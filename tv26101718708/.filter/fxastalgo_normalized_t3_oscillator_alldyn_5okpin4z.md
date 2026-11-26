# FxASTAlgo Normalized T3 Oscillator [ALLDYN]

- url: https://www.tradingview.com/script/5okPIN4Z-FxASTAlgo-Normalized-T3-Oscillator-ALLDYN/
- type: indicator
- pine_id: PUB;4f23574e343b4c10b255733118417589
- version: 1.0

## Description

[b]◈🛡 FxASTAlgo Normalized T3 Oscillator [ALLDYN][/b]

[b]The FxASTAlgo Normalized T3 Oscillator[/b] is a streamlined trend-pressure oscillator designed to visualize where smoothed price momentum sits within its own recent range.

This is a [b]foundational[/b] FxAST oscillator designed for [b]clean momentum and bias visualization[/b]. It [b]is not intended[/b] to replace full decision frameworks, but to[i] provide a clear, normalized view of trend pressure.[/i]

Instead of relying on traditional overbought/oversold logic, this tool normalizes a [b]T3-smoothed price series[/b] into a centered oscillator, allowing traders to quickly identify [b]bias, strength, and momentum state[/b] across any market or timeframe.
----------------------------------------------------------------------------------------------------------------
[b]⚙️ Core Concept
[/b]This oscillator answers a simple but powerful question:
[list]
[*][b]Where is smoothed price pressure relative to its own recent envelope?[/b]
[/list]
By normalizing T3 output over a rolling range, the indicator provides a consistent view of:
[list]
[*]Directional bias (above/below equilibrium)
[*]Momentum expansion and contraction
[*]Regime shifts and transitions
[/list]
------------------------------------------------------------------------------------------------------------------
[b]📊 Key Features[/b]
[b]T3-Based Smoothing[/b]
[list]
[*]Reduces noise while maintaining responsiveness to short-term momentum shifts.
[/list]
[b]Normalized Output (-0.5 to +0.5)[/b]
[list]
[*]Standardized range allows for consistent interpretation across instruments.
[/list]
[b]Dynamic Momentum Coloring[/b]
[list]
[*]Column-based visualization highlights strength and pressure progression.
[/list]
[b]Signal Line (Multi-MA Options)[/b]
[list]
[*]Optional moving average overlay for additional confirmation or filtering.
[/list]
[b]Compact HUD (Bias / Strength / State / MA Relation)[/b]
[list]
[*]At-a-glance readout of current market condition.
[/list]
[b]Zero-Line Alerts[/b]
[list]
[*]Clean directional triggers for potential regime shifts.
[/list]
----------------------------------------------------------------------------------------------------------
[b]🧠 How to Use[/b]
[b]Above 0[/b] → Bullish pressure dominates
[b]Below 0 [/b]→ Bearish pressure dominates
[b]±0.25[/b] → Strong directional momentum
[b]±0.40–0.50[/b] → Expansion / trend continuation zones
[b]Near 0 [/b]→ Compression / transition / indecision
[b]Oscillator vs MA[/b]
[list]
[*][b]Above MA [/b]→ Momentum leading
[*][b]Below MA[/b] → Momentum weakening
[/list]
-------------------------------------------------------------------------------------------------------------
[b]🎯 Best Use Cases[/b]
[list]
[*]Trend confirmation
[*]Directional bias filtering
[*]Momentum expansion/decay tracking
[*]Regime shift identification
[/list]
--------------------------------------------------------------------------------------------------------------
[b]⚠️ Notes[/b]
This is [b]not a traditional reversal oscillator[/b].
Extreme readings indicate [b]pressure[/b], not guaranteed turning points.

[b]Best used in conjunction with:[/b]
[list]
[*]Structure (HH/LL, liquidity)
[*]Volume / order flow context
[*]Higher timeframe bias
[/list]
-------------------------------------------------------------------------------------------------------------------
[b]◈🛡 FxAST Philosophy[/b]
Built under the [b]FxAST framework[/b], this tool prioritizes:
[list]
[*]Clarity over complexity
[*]Function over decoration
[*]Decision-support over signal noise
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © alldyn_pip_king

//@version=6
indicator(title = '◈🛡FxASTAlgo Normalized T3 Oscillator [ALLDYN]', shorttitle = '◈🛡FxASTAlgo Normalized T3 [ALLDYN]', overlay = false)

