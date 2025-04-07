
CREATE DATABASE social_media_db1;

CREATE SCHEMA IF NOT EXISTS social_media1;


CREATE TABLE IF NOT EXISTS social_media1.user (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(75) UNIQUE NOT NULL,
    password VARCHAR(300) NOT NULL,
    name VARCHAR(75) NOT NULL,
    surname VARCHAR(75) NOT NULL,
    age INT CHECK (age >= 0),
    email VARCHAR(150) UNIQUE NOT NULL,
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    city VARCHAR(170),
    country VARCHAR(50),
    date_of_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL
);


CREATE TABLE IF NOT EXISTS social_media1.post (
    post_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES social_media1.user(user_id) ON DELETE CASCADE,
    post_content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL
);


CREATE TABLE IF NOT EXISTS social_media1.reaction (
    reaction_id SERIAL PRIMARY KEY,
    post_id INT REFERENCES social_media1.post(post_id) ON DELETE CASCADE,
    user_id INT REFERENCES social_media1.user(user_id) ON DELETE CASCADE,
    reaction_type VARCHAR(50) CHECK (reaction_type IN ('like', 'dislike', 'love')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL
);


CREATE TABLE IF NOT EXISTS social_media1.friendship (
    friendship_id SERIAL PRIMARY KEY,
    user1_id INT REFERENCES social_media1.user(user_id) ON DELETE CASCADE,
    user2_id INT REFERENCES social_media1.user(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL,
    UNIQUE (user1_id, user2_id)
);


CREATE TABLE IF NOT EXISTS social_media1.comment (
    comment_id SERIAL PRIMARY KEY,
    post_id INT REFERENCES social_media1.post(post_id) ON DELETE CASCADE,
    user_id INT REFERENCES social_media1.user(user_id) ON DELETE CASCADE,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL
);


CREATE TABLE IF NOT EXISTS social_media1.media (
    media_id SERIAL PRIMARY KEY,
    post_id INT REFERENCES social_media1.post(post_id) ON DELETE CASCADE,
    media_url VARCHAR(255) NOT NULL,
    media_type VARCHAR(50) CHECK (media_type IN ('image', 'video', 'audio')),
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS social_media1.hashtag (
    hashtag_id SERIAL PRIMARY KEY,
    hashtag_name VARCHAR(50) UNIQUE NOT NULL,
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL
);


CREATE TABLE IF NOT EXISTS social_media1.group (
    group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(100) NOT NULL,
    created_by INT REFERENCES social_media1.user(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS social_media1.group_member (
    group_member_id SERIAL PRIMARY KEY,
    group_id INT REFERENCES social_media1.group(group_id) ON DELETE CASCADE,
    user_id INT REFERENCES social_media1.user(user_id) ON DELETE CASCADE,
    role VARCHAR(50) CHECK (role IN ('admin', 'member')),
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL,
    UNIQUE (group_id, user_id)
);


CREATE TABLE IF NOT EXISTS social_media1.saved_post (
    saved_post_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES social_media1.user(user_id) ON DELETE CASCADE,
    post_id INT REFERENCES social_media1.post(post_id) ON DELETE CASCADE,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL
);


CREATE TABLE IF NOT EXISTS social_media1.user_report (
    report_id SERIAL PRIMARY KEY,
    reported_by INT REFERENCES social_media1.user(user_id) ON DELETE CASCADE,
    reported_post INT REFERENCES social_media1.post(post_id) ON DELETE CASCADE,
    report_reason VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL
);


CREATE TABLE IF NOT EXISTS social_media1.user_relationship (
    relationship_id SERIAL PRIMARY KEY,
    user1_id INT REFERENCES social_media1.user(user_id) ON DELETE CASCADE,
    user2_id INT REFERENCES social_media1.user(user_id) ON DELETE CASCADE,
    relationship_type VARCHAR(50) CHECK (relationship_type IN ('friend', 'follower')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts DATE DEFAULT CURRENT_DATE NOT NULL,
    UNIQUE (user1_id, user2_id)
);
