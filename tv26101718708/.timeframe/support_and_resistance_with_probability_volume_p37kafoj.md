# Support and Resistance with Probability% Volume

- url: https://www.tradingview.com/script/p37KAFoJ-Support-and-Resistance-with-Probability-Volume/
- type: indicator
- pine_id: PUB;e033183d859042818c126fba5870b0c6
- version: 1.0

## Description

[b]Release Notes — Support and Resistance with Probability% Volume[/b]

What this script does

This indicator automatically plots Support and Resistance zones using confirmed pivot highs/lows from two higher-timeframe “banks”. Each level tracks:
Touch count (how many times price has interacted with the level)
Respect probability % (how often touches resulted in a bounce vs a break)
Volume context for each touch (bucketed into Low → Extra High)

It is designed for both scalping and day trading, with one preset selector.

Key Features

[b]1) Scalp / Day Trade presets (2-bank framework)[/b]

A single dropdown sets the two internal timeframes:
Scalp mode: Bank A = 1m, Bank B = 5m
Day Trade mode: Bank A = 15m, Bank B = 1H
This gives you a fast bank (near-term structure) and a slower bank (bigger structure) at the same time.

[b]2) Confirmed Pivot Levels (non-repainting level creation)[/b]

Levels are created only from confirmed pivot highs/lows, using:
Left Bars / Right Bars to confirm pivots
Levels are added only when the source timeframe prints a new bar
Because pivots are confirmed and request.security() uses lookahead_off, levels are stable (no future leakage).

[b]3) Level merging (de-clutter / reduce duplicates)[/b]

When a new pivot prints, the script checks if it’s close to an existing level.
If within Merge Similar Levels (%), it merges into the existing level (averages the price)
Otherwise it creates a new level
This keeps the chart clean and prevents “stacked” levels at nearly the same price.

[b]4) Level management & pruning (Live vs Historical depth)[/b]

The script maintains a rolling “active level set” using a time window:
Include Historical Levels OFF → uses Bars Window For Levels
Include Historical Levels ON → uses Historical Bars
Old levels automatically drop off once they exceed the selected window, and the bank is also capped with:
Max Levels (Bank A / Bank B)
So it stays fast and avoids clutter.

[b]5) Touch detection (wick-based, ATR-scaled tolerance)[/b]

Touches are detected using a wick-based method (more realistic than close-only tests), with tolerance based on ATR:
Touch Tolerance (ATR x) defines how close price must get to count as a touch
Cooldown Between Touches prevents counting repeated taps too quickly
This works well for volatile symbols where “near misses” matter.

[b]6) Respect Probability % (bounce vs break outcome)[/b]

After a touch, the script opens a “pending outcome” and measures whether price:
Bounces by reaching a bounce threshold, or
Breaks by crossing a break threshold
Both thresholds are ATR-scaled:
Bounce Distance (ATR x)
Break Threshold (ATR x)
The result updates counters:
ok = respected (bounce)
bad = failed (break)
Respect % = ok / (ok + bad) × 100
Lookahead windows control how long the script waits for an outcome:
Lookahead Bars for Respect (Bank A / Bank B)
If neither bounce nor break occurs within the lookahead window, the pending state expires without scoring.

[b]7) Wick Zones (largest excursion visualization)[/b]

Each level maintains a “worst case” wick excursion seen so far:
Support tracks the largest wick below the level
Resistance tracks the largest wick above the level
These are drawn as zones (boxes), so you can visually see how “thick” the level behaves in practice.
Controls include:
Show Zones
Min Zone Height (ATR x)
Zone fill / border opacity settings
Optional:
Show Center Line (lvl) to draw a clean line through the zone midpoint.

[b]8) Volume bucket breakdown per touch (HMV-style)[/b]

Each touch is classified into a volume “bucket” using Z-score:
Uses Volume MA and Volume StDev
Categorizes touches into: Low / Normal / Medium / High / Extra High
Counts how many touches occurred in each bucket
You can choose what to display with:
Show Low / Normal / Medium / High / Extra High
Show Volume Breakdown in Labels
This lets you quickly spot whether a level is being tested mostly on heavy volume (more meaningful) or low volume (often less meaningful).

[b]9) Clean chart rendering + label controls[/b]

The indicator uses object “pools” (lines/labels/boxes) to stay efficient.
You can control appearance with:
Per-bank colors + line widths
Label on/off
Label background opacity + text opacity
Back-extend (how far zones/lines extend left)
Interpreting the labels
Each plotted level label displays:
Sup. / Res.
Bank timeframe (e.g., 1m, 5m, 15m, 1H)
Touch count
Resp % (respect probability)
Optional volume bucket counts for touches
Example:
Sup. (5m) | Touch: 6 | Resp: 83% | Vol M:3 H:2 XH:1

[b]How to Use — Support and Resistance with Probability% Volume[/b]

[b]1) Pick your mode first (Scalp vs Day Trade)[/b]

Use Preset Mode to set the two timeframe banks:
Scalp = Bank A 1m (micro structure) + Bank B 5m (local structure)
Day Trade = Bank A 15m (intraday structure) + Bank B 1H (session structure)
Rule of thumb:
If you’re trading off a 1m–5m chart → Scalp
If you’re trading 5m–15m entries / session moves → Day Trade

[b]2) Understand what the script plots[/b]

Each bank creates levels from confirmed pivot highs/lows and draws them as:
A wick zone (filled box): shows “where price really stabs” around the level
Optional center line: a clean line at the level price
A label: shows Touches, Respect%, and optional Volume bucket counts
Support/Resistance is decided dynamically:
If current price is above the level → it will label it as Support
If current price is below the level → it will label it as Resistance

[b]3) Use Touches + Respect% as the “quality filter”[/b]

The two most useful numbers are:
Touch count: how often the level has been interacted with
Respect %: how often touches resulted in a bounce vs a break
(higher usually = more reliable in that market context)

Practical guidance:
Touches 1–2: “new / unproven” levels (use cautiously)
Touches 3–5: good working levels
Touches 6+: strong structure but can become “obvious” (watch for stop runs)

