-- -----------------------------------
-- Athena Database script
-- Important: Execute this script after creating the SpagoBI Tables
-- ------------------------------------


-- tables for different athena product types
CREATE TABLE SBI_PRODUCT_TYPE (
	PRODUCT_TYPE_ID INTEGER NOT NULL,
	LABEL VARCHAR2(40) NOT NULL,
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
	PRIMARY KEY(PRODUCT_TYPE_ID),
	CONSTRAINT XAK1SBI_PRODUCT_TYPE UNIQUE(LABEL, ORGANIZATION)
);

-- mapping table between organizations (tenants) and product types
CREATE TABLE SBI_ORGANIZATION_PRODUCT_TYPE (
	PRODUCT_TYPE_ID INTEGER NOT NULL,
	ORGANIZATION_ID INTEGER NOT NULL,
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
	PRIMARY KEY(PRODUCT_TYPE_ID, ORGANIZATION_ID),
	CONSTRAINT FK_PRODUCT_TYPE_1 FOREIGN KEY (PRODUCT_TYPE_ID) REFERENCES SBI_PRODUCT_TYPE (PRODUCT_TYPE_ID) ON DELETE CASCADE,
	CONSTRAINT FK_ORGANIZATION_3 FOREIGN KEY (ORGANIZATION_ID) REFERENCES SBI_ORGANIZATIONS (ID) ON DELETE CASCADE
);




-- create: GLOSSARY tables
CREATE TABLE SBI_GL_WORD (
	WORD_ID INTEGER NOT NULL ,
	WORD VARCHAR2 (100),
	DESCR VARCHAR2 (500),
	FORMULA VARCHAR2 (500),
	STATE INTEGER DEFAULT NULL,
	CATEGORY INTEGER DEFAULT NULL,
	
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
	PRIMARY KEY(WORD_ID),
  	CONSTRAINT CATEGORY FOREIGN KEY (CATEGORY) REFERENCES SBI_DOMAINS (VALUE_ID) ON DELETE CASCADE,
  	CONSTRAINT STATE FOREIGN KEY (STATE) REFERENCES SBI_DOMAINS (VALUE_ID) ON DELETE CASCADE
) ;

CREATE TABLE SBI_GL_ATTRIBUTES (
	ATTRIBUTE_ID INTEGER NOT NULL ,
	ATTRIBUTE_CD VARCHAR2 (30),
	ATTRIBUTE_NM VARCHAR2 (100),
	ATTRIBUTE_DS VARCHAR2 (500),
	MANDATORY_FL INTEGER,
	ATTRIBUTES_TYPE VARCHAR2 (50),
	DOMAIN VARCHAR2 (500),
	FORMAT VARCHAR2 (30),
	DISPLAY_TP VARCHAR2 (30),
	ATTRIBUTES_ORDER VARCHAR2 (30),
	
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
PRIMARY KEY(ATTRIBUTE_ID) 
);

CREATE TABLE SBI_GL_WORD_ATTR (
	WORD_ID INTEGER NOT NULL ,
	ATTRIBUTE_ID INTEGER NOT NULL ,
	ATTR_VALUE VARCHAR2 (500),
	ATTR_ORDER INTEGER,
	
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
PRIMARY KEY(WORD_ID,ATTRIBUTE_ID) 
);

CREATE TABLE SBI_GL_REFERENCES (
	WORD_ID INTEGER NOT NULL ,
	REF_WORD_ID INTEGER NOT NULL ,
	REFERENCES_ORDER INTEGER,
	
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
PRIMARY KEY(WORD_ID,REF_WORD_ID) 
);

CREATE TABLE SBI_GL_GLOSSARY (
	GLOSSARY_ID INTEGER NOT NULL ,
	GLOSSARY_CD VARCHAR2 (30),
	GLOSSARY_NM VARCHAR2 (100),
	GLOSSARY_DS VARCHAR2 (500),
	
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
PRIMARY KEY(GLOSSARY_ID) 
);

