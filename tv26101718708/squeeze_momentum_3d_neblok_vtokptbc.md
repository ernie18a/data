# Squeeze Momentum 3D [NeBlok]

- url: https://www.tradingview.com/script/VTOKPTBC-Squeeze-Momentum-3D-NeBlok/
- type: indicator
- pine_id: PUB;cb6db39d0fb143429e863053028c67b9
- version: 1.0

## Description

SQUEEZE MOMENTUM 3D [NeBlok]

Squeeze Momentum 3D finds periods when the market is coiling (volatility compressing) and then tells you when that energy releases and in which direction. It combines a three-tier squeeze engine, ATR-normalized momentum, graded breakout signals, compression boxes on the price chart, an EMA trend overlay, and an extruded 3D histogram.

Concept credit: The "Bollinger Bands inside Keltner Channels" squeeze idea comes from John Carter's TTM Squeeze. This script is written from scratch, and the tiering, ATR normalization, signal grading, compression boxes, trend overlay, dashboard and 3D rendering are original to this version.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1) The Squeeze Engine
The script compares the width of the Bollinger Bands to the width of the Keltner Channels. When the Bollinger Bands contract inside the Keltner Channels, volatility is compressed and the market is "in a squeeze." Instead of a simple on/off reading, compression is graded into three tiers:

- HIGH compression (amber dots): the tightest squeezes. Bollinger width is inside 1.0x the Keltner range.
- MID compression (red dots): a standard squeeze. Inside 1.5x.
- LOW compression (gray dots): early or mild compression. Inside 2.0x.
- NO squeeze (green dots): volatility is expanding.

The dots run along the zero line of the indicator pane. You choose which tier counts as "in squeeze" (default: Mid).

2) Momentum
The histogram measures how far price has moved from its equilibrium, defined as a blend of the recent high/low midpoint and an EMA. That distance is smoothed with a linear regression. By default, momentum is divided by ATR, so the readings are expressed in ATR units. A reading of 1.5 means roughly the same thing on MES, NQ, QQQ, BTC or any other symbol.

Histogram colors:
- Bright cyan: bullish momentum and rising
- Dark teal: bullish momentum but fading
- Bright magenta: bearish momentum and falling
- Dark magenta: bearish momentum but fading

Color intensity scales with the strength of the reading relative to the last 100 bars, so the strongest pushes stand out.

3) Fire Signals
A "fire" happens when a qualified squeeze (one that lasted at least the minimum number of bars, default 6) releases. The direction comes from the momentum reading at the moment of release. Each fire is graded:

- SQZ A (large label): momentum direction, momentum slope and the EMA trend all agree. This is the higher-quality signal.
- B (small triangle): the squeeze released, but not everything is aligned. Treat it as a heads-up, not a trigger.

Squeezes that release before the minimum bar count are ignored. They produce no signal and no box.

4) Compression Boxes
On the price chart, each qualified squeeze is outlined with a dashed box showing the high and low of the coil, labeled with how many bars it lasted. The box's color reflects the squeeze tier. These ranges give you natural reference levels: a breakout that holds outside the box confirms the release, and a quick return inside it is a warning sign.

5) EMA Trend Overlay
A fast EMA (9) and slow EMA (21) are drawn on the price chart. A "+" marks each cross: green for bullish, red for bearish. The EMA relationship is also used to grade fire signals.

6) Dashboard
A compact table shows the current squeeze tier, bars spent in the squeeze, the BB/KC ratio (lower = tighter), momentum value and direction, EMA trend, and the most recent fire with how many bars ago it happened.

7) 3D Histogram
The most recent bars are drawn as extruded 3D prisms. Bullish bars cap on top and bearish bars cap on the bottom, so bars always extrude away from zero. Because TradingView limits the number of drawing objects per script, 3D rendering applies to the most recent 100 bars by default (up to 120). Older bars display as standard flat columns. 3D can be turned off in the settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: Watch for the coil.
When the dots turn red or amber, the market is compressing. Longer squeezes and higher tiers tend to precede larger moves. The compression box shows you the range that is building.

