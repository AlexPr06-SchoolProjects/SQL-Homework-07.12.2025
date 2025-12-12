-- Query 1

WITH 
	-- CTE #1
	id_per_albums AS (
	SELECT 
		a.user_id,
		COUNT(*) AS albums_count
	FROM albums a
	GROUP BY a.user_id
	),

	-- CTE #2
	has_max_alboms AS (
		SELECT
			MAX(albums_count) AS max_album_count
		FROM id_per_albums
	)

SELECT 
u.nickname AS [user_nickname],
ipa.albums_count AS [albums_count]
FROM users u
INNER JOIN id_per_albums ipa ON u.id = ipa.user_id
INNER JOIN has_max_alboms hma ON hma.max_album_count = ipa.albums_count;


-- Query 2
	-- Option 1 - might be faster
	SELECT
		u.id			AS [user_id],
		u.nickname		AS [user_nickname]
	FROM users u
	LEFT JOIN albums a ON u.id = a.user_id
	WHERE a.user_id IS NULL;

	-- Option 2  - might be slower
	SELECT 
		u.id			AS [user_id],
		u.nickname		AS [user_nickname]
	FROM users u
	WHERE NOT EXISTS (
		SELECT a.user_id
		FROM albums a
		WHERE a.user_id = u.id -- dependent subquery (will be made every single time)
	);


-- Query 3 
SELECT 
	a.id		AS [albom_id],
	a.title		AS [albom_title],
	a.rate		AS [albom_rate]
FROM albums a 
WHERE a.rate > (
	SELECT 
		AVG(ISNULL(sub_a.rate, 0))
	FROM albums sub_a
);  -- as we discussed during our last lesson, SQL Server 
	-- will optimise this subquery so that it will be made only once. (Independent subquery)


-- Query 4 

-- 4. Ќайти пользователей, у которых есть альбомы, не содержащие ни одного изображени€.
-- | id | nickname | empty_albums |  - наверное опечатка, так как таблицы dbo.alboms и dbo.users
-- не св€заны с dbo.images. ќднако если бы были, то вот как бы € это реализовал:
--SELECT *
--FROM users u 
--INNER JOIN albums a ON u.id = a.user_id
--INNER JOIN images i ON a.image_id = i.id
--WHERE a.image_id IS NULL; - ну или что-то подобное

-- Query 5
--5. ƒл€ каждого альбома вывести самое свежее изображение (по дате публикации).
--| alb_title| img_title | max_publish_date |
-- ќп€ть таки, таблицы dbo.alboms и dbo.users
-- не св€заны с dbo.images. Ќо вот как € это реализовал бы
--SELECT *
--FROM albums a
--LEFT JOIN images i ON a.image_id = i.id
--WHERE i.publish_date = (
--	SELECT 
--		MAX(i2.publish_date)
--	FROM images i2
--	WHERE i2.album_id = a.id
--);  - что-то в таком духе. Ќа самом деле, т€жело предпологать правильную реализацию, ибо если один альбом
	--  может одновременно иметь несколько картинок(их ссылки или айдишники), то это нужно хранить в какой то структуре
	--  (первое, что приходит в голову - json. — технической точки зрени€ могу ошибатьс€, поскольку не знаю все возможные
	--   варианты и, возможно, json - не сама€ лучша€ иде€.) - но это уже, что называетс€, экстропол€ци€ (extrapolation).

