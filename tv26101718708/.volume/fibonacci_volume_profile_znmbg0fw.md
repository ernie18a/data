# Fibonacci Volume Profile

- url: https://www.tradingview.com/script/zNmbG0Fw-Fibonacci-Volume-Profile/
- type: indicator
- pine_id: PUB;b0457d7b647d40d0821c37b59bee560d
- version: 1.0

## Description

fibonacci volume profile — institutional edition v2

fibonacci volume profile is a chart-based volume profile tool designed to combine volume structure, fibonacci levels, poc, vah, val, bull/bear volume split, merged poc clusters, confluence detection, global heatmap zones and live volume profile gauges in one visual workspace.

the goal of this tool is to help traders understand where volume is concentrated, where price is reacting, and where important structural levels may exist on the chart.

this indicator is not a buy or sell system. it is a market structure and volume analysis tool. it helps the user read the chart with more context before making a trading decision.

main concept

volume profile shows where volume has traded inside a selected price range.

instead of only looking at candles, this tool studies how volume is distributed across price levels. areas with high volume can act as important reaction zones because many market participants traded there. areas with lower volume can sometimes show thinner zones where price may move faster.

the script builds volume profiles using different trigger modes:

fixed bars

session

manual period

each profile displays volume rows, poc, value area, fibonacci levels and optional advanced modules.

how the volume profile works

each volume profile divides the selected range into several price rows.

for every row, the script estimates how much volume traded there.

the row with the highest volume becomes the poc.

the value area contains the main part of traded volume, based on the selected value area percentage.

vah is the upper limit of the value area.

val is the lower limit of the value area.

poc, vah and val are often used by traders as reference levels for reaction, acceptance, rejection, balance and imbalance.

important levels

poc

poc means point of control. it is the price level with the highest volume inside the profile.

a poc can act as a magnet when price returns to it. it can also become a reaction level if price rejects it.

vah

vah means value area high. it marks the upper boundary of the value area.

price above vah can show strength or expansion away from value.

price rejecting vah can show that buyers failed to accept higher prices.

val

val means value area low. it marks the lower boundary of the value area.

price below val can show weakness or expansion away from value.

price rejecting val can show that sellers failed to accept lower prices.

fibonacci module

the script can draw fibonacci levels from the selected volume profile structure.

the anchor can be based on:

vp range

vah to val

poc to range

the fibonacci direction can be automatic or manually selected.

automatic direction uses the dominant bull or bear volume logic to decide whether the fibonacci should be drawn from low to high or from high to low.

this makes the fibonacci module connected to the volume profile context instead of being only a manual drawing tool.

bull and bear volume split

the profile can separate estimated bullish and bearish volume.

this helps identify whether volume inside the profile is more aggressive on the buy side or the sell side.

the delta method can be selected from several modes:

bar direction

range position

body weighted

wick absorption

hybrid pro

this does not represent real bid and ask order flow. it is an estimation based on candle behavior and volume distribution.

merged poc module

when several poc levels are close together, the script can merge them into a cleaner cluster.

this helps reduce chart noise and makes repeated high-volume zones easier to read.

a merged poc cluster can show that several profiles agree around the same price area.

when multiple poc levels cluster near the same zone, that level can become more important for future analysis.

confluence detector

the true confluence detector looks for clusters between different level types.

it can combine:

poc

vah

val

fibonacci levels

multiple profiles

the idea is to identify zones where several independent references are close to each other.

a confluence zone is not a guaranteed reversal point. it is a zone where the chart deserves more attention.

global heatmap

the global heatmap aggregates visible volume profiles into one heatmap zone on the right side of the chart.

this gives a broader view of where volume is concentrated across all visible profiles.

the global heatmap can help identify larger high-volume areas and thinner zones.

live vp gauges panel

the live vp gauges panel shows live information about the current developing volume profile.

it includes readings such as:

buy pressure

sell pressure

net delta estimate

value area position

distance to poc

distance to vah

distance to val

current row pressure

last bar pressure

close location inside the vp range

this panel is not an order book. it does not use bid and ask data. it is based on the current volume profile structure.

dashboard

the dashboard gives a quick summary of the current mode and important status information.

it can show:

current vp mode

number of stored profiles

nearest poc

distance to nearest poc

fibonacci status

poc merge status

value area extension status

confluence status

global heatmap status

poc touch alert

the script includes a poc touch alert.

this alert can help notify when price reaches a stored poc level.

a poc touch does not mean immediate entry. it only means price has reached an important volume reference level.

how to use the tool

step 1: choose the vp mode

fixed bars creates a new profile every selected number of bars.

session creates profiles based on the selected session.

manual period builds a live profile from a fixed manual number of bars.

beginners can start with fixed bars because it is simple and stable.

step 2: choose the number of rows

rows per vp controls how detailed the volume profile is.

more rows give more precision but can make the chart heavier.

fewer rows give a cleaner view but less detail.

a balanced setting is usually better for beginners.

step 3: read poc, vah and val

start by locating the poc.

then look at vah and val.

ask three simple questions:

is price above value?

is price below value?

is price inside value?

this gives a basic market context.

step 4: check reaction zones

watch how price behaves when it reaches poc, vah, val, fibonacci levels or merged poc clusters.

a strong reaction can show rejection.

a slow move through the level can show acceptance.

a clean breakout can show expansion away from value.

step 5: confirm with price action

do not trade only because price touches a level.

wait for confirmation such as:

market structure shift

rejection candle

break and retest

support or resistance reaction

volume confirmation

trend confirmation

example 1: price returns to poc

price moves away from a profile and later returns to the poc.

this can be a magnet zone because the poc is the highest volume level of that profile.

a beginner can watch if price accepts the poc or rejects it.

if price holds above poc after a retest, it may show support behavior.

if price rejects below poc, it may show resistance behavior.

example 2: rejection at vah

price moves up into vah and fails to stay above it.

this can show that higher prices are not accepted.

a trader can then look for bearish confirmation on the normal price chart.

the level itself is only a reference. confirmation is still required.

example 3: reaction at val

price drops into val and quickly rejects lower prices.

this can show that sellers failed to push price below value.

a trader can then look for bullish confirmation before considering a long setup.

example 4: merged poc cluster

several poc levels appear close to each other and the script merges them.

this creates a cleaner high-volume cluster.

if price returns to that cluster, it can become an important decision zone.

a beginner should watch whether price bounces, consolidates, or breaks through the cluster.

example 5: confluence zone

a poc, a fibonacci level and a value area boundary appear near the same price.

the confluence detector can highlight this type of zone.

this does not predict the future, but it helps the trader focus on areas where several references agree.

example 6: global heatmap

the global heatmap shows a strong high-volume area on the right side of the chart.

if price trades near this zone, it may slow down, react or consolidate.

if price moves through a low-volume zone, it may move faster.

beginner trading workflow

first, identify the current trend on the main chart.

then, check where price is compared to the nearest poc.

next, look at vah and val.

then, check if there is a merged poc cluster or confluence zone nearby.

after that, wait for price action confirmation.

finally, define risk before entering any trade.

a simple beginner rule is:

do not enter just because a level appears.

wait for price to react.

wait for confirmation.

protect the trade with a clear invalidation level.

best use cases

volume profile analysis

poc reaction zones

value area reading

fibonacci confluence

session profile analysis

fixed range profile analysis

support and resistance context

market balance and imbalance reading

high-volume and low-volume zone detection

beginner-friendly structure analysis

settings overview

vp trigger

selects how the profile is created.

fixed bars builds profiles after a fixed number of bars.

session builds profiles around selected market sessions.

manual period builds a profile from a manual number of bars.

bars per vp

controls how many bars are used before a new fixed profile is created.

manual period bars

controls the number of bars used for the manual live profile.

max vp visible

controls how many profiles remain visible on the chart.

rows per vp

controls the number of price rows inside each profile.

value area percentage

controls how much of the profile volume is included inside the value area.

vp width percentage

controls the visual width of each profile.

show fibonacci

enables or disables fibonacci levels.

anchor type

selects what structure is used to anchor fibonacci levels.

fib direction

selects automatic or manual fibonacci direction.

show poc

shows or hides the point of control.

show vah and val

shows or hides value area high and value area low.

extend poc right

extends poc levels to the right side of the chart.

merge close poc lines

merges close poc levels into cleaner clusters.

bull and bear split

shows estimated bullish and bearish volume separately.

delta method

selects how bullish and bearish volume is estimated.

global heatmap

