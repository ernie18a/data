<!-- tradingview-pine-id: PUB;cd630e424fe2437d87c922d2c1499872 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Weighted Adaptive Moving Average

Source: https://www.tradingview.com/script/gEBA8gGn-Weighted-Adaptive-Moving-Average-Achira-Meegasthanne/

## Description

Weighted Adaptive Moving Average

Weighted Adaptive Moving Average is an adaptive trend-following indicator designed to adjust its responsiveness according to market movement and price efficiency.

The indicator combines an Efficiency Ratio, adaptive moving average calculation, dynamic price deviation, ATR-based trend analysis, and bullish/bearish flow detection to create a responsive trend line and visual market direction.

🔹 KEY FEATURES

📈 ADAPTIVE MOVING AVERAGE

The indicator uses an adaptive moving average that dynamically changes its behavior according to the relationship between price movement and total price movement over the selected length.

When price movement is more directional, the moving average can respond more efficiently to changes in price.

⚙️ CUSTOMIZABLE SETTINGS

The indicator provides the following settings:

• Sensitivity
• Length
• Source

The default Length is 14, while the default Sensitivity is 2.5.

📊 EFFICIENCY RATIO

The adaptive calculation uses an Efficiency Ratio based on:

• Net price change over the selected length
• Sum of absolute price changes over the same period

This allows the moving average to adapt according to the efficiency of current price movement.

🎯 DYNAMIC PRICE ADJUSTMENT

The indicator calculates a dynamic deviation using cumulative price movement and the selected Sensitivity.

This adjustment allows the adaptive moving average to respond to significant price movement while filtering smaller price fluctuations.

📈 ADAPTIVE TREND LINE

The main moving average is displayed as a step-style trend line.

Its color changes according to the detected trend condition:

• Bullish
• Bearish
• Flat

This provides a simple visual representation of the current adaptive trend.

🟢 BULLISH FLOW

Bullish Flow becomes active when the adaptive moving average is rising.

When Bullish Flow is active:

• The trend area uses the bullish color
• Price bars are colored bullish
• The indicator can generate a bullish transition label

🔴 BEARISH FLOW

Bullish Flow becomes inactive when the adaptive moving average is falling.

When Bearish Flow is active:

• The trend area uses the bearish color
• Price bars are colored bearish
• The indicator can generate a bearish transition label

📐 ATR-BASED TREND ANALYSIS

The indicator uses a 14-period ATR to measure price movement and normalize the slope of the adaptive moving average.

The relationship between the moving average slope and ATR is used to determine whether the market is showing stronger directional movement or a flatter condition.

📊 TREND CONDITIONS

The indicator classifies the adaptive moving average into three conditions:

UP

The adaptive moving average is moving strongly in the upward direction according to the configured trend threshold.

DOWN

The adaptive moving average is moving strongly in the downward direction according to the configured trend threshold.

FLAT

The adaptive moving average does not meet the required upward or downward threshold.

🎨 DYNAMIC TREND AREA

The indicator creates an upper and lower adaptive band around the main moving average.

The area between these bands is filled according to the current Bullish Flow:

• Bullish Flow = Bullish shaded area
• Bearish Flow = Bearish shaded area

This provides a visual representation of the current market flow.

🕯️ BAR COLORING

Chart candles are automatically colored according to the current Bullish Flow.

• Bullish Flow = Bullish candle color
• Bearish Flow = Bearish candle color

This makes the prevailing market direction easy to identify at a glance.

🎯 TREND TRANSITION LABELS

The indicator creates labels when Bullish Flow changes direction.

BUY TRANSITION

A bullish transition occurs when Bullish Flow changes from bearish to bullish.

The indicator displays a label below the candle containing the current low value.

SELL TRANSITION

A bearish transition occurs when Bullish Flow changes from bullish to bearish.

The indicator displays a label above the candle containing the current high value.

🧠 HOW IT WORKS

1. Calculate Price Efficiency

