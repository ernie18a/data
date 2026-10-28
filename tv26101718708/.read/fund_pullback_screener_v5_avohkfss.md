# Fund + Pullback Screener v5

- url: https://www.tradingview.com/script/AVOhkFSs-Fund-Pullback-Screener-v5/
- type: indicator
- pine_id: PUB;8280e138573b4d8aa58fdabbbee6db56
- version: 2.0

## Description

Fund + Pullback Screener — fundamental filter + pullback entry signal

WHAT IT DOES

This indicator combines fundamental screening and technical entry timing in a single tool. The logic is two-stage: a stock is first checked against fundamental criteria, then against a pullback setup (a retracement within an uptrend). All checks are displayed in an on-chart table: value, threshold, pass/fail.

PRESETS

5 built-in fundamental filter modes (switchable in settings):

- GARP — quality companies at a reasonable price: P/E 8–35, ROE > 15%, operating margin > 15%, EPS growth > 10%, Debt/Equity < 1, PEG < 2
- Growth — profitable companies with aggressive growth: P/E up to 120, EPS growth > 25%, revenue growth > 20%, PEG < 3
- Deep Value — cheap and profitable: P/E 5–18, PEG < 1.2, Debt/Equity < 0.7
- Emerging Growth — pre-profit hypergrowth (P/E, PEG, EPS, ROE are not used): revenue growth > 30%, revenue acceleration, gross margin > 40%, improving operating margin, Rule of 40, share dilution < 8%
- Custom — manual thresholds

SIGNAL LOGIC

Status in the table: NO / WATCH / ENTRY.

- Trend filter: weekly timeframe, price above SMA200 and SMA50 above SMA200. For young companies without 200 weeks of history, it automatically falls back to SMA50.
- WATCH: fundamentals passed, uptrend intact, RSI below 50, price within 4 ATR of support (pivot low or SMA50). A candidate to monitor.
- ENTRY: RSI in the 30–50 zone turning up, price within 1.5 ATR above support (an undercut down to 0.5 ATR is allowed). Shown as a triangle below the bar.

Distances are measured in ATR units, so the logic automatically adapts to each instrument's volatility.

HANDLING UNAVAILABLE DATA (N/A POLICY)

Some sectors structurally lack certain metrics (e.g., gross margin for insurers). Lenient mode (default) skips up to 2 unavailable metrics, marking them with a gray "–" and showing a skip counter. Core metrics (market cap, revenue growth) are never skipped. Strict mode: any unavailable metric = fail.

HOW TO USE

1. Recommended timeframe — daily.
2. Pick the preset matching the company type: mature names — GARP/Deep Value, expensive growers — Growth, pre-profit — Emerging Growth.
3. Shortlist candidates with the native TradingView screener, add them to a watchlist and flip through the charts — the table instantly shows the full picture for each ticker.
4. All thresholds are configurable in the settings.

LIMITATIONS

- Works on stocks only — crypto, forex and futures have no fundamental data.
- EPS and revenue growth are computed from the history of quarterly reports accumulated on the chart: full history is required (at least 8–9 quarters), otherwise growth metrics show n/a.
- Fundamental data updates quarterly as reports are released.
- The indicator is informational only and is not investment advice.

## Source Code

````pine
//@version=6
indicator("Fund + Pullback Screener v6", overlay = true, max_labels_count = 50)

// ============================= PRESET =============================
grpP = "Strategy Preset"
preset = input.string("GARP", "Table preset (display)", options = ["GARP", "Growth", "Deep Value", "Emerging Growth", "Custom"], group = grpP, tooltip = "Which preset's thresholds are shown in the table rows. Signals can be scoped independently below.")
scope  = input.string("Any preset", "Signal scope", options = ["Any preset", "Selected preset"], group = grpP, tooltip = "Any preset: WATCH/ENTRY fire if fundamentals pass ANY of the 4 built-in presets — one alert covers a mixed watchlist. Selected preset: signals follow only the preset chosen above.")
naPolicy = input.string("Lenient", "N/A policy", options = ["Lenient", "Strict"], group = grpP)
naLimit  = input.int(2, "Max n/a skipped (Lenient)", minval = 0, maxval = 4, group = grpP)

isEmerging = preset == "Emerging Growth"
lenient    = naPolicy == "Lenient"

