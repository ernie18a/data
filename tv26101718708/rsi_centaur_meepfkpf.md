# Rsi centaur

- url: https://www.tradingview.com/script/mEEPFKpf-Rsi-centaur/
- type: indicator
- pine_id: PUB;cbd5c77f87c74a78bde554c3e05478e9
- version: 1.0

## Description

RSI centaur is a visual RSI-based oscillator designed to make momentum extremes, mean reversion zones, midline shifts, and confirmed divergences easier to read on one clean panel.

The indicator uses an adaptive RSI calculation based on Gaussian-weighted price changes. Instead of treating every past bar with the same importance, the RSI core applies a smooth weighting curve to recent gains and losses. This gives the oscillator a slightly different feel from a standard RSI while keeping the logic familiar for traders who already use momentum tools.

A signal line can be enabled to help read short-term smoothing. The panel also includes multiple dashed reference levels at 90, 85, 80, 75, 70, 50, 30, 25, 20, 15, and 10. These levels are not meant to be automatic buy or sell zones by themselves. They are visual areas where momentum may be extended, exhausted, or returning toward balance.

Main features:
- Adaptive Gaussian-weighted RSI oscillator
- Optional RSI-based signal line
- Configurable overbought and oversold guide levels
- Entry circles when RSI enters extreme zones
- Exit circles when RSI leaves extreme zones
- Midline dots when RSI crosses the 50 level
- Confirmed bullish and bearish RSI divergences
- Classic, hidden, and exaggerated divergence modes
- Alerts for entries, exits, midline crosses, divergences, and any signal

How to read it:
When RSI moves above 70, momentum is usually strong on the upside. If it continues into 75, 80, 85, or 90, the market is becoming more extended. A circle appearing when RSI comes back under one of these upper levels can be used as a warning that upside momentum is cooling.

When RSI moves below 30, downside momentum is usually strong. If it continues into 25, 20, 15, or 10, the market is becoming more extended to the downside. A circle appearing when RSI comes back above one of these lower levels can be used as a warning that bearish pressure is weakening.

The 50 line is used as a simple momentum balance level. Crosses above 50 suggest that the oscillator is moving back into bullish momentum territory. Crosses below 50 suggest that the oscillator is moving back into bearish momentum territory.

Beginner example 1:
Price has been falling and the RSI drops below 20. This does not automatically mean the market should be bought. A more conservative read is to wait until RSI crosses back above 20 or 25, then check whether price is also reacting from a support zone, previous low, or other market structure level.

Beginner example 2:
Price makes a new high, but the RSI makes a lower high. If a bearish divergence is confirmed, it can warn that the upward move is losing momentum. This is not a sell signal by itself, but it can help traders become more cautious with long positions or look for confirmation from price action.

Beginner example 3:
RSI crosses above 50 after spending time below it. This can show that momentum is shifting back toward the upside. If price is also above a key moving average or breaking a local structure level, the midline cross may support a bullish scenario.

About divergences:
Divergences are based on confirmed RSI pivots. Because pivots require confirmation, divergence labels appear only after the confirmation bars have closed. This makes them cleaner, but it also means they are not intended to mark the exact top or bottom in real time.

Suggested use:
Centaur RSI is best used as a momentum and context tool. It can help identify overextended conditions, momentum recovery, and possible divergence areas. It should be combined with price structure, trend direction, volume, or support and resistance analysis before making trading decisions.

Limitations:
No RSI tool can predict future price movement. Strong trends can keep RSI overbought or oversold for a long time. Divergences can also fail during high momentum markets. The indicator is designed to provide visual context, not guaranteed entries or exits.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("RSI CENTAUR", overlay=false, max_lines_count=500, max_polylines_count=100, max_labels_count=500, precision=1)

a1 = input.int(14, minval=1, title="RSI Length", group="Adaptive RSI (Gaussian Weighted)")
a2 = input.float(3.0, minval=0.01, title="Gaussian Sigma", group="Adaptive RSI (Gaussian Weighted)")
a3 = input.bool(true, title="Signal Line", group="Signal Line")
a4 = input.int(9, minval=1, title="Signal Length", group="Signal Line")

