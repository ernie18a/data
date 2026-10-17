# Macro Liquidity Z-Score (Smoothed)

- url: https://www.tradingview.com/script/6ayXnQ7M-Macro-Liquidity-Z-Score-Smoothed/
- type: indicator
- pine_id: PUB;0a6965edc1304ab4971bb6c94be527c2
- version: 1.0

## Description

[b]Overview[/b]
The Global Liquidity Z-Score Index is a macro-analytical tool designed to track, smooth, and visualise the expansions and contractions of global fiat liquidity. Central bank interventions and monetary policy print the ultimate "tide" that lifts or lowers all risk assets. This indicator standardises global money supply expansion into a clean standard deviation oscillator (Z-Score), helping macro investors identify generational market bottoms and structural cycle peaks.
Unlike traditional economic charts that suffer from heavy month-to-month seasonal reporting noise, this script applies a dual-stage filtering system to isolate the true multi-year structural trend.

[b]How It Works & Calculations[/b]
This indicator functions best when applied to a combined custom global M2 ticker string (such as summing the M2 figures of the US, Eurozone, China, Japan, and the UK).The calculation follows two distinct mechanical steps:
1.	Seasonality Smoothing: Raw monthly macro data inherently has annual jagged noise due to holiday spending cycles and uneven central bank reporting dates. The script applies a localised Simple Moving Average (SMA) filter to smooth these short-term discrepancies.
2.	Statistical Variance (Z-Score): The script then calculates the standard deviation of the smoothed liquidity trend against a long-term rolling baseline. The final formula plots how many standard deviations current global liquidity is deviating from its multi-year mean:
 
[b]Z = ( x - µ ) / σ[/b]
      

Z  = (Where x is the smoothed M2 data, µ is the rolling mean lookback, and σ is the standard deviation).

[b]How to Use & Interpret the Signals[/b]
To align this script with major asset class cycles (like the 4-year crypto halving cycles or structural equity regimes), it is highly recommended to use it on the Monthly (1M) time frame with a Z-Score Lookback of 36 or 48 months.

•	The Upper "Overheated" Threshold (+1.2 Zone): When the indicator line spikes deep into the upper band and turns red, global central banks are injecting capital at a rate significantly higher than the multi-year average. This represents peak monetary expansion, historically correlating with late-stage bull market euphoria and asset overvaluation. This is a zone to scale out of risk.
•	The Lower "Liquidity Floor" Threshold (-1.2 Zone): When the indicator bottoms out into a deep valley and turns green, it highlights severe quantitative tightening or liquidity contraction relative to the trend. Historically, when the line stabilises in this zone and begins curling back upward, it signals a structural market pivot—marking exceptional, low-risk periods for long-term spot asset accumulation.
•	The Current Regime: The baseline (0.0) represents perfectly neutral liquidity expansion. Watch for clean, rolling cross-overs of the baseline to identify mid-cycle momentum shifts.

[b]Inputs & Customisation[/b]
•	Source Data: Defaults to close. Ensure your active chart is loaded with a global M2 tracking formula.
•	Seasonality Smoothing: Controls the short-term smoothing filter. Recommended setting: 3 to 6 months to erase reporting noise.
•	Z-Score Lookback: Controls the multi-year statistical lens. Recommended setting: 36 to 48 months for macro market cycles.

## Source Code

````pine
//@version=6
indicator("Macro Liquidity Z-Score (Smoothed v6)", shorttitle="Macro Z-Score v6", overlay=false)

// Inputs
src          = input.source(close, title="Source Data")
smoothLength = input.int(6, title="Seasonality Smoothing (Months)", minval=1)
zLength      = input.int(36, title="Z-Score Lookback (Months)", minval=1)

// 1. Smooth out the seasonal monthly zig-zags first using the ta namespace
smoothedSrc = ta.sma(src, smoothLength)

// 2. Calculate Z-Score on the smoothed macro trend
mae    = ta.sma(smoothedSrc, zLength)
sdev   = ta.stdev(smoothedSrc, zLength)
zscore = (smoothedSrc - mae) / sdev

// Define color thresholds based on value using precise conditional logic
color zColor = zscore > 1.2 ? color.red : zscore < -1.2 ? color.green : color.blue

// Plotting the lines
plot(zscore, title="Z-Score Line", color=zColor, linewidth=2)
hline(0, "Baseline", color=color.gray, linestyle=hline.style_dashed)

// Key Threshold Bands
hline(1.2, "Overheated (+1.2)", color=color.new(color.red, 30), linestyle=hline.style_dotted)
hline(-1.2, "Liquidity Floor (-1.2)", color=color.new(color.green, 30), linestyle=hline.style_dotted)

// Background highlights for clear macro regimes using v6 styling rules
bgcolor(zscore > 1.2 ? color.new(color.red, 92) : zscore < -1.2 ? color.new(color.green, 92) : na)
````
