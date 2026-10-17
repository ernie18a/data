# ES Breakout Toolkit Breakout Candle Scanner Free

- url: https://www.tradingview.com/script/dQoagvwL-ES-Breakout-Toolkit-Breakout-Candle-Scanner-Free/
- type: indicator
- pine_id: PUB;91d39039fd964cad9b1b22b9906ba326
- version: 1.0

## Description

=== PART OF THE ES BREAKOUT TOOLKIT ===
This is one of several free, standalone indicators that make up the ES Breakout Toolkit series. Each indicator isolates a single component used in the full ES London Breakout Pro strategy. They are designed to be useful on their own and educational for traders studying what makes a quality breakout candle.

=== WHAT THIS INDICATOR DOES ===
The Breakout Candle Scanner identifies candles that meet specific structural criteria for a high-quality breakout. Not every candle that crosses a level is worth trading — this indicator filters for candles with strong body-to-range ratios, directionally committed close positions, and confirmed breaks above or below a recent range.

When a candle breaks out of a defined range AND meets the body ratio and momentum close thresholds, it is marked with a BUY or SELL label. A detail label shows the exact body percentage and close position so you can see why it qualified. An optional mode also marks strong candles that did not produce a breakout, which can be useful for studying candle quality across different market conditions.

=== HOW TO USE IT ===
Apply this to an ES futures chart on a 5-minute timeframe. The indicator will scan every candle and mark those that qualify as breakout candles. You can adjust the body ratio threshold, close position thresholds, breakout buffer, and range lookback in the inputs.

Body Ratio measures how much of the candle's total range is real body vs wicks. Higher values mean more conviction. Close Position measures where price closed within the candle's range — a bullish candle closing near its high (70%+) or a bearish candle closing near its low (30% or below) indicates strong momentum commitment.

The dashboard tracks total bullish and bearish breakout candles as well as strong non-breakout candles, giving you a running count of candle quality during the session.

=== KEY FEATURES ===
- Breakout candle detection with body ratio and close position filters
- Configurable thresholds for all candle quality metrics
- ATR-based breakout buffer to filter false breaks
- Detail labels showing exact body% and close position% on each signal
- Optional mode to mark all strong candles (not just breakouts)
- Optional bar coloring for qualifying candles
- Optional London session filter
- Running stats dashboard
- Alerts for bullish and bearish breakout candles

=== ABOUT THE ES BREAKOUT TOOLKIT ===
This indicator is part of a free series that breaks down the building blocks of a London session ES futures breakout strategy. Other free indicators in the series cover session highlighting, consolidation range detection, ADX regime filtering, and momentum close analysis. Each is published separately on my profile.

The full ES London Breakout Pro indicator combines all of these components into a unified strategy with additional proprietary features including advanced risk management, trade qualification, and data tracking. It is available as an invite-only script on my profile. Use the access request instructions on that script's page if you are interested.

=== DISCLAIMER ===
This indicator is provided for educational and informational purposes only. It is NOT financial advice. It does not constitute a recommendation to buy, sell, or hold any financial instrument. Trading futures involves substantial risk of loss and is not suitable for all investors. Past performance of any indicator or strategy is not indicative of future results. Always conduct your own research and consult a qualified financial advisor before making any trading decisions. You are solely responsible for your own trading activity.

## Source Code

````pine
//@version=6
indicator("[ES Breakout Toolkit] Breakout Candle Scanner — Free", overlay=true)

// ==================== INPUTS ====================
bodyRatio = input.float(0.48, "Min Body Ratio (body/range)", minval=0.2, step=0.05)
bullClosePosition = input.float(0.70, "Bullish Close Position Min", minval=0.5, step=0.05)
bearClosePosition = input.float(0.30, "Bearish Close Position Max", minval=0.05, step=0.05)
atrBreakoutBuffer = input.float(0.04, "Breakout Buffer (x ATR)", minval=0.01, step=0.01)
rangeBars = input.int(10, "Range Lookback (bars)", minval=3, maxval=50)
showAllStrong = input.bool(false, "Show All Strong Candles (not just breakouts)")
showBarColor = input.bool(true, "Color Qualifying Candles")
sessionFilterOn = input.bool(false, "Limit to London Session (12AM-6AM PT)")

// ==================== INDICATORS ====================
atr = ta.atr(20)

// ==================== SESSION ====================
ptHour = hour(time, "America/Los_Angeles")
inSession = not sessionFilterOn or (ptHour >= 0 and ptHour < 6)

// ==================== RANGE LEVELS ====================
rangeHigh = ta.highest(high, rangeBars)
rangeLow = ta.lowest(low, rangeBars)

// ==================== CANDLE ANALYSIS ====================
bodySize = math.abs(close - open)
candleRange = high - low
bodyRatioCalc = candleRange > 0 ? bodySize / candleRange : 0
closePos = candleRange > 0 ? (close - low) / candleRange : 0.5