b1 = input.bool(true, title="Enable RSI Divergences (Confirmed)", group="Divergences (RSI Classic)")
b2 = input.int(5, minval=1, maxval=50, title="Pivot Left", group="Divergences (RSI Classic)")
b3 = input.int(5, minval=1, maxval=50, title="Pivot Right", group="Divergences (RSI Classic)")
b4 = input.bool(true, title="Classic Divergences", group="Divergences (RSI Classic)")
b5 = input.bool(true, title="Hidden Divergences", group="Divergences (RSI Classic)")
b6 = input.bool(true, title="Exaggerated Divergences", group="Divergences (RSI Classic)")
b7 = input.color(color.lime, "Bull Color", group="Divergences (RSI Classic)")
b8 = input.color(color.red, "Bear Color", group="Divergences (RSI Classic)")
b9 = input.int(300, minval=50, maxval=2000, title="Max Divergence Lines (Global)", group="Divergences (RSI Classic)")
b10 = input.int(300, minval=50, maxval=2000, title="Max Divergence Labels (Global)", group="Divergences (RSI Classic)")
b11 = input.int(6, minval=1, maxval=50, title="Exaggerated: Max Pivot Gap (bars)", group="Divergences (RSI Classic)")
b12 = input.int(14, minval=1, title="Exaggerated: ATR Length", group="Divergences (RSI Classic)")
b13 = input.float(0.05, minval=0.0, step=0.01, title="Exaggerated: Price Tolerance (ATR %)", group="Divergences (RSI Classic)")

c1 = input.bool(true, title="Exit Signals", group="Cross Signals")
c2 = input.bool(true, title="Entry Circles (Zone Entries)", group="Cross Signals")

c3 = input.color(color.rgb(255, 0, 0), title="Color 90/10", group="Cross Signals")
c4 = input.color(color.rgb(255, 115, 0), title="Color 85/15", group="Cross Signals")
c5 = input.color(color.rgb(255, 196, 0), title="Color 80/20", group="Cross Signals")
c6 = input.color(color.rgb(251, 254, 44), title="Color 75/25", group="Cross Signals")
c7 = input.color(color.rgb(254, 255, 167), title="Color 70/30", group="Cross Signals")

c8 = input.int(80, minval=0, maxval=100, title="Glow Transparency", group="Cross Signals")
c9 = input.int(0, minval=0, maxval=100, title="Dot Transparency", group="Cross Signals")

c10 = input.bool(true, title="Midline Dots (50)", group="Cross Signals")
c11 = input.color(color.yellow, title="Midline Dot Color", group="Cross Signals")

d1 = input.bool(true, title="Show ALL Dashed Levels", group="Dashed Levels")
d2 = input.bool(true, title="Show 90", group="Dashed Levels")
d3 = input.bool(true, title="Show 85", group="Dashed Levels")
d4 = input.bool(true, title="Show 80", group="Dashed Levels")
d5 = input.bool(true, title="Show 75", group="Dashed Levels")
d6 = input.bool(true, title="Show 70 (Upper Band)", group="Dashed Levels")
d7 = input.bool(true, title="Show 50 (Midline)", group="Dashed Levels")
d8 = input.bool(true, title="Show 30 (Lower Band)", group="Dashed Levels")
d9 = input.bool(true, title="Show 25", group="Dashed Levels")
d10 = input.bool(true, title="Show 20", group="Dashed Levels")
d11 = input.bool(true, title="Show 15", group="Dashed Levels")
d12 = input.bool(true, title="Show 10", group="Dashed Levels")

d13 = d1 and d2
d14 = d1 and d3
d15 = d1 and d4
d16 = d1 and d5
d17 = d1 and d6
d18 = d1 and d7
d19 = d1 and d8
d20 = d1 and d9
d21 = d1 and d10
d22 = d1 and d11
d23 = d1 and d12

e1 = color.new(color.red, d17 ? 0 : 100)
e2 = color.new(color.green, d19 ? 0 : 100)
e3 = color.new(color.red, d13 ? 0 : 100)
e4 = color.new(color.red, d14 ? 0 : 100)
e5 = color.new(color.red, d15 ? 0 : 100)
e6 = color.new(color.red, d16 ? 0 : 100)
e7 = color.new(color.green, d20 ? 0 : 100)
e8 = color.new(color.green, d21 ? 0 : 100)
e9 = color.new(color.green, d22 ? 0 : 100)
e10 = color.new(color.green, d23 ? 0 : 100)
e11 = color.new(color.yellow, d18 ? 0 : 100)

var float[] f1 = array.new_float()
var float f2 = na
var int f3 = na
var float f4 = na

bool f5 = barstate.isfirst or f3 != a1 or f4 != a2
if f5
    array.clear(f1)
    float f6 = 0.0
    for i = 1 to a1
        float f7 = math.exp(-math.pow(i - (a1 / 2), 2) / (2 * math.pow(a2, 2)))
        array.push(f1, f7)
        f6 += f7
    f2 := f6
    f3 := a1
    f4 := a2

