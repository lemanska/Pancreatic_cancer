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

study = StudyDefinition(
    # define default dummy data behaviour
    default_expectations={
        "date": {"earliest": "2015-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.8,
    },

    # define the study index date
    index_date="2015-01-01",

    # define the study population
    #population=patients.registered_as_of("index_date"),#should we just include adults? 
    population=patients.all(),

    # define the study variables
    pa_ca=patients.with_these_clinical_events(
        pan_cancer_codes,
        on_or_after="index_date",
        find_last_match_in_period=True,
        include_date_of_match=True,
        include_month=True, 
        include_day=True,
        returning="binary_flag",# later could do it as cat for the type of pa ca
        return_expectations={"incidence": 0.1},
    ),
    region=patients.registered_practice_as_of(
        "index_date",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "North East": 0.1,
                    "North West": 0.1,
                    "Yorkshire and the Humber": 0.2,
                    "East Midlands": 0.1,
                    "West Midlands": 0.1,
                    "East of England": 0.1,
                    "London": 0.1,
                    "South East": 0.2,
                },
            },
        },
    ),
)

measures = [
    Measure(
        id="pa_ca_diagnosis",
        numerator="pa_ca",
        denominator="population",
        group_by="population"
    ),
    ###denominator is population? Total? should it be number of registered at that time?
    Measure(
        id="pa_ca_by_region",
        numerator="pa_ca",
        denominator="population",
        group_by="region"
        #small_number_suppression=True,
    ),
]
