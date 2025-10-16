-- =============================================
-- Loya - BASE DE DONNÉES COMPLÈTE
-- =============================================

-- Création de la base de données
CREATE DATABASE IF NOT EXISTS Loya CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE Loya;

-- =============================================
-- TABLE : utilisateurs (Tous les utilisateurs)
-- =============================================
CREATE TABLE utilisateurs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    telephone VARCHAR(50),
    mot_de_passe VARCHAR(255) NOT NULL,
    role ENUM('client', 'coiffeur', 'admin') DEFAULT 'client',
    prenom VARCHAR(100),
    nom VARCHAR(100),
    date_naissance DATE,
    genre ENUM('homme', 'femme', 'autre'),
    est_verifie BOOLEAN DEFAULT FALSE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- TABLE : profils_coiffeurs (Pro détaillé)
-- =============================================
CREATE TABLE profils_coiffeurs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    utilisateur_id INT UNIQUE,
    biographie TEXT,
    adresse TEXT,
    ville VARCHAR(100),
    code_postal VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    annees_experience INT DEFAULT 0,
    note_moyenne DECIMAL(3, 2) DEFAULT 0.00,
    nombre_avis INT DEFAULT 0,
    est_actif BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
);

-- =============================================
-- TABLE : services (Services proposés)
-- =============================================
CREATE TABLE services (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coiffeur_id INT,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    prix DECIMAL(8, 2) NOT NULL,
    duree INT NOT NULL COMMENT 'Durée en minutes',
    categorie ENUM('coupe', 'coloration', 'soin', 'coiffure', 'barbe', 'autre'),
    est_actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coiffeur_id) REFERENCES profils_coiffeurs(id) ON DELETE CASCADE
);

-- =============================================
-- TABLE : disponibilites (Plannings coiffeurs)
-- =============================================
CREATE TABLE disponibilites (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coiffeur_id INT,
    jour_semaine ENUM('lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'),
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    est_actif BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (coiffeur_id) REFERENCES profils_coiffeurs(id) ON DELETE CASCADE
);

-- =============================================
-- TABLE : rendez_vous (Réservations)
-- =============================================
CREATE TABLE rendez_vous (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT,
    coiffeur_id INT,
    service_id INT,
    date_rdv DATE NOT NULL,
    heure_rdv TIME NOT NULL,
    statut ENUM('confirme', 'annule', 'termine', 'en_attente') DEFAULT 'en_attente',
    prix_total DECIMAL(8, 2),
    notes_client TEXT,
    notes_coiffeur TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES utilisateurs(id),
    FOREIGN KEY (coiffeur_id) REFERENCES profils_coiffeurs(id),
    FOREIGN KEY (service_id) REFERENCES services(id)
);

-- =============================================
-- TABLE : paiements (Transactions Flutterwave)
-- =============================================
CREATE TABLE paiements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    rendez_vous_id INT UNIQUE,
    montant_total DECIMAL(8, 2) NOT NULL,
    commission_plateforme DECIMAL(8, 2) NOT NULL COMMENT '15% du montant total',
    montant_coiffeur DECIMAL(8, 2) NOT NULL COMMENT '85% du montant total',
    methode_paiement ENUM('mobile_money', 'carte', 'virement', 'especes'),
    operateur_mobile VARCHAR(50) COMMENT 'Orange, MTN, etc.',
    numero_transaction VARCHAR(100) COMMENT 'ID Flutterwave',
    statut_paiement ENUM('en_attente', 'paye', 'echec', 'rembourse'),
    date_paiement TIMESTAMP NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rendez_vous_id) REFERENCES rendez_vous(id)
);

-- =============================================
-- TABLE : avis (Notes et commentaires)
-- =============================================
CREATE TABLE avis (
    id INT PRIMARY KEY AUTO_INCREMENT,
    rendez_vous_id INT UNIQUE,
    client_id INT,
    coiffeur_id INT,
    note INT CHECK (note >= 1 AND note <= 5),
    commentaire TEXT,
    est_verifie BOOLEAN DEFAULT FALSE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rendez_vous_id) REFERENCES rendez_vous(id),
    FOREIGN KEY (client_id) REFERENCES utilisateurs(id),
    FOREIGN KEY (coiffeur_id) REFERENCES profils_coiffeurs(id)
);