Respect% guidance:
70–100%: level has recently held well
50–70%: mixed, often tradable only with confirmation
<50%: level is getting chewed through (treat as weak / likely to break)
4) Use the Volume breakdown to judge “meaningful” touches
If Show Volume Breakdown in Labels is on, you’ll see counts like:
M:3 H:2 XH:1 (Medium/High/Extra High volume touches)

How to read it:
More H/XH touches → level tests happened when participation was strong
(usually more meaningful than low-volume taps)
Mostly Low/Normal touches → the level may be “technical” but not defended
Tip for scalping:
A level with high Respect% and multiple High/Extra High touches is often a great “reaction zone” to stalk entries around.

[b]5) Tune “how strict” a touch is (Touch Tolerance)[/b]

Touch Tolerance (ATR x) controls how close price must get to count as a touch.
Smaller = stricter touches (fewer, cleaner)
Larger = looser touches (more, but noisier)
Common starting points:
XAUUSD 1m scalping: 0.08 – 0.15
15m / 1H day trading: 0.10 – 0.25
If you feel touches are “too easy” → reduce tolerance.
If it misses obvious taps → increase tolerance slightly.

[b]6) Tune Respect% behavior (Bounce / Break thresholds)[/b]

These are ATR-based, so they adapt to volatility:
Bounce Distance (ATR x): how far price must move away to count as a bounce
Break Threshold (ATR x): how far through the level counts as a failure/break
Lookahead Bars: how long the script waits for bounce/break confirmation
Practical tuning:
If Respect% feels too optimistic (too many bounces) → increase Bounce Distance
If Respect% feels too harsh (too many breaks) → increase Break Threshold
If outcomes often remain unresolved → increase Lookahead Bars slightly

[b]7) Use Zones (wick thickness) for entries and stops[/b]

Zones show the largest wick excursion seen at that level. This helps with:
Entry placement: enter near the “edge” of the zone rather than the center
Stop placement: stops often need to sit outside the wick zone to avoid noise
Avoiding fakeouts: if the zone is thick, expect deeper probes
Controls:
Min Zone Height (ATR x) prevents tiny/meaningless zones
Zone opacity lets you keep the chart readable

[b]8) De-clutter with merging + level limits[/b]

If you see too many levels stacked:
Increase Merge Similar Levels (%)
Reduce Max Levels per bank
Reduce the Bars Window (or don’t enable Historical)
If you want broader structure:
Enable Include Historical Levels and increase historical bars (careful—more clutter)

[b]9) A simple workflow for trading with it[/b]

[b]For longs[/b]
Identify nearest Support zone (from either bank)
Prefer levels with higher touches + higher Respect%
Prefer levels with multiple High/Extra High volume touches
Wait for your entry trigger (your system/confirmation)
Use the zone thickness to judge stop distance

[b]For shorts[/b]
Same logic using Resistance zones.

[b]Attribution[/b]

This indicator incorporates ideas from several open-source TradingView projects.

[b]Heatmap Volume (xdecow)[/b]

The volume classification system used for touch analysis is inspired by the open-source 
[b]Heatmap Volume indicator by xdecow.[/b]

Specifically, this script adapts the statistical volume classification methodology based on:
[list]
[*]Moving Average of Volume
[*]Standard Deviation of Volume
[*]Relative Volume (Z-Score) Buckets
[/list]

The original Heatmap Volume indicator was designed to visualise abnormal market participation.

In this indicator, that methodology has been substantially extended and integrated into an entirely different Support & Resistance framework where volume buckets are used to:

[list]
[*]Classify every support/resistance touch.
[*]Build historical volume-touch statistics.
[*]Measure how often high participation defends or breaks levels.
[*]Display volume participation directly within each level label.
[/list]

All Support & Resistance detection, probability calculations, touch engine, wick zone calculations, buyer/seller control analysis, level management, historical statistics and rendering were independently developed for this project.

Special thanks to xdecow for releasing the original Heatmap Volume indicator as open source.

## Source Code

````pine
//@version=6
indicator("Support and Resistance with Probability% Volume", overlay=true,
     max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=5000)
     
//=============================================================================
// VOLUME CLASSIFICATION ATTRIBUTION
//=============================================================================
//
// This indicator incorporates a volume classification methodology inspired by
// the open-source Heatmap Volume indicator created by xdecow.
//
// The original Heatmap Volume concept classifies volume using a moving average
// and standard deviation (Z-score) to identify relative participation levels.
//
// This implementation has been substantially modified and integrated into a
// Support & Resistance engine, where the volume classifications are used to:
//
// • Categorise touches into Low / Normal / Medium / High / Extra High.
// • Build historical volume-touch statistics.
// • Calculate probability metrics for Support and Resistance levels.
// • Display volume participation within each level label.
//
// Original Heatmap Volume concept:
// © xdecow
//
// All Support & Resistance logic, probability engine, wick-zone analysis,
// level management, touch tracking and buyer/seller participation statistics
// are original additions.
//=============================================================================
//──────────────────────────────────────────────────────────────────────────────
// MODE (Scalp / Day Trade)
//──────────────────────────────────────────────────────────────────────────────
grpMode = "Mode"
mode = input.string("Scalp", "Preset Mode", options=["Scalp","Day Trade"], group=grpMode)

// Effective TFs from mode (hard-wired)
string tfA = mode == "Scalp" ? "1"  : "15"
string tfB = mode == "Scalp" ? "5"  : "60"

f_tfLabel(string tf) =>
    tf == "60" ? "1H" : (tf + "m")

string tfALabel = f_tfLabel(tfA)
string tfBLabel = f_tfLabel(tfB)

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────
grpDef = "Level Definition"
leftBars   = input.int(15, "Left Bars", minval=1, group=grpDef)
rightBars  = input.int(15, "Right Bars", minval=1, group=grpDef)
mergePct   = input.float(0.25, "Merge Similar Levels (%)", minval=0.01, step=0.01, group=grpDef)
maxLvlsA   = input.int(10, "Max Levels (Bank A)", minval=1, maxval=50, group=grpDef)
maxLvlsB   = input.int(10, "Max Levels (Bank B)", minval=1, maxval=50, group=grpDef)

