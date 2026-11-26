# Risk Analysis [OmegaTools]

- url: https://www.tradingview.com/script/BNRy7tEs-Risk-Analysis-OmegaTools/
- type: indicator
- pine_id: PUB;b7653d7db60e4c83a0f2fbc039855b39
- version: 1.0

## Description

[b]Risk Analysis [OmegaTools][/b]

[b]Overview[/b]

Risk Analysis [OmegaTools] is a professional-grade, overlay risk dashboard designed for active traders and quantitative analysts who need a structured, real-time view of market conditions directly on their chart. Rather than cluttering the chart with multiple sub-pane indicators, this tool consolidates eight statistically grounded risk and market-structure metrics into a single, clean, repositionable table — giving you an immediate read on directionality, volatility, momentum regime, and price positioning at a glance.

The indicator is fully dollar-denominated via syminfo.pointvalue, making it natively compatible with futures contracts (NQ, ES, GC, CL, 6E, and others), where tick-scaled dollar values are essential for meaningful risk sizing and trade management.


[b]Metrics Explained[/b]

[b]Directionality — ADR$[/b]

The Average Directional Range captures the one-sided, committed portion of each bar's movement — the distance price traveled in a single direction — as opposed to the full high-low span. It blends a short-term RMA (11) with a medium-term SMA (34) to smooth noise while remaining responsive to shifts in directional energy.

[pine]dr = math.max(high - close, close - open)
adr = math.avg(ta.rma(dr, 11), ta.sma(dr, 34)) * syminfo.pointvalue[/pine]

Expressed in dollar terms, ADR gives you a practical measure of how much price has been committing to a direction per bar, which directly informs target placement and profit expectation calibration.


[b]Volatility — ATR$[/b]

The Average True Range measures the full extent of bar-to-bar price expansion, capturing both directional and indecisive (choppy) volatility. The same dual-smoothing structure (RMA 11 averaged with SMA 34) is applied for consistency with the ADR calculation.

[pine]tr = high - low
atr = math.avg(ta.rma(tr, 11), ta.sma(tr, 34)) * syminfo.pointvalue[/pine]

Expressed in dollars, ATR serves as the baseline volatility reference for stop-loss sizing, risk-reward calibration, and position sizing models.


[b]Directionality Relative — X multiplier[/b]

This metric contextualizes the current ADR/ATR ratio against its own 50-bar rolling average, expressing the result as a multiplier.

[pine]directionality = adr / atr * 100
directionalityrelative = directionality[1] / ta.sma(directionality[1], 50)[/pine]

A reading of 1.0X means directional intensity is at its historical norm. Values above 1.0X indicate the market is more directional than its recent baseline, which is favorable for trend-following approaches. Values below 1.0X signal a contraction in directionality, suggesting a shift toward mean-reversion or consolidation conditions.


[b]Distance from High — $[/b]

The dollar distance between the current close and the 11-bar swing high. This metric directly quantifies how much room price has traveled away from a recent structural peak, which is critical for assessing short-side risk exposure, trailing stop management, and mean-reversion entry evaluation.

[pine]distfromh = (ta.highest(high, 11) - close) * syminfo.pointvalue[/pine]

Low values indicate price is pinned near the top of the recent range. High values indicate extended downside displacement from the swing high.


[b]Distance from Low — $[/b]

The symmetric complement — the dollar distance between the current close and the 11-bar swing low. High values indicate price has stretched far above a recent structural base.

[pine]distfroml = (close - ta.lowest(low, 11)) * syminfo.pointvalue[/pine]

This pair of metrics together defines the current intra-range positioning of price, which is indispensable for both breakout and mean-reversion setups.


[b]ADF — Augmented Dickey-Fuller Proxy[/b]

The ADF metric is a statistical proxy for the Augmented Dickey-Fuller test, a classic econometric test for stationarity (mean-reversion) versus unit-root behavior (trending). The 100-bar Pearson correlation between price changes and lagged price levels is used as the core signal, then scaled and shifted for readability.

[pine]adf = ta.correlation(close - close[1], close[1], 100) * 10 + 0.5[/pine]

A negative correlation between price changes and price levels implies mean-reverting dynamics. A positive correlation implies trend-persistence. Values above 0 indicate a strong trending regime. Values near 0 indicate a transitional or mixed regime. Values below 0 indicate a mean-reverting regime where price consistently reverts from extremes. This is particularly valuable for regime-conditional strategy selection.


[b]Relative Volume — RelVolume X[/b]

Relative Volume compares short-term volume activity against medium-term baseline activity, expressed as a multiplier.

[pine]relvol = ta.sma(volume, 5) / ta.sma(volume, 21)[/pine]

Values above 1.0X indicate current volume is elevated relative to the recent norm, signaling heightened participation. Values near 1.0X indicate volume is in line with baseline. Values below 1.0X indicate suppressed volume and low conviction. This metric is essential for filtering signal quality — high-conviction moves require volume confirmation, and this ratio makes that assessment immediate and quantitative.


[b]Z-Score[/b]

The Z-Score measures how many standard deviations the current price is displaced from its 21-bar rolling mean. It is one of the most direct statistical measures of mean-reversion opportunity.

[pine]zscore = (close - ta.sma(close, 21)) / ta.stdev(close, 21)[/pine]

A Z-Score above +2 indicates price is significantly extended to the upside with elevated reversion risk. A Z-Score below −2 indicates price is significantly extended to the downside. A Z-Score near 0 indicates price is trading near its statistical center of gravity. Combined with the ADF and Relative Volume, the Z-Score completes a full statistical picture of the current market regime and opportunity type.


