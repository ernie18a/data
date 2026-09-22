<!-- tradingview-pine-id: PUB;955ce51b5d574be187360c5371472aa7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Gaussian Trend Filter | Lyro RS

Source: https://www.tradingview.com/script/BUFUAdTn-Gaussian-Trend-Filter-Lyro-RS/

## Description

█ Overview

Gaussian Blur Trend Filter | Lyro RS is a trend-following overlay that runs price through a two-pass Gaussian blur to build a smoothed baseline, then classifies the market as bullish, bearish, or neutral from the slope of that baseline combined with price's position relative to it.

Where a single moving average reacts to every wiggle in price, this indicator convolves the same Gaussian kernel over price twice. The second pass smooths the already-smoothed series, producing a wider effective kernel with cleaner slope behaviour than a single-pass filter of the same length — fewer false slope changes, later noise-driven flips.

[image]https://www.tradingview.com/x/2fDehXvX/[/image]

The result is a coloured baseline with a filled cloud back to price, flip labels marking the exact bar of a trend change, and recoloured candles so the whole chart reflects the current state at a glance.

█ How It Works

⚪ Gaussian Weighting
Each bar in the lookback window is weighted using a Gaussian curve rather than a flat or linear taper, so nearby bars dominate but older bars still contribute smoothly instead of dropping out abruptly.

[pine]
w = math.exp(-(i * i) / (2.0 * sigma * sigma))
[/pine]

sigma is set as a percentage of Kernel Length via the Blur Width input, which shapes how quickly that weighting falls off.

⚪ Two-Pass Convolution
The first pass smooths raw close into an intermediate series. The second pass smooths that already-blurred series with the same kernel. Two convolved Gaussians combine into one wider, cleaner Gaussian — this is what removes the "noise of the noise" that a single pass leaves behind.

[image]https://www.tradingview.com/x/RO5halYV/[/image]

⚪ Trend Classification
The trend only flips to bullish when the baseline is rising and price closes above it, and only flips to bearish when the baseline is falling and price closes below it. Outside of those conditions the previous state is held, so the trend is sticky rather than flickering on ambiguous bars.

⚪ Visual Layer
The baseline is drawn as a stacked outer-glow / glow / core-line plot for a soft neon look, the raw first-pass line is kept visible but faint as a reference, the space between baseline and price is filled as a trend cloud, and candles are recoloured to match the active trend.

█ How to Use

⚪ Reading the Cloud
Cloud colour and fill direction show the current bias and how far price has stretched from the smoothed baseline.

⚪ Flip Labels
"Long" and "Short" labels mark the exact bar where trend state changed — useful as an entry trigger or as confirmation of a bias shift.

[image]https://www.tradingview.com/x/5jQP13Tr/[/image]

⚪ Tuning Kernel Length
Shorter length reacts faster and produces more flips; longer length is smoother but lags further behind price. Lower timeframes generally want shorter settings.

⚪ Tuning Blur Width
Controls how sharply the Gaussian weighting falls off relative to Kernel Length. Lower values keep more first-pass detail; higher values flatten the weighting curve for extra smoothness.

[image]https://www.tradingview.com/x/4E3K8myg/[/image]

⚪ Alerts
Two built-in alert conditions — Bullish Flip and Bearish Flip — let you get notified the moment the trend state changes without watching the chart.

█ Settings

[*]Kernel Length (5–100, default 30) — number of bars used in the Gaussian window for both blur passes.
[*]Blur Width (0.1–1.0, step 0.05, default 0.35) — Gaussian sigma as a fraction of Kernel Length.
[*]Custom Color Palette — Classic, Mystic (default), Accented, or Royal preset schemes.
[*]Use Custom Palette — overrides the preset with your own Up/Down colours.

█ Important
The double Gaussian pass trades reactivity for a cleaner slope — the baseline will lag raw price more than a single-pass filter of the same length. Reduce Kernel Length on faster markets or lower timeframes if that lag feels excessive. Trend state is confirmed on bar close and does not repaint historically, though the state of the currently forming bar can still change until it closes.

This script is provided for educational and informational purposes only and does not constitute financial advice. Past performance of any strategy, indicator, or trading approach does not guarantee future results.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LyroRS

//@version=6
indicator("Gaussian Trend Filter | Lyro RS", "GTF | Lyro RS", overlay = true)

