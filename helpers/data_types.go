package helpers

import (
	"fmt"
	"strings"
	"time"
)

// AccountRole is user's account role type
type AccountRole int

// Enumeration of account role
const (
	RoleUnknown       AccountRole = iota // 0
	RoleAdministrator                    // 1
	RoleModerator                        // 2
	RoleCourseManager                    // 3
	RoleStudent                          // 4
)

// String returns string representation of AccountRole value
func (a AccountRole) String() string {
	switch a {
	case RoleUnknown:
		return "Unknown"
	case RoleAdministrator:
		return "Administrator"
	case RoleModerator:
		return "Moderator"
	case RoleCourseManager:
		return "Course_Manager"
	case RoleStudent:
		return "Student"
	default:
		return fmt.Sprintf("AccountRole(%d)", int(a))
	}
}

// FromString returns AccountRole value extracted from string
func (AccountRole) FromString(s string) AccountRole {
	switch strings.ToUpper(s) {
	case "ADMINISTRATOR":
		return RoleAdministrator
	case "MODERATOR":
		return RoleModerator
	case "COURSE_MANAGER":
		return RoleCourseManager
	case "STUDENT":
		return RoleStudent
	default:
		return RoleUnknown
	}
}

type Account struct {
	Id           string
	Role         AccountRole
	Name         string
	EmailAddress string
	PasswordHash string
}

type Device struct {
	Id           string
	AccountId    string
	LastOnlineAt time.Time
	Token        string
	ExpireAt     time.Time
}
