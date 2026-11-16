package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	apiv1 "Luna.LMS/luna-server/api/v1"
	"Luna.LMS/luna-server/config"
	dbquerier "Luna.LMS/luna-server/db_querier"
	"Luna.LMS/luna-server/helpers"
	"github.com/gin-gonic/gin"
)

func main() {
	// Initialise server configuration
	err := config.Init()
	if err != nil {
		return
	}

	// Initialise cryptographic functionality
	err = helpers.InitCrypto()
	if err != nil {
		log.Println(err)
		return
	}

	// Initialise database instance
	err = dbquerier.Init()
	if err != nil {
		log.Println(err)
		return
	}

	defer func() {
		err := dbquerier.Close()
		if err != nil {
			log.Println(err)
		}
	}()

	server := initServer()

	// TODO: Add support for TLS/SSL
	// Run server
	err = server.ListenAndServe()
	if err != nil {
		log.Println(err)
	}

	defer func(server *http.Server) {
		err := server.Close()
		if err != nil {

		}
	}(server)
}

// initServer prepares HTTP server instance and returns it
func initServer() *http.Server {
	// Create Gin engine instance
	g := gin.Default()

	// Prepare API handlers
	bindHandlers(g)

	// Configure server parameters
	s := &http.Server{
		Addr:         fmt.Sprintf(":%d", config.GlobalConfig.Server.Port),
		Handler:      g,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
	}
	return s
}

// bindHandlers binds all API paths to their respective handlers
func bindHandlers(g *gin.Engine) {
	g.GET("/v1/srv/ping", apiv1.Ping)
}