float f11 = 0.0
float f12 = 0.0
for i = 1 to a1
    float f7 = array.get(f1, i - 1)
    float f8 = close[i - 1] - close[i]
    float f9 = f8 > 0 ? f8 : 0.0
    float f10 = f8 < 0 ? -f8 : 0.0
    f11 += f9 * f7
    f12 += f10 * f7

float f13 = f11 / f2
float f14 = f12 / f2
float f15 = f14 == 0 ? 0 : f13 / f14
float f16 = f14 == 0 ? 100 : 100 - (100 / (1 + f15))
float f17 = ta.sma(f16, a4)

float f18 = ta.rsi(close, a1)

f19 = plot(f16, "Adaptive RSI", color=color.rgb(0, 117, 90))
plot(f17, "RSI-based MA", color=color.rgb(0, 255, 234), display=a3 ? display.all : display.none, editable=a3)

g1 = hline(70, "Overbought", color=e1, linestyle=hline.style_dashed, linewidth=1)
g2 = hline(30, "Oversold", color=e2, linestyle=hline.style_dashed, linewidth=1)

hline(90, "Extreme Overbought 90", color=e3, linestyle=hline.style_dashed, linewidth=1)
hline(85, "Extreme Overbought 85", color=e4, linestyle=hline.style_dashed, linewidth=1)
hline(80, "Extreme Overbought 80", color=e5, linestyle=hline.style_dashed, linewidth=1)
hline(75, "Extreme Overbought 75", color=e6, linestyle=hline.style_dashed, linewidth=1)

hline(25, "Extreme Oversold 25", color=e7, linestyle=hline.style_dashed, linewidth=1)
hline(20, "Extreme Oversold 20", color=e8, linestyle=hline.style_dashed, linewidth=1)
hline(15, "Extreme Oversold 15", color=e9, linestyle=hline.style_dashed, linewidth=1)
hline(10, "Extreme Oversold 10", color=e10, linestyle=hline.style_dashed, linewidth=1)

hline(50, "Midline", color=e11, linestyle=hline.style_dashed, linewidth=1)
g3 = plot(50, color=chart.fg_color, display=display.none)

fill(g1, g2, color=color.rgb(126, 87, 194, 90), title="RSI Background Fill")
fill(f19, g3, 100, 60, top_color=color.new(color.green, 0), bottom_color=color.new(color.green, 100), title="Overbought Gradient Fill")
fill(f19, g3, 40, 0, top_color=color.new(color.red, 100), bottom_color=color.new(color.red, 0), title="Oversold Gradient Fill")

g4 = plot(f16, color=color.rgb(0, 117, 90), display=display.none, editable=false)
g5 = plot(f16[4], display=display.none, editable=false)
fill(g4, g5, f16, f16[4], color.rgb(0, 117, 90), na)

bool h1 = ta.crossunder(f16, 90)
bool h2 = ta.crossunder(f16, 85)
bool h3 = ta.crossunder(f16, 80)
bool h4 = ta.crossunder(f16, 75)
bool h5 = ta.crossunder(f16, 70)
bool h6 = ta.crossover(f16, 30)
bool h7 = ta.crossover(f16, 25)
bool h8 = ta.crossover(f16, 20)
bool h9 = ta.crossover(f16, 15)
bool h10 = ta.crossover(f16, 10)

bool i1 = ta.crossover(f16, 90)
bool i2 = ta.crossover(f16, 85)
bool i3 = ta.crossover(f16, 80)
bool i4 = ta.crossover(f16, 75)
bool i5 = ta.crossover(f16, 70)
bool i6 = ta.crossunder(f16, 30)
bool i7 = ta.crossunder(f16, 25)
bool i8 = ta.crossunder(f16, 20)
bool i9 = ta.crossunder(f16, 15)
bool i10 = ta.crossunder(f16, 10)

float j1 = na
color j2 = na
if h1
    j1 := 90, j2 := c3
else if h2
    j1 := 85, j2 := c4
else if h3
    j1 := 80, j2 := c5
else if h4
    j1 := 75, j2 := c6
else if h5
    j1 := 70, j2 := c7
else if h6
    j1 := 30, j2 := c7
else if h7
    j1 := 25, j2 := c6
else if h8
    j1 := 20, j2 := c5
else if h9
    j1 := 15, j2 := c4
else if h10
    j1 := 10, j2 := c3

