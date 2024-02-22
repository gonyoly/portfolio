GO
CREATE DATABASE BibleWoIsWhoDB
GO
Use BibleWoIsWhoDB
GO
CREATE TABLE Persons
			(
			person_sequence INT IDENTITY
			,person_id VARCHAR(30) CONSTRAINT prsns_prsnid_pk PRIMARY KEY
			,person_name VARCHAR (20) NOT NULL
			,unique_attribute VARCHAR (100) NOT NULL
			,sex VARCHAR (6) NOT NULL
			,tribe VARCHAR (15)
			,person_notes VARCHAR
			,name_instance INT CONSTRAINT prsns_instnc_ck CHECK(name_instance BETWEEN 1 AND 23)
			,CONSTRAINT prsns_sex_ck CHECK(sex LIKE 'male' 
										OR sex LIKE 'female')
			)
GO
CREATE TABLE Reference
			(
			verse_sequence INT IDENTITY
			,reference_id VARCHAR (20) CONSTRAINT refs_refid_pk PRIMARY KEY
			,book_id INT NOT NULL 
			,usx_code VARCHAR (3) NOT NULL 
			,chapter INT NOT NULL 
			,verse INT NOT NULL 
			,CONSTRAINT refs_bookid_ck  CHECK(book_id BETWEEN 1 AND 66)
			,CONSTRAINT refs_chapter_ck CHECK(chapter BETWEEN 1 AND 150)
			,CONSTRAINT refs_verse_ck CHECK(verse BETWEEN 1 AND 176)
			)
GO
CREATE TABLE PersonLabels
			(
			label_sequence INT IDENTITY
			,person_label_id VARCHAR (30) CONSTRAINT prsnlbl_prsnlblid_pk PRIMARY KEY
			,person_id VARCHAR(30) NOT NULL
			,english_label VARCHAR(30) NOT NULL
			,hebrew_label NVARCHAR(40) NOT NULL --actually, there are a few blanks in the corresponding excel column, but ideally they should have been filled up
			,hebrew_label_transliterated VARCHAR(40) NOT NULL --actually, there are a few blanks in the corresponding excel column, but ideally they should have been filled up
			,hebrew_label_meaning VARCHAR(100)
			,greek_label NVARCHAR(40) NOT NULL --actually, there are a few blanks in the corresponding excel column, but ideally they should have been filled up
			,greek_label_transliterated VARCHAR(40) NOT NULL --actually, there are a few blanks in the corresponding excel column, but ideally they should have been filled up
			,greek_label_meaning VARCHAR(100)
			,label_reference_id VARCHAR(20) NOT NULL
			,label_type VARCHAR(11) NOT NULL
			,label_notes NVARCHAR (300)
			,person_label_count INT NOT NULL
			,CONSTRAINT prsnlbl_prsnid_fk FOREIGN KEY (person_id) REFERENCES Persons(person_id)
			,CONSTRAINT prsnlbl_lblrefid_fk FOREIGN KEY (label_reference_id) REFERENCES Reference(reference_id)
			,CONSTRAINT prsnlbl_lbltype_ck CHECK(label_type LIKE 'title' 
												OR label_type LIKE 'proper name'
												OR label_type LIKE 'description')
			,CONSTRAINT prsnlbl_prsnlblcnt_ck CHECK(person_label_count BETWEEN 1 AND 169)
			)
			GO
CREATE TABLE PersonVerse
			(
			person_verse_sequence INT IDENTITY
			,person_verse_id VARCHAR (40)  CONSTRAINT prsnvrs_prsnvrsid_pk PRIMARY KEY
			,reference_id VARCHAR(20) NOT NULL
			,person_label_id VARCHAR (30) CONSTRAINT prsnvrs_prsnlblid_fk REFERENCES PersonLabels(person_label_id)
			,person_id VARCHAR(30) NOT NULL
			,person_label VARCHAR (60)
			,person_label_count INT CONSTRAINT prsnvrs_prsnlblcnt_ck CHECK(person_label_count BETWEEN 1 AND 5)
			,person_verse_notes VARCHAR
			,CONSTRAINT prsnvrs_refid_fk FOREIGN KEY (reference_id) REFERENCES Reference(reference_id)
			,CONSTRAINT prsnvrs_prsnid_fk FOREIGN KEY (person_id) REFERENCES Persons(person_id)
			)
			GO
CREATE TABLE PersonRelationship
			(
			person_relationship_sequence  INT IDENTITY
			,person_relationship_id VARCHAR (50)  CONSTRAINT prsnrltnshp_prsnrltnshpid_pk PRIMARY KEY
			,person_id_1 VARCHAR(30) NOT NULL
			,relationship_type VARCHAR(30) NOT NULL
			,person_id_2 VARCHAR(30) NOT NULL
			,relationship_category VARCHAR(8) NOT NULL
			,reference_id  VARCHAR(20) NOT NULL
			,relationship_notes VARCHAR
			,CONSTRAINT prsnrltnshp_rltnshpcat_ck CHECK(relationship_category LIKE 'explicit' OR 
														relationship_category LIKE 'implicit' OR 
														relationship_category LIKE 'inferred')
			,CONSTRAINT prsnrltnshp_prsnid1_fk FOREIGN KEY (person_id_1) REFERENCES Persons(person_id)
			,CONSTRAINT prsnrltnshp_prsnid2_fk FOREIGN KEY (person_id_2) REFERENCES Persons(person_id)
			,CONSTRAINT prsnrltnshp_refid_fk FOREIGN KEY (reference_id) REFERENCES Reference(reference_id)
			)
			GO
