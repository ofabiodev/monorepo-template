package server

import (
	"encoding/json"
	"log/slog"
	"net/http"

	"github.com/monorepo-template/api/internal/repository"
)

type Server struct {
	queries *repository.Queries
}

func New(queries *repository.Queries) *Server {
	return &Server{queries: queries}
}

// Routes registers all HTTP routes on a new mux.
func (s *Server) Routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /hello", s.handleHello)
	return mux
}

type helloResponse struct {
	Message string `json:"message"`
}

func (s *Server) handleHello(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, helloResponse{Message: "hello world"})
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(v); err != nil {
		slog.Error("write json response", "error", err)
	}
}
