# Consecutive Trend Counter [Achira Meegasthanne]

- url: https://www.tradingview.com/script/g7atFlfj-Consecutive-Trend-Counter-Achira-Meegasthanne/
- type: indicator
- pine_id: PUB;b9818553a949414499b4dd482bb05f73
- version: 1.0

## Description

[b]Consecutive Trend Counter[/b]

Consecutive Trend Counter is a multi-timeframe trend analysis indicator designed to identify and visualize sustained bullish and bearish market conditions.

The indicator compares a [b]Fast EMA[/b] with a [b]Slow WMA[/b] and counts how many consecutive bars the current trend has remained bullish or bearish.

It then combines trend conditions from multiple timeframes to identify stronger directional alignment.

[b]🔹 KEY FEATURES[/b]

[b]📈 Consecutive Trend Counter[/b]

The indicator tracks the number of consecutive bars where:

• Fast EMA > Slow WMA = Bullish
• Fast EMA < Slow WMA = Bearish

When the direction changes, the previous counter is reset and the new trend count begins.

[b]⏱️ MULTI-TIMEFRAME TREND ANALYSIS[/b]

The indicator checks trend direction across three timeframes:

• Current Chart Timeframe
• 60-Minute Timeframe
• 240-Minute Timeframe

This allows the indicator to identify when multiple timeframes are aligned in the same direction.

[b]🟢 UPTREND CONFIRMATION[/b]

An [b]UPTREND[/b] condition is displayed when:

• Current timeframe is bullish
• 60-minute trend is bullish
• 240-minute trend is bullish
• Bullish consecutive count reaches the selected threshold

The indicator displays the number of consecutive bullish bars directly on the chart.

[b]🔴 DOWNTREND CONFIRMATION[/b]

A [b]DOWNTREND[/b] condition is displayed when:

• Current timeframe is bearish
• 60-minute trend is bearish
• 240-minute trend is bearish
• Bearish consecutive count reaches the selected threshold

The indicator displays the number of consecutive bearish bars directly on the chart.

[b]💪 TREND STRENGTH[/b]

The indicator identifies stronger trends when the consecutive trend count reaches [b]30 bars or more[/b].

Strong bullish and bearish conditions receive a stronger visual indication on the chart.

[b]↔️ SIDEWAYS MARKET DETECTION[/b]

When all timeframes are not aligned, the indicator can classify the market as:

• SIDEWAYS
• SIDEWAYS UP
• SIDEWAYS BEAR

This helps distinguish between strong directional conditions and periods where the market lacks complete multi-timeframe alignment.

[b]⚙️ CUSTOMIZABLE SETTINGS[/b]

The indicator provides several user-controlled settings:

• Up Color
• Down Color
• Plot Moving Averages
• Fast Moving Average Length
• Slow Moving Average Length
• Trend Threshold

The default Fast Moving Average is [b]9 EMA[/b] and the default Slow Moving Average is [b]36 WMA[/b].

[b]📊 MOVING AVERAGE VISUALIZATION[/b]

You can optionally display the Fast EMA and Slow WMA directly on the chart.

This makes it easier to visually understand how the trend counter determines bullish and bearish conditions.

[b]🎯 SIGNAL VISUALIZATION[/b]

When all monitored timeframes are aligned:

• Bullish conditions are highlighted with bullish bar coloring
• Bearish conditions are highlighted with bearish bar coloring
• Bullish markers are displayed below the bar
• Bearish markers are displayed above the bar

This provides a quick visual way to identify periods of stronger directional alignment.

[b]🧠 HOW IT WORKS[/b]

[b]1. Calculate Moving Averages[/b]

The indicator calculates a Fast EMA and Slow WMA.

[b]2. Determine Trend Direction[/b]

Fast EMA above Slow WMA indicates bullish conditions.

Fast EMA below Slow WMA indicates bearish conditions.

[b]3. Count Consecutive Bars[/b]

The indicator counts how many consecutive bars remain in the current direction.

[b]4. Check Multiple Timeframes[/b]

The same trend relationship is evaluated on the current chart timeframe, 60-minute timeframe, and 240-minute timeframe.

[b]5. Confirm Alignment[/b]

When all monitored timeframes agree and the consecutive count reaches the selected threshold, the indicator identifies a stronger trend condition.

[b]6. Classify Market Condition[/b]

If the timeframes are not fully aligned, the indicator can display a sideways condition instead.

[b]📌 TREND LOGIC[/b]

[b]Bullish:[/b]

Fast EMA > Slow WMA

[b]Bearish:[/b]

Fast EMA < Slow WMA

[b]Strong Bullish:[/b]

Bullish consecutive count ≥ 30 bars

[b]Strong Bearish:[/b]

Bearish consecutive count ≥ 30 bars

[b]⚠️ IMPORTANT DISCLAIMER[/b]

This indicator is designed for [b]market analysis and educational purposes[/b].

Trend alignment and consecutive-bar counts should not be considered guaranteed buy or sell signals.

Market conditions can change quickly, and trend indicators may react after price movement has already occurred.

