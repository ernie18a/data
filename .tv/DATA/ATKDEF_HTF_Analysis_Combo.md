<!-- tradingview-pine-id: PUB;c1270d2c7c7a4934b36665babdc0e9e3 -->
<!-- tradingviewscripts-format: 1 -->
# ATK/DEF HTF Analysis Combo

Source: https://www.tradingview.com/script/wvSxqXhe/

## Description

# ATK/DEF HTF Analysis Combo

ATK/DEF HTF Analysis Combo is a Higher Timeframe market environment analysis framework designed to observe the broader market structure from a use-selected timeframe.

Instead of focusing only on the active chart, this indicator uses a selected Higher Timeframe as the primary reference environment and organizes several independent market measurements into one structured dashboard.

The objective is to provide a clearer view of the **broader market direction, trend condition, momentum condition, and volatility environment** through a Higher Timeframe perspective.

The indicator is designed as an analytical observation framework rather than a conventional single-condition indicator.

## 📊 Higher Timeframe Market Environment

The core of this indicator is the use of a use-selected Higher Timeframe.

The selected timeframe becomes the reference environment for the dashboard.

For example, the user may select:

* 4 Hour
* Daily
* Weekly
* Other supported  timeframes

The indicator retrieves market data from the selected timeframe and evaluates the corresponding market conditions.

This allows the active chart to be viewed in the contet of a broader market environment.

A smaller chart can contain many local price movements while the selected Higher Timeframe may still maintin a different overall structure.

The purpose of this framework is to make that broader structure visible in a compact analytical format.

# 🧭 Four-Dimensional HTF Observation

ATK/DEF HTF Analysis Combo separates the Higher Timeframe environment into four primary dimensions:

**Direction**

**Trend**

**Momentum**

**Volatility**

These dimensions are intentionally treated as independent analytical modules.

They do not represent the same characteristic of the market.

A market can have a clear directional position while momentum is neutral.

A market can have strong trend strength while volatility is relatively low.

A market can experience elevated volatility while directional structure remains mixed.

By keeping these measurements separated, the dashboard preserves more information about the current Higher Timeframe environment.

# 🎯 1. HTF Direction

The HTF Direction module evaluates the directional position of the selected Higher Timeframe.

The calculation examines the relationship between:

* HTF closing price
* EMA 8
* EMA 21
* EMA 50
* +DI
* -DI

The relationship between price and multiple EMA levels provides the primary structural classification.

The +DI and -DI relationship is then used as an additional directional component.

The module classifies the environment into several states:

* 📈 Strong Bull
* 📈 Bullish
* ↗️ Mixed Bull
* ➡️ Neutral
* ↘️ Mixed Bear
* 📉 Bearish
* 📉 Strong Bear

A Direction Score ranging from **-100 to +100** is also displayed.

The score provides a normalized representation of the directional classification used by the module.

The Direction module is not intended to represent the entire market by itself.

It describes the directional position of the selected Higher Timeframe environment.

# 📈 2. HTF Trend

The HTF Trend module examines the strength and orientation of the broader trend structure.

It uses:

* ADX
* +DI
* -DI

ADX is used to describe the strength of the prevailing directional structure, while +DI and -DI provide the directional component.

The module produces several classifications:

* 🔥 Strong Bull
* 🔥 Strong Bear
* ⚡ Bull Trend
* ⚡ Bear Trend
* 🌊 Weak Trend
* 🌀 Range

This creates a distinction between **directional position** and **trend strength**.

The Direction module asks where the market is positioned.

The Trend module asks how strongly the directional structure is expressed.

These two measurements can therefore display different conditions at the same time.

# ⚡ 3. HTF Momentum

The HTF Momentum module uses RSI to describe the current momentum condition of the selected Higher Timeframe.

The RSI range is divided into multiple states:

* 🚀 Strong Up
* ⬆️ Accelerating
* ↗️ Bullish
* ➡️ Neutral
* ↘️ Bearish
* ⬇️ Declining
* 💀 Strong Down

The purpose of this classification is to provide a more detailed view of momentum rather than reducing the entire momentum condition to a simple positive or negative value.

