

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

-- id the app. todo: put this in URI
set application_name = myapp ; 

-- sessions... can get AAS..
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

-- some seq
create sequence crx_snap_seq ;

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

-- databases
-- skip for the moment..

-- table: just the key-fields, other data can be joined from crdb + snapshot(-time)
create table crx_tables (
  table_id      bigint
, parent_id     bigint
, name          text
) ;
  
-- this makes it complicated to construct point-in-time.. ??
-- better: call sh-script with snap_id, 
-- if if not yet exist: create it., then loop over nodes
-- need shellscript: get_seq $1=seq_name, exit code and stdout = nextval.
create table crx_snap (
  snap_id         bigint primary key 
, dt              timestamp 
, node_created    int 
, client_created  text
);

-- nodes, and statuses at time of snapshot
create table crx_sn_nodes ( 
  snap_id       bigint
, node_id       int
, started_at    timestamp
, is_live       boolean
, ranges        bigint, leases bigint
, draining boolean, decommissioning boolean, membership text, updated_at timestamp
, constraint crx_sn_nodes_pk primary key ( snap_id, node_id ) 
); 

-- databases: later
create table  crx_sn_datab ( 
  snap_id bigint
, db_id   bigint
, db_name text
, constraint crx_sn_datab_pk primary key ( snap_id, db_id )
, ) ; 

-- tables
create table crx_sn_tables (
  snap_id   bigint
, table_id  bigint
, parent_id bigint
, parent_schema_id bigint
, table_name text
, database_name text 
, constraint crx_sn_tables_pk primary key ( snap_id, table_id ) 
) ; 

-- leases, this one is node-specific, need to insert from every node
create table crx_sn_leases (
  snap_id     bigint
, node_id     bigint
, table_id    bigint 
, parent_id   bigint
, name        text
, expiration  timestamp
, deleted     boolean
, constraint crx_sn_leases_pk primary key ( snap_id, node_id, table_id )
);

-- ranges, need to find exact PK and FKs
-- this seems to fix table to lease-holder, and to replicas
create table crx_sn_ranges (
  snap_id     bigint
, range_id    bigint
, lease_holder bigint
, table_id    bigint 
, db_name      text
, schema_name  text
, table_name   text 
, index_name   text
, replicas     text
, voting_repl  text
, non_vt_repl  text
, learner_repl  text
, constraint crx_sn_ranges_pk primary key ( snap_id, range_id )
) ; 

-- ranges_no_leases??
create table crx_sn_range_no_l (
  snap_id    bigint
, rel_id     bigint
, parent_schema_id bigint
, rel_name   text
, drop_time  timestamp
, constraint crx_sn_range_no


-- kv_dropped_rel, is not snap+id dependent.. 
-- beware on insert: needs not-exist.
-- beware: pk may be just ID.
create table crx_sn_kv_dropped (
  snap_id     bigint
, parent_schema_id bigint
, rel_id      bigint
, rel_name    text
, drop_time   timestamp
, constraint crx_sn_kv_dropped_pk primary key ( parent_schema_id, rel_id ) 
);