CREATE TABLE [Events]
			(
			event_sequence  INT IDENTITY
			,event_id VARCHAR (50) CONSTRAINT event_eventid_pk PRIMARY KEY
			,event_label VARCHAR (70) NOT NULL
			,event_description VARCHAR (300)
			,event_type VARCHAR(12) NOT NULL
			,person_id VARCHAR(30) CONSTRAINT event_prsnid_fk REFERENCES Persons(person_id)
			,event_year_ah INT CONSTRAINT event_eventyyah_ck CHECK(event_year_ah BETWEEN 1 AND 4108) --the last possibly relevant event in Paul's life (his travel from Spain(?) to Asia, 66 AD ~ 4108 AH), 
			,person_age_at_event INT CONSTRAINT event_prsnsage_ck CHECK(person_age_at_event BETWEEN 0 AND 969)
			,event_year_offset INT --the number of years used in the event_year_calculation column, both positives and negatives
			,event_year_calculation VARCHAR (300)
			,event_reference_id VARCHAR (20) --NOT NULL --actually, the excel table is defined 'at work', and ideally all blanks in this column are to be filled up = which is, however, not the case by now
			,event_location VARCHAR (20)
			,event_location_reference_id VARCHAR(20) CONSTRAINT event_evlocid_fk REFERENCES Reference(reference_id)
			,event_notes VARCHAR (300)
			,CONSTRAINT event_eventtype_ck CHECK (event_type LIKE 'Battle'
																	OR event_type LIKE 'Birth'
																	OR event_type LIKE 'Bondage'
																	OR event_type LIKE 'Construction'
																	OR event_type LIKE 'Covenant'
																	OR event_type LIKE 'Death'
																	OR event_type LIKE 'Destruction'
																	OR event_type LIKE 'Freedom'
																	OR event_type LIKE 'Judgeship'
																	OR event_type LIKE 'Marriage'
																	OR event_type LIKE 'Meeting'
																	OR event_type LIKE 'Message'
																	OR event_type LIKE 'Promise'
																	OR event_type LIKE 'Reign'
																	OR event_type LIKE 'Travel'
																	OR event_type LIKE 'Unique'
																	OR event_type LIKE 'Vision')
			,CONSTRAINT event_eventrefid_fk FOREIGN KEY (event_reference_id) REFERENCES Reference(reference_id)
			)
			GO
CREATE TABLE Epochs
			(
			epoch_sequence  INT IDENTITY
			,epoch_id VARCHAR (50) CONSTRAINT epoch_epochid_pk PRIMARY KEY
			,epoch_name VARCHAR (50) NOT NULL
			,epoch_description VARCHAR (500) NOT NULL
			,epoch_type VARCHAR(12) NOT NULL
			,person_id VARCHAR(30) CONSTRAINT epoch_prsnid_fk REFERENCES Persons(person_id)
			,start_year_ah INT CONSTRAINT epoch_epochstrtyyah_ck CHECK(start_year_ah BETWEEN 1 AND 4112) -- ~70 AD, destr. of 2nd temple
			,end_year_ah INT CONSTRAINT epoch_epochendyyah_ck CHECK(end_year_ah BETWEEN 931 AND 4112)
			,period_length INT CONSTRAINT epoch_prdlngth_ck CHECK(period_length BETWEEN 1 AND 969)
			,start_year_calculation VARCHAR (300)
			,start_year_offset INT --ditto
			,start_year_reference_id VARCHAR(20) CONSTRAINT epoch_strtyyrefid_fk REFERENCES Reference(reference_id)
			,end_year_calculation VARCHAR (300)
			,end_year_reference_id VARCHAR(20) CONSTRAINT epoch_endyyrefid_fk REFERENCES Reference(reference_id)
			,period_length_reference_id VARCHAR(20) CONSTRAINT epoch_prdlngthrefid_fk REFERENCES Reference(reference_id)
			,epoch_notes VARCHAR (300)
			,CONSTRAINT epoch_epochtype_ck CHECK (epoch_type LIKE 'Battle'
												OR epoch_type LIKE 'Bondage'
												OR epoch_type LIKE 'Captivity'
												OR epoch_type LIKE 'Construction'
												OR epoch_type LIKE 'Destruction'
												OR epoch_type LIKE 'Exile'
												OR epoch_type LIKE 'Judge'
												OR epoch_type LIKE 'Life'
												OR epoch_type LIKE 'Message'
												OR epoch_type LIKE 'Period'
												OR epoch_type LIKE 'Prophet'
												OR epoch_type LIKE 'Rebellion'
												OR epoch_type LIKE 'Reign'
												OR epoch_type LIKE 'Travel'
												OR epoch_type LIKE 'Unique'
												OR epoch_type LIKE 'Vision')
			)
			GO
