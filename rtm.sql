REM  Author: Naresh Bhandare
REM  this is derived from rtop.sql - similar information as rtop.sql is generated by this script, but only for the specified module
REM   multiple modules can also be queried for using % wildcard
REM  usage, e.g. at sqlplus prompt
REM   > @rtm
REM     enter module [you may use %] : JDBC Thin Client
REM     sessions for module JDBC Thin Client
REM  This will display pivot for last 15 minutes activity in terms of wait events/CPU and in terms of sql_ids executed
REM   any spile or anomaly can be seen to drill down to issues
REM

set pages 2000 lines 166 verify off
set timing off feed off
col machine for a12 trunc
column w format a29 heading "Process State"
column avrg format 9999.999 heading "Average|Count"
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
break on inst skip 1

accept module prompt "enter module [you may use %] : "

prompt sessions for module &module

select inst_id, status, count(*) from gv$session where nvl(module,program) like '&module' group by inst_id, status
/

prompt
prompt Process States in last 15 minutes for &module
prompt

select * from (
select * from (
	select inst, w
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
		select   inst,mins_hist, w, count(*) / 60 cnt
		from
			(select inst_id inst, sysdate sdt, 
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
				decode(session_state, 'ON CPU', 'CPU', event) w
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  and nvl(module, program) like '&module'
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

--prompt
--prompt Wait Class for &module in last 15 minutes
--
--select * from (
--select * from (
--	select inst, w
--		,round(sum(cnt)/15,3)                        avrg
--		,round(sum(decode(mins_hist, 1,cnt,null)),3) t_1
--		,round(sum(decode(mins_hist, 2,cnt,null)),3) t_2
--		,round(sum(decode(mins_hist, 3,cnt,null)),3) t_3
--		,round(sum(decode(mins_hist, 4,cnt,null)),3) t_4
--		,round(sum(decode(mins_hist, 5,cnt,null)),3) t_5
--		,round(sum(decode(mins_hist, 6,cnt,null)),3) t_6
--		,round(sum(decode(mins_hist, 7,cnt,null)),3) t_7
--		,round(sum(decode(mins_hist, 8,cnt,null)),3) t_8
--		,round(sum(decode(mins_hist, 9,cnt,null)),3) t_9
--		,round(sum(decode(mins_hist,10,cnt,null)),3) t_10
--		,round(sum(decode(mins_hist,11,cnt,null)),3) t_11
--		,round(sum(decode(mins_hist,12,cnt,null)),3) t_12
--		,round(sum(decode(mins_hist,13,cnt,null)),3) t_13
--		,round(sum(decode(mins_hist,14,cnt,null)),3) t_14
--		,round(sum(decode(mins_hist,15,cnt,null)),3) t_15
--	from (
--		select   inst,mins_hist, w, count(*) / 60 cnt
--		from
--			(select inst_id inst, sysdate sdt, 
--                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
--				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
--				decode(session_state, 'ON CPU', 'CPU', wait_class) w
--			from gv$active_session_history a
--			where sample_time >= sysdate - 0.25/24
--			  and nvl(module, program) like '&module'
--			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
--			) a
--		group by inst, mins_hist, w
--		)
--	group by inst, w
--	order by nvl(avrg,0) desc
--	)
--where  avrg > 0
--  and rownum <= 25
--) order by inst, avrg desc
--/

select * from (
select * from (
	select inst, sql_id
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
		select  inst, mins_hist, sql_id, count(*) / 60 cnt
		from
			(select inst_id inst, sysdate sdt, 
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
				sql_id
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  and nvl(module,program) like '&module'
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by inst, mins_hist, sql_id
		)
	group by inst, sql_id
	order by nvl(avrg,0) desc
	)
where  avrg > 0
  and rownum <= 25
)
order by inst, avrg desc
/


accept ctlc prompt "hit ctrl-C to abort"

with sids as
(select inst_id inst, sid, serial#, to_char(logon_time, 'dd-mon hh24:mi') logon from gv$session where nvl(module,program) like '&module')
select * from (
        select inst, sid, logon, machine
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
                select  inst, mins_hist, sid, logon, machine, count(*) / 60 cnt
                from
                        (select inst_id inst, sysdate sdt,
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
                                --trunc((sysdate - sample_time) * 24  * 60) mins_hist,
                                sid, logon, machine
                        from gv$active_session_history a, sids s
                        where a.sample_time(+) >= sysdate - 0.25/24
                          and a.module(+) like '&module'
                          and a.session_id(+) = s.sid and a.session_Serial#(+) = s.serial#
                          --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
                        ) a
                group by inst, mins_hist, sid, logon, machine
                )
        group by inst, sid, logon, machine
        order by nvl(avrg,0) desc
        )
--where  avrg > 0
  --and rownum <= 25
order by 1, 4, 3, 2
/
