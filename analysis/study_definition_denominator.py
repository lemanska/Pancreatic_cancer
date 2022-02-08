from cohortextractor import (
    StudyDefinition,
    patients
)
from codelists import *

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "2015-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
        },
    index_date="2015-01-01",
    population=patients.registered_as_of("index_date"),###how to get a reg date, 
    #this one is incorrect as is does not take into account ppl who reg later 
    dereg_date=patients.date_deregistered_from_all_supported_practices(
        on_or_after="index_date",
        date_format="YYYY-MM",
        return_expectations={"date": {"earliest": "index_date"},
        "incidence":0.2
        },
    ),
    registered=patients.registered_as_of(
        "2015-01-15",
        return_expectations={"incidence": 0.98}
    ),##loop this per month
)