//---------------------------------------------------------------------------------------------------------------------{
//Settings
//---------------------------------------------------------------------------------------------------------------------{
length   = input.int(30, 'Kernel Length', minval = 5, maxval = 100, group = 'Settings')

sigmaPct = input.float(0.35, 'Blur Width', minval = 0.1, maxval = 1, step = 0.05
  , tooltip = 'Gaussian sigma as a fraction of kernel length'
  , group = 'Settings')

//---------------------------------------------------------------------------------------------------------------------{
//Color
//---------------------------------------------------------------------------------------------------------------------{
ColMode = input.string('Mystic', 'Custom Color Palette', inline = 'drop', options = ['Classic', 'Mystic', 'Accented', 'Royal'], display = display.none, group = 'Color', tooltip = 'Choose a predefined color scheme for indicator visualization.')
cpyn    = input.bool(false, 'Use Custom Palette', group = 'Color', display = display.none)
cp_UpC  = input.color(#00ff00, 'Custom Up', inline = 'Custom Palette', group = 'Color', display = display.none)
cp_DnC  = input.color(#ff0000, 'Custom Down', inline = 'Custom Palette', group = 'Color', display = display.none)

color UpC = na
color DnC = na

switch ColMode
    "Classic" =>
        UpC := #00E676
        DnC := #880E4F
    "Mystic" =>
        UpC := #30FDCF
        DnC := #E117B7
    "Accented" =>
        UpC := #9618F7
        DnC := #FF0078
    "Royal" =>
        UpC := #FFC107
        DnC := #673AB7

if cpyn
    UpC := cp_UpC
    DnC := cp_DnC

//---------------------------------------------------------------------------------------------------------------------{
//Two-Pass Blur
//---------------------------------------------------------------------------------------------------------------------{
//The image-processing trick applied to price: one gaussian pass
//removes noise, a SECOND pass over the already-blurred series
//removes the noise of the noise. Two convolved gaussians form a
//wider gaussian with far cleaner slope behaviour than one big pass.
gaussma(s, len, sigma) =>
    num = 0.0
    den = 0.0
    for i = 0 to len - 1
        w = math.exp(-(i * i) / (2.0 * sigma * sigma))
        num += s[i] * w
        den += w
    num / den

blur1 = gaussma(close, length, length * sigmaPct)
blur2 = gaussma(blur1, length, length * sigmaPct)

var int trend = 0
if blur2 > blur2[1] and close > blur2
    trend := 1
else if blur2 < blur2[1] and close < blur2
    trend := -1

flipUp   = trend == 1  and trend[1] != 1
flipDown = trend == -1 and trend[1] != -1

css = trend == 1 ? UpC : trend == -1 ? DnC : color.gray

//---------------------------------------------------------------------------------------------------------------------{
//Visuals
//---------------------------------------------------------------------------------------------------------------------{
plot(blur1, 'First Pass', color.new(css, 70), 1)

plot(blur2, 'Blur [Outer Glow]', color.new(css, 90), 10, editable = false)
plot(blur2, 'Blur [Glow]', color.new(css, 78), 5, editable = false)
pBase  = plot(blur2, 'Gaussian Blur', css, 2)
pPrice = plot(close, 'Price Anchor', na, editable = false)
fill(pBase, pPrice, color.new(css, 92), 'Trend Cloud')

plotshape(flipUp, 'Long Flip', shape.labelup, location.belowbar, UpC, text = '𝓛𝓸𝓷𝓰', textcolor = #000000, size = size.small)
plotshape(flipDown, 'Short Flip', shape.labeldown, location.abovebar, DnC, text = '𝓢𝓱𝓸𝓻𝓽', textcolor = #000000, size = size.small)

//---------------------------------------------------------------------------------------------------------------------{
//Alerts
//---------------------------------------------------------------------------------------------------------------------{
alertcondition(flipUp, 'Bullish Flip', 'GBTF | Lyro RS: Bullish blur flip on {{ticker}} ({{interval}})')
alertcondition(flipDown, 'Bearish Flip', 'GBTF | Lyro RS: Bearish blur flip on {{ticker}} ({{interval}})')

//---------------------------------------------------------------------------------------------------------------------}
plotcandle(open, high, low, close, color= css, wickcolor = css, bordercolor= css, force_overlay = true)
````
