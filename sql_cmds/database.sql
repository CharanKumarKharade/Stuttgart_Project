-- DROP tables first (to reset cleanly for development)
DROP TABLE IF EXISTS VisitLog;
DROP TABLE IF EXISTS Wishlist;
DROP TABLE IF EXISTS Place;
DROP TABLE IF EXISTS categories;

-- categories
CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- places
CREATE TABLE IF NOT EXISTS Place (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    location TEXT,
    image TEXT,
    category_id INTEGER,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- wishlist
CREATE TABLE IF NOT EXISTS Wishlist (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    place_id INTEGER,
    visited BOOLEAN DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE,
    FOREIGN KEY (place_id) REFERENCES Place(id) ON DELETE CASCADE,
    UNIQUE (user_id, place_id)
);

-- visit log
CREATE TABLE IF NOT EXISTS VisitLog (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    place_id INTEGER,
    visited_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- insert into categories
INSERT OR IGNORE INTO categories (name, description) VALUES 
('Monument', 'Historical sites'), 
('Museum', 'Cultural institutions'), 
('Shopping Mall', 'Retail and entertainment');

-- insert into places
INSERT INTO Place (name, description, location, image, category_id) VALUES 
('TV Tower', 'A tall television tower.', 'Stuttgart East', 'tv_tower.jpg', 1),
('Mercedes-Benz Museum', 'Famous automobile museum.', 'Stuttgart Bad Cannstatt', 'mb_museum.jpg', 2);

-- insert into wishlist
INSERT OR IGNORE INTO Wishlist (user_id, place_id, visited) VALUES (1, 1, 0);

-- trigger: insert into VisitLog when a place is marked as visited
CREATE TRIGGER IF NOT EXISTS log_visited
AFTER UPDATE ON Wishlist
FOR EACH ROW
WHEN NEW.visited = 1 AND OLD.visited = 0
BEGIN
    INSERT INTO VisitLog (user_id, place_id, visited_at)
    VALUES (NEW.user_id, NEW.place_id, CURRENT_TIMESTAMP);
END;

-- view: user wishlist
CREATE VIEW IF NOT EXISTS UserWishlist AS
SELECT
    u.username,
    p.name AS place_name,
    w.visited
FROM Wishlist w
JOIN auth_user u ON w.user_id = u.id
JOIN Place p ON w.place_id = p.id;

-- TRANSACTIONS --

-- 1. View visited places
BEGIN;
SELECT u.username, p.name, w.visited
FROM Wishlist w
JOIN auth_user u ON w.user_id = u.id
JOIN Place p ON w.place_id = p.id
WHERE w.visited = 1;
COMMIT;

-- 2. Insert a new place
BEGIN;
INSERT INTO Place (name, description, location, image, category_id)
VALUES ('New Place', 'Description of new place', 'Downtown', 'new_place.jpg', 1);
COMMIT;

-- 3. Simulate a failed wishlist insert (duplicate)
BEGIN;
INSERT OR IGNORE INTO Wishlist (user_id, place_id, visited)
VALUES (1, 1, 0);
ROLLBACK;


-- Join query
SELECT
    u.username,
    p.name AS place_name,
    c.name AS category_name,
    w.visited
FROM Wishlist w     
JOIN auth_user u ON w.user_id = u.id
JOIN Place p ON w.place_id = p.id
JOIN categories c ON p.category_id = c.id
WHERE w.visited = 0
ORDER BY u.username, p.name;    


--  1 trigger and also a procedure