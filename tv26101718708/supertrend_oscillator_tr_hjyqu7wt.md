# Supertrend Oscillator | TR

- url: https://www.tradingview.com/script/HjyQu7WT-Supertrend-Oscillator-TR/
- type: indicator
- pine_id: PUB;68f93d10ecc54d939f539994b5bcf9f6
- version: 2.0

## Description

🎯 Overview
Supertrend Oscillator transforms the classic Supertrend (which plots a directional line on price) into a bounded oscillator that ranges from -100% to +100%. It measures how far price is from the Supertrend line relative to the ATR‑based bandwidth, giving a clear, normalised view of trend strength. The indicator keeps all the familiar Supertrend logic but adds gradient candle coloring, dynamic fills, nine color themes, entry signals, and a persistent trend table – turning a trend‑following line into a full visual momentum system.

⚙️ Core Calculations
1. Standard Supertrend
Source: hl2 (high+low / 2)

ATR Period: default 10

Factor: default 3

The Supertrend line and direction (pineDir) are computed using the classic Pine Script logic:

pineDir = -1 → uptrend (price above Supertrend)

pineDir = +1 → downtrend (price below Supertrend)

2. Oscillator (%)
Uptrend (pineDir = -1): positive values (0 to +100)

Downtrend (pineDir = +1): negative values (0 to -100)

The result is clamped to [-100, +100].

3. Normalised Percent (0..1)
Over the last 70 bars, percent is re‑scaled to a 0–1 range. Used for gradient candle coloring (smooth transition between bearish and bullish theme colors).

4. Momentum & Fill Transparency
Momentum = absolute 5‑bar change of percent

Normalised over a 50‑bar max → normMomentum

Fill transparency = 35 - (normMomentum × 25) clamped 0–100
→ Higher momentum = less transparent (more visible fill).

🎨 Visual Features
9 Color Themes
Same palette as the previous Williams %R indicator:

Classic, Modern, Heat, Robust, Accented, Monochrome, Moderate, Aqua, Cosmic.

Each theme defines UpC (bullish color) and DnC (bearish color).

Gradient Candles
Candle color interpolates between DnC and UpC based on the normalised percent.

Overlay on the price chart (plotcandle).

Dynamic Fills (between oscillator and zero line)
Overbought fill (percent > 0) – gradient from solid UpC (at +100) to transparent (at 0)

Oversold fill (percent < 0) – gradient from transparent (at 0) to solid DnC (at -100)

Trend‑direction fill – only fills the side of the current trend (bullish or bearish), with momentum‑based transparency. Higher momentum = less transparent.

Supertrend Overlay (optional)
Plot Chart toggle (false by default). When enabled, plots the classic Supertrend lines directly on the price pane:

Uptrend line (green) when pineDir = -1

Downtrend line (red) when pineDir = +1

Signal Markers
LONG (Bull_Cross): percent crosses above zero → green triangle below bar.

SHORT (Bear_Cross): percent crosses below zero → red triangle above bar.

Background Tint
Very light bullish / bearish tint matching the active trend.

Trend Table (middle‑right corner)
Shows “BULLISH” (⬆️) or “BEARISH” (⬇️) in large colored text.

Floating Value Label
On the last bar, shows the current percent value (e.g., 42.35%) near the oscillator line, with a semi‑transparent background matching the trend color.

📈 Signal System
Entry Signals
LONG (Bull_Cross): percent crosses above 0
→ Occurs when price moves from below Supertrend to above it, pushing the oscillator from negative into positive territory.

SHORT (Bear_Cross): percent crosses below 0

Trend Persistence
Trend_Supertrend stores the last confirmed direction:

1 = bullish (percent > 0)

-1 = bearish (percent < 0)

The trend state only changes on a zero‑line cross – prevents flickering near the threshold.

Overbought / Oversold Interpretation
+100 → price is exactly one ATR‑bandwidth above the Supertrend (strong uptrend).

