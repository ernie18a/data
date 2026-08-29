<!-- tradingview-pine-id: PUB;aa1f1df5f3674130a549581bf813d403 -->
<!-- tradingviewscripts-format: 1 -->
# Breakout Volume Delta | Flux Charts

Source: https://www.tradingview.com/script/BsWaPtEz-Breakout-Volume-Delta-Flux-Charts/

## Description

GENERAL OVERVIEW:
Breakout Volume Delta is an indicator that measures breakout strength using lower-timeframe volume delta. It estimates buyer vs. seller participation within the breakout candle by summing bullish and bearish sub-candle volumes, then visualizes that dominance by splitting the candle body into bullish and bearish segments.
https://www.tradingview.com/x/AQGBkiiG/ 
https://www.tradingview.com/x/li1Zdtsv/ 
https://www.tradingview.com/x/dYHoYL2m/ 
​​https://www.tradingview.com/x/UuFy5eif/ 

What is the theory behind the indicator?:
Breakouts often look strong on price alone, but their quality depends on participation. A breakout candle that is driven by dominant buying or selling pressure is generally more meaningful than a breakout candle that forms with mixed or weak participation.

This indicator gauges participation using lower timeframe volume delta. It breaks the current candle into lower timeframe sub-candles, sums volume on bullish sub-candles as bullish volume, and sums volume on bearish sub-candles as bearish volume. Those totals are converted into dominance percentages.

The breakout candle is then visualized using a split-body overlay: the portion sized by the dominant side is shown in the breakout color, and the remaining portion is shown as the opposite side. This makes it easy to judge whether the breakout candle was supported by real directional participation or if the opposite side was active inside the same candle.

Bullish dominant breakout candle:
https://www.tradingview.com/x/gpuDpRdj/

Bearish dominant breakout candle:
https://www.tradingview.com/x/NelkuwXa/ 

FEATURES:
🔹Swing Left and Right
Controls how many swing-timeframe candles are required on the left and right side to confirm a swing point before a level is drawn. Higher values reduce noise by requiring stronger confirmation. Higher values increase confirmation delay because more candles are needed to validate the pivot.
https://www.tradingview.com/x/hkeM1bgV/ 

🔹Swing Timeframe
Selects the timeframe used to detect swing levels. Default setting uses the chart timeframe. Creates each swing timeframe candle by combining the smaller candles inside it, then tracks the highest high and lowest low made during that period. Saves the exact time when those highs and lows happened so levels can be placed accurately on lower timeframes.

Swing levels detected on a higher timeframe and shown on a lower timeframe chart:
https://www.tradingview.com/x/0fxICYHq/ 

🔹Volume Delta LTF
Selects the lower timeframe used to estimate buy vs sell participation inside each breakout candle.

[*]Bull volume sums volume from sub-candles where close is above open.
[*]Bear volume sums volume from sub-candles where close is below open.

Converts those totals into bullish and bearish dominance percentages.

Volume delta label showing bullish and bearish dominance:
https://www.tradingview.com/x/nQYyjyKw/ 

🔹Breakout by
Controls how a swing level is considered broken.

[*]Wick mode confirms a break when the wick crosses the level.
[*]Close mode confirms a break only when the candle closes beyond the level.

Close breakout:
https://www.tradingview.com/x/vL3xsoqT/

Wick breakout:
https://www.tradingview.com/x/7iLaNIU3/ 

🔹Show Nearest
Limits how many of the most recent swing levels remain visible on the chart. Deletes older levels once the stored level count exceeds the chosen number.

Only the most recent swing levels shown on the chart:
https://www.tradingview.com/x/LQeLQX5Q/ 

🔹Breakout Volume Filter
Optional filter that only validates a breakout if the breakout candle shows enough dominance from the breakout side.

[*]Bullish breakouts require bullish dominance to exceed the threshold.
[*]Bearish breakouts require bearish dominance to exceed the threshold.

If the filter fails, the affected level is removed instead of being marked as broken.

Bullish breakout with Breakout Volume Filter activated:
https://www.tradingview.com/x/7QbE4Ei7/

Bearish breakout with Breakout Volume Filter activated:
https://www.tradingview.com/x/kXJnIACl/ 

🔹Unmitigated Levels
Controls how live (unmitigated) swing levels are drawn. Users can customize the Line style, thickness, and colors for live levels.

Live levels shown with unmitigated styling:
https://www.tradingview.com/x/ke0U1A4n/ 

🔹Broken Levels
Controls how a level looks after it breaks and locks it to the breakout bar. Switches the level to broken style, width, and color, and stops extending and ends at the breakout candle time.

