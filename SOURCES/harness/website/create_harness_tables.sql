--
-- Table structure for table `usecase`
--

DROP TABLE IF EXISTS `author`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `author` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `signum` varchar(20) NOT NULL DEFAULT '',
  `firstname` varchar(20) NOT NULL DEFAULT '',
  `lastname` varchar(30) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB ;

insert into author (signum,firstname,lastname) values ("edavmax", "Dave", "Maxwell"); 
insert into author (signum,firstname,lastname) values ("eedmax", "Ed", "Maxwell"); 
insert into author (signum,firstname,lastname) values ("eturdan", "Danny", "Turner"); 
insert into author (signum,firstname,lastname) values ("erowbai", "Rowland", "Bainbridge"); 
insert into author (signum,firstname,lastname) values ("xsimrea", "Simon", "Reap"); 
insert into author (signum,firstname,lastname) values ("xfeldan", "Felix", "Dansay"); 
insert into author (signum,firstname,lastname) values ("xphicoo", "Phil", "Cooper"); 
insert into author (signum,firstname,lastname) values ("xdansan", "Daniel", "Sanabria"); 
insert into author (signum,firstname,lastname) values ("xbahzan", "Bahran", "Zamani"); 
insert into author (signum,firstname,lastname) values ("xamamcg", "Amanda", "McGuinness"); 

DROP TABLE IF EXISTS `funcarea`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `funcarea` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB ;

insert into funcarea (name) values("LDAP");
insert into funcarea (name) values("DHCP");
insert into funcarea (name) values("DNS");
insert into funcarea (name) values("NTP");
insert into funcarea (name) values("SMRS");
insert into funcarea (name) values("COMMON");
insert into funcarea (name) values("INSTALL"); 
insert into funcarea (name) values("UPGRADE"); 

DROP TABLE IF EXISTS `usecase`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `usecase` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fa_id` int(11) NOT NULL,
  `auth_id` int(11) NOT NULL,
  `name` varchar(60) NOT NULL DEFAULT '',
  `slogan` text NOT NULL DEFAULT '',
  `steps` text NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB ;

-- ldap usecases
-- insert into usecase (fa_id,auth_id,name,slogan,steps) values(1, 1, "LDAP_USER_ADD", "Add a user to LDAP", "1. Login to the infra as user root\n2. Run the script add_user.sh\n3. Answer the questions");
-- insert into usecase (fa_id,auth_id,name,slogan,steps) values(1, 1, "LDAP_USER_DELETE", "Delete a user from LDAP", "1. Login to the infra as user root\n2. Run the script del_user.sh\n3. Answer the questions");
-- insert into usecase (fa_id,auth_id,name,slogan,steps) values(1, 1, "LDAP_USER_MODIFY", "Modify a user in LDAP", "1. Login to the infra as user root\n2. Run the script modify_user.sh\n3. Answer the questions");
-- insert into usecase (fa_id,auth_id,name,slogan,steps) values(2, 1, "DHCP_NETWORK_ADD", "Add a network to DHCP", "1. After initial install login to Infra as user root\n2. Run the ai_manager.sh script to add the network ");
-- insert into usecase (fa_id,auth_id,name,slogan,steps) values(2, 1, "DHCP_LTE_CLIENT_ADD", "Add an LTE network element to DHCP", "1. After initial install login to Infra as user root\n2. Run the ai_manager.sh script to add the lte client");

-- smrs usecases
-- insert into usecase (fa_id,auth_id,name,slogan,steps) values(5, 1, "SMRS_SMRSMASTER_ADD", "Add SMRS master to OSS master", "1. Login to OSS master as user root \n2. Run the script configure_smrs.sh");
-- insert into usecase (fa_id,auth_id,name,slogan,steps) values(5, 1, "SMRS_NEDSS_ADD", "Add NEDSS to SMRS master", "1. Login to OSS master as user root \n2. Run the script configure_smrs.sh");
-- insert into usecase (fa_id,auth_id,name,slogan,steps) values(5, 1, "SMRS_SLAVESERVICE_ADD", "Add SMRS slave service to OSS master", "1. Login to OSS master as user root \n2. Run the script configure_smrs.sh");


-- install usecases
-- insert into usecase (fa_id,auth_id,name,slogan,steps) values(7, 1, "INSTALL_COMINF_AUTOINSTALL", "Perform automated install of COMInf servers using pre-inirator file", "1. Enter server and service details in pre-inirator file  \n2. Run manage_dhcp_client script on MWS\n3. Reboot servers to start network installation.");
--
-- Table structure for table `testcase`
--

DROP TABLE IF EXISTS `testcase`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `testcase` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uc_id` int(11) NOT NULL,
  `auth_id` int(11) NOT NULL,
  `cont_id` int(11) NOT NULL,
  `slogan` text NOT NULL,
  `polarity` enum('positive','negative') NOT NULL DEFAULT 'positive',
  `type` enum('FT','UNIT') NOT NULL DEFAULT 'FT',
  `priority` enum('high','low') NOT NULL DEFAULT 'high',
  `preconditions` text NOT NULL,
  `automated` int(1) NOT NULL DEFAULT '0',
  `manual_steps` text NOT NULL,
  `postconditions` text NOT NULL,
  `disabled` int(1) NOT NULL DEFAULT '0',
  `approved` int(1) NOT NULL DEFAULT '0',
  `timeout` int(11) NOT NULL DEFAULT '600',
  `passcode` int(3) NOT NULL DEFAULT '0',
  `expect_plugin` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB ;

-- insert into testcase (uc_id,auth_id, cont_id, slogan,preconditions,manual_steps) values(1, 1, 4, "Add LDAP user using command line options", "Infra is up, OpenDJ is installed", "1. Login to Infra as user root \n2. Run the script add_ldap.sh");
-- insert into testcase (uc_id,auth_id, cont_id, slogan,preconditions,manual_steps) values(1, 1, 3, "Add LDAP user in interactive mode ", "Infra is up, OpenDJ is installed", "1. Login to Infra as user root \n2. Run the script add_ldap.sh");

DROP TABLE IF EXISTS `testsuite`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `testsuite` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `auth_id` int(11) NOT NULL,
  `name` varchar(60) NOT NULL DEFAULT '',
  `slogan` text NOT NULL,
  `exemode` enum('dependent', 'independent') NOT NULL DEFAULT 'dependent',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB ;

insert into testsuite (auth_id, name, slogan, exemode) values (1, "SMRS full suites",  "Full suites deployment for SMRS", "dependent");

DROP TABLE IF EXISTS `tstcmapping`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tstcmapping` (
  `tsid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `tcid` int(11) NOT NULL,
  PRIMARY KEY (`tsid`, `tcid`)
) ENGINE=InnoDB ;

insert into tstcmapping (tsid, tcid) values ( 1, 4 ) , (1, 5), (1,6), (1,7);




