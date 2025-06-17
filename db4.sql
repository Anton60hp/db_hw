-- Задача 1
with recursive empl_hierarchy as (
select 
	e.employeeid,
	e."name",
	e.managerid,
	e.departmentid,
	e.roleid
from employees e 
where e.employeeid = 1
union all
select 
	e.employeeid,
	e."name",
	e.managerid,
	e.departmentid,
	e.roleid
from employees e 
join empl_hierarchy eh on e.managerid = eh.employeeid
)
select 
	eh.employeeid,
	eh."name" as employeename,
	eh.managerid,
	d.departmentname,
	r.rolename,
	string_agg(p.projectname, ', '),
	string_agg(t.taskname, ', ')
from empl_hierarchy eh
left join departments d on eh.departmentid = d.departmentid
left join roles r on eh.roleid = r.roleid
left join projects p on d.departmentid = p.departmentid
left join tasks t on eh.employeeid = t.assignedto
group by 
	eh.employeeid,
	eh."name",
	eh.managerid,
	d.departmentname,
	r.rolename
order by eh."name"

-- Задача 2
with recursive empl_hierarchy as (
select 
	e.employeeid,
	e."name",
	e.managerid,
	e.departmentid,
	e.roleid
from employees e 
where e.employeeid = 1
union all
select 
	e.employeeid,
	e."name",
	e.managerid,
	e.departmentid,
	e.roleid
from employees e 
join empl_hierarchy eh on e.managerid = eh.employeeid
),
subordinates_count as (
	select 
		e.managerid as employeeid,
		count(*) as total_subordinates
	from employees e 
	where e.managerid in (select eh.employeeid from empl_hierarchy eh)
	group by e.managerid 
),
empl_proj as (
	select 
		eh.employeeid,
		string_agg(p.projectname, ', ') as projects
	from empl_hierarchy eh
	join departments d on eh.departmentid = d.departmentid
	join projects p on d.departmentid = p.departmentid
	group by eh.employeeid
),
empl_tasks as (
	select
		t.assignedto as employeeid,
		string_agg(t.taskname, ', ') as tasks,
		count(*) as total_tasks
	from tasks t
	join empl_hierarchy eh on eh.employeeid = t.assignedto
	group by t.assignedto
)
select 
	eh.employeeid,
	eh."name" as employeename,
	eh.managerid,
	d.departmentname,
	r.rolename,
	ep.projects,
	et.tasks,
	coalesce(et.total_tasks, 0) as total_tasks,
	coalesce(sc.total_subordinates, 0) as total_subordinates
from empl_hierarchy eh
left join departments d on eh.departmentid = d.departmentid
left join roles r on eh.roleid = r.roleid
left join subordinates_count sc on eh.employeeid = sc.employeeid
left join empl_proj ep on eh.employeeid = ep.employeeid
left join empl_tasks et on eh.employeeid = et.employeeid
order by eh."name"

-- Задача 3
with managers as (
	select 
		e.employeeid,
		e."name",
		e.managerid,
		e.departmentid,
		e.roleid
	from employees e 
	where exists (
		select 1 from employees e1
		where e1.managerid = e.employeeid
	)
),
subordinates_count_recursive as (
	with recursive empl_hierarchy as (
	select 
		e.employeeid,
		e.managerid
	from employees e 
	where e.managerid is not null
	union all
	select 
		eh.managerid as employeeid,
		e.employeeid as subordinateid
	from employees e 
	join empl_hierarchy eh on e.managerid = eh.employeeid
	)
	select 
		e.managerid as employeeid,
		count(*) as total_subordinates
	from employees e 
	where e.managerid in (select eh.employeeid from empl_hierarchy eh)
	group by e.managerid 
),
empl_proj as (
	select 
		eh.employeeid,
		string_agg(p.projectname, ', ') as projects
	from managers eh
	join departments d on eh.departmentid = d.departmentid
	join projects p on d.departmentid = p.departmentid
	group by eh.employeeid
),
empl_tasks as (
	select
		t.assignedto as employeeid,
		string_agg(t.taskname, ', ') as tasks
	from tasks t
	join managers eh on eh.employeeid = t.assignedto
	group by t.assignedto
)
select 
	eh.employeeid,
	eh."name" as employeename,
	eh.managerid,
	d.departmentname,
	r.rolename,
	ep.projects,
	et.tasks,
	coalesce(sc.total_subordinates, 0) as total_subordinates
from managers eh
left join departments d on eh.departmentid = d.departmentid
left join roles r on eh.roleid = r.roleid
left join subordinates_count_recursive sc on eh.employeeid = sc.employeeid
left join empl_proj ep on eh.employeeid = ep.employeeid
left join empl_tasks et on eh.employeeid = et.employeeid
order by eh."name"