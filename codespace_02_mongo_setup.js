// ============================================================
// MONGODB (DOCUMENT) — DDIA Ch.2 exercise
// Paste this into mongosh (or the Atlas "mongosh" web shell)
// after connecting to your Atlas cluster.
// Run: use blog   first if mongosh doesn't default to a db.
// ============================================================

use blog;

// 1. AUTHORS — kept as separate documents (referenced, not embedded,
//    because many posts/comments point back to the same author and
//    we don't want to duplicate/update author info everywhere)
db.authors.insertMany([
  { _id: "a1", name: "Alice", email: "alice@example.com" },
  { _id: "a2", name: "Bob", email: "bob@example.com" },
  { _id: "a3", name: "Carol", email: "carol@example.com" }
]);

db.authors.updateOne(
  { _id: "a1" },
  { $set: { follows: ["a2"] } } // Alice follows Bob
);

// 2. POSTS — comments and tags EMBEDDED (read together with the post,
//    one-to-many, no need to look them up separately)
db.posts.insertMany([
  {
    _id: "p1",
    author_id: "a2",
    title: "DDIA is great",
    body: "Chapter 2 is about data models...",
    tags: ["databases", "distributed-systems"],
    comments: [
      { author_id: "a1", body: "Nice post!", created_at: new Date() },
      { author_id: "a3", body: "Agreed, very clear explanation.", created_at: new Date() }
    ],
    created_at: new Date()
  },
  {
    _id: "p2",
    author_id: "a2",
    title: "Understanding LSM trees",
    body: "Log-structured merge trees are...",
    tags: ["databases"],
    comments: [],
    created_at: new Date()
  }
]);

// 3. QUERY A — fetch a post with everything embedded: ONE query, no joins
db.posts.findOne({ _id: "p1" });

// 4. QUERY A-variant — but the author's name is NOT embedded, so to get
//    "post + author's actual name" you need $lookup (Mongo's join):
db.posts.aggregate([
  { $match: { _id: "p1" } },
  {
    $lookup: {
      from: "authors",
      localField: "author_id",
      foreignField: "_id",
      as: "author"
    }
  }
]);

// 5. QUERY B — the "friends of friends" style query:
// find everyone who commented on a post written by someone I follow.
// Notice this needs a $lookup + multiple stages + unwinding an embedded
// array — noticeably more awkward than the graph version, and would get
// much worse for a 2-hop version.
db.authors.aggregate([
  { $match: { _id: "a1" } },
  { $unwind: "$follows" },
  {
    $lookup: {
      from: "posts",
      localField: "follows",
      foreignField: "author_id",
      as: "posts"
    }
  },
  { $unwind: "$posts" },
  { $unwind: "$posts.comments" },
  {
    $lookup: {
      from: "authors",
      localField: "posts.comments.author_id",
      foreignField: "_id",
      as: "commenter"
    }
  },
  { $unwind: "$commenter" },
  { $project: { _id: 0, commenter: "$commenter.name" } }
]);

// 6. EXERCISE — try embedding the author's name directly into each post
// instead of referencing it, then update Bob's name in the authors
// collection. Notice it does NOT update inside posts.p1/p2 — that's the
// denormalization/update-anomaly tradeoff DDIA talks about in Ch.2.