-100 → price is exactly one ATR‑bandwidth below the Supertrend (strong downtrend).

Crossing zero indicates the price has just crossed the Supertrend line – a classic reversal signal.

Divergence Possibility
Although not explicitly coded, the oscillator’s raw percent value can be used to spot divergences:

Price makes a higher high but percent makes a lower high → bearish divergence.

Price makes a lower low but percent makes a higher low → bullish divergence.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tiagorocha1989
//                              ████████╗ ████████╗  ████████╗  ███████╗   ██████╗        ██████╗   ██████╗   ██████╗ ██╗   ██╗ ████████╗
//                              ╚══██╔══╝ ╚══██╔══╝  ██╔═══██║  ██╔════╝  ██╔═══██╗       ██╔══██╗ ██╔═══██╗ ██╔════╝ ██║   ██║ ██╔═══██║
//                                 ██║       ██║     ████████║  ██║ ███║  ██║   ██║       ██████╔╝ ██║   ██║ ██║      ████████║ ████████║
//                                 ██║       ██║     ██╔═══██║  ██║  ██║  ██║   ██║       ██╔══██╗ ██║   ██║ ██║      ██║   ██║ ██╔═══██║
//                                 ██║    ████████╗  ██║   ██║  ███████║  ╚██████╔╝       ██║  ██║ ╚██████╔╝ ╚██████╗ ██║   ██║ ██║   ██║
//@version=6
indicator('Supertrend Oscillator | TR', 'Supertrend Oscillator | TR →', false)
//╔═════════════════╗
//║     Input's     ║
//╚═════════════════╝
Color_Mode =    input.string('Classic', 'Color Choice', group='🎨 Color', options=['Classic','Modern','Heat','Robust','Accented','Monochrome','Moderate','Aqua','Cosmic'])
Chart_Plot =    input.bool(false, 'Plot Chart', group='⚙️ Supertrend Setting')
atrPeriod =     input.int(10, 'ATR Period', minval=1, group='⚙️ Supertrend Setting')
factor =        input.float(3, 'Factor', minval=1, step= 0.1, group='⚙️ Supertrend Setting')
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
pine_supertrend(factor, atrPeriod) =>
    src = hl2
    atr = ta.atr(atrPeriod)
    upperBand = src + factor * atr
    lowerBand = src - factor * atr
    prevLowerBand = nz(lowerBand[1])
    prevUpperBand = nz(upperBand[1])

    lowerBand := lowerBand > prevLowerBand or close[1] < prevLowerBand ? lowerBand : prevLowerBand
    upperBand := upperBand < prevUpperBand or close[1] > prevUpperBand ? upperBand : prevUpperBand

    var float superTrend = na
    var int   direction = na

    if barstate.isfirst
        direction := close > upperBand ? -1 : 1
        superTrend := direction == -1 ? lowerBand : upperBand
    else
        if nz(superTrend[1]) == nz(upperBand[1])
            direction := close > upperBand ? -1 : 1
        else
            direction := close < lowerBand ? 1 : -1
        superTrend := direction == -1 ? lowerBand : upperBand

    [superTrend, direction, atr]

