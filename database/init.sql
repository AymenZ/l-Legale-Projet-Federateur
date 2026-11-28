-- Exécuté automatiquement au premier démarrage du conteneur.
CREATE EXTENSION IF NOT EXISTS vector;      -- pgvector (embeddings du RAG)
CREATE EXTENSION IF NOT EXISTS pgcrypto;    -- gen_random_uuid()
