# pranjalabhigyan

- url: https://www.tradingview.com/script/OrwYCaxJ-pranjalabhigyan/
- type: indicator
- pine_id: PUB;2939b4e1ba5b4b6798e76e99265255c7
- version: 1.0

## Description

# pranjalabhigyan — Parabolic Weighted Moving Average (PWMA)

pranjalabhigyan is a custom Parabolic Weighted Moving Average (PWMA) indicator designed to provide smoother trend detection while reacting faster to price action compared to traditional moving averages.

Unlike SMA or EMA, this indicator applies a parabolic weighting system, giving progressively higher importance to recent candles. This helps traders identify momentum shifts and trend direction with improved responsiveness.

## Features

• Custom Parabolic Weighted Moving Average
• Manual timeframe selection (Multi-Timeframe Support)
• Dynamic trend color changes
• BUY and SELL signal labels
• Alert conditions for crossovers
• Clean and lightweight chart overlay

## How It Works

The indicator calculates a weighted moving average using squared (parabolic) weights. Recent price candles receive significantly more influence than older candles, allowing the PWMA to adapt quickly during trending markets while remaining smoother than many fast-moving averages.

## Signals

• BUY Signal → Price crosses above PWMA
• SELL Signal → Price crosses below PWMA

## Timeframe Flexibility

Users can manually select a custom timeframe independent of the chart timeframe.
Examples:
• 5 → 5 Minutes
• 15 → 15 Minutes
• 60 → 1 Hour
• 240 → 4 Hours
• D → Daily

## Best Use Cases

• Trend following
• Momentum confirmation
• Dynamic support and resistance
• Multi-timeframe analysis
• Scalping, intraday, and swing trading

## Disclaimer

This indicator is intended for educational and analytical purposes only and should not be considered financial advice. Always use proper risk management before trading.

## Source Code

````pine
//@version=5
indicator("pranjalabhigyan", overlay=true)

// ===== INPUTS =====
length = input.int(20, minval=1, title="PWMA Length")
src = input.source(close, title="Source")
tf = input.timeframe("60", title="Custom Timeframe")

// ===== PWMA FUNCTION =====
pwma_func(_src, _length) =>
    float weightedSum = 0.0
    float weightTotal = 0.0

    for i = 0 to _length - 1
        weight = math.pow(_length - i, 2)
        weightedSum += _src[i] * weight
        weightTotal += weight

    weightedSum / weightTotal

// ===== MULTI-TIMEFRAME PWMA =====
pwma_htf = request.security(syminfo.tickerid, tf, pwma_func(src, length))

// ===== TREND COLOR =====
trendColor = pwma_htf > pwma_htf[1] ? color.lime : color.red

// ===== PLOT =====
plot(pwma_htf, title="PWMA", color=trendColor, linewidth=3)

// ===== SIGNALS =====
buySignal = ta.crossover(close, pwma_htf)
sellSignal = ta.crossunder(close, pwma_htf)

// ===== BUY/SELL LABELS =====
plotshape(buySignal, title="BUY", location=location.belowbar, color=color.lime, style=shape.labelup, text="BUY")

plotshape(sellSignal, title="SELL", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// ===== ALERTS =====
alertcondition(buySignal, title="Buy Alert", message="Price crossed ABOVE PWMA")

alertcondition(sellSignal, title="Sell Alert", message="Price crossed BELOW PWMA")
````
