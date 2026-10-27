# Price to Sales Ratio [Gabremoku]

- url: https://www.tradingview.com/script/0Ek7UMvs-Price-to-Sales-Ratio-Gabremoku/
- type: indicator
- pine_id: PUB;3aa5651752ab4243bb67781d6a3e60f3
- version: 1.0

## Description

Price to Sales Ratio [Gabremoku] is a valuation indicator designed to help investors analyze how expensive or cheap a stock is relative to its revenue.

The script calculates the P/S ratio using market capitalization divided by total trailing-twelve-month revenue, then enriches that raw valuation with historical averages, rolling Z-score, percentile ranking, 52-week extremes, and sector benchmark comparison. The price-to-sales ratio is commonly used as a revenue multiple, especially for companies where earnings may be weak, negative, or highly variable.

This makes the indicator useful for growth stocks, cyclical companies, and early-stage businesses where price-to-earnings can be less informative than revenue-based valuation.

What it shows
📊 Current P/S Ratio — the live valuation multiple based on:

current stock price

total shares outstanding

trailing-twelve-month revenue

📈 Historical Average — choose between:

Cumulative Average for the full available history

Rolling Average based on a user-defined lookback in years

🧮 Z-Score Mode — switch from raw P/S to a statistical valuation view that shows how far the current ratio is from its rolling average in standard deviations.

📍 Historical Percentile — shows where the current P/S sits within its historical range over the selected lookback.

📅 52-Week High / Low — provides a fast valuation range reference for the last trading year.

🏭 Sector Benchmark — compare the company’s P/S ratio against a benchmark using:

Auto-detected sector

Sector index

Manual sector value

Why P/S matters
The P/S ratio tells you how much investors are paying for each dollar of company revenue. A lower P/S ratio is often considered more attractive when comparing similar companies in the same industry, but sector differences matter a lot.

That last part is important: P/S should not be judged in isolation. Technology companies often trade at much higher revenue multiples than energy, materials, or consumer businesses, so comparing a stock only against a generic threshold can be misleading. Sector-relative comparison is generally more meaningful than absolute comparison.

Benchmark logic
This indicator includes one of its strongest features: sector context.

It can automatically estimate a sector benchmark through:

exact ticker lookup

keyword-based sector detection

manual fallback sector selection

That matters because P/S multiples vary materially by industry, and valuation comparison is most useful when done against companies or sectors with similar economic characteristics.

The script then colors the main P/S line with a practical valuation model:

🟢 Green — P/S below benchmark, potentially undervalued relative to sector

🟠 Orange — P/S above benchmark but below historical average, more neutral / fair-value zone

🔴 Red — P/S above historical average, potentially expensive relative to its own history

Features
✅ Live Price-to-Sales ratio calculation

✅ Uses total shares outstanding and TTM revenue

✅ Cumulative or rolling historical average

✅ Z-score mode for statistical valuation

✅ Historical percentile ranking

✅ 52-week valuation high/low

✅ Sector benchmark comparison

✅ Auto sector detection with hybrid logic

✅ Manual and sector-index benchmark options

✅ Dynamic color coding based on valuation regime

✅ Ultra-smooth gradient fill between current P/S and benchmark

✅ Dashboard with key statistics

✅ Last-value chart label

How to use
A practical way to read the script is:

🔎 Start with the current P/S ratio.

📊 Compare it with the sector benchmark to see whether the stock trades richer or cheaper than its industry.

🧮 Check the Z-score to understand whether the current valuation is stretched versus its own historical behavior.

📍 Use the percentile to see where today’s valuation sits within the selected lookback window.

This approach combines absolute valuation, relative valuation, and historical context in one screen, which is much more useful than reading the raw P/S ratio alone.

Operational suggestion
💡 Suggested workflow

🟢 Value watchlist setup: look for stocks with current P/S below sector benchmark and below their own historical average. A lower P/S relative to peers can indicate more attractive valuation, provided the business quality is not deteriorating.

🟠 Neutral zone: if the stock is above benchmark but still below or near its historical average, it may be in a fairer valuation zone rather than clearly cheap or expensive.

🔴 Stretch zone: if the stock is trading with a high Z-score, high percentile, and above both benchmark and average, it may be priced aggressively relative to its own history and sector context.

📈 Best use case: this indicator is especially useful for companies with unstable earnings, where P/E may be less reliable and revenue multiples can provide a cleaner valuation anchor.

A strong practical rule:

use P/S for initial screening

use sector benchmark for context

use Z-score and percentile for timing

then confirm with margins, growth, debt, and cash flow

Because revenue alone does not tell you whether that revenue is profitable.

Notes
This indicator is best suited for relative valuation analysis, not for making a final investment decision on its own. A low P/S ratio can reflect undervaluation, but it can also reflect weak margins, declining sales quality, or poor business outlook, so it should always be paired with profitability and growth analysis.

Author: Gabremoku

## Source Code

````pine
//@version=6
indicator("Price to Sales Ratio [Gabremoku]", shorttitle="P/S Ratio [Gabremoku]", overlay=false)
// Indicator version V0.9

// --- Inputs ---
use_cumulative_avg = input.bool(true, "Use Cumulative Average (Default)", tooltip="If true, uses the historical average since the beginning of data. If false, uses the Moving Average based on the Lookback Period.")
lookback_years = input.int(5, "Lookback Period (Years)", minval=1, tooltip="Period for Moving Average (if enabled), Z-Score, and Percentile calculations.")
show_dashboard = input.bool(true, "Show Dashboard", tooltip="Display a table with current statistics.")
show_zscore = input.bool(false, "Z-Score Mode", tooltip="If enabled, plots the Z-Score instead of the P/S Ratio.")

