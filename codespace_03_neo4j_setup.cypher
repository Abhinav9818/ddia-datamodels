// ============================================================
// NEO4J (GRAPH) — DDIA Ch.2 exercise
// Paste this into the Neo4j Browser connected to your AuraDB
// instance and run it (Browser executes each statement in order).
// ============================================================

// 1. CREATE NODES AND RELATIONSHIPS
CREATE (alice:Author {name: "Alice", email: "alice@example.com"})
CREATE (bob:Author {name: "Bob", email: "bob@example.com"})
CREATE (carol:Author {name: "Carol", email: "carol@example.com"})

CREATE (p1:Post {title: "DDIA is great", body: "Chapter 2 is about data models..."})
CREATE (p2:Post {title: "Understanding LSM trees", body: "Log-structured merge trees are..."})

CREATE (t1:Tag {name: "databases"})
CREATE (t2:Tag {name: "distributed-systems"})

CREATE (c1:Comment {body: "Nice post!"})
CREATE (c2:Comment {body: "Agreed, very clear explanation."})

CREATE (alice)-[:FOLLOWS]->(bob)

CREATE (bob)-[:WROTE]->(p1)
CREATE (bob)-[:WROTE]->(p2)

CREATE (p1)-[:TAGGED]->(t1)
CREATE (p1)-[:TAGGED]->(t2)
CREATE (p2)-[:TAGGED]->(t1)

CREATE (c1)-[:ON]->(p1)
CREATE (c2)-[:ON]->(p1)
CREATE (alice)-[:WROTE]->(c1)
CREATE (carol)-[:WROTE]->(c2);

// 2. QUERY A — fetch a post with author, tags, and comments
// (a single pattern-match traversal, no "joins" as such)
MATCH (a:Author)-[:WROTE]->(p:Post {title: "DDIA is great"})
OPTIONAL MATCH (p)-[:TAGGED]->(t:Tag)
OPTIONAL MATCH (c:Comment)-[:ON]->(p)
OPTIONAL MATCH (ca:Author)-[:WROTE]->(c)
RETURN p.title, a.name AS author, collect(DISTINCT t.name) AS tags,
       collect(DISTINCT {comment: c.body, commenter: ca.name}) AS comments;

// 3. QUERY B — the "friends of friends" style query:
// find everyone who commented on a post written by someone I follow.
// This is the query graph databases are built for — compare its
// simplicity here to the SQL JOINs and Mongo $lookup/$unwind versions.
MATCH (me:Author {name: "Alice"})-[:FOLLOWS]->(friend)-[:WROTE]->(post)<-[:ON]-(comment)<-[:WROTE]-(commenter)
RETURN DISTINCT commenter.name;

// 4. EXERCISE — extend Query B to 2 hops (friends of friends) by just
// adding another [:FOLLOWS] hop in the pattern:
// MATCH (me:Author {name:"Alice"})-[:FOLLOWS*1..2]->(friend)-[:WROTE]->(post)<-[:ON]-(comment)<-[:WROTE]-(commenter)
// Notice how trivial this change is here vs. the recursive CTE you'd
// need in Postgres or the extra aggregation stages in Mongo.