// ===================== CUSTOM FIELDS (Preset = Custom) =====================
grpF = "Custom Fundamental Filters"
peMinIn    = input.float(8,   "P/E min",                     group = grpF)
peMaxIn    = input.float(35,  "P/E max",                     group = grpF)
epsGrMinIn = input.float(10,  "EPS dil growth TTM YoY, % >", group = grpF)
revGrMinIn = input.float(5,   "Revenue growth TTM YoY, % >", group = grpF)
roeMinIn   = input.float(15,  "ROE, % >",                    group = grpF)
opmMinIn   = input.float(15,  "Op margin, % >",              group = grpF)
deMaxIn    = input.float(1,   "Debt / Equity <",             group = grpF)
mcapMinIn  = input.float(10,  "Mkt cap, B USD >",            group = grpF)
pegMaxIn   = input.float(2,   "PEG <",                       group = grpF)

// ===================== EMERGING GROWTH FIELDS =====================
grpEG = "Emerging Growth Filters"
egRevGrMin = input.float(30,  "Revenue growth TTM YoY, % >", group = grpEG)
egGmMin    = input.float(40,  "Gross margin, % >",           group = grpEG)
egR40Min   = input.float(40,  "Rule of 40 (RevGr + OpM) >",  group = grpEG)
egDeMax    = input.float(1.5, "Debt / Equity <",             group = grpEG)
egMcapMin  = input.float(2,   "Mkt cap, B USD >",            group = grpEG)
egDilMax   = input.float(8,   "Share dilution YoY, % <",     group = grpEG)

// ===================== EFFECTIVE THRESHOLDS (table display) =====================
f_preset(string p) =>
    switch p
        "GARP"       => [8.0,  35.0,  10.0, 5.0,  15.0, 15.0, 1.0, 10.0, 2.0]
        "Growth"     => [8.0,  120.0, 25.0, 20.0, 12.0, 10.0, 1.5, 10.0, 3.0]
        "Deep Value" => [5.0,  18.0,  0.0,  0.0,  10.0, 10.0, 0.7, 10.0, 1.2]
        =>              [peMinIn, peMaxIn, epsGrMinIn, revGrMinIn, roeMinIn, opmMinIn, deMaxIn, mcapMinIn, pegMaxIn]

[peMin, peMax, epsGrMin, revGrMin, roeMin, opmMin, deMax, mcapMin, pegMax] = f_preset(preset)

// ========================= ENTRY / WATCH INPUTS =========================
grpE = "ENTRY trigger"
rsiLen     = input.int(14,    "RSI length",                     group = grpE)
rsiLow     = input.float(30,  "RSI zone: low",                  group = grpE)
rsiHigh    = input.float(50,  "RSI zone: high",                 group = grpE)
entryProx  = input.float(1.5, "Support proximity, ATR (above)", group = grpE, step = 0.25)
entryUnder = input.float(0.5, "Allowed undercut, ATR (below)",  group = grpE, step = 0.25)
pivLen     = input.int(10,    "Pivot length (bars left/right)", group = grpE)
atrLen     = input.int(14,    "ATR length",                     group = grpE)

grpWch = "WATCH stage"
watchRsiMax = input.float(50, "RSI below",              group = grpWch)
watchProx   = input.float(4,  "Support proximity, ATR", group = grpWch, step = 0.5)

grpW = "Trend Filter (weekly)"
useWeekly = input.bool(true, "Trend on weekly TF (else current TF)", group = grpW)

grpV = "Display"
showTable = input.bool(true, "Show table",                  group = grpV)
showMAs   = input.bool(true, "Show SMA 50/200",             group = grpV)
showSup   = input.bool(true, "Show support level",          group = grpV)
showWatch = input.bool(true, "Highlight WATCH background",  group = grpV)

// ========================= COLOR PALETTE =========================
colTeal  = color.rgb(38, 166, 154)
colRed   = color.rgb(192, 108, 108)
colGray  = color.rgb(120, 128, 136)
colSlate = color.rgb(69, 90, 100)
colText  = color.rgb(30, 34, 40)
colTextL = color.rgb(235, 238, 242)

bgOK   = color.new(colTeal, 55)
bgNO   = color.new(colRed, 60)
bgNA   = color.new(colGray, 75)
bgHdr  = color.new(colGray, 88)
bgSect = color.new(colSlate, 25)

