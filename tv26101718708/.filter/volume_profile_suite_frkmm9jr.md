# Volume Profile Suite

- url: https://www.tradingview.com/script/FRKmm9jr-Volume-Profile-Suite/
- type: indicator
- pine_id: PUB;2c925423f53143858b5b6717ed4c90ca
- version: 6.0

## Description

VP Suite: Volume Profile, Value Areas & Multi-Timeframe Levels

VP Suite shows where volume actually traded and turns it into clear, graded levels for planning your day.

What it shows

Session profiles: volume at each price, split into buyers and sellers. The split is estimated from lower-timeframe candles.
POC, VAH and VAL: the most-traded price and the value area that holds 70% of the volume.
Prior-day value area: yesterday’s VAH, POC and VAL as dashed lines.
Carried POCs: previous sessions’ POCs, kept on the chart until price trades through them.
HVN zones: high-volume areas where price tends to slow down and react.
LVN zones: low-volume gaps that price tends to move through fast or reject hard.
MTF confluence zones: levels where the monthly, weekly and daily profiles agree. They’re tagged like M W D and graded A+ (all three agree), A (two) or B (one).
Status panel: where price sits compared with value, where the session opened, the nearest zone above and below with the distance in points, and today’s buy/sell split.

How to use it

Before the open: note the nearest A+ and A zones above and below price, plus any carried POC nearby.
Plan scenarios:
If price breaks an LVN, the next HVN is the likely target.
If price rejects at an LVN, expect a rotation back to the HVN it came from.
During the session: wait for price to reach a zone and watch how it reacts. A stall at an HVN, a sharp rejection at an LVN, or a clean break followed by a retest each show you who’s in control.
Rule of thumb: price rests at HVNs and travels through LVNs.

Quick settings

Preset: Minimal, Standard or Full.
Theme: Auto, Light or Dark.
Session: ETH (the full 24-hour session) or RTH (9:30–16:00 New York).
Focus: the zones nearest price stay strong and the rest fade.

Works on any intraday timeframe and is tuned for futures such as NQ/MNQ. It’s a tool for reading the market, not trading advice.

## Source Code

````pine
//@version=6
indicator("Volume Profile Suite", "VP Suite", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_polylines_count = 10, max_bars_back = 5000, behind_chart = true)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
grpGen = "General"
preset = input.string("Full", "Preset", options = ["Minimal", "Standard", "Full", "Custom"], group = grpGen, tooltip = "Minimal: session profiles + carried POCs. Standard: + HVN / LVN zones. Full: + M / W / D confluence zones. Custom: use the switches marked '· Custom'.")
theme  = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light", "Custom"], group = grpGen, tooltip = "Auto matches your chart background. Custom uses the colors in 'Colors (Custom theme)'.")

grpSes = "Session Profile"
inShowSes       = input.bool(true, "Session profiles · Custom", group = grpSes)
sesMode         = input.string("ETH (full)", "Session", options = ["ETH (full)", "RTH"], group = grpSes, tooltip = "RTH builds one profile per day from regular trading hours only.")
rthSess         = input.session("0930-1600", "RTH hours (New York time)", group = grpSes)
sesTf           = input.timeframe("D", "Period (ETH only)", group = grpSes)
sesRows         = input.int(24, "Rows", minval = 5, maxval = 200, group = grpSes, tooltip = "More rows = finer detail. At high row counts fewer completed profiles are shown so everything fits TradingView's 500-box limit.")
rowStyle        = input.string("Split (buyers | sellers)", "Row style", options = ["Split (buyers | sellers)", "Winner color"], group = grpSes, tooltip = "Split shows buyers and sellers side by side in each value-area row. Winner color colors the whole row by the side that traded more.")
sesShowDev      = input.bool(true, "Show developing profile + levels", group = grpSes)
sesMax          = input.int(4, "Completed profiles to show", minval = 1, maxval = 12, group = grpSes)
sesCurWidthPct  = input.int(12, "Current profile width (% of period)", minval = 2, maxval = 100, group = grpSes)
sesPastWidthPct = input.int(10, "Previous profiles width (% of period)", minval = 2, maxval = 100, group = grpSes)
profTransp      = input.int(40, "Current profile transparency %", minval = 0, maxval = 95, group = grpSes)
pastTransp      = input.int(65, "Previous profiles transparency %", minval = 0, maxval = 95, group = grpSes)