https://www.tradingview.com/x/cU6m0jmr/ 

🔹Volume Delta
Controls the colors used for bullish and bearish dominance on the split-body overlay.
https://www.tradingview.com/x/u2A2DF5f/ 

🔹Extend Levels
Controls how far levels extend forward when Extend Right is disabled.
https://www.tradingview.com/x/ZAsfsfZd/ 

🔹Extend Right
When enabled, levels extend all the way to the right instead of stopping at a fixed future point.
https://www.tradingview.com/x/DQydWtLU/ 

🔹Volume Delta Labels
Optional volume delta labels that print bullish and bearish volume with dominance percentages on breakout bars.

[*]Shows bull and bear volumes plus percentages.
[*]Places label above bullish breakouts and below bearish breakouts.

https://www.tradingview.com/x/8gD0iJri/ 

UNIQUENESS:
Breakout Volume Delta is unique because it visualizes breakout strength directly on the breakout candle using lower timeframe buy vs sell dominance, instead of relying on price action alone.

[*]Breakout strength is shown inside the breakout candle by splitting the body into bullish and bearish participation segments.
[*]Lower timeframe activity is mapped onto the higher timeframe candle so dominance is visible exactly where the breakout happened.
[*]Swing levels provide breakout context, while the split-body overlay explains how much real participation supported the move.
[*]Chart-clean design keeps the display readable by limiting how many levels remain on screen.

https://www.tradingview.com/x/rb86GZnm/

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©fluxchart

//@version=6
indicator("Breakout Volume Delta | Flux Charts", overlay = true, max_lines_count = 500, max_labels_count = 500, behind_chart = false)

//#region CONSTANTS
const string sTfTip = "Timeframe used to detect swing highs/lows."
const string volDelTip = "Lower timeframe used to estimate buy vs sell volume for the breakout candle."
const string brModeTip = "Choose whether a level is considered broken by candle wicks or by candle close."
const string showNeTip = "Limits how many most recent swing high/low levels shown on the chart."
const string brVolFiltTip = "Only count breakouts when the breakout candle has enough bull/bear volume dominance."

const string grpSw = "GENERAL CONFIGURATION"
const string grpLn = "Styling"
disp = display.none
//#endregion CONSTANTS

//#region INPUTS
int swLenL = input.int(10, "Swing Left", minval = 1, group = grpSw, inline = "sw", display = disp)
int swLenR = input.int(10, "Right", minval = 1, group = grpSw, inline = "sw", display = disp)

string swTfIn = input.timeframe("", "Swing Timeframe", tooltip = sTfTip, group = grpSw, display = disp)
string vdLtf = input.timeframe("1", "Volume Delta LTF", tooltip = volDelTip, group = grpSw, display = disp)

string brMode = input.string("Close", "Breakout by", options = ["Close", "Wick"], tooltip = brModeTip, group = grpSw, display = disp)
int maxLvls = input.int(5, "Show Nearest", minval = 1, tooltip = showNeTip, group = grpSw, display = disp)

bool brVolFiltOn = input.bool(false, "Breakout Volume Filter", tooltip = brVolFiltTip, group = grpSw, inline = "bv", display = disp)
float brVolFiltPctIn = input.float(60.0, "", minval = 0.0, maxval = 100.0, step = 0.5, group = grpSw, inline = "bv", display = disp)

string unmitStyleIn = input.string("Dotted", "Unmitigated Levels", options = ["Solid", "Dashed", "Dotted"], group = grpLn, inline = "unm", display = disp)
int unmitW = input.int(1, "", minval = 1, maxval = 4, group = grpLn, inline = "unm", display = disp)
color unmitHiCol = input.color(color.new(color.lime, 0), "", group = grpLn, inline = "unm", display = disp)
color unmitLoCol = input.color(color.new(color.red, 0), "", group = grpLn, inline = "unm", display = disp)

string brkStyleIn = input.string("Solid", "Broken Levels", options = ["Solid", "Dashed", "Dotted"], group = grpLn, inline = "brk", display = disp)
int brkW = input.int(1, "", minval = 1, maxval = 4, group = grpLn, inline = "brk", display = disp)
color brkHiCol = input.color(color.new(color.lime, 0), "", group = grpLn, inline = "brk", display = disp)
color brkLoCol = input.color(color.new(color.red, 0), "", group = grpLn, inline = "brk", display = disp)

