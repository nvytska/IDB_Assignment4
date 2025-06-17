-- Database to track internship applications
create database internships_application_tracker;
use internships_application_tracker;


-- Users table stores basic information about applicants
create table users(
user_id int primary key auto_increment, -- Unique identifier for each user
full_name varchar(100) not null, -- Full name of the user
email varchar(100) not null unique, -- Email address (must be unique)
university varchar(100) -- University the user is attending 
);

-- Companies table stores details about companies offering internships
create table companies(
company_id int primary key auto_increment, -- Unique identifier for each company
name varchar(100) not null, -- Name of the company
industry varchar(50), -- Industry category the company operates in
location varchar(50) -- Location of the company
);

-- Positions table stores internship positions at companies
create table positions(
position_id int primary key auto_increment, -- Unique identifier for each position
company_id int, -- Reference to the company offering this position
job_title varchar(50) not null, -- Title of the internship position
description text, -- Detailed description of the position
foreign key (company_id) references companies(company_id) 
on delete cascade -- Foreign key to connect to the company
);

-- Statuses table defines possible application statuses
create table statuses(
status_id int primary key auto_increment, -- Unique identifier for each status
status varchar(50) not null
check (status in ('Applied', 'Interviewing', 'Offered', 'Rejected')) -- Only allow predefined statuses
);

-- Applications table tracks internship applications submitted by users
create table applications(
application_id int primary key auto_increment, -- Unique identifier for each application
user_id int not null, -- Reference to the applicant
position_id int not null, -- Reference to the applied position
application_date date not null, -- Date when the application was submitted
status_id int, -- Reference to the current status of the application
foreign key (user_id) references users(user_id)
on delete cascade,
foreign key (position_id) references positions(position_id)
on delete cascade, 
foreign key (status_id) references statuses(status_id)
on delete cascade 
);

-- Contacts table stores information about company representatives
create table contacts(
contact_id int primary key auto_increment, -- Unique identifier for each contact
company_id int not null, -- Reference to the company where the contact works
full_name varchar(100) not null, -- Full name of the contact person
email varchar(100) unique, -- Email address of the contact (must be unique)
phone_number varchar(20) unique, -- Phone number of the contact (must be unique)
position varchar(50), -- Job title of the contact person
foreign key (company_id) references companies(company_id)
on delete cascade 
);

-- Notes table allows users to record application-related notes
create table notes(
note_id int primary key auto_increment, -- Unique identifier for each note
application_id int not null, -- Reference to the application associated with this note
creation_date date, -- Date when the note was created
note_text text, -- The actual note content
foreign key (application_id) references applications(application_id)
on delete cascade 
);

-- Interviews table stores interview details for applications
create table interviews(
interview_id int primary key auto_increment, -- Unique identifier for each interview
application_id int not null, -- Reference to the associated application
interview_round int, -- The round number of the interview (must be between 1 and 5)
interview_date date, -- Date when the interview took place
feedback text, -- Feedback from the interview
constraint chk_interview check (interview_round > 0 and interview_round <= 5), -- Ensure valid round numbers
foreign key (application_id) references applications(application_id)
on delete cascade 
);


-- creating users

create user if not exists 'admissions_officer'@'%' identified by '123456-officer';
grant select, insert on internships_application_tracker.* to 'admissions_officer'@'%';


create user if not exists 'database_manager'@'%' identified by '123456-db-manager';
grant all privileges on internships_application_tracker.* to 'database_manager'@'%';


create user if not exists 'intern'@'%' identified by '123456-intern';
grant select on
    internships_application_tracker.applications to 'intern'@'%';


-- creating tigger

delimiter //
create trigger tr_auto_note_on_apl after update on applications
    for each row
    begin
        if new.status_id = 3 and old.status_id != 3 then
            insert into notes (application_id, creation_date, note_text)
                values (new.application_id,
                        curdate(),
                        concat('Auto note: Received offer! Date: ', curdate()));
        end if;
    end //
delimiter ;
