# Bounce Setup Indicator + Quality Score

- url: https://www.tradingview.com/script/YqRfoyqg-Bounce-Setup-Indicator-Quality-Score/
- type: indicator
- pine_id: PUB;1294186aa33f465f838d5bc40d39d716
- version: 1.0

## Description

Bounce Pro Elite Suite v3.0

Core Trading Systems

✔ Bullish Bounce

✔ Bearish Bounce

✔ Bullish Bounce 200

✔ Bearish Bounce 200

⸻

Trend Engine

Displays:

• EMA Rainbow Trend

• 50/200 SMA Trend

• Market Bias

• Trend Strength

• Higher Timeframe Confirmation

⸻

Smart Checklist

Every condition receives a check mark.

Example:

✅ EMA Alignment

✅ Strong ADX

✅ Stochastic Pullback

✅ Near Support

✅ RSI Trigger

✅ Price Trigger

⚠ Large Gap

⚠ Earnings Soon (manual reminder)

Final Result:

8 / 10 Conditions Passed

⸻

Trade Quality Score

0-100 Score

95-100 Elite

90-94 Excellent

80-89 High Probability

70-79 Good

60-69 Average

Below 60 Avoid

⸻

Confidence Meter

Visual Gauge

🟢 Green

🟡 Yellow

🔴 Red

Based on:

Trend

Momentum

Volatility

Location

Entry Trigger

⸻

Entry Confirmation

CALL

PUT

WAIT

Shows exactly why a trade is or isn’t ready.

⸻

ATR Risk Engine

Automatically calculates

Entry

Suggested Stop Loss

Target 1 (1R)

Target 2 (2R)

Target 3 (3R)

Risk %

ATR Buffer

⸻

Support / Resistance Engine

Highlights

EMA Support

50 SMA

200 SMA

Previous Swing High

Previous Swing Low

Horizontal Levels

⸻

Multi-Timeframe Scanner

Check

15 Minute

30 Minute

1 Hour

2 Hour

4 Hour

Daily

Weekly

Green = Trend agrees

Red = Trend disagrees

⸻

Options Dashboard

Suggested Direction

CALL

PUT

Estimated Delta

Suggested DTE

Expected Hold Time

⸻

Market Health

ADX

RSI

ATR

Trend Score

Momentum Score

Volatility Score

⸻

Smart Warnings

Large Candle

Gap

Overextended Trend

Low Volume

Low ADX

Choppy Market

Late Entry

⸻

Dashboard

Displays

Current Setup

Quality Score

Confidence

Risk

Trend

Momentum

Support

Resistance

ATR

Daily Filter

Trade Direction

⸻

Alerts

Bullish Bounce

Bearish Bounce

Bounce 200

High Quality Setup

Elite Setup

ATR Stop Hit

Target 1

Target 2

Target 3

Trend Change

Quality Score >90

Daily Trend Change

⸻

Future AI Features

Machine-learning style weighted scoring

Automatic ranking of every setup

Best trade of the day

Probability estimate

Portfolio watchlist scanner

Heat map for strongest setups

Performance statistics

Win rate by setup

Average R multiple

Average holding period

Trade journal export

## Source Code

````pine
//@version=6
indicator("Bounce Setup Indicator + Quality Score v6", overlay=true, max_labels_count=500)

// INPUTS
mode = input.string("All Setups", "Setup Mode", options=["All Setups", "Bullish Bounce", "Bearish Bounce", "Bullish Bounce 200", "Bearish Bounce 200"])
useDailyFilter = input.bool(false, "Use Daily Timeframe Filter")
showEMAs = input.bool(true, "Show EMA Rainbow")
showSMAs = input.bool(true, "Show 50/200 SMA")
showSetups = input.bool(true, "Show Setup Signals")
showEntries = input.bool(true, "Show Entry Signals")
showDashboard = input.bool(true, "Show Dashboard")

