package apiv1

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// A response data for the Ping
type ResponsePing struct {
	Status string `json:"status"`
}

// Ping is an API handler for a ping request
func Ping(c *gin.Context) {
	c.JSON(http.StatusOK, ResponsePing{"pong"})
}
