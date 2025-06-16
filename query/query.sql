use internships_application_tracker;

-- Аналіз заявок по статусах для кожного користувача
SELECT
    u.full_name AS fullname,
    u.university AS university,
    COUNT(a.application_id) AS cnt_applications,
    SUM(CASE WHEN s.status = 'Applied' THEN 1 ELSE 0 END) AS Applied,
    SUM(CASE WHEN s.status = 'Interviewing' THEN 1 ELSE 0 END) AS Interviewing,
    SUM(CASE WHEN s.status = 'Offered' THEN 1 ELSE 0 END) AS Offered,
    SUM(CASE WHEN s.status = 'Rejected' THEN 1 ELSE 0 END) AS Rejected
FROM users u
    LEFT JOIN applications a ON u.user_id = a.user_id
    LEFT JOIN statuses s ON a.status_id = s.status_id
GROUP BY u.user_id, u.full_name, u.university
HAVING COUNT(a.application_id) > 0
ORDER BY cnt_applications DESC;

-- Аналіз топ-5 компаній найбільшою кількістю заявок та середнім часом відповіді
SELECT
    c.name AS Company,
    c.industry,
    c.location,
    COUNT(DISTINCT p.position_id) AS Positions,
    COUNT(a.application_id) AS cnt_applications
FROM companies c
    JOIN positions p ON c.company_id = p.company_id
    JOIN applications a ON p.position_id = a.position_id
GROUP BY c.company_id, c.name, c.industry, c.location
ORDER BY COUNT(a.application_id) DESC, c.name
LIMIT 5;

-- Ранжування студентів по активності подачі заявок
SELECT
    u.full_name AS student_name,
    u.university,
    COUNT(a.application_id) AS cnt_applications,
    RANK() OVER (ORDER BY COUNT(a.application_id) DESC) AS activity_rank,
    DENSE_RANK() OVER (PARTITION BY u.university ORDER BY COUNT(a.application_id) DESC) AS University_rank,
    LAG(COUNT(a.application_id)) OVER (ORDER BY COUNT(a.application_id) DESC) AS Previous_student
FROM users u
         LEFT JOIN applications a ON u.user_id = a.user_id
GROUP BY u.user_id, u.full_name, u.university
HAVING COUNT(a.application_id) > 0
ORDER BY COUNT(a.application_id) DESC;