// --- Benchmark Settings ---
enable_benchmark = input.bool(true, "Enable Sector Benchmark", tooltip="Show a horizontal line representing the sector average P/S ratio. Only active in P/S mode.")
benchmark_mode = input.string("Auto Detect Sector", "Benchmark Mode", options=["Auto Detect Sector", "From Sector Index", "Manual"], tooltip="Auto Detect Sector: automatically detects sector from symbol name. From Sector Index: retrieves P/S from a sector index. Manual: enter value manually.")
sector_selection = input.string("Not Detected", "Sector (Fallback)", options=["Not Detected", "Technology", "Healthcare", "Energy", "Financial Services", "Consumer Cyclical", "Consumer Defensive", "Industrials", "Communication Services", "Utilities", "Real Estate", "Materials", "Basic Materials"], tooltip="Select the sector as fallback if auto-detection fails (used only in 'Auto Detect Sector' mode). 'Not Detected' uses median benchmark value of all sectors.")
// IMPORTANT: must be in the form EXCHANGE:SYMBOL, e.g. AMEX:XLV, NASDAQ:XLK, MIL:FTSEMIB
sector_index_symbol = input.string("AMEX:XLV", "Sector Index Symbol", tooltip="Enter the sector index in the form EXCHANGE:SYMBOL (e.g., AMEX:XLV, NASDAQ:XLK). Used only in 'From Sector Index' mode.")
benchmark_value_manual = input.float(2.5, "Manual Benchmark P/S Value", minval=0, step=0.1, tooltip="Average P/S ratio for the sector (only used in Manual mode).")

// --- HYBRID SECTOR DETECTION SYSTEM ---
// Priority: 1. Exact Ticker Lookup → 2. Keyword Matching → 3. Manual Fallback

// ===== LOOKUP TABLE HELPER FUNCTIONS (ONE TICKER PER LINE) =====

lookup_tech(ticker) =>
    switch ticker
        "AAPL" => true
        "MSFT" => true
        "NVDA" => true
        "GOOG" => true
        "GOOGL" => true
        "META" => true
        "AVGO" => true
        "QCOM" => true
        "CRM" => true
        "ADBE" => true
        "INTC" => true
        "AMD" => true
        "CSCO" => true
        "ORCL" => true
        "SNOW" => true
        "NOW" => true
        "NET" => true
        "DDOG" => true
        "CRWD" => true
        "ZS" => true
        "OKTA" => true
        "PANW" => true
        "FTNT" => true
        "SPLK" => true
        "TWLO" => true
        "TTD" => true
        "ROKU" => true
        "PINS" => true
        "SNAP" => true
        "COIN" => true
        "MSTR" => true
        "PLTR" => true
        "AI" => true
        "MRVL" => true
        "LRCX" => true
        "KLAC" => true
        "ASML" => true
        "AMAT" => true
        "ARM" => true
        "DOCN" => true
        => false

lookup_healthcare(ticker) =>
    switch ticker
        "JNJ" => true
        "UNH" => true
        "PFE" => true
        "ABBV" => true
        "TMO" => true
        "MRK" => true
        "LLY" => true
        "AZN" => true
        "NVO" => true
        "AMGN" => true
        "GILD" => true
        "REGN" => true
        "BIIB" => true
        "VRTX" => true
        "BNTX" => true
        "MRNA" => true
        "SRPT" => true
        "JAZZ" => true
        "EXEL" => true
        "INCY" => true
        "CELG" => true
        "CDNA" => true
        "SCPH" => true
        "VCYT" => true
        "CRTX" => true
        "IOVA" => true
        "ENTA" => true
        "OPCH" => true
        "CVS" => true
        "CI" => true
        "HUM" => true
        "ANTM" => true
        "MOH" => true
        "CNC" => true
        "DVA" => true
        "HCA" => true
        "HOLX" => true
        "ISRG" => true
        "ALGN" => true
        "RMD" => true
        => false

lookup_financial(ticker) =>
    switch ticker
        "JPM" => true
        "BAC" => true
        "WFC" => true
        "C" => true
        "GS" => true
        "MS" => true
        "BLK" => true
        "SCHW" => true
        "TROW" => true
        "STT" => true
        "BK" => true
        "AXP" => true
        "V" => true
        "MA" => true
        "COF" => true
        "IVZ" => true
        "AMG" => true
        "FIS" => true
        "FISV" => true
        "GPN" => true
        "ADP" => true
        "BR" => true
        "BX" => true
        "HOOD" => true
        "UPST" => true
        "LC" => true
        "SOFI" => true
        "PYPL" => true
        => false

lookup_consumer_cyclical(ticker) =>
    switch ticker
        "NKE" => true
        "HD" => true
        "LOW" => true
        "TGT" => true
        "COST" => true
        "ROST" => true
        "TJX" => true
        "BBY" => true
        "RH" => true
        "DKS" => true
        "F" => true
        "GM" => true
        "STLA" => true
        "TM" => true
        "HMC" => true
        "NIO" => true
        "XPEV" => true
        "LI" => true
        "RIVN" => true
        "LCID" => true
        "MCD" => true
        "SBUX" => true
        "YUM" => true
        "CMG" => true
        "DPZ" => true
        "DIN" => true
        "WEN" => true
        "LVS" => true
        "WYNN" => true
        "MGM" => true
        "CZR" => true
        "CCL" => true
        "RCL" => true
        "NCLH" => true
        "AMZN" => true
        "SHOP" => true
        "ETSY" => true
        "EBAY" => true
        "MELI" => true
        => false

lookup_consumer_defensive(ticker) =>
    switch ticker
        "PG" => true
        "KO" => true
        "PEP" => true
        "WMT" => true
        "PM" => true
        "MO" => true
        "CL" => true
        "CLX" => true
        "KMB" => true
        "GIS" => true
        "CPB" => true
        "SJM" => true
        "HSY" => true
        "MDLZ" => true
        "MNST" => true
        "TAP" => true
        "STZ" => true
        => false

