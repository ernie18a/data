# The Alchemy Score Dashboard

- url: https://www.tradingview.com/script/5QYhW5aJ-The-Alchemy-Score-Dashboard/
- type: indicator
- pine_id: PUB;5bf7f4eb40a64d619aed960394eb4a62
- version: 1.0

## Description

it rates small caps for wether they might outperform and how likely it is.
can click trough your scraeener with this open and it will rate each stock by pulling financial data.

## Source Code

````pine
//@version=6
indicator("The Alchemy Score Dashboard", overlay=true)

// --- USER SETTINGS ---
string fin_period = input.string("FQ", title="Financial Period (FQ=Quarter, FH=Half-Year, FY=Annual)", options=["FQ", "FH", "FY"])

// ==========================================
// TIME CONTROL SAFETY CHECK
// ==========================================
bool is_valid_timeframe = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly

// Only request financial data if we are on a valid macro timeframe to prevent crashes
float market_cap   = is_valid_timeframe ? request.financial(syminfo.tickerid, "MARKET_CAPITALIZATION", fin_period) : na
float total_equity = is_valid_timeframe ? request.financial(syminfo.tickerid, "TOTAL_EQUITY", fin_period) : na
float fcf          = is_valid_timeframe ? request.financial(syminfo.tickerid, "FREE_CASH_FLOW", fin_period) : na
float net_income   = is_valid_timeframe ? request.financial(syminfo.tickerid, "NET_INCOME", fin_period) : na
float operating_cf = is_valid_timeframe ? request.financial(syminfo.tickerid, "CASH_F_OPERATING_ACT", fin_period) : na
float ebitda       = is_valid_timeframe ? request.financial(syminfo.tickerid, "EBITDA", fin_period) : na
float assets       = is_valid_timeframe ? request.financial(syminfo.tickerid, "TOTAL_ASSETS", fin_period) : na
float pe_ratio     = is_valid_timeframe ? request.financial(syminfo.tickerid, "PRICE_EARNINGS_PE_RATIO", fin_period) : na

// Calculate Trailing Periods for Reinvestment Quality
float ebitda_prev = ebitda[1]
float assets_prev = assets[1]

float ebitda_growth = na
if not na(ebitda) and not na(ebitda_prev) and ebitda_prev != 0
    ebitda_growth := (ebitda - ebitda_prev) / math.abs(ebitda_prev)

float asset_growth = na
if not na(assets) and not na(assets_prev) and assets_prev != 0
    asset_growth := (assets - assets_prev) / assets_prev

float fcf_yield = na
if not na(fcf) and not na(market_cap) and market_cap != 0
    fcf_yield := fcf / market_cap

// Calculate Max 1-Day Return over last month (20 trading days)
float prev_close = close[1]
float one_day_return = na
if not na(close) and not na(prev_close) and prev_close != 0
    one_day_return := (close - prev_close) / prev_close

float max_daily_return = ta.highest(one_day_return, 20)

// ==========================================
// 2. SCORE CALCULATION LOGIC
// ==========================================
int alchemy_score = 0
string flags = ""
string warnings = ""
bool hard_fail = false

if not is_valid_timeframe
    hard_fail := true
    warnings += "• ERROR: Switch chart to Daily (D) view\n"
else
    // --- Layer 1 Hard Boundary Fail Checks ---
    if not na(market_cap) and market_cap > 20000000000
        hard_fail := true
        warnings += "• Failed Layer 1: Market Cap over $20B\n"

    if not na(total_equity) and total_equity <= 0
        hard_fail := true
        warnings += "• Failed Layer 1: Negative Equity\n"

    if not na(fcf) and fcf <= 0
        hard_fail := true
        warnings += "• Failed Layer 1: Negative FCF\n"

    // --- Layer 3 Hard Fail Traps ---
    if not na(max_daily_return) and max_daily_return > 0.15
        hard_fail := true
        warnings += "• TRAP: MAX Effect (>15% Day)\n"

    if not na(net_income) and not na(operating_cf) and net_income > (operating_cf * 1.2)
        hard_fail := true
        warnings += "• TRAP: High Accruals\n"

    // --- Layer 2 Outperformance Accrual ---
    if not na(fcf_yield) and fcf_yield > 0.05
        alchemy_score += 2
        flags += "• High FCF Yield (>5%) [+2]\n"

    if not na(ebitda_growth) and not na(asset_growth) and ebitda_growth > asset_growth
        alchemy_score += 2
        flags += "• Supported Investment [+2]\n"

    if not na(ebitda) and not na(ebitda_prev) and ebitda > ebitda_prev
        alchemy_score += 2
        flags += "• Sequential EBITDA Expansion [+2]\n"

    if not na(pe_ratio) and pe_ratio > 0 and pe_ratio < 25
        alchemy_score += 2
        flags += "• Reasonable Valuation Anchor [+2]\n"

    if not na(market_cap) and market_cap < 1500000000
        alchemy_score += 2
        flags += "• Maximum Size Leverage (<$1.5B) [+2]\n"

// ==========================================
// 3. VISUAL DISPLAY PANEL
// ==========================================
var table infoTable = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast
    table.cell(infoTable, 0, 0, "METRIC ANALYSIS", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(infoTable, 1, 0, "STATUS / SCORE", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    
    color trap_color = hard_fail ? color.red : color.green
    string trap_text = hard_fail ? "BLACKLISTED" : "PASSED"
    table.cell(infoTable, 0, 1, "Trap Screening", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, trap_text, text_color=color.white, bgcolor=color.new(trap_color, 50), text_size=size.small)
    
    color score_color = alchemy_score >= 6 ? color.green : alchemy_score >= 4 ? color.orange : color.red
    table.cell(infoTable, 0, 2, "Alchemy Score", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(alchemy_score) + " / 10", text_color=color.white, bgcolor=color.new(score_color, 30), text_size=size.normal)
    
    string details = hard_fail ? "DIAGNOSTICS:\n" + warnings : "GREEN FLAGS:\n" + flags
    color details_bg = hard_fail ? color.new(color.red, 80) : color.new(color.green, 80)
    table.cell(infoTable, 0, 3, "Scoring Details", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, details, text_color=color.white, bgcolor=details_bg, text_size=size.small, text_halign=text.align_left)
````
