# #1187 PRPV3

- url: https://www.tradingview.com/script/eqCgHS1E-1187-PRPV3/
- type: indicator
- pine_id: PUB;bef25a8be1b3428aade27fba6359da18
- version: 4.0

## Description

PRPV3 Indicator is a multi-layer momentum and trend framework designed for intraday market structure analysis ⚡

The script combines a custom adaptive smoothing engine 🧠 with EMA confirmation logic 📊 to identify directional momentum shifts, continuation phases 🔄, and short-term trend transitions 📉📈.

🔹 Main Components:

⚙️ PR Trend Engine
Adaptive momentum flow system designed to reduce short-term market noise while maintaining responsiveness during intraday volatility 🌊

📊 EMA Structure Layer
Multi-EMA alignment used for directional confirmation and continuation filtering.

🟢 BUY / 🔴 SELL Signals
Generated from momentum transition events and directional flow shifts.

🚀 BUY+ / 📉 SELL+ Signals
Continuation-based entries triggered when momentum and EMA structure align after the initial signal.

🎨 PR Ribbon
Visual trend-state ribbon for directional awareness and market flow visualization.

🧭 MTF Dashboard
Optional multi-timeframe EMA structure overview for broader market context.

⏱️ The script is intended for discretionary intraday analysis and trend continuation monitoring across multiple market conditions.

⚠️ This indicator is designed as a market analysis framework and should not be considered standalone financial advice.

## Source Code

````pine
// This work is protected by copyright.
// Copyright © 2026 PR PROJECT. All Rights Reserved.
//
// You may use this indicator for personal trading.
// You may NOT copy, republish, redistribute, sell,
// modify and republish, or claim this work as your own
// without prior written permission from the author.
//
// Author : AbgBujang7
//=============================================================================//

//@version=6
indicator("PR PROJECT V3", overlay=true, max_labels_count=500)

// GROUPS
groupEMA = "Moving Average"
groupFilter = "Filter"
groupRibbon = "PR Ribbon"
groupDashboard = "MTF Dashboard"
groupSigColor = "Signal Labels - Colors"
groupSigSize = "Signal Labels - Size"

// FIXED PR TREND ENGINE SETTINGS
src = close
modeSwitch = "Thma"
length = 1000
lengthMult = 2.0

// EMA SETTINGS
emaFastLen = 3
emaMidLen = 8
emaSlowLen = 21

showEMA = input.bool(false, "Show EMA Visual?", group=groupEMA)

// PR RIBBON
showPRRibbon = input.bool(true, "Show PR Ribbon", group=groupRibbon)
ribbonOpacity = input.int(
     20,
     "Ribbon Opacity",
     minval=0,
     maxval=100,
     group=groupRibbon
)

// EMA COLORS
emaFastColor = input.color(
     color.aqua,
     "Fast EMA Color",
     group=groupEMA
)

emaMidColor = input.color(
     color.orange,
     "Mid EMA Color",
     group=groupEMA
)

emaSlowColor = input.color(
     color.rgb(255, 0, 0),
     "Slow EMA Color",
     group=groupEMA
)

// FILTER
maxPlusSignal = input.int(
     3,
     "Max BUY+/SELL+ Count",
     group=groupFilter
)

atrLen = input.int(
     14,
     "ATR Length",
     group=groupFilter
)

atrMult = input.float(
     0.1,
     "Signal Offset (xATR)",
     group=groupFilter
)

// DASHBOARD
showDashboard = input.bool(
     false,
     "Show MTF Dashboard",
     group=groupDashboard
)

dashboardPos = input.string(
     "Top Right",
     "Dashboard Position",
     options=[
         "Top Right",
         "Top Left",
         "Bottom Right",
         "Bottom Left"
     ],
     group=groupDashboard
)

dashboardSizeInput = input.string(
     "small",
     "Dashboard Text Size",
     options=[
         "tiny",
         "small",
         "normal",
         "large",
         "huge"
     ],
     group=groupDashboard
)

