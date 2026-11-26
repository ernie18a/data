# Quarterly Earnings 

- url: https://www.tradingview.com/script/tdlpgQ8I-Quarterly-Earnings/
- type: indicator
- pine_id: PUB;7f07739871f742428feb3107e29c4a1c
- version: 1.0

## Description

Here's a ready-to-paste TradingView publication description:

---

**Quarterly Earnings Dashboard**

A clean on-chart table that puts a stock's key fundamentals next to its price action — built for fundamentals-aware swing/position traders who want valuation, quality, and earnings trend in one glance without leaving the chart.

**Current snapshot (top row)**
- **MCap (Cr)** — market capitalisation
- **PE** — price-to-earnings
- **FFloat (Cr)** — free-float market cap (MCap × float shares ÷ total shares)
- **RVOL** — relative volume vs the N-bar average (configurable), to spot unusual activity
- **ROE%** — return on equity
- **CFO/PAT%** — cash conversion: operating cash flow ÷ profit after tax. ~100%+ signals profits backed by real cash; persistently low is a quality red flag.

**Quarterly earnings table**
For the last N reported quarters: **PAT (Cr)**, **PAT YoY%**, **Sales (Cr)**, **Sales YoY%**, and **OPM%**. YoY columns are colour-coded green/red so accelerating or decelerating earnings jump out.

**Inputs**
- Quarters to show (1–16)
- Reporting period (FQ / FY / TTM)
- RVOL length
- Table position and colours

**Notes**
- All data is pulled from TradingView's built-in fundamentals via `request.financial()`. Best used on a single stock's weekly or daily chart.
- Some IDs (free float, cash flow) aren't published on the quarterly feed for every market, so the snapshot falls back FQ → FY → TTM. If a cell still reads "n/a", TradingView simply doesn't carry that data for the symbol.
- RVOL is relative to the chart timeframe — on a weekly chart it's volume vs the 20-week average.

Not financial advice; for research and educational use.

---

## Source Code

````pine
//@version=6
// =============================================================================
// Quarterly Earnings Dashboard
//   Top  : CURRENT snapshot  ->  MCap(Cr) | PE | FreeFloat% | RVOL
//   Below: per-quarter table ->  Qtr | EPS | EPS YoY | Sales(Cr) | Sales YoY | OPM% | ROE%
// Data: TradingView fundamentals via request.financial(). Best on a single
// stock's weekly/daily chart (NSE/BSE supported).
// =============================================================================
indicator("Quarterly Earnings Dashboard", overlay = true)

