# Auto Fib Evo

- url: https://www.tradingview.com/script/kZuTXFnH-Auto-Fib-Evo/
- type: indicator
- pine_id: PUB;7097958871a64532851e0ae719047170
- version: 1.0

## Description

auto fib evo is an automatic fibonacci structure tool designed to detect significant market swings, anchor fibonacci levels to confirmed price structure, map retracement and extension zones, project potential targets, identify multi-timeframe confluence, and provide a live reading of where price is positioned inside the current structural leg.

instead of requiring manual fibonacci placement, the indicator builds its framework from confirmed swing pivots and filters weak legs using atr. the active a → b structure can be calculated directly from the chart timeframe or from a confirmed higher-timeframe anchor.

### swing engine

the swing engine determines which price leg is used as the foundation for the fibonacci structure.

**pivot length**

controls how many bars on each side are required to confirm a swing pivot.

a higher value focuses on larger and more established market swings. a lower value reacts faster and captures smaller structures.

because pivots require confirmation, a swing becomes available only after the required number of bars has formed.

**min leg size**

filters structural legs according to atr.

the distance between a and b must be large enough relative to atr at the confirmed b pivot. this helps prevent very small price fluctuations from becoming the active fibonacci structure.

for example, a setting of 2.0 requires the detected leg to measure at least two times the relevant atr.

**use htf anchor**

switches the main fibonacci structure from the chart timeframe to a higher timeframe.

when enabled, the complete swing calculation is performed using confirmed higher-timeframe data.

the selected anchor timeframe must be higher than the current chart timeframe.

**htf timeframe**

selects the higher timeframe used by the main structural engine.

this can be useful when trading on a lower timeframe while keeping the fibonacci framework anchored to a larger market structure.

**trend ema**

sets the ema used to evaluate whether the active structural direction agrees with the broader price trend.

**auto direction**

automatically follows the latest valid bullish or bearish structural leg.

**manual direction**

when auto direction is disabled, the engine can be restricted to either up or down structures.

this allows the user to focus only on bullish retracement structures or only on bearish ones.

### fibonacci retracement grid

the retracement grid automatically calculates fibonacci levels between the confirmed a and b anchors.

available levels include:

0.000  
0.236  
0.382  
0.500  
0.618  
0.650  
0.705  
0.786  
0.886  
1.000

each level can be enabled or disabled individually.

**0.500**

represents the equilibrium area of the structural leg.

**0.618**

highlights the classic golden fibonacci retracement.

**0.650 and 0.705**

provide additional levels around the deeper retracement area and can be used together with the ote framework.

**0.786 and 0.886**

provide deeper retracement references closer to a full return toward the original structural anchor.

the indicator automatically adapts these levels to bullish and bearish legs.

### golden pocket

the golden pocket highlights the area between the 0.618 and 0.650 retracement levels.

when enabled, this zone is displayed directly on the active structure.

it provides a fast visual reference for one of the most closely watched fibonacci retracement areas without requiring the trader to calculate or draw it manually.

### ote zone

the ote zone covers the broader 0.620 to 0.790 retracement region.

this creates a larger structural retracement area around several important fibonacci levels.

the golden pocket and ote can be displayed together, allowing the narrower golden area to remain visible inside the broader deep-retracement zone.

### fibonacci extensions

auto fib evo can automatically project fibonacci levels beyond the confirmed a → b leg.

available extensions include:

1.272  
1.414  
1.618  
2.000  
2.618

each extension can be activated independently.

**1.272**

provides an initial extension reference beyond the completed structural leg.

**1.618**

is highlighted as the primary golden extension.

**2.000 and 2.618**

provide progressively more distant structural projection levels.

extensions can be used as reference areas when price moves beyond the original a → b structure.

### a-b-c measured projection

the indicator includes a separate measured-move projection engine.

after a valid a → b leg has been established, the script waits for a confirmed c retracement pivot.

from c, it projects the magnitude of the original a → b move.

two projection targets are displayed:

**abc 1.000**

projects 100% of the original a → b magnitude from c.

**abc 1.618**

projects 161.8% of the original a → b magnitude from c.

this provides a second projection framework that is structurally different from standard fibonacci extensions.

### time fibonacci

auto fib evo also applies fibonacci ratios to time.

the duration between the confirmed a and b pivots becomes the reference time span.

available time ratios are:

0.382  
0.618  
1.000  
1.618

vertical fibonacci time markers are projected forward from b.

these levels do not predict a specific price. they provide time references based on the duration of the detected structural move.

this can help compare future market activity with the temporal proportions of the original leg.

### multi-timeframe confluence engine

the confluence engine compares fibonacci structures from three configurable higher timeframes.

**confluence tf 1**

sets the first timeframe.

**confluence tf 2**

sets the second timeframe.

**confluence tf 3**

sets the third timeframe.

only genuine higher timeframes participate in the calculation. duplicate timeframe selections are excluded so the same market context cannot be counted more than once.

the confluence engine compares several important fibonacci levels from each valid timeframe, including retracements and extensions.

when levels from different timeframes are sufficiently close to each other, they can form a confluence cluster.

**cluster tolerance %**

controls the maximum price distance allowed between levels for them to belong to the same cluster.

a smaller tolerance requires tighter agreement between levels.

a larger tolerance allows wider clusters.

**minimum distinct tfs**

controls how many different timeframes must contribute before a cluster is considered valid.

this can be set to two or three.

the system also weights valid timeframes according to their actual timeframe magnitude.

confluence quality is classified as:

none  
valid  
moderate  
strong  
very strong

the strongest detected cluster is also tracked by the dashboard.

### live retracement position

the indicator continuously measures the current price relative to the active a → b structure.

the live readout displays the current retracement percentage and automatically classifies price into structural zones.

possible states include:

extension  
shallow retrace  
mid retrace  
equilibrium  
golden pocket  
ote  
deep retrace  
full retrace

this makes it possible to understand the current fibonacci position without manually comparing price against every individual line.

### trend context

the active structural direction is compared with the selected trend ema.

when the detected fibonacci leg and ema context point in the same direction, the dashboard reports the structure as aligned.

when they disagree, it reports a divergent trend context.

this provides an additional layer of information when evaluating the active fibonacci structure.

### parallel fib channel

