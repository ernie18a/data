# Real Relative Strength

- url: https://www.tradingview.com/script/2HiCniE7-Real-Relative-Strength/
- type: indicator
- pine_id: PUB;caf7f9afa969447797ce59de86a9d64d
- version: 1.0

## Description

[b]Real Relative Strength (RRS)[/b]

[b]Real Relative Strength (RRS)[/b] measures a stock's performance relative to a benchmark (default: SPY) while adjusting for volatility using ATR.

Unlike traditional Relative Strength, which compares price performance directly, RRS compares ATR-normalized moves, showing whether a stock is outperforming or underperforming the market on a risk-adjusted basis.

[b]Interpretation[/b]
[list]
[*]RRS > 0 → Stock is outperforming the benchmark.
[*]RRS < 0 → Stock is underperforming the benchmark.
[*]RRS = 0 → Stock is performing in line with the benchmark.
[/list]

[b]Features[/b]
[list]
[*]Uses a rolling lookback period (default: 12 bars).
[*]Normalizes price movement by ATR to account for volatility differences.
[*]Includes a correlation indicator to show how closely the stock tracks the benchmark.
[*]Green fill indicates positive relative strength; red fill indicates negative relative strength.
[*]Trading Applications
[/list]

[b]Bullish Candidates
[/b]
[list]
[*]RRS above zero and rising.
[*]Price above key moving averages.
[*]Volume expanding.
[*]Indicates institutional leadership and market outperformance.
[/list]

[b]Bearish Candidates
[/b]
[list]
[*]RRS below zero and falling.
[*]Price below key moving averages.
[*]Weak participation during market rallies.
[*]Indicates relative weakness versus the broader market.
[/list]

[b]Key Insight:
[/b]RRS answers the question: "How many ATRs stronger or weaker is this stock compared to the benchmark over the selected lookback period?" This volatility-adjusted approach helps identify true market leaders and laggards more effectively than traditional relative strength measures.
​

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

// © WorkPiece 12.28.21

//@version=6


indicator(title="Real Relative Strength", shorttitle="RRS")

comparedWithSecurity = input.symbol(title="Compare With", defval="SPY")

length = input(title="Length", defval=12)


//##########Rolling Price Change##########

comparedClose = request.security(symbol=comparedWithSecurity, timeframe="", expression=close)

comparedRollingMove = comparedClose - comparedClose[length]

symbolRollingMove = close - close[length]


//##########Rolling ATR Change##########

symbolRollingATR = ta.atr(length)[1]

comparedRollingATR = request.security (symbol=comparedWithSecurity, timeframe="", expression= ta.atr(length)[1])


//##########Calculations##########

powerIndex = comparedRollingMove / comparedRollingATR

RRS = (symbolRollingMove - powerIndex * symbolRollingATR) / symbolRollingATR


//##########Plot##########

RealRelativeStrength = plot(RRS, "RealRelativeStrength", color=color.blue)

Baseline = plot(0, "Baseline", color=color.red)


//##########Extra Stuff##########

fill(RealRelativeStrength, Baseline, color = RRS >= 0 ? color.green : color.red, title="fill")


correlated = ta.correlation(close, comparedClose, length)

Correlation = plot(0, title="Correlation", color = correlated > .75 ? #00FF00 : correlated > .50 ? #00C000 : correlated > .25 ? #008000 : correlated > 0.0 ? #004000 :correlated > -.25 ? #400000 :correlated > -.50 ? #800000 :correlated > -.75 ? #C00000 :#FF0000, linewidth=3, style=plot.style_circles)
````
