# Trend Quality Indicator - TQI | TR

- url: https://www.tradingview.com/script/wWgA0nGW-Trend-Quality-Indicator-TQI-TR/
- type: indicator
- pine_id: PUB;ee3a2e3194b646c7aff99d577d0495df
- version: 1.0

## Description

🎯 Overview
TQI | TR (Trend Quality Indicator) is a hybrid oscillator that measures both the direction and the statistical reliability of a trend. It combines linear regression slope (trend strength) with R‑squared (goodness of fit), then normalises the result into a clean oscillator. This unique approach filters out weak or noisy trends and highlights only high‑quality moves.

Key Features
📐 Statistical Precision
Linear Regression Slope – Captures raw trend direction and steepness.

R‑Squared (R²) – Measures how well price follows a linear trend (0 = no fit, 1 = perfect fit).

ATR Normalisation – Divides slope by Average True Range to make values comparable across different volatility environments.

Smoothing – Final signal is smoothed to reduce noise.

🎨 Advanced Visualization
9 Color Themes – Classic, Modern, Heat, Robust, Accented, Monochrome, Moderate, Aqua, Cosmic.

Dynamic Fill Zones – Multi‑layer fills with transparency that reacts to momentum.

Gradient Candle Coloring – Candles smoothly transition between bearish and bullish colors based on TQI value.

Signal Markers – Clear long/short triangles on zero‑line crosses.

Trend Background – Subtle background tint matching the current trend state.

📈 Complete Signal System
Zero‑Line Crossovers – Primary entry/exit signals.

Trend Quality Value – Positive = bullish, negative = bearish; magnitude indicates strength.

Persistent Trend State – Remembers last direction until a crossover occurs.

Real‑Time Updates – Calculated on every bar.

How It Works
Calculation Logic
Linear Regression Slope – Slope of a linear regression line fitted to close over Length_TQI periods.

Normalised Slope – slope / ATR(ATR_Length_TQI). This makes the slope comparable across different price and volatility scales.

R‑Squared (R²) – Computed as sum((regression_value - mean)^2) / sum((close - mean)^2). It represents the proportion of price variance explained by the linear trend.

Raw TQI – normalised_slope * R². Multiplying by R² penalises trends that are not linear (i.e., choppy or curved moves).

Smoothed TQI – Simple moving average of raw TQI over Smooth_TQI periods. This is the final signal line.

Normalised TQI – Rescaled to a 0‑1 range using a 70‑period lookback. Used for gradient candle colors.

Dynamic Fill Transparency
Calculates momentum = |TQI - TQI[5]| (5‑bar change).

Normalises momentum against its 50‑period highest value.

Fill transparency = 35 - (norm_momentum * 25), clamped 0‑100.
Strong momentum → less transparency → more visible fill.
Weak momentum → more transparency → fill fades out.

Trend State Persistence
Trend_TQI is 1 (bullish) when smoothed TQI > 0, -1 (bearish) when < 0.

Once set, it holds until a zero‑line crossover occurs. This prevents flickering near the zero line.

Display Options
Visual Components
TQI Signal Line – Coloured by trend state (bullish/bearish) with reduced opacity.

Zero Line – Yellow horizontal line.

Fills – Three fills: above zero (bullish zone), below zero (bearish zone), and a third dynamic fill that only appears in the current trend direction. Fill transparency reacts to momentum.

Gradient Candles – Price bars change colour smoothly between the theme’s down‑color and up‑color based on normalised TQI.

Entry Signals – Triangles below (long) or above (short) bars on zero‑line crosses.

Background – Very light tint matching the trend direction.

Value Label – Shows current TQI value as a floating label near the signal line.

Trend Table – At the middle‑right, displays “Bullish”, “Bearish”, or “Neutral” with large coloured text.

Trading Signals
Entry Signals
LONG – Smoothed TQI crosses above the zero line.
→ Triangle below the bar.
→ Candles turn bullish (gradient).
→ Background tints bullish.

SHORT – Smoothed TQI crosses below the zero line.
→ Triangle above the bar.
→ Candles turn bearish.
→ Background tints bearish.

Trend Confirmation
Strong Bullish – TQI significantly above zero and rising, with low fill transparency (high momentum).

Strong Bearish – TQI significantly below zero and falling.

Weak / No Trend – TQI oscillating near zero; fills become highly transparent.

Divergence – Price makes a new high/low but TQI fails to confirm (indicates weakening trend quality).

Customization Settings
Technical Parameters
Analysis Period (Length_TQI) – Lookback for linear regression and R² (default 20).

