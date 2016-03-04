declare
v_sql LONG;
begin

v_sql:='IDN_OAUTH_CONSUMER_APPS (
        ID INTEGER,
        CONSUMER_KEY VARCHAR2 (255),
        CONSUMER_SECRET VARCHAR2 (512),
        USERNAME VARCHAR2 (255),
        TENANT_ID INTEGER DEFAULT 0,
        USER_DOMAIN VARCHAR(50),
        APP_NAME VARCHAR2 (255),
        OAUTH_VERSION VARCHAR2 (128),
        CALLBACK_URL VARCHAR2 (1024),
        GRANT_TYPES VARCHAR (1024),
        CONSTRAINT CONSUMER_KEY_CONSTRAINT UNIQUE (CONSUMER_KEY),
        PRIMARY KEY (ID))';
execute immediate v_sql;

EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -955 THEN
        NULL; -- suppresses ORA-00955 exception
      ELSE
         RAISE;
      END IF;
END;
/

CREATE SEQUENCE IDN_OAUTH_CONSUMER_APPS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER IDN_OAUTH_CONSUMER_APPS_TRIG
            BEFORE INSERT
            ON IDN_OAUTH_CONSUMER_APPS
            REFERENCING NEW AS NEW
            FOR EACH ROW
              BEGIN
                SELECT IDN_OAUTH_CONSUMER_APPS_SEQ.nextval INTO :NEW.ID FROM dual;
              END;
/

CREATE TABLE APM_SUBSCRIBER (
    SUBSCRIBER_ID INTEGER,
    USER_ID VARCHAR2(50) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EMAIL_ADDRESS VARCHAR2(256) NULL,
    DATE_SUBSCRIBED TIMESTAMP NOT NULL,
    PRIMARY KEY (SUBSCRIBER_ID),
    UNIQUE (TENANT_ID,USER_ID)
)
/

CREATE SEQUENCE APM_SUBSCRIBER_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_SUBSCRIBER_TRIGGER
    BEFORE INSERT
    ON APM_SUBSCRIBER
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
    SELECT APM_SUBSCRIBER_SEQUENCE.nextval INTO :NEW.SUBSCRIBER_ID FROM dual;
    END;
/

CREATE INDEX IDX_APM_SUBSCRIBER_USER_ID ON APM_SUBSCRIBER (USER_ID)
/

CREATE TABLE APM_APPLICATION (
    APPLICATION_ID INTEGER,
    NAME VARCHAR2(100),
    SUBSCRIBER_ID INTEGER,
    APPLICATION_TIER VARCHAR2(50) DEFAULT 'Unlimited',
    CALLBACK_URL VARCHAR2(512),
    DESCRIPTION VARCHAR2(512),
    APPLICATION_STATUS VARCHAR2(50) DEFAULT 'APPROVED',
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES APM_SUBSCRIBER(SUBSCRIBER_ID),
    PRIMARY KEY(APPLICATION_ID),
    UNIQUE (NAME,SUBSCRIBER_ID)
)
/

CREATE SEQUENCE APM_APPLICATION_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_APPLICATION_TRIGGER
    BEFORE INSERT
    ON APM_APPLICATION
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
    SELECT APM_APPLICATION_SEQUENCE.nextval INTO :NEW.APPLICATION_ID FROM dual;
    END;
/

CREATE TABLE APM_APP (
    APP_ID INTEGER,
    APP_PROVIDER VARCHAR2(256),
    TENANT_ID INTEGER,
    APP_NAME VARCHAR2(256),
    APP_VERSION VARCHAR2(30),
    CONTEXT VARCHAR2(256),
    TRACKING_CODE VARCHAR2(100),
    UUID VARCHAR2(500) NOT NULL,
    SAML2_SSO_ISSUER VARCHAR2(500),
    LOG_OUT_URL VARCHAR2(500),
    APP_ALLOW_ANONYMOUS NUMBER(1) NULL,
    APP_ENDPOINT VARCHAR2(500),
    TREAT_AS_SITE NUMBER(1) NOT NULL,
    PRIMARY KEY(APP_ID),
    UNIQUE (APP_PROVIDER,APP_NAME,APP_VERSION,TRACKING_CODE,UUID),
    UNIQUE (SAML2_SSO_ISSUER)
)
/

CREATE SEQUENCE APM_APP_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_APP_TRIGGER
    BEFORE INSERT
    ON APM_APP
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
    SELECT APM_APP_SEQUENCE.nextval INTO :NEW.APP_ID FROM dual;
    END;
