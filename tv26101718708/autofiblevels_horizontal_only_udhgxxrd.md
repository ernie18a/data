# AutoFibLevels - Horizontal Only

- url: https://www.tradingview.com/script/UdHgXXrD-AutoFibLevels-Horizontal-Only/
- type: indicator
- pine_id: PUB;c96409dfff394719a430c576d67e743f
- version: 1.0

## Description

AutoFib Levels – Horizontal Only

Automatic Fibonacci retracement and extension levels calculated dynamically from the highest high and lowest low over a lookback period that adapts to your current timeframe.
Unlike most AutoFib indicators, this version displays only clean horizontal price lines with colored fill zones between levels — no diagonal or stepping lines cluttering the chart as price moves.

Levels plotted:

Extensions: 1.618, 1.272, 1.0
Retracements: 0.786, 0.618, 0.5, 0.382, 0.236, 0.0
Downside extensions: -0.238 through -1.618

Features:

Color-coded zones between each level for instant visual reference
Fully customizable lookback lengths for every timeframe (1m through Monthly)
Configurable high/low source inputs
Clean price axis labels with no duplicates

You will need to click "Lock vertical cursor line by time" in the chart settings. Right-click on your chart to find and select this setting

## Source Code

````pine
//@version=5
indicator("AutoFibLevels - Horizontal Only", shorttitle="Claude Fib", overlay=true, max_labels_count=100)

// --- TIMEFRAME LENGTHS ---
m1_  = input.int(1440, "1 Min",    minval=1, group="Timeframe Lengths")
m3_  = input.int(480,  "3 Min",    minval=1, group="Timeframe Lengths")
m5_  = input.int(288,  "5 Min",    minval=1, group="Timeframe Lengths")
m15_ = input.int(480,  "15 Min",   minval=1, group="Timeframe Lengths")
m30_ = input.int(672,  "30 Min",   minval=1, group="Timeframe Lengths")
h1_  = input.int(336,  "1 Hour",   minval=1, group="Timeframe Lengths")
h2_  = input.int(168,  "2 Hours",  minval=1, group="Timeframe Lengths")
h3_  = input.int(112,  "3 Hours",  minval=1, group="Timeframe Lengths")
h4_  = input.int(84,   "4 Hours",  minval=1, group="Timeframe Lengths")
h6_  = input.int(56,   "6 Hours",  minval=1, group="Timeframe Lengths")
h12_ = input.int(156,  "12 Hours", minval=1, group="Timeframe Lengths")
d_   = input.int(60,   "Daily",    minval=1, group="Timeframe Lengths")
w_   = input.int(52,   "Weekly",   minval=1, group="Timeframe Lengths")
mo_  = input.int(24,   "Monthly",  minval=1, group="Timeframe Lengths")
dc_  = input.int(576,  "Custom",   minval=1, group="Timeframe Lengths")

// --- SOURCE ---
src_hi = input.source(high, "High Source", group="Source")
src_lo = input.source(low,  "Low Source",  group="Source")

// --- DISPLAY ---
reverseDir    = input.bool(false, "Reverse (flip extension sides)",                group="Display")
showExtUp     = input.bool(true,  "Show Upper Extensions (1.272 / 1.414 / 1.618)", group="Display")
showExtDn     = input.bool(true,  "Show Lower Extensions (-0.238 to -1.0)",        group="Display")
highlightZone = input.bool(true,  "Highlight Active Zone",                         group="Display")

// --- LABELS ---
showLabels   = input.bool(true,    "Show Labels",      group="Labels")
showLevelTxt = input.bool(true,    "Show Level Ratio", group="Labels")
showPriceTxt = input.bool(true,    "Show Price",       group="Labels")
labelSzStr   = input.string("small", "Label Size", options=["tiny","small","normal","large"], group="Labels")

// --- TIMEFRAME RESOLUTION ---
len = switch timeframe.period
    "1"   => m1_
    "3"   => m3_
    "5"   => m5_
    "15"  => m15_
    "30"  => m30_
    "60"  => h1_
    "120" => h2_
    "180" => h3_
    "240" => h4_
    "360" => h6_
    "720" => h12_
    "D"   => d_
    "W"   => w_
    "M"   => mo_
    =>       dc_

