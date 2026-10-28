# KEGEL 1.618 Fibonacci & Sequential Suite v5

- url: https://www.tradingview.com/script/GWESub8V-KEGEL-1-618-Fibonacci-Sequential-Suite-v5/
- type: indicator
- pine_id: PUB;b22387a1615d45379b9c8225117553e3
- version: 3.0

## Description

Auto Fib levels based off market structure shifts / 1.618 is always the key level / various other goodies for boys including some Wyckoff, OB, FVG's and maybe some sequential for extra spice. 

https://www.tradingview.com/x/12m7SDGk/

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// KEGEL 1.618 Fibonacci Suite — Open Source
// Built for anyone willing to put in the work to understand price.
// This is only possible because Christ Yeshua is King, and all credit is his only...
//@version=6
indicator("KEGEL 1.618 Fibonacci Suite v6", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ==========================================
// --- INPUT GROUPS ---
// ==========================================
string G_FIB  = "Fibonacci Levels"
string G_SIG  = "Signal Logic & MSB"
string G_ICT  = "ICT & Liquidity"
string G_GRID = "Fixed Grid Levels"
string G_TD   = "GK Sequencer"
string G_WYK  = "Wyckoff Effort/Result"
string G_ALR  = "Alert Customization"

// ==========================================
// --- INPUTS: FIBONACCI ---
// ==========================================
showFibs       = input.bool(true,  "Show Fibonacci Levels",         group=G_FIB)
showOnlyLast   = input.bool(true,  "Only Show Most Recent Fib",      group=G_FIB)
showLabels     = input.bool(true,  "Show Price Labels",              group=G_FIB)
showLabelsLast = input.bool(true,  "Labels on Current Fib Only",     group=G_FIB)
fibWidth       = input.int(1,      "Line Thickness", minval=1, maxval=5, group=G_FIB)

useF0    = input.bool(true,  "", inline="L0",    group=G_FIB), f0_val    = input.float(0.0,   "Level 0.000",    inline="L0",    group=G_FIB), f0_col    = input.color(color.gray,                  "", inline="L0",    group=G_FIB)
useF236  = input.bool(true,  "", inline="L236",  group=G_FIB), f236_val  = input.float(0.236, "Level 0.236",    inline="L236",  group=G_FIB), f236_col  = input.color(color.new(color.gray, 40),   "", inline="L236",  group=G_FIB)
useF382  = input.bool(true,  "", inline="L382",  group=G_FIB), f382_val  = input.float(0.382, "Level 0.382",    inline="L382",  group=G_FIB), f382_col  = input.color(color.new(color.gray, 40),   "", inline="L382",  group=G_FIB)
useF5    = input.bool(true,  "", inline="L5",    group=G_FIB), f5_val    = input.float(0.5,   "Level 0.500",    inline="L5",    group=G_FIB), f5_col    = input.color(#5b9cf6,                     "", inline="L5",    group=G_FIB)
useF618  = input.bool(true,  "", inline="L618",  group=G_FIB), f618_val  = input.float(0.618, "Level 0.618",    inline="L618",  group=G_FIB), f618_col  = input.color(#089981,                     "", inline="L618",  group=G_FIB)
useF65   = input.bool(true,  "", inline="L65",   group=G_FIB), f65_val   = input.float(0.65,  "Level 0.650",    inline="L65",   group=G_FIB), f65_col   = input.color(#089981,                     "", inline="L65",   group=G_FIB)
useF786  = input.bool(true,  "", inline="L786",  group=G_FIB), f786_val  = input.float(0.786, "Level 0.786",    inline="L786",  group=G_FIB), f786_col  = input.color(color.new(color.gray, 40),   "", inline="L786",  group=G_FIB)
useF1    = input.bool(true,  "", inline="L1",    group=G_FIB), f1_val    = input.float(1.0,   "Level 1.000",    inline="L1",    group=G_FIB), f1_col    = input.color(color.gray,                  "", inline="L1",    group=G_FIB)
useF1618 = input.bool(true,  "", inline="L1618", group=G_FIB), f1618_val = input.float(1.618, "Level 1.618 🎯", inline="L1618", group=G_FIB), f1618_col = input.color(#f23645,                     "", inline="L1618", group=G_FIB)
useF2618 = input.bool(true,  "", inline="L2618", group=G_FIB), f2618_val = input.float(2.618, "Level 2.618",    inline="L2618", group=G_FIB), f2618_col = input.color(color.maroon,                "", inline="L2618", group=G_FIB)
useF3618 = input.bool(true,  "", inline="L3618", group=G_FIB), f3618_val = input.float(3.618, "Level 3.618",    inline="L3618", group=G_FIB), f3618_col = input.color(color.new(color.maroon, 30), "", inline="L3618", group=G_FIB)
useF4236 = input.bool(true,  "", inline="L4236", group=G_FIB), f4236_val = input.float(4.236, "Level 4.236",    inline="L4236", group=G_FIB), f4236_col = input.color(color.new(color.purple, 20), "", inline="L4236", group=G_FIB)

// ==========================================
// --- INPUTS: SIGNAL LOGIC & MSB ---
// ==========================================
confirmClose   = input.bool(false, "Wait for Bar Close (No Repaint)", group=G_SIG,
                 tooltip="ON = signals only trigger on confirmed closed candles. Eliminates repainting. OFF = live intrabar.")
pivotLen       = input.int(4,       "Pivot Lookback", minval=1, group=G_SIG)
entryFib       = input.string("0.618", "Entry at Fib", options=["0.382","0.5","0.618","0.65","0.786"], group=G_SIG)
tpFib          = input.float(1.618, "Take Profit (Fib)", group=G_SIG)
requireSweep   = input.bool(false,  "Require Liquidity Sweep Before Signal", group=G_SIG)
showMSBBox     = input.bool(true,   "Show MSB Origin Box", group=G_SIG)
msbBoxExtend   = input.int(40,      "MSB Box Extension (Bars)", minval=5, maxval=200, group=G_SIG)
msbVolLookback = input.int(100,     "Volume Lookback (bars)", minval=20, maxval=500, group=G_SIG)
msbBullCol     = input.color(color.new(#089981, 70), "MSB Bull Color", inline="msbcol", group=G_SIG)
msbBearCol     = input.color(color.new(#f23645, 70), "MSB Bear Color", inline="msbcol", group=G_SIG)
msbMitCol      = input.color(color.new(color.gray, 80), "Mitigated Color", group=G_SIG)

// ==========================================
// --- INPUTS: ICT & LIQUIDITY ---
// ==========================================
showFVG      = input.bool(true,  "Show FVGs",              group=G_ICT)
maxFVGs      = input.int(8,      "Max FVGs to Display", minval=1, maxval=20, group=G_ICT)
fvgColBull   = input.color(color.new(#089981, 85), "Bull FVG", inline="fvg", group=G_ICT)
fvgColBear   = input.color(color.new(#f23645, 85), "Bear FVG", inline="fvg", group=G_ICT)
showOB       = input.bool(true,  "Show Order Blocks",       group=G_ICT)
obColBull    = input.color(color.new(#089981, 80), "Bull OB", inline="ob",  group=G_ICT)
obColBear    = input.color(color.new(#f23645, 80), "Bear OB", inline="ob",  group=G_ICT)
obExtend     = input.int(10,     "OB/FVG Extension (Bars)", minval=0, group=G_ICT)
showMidline  = input.bool(true,  "Show 50% Midline on Zones", group=G_ICT)
showSweeps   = input.bool(true,  "Show Liquidity Sweeps",   group=G_ICT)
showVolPools = input.bool(true,  "Show Volume Pools (HV)",  group=G_ICT)
volThreshold = input.float(1.8,  "Volume Spike Multiplier", minval=1.0, group=G_ICT)
volLabelSize = input.string("Normal", "Volume Label Size", options=["Tiny","Small","Normal","Large"], group=G_ICT)

// ==========================================
// --- INPUTS: FIXED GRID ---
// ==========================================
showGrid       = input.bool(true, "Show Fixed Grid Levels", group=G_GRID)
gridInstr      = input.string("Auto-Detect", "Instrument", options=["Auto-Detect","NQ/MNQ","ES/MES","YM/MYM","Custom"], group=G_GRID)
gridCustomRTH  = input.float(10.0, "Custom RTH Interval",      group=G_GRID)
gridCustomON   = input.float(5.0,  "Custom Overnight Interval", group=G_GRID)
gridLineCol    = input.color(color.new(color.white, 60), "Grid Line Color", group=G_GRID)
gridLineWid    = input.int(1, "Grid Line Width", minval=1, maxval=3, group=G_GRID)
gridLineStyle  = input.string("Solid", "Grid Line Style", options=["Solid","Dashed","Dotted"], group=G_GRID)
showGridLabels = input.bool(true, "Show Grid Labels", group=G_GRID)
gridLookback   = input.int(200,   "Grid Lookback (bars)", minval=50, maxval=500, group=G_GRID)

// ==========================================
// --- INPUTS: GK SEQUENCER ---
// ==========================================
showGK        = input.bool(true, "Show GK Sequencer", group=G_TD)
gkMode        = input.string("Both", "Display Mode", options=["Full Count","Late Stage","Both"], group=G_TD,
               tooltip="Full Count: 6→9→A→B rhythm\nLate Stage: 7→8→9→B high-signal mode\nBoth: full count tiny + late stage prominent")
show6         = input.bool(true,  "Show 6", inline="gk1", group=G_TD)
show9         = input.bool(true,  "Show 9", inline="gk1", group=G_TD)
showA         = input.bool(true,  "Show A", inline="gk2", group=G_TD)
showB         = input.bool(true,  "Show B", inline="gk2", group=G_TD)
gkColorBull   = input.color(#089981, "Full Count Bull", inline="gkc", group=G_TD)
gkColorBear   = input.color(#f23645, "Full Count Bear", inline="gkc", group=G_TD)
gkCol7        = input.color(#f5a623, "7",  inline="gkls",  group=G_TD, tooltip="Warning — fuse burning")
gkCol8        = input.color(#f07b23, "8",  inline="gkls",  group=G_TD, tooltip="Prepare — almost there")
gkCol9Bear    = input.color(#f23645, "9▼", inline="gkls2", group=G_TD, tooltip="Bear exhaustion")
gkCol9Bull    = input.color(#089981, "9▲", inline="gkls2", group=G_TD, tooltip="Bull exhaustion")
gkColBBear    = input.color(#f23645, "B▼", inline="gkls3", group=G_TD, tooltip="Bear B signal")
gkColBBull    = input.color(#089981, "B▲", inline="gkls3", group=G_TD, tooltip="Bull B signal")
showBTrigger   = input.bool(true, "Show B Trigger Line", group=G_TD,
                 tooltip="Line at B candle high (bear) or low (bull). Close through = entry trigger.")
bTriggerCol    = input.color(color.new(color.white, 30), "Trigger Color", inline="btrig", group=G_TD)
bTriggerExtend = input.int(30, "Extend (Bars)", minval=5, maxval=200, inline="btrig", group=G_TD)
showCycles    = input.bool(true, "Show GK Liquidity Cycle Zones", group=G_TD)
cycleProx     = input.float(0.0, "Zone Proximity (0=Auto)", group=G_TD)
cycleMaxAge   = input.int(500,   "Zone Max Age (Bars)", minval=50, maxval=2000, group=G_TD)
cycleExtend   = input.int(50,    "Zone Extension (Bars)", minval=10, maxval=300, group=G_TD)
cycleBullCol  = input.color(color.new(#f5a623, 80), "Bull Zone", inline="cyc", group=G_TD)
cycleBearCol  = input.color(color.new(#9b59b6, 80), "Bear Zone", inline="cyc", group=G_TD)

// ==========================================
// --- INPUTS: WYCKOFF ---
// ==========================================
showWyckoff  = input.bool(true,  "Show Wyckoff Effort/Result", group=G_WYK)
wykVolMult   = input.float(3.5,  "Volume Spike Multiplier", minval=1.1, maxval=10.0, group=G_WYK)
wykBodyPct   = input.float(0.15, "Max Doji Body %",         minval=0.05, maxval=0.5,  group=G_WYK)
wykBullCol   = input.color(color.new(#f23645, 20), "Bear Signal Color", inline="wykcol", group=G_WYK)
wykBearCol   = input.color(color.new(#089981, 20), "Bull Signal Color", inline="wykcol", group=G_WYK)

// ==========================================
// --- INPUTS: ALERTS ---
// ==========================================
alrMSB    = input.bool(true,  "Market Structure Breaks", group=G_ALR)
alrFVG    = input.bool(true,  "Fair Value Gaps",          group=G_ALR)
alrOB     = input.bool(true,  "Order Blocks",             group=G_ALR)
alrFib    = input.bool(false, "Fib Level Touches",        group=G_ALR)
alrGK9    = input.bool(true,  "GK Count 9",               group=G_ALR)
alrGKB    = input.bool(true,  "GK B Signal",              group=G_ALR)
alrBTrig  = input.bool(true,  "B Trigger Line Break",     group=G_ALR)
alrCycle  = input.bool(true,  "Cycle Zone Events",        group=G_ALR)
alrSweep  = input.bool(true,  "Liquidity Sweeps",         group=G_ALR)
alrBB     = input.bool(true,  "Magnet/Trigger Hits",      group=G_ALR)
alrSignal = input.bool(true,  "Buy/Sell Entry Signals",   group=G_ALR)
alrGrid   = input.bool(false, "Price Hits Grid Level",    group=G_ALR)
alrWyk    = input.bool(true,  "Wyckoff Effort/Result",    group=G_ALR)
alrMit    = input.bool(true,  "Zone Mitigation",          group=G_ALR)

// ==========================================
// --- HELPERS ---
// ==========================================
f_labelSize(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal

f_volStr(v) =>
    v >= 1000000 ? str.tostring(math.round(v / 1000000, 2)) + "M" :
     v >= 1000   ? str.tostring(math.round(v / 1000, 1))   + "K" :
     str.tostring(int(v))

f_zoneVol(zHigh, zLow, lookback) =>
    float total = 0.0
    int   lim   = math.min(lookback, bar_index)
    for i = 0 to lim
        if high[i] >= zLow and low[i] <= zHigh
            total += volume[i]
    total

// ==========================================
// --- SESSION & GRID ---
// ==========================================
isRTH = not na(time("1", "0930-1600", "America/New_York"))

f_getInterval() =>
    float rth = 0.0
    float on  = 0.0
    string det = gridInstr
    if det == "Auto-Detect"
        string t = syminfo.ticker
        if str.contains(t, "NQ") or str.contains(t, "MNQ")
            det := "NQ/MNQ"
        else if str.contains(t, "ES") or str.contains(t, "MES")
            det := "ES/MES"
        else if str.contains(t, "YM") or str.contains(t, "MYM")
            det := "YM/MYM"
        else
            det := "Custom"
    if det == "NQ/MNQ"
        rth := 50.0
        on  := 25.0
    else if det == "ES/MES"
        rth := 10.0
        on  := 5.0
    else if det == "YM/MYM"
        rth := 100.0
        on  := 50.0
    else
        rth := gridCustomRTH
        on  := gridCustomON
    [rth, on]

[gridRTH, gridON] = f_getInterval()
float gridInterval = isRTH ? gridRTH : gridON

f_cycleProx() =>
    float p = cycleProx
    if p == 0.0
        string t = syminfo.ticker
        if str.contains(t, "NQ") or str.contains(t, "MNQ")
            p := 25.0
        else if str.contains(t, "ES") or str.contains(t, "MES")
            p := 5.0
        else if str.contains(t, "YM") or str.contains(t, "MYM")
            p := 50.0
        else
            p := 10.0
    p

float zoneProx = f_cycleProx()

// ==========================================
// --- PIVOTS ---
// ==========================================
float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low,  pivotLen, pivotLen)
var float lastPH    = na
var float lastPL    = na
var int   lastPHIdx = na
var int   lastPLIdx = na

if not na(ph)
    lastPH    := ph
    lastPHIdx := bar_index[pivotLen]
if not na(pl)
    lastPL    := pl
    lastPLIdx := bar_index[pivotLen]

// ==========================================
// --- MARKET STRUCTURE BREAKS ---
// ==========================================
bool bullBreak = confirmClose ?
     (close[1] > nz(lastPH[1]) and close[2] <= nz(lastPH[2])) :
     ta.crossover(close, lastPH)
bool bearBreak = confirmClose ?
     (close[1] < nz(lastPL[1]) and close[2] >= nz(lastPL[2])) :
     ta.crossunder(close, lastPL)

// ==========================================
// --- LIQUIDITY SWEEPS ---
// ==========================================
float lowLo    = ta.lowest(low,   pivotLen * 2)
float hiHi     = ta.highest(high, pivotLen * 2)
bool bullSweep = low < lastPL and close > lastPL and low == lowLo
bool bearSweep = high > lastPH and close < lastPH and high == hiHi

var bool recentBullSweep = false
var bool recentBearSweep = false
var int  sweepAge        = 0

if bullSweep
    recentBullSweep := true
    recentBearSweep := false
    sweepAge        := 0
    if alrSweep
        alert(str.format("{0} ({1}): Bull Sweep @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)
if bearSweep
    recentBearSweep := true
    recentBullSweep := false
    sweepAge        := 0
    if alrSweep
        alert(str.format("{0} ({1}): Bear Sweep @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)

sweepAge += 1
if sweepAge > 20
    recentBullSweep := false
    recentBearSweep := false

// ==========================================
// --- GK SEQUENCER COUNTS ---
// ==========================================
var int bullGK = 0
var int bearGK = 0
if close > close[4]
    bullGK += 1
    bearGK := 0
else if close < close[4]
    bearGK += 1
    bullGK := 0
else
    bullGK := 0
    bearGK := 0

var int gkBull = 0
var int gkBear = 0
gkBull := close > close[4] ? nz(gkBull[1]) + 1 : 0
gkBear := close < close[4] ? nz(gkBear[1]) + 1 : 0

int gkBullUp = gkBull - ta.valuewhen(gkBull < gkBull[1], gkBull, 1)
int gkBearDn = gkBear - ta.valuewhen(gkBear < gkBear[1], gkBear, 1)

bool lsBull7  = gkBullUp == 7
bool lsBull8  = gkBullUp == 8
bool lsBull9  = gkBullUp == 9
bool lsBull13 = gkBullUp == 13
bool lsBear7  = gkBearDn == 7
bool lsBear8  = gkBearDn == 8
bool lsBear9  = gkBearDn == 9
bool lsBear13 = gkBearDn == 13

bool bull9Complete = (gkMode == "Full Count" or gkMode == "Both") ? bullGK == 9 : lsBull9
bool bear9Complete = (gkMode == "Full Count" or gkMode == "Both") ? bearGK == 9 : lsBear9

if alrGK9
    if lsBull9
        alert(str.format("{0} ({1}): GK Bull 9 @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)
    if lsBear9
        alert(str.format("{0} ({1}): GK Bear 9 @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)
if alrGKB
    if lsBull13
        alert(str.format("{0} ({1}): GK Bull B Signal @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)
    if lsBear13
        alert(str.format("{0} ({1}): GK Bear B Signal @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)

// ==========================================
// --- B TRIGGER LINES ---
// ==========================================
var line[]  bTrigLines   = array.new_line()
var float[] bTrigLevels  = array.new_float()
var bool[]  bTrigBulls   = array.new_bool()
var int[]   bTrigBars    = array.new_int()
var bool[]  bTrigFired   = array.new_bool()
int maxBTrig = 4

if showBTrigger and showGK
    if lsBull13
        line tl = line.new(bar_index, low, bar_index + bTriggerExtend, low,
                           color=bTriggerCol, width=1, style=line.style_dashed)
        array.push(bTrigLines,  tl)
        array.push(bTrigLevels, low)
        array.push(bTrigBulls,  true)
        array.push(bTrigBars,   bar_index)
        array.push(bTrigFired,  false)
        while array.size(bTrigLines) > maxBTrig
            line.delete(array.shift(bTrigLines))
            array.shift(bTrigLevels)
            array.shift(bTrigBulls)
            array.shift(bTrigBars)
            array.shift(bTrigFired)
    if lsBear13
        line tl = line.new(bar_index, high, bar_index + bTriggerExtend, high,
                           color=bTriggerCol, width=1, style=line.style_dashed)
        array.push(bTrigLines,  tl)
        array.push(bTrigLevels, high)
        array.push(bTrigBulls,  false)
        array.push(bTrigBars,   bar_index)
        array.push(bTrigFired,  false)
        while array.size(bTrigLines) > maxBTrig
            line.delete(array.shift(bTrigLines))
            array.shift(bTrigLevels)
            array.shift(bTrigBulls)
            array.shift(bTrigBars)
            array.shift(bTrigFired)

var bool bTrigBullFired = false
var bool bTrigBearFired = false
bTrigBullFired := false
bTrigBearFired := false

if array.size(bTrigLines) > 0
    for i = 0 to array.size(bTrigLines) - 1
        if not array.get(bTrigFired, i)
            float lvl  = array.get(bTrigLevels, i)
            bool  bull = array.get(bTrigBulls,  i)
            int   age  = bar_index - array.get(bTrigBars, i)
            line.set_x2(array.get(bTrigLines, i), bar_index + bTriggerExtend)
            if bull and close > lvl
                array.set(bTrigFired, i, true)
                bTrigBullFired := true
                line.set_color(array.get(bTrigLines, i), gkColBBull)
                if alrBTrig
                    alert(str.format("{0} ({1}): GK Bull B Trigger Broken @ {2}", syminfo.ticker, timeframe.period, lvl), alert.freq_once_per_bar)
            else if not bull and close < lvl
                array.set(bTrigFired, i, true)
                bTrigBearFired := true
                line.set_color(array.get(bTrigLines, i), gkColBBear)
                if alrBTrig
                    alert(str.format("{0} ({1}): GK Bear B Trigger Broken @ {2}", syminfo.ticker, timeframe.period, lvl), alert.freq_once_per_bar)
            else if age > bTriggerExtend + 5
                array.set(bTrigFired, i, true)
                line.set_color(array.get(bTrigLines, i), color.new(color.gray, 80))

// ==========================================
// --- GK CYCLE ZONES ---
// ==========================================
var float[] bull9Prices  = array.new_float()
var int[]   bull9Bars    = array.new_int()
var float[] bear9Prices  = array.new_float()
var int[]   bear9Bars    = array.new_int()
var box[]   cycleBoxes   = array.new_box()
var label[] cycleLabels  = array.new_label()
var float[] cycleHighs   = array.new_float()
var float[] cycleLows    = array.new_float()
var int[]   cycleCounts  = array.new_int()
var bool[]  cycleBulls   = array.new_bool()
var bool[]  cycleMits    = array.new_bool()
var int[]   cycleBirths  = array.new_int()
int maxCycleZones = 8

if showCycles and bull9Complete
    array.push(bull9Prices, high)
    array.push(bull9Bars,   bar_index)
    while array.size(bull9Prices) > 20
        array.shift(bull9Prices)
        array.shift(bull9Bars)
    int   sz       = array.size(bull9Prices)
    bool  matched  = false
    int   matchIdx = -1
    if sz >= 2
        for i = 0 to sz - 2
            if math.abs(high - array.get(bull9Prices, i)) <= zoneProx
                matched  := true
                matchIdx := i
                break
    if matched
        bool zoneFound = false
        if array.size(cycleBoxes) > 0
            for i = 0 to array.size(cycleBoxes) - 1
                if not array.get(cycleMits, i) and array.get(cycleBulls, i)
                    float zh   = array.get(cycleHighs, i)
                    float zl   = array.get(cycleLows,  i)
                    float zmid = (zh + zl) / 2
                    if math.abs(high - zmid) <= zoneProx * 1.5
                        int newCount = array.get(cycleCounts, i) + 1
                        array.set(cycleCounts, i, newCount)
                        float newH = math.max(zh, high)
                        float newL = math.min(zl, low)
                        array.set(cycleHighs, i, newH)
                        array.set(cycleLows,  i, newL)
                        int op = math.max(90 - newCount * 15, 30)
                        box.set_top(array.get(cycleBoxes, i), newH)
                        box.set_bottom(array.get(cycleBoxes, i), newL)
                        box.set_bgcolor(array.get(cycleBoxes, i), color.new(#f5a623, op))
                        label.set_text(array.get(cycleLabels, i), "🔄 " + str.tostring(newCount) + "x")
                        label.set_y(array.get(cycleLabels, i), (newH + newL) / 2)
                        zoneFound := true
                        if alrCycle
                            alert(str.format("{0} ({1}): GK Bull Cycle {2}x @ {3}", syminfo.ticker, timeframe.period, newCount, close), alert.freq_once_per_bar)
                        break
        if not zoneFound and array.size(cycleBoxes) <= maxCycleZones
            float zH = math.max(high, array.get(bull9Prices, matchIdx))
            float zL = math.min(low,  array.get(bull9Prices, matchIdx) - zoneProx * 0.5)
            box bx   = box.new(bar_index - 5, zH, bar_index + cycleExtend, zL,
                               bgcolor=color.new(#f5a623, 75), border_color=color.new(#f5a623, 40))
            label lb = label.new(bar_index, (zH + zL) / 2, "🔄 2x",
                                 style=label.style_label_left, color=color.new(#f5a623, 40),
                                 textcolor=color.white, size=size.small)
            array.push(cycleBoxes,  bx)
            array.push(cycleLabels, lb)
            array.push(cycleHighs,  zH)
            array.push(cycleLows,   zL)
            array.push(cycleCounts, 2)
            array.push(cycleBulls,  true)
            array.push(cycleMits,   false)
            array.push(cycleBirths, bar_index)
            if alrCycle
                alert(str.format("{0} ({1}): New GK Bull Cycle Zone @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)

if showCycles and bear9Complete
    array.push(bear9Prices, low)
    array.push(bear9Bars,   bar_index)
    while array.size(bear9Prices) > 20
        array.shift(bear9Prices)
        array.shift(bear9Bars)
    int   sz       = array.size(bear9Prices)
    bool  matched  = false
    int   matchIdx = -1
    if sz >= 2
        for i = 0 to sz - 2
            if math.abs(low - array.get(bear9Prices, i)) <= zoneProx
                matched  := true
                matchIdx := i
                break
    if matched
        bool zoneFound = false
        if array.size(cycleBoxes) > 0
            for i = 0 to array.size(cycleBoxes) - 1
                if not array.get(cycleMits, i) and not array.get(cycleBulls, i)
                    float zh   = array.get(cycleHighs, i)
                    float zl   = array.get(cycleLows,  i)
                    float zmid = (zh + zl) / 2
                    if math.abs(low - zmid) <= zoneProx * 1.5
                        int newCount = array.get(cycleCounts, i) + 1
                        array.set(cycleCounts, i, newCount)
                        float newH = math.max(zh, high)
                        float newL = math.min(zl, low)
                        array.set(cycleHighs, i, newH)
                        array.set(cycleLows,  i, newL)
                        int op = math.max(90 - newCount * 15, 30)
                        box.set_top(array.get(cycleBoxes, i), newH)
                        box.set_bottom(array.get(cycleBoxes, i), newL)
                        box.set_bgcolor(array.get(cycleBoxes, i), color.new(#9b59b6, op))
                        label.set_text(array.get(cycleLabels, i), "🔄 " + str.tostring(newCount) + "x")
                        label.set_y(array.get(cycleLabels, i), (newH + newL) / 2)
                        zoneFound := true
                        if alrCycle
                            alert(str.format("{0} ({1}): GK Bear Cycle {2}x @ {3}", syminfo.ticker, timeframe.period, newCount, close), alert.freq_once_per_bar)
                        break
        if not zoneFound and array.size(cycleBoxes) <= maxCycleZones
            float zH = math.max(high, array.get(bear9Prices, matchIdx) + zoneProx * 0.5)
            float zL = math.min(low,  array.get(bear9Prices, matchIdx))
            box bx   = box.new(bar_index - 5, zH, bar_index + cycleExtend, zL,
                               bgcolor=color.new(#9b59b6, 75), border_color=color.new(#9b59b6, 40))
            label lb = label.new(bar_index, (zH + zL) / 2, "🔄 2x",
                                 style=label.style_label_left, color=color.new(#9b59b6, 40),
                                 textcolor=color.white, size=size.small)
            array.push(cycleBoxes,  bx)
            array.push(cycleLabels, lb)
            array.push(cycleHighs,  zH)
            array.push(cycleLows,   zL)
            array.push(cycleCounts, 2)
            array.push(cycleBulls,  false)
            array.push(cycleMits,   false)
            array.push(cycleBirths, bar_index)
            if alrCycle
                alert(str.format("{0} ({1}): New GK Bear Cycle Zone @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)

if barstate.islast and array.size(cycleBoxes) > 0
    for i = 0 to array.size(cycleBoxes) - 1
        if not array.get(cycleMits, i)
            float zh   = array.get(cycleHighs, i)
            float zl   = array.get(cycleLows,  i)
            float zmid = (zh + zl) / 2
            bool  bull = array.get(cycleBulls, i)
            int   age  = bar_index - array.get(cycleBirths, i)
            bool  mit  = bull ? close < zmid : close > zmid
            if mit or age > cycleMaxAge
                array.set(cycleMits, i, true)
                box.set_bgcolor(array.get(cycleBoxes, i), age > cycleMaxAge ? color.new(color.gray, 90) : msbMitCol)
                box.set_border_color(array.get(cycleBoxes, i), color.new(color.gray, 70))
            else
                box.set_right(array.get(cycleBoxes, i), bar_index + cycleExtend)

// ==========================================
// --- SIGNAL STATE MACHINE ---
// ==========================================
var int   pos             = 0
var bool  bull9Confluence = false
var bool  bear9Confluence = false
var int   confluenceCycles = 0
var float anchor0         = na
var float anchor1         = na
var int   anchor0Idx      = na
var int   anchor1Idx      = na
var int   dir             = 0
var bool  target1618Hit   = false
var bool  trigger100Hit   = false
var bool  setupActive     = false
var float msbHigh         = na
var float msbLow          = na
var int   msbLeft         = na
var bool  msbIsBull       = false
var bool  msbMitigated    = false
var float msbVolTotal     = 0.0
var box   msbBox          = na
var label msbVolLbl       = na
var color msbBorderCol    = #089981

if setupActive and pos == 0
    if (dir == 1 and (bearBreak or low < anchor0)) or (dir == -1 and (bullBreak or high > anchor0))
        setupActive   := false
        target1618Hit := false
        trigger100Hit := false

if (bullBreak or bearBreak) and not setupActive
    anchor0       := bullBreak ? lastPL    : lastPH
    anchor1       := bullBreak ? lastPH    : lastPL
    anchor0Idx    := bullBreak ? lastPLIdx : lastPHIdx
    anchor1Idx    := bullBreak ? lastPHIdx : lastPLIdx
    dir           := bullBreak ? 1 : -1
    target1618Hit := false
    trigger100Hit := false
    setupActive   := true
    if alrMSB
        alert(str.format("{0} ({1}): {2} MSB @ {3}", syminfo.ticker, timeframe.period, dir == 1 ? "Bull" : "Bear", close), alert.freq_once_per_bar)

float diffVal   = anchor1 - anchor0
float entryMult = entryFib == "0.382" ? 0.382 : entryFib == "0.5" ? 0.5 : entryFib == "0.65" ? 0.65 : entryFib == "0.786" ? 0.786 : 0.618
float pEntry    = anchor0 + diffVal * entryMult
float pSL       = anchor0
float pTP       = anchor0 + diffVal * tpFib
float p1618     = anchor0 + diffVal * 1.618
float p100      = anchor1

bool sweepGateOk = not requireSweep or (dir == 1 and recentBullSweep) or (dir == -1 and recentBearSweep)

if setupActive
    if dir == 1
        if high >= p1618
            target1618Hit := true
        if target1618Hit and low <= p100
            trigger100Hit := true
    else if dir == -1
        if low <= p1618
            target1618Hit := true
        if target1618Hit and high >= p100
            trigger100Hit := true

bool magnetJustHit  = target1618Hit and not target1618Hit[1]
bool triggerJustHit = trigger100Hit and not trigger100Hit[1]

bool buySignal  = trigger100Hit and pos == 0 and setupActive and dir ==  1 and low  <= pEntry and sweepGateOk
bool sellSignal = trigger100Hit and pos == 0 and setupActive and dir == -1 and high >= pEntry and sweepGateOk

if buySignal
    pos := 1
    if alrSignal
        alert(str.format("{0} ({1}): BUY @ {2} | TP {3} | SL {4}", syminfo.ticker, timeframe.period, close, pTP, pSL), alert.freq_once_per_bar)
if sellSignal
    pos := -1
    if alrSignal
        alert(str.format("{0} ({1}): SELL @ {2} | TP {3} | SL {4}", syminfo.ticker, timeframe.period, close, pTP, pSL), alert.freq_once_per_bar)

bool exitLong  = pos ==  1 and (high >= pTP or low  <= pSL)
bool exitShort = pos == -1 and (low  <= pTP or high >= pSL)
if exitLong or exitShort
    pos         := 0
    setupActive := false

// ==========================================
// --- WYCKOFF ---
// ==========================================
float avgVolWyk   = ta.sma(volume, 20)
float candleRange = high - low
float bodySize    = math.abs(close - open)
bool  isClimax    = volume[1] > avgVolWyk * wykVolMult
bool  isDoji      = candleRange > 0 and (bodySize / candleRange) < wykBodyPct
bool  wykBearSig  = showWyckoff and isClimax and close[1] > open[1] and isDoji
bool  wykBullSig  = showWyckoff and isClimax and close[1] < open[1] and isDoji

if alrWyk
    if wykBearSig
        alert(str.format("{0} ({1}): Wyckoff Bear @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)
    if wykBullSig
        alert(str.format("{0} ({1}): Wyckoff Bull @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)

// ==========================================
// --- FIBONACCI DRAWING ---
// ==========================================
var line[]  fibLines  = array.new_line()
var label[] fibLabels = array.new_label()

f_fib(use, val, col, a0, a1, a0i, w, lbl) =>
    if use and not na(a0)
        float p = a0 + (a1 - a0) * val
        array.push(fibLines, line.new(a0i, p, bar_index + 30, p, color=col, width=w))
        if lbl
            array.push(fibLabels, label.new(bar_index + 30, p,
                 str.tostring(val) + " (" + str.tostring(p, format.mintick) + ")",
                 textcolor=col, style=label.style_label_left, color=#00000000, size=size.small))

if (bullBreak or bearBreak) and showFibs
    if showOnlyLast
        while array.size(fibLines) > 0
            line.delete(array.shift(fibLines))
        while array.size(fibLabels) > 0
            label.delete(array.shift(fibLabels))
    else if showLabelsLast
        while array.size(fibLabels) > 0
            label.delete(array.shift(fibLabels))

    int  a0i   = bullBreak ? lastPLIdx : lastPHIdx
    bool doLbl = showLabels

    f_fib(useF0,    f0_val,    f0_col,    anchor0, anchor1, a0i, fibWidth, doLbl)
    f_fib(useF236,  f236_val,  f236_col,  anchor0, anchor1, a0i, fibWidth, doLbl)
    f_fib(useF382,  f382_val,  f382_col,  anchor0, anchor1, a0i, fibWidth, doLbl)
    f_fib(useF5,    f5_val,    f5_col,    anchor0, anchor1, a0i, fibWidth, doLbl)
    f_fib(useF618,  f618_val,  f618_col,  anchor0, anchor1, a0i, fibWidth, doLbl)
    f_fib(useF65,   f65_val,   f65_col,   anchor0, anchor1, a0i, fibWidth, doLbl)
    f_fib(useF786,  f786_val,  f786_col,  anchor0, anchor1, a0i, fibWidth, doLbl)
    f_fib(useF1,    f1_val,    f1_col,    anchor0, anchor1, a0i, fibWidth, doLbl)
    f_fib(useF1618, f1618_val, f1618_col, anchor0, anchor1, a0i, fibWidth, doLbl)
    f_fib(useF2618, f2618_val, f2618_col, anchor0, anchor1, a0i, fibWidth, doLbl)
    f_fib(useF3618, f3618_val, f3618_col, anchor0, anchor1, a0i, fibWidth, doLbl)
    f_fib(useF4236, f4236_val, f4236_col, anchor0, anchor1, a0i, fibWidth, doLbl)

if alrFib and not na(anchor0)
    float d = anchor1 - anchor0
    float[] vals = array.from(f0_val, f236_val, f382_val, f5_val, f618_val, f65_val, f786_val, f1_val, f1618_val, f2618_val, f3618_val, f4236_val)
    for v in vals
        float lvl = anchor0 + d * v
        if math.abs(close - lvl) <= syminfo.mintick * 3 and math.abs(close[1] - lvl) > syminfo.mintick * 3
            alert(str.format("{0} ({1}): Fib {2} touched @ {3}", syminfo.ticker, timeframe.period, v, lvl), alert.freq_once_per_bar)

// ==========================================
// --- MSB ORIGIN BOX ---
// ==========================================
if (bullBreak or bearBreak) and showMSBBox
    int msbIdx = 1
    for i = 1 to 10
        if bullBreak and close[i] > open[i]
            msbIdx := i
            break
        if bearBreak and close[i] < open[i]
            msbIdx := i
            break
    if not na(msbBox)
        box.delete(msbBox)
    if not na(msbVolLbl)
        label.delete(msbVolLbl)
    msbHigh      := high[msbIdx]
    msbLow       := low[msbIdx]
    msbLeft      := bar_index[msbIdx]
    msbIsBull    := bullBreak
    msbMitigated := false
    msbBorderCol := bullBreak ? #089981 : #f23645
    msbVolTotal  := f_zoneVol(msbHigh, msbLow, msbVolLookback)
    color mc      = bullBreak ? msbBullCol : msbBearCol
    msbBox       := box.new(msbLeft, msbHigh, bar_index + msbBoxExtend, msbLow,
                            bgcolor=mc, border_color=msbBorderCol)
    msbVolLbl    := label.new(msbLeft + 2, (msbHigh + msbLow) / 2, f_volStr(msbVolTotal),
                              style=label.style_label_right, color=msbBorderCol,
                              textcolor=color.white, size=f_labelSize(volLabelSize))

if not na(msbBox) and not msbMitigated and showMSBBox
    float msbMid  = (msbHigh + msbLow) / 2
    bool  priceIn = high >= msbLow and low <= msbHigh
    bool  bullMit = msbIsBull and close < msbMid
    bool  bearMit = not msbIsBull and close > msbMid
    if bullMit or bearMit
        msbMitigated := true
        box.set_bgcolor(msbBox, msbMitCol)
        box.set_border_color(msbBox, color.new(color.gray, 60))
        if alrMit
            alert(str.format("{0} ({1}): MSB Mitigated @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)
    else if priceIn and barstate.islast
        msbVolTotal := f_zoneVol(msbHigh, msbLow, msbVolLookback)
        box.set_bgcolor(msbBox, color.new(msbBorderCol, 55))
    if barstate.islast
        box.set_right(msbBox, bar_index + msbBoxExtend)
        if not na(msbVolLbl)
            label.set_text(msbVolLbl, f_volStr(msbVolTotal))
            label.set_y(msbVolLbl, (msbHigh + msbLow) / 2)

// ==========================================
// --- OB & FVG ARRAYS ---
// ==========================================
var box[]   obBoxes  = array.new_box()
var float[] obHighs  = array.new_float()
var float[] obLows   = array.new_float()
var bool[]  obBulls  = array.new_bool()
var bool[]  obMits   = array.new_bool()
var label[] obLabels = array.new_label()
var float[] obVols   = array.new_float()
int maxOBs = 6

var box[]   fvgBoxes  = array.new_box()
var float[] fvgHighs  = array.new_float()
var float[] fvgLows   = array.new_float()
var bool[]  fvgBulls  = array.new_bool()
var bool[]  fvgMits   = array.new_bool()
var label[] fvgLabels = array.new_label()
var float[] fvgVols   = array.new_float()

// ==========================================
// --- FVGs ---
// ==========================================
if showFVG
    bool isBullFVG = low  > high[2]
    bool isBearFVG = high < low[2]
    if isBullFVG or isBearFVG
        float t   = isBullFVG ? low     : low[2]
        float b   = isBullFVG ? high[2] : high
        float mid = (t + b) / 2
        color fg  = isBullFVG ? fvgColBull : fvgColBear
        color bd  = color.new(isBullFVG ? fvgColBull : fvgColBear, 40)
        float initVol = f_zoneVol(t, b, 50)
        box bx = box.new(bar_index[2], t, bar_index + obExtend, b, bgcolor=fg, border_color=bd)
        if showMidline
            line.new(bar_index[2], mid, bar_index + obExtend, mid, color=bd, style=line.style_dotted)
        label lbl = label.new(bar_index[2] + 1, mid, f_volStr(initVol),
                              style=label.style_label_right,
                              color=isBullFVG ? color.new(#089981, 40) : color.new(#f23645, 40),
                              textcolor=color.white, size=f_labelSize(volLabelSize))
        array.push(fvgBoxes,  bx)
        array.push(fvgHighs,  t)
        array.push(fvgLows,   b)
        array.push(fvgBulls,  isBullFVG)
        array.push(fvgMits,   false)
        array.push(fvgLabels, lbl)
        array.push(fvgVols,   initVol)
        while array.size(fvgBoxes) > maxFVGs
            box.delete(array.shift(fvgBoxes))
            array.shift(fvgHighs)
            array.shift(fvgLows)
            array.shift(fvgBulls)
            array.shift(fvgMits)
            label.delete(array.shift(fvgLabels))
            array.shift(fvgVols)
        if alrFVG
            alert(str.format("{0} ({1}): {2} FVG", syminfo.ticker, timeframe.period, isBullFVG ? "Bull" : "Bear"), alert.freq_once_per_bar)

// ==========================================
// --- ORDER BLOCKS ---
// ==========================================
if showOB and (bullBreak or bearBreak)
    int obIdx = 0
    int lim   = math.max(math.min(bar_index - (bullBreak ? lastPLIdx : lastPHIdx), 15), 1)
    for i = 1 to lim
        if (bullBreak and open[i] > close[i]) or (bearBreak and open[i] < close[i])
            obIdx := i
            break
    if obIdx > 0
        color oc  = bullBreak ? obColBull : obColBear
        color obc = bullBreak ? #089981   : #f23645
        float oh  = high[obIdx]
        float ol  = low[obIdx]
        float mid = (oh + ol) / 2
        float initVol = f_zoneVol(oh, ol, 50)
        box bx = box.new(bar_index[obIdx], oh, bar_index[obIdx] + obExtend, ol,
                         bgcolor=oc, border_color=obc,
                         text="OB", text_color=obc, text_size=size.tiny,
                         text_halign=text.align_left)
        if showMidline
            line.new(bar_index[obIdx], mid, bar_index[obIdx] + obExtend, mid, color=obc, style=line.style_dotted)
        label lbl = label.new(bar_index[obIdx] + 1, mid, f_volStr(initVol),
                              style=label.style_label_right,
                              color=bullBreak ? color.new(#089981, 40) : color.new(#f23645, 40),
                              textcolor=color.white, size=f_labelSize(volLabelSize))
        array.push(obBoxes,  bx)
        array.push(obHighs,  oh)
        array.push(obLows,   ol)
        array.push(obBulls,  bullBreak)
        array.push(obMits,   false)
        array.push(obLabels, lbl)
        array.push(obVols,   initVol)
        while array.size(obBoxes) > maxOBs
            box.delete(array.shift(obBoxes))
            array.shift(obHighs)
            array.shift(obLows)
            array.shift(obBulls)
            array.shift(obMits)
            label.delete(array.shift(obLabels))
            array.shift(obVols)
        if alrOB
            alert(str.format("{0} ({1}): {2} OB", syminfo.ticker, timeframe.period, bullBreak ? "Bull" : "Bear"), alert.freq_once_per_bar)

// ==========================================
// --- ZONE LIFECYCLE ---
// ==========================================
if barstate.islast
    if array.size(obBoxes) > 0
        for i = 0 to array.size(obBoxes) - 1
            if not array.get(obMits, i)
                float zh     = array.get(obHighs, i)
                float zl     = array.get(obLows,  i)
                float zmid   = (zh + zl) / 2
                bool  bull   = array.get(obBulls, i)
                bool  inZone = high >= zl and low <= zh
                bool  mit    = bull ? close < zmid : close > zmid
                if mit
                    array.set(obMits, i, true)
                    box.set_bgcolor(array.get(obBoxes, i), msbMitCol)
                    box.set_border_color(array.get(obBoxes, i), color.new(color.gray, 60))
                    if alrMit
                        alert(str.format("{0} ({1}): OB Mitigated @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)
                else if inZone
                    float newVol = f_zoneVol(zh, zl, 50)
                    array.set(obVols, i, newVol)
                    label.set_text(array.get(obLabels, i), f_volStr(newVol))
                    box.set_bgcolor(array.get(obBoxes, i), bull ? color.new(#089981, 55) : color.new(#f23645, 55))
    if array.size(fvgBoxes) > 0
        for i = 0 to array.size(fvgBoxes) - 1
            if not array.get(fvgMits, i)
                float zh     = array.get(fvgHighs, i)
                float zl     = array.get(fvgLows,  i)
                float zmid   = (zh + zl) / 2
                bool  bull   = array.get(fvgBulls, i)
                bool  inZone = high >= zl and low <= zh
                bool  mit    = bull ? close < zmid : close > zmid
                if mit
                    array.set(fvgMits, i, true)
                    box.set_bgcolor(array.get(fvgBoxes, i), msbMitCol)
                    box.set_border_color(array.get(fvgBoxes, i), color.new(color.gray, 60))
                    if alrMit
                        alert(str.format("{0} ({1}): FVG Mitigated @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)
                else if inZone
                    float newVol = f_zoneVol(zh, zl, 50)
                    array.set(fvgVols, i, newVol)
                    label.set_text(array.get(fvgLabels, i), f_volStr(newVol))
                    box.set_bgcolor(array.get(fvgBoxes, i), bull ? color.new(#089981, 55) : color.new(#f23645, 55))

// ==========================================
// --- FIXED GRID ---
// ==========================================
var line[]  gridLines  = array.new_line()
var label[] gridLabels = array.new_label()

if showGrid and barstate.islast
    while array.size(gridLines) > 0
        line.delete(array.shift(gridLines))
    while array.size(gridLabels) > 0
        label.delete(array.shift(gridLabels))
    float ref     = math.round(close / gridInterval) * gridInterval
    int   numLvls = 30
    for i = -numLvls to numLvls
        float lvl = ref + i * gridInterval
        if lvl > low * 0.99 and lvl < high * 1.01
            line gl = line.new(bar_index - gridLookback, lvl, bar_index + 50, lvl,
                 color=gridLineCol, width=gridLineWid,
                 style=gridLineStyle == "Dashed" ? line.style_dashed : gridLineStyle == "Dotted" ? line.style_dotted : line.style_solid)
            array.push(gridLines, gl)
            if showGridLabels
                array.push(gridLabels, label.new(bar_index + 50, lvl,
                     str.tostring(lvl, format.mintick),
                     style=label.style_label_left, color=#00000000,
                     textcolor=gridLineCol, size=size.tiny))
    if alrGrid
        float nearestGrid = math.round(close / gridInterval) * gridInterval
        if math.abs(close - nearestGrid) < syminfo.mintick * 2
            alert(str.format("{0} ({1}): Price at Grid {2}", syminfo.ticker, timeframe.period, nearestGrid), alert.freq_once_per_bar)

// ==========================================
// --- VOLUME POOLS ---
// ==========================================
float avgVol   = ta.sma(volume, 20)
bool isHighVol = volume > avgVol * volThreshold
if showVolPools and isHighVol and (bullBreak or bearBreak)
    label.new(bar_index, bullBreak ? low : high, "HV",
         color=#00000000,
         style=bullBreak ? label.style_label_up : label.style_label_down,
         textcolor=color.new(color.white, 30), size=size.tiny)

// ==========================================
// --- PLOTSHAPES ---
// ==========================================
plotshape(buySignal,  "Buy",  shape.triangleup,   location.belowbar, #089981, size=size.small, text="BUY",  textcolor=#089981)
plotshape(sellSignal, "Sell", shape.triangledown,  location.abovebar, #f23645, size=size.small, text="SELL", textcolor=#f23645)
plotshape(showSweeps and bullSweep, "Bull Sweep", shape.circle, location.belowbar, #089981, size=size.tiny, text="Sweep", textcolor=#089981)
plotshape(showSweeps and bearSweep, "Bear Sweep", shape.circle, location.abovebar, #f23645, size=size.tiny, text="Sweep", textcolor=#f23645)
plotshape(wykBearSig, "Wyckoff Bear", shape.labeldown, location.abovebar, wykBullCol, size=size.small, text="W", textcolor=color.white)
plotshape(wykBullSig, "Wyckoff Bull", shape.labelup,   location.belowbar, wykBearCol, size=size.small, text="W", textcolor=color.white)

plotchar(magnetJustHit,  "Magnet",  "🎯", location.abovebar, size=size.tiny)
plotchar(triggerJustHit, "Trigger", "⚡", location.belowbar, size=size.tiny)

if alrBB
    if magnetJustHit
        alert(str.format("{0} ({1}): Magnet 1.618 Hit @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)
    if triggerJustHit
        alert(str.format("{0} ({1}): Trigger 1.0 Hit @ {2}", syminfo.ticker, timeframe.period, close), alert.freq_once_per_bar)

// ==========================================
// --- GK SEQUENCER PLOTS ---
// Hierarchy: 6=tiny | 9=tiny | A=small | B=normal
// Late:      7=tiny | 8=small | 9=small | B=normal
// Confluence 9 = diamond
// ==========================================
bool showFull = gkMode == "Full Count" or gkMode == "Both"
bool showLate = gkMode == "Late Stage" or gkMode == "Both"

bull9Confluence  := false
bear9Confluence  := false
confluenceCycles := 0

if lsBull9 and array.size(cycleBoxes) > 0
    for i = 0 to array.size(cycleBoxes) - 1
        if not array.get(cycleMits, i) and array.get(cycleBulls, i)
            if close >= array.get(cycleLows, i) and close <= array.get(cycleHighs, i)
                bull9Confluence  := true
                confluenceCycles := array.get(cycleCounts, i)
                break

if lsBear9 and array.size(cycleBoxes) > 0
    for i = 0 to array.size(cycleBoxes) - 1
        if not array.get(cycleMits, i) and not array.get(cycleBulls, i)
            if close >= array.get(cycleLows, i) and close <= array.get(cycleHighs, i)
                bear9Confluence  := true
                confluenceCycles := array.get(cycleCounts, i)
                break

if alrCycle and bull9Confluence
    alert(str.format("{0} ({1}): 🔥 GK Bull 9 inside {2}x Cycle Zone @ {3}", syminfo.ticker, timeframe.period, confluenceCycles, close), alert.freq_once_per_bar)
if alrCycle and bear9Confluence
    alert(str.format("{0} ({1}): 🔥 GK Bear 9 inside {2}x Cycle Zone @ {3}", syminfo.ticker, timeframe.period, confluenceCycles, close), alert.freq_once_per_bar)

// Full Count
plotchar(showGK and showFull and show6 and bearGK == 6,  "GK Bear 6", "6", location.abovebar, gkColorBear, size=size.tiny)
plotchar(showGK and showFull and show9 and bearGK == 9,  "GK Bear 9", "9", location.abovebar, gkColorBear, size=size.tiny)
plotchar(showGK and showFull and showA and bearGK == 11, "GK Bear A", "A", location.abovebar, gkColorBear, size=size.small)
plotchar(showGK and showFull and show6 and bullGK == 6,  "GK Bull 6", "6", location.belowbar, gkColorBull, size=size.tiny)
plotchar(showGK and showFull and show9 and bullGK == 9,  "GK Bull 9", "9", location.belowbar, gkColorBull, size=size.tiny)
plotchar(showGK and showFull and showA and bullGK == 11, "GK Bull A", "A", location.belowbar, gkColorBull, size=size.small)

// Late Stage
plotchar(showGK and showLate and lsBear7, "GK LS Bear 7", "7", location.abovebar, gkCol7,    size=size.tiny)
plotchar(showGK and showLate and lsBull7, "GK LS Bull 7", "7", location.belowbar, gkCol7,    size=size.tiny)
plotchar(showGK and showLate and lsBear8, "GK LS Bear 8", "8", location.abovebar, gkCol8,    size=size.small)
plotchar(showGK and showLate and lsBull8, "GK LS Bull 8", "8", location.belowbar, gkCol8,    size=size.small)
plotchar(showGK and showLate and lsBear9 and not bear9Confluence, "GK LS Bear 9", "9",  location.abovebar, gkCol9Bear, size=size.small)
plotchar(showGK and showLate and lsBull9 and not bull9Confluence, "GK LS Bull 9", "9",  location.belowbar, gkCol9Bull, size=size.small)
plotchar(showGK and showLate and bear9Confluence,                 "GK Bear 9 CF", "◆", location.abovebar, gkCol9Bear, size=size.normal)
plotchar(showGK and showLate and bull9Confluence,                 "GK Bull 9 CF", "◆", location.belowbar, gkCol9Bull, size=size.normal)

// B Signal — shared (one plotchar per direction covers both Full and Late)
plotchar(showGK and showB and (bearGK == 13 or lsBear13), "GK Bear B", "B", location.abovebar, gkColBBear, size=size.normal)
plotchar(showGK and showB and (bullGK == 13 or lsBull13), "GK Bull B", "B", location.belowbar, gkColBBull, size=size.normal)

// ==========================================
// --- ALERT CONDITIONS ---
// ==========================================
alertcondition(buySignal,                          "BUY Signal",           "KEGEL: BUY Entry Signal")
alertcondition(sellSignal,                         "SELL Signal",          "KEGEL: SELL Entry Signal")
alertcondition(bullBreak,                          "Bull MSB",             "KEGEL: Bullish MSB")
alertcondition(bearBreak,                          "Bear MSB",             "KEGEL: Bearish MSB")
alertcondition(bullSweep,                          "Bull Sweep",           "KEGEL: Bull Liquidity Sweep")
alertcondition(bearSweep,                          "Bear Sweep",           "KEGEL: Bear Liquidity Sweep")
alertcondition(magnetJustHit,                      "Magnet 1.618 Hit",     "KEGEL: Magnet 1.618 Hit")
alertcondition(triggerJustHit,                     "Trigger 1.0 Hit",      "KEGEL: Trigger 1.0 Hit")
alertcondition(lsBull9 or lsBear9,                 "GK Sequencer 9",       "KEGEL: GK Count 9 Exhaustion")
alertcondition(lsBull13 or lsBear13,               "GK Sequencer B",       "KEGEL: GK B Signal")
alertcondition(bTrigBullFired,                     "Bull B Trigger Break", "KEGEL: Bull B Trigger Broken")
alertcondition(bTrigBearFired,                     "Bear B Trigger Break", "KEGEL: Bear B Trigger Broken")
alertcondition(bTrigBullFired or bTrigBearFired,   "Any B Trigger Break",  "KEGEL: B Trigger Broken")
alertcondition(bull9Confluence or bear9Confluence, "GK Confluence 9",      "KEGEL: GK 9 inside Cycle Zone")
alertcondition(wykBullSig,                         "Wyckoff Bull",         "KEGEL: Wyckoff Bull Signal")
alertcondition(wykBearSig,                         "Wyckoff Bear",         "KEGEL: Wyckoff Bear Signal")
alertcondition(buySignal or sellSignal,            "Any Entry Signal",     "KEGEL: Entry Signal")
alertcondition(bullSweep or bearSweep,             "Any Sweep",            "KEGEL: Liquidity Sweep")
alertcondition(bullBreak or bearBreak,             "Any MSB",              "KEGEL: MSB Formed")
````