//──────────────────────────────────────────────────────────────────────────────
// Consolidation (DISPLAY-ONLY) — does NOT change base level engine
//──────────────────────────────────────────────────────────────────────────────
grpConsol = "Consolidation (Display Only)"
enableConsolidation = input.bool(false, "Enable Consolidation (display-only)", group=grpConsol)
mergePips           = input.float(10.0, "Merge Distance (pips)", minval=0.0, step=0.5, group=grpConsol)
pipSize             = input.float(0.1, "Pip Size (price units)", step=0.01, group=grpConsol,
     tooltip="For your XAUUSD convention: 0.1 = 1 pip")

float mergeAbs = mergePips * pipSize

grpHist = "Historical Levels"
useHistorical  = input.bool(false, "Include Historical Levels", group=grpHist)
lookbackBarsA  = input.int(1000, "Bars Window For Levels (Bank A)", minval=100, group=grpHist)
lookbackBarsB  = input.int(1000, "Bars Window For Levels (Bank B)", minval=100, group=grpHist)
histBarsA      = input.int(20000, "Historical Bars (Bank A)", minval=1000, group=grpHist)
histBarsB      = input.int(8000,  "Historical Bars (Bank B)", minval=1000, group=grpHist)

grpTouch = "Touches + Respect % (Wick-Based)"
atrLen        = input.int(14, "ATR Length", minval=1, group=grpTouch)
touchTolATR   = input.float(0.10, "Touch Tolerance (ATR x)", minval=0.01, step=0.01, group=grpTouch)
breakTolATR   = input.float(0.15, "Break Threshold (ATR x)",  minval=0.01, step=0.01, group=grpTouch)
bounceATR     = input.float(0.50, "Bounce Distance (ATR x)",  minval=0.01, step=0.01, group=grpTouch)
cooldownBars  = input.int(2, "Cooldown Between Touches (TF bars)", minval=0, group=grpTouch)

// Lookahead (simple)
lookAheadA = input.int(20, "Lookahead Bars for Respect (Bank A)", minval=1, group=grpTouch)
lookAheadB = input.int(10, "Lookahead Bars for Respect (Bank B)", minval=1, group=grpTouch)

grpStyle = "Style"
supportColorA = input.color(color.lime, "Bank A Support Color", group=grpStyle)
resistColorA  = input.color(color.red,  "Bank A Resistance Color", group=grpStyle)
supportColorB = input.color(color.new(color.lime, 0), "Bank B Support Color", group=grpStyle)
resistColorB  = input.color(color.new(color.red,  0), "Bank B Resistance Color", group=grpStyle)
lineWidthA    = input.int(2, "Bank A Line Width", minval=1, maxval=5, group=grpStyle)
lineWidthB    = input.int(2, "Bank B Line Width", minval=1, maxval=5, group=grpStyle)
labelTextColor = input.color(color.white, "Label Text Color", group=grpStyle)
labelBgOpacity   = input.int(0,  "Label Background Opacity (0-100)", minval=0, maxval=100, group=grpStyle)
labelTextOpacity = input.int(0,  "Label Text Opacity (0-100)",       minval=0, maxval=100, group=grpStyle)
showLabels     = input.bool(true, "Show Labels", group=grpStyle)
backBars       = input.int(500, "Line/Zones Back-Extend (chart bars)", minval=10, maxval=10000, group=grpStyle)

//──────────────────────────────────────────────────────────────────────────────
// Zones (largest wick-based)
//──────────────────────────────────────────────────────────────────────────────
grpZone = "Zones (Largest Wick)"
showZones         = input.bool(true,  "Show Zones", group=grpZone)
showCenterLine    = input.bool(false, "Show Center Line (lvl)", group=grpZone)
zoneOpacity       = input.int(85, "Zone Fill Opacity (0-100)", minval=0, maxval=100, group=grpZone)
zoneBorderOpacity = input.int(60, "Zone Border Opacity (0-100)", minval=0, maxval=100, group=grpZone)
minZoneATRMult    = input.float(0.10, "Min Zone Height (ATR x)", minval=0.0, step=0.01, group=grpZone)

//──────────────────────────────────────────────────────────────────────────────
// Volume Touch Breakdown (HMV-style buckets)
//──────────────────────────────────────────────────────────────────────────────
grpVolHM = "Volume Touch Breakdown (HMV-style)"
showVolTouchBreakdown = input.bool(true, "Show Volume Breakdown in Labels", group=grpVolHM)
volMaLen   = input.int(610, "Volume MA Length", minval=2, group=grpVolHM)
volSdLen   = input.int(610, "Volume StDev Length", minval=2, group=grpVolHM)
thrExtraHigh = input.float(3.0,  "Extra High (stdevs)", group=grpVolHM)
thrHigh      = input.float(1.5,  "High (stdevs)",       group=grpVolHM)
thrMedium    = input.float(0.3,  "Medium (stdevs)",     group=grpVolHM)
thrNormal    = input.float(-0.5, "Normal (stdevs)",     group=grpVolHM)

grpVolShow = "Volume Buckets Visible"
showLow       = input.bool(false,  "Show Low",        group=grpVolShow)
showNormal    = input.bool(false,  "Show Normal",     group=grpVolShow)
showMedium    = input.bool(true,   "Show Medium",     group=grpVolShow)
showHigh      = input.bool(true,   "Show High",       group=grpVolShow)
showExtraHigh = input.bool(true,   "Show Extra High", group=grpVolShow)

//──────────────────────────────────────────────────────────────────────────────
// Buyer/Seller Control (Volume Proxy) — minimalist
//──────────────────────────────────────────────────────────────────────────────
grpCtl = "Volume Control (Buy/Sell Proxy)"
showVolControl      = input.bool(true, "Show Buyer/Seller Control", group=grpCtl)
volControlStyle     = input.string("Glyph+Pct", "Display", options=["Glyph","Pct","Glyph+Pct"], group=grpCtl)
volControlMode      = input.string("Body-weighted", "Proxy Method", options=["Body-weighted","Up/Down Candle"], group=grpCtl)
domThr              = input.float(0.60, "Dominance Threshold", minval=0.50, maxval=0.90, step=0.01, group=grpCtl)

