# Strategy: Range Breakout

- url: https://www.tradingview.com/script/pEf6ohWk-Strategy-Range-Breakout/
- type: strategy
- pine_id: PUB;667c65719bc9470689b6d58fece166d7
- version: 2.0

## Description

[b]What?[/b]

In the price action, levels have a significant role to play. Based on the price moving above/below the levels - the underlying instrument shows some price-action in the direction of breakout/breakdown.

There are plenty of ways level can be determined. Levels are the decision point to take a trade or not. [i]But[/i] if we make the level derivation complex, then the execution may get hamper. 

This strategy script, developed in PineScript v5, is our attempt at solving this problem at the core by providing this simple, yet elegant solution to this problem.

It's essentially an attempt to [b]Trade Simple[/b] by drawing logical (horizontal) lines in the chart and take actions, after multiple associated parameters confirmation, on the [i]breakout[/i] / [i]breakdown[/i] of the levels.



[b]How?[/b]

Let us explain how we are drawing the levels. 

We are depending on some of the parameters as described below:

[list]
[*] [b]Open Range[/b]: During intraday movement, often if prices move beyond a particular level, it exibits more movement in the same swing in same direction. We found out, through our back testing for Indian Indices like [symbol="NSE:NIFTY"]NSE:NIFTY[/symbol], [symbol="NSE:BANKNIFTY"]NSE:BANKNIFTY[/symbol] or [symbol="NSE:CNXFINANCE"]NSE:CNXFINANCE[/symbol] the first 15m (i.e 09:15 AM to 09:30 AM, IST) is one of such range. For Indian stocks, it is 9:15 to 9:45. And for MCX [symbol="MCX:CRUDEOIL1!"]MCX:CRUDEOIL1![/symbol] it's 5:00 pm to 6:00 pm. There are our first levels.
[*] [b]PDHCL[/b]: Previous Day High, Close, Low. This is our next level
[*] [b]VWAP[/b]: The rolling VWAP (volume weighted average price)
[/list]

In the breakout/breakdown of the Open Range and Previous Day High/Low, we are taking the trade decisions as follows using [i]CEST[/i] principle:

[b][i]C[/i]onditions[/b]: 
[*] If current bar's (say you are in 5m timeframe) closing is broken out the Open Range High or Previous Day High, taken a Buy/Long decision (let's say buying a Call Option CE or selling a Put Option PE or buying the future or cash).
[*] If current bar's (say you are in 5m timeframe) closing is broken down the Open Range Low or Previous Day Low, taken a Sell/Short decision (let's say buying a Put Option CE or selling a Call Option PE or selling the future or cash).
[*] Additionally, and optionally (default ON, one can turn off): we are checking various other associated multiple confirmations as follows:
         1. [b]Momentum[/b]: Checking 14-period RSI value is more than 50 or less than 50 (all parameters like period, OB, OS ranges are configurable through settings)
         2. Current bar's volume is more than the last 20 bars volume average. How much more - that multiplier is also configurable. (default is 1)
         3. The breakout candle is bullish (green) or bearish (red).

[b][i]E[/i]ntry[/b]: 
[*] All of these happens [i]only on the closing of the candle[/i]. Means: [i]Non Repainting![/i]. 
[*] Clearly in the chart we are showing as green up arrow BO (breakout for buy) and red down arrow BD (breakdown for sell) to take your decision process smooth.
[*] So, on the closing of the decision BO/BD candle we are entering the trade (with a thumping heart and nail biting ...)

[b][i]S[/i]top Loss[/b]: 
[*] We are relying on the time tasted (last 40 years) mechanism of Average True Range (ATR) of default 14 period. This default period is also configurable. 
[*] So for Long trades: the 14 period ATR low band is the SL.
[*] For Short trades: the 14 period ATR high band is the SL.