INSERT INTO Persons (person_id, person_name, unique_attribute, sex, tribe, person_notes, name_instance)
VALUES
('Yhvh_1',	'Elohim',	'Holy, Holy, Holy (ISA 6:3) and many others',	'male',	NULL,	NULL,	1)
,('Yhvh_2',	'Yhvh Elohim',	'Holy, Holy, Holy (ISA 6:3) and many others',	'male',	NULL,	NULL,	2)
,('Yhvh_3',	'Yhvh',	'Holy, Holy, Holy (ISA 6:3) and many others',	'male',	NULL,	NULL,	3)
,('Adam_1',	'Adam',	'first man (1CO 15:45)',	'male',	NULL,	NULL,	1)
,('Eve_1',	'Eve',	'first woman, created from Adam (Gen 2:22)',	'female',	NULL,	NULL,	1)
,('Cain_1',	'Cain',	'first son of Adam (GEN 4:1), cursed from the ground (GEN 4:11)',	'male',	NULL,	NULL,	1)
,('Abel_1',	'Abel',	'son of Adam(GEN 4:2), first person murdered (GEN 4:8)',	'male',	NULL,	NULL,	1)
,('Enoch_1',	'Enoch',	'son of Cain (GEN 4:17)',	'male',	NULL,	NULL,	1)
,('Irad_1',	'Irad',	'son of Enoch (GEN 4:18)',	'male',	NULL,	NULL,	1)
,('Mehujael_1',	'Mehujael',	'son of Irad (GEN 4:18)',	'male',	NULL,	NULL,	1)
,('Methushael_1',	'Methushael',	'son of Mehujael (GEN 4:18)',	'male',	NULL,	NULL,	1)
,('Lamech_1',	'Lamech',	'son of Methushael (GEN 4:18)',	'male',	NULL,	NULL,	1)
,('Adah_1',	'Adah',	'wife of Lamech (GEN 4:19)',	'female',	NULL,	NULL,	1)
,('Zillah_1',	'Zillah',	'wife of Lamech (GEN 4:19)',	'female',	NULL,	NULL,	1)
,('Jabal_1',	'Jabal',	'father of those who dwell in tents and have livestock (GEN 4:20)',	'male',	NULL,	NULL,	1)
,('Jubal_1',	'Jubal',	'father of all those who play the lyre and pipe (GEN 4:21)',	'male',	NULL,	NULL,	1)
,('Tubal-cain_1',	'Tubal-cain',	'the forger of all implements of bronze and iron (GEN 4:22)',	'male',	NULL,	NULL,	1)
,('Naamah_1',	'Naamah',	'sister of Tubal-cain (GEN 4:22)',	'female',	NULL,	NULL,	1)
,('Seth_1',	'Seth',	'son of Adam (GEN 4:25)',	'male',	NULL,	NULL,	1)
,('Enosh_1',	'Enosh',	'son of Seth (GEN 4:26)',	'male',	NULL,	NULL,	1)
,('Kenan_1',	'Kenan',	'son of Enosh (GEN 5:9)',	'male',	NULL,	NULL,	1)
,('Mahalalel_1',	'Mahalalel',	'son of Kenan (GEN 5:12)',	'male',	NULL,	NULL,	1)
,('Jared_1',	'Jared',	'son of Mahalael (GEN 5:12)',	'male',	NULL,	NULL,	1)
,('Enoch_2',	'Enoch',	'son of Jared (GEN 5:18)',	'male',	NULL,	NULL,	2)
,('Methuselah_1',	'Methuselah',	'son of Enoch (GEN 5:21)',	'male',	NULL,	NULL,	1)
,('Lamech_2',	'Lamech',	'son of Methuselah (GEN 5:25)',	'male',	NULL,	NULL,	2)
			GO