//──────────────────────────────────────────────────────────────────────────────
// Series pulls (2 banks)
//──────────────────────────────────────────────────────────────────────────────
float oA = request.security(syminfo.tickerid, tfA, open,  barmerge.gaps_off, barmerge.lookahead_off)
float hA = request.security(syminfo.tickerid, tfA, high,  barmerge.gaps_off, barmerge.lookahead_off)
float lA = request.security(syminfo.tickerid, tfA, low,   barmerge.gaps_off, barmerge.lookahead_off)
float cA = request.security(syminfo.tickerid, tfA, close, barmerge.gaps_off, barmerge.lookahead_off)
int   tA = request.security(syminfo.tickerid, tfA, time,  barmerge.gaps_off, barmerge.lookahead_off)
float aA = request.security(syminfo.tickerid, tfA, ta.atr(atrLen), barmerge.gaps_off, barmerge.lookahead_off)

float vA   = request.security(syminfo.tickerid, tfA, volume, barmerge.gaps_off, barmerge.lookahead_off)
float vmaA = request.security(syminfo.tickerid, tfA, ta.sma(volume, volMaLen), barmerge.gaps_off, barmerge.lookahead_off)
float vsdA = request.security(syminfo.tickerid, tfA, ta.stdev(volume, volSdLen), barmerge.gaps_off, barmerge.lookahead_off)

float oB = request.security(syminfo.tickerid, tfB, open,  barmerge.gaps_off, barmerge.lookahead_off)
float hB = request.security(syminfo.tickerid, tfB, high,  barmerge.gaps_off, barmerge.lookahead_off)
float lB = request.security(syminfo.tickerid, tfB, low,   barmerge.gaps_off, barmerge.lookahead_off)
float cB = request.security(syminfo.tickerid, tfB, close, barmerge.gaps_off, barmerge.lookahead_off)
int   tB = request.security(syminfo.tickerid, tfB, time,  barmerge.gaps_off, barmerge.lookahead_off)
float aB = request.security(syminfo.tickerid, tfB, ta.atr(atrLen), barmerge.gaps_off, barmerge.lookahead_off)

float vB   = request.security(syminfo.tickerid, tfB, volume, barmerge.gaps_off, barmerge.lookahead_off)
float vmaB = request.security(syminfo.tickerid, tfB, ta.sma(volume, volMaLen), barmerge.gaps_off, barmerge.lookahead_off)
float vsdB = request.security(syminfo.tickerid, tfB, ta.stdev(volume, volSdLen), barmerge.gaps_off, barmerge.lookahead_off)

// Confirmed pivots (LuxAlgo-style)
float phA = request.security(syminfo.tickerid, tfA, ta.pivothigh(high, leftBars, rightBars), barmerge.gaps_off, barmerge.lookahead_off)
float plA = request.security(syminfo.tickerid, tfA, ta.pivotlow(low,  leftBars, rightBars), barmerge.gaps_off, barmerge.lookahead_off)
float phB = request.security(syminfo.tickerid, tfB, ta.pivothigh(high, leftBars, rightBars), barmerge.gaps_off, barmerge.lookahead_off)
float plB = request.security(syminfo.tickerid, tfB, ta.pivotlow(low,  leftBars, rightBars), barmerge.gaps_off, barmerge.lookahead_off)

bool newBarA = (tA != tA[1])
bool newBarB = (tB != tB[1])

//──────────────────────────────────────────────────────────────────────────────
// Level Banks (A + B)
//──────────────────────────────────────────────────────────────────────────────
var float[] lvlsA    = array.new<float>()
var int[]   bornA    = array.new<int>()
var int[]   tchA     = array.new<int>()
var int[]   lastTA   = array.new<int>()
var int[]   okA      = array.new<int>()
var int[]   badA     = array.new<int>()
var bool[]  pendA    = array.new<bool>()
var int[]   pExpireA = array.new<int>()
var int[]   pSideA   = array.new<int>()
var float[] pBounceA = array.new<float>()
var float[] pBreakA  = array.new<float>()

var int[]   vtLowA   = array.new<int>()
var int[]   vtNormA  = array.new<int>()
var int[]   vtMedA   = array.new<int>()
var int[]   vtHighA  = array.new<int>()
var int[]   vtXHA    = array.new<int>()

var float[] wickDnA  = array.new<float>()
var float[] wickUpA  = array.new<float>()

var float[] buyVolA  = array.new<float>()
var float[] sellVolA = array.new<float>()

var float[] lvlsB    = array.new<float>()
var int[]   bornB    = array.new<int>()
var int[]   tchB     = array.new<int>()
var int[]   lastTB   = array.new<int>()
var int[]   okB      = array.new<int>()
var int[]   badB     = array.new<int>()
var bool[]  pendB    = array.new<bool>()
var int[]   pExpireB = array.new<int>()
var int[]   pSideB   = array.new<int>()
var float[] pBounceB = array.new<float>()
var float[] pBreakB  = array.new<float>()

var int[]   vtLowB   = array.new<int>()
var int[]   vtNormB  = array.new<int>()
var int[]   vtMedB   = array.new<int>()
var int[]   vtHighB  = array.new<int>()
var int[]   vtXHB    = array.new<int>()

var float[] wickDnB  = array.new<float>()
var float[] wickUpB  = array.new<float>()

var float[] buyVolB  = array.new<float>()
var float[] sellVolB = array.new<float>()

var int tfBarA = 0
var int tfBarB = 0
if newBarA
    tfBarA += 1
if newBarB
    tfBarB += 1

//──────────────────────────────────────────────────────────────────────────────
// Helpers
//──────────────────────────────────────────────────────────────────────────────
f_clamp(float x, float lo, float hi) =>
    math.min(hi, math.max(lo, x))

f_vol_bucket(float V, float VMA, float VSD) =>
    float z = (not na(V) and not na(VMA) and not na(VSD) and VSD > 0) ? ((V - VMA) / VSD) : 0.0
    int b =
         z >= thrExtraHigh ? 4 :
         z >= thrHigh      ? 3 :
         z >= thrMedium    ? 2 :
         z >= thrNormal    ? 1 : 0
    b

