# Equilibrium Candles + Pattern [Honestcowboy]

- url: https://www.tradingview.com/script/e1wPKRCs-Equilibrium-Candles-Pattern-Honestcowboy/
- type: strategy
- pine_id: PUB;655f1f4fb7ce4977aa9ec5483047dee1
- version: 1.0

## Description

The Equilibrium Candles is a very simple trend continuation or reversal strategy depending on your settings.

[b]How an Equilibrium Candle is created:[/b]
[list=1]
[*]We calculate the equilibrium by measuring the mid point between highest and lowest point over X amount of bars back.
[*]This now is the opening price for each bar and will be considered a green bar if price closes above equilibrium.
[*]Bars get shaded by checking if regular candle close is higher than open etc. So you still see what the normal candles are doing.
[/list]
[b]
Why are they useful?[/b]

The equilibrium is calculated the same as Baseline in Ichimoku Cloud. Which provides a point where price is very likely to retrace to. This script visualises the distance between close and equilibrium using candles. To provide a clear visual of how price relates to this equilibrium point.

This also makes it more straightforward to develop strategies based on this simple concept and makes the trader purely focus on this relationship and not think of any Ichimoku Cloud theories.

Script uses a very simple pattern to enter trades:
[image]https://www.tradingview.com/x/RDLOykOp/[/image]
[list=1]
[*]It will count how many candles have been one directional (above or below equilibrium)
[*]Based on user input after X candles (7 by default) script shows we are in a trend (bg colors)
[*]On the first pullback (candle closes on other side of equilibrium) it will look to enter a trade.
[*]Places a stop order at the high of the candle if bullish trend or reverse if bearish trend.
[*]If based on user input after X opposite candles (2 by default) order is not filled will cancel it and look for a new trend.
[/list]

[b]Use Reverse Logic:[/b]
There is a use reverse logic in the settings which on default is turned on. It will turn long orders into short orders making the stop orders become limit orders. It will use the normal long SL as target for the short. And TP as stop for the short. This to provide a means to reverse equity curve in case your pair is mean reverting by nature instead of trending.

[b]ATR Calculation:[/b]
Averaged ATR, which is using ta.percentile_nearest_rank of 60% of a normal ATR (14 period) over the last 200 bars. This in simple words finds a value slightly above the mean ATR value over that period.

[b]Big Candle Exit Logic:[/b]
Using Averaged ATR the script will check if a candle closes X times that ATR from the equilibrium point. This is then considered an overextension and all trades are closed.
This is also based on user input.

[b]Simple trade management logic:[/b]
https://www.tradingview.com/x/VaSW6kE5/
[list=1]
[*]Checks if the user has selected to use TP and SL, or/and big candle exit.
[*]Places a TP and SL based on averaged ATR at a multiplier based on user Input.
[*]Closes trade if there is a Big Candle Exit or an opposite direction signal from indicator.
[/list]

[b]Script can be fully automated to MT5[/b]

There are risk settings in % and symbol settings provided at the bottom of the indicator. The script will send alert to MT5 broker trying to mimic the execution that happens on tradingview. There are always delays when using a bridge to MT5 broker and there could be errors so be mindful of that. This script sends alerts in format so they can be read by tradingview.to which is a bridge between the platforms. 

Use the all alert function calls feature when setting up alerts and make sure you provide the right webhook if you want to use this approach.

There is also a simple buy and sell alert feature if you don't want to fully automate but still get alerts. These are available in the dropdown when creating an alert.

Almost every setting in this indicator has a tooltip added to it. So if any setting is not clear hover over the (?) icon on the right of the setting.

The backtest uses a 4% exposure per trade and a 10 point slippage. I did not include a commission cause I'm not personaly aware what the commissions are on most forex brokers. I'm only aware of minimal slippage to use in a backtest. Trading conditions vary per broker you use so always pay close attention to trading costs on your own broker. Use a full automation at your own risk and discretion and do proper backtesting.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Honestcowboy

//@version=5
strategy("Equilibrium Candles + Pattern [Honestcowboy]", overlay=false, pyramiding=1, default_qty_type = strategy.percent_of_equity, default_qty_value = 4, initial_capital=20000, slippage=10)

