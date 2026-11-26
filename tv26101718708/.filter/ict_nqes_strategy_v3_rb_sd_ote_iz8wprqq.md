# ICT NQ/ES Strategy v3 - RB / SD / OTE

- url: https://www.tradingview.com/script/iz8wPrQQ-ICT-NQ-ES-Strategy-v3-RB-SD-OTE/
- type: indicator
- pine_id: PUB;d8a4b9c2492045ec8ae58e6961e743e0
- version: 1.0

## Description

ict concepts 
9:30 opening range 
NWOG 
PDH,pdl 
standard deviation 
ote

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © m8-fx

//@version=6
indicator("ICT NQ/ES Strategy v3 - RB / SD / OTE", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

// Opening Range
showOR        = input.bool(true,  "Show 9:30 Opening Range",       group="📍 Opening Range")
orColor       = input.color(color.new(color.yellow, 80),           "OR Box Color",              group="📍 Opening Range")
orBorderColor = input.color(color.yellow,                          "OR Border Color",            group="📍 Opening Range")

// Previous Day H/L
showPDHL      = input.bool(true,  "Show Prev Day High/Low",        group="📅 Previous Day H/L")
pdHighColor   = input.color(color.new(color.red, 0),               "PDH Color",                 group="📅 Previous Day H/L")
pdLowColor    = input.color(color.new(color.lime, 0),              "PDL Color",                 group="📅 Previous Day H/L")

// Weekly Gap
showWeekGap   = input.bool(true,  "Show Weekly Opening Gap",       group="📆 Weekly Gap")
weekGapColor  = input.color(color.new(color.purple, 70),           "Weekly Gap Color",          group="📆 Weekly Gap")

// Order Blocks
showOB        = input.bool(true,  "Show Order Blocks",             group="🟩 Order Blocks")
displacement  = input.float(1.5,  "Displacement ATR Mult",         group="🟩 Order Blocks", minval=1.0, maxval=5.0)
bullOBColor   = input.color(color.new(color.green, 80),            "Bullish OB",                group="🟩 Order Blocks")
bearOBColor   = input.color(color.new(color.red, 80),              "Bearish OB",                group="🟩 Order Blocks")

// Rejection Blocks
showRB        = input.bool(true,  "Show Rejection Blocks",         group="🔴 Rejection Blocks")
rbLookback    = input.int(3,      "Wick Lookback",                 group="🔴 Rejection Blocks", minval=1, maxval=10)
rbWickMult    = input.float(0.6,  "Min Wick/Range Ratio",          group="🔴 Rejection Blocks", minval=0.3, maxval=0.9, step=0.05)
bullRBColor   = input.color(color.new(color.green, 70),            "Bullish RB",                group="🔴 Rejection Blocks")
bearRBColor   = input.color(color.new(color.red, 70),              "Bearish RB",                group="🔴 Rejection Blocks")

// FVG
showFVG       = input.bool(true,  "Show Fair Value Gaps",          group="⬜ FVG")
bullFVGColor  = input.color(color.new(color.teal, 75),             "Bullish FVG",               group="⬜ FVG")
bearFVGColor  = input.color(color.new(color.orange, 75),           "Bearish FVG",               group="⬜ FVG")

// Fibonacci / OTE
showFib       = input.bool(true,  "Show OR Fib 0.5",               group="📐 Fibonacci / OTE")
showOTE       = input.bool(true,  "Show OTE Zone (62–79%)",        group="📐 Fibonacci / OTE")
fibColor      = input.color(color.new(color.white, 30),            "Fib 0.5 Color",             group="📐 Fibonacci / OTE")
oteColor      = input.color(color.new(color.fuchsia, 75),          "OTE Zone Color",            group="📐 Fibonacci / OTE")
oteLookback   = input.int(50,     "OTE Swing Lookback",            group="📐 Fibonacci / OTE",  minval=10, maxval=200)

// Standard Deviation
showSD        = input.bool(true,  "Show Std Dev Levels",           group="📊 Standard Deviation")
sdLength      = input.int(20,     "Std Dev Length",                group="📊 Standard Deviation", minval=5, maxval=100)
sdMult1       = input.float(1.0,  "SD Level 1 (×)",               group="📊 Standard Deviation", minval=0.5, maxval=3.0, step=0.5)
sdMult2       = input.float(2.0,  "SD Level 2 (×)",               group="📊 Standard Deviation", minval=0.5, maxval=5.0, step=0.5)
sdMult3       = input.float(3.0,  "SD Level 3 (×)",               group="📊 Standard Deviation", minval=0.5, maxval=6.0, step=0.5)
sdColor1      = input.color(color.new(color.blue, 40),             "SD ±1 Color",               group="📊 Standard Deviation")
sdColor2      = input.color(color.new(color.blue, 60),             "SD ±2 Color",               group="📊 Standard Deviation")
sdColor3      = input.color(color.new(color.blue, 75),             "SD ±3 Color",               group="📊 Standard Deviation")

// Signals
showSignals   = input.bool(true,  "Show Entry Signals",            group="🎯 Signals")
liqLookback   = input.int(20,     "Liquidity Lookback",            group="🎯 Signals", minval=5, maxval=100)

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════
atr = ta.atr(14)

nyHour(t)  => hour(t,      "America/New_York")
nyMinute(t)=> minute(t,    "America/New_York")
nyDow(t)   => dayofweek(t, "America/New_York")

isNewDay   = ta.change(time("D")) != 0
isNewWeek  = ta.change(time("W")) != 0
isRTH      = not na(time("1", "0930-1600", "America/New_York"))
isORCandle = nyHour(time) == 9 and nyMinute(time) == 30 and timeframe.isintraday

// ═══════════════════════════════════════════════════════════════
// PREVIOUS DAY HIGH / LOW
// ═══════════════════════════════════════════════════════════════
var float pdHigh     = na
var float pdLow      = na
var float dayHigh    = na
var float dayLow     = na
var line  pdHighLine = na
var line  pdLowLine  = na
var label pdHLabel   = na
var label pdLLabel   = na

if isNewDay
    pdHigh  := dayHigh
    pdLow   := dayLow
    dayHigh := high
    dayLow  := low

    if showPDHL and not na(pdHigh)
        if not na(pdHighLine)
            line.delete(pdHighLine)
            line.delete(pdLowLine)
            label.delete(pdHLabel)
            label.delete(pdLLabel)
        pdHighLine := line.new(bar_index, pdHigh, bar_index + 500, pdHigh,
                               color=pdHighColor, width=2, style=line.style_solid)
        pdLowLine  := line.new(bar_index, pdLow,  bar_index + 500, pdLow,
                               color=pdLowColor,  width=2, style=line.style_solid)
        pdHLabel   := label.new(bar_index, pdHigh, "PDH " + str.tostring(pdHigh, "#.00"),
                                color=color.new(color.red, 80), textcolor=color.red,
                                style=label.style_label_right, size=size.small)
        pdLLabel   := label.new(bar_index, pdLow,  "PDL " + str.tostring(pdLow, "#.00"),
                                color=color.new(color.lime, 80), textcolor=color.lime,
                                style=label.style_label_right, size=size.small)
else
    dayHigh := not na(dayHigh) ? math.max(dayHigh, high) : high
    dayLow  := not na(dayLow)  ? math.min(dayLow,  low)  : low

if showPDHL and not na(pdHighLine)
    line.set_x2(pdHighLine, bar_index + 2)
    line.set_x2(pdLowLine,  bar_index + 2)

// ═══════════════════════════════════════════════════════════════
// WEEKLY OPENING GAP
// ═══════════════════════════════════════════════════════════════
var float weekOpenPrice = na
var float prevWeekClose = na
var float wkGapTop      = na
var float wkGapBot      = na
var box   weekGapBox    = na
var label weekGapLabel  = na
var line  weekOpenLine  = na

isFriday = nyDow(time) == dayofweek.friday

if isFriday
    prevWeekClose := close

if isNewWeek
    weekOpenPrice := open
    if not na(prevWeekClose) and showWeekGap
        wkGapTop := math.max(weekOpenPrice, prevWeekClose)
        wkGapBot := math.min(weekOpenPrice, prevWeekClose)
        if not na(weekGapBox)
            box.delete(weekGapBox)
        if not na(weekGapLabel)
            label.delete(weekGapLabel)
        if not na(weekOpenLine)
            line.delete(weekOpenLine)
        if (wkGapTop - wkGapBot) > atr * 0.1
            weekGapBox   := box.new(bar_index, wkGapTop, bar_index + 500, wkGapBot,
                                    border_color=color.purple, border_width=1,
                                    bgcolor=weekGapColor)
            weekGapLabel := label.new(bar_index, wkGapTop, "WEEKLY GAP",
                                      color=color.new(color.purple, 70), textcolor=color.white,
                                      style=label.style_label_down, size=size.small)
    weekOpenLine := line.new(bar_index, weekOpenPrice, bar_index + 500, weekOpenPrice,
                             color=color.new(color.purple, 20), width=2, style=line.style_dashed)

if showWeekGap
    if not na(weekGapBox)
        box.set_right(weekGapBox, bar_index + 2)
    if not na(weekOpenLine)
        line.set_x2(weekOpenLine, bar_index + 2)

// ═══════════════════════════════════════════════════════════════
// OPENING RANGE (9:30 5m candle)
// ═══════════════════════════════════════════════════════════════
var float orHigh  = na
var float orLow   = na
var int   orBar   = na
var box   orBox   = na
var line  orHLine = na
var line  orLLine = na

if isORCandle
    orHigh := high
    orLow  := low
    orBar  := bar_index
    if not na(orBox)
        box.delete(orBox)
    if not na(orHLine)
        line.delete(orHLine)
        line.delete(orLLine)
    orBox  := box.new(bar_index, orHigh, bar_index + 1, orLow,
                      border_color=orBorderColor, border_width=2, bgcolor=orColor)
    orHLine := line.new(bar_index, orHigh, bar_index + 300, orHigh,
                        color=color.yellow, width=1, style=line.style_dashed)
    orLLine := line.new(bar_index, orLow,  bar_index + 300, orLow,
                        color=color.yellow, width=1, style=line.style_dashed)

if showOR and not na(orBox)
    box.set_right(orBox, bar_index + 2)
if showOR and not na(orHLine)
    line.set_x2(orHLine, bar_index + 2)
    line.set_x2(orLLine, bar_index + 2)

// ═══════════════════════════════════════════════════════════════
// FIB 0.5 OF OPENING RANGE
// ═══════════════════════════════════════════════════════════════
orMid = not na(orHigh) and not na(orLow) ? (orHigh + orLow) / 2 : na

var line  fibLine  = na
var label fibLabel = na

if isORCandle and showFib
    if not na(fibLine)
        line.delete(fibLine)
        label.delete(fibLabel)
    fibLine  := line.new(bar_index, orMid, bar_index + 300, orMid,
                         color=fibColor, width=2, style=line.style_dotted)
    fibLabel := label.new(bar_index, orMid, "OR 0.5",
                          color=color.new(color.white, 70), textcolor=color.white,
                          style=label.style_label_right, size=size.small)

if not na(fibLine)
    line.set_x2(fibLine, bar_index + 2)

// ═══════════════════════════════════════════════════════════════
// OTE ZONE  (62% – 79% fib retracement of last major swing)
// ICT Optimal Trade Entry = price pulling back into 62–79% of a
// displacement move, targeting the 50% (equilibrium) draw
// ═══════════════════════════════════════════════════════════════
swingHigh = ta.highest(high, oteLookback)
swingLow  = ta.lowest(low,   oteLookback)
swingRng  = swingHigh - swingLow

// Bullish OTE: retracement from swing high down into 62–79% zone
// (measured from swing low up)
oteB_top  = swingLow + swingRng * 0.79   // 79% up from low
oteB_bot  = swingLow + swingRng * 0.62   // 62% up from low
ote50     = swingLow + swingRng * 0.50   // equilibrium

// Bearish OTE: price retracing up into 62–79% from swing high
oteBr_bot = swingHigh - swingRng * 0.79
oteBr_top = swingHigh - swingRng * 0.62

// Determine which OTE to show based on trend (close vs midpoint)
aboveMid  = close > ote50
// Bullish bias → show bull OTE pullback zone; bearish → bear OTE
oteTop    = aboveMid ? oteB_top  : oteBr_top
oteBot    = aboveMid ? oteB_bot  : oteBr_bot

var box   oteBox   = na
var label oteLabel = na
var line  ote50Ln  = na

if showOTE
    if not na(oteBox)
        box.delete(oteBox)
        label.delete(oteLabel)
        line.delete(ote50Ln)

    oteBox   := box.new(bar_index - oteLookback, oteTop, bar_index + 10, oteBot,
                        border_color=color.fuchsia, border_width=1,
                        bgcolor=oteColor, extend=extend.none)
    oteLabel := label.new(bar_index, oteTop, "OTE 62–79%",
                          color=color.new(color.fuchsia, 70), textcolor=color.fuchsia,
                          style=label.style_label_left, size=size.small)
    ote50Ln  := line.new(bar_index - oteLookback, ote50, bar_index + 10, ote50,
                         color=color.new(color.fuchsia, 30), width=1,
                         style=line.style_dotted)

// ═══════════════════════════════════════════════════════════════
// STANDARD DEVIATION LEVELS
// Anchored to the OR open price each session
// SD bands show expected move ranges (1σ, 2σ, 3σ)
// ═══════════════════════════════════════════════════════════════
// Calculate rolling std dev of close
sdValue   = ta.stdev(close, sdLength)

// Anchor = OR open (first RTH price)
var float sdAnchor = na
if isORCandle
    sdAnchor := open

sdUp1  = not na(sdAnchor) ? sdAnchor + sdValue * sdMult1 : na
sdDn1  = not na(sdAnchor) ? sdAnchor - sdValue * sdMult1 : na
sdUp2  = not na(sdAnchor) ? sdAnchor + sdValue * sdMult2 : na
sdDn2  = not na(sdAnchor) ? sdAnchor - sdValue * sdMult2 : na
sdUp3  = not na(sdAnchor) ? sdAnchor + sdValue * sdMult3 : na
sdDn3  = not na(sdAnchor) ? sdAnchor - sdValue * sdMult3 : na

var line sdU1l = na,  var line sdD1l = na
var line sdU2l = na,  var line sdD2l = na
var line sdU3l = na,  var line sdD3l = na
var label sdU1lb = na, var label sdD1lb = na
var label sdU2lb = na, var label sdD2lb = na
var label sdU3lb = na, var label sdD3lb = na

if showSD and isORCandle and not na(sdAnchor)
    // Delete old
    if not na(sdU1l)
        line.delete(sdU1l),  line.delete(sdD1l)
        line.delete(sdU2l),  line.delete(sdD2l)
        line.delete(sdU3l),  line.delete(sdD3l)
        label.delete(sdU1lb), label.delete(sdD1lb)
        label.delete(sdU2lb), label.delete(sdD2lb)
        label.delete(sdU3lb), label.delete(sdD3lb)

    sdU1l  := line.new(bar_index, sdUp1, bar_index + 300, sdUp1, color=sdColor1, width=1, style=line.style_solid)
    sdD1l  := line.new(bar_index, sdDn1, bar_index + 300, sdDn1, color=sdColor1, width=1, style=line.style_solid)
    sdU2l  := line.new(bar_index, sdUp2, bar_index + 300, sdUp2, color=sdColor2, width=1, style=line.style_solid)
    sdD2l  := line.new(bar_index, sdDn2, bar_index + 300, sdDn2, color=sdColor2, width=1, style=line.style_solid)
    sdU3l  := line.new(bar_index, sdUp3, bar_index + 300, sdUp3, color=sdColor3, width=1, style=line.style_solid)
    sdD3l  := line.new(bar_index, sdDn3, bar_index + 300, sdDn3, color=sdColor3, width=1, style=line.style_solid)

    sdU1lb := label.new(bar_index, sdUp1, "+1σ", color=color.new(color.blue, 80), textcolor=color.blue, style=label.style_label_right, size=size.tiny)
    sdD1lb := label.new(bar_index, sdDn1, "−1σ", color=color.new(color.blue, 80), textcolor=color.blue, style=label.style_label_right, size=size.tiny)
    sdU2lb := label.new(bar_index, sdUp2, "+2σ", color=color.new(color.blue, 80), textcolor=color.blue, style=label.style_label_right, size=size.tiny)
    sdD2lb := label.new(bar_index, sdDn2, "−2σ", color=color.new(color.blue, 80), textcolor=color.blue, style=label.style_label_right, size=size.tiny)
    sdU3lb := label.new(bar_index, sdUp3, "+3σ", color=color.new(color.blue, 80), textcolor=color.blue, style=label.style_label_right, size=size.tiny)
    sdD3lb := label.new(bar_index, sdDn3, "−3σ", color=color.new(color.blue, 80), textcolor=color.blue, style=label.style_label_right, size=size.tiny)

// Extend SD lines each bar
if showSD and not na(sdU1l)
    line.set_x2(sdU1l, bar_index + 2),  line.set_x2(sdD1l, bar_index + 2)
    line.set_x2(sdU2l, bar_index + 2),  line.set_x2(sdD2l, bar_index + 2)
    line.set_x2(sdU3l, bar_index + 2),  line.set_x2(sdD3l, bar_index + 2)

// ═══════════════════════════════════════════════════════════════
// LIQUIDITY SWEEP
// ═══════════════════════════════════════════════════════════════
recentHigh  = ta.highest(high, liqLookback)[1]
recentLow   = ta.lowest(low,   liqLookback)[1]
bullSweep   = low  < recentLow  and close > recentLow
bearSweep   = high > recentHigh and close < recentHigh
orHighSweep = not na(orHigh) and high > orHigh and close < orHigh
orLowSweep  = not na(orLow)  and low  < orLow  and close > orLow

// ═══════════════════════════════════════════════════════════════
// ORDER BLOCKS
// ═══════════════════════════════════════════════════════════════
bullDisplace  = close > open and (close - open) > atr * displacement
bearDisplace  = open > close and (open - close) > atr * displacement
bullOB_active = bullDisplace and open[1] > close[1]
bearOB_active = bearDisplace and open[1] < close[1]

if showOB and bullOB_active
    box.new(bar_index - 1, high[1], bar_index + 20, low[1],
            border_color=color.green, border_width=1, bgcolor=bullOBColor)

if showOB and bearOB_active
    box.new(bar_index - 1, high[1], bar_index + 20, low[1],
            border_color=color.red, border_width=1, bgcolor=bearOBColor)

// ═══════════════════════════════════════════════════════════════
// REJECTION BLOCKS
// A Rejection Block is identified by a candle with a dominant
// wick that shows price was strongly rejected from a level.
// Bullish RB: long lower wick (buyers absorbed supply aggressively)
// Bearish RB: long upper wick (sellers absorbed demand aggressively)
// The RB zone = the full wick range (body edge to tip of wick)
// ═══════════════════════════════════════════════════════════════
candleRange   = high - low
bodyTop       = math.max(open, close)
bodyBot       = math.min(open, close)
upperWick     = high - bodyTop
lowerWick     = bodyBot - low

// Bullish RB: lower wick >= rbWickMult of total range, small upper wick
bullRB = candleRange > 0 and
         (lowerWick / candleRange) >= rbWickMult and
         lowerWick > upperWick * 2

// Bearish RB: upper wick >= rbWickMult of total range, small lower wick
bearRB = candleRange > 0 and
         (upperWick / candleRange) >= rbWickMult and
         upperWick > lowerWick * 2

if showRB and bullRB
    // Zone = from body bottom down to low (the wick zone)
    box.new(bar_index, bodyBot, bar_index + 20, low,
            border_color=color.green, border_width=1,
            bgcolor=bullRBColor)
    label.new(bar_index, low, "RB",
              color=color.new(color.green, 70), textcolor=color.green,
              style=label.style_label_up, size=size.tiny)

if showRB and bearRB
    // Zone = from body top up to high (the wick zone)
    box.new(bar_index, high, bar_index + 20, bodyTop,
            border_color=color.red, border_width=1,
            bgcolor=bearRBColor)
    label.new(bar_index, high, "RB",
              color=color.new(color.red, 70), textcolor=color.red,
              style=label.style_label_down, size=size.tiny)

// ═══════════════════════════════════════════════════════════════
// FAIR VALUE GAPS
// ═══════════════════════════════════════════════════════════════
bullFVG = low[0] > high[2] and close[1] > open[1]
bearFVG = high[0] < low[2] and open[1]  > close[1]

if showFVG and bullFVG
    box.new(bar_index - 2, low[0],  bar_index + 25, high[2],
            border_color=color.teal,   border_width=1, bgcolor=bullFVGColor)

if showFVG and bearFVG
    box.new(bar_index - 2, high[0], bar_index + 25, low[2],
            border_color=color.orange, border_width=1, bgcolor=bearFVGColor)

// ═══════════════════════════════════════════════════════════════
// ENTRY SIGNALS
// Long: sweep of lows + OB/FVG/RB/OTE confluence
// Short: sweep of highs + OB/FVG/RB/OTE confluence
// ═══════════════════════════════════════════════════════════════
nearFib    = not na(orMid)  ? math.abs(close - orMid)  < atr * 0.5 : false
nearORHigh = not na(orHigh) ? math.abs(close - orHigh) < atr * 0.5 : false
nearORLow  = not na(orLow)  ? math.abs(close - orLow)  < atr * 0.5 : false
inOTEzone  = not na(oteTop) and not na(oteBot) ? close <= oteTop and close >= oteBot : false
nearSD1Up  = not na(sdUp1)  ? math.abs(close - sdUp1)  < atr * 0.3 : false
nearSD1Dn  = not na(sdDn1)  ? math.abs(close - sdDn1)  < atr * 0.3 : false

bullConfl  = bullOB_active[1] or bullFVG[1] or bullRB[1] or nearFib or nearORLow or inOTEzone or nearSD1Dn
bearConfl  = bearOB_active[1] or bearFVG[1] or bearRB[1] or nearFib or nearORHigh or inOTEzone or nearSD1Up

anySweepBull = bullSweep or orLowSweep
anySweepBear = bearSweep or orHighSweep

longSignal  = showSignals and isRTH and anySweepBull and bullConfl and close > orLow
shortSignal = showSignals and isRTH and anySweepBear and bearConfl and close < orHigh

plotshape(longSignal,  title="Long",  location=location.belowbar,
          style=shape.triangleup,   size=size.normal,
          color=color.lime, text="LONG",  textcolor=color.lime)

plotshape(shortSignal, title="Short", location=location.abovebar,
          style=shape.triangledown, size=size.normal,
          color=color.red,  text="SHORT", textcolor=color.red)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(longSignal,  title="ICT Long",       message="ICT LONG: Sweep + OB/FVG/RB + OTE/SD Confluence")
alertcondition(shortSignal, title="ICT Short",      message="ICT SHORT: Sweep + OB/FVG/RB + OTE/SD Confluence")
alertcondition(bullRB,      title="Bull Rejection Block", message="Bullish Rejection Block detected")
alertcondition(bearRB,      title="Bear Rejection Block", message="Bearish Rejection Block detected")
alertcondition(inOTEzone,   title="Price in OTE Zone",    message="Price entered OTE zone 62-79%")

// ═══════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 14,
                           border_width=1,
                           border_color=color.new(color.gray, 50),
                           bgcolor=color.new(color.black, 65))

