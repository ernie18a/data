# Elaris Session Strength Indicator

- url: https://www.tradingview.com/script/6YmxQPeJ-Elaris-Session-Strength-Indicator/
- type: indicator
- pine_id: PUB;5e0802170a064c9c8b0439546e63ed80
- version: 1.0

## Description

## Elaris Session Breakout Pro

Elaris Session Breakout Pro is a clean and professional session-based trading indicator designed to help traders identify high-probability breakout opportunities during key market sessions such as London and New York.

The indicator automatically tracks the opening range of the selected session and highlights breakout confirmations when price closes above or below the defined session range. This allows traders to quickly spot momentum expansion, liquidity-driven moves, and potential intraday trend continuation setups without manually drawing levels.

Built with a strong focus on clarity, usability, and real-time decision support, the indicator is optimized for scalpers, day traders, and momentum traders across crypto, forex, and index markets.

### Key Features

• Automatic session opening range detection
• Dynamic breakout signals for bullish and bearish moves
• Non-repainting breakout confirmations
• Clean chart visualization with minimal clutter
• Configurable session timings and breakout logic
• Visual breakout labels and session range plotting
• Suitable for crypto, forex, and traditional markets
• Optimized for lower timeframes and intraday trading

### How It Works

The indicator monitors the first candle or opening range of the selected trading session. When price successfully closes above the session high, a bullish breakout signal is generated. When price closes below the session low, a bearish breakout signal is generated.

This approach helps traders identify moments where liquidity and volatility expand during active market hours, often leading to strong directional movement.

### Best Use Cases

• London session breakout trading
• New York open momentum trades
• Crypto volatility expansion setups
• Intraday trend continuation strategies
• Liquidity and range breakout confirmation

### Notes

Like all trading indicators, this tool should be used as part of a complete trading plan with proper risk management and confirmation techniques. Market conditions can vary, and no indicator guarantees profitability or a 100% win rate.

TradingView session concepts referenced in this script are based on TradingView’s official Pine Script session documentation.

## Source Code

````pine
//@version=6
indicator("Elaris Session Strength Indicator", shorttitle="Elaris SSI", overlay=false, max_labels_count=200, max_lines_count=50)


// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
groupSessions = "Sessions"
asiaSession   = input.session("0000-0800", "Asia Session", group=groupSessions)
londonSession = input.session("0800-1600", "London Session", group=groupSessions)
newyorkSession= input.session("1300-2100", "New York Session", group=groupSessions)

groupEngine = "Strength Engine"
atrLength        = input.int(14, "ATR Length", minval=1, group=groupEngine)
volLength        = input.int(20, "Volume Average Length", minval=1, group=groupEngine)
signalLength     = input.int(8, "Signal Smoothing", minval=1, group=groupEngine)
strengthSmooth   = input.int(5, "Strength Smoothing", minval=1, group=groupEngine)
sessionOpenLen   = input.int(1, "Session Open Reference Bars", minval=1, maxval=10, group=groupEngine)

weightRange      = input.float(30.0, "Weight: Range Expansion", minval=0, maxval=100, step=0.5, group=groupEngine)
weightVolume     = input.float(25.0, "Weight: Relative Volume", minval=0, maxval=100, step=0.5, group=groupEngine)
weightBody       = input.float(20.0, "Weight: Candle Efficiency", minval=0, maxval=100, step=0.5, group=groupEngine)
weightDisplace   = input.float(25.0, "Weight: Session Displacement", minval=0, maxval=100, step=0.5, group=groupEngine)

groupView = "Visuals"
showHistogram    = input.bool(true, "Show Strength Histogram", group=groupView)
showBullBear     = input.bool(true, "Show Bull/Bear Components", group=groupView)
showBackground   = input.bool(true, "Tint Current Session Background", group=groupView)
showPanel        = input.bool(true, "Show Info Panel", group=groupView)
showSessionMarks = input.bool(true, "Mark Session Starts", group=groupView)

groupThresholds = "States & Alerts"
strongThreshold = input.float(65.0, "Strong Threshold", minval=0, maxval=100, step=0.5, group=groupThresholds)
weakThreshold   = input.float(35.0, "Weak Threshold", minval=0, maxval=100, step=0.5, group=groupThresholds)

// -----------------------------------------------------------------------------
// Session detection
// -----------------------------------------------------------------------------
inAsia    = not na(time(timeframe.period, asiaSession))
inLondon  = not na(time(timeframe.period, londonSession))
inNewYork = not na(time(timeframe.period, newyorkSession))

sessionCode =
     inAsia    ? 1 :
     inLondon  ? 2 :
     inNewYork ? 3 : 0

sessionName =
     sessionCode == 1 ? "Asia" :
     sessionCode == 2 ? "London" :
     sessionCode == 3 ? "New York" : "Off Session"