/

CREATE INDEX IDX_APM_APP_UUID ON APM_APP (UUID)
/

CREATE TABLE APM_POLICY_GROUP
( 
    POLICY_GRP_ID INTEGER,
    NAME VARCHAR2(256),
    AUTH_SCHEME VARCHAR2(50) NULL,
    THROTTLING_TIER VARCHAR2(512) DEFAULT NULL,
    USER_ROLES VARCHAR2(512) DEFAULT NULL,  
    URL_ALLOW_ANONYMOUS NUMBER(1) DEFAULT 0,   
    DESCRIPTION VARCHAR2(1000) NULL,
    PRIMARY KEY (POLICY_GRP_ID)
)
/

CREATE SEQUENCE APM_POLICY_GROUP_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_POLICY_GROUP_TRIGGER
    BEFORE INSERT
    ON APM_POLICY_GROUP
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_POLICY_GROUP_SEQUENCE.nextval INTO :NEW.POLICY_GRP_ID FROM dual;
    END;
	/

CREATE TABLE APM_POLICY_GROUP_MAPPING
( 
    POLICY_GRP_ID INTEGER  NOT NULL,
    APP_ID INTEGER NOT NULL,
    FOREIGN KEY (APP_ID) REFERENCES  APM_APP(APP_ID) ON DELETE CASCADE,
    FOREIGN KEY (POLICY_GRP_ID) REFERENCES APM_POLICY_GROUP (POLICY_GRP_ID) ON DELETE CASCADE,
    PRIMARY KEY (POLICY_GRP_ID,APP_ID)
)
/


CREATE TABLE APM_APP_URL_MAPPING (
    URL_MAPPING_ID INTEGER,
    APP_ID INTEGER NOT NULL,
    HTTP_METHOD VARCHAR2(20) NULL,
    URL_PATTERN VARCHAR2(512) NULL, 
    SKIP_THROTTLING NUMBER(1) DEFAULT 0,  
    POLICY_GRP_ID INTEGER NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON DELETE CASCADE,
    FOREIGN KEY (POLICY_GRP_ID) REFERENCES APM_POLICY_GROUP (POLICY_GRP_ID),
    PRIMARY KEY(URL_MAPPING_ID)
)
/


CREATE SEQUENCE APM_APP_URL_MAPPING_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_APP_URL_MAPPING_TRIGGER
    BEFORE INSERT
    ON APM_APP_URL_MAPPING
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_APP_URL_MAPPING_SEQUENCE.nextval INTO :NEW.URL_MAPPING_ID FROM dual;
    END;
	/

CREATE TABLE APM_ENTITLEMENT_POLICY_PARTIAL (
    ENTITLEMENT_POLICY_PARTIAL_ID INTEGER,
    NAME VARCHAR2(256) DEFAULT NULL,
    CONTENT VARCHAR2(2048) DEFAULT NULL,
    "SHARED" NUMBER(1) DEFAULT 0,
    AUTHOR VARCHAR2(256) DEFAULT NULL,   
    DESCRIPTION VARCHAR2(1000) NULL,
    TENANT_ID INT NULL,
    PRIMARY KEY(ENTITLEMENT_POLICY_PARTIAL_ID)
)
/

-- Breaking the naming convention since the identifer name is too long.
CREATE SEQUENCE APM_ENTL_POLICY_PARTIAL_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/

-- Breaking the naming convention since the identifer name is too long.
CREATE OR REPLACE TRIGGER APM_ENTL_POLICY_PARTIAL_TRIG
    BEFORE INSERT
    ON APM_ENTITLEMENT_POLICY_PARTIAL
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_ENTL_POLICY_PARTIAL_SEQ.nextval INTO :NEW.ENTITLEMENT_POLICY_PARTIAL_ID FROM dual;
    END;
	/

CREATE TABLE APM_POLICY_GRP_PARTIAL_MAPPING (
    POLICY_GRP_ID INTEGER NOT NULL,
    POLICY_PARTIAL_ID INTEGER NOT NULL,
    EFFECT VARCHAR2(50),
    POLICY_ID VARCHAR2(100) DEFAULT NULL,
    FOREIGN KEY(POLICY_GRP_ID) REFERENCES APM_POLICY_GROUP(POLICY_GRP_ID)  ON DELETE CASCADE,
    FOREIGN KEY(POLICY_PARTIAL_ID) REFERENCES APM_ENTITLEMENT_POLICY_PARTIAL(ENTITLEMENT_POLICY_PARTIAL_ID),
    PRIMARY KEY(POLICY_GRP_ID, POLICY_PARTIAL_ID)
)
/