[b][i]T[/i]arget[/b]: 
[*] We are depending on the thump rule of 1:2 Risk Reward. It's simple and effective. No fancy thing. We are closing the trade on double the favorable price movement compared to the SL placed. Of course, this RR ratio is confiurable from the settings, as usual.

 

[b]What's Unqiue in it?[/b]

The [b]utter simplicity[/b] of this trading mechanism. No fancy things like complex chart pattern, OI data, multiple candlestick patterns, Order flow analysis etc. 

[*] Simple level determination, 
[*] Marking clearly in the chart.
[*] Making each parameter configurable in Settings and showing tooltip adjacent to the parameter to make you understand it better for your customization,
[*] Wait for the candle close, thus eliminating the chances of repainting menace (as much as possible)
[*] Additional momentum and volume check to trade entry confirmation.
[*] Works with normal candlestick (nothing special ones like HA ...)
[*] Showing everything as a [i]Summary Table[/i] (which, again can be turned off optionally) overlaying at the bottom-right corner of the chart,
[*] Optionally the Summary Table can be configured to alert you back (say you get it notified in your email or SMS).

That way, a single, simple, effective trade setup will ease your journey as smooth sail as possible. 


[b]Mentions[/b]
[*] There are plenty of friends from whom time to time we borrowed some of the ideas while working closely together over last one year. 
[*] From tradingview community, we took the spirit of @zzzcrypto123 awesome work done long back (in 2020) as the indicator "ORB - Opening Range Breakout". (We tried to reach him for his explicit consent, unable to catch hold of him).
[*] Some other publicly available materials we have consulted to get the additional checks (like RSI, volume).


[b]Lat word[/b]

Use it please and thank you for your constant patronage in following us in this awesome platform. Let's keep growing together. 


[i]Disclaimer[/i]:

This piece of software does not come up with any warrantee or any rights of not changing it over the future course of time.
We are not responsible for any trading/investment decision you are taking out of the outcome of this indicator.

## Source Code

````pine
// @version=5
// Open-Range-Breakout strategy
// No license. Free and Open Source.    

strategy('Strategy: ORB', shorttitle="ORB", overlay=true , currency=currency.NONE, initial_capital=100000)

// Inputs
period = input.int(defval=15, title="TimeRange", tooltip="The range in minutes (default: 15m)")
sessionInput = input.session(defval="0915-0930", title="Time Range", group="ORB settings", tooltip='What is the timeperiod (default 9:15AM to 9:30AM, exchange timezone')
hide = input.bool(defval = false, title="Hide ORB Range", group="ORB setting", tooltip = 'Hide the ORB range drawing')

// SL Related
slAtrLen = input.int(defval=14, title="ATR Period for placing SL", group="StopLoss settings")
showSLLines = input.bool(defval=false, title="Show SL lines in chart", tooltip="Show SL lines also as dotted lines in chart. Note: chart may look untidy.", group="StopLoss settings")

// Further Filtering
ignoreMementumVolume = input.bool(defval=false, title="Ignore Momentum & Volume", tooltip="Ignore Momentum & Volume to find out trades", group="Strengh Settings")
rsiLen = input.int(defval=14, title="Momentum Period", group="Strengh Settings", tooltip = 'To determine the momentum, RSI period is set default to 100')
rsiBullish = input.int(defval=50, step=1, title="Bullish Momentum", group="Strengh Settings", tooltip = 'Bullish Momentum, default set to RSI as 50')
rsiBearish = input.int(defval=50, step=1, title="Bearish Momentum", group="Strengh Settings", tooltip = 'Bearish Momentum, default set to RSI as 50')
volAvg = input.int(defval=20, step=1, title="Volume Average Period", group="Strengh Settings", tooltip = 'To calculate average volume, how many historical bars are considered. Default: 20.')
volThreshold = input.float(defval=1, step=0.1, title="Volume Strengh", group="Strengh Settings", tooltip = 'Multiplier: How big the current bar volume compared to average of last 20')