Always perform your own analysis, apply proper risk management, and test the indicator thoroughly before using it with real capital.

[b]Track the trend. Measure its persistence. Confirm the direction.[/b]

## Source Code

````pine

//@version=6
indicator("Consecutive Trend Counter", overlay=true)

// Colors
green = input(color.new(#0df1c6, 20), 'Up Color')
red = input(#871ee9, 'Dn Color')
//User Inputs
bool plot_ma = input.bool(defval = false, title = "Plot Moving Averages?")
int fast_ = input.int(defval = 9, title = "Fast Moving Average")
int slow_ = input.int(defval = 36, title = "Slow Moving Average")

// Input for threshold
thresholdCount = input.int(3, "Trend Threshold", minval=1, tooltip = "How many bard must the moving average be trending down?")

// Function to calculate trend counts
trendCalc(srcClose) =>
    float fastMA = ta.ema(srcClose, fast_)
    float slowMA = ta.wma(srcClose, slow_)
    bool isBullish = fastMA > slowMA
    bool isBearish = fastMA < slowMA
    [isBullish, isBearish]

// Get current timeframe trends
[isBullish, isBearish] = trendCalc(close)

// Get 4h trends
[isBullish4h, isBearish4h] = request.security(syminfo.tickerid, "60", trendCalc(close))

// Get daily trends
[isBullishD, isBearishD] = request.security(syminfo.tickerid, "240", trendCalc(close))

// Initialize consecutive counters
var int bullishCount = 0
var int bearishCount = 0

// Initialize label variables
var label bullLabel = na
var label bearLabel = na
var label sideLabel = na

// Update consecutive counts
if isBullish
    bullishCount := bullishCount + 1
    bearishCount := 0  // Reset bearish count
else if isBearish
    bearishCount := bearishCount + 1
    bullishCount := 0  // Reset bullish count
else
    // Reset both if neither condition is met
    bullishCount := 0
    bearishCount := 0

// Plot MAs
plot(plot_ma ? ta.ema(close, fast_) : na, "Fast EMA", color=green)
plot(plot_ma ? ta.wma(close, slow_) : na, "Slow WMA", color=red)

// Delete previous labels
if not na(bullLabel)
    label.delete(bullLabel)
if not na(bearLabel)
    label.delete(bearLabel)
if not na(sideLabel)
    label.delete(sideLabel)

// Check for all timeframe alignment
bool allBullish = isBullish and isBullish4h and isBullishD and bullishCount >= thresholdCount
bool allBearish = isBearish and isBearish4h and isBearishD and bearishCount >= thresholdCount

//check strength
strong_downtrend = (bearishCount >= 30)
strong_uptrend = (bullishCount >= 30)

// Create new labels based on consecutive counts with specified parameters
if allBearish and barstate.islast
    bearLabel := label.new(
         x=bar_index + 5,
         y=close,
         text="DOWNTREND
         (" + str.tostring(bearishCount) + " bars)",
         color= strong_downtrend ?  red:color.new(red, 20),
         textcolor=color.new(color.white, 0),
         style=label.style_label_left)
else if allBullish and barstate.islast
    bullLabel := label.new(
         x=bar_index + 5,
         y=close,
         text="UPTREND (" + str.tostring(bullishCount) + " bars)",
         color=strong_uptrend ? green:color.new(green, 20),
         textcolor=color.new(color.black, 0),
         style=label.style_label_left)
else if not allBullish and not allBearish and (bearishCount >= thresholdCount) and barstate.islast
    sideLabel := label.new(
         x=bar_index + 5,
         y=close,
         text="SIDEWAYS BEAR (DOWN" + str.tostring(math.max(bearishCount, bullishCount)) + " bars)",
         color=color.new(red, 80),
         textcolor=color.white,
         style=label.style_label_left)
else if not allBullish and not allBearish and (bullishCount >= thresholdCount) and barstate.islast
    sideLabel := label.new(
         x=bar_index + 5,
         y=close,
         text="SIDEWAYS (UP " + str.tostring(math.max(bearishCount, bullishCount)) + " bars)",
         color=color.new(green,80),
         textcolor=color.white,
         style=label.style_label_left)
else if not allBullish and not allBearish and (bullishCount <= thresholdCount and bearishCount <= thresholdCount) and barstate.islast
    sideLabel := label.new(
         x=bar_index + 5,
         y=close,
         text="SIDEWAYS",// (" + str.tostring(math.max(bearishCount, bullishCount)) + " bars)",
         color=color.new(color.gray, 50),
         textcolor=color.white,
         style=label.style_label_left)
// Color bars and plot arrows only when all timeframes align
barcolor(allBearish ? color.new(red, 0) : allBullish ? green : na)

plotshape(allBearish ,text = 'S',textcolor = color.white, style=shape.labeldown, location=location.abovebar, color=color.new(red, 65), size=size.tiny)
plotshape(allBullish ,text = 'B' ,textcolor = color.white, style=shape.labelup, location=location.belowbar, color=color.new(green,65), size=size.tiny)
````
