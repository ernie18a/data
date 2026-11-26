# SheLoveTheWoo

- url: https://www.tradingview.com/script/5VT6whB7-SheLoveTheWoo/
- type: indicator
- pine_id: PUB;5e225d35d6de4d749137256d8c316463
- version: 1.0

## Description

What This Script Does
This is an automated trading signal indicator designed to identify high-probability entry opportunities using Inner Circle Trader (ICT) trading principles. It combines:
Fair Value Gaps (FVG) - Price imbalances on the chart
Market Structure Shifts (MSS) - When price breaks previous highs/lows
SMT Divergence - RSI weakness signals potential reversals
Automatic Entry Grading - Rates each setup from A+ (best) to C (skip)
Risk/Reward Targets - Calculates TP and SL automatically



What You'll See on Your Chart
Yellow Background

Appears 7-10 AM EST (New York Killzone)
This is when the indicator looks for entries
Outside this time = no trading signals

Blue Boxes

Show Fair Value Gaps (price zones with no trading)
Entry opportunities form in these gaps
The bigger/cleaner the gap = better signal

Green Labels "MSS UP" / Red Labels "MSS DOWN"

Price has broken previous structure
Green = price moving up aggressively
Red = price moving down aggressively
This is smart money moving the market

"BULLISH DIV" or "BEARISH DIV" Labels

RSI divergence detected (opposite to price direction)
Bullish Div = Price lower, RSI higher = bounce coming
Bearish Div = Price higher, RSI lower = reversal coming

Grade Label (A+, A, B+, etc.)

Shows entry quality score (0-100 points)
A+ 🔥 = BEST trade (all 3 signals aligned)
A ✓ = VERY GOOD trade
B+ ⚠️ = MODERATE trade
B/C = SKIP these (low confidence)

Green & Red Dashed Lines

Green line = Take Profit target
Red line = Stop Loss placement
Automatically calculated based on your $300 risk

Information Panel (Bottom Right)

Shows current status: Killzone active? FVG detected? Divergence?
Shows exact TP/SL prices
Shows grade score and risk/reward ratio


How to Trade with This Script
Your Trading Routine (7-10 AM EST Daily)
Step 1: Wait for Killzone ⏰

Chart background turns yellow at 7 AM EST
Don't trade outside this window

Step 2: Look for A+ Grade Signals 🔥

Watch for the A+ 🔥 grade label to appear
This means: FVG + MSS + Divergence are all aligned
This is your highest probability entry

Step 3: Check the Setup Quality

Is there a blue box (FVG)? ✓
Is there MSS UP or MSS DOWN label? ✓
Is there BULLISH DIV or BEARISH DIV label? ✓
All 3 present = GREEN LIGHT TO TRADE

Step 4: Place Your Trade

For BULLISH setups (A+ grade, BULLISH DIV, MSS UP):

Entry: At the blue FVG box (green dashed line area)
Stop Loss: Red dashed line (below the entry)
Take Profit: Green dashed line (above the entry)
Position Size: Risk $300 (configured in settings)
Risk/Reward: Minimum 2:1 (you make $600 if you win)


For BEARISH setups (A+ grade, BEARISH DIV, MSS DOWN):

Entry: At the blue FVG box (red dashed line area)
Stop Loss: Red dashed line (above the entry)
Take Profit: Green dashed line (below the entry)
Position Size: Risk $300
Risk/Reward: Minimum 2:1



Step 5: Execute & Manage

Once price hits your entry zone (FVG), place your order
Use the red line as your stop loss
Use the green line as your take profit target
If stop is hit = move on to next setup
If take profit is hit = collect your profit


Settings (Right-Click Indicator → Settings)
Time Settings

Killzone Start Hour: 7 (when to start looking)
Killzone End Hour: 10 (when to stop)

Risk Settings

