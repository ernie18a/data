# Buy Sell Momentum Entries v2

- url: https://www.tradingview.com/script/QgwIDTnd-Buy-Sell-Momentum-Entries-v2/
- type: indicator
- pine_id: PUB;96be71a6e9344c80a723a6f296a90a2f
- version: 2.0

## Description

Momentum Entries v2 is a simple buy/sell confirmation indicator built to find strong continuation candles after momentum begins.

It is not meant to predict every move or catch every reversal. The goal is to filter for cleaner entries where price is already showing displacement, direction, and follow-through.

I personally like these settings on the 1-minute chart:

Confirmation Push Ticks: 40
Min Body %: 60
Cooldown Bars After Signal: 0
Block Same-Side Repeats: On
Fast EMA: 9
Slow EMA: 21
Use Fast EMA Filter: On
Use Slow EMA Filter: On
Require Fast EMA Above/Below Slow EMA: On

You can adjust the settings however you like depending on your market, timeframe, and trading style.

Important settings:

Confirmation Push Ticks:
How far price must push in the signal direction before a buy or sell can appear. Higher = fewer signals, stronger momentum required.

Min Body %:
Requires the candle body to be a certain percentage of the full candle range. Higher = stronger candles only.

Cooldown Bars After Signal:
Stops the indicator from giving another signal for a set number of bars after a signal. Higher = fewer signals.

Block Same-Side Repeats:
Prevents repeated buy-after-buy or sell-after-sell signals. This helps keep the chart cleaner.

Fast EMA Length:
The shorter EMA used for direction and trend confirmation.

Slow EMA Length:
The longer EMA used to confirm broader direction.

Use Fast / Slow EMA Filter:
Requires price to be on the correct side of the selected EMA before a signal appears.

Require Fast EMA Above/Below Slow EMA:
For buys, the fast EMA must be above the slow EMA.
For sells, the fast EMA must be below the slow EMA.
This helps avoid taking signals against the short-term trend.

Best use:
Use this as an entry confirmation tool, not a full trading system by itself. It works best when combined with your own levels, market structure, sweep areas, support/resistance, or higher-timeframe bias.

## Source Code

````pine
//@version=6
indicator("Buy Sell Momentum Entries v3", overlay=true, max_labels_count=500)

//====================================================
// INPUTS
//====================================================
groupCore = "Entry Logic"
confirmTicks = input.int(40, "Confirmation Push Ticks", minval=1, group=groupCore)
bodyPctMin   = input.float(60.0, "Min Body %", minval=0, maxval=100, step=5, group=groupCore)
cooldownBars = input.int(10, "Cooldown Bars After Signal", minval=0, group=groupCore)
noSameSideRepeat = input.bool(true, "Block Same-Side Repeats", group=groupCore)

groupEMA = "EMA Filters"
emaFastLen = input.int(9, "Fast EMA Length", minval=1, group=groupEMA)
emaSlowLen = input.int(21, "Slow EMA Length", minval=1, group=groupEMA)
useFastEma = input.bool(true, "Use Fast EMA Filter", group=groupEMA)
useSlowEma = input.bool(true, "Use Slow EMA Filter", group=groupEMA)
requireEmaTrend = input.bool(true, "Require Fast EMA Above/Below Slow EMA", group=groupEMA)

groupSession = "Session"
useSession = input.bool(true, "Use Session Filter", group=groupSession)
tradeSession = input.session("0930-1230", "Trade Session", group=groupSession)
sessionTZ = input.string("America/New_York", "Session Timezone", group=groupSession)

groupDisplay = "Display"
showEMAs   = input.bool(true, "Show EMAs", group=groupDisplay)
showLabels = input.bool(true, "Show Buy/Sell Labels", group=groupDisplay)
colorBars  = input.bool(true, "Color Signal Bars", group=groupDisplay)

