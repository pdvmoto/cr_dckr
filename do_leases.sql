
-- note: a merge would be more elegant..  ?
-- note: the deleted tables seem to get double-entries, even if delted=f ??

delete from crx_leases where node_id in ( select node_id from crx_nodeinfo ) ;

insert into crx_leases select * from crdb_internal.leases ;

select node_id, nodename from crx_nodeinfo ; 

\q