lookup_energy(ticker) =>
    switch ticker
        "XOM" => true
        "CVX" => true
        "COP" => true
        "SLB" => true
        "HAL" => true
        "MPC" => true
        "VLO" => true
        "PSX" => true
        "OXY" => true
        "MRO" => true
        "EOG" => true
        "DVN" => true
        "FANG" => true
        "APA" => true
        "CTRA" => true
        "EQT" => true
        "SWN" => true
        "RRC" => true
        "CNX" => true
        "AR" => true
        => false

lookup_utilities(ticker) =>
    switch ticker
        "NEE" => true
        "DUK" => true
        "SO" => true
        "D" => true
        "AEP" => true
        "EXC" => true
        "SRE" => true
        "XEL" => true
        "ES" => true
        "PEG" => true
        "ED" => true
        "EIX" => true
        "FE" => true
        "ETR" => true
        "LNT" => true
        "NI" => true
        "PNW" => true
        "PPL" => true
        "AEE" => true
        "WEC" => true
        => false

lookup_realestate(ticker) =>
    switch ticker
        "AMT" => true
        "PLD" => true
        "EQIX" => true
        "PSA" => true
        "WELL" => true
        "VICI" => true
        "O" => true
        "SPG" => true
        "DLR" => true
        "EQR" => true
        "AVB" => true
        "UDR" => true
        "MAA" => true
        "LSI" => true
        "NXRT" => true
        "CPT" => true
        "ESS" => true
        "AIR" => true
        "INVH" => true
        "AMH" => true
        => false

lookup_industrials(ticker) =>
    switch ticker
        "BA" => true
        "CAT" => true
        "HON" => true
        "GE" => true
        "DE" => true
        "LMT" => true
        "RTX" => true
        "NOC" => true
        "GD" => true
        "CMI" => true
        "EMR" => true
        "ETN" => true
        "IR" => true
        "PH" => true
        "ROK" => true
        "SWK" => true
        "TT" => true
        "AOS" => true
        "DOV" => true
        "FAST" => true
        => false

lookup_materials(ticker) =>
    switch ticker
        "LIN" => true
        "APD" => true
        "SHW" => true
        "ECL" => true
        "PPG" => true
        "FCX" => true
        "NEM" => true
        "SCCO" => true
        "TECK" => true
        "X" => true
        "CLF" => true
        "NUE" => true
        "STLD" => true
        "CMC" => true
        "AA" => true
        "CENX" => true
        "KALU" => true
        => false

lookup_communications(ticker) =>
    switch ticker
        "NFLX" => true
        "DIS" => true
        "CMCSA" => true
        "CHTR" => true
        "LBRDK" => true
        "FOXA" => true
        "FOX" => true
        "NWSA" => true
        "PARA" => true
        "WBD" => true
        "SPOT" => true
        "LUMN" => true
        "VZ" => true
        "T" => true
        "TMUS" => true
        "SIRI" => true
        "ATUS" => true
        "VMEO" => true
        => false

// === MAIN LOOKUP FUNCTION (CALLED AFTER HELPERS DEFINED) ===
lookup_sector_from_ticker() =>
    ticker = syminfo.ticker
    if lookup_tech(ticker)
        "Technology"
    else if lookup_healthcare(ticker)
        "Healthcare"
    else if lookup_financial(ticker)
        "Financial Services"
    else if lookup_consumer_cyclical(ticker)
        "Consumer Cyclical"
    else if lookup_consumer_defensive(ticker)
        "Consumer Defensive"
    else if lookup_energy(ticker)
        "Energy"
    else if lookup_utilities(ticker)
        "Utilities"
    else if lookup_realestate(ticker)
        "Real Estate"
    else if lookup_industrials(ticker)
        "Industrials"
    else if lookup_materials(ticker)
        "Materials"
    else if lookup_communications(ticker)
        "Communication Services"
    else
        na

