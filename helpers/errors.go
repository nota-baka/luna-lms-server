package helpers

import "fmt"

// Request error type
type RequestError int

// Enumeration of request errors
const (
	ReqerrUnknown           RequestError = iota // 0
	ReqerrInvalidReqBody                        // 1
	ReqerrNoAuthToken                           // 2
	ReqerrBadAuthToken                          // 3
	ReqerrBadLoginCreds                         // 4
	ReqerrFailedTotpAttempt                     // 5
)

// Get a string representation of a RequestError value
func (r RequestError) String() string {
	switch r {
	case ReqerrUnknown:
		return "Unknown"
	case ReqerrInvalidReqBody:
		return "InvalidReqBody"
	case ReqerrNoAuthToken:
		return "NoAuthToken"
	case ReqerrBadAuthToken:
		return "BadAuthToken"
	case ReqerrBadLoginCreds:
		return "BadLoginCreds"
	case ReqerrFailedTotpAttempt:
		return "FailedTotpAttempt"
	default:
		return fmt.Sprintf("RequestError(%d)", int(r))
	}
}

// Get a text description of a RequestError value
func (r RequestError) Desc() string {
	switch r {
	case ReqerrUnknown:
		return "Unknown error"
	case ReqerrInvalidReqBody:
		return "Invalid request body provided"
	case ReqerrNoAuthToken:
		return "No authentication token provided"
	case ReqerrBadAuthToken:
		return "Bad authentication token provided"
	case ReqerrBadLoginCreds:
		return "Bad login credentials provided"
	case ReqerrFailedTotpAttempt:
		return "TOTP attempt failed"
	default:
		return fmt.Sprintf("RequestError(%s)", r)
	}
}
