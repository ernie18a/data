# Relative Volume At Time

- url: https://www.tradingview.com/script/c82Xuy1Y-Relative-Volume-At-Time/
- type: indicator
- pine_id: PUB;cd6f105ad255415699b07759e8ed95ed
- version: 4.0

## Description

Relative Volume At Time
What it does
This indicator shows how today's trading volume compares to the typical volume for this exact point in the session — not the full day average. A value of 1.5x means the stock is pacing 50% above its normal volume for this time of day, suggesting today's session could close at ~1.5x its average daily volume.
This is the same calculation used in the TradingView screener's "Rel Vol at Time" column.
Why it matters
Standard relative volume indicators compare current volume to the full average daily volume. The problem: at 10:00 AM only 20-30% of the day's volume has typically traded, so the number is always low and hard to interpret early in the session.
Relative Volume At Time solves this by comparing apples to apples — the first 60 minutes of today vs. the first 60 minutes of the past N days. This means the reading is meaningful from the very first minutes of the session.
How it works
On intraday charts (1m, 5m, 15m, etc.):
Each bar's volume is compared to the average volume of bars at the same minute of day over the previous N sessions.
On daily charts (recommended):
The indicator fetches intraday data via request.security_lower_tf and computes the cumulative volume from session open up to the current bar. This is then compared to the average cumulative volume at the same point in time across the previous N sessions.
Interpreting the values
ValueMeaning< 1.0Below average volume — avoid, low conviction1.0 – 1.5Neutral≥ 1.5Above average — worth attention≥ 2.0Strong signal — especially powerful on breakouts
Settings

Lookback days — Number of past sessions used to calculate the average. Default: 10. Recommended: 20 for a more stable baseline (one full trading month).
Smoothing (bars) — Applies an SMA over the last N RVOL values. Keep at 1 for raw real-time readings.
Intraday resolution for daily mode — The lower timeframe used to fetch intraday volume on daily charts. Default: 1 minute for maximum accuracy.
Show current vs average volume — Displays the raw volume numbers used in the calculation, useful for debugging or verification.

Best use case
Works best as a filter for breakout and trend-following strategies on daily charts. Before entering a trade, confirm that RVOL at Time is ≥ 1.5x to ensure the move is backed by genuine volume conviction rather than low-liquidity drift.
Built-in alerts are included for ≥ 1.5x and ≥ 2.0x thresholds.

## Source Code

````pine
//@version=6
// =====================================================================
//  Relative Volume At Time + Breakout RVol [Galin]
//
//  INTRADAY chart (1m, 5m, 15m, 1h, ...):
//      compares the CURRENT bar's volume to the average volume of bars
//      at the SAME minute of day over the previous N sessions.
//
//  DAILY (or higher) chart:
//      the current daily bar is today's partial session. We fetch the
//      intraday volume of every past daily bar via request.security_lower_tf,
//      sum the same number of intraday bars (= today's bars-so-far) for
//      each past day, and compare today's cumulative volume to that average.
//
//      So at 30 minutes into the session, today's first-30-minutes volume
//      is compared to the average first-30-minutes volume of the last N
//      sessions - which is exactly the "Rel Vol at Time" semantics from
//      the TradingView screener.
//
//  A value of 1.5 means today is pacing 50% above the typical volume for
//  this point of the day, and the daily candle is on track to close at
//  ~1.5x its average daily volume.
//
//  BREAKOUT RVOL (invisible until a pivot is set):
//      set a pivot price in the settings. The first bar of the session
//      whose HIGH touches the pivot starts a volume window. BRVol =
//      volume traded since that moment vs the average volume traded in
//      the SAME time-of-day window over the lookback days.
//      Works on intraday charts (stateful bar timer) AND on daily
//      charts (window built from the same intraday arrays used by
//      daily-mode RVol; the confirm window then counts bars of the
//      selected intraday resolution - minutes by default).
//      Gray = armed · orange = counting · green = confirmed ·
//      red = confirm window elapsed without volume. Re-arms every day.
// =====================================================================
indicator("Relative Volume At Time + Breakout RVol [Galin]", overlay = true, precision = 2)

