# ES Breakout Toolkit Momentum Close Filter Free

- url: https://www.tradingview.com/script/lfxfpdpx-ES-Breakout-Toolkit-Momentum-Close-Filter-Free/
- type: indicator
- pine_id: PUB;d409df6d5ca642379e850a7f6d39b81e
- version: 1.0

## Description

=== PART OF THE ES BREAKOUT TOOLKIT ===
This is one of several free, standalone indicators that make up the ES Breakout Toolkit series. Each indicator isolates a single component used in the full ES London Breakout Pro strategy. They are designed to be useful on their own and educational for traders who want to understand candle close dynamics and momentum quality.

=== WHAT THIS INDICATOR DOES ===
The Momentum Close Filter analyzes where price closes within each candle's range and classifies candles by momentum strength. A candle that closes near its high has strong bullish momentum. A candle that closes near its low has strong bearish momentum. A candle that closes in the middle is indecisive.

This concept — called close position analysis — is a powerful filter that many traders overlook. The indicator tracks close position in real time, identifies extreme momentum readings using a statistical threshold (1.5 standard deviations above/below average), and detects momentum streaks where multiple consecutive candles show strong directional commitment.

=== HOW TO USE IT ===
Apply this to an ES futures chart on a 5-minute timeframe. The indicator will color bars by their momentum classification and mark extreme momentum candles with diamond signals. Streak flags appear when three or more consecutive candles show strong momentum in the same direction.

The dashboard shows the current candle's close position percentage, body ratio, momentum classification, streak count, and the rolling average close position over your lookback period. The running stats at the bottom show how many strong bullish vs bearish candles have occurred, giving you a sense of the session's directional bias.

An optional histogram mode plots the close position as columns in a separate pane with your threshold lines and the rolling average overlaid. This is useful for studying close position distribution over time.

=== KEY FEATURES ===
- Real-time close position analysis for every candle
- Configurable bullish and bearish momentum thresholds
- Extreme momentum detection using standard deviation bands
- Momentum streak tracking with visual flags at 3+ consecutive candles
- Optional bar coloring by momentum classification
- Optional histogram pane with threshold and average lines
- Optional London session filter
- Dashboard with close position, body ratio, momentum state, and streak info
- Running session stats for strong bull vs bear candle counts
- Alerts for strong and extreme momentum candles in both directions

=== WHY CLOSE POSITION MATTERS ===
Two candles can have identical body sizes but very different close positions. A candle with a long upper wick closing in the middle of its range tells a different story than a candle closing at its high with no upper wick. Close position captures this nuance. When combined with a body ratio filter, it becomes a reliable measure of whether a candle represents genuine directional commitment or just noise.

=== ABOUT THE ES BREAKOUT TOOLKIT ===
This indicator is part of a free series that breaks down the building blocks of a London session ES futures breakout strategy. Other free indicators in the series cover session highlighting, consolidation range detection, ADX regime filtering, and breakout candle scanning. Each is published separately on my profile.

The full ES London Breakout Pro indicator combines all of these components into a unified strategy with additional proprietary features including advanced risk management, trade qualification, and data tracking. It is available as an invite-only script on my profile. Use the access request instructions on that script's page if you are interested.

=== DISCLAIMER ===
This indicator is provided for educational and informational purposes only. It is NOT financial advice. It does not constitute a recommendation to buy, sell, or hold any financial instrument. Trading futures involves substantial risk of loss and is not suitable for all investors. Past performance of any indicator or strategy is not indicative of future results. Always conduct your own research and consult a qualified financial advisor before making any trading decisions. You are solely responsible for your own trading activity.

## Source Code

````pine
//@version=6
indicator("[ES Breakout Toolkit] Momentum Close Filter — Free", overlay=true)

// ==================== INPUTS ====================
strongBullThreshold = input.float(0.70, "Strong Bull Threshold", minval=0.5, step=0.05)
strongBearThreshold = input.float(0.30, "Strong Bear Threshold", minval=0.05, step=0.05)
showBarColor = input.bool(true, "Color Bars by Close Position")
showSignals = input.bool(true, "Show Extreme Momentum Signals")
showHistogram = input.bool(false, "Show Histogram (use with separate pane)")
lookback = input.int(20, "Lookback for Avg Close Position", minval=5)
sessionFilterOn = input.bool(false, "Limit to London Session (12AM-6AM PT)")

// ==================== SESSION ====================
ptHour = hour(time, "America/Los_Angeles")
inSession = not sessionFilterOn or (ptHour >= 0 and ptHour < 6)

// ==================== CLOSE POSITION ANALYSIS ====================
candleRange = high - low
closePos = candleRange > 0 ? (close - low) / candleRange : 0.5
bodySize = math.abs(close - open)
bodyRatio = candleRange > 0 ? bodySize / candleRange : 0
isBullish = close > open

// ==================== CLASSIFICATION ====================
strongBull = closePos >= strongBullThreshold and isBullish and inSession
strongBear = closePos <= strongBearThreshold and not isBullish and inSession
neutral = not strongBull and not strongBear

// ==================== AVERAGES ====================
avgClosePos = ta.sma(closePos, lookback)
closePosStdev = ta.stdev(closePos, lookback)
extremeBull = closePos > avgClosePos + closePosStdev * 1.5 and isBullish
extremeBear = closePos < avgClosePos - closePosStdev * 1.5 and not isBullish

// ==================== STREAK TRACKING ====================
var int bullStreak = 0
var int bearStreak = 0

if strongBull
    bullStreak := bullStreak + 1
    bearStreak := 0
