# Terminal Velocity Stop | Lyro RS

- url: https://www.tradingview.com/script/7YXrxMjV-Terminal-Velocity-Stop-Lyro-RS/
- type: indicator
- pine_id: PUB;e4b3de3ee1cf40b9b4e64b108d853759
- version: 1.0

## Description

[b]Overview: [/b]
Terminal Velocity Stop is an ATR-based trailing stop that borrows a physics concept for its trailing logic: a falling object stops accelerating once it hits terminal velocity. Instead of letting a single vertical candle snap the stop right under price, this stop's per-bar movement is hard-capped at a maximum speed, so it keeps a controlled distance through violent moves and only closes the gap gradually once the market settles.

[b]Key Features[/b]
[list]
[*]ATR-Based Stop Targeting: Calculates a bullish and bearish stop target using independent ATR multipliers, allowing asymmetric distance in uptrends versus downtrends.
[*]Terminal Velocity Cap: Limits how far the stop can travel per bar (in ATR terms), so parabolic candles cannot yank the stop into the noise — the stop always approaches its target at a controlled, capped speed.
[*]Directional Trailing Logic: The stop only tightens in the direction of the current trend and flips direction (with a fresh target) once price closes through it.
[*]Trend Cloud Fill: Fills the space between price and the stop line, shaded and colored to reflect current trend direction and give a clear visual sense of the cushion between price and the stop.
[*]Flip Markers: Plots a marker dot at the exact bar where the stop flips direction, making trend reversals easy to spot at a glance.
[*]Candle Coloring: Colors chart candles according to the current stop direction for immediate visual alignment between price action and trend state.
[*]Customizable Visuals: Choose from 4 preset palettes — Classic, Mystic, Accented, Royal — or define your own custom bullish/bearish colors.
[/list]

[b]How It Works[/b]
[list=1]
[*]ATR Calculation – Computes the Average True Range over the chosen length as the base volatility measure.
[*]Target Calculation – Sets a bullish target below price or bearish target above price, offset by the respective ATR multiplier.
[*]Speed Capping – Limits the stop's movement toward its target each bar to a maximum of the Terminal Velocity setting (in ATR per bar), regardless of how far the target has moved.
[*]Directional Trailing – In an uptrend the stop only ratchets upward toward its target; in a downtrend it only ratchets downward, never loosening.
[*]Flip Detection – When price closes beyond the current stop, direction flips and a new stop target is established on the opposite side of price.
[*]Visualization – Plots the stop line with a glow effect, fills the trend cloud between price and stop, marks flips, and colors candles to match the current direction.
[/list]

[b]Practical Use[/b]
[list]
[*]Trailing Stop Management – Use the plotted stop line as a dynamic trailing stop level for open positions, adjusting for the asymmetric up/down multipliers to suit your risk tolerance.
[*]Volatility Spike Protection – The Terminal Velocity cap helps avoid getting stopped out prematurely during a single volatile candle by preventing the stop from moving too aggressively in one bar.
[*]Trend Direction Read – Use flip markers and candle coloring as a quick visual cue for the prevailing trend direction.
[*]Cushion Awareness – Watch the width of the trend cloud to gauge how much room price currently has before triggering a stop flip.
[/list]

[b]Customization[/b]
[list]
[*]Adjust ATR Length to tune stop responsiveness to volatility.
[*]Set independent + and - Multipliers to control stop distance separately for uptrends and downtrends.
[*]Adjust Terminal Velocity to control the maximum per-bar speed of the stop.
[*]Pick a preset palette or define fully custom bullish/bearish colors.
[/list]

[b]⚠️Disclaimer[/b]
This indicator is a tool for technical analysis and does not provide guaranteed results. It should be used in conjunction with other analysis methods and proper risk management practices. The creators of this indicator are not responsible for any financial decisions made based on its signals.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LyroRS

//@version=6
indicator("Terminal Velocity Stop | Lyro RS", "TVS | Lyro RS", overlay = true)

//---------------------------------------------------------------------------------------------------------------------{
//Settings
//---------------------------------------------------------------------------------------------------------------------{
atrLen = input.int(14, 'ATR Length', minval = 1, group = 'Settings')

mult   = input.float(3.0, '+ Multiplier', minval = 0.5, step = 0.25
  , tooltip = 'Distance of the stop target from price'
  , group = 'Settings')

multm  = input.float(3.0, '- Multiplier', minval = 0.5, step = 0.25
  , tooltip = 'Distance of the stop target from price in downtrends'
  , group = 'Settings')

vmax   = input.float(0.3, 'Terminal Velocity', minval = 0.05, maxval = 2, step = 0.05
  , tooltip = 'Maximum speed of the stop in ATR per bar. However violent the move, the stop can never travel faster than this — parabolic candles cannot yank it into the noise'
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
//Terminal Velocity Stop
//---------------------------------------------------------------------------------------------------------------------{
//A falling object stops accelerating at terminal velocity. This stop
//chases its ATR target but its per-bar travel is hard-capped: after
//a vertical candle a normal stop teleports right under price and the
//first pause knocks the position out — this one keeps its distance
//and closes it at a controlled speed.
atr = ta.atr(atrLen)

var float stop = na
var int   dir  = 1

target = dir == 1 ? close - mult * atr : close + multm * atr

if na(stop)
    stop := target
else
    step = math.max(math.min(target - stop, vmax * atr), -vmax * atr)

    if dir == 1
        stop := math.max(stop, stop + step)

        if close < stop
            dir  := -1
            stop := close + multm * atr
    else
        stop := math.min(stop, stop + step)

        if close > stop
            dir  := 1
            stop := close - mult * atr

flipUp   = dir == 1 and dir[1] == -1
flipDown = dir == -1 and dir[1] == 1

css = dir == 1 ? UpC : DnC

//---------------------------------------------------------------------------------------------------------------------{
//Visuals
//---------------------------------------------------------------------------------------------------------------------{
plot(dir == 1 and not flipUp ? stop : na, 'Bull Stop [Glow]', color.new(UpC, 80), 6, plot.style_linebr, editable = false)
plot(dir == 1 and not flipUp ? stop : na, 'Bull Stop', UpC, 2, plot.style_linebr)
plot(dir == -1 and not flipDown ? stop : na, 'Bear Stop [Glow]', color.new(DnC, 80), 6, plot.style_linebr, editable = false)
plot(dir == -1 and not flipDown ? stop : na, 'Bear Stop', DnC, 2, plot.style_linebr)

pStop  = plot(stop, 'Stop Anchor', na, editable = false)
pPrice = plot(close, 'Price Anchor', na, editable = false)
fill(pStop, pPrice,
     dir == 1 ? stop : close, dir == 1 ? close : stop,
     dir == 1 ? color.new(UpC, 90) : color.new(DnC, 50),
     dir == 1 ? color.new(UpC, 50) : color.new(DnC, 90),
     'Trend Cloud')

plot(flipUp or flipDown ? stop : na, 'Flip Dot', color.new(css, 0), 4, plot.style_circles, join = false)
plotcandle(open, high, low, close, color= css, wickcolor= css, bordercolor= css, force_overlay= true)

//---------------------------------------------------------------------------------------------------------------------{
//Alerts
//---------------------------------------------------------------------------------------------------------------------{
alertcondition(flipUp, 'Bullish Flip', 'TVS | Lyro RS: Bullish stop flip on {{ticker}} ({{interval}})')
alertcondition(flipDown, 'Bearish Flip', 'TVS | Lyro RS: Bearish stop flip on {{ticker}} ({{interval}})')

//---------------------------------------------------------------------------------------------------------------------}
````