Risk Per Trade: $300 (how much you're willing to lose)
Risk to Reward Ratio: 2.0 (make $600 for every $300 risked)
Contract Type: MNQ or MES (which futures you trade)

Detection Settings

Divergence Lookback: 20 bars (how far back to look for RSI divergence)
Liquidity Lookback: 50 bars (how far back to find liquidity levels)
FVG Lookback: 3 candles (minimum candles for FVG detection)

Display Options

Toggle on/off: Killzone highlight, FVG boxes, divergence labels, alerts, grades
Change colors to match your preference


Understanding the Grades
GradeScoreWhat It MeansActionA+ 🔥95+BEST SETUPTAKE THIS TRADEA ✓85-94VERY GOODTake it (high probability)B+ ⚠️75-84MODERATEOptional (medium probability)B60-74WEAKConsider passingC<60POORSKIP - Too risky
Scoring Factors:

Killzone active = +30 points (most important)
All 3 signals aligned = +40 points
Strong RSI divergence = +20 points
FVG in premium/discount zone = +10 points


Real-World Trading Example
At 8:15 AM EST:
You see:

🟡 Yellow background (Killzone active) ✓
🔵 Blue box (FVG) ✓
🟢 MSS UP label (structure broken upward) ✓
🟢 BULLISH DIV label (RSI divergence) ✓
Grade: A+ 🔥 (Score: 98/100) ✓
Red line at 2475.0 (Stop Loss)
Green line at 2485.5 (Take Profit)
Risk: $300 | TP: $600

## Source Code

````pine
//@version=6
indicator("ICT Trading Setup Detector + SMT Divergence + GRADING", overlay=true)

// INPUTS
killzoneStart = input.int(7, "Killzone Start Hour (EST)", minval=0, maxval=23)
killzoneEnd = input.int(10, "Killzone End Hour (EST)", minval=0, maxval=23)
fvgLookback = input.int(3, "FVG Lookback Candles", minval=3, maxval=10)
minGapSize = input.float(0.5, "Minimum Gap Size (Points)", minval=0.1)
lookbackBars = input.int(50, "Liquidity Lookback Bars", minval=20, maxval=200)
showLiquidity = input.bool(true, "Show Liquidity Levels (15M)")
showDivergence = input.bool(true, "Show SMT Divergence Detection")
rsiLength = input.int(14, "RSI Length for Divergence", minval=5, maxval=50)
divergenceLookback = input.int(20, "Divergence Lookback Bars", minval=10, maxval=50)
riskPerTrade = input.float(300, "Risk Per Trade ($)", minval=50, maxval=1000)
rrRatio = input.float(2.0, "Risk to Reward Ratio (Minimum)", minval=1.0, maxval=5.0)
contractType = input.string("MNQ", "Contract Type (MNQ or MES)", options=["MNQ", "MES"])
showFVG = input.bool(true, "Show Fair Value Gaps (FVG)")
showIFVG = input.bool(true, "Show Inverse FVG (IFVG)")
showKillzone = input.bool(true, "Highlight Killzone")
showAlerts = input.bool(true, "Show Alert Labels")
showGrading = input.bool(true, "Show Entry Grades & Targets")
fvgColor = input.color(color.new(color.blue, 80), "FVG Color")
ifvgColor = input.color(color.new(color.orange, 80), "IFVG Color")
killzoneColor = input.color(color.new(color.yellow, 90), "Killzone Color")
bullishDivColor = input.color(color.new(color.green, 70), "Bullish Divergence Color")
bearishDivColor = input.color(color.new(color.red, 70), "Bearish Divergence Color")
gradeAColor = input.color(color.new(color.lime, 0), "Grade A+ Color")
gradeBColor = input.color(color.new(color.green, 0), "Grade A Color")
gradeCColor = input.color(color.new(color.orange, 0), "Grade B Color")

// FUNCTIONS
inKillzone() =>
    currHour = hour(time)
    currHour >= killzoneStart and currHour < killzoneEnd

detectFVG(idx) =>
    if idx < 2
        [false, 0.0, 0.0]
    else
        candle1High = high[idx]
        candle1Low = low[idx]
        candle3High = high[idx - 2]
        candle3Low = low[idx - 2]
        bullishGap = candle1High < candle3Low
        bearishGap = candle1Low > candle3High
        if bullishGap
            [true, candle1High, candle3Low]
        else if bearishGap
            [true, candle3High, candle1Low]
        else
            [false, 0.0, 0.0]

// CORE CALCULATIONS
rsi = ta.rsi(close, rsiLength)
[isFVG, fvgLow, fvgHigh] = detectFVG(0)

var array<float> prevFVGHighs = array.new<float>()
var array<float> prevFVGLows = array.new<float>()

if isFVG
    array.push(prevFVGHighs, fvgHigh)
    array.push(prevFVGLows, fvgLow)
    if array.size(prevFVGHighs) > 20
        array.shift(prevFVGHighs)
        array.shift(prevFVGLows)

recentHigh = ta.highest(high, lookbackBars)
recentLow = ta.lowest(low, lookbackBars)
fifteenMinHigh = request.security(syminfo.tickerid, "15", high)
fifteenMinLow = request.security(syminfo.tickerid, "15", low)

// DIVERGENCE
var float lastLowPrice = na
var float lastLowRSI = na
var float lastHighPrice = na
var float lastHighRSI = na

currentLowPrice = ta.lowest(low, divergenceLookback)
currentLowRSI = ta.lowest(rsi, divergenceLookback)

isBullishDiv = false
bullishDivPrice = 0.0
bullishDivRSI = 0.0

if na(lastLowPrice)
    lastLowPrice := currentLowPrice
    lastLowRSI := currentLowRSI
else
    if currentLowPrice < lastLowPrice and currentLowRSI > lastLowRSI
        isBullishDiv := true
        bullishDivPrice := currentLowPrice
        bullishDivRSI := currentLowRSI
    if currentLowPrice < lastLowPrice
        lastLowPrice := currentLowPrice
        lastLowRSI := currentLowRSI

currentHighPrice = ta.highest(high, divergenceLookback)
currentHighRSI = ta.highest(rsi, divergenceLookback)

isBearishDiv = false
bearishDivPrice = 0.0
bearishDivRSI = 0.0

if na(lastHighPrice)
    lastHighPrice := currentHighPrice
    lastHighRSI := currentHighRSI
else
    if currentHighPrice > lastHighPrice and currentHighRSI < lastHighRSI
        isBearishDiv := true
        bearishDivPrice := currentHighPrice
        bearishDivRSI := currentHighRSI
    if currentHighPrice > lastHighPrice
        lastHighPrice := currentHighPrice
        lastHighRSI := currentHighRSI

// MARKET STRUCTURE
var float lastSwingHigh = na
var float lastSwingLow = na

if na(lastSwingHigh)
    lastSwingHigh := high
if na(lastSwingLow)
    lastSwingLow := low

if high > lastSwingHigh
    lastSwingHigh := high
if low < lastSwingLow
    lastSwingLow := low

mssUp = close > lastSwingHigh and close[1] <= lastSwingHigh[1]
mssDown = close < lastSwingLow and close[1] >= lastSwingLow[1]

// SIGNALS
fvgInKillzone = isFVG and inKillzone()
mssConfirmed = mssUp or mssDown
smtDivergenceSignal = isBullishDiv or isBearishDiv
setupSignalStrong = (fvgInKillzone and mssConfirmed and smtDivergenceSignal)
setupSignalModerate = (fvgInKillzone and mssConfirmed) or (fvgInKillzone and smtDivergenceSignal)
setupSignalWeak = fvgInKillzone or mssConfirmed or smtDivergenceSignal

// RISK
pointValue = contractType == "MNQ" ? 20 : 50
riskPoints = riskPerTrade / pointValue
profitPoints = riskPoints * rrRatio

// GRADING
score = 0.0
if inKillzone()
    score := score + 30
if setupSignalStrong
    score := score + 40
else if setupSignalModerate
    score := score + 25
else if setupSignalWeak
    score := score + 10

if isBullishDiv
    divStr = bullishDivRSI - 50
    if divStr < -20
        score := score + 20
    else if divStr < -10
        score := score + 15
    else
        score := score + 10
else if isBearishDiv
    divStr = 50 - bearishDivRSI
    if divStr > 20
        score := score + 20
    else if divStr > 10
        score := score + 15
    else
        score := score + 10

if isFVG and fvgHigh != fvgLow
    midPoint = (fvgHigh + fvgLow) / 2
    fvgPercent = (fvgLow - midPoint) / ((fvgHigh - fvgLow) / 2)
    if fvgPercent < -0.3 or fvgPercent > 0.3
        score := score + 10
    else
        score := score + 5

entryScore = score
entryGrade = if entryScore >= 95
    "A+ 🔥"
else if entryScore >= 85
    "A ✓"
else if entryScore >= 75
    "B+ ⚠"
else if entryScore >= 60
    "B"
else
    "C"

gradeColor = if str.contains(entryGrade, "A+")
    gradeAColor
else if str.contains(entryGrade, "A")
    gradeBColor
else
    gradeCColor

// GLOBAL SCOPE - BGCOLOR (MUST BE AT ROOT LEVEL)
bgColor = if showKillzone and inKillzone()
    killzoneColor
else
    na

bgcolor(bgColor)

// PLOTTING
if showFVG and isFVG
    box.new(bar_index - 1, fvgHigh, bar_index, fvgLow, border_color=na, bgcolor=fvgColor)

if showLiquidity
    line.new(bar_index - 50, fifteenMinHigh, bar_index, fifteenMinHigh, color=color.new(color.gray, 50), width=1, style=line.style_dashed)
    line.new(bar_index - 50, fifteenMinLow, bar_index, fifteenMinLow, color=color.new(color.gray, 50), width=1, style=line.style_dashed)

if mssUp
    label.new(bar_index, high, "MSS UP", color=color.green, style=label.style_label_down, textcolor=color.white)
if mssDown
    label.new(bar_index, low, "MSS DOWN", color=color.red, style=label.style_label_up, textcolor=color.white)

if showDivergence and isBullishDiv
    label.new(bar_index, low, "BULLISH DIV", color=bullishDivColor, style=label.style_label_up, textcolor=color.white)
    line.new(bar_index - divergenceLookback, bullishDivPrice, bar_index, low, color=color.new(color.green, 30), width=2, style=line.style_dotted)

if showDivergence and isBearishDiv
    label.new(bar_index, high, "BEARISH DIV", color=bearishDivColor, style=label.style_label_down, textcolor=color.white)
    line.new(bar_index - divergenceLookback, bearishDivPrice, bar_index, high, color=color.new(color.red, 30), width=2, style=line.style_dotted)

// ALERTS
if showAlerts and setupSignalStrong
    alertText = "🔥 STRONG SETUP: FVG + MSS + DIV"
    label.new(bar_index, high * 1.002, alertText, color=color.new(color.blue, 0), style=label.style_label_center, textcolor=color.yellow, size=size.small)
    alert(alertText + " on " + syminfo.tickerid, alert.freq_once_per_bar)

if showAlerts and setupSignalModerate
    alertText = "⚠ MODERATE SETUP: Multiple Signals"
    label.new(bar_index, high * 1.001, alertText, color=color.new(color.blue, 0), style=label.style_label_center, textcolor=color.white, size=size.small)
    alert(alertText + " on " + syminfo.tickerid, alert.freq_once_per_bar)

// GRADES AND TP/SL
if showGrading and (setupSignalStrong or setupSignalModerate)
    isBullishSetup = isBullishDiv or (mssUp and close > open)
    if isBullishSetup
        slLevel = low - (riskPoints * syminfo.mintick)
        tpLevel = high + (profitPoints * syminfo.mintick)
        gradeText = entryGrade + "\nRISK: $" + str.tostring(math.round(riskPerTrade)) + "\nTP: " + str.tostring(tpLevel, "#.#") + "\nSL: " + str.tostring(slLevel, "#.#")
        label.new(bar_index, high * 1.005, gradeText, color=gradeColor, style=label.style_label_center, textcolor=color.white, size=size.small, yloc=yloc.abovebar)
        line.new(bar_index - 20, tpLevel, bar_index + 5, tpLevel, color=color.new(color.green, 40), width=2, style=line.style_dashed)
        line.new(bar_index - 20, slLevel, bar_index + 5, slLevel, color=color.new(color.red, 40), width=2, style=line.style_dashed)
    else
        slLevel = high + (riskPoints * syminfo.mintick)
        tpLevel = low - (profitPoints * syminfo.mintick)
        gradeText = entryGrade + "\nRISK: $" + str.tostring(math.round(riskPerTrade)) + "\nTP: " + str.tostring(tpLevel, "#.#") + "\nSL: " + str.tostring(slLevel, "#.#")
        label.new(bar_index, low * 0.995, gradeText, color=gradeColor, style=label.style_label_center, textcolor=color.white, size=size.small, yloc=yloc.belowbar)
        line.new(bar_index - 20, tpLevel, bar_index + 5, tpLevel, color=color.new(color.green, 40), width=2, style=line.style_dashed)
        line.new(bar_index - 20, slLevel, bar_index + 5, slLevel, color=color.new(color.red, 40), width=2, style=line.style_dashed)

// INFO PANEL
info_text = "═══ ICT SETUP STATUS ═══\nGRADE: " + entryGrade + " (Score: " + str.tostring(math.round(entryScore)) + "/100)\n━━━━━━━━━━━━━━━━━━\nKILLZONE: " + (inKillzone() ? "🟢 YES" : "🔴 NO") + "\nFVG DETECTED: " + (isFVG ? "🟢 YES" : "🔴 NO") + "\nMSS ACTIVE: " + (mssConfirmed ? "🟢 YES" : "🔴 NO") + "\nSMT DIVERGENCE: " + (smtDivergenceSignal ? "🟢 YES" : "🔴 NO") + "\n━━━━━━━━━━━━━━━━━━\nBullish Div: " + (isBullishDiv ? "✓" : "✗") + " | Bearish Div: " + (isBearishDiv ? "✓" : "✗") + "\n15M High: " + str.tostring(fifteenMinHigh, "#.#") + "\n15M Low: " + str.tostring(fifteenMinLow, "#.#") + "\nRSI: " + str.tostring(rsi, "#.#") + "\n━━━━━━━━━━━━━━━━━━\nRISK/REWARD TARGETS:\nRisk per Trade: $" + str.tostring(math.round(riskPerTrade)) + "\nRisk Points: " + str.tostring(math.round(riskPoints, 1)) + "\nTP Points: " + str.tostring(math.round(profitPoints, 1)) + "\nR/R Ratio: 1:" + str.tostring(rrRatio)

plot(na, title="Info", display=display.status_line)
````