-- =============================================
-- TABLE : verifications (KYC coiffeurs)
-- =============================================
CREATE TABLE verifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coiffeur_id INT UNIQUE,
    type_document ENUM('cni', 'passeport', 'permis'),
    pays_document VARCHAR(100),
    recto_document VARCHAR(255) COMMENT 'URL de l image',
    verso_document VARCHAR(255) COMMENT 'URL de l image',
    selfie_avec_document VARCHAR(255) COMMENT 'URL de l image',
    statut_verification ENUM('en_attente', 'approuve', 'rejete') DEFAULT 'en_attente',
    raison_rejet TEXT,
    verifie_par_admin INT COMMENT 'ID admin qui a validé',
    date_soumission TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_verification TIMESTAMP NULL,
    FOREIGN KEY (coiffeur_id) REFERENCES profils_coiffeurs(id),
    FOREIGN KEY (verifie_par_admin) REFERENCES utilisateurs(id)
);

-- =============================================
-- TABLE : photos_coiffeurs (Galerie portfolios)
-- =============================================
CREATE TABLE photos_coiffeurs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coiffeur_id INT,
    url_photo VARCHAR(255) NOT NULL,
    type_photo ENUM('avatar', 'portfolio', 'salon', 'certification'),
    legende VARCHAR(200),
    ordre_affichage INT DEFAULT 0,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coiffeur_id) REFERENCES profils_coiffeurs(id) ON DELETE CASCADE
);

-- =============================================
-- TABLE : favoris (Coiffeurs favoris clients)
-- =============================================
CREATE TABLE favoris (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT,
    coiffeur_id INT,
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_favoris (client_id, coiffeur_id),
    FOREIGN KEY (client_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (coiffeur_id) REFERENCES profils_coiffeurs(id) ON DELETE CASCADE
);

-- =============================================
-- TABLE : messages (Chat client-coiffeur)
-- =============================================
CREATE TABLE messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    expediteur_id INT,
    destinataire_id INT,
    rendez_vous_id INT NULL,
    contenu TEXT NOT NULL,
    url_image VARCHAR(255),
    est_lu BOOLEAN DEFAULT FALSE,
    date_envoi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (expediteur_id) REFERENCES utilisateurs(id),
    FOREIGN KEY (destinataire_id) REFERENCES utilisateurs(id),
    FOREIGN KEY (rendez_vous_id) REFERENCES rendez_vous(id)
);

-- =============================================
-- TABLE : retraits (Retraits argent coiffeurs)
-- =============================================
CREATE TABLE retraits (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coiffeur_id INT,
    montant DECIMAL(8, 2) NOT NULL,
    methode_retrait ENUM('mobile_money', 'virement_bancaire'),
    numero_compte VARCHAR(100) COMMENT 'Numéro mobile ou IBAN',
    statut_retrait ENUM('en_attente', 'traite', 'echec') DEFAULT 'en_attente',
    date_demande TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_traitement TIMESTAMP NULL,
    FOREIGN KEY (coiffeur_id) REFERENCES profils_coiffeurs(id)
);

-- =============================================
-- INDEX pour optimiser les performances
-- =============================================

-- Index pour la recherche de coiffeurs
CREATE INDEX idx_coiffeurs_ville ON profils_coiffeurs(ville);
CREATE INDEX idx_coiffeurs_notes ON profils_coiffeurs(note_moyenne);
CREATE INDEX idx_coiffeurs_actifs ON profils_coiffeurs(est_actif);

-- Index pour les rendez-vous
CREATE INDEX idx_rdv_date ON rendez_vous(date_rdv);
CREATE INDEX idx_rdv_coiffeur_date ON rendez_vous(coiffeur_id, date_rdv);
CREATE INDEX idx_rdv_statut ON rendez_vous(statut);

-- Index pour la recherche de services
CREATE INDEX idx_services_categorie ON services(categorie);
CREATE INDEX idx_services_prix ON services(prix);
CREATE INDEX idx_services_actifs ON services(est_actif);

-- Index pour les disponibilités
CREATE INDEX idx_dispo_coiffeur_jour ON disponibilites(coiffeur_id, jour_semaine);

-- Index pour les paiements
CREATE INDEX idx_paiements_statut ON paiements(statut_paiement);
CREATE INDEX idx_paiements_date ON paiements(date_paiement);

-- =============================================
-- VUES UTILES (Pour les statistiques)
-- =============================================

-- Vue pour le dashboard coiffeur
CREATE VIEW vue_dashboard_coiffeur AS
SELECT 
    c.id as coiffeur_id,
    COUNT(DISTINCT r.id) as total_rendez_vous,
    COUNT(DISTINCT a.id) as total_avis,
    COALESCE(AVG(a.note), 0) as note_moyenne,
    COALESCE(SUM(p.montant_coiffeur), 0) as revenus_totaux
FROM profils_coiffeurs c
LEFT JOIN rendez_vous r ON c.id = r.coiffeur_id
LEFT JOIN avis a ON r.id = a.rendez_vous_id
LEFT JOIN paiements p ON r.id = p.rendez_vous_id
GROUP BY c.id;

-- =============================================
-- FIN DU SCRIPT
-- =============================================