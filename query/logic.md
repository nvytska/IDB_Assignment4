# Пояснення бізнес-логіки та SQL запитів для системи відстеження стажувань

### 1. Аналітичний запит: Статистика заявок по статусах для кожного користувача

**Бізнес-потреба:** Розуміння ефективності кожного студента у пошуку стажування.

```sql
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
```

**Пояснення термінології:**
- **LEFT JOIN** - використовуємо щоб включити всіх користувачів, навіть тих що не мають заявок
- **GROUP BY** - групуємо по користувачу для агрегації його статистики
- **HAVING** - фільтруємо групи після GROUP BY (на відміну від WHERE що фільтрує до групування)
- **CASE WHEN** - умовна логіка для підрахунку статусів (conditional aggregation)
- **Aggregate functions** (COUNT, SUM) - функції агрегації для обчислення статистики

**Бізнес-ідея:** Дозволяє ідентифікувати найуспішніших студентів та тих, хто потребує підтримки.

### 2. Складний JOIN: Топ-5 компаній з найбільшою кількістю заявок

**Бізнес-потреба:** Аналіз популярності компаній та їхньої активності у найманні стажерів.

```sql
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
```

**Пояснення термінології:**
- **INNER JOIN** - тільки ті компанії, які мають і позиції, і заявки
- **COUNT(DISTINCT)** - підраховуємо унікальні значення (позиції не дублюються)
- **LIMIT** - обмеження кількості результатів

**Бізнес-ідея:** Показує найпопулярніші компанії та швидкість їхньої реакції на заявки.

### 3. Window Function: Ранжування студентів по активності

**Бізнес-потреба:** Створення рейтингу активності студентів в пошуку стажувань.

```sql
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


```

**Пояснення термінології:**
- **Window Functions** - функції що працюють з "вікном" даних навколо поточного рядка
- **OVER clause** - визначає вікно для window function
- **RANK()** - ранжування з пропусками (1,2,2,4...)
- **DENSE_RANK()** - ранжування без пропусків (1,2,2,3...)
- **PARTITION BY** - розділення даних на групи для окремого ранжування
- **LAG()** - доступ до значення з попереднього рядка

**Бізнес-ідея:** Мотивація студентів через створення здорової конкуренції.