// --- CALCULATIONS ---
raw_hi = ta.highest(src_hi, len)
raw_lo = ta.lowest(src_lo,  len)
r      = raw_hi - raw_lo

ref(p) => reverseDir ? raw_hi + raw_lo - p : p

p_161   = ref(raw_hi + 0.618 * r)
p_1414  = ref(raw_hi + 0.414 * r)
p_127   = ref(raw_hi + 0.272 * r)
p_100   = ref(raw_hi)
p_786   = ref(raw_lo + 0.786 * r)
p_618   = ref(raw_lo + 0.618 * r)
p_50    = ref(raw_lo + 0.500 * r)
p_382   = ref(raw_lo + 0.382 * r)
p_238   = ref(raw_lo + 0.238 * r)
p_0     = ref(raw_lo)
p_m238  = ref(raw_lo - 0.238 * r)
p_m382  = ref(raw_lo - 0.382 * r)
p_m50   = ref(raw_lo - 0.500 * r)
p_m618  = ref(raw_lo - 0.618 * r)
p_m786  = ref(raw_lo - 0.786 * r)
p_m100  = ref(raw_lo - 1.000 * r)

// --- ZONE DETECTION ---
inZn(a, b) => close >= math.min(a, b) and close < math.max(a, b)
ha(active)  => highlightZone and active ? 45 : 82

hz_161_1414  = inZn(p_161,  p_1414)
hz_1414_127  = inZn(p_1414, p_127)
hz_127_100   = inZn(p_127,  p_100)
hz_100_786   = inZn(p_100,  p_786)
hz_786_618   = inZn(p_786,  p_618)
hz_618_50    = inZn(p_618,  p_50)
hz_50_382    = inZn(p_50,   p_382)
hz_382_238   = inZn(p_382,  p_238)
hz_238_0     = inZn(p_238,  p_0)
hz_0_m238    = inZn(p_0,    p_m238)
hz_m238_m382 = inZn(p_m238, p_m382)
hz_m382_m50  = inZn(p_m382, p_m50)
hz_m50_m618  = inZn(p_m50,  p_m618)
hz_m618_m786 = inZn(p_m618, p_m786)
hz_m786_m100 = inZn(p_m786, p_m100)

// --- COLORS ---
c_lime = color.lime
c_1414 = #FFBB00
c_127  = #80EDF2
c_gray = color.gray
c_blue = #3399FF
c_orng = color.orange
c_aqua = color.aqua
c_grn  = color.green
c_red  = color.red

// --- LABEL HELPERS ---
lsz() =>
    labelSzStr == "tiny"   ? size.tiny   :
     labelSzStr == "small"  ? size.small  :
     labelSzStr == "normal" ? size.normal : size.large

makeTxt(ratio, price) =>
    t = ""
    if showLevelTxt
        t := ratio
    if showLevelTxt and showPriceTxt
        t := t + "  "
    if showPriceTxt
        t := t + str.tostring(price, format.mintick)
    t

// --- INVISIBLE FILL-HELPER PLOTS ---
// Simple full-history plots with display=display.none.
// This is the only fill method that is truly price-integrated in TradingView.
F161_f   = plot(p_161,   display=display.none)
F1414_f  = plot(p_1414,  display=display.none)
F127_f   = plot(p_127,   display=display.none)
F100_f   = plot(p_100,   display=display.none)
F786_f   = plot(p_786,   display=display.none)
F618_f   = plot(p_618,   display=display.none)
F50_f    = plot(p_50,    display=display.none)
F382_f   = plot(p_382,   display=display.none)
F238_f   = plot(p_238,   display=display.none)
F0_f     = plot(p_0,     display=display.none)
Fm238_f  = plot(p_m238,  display=display.none)
Fm382_f  = plot(p_m382,  display=display.none)
Fm50_f   = plot(p_m50,   display=display.none)
Fm618_f  = plot(p_m618,  display=display.none)
Fm786_f  = plot(p_m786,  display=display.none)
Fm100_f  = plot(p_m100,  display=display.none)