f_remove_at(int idx,
            float[] lvls, int[] born, int[] tch, int[] lastT, int[] ok, int[] bad,
            bool[] pend, int[] pExpire, int[] pSide, float[] pBounce, float[] pBreak,
            int[] vtLow, int[] vtNorm, int[] vtMed, int[] vtHigh, int[] vtXH,
            float[] wickDn, float[] wickUp,
            float[] buyVol, float[] sellVol) =>

    array.remove(lvls, idx)
    array.remove(born, idx)
    array.remove(tch, idx)
    array.remove(lastT, idx)
    array.remove(ok, idx)
    array.remove(bad, idx)
    array.remove(pend, idx)
    array.remove(pExpire, idx)
    array.remove(pSide, idx)
    array.remove(pBounce, idx)
    array.remove(pBreak, idx)

    array.remove(vtLow, idx)
    array.remove(vtNorm, idx)
    array.remove(vtMed, idx)
    array.remove(vtHigh, idx)
    array.remove(vtXH, idx)

    array.remove(wickDn, idx)
    array.remove(wickUp, idx)

    array.remove(buyVol, idx)
    array.remove(sellVol, idx)
    true

f_add_level(float price, int nowTime, float mergePct_,
            float[] lvls, int[] born, int[] tch, int[] lastT, int[] ok, int[] bad,
            bool[] pend, int[] pExpire, int[] pSide, float[] pBounce, float[] pBreak,
            int[] vtLow, int[] vtNorm, int[] vtMed, int[] vtHigh, int[] vtXH,
            float[] wickDn, float[] wickUp,
            float[] buyVol, float[] sellVol,
            int maxLevels) =>
    bool did = false
    if not na(price)
        int n = array.size(lvls)
        int found = -1
        if n > 0
            for i = 0 to n - 1
                float ex = array.get(lvls, i)
                float diffPct = math.abs(price - ex) / ex * 100.0
                if diffPct <= mergePct_
                    found := i

        if found != -1
            float ex2 = array.get(lvls, found)
            array.set(lvls, found, (ex2 + price) / 2.0)
            did := true
        else
            array.push(lvls, price)
            array.push(born, nowTime)
            array.push(tch, 0)
            array.push(lastT, -1000000)
            array.push(ok, 0)
            array.push(bad, 0)
            array.push(pend, false)
            array.push(pExpire, 0)
            array.push(pSide, 0)
            array.push(pBounce, na)
            array.push(pBreak, na)

            array.push(vtLow,  0)
            array.push(vtNorm, 0)
            array.push(vtMed,  0)
            array.push(vtHigh, 0)
            array.push(vtXH,   0)

            array.push(wickDn, 0.0)
            array.push(wickUp, 0.0)

            array.push(buyVol,  0.0)
            array.push(sellVol, 0.0)

            did := true

            while array.size(lvls) > maxLevels
                int oldestIdx = 0
                int oldestT = array.get(born, 0)
                for j = 1 to array.size(born) - 1
                    int bt = array.get(born, j)
                    if bt < oldestT
                        oldestT := bt
                        oldestIdx := j
                _ = f_remove_at(oldestIdx, lvls, born, tch, lastT, ok, bad, pend, pExpire, pSide, pBounce, pBreak,
                                vtLow, vtNorm, vtMed, vtHigh, vtXH, wickDn, wickUp, buyVol, sellVol)
    did

f_prune_by_time(int nowTime, int windowMs,
                float[] lvls, int[] born, int[] tch, int[] lastT, int[] ok, int[] bad,
                bool[] pend, int[] pExpire, int[] pSide, float[] pBounce, float[] pBreak,
                int[] vtLow, int[] vtNorm, int[] vtMed, int[] vtHigh, int[] vtXH,
                float[] wickDn, float[] wickUp,
                float[] buyVol, float[] sellVol) =>
    bool any = false
    int i = 0
    while i < array.size(born)
        int bt = array.get(born, i)
        if (nowTime - bt) > windowMs
            _ = f_remove_at(i, lvls, born, tch, lastT, ok, bad, pend, pExpire, pSide, pBounce, pBreak,
                            vtLow, vtNorm, vtMed, vtHigh, vtXH, wickDn, wickUp, buyVol, sellVol)
            any := true
        else
            i += 1
    any

