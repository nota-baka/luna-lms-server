package apiv1

import (
	"database/sql"
	"errors"
	"net/http"

	dbquerier "Luna.LMS/luna-server/db_querier"
	"github.com/gin-gonic/gin"
)

// RequestAuthLogin is expected request for login
type RequestAuthLogin struct {
	EmailAddress string `json:"email_address"`
	Password     string `json:"password"`
}

// ResponseAuthLogin is expected response for successful login
type ResponseAuthLogin struct {
	Id   string `json:"id"`
	Role string `json:"role"`
	Name string `json:"name"`
}

// ResponseAuthLoginTotpInit is expected response for successful login requiring TOTP authentication
type ResponseAuthLoginTotpInit struct {
	TotpAttemptId string `json:"totp_attempt_id"`
}

// RequestAuthLoginTotpConfirm is expected request for TOTP authentication
type RequestAuthLoginTotpConfirm struct {
	TotpAttemptId string `json:"totp_attempt_id"`
	TotpCode      string `json:"totp_code"`
}

// AuthLoginHandler processes login request
func AuthLoginHandler(g *gin.Context) {
	var creds RequestAuthLogin
	if err := g.ShouldBindJSON(&creds); err != nil || creds.EmailAddress == "" || creds.Password == "" {
		g.Status(http.StatusBadRequest)
		return
	}

	account, err := dbquerier.GetAccountByCreds(g, creds.EmailAddress)
	if err != nil {
		g.Status(http.StatusUnauthorized)
		return
	}

	_, err = dbquerier.GetTotpSecretByAccountId(g, account.Id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			device, err := dbquerier.RegisterDevice(g, account.Id)
			if err != nil {
				g.Status(http.StatusInternalServerError)
				return
			}
			// TODO: CHANGE secure TO TRUE, OR JUST MAKE IT CONFIGURABLE IN RUNTIME
			g.SetCookie("deviceId", device.Id, 60*60*24*30, "/", "", false, true)
			g.SetCookie("sessionToken", device.Token, 60*10, "/", "", false, true)
			g.JSON(http.StatusOK, ResponseAuthLogin{
				Id:   account.Id,
				Role: account.Role.String(),
				Name: account.Name,
			})
			return
		}

		g.Status(http.StatusInternalServerError)
		return
	}

	var totpAttemptId string
	totpAttemptId, err = dbquerier.RegisterTotpAttempt(g, account.Id)
	if err != nil {
		g.Status(http.StatusInternalServerError)
		return
	}
	g.JSON(http.StatusOK, ResponseAuthLoginTotpInit{totpAttemptId})
}
