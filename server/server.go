package main

import (
	apiv1 "Luna.LMS/luna-server/api/v1"
	"github.com/gin-gonic/gin"
)

func main() {
	// Create a Gin engine instance
	g := gin.Default()

	// Prepare the server
	bindHandlers(g)

	// Run the server
	g.Run()
}

// bindHandlers binds all API pathes to their respective handlers
func bindHandlers(g *gin.Engine) {
	g.GET("/v1/srv/ping", apiv1.Ping)
}
