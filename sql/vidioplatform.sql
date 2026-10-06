-- Аккаунты
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    registered_at TIMESTAMP NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%')
);

-- Каналы
CREATE TABLE channels (
    channel_id SERIAL PRIMARY KEY,
    account_id INT NOT NULL REFERENCES accounts(account_id) ON DELETE CASCADE,
    name_channel VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    avatar_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_channel_name_len CHECK (char_length(name_channel) >= 3)
);

CREATE INDEX idx_channel_account ON channels(account_id);

-- Настройки канала
CREATE TABLE channel_settings (
	channel_id INT PRIMARY KEY REFERENCES channels(channel_id) ON DELETE CASCADE,
	is_monetizeted BOOLEAN NOT NULL DEFAULT FALSE,
	comments_eneble BOOLEAN NOT NULL DEFAULT TRUE,
	country_code CHAR(2),
	updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Видео
CREATE TABLE videos (
	video_id SERIAL PRIMARY KEY,
	channel_id INT NOT NULL REFERENCES channels(channel_id) ON DELETE CASCADE,
	title VARCHAR(200) NOT NULL,
	description TEXT,
	duration_sec INT NOT NULL,
	views_count BIGINT NOT NULL DEFAULT 0,
	published_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT chk_duration CHECK (duration_sec > 0),
    CONSTRAINT chk_views CHECK (views_count >= 0)
);

CREATE INDEX idx_videos_channel ON videos(channel_id);

-- Подписки
CREATE TABLE subscriptions (
    subscriber_channel_id INT NOT NULL REFERENCES channels(channel_id) ON DELETE CASCADE,
    target_channel_id     INT NOT NULL REFERENCES channels(channel_id) ON DELETE CASCADE,
    subscribed_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (subscriber_channel_id, target_channel_id),
    CONSTRAINT chk_no_self_subscription CHECK (subscriber_channel_id <> target_channel_id)
);

-- Комментарии
CREATE TABLE comments (
    comment_id SERIAL PRIMARY KEY,
    video_id INT NOT NULL REFERENCES videos(video_id) ON DELETE CASCADE,
    channel_id INT NOT NULL REFERENCES channels(channel_id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_comment_not_empty CHECK (char_length(trim(content)) > 0)
);

CREATE INDEX idx_comments_video ON comments(video_id);

-- Лайки 
CREATE TABLE likes (
    channel_id INT NOT NULL REFERENCES channels(channel_id) ON DELETE CASCADE,
    video_id INT NOT NULL REFERENCES videos(video_id) ON DELETE CASCADE,
    liked_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (channel_id, video_id)
);

CREATE OR REPLACE FUNCTION prevent_last_channel_deletion()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM channels WHERE account_id = OLD.account_id) <= 1 THEN
        RAISE EXCEPTION 'Нельзя удалить последний канал аккаунта %', OLD.account_id;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_last_channel
BEFORE DELETE ON channels
FOR EACH ROW EXECUTE FUNCTION prevent_last_channel_deletion();

INSERT INTO accounts (email, password_hash) VALUES
('alice@mail.com', 'hash1'),
('bob@mail.com', 'hash2'),
('carol@mail.com', 'hash3');

INSERT INTO channels (account_id, name_channel, description) VALUES
(1, 'Alice Tech','Технологии'),
(1, 'Alice Vlog', 'Влоги'),
(2, 'Bob Games', 'Игры'),
(3, 'Carol Music', 'Музыка');

INSERT INTO channel_settings (channel_id, is_monetizeted, country_code) VALUES
(1, TRUE,'RU'),
(2, FALSE, 'RU'),
(3, TRUE, 'US'),
(4, FALSE, 'KZ');

INSERT INTO videos (channel_id, title, duration_sec) VALUES
(1, 'PostgreSQL за 10 минут', 600),
(1, 'Python с нуля', 1200),
(3, 'Обзор новой игры', 900),
(4, 'Как писать музыку', 480);

INSERT INTO subscriptions (subscriber_channel_id, target_channel_id) VALUES
(2, 1), (3, 1), (4, 1), (1, 4);

INSERT INTO comments (video_id, channel_id, content) VALUES
(1, 3, 'Отличное видео!'),
(1, 4, 'Спасибо, помогло'),
(3, 1, 'Крутая игра');

INSERT INTO likes (channel_id, video_id) VALUES
(1, 4), (2, 1), (3, 1), (4, 1), (2, 3);
