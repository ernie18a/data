# Delta and CVD

- url: https://www.tradingview.com/script/LyouoA7o-Delta-and-CVD/
- type: indicator
- pine_id: PUB;715f4fa46178411dbd65b98eabcabbd6
- version: 1.0

## Description

# ⚡delta and cvd

wizard alpha delta and cvd is an order-flow indicator designed to visualize the relationship between **volume delta, cumulative volume delta and price** in a dedicated pane.

the indicator combines individual delta columns for every candle with a cumulative volume delta curve, allowing traders to observe how buying and selling pressure develops behind price movement.

its purpose is not simply to show whether a candle is bullish or bearish, but to provide another perspective on the participation occurring inside each bar and how that pressure accumulates over time.

---

## 📊 volume delta

each histogram column represents the estimated volume delta of one chart bar.

**positive delta** indicates greater estimated buying participation.

**negative delta** indicates greater estimated selling participation.

the zero line separates positive and negative pressure, making changes in aggressor balance easy to identify.

larger columns represent stronger imbalance between estimated buying and selling volume.

---

## 🔬 intrabar delta

the default calculation uses lower-timeframe intrabar data.

the indicator automatically selects a lower timeframe according to the active chart timeframe:

**up to 5 minutes → 1 minute**

**up to 1 hour → 5 minutes**

**up to 4 hours → 15 minutes**

**higher timeframes → 60 minutes**

the intrabar timeframe can also be selected manually from the settings.

within those lower-timeframe bars, volume is classified according to candle direction and accumulated into the higher-timeframe bar.

this provides a more granular estimation than relying only on the geometry of the main chart candle.

---

## 📐 candle geometry mode

a second delta source is available: **candle geometry**.

in this mode, the position of the close inside the candle range determines the estimated buy/sell distribution.

a close near the upper part of the candle assigns a greater portion of volume toward buying pressure, while a close near the lower part assigns more toward selling pressure.

this provides an alternative when intrabar analysis is not desired or lower-timeframe information is limited.

---

# 🟡 cumulative volume delta — cvd

cvd accumulates individual bar delta over time.

instead of examining each bar independently, it shows how estimated buying and selling pressure develops across a larger sequence of candles.

a rising cvd means positive delta is accumulating.

a falling cvd means negative delta is accumulating.

this makes cvd particularly useful for comparing **participation with price structure**.

the gold curve is dynamically scaled across the pane so that its internal structure remains clearly visible alongside the delta histogram.

---

# ⚓ cvd anchor modes

the indicator includes three different accumulation methods.

## visible range

cvd begins from the left edge of the currently visible chart.

when the visible chart range changes, the analysis window changes with it.

this mode is useful for studying a specific structure simply by zooming or moving the chart.

it can be used to inspect:

• an impulse  
• a consolidation  
• a breakout  
• a reversal structure  
• a local trading range

---

## session

cvd resets when a new selected session begins.

the session timeframe is configurable.

for example, using a daily session allows each trading day to begin with a fresh cumulative delta calculation.

this makes it easier to compare how order-flow pressure develops during individual sessions.

---

## continuous

continuous mode keeps accumulating delta without resetting at the visible range or session boundary.

this provides a broader view of cumulative pressure across the historical bars stored by the indicator.

the number of stored bars can be adjusted in the settings.

---

# 📈 reading the cvd

cvd becomes especially useful when compared directly with price.

### price rising + cvd rising

price and estimated buying pressure are moving in the same direction.

buyers are contributing positively to the move.

### price falling + cvd falling

price and estimated selling pressure are moving in the same direction.

selling pressure is accompanying the decline.

### price rising + cvd weakening

price continues higher while cumulative buying pressure fails to confirm the movement.

this creates an order-flow disagreement worth monitoring.

### price falling + cvd strengthening

price continues lower while cumulative delta stops confirming the decline or begins moving higher.

this can reveal another form of disagreement between price movement and underlying estimated participation.