f_update_bank(bool isNewBar, int tfBar, float H, float L, float O, float C, float ATR, int nowTime,
              float V, float VMA, float VSD,
              int lookAheadTf, int windowMs,
              float[] lvls, int[] born, int[] tch, int[] lastT, int[] ok, int[] bad,
              bool[] pend, int[] pExpire, int[] pSide, float[] pBounce, float[] pBreak,
              int[] vtLow, int[] vtNorm, int[] vtMed, int[] vtHigh, int[] vtXH,
              float[] wickDn, float[] wickUp,
              float[] buyVol, float[] sellVol) =>
    bool did = false
    if isNewBar
        _ = f_prune_by_time(nowTime, windowMs, lvls, born, tch, lastT, ok, bad, pend, pExpire, pSide, pBounce, pBreak,
                            vtLow, vtNorm, vtMed, vtHigh, vtXH, wickDn, wickUp, buyVol, sellVol)

        int n = array.size(lvls)
        if n > 0 and not na(ATR)
            float tolBase    = ATR * touchTolATR
            float brkBase    = ATR * breakTolATR
            float bounceBase = ATR * bounceATR

            // resolve pending
            for i = 0 to n - 1
                if array.get(pend, i)
                    int exp  = array.get(pExpire, i)
                    int side = array.get(pSide, i)
                    float bnc = array.get(pBounce, i)
                    float brk = array.get(pBreak, i)

                    if tfBar > exp
                        array.set(pend, i, false)
                    else
                        bool broke   = side == 1 ? (L < brk) : (H > brk)
                        bool bounced = side == 1 ? (H >= bnc) : (L <= bnc)
                        if broke
                            array.set(bad, i, array.get(bad, i) + 1)
                            array.set(pend, i, false)
                        else if bounced
                            array.set(ok, i, array.get(ok, i) + 1)
                            array.set(pend, i, false)

            // detect touches (wick-based)
            for i = 0 to n - 1
                if not array.get(pend, i)
                    int last = array.get(lastT, i)
                    if (tfBar - last) >= cooldownBars
                        float lvl = array.get(lvls, i)
                        int sideNow = (C >= lvl) ? 1 : -1
                        bool touched = sideNow == 1 ? (L <= lvl + tolBase) : (H >= lvl - tolBase)

                        if touched
                            array.set(tch, i, array.get(tch, i) + 1)
                            array.set(lastT, i, tfBar)

                            int b = f_vol_bucket(V, VMA, VSD)
                            if b == 4
                                array.set(vtXH, i, array.get(vtXH, i) + 1)
                            else if b == 3
                                array.set(vtHigh, i, array.get(vtHigh, i) + 1)
                            else if b == 2
                                array.set(vtMed, i, array.get(vtMed, i) + 1)
                            else if b == 1
                                array.set(vtNorm, i, array.get(vtNorm, i) + 1)
                            else
                                array.set(vtLow, i, array.get(vtLow, i) + 1)

                            // Buyer/Seller volume proxy for this touch (accumulated regardless of display toggles)
                            float rng = math.max(H - L, syminfo.mintick)
                            float delta =
                                 volControlMode == "Up/Down Candle"
                                 ? (C >= O ? 1.0 : -1.0)
                                 : f_clamp((C - O) / rng, -1.0, 1.0)

                            float buyShare  = (delta + 1.0) * 0.5
                            float sellShare = 1.0 - buyShare

                            array.set(buyVol,  i, array.get(buyVol,  i) + (V * buyShare))
                            array.set(sellVol, i, array.get(sellVol, i) + (V * sellShare))

                            float dn = math.max(0.0, lvl - L)
                            float up = math.max(0.0, H - lvl)
                            if sideNow == 1
                                array.set(wickDn, i, math.max(array.get(wickDn, i), dn))
                            else
                                array.set(wickUp, i, math.max(array.get(wickUp, i), up))

                            float bounceT = sideNow == 1 ? (lvl + bounceBase) : (lvl - bounceBase)
                            float breakT  = sideNow == 1 ? (lvl - brkBase)    : (lvl + brkBase)

                            array.set(pend, i, true)
                            array.set(pExpire, i, tfBar + lookAheadTf)
                            array.set(pSide, i, sideNow)
                            array.set(pBounce, i, bounceT)
                            array.set(pBreak,  i, breakT)
                            did := true
    did

//──────────────────────────────────────────────────────────────────────────────
// Historical window + updates
//──────────────────────────────────────────────────────────────────────────────
int barsA  = useHistorical ? histBarsA : lookbackBarsA
int barsB  = useHistorical ? histBarsB : lookbackBarsB
int winMsA = timeframe.in_seconds(tfA) * 1000 * barsA
int winMsB = timeframe.in_seconds(tfB) * 1000 * barsB

_ = f_update_bank(newBarA, tfBarA, hA, lA, oA, cA, aA, tA, vA, vmaA, vsdA, lookAheadA, winMsA,
                  lvlsA, bornA, tchA, lastTA, okA, badA, pendA, pExpireA, pSideA, pBounceA, pBreakA,
                  vtLowA, vtNormA, vtMedA, vtHighA, vtXHA, wickDnA, wickUpA, buyVolA, sellVolA)

_ = f_update_bank(newBarB, tfBarB, hB, lB, oB, cB, aB, tB, vB, vmaB, vsdB, lookAheadB, winMsB,
                  lvlsB, bornB, tchB, lastTB, okB, badB, pendB, pExpireB, pSideB, pBounceB, pBreakB,
                  vtLowB, vtNormB, vtMedB, vtHighB, vtXHB, wickDnB, wickUpB, buyVolB, sellVolB)

// Add new pivot levels (only when TF bar updates) — BASE ENGINE UNCHANGED
if newBarA
    if not na(phA)
        _ = f_add_level(phA, tA, mergePct, lvlsA, bornA, tchA, lastTA, okA, badA, pendA, pExpireA, pSideA, pBounceA, pBreakA,
                        vtLowA, vtNormA, vtMedA, vtHighA, vtXHA, wickDnA, wickUpA, buyVolA, sellVolA, maxLvlsA)
    if not na(plA)
        _ = f_add_level(plA, tA, mergePct, lvlsA, bornA, tchA, lastTA, okA, badA, pendA, pExpireA, pSideA, pBounceA, pBreakA,
                        vtLowA, vtNormA, vtMedA, vtHighA, vtXHA, wickDnA, wickUpA, buyVolA, sellVolA, maxLvlsA)

if newBarB
    if not na(phB)
        _ = f_add_level(phB, tB, mergePct, lvlsB, bornB, tchB, lastTB, okB, badB, pendB, pExpireB, pSideB, pBounceB, pBreakB,
                        vtLowB, vtNormB, vtMedB, vtHighB, vtXHB, wickDnB, wickUpB, buyVolB, sellVolB, maxLvlsB)
    if not na(plB)
        _ = f_add_level(plB, tB, mergePct, lvlsB, bornB, tchB, lastTB, okB, badB, pendB, pExpireB, pSideB, pBounceB, pBreakB,
                        vtLowB, vtNormB, vtMedB, vtHighB, vtXHB, wickDnB, wickUpB, buyVolB, sellVolB, maxLvlsB)

//──────────────────────────────────────────────────────────────────────────────
// Drawing pools (lines + labels + zones)
//──────────────────────────────────────────────────────────────────────────────
var line[]  linesA = array.new_line()
var label[] labsA  = array.new_label()
var box[]   zonesA = array.new_box()

var line[]  linesB = array.new_line()
var label[] labsB  = array.new_label()
var box[]   zonesB = array.new_box()

f_ensure_pool(int count, line[] ls, label[] lbs, box[] bs) =>
    while array.size(ls) < count
        array.push(ls, line.new(bar_index, close, bar_index, close, extend=extend.none))
        array.push(lbs, label.new(bar_index, close, "", style=label.style_label_left, textcolor=labelTextColor, size=size.small))
        array.push(bs, box.new(bar_index, close, bar_index, close, border_width=1))
    true