detect_sector_from_symbol() =>
    ticker = syminfo.ticker
    ticker_upper = str.upper(ticker)
    
    // Healthcare keywords and tickers (checked first as it's most specific)
    healthcare_keywords = array.from("HEALTH", "MED", "BIO", "PHARMA", "PHARMACEUTICAL", "DRUG", "MEDICAL", "HOSPITAL", "CLINIC", "LAB", "LABORATORY", "DIAGNOSTIC", "THERAPEUTIC", "VACCINE", "TREATMENT", "CARE", "PATIENT", "PFIZER", "PFE", "JNJ", "JOHNSON", "MERCK", "MRK", "BRISTOL", "BMY", "ABBV", "GILD", "GILEAD", "AMGN", "AMGEN", "REGN", "REGENERON", "UNH", "UNITEDHEALTH", "CVS", "CI", "CIGNA", "HUM", "HUMANA", "ANTM", "ANTHEM", "DVA", "DAVITA", "HCA", "HCAHEALTH", "CNC", "CENTENE", "MOH", "MOLINA", "ELV", "ELEVANCE", "HOLX", "HOLOGIC", "ILMN", "ILLUMINA", "TMO", "THERMO", "DHR", "DANAHER", "BSX", "BOSTON", "SYK", "STRYKER", "ZBH", "ZIMMER", "BAX", "BAXTER", "BDX", "BECTON", "EW", "EDWARDS", "RMD", "RESMED", "ALGN", "ALIGN", "ISRG", "INTUITIVE", "DXCM", "DEXCOM", "SWAV", "SHOCKWAVE")
    
    // Technology keywords and tickers
    tech_keywords = array.from("TECH", "SOFT", "SOFTWARE", "HARDWARE", "SEMI", "SEMICONDUCTOR", "CHIP", "INTERNET", "CLOUD", "AI", "ARTIFICIAL", "DATA", "DIGITAL", "COMPUTER", "ELECTRONIC", "AAPL", "APPLE", "MSFT", "MICROSOFT", "GOOGL", "GOOGLE", "META", "FACEBOOK", "AMZN", "AMAZON", "NVDA", "NVIDIA", "INTC", "INTEL", "AMD", "ADVANCED", "TSM", "TAIWAN", "AVGO", "BROADCOM", "CRM", "SALESFORCE", "ORCL", "ORACLE", "ADBE", "ADOBE", "CSCO", "CISCO", "QCOM", "QUALCOMM", "TXN", "TEXAS", "NOW", "SERVICENOW", "SNOW", "SNOWFLAKE", "NET", "CLOUDFLARE", "DDOG", "DATADOG", "CRWD", "CROWDSTRIKE", "ZS", "ZSCALER", "OKTA", "PANW", "PALO", "FTNT", "FORTINET", "SPLK", "SPLUNK", "DOCN", "DIGITALOCEAN", "NETAPP", "HPQ", "HEWLETT", "DELL", "HPE")
    
    // Energy keywords and tickers
    energy_keywords = array.from("ENERGY", "OIL", "GAS", "NATURAL", "PETROLEUM", "REFINERY", "DRILLING", "EXPLORATION", "PIPELINE", "LNG", "CRUDE", "FUEL", "XOM", "EXXON", "CVX", "CHEVRON", "SLB", "SCHLUMBERGER", "HAL", "HALLIBURTON", "COP", "CONOCO", "MPC", "MARATHON", "VLO", "VALERO", "PSX", "PHILLIPS", "OXY", "OCCIDENTAL", "EOG", "DVN", "DEVON", "FANG", "DIAMONDBACK", "MRO", "APA", "APACHE", "CTRA", "COTERRA", "EQT", "SWN", "SOUTHWESTERN", "RRC", "RANGE", "NBL", "NOBLE", "CNX", "AR", "ANTERO", "GPOR", "GULFPORT", "MTDR", "MATADOR", "PDC", "SM", "CRK", "COMSTOCK", "LPI", "LAREDO")
    
    // Financial Services keywords and tickers
    financial_keywords = array.from("BANK", "FIN", "FINANCIAL", "INSURANCE", "INSUR", "INVESTMENT", "ASSET", "WEALTH", "CREDIT", "LENDING", "MORTGAGE", "TRUST", "CAPITAL", "JPM", "JPMORGAN", "BAC", "BANKOFAMERICA", "WFC", "WELLS", "C", "CITI", "CITIGROUP", "GS", "GOLDMAN", "MS", "MORGAN", "BLK", "BLACKROCK", "SCHW", "CHARLES", "TROW", "TROWEPRICE", "BEN", "FRANKLIN", "IVZ", "INVESCO", "STT", "STATESTREET", "BK", "BANKOFNEWYORK", "COF", "CAPITALONE", "AXP", "AMERICANEXPRESS", "V", "VISA", "MA", "MASTERCARD", "PYPL", "PAYPAL", "SQ", "SQUARE", "FIS", "FIDELITY", "FISV", "FISERV", "GPN", "GLOBAL", "ADP", "AUTOMATIC", "BR", "BROADRIDGE", "HOOD", "ROBINHOOD", "SOFI", "LC", "LENDINGCLUB", "UPST", "UPSTART")
    
    // Consumer Cyclical keywords and tickers
    consumer_cyclical_keywords = array.from("AUTO", "AUTOMOTIVE", "CAR", "RETAIL", "ECOMMERCE", "RESTAURANT", "HOTEL", "TRAVEL", "LEISURE", "ENTERTAINMENT", "GAMING", "CASINO", "TSLA", "TESLA", "F", "FORD", "GM", "GENERALMOTORS", "STLA", "STELLANTIS", "TM", "TOYOTA", "HMC", "HONDA", "NIO", "XPEV", "XPENG", "LI", "RIVN", "RIVIAN", "LCID", "LUCID", "AMZN", "AMAZON", "HD", "HOMEDEPOT", "LOW", "LOWES", "NKE", "NIKE", "SBUX", "STARBUCKS", "MCD", "MCDONALDS", "YUM", "CMG", "CHIPOTLE", "DPZ", "DOMINOS", "WEN", "WENDYS", "DIN", "DINEEQUITY", "TGT", "TARGET", "WMT", "WALMART", "COST", "COSTCO", "TJX", "ROST", "ROSS", "BBY", "BESTBUY", "GME", "GAMESTOP", "AMC", "NCLH", "NORWEGIAN", "CCL", "CARNIVAL", "RCL", "ROYAL", "LVS", "LASVEGAS", "WYNN", "MGM", "CZR", "CAESARS", "ETSY", "EBAY", "SHOP", "SHOPIFY", "MELI", "MERCADOLIBRE", "SE", "SEA", "PDD", "PINDUODUO", "JD", "BABA", "ALIBABA")
    
    // Consumer Defensive keywords and tickers
    consumer_defensive_keywords = array.from("FOOD", "BEVERAGE", "GROCERY", "STAPLE", "CONSUMER", "PACKAGED", "HOUSEHOLD", "PERSONAL", "CARE", "PG", "PROCTER", "KO", "COCA", "PEP", "PEPSI", "WMT", "WALMART", "COST", "COSTCO", "CL", "COLGATE", "KMB", "KIMBERLY", "CHD", "CHURCH", "CLX", "CLOROX", "GIS", "GENERAL", "CPB", "CAMPBELL", "SJM", "SMUCKER", "HSY", "HERSHEY", "MDLZ", "MONDELEZ", "TAP", "MOLSON", "BFB", "BROWN", "STZ", "CONSTELLATION", "TGT", "TARGET", "KR", "KROGER", "ACI", "ALBERTSONS", "SFM", "SPROUTS", "WMK", "WEIS", "CASY", "CASEYS", "MKC", "MCCORMICK", "SPB", "SPECTRUM", "LW", "LAMB", "FLO", "FLOWERS")
    
    // Industrials keywords and tickers
    industrials_keywords = array.from("AEROSPACE", "DEFENSE", "MACHINERY", "EQUIPMENT", "TRANSPORTATION", "LOGISTICS", "SUPPLY", "MANUFACTURING", "INDUSTRIAL", "BA", "BOEING", "LMT", "LOCKHEED", "RTX", "RAYTHEON", "NOC", "NORTHROP", "GD", "GENERAL", "HON", "HONEYWELL", "GE", "GENERALELECTRIC", "CAT", "CATERPILLAR", "DE", "DEERE", "CMI", "CUMMINS", "EMR", "EMERSON", "ETN", "EATON", "IR", "INGERSOLL", "PH", "PARKER", "ROK", "ROCKWELL", "SWK", "STANLEY", "TT", "TRANE", "WWD", "WOODWARD", "AME", "AMETEK", "AOS", "SMITH", "DOV", "DOVER", "FAST", "FASTENAL", "GWW", "GRAINGER", "ZBRA", "ZEBRA", "HWM", "HOWMET", "ALLE", "ALLEGION", "CSL", "CARLISLE", "CHRW", "CH", "EXPD", "EXPEDITORS", "KNX", "KNIGHT", "ODFL", "OLD", "XPO", "JBHT", "HUNT", "ARCB", "ARCBEST", "YRCW", "YELLOW")
    
    // Communication Services keywords and tickers
    communication_keywords = array.from("MEDIA", "ENTERTAINMENT", "TELECOM", "WIRELESS", "BROADBAND", "CABLE", "STREAMING", "BROADCAST", "PUBLISHING", "GOOGL", "GOOGLE", "META", "FACEBOOK", "NFLX", "NETFLIX", "DIS", "DISNEY", "CMCSA", "COMCAST", "T", "AT&T", "VZ", "VERIZON", "TMUS", "TMobile", "CHTR", "CHARTER", "LBRDK", "LIBERTY", "FOXA", "FOX", "NWSA", "NEWS", "PARA", "PARAMOUNT", "WBD", "WARNER", "SPOT", "SPOTIFY", "SIRI", "SIRIUS", "LUMN", "LUMEN", "ATUS", "ALTICE", "CABO", "CABLEONE", "OTTR", "OTTER", "SHEN", "SHENANDOAH")
    
    // Utilities keywords and tickers
    utilities_keywords = array.from("POWER", "ELECTRIC", "ELECTRICITY", "WATER", "GAS", "NATURALGAS", "RENEWABLE", "SOLAR", "WIND", "NUCLEAR", "UTILITY", "NEE", "NEXTERRA", "DUK", "DUKE", "SO", "SOUTHERN", "D", "DOMINION", "AEP", "AMERICAN", "EXC", "EXELON", "SRE", "SEMPRA", "XEL", "XCEL", "ES", "EVERGY", "PEG", "PUBLIC", "ED", "CONSOLIDATED", "EIX", "EDISON", "FE", "FIRSTENERGY", "ETR", "ENTERGY", "AEE", "AMEREN", "CMS", "LNT", "ALLIANT", "NI", "NISOURCE", "PNW", "PPL", "WEC", "ATO", "ATMOS", "AWK", "SJW", "YORW", "YORK")
    
    // Real Estate keywords and tickers
    real_estate_keywords = array.from("REIT", "REITS", "REALTY", "PROPERTY", "PROPERTIES", "REALESTATE", "ESTATE", "LAND", "DEVELOPMENT", "AMT", "AMERICANTOWER", "PLD", "PROLOGIS", "EQIX", "EQUINIX", "PSA", "PUBLIC", "WELL", "WELLTOWER", "VICI", "SPG", "SIMON", "O", "DLR", "DIGITAL", "EXR", "EXTRA", "AVB", "AVALON", "EQR", "EQUITY", "UDR", "MAA", "MID", "CPT", "CAMDEN", "ESS", "ESSEX", "INVH", "INVITATION", "AMH", "AMERICAN", "SUI", "SUN", "BRT", "IRT", "INDEPENDENCE", "AIRC", "APARTMENT", "NMRK", "NEWMARK", "CBRE", "JLL", "JONES", "CWK", "CUSHMAN")
    
    // Materials/Basic Materials keywords and tickers
    materials_keywords = array.from("CHEMICAL", "STEEL", "METAL", "MINING", "MINERAL", "CONSTRUCTION", "BUILDING", "MATERIAL", "CEMENT", "GLASS", "PAPER", "FORESTRY", "LIN", "LINDE", "APD", "AIR", "SHW", "SHERWIN", "ECL", "ECOLAB", "DD", "DUPONT", "PPG", "FCX", "FREEPORT", "NEM", "NEWMONT", "VALE", "RIO", "RIOTINTO", "BHP", "SCCO", "SOUTHERN", "TECK", "X", "US", "CLF", "CLEVELAND", "NUE", "NUCOR", "STLD", "RS", "RELIANCE", "CMC", "COMMERCIAL", "SID", "GGB", "GERDAU", "TX", "TENARIS", "MT", "ARCELOR", "PKX", "POSCO", "AN", "ALCOA", "AA", "CENX", "CENTURY", "KALU", "KAISER", "NWPX", "NORTHWEST")
    
    // Check Healthcare first (most specific)
    string detected_sector = na
    for i = 0 to array.size(healthcare_keywords) - 1
        if str.contains(ticker_upper, array.get(healthcare_keywords, i))
            detected_sector := "Healthcare"
            break
    
    // Check Technology if not detected yet
    if na(detected_sector)
        for i = 0 to array.size(tech_keywords) - 1
            if str.contains(ticker_upper, array.get(tech_keywords, i))
                detected_sector := "Technology"
                break
    
    // Check Energy if not detected yet
    if na(detected_sector)
        for i = 0 to array.size(energy_keywords) - 1
            if str.contains(ticker_upper, array.get(energy_keywords, i))
                detected_sector := "Energy"
                break
    
    // Check Financial Services if not detected yet
    if na(detected_sector)
        for i = 0 to array.size(financial_keywords) - 1
            if str.contains(ticker_upper, array.get(financial_keywords, i))
                detected_sector := "Financial Services"
                break
    
    // Check Consumer Cyclical if not detected yet
    if na(detected_sector)
        for i = 0 to array.size(consumer_cyclical_keywords) - 1
            if str.contains(ticker_upper, array.get(consumer_cyclical_keywords, i))
                detected_sector := "Consumer Cyclical"
                break
    
    // Check Consumer Defensive if not detected yet
    if na(detected_sector)
        for i = 0 to array.size(consumer_defensive_keywords) - 1
            if str.contains(ticker_upper, array.get(consumer_defensive_keywords, i))
                detected_sector := "Consumer Defensive"
                break
    
    // Check Industrials if not detected yet
    if na(detected_sector)
        for i = 0 to array.size(industrials_keywords) - 1
            if str.contains(ticker_upper, array.get(industrials_keywords, i))
                detected_sector := "Industrials"
                break
    
    // Check Communication Services if not detected yet
    if na(detected_sector)
        for i = 0 to array.size(communication_keywords) - 1
            if str.contains(ticker_upper, array.get(communication_keywords, i))
                detected_sector := "Communication Services"
                break
    
    // Check Utilities if not detected yet
    if na(detected_sector)
        for i = 0 to array.size(utilities_keywords) - 1
            if str.contains(ticker_upper, array.get(utilities_keywords, i))
                detected_sector := "Utilities"
                break
    
    // Check Real Estate if not detected yet
    if na(detected_sector)
        for i = 0 to array.size(real_estate_keywords) - 1
            if str.contains(ticker_upper, array.get(real_estate_keywords, i))
                detected_sector := "Real Estate"
                break
    
    // Check Materials if not detected yet
    if na(detected_sector)
        for i = 0 to array.size(materials_keywords) - 1
            if str.contains(ticker_upper, array.get(materials_keywords, i))
                detected_sector := "Materials"
                break
    
    // Return detected sector or na if cannot detect
    detected_sector

