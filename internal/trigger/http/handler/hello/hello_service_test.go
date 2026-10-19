package hello

import (
	"encoding/json"
	"testing"

	"github.com/cloudwego/hertz/pkg/app/server"
	"github.com/cloudwego/hertz/pkg/common/ut"
	"github.com/cloudwego/hertz/pkg/protocol/consts"
)

func TestHello(t *testing.T) {
	h := server.New()
	h.GET("/hello", Hello)

	tests := []struct {
		name        string
		target      string
		wantStatus  int
		wantMessage string
	}{
		{
			name:        "valid name",
			target:      "/hello?name=World",
			wantStatus:  consts.StatusOK,
			wantMessage: "Hello, World!",
		},
		{
			name:       "missing required name",
			target:     "/hello",
			wantStatus: consts.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			response := ut.PerformRequest(h.Engine, consts.MethodGet, tt.target, nil).Result()
			if response.StatusCode() != tt.wantStatus {
				t.Fatalf("expected status %d, got %d", tt.wantStatus, response.StatusCode())
			}

			if tt.wantStatus != consts.StatusOK {
				if len(response.Body()) == 0 {
					t.Error("expected validation error response body")
				}
				return
			}

			var body struct {
				Message string `json:"message"`
			}
			if err := json.Unmarshal(response.Body(), &body); err != nil {
				t.Fatalf("decode response body: %v", err)
			}
			if body.Message != tt.wantMessage {
				t.Errorf("expected message %q, got %q", tt.wantMessage, body.Message)
			}
		})
	}
}