CREATE TABLE SBI_GL_CONTENTS (
	CONTENT_ID INTEGER NOT NULL ,
	GLOSSARY_ID INTEGER NOT NULL ,
	PARENT_ID INTEGER,
	CONTENT_CD VARCHAR2 (30),
	CONTENT_NM VARCHAR2 (100),
	CONTENT_DS VARCHAR2 (500),
	DEPTH INTEGER,
	
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
PRIMARY KEY(CONTENT_ID) 
) ;

CREATE TABLE SBI_GL_WLIST (
	CONTENT_ID INTEGER NOT NULL ,
	WORD_ID INTEGER NOT NULL ,
	WORD_ORDER INTEGER,
	
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
PRIMARY KEY(CONTENT_ID,WORD_ID) 
);

CREATE TABLE SBI_PRODUCT_TYPE_ENGINE (
	PRODUCT_TYPE_ID INTEGER NOT NULL,
	ENGINE_ID INTEGER NOT NULL,
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
	PRIMARY KEY (PRODUCT_TYPE_ID, ENGINE_ID)
);

CREATE TABLE SBI_IMAGES (
  IMAGE_ID INTEGER NOT NULL,
  NAME VARCHAR2(100) NOT NULL,
  CONTENT BLOB NOT NULL,
  CONTENT_ICO blob,
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
  PRIMARY KEY (IMAGE_ID),
  CONSTRAINT XAK1SBI_IMAGES UNIQUE(NAME)
);


CREATE TABLE SBI_GL_DOCWLIST (
	WORD_ID INTEGER NOT NULL,
	BIOBJ_ID INTEGER NOT NULL,
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
  PRIMARY KEY (BIOBJ_ID, WORD_ID),
  CONSTRAINT WORD_ID FOREIGN KEY (WORD_ID) REFERENCES SBI_GL_WORD (WORD_ID) ON DELETE CASCADE,
  CONSTRAINT DOCUMENT_ID FOREIGN KEY (BIOBJ_ID) REFERENCES SBI_OBJECTS (BIOBJ_ID) ON DELETE CASCADE
);

CREATE TABLE SBI_GL_DATASETWLIST (
   WORD_ID INTEGER NOT NULL,
   DS_ID INTEGER NOT NULL,
   COLUMN_NAME VARCHAR2(100) NOT NULL,
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
   VERSION_NUM INTEGER DEFAULT NULL,
   PRIMARY KEY (WORD_ID,DS_ID,COLUMN_NAME),
  -- KEY DATASET_IDX (`DS_ID`),
  -- KEY ORGANIZATION_IDX (`ORGANIZATION`),
  -- CONSTRAINT DATASET FOREIGN KEY (DS_ID) REFERENCES SBI_DATA_SET (DS_ID) ON DELETE CASCADE,
   CONSTRAINT WORD FOREIGN KEY (WORD_ID) REFERENCES SBI_GL_WORD (WORD_ID) ON DELETE CASCADE
 ) ;

CREATE TABLE SBI_GL_TABLE (
  TABLE_ID INTEGER NOT NULL,
  LABEL VARCHAR2(100) NOT NULL, 
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
  PRIMARY KEY (TABLE_ID)
);

CREATE TABLE SBI_GL_BNESS_CLS (
  BC_ID INTEGER NOT NULL,
  DATAMART_NAME VARCHAR2(100) NOT NULL,
  UNIQUE_IDENTIFIER VARCHAR2(100) NOT NULL,
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
  PRIMARY KEY (BC_ID)
) ;




CREATE TABLE SBI_GL_BNESS_CLS_WLIST (
  WORD_ID INTEGER NOT NULL,
  BC_ID INTEGER NOT NULL,
  COLUMN_NAME VARCHAR2(100) DEFAULT NULL,
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
  PRIMARY KEY (BC_ID,WORD_ID),
 -- KEY WORDID (`WORD_ID`),
  CONSTRAINT BCID FOREIGN KEY (BC_ID) REFERENCES SBI_GL_BNESS_CLS (BC_ID) ON DELETE CASCADE,
  CONSTRAINT WORDID FOREIGN KEY (WORD_ID) REFERENCES SBI_GL_WORD (WORD_ID) ON DELETE CASCADE
);

