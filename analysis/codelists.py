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
# cancer

cancer_referral_codes = codelist_from_csv(
    "codelists/user-agleman-cancer_referrals_pancreatic_cancer_snomed.csv",
    system="snomed",
    column="code",
)

chemotherapy_or_radiotherapy_codes = codelist_from_csv(
    "codelists/opensafely-chemotherapy-or-radiotherapy.csv",
    system="ctv3",
    column="CTV3ID",
)

pan_cancer_codes = codelist_from_csv(
    "codelists/user-agleman-cancer_referrals_pancreatic_cancer_snomed.csv",
    system="ctv3",
    column="code",
)

# HbA1c
hba1c_new_codes = codelist(["XaPbt", "Xaeze", "Xaezd"], system="ctv3")

# Ca death 
pa_ca_icd10 = codelist(["C25", "C25.0", "C25.1", "C25.2", "C25.3", "C25.4", 
                     "C25.7", "C25.8", "C25.8"], system ="icd10")