Expense Approval System — SAP ABAP RAP (Full-Stack)

A self-built, end-to-end SAP application implementing a multi-level expense approval process, developed on the SAP BTP ABAP Environment using the RESTful ABAP Programming Model (RAP).

This project was built during my full-time training toward the SAP® Certified Associate – Back-End Developer – ABAP™ Cloud certification, as a way to apply RAP concepts (business objects, draft handling, compositions, actions, access control) in a realistic business scenario.

Overview

The application models a typical corporate expense approval workflow: an employee submits an expense report, individual line items are added, and the report moves through a multi-step, amount-dependent approval chain before being finalized. Every decision is captured in an approval log for full traceability.

Key Features
Draft-enabled RAP Business Object with a 3-tier composition hierarchy: Report → Items → Approval Log
Cross-entity validations (budget and policy checks) enforced via custom Exception and Message classes
Multi-step approval workflow: 6 distinct approval actions with amount-based dynamic routing (higher amounts require additional approval levels)
Dynamic UI control per approval step, implemented via get_instance_features, so only valid actions are shown to the user at each stage
Field-level audit trail — every change to a report is logged
Row-level access control via CDS Access Control, ensuring users only see/approve the reports relevant to their role
Fiori Elements UI, generated directly from the RAP business object and CDS annotations
Tech Stack
ABAP RESTful Application Programming Model (RAP) — Managed Implementation
Core Data Services (CDS Views), CDS Access Control
ABAP Behavior Definitions, Actions, Determinations, Validations
SAP Fiori Elements (OData V4 UI Service)
SAP BTP ABAP Environment
Status / Notes

This is a personal training project, not a productive system. It is intended to demonstrate practical understanding of RAP's more advanced capabilities — draft handling, compositions, dynamic feature control, and access control — beyond a basic CRUD example.
