from cohortextractor import (
    StudyDefinition,
    Measure,
    codelist,
    codelist_from_csv,
    combine_codelists,
    filter_codes_by_category,
    patients,
)
from codelists import *

start_date = "2015-01-01"
end_date = "today"

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "2015-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
        },
    index_date="2015-01-01", # this will change monthly
# population all adults with pancreatic cancer (adult age at pancreatic cacncer diagnosis) 
# who have not had surgical resection after pa ca diagnosis, and who
# remian alive and registered at an index date (to allow altering denominator)
    population=patients.satisfying(
        """
        pa_ca
        AND (age >=18 AND age <= 110)
        AND registered
        AND NOT died_any
        AND NOT pancreatic_resection
        """
    ),
    pa_ca=patients.with_these_clinical_events(
        pan_cancer_codes,
        on_or_after="1950-01-01",
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
    age=patients.age_as_of(
        "pa_ca_date",
        return_expectations={
            "rate": "exponential_increase",
            "int": {"distribution": "population_ages"},
        },
    ),
    pancreatic_resection=patients.admitted_to_hospital(
        with_these_procedures=pancreatic_resection_OPCS4,
        on_or_after="pa_ca_date",
        returning="binary_flag",
        return_expectations={"incidence": 0.20},
        find_first_match_in_period=True,
    ),
    registered=patients.registered_as_of(
        "index_date",
        return_expectations={"incidence":0.95}
    ),
    died_any=patients.died_from_any_cause(
        on_or_after="index_date",
        returning="binary_flag",
        return_expectations={"incidence": 0.60},
    ),
# quality standard treatment panc enzymes prescriptions
    enzyme_replace=patients.with_these_medications(
        enzyme_replace,
        # on_or_before="pa_ca_date",
        between=["index_date - 1 months", "index_date"],
        returning="binary_flag",
        return_expectations={"incidence": 0.50},
    ),
)

measures = [
    Measure(
        id="enzymeRx_rate",
        numerator="enzyme_replace",
        denominator="population",
        group_by="population",
        small_number_suppression=True,
    ),
]