if barstate.islast
    table.cell(dash, 0, 0,  "ICT NQ/ES v3",   text_color=color.yellow, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(dash, 1, 0,  "LEVEL / STATUS",  text_color=color.yellow, bgcolor=color.new(color.black, 40), text_size=size.small)

    table.cell(dash, 0, 1,  "OR High",         text_color=color.white,  text_size=size.small)
    table.cell(dash, 1, 1,  not na(orHigh) ? str.tostring(orHigh, "#.00") : "—", text_color=color.yellow, text_size=size.small)
    table.cell(dash, 0, 2,  "OR Low",          text_color=color.white,  text_size=size.small)
    table.cell(dash, 1, 2,  not na(orLow)  ? str.tostring(orLow,  "#.00") : "—", text_color=color.yellow, text_size=size.small)
    table.cell(dash, 0, 3,  "OR Mid (0.5)",    text_color=color.white,  text_size=size.small)
    table.cell(dash, 1, 3,  not na(orMid)  ? str.tostring(orMid,  "#.00") : "—", text_color=color.aqua,   text_size=size.small)

    table.cell(dash, 0, 4,  "PDH",             text_color=color.white,  text_size=size.small)
    table.cell(dash, 1, 4,  not na(pdHigh) ? str.tostring(pdHigh, "#.00") : "—", text_color=color.red,    text_size=size.small)
    table.cell(dash, 0, 5,  "PDL",             text_color=color.white,  text_size=size.small)
    table.cell(dash, 1, 5,  not na(pdLow)  ? str.tostring(pdLow,  "#.00") : "—", text_color=color.lime,   text_size=size.small)

    table.cell(dash, 0, 6,  "Week Open",       text_color=color.white,  text_size=size.small)
    table.cell(dash, 1, 6,  not na(weekOpenPrice) ? str.tostring(weekOpenPrice, "#.00") : "—", text_color=color.purple, text_size=size.small)

    table.cell(dash, 0, 7,  "OTE Top",         text_color=color.white,  text_size=size.small)
    table.cell(dash, 1, 7,  not na(oteTop) ? str.tostring(oteTop, "#.00") : "—", text_color=color.fuchsia, text_size=size.small)
    table.cell(dash, 0, 8,  "OTE Bot",         text_color=color.white,  text_size=size.small)
    table.cell(dash, 1, 8,  not na(oteBot) ? str.tostring(oteBot, "#.00") : "—", text_color=color.fuchsia, text_size=size.small)

    table.cell(dash, 0, 9,  "SD +1σ / −1σ",   text_color=color.white,  text_size=size.small)
    sdStr = not na(sdUp1) ? str.tostring(sdUp1, "#.00") + " / " + str.tostring(sdDn1, "#.00") : "—"
    table.cell(dash, 1, 9,  sdStr,             text_color=color.blue,   text_size=size.small)

    table.cell(dash, 0, 10, "SD +2σ / −2σ",   text_color=color.white,  text_size=size.small)
    sdStr2 = not na(sdUp2) ? str.tostring(sdUp2, "#.00") + " / " + str.tostring(sdDn2, "#.00") : "—"
    table.cell(dash, 1, 10, sdStr2,            text_color=color.blue,   text_size=size.small)

    table.cell(dash, 0, 11, "In OTE",          text_color=color.white,  text_size=size.small)
    table.cell(dash, 1, 11, inOTEzone ? "YES ✅" : "NO",
               text_color=inOTEzone ? color.fuchsia : color.gray, text_size=size.small)

    table.cell(dash, 0, 12, "RTH",             text_color=color.white,  text_size=size.small)
    table.cell(dash, 1, 12, isRTH ? "ACTIVE ✅" : "CLOSED ❌",
               text_color=isRTH ? color.lime : color.gray, text_size=size.small)

    sweepSt = (bullSweep or orLowSweep) ? "BULL 🟢" : (bearSweep or orHighSweep) ? "BEAR 🔴" : "None"
    table.cell(dash, 0, 13, "Sweep",           text_color=color.white,  text_size=size.small)
    table.cell(dash, 1, 13, sweepSt,
               text_color=(bullSweep or orLowSweep) ? color.lime : (bearSweep or orHighSweep) ? color.red : color.gray,
               text_size=size.small)
````
