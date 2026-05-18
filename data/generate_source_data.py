"""
Generate synthetic source-system extracts for the TFS auto-finance EDP.

Simulates three separate operational source systems:
  - Origination : credit applications + applicants
  - Servicing   : booked contracts, monthly status snapshots, payments
  - Dealer      : dealer network + vehicle inventory

Output: one CSV per source table, written next to this script in data/.
Pure standard library. Fixed seed -> reproducible.

Run:  python3 data/generate_source_data.py
"""
import csv
import os
import random
from datetime import date, timedelta

random.seed(42)                       # reproducible runs
OUT_DIR = os.path.dirname(os.path.abspath(__file__))
TODAY = date(2026, 5, 17)

# ---- volumes ----------------------------------------------------------------
N_DEALERS   = 60
N_CUSTOMERS = 250
N_VEHICLES  = 350
N_APPS      = 300

# ---- reference value pools --------------------------------------------------
FIRST = ["James","Mary","Robert","Patricia","John","Jennifer","Michael","Linda",
         "David","Elizabeth","Wei","Priya","Mohammed","Sofia","Liam","Olivia",
         "Noah","Emma","Lucas","Ava","Arjun","Mei","Diego","Fatima"]
LAST  = ["Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis",
         "Singh","Patel","Chen","Nguyen","Kim","Tremblay","Roy","Gagnon",
         "Lee","Wong","Martin","Khan"]
MAKES = {"Toyota": ["Corolla","Camry","RAV4","Highlander","Tacoma","Prius"],
         "Lexus":  ["RX","NX","ES","UX","IS"]}
TRIMS      = ["Base","LE","XLE","Limited","Platinum"]
PROVINCES  = ["ON","ON","ON","QC","BC","AB"]          # Ontario-weighted
CITIES     = {"ON":["Markham","Toronto","Mississauga","Ottawa","London"],
              "QC":["Montreal","Laval","Quebec City"],
              "BC":["Vancouver","Burnaby","Surrey"],
              "AB":["Calgary","Edmonton"]}
REGIONS    = ["Central","Eastern","Western","Quebec"]
CHANNELS   = ["DEALER","ONLINE","BRANCH"]
PROD_TYPES = ["LOAN","LEASE"]
PAY_METHODS= ["PRE_AUTHORIZED","ONLINE_BANKING","CHEQUE"]
RISK_BANDS = ["PRIME","NEAR_PRIME","SUBPRIME"]


def rand_date(start: date, end: date) -> date:
    """A random date in [start, end]."""
    return start + timedelta(days=random.randint(0, (end - start).days))


def vin(i: int) -> str:
    """Synthetic 17-char VIN-like string, unique per index."""
    chars = "ABCDEFGHJKLMNPRSTUVWXYZ0123456789"
    body = "".join(random.choice(chars) for _ in range(11))
    return f"2T{body}{i:04d}"[:17]


def postal() -> str:
    L = "ABCEGHJKLMNPRSTVXY"
    D = "0123456789"
    return (random.choice(L)+random.choice(D)+random.choice(L)+" "
            + random.choice(D)+random.choice(L)+random.choice(D))


def phone() -> str:
    return f"({random.randint(200,999)}) {random.randint(200,999)}-{random.randint(1000,9999)}"


def write_csv(name: str, header: list, rows: list) -> None:
    path = os.path.join(OUT_DIR, name)
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    print(f"  {name:38s} {len(rows):5d} rows")


# =============================================================================
# 1. DEALER source system
# =============================================================================
dealers = []
for i in range(1, N_DEALERS + 1):
    prov = random.choice(PROVINCES)
    dealers.append([
        f"D{i:04d}",                                   # dealer_code (business key)
        f"{random.choice(['Markham','Pacific','Maple','Summit','Royal'])} "
        f"{random.choice(['Toyota','Lexus'])} {random.choice(['Centre','Motors'])}",
        random.choice(REGIONS),
        random.choice(CITIES[prov]),
        prov,
        random.choices(["ACTIVE","INACTIVE"], weights=[92,8])[0],
    ])
write_csv("dealer_dealers.csv",
          ["dealer_code","dealer_name","region","city","province","dealer_status"],
          dealers)

vehicles = []
for i in range(1, N_VEHICLES + 1):
    make  = random.choice(list(MAKES))
    model = random.choice(MAKES[make])
    vehicles.append([
        vin(i),                                        # vin (business key)
        make, model,
        random.randint(2021, 2026),                    # model_year
        random.choice(TRIMS),
        random.randint(24000, 78000),                  # msrp
    ])
write_csv("dealer_vehicles.csv",
          ["vin","make","model","model_year","trim","msrp"],
          vehicles)

# =============================================================================
# 2. ORIGINATION source system
# =============================================================================
orig_customers = []
for i in range(1, N_CUSTOMERS + 1):
    prov = random.choice(PROVINCES)
    orig_customers.append([
        f"C{i:06d}",                                   # customer_id (business key)
        random.choice(FIRST), random.choice(LAST),
        rand_date(date(1960,1,1), date(2004,12,31)).isoformat(),   # date_of_birth
        f"cust{i}@example.com",
        phone(),
        f"{random.randint(1,9999)} {random.choice(['King','Queen','Main','Bay','Yonge'])} St",
        random.choice(CITIES[prov]), prov, postal(),
        random.randint(540, 840),                      # credit_score
        random.choice(RISK_BANDS),
        "2026-04-30",                                  # source_extract_date
    ])