INSERT INTO Reference (reference_id, book_id, usx_code, chapter, verse)
VALUES
('GEN 1:1',	1,	'GEN',	1,	1)
,('GEN 1:2',	1,	'GEN',	1,	2)
,('GEN 1:3',	1,	'GEN',	1,	3)
,('GEN 1:4',	1,	'GEN',	1,	4)
,('GEN 1:5',	1,	'GEN',	1,	5)
,('GEN 1:6',	1,	'GEN',	1,	6)
,('GEN 1:7',	1,	'GEN',	1,	7)
,('GEN 1:8',	1,	'GEN',	1,	8)
,('GEN 1:9',	1,	'GEN',	1,	9)
,('GEN 1:10',	1,	'GEN',	1,	10)
,('GEN 1:11',	1,	'GEN',	1,	11)
,('GEN 1:12',	1,	'GEN',	1,	12)
,('GEN 1:13',	1,	'GEN',	1,	13)
,('GEN 1:14',	1,	'GEN',	1,	14)
,('GEN 1:15',	1,	'GEN',	1,	15)
,('GEN 1:16',	1,	'GEN',	1,	16)
,('GEN 1:17',	1,	'GEN',	1,	17)
,('GEN 1:18',	1,	'GEN',	1,	18)
,('GEN 1:19',	1,	'GEN',	1,	19)
,('GEN 1:20',	1,	'GEN',	1,	20)
,('GEN 1:21',	1,	'GEN',	1,	21)
,('GEN 1:22',	1,	'GEN',	1,	22)
,('GEN 1:23',	1,	'GEN',	1,	23)
,('GEN 1:24',	1,	'GEN',	1,	24)
,('GEN 1:25',	1,	'GEN',	1,	25)
,('GEN 1:26',	1,	'GEN',	1,	26)
,('GEN 1:27',	1,	'GEN',	1,	27)
,('GEN 1:28',	1,	'GEN',	1,	28)
,('GEN 1:29',	1,	'GEN',	1,	29)
,('GEN 1:30',	1,	'GEN',	1,	30)
,('GEN 1:31',	1,	'GEN',	1,	31)
,('GEN 2:1',	1,	'GEN',	2,	1 )
,('GEN 2:2',	1,	'GEN',	2,	2 )
,('GEN 2:3',	1,	'GEN',	2,	3 )
,('GEN 2:4',	1,	'GEN',	2,	4 )
,('GEN 2:5',	1,	'GEN',	2,	5 )
,('GEN 2:6',	1,	'GEN',	2,	6 )
,('GEN 2:7',	1,	'GEN',	2,	7 )
,('GEN 2:8',	1,	'GEN',	2,	8 )
,('GEN 2:9',	1,	'GEN',	2,	9 )
,('GEN 2:10',	1,	'GEN',	2,	10)
,('GEN 2:11',	1,	'GEN',	2,	11)
,('GEN 2:12',	1,	'GEN',	2,	12)
,('GEN 2:13',	1,	'GEN',	2,	13)
,('GEN 2:14',	1,	'GEN',	2,	14)
,('GEN 2:15',	1,	'GEN',	2,	15)
,('GEN 2:16',	1,	'GEN',	2,	16)
,('GEN 2:17',	1,	'GEN',	2,	17)
,('GEN 2:18',	1,	'GEN',	2,	18)
,('GEN 2:19',	1,	'GEN',	2,	19)
,('GEN 2:20',	1,	'GEN',	2,	20)
,('GEN 2:21',	1,	'GEN',	2,	21)
,('GEN 2:22',	1,	'GEN',	2,	22)
,('GEN 2:23',	1,	'GEN',	2,	23)
,('GEN 2:24',	1,	'GEN',	2,	24)
,('GEN 2:25',	1,	'GEN',	2,	25)
,('GEN 3:1',	1,	'GEN',	3,	1 )
,('GEN 3:2',	1,	'GEN',	3,	2 )
,('GEN 3:3',	1,	'GEN',	3,	3 )
,('GEN 3:4',	1,	'GEN',	3,	4 )
,('GEN 3:5',	1,	'GEN',	3,	5 )
,('GEN 3:6',	1,	'GEN',	3,	6 )
,('GEN 3:7',	1,	'GEN',	3,	7 )
,('GEN 3:8',	1,	'GEN',	3,	8 )
,('GEN 3:9',	1,	'GEN',	3,	9 )
,('GEN 3:10',	1,	'GEN',	3,	10)
,('GEN 3:11',	1,	'GEN',	3,	11)
,('GEN 3:12',	1,	'GEN',	3,	12)
,('GEN 3:13',	1,	'GEN',	3,	13)
,('GEN 3:14',	1,	'GEN',	3,	14)
,('GEN 3:15',	1,	'GEN',	3,	15)
,('GEN 3:16',	1,	'GEN',	3,	16)
,('GEN 3:17',	1,	'GEN',	3,	17)
,('GEN 3:18',	1,	'GEN',	3,	18)
,('GEN 3:19',	1,	'GEN',	3,	19)
,('GEN 3:20',	1,	'GEN',	3,	20)
,('GEN 3:21',	1,	'GEN',	3,	21)
,('GEN 3:22',	1,	'GEN',	3,	22)
,('GEN 3:23',	1,	'GEN',	3,	23)
,('GEN 3:24',	1,	'GEN',	3,	24)
,('GEN 4:1',	1,	'GEN',	4,	1 )
,('GEN 4:2',	1,	'GEN',	4,	2 )
,('GEN 4:3',	1,	'GEN',	4,	3 )
,('GEN 4:4',	1,	'GEN',	4,	4 )
,('GEN 4:5',	1,	'GEN',	4,	5 )
,('GEN 4:6',	1,	'GEN',	4,	6 )
,('GEN 4:7',	1,	'GEN',	4,	7 )
,('GEN 4:8',	1,	'GEN',	4,	8 )
,('GEN 4:9',	1,	'GEN',	4,	9 )
,('GEN 4:10',	1,	'GEN',	4,	10)
,('GEN 4:11',	1,	'GEN',	4,	11)
,('GEN 4:12',	1,	'GEN',	4,	12)
,('GEN 4:13',	1,	'GEN',	4,	13)
,('GEN 4:14',	1,	'GEN',	4,	14)
,('GEN 4:15',	1,	'GEN',	4,	15)
,('GEN 4:16',	1,	'GEN',	4,	16)
,('GEN 4:17',	1,	'GEN',	4,	17)
,('GEN 4:18',	1,	'GEN',	4,	18)
,('GEN 4:19',	1,	'GEN',	4,	19)
,('GEN 4:20',	1,	'GEN',	4,	20)
,('GEN 4:21',	1,	'GEN',	4,	21)
,('GEN 4:22',	1,	'GEN',	4,	22)
,('GEN 4:23',	1,	'GEN',	4,	23)
,('GEN 4:24',	1,	'GEN',	4,	24)
,('GEN 4:25',	1,	'GEN',	4,	25)
,('GEN 4:26',	1,	'GEN',	4,	26)
,('GEN 5:1',	1,	'GEN',	5,	1 )
,('GEN 5:2',	1,	'GEN',	5,	2 )
,('GEN 5:3',	1,	'GEN',	5,	3 )
,('GEN 5:4',	1,	'GEN',	5,	4 )
,('GEN 5:5',	1,	'GEN',	5,	5 )
,('GEN 5:6',	1,	'GEN',	5,	6 )
,('GEN 5:7',	1,	'GEN',	5,	7 )
,('GEN 5:8',	1,	'GEN',	5,	8 )
,('GEN 5:9',	1,	'GEN',	5,	9 )
,('GEN 5:10',	1,	'GEN',	5,	10)
,('GEN 5:11',	1,	'GEN',	5,	11)
,('GEN 5:12',	1,	'GEN',	5,	12)
,('GEN 5:13',	1,	'GEN',	5,	13)
,('GEN 5:14',	1,	'GEN',	5,	14)
,('GEN 5:15',	1,	'GEN',	5,	15)
,('GEN 5:16',	1,	'GEN',	5,	16)
,('GEN 5:17',	1,	'GEN',	5,	17)
,('GEN 5:18',	1,	'GEN',	5,	18)
,('GEN 5:19',	1,	'GEN',	5,	19)
,('GEN 5:20',	1,	'GEN',	5,	20)
,('GEN 5:21',	1,	'GEN',	5,	21)
,('GEN 5:22',	1,	'GEN',	5,	22)
,('GEN 5:23',	1,	'GEN',	5,	23)
,('GEN 5:24',	1,	'GEN',	5,	24)
,('GEN 5:25',	1,	'GEN',	5,	25)
,('GEN 5:26',	1,	'GEN',	5,	26)
,('GEN 5:27',	1,	'GEN',	5,	27)
,('GEN 5:28',	1,	'GEN',	5,	28)
,('GEN 5:29',	1,	'GEN',	5,	29)
,('GEN 5:30',	1,	'GEN',	5,	30)
,('GEN 5:31',	1,	'GEN',	5,	31)
,('GEN 5:32',	1,	'GEN',	5,	32)
,('GEN 6:1',	1,	'GEN',	6,	1 )
,('GEN 6:2',	1,	'GEN',	6,	2 )
,('GEN 6:3',	1,	'GEN',	6,	3 )
,('GEN 6:4',	1,	'GEN',	6,	4 )
,('GEN 6:5',	1,	'GEN',	6,	5 )
,('GEN 6:6',	1,	'GEN',	6,	6 )
,('GEN 6:7',	1,	'GEN',	6,	7 )
,('GEN 6:8',	1,	'GEN',	6,	8 )

			GO
