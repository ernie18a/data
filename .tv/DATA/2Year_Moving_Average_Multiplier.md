<!-- tradingview-pine-id: PUB;c77b225dc8404b02859f1bc9f3727e88 -->
<!-- tradingviewscripts-format: 1 -->
# 2-Year Moving Average Multiplier

Source: https://www.tradingview.com/script/zQdZFK78-2-Year-Moving-Average-Multiplier/

## Description

[image]https://www.tradingview.com/x/KtAuTcL9/[/image]

2-Year Moving Average Multiplier is a long-term trend and valuation overlay for your chart.

It plots a 2-year (730-day) SMA as a lower band and a multiplier line as an upper band to form a reference channel. Price inside the band is normal. Price above the upper band triggers a red fill (overextended). Price below the lower band triggers a green fill (potentially undervalued).

───────────────────

HOW IT WORKS

Three lines are drawn on your chart:

[*]Lower Band (green) is a 730-day Simple Moving Average, your long-term baseline.
[*]Upper Band (red) is the lower band times a multiplier, giving you an upper reference.
[*]Midpoint (white, dimmed) sits right between the two bands as a center reference.
[*]Conditional fills highlight when price breaks above or below the band boundaries.

───────────────────

INPUTS

Indicator Settings:

[*]Moving Average Length is the SMA period in bars. 730 equals 2 calendar years.
[*]Moving Average Multiplier sets how far above the SMA the upper band sits.
[*]Source picks the price input for the SMA calculation.
[*]Resolution is the timeframe used for the calculation. Bands stay consistent no matter what chart resolution you view.

Plot Options:

[*]Fill background within moving averages toggles the light blue fill between bands.
[*]Fill above and below ranges toggles the red and green breakout fills.
[*]Plot moving average mid point shows or hides the midpoint line.
[*]Plot daily highs and lows overlays daily high and low lines in blue.

───────────────────

HOW TO USE

[*]Between bands means the asset is in its normal long-term range.
[*]Above upper band (red) means price is potentially overextended. Treat it as a caution signal, not an automatic sell.
[*]Below lower band (green) means price could be undervalued. Treat it as a watch signal, not an automatic buy.
[*]Adjust the multiplier to control sensitivity. Higher values mean fewer breakouts, lower values mean more.
[*]Change the length to adjust the indicator to be longer or shorter than 2 years.

───────────────────

NOTES

[*]The SMA needs 730 bars of history to stabilize. Newer assets or short history will show incomplete values early on.
[*]Works best on liquid, established instruments, most notably on Bitcoin BTCUSD.
[*]Bands are locked to the chosen resolution so they wont shift when you change your chart timeframe.

───────────────────

Disclaimer: This indicator is for educational and informational purposes only. It is not financial advice. Trading involves substantial risk of loss and past performance does not guarantee future results. Always do your own research and consult a qualified financial advisor before making investment decisions. The author assumes no liability for any losses incurred.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KevanoTrades

//@version=6

// @description Long-term trend and valuation overlay. Plots a 2-year (730-day) SMA lower band and a configurable multiplier upper band. Red fill = price above upper band (overextended). Green fill = price below lower band (potentially undervalued). Works consistently across all chart resolutions.
indicator(title = '2-Year Moving Average Multiplier', shorttitle = '2Y MA Mult', overlay = true)

// Groups
const string g_settings = 'Indicator Settings'
const string g_plotOptions = 'Plot Options'

// Tooltips
const string t_length = '2 years is 730 days long, not including leap years (365 * 2 = 730).'

// Getting inputs
int i_length = input.int(defval = 730, title = 'Moving Average Length', minval = 2, tooltip = t_length, group = g_settings)
int i_mult = input.int(defval = 5, title = 'Moving Average Multiplier', minval = 2, group = g_settings)
series float i_source = input.source(defval = close, title = 'Source', group = g_settings)
string i_timeframe = input.timeframe(defval = 'D', title = 'Resolution', group = g_settings)

// Plot options
bool i_background = input.bool(defval = true, title = 'Fill background within moving averages', group = g_plotOptions)
bool i_fill = input.bool(defval = true, title = 'Fill above and below ranges', group = g_plotOptions)
bool i_midPlot = input.bool(defval = true, title = 'Plot moving average mid point', group = g_plotOptions)
bool i_dailyPlots = input.bool(defval = false, title = 'Plot daily highs and lows', group = g_plotOptions)

// Fetch daily data via request.security so everything is on the same resolution
series float dailyClose = request.security(syminfo.tickerid, i_timeframe, i_source, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
series float dailyHigh = request.security(syminfo.tickerid, i_timeframe, high, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
series float dailyLow = request.security(syminfo.tickerid, i_timeframe, low, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// Calculate 2Y SMA on daily bars — expression is evaluated on the requested resolution
series float lower2Yma = request.security(syminfo.tickerid, i_timeframe, ta.sma(i_source, i_length), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
series float upper2Yma = lower2Yma * i_mult
series float mid2Yma = (lower2Yma + upper2Yma) / 2

// Plotting
upperPlot = plot(upper2Yma, title = 'Upper 2-Year MA', color = color.new(color.red, 0), linewidth = 1, style = plot.style_line)
midPlot = plot(mid2Yma, title = 'Mid 2-Year MA', color = color.new(color.white, 75), linewidth = 1, style = plot.style_line, display = i_midPlot ? display.all : display.none)
lowerPlot = plot(lower2Yma, title = 'Lower 2-Year MA', color = color.new(color.green, 0), linewidth = 1, style = plot.style_line)
highs = plot(dailyHigh, title = 'Daily Highs', color = color.blue, display = i_dailyPlots ? display.all : display.none)
lows = plot(dailyLow, title = 'Daily Lows', color = color.blue, display = i_dailyPlots ? display.all : display.none)

// Fill with colors — comparisons use daily data so behavior is consistent across all chart timeframes
fill(lowerPlot, upperPlot, color = color.new(#90bff9, 95), title = 'Background Fill', display = i_background ? display.all : display.none)
fill(upperPlot, highs, color = (dailyClose > upper2Yma) ? color.new(color.red, 75) : na, title = 'Upper Fill', display = i_fill ? display.all : display.none)
fill(lowerPlot, lows, color = (dailyClose < lower2Yma) ? color.new(color.green, 75) : na, title = 'Lower Fill', display = i_fill ? display.all : display.none)
````