Step 2: Read the momentum while in the squeeze.
Momentum often starts leaning one way before the release. A histogram that is rising toward or above zero while in a squeeze suggests the break may come to the upside, and vice versa.

Step 3: Act on the release, not the squeeze.
The squeeze tells you something is building. The fire tells you it has started. SQZ A signals have full alignment. B signals deserve extra confirmation.

Step 4: Use the box for structure.
Many traders place stops back inside or beyond the opposite side of the compression box and watch for price to hold outside the range after the fire.

Step 5: Manage the trade with momentum.
When the histogram shifts from the bright color to the fading color, momentum is slowing. That is a common place to tighten stops or take partial profits.

Tips
- Signals are confirmed on bar close. On the live (unclosed) bar, the squeeze tier and signals can change until the bar closes. Historical signals do not repaint.
- Checking a higher timeframe for direction and using this indicator on a lower timeframe for timing can help filter out weaker signals.
- Tighter markets or faster timeframes may benefit from a higher minimum bar count. Slower markets may need a lower one.
- Pair the signals with your own risk management. No indicator works on its own.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Squeeze Engine: Length, Bollinger standard deviation, Keltner multipliers for each tier, the minimum tier counted as a squeeze, and the minimum bars required before a fire counts.

Momentum: Momentum length, ATR normalization on/off, ATR length, and an optional momentum wave line.

Trend Overlay: Fast and slow EMA lengths, cross markers, and whether A-grade signals require EMA trend alignment.

Price Chart Visuals: Compression boxes, fire signals, optional squeeze shading on the price chart, and optional candle coloring by momentum.

3D Histogram: 3D on/off, number of 3D bars, bar face width, and horizontal and vertical depth. Keep face width plus horizontal depth under 1.0 so neighboring bars don't overlap.

Colors & Dashboard: Every color is customizable, and the dashboard can be moved to any corner or hidden.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Enable the alert types you want in the settings (Squeeze Fire, Squeeze ON, EMA Cross). Then create an alert on this indicator and choose "Any alert() function call." All alerts trigger once per bar close and include the ticker, signal type, grade, squeeze length and closing price.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This script is provided for educational and informational purposes only. It is not financial, investment or trading advice, and it is not a recommendation to buy or sell any security, futures contract, cryptocurrency or other financial instrument.

Trading involves substantial risk of loss and is not suitable for every investor. Past performance of any signal, pattern or indicator does not guarantee future results. Squeeze signals can and do fail, and markets can move against any position.

You are solely responsible for your own trading decisions. Always do your own research, test any tool before using it with real capital, and consider consulting a licensed financial professional. The author accepts no liability for any losses resulting from the use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