CREATE TABLE SBI_GL_TABLE_WLIST (
  WORD_ID INTEGER NOT NULL,
  TABLE_ID INTEGER NOT NULL,
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
  PRIMARY KEY (TABLE_ID,WORD_ID),
   CONSTRAINT TABLEID FOREIGN KEY (TABLE_ID) REFERENCES SBI_GL_TABLE (TABLE_ID) ON DELETE CASCADE,
  CONSTRAINT WORDIDT FOREIGN KEY (WORD_ID) REFERENCES SBI_GL_WORD (WORD_ID) ON DELETE CASCADE
) ;


CREATE TABLE SBI_WS_EVENT (
  ID INTEGER NOT NULL,
  EVENT_NAME VARCHAR2(45) NOT NULL UNIQUE,
  IP_COME_FROM VARCHAR2(15) NULL,
  INCOMING_DATE DATE NULL,
  TAKE_CHARGE_DATE DATE NULL,
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
  PRIMARY KEY (id)
);


CREATE TABLE SBI_FEDERATION_DEFINITION (
	   FEDERATION_ID 		INTEGER NOT NULL,
  	   LABEL 				VARCHAR2(100) DEFAULT NULL,
       NAME 				VARCHAR2(100) DEFAULT NULL,
       DESCRIPTION 			VARCHAR2(100) DEFAULT NULL,
       RELATIONSHIPS 		BLOB,
	USER_IN              VARCHAR2(100) NOT NULL,
    USER_UP              VARCHAR2(100),
    USER_DE              VARCHAR2(100),
    TIME_IN              TIMESTAMP NOT NULL,
    TIME_UP              TIMESTAMP DEFAULT NULL,    
    TIME_DE              TIMESTAMP DEFAULT NULL,
    SBI_VERSION_IN       VARCHAR2(10),
    SBI_VERSION_UP       VARCHAR2(10),
    SBI_VERSION_DE       VARCHAR2(10),
    META_VERSION         VARCHAR2(100),
    ORGANIZATION         VARCHAR2(20),
  	   PRIMARY KEY (FEDERATION_ID)
) ;

CREATE TABLE SBI_DATA_SET_FEDERATION (
       FEDERATION_ID 		INTEGER NOT NULL,
       DS_ID 				INTEGER NOT NULL,
       VERSION_NUM 			INTEGER NOT NULL,
       ORGANIZATION 		VARCHAR2(20) NOT NULL,
       PRIMARY KEY (FEDERATION_ID,DS_ID,VERSION_NUM,ORGANIZATION)       
) ;

-- modify sbi_user_func with product_id fk 
ALTER TABLE SBI_USER_FUNC ADD PRODUCT_TYPE_ID INTEGER NOT NULL;
-- modify sbi_authorization with product_id fk
ALTER TABLE SBI_AUTHORIZATIONS ADD PRODUCT_TYPE_ID INTEGER NOT NULL;

-- Create Foreign keys section

ALTER TABLE SBI_GL_WORD_ATTR ADD FOREIGN KEY (WORD_ID) REFERENCES SBI_GL_WORD (WORD_ID);

ALTER TABLE SBI_GL_REFERENCES ADD FOREIGN KEY (WORD_ID) REFERENCES SBI_GL_WORD (WORD_ID);

ALTER TABLE SBI_GL_REFERENCES ADD FOREIGN KEY (REF_WORD_ID) REFERENCES SBI_GL_WORD (WORD_ID);

ALTER TABLE SBI_GL_WLIST ADD FOREIGN KEY (WORD_ID) REFERENCES SBI_GL_WORD (WORD_ID);