CREATE TABLE APM_SUBSCRIPTION (
    SUBSCRIPTION_ID INTEGER,
    SUBSCRIPTION_TYPE VARCHAR2(50),
    TIER_ID VARCHAR2(50),
    APP_ID INTEGER,
    LAST_ACCESSED TIMESTAMP NULL,
    APPLICATION_ID INTEGER,
    SUB_STATUS VARCHAR2(50),
    TRUSTED_IDP VARCHAR2(255) NULL,
    SUBSCRIPTION_TIME TIMESTAMP NOT NULL,
    FOREIGN KEY(APPLICATION_ID) REFERENCES APM_APPLICATION(APPLICATION_ID),
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID),
    PRIMARY KEY (SUBSCRIPTION_ID),
    UNIQUE(APP_ID, APPLICATION_ID,SUBSCRIPTION_TYPE)
)
/

CREATE SEQUENCE APM_SUBSCRIPTION_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_SUBSCRIPTION_TRIGGER
    BEFORE INSERT
    ON APM_SUBSCRIPTION
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_SUBSCRIPTION_SEQUENCE.nextval INTO :NEW.SUBSCRIPTION_ID FROM dual;
	END;
	/

CREATE INDEX IDX_SUB_APP_ID ON APM_SUBSCRIPTION (APPLICATION_ID, SUBSCRIPTION_ID)
/

CREATE TABLE APM_APP_LC_EVENT (
    EVENT_ID INTEGER,
    APP_ID INTEGER NOT NULL,
    PREVIOUS_STATE VARCHAR2(50),
    NEW_STATE VARCHAR2(50) NOT NULL,
    USER_ID VARCHAR2(50) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EVENT_DATE TIMESTAMP NOT NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID),
    PRIMARY KEY (EVENT_ID)
)
/

CREATE SEQUENCE APM_APP_LC_EVENT_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_APP_LC_EVENT_TRIGGER
    BEFORE INSERT
    ON APM_APP_LC_EVENT
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_APP_LC_EVENT_SEQUENCE.nextval INTO :NEW.EVENT_ID FROM dual;
    END;
	/

CREATE TABLE APM_APP_COMMENTS (
    COMMENT_ID INTEGER,
    COMMENT_TEXT VARCHAR2(512),
    COMMENTED_USER VARCHAR2(255),
    DATE_COMMENTED TIMESTAMP NOT NULL,
    APP_ID INTEGER NOT NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID),
    PRIMARY KEY (COMMENT_ID)
)
/

CREATE SEQUENCE APM_APP_COMMENTS_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_APP_COMMENTS_TRIGGER
    BEFORE INSERT
    ON APM_APP_COMMENTS
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_APP_COMMENTS_SEQUENCE.nextval INTO :NEW.COMMENT_ID FROM dual;
    END;
/

CREATE TABLE APM_APP_RATINGS(
    RATING_ID INTEGER,
    APP_ID INTEGER,
    RATING INTEGER,
    SUBSCRIBER_ID INTEGER,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID),
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES APM_SUBSCRIBER(SUBSCRIBER_ID),
    PRIMARY KEY (RATING_ID)
)
/

CREATE SEQUENCE APM_APP_RATINGS_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_APP_RATINGS_TRIGGER
    BEFORE INSERT
    ON APM_APP_RATINGS
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_APP_RATINGS_SEQUENCE.nextval INTO :NEW.RATING_ID FROM dual;
	END;
	/

CREATE TABLE APM_TIER_PERMISSIONS (
    TIER_PERMISSIONS_ID INTEGER,
    TIER VARCHAR2(50) NOT NULL,
    PERMISSIONS_TYPE VARCHAR2(50) NOT NULL,
    ROLES VARCHAR2(512) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    PRIMARY KEY(TIER_PERMISSIONS_ID)
)
/

CREATE SEQUENCE APM_TIER_PERMISSIONS_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_TIER_PERMISSIONS_TRIGGER
    BEFORE INSERT
    ON APM_TIER_PERMISSIONS
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_TIER_PERMISSIONS_SEQUENCE.nextval INTO :NEW.TIER_PERMISSIONS_ID FROM dual;
    END;
	/

