package dbquerier

import (
	"database/sql"
	"log"

	_ "github.com/jackc/pgx/v5/stdlib"
)

// dbConn is database connection handler
var dbConn *sql.DB

// Init creates PostgreSQL database handler before any query
func Init() error {
	// TODO: replace hard-coded connection link with config
	dsn := "postgres://test-db-user:test-db-pass@localhost:5432/test-db-user?sslmode=disable"
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
