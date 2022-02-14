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
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "uniform",
        "incidence": 0.8,
    },

    index_date=start_date,

    population=patients.satisfying(
        """
       (age >=18 AND age <=120) AND
       (sex = 'M' OR sex = 'F')
       """
    ),
    age=patients.age_as_of(
        "index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.5, "F": 0.5}},
        }
    ),
    #demographics
    msoa=patients.registered_practice_as_of(
        "index_date",
        returning="msoa_code",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "E02002488": 0.1,
                    "E02002586": 0.1,
                    "E02002677": 0.1,
                    "E02002814": 0.1,
                    "E02002915": 0.1,
                    "E02003251": 0.1,
                    "E02000003": 0.2,
                    "E02003334": 0.1,
                    "E02002986": 0.1,
                },
            },
        },
    ),
    stp=patients.registered_practice_as_of(
        "index_date",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {
                "E54000005": 0.25, "E54000006": 0.25,
                "E54000007": 0.25, "E54000008": 0.25}},
        },
    ),
    imd_Q=patients.address_as_of(
        "index_date",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),
    imd_cat=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """index_of_multiple_deprivation >=1 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
        },
        index_of_multiple_deprivation=patients.address_as_of(
            "index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0.05,
                    "1": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5": 0.19,
                }
            },
        },
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
    # pancreawtic cancer variables
    pa_ca=patients.with_these_clinical_events(
        pan_cancer_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        include_date_of_match=True,
        include_month=True,
        include_day=True,
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    ca_date=patients.with_these_clinical_events(
        pan_cancer_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1},
    ),
    age_at_paca=patients.age_as_of(
        "ca_date",
        return_expectations={
            "rate": "exponential_increase",
            "int": {"distribution": "population_ages"},
            "float": {"distribution": "normal", "mean": 60, "stddev": 10},
            "incidence": 0.1,
        },
    ),
    # Will this work? I need BMI the closst to PaCa diagnosis, but not all will have this
    bmi=patients.most_recent_bmi(
        between=["index_date - 2 years", "index_date + 1 years"],
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2013-01-01", "latest": "today"},
            "float": {"distribution": "normal", "mean": 25, "stddev": 8},
            "incidence": 0.1
        }
    ),
    bmi_cat=patients.categorised_as({
        "No data": "DEFAULT",  
        "Underweight (<18.5)": """ bmi_value >= 5 AND bmi_value < 18.5""",
        "Normal (18.5-24.9)": """ bmi_value >= 18.5 AND bmi_value < 25""",
        "Overweight (25-29.9)": """ bmi_value >= 25 AND bmi_value < 30""",
        "Obese I (30-34.9)": """ bmi_value >= 30 AND bmi_value < 35""",
        "Obese II (35-39.9)": """ bmi_value >= 35 AND bmi_value < 40""",
        "Obese III (40+)": """ bmi_value >= 40 AND bmi_value < 100"""
    },
        bmi_value=patients.most_recent_bmi(
            between=["index_date - 2 years", "index_date + 1 years"],
            minimum_age_at_measurement=16
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "No data": 0.2,
                    "Underweight (<18.5)": 0.2,
                    "Normal (18.5-24.9)": 0.3,
                    "Overweight (25-29.9)": 0.1,
                    "Obese I (30-34.9)": 0.1,
                    "Obese II (35-39.9)": 0.05,
                    "Obese III (40+)": 0.05,
                }
            }
        }
    ),
    latest_hba1c=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        between=["index_date - 2 years", "index_date + 1 years"],
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        include_day=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.95,
        }
    ),
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        returning="binary_flag",
        # does this give me a date of diagnosis 
        include_date_of_match=True,
        include_month=True,
        include_day=True,
        return_expectations={"incidence": 0.30},
    ),
    # Diagnostic tests prior to diagnosis 
    liver_funct=patients.with_these_clinical_events(
        liver_funct_codes,
        between=["ca_date - 6 months", "ca_date"],
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={"incidence": 0.50},
    ),
    ca19_9=patients.with_these_clinical_events(
        ca19_9,
        between=["ca_date - 6 months", "ca_date"],
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={"incidence": 0.20},
    ),
    CEAntigen=patients.with_these_clinical_events(
        CEA,
        between=["ca_date - 6 months", "ca_date"],
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={"incidence": 0.10},
    ),
    # Symptoms, jaundice example
    jaundice=patients.with_these_clinical_events(
        jaundice,
        between=["ca_date - 6 months", "ca_date"],
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={"incidence": 0.60},
    ),
    # Referrals from primary care
    Refer=patients.with_these_clinical_events(
        cancer_referral_codes,
        # on_or_before="ca_date",
        between=["ca_date - 6 months", "ca_date"],
        find_last_match_in_period=True,
        returning="binary_flag",
        # returning="date", # can I have a count? 
        # date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.6},
    ),
    # treatment in primary care - panc enzymes new prescriptions 
    enz_repl=patients.with_these_clinical_events(
        enzyme_replace,
        # on_or_before="ca_date",
        between=["ca_date - 6 months", "ca_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.1,
        }
    ),
    adm_before=patients.admitted_to_hospital(
        between=["ca_date - 6 months", "ca_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 1},
            "incidence": 0.4,
        }
    ),
    adm_after=patients.admitted_to_hospital(
        between=["ca_date", "ca_date + 6 months", ],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 3},
            "incidence": 0.6,
        }
    ),
    adm_ca=patients.admitted_to_hospital(
        with_these_diagnoses=pa_ca_icd10,
        between=["ca_date - 6 months", "ca_date + 6 months", ],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 2},
            "incidence": 0.3,
        }
    ),
    adm_ca_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_diagnoses=pa_ca_icd10,
        on_or_after="ca_date",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2015-01-01"}},
    ),
    emergency_care_before=patients.attended_emergency_care(
        between=["ca_date - 6 months", "ca_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 2},
            "incidence": 0.3,
        }
    ),
    emergency_care_after=patients.attended_emergency_care(
        between=["ca_date", "ca_date + 6 months"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 2},
            "incidence": 0.3,
        }
    ),
    died=patients.died_from_any_cause(
        on_or_after="ca_date",
        returning="binary_flag",
        return_expectations={"incidence": 0.80},
    ),
    died_any=patients.died_from_any_cause(
        on_or_after="ca_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2015-01-01"},
            "rate": "exponential_increase",
            "incidence": 0.80
        },
    ),
    died_ca=patients.with_these_codes_on_death_certificate(
        pa_ca_icd10,
        on_or_after="ca_date",
        match_only_underlying_cause=False,
        return_expectations={"incidence": 0.50},
    ),
    died_ca_date=patients.with_these_codes_on_death_certificate(
        pa_ca_icd10,
        on_or_after="ca_date",
        match_only_underlying_cause=False,
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2015-01-01"},
            "rate": "exponential_increase",
            "incidence": 0.50
        },
    ),
    gp_count=patients.with_gp_consultations(
        between=["ca_date - 1 years", "ca_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 6, "stddev": 3},
            "incidence": 0.6,
        },
    ),
    care_home_type=patients.care_home_status_as_of(
        "ca_date",
        categorised_as={
            "PC":
            """
            IsPotentialCareHome
            AND LocationDoesNotRequireNursing='Y'
            AND LocationRequiresNursing='N'
            """,
            "PN":
            """
            IsPotentialCareHome
            AND LocationDoesNotRequireNursing='N'
            AND LocationRequiresNursing='Y'
            """,
            "PS": "IsPotentialCareHome",
            "PR": "NOT IsPotentialCareHome",
            "": "DEFAULT",
        },
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"PC": 0.05, "PN": 0.05, "PS": 0.05, "PR": 0.84, "": 0.01},},
        },
    ),
)

measures = [
    Measure(
        id="pa_ca_diagnosis_rate",
        numerator="pa_ca",
        denominator="population",
        group_by="population",
    ),
    Measure(
        id="pa_ca_by_region_rate",
        numerator="pa_ca",
        denominator="population",
        group_by="region",
        small_number_suppression=True,
    ),
        Measure(
        id="pa_ca_by_IMD_rate",
        numerator="pa_ca",
        denominator="population",
        group_by="imd_cat",
        small_number_suppression=True,
    ),
]