// ======================= FUNDAMENTAL DATA =======================
fqEps  = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_DILUTED", "FQ", ignore_invalid_symbol = true)
revTTM = request.financial(syminfo.tickerid, "TOTAL_REVENUE",              "TTM", ignore_invalid_symbol = true)
roe    = request.financial(syminfo.tickerid, "RETURN_ON_EQUITY",           "FQ", ignore_invalid_symbol = true)
opm    = request.financial(syminfo.tickerid, "OPERATING_MARGIN",           "FQ", ignore_invalid_symbol = true)
gm     = request.financial(syminfo.tickerid, "GROSS_MARGIN",               "FQ", ignore_invalid_symbol = true)
de     = request.financial(syminfo.tickerid, "DEBT_TO_EQUITY",             "FQ", ignore_invalid_symbol = true)
tso    = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING",   "FQ", ignore_invalid_symbol = true)

f_track(float src, float[] a) =>
    if not na(src) and (array.size(a) == 0 or src != array.get(a, array.size(a) - 1))
        array.push(a, src)

var float[] epsArr = array.new_float()
var float[] revArr = array.new_float()
var float[] opmArr = array.new_float()
var float[] tsoArr = array.new_float()
f_track(fqEps, epsArr)
f_track(revTTM, revArr)
f_track(opm, opmArr)
f_track(tso, tsoArr)

f_sumLast(float[] a, int n, int offset) =>
    s = array.size(a)
    float total = na
    if s >= n + offset
        total := 0.0
        for i = 0 to n - 1
            total += array.get(a, s - 1 - offset - i)
    total

f_back(float[] a, int offset) =>
    s = array.size(a)
    s >= offset + 1 ? array.get(a, s - 1 - offset) : na

// ---- metrics ----
epsTTM     = f_sumLast(epsArr, 4, 0)
epsTTMprev = f_sumLast(epsArr, 4, 4)
epsGrowth  = not na(epsTTM) and not na(epsTTMprev) and epsTTMprev > 0 ? (epsTTM / epsTTMprev - 1) * 100 : na

rev4 = f_back(revArr, 4)
rev8 = f_back(revArr, 8)
revGrowth     = not na(revTTM) and not na(rev4) and rev4 > 0 ? (revTTM / rev4 - 1) * 100 : na
revGrowthPrev = not na(rev4)   and not na(rev8) and rev8 > 0 ? (rev4   / rev8 - 1) * 100 : na

pe    = not na(epsTTM) and epsTTM > 0 ? close / epsTTM : na
peg   = not na(pe) and not na(epsGrowth) and epsGrowth > 0 ? pe / epsGrowth : na
mcapB = not na(tso) ? close * tso / 1e9 : na

opm4     = f_back(opmArr, 4)
opmTrend = not na(opm) and not na(opm4) ? opm - opm4 : na
tso4     = f_back(tsoArr, 4)
dilution = not na(tso) and not na(tso4) and tso4 > 0 ? (tso / tso4 - 1) * 100 : na
ruleOf40 = not na(revGrowth) and not na(opm) ? revGrowth + opm : na
revAccel = not na(revGrowth) and not na(revGrowthPrev) ? revGrowth - revGrowthPrev : na

// ---- tri-state: 1 = pass, 0 = fail, -1 = n/a ----
f_st(float v, bool cond) => na(v) ? -1 : cond ? 1 : 0

// ---- verdict over a set of skippable states + 2 core states ----
f_verdict(int[] skippable, int coreA, int coreB) =>
    int fails = 0
    int nas   = 0
    for st in skippable
        if st == 0
            fails += 1
        if st == -1
            nas += 1
    coreOK = coreA == 1 and coreB == 1
    bool ok = lenient ? (coreOK and fails == 0 and nas <= naLimit) : (coreOK and fails == 0 and nas == 0)
    [ok, nas]

