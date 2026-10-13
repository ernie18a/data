<!-- tradingview-pine-id: PUB;e827857671ec484abe1a41693d08a33e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Regime

Source: https://www.tradingview.com/script/0zkOGjVH/

## Description

Volatility Regime

OVERVIEW
This indicator classifies the current market into one of three volatility regimes — Low, Medium, or High — and displays them in a separate panel below the price chart. Rather than measuring volatility in absolute terms, it evaluates how current volatility compares to its own recent history, so the classification adapts automatically to any instrument and timeframe without needing manual recalibration.

METHODOLOGY
Volatility is calculated as the standard deviation of logarithmic returns over a user-defined lookback period. That value is then compared to its own distribution over a longer historical window using a percentile rank calculation. The result is a 0-100 reading showing where current volatility stands relative to its own recent history, rather than relying on a fixed, one-size-fits-all threshold that would behave differently across instruments.

COMPONENTS
- Volatility Percentile Rank line: plots the 0-100 percentile reading of current volatility, colored according to the active regime.
- Threshold lines: two dashed horizontal lines mark the Low and High volatility thresholds (default 33 and 66), both adjustable.
- Panel background shading: the background of the indicator panel is tinted according to the active regime for quick visual reference.
- Regime label: a label on the most recent bar displays the current regime as text (LOW / MEDIUM / HIGH).

REGIMES
- Low Volatility Regime: percentile rank at or below the low threshold. Current volatility is compressed relative to its recent history.
- Medium Volatility Regime: percentile rank between the two thresholds. A transitional or average volatility state.
- High Volatility Regime: percentile rank at or above the high threshold. Current volatility is expanded relative to its recent history.

PURPOSE
This tool adds volatility context to trading decisions rather than generating direct buy or sell signals. Market behavior tends to differ meaningfully across volatility regimes, and being aware of the active regime can help with position sizing, stop placement, and identifying which type of setups are more likely to be relevant at a given time.

HOW TO USE IT
- Check the current regime shown in the panel before evaluating a setup on the main chart.
- Consider adjusting position size and stop-loss distance according to the active regime — wider stops and smaller size are generally more appropriate in high volatility conditions, and the opposite in low volatility conditions.
- A prolonged Low Volatility Regime can indicate the market is compressing and may be approaching an expansion phase.
- Volatility Length, Percentile Rank Lookback, and both threshold levels are adjustable in the settings to fit different instruments and timeframes.

NOTES
This indicator is a contextual tool intended to support discretionary or systematic analysis. It does not predict market direction and should be used alongside a broader trading methodology and proper risk management.

---

## Source Code

````pine
//@version=6
indicator("Volatility Regime", shorttitle="Vol Regime", overlay=false)

// ---------------- Inputs ----------------
volLength   = input.int(20, title="Volatility Length", minval=1, group="Volatility")
rankLength  = input.int(100, title="Percentile Rank Lookback", minval=10, group="Volatility")

lowThresh   = input.float(33.0, title="Low Volatility Threshold (Percentile)", minval=0, maxval=100, group="Thresholds")
highThresh  = input.float(66.0, title="High Volatility Threshold (Percentile)", minval=0, maxval=100, group="Thresholds")

lowColor    = input.color(color.new(color.green, 0),  title="Low Volatility Color",    group="Colors")
medColor    = input.color(color.new(color.yellow, 0), title="Medium Volatility Color", group="Colors")
highColor   = input.color(color.new(color.red, 0),    title="High Volatility Color",   group="Colors")

// ---------------- Volatility Calculation ----------------
// Standard deviation of log returns as the base volatility measure
logReturn = math.log(close / close[1])
vol = ta.stdev(logReturn, volLength)

// Percentile rank of current volatility within the lookback window (0-100)
volRank = ta.percentrank(vol, rankLength)

// ---------------- Regime Classification ----------------
// 1 = Low, 2 = Medium, 3 = High
regime = volRank <= lowThresh ? 1 : volRank >= highThresh ? 3 : 2

regimeColor = regime == 1 ? lowColor : regime == 2 ? medColor : highColor
regimeText  = regime == 1 ? "LOW" : regime == 2 ? "MEDIUM" : "HIGH"

// ---------------- Plots ----------------
plot(volRank, title="Volatility Percentile Rank", color=regimeColor, linewidth=2)

hline(lowThresh, title="Low Threshold", color=color.gray, linestyle=hline.style_dashed)
hline(highThresh, title="High Threshold", color=color.gray, linestyle=hline.style_dashed)
hline(0, title="Zero Line", color=color.new(color.gray, 70))
hline(100, title="Hundred Line", color=color.new(color.gray, 70))

// Shade the panel background according to the active regime
bgcolor(color.new(regimeColor, 85))

// ---------------- Current Regime Label ----------------
var label regimeLabel = na

if barstate.islast
    if not na(regimeLabel)
        label.delete(regimeLabel)
    regimeLabel := label.new(bar_index, volRank, text=regimeText, xloc=xloc.bar_index, style=label.style_label_left, color=regimeColor, textcolor=color.white, size=size.small)
````