else if strongBear
    bearStreak := bearStreak + 1
    bullStreak := 0
else
    bullStreak := 0
    bearStreak := 0

// ==================== STATS ====================
var int totalStrongBull = 0
var int totalStrongBear = 0
var int totalNeutral = 0
var int totalExtremeBull = 0
var int totalExtremeBear = 0

if inSession
    if strongBull
        totalStrongBull := totalStrongBull + 1
    else if strongBear
        totalStrongBear := totalStrongBear + 1
    else
        totalNeutral := totalNeutral + 1
    if extremeBull
        totalExtremeBull := totalExtremeBull + 1
    if extremeBear
        totalExtremeBear := totalExtremeBear + 1

// ==================== BAR COLORING ====================
bullColor = closePos >= 0.85 ? #00E676 : closePos >= strongBullThreshold ? #66BB6A : na
bearColor = closePos <= 0.15 ? #FF1744 : closePos <= strongBearThreshold ? #EF5350 : na
neutralColor = color.new(color.gray, 50)

barcolor(showBarColor and strongBull ? bullColor : showBarColor and strongBear ? bearColor : na)

// ==================== SIGNALS ====================
plotshape(showSignals and extremeBull and inSession, title="Extreme Bull", style=shape.diamond, location=location.belowbar, color=#00E676, size=size.tiny, text="STRONG")
plotshape(showSignals and extremeBear and inSession, title="Extreme Bear", style=shape.diamond, location=location.abovebar, color=#FF1744, size=size.tiny, text="STRONG")

// ==================== STREAK MARKERS ====================
plotshape(bullStreak >= 3, title="Bull Streak 3+", style=shape.flag, location=location.belowbar, color=color.new(color.lime, 20), size=size.tiny)
plotshape(bearStreak >= 3, title="Bear Streak 3+", style=shape.flag, location=location.abovebar, color=color.new(color.red, 20), size=size.tiny)

// ==================== CLOSE POSITION LINE (optional pane) ====================
plot(showHistogram ? closePos : na, "Close Position", color=strongBull ? color.lime : strongBear ? color.red : color.gray, style=plot.style_columns)
plot(showHistogram ? strongBullThreshold : na, "Bull Threshold", color=color.new(color.lime, 70))
plot(showHistogram ? strongBearThreshold : na, "Bear Threshold", color=color.new(color.red, 70))
plot(showHistogram ? avgClosePos : na, "Avg Close Pos", color=color.new(color.white, 50), linewidth=1)

// ==================== DASHBOARD ====================
var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 10), border_width=1)
table.cell(dash, 0, 0, "Momentum Close", text_color=color.white, text_size=size.small, bgcolor=color.new(color.teal, 30))
table.cell(dash, 1, 0, "Filter", text_color=color.white, text_size=size.small, bgcolor=color.new(color.teal, 30))
table.cell(dash, 0, 1, "Close Position", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 1, str.tostring(closePos * 100, "#.#") + "%", text_color=strongBull ? color.lime : strongBear ? color.red : color.yellow, text_size=size.small)
table.cell(dash, 0, 2, "Body Ratio", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 2, str.tostring(bodyRatio * 100, "#.#") + "%", text_color=bodyRatio >= 0.48 ? color.lime : color.gray, text_size=size.small)
table.cell(dash, 0, 3, "Momentum", text_color=color.gray, text_size=size.small)
momTxt = strongBull ? "STRONG BULL" : strongBear ? "STRONG BEAR" : "NEUTRAL"
momCol = strongBull ? color.lime : strongBear ? color.red : color.gray
table.cell(dash, 1, 3, momTxt, text_color=momCol, text_size=size.small)
table.cell(dash, 0, 4, "Streak", text_color=color.gray, text_size=size.small)
streakTxt = bullStreak > 0 ? str.tostring(bullStreak) + " Bull" : bearStreak > 0 ? str.tostring(bearStreak) + " Bear" : "---"
table.cell(dash, 1, 4, streakTxt, text_color=bullStreak > 0 ? color.lime : bearStreak > 0 ? color.red : color.gray, text_size=size.small)
table.cell(dash, 0, 5, "Avg Close Pos", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 5, str.tostring(avgClosePos * 100, "#.#") + "%", text_color=color.white, text_size=size.small)
totalCandles = totalStrongBull + totalStrongBear + totalNeutral
table.cell(dash, 0, 6, "Strong Bull", text_color=color.gray, text_size=size.small)
bullPct = totalCandles > 0 ? (totalStrongBull / totalCandles) * 100 : 0
table.cell(dash, 1, 6, str.tostring(totalStrongBull) + " (" + str.tostring(bullPct, "#") + "%)", text_color=color.lime, text_size=size.small)
table.cell(dash, 0, 7, "Strong Bear", text_color=color.gray, text_size=size.small)
bearPct = totalCandles > 0 ? (totalStrongBear / totalCandles) * 100 : 0
table.cell(dash, 1, 7, str.tostring(totalStrongBear) + " (" + str.tostring(bearPct, "#") + "%)", text_color=color.red, text_size=size.small)

// ==================== ALERTS ====================
alertcondition(strongBull, "Strong Bull Momentum", "Candle closed with strong bullish momentum")
alertcondition(strongBear, "Strong Bear Momentum", "Candle closed with strong bearish momentum")
alertcondition(extremeBull, "Extreme Bull Momentum", "Candle closed with extreme bullish momentum")
alertcondition(extremeBear, "Extreme Bear Momentum", "Candle closed with extreme bearish momentum")
````
