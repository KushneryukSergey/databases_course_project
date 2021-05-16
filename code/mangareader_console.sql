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
INSERT INTO mangareader.users
(user_id,
 user_nm,
 user_page_url)
VALUES (1001, 'spamer', 'mangareader.com/u/1001');
COPY mangareader.users
    (user_id, user_nm, user_avatar_url, user_page_url, register_dttm)
FROM '/home/skushneryuk/study/databases/project/data/inserts/mangareader_users.csv'
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
FROM '/home/skushneryuk/study/databases/project/data/inserts/mangareader_authors.csv'
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
FROM '/home/skushneryuk/study/databases/project/data/inserts/mangareader_translators.csv'
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
FROM '/home/skushneryuk/study/databases/project/data/inserts/mangareader_comics.csv'
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
FROM '/home/skushneryuk/study/databases/project/data/inserts/mangareader_chapters.csv'
DELIMITER ','
CSV HEADER;

-- inserts comments
INSERT INTO mangareader.comments
    (comment_id, comic_id, user_id, comment_txt)
VALUES (0, 0, 1, 'лутшая манга евер');
COPY mangareader.comments
    (comment_id, comic_id, user_id, comment_txt, comment_dttm)
FROM '/home/skushneryuk/study/databases/project/data/inserts/mangareader_comments.csv'
DELIMITER ','
CSV HEADER;

-- inserts favorites
INSERT INTO mangareader.favorites
    (user_id, comic_id)
VALUES (1, 0);
COPY mangareader.favorites
    (user_id, comic_id)
FROM '/home/skushneryuk/study/databases/project/data/inserts/mangareader_favorites.csv'
DELIMITER ','
CSV HEADER;

-- inserts comic_authors
INSERT INTO mangareader.comic_authors
(author_id, comic_id, working_tp)
VALUES (0, 0, 'art');
COPY mangareader.comic_authors
    (author_id, comic_id, working_tp)
FROM '/home/skushneryuk/study/databases/project/data/inserts/mangareader_comic_authors.csv'
DELIMITER ','
CSV HEADER;

-- inserts linked_comics
INSERT INTO mangareader.linked_comics
(comic_id1, comic_id2, relation_tp)
VALUES (1, 0, 'sequel');
COPY mangareader.linked_comics
    (comic_id1, comic_id2, relation_tp)
FROM '/home/skushneryuk/study/databases/project/data/inserts/mangareader_linked_comics.csv'
DELIMITER ','
CSV HEADER;

-- inserts pages_read
INSERT INTO mangareader.pages_read
(user_id, chapter_id, page_num, read_dttm)
VALUES (1, 0, 1, '10.05.2021 15:54:00');
COPY mangareader.pages_read
    (user_id, chapter_id, page_num, read_dttm)
FROM '/home/skushneryuk/study/databases/project/data/inserts/mangareader_pages_read.csv'
DELIMITER ','
CSV HEADER;


-------------------CRUD--------------------------
UPDATE mangareader.users
SET user_nm = '$UPERshoujoG1RL'
WHERE user_nm = 'shoujoG1RL';

SELECT * FROM mangareader.users;

DELETE FROM mangareader.users
WHERE user_nm = 'spamer';


-----------------------------Запросы к базе данных----------------------------
-- Todo данных пока мало, поэтому результативность этих запросов немного сложновато проверить
-- Готов добавить еще данных в ближайшее время для этого

-- 1. Найдем количестве актуальных глав на каждом языке и отсортируем, уберем те, на которым меньше 5 глав
-- Получим список популярных языков, отсортированный по количеству глав на нем

SELECT
       ch.lang AS language,
       count(ch.chapter_id) AS chapters
FROM mangareader.chapters ch
WHERE ch.valid_to_dttm = '01.01.5999 00:00:00'
GROUP BY ch.lang
HAVING count(*) >= 5
ORDER BY chapters DESC;


