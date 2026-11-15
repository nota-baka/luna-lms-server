package main

import (
	"log"

	apiv1 "Luna.LMS/luna-server/api/v1"
	dbquerier "Luna.LMS/luna-server/db_querier"
	"github.com/gin-gonic/gin"
)

func main() {
	// Initialise database instance
	err := dbquerier.Init()

	defer func() {
		err := dbquerier.Close()
		if err != nil {
			log.Fatal(err)
		}
	}()

	if err != nil {
		log.Fatal(err)
		return
	}

	// Create a Gin engine instance
	g := gin.Default()

	// Prepare the server
	bindHandlers(g)

	// Run the server
	err = g.Run()
	if err != nil {
		log.Fatal(err)
		return
	}
}

// bindHandlers binds all API paths to their respective handlers
func bindHandlers(g *gin.Engine) {
	g.GET("/v1/srv/ping", apiv1.Ping)
}