the parallel fib channel extends the geometry of the detected a → b leg.

instead of displaying only horizontal fibonacci prices, it creates parallel projected boundaries based on the slope and magnitude of the active structural move.

this can help visualize the directional geometry surrounding the current fibonacci framework.

### visual options

three themes are available:

**obsidian gold**

**neon wizard**

**institutional mono**

**extend right**

controls how far the active fibonacci levels and related visual elements extend beyond the current bar.

**label position**

labels can be displayed on the right, left, or both sides of the structure.

**live retracement readout**

enables the live percentage and structural-zone label next to current price.

**parallel fib channel**

enables or disables the projected channel around the structural leg.

### dashboard

the dashboard summarizes the current fibonacci structure in a compact format.

it includes information about the active structural leg, anchor source, a → b range, leg size relative to atr, current retracement, structural position, trend context, equilibrium level, golden 0.618 level, 1.618 extension and nearby structural levels.

the dashboard also incorporates the multi-timeframe confluence state when enough valid higher-timeframe structures are available.

its position can be moved between the four chart corners and the text can be displayed in tiny, small, or normal size.

### quick start

add auto fib evo to the chart and begin with the default settings.

first, allow the swing engine to detect a confirmed a → b leg.

**a** represents the beginning of the detected structural move.

**b** represents the confirmed endpoint of that move.

once the structure is available, the fibonacci retracement grid is automatically positioned between these anchors.

watch the live retracement readout to see where current price is located inside the structure.

a reading around 50% places price near equilibrium.

a retracement around 61.8% to 65% places price inside the golden pocket.

a deeper retracement between approximately 62% and 79% falls inside the broader ote area.

if price expands beyond the original structural move, use the 1.272, 1.618, 2.000 and 2.618 extensions as projected structural references.

when a confirmed c pivot becomes available, the abc projection adds separate 1.000 and 1.618 measured-move targets.

enable the multi-timeframe confluence overlay to identify areas where fibonacci levels from different higher-timeframe structures cluster near the same price.

the time fibonacci verticals can then be used as an additional time-based reference alongside the price-based fibonacci framework.

### using the htf anchor

for a cleaner higher-timeframe structure while trading a lower chart timeframe, enable **use htf anchor**.

select a timeframe higher than the chart timeframe.

for example, a trader working on a lower intraday chart can anchor the main fibonacci structure to a larger intraday or higher-timeframe swing.

the main grid will then follow the accepted confirmed structure from that higher timeframe rather than rebuilding its primary anchors from smaller chart-timeframe swings.

for native chart-timeframe structures, leave htf anchor disabled.

### adjusting sensitivity

if the indicator detects too many small structures, increase **pivot length** or **min leg size**.

this forces the engine to focus on more significant confirmed swings.

if the structure reacts too slowly, reduce the pivot length while keeping enough filtering to avoid insignificant market noise.

increasing **min leg size** is particularly useful when the objective is to reject small swings during low-volatility or noisy conditions.

for multi-timeframe confluence, reduce **cluster tolerance %** when tighter price agreement is required.

increase **minimum distinct tfs** to require confirmation from more independent timeframe structures.

### how auto fib evo can help

auto fib evo is designed to remove much of the manual work involved in maintaining fibonacci structures while keeping the levels connected to confirmed market swings.

it can help with:

automatically identifying significant bullish and bearish structural legs

filtering small swings with atr-based validation

automatically placing fibonacci retracement levels

tracking the current retracement percentage in real time

identifying equilibrium, golden pocket, ote and deep retracement areas

projecting standard fibonacci extensions

creating a-b-c measured-move targets

mapping fibonacci relationships in time

comparing fibonacci structures across multiple higher timeframes

locating price areas where independent timeframe levels converge

keeping lower-timeframe analysis anchored to confirmed higher-timeframe structure

checking whether the active structural leg agrees with the ema trend context

visualizing the geometry of the move with a parallel fibonacci channel

reducing repeated manual fibonacci drawing as market structure evolves

the indicator is best used as a structural mapping tool. fibonacci levels represent reference areas derived from confirmed price swings, not guaranteed reversal or target prices. confluence, trend context, current price behavior, volatility and risk management should be considered together when evaluating a setup.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6

