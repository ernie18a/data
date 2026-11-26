# Squeeze Momentum IQ Trade Management Simplified

- url: https://www.tradingview.com/script/T5bUOfHy-Squeeze-Momentum-IQ-Trade-Management-Simplified/
- type: indicator
- pine_id: PUB;40628376feaa4ff2a6dfcc6fd02dde73
- version: 1.0

## Description

Squeeze Momentum IQ Trade Management Simplified

A trade management and position conviction engine designed to help determine whether to continue holding, manage cautiously, take profits, or avoid new entries.

Most indicators focus on finding entries.

Squeeze Momentum Nexus Conviction focuses on a different question:

"Does the trade still deserve my conviction?"

Rather than generating simple buy and sell signals, Conviction continuously evaluates trend quality, momentum behavior, efficiency, and confirmation conditions to determine whether current market conditions still support remaining in a trade.

The objective is to help traders avoid two common mistakes:

• Exiting strong trends too early
• Holding weakening trades too long

Core Concept

Conviction transforms multiple market variables into a simplified trade management framework:

HOLD

Strong trend quality and confirmation
Momentum remains healthy
Higher timeframe and trend conditions supportive

HOLD CAUTIOUSLY

Trend remains intact, but signs of weakening or conflict begin to appear
Increased probability of pullback or slower continuation

TAKE PROFIT / DO NOT ENTER

Trade quality deteriorating
Momentum weakening significantly
Choppy or conflicting conditions increasing
Features

Trade Quality Engine
Evaluates market conditions through a weighted scoring model using:

• Momentum behavior
• Trend confirmation
• Higher timeframe agreement
• Efficiency ratio
• Volatility state
• Expansion quality

Conviction State Engine

Converts raw calculations into actionable states:

HOLD

Strong continuation conditions
Trend quality remains elevated

HOLD CAUTIOUSLY

Moderate quality conditions
Continuation possible but with increasing caution

TAKE PROFIT / DO NOT ENTER

Weak conditions
Elevated risk of deterioration, pullback, or lower probability continuation

Visual Hold Zones

Vertical highlighted chart regions visually display current conviction states:

Green

HOLD

Orange

HOLD CAUTIOUSLY

Red

TAKE PROFIT / DO NOT ENTER

Designed to allow immediate interpretation directly from price action without requiring constant dashboard monitoring.

Simple Decision Dashboard

Displays only the essential information:

Action

HOLD
HOLD CAUTIOUSLY
TAKE PROFIT / DO NOT ENTER

Trade Quality

Current trade-grade evaluation

Score

Weighted confidence reading
Suggested Uses

Can be used for:

• Managing existing positions
• Scaling out of trades
• Holding trend positions longer
• Filtering poor continuation conditions
• Preventing emotional exits
• Avoiding lower quality entries

Works well alongside:

• Market structure
• Trend systems
• Volume Profile / POC analysis
• Supply and demand zones
• Higher timeframe bias
• Risk management systems

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("Squeeze Momentum IQ Trade Management Simplified", shorttitle="TGY SQZ IQ Management", overlay=true, max_labels_count=500)

//────────────────────────────
// Inputs
//────────────────────────────
src = input.source(close, "Source")

gSqz = "Squeeze Settings"
bbLen   = input.int(20, "BB Length", group=gSqz)
bbMult  = input.float(2.0, "BB Mult", group=gSqz)
kcLen   = input.int(20, "KC Length", group=gSqz)
kcMult  = input.float(1.5, "KC Mult", group=gSqz)
useTR   = input.bool(true, "Use True Range for KC", group=gSqz)

gMom = "Momentum Engine"
momLen = input.int(20, "Momentum Length", group=gMom)
smoothLen = input.int(5, "Momentum Smoothing", group=gMom)
emaLen = input.int(50, "EMA Length", group=gMom)

gEff = "Efficiency Filter"
erLen = input.int(20, "Efficiency Length", group=gEff)
erThreshold = input.float(0.35, "Efficiency Threshold", step=0.05, group=gEff)

gMTF = "Higher Timeframe"
htf = input.timeframe("60", "Higher Timeframe", group=gMTF)

gVisual = "Visuals"
showTable = input.bool(true, "Show Table", group=gVisual)
showHighlights = input.bool(true, "Show Vertical Highlights", group=gVisual)
tablePos = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=gVisual)
tableSize = input.string("Small", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group=gVisual)

holdColor = input.color(color.lime, "HOLD Highlight", group=gVisual)
cautionColor = input.color(color.orange, "HOLD CAUTIOUSLY Highlight", group=gVisual)
exitColor = input.color(color.red, "TAKE PROFIT / DO NOT ENTER Highlight", group=gVisual)

highlightTransparency = input.int(85, "Highlight Transparency", minval=0, maxval=100, group=gVisual)

headerBg = input.color(color.black, "Header Background", group=gVisual)
labelBg = input.color(color.rgb(20, 24, 32), "Label Background", group=gVisual)
textColor = input.color(color.white, "Text Color", group=gVisual)
holdText = input.color(color.black, "HOLD Text", group=gVisual)
cautionText = input.color(color.black, "CAUTION Text", group=gVisual)
exitText = input.color(color.white, "EXIT Text", group=gVisual)