adxMin = input.float(20, "Minimum ADX", step=0.5)
stochBullLevel = input.float(40, "Bullish Stoch <= Level")
stochBearLevel = input.float(60, "Bearish Stoch >= Level")
nearPct = input.float(1.5, "Near Support/Resistance %", step=0.1)

useRSITrigger = input.bool(true, "Use RSI(2) Bullish Trigger")
useATRWarning = input.bool(true, "Use Large Candle / Gap Warning")
atrMultiplier = input.float(1.8, "Large Candle ATR Multiplier", step=0.1)

// MOVING AVERAGES
ema8 = ta.ema(close, 8)
ema21 = ta.ema(close, 21)
ema34 = ta.ema(close, 34)
ema55 = ta.ema(close, 55)
ema89 = ta.ema(close, 89)

sma50 = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

// INDICATORS
stochK = ta.sma(ta.stoch(close, high, low, 8), 3)
rsi2 = ta.rsi(close, 2)
[plusDI, minusDI, adx] = ta.dmi(13, 13)
atr = ta.atr(14)

// DAILY VALUES
dClose = request.security(syminfo.tickerid, "D", close)
dHigh = request.security(syminfo.tickerid, "D", high)
dLow = request.security(syminfo.tickerid, "D", low)

dEma8 = request.security(syminfo.tickerid, "D", ta.ema(close, 8))
dEma21 = request.security(syminfo.tickerid, "D", ta.ema(close, 21))
dEma34 = request.security(syminfo.tickerid, "D", ta.ema(close, 34))
dEma55 = request.security(syminfo.tickerid, "D", ta.ema(close, 55))
dEma89 = request.security(syminfo.tickerid, "D", ta.ema(close, 89))

dSma50 = request.security(syminfo.tickerid, "D", ta.sma(close, 50))
dSma200 = request.security(syminfo.tickerid, "D", ta.sma(close, 200))

dStochK = request.security(syminfo.tickerid, "D", ta.sma(ta.stoch(close, high, low, 8), 3))
dRsi2 = request.security(syminfo.tickerid, "D", ta.rsi(close, 2))
[dPlusDI, dMinusDI, dAdx] = request.security(syminfo.tickerid, "D", ta.dmi(13, 13))

// ACTIVE VALUES
aEma8 = useDailyFilter ? dEma8 : ema8
aEma21 = useDailyFilter ? dEma21 : ema21
aEma34 = useDailyFilter ? dEma34 : ema34
aEma55 = useDailyFilter ? dEma55 : ema55
aEma89 = useDailyFilter ? dEma89 : ema89

aSma50 = useDailyFilter ? dSma50 : sma50
aSma200 = useDailyFilter ? dSma200 : sma200
aStochK = useDailyFilter ? dStochK : stochK
aRsi2 = useDailyFilter ? dRsi2 : rsi2
aAdx = useDailyFilter ? dAdx : adx

// TREND LOGIC
bullRainbow = aEma8 > aEma21 and aEma21 > aEma34 and aEma34 > aEma55 and aEma55 > aEma89
bearRainbow = aEma8 < aEma21 and aEma21 < aEma34 and aEma34 < aEma55 and aEma55 < aEma89

bullLongTrend = aSma50 > aSma200
bearLongTrend = aSma50 < aSma200

// RETRACEMENT
bullRetracement = aStochK <= stochBullLevel
bearRetracement = aStochK >= stochBearLevel
adxStrong = aAdx >= adxMin

// SUPPORT / RESISTANCE
nearEma8 = math.abs(close - ema8) / close * 100 <= nearPct
nearEma21 = math.abs(close - ema21) / close * 100 <= nearPct
nearEma34 = math.abs(close - ema34) / close * 100 <= nearPct
nearSma50 = math.abs(close - sma50) / close * 100 <= nearPct
nearSma200 = math.abs(close - sma200) / close * 100 <= nearPct

