# Trend Detector by Firozstar V 1.0

- url: https://www.tradingview.com/script/MoDotMnR-Trend-Detector-by-Firozstar-V-1-0/
- type: indicator
- pine_id: PUB;daf7ad3e052f4a2d955dd0f3a667a882
- version: 1.0

## Description

You can use this professional description:

Trend Detector by Firozstar V 1.0 (TDFS) is a momentum-based trend indicator designed to provide a simple visual representation of market direction and momentum strength.

The indicator calculates the difference between a fast and slow moving average and normalizes the resulting value to provide consistent trend interpretation.

The indicator uses three distinct market states:

• Bullish Trend: The trend line moves above the upper threshold and is displayed in green.

• Bearish Trend: The trend line moves below the lower threshold and is displayed in red.

• Neutral Zone: The trend line remains between the upper and lower thresholds and is displayed in grey.

By default, the indicator uses 12-period and 26-period exponential moving averages (EMA), with customizable moving average types, periods, and trend thresholds.

Key Features:

• Simple trend and momentum visualization
• Bullish, bearish, and neutral market identification
• Customizable upper and lower trend thresholds
• Support for EMA and SMA calculations
• Color-coded trend line for easier interpretation
• Neutral zone highlighting
• Alert conditions for bullish, bearish, and neutral trend transitions

TDFS is designed to help traders visually evaluate momentum and identify changes in market direction. It can be used across different instruments and timeframes.

Disclaimer: This indicator is intended for educational and analytical purposes only. It does not constitute financial or investment advice. Users should perform their own analysis and use appropriate risk management before making trading decisions.

## Source Code

````pine
//@version=6
indicator(
     title = "Trend Detector by Firozstar V 1.0",
     shorttitle = "TDFS V 1.0",
     overlay = false,
     timeframe = "",
     timeframe_gaps = true
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUT SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
priceSeries = input.source(close, "Price Source")

quickPeriod = input.int(
     defval = 12,
     title = "Quick Average Period",
     minval = 1
)

basePeriod = input.int(
     defval = 26,
     title = "Base Average Period",
     minval = 1
)

averageMethod = input.string(
     defval = "EMA",
     title = "Average Calculation",
     options = ["EMA", "SMA"]
)

upperLevel = input.float(
     defval = 0.05,
     title = "Upper Trend Level",
     step = 0.01
)

lowerLevel = input.float(
     defval = -0.05,
     title = "Lower Trend Level",
     step = 0.01
)

showNeutralZone = input.bool(
     defval = true,
     title = "Highlight Neutral Zone"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AVERAGE CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trendAverage(float data, int period, simple string method) =>
    switch method
        "EMA" => ta.ema(data, period)
        "SMA" => ta.sma(data, period)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND MOMENTUM CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
quickTrend = trendAverage(
     priceSeries,
     quickPeriod,
     averageMethod
)

baseTrend = trendAverage(
     priceSeries,
     basePeriod,
     averageMethod
)

// Percentage-normalized MACD calculation
trendStrength = baseTrend != 0
     ? ((quickTrend - baseTrend) / baseTrend) * 100
     : 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UPPER AND LOWER RANGE LINES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
upperLine = hline(
     upperLevel,
     title = "Upper Trend Line",
     color = color.green,
     linestyle = hline.style_solid,
     linewidth = 2
)

lowerLine = hline(
     lowerLevel,
     title = "Lower Trend Line",
     color = color.red,
     linestyle = hline.style_solid,
     linewidth = 2
)

fill(
     upperLine,
     lowerLine,
     title = "Neutral Trend Zone",
     color = showNeutralZone
          ? color.new(color.gray, 88)
          : na
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND LINE APPEARANCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trendLineColor =
     trendStrength > upperLevel ? color.lime :
     trendStrength < lowerLevel ? color.red :
     color.gray

plot(
     trendStrength,
     title = "Trend Strength",
     color = trendLineColor,
     linewidth = 2
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullishTrendStart = ta.crossover(
     trendStrength,
     upperLevel
)

bearishTrendStart = ta.crossunder(
     trendStrength,
     lowerLevel
)

enteredNeutralZone =
     ta.crossunder(trendStrength, upperLevel) or
     ta.crossover(trendStrength, lowerLevel)

alertcondition(
     bullishTrendStart,
     title = "Bullish Trend Started",
     message = "TDFS crossed above the upper trend level."
)

alertcondition(
     bearishTrendStart,
     title = "Bearish Trend Started",
     message = "TDFS crossed below the lower trend level."
)

alertcondition(
     enteredNeutralZone,
     title = "Neutral Trend Started",
     message = "TDFS entered the neutral trend zone."
)
````
