from codelists import *
from cohortextractor import (
    StudyDefinition,
    Measure,
    codelist,
    codelist_from_csv,
    combine_codelists,
    filter_codes_by_category,
    patients,
)

start_date = "2015-01-01"
end_date = "today"

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "2000-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
        },
    # index_date="", not defined becasue it will be pa_ca_date
    population=patients.satisfying(
        """pa_ca AND
        (age >=18 AND age <= 110)"""
    ),
    pa_ca=patients.with_these_clinical_events(
        pan_cancer_codes,
        on_or_after="1900-01-01",
        find_first_match_in_period=True,
        include_date_of_match=True,
        include_month=True,
        include_day=True,
        returning="binary_flag",
        return_expectations={
            "date": {"earliest": "2013-01-01", "latest": "today"},
            "incidence": 1.0
        }
    ),
# demographics
    age=patients.age_as_of(
        "pa_ca_date",
        return_expectations={
            "rate": "exponential_increase",
            "int": {"distribution": "population_ages"},
        },
    ),
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),
    ethnicity=patients.categorised_as(
        {
            "Missing": "DEFAULT",
            "White": """ ethnicity_code=1 """,
            "Mixed": """ ethnicity_code=2 """,
            "South Asian": """ ethnicity_code=3 """,
            "Black": """ ethnicity_code=4 """,
            "Other": """ ethnicity_code=5 """,
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "Missing": 0.4,
                    "White": 0.2,
                    "Mixed": 0.1,
                    "South Asian": 0.1,
                    "Black": 0.1,
                    "Other": 0.1,
                }
            },
        },
        ethnicity_code=patients.with_these_clinical_events(
            ethnicity_codes,
            returning="category",
            find_last_match_in_period=True,
            on_or_before="pa_ca_date",
            return_expectations={
            "category": {"ratios": {"1": 0.4, "2": 0.4, "3": 0.2, "4":0.2,"5": 0.2}},
            "incidence": 0.75,
            },
        ),
    ),
# services
    bmi_before=patients.most_recent_bmi(
        between=["pa_ca_date - 6 months", "pa_ca_date"],
        minimum_age_at_measurement=16,
        return_expectations={
            "date": {"earliest": "2013-01-01", "latest": "today"},
            "float": {"distribution": "normal", "mean": 25, "stddev": 8},
            "incidence": 0.1
        }
    ),
    bmi_after=patients.most_recent_bmi(
        between=["pa_ca_date", "pa_ca_date + 6 months"],
        minimum_age_at_measurement=16,
        return_expectations={
            "date": {"earliest": "2013-01-01", "latest": "today"},
            "float": {"distribution": "normal", "mean": 25, "stddev": 8},
            "incidence": 0.1
        }
    ),
    hba1c_before=patients.with_these_clinical_events(
        hba1c_codes,
        between=["pa_ca_date - 6 months", "pa_ca_date"],
        returning="binary_flag",
        return_expectations={"incidence": 0.50},
    ),
    hba1c_after=patients.with_these_clinical_events(
        hba1c_codes,
        between=["pa_ca_date", "pa_ca_date + 6 months"],
        returning="binary_flag",
        return_expectations={"incidence": 0.50},
    ),
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        returning="binary_flag",
        return_expectations={"incidence": 0.30},
    ),
# Diagnostic tests prior to diagnosis
    liver_funct_before=patients.with_these_clinical_events(
        liver_funct_codes,
        between=["pa_ca_date - 6 months", "pa_ca_date"],
        returning="binary_flag",
        return_expectations={"incidence": 0.50},
    ),
    liver_funct_after=patients.with_these_clinical_events(
        liver_funct_codes,
        between=["pa_ca_date", "pa_ca_date + 6 months"],
        returning="binary_flag",
        return_expectations={"incidence": 0.50},
    ),
    pancreatic_imaging=patients.admitted_to_hospital(
        with_these_procedures=pancreatic_imaging_OPCS4,
        between=["pa_ca_date - 6 months", "pa_ca_date"],
        returning="binary_flag",
        return_expectations={"incidence": 0.20},
        find_first_match_in_period=True,
    ),
# Symptoms, jaundice example
    jaundice=patients.with_these_clinical_events(
        jaundice,
        between=["pa_ca_date - 6 months", "pa_ca_date"],
        returning="binary_flag",
        return_expectations={"incidence": 0.60},
    ),
# treatment
    enzyme_replace=patients.with_these_medications(
        enzyme_replace,
        between=["pa_ca_date", "pa_ca_date + 6 months"],
        returning="binary_flag",
        return_expectations={"incidence": 0.50},
    ),
    pancreatic_resection=patients.admitted_to_hospital(
        with_these_procedures=pancreatic_resection_OPCS4,
        between=["pa_ca_date", "pa_ca_date + 6 months"],
        returning="binary_flag",
        return_expectations={"incidence": 0.20},
    ),
# secondary care admissions
    admitted_before=patients.admitted_to_hospital(
        between=["pa_ca_date - 6 months", "pa_ca_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 1},
            "incidence": 0.4,
        }
    ),
    admitted_after=patients.admitted_to_hospital(
        between=["pa_ca_date", "pa_ca_date + 6 months", ],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 3},
            "incidence": 0.6,
        }
    ),
    emergency_care_before=patients.attended_emergency_care(
        between=["pa_ca_date - 6 months", "pa_ca_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 2},
            "incidence": 0.3,
        }
    ),
    emergency_care_after=patients.attended_emergency_care(
        between=["pa_ca_date", "pa_ca_date + 6 months"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 2},
            "incidence": 0.3,
        }
    ),
#mortality
    died_any=patients.died_from_any_cause(
        between=["pa_ca_date", "pa_ca_date + 6 months", ],
        returning="binary_flag",
        return_expectations={"incidence": 0.80},
    ),
    died_any_date=patients.died_from_any_cause(
        on_or_after="pa_ca_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2015-01-01"},
            "rate": "exponential_increase",
            "incidence": 0.80
        },
    ),
    # gp_consult_before=patients.with_gp_consultations(
    #     between=["pa_ca_date - 6 months", "pa_ca_date"],
    #     returning="number_of_matches_in_period",
    #     return_expectations={
    #         "int": {"distribution": "normal", "mean": 6, "stddev": 3},
    #         "incidence": 0.6,
    #     },
    # ),
    # gp_consult_after=patients.with_gp_consultations(
    #     between=["pa_ca_date", "pa_ca_date + 6 months"],
    #     returning="number_of_matches_in_period",
    #     return_expectations={
    #         "int": {"distribution": "normal", "mean": 6, "stddev": 3},
    #         "incidence": 0.6,
    #     },
    # ),
    # gp_PT_consult_before=patients.with_gp_consultations(
    #     between=["pa_ca_date - 6 months", "pa_ca_date"],
    #     returning="binary_flag",
    #     return_expectations={"incidence": 0.50},
    # ),
    # gp_PT_consult_after=patients.with_gp_consultations(
    #     between=["pa_ca_date", "pa_ca_date + 6 months"],
    #     returning="binary_flag",
    #     return_expectations={"incidence": 0.50},
    # ),
)