// --- Sector Benchmark Mapping Function ---
// Returns typical P/S ratio averages for different sectors (based on market data)
// Median of all sector benchmarks: (1.5, 1.8, 1.8, 1.9, 1.9, 2.0, 2.2, 3.1, 3.5, 4.2, 5.5, 8.5) = 2.1
get_sector_benchmark(sector) =>
    switch sector
        "Not Detected" => 2.1  // Median of all sector benchmarks
        "Technology" => 5.5
        "Healthcare" => 4.2
        "Energy" => 1.8
        "Financial Services" => 3.1
        "Consumer Cyclical" => 1.5
        "Consumer Defensive" => 1.8
        "Industrials" => 2.2
        "Communication Services" => 3.5
        "Utilities" => 2.0
        "Real Estate" => 8.5
        "Materials" => 1.9
        "Basic Materials" => 1.9
        => 2.1  // Default fallback (median)

// --- Financial Data Retrieval ---
// 1. Get Total Shares Outstanding (Fiscal Quarter)
shares_outstanding = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ")

// 2. Get Total Revenue (Trailing Twelve Months)
total_revenue = request.financial(syminfo.tickerid, "TOTAL_REVENUE", "TTM")

// 3. Get Sector Index P/S Ratio (if using sector index mode)
float sector_index_ps = na
if benchmark_mode == "From Sector Index" and sector_index_symbol != ""
    // Retrieve financial data from sector index
    sector_shares = request.financial(sector_index_symbol, "TOTAL_SHARES_OUTSTANDING", "FQ")
    sector_revenue = request.financial(sector_index_symbol, "TOTAL_REVENUE", "TTM")
    sector_close = request.security(sector_index_symbol, timeframe.period, close, lookahead=barmerge.lookahead_off)
    sector_market_cap = sector_close * sector_shares
    sector_index_ps := (not na(sector_revenue) and sector_revenue != 0) ? (sector_market_cap / sector_revenue) : na

