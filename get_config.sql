

/* 
-- finding built in fuctinos,quiet a lot
select 'select ' || schema || '.'|| function || '();' 
, bf.* 
from crdb_internal.builtin_functions bf 
where schema  ='crdb_internal'
order by "function" ;

-- top level info: what cluster are we, and when did we find it..
select crdb_internal.cluster_id() clu_id, crdb_internal.cluster_name() clu_name; ; 

-- node..
select crdb_internal.node_id();

-- recreate stmnts
select crdb_internal.show_create_all_tables('defaultdb');

set application_name = myapp ; 

select * from crdb_internal.cluster_sessions ; 

-- expected to find node-health here as well, live/suspet/dead ..
select * from crdb_internal.gossip_network ; 
select * from crdb_internal.gossip_nodes ;

select * from crdb_internal.session ; 

leases : local to node,
ranges_no_leases: seems global ?
node-local data, like leases on the node...  need to collect on all nodes, at same time.
also mind keys: node_id, table_id, parent_id, name...
and what does "deleted" signify?



crdb_internal.tables : need to investigate..
crdb_internal.index_columns : implicit list of indexes.
k


-- excercise: entities to try capture:
1. cluster, id + name 
2. nodes, from gossip ? , node-id = key, nodename is not unique...
3. tables + indexes from ... pg, and from crdb-internals
4. leases + replicase : from leases-per-node, and from replicas..?
5. combine the whole, and verify.
6. over time, say 15-min: nodes+uptime.

*/

-- cluster..
create table crx_cluster (
  id text primary key
, clu_name text
, dt_first_detect datetime 
) ; 
 
-- nodes, start simple, add addresses later, 
-- and put start-time and live/yn on measurements
create table crx_node (
  id integer primary key
, nodename text
, sql_addr text
) ; 

-- table: just the key-fields, other data can be joined from crdb + snapshot(-time)
create table crx_tables (
  table_id      bigint
, parent_id     bigint
, name          text
) ;
  

-- a snapshot is : cluster + node + time...
-- this makes it complicated to construct point-in-time.. ??
-- better: call sh-script with snap_id, 
-- if if not yet exist: create it., then loop over nodes
-- need shellscript: get_seq $1=seq_name, exit code and stdout = nextval.
create table crx_snap (
  id bigint primary key 
, dt datetime 
, node_created int 
);

