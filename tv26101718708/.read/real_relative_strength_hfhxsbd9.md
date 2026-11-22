# Real Relative Strength

- url: https://www.tradingview.com/script/hfhXsbD9-Real-Relative-Strength/
- type: indicator
- pine_id: PUB;d6e626f5716844fab835e79daaafa27b
- version: 1.0

## Description

Rolling Real Relative Strength vs SPY measures how strongly a stock is performing compared to a benchmark, such as SPY, over a rolling lookback period. Unlike simple relative strength comparisons, this indicator normalizes both the selected symbol and the comparison security by their respective ATR values, helping account for differences in volatility.

The result is a cleaner view of whether the charted symbol is outperforming or underperforming the benchmark on a volatility-adjusted basis.

Above zero suggests the symbol is showing real relative strength.
Below zero suggests the symbol is showing real relative weakness.
Green/red fill highlights positive or negative relative performance.
Correlation dots on the baseline show how closely the symbol is moving with the benchmark over the selected lookback period.
This tool can be useful for identifying stocks that are holding up better than the market during pullbacks, showing leadership during rallies, or revealing weakness despite broader market strength.

Default comparison symbol is SPY, but it can be changed to any ticker.

## Source Code

````pine
//@version=6
indicator(title="Real Relative Strength", shorttitle="RRS", overlay=false)

// ─────────────────────────────────────
// Inputs
// ─────────────────────────────────────
comparedWithSecurity = input.symbol("SPY", title="Compare With")
length = input.int(12, title="Length", minval=1)

showFill = input.string(
     "Solid",
     title="Show Fill",
     options=["Multi", "Solid", "None"]
)

showCorrelation = input.bool(true, title="Show Correlation")

// ─────────────────────────────────────
// Compared Security Data
// ─────────────────────────────────────
comparedClose = request.security(
     comparedWithSecurity,
     timeframe.period,
     close
)

comparedHigh = request.security(
     comparedWithSecurity,
     timeframe.period,
     high
)

comparedLow = request.security(
     comparedWithSecurity,
     timeframe.period,
     low
)

// ─────────────────────────────────────
// Rolling Price Change
// ─────────────────────────────────────
comparedRollingMove = comparedClose - comparedClose[length]
symbolRollingMove = close - close[length]

// ─────────────────────────────────────
// Rolling ATR Change
// ThinkScript version used Wilder's Average of TrueRange
// Pine's ta.atr() is Wilder's ATR
// Shifted by [1] to match the original logic
// ─────────────────────────────────────
symbolRollingATR = ta.atr(length)[1]

comparedRollingATR = request.security(
     comparedWithSecurity,
     timeframe.period,
     ta.atr(length)[1]
)

// ─────────────────────────────────────
// Calculations
// ─────────────────────────────────────
powerIndex = comparedRollingATR != 0 ? comparedRollingMove / comparedRollingATR : na
expectedMove = powerIndex * symbolRollingATR
diff = symbolRollingMove - expectedMove
RRS = symbolRollingATR != 0 ? diff / symbolRollingATR : na

// ─────────────────────────────────────
// Plot
// ─────────────────────────────────────
rrsPlot = plot(
     RRS,
     title="Real Relative Strength",
     color=color.blue,
     linewidth=2
)

baselinePlot = plot(
     0,
     title="Baseline",
     color=color.red,
     linewidth=1
)

// ─────────────────────────────────────
// Fill Options
// ─────────────────────────────────────
solidFillColor = RRS >= 0 ? color.new(color.green, 80) : color.new(color.red, 80)

fill(
     rrsPlot,
     baselinePlot,
     color=showFill == "Solid" ? solidFillColor : na,
     title="Solid Fill"
)

// Multi-color histogram similar to ThinkScript Fill
multiColor =
     RRS >= 0
         ? RRS > RRS[1]
             ? color.green
             : color.rgb(0, 100, 0)
         : RRS < RRS[1]
             ? color.red
             : color.rgb(139, 0, 0)

plot(
     showFill == "Multi" ? RRS : na,
     title="Multi Fill Histogram",
     style=plot.style_histogram,
     linewidth=3,
     color=multiColor
)

// ─────────────────────────────────────
// Correlation
// ─────────────────────────────────────
correlated = ta.correlation(close, comparedClose, length)

corrColor =
     correlated > 0.75 ? color.rgb(0, 255, 0) :
     correlated > 0.50 ? color.rgb(0, 192, 0) :
     correlated > 0.25 ? color.rgb(0, 128, 0) :
     correlated > 0.00 ? color.rgb(0, 64, 0) :
     correlated > -0.25 ? color.rgb(64, 0, 0) :
     correlated > -0.50 ? color.rgb(128, 0, 0) :
     correlated > -0.75 ? color.rgb(192, 0, 0) :
     color.rgb(255, 0, 0)

plot(
     showCorrelation ? 0 : na,
     title="Correlation",
     color=corrColor,
     linewidth=3,
     style=plot.style_circles
)
````