// ================================== //
// ---------> User Input <----------- //
// ================================== //

candleSmoothing = input.int(9, title="Equilibrium Length", tooltip="The lookback for finding equilibrium.\nIt is same calculation as the Baseline in Ichimoku Cloud and is the mid point between highest and lowest value over this length.", group="Base Settings")
candlesForTrend = input.int(7, title="Candles needed for Trend", tooltip="The amount of candles in one direction (colored) before it's considered a trend.\nOrders get created on the first candle in opposite direction.", group="Base Settings")
maxPullbackCandles = input.int(2, title="Max Pullback (candles)", tooltip="The amount of candles can go in opposite direction until a pending trade order is cancelled.", group="Base Settings")
candle_bull_c1 = input.color(color.rgb(0,255,0), title="", inline="1", group="Candle Coloring")
candle_bull_c2 = input.color(color.rgb(0,100,0), title="", inline="1", group="Candle Coloring")
candle_bear_c1 = input.color(color.rgb(238,130,238), title="", inline="2", group="Candle Coloring")
candle_bear_c2 = input.color(color.rgb(75,0,130), title="", inline="2", group="Candle Coloring")
highlightClosePrices = input.bool(defval=true, title="Highlight close prices", group="Candle Coloring", tooltip="Will put small yellow dots where closing price would be.")
useBgColoring = input.bool(defval=true, title="color main chart Bg based on trend and entry point", tooltip="colors main chart background based on trend and entry points", group="Chart Background")
trend_bull_c = input.color(color.rgb(0,100,0,50), title="Trend Bull Color", group="Chart Background")
trend_bear_c = input.color(color.rgb(75,0,130, 50), title="Trend Bear Color", group="Chart Background")
long_zone_c = input.color(color.rgb(0,255,0,60), title="Long Entry Zone Color", group="Chart Background")
short_zone_c = input.color(color.rgb(238,130,238,60), title="Short Entry Zone Color", group="Chart Background")
atrLenghtScob = input.int(14, title="ATR Length", group = "Volatility Settings")
atrAverageLength = input.int(200, title="ATR percentile averages lookback", group = "Volatility Settings")
atrPercentile    = input.int(60, minval=0, maxval=99, title="ATR > bottom X percentile", group = "Volatility Settings", tooltip="For the Final ATR value in which percentile of last X bars does it need to be a number. At 60 it's the lowest ATR in top 40% of ATR over X bars")
useReverse = input.bool(true, title="Use Reverse", group="Strategy Inputs", tooltip="The Strategy will open short orders where normal strategy would open long orders. It will use the SL as TP and the TP as SL. So would create the exact opposite in returns as the normal strategy.")
stopMultiplier = input.float(2, title="stop+tp atr multiplier", group="Strategy Inputs")
useTPSL = input.bool(defval=true, title="use stop and TP", group="Strategy Inputs")
useBigCandleExit = input.bool(defval=true, title="Big Candle Exit", group="Strategy Inputs", inline="1", tooltip="Closes all open trades whenever price closes too far from the equilibrium")
bigCandleMultiplier = input.float(defval=1, title="Exit Multiplier", group="Strategy Inputs", inline="1", tooltip="The amount of times in ATR mean candle needs to close outside of equilibrium for it to be a big candle exit.")

tvToQPerc = input.float(defval=1, title="Trade size in Account risk %", group="Tradingview.to Connection (MT5)", tooltip="Quantity as a percentage with stop loss in the commands; the lot size is calculated based on the percentage to lose in case sl is hit. If SL is not specified, the Lot size will be calculated based on account balance.")
tvToOverrideSymbol = input.bool(defval=false, title="Override Symbol?", group="Tradingview.to Connection (MT5)")
tvToSymbol = input.string(defval="EURUSD", title="", group="Tradingview.to Connection (MT5)")
// ================================== //
// -----> Immutable Constants <------ //
// ================================== // 

var bool isBullTrend = false
var bool isBearTrend = false
var bool isLongCondition = false
var bool isShortCondition = false
var int bullCandleCount = 0
var int bearCandleCount = 0
var float longLine = na
var float shortLine = na

