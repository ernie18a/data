# Relative Strength Matrix

- url: https://www.tradingview.com/script/hldPaH6Y-Relative-Strength-Matrix/
- type: indicator
- pine_id: PUB;d356268a5b0146448935e253b9f972b9
- version: 1.0

## Description

[b]Overview[/b]
This script is based on work of @jfsrev 's indicator "Swing Data - ADR% / RVol / PVol / Float % / Avg $ Vol", which I modified heavily and left only the Relative Strength related calculations and added to these.

The Relative Strength Matrix is a contextual dashboard designed to help traders instantly identify whether a stock—and its corresponding industry or sector—is displaying true leadership or relative weakness. By tracking rolling price performance across multiple timeframes relative to the S&P 500 (SPX), the script visualizes market alpha directly on your chart via a clean, dynamic, and non-intrusive matrix panel.

[b]Features and customization[/b]
Script has following main features and customization options:
[list]
[*] Modifiable RS score calculation: you can dynamically adjust the mathematical percentage weights for the 2-Week (10d), 1-Month (21d), 3-Month (63d), and 6-Month (126d) momentum lookback periods straight from the UI settings.
[*] Multi-Period Trend Tracking: Calculates and presents the real-time absolute percentage performance of the tracked industry ETF over different time periods. Results can be shown or hidden for each calculation separately.
[*] Individual tickers can be mapped to target ETFs: You can form your own groups with individual tickers and specify benchmark ETF for them (e.g. Tickers: CRWD, S, PANW => Target industry: CIBR)
[*] Industry specific mapping to target ETF: You can use TradingViews provided Industry-information and map the industry to specific ETF (e.g., TW Industry: Semiconductors => Target ETF: SMH)
[*] Complete UI visuals customization: You can customize table position, sizes, background transparencies, border widths, and text colors.
[/list]

[b]Order for RS calculation[/b]
Relative Strength is checked and mapped in the following order:
[list]
[*] Tier 1: Custom Groups (Fully User-Defined) - The script checks if the current ticker belongs to any of your 20 fully customizable thematic watchlists (e.g., Cybersecurity, Semis, Crypto Infrastructure). If found, it instantly binds the stock to your manually assigned thematic ETF.
[*] Tier 2: Core Industries (User-Defined Mappings) – If not found in a custom group, the script screens the stock's native TradingView Industry against 30 available custom mapping slots to find your preferred benchmark tracking ETF.
[*] Tier 3: Sector Fallback (Hardcoded) – If no custom group or industry mapping exists, the engine relies on a robust, hardcoded fallback architecture that maps the stock’s native TradingView Sector to its corresponding Select Sector SPDR ETF (e.g., Electronic Technology is mapped to XLK, Finance is mapped to XLF, Energy is mapped to XLE etc).
[*] Tier 4: Global Catch-All – If a stock does not belong to any defined industry or sector, it defaults to SPY to guarantee a clean baseline calculation without script errors.
[/list]

## Source Code

````pine
//@version=6
indicator(title = "Relative Strength Matrix", shorttitle = "RS Matrix", overlay = true, scale = scale.none, precision = 2)