trendPeriod = input.int(defval=200, step=1, title="Trend Period", group="Trend Settings", tooltip = 'To calculate trend, what period is considered. Default: 200.')
hideTrend = input.bool(defval = false, title="Hide the trend line", group="Trend Settings", tooltip = 'Hide the trend')

hidePDHCL = input.bool(defval = false, title="Hide the PDHCL (prev day High Close Low range) & VWAP", tooltip = 'Hide the Previous Day High, Close, Low lines, including VWAP')

hideTable = input.bool(defval = false, title="Hide the Summary Table", tooltip = 'Hide the summary table.')

// Trade related
rrRatio = input.float(title='Risk:Reward', step=0.1, defval=2.0, group="Trade settings")
endOfDay = input.int(defval=1500, title="Close all trades, default is 3:00 PM, 1500 hours (integer)", group="Trade settings")
mktAlwaysOn = input.bool(defval=true, title="Markets that never closed (Crypto, Forex, Commodity)", tooltip="Some markers never closes. For those cases, make this checked.", group="Trade settings")
lotSize = input.int(title='Lot Size', step=1, defval=1, group="Trade settings")

// Util method

is_newbar(res) => 
	timeframe.change(time(res)) != 0


annotatePlots(txt, val, hide) => 
    if (not hide)
        var l1 = label.new(bar_index, hidePDHCL ? na : val, txt, style=label.style_label_left, size = size.tiny, textcolor = color.white, tooltip = txt)
        label.set_xy(l1, bar_index, hidePDHCL ? na : val)

// print table
printTable(txt) =>
    var table t = table.new(position.bottom_right, 1, 1)
    table.cell(t, 0, 0, txt, text_halign = text.align_left, bgcolor = color.lime)
	
// globals
t = time(timeframe.period, sessionInput + ":1234567") // everyday
in_session = not na(t)
is_first = in_session and not in_session[1]
is_end_session = in_session[1] and not in_session
green(open, close) => close > open ? true : false
red(open, close) => close < open ? true : false

var float orb_high = na
var float orb_low = na
if is_first
    orb_high := high
    orb_low := low
else
    orb_high := orb_high[1]
    orb_low := orb_low[1]
if high > orb_high and in_session
    orb_high := high
if low < orb_low and in_session
    orb_low := low

plot(hide ? na : orb_high, style=plot.style_line, color=orb_high[1] != orb_high ? na : color.green, title="ORB High", linewidth=2)
annotatePlots('ORB-H', orb_high, hide)
plot(hide ? na : orb_low, style=plot.style_line, color=orb_low[1] != orb_low ? na : color.red, title="ORB Low", linewidth=2)
annotatePlots('ORB-L', orb_low, hide)


// PDHCL (Previous Day High Close Low)
[dh,dl,dc] = request.security(syminfo.ticker, "D", [high[1],low[1], close[1]], lookahead=barmerge.lookahead_on)
plot(hidePDHCL ? na : dh, title="Prev High",  color=color.red,  linewidth=2, trackprice=true, show_last = 1)
annotatePlots('PDH', dh, hidePDHCL)
plot(hidePDHCL ? na : dl, title="Prev Low",  color=color.green,  linewidth=2, trackprice=true, show_last = 1)
annotatePlots('PDL', dl, hidePDHCL)
plot(hidePDHCL ? na : dc, title="Prev Close",  color=color.black,  linewidth=2, trackprice=true, show_last = 1)
annotatePlots('PDC', dc, hidePDHCL)
plot(hidePDHCL ? na : ta.vwap(close), title="VWAP",  color=color.fuchsia,  linewidth=2, trackprice=true, show_last = 1)
annotatePlots('VWAP', ta.vwap(close), hidePDHCL)


// For SL calculation
atr = ta.atr(slAtrLen)	
highestHigh = ta.highest(high, 7)
lowestLow = ta.lowest(low, 7)
longStop = showSLLines ? lowestLow - (atr * 1) : na
shortStop = showSLLines ? highestHigh + (atr * 1) : na
plot(longStop, title="Buy SL", color=color.green, style=plot.style_cross)
plot(shortStop, title="Sell SL", color=color.red, style=plot.style_cross)
annotatePlots('SL-Long', longStop, showSLLines)
annotatePlots('SL-Short', shortStop, showSLLines)