buyColor   = input.color(color.lime, "Buy Color", group=groupDisplay)
sellColor  = input.color(color.red, "Sell Color", group=groupDisplay)
neutralColor = input.color(color.gray, "Neutral Bar Color", group=groupDisplay)
colorNeutralBars = input.bool(false, "Color Neutral Bars", group=groupDisplay)

//====================================================
// CALCS
//====================================================
inSession = not useSession or not na(time(timeframe.period, tradeSession, sessionTZ))

tickSize = syminfo.mintick
confirmMove = confirmTicks * tickSize

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

candleRange = high - low
bodySize = math.abs(close - open)
bodyPct = candleRange > 0 ? bodySize / candleRange * 100 : 0

//====================================================
// MOMENTUM CONDITIONS
//====================================================
buyBreak  = close > high[1]
sellBreak = close < low[1]

strongBody = bodyPct >= bodyPctMin

buyPush  = high >= close[1] + confirmMove
sellPush = low <= close[1] - confirmMove

buyEmaOk =
     (not useFastEma or close > emaFast) and
     (not useSlowEma or close > emaSlow) and
     (not requireEmaTrend or emaFast >= emaSlow)

sellEmaOk =
     (not useFastEma or close < emaFast) and
     (not useSlowEma or close < emaSlow) and
     (not requireEmaTrend or emaFast <= emaSlow)

//====================================================
// RAW SIGNALS BEFORE SESSION FILTER
//====================================================
rawBuyNoSession =
     buyBreak and
     strongBody and
     buyEmaOk and
     buyPush

rawSellNoSession =
     sellBreak and
     strongBody and
     sellEmaOk and
     sellPush

//====================================================
// COOLDOWN / REPEAT BLOCK
//====================================================
var int lastSignalBar = na
var int lastSignalDir = 0   // 1 buy, -1 sell

barsSinceSignal = na(lastSignalBar) ? 100000 : bar_index - lastSignalBar
cooldownOk = barsSinceSignal > cooldownBars

buyRepeatOk = not noSameSideRepeat or lastSignalDir != 1
sellRepeatOk = not noSameSideRepeat or lastSignalDir != -1

//====================================================
// FINAL DISPLAY SIGNALS
//====================================================
buySignal =
     barstate.isconfirmed and
     rawBuyNoSession and
     inSession and
     cooldownOk and
     buyRepeatOk

sellSignal =
     barstate.isconfirmed and
     rawSellNoSession and
     inSession and
     cooldownOk and
     sellRepeatOk

//====================================================
// STATE UPDATE
// Important:
// Updates from raw signals, not session-filtered signals.
// This stops signals from moving when session times change.
//====================================================
if barstate.isconfirmed
    if rawBuyNoSession and cooldownOk and buyRepeatOk
        lastSignalBar := bar_index
        lastSignalDir := 1

    if rawSellNoSession and cooldownOk and sellRepeatOk
        lastSignalBar := bar_index
        lastSignalDir := -1

//====================================================
// PLOTS
//====================================================
plot(showEMAs ? emaFast : na, "Fast EMA", color=color.orange, linewidth=1)
plot(showEMAs ? emaSlow : na, "Slow EMA", color=color.blue, linewidth=1)

plotshape(
     showLabels and buySignal,
     title="Buy",
     style=shape.labelup,
     location=location.belowbar,
     text="BUY",
     color=color.new(buyColor, 0),
     textcolor=color.black,
     size=size.small)

plotshape(
     showLabels and sellSignal,
     title="Sell",
     style=shape.labeldown,
     location=location.abovebar,
     text="SELL",
     color=color.new(sellColor, 0),
     textcolor=color.white,
     size=size.small)

//====================================================
// BAR COLOR
//====================================================
barCol =
     buySignal ? buyColor :
     sellSignal ? sellColor :
     colorNeutralBars ? neutralColor :
     na

barcolor(colorBars ? barCol : na)

//====================================================
// ALERTS
//====================================================
alertcondition(buySignal, "ATT Momentum Buy", "BUY ATT Momentum Entry")
alertcondition(sellSignal, "ATT Momentum Sell", "SELL ATT Momentum Entry")
````