-- 2. Хотим узнать, что последнее сделали переводчики на сайте, т.е. какие последние главы перевели
-- Для каждого переводчика узнаем три последних актуальных переведенных главы

SELECT ordered_last_chapters.translator_nm,
       ordered_last_chapters.ch_order,
       ordered_last_chapters.chapter_nm,
       c.comic_nm,
       ordered_last_chapters.valid_from_dttm
FROM
    mangareader.comics c
INNER JOIN
(SELECT row_number() OVER (partition by tr.translator_id
                          order by last_chapters.valid_from_dttm DESC) AS ch_order,
       last_chapters.*,
       tr.translator_nm
FROM
    mangareader.translators tr
INNER JOIN (SELECT ch.comic_id,
                   ch.chapter_nm,
                   ch.translator_id,
                   ch.valid_from_dttm
FROM mangareader.chapters ch
WHERE ch.valid_to_dttm = '01.01.5999 00:00:00') AS last_chapters
    ON last_chapters.translator_id = tr.translator_id) AS ordered_last_chapters
ON ordered_last_chapters.comic_id = c.comic_id
WHERE ordered_last_chapters.ch_order <= 3;


-- 3. Хотим узнать что нового на сайте. Выведем последние 20 актуальных глав на сайте

SELECT ordered_chapters.ch_order,
       c.comic_nm,
       ordered_chapters.chapter_nm,
       ordered_chapters.valid_from_dttm
FROM
mangareader.comics c
INNER JOIN
(SELECT row_number() OVER (order by ch.valid_from_dttm DESC) AS ch_order,
        ch.comic_id,
        ch.chapter_nm,
        ch.valid_from_dttm
FROM mangareader.chapters ch
WHERE ch.valid_to_dttm = '01.01.5999 00:00:00') as ordered_chapters
ON c.comic_id = ordered_chapters.comic_id
WHERE ordered_chapters.ch_order <= 20
ORDER BY ordered_chapters.ch_order;


-- 4. Кто последний зарегистрировавшийся пользователь?
-- Выведем его никнейм и дату регистрации

SELECT * FROM
(SELECT row_number() OVER (order by u.register_dttm DESC) AS register_order,
        u.user_nm,
        u.register_dttm
FROM mangareader.users u) as ordered_users
WHERE ordered_users.register_order = 1;

-- 5. Какой был последний комментарий на сайте?
-- Выведем его автора, текст и к какому оно произведению


SELECT u.user_nm,
       comic_comment.comic_nm,
       comic_comment.comment_txt,
       comic_comment.comment_dttm
       FROM
    mangareader.users u
INNER JOIN
(SELECT * FROM
    mangareader.comics c
INNER JOIN
(SELECT row_number() OVER (order by com.comment_dttm DESC) AS comment_order,
        com.user_id,
        com.comment_txt,
        com.comment_dttm,
        com.comic_id
FROM mangareader.comments com) as ordered_comments
ON ordered_comments.comic_id = c.comic_id
WHERE ordered_comments.comment_order = 1) AS comic_comment
ON u.user_id = comic_comment.user_id;

---------------Добавляем индексы------------------------
CREATE INDEX ON mangareader.users(user_id);
CREATE INDEX ON mangareader.authors(author_id);
CREATE INDEX ON mangareader.translators(translator_id);
CREATE INDEX ON mangareader.comics(comic_id);
CREATE INDEX ON mangareader.comments(comment_id);
CREATE INDEX ON mangareader.chapters(chapter_id);

CREATE INDEX ON mangareader.favorites(comic_id, user_id);
CREATE INDEX ON mangareader.comic_authors(comic_id, author_id);
CREATE INDEX ON mangareader.linked_comics(comic_id1, comic_id2);
CREATE INDEX ON mangareader.pages_read(chapter_id, read_dttm, user_id, page_num);


---------------Добавляем представления------------------------
-- имеет смысл еще подумать над полями
DROP SCHEMA IF EXISTS mangareader_views CASCADE;
CREATE schema mangareader_views;