// --- Calculation ---

// Calculate Market Capitalization
market_cap = close * shares_outstanding

// Calculate P/S Ratio
ps_ratio = (not na(total_revenue) and total_revenue != 0) ? (market_cap / total_revenue) : na

// Constants for Time-Based Calculations
days_in_year = 252
lookback_length = lookback_years * days_in_year

// 1. Cumulative Average (Historical Mean) - Restored Default
var float sum_ps = 0.0
var int count_ps = 0
if not na(ps_ratio)
    sum_ps := sum_ps + ps_ratio
    count_ps := count_ps + 1
ps_avg_cumulative = count_ps > 0 ? sum_ps / count_ps : na

// 2. Moving Average (SMA) - Alternative
ps_avg_sma = ta.sma(ps_ratio, lookback_length)

// Determine which Average to use for Plotting and Dashboard
ps_avg_display = use_cumulative_avg ? ps_avg_cumulative : ps_avg_sma

// 3. Standard Deviation & Z-Score (Point 3)
// Note: Z-Score is typically calculated using a rolling window (SMA) to reflect current volatility.
// We will use the Rolling Mean (SMA) for Z-Score calculation to ensure statistical consistency with Rolling StdDev.
ps_std = ta.stdev(ps_ratio, lookback_length)
z_score = (ps_ratio - ps_avg_sma) / ps_std

// 4. Historical Percentile (Point 4)
percentile = ta.percentrank(ps_ratio, lookback_length)

// 5. 52-Week High/Low
high_52w = ta.highest(ps_ratio, days_in_year)
low_52w = ta.lowest(ps_ratio, days_in_year)

