package dbquerier

import (
	"database/sql"
	"fmt"
	"log"

	"Luna.LMS/luna-server/config"
	_ "github.com/jackc/pgx/v5/stdlib"
)

// dbConn is database connection handler
var dbConn *sql.DB

// Init creates PostgreSQL database handler before any query
func Init() error {
	log.Println("DATABASE: Initialising database connection")

	dsn := prepareConnectionURL()
	var err error
	dbConn, err = sql.Open("pgx", dsn)

	if err != nil {
		log.Println(err)
		return err
	}

	if err = dbConn.Ping(); err != nil {
		log.Println(err)
		return err
	}

	log.Println("DATABASE: Connected")

	return nil
}

// Close closes database handler instance
func Close() error {
	if err := dbConn.Close(); err != nil {
		log.Println(err)
		return err
	}
	return nil
}

// prepareConnectionURL formats database connection URL from GlobalConfig fields
func prepareConnectionURL() string {
	sslMode := "disable"
	if config.GlobalConfig.Database.SSLMode {
		sslMode = "verify-full"
	}
	return fmt.Sprintf(
		"postgres://%s:%s@%s:%d/%s?sslmode=%s",
		config.GlobalConfig.Database.User,
		config.GlobalConfig.Database.Pass,
		config.GlobalConfig.Database.Host,
		config.GlobalConfig.Database.Port,
		config.GlobalConfig.Database.Name,
		sslMode,
	)
}