CREATE TABLE APM_WORKFLOWS(
    WF_ID INTEGER,
    WF_REFERENCE VARCHAR2(255) NOT NULL,
    WF_TYPE VARCHAR2(255) NOT NULL,
    WF_STATUS VARCHAR2(255) NOT NULL,
    WF_CREATED_TIME TIMESTAMP,
    WF_UPDATED_TIME TIMESTAMP,
    WF_STATUS_DESC VARCHAR2(1000),
    TENANT_ID INTEGER,
    TENANT_DOMAIN VARCHAR2(255),
    WF_EXTERNAL_REFERENCE VARCHAR2(255) NOT NULL,
    PRIMARY KEY (WF_ID),
    UNIQUE (WF_EXTERNAL_REFERENCE)
)
/

CREATE SEQUENCE APM_WORKFLOWS_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_WORKFLOWS_TRIGGER
    BEFORE INSERT
    ON APM_WORKFLOWS
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_WORKFLOWS_SEQUENCE.nextval INTO :NEW.WF_ID FROM dual;
    END;
	/


-- TODO : Add Foreign key contraints for APP_CONSUMER_KEY --> IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) and  (SAML2_SSO_ISSUER) --> APM_APP(SAML2_SSO_ISSUER)
CREATE TABLE APM_API_CONSUMER_APPS(
     ID INTEGER,
     SAML2_SSO_ISSUER VARCHAR2(500),
     APP_CONSUMER_KEY VARCHAR2(512),
     API_TOKEN_ENDPOINT VARCHAR2(1024),
     API_CONSUMER_KEY VARCHAR2(512),
     API_CONSUMER_SECRET VARCHAR2(512),
     APP_NAME VARCHAR2(512),
     PRIMARY KEY (ID, APP_CONSUMER_KEY)
)
/

CREATE SEQUENCE APM_API_CONSUMER_APPS_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_API_CONSUMER_APPS_TRIGGER
    BEFORE INSERT
    ON APM_API_CONSUMER_APPS
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_API_CONSUMER_APPS_SEQUENCE.nextval INTO :NEW.ID FROM dual;
	END;
	/




CREATE TABLE APM_APP_HITS (
    UUID VARCHAR2(500) NOT NULL,
    APP_NAME VARCHAR2(200) NOT NULL,
    VERSION VARCHAR2(50),
    CONTEXT VARCHAR2(256) NOT NULL,
    USER_ID VARCHAR2(50) NOT NULL,
    TENANT_ID INTEGER,
    HIT_TIME TIMESTAMP NOT NULL,
    PRIMARY KEY (UUID, USER_ID, TENANT_ID, HIT_TIME)
)
/

CREATE TABLE APM_APP_JAVA_POLICY(
    JAVA_POLICY_ID INTEGER,
    DISPLAY_NAME VARCHAR2(100) NOT NULL,
    FULL_QUALIFI_NAME VARCHAR2(256) NOT NULL,
    DESCRIPTION VARCHAR2(2500),
    DISPLAY_ORDER_SEQ_NO INTEGER NOT NULL,
    IS_MANDATORY NUMBER(1) DEFAULT 0,
    POLICY_PROPERTIES VARCHAR2(512) NULL,
    IS_GLOBAL NUMBER(1) DEFAULT 1,
    PRIMARY KEY(JAVA_POLICY_ID),
    UNIQUE(FULL_QUALIFI_NAME,DISPLAY_ORDER_SEQ_NO)
)
/

CREATE SEQUENCE APM_APP_JAVA_POLICY_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_APP_JAVA_POLICY_TRIGGER
    BEFORE INSERT
    ON APM_APP_JAVA_POLICY
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_APP_JAVA_POLICY_SEQUENCE.nextval INTO :NEW.JAVA_POLICY_ID FROM dual;
    END;
	/

CREATE TABLE APM_APP_JAVA_POLICY_MAPPING(
    JAVA_POLICY_ID INTEGER NOT NULL,
    APP_ID  INTEGER NOT NULL,
    PRIMARY KEY (JAVA_POLICY_ID,APP_ID),
    FOREIGN KEY (JAVA_POLICY_ID) REFERENCES APM_APP_JAVA_POLICY(JAVA_POLICY_ID) ON DELETE CASCADE,
    FOREIGN KEY (APP_ID) REFERENCES APM_APP(APP_ID) ON DELETE CASCADE
)
/

