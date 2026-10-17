# ha macd nemesis

- url: https://www.tradingview.com/script/jHlCAeUv-ha-macd-nemesis/
- type: indicator
- pine_id: PUB;995ec1c0e75f4a6bae85ce520517e267
- version: 1.0

## Description

HA Nemesis is a Heikin Ashi based MACD oscillator designed to make momentum shifts easier to read in a separate pane.

Instead of plotting a classic MACD only as two lines and a histogram, this script rebuilds the MACD movement into synthetic Heikin Ashi candles. The goal is to give a cleaner visual view of momentum direction, candle pressure, signal-line interaction, and possible exhaustion areas.

The indicator includes three display modes:

* Hybrid: shows the Heikin Ashi MACD candles with the histogram.
* MACD: focuses on the candle-style MACD structure.
* Histogram: focuses mainly on histogram expansion and contraction.

The blue candles represent bullish momentum pressure. The red candles represent bearish momentum pressure. The signal line can be used as a reference for momentum confirmation. When the Heikin Ashi MACD closes above the signal line, bullish pressure is improving. When it closes below the signal line, bearish pressure is increasing.

The upper red background bands mark extended bullish momentum areas where upside pressure may be stretched. The lower blue background bands mark extended bearish momentum areas where downside pressure may be stretched. These zones are not automatic reversal signals. They are visual areas where traders can watch for reaction, slowdown, or continuation.

The script also includes optional bar coloring modes:

* MidLine: colors bars based on whether the oscillator is above or below zero.
* Candles: colors bars based on the Heikin Ashi MACD candle direction.
* Signal Cross: colors bars based on the relationship between the HA MACD close and the signal line.
* Extremities: highlights potential extended momentum conditions.

Alerts are built around two main ideas:

1. Heikin Ashi MACD crossing the signal EMA.
2. Heikin Ashi MACD candle color changing from bearish to bullish or bullish to bearish.

To reduce weak signals, the alert module uses candle filters. It can ignore small, weak, or doji-like HA MACD candles. If tracking is enabled, a raw signal can remain pending until a valid candle confirms the move, instead of firing immediately on a weak candle.

Beginner example 1:
The oscillator has been red and below the signal line. A blue Heikin Ashi MACD candle appears and closes above the signal line. If the candle passes the body and range filters, the alert can mark a bullish momentum shift. A beginner can then check whether price is also reclaiming a support level, breaking a local structure, or moving with trend confirmation.

Beginner example 2:
The oscillator has been blue and above the signal line. A red Heikin Ashi MACD candle appears and closes below the signal line. If the move is confirmed by a valid candle, it can warn that bullish momentum is fading. This can help traders avoid late long entries or watch for a possible pullback.

Beginner example 3:
The oscillator reaches the upper red band and then starts printing weaker blue candles or flips red. This can suggest that upside momentum is losing strength. It does not mean price must reverse, but it gives a useful warning to slow down and check resistance, volume, and price structure.

Beginner example 4:
The oscillator reaches the lower blue band and then starts printing stronger blue candles or crosses above the signal line. This can suggest that downside pressure is weakening. It is usually safer to wait for price confirmation rather than entering only because the oscillator is in an extreme zone.

Suggested use:
HA Nemesis is best used as a momentum-reading tool. It can help identify when pressure is shifting, when momentum is stretched, and when a cleaner candle-based confirmation appears. It works well alongside support and resistance, trend direction, volume, or a higher-timeframe bias.

Useful settings:

* Use Hybrid mode for the most complete visual read.
* Use Histogram mode when you want a cleaner momentum-only view.
* Keep the weak candle filter enabled if you want fewer low-quality alerts.
* Increase the minimum body or range values to make alerts more selective.
* Use bar coloring only if you want the oscillator state reflected directly on price bars.

Limitations:
This indicator does not predict future price movement. Strong trends can remain extended for a long time, and crosses can fail during choppy markets. Alerts should be treated as momentum events, not as guaranteed buy or sell signals. Always combine the indicator with price action and proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("HA macd nemesis", "Ha mcd", overlay=false, max_lines_count=100, max_labels_count=50)

type bar
    float o = na
    float h = na
    float l = na
    float c = na