The module also generates a normalized Momentum Score between **-100 and +100**.

Momentum is kept independent from Direction and Trend because these characteristics can behave differently within the same market environment.

# 📊 4. HTF Volatility

The HTF Volatility module measures the relative movement environment of the selected Higher Timeframe using ATR.

The current ATR is compared with its 50-period average:

**ATR Ratio = Current ATR / Average ATR**

The result is classified into:

* 🔥 Extreme
* ⚠️ High
* 📊 Elevated
* 📊 Normal
* 😴 Low

Volatility is treated as a **non-directional measurement**.

A high volatility condition does not represent an upward or downward direction.

It describes the relative magnitude of market movement compared with its reference volatility.

This distinction allows the dashboard to separate market activity from market direction.

# 🏆 5. HTF Composite Environment

The final HTF score combines the independent Direction, Trend and Momentum scores.

The three directional components are averaged into a normalized composite value.

The Volatility condition can then modify the composite value when volatility reaches elevated levels.

The resulting score is constrained to a range between:

**-100 and +100**

The composite value is intended to provide a compact representation of the broader Higher Timeframe environment.

It does not replace the individual modules.

Instead, it provides another layer of information that can be compared with the separate Direction, Trend, Momentum and Volatility readings.

# 🔬 Independent Module Architecture

One of the main characteristics of ATK/DEF HTF Analysis Combo is its independent-module architecture.

Rather than forcing all market conditions into one calculation from the beginning, each component is evaluated separately.

### Direction

Describes the broader directional position.

### Trend

Describes the strength and orientation of the trend structure.

### Momentum

Describes the current momentum condition.

### Volatility

Describes the relative magnitude of market movement.

### Composite Environment

Provides a consolidated numerical representation of the directional modules.

This architecture allows different market characteristics to remain visible instead of hing them inside one simplified reading.

# 🌐 Broader Market Observation

The indicator is designed specifically around the idea of observing the market from a broader timeframe perspective.

The active chart represents the immediate chart environment.

The selected Higher Timeframe represents the broader reference environment.

The dashboard connects these two perspectives by displaying the selected HTF conditions directly on the active chart.

This makes it possible to examine how the current chart exists within a larger market structure.

The indicator therefore focuses on **environmental context rather than individual candle interpretation**.

# 📐 Why Higher Timeframe Data Is Used

Higher Timeframe data can provide a different structural perspective from the active chart.

For example, price movement that appears highly directional on a smaller chart may exist inside a much broader range when viewed from a larger timeframe.

Likewise, a period of relatively quiet movement on the ative chart may occur while the broader timeframe maintns a clearly defined directional structure.

The purpose of the HTF framework is to expose this broader context through a consistent set of measurements.

# 🧩 Multiple Conditions Can Coexist

The dashboard does not require every module to produce the same classification.

Different combinations are possible.

For example:

**Bullish Direction + Weak Trend + Neutral Momentum + Low Volatility**

or:

**Mixed Direction + Strong Trend + Strong Momentum + High Volatility**

or:

**Neutral Direction + Range + Neutral Momentum + Normal Volatility**

These combinations represent different market environments.

The dashboard preserves these differences instead of reducing every situation to one basic directional label.

# 📊 Scoring System

Direction, Trend and Momentum use normalized scores to represent their respective classifications.

Directional scores use a range from **-100 to +100**.

The Volatility module uses a separate non-directional scale because volatility does not inherently describe upward or downward movement.

The Composite HTF Score is normalized to remain within **-100 to +100**.

The scores are mathematical representations of the conditions defined in the script.

They should be interpreted as descriptive measurements of the selected Higher Timeframe environment.

# ⚙️ User-Defined Timeframe Configuration

The Higher Timeframe reference is **user-configurable**.

Users are expected to select and configure the timeframe that they want the dashboard to analyze.

The indicator does not assume that one particular timeframe is appropriate for every chart or every market.

Changing the HTF Resolution changes the reference environment used by the dashboard.

This is an important part of the design because the indicator is intended to allow the user to determine which broader market context should be observed.

The selected timeframe should therefore be considered part of the user's analytical configuration.

# 🖥️ Dashboard