isBullish = close > open
isBearish = close < open
strongBody = bodyRatioCalc >= bodyRatio
strongBullMomentum = closePos >= bullClosePosition
strongBearMomentum = closePos <= bearClosePosition

// ==================== BREAKOUT DETECTION ====================
breakoutUp = close > rangeHigh[1] + atr * atrBreakoutBuffer and close[1] <= rangeHigh[1]
breakoutDown = close < rangeLow[1] - atr * atrBreakoutBuffer and close[1] >= rangeLow[1]

bullBreakoutCandle = breakoutUp and isBullish and strongBody and strongBullMomentum and inSession
bearBreakoutCandle = breakoutDown and isBearish and strongBody and strongBearMomentum and inSession

strongBullCandle = isBullish and strongBody and strongBullMomentum and inSession and not bullBreakoutCandle
strongBearCandle = isBearish and strongBody and strongBearMomentum and inSession and not bearBreakoutCandle

// ==================== PLOTTING ====================
plotshape(bullBreakoutCandle, title="Bull Breakout Candle", style=shape.triangleup, location=location.belowbar, color=#00E676, size=size.normal, text="BULL BO")
plotshape(bearBreakoutCandle, title="Bear Breakout Candle", style=shape.triangledown, location=location.abovebar, color=#FF1744, size=size.normal, text="BEAR BO")

plotshape(showAllStrong and strongBullCandle, title="Strong Bull", style=shape.circle, location=location.belowbar, color=color.new(color.lime, 40), size=size.tiny)
plotshape(showAllStrong and strongBearCandle, title="Strong Bear", style=shape.circle, location=location.abovebar, color=color.new(color.red, 40), size=size.tiny)

// ==================== BAR COLORING ====================
barcolor(showBarColor and bullBreakoutCandle ? #00E676 : showBarColor and bearBreakoutCandle ? #FF1744 : showBarColor and showAllStrong and strongBullCandle ? color.new(color.lime, 50) : showBarColor and showAllStrong and strongBearCandle ? color.new(color.red, 50) : na)

// ==================== CANDLE DETAIL LABELS ====================
if bullBreakoutCandle
    detailTxt = "Body: " + str.tostring(bodyRatioCalc * 100, "#") + "%\nClose: " + str.tostring(closePos * 100, "#") + "%"
    label.new(bar_index, low, detailTxt, style=label.style_label_up, color=color.new(#00E676, 60), textcolor=color.white, size=size.tiny)

if bearBreakoutCandle
    detailTxt = "Body: " + str.tostring(bodyRatioCalc * 100, "#") + "%\nClose: " + str.tostring(closePos * 100, "#") + "%"
    label.new(bar_index, high, detailTxt, style=label.style_label_down, color=color.new(#FF1744, 60), textcolor=color.white, size=size.tiny)

// ==================== STATS TRACKING ====================
var int totalBullBO = 0
var int totalBearBO = 0
var int totalStrongBull = 0
var int totalStrongBear = 0

if bullBreakoutCandle
    totalBullBO := totalBullBO + 1
if bearBreakoutCandle
    totalBearBO := totalBearBO + 1
if strongBullCandle
    totalStrongBull := totalStrongBull + 1
if strongBearCandle
    totalStrongBear := totalStrongBear + 1

// ==================== DASHBOARD ====================
var table dash = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 10), border_width=1)
table.cell(dash, 0, 0, "Candle Scanner", text_color=color.white, text_size=size.small, bgcolor=color.new(color.teal, 30))
table.cell(dash, 1, 0, "Status", text_color=color.white, text_size=size.small, bgcolor=color.new(color.teal, 30))
table.cell(dash, 0, 1, "Current Body%", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 1, str.tostring(bodyRatioCalc * 100, "#.#") + "%", text_color=strongBody ? color.lime : color.gray, text_size=size.small)
table.cell(dash, 0, 2, "Close Position", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 2, str.tostring(closePos * 100, "#.#") + "%", text_color=closePos >= bullClosePosition ? color.lime : closePos <= bearClosePosition ? color.red : color.yellow, text_size=size.small)
table.cell(dash, 0, 3, "Direction", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 3, isBullish ? "BULLISH" : "BEARISH", text_color=isBullish ? color.lime : color.red, text_size=size.small)
table.cell(dash, 0, 4, "Bull Breakouts", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 4, str.tostring(totalBullBO), text_color=color.lime, text_size=size.small)
table.cell(dash, 0, 5, "Bear Breakouts", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 5, str.tostring(totalBearBO), text_color=color.red, text_size=size.small)
table.cell(dash, 0, 6, "Strong (non-BO)", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 6, str.tostring(totalStrongBull) + " / " + str.tostring(totalStrongBear), text_color=color.white, text_size=size.small)

// ==================== ALERTS ====================
alertcondition(bullBreakoutCandle, "Bullish Breakout Candle", "Strong bullish breakout candle detected")
alertcondition(bearBreakoutCandle, "Bearish Breakout Candle", "Strong bearish breakout candle detected")
````