CREATE TABLE APM_EXTERNAL_STORES (
    APP_STORE_ID INTEGER,
    APP_ID INTEGER,
    STORE_ID VARCHAR2(255) NOT NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON DELETE CASCADE,
    PRIMARY KEY (APP_STORE_ID)
)
/

CREATE SEQUENCE APM_EXTERNAL_STORES_SEQUENCE START WITH 1 INCREMENT BY 1
/

CREATE OR REPLACE TRIGGER APM_EXTERNAL_STORES_TRIGGER
		    BEFORE INSERT
                    ON APM_EXTERNAL_STORES
                    REFERENCING NEW AS NEW
                    FOR EACH ROW
                    BEGIN
                    SELECT APM_EXTERNAL_STORES_SEQUENCE.nextval INTO :NEW.APP_STORE_ID FROM dual;
                    END;
/

CREATE TABLE APM_APP_DEFAULT_VERSION (
    DEFAULT_VERSION_ID INTEGER,
    APP_NAME VARCHAR2(256),
    APP_PROVIDER VARCHAR2(256),
    DEFAULT_APP_VERSION VARCHAR2(30),
    PUBLISHED_DEFAULT_APP_VERSION VARCHAR2(30),
    TENANT_ID INTEGER,
PRIMARY KEY(DEFAULT_VERSION_ID)
)
/

CREATE SEQUENCE APM_APP_DEFAULT_VERSION_SEQUENCE START WITH 1 INCREMENT BY 1
/

CREATE OR REPLACE TRIGGER APM_APP_DEFAULT_VERSION_TRIGGER
		    BEFORE INSERT
                    ON APM_APP_DEFAULT_VERSION_SEQUENCE
                    REFERENCING NEW AS NEW
                    FOR EACH ROW
                    BEGIN
                    SELECT APM_APP_DEFAULT_VERSION_SEQUENCE.nextval INTO :NEW.DEFAULT_VERSION_ID FROM dual;
                    END;

CREATE TABLE APM_FAVOURITE_APPS (
   ID INTEGER ,
   USER_ID VARCHAR(50) NOT NULL,
   TENANT_ID INTEGER NOT NULL,
   APP_ID INTEGER NOT NULL,
   CREATED_TIME DATE NOT NULL,
   PRIMARY KEY (ID),
   FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON DELETE CASCADE,
   UNIQUE (TENANT_ID,USER_ID,APP_ID)
)
/

CREATE SEQUENCE APM_FAVOURITE_APPS_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_FAVOURITE_APPS_TRIGGER
    BEFORE INSERT
    ON APM_FAVOURITE_APPS
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_FAVOURITE_APPS_SEQUENCE.nextval INTO :NEW.ID FROM dual;
    END;
/

CREATE TABLE APM_STORE_FAVOURITE_PAGE (
   ID INTEGER ,
   USER_ID VARCHAR(50) NOT NULL,
   TENANT_ID_OF_USER INTEGER NOT NULL,
   TENANT_ID_OF_STORE INTEGER NOT NULL,
   PRIMARY KEY (ID)
)
/

CREATE SEQUENCE APM_STORE_FAVOURITE_PAGE_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APM_STORE_FAVOURITE_PAGE_TRIGGER
    BEFORE INSERT
    ON APM_STORE_FAVOURITE_PAGE
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT APM_STORE_FAVOURITE_PAGE_SEQUENCE.nextval INTO :NEW.ID FROM dual;
    END;
/


INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY, IS_GLOBAL )
VALUES ('Reverse Proxy Handler','org.wso2.carbon.appmgt.gateway.handlers.proxy.ReverseProxyHandler','',1,1,1)
/
 
INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY,IS_GLOBAL)
VALUES ('SAML2 Authentication Handler','org.wso2.carbon.appmgt.gateway.handlers.security.saml2.SAML2AuthenticationHandler','',2,1,1)
/

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY,IS_GLOBAL)
VALUES ('Entitlement Handler','org.wso2.carbon.appmgt.gateway.handlers.security.entitlement.EntitlementHandler','',3,1,1)
/

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY, POLICY_PROPERTIES,IS_GLOBAL )
VALUES ('API Throttle Handler','org.wso2.carbon.appmgt.gateway.handlers.throttling.APIThrottleHandler','',4,1,'{ "id": "A",  "policyKey": "gov:/appmgt/applicationdata/tiers.xml"}',1)
/

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY,IS_GLOBAL)
VALUES ('Publish Statistics:','org.wso2.carbon.appmgt.usage.publisher.APPMgtUsageHandler','',5,0,1)
/


