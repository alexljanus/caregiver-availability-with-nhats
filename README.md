## README File for the Project Caregiver Availability and Patterns of Informal and Formal Eldercare

### File: alexljanus/caregiver-availability-with-nhats/Data and Methods.md

This file contains

### Directory: alexljanus/caregiver-availability-with-nhats/analysis

This directory contains Stata do-files (as well as their corresponding log files) that are necessary to perform the data preparation and statistical modeling steps for the project Caregiver Availability and Patterns of Informal and Formal Eldercare.

Below is a general description of the analytical steps performed by each of the do-files. Please see the do-files themselves for detailed annotations:
#### dofile1.do
- Reads in the sample-person-level data file from **Round 1** "NHATS_Round_1_SP_File" (available from the National Health and Aging Trends Study website https://nhats.org).
- Generates the following sample-person-level variables:
  - Measures of dementia status
  - Measures of limitations with self-care and mobility activities
  - Measures of unmet need with activities of daily living (ADLs) and instrumental activities of daily living (IADLs)
  - Measures of socio-demographic characteristics (gender, racial ancestry, age, spouse has self-care needs, marital status, number of children, total income, medicaid coverage, residential care status)
- Saves a revised sample-person-level data file from Round 1 containing the aforementioned measures.

#### dofile2.do
- Reads in the sample-person-level data file from **Round 5** "NHATS_Round_5_SP_File_V2" (available from the National Health and Aging Trends Study website https://nhats.org).
- Generates the following sample-person-level variables:
  - Measures of dementia status
  - Measures of limitations with self-care and mobility activities
  - Measures of unmet need with activities of daily living (ADLs) and instrumental activities of daily living (IADLs)
  - Measures of socio-demographic characteristics (gender, racial ancestry, age, spouse has self-care needs, marital status, number of children, total income, medicaid coverage, residential care status)
- Saves a revised sample-person-level data file from Round 5 containing the aforementioned measures.

#### dofile3.do
- Performs the following merges with the other-person-level data file (which includes caregivers/helpers) from **Round 1** ("NHATS_Round_1_OP_File_v2"):
  - One-to-one merge with the data file containing imputed caregiving hours from Round 1 ("Round_1_hours") using the composite primary key spid, opid.
  - Many-to-one merge with the revised sample-person-level data file from Round 1 ("SP_ROUND1") using the key spid.
  - One-to-one merge with the National Study of Caregiving other-person-level tracker file from Round 1 ("NSOC_Round_1_OP_Tracker_File") using the composite primary key spid, opid.
  - One-to-one merge with the National Study of Caregiving main data file from Round 1 ("NSOC_Round_1_File_v2") using the composite primary key spid, opid.
  - Saves a revised other-person-level data file from Round 1 ("ROUND1")

#### dofile4.do
- Performs the following merges with the other-person-level data file (which includes caregivers/helpers) from **Round 5** ("NHATS_Round_5_OP_File_V2"):
  - One-to-one merge with the data file containing imputed caregiving hours from Round 5 ("Round_5_hours") using the composite primary key spid, opid.
  - Many-to-one merge with the revised sample-person-level data file from Round 5 ("SP_ROUND5") using the key spid.
  - One-to-one merge with the National Study of Caregiving other-person-level tracker file from Round 5 ("NSOC_Round_5_OP_Tracker_File_V2") using the composite primary key spid, opid.
  - One-to-one merge with the National Study of Caregiving main data file from Round 5 ("NSOC_Round_5_File_V2") using the composite primary key spid, opid.
  - Saves a revised other-person-level data file from Round 5 ("ROUND5")

#### dofile5.do
- Performs a one-to-one merge with the revised other-person-level data files from Round 1 and Round 5.
- Reshapes the merged data file ("WIDE") from wide to long format so that caregiver/helper-level data from different rounds is recorded in separate rows. 
- Generates the following caregiver/helper-level variables:
  - Multiple helper flags.
  - Measures of caregivers'/helpers' socio-demographic characteristics.
- Dependent variables for the hours of care received from focal (primary) non-spousal helpers, non-focal non-spousal helpers, non-focal spousal helpers, formal helpers, and all sources combined. 
- Saves a revised caregiver/helper-level data file in long format so that caregiver/helper-level data from different rounds is recorded in separate rows.

#### dofile6.do
- Creates datasets of summary statistics describing sample persons for use in constructing Table 1: Characteristics of SPs with at least 1 NSOC-Interviewed Nonspousal Helper, SPs without an NSOC-Interviewed Nonspousal Helper, and the Combined Sample.

#### dofile7.do
- Calculates estimates describing focal (primary) non-spousal helpers for Table 2: Characteristics of Focal Nonspousal Helpers.

#### dofile8.do
- Calculates the percentage of sample persons with data from Round 1 only, Round 5 only, and both rounds.

#### dofile9.do
- Creates a sample-person-level dataset to be used for the statistical models (i.e., sample persons with at least one nonspousal caregiver/helper who was interviewed in the National Study of Caregiving).
- Performs one set of imputations to impute missing values of the measures to be used as independent variables in the statistical models.

#### dofile10.do
- Estimates generalized linear models to examine the association of care received from different sources (focal nonspousal, nonfocal nonspousal, spousal, formal, and all sources combined) with indicators of focal (primary) helpers' availability (employment status and residential proximity) and other factors.
- Estimates generalized linear models to examine the association of unmet need with activities of daily living and instrumental activities of daily living with indicators of focal (primary) helpers' availability (employment status and residential proximity) and other factors.

### Directory: alexljanus/caregiver-availability-with-nhats/figures

This directory contains a Jupyter notebook that creates the following figures using Python's matplotlib library and saves them as .png files:
- Hours of Care Received by Focal Caregivers' Employment Status and Source of Care (Bar Charts)
- Hours of Care Received by Focal Caregivers' Employment Status and Source of Care (Pie Charts)
- Hours of Care Received by Focal Caregivers' Residential Proximity and Source of Care (Bar Charts)
- Hours of Care Received by Focal Caregivers' Residential Proximity and Source of Care (Pie Charts)

### Directory: alexljanus/caregiver-availability-with-nhats/figures/figures-as-png-files

This directory contains the figures from the project saved as .png files.