newSession = sessionCode != sessionCode[1] and sessionCode != 0
endSession = sessionCode == 0 and sessionCode[1] != 0

// -----------------------------------------------------------------------------
// Session color theme
// -----------------------------------------------------------------------------
sessionColor =
     sessionCode == 1 ? color.new(color.teal, 0) :
     sessionCode == 2 ? color.new(color.blue, 0) :
     sessionCode == 3 ? color.new(color.orange, 0) :
     color.new(color.gray, 50)

bgcolor(showBackground and sessionCode != 0 ? color.new(sessionColor, 90) : na)

// -----------------------------------------------------------------------------
// Session open tracking
// -----------------------------------------------------------------------------
var float currentSessionOpen = na
var float currentSessionHigh = na
var float currentSessionLow  = na
var int   currentSessionBars = 0

if newSession
    currentSessionOpen := open
    currentSessionHigh := high
    currentSessionLow  := low
    currentSessionBars := 1
else if sessionCode != 0
    currentSessionHigh := na(currentSessionHigh) ? high : math.max(currentSessionHigh, high)
    currentSessionLow  := na(currentSessionLow)  ? low  : math.min(currentSessionLow, low)
    currentSessionBars += 1
else
    currentSessionOpen := na
    currentSessionHigh := na
    currentSessionLow  := na
    currentSessionBars := 0

sessionRefOpen = ta.valuewhen(newSession, open, 0)
sessionOpenPrice = na(sessionRefOpen) ? open : sessionRefOpen

// -----------------------------------------------------------------------------
// Base measures
// -----------------------------------------------------------------------------
atrValue = ta.atr(atrLength)
avgVol   = ta.sma(volume, volLength)

barRange = high - low
realBody = math.abs(close - open)

// Relative range expansion
rangeExpansionRaw = atrValue > 0 ? barRange / atrValue : 0.0
rangeExpansion    = math.min(rangeExpansionRaw, 2.5) / 2.5 * 100.0

// Relative volume expansion
relativeVolumeRaw = avgVol > 0 ? volume / avgVol : 0.0
relativeVolume    = math.min(relativeVolumeRaw, 2.5) / 2.5 * 100.0

// Candle efficiency: how directional the bar is
bodyEfficiencyRaw = barRange > 0 ? realBody / barRange : 0.0
bodyEfficiency    = bodyEfficiencyRaw * 100.0

// Displacement from session open
sessionDisplacementRaw = atrValue > 0 and not na(sessionOpenPrice) ? math.abs(close - sessionOpenPrice) / atrValue : 0.0
sessionDisplacement    = math.min(sessionDisplacementRaw, 3.0) / 3.0 * 100.0

// -----------------------------------------------------------------------------
// Composite strength
// -----------------------------------------------------------------------------
weightsTotal = math.max(weightRange + weightVolume + weightBody + weightDisplace, 0.0001)

rawStrength =( rangeExpansion   * weightRange + relativeVolume   * weightVolume + bodyEfficiency   * weightBody + sessionDisplacement * weightDisplace ) / weightsTotal

smoothedStrength = ta.ema(rawStrength, strengthSmooth)
signalLine       = ta.ema(smoothedStrength, signalLength)

// -----------------------------------------------------------------------------
// Directional bias
// -----------------------------------------------------------------------------
barBias =
     close > open ? 1.0 :
     close < open ? -1.0 : 0.0

sessionBiasFromOpen =
     close > sessionOpenPrice ? 1.0 :
     close < sessionOpenPrice ? -1.0 : 0.0

combinedBias = (barBias * 0.45) + (sessionBiasFromOpen * 0.55)
combinedBias := math.max(math.min(combinedBias, 1.0), -1.0)

signedStrength = smoothedStrength * combinedBias
bullStrength   = math.max(signedStrength, 0)
bearStrength   = math.abs(math.min(signedStrength, 0))

// -----------------------------------------------------------------------------
// State model
// -----------------------------------------------------------------------------
absStrength = math.abs(signedStrength)

isStrongBull = signedStrength >= strongThreshold
isStrongBear = signedStrength <= -strongThreshold
isWeak       = absStrength < weakThreshold
isBullBuild  = signedStrength > weakThreshold and signedStrength < strongThreshold
isBearBuild  = signedStrength < -weakThreshold and signedStrength > -strongThreshold

stateText =
     isStrongBull ? "Strong Bullish Session" :
     isStrongBear ? "Strong Bearish Session" :
     isBullBuild  ? "Bullish Building" :
     isBearBuild  ? "Bearish Building" :
     "Neutral / Weak"

stateColor =
     isStrongBull ? color.lime :
     isStrongBear ? color.red :
     isBullBuild  ? color.green :
     isBearBuild  ? color.maroon :
     color.gray

