# Gold Compass Lite

- url: https://www.tradingview.com/script/jp0AVM4D-Gold-Compass-Lite/
- type: indicator
- pine_id: PUB;3d3d5d87f9594b9794af36d346e8ac8e
- version: 1.0

## Description

[b]OVERVIEW[/b]

Gold Compass Lite is a simplified, fully open-source companion to Gold Compass Pro, giving traders a free, at-a-glance read on Gold (XAUUSD) trend, pullback, momentum, and compression conditions via a compact dashboard.

[b]HOW IT WORKS[/b]

[list]
[*]Trend — derived from price position relative to the 50/100/200 EMA structure.
[*]Pullback — flagged when price sits on the opposite side of the 21 EMA from the prevailing trend.
[*]Momentum — a stochastic %K/%D crossover.
[*]Compression — flagged when recent closing-price standard deviation falls below a fraction of current ATR.
[/list]

These four conditions are combined directly into the dashboard's Trend, Signal, Action, Market State, and Momentum fields — there is no filtering, confirmation, or signal-locking layer between the raw conditions and the display. This is intentionally a simpler, faster read than Pro, not a scaled-down version of Pro's multi-engine logic.

[b]WHY THE SOURCE IS OPEN[/b]

The logic above is fully visible in the code below. Gold Compass Lite is meant to demonstrate our approach to trend, pullback, momentum, and compression analysis on gold — feel free to review, learn from, or build on it.

[b]LIMITATIONS[/b]

Uses historical and current price data only; it cannot predict future prices. Not a signal generator — it is a context dashboard meant to be read alongside your own analysis, not traded mechanically.

## Source Code

````pine
//@version=6
indicator("Gold Compass Lite", overlay=true, max_labels_count=500)

//==================================================
// DISPLAY
//==================================================
panelMode = input.string("Full", "Panel Mode", options=["Full", "Compact"])

//==================================================
// INPUTS
//==================================================
fastLen        = input.int(50,  "Fast EMA")
slowLen        = input.int(100, "Slow EMA")
macroLen       = input.int(200, "Macro EMA")
pullbackEMALen = input.int(21,  "Pullback EMA")

stochLen = input.int(14, "Stochastic Length")
atrLen   = input.int(14, "ATR Length")

//==================================================
// CALCULATIONS
//==================================================
fastEMA     = ta.ema(close, fastLen)
slowEMA     = ta.ema(close, slowLen)
macroEMA    = ta.ema(close, macroLen)
pullbackEMA = ta.ema(close, pullbackEMALen)

rawK   = ta.stoch(close, high, low, stochLen)
stochK = ta.sma(rawK, 3)
stochD = ta.sma(stochK, 3)

atrValue = ta.atr(atrLen)

//==================================================
// TREND
//==================================================
bullMacro = close > macroEMA and fastEMA > slowEMA
bearMacro = close < macroEMA and fastEMA < slowEMA

watchLong  = bullMacro
watchShort = bearMacro

//==================================================
// CONTEXT LOGIC
//==================================================
bullRetracement = bullMacro and close < pullbackEMA
bearRetracement = bearMacro and close > pullbackEMA

bullMomentumShift = ta.crossover(stochK, stochD)
bearMomentumShift = ta.crossunder(stochK, stochD)

isCompression = ta.stdev(close, 8) < atrValue * 0.3

//==================================================
// INTERPRETATION
//==================================================
signalType =
     bearRetracement ? "Short-Term Retracement" :
     bullRetracement ? "Short-Term Retracement" :
     bullMomentumShift ? "Momentum Shift" :
     bearMomentumShift ? "Momentum Shift" :
     isCompression ? "Compression" :
     watchShort ? "Bearish Pressure" :
     watchLong ? "Bullish Pressure" :
     "No Clear Signal"

possibleAction =
     bearRetracement ? "Watch Short" :
     bullRetracement ? "Watch Long" :
     bullMomentumShift ? "Stay Patient" :
     bearMomentumShift ? "Stay Patient" :
     watchShort ? "Watch Short" :
     watchLong ? "Watch Long" :
     "Neutral"