these conditions should be interpreted as **context**, not automatic reversal signals.

---

# 🔎 delta vs cvd

delta and cvd answer two different questions.

**delta asks:**

what happened inside this individual bar?

**cvd asks:**

what has been accumulating across the sequence of bars?

a single large positive delta candle can therefore occur while the broader cvd structure remains negative.

similarly, several smaller positive delta bars can gradually reverse the direction of cvd even without one exceptionally large candle.

using both together provides short-term and cumulative order-flow context.

---

# 🎓 mini tutorial

## 1. choose the delta source

start with **intrabar** mode.

leave the intrabar timeframe on **auto** for general use.

manual lower-timeframe selection can be used when you want direct control over the granularity of the calculation.

---

## 2. choose the cvd anchor

use **visible range** when analyzing a specific structure on the chart.

use **session** when studying intraday participation session by session.

use **continuous** when you want cumulative pressure across a longer historical sequence.

---

## 3. read the histogram first

observe the delta columns around important price movements.

look for:

**expanding positive delta**

**expanding negative delta**

**rapid transitions around zero**

**isolated extreme delta bars**

**sequences dominated by one side**

this shows the immediate balance of estimated buying and selling participation.

---

## 4. read the cvd structure

next, observe whether cvd is:

**rising**

**falling**

**flattening**

**accelerating**

or **changing direction**

do not focus only on the absolute cvd number.

the evolution of the curve is often more informative than the raw value itself.

---

## 5. compare cvd with price

this is the central workflow.

if price makes higher highs, check whether cvd is also progressing higher.

if price makes lower lows, check whether cvd is also progressing lower.

agreement between both provides confirmation of participation.

disagreement tells you that price and estimated order flow are behaving differently and deserves closer examination.

---

## 6. inspect important price zones

the indicator becomes more useful when delta behavior is studied around meaningful market structure.

examples include:

**support and resistance**

**previous highs and lows**

**breakout levels**

**range boundaries**

**volume profile poc**

**vah and val**

**hvn and lvn**

a large delta event in the middle of random price action has different significance from the same event occurring at an important structural level.

---

# 🧠 practical workflow

**price structure → key level → bar delta → cvd direction → confirmation or disagreement → price reaction**

first identify what price is doing.

then locate the important structural area.

observe the delta generated as price interacts with that area.

check whether cumulative delta confirms the movement.

finally, wait for price itself to confirm how the market responds.

---

# ⚔️ practical example

imagine price pushes above a previous high.

the first question is whether positive delta expands during the breakout.

the second question is whether cvd also establishes a stronger high.

if price, delta and cvd expand together, participation is aligned with the breakout.

if price reaches a new high while cvd fails to progress with it, the move contains an order-flow disagreement.

that disagreement alone does not define the next direction, but it provides valuable information about the internal structure of the move.

---

# 🛡️ important interpretation

wizard alpha delta and cvd should be used as an **order-flow confirmation and context tool**, not as a standalone buy or sell system.

delta estimates the balance of buying and selling participation for individual bars.

cvd transforms that information into a cumulative structure.

when combined with price action, market structure and volume-profile levels, the indicator provides a compact way to study whether participation is confirming, weakening or diverging from the movement visible on the chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6

indicator("Delta and CVD", shorttitle = "Delta and CVD", overlay = false, format = format.volume, max_polylines_count = 20, max_labels_count = 20, max_lines_count = 20)

const string G_FLOW  = "Order flow"
const string G_CVD   = "CVD"
const string G_STYLE = "Style"