indicator("AUTO FIB EVO", "AFBE", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
const string G1 = "🎯  SWING ENGINE"
const string G2 = "📐  RETRACEMENT"
const string G3 = "🚀  EXTENSION / PROJECTION"
const string G4 = "⏳  TIME FIBONACCI"
const string G5 = "💠  CONFLUENCE ENGINE"
const string G6 = "🌟  GOLDEN POCKET / OTE"
const string G7 = "🎨  VISUALS"
const string G8 = "🖥️  DASHBOARD"

int    pivLen      = input.int(20, "Pivot Length", minval = 3, group = G1, tooltip = "Bars on each side required to confirm a swing. Confirmation occurs pivLen bars after the pivot.")
float  minLegAtr   = input.float(2.0, "Min Leg Size (ATR x)", minval = 0.5, step = 0.5, group = G1, tooltip = "Minimum A→B range measured against ATR at the confirmed B pivot on the same timeframe as the structure.")
bool   useHtf      = input.bool(false, "Use HTF Anchor", group = G1, tooltip = "Calculates the complete swing engine inside the selected higher timeframe and uses confirmed HTF values only.")
string htfTf       = input.timeframe("240", "HTF Timeframe", group = G1)
int    emaLen      = input.int(200, "Trend EMA", minval = 20, group = G1)
bool   autoDir     = input.bool(true, "Auto Direction (latest valid leg)", group = G1)
string manualDir   = input.string("UP", "Manual Direction", options = ["UP", "DOWN"], group = G1, tooltip = "Used only when Auto Direction is disabled. The engine keeps the latest valid leg matching this direction.")

bool   showRet     = input.bool(true, "Show Retracement Grid", group = G2)
bool   f000        = input.bool(true, "0.000", group = G2, inline = "r1")
bool   f236        = input.bool(true, "0.236", group = G2, inline = "r1")
bool   f382        = input.bool(true, "0.382", group = G2, inline = "r1")
bool   f500        = input.bool(true, "0.500", group = G2, inline = "r2")
bool   f618        = input.bool(true, "0.618  (Golden)", group = G2, inline = "r2")
bool   f650        = input.bool(true, "0.650  (OTE)", group = G2, inline = "r3")
bool   f705        = input.bool(true, "0.705  (OTE)", group = G2, inline = "r3")
bool   f786        = input.bool(true, "0.786", group = G2, inline = "r4")
bool   f886        = input.bool(false, "0.886", group = G2, inline = "r4")
bool   f1000       = input.bool(true, "1.000", group = G2, inline = "r4")

bool   showExt     = input.bool(true, "Show Extensions", group = G3)
bool   x1272       = input.bool(true, "1.272", group = G3, inline = "x1")
bool   x1414       = input.bool(false, "1.414", group = G3, inline = "x1")
bool   x1618       = input.bool(true, "1.618  (Golden Ext)", group = G3, inline = "x1")
bool   x2000       = input.bool(true, "2.000", group = G3, inline = "x2")
bool   x2618       = input.bool(true, "2.618", group = G3, inline = "x2")
bool   showProj    = input.bool(true, "A-B-C Measured Projection", group = G3, tooltip = "Projects 1.000 and 1.618 of the confirmed A→B magnitude from the latest confirmed C retracement pivot.")

bool   showTime    = input.bool(true, "Time Fibonacci Verticals", group = G4)
bool   t0382       = input.bool(true, "0.382", group = G4, inline = "t1")
bool   t0618       = input.bool(true, "0.618", group = G4, inline = "t1")
bool   t1000       = input.bool(true, "1.000", group = G4, inline = "t2")
bool   t1618       = input.bool(true, "1.618", group = G4, inline = "t2")

bool   showConf    = input.bool(true, "HTF Confluence Overlay", group = G5)
string cfTf1       = input.timeframe("60",  "Confluence TF 1", group = G5)
string cfTf2       = input.timeframe("240", "Confluence TF 2", group = G5)
string cfTf3       = input.timeframe("D",   "Confluence TF 3", group = G5)
float  confPct      = input.float(0.30, "Cluster Tolerance %", minval = 0.05, step = 0.05, group = G5, tooltip = "Two levels belong to the same cluster when their price distance is within this percentage of current price.")
int    confMinTfs   = input.int(2, "Minimum Distinct TFs", minval = 2, maxval = 3, group = G5, tooltip = "A valid confluence cluster must contain levels from at least this many distinct timeframes.")

bool   showPocket  = input.bool(true, "Golden Pocket (61.8 – 65)", group = G6)
bool   showOte     = input.bool(true, "OTE Zone (62 – 79)", group = G6)

string themeChoice = input.string("Institutional Mono", "Chart Theme", options = ["Obsidian Gold", "Neon Wizard", "Institutional Mono"], group = G7)
int    extendR      = input.int(30, "Extend Right (bars)", minval = 0, maxval = 500, group = G7)
string lblPos       = input.string("Right", "Label Position", options = ["Right", "Left", "Both"], group = G7)
bool   showLive     = input.bool(true, "Live Retracement Readout", group = G7)
bool   showChan     = input.bool(true, "Parallel Fib Channel", group = G7)

string dashPos      = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G8)
string dashSize     = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = G8)
bool   showDash     = input.bool(true, "Show Dashboard", group = G8)

// ─────────────────────────────────────────────────────────────────────────────
// PALETTES
// ─────────────────────────────────────────────────────────────────────────────
bool isObsidian = themeChoice == "Obsidian Gold"
bool isNeon     = themeChoice == "Neon Wizard"

color cBull   = isObsidian ? #26E5B0 : isNeon ? #00FFD1 : #6FAF9F
color cBear   = isObsidian ? #FF4E6A : isNeon ? #FF3B5C : #B66A76
color cGold   = isObsidian ? #FFD23F : isNeon ? #FFD23F : #C6A15B
color cGold2  = isObsidian ? #FFB800 : isNeon ? #FFB800 : #A9884F
color cSoft   = isObsidian ? #6B7280 : isNeon ? #8A93A6 : #667281
color cAccent = isObsidian ? #7C5CFF : isNeon ? #00FFD1 : #7892AA
color BGD     = #0A0E14

// Fixed institutional dashboard palette.
color pBg      = #0B0F14
color pHeader  = #111820
color pCell    = #0E141B
color pBorder  = #27313C
color pText    = #D7DEE7
color pMuted   = #7E8A99
color pBull    = #6FAF9F
color pBear    = #B66A76
color pGold    = #C6A15B
color pBlue    = #7892AA
color pNeutral = #9CA8B6

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
f_txtSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

f_dashPos(string s) =>
    s == "Top Right" ? position.top_right : s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : position.bottom_left

f_ratioColor(float r) =>
    float ra = math.abs(r)
    ra == 0.618 or ra == 0.650 or ra == 1.618 ? cGold : ra == 0.500 or ra == 0.705 or ra == 1.000 or ra == 1.272 ? cGold2 : cAccent

f_ratioWidth(float r) =>
    float ra = math.abs(r)
    ra == 0.618 or ra == 1.618 or ra == 0.500 or ra == 0.705 or ra == 1.000 ? 2 : 1

f_ratioStyle(float r) =>
    float ra = math.abs(r)
    ra == 0.618 or ra == 1.618 or ra == 1.000 or ra == 0.000 or ra == 0.500 or ra == 0.705 or ra == 1.272 ? line.style_solid : line.style_dashed

f_retrace(float ap, float bp, float r) =>
    bp - (bp - ap) * r

f_extend(float ap, float bp, float ext) =>
    ap + (bp - ap) * ext

// Adds the institutional confluence level set for one distinct HTF structure.
f_addConfLevels(array<float> ys, array<int> ids, float ap, float bp, int tfId) =>
    array.push(ys, f_retrace(ap, bp, 0.500))
    array.push(ids, tfId)
    array.push(ys, f_retrace(ap, bp, 0.618))
    array.push(ids, tfId)
    array.push(ys, f_retrace(ap, bp, 0.650))
    array.push(ids, tfId)
    array.push(ys, f_retrace(ap, bp, 0.786))
    array.push(ids, tfId)
    array.push(ys, f_retrace(ap, bp, 1.000))
    array.push(ids, tfId)
    array.push(ys, f_extend(ap, bp, 1.272))
    array.push(ids, tfId)
    array.push(ys, f_extend(ap, bp, 1.618))
    array.push(ids, tfId)

