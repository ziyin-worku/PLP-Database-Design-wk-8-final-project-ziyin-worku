# Clinic Booking & Patient Management System

## Assignment: Week 8 Final Project
**Question 1: Build a Complete Database Management System**

---

## Objective
Design and implement a full-featured relational database using **MySQL**.

---

## Use Case
A **Clinic Booking & Patient Management System** that manages:

- Patients
- Doctors & Specialties
- Appointments
- Medical Records
- Medications & Prescriptions
- Treatments
- Invoices & Payments
- Insurance Providers
- Audit Logs

---

## Database Schema
The schema includes **well-structured tables** with:

- **Primary Keys** for unique identification  
- **Foreign Keys** to enforce relationships  
- **NOT NULL** and **UNIQUE** constraints where appropriate  
- **ENUMs** and **CHECK constraints** for valid data  

### Relationships
- **One-to-One**: `users` ↔ `doctors`  
- **One-to-Many**: `doctors` → `appointments`, `patients` → `appointments`  
- **Many-to-Many**: `doctors` ↔ `specialties` via `doctor_specialty`  
- **Many-to-Many**: `appointments` ↔ `treatments` via `appointment_treatments`

---

## Features
- Triggers to prevent overlapping appointments
- Automatic invoice updates when treatments are added
- Views for patient appointments, doctor schedules, and billing
- Stored procedures to cancel appointments and check doctor availability
- Indexes for performance optimization

---

## Deliverables
A single **`.sql` file**:  
- `CREATE DATABASE` statement  
- `CREATE TABLE` statements  
- Relationship constraints  
- Sample test data  

---

## How to Use
1. Open **MySQL Workbench** or any MySQL client.  
2. Execute the `.sql` file to create the database, tables, and sample data.  
3. Run queries on views and tables to test relationships, triggers, and stored procedures.  

---

## Author
- **Ziyin Worku**  
- Submission for **Week 8 Database Management Assignment**