float j3 = na
color j4 = na
if i1
    j3 := 90, j4 := c3
else if i2
    j3 := 85, j4 := c4
else if i3
    j3 := 80, j4 := c5
else if i4
    j3 := 75, j4 := c6
else if i5
    j3 := 70, j4 := c7
else if i6
    j3 := 30, j4 := c7
else if i7
    j3 := 25, j4 := c6
else if i8
    j3 := 20, j4 := c5
else if i9
    j3 := 15, j4 := c4
else if i10
    j3 := 10, j4 := c3

plotshape(c1 and not na(j1) ? j1 : na, title="Exit Dot (All Levels)", location=location.absolute, style=shape.circle, color=(c1 and not na(j1) ? color.new(j2, c9) : na), size=size.tiny)
plotshape(c1 and not na(j1) ? j1 : na, title="Exit Glow (All Levels)", location=location.absolute, style=shape.circle, color=(c1 and not na(j1) ? color.new(j2, c8) : na), size=size.small)

plotshape(c2 and not na(j3) ? j3 : na, title="Entry Dot (All Levels)", location=location.absolute, style=shape.circle, color=(c2 and not na(j3) ? color.new(j4, c9) : na), size=size.tiny)
plotshape(c2 and not na(j3) ? j3 : na, title="Entry Glow (All Levels)", location=location.absolute, style=shape.circle, color=(c2 and not na(j3) ? color.new(j4, c8) : na), size=size.small)

bool k1 = ta.crossover(f16, 50)
bool k2 = ta.crossunder(f16, 50)
plotshape(c10 and d18 and (k1 or k2) ? 50 : na, title="Midline Dot", location=location.absolute, style=shape.circle, color=color.new(c11, c9), size=size.tiny)
plotshape(c10 and d18 and (k1 or k2) ? 50 : na, title="Midline Glow", location=location.absolute, style=shape.circle, color=color.new(c11, c8), size=size.small)

var line[] l1 = array.new_line()
l2(_ln) =>
    array.push(l1, _ln)
    while array.size(l1) > b9
        line l6 = array.shift(l1)
        if not na(l6)
            line.delete(l6)
    0

var label[] l3 = array.new_label()
l4(_lb) =>
    array.push(l3, _lb)
    while array.size(l3) > b10
        label l6 = array.shift(l3)
        if not na(l6)
            label.delete(l6)
    0

l5(m1, m2, m3, m4, m5, m6) =>
    line m7 = line.new(x1=m1, y1=m2, x2=m3, y2=m4, xloc=xloc.bar_index, extend=extend.none, color=m6, width=1)
    l2(m7)
    label m8 = label.new(x=m3, y=m4, text=(m5 ? "Bull" : "Bear"), style=(m5 ? label.style_label_up : label.style_label_down), color=color.new(m6, 0), textcolor=color.new(color.white, 0), size=size.tiny)
    l4(m8)
    0

float n1 = ta.pivotlow(f18, b2, b3)
float n2 = ta.pivothigh(f18, b2, b3)
bool n3 = not na(n1)
bool n4 = not na(n2)

int n5 = bar_index - b3
int n6 = bar_index - b3
int n7 = ta.valuewhen(n3, n5, 1)
int n8 = ta.valuewhen(n4, n6, 1)

float n9 = ta.valuewhen(n3, n1, 1)
float n10 = ta.valuewhen(n4, n2, 1)

float n11 = low[b3]
float n12 = high[b3]
float n13 = ta.valuewhen(n3, low[b3], 1)
float n14 = ta.valuewhen(n4, high[b3], 1)

bool n15 = n3 and not na(n9) and not na(n7)
bool n16 = n4 and not na(n10) and not na(n8)

float n17 = ta.atr(b12) * b13
bool n18 = n15 and (n5 - n7) <= b11
bool n19 = n16 and (n6 - n8) <= b11
bool n20 = n15 and math.abs(n11 - n13) <= n17
bool n21 = n16 and math.abs(n12 - n14) <= n17

bool o1 = b1 and b4 and n15 and n11 < n13 and n1 > n9
bool o2 = b1 and b4 and n16 and n12 > n14 and n2 < n10
bool o3 = b1 and b5 and n15 and n11 > n13 and n1 < n9
bool o4 = b1 and b5 and n16 and n12 < n14 and n2 > n10
bool o5 = b1 and b6 and n18 and n20 and n1 > n9
bool o6 = b1 and b6 and n19 and n21 and n2 < n10

if o1
    l5(n7, n9, n5, n1, true, b7)
