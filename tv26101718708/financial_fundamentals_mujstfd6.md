# Financial fundamentals

- url: https://www.tradingview.com/script/MuJsTfD6-Financial-fundamentals/
- type: indicator
- pine_id: PUB;dc3d208bcff7474b81ecbf734f3a43b2
- version: 1.0

## Description

This indicator helps you understand the basic financial fundamentals of the company. It displays price to earning ratio, price to book ratio, market capitalisation, net income, revenue, net income and EPS growth, year on year and then quarter on quarter, followed by three years CAGR, growth of revenue, net income and debt. And if you think that these numbers can be manipulated, then it also shows free cash flow to net income ratio. So basically, it covers everything financiallythat is needed for you to see for a long-term investment.

## Source Code

````pine
//@version=6
indicator("Fundamentals", "", true)

color TEXT_COL = #D1D4DC
color BG_MAIN  = color.new(#000000, 80)
color BG_NEG   = color.new(#C90707, 75)
color BG_POS   = color.new(#07C943, 75)
color BG_WARN  = color.new(#E07B00, 75)

string yPos = input.string("top",   "↕", inline="01", options=["top","middle","bottom"])
string xPos = input.string("right", "↔", inline="01", options=["left","center","right"])

var table t = table.new(yPos + "_" + xPos, 2, 14, border_width=1)

// ————— Arrays: size 16 so sumWindow(12) can safely reach index 15 —————
var arr_rev    = array.new_float(16, na)
var arr_ni     = array.new_float(16, na)
var arr_eps    = array.new_float(16, na)
var arr_debt   = array.new_float(16, na)
var arr_ocf    = array.new_float(16, na)
var arr_eps_fy = array.new_float(3, na)
var arr_ni_fy  = array.new_float(3, na)

// ————— Anchors —————
float ref_fq = request.financial(syminfo.tickerid, "TOTAL_REVENUE",            "FQ", gaps=barmerge.gaps_on, ignore_invalid_symbol=true)
float ref_fy = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_BASIC", "FY", gaps=barmerge.gaps_on, ignore_invalid_symbol=true)

// ————— Raw FQ data —————
float raw_rev    = request.financial(syminfo.tickerid, "TOTAL_REVENUE",               "FQ", ignore_invalid_symbol=true)
float raw_ni     = request.financial(syminfo.tickerid, "NET_INCOME",                  "FQ", ignore_invalid_symbol=true)
float raw_eps    = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_BASIC",    "FQ", ignore_invalid_symbol=true)
float raw_debt   = request.financial(syminfo.tickerid, "TOTAL_DEBT",                  "FQ", ignore_invalid_symbol=true)
float raw_ocf    = request.financial(syminfo.tickerid, "FREE_CASH_FLOW", "FQ", ignore_invalid_symbol=true)
float raw_eps_fy = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_BASIC",    "FY", ignore_invalid_symbol=true)
float raw_ni_fy  = request.financial(syminfo.tickerid, "NET_INCOME",                  "FY", ignore_invalid_symbol=true)

if not na(ref_fq)
    array.unshift(arr_rev, raw_rev)
    array.pop(arr_rev)
    array.unshift(arr_ni, raw_ni)
    array.pop(arr_ni)
    array.unshift(arr_eps, raw_eps)
    array.pop(arr_eps)
    array.unshift(arr_debt, raw_debt)
    array.pop(arr_debt)
    array.unshift(arr_ocf, raw_ocf)
    array.pop(arr_ocf)

if not na(ref_fy)
    array.unshift(arr_eps_fy, raw_eps_fy)
    array.pop(arr_eps_fy)
    array.unshift(arr_ni_fy, raw_ni_fy)
    array.pop(arr_ni_fy)

// ————— Growth calculations —————
calcQoQ(array<float> arr) =>
    float curr = array.get(arr, 0)
    float prev = array.get(arr, 1)
    (not na(curr) and not na(prev) and prev != 0) ? (curr - prev) / math.abs(prev) : na

calcYoY(array<float> arr) =>
    float curr = array.get(arr, 0)
    float prev = array.get(arr, 4)
    (not na(curr) and not na(prev) and prev != 0) ? (curr - prev) / math.abs(prev) : na

calcYoYFY(array<float> arr) =>
    float curr = array.get(arr, 0)
    float prev = array.get(arr, 1)
    (not na(curr) and not na(prev) and prev != 0) ? (curr - prev) / math.abs(prev) : na

calc3YCAGR(array<float> arr) =>
    float curr = array.get(arr, 0)
    float base = array.get(arr, 12)
    (not na(curr) and not na(base) and base > 0) ? math.pow(curr / base, 1.0 / 3.0) - 1 : na

// ————— CFO/NI ratio helpers —————
sumWindow(array<float> arr, int startIdx) =>
    float s = 0.0
    bool valid = true
    for i = startIdx to startIdx + 3
        float v = array.get(arr, i)
        if na(v)
            valid := false
        else
            s += v
    valid ? s : na

float ttm_ni_now  = sumWindow(arr_ni,  0)
float ttm_ocf_now = sumWindow(arr_ocf, 0)
float cfoni_now   = (not na(ttm_ni_now) and not na(ttm_ocf_now) and ttm_ni_now != 0) ? ttm_ocf_now / ttm_ni_now : na

float ttm_ni_3y   = sumWindow(arr_ni,  12)
float ttm_ocf_3y  = sumWindow(arr_ocf, 12)
float cfoni_3y    = (not na(ttm_ni_3y) and not na(ttm_ocf_3y) and ttm_ni_3y != 0) ? ttm_ocf_3y / ttm_ni_3y : na

bool cfoni_improving = not na(cfoni_now) and not na(cfoni_3y) and cfoni_now > cfoni_3y

// ————— Static financials —————
float tso  = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ",  ignore_invalid_symbol=true)
float eps  = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE",       "TTM", ignore_invalid_symbol=true)
float bvps = request.financial(syminfo.tickerid, "BOOK_VALUE_PER_SHARE",     "FQ",  ignore_invalid_symbol=true)
float ni   = request.financial(syminfo.tickerid, "NET_INCOME",               "TTM", ignore_invalid_symbol=true)
float pe   = close / eps
float pb   = close / bvps
float mc   = tso * close

// ————— All growth metrics —————
float rev_yoy   = calcYoY(arr_rev)
float ni_yoy    = calcYoYFY(arr_ni_fy)
float eps_yoy   = calcYoYFY(arr_eps_fy)
float rev_qoq   = calcQoQ(arr_rev)
float ni_qoq    = calcQoQ(arr_ni)
float eps_qoq   = calcQoQ(arr_eps)
float rev_cagr  = calc3YCAGR(arr_rev)
float ni_cagr   = calc3YCAGR(arr_ni)
float debt_cagr = calc3YCAGR(arr_debt)

// ————— Helpers —————
fmtVal(float v, int prec) =>
    if na(v)
        "n/a"
    else
        float a = math.abs(v)
        float d = a > 0 ? math.log10(a) : 0.0
        string p = prec == 2 ? ".00" : prec == 1 ? ".0" : ""
        string r = switch
            d > 12 => str.tostring(v / 1e12, "#" + p) + " T"
            d > 9  => str.tostring(v / 1e9,  "#" + p) + " B"
            d > 6  => str.tostring(v / 1e6,  "#" + p) + " M"
            d > 3  => str.tostring(v / 1e3,  "#" + p) + " K"
            =>        str.tostring(v, "#" + p)
        r

printRow(int row, string label, float value, int prec) =>
    if barstate.islastconfirmedhistory or barstate.islast
        color bg   = value < 0 ? BG_NEG : BG_MAIN
        string val = fmtVal(value, prec)
        table.cell(t, 0, row, " " + label, 0, 0, TEXT_COL, text.align_left,  text.align_center, 11, BG_MAIN)
        table.cell(t, 1, row, val + " ",   0, 0, TEXT_COL, text.align_right, text.align_center, 11, bg)

printPctRow(int row, string label, float value) =>
    if barstate.islastconfirmedhistory or barstate.islast
        color bg   = na(value) ? BG_MAIN : value < 0 ? BG_NEG : BG_POS
        string val = na(value) ? "n/a" : str.tostring(math.round(value * 100, 1)) + "%"
        table.cell(t, 0, row, " " + label, 0, 0, TEXT_COL, text.align_left,  text.align_center, 11, BG_MAIN)
        table.cell(t, 1, row, val + " ",   0, 0, TEXT_COL, text.align_right, text.align_center, 11, bg)

printPctRowInv(int row, string label, float value) =>
    if barstate.islastconfirmedhistory or barstate.islast
        color bg   = na(value) ? BG_MAIN : value > 0 ? BG_NEG : BG_POS
        string val = na(value) ? "n/a" : str.tostring(math.round(value * 100, 1)) + "%"
        table.cell(t, 0, row, " " + label, 0, 0, TEXT_COL, text.align_left,  text.align_center, 11, BG_MAIN)
        table.cell(t, 1, row, val + " ",   0, 0, TEXT_COL, text.align_right, text.align_center, 11, bg)

printCFONI(int row, string label, float value, bool improving) =>
    if barstate.islastconfirmedhistory or barstate.islast
        color bg     = na(value) ? BG_MAIN : value >= 1.0 ? BG_POS : value >= 0.5 ? BG_WARN : BG_NEG
        string trend = na(cfoni_3y) ? "" : improving ? " ▲" : " ▼"
        string val   = na(value) ? "n/a" : str.tostring(math.round(value, 2)) + "x" + trend
        table.cell(t, 0, row, " " + label, 0, 0, TEXT_COL, text.align_left,  text.align_center, 11, BG_MAIN)
        table.cell(t, 1, row, val + " ",   0, 0, TEXT_COL, text.align_right, text.align_center, 11, bg)

// ————— Display —————
printRow(0,        "P/E",          pe,       2)
printRow(1,        "P/B",          pb,       2)
printRow(2,        "Mkt Cap",      mc,       2)
printRow(3,        "Net Income",   ni,       2)
printPctRow(4,     "Rev YoY",      rev_yoy)
printPctRow(5,     "NI YoY",       ni_yoy)
printPctRow(6,     "EPS YoY",      eps_yoy)
printPctRow(7,     "Rev QoQ",      rev_qoq)
printPctRow(8,     "NI QoQ",       ni_qoq)
printPctRow(9,     "EPS QoQ",      eps_qoq)
printPctRow(10,    "Rev 3Y CAGR",  rev_cagr)
printPctRow(11,    "NI 3Y CAGR",   ni_cagr)
printPctRowInv(12, "Debt 3Y CAGR", debt_cagr)
printCFONI(13,     "FREE_CASH_FLOW/NI",       cfoni_now, cfoni_improving)
````
