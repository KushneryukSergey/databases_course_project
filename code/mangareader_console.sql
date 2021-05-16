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
    chapter_cnt     integer     NOT NULL DEFAULT 0,
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
    translator_id   integer   DEFAULT NULL,  -- in case when language is original
    chapter_num     integer   NOT NULL,
    chapter_nm      text      NOT NULL,
    page_cnt        integer   NOT NULL DEFAULT 0,
    lang            language  NOT NULL,
    valid_from_dttm timestamp NOT NULL DEFAULT current_timestamp,
    valid_to_dttm   timestamp NOT NULL DEFAULT '01.01.5999 00:00:00',
    CONSTRAINT fk_comics FOREIGN KEY (comic_id) REFERENCES mangareader.comics (comic_id),
    CONSTRAINT fk_translators FOREIGN KEY (translator_id) REFERENCES mangareader.translators(translator_id)
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
    CONSTRAINT pk_comic_authors PRIMARY KEY (author_id, comic_id, working_tp),
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


-- Делаем insert-ы для всех таблиц
-- todo сделать функцию, которая позволит избавиться от копипаста

-- inserts users
INSERT INTO mangareader.users
(user_id,
 user_nm,
 user_page_url)
VALUES (0, 'admin', 'mangareader.com/u/0');
COPY mangareader.users
    (user_id, user_nm, user_avatar_url, user_page_url, register_dttm)
FROM '/home/skushneryuk/study/databases/project/inserts/mangareader_users.csv'
DELIMITER ','
CSV HEADER;


-- inserts authors
INSERT INTO mangareader.authors
(author_id,
 author_nm,
 author_page_url)
VALUES (0, 'Masashi Kishimoto', 'mangareader.com/a/0');
COPY mangareader.authors
    (author_id, author_nm, author_avatar_url, author_page_url)
FROM '/home/skushneryuk/study/databases/project/inserts/mangareader_authors.csv'
DELIMITER ','
CSV HEADER;


-- inserts translators
INSERT INTO mangareader.translators
(translator_id,
 translator_nm,
 translator_page_url)
VALUES (0, 'Narutoproject', 'mangareader.com/t/0');
COPY mangareader.translators
    (translator_id, translator_nm, translator_avatar_url, translator_page_url)
FROM '/home/skushneryuk/study/databases/project/inserts/mangareader_translators.csv'
DELIMITER ','
CSV HEADER;

-- inserts comics
INSERT INTO mangareader.comics
(comic_id,
 comic_nm,
 chapter_cnt,
 comic_page_url)
VALUES (0, 'Naruto', 1, 'mangareader.com/comic/naruto');
COPY mangareader.comics
    (comic_id, comic_nm, chapter_cnt, comic_page_url, add_dttm)
FROM '/home/skushneryuk/study/databases/project/inserts/mangareader_comics.csv'
DELIMITER ','
CSV HEADER;

-- inserts chapters
INSERT INTO mangareader.chapters
(chapter_id,
 comic_id,
 translator_id,
 chapter_num,
 chapter_nm,
 page_cnt,
 lang)
VALUES (0, 0, 0, 1, 'Глава 1', 20, 'ru');
COPY mangareader.chapters
    (chapter_id, comic_id, translator_id, chapter_num, chapter_nm, page_cnt, lang, valid_from_dttm, valid_to_dttm)
FROM '/home/skushneryuk/study/databases/project/inserts/mangareader_chapters.csv'
DELIMITER ','
CSV HEADER;

-- inserts comments
INSERT INTO mangareader.comments
    (comment_id, comic_id, user_id, comment_txt)
VALUES (0, 0, 1, 'лутшая манга евер');
COPY mangareader.comments
    (comment_id, comic_id, user_id, comment_txt, comment_dttm)
from '/home/skushneryuk/study/databases/project/inserts/mangareader_comments.csv'
DELIMITER ','
CSV HEADER;

-- inserts favorites
INSERT INTO mangareader.favorites
    (user_id, comic_id)
VALUES (1, 0);
COPY mangareader.favorites
    (user_id, comic_id)
from '/home/skushneryuk/study/databases/project/inserts/mangareader_favorites.csv'
DELIMITER ','
CSV HEADER;