nearBullSupport = nearEma8 or nearEma21 or nearEma34 or nearSma50
nearBearResistance = nearEma8 or nearEma21 or nearEma34 or nearSma50
touching200 = high >= sma200 and low <= sma200

// WARNINGS
largeCandle = math.abs(close - open) > atr * atrMultiplier
gapUp = open > high[1] + atr * 0.5
gapDown = open < low[1] - atr * 0.5

bullWarning = useATRWarning and ((largeCandle and close < open) or gapDown)
bearWarning = useATRWarning and ((largeCandle and close > open) or gapUp)

warningClearBull = not bullWarning
warningClearBear = not bearWarning

// SETUPS
bullishBounceSetup = bullRainbow and bullRetracement and adxStrong and nearBullSupport and warningClearBull
bearishBounceSetup = bearRainbow and bearRetracement and adxStrong and nearBearResistance and warningClearBear

bullishBounce200Setup = touching200 and bullLongTrend and bullRetracement and warningClearBull
bearishBounce200Setup = touching200 and bearLongTrend and bearRetracement and warningClearBear

// ENTRY LOGIC
var float bullLowBarHigh = na
var float bearHighBarLow = na

if bullRetracement
    bullLowBarHigh := high

if bearRetracement
    bearHighBarLow := low

bullPriceTrigger = not na(bullLowBarHigh) and close > bullLowBarHigh and close[1] <= bullLowBarHigh
bearPriceTrigger = not na(bearHighBarLow) and close < bearHighBarLow and close[1] >= bearHighBarLow

bullRSITrigger = ta.crossover(aRsi2, 10)

bullEntryTrigger = useRSITrigger ? bullPriceTrigger or bullRSITrigger : bullPriceTrigger
bearEntryTrigger = bearPriceTrigger

bullishBounceEntry = bullishBounceSetup and bullEntryTrigger
bearishBounceEntry = bearishBounceSetup and bearEntryTrigger
bullishBounce200Entry = bullishBounce200Setup and bullEntryTrigger
bearishBounce200Entry = bearishBounce200Setup and bearEntryTrigger

// QUALITY SCORE
int score = 0

score += bullRainbow or bearRainbow ? 20 : 0
score += bullLongTrend or bearLongTrend ? 15 : 0
score += bullRetracement or bearRetracement ? 20 : 0
score += aAdx >= 20 ? 15 : 0
score += aAdx >= 25 ? 5 : 0
score += nearBullSupport or nearBearResistance or touching200 ? 20 : 0
score += bullEntryTrigger or bearEntryTrigger ? 5 : 0
score -= bullWarning or bearWarning ? 20 : 0

score := math.max(score, 0)
score := math.min(score, 100)

qualityLabel = score >= 85 ? "A+ Setup" : score >= 75 ? "A Setup" : score >= 65 ? "B Setup" : score >= 50 ? "C Setup" : "Weak Setup"

// MODE FILTERS
showBullBounce = mode == "All Setups" or mode == "Bullish Bounce"
showBearBounce = mode == "All Setups" or mode == "Bearish Bounce"
showBull200 = mode == "All Setups" or mode == "Bullish Bounce 200"
showBear200 = mode == "All Setups" or mode == "Bearish Bounce 200"

// PLOTS
plot(showEMAs ? ema8 : na, "8 EMA")
plot(showEMAs ? ema21 : na, "21 EMA")
plot(showEMAs ? ema34 : na, "34 EMA")
plot(showEMAs ? ema55 : na, "55 EMA")
plot(showEMAs ? ema89 : na, "89 EMA")

plot(showSMAs ? sma50 : na, "50 SMA", linewidth=2)
plot(showSMAs ? sma200 : na, "200 SMA", linewidth=3)

