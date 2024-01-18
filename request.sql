/*
 * Section 1 - Configuration de la base de données
 */

/*
 * Question 1
 */
CREATE DATABASE IF NOT EXISTS GestionMagasin;

/*
 * Question 2
 */
CREATE TABLE Produits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50),
    prix FLOAT,
    quantiteStock INT,
    datePeremption DATE
);

/*
 * Question 3
 */
INSERT INTO Produits (nom, prix, quantiteStock, datePeremption) VALUES
('produit1', 19.99, 50, '2024-12-31'),
('produit2', 59.99, 42, '2024-03-26'),
('produit3', 9.99, 11, '2024-08-11');

/*
 * Question 4
 */
CREATE TABLE Commandes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_produit INT,
    quantiteCommandee INT,
    dateCommande DATE,
    FOREIGN KEY (id_produit) REFERENCES Produits(id)
);

/*
 * Section 2 - Requêtes SQL
 */

/* 
 * Question 5
 */
SELECT nom, prix, quantiteStock
FROM Produits
WHERE prix > 50.00;

/* 
 * Question 6
 */
UPDATE Produits
SET prix = prix * 0.9
WHERE id = 1;

/* 
 * Question 7
 */
SELECT 
    p.id AS id_produit, 
    p.nom AS nom_produit, 
    SUM(c.quantiteCommandee) AS quantite_totale_commandee
FROM Produits p
INNER JOIN Commandes c
ON p.id = c.id_produit
GROUP BY p.id, p.nom;

/* 
 * Question 8
 */
SELECT *
FROM Produits
WHERE quantiteStock < (
    SELECT AVG(quantiteStock) FROM Produits
);

/* 
 * Section 3 - Procédures Stockées
 */

/* 
 * Question 9
 */
DELIMITER //
CREATE PROCEDURE AjusterQuantiteNegative(
    IN produit_id INT
)
BEGIN
    DECLARE nouvelle_quantite INT;

    SELECT quantiteStock INTO nouvelle_quantite
    FROM Produits
    WHERE id = produit_id;

    IF nouvelle_quantite < 0 THEN
        UPDATE Produits
        SET quantiteStock = 0
        WHERE id = produit_id;
    END IF;
END //

/* 
 * Question 10 
 */
DELIMITER //
CREATE PROCEDURE AppliquerRemise(
    INOUT montant_total DECIMAL(10, 2)
)
BEGIN
    IF montant_total > 1000 THEN
        SET montant_total = montant_total - (montant_total * 0.05);
    END IF;
END //

/*
 * Question 11
 */
DELIMITER //
CREATE PROCEDURE SupprimerProduitsPerimes()
BEGIN
    DELETE FROM Produits
    WHERE datePeremption < CURDATE();
END //

/* 
 * Section 4 - Triggers
 */

/* 
 * Question 12
 */
DELIMITER //
CREATE TRIGGER before_update_produit
BEFORE UPDATE ON Produits 
FOR EACH ROW 
BEGIN
    IF NEW.quantiteStock < 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La quantité en stock est inférieure à 1O.';
    END IF;
END //

/*
 * Question 13
 */
DELIMITER //
CREATE TRIGGER after_insert_commande
AFTER INSERT ON Commandes
FOR EACH ROW
BEGIN
    UPDATE Produits
    SET quantiteStock = quantiteStock - NEW.quantiteCommandee
    WHERE id = NEW.id_produit;
END //

/* 
 * Question 14
 */
DELIMITER //
CREATE TRIGGER before_delete_produit
BEFORE DELETE ON Produits
FOR EACH ROW
BEGIN 
    IF OLD.quantiteStock > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossible de supprimer le produit, la quantité en stock est supérieure à 0.';
    END IF;
END //

/* 
 * Section 5 - Gestion des rôles utilisateurs
 */

/* 
 * Question 15
 */
CREATE USER 'MagasinAdmin'@'localhost' IDENTIFIED BY 'StrongPassword1234?';

/*
 * Question 16
 */
GRANT ALL PRIVILEGES ON GestionMagasin.Produits TO 'MagasinAdmin'@'localhost';
FLUSH PRIVILEGES;

/* 
 * Question 17
 */ 
DROP USER 'MagasinAdmin'@'localhost';

/*
 * Section 6 - Sauvegarde de la base de données
 */

/* 
 * Question 18
 */