if o2
    l5(n8, n10, n6, n2, false, b8)
if o3
    l5(n7, n9, n5, n1, true, b7)
if o4
    l5(n8, n10, n6, n2, false, b8)
if o5
    l5(n7, n9, n5, n1, true, b7)
if o6
    l5(n8, n10, n6, n2, false, b8)

alertcondition(c1 and h1, title="Exit 90", message="CENTAUR RSI: Exit 90 (crossunder 90)")
alertcondition(c1 and h2, title="Exit 85", message="CENTAUR RSI: Exit 85 (crossunder 85)")
alertcondition(c1 and h3, title="Exit 80", message="CENTAUR RSI: Exit 80 (crossunder 80)")
alertcondition(c1 and h4, title="Exit 75", message="CENTAUR RSI: Exit 75 (crossunder 75)")
alertcondition(c1 and h5, title="Exit 70", message="CENTAUR RSI: Exit 70 (crossunder 70)")
alertcondition(c1 and h6, title="Exit 30", message="CENTAUR RSI: Exit 30 (crossover 30)")
alertcondition(c1 and h7, title="Exit 25", message="CENTAUR RSI: Exit 25 (crossover 25)")
alertcondition(c1 and h8, title="Exit 20", message="CENTAUR RSI: Exit 20 (crossover 20)")
alertcondition(c1 and h9, title="Exit 15", message="CENTAUR RSI: Exit 15 (crossover 15)")
alertcondition(c1 and h10, title="Exit 10", message="CENTAUR RSI: Exit 10 (crossover 10)")

alertcondition(c2 and i1, title="Entry 90", message="CENTAUR RSI: Entry 90 (crossover 90)")
alertcondition(c2 and i2, title="Entry 85", message="CENTAUR RSI: Entry 85 (crossover 85)")
alertcondition(c2 and i3, title="Entry 80", message="CENTAUR RSI: Entry 80 (crossover 80)")
alertcondition(c2 and i4, title="Entry 75", message="CENTAUR RSI: Entry 75 (crossover 75)")
alertcondition(c2 and i5, title="Entry 70", message="CENTAUR RSI: Entry 70 (crossover 70)")
alertcondition(c2 and i6, title="Entry 30", message="CENTAUR RSI: Entry 30 (crossunder 30)")
alertcondition(c2 and i7, title="Entry 25", message="CENTAUR RSI: Entry 25 (crossunder 25)")
alertcondition(c2 and i8, title="Entry 20", message="CENTAUR RSI: Entry 20 (crossunder 20)")
alertcondition(c2 and i9, title="Entry 15", message="CENTAUR RSI: Entry 15 (crossunder 15)")
alertcondition(c2 and i10, title="Entry 10", message="CENTAUR RSI: Entry 10 (crossunder 10)")

alertcondition(c10 and d18 and k1, title="Midline Cross Up (50)", message="CENTAUR RSI: RSI crossed ABOVE 50")
alertcondition(c10 and d18 and k2, title="Midline Cross Down (50)", message="CENTAUR RSI: RSI crossed BELOW 50")

alertcondition(b1 and o1, title="Bullish Classic Divergence", message="CENTAUR RSI: Bullish CLASSIC divergence confirmed")
alertcondition(b1 and o2, title="Bearish Classic Divergence", message="CENTAUR RSI: Bearish CLASSIC divergence confirmed")
alertcondition(b1 and o3, title="Bullish Hidden Divergence", message="CENTAUR RSI: Bullish HIDDEN divergence confirmed")
alertcondition(b1 and o4, title="Bearish Hidden Divergence", message="CENTAUR RSI: Bearish HIDDEN divergence confirmed")
alertcondition(b1 and o5, title="Bullish Exaggerated Divergence", message="CENTAUR RSI: Bullish EXAGGERATED divergence confirmed")
alertcondition(b1 and o6, title="Bearish Exaggerated Divergence", message="CENTAUR RSI: Bearish EXAGGERATED divergence confirmed")

bool q1 = i1 or i2 or i3 or i4 or i5 or i6 or i7 or i8 or i9 or i10
bool q2 = h1 or h2 or h3 or h4 or h5 or h6 or h7 or h8 or h9 or h10
bool q3 = o1 or o2 or o3 or o4 or o5 or o6
alertcondition((c2 and q1) or (c1 and q2) or (c10 and d18 and (k1 or k2)) or (b1 and q3), title="CENTAUR RSI: Any Signal", message="CENTAUR RSI: New signal (Entry/Exit/Midline/Divergence)")
````
