@testable import Swogic

struct SimpleError: Equatable, EquatableToAny {
    let errorMessage: String

    static var placeholder: SimpleError {
        return SimpleError(errorMessage: "dummy")
    }
}

enum HttpStatus: Equatable, EquatableAfterProjection {
    static var projection: () -> HttpStatus.Projected


    enum Projected {
        case ok
        case unauthorized
        case internalError
    }

    case ok
    case unauthorized(SimpleError)
    case internalError(SimpleError)

    static var projection: (HttpStatus) -> Projected {
        return {
            switch $0 {
            case .ok:
                return .ok
            case .unauthorized:
                return .unauthorized
            case .internalError:
                return.internalError
            }
        }
    }
}

let login: Step<Void, HttpStatus>
let request: Step<Void, HttpStatus>
let refresh: Step<Void, HttpStatus>
let logError: Step<HttpStatus, Void>

let a: StepChain<Void, Void> = refresh ---- {  .ok   } ---> refresh.consume
let b: StepChain<Void, HttpStatus> = refresh ---- { .unauthorized }
let c: StepChain<Void, Void> = b ---> logError
let d: StepChain<Void, Void> = refresh ---- { .unauthorized  } ---> logError

// TODO: replace consume by operator
let refreshAndRetry = Process([
    refresh ---- { .ok            } ---> refresh.consume ---> request ---> request.consume,
    refresh ---- { .unauthorized  } ---> logError,
    refresh ---- { .internalError } ---> logError
])

let process = Process([
    login ---- { .ok            } ---> request ---- { .unauthorized  } ---> refreshAndRetry,
    login ---- { .ok            } ---> request ---- { .internalError } ---> logError,
    login ---- { .unauthorized  } ---> refreshAndRetry,
    login ---- { .internalError } ---> logError

    // TODO: think of a placeholder so we don't need to repeat login all the time
])
