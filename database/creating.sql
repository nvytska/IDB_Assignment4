create database internships_application_tracker;
use internships_application_tracker;

create table users(
user_id int primary key auto_increment,
full_name varchar(100) not null,
email varchar(100) not null unique,
university varchar(100)
);

create table companies(
company_id int primary key auto_increment,
name varchar(100) not null,
industry varchar(50),
location varchar(50)
);

create table positions(
position_id int primary key auto_increment,
company_id int, 
job_title varchar(50) not null,
description text,
foreign key (company_id) references companies(company_id)
on delete cascade);

create table statuses(
status_id int primary key auto_increment,
status varchar(50) not null
check (status in ('Applied', 'Interviewing', 'Offered', 'Rejected')));

create table applications(
application_id int primary key auto_increment,
user_id int not null,
position_id int not null,
application_date date not null,
status_id int,
foreign key (user_id) references users(user_id)
on delete cascade,
foreign key (position_id) references positions(position_id)
on delete cascade,
foreign key (status_id) references statuses(status_id)
on delete cascade);

create table contacts(
contact_id int primary key auto_increment,
company_id int not null, 
full_name varchar(100) not null,
email varchar(100) unique,
phone_number varchar(20) unique,
position varchar(50),
foreign key (company_id) references companies(company_id)
on delete cascade);

create table notes(
note_id int primary key auto_increment,
application_id int not null,
creation_date date,
note_text text,
foreign key (application_id) references applications(application_id)
on delete cascade);

create table interviews(
interview_id int primary key auto_increment,
application_id int not null,
interview_round int,
interview_date date,
feedback text,
constraint chk_interview check (interview_round > 0 and interview_round <= 5),
foreign key (application_id) references applications(application_id)
on delete cascade);
