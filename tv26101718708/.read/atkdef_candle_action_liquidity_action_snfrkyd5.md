# ATK/DEF CANDLE ACTION + LIQUIDITY ACTION

- url: https://www.tradingview.com/script/snfRkYD5/
- type: indicator
- pine_id: PUB;46c9527cb541465d8a7365191b5ac3f3
- version: 1.0

## Description

Overview

ATK/DEF Candle Action + Liquidity Action is a price action analysis framework designed to study market behavior through a combination of candlestick analysis, momentum measurement, liquidity interaction, and market structure observation.

The framework is based on the ATK/DEF concept, which represents the changing balance between directional price pressure and defensive market reactions.

* **ATK (Attack)** represents periods where directional momentum expands and price pressure becomes more dominant.
* **DEF (Defense)** represents periods where price pressure weakens, liquidity is tested, or market balance develops.

This indicator does not attempt to predict future price movement. Instead, it provides a structured visualization of current market conditions and historical price behavior.

---

# Core Components

## 1. Momentum Strength Framework

The indicator combines two momentum-based measurements into a normalized 0–100 strength score.

### CHO Momentum Component

The CHO component evaluates the relationship between short-term and longer-term price momentum.

The calculation compares:

* Fast momentum change
* Slow momentum change

This helps visualize whether recent price movement is accelerating or losing strength.

### Momentum Component

The Momentum component measures the rate of price change over a selected period.

The raw momentum value is normalized using historical values to create a consistent interpretation range.

### Composite Score

The final score combines:

* CHO Component: 60%
* Momentum Component: 40%

The score provides a visual representation of relative market pressure.

Higher values indicate stronger upward price pressure.

Lower values indicate stronger downward price pressure.

Middle values indicate a more balanced market condition.

---

# 2. Market State Classification

The State system converts the composite score into different market conditions:

### Strong

Higher momentum expansion and stronger directional pressure.

### Up

Positive momentum conditions with upward pressure.

### Range

Balanced conditions where neither side shows clear dominance.

### Down

Negative momentum conditions with downward pressure.

### Crash

Strong downside pressure and aggressive selling conditions.

The State classification is designed to help users quickly understand the current price environment.

---

# 3. Trend Context Framework

The Trend system evaluates the relationship between momentum conditions and market structure.

It identifies whether the market environment is:

* Bullish
* Bearish
* Neutral
* Range-bound

Range detection considers factors such as:

* Price channel width
* Volatility conditions
* Momentum balance

This allows users to distinguish directional movement from consolidation phases.

---

# 4. Liquidity Action System

The Liquidity Action module focuses on how price interacts with important high and low reference areas.

Liquidity levels are calculated using recent price extremes and displayed as visual reference zones.

The system identifies:

### Liquidity Sweep Up

Price moves above a previous high area but closes back below the level.

This represents a failed upward expansion and highlights a potential liquidity reaction area.

### Liquidity Sweep Down

Price moves below a previous low area but closes back above the level.

This represents a failed downward expansion and highlights a potential liquidity reaction area.

### High Activity Candles

The system also identifies candles with:

* Above-average volume
* Larger-than-normal price range

These candles highlight periods of increased market participation.

---

# 5. Candlestick Action Framework

The indicator analyzes multiple candlestick structures, including:

* Bullish Engulfing
* Bearish Engulfing
* Hammer
* Shooting Star
* Inside Bar
* Pin Bar
* Morning Star
* Evening Star
* Large Body Candles
* Doji

Each pattern is assigned a predefined classification level for visual interpretation.

The classification is designed to help users compare different candle behaviors and their relationship with current market conditions.

---

# Visual Elements

The indicator displays:

* Market strength score
* State classification
* Trend context
* Liquidity levels
* Liquidity interaction labels
* Candlestick pattern markers
* Market condition information panel

All visual elements are designed for analytical observation.

---

# Analytical Workflow

A suggested analysis process:

### 1. Observe Market State

Identify whether current price pressure is expanding, weakening, or balanced.

### 2. Evaluate Trend Context

Compare momentum conditions with broader market structure.

### 3. Observe Liquidity Interaction

Study how price reacts around important high and low areas.

### 4. Analyze Candlestick Behavior

Use candle patterns as additional information about price reactions.

### 5. Compare Multiple Timeframes