shows an aggregated heatmap from visible profiles.

true confluence detector

detects zones where several important levels cluster together.

live vp gauges panel

shows live pressure and distance readings from the developing profile.

dashboard

shows a compact status panel with useful script information.

risk note

this indicator is designed for technical analysis and education. it does not give financial advice and does not guarantee results. levels, profiles, gauges, heatmaps and alerts are references only. always use risk management and confirm every setup with your own analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
// ============================================================================
// FIBONACCI VOLUME PROFILE — INSTITUTIONAL EDITION v2
// ============================================================================
indicator("Fibonacci Volume Profile", "FIB-VP v2", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 2000)
const int MAX_BUILD_BARS_SAFE = 1500
max_bars_back(open, MAX_BUILD_BARS_SAFE + 5)
max_bars_back(high, MAX_BUILD_BARS_SAFE + 5)
max_bars_back(low, MAX_BUILD_BARS_SAFE + 5)
max_bars_back(close, MAX_BUILD_BARS_SAFE + 5)
max_bars_back(volume, MAX_BUILD_BARS_SAFE + 5)

// ============================ INPUTS — VP ENGINE ============================
g0          = "VP ENGINE"
vpMode      = input.string("Fixed Bars", "VP Trigger", options = ["Fixed Bars", "Session", "Manual Period"], group = g0, tooltip = "Fixed Bars : nouveau VP tous les N bars / Session : un VP par session / Manual : période en bars fixe")
vpBars      = input.int(100, "Bars Per VP",       minval = 20, maxval = 1000, group = g0)
manualBars  = input.int(250, "Manual Period Bars", minval = 20, maxval = 1500, group = g0)
maxVP       = input.int(6, "Max VP Visible",      minval = 2, maxval = 12, group = g0)
nRows       = input.int(36, "Rows per VP",        minval = 12, maxval = 100, group = g0)
valuePct    = input.float(70.0, "Value Area %",   minval = 50, maxval = 90, step = 1, group = g0)
widthPct    = input.float(18, "VP Width %",       minval = 5, maxval = 50, step = 1, group = g0)

// ============================ INPUTS — SESSION ==============================
g1          = "SESSION CONFIG"
sessionTz   = input.string("Etc/UTC", "Session Timezone", group = g1)
sessionPick = input.string("New York", "Session", options = ["Asia", "London", "New York", "All Sessions"], group = g1)

// ============================ INPUTS — FIB LEVELS ===========================
g2          = "FIBONACCI LEVELS"
showFib     = input.bool(true, "Show Fibonacci", group = g2)
fibAnchor   = input.string("VP Range", "Anchor Type", options = ["VP Range", "VAH-VAL", "POC-Range"], group = g2)
fibDirection = input.string("Auto", "Fib Direction", options = ["Auto", "Low to High", "High to Low"], group = g2, tooltip = "Auto : Low→High si delta bull dominant, High→Low si delta bear dominant. Permet de tracer le Fib dans les deux sens.")
fibAutoExtend = input.bool(true, "Auto Extend + Freeze", group = g2, tooltip = "Le Fib live s'étend à droite. Les Fibs historiques se figent avant le VP suivant.")
fib_000     = input.bool(true,  "0.000", group = g2, inline = "f0")
fib_236     = input.bool(true,  "0.236", group = g2, inline = "f1")
fib_382     = input.bool(true,  "0.382", group = g2, inline = "f1")
fib_500     = input.bool(true,  "0.500", group = g2, inline = "f2")
fib_618     = input.bool(true,  "0.618", group = g2, inline = "f2")
fib_786     = input.bool(true,  "0.786", group = g2, inline = "f3")
fib_886     = input.bool(false, "0.886", group = g2, inline = "f3")
fibStyle    = input.string("Solid", "Fib Line Style", options = ["Solid", "Dashed", "Dotted"], group = g2)
showFibLbl  = input.bool(true, "Fib Labels",   group = g2)

// ============================ INPUTS — POC/VA ===============================
g4         = "POC / VA STYLE"
showPoc    = input.bool(true, "Show POC",          group = g4)
showVa     = input.bool(true, "Show VAH/VAL",      group = g4)
extendPoc  = input.bool(true, "Extend POC Right",  group = g4)
mergePoc   = input.bool(true, "Merge Close POC Lines + Labels", group = g4, tooltip = "Fusionne réellement les lignes et labels POC proches. Le prix du cluster conserve le POC le plus récent.")
pocMergeMode = input.string("Hybrid", "POC Merge Mode", options = ["Ticks", "Percent", "ATR", "Price", "Hybrid", "All Visible"], group = g4, tooltip = "All Visible fusionne tous les POC visibles dans une seule ligne/label au POC le plus récent. Hybrid utilise la plus grande tolérance entre ticks, %, ATR et prix absolu.")
pocMergeTicks = input.int(50, "POC Merge Tolerance (ticks)", minval = 0, maxval = 100000, group = g4)
pocMergePct = input.float(0.15, "POC Merge Tolerance %", minval = 0.00, maxval = 10.00, step = 0.01, group = g4)
pocMergeAtr = input.float(0.25, "POC Merge Tolerance ATR", minval = 0.00, maxval = 10.00, step = 0.01, group = g4)
pocMergePrice = input.float(0.0, "POC Merge Tolerance Price", minval = 0.0, step = 0.1, group = g4, tooltip = "Tolérance directe en points/prix. Utile sur BTC, NASDAQ, DAX, indices, etc.")
pocWidth   = input.int(2, "POC Line Width",        minval = 1, maxval = 4, group = g4)
extendVa   = input.bool(true, "Auto Extend VAH/VAL + Freeze", group = g4)
showVaLbl  = input.bool(true, "VAH/VAL Labels", group = g4)
vaLblOffset = input.int(15, "VA Label Offset After Fib", minval = 4, maxval = 40, group = g4)

// ============================ INPUTS — BULL/BEAR ============================
g5         = "BULL/BEAR SPLIT"
showSplit  = input.bool(true, "Split Bull/Bear",   group = g5)
deltaMode  = input.string("Bar Direction", "Delta Method", options = ["Bar Direction", "Range Position", "Body Weighted", "Wick Absorption", "Hybrid Pro"], group = g5)

// ============================ INPUTS — STYLE ================================
g6           = "AESTHETIC"
heatStyle    = input.string("Thermal", "Color Palette", options = ["Thermal", "Plasma", "Ice Fire", "Mono Cyan", "Mono Gold"], group = g6)
opacityBase  = input.float(0.75, "Base Opacity",   minval = 0.2, maxval = 1.5, step = 0.05, group = g6)
ageFade      = input.bool(true,  "Fade With Age",  group = g6)
glowEffect   = input.bool(true,  "Glow Effect",    group = g6)
showLabels   = input.bool(true,  "VP Labels",      group = g6)
showDash     = input.bool(true,  "Dashboard",      group = g6)

// ============================ INPUTS — ADVANCED MODES =======================
g7            = "ADVANCED MODES"
// 1) Confluence Detector
confDetect    = input.bool(false, "▸ True Confluence Detector", group = g7, tooltip = "Confluence validée uniquement par clusters multi-sources : plusieurs VPs et plusieurs types de niveaux.")
confMin       = input.int(3, "Min Levels for Confluence", minval = 2, maxval = 12, group = g7)
confMinVps    = input.int(2, "Min Unique VPs", minval = 1, maxval = 8, group = g7)
confMinTypes  = input.int(2, "Min Unique Level Types", minval = 1, maxval = 5, group = g7)
confTolPct    = input.float(0.20, "Confluence Tolerance %", minval = 0.01, maxval = 1.0, step = 0.01, group = g7)
confTolTicks  = input.int(20, "Confluence Tolerance Ticks", minval = 1, maxval = 500, group = g7)
confTolAtr    = input.float(0.10, "Confluence Tolerance ATR", minval = 0.01, maxval = 1.00, step = 0.01, group = g7)
confTolMode   = input.string("Hybrid", "Confluence Tolerance Mode", options = ["Percent", "Ticks", "ATR", "Hybrid"], group = g7)

// 2) Global Heatmap
globalHeat    = input.bool(true, "▸ Global Heatmap",          group = g7, tooltip = "Agrège tous les VPs visibles en une heatmap unique sur le bord droit du chart")
heatRes       = input.int(72,   "Heatmap Resolution",          minval = 24, maxval = 200, group = g7)
heatWidth     = input.int(20,   "Heatmap Width (bars)",        minval = 3, maxval = 30, group = g7)
heatOffset    = input.int(75,   "Heatmap Right Offset",        minval = 10, maxval = 100, group = g7)