[pineST, pineDir, atr] = pine_supertrend(factor, atrPeriod)
bandWidth = factor * atr
safeBandWidth = math.max(bandWidth, 1e-10)
diff = close - pineST
percent = pineDir < 0 ? math.min(100, math.max(0,  (diff / safeBandWidth) * 100)) : math.max(-100, math.min(0, (diff / safeBandWidth) * 100))
momentum = math.abs(percent - nz(percent[5], percent))
maxMomentum = ta.highest(momentum, 50)
normMomentum = maxMomentum > 0 ? math.min(momentum / maxMomentum, 1) : 0
Fill_Transp = int(math.max(0, math.min(100, 35 - (normMomentum * 25))))
Min_percent = ta.lowest(percent, 70)
Max_percent = ta.highest(percent, 70)
Range_percent = Max_percent - Min_percent
Norm_percent = Range_percent != 0 ? (percent - Min_percent) / Range_percent : 0.5
Bar_Color = color.from_gradient(Norm_percent, 0, 1, DnC, UpC)
Bull_Cross = ta.crossover(percent, 0)
Bear_Cross = ta.crossunder(percent, 0)
//╔═════════════════════════╗
//║     Trend Condition     ║
//╚═════════════════════════╝
var Trend_Supertrend = 0
Trend_Supertrend := pineDir  == -1 ? 1 : pineDir  == 1 ? -1 : nz(Trend_Supertrend[1])
//╔════════════════════════╗
//║          Plot          ║
//╚════════════════════════╝
plot(Chart_Plot ? pineDir < 0 ? pineST : na : na, 'Up Trend Line', color.green, 2, plot.style_linebr, force_overlay=true)
plot(Chart_Plot ? pineDir > 0 ? pineST : na : na, 'Down Trend Line', color.red,   2, plot.style_linebr, force_overlay=true)
percentPlot = plot(percent, 'Força da Tendência (%)', color = Trend_Supertrend == 1 ? UpC : DnC, linewidth=2, style=plot.style_line)
zeroPlot = plot(0, 'Zero', color.gray, linewidth=1, style=plot.style_line, display=display.all - display.pane - display.status_line)
fill(percentPlot, zeroPlot, top_color = percent > 0 ? color.new(UpC, Fill_Transp) : color.new(UpC, 100), bottom_color = percent > 0 ? color.new(UpC, 100) : color.new(UpC, 100), title='Overbought  Fill')
fill(percentPlot, zeroPlot, 0, -200, top_color = color.new(DnC, 100), bottom_color = color.new(DnC, 0), title = 'Oversold Fill')
fill(percentPlot, zeroPlot, (Trend_Supertrend == -1 ? percent : 0), Trend_Supertrend == 1 ? 0 : (Trend_Supertrend == -1 ? 0 : percent), Trend_Supertrend == -1 ? color.new(DnC, Fill_Transp) : #00000000,  Trend_Supertrend == -1 ? #00000000 : color.new(UpC, Fill_Transp), title = 'Dynamic Fill')
plotcandle(open, high, low, close, 'Bar Color', Bar_Color, Bar_Color, bordercolor=Bar_Color, force_overlay=true)
plotshape(Bull_Cross, 'LONG', shape.triangleup, location.belowbar, UpC, 0, size=size.small, force_overlay=true)
plotshape(Bear_Cross, 'SHORT', shape.triangledown, location.abovebar, DnC, 0, size=size.small, force_overlay=true)
bgcolor(Trend_Supertrend == 1 ? color.new(UpC, 95) : Trend_Supertrend == -1 ? color.new(DnC, 95) : na, title='Zone Background', force_overlay=true)
//╔════════════════════════╗
//║          VIEW          ║
//╚════════════════════════╝
var table Table_Supertrend = table.new(position.middle_right, 1, 1, border_width=1)
var label SupertrendLabel = na

if barstate.islast
    table.cell(Table_Supertrend, 0, 0, text = Trend_Supertrend == 1 ? '⬆️ BULLISH' : '⬇️ BEARISH', text_color = Trend_Supertrend == 1 ? UpC : DnC, text_size = size.huge)
    
    if not na(SupertrendLabel)
        label.delete(SupertrendLabel)
    SupertrendLabel := label.new(bar_index + 5, percent, text = str.tostring(percent, '#.##') + '%', color = Trend_Supertrend == 1 ? color.new(UpC, 20) : color.new(DnC, 20), style = label.style_label_left, size = size.large, textcolor = #000000)
//╔════════════════════════╗
//║         Alerts         ║
//╚════════════════════════╝
alertcondition(Bull_Cross, title='LONG', message='{{ticker}} LONG')
alertcondition(Bear_Cross, title='SHORT', message='{{ticker}} SHORT')
````