color bullBase = input.color(color.new(#00FF6A, 0), "Volume Delta", group = grpLn, inline = "vd", display = disp)
color bearBase = input.color(color.new(#FF2D55, 0), "", group = grpLn, inline = "vd", display = disp)

int extendBars = input.int(5, "Extend Levels", minval = 1, group = grpLn, inline = "ext11", display = disp)
bool extendRight = input.bool(false, "Extend Right", group = grpLn, inline = "ext", display = disp)
bool dbgShow = input.bool(true, "Volume Delta Labels", group = grpLn, inline = "ext", display = disp)
//#endregion INPUTS

//#region TYPES
type PxT
    float p
    int t

type SwBar
    PxT h
    PxT l
//#endregion TYPES

//#region ARRAYS
var array<line> linesHi = array.new_line()
var array<float> pricesHi = array.new_float()
var array<bool> mitigHi = array.new_bool()

var array<line> linesLo = array.new_line()
var array<float> pricesLo = array.new_float()
var array<bool> mitigLo = array.new_bool()

var array<SwBar> swHist = array.new<SwBar>()
//#endregion ARRAYS

//#region VARIABLES
var string swTfPrev = ""
var bool swInited = false
var SwBar swCur = na

var int lastPhT = na
var int lastPlT = na

float fillOpen = na
float fillHigh = na
float fillLow = na
float fillClose = na
color fillCol = na

float oppOpen = na
float oppHigh = na
float oppLow = na
float oppClose = na
color oppCol = na

color breakOutlineCol = na

var bool dbgDoLabel = false
var bool dbgIsBull = false
var string dbgLblTxt = ""
var float dbgLblY = na
//#endregion VARIABLES

//#region FUNCTIONS
// Converts a string input into a line style.
fLineStyle(string s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

fFmt(float v) =>
    float av = math.abs(v)
    string suf = av >= 1e9 ? "B" : av >= 1e6 ? "M" : av >= 1e3 ? "K" : ""
    float div = av >= 1e9 ? 1e9 : av >= 1e6 ? 1e6 : av >= 1e3 ? 1e3 : 1.0
    string s = str.tostring(v / div, av >= 1e3 ? "#.##" : "#")
    s + suf

fPctStr(float pct01) =>
    float p = math.max(0.0, math.min(1.0, pct01)) * 100.0
    str.tostring(p, "#.#") + "%"

// Sums bullish sub-bar volume from a lower timeframe.
fBullVolSum(string ltf) =>
    arr = request.security_lower_tf(syminfo.tickerid, ltf, close > open ? volume : 0.0)
    float sum = 0.0
    int n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            sum += array.get(arr, i)
    sum

// Sums bearish sub-bar volume from a lower timeframe.
fBearVolSum(string ltf) =>
    arr = request.security_lower_tf(syminfo.tickerid, ltf, close < open ? volume : 0.0)
    float sum = 0.0
    int n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            sum += array.get(arr, i)
    sum

tfResolve(string tfIn) =>
    string tf = tfIn == "" ? timeframe.period : tfIn
    int chartSec = timeframe.in_seconds(timeframe.period)
    int wantSec = timeframe.in_seconds(tf)
    (not na(chartSec) and not na(wantSec) and wantSec < chartSec) ? timeframe.period : tf

pxNew(float p, int t) =>
    PxT.new(p, t)

swBarEmpty() =>
    SwBar.new(pxNew(na, na), pxNew(na, na))

fTrim() =>
    while array.size(linesHi) > maxLvls
        line.delete(array.shift(linesHi))
        array.shift(pricesHi)
        array.shift(mitigHi)
    while array.size(linesLo) > maxLvls
        line.delete(array.shift(linesLo))
        array.shift(pricesLo)
        array.shift(mitigLo)
//#endregion FUNCTIONS

//#region CALCULATIONS
int chartSec = timeframe.in_seconds(timeframe.period)
int barMs = na(chartSec) ? 60000 : (chartSec * 1000)
int extX2 = time + extendBars * barMs

// Swing engine and level creation.
string swTf = tfResolve(swTfIn)
string unmitStyle = fLineStyle(unmitStyleIn)

if na(swCur)
    swCur := swBarEmpty()

if barstate.isfirst or swTfPrev != swTf
    swTfPrev := swTf
    swInited := false
    swCur := swBarEmpty()
    array.clear(swHist)

bool swNewTf = timeframe.change(swTf)

if swNewTf and swInited
    array.unshift(swHist, swCur)

    int keepN = math.max(50, swLenL + swLenR + 10)
    while array.size(swHist) > keepN
        array.pop(swHist)

    swInited := false
    swCur := swBarEmpty()

if not swInited
    swCur.h := pxNew(high, time)
    swCur.l := pxNew(low, time)
    swInited := true
else
    if na(swCur.h.p) or high > swCur.h.p
        swCur.h := pxNew(high, time)
    if na(swCur.l.p) or low < swCur.l.p
        swCur.l := pxNew(low, time)

bool gotPivotEvent = swNewTf and array.size(swHist) >= (swLenL + swLenR + 1)

if gotPivotEvent
    int r = swLenR
    int l = swLenL

    SwBar cand = array.get(swHist, r)

    float candH = cand.h.p
    float candL = cand.l.p

    bool isPh = not na(candH)
    bool isPl = not na(candL)

    for j = 0 to r - 1
        SwBar b = array.get(swHist, j)
        if isPh and not na(b.h.p) and candH <= b.h.p
            isPh := false
        if isPl and not na(b.l.p) and candL >= b.l.p
            isPl := false

    for j = r + 1 to r + l
        SwBar b = array.get(swHist, j)
        if isPh and not na(b.h.p) and candH <= b.h.p
            isPh := false
        if isPl and not na(b.l.p) and candL >= b.l.p
            isPl := false

    if isPh and (na(lastPhT) or cand.h.t != lastPhT)
        float y = candH
        line ln = line.new(
            x1 = cand.h.t, y1 = y,
            x2 = (extendRight ? time : extX2), y2 = y,
            xloc = xloc.bar_time,
            extend = (extendRight ? extend.right : extend.none),
            style = unmitStyle, width = unmitW, color = unmitHiCol)
        array.push(linesHi, ln)
        array.push(pricesHi, y)
        array.push(mitigHi, false)
        fTrim()
        lastPhT := cand.h.t

    if isPl and (na(lastPlT) or cand.l.t != lastPlT)
        float y = candL
        line ln = line.new(
            x1 = cand.l.t, y1 = y,
            x2 = (extendRight ? time : extX2), y2 = y,
            xloc = xloc.bar_time,
            extend = (extendRight ? extend.right : extend.none),
            style = unmitStyle, width = unmitW, color = unmitLoCol)
        array.push(linesLo, ln)
        array.push(pricesLo, y)
        array.push(mitigLo, false)
        fTrim()
        lastPlT := cand.l.t

// LTF bull/bear volume.
float bullVol = fBullVolSum(vdLtf)
float bearVol = fBearVolSum(vdLtf)
float totalVol = bullVol + bearVol

float bullPct = totalVol > 0 ? bullVol / totalVol : 0.5
bullPct := math.max(0.0, math.min(1.0, bullPct))
float bearPct = totalVol > 0 ? (1.0 - bullPct) : 0.5
bearPct := math.max(0.0, math.min(1.0, bearPct))

float brVolThr = math.max(0.0, math.min(1.0, brVolFiltPctIn / 100.0))

// Breakout detection and level updates.
bool useWick = brMode == "Wick"
bool didHighBreak = false
bool didLowBreak = false

string brkStyle = fLineStyle(brkStyleIn)

int hiCount = array.size(linesHi)
if hiCount > 0
    for i = hiCount - 1 to 0 by 1
        if not array.get(mitigHi, i)
            float lvl = array.get(pricesHi, i)
            bool br = useWick ? high > lvl : close > lvl
            if br
                bool volOk = not brVolFiltOn or (bullPct > brVolThr)
                if brVolFiltOn and not volOk
                    line lnDel = array.get(linesHi, i)
                    line.delete(lnDel)
                    array.remove(linesHi, i)
                    array.remove(pricesHi, i)
                    array.remove(mitigHi, i)
                else
                    array.set(mitigHi, i, true)
                    line ln = array.get(linesHi, i)
                    line.set_style(ln, brkStyle)
                    line.set_width(ln, brkW)
                    line.set_color(ln, brkHiCol)
                    line.set_extend(ln, extend.none)
                    line.set_x2(ln, time)
                    line.set_y2(ln, lvl)
                    didHighBreak := true

int loCount = array.size(linesLo)
if loCount > 0
    for i = loCount - 1 to 0 by 1
        if not array.get(mitigLo, i)
            float lvl = array.get(pricesLo, i)
            bool br = useWick ? low < lvl : close < lvl
            if br
                bool volOk = not brVolFiltOn or (bearPct > brVolThr)
                if brVolFiltOn and not volOk
                    line lnDel = array.get(linesLo, i)
                    line.delete(lnDel)
                    array.remove(linesLo, i)
                    array.remove(pricesLo, i)
                    array.remove(mitigLo, i)
                else
                    array.set(mitigLo, i, true)
                    line ln = array.get(linesLo, i)
                    line.set_style(ln, brkStyle)
                    line.set_width(ln, brkW)
                    line.set_color(ln, brkLoCol)
                    line.set_extend(ln, extend.none)
                    line.set_x2(ln, time)
                    line.set_y2(ln, lvl)
                    didLowBreak := true

hiCount := array.size(linesHi)
if hiCount > 0
    for i = 0 to hiCount - 1
        if not array.get(mitigHi, i)
            float lvl = array.get(pricesHi, i)
            line ln = array.get(linesHi, i)
            line.set_color(ln, unmitHiCol)
            line.set_width(ln, unmitW)
            line.set_style(ln, unmitStyle)
            line.set_y2(ln, lvl)
            if extendRight
                line.set_extend(ln, extend.right)
                line.set_x2(ln, time)
            else
                line.set_extend(ln, extend.none)
                line.set_x2(ln, extX2)

loCount := array.size(linesLo)
if loCount > 0
    for i = 0 to loCount - 1
        if not array.get(mitigLo, i)
            float lvl = array.get(pricesLo, i)
            line ln = array.get(linesLo, i)
            line.set_color(ln, unmitLoCol)
            line.set_width(ln, unmitW)
            line.set_style(ln, unmitStyle)
            line.set_y2(ln, lvl)
            if extendRight
                line.set_extend(ln, extend.right)
                line.set_x2(ln, time)
            else
                line.set_extend(ln, extend.none)
                line.set_x2(ln, extX2)

// Breakout fill calculation.
fillOpen := na
fillHigh := na
fillLow := na
fillClose := na
fillCol := na

oppOpen := na
oppHigh := na
oppLow := na
oppClose := na
oppCol := na

breakOutlineCol := na

dbgDoLabel := false

bool breakBar = didHighBreak or didLowBreak

if breakBar
    bool isBullBreak = didHighBreak
    breakOutlineCol := isBullBreak ? bullBase : bearBase

    float bodyTop = math.max(open, close)
    float bodyBtm = math.min(open, close)
    float bodyRng = bodyTop - bodyBtm
    if bodyRng <= 0
        float pad0 = math.max(high - low, syminfo.mintick) * 0.35
        bodyTop := close + pad0
        bodyBtm := close - pad0
        bodyRng := bodyTop - bodyBtm

    if isBullBreak
        float cut = bodyBtm + bodyRng * bullPct

        fillOpen := bodyBtm
        fillClose := cut
        fillHigh := math.max(fillOpen, fillClose)
        fillLow := math.min(fillOpen, fillClose)
        fillCol := bullBase

        oppOpen := cut
        oppClose := bodyTop
        oppHigh := math.max(oppOpen, oppClose)
        oppLow := math.min(oppOpen, oppClose)
        oppCol := bearBase
    else
        float cut = bodyTop - bodyRng * bearPct

        fillOpen := cut
        fillClose := bodyTop
        fillHigh := math.max(fillOpen, fillClose)
        fillLow := math.min(fillOpen, fillClose)
        fillCol := bearBase

        oppOpen := bodyBtm
        oppClose := cut
        oppHigh := math.max(oppOpen, oppClose)
        oppLow := math.min(oppOpen, oppClose)
        oppCol := bullBase

    if dbgShow
        dbgLblTxt := fFmt(bullVol) + " (" + fPctStr(bullPct) + ") | " + fFmt(bearVol) + " (" + fPctStr(bearPct) + ")"
        float pad = math.max(high - low, syminfo.mintick) * 0.25
        dbgLblY := isBullBreak ? (high + pad) : (low - pad)
        dbgIsBull := isBullBreak
        dbgDoLabel := true
//#endregion CALCULATIONS

//#region VISUALS
if dbgDoLabel
    label.new(
        x = bar_index,
        y = dbgLblY,
        text = dbgLblTxt,
        style = dbgIsBull ? label.style_label_down : label.style_label_up,
        textcolor = dbgIsBull ? bullBase : bearBase,
        color = color.new(color.black, 100),
        size = size.small, force_overlay = true)

plotcandle(
    oppOpen, oppHigh, oppLow, oppClose,
    title = "Breakout Delta Top/Bottom (Opp Segment)",
    color = oppCol, wickcolor = na, bordercolor = na)

plotcandle(
    fillOpen, fillHigh, fillLow, fillClose,
    title = "Breakout Delta Top/Bottom (Main Segment)",
    color = fillCol, wickcolor = na, bordercolor = na)

plotcandle(
    open, high, low, close,
    title = "Breakout Outline",
    color = na,
    wickcolor = breakOutlineCol,
    bordercolor = breakOutlineCol)
//#endregion VISUALS
````