// 3) Live VP Gauges Panel — PAS un orderbook. Jauges live dérivées du VP en formation. Aucun bid/ask, aucun appel 1T.
g8              = "LIVE VP GAUGES PANEL"
showLiveGauges  = input.bool(true, "▸ Live VP Gauges Panel", group = g8, tooltip = "Jauges live basées sur le VP en formation. Ce n'est pas un carnet d'ordres. Aucun bid/ask et aucun appel 1T, donc pas d'erreur de plan Expert+." )
liveGaugePos    = input.string("Bottom Right", "Panel Corner", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = g8)
liveGaugeRows   = input.string("Full", "Panel Detail", options = ["Compact", "Full"], group = g8)
liveGaugeRef    = input.string("Value Area", "Distance Reference", options = ["Value Area", "VP Range", "ATR"], group = g8)

// ============================ PALETTES ======================================
f_palBull(int stop) =>
    color c = #00E676
    if heatStyle == "Thermal"
        c := stop == 0 ? #1B5E20 : stop == 1 ? #2E7D32 : stop == 2 ? #66BB6A : stop == 3 ? #FFEB3B : #FF6F00
    else if heatStyle == "Plasma"
        c := stop == 0 ? #4A148C : stop == 1 ? #6A1B9A : stop == 2 ? #C77DFF : stop == 3 ? #FF6EC7 : #FF006E
    else if heatStyle == "Ice Fire"
        c := stop == 0 ? #003566 : stop == 1 ? #0077B6 : stop == 2 ? #00B4D8 : stop == 3 ? #FFA500 : #FF4500
    else if heatStyle == "Mono Cyan"
        c := stop == 0 ? #004D5C : stop == 1 ? #006978 : stop == 2 ? #00838F : stop == 3 ? #0097A7 : #00BCD4
    else
        c := stop == 0 ? #4E342E : stop == 1 ? #6D4C41 : stop == 2 ? #8D6E63 : stop == 3 ? #D7B48E : #FFD54F
    c

f_palBear(int stop) =>
    color c = #FF1744
    if heatStyle == "Thermal"
        c := stop == 0 ? #4A0E0E : stop == 1 ? #8E1717 : stop == 2 ? #C62828 : stop == 3 ? #E91E63 : #FF1744
    else if heatStyle == "Plasma"
        c := stop == 0 ? #311B92 : stop == 1 ? #4527A0 : stop == 2 ? #5E35B1 : stop == 3 ? #7E57C2 : #9575CD
    else if heatStyle == "Ice Fire"
        c := stop == 0 ? #1A237E : stop == 1 ? #283593 : stop == 2 ? #3949AB : stop == 3 ? #5C6BC0 : #7986CB
    else if heatStyle == "Mono Cyan"
        c := stop == 0 ? #263238 : stop == 1 ? #37474F : stop == 2 ? #455A64 : stop == 3 ? #546E7A : #607D8B
    else
        c := stop == 0 ? #3E2723 : stop == 1 ? #4E342E : stop == 2 ? #5D4037 : stop == 3 ? #6D4C41 : #795548
    c

colPoc    = heatStyle == "Mono Gold" ? #FFD700 : heatStyle == "Mono Cyan" ? #00E5FF : heatStyle == "Plasma" ? #FF6EC7 : heatStyle == "Ice Fire" ? #FFFFFF : #FFEB3B
colVA     = heatStyle == "Mono Gold" ? #B8860B : heatStyle == "Mono Cyan" ? #00ACC1 : heatStyle == "Plasma" ? #9C27B0 : #29B6F6
colFib    = heatStyle == "Mono Gold" ? #DAA520 : heatStyle == "Mono Cyan" ? #4DD0E1 : heatStyle == "Plasma" ? #E040FB : #FFB74D
colPower  = #FFD700
colConfHi = #FF6EC7
colText   = #ECEFF1
colDim    = #607D8B

atr14 = ta.atr(14)
volSma50 = ta.sma(volume, 50)

// ============================ TYPES =========================================
type VolumeProfile
    int   startBar
    int   endBar
    float hi
    float lo
    float pocPrice
    float vahPrice
    float valPrice
    float pocVol
    float totalVol
    float bullVol
    float bearVol
    float powerScore
    array<float> rowsTotal
    array<float> rowsBull
    array<float> rowsBear

// ============================ STORAGE =======================================
var array<VolumeProfile> vpList = array.new<VolumeProfile>()
var array<box>      allBoxes  = array.new<box>()
var array<line>     allLines  = array.new<line>()
var array<label>    allLabels = array.new<label>()
var array<linefill> allFills  = array.new<linefill>()

// ============================ SESSION DETECTION =============================
f_minOfDay(int i) =>
    hour(time[i], sessionTz) * 60 + minute(time[i], sessionTz)

f_inSess(int m) =>
    bool s = false
    if sessionPick == "Asia"
        s := m >= 0 and m < 360
    else if sessionPick == "London"
        s := m >= 420 and m < 660
    else if sessionPick == "New York"
        s := m >= 810 and m < 1260
    else
        s := true
    s

curMin = f_minOfDay(0)
inSessionNow = f_inSess(curMin)
inSessionPrev = f_inSess(f_minOfDay(1))

var int currentVPStart = bar_index
sessionStart = vpMode == "Session" and inSessionNow and not inSessionPrev
sessionEnd   = vpMode == "Session" and not inSessionNow and inSessionPrev
fixedBarsTrigger = vpMode == "Fixed Bars" and bar_index > 0 and (bar_index - currentVPStart) >= vpBars
manualTrigger = false

newVPTrigger = (sessionEnd or fixedBarsTrigger) and bar_index > 0
if sessionStart
    currentVPStart := bar_index

// ============================ FIB HELPER ====================================
f_fibLevel(float anchor, float endP, float ratio) =>
    anchor + (endP - anchor) * ratio

f_clamp(float x, float lo_, float hi_) =>
    math.max(math.min(x, hi_), lo_)

f_bullShare(float o, float h, float l, float c) =>
    float r = math.max(h - l, syminfo.mintick)
    float body = math.abs(c - o)
    float bodyDir = c > o ? 1.0 : c < o ? 0.0 : 0.5
    float closeLoc = f_clamp((c - l) / r, 0.0, 1.0)
    float upperW = h - math.max(o, c)
    float lowerW = math.min(o, c) - l
    float wickBias = f_clamp(0.5 + (lowerW - upperW) / r, 0.0, 1.0)
    float bodyWeight = f_clamp(body / r, 0.0, 1.0)
    float s = 0.5
    if deltaMode == "Bar Direction"
        s := bodyDir
    else if deltaMode == "Range Position"
        s := closeLoc
    else if deltaMode == "Body Weighted"
        s := f_clamp(closeLoc * 0.45 + bodyDir * 0.45 + bodyWeight * 0.10, 0.0, 1.0)
    else if deltaMode == "Wick Absorption"
        s := wickBias
    else
        s := f_clamp(closeLoc * 0.40 + bodyDir * 0.30 + wickBias * 0.20 + bodyWeight * 0.10, 0.0, 1.0)
    s

f_fibIsUp(VolumeProfile vp) =>
    fibDirection == "Low to High" ? true : fibDirection == "High to Low" ? false : vp.bullVol >= vp.bearVol

f_fibAnchorA(VolumeProfile vp) =>
    bool up = f_fibIsUp(vp)
    float a = vp.lo
    if fibAnchor == "VAH-VAL"
        a := up ? vp.valPrice : vp.vahPrice
    else if fibAnchor == "POC-Range"
        a := vp.pocPrice
    else
        a := up ? vp.lo : vp.hi
    a

f_fibAnchorB(VolumeProfile vp) =>
    bool up = f_fibIsUp(vp)
    float b = vp.hi
    if fibAnchor == "VAH-VAL"
        b := up ? vp.vahPrice : vp.valPrice
    else if fibAnchor == "POC-Range"
        b := up ? vp.hi : vp.lo
    else
        b := up ? vp.hi : vp.lo
    b

f_vpBars(VolumeProfile vp) =>
    vp.endBar - vp.startBar + 1

f_vpWidth(VolumeProfile vp) =>
    int(math.max(f_vpBars(vp) * widthPct / 100, 3))

f_vpMidBar(VolumeProfile vp) =>
    vp.startBar + int(f_vpBars(vp) / 2)

