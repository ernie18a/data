# Adaptive Volatility Envelope [QuantAlgo]

- url: https://www.tradingview.com/script/j911frQL-Adaptive-Volatility-Envelope-QuantAlgo/
- type: indicator
- pine_id: PUB;716c265cb9c846debef552b63c1d0517
- version: 1.0

## Description

[b]🟢 Overview[/b]

The [b]Adaptive Volatility Envelope[/b] wraps price in a dynamic field of volatility bands centred on a self-adjusting baseline. Rather than tracking price at a fixed speed, the centerline measures how efficiently price is moving and accelerates when movement is more directional while slowing down in choppy conditions, so the baseline follows sustained moves more closely and reacts less to sideways noise. Around this adaptive centerline, layered ATR-scaled bands form a heat map that brightens toward the side price is moving into, giving traders a visual read on both trend state and momentum strength across any instrument or timeframe.
[image]https://www.tradingview.com/x/vVlveekj/[/image]
[b]🟢 How It Works[/b]

The indicator's core methodology combines two mechanisms: an efficiency-driven centerline that adapts its tracking speed to market conditions, and a volatility-scaled band field that visualises momentum through colour and brightness.

First, market efficiency is measured by comparing net directional movement against total movement over the adaptation window. This ratio approaches one when movement is more directional and falls toward zero in choppy conditions, and it is used to blend between a slow choppy speed and a fast trending speed. The result is a smoothing factor that automatically tightens the centerline's tracking in directional moves and loosens it in noise, without manual recalibration:
[pine]efficiencyRatio = totalMovement != 0 ? priceChange / totalMovement : 0.0
smoothingFactor = choppySpeed + (trendSpeed - choppySpeed) * efficiencyRatio[/pine]
Next, the centerline advances toward price by the smoothing factor on each bar, producing an adaptive baseline that closes the gap quickly when efficiency is high and slowly when it is low:
[pine]centerline := na(centerline[1]) ? src : centerline[1] + smoothingFactor * (src - centerline[1])[/pine]
Band width is then derived from Average True Range scaled by the band spacing, with a safety cap that measures total envelope height against the recent fifty bar price range. If the raw width would exceed this cap, every band is scaled down proportionally, preventing the field from blowing out and distorting the chart scale during volatility spikes:
[pine]widthScale = rawWidth > maxWidth and rawWidth != 0 and maxWidth > 0 ? maxWidth / rawWidth : 1.0
bandUnit   = atr * bandSpacing * widthScale[/pine]
Momentum is resolved from the centerline's slope normalised by ATR and scaled by the colour sensitivity, then clamped to a range of minus one to one. This drives a gradient that runs from the neutral colour at flat momentum toward the bullish or bearish colour as the move strengthens, while a directional brightness offset lights up the leading side of the envelope more than the trailing side:
[pine]momentumRaw = not na(atr) and atr != 0 ? slope / atr * colorSens : 0.0
momentum    = math.max(-1.0, math.min(1.0, momentumRaw))[/pine]
Finally, a confirmed-bars toggle governs what the script computes. In Live mode the centerline, momentum, bands and signals update intrabar on the developing bar for the fastest response, with the current bar able to change until it closes. In Confirmed mode everything is locked to closed bars only, so signals do not repaint and print on the bar that closes the move.
[image]https://www.tradingview.com/x/iWrs9nCQ/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Bullish Momentum (Centerline and Bands Brightening Toward the Bullish Colour):[/b] When the centerline slopes upward relative to volatility, momentum turns positive and the envelope gradient shifts toward the bullish colour. The leading upper side of the field brightens through the directional brightness offset, making the direction of the move easier to read. The bullish state persists as long as the centerline continues rising, and a "Momentum Turned Bullish" alert fires on the bar where momentum crosses above zero.

[b]▶ Bearish Momentum (Centerline and Bands Brightening Toward the Bearish Colour):[/b] When the centerline slopes downward relative to volatility, momentum turns negative and the gradient shifts toward the bearish colour, with the leading lower side of the field brightening to flag the downturn. As with the bullish state, the colour saturates as the move strengthens and fades toward neutral as momentum flattens. A "Momentum Turned Bearish" alert fires on the bar where momentum crosses below zero, flagging a potential short or exit condition.

