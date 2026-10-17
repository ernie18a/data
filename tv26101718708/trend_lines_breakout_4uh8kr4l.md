# Trend lines Breakout

- url: https://www.tradingview.com/script/4uH8kr4l-Trend-lines-Breakout/
- type: indicator
- pine_id: PUB;af81cf47925248cc8ed9fc6b716580c1
- version: 1.0

## Description

Title :- [b]Trend Line Breakouts [/b]
               Overview The Trendline Breakouts indicator automates the tedious process of drawing support and resistance trendlines. By identifying key Pivot Highs and Lows, the script dynamically plots valid trendlines and actively monitors price action to detect and highlight breakouts in real-time. Whether you are a day trader looking for intraday momentum or a swing trader looking for structural shifts, this tool helps keep your charts clean while ensuring you never miss a critical trendline break.

[b]Core Features[/b]
•	Automated Trendlines: Dynamically connects consecutive Lower Highs for Resistance (Bearish trends) and Higher Lows for Support (Bullish trends).
•	Real-Time Breakout Detection: Automatically detects when the closing price breaks a previously established support or resistance line.
•	Smart Forward Projection: When a line is broken, the script doesn't just leave it hanging. If historical lines are toggled on, the broken trendline immediately turns into a dashed, faded line and projects exactly 5 bars into the future using the line's original slope. This allows you to visualize the exact breakout zone without cluttering the chart infinitely.
•	Visual Signals: Plots clean, unobtrusive triangle shapes on the chart the moment a breakout is confirmed (Blue for Bullish, Yellow for Bearish).
•	Real-Time Alerts System: Visually flags the exact candle where a structural breakout occurs, allowing for rapid decision-making.
•	Historical Line Management : When a line is broken, it can be:
•	Kept on chart with dashed style and faded color (if Show Broken Historical Lines is enabled) Deleted from chart (if disabled) Broken lines are extended 5 bars into the future for visual reference
•	
[b]How It Works :-[/b]
       The indicator uses TradingView's built-in ta.pivothigh and ta.pivotlow functions to locate structural swing points based on your defined lookback and look-forward periods.
Breakout Signals The script utilizes clean, unobtrusive chart shapes to signal confirmed breakouts exactly when the candle closes:

•	Bullish Breakout: A small Blue Triangle Up appears below the bar. This occurs when the price violently breaks above a downward-sloping Resistance trendline.

•	Bearish Breakout: A small Yellow Triangle Down appears above the bar. This occurs when the price drops below an upward-sloping Support trendline.

[b]Detection[/b]
The indicator's detection engine runs strictly on the closing price of the candle to prevent false signals from mid-candle wicks.
•	It mathematically calculates the real-time slope of the active trendline using line.get_price(bar_index).
•	If the close of the current candle crosses that exact price coordinate, the script instantly categorizes the line as "broken," triggers the visual signal, and initiates the 5-bar forward projection.

[b]Visual Signals[/b]
•	🔺 Blue Triangle (below bar): Bullish breakout (price broke resistance)
•	🔻 Yellow Triangle (above bar): Bearish breakout (price broke support)
•	Solid Lines: Active trend lines
•	Dashed Lines: Broken historical trend lines

[b]Settings & Customization[/b]
•	Pivot Left / Right Bars: Controls the sensitivity of the pivot points. Lower numbers will  map out micro-trends, while higher numbers will only plot major structural macro-trends.
•	Show Breakout: Toggle the visual triangle signals on or off.
•	Show Broken Historical Lines: If enabled, broken lines fade, turn dashed, and extend 5 bars forward to show the breakout area. If disabled, lines are instantly deleted upon breakout to keep the chart pristine.
•	Support / Resistance Tend Line Color: Fully customizable colors for both active trendlines and their faded historical counterparts.

[b]How to Use[/b]
1.	Adjust Pivot Periods: Increase for longer-term trends, decrease for shorter-term
2.	Identify the Trend: Let the indicator map out the current channel or wedge. Upward-sloping green lines act as Support, and downward-sloping red lines act as Resistance.
3.	Wait for the Break: Watch for the price action to squeeze toward the apex of the trendlines.
4.	Trade the Retest: When a line breaks and turns dashed, use the 5-bar extended projection as a visual guide for a potential "break-and-retest" entry. Often, old resistance acts as new support.

[b]Timeframe[/b]
This indicator is completely timeframe-agnostic. Because it calculates structure based on raw price action and pivots rather than fixed time periods, it performs equally well across the board:
•	Scalping/Day Trading: 3m, 5m, and 15m charts (consider lowering the Pivot settings slightly for faster signals).
•	Swing Trading: 1H, 4H, and Daily charts (keep default Pivot settings for strong macro structural lines).
Release Notes Built using Pine Script™ v6 utilizing advanced custom types, arrays, and methods for highly efficient line management.

