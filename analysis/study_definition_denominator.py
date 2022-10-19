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
    index_date="2015-01-01",
    population=patients.satisfying(
        """
        registered AND
        (age >=18 AND age <= 110)
        """
    ),
    age=patients.age_as_of(
        "index_date",
        return_expectations={
            "rate": "exponential_increase",
            "int": {"distribution": "population_ages"},
        },
    ),
    registered=patients.registered_as_of(
        "index_date",
        return_expectations={"incidence":0.95}
    ),
)

measures = [
    Measure(
        id="registered_rate",
        numerator="registered",
        denominator="population",
        group_by="population",
    ),
]