[b]▶ Neutral Momentum (Centerline and Bands at the Neutral Colour):[/b] When the centerline is flat or moving slowly relative to volatility, momentum sits near zero and the gradient settles at the neutral colour at the middle of its range. This indicates low conviction or sideways drift rather than a directional move, and the envelope brightens away from neutral only as the slope steepens enough to register on either side. Reading the neutral state helps separate genuine momentum from chop, since the field stays muted until price generates a meaningful directional slope.
[image]https://www.tradingview.com/x/vsxtYfvq/[/image]
[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Three parameter sets cover a range of trading styles and timeframes. "Default" delivers a balanced engine for swing trading on 4-hour and daily charts. "Fast Response" shortens the adaptation window and quickens both market speeds for tighter, more reactive bands on 5-minute to 1-hour charts, suiting intraday and scalping use. "Smooth Trend" lengthens the adaptation window and slows the speeds for wider, steadier bands on daily and weekly charts, suiting position trading. The presets deliberately leave Volatility Length untouched, so band width stays under independent manual control.
[image]https://www.tradingview.com/x/WEIopiEp/[/image]
[b]▶ Built-in Alerts:[/b] Three alert conditions support automated monitoring of momentum transitions. "Momentum Turned Bullish" fires on the bar momentum crosses above zero. "Momentum Turned Bearish" fires on the bar momentum crosses below zero. "Any Momentum Change" triggers on either transition for traders who want a single unified alert regardless of direction. All alerts include the exchange, ticker, and timeframe in the message for immediate context, and the confirmed-bars toggle determines whether they evaluate on live or closed-bar data.
[image]https://www.tradingview.com/x/53tOZjq2/[/image]
[b]▶ Visual Customisation:[/b] Six colour presets, Classic, Aqua, Cosmic, Cyber, Neon, and Custom, provide coordinated bullish and bearish colour pairings suited to different chart themes and personal preferences. Selecting Custom exposes independent colour pickers for full manual control over both states, alongside an adjustable neutral colour for the midpoint of the gradient. The number of band layers is configurable from one for a clean minimal look up to eight for a rich gradient field, and the bands can be hidden entirely to display only the centerline. Optional bar colouring tints price candles with the active trend colour at a configurable transparency level, reflecting the current momentum state without reading the centerline directly.
[image]https://www.tradingview.com/x/LHVJutwI/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Adaptive Volatility Envelope [QuantAlgo]', overlay = true)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string calculation_settings = '════════ Calculation Parameters ════════'
var string visual_settings      = '════════ Visualization Settings ════════'

tooltip_preset     = 'Select a predefined configuration optimised for different trading styles and timeframes.'
tooltip_preset_det = 'Default (Adaptation 20, Speeds 0.05 / 0.85, Spacing 0.6): Balanced engine for swing trading on 4H and daily charts.\n\nFast Response (Adaptation 12, Speeds 0.10 / 0.92, Spacing 0.5): Quicker adaptation and tighter bands for intraday and scalping on 5min to 1H charts.\n\nSmooth Trend (Adaptation 30, Speeds 0.03 / 0.75, Spacing 0.8): Slower adaptation and wider bands for position trading on daily and weekly charts.\n\nNote: presets do not change Volatility Length, so band width stays under your control.'
tooltip_confirmed  = 'Off (Live): the centerline, momentum, bands and signals update intrabar on the developing bar for the fastest response. The current bar can change until it closes. \n\nOn (Confirmed): everything is locked to closed bars only, so signals never repaint and print on the bar that closes the move, with no one-bar delay. \n\nLive mode suits discretionary intraday trading; Confirmed mode suits alerts and systematic execution.\n\nNote: this toggle controls what the script computes. How often an alert actually fires is set separately in the alert dialog (Once Per Bar vs Once Per Bar Close).'
tooltip_src        = 'Price data used to build the centerline and the bands. Close is standard and works well in most conditions. Using hl2 or hlc3 includes more of the bar range and produces a slightly smoother response. ohlc4 also includes the open and can reduce distortions caused by single wicks. This input affects the centerline and every band equally.'
tooltip_adapt      = 'How many bars the indicator looks back to decide whether the market is trending or choppy. It then speeds the centerline up automatically in clean trends and slows it down in choppy conditions. Shorter values (10 to 15) react faster and suit intraday charts. Longer values (28 to 40) give a steadier baseline for swing and position trading. Standard value is 20.'
tooltip_choppy     = 'How quickly the centerline is allowed to move when the market is choppy or sideways. Lower values keep it slow and stable so it ignores noise and avoids whipsaws. Higher values let it react sooner but expose it to chop. Standard value is 0.05.'
tooltip_trend      = 'How tightly the centerline tracks price once a clean trend is detected. Higher values hug price closely in strong trends. Lower values keep more lag, which can help confirm a move before reacting. Standard value is 0.85.'
tooltip_vol        = 'Lookback for Average True Range, which sets how wide the envelope is. Shorter values make the bands react quickly to bursts of volatility. Longer values produce steadier, slower changing band width. This input is not changed by the presets, so you can tune band width independently. Standard value is 20.'
tooltip_spacing    = 'Distance between each band, measured as a multiple of ATR. Larger values spread the bands further apart and widen the field. Smaller values pack them tightly around the centerline. Standard value is 0.6.'
tooltip_bands      = 'How many band layers are drawn on each side of the centerline. More layers (5 to 8) produce a richer heat map gradient. Fewer layers (1 to 3) give a cleaner, lighter look. Standard value is 3.'
tooltip_maxwidth   = 'A safety cap on total envelope height, measured against the recent 50 bar price range. This stops the bands from blowing out and wrecking the chart scale during volatility spikes. Lower values clamp the field tighter. Standard value is 40%.'

tooltip_show_bands   = 'Show or hide the volatility bands. Disable to display only the centerline for a clean, minimal view. The centerline colour and all alerts continue to work either way.'
tooltip_color_preset = 'Pre-configured colour schemes optimised for different chart themes and visual preferences. Classic uses traditional green and red. Aqua provides ocean inspired blue and orange. Cosmic offers cyan and purple. Cyber features warm orange against cool cyan. Neon delivers high contrast yellow and magenta. Custom lets you set the bull and bear colours yourself.'
tooltip_bullish    = 'Colour that the centerline and bands brighten toward as upward momentum strengthens. Use a vibrant colour to highlight uptrend conditions and potential long opportunities.'
tooltip_bearish    = 'Colour that the centerline and bands brighten toward as downward momentum strengthens. Use a warning colour to flag downtrend conditions and potential short or exit signals.'
tooltip_neutral    = 'Colour shown when momentum is flat or near zero, which is the middle of the gradient. Gray is recommended as a neutral cue that clearly separates low momentum drift from a strong directional move.'
tooltip_sens       = 'How strongly the colour reacts to the slope of the centerline. Higher values reach the full bull or bear colour on smaller moves, making subtle momentum visible. Lower values need a stronger move before the colour fully saturates. Standard value is 8.'
tooltip_bright     = 'How much brighter the leading side of the envelope is versus the trailing side. Higher values make the direction of momentum visually obvious by lighting up the side price is moving toward. Set to 0 for a symmetric field. Standard value is 28.'
tooltip_barcolor   = 'Enable or disable colouring of the price bars using the current trend colour. This gives instant confirmation of momentum state without reading the centerline directly. Disable if you prefer default bars or already use another bar colouring tool.'
tooltip_bartrans   = 'Transparency of the bar colouring. Lower values (0 to 30) produce vivid, fully saturated bars. Higher values (70 to 90) apply a subtle tint that signals state without hiding price action. Standard value is 0.'

preset         = input.string('Default', 'Preset Configuration', options = ['Default', 'Fast Response', 'Smooth Trend'], group = calculation_settings, tooltip = tooltip_preset + '\n\n' + tooltip_preset_det)
confirmed_only = input.bool(true, 'Use Confirmed Bars Only', group = calculation_settings, tooltip = tooltip_confirmed)
src          = input.source(close, 'Price Source',          group = calculation_settings, tooltip = tooltip_src)
adaptLength  = input.int(20,   'Adaptation Length', minval = 2,   group = calculation_settings, tooltip = tooltip_adapt)
choppySpeed  = input.float(0.05, 'Choppy Market Speed',  minval = 0.01, maxval = 0.5,  step = 0.01, group = calculation_settings, tooltip = tooltip_choppy)
trendSpeed   = input.float(0.85, 'Trending Market Speed', minval = 0.5,  maxval = 0.99, step = 0.01, group = calculation_settings, tooltip = tooltip_trend)
volLength    = input.int(20,   'Volatility Length', minval = 1,   group = calculation_settings, tooltip = tooltip_vol)
bandSpacing  = input.float(0.6, 'Band Spacing',     minval = 0.1, step = 0.1, group = calculation_settings, tooltip = tooltip_spacing)
numBands     = input.int(3,    'Number of Bands',  minval = 1, maxval = 8, group = calculation_settings, tooltip = tooltip_bands)
maxWidthPct  = input.float(40, 'Maximum Width (%)', minval = 5, maxval = 100, step = 5, group = calculation_settings, tooltip = tooltip_maxwidth)

show_bands    = input.bool(true,  'Show Bands',      group = visual_settings, tooltip = tooltip_show_bands)
color_preset  = input.string('Custom', 'Color Preset', options = ['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group = visual_settings, tooltip = tooltip_color_preset)
bullish_input = input.color(#00ffaa, 'Bullish Color',  group = visual_settings, tooltip = tooltip_bullish)
bearish_input = input.color(#ff0000, 'Bearish Color',  group = visual_settings, tooltip = tooltip_bearish)
neutral_color = input.color(#787b86, 'Neutral Color',  group = visual_settings, tooltip = tooltip_neutral)
colorSens     = input.float(8.0, 'Color Sensitivity',   minval = 1.0, step = 0.5, group = visual_settings, tooltip = tooltip_sens)
asymStrength  = input.float(28, 'Directional Brightness', minval = 0, maxval = 50, step = 2, group = visual_settings, tooltip = tooltip_bright)
enable_bar    = input.bool(false, 'Enable Bar Coloring', group = visual_settings, tooltip = tooltip_barcolor)
bar_trans     = input.int(0, 'Bar Color Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bartrans)

if preset == 'Fast Response'
    adaptLength := 12
    choppySpeed := 0.10
    trendSpeed  := 0.92
    bandSpacing := 0.5
else if preset == 'Smooth Trend'
    adaptLength := 30
    choppySpeed := 0.03
    trendSpeed  := 0.75
    bandSpacing := 0.8

[bullish_color, bearish_color] = switch color_preset
    'Classic' => [#00ff00, #ff0000]
    'Aqua'    => [#00d4ff, #ff8c00]
    'Cosmic'  => [#49ffce, #9932cc]
    'Cyber'   => [#00cccc, #ff6600]
    'Neon'    => [#ffff00, #ff00ff]
    'Custom'  => [bullish_input, bearish_input]

//              ╔════════════════════════════════╗              //
//              ║        CORE CALCULATION        ║              //
//              ╚════════════════════════════════╝              //

priceChange     = math.abs(src - src[adaptLength])
totalMovement   = math.sum(math.abs(src - src[1]), adaptLength)
efficiencyRatio = totalMovement != 0 ? priceChange / totalMovement : 0.0
smoothingFactor = choppySpeed + (trendSpeed - choppySpeed) * efficiencyRatio

var float centerline = na
centerline := na(centerline[1]) ? src : centerline[1] + smoothingFactor * (src - centerline[1])

atr         = ta.atr(volLength)
recentRange = ta.highest(high, 50) - ta.lowest(low, 50)
rawWidth    = atr * bandSpacing * numBands
maxWidth    = recentRange * (maxWidthPct / 100.0)
widthScale  = rawWidth > maxWidth and rawWidth != 0 and maxWidth > 0 ? maxWidth / rawWidth : 1.0
bandUnit    = atr * bandSpacing * widthScale

slope       = (centerline - nz(centerline[2], centerline)) / 2.0
momentumRaw = not na(atr) and atr != 0 ? slope / atr * colorSens : 0.0
momentum    = math.max(-1.0, math.min(1.0, momentumRaw))

calcOK = confirmed_only ? barstate.isconfirmed : true

var float dispCenter   = na
var float dispBandUnit = na
var float dispMomentum = na
if calcOK
    dispCenter   := centerline
    dispBandUnit := bandUnit
    dispMomentum := momentum

dispBandOffset(level) => dispBandUnit * (level + 0.5 * math.log(level + 1))

trendColor = dispMomentum >= 0 ? color.from_gradient(dispMomentum, 0, 1, neutral_color, bullish_color) : color.from_gradient(-dispMomentum, 0, 1, neutral_color, bearish_color)

//              ╔════════════════════════════════╗              //
//              ║          VISUALIZATION         ║              //
//              ╚════════════════════════════════╝              //

center = plot(dispCenter, 'Centerline', color.new(trendColor, 0), 4)

u1=plot(show_bands ? dispCenter+dispBandOffset(1) : na, display=display.none), l1=plot(show_bands ? dispCenter-dispBandOffset(1) : na, display=display.none)
u2=plot(show_bands and numBands>=2 ? dispCenter+dispBandOffset(2) : na, display=display.none), l2=plot(show_bands and numBands>=2 ? dispCenter-dispBandOffset(2) : na, display=display.none)
u3=plot(show_bands and numBands>=3 ? dispCenter+dispBandOffset(3) : na, display=display.none), l3=plot(show_bands and numBands>=3 ? dispCenter-dispBandOffset(3) : na, display=display.none)
u4=plot(show_bands and numBands>=4 ? dispCenter+dispBandOffset(4) : na, display=display.none), l4=plot(show_bands and numBands>=4 ? dispCenter-dispBandOffset(4) : na, display=display.none)
u5=plot(show_bands and numBands>=5 ? dispCenter+dispBandOffset(5) : na, display=display.none), l5=plot(show_bands and numBands>=5 ? dispCenter-dispBandOffset(5) : na, display=display.none)
u6=plot(show_bands and numBands>=6 ? dispCenter+dispBandOffset(6) : na, display=display.none), l6=plot(show_bands and numBands>=6 ? dispCenter-dispBandOffset(6) : na, display=display.none)
u7=plot(show_bands and numBands>=7 ? dispCenter+dispBandOffset(7) : na, display=display.none), l7=plot(show_bands and numBands>=7 ? dispCenter-dispBandOffset(7) : na, display=display.none)
u8=plot(show_bands and numBands>=8 ? dispCenter+dispBandOffset(8) : na, display=display.none), l8=plot(show_bands and numBands>=8 ? dispCenter-dispBandOffset(8) : na, display=display.none)

asymShift = dispMomentum * asymStrength
tU(level) => math.round(math.max(0, math.min(99, 72 + (level-1)*(26.0/numBands) - asymShift)))
tL(level) => math.round(math.max(0, math.min(99, 72 + (level-1)*(26.0/numBands) + asymShift)))

fill(center,u1, color.new(trendColor,tU(1))), fill(center,l1, color.new(trendColor,tL(1)))
fill(u1,u2, color.new(trendColor,tU(2))), fill(l1,l2, color.new(trendColor,tL(2)))
fill(u2,u3, color.new(trendColor,tU(3))), fill(l2,l3, color.new(trendColor,tL(3)))
fill(u3,u4, color.new(trendColor,tU(4))), fill(l3,l4, color.new(trendColor,tL(4)))
fill(u4,u5, color.new(trendColor,tU(5))), fill(l4,l5, color.new(trendColor,tL(5)))
fill(u5,u6, color.new(trendColor,tU(6))), fill(l5,l6, color.new(trendColor,tL(6)))
fill(u6,u7, color.new(trendColor,tU(7))), fill(l6,l7, color.new(trendColor,tL(7)))
fill(u7,u8, color.new(trendColor,tU(8))), fill(l7,l8, color.new(trendColor,tL(8)))

barcolor(enable_bar ? color.new(trendColor, bar_trans) : na, title = 'Trend Bar Color')

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

bullTurn = ta.crossover(dispMomentum, 0)  and calcOK
bearTurn = ta.crossunder(dispMomentum, 0) and calcOK
anyTurn  = bullTurn or bearTurn

alertcondition(bullTurn, title = 'Momentum Turned Bullish', message = 'Adaptive Volatility Envelope: momentum turned BULLISH on {{exchange}}:{{ticker}} {{interval}}')
alertcondition(bearTurn, title = 'Momentum Turned Bearish', message = 'Adaptive Volatility Envelope: momentum turned BEARISH on {{exchange}}:{{ticker}} {{interval}}')
alertcondition(anyTurn,  title = 'Any Momentum Change',  message = 'Adaptive Volatility Envelope: momentum direction CHANGED on {{exchange}}:{{ticker}} {{interval}}')

//              ╔════════════════════════════════╗              //
//              ║           CREATED BY           ║              //
//              ╚════════════════════════════════╝              //

// ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗     █████╗ ██╗      ██████╗  ██████╗ 
//██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝    ██╔══██╗██║     ██╔════╝ ██╔═══██╗
//██║   ██║██║   ██║███████║██╔██╗ ██║   ██║       ███████║██║     ██║  ███╗██║   ██║
//██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║       ██╔══██║██║     ██║   ██║██║   ██║
//╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║       ██║  ██║███████╗╚██████╔╝╚██████╔╝
// ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
````