// SETUP SIGNALS
plotshape(showSetups and showBullBounce and bullishBounceSetup, title="Bullish Bounce Setup", style=shape.circle, location=location.belowbar, size=size.tiny, text="BB")
plotshape(showSetups and showBearBounce and bearishBounceSetup, title="Bearish Bounce Setup", style=shape.circle, location=location.abovebar, size=size.tiny, text="SB")
plotshape(showSetups and showBull200 and bullishBounce200Setup, title="Bullish Bounce 200 Setup", style=shape.diamond, location=location.belowbar, size=size.small, text="B200")
plotshape(showSetups and showBear200 and bearishBounce200Setup, title="Bearish Bounce 200 Setup", style=shape.diamond, location=location.abovebar, size=size.small, text="S200")

// ENTRY SIGNALS
plotshape(showEntries and showBullBounce and bullishBounceEntry, title="Bullish Bounce Entry", style=shape.triangleup, location=location.belowbar, size=size.normal, text="CALL")
plotshape(showEntries and showBearBounce and bearishBounceEntry, title="Bearish Bounce Entry", style=shape.triangledown, location=location.abovebar, size=size.normal, text="PUT")
plotshape(showEntries and showBull200 and bullishBounce200Entry, title="Bullish Bounce 200 Entry", style=shape.triangleup, location=location.belowbar, size=size.normal, text="CALL 200")
plotshape(showEntries and showBear200 and bearishBounce200Entry, title="Bearish Bounce 200 Entry", style=shape.triangledown, location=location.abovebar, size=size.normal, text="PUT 200")

// RISK WARNINGS
plotshape(bullWarning, title="Bullish Warning", style=shape.xcross, location=location.abovebar, size=size.tiny, text="Risk")
plotshape(bearWarning, title="Bearish Warning", style=shape.xcross, location=location.belowbar, size=size.tiny, text="Risk")

// ALERTS
alertcondition(bullishBounceSetup, "Bullish Bounce Setup", "Bullish Bounce setup detected")
alertcondition(bearishBounceSetup, "Bearish Bounce Setup", "Bearish Bounce setup detected")
alertcondition(bullishBounce200Setup, "Bullish Bounce 200 Setup", "Bullish Bounce 200 setup detected")
alertcondition(bearishBounce200Setup, "Bearish Bounce 200 Setup", "Bearish Bounce 200 setup detected")

alertcondition(bullishBounceEntry, "Bullish Bounce Entry", "Bullish Bounce CALL entry trigger")
alertcondition(bearishBounceEntry, "Bearish Bounce Entry", "Bearish Bounce PUT entry trigger")
alertcondition(bullishBounce200Entry, "Bullish Bounce 200 Entry", "Bullish Bounce 200 CALL entry trigger")
alertcondition(bearishBounce200Entry, "Bearish Bounce 200 Entry", "Bearish Bounce 200 PUT entry trigger")

alertcondition(score >= 75, "High Quality Setup", "Bounce setup quality score is 75 or higher")
alertcondition(score >= 85, "A+ Quality Setup", "Bounce setup quality score is 85 or higher")

// DASHBOARD
var table dash = table.new(position.top_right, 1, 10)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "Bounce Setup Dashboard")
    table.cell(dash, 0, 1, "Mode: " + mode)
    table.cell(dash, 0, 2, "Quality: " + str.tostring(score) + "/100")
    table.cell(dash, 0, 3, "Grade: " + qualityLabel)
    table.cell(dash, 0, 4, "Stoch K: " + str.tostring(aStochK, "#.##"))
    table.cell(dash, 0, 5, "RSI(2): " + str.tostring(aRsi2, "#.##"))
    table.cell(dash, 0, 6, "ADX: " + str.tostring(aAdx, "#.##"))
    table.cell(dash, 0, 7, "Trend: " + (bullRainbow or bullLongTrend ? "Bullish" : bearRainbow or bearLongTrend ? "Bearish" : "Neutral"))
    table.cell(dash, 0, 8, "Warning: " + (bullWarning or bearWarning ? "YES" : "NO"))
    table.cell(dash, 0, 9, "Daily Filter: " + (useDailyFilter ? "ON" : "OFF"))

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0)
````