f_zoneName(float ret) =>
    na(ret) ? "NO STRUCTURE" : ret < 0.0 ? "EXTENSION" : ret < 0.382 ? "SHALLOW RETRACE" : ret < 0.485 ? "MID RETRACE" : ret <= 0.515 ? "EQUILIBRIUM" : ret >= 0.618 and ret <= 0.650 ? "GOLDEN POCKET" : ret >= 0.620 and ret <= 0.790 ? "OTE" : ret < 1.0 ? "DEEP RETRACE" : "FULL RETRACE"

f_confText(int score, int tfs, int maxScore) =>
    float q = maxScore > 0 ? float(score) / float(maxScore) : 0.0
    tfs < confMinTfs ? "NONE" : q >= 0.99 ? "VERY STRONG" : q >= 0.80 ? "STRONG" : q >= 0.60 ? "MODERATE" : "VALID"

f_confColor(int score, int tfs, int maxScore) =>
    float q = maxScore > 0 ? float(score) / float(maxScore) : 0.0
    tfs < confMinTfs ? pMuted : q >= 0.80 ? pGold : q >= 0.60 ? pBlue : pNeutral

// Returns a confirmed HTF structural state. The entire calculation happens
// inside the request.security() context. Outputs are shifted by one requested
// timeframe bar, so lookahead_on exposes only already-confirmed HTF state.
f_htfLeg(int len, float minAtrX) =>
    float atr = ta.atr(14)
    float ph  = ta.pivothigh(high, len, len)
    float pl  = ta.pivotlow(low, len, len)

    var float lastPH = na
    var int   lastPHT = na
    var float lastPHAtr = na
    var float lastPL = na
    var int   lastPLT = na
    var float lastPLAtr = na

    var float ap = na
    var int   at = na
    var float bp = na
    var int   bt = na
    var int   d  = 0
    var float cp = na
    var int   ct = na
    var float legAtr = na

    bool phNew = not na(ph)
    bool plNew = not na(pl)

    if phNew
        lastPH := ph
        lastPHT := time[len]
        lastPHAtr := atr[len]
    if plNew
        lastPL := pl
        lastPLT := time[len]
        lastPLAtr := atr[len]

    if phNew and not na(lastPL) and lastPHT > lastPLT
        float legSize = lastPH - lastPL
        float endpointAtr = lastPHAtr
        if not na(endpointAtr) and legSize >= minAtrX * endpointAtr
            ap := lastPL
            at := lastPLT
            bp := lastPH
            bt := lastPHT
            d := 1
            cp := na
            ct := na
            legAtr := endpointAtr

    if plNew and not na(lastPH) and lastPLT > lastPHT
        float legSize = lastPH - lastPL
        float endpointAtr = lastPLAtr
        if not na(endpointAtr) and legSize >= minAtrX * endpointAtr
            ap := lastPH
            at := lastPHT
            bp := lastPL
            bt := lastPLT
            d := -1
            cp := na
            ct := na
            legAtr := endpointAtr

    if not na(ap) and not na(bp)
        if d == 1 and plNew and time[len] > bt
            cp := pl
            ct := time[len]
        if d == -1 and phNew and time[len] > bt
            cp := ph
            ct := time[len]

    [ap[1], at[1], bp[1], bt[1], d[1], cp[1], ct[1], legAtr[1], atr[1], ta.ema(close, emaLen)[1]]

// ─────────────────────────────────────────────────────────────────────────────
// CHART-TF STRUCTURAL ENGINE
// ─────────────────────────────────────────────────────────────────────────────
float atrChart = ta.atr(14)
float emaChart = ta.ema(close, emaLen)
float phChart  = ta.pivothigh(high, pivLen, pivLen)
float plChart  = ta.pivotlow(low, pivLen, pivLen)

var float lastPH = na
var int   lastPHT = na
var float lastPHAtr = na
var float lastPL = na
var int   lastPLT = na
var float lastPLAtr = na

var float chartAP = na
var int   chartAT = na
var float chartBP = na
var int   chartBT = na
var int   chartDir = 0
var float chartCP = na
var int   chartCT = na
var float chartLegAtr = na

if barstate.isconfirmed
    bool phNew = not na(phChart)
    bool plNew = not na(plChart)

    if phNew
        lastPH := phChart
        lastPHT := time[pivLen]
        lastPHAtr := atrChart[pivLen]
    if plNew
        lastPL := plChart
        lastPLT := time[pivLen]
        lastPLAtr := atrChart[pivLen]

    bool allowUp = autoDir or manualDir == "UP"
    bool allowDn = autoDir or manualDir == "DOWN"

    if phNew and allowUp and not na(lastPL) and lastPHT > lastPLT
        float legSize = lastPH - lastPL
        float endpointAtr = lastPHAtr
        if not na(endpointAtr) and legSize >= minLegAtr * endpointAtr
            chartAP := lastPL
            chartAT := lastPLT
            chartBP := lastPH
            chartBT := lastPHT
            chartDir := 1
            chartCP := na
            chartCT := na
            chartLegAtr := endpointAtr

    if plNew and allowDn and not na(lastPH) and lastPLT > lastPHT
        float legSize = lastPH - lastPL
        float endpointAtr = lastPLAtr
        if not na(endpointAtr) and legSize >= minLegAtr * endpointAtr
            chartAP := lastPH
            chartAT := lastPHT
            chartBP := lastPL
            chartBT := lastPLT
            chartDir := -1
            chartCP := na
            chartCT := na
            chartLegAtr := endpointAtr

    if not na(chartAP) and not na(chartBP)
        if chartDir == 1 and plNew and time[pivLen] > chartBT
            chartCP := plChart
            chartCT := time[pivLen]
        if chartDir == -1 and phNew and time[pivLen] > chartBT
            chartCP := phChart
            chartCT := time[pivLen]

// Guard against accidental equal/lower-timeframe anchoring through request.security().
// Equal timeframe should use the native chart engine; HTF mode is intentionally HTF-only.
if barstate.isfirst and useHtf and timeframe.in_seconds(htfTf) <= timeframe.in_seconds()
    runtime.error("HTF Anchor must be higher than the chart timeframe. Disable HTF Anchor to use the chart timeframe.")