INSERT INTO PersonLabels (person_label_id
							,person_id
							,english_label 
							,hebrew_label 
							,hebrew_label_transliterated 
							,hebrew_label_meaning 
							,greek_label 
							,greek_label_transliterated 
							,greek_label_meaning 
							,label_reference_id 
							,label_type 
							,label_notes 
							,person_label_count)
VALUES
('Yhvh_1_1',	'Yhvh_1',	'G-d',	'אֱלֹהִים',	'elohiym',	'rulers, judges, divine ones [all plural]',	N'θεός',	'THeos',	'a deity or The Deity',	'GEN 1:1',	'title',	NULL,	1)
,('Yhvh_1_2',	'Yhvh_2',	'LORD G-d',	'יְהוָה אֱלֹהִים',	'y-h-v-h elohiym',	'[special name of G-d], god [plural]',	N'θεός',	'THeos',	'a deity or The Deity',	'GEN 2:4',	'title',	NULL,	2)
,('Adam_1_1',	'Adam_1',	'Adam',	'אָדָם',	'adam',	'man, mankind',	N'Ἀδάμ',	'Adam',	NULL,	'GEN 2:20',	'proper name',	NULL,	1)
,('Eve_1_1',	'Eve_1',	'Eve',	'חַוָּה',	'chavah',	'living one',	N'ζωή',	N'Zōē',	'life, living existence',	'GEN 3:20',	'proper name',	NULL,	1)
,('Cain_1_1',	'Cain_1',	'Cain',	'קַיִן',	'qayin',	'brought forth, acquired',	N'Κάϊν',	'Kain',	NULL,	'GEN 4:1',	'proper name',	NULL,	1)
,('Yhvh_1_3',	'Yhvh_3',	'LORD',	'יהוה',	'y-h-v-h',	'[the proper name of the one true G-d]',	N'θεός',	'THeos',	'a deity or The Deity',	'GEN 4:1',	'proper name',	N'יהוה is the proper name but many English translations render it "LORD" in all caps',	3)
,('Abel_1_1',	'Abel_1',	'Abel',	'הֵבֶל',	'hevel',	'morning mist',	N'Ἅβελ',	'Abel',	NULL,	'GEN 4:2',	'proper name',	NULL,	1)
,('Enoch_1_1',	'Enoch_1',	'Enoch',	'חֲנוֹךְ',	'chanoch',	'initiated; follower',	N'Ενωχ',	N'Enōx',	NULL,	'GEN 4:17',	'proper name',	NULL,	1)
,('Irad_1_1',	'Irad_1',	'Irad',	'עִירָד',	'iyrad',	'fugitive',	N'Γαιδαδ',	N'Gaidad',	NULL,	'GEN 4:18',	'proper name',	NULL,	1)
			GO
