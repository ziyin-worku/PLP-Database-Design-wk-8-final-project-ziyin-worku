-- ===================================
-- clinic_management_full_with_triggers.sql
-- Clinic Booking & Patient Management System
-- ===================================

-- DROP & CREATE DATABASE
DROP DATABASE IF EXISTS clinic_management;
CREATE DATABASE clinic_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE clinic_management;

-- ==========================
-- TABLES
-- ==========================
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active TINYINT DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    role_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active TINYINT DEFAULT 1,
    CONSTRAINT fk_users_role 
        FOREIGN KEY (role_id) 
        REFERENCES roles(role_id)
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    dob DATE,
    gender ENUM('Male','Female','Other','Prefer not to say') DEFAULT 'Prefer not to say',
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    license_number VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    email VARCHAR(255),
    bio TEXT,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_doctors_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(user_id)
        ON DELETE SET NULL 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE specialties (
    specialty_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active TINYINT DEFAULT 1
) ENGINE=InnoDB;


CREATE TABLE doctor_specialty (
    doctor_id INT NOT NULL,
    specialty_id INT NOT NULL,
    is_primary TINYINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (doctor_id, specialty_id),
    CONSTRAINT fk_ds_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ds_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    floor INT,
    room_type ENUM('Consultation', 'Examination', 'Procedure', 'Other') DEFAULT 'Consultation',
    description TEXT,
    is_active TINYINT DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    room_id INT NULL,
    appointment_datetime DATETIME NOT NULL,
    duration_minutes INT NOT NULL DEFAULT 30,
    status ENUM('Scheduled','Checked-in','In Progress','Completed','Cancelled','No-Show') DEFAULT 'Scheduled',
    reason TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP NULL,
    cancellation_reason TEXT,
    CONSTRAINT fk_appointments_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_appointments_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_appointments_room FOREIGN KEY (room_id) REFERENCES rooms(room_id) 
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE medical_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NULL,
    appointment_id INT NULL,
    visit_date DATE NOT NULL,
    symptoms TEXT,
    examination_findings TEXT,
    notes TEXT,
    diagnosis TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_records_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_records_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_records_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) 
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE medications (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    manufacturer VARCHAR(255),
    description TEXT,
    is_active TINYINT DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT NOT NULL,
    medication_id INT NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(100),
    duration_days INT,
    start_date DATE,
    end_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prescription_record FOREIGN KEY (record_id) REFERENCES medical_records(record_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_prescription_med FOREIGN KEY (medication_id) REFERENCES medications(medication_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE treatments (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    typical_duration INT,
    cost DECIMAL(10,2) DEFAULT 0.00
) ENGINE=InnoDB;

CREATE TABLE appointment_treatments (
    appointment_id INT NOT NULL,
    treatment_id INT NOT NULL,
    quantity INT DEFAULT 1,
    notes TEXT,
    PRIMARY KEY (appointment_id, treatment_id),
    CONSTRAINT fk_at_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_at_treatment FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    issued_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATE,
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    paid_amount DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('Draft', 'Issued', 'Paid', 'Overdue', 'Cancelled') DEFAULT 'Draft',
    payment_method ENUM('Cash','Card','Insurance','Bank Transfer','Other') DEFAULT 'Cash',
    payment_date DATETIME NULL,
    notes TEXT,
    CONSTRAINT fk_invoice_appointment FOREIGN KEY (appointment_id) 
        REFERENCES appointments(appointment_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE invoice_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    description TEXT NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10,2) DEFAULT 0.00,
    total_price DECIMAL(10,2) DEFAULT 0.00,
    CONSTRAINT fk_items_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE insurance_providers (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    contact_info VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    is_active TINYINT DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE patient_insurance (
    insurance_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    provider_id INT NOT NULL,
    policy_number VARCHAR(100) NOT NULL,
    valid_from DATE,
    valid_to DATE,
    copay_amount DECIMAL(10,2) DEFAULT 0.00,
    coverage_percentage DECIMAL(5,2) DEFAULT 0.00,
    notes TEXT,
    is_verified TINYINT DEFAULT 0,
    verified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_pi_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pi_provider FOREIGN KEY (provider_id) REFERENCES insurance_providers(provider_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE (patient_id, provider_id, policy_number)
) ENGINE=InnoDB;

-- ==========================
-- TRIGGERS
-- ==========================


DELIMITER //

CREATE TRIGGER prevent_doctor_overlap
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM appointments 
        WHERE doctor_id = NEW.doctor_id
          AND appointment_datetime < DATE_ADD(NEW.appointment_datetime, INTERVAL NEW.duration_minutes MINUTE)
          AND DATE_ADD(appointment_datetime, INTERVAL duration_minutes MINUTE) > NEW.appointment_datetime
          AND status NOT IN ('Cancelled', 'No-Show')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor has overlapping appointment';
    END IF;
END;
//


CREATE TRIGGER prevent_room_overlap
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
    IF NEW.room_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM appointments 
        WHERE room_id = NEW.room_id
        AND appointment_datetime < DATE_ADD(NEW.appointment_datetime, INTERVAL NEW.duration_minutes MINUTE)
        AND DATE_ADD(appointment_datetime, INTERVAL duration_minutes MINUTE) > NEW.appointment_datetime
        AND status NOT IN ('Cancelled', 'No-Show')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room has overlapping appointment';
    END IF;
END//

CREATE TRIGGER update_invoice_total
AFTER INSERT ON appointment_treatments
FOR EACH ROW
BEGIN
    UPDATE invoices i
    JOIN (
        SELECT at.appointment_id, SUM(t.cost * at.quantity) AS total
        FROM appointment_treatments at
        JOIN treatments t ON at.treatment_id = t.treatment_id
        WHERE at.appointment_id = NEW.appointment_id
        GROUP BY at.appointment_id
    ) calc ON i.appointment_id = calc.appointment_id
    SET i.total_amount = calc.total
    WHERE i.appointment_id = NEW.appointment_id;
END//
DELIMITER ;

-- ==========================
-- VIEWS
-- ==========================
CREATE OR REPLACE VIEW vw_patient_upcoming_appointments AS
SELECT p.patient_id, p.first_name, p.last_name, 
       a.appointment_id, a.appointment_datetime, 
       d.first_name AS doctor_first, d.last_name AS doctor_last,
       r.room_number,
       a.status, a.reason
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
LEFT JOIN rooms r ON a.room_id = r.room_id
WHERE a.appointment_datetime >= NOW()
AND a.status IN ('Scheduled', 'Checked-in', 'In Progress');


CREATE OR REPLACE VIEW vw_doctor_schedule AS
SELECT d.doctor_id, d.first_name, d.last_name,
       a.appointment_datetime, 
       DATE_ADD(a.appointment_datetime, INTERVAL a.duration_minutes MINUTE) AS end_time,
       p.first_name AS patient_first, p.last_name AS patient_last,
       a.status, r.room_number
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN patients p ON a.patient_id = p.patient_id
LEFT JOIN rooms r ON a.room_id = r.room_id
WHERE a.appointment_datetime >= CURDATE()
ORDER BY d.doctor_id, a.appointment_datetime;


CREATE OR REPLACE VIEW vw_patient_billing AS
SELECT p.patient_id, p.first_name, p.last_name,
       i.invoice_id, i.issued_date, i.due_date,
       i.total_amount, i.paid_amount, i.status,
       a.appointment_datetime,
       d.first_name AS doctor_first, d.last_name AS doctor_last
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN invoices i ON a.appointment_id = i.appointment_id
JOIN doctors d ON a.doctor_id = d.doctor_id;

-- ==========================
-- STORED PROCEDURES
-- ==========================
DELIMITER //

CREATE PROCEDURE sp_cancel_appointment(
    IN p_appointment_id INT,
    IN p_reason TEXT
)
BEGIN
    DECLARE current_status VARCHAR(20);
    
    SELECT status INTO current_status 
    FROM appointments 
    WHERE appointment_id = p_appointment_id;
    
    IF current_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Appointment is already cancelled';
    ELSEIF current_status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot cancel completed appointment';
    ELSE
        UPDATE appointments 
        SET status = 'Cancelled',
            cancellation_reason = p_reason,
            cancelled_at = NOW()
        WHERE appointment_id = p_appointment_id;
        
        UPDATE invoices 
        SET status = 'Cancelled'
        WHERE appointment_id = p_appointment_id;
    END IF;
END//

CREATE PROCEDURE sp_get_doctor_availability(
    IN p_doctor_id INT,
    IN p_date DATE
)
BEGIN
    SELECT 
        TIME(a.appointment_datetime) AS start_time,
        TIME(DATE_ADD(a.appointment_datetime, INTERVAL a.duration_minutes MINUTE)) AS end_time,
        a.status
    FROM appointments a
    WHERE a.doctor_id = p_doctor_id
      AND DATE(a.appointment_datetime) = p_date
    ORDER BY a.appointment_datetime;
END//
DELIMITER ;

-- ==========================
-- SAMPLE DATA
-- ==========================
INSERT INTO roles (name, description) VALUES
('Admin','System administrator'),
('Doctor','Medical doctor'),
('Receptionist','Front desk'),
('Nurse','Medical nurse');

INSERT INTO users (username, password_hash, email, role_id) VALUES
('admin','hash_admin','admin@clinic.test',1),
('dr_john','hash_doc1','john.doe@clinic.test',2),
('dr_marta','hash_doc2','marta.h@clinic.test',2),
('reception','hash_recep','reception@clinic.test',3);

INSERT INTO patients (first_name,last_name,dob,gender,phone,email,address) VALUES
('Amina','Bekele','1990-04-10','Female','0911000001','amina@test.com','Addis Ababa'),
('Samuel','Teklu','1985-12-01','Male','0911000002','samuel@test.com','Addis Ababa');

INSERT INTO doctors (user_id,first_name,last_name,license_number,phone,email,bio) VALUES
(2,'John','Doe','LIC-2020-001','0911111111','john.doe@clinic.test','General practitioner'),
(NULL,'Marta','Hailu','LIC-2021-002','0912222222','marta.h@clinic.test','Pediatrics specialist');

INSERT INTO specialties (name, description) VALUES
('General Practice','Primary care'),
('Pediatrics','Child health');

INSERT INTO doctor_specialty (doctor_id,specialty_id,is_primary) VALUES
(1,1,1),(2,2,1);

INSERT INTO rooms (room_number,floor,room_type,description) VALUES
('101',1,'Consultation','Consultation Room 1'),
('102',1,'Consultation','Consultation Room 2');

INSERT INTO appointments (patient_id, doctor_id, room_id, appointment_datetime, duration_minutes, status, reason) VALUES
(1,1,1,'2025-09-20 09:00:00',30,'Scheduled','Routine checkup'),
(2,2,2,'2025-09-21 10:30:00',45,'Scheduled','Child fever');

INSERT INTO medical_records (patient_id, doctor_id, appointment_id, visit_date, symptoms, diagnosis) VALUES
(1,1,1,CURDATE(),'Mild headache','Tension headache'),
(2,2,2,CURDATE(),'Fever, cough','Viral infection');

INSERT INTO medications (name,manufacturer,description) VALUES
('Paracetamol','Acme Pharma','Analgesic'),
('Amoxicillin','GoodPharma','Antibiotic');

INSERT INTO prescriptions (record_id,medication_id,dosage,frequency,duration_days,start_date,end_date) VALUES
(1,1,'500mg','3 times/day',3,CURDATE(),CURDATE() + INTERVAL 3 DAY),
(2,2,'250mg','2 times/day',7,CURDATE(),CURDATE() + INTERVAL 7 DAY);

INSERT INTO treatments (name, description, typical_duration, cost) VALUES
('Consultation','Doctor consultation',30,15.00),
('Basic Examination','Physical examination',45,25.00);

INSERT INTO appointment_treatments (appointment_id, treatment_id, quantity) VALUES
(1,1,1),
(2,1,1),
(2,2,1);

INSERT INTO insurance_providers (name, contact_info, phone, email) VALUES
('Ethio Insurance', 'Bole Road, Addis Ababa', '0915000001', 'info@ethioinsurance.com');

INSERT INTO patient_insurance (patient_id, provider_id, policy_number, valid_from, valid_to, coverage_percentage) VALUES
(1,1,'POL123456','2025-01-01','2025-12-31',80.00);

INSERT INTO invoices (appointment_id, issued_date, due_date, total_amount, status, payment_method) VALUES
(1,'2025-09-20','2025-10-20',15.00,'Issued','Insurance'),
(2,'2025-09-21','2025-10-21',40.00,'Issued','Cash');
