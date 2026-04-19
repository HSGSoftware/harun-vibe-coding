package api

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// stub is a placeholder used by routes not yet implemented in this phase.
// Returns 501 and the matched route path so the client can surface a useful
// "Faz N'de açılacak" banner.
func stub(c *gin.Context) {
	c.JSON(http.StatusNotImplemented, gin.H{"error": "not_implemented", "path": c.FullPath()})
}