ALTER TABLE SBI_GL_WORD_ATTR ADD FOREIGN KEY (ATTRIBUTE_ID) REFERENCES SBI_GL_ATTRIBUTES (ATTRIBUTE_ID);

ALTER TABLE SBI_GL_CONTENTS ADD FOREIGN KEY (GLOSSARY_ID) REFERENCES SBI_GL_GLOSSARY (GLOSSARY_ID);

ALTER TABLE SBI_GL_CONTENTS ADD FOREIGN KEY (PARENT_ID) REFERENCES SBI_GL_CONTENTS (CONTENT_ID);

ALTER TABLE SBI_GL_WLIST ADD FOREIGN KEY (CONTENT_ID) REFERENCES SBI_GL_CONTENTS (CONTENT_ID);
	
ALTER TABLE SBI_PRODUCT_TYPE_ENGINE ADD CONSTRAINT FK_PRODUCT_TYPE_2 FOREIGN KEY (PRODUCT_TYPE_ID) REFERENCES SBI_PRODUCT_TYPE (PRODUCT_TYPE_ID) ON DELETE CASCADE;

ALTER TABLE SBI_PRODUCT_TYPE_ENGINE ADD CONSTRAINT FK_ENGINE_2 FOREIGN KEY (ENGINE_ID) REFERENCES SBI_ENGINES (ENGINE_ID) ON DELETE CASCADE;

ALTER TABLE SBI_USER_FUNC ADD CONSTRAINT FK_PRODUCT_TYPE FOREIGN KEY (PRODUCT_TYPE_ID) REFERENCES SBI_PRODUCT_TYPE (PRODUCT_TYPE_ID) ON DELETE CASCADE;

ALTER TABLE SBI_AUTHORIZATIONS ADD CONSTRAINT FK2_PRODUCT_TYPE FOREIGN KEY (PRODUCT_TYPE_ID) REFERENCES SBI_PRODUCT_TYPE (PRODUCT_TYPE_ID) ON DELETE CASCADE;

ALTER TABLE SBI_DATA_SET_FEDERATION ADD CONSTRAINT FK_SBI_DATA_SET_FED FOREIGN KEY (FEDERATION_ID) REFERENCES SBI_FEDERATION_DEFINITION (FEDERATION_ID) ON DELETE CASCADE;

ALTER TABLE SBI_DATA_SET_FEDERATION ADD CONSTRAINT FK_SBI_DATA_SET_FED2 FOREIGN KEY (DS_ID, VERSION_NUM, ORGANIZATION) REFERENCES SBI_DATA_SET (DS_ID, VERSION_NUM,ORGANIZATION) ON DELETE CASCADE;

ALTER TABLE SBI_DATA_SET ADD COLUMN FEDERATION_ID INTEGER NULL DEFAULT NULL  AFTER SCOPE_ID ;

ALTER TABLE SBI_DATA_SET ADD CONSTRAINT FK_SBI_FEDERATION  FOREIGN KEY (FEDERATION_ID )  REFERENCES SBI_FEDERATION_DEFINITION (FEDERATION_ID)  ON DELETE NO ACTION ON UPDATE NO ACTION;
    

CREATE INDEX FK_ORGANIZATION_3 ON SBI_ORGANIZATION_PRODUCT_TYPE(ORGANIZATION_ID);
CREATE INDEX STATE_IDX ON SBI_GL_WORD(STATE);
CREATE INDEX CATEGORY_IDX ON SBI_GL_WORD(CATEGORY);
CREATE INDEX WORD_ID_idx ON SBI_GL_DOCWLIST(WORD_ID);
CREATE INDEX DATASET_IDX ON SBI_GL_DATASETWLIST(DS_ID);
CREATE INDEX ORGANIZATION_IDX ON SBI_GL_DATASETWLIST(ORGANIZATION);
CREATE INDEX WORDID ON SBI_GL_BNESS_CLS_WLIST(WORD_ID);