[b]Disclaimer & Risk Management[/b]
•	Beware of False Breakouts: While this script accurately detects structural breaks based on closing prices, financial markets are inherently noisy. "Whipsaws" or false breakouts occur frequently, where the price breaks a trendline only to immediately reverse.
•	Educational Use Only: This script is published for educational and informational purposes only and does not constitute financial advice. Always backtest any new tool, use proper position sizing, and employ strict stop-losses to protect your capital. Past market structure is not a guaranteed predictor of future price action.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trend-My-Friend
//@version=6
indicator('Trend lines Breakout','TLineB_TMF', overlay = true, max_lines_count = 500)
pivotLeg = input.int(10, 'Pivot Left Bars',minval= 5,maxval=100)
rightBars = input.int(5, 'Pivot Right Bars',minval= 3,maxval=100)
showbrkout = input.bool(true, 'Show Breakout ', inline = 'brk')
showHistory = input.bool(true, 'Show Broken Historical Lines ?   ', inline = 'brk')
bullColor = input.color(#b4ecb6, 'Support TL Color', inline = 'col')
bearColor = input.color(#f7abab, 'Resistance TL Color', inline = 'col')

pHigh = ta.pivothigh(high, pivotLeg, rightBars)
pLow = ta.pivotlow(low, pivotLeg, rightBars)
// --- TYPES ---
type Pivot
	float value
	int loc
type lineArgs
	int x1
	int x2
	float y1
	float y2
	color lineColor
type signal
	bool valid
	lineArgs args
type lineItem
	line ln = na
	int x1 = 0
	bool active = true

// --- VARIABLES ---
var allPH = array.new<Pivot>()
var allPL = array.new<Pivot>()

var bullishLines = array.new<lineItem>()
var bearishLines = array.new<lineItem>()
// store pivot points 
if not na(pHigh)
    allPH.push(Pivot.new(pHigh, bar_index - rightBars))
if not na(pLow)
    allPL.push(Pivot.new(pLow, bar_index - rightBars))
//Line Draw function
drawLine(lineArgs args) =>
    line.new(args.x1, args.y1, args.x2, args.y2, color = args.lineColor, width = 1)

method checkTrend(array<Pivot> this, bool isBull, color lineColor) =>
    if this.size() < 2
        signal.new(false, na)
    else
        curr = this.last()
        prev = this.get(this.size() - 2)
        // Higher Low for Bullish, Lower High for Bearish
        valid = isBull ? curr.value > prev.value : curr.value < prev.value
        if valid
            signal.new(valid, lineArgs.new(prev.loc, curr.loc, prev.value, curr.value, lineColor))
        else
            signal.new(false, na)

processSignal(signal sig, array<lineItem> linesArr) =>
    if sig.valid
        if linesArr.size() == 0 or sig.args.x1 > linesArr.last().x1
            linesArr.push(lineItem.new(drawLine(sig.args), sig.args.x1, true))

updateLines(array<lineItem> linesArr, bool isBull) =>
    bool breakoutDetected = false
    if linesArr.size() > 0
        for item in linesArr
            if item.active
                price = item.ln.get_price(bar_index)
                // Support breaks when close <= price. Resistance breaks when close >= price.
                isBreak = isBull ? close <= price : close >= price
                if isBreak
                    if showHistory
                        // Calculate the projected price 5 bars into the future
                        tX = bar_index + 5
                        tY = item.ln.get_price(tX)
                        // Extend the line to the target 5 bars ahead
                        item.ln.set_x2(tX)
                        item.ln.set_y2(tY)
                        item.ln.set_style(line.style_dashed)
                        item.ln.set_color(isBull ? #92e9a17a : #faa3a37c) // Faded green or faded red
                        item.active := false
                        breakoutDetected := true
                    else
                        line.delete(item.ln)
                else
                    // Normal extension while active
                    item.ln.set_x2(bar_index)
                    item.ln.set_y2(price)
    breakoutDetected
// --- EXECUTION ---
// Process Trends
processSignal(allPL.checkTrend(true, bullColor), bullishLines)
processSignal(allPH.checkTrend(false, bearColor), bearishLines)
// Update Lines & Get Breakout Status
bullBreak = updateLines(bullishLines, true) // Support Broken (Bearish event)
bearBreak = updateLines(bearishLines, false) // Resistance Broken (Bullish event)
// --- PLOTTING ---
plotshape(bearBreak and showbrkout, title = 'Bullish Breakout', style = shape.triangleup, location = location.belowbar, color = color.blue, size = size.tiny)
plotshape(bullBreak and showbrkout, title = 'Bearish Breakout', style = shape.triangledown, location = location.abovebar, color = color.yellow, size = size.tiny)
// alerts
if bearBreak
    alert("Bullish Breakout",freq = alert.freq_once_per_bar_close)
if bullBreak
    alert("Bearish Breakout",freq = alert.freq_once_per_bar_close)
````