f_hide_from(int start, line[] ls, label[] lbs, box[] bs) =>
    int sz = array.size(ls)
    if sz > 0 and start < sz
        for i = start to sz - 1
            line  ln = array.get(ls, i)
            label lb = array.get(lbs, i)
            box   bx = array.get(bs, i)

            line.set_xy1(ln, na, na)
            line.set_xy2(ln, na, na)
            label.set_x(lb, na)
            label.set_y(lb, na)

            box.set_lefttop(bx, na, na)
            box.set_rightbottom(bx, na, na)
    true

f_bucket_txt(int vLow, int vNorm, int vMed, int vHigh, int vXH) =>
    string s = ""
    string sep = ""
    if showLow
        s += sep + "L:" + str.tostring(vLow)
        sep := " "
    if showNormal
        s += sep + "N:" + str.tostring(vNorm)
        sep := " "
    if showMedium
        s += sep + "M:" + str.tostring(vMed)
        sep := " "
    if showHigh
        s += sep + "H:" + str.tostring(vHigh)
        sep := " "
    if showExtraHigh
        s += sep + "XH:" + str.tostring(vXH)
        sep := " "
    s

// Build display-only consolidated arrays from base arrays (no base mutation)
f_build_display(bool doConsol, float distAbs,
                float[] srcLvls, int[] srcT, int[] srcOk, int[] srcBad,
                int[] srcVL, int[] srcVN, int[] srcVM, int[] srcVH, int[] srcVX,
                float[] srcWDn, float[] srcWUp,
                float[] srcBV, float[] srcSV,
                float[] outLvls, int[] outT, int[] outOk, int[] outBad,
                int[] outVL, int[] outVN, int[] outVM, int[] outVH, int[] outVX,
                float[] outWDn, float[] outWUp,
                float[] outBV, float[] outSV) =>

    array.clear(outLvls), array.clear(outT), array.clear(outOk), array.clear(outBad)
    array.clear(outVL), array.clear(outVN), array.clear(outVM), array.clear(outVH), array.clear(outVX)
    array.clear(outWDn), array.clear(outWUp)
    array.clear(outBV), array.clear(outSV)

    int n = array.size(srcLvls)
    if n == 0
        true
    else
        for i = 0 to n - 1
            float lvl = array.get(srcLvls, i)

            int ti   = array.get(srcT, i)
            int oki  = array.get(srcOk, i)
            int badi = array.get(srcBad, i)

            int vL  = array.get(srcVL, i)
            int vN  = array.get(srcVN, i)
            int vM  = array.get(srcVM, i)
            int vH  = array.get(srcVH, i)
            int vX  = array.get(srcVX, i)

            float wDn = array.get(srcWDn, i)
            float wUp = array.get(srcWUp, i)

            float bV = array.get(srcBV, i)
            float sV = array.get(srcSV, i)

            int found = -1
            if doConsol and distAbs > 0 and array.size(outLvls) > 0
                for g = 0 to array.size(outLvls) - 1
                    float gl = array.get(outLvls, g)
                    if math.abs(lvl - gl) <= distAbs
                        found := g

            if found == -1
                array.push(outLvls, lvl)
                array.push(outT, ti)
                array.push(outOk, oki)
                array.push(outBad, badi)

                array.push(outVL, vL)
                array.push(outVN, vN)
                array.push(outVM, vM)
                array.push(outVH, vH)
                array.push(outVX, vX)

                array.push(outWDn, wDn)
                array.push(outWUp, wUp)

                array.push(outBV, bV)
                array.push(outSV, sV)
            else
                int gt   = array.get(outT, found)
                float gl = array.get(outLvls, found)

                // Weighted average price by (touches, but fallback weight=1 if zero)
                float w1 = math.max(1.0, gt)
                float w2 = math.max(1.0, ti)
                float newLvl = (gl * w1 + lvl * w2) / (w1 + w2)
                array.set(outLvls, found, newLvl)

                array.set(outT,   found, gt + ti)
                array.set(outOk,  found, array.get(outOk, found) + oki)
                array.set(outBad, found, array.get(outBad, found) + badi)

                array.set(outVL, found, array.get(outVL, found) + vL)
                array.set(outVN, found, array.get(outVN, found) + vN)
                array.set(outVM, found, array.get(outVM, found) + vM)
                array.set(outVH, found, array.get(outVH, found) + vH)
                array.set(outVX, found, array.get(outVX, found) + vX)

                array.set(outWDn, found, math.max(array.get(outWDn, found), wDn))
                array.set(outWUp, found, math.max(array.get(outWUp, found), wUp))

                array.set(outBV, found, array.get(outBV, found) + bV)
                array.set(outSV, found, array.get(outSV, found) + sV)
        true

// Temp arrays (re-used) for consolidated display
var float[] dLvlsA = array.new<float>()
var int[]   dTchA  = array.new<int>()
var int[]   dOkA   = array.new<int>()
var int[]   dBadA  = array.new<int>()
var int[]   dVLA   = array.new<int>()
var int[]   dVNA   = array.new<int>()
var int[]   dVMA   = array.new<int>()
var int[]   dVHA   = array.new<int>()
var int[]   dVXA   = array.new<int>()
var float[] dWDA   = array.new<float>()
var float[] dWUA   = array.new<float>()
var float[] dBVA   = array.new<float>()
var float[] dSVA   = array.new<float>()

var float[] dLvlsB = array.new<float>()
var int[]   dTchB  = array.new<int>()
var int[]   dOkB   = array.new<int>()
var int[]   dBadB  = array.new<int>()
var int[]   dVLB   = array.new<int>()
var int[]   dVNB   = array.new<int>()
var int[]   dVMB   = array.new<int>()
var int[]   dVHB   = array.new<int>()
var int[]   dVXB   = array.new<int>()
var float[] dWDB   = array.new<float>()
var float[] dWUB   = array.new<float>()
var float[] dBVB   = array.new<float>()
var float[] dSVB   = array.new<float>()

