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
        "incidence": 1,
        },
    index_date="2015-01-01",
    population=patients.all(),
    #population=patients.registered_as_of("index_date"),
    
    dereg_date=patients.date_deregistered_from_all_supported_practices(
        on_or_after="index_date",
        date_format="YYYY-MM",
        return_expectations={"date": {"earliest": "index_date"},
        "incidence":0.2
        },
    ),
    registered=patients.registered_as_of(
        "index_date",
        return_expectations={"incidence":0.95}
    ),##otherwise this could be looped if not using measures 
)

measures = [
    Measure(
        id="registered_rate",
        numerator="registered",
        denominator="population",
        group_by="population",
    ),
]