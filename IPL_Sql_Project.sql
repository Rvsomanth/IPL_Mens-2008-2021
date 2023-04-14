create table ipl(
match_id int,
season int,
start_date date,
venue varchar(70),
innings int,
ball float,
batting_team varchar(30),
bowling_team varchar(30),
striker varchar(30),
non_striker varchar(30),
bowler varchar(30),
runs_off_bat int,
extras int,
wides float,
noballs float,
byes float,
legbyes float,
wicket_type varchar(50),
player_dismissed varchar(50),
run int,
over int);

--drop table ipl;
/*
if permission denied error, give the access to the file in properities and securities.
copy public."ipl" 
from 'C:\Users\SOMANTH KUMAR\Downloads\IPL Project\project\IPL_Dataset.csv'
DELIMITER ',' CSV HEADER;
*/
select * from ipl;

-- 1. List of Seasons
select distinct(season) from ipl;

--2. First ball of IPL history
select * from ipl limit 1

-- 3. Season Wise IPL Matches
select season,count(distinct match_id) from ipl
group by season;

--4. Most IPL Matches played in a Venue
select venue,count(distinct match_id) as matches_played_count from ipl
group by venue
order by 2 desc;

--5. IPL Matches Played by Each Team
select distinct batting_team,count(distinct match_id) as team_count from ipl
group by batting_team
order by 2 desc;

--6. Most Run Scored by IPL Teams
select match_id,batting_team,sum(run) as runs_scored from ipl
group by match_id,batting_team
order by 3 desc
limit 5;

--7. Most IPL Runs by a Batsman
select match_id,striker,sum(runs_off_bat) as runs_scored from ipl
group by match_id,striker
order by 3 desc
limit 5;

--8. Avg Run by Teams in Powerplay
select batting_team,round(avg(sum_runs),2) as avg_runs from
(select match_id,batting_team,sum(run) as sum_runs from ipl
where over <6
group by match_id,batting_team
 )x
group by 1
order by 2 desc;

-- 9. Most IPL Century by a Player

select striker,count(runs_scored) as no_of_centuries from
(select season,match_id,batting_team,striker,sum(runs_off_bat) as runs_scored
from ipl
group by 1,2,3,4)x
where runs_scored >=100
group by 1
order by 2 desc;

-- 10. Most IPL Fifty by Player
select striker,count(runs_scored) as no_of_centuries from
(select match_id,striker,sum(runs_off_bat) as runs_scored
from ipl
group by 1,2)x
where runs_scored >=50
group by 1
order by 2 desc;

-- 11. Orange Cap Holder Each Season
select distinct season,batting_team,striker,runs_scored from 
(select distinct season,batting_team,striker,sum(runs_off_bat) as runs_scored,
dense_rank() over (partition by season order by sum(runs_off_bat) desc) as dn
from ipl
group by 1,2,3
order by 4 desc)x
where dn=1;

--12. Most Sixes in an IPL Inning

select match_id,season,striker,count(runs_off_bat) as no_of_sixes from ipl
where runs_off_bat =6
group by 1,2,3
order by 4 desc
limit 5;

--13. Most Boundary (4s) hit by a Batsman
select match_id,season,striker,count(runs_off_bat) as no_of_sixes from ipl
where runs_off_bat =4
group by 1,2,3
order by 4 desc
limit 5;

--14. Most runs in an IPL season by Player
select season,striker,sum(runs_off_bat) as runs_scored from ipl
group by 1,2
order by 3 desc
limit 5;

--15. No. of Sixes in IPL Seasons
select season,count(run)as six_count from ipl
where run=6
group by 1
order by 2 desc;

--16. Highest Total by IPL Teams
select match_id,season,batting_team,sum(run) as runs_scored
from ipl
group by 1,2,3
order by 4 desc;

--17. Most IPL Sixes Hit by a batsman

select striker,count(runs_off_bat) as six_count
from ipl
where runs_off_bat=6
group by 1
order by 2 desc;

--19. Most run conceded by a bowler in an inning
select match_id,season,batting_team,bowling_team,bowler,sum(run) as runs_given
from ipl
group by 1,2,3,4,5
order by 6 desc;

--20. Purple Cap Holders
select season,bowler,count(wicket_type) as no_of_wickets
from ipl
where wicket_type not in (' ','run out','obstructing the field') 
group by 1,2
order by 3 desc;

