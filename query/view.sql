use internships_application_tracker;

create view company_hiring_efficiency as
select
    c.name as company_name,
    c.industry,
    count(a.application_id) as total_applications,
    sum(case when s.status = 'Offered' then 1 else 0 end) as offers_made,
    ROUND(
            (sum(case when s.status = 'Offered' then 1 else 0 end) * 100.0 / count(a.application_id)), 2
    ) as offer_rate_percent,
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
