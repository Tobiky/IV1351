CREATE TABLE address
(
    "id"             SERIAL PRIMARY KEY NOT NULL,
    "street_address" VARCHAR(50)        NOT NULL,
    "zip_code"       VARCHAR(20)        NOT NULL,
    "postal_code"    VARCHAR(20),
    "city"           VARCHAR(50)
);

CREATE TABLE genre
(
    "id"    SERIAL PRIMARY KEY NOT NULL,
    "genre" VARCHAR(50)
);

CREATE TABLE instrument
(
    "id"              SERIAL PRIMARY KEY NOT NULL,
    "instrument_name" VARCHAR(100)       NOT NULL
);

CREATE TABLE instrument_product
(
    "id"             SERIAL PRIMARY KEY NOT NULL,
    "brand"          VARCHAR(100),
    "stock_quantity" INT,
    "cost"           INT,
    "instrument_id"  INT NOT NULL,
    FOREIGN KEY ("instrument_id") REFERENCES instrument ("id") ON DELETE CASCADE
);

CREATE TABLE location
(
    "address_id" SERIAL PRIMARY KEY NOT NULL,
    "room"       VARCHAR(100)       NOT NULL,
    FOREIGN KEY ("address_id") REFERENCES address ("id") ON DELETE CASCADE
);

CREATE TABLE person
(
    "id"            SERIAL PRIMARY KEY NOT NULL,
    "person_number" VARCHAR(12)        NOT NULL,
    "age"           INT
);

CREATE TABLE person_address
(
    "address_id" INT NOT NULL,
    "person_id"  INT NOT NULL,
    PRIMARY KEY ("address_id", "person_id"),
    FOREIGN KEY ("address_id") REFERENCES address ("id") ON DELETE CASCADE,
    FOREIGN KEY ("person_id") REFERENCES person ("id") ON DELETE CASCADE
);

CREATE TABLE phone_number
(
    "person_id" INT         NOT NULL,
    "number"    VARCHAR(12) NOT NULL,
    PRIMARY KEY ("person_id", "number"),
    FOREIGN KEY ("person_id") REFERENCES person ("id") ON DELETE CASCADE
);

CREATE TABLE student_application
(
    "student_person_id" INT PRIMARY KEY NOT NULL,
    "keep_application"  BOOLEAN         NOT NULL,
    "accepted"          BOOLEAN,
    "skill_level"       INT             NOT NULL,
    "ensemble"          BOOLEAN         NOT NULL,
    FOREIGN KEY ("student_person_id") REFERENCES person ("id") ON DELETE CASCADE
);

