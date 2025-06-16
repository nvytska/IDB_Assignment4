# Пояснення бізнес-логіки та SQL запитів для системи відстеження стажувань

### 1. Аналітичний запит: Статистика заявок по статусах для кожного користувача

**Бізнес-потреба:** Розуміння ефективності кожного студента у пошуку стажування.

```sql
use internships_application_tracker;
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
use internships_application_tracker;
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
use internships_application_tracker;
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

### 4. Ролі користувачів та політики доступу

```sql
use internships_application_tracker;
create user if not exists 'admissions_officer'@'%' identified by '123456-officer';
grant select, insert on internships_application_tracker.* to 'admissions_officer'@'%';

create user if not exists 'database_manager'@'%' identified by '123456-db-manager';
grant all privileges on internships_application_tracker.* to 'database_manager'@'%';

create user if not exists 'intern'@'%' identified by '123456-intern';
grant select on internships_application_tracker.applications to 'intern'@'%';
```

### 5. Автоматичний тригер для нотатки при зміні статусу

```sql
use internships_application_tracker;
delimiter //
create trigger tr_auto_note_on_apl after update on applications
    for each row
    begin
        if new.status_id = 3 and old.status_id != 3 then
            insert into notes (application_id, creation_date, note_text)
            values (new.application_id, curdate(), concat('Auto note: Received offer! Date: ', curdate()));
        end if;
    end //
delimiter ;
```

**Ідея:**
- Якщо статус змінився на **Offered**, додаємо нотатку про це.


### 6. Процедура `get_student_progress_report`

```sql
use internships_application_tracker;
delimiter //
create procedure get_student_progress_report(in student_id int)
begin
    select
        u.full_name,
        u.email,
        u.university,
        count(a.application_id) as total_applications,
        max(a.application_date) as last_application_date
    from users u
             left join applications a on u.user_id = a.user_id
    where u.user_id = student_id
    group by u.user_id;

    select
        c.name as company,
        p.job_title,
        s.status,
        a.application_date,
        count(i.interview_id) as interview_count,
        count(n.note_id) as notes_count,
        IF(note_text is null,'No notes', note_text)
    from applications a
             inner join positions p on a.position_id = p.position_id
             inner join companies c on p.company_id = c.company_id
             inner join statuses s on a.status_id = s.status_id
             left join interviews i on a.application_id = i.application_id
             left join notes n on a.application_id = n.application_id
    where a.user_id = student_id
    group by a.application_id, a.application_date, note_text
    order by a.application_date desc;
end //
delimiter ;
```

**Ідея:**
- Виводить всю потрібну інтерну інформацію.

### 7. View: `company_hiring_efficiency`

```sql
use internships_application_tracker;
create view company_hiring_efficiency as
select
    c.name as company_name,
    c.industry,
    count(a.application_id) as total_applications,
    sum(case when s.status = 'Offered' then 1 else 0 end) as offers_made,
    ROUND((sum(case when s.status = 'Offered' then 1 else 0 end) * 100.0 / count(a.application_id)), 2) as offer_rate_percent,
    avg(i.interview_round) as avg_interview_rounds,
    count(DISTINCT cont.contact_id) as hr_contacts_available
from companies c
         left join positions p on c.company_id = p.company_id
         left join applications a on p.position_id = a.position_id
         left join statuses s on a.status_id = s.status_id
         left join interviews i on a.application_id = i.application_id
         left join contacts cont on c.company_id = cont.company_id
group by c.company_id, c.name, c.industry
having count(a.application_id) >= 3
order by offer_rate_percent desc;
```

**Бізнес-потреба**:
- Оцінити ефективність компаній у процесі найму, зрозуміти, наскільки активно вони приймають участь у програмі стажувань та як добре обробляють подані заявки.