type osc
    bar   b = na
    float s = na
    float h = na

method src(bar b, simple string src) =>
    float x = switch src
        "open"  => b.o
        "high"  => b.h
        "low"   => b.l
        "close" => b.c
        "oc2"   => math.avg(b.o, b.c)
        "hl2"   => math.avg(b.h, b.l)
        "hlc3"  => math.avg(b.h, b.l, b.c)
        "ohlc4" => math.avg(b.o, b.h, b.l, b.c)
        "hlcc4" => math.avg(b.h, b.l, b.c, b.c)
    x

method ha(bar b, simple bool p = true) =>
    var bar x = bar.new()
    x.c := b.src("ohlc4")
    float prevXO = barstate.isfirst ? na : (x[1]).o
    float prevOc2 = barstate.isfirst or na(prevXO) ? b.src("oc2") : nz(((x[1]).src("oc2")))
    x := bar.new(prevOc2, math.max(b.h, math.max(x.o, x.c)), math.min(b.l, math.min(x.o, x.c)), x.c)
    p ? x : b

method stmc(bar b, simple string src, simple int flen, simple int slen, simple string sig, simple int clen) =>
    float emaFast = ta.ema(b.src(src), flen)
    float emaSlow = ta.ema(b.src(src), slen)
    float emaRng  = ta.ema(b.h - b.l, slen)
    float x = (emaFast - emaSlow) / emaRng * 100
    bar z = bar.new(x[1], math.max(x, x[1]), math.min(x, x[1]), x).ha()
    float s = ta.ema(z.src(sig), clen)
    osc.new(z, s, z.c - s)

const string gm = "MACD Settings", const string gu = "UI Options", const string gb = "Background Bands", const string gx = "Exports"

src  = input.string("close", "Source", ["open","high","low","close","hl2","hlc3","ohlc4","hlcc4"], group=gm)
fast = input.int(12, "Fast Length", group=gm)
slow = input.int(26, "Slow Length", group=gm)
sigb = input.bool(true, "Signal", inline="1", group=gm)
sigs = input.string("close", "Source", ["open","high","low","close","hl2","hlc3","ohlc4","hlcc4"], inline="1", group=gm)
sigl = input.int(9, "Length", inline="1", group=gm)

mode = input.string("Hybrid", "Display Mode", ["Hybrid","MACD","Histogram"], group=gu)
revt = input.int(100, "Reversion Threshold", [100,150], group=gu)
colb = input.string("None", "Bar Coloring", ["None","MidLine","Candles","Sig Cross","Extremities"], group=gu)
hol  = input.bool(true, "Hollow Candles", group=gu)

blueInner = input.color(color.rgb(33, 125, 255), "Lower Band Blue (Inner)", group=gb)
blueOuter = input.color(color.rgb(0, 200, 255), "Lower Band Blue (Outer)", group=gb)

exportMode = input.string("Full", "Hidden Export Series", options=["Off","Minimal","Full"], group=gx)

bar b = bar.new(open, high, low, close)
osc o = b.stmc(src, fast, slow, sigs, sigl)

const color colup = color.rgb(33, 125, 255)
const color coldn = #ff0048
const color colhu = color.rgb(94, 255, 0)
const color colhd = #f90303
var color colnt = chart.fg_color

float hPrev = barstate.isfirst ? o.h : (o[1]).h
color colh = o.h > 0 ? (o.h > hPrev ? color.new(colhu, 20) : color.new(colhu, 30)) : (o.h > hPrev ? color.new(colhd, 20) : color.new(colhd, 30))

color haColor = switch
    o.b.c > o.b.o => colup
    o.b.c < o.b.o => coldn
    => colnt

m   = hline(0, "Mid Line", chart.fg_color, hline.style_solid)
min = hline(mode != "Histogram" ? -200 : -100, display=display.none)
ll  = hline(mode != "Histogram" ? -150 : -75,  display=display.none)
hl  = hline(mode != "Histogram" ? -100 : -50,  display=display.none)
max = hline(mode != "Histogram" ? +200 : +100, display=display.none)
hh  = hline(mode != "Histogram" ? +150 : +75,  display=display.none)
lh  = hline(mode != "Histogram" ? +100 : +50,  display=display.none)