grpLvl = "Levels"
showPd         = input.bool(true, "Prior-day VAH / POC / VAL", group = grpLvl, tooltip = "Yesterday's value area (the last completed session) drawn dashed across today.")
pdLabels       = input.bool(true, "Label prior-day lines", group = grpLvl)
pdPocLblCustom = input.bool(false, "Custom pPOC label color", inline = "ppoc", group = grpLvl, tooltip = "Off: the pPOC label follows the theme.")
cPdPocLbl      = input.color(#E31B23, "", inline = "ppoc", group = grpLvl)
inShowPocCarry = input.bool(true, "Carried POCs · Custom", group = grpLvl)
pocMode        = input.string("Until touched", "Carried POC mode", options = ["Until touched", "Always"], group = grpLvl)
pocStopAtSes   = input.bool(true, "Stop carried POCs at current session", group = grpLvl, tooltip = "Previous POCs run through completed sessions but end where the current session begins.")
pocMax         = input.int(10, "Max carried POCs", minval = 1, maxval = 50, group = grpLvl)
showDpoc       = input.bool(true, "Developing POC path", group = grpLvl, tooltip = "Step line showing where today's POC has been during the session.")

grpZones = "Zones"
inShowHvn        = input.bool(true, "High volume nodes (HVN) · Custom", group = grpZones)
inShowLvn        = input.bool(true, "Low volume nodes (LVN) · Custom", group = grpZones)
nodeSrc          = input.string("Last Session", "HVN / LVN source", options = ["Last Session", "Developing Session"], group = grpZones)
nodeMinGrade     = input.string("B", "HVN / LVN minimum grade", options = ["A+", "A", "B"], group = grpZones)
nodeMax          = input.int(8, "Max HVN / LVN zones each", minval = 1, maxval = 20, group = grpZones)
nodeMaxHeightPct = input.float(6, "Max zone height (% of profile range)", minval = 1, maxval = 50, group = grpZones)
inShowMtf        = input.bool(true, "M / W / D confluence · Custom", group = grpZones)
mtfUseM          = input.bool(true, "Monthly", inline = "tfs", group = grpZones)
mtfUseW          = input.bool(true, "Weekly", inline = "tfs", group = grpZones)
mtfUseD          = input.bool(true, "Daily", inline = "tfs", group = grpZones)
mtfUseDev        = input.bool(true, "Include developing week / month", group = grpZones, tooltip = "Also take levels from the week and month in progress (updated once per bar). Completed-period levels stay fixed.")
mtfMinTf         = input.int(1, "Min timeframes agreeing", minval = 1, maxval = 3, group = grpZones, tooltip = "Grade = timeframe count: 3 = A+, 2 = A, 1 = B. The more timeframes, the heavier the zone is drawn.")
mtfMax           = input.int(15, "Max confluence zones", minval = 1, maxval = 30, group = grpZones)

grpFocus = "Focus & Labels"
focusOn       = input.bool(true, "Highlight nearest zones", group = grpFocus, tooltip = "Zones closest to price are drawn at full strength; the rest fade.")
focusCount    = input.int(2, "Nearest zones above / below", minval = 1, maxval = 10, group = grpFocus)
focusFade     = input.int(50, "Fade others by %", minval = 0, maxval = 90, group = grpFocus)
fadeOld       = input.bool(true, "Fade older zones and POCs", group = grpFocus)
ageFadeMax    = input.int(30, "Max age fade %", minval = 0, maxval = 80, group = grpFocus)
tagGapMult    = input.float(0.4, "Merge tags closer than (x ATR)", minval = 0, maxval = 5, step = 0.1, group = grpFocus, tooltip = "Right-edge tags this close together are combined into one, e.g. 'M W D  A+ · pVAH'. 0 = never merge.")
nodeLblCustom = input.bool(false, "Custom HVN / LVN label colors", group = grpFocus, tooltip = "Off: labels follow the theme.")
cHvnLbl       = input.color(#5F6368, "HVN label", inline = "nlbl", group = grpFocus)
cLvnLbl       = input.color(#5F6368, "LVN label", inline = "nlbl", group = grpFocus)

grpPanel = "Status Panel"
showPanel = input.bool(true, "Show status panel", group = grpPanel)
panelPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpPanel)
panelSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpPanel)

grpLines = "Lines"
cVahLine      = input.color(#9AA0A699, "VAH line", inline = "vah", group = grpLines)
vahStyle      = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], inline = "vah", group = grpLines)
cValLine      = input.color(#9AA0A699, "VAL line", inline = "val", group = grpLines)
valStyle      = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], inline = "val", group = grpLines)
cPocLine      = input.color(#E31B2399, "Current POC line", inline = "poc", group = grpLines)
pocWidth      = input.int(1, "Width", minval = 1, maxval = 4, inline = "poc", group = grpLines)
cPocCarry     = input.color(#E31B2359, "Carried POC lines", inline = "pocc", group = grpLines)
pocCarryWidth = input.int(1, "Width", minval = 1, maxval = 4, inline = "pocc", group = grpLines)
cDpoc         = input.color(#E31B2380, "POC path", inline = "dpoc", group = grpLines)
dpocWidth     = input.int(1, "Width", minval = 1, maxval = 4, inline = "dpoc", group = grpLines)

grpStyle = "Colors (Custom theme)"
cBuyIn     = input.color(#D9D9D9, "Buyers", group = grpStyle)
cSellIn    = input.color(#E31B23, "Sellers", group = grpStyle)
cBuyDimIn  = input.color(#2E3138, "Outside VA (buyers)", group = grpStyle)
cSellDimIn = input.color(#5A1418, "Outside VA (sellers)", group = grpStyle)
cTextIn    = input.color(#9AA0A6, "Label text", group = grpStyle)
cZoneIn    = input.color(#4A4F57, "HVN / LVN zones", group = grpStyle)
cMtfIn     = input.color(#4A4F57, "MTF confluence zones", group = grpStyle)

grpAdv = "Advanced"
profDetail    = input.string("Intrabar (accurate)", "Profile detail", options = ["Intrabar (accurate)", "Chart bars (fast)"], group = grpAdv, tooltip = "Intrabar places volume where the lower-timeframe candles actually traded. Chart bars spreads each bar's volume evenly over its range (faster, less memory). 1-minute charts always use chart bars.")
ltfInput      = input.string("Auto", "Intrabar timeframe", options = ["Auto", "1", "3", "5", "15", "30", "60"], group = grpAdv, tooltip = "Lower-timeframe candles used for the buy/sell split and intrabar detail: up candles = buyers, down candles = sellers. Auto picks a timeframe below the chart's.")
maxBuf        = input.int(10000, "Max bars kept in memory", minval = 500, maxval = 50000, group = grpAdv, tooltip = "Profiles can only be built from bars kept in memory. Raise this for monthly profiles on low timeframes.")
vaPct         = input.float(70, "Value Area %", minval = 10, maxval = 99, group = grpAdv)
hvnMinPct     = input.float(45, "HVN min size (% of POC)", minval = 5, maxval = 100, group = grpAdv)
lvnMinDepth   = input.float(50, "LVN min depth (%)", minval = 10, maxval = 100, group = grpAdv, tooltip = "How far the row's volume dips below the smaller of the volume peaks on either side.")
mtfTolMult    = input.float(1.0, "MTF agreement tolerance (x ATR)", minval = 0.1, maxval = 10, step = 0.1, group = grpAdv)
mtfRows       = input.int(40, "MTF rows per profile", minval = 10, maxval = 200, group = grpAdv)
mtfNodesPerTf = input.int(3, "MTF HVNs per timeframe", minval = 0, maxval = 10, group = grpAdv)

ROW_GAP = 0.08
MAX_BARS_BACK_DRAW = 4500
LTF_CAP = 90000
bool splitRows = rowStyle == "Split (buyers | sellers)"
int boxesPerRow = splitRows ? 2 : 1
sesMaxEff = math.max(0, math.min(sesMax, int((440 - sesRows * boxesPerRow) / (sesRows * boxesPerRow))))
minRank = nodeMinGrade == "A+" ? 3 : nodeMinGrade == "A" ? 2 : 1

// ─────────────────────────────────────────────────────────────────────────────
// Preset + theme resolution
// ─────────────────────────────────────────────────────────────────────────────
bool customPreset = preset == "Custom"
showSes      = customPreset ? inShowSes : true
showPocCarry = customPreset ? inShowPocCarry : true
showHvn      = customPreset ? inShowHvn : preset != "Minimal"
showLvn      = customPreset ? inShowLvn : preset != "Minimal"
showMtf      = customPreset ? inShowMtf : preset == "Full"

float bgLum = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool customTheme = theme == "Custom"
bool lightTheme  = theme == "Light" or (theme == "Auto" and bgLum > 128)
colBuy     = customTheme ? cBuyIn     : lightTheme ? #3C4048 : #D9D9D9
colSell    = customTheme ? cSellIn    : lightTheme ? #D32F2F : #E31B23
colBuyDim  = customTheme ? cBuyDimIn  : lightTheme ? #A9AEB5 : #2E3138
colSellDim = customTheme ? cSellDimIn : lightTheme ? #E3A3A3 : #5A1418
colText    = customTheme ? cTextIn    : lightTheme ? #5F6368 : #9AA0A6
colZone    = customTheme ? cZoneIn    : lightTheme ? #5F6368 : #4A4F57
colMtf     = customTheme ? cMtfIn     : lightTheme ? #5F6368 : #4A4F57

// ─────────────────────────────────────────────────────────────────────────────
// Per-bar buy / sell volume from lower-timeframe candles
// ─────────────────────────────────────────────────────────────────────────────
chartSec = timeframe.in_seconds()
string autoTf = chartSec <= 300 ? "1" : chartSec <= 3600 ? "5" : chartSec <= 14400 ? "15" : "60"
string wantTf = ltfInput == "Auto" ? autoTf : ltfInput
bool useLtf = timeframe.in_seconds(wantTf) < chartSec
bool useIb  = useLtf and profDetail == "Intrabar (accurate)"

// Intrabar buffer: one entry per lower-timeframe candle. ltfBase = absolute index of element 0.
var array<float> ltfH = array.new<float>()
var array<float> ltfL = array.new<float>()
var array<float> ltfB = array.new<float>()
var array<float> ltfS = array.new<float>()
var int ltfTotal = 0
var int ltfBase  = 0

float buyV  = 0.0
float sellV = 0.0
bool gotLtf = false
int ibStart = ltfTotal
int ibN = 0
if useLtf
    [ltfO, ltfC, ltfV, ltfHi, ltfLo] = request.security_lower_tf(syminfo.tickerid, wantTf, [open, close, volume, high, low])
    if ltfV.size() > 0
        gotLtf := true
        for i = 0 to ltfV.size() - 1
            float v = nz(ltfV.get(i))
            float o = ltfO.get(i)
            float c = ltfC.get(i)
            float bI = c > o ? v : c < o ? 0.0 : v * 0.5
            float sI = v - bI
            buyV  += bI
            sellV += sI
            if useIb
                ltfH.push(ltfHi.get(i))
                ltfL.push(ltfLo.get(i))
                ltfB.push(bI)
                ltfS.push(sI)
                ibN += 1
if not gotLtf
    // Fallback: split by where the close sits in the bar's range
    float v   = nz(volume)
    float rng = high - low
    float bf  = rng > 0 ? (close - low) / rng : 0.5
    buyV  := v * bf
    sellV := v * (1 - bf)
ltfTotal += ibN
while ltfH.size() > LTF_CAP
    ltfH.shift()
    ltfL.shift()
    ltfB.shift()
    ltfS.shift()
    ltfBase += 1

// Rolling buffer of chart-bar data used to build every profile
var array<float> bufH  = array.new<float>()
var array<float> bufL  = array.new<float>()
var array<float> bufB  = array.new<float>()
var array<float> bufS  = array.new<float>()
var array<int>   bufLs = array.new<int>()
var array<int>   bufLn = array.new<int>()
bufH.push(high)
bufL.push(low)
bufB.push(buyV)
bufS.push(sellV)
bufLs.push(ibStart)
bufLn.push(ibN)
if bufH.size() > maxBuf
    bufH.shift()
    bufL.shift()
    bufB.shift()
    bufS.shift()
    bufLs.shift()
    bufLn.shift()

atrVal = ta.atr(14)

// Drawings that are rebuilt on the last bar
var array<box>    tmpBoxes  = array.new<box>()
var array<line>   tmpLines  = array.new<line>()
var array<label>  tmpLabels = array.new<label>()
// Right-edge tags waiting to be merged and drawn
var array<float>  tagY   = array.new<float>()
var array<string> tagTxt = array.new<string>()
var array<color>  tagCol = array.new<color>()
var array<int>    tagPri = array.new<int>()

// ─────────────────────────────────────────────────────────────────────────────
// Profile engine
// ─────────────────────────────────────────────────────────────────────────────
type Profile
    float lo
    float hi
    float step
    int rows
    array<float> buy
    array<float> sell
    array<float> tot
    int poc
    int vahRow
    int valRow
    float totBuy
    float totSell

// A price zone to draw on the last bar (HVN, LVN or MTF)
type Zone
    float top
    float bot
    int x1
    string kind
    string tag
    string grade
    int weight
    string extra
    bool alive
    bool focus

// Keep a drawing's left edge well inside how far back TradingView lets a script draw (stays under max_bars_back)
xClamp(int x) =>
    math.max(x, bar_index - MAX_BARS_BACK_DRAW)

// Buffer position of a bar_index (clamped to what is in memory)
posOf(int bi) =>
    int first = bar_index - bufH.size() + 1
    math.min(bufH.size() - 1, math.max(0, bi - first))

// Spread one candle's buy / sell volume over the rows its high-low range covers
spreadVol(array<float> buy, array<float> sell, float lo, float step, int rows, float h, float l, float bv, float sv) =>
    float rng = h - l
    int r0 = math.min(rows - 1, math.max(0, math.floor((l - lo) / step)))
    int r1 = math.min(rows - 1, math.max(0, math.floor((h - lo) / step)))
    for r = r0 to r1
        float rLo = lo + r * step
        float w = rng > 0 ? (math.min(h, rLo + step) - math.max(l, rLo)) / rng : 1.0 / (r1 - r0 + 1)
        if w > 0
            buy.set(r, buy.get(r) + bv * w)
            sell.set(r, sell.get(r) + sv * w)
    true

// Build a profile from buffer positions [fromPos, toPos]
buildProfile(int fromPos, int toPos, int rows, float vaP) =>
    float lo = bufL.get(fromPos)
    float hi = bufH.get(fromPos)
    for i = fromPos to toPos
        lo := math.min(lo, bufL.get(i))
        hi := math.max(hi, bufH.get(i))
    if hi - lo < syminfo.mintick
        hi := lo + syminfo.mintick * rows
    float step = (hi - lo) / rows
    buy  = array.new<float>(rows, 0.0)
    sell = array.new<float>(rows, 0.0)
    for i = fromPos to toPos
        int ln = bufLn.get(i)
        int ls = bufLs.get(i)
        if useIb and ln > 0 and ls >= ltfBase
            // Intrabar detail: place volume where each lower-timeframe candle traded
            int s0 = ls - ltfBase
            for j = s0 to s0 + ln - 1
                spreadVol(buy, sell, lo, step, rows, ltfH.get(j), ltfL.get(j), ltfB.get(j), ltfS.get(j))
        else
            spreadVol(buy, sell, lo, step, rows, bufH.get(i), bufL.get(i), bufB.get(i), bufS.get(i))
    tot = array.new<float>(rows, 0.0)
    for r = 0 to rows - 1
        tot.set(r, buy.get(r) + sell.get(r))
    // POC and Value Area: expand from the POC towards the heavier neighbour
    int poc = tot.indexof(tot.max())
    float target = tot.sum() * vaP / 100
    int up = poc
    int dn = poc
    float acc = tot.get(poc)
    while acc < target and (up < rows - 1 or dn > 0)
        float vUp = -1.0
        float vDn = -1.0
        if up < rows - 1
            vUp := tot.get(up + 1)
        if dn > 0
            vDn := tot.get(dn - 1)
        if vUp >= vDn
            up += 1
            acc += vUp
        else
            dn -= 1
            acc += vDn
    Profile.new(lo, hi, step, rows, buy, sell, tot, poc, up, dn, buy.sum(), sell.sum())

rowTop(Profile p, int r) =>
    p.lo + (r + 1) * p.step - p.step * ROW_GAP
rowBot(Profile p, int r) =>
    p.lo + r * p.step + p.step * ROW_GAP
rowMid(Profile p, int r) =>
    p.lo + (r + 0.5) * p.step
vahPrice(Profile p) =>
    p.lo + (p.vahRow + 1) * p.step
valPrice(Profile p) =>
    p.lo + p.valRow * p.step

// Moving-average smoothing for node detection; the window grows with the row count
smoothK(int n) =>
    math.max(1, math.round(n / 30))

smooth(array<float> a) =>
    int n = a.size()
    int k = smoothK(n)
    out = array.new<float>(n, 0.0)
    for i = 0 to n - 1
        float sum = 0.0
        int cnt = 0
        for j = math.max(0, i - k) to math.min(n - 1, i + k)
            sum += a.get(j)
            cnt += 1
        out.set(i, sum / cnt)
    out

// Add a zone spanning rows a..b around centre row c, capped in height.
// A zone touching the previous one replaces it only if stronger (no stacked zones). Returns the new last row.
addZone(Profile p, array<float> zLo, array<float> zHi, array<float> zSc, int a, int b, int c, float score, int lastHi) =>
    float lo = p.lo + a * p.step
    float hi = p.lo + (b + 1) * p.step
    float maxH = (p.hi - p.lo) * nodeMaxHeightPct / 100
    if hi - lo > maxH
        float mid = rowMid(p, c)
        lo := mid - maxH / 2
        hi := mid + maxH / 2
    int newLast = lastHi
    if zLo.size() > 0 and a <= lastHi + 1
        if score > zSc.last()
            int k = zLo.size() - 1
            zLo.set(k, lo)
            zHi.set(k, hi)
            zSc.set(k, score)
            newLast := b
    else
        zLo.push(lo)
        zHi.push(hi)
        zSc.push(score)
        newLast := b
    newLast

// High volume nodes: local peaks >= minPct of the POC. Score = peak / POC.
findHVN(Profile p, float minPct, float zonePct) =>
    s = smooth(p.tot)
    int kw = smoothK(p.rows)
    int n = s.size()
    float mx = s.max()
    zLo = array.new<float>()
    zHi = array.new<float>()
    zSc = array.new<float>()
    if mx > 0
        int lastHi = -1
        for i = 0 to n - 1
            float v = s.get(i)
            float prev = -1.0
            float nxt = -1.0
            if i > 0
                prev := s.get(i - 1)
            if i < n - 1
                nxt := s.get(i + 1)
            if i > lastHi and v >= prev and v > nxt and v >= mx * minPct / 100
                float thr = v * zonePct / 100
                int a = i
                while a > 0 and i - a < 2 * kw and s.get(a - 1) >= thr
                    a -= 1
                int b = i
                while b < n - 1 and b - i < 2 * kw and s.get(b + 1) >= thr
                    b += 1
                lastHi := addZone(p, zLo, zHi, zSc, a, b, i, v / mx, lastHi)
    [zLo, zHi, zSc]

// Low volume nodes: troughs between two real volume peaks. Score = depth of the dip.
findLVN(Profile p, float minDepth) =>
    s = smooth(p.tot)
    int kw = smoothK(p.rows)
    int n = s.size()
    float mx = s.max()
    zLo = array.new<float>()
    zHi = array.new<float>()
    zSc = array.new<float>()
    if mx > 0 and n >= 5
        pre = array.new<float>(n, 0.0)
        suf = array.new<float>(n, 0.0)
        float run = 0.0
        for i = 0 to n - 1
            run := math.max(run, s.get(i))
            pre.set(i, run)
        run := 0.0
        for i = n - 1 to 0
            run := math.max(run, s.get(i))
            suf.set(i, run)
        int lastHi = -1
        for i = 1 to n - 2
            float v = s.get(i)
            if i > lastHi and v <= s.get(i - 1) and v < s.get(i + 1)
                float prom = math.min(pre.get(i - 1), suf.get(i + 1))
                if prom > 0 and prom >= mx * 0.2
                    float depth = 1 - v / prom
                    if depth * 100 >= minDepth
                        float thr = v + (prom - v) * 0.3
                        int a = i
                        while a > 0 and i - a < kw and s.get(a - 1) <= thr
                            a -= 1
                        int b = i
                        while b < n - 1 and b - i < kw and s.get(b + 1) <= thr
                            b += 1
                        lastHi := addZone(p, zLo, zHi, zSc, a, b, i, depth, lastHi)
    [zLo, zHi, zSc]

gradeOf(float sc, float tAp, float tA) =>
    sc >= tAp ? "A+" : sc >= tA ? "A" : "B"

gradeRank(string g) =>
    g == "A+" ? 3 : g == "A" ? 2 : 1

// ─────────────────────────────────────────────────────────────────────────────
// Drawing helpers
// ─────────────────────────────────────────────────────────────────────────────
clearTmp() =>
    while tmpBoxes.size() > 0
        tmpBoxes.pop().delete()
    while tmpLines.size() > 0
        tmpLines.pop().delete()
    while tmpLabels.size() > 0
        tmpLabels.pop().delete()
    tagY.clear()
    tagTxt.clear()
    tagCol.clear()
    tagPri.clear()
    true

// Session profile. Value-area rows: buyers | sellers side by side (Split) or the winning side's color.
// POC row emphasized. Rows outside the value area: faint outline only.
drawSession(Profile p, int x1, int maxLen, array<box> store, int transp) =>
    float mx = p.tot.max()
    int cnt = 0
    if mx > 0
        for r = 0 to p.rows - 1
            float t = p.tot.get(r)
            if t > 0
                bool inVA = r >= p.valRow and r <= p.vahRow
                float bv = p.buy.get(r)
                float sv = p.sell.get(r)
                bool buyDom = bv >= sv
                float top = rowTop(p, r)
                float bot = rowBot(p, r)
                int len = math.max(1, math.round(t / mx * maxLen))
                int xEnd = math.min(bar_index, x1 + len)
                if inVA
                    bool isPoc = r == p.poc
                    int tt = isPoc ? math.max(0, transp - 30) : transp
                    int bw = isPoc ? 1 : 0
                    if splitRows
                        int xb = math.min(xEnd, x1 + math.round(bv / mx * maxLen))
                        color cb = color.new(colBuy, tt)
                        color cs = color.new(colSell, tt)
                        if xb > x1
                            store.push(box.new(x1, top, xb, bot, border_color = isPoc ? cPocLine : cb, border_width = bw, bgcolor = cb))
                            cnt += 1
                        if xEnd > xb
                            store.push(box.new(xb, top, xEnd, bot, border_color = isPoc ? cPocLine : cs, border_width = bw, bgcolor = cs))
                            cnt += 1
                    else
                        color fc = color.new(buyDom ? colBuy : colSell, tt)
                        store.push(box.new(x1, top, xEnd, bot, border_color = isPoc ? cPocLine : fc, border_width = bw, bgcolor = fc))
                        cnt += 1
                else
                    color oc = color.new(buyDom ? colBuyDim : colSellDim, transp)
                    store.push(box.new(x1, top, xEnd, bot, border_color = oc, border_width = 1, bgcolor = color.new(oc, 100)))
                    cnt += 1
    cnt

lineStyle(string st) =>
    st == "Solid" ? line.style_solid : st == "Dashed" ? line.style_dashed : line.style_dotted

// VAH / POC / VAL lines, from the profile start to the current bar
drawLevels(Profile p, int x1) =>
    float vahP = vahPrice(p)
    float valP = valPrice(p)
    float pocP = rowMid(p, p.poc)
    tmpLines.push(line.new(xClamp(x1), vahP, bar_index, vahP, color = cVahLine, style = lineStyle(vahStyle)))
    tmpLines.push(line.new(xClamp(x1), valP, bar_index, valP, color = cValLine, style = lineStyle(valStyle)))
    tmpLines.push(line.new(xClamp(x1), pocP, bar_index, pocP, color = cPocLine, width = pocWidth))
    true

// Add graded HVN / LVN zones (strongest first) to the zone list
collectNodes(array<float> zLo, array<float> zHi, array<float> zSc, float tAp, float tA, int x1, string kind, int maxN, array<Zone> zones) =>
    int n = zLo.size()
    if n > 0
        idx = zSc.sort_indices(order.descending)
        int added = 0
        for k = 0 to n - 1
            int i = idx.get(k)
            string g = gradeOf(zSc.get(i), tAp, tA)
            int rk = gradeRank(g)
            if rk >= minRank and added < maxN
                zones.push(Zone.new(zHi.get(i), zLo.get(i), x1, kind, kind, g, rk, "", true, false))
                added += 1
    true

zoneText(Zone z) =>
    z.kind == "MTF" ? z.tag + z.extra + "  " + z.grade : z.kind + " " + z.grade

// Queue a right-edge tag; tags are merged and drawn together by flushTags()
edgeTag(float y, string txt, color col, int pri) =>
    tagY.push(y)
    tagTxt.push(txt)
    tagCol.push(col)
    tagPri.push(pri)
    true

// Draw queued tags. Tags within `gap` of each other become one label, highest priority first.
flushTags(float gap) =>
    int n = tagY.size()
    if n > 0
        idx = tagY.sort_indices(order.ascending)
        int k = 0
        while k < n
            float y0 = tagY.get(idx.get(k))
            members = array.new<int>()
            pris = array.new<int>()
            int j = k
            while j < n and tagY.get(idx.get(j)) - y0 <= gap
                int ij = idx.get(j)
                members.push(ij)
                pris.push(tagPri.get(ij))
                j += 1
            k := j
            ordm = pris.sort_indices(order.descending)
            int best = members.get(ordm.get(0))
            texts = array.new<string>()
            tips = array.new<string>()
            for q = 0 to members.size() - 1
                int mi = members.get(ordm.get(q))
                texts.push(tagTxt.get(mi))
                tips.push(tagTxt.get(mi) + "  " + str.tostring(tagY.get(mi), format.mintick))
            tmpLabels.push(label.new(bar_index, tagY.get(best), texts.join(" · "), style = label.style_label_left, color = color.new(#000000, 100), textcolor = tagCol.get(best), size = size.tiny, text_font_family = font.family_monospace, tooltip = tips.join("\n")))
    true

// Extra transparency for zones that started long ago (0 when age fading is off)
ageAdd(int x1, float ageSpan) =>
    fadeOld ? int(math.round(math.min(1.0, math.max(0, bar_index - x1) / ageSpan) * ageFadeMax)) : 0

fadeT(int t, bool focus, int age) =>
    math.min(95, t + (focus ? 0 : focusFade) + age)

// Draw one zone (box up to the current bar) and queue its tag
drawZone(Zone z, float ageSpan) =>
    bool isMtf = z.kind == "MTF"
    int w = z.weight
    int age = ageAdd(z.x1, ageSpan)
    int fillT = isMtf ? (w == 3 ? 55 : w == 2 ? 70 : 88) : z.kind == "HVN" ? 70 : 85
    int borderT = isMtf ? (w == 3 ? 0 : w == 2 ? 40 : 70) : 30
    int textT = w == 3 ? 0 : w == 2 ? 30 : 55
    int bw = isMtf and w == 3 ? 2 : 1
    string bs = isMtf ? (w == 1 ? line.style_dotted : line.style_solid) : z.kind == "LVN" ? line.style_dashed : line.style_solid
    color base = isMtf ? colMtf : colZone
    color txtBase = isMtf ? colText : nodeLblCustom ? (z.kind == "HVN" ? cHvnLbl : cLvnLbl) : colZone
    tmpBoxes.push(box.new(xClamp(z.x1), z.top, bar_index, z.bot, border_color = color.new(base, fadeT(borderT, z.focus, age)), border_width = bw, border_style = bs, bgcolor = color.new(base, fadeT(fillT, z.focus, age))))
    edgeTag((z.top + z.bot) / 2, zoneText(z), color.new(txtBase, fadeT(textT, z.focus, age)), isMtf ? 3 : 2)
    true

// ─────────────────────────────────────────────────────────────────────────────
// Session profiles + carried-forward POCs
// ─────────────────────────────────────────────────────────────────────────────
var array<box>   sesBoxes  = array.new<box>()
var array<int>   sesCounts = array.new<int>()
var array<line>  pocLines  = array.new<line>()
var array<float> pocPrices = array.new<float>()
var array<bool>  pocActive = array.new<bool>()
var int sesStart = na
var bool sesActive = false
var int lastSesStart = na
var int lastSesLen = na
var Profile lastSesP = na
var float sesOpen = na

// Session boundaries: ETH = every new period; RTH = New York regular hours of each day
bool isRth  = sesMode == "RTH"
bool inSes  = isRth ? not na(time(timeframe.period, rthSess, "America/New_York")) : true
bool newDay = timeframe.change("D")
bool tfChg  = timeframe.change(sesTf)
bool sesEnd   = isRth ? (inSes[1] and not inSes) or (inSes and inSes[1] and newDay) : tfChg
bool sesBegin = isRth ? inSes and (not inSes[1] or newDay) : tfChg or na(sesStart)

bool needLastSes = (showHvn or showLvn) and nodeSrc == "Last Session"
if sesEnd and sesActive and bar_index - 1 >= sesStart and (showSes or needLastSes or showPd or showPanel)
    p = buildProfile(posOf(sesStart), posOf(bar_index - 1), sesRows, vaPct)
    lastSesP := p
    lastSesStart := sesStart
    lastSesLen := bar_index - sesStart
    if showSes and sesMaxEff > 0
        int maxLen = math.max(2, math.round(lastSesLen * sesPastWidthPct / 100))
        sesCounts.push(drawSession(p, sesStart, maxLen, sesBoxes, pastTransp))
        while sesCounts.size() > sesMaxEff
            int n = sesCounts.shift()
            if n > 0
                for k = 1 to n
                    sesBoxes.shift().delete()
    if showPocCarry
        float pocP = rowMid(p, p.poc)
        pocLines.push(line.new(sesStart, pocP, bar_index, pocP, color = cPocCarry, width = pocCarryWidth))
        pocPrices.push(pocP)
        pocActive.push(true)
        while pocLines.size() > pocMax
            pocLines.shift().delete()
            pocPrices.shift()
            pocActive.shift()
        // Older carried POCs a step fainter than newer ones
        int np = pocLines.size()
        float baseT = color.t(cPocCarry)
        for i = 0 to np - 1
            float tt = fadeOld ? math.min(95, baseT + (np - 1 - i) * ageFadeMax / math.max(1, pocMax - 1)) : baseT
            pocLines.get(i).set_color(color.new(cPocCarry, tt))
if sesEnd
    sesActive := false
if sesBegin
    sesStart := bar_index
    sesActive := true
    sesOpen := open

// Extend carried POCs; in "Until touched" mode stop once price trades through.
// Optionally they end at the bar before the current session starts.
int pocEnd = pocStopAtSes and sesActive ? math.max(sesStart - 1, 0) : bar_index
if pocLines.size() > 0
    for i = 0 to pocLines.size() - 1
        if pocActive.get(i)
            pocLines.get(i).set_x2(pocEnd)
            float pr = pocPrices.get(i)
            if pocMode == "Until touched" and low <= pr and high >= pr
                pocActive.set(i, false)

// ─────────────────────────────────────────────────────────────────────────────
// Developing POC path: incremental volume per price bucket for the current session
// ─────────────────────────────────────────────────────────────────────────────
var map<int, float> dpMap = map.new<int, float>()
var array<chart.point> dpPts = array.new<chart.point>()
var float dpBucket = na
var float dpMax = 0.0
var float dpPrice = na

dpAdd(map<int, float> m, float bucket, float h, float l, float v) =>
    int k0 = math.floor(l / bucket)
    int k1 = math.floor(h / bucket)
    float per = v / (k1 - k0 + 1)
    int bestK = k0
    float bestV = -1.0
    for k = k0 to k1
        float nv = nz(m.get(k)) + per
        m.put(k, nv)
        if nv > bestV
            bestV := nv
            bestK := k
    [bestK, bestV]

if sesBegin
    dpMap.clear()
    dpPts.clear()
    dpMax := 0.0
    dpPrice := na
    float rawB = nz(atrVal, syminfo.mintick * 16) * 0.25
    dpBucket := math.max(syminfo.mintick, math.round(rawB / syminfo.mintick) * syminfo.mintick)

if showDpoc and sesActive and not na(dpBucket) and bar_index > last_bar_index - MAX_BARS_BACK_DRAW
    int bestK = na
    float bestV = -1.0
    if ibN > 0
        int s0 = ibStart - ltfBase
        for j = math.max(0, s0) to s0 + ibN - 1
            [k, v] = dpAdd(dpMap, dpBucket, ltfH.get(j), ltfL.get(j), ltfB.get(j) + ltfS.get(j))
            if v > bestV
                bestV := v
                bestK := k
    else
        [k, v] = dpAdd(dpMap, dpBucket, high, low, nz(volume))
        bestV := v
        bestK := k
    if bestV > dpMax
        dpMax := bestV
        float newP = (bestK + 0.5) * dpBucket
        if na(dpPrice) or newP != dpPrice
            if dpPts.size() < 9000
                if not na(dpPrice)
                    dpPts.push(chart.point.from_index(bar_index, dpPrice))
                dpPts.push(chart.point.from_index(bar_index, newP))
            dpPrice := newP

var polyline dpLine = na

// ─────────────────────────────────────────────────────────────────────────────
// MTF: levels (POC + top HVNs) of the last completed Day / Week / Month
// ─────────────────────────────────────────────────────────────────────────────
tfOk(string tf) =>
    timeframe.in_seconds(tf) > chartSec

mtfCollect(int fromBar, int toBar, array<float> lv, array<bool> isP) =>
    lv.clear()
    isP.clear()
    int a = posOf(fromBar)
    int b = posOf(toBar)
    if b >= a
        p = buildProfile(a, b, mtfRows, vaPct)
        float pocP = rowMid(p, p.poc)
        lv.push(pocP)
        isP.push(true)
        [zLo, zHi, zSc] = findHVN(p, hvnMinPct, 70.0)
        int n = zSc.size()
        if n > 0 and mtfNodesPerTf > 0
            idx = zSc.sort_indices(order.descending)
            int added = 0
            for k = 0 to n - 1
                int i = idx.get(k)
                float mid = (zLo.get(i) + zHi.get(i)) / 2
                if added < mtfNodesPerTf and math.abs(mid - pocP) > p.step * 1.5
                    lv.push(mid)
                    isP.push(false)
                    added += 1
    true

// x = bar where the zone starts drawing (end of the source period, or start of a developing one)
appendLv(array<float> lv, array<bool> isP, int tf, int x, array<float> allP, array<int> allT, array<bool> allPoc, array<int> allX) =>
    if lv.size() > 0
        for i = 0 to lv.size() - 1
            allP.push(lv.get(i))
            allT.push(tf)
            allPoc.push(isP.get(i))
            allX.push(x)
    true

var array<float> dLv = array.new<float>()
var array<bool>  dPoc = array.new<bool>()
var array<float> wLv = array.new<float>()
var array<bool>  wPoc = array.new<bool>()
var array<float> mLv = array.new<float>()
var array<bool>  mPoc = array.new<bool>()
var array<float> wDevLv = array.new<float>()
var array<bool>  wDevPoc = array.new<bool>()
var array<float> mDevLv = array.new<float>()
var array<bool>  mDevPoc = array.new<bool>()
var int dStart = na
var int wStart = na
var int mStart = na
var bool dValid = false
var bool wValid = false
var bool mValid = false
var int dFin = na
var int wFin = na
var int mFin = na

newW = timeframe.change("W")
newM = timeframe.change("M")

// A period only counts once we have seen its true start (skips the partial first one)
if newDay and not na(dStart) and dValid and showMtf and mtfUseD and tfOk("D")
    mtfCollect(dStart, bar_index - 1, dLv, dPoc)
    dFin := bar_index
if newDay or na(dStart)
    dValid := not na(dStart)
    dStart := bar_index

if newW and not na(wStart) and wValid and showMtf and mtfUseW and tfOk("W")
    mtfCollect(wStart, bar_index - 1, wLv, wPoc)
    wFin := bar_index
if newW or na(wStart)
    wValid := not na(wStart)
    wStart := bar_index

if newM and not na(mStart) and mValid and showMtf and mtfUseM and tfOk("M")
    mtfCollect(mStart, bar_index - 1, mLv, mPoc)
    mFin := bar_index
if newM or na(mStart)
    mValid := not na(mStart)
    mStart := bar_index

// Developing week / month levels: rebuilt once per closed bar near the end of the chart, not on every tick
if showMtf and mtfUseDev and barstate.isconfirmed and bar_index >= last_bar_index - 1
    if mtfUseW and tfOk("W")
        mtfCollect(wStart, bar_index, wDevLv, wDevPoc)
    if mtfUseM and tfOk("M")
        mtfCollect(mStart, bar_index, mDevLv, mDevPoc)

panelPosConst = panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : panelPos == "Bottom Left" ? position.bottom_left : position.top_right
panelSizeConst = panelSize == "Tiny" ? size.tiny : panelSize == "Normal" ? size.normal : size.small
var table panel = table.new(panelPosConst, 2, 5, bgcolor = color.new(colText, 92), frame_color = color.new(colText, 70), frame_width = 1, border_width = 0)

panelRow(int r, string name, string val, color valCol) =>
    table.cell(panel, 0, r, name, text_color = color.new(colText, 25), text_size = panelSizeConst, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(panel, 1, r, val, text_color = valCol, text_size = panelSizeConst, text_halign = text.align_left, text_font_family = font.family_monospace)
    true

// ─────────────────────────────────────────────────────────────────────────────
// Last bar: developing session, levels, zones (collect -> merge -> focus -> draw), tags, panel
// ─────────────────────────────────────────────────────────────────────────────
if barstate.islast
    clearTmp()

    // Developing session profile
    Profile devP = na
    bool needDev = (showSes and sesShowDev) or ((showHvn or showLvn) and nodeSrc == "Developing Session") or showPanel
    if needDev and sesActive
        devP := buildProfile(posOf(sesStart), posOf(bar_index), sesRows, vaPct)
        if showSes and sesShowDev
            int barsRef = na(lastSesLen) ? bar_index - sesStart + 1 : lastSesLen
            drawSession(devP, sesStart, math.max(2, math.round(barsRef * sesCurWidthPct / 100)), tmpBoxes, profTransp)
            drawLevels(devP, sesStart)

    // Developing POC path
    if not na(dpLine)
        dpLine.delete()
    if showDpoc and sesActive and dpPts.size() > 0 and sesStart > bar_index - MAX_BARS_BACK_DRAW
        pts = dpPts.copy()
        pts.push(chart.point.from_index(bar_index, dpPrice))
        dpLine := polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_index, line_color = cDpoc, line_width = dpocWidth)

    // Prior-day value area, dashed, across the current session
    if showPd and not na(lastSesP)
        int px1 = xClamp(lastSesStart + lastSesLen)
        float pdH = vahPrice(lastSesP)
        float pdL = valPrice(lastSesP)
        float pdP = rowMid(lastSesP, lastSesP.poc)
        tmpLines.push(line.new(px1, pdH, bar_index, pdH, color = cVahLine, style = line.style_dashed))
        tmpLines.push(line.new(px1, pdL, bar_index, pdL, color = cValLine, style = line.style_dashed))
        tmpLines.push(line.new(px1, pdP, bar_index, pdP, color = cPocCarry, width = pocCarryWidth, style = line.style_dashed))
        if pdLabels
            edgeTag(pdH, "pVAH", colText, 1)
            edgeTag(pdP, "pPOC", pdPocLblCustom ? cPdPocLbl : colText, 1)
            edgeTag(pdL, "pVAL", colText, 1)

    zones = array.new<Zone>()

    // HVN / LVN zones
    if showHvn or showLvn
        Profile src = nodeSrc == "Last Session" ? lastSesP : devP
        int sx = nodeSrc == "Last Session" ? lastSesStart : sesStart
        if not na(src) and not na(sx)
            if showHvn
                [hLo, hHi, hSc] = findHVN(src, hvnMinPct, 70.0)
                collectNodes(hLo, hHi, hSc, 0.8, 0.6, sx, "HVN", nodeMax, zones)
            if showLvn
                [lLo, lHi, lSc] = findLVN(src, lvnMinDepth)
                collectNodes(lLo, lHi, lSc, 0.85, 0.7, sx, "LVN", nodeMax, zones)

    // MTF confluence: cluster D / W / M levels that sit within the tolerance.
    // Weight = number of timeframes in the cluster: 3 = A+, 2 = A, 1 = B.
    if showMtf
        float tol = math.max(nz(atrVal) * mtfTolMult, syminfo.mintick * 4)
        allP = array.new<float>()
        allT = array.new<int>()
        allPoc = array.new<bool>()
        allX = array.new<int>()
        if mtfUseD and tfOk("D")
            appendLv(dLv, dPoc, 0, nz(dFin), allP, allT, allPoc, allX)
        if mtfUseW and tfOk("W")
            appendLv(wLv, wPoc, 1, nz(wFin), allP, allT, allPoc, allX)
            if mtfUseDev
                appendLv(wDevLv, wDevPoc, 1, nz(wStart), allP, allT, allPoc, allX)
        if mtfUseM and tfOk("M")
            appendLv(mLv, mPoc, 2, nz(mFin), allP, allT, allPoc, allX)
            if mtfUseDev
                appendLv(mDevLv, mDevPoc, 2, nz(mStart), allP, allT, allPoc, allX)

        mtfZones = array.new<Zone>()
        cScore = array.new<float>()
        int n = allP.size()
        if n > 0
            idx = allP.sort_indices(order.ascending)
            float pad = math.max(tol * 0.1, syminfo.mintick * 2)
            int k = 0
            while k < n
                float lo = allP.get(idx.get(k))
                float hi = lo
                bool hD = false
                bool hW = false
                bool hM = false
                bool hP = false
                int x1 = 0
                int j = k
                while j < n and allP.get(idx.get(j)) - lo <= tol
                    int ii = idx.get(j)
                    hi := allP.get(ii)
                    int tf = allT.get(ii)
                    hD := hD or tf == 0
                    hW := hW or tf == 1
                    hM := hM or tf == 2
                    hP := hP or allPoc.get(ii)
                    x1 := math.max(x1, allX.get(ii))
                    j += 1
                k := j
                int cnt = (hD ? 1 : 0) + (hW ? 1 : 0) + (hM ? 1 : 0)
                if cnt >= mtfMinTf
                    tags = array.new<string>()
                    if hM
                        tags.push("M")
                    if hW
                        tags.push("W")
                    if hD
                        tags.push("D")
                    string g = cnt == 3 ? "A+" : cnt == 2 ? "A" : "B"
                    // POC and nearness to price only break ties within the same timeframe count
                    float dist = math.abs((lo + hi) / 2 - close)
                    mtfZones.push(Zone.new(hi + pad, lo - pad, x1, "MTF", tags.join(" "), g, cnt, "", true, false))
                    cScore.push(cnt * 10 + (hP ? 5 : 0) - math.min(4.0, dist / (tol * 5)))
        if mtfZones.size() > 0
            ord = cScore.sort_indices(order.descending)
            for q = 0 to math.min(mtfZones.size(), mtfMax) - 1
                zones.push(mtfZones.get(ord.get(q)))

    int nZones = zones.size()
    int nearUp = -1
    int nearDn = -1
    int inI = -1
    if nZones > 0
        // Merge: an HVN / LVN inside an MTF zone is folded into that zone's tag
        for i = 0 to nZones - 1
            Zone a = zones.get(i)
            if a.kind != "MTF"
                for j = 0 to nZones - 1
                    Zone m = zones.get(j)
                    if a.alive and m.kind == "MTF" and a.bot <= m.top and a.top >= m.bot
                        if not str.contains(m.extra, a.kind)
                            m.extra := m.extra + " + " + a.kind
                        a.alive := false

        // Focus: nearest zones above and below price stay strong, the rest fade
        aboveI = array.new<int>()
        aboveD = array.new<float>()
        belowI = array.new<int>()
        belowD = array.new<float>()
        for i = 0 to nZones - 1
            Zone z = zones.get(i)
            if z.alive
                if close >= z.bot and close <= z.top
                    z.focus := true
                    inI := i
                else if z.bot > close
                    aboveI.push(i)
                    aboveD.push(z.bot - close)
                else
                    belowI.push(i)
                    belowD.push(close - z.top)
                if not focusOn
                    z.focus := true
        if aboveI.size() > 0
            oa = aboveD.sort_indices(order.ascending)
            nearUp := aboveI.get(oa.get(0))
            for q = 0 to math.min(aboveI.size(), focusCount) - 1
                Zone za = zones.get(aboveI.get(oa.get(q)))
                za.focus := true
        if belowI.size() > 0
            ob = belowD.sort_indices(order.ascending)
            nearDn := belowI.get(ob.get(0))
            for q = 0 to math.min(belowI.size(), focusCount) - 1
                Zone zb = zones.get(belowI.get(ob.get(q)))
                zb.focus := true

        // Age reference: about five sessions
        float ageSpan = math.max(1.0, nz(lastSesLen, math.round(86400 / chartSec)) * 5.0)
        for i = 0 to nZones - 1
            Zone z = zones.get(i)
            if z.alive
                drawZone(z, ageSpan)

    // Right-edge tags, merged where they would overlap
    flushTags(nz(atrVal) * tagGapMult)

    // Status panel
    if showPanel
        bool haveDev = sesActive and not na(devP)
        Profile vaRef = haveDev ? devP : lastSesP
        string priceTxt = "—"
        if not na(vaRef)
            priceTxt := close > vahPrice(vaRef) ? "Above VAH" : close < valPrice(vaRef) ? "Below VAL" : "Inside VA"
            if not haveDev
                priceTxt := priceTxt + " (prior)"
        if inI >= 0
            priceTxt := priceTxt + " · in " + zoneText(zones.get(inI))

        string openTxt = "—"
        if sesActive and not na(lastSesP) and not na(sesOpen)
            openTxt := sesOpen > vahPrice(lastSesP) ? "Above prior VA" : sesOpen < valPrice(lastSesP) ? "Below prior VA" : "Inside prior VA"

        string upTxt = "—"
        if nearUp >= 0
            Zone zu = zones.get(nearUp)
            upTxt := zoneText(zu) + "  +" + str.tostring(zu.bot - close, format.mintick)
        string dnTxt = "—"
        if nearDn >= 0
            Zone zd = zones.get(nearDn)
            dnTxt := zoneText(zd) + "  -" + str.tostring(close - zd.top, format.mintick)

        string sesTxt = "—"
        color sesCol = colText
        if haveDev and devP.totBuy + devP.totSell > 0
            float bPct = devP.totBuy / (devP.totBuy + devP.totSell) * 100
            sesTxt := bPct >= 50 ? str.tostring(bPct, "#") + "% buyers" : str.tostring(100 - bPct, "#") + "% sellers"
            sesCol := bPct >= 50 ? colBuy : colSell

        panelRow(0, "Price", priceTxt, colText)
        panelRow(1, "Open", openTxt, colText)
        panelRow(2, "Next ↑", upTxt, colText)
        panelRow(3, "Next ↓", dnTxt, colText)
        panelRow(4, "Session", sesTxt, sesCol)

plot(na, "hidden", display = display.none, editable = false)
````