dashPosition =
     dashboardPos == "Top Left" ? position.top_left :
     dashboardPos == "Bottom Right" ? position.bottom_right :
     dashboardPos == "Bottom Left" ? position.bottom_left :
     position.top_right

dashSize =
     dashboardSizeInput == "tiny" ? size.tiny :
     dashboardSizeInput == "small" ? size.small :
     dashboardSizeInput == "large" ? size.large :
     dashboardSizeInput == "huge" ? size.huge :
     size.normal

// SIGNAL COLORS
buyColor = input.color(
     color.new(#146E02, 20),
     "BUY Background",
     group=groupSigColor
)

sellColor = input.color(
     color.new(#A00101, 20),
     "SELL Background",
     group=groupSigColor
)

buyPlusColor = input.color(
     color.new(#00BCD4, 50),
     "BUY+ Background",
     group=groupSigColor
)

sellPlusColor = input.color(
     color.new(#ff9800, 50),
     "SELL+ Background",
     group=groupSigColor
)

// SIGNAL SIZE
signalSize = input.string(
     "normal",
     "BUY / SELL",
     options=[
         "tiny",
         "small",
         "normal",
         "large",
         "huge"
     ],
     group=groupSigSize
)

signalPlusSize = input.string(
     "normal",
     "BUY+ / SELL+",
     options=[
         "tiny",
         "small",
         "normal",
         "large",
         "huge"
     ],
     group=groupSigSize
)

sigSize =
     signalSize == "tiny" ? size.tiny :
     signalSize == "small" ? size.small :
     signalSize == "large" ? size.large :
     signalSize == "huge" ? size.huge :
     size.normal

sigPlusSize =
     signalPlusSize == "tiny" ? size.tiny :
     signalPlusSize == "small" ? size.small :
     signalPlusSize == "large" ? size.large :
     signalPlusSize == "huge" ? size.huge :
     size.normal

// PR TREND ENGINE
prFlow(_src, _length, _profile) =>
    _half = math.max(
         1,
         math.round(_length / 2)
    )

    _root = math.max(
         1,
         math.round(math.sqrt(_length))
    )

    _third = math.max(
         1,
         math.round(_length / 3)
    )

    _fastFlow = ta.wma(
         2 * ta.wma(_src, _half) -
         ta.wma(_src, _length),
         _root
    )

    _softFlow = ta.ema(
         2 * ta.ema(_src, _half) -
         ta.ema(_src, _length),
         _root
    )

    _deepFlow = ta.wma(
         ta.wma(_src, _third) * 3 -
         ta.wma(_src, _half) -
         ta.wma(_src, _length),
         _length
    )

    _profile == "Fast" ? _fastFlow :
     _profile == "Soft" ? _softFlow :
     _deepFlow

prProfile =
     modeSwitch == "Hma" ? "Fast" :
     modeSwitch == "Ehma" ? "Soft" :
     "Deep"

// EMA TREND TEXT
emaTrendText(_tf) =>
    _fast = request.security(
         syminfo.tickerid,
         _tf,
         ta.ema(close, emaFastLen)
    )

    _mid = request.security(
         syminfo.tickerid,
         _tf,
         ta.ema(close, emaMidLen)
    )

    _slow = request.security(
         syminfo.tickerid,
         _tf,
         ta.ema(close, emaSlowLen)
    )

    _bull = _fast > _mid and _mid > _slow
    _bear = _fast < _mid and _mid < _slow

    _bull ? "BULLISH" :
     _bear ? "BEARISH" :
     "NEUTRAL"

emaTrendColor(_trend) =>
    _trend == "BULLISH" ? color.new(color.green, 15) :
     _trend == "BEARISH" ? color.new(color.red, 15) :
     color.new(color.gray, 30)

// PR TREND CORE
prLen = math.round(length * lengthMult)

prMain = prFlow(
     src,
     prLen,
     prProfile
)

prGuide = prMain[2]

prBull = prMain > prGuide
prBear = prMain < prGuide

prColor = prBull ? color.lime : color.red

prTurnBull =
     barstate.isconfirmed and
     prBull and
     not prBull[1]

prTurnBear =
     barstate.isconfirmed and
     prBear and
     not prBear[1]

// EMA
emaFast = ta.ema(close, emaFastLen)
emaMid = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)

bullishStack =
     emaFast > emaMid and
     emaMid > emaSlow

bearishStack =
     emaFast < emaMid and
     emaMid < emaSlow

bullishCross =
     barstate.isconfirmed and
     bullishStack and
     not bullishStack[1]

bearishCross =
     barstate.isconfirmed and
     bearishStack and
     not bearishStack[1]

// SIGNAL
buySignal = prTurnBull
sellSignal = prTurnBear

// OFFSET
atrValue = ta.atr(atrLen)
offset = atrValue * atrMult

// STATE
var int activeSignal = 0
var int activeBar = na
var int buyPlusCount = 0
var int sellPlusCount = 0
var bool pendingBuyPlus = false
var bool pendingSellPlus = false

if buySignal
    activeSignal := 1
    activeBar := bar_index
    buyPlusCount := 0
    pendingBuyPlus := bullishStack

if sellSignal
    activeSignal := -1
    activeBar := bar_index
    sellPlusCount := 0
    pendingSellPlus := bearishStack

buyPlusSignal =
     barstate.isconfirmed and
     buyPlusCount < maxPlusSignal and
     (
         (
             activeSignal == 1 and
             pendingBuyPlus and
             bar_index == activeBar + 1
         )
         or
         (
             activeSignal == 1 and
             bullishCross
         )
     )

sellPlusSignal =
     barstate.isconfirmed and
     sellPlusCount < maxPlusSignal and
     (
         (
             activeSignal == -1 and
             pendingSellPlus and
             bar_index == activeBar + 1
         )
         or
         (
             activeSignal == -1 and
             bearishCross
         )
     )

if buyPlusSignal
    buyPlusCount += 1
    pendingBuyPlus := false

if sellPlusSignal
    sellPlusCount += 1
    pendingSellPlus := false

// PR RIBBON
plotshape(
     showPRRibbon,
     title="PR Ribbon",
     style=shape.square,
     location=location.bottom,
     color=color.new(prColor, ribbonOpacity),
     size=size.tiny
)

// PLOT EMA
plot(
     showEMA ? emaFast : na,
     title="Fast EMA",
     color=emaFastColor,
     linewidth=2
)

plot(
     showEMA ? emaMid : na,
     title="Mid EMA",
     color=emaMidColor,
     linewidth=2
)

plot(
     showEMA ? emaSlow : na,
     title="Slow EMA",
     color=emaSlowColor,
     linewidth=2
)

// DASHBOARD TABLE
var table dash = table.new(
     dashPosition,
     2,
     6,
     border_width=1
)

if barstate.islast and showDashboard
    t1 = emaTrendText("1")
    t5 = emaTrendText("5")
    t15 = emaTrendText("15")
    t30 = emaTrendText("30")
    t60 = emaTrendText("60")

    table.cell(
         dash,
         0,
         0,
         "Timeframe",
         text_color=color.white,
         bgcolor=color.new(color.black, 0),
         text_size=dashSize
    )

    table.cell(
         dash,
         1,
         0,
         "Trend",
         text_color=color.white,
         bgcolor=color.new(color.black, 0),
         text_size=dashSize
    )

    table.cell(
         dash,
         0,
         1,
         "M1",
         text_color=color.white,
         bgcolor=color.new(color.black, 70),
         text_size=dashSize
    )

    table.cell(
         dash,
         1,
         1,
         t1,
         text_color=color.white,
         bgcolor=emaTrendColor(t1),
         text_size=dashSize
    )

    table.cell(
         dash,
         0,
         2,
         "M5",
         text_color=color.white,
         bgcolor=color.new(color.black, 70),
         text_size=dashSize
    )

    table.cell(
         dash,
         1,
         2,
         t5,
         text_color=color.white,
         bgcolor=emaTrendColor(t5),
         text_size=dashSize
    )

    table.cell(
         dash,
         0,
         3,
         "M15",
         text_color=color.white,
         bgcolor=color.new(color.black, 70),
         text_size=dashSize
    )

    table.cell(
         dash,
         1,
         3,
         t15,
         text_color=color.white,
         bgcolor=emaTrendColor(t15),
         text_size=dashSize
    )

    table.cell(
         dash,
         0,
         4,
         "M30",
         text_color=color.white,
         bgcolor=color.new(color.black, 70),
         text_size=dashSize
    )

    table.cell(
         dash,
         1,
         4,
         t30,
         text_color=color.white,
         bgcolor=emaTrendColor(t30),
         text_size=dashSize
    )

    table.cell(
         dash,
         0,
         5,
         "H1",
         text_color=color.white,
         bgcolor=color.new(color.black, 70),
         text_size=dashSize
    )

    table.cell(
         dash,
         1,
         5,
         t60,
         text_color=color.white,
         bgcolor=emaTrendColor(t60),
         text_size=dashSize
    )

if barstate.islast and not showDashboard
    table.clear(
         dash,
         0,
         0,
         1,
         5
    )

// EXTRA SPACING
extraOffset = atrValue * 0.2

buyY = low - offset
buyPlusY = low - offset - extraOffset

sellY = high + offset
sellPlusY = high + offset + extraOffset

// LABELS
if buySignal
    label.new(
         bar_index,
         buyY,
         "BUY",
         style=label.style_label_up,
         color=buyColor,
         textcolor=color.white,
         size=sigSize
    )

if buyPlusSignal
    label.new(
         bar_index,
         buyPlusY,
         "BUY+",
         style=label.style_label_up,
         color=buyPlusColor,
         textcolor=color.white,
         size=sigPlusSize
    )

if sellSignal
    label.new(
         bar_index,
         sellY,
         "SELL",
         style=label.style_label_down,
         color=sellColor,
         textcolor=color.white,
         size=sigSize
    )

if sellPlusSignal
    label.new(
         bar_index,
         sellPlusY,
         "SELL+",
         style=label.style_label_down,
         color=sellPlusColor,
         textcolor=color.white,
         size=sigPlusSize
    )

// ALERTS
alertcondition(
     buySignal,
     title="BUY Signal",
     message="PR PROJECT V3: BUY signal confirmed"
)

alertcondition(
     sellSignal,
     title="SELL Signal",
     message="PR PROJECT V3: SELL signal confirmed"
)

alertcondition(
     buyPlusSignal,
     title="BUY+ Signal",
     message="PR PROJECT V3: BUY+ continuation confirmed"
)

alertcondition(
     sellPlusSignal,
     title="SELL+ Signal",
     message="PR PROJECT V3: SELL+ continuation confirmed"
)

alertcondition(
     prTurnBull,
     title="PR Ribbon Turned Green",
     message="PR PROJECT V3: PR Ribbon turned green"
)

alertcondition(
     prTurnBear,
     title="PR Ribbon Turned Red",
     message="PR PROJECT V3: PR Ribbon turned red"
)

alertcondition(
     bullishCross,
     title="Bullish EMA Structure",
     message="PR PROJECT V3: EMA bullish structure confirmed"
)

alertcondition(
     bearishCross,
     title="Bearish EMA Structure",
     message="PR PROJECT V3: EMA bearish structure confirmed"
)

alertcondition(
     barstate.isconfirmed and bullishStack,
     title="EMA Bullish Active",
     message="PR PROJECT V3: EMA bullish structure active"
)

alertcondition(
     barstate.isconfirmed and bearishStack,
     title="EMA Bearish Active",
     message="PR PROJECT V3: EMA bearish structure active"
)

alertcondition(
     buySignal or buyPlusSignal,
     title="Any BUY Alert",
     message="PR PROJECT V3: BUY / BUY+ alert"
)

alertcondition(
     sellSignal or sellPlusSignal,
     title="Any SELL Alert",
     message="PR PROJECT V3: SELL / SELL+ alert"
)

alertcondition(
     buySignal or
     sellSignal or
     buyPlusSignal or
     sellPlusSignal,
     title="Any Signal Alert",
     message="PR PROJECT V3: Any signal confirmed"
)
````
