# Volatility Vault - EMA Tap Scanner

- url: https://www.tradingview.com/script/ejjXqMNM-Volatility-Vault-EMA-Tap-Scanner/
- type: indicator
- pine_id: PUB;33105a4c5d7d4d49971ddfbe97efbdbd
- version: 1.0

## Description

Volatility Vault — EMA Tap Scanner
A multi-timeframe EMA scanner that silently monitors the 9, 21, 50, 100, and 200 EMAs across up to 21 timeframes (from 1-second to weekly) and surfaces only the levels price is actively approaching or touching.
What it does:
Instead of plotting dozens of EMA lines on your chart, it displays a dynamic table that stays quiet until price comes within range of an EMA on any tracked timeframe. When a level activates, that timeframe's row appears automatically — green for price tapping from above (potential support), red for tapping from below (potential resistance), orange for approaching. Each cell shows the EMA price so you know the exact level.
Why it's useful:
Every EMA on every timeframe is a potential reaction level. A 4H 50 EMA, a 15m 200 EMA, and a 1m 9 EMA all matter depending on what you're trading — but you can't watch them all at once. This scanner does the watching for you and only interrupts when something's actionable.
Key features:

Scans 21 timeframes including sub-minute (1s, 5s, 15s, 30s, 45s), all standard minute intervals (1m through 45m), hours (1H–4H), daily, and weekly
Core timeframes (5m, 15m, 1H, 4H, 1D) are pinned to the top when active and highlighted in aqua so HTF structure is always visible first
Non-core timeframes are ranked by tightest proximity — only the closest levels display
Configurable TAP and NEAR thresholds to match the volatility of whatever you're trading
Single consolidated alert fires whenever any EMA on any enabled timeframe gets tapped
Row cap keeps the table compact even when many levels are in play

Use case:
Built for traders who want to enter on EMA reactions across any timeframe without cluttering the chart or missing confluence between timeframes. When multiple rows activate on the same EMA value, you're looking at a high-probability reaction zone.

## Source Code

````pine
//@version=6
indicator("Volatility Vault - EMA Tap Scanner", overlay=true, max_lines_count=500)

// ============================================================================
// INPUTS
// ============================================================================
grpDisplay = "Display"
tablePos   = input.string("Top Right", "Table Position",
             options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"],
             group=grpDisplay)
tableSize  = input.string("Normal", "Table Size",
             options=["Tiny","Small","Normal","Large"], group=grpDisplay)
maxRows    = input.int(8, "Max Rows to Display", minval=2, maxval=20,
             tooltip="Cap how many TF rows show at once. Core TFs with signals are prioritized, then tightest taps by distance.",
             group=grpDisplay)
pinCoreTFs = input.bool(true, "Pin Core TFs (5m/15m/1H/4H/1D) at top when active",
             group=grpDisplay)

grpLogic = "Detection"
tapPct  = input.float(0.10, "TAP Proximity %", minval=0.01, step=0.05,
          tooltip="Price within this % of EMA = TAP",
          group=grpLogic)
nearPct = input.float(0.30, "NEAR Proximity %", minval=0.01, step=0.05,
          tooltip="Price within this % of EMA = NEAR. Must be larger than TAP %.",
          group=grpLogic)

grpScan = "Timeframes to Scan (silent background)"
scanNote = "Toggle which TFs to include. Seconds TFs require Premium. Unchecked = ignored."

// --- Seconds ---
use_1s  = input.bool(false, "1s",  inline="s1", group=grpScan)
use_5s  = input.bool(false, "5s",  inline="s1", group=grpScan)
use_15s = input.bool(false, "15s", inline="s1", group=grpScan)
use_30s = input.bool(false, "30s", inline="s1", group=grpScan)
use_45s = input.bool(false, "45s", inline="s1", group=grpScan)