Higher timeframes provide broader context, while lower timeframes show shorter-term price behavior.

---

# Technical Concept

ATK/DEF is a visual framework created to describe the interaction between:

* Price momentum
* Candlestick behavior
* Liquidity reactions
* Market structure

The purpose is to transform complex price movement into a structured analytical view.

---

# Limitations

* The indicator is based on historical price data.
* Market conditions can change rapidly.
* No indicator can guarantee future market behavior.
* Users should evaluate information independently and combine it with their own analysis methods.

---

# Disclaimer

This indicator is provided for technical analysis and educational purposes only.

It does not constitute financial advice, investment advice, or trading recommendations.

The author does not guarantee the accuracy or completeness of calculations or interpretations.

All decisions made using this tool remain the responsibility of the user.

## Source Code

````pine
//@version=6
indicator("📊 ATK/DEF CANDLE ACTION + LIQUIDITY ACTION", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================
// MODULE 1: INPUT PARAMETERS
// ============================================================

int cho_fast = input.int(3, "CHO Fast", minval=1, maxval=20)
int cho_slow = input.int(10, "CHO Slow", minval=1, maxval=50)
int mom_len = input.int(10, "Momentum Period", minval=1, maxval=50)
int liqLookback = input.int(20, "Liquidity Lookback", minval=5, maxval=100)

bool showTable = input.bool(true, "Show Info Table", group="Display")
bool showLiquidity = input.bool(true, "Show Liquidity Levels", group="Display")
bool showLabels = input.bool(true, "Show Signal Labels on Chart", group="Display")


// ============================================================
// MODULE 2: CHO + MOMENTUM SCORE CALCULATION
// ============================================================

float fastMom = ta.change(close, cho_fast)
float slowMom = ta.change(close, cho_slow)
float choValue = slowMom != -fastMom ? (fastMom - slowMom) / (fastMom + slowMom) * 100 : 0
float choScore = (choValue + 100) / 200 * 100

float momValue = ta.mom(close, mom_len)
float momHigh = ta.highest(momValue, 100)
float momLow = ta.lowest(momValue, 100)
float momScore = momHigh != momLow ? (momValue - momLow) / (momHigh - momLow) * 100 : 50

float score = choScore * 0.6 + momScore * 0.4


// ============================================================
// MODULE 3: STATE + RANGE MARKET DETECTION
// ============================================================

float atrVal = ta.atr(14)
float avgRange20 = ta.sma(high - low, 20)
float rangeWidth = (ta.highest(high, 20) - ta.lowest(low, 20)) / atrVal
float rangeRatio = (high - low) / avgRange20

// ---- State (based on score) ----
string stateText = ""
color stateColor = color.white

if score >= 70
    stateText := "🚀 Strong"
    stateColor := color.green
else if score >= 55
    stateText := "📈 Up"
    stateColor := color.green
else if score >= 45
    stateText := "➖ Range"
    stateColor := color.orange
else if score >= 30
    stateText := "📉 Down"
    stateColor := color.red
else
    stateText := "🔥 Crash"
    stateColor := color.red

// ---- Range Market ----
bool isRange = false

if rangeWidth < 3.0 and score > 30 and score < 70
    isRange := true
else if rangeWidth < 2.5 and score > 35 and score < 65
    isRange := true
else if rangeRatio < 0.8 and score > 40 and score < 60
    isRange := true

// ---- Trend (integrates Range + Score) ----
string trendText = ""
color trendColor = color.white

if isRange
    trendText := "🔁 Range"
    trendColor := color.yellow
else if score >= 70
    trendText := "🔥 Strong Bullish"
    trendColor := color.green
else if score >= 55
    trendText := "📈 Bullish"
    trendColor := color.green
else if score >= 45
    trendText := "➖ Neutral"
    trendColor := color.gray
else if score >= 30
    trendText := "📉 Bearish"
    trendColor := color.red
else
    trendText := "🔥 Strong Bearish"
    trendColor := color.red

float rangeHigh = ta.highest(high, 20)
float rangeLow = ta.lowest(low, 20)


// ============================================================
// MODULE 4: LIQUIDITY DETECTION
// ============================================================

float liqHigh = ta.highest(high, liqLookback)
float liqLow = ta.lowest(low, liqLookback)

bool sweepHigh = high > liqHigh[1] and close < liqHigh[1]
bool fakeBreakout = sweepHigh

bool sweepLow = low < liqLow[1] and close > liqLow[1]
bool fakeBreakdown = sweepLow

float avgVolume = ta.sma(volume, 20)
float avgRangeVol = ta.sma(high - low, 20)
bool highVolumeCandle = volume > avgVolume * 1.5
bool wideRangeCandle = (high - low) > avgRangeVol * 1.5
bool liquidityCandle = highVolumeCandle and wideRangeCandle


// ============================================================
// MODULE 5: K-LINE PATTERN RISK
// ============================================================

bool isBullish = close > open
bool isBearish = close < open
float body = math.abs(close - open)
float totalRange = high - low
float upperWick = high - math.max(close, open)
float lowerWick = math.min(close, open) - low

string patternName = ""
color patternColor = color.white
float patternRisk = 0.0

if isBullish and close > open[1] and open < close[1]
    patternName := "Bull Engulf"
    patternColor := color.green
    patternRisk := 20.0

else if isBearish and close < open[1] and open > close[1]
    patternName := "Bear Engulf"
    patternColor := color.red
    patternRisk := 20.0

else if lowerWick > body * 2 and upperWick < body * 0.3 and totalRange > 0
    patternName := "Hammer"
    patternColor := color.green
    patternRisk := 25.0

else if upperWick > body * 2 and lowerWick < body * 0.3 and totalRange > 0
    patternName := "Shooting Star"
    patternColor := color.red
    patternRisk := 45.0

else if high <= high[1] and low >= low[1]
    patternName := "Inside Bar"
    patternColor := color.orange
    patternRisk := 15.0

else if (lowerWick > body * 2 or upperWick > body * 2) and body < totalRange * 0.3
    patternName := "Pin Bar"
    patternColor := color.blue
    patternRisk := 40.0

else if isBearish[2] and math.abs(close[1] - open[1]) <= (high[1] - low[1]) * 0.1 and isBullish and close > (open[2] + close[2]) / 2
    patternName := "Morning Star"
    patternColor := color.green
    patternRisk := 15.0

else if isBullish[2] and math.abs(close[1] - open[1]) <= (high[1] - low[1]) * 0.1 and isBearish and close < (open[2] + close[2]) / 2
    patternName := "Evening Star"
    patternColor := color.red
    patternRisk := 65.0

else if body > atrVal * 0.8 and isBullish
    patternName := "Large Body ↑"
    patternColor := color.green
    patternRisk := 20.0

else if body > atrVal * 0.8 and isBearish
    patternName := "Large Body ↓"
    patternColor := color.red
    patternRisk := 20.0

else if math.abs(close - open) <= (high - low) * 0.1
    patternName := "Doji"
    patternColor := color.yellow
    patternRisk := 50.0

else
    patternName := "None"
    patternColor := color.gray
    patternRisk := 0.0


// ============================================================
// MODULE 6: LIQUIDITY LINES
// ============================================================

var line liqHighLine = na
var line liqLowLine = na
var label liqHighLabel = na
var label liqLowLabel = na
var label sweepLabel = na

if showLiquidity and barstate.islast
    line.delete(liqHighLine)
    line.delete(liqLowLine)
    label.delete(liqHighLabel)
    label.delete(liqLowLabel)
    label.delete(sweepLabel)
    
    liqHighLine := line.new(
        x1=bar_index - liqLookback,
        y1=liqHigh,
        x2=bar_index,
        y2=liqHigh,
        color=color.new(color.red, 40),
        style=line.style_dashed,
        width=1,
        extend=extend.right
    )
    liqHighLabel := label.new(
        x=bar_index,
        y=liqHigh,
        text="Liq High",
        color=color.rgb(0,0,0, 0),
        textcolor=color.red,
        style=label.style_label_left,
        size=size.tiny
    )
    
    liqLowLine := line.new(
        x1=bar_index - liqLookback,
        y1=liqLow,
        x2=bar_index,
        y2=liqLow,
        color=color.new(color.green, 40),
        style=line.style_dashed,
        width=1,
        extend=extend.right
    )
    liqLowLabel := label.new(
        x=bar_index,
        y=liqLow,
        text="Liq Low",
        color=color.rgb(0,0,0, 0),
        textcolor=color.green,
        style=label.style_label_left,
        size=size.tiny
    )
    
    if fakeBreakout
        sweepLabel := label.new(
            x=bar_index,
            y=high + atrVal * 0.8,
            text="⚡ Fake Breakout",
            color=color.rgb(0,0,0, 0),
            textcolor=color.rgb(255,80,80),
            style=label.style_label_down,
            size=size.small
        )
    else if fakeBreakdown
        sweepLabel := label.new(
            x=bar_index,
            y=low - atrVal * 0.8,
            text="⚡ Fake Breakdown",
            color=color.rgb(0,0,0, 0),
            textcolor=color.rgb(80,255,80),
            style=label.style_label_up,
            size=size.small
        )


// ============================================================
// MODULE 7: INFO TABLE
// ============================================================

if showTable and barstate.islast
    var table infoTable = table.new(position.top_right, columns=2, rows=8, bgcolor=color.rgb(10,10,30, 90), border_color=color.rgb(60,60,120), border_width=2)
    
    table.cell(infoTable, 0, 0, " 📊 ATK/DEF CANDLE + LIQ ", text_color=color.rgb(200,200,255), bgcolor=color.rgb(40,40,100), text_size=size.normal)
    table.cell(infoTable, 1, 0, "", bgcolor=color.rgb(40,40,100))
    
    string scoreText = str.tostring(score, "#.#") + "%"
    color scoreColor = score >= 70 ? color.rgb(0,255,100) : score >= 40 ? color.rgb(255,200,50) : color.rgb(255,50,50)
    table.cell(infoTable, 0, 1, " CHO Score", text_color=color.rgb(180,180,200), text_size=size.small, bgcolor=color.rgb(20,20,50))
    table.cell(infoTable, 1, 1, scoreText, text_color=scoreColor, text_size=size.small, bgcolor=color.rgb(20,20,50))
    
    color stateBgColor = stateColor == color.green ? color.rgb(20,60,20) : stateColor == color.red ? color.rgb(60,20,20) : stateColor == color.orange ? color.rgb(60,60,20) : color.rgb(30,30,30)
    table.cell(infoTable, 0, 2, " State", text_color=color.rgb(180,180,200), text_size=size.small, bgcolor=color.rgb(20,20,50))
    table.cell(infoTable, 1, 2, stateText, text_color=stateColor, text_size=size.small, bgcolor=stateBgColor)
    
    color trendBgColor = isRange ? color.rgb(60,60,20) : trendColor == color.green ? color.rgb(20,60,20) : trendColor == color.red ? color.rgb(60,20,20) : color.rgb(30,30,30)
    table.cell(infoTable, 0, 3, " Trend", text_color=color.rgb(180,180,200), text_size=size.small, bgcolor=color.rgb(20,20,50))
    table.cell(infoTable, 1, 3, trendText, text_color=trendColor, text_size=size.small, bgcolor=trendBgColor)
    
    string liqText = fakeBreakout ? "⚡ Fake Breakout" : fakeBreakdown ? "⚡ Fake Breakdown" : liquidityCandle ? "💧 High Volume" : "● Normal"
    color liqColor = fakeBreakout ? color.rgb(255,80,80) : fakeBreakdown ? color.rgb(80,255,80) : liquidityCandle ? color.rgb(255,255,100) : color.rgb(150,150,150)
    color liqBg = fakeBreakout ? color.rgb(60,20,20) : fakeBreakdown ? color.rgb(20,60,20) : liquidityCandle ? color.rgb(60,60,20) : color.rgb(20,20,50)
    table.cell(infoTable, 0, 4, " Liquidity", text_color=color.rgb(180,180,200), text_size=size.small, bgcolor=color.rgb(20,20,50))
    table.cell(infoTable, 1, 4, liqText, text_color=liqColor, text_size=size.small, bgcolor=liqBg)
    
    string patternDisplay = patternName != "None" ? patternName : "None"
    color patternBg = patternName != "None" ? color.rgb(40,40,60) : color.rgb(20,20,50)
    table.cell(infoTable, 0, 5, " Pattern", text_color=color.rgb(180,180,200), text_size=size.small, bgcolor=color.rgb(20,20,50))
    table.cell(infoTable, 1, 5, patternDisplay, text_color=patternName != "None" ? patternColor : color.rgb(100,100,100), text_size=size.small, bgcolor=patternBg)
    
    string riskText = patternName != "None" ? str.tostring(patternRisk, "#.#") + "%" : "0%"
    color riskColor = patternRisk <= 25 ? color.rgb(0,255,100) : patternRisk <= 50 ? color.rgb(255,200,50) : color.rgb(255,50,50)
    color riskBg = patternRisk <= 25 ? color.rgb(20,60,30) : patternRisk <= 50 ? color.rgb(60,60,20) : color.rgb(60,20,20)
    table.cell(infoTable, 0, 6, " Risk Level", text_color=color.rgb(180,180,200), text_size=size.small, bgcolor=color.rgb(20,20,50))
    table.cell(infoTable, 1, 6, riskText, text_color=riskColor, text_size=size.small, bgcolor=riskBg)
    
    string rangeText = isRange ? "🔁 Range Detected" : "◆ Trending"
    color rangeColor = isRange ? color.rgb(255,255,100) : color.rgb(100,200,255)
    color rangeBg = isRange ? color.rgb(60,60,20) : color.rgb(20,40,60)
    table.cell(infoTable, 0, 7, " Market", text_color=color.rgb(180,180,200), text_size=size.small, bgcolor=color.rgb(20,20,50))
    table.cell(infoTable, 1, 7, rangeText, text_color=rangeColor, text_size=size.small, bgcolor=rangeBg)


// ============================================================
// MODULE 8: AUTO-DELETE LABELS (ONLY LAST 10 BARS)
// ============================================================

var label[] labelArray = array.new_label()

f_addLabel(x, y, txt, col, style, sz) =>
    label lbl = label.new(x, y, txt, color=color.rgb(0,0,0,0), textcolor=col, style=style, size=sz)
    array.push(labelArray, lbl)
    while array.size(labelArray) > 10
        label.delete(array.shift(labelArray))

if showLabels and barstate.isconfirmed and bar_index >= last_bar_index - 10
    color choCol = score >= 70 ? color.rgb(0,255,100) : score >= 40 ? color.rgb(255,200,50) : color.rgb(255,50,50)
    f_addLabel(bar_index, high + atrVal * 0.35, "CHO: " + str.tostring(score, "#.#") + "%", choCol, label.style_none, size.tiny)
    
    f_addLabel(bar_index, high + atrVal * 0.05, stateText, stateColor, label.style_none, size.tiny)
    
    f_addLabel(bar_index, low - atrVal * 0.35, trendText, trendColor, label.style_none, size.tiny)
    
    if fakeBreakout
        f_addLabel(bar_index, high + atrVal * 0.9, "⚡ Fake Breakout", color.rgb(255,80,80), label.style_none, size.small)
    
    if fakeBreakdown
        f_addLabel(bar_index, low - atrVal * 0.9, "⚡ Fake Breakdown", color.rgb(80,255,80), label.style_none, size.small)
    
    if liquidityCandle and not fakeBreakout and not fakeBreakdown
        f_addLabel(bar_index, high + atrVal * 0.25, "💧 High Vol", color.rgb(255,255,100), label.style_none, size.tiny)
    
    if patternName != "None"
        string riskSymbol = patternRisk <= 25 ? "🟢" : patternRisk <= 50 ? "🟡" : "🔴"
        f_addLabel(bar_index, high + atrVal * 0.6, patternName + " " + riskSymbol + " " + str.tostring(patternRisk, "#.#") + "%", patternColor, label.style_none, size.tiny)
    
    if isRange
        f_addLabel(bar_index, low - atrVal * 0.6, "🔁 Range", color.rgb(255,255,100), label.style_none, size.tiny)
    
    if score > score[1]
        f_addLabel(bar_index, high + atrVal * 0.9, "▲", color.rgb(0,255,100), label.style_none, size.tiny)
    else if score < score[1]
        f_addLabel(bar_index, high + atrVal * 0.9, "▼", color.rgb(255,50,50), label.style_none, size.tiny)


// ============================================================
// MODULE 9: RANGE BOX
// ============================================================

var box rangeBox = na

if showLiquidity and barstate.islast
    box.delete(rangeBox)
    if isRange
        rangeBox := box.new(
            left=bar_index - 10,
            top=rangeHigh,
            right=bar_index,
            bottom=rangeLow,
            bgcolor=color.new(color.yellow, 8),
            border_color=color.new(color.yellow, 30),
            border_width=1
        )
````