[b]How to Use This Indicator[/b]

[b]Trend-Following Context[/b]

When ADF is above 0, Directionality Relative is above 1.0X, and Relative Volume is above 1.0X, the market is showing statistically robust trending behavior with above-average participation. In this context, use ATR$ for stop-loss placement and ADR$ for realistic target sizing. Use Distance from High and Distance from Low to assess whether a pullback entry is available or whether price has already extended beyond a reasonable entry point.

[b]Mean-Reversion Context[/b]

When ADF is below 0, Z-Score is above ±1.5, and Directionality Relative is below 1.0X, the market structure favors mean-reversion setups. Distance from High and Low identifies the magnitude of the current displacement from structure. Relative Volume below 1.0X in this context supports a low-conviction, fading approach.

[b]Position Sizing[/b]

All dollar-denominated metrics — ADR$, ATR$, Distance from High$, Distance from Low$ — are scaled by syminfo.pointvalue, making them directly usable for dollar-based risk models. For example: if ATR$ reads 300$, a 1-ATR stop on a standard NQ contract represents $300 of risk per contract with no manual conversion required.


[b]Inputs[/b]

[b]Table Location[/b] — Default: Top Center. Repositions the dashboard anywhere on the chart. Available positions: Bottom Right, Bottom Center, Bottom Left, Middle Right, Middle Center, Middle Left, Top Right, Top Center, Top Left.


[b]Compatibility[/b]

Recommended for futures markets where syminfo.pointvalue is meaningful (NQ, ES, CL, GC, 6E, and others). Compatible with all asset classes and all timeframes. Renders as an overlay table directly on the price chart with no sub-pane required. The table uses chart.fg_color throughout for full light and dark theme compatibility. All calculations run on the current symbol and timeframe with no secondary data requests, keeping the indicator lightweight and fast.


[b]Notes[/b]

This indicator is published open source. Study, adapt, and build on it freely.

© OmegaTools — Professional quantitative tools for serious traders.

## Source Code

````pine
// © OmegaTools

//@version=6
indicator("Risk Analysis [OmegaTools]", 'Risk', overlay = true)

locinp = input.string('Top Center', 'Table Location', ['Bottom Right', 'Bottom Center', 'Bottom Left', 'Middle Right', 'Middle Center', 'Middle Left', 'Top Right', 'Top Center', 'Top Left'])

// Calculations

cl = close
vm = volume
pv = syminfo.pointvalue

adf = ta.correlation(close - close[1], close[1], 100) * 10 + 0.5

dr = math.max(high - close, close - open)
tr = (high - low)

adr = math.avg(ta.rma(dr, 11), ta.sma(dr, 34)) * pv
atr = math.avg(ta.rma(tr, 11), ta.sma(tr, 34)) * pv
directionality = adr / atr * 100
directionalityrelative = directionality[1] / ta.sma(directionality[1], 50)

hh = ta.highest(high, 11)
ll = ta.lowest(low, 11)

distfromh = (hh - cl) * pv
distfroml = (cl - ll) * pv

relvol = ta.sma(vm, 5) / ta.sma(vm, 21)
zscore = (cl - ta.sma(cl, 21)) / ta.stdev(cl, 21)

loc = switch locinp
    'Bottom Right' => position.bottom_right
    'Bottom Center' => position.bottom_center
    'Bottom Left' => position.bottom_left
    'Middle Right' => position.middle_right
    'Middle Center' => position.middle_center
    'Middle Left' => position.middle_left
    'Top Right' => position.top_right
    'Top Center' => position.top_center
    'Top Left' => position.top_left
    => position.bottom_right

// Plotting

var tab = table.new(loc, 10, 10)
tab.cell(1, 1, 'Directionality', text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80))
tab.cell(1, 2, 'Volatility', text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80))
tab.cell(1, 3, '', text_color = chart.fg_color)
tab.cell(2, 1, str.tostring(adr, '#.#') + '$', text_color = chart.fg_color, text_formatting = text.format_bold)
tab.cell(2, 2, str.tostring(atr, '#.#') + '$', text_color = chart.fg_color, text_formatting = text.format_bold)
tab.cell(2, 3, str.tostring(directionalityrelative, '#.#') + 'X', text_color = chart.fg_color, text_formatting = text.format_bold, tooltip = 'How much is the current directionality relative to the volatility, considering the recent price data')

tab.cell(3, 1, 'Distance from High', text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80))
tab.cell(3, 2, 'Distance from Low', text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80))
tab.cell(4, 1, str.tostring(distfromh, '#.#') + '$', text_color = chart.fg_color, text_formatting = text.format_bold)
tab.cell(4, 2, str.tostring(distfroml, '#.#') + '$', text_color = chart.fg_color, text_formatting = text.format_bold)

tab.cell(5, 1, 'ADF', text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80))
tab.cell(5, 2, 'RelVolume', text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80))
tab.cell(5, 3, 'ZScore', text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80))
tab.cell(6, 1, str.tostring(adf, '#.##'), text_color = chart.fg_color, text_formatting = text.format_bold, tooltip = 'Above 0 -> Strong trend \n Below 2 -> Weak Trend')
tab.cell(6, 2, str.tostring(relvol, '#.#') + 'X', text_color = chart.fg_color, text_formatting = text.format_bold)
tab.cell(6, 3, str.tostring(zscore, '#.#'), text_color = chart.fg_color, text_formatting = text.format_bold)

// End of Script
````
