package helpers

import (
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"errors"

	"Luna.LMS/luna-server/config"
	"golang.org/x/crypto/bcrypt"
	"golang.org/x/crypto/chacha20poly1305"
)

var aead cipher.AEAD

func InitCrypto() error {
	if aead == nil {
		var err error
		aead, err = chacha20poly1305.NewX(config.GlobalConfig.Encryption.Key)
		if err != nil {
			return err
		}
	}
	return nil
}

// VerifyPassword compares password string against hash
func VerifyPassword(password string, hash []byte) bool {
	err := bcrypt.CompareHashAndPassword(hash, []byte(password))
	return err == nil
}

// HashPassword generates hash from password string
func HashPassword(password string) ([]byte, error) {
	return bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
}

// EncryptString encrypts string and returns result in the form (nonce + encrypted bytes)
func EncryptString(plainText string) ([]byte, error) {
	nonce := make([]byte, aead.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return nil, err
	}

	encText := aead.Seal(nonce, nonce, []byte(plainText), nil)

	return encText, nil
}

// DecryptString decrypts encrypted text and returns string
func DecryptString(encText []byte) (string, error) {
	nonceSize := aead.NonceSize()
	if len(encText) < nonceSize {
		return "", errors.New("ciphertext too short")
	}
	nonce := encText[:nonceSize]
	encText = encText[nonceSize:]
	decrypted, err := aead.Open(nil, nonce, encText, nil)
	if err != nil {
		return "", err
	}
	return string(decrypted), nil
}

// GenerateToken generates 32 bytes long random token
func GenerateToken() ([]byte, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return nil, err
	}
	return b, nil

}

// HashToken generates hash from token using SHA-256
func HashToken(token []byte) []byte {
	sum := sha256.Sum256(token)
	return sum[:]
}

// VerifyToken compares token with hash
func VerifyToken(token []byte, hash []byte) bool {
	sum := HashToken(token)
	return subtle.ConstantTimeCompare(sum, hash) == 1
}
