<!-- tradingview-pine-id: PUB;56816eee0d9c436bbfe1ad4e20404c68 -->
<!-- tradingviewscripts-format: 1 -->
# Trend Range Detector (Zeiierman)

Source: https://www.tradingview.com/script/WC3DYn1W-Trend-Range-Detector-Zeiierman/

## Description

█ Overview
Trend Range Detector (Zeiierman) is a market structure tool that identifies and tracks periods of price compression by forming adaptive range boxes based on volatility and price movement. When prices remain stable within a defined band, the script dynamically draws a range box; when prices break out of that structure, the box highlights the breakout in real-time.
[image]https://www.tradingview.com/x/eEMETZC9/[/image]

By combining a volatility-based envelope with a custom weighted centerline, this tool filters out noise and isolates truly stable zones — providing a clean framework for traders who focus on accumulation, distribution, breakout anticipation, and reversion opportunities.

Whether you're range trading, spotting trend consolidations, or looking for volatility contractions before major moves, the Trend Range Detector gives you a mathematically adaptive, visually intuitive structure that maps the heartbeat of the market.
[image]https://www.tradingview.com/x/7Zk0kIsH/[/image]

█ How It Works
⚪ Range Formation Engine
The core of this indicator revolves around two conditions:

[*]Distance Filter: The maximum distance between all recent closes and a dynamic centerline must remain within a volatility envelope.
[*]Volatility Envelope: Based on an ATR(2000) multiplied by a user-defined factor to account for broader market volatility trends.

If both conditions are satisfied over the most recent length bars, a range box is drawn to visually anchor the zone.

⚪ Dynamic Breakout Coloring
When price breaks out of the top or bottom of the active range box, the box color shifts in real-time:

[*]Blue Boxes represent areas where price has remained within a defined volatility envelope over a sustained number of bars. These zones reflect stable, low-volatility periods, often associated with consolidation, equilibrium, or market indecision.
[*]Green Boxes for bullish breakouts.
[*]Red Boxes for bearish breakdowns.

This allows traders to visually spot transitions from consolidation to expansion phases without relying on lagging signals.
█ Why Use a Weighted Close Instead of SMA?

A standard Simple Moving Average (SMA) treats all past closes equally, which works well in theory, but not in dynamic, fast-shifting markets. In this script, we replace the traditional SMA with a speed-weighted average that reflects how aggressively the market has moved bar-to-bar.

⚪ Here's why it matters:

[*]Bars with higher momentum (larger price differences between closes) are given more weight.
[*]Slow, sideways candles (typical in noise or low volume) contribute less to the calculated centerline.

This method creates a more accurate snapshot of market behavior, especially during volatile phases. As a result, the indicator adapts to market conditions more effectively, helping traders identify real consolidation zones, not just average lines distorted by flat bars or noise.

█ How to Use

⚪ Range Detection

[*]Boxes form only when price remains consistently close to the speed-weighted mean.
[*]Helps identify sideways zones, consolidations, and low-volatility structures where price is “charging up.”

[image]https://www.tradingview.com/x/t4C7809Q/[/image]

⚪ Breakout Confirmation

[*]Once price exits the top or bottom boundary, the box immediately highlights the direction of the break.
[*]Use this signal in conjunction with your own momentum, volume, or trend filters for higher-confidence trades.

[image]https://www.tradingview.com/x/H5UlDuL6/[/image]

█ Settings

[*]Minimum Range Length: Number of candles required for a valid range to form.
[*]Range Width Multiplier: Adjusts the envelope around the weighted average using ATR(2000).
[*]Highlight Box Breaks: Enables real-time coloring of breakouts and breakdowns for immediate visual feedback.

-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator("Trend Range Detector (Zeiierman)", overlay=true, max_boxes_count = 500, max_lines_count = 500)
//~~}

// ~~ Tooltips {
var string t1 = "The minimum number of bars required to qualify a range box. A higher value ensures the range is well-established, but may reduce responsiveness."
var string t2 = "Multiplier that adjusts the vertical size of the range box based on ATR. Larger values create wider boxes and accommodate higher volatility."
var string t3 = "Enable this to highlight boxes that are actively being broken. Green means a breakout above the box; red indicates a breakdown below."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
length   = input.int(50, minval=1, step=1, title="Minimum Range Length", tooltip = t1)
mult     = input.float(2.0, minval=0.1, step = 0.1, title="Range Width Multiplier", tooltip = t2)
highlightBreak = input.bool(true, "Highlight Box Breaks", tooltip = t3)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Calculations {
atr = ta.atr(2000) * mult

sumWeightedClose = 0.0
sumWeights       = 0.0
for i = 0 to length - 1
    delta = math.abs(close[i] - close[i+1])
    w     = delta / close[i+1]
    sumWeightedClose := sumWeightedClose + close[i] * w
    sumWeights  := sumWeights + w
ma = sumWeights != 0 ? sumWeightedClose / sumWeights : na

distances = array.new_float()
for i = 0 to length - 1
    distances.push(math.abs(close[i] - ma))
maxDist = distances.max()
inRange = maxDist <= atr
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Box {
b = bar_index
var line boxMidLine = na
var line boxTopLine = na
var line boxBotLine = na
var box rectBox = na
var color boxColor = color.rgb(33, 87, 243, 90)

newBox    = inRange and not inRange[1]
extendBox = inRange and not newBox

if newBox
    if rectBox.get_right()<(b-length) or na(rectBox)
        rectBox := box.new(b - length, ma + atr, b, ma - atr, border_color=color.new(boxColor, 0), bgcolor=color.new(boxColor, 85))

        boxMidLine := line.new(b - length, math.avg(ma+atr,ma-atr), b, math.avg(ma+atr,ma-atr), color=color.new(boxColor, 50), style=line.style_dotted)
        boxTopLine := line.new(b - length, ma+atr, b, ma+atr, color=color.new(boxColor, 50))
        boxBotLine := line.new(b - length, ma-atr, b, ma-atr, color=color.new(boxColor, 50))

if extendBox
    boxMidLine.set_x2(b)
    boxTopLine.set_x2(b)
    boxBotLine.set_x2(b)

if highlightBreak
    breakUp = close > rectBox.get_top() 
    breakDn = close < rectBox.get_bottom() 
    boxColor := breakUp ? color.rgb(8,153,119, 90) : breakDn ? color.rgb(242,54,69,90) : color.rgb(33, 87, 243, 90)

    if not na(rectBox)
        rectBox.set_bgcolor(boxColor)
        rectBox.set_border_color(color.new(boxColor, 0))

        boxMidLine.set_color(color.new(boxColor, 0))
        boxTopLine.set_color(color.new(boxColor, 0))
        boxBotLine.set_color(color.new(boxColor, 0))
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
