DROP TABLE IF EXISTS contact;

-- Création de la table
CREATE TABLE contact (
    id SERIAL PRIMARY KEY,
    sender VARCHAR(255) NULL,
    recipient VARCHAR(255) NULL,
    subject VARCHAR(255) NULL,
    content TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NULL
);

-- Insertion de plusieurs lignes de test
INSERT INTO contact (sender, recipient, subject, content, created_at) VALUES
('test1@test.com', 'contact1@cloudnative.dev', 'Demande 1', 'Contenu de la demande 1', NOW()),
('test2@test.com', 'contact2@cloudnative.dev', 'Demande 2', 'Contenu de la demande 2', NOW()),
('test3@test.com', 'contact3@cloudnative.dev', 'Demande 3', 'Contenu de la demande 3', NOW());