//@version=6
// ════════════════════════════════════════════════════════════════════════
//  Squeeze Momentum 3D [NeBlok]
//  © NeBlok — free community script
//
//  What it does
//   • Volatility compression engine: Bollinger width vs Keltner width,
//     graded into three tiers (Low / Mid / High compression)
//   • ATR-normalized linear-regression momentum, so readings compare
//     across symbols and timeframes (MES, NQ, QQQ, BTC ...)
//   • Compression boxes on the price chart mapping each squeeze range
//   • Graded "fire" signals when a qualified squeeze releases
//       A = momentum direction + slope + EMA trend all aligned
//       B = release without full alignment
//   • Fast/slow EMA trend overlay with cross markers on the price chart
//   • Extruded 3D histogram on the most recent bars
//
//  Concept credit: the Bollinger-inside-Keltner squeeze idea comes from
//  John Carter's TTM Squeeze. This implementation is written from scratch.
// ════════════════════════════════════════════════════════════════════════
indicator("Squeeze Momentum 3D [NeBlok]", shorttitle = "SQZ3D [NeBlok]", overlay = false, precision = 2, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────── INPUTS ──────────────────────────────────
grpS = "Squeeze Engine"
sqzLen   = input.int(20, "Length", minval = 5, group = grpS)
bbMult   = input.float(2.0, "Bollinger Std Dev", minval = 0.5, step = 0.1, group = grpS)
kcHigh   = input.float(1.0, "Keltner Mult — High compression", minval = 0.1, step = 0.1, group = grpS)
kcMid    = input.float(1.5, "Keltner Mult — Mid compression", minval = 0.1, step = 0.1, group = grpS)
kcLow    = input.float(2.0, "Keltner Mult — Low compression", minval = 0.1, step = 0.1, group = grpS)
minTierS = input.string("Mid", "Minimum tier counted as 'in squeeze'", options = ["Low", "Mid", "High"], group = grpS)
minBars  = input.int(6, "Min bars in squeeze before a fire counts", minval = 1, group = grpS, tooltip = "Short squeezes that release before this many bars are ignored (no fire signal, no box).")

grpM = "Momentum"
momLen   = input.int(20, "Momentum Length", minval = 5, group = grpM)
normATR  = input.bool(true, "Normalize by ATR", group = grpM, tooltip = "Expresses momentum in ATR units so the same readings mean the same thing on MES, NQ, QQQ or BTC.")
atrLen   = input.int(14, "ATR Length (normalization)", minval = 1, group = grpM)
showWave = input.bool(false, "Show momentum wave line", group = grpM)

grpT = "Trend Overlay (price chart)"
showEMAs      = input.bool(true, "Show fast/slow EMAs", group = grpT)
fastLen       = input.int(9, "Fast EMA", minval = 1, group = grpT)
slowLen       = input.int(21, "Slow EMA", minval = 1, group = grpT)
showX         = input.bool(true, "Mark EMA crosses (+)", group = grpT)
useTrendGrade = input.bool(true, "Require EMA trend for A-grade fires", group = grpT)

grpP = "Price Chart Visuals"
showBoxes = input.bool(true, "Compression boxes", group = grpP)
showFire  = input.bool(true, "Fire signals", group = grpP)
showSqzBg = input.bool(false, "Shade price chart during squeeze", group = grpP)
colorBars = input.bool(false, "Color candles by momentum", group = grpP)

grp3 = "3D Histogram"
use3D    = input.bool(true, "3D rendering", group = grp3)
n3D      = input.int(100, "3D bars (most recent)", minval = 10, maxval = 120, group = grp3, tooltip = "TradingView caps drawing objects, so 3D is applied to the most recent bars. Older bars use flat columns.")
barWidth = input.float(0.55, "Front face width (fraction of bar)", minval = 0.2, maxval = 0.8, step = 0.05, group = grp3, tooltip = "Keep width + horizontal depth under 1.0 so neighboring bars don't overlap.")
depthX   = input.float(0.28, "Depth — horizontal (fraction of bar)", minval = 0.05, maxval = 0.4, step = 0.01, group = grp3)
depthY   = input.float(0.06, "Depth — vertical (fraction of range)", minval = 0.0, maxval = 0.2, step = 0.01, group = grp3)

grpC = "Colors"
cUpStrong = input.color(#00E5FF, "Bull — rising", group = grpC)
cUpWeak   = input.color(#00788A, "Bull — fading", group = grpC)
cDnStrong = input.color(#FF2E88, "Bear — falling", group = grpC)
cDnWeak   = input.color(#8A1A50, "Bear — fading", group = grpC)
cSqzHigh  = input.color(#FFB300, "Squeeze — High", group = grpC)
cSqzMid   = input.color(#FF5252, "Squeeze — Mid", group = grpC)
cSqzLow   = input.color(#78909C, "Squeeze — Low", group = grpC)
cSqzOff   = input.color(#00C853, "No squeeze", group = grpC)
cFast     = input.color(#FF7043, "Fast EMA", group = grpC)
cSlow     = input.color(#43A047, "Slow EMA", group = grpC)
dashPos   = input.string("Top Right", "Dashboard", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Hidden"], group = grpC)

grpA = "Alerts"
alFire = input.bool(true, "Squeeze fire (A and B)", group = grpA)
alOn   = input.bool(false, "Squeeze ON", group = grpA)
alX    = input.bool(false, "EMA cross", group = grpA)

// ─────────────────────────── SQUEEZE ENGINE ──────────────────────────────
// Bollinger half-width vs Keltner half-width. Both share the same SMA basis,
// so "BB inside KC" reduces to: stdev band < m × average true range.
basis = ta.sma(close, sqzLen)
dev   = bbMult * ta.stdev(close, sqzLen)
kcRng = ta.sma(ta.tr(true), sqzLen)
ratio = kcRng > 0 ? dev / kcRng : na      // lower = tighter compression

tier    = ratio < kcHigh ? 3 : ratio < kcMid ? 2 : ratio < kcLow ? 1 : 0
minTier = minTierS == "High" ? 3 : minTierS == "Mid" ? 2 : 1
inSqz   = tier >= minTier

var int sqzBars = 0
sqzBars := inSqz ? sqzBars + 1 : 0

sqzStart = inSqz and not inSqz[1]
sqzEnd   = not inSqz and inSqz[1]
released = sqzEnd and sqzBars[1] >= minBars

tierTxt = tier == 3 ? "HIGH" : tier == 2 ? "MID" : tier == 1 ? "LOW" : "OFF"
sqzCol  = tier == 3 ? cSqzHigh : tier == 2 ? cSqzMid : tier == 1 ? cSqzLow : cSqzOff

// ───────────────────────────── MOMENTUM ──────────────────────────────────
// Distance of close from an equilibrium price (midpoint of the Donchian
// range blended with an EMA), smoothed with a linear regression, then
// optionally expressed in ATR units.
eqPrice = math.avg(math.avg(ta.highest(high, momLen), ta.lowest(low, momLen)), ta.ema(close, momLen))
rawMom  = ta.linreg(close - eqPrice, momLen, 0)
atrN    = ta.atr(atrLen)
mom     = normATR ? (atrN > 0 ? rawMom / atrN : 0.0) : rawMom
momUp   = mom > nz(mom[1])

momRef   = ta.highest(math.abs(nz(mom)), 100)
strength = momRef > 0 ? math.abs(nz(mom)) / momRef : 0.0
baseCol  = mom >= 0 ? (momUp ? cUpStrong : cUpWeak) : (momUp ? cDnWeak : cDnStrong)
histCol  = color.from_gradient(strength, 0.0, 1.0, color.new(baseCol, 55), baseCol)

// ─────────────────────────────── TREND ───────────────────────────────────
emaF    = ta.ema(close, fastLen)
emaS    = ta.ema(close, slowLen)
trendUp = emaF > emaS
bullX   = ta.crossover(emaF, emaS)
bearX   = ta.crossunder(emaF, emaS)

// ─────────────────────────── FIRE SIGNALS ────────────────────────────────
longFire  = released and mom > 0
shortFire = released and mom < 0
longA     = longFire and momUp and (not useTrendGrade or trendUp)
shortA    = shortFire and not momUp and (not useTrendGrade or not trendUp)
longB     = longFire and not longA
shortB    = shortFire and not shortA

var string lastFire    = "—"
var int    lastFireBar = na
if longFire or shortFire
    lastFire    := (longFire ? "LONG " : "SHORT ") + (longA or shortA ? "A" : "B")
    lastFireBar := bar_index

// ──────────────────────────── PANE PLOTS ─────────────────────────────────
in3D = use3D and bar_index > last_bar_index - n3D

hline(0, "Zero", color.new(color.gray, 70), hline.style_dotted)
plot(mom, "Momentum", in3D ? na : histCol, style = plot.style_columns)
plot(showWave ? mom : na, "Wave Glow", color.new(baseCol, 80), 6)
plot(showWave ? mom : na, "Wave", baseCol, 2)
plot(0, "Squeeze Dots", in3D ? na : sqzCol, 3, plot.style_circles)

// ─────────────────────────── 3D HISTOGRAM ────────────────────────────────
// Each bar is drawn as an extruded prism: a front face (box), a cap face and
// a side face (two linefills). Bars extrude away from zero, so bullish bars
// cap on top and bearish bars cap on the bottom. Time coordinates allow
// sub-bar positioning.
f_shade(color c, float k) =>
    color.rgb(math.min(255, color.r(c) * k), math.min(255, color.g(c) * k), math.min(255, color.b(c) * k), color.t(c))

barMs = timeframe.in_seconds() * 1000

if in3D and not na(mom)
    float dyAbs = momRef * depthY
    float d     = (mom >= 0 ? 1.0 : -1.0) * dyAbs
    int   span  = math.round(barMs * (barWidth + depthX))
    int   xL    = time - math.round(span / 2)
    int   xR    = xL + math.round(barMs * barWidth)
    int   dx    = math.round(barMs * depthX)
    color noLn  = color.new(color.white, 100)

    // front face
    box.new(xL, math.max(mom, 0.0), xR, math.min(mom, 0.0), xloc = xloc.bar_time, border_color = f_shade(baseCol, 1.5), border_width = 1, bgcolor = histCol)

    // cap face (at the tip of the bar)
    l1 = line.new(xL, mom, xR, mom, xloc = xloc.bar_time, color = noLn)
    l2 = line.new(xL + dx, mom + d, xR + dx, mom + d, xloc = xloc.bar_time, color = noLn)
    linefill.new(l1, l2, f_shade(histCol, 1.35))

    // side face
    l3 = line.new(xR, 0.0, xR, mom, xloc = xloc.bar_time, color = noLn)
    l4 = line.new(xR + dx, d, xR + dx, mom + d, xloc = xloc.bar_time, color = noLn)
    linefill.new(l3, l4, f_shade(histCol, 0.55))

    // squeeze dot on the zero plane (drawn as a label so it sits above the prisms)
    label.new(time, 0.0, "", xloc = xloc.bar_time, style = label.style_circle, color = sqzCol, size = size.tiny)

// ───────────────────────── PRICE CHART OVERLAY ───────────────────────────
plot(showEMAs ? emaF : na, "Fast EMA", cFast, 1, force_overlay = true)
plot(showEMAs ? emaS : na, "Slow EMA", cSlow, 1, force_overlay = true)
plotshape(showEMAs and showX and bullX ? emaF : na, title = "Bull EMA Cross", style = shape.cross, location = location.absolute, color = cSlow, size = size.tiny, force_overlay = true)
plotshape(showEMAs and showX and bearX ? emaF : na, title = "Bear EMA Cross", style = shape.cross, location = location.absolute, color = #FF1744, size = size.tiny, force_overlay = true)

plotshape(showFire and longA, title = "Fire Long A", style = shape.labelup, location = location.belowbar, color = cUpStrong, text = "SQZ A", textcolor = color.black, size = size.small, force_overlay = true)
plotshape(showFire and longB, title = "Fire Long B", style = shape.triangleup, location = location.belowbar, color = color.new(cUpStrong, 40), text = "B", textcolor = cUpStrong, size = size.tiny, force_overlay = true)
plotshape(showFire and shortA, title = "Fire Short A", style = shape.labeldown, location = location.abovebar, color = cDnStrong, text = "SQZ A", textcolor = color.white, size = size.small, force_overlay = true)
plotshape(showFire and shortB, title = "Fire Short B", style = shape.triangledown, location = location.abovebar, color = color.new(cDnStrong, 40), text = "B", textcolor = cDnStrong, size = size.tiny, force_overlay = true)

bgcolor(showSqzBg and inSqz ? color.new(sqzCol, 90) : na, title = "Squeeze Shade", force_overlay = true)
barcolor(colorBars ? histCol : na, title = "Momentum Candles")

// ───────────────────────── COMPRESSION BOXES ─────────────────────────────
var box   cBox = na
var float cHi  = na
var float cLo  = na

if showBoxes
    if sqzStart
        cHi  := high
        cLo  := low
        cBox := box.new(bar_index, high, bar_index, low, border_color = color.new(sqzCol, 25), border_width = 1, border_style = line.style_dashed, bgcolor = color.new(sqzCol, 90), text = "1 bar", text_size = size.tiny, text_color = color.new(sqzCol, 10), text_halign = text.align_right, text_valign = text.align_top, force_overlay = true)
    else if inSqz and not na(cBox)
        cHi := math.max(cHi, high)
        cLo := math.min(cLo, low)
        box.set_top(cBox, cHi)
        box.set_bottom(cBox, cLo)
        box.set_right(cBox, bar_index)
        box.set_border_color(cBox, color.new(sqzCol, 25))
        box.set_bgcolor(cBox, color.new(sqzCol, 90))
        box.set_text_color(cBox, color.new(sqzCol, 10))
        box.set_text(cBox, str.tostring(sqzBars) + " bars")
    if sqzEnd and not na(cBox)
        if sqzBars[1] < minBars
            box.delete(cBox)
        cBox := na

// ───────────────────────────── DASHBOARD ─────────────────────────────────
tblPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
var table dash = table.new(tblPos, 2, 7, bgcolor = color.new(#0B0F19, 10), frame_color = color.new(#2A3142, 0), frame_width = 1, border_color = color.new(#2A3142, 0), border_width = 1)

f_row(int r, string k, string v, color vc) =>
    table.cell(dash, 0, r, k, text_color = color.new(color.white, 35), text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, v, text_color = vc, text_size = size.small, text_halign = text.align_right)

if barstate.islast and dashPos != "Hidden"
    string momTxt  = str.tostring(mom, "0.00") + (normATR ? " ATR " : " ") + (momUp ? "▲" : "▼")
    string fireTxt = lastFire + (na(lastFireBar) ? "" : " · " + str.tostring(bar_index - lastFireBar) + " bars ago")
    f_row(0, "SQZ3D", "[NeBlok]", cUpStrong)
    f_row(1, "Squeeze", tierTxt, sqzCol)
    f_row(2, "Bars in squeeze", str.tostring(sqzBars), color.white)
    f_row(3, "BB / KC ratio", str.tostring(ratio, "0.00"), color.white)
    f_row(4, "Momentum", momTxt, baseCol)
    f_row(5, "EMA trend", trendUp ? "BULL" : "BEAR", trendUp ? cSlow : #FF1744)
    f_row(6, "Last fire", fireTxt, str.startswith(lastFire, "LONG") ? cUpStrong : str.startswith(lastFire, "SHORT") ? cDnStrong : color.gray)

// ─────────────────────────────── ALERTS ──────────────────────────────────
tick = syminfo.ticker
px   = str.tostring(close, format.mintick)

if alFire and longFire
    alert("SQZ3D [NeBlok] | " + tick + " | LONG fire (" + (longA ? "A" : "B") + ") after " + str.tostring(sqzBars[1]) + " bars | close " + px, alert.freq_once_per_bar_close)
if alFire and shortFire
    alert("SQZ3D [NeBlok] | " + tick + " | SHORT fire (" + (shortA ? "A" : "B") + ") after " + str.tostring(sqzBars[1]) + " bars | close " + px, alert.freq_once_per_bar_close)
if alOn and sqzStart
    alert("SQZ3D [NeBlok] | " + tick + " | Squeeze ON (" + tierTxt + ") | close " + px, alert.freq_once_per_bar_close)
if alX and bullX
    alert("SQZ3D [NeBlok] | " + tick + " | Bullish EMA cross | close " + px, alert.freq_once_per_bar_close)
if alX and bearX
    alert("SQZ3D [NeBlok] | " + tick + " | Bearish EMA cross | close " + px, alert.freq_once_per_bar_close)
````