ATR Period – Used to normalise the slope (default 14).

Smoothing – SMA period applied to raw TQI (default 5).

Visual Parameters
Color Choice – 9 themes.

Candle coloring, entry signals, background, table, and label are always shown (no explicit on/off inputs in this version, but can be added).

Alert System
TQI LONG – Triggered on bullish zero‑line cross.

TQI SHORT – Triggered on bearish zero‑line cross.
Both alerts include the ticker symbol in the message.

Benefits for Traders
🧠 Statistical Edge
Uses R‑squared to filter out “false trends” that are steep but erratic.

Normalisation via ATR makes the indicator universal across instruments and timeframes.

🎯 Clear Signal Quality
The multiplication of slope by R² means you only get strong signals when price is moving consistently in one direction.

Avoids whipsaws common in simple momentum oscillators.

⚡ Practical Applications
Trend Following – Enter when TQI crosses zero and remains on that side.

Trend Exhaustion – Watch for TQI divergences before price reversals.

Filter for Other Indicators – Use TQI to confirm signals from breakouts, moving averages, or volume indicators.

Mean Reversion Caution – Avoid counter‑trend trades when TQI shows a high‑quality trend.

Ideal Usage Scenarios
Best Market Conditions
Trending markets (strong linear moves).

Breakout confirmations – a breakout accompanied by rising TQI is more reliable.

Avoiding choppy markets – TQI will stay near zero or produce very transparent fills.

Timeframe Compatibility
Works on all timeframes.

Particularly effective on higher timeframes (1H, 4H, daily) where linear trends are more meaningful.