The dashboard provides a compact display of the five main analytical sections:

### 🎯 HTF Direction

Directional classification and normalized Direction Score.

### 📈 HTF Trend

Trend classification and ADX measurement.

### ⚡ HTF Momentum

Momentum classification and RSI measurement.

### 📊 HTF Volatility

Volatility classification and ATR Ratio.

### 🏆 HTF Final Environment

Composite Higher Timeframe score and overall environmental classification.

The selected HTF resolution is also displayed in the dashboard header.

The table can be positioned on either side of the chart according to the user's preference.

# 📏 Technical Components

The indicator uses established market-data calculations including:

* EMA 8
* EMA 21
* EMA 50
* RSI 14
* ADX 14
* +DI
* -DI
* ATR 14
* 50-period average ATR

These components are processed independently before being combined into the Higher Timeframe dashboard.

The purpose of the framework is not to introduce a single new mathematical measurement, but to organize several market characteristics into a unified Higher Timeframe observation structure.

# 🧠 Analytical Concept

ATK/DEF HTF Analysis Combo approaches market observation from a broader environmental perspective.

Instead of asking only whether price is moving upward or downward, the framework separates the market into several observable characteristics:

**Where is the market positioned?**

**How strong is the directional structure?**

**What is the current momentum condition?**

**How active is the market environment?**

**How do these independent conditions relate to one another?**

This creates a multi-dimensional representation of the selected Higher Timeframe environment.

---

# ⚠️ Important Information

ATK/DEF HTF Analysis Combo is an analytical and visualization tool based on market data and mattical calculations.

The classifications and scores are generated from the relationships defined in the scrt between price, EMA, DMI, ADX, RSI and ATR.

The displayed values represent the calculated state of the selected Higher Timeframe environment at the time of observation.

They are not intended to represent certainty, probability, guarantees, or future market outcomes.

The indicator does not provide finl advice, tre instructions,  or recommendations, or capital-management guidance.

The purpose of this script is to provide a structured framework for observing the broader market environment through use-selected Higher Timeframe data.

User are responsible for selecting and configuring the timeframe parameters appropriate to their own analytical requirements.

---

## Source Code

````pine
//@version=6
indicator("ATK/DEF HTF Analysis Combo", overlay=true, max_lines_count=300, max_labels_count=300)

// ============================================
// 1. INPUT PARAMETERS
// ============================================
showHTFTable = input.bool(true, "Show HTF Analysis Table", group="Display Settings")
tablePosition = input.string("Right", "Table Position", options=["Right", "Left"], group="Display Settings")
htfResolution = input.timeframe("D", "HTF Resolution", group="HTF Settings", tooltip="Higher timeframe resolution (D=Daily, W=Weekly, 4H=4 Hour)")

// ============================================
// 2. CALCULATE INDICATORS IN CURRENT TIMEFRAME
// ============================================

// 2.1 Trend Indicators
[htfDIPlusVal, htfDIMinusVal, htfADXValue] = ta.dmi(14, 14)
htfRSIValue = ta.rsi(close, 14)
htfEMA8Value = ta.ema(close, 8)
htfEMA21Value = ta.ema(close, 21)
htfEMA50Value = ta.ema(close, 50)

// 2.2 Volatility Indicators
htfATRValue = ta.atr(14)
htfAvgATRValue = ta.sma(ta.atr(14), 50)

// ============================================
// 3. REQUEST HTF DATA
// ============================================

// 3.1 Price Data
htfClose = request.security(syminfo.tickerid, htfResolution, close)
htfHigh = request.security(syminfo.tickerid, htfResolution, high)
htfLow = request.security(syminfo.tickerid, htfResolution, low)
htfOpen = request.security(syminfo.tickerid, htfResolution, open)

// 3.2 Trend Indicators (HTF)
htfADX = request.security(syminfo.tickerid, htfResolution, htfADXValue)
htfDIPlus = request.security(syminfo.tickerid, htfResolution, htfDIPlusVal)
htfDIMinus = request.security(syminfo.tickerid, htfResolution, htfDIMinusVal)
htfRSI = request.security(syminfo.tickerid, htfResolution, htfRSIValue)
htfEMA8 = request.security(syminfo.tickerid, htfResolution, htfEMA8Value)
htfEMA21 = request.security(syminfo.tickerid, htfResolution, htfEMA21Value)
htfEMA50 = request.security(syminfo.tickerid, htfResolution, htfEMA50Value)