import TradingView/ta/7 as ta

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
simple int   len         = input.int(2, 'T3 Calculation Period', group = 'Calculation', inline = '1', minval = 1)
series float source      = input.source(close, 'Calculation Source', group = 'Calculation', inline = '1')
simple float vf          = input.float(0.7, 'T3 Volume Factor', group = 'Calculation', inline = '2', minval = 0.0, maxval = 1.0, step = 0.05)
simple int   normPeriod  = input.int(50, 'Normalization Period', minval = 1, group = 'Calculation', inline = '2')

simple bool   showOsc       = input.bool(true, 'Show Oscillator?', group = 'Signals')
simple bool   showMA        = input.bool(true, 'Show Oscillator Moving Average', group = 'Signals', tooltip = 'If you are going to use the moving average as the signal line, go into the style menu and change the moving average line into columns if desired.')
string        maType        = input.string('SMA', title = 'Moving Average Type', options = ['SMA', 'EMA', 'DEMA', 'TEMA', 'RMA', 'WMA', 'HMA', 'T3', 'ALMA', 'LINREG', 'VWMA'], group = 'Signals')
simple int    maLen         = input.int(18, 'MA Period', minval = 1, group = 'Signals')

simple bool   paintCandles  = input.bool(false, 'Paint Candles according to Trend?', group = 'UI Settings')
simple bool   showStatic    = input.bool(true, 'Show Static Levels?', group = 'UI Settings')

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
subject = ta.t3(source, len, vf)

lowestT3  = ta.lowest(subject, normPeriod)
highestT3 = ta.highest(subject, normPeriod)
rangeT3   = highestT3 - lowestT3

plotOsc = rangeT3 != 0 ? (subject - lowestT3) / rangeT3 - 0.50 : 0.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MOVING AVERAGE FUNCTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_ma(src, length, type) =>
    switch type
        'SMA'    => ta.sma(src, length)
        'EMA'    => ta.ema(src, length)
        'DEMA'   => ta.dema(src, length)
        'TEMA'   => ta.tema(src, length)
        'RMA'    => ta.rma(src, length)
        'WMA'    => ta.wma(src, length)
        'HMA'    => ta.hma(src, length)
        'T3'     => ta.t3(src, length, vf)
        'ALMA'   => ta.alma(src, length, 0.85, 6)
        'LINREG' => ta.linreg(src, length, 0)
        'VWMA'   => ta.vwma(src, length)

sigMA = f_ma(plotOsc, maLen, maType)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OSCILLATOR COLOR LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color plotCol = na

if plotOsc >= 0.49
    plotCol := #33ff00fc
else if plotOsc >= 0.40
    plotCol := #00ff0080
else if plotOsc >= 0.25
    plotCol := #00ff003d
else if plotOsc >= 0.125
    plotCol := #1e9b254d
else if plotOsc >= 0
    plotCol := #1dcaff4d
else if plotOsc <= -0.49
    plotCol := #ff0000
else if plotOsc <= -0.40
    plotCol := #ff000080
else if plotOsc <= -0.25
    plotCol := #ff00004d
else if plotOsc <= -0.125
    plotCol := #7715154d
else
    plotCol := #e651004d

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATIC COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
obCol  = #ff0000fc
osCol  = #00ff00fc
midCol = #ffffff4d

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTTING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showOsc ? plotOsc : na, 'T3 Normalized', plotCol, 2, plot.style_columns)
plot(showMA ? sigMA : na, 'Moving Average', color = color.white)

obUpper = plot(showStatic ? 0.5 : na, '+', obCol)
osUpper = plot(showStatic ? -0.4 : na, '-', osCol)
obLower = plot(showStatic ? 0.4 : na, '+', obCol)
osLower = plot(showStatic ? -0.5 : na, '-', osCol)

