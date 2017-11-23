CREATE TABLE IF NOT EXISTS IDN_OAUTH_CONSUMER_APPS (
            ID INTEGER NOT NULL AUTO_INCREMENT,
            CONSUMER_KEY VARCHAR (255),
            CONSUMER_SECRET VARCHAR (512),
            USERNAME VARCHAR (255),
            TENANT_ID INTEGER DEFAULT 0,
            USER_DOMAIN VARCHAR(50),
            APP_NAME VARCHAR (255),
            OAUTH_VERSION VARCHAR (128),
            CALLBACK_URL VARCHAR (1024),
            GRANT_TYPES VARCHAR (1024),
            CONSTRAINT CONSUMER_KEY_CONSTRAINT UNIQUE (CONSUMER_KEY),
            PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS APM_SUBSCRIBER (
    SUBSCRIBER_ID INTEGER AUTO_INCREMENT,
    USER_ID VARCHAR(255) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EMAIL_ADDRESS VARCHAR(256) NULL,
    DATE_SUBSCRIBED TIMESTAMP NOT NULL,
    PRIMARY KEY (SUBSCRIBER_ID),
    UNIQUE (TENANT_ID,USER_ID)
);

CREATE TABLE IF NOT EXISTS APM_APPLICATION (
    APPLICATION_ID INTEGER AUTO_INCREMENT,
    NAME VARCHAR(100),
    SUBSCRIBER_ID INTEGER,
    APPLICATION_TIER VARCHAR(50) DEFAULT 'Unlimited',
    CALLBACK_URL VARCHAR(512),
    DESCRIPTION VARCHAR(512),
	APPLICATION_STATUS VARCHAR(50) DEFAULT 'APPROVED',
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES APM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY(APPLICATION_ID),
    UNIQUE (NAME,SUBSCRIBER_ID)
);
CREATE TABLE IF NOT EXISTS APM_BUSINESS_OWNER(
  OWNER_ID INTEGER  AUTO_INCREMENT,
  OWNER_NAME VARCHAR(200) NOT NULL,
  OWNER_EMAIL VARCHAR(300) NOT NULL,
  OWNER_DESC VARCHAR(1500),
  OWNER_SITE VARCHAR(200),
  TENANT_ID INTEGER,
  PRIMARY KEY(OWNER_ID),
  UNIQUE (OWNER_NAME,OWNER_EMAIL,TENANT_ID)
);

CREATE TABLE IF NOT EXISTS APM_BUSINESS_OWNER_PROPERTY(
  OWNER_PROP_ID INTEGER AUTO_INCREMENT,
  OWNER_ID INTEGER NOT NULL,
  NAME VARCHAR(200) NOT NULL,
  VALUE VARCHAR(300) NOT NULL,
  SHOW_IN_STORE BOOLEAN NOT NULL,
  PRIMARY KEY(OWNER_PROP_ID),
  FOREIGN KEY(OWNER_ID) REFERENCES APM_BUSINESS_OWNER(OWNER_ID)
);

 CREATE TABLE IF NOT EXISTS APM_APP (
     APP_ID INTEGER AUTO_INCREMENT,
     APP_PROVIDER VARCHAR(256),
     TENANT_ID INTEGER,
     APP_NAME VARCHAR(256),
     APP_VERSION VARCHAR(30),
     CONTEXT VARCHAR(256),
     TRACKING_CODE varchar(100),
     VISIBLE_ROLES varchar(500),
     UUID varchar(500),
     SAML2_SSO_ISSUER varchar(500),
     LOG_OUT_URL varchar(500),
     APP_ALLOW_ANONYMOUS BOOLEAN NULL,
     APP_ENDPOINT varchar(500),
     TREAT_AS_SITE BOOLEAN NOT NULL,
     PRIMARY KEY(APP_ID),
     UNIQUE (APP_PROVIDER,APP_NAME,APP_VERSION,TRACKING_CODE,UUID)
 );

CREATE TABLE IF NOT EXISTS APM_POLICY_GROUP
( 
	POLICY_GRP_ID INTEGER AUTO_INCREMENT,
	NAME VARCHAR(256),
	AUTH_SCHEME VARCHAR(50) NULL,
	THROTTLING_TIER varchar(512) DEFAULT NULL,
	USER_ROLES varchar(512) DEFAULT NULL,  
	URL_ALLOW_ANONYMOUS BOOLEAN DEFAULT FALSE,
	DESCRIPTION VARCHAR(1000) NULL,   
	PRIMARY KEY (POLICY_GRP_ID)
);
 
CREATE TABLE IF NOT EXISTS APM_POLICY_GROUP_MAPPING
( 
	POLICY_GRP_ID INTEGER  NOT NULL,
	APP_ID INTEGER NOT NULL,
	FOREIGN KEY (APP_ID) REFERENCES  APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (POLICY_GRP_ID) REFERENCES APM_POLICY_GROUP (POLICY_GRP_ID)  ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY (POLICY_GRP_ID,APP_ID)
);

CREATE TABLE IF NOT EXISTS APM_APP_URL_MAPPING (
    URL_MAPPING_ID INTEGER AUTO_INCREMENT,
    APP_ID INTEGER NOT NULL,
    HTTP_METHOD VARCHAR(20) NULL,
	URL_PATTERN VARCHAR(512) NULL, 
    SKIP_THROTTLING BOOLEAN DEFAULT FALSE,  
    POLICY_GRP_ID INTEGER NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (POLICY_GRP_ID) REFERENCES APM_POLICY_GROUP (POLICY_GRP_ID),
    PRIMARY KEY(URL_MAPPING_ID)
);

CREATE TABLE IF NOT EXISTS APM_ENTITLEMENT_POLICY_PARTIAL (
    ENTITLEMENT_POLICY_PARTIAL_ID INTEGER AUTO_INCREMENT,
    NAME varchar(256) DEFAULT NULL,
    CONTENT varchar(2048) DEFAULT NULL,
    SHARED  BOOLEAN DEFAULT FALSE,
    AUTHOR varchar(256) DEFAULT NULL,	
    DESCRIPTION VARCHAR(1000) NULL,
    TENANT_ID INTEGER NULL,
    PRIMARY KEY(ENTITLEMENT_POLICY_PARTIAL_ID)
);

CREATE TABLE IF NOT EXISTS APM_POLICY_GRP_PARTIAL_MAPPING (
    POLICY_GRP_ID INTEGER NOT NULL,
    POLICY_PARTIAL_ID INTEGER NOT NULL,
    EFFECT varchar(50),
    POLICY_ID varchar(100) DEFAULT NULL,
    FOREIGN KEY(POLICY_GRP_ID) REFERENCES APM_POLICY_GROUP(POLICY_GRP_ID)  ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(POLICY_PARTIAL_ID) REFERENCES APM_ENTITLEMENT_POLICY_PARTIAL(ENTITLEMENT_POLICY_PARTIAL_ID),
    PRIMARY KEY(POLICY_GRP_ID, POLICY_PARTIAL_ID)
);

CREATE TABLE IF NOT EXISTS APM_SUBSCRIPTION (
    SUBSCRIPTION_ID INTEGER AUTO_INCREMENT,
    SUBSCRIPTION_TYPE VARCHAR(50),
    TIER_ID VARCHAR(50),
    APP_ID INTEGER,
    LAST_ACCESSED TIMESTAMP NULL,
    APPLICATION_ID INTEGER,
    SUB_STATUS VARCHAR(50),
    TRUSTED_IDP VARCHAR(255) NULL,
    SUBSCRIPTION_TIME TIMESTAMP NOT NULL,
    FOREIGN KEY(APPLICATION_ID) REFERENCES APM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (SUBSCRIPTION_ID),
    UNIQUE(APP_ID, APPLICATION_ID,SUBSCRIPTION_TYPE)
);

CREATE TABLE IF NOT EXISTS APM_APP_LC_EVENT (
    EVENT_ID INTEGER AUTO_INCREMENT,
    APP_ID INTEGER NOT NULL,
    PREVIOUS_STATE VARCHAR(50),
    NEW_STATE VARCHAR(50) NOT NULL,
    USER_ID VARCHAR(255) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EVENT_DATE TIMESTAMP NOT NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (EVENT_ID)
);

CREATE TABLE IF NOT EXISTS APM_TIER_PERMISSIONS (
    TIER_PERMISSIONS_ID INTEGER AUTO_INCREMENT,
    TIER VARCHAR(50) NOT NULL,
    PERMISSIONS_TYPE VARCHAR(50) NOT NULL,
    ROLES VARCHAR(512) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    PRIMARY KEY(TIER_PERMISSIONS_ID)
);

CREATE TABLE IF NOT EXISTS APM_WORKFLOWS(
    WF_ID INTEGER AUTO_INCREMENT,
    WF_REFERENCE VARCHAR(255) NOT NULL,
    WF_TYPE VARCHAR(255) NOT NULL,
    WF_STATUS VARCHAR(255) NOT NULL,
    WF_CREATED_TIME TIMESTAMP,
    WF_UPDATED_TIME TIMESTAMP,
    WF_STATUS_DESC VARCHAR(1000),
    TENANT_ID INTEGER,
    TENANT_DOMAIN VARCHAR(255),
    WF_EXTERNAL_REFERENCE VARCHAR(255) NOT NULL,
    PRIMARY KEY (WF_ID),
    UNIQUE (WF_EXTERNAL_REFERENCE)
);

CREATE TABLE IF NOT EXISTS APM_API_CONSUMER_APPS (
 ID INTEGER AUTO_INCREMENT,
 SAML2_SSO_ISSUER varchar(500),
 APP_CONSUMER_KEY VARCHAR(512),
 API_TOKEN_ENDPOINT VARCHAR (1024),
 API_CONSUMER_KEY VARCHAR(512),
 API_CONSUMER_SECRET VARCHAR(512),
 APP_NAME VARCHAR(512),
 PRIMARY KEY (ID, APP_CONSUMER_KEY),
 FOREIGN KEY (SAML2_SSO_ISSUER) REFERENCES APM_APP(SAML2_SSO_ISSUER),
 FOREIGN KEY (APP_CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS APM_APP_HITS (
UUID VARCHAR(500) NOT NULL,
APP_NAME VARCHAR(200) NOT NULL,
VERSION VARCHAR(50),
CONTEXT VARCHAR(256) NOT NULL,
USER_ID VARCHAR(255) NOT NULL,
TENANT_ID INTEGER,
HIT_TIME TIMESTAMP NOT NULL,
PRIMARY KEY (UUID, USER_ID, TENANT_ID, HIT_TIME)
);

CREATE TABLE IF NOT EXISTS APM_APP_JAVA_POLICY
(
JAVA_POLICY_ID INTEGER AUTO_INCREMENT,
DISPLAY_NAME VARCHAR(100) NOT NULL,
FULL_QUALIFI_NAME VARCHAR(256) NOT NULL,
DESCRIPTION VARCHAR(2500),
DISPLAY_ORDER_SEQ_NO INTEGER NOT NULL,
IS_MANDATORY BOOLEAN DEFAULT FALSE,
POLICY_PROPERTIES VARCHAR(512) NULL,
IS_GLOBAL BOOLEAN DEFAULT TRUE,
PRIMARY KEY(JAVA_POLICY_ID),
UNIQUE(FULL_QUALIFI_NAME,DISPLAY_ORDER_SEQ_NO)
);


CREATE TABLE IF NOT EXISTS APM_APP_JAVA_POLICY_MAPPING
(
JAVA_POLICY_ID INTEGER NOT NULL,
APP_ID  INTEGER NOT NULL,
PRIMARY KEY (JAVA_POLICY_ID,APP_ID),
FOREIGN KEY (JAVA_POLICY_ID) REFERENCES APM_APP_JAVA_POLICY(JAVA_POLICY_ID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS APM_EXTERNAL_STORES(
    APP_STORE_ID INTEGER AUTO_INCREMENT,
    APP_ID INTEGER,
    STORE_ID VARCHAR(255) NOT NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (APP_STORE_ID)
);

CREATE TABLE IF NOT EXISTS APM_APP_DEFAULT_VERSION(
    DEFAULT_VERSION_ID INTEGER AUTO_INCREMENT,
    APP_NAME VARCHAR(256),
    APP_PROVIDER VARCHAR(256),
    DEFAULT_APP_VERSION VARCHAR(30),
    PUBLISHED_DEFAULT_APP_VERSION VARCHAR(30),
    TENANT_ID INTEGER,
PRIMARY KEY(DEFAULT_VERSION_ID)
);

CREATE TABLE IF NOT EXISTS APM_FAVOURITE_APPS (
   ID INTEGER  AUTO_INCREMENT,
   USER_ID VARCHAR(255) NOT NULL,
   TENANT_ID INTEGER NOT NULL,
   APP_ID INTEGER NOT NULL,
   CREATED_TIME TIMESTAMP NOT NULL,
   PRIMARY KEY (ID),
   FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON DELETE CASCADE,
   UNIQUE (TENANT_ID,USER_ID,APP_ID)
);

CREATE TABLE IF NOT EXISTS APM_STORE_FAVOURITE_PAGE (
   ID INTEGER  AUTO_INCREMENT,
   USER_ID VARCHAR(255) NOT NULL,
   TENANT_ID_OF_USER INTEGER NOT NULL,
   TENANT_ID_OF_STORE INTEGER NOT NULL,
   PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS APM_ONE_TIME_DOWNLOAD_LINK(
     ID INTEGER  AUTO_INCREMENT,
     BINARY_FILE varchar(500) NOT NULL,
     UUID varchar(500) NOT NULL,
     IS_DOWNLOADED BOOLEAN NOT NULL,
     USERNAME VARCHAR(255),
     TENANT_ID INTEGER,
     TENANT_DOMAIN VARCHAR(255),
     CREATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS APM_USER_PORTAL_THEME(
  TENANT_ID INTEGER,
  NAME VARCHAR(200) NOT NULL,
  DESCRIPTION VARCHAR(1500),
  PRIMARY KEY(TENANT_ID),
  UNIQUE (TENANT_ID)
);


INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY, IS_GLOBAL )
VALUES ('Reverse Proxy Handler','org.wso2.carbon.appmgt.gateway.handlers.proxy.ReverseProxyHandler','',1,TRUE,TRUE);

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY,IS_GLOBAL)
VALUES ('SAML2 Authentication Handler','org.wso2.carbon.appmgt.gateway.handlers.security.authentication.SAML2AuthenticationHandler','',2,TRUE,TRUE);

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY,IS_GLOBAL)
VALUES ('Subscription Handler', 'org.wso2.carbon.appmgt.gateway.handlers.subscription.SubscriptionsHandler', '', 3,TRUE,TRUE);

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY,IS_GLOBAL)
VALUES ('Authorization Handler', 'org.wso2.carbon.appmgt.gateway.handlers.security.entitlement.AuthorizationHandler','',4,TRUE,TRUE);

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY,IS_GLOBAL)
VALUES ('Entitlement Handler','org.wso2.carbon.appmgt.gateway.handlers.security.entitlement.EntitlementHandler','',5,TRUE,TRUE);

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY, POLICY_PROPERTIES,IS_GLOBAL )
VALUES ('API Throttle Handler','org.wso2.carbon.appmgt.gateway.handlers.throttling.APIThrottleHandler','',6,TRUE,'{ "id": "A",  "policyKey": "gov:/appmgt/applicationdata/tiers.xml"}',TRUE);

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY,IS_GLOBAL)
VALUES ('Publish Statistics:','org.wso2.carbon.appmgt.usage.publisher.APPMgtUsageHandler','',7,FALSE,TRUE);


CREATE INDEX IDX_SUB_APP_ID ON APM_SUBSCRIPTION (APPLICATION_ID, SUBSCRIPTION_ID);