// --- Determine Sector Based on Mode ---
// Get the actual sector to use (either from selection or auto-detection)
actual_sector = switch benchmark_mode
    "Auto Detect Sector" => 
        // HYBRID SYSTEM: 1. Try Lookup Table â†’ 2. Try Keyword Matching â†’ 3. Use Manual Fallback
        lookup_result = lookup_sector_from_ticker()
        if not na(lookup_result)
            lookup_result  // Found in lookup table
        else
            keyword_result = detect_sector_from_symbol()
            not na(keyword_result) ? keyword_result : sector_selection  // Use keyword matching or manual fallback
    => sector_selection

// --- Determine Benchmark Value Based on Mode ---
// Calculate benchmark value dynamically based on selected mode
benchmark_value_raw = switch benchmark_mode
    "Auto Detect Sector" => get_sector_benchmark(actual_sector) 
    "From Sector Index" => sector_index_ps
    => benchmark_value_manual

// Use calculated value if valid, otherwise fallback to manual value
benchmark_value = not na(benchmark_value_raw) ? benchmark_value_raw : benchmark_value_manual

// Determine sector name for display
sector_name = switch benchmark_mode
    "Auto Detect Sector" => actual_sector + " (Auto)"
    "From Sector Index" => (sector_index_symbol != "" ? sector_index_symbol : "Sector Index")
    => "Custom"

// --- Color Logic for Benchmark Mode ---
// Green: P/S < Benchmark (undervalued, good value)
// Orange: Benchmark < P/S < Average (fair value zone)
// Red: P/S > Average (overvalued, expensive)
color_red = color.new(#f23645, 0)      // Red
color_orange = color.new(#ff9800, 0)   // Orange
color_green = color.new(#089981, 0)    // Green
color_blue = color.blue                // Default blue for non-benchmark mode

ps_color = if enable_benchmark and not show_zscore
    if ps_ratio < benchmark_value
        color_green
    else if ps_ratio < ps_avg_display
        color_orange
    else
        color_red
else
    color_blue

// --- Plotting ---

// Dynamic Plotting based on 'show_zscore' input
plot_val = show_zscore ? z_score : ps_ratio
plot_avg = show_zscore ? 0 : ps_avg_display // Z-Score mean is always 0

// Main Plot with Dynamic Color - More prominent line
main_plot = plot(plot_val, title="Main Value", color=show_zscore ? color.purple : ps_color, linewidth=3)

// Average Plot (Only for P/S mode) - Color changes to blue when benchmark is enabled
avg_line_color = (enable_benchmark and not show_zscore) ? color.blue : color.orange
avg_plot = plot(show_zscore ? na : plot_avg, title="Average", color=avg_line_color, linewidth=2)

// Benchmark Plot (Only for P/S mode and if enabled)
benchmark_plot = plot(enable_benchmark and not show_zscore ? benchmark_value : na, title="Sector Benchmark", color=color.new(color.gray, 0), linewidth=2, style=plot.style_line)

// Fill between P/S and Benchmark with ultra-smooth gradient effect (Only when benchmark is active)
// Create smooth gradient using many fine-grained overlapping fills with progressive transparency
// Calculate intermediate gradient values (12 layers for ultra-smooth transition)
// Each layer covers ~8.3% of distance with progressive transparency from 70% to 96% (more transparent)
gradient_enabled = enable_benchmark and not show_zscore and not na(plot_val) and not na(benchmark_value)

g1 = gradient_enabled ? plot_val + (benchmark_value - plot_val) * 0.083 : na
g2 = gradient_enabled ? plot_val + (benchmark_value - plot_val) * 0.167 : na
g3 = gradient_enabled ? plot_val + (benchmark_value - plot_val) * 0.25 : na
g4 = gradient_enabled ? plot_val + (benchmark_value - plot_val) * 0.333 : na
g5 = gradient_enabled ? plot_val + (benchmark_value - plot_val) * 0.417 : na
g6 = gradient_enabled ? plot_val + (benchmark_value - plot_val) * 0.5 : na
g7 = gradient_enabled ? plot_val + (benchmark_value - plot_val) * 0.583 : na
g8 = gradient_enabled ? plot_val + (benchmark_value - plot_val) * 0.667 : na
g9 = gradient_enabled ? plot_val + (benchmark_value - plot_val) * 0.75 : na
g10 = gradient_enabled ? plot_val + (benchmark_value - plot_val) * 0.833 : na
g11 = gradient_enabled ? plot_val + (benchmark_value - plot_val) * 0.917 : na

// Create gradient plot layers (hidden, used only for fills) - More transparent
gp1 = plot(g1, title="G1", color=color.new(ps_color, 72), linewidth=1, display=display.none)
gp2 = plot(g2, title="G2", color=color.new(ps_color, 76), linewidth=1, display=display.none)
gp3 = plot(g3, title="G3", color=color.new(ps_color, 79), linewidth=1, display=display.none)
gp4 = plot(g4, title="G4", color=color.new(ps_color, 81), linewidth=1, display=display.none)
gp5 = plot(g5, title="G5", color=color.new(ps_color, 83), linewidth=1, display=display.none)
gp6 = plot(g6, title="G6", color=color.new(ps_color, 85), linewidth=1, display=display.none)
gp7 = plot(g7, title="G7", color=color.new(ps_color, 87), linewidth=1, display=display.none)
gp8 = plot(g8, title="G8", color=color.new(ps_color, 89), linewidth=1, display=display.none)
gp9 = plot(g9, title="G9", color=color.new(ps_color, 91), linewidth=1, display=display.none)
gp10 = plot(g10, title="G10", color=color.new(ps_color, 93), linewidth=1, display=display.none)
gp11 = plot(g11, title="G11", color=color.new(ps_color, 95), linewidth=1, display=display.none)

// Fill between layers with progressive transparency for ultra-smooth gradient (more transparent)
fill(main_plot, gp1, color=color.new(ps_color, 70), title="GF1")
fill(gp1, gp2, color=color.new(ps_color, 74), title="GF2")
fill(gp2, gp3, color=color.new(ps_color, 78), title="GF3")
fill(gp3, gp4, color=color.new(ps_color, 80), title="GF4")
fill(gp4, gp5, color=color.new(ps_color, 82), title="GF5")
fill(gp5, gp6, color=color.new(ps_color, 84), title="GF6")
fill(gp6, gp7, color=color.new(ps_color, 86), title="GF7")
fill(gp7, gp8, color=color.new(ps_color, 88), title="GF8")
fill(gp8, gp9, color=color.new(ps_color, 90), title="GF9")
fill(gp9, gp10, color=color.new(ps_color, 92), title="GF10")
fill(gp10, gp11, color=color.new(ps_color, 94), title="GF11")
fill(gp11, benchmark_plot, color=color.new(ps_color, 96), title="GF12")

// Zero Line (Reference)
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)

// Z-Score Reference Lines
hline(show_zscore ? 2 : na, "+2 StdDev", color=color.red, linestyle=hline.style_dashed)
hline(show_zscore ? -2 : na, "-2 StdDev", color=color.green, linestyle=hline.style_dashed)

// --- Dashboard (Point 5) ---
// Improved Aesthetics
var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(#131722, 0), border_color=color.new(#363a45, 0), border_width=1, frame_color=color.new(#363a45, 0), frame_width=1)

if show_dashboard and barstate.islast
    // Define Colors
    c_bg_header = color.new(#2962ff, 10) // Vibrant Blue
    c_bg_row = color.new(#1e222d, 10)    // Dark Gray
    c_text_header = color.white
    c_text_row = color.new(#d1d4dc, 0)   // Light Gray
    c_pos = color.new(#089981, 0)        // Green
    c_neg = color.new(#f23645, 0)        // Red
    
    // Header
    table.cell(dash, 0, 0, "P/S Statistics", text_color=c_text_header, bgcolor=c_bg_header, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)
    
    // Sub-Headers
    table.cell(dash, 0, 1, "Metric", text_color=c_text_row, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, "Value", text_color=c_text_row, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_right)
    
    // Row 1: Current P/S with dynamic color when benchmark is active
    current_ps_color = enable_benchmark and not show_zscore ? ps_color : color.white
    table.cell(dash, 0, 2, "Current P/S", text_color=color.white, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(ps_ratio, "#.2f"), text_color=current_ps_color, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_right)
    
    // Row 2: Average P/S
    avg_label = use_cumulative_avg ? "Avg P/S (Hist)" : "Avg P/S (" + str.tostring(lookback_years) + "Y)"
    table.cell(dash, 0, 3, avg_label, text_color=c_text_row, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(ps_avg_display, "#.2f"), text_color=c_text_row, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_right)
    
    // Row 3: Benchmark (Only if enabled and not in Z-Score mode)
    row_offset = 0
    if enable_benchmark and not show_zscore
        // Calculate difference from benchmark
        benchmark_diff = ps_ratio - benchmark_value
        benchmark_diff_pct = (benchmark_diff / benchmark_value) * 100
        benchmark_color = benchmark_diff > 0 ? c_neg : c_pos
        
        // Create benchmark label based on mode
        benchmark_label = switch benchmark_mode
            "Auto Detect Sector" => actual_sector + " Benchmark (Auto)"
            "From Sector Index" => (sector_index_symbol != "" ? sector_index_symbol : "Sector Index") + " Benchmark"
            => "Custom Benchmark"
        
        // Show warning if sector index data is not available
        benchmark_value_display = benchmark_mode == "From Sector Index" and na(sector_index_ps) ? "N/A" : str.tostring(benchmark_value, "#.2f")
        benchmark_diff_display = benchmark_mode == "From Sector Index" and na(sector_index_ps) ? "" : " (" + (benchmark_diff > 0 ? "+" : "") + str.tostring(benchmark_diff_pct, "#.1f") + "%)"
        
        table.cell(dash, 0, 4, benchmark_label, text_color=c_text_row, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_left)
        table.cell(dash, 1, 4, benchmark_value_display + benchmark_diff_display, text_color=benchmark_color, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_right)
        row_offset := 1
    
    // Row 4: Z-Score
    z_color = z_score > 2 ? c_neg : z_score < -2 ? c_pos : c_text_row
    table.cell(dash, 0, 4 + row_offset, "Z-Score (" + str.tostring(lookback_years) + "Y)", text_color=c_text_row, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4 + row_offset, str.tostring(z_score, "#.2f"), text_color=z_color, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_right)
    
    // Row 5: Percentile
    // Color percentile: Low is good (Green), High is bad (Red)
    p_color = percentile < 20 ? c_pos : percentile > 80 ? c_neg : c_text_row
    table.cell(dash, 0, 5 + row_offset, "Percentile (" + str.tostring(lookback_years) + "Y)", text_color=c_text_row, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5 + row_offset, str.tostring(percentile, "#.0") + "%", text_color=p_color, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_right)
    
    // Row 6: 52W High/Low
    table.cell(dash, 0, 6 + row_offset, "52W High/Low", text_color=c_text_row, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6 + row_offset, str.tostring(high_52w, "#.2f") + " / " + str.tostring(low_52w, "#.2f"), text_color=c_text_row, bgcolor=c_bg_row, text_size=size.small, text_halign=text.align_right)

// --- Labels ---
if barstate.islast and not na(plot_val)
    label_text = (show_zscore ? "Z-Score: " : "P/S: ") + str.tostring(plot_val, "#.2f")
    label_color = show_zscore ? color.purple : ps_color
    label.new(bar_index, plot_val, text = label_text, color = label_color, style = label.style_label_left, textcolor = color.white, size = size.small)
````