CREATE VIEW mangareader_views.users AS
SELECT u.user_nm, u.register_dttm, u.user_avatar_url
FROM mangareader.users AS u;

CREATE VIEW mangareader_views.authors AS
SELECT a.author_nm, a.author_avatar_url
FROM mangareader.authors AS a;

CREATE VIEW mangareader_views.translators AS
SELECT t.translator_nm, t.translator_avatar_url
FROM mangareader.translators AS t;

CREATE VIEW mangareader_views.comics AS
SELECT c.comic_nm, c.chapter_cnt, c.add_dttm
FROM mangareader.comics AS c;

CREATE VIEW mangareader_views.comments AS
SELECT com.comment_txt, com.comment_dttm
FROM mangareader.comments AS com;

CREATE VIEW mangareader_views.chapters AS
SELECT ch.chapter_nm, ch.chapter_num, ch.lang, ch.page_cnt, ch.valid_from_dttm
FROM mangareader.chapters AS ch;

CREATE VIEW mangareader_views.favorites AS
SELECT *
FROM mangareader.favorites AS fav;

CREATE VIEW mangareader_views.comic_authors AS
SELECT *
FROM mangareader.comic_authors AS ca;

CREATE VIEW mangareader_views.linked_comics AS
SELECT *
FROM mangareader.linked_comics AS lc;

CREATE VIEW mangareader_views.pages_read AS
SELECT *
FROM mangareader.pages_read AS pr;

-------------------Триггеры-----------------------
-- По идее, стоит их включить до insert-ов


-- Триггер на обновление старой главы.
-- Т.е. если мы добавили новую версию главы к произведению (с тем же
-- comic_id и chapter_num), то нужно у старой версии главы обновить
-- поле valid_to_dttm на наш valid_from_dttm

CREATE or replace function mangareader.update_chapter_valid_to_func() RETURNS TRIGGER AS
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

DROP TRIGGER IF EXISTS update_chapter_valid_to ON mangareader.chapters;
CREATE TRIGGER update_chapter_valid_to
    BEFORE INSERT
    ON mangareader.chapters
    FOR EACH ROW
EXECUTE PROCEDURE mangareader.update_chapter_valid_to_func();




-- Триггер на добавление поля приквел-сиквел связи:
-- если добавили информацию, что произведение1 - сиквел произведения2, то
-- нужно добавить обратную приквел-связь

CREATE or replace function mangareader.update_comic_links_func() RETURNS TRIGGER AS
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

DROP TRIGGER IF EXISTS update_links ON mangareader.linked_comics;
CREATE TRIGGER update_links
    BEFORE INSERT
    ON mangareader.linked_comics
    FOR EACH ROW
EXECUTE PROCEDURE mangareader.update_comic_links_func();


-----------------Сложные преставления----------------------

-- 1. join: users [равенство user_id] favorites [равенство comic_id] comics
-- для получения статистики по популярности тех или иных произведений, а так же активности пользователя

CREATE VIEW mangareader_views.comic_favorability AS
SELECT users.user_id,
       users.user_nm,
       users.register_dttm AS user_register_dttm,
       fav_n_comics.comic_id,
       fav_n_comics.comic_nm,
       fav_n_comics.chapter_cnt,
       fav_n_comics.add_dttm AS comic_add_dttm
FROM mangareader.users
INNER JOIN (
    SELECT c.comic_nm,
           c.chapter_cnt,
           c.comic_id,
           c.add_dttm,
           fav.user_id
    FROM mangareader.favorites fav
        INNER JOIN mangareader.comics c
            ON fav.comic_id = c.comic_id
) AS fav_n_comics ON users.user_id = fav_n_comics.user_id;

-- 2. join: users [равенство user_id] pages_read [равенство chapter_id] chapters
-- для получения статистики по популярности тех или иных произведений, насколько много их читают и т.д.

CREATE VIEW mangareader_views.comic_readability AS
SELECT read_chapters.*,
       users.user_nm,
       users.register_dttm AS user_register_dttm