f_vpRightBar(VolumeProfile vp) =>
    f_vpMidBar(vp) + int(f_vpWidth(vp) / 2)

f_vpLeftBar(VolumeProfile vp) =>
    f_vpMidBar(vp) - int(f_vpWidth(vp) / 2)

f_vpStep(VolumeProfile vp) =>
    math.max(vp.hi - vp.lo, syminfo.mintick * nRows) / nRows

f_baseTransp(int vpIndex, int totalShown) =>
    float ageRatio = totalShown > 1 ? float(vpIndex) / float(totalShown - 1) : 0.0
    float opacMult = ageFade ? math.max(opacityBase * (1.0 - ageRatio * 0.55), 0.25) : opacityBase
    int(math.max(85 - opacMult * 50, 35))

f_freezeEnd(int vpIndex, int midBar, int fallbackEnd, int rightExtend, int nextStart, bool doAuto) =>
    int out = fallbackEnd
    if doAuto
        if vpIndex == 0
            out := rightExtend
        else
            out := na(nextStart) ? fallbackEnd : nextStart - 1
    math.max(midBar + 1, out)

f_hasInt(array<int> a, int v) =>
    bool found = false
    if array.size(a) > 0
        for i = 0 to array.size(a) - 1
            if array.get(a, i) == v
                found := true
                break
    found

f_confTol() =>
    float pctTol = close * confTolPct / 100.0
    float tickTol = syminfo.mintick * confTolTicks
    float atrTol = nz(atr14, syminfo.mintick * 100.0) * confTolAtr
    confTolMode == "Percent" ? pctTol : confTolMode == "Ticks" ? tickTol : confTolMode == "ATR" ? atrTol : math.max(math.max(pctTol, tickTol), atrTol)

f_pocMergeTol() =>
    float tickTol = syminfo.mintick * pocMergeTicks
    float pctTol = close * pocMergePct / 100.0
    float atrTol = nz(atr14, syminfo.mintick * 100.0) * pocMergeAtr
    float priceTol = pocMergePrice
    float tol = tickTol
    if pocMergeMode == "Percent"
        tol := pctTol
    else if pocMergeMode == "ATR"
        tol := atrTol
    else if pocMergeMode == "Price"
        tol := priceTol
    else if pocMergeMode == "Hybrid"
        tol := math.max(math.max(tickTol, pctTol), math.max(atrTol, priceTol))
    else if pocMergeMode == "All Visible"
        tol := 10e10
    tol

f_buildVPFromRange(int startBar, int endBar) =>
    int safeEnd = math.min(endBar, bar_index)
    int safeStart = math.max(startBar, safeEnd - MAX_BUILD_BARS_SAFE + 1)
    int barsCount = safeEnd - safeStart + 1
    if barsCount < 5
        VolumeProfile vp = VolumeProfile.new(safeStart, safeEnd, na, na, na, na, na, na, na, na, na, na, array.new_float(nRows, 0.0), array.new_float(nRows, 0.0), array.new_float(nRows, 0.0))
        vp
    else
        float hi = high[bar_index - safeEnd]
        float lo = low[bar_index - safeEnd]
        for i = 0 to barsCount - 1
            int idx = bar_index - safeEnd + i
            if high[idx] > hi
                hi := high[idx]
            if low[idx] < lo
                lo := low[idx]

        float range_ = math.max(hi - lo, syminfo.mintick * nRows)
        float step = range_ / nRows

        array<float> tot  = array.new_float(nRows, 0.0)
        array<float> bull = array.new_float(nRows, 0.0)
        array<float> bear = array.new_float(nRows, 0.0)

        float bullTot = 0.0
        float bearTot = 0.0

        for i = 0 to barsCount - 1
            int idx = bar_index - safeEnd + i
            float barHi = high[idx]
            float barLo = low[idx]
            float barRange = math.max(barHi - barLo, syminfo.mintick)
            float v = nz(volume[idx], 0.0)

            float bullShare = f_bullShare(open[idx], barHi, barLo, close[idx])
            float bearShare = 1.0 - bullShare
            float vBull = v * bullShare
            float vBear = v * bearShare
            bullTot += vBull
            bearTot += vBear

            int rowLoIdx = int(math.floor((barLo - lo) / step))
            int rowHiIdx = int(math.floor((barHi - lo) / step))
            rowLoIdx := math.max(math.min(rowLoIdx, nRows - 1), 0)
            rowHiIdx := math.max(math.min(rowHiIdx, nRows - 1), 0)
            int spanned = rowHiIdx - rowLoIdx + 1
            float vPerBull = vBull / spanned
            float vPerBear = vBear / spanned

            for k = rowLoIdx to rowHiIdx
                array.set(bull, k, array.get(bull, k) + vPerBull)
                array.set(bear, k, array.get(bear, k) + vPerBear)
                array.set(tot,  k, array.get(tot,  k) + vPerBull + vPerBear)

        int pIdx = 0
        float maxV = array.get(tot, 0)
        for k = 1 to nRows - 1
            float v = array.get(tot, k)
            if v > maxV
                maxV := v
                pIdx := k
        float pocPrice = lo + (pIdx + 0.5) * step

        float totalV = 0.0
        for k = 0 to nRows - 1
            totalV += array.get(tot, k)

        float targetVol = totalV * valuePct / 100.0
        float accVol = maxV
        int vaHi = pIdx
        int vaLo = pIdx

        while accVol < targetVol and (vaHi < nRows - 1 or vaLo > 0)
            float volUp = vaHi < nRows - 1 ? array.get(tot, vaHi + 1) : -1.0
            float volDn = vaLo > 0 ? array.get(tot, vaLo - 1) : -1.0
            if volUp >= volDn and volUp >= 0
                vaHi += 1
                accVol += volUp
            else if volDn >= 0
                vaLo -= 1
                accVol += volDn
            else
                break

        float vahPrice = lo + (vaHi + 1) * step
        float valPrice = lo + vaLo * step

        // VP SCORE interne
        float concentration = totalV > 0 ? (maxV / totalV) * 100.0 : 0.0
        float concScore = math.min(concentration * 4.0, 35.0)

        float densScore = 0.0
        if barsCount > 0
            float volPerBar = totalV / barsCount
            float refVol = nz(volSma50, volPerBar)
            if refVol > 0
                densScore := math.min((volPerBar / refVol) * 15.0, 25.0)

        float vaRange = vahPrice - valPrice
        float compactScore = 0.0
        if range_ > 0
            float vaRatio = vaRange / range_
            compactScore := math.max((1.0 - vaRatio) * 25.0, 0.0)

        float deltaRatio = totalV > 0 ? math.abs(bullTot - bearTot) / totalV : 1.0
        float symmScore = (1.0 - deltaRatio) * 15.0

        float power = concScore + densScore + compactScore + symmScore
        power := math.min(math.max(power, 0.0), 100.0)

        VolumeProfile vp = VolumeProfile.new(safeStart, safeEnd, hi, lo, pocPrice, vahPrice, valPrice, maxV, totalV, bullTot, bearTot, power, tot, bull, bear)
        vp

// ============================ PRECOMPUTED SERIES CALLS ======================
int closedEndGlobal = math.max(bar_index - 1, 0)
VolumeProfile closedVPNow = f_buildVPFromRange(currentVPStart, closedEndGlobal)
pocMergeTolNow = f_pocMergeTol()
confTolNow = f_confTol()

// ============================ ON NEW VP =====================================
if newVPTrigger
    VolumeProfile newVP = closedVPNow
    if not na(newVP.pocPrice)
        array.unshift(vpList, newVP)
        int maxSize = maxVP
        while array.size(vpList) > maxSize
            array.pop(vpList)
    if fixedBarsTrigger
        currentVPStart := bar_index

int liveStartNow = vpMode == "Manual Period" ? math.max(bar_index - manualBars + 1, 0) : currentVPStart
VolumeProfile liveVPNow = f_buildVPFromRange(liveStartNow, bar_index)

// ============================ DRAW HELPERS ==================================
f_clearAll() =>
    if array.size(allBoxes) > 0
        for i = 0 to array.size(allBoxes) - 1
            box.delete(array.get(allBoxes, i))
        array.clear(allBoxes)
    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1
            line.delete(array.get(allLines, i))
        array.clear(allLines)
    if array.size(allLabels) > 0
        for i = 0 to array.size(allLabels) - 1
            label.delete(array.get(allLabels, i))
        array.clear(allLabels)
    if array.size(allFills) > 0
        for i = 0 to array.size(allFills) - 1
            linefill.delete(array.get(allFills, i))
        array.clear(allFills)

