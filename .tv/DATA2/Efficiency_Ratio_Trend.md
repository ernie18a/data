<!-- tradingview-pine-id: PUB;7f1b56ba5f2742df987ab944dd71144b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Efficiency Ratio Trend

Source: https://www.tradingview.com/script/Fef044IM-Efficiency-Ratio-Trend-Achira-Meegasthanne/

## Description

Efficiency Ratio Trend

Efficiency Ratio Trend is an adaptive trend-following indicator designed to identify the current market direction by combining price efficiency, adaptive deviation, volatility, and trend persistence.

The indicator uses an Efficiency Ratio to dynamically adjust its deviation and create a step-style trend line that responds to meaningful price movement while filtering smaller fluctuations.

🔹 KEY FEATURES

📊 EFFICIENCY RATIO

The indicator calculates an Efficiency Ratio based on the relationship between net price movement and the total absolute price movement over the selected Length.

This allows the trend calculation to adapt to the efficiency of the current market movement.

📈 ADAPTIVE TREND CALCULATION

The indicator uses the Efficiency Ratio together with short-term and long-term standard deviation measurements to calculate a dynamic deviation.

This creates an adaptive trend level that responds differently depending on current market conditions.

⚙️ CUSTOMIZABLE SETTINGS

The indicator provides several user-controlled settings:

• Length
• Fast Length
• Slow Length
• Source
• Sensitivity

The default settings are:

• Length = 200
• Fast Length = 100
• Slow Length = 400
• Source = Close

📐 DYNAMIC DEVIATION

The deviation is dynamically calculated by combining fast and slow volatility measurements according to the current Efficiency Ratio.

When market efficiency changes, the weighting between the fast and slow volatility components changes accordingly.

🟢 BULLISH TREND

A bullish trend condition is established when the adaptive trend value moves upward beyond the defined volatility threshold.

When bullish conditions are active:

• The trend line uses the bullish color
• The trend state becomes bullish
• Price movement is visually represented as an upward trend

🔴 BEARISH TREND

A bearish trend condition is established when the adaptive trend value moves downward beyond the defined volatility threshold.

When bearish conditions are active:

• The trend line uses the bearish color
• The trend state becomes bearish
• Price movement is visually represented as a downward trend

📊 VOLATILITY-ADJUSTED THRESHOLD

The indicator uses a 14-period ATR to calculate the current volatility percentage.

The adaptive trend movement is compared against this volatility-based threshold to determine whether a meaningful trend change has occurred.

🧠 TREND PERSISTENCE

Small movements below the calculated threshold do not immediately change the trend state.

Instead, the previous trend direction is maintained until the adaptive movement exceeds the required threshold.

This helps reduce unnecessary changes caused by smaller price fluctuations.

🎨 TREND VISUALIZATION

The indicator displays a step-style trend line directly on the chart.

The line changes between:

• Bullish
• Bearish

This provides a simple visual representation of the current adaptive market direction.

📌 CORE CONCEPT

Price Efficiency → Adaptive Volatility → Dynamic Deviation → ATR Threshold → Trend Confirmation → Direction

🧠 HOW IT WORKS

1. Calculate Price Efficiency

The indicator measures net price movement relative to the total absolute movement over the selected Length.

2. Calculate Volatility

Fast and slow standard deviation values are calculated using the configured Fast Length and Slow Length.

3. Build Adaptive Deviation

The Efficiency Ratio determines how the fast and slow volatility components are weighted.

4. Create the Adaptive Trend

The indicator updates the trend value only when price moves beyond the calculated adaptive deviation.

5. Calculate ATR Threshold

A 14-period ATR is used to normalize the trend movement according to current market volatility.

6. Confirm Trend Direction

Only movements exceeding the volatility-adjusted threshold are considered meaningful trend changes.

7. Display the Trend

The resulting adaptive trend is plotted as a step-style line with bullish or bearish coloring.

⚠️ IMPORTANT DISCLAIMER

This indicator is designed for market analysis and educational purposes.

The Efficiency Ratio Trend should not be considered a guaranteed buy or sell signal.

Trend calculations are based on historical price and volatility data, and market conditions can change quickly.

Always perform your own analysis, use proper risk management, and thoroughly test the indicator before using it with real capital.

Measure the efficiency. Adapt to volatility. Follow the trend.

---

## Source Code

````pine
//@version=6
indicator('Efficiency Ratio Trend', overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_polylines_count = 100)

bullCol = color.new(#0df1c6, 20)
bearCol = #871ee9

markrtStairsSen = input.float(defval = 2.0, title = '', inline = '7', minval = 0.01, display = display.none)
length = input(200, 'Length')
fastLen = input(100, 'Fast Length')
slowLen = input(400, 'Slow Length')
Src = input(close)


m_function(float sensitivitygg, color bullCol, color bearCol) =>
    lengthf = length
    fast = fastLen
    slow = slowLen
    src = Src

    er = math.abs(ta.change(src, lengthf)) / math.sum(math.abs(ta.change(src)), lengthf)
    dev = er * ta.stdev(src * 2, fast) + (1 - er) * ta.stdev(src * 2, slow)
    a = 0.
    a := src > nz(a[1], src) + dev ? src : src < nz(a[1], src) - dev ? src : nz(a[1], src)

    css = fixnan(a > a[1] ? bullCol : a < a[1] ? bearCol : na)

    delta = (a - a[1]) / a[1]
    atr_length = 14
    atr_val = ta.atr(atr_length)
    price_scale = a != 0 ? a : close
    volatility_pct = atr_val / price_scale

    sensitivity1 = 0.01

    threshold = volatility_pct * sensitivity1
    clr = math.abs(delta) < threshold ? na : delta > 0 ? bullCol : bearCol

    var int trend = 0

    // Only consider changes above threshold
    if math.abs(delta) >= threshold
        trend := delta > 0 ? 1 : 0
        trend
    else // If below threshold, keep previous trend (trend unchanged)
        trend := trend
        trend

    isBullms = trend == 1

    [a, css, isBullms]

[a, css, isBullms] = m_function(markrtStairsSen, bullCol, bearCol)


//plot(markrtStairs ? a : na, color = plotColor, linewidth=3, style=plot.style_stepline_diamond, editable=false)
plot(a, color = isBullms ? bullCol : bearCol, linewidth = 3, style = plot.style_stepline_diamond, editable = false)
````