FROM mangareader.users
INNER JOIN (
    SELECT c.chapter_id,
           c.comic_id,
           c.chapter_nm,
           c.chapter_num,
           c.translator_id,
           c.page_cnt,
           c.lang,
           pr.page_num,
           pr.read_dttm,
           pr.user_id
    FROM mangareader.pages_read pr
        INNER JOIN mangareader.chapters c
            ON pr.chapter_id = c.chapter_id
) AS read_chapters ON users.user_id = read_chapters.user_id;


-- 3. join: translators [равенство translator_id] chapters [равенство comic_id] comics
-- для получения информации о том, над какими проектами работают переводчики или какие
-- переводчики работают над конкретным произведением, каков их вклад

CREATE VIEW mangareader_views.translators_work AS
SELECT comic_chapters.*,
       translators.translator_nm
FROM mangareader.translators
INNER JOIN (
    SELECT c.comic_id,
           c.comic_nm,
           c.chapter_cnt,
           ch.chapter_id,
           ch.chapter_num,
           ch.chapter_nm,
           ch.page_cnt,
           ch.lang,
           ch.translator_id
    FROM mangareader.chapters ch
        INNER JOIN mangareader.comics c
            ON ch.comic_id = c.comic_id
) AS comic_chapters ON translators.translator_id = comic_chapters.translator_id;


---------------------------Процедуры (функции)------------------------------

-- 1. Получить статистику пользователя по количеству прочитанных страниц
-- за все время пребывания на сайте

CREATE OR REPLACE FUNCTION mangareader.count_all_user_read(arg_user_id integer) RETURNS integer AS
$$
DECLARE
    user_pages_read integer = (SELECT count(*)
                               FROM mangareader_views.comic_readability cr
                               WHERE arg_user_id = cr.user_id);
BEGIN
    RETURN user_pages_read;
END;
$$ LANGUAGE plpgsql;

SELECT (mangareader.count_all_user_read(1));


-- 2. Получить всех переводчиков, поработавших над переводом конкретного произведения
CREATE OR REPLACE FUNCTION mangareader.get_comic_translators(arg_comic_id integer)
RETURNS table (
    translator_id integer,
    translator_nm varchar(255)
)
AS $$
BEGIN
    RETURN QUERY SELECT
           tw.translator_id,
           tw.translator_nm
    FROM
         mangareader_views.translators_work tw
    WHERE arg_comic_id = tw.comic_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM mangareader.get_comic_translators(0);


-- 2.5) Вернуть id произведений автора
DROP FUNCTION IF EXISTS mangareader.get_author_works;
CREATE OR REPLACE FUNCTION mangareader.get_author_works(arg_author_id integer)
RETURNS table (comic_id integer,
               author_id integer)
AS $$
BEGIN
    RETURN QUERY SELECT ca.comic_id, ca.author_id
                 FROM mangareader.comic_authors ca
                 WHERE ca.author_id = arg_author_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM mangareader.get_author_works(0);

-- 3) Получить количество пользователей, которые любят определенного автора
-- (в их избранных находится не менее 50% процентов произведений этого автора)
CREATE OR REPLACE FUNCTION mangareader.count_comic_fans(arg_author_id integer)  RETURNS integer AS $$
DECLARE
    author_works_count integer = (SELECT count(*) FROM
                                  (SELECT * FROM mangareader.get_author_works(arg_author_id)) AS author_works);
    fans_count integer = (SELECT count(*) FROM
                          (SELECT DISTINCT fav.user_id
                           FROM (mangareader.favorites fav
                           INNER JOIN
                           (SELECT * FROM mangareader.get_author_works(arg_author_id)) AS author_works
                           ON fav.comic_id = author_works.comic_id)
                           GROUP BY fav.user_id
                           HAVING 2 * COUNT(fav.comic_id) >= author_works_count) AS fans);
BEGIN
    RETURN fans_count;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM mangareader.count_comic_fans(0);