// ============================ DRAW SINGLE VP ================================
// ============================ DRAW SINGLE VP — BOXES LOCKED =================
f_drawVP(VolumeProfile vp, int vpIndex, int totalShown, int rightExtend, int nextStart) =>
    if not na(vp.pocPrice) and not na(vp.hi) and not na(vp.lo)
        int baseTransp = f_baseTransp(vpIndex, totalShown)
        int barsCount = f_vpBars(vp)
        int vpWidth = f_vpWidth(vp)
        int midBar = f_vpMidBar(vp)
        int rightBar = f_vpRightBar(vp)
        int leftBar = f_vpLeftBar(vp)
        float step = f_vpStep(vp)

        // --- Profile rows : géométrie originale conservée ---
        for k = 0 to nRows - 1
            float rowLo = vp.lo + k * step
            float rowHi = vp.lo + (k + 1) * step
            float vBull = array.get(vp.rowsBull, k)
            float vBear = array.get(vp.rowsBear, k)
            float vTot = vBull + vBear

            if vTot > 0 and vp.pocVol > 0
                float intensity = vTot / vp.pocVol
                int stop = intensity > 0.85 ? 4 : intensity > 0.65 ? 3 : intensity > 0.40 ? 2 : intensity > 0.20 ? 1 : 0
                int rowTransp = int(math.max(baseTransp - intensity * 30, 25))

                if showSplit
                    float bullWidth = (vBull / vp.pocVol) * (vpWidth / 2.0)
                    float bearWidth = (vBear / vp.pocVol) * (vpWidth / 2.0)
                    if bullWidth > 0.1
                        box bb = box.new(midBar, rowHi, midBar + int(bullWidth), rowLo, bgcolor = color.new(f_palBull(stop), rowTransp), border_color = color.new(f_palBull(stop), math.max(rowTransp - 5, 20)), border_width = 1)
                        array.push(allBoxes, bb)
                    if bearWidth > 0.1
                        box bb = box.new(midBar - int(bearWidth), rowHi, midBar, rowLo, bgcolor = color.new(f_palBear(stop), rowTransp), border_color = color.new(f_palBear(stop), math.max(rowTransp - 5, 20)), border_width = 1)
                        array.push(allBoxes, bb)
                else
                    bool bullDom = vBull > vBear
                    color c = bullDom ? f_palBull(stop) : f_palBear(stop)
                    float halfW = (vTot / vp.pocVol) * (vpWidth / 2.0)
                    box bb = box.new(midBar - int(halfW), rowHi, midBar + int(halfW), rowLo, bgcolor = color.new(c, rowTransp), border_color = color.new(c, math.max(rowTransp - 5, 20)), border_width = 1)
                    array.push(allBoxes, bb)

        int frozenEnd = f_freezeEnd(vpIndex, midBar, rightBar + 2, rightExtend, nextStart, fibAutoExtend)

        // --- VA lines + labels : extension auto/freeze, labels après Fib ---
        if showVa
            int vaEnd = f_freezeEnd(vpIndex, midBar, rightBar + 2, rightExtend, nextStart, extendVa)
            line vahL = line.new(leftBar, vp.vahPrice, vaEnd, vp.vahPrice, color = color.new(colVA, math.max(baseTransp - 10, 25)), width = 1, style = line.style_dashed)
            array.push(allLines, vahL)
            line valL = line.new(leftBar, vp.valPrice, vaEnd, vp.valPrice, color = color.new(colVA, math.max(baseTransp - 10, 25)), width = 1, style = line.style_dashed)
            array.push(allLines, valL)
            if showVaLbl
                int vaX = vaEnd + vaLblOffset
                label vahLbl = label.new(vaX, vp.vahPrice, "VAH " + str.tostring(vp.vahPrice, format.mintick), color = color.new(colVA, 78), textcolor = colText, size = size.tiny, style = label.style_label_left)
                array.push(allLabels, vahLbl)
                label valLbl = label.new(vaX, vp.valPrice, "VAL " + str.tostring(vp.valPrice, format.mintick), color = color.new(colVA, 78), textcolor = colText, size = size.tiny, style = label.style_label_left)
                array.push(allLabels, valLbl)

        // --- Fib lines : 0.000 inclus, direction Low→High ou High→Low, auto-extend/freeze ---
        if showFib
            float anchorA = f_fibAnchorA(vp)
            float anchorB = f_fibAnchorB(vp)
            fStyle = fibStyle == "Solid" ? line.style_solid : fibStyle == "Dashed" ? line.style_dashed : line.style_dotted
            array<float> fibRatios = array.from(0.000, 0.236, 0.382, 0.500, 0.618, 0.786, 0.886)
            array<bool> fibFlags = array.from(fib_000, fib_236, fib_382, fib_500, fib_618, fib_786, fib_886)
            for fi = 0 to array.size(fibRatios) - 1
                if array.get(fibFlags, fi)
                    float ratio = array.get(fibRatios, fi)
                    float p = f_fibLevel(anchorA, anchorB, ratio)
                    line fl = line.new(midBar, p, frozenEnd, p, color = color.new(colFib, math.max(baseTransp + 5, 30)), width = 1, style = fStyle)
                    array.push(allLines, fl)
                    if showFibLbl
                        label lbl_ = label.new(frozenEnd + 4, p, str.tostring(ratio, "#.000"), color = color.new(colFib, 80), textcolor = colText, size = size.tiny, style = label.style_label_left)
                        array.push(allLabels, lbl_)

        // --- VP label : mode filtrage supprimé, géométrie inchangée ---
        if showLabels
            string lblTxt = "VP" + str.tostring(vpIndex + 1)
            label vpLbl = label.new(midBar, vp.hi + step, lblTxt, color = color.new(colPoc, 50), textcolor = colText, size = size.tiny, style = label.style_label_down)
            array.push(allLabels, vpLbl)