h  = plot(mode != "Histogram" and sigb ? o.s : na, "Signal", colnt)
mc = plot(mode != "MACD" ? o.h : na, "H", colh, 1, plot.style_columns)

fill(lh, hh,  color.new(coldn, 90))
fill(hh, max, color.new(coldn, 80))

fill(ll, hl,  color.new(blueInner, 90))
fill(ll, min, color.new(blueOuter, 80))

plotcandle(mode != "Histogram" ? o.b.o : na,
           mode != "Histogram" ? o.b.h : na,
           mode != "Histogram" ? o.b.l : na,
           mode != "Histogram" ? o.b.c : na,
           "𝗠𝗔𝗖𝗗",
           hol ? (o.b.c > o.b.o ? na : haColor) : haColor,
           haColor,
           bordercolor=haColor)

color col = switch colb
    "MidLine"     => o.b.c > 0     ? colup : coldn
    "Candles"     => o.b.c > o.b.o ? colup : coldn
    "Sig Cross"   => o.s > o.b.c   ? coldn : colup
    "Extremities" => o.b.c > revt  ? coldn : o.b.c < -revt ? colup : color.new(colnt, 25)
    "None"        => na
barcolor(col)

const string ga = "Alerts"

alCrossOn = input.bool(true, "Alerts: HA cross Signal(EMA)", group=ga)
alColorOn = input.bool(true, "Alerts: HA color change", group=ga)

minBody   = input.float(5.0, "Min HA Body (abs close-open)", step=0.1, group=ga)
useFilter  = input.bool(true, "Filter: exclude weak & doji", group=ga)
minRange   = input.float(8.0, "  Min HA Range (high-low)", step=0.1, group=ga)
minBodyPct = input.float(35.0, "  Weak candle: min body% of range", step=1.0, minval=0.0, maxval=100.0, group=ga)
dojiPct    = input.float(10.0, "  Doji: max body% of range", step=1.0, minval=0.0, maxval=100.0, group=ga)

trackOn    = input.bool(true, "Tracking: keep signal until valid candle", group=ga)
maxWait    = input.int(20, "  Tracking: max bars to wait (0=∞)", minval=0, group=ga)

float haO = o.b.o, haH = o.b.h, haL = o.b.l, haC = o.b.c
bool bullish = haC > haO
bool bearish = haC < haO

float haBody  = math.abs(haC - haO)
float haRange = math.abs(haH - haL)
float bodyPr  = haRange == 0.0 ? 0.0 : (haBody / haRange) * 100.0

bool bodyOK  = haBody >= minBody
bool rangeOK = haRange >= minRange
bool weakOK  = bodyPr >= minBodyPct
bool dojiOK  = bodyPr > dojiPct
bool filtOK  = useFilter ? (bodyOK and rangeOK and weakOK and dojiOK) : bodyOK

float sigLine = o.s

bool xCrossUp = ta.crossover(haC, sigLine)
bool xCrossDn = ta.crossunder(haC, sigLine)

bool rawCrossUp   = alCrossOn and bullish and xCrossUp
bool rawCrossDown = alCrossOn and bearish and xCrossDn

bool prevBullish = bullish[1]
bool prevBearish = bearish[1]

bool rawColorUp   = alColorOn and bullish and prevBearish
bool rawColorDown = alColorOn and bearish and prevBullish

var bool pendCrossUp = false
var bool pendCrossDn = false
var bool pendColorUp = false
var bool pendColorDn = false
var int  pendCrossUpBar = na
var int  pendCrossDnBar = na
var int  pendColorUpBar = na
var int  pendColorDnBar = na

if trackOn
    if rawCrossUp and not filtOK
        pendCrossUp := true, pendCrossUpBar := bar_index
    if rawCrossDown and not filtOK
        pendCrossDn := true, pendCrossDnBar := bar_index
    if rawColorUp and not filtOK
        pendColorUp := true, pendColorUpBar := bar_index
    if rawColorDown and not filtOK
        pendColorDn := true, pendColorDnBar := bar_index

