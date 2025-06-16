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

call get_student_progress_report(1);