// 3.3 Volatility Indicators (HTF)
htfATR = request.security(syminfo.tickerid, htfResolution, htfATRValue)
htfAvgATR = request.security(syminfo.tickerid, htfResolution, htfAvgATRValue)

// ============================================
// 4. MODULE 1: HTF DIRECTION - Independent Scoring
// ============================================
htfDirection = ""
htfDirectionColor = color.white
htfDirectionScore = 0.0  // Range: -100 to 100

emaBullish = htfClose > htfEMA8 and htfClose > htfEMA21 and htfClose > htfEMA50
emaBearish = htfClose < htfEMA8 and htfClose < htfEMA21 and htfClose < htfEMA50

if emaBullish and htfDIPlus > htfDIMinus
    htfDirection := "📈 Strong Bull"
    htfDirectionColor := color.rgb(0, 255, 0)
    htfDirectionScore := 100
else if emaBullish
    htfDirection := "📈 Bullish"
    htfDirectionColor := color.rgb(100, 255, 100)
    htfDirectionScore := 75
else if emaBearish and htfDIMinus > htfDIPlus
    htfDirection := "📉 Strong Bear"
    htfDirectionColor := color.rgb(255, 0, 0)
    htfDirectionScore := -100
else if emaBearish
    htfDirection := "📉 Bearish"
    htfDirectionColor := color.rgb(255, 100, 100)
    htfDirectionScore := -75
else if htfClose > htfEMA8 and htfClose < htfEMA21
    htfDirection := "↗️ Mixed Bull"
    htfDirectionColor := color.rgb(255, 200, 0)
    htfDirectionScore := 25
else if htfClose < htfEMA8 and htfClose > htfEMA21
    htfDirection := "↘️ Mixed Bear"
    htfDirectionColor := color.rgb(255, 150, 0)
    htfDirectionScore := -25
else
    htfDirection := "➡️ Neutral"
    htfDirectionColor := color.rgb(150, 150, 150)
    htfDirectionScore := 0

// ============================================
// 5. MODULE 2: HTF TREND - Independent Scoring
// ============================================
htfTrend = ""
htfTrendColor = color.white
htfTrendScore = 0.0  // Range: -100 to 100

trendBullish = htfDIPlus > htfDIMinus
trendBearish = htfDIMinus > htfDIPlus

if htfADX > 40 and trendBullish
    htfTrend := "🔥 Strong Bull"
    htfTrendColor := color.rgb(0, 255, 0)
    htfTrendScore := 100
else if htfADX > 40 and trendBearish
    htfTrend := "🔥 Strong Bear"
    htfTrendColor := color.rgb(255, 0, 0)
    htfTrendScore := -100
else if htfADX > 25 and trendBullish
    htfTrend := "⚡ Bull Trend"
    htfTrendColor := color.rgb(100, 255, 100)
    htfTrendScore := 66
else if htfADX > 25 and trendBearish
    htfTrend := "⚡ Bear Trend"
    htfTrendColor := color.rgb(255, 100, 100)
    htfTrendScore := -66
else if htfADX > 20
    htfTrend := "🌊 Weak Trend"
    htfTrendColor := color.rgb(255, 200, 0)
    htfTrendScore := 33
else
    htfTrend := "🌀 Range"
    htfTrendColor := color.rgb(150, 150, 150)
    htfTrendScore := 0

// ============================================
// 6. MODULE 3: HTF MOMENTUM - Independent Scoring
// ============================================
htfMomentum = ""
htfMomentumColor = color.white
htfMomentumScore = 0.0  // Range: -100 to 100

if htfRSI > 75
    htfMomentum := "🚀 Strong Up"
    htfMomentumColor := color.rgb(255, 0, 0)
    htfMomentumScore := 100