// --- Minutes (short) ---
use_1m  = input.bool(true,  "1m",  inline="m1", group=grpScan)
use_2m  = input.bool(true,  "2m",  inline="m1", group=grpScan)
use_3m  = input.bool(true,  "3m",  inline="m1", group=grpScan)
use_5m  = input.bool(true,  "5m",  inline="m1", group=grpScan)

// --- Minutes (mid) ---
use_10m = input.bool(true,  "10m", inline="m2", group=grpScan)
use_15m = input.bool(true,  "15m", inline="m2", group=grpScan)
use_20m = input.bool(true,  "20m", inline="m2", group=grpScan)
use_30m = input.bool(true,  "30m", inline="m2", group=grpScan)
use_45m = input.bool(true,  "45m", inline="m2", group=grpScan)

// --- Hours ---
use_1h  = input.bool(true,  "1H",  inline="h1", group=grpScan)
use_2h  = input.bool(true,  "2H",  inline="h1", group=grpScan)
use_3h  = input.bool(true,  "3H",  inline="h1", group=grpScan)
use_4h  = input.bool(true,  "4H",  inline="h1", group=grpScan)

// --- Higher ---
use_1D  = input.bool(true,  "1D",  inline="d1", group=grpScan)
use_1W  = input.bool(false, "1W",  inline="d1", group=grpScan)

