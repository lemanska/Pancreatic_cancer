from cohortextractor import (
    codelist_from_csv,
    codelist,
)

# DEMOGRAPHIC CODELIST
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)
ethnicity_codes_16 = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_16",
)
# Symptoms

jaundice = codelist_from_csv(
    "codelists/user-agleman-jaundice.csv",
    system="snomed",
    column="code",
)

# tests
ca19_9 = codelist_from_csv(
    "codelists/user-agleman-ca_19_9.csv",
    system="snomed",
    column="code",
)
CEA = codelist_from_csv(
    "codelists/user-agleman-cea.csv",
    system="snomed",
    column="code",
)
# Fast track referrals for paca
cancer_referral_codes = codelist_from_csv(
    "codelists/user-agleman-cancer_referrals_pancreatic_cancer_snomed.csv",
    system="snomed",
    column="code",
)
# treatment - enzyme replacement 
# this is not right as it is a medication - should be dmd system?
enzyme_replace = codelist_from_csv(
    "codelists/user-agleman-pancreatic-enzyme-replacement-therapy.csv",
    system="snomed",
    column="code",
)

chemotherapy_or_radiotherapy_codes = codelist_from_csv(
    "codelists/opensafely-chemotherapy-or-radiotherapy.csv",
    system="ctv3",
    column="CTV3ID",
)

pan_cancer_codes = codelist_from_csv(
    "codelists/user-agleman-pancreatic_cancer_snomed.csv",
    system="snomed",
    column="code",
)

diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes.csv", system="ctv3", column="CTV3ID"
)

liver_funct_codes = codelist_from_csv(
    "codelists/user-agleman-liver_function_tests.csv",
    system="snomed",
    column="code",
)

# pa ca icd10 for admisions and death
# pa_ca_icd10 = codelist(["C25", "C25.0", "C25.1", "C25.2", 
# "C25.3", "C25.4",
# "C25.7", "C25.8", "C25.8"], system ="icd10")

pa_ca_icd10 = codelist_from_csv(
    "codelists/user-agleman-pancreatic-cancer-icd10.csv",
    system="icd10",
    column="code",
)

# HbA1c
hba1c_new_codes = codelist(["XaPbt", "Xaeze", "Xaezd"], system="ctv3")

# Pancreatic resection
pancreatic_resection_OPCS4 = codelist(
    [
    "J55", "J55.1", "J55.2", "J55.3", "J55.8", "J55.9",
    "J56", "J56.1", "J56.2", "J56.3", "J56.4", "J56.8", "J56.9",
    "J57", "J57.1", "J57.2", "J57.3", "J57.4", "J57.5", "J57.6", "J57.8", "J57.9"
    ],
    system="opcs4")