// ----------------------------- Inputs ----------------------------------------
int    numRows   = input.int(8, "Quarters to show", minval = 1, maxval = 16)
string finPeriod = input.string("FQ", "Reporting period", options = ["FQ", "FY", "TTM"])
int    rvolLen   = input.int(20, "RVOL length (bars)", minval = 2)
string tblPos    = input.string("top_right", "Table position",
     options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right"])
color  posCol    = input.color(color.new(color.green, 0),  "Positive YoY text")
color  negCol    = input.color(color.new(color.red,   0),  "Negative YoY text")
color  hdrBg     = input.color(color.new(color.blue,  0),  "Header background")
color  snapBg    = input.color(color.new(color.teal,  20), "Snapshot background")
color  rowBg     = input.color(color.new(color.gray,  90), "Row background")
color  txtCol    = input.color(color.white,                "Text color")

// --------------------- Pull fundamentals -------------------------------------
// ignore_invalid_symbol = true  ->  unavailable IDs return na instead of erroring.
fin(string id) => request.financial(syminfo.tickerid, id, finPeriod, ignore_invalid_symbol = true)

// Quarterly (for the table)
pat = fin("NET_INCOME")                       // Profit After Tax
rev = fin("TOTAL_REVENUE")
opm = fin("OPERATING_MARGIN")
cfo = fin("CASH_F_OPERATING_ACTIVITIES")      // Cash flow from operations

// Current snapshot — coalesce FQ -> FY -> TTM so IDs missing on quarterly still fill.
finAny(string id) =>
    float v = request.financial(syminfo.tickerid, id, finPeriod, ignore_invalid_symbol = true)
    v := na(v) ? request.financial(syminfo.tickerid, id, "FY",  ignore_invalid_symbol = true) : v
    v := na(v) ? request.financial(syminfo.tickerid, id, "TTM", ignore_invalid_symbol = true) : v
    v

mcap     = finAny("MARKET_CAP_BASIC")
pe       = finAny("PRICE_EARNINGS")
roe      = finAny("RETURN_ON_EQUITY")
floatShA = finAny("FLOAT_SHARES_OUTSTANDING")
totShA   = finAny("TOTAL_SHARES_OUTSTANDING")
floatPA  = finAny("FLOAT_SHARES_PERCENT")
cfoA     = finAny("CASH_F_OPERATING_ACTIVITIES")
patA     = finAny("NET_INCOME")

mcapCr = na(mcap) ? na : mcap / 1e7
// Free float as a FRACTION of total (units cancel) -> always <= market cap.
floatFrac   = (not na(floatShA) and not na(totShA) and totShA != 0) ? floatShA / totShA : (na(floatPA) ? na : floatPA / 100.0)
freeFloatCr = (na(mcapCr) or na(floatFrac)) ? na : mcapCr * floatFrac
// CFO/PAT in % (cash conversion). ~100% is healthy.
snapCfoPat  = (na(cfoA) or na(patA) or patA == 0) ? na : cfoA / patA * 100.0

// RVOL = current volume / average volume over rvolLen bars
avgVol = ta.sma(volume, rvolLen)
rvol   = na(avgVol) or avgVol == 0 ? na : volume / avgVol

// ------------------------- Store one row per quarter -------------------------
var array<float> aPat  = array.new_float()
var array<float> aRev  = array.new_float()
var array<float> aOpm  = array.new_float()
var array<int>   aTime = array.new_int()

bool isNewQtr = (not na(pat) and pat != pat[1]) or (not na(rev) and rev != rev[1])

if isNewQtr
    array.unshift(aPat,  na(pat) ? na : pat / 1e7)   // Cr
    array.unshift(aRev,  na(rev) ? na : rev / 1e7)   // Cr
    array.unshift(aOpm,  opm)
    array.unshift(aTime, time)

// ------------------------------ Formatting helpers ---------------------------
f_num(float x, string fmt) => na(x) ? "n/a" : str.tostring(x, fmt)
f_pct(float x)             => na(x) ? "n/a" : str.tostring(x, "#.#") + "%"

f_yoy(array<float> a, int i) =>
    string s = "—"
    color  c = txtCol
    if i + 4 < array.size(a)
        float cur = array.get(a, i)
        float prv = array.get(a, i + 4)
        if not na(cur) and not na(prv) and prv != 0
            float pct = (cur - prv) / math.abs(prv) * 100.0
            s := (pct >= 0 ? "+" : "") + str.tostring(pct, "#.#") + "%"
            c := pct >= 0 ? posCol : negCol
    [s, c]

// ------------------------------- Draw the table ------------------------------
// 6 columns. Rows: 2 snapshot + 1 quarter-header + numRows quarters.
var table t = table.new(tblPos, 6, numRows + 3, border_width = 1)

if barstate.islast
    table.clear(t, 0, 0, 5, numRows + 2)

    // ---- Snapshot row (current values) ----
    snapHd = array.from("MCap(Cr)", "PE", "FFloat(Cr)", "RVOL", "ROE%", "CFO/PAT%")
    for c = 0 to 5
        table.cell(t, c, 0, array.get(snapHd, c), text_color = txtCol, bgcolor = hdrBg, text_size = size.small)

    table.cell(t, 0, 1, f_num(mcapCr, "#,###"),        text_color = txtCol, bgcolor = snapBg, text_size = size.small)
    table.cell(t, 1, 1, f_num(pe, "#.#"),              text_color = txtCol, bgcolor = snapBg, text_size = size.small)
    table.cell(t, 2, 1, f_num(freeFloatCr, "#,###"),   text_color = txtCol, bgcolor = snapBg, text_size = size.small)
    table.cell(t, 3, 1, f_num(rvol, "#.##"),           text_color = txtCol, bgcolor = snapBg, text_size = size.small)
    table.cell(t, 4, 1, f_pct(roe),                    text_color = txtCol, bgcolor = snapBg, text_size = size.small)
    table.cell(t, 5, 1, f_pct(snapCfoPat),             text_color = txtCol, bgcolor = snapBg, text_size = size.small)

    // ---- Quarterly earnings header ----
    qHead = array.from("Qtr", "PAT(Cr)", "PAT YoY", "Sales(Cr)", "Sales YoY", "OPM%")
    for c = 0 to 5
        table.cell(t, c, 2, array.get(qHead, c), text_color = txtCol, bgcolor = hdrBg,
             text_size = size.small, text_halign = text.align_center)

    // ---- Quarterly rows ----
    int shown = math.min(numRows, array.size(aPat))
    if shown > 0
        for i = 0 to shown - 1
            int r = i + 3
            [patY, patC] = f_yoy(aPat, i)
            [revY, revC] = f_yoy(aRev, i)
            qLbl = str.format_time(array.get(aTime, i), "MMM-yy", syminfo.timezone)

            table.cell(t, 0, r, qLbl,                                  text_color = txtCol, bgcolor = rowBg, text_size = size.small)
            table.cell(t, 1, r, f_num(array.get(aPat, i), "#,###.#"),  text_color = txtCol, bgcolor = rowBg, text_size = size.small)
            table.cell(t, 2, r, patY,                                  text_color = patC,   bgcolor = rowBg, text_size = size.small)
            table.cell(t, 3, r, f_num(array.get(aRev, i), "#,###.#"),  text_color = txtCol, bgcolor = rowBg, text_size = size.small)
            table.cell(t, 4, r, revY,                                  text_color = revC,   bgcolor = rowBg, text_size = size.small)
            table.cell(t, 5, r, f_pct(array.get(aOpm, i)),             text_color = txtCol, bgcolor = rowBg, text_size = size.small)
    else
        table.cell(t, 0, 3, "No fundamental data for this symbol", text_color = txtCol, bgcolor = rowBg, text_size = size.small)
````
