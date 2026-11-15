package apiv1

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// ResponsePing is response data type for Ping
type ResponsePing struct {
	Status string `json:"status"`
}

// Ping is API handler for ping request
func Ping(c *gin.Context) {
	c.JSON(http.StatusOK, ResponsePing{"pong"})
}