INSERT INTO PersonVerse (person_verse_id ,reference_id ,person_label_id ,person_id ,person_label ,person_label_count ,person_verse_notes)
VALUES
('GEN 1:2__Yhvh_1_1',	'GEN 1:2',	'Yhvh_1_1',	'Yhvh_1',	'G-d',	1,	NULL)
,('GEN 1:3__Yhvh_1_1',	'GEN 1:3',	'Yhvh_1_1',	'Yhvh_1',	'G-d',	1,	NULL)
,('GEN 1:4__Yhvh_1_1',	'GEN 1:4',	'Yhvh_1_1',	'Yhvh_1',	'G-d',	1,	NULL)
,('GEN 1:5__Yhvh_1_1',	'GEN 1:5',	'Yhvh_1_1',	'Yhvh_1',	'G-d',	1,	NULL)
,('GEN 1:1__Yhvh_1_1',	'GEN 1:1',	'Yhvh_1_1',	'Yhvh_1',	'G-d',	1,	NULL)
,('GEN 1:6__Yhvh_1_1',	'GEN 1:6',	'Yhvh_1_1',	'Yhvh_1',	'G-d',	1,	NULL)
,('GEN 1:7__Yhvh_1_1',	'GEN 1:7',	'Yhvh_1_1',	'Yhvh_1',	'G-d',	1,	NULL)
,('GEN 1:8__Yhvh_1_1',	'GEN 1:8',	'Yhvh_1_1',	'Yhvh_1',	'G-d',	1,	NULL)
,('GEN 1:9__Yhvh_1_1',	'GEN 1:9',	'Yhvh_1_1',	'Yhvh_1',	'G-d',	1,	NULL)
			GO
INSERT INTO PersonRelationship (person_relationship_id,	person_id_1,	relationship_type,	person_id_2,	relationship_category,	reference_id,	relationship_notes)
VALUES
('Yhvh_1:Adam_1:1',	'Yhvh_1',	'Creator',	'Adam_1',	'explicit',	'GEN 2:7',	NULL)
,('Adam_1:Yhvh_1:2',	'Adam_1',	'creation',	'Yhvh_1',	'inferred',	'GEN 2:7',	NULL)
,('Adam_1:Eve_1:3',	'Adam_1',	'husband',	'Eve_1',	'explicit',	'GEN 3:6',	NULL)
,('Eve_1:Adam_1:4',	'Eve_1',	'wife',	'Adam_1',	'explicit',	'GEN 2:25',	NULL)
,('Adam_1:Cain_1:5',	'Adam_1',	'father',	'Cain_1',	'inferred',	'GEN 4:1',	NULL)
,('Cain_1:Adam_1:6',	'Cain_1',	'son',	'Adam_1',	'inferred',	'GEN 4:1',	NULL)
,('Eve_1:Cain_1:7',	'Eve_1',	'mother',	'Cain_1',	'explicit',	'GEN 4:1',	NULL)
,('Cain_1:Eve_1:8',	'Cain_1',	'son',	'Eve_1',	'inferred',	'GEN 4:1',	NULL)
,('Adam_1:Abel_1:9',	'Adam_1',	'father',	'Abel_1',	'inferred',	'GEN 4:2',	NULL)
,('Abel_1:Adam_1:10',	'Abel_1',	'son',	'Adam_1',	'inferred',	'GEN 4:2',	NULL)
			GO
INSERT INTO [Events] (event_id
						,event_label
						,event_description
						,event_type
						,person_id
						,event_year_ah
						,person_age_at_event
						,event_year_offset
						,event_year_calculation
						,event_reference_id
						,event_location
						,event_location_reference_id
						,event_notes)