// ─────────────────────────────────────────────────────────────────────────────
// TRUE HTF ANCHOR — confirmed data only
// ─────────────────────────────────────────────────────────────────────────────
[htfAP, htfAT, htfBP, htfBT, htfDirRaw, htfCP, htfCT, htfLegAtr, htfAtr, htfEma] = request.security(syminfo.tickerid, htfTf, f_htfLeg(pivLen, minLegAtr), lookahead = barmerge.lookahead_on)

// Manual direction is applied to the confirmed HTF state without fabricating a
// different leg. If the latest confirmed HTF leg is not the requested direction,
// the chart-TF fallback is NOT used; the previous accepted HTF leg is retained.
var float acceptedHtfAP = na
var int   acceptedHtfAT = na
var float acceptedHtfBP = na
var int   acceptedHtfBT = na
var int   acceptedHtfDir = 0
var float acceptedHtfCP = na
var int   acceptedHtfCT = na
var float acceptedHtfLegAtr = na

bool htfDirectionAllowed = autoDir or (manualDir == "UP" and htfDirRaw == 1) or (manualDir == "DOWN" and htfDirRaw == -1)
if htfDirectionAllowed and not na(htfAP) and not na(htfBP)
    acceptedHtfAP := htfAP
    acceptedHtfAT := htfAT
    acceptedHtfBP := htfBP
    acceptedHtfBT := htfBT
    acceptedHtfDir := htfDirRaw
    acceptedHtfCP := htfCP
    acceptedHtfCT := htfCT
    acceptedHtfLegAtr := htfLegAtr

float aP = useHtf ? acceptedHtfAP : chartAP
int   aT = useHtf ? acceptedHtfAT : chartAT
float bP = useHtf ? acceptedHtfBP : chartBP
int   bT = useHtf ? acceptedHtfBT : chartBT
int   dir = useHtf ? acceptedHtfDir : chartDir
float cP = useHtf ? acceptedHtfCP : chartCP
int   cT = useHtf ? acceptedHtfCT : chartCT
float structureAtr = useHtf ? acceptedHtfLegAtr : chartLegAtr
float structureEma = useHtf ? htfEma : emaChart

f_priceAt(float r) =>
    aP + (bP - aP) * r

f_retraceAt(float r) =>
    f_retrace(aP, bP, r)

f_extendBeyond(float ext) =>
    f_extend(aP, bP, ext)

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRMED MULTI-TF CONFLUENCE STRUCTURES
// ─────────────────────────────────────────────────────────────────────────────
[cfA1, cfAT1, cfB1, cfBT1, cfD1, cfC1, cfCT1, cfLA1, cfAtr1, cfEma1] = request.security(syminfo.tickerid, cfTf1, f_htfLeg(pivLen, minLegAtr), lookahead = barmerge.lookahead_on)
[cfA2, cfAT2, cfB2, cfBT2, cfD2, cfC2, cfCT2, cfLA2, cfAtr2, cfEma2] = request.security(syminfo.tickerid, cfTf2, f_htfLeg(pivLen, minLegAtr), lookahead = barmerge.lookahead_on)
[cfA3, cfAT3, cfB3, cfBT3, cfD3, cfC3, cfCT3, cfLA3, cfAtr3, cfEma3] = request.security(syminfo.tickerid, cfTf3, f_htfLeg(pivLen, minLegAtr), lookahead = barmerge.lookahead_on)

float chartSec = timeframe.in_seconds()
float cfSec1 = timeframe.in_seconds(cfTf1)
float cfSec2 = timeframe.in_seconds(cfTf2)
float cfSec3 = timeframe.in_seconds(cfTf3)

// Only genuine higher-timeframe feeds participate. Duplicate timeframe
// selections are de-duplicated so one market context cannot count twice.
bool cfValid1 = cfSec1 > chartSec
bool cfValid2 = cfSec2 > chartSec and cfTf2 != cfTf1
bool cfValid3 = cfSec3 > chartSec and cfTf3 != cfTf1 and cfTf3 != cfTf2

// Weight automatically follows actual timeframe magnitude, not input-slot order.
int cfW1 = cfValid1 ? 1 + (cfValid2 and cfSec1 > cfSec2 ? 1 : 0) + (cfValid3 and cfSec1 > cfSec3 ? 1 : 0) : 0
int cfW2 = cfValid2 ? 1 + (cfValid1 and cfSec2 > cfSec1 ? 1 : 0) + (cfValid3 and cfSec2 > cfSec3 ? 1 : 0) : 0
int cfW3 = cfValid3 ? 1 + (cfValid1 and cfSec3 > cfSec1 ? 1 : 0) + (cfValid2 and cfSec3 > cfSec2 ? 1 : 0) : 0
int confMaxScore = cfW1 + cfW2 + cfW3
int confValidTfCount = (cfValid1 ? 1 : 0) + (cfValid2 ? 1 : 0) + (cfValid3 ? 1 : 0)

array<float> confY = array.new_float()
array<int> confTfId = array.new_int()

if showConf
    if cfValid1 and not na(cfA1) and not na(cfB1) and cfA1 != cfB1
        f_addConfLevels(confY, confTfId, cfA1, cfB1, 1)
    if cfValid2 and not na(cfA2) and not na(cfB2) and cfA2 != cfB2
        f_addConfLevels(confY, confTfId, cfA2, cfB2, 2)
    if cfValid3 and not na(cfA3) and not na(cfB3) and cfA3 != cfB3
        f_addConfLevels(confY, confTfId, cfA3, cfB3, 3)

int   confBestScore = 0
int   confBestTfs = 0
float confBestY = na
float confTolAbs = close * (confPct / 100.0)
int confN = array.size(confY)

