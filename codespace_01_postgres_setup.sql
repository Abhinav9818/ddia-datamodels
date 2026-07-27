-- ============================================================
-- POSTGRES (RELATIONAL) — DDIA Ch.2 exercise
-- Paste this whole file into the Neon SQL editor and run it.
-- ============================================================

-- 1. SCHEMA
CREATE TABLE authors (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE
);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  author_id INT REFERENCES authors(id),
  title TEXT NOT NULL,
  body TEXT,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE tags (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE
);

CREATE TABLE post_tags (
  post_id INT REFERENCES posts(id),
  tag_id INT REFERENCES tags(id),
  PRIMARY KEY (post_id, tag_id)
);

CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  post_id INT REFERENCES posts(id),
  author_id INT REFERENCES authors(id),
  body TEXT,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE follows (
  follower_id INT REFERENCES authors(id),
  followee_id INT REFERENCES authors(id),
  PRIMARY KEY (follower_id, followee_id)
);

-- 2. SEED DATA
INSERT INTO authors (name, email) VALUES
  ('Alice', 'alice@example.com'),
  ('Bob',   'bob@example.com'),
  ('Carol', 'carol@example.com');

INSERT INTO follows (follower_id, followee_id) VALUES (1, 2); -- Alice follows Bob

INSERT INTO posts (author_id, title, body) VALUES
  (2, 'DDIA is great', 'Chapter 2 is about data models...'),
  (2, 'Understanding LSM trees', 'Log-structured merge trees are...');

INSERT INTO tags (name) VALUES ('databases'), ('distributed-systems');

INSERT INTO post_tags (post_id, tag_id) VALUES (1, 1), (1, 2), (2, 1);

INSERT INTO comments (post_id, author_id, body) VALUES
  (1, 1, 'Nice post!'),
  (1, 3, 'Agreed, very clear explanation.');

-- 3. QUERY A — fetch a post with author, tags, and comments (needs JOINs)
SELECT
  p.title,
  a.name AS author,
  ARRAY_AGG(DISTINCT t.name) AS tags,
  c.body AS comment,
  ca.name AS commenter
FROM posts p
JOIN authors a ON p.author_id = a.id
LEFT JOIN post_tags pt ON pt.post_id = p.id
LEFT JOIN tags t ON t.id = pt.tag_id
LEFT JOIN comments c ON c.post_id = p.id
LEFT JOIN authors ca ON c.author_id = ca.id
WHERE p.id = 1
GROUP BY p.title, a.name, c.body, ca.name;

-- 4. QUERY B — the "friends of friends" style query:
-- find everyone who commented on a post written by someone I follow
SELECT DISTINCT ca.name AS commenter
FROM follows f
JOIN posts p ON p.author_id = f.followee_id
JOIN comments c ON c.post_id = p.id
JOIN authors ca ON ca.id = c.author_id
WHERE f.follower_id = 1; -- Alice's id

-- Try extending this to "friends of friends of friends" (2 hops) and notice
-- how much messier the JOINs / recursive CTE gets compared to Neo4j.