--21. Most IPL Wickets by a Bowler
select bowler,count(wicket_type) as no_of_wickets
from ipl
where wicket_type not in (' ','run out','obstructing the field') 
group by 1
order by 2 desc;

--22. Most Dot Ball by a Bowler
select bowler,count(run) as no_of_dotballs
from ipl
where run=0 
group by 1
order by 2 desc;

--23. Most Maiden over by a Bowler
select bowler,count(over) from 
(select match_id,bowler,over,sum(run) as runs_scored
from ipl
group by 1,2,3
)x
where runs_scored=0
group by 1
order by 2 desc;

--24. Most Wickets by an IPL Team
select bowling_team,count(wicket_type) as no_of_wickets
from ipl
where wicket_type not in (' ','retired hurt','obstructing the field')
group by 1
order by 2 desc;

--25. Most No Balls by an IPL team
select bowling_team,count(noballs) as no_of_noballs
from ipl
where noballs!=0
group by 1
order by 2 desc;

--26. Most No Balls by an IPL Bowler
select bowler,count(noballs) as no_of_noballs
from ipl
where noballs!=0
group by 1
order by 2 desc;

--27. Most run given by a team in Extras
select bowling_team,count(extras) as no_of_extras
from ipl
where extras!=0
group by 1
order by 2 desc;

--28. Most Wides Conceded by an IPL team
select bowling_team,count(wides) as no_of_wides
from ipl
where wides!=0
group by 1
order by 2 desc;

--team own the tropy in season
 
select * from  
	(select season,batting_team as tropy_winners,bowling_team as runner_cup,
	 runs_scored,start_date,
	dense_rank() over (partition by season order by max(start_date) desc) as lv
	from (
		select *,dense_rank() over 
		(partition by match_id order by runs_scored desc) as dn
		from
			(select season,match_id,start_date,
			 batting_team,bowling_team,sum(run) as runs_scored
			from ipl
			group by 1,2,3,4,5
			 )x)y
			where dn=1
			group by 1,2,3,4,5
			 )z
where lv=1;

-- total ipl teams first and second innings with total wins and loss

with cte as (
	select *,
	dense_rank() over (partition by match_id order by runs_scored desc) as dn
	from 
	(select *,row_number() over (partition by match_id order by season) as rn
	from 
	(select match_id,season,batting_team,bowling_team,sum(run) as runs_scored
	 from ipl group by 1,2,3,4)x)y),
total_matches as (
	select batting_team,count(rn) as total_matches_played from cte
	group by 1
	order by 2 desc),
innings_count as (
	select t1.batting_team as first_batting,t1.count_first_inn,
	t2.batting_team as second_batting,t2.count_second_inn from 
	(select batting_team,count(rn) as count_first_inn from cte
	where rn=1  
	group by 1) t1
	inner join  
	(select batting_team,count(rn) as count_second_inn from cte
	where rn=2 
	group by 1) t2
	on t1.batting_team=t2.batting_team),
first_inn_win_loss as (
	select t1.batting_team as first_bat_wl,t1.count_first_inn_win,
	t2.count_first_inn_loss from
	(select batting_team,count(rn) as count_first_inn_win from cte
	where rn=1 and dn=1 
	group by 1) t1
	inner join  
	(select batting_team,count(rn) as count_first_inn_loss from cte
	where rn=1 and dn=2 
	group by 1)t2 
	on t1.batting_team=t2.batting_team),

second_inn_win_loss as (
	select t1.batting_team as sec_inn_wl,t1.count_second_inn_win,
	t2.count_second_inn_loss from
	(select batting_team,count(rn) as count_second_inn_win from cte
	where rn=2 and dn=1 
	group by 1)t1
	inner join  
	(select batting_team,count(rn) as count_second_inn_loss from cte
	where rn=2 and dn=2 
	group by 1)t2
	on t1.batting_team=t2.batting_team )

select batting_team as ipl_teams,total_matches_played,count_first_inn,
count_second_inn,count_first_inn_win,count_first_inn_loss,
count_second_inn_win,count_second_inn_loss
from total_matches tm
inner join innings_count ic
on tm.batting_team = ic.first_batting
inner join first_inn_win_loss fi
on fi.first_bat_wl = tm.batting_team
inner join second_inn_win_loss si
on si.sec_inn_wl = tm.batting_team;



