string deltaSrc = input.string("Intrabar", "Delta source", options = ["Intrabar", "Candle geometry"], group = G_FLOW)
string ltfIn    = input.string("Auto", "Intrabar timeframe", options = ["Auto", "1", "3", "5", "15", "60"], group = G_FLOW)
string anchor   = input.string("Visible range", "CVD anchor", options = ["Visible range", "Session", "Continuous"], group = G_CVD)
string sessTfIn = input.timeframe("D", "Session", group = G_CVD)
bool   showCvd  = input.bool(true, "Show CVD line", group = G_CVD, inline = "c")
bool   glowOn   = input.bool(true, "Glow", group = G_CVD, inline = "c")
int    maxStore = input.int(3000, "Bars kept in memory", minval = 500, maxval = 5000, group = G_CVD)
color  cUp   = input.color(#00FFD1, "Buy", group = G_STYLE, inline = "k")
color  cDn   = input.color(#FF3B5C, "Sell", group = G_STYLE, inline = "k")
color  cGold = input.color(#FFD23F, "CVD", group = G_STYLE, inline = "k")

const color C_GRID  = #8092AA
const color C_MUTED = #738396
const color C_DARK  = #1A1405

// ───────────────────────────── Delta ─────────────────────────────────────
int    tfSec   = timeframe.in_seconds()
string ltfAuto = tfSec <= 300 ? "1" : tfSec <= 3600 ? "5" : tfSec <= 14400 ? "15" : "60"
string ltf     = ltfIn == "Auto" ? ltfAuto : ltfIn
[ltfO, ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, ltf, [open, close, volume], ignore_invalid_timeframe = true)
bool newSess = timeframe.change(sessTfIn)

f_intrabar(array<float> ao, array<float> ac, array<float> av) =>
    float b = 0.0
    float t = 0.0
    float prevDir = 0.0
    int n = na(av) ? 0 : array.size(av)
    if n > 0
        for i = 0 to n - 1
            float vi = nz(array.get(av, i))
            float oi = array.get(ao, i)
            float ci = array.get(ac, i)
            float d = ci > oi ? 1.0 : ci < oi ? -1.0 : prevDir
            if d > 0
                b := b + vi
            else if d == 0
                b := b + vi * 0.5
            prevDir := d
            t := t + vi
    [b, t]

f_v(float v) =>
    float a = math.abs(v)
    string sg = v < 0 ? "-" : ""
    string out = a >= 1e9 ? sg + str.tostring(a / 1e9, "0.00") + "B" : a >= 1e6 ? sg + str.tostring(a / 1e6, "0.00") + "M" : a >= 1e3 ? sg + str.tostring(a / 1e3, a >= 1e5 ? "0" : "0.0") + "K" : sg + str.tostring(a, a < 10 ? "0.00" : "0")
    out

f_sv(float v) =>
    string sg = v > 0 ? "+" : ""
    sg + f_v(v)

[ibBuy, ibTot] = f_intrabar(ltfO, ltfC, ltfV)
float geoFrac = high > low ? (close - low) / (high - low) : 0.5
float buyFrac = deltaSrc == "Intrabar" and ibTot > 0 ? ibBuy / ibTot : geoFrac
float vol0    = nz(volume)
float delta   = vol0 * (2 * buyFrac - 1)

// Delta columns
color dCol = delta >= 0 ? color.new(cUp, 58) : color.new(cDn, 55)
plot(delta, "Delta", color = dCol, style = plot.style_columns, histbase = 0)
hline(0, "Zero", color = color.new(C_GRID, 80), linestyle = hline.style_solid)

// Running CVD for the status line and data window
int leftT = chart.left_visible_bar_time
var float cvdRun = 0.0
bool resetNow = anchor == "Visible range" ? time == leftT : anchor == "Session" ? newSess : false
if resetNow
    cvdRun := 0.0
cvdRun := cvdRun + delta
float cvdShown = anchor == "Visible range" and time < leftT ? na : cvdRun
plot(cvdShown, "CVD", color = cGold, display = display.status_line + display.data_window)

// ───────────────────────────── Storage ────────────────────────────────────
var array<int>   aI = array.new<int>()
var array<int>   aT = array.new<int>()
var array<float> aD = array.new<float>()
var array<bool>  aS = array.new<bool>()
array.push(aI, bar_index)
array.push(aT, time)
array.push(aD, delta)
array.push(aS, newSess)
if array.size(aI) > maxStore
    array.shift(aI)
    array.shift(aT)
    array.shift(aD)
    array.shift(aS)

var array<polyline> gPolys  = array.new<polyline>()
var array<label>    gLabels = array.new<label>()

// ───────────────────────────── Redraw ─────────────────────────────────────
if barstate.islast and showCvd
    int np = array.size(gPolys)
    if np > 0
        for i = 0 to np - 1
            polyline.delete(array.get(gPolys, i))
    array.clear(gPolys)
    int nl = array.size(gLabels)
    if nl > 0
        for i = 0 to nl - 1
            label.delete(array.get(gLabels, i))
    array.clear(gLabels)

    int n = array.size(aT)
    int rightT = chart.right_visible_bar_time
    int i0 = -1
    int i1 = -1
    for i = 0 to n - 1
        int ti = array.get(aT, i)
        if ti >= leftT and ti <= rightT
            if i0 < 0
                i0 := i
            i1 := i
    if i0 < 0
        i0 := int(math.max(0, n - 150))
        i1 := n - 1

    // CVD across the visible window with the chosen anchor
    array<float> cv = array.new<float>()
    float run  = 0.0
    float cmin = na
    float cmax = na
    float mad  = 0.0
    if anchor == "Continuous" and i0 > 0
        for i = 0 to i0 - 1
            run := run + array.get(aD, i)
    if anchor == "Session"
        int sStart = 0
        for i = 0 to i0
            if array.get(aS, i)
                sStart := i
        if sStart < i0
            for i = sStart to i0 - 1
                run := run + array.get(aD, i)
    for i = i0 to i1
        if anchor == "Session" and array.get(aS, i) and i > i0
            run := 0.0
        float d = array.get(aD, i)
        run  := run + d
        mad  := math.max(mad, math.abs(d))
        cmin := na(cmin) ? run : math.min(cmin, run)
        cmax := na(cmax) ? run : math.max(cmax, run)
        array.push(cv, run)
    if cmax - cmin < 1e-9
        cmax := cmax + 1
        cmin := cmin - 1
    mad := math.max(mad, 1e-9)

    // Map CVD into the delta scale: full pane height like the desk
    float span = mad * 0.96
    array<chart.point> pts = array.new<chart.point>()
    int m = array.size(cv)
    if m > 0
        for j = 0 to m - 1
            float y = (array.get(cv, j) - cmin) / (cmax - cmin) * 2 * span - span
            array.push(pts, chart.point.from_index(array.get(aI, i0 + j), y))
    if glowOn
        array.push(gPolys, polyline.new(pts, line_color = color.new(cGold, 90), line_width = 9))
        array.push(gPolys, polyline.new(pts, line_color = color.new(cGold, 78), line_width = 6))
        array.push(gPolys, polyline.new(pts, line_color = color.new(cGold, 52), line_width = 3))
    array.push(gPolys, polyline.new(pts, line_color = cGold, line_width = 1))

    // Axis-style tags: last CVD, visible max and min
    if m > 0
        float lastC = array.get(cv, m - 1)
        float yLast = (lastC - cmin) / (cmax - cmin) * 2 * span - span
        int   xTag  = bar_index + 2
        array.push(gLabels, label.new(xTag, yLast, f_sv(lastC), color = cGold, textcolor = C_DARK, style = label.style_label_left, size = size.tiny, text_font_family = font.family_monospace))
        array.push(gLabels, label.new(xTag, span, f_v(cmax), color = color.new(cGold, 100), textcolor = C_MUTED, style = label.style_label_left, size = size.tiny, text_font_family = font.family_monospace))
        array.push(gLabels, label.new(xTag, -span, f_v(cmin), color = color.new(cGold, 100), textcolor = C_MUTED, style = label.style_label_left, size = size.tiny, text_font_family = font.family_monospace))
````