write_csv("origination_customers.csv",
          ["customer_id","first_name","last_name","date_of_birth","email","phone",
           "street_address","city","province","postal_code","credit_score",
           "risk_band","source_extract_date"],
          orig_customers)

applications = []
for i in range(1, N_APPS + 1):
    app_date = rand_date(date(2023,1,1), TODAY)
    decision = random.choices(["APPROVED","DECLINED"], weights=[78,22])[0]
    req_amt  = random.randint(15000, 75000)
    approved = req_amt if decision == "APPROVED" else 0
    applications.append([
        f"APP{i:06d}",                                 # application_id (business key)
        f"C{random.randint(1, N_CUSTOMERS):06d}",       # customer_id  -> origination cust
        f"D{random.randint(1, N_DEALERS):04d}",         # dealer_code
        vin(random.randint(1, N_VEHICLES)),             # vin
        random.choice(PROD_TYPES),
        req_amt,
        app_date.isoformat(),
        random.choice(CHANNELS),
        decision,
        approved,
        (app_date + timedelta(days=random.randint(1,9))).isoformat(),  # decision_date
    ])
write_csv("origination_applications.csv",
          ["application_id","customer_id","dealer_code","vin","product_type",
           "requested_amount","application_date","channel","credit_decision",
           "approved_amount","decision_date"],
          applications)

# =============================================================================
# 3. SERVICING source system  (only APPROVED applications become contracts)
# =============================================================================
contracts, contract_status, payments = [], [], []
servicing_cust_ids = set()
pay_seq = 0

for app in applications:
    if app[8] != "APPROVED":
        continue
    (application_id, customer_id, dealer_code, v, prod_type,
     req_amt, app_date_s, *_rest) = app
    contract_number = f"CTR{len(contracts)+1:06d}"
    term   = random.choice([36, 48, 60, 72])
    start  = date.fromisoformat(app_date_s) + timedelta(days=random.randint(3, 20))
    maturity = start + timedelta(days=term*30)
    amount_financed = req_amt
    apr    = round(random.uniform(2.9, 9.9), 2)
    residual = round(amount_financed * random.uniform(0.30, 0.55), 2) if prod_type=="LEASE" else 0
    contracts.append([
        contract_number, application_id, customer_id, v, dealer_code,
        prod_type, apr, term, amount_financed, residual,
        start.isoformat(), maturity.isoformat(),
    ])
    servicing_cust_ids.add(customer_id)

    # monthly status snapshots from start to min(today, maturity), capped at 24
    bal = float(amount_financed)
    monthly_principal = amount_financed / term
    snap = start
    months = 0
    while snap <= min(TODAY, maturity) and months < 24:
        delinquent = random.random() < 0.08
        bucket = random.choice(["1-30","31-60","61-90"]) if delinquent else "CURRENT"
        status = "DELINQUENT" if delinquent else ("PAID_OFF" if bal <= 0 else "ACTIVE")
        contract_status.append([
            contract_number, snap.isoformat(), status, bucket, round(max(bal,0),2),
        ])
        # a payment for that month
        if bal > 0:
            pay_seq += 1
            pay_amt = round(monthly_principal * (1 + apr/100/12), 2)
            payments.append([
                f"PMT{pay_seq:07d}", contract_number,
                (snap + timedelta(days=random.randint(0,5))).isoformat(),
                pay_amt, random.choice(PAY_METHODS),
            ])
            bal -= monthly_principal
        months += 1
        # advance ~1 month
        snap = (snap.replace(day=1) + timedelta(days=32)).replace(day=1)

write_csv("servicing_contracts.csv",
          ["contract_number","application_id","customer_id","vin","dealer_code",
           "contract_type","apr","term_months","amount_financed","residual_value",
           "start_date","maturity_date"],
          contracts)
write_csv("servicing_contract_status.csv",
          ["contract_number","status_date","contract_status","delinquency_bucket",
           "outstanding_balance"],
          contract_status)
write_csv("servicing_payments.csv",
          ["payment_id","contract_number","payment_date","payment_amount","payment_method"],
          payments)

# Servicing's OWN view of the customer -- same customer_id, but contact details
# may have been updated after origination. This is the multi-source integration
# case Data Vault is built for.
servicing_customers = []
for c in orig_customers:
    cid = c[0]
    if cid not in servicing_cust_ids:
        continue
    first, last = c[1], c[2]
    prov = random.choice(PROVINCES)
    # ~35% have an updated email / phone / address since origination
    updated = random.random() < 0.35
    email = f"{first.lower()}.{last.lower()}@mail.com" if updated else c[4]
    ph    = phone() if updated else c[5]
    servicing_customers.append([
        cid, first, last, email, ph,
        f"{random.randint(1,9999)} {random.choice(['Elm','Oak','Pine','Cedar'])} Ave",
        random.choice(CITIES[prov]), prov, postal(),
        "2026-05-15",                                  # source_extract_date (newer)
    ])
write_csv("servicing_customers.csv",
          ["customer_id","first_name","last_name","email","phone",
           "mailing_street","mailing_city","mailing_province","mailing_postal_code",
           "source_extract_date"],
          servicing_customers)

print("\nDone. Source extracts written to data/.")