if showConf and confN > 0
    for i = 0 to confN - 1
        float yi = array.get(confY, i)
        bool hit1 = false
        bool hit2 = false
        bool hit3 = false
        for j = 0 to confN - 1
            float yj = array.get(confY, j)
            if math.abs(yj - yi) <= confTolAbs
                int tfId = array.get(confTfId, j)
                hit1 := hit1 or tfId == 1
                hit2 := hit2 or tfId == 2
                hit3 := hit3 or tfId == 3
        int distinct = (hit1 ? 1 : 0) + (hit2 ? 1 : 0) + (hit3 ? 1 : 0)
        int score = (hit1 ? cfW1 : 0) + (hit2 ? cfW2 : 0) + (hit3 ? cfW3 : 0)
        if distinct >= confMinTfs and (score > confBestScore or score == confBestScore and (na(confBestY) or math.abs(yi - close) < math.abs(confBestY - close)))
            confBestScore := score
            confBestTfs := distinct
            confBestY := yi

// ─────────────────────────────────────────────────────────────────────────────
// CURRENT STRUCTURAL METRICS
// ─────────────────────────────────────────────────────────────────────────────
float liveRet = na
if not na(aP) and not na(bP) and bP != aP
    liveRet := (bP - close) / (bP - aP)

bool structureUp = dir == 1
bool trendBull = close > structureEma
bool trendAligned = dir != 0 and ((structureUp and trendBull) or (not structureUp and not trendBull))
string positionState = f_zoneName(liveRet)

// ─────────────────────────────────────────────────────────────────────────────
// DRAWING POOLS
// ─────────────────────────────────────────────────────────────────────────────
var line[]  rLn = array.new<line>()
var label[] rLb = array.new<label>()
var box[]   rBx = array.new<box>()

f_wipe() =>
    while array.size(rLn) > 0
        line.delete(array.pop(rLn))
    while array.size(rLb) > 0
        label.delete(array.pop(rLb))
    while array.size(rBx) > 0
        box.delete(array.pop(rBx))

f_drawLevel(float y, int lx, int rx, float ratio, string tag, color tone) =>
    color lc = na(tone) ? f_ratioColor(ratio) : tone
    int lw = f_ratioWidth(ratio)
    array.push(rLn, line.new(lx, y, rx, y, xloc = xloc.bar_time, color = color.new(lc, 15), width = lw, style = f_ratioStyle(ratio)))
    float ra = math.abs(ratio)
    if ra == 0.618 or ra == 1.618
        array.push(rLn, line.new(lx, y, rx, y, xloc = xloc.bar_time, color = color.new(lc, 84), width = 4))
    string txt = tag + "  " + str.tostring(y, format.mintick)
    if lblPos == "Right" or lblPos == "Both"
        array.push(rLb, label.new(rx, y, txt, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(BGD, 100), textcolor = color.new(lc, 8), size = size.tiny))
    if lblPos == "Left" or lblPos == "Both"
        array.push(rLb, label.new(lx, y, tag, xloc = xloc.bar_time, style = label.style_label_right, color = color.new(BGD, 100), textcolor = color.new(lc, 20), size = size.tiny))