// ----------------------------- Inputs --------------------------------
lookbackDays    = input.int(10,   "Lookback days",   minval = 1, maxval = 100)
smoothing       = input.int(1,    "Smoothing (bars)", minval = 1, maxval = 50, tooltip = "SMA over the last N bars of the ratio. 1 = no smoothing. Useful on noisy 1m charts.")
intradayResForD = input.string("1", "Intraday resolution for daily mode", options = ["1", "3", "5", "15"], tooltip = "On daily/weekly/monthly charts, this is the lower timeframe used to fetch intraday volume for time-of-day matching. Also defines the confirm-window unit for Breakout RVol on daily charts.")
showRaw         = input.bool(false, "Show current vs average volume")
tblPos          = input.string("top_right", "Table position", options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right", "middle_left"])
txtSize         = input.string("large", "Number size", options = ["small", "normal", "large", "huge"])

// ── BREAKOUT RVOL: inputs ─────────────────────────────────────────────
string grpBR    = "Breakout RVol"
pivotPrice      = input.float(0.0, "Pivot price (0 = off)", minval = 0, step = 0.01, group = grpBR)
confirmBars     = input.int(30,    "Confirm window (bars)", minval = 1, group = grpBR, tooltip = "1m chart: 30 bars = 30 min · 5m chart: 6 bars = 30 min · daily chart: bars of the intraday resolution above (default 1 = minutes)")
minConfirm      = input.float(1.0, "Min BRVol to confirm",  step = 0.1, group = grpBR)

// ----------------------------- Mode ----------------------------------
bool isIntraday = not (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)

// =====================================================================
//                          INTRADAY  PATH
// =====================================================================
var matrix<float> hist   = matrix.new<float>(1440, lookbackDays, na)
var array<int>    posArr = array.new<int>(1440, 0)

int tod = hour * 60 + minute

float sumIntra = 0.0
int   cntIntra = 0
if isIntraday and tod >= 0 and tod < 1440
    for c = 0 to lookbackDays - 1
        float v = matrix.get(hist, tod, c)
        if not na(v)
            sumIntra += v
            cntIntra += 1
float avgVolIntra = cntIntra > 0 ? sumIntra / cntIntra : na
float relVolIntra = (not na(avgVolIntra) and avgVolIntra > 0) ? volume / avgVolIntra : na

if isIntraday and barstate.isconfirmed and tod >= 0 and tod < 1440 and not na(volume)
    int p = array.get(posArr, tod)
    matrix.set(hist, tod, p % lookbackDays, volume)
    array.set(posArr, tod, p + 1)

// =====================================================================
//                          DAILY+  PATH
// =====================================================================
array<float> ltfVols = isIntraday ? na : request.security_lower_tf(syminfo.tickerid, intradayResForD, volume)

int   K        = na(ltfVols) ? 0   : array.size(ltfVols)
float todayCum = na
if not isIntraday and K > 0
    float s = 0.0
    for i = 0 to K - 1
        s += array.get(ltfVols, i)
    todayCum := s

float sumPast = 0.0
int   cntPast = 0
if not isIntraday and K > 0
    for d = 1 to lookbackDays
        array<float> pastArr = ltfVols[d]
        if not na(pastArr)
            int pSize = array.size(pastArr)
            if pSize >= K
                float cum = 0.0
                for i = 0 to K - 1
                    cum += array.get(pastArr, i)
                sumPast += cum
                cntPast += 1
float avgVolDaily = cntPast > 0 ? sumPast / cntPast : na
float relVolDaily = (not na(avgVolDaily) and avgVolDaily > 0) ? todayCum / avgVolDaily : na

// =====================================================================
//                          Combine + smoothing
// =====================================================================
float relVolRaw  = isIntraday ? relVolIntra : relVolDaily
float displayVol = isIntraday ? volume      : todayCum
float displayAvg = isIntraday ? avgVolIntra : avgVolDaily
float relVol     = smoothing > 1 ? ta.sma(relVolRaw, smoothing) : relVolRaw

// =====================================================================
//          BREAKOUT RVOL  (intraday AND daily charts)
//  Numerator:   real volume accumulated since the pivot was touched.
//  Denominator: average volume traded in the SAME time-of-day window
//               over the lookback days.
// =====================================================================
bool brActive = pivotPrice > 0

// ── intraday path: stateful timer reusing the per-minute averages ──
var int   brDays    = 0
var bool  trigIntra = false
var int   trigBar   = na
var float winVol    = na
var float avgWin    = na

if isIntraday and (timeframe.change("D") or barstate.isfirst)
    brDays    += 1
    trigIntra := false
    trigBar   := na
    winVol    := na
    avgWin    := na

bool brTrigEvtI = isIntraday and brActive and not trigIntra and high >= pivotPrice
if brTrigEvtI
    trigIntra := true
    trigBar   := bar_index
    winVol    := volume                 // window includes the trigger bar itself
    avgWin    := nz(avgVolIntra)
else if isIntraday and brActive and trigIntra
    winVol += volume
    avgWin += nz(avgVolIntra)

float brValIntra = trigIntra and brDays >= 5 and not na(avgWin) and avgWin > 0 ? winVol / avgWin : na

// ── daily path: stateless window over the intraday arrays ──
array<float> ltfHighs = isIntraday ? na : request.security_lower_tf(syminfo.tickerid, intradayResForD, high)

int trigIdxD = na
if not isIntraday and brActive and K > 0 and high >= pivotPrice
    int KH = math.min(K, array.size(ltfHighs))
    for i = 0 to KH - 1
        if array.get(ltfHighs, i) >= pivotPrice
            trigIdxD := i
            break

float brValDaily = na
int   brBarsInD  = 0
if not na(trigIdxD)
    float wToday = 0.0
    for i = trigIdxD to K - 1
        wToday += array.get(ltfVols, i)
    float wSum = 0.0
    int   wCnt = 0
    for d = 1 to lookbackDays
        array<float> pastArr = ltfVols[d]
        if not na(pastArr)
            int pSize = array.size(pastArr)
            if pSize >= K
                float cum = 0.0
                for i = trigIdxD to K - 1
                    cum += array.get(pastArr, i)
                wSum += cum
                wCnt += 1
    brBarsInD  := K - trigIdxD
    brValDaily := wCnt >= 5 and wSum > 0 ? wToday / (wSum / wCnt) : na

// ── unified state ──
bool  brTriggered = isIntraday ? trigIntra : not na(trigIdxD)
int   brBarsIn    = isIntraday ? (trigIntra ? bar_index - trigBar + 1 : 0) : brBarsInD
float brVal       = isIntraday ? brValIntra : brValDaily
bool  brConf      = brTriggered and not na(brVal) and brVal >= minConfirm
bool  brFail      = brTriggered and not na(brVal) and brBarsIn >= confirmBars and brVal < minConfirm

plot(brActive ? pivotPrice : na, "BRVol pivot", color.new(color.aqua, 55), 1, plot.style_linebr)
plotshape(brTriggered and not brTriggered[1], "BRVol trigger", shape.triangleup, location.belowbar, color.new(color.aqua, 0), size = size.tiny)

// ----------------------------- Helpers -------------------------------
f_fmt(x) =>
    string r = "n/a"
    if not na(x)
        if x >= 1e9
            r := str.tostring(x / 1e9, "#.##") + "B"
        else if x >= 1e6
            r := str.tostring(x / 1e6, "#.##") + "M"
        else if x >= 1e3
            r := str.tostring(x / 1e3, "#.##") + "K"
        else
            r := str.tostring(x, "#.##")
    r

tablePosition = switch tblPos
    "top_left"     => position.top_left
    "top_right"    => position.top_right
    "bottom_left"  => position.bottom_left
    "bottom_right" => position.bottom_right
    "middle_left"  => position.middle_left
    => position.middle_right

txtSizeOpt = switch txtSize
    "small"  => size.small
    "normal" => size.normal
    "huge"   => size.huge
    => size.large

// ----------------------------- Render --------------------------------
var table t = table.new(tablePosition, 2, 4, border_width = 1)

if barstate.islast
    table.clear(t, 0, 0, 1, 3)

    rvolColor = (not na(relVol) and relVol >= 1) ? color.new(color.green, 0) : color.new(color.gray, 0)

    table.cell(t, 0, 0, "RVol", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.normal)
    table.cell(t, 1, 0, na(relVol) ? "n/a" : str.tostring(relVol, "#.##") + "x", text_color = color.white, bgcolor = rvolColor, text_size = txtSizeOpt)

    if showRaw
        table.cell(t, 0, 1, isIntraday ? "Current bar vol" : "Today cum vol", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
        table.cell(t, 1, 1, f_fmt(displayVol), text_color = color.white, bgcolor = color.new(color.blue, 30), text_size = size.small)
        table.cell(t, 0, 2, "Avg @ this time", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
        table.cell(t, 1, 2, f_fmt(displayAvg), text_color = color.white, bgcolor = color.new(color.blue, 30), text_size = size.small)

    // ── BREAKOUT RVOL: table row ──
    int brRow = showRaw ? 3 : 1
    if brActive
        string btxt = not brTriggered ?
             "armed @ " + str.tostring(pivotPrice, format.mintick) :
             (na(brVal) ? "…" : str.tostring(brVal, "#.##") + "x") + " · " + str.tostring(brBarsIn) + "/" + str.tostring(confirmBars)
        color bbg = not brTriggered ? color.new(color.gray, 40) :
             brConf ? color.new(color.green, 20) :
             brFail ? color.new(color.red, 20)   : color.new(color.orange, 25)
        table.cell(t, 0, brRow, "BRVol", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.normal)
        table.cell(t, 1, brRow, btxt, text_color = color.white, bgcolor = bbg, text_size = size.normal)

// ----------------------------- Alerts --------------------------------
alertcondition(not na(relVol) and relVol >= 2,   "Rel Vol at Time >= 2x",   "Volume is pacing at 2x the typical volume for this point of the session")
alertcondition(not na(relVol) and relVol >= 1.5, "Rel Vol at Time >= 1.5x", "Volume is pacing at 1.5x the typical volume for this point of the session")

// ── BREAKOUT RVOL: alerts (create them with "Once per bar") ──
bool aTrig = isIntraday ? brTrigEvtI : brTriggered
bool aConf = isIntraday ? (brConf and not brConf[1]) : brConf
bool aFail = isIntraday ? (brFail and not brFail[1]) : brFail

alertcondition(aTrig, "BRVol: trigger",          "Pivot crossed — breakout volume window started")
alertcondition(aConf, "BRVol: volume CONFIRMED", "Breakout RVol above threshold")
alertcondition(aFail, "BRVol: volume FAILED",    "Confirm window elapsed — breakout RVol still below threshold")
````
