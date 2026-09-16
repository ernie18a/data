<!-- tradingview-pine-id: PUB;ddcbddcc9aac44f6960272bd44b4ac17 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volatility of Returns | NickJoan

Source: https://www.tradingview.com/script/AT3imZhm-Volatility-of-Returns-NickJoan/

## Description

Volatility of Returns | NickJoan

Core Idea

Volatility of Returns measures the standard deviation of logarithmic returns over a user-defined lookback window. This is the industry-standard approach to calculating historical volatility, widely used in finance for risk management, option pricing, and portfolio analysis.

The indicator displays volatility as an annualized percentage, making it easy to compare across different assets and timeframes. An optional moving average helps smooth the volatility series and identify trends in volatility itself.

Calculation Logic

The indicator follows a straightforward three-step process:

1. Log returns calculation

For each bar, the script calculates the logarithmic return:

• logRet = log(close / close[1])

2. Standard deviation calculation

The script calculates the standard deviation of log returns over the specified lookback period:

• stdevLogRet = stdev(logRet, length)

This measures how much returns typically deviate from their mean.

3. Annualization

The raw standard deviation is then annualized by multiplying by the square root of the annualization period:

• volatility = stdevLogRet × √annPeriod × 100

For daily crypto charts, the default is √365. This converts the per-bar volatility into an annualized percentage.

Chart Output

The indicator displays in a separate pane below the price chart:

Volatility line
• Shows the annualized volatility percentage
• Plotted in blue

Moving average line (optional)
• Shows the smoothed volatility trend
• User-selectable type: SMA, EMA, WMA, or RMA
• Plotted in gray with thicker linewidth
• Can be toggled off via input

Inputs

CALCULATION

• Volatility Lookback (bars): window for standard deviation calculation. Default: 90.
• Annualize: toggles annualization on/off. Default: true.
• Annualization Period: period used for annualization. Default: 365.

MOVING AVERAGE

• Show Moving Average: toggles MA overlay visibility. Default: true.
• MA Type: MA calculation method (SMA, EMA, WMA, RMA). Default: EMA.
• MA Length: MA lookback period. Default: 30.

How to Use It

Volatility level assessment

• Low volatility: calm, consolidating market
• Medium volatility: normal market conditions
• High volatility: turbulent, fast-moving market

Note: "Low" and "High" are relative to the asset class. Crypto naturally has higher volatility than stocks or forex.

Volatility trend identification

Use the moving average to identify whether volatility is rising or falling:

• Volatility above MA: elevated relative to recent trend
• Volatility below MA: suppressed relative to recent trend
• MA sloping up: volatility is increasing
• MA sloping down: volatility is decreasing

Risk management

Use volatility to adjust position sizing and risk parameters:

• High volatility: reduce position size, widen stop losses
• Low volatility: can increase position size, tighter stops
• Rising volatility: prepare for potential breakout or increased uncertainty
• Falling volatility: consolidation phase, wait for direction

Best Use Cases

• Historical volatility measurement
• Risk management and position sizing
• Volatility trend analysis
• Cross-asset volatility comparison
• Portfolio risk monitoring

Notes

The indicator is designed for daily crypto charts but works on any timeframe.

• Daily timeframe: use Annualization Period = 365
• 4H timeframe: use Annualization Period = 2190 (365 × 6)
• 1H timeframe: use Annualization Period = 8760 (365 × 24)
• Or disable annualization for raw per-bar volatility

The lookback period determines sensitivity:

• Shorter lookback (20-30 bars): more reactive to recent spikes
• Medium lookback (60-90 bars): balanced approach
• Longer lookback (180-365 bars): smooth, long-term trends

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at [https://mozilla.org/MPL/2.0/](https://mozilla.org/MPL/2.0/)
// © Nick_Joan


//@version=6
indicator(title = "Volatility of Returns | NickJoan", format = format.percent, overlay = false)


// ─── Inputs ───────────────────────────────────────────────────────────────────
length       = input.int(90, "Volatility Lookback (bars)", minval = 2, group = "CALCULATION")
annualize    = input.bool(true, "Annualize", group = "CALCULATION", tooltip = "Annualize using √period. Default: √365 for daily crypto.")
annPeriod    = input.int(365, "Annualization Period", minval = 1, group = "CALCULATION")

showMa       = input.bool(true, "Show Moving Average", group = "MOVING AVERAGE")
maType       = input.string('EMA', title = 'MA Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = "MOVING AVERAGE")
maLen        = input.int(30, title = 'MA Length', minval = 1, group = "MOVING AVERAGE")


// ─── Calculations ─────────────────────────────────────────────────────────────
// Log returns
logRet = math.log(close / close[1])

// Standard deviation of log returns
stdevLogRet = ta.stdev(logRet, length)

// Annualize
annFactor = annualize ? math.sqrt(annPeriod) : 1.0
volatility = stdevLogRet * annFactor * 100


// ─── Moving Average ───────────────────────────────────────────────────────────
ma = switch maType
    'SMA' => ta.sma(volatility, maLen)
    'EMA' => ta.ema(volatility, maLen)
    'WMA' => ta.wma(volatility, maLen)
    'RMA' => ta.rma(volatility, maLen)


// ─── Plots ────────────────────────────────────────────────────────────────────
plot(volatility, title = "Volatility (%)", color = color.blue)
plot(showMa ? ma : na, title = 'Moving Average', linewidth = 2, color = color.new(color.gray, 70))
````