// ---- standard-preset evaluator (reused for GARP / Growth / DV / Custom) ----
f_fundStd(float _peMin, float _peMax, float _epsGrMin, float _revGrMin, float _roeMin, float _opmMin, float _deMax, float _mcapMin, float _pegMax) =>
    _stM  = f_st(mcapB, mcapB > _mcapMin)
    _stR  = f_st(revGrowth, revGrowth > _revGrMin)
    int[] _sk = array.new_int()
    array.push(_sk, f_st(pe,        pe >= _peMin and pe <= _peMax))
    array.push(_sk, f_st(epsGrowth, epsGrowth > _epsGrMin))
    array.push(_sk, f_st(roe,       roe > _roeMin))
    array.push(_sk, f_st(opm,       opm > _opmMin))
    array.push(_sk, f_st(de,        de < _deMax))
    array.push(_sk, f_st(peg,       peg < _pegMax))
    [_ok, _nas] = f_verdict(_sk, _stM, _stR)
    [_ok, _nas]

// ---- emerging-growth evaluator ----
f_fundEG() =>
    _stM = f_st(mcapB, mcapB > egMcapMin)
    _stR = f_st(revGrowth, revGrowth > egRevGrMin)
    int[] _sk = array.new_int()
    array.push(_sk, f_st(revAccel, revAccel > 0))
    array.push(_sk, f_st(gm,       gm > egGmMin))
    array.push(_sk, f_st(opmTrend, opmTrend > 0))
    array.push(_sk, f_st(ruleOf40, ruleOf40 > egR40Min))
    array.push(_sk, f_st(de,       de < egDeMax))
    array.push(_sk, f_st(dilution, dilution < egDilMax))
    [_ok, _nas] = f_verdict(_sk, _stM, _stR)
    [_ok, _nas]

// ---- evaluate ALL presets in parallel ----
[fundGARP, naGARP] = f_fundStd(8, 35, 10, 5, 15, 15, 1, 10, 2)
[fundGrw,  naGrw]  = f_fundStd(8, 120, 25, 20, 12, 10, 1.5, 10, 3)
[fundDV,   naDV]   = f_fundStd(5, 18, 0, 0, 10, 10, 0.7, 10, 1.2)
[fundEG,   naEG]   = f_fundEG()
[fundCst,  naCst]  = f_fundStd(peMinIn, peMaxIn, epsGrMinIn, revGrMinIn, roeMinIn, opmMinIn, deMaxIn, mcapMinIn, pegMaxIn)

anyFund = fundGARP or fundGrw or fundDV or fundEG

// ---- selected-preset verdict (for table display) ----
[fundSel, naSel] = switch preset
    "GARP"            => [fundGARP, naGARP]
    "Growth"          => [fundGrw,  naGrw]
    "Deep Value"      => [fundDV,   naDV]
    "Emerging Growth" => [fundEG,   naEG]
    =>                   [fundCst,  naCst]

fundOK  = scope == "Any preset" ? anyFund : fundSel
naCount = naSel

matched = (fundGARP ? "GARP " : "") + (fundGrw ? "Growth " : "") + (fundDV ? "DeepValue " : "") + (fundEG ? "EmergGrowth" : "")
matched := matched == "" ? "none" : matched

// ---- table row states for the SELECTED preset ----
stMcapT = f_st(mcapB, mcapB > (isEmerging ? egMcapMin : mcapMin))
stRevT  = f_st(revGrowth, revGrowth > (isEmerging ? egRevGrMin : revGrMin))
stPe  = f_st(pe,        pe >= peMin and pe <= peMax)
stEps = f_st(epsGrowth, epsGrowth > epsGrMin)
stRoe = f_st(roe,       roe > roeMin)
stOpm = f_st(opm,       opm > opmMin)
stDe  = f_st(de,        de < deMax)
stPeg = f_st(peg,       peg < pegMax)
stAcc  = f_st(revAccel, revAccel > 0)
stGm   = f_st(gm,       gm > egGmMin)
stOpTr = f_st(opmTrend, opmTrend > 0)
stR40  = f_st(ruleOf40, ruleOf40 > egR40Min)
stDeE  = f_st(de,       de < egDeMax)
stDil  = f_st(dilution, dilution < egDilMax)

// ======================== TREND (WEEKLY) ========================
f_trend() =>
    [close, ta.sma(close, 50), ta.sma(close, 200)]

[wC, wS50, wS200] = request.security(syminfo.tickerid, useWeekly ? "W" : timeframe.period, f_trend(), lookahead = barmerge.lookahead_off)
trendFull = not na(wS200) and wC > wS200 and wS50 > wS200
trendYng  = na(wS200) and not na(wS50) and wC > wS50
trendOK   = trendFull or trendYng