// ============================ MERGED POC DRAW ===============================
f_drawMergedPocs(array<VolumeProfile> vps, int totalShown, int rightExtend) =>
    if showPoc and array.size(vps) > 0
        int n = array.size(vps)
        float tol = mergePoc ? pocMergeTolNow : 0.0
        array<bool> used = array.new_bool(n, false)
        for i = 0 to n - 1
            if not array.get(used, i)
                VolumeProfile anchorVp = array.get(vps, i)
                if not na(anchorVp.pocPrice)
                    float anchorPrice = anchorVp.pocPrice
                    float clusterLo = anchorPrice
                    float clusterHi = anchorPrice
                    array<bool> inCluster = array.new_bool(n, false)
                    array.set(inCluster, i, true)
                    bool changed = true
                    while changed
                        changed := false
                        for j = 0 to n - 1
                            if not array.get(used, j) and not array.get(inCluster, j)
                                VolumeProfile testVp = array.get(vps, j)
                                if not na(testVp.pocPrice)
                                    bool mergeNow = mergePoc and (pocMergeMode == "All Visible" or testVp.pocPrice >= clusterLo - tol and testVp.pocPrice <= clusterHi + tol)
                                    if mergeNow
                                        array.set(inCluster, j, true)
                                        clusterLo := math.min(clusterLo, testVp.pocPrice)
                                        clusterHi := math.max(clusterHi, testVp.pocPrice)
                                        changed := true
                    int count = 0
                    int xLeft = f_vpLeftBar(anchorVp)
                    int xRight = extendPoc ? rightExtend : f_vpRightBar(anchorVp) + 2
                    for j = 0 to n - 1
                        if array.get(inCluster, j)
                            array.set(used, j, true)
                            VolumeProfile memberVp = array.get(vps, j)
                            count += 1
                            xLeft := math.min(xLeft, f_vpLeftBar(memberVp))
                            xRight := extendPoc ? rightExtend : math.max(xRight, f_vpRightBar(memberVp) + 2)
                    int baseTransp = f_baseTransp(i, totalShown)
                    if glowEffect
                        line pocGlow1 = line.new(xLeft, anchorPrice, xRight, anchorPrice, color = color.new(colPoc, math.min(baseTransp + 30, 85)), width = pocWidth + 3)
                        array.push(allLines, pocGlow1)
                        line pocGlow2 = line.new(xLeft, anchorPrice, xRight, anchorPrice, color = color.new(colPoc, math.min(baseTransp + 15, 75)), width = pocWidth + 1)
                        array.push(allLines, pocGlow2)
                    line pocL = line.new(xLeft, anchorPrice, xRight, anchorPrice, color = color.new(colPoc, math.max(baseTransp - 20, 15)), width = pocWidth)
                    array.push(allLines, pocL)
                    if showLabels
                        string mergeTxt = count > 1 ? " x" + str.tostring(count) + " [" + str.tostring(clusterLo, format.mintick) + "–" + str.tostring(clusterHi, format.mintick) + "]" : ""
                        string txt = "POC " + str.tostring(anchorPrice, format.mintick) + mergeTxt
                        label pLbl = label.new(xRight + 2, anchorPrice, txt, color = color.new(colPoc, 35), textcolor = #000000, size = size.tiny, style = label.style_label_left)
                        array.push(allLabels, pLbl)

// ============================================================================
// ADVANCED MODE 1 : TRUE CONFLUENCE DETECTOR
// ============================================================================
f_drawConfluence(array<VolumeProfile> vps) =>
    if confDetect and array.size(vps) > 0
        array<float> levels = array.new_float()
        array<int> sources = array.new_int()
        array<int> types = array.new_int()
        int nVps = array.size(vps)
        for i = 0 to nVps - 1
            VolumeProfile vp = array.get(vps, i)
            if not na(vp.pocPrice)
                array.push(levels, vp.pocPrice)
                array.push(sources, i)
                array.push(types, 1)
            if not na(vp.vahPrice)
                array.push(levels, vp.vahPrice)
                array.push(sources, i)
                array.push(types, 2)
            if not na(vp.valPrice)
                array.push(levels, vp.valPrice)
                array.push(sources, i)
                array.push(types, 3)
            if showFib and not na(vp.hi) and not na(vp.lo)
                float a = f_fibAnchorA(vp)
                float b = f_fibAnchorB(vp)
                array<float> fibRatios = array.from(0.000, 0.236, 0.382, 0.500, 0.618, 0.786, 0.886)
                array<bool> fibFlags = array.from(fib_000, fib_236, fib_382, fib_500, fib_618, fib_786, fib_886)
                for fi = 0 to array.size(fibRatios) - 1
                    if array.get(fibFlags, fi)
                        array.push(levels, f_fibLevel(a, b, array.get(fibRatios, fi)))
                        array.push(sources, i)
                        array.push(types, 4)
        float tol = confTolNow
        int n = array.size(levels)
        if n > 1
            for i = 0 to n - 1
                float center = array.get(levels, i)
                bool alreadyClustered = false
                if i > 0
                    for prev = 0 to i - 1
                        if math.abs(array.get(levels, prev) - center) <= tol
                            alreadyClustered := true
                            break
                if not alreadyClustered
                    array<int> uniqueVps = array.new_int()
                    array<int> uniqueTypes = array.new_int()
                    int count = 0
                    float sum = 0.0
                    for j = 0 to n - 1
                        float p = array.get(levels, j)
                        if math.abs(p - center) <= tol
                            int src = array.get(sources, j)
                            int typ = array.get(types, j)
                            if not f_hasInt(uniqueVps, src)
                                array.push(uniqueVps, src)
                            if not f_hasInt(uniqueTypes, typ)
                                array.push(uniqueTypes, typ)
                            sum += p
                            count += 1
                    int vpCnt = array.size(uniqueVps)
                    int typeCnt = array.size(uniqueTypes)
                    bool valid = count >= confMin and vpCnt >= confMinVps and typeCnt >= confMinTypes
                    if valid
                        float avgP = sum / count
                        float score = math.min(count * 10.0 + vpCnt * 20.0 + typeCnt * 12.0, 100.0)
                        color glowCol = score >= 80 ? colConfHi : score >= 60 ? colPower : colPoc
                        line confGlow1 = line.new(bar_index - 80, avgP, bar_index + 18, avgP, color = color.new(glowCol, 65), width = 5)
                        array.push(allLines, confGlow1)
                        line confGlow2 = line.new(bar_index - 80, avgP, bar_index + 18, avgP, color = color.new(glowCol, 35), width = 3)
                        array.push(allLines, confGlow2)
                        line cl = line.new(bar_index - 80, avgP, bar_index + 18, avgP, color = color.new(glowCol, 10), width = 1)
                        array.push(allLines, cl)
                        label clb = label.new(bar_index + 20, avgP, "◆ CONF " + str.tostring(score, "#") + " | L" + str.tostring(count) + " VP" + str.tostring(vpCnt) + " T" + str.tostring(typeCnt), color = color.new(glowCol, 5), textcolor = #000000, size = size.small, style = label.style_label_left)
                        array.push(allLabels, clb)

// ADVANCED MODE 2 : GLOBAL HEATMAP
// ============================================================================
f_drawGlobalHeatmap(array<VolumeProfile> vps) =>
    if globalHeat and array.size(vps) > 0
        float gHi = na
        float gLo = na
        int nVps = array.size(vps)

        for i = 0 to nVps - 1
            VolumeProfile vp = array.get(vps, i)
            if not na(vp.hi)
                gHi := na(gHi) ? vp.hi : math.max(gHi, vp.hi)
            if not na(vp.lo)
                gLo := na(gLo) ? vp.lo : math.min(gLo, vp.lo)

        if not na(gHi) and not na(gLo) and gHi > gLo
            float gRange = gHi - gLo
            float gStep = gRange / heatRes
            array<float> heatBull = array.new_float(heatRes, 0.0)
            array<float> heatBear = array.new_float(heatRes, 0.0)

            for i = 0 to nVps - 1
                VolumeProfile vp = array.get(vps, i)
                if not na(vp.hi) and not na(vp.lo)
                    float vpStep = (vp.hi - vp.lo) / nRows
                    for k = 0 to nRows - 1
                        float rowPrice = vp.lo + (k + 0.5) * vpStep
                        float vBull = array.get(vp.rowsBull, k)
                        float vBear = array.get(vp.rowsBear, k)
                        int gIdx = int((rowPrice - gLo) / gStep)
                        gIdx := math.max(math.min(gIdx, heatRes - 1), 0)
                        array.set(heatBull, gIdx, array.get(heatBull, gIdx) + vBull)
                        array.set(heatBear, gIdx, array.get(heatBear, gIdx) + vBear)

            float maxV = 0
            for k = 0 to heatRes - 1
                float t = array.get(heatBull, k) + array.get(heatBear, k)
                if t > maxV
                    maxV := t

            if maxV > 0
                int rightStart = bar_index + heatOffset
                int midCol = rightStart + int(heatWidth / 2)

                // Background frame
                box frameBg = box.new(rightStart - 1, gHi + gStep, rightStart + heatWidth + 1, gLo - gStep, bgcolor = color.new(#0D1B2A, 75), border_color = color.new(colPoc, 60), border_width = 1)
                array.push(allBoxes, frameBg)

                for k = 0 to heatRes - 1
                    float vBull = array.get(heatBull, k)
                    float vBear = array.get(heatBear, k)
                    float vTot = vBull + vBear
                    if vTot > 0
                        float intensity = vTot / maxV
                        int stop = intensity > 0.85 ? 4 : intensity > 0.65 ? 3 : intensity > 0.40 ? 2 : intensity > 0.20 ? 1 : 0
                        int transp = int(math.max(75 - intensity * 45, 25))
                        float rowLo = gLo + k * gStep
                        float rowHi = gLo + (k + 1) * gStep

                        if showSplit
                            float bullW = (vBull / maxV) * (heatWidth / 2.0)
                            float bearW = (vBear / maxV) * (heatWidth / 2.0)
                            if bullW > 0.1
                                box b = box.new(midCol, rowHi, midCol + int(bullW), rowLo, bgcolor = color.new(f_palBull(stop), transp), border_color = color.new(f_palBull(stop), math.max(transp - 5, 20)))
                                array.push(allBoxes, b)
                            if bearW > 0.1
                                box b = box.new(midCol - int(bearW), rowHi, midCol, rowLo, bgcolor = color.new(f_palBear(stop), transp), border_color = color.new(f_palBear(stop), math.max(transp - 5, 20)))
                                array.push(allBoxes, b)
                        else
                            bool bullDom = vBull > vBear
                            color c = bullDom ? f_palBull(stop) : f_palBear(stop)
                            float halfW = (vTot / maxV) * (heatWidth / 2.0)
                            box b = box.new(midCol - int(halfW), rowHi, midCol + int(halfW), rowLo, bgcolor = color.new(c, transp), border_color = color.new(c, math.max(transp - 5, 20)))
                            array.push(allBoxes, b)

                // Header label
                label hLbl = label.new(midCol, gHi + gStep * 2, "GLOBAL", color = color.new(colPoc, 20), textcolor = #000000, size = size.tiny, style = label.style_label_down)
                array.push(allLabels, hLbl)

                // Global POC (max row across all VPs)
                int gPocIdx = 0
                float gMax = 0
                for k = 0 to heatRes - 1
                    float t = array.get(heatBull, k) + array.get(heatBear, k)
                    if t > gMax
                        gMax := t
                        gPocIdx := k
                float gPocPrice = gLo + (gPocIdx + 0.5) * gStep
                line gpLine = line.new(rightStart - 3, gPocPrice, rightStart + heatWidth + 3, gPocPrice, color = colPower, width = 2)
                array.push(allLines, gpLine)
                label gpLbl = label.new(rightStart + heatWidth + 5, gPocPrice, "G-POC " + str.tostring(gPocPrice, format.mintick), color = color.new(colPower, 20), textcolor = #000000, size = size.tiny, style = label.style_label_left)
                array.push(allLabels, gpLbl)


// ============================================================================
// LIVE VP GAUGES PANEL — SQUARES / 4 CORNERS / NO BID-ASK / NO 1T
// ============================================================================
f_gauge10(float x) =>
    float v = math.max(math.min(x, 1.0), 0.0)
    int n = int(math.round(v * 10.0))
    n := math.max(math.min(n, 10), 0)
    string g = ""
    for i = 1 to 10
        g += i <= n ? "■" : "□"
    g

f_pctTxt(float x) =>
    str.tostring(math.max(math.min(x, 1.0), 0.0) * 100.0, "#.0") + "%"

f_liveGaugePosition() =>
    liveGaugePos == "Top Left" ? position.top_left : liveGaugePos == "Top Right" ? position.top_right : liveGaugePos == "Bottom Left" ? position.bottom_left : position.bottom_right

f_drawLiveVpGauges(VolumeProfile liveVP) =>
    var table lg = table.new(f_liveGaugePosition(), 4, 11, border_width = 1, border_color = color.new(#263238, 55), frame_width = 1, frame_color = color.new(#263238, 25))
    if showLiveGauges and not na(liveVP.pocPrice) and liveVP.totalVol > 0 and liveVP.pocVol > 0
        color bgHdr = color.new(#0D1B2A, 0)
        color bgVal = color.new(#0D1B2A, 30)
        color bgDim = color.new(#0D1B2A, 72)
        float bullPct = liveVP.totalVol > 0 ? liveVP.bullVol / liveVP.totalVol : 0.5
        bullPct := math.max(math.min(bullPct, 1.0), 0.0)
        float bearPct = 1.0 - bullPct
        float deltaNorm = bullPct - bearPct
        float deltaGauge = (deltaNorm + 1.0) / 2.0
        float vpRange = math.max(liveVP.hi - liveVP.lo, syminfo.mintick * nRows)
        float vaRange = math.max(liveVP.vahPrice - liveVP.valPrice, syminfo.mintick)
        float atr = nz(atr14, syminfo.mintick * 100.0)
        float distRef = liveGaugeRef == "VP Range" ? vpRange : liveGaugeRef == "ATR" ? atr : vaRange
        distRef := math.max(distRef, syminfo.mintick)
        float vaPos = math.max(math.min((close - liveVP.valPrice) / vaRange, 1.0), 0.0)
        float pocDist = math.abs(close - liveVP.pocPrice)
        float pocMag = math.max(1.0 - pocDist / distRef, 0.0)
        float vahDist = math.abs(close - liveVP.vahPrice)
        float valDist = math.abs(close - liveVP.valPrice)
        float vahNear = math.max(1.0 - vahDist / distRef, 0.0)
        float valNear = math.max(1.0 - valDist / distRef, 0.0)
        float closeLoc = math.max(math.min((close - liveVP.lo) / vpRange, 1.0), 0.0)
        float rowPressure = 0.5
        float step = vpRange / nRows
        int curIdx = int(math.floor((close - liveVP.lo) / step))
        curIdx := math.max(math.min(curIdx, nRows - 1), 0)
        float curBull = array.get(liveVP.rowsBull, curIdx)
        float curBear = array.get(liveVP.rowsBear, curIdx)
        float curTot = curBull + curBear
        if curTot > 0
            rowPressure := curBull / curTot
        float barPressure = f_bullShare(open, high, low, close)
        string domTxt = "PRESS"
        color domCol = deltaNorm > 0.05 ? f_palBull(4) : deltaNorm < -0.05 ? f_palBear(4) : colPoc
        string vaState = close > liveVP.vahPrice ? "ABOVE VA" : close < liveVP.valPrice ? "BELOW VA" : "INSIDE VA"
        string pocSide = close >= liveVP.pocPrice ? "ABOVE POC" : "BELOW POC"
        table.cell(lg, 0, 0, "LIVE VP", bgcolor = color.new(colPoc, 20), text_color = #000000, text_size = size.tiny)
        table.cell(lg, 1, 0, domTxt, bgcolor = color.new(domCol, 20), text_color = #000000, text_size = size.tiny)
        table.cell(lg, 2, 0, pocSide, bgcolor = bgHdr, text_color = colPoc, text_size = size.tiny)
        table.cell(lg, 3, 0, str.tostring(liveVP.pocPrice, format.mintick), bgcolor = bgVal, text_color = colPoc, text_size = size.tiny)
        table.cell(lg, 0, 1, "BUY", bgcolor = bgHdr, text_color = f_palBull(4), text_size = size.tiny)
        table.cell(lg, 1, 1, f_gauge10(bullPct), bgcolor = bgVal, text_color = f_palBull(4), text_size = size.tiny)
        table.cell(lg, 2, 1, f_pctTxt(bullPct), bgcolor = bgVal, text_color = f_palBull(4), text_size = size.tiny)
        table.cell(lg, 3, 1, "Live VP", bgcolor = bgDim, text_color = colText, text_size = size.tiny)
        table.cell(lg, 0, 2, "SELL", bgcolor = bgHdr, text_color = f_palBear(4), text_size = size.tiny)
        table.cell(lg, 1, 2, f_gauge10(bearPct), bgcolor = bgVal, text_color = f_palBear(4), text_size = size.tiny)
        table.cell(lg, 2, 2, f_pctTxt(bearPct), bgcolor = bgVal, text_color = f_palBear(4), text_size = size.tiny)
        table.cell(lg, 3, 2, "Live VP", bgcolor = bgDim, text_color = colText, text_size = size.tiny)
        table.cell(lg, 0, 3, "NET Δ", bgcolor = bgHdr, text_color = domCol, text_size = size.tiny)
        table.cell(lg, 1, 3, f_gauge10(deltaGauge), bgcolor = bgVal, text_color = domCol, text_size = size.tiny)
        table.cell(lg, 2, 3, str.tostring(deltaNorm * 100.0, "#.0") + "%", bgcolor = bgVal, text_color = domCol, text_size = size.tiny)
        table.cell(lg, 3, 3, "0=center", bgcolor = bgDim, text_color = colText, text_size = size.tiny)
        table.cell(lg, 0, 4, "VA POS", bgcolor = bgHdr, text_color = colVA, text_size = size.tiny)
        table.cell(lg, 1, 4, f_gauge10(vaPos), bgcolor = bgVal, text_color = colVA, text_size = size.tiny)
        table.cell(lg, 2, 4, vaState, bgcolor = bgVal, text_color = colVA, text_size = size.tiny)
        table.cell(lg, 3, 4, str.tostring(close, format.mintick), bgcolor = bgVal, text_color = colText, text_size = size.tiny)
        table.cell(lg, 0, 5, "POC MAG", bgcolor = bgHdr, text_color = colPoc, text_size = size.tiny)
        table.cell(lg, 1, 5, f_gauge10(pocMag), bgcolor = bgVal, text_color = colPoc, text_size = size.tiny)
        table.cell(lg, 2, 5, f_pctTxt(pocMag), bgcolor = bgVal, text_color = colPoc, text_size = size.tiny)
        table.cell(lg, 3, 5, str.tostring(pocDist, format.mintick), bgcolor = bgDim, text_color = colText, text_size = size.tiny)
        table.cell(lg, 0, 6, "VAH NEAR", bgcolor = bgHdr, text_color = colVA, text_size = size.tiny)
        table.cell(lg, 1, 6, f_gauge10(vahNear), bgcolor = bgVal, text_color = colVA, text_size = size.tiny)
        table.cell(lg, 2, 6, f_pctTxt(vahNear), bgcolor = bgVal, text_color = colVA, text_size = size.tiny)
        table.cell(lg, 3, 6, str.tostring(liveVP.vahPrice, format.mintick), bgcolor = bgDim, text_color = colVA, text_size = size.tiny)
        table.cell(lg, 0, 7, "VAL NEAR", bgcolor = bgHdr, text_color = colVA, text_size = size.tiny)
        table.cell(lg, 1, 7, f_gauge10(valNear), bgcolor = bgVal, text_color = colVA, text_size = size.tiny)
        table.cell(lg, 2, 7, f_pctTxt(valNear), bgcolor = bgVal, text_color = colVA, text_size = size.tiny)
        table.cell(lg, 3, 7, str.tostring(liveVP.valPrice, format.mintick), bgcolor = bgDim, text_color = colVA, text_size = size.tiny)
        table.cell(lg, 0, 8, "PRESS", bgcolor = bgHdr, text_color = rowPressure >= 0.5 ? f_palBull(4) : f_palBear(4), text_size = size.tiny)
        table.cell(lg, 1, 8, f_gauge10(rowPressure), bgcolor = bgVal, text_color = rowPressure >= 0.5 ? f_palBull(4) : f_palBear(4), text_size = size.tiny)
        table.cell(lg, 2, 8, f_pctTxt(rowPressure), bgcolor = bgVal, text_color = rowPressure >= 0.5 ? f_palBull(4) : f_palBear(4), text_size = size.tiny)
        table.cell(lg, 3, 8, "current row", bgcolor = bgDim, text_color = colText, text_size = size.tiny)
        if liveGaugeRows == "Full"
            table.cell(lg, 0, 9, "BAR", bgcolor = bgHdr, text_color = barPressure >= 0.5 ? f_palBull(4) : f_palBear(4), text_size = size.tiny)
            table.cell(lg, 1, 9, f_gauge10(barPressure), bgcolor = bgVal, text_color = barPressure >= 0.5 ? f_palBull(4) : f_palBear(4), text_size = size.tiny)
            table.cell(lg, 2, 9, f_pctTxt(barPressure), bgcolor = bgVal, text_color = barPressure >= 0.5 ? f_palBull(4) : f_palBear(4), text_size = size.tiny)
            table.cell(lg, 3, 9, "last bar", bgcolor = bgDim, text_color = colText, text_size = size.tiny)
            table.cell(lg, 0, 10, "CLOSE LOC", bgcolor = bgHdr, text_color = colFib, text_size = size.tiny)
            table.cell(lg, 1, 10, f_gauge10(closeLoc), bgcolor = bgVal, text_color = colFib, text_size = size.tiny)
            table.cell(lg, 2, 10, f_pctTxt(closeLoc), bgcolor = bgVal, text_color = colFib, text_size = size.tiny)
            table.cell(lg, 3, 10, "VP range", bgcolor = bgDim, text_color = colText, text_size = size.tiny)
        else
            for rr = 9 to 10
                for cc = 0 to 3
                    table.cell(lg, cc, rr, "", bgcolor = color.new(#0D1B2A, 100), text_color = colText, text_size = size.tiny)
    else
        if showLiveGauges
            for rr = 0 to 10
                for cc = 0 to 3
                    table.cell(lg, cc, rr, rr == 0 and cc == 0 ? "LIVE VP" : rr == 0 and cc == 1 ? "NO DATA" : "", bgcolor = rr == 0 ? color.new(#0D1B2A, 20) : color.new(#0D1B2A, 100), text_color = colDim, text_size = size.tiny)

// ============================ MAIN DRAW =====================================
if barstate.islast
    f_clearAll()

    // Build live VP
    VolumeProfile liveVP = liveVPNow

    array<VolumeProfile> drawList = array.new<VolumeProfile>()
    int n = math.min(array.size(vpList), maxVP - 1)
    if n > 0
        for i = 0 to n - 1
            array.push(drawList, array.get(vpList, i))

    if not na(liveVP.pocPrice)
        array.unshift(drawList, liveVP)

    int rightExtend = bar_index + 20
    int totalShown = array.size(drawList)
    if totalShown > 0
        for i = 0 to totalShown - 1
            VolumeProfile vp = array.get(drawList, i)
            int nextStart = na
            if i > 0
                VolumeProfile nextVp = array.get(drawList, i - 1)
                nextStart := nextVp.startBar
            f_drawVP(vp, i, totalShown, rightExtend, nextStart)
        f_drawMergedPocs(drawList, totalShown, rightExtend)

    // === ADVANCED MODES ===
    f_drawConfluence(drawList)
    f_drawGlobalHeatmap(drawList)
    f_drawLiveVpGauges(liveVP)

// ============================ DASHBOARD ====================================
if showDash and barstate.islast
    var table dash = table.new(position.top_right, 2, 10, border_width = 1, border_color = color.new(#263238, 60), frame_width = 1, frame_color = color.new(#263238, 30))

    int totalVPs = array.size(vpList)
    float nearestPocPrice = na
    float nearestDist = na
    if totalVPs > 0
        for i = 0 to totalVPs - 1
            VolumeProfile vp = array.get(vpList, i)
            if not na(vp.pocPrice)
                float d = math.abs(close - vp.pocPrice)
                if na(nearestDist) or d < nearestDist
                    nearestDist := d
                    nearestPocPrice := vp.pocPrice

    color bgHdr = color.new(#0D1B2A, 0)
    color bgVal = color.new(#0D1B2A, 30)
    color txtHdr = #607D8B

    table.cell(dash, 0, 0, "FIB-VP", bgcolor = color.new(colPoc, 30), text_color = #000000, text_size = size.tiny)
    table.cell(dash, 1, 0, "ALL " + str.tostring(maxVP), bgcolor = color.new(colPoc, 30), text_color = #000000, text_size = size.tiny)
    table.cell(dash, 0, 1, "MODE", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 1, vpMode, bgcolor = bgVal, text_color = colText, text_size = size.tiny)
    table.cell(dash, 0, 2, "VPs", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 2, str.tostring(totalVPs) + " stored", bgcolor = bgVal, text_color = colText, text_size = size.tiny)
    table.cell(dash, 0, 3, "NEAR POC", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 3, na(nearestPocPrice) ? "—" : str.tostring(nearestPocPrice, format.mintick), bgcolor = bgVal, text_color = colPoc, text_size = size.tiny)
    table.cell(dash, 0, 4, "POC DIST", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    string distStr = na(nearestDist) ? "—" : str.tostring((nearestDist / close) * 100.0, "#.00") + "%"
    table.cell(dash, 1, 4, distStr, bgcolor = bgVal, text_color = colText, text_size = size.tiny)
    table.cell(dash, 0, 5, "FIB", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 5, showFib ? fibAnchor + " | " + fibDirection : "OFF", bgcolor = bgVal, text_color = showFib ? colFib : colDim, text_size = size.tiny)
    table.cell(dash, 0, 6, "POC MERGE", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 6, mergePoc ? "ON" : "OFF", bgcolor = bgVal, text_color = mergePoc ? colPoc : colDim, text_size = size.tiny)
    table.cell(dash, 0, 7, "VA EXT", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 7, extendVa ? "ON" : "OFF", bgcolor = bgVal, text_color = extendVa ? colVA : colDim, text_size = size.tiny)
    table.cell(dash, 0, 8, "CONF", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 8, confDetect ? "TRUE" : "OFF", bgcolor = bgVal, text_color = confDetect ? colConfHi : colDim, text_size = size.tiny)
    table.cell(dash, 0, 9, "G-HEAT", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 9, globalHeat ? "ON" : "OFF", bgcolor = bgVal, text_color = globalHeat ? colPower : colDim, text_size = size.tiny)

// ============================ ALERTS =======================================
hitPoc = false
if array.size(vpList) > 0
    for i = 0 to array.size(vpList) - 1
        VolumeProfile vp = array.get(vpList, i)
        if not na(vp.pocPrice) and high >= vp.pocPrice and low <= vp.pocPrice and not (high[1] >= vp.pocPrice and low[1] <= vp.pocPrice)
            hitPoc := true
            break

alertcondition(hitPoc, "POC Touch", "APEX FIB-VP: Price reached a POC level.")
````
