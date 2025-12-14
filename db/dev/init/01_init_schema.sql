-- Création du type ENUM pour le statut du document
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'document_status') THEN
        CREATE TYPE document_status AS ENUM (
            'PROCESSING',
            'COMPLETED',
            'SENDED',
            'FAILED'
        );
    END IF;
END$$;

-- Table des documents qui sont décomposés en chunks
CREATE TABLE documents (
    document_id UUID PRIMARY KEY,
    total_chunks INT NOT NULL,
    processed_chunks INT DEFAULT 0,
    document_status document_status DEFAULT 'PROCESSING'
);

-- Table des mots-clés par chunk
CREATE TABLE keywords (
    id SERIAL PRIMARY KEY,
    document_id UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    chunk_number INT NOT NULL,
    keywords JSONB NOT NULL,
    processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Index utiles pour le polling
CREATE INDEX idx_documents_status ON documents (document_status);
CREATE INDEX idx_keywords_document_id ON keywords (document_id);

CREATE INDEX idx_keywords_document_chunk ON keywords(document_id, chunk_number);

CREATE INDEX idx_documents_status_processed 
    ON documents (document_status, processed_chunks, total_chunks);

-- Contraintes d'unicité
ALTER TABLE documents
    ALTER COLUMN document_status TYPE document_status
    USING document_status::text::document_status;

ALTER TABLE keywords ADD CONSTRAINT uk_keywords_document_chunk UNIQUE (document_id, chunk_number);