f_render_bank(string tfLabel,
              float[] baseLvls, int[] baseT, int[] baseOk, int[] baseBad,
              int[] baseVL, int[] baseVN, int[] baseVM, int[] baseVH, int[] baseVX,
              float[] baseWDn, float[] baseWUp,
              float[] baseBV, float[] baseSV,
              float ATR,
              color supCol, color resCol, int lw,
              line[] ls, label[] lbs, box[] bs,
              bool doConsol, float distAbs,
              float[] outLvls, int[] outT, int[] outOk, int[] outBad,
              int[] outVL, int[] outVN, int[] outVM, int[] outVH, int[] outVX,
              float[] outWDn, float[] outWUp,
              float[] outBV, float[] outSV) =>

    _ = f_build_display(doConsol, distAbs,
        baseLvls, baseT, baseOk, baseBad,
        baseVL, baseVN, baseVM, baseVH, baseVX,
        baseWDn, baseWUp,
        baseBV, baseSV,
        outLvls, outT, outOk, outBad,
        outVL, outVN, outVM, outVH, outVX,
        outWDn, outWUp,
        outBV, outSV)

    int n = array.size(outLvls)
    if n == 0
        _ = f_hide_from(0, ls, lbs, bs)
        true
    else
        _ = f_ensure_pool(n, ls, lbs, bs)
        if array.size(ls) > n
            _ = f_hide_from(n, ls, lbs, bs)

        int safeX1 = math.max(0, bar_index - backBars)
        int endX   = showLabels ? (bar_index + 1) : bar_index
        float minH = (not na(ATR) ? (ATR * minZoneATRMult) : 0.0)

        for i = 0 to n - 1
            float lvl = array.get(outLvls, i)
            int touches = array.get(outT, i)
            int oki  = array.get(outOk, i)
            int badi = array.get(outBad, i)

            float denom = (oki + badi)
            float pct = denom > 0 ? (oki * 100.0 / denom) : na
            string pctTxt = na(pct) ? "n/a" : (str.tostring(math.round(pct)) + "%")

            int vLow  = array.get(outVL, i)
            int vNorm = array.get(outVN, i)
            int vMed  = array.get(outVM, i)
            int vHigh = array.get(outVH, i)
            int vXH   = array.get(outVX, i)

            string volTxt = ""
            if showVolTouchBreakdown
                string bucket = f_bucket_txt(vLow, vNorm, vMed, vHigh, vXH)
                volTxt := bucket == "" ? "" : (" | V " + bucket)

            bool isSup = close >= lvl
            color col = isSup ? supCol : resCol

            float exc = isSup ? array.get(outWDn, i) : array.get(outWUp, i)
            float thick = math.max(minH, exc)

            box bx = array.get(bs, i)
            if showZones and thick > 0
                float topY = isSup ? lvl : (lvl + thick)
                float botY = isSup ? (lvl - thick) : lvl
                box.set_lefttop(bx, safeX1, topY)
                box.set_rightbottom(bx, endX, botY)
                box.set_bgcolor(bx, color.new(col, zoneOpacity))
                box.set_border_color(bx, color.new(col, zoneBorderOpacity))
            else
                box.set_lefttop(bx, na, na)
                box.set_rightbottom(bx, na, na)

            line ln = array.get(ls, i)
            if showCenterLine
                line.set_xy1(ln, safeX1, lvl)
                line.set_xy2(ln, endX, lvl)
                line.set_color(ln, col)
                line.set_width(ln, lw)
                line.set_extend(ln, extend.none)
            else
                line.set_xy1(ln, na, na)
                line.set_xy2(ln, na, na)

            // Buyer/Seller control (always has a neutral EQ baseline)
            float bV = array.get(outBV, i)
            float sV = array.get(outSV, i)
            float tV = bV + sV
            float buyPct = tV > 0 ? (bV / tV) : 0.5

            bool buyersDom  = buyPct >= domThr
            bool sellersDom = buyPct <= (1.0 - domThr)

            string glyph = buyersDom ? "▲" : sellersDom ? "▼" : "•"
            string pctTag =
                 buyersDom  ? ("B" + str.tostring(math.round(buyPct * 100.0))) :
                 sellersDom ? ("S" + str.tostring(math.round((1.0 - buyPct) * 100.0))) :
                              "EQ"

            string ctlTxt = ""
            if showVolControl
                ctlTxt :=
                     volControlStyle == "Glyph"     ? (" " + glyph) :
                     volControlStyle == "Pct"       ? (" " + pctTag) :
                                                     (" " + glyph + pctTag)

            label lb = array.get(lbs, i)
            string txt = "(" + tfLabel + ") | T: " + str.tostring(touches) + " | R: " + pctTxt + volTxt + ctlTxt
            if showLabels
                label.set_x(lb, endX)
                label.set_y(lb, lvl)
                label.set_text(lb, txt)
                label.set_color(lb, color.new(col, labelBgOpacity))
                label.set_textcolor(lb, color.new(labelTextColor, labelTextOpacity))
                label.set_style(lb, label.style_label_left)
                label.set_size(lb, size.small)
            else
                label.set_x(lb, na)
                label.set_y(lb, na)
        true

// Render both banks
bool doConsolNow = enableConsolidation and mergeAbs > 0

_ = f_render_bank(tfALabel,
    lvlsA, tchA, okA, badA,
    vtLowA, vtNormA, vtMedA, vtHighA, vtXHA,
    wickDnA, wickUpA,
    buyVolA, sellVolA,
    aA,
    supportColorA, resistColorA, lineWidthA,
    linesA, labsA, zonesA,
    doConsolNow, mergeAbs,
    dLvlsA, dTchA, dOkA, dBadA,
    dVLA, dVNA, dVMA, dVHA, dVXA,
    dWDA, dWUA,
    dBVA, dSVA)

_ = f_render_bank(tfBLabel,
    lvlsB, tchB, okB, badB,
    vtLowB, vtNormB, vtMedB, vtHighB, vtXHB,
    wickDnB, wickUpB,
    buyVolB, sellVolB,
    aB,
    supportColorB, resistColorB, lineWidthB,
    linesB, labsB, zonesB,
    doConsolNow, mergeAbs,
    dLvlsB, dTchB, dOkB, dBadB,
    dVLB, dVNB, dVMB, dVHB, dVXB,
    dWDB, dWUB,
    dBVB, dSVB)
````
