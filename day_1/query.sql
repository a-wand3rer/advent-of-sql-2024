with kid_wishes as (select c.name,
                           w.list_id,
                           c.child_id,
                           w.child_id,
                           w.submitted_date,
                           w.wishes ->> 'first_choice'             as primary_wish,
                           w.wishes ->> 'second_choice'            as backup_wish,
                           w.wishes -> 'colors' ->> 0              as favourite_color,
                           json_array_length(w.wishes -> 'colors') as color_count,
                           row_number() over (partition by c.name order by submitted_date desc) as rn
                    from children c
                             join wish_lists w on c.child_id = w.child_id
)
select
    kw.*,
--     kw.name as kid_name,
--        kw.primary_wish,
--        kw.backup_wish,
--        kw.favourite_color,
--        kw.color_count,
    case
        when tc.difficulty_to_make = 1 then 'Simple Gift'
        when tc.difficulty_to_make = 2 then 'Moderate Gift'
        else 'Complex Gift'
        end as gift_complexity,
    case
        when tc.category = 'outdoor' then 'Outside Workshop'
        when tc.category = 'educational' then 'Learning Workshop'
        else 'General Workshop'
        end as workshop_assignment

from kid_wishes kw
         join toy_catalogue tc on kw.primary_wish = tc.toy_name
-- where kw.rn = 1
order by kw.name, kw.submitted_date desc
limit 10;
;