//────────────────────────────
// Squeeze Logic
//────────────────────────────
basis = ta.sma(src, bbLen)
dev = bbMult * ta.stdev(src, bbLen)
upperBB = basis + dev
lowerBB = basis - dev

ma = ta.sma(src, kcLen)
rng = useTR ? ta.tr(true) : high - low
rangeMA = ta.sma(rng, kcLen)
upperKC = ma + rangeMA * kcMult
lowerKC = ma - rangeMA * kcMult

sqzOn = lowerBB > lowerKC and upperBB < upperKC
sqzOff = lowerBB < lowerKC and upperBB > upperKC

//────────────────────────────
// Momentum
//────────────────────────────
highestHigh = ta.highest(high, momLen)
lowestLow = ta.lowest(low, momLen)
midpoint = math.avg(highestHigh, lowestLow)
baseline = math.avg(midpoint, ta.sma(close, momLen))

rawMom = ta.linreg(src - baseline, momLen, 0)
mom = ta.ema(rawMom, smoothLen)

momUp = mom > mom[1]
momDown = mom < mom[1]

bullMom = mom > 0
bearMom = mom < 0

momentumStrengthening = bullMom and momUp or bearMom and momDown
momentumWeakening = bullMom and momDown or bearMom and momUp

//────────────────────────────
// Efficiency
//────────────────────────────
directionalMove = math.abs(close - close[erLen])
volatilityMove = math.sum(math.abs(close - close[1]), erLen)
er = volatilityMove != 0 ? directionalMove / volatilityMove : 0
efficient = er >= erThreshold

//────────────────────────────
// Trend
//────────────────────────────
ema = ta.ema(close, emaLen)
trendBull = close > ema
trendBear = close < ema

//────────────────────────────
// HTF Momentum
//────────────────────────────
f_htfMom() =>
    hHigh = ta.highest(high, momLen)
    hLow = ta.lowest(low, momLen)
    hMid = math.avg(hHigh, hLow)
    hBase = math.avg(hMid, ta.sma(close, momLen))
    ta.ema(ta.linreg(close - hBase, momLen, 0), smoothLen)

htfMom = request.security(syminfo.tickerid, htf, f_htfMom(), barmerge.gaps_off, barmerge.lookahead_off)

htfBull = htfMom > 0
htfBear = htfMom < 0

//────────────────────────────
// Trade Quality Score
//────────────────────────────
score = 0.0

score += sqzOff ? 20 : sqzOn ? 10 : 0
score += momentumStrengthening ? 25 : momentumWeakening ? 10 : 0
score += efficient ? 20 : 0
score += bullMom and htfBull or bearMom and htfBear ? 20 : 0
score += bullMom and trendBull or bearMom and trendBear ? 15 : 0

score := math.min(score, 100)

// Original-style grade
grade =
     score >= 85 ? "A+" :
     score >= 75 ? "A" :
     score >= 65 ? "B+" :
     score >= 55 ? "B" :
     score >= 45 ? "C" :
     "Below C"

//────────────────────────────
// Hold / Profit Logic
//────────────────────────────
holdState =
     score >= 75 ? "HOLD" :
     score >= 45 ? "HOLD CAUTIOUSLY" :
     "TAKE PROFIT / DO NOT ENTER"

holdBg =
     score >= 75 ? holdColor :
     score >= 45 ? cautionColor :
     exitColor

holdTxt =
     score >= 75 ? holdText :
     score >= 45 ? cautionText :
     exitText

bgcolor(showHighlights ? color.new(holdBg, highlightTransparency) : na)

//────────────────────────────
// Table
//────────────────────────────
txtSize =
     tableSize == "Tiny" ? size.tiny :
     tableSize == "Small" ? size.small :
     tableSize == "Normal" ? size.normal :
     size.large

pos =
     tablePos == "Top Left" ? position.top_left :
     tablePos == "Bottom Right" ? position.bottom_right :
     tablePos == "Bottom Left" ? position.bottom_left :
     position.top_right

var table dash = table.new(pos, 2, 4, border_width=1)

if showTable and barstate.islast
    table.cell(dash, 0, 0, "TRADE STATUS", text_color=textColor, bgcolor=headerBg, text_size=txtSize)
    table.cell(dash, 1, 0, "LIVE READING", text_color=textColor, bgcolor=headerBg, text_size=txtSize)

    table.cell(dash, 0, 1, "Action", text_color=textColor, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 1, holdState, text_color=holdTxt, bgcolor=holdBg, text_size=txtSize)

    table.cell(dash, 0, 2, "Trade Quality", text_color=textColor, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 2, grade, text_color=holdTxt, bgcolor=holdBg, text_size=txtSize)

    table.cell(dash, 0, 3, "Score", text_color=textColor, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 3, str.tostring(score, "#") + "%", text_color=holdTxt, bgcolor=holdBg, text_size=txtSize)

//────────────────────────────
// Alerts
//────────────────────────────
alertcondition(score >= 75, "HOLD", "Trade quality is A or higher. HOLD.")
alertcondition(score < 75 and score >= 45, "HOLD CAUTIOUSLY", "Trade quality is B/C range. HOLD CAUTIOUSLY.")
alertcondition(score < 45, "TAKE PROFIT / DO NOT ENTER", "Trade quality is below C. TAKE PROFIT or DO NOT ENTER.")
````
