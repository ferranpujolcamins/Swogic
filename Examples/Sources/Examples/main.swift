@testable import Swogic

struct SimpleError: Equatable, EquatableToAny {
    let errorMessage: String

    static var placeholder: SimpleError {
        return SimpleError(errorMessage: "dummy")
    }
}

enum A: CaseIterable {
    case a
}

enum HttpStatus: Equatable, EquatableToAny {
    case ok
    case unauthorized(SimpleError)
    case internalError(SimpleError)

    public func isEqual(to other: Any) -> Bool {
        if let other = other as? HttpStatus {
            switch (other, self) {
            case (.ok, .ok), (.unauthorized, .unauthorized), (.internalError, .internalError):
                return true
            default:
                return false
            }
        }
        return false
    }
}

let login: Step<Void, HttpStatus>
let request: Step<Void, HttpStatus>
let refresh: Step<Void, HttpStatus>
let logError: Step<HttpStatus, Void>

let a: StepChain<Void, Void> = refresh ---- {  .ok   } ---> refresh.consume
let b: StepChain<Void, HttpStatus> = refresh ---- { .unauthorized(SimpleError.dummy) }
let c: StepChain<Void, Void> = b ---> logError
let d: StepChain<Void, Void> = refresh ---- { .unauthorized(SimpleError.dummy)  } ---> logError

// TODO: replace consume by operator
let refreshAndRetry = Process([
    refresh ---- { .ok            } ---> refresh.consume ---> request ---> request.consume,
    refresh ---- { .unauthorized(SimpleError.placeholder)  } ---> logError,
    refresh ---- { .internalError(SimpleError.placeholder) } ---> logError
])

let process = Process([
    login ---- { .ok            } ---> request ---- { .unauthorized  } ---> refreshAndRetry,
    login ---- { .ok            } ---> request ---- { .internalError } ---> logError,
    login ---- { .unauthorized  } ---> refreshAndRetry,
    login ---- { .internalError } ---> logError

    // TODO: think of a placeholder so we don't need to repeat login all the time
])
