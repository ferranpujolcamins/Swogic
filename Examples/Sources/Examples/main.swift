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

let login: State<Void, HttpStatus> = { .ok } ~ "login"
let request: State<Void, HttpStatus> = { .ok } ~ "request"
let refresh: State<Void, HttpStatus> = { .ok } ~ "refresh"
let logError: State<HttpStatus, Void> = { _ in } ~ "logError"

// TODO: replace consume by operator
let refreshAndRetry: StateMachine<Void, Void> = StateMachine([
    refresh ---- { .ok            } ---> refresh.consume ---> request ---> request.consume,
    refresh ---- { .unauthorized  } ---> logError,
    refresh ---- { .internalError } ---> logError
])

let process: StateMachine<Void, Void> = StateMachine([
    login ---- { .ok            } ---> login.consume ---> request ---- { .unauthorized  } ---> login.consume ---> refreshAndRetry,
    login ---- { .ok            } ---> login.consume ---> request ---- { .internalError } ---> logError,
    login ---- { .unauthorized  } ---> login.consume ---> refreshAndRetry,
    login ---- { .internalError } ---> logError as StepChain<Void, Void>
    // TODO: think of a placeholder so we don't need to repeat login all the time
])
/*
                          | .checkAvailability                              | .performOperation & .log
                          |                                                 |
waiting ---- { .started } ^ ---> checkingAvailability ---- { .available   } ^ ---> waiting

                                                                            | .log
                                                                            |
waiting ---- { .started } * ---> checkingAvailability ---- { .unavailable } ^ ---> waiting
*/