// ─────────────────────────────────────────────────────────────────────────────
// RENDER — current structural state only
// ─────────────────────────────────────────────────────────────────────────────
if barstate.islast
    f_wipe()

    if not na(aP) and not na(bP) and not na(aT) and not na(bT)
        int barMs = int(math.max(1000.0, nz(timeframe.in_seconds(), 60.0) * 1000.0))
        int lx = aT
        int rx = time + extendR * barMs
        float leg = bP - aP
        bool up = dir == 1

        // Anchor leg.
        array.push(rLn, line.new(aT, aP, bT, bP, xloc = xloc.bar_time, color = color.new(up ? cBull : cBear, 20), width = 3))
        array.push(rLn, line.new(aT, aP, bT, bP, xloc = xloc.bar_time, color = color.new(up ? cBull : cBear, 84), width = 7))
        array.push(rLb, label.new(aT, aP, "A", xloc = xloc.bar_time, style = up ? label.style_label_up : label.style_label_down, color = color.new(BGD, 20), textcolor = cGold, size = size.small))
        array.push(rLb, label.new(bT, bP, "B", xloc = xloc.bar_time, style = up ? label.style_label_down : label.style_label_up, color = color.new(BGD, 20), textcolor = cGold, size = size.small))

        // Retracement grid.
        if showRet
            float[] rats = array.new_float()
            string[] tags = array.new_string()
            if f000
                array.push(rats, 0.000)
                array.push(tags, "0.000")
            if f236
                array.push(rats, 0.236)
                array.push(tags, "0.236")
            if f382
                array.push(rats, 0.382)
                array.push(tags, "0.382")
            if f500
                array.push(rats, 0.500)
                array.push(tags, "0.500")
            if f618
                array.push(rats, 0.618)
                array.push(tags, "0.618  ★")
            if f650
                array.push(rats, 0.650)
                array.push(tags, "0.650")
            if f705
                array.push(rats, 0.705)
                array.push(tags, "0.705")
            if f786
                array.push(rats, 0.786)
                array.push(tags, "0.786")
            if f886
                array.push(rats, 0.886)
                array.push(tags, "0.886")
            if f1000
                array.push(rats, 1.000)
                array.push(tags, "1.000")
            int nR = array.size(rats)
            if nR > 0
                for i = 0 to nR - 1
                    float r = array.get(rats, i)
                    f_drawLevel(f_retraceAt(r), lx, rx, r, array.get(tags, i), na)

        // Extensions.
        if showExt
            float[] exs = array.new_float()
            string[] etags = array.new_string()
            if x1272
                array.push(exs, 1.272)
                array.push(etags, "1.272")
            if x1414
                array.push(exs, 1.414)
                array.push(etags, "1.414")
            if x1618
                array.push(exs, 1.618)
                array.push(etags, "1.618  ★")
            if x2000
                array.push(exs, 2.000)
                array.push(etags, "2.000")
            if x2618
                array.push(exs, 2.618)
                array.push(etags, "2.618")
            int nE = array.size(exs)
            if nE > 0
                for i = 0 to nE - 1
                    float e = array.get(exs, i)
                    f_drawLevel(f_extendBeyond(e), lx, rx, e, array.get(etags, i), na)

        // Golden Pocket and OTE.
        if showPocket
            float y1 = f_retraceAt(0.618)
            float y2 = f_retraceAt(0.650)
            array.push(rBx, box.new(lx, math.max(y1, y2), rx, math.min(y1, y2), xloc = xloc.bar_time, border_color = na, bgcolor = color.new(cGold, 84)))
        if showOte
            float y1 = f_retraceAt(0.620)
            float y2 = f_retraceAt(0.790)
            array.push(rBx, box.new(lx, math.max(y1, y2), rx, math.min(y1, y2), xloc = xloc.bar_time, border_color = color.new(cGold2, 72), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(cGold2, 93)))

        // A-B-C projection.
        if showProj and not na(cP) and not na(cT)
            float mag = math.abs(leg)
            float dSign = up ? 1.0 : -1.0
            float t1 = cP + dSign * mag
            float t2 = cP + dSign * mag * 1.618
            array.push(rLn, line.new(cT, cP, rx, t1, xloc = xloc.bar_time, color = color.new(cAccent, 50), width = 1, style = line.style_dotted))
            array.push(rLn, line.new(cT, cP, rx, t2, xloc = xloc.bar_time, color = color.new(cAccent, 30), width = 1, style = line.style_dashed))
            array.push(rLb, label.new(rx, t1, "ABC 1.000  " + str.tostring(t1, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(BGD, 100), textcolor = color.new(cAccent, 10), size = size.tiny))
            array.push(rLb, label.new(rx, t2, "ABC 1.618  " + str.tostring(t2, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(BGD, 100), textcolor = cAccent, size = size.tiny))
            array.push(rLb, label.new(cT, cP, "C", xloc = xloc.bar_time, style = up ? label.style_label_up : label.style_label_down, color = color.new(BGD, 20), textcolor = cAccent, size = size.tiny))

        // Time Fibonacci using the confirmed A→B time span.
        if showTime
            int spanMs = bT - aT
            if spanMs > 0
                float[] trs = array.new_float()
                string[] ttags = array.new_string()
                if t0382
                    array.push(trs, 0.382)
                    array.push(ttags, "T 0.382")
                if t0618
                    array.push(trs, 0.618)
                    array.push(ttags, "T 0.618")
                if t1000
                    array.push(trs, 1.000)
                    array.push(ttags, "T 1.000")
                if t1618
                    array.push(trs, 1.618)
                    array.push(ttags, "T 1.618")
                int nT = array.size(trs)
                if nT > 0
                    for i = 0 to nT - 1
                        int tx = bT + int(float(spanMs) * array.get(trs, i))
                        array.push(rLn, line.new(tx, aP, tx, bP, xloc = xloc.bar_time, color = color.new(cAccent, 68), width = 1, style = line.style_dotted, extend = extend.both))
                        array.push(rLb, label.new(tx, up ? bP : aP, array.get(ttags, i), xloc = xloc.bar_time, style = label.style_label_down, color = color.new(BGD, 100), textcolor = color.new(cAccent, 25), size = size.tiny))

        // Parallel Fib channel.
        if showChan
            int spanMs = bT - aT
            if spanMs > 0
                float slopePerMs = leg / float(spanMs)
                int futureMs = rx - bT
                float upperY0 = aP + leg
                float upperY1 = bP + leg + slopePerMs * float(futureMs)
                float lowerY0 = aP - leg
                float lowerY1 = bP - leg + slopePerMs * float(futureMs)
                array.push(rLn, line.new(aT, upperY0, rx, upperY1, xloc = xloc.bar_time, color = color.new(cAccent, 78), width = 1, style = line.style_dotted))
                array.push(rLn, line.new(aT, lowerY0, rx, lowerY1, xloc = xloc.bar_time, color = color.new(cAccent, 78), width = 1, style = line.style_dotted))

        // Distinct-timeframe confluence clusters. One contribution maximum per TF.
        if showConf and confN > 0
            float[] drawnClusters = array.new_float()
            for i = 0 to confN - 1
                float yi = array.get(confY, i)
                bool hit1 = false
                bool hit2 = false
                bool hit3 = false
                for j = 0 to confN - 1
                    float yj = array.get(confY, j)
                    if math.abs(yj - yi) <= confTolAbs
                        int tfId = array.get(confTfId, j)
                        hit1 := hit1 or tfId == 1
                        hit2 := hit2 or tfId == 2
                        hit3 := hit3 or tfId == 3
                int distinct = (hit1 ? 1 : 0) + (hit2 ? 1 : 0) + (hit3 ? 1 : 0)
                int score = (hit1 ? cfW1 : 0) + (hit2 ? cfW2 : 0) + (hit3 ? cfW3 : 0)
                bool duplicate = false
                int dn = array.size(drawnClusters)
                if dn > 0
                    for k = 0 to dn - 1
                        duplicate := duplicate or math.abs(array.get(drawnClusters, k) - yi) <= confTolAbs
                if distinct >= confMinTfs and not duplicate
                    array.push(drawnClusters, yi)
                    color hc = f_confColor(score, distinct, confMaxScore)
                    float q = confMaxScore > 0 ? float(score) / float(confMaxScore) : 0.0
                    int hw = q >= 0.80 ? 2 : 1
                    int cx1 = time + 2 * barMs
                    int cx2 = time + math.max(8, extendR) * barMs
                    array.push(rLn, line.new(cx1, yi, cx2, yi, xloc = xloc.bar_time, color = color.new(hc, 35), width = hw, style = line.style_dashed))
                    array.push(rLb, label.new(cx2, yi, "CONF " + str.tostring(score) + "/" + str.tostring(confMaxScore) + " · " + str.tostring(distinct) + "TF", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(BGD, 100), textcolor = hc, size = size.tiny))

        // Live structural retracement.
        if showLive and not na(liveRet)
            float pct = liveRet * 100.0
            color rc = positionState == "GOLDEN POCKET" ? cGold : positionState == "OTE" ? cGold2 : cAccent
            array.push(rLb, label.new(time + barMs, close, "◆ " + str.tostring(pct, "#.#") + "% · " + positionState, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(BGD, 15), textcolor = rc, size = size.small))

// ─────────────────────────────────────────────────────────────────────────────
// INSTITUTIONAL DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
var table tb = table.new(f_dashPos(dashPos), 2, 15, bgcolor = pBg, border_width = 1, border_color = pBorder)

if barstate.islast
    if showDash
        string ts = dashSize
        float leg = na(aP) or na(bP) ? na : bP - aP
        bool up = dir == 1
        float nextUp = na
        float nextDn = na

        if not na(aP) and not na(bP)
            float lv618 = f_retraceAt(0.618)
            float lv500 = f_retraceAt(0.500)
            float lv786 = f_retraceAt(0.786)
            float lvX1 = f_extendBeyond(1.272)
            float lvX2 = f_extendBeyond(1.618)
            float[] levels = array.from(lv618, lv500, lv786, lvX1, lvX2, aP, bP)
            for i = 0 to array.size(levels) - 1
                float lv = array.get(levels, i)
                if not na(lv) and lv > close and (na(nextUp) or lv < nextUp)
                    nextUp := lv
                if not na(lv) and lv < close and (na(nextDn) or lv > nextDn)
                    nextDn := lv

        color dirColor = na(leg) ? pMuted : up ? pBull : pBear
        color posColor = positionState == "GOLDEN POCKET" ? pGold : positionState == "OTE" ? pGold : positionState == "EQUILIBRIUM" ? pBlue : pNeutral
        color alignColor = trendAligned ? pBull : pBear
        string sourceTxt = useHtf ? "HTF " + htfTf : "CHART " + timeframe.period
        string dirTxt = na(leg) ? "—" : up ? "BULLISH" : "BEARISH"
        string trendTxt = na(structureEma) ? "—" : trendAligned ? "ALIGNED" : "DIVERGENT"
        string confTxt = confValidTfCount < confMinTfs ? "TF CONFIG" : f_confText(confBestScore, confBestTfs, confMaxScore)

        table.cell(tb, 0, 0, "AUTO FIBONACCI", text_color = pText, text_size = f_txtSize(ts), bgcolor = pHeader)
        table.cell(tb, 1, 0, "INSTITUTIONAL", text_color = pGold, text_size = size.tiny, bgcolor = pHeader)

        table.cell(tb, 0, 1, "STRUCTURAL LEG", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 1, dirTxt, text_color = dirColor, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 2, "ANCHOR", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 2, sourceTxt, text_color = pNeutral, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 3, "A → B RANGE", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 3, na(leg) ? "—" : str.tostring(math.abs(leg), format.mintick), text_color = pText, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 4, "LEG / ATR", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 4, na(leg) or na(structureAtr) or structureAtr == 0 ? "—" : str.tostring(math.abs(leg) / structureAtr, "#.##") + "x", text_color = pNeutral, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 5, "RETRACEMENT", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 5, na(liveRet) ? "—" : str.tostring(liveRet * 100.0, "#.#") + "%", text_color = posColor, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 6, "POSITION", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 6, positionState, text_color = posColor, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 7, "TREND CONTEXT", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 7, trendTxt, text_color = alignColor, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 8, "EQUILIBRIUM 0.500", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 8, na(aP) or na(bP) ? "—" : str.tostring(f_retraceAt(0.500), format.mintick), text_color = pBlue, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 9, "GOLDEN 0.618", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 9, na(aP) or na(bP) ? "—" : str.tostring(f_retraceAt(0.618), format.mintick), text_color = pGold, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 10, "EXTENSION 1.618", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 10, na(aP) or na(bP) ? "—" : str.tostring(f_extendBeyond(1.618), format.mintick), text_color = pGold, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 11, "UPSIDE LEVEL", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 11, na(nextUp) ? "—" : str.tostring(nextUp, format.mintick) + "  +" + str.tostring((nextUp / close - 1.0) * 100.0, "#.##") + "%", text_color = pBull, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 12, "DOWNSIDE LEVEL", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 12, na(nextDn) ? "—" : str.tostring(nextDn, format.mintick) + "  -" + str.tostring((1.0 - nextDn / close) * 100.0, "#.##") + "%", text_color = pBear, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 13, "HTF CONFLUENCE", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 13, showConf ? confTxt + (confBestTfs >= confMinTfs ? "  " + str.tostring(confBestScore) + "/" + str.tostring(confMaxScore) : "") : "OFF", text_color = showConf ? (confValidTfCount < confMinTfs ? pBear : f_confColor(confBestScore, confBestTfs, confMaxScore)) : pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 14, "DATA STATE", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 14, "CONFIRMED", text_color = pBull, text_size = size.tiny, bgcolor = pCell)
    else
        table.clear(tb, 0, 0, 1, 14)

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRMED ALERT EVENTS + HIDDEN OUTPUTS
// ─────────────────────────────────────────────────────────────────────────────
float lv618Series = not na(aP) and not na(bP) ? f_retraceAt(0.618) : na
float lv500Series = not na(aP) and not na(bP) ? f_retraceAt(0.500) : na
float lvExtSeries = not na(aP) and not na(bP) ? f_extendBeyond(1.618) : na

bool rawCross618 = ta.cross(close, lv618Series)
bool rawCross500 = ta.cross(close, lv500Series)
bool rawCrossExt = ta.cross(close, lvExtSeries)

bool inPocket = not na(aP) and not na(bP) and close <= math.max(f_retraceAt(0.618), f_retraceAt(0.650)) and close >= math.min(f_retraceAt(0.618), f_retraceAt(0.650))
bool enteredPocket = inPocket and not inPocket[1]

bool cross618 = barstate.isconfirmed and rawCross618
bool cross500 = barstate.isconfirmed and rawCross500
bool crossExt = barstate.isconfirmed and rawCrossExt
bool pocketEntry = barstate.isconfirmed and enteredPocket

alertcondition(cross618, "Price crossed 0.618 (Golden)", "AUTO FIB: confirmed close event crossed the 0.618 golden retracement.")
alertcondition(cross500, "Price crossed 0.500", "AUTO FIB: confirmed close event crossed the 0.500 equilibrium.")
alertcondition(crossExt, "Price crossed 1.618 extension", "AUTO FIB: confirmed close event crossed the 1.618 extension.")
alertcondition(pocketEntry, "Price entered Golden Pocket", "AUTO FIB: confirmed close entered the 0.618–0.650 golden pocket.")

plot(lv618Series, "Golden 0.618", display = display.none)
plot(lv500Series, "Eq 0.500", display = display.none)
plot(lvExtSeries, "Ext 1.618", display = display.none)
plot(liveRet, "Live Retrace %", display = display.none)
plot(showConf and confBestTfs >= confMinTfs ? confBestY : na, "Best HTF Confluence", display = display.none)
````