else if htfRSI > 65
    htfMomentum := "⬆️ Accelerating"
    htfMomentumColor := color.rgb(255, 165, 0)
    htfMomentumScore := 75
else if htfRSI > 55
    htfMomentum := "↗️ Bullish"
    htfMomentumColor := color.rgb(0, 255, 0)
    htfMomentumScore := 50
else if htfRSI > 45
    htfMomentum := "➡️ Neutral"
    htfMomentumColor := color.rgb(150, 150, 150)
    htfMomentumScore := 0
else if htfRSI > 35
    htfMomentum := "↘️ Bearish"
    htfMomentumColor := color.rgb(255, 150, 0)
    htfMomentumScore := -50
else if htfRSI > 25
    htfMomentum := "⬇️ Declining"
    htfMomentumColor := color.rgb(255, 100, 100)
    htfMomentumScore := -75
else
    htfMomentum := "💀 Strong Down"
    htfMomentumColor := color.rgb(255, 0, 0)
    htfMomentumScore := -100

// ============================================
// 7. MODULE 4: HTF VOLATILITY - Independent Scoring
// ============================================
htfVolatilityRatio = htfATR / (htfAvgATR + 0.0001)
htfVolatility = ""
htfVolatilityColor = color.white
htfVolatilityScore = 0.0  // Range: 0 to 100 (Volatility is non-directional)

if htfVolatilityRatio > 1.8
    htfVolatility := "🔥 Extreme"
    htfVolatilityColor := color.rgb(255, 0, 0)
    htfVolatilityScore := 100
else if htfVolatilityRatio > 1.4
    htfVolatility := "⚠️ High"
    htfVolatilityColor := color.rgb(255, 165, 0)
    htfVolatilityScore := 75
else if htfVolatilityRatio > 1.0
    htfVolatility := "📊 Elevated"
    htfVolatilityColor := color.rgb(255, 200, 0)
    htfVolatilityScore := 50
else if htfVolatilityRatio > 0.6
    htfVolatility := "📊 Normal"
    htfVolatilityColor := color.rgb(0, 200, 0)
    htfVolatilityScore := 25
else
    htfVolatility := "😴 Low"
    htfVolatilityColor := color.rgb(0, 150, 255)
    htfVolatilityScore := 0

// ============================================
// 8. MODULE 5: HTF COMPOSITE ENVIRONMENT
// ============================================

// 8.1 Simple Average of Independent Scores
htfScore = (htfDirectionScore + htfTrendScore + htfMomentumScore) / 3

// 8.2 Volatility Adjustment (Risk Factor)
if htfVolatilityScore > 75
    htfScore := htfScore * 0.85  // Extreme volatility reduces confidence
else if htfVolatilityScore > 50
    htfScore := htfScore * 0.95  // High volatility slightly reduces confidence

// 8.3 Normalize score to -100 to 100
htfScore := math.min(math.max(htfScore, -100), 100)

// 8.4 Composite Environment Interpretation
htfFinalResult = ""
htfFinalColor = color.white
htfFinalBgColor = color.rgb(0, 0, 0, 80)

if htfScore > 60
    htfFinalResult := "🟢 STRONG BUY"
    htfFinalColor := color.rgb(0, 255, 0)
    htfFinalBgColor := color.rgb(0, 100, 0, 60)
else if htfScore > 35
    htfFinalResult := "🟢 BUY"
    htfFinalColor := color.rgb(100, 255, 100)
    htfFinalBgColor := color.rgb(0, 80, 0, 40)
else if htfScore > 15
    htfFinalResult := "🟡 Weak Buy"
    htfFinalColor := color.rgb(255, 200, 0)
    htfFinalBgColor := color.rgb(80, 80, 0, 40)
else if htfScore > -15
    htfFinalResult := "⚪ NEUTRAL"
    htfFinalColor := color.rgb(150, 150, 150)
    htfFinalBgColor := color.rgb(50, 50, 50, 40)
else if htfScore > -35
    htfFinalResult := "🟠 Weak Sell"
    htfFinalColor := color.rgb(255, 150, 0)
    htfFinalBgColor := color.rgb(80, 40, 0, 40)
