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
    (chapter_id, comic_id, translator_id, chapter_num, chapter_nm, lang)  
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