// --- VISIBLE HORIZONTAL PLOTS (price axis labels) ---
vis(cond, val) => barstate.islast and cond ? val : na

plot(vis(showExtUp, p_161),  color=c_lime, title="1.618",  trackprice=true)
plot(vis(showExtUp, p_1414), color=c_1414, title="1.414",  trackprice=true)
plot(vis(showExtUp, p_127),  color=c_127,  title="1.272",  trackprice=true)
plot(vis(true,      p_100),  color=c_gray, title="1",      trackprice=true)
plot(vis(true,      p_786),  color=c_blue, title="0.786",  trackprice=true)
plot(vis(true,      p_618),  color=c_orng, title="0.618",  trackprice=true)
plot(vis(true,      p_50),   color=c_aqua, title="0.5",    trackprice=true)
plot(vis(true,      p_382),  color=c_grn,  title="0.382",  trackprice=true)
plot(vis(true,      p_238),  color=c_red,  title="0.236",  trackprice=true)
plot(vis(true,      p_0),    color=c_gray, title="0",      trackprice=true)
plot(vis(showExtDn, p_m238), color=c_red,  title="-0.238", trackprice=true)
plot(vis(showExtDn, p_m382), color=c_grn,  title="-0.382", trackprice=true)
plot(vis(showExtDn, p_m50),  color=c_aqua, title="-0.50",  trackprice=true)
plot(vis(showExtDn, p_m618), color=c_orng, title="-0.618", trackprice=true)
plot(vis(showExtDn, p_m786), color=c_blue, title="-0.786", trackprice=true)
plot(vis(showExtDn, p_m100), color=c_gray, title="-1",     trackprice=true)

// --- FILLS ---
fill(F1414_f, F161_f,  showExtUp ? color.new(c_lime, ha(hz_161_1414))   : na, title="1.618 zone")
fill(F127_f,  F1414_f, showExtUp ? color.new(c_1414, ha(hz_1414_127))   : na, title="1.414 zone")
fill(F100_f,  F127_f,  showExtUp ? color.new(c_127,  ha(hz_127_100))    : na, title="1.272 zone")
fill(F786_f,  F100_f,  color.new(c_gray, ha(hz_100_786)),  title="1 zone")
fill(F618_f,  F786_f,  color.new(c_blue, ha(hz_786_618)),  title="0.786 zone")
fill(F50_f,   F618_f,  color.new(c_orng, ha(hz_618_50)),   title="0.618 zone")
fill(F382_f,  F50_f,   color.new(c_aqua, ha(hz_50_382)),   title="0.5 zone")
fill(F238_f,  F382_f,  color.new(c_grn,  ha(hz_382_238)),  title="0.382 zone")
fill(F0_f,    F238_f,  color.new(c_red,  ha(hz_238_0)),    title="0.236 zone")
fill(F0_f,    Fm238_f, showExtDn ? color.new(c_red,  ha(hz_0_m238))    : na, title="-0.238 zone")
fill(Fm238_f, Fm382_f, showExtDn ? color.new(c_grn,  ha(hz_m238_m382)) : na, title="-0.382 zone")
fill(Fm382_f, Fm50_f,  showExtDn ? color.new(c_aqua, ha(hz_m382_m50))  : na, title="-0.50 zone")
fill(Fm50_f,  Fm618_f, showExtDn ? color.new(c_orng, ha(hz_m50_m618))  : na, title="-0.618 zone")
fill(Fm618_f, Fm786_f, showExtDn ? color.new(c_blue, ha(hz_m618_m786)) : na, title="-0.786 zone")
fill(Fm786_f, Fm100_f, showExtDn ? color.new(c_gray, ha(hz_m786_m100)) : na, title="-1 zone")

// --- LABELS ---
var label[] lbls = array.new_label(0)

