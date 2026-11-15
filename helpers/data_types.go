package helpers

import "fmt"

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
		return "CourseManager"
	case RoleStudent:
		return "Student"
	default:
		return fmt.Sprintf("AccountRole(%d)", int(a))
	}
}