CREATE TABLE time_slot
(
    "id"               SERIAL PRIMARY KEY       NOT NULL,
    "start_date_time"  TIMESTAMP WITH TIME ZONE NOT NULL,
    "ending_date_time" TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE email_address
(
    "person_id" INT PRIMARY KEY NOT NULL,
    "email"     VARCHAR(100)    NOT NULL,
    PRIMARY KEY ("person_id", "email"),
    FOREIGN KEY ("person_id") REFERENCES person ("id") ON DELETE CASCADE
);

CREATE TABLE first_name
(
    "person_id" INT PRIMARY KEY NOT NULL,
    "name"      VARCHAR(50)     NOT NULL,
    PRIMARY KEY ("person_id", "name"),
    FOREIGN KEY ("person_id") REFERENCES person ("id") ON DELETE CASCADE
);

CREATE TABLE instructor
(
    "person_id"   INT PRIMARY KEY    NOT NULL,
    "employee_id" VARCHAR(50) UNIQUE NOT NULL,
    FOREIGN KEY ("person_id") REFERENCES person ("id") ON DELETE CASCADE
);

CREATE TABLE instructor_instrument
(
    "instructor_id" INT NOT NULL,
    "instrument_id" INT NOT NULL,
    PRIMARY KEY ("instrument_id", "instrument_id"),
    FOREIGN KEY ("instructor_id") REFERENCES instructor ("person_id") ON DELETE CASCADE,
    FOREIGN KEY ("instrument_id") REFERENCES instrument ("id") ON DELETE CASCADE
);

CREATE TABLE instructor_payment
(
    "instructor_id"  INT     NOT NULL,
    "time_slot_id"   INT     NOT NULL,
    "instructor_pay" DECIMAL NOT NULL,
    PRIMARY KEY ("instructor_id", "time_slot_id"),
    FOREIGN KEY ("instructor_id") REFERENCES instructor ("person_id") ON DELETE CASCADE,
    FOREIGN KEY ("time_slot_id") REFERENCES time_slot ("id") ON DELETE CASCADE
);

CREATE TABLE instrument_application
(
    "instrument_id"     INT NOT NULL,
    "student_person_id" INT NOT NULL,
    PRIMARY KEY ("instrument_id", "student_person_id"),
    FOREIGN KEY ("instrument_id") REFERENCES instrument ("id") ON DELETE CASCADE,
    FOREIGN KEY ("student_person_id") REFERENCES person ("id") ON DELETE CASCADE
);

CREATE TABLE last_name
(
    "person_id" INT         NOT NULL,
    "name"      VARCHAR(50) NOT NULL,
    PRIMARY KEY ("person_id", "name"),
    FOREIGN KEY ("person_id") REFERENCES person ("id") ON DELETE CASCADE
);

CREATE TABLE lesson
(
    "id"            SERIAL PRIMARY KEY NOT NULL,
    "skill_level"   INT                NOT NULL,
    "cost"          DECIMAL            NOT NULL,
    "extra_cost"    DECIMAL,
    "cost_info"     TEXT,
    "instructor_id" INT,
    "time_slot_id"  INT,
    "location_id"   INT,
    FOREIGN KEY ("instructor_id") REFERENCES instructor ("person_id") ON DELETE SET NULL,
    FOREIGN KEY ("time_slot_id") REFERENCES time_slot ("id") ON DELETE SET NULL,
    FOREIGN KEY ("location_id") REFERENCES location ("address_id") ON DELETE SET NULL
);

CREATE TABLE lesson_instrument
(
    "instrument_id" INT NOT NULL,
    "lesson_id"     INT NOT NULL,
    PRIMARY KEY ("instrument_id", "lesson_id"),
    FOREIGN KEY ("instrument_id") REFERENCES instrument ("id") ON DELETE CASCADE,
    FOREIGN KEY ("lesson_id") REFERENCES lesson ("id") ON DELETE CASCADE
);

CREATE TABLE student
(
    "person_id"  INT PRIMARY KEY NOT NULL,
    "discounted" BOOLEAN         NOT NULL,
    FOREIGN KEY ("person_id") REFERENCES person ("id") ON DELETE CASCADE
);

CREATE TABLE student_guardians
(
    "student_id"  INT NOT NULL,
    "guardian_id" INT NOT NULL,
    PRIMARY KEY ("student_id", "guardian_id"),
    FOREIGN KEY ("student_id") REFERENCES student ("person_id") ON DELETE CASCADE,
    FOREIGN KEY ("guardian_id") REFERENCES person ("id") ON DELETE CASCADE
);

CREATE TABLE student_lesson
(
    "student_id" INT NOT NULL,
    "lesson_id"  INT NOT NULL,
    PRIMARY KEY ("student_id", "lesson_id"),
    FOREIGN KEY ("student_id") REFERENCES student ("person_id") ON DELETE CASCADE,
    FOREIGN KEY ("lesson_id") REFERENCES lesson ("id") ON DELETE CASCADE
);


CREATE TABLE student_payment
(
    "student_id"         INT     NOT NULL,
    "time_slot_id"       INT     NOT NULL,
    "student_charge"     DECIMAL NOT NULL,
    "payed"              BOOLEAN NOT NULL,
    "charge_description" TEXT,
    PRIMARY KEY ("student_id", "time_slot_id"),
    FOREIGN KEY ("student_id") REFERENCES student ("person_id") ON DELETE CASCADE,
    FOREIGN KEY ("time_slot_id") REFERENCES time_slot ("id") ON DELETE CASCADE
);


CREATE TABLE student_sibling
(
    "student_id" INT NOT NULL,
    "sibling_id" INT NOT NULL,
    PRIMARY KEY ("student_id", "sibling_id"),
    FOREIGN KEY ("student_id") REFERENCES student ("person_id") ON DELETE CASCADE,
    FOREIGN KEY ("sibling_id") REFERENCES student ("person_id") ON DELETE CASCADE
);


CREATE TABLE audition
(
    "lesson_id" INT PRIMARY KEY NOT NULL,
    "passed"    BOOLEAN,
    FOREIGN KEY ("lesson_id") REFERENCES lesson ("id") ON DELETE CASCADE
);


CREATE TABLE ensemble
(
    "lesson_id"    INT PRIMARY KEY NOT NULL,
    "min_students" INT             NOT NULL,
    "max_students" INT             NOT NULL,
    FOREIGN KEY ("lesson_id") REFERENCES lesson ("id") ON DELETE CASCADE
);

CREATE TABLE ensemble_genre
(
    "genre_id"    INT NOT NULL,
    "ensemble_id" INT NOT NULL,
    PRIMARY KEY ("genre_id", "ensemble_id"),
    FOREIGN KEY ("genre_id") REFERENCES genre ("id") ON DELETE CASCADE,
    FOREIGN KEY ("ensemble_id") REFERENCES ensemble ("lesson_id") ON DELETE CASCADE
);


CREATE TABLE instrument_rental_application
(
    "student_id"      INT PRIMARY KEY NOT NULL,
    "instrument_name" VARCHAR(100)    NOT NULL,
    "brand"           VARCHAR(100),
    "accepted"        BOOLEAN,
    FOREIGN KEY ("student_id") REFERENCES student ("person_id") ON DELETE CASCADE
);


CREATE TABLE instrument_rental
(
    "instrument_id" INT     NOT NULL,
    "student_id"    INT     NOT NULL,
    "time_slot_id"  INT     NOT NULL,
    "rental_charge" DECIMAL NOT NULL,
    "instrument_product_id" INT NOT NULL,
    PRIMARY KEY ("instrument_product_id", "student_id", "time_slot_id"),
    FOREIGN KEY ("instrument_product_id") REFERENCES instrument_product ("id") ON DELETE CASCADE,
    FOREIGN KEY ("instrument_id") REFERENCES instrument ("id") ON DELETE CASCADE,
    FOREIGN KEY ("student_id") REFERENCES student ("person_id") ON DELETE CASCADE,
    FOREIGN KEY ("time_slot_id") REFERENCES time_slot ("id") ON DELETE CASCADE
);
