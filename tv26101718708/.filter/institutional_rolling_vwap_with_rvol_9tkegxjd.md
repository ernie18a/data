# Institutional Rolling VWAP with RVOL

- url: https://www.tradingview.com/script/9tkeGXjD/
- type: indicator
- pine_id: PUB;f20017ebbd9c48fc83e257a624d984ab
- version: 1.0

## Description

Institutional Rolling VWAP (IRVWAP) combines a time-based Rolling VWAP with liquidity-adjusted volatility bands, ADV analysis, and relative volume metrics to estimate institutional fair value and identify accumulation, distribution, and price extremes.

Unlike a standard VWAP, which only tracks the volume-weighted average price over a rolling window, IRVWAP adapts its volatility bands using liquidity and volume participation metrics inspired by institutional trading behavior.

[b]Institutional Logic[/b]
Research on market impact suggests that large orders are typically executed over multiple days or weeks rather than in a single session.
IRVWAP incorporates this idea by comparing recent trading activity against long-term average volume.​

[i]When market participation increases:
[/i]Bands contract;
Price deviations become more meaningful;

[i]When participation decreases:
[/i]Bands expand;
Noise is filtered more aggressively.

[i]Inputs[/i]
• Rolling VWAP time window;
• ADV length;
• Flow length;
• Adaptive band toggle;
• Standard deviation multipliers.

[i]Features:
[/i]• Rolling VWAP based on a time-based moving window;
• Volume-weighted standard deviation bands;
• Adaptive volatility bands based on Relative Volume (RVOL);
• Average Daily Volume (ADV) monitoring;
• Institutional Activity Score (Z-Score);
• Designed to identify potential accumulation and distribution zones.

[i]Suggested Uses
[/i]| Condition | Interpretation |
| Above +2σ & RVOL > 1.3 | Bullish continuation |
| Above +3σ & RVOL > 1.5 | Strong bullish continuation |
| Above +2σ & RVOL < 0.8 | Bearish mean reversion |
| Below -2σ & RVOL > 1.3 | Bearish continuation |
| Below -3σ & RVOL > 1.5 | Strong bearish continuation |
| Below -2σ & RVOL < 0.8 | Bullish mean reversion |
| Between ±1σ | Fair value zone |

[b]Code is bugged, fix the scale: right click --> fix the axis
[/b]
[i]Based on the papers:
Slow decay of impact in equity markets - Brokmann et al. (2014)
VWAP Execution as an Optimal Strategy - Takashi Kato (2017)
Mean Variance Optimal: VWAP Trading - McCulloch & Kazakov (2012)[/s]

Ps: I built this code with zero coding knowledge using GPT. If I made mistakes or some things does not make sense please contact me.[/i]

## Source Code

````pine
//@version=6
indicator("Institutional RVOL", shorttitle="IRVOL", overlay=false)

//====================================================
// Inputs
//====================================================

shortLength = input.int(20, "Recent Volume Length", minval=1)
longLength  = input.int(50, "Long-Term Volume Length", minval=1)
signalLen   = input.int(10, "Signal EMA Length", minval=1)

//====================================================
// RVOL Calculation
//====================================================

recentVol = ta.sma(volume, shortLength)
longVol   = ta.sma(volume, longLength)

rvol = longVol > 0 ? recentVol / longVol : na

signal = ta.ema(rvol, signalLen)

//====================================================
// Colors
//====================================================

color histColor =
     rvol < 0.8 ? color.gray :
     rvol < 1.2 ? color.blue :
     rvol < 1.5 ? color.green :
     rvol < 2.0 ? color.orange :
     color.red

//====================================================
// Plots
//====================================================

plot(
     rvol,
     title="RVOL",
     style=plot.style_columns,
     color=histColor,
     linewidth=2)

plot(
     signal,
     title="RVOL EMA",
     color=color.white,
     linewidth=2)

//====================================================
// Reference Levels
//====================================================

hline(2.0, "Extreme Activity", color.red)
hline(1.5, "Institutional Activity", color.orange)
hline(1.2, "Above Average", color.green)
hline(1.0, "Normal", color.gray)
hline(0.8, "Below Average", color.gray)
hline(0.5, "Low Activity", color.gray)

//====================================================
// Background Highlights
//====================================================

bgcolor(
     rvol > 2.0
     ? color.new(color.red, 92)
     : na)

bgcolor(
     rvol > 1.5 and rvol <= 2.0
     ? color.new(color.orange, 94)
     : na)

//====================================================
// Alerts
//====================================================

alertcondition(
     ta.crossover(rvol, 1.2),
     title="RVOL Above Average",
     message="RVOL crossed above 1.2")

alertcondition(
     ta.crossover(rvol, 1.5),
     title="Institutional Activity",
     message="RVOL crossed above 1.5")

alertcondition(
     ta.crossover(rvol, 2.0),
     title="Extreme Activity",
     message="RVOL crossed above 2.0")
````
