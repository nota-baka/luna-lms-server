package dbquerier

import (
	"database/sql"
	"log"

	_ "github.com/jackc/pgx/v5/stdlib"
)

var DbConn *sql.DB

// Init creates PostgreSQL database connection before any query
func Init() error {
	// TODO: replace hard-coded connection link with config
	dsn := "postgres://test-db-user:test-db-pass@localhost:5432/test-db-user?sslmode=disable"
	var err error
	DbConn, err = sql.Open("pgx", dsn)

	if err != nil {
		log.Fatal(err)
		return err
	}

	if err = DbConn.Ping(); err != nil {
		log.Fatal(err)
		return err
	}

	return nil
}

func Close() error {
	if err := DbConn.Close(); err != nil {
		log.Fatal(err)
		return err
	}
	return nil
}
