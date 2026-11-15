package config

import (
	"errors"
	"log"
	"os"
	"strconv"

	"github.com/BurntSushi/toml"
	gap "github.com/muesli/go-app-paths"
)

// Config struct represents Luna.LMS server configuration parameters
type Config struct {
	Database struct {
		Host    string `toml:"host"`
		Port    int    `toml:"port"`
		User    string `toml:"user"`
		Pass    string `toml:"pass"`
		Name    string `toml:"name"`
		SSLMode bool   `toml:"ssl_mode"`
	}

	Server struct {
		Port int `toml:"port"`
	}
}

// GlobalConfig is server's configuration
var GlobalConfig Config

// Init loads configuration to GlobalConfig variable
func Init() error {
	log.Println("CONFIG: Starting configuration parsing...")
	err := initWithConfigFiles()
	if err != nil {
		return err
	}
	err = initWithEnvVariables()
	if err != nil {
		return err
	}
	err = checkConfiguration()
	if err != nil {
		return err
	}
	log.Println("CONFIG: Finished configuration parsing")
	return nil
}

// initWithConfigFiles tries to load configuration from standard configuration paths
func initWithConfigFiles() error {
	// Get existing configuration files
	scope := gap.NewScope(gap.User, "luna-lms-server")
	configFiles, err := scope.LookupConfig("config.toml")
	if err != nil {
		log.Println(err)
		return err
	}

	// Go through found configuration files
	for _, configFile := range configFiles {
		file, err := os.ReadFile(configFile)
		if err != nil {
			log.Println(err)
			return err
		}

		// Parse configuration file
		err = toml.Unmarshal(file, &GlobalConfig)
		if err != nil {
			log.Println(err)
			return err
		}
	}
	return nil
}

// initWithEnvVariables tries to load configuration from environment variables
func initWithEnvVariables() error {
	if dbHost := os.Getenv("LUNA_DATABASE_HOST"); dbHost != "" {
		GlobalConfig.Database.Host = dbHost
	}
	if dbPort := os.Getenv("LUNA_DATABASE_PORT"); dbPort != "" {
		var err error
		GlobalConfig.Database.Port, err = strconv.Atoi(dbPort)
		if err != nil {
			log.Println("CONFIG: Error converting database port to int")
			return err
		}
	}
	if dbUser := os.Getenv("LUNA_DATABASE_USER"); dbUser != "" {
		GlobalConfig.Database.User = dbUser
	}
	if dbPass := os.Getenv("LUNA_DATABASE_PASS"); dbPass != "" {
		GlobalConfig.Database.Pass = dbPass
	}
	if dbName := os.Getenv("LUNA_DATABASE_NAME"); dbName != "" {
		GlobalConfig.Database.Name = dbName
	}
	if dbSSLMode := os.Getenv("LUNA_DB_SSL_MODE"); dbSSLMode != "" {
		GlobalConfig.Database.SSLMode = true
	}
	if srvPort := os.Getenv("LUNA_SERVER_PORT"); srvPort != "" {
		var err error
		GlobalConfig.Server.Port, err = strconv.Atoi(srvPort)
		if err != nil {
			log.Println("CONFIG: Error converting server port to int")
			return err
		}
	}
	return nil
}

// checkConfiguration validates parsed configuration
func checkConfiguration() error {
	fail := false

	if GlobalConfig.Database.Host == "" {
		log.Println("CONFIG: Database host is required")
		fail = true
	}
	if GlobalConfig.Database.Port <= 0 || GlobalConfig.Database.Port > 65535 {
		log.Println("CONFIG: Database port must more than 0 and less than 65535")
		fail = true
	}
	if GlobalConfig.Database.User == "" {
		log.Println("CONFIG: Database user is required")
		fail = true
	}
	if GlobalConfig.Database.Pass == "" {
		log.Println("CONFIG: Database password is required")
		fail = true
	}
	if GlobalConfig.Database.Name == "" {
		log.Println("CONFIG: Database name is required")
		fail = true
	}
	if GlobalConfig.Server.Port <= 0 || GlobalConfig.Server.Port > 65535 {
		log.Println("CONFIG: Server port must more than 0 and less than 65535")
		fail = true
	}

	if fail {
		log.Println("Configuration has failed. Terminating...")
		return errors.New("configuration has failed")
	}

	return nil
}