grpColors = "Header Colors"
c9   = input.color(#4A90E2, "9",   group=grpColors)
c21  = input.color(#4A90E2, "21",  group=grpColors)
c50  = input.color(#F5A623, "50",  group=grpColors)
c100 = input.color(#BD10E0, "100", group=grpColors)
c200 = input.color(#E02020, "200", group=grpColors)

// ============================================================================
// MTF FETCH — each TF returns all 5 EMAs
// ============================================================================
getEmas(simple string tf) =>
    request.security(syminfo.tickerid, tf,
         [ta.ema(close, 9), ta.ema(close, 21), ta.ema(close, 50),
          ta.ema(close, 100), ta.ema(close, 200)],
         lookahead=barmerge.lookahead_off)

[e9_1s,  e21_1s,  e50_1s,  e100_1s,  e200_1s ] = getEmas("1S")
[e9_5s,  e21_5s,  e50_5s,  e100_5s,  e200_5s ] = getEmas("5S")
[e9_15s, e21_15s, e50_15s, e100_15s, e200_15s] = getEmas("15S")
[e9_30s, e21_30s, e50_30s, e100_30s, e200_30s] = getEmas("30S")
[e9_45s, e21_45s, e50_45s, e100_45s, e200_45s] = getEmas("45S")

[e9_1m,  e21_1m,  e50_1m,  e100_1m,  e200_1m ] = getEmas("1")
[e9_2m,  e21_2m,  e50_2m,  e100_2m,  e200_2m ] = getEmas("2")
[e9_3m,  e21_3m,  e50_3m,  e100_3m,  e200_3m ] = getEmas("3")
[e9_5m,  e21_5m,  e50_5m,  e100_5m,  e200_5m ] = getEmas("5")
[e9_10m, e21_10m, e50_10m, e100_10m, e200_10m] = getEmas("10")
[e9_15m, e21_15m, e50_15m, e100_15m, e200_15m] = getEmas("15")
[e9_20m, e21_20m, e50_20m, e100_20m, e200_20m] = getEmas("20")
[e9_30m, e21_30m, e50_30m, e100_30m, e200_30m] = getEmas("30")
[e9_45m, e21_45m, e50_45m, e100_45m, e200_45m] = getEmas("45")

[e9_1h,  e21_1h,  e50_1h,  e100_1h,  e200_1h ] = getEmas("60")
[e9_2h,  e21_2h,  e50_2h,  e100_2h,  e200_2h ] = getEmas("120")
[e9_3h,  e21_3h,  e50_3h,  e100_3h,  e200_3h ] = getEmas("180")
[e9_4h,  e21_4h,  e50_4h,  e100_4h,  e200_4h ] = getEmas("240")

[e9_1D,  e21_1D,  e50_1D,  e100_1D,  e200_1D ] = getEmas("D")
[e9_1W,  e21_1W,  e50_1W,  e100_1W,  e200_1W ] = getEmas("W")

// ============================================================================
// HELPERS
// ============================================================================
getPos(string p) =>
    pos = position.top_right
    if p == "Top Left"
        pos := position.top_left
    else if p == "Middle Right"
        pos := position.middle_right
    else if p == "Middle Left"
        pos := position.middle_left
    else if p == "Bottom Right"
        pos := position.bottom_right
    else if p == "Bottom Left"
        pos := position.bottom_left
    pos

getSize(string s) =>
    sz = size.normal
    if s == "Tiny"
        sz := size.tiny
    else if s == "Small"
        sz := size.small
    else if s == "Large"
        sz := size.large
    sz

// 0=FAR, 1=NEAR, 2=TAP
classify(float price, float ema) =>
    state = 0
    if not na(ema) and not na(price) and ema > 0
        d = math.abs(price - ema) / price * 100
        if d <= tapPct
            state := 2
        else if d <= nearPct
            state := 1
    state

cellBg(int state, float price, float ema) =>
    bg = color.new(color.gray, 85)
    if state == 2
        bg := price >= ema ? color.new(color.green, 55) : color.new(color.red, 55)
    else if state == 1
        bg := color.new(color.orange, 55)
    bg

cellTxt(int state, float price, float ema) =>
    txt = color.new(color.gray, 30)
    if state == 2
        txt := price >= ema ? color.new(color.lime, 0) : color.new(color.red, 0)
    else if state == 1
        txt := color.new(color.yellow, 0)
    txt

cellText(int state, float ema) =>
    out = "n/a"
    if not na(ema)
        tag = state == 2 ? "TAP" : state == 1 ? "NEAR" : "—"
        out := tag + "\n" + str.tostring(ema, format.mintick)
    out

// Minimum distance % from price to the closest of 5 EMAs for a TF
// Used for sorting non-core rows when >maxRows are active
minDist(float v9, float v21, float v50, float v100, float v200) =>
    d = 9999.0
    if not na(v9)
        d := math.min(d, math.abs(close - v9)   / close * 100)
    if not na(v21)
        d := math.min(d, math.abs(close - v21)  / close * 100)
    if not na(v50)
        d := math.min(d, math.abs(close - v50)  / close * 100)
    if not na(v100)
        d := math.min(d, math.abs(close - v100) / close * 100)
    if not na(v200)
        d := math.min(d, math.abs(close - v200) / close * 100)
    d

// Row has any signal (NEAR or TAP)?
hasSignal(float v9, float v21, float v50, float v100, float v200) =>
    classify(close, v9)   > 0 or classify(close, v21)  > 0 or
     classify(close, v50)  > 0 or classify(close, v100) > 0 or
     classify(close, v200) > 0

hasTap(float v9, float v21, float v50, float v100, float v200) =>
    classify(close, v9)   == 2 or classify(close, v21)  == 2 or
     classify(close, v50)  == 2 or classify(close, v100) == 2 or
     classify(close, v200) == 2

// ============================================================================
// BUILD CANDIDATE LIST: parallel arrays of TFs with signals
// ============================================================================
var array<string> tfLabels  = array.new<string>()
var array<float>  tfE9s     = array.new<float>()
var array<float>  tfE21s    = array.new<float>()
var array<float>  tfE50s    = array.new<float>()
var array<float>  tfE100s   = array.new<float>()
var array<float>  tfE200s   = array.new<float>()
var array<float>  tfMinDist = array.new<float>()
var array<bool>   tfIsCore  = array.new<bool>()

array.clear(tfLabels)
array.clear(tfE9s)
array.clear(tfE21s)
array.clear(tfE50s)
array.clear(tfE100s)
array.clear(tfE200s)
array.clear(tfMinDist)
array.clear(tfIsCore)

addCandidate(bool use, string label, bool core, float v9, float v21, float v50, float v100, float v200) =>
    if use and hasSignal(v9, v21, v50, v100, v200)
        array.push(tfLabels,  label)
        array.push(tfE9s,     v9)
        array.push(tfE21s,    v21)
        array.push(tfE50s,    v50)
        array.push(tfE100s,   v100)
        array.push(tfE200s,   v200)
        array.push(tfMinDist, minDist(v9, v21, v50, v100, v200))
        array.push(tfIsCore,  core)

// Core TFs (marked core=true) get priority when pinning is on
addCandidate(use_1s,  "1s",  false, e9_1s,  e21_1s,  e50_1s,  e100_1s,  e200_1s)
addCandidate(use_5s,  "5s",  false, e9_5s,  e21_5s,  e50_5s,  e100_5s,  e200_5s)
addCandidate(use_15s, "15s", false, e9_15s, e21_15s, e50_15s, e100_15s, e200_15s)
addCandidate(use_30s, "30s", false, e9_30s, e21_30s, e50_30s, e100_30s, e200_30s)
addCandidate(use_45s, "45s", false, e9_45s, e21_45s, e50_45s, e100_45s, e200_45s)

addCandidate(use_1m,  "1m",  false, e9_1m,  e21_1m,  e50_1m,  e100_1m,  e200_1m)
addCandidate(use_2m,  "2m",  false, e9_2m,  e21_2m,  e50_2m,  e100_2m,  e200_2m)
addCandidate(use_3m,  "3m",  false, e9_3m,  e21_3m,  e50_3m,  e100_3m,  e200_3m)
addCandidate(use_5m,  "5m",  true,  e9_5m,  e21_5m,  e50_5m,  e100_5m,  e200_5m)
addCandidate(use_10m, "10m", false, e9_10m, e21_10m, e50_10m, e100_10m, e200_10m)
addCandidate(use_15m, "15m", true,  e9_15m, e21_15m, e50_15m, e100_15m, e200_15m)
addCandidate(use_20m, "20m", false, e9_20m, e21_20m, e50_20m, e100_20m, e200_20m)
addCandidate(use_30m, "30m", false, e9_30m, e21_30m, e50_30m, e100_30m, e200_30m)
addCandidate(use_45m, "45m", false, e9_45m, e21_45m, e50_45m, e100_45m, e200_45m)

addCandidate(use_1h,  "1H",  true,  e9_1h,  e21_1h,  e50_1h,  e100_1h,  e200_1h)
addCandidate(use_2h,  "2H",  false, e9_2h,  e21_2h,  e50_2h,  e100_2h,  e200_2h)
addCandidate(use_3h,  "3H",  false, e9_3h,  e21_3h,  e50_3h,  e100_3h,  e200_3h)
addCandidate(use_4h,  "4H",  true,  e9_4h,  e21_4h,  e50_4h,  e100_4h,  e200_4h)

addCandidate(use_1D,  "1D",  true,  e9_1D,  e21_1D,  e50_1D,  e100_1D,  e200_1D)
addCandidate(use_1W,  "1W",  false, e9_1W,  e21_1W,  e50_1W,  e100_1W,  e200_1W)

// ============================================================================
// SORT: core-pinned first (if enabled), then by tightest minDist
// Simple selection-sort because size is small
// ============================================================================
n = array.size(tfLabels)

swapAll(int a, int b) =>
    tl_a = array.get(tfLabels,  a), tl_b = array.get(tfLabels,  b)
    e9a  = array.get(tfE9s,     a), e9b  = array.get(tfE9s,     b)
    e21a = array.get(tfE21s,    a), e21b = array.get(tfE21s,    b)
    e50a = array.get(tfE50s,    a), e50b = array.get(tfE50s,    b)
    e100a= array.get(tfE100s,   a), e100b= array.get(tfE100s,   b)
    e200a= array.get(tfE200s,   a), e200b= array.get(tfE200s,   b)
    mda  = array.get(tfMinDist, a), mdb  = array.get(tfMinDist, b)
    ica  = array.get(tfIsCore,  a), icb  = array.get(tfIsCore,  b)
    array.set(tfLabels,  a, tl_b), array.set(tfLabels,  b, tl_a)
    array.set(tfE9s,     a, e9b),  array.set(tfE9s,     b, e9a)
    array.set(tfE21s,    a, e21b), array.set(tfE21s,    b, e21a)
    array.set(tfE50s,    a, e50b), array.set(tfE50s,    b, e50a)
    array.set(tfE100s,   a, e100b),array.set(tfE100s,   b, e100a)
    array.set(tfE200s,   a, e200b),array.set(tfE200s,   b, e200a)
    array.set(tfMinDist, a, mdb),  array.set(tfMinDist, b, mda)
    array.set(tfIsCore,  a, icb),  array.set(tfIsCore,  b, ica)

// Scoring: lower = higher priority.
// If pinning, core TFs get score = minDist, non-core get score = minDist + 1000.
// If not pinning, score = minDist only.
score(int i) =>
    md   = array.get(tfMinDist, i)
    core = array.get(tfIsCore,  i)
    s = md
    if pinCoreTFs and not core
        s := md + 1000.0
    s

if n > 1
    for i = 0 to n - 2
        minI = i
        for j = i + 1 to n - 1
            if score(j) < score(minI)
                minI := j
        if minI != i
            swapAll(i, minI)

// ============================================================================
// RENDER TABLE
// ============================================================================
var table t = table.new(position.top_right, 6, 25, border_width=1, frame_width=1,
     frame_color=color.new(color.gray, 50))

if barstate.islast
    table.clear(t, 0, 0, 5, 24)
    sz = getSize(tableSize)
    table.set_position(t, getPos(tablePos))

    // Title
    table.cell(t, 0, 0, "EMA TAP SCANNER",
         bgcolor=color.new(color.black, 0), text_color=color.red, text_size=sz)
    table.merge_cells(t, 0, 0, 5, 0)

    // Header
    headerBg = color.new(color.black, 30)
    table.cell(t, 0, 1, "TF",  bgcolor=headerBg, text_color=color.white, text_size=sz)
    table.cell(t, 1, 1, "9",   bgcolor=headerBg, text_color=c9,   text_size=sz)
    table.cell(t, 2, 1, "21",  bgcolor=headerBg, text_color=c21,  text_size=sz)
    table.cell(t, 3, 1, "50",  bgcolor=headerBg, text_color=c50,  text_size=sz)
    table.cell(t, 4, 1, "100", bgcolor=headerBg, text_color=c100, text_size=sz)
    table.cell(t, 5, 1, "200", bgcolor=headerBg, text_color=c200, text_size=sz)

    if n == 0
        table.cell(t, 0, 2, "Quiet",
             bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=sz)
        table.merge_cells(t, 0, 2, 5, 2)
    else
        rowsToShow = math.min(n, maxRows)
        for i = 0 to rowsToShow - 1
            label = array.get(tfLabels, i)
            v9    = array.get(tfE9s,    i)
            v21   = array.get(tfE21s,   i)
            v50   = array.get(tfE50s,   i)
            v100  = array.get(tfE100s,  i)
            v200  = array.get(tfE200s,  i)
            core  = array.get(tfIsCore, i)
            s9    = classify(close, v9)
            s21   = classify(close, v21)
            s50   = classify(close, v50)
            s100  = classify(close, v100)
            s200  = classify(close, v200)
            rowIdx = i + 2

            // Core TFs get slightly brighter TF label
            tfBg   = core ? color.new(color.navy, 40) : color.new(color.black, 40)
            tfText = core ? color.new(color.aqua, 0)  : color.white

            table.cell(t, 0, rowIdx, label,
                 bgcolor=tfBg, text_color=tfText, text_size=sz)
            table.cell(t, 1, rowIdx, cellText(s9,   v9),
                 bgcolor=cellBg(s9,   close, v9),   text_color=cellTxt(s9,   close, v9),   text_size=sz)
            table.cell(t, 2, rowIdx, cellText(s21,  v21),
                 bgcolor=cellBg(s21,  close, v21),  text_color=cellTxt(s21,  close, v21),  text_size=sz)
            table.cell(t, 3, rowIdx, cellText(s50,  v50),
                 bgcolor=cellBg(s50,  close, v50),  text_color=cellTxt(s50,  close, v50),  text_size=sz)
            table.cell(t, 4, rowIdx, cellText(s100, v100),
                 bgcolor=cellBg(s100, close, v100), text_color=cellTxt(s100, close, v100), text_size=sz)
            table.cell(t, 5, rowIdx, cellText(s200, v200),
                 bgcolor=cellBg(s200, close, v200), text_color=cellTxt(s200, close, v200), text_size=sz)

// ============================================================================
// ALERTS — fire if any enabled TF has any TAP
// ============================================================================
anyTap =
     (use_1s  and hasTap(e9_1s,  e21_1s,  e50_1s,  e100_1s,  e200_1s))  or
     (use_5s  and hasTap(e9_5s,  e21_5s,  e50_5s,  e100_5s,  e200_5s))  or
     (use_15s and hasTap(e9_15s, e21_15s, e50_15s, e100_15s, e200_15s)) or
     (use_30s and hasTap(e9_30s, e21_30s, e50_30s, e100_30s, e200_30s)) or
     (use_45s and hasTap(e9_45s, e21_45s, e50_45s, e100_45s, e200_45s)) or
     (use_1m  and hasTap(e9_1m,  e21_1m,  e50_1m,  e100_1m,  e200_1m))  or
     (use_2m  and hasTap(e9_2m,  e21_2m,  e50_2m,  e100_2m,  e200_2m))  or
     (use_3m  and hasTap(e9_3m,  e21_3m,  e50_3m,  e100_3m,  e200_3m))  or
     (use_5m  and hasTap(e9_5m,  e21_5m,  e50_5m,  e100_5m,  e200_5m))  or
     (use_10m and hasTap(e9_10m, e21_10m, e50_10m, e100_10m, e200_10m)) or
     (use_15m and hasTap(e9_15m, e21_15m, e50_15m, e100_15m, e200_15m)) or
     (use_20m and hasTap(e9_20m, e21_20m, e50_20m, e100_20m, e200_20m)) or
     (use_30m and hasTap(e9_30m, e21_30m, e50_30m, e100_30m, e200_30m)) or
     (use_45m and hasTap(e9_45m, e21_45m, e50_45m, e100_45m, e200_45m)) or
     (use_1h  and hasTap(e9_1h,  e21_1h,  e50_1h,  e100_1h,  e200_1h))  or
     (use_2h  and hasTap(e9_2h,  e21_2h,  e50_2h,  e100_2h,  e200_2h))  or
     (use_3h  and hasTap(e9_3h,  e21_3h,  e50_3h,  e100_3h,  e200_3h))  or
     (use_4h  and hasTap(e9_4h,  e21_4h,  e50_4h,  e100_4h,  e200_4h))  or
     (use_1D  and hasTap(e9_1D,  e21_1D,  e50_1D,  e100_1D,  e200_1D))  or
     (use_1W  and hasTap(e9_1W,  e21_1W,  e50_1W,  e100_1W,  e200_1W))

alertcondition(anyTap, title="EMA Tap Detected",
     message="Price tapping one or more MTF EMAs — check scanner table.")
````