else if htfScore > -60
    htfFinalResult := "🔴 SELL"
    htfFinalColor := color.rgb(255, 100, 100)
    htfFinalBgColor := color.rgb(80, 0, 0, 40)
else
    htfFinalResult := "🔴 STRONG SELL"
    htfFinalColor := color.rgb(255, 0, 0)
    htfFinalBgColor := color.rgb(100, 0, 0, 60)

// ============================================
// 9. HTF ANALYSIS TABLE (5 Independent Modules)
// ============================================
if showHTFTable
    tablePos = tablePosition == "Right" ? position.top_right : position.top_left
    
    var table htfTable = table.new(tablePos, 2, 6,
                                    bgcolor=color.rgb(10, 10, 25, 92),
                                    border_color=color.rgb(80, 80, 150),
                                    border_width=1, frame_width=2)
    
    // Header (Row 0)
    table.cell(htfTable, 0, 0, "📊 ATK/DEF HTF Analysis (" + htfResolution + ")", 
               text_color=color.rgb(255, 255, 255),
               text_size=size.normal,
               bgcolor=color.rgb(40, 40, 100))
    table.merge_cells(htfTable, 0, 0, 1, 0)
    
    // Row 1: HTF Direction
    table.cell(htfTable, 0, 1, "🎯 HTF Direction", 
               text_color=color.rgb(200, 200, 255),
               bgcolor=color.rgb(20, 20, 50, 90))
    table.cell(htfTable, 1, 1, htfDirection + "\nScore: " + str.tostring(htfDirectionScore, "#.0"), 
               text_color=htfDirectionColor, text_size=size.small,
               bgcolor=color.rgb(20, 20, 50, 90))
    
    // Row 2: HTF Trend
    table.cell(htfTable, 0, 2, "📈 HTF Trend", 
               text_color=color.rgb(200, 200, 255),
               bgcolor=color.rgb(30, 30, 60, 90))
    table.cell(htfTable, 1, 2, htfTrend + "\n(ADX: " + str.tostring(htfADX, "#.1") + ")", 
               text_color=htfTrendColor, text_size=size.small,
               bgcolor=color.rgb(30, 30, 60, 90))
    
    // Row 3: HTF Momentum
    table.cell(htfTable, 0, 3, "⚡ HTF Momentum", 
               text_color=color.rgb(200, 200, 255),
               bgcolor=color.rgb(20, 20, 50, 90))
    table.cell(htfTable, 1, 3, htfMomentum + "\n(RSI: " + str.tostring(htfRSI, "#.1") + ")", 
               text_color=htfMomentumColor, text_size=size.small,
               bgcolor=color.rgb(20, 20, 50, 90))
    
    // Row 4: HTF Volatility
    table.cell(htfTable, 0, 4, "📊 HTF Volatility", 
               text_color=color.rgb(200, 200, 255),
               bgcolor=color.rgb(30, 30, 60, 90))
    table.cell(htfTable, 1, 4, htfVolatility + "\n(ATR Ratio: " + str.tostring(htfVolatilityRatio, "#.2") + ")", 
               text_color=htfVolatilityColor, text_size=size.small,
               bgcolor=color.rgb(30, 30, 60, 90))
    
    // Row 5: HTF Composite Environment
    table.cell(htfTable, 0, 5, "🏆 HTF Composite", 
               text_color=color.rgb(255, 255, 200),
               text_size=size.normal,
               bgcolor=color.rgb(40, 40, 80, 90))
    table.cell(htfTable, 1, 5, htfFinalResult + "\nScore: " + str.tostring(htfScore, "#.0"), 
               text_color=htfFinalColor, text_size=size.small,
               bgcolor=htfFinalBgColor)

// ============================================
// 10. STATUS LINE DISPLAY
// ============================================
plot(htfADX, "HTF ADX", display=display.status_line, color=color.rgb(255, 200, 0))
plot(htfRSI, "HTF RSI", display=display.status_line, color=color.rgb(0, 200, 255))
plot(htfATR, "HTF ATR", display=display.status_line, color=color.rgb(255, 100, 100))
plot(htfScore, "HTF Score", display=display.status_line, color=color.rgb(0, 255, 200))
````
