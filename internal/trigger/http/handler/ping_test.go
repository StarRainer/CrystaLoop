package handler

import (
	"encoding/json"
	"testing"

	"github.com/cloudwego/hertz/pkg/app/server"
	"github.com/cloudwego/hertz/pkg/common/ut"
	"github.com/cloudwego/hertz/pkg/protocol/consts"
)

func TestPing(t *testing.T) {
	h := server.New()
	h.GET("/ping", Ping)

	response := ut.PerformRequest(h.Engine, consts.MethodGet, "/ping", nil).Result()
	if response.StatusCode() != consts.StatusOK {
		t.Fatalf("expected status %d, got %d", consts.StatusOK, response.StatusCode())
	}

	var body struct {
		Message string `json:"message"`
	}
	if err := json.Unmarshal(response.Body(), &body); err != nil {
		t.Fatalf("decode response body: %v", err)
	}
	if body.Message != "pong" {
		t.Errorf("expected message %q, got %q", "pong", body.Message)
	}
}