bool expUp  = maxWait > 0 and not na(pendCrossUpBar) and (bar_index - pendCrossUpBar) > maxWait
bool expDn  = maxWait > 0 and not na(pendCrossDnBar) and (bar_index - pendCrossDnBar) > maxWait
bool expCU  = maxWait > 0 and not na(pendColorUpBar) and (bar_index - pendColorUpBar) > maxWait
bool expCD  = maxWait > 0 and not na(pendColorDnBar) and (bar_index - pendColorDnBar) > maxWait

if expUp
    pendCrossUp := false, pendCrossUpBar := na
if expDn
    pendCrossDn := false, pendCrossDnBar := na
if expCU
    pendColorUp := false, pendColorUpBar := na
if expCD
    pendColorDn := false, pendColorDnBar := na

if pendCrossUp and haC < sigLine
    pendCrossUp := false, pendCrossUpBar := na
if pendCrossDn and haC > sigLine
    pendCrossDn := false, pendCrossDnBar := na
if pendColorUp and bearish
    pendColorUp := false, pendColorUpBar := na
if pendColorDn and bullish
    pendColorDn := false, pendColorDnBar := na

bool fireCrossUp = (rawCrossUp and filtOK) or (trackOn and pendCrossUp and filtOK and bullish and haC > sigLine)
bool fireCrossDn = (rawCrossDown and filtOK) or (trackOn and pendCrossDn and filtOK and bearish and haC < sigLine)

bool fireColorUp = (rawColorUp and filtOK) or (trackOn and pendColorUp and filtOK and bullish)
bool fireColorDn = (rawColorDown and filtOK) or (trackOn and pendColorDn and filtOK and bearish)

if fireCrossUp
    pendCrossUp := false, pendCrossUpBar := na
if fireCrossDn
    pendCrossDn := false, pendCrossDnBar := na
if fireColorUp
    pendColorUp := false, pendColorUpBar := na
if fireColorDn
    pendColorDn := false, pendColorDnBar := na

alertcondition(fireCrossUp, title="NEMESIS: HA Blue crosses above Signal(EMA) (tracked)", message="NEMESIS: HA BLUE above Signal EMA (o.s) + valid candle (tracked)")
alertcondition(fireCrossDn, title="NEMESIS: HA Red crosses below Signal(EMA) (tracked)", message="NEMESIS: HA RED below Signal EMA (o.s) + valid candle (tracked)")
alertcondition(fireColorUp, title="NEMESIS: HA color change Red→Blue (tracked)", message="NEMESIS: HA color change RED→BLUE + valid candle (tracked)")
alertcondition(fireColorDn, title="NEMESIS: HA color change Blue→Red (tracked)", message="NEMESIS: HA color change BLUE→RED + valid candle (tracked)")

triColUp = color.rgb(33, 125, 255)
triColDn = #ff0048

if fireCrossUp
    label.new(bar_index, haL, "▲", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, textcolor=triColUp, color=color.new(triColUp, 100), size=size.tiny)
if fireCrossDn
    label.new(bar_index, haH, "▼", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, textcolor=triColDn, color=color.new(triColDn, 100), size=size.tiny)
if fireColorUp
    label.new(bar_index, haL, "▲", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, textcolor=triColUp, color=color.new(triColUp, 100), size=size.tiny)
if fireColorDn
    label.new(bar_index, haH, "▼", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, textcolor=triColDn, color=color.new(triColDn, 100), size=size.tiny)

bool expMin = exportMode != "Off"
bool expAll = exportMode == "Full"

plot(expMin ? o.b.o : na, "open", editable=false, display=display.none)
plot(expMin ? o.b.h : na, "high", editable=false, display=display.none)
plot(expMin ? o.b.l : na, "low", editable=false, display=display.none)
plot(expMin ? o.b.c : na, "close", editable=false, display=display.none)
plot(expAll ? o.b.src("hl2")   : na, "hl2", editable=false, display=display.none)
plot(expAll ? o.b.src("hlc3")  : na, "hlc3", editable=false, display=display.none)
plot(expAll ? o.b.src("ohlc4") : na, "ohlc4", editable=false, display=display.none)
plot(expAll ? o.b.src("hlcc4") : na, "hlcc4", editable=false, display=display.none)
````
