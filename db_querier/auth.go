package dbquerier

import (
	"encoding/base64"
	"log"

	"Luna.LMS/luna-server/helpers"
	"github.com/gin-gonic/gin"
)

// GetAccountByCreds Returns account data by email address, if exists. Returns error if it does not
func GetAccountByCreds(c *gin.Context, emailAddress string) (helpers.Account, error) {
	var account helpers.Account
	row := dbConn.QueryRowContext(c, "SELECT id, role, name, email_address, password_hash FROM accounts WHERE email_address = $1", emailAddress)
	var accountRoleStr string
	if err := row.Scan(&account.Id, &accountRoleStr, &account.Name, &account.EmailAddress, &account.PasswordHash); err != nil {
		log.Println(err)
		return helpers.Account{}, err
	}
	account.Role = account.Role.FromString(accountRoleStr)
	return account, nil
}

// RegisterTotpAttempt saves TOTP attempt ID for account
func RegisterTotpAttempt(c *gin.Context, accountId string) (string, error) {
	var totpAttemptId string
	err := dbConn.QueryRowContext(c, "INSERT INTO accounts_totp_attempts (account_id) VALUES ($1) RETURNING id", accountId).Scan(&totpAttemptId)
	if err != nil {
		log.Println(err)
		return "", err
	}
	return totpAttemptId, nil
}

// GetTotpSecretByAccountId Checks if account has TOTP setup and returns encrypted secret if yes
func GetTotpSecretByAccountId(c *gin.Context, accountId string) ([]byte, error) {
	var secretEnc []byte
	err := dbConn.QueryRowContext(c, "SELECT secret_enc FROM accounts_totp WHERE account_id=$1 AND confirmed", accountId).Scan(&secretEnc)
	if err != nil {
		return nil, err
	}
	return secretEnc, nil
}

// RegisterDevice saves session data for new login
func RegisterDevice(c *gin.Context, accountId string) (helpers.Device, error) {
	sessionToken, err := helpers.GenerateToken()
	if err != nil {
		log.Println(err)
		return helpers.Device{}, err
	}
	sessionTokenHash := helpers.HashToken(sessionToken)
	var device helpers.Device
	err = dbConn.QueryRowContext(c, "INSERT INTO devices (account_id, session_token_hash) VALUES ($1, $2) RETURNING id, session_expires_at", accountId, sessionTokenHash).Scan(&device.Id, &device.Token)
	if err != nil {
		log.Println(err)
		return helpers.Device{}, err
	}
	device.AccountId = accountId
	device.Token = base64.StdEncoding.EncodeToString(sessionToken)
	return device, nil
}

// ValidateSessionToken validates provided sessionToken against database
//func ValidateSessionToken(c *gin.Context, sessionToken []byte) ([]byte, error) {
//	var sessionTokenHash []byte
//}
