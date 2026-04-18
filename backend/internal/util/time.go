package util

import "time"

// NowMillis returns the current UNIX time in milliseconds.
func NowMillis() int64 {
	return time.Now().UnixMilli()
}