if barstate.islast
    for lbl in lbls
        label.delete(lbl)
    array.clear(lbls)

    if showLabels and (showLevelTxt or showPriceTxt)
        sz = lsz()
        x  = bar_index + 2

        if showExtUp
            array.push(lbls, label.new(x, p_161,  makeTxt("1.618",  p_161),  xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_lime, 85), textcolor=c_lime, size=sz))
            array.push(lbls, label.new(x, p_1414, makeTxt("1.414",  p_1414), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_1414, 85), textcolor=c_1414, size=sz))
            array.push(lbls, label.new(x, p_127,  makeTxt("1.272",  p_127),  xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_127,  85), textcolor=c_127,  size=sz))

        array.push(lbls, label.new(x, p_100, makeTxt("1.0",   p_100), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_gray, 85), textcolor=c_gray, size=sz))
        array.push(lbls, label.new(x, p_786, makeTxt("0.786", p_786), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_blue, 85), textcolor=c_blue, size=sz))
        array.push(lbls, label.new(x, p_618, makeTxt("0.618", p_618), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_orng, 85), textcolor=c_orng, size=sz))
        array.push(lbls, label.new(x, p_50,  makeTxt("0.5",   p_50),  xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_aqua, 85), textcolor=c_aqua, size=sz))
        array.push(lbls, label.new(x, p_382, makeTxt("0.382", p_382), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_grn,  85), textcolor=c_grn,  size=sz))
        array.push(lbls, label.new(x, p_238, makeTxt("0.236", p_238), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_red,  85), textcolor=c_red,  size=sz))
        array.push(lbls, label.new(x, p_0,   makeTxt("0",     p_0),   xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_gray, 85), textcolor=c_gray, size=sz))

        if showExtDn
            array.push(lbls, label.new(x, p_m238, makeTxt("-0.238", p_m238), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_red,  85), textcolor=c_red,  size=sz))
            array.push(lbls, label.new(x, p_m382, makeTxt("-0.382", p_m382), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_grn,  85), textcolor=c_grn,  size=sz))
            array.push(lbls, label.new(x, p_m50,  makeTxt("-0.50",  p_m50),  xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_aqua, 85), textcolor=c_aqua, size=sz))
            array.push(lbls, label.new(x, p_m618, makeTxt("-0.618", p_m618), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_orng, 85), textcolor=c_orng, size=sz))
            array.push(lbls, label.new(x, p_m786, makeTxt("-0.786", p_m786), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_blue, 85), textcolor=c_blue, size=sz))
            array.push(lbls, label.new(x, p_m100, makeTxt("-1.0",   p_m100), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c_gray, 85), textcolor=c_gray, size=sz))

// --- ALERTS ---
alertcondition(ta.cross(close, p_618),  title="Cross 0.618",  message="AutoFib: Price crossed 0.618")
alertcondition(ta.cross(close, p_50),   title="Cross 0.5",    message="AutoFib: Price crossed 0.5")
alertcondition(ta.cross(close, p_382),  title="Cross 0.382",  message="AutoFib: Price crossed 0.382")
alertcondition(ta.cross(close, p_786),  title="Cross 0.786",  message="AutoFib: Price crossed 0.786")
alertcondition(ta.cross(close, p_1414), title="Cross 1.414",  message="AutoFib: Price crossed 1.414")
alertcondition(ta.cross(close, p_127),  title="Cross 1.272",  message="AutoFib: Price crossed 1.272")
alertcondition(ta.cross(close, p_161),  title="Cross 1.618",  message="AutoFib: Price crossed 1.618")
alertcondition(ta.cross(close, p_100),  title="Cross 1.0",    message="AutoFib: Price crossed 1.0")
alertcondition(ta.cross(close, p_0),    title="Cross 0",      message="AutoFib: Price crossed 0")
alertcondition(ta.cross(close, p_m618), title="Cross -0.618", message="AutoFib: Price crossed -0.618")
alertcondition(ta.cross(close, p_m100), title="Cross -1.0",   message="AutoFib: Price crossed -1.0")
````