// -----------------------------------------------------------------------------
// Plots
// -----------------------------------------------------------------------------
zeroLine = 0.0
upperBand = strongThreshold
lowerBand = -strongThreshold
weakBandUp = weakThreshold
weakBandDn = -weakThreshold

hline(0, "Zero", color=color.new(color.gray, 70))
hline(strongThreshold, "Strong Bull Threshold", color=color.new(color.lime, 65), linestyle=hline.style_dashed)
hline(-strongThreshold, "Strong Bear Threshold", color=color.new(color.red, 65), linestyle=hline.style_dashed)
hline(weakThreshold, "Weak Upper", color=color.new(color.gray, 85), linestyle=hline.style_dotted)
hline(-weakThreshold, "Weak Lower", color=color.new(color.gray, 85), linestyle=hline.style_dotted)

histColor =
     signedStrength >= strongThreshold ? color.new(color.lime, 0) :
     signedStrength > 0 ? color.new(color.green, 10) :
     signedStrength <= -strongThreshold ? color.new(color.red, 0) :
     color.new(color.orange, 10)

plot(showHistogram ? signedStrength : na, "Session Strength", style=plot.style_columns, color=histColor, linewidth=2)
plot(signalLine * (signedStrength == 0 ? 0 : math.sign(signedStrength)), "Signal Line", color=color.white, linewidth=2)

plot(showBullBear ? bullStrength : na, "Bull Strength", color=color.new(color.lime, 0), linewidth=2)
plot(showBullBear ? -bearStrength : na, "Bear Strength", color=color.new(color.red, 0), linewidth=2)

// -----------------------------------------------------------------------------
// Session start markers
// -----------------------------------------------------------------------------
plotshape(showSessionMarks and newSession, title="Session Start", style=shape.diamond, location=location.bottom, size=size.tiny, color=sessionColor, text="S")

// -----------------------------------------------------------------------------
// Session statistics
// -----------------------------------------------------------------------------
sessionRange = sessionCode != 0 and not na(currentSessionHigh) and not na(currentSessionLow) ? (currentSessionHigh - currentSessionLow) : na
sessionRangeAtr = sessionCode != 0 and atrValue > 0 and not na(sessionRange) ? sessionRange / atrValue : na

progressBarsEstimate = sessionCode != 0 ? currentSessionBars : na

// -----------------------------------------------------------------------------
// Alerts
// -----------------------------------------------------------------------------
bullCrossStrong = ta.crossover(signedStrength, strongThreshold)
bearCrossStrong = ta.crossunder(signedStrength, -strongThreshold)
crossAboveZero  = ta.crossover(signedStrength, 0)
crossBelowZero  = ta.crossunder(signedStrength, 0)

alertcondition(bullCrossStrong, "Strong Bullish Session", "Elaris SSI: Session strength crossed into strong bullish territory.")
alertcondition(bearCrossStrong, "Strong Bearish Session", "Elaris SSI: Session strength crossed into strong bearish territory.")
alertcondition(crossAboveZero, "Bullish Bias Shift", "Elaris SSI: Session strength shifted above zero.")
alertcondition(crossBelowZero, "Bearish Bias Shift", "Elaris SSI: Session strength shifted below zero.")
alertcondition(newSession, "New Session Started", "Elaris SSI: A new trading session has started.")

// -----------------------------------------------------------------------------
// Info panel
// TradingView tables are part of Pine's official visuals system.
// -----------------------------------------------------------------------------
var table panel = table.new(position.top_right, 2, 8, border_width=1)

fmt(v) =>
    na(v) ? "n/a" : str.tostring(v, "#.##")

if barstate.islast and showPanel
    table.cell(panel, 0, 0, "Elaris SSI", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 0, sessionName, text_color=color.white, bgcolor=sessionColor)

    table.cell(panel, 0, 1, "State", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 1, stateText, text_color=stateColor, bgcolor=color.new(color.black, 0))

    table.cell(panel, 0, 2, "Strength", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 2, fmt(signedStrength), text_color=color.white, bgcolor=color.new(stateColor, 75))

    table.cell(panel, 0, 3, "Range Score", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 3, fmt(rangeExpansion), text_color=color.white, bgcolor=color.new(color.blue, 80))

    table.cell(panel, 0, 4, "Volume Score", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 4, fmt(relativeVolume), text_color=color.white, bgcolor=color.new(color.purple, 80))

    table.cell(panel, 0, 5, "Efficiency", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 5, fmt(bodyEfficiency), text_color=color.white, bgcolor=color.new(color.green, 80))

    table.cell(panel, 0, 6, "Displacement", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 6, fmt(sessionDisplacement), text_color=color.white, bgcolor=color.new(color.orange, 80))

    table.cell(panel, 0, 7, "Session Range ATR", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 7, fmt(sessionRangeAtr), text_color=color.white, bgcolor=color.new(color.gray, 80))
````