VALUES
 ('Creation', 'The Creation',	'All of Creation was formed by G-d''s spoken word. (GEN 1:1-31)',	'Unique',	'Yhvh_1',	1,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'Seven days of creation (GEN 2:2)')
,('Birth_Adam_1',	'Birth of Adam',	'"God created man in His own image, in the image of God He created him; male and female He created them. (GEN 1:27) God saw all that He had made, and behold, it was very good. And there was evening and there was morning, THE SIXTH DAY. (GEN 1:31)"',	'Birth',	'Adam_1',	1,	0,	NULL,	'No calculation: fundamental assertion',	'GEN 1:27',	'West of Eden',	'GEN 2:8',	'Adam was created (not born) on the 6th day.')
,('Birth_Seth_1',	'Birth of Seth',	'When Adam had lived ONE HUNDRED AND THIRTY YEARS, he became the father of a son in his own likeness, according to his image, and named him Seth. (GEN 5:3)',	'Birth',	'Seth_1',	131,	0,	130,	'Birth year of Seth_1''s father [Adam_1] (1) + his father''s age at his birth (130) = 131',	'GEN 5:3',	NULL,	NULL,	NULL)
,('Birth_Enosh_1',	'Birth of Enosh',	'Seth lived ONE HUNDRED AND FIVE YEARS, and became the father of Enosh. (GEN 5:6)',	'Birth',	'Enosh_1',	236,	0,	105,	'Birth year of Enosh_1''s father [Seth_1] (131) + his father''s age at his birth (105) = 236',	'GEN 5:6',	NULL,	NULL,	NULL)
,('Birth_Kenan_1',	'Birth of Kenan',	'Enosh lived NINETY YEARS, and became the father of Kenan. (GEN 5:9)',	'Birth',	'Kenan_1',	326,	0,	90,	'Birth year of Kenan_1''s father [Enosh_1] (236) + his father''s age at his birth (90) = 326',	'GEN 5:9',	NULL,	NULL,	NULL)
,('Birth_Mahalalel_1',	'Birth of Mahalalel',	'Kenan lived SEVENTY YEARS, and became the father of Mahalalel. (GEN 5:12)',	'Birth',	'Mahalalel_1',	396,	0,	70,	'Birth year of Mahalalel_1''s father [Kenan_1] (326) + his father''s age at his birth (70) = 396',	'GEN 5:12',	NULL,	NULL,	NULL)
,('Birth_Jared_1',	'Birth of Jared',	'Mahalalel lived SIXTY-FIVE YEARS, and became the father of Jared. (GEN 5:15)',	'Birth',	'Jared_1',	461,	0,	65,	'Birth year of Jared_1''s father [Mahalalel_1] (396) + his father''s age at his birth (65) = 461',	'GEN 5:15',	NULL,	NULL,	NULL)
,('Birth_Enoch_2',	'Birth of Enoch',	'Jared lived ONE HUNDRED AND SIXTY-TWO YEARS, and became the father of Enoch. (GEN 5:18)',	'Birth',	'Enoch_2',	623,	0,	162,	'Birth year of Enoch_2''s father [Jared_1] (461) + his father''s age at his birth (162) = 623',	'GEN 5:18',	NULL,	NULL,	NULL)
,('Birth_Methuselah_1',	'Birth of Methuselah',	'Enoch lived SIXTY-FIVE YEARS, and became the father of Methuselah. (GEN 5:21)',	'Birth',	'Methuselah_1',	688,	0,	65,	'Birth year of Methuselah_1''s father [Enoch_2] (623) + his father''s age at his birth (65) = 688',	'GEN 5:21',	NULL,	NULL,	NULL)
,('Birth_Lamech_2',	'Birth of Lamech',	'Methuselah lived ONE HUNDRED AND EIGHTY-SEVEN YEARS, and became the father of Lamech. (GEN 5:25)',	'Birth',	'Lamech_2',	875,	0,	187,	'Birth year of Lamech_2''s father [Methuselah_1] (688) + his father''s age at his birth (187) = 875',	'GEN 5:25',	NULL,	NULL,	NULL)
			GO
INSERT INTO Epochs (epoch_id
					,epoch_name
					,epoch_description
					,epoch_type
					,person_id
					,start_year_ah
					,end_year_ah
					,period_length
					,start_year_calculation
					,start_year_offset
					,start_year_reference_id
					,end_year_calculation
					,end_year_reference_id
					,period_length_reference_id
					,epoch_notes)