// Momentum: rsi
rsi = ta.rsi(close, rsiLen)

// trend: EMA200
ema = ta.ema(close, trendPeriod)
plot(hideTrend ? na : ema, "EMA Trend", color=close > ema ? color.green : color.red, linewidth = 1)
annotatePlots('Trendline', ema, hideTrend)

// Volume-Weighed Moving Average calculation
vwmaAvg = ta.vwma(close, volAvg)
vwma_latest = volume
// plotshape((barstate.isconfirmed and (vwma_latest > (vwmaAvg * volThreshold))), title='VolumeData', text='', location=location.abovebar, style=shape.diamond, color=color.gray, textcolor=color.gray, size=size.tiny)

// Trade signals

longCond = barstate.isconfirmed and (ta.crossover(close, orb_high) or ta.crossover(close, dh)) and green(open, close) and (ignoreMementumVolume ? true : rsi > rsiBullish and (vwma_latest > (vwmaAvg * volThreshold)))
shortCond = barstate.isconfirmed and (ta.crossunder(close, orb_low) or ta.crossunder(close, dl)) and red(open, close) and (ignoreMementumVolume ? true : rsi < rsiBearish and (vwma_latest > (vwmaAvg * volThreshold)))

plotshape(longCond, title='Breakout', text='BO', location=location.belowbar, style=shape.triangleup, color=color.green, textcolor=color.green)
plotshape(shortCond, title='Breakout', text='BD', location=location.abovebar, style=shape.triangledown, color=color.red, textcolor=color.red)


// Trade execute
h = hour(time('1'), syminfo.timezone)
m = minute(time('1'), syminfo.timezone)
hourVal = h * 100 + m
totalTrades = strategy.opentrades + strategy.closedtrades
if (mktAlwaysOn or (hourVal < endOfDay))
    // Entry
    var float sl = na
    var float target = na
    if (longCond)
        strategy.entry("enter long", strategy.long, lotSize, limit=na, stop=na, comment="Enter Long")
        sl := longStop
        target := close + ((close - longStop) * rrRatio)
        alert('Buy:' + syminfo.ticker + ' ,SL:' + str.tostring(math.floor(sl)) + ', Target:' + str.tostring(target), alert.freq_once_per_bar)
    if (shortCond)
        strategy.entry("enter short", strategy.short, lotSize, limit=na, stop=na, comment="Enter Short")
        sl := shortStop
        target := close - ((shortStop - close) * rrRatio)
        alert('Sell:' + syminfo.ticker + ' ,SL:' + str.tostring(math.floor(sl)) + ', Target:' + str.tostring(target), alert.freq_once_per_bar)

    // Exit: target or SL
    if ((close >= target) or (close <= sl))
        strategy.close("enter long", comment=close < sl ? "Long SL hit" : "Long target hit")
    if ((close <= target) or (close >= sl))
        strategy.close("enter short", comment=close > sl ? "Short SL hit" : "Short target hit")
else if (not mktAlwaysOn)
    // Close all open position at the end if Day
    strategy.close_all(comment = "Close all entries at end of day.")


// Plotting table
if (not hideTable and is_end_session)
    message =  syminfo.ticker + " :\n\nORB Upper: " + str.tostring(math.round(orb_high)) + "\nORB Lower: " + str.tostring(math.round(orb_low)) + "\nPDH: " + str.tostring(math.round(dh)) + "\nPDC: " + str.tostring(math.round(dc)) + "\nPDL: " + str.tostring(math.round(dl)) + "\nVWAP: " + str.tostring(math.round(ta.vwap(close)))   
    printTable(message)
    alert(message, alert.freq_once_per_bar_close)
````