fill(obUpper, obLower, #7715154d, 'OB Fill')
fill(osUpper, osLower, #1e9b254d, 'OS Fill')

hline(0, '0 Line', midCol, hline.style_solid)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BAR COLOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color barColour = plotOsc > 0 ? #00ff00 : plotOsc < 0 ? #ff0000 : #ffffff
barcolor(paintCandles ? barColour : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
oscCrossUp = ta.crossover(plotOsc, 0)
oscCrossDn = ta.crossunder(plotOsc, 0)

alertcondition(oscCrossUp, title = 'Normalized T3 Long', message = 'Normalized T3 Long {{exchange}}:{{ticker}}')
alertcondition(oscCrossDn, title = 'Normalized T3 Short', message = 'Normalized T3 Short {{exchange}}:{{ticker}}')

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HUD SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gHud = "HUD"

showHUD     = input.bool(true, "Show HUD", group = gHud, inline = "hud1")
hudPosition = input.string("Bottom Right", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gHud, inline = "hud1")
hudSize     = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = gHud, inline = "hud2")

hudTextSize = hudSize == "Tiny" ? size.tiny : hudSize == "Small" ? size.small : hudSize == "Large" ? size.large : size.normal

hudPos = hudPosition == "Top Left" ? position.top_left :
     hudPosition == "Top Center" ? position.top_center :
     hudPosition == "Top Right" ? position.top_right :
     hudPosition == "Middle Left" ? position.middle_left :
     hudPosition == "Middle Center" ? position.middle_center :
     hudPosition == "Middle Right" ? position.middle_right :
     hudPosition == "Bottom Left" ? position.bottom_left :
     hudPosition == "Bottom Center" ? position.bottom_center :
     position.bottom_right

oscBias =
     plotOsc > 0 ? "Bullish" :
     plotOsc < 0 ? "Bearish" :
     "Neutral"

oscStrength =
     plotOsc >= 0.49 ? "Extreme Bull" :
     plotOsc >= 0.25 ? "Strong Bull" :
     plotOsc > 0 ? "Bullish" :
     plotOsc <= -0.49 ? "Extreme Bear" :
     plotOsc <= -0.25 ? "Strong Bear" :
     plotOsc < 0 ? "Bearish" :
     "Neutral"

oscState =
     plotOsc >= 0.40 ? "Upper Expansion" :
     plotOsc <= -0.40 ? "Lower Expansion" :
     math.abs(plotOsc) <= 0.10 ? "Compression" :
     "Rotation"

maState =
     plotOsc > sigMA ? "Above MA" :
     plotOsc < sigMA ? "Below MA" :
     "At MA"

biasBg =
     plotOsc > 0 ? color.new(color.lime, 75) :
     plotOsc < 0 ? color.new(color.red, 75) :
     color.new(color.gray, 80)

strengthBg =
     plotOsc >= 0.25 ? color.new(color.lime, 65) :
     plotOsc <= -0.25 ? color.new(color.red, 65) :
     color.new(color.gray, 82)

stateBg =
     math.abs(plotOsc) <= 0.10 ? color.new(color.orange, 65) :
     plotOsc >= 0.40 ? color.new(color.lime, 70) :
     plotOsc <= -0.40 ? color.new(color.red, 70) :
     color.new(color.blue, 80)

maBg =
     plotOsc > sigMA ? color.new(color.lime, 78) :
     plotOsc < sigMA ? color.new(color.red, 78) :
     color.new(color.gray, 82)

var table hud = table.new(hudPos, 2, 4, border_width = 1)

if barstate.isfirst
    table.cell(hud, 0, 0, "Bias", text_color = color.white, text_size = hudTextSize, bgcolor = color.new(color.black, 0))
    table.cell(hud, 0, 1, "Strength", text_color = color.white, text_size = hudTextSize, bgcolor = color.new(color.black, 0))
    table.cell(hud, 0, 2, "State", text_color = color.white, text_size = hudTextSize, bgcolor = color.new(color.black, 0))
    table.cell(hud, 0, 3, "MA Rel.", text_color = color.white, text_size = hudTextSize, bgcolor = color.new(color.black, 0))

if barstate.islast
    table.cell(hud, 1, 0, oscBias, text_color = color.white, text_size = hudTextSize, bgcolor = biasBg)
    table.cell(hud, 1, 1, oscStrength, text_color = color.white, text_size = hudTextSize, bgcolor = strengthBg)
    table.cell(hud, 1, 2, oscState, text_color = color.white, text_size = hudTextSize, bgcolor = stateBg)
    table.cell(hud, 1, 3, maState, text_color = color.white, text_size = hudTextSize, bgcolor = maBg)

if not showHUD
    table.clear(hud, 0, 0, 1, 3)
````