// ================================== //
// ---> Functional Declarations <---- //
// ================================== //

baseLine(len) =>
    math.avg(ta.lowest(len), ta.highest(len))

// ================================== //
// ----> Variable Calculations <----- //
// ================================== //

longSignal = false
shortSignal = false

equilibrium = baseLine(candleSmoothing)
atrEquilibrium = ta.atr(atrLenghtScob)
atrAveraged = ta.percentile_nearest_rank(atrEquilibrium, atrAverageLength, atrPercentile)
equilibriumTop  = equilibrium + atrAveraged*bigCandleMultiplier
equilibriumBottom = equilibrium - atrAveraged*bigCandleMultiplier

// ================================== //
// -----> Conditional Variables <---- //
// ================================== //
if not isBullTrend and close>equilibrium
    bullCandleCount := bullCandleCount + 1
    bearCandleCount := 0
    isBearTrend := false

if not isBearTrend and close<equilibrium
    bearCandleCount := bearCandleCount + 1
    bullCandleCount := 0
    isBullTrend := false

if bullCandleCount >= candlesForTrend
    isBullTrend := true
    isBearTrend := false
    bullCandleCount := 0
    bearCandleCount := 0
if bearCandleCount >= candlesForTrend
    isBearTrend := true
    isBullTrend := false
    bullCandleCount := 0
    bearCandleCount := 0

// ================================== //
// ------> Strategy Execution <------ //
// ================================== //

if isBullTrend[1] and close<equilibrium
    if useReverse and (not na(atrAveraged))
        strategy.entry("short", strategy.short, limit=high)
        alert("Sell " + str.tostring((tvToOverrideSymbol ? tvToSymbol : syminfo.ticker)) + " Q=" + str.tostring(tvToQPerc) + "% P=" + str.tostring(high) + " TP=" + str.tostring(high-stopMultiplier*atrAveraged)+ " SL=" + str.tostring(high+stopMultiplier*atrAveraged), freq=alert.freq_once_per_bar)
    if (not useReverse) and (not na(atrAveraged))
        strategy.entry("long", strategy.long, stop=high)
        alert("Buy " + str.tostring((tvToOverrideSymbol ? tvToSymbol : syminfo.ticker)) + " Q=" + str.tostring(tvToQPerc) + "% P=" + str.tostring(high) + " TP=" + str.tostring(high+stopMultiplier*atrAveraged) + " SL=" + str.tostring(high+stopMultiplier*atrAveraged), freq=alert.freq_once_per_bar)
    isLongCondition := true
    isBullTrend := false
    longLine := high

if isBearTrend[1] and close>equilibrium
    if useReverse and (not na(atrAveraged))
        strategy.entry("long", strategy.long, limit=low)
        alert("Buy " + str.tostring((tvToOverrideSymbol ? tvToSymbol : syminfo.ticker)) + " Q=" + str.tostring(tvToQPerc) + "% P=" + str.tostring(low) + " TP=" + str.tostring(low+stopMultiplier*atrAveraged) + " SL=" + str.tostring(low-stopMultiplier*atrAveraged), freq=alert.freq_once_per_bar)
    if (not useReverse) and (not na(atrAveraged))
        strategy.entry("short", strategy.short, stop=low)
        alert("Sell " + str.tostring((tvToOverrideSymbol ? tvToSymbol : syminfo.ticker)) + " Q=" + str.tostring(tvToQPerc) + "% P=" + str.tostring(low) + " TP=" + str.tostring(low-stopMultiplier*atrAveraged) + " SL=" + str.tostring(low+stopMultiplier*atrAveraged), freq=alert.freq_once_per_bar)
    isShortCondition := true
    isBearTrend := false
    shortLine := low

if isLongCondition and (bearCandleCount >= maxPullbackCandles)[1]
    if useReverse
        strategy.cancel("short")
        alert("Cancel " + str.tostring((tvToOverrideSymbol ? tvToSymbol : syminfo.ticker)) + " t=sell")
    if not useReverse
        strategy.cancel("long")
        alert("Cancel " + str.tostring((tvToOverrideSymbol ? tvToSymbol : syminfo.ticker)) + " t=buy")
    isLongCondition := false
    bullCandleCount := 0
    longLine := na