VALUES
('Creation',	'The Creation',	'All of Creation was formed by G-d''s spoken word. (GEN 1:1-31)',	'Unique',	'Yhvh_1',	1,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'Seven days of creation (GEN 2:2)')
,('Life_Adam_1',	'The Life of Adam',	'"God created man in His own image, in the image of God He created him; male and female He created them. (GEN 1:27) God saw all that He had made, and behold, it was very good. And there was evening and there was morning, the sixth day. (GEN 1:31) [Adam was created (not born) on the 6th day.] So all the days that Adam lived were nine hundred and thirty years, and he died. (GEN 5:5)"',	'Life',	'Adam_1',	1,	931,	930,	NULL,	NULL,	'GEN 1:27',	'Adam_1 birth year (1) + Adam_1 age at death (930) = 931',	NULL,	'GEN 5:5',	NULL)
,('Life_Seth_1',	'The Life of Seth',	'"When Adam had lived one hundred and thirty years, he became the father of a son in his own likeness, according to his image, and named him Seth. (GEN 5:3) So all the days of Seth were nine hundred and twelve years, and he died. (GEN 5:5)"',	'Life',	'Seth_1',	131,	1043,	912,	'Birth year of father (1) + age of father at son''s birth (130) = 131',	130,	'GEN 5:3',	'Seth_1 birth year (131) + Seth_1 age at death (912) = 1043',	NULL,	'GEN 5:8',	NULL)
,('Life_Enosh_1',	'The Life of Enosh',	'"Seth lived one hundred and five years, and became the father of Enosh. (GEN 5:6) So all the days of Enosh were nine hundred and five years, and he died. (GEN 5:11)"',	'Life',	'Enosh_1',	236,	1141,	905,	'Birth year of father (131) + age of father at son''s birth (105) = 236',	105,	'GEN 5:6',	'Enosh_1 birth year (236) + Enosh_1 age at death (905) = 1141',	NULL,	'GEN 5:11',	NULL)
,('Life_Kenan_1',	'The Life of Kenan',	'"Enosh lived ninety years, and became the father of Kenan. (GEN 5:9) So all the days of Kenan were nine hundred and ten years, and he died. (GEN 5:14)"',	'Life',	'Kenan_1',	326,	1236,	910,	'Birth year of father (236) + age of father at son''s birth (90) = 326',	90,	'GEN 5:9',	'Kenan_1 birth year (326) + Kenan_1 age at death (910) = 1236',	NULL,	'GEN 5:14',	NULL)
,('Life_Mahalalel_1',	'The Life of Mahalalel',	'"Kenan lived seventy years, and became the father of Mahalalel. (GEN 5:12) So all the days of Mahalalel were eight hundred and ninety-five years, and he died. (GEN 5:17)"',	'Life',	'Mahalalel_1',	396,	1291,	895,	'Birth year of father (326) + age of father at son''s birth (70) = 396',	70,	'GEN 5:12',	'Mahalalel_1 birth year (396) + Mahalalel_1 age at death (895) = 1291',	NULL,	'GEN 5:17',	NULL)
,('Life_Jared_1',	'The Life of Jared',	'"Mahalalel lived sixty-five years, and became the father of Jared. (GEN 5:15) So all the days of Jared were nine hundred and sixty-two years, and he died. (GEN 5:20)"',	'Life',	'Jared_1',	461,	1423,	962,	'Birth year of father (396) + age of father at son''s birth (65) = 461',	65,	'GEN 5:15',	'Jared_1 birth year (461) + Jared_1 age at death (962) = 1423',	NULL,	'GEN 5:20',	NULL)
,('Life_Enoch_2',	'The Life of Enoch',	'"Jared lived one hundred and sixty-two years, and became the father of Enoch. (GEN 5:18) So all the days of Enoch were three hundred and sixty-five years. (GEN 5:23) Enoch walked with God; and he was not, for God took him. (GEN 5:24) [Note that Enoch did not die but was "taken".]"', 'Life',	'Enoch_2',	623,	988,	365,	'Birth year of father (461) + age of father at son''s birth (162) = 623',	162,	'GEN 5:18',	'Enoch_2 birth year (623) + Enoch_2 age at death (365) = 988',	NULL,	'GEN 5:23',	NULL)
,('Life_Methuselah_1',	'The Life of Methuselah',	'"Enoch lived sixty-five years, and became the father of Methuselah. (GEN 5:21) So all the days of Methuselah were nine hundred and sixty-nine years, and he died. (GEN 5:27) [Methuselah lived 969 years, longer than any other person born. Methuselah died just before the time of the Flood.]"',	'Life',	'Methuselah_1',	688,	1657,	969,	'Birth year of father (623) + age of father at son''s birth (65) = 688',	65,	'GEN 5:21',	'Methuselah_1 birth year (688) + Methuselah_1 age at death (969) = 1657',	NULL,	'GEN 5:27',	NULL)
,('Life_Lamech_2',	'The Life of Lamech',	'"Methuselah lived one hundred and eighty-seven years, and became the father of Lamech. (GEN 5:25) So all the days of Lamech were seven hundred and seventy-seven years, and he died. (GEN 5:31)"',	'Life',	'Lamech_2',	875,	1652,	777,	'Birth year of father (688) + age of father at son''s birth (187) = 875',	187,	'GEN 5:25',	'Lamech_2 birth year (875) + Lamech_2 age at death (777) = 1652',	NULL,	'GEN 5:31',	NULL)
