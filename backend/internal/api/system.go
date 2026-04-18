package api

import (
	"net/http"
	"runtime"
	"time"

	"github.com/gin-gonic/gin"

	"github.com/hsgsoftware/harun-vibe-coding/backend/pkg/version"
)

// RegisterSystem mounts /health and /system/* endpoints.
func RegisterSystem(r *gin.RouterGroup, d Deps) {
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"ok":               true,
			"version":          version.Version,
			"uptime_sec":       int(time.Since(d.StartedAt).Seconds()),
			"projects_running": 0,
			"ai_ready":         false,
		})
	})

	r.GET("/system/info", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"os":                 runtime.GOOS,
			"arch":               runtime.GOARCH,
			"cpu":                runtime.NumCPU(),
			"go_version":         runtime.Version(),
			"termux_version":     "",
			"git_version":        "",
			"node_version":       "",
			"python_version":     "",
			"cloudflared_version": "",
			"android_sdk":        "",
			"ram_mb":             0,
			"disk_free_gb":       0,
		})
	})

	r.GET("/system/stats", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"cpu_percent":      0,
			"ram_used_mb":      0,
			"ram_total_mb":     0,
			"battery_percent":  0,
			"battery_charging": false,
			"temperature_c":    0,
			"uptime_sec":       int(time.Since(d.StartedAt).Seconds()),
		})
	})

	r.POST("/system/shutdown", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
}
