@testable import Swogic

struct SimpleError: Equatable, EquatableToAny {
    let errorMessage: String
}

enum HttpStatus: Equatable, EquatableAfterProjection {
    enum Projected: Equatable, EquatableToAny {
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

let login: Step<Void, HttpStatus> = { .ok } ~ "login"
let request: Step<Void, HttpStatus> = { .ok } ~ "request"
let refresh: Step<Void, HttpStatus> = { .ok } ~ "refresh"
let logError: Step<HttpStatus, Void> = { _ in } ~ "logError"

// TODO: replace consume by operator
let refreshAndRetry: Process<Void, Void> = Process([
    refresh ---- { .ok            } ---> refresh.consume ---> request ---> request.consume,
    refresh ---- { .unauthorized  } ---> logError,
    refresh ---- { .internalError } ---> logError
])

let process: Process<Void, Void> = Process([
    login ---- { .ok            } ---> login.consume ---> request ---- { .unauthorized  } ---> login.consume ---> refreshAndRetry,
    login ---- { .ok            } ---> login.consume ---> request ---- { .internalError } ---> logError,
    login ---- { .unauthorized  } ---> login.consume ---> refreshAndRetry,
    login ---- { .internalError } ---> logError as StepChain<Void, Void>
    // TODO: think of a placeholder so we don't need to repeat login all the time
])