// ================= SUPPORT: PIVOT LOW + SMA50 =================
atr    = ta.atr(atrLen)
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)
pl     = ta.pivotlow(low, pivLen, pivLen)

var float support = na
if not na(pl)
    support := pl

dPiv  = not na(support) ? (close - support) / atr : na
dMA   = (close - sma50) / atr
dShow = na(dPiv) ? dMA : (math.abs(dPiv) < math.abs(dMA) ? dPiv : dMA)

nearPiv = not na(dPiv) and dPiv <= entryProx and dPiv >= -entryUnder
nearMA  = dMA <= entryProx and dMA >= -entryUnder
nearSup = nearPiv or nearMA

watchPiv  = not na(dPiv) and dPiv <= watchProx and dPiv >= -entryUnder
watchMA   = dMA <= watchProx and dMA >= -entryUnder
watchNear = watchPiv or watchMA

// ========================== SIGNALS ==========================
rsi = ta.rsi(close, rsiLen)

rsiEntry = rsi >= rsiLow and rsi <= rsiHigh and rsi > rsi[1]
rsiWatch = rsi < watchRsiMax

entrySignal = fundOK and trendOK and rsiEntry and nearSup
watchSignal = fundOK and trendOK and rsiWatch and watchNear and not entrySignal

// =========================== PLOTS ===========================
plot(showMAs ? sma50  : na, "SMA 50",  color = color.new(colGray, 20))
plot(showMAs ? sma200 : na, "SMA 200", color = color.new(colSlate, 0), linewidth = 2)
plot(showSup ? support : na, "Support", color = color.new(colTeal, 30), style = plot.style_linebr, linewidth = 2)

plotshape(entrySignal, "ENTRY (pullback)", style = shape.triangleup, location = location.belowbar, color = color.new(colTeal, 0), size = size.small)
bgcolor(showWatch and watchSignal ? color.new(colGray, 94) : na)

// =========================== ALERTS ===========================
newEntry = entrySignal and not entrySignal[1]
newWatch = watchSignal and not watchSignal[1]

alertcondition(newEntry, "ENTRY signal", "Fund+Pullback ENTRY: {{ticker}} @ {{close}}")
alertcondition(newWatch, "WATCH signal", "Fund+Pullback WATCH: {{ticker}} @ {{close}}")
alertcondition(newEntry or newWatch, "Any signal (ENTRY or WATCH)", "Fund+Pullback signal: {{ticker}} @ {{close}}")

// Dynamic message with matched presets (use alert type: "Any alert() function call")
if barstate.isconfirmed and newEntry
    alert("ENTRY: " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " | passed: " + matched, alert.freq_once_per_bar_close)
if barstate.isconfirmed and newWatch
    alert("WATCH: " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " | passed: " + matched, alert.freq_once_per_bar_close)

// =========================== TABLE ===========================
f_fmt(float v, string suffix) => na(v) ? "n/a" : str.tostring(v, "#.##") + suffix

var table t = table.new(position.top_right, 4, 20, border_width = 1)

f_row(int r, string name, string val, string thr, int st) =>
    color bg   = st == 1 ? bgOK : st == 0 ? bgNO : lenient ? bgNA : bgNO
    string mrk = st == 1 ? "✓" : st == 0 ? "✗" : lenient ? "–" : "✗"
    table.cell(t, 0, r, name, text_color = colText, bgcolor = bgHdr, text_halign = text.align_left, text_size = size.small)
    table.cell(t, 1, r, val,  text_color = colText, bgcolor = bg, text_size = size.small)
    table.cell(t, 2, r, thr,  text_color = colText, bgcolor = bgHdr, text_size = size.small)
    table.cell(t, 3, r, mrk,  text_color = colText, bgcolor = bg, text_size = size.small)

f_sect(int r, string title, string c1, string c2) =>
    table.cell(t, 0, r, title, text_color = colTextL, bgcolor = bgSect, text_halign = text.align_left, text_size = size.small)
    table.cell(t, 1, r, c1, text_color = colTextL, bgcolor = bgSect, text_size = size.small)
    table.cell(t, 2, r, c2, text_color = colTextL, bgcolor = bgSect, text_size = size.small)
    table.cell(t, 3, r, "", bgcolor = bgSect)

