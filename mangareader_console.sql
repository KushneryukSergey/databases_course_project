DROP SCHEMA IF EXISTS mangareader CASCADE;
CREATE SCHEMA mangareader;

DROP TABLE IF EXISTS mangareader.users;
CREATE TABLE mangareader.users
(
    user_id         integer      NOT NULL UNIQUE PRIMARY KEY,
    user_nm         varchar(255) NOT NULL,
    user_avatar_url text                  DEFAULT 'https://i.stack.imgur.com/34AD2.jpg',
    user_page_url   text         NOT NULL,
    register_dttm   timestamp    NOT NULL DEFAULT current_timestamp
);

DROP TABLE IF EXISTS mangareader.authors;
CREATE TABLE mangareader.authors
(
    author_id         integer      NOT NULL UNIQUE PRIMARY KEY,
    author_nm         varchar(255) NOT NULL,
    author_avatar_url text DEFAULT 'https://i.stack.imgur.com/34AD2.jpg',
    author_page_url   text
);

DROP TABLE IF EXISTS mangareader.translators;
CREATE TABLE mangareader.translators
(
    translator_id         integer      NOT NULL UNIQUE PRIMARY KEY,
    translator_nm         varchar(255) NOT NULL,
    translator_avatar_url text DEFAULT 'https://i.stack.imgur.com/34AD2.jpg',
    translator_page_url   text
);

DROP TABLE IF EXISTS mangareader.comics;
CREATE TABLE mangareader.comics
(
    comic_id       integer      NOT NULL UNIQUE PRIMARY KEY,
    comic_nm       varchar(255) NOT NULL,
    chapter_cnt    integer      NOT NULL DEFAULT 0,
    comic_page_url text         NOT NULL,
    add_dttm       timestamp    NOT NULL DEFAULT current_timestamp
);

DROP TYPE IF EXISTS language;
CREATE TYPE language AS ENUM ('ru', 'en', 'jp');
DROP TABLE IF EXISTS mangareader.chapters;
CREATE TABLE mangareader.chapters
(
    chapter_id      integer   NOT NULL UNIQUE PRIMARY KEY,
    comic_id        integer   NOT NULL,
    translator_id   integer            DEFAULT NULL, -- in case when language is original
    chapter_num     integer   NOT NULL,
    chapter_nm      text      NOT NULL,
    page_cnt        integer   NOT NULL DEFAULT 0,
    lang            language  NOT NULL,
    valid_from_dttm timestamp NOT NULL DEFAULT current_timestamp,
    valid_to_dttm   timestamp NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_comics FOREIGN KEY (comic_id) REFERENCES mangareader.comics (comic_id),
    CONSTRAINT fk_translators FOREIGN KEY (translator_id) REFERENCES mangareader.translators (translator_id)
);

DROP TABLE IF EXISTS mangareader.comments;
CREATE TABLE mangareader.comments
(
    comment_id   integer   NOT NULL UNIQUE PRIMARY KEY,
    comic_id     integer   NOT NULL,
    user_id      integer   NOT NULL,
    comment_txt  text      NOT NULL,
    comment_dttm timestamp NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_comics FOREIGN KEY (comic_id) REFERENCES mangareader.comics (comic_id),
    CONSTRAINT fk_users FOREIGN KEY (user_id) REFERENCES mangareader.users (user_id)
);

DROP TABLE IF EXISTS mangareader.favorites;
CREATE TABLE mangareader.favorites
(
    user_id  integer NOT NULL,
    comic_id integer NOT NULL,
    CONSTRAINT pk_favorites PRIMARY KEY (user_id, comic_id),
    CONSTRAINT fk_comics FOREIGN KEY (comic_id) REFERENCES mangareader.comics (comic_id),
    CONSTRAINT fk_users FOREIGN KEY (user_id) REFERENCES mangareader.users (user_id)
);

DROP TYPE IF EXISTS work_type;
CREATE TYPE work_type AS ENUM ('art', 'script');
DROP TABLE IF EXISTS mangareader.comic_authors;
CREATE TABLE mangareader.comic_authors
(
    author_id  integer   NOT NULL,
    comic_id   integer   NOT NULL,
    working_tp work_type NOT NULL,
    CONSTRAINT pk_comic_authors PRIMARY KEY (author_id, comic_id),
    CONSTRAINT fk_authors FOREIGN KEY (author_id) REFERENCES mangareader.authors (author_id),
    CONSTRAINT fk_comics FOREIGN KEY (comic_id) REFERENCES mangareader.comics (comic_id)
);

DROP TYPE IF EXISTS relation;
CREATE TYPE relation AS ENUM (
    'prequel',
    'sequel',
    'spinoff',
    'side_story',
    'crossover'
    );
DROP TABLE IF EXISTS mangareader.linked_comics;
CREATE TABLE mangareader.linked_comics
(
    comic_id1   integer  NOT NULL,
    comic_id2   integer  NOT NULL,
    relation_tp relation NOT NULL,
    CONSTRAINT pk_linked_comics PRIMARY KEY (comic_id1, comic_id2),
    CONSTRAINT fk_comics1 FOREIGN KEY (comic_id1) REFERENCES mangareader.comics (comic_id),
    CONSTRAINT fk_comics2 FOREIGN KEY (comic_id2) REFERENCES mangareader.comics (comic_id)
);

DROP TABLE IF EXISTS mangareader.pages_read;
CREATE TABLE mangareader.pages_read
(
    user_id    integer   NOT NULL,
    chapter_id integer   NOT NULL,
    page_num   integer   NOT NULL,
    read_dttm  timestamp NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_pages_read PRIMARY KEY (user_id, chapter_id, page_num, read_dttm),
    CONSTRAINT fk_users FOREIGN KEY (user_id) REFERENCES mangareader.users (user_id),
    CONSTRAINT fk_chapters FOREIGN KEY (chapter_id) REFERENCES mangareader.chapters (chapter_id)
);