if isShortCondition and (bullCandleCount >= maxPullbackCandles)[1]
    if useReverse
        strategy.cancel("long")
        alert("Cancel " + str.tostring((tvToOverrideSymbol ? tvToSymbol : syminfo.ticker)) + " t=buy")
    if not useReverse
        strategy.cancel("short")
        alert("Cancel " + str.tostring((tvToOverrideSymbol ? tvToSymbol : syminfo.ticker)) + " t=sell")
    isShortCondition := false
    bearCandleCount := 0
    shortLine := na
    
// ---- Save for graphical display that there is a longcondition + reset other variables
if high>longLine
    longSignal := true
    longLine := na
    isLongCondition := false

if low<shortLine
    shortSignal := true
    shortLine := na
    isShortCondition := false
// ---- Get Stop loss and Take Profit in there
if useReverse
    if useTPSL
        if strategy.position_size < 0 and strategy.position_size[1] >= 0
            strategy.exit("short exit", "short", limit=longLine[1]-stopMultiplier*atrAveraged, stop=longLine[1]+stopMultiplier*atrAveraged)
        if strategy.position_size > 0 and strategy.position_size[1] <= 0
            strategy.exit("long exit", "long", limit=shortLine[1]+stopMultiplier*atrAveraged, stop=shortLine[1]-stopMultiplier*atrAveraged)
if not useReverse
    if useTPSL
        if strategy.position_size > 0 and strategy.position_size[1] <= 0
            strategy.exit("long exit", "long", limit=longLine[1]+stopMultiplier*atrAveraged, stop=longLine[1]-stopMultiplier*atrAveraged)
        if strategy.position_size < 0 and strategy.position_size[1] >=0
            strategy.exit("short exit", "short", limit=shortLine[1]-stopMultiplier*atrAveraged, stop=shortLine[1]+stopMultiplier*atrAveraged)
// ----- Logic for closing positions on a big candle in either direction
if (strategy.position_size[1]>0 or strategy.position_size[1]<0) and useBigCandleExit
    if close>equilibriumTop or close<equilibriumBottom
        strategy.close_all("Big Candle Stop")
        alert("close " + str.tostring((tvToOverrideSymbol ? tvToSymbol : syminfo.ticker)))

// ================================== //
// ------> Graphical Display <------- //
// ================================== //

// Deviation from equilibrium using smoothed ATR and percentile nearest rank to rank the coloring of the candles
candle_c2 = close>equilibrium ? close>open ? candle_bull_c1 : candle_bull_c2 : close<open ? candle_bear_c1 : candle_bear_c2
// 
plotcandle(equilibrium, high, low, close, title="Equilibrium Candles", color=candle_c2, wickcolor=candle_c2, bordercolor=candle_c2)
plotshape(highlightClosePrices ? close : na, title="Closing Bubble", style=shape.circle, location=location.absolute, color=color.yellow)
bgcolor(useBgColoring ? (isBullTrend ? trend_bull_c : isBearTrend ? trend_bear_c : isLongCondition ? long_zone_c : isShortCondition ? short_zone_c : na) : na, force_overlay=true)
plot(longLine, color=candle_bull_c1, title="Long Line", style=plot.style_linebr, linewidth=4)
plot(shortLine, color=candle_bear_c1, title="Short Line", style=plot.style_linebr, linewidth=4)
plotshape(longSignal ? math.min(equilibrium, low)+(-0.5*atrAveraged) : na, title="Long Signal", color=candle_bull_c1, style=shape.diamond, size=size.tiny, location=location.absolute)
plotshape(shortSignal ? math.max(equilibrium, high)+(0.5*atrAveraged) : na, title="Short Signal", color=candle_bear_c1, style=shape.diamond, size=size.tiny, location=location.absolute)

// =================================== //
// ------> Simple Form Alerts <------- //
// =================================== //

alertcondition(longSignal, "Simple Long Signal")
alertcondition(shortSignal, "Simple Short Signal")
````
