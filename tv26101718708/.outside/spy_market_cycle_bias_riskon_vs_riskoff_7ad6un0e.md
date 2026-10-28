# SPY Market Cycle Bias (Risk-On vs Risk-Off)

- url: https://www.tradingview.com/script/7Ad6UN0e-SPY-Market-Cycle-Bias-Risk-On-vs-Risk-Off/
- type: indicator
- pine_id: PUB;12c7f5e7fa41468fa06f2ac7109616e6
- version: 1.0

## Description

[image]https://www.tradingview.com/x/DNDDnGmS/[/image]A simple but powerful market regime indicator designed to help traders align with the broader market trend using the relationship between the daily 20 EMA and 50 EMA of SPY (S&P 500 Index)

This indicator identifies whether the overall market environment is in a bullish or bearish cycle by monitoring the trend structure of SPY — one of the most widely followed market benchmarks.

Instead of relying solely on individual stock price action, this tool helps traders determine whether the broader market is supportive of long-side momentum and swing trading.

[b]How It Works[/b]

The indicator compares:

Daily EMA 20
Daily EMA 50

Market bias is determined as follows:

Bullish Cycle → EMA 20 > EMA 50
Bearish Cycle → EMA 20 < EMA 50

A real-time dashboard displays the current market regime directly on the chart.

[b]Why It’s Useful[/b]

Many traders focus only on individual stock setups while ignoring the broader market environment. However, market regime often has a major influence on:

breakout success rates,
momentum continuation,
volatility behavior,
and overall trade expectancy.

This indicator helps traders:

stay aligned with the dominant market trend,
reduce exposure during weak market conditions,
improve trade selection,
and avoid forcing aggressive longs during bearish cycles.


[b]Practical Applications[/b]

Example framework:

SPY EMA20 > EMA50 → focus on long setups
SPY EMA20 < EMA50 → defensive positioning / reduced risk

Many professional traders use market regime filters similar to this to improve consistency and reduce low-quality trades during unfavorable market conditions.

## Source Code

````pine
//@version=6
indicator("SPY Market Cycle Bias", overlay = true)

// === INPUTS ===
fastLen = input.int(20, title = "Fast EMA")
slowLen = input.int(50, title = "Slow EMA")

// === SPY DAILY EMAs ===
spyEMA20 = request.security(
     "SPY",
     "D",
     ta.ema(close, fastLen)
)

spyEMA50 = request.security(
     "SPY",
     "D",
     ta.ema(close, slowLen)
)

// === REGIME LOGIC ===
isBullish = spyEMA20 > spyEMA50

trendText  = isBullish ? "BULLISH" : "BEARISH"
trendColor = isBullish
     ? color.rgb(83, 187, 83)
     : color.red

// === OPTIONAL PLOTS ===
plot(
     spyEMA20,
     title = "SPY Daily EMA 20",
     color = color.lime,
     linewidth = 2
)

plot(
     spyEMA50,
     title = "SPY Daily EMA 50",
     color = color.orange,
     linewidth = 2
)

// === TABLE ===
var table regimeTable = table.new(
     position.top_right,
     columns = 2,
     rows = 2,
     border_width = 1
)

// === UPDATE TABLE ===
if barstate.islast

    // Header
    table.cell(
         regimeTable, 0, 0,
         "Metric",
         bgcolor = color.gray,
         text_color = color.white
    )

    table.cell(
         regimeTable, 1, 0,
         "Status",
         bgcolor = color.gray,
         text_color = color.white
    )

    // Cycle Bias
    table.cell(
         regimeTable, 0, 1,
         "SPY Cycle Bias",
         text_color = color.white
    )

    table.cell(
         regimeTable, 1, 1,
         trendText,
         bgcolor = trendColor,
         text_color = color.white
    )

// === BACKGROUND ===
bgcolor(
     isBullish
     ? color.new(color.green, 92)
     : color.new(color.red, 92)
)
````
