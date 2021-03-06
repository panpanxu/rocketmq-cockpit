CREATE DATABASE IF NOT EXISTS cockpit CHARACTER SET 'UTF8';

USE cockpit;

CREATE TABLE IF NOT EXISTS name_server (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  ip VARCHAR(64) NOT NULL,
  port SMALLINT NOT NULL DEFAULT 9876,
  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP NOT NULL DEFAULT 0
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS ip_mapping(
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  inner_ip VARCHAR(64) NOT NULL,
  public_ip VARCHAR(64) NOT NULL,
  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP NOT NULL DEFAULT 0
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS topic (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  topic VARCHAR(255) NOT NULL,
  cluster_name VARCHAR(100) NOT NULL DEFAULT 'DefaultCluster',
  permission TINYINT NOT NULL DEFAULT 6,
  write_queue_num INT NOT NULL DEFAULT 4,
  read_queue_num INT NOT NULL DEFAULT 4,
  unit BOOL NOT NULL DEFAULT FALSE ,
  has_unit_subscription BOOL NOT NULL DEFAULT FALSE ,
  broker_address VARCHAR(255),
  order_type BOOL DEFAULT FALSE,
  status_id INT NOT NULL DEFAULT 1 REFERENCES status_lu(id) ON DELETE RESTRICT ,
  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP NOT NULL DEFAULT 0
) ENGINE = INNODB;


CREATE TABLE IF NOT EXISTS consumer_group (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  cluster_name VARCHAR(255) NOT NULL DEFAULT 'DefaultCluster',
  which_broker_when_consume_slowly INT NOT NULL DEFAULT 1,
  group_name VARCHAR(255) NOT NULL,
  consume_enable BOOL NOT NULL DEFAULT TRUE ,
  consume_broadcast_enable BOOL NOT NULL DEFAULT FALSE,
  broker_address VARCHAR(255),
  broker_id INT,
  retry_max_times INT NOT NULL DEFAULT 3,
  retry_queue_num MEDIUMINT NOT NULL DEFAULT 3,
  consume_from_min_enable BOOL NOT NULL DEFAULT TRUE,
  status_id INT NOT NULL DEFAULT 1 REFERENCES status_lu(id) ON DELETE RESTRICT ,
  threshold INT NOT NULL DEFAULT 1000,
  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP NOT NULL DEFAULT 0
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS status_lu (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS consume_progress (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  consumer_group VARCHAR(255) NOT NULL,
  topic VARCHAR(255) NOT NULL,
  broker_name VARCHAR(255) NOT NULL,
  queue_id INT NOT NULL,
  broker_offset BIGINT NOT NULL DEFAULT 0,
  consumer_offset BIGINT NOT NULL DEFAULT 0,
  last_timestamp BIGINT NOT NULL DEFAULT 0,
  diff BIGINT NOT NULL DEFAULT 0,
  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

CREATE TABLE name_server_kv (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  name_space VARCHAR(255) NOT NULL,
  `key` VARCHAR(255) NOT NULL,
  `value` VARCHAR(255) NOT NULL,
  status_id INT NOT NULL REFERENCES status_lu(id) ON DELETE RESTRICT
);


-- User

CREATE TABLE IF NOT EXISTS team (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS cockpit_user (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(32) NOT NULL ,
  password  VARCHAR(64) NOT NULL,
  email VARCHAR(255) NOT NULL ,
  status_id INT NOT NULL REFERENCES status_lu(id) ON DELETE RESTRICT
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS team_user_xref (
  team_id INT NOT NULL REFERENCES team(id) ON DELETE RESTRICT ,
  user_id INT NOT NULL REFERENCES cockpit_user(id) ON DELETE RESTRICT ,
  CONSTRAINT UNIQUE (team_id, user_id)
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS cockpit_role (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(32) NOT NULL
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS cockpit_user_role_xref (
  user_id INT NOT NULL REFERENCES cockpit_user(id) ON DELETE RESTRICT ,
  role_id INT NOT NULL REFERENCES cockpit_role(id) ON DELETE RESTRICT ,
  CONSTRAINT UNIQUE (user_id, role_id)
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS cockpit_user_login (
  user_name VARCHAR(32) NOT NULL ,
  login_status INT NOT NULL DEFAULT 1,
  retry INT NOT NULL DEFAULT 0,
  lock_time BIGINT NOT NULL DEFAULT 0
) ENGINE = INNODB;

-- Resource ownership

CREATE TABLE IF NOT EXISTS topic_team_xref(
  topic_id INT NOT NULL REFERENCES topic(id) ON DELETE RESTRICT ,
  team_id INT NOT NULL REFERENCES team(id) ON DELETE RESTRICT ,
  CONSTRAINT UNIQUE (topic_id, team_id)
) ENGINE = INNODB;


CREATE TABLE IF NOT EXISTS consumer_group_team_xref(
  consumer_group_id INT NOT NULL REFERENCES consumer_group(id) ON DELETE RESTRICT ,
  team_id INT NOT NULL REFERENCES team(id) ON DELETE RESTRICT ,
  CONSTRAINT UNIQUE (consumer_group_id, team_id)
) ENGINE = INNODB;


-- Login
CREATE TABLE IF NOT EXISTS login (
  id INT NOT NULL PRIMARY KEY NOT NULL AUTO_INCREMENT,
  login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  user_id INT NOT NULL REFERENCES cockpit_user(id),
  token CHAR(32) NOT NULL
) ENGINE = INNODB;

CREATE INDEX idx_token ON login(token) USING HASH;



