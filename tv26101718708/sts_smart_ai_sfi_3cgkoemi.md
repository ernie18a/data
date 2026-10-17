# STS SMART AI [SFI]

- url: https://www.tradingview.com/script/3cgKOEMI/
- type: indicator
- pine_id: PUB;928794f7a9d24035b0ff7781a1ad87eb
- version: 1.0

## Description

STS SMART AI [SFI Academy]

STS SMART AI is a momentum and volatility analysis indicator developed as part of the STS SMART AI Trading System by SFI Academy.

Rather than generating standalone Buy or Sell signals, this indicator is designed to provide additional market context that helps traders make more informed decisions while managing positions with the STS SMART AI system.

Purpose

The indicator helps traders evaluate:

Market momentum
Strength of bullish and bearish pressure
Volatility compression (Squeeze)
Potential momentum expansion after low-volatility conditions

Its primary objective is to improve market awareness before activating or managing the STS SMART AI execution process.

Core Components
Momentum Analysis

A Linear Regression Momentum Histogram is used to visualize changes in market strength.

Blue Histogram → Bullish momentum
Red Histogram → Bearish momentum

Changes in histogram size can help identify whether momentum is strengthening or weakening.

Volatility Compression

STS SMART AI detects squeeze conditions by comparing:

Bollinger Bands
Keltner Channels

When volatility contracts, the market often enters a consolidation phase. Expanding volatility may indicate the beginning of a stronger directional move.

Designed to Work with STS SMART AI

This indicator is intended to be used together with the STS SMART AI position management system.

It is not designed to replace market analysis or produce automatic trading signals.

Traders are encouraged to combine it with:

Market Structure
Trend Analysis
Support & Resistance
Supply & Demand
Risk Management
Adjustable Parameters
Bollinger Band Length
Bollinger Band Multiplier
Keltner Channel Length
Keltner Channel Multiplier
True Range Calculation

These settings allow traders to adapt the indicator to different markets and trading styles.

Suitable Markets
Gold (XAUUSD)
Forex
Cryptocurrency
Indices
Stocks

Compatible with multiple timeframes.

About STS SMART AI

STS SMART AI is a trading framework developed by SFI Academy to support disciplined trade management and structured decision-making.

The indicator provides analytical confirmation, while the complete STS SMART AI workflow focuses on consistency, risk control, and systematic execution.

Disclaimer

This indicator is provided for educational and analytical purposes only. It does not provide financial advice or guarantee future trading results. Always apply appropriate risk management before making trading decisions.

## Source Code

````pine
//@version=6
indicator("STS SMART AI [SFI Academy]", shorttitle="STS SMART AI", overlay=false)

length   = input.int(20,      title="BB Length")
mult     = input.float(2.0,   title="BB MultFactor")
lengthKC = input.int(20,      title="KC Length")
multKC   = input.float(1.5,   title="KC MultFactor")
useTrueRange = input.bool(true, title="Use TrueRange (KC)")

// ── Bollinger Bands ────────────────────────────────────────
basis = ta.sma(close, length)
dev   = multKC * ta.stdev(close, length)     // gốc dùng multKC ở đây
upperBB = basis + dev
lowerBB = basis - dev

// ── Keltner Channel ────────────────────────────────────────
ma       = ta.sma(close, lengthKC)
barRange = useTrueRange ? ta.tr(true) : (high - low)   // ← đã sửa ở đây
rangema  = ta.sma(barRange, lengthKC)

upperKC = ma + rangema * multKC
lowerKC = ma - rangema * multKC

// ── Squeeze condition ──────────────────────────────────────
sqzOn  = (lowerBB > lowerKC) and (upperBB < upperKC)
sqzOff = (lowerBB < lowerKC) and (upperBB > upperKC)
noSqz  = not sqzOn and not sqzOff

// ── Momentum oscillator ────────────────────────────────────
avgHighLow = ta.sma(math.avg(ta.highest(high, lengthKC), ta.lowest(low, lengthKC)), 1)
avgClose   = ta.sma(close, lengthKC)
midLine    = math.avg(avgHighLow, avgClose)

val = ta.linreg(close - midLine, lengthKC, 0)

// ── Color logic ────────────────────────────────────────────
bcolor = val > 0 ?
         (val > nz(val[1]) ? color.rgb(0, 23, 230) : color.rgb(0, 23, 230)) :
         (val < nz(val[1]) ? color.rgb(255, 82, 97)  : color.rgb(255, 82, 97))

scolor = noSqz ? color.blue : sqzOn ? color.black : color.gray

// ── Plotting ───────────────────────────────────────────────
plot(val,   color = bcolor,  style = plot.style_histogram, linewidth = 4, title = "Momentum")


// Optional: highlight vùng squeeze
// bgcolor(sqzOn ? color.new(color.orange, 92) : na, title="Squeeze Zone")
````