f_b(bool b) => b ? 1 : 0

if barstate.islast and showTable
    f_sect(0, "PRESET", preset, scope == "Any preset" ? "scope: ANY" : "scope: sel")
    f_sect(1, "FUNDAMENTALS", "Value", "Threshold")

    if isEmerging
        f_row(2, "Mkt cap, B$",        f_fmt(mcapB, ""),       "> " + str.tostring(egMcapMin),        stMcapT)
        f_row(3, "Rev gr TTM YoY, %",  f_fmt(revGrowth, "%"),  "> " + str.tostring(egRevGrMin) + "%", stRevT)
        f_row(4, "Rev acceleration",   f_fmt(revAccel, " pp"), "> 0",                                 stAcc)
        f_row(5, "Gross margin, %",    f_fmt(gm, "%"),         "> " + str.tostring(egGmMin) + "%",    stGm)
        f_row(6, "Op margin trend",    f_fmt(opmTrend, " pp"), "> 0 (improving)",                     stOpTr)
        f_row(7, "Rule of 40",         f_fmt(ruleOf40, ""),    "> " + str.tostring(egR40Min),         stR40)
        f_row(8, "Debt/Equity",        f_fmt(de, ""),          "< " + str.tostring(egDeMax),          stDeE)
        f_row(9, "Dilution YoY, %",    f_fmt(dilution, "%"),   "< " + str.tostring(egDilMax) + "%",   stDil)
    else
        f_row(2, "Mkt cap, B$",       f_fmt(mcapB, ""),      "> " + str.tostring(mcapMin),  stMcapT)
        f_row(3, "P/E (TTM)",         f_fmt(pe, ""),         str.tostring(peMin) + "-" + str.tostring(peMax), stPe)
        f_row(4, "EPS gr TTM YoY, %", f_fmt(epsGrowth, "%"), "> " + str.tostring(epsGrMin) + "%", stEps)
        f_row(5, "Rev gr TTM YoY, %", f_fmt(revGrowth, "%"), "> " + str.tostring(revGrMin) + "%", stRevT)
        f_row(6, "ROE, %",            f_fmt(roe, "%"),       "> " + str.tostring(roeMin) + "%",   stRoe)
        f_row(7, "Op margin, %",      f_fmt(opm, "%"),       "> " + str.tostring(opmMin) + "%",   stOpm)
        f_row(8, "Debt/Equity",       f_fmt(de, ""),         "< " + str.tostring(deMax),          stDe)
        f_row(9, "PEG",               f_fmt(peg, ""),        "< " + str.tostring(pegMax),         stPeg)

    if lenient
        f_sect(10, "n/a skipped", str.tostring(naCount) + " / " + str.tostring(naLimit), "")

    f_sect(11, "Presets passed", matched, "")

    f_sect(12, "TECHNICALS", "", "")

    string trendVal = trendYng ? "C>" + f_fmt(wS50, "") + " (50w, young)" : "C>" + f_fmt(wS200, "") + " | 50>200"
    f_row(13, "Trend (W)", trendVal, "up", f_b(trendOK))
    f_row(14, "RSI (" + str.tostring(rsiLen) + ")", f_fmt(rsi, ""), str.tostring(rsiLow) + "-" + str.tostring(rsiHigh) + " rising", f_b(rsiEntry))
    f_row(15, "Dist to support, ATR", f_fmt(dShow, ""), "-" + str.tostring(entryUnder) + "...+" + str.tostring(entryProx), f_b(nearSup))

    string statusTxt = entrySignal ? "ENTRY" : watchSignal ? "WATCH" : "NO"
    color statusBg  = entrySignal ? color.new(colTeal, 35) : watchSignal ? color.new(colGray, 45) : color.new(colRed, 45)
    table.cell(t, 0, 17, "STATUS",  text_color = colText, bgcolor = statusBg, text_size = size.small)
    table.cell(t, 1, 17, statusTxt, text_color = colText, bgcolor = statusBg, text_size = size.small)
    table.cell(t, 2, 17, "", bgcolor = bgHdr)
    table.cell(t, 3, 17, fundOK ? "fund ✓" : "fund ✗", text_color = colText, bgcolor = fundOK ? bgOK : bgNO, text_size = size.small)
````
