# reversal candle

- url: https://www.tradingview.com/script/qY2zFBjV-reversal-candle/
- type: indicator
- pine_id: PUB;cf628a08693e49069df78a1271899aae
- version: 1.0

## Description

This indicator is a Technical Reversal Pattern Suite designed to identify specific candlestick formations that suggest a potential change in market direction. It combines trend filtering, volume analysis, and pattern recognition into a single tool.Here is a breakdown of how it works:1. Trend Filter (9 SMA)The indicator uses a 9-period Simple Moving Average (SMA) as the "filter" for the entire system.Why? Reversal patterns are highly contextual. A pattern that looks like a reversal in a downtrend is actually a "continuation" pattern if the overall trend is strongly upwards. By requiring the price to be on a specific side of the 9 SMA, the script ensures you are only looking for trades that align with the short-term momentum.2. Pattern Recognition LogicThe script looks for six distinct candlestick patterns, split by the trend they appear in:PatternCategoryLogicEngulfing (BE/BU)Trend ReversalOne candle's body completely "eats" or engulfs the previous candle's body, signaling a shift in control.Hammer (HM)BullishSmall body at the top with a long lower shadow; implies sellers were rejected.Inverted Hammer (IH)BullishSmall body at the bottom with a long upper shadow; shows buyers testing the resistance.Shooting Star (SS)BearishSmall body at the bottom with a long upper shadow; implies buyers were rejected at a peak.Hanging Man (HM)BearishSmall body at the top with a long lower shadow; implies that despite a low price, sellers are stepping in during an uptrend.3. Volume ConfirmationThe script includes a Volume Filter that calculates the average volume over the last 20 periods (ta.sma(volume, 20)).The Logic: A reversal pattern is considered "weak" or "noisy" if it happens on low volume. By requiring volume > volAvg, the indicator ensures that the pattern is backed by significant market participation, which increases the probability that a "real" move is occurring.4. Visual ManagementDynamic Labels: It uses a latestLabel variable to ensure that only the most recent signal remains on your screen, preventing historical clutter.Highlighting: It uses barcolor() to change the candle color the moment a pattern is detected, making the signal immediately visible without needing to check the labels.Summary of Indicators UsedMoving Averages: 9 SMA (Trend), 20 SMA (Volume).Candlestick Math: Uses the relationship between open, close, high, and low to calculate bodySize and shadow lengths.Logical Confluence: It forces four conditions to be true simultaneously before alerting: Trend direction + Pattern geometry + Volume threshold + Logic validity.This tool is designed to act as a "Decision Point" indicator. It does not tell you to buy or sell, but rather tells you when the market has reached a state of "exhaustion" where a reversal is statistically more likely to happen.

## Source Code

````pine
//@version=6
indicator("reversal candle", shorttitle="Latest Signal", overlay=true)

// --- Inputs ---
var groupSettings = "Display Settings"
showLabels = input.bool(true, "Show Pattern Labels", group=groupSettings)
showSMA = input.bool(true, "Show 9 SMA Line", group=groupSettings)
highlightCandles = input.bool(true, "Highlight Pattern Candles", group=groupSettings)

var groupVol = "Volume Filter"
useVolFilter = input.bool(true, "Use Volume Filter", group=groupVol)
volAvgLen = input.int(20, "Volume Average Length", group=groupVol)

smaLength = input.int(9, "Trend Filter Length (SMA)", group="Trend Settings")
colorBear = input.color(color.red, "Bearish Color", group="Colors")
colorBull = input.color(color.blue, "Bullish Color", group="Colors")

// --- Variables to track the latest label ---
var label latestLabel = na

// --- Trend Logic (9 SMA) ---
sma9 = ta.sma(close, smaLength)
isUptrend = close > sma9
isDowntrend = close < sma9
plot(showSMA ? sma9 : na, color=color.gray, title="9 SMA")

// --- Volume Logic ---
volAvg = ta.sma(volume, volAvgLen)
isHighVol = not useVolFilter or (volume > volAvg)

// --- Patterns ---
bodySize = math.abs(close - open)
upperShadow = high - math.max(close, open)
lowerShadow = math.min(close, open) - low

engulfBear = isUptrend and open > close[1] and close < open[1] and bodySize > bodySize[1] and isHighVol
engulfBull = isDowntrend and open < close[1] and close > open[1] and bodySize > bodySize[1] and isHighVol
isHammer = isDowntrend and lowerShadow > (bodySize * 2) and upperShadow < bodySize and isHighVol
isInvertedHammer = isDowntrend and upperShadow > (bodySize * 2) and lowerShadow < bodySize and isHighVol
isShootStar = isUptrend and upperShadow > (bodySize * 2) and lowerShadow < bodySize and isHighVol
isHangingMan = isUptrend and lowerShadow > (bodySize * 2) and upperShadow < bodySize and isHighVol

isBearSignal = engulfBear or isShootStar or isHangingMan
isBullSignal = engulfBull or isHammer or isInvertedHammer

// --- Visuals ---
if showLabels and (isBearSignal or isBullSignal)
    // Delete the previous label before creating a new one
    if not na(latestLabel)
        label.delete(latestLabel)
    
    // Create new label based on the signal
    if isBearSignal
        latestLabel := label.new(bar_index, high, text=isShootStar ? "SS" : isHangingMan ? "HM" : "BE", style=label.style_label_down, color=colorBear, textcolor=color.white)
    else
        latestLabel := label.new(bar_index, low, text=isInvertedHammer ? "IH" : isHammer ? "HM" : "BU", style=label.style_label_up, color=colorBull, textcolor=color.white)

// Bar Coloring
barcolor(highlightCandles ? (isBearSignal ? colorBear : isBullSignal ? colorBull : na) : na)
````
