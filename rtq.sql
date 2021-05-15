REM  Author: Naresh Bhandare
REM (use at your own ris - no gurantees implied)
REM  based on rtop.sql, this shows the same information filtered for a specific sql_id
REM
REM example at sqlplus prompt
REM > @rtq
REM   enter sql_id : 0hp5b4nf5r34f
REM


set pages 2000 lines 166 verify off
set timing off feed off
col machine for a20 trunc
column w format a29 heading "Process State"
column avrg format 9999.9 heading "Average|Count"
column t_1 format 999.9
column t_2 format 999.9
column t_3 format 999.9
column t_4 format 999.9
column t_5 format 999.9
column t_6 format 999.9
column t_7 format 999.9
column t_8 format 999.9
column t_9 format 999.9
column t_10 format 999.9
column t_11 format 999.9
column t_12 format 999.9
column t_13 format 999.9
column t_14 format 999.9
column t_15 format 999.9
col inst for 99
col module for a30 trunc
break on inst

accept sql_id prompt "enter sql_id : "

prompt
prompt Process States in last 15 minutes for &sql_id
prompt

select * from (
select * from (
	select inst, w
		,round(sum(cnt)/15,2)                        avrg
		,round(sum(decode(mins_hist, 1,cnt,null)),2) t_1
		,round(sum(decode(mins_hist, 2,cnt,null)),2) t_2
		,round(sum(decode(mins_hist, 3,cnt,null)),2) t_3
		,round(sum(decode(mins_hist, 4,cnt,null)),2) t_4
		,round(sum(decode(mins_hist, 5,cnt,null)),2) t_5
		,round(sum(decode(mins_hist, 6,cnt,null)),2) t_6
		,round(sum(decode(mins_hist, 7,cnt,null)),2) t_7
		,round(sum(decode(mins_hist, 8,cnt,null)),2) t_8
		,round(sum(decode(mins_hist, 9,cnt,null)),2) t_9
		,round(sum(decode(mins_hist,10,cnt,null)),2) t_10
		,round(sum(decode(mins_hist,11,cnt,null)),2) t_11
		,round(sum(decode(mins_hist,12,cnt,null)),2) t_12
		,round(sum(decode(mins_hist,13,cnt,null)),2) t_13
		,round(sum(decode(mins_hist,14,cnt,null)),2) t_14
		,round(sum(decode(mins_hist,15,cnt,null)),2) t_15
	from (
		select  inst, mins_hist, w, count(*) / 60 cnt
		from
			(select inst_id inst, sysdate sdt, 
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
				decode(session_state, 'ON CPU', 'CPU', event) w
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  and sql_id = '&sql_id'
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by inst, mins_hist, w
		)
	group by inst, w
	order by nvl(avrg,0) desc
	)
where  avrg > 0
  and rownum <= 25
) order by inst, avrg desc
/

select * from (
select * from (
	select inst, module
		,round(sum(cnt)/15,2)                        avrg
		,round(sum(decode(mins_hist, 1,cnt,null)),2) t_1
		,round(sum(decode(mins_hist, 2,cnt,null)),2) t_2
		,round(sum(decode(mins_hist, 3,cnt,null)),2) t_3
		,round(sum(decode(mins_hist, 4,cnt,null)),2) t_4
		,round(sum(decode(mins_hist, 5,cnt,null)),2) t_5
		,round(sum(decode(mins_hist, 6,cnt,null)),2) t_6
		,round(sum(decode(mins_hist, 7,cnt,null)),2) t_7
		,round(sum(decode(mins_hist, 8,cnt,null)),2) t_8
		,round(sum(decode(mins_hist, 9,cnt,null)),2) t_9
		,round(sum(decode(mins_hist,10,cnt,null)),2) t_10
		,round(sum(decode(mins_hist,11,cnt,null)),2) t_11
		,round(sum(decode(mins_hist,12,cnt,null)),2) t_12
		,round(sum(decode(mins_hist,13,cnt,null)),2) t_13
		,round(sum(decode(mins_hist,14,cnt,null)),2) t_14
		,round(sum(decode(mins_hist,15,cnt,null)),2) t_15
	from (
		select  inst, mins_hist, module, count(*) / 60 cnt
		from
			(select inst_id inst, sysdate sdt, 
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
				module
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  and sql_id = '&sql_id'
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by inst, mins_hist, module
		)
	group by inst, module
	order by nvl(avrg,0) desc
	)
where  avrg > 0
  and rownum <= 25
) order by inst, avrg desc
/

accept ctlc prompt "hit ctrl-C to abort"

select * from (
        select inst, sid, machine
                ,round(sum(cnt)/15,3)                        avrg
                ,round(sum(decode(mins_hist, 1,cnt,null)),3) t_1
                ,round(sum(decode(mins_hist, 2,cnt,null)),3) t_2
                ,round(sum(decode(mins_hist, 3,cnt,null)),3) t_3
                ,round(sum(decode(mins_hist, 4,cnt,null)),3) t_4
                ,round(sum(decode(mins_hist, 5,cnt,null)),3) t_5
                ,round(sum(decode(mins_hist, 6,cnt,null)),3) t_6
                ,round(sum(decode(mins_hist, 7,cnt,null)),3) t_7
                ,round(sum(decode(mins_hist, 8,cnt,null)),3) t_8
                ,round(sum(decode(mins_hist, 9,cnt,null)),3) t_9
                ,round(sum(decode(mins_hist,10,cnt,null)),3) t_10
                ,round(sum(decode(mins_hist,11,cnt,null)),3) t_11
                ,round(sum(decode(mins_hist,12,cnt,null)),3) t_12
                ,round(sum(decode(mins_hist,13,cnt,null)),3) t_13
                ,round(sum(decode(mins_hist,14,cnt,null)),3) t_14
                ,round(sum(decode(mins_hist,15,cnt,null)),3) t_15
        from (
                select  inst, mins_hist, sid, machine, count(*) / 60 cnt
                from
                        (select inst_id inst, sysdate sdt,
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
                                --trunc((sysdate - sample_time) * 24  * 60) mins_hist,
                                session_id sid, machine
                        from gv$active_session_history a
                        where a.sample_time(+) >= sysdate - 0.25/24
                          and a.sql_id(+) like '&sql_id'
                          --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
                        ) a
                group by inst, mins_hist, sid, machine
                )
        group by inst, sid, machine
        order by nvl(avrg,0) desc
        )
--where  avrg > 0
  --and rownum <= 25
order by 1, 4, 3, 2
/