The indicator measures net price movement relative to total absolute price movement.

2. Calculate Adaptive Average

The Efficiency Ratio is used to create an adaptive moving average.

3. Apply Dynamic Deviation

A sensitivity-based deviation is calculated from cumulative price movement.

4. Adjust the Moving Average

The adaptive calculation incorporates the dynamic deviation to make the moving average responsive to significant price movement.

5. Analyze Moving Average Slope

The indicator compares the current adaptive moving average with its previous value.

6. Apply ATR Normalization

The moving average movement is evaluated relative to ATR to determine the current trend condition.

7. Determine Bullish or Bearish Flow

The direction of the adaptive moving average determines the current Bullish Flow state.

8. Display the Trend

The indicator visualizes the trend using the adaptive line, shaded area, bar colors, and transition labels.

📌 CORE CONCEPT

Price Efficiency → Adaptive Moving Average → Dynamic Deviation → ATR Trend Analysis → Bullish/Bearish Flow → Visual Trend Confirmation

⚠️ IMPORTANT DISCLAIMER

This indicator is designed for market analysis and educational purposes.

The adaptive moving average, trend conditions, Bullish Flow, Bearish Flow, and transition labels should not be considered guaranteed buy or sell signals.

Moving averages are reactive tools and market conditions can change quickly.

Always perform your own analysis, use proper risk management, and thoroughly test the indicator before using it with real capital.

Adapt to the market. Follow the flow. Understand the trend.

---

## Source Code

````pine
//@version=6
indicator('Weighted Adaptive Moving Average', overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

moneyBiasValue = input(2.5, 'Sensitivity')
length = input(14, 'Length')
gamma = moneyBiasValue
src = input(close)
fill_width = 0.2

er = math.abs(ta.change(src, length)) / math.sum(math.abs(ta.change(src)), length)

ama(x) =>
    a = 0.0
    a := er * x + (1 - er) * nz(a[1], x)
    a

ma = 0.0
d = ta.cum(math.abs(src - nz(ma[1], src))) / bar_index * gamma
ma := ama(ama(src > nz(ma[1], src) + d ? src + d : src < nz(ma[1], src) - d ? src - d : nz(ma[1], src)))

adjusted_d = d * fill_width
upma = ma + adjusted_d
downma = ma - adjusted_d

css = ma > ma[1] ? #00db6a : ma < ma[1] ? #ff1a22 : na

var bool BullishFlow = false

if ma > ma[1]
    BullishFlow := true
    BullishFlow
else if ma < ma[1]
    BullishFlow := false
    BullishFlow

TrendThreshold = 0.02
//================ SMOOTH WEIGHTS =================
atrBase = ta.atr(14)
tilt = (ma - ma[1]) / (0.1 * atrBase)

Up = tilt < TrendThreshold * -1
Down = tilt > TrendThreshold
Flat = not Up and not Down

Green = color.new(#0df1c6, 20)
Red = #871ee9

plot(ma, color = Up ? Green : Down ? Red : color.gray, linewidth = 2, style = plot.style_stepline, editable = false)
p1 = plot(upma, color = Green)
p2 = plot(downma, color = Red)
fill(p1, p2, color = BullishFlow ? color.new(Green, 80) : color.new(Red, 80))

barcolor(BullishFlow ? Green : Red)

y1 = low - ta.atr(30) * 4
y2 = high + ta.atr(30) * 4
buy = BullishFlow and BullishFlow != BullishFlow[1] ? label.new(bar_index, y1, 'Low' + '\n' + str.tostring(low, format.volume), xloc.bar_index, yloc.price, Green, label.style_label_up, color.white, size.normal) : na
sell = not BullishFlow and BullishFlow != BullishFlow[1] ? label.new(bar_index, y2, 'High' + '\n' + str.tostring(high, format.volume), xloc.bar_index, yloc.price, Red, label.style_label_down, color.white, size.normal) : na
````