Lower timeframes may benefit from shorter Length_TQI and Smoothing.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tiagorocha1989
//                              ████████╗ ████████╗  ████████╗  ███████╗   ██████╗        ██████╗   ██████╗   ██████╗ ██╗   ██╗ ████████╗
//                              ╚══██╔══╝ ╚══██╔══╝  ██╔═══██║  ██╔════╝  ██╔═══██╗       ██╔══██╗ ██╔═══██╗ ██╔════╝ ██║   ██║ ██╔═══██║
//                                 ██║       ██║     ████████║  ██║ ███║  ██║   ██║       ██████╔╝ ██║   ██║ ██║      ████████║ ████████║
//                                 ██║       ██║     ██╔═══██║  ██║  ██║  ██║   ██║       ██╔══██╗ ██║   ██║ ██║      ██║   ██║ ██╔═══██║
//                                 ██║    ████████╗  ██║   ██║  ███████║  ╚██████╔╝       ██║  ██║ ╚██████╔╝ ╚██████╗ ██║   ██║ ██║   ██║
//@version=6
indicator('Trend Quality Indicator - TQI | TR', 'TQI | TR →')
//╔═════════════════╗
//║     Input's     ║
//╚═════════════════╝
Color_Mode =        input.string('Classic', 'Color Choice', group = '🎨 Color', options = ['Classic', 'Modern', 'Heat', 'Robust', 'Accented', 'Monochrome', 'Moderate', 'Aqua', 'Cosmic'])
Length_TQI =        input.int(20, 'Analysis Period', group='⚙️ TQI Setting')
ATR_Length_TQI =    input.int(14, 'ATR Period', group='⚙️ TQI Setting')
Smooth_TQI =        input.int(5, 'Smoothing', group='⚙️ TQI Setting')
//╔═════════════════╗
//║     Color       ║
//╚═════════════════╝
[UpC, DnC] = switch Color_Mode
    'Classic'       => [#008800, #ff0000]
    'Modern'        => [#ffffff, #b721ff]
    'Heat'          => [#ff0000, #87cefb]
    'Robust'        => [#ffbb00, #770737]
    'Accented'      => [#8c5cf7, #e83e8c]
    'Monochrome'    => [#e9ecef, #495057]
    'Moderate'      => [#43a047, #e53935]
    'Aqua'          => [#00a8e8, #f18f01]
    'Cosmic'        => [#e83e8c, #6f2da8]
//╔════════════════════════╗
//║      Calculation       ║
//╚════════════════════════╝
linregSlope      = ta.linreg(close, Length_TQI, 0) - ta.linreg(close, Length_TQI, 1)
normalizedSlope  = linregSlope / ta.atr(ATR_Length_TQI)
basis            = math.sum(close, Length_TQI) / Length_TQI
sumSquaresTotal  = math.sum(math.pow(close - basis, 2), Length_TQI)
sumSquaresReg    = math.sum(math.pow(ta.linreg(close, Length_TQI, 0) - basis, 2), Length_TQI)
rSquared         = sumSquaresReg / sumSquaresTotal
rSquared         := math.min(1, math.max(0, rSquared))
rawSignal = normalizedSlope * rSquared
signal    = ta.sma(rawSignal, Smooth_TQI)
min_TQI = ta.lowest(signal, 70)
max_TQI = ta.highest(signal, 70)
range_TQI = max_TQI - min_TQI
norm_TQI = range_TQI != 0 ? (signal - min_TQI) / range_TQI : 0.5
Trend_Color = color.from_gradient(norm_TQI, 0, 1, DnC, UpC)
momentum = math.abs(signal - signal[5])
max_momentum = ta.highest(momentum, 50)
norm_momentum = max_momentum > 0 ? math.min(momentum / max_momentum, 1) : 0
Fill_Transp = int(math.max(0, math.min(100, 35 - (norm_momentum * 25))))
//╔═════════════════════════╗
//║     Trend Condition     ║
//╚═════════════════════════╝
Entry_TQI = 0.0
isBull_TQI = signal > Entry_TQI
isBear_TQI = signal < Entry_TQI
Bull_TQI   = ta.crossover(signal, Entry_TQI)
Bear_TQI   = ta.crossunder(signal, Entry_TQI)

var Trend_TQI = 0
Trend_TQI := isBull_TQI ? 1 : isBear_TQI ? -1 : nz(Trend_TQI[1])
//╔═════════════════╗
//║     Plot        ║
//╚═════════════════╝
Plot_TQI       = plot(signal, 'TQI Signal', color = Trend_TQI == 1 ? color.new(UpC, 50) : Trend_TQI == -1 ? color.new(DnC, 50) : na, linewidth = 3)
Plot_Entry_TQI = plot(Entry_TQI, 'Zero Line', color = color.yellow)
fill(Plot_TQI, Plot_Entry_TQI, 0.2, Entry_TQI, top_color = color.new(UpC, Fill_Transp), bottom_color = color.new(UpC, 100), title = 'Above Fill')
fill(Plot_TQI, Plot_Entry_TQI, Entry_TQI, 0,   top_color = color.new(DnC, 100), bottom_color = color.new(DnC, Fill_Transp), title = 'Below Fill')
fill(Plot_TQI, Plot_Entry_TQI, Trend_TQI == -1 ? signal : Entry_TQI, Trend_TQI == -1 ? Entry_TQI : signal, Trend_TQI == -1 ? color.new(DnC, Fill_Transp) : #00000000, Trend_TQI == -1 ? #00000000 : color.new(UpC, Fill_Transp))
plotcandle(open, high, low, close, 'Bar Color', Trend_Color, Trend_Color, bordercolor = Trend_Color, force_overlay = true)
plotshape(Bull_TQI, 'LONG' , shape.triangleup  , location.belowbar, UpC, 0, size = size.small, force_overlay = true)
plotshape(Bear_TQI, 'SHORT', shape.triangledown, location.abovebar, DnC, 0, size = size.small, force_overlay = true)
bgcolor(Trend_TQI == 1 ? color.new(UpC, 95) : Trend_TQI == -1 ? color.new(DnC, 95) : na, title = 'Trend Background', force_overlay = true)
//╔═════════════════╗
//║     VIEW        ║
//╚═════════════════╝
var table Table_TQI = table.new(position.middle_right, 1, 1, border_width = 1)
var label TQILabel = na
if barstate.islast
    table.cell(Table_TQI, 0, 0, text = Trend_TQI == 1 ? '⬆️ Bullish' : Trend_TQI == -1 ? '⬇️ Bearish' : '➡️ Neutral', text_color = Trend_TQI == 1 ? UpC : Trend_TQI == -1 ? DnC : color.gray, text_size = size.huge)
    if not na(TQILabel)
        label.delete(TQILabel)
    TQILabel := label.new(bar_index + 5, signal, text = str.tostring(signal, '#.##'), color = Trend_TQI == 1 ? color.new(UpC, 20) : Trend_TQI == -1 ? color.new(DnC, 20) : color.gray, style = label.style_label_left, size = size.large, textcolor = #000000)
//╔═════════════════════════╗
//║         ALERTAS         ║
//╚═════════════════════════╝
alertcondition(Bull_TQI, title = 'TQI LONG', message = '{{ticker}} TQI LONG')
alertcondition(Bear_TQI, title = 'TQI SHORT', message = '{{ticker}} TQI SHORT')
````