-- inserts comic_authors
INSERT INTO mangareader.comic_authors
(author_id, comic_id, working_tp)
VALUES (0, 0, 'art');
COPY mangareader.comic_authors
    (author_id, comic_id, working_tp)
from '/home/skushneryuk/study/databases/project/inserts/mangareader_comic_authors.csv'
DELIMITER ','
CSV HEADER;

-- inserts linked_comics
INSERT INTO mangareader.linked_comics
(comic_id1, comic_id2, relation_tp)
VALUES (1, 0, 'sequel');
COPY mangareader.linked_comics
    (comic_id1, comic_id2, relation_tp)
from '/home/skushneryuk/study/databases/project/inserts/mangareader_linked_comics.csv'
DELIMITER ','
CSV HEADER;

-- inserts pages_read
INSERT INTO mangareader.pages_read
(user_id, chapter_id, page_num, read_dttm)
VALUES (1, 0, 1, '10.05.2021 15:54:00');
COPY mangareader.pages_read
    (user_id, chapter_id, page_num, read_dttm)
from '/home/skushneryuk/study/databases/project/inserts/mangareader_pages_read.csv'
DELIMITER ','
CSV HEADER;

---------------Добавляем индексы------------------------
create index on mangareader.users(user_id);
create index on mangareader.authors(author_id);
create index on mangareader.translators(translator_id);
create index on mangareader.comics(comic_id);
create index on mangareader.comments(comment_id);
create index on mangareader.chapters(chapter_id);

create index on mangareader.favorites(comic_id, user_id);
create index on mangareader.comic_authors(comic_id, author_id);
create index on mangareader.linked_comics(comic_id1, comic_id2);
create index on mangareader.pages_read(chapter_id, read_dttm, user_id, page_num);


---------------Добавляем представления------------------------
-- имеет смысл еще подумать над полями
create schema mangareader_views;

create view mangareader_views.users as
select *
from mangareader.users as u;

create view mangareader_views.authors as
select *
from mangareader.authors as u;

create view mangareader_views.translators as
select *
from mangareader.translators as u;

create view mangareader_views.comics as
select *
from mangareader.comics as u;

create view mangareader_views.comments as
select *
from mangareader.comments as u;

create view mangareader_views.chapters as
select *
from mangareader.chapters as u;

create view mangareader_views.favorites as
select *
from mangareader.favorites as u;

create view mangareader_views.comic_authors as
select *
from mangareader.comic_authors as u;

create view mangareader_views.linked_comics as
select *
from mangareader.linked_comics as u;

create view mangareader_views.pages_read as
select *
from mangareader.pages_read as u;

-------------------Триггеры-----------------------
-- По идее, стоит их включить до insert-ов


-- Триггер на обновление старой главы.
-- Т.е. если мы добавили новую версию главы к произведению (с тем же
-- comic_id и chapter_num), то нужно у старой версии главы обновить
-- поле valid_to_dttm на наш valid_from_dttm

create or replace function mangareader.update_chapter_valid_to_func() RETURNS TRIGGER AS
$$
BEGIN
    UPDATE mangareader.chapters
    SET valid_to_dttm = NEW.valid_from_dttm
    WHERE comic_id = NEW.comic_id and
          chapter_num = NEW.chapter_num and
          valid_to_dttm = NEW.valid_to_dttm;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_chapter_valid_to on mangareader.chapters;
CREATE TRIGGER update_chapter_valid_to
    BEFORE INSERT
    ON mangareader.chapters
    FOR EACH ROW
EXECUTE PROCEDURE mangareader.update_chapter_valid_to_func();




-- Триггер на добавление поля приквел-сиквел связи:
-- если добавили информацию, что произведение1 - сиквел произведения2, то
-- нужно добавить обратную приквел-связь

create or replace function mangareader.update_comic_links_func() RETURNS TRIGGER AS
$$
BEGIN
    IF (NEW.relation_tp = 'sequel') THEN
        INSERT INTO mangareader.linked_comics
            (comic_id1, comic_id2, relation_tp)
        VALUES (NEW.comic_id2, NEW.comic_id1, 'prequel');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_links on mangareader.linked_comics;
CREATE TRIGGER update_links
    BEFORE INSERT
    ON mangareader.linked_comics
    FOR EACH ROW
EXECUTE PROCEDURE mangareader.update_comic_links_func();


-----------------Сложные преставления----------------------
