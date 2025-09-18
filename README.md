# Clinic Management System Database

## Overview
A comprehensive MySQL database system designed for managing clinic operations including patient appointments, medical records, billing, and staff management.

## Database Schema

### Core Tables
- **Patients** - Stores patient demographics and contact information
- **Doctors** - Manages doctor profiles, licenses, and specialties
- **Appointments** - Handles scheduling with conflict prevention
- **Medical Records** - Tracks patient visits, diagnoses, and treatments
- **Invoices** - Manages billing and payments

### Relationships
- **One-to-Many**: Patients → Appointments, Doctors → Appointments
- **Many-to-Many**: Doctors ↔ Specialties (via doctor_specialty table)
- **One-to-One**: Appointments ↔ Invoices

### Constraints Implemented
- Primary Keys on all main tables
- Foreign Keys for relationship integrity
- Unique constraints (username, email, license numbers)
- ENUM types for status fields and categories
- NOT NULL constraints on required fields

## Advanced Features

### Triggers
1. **prevent_doctor_overlap** - Ensures doctors don't have overlapping appointments
2. **prevent_room_overlap** - Prevents double-booking of rooms
3. **update_invoice_total** - Automatically calculates invoice totals when treatments are added

### Views
1. **vw_patient_upcoming_appointments** - Shows upcoming appointments for patients
2. **vw_doctor_schedule** - Displays doctor schedules
3. **vw_patient_billing** - Provides billing information for patients

### Stored Procedures
1. **sp_cancel_appointment** - Handles appointment cancellation with validation
2. **sp_get_doctor_availability** - Checks doctor availability for a specific date

## Installation

1. Execute the SQL file in MySQL:
```bash
mysql -u your_username -p < clinic_management_full_with_triggers.sql