// =========================================================================
// INPUTS & UI LAYOUT CONFIGURATION
// =========================================================================
posTable          = input.string(defval='Top Right', title='Table Position', options=['Top Left', 'Top Center', 'Top Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group = 'Table layout')
tbl_size          = input.string('Normal', title='Table Size', options=['Tiny', 'Small', 'Normal', 'Large'], group = 'Table layout')
use_top_spacer    = input.bool(true, title="Add top spacer row?", tooltip="Injects an empty row at the top to push down the table and clear TradingView chart icons.", group="Table layout")

// Comprehensive Color Theme Controls
bg_col            = input.color(#ffffff00, title='Panel background', group = 'Table background customization')
row_bg_col        = input.color(#ffffff00, title='Row background', group = 'Table background customization')

// Borders Customization
border_col        = input.color(#000000, title='Border color', group = 'Table border settings')
border_width      = input.int(1, title='Border line width', minval=0, maxval=5, group = 'Table border settings')

// Dynamic Font Color Alert Customization
txt_col_default   = input.color(#000000, title='Default text color', group = 'Text color customization')
c_bullish_font    = input.color(#26a69a, title='Strong performance text color', group = 'Text color customization')
c_neutral_font    = input.color(#d4af37, title='Neutral performance text color', group = 'Text color customization')
c_bearish_font    = input.color(#ef5350, title='Weak performance text color', group = 'Text color customization')

// Toggle Settings
show_stock_rs     = input.bool(true, title="Show Stock RS Rating?", group="RS & ETF display")
show_sector_name  = input.bool(true, title="Show Sector/Industry Name?", group="RS & ETF display")
show_sector_etf   = input.bool(true, title="Show Tracked ETF Ticker?", group="RS & ETF display")
show_sector_rs    = input.bool(true, title="Show Tracked ETF RS Rating?", group="RS & ETF display")

show_perf_1d      = input.bool(true, title="Show Tracked ETF 1D Perf Row?", group="ETF performance display")
show_perf_2w      = input.bool(true, title="Show Tracked ETF 2W Perf Row?", group="ETF performance display")
show_perf_1m      = input.bool(true, title="Show Tracked ETF 1M Perf Row?", group="ETF performance display")
show_perf_3m      = input.bool(true, title="Show Tracked ETF 3M Perf Row?", group="ETF performance display")
show_perf_6m      = input.bool(true, title="Show Tracked ETF 6M Perf Row?", group="ETF performance display")

// Relative Strength Calculation Period Weights Settings
w_2w  = input.int(20, title="2-Week (10d) Weight %", minval=0, maxval=100, group="Relative Strength Momentum Weights")
w_1m  = input.int(30, title="1-Month (21d) Weight %", minval=0, maxval=100, group="Relative Strength Momentum Weights")
w_3m  = input.int(30, title="3-Month (63d) Weight %", minval=0, maxval=100, group="Relative Strength Momentum Weights")
w_6m  = input.int(20, title="6-Month (126d) Weight %", minval=0, maxval=100, group="Relative Strength Momentum Weights")

// Convert integer weights to calculation percentages 
float weight_2w = w_2w / 100.0
float weight_1m = w_1m / 100.0
float weight_3m = w_3m / 100.0
float weight_6m = w_6m / 100.0

// =========================================================================
// TIER 1: 20 DYNAMIC USER-DEFINED THEMATIC CUSTOM GROUPS
// =========================================================================
group1_name    = input.string("Cybersecurity", title="Group 1 Name", group="Custom Thematic Group 01")
group1_tickers = input.string("PANW, CRWD, S, FTNT, NET, OKTA, ZS, CYBR, FFIV, AKAM, QLYS", title="Group 1 Tickers", group="Custom Thematic Group 01")
group1_etf     = input.string("CIBR", title="Group 1 Tracking ETF", group="Custom Thematic Group 01")

group2_name    = input.string("Semi & AI infra ", title="Group 2 Name", group="Custom Thematic Group 02")
group2_tickers = input.string("SMCI, VRT, NVDA, AMD, TSM, MU, INTC, AVGO, LRCX, AMAT, KLAC, TXN, MRVL, CDNS, SNPS, ARM, TER, STM, NXPI, MPWR, ALAB, MCHP, ON, SWKS", title="Group 2 Tickers", group="Custom Thematic Group 02")
group2_etf     = input.string("SMH", title="Group 2 Tracking ETF", group="Custom Thematic Group 02")

group3_name    = input.string("Electrification", title="Group 3 Name", group="Custom Thematic Group 03")
group3_tickers = input.string("ENPH, GEV, FLNC, LITE", title="Group 3 Tickers", group="Custom Thematic Group 03")
group3_etf     = input.string("GRID", title="Group 3 Tracking ETF", group="Custom Thematic Group 03")

group4_name    = input.string("Homebuilders", title="Group 4 Name", group="Custom Thematic Group 04")
group4_tickers = input.string("LEN, DHI, PHM, NVR, TOL, TMHC, MDC, BLDR, HD, LOW, OC, MOHO", title="Group 4 Tickers", group="Custom Thematic Group 04")
group4_etf     = input.string("XHB", title="Group 4 Tracking ETF", group="Custom Thematic Group 04")

group5_name    = input.string("Coal Industry", title="Group 5 Name", group="Custom Thematic Group 05")
group5_tickers = input.string("BTU, AMR, HCC, ARLP, METC, SXC, NRP", title="Group 5 Tickers", group="Custom Thematic Group 05")
group5_etf     = input.string("COAL", title="Group 5 Tracking ETF", group="Custom Thematic Group 05")

group6_name    = input.string("", title="Group 6 Name", group="Custom Thematic Group 06")
group6_tickers = input.string("", title="Group 6 Tickers", group="Custom Thematic Group 06")
group6_etf     = input.string("", title="Group 6 Tracking ETF", group="Custom Thematic Group 06")

group7_name    = input.string("", title="Group 7 Name", group="Custom Thematic Group 07")
group7_tickers = input.string("", title="Group 7 Tickers", group="Custom Thematic Group 07")
group7_etf     = input.string("", title="Group 7 Tracking ETF", group="Custom Thematic Group 07")

group8_name    = input.string("", title="Group 8 Name", group="Custom Thematic Group 08")
group8_tickers = input.string("", title="Group 8 Tickers", group="Custom Thematic Group 08")
group8_etf     = input.string("", title="Group 8 Tracking ETF", group="Custom Thematic Group 08")

group9_name    = input.string("", title="Group 9 Name", group="Custom Thematic Group 09")
group9_tickers = input.string("", title="Group 9 Tickers", group="Custom Thematic Group 09")
group9_etf     = input.string("", title="Group 9 Tracking ETF", group="Custom Thematic Group 09")

group10_name   = input.string("", title="Group 10 Name", group="Custom Thematic Group 10")
group10_tickers= input.string("", title="Group 10 Tickers", group="Custom Thematic Group 10")
group10_etf    = input.string("", title="Group 10 Tracking ETF", group="Custom Thematic Group 10")

group11_name   = input.string("", title="Group 11 Name", group="Custom Thematic Group 11")
group11_tickers= input.string("", title="Group 11 Tickers", group="Custom Thematic Group 11")
group11_etf    = input.string("", title="Group 11 Tracking ETF", group="Custom Thematic Group 11")

group12_name   = input.string("", title="Group 12 Name", group="Custom Thematic Group 12")
group12_tickers= input.string("", title="Group 12 Tickers", group="Custom Thematic Group 12")
group12_etf    = input.string("", title="Group 12 Tracking ETF", group="Custom Thematic Group 12")

group13_name   = input.string("", title="Group 13 Name", group="Custom Thematic Group 13")
group13_tickers= input.string("", title="Group 13 Tickers", group="Custom Thematic Group 13")
group13_etf    = input.string("", title="Group 13 Tracking ETF", group="Custom Thematic Group 13")

group14_name   = input.string("", title="Group 14 Name", group="Custom Thematic Group 14")
group14_tickers= input.string("", title="Group 14 Tickers", group="Custom Thematic Group 14")
group14_etf    = input.string("", title="Group 14 Tracking ETF", group="Custom Thematic Group 14")

group15_name   = input.string("", title="Group 15 Name", group="Custom Thematic Group 15")
group15_tickers= input.string("", title="Group 15 Tickers", group="Custom Thematic Group 15")
group15_etf    = input.string("", title="Group 15 Tracking ETF", group="Custom Thematic Group 15")

group16_name   = input.string("", title="Group 16 Name", group="Custom Thematic Group 16")
group16_tickers= input.string("", title="Group 16 Tickers", group="Custom Thematic Group 16")
group16_etf    = input.string("", title="Group 16 Tracking ETF", group="Custom Thematic Group 16")

group17_name   = input.string("", title="Group 17 Name", group="Custom Thematic Group 17")
group17_tickers= input.string("", title="Group 17 Tickers", group="Custom Thematic Group 17")
group17_etf    = input.string("", title="Group 17 Tracking ETF", group="Custom Thematic Group 17")

group18_name   = input.string("", title="Group 18 Name", group="Custom Thematic Group 18")
group18_tickers= input.string("", title="Group 18 Tickers", group="Custom Thematic Group 18")
group18_etf    = input.string("", title="Group 18 Tracking ETF", group="Custom Thematic Group 18")

group19_name   = input.string("", title="Group 19 Name", group="Custom Thematic Group 19")
group19_tickers= input.string("", title="Group 19 Tickers", group="Custom Thematic Group 19")
group19_etf    = input.string("", title="Group 19 Tracking ETF", group="Custom Thematic Group 19")

group20_name   = input.string("", title="Group 20 Name", group="Custom Thematic Group 20")
group20_tickers= input.string("", title="Group 20 Tickers", group="Custom Thematic Group 20")
group20_etf    = input.string("", title="Group 20 Tracking ETF", group="Custom Thematic Group 20")


// =========================================================================
// TIER 2: 30 MANUALLY MAINTAINED INDUSTRIES (TRADINGVIEW CORE INDUSTRIES)
// =========================================================================
ind1_match = input.string("Electrical Products", title="Industry 1 Match Name", group="Custom Industry Mappings 01")
ind1_etf   = input.string("GRID", title="Industry 1 Tracking ETF", group="Custom Industry Mappings 01")

ind2_match = input.string("Alternative Power Generation", title="Industry 2 Match Name", group="Custom Industry Mappings 02")
ind2_etf   = input.string("GRID", title="Industry 2 Tracking ETF", group="Custom Industry Mappings 02")

ind3_match = input.string("Semiconductors", title="Industry 3 Match Name", group="Custom Industry Mappings 03")
ind3_etf   = input.string("SMH", title="Industry 3 Tracking ETF", group="Custom Industry Mappings 03")

ind4_match = input.string("Biotechnology", title="Industry 4 Match Name", group="Custom Industry Mappings 04")
ind4_etf   = input.string("IBB", title="Industry 4 Tracking ETF", group="Custom Industry Mappings 04")

ind5_match = input.string("Aerospace & Defense", title="Industry 5 Match Name", group="Custom Industry Mappings 05")
ind5_etf   = input.string("ITA", title="Industry 5 Tracking ETF", group="Custom Industry Mappings 05")

ind6_match = input.string("Pharmaceuticals: Major", title="Industry 6 Match Name", group="Custom Industry Mappings 06")
ind6_etf   = input.string("PPH", title="Industry 6 Tracking ETF", group="Custom Industry Mappings 06")

ind7_match = input.string("Regional Banks", title="Industry 7 Match Name", group="Custom Industry Mappings 07")
ind7_etf   = input.string("KRE", title="Industry 7 Tracking ETF", group="Custom Industry Mappings 07")

ind8_match = input.string("Marine Shipping", title="Industry 8 Match Name", group="Custom Industry Mappings 08")
ind8_etf   = input.string("BOAT", title="Industry 8 Tracking ETF", group="Custom Industry Mappings 08")

ind9_match = input.string("Airlines", title="Industry 9 Match Name", group="Custom Industry Mappings 09")
ind9_etf   = input.string("JETS", title="Industry 9 Tracking ETF", group="Custom Industry Mappings 09")

ind10_match = input.string("Trucking", title="Industry 10 Match Name", group="Custom Industry Mappings 10")
ind10_etf   = input.string("IYT", title="Industry 10 Tracking ETF", group="Custom Industry Mappings 10")

ind11_match = input.string("Other Transportation", title="Industry 11 Match Name", group="Custom Industry Mappings 11")
ind11_etf   = input.string("IYT", title="Industry 11 Tracking ETF", group="Custom Industry Mappings 11")

ind12_match = input.string("Homebuilding", title="Industry 12 Match Name", group="Custom Industry Mappings 12")
ind12_etf   = input.string("XHB", title="Industry 12 Tracking ETF", group="Custom Industry Mappings 12")

ind13_match = input.string("Home Improvement Chains", title="Industry 13 Match Name", group="Custom Industry Mappings 13")
ind13_etf   = input.string("XHB", title="Industry 13 Tracking ETF", group="Custom Industry Mappings 13")

ind14_match = input.string("Steel", title="Industry 14 Match Name", group="Custom Industry Mappings 14")
ind14_etf   = input.string("SLX", title="Industry 14 Tracking ETF", group="Custom Industry Mappings 14")

ind15_match = input.string("Coal", title="Industry 15 Match Name", group="Custom Industry Mappings 15")
ind15_etf   = input.string("COAL", title="Industry 15 Tracking ETF", group="Custom Industry Mappings 15")

ind16_match = input.string("Real Estate Investment Trusts", title="Industry 16 Match Name", group="Custom Industry Mappings 16")
ind16_etf   = input.string("XLRE", title="Industry 16 Tracking ETF", group="Custom Industry Mappings 16")

ind17_match = input.string("Packaged Software", title="Industry 17 Match Name", group="Custom Industry Mappings 17")
ind17_etf   = input.string("IGV", title="Industry 17 Tracking ETF", group="Custom Industry Mappings 17")

ind18_match = input.string("Oilfield Services/Equipment", title="Industry 18 Match Name", group="Custom Industry Mappings 18")
ind18_etf   = input.string("XES", title="Industry 18 Tracking ETF", group="Custom Industry Mappings 18")

ind19_match = input.string("Multi-Line Insurance", title="Industry 19 Match Name", group="Custom Industry Mappings 19")
ind19_etf   = input.string("IAK", title="Industry 19 Tracking ETF", group="Custom Industry Mappings 19")

ind20_match = input.string("Property/Casualty Insurance", title="Industry 20 Match Name", group="Custom Industry Mappings 20")
ind20_etf   = input.string("IAK", title="Industry 20 Tracking ETF", group="Custom Industry Mappings 20")

ind21_match = input.string("", title="Industry 21 Match Name", group="Custom Industry Mappings 21")
ind21_etf   = input.string("", title="Industry 21 Tracking ETF", group="Custom Industry Uappings 21")

ind22_match = input.string("", title="Industry 22 Match Name", group="Custom Industry Mappings 22")
ind22_etf   = input.string("", title="Industry 22 Tracking ETF", group="Custom Industry Mappings 22")
ind23_match = input.string("", title="Industry 23 Match Name", group="Custom Industry Mappings 23")
ind23_etf   = input.string("", title="Industry 23 Tracking ETF", group="Custom Industry Mappings 23")
ind24_match = input.string("", title="Industry 24 Match Name", group="Custom Industry Mappings 24")
ind24_etf   = input.string("", title="Industry 24 Tracking ETF", group="Custom Industry Mappings 24")
ind25_match = input.string("", title="Industry 25 Match Name", group="Custom Industry Mappings 25")
ind25_etf   = input.string("", title="Industry 25 Tracking ETF", group="Custom Industry Mappings 25")
ind26_match = input.string("", title="Industry 26 Match Name", group="Custom Industry Mappings 26")
ind26_etf   = input.string("", title="Industry 26 Tracking ETF", group="Custom Industry Mappings 26")
ind27_match = input.string("", title="Industry 27 Match Name", group="Custom Industry Mappings 27")
ind27_etf   = input.string("", title="Industry 27 Tracking ETF", group="Custom Industry Mappings 27")
ind28_match = input.string("", title="Industry 28 Match Name", group="Custom Industry Mappings 28")
ind28_etf   = input.string("", title="Industry 28 Tracking ETF", group="Custom Industry Mappings 28")
ind29_match = input.string("", title="Industry 29 Match Name", group="Custom Industry Mappings 29")
ind29_etf   = input.string("", title="Industry 29 Tracking ETF", group="Custom Industry Mappings 29")
ind30_match = input.string("", title="Industry 30 Match Name", group="Custom Industry Mappings 30")
ind30_etf   = input.string("", title="Industry 30 Tracking ETF", group="Custom Industry Mappings 30")


// Map Table Positions & Sizes
tablePos = switch posTable
    'Top Left'      => position.top_left
    'Top Center'    => position.top_center
    'Top Right'     => position.top_right
    'Bottom Left'   => position.bottom_left
    'Bottom Center' => position.bottom_center
    'Bottom Right'  => position.bottom_right

size_tbl = switch tbl_size
    'Tiny'    => size.tiny
    'Small'   => size.small
    'Normal'  => size.normal
    'Large'   => size.large

// =========================================================================
// PIPELINE STRUCTURAL WATERFALL ENGINE
// =========================================================================
string current_ticker   = syminfo.ticker
string current_industry = na(syminfo.industry) ? 'N/A' : syminfo.industry
string current_sector   = na(syminfo.sector) ? 'N/A' : syminfo.sector

// Safe lookup helper function for comma-separated group parsing
is_ticker_in_group(string ticker_list, string target_ticker) =>
    if ticker_list == ""
        false
    else
        string clean_list     = str.upper(ticker_list)
        string clean_ticker   = str.upper(target_ticker)
        string formatted_list = "," + str.replace_all(clean_list, " ", "") + ","
        string formatted_item = "," + clean_ticker + ","
        str.contains(formatted_list, formatted_item)

// Helper function to safely process clean UI user assignments
clean_string(string src_text) =>
    str.upper(str.replace_all(src_text, " ", ""))

string custom_assigned_name = ""
string matched_etf = "NONE"

// TIER 1: Individual Stocks explicitly mapped inside Custom Groups (1 - 20)
if is_ticker_in_group(group1_tickers, current_ticker)
    matched_etf := clean_string(group1_etf)
    custom_assigned_name := group1_name
else if is_ticker_in_group(group2_tickers, current_ticker)
    matched_etf := clean_string(group2_etf)
    custom_assigned_name := group2_name
else if is_ticker_in_group(group3_tickers, current_ticker)
    matched_etf := clean_string(group3_etf)
    custom_assigned_name := group3_name
else if is_ticker_in_group(group4_tickers, current_ticker)
    matched_etf := clean_string(group4_etf)
    custom_assigned_name := group4_name
else if is_ticker_in_group(group5_tickers, current_ticker)
    matched_etf := clean_string(group5_etf)
    custom_assigned_name := group5_name
else if is_ticker_in_group(group6_tickers, current_ticker)
    matched_etf := clean_string(group6_etf)
    custom_assigned_name := group6_name
else if is_ticker_in_group(group7_tickers, current_ticker)
    matched_etf := clean_string(group7_etf)
    custom_assigned_name := group7_name
else if is_ticker_in_group(group8_tickers, current_ticker)
    matched_etf := clean_string(group8_etf)
    custom_assigned_name := group8_name
else if is_ticker_in_group(group9_tickers, current_ticker)
    matched_etf := clean_string(group9_etf)
    custom_assigned_name := group9_name
else if is_ticker_in_group(group10_tickers, current_ticker)
    matched_etf := clean_string(group10_etf)
    custom_assigned_name := group10_name
else if is_ticker_in_group(group11_tickers, current_ticker)
    matched_etf := clean_string(group11_etf)
    custom_assigned_name := group11_name
else if is_ticker_in_group(group12_tickers, current_ticker)
    matched_etf := clean_string(group12_etf)
    custom_assigned_name := group12_name
else if is_ticker_in_group(group13_tickers, current_ticker)
    matched_etf := clean_string(group13_etf)
    custom_assigned_name := group13_name
else if is_ticker_in_group(group14_tickers, current_ticker)
    matched_etf := clean_string(group14_etf)
    custom_assigned_name := group14_name
else if is_ticker_in_group(group15_tickers, current_ticker)
    matched_etf := clean_string(group15_etf)
    custom_assigned_name := group15_name
else if is_ticker_in_group(group16_tickers, current_ticker)
    matched_etf := clean_string(group16_etf)
    custom_assigned_name := group16_name
else if is_ticker_in_group(group17_tickers, current_ticker)
    matched_etf := clean_string(group17_etf)
    custom_assigned_name := group17_name
else if is_ticker_in_group(group18_tickers, current_ticker)
    matched_etf := clean_string(group18_etf)
    custom_assigned_name := group18_name
else if is_ticker_in_group(group19_tickers, current_ticker)
    matched_etf := clean_string(group19_etf)
    custom_assigned_name := group19_name
else if is_ticker_in_group(group20_tickers, current_ticker)
    matched_etf := clean_string(group20_etf)
    custom_assigned_name := group20_name

// TIER 2: Manually Specified TV Default Industries (1 - 30)
if matched_etf == "NONE" and current_industry != 'N/A'
    string up_industry = str.upper(current_industry)
    if up_industry == str.upper(ind1_match) and ind1_match != ""
        matched_etf := clean_string(ind1_etf)
    else if up_industry == str.upper(ind2_match) and ind2_match != ""
        matched_etf := clean_string(ind2_etf)
    else if up_industry == str.upper(ind3_match) and ind3_match != ""
        matched_etf := clean_string(ind3_etf)
    else if up_industry == str.upper(ind4_match) and ind4_match != ""
        matched_etf := clean_string(ind4_etf)
    else if up_industry == str.upper(ind5_match) and ind5_match != ""
        matched_etf := clean_string(ind5_etf)
    else if up_industry == str.upper(ind6_match) and ind6_match != ""
        matched_etf := clean_string(ind6_etf)
    else if up_industry == str.upper(ind7_match) and ind7_match != ""
        matched_etf := clean_string(ind7_etf)
    else if up_industry == str.upper(ind8_match) and ind8_match != ""
        matched_etf := clean_string(ind8_etf)
    else if up_industry == str.upper(ind9_match) and ind9_match != ""
        matched_etf := clean_string(ind9_etf)
    else if up_industry == str.upper(ind10_match) and ind10_match != ""
        matched_etf := clean_string(ind10_etf)
    else if up_industry == str.upper(ind11_match) and ind11_match != ""
        matched_etf := clean_string(ind11_etf)
    else if up_industry == str.upper(ind12_match) and ind12_match != ""
        matched_etf := clean_string(ind12_etf)
    else if up_industry == str.upper(ind13_match) and ind13_match != ""
        matched_etf := clean_string(ind13_etf)
    else if up_industry == str.upper(ind14_match) and ind14_match != ""
        matched_etf := clean_string(ind14_etf)
    else if up_industry == str.upper(ind15_match) and ind15_match != ""
        matched_etf := clean_string(ind15_etf)
    else if up_industry == str.upper(ind16_match) and ind16_match != ""
        matched_etf := clean_string(ind16_etf)
    else if up_industry == str.upper(ind17_match) and ind17_match != ""
        matched_etf := clean_string(ind17_etf)
    else if up_industry == str.upper(ind18_match) and ind18_match != ""
        matched_etf := clean_string(ind18_etf)
    else if up_industry == str.upper(ind19_match) and ind19_match != ""
        matched_etf := clean_string(ind19_etf)
    else if up_industry == str.upper(ind20_match) and ind20_match != ""
        matched_etf := clean_string(ind20_etf)
    else if up_industry == str.upper(ind21_match) and ind21_match != ""
        matched_etf := clean_string(ind21_etf)
    else if up_industry == str.upper(ind22_match) and ind22_match != ""
        matched_etf := clean_string(ind22_etf)
    else if up_industry == str.upper(ind23_match) and ind23_match != ""
        matched_etf := clean_string(ind23_etf)
    else if up_industry == str.upper(ind24_match) and ind24_match != ""
        matched_etf := clean_string(ind24_etf)
    else if up_industry == str.upper(ind25_match) and ind25_match != ""
        matched_etf := clean_string(ind25_etf)
    else if up_industry == str.upper(ind26_match) and ind26_match != ""
        matched_etf := clean_string(ind26_etf)
    else if up_industry == str.upper(ind27_match) and ind27_match != ""
        matched_etf := clean_string(ind27_etf)
    else if up_industry == str.upper(ind28_match) and ind28_match != ""
        matched_etf := clean_string(ind28_etf)
    else if up_industry == str.upper(ind29_match) and ind29_match != ""
        matched_etf := clean_string(ind29_etf)
    else if up_industry == str.upper(ind30_match) and ind30_match != ""
        matched_etf := clean_string(ind30_etf)

// TIER 3: Sector Level Hardcoded Fallback
if matched_etf == "NONE"
    matched_etf := switch current_sector
        "Electronic Technology"     => "XLK" 
        "Technology Services"       => "XLK" 
        "Communications"            => "XLC" 
        "Finance"                   => "XLF" 
        "Health Technology"         => "XLV" 
        "Health Services"           => "XLV" 
        "Retail Trade"              => "XLY" 
        "Consumer Services"         => "XLY" 
        "Consumer Durables"         => "XLY" 
        "Consumer Non-Durables"     => "XLP" 
        "Producer Manufacturing"    => "XLI" 
        "Commercial Services"       => "XLI" 
        "Industrial Services"       => "XLI" 
        "Transportation"            => "XLI" 
        "Distribution Services"     => "XLI" 
        "Energy Minerals"           => "XLE" 
        "Non-Energy Minerals"       => "XLB" 
        "Process Industries"        => "XLB" 
        "Utilities"                 => "XLU" 
        => "NONE"

// TIER 4: Global Baseline Catch-All Default
if matched_etf == "NONE" or matched_etf == ""
    matched_etf := "SPY"

tracked_etf = matched_etf

// Define final display text layout presentation
group_display_name = custom_assigned_name != "" ? custom_assigned_name : (current_industry != 'N/A' and current_industry != '' ? current_industry : current_sector)

// =========================================================================
// 2. MATHEMATICAL CORE ENGINE (DYNAMICALLY WEIGHTED RS MOMENTUM ENGINE)
// =========================================================================
f_attributePercentile(totalRsScore, tallerPerf, smallerPerf, rangeUp, rangeDn, weight) =>
    sum = totalRsScore + (totalRsScore - smallerPerf) * weight
    if (sum > tallerPerf - 1)
        sum := tallerPerf - 1
    k1 = smallerPerf / rangeDn
    k2 = (tallerPerf - 1) / rangeUp
    k3 = (k1 - k2) / (tallerPerf - 1 - smallerPerf)
    RsRating = sum / (k1 - k3 * (totalRsScore - smallerPerf))
    if (RsRating > rangeUp)
        RsRating := rangeUp
    if (RsRating < rangeDn)
        RsRating := rangeDn
    RsRating

f_get_rs_rating(target_ticker, w1, w2, w3, w4) =>
    // Shortened rolling window inputs for immediate tracking
    n10   = bar_index < 10  ? bar_index : 10
    n21   = bar_index < 21  ? bar_index : 21
    n63   = bar_index < 63  ? bar_index : 63 
    n126  = bar_index < 126 ? bar_index : 126

    closeDaRs    = request.security(target_ticker, 'D', close)
    spxcloseDaRs = request.security('SP:SPX', 'D', close)

    perfTicker10   = closeDaRs / closeDaRs[n10]
    perfTicker21   = closeDaRs / closeDaRs[n21]
    perfTicker63   = closeDaRs / closeDaRs[n63]
    perfTicker126  = closeDaRs / closeDaRs[n126]

    perfComp10     = spxcloseDaRs / spxcloseDaRs[n10]
    perfComp21     = spxcloseDaRs / spxcloseDaRs[n21]
    perfComp63     = spxcloseDaRs / spxcloseDaRs[n63]
    perfComp126    = spxcloseDaRs / spxcloseDaRs[n126]

    // Multi-period rolling math with dynamic UI input weightings
    float rs_stock = (w1 * perfTicker10) + (w2 * perfTicker21) + (w3 * perfTicker63) + (w4 * perfTicker126)
    float rs_ref   = (w1 * perfComp10)   + (w2 * perfComp21)   + (w3 * perfComp63)   + (w4 * perfComp126)

    float totalRsScore  = (rs_stock) / (rs_ref) * 100
    float totalRsRating = -1.0

    curveRsPerf = request.seed('seed_fred6725_rs_rating', 'RSRATING', close)
    delta       = ta.barssince(not na(curveRsPerf))

    var float[] different_values = array.new_float(7, 0.0)
    var int counter = 0

    float first = 0.0, float scnd = 0.0, float thrd = 0.0, float frth = 0.0
    float ffth  = 0.0, float sxth = 0.0, float svth = 0.0

    for i = delta to 34 + delta
        close_value = nz(curveRsPerf[i])
        if (not array.includes(different_values, close_value) and counter < 7 and close_value != 0)
            array.set(different_values, counter, close_value)
            counter := counter + 1

    first := array.get(different_values, 0)
    scnd  := array.get(different_values, 1)
    thrd  := array.get(different_values, 2)
    frth  := array.get(different_values, 3)
    ffth  := array.get(different_values, 4)
    sxth  := array.get(different_values, 5)
    svth  := array.get(different_values, 6)

    if (totalRsScore >= first)
        totalRsRating := 99.0
    if (totalRsScore <= svth)
        totalRsRating := 1.0

    if (totalRsScore < first and totalRsScore >= scnd)
        totalRsRating := f_attributePercentile(totalRsScore, first, scnd, 98, 90, 0.33)
    if (totalRsScore < scnd and totalRsScore >= thrd)
        totalRsRating := f_attributePercentile(totalRsScore, scnd, thrd, 89, 70, 2.1)
    if (totalRsScore < thrd and totalRsScore >= frth)
        totalRsRating := f_attributePercentile(totalRsScore, thrd, frth, 69, 50, 0.0)
    if (totalRsScore < frth and totalRsScore >= ffth)
        totalRsRating := f_attributePercentile(totalRsScore, frth, ffth, 49, 30, 0.0)
    if (totalRsScore < ffth and totalRsScore >= sxth)
        totalRsRating := f_attributePercentile(totalRsScore, ffth, sxth, 29, 10, 0.0)
    if (totalRsScore < sxth and totalRsScore >= svth)
        totalRsRating := f_attributePercentile(totalRsScore, sxth, svth, 9, 2, 0.0)

    totalRsRating

// Run Core Calculations passing the user specified weight values
stockRs    = math.round(f_get_rs_rating(syminfo.tickerid, weight_2w, weight_1m, weight_3m, weight_6m),0)
trackedRs  = math.round(f_get_rs_rating(tracked_etf, weight_2w, weight_1m, weight_3m, weight_6m),0)

closeTracked = request.security(tracked_etf, 'D', close)
openTracked  = request.security(tracked_etf, 'D', open)
tracked_chg  = ((closeTracked - openTracked) / openTracked) * 100

// Historical Security Arrays for Multi-Period Performance Tracking
etf_close_2w = request.security(tracked_etf, 'D', close[10])
etf_close_1m = request.security(tracked_etf, 'D', close[21])
etf_close_3m = request.security(tracked_etf, 'D', close[63])
etf_close_6m = request.security(tracked_etf, 'D', close[126])

perf_2w      = ((closeTracked - etf_close_2w) / etf_close_2w) * 100
perf_1m      = ((closeTracked - etf_close_1m) / etf_close_1m) * 100
perf_3m      = ((closeTracked - etf_close_3m) / etf_close_3m) * 100
perf_6m      = ((closeTracked - etf_close_6m) / etf_close_6m) * 100

// =========================================================================
// 3. TABLE VISUALIZATION SYSTEM (DYNAMIC LAYOUT EXPANSION)
// =========================================================================
// Accommodates up to 9 potential visualization parameters vertically (including potential blank spacer)
var table rs_matrix = table.new(tablePos, 2, 10, bgcolor=bg_col, border_width=border_width, border_color=border_col)

if barstate.islast
    int current_row = 0

    // Top Spacer Row Injection Configuration (Overcomes TradingView UI icon crowding)
    if use_top_spacer and (posTable == 'Top Right' or posTable == 'Top Center' or posTable == 'Top Left')
        table.cell(rs_matrix, 0, current_row, text=" ", text_color=color.new(color.white, 100), bgcolor=color.new(color.white, 100), text_size=size_tbl)
        table.cell(rs_matrix, 1, current_row, text=" ", text_color=color.new(color.white, 100), bgcolor=color.new(color.white, 100), text_size=size_tbl)
        current_row := current_row + 1

    // Row: Stock RS Rating (With Font-Color Alerts)
    if show_stock_rs
        color stock_font_color = stockRs >= 80 ? c_bullish_font : stockRs <= 50 ? c_bearish_font : c_neutral_font
        table.cell(rs_matrix, 0, current_row, text="Stock RS Rating (vs SPX)", text_color=txt_col_default, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_left)
        table.cell(rs_matrix, 1, current_row, text=str.tostring(stockRs, "0.0"), text_color=stock_font_color, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_center)
        current_row := current_row + 1

    // Row: Structural Assignment Name
    if show_sector_name
        table.cell(rs_matrix, 0, current_row, text="Assigned Group/Sector", text_color=txt_col_default, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_left)
        table.cell(rs_matrix, 1, current_row, text=group_display_name, text_color=txt_col_default, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_center)
        current_row := current_row + 1

    // Row: Benchmark ETF Ticker Tracker
    if show_sector_etf
        table.cell(rs_matrix, 0, current_row, text="Tracked ETF Reference", text_color=txt_col_default, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_left)
        table.cell(rs_matrix, 1, current_row, text=tracked_etf, text_color=txt_col_default, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_center)
        current_row := current_row + 1

    // Row: Tracked ETF Relative Strength (With Font-Color Alerts)
    if show_sector_rs
        color tracked_font_color = trackedRs >= 80 ? c_bullish_font : trackedRs <= 50 ? c_bearish_font : c_neutral_font
        table.cell(rs_matrix, 0, current_row, text="Tracked ETF RS (vs SPX)", text_color=txt_col_default, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_left)
        table.cell(rs_matrix, 1, current_row, text=str.tostring(trackedRs, "0"), text_color=tracked_font_color, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_center)
        current_row := current_row + 1

    // Row: Open-to-Close Intraday Flow Performance (With Font-Color Alerts)
    if show_perf_1d
        string formatted_chg = (tracked_chg > 0 ? "+" : "") + str.tostring(tracked_chg, "0.00") + "%"
        color chg_font_color = tracked_chg >= 0 ? c_bullish_font : c_bearish_font
        table.cell(rs_matrix, 0, current_row, text="Tracked ETF Daily Perf", text_color=txt_col_default, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_left)
        table.cell(rs_matrix, 1, current_row, text=formatted_chg, text_color=chg_font_color, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_center)
        current_row := current_row + 1

    // Historical Period Extension Matrix Block (Optional Rows)
    // 2-Week Dynamic Render
    if show_perf_2w
        string txt_2w = (perf_2w > 0 ? "+" : "") + str.tostring(perf_2w, "0.00") + "%"
        color col_2w  = perf_2w >= 0 ? c_bullish_font : c_bearish_font
        table.cell(rs_matrix, 0, current_row, text="Tracked ETF 2W Perf", text_color=txt_col_default, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_left)
        table.cell(rs_matrix, 1, current_row, text=txt_2w, text_color=col_2w, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_center)
        current_row := current_row + 1

    // 1-Month Dynamic Render
    if show_perf_1m
        string txt_1m = (perf_1m > 0 ? "+" : "") + str.tostring(perf_1m, "0.00") + "%"
        color col_1m  = perf_1m >= 0 ? c_bullish_font : c_bearish_font
        table.cell(rs_matrix, 0, current_row, text="Tracked ETF 1M Perf", text_color=txt_col_default, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_left)
        table.cell(rs_matrix, 1, current_row, text=txt_1m, text_color=col_1m, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_center)
        current_row := current_row + 1

    // 3-Month Dynamic Render
    if show_perf_3m
        string txt_3m = (perf_3m > 0 ? "+" : "") + str.tostring(perf_3m, "0.00") + "%"
        color col_3m  = perf_3m >= 0 ? c_bullish_font : c_bearish_font
        table.cell(rs_matrix, 0, current_row, text="Tracked ETF 3M Perf", text_color=txt_col_default, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_left)
        table.cell(rs_matrix, 1, current_row, text=txt_3m, text_color=col_3m, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_center)
        current_row := current_row + 1

    // 6-Month Dynamic Render
    if show_perf_6m
        string txt_6m = (perf_6m > 0 ? "+" : "") + str.tostring(perf_6m, "0.00") + "%"
        color col_6m  = perf_6m >= 0 ? c_bullish_font : c_bearish_font
        table.cell(rs_matrix, 0, current_row, text="Tracked ETF 6M Perf", text_color=txt_col_default, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_left)
        table.cell(rs_matrix, 1, current_row, text=txt_6m, text_color=col_6m, bgcolor=row_bg_col, text_size=size_tbl, text_halign=text.align_center)
        current_row := current_row + 1

plot(0, color=color.new(color.black, 100), title="Subwindow Spacer")
````
