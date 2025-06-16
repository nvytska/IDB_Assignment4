USE internships_application_tracker;

ALTER TABLE users COMMENT = 'Таблиця користувачів системи - студенти які подають на стажування';
ALTER TABLE companies COMMENT = 'Компаній які пропонують стажування';
ALTER TABLE positions COMMENT = 'Позиції для стажування в компаніях';
ALTER TABLE statuses COMMENT = 'Статуси заявок (Applied, Interviewing, Offered, Rejected)';
ALTER TABLE applications COMMENT = 'Таблиця заявок студентів на стажування';
ALTER TABLE contacts COMMENT = 'Контактні особи в компаніях (HR, менеджери)';
ALTER TABLE notes COMMENT = 'Нотатки студентів';
ALTER TABLE interviews COMMENT = 'Інформація про співбесіди (дати, раунди, відгуки)';

ALTER TABLE users MODIFY COLUMN user_id INT AUTO_INCREMENT COMMENT 'Унікальний ідентифікатор користувача';
ALTER TABLE users MODIFY COLUMN email VARCHAR(100) NOT NULL UNIQUE COMMENT 'Унікальна електронна пошта користувача';
ALTER TABLE applications MODIFY COLUMN application_date DATE NOT NULL COMMENT 'Дата подачі заявки';
ALTER TABLE interviews MODIFY COLUMN interview_round INT COMMENT 'Номер раунду співбесіди (1-5)';
