/* 

 file: mk_snaps.sql: create objects to collect snapshots

 usage: run this create script before using do_snaps.sh

 related files:
  get_snap.sh : stdout the last snap_id
  do_snaps.sh : collect the cluster-wide info
  do_snap_node.sh: collect snap-data on 1 node (run at node)

convention:
  crx_obj : parent table for objects: cluster, node, table, index, lease, range....
  crx_sn_obj : measurements for object : cluster, node, table, index, lease, range 

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
, dt_first_detect timestamp 
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
) ; 

-- tables
create table crx_sn_tables (
  snap_id   bigint
, table_id  bigint
, parent_id bigint
, parent_schema_id bigint
, table_name text
, database_name text 
, est_rows   bigint
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
, range_size   bigint
, constraint crx_sn_ranges_pk primary key ( snap_id, range_id )
) ; 

-- ranges_no_leases??
create table crx_sn_ranges_no_lse (
  snap_id     bigint
, range_id    bigint
, table_id    bigint 
, db_name      text
, schema_name  text
, table_name   text 
, index_name   text
, replicas     text
, voting_repl  text
, non_vt_repl  text
, learner_repl  text
, constraint crx_sn_ranges_no_lse_pk primary key ( snap_id, range_id )
) ; 


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