//==================================================
// VISUALS
//==================================================
plot(macroEMA, "200 EMA", color=color.yellow, linewidth=2)
plot(pullbackEMA, "21 EMA", color=color.purple, linewidth=2)

//==================================================
// PANEL COLORS
//==================================================
trendBg =
     bullMacro ? color.new(color.green, 10) :
     bearMacro ? color.new(color.red, 10) :
     color.new(color.gray, 20)

signalBg =
     signalType == "Bullish Pressure" ? color.new(color.green, 20) :
     signalType == "Bearish Pressure" ? color.new(color.red, 20) :
     signalType == "Compression" ? color.new(color.orange, 20) :
     signalType == "Momentum Shift" ? color.new(color.yellow, 20) :
     color.new(color.gray, 30)

actionBg =
     possibleAction == "Watch Long" ? color.new(color.green, 10) :
     possibleAction == "Watch Short" ? color.new(color.red, 10) :
     color.new(color.gray, 30)

//==================================================
// PANEL TABLE
//==================================================
txtSize = size.small
var table dash = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast
    for r = 0 to 5
        table.cell(dash, 0, r, "", bgcolor=color.new(color.black, 100))
        table.cell(dash, 1, r, "", bgcolor=color.new(color.black, 100))

    if panelMode == "Full"
        table.cell(dash, 0, 0, "Gold Compass Lite", text_color=color.white, bgcolor=color.black, text_size=txtSize)
        table.cell(dash, 1, 0, "Market Context", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=txtSize)

        table.cell(dash, 0, 1, "Trend", text_color=color.white, bgcolor=color.black, text_size=txtSize)
        table.cell(dash, 1, 1, bullMacro ? "Bullish" : bearMacro ? "Bearish" : "Neutral", text_color=color.black, bgcolor=trendBg, text_size=txtSize)

        table.cell(dash, 0, 2, "Signal", text_color=color.white, bgcolor=color.black, text_size=txtSize)
        table.cell(dash, 1, 2, signalType, text_color=color.black, bgcolor=signalBg, text_size=txtSize)

        table.cell(dash, 0, 3, "Action", text_color=color.white, bgcolor=color.black, text_size=txtSize)
        table.cell(dash, 1, 3, possibleAction, text_color=color.black, bgcolor=actionBg, text_size=txtSize)

        table.cell(dash, 0, 4, "Market State", text_color=color.white, bgcolor=color.black, text_size=txtSize)
        table.cell(dash, 1, 4,
             isCompression ? "Compression" :
             bullRetracement or bearRetracement ? "Pullback" :
             bullMacro or bearMacro ? "Trending" :
             "Neutral",
             text_color=color.black, bgcolor=color.new(color.gray, 10), text_size=txtSize)

        table.cell(dash, 0, 5, "Momentum", text_color=color.white, bgcolor=color.black, text_size=txtSize)
        table.cell(dash, 1, 5,
             stochK > stochD ? "Bullish" :
             stochK < stochD ? "Bearish" :
             "Neutral",
             text_color=color.black, bgcolor=color.new(color.gray, 10), text_size=txtSize)

    else
        table.cell(dash, 0, 0, "Gold Compass Lite", text_color=color.white, bgcolor=color.black, text_size=txtSize)
        table.cell(dash, 1, 0, "Compact", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=txtSize)

        table.cell(dash, 0, 1, "Trend", text_color=color.white, bgcolor=color.black, text_size=txtSize)
        table.cell(dash, 1, 1, bullMacro ? "Bull" : bearMacro ? "Bear" : "Neutral", text_color=color.black, bgcolor=trendBg, text_size=txtSize)

        table.cell(dash, 0, 2, "Signal", text_color=color.white, bgcolor=color.black, text_size=txtSize)
        table.cell(dash, 1, 2, signalType, text_color=color.black, bgcolor=signalBg, text_size=txtSize)

        table.cell(dash, 0, 3, "Action", text_color=color.white, bgcolor=color.black, text_size=txtSize)
        table.cell(dash, 1, 3, possibleAction, text_color=color.black, bgcolor=actionBg, text_size=txtSize)
````
