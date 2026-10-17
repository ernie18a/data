# Adaptive Fourier Transform CCI [QuantAlgo]

- url: https://www.tradingview.com/script/KWRHKdqw-Adaptive-Fourier-Transform-CCI-QuantAlgo/
- type: indicator
- pine_id: PUB;a6099b6147c44328a940c20e001f2626
- version: 1.0

## Description

[b]🟢 Overview[/b]

The [b]Adaptive Fourier Transform CCI[/b] reimagines the classic Commodity Channel Index by replacing its fixed lookback period with one that continuously adjusts to the market's own rhythm. Rather than measuring price deviation against an arbitrary static length, it first isolates the cyclical component of price action through a Discrete Fourier Transform, identifies which cycle period currently holds the most spectral energy, and then tunes the CCI calculation to that dominant period. The result is a momentum oscillator calibrated to the frequency structure of the instrument being traded, naturally tightening during fast, high-frequency regimes and widening during slower, drawn-out cycles without requiring manual timeframe adjustments.
[image]https://www.tradingview.com/x/Vijw7DZP/[/image]
[b]🟢 How It Works[/b]

Before any cycle detection occurs, raw price is conditioned through two sequential filters. A high-pass filter strips the slow-moving trend component from the close, leaving only the oscillating portion of price action:
[pine]hp := 0.5 * (1 + a1) * (close - close[1]) + a1 * hp[1][/pine]
That residual is then passed through a Super Smoother filter, which removes short-term noise from the cycle signal without introducing the lag that standard moving averages add at this stage:
[pine]filt := c1 * (hp + hp[1]) / 2 + c2 * filt[1] + c3 * filt[2][/pine]
This cleaned signal is what the Discrete Fourier Transform (DFT) operates on. The DFT scans across a range of candidate cycle periods and measures how much price energy is concentrated at each one. The period where that energy is strongest is selected as the dominant cycle. An EMA smooths the period output to prevent erratic length switching between bars, and the result is scaled by the Length Multiplier to derive the final adaptive CCI lookback:
[pine]adaptiveLen = clamp(round(dominantPeriod × lengthMult), 5, 60)[/pine]
The CCI is then calculated using the standard Lambert formula over that adaptive length, measuring how far typical price has deviated from its mean relative to its average absolute deviation. An optional output smoothing MA reduces bar-to-bar noise before the final value is plotted.
[image]https://www.tradingview.com/x/93LdBZRO/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Overbought (Above Upper Level, Red):[/b] When the Adaptive Fourier Transform CCI (AFT-CCI) rises above the upper threshold, price has deviated significantly above its cycle-adaptive mean. The reading reflects momentum extended relative to the market's current detected rhythm rather than a fixed arbitrary baseline. The signal carries more weight when the dominant cycle is stable and the DFT is locked onto a consistent frequency rather than switching between periods.

[b]▶ Oversold (Below Lower Level, Green):[/b] When the AFT-CCI falls below the lower threshold, price has moved an equivalent distance below its cycle-adaptive mean. In strongly trending conditions the AFT-CCI can remain in either zone for extended periods, so the threshold levels should be read as zones of extension rather than automatic reversal points.

[b]▶ Neutral Zone (Between Levels, Grey):[/b] When the AFT-CCI sits between the upper and lower thresholds, price deviation relative to the detected cycle is within normal range. Zero-line crosses within this zone indicate the adaptive mean is being reclaimed, which can serve as early directional context before a full threshold break develops.

[b]▶ Zero Line:[/b] The zero line represents the adaptive mean itself. A cross above zero indicates typical price has moved above the cycle-adaptive mean; a cross below indicates the opposite. These crosses are lower-conviction reads on their own but become more meaningful when followed by a threshold break in the same direction.
[image]https://www.tradingview.com/x/JspxuB6Q/[/image]
[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Two parameter sets sit alongside the default configuration. "Fast Response" compresses the DFT window and cycle search range while raising the length multiplier, producing faster adaptation suited to intraday charts from 5-minute to 1-hour. "Smooth Trend" expands the window and search range while lowering the multiplier, establishing a more stable cycle read suited to daily and weekly position trading.
[image]https://www.tradingview.com/x/fKr2U2NR/[/image]
[b]▶ Built-in Alerts:[/b] Six alert conditions cover the full range of meaningful oscillator events. Separate alerts fire on entering and exiting both overbought and oversold territory, capturing threshold breaks in both directions. Two additional alerts trigger on bullish and bearish zero-line crosses, enabling directional monitoring without requiring constant chart observation.
[image]https://www.tradingview.com/x/G7wI9Ped/[/image]
[b]▶ Visual Customisation:[/b] Six colour presets, Classic, Aqua, Cosmic, Cyber, Neon, and Custom, apply consistently across the signal line, glow layers, and threshold level lines so the overbought and oversold colours remain coherent regardless of which preset is active. The optional neon glow effect uses three layered plots at increasing transparency to give the signal line visual depth and make threshold breaks immediately readable at a glance.
[image]https://www.tradingview.com/x/x9xoXs5G/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Adaptive Fourier Transform CCI [QuantAlgo]', overlay = false, precision = 2)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string grp_preset  = '════════ Preset Configuration ════════'
var string grp_fourier = '════════ Fourier Cycle Detection ════════'
var string grp_cci     = '════════ CCI Parameters ════════'
var string grp_levels  = '════════ Threshold Levels ════════'
var string grp_visual  = '════════ Visualization Settings ════════'

tt_preset       = 'Select a predefined configuration optimised for different trading styles and timeframes.\n\nDefault (Window 60, Range 10–40, Mult 0.50): Balanced configuration suited to swing trading on 4H and daily charts. Captures meaningful cycle shifts while filtering short-term noise.\n\nFast Response (Window 30, Range 4–20, Mult 0.75): Fast-reacting setup for intraday use on 5min–1H charts. Shorter window and higher multiplier produce rapid cycle adaptation with a tighter CCI length.\n\nSmooth Trend (Window 120, Range 20–60, Mult 0.35): High-stability setup for position traders on daily and weekly charts. Maximum window and lowest multiplier produce slow, high-conviction trend signals.'
tt_window       = 'Number of bars used by the Discrete Fourier Transform when scanning for the dominant market cycle. Larger windows (80–120) capture longer-term cyclical structure with greater stability but slower adaptation to shifting regimes. Smaller windows (20–40) react more quickly to cycle changes but are more sensitive to noise. Default is 60 for a balanced scan horizon across most timeframes.'
tt_min_period   = 'Shortest cycle period (in bars) the DFT will consider as a dominant cycle candidate. Setting this too low includes very short, noisy micro-cycles in the search space. Recommended range is 4–14. Default is 10.'
tt_max_period   = 'Longest cycle period (in bars) the DFT will consider as a dominant cycle candidate. Setting this too high can cause the indicator to lock onto slow macro cycles, producing lagging CCI signals. Recommended range is 20–60. Default is 40. Must be greater than Min Cycle Period.'
tt_cycle_smooth = 'EMA smoothing period applied to the raw dominant cycle period output from the DFT before it is used to derive the adaptive CCI length. Higher values (15–30) stabilise the detected cycle and prevent rapid length switching at the cost of slower adaptation. Lower values (2–6) allow the CCI length to react faster to regime changes. Default is 8.'
tt_mult         = 'Scales the detected dominant cycle period to derive the adaptive CCI lookback length. A value of 0.50 sets the CCI length to half the dominant period. Increase toward 1.0 to use the full detected cycle as the lookback; decrease toward 0.25 for a shorter, more reactive CCI. The resulting length is always clamped between 5 and 60 bars. Default is 0.50.'
tt_constant     = 'Lambert constant used in the CCI denominator. The traditional value is 0.015, which scales the CCI such that approximately 70–80% of readings fall within the ±100 band under normal market conditions. Increasing this value compresses the CCI range; decreasing it expands it. Only adjust if you have a specific reason to rescale the output distribution.'
tt_smooth_type  = 'Moving average type applied to the raw AFT-CCI output before plotting. None outputs the raw signal with no post-processing. SMA applies equal-weight smoothing. EMA applies recency-biased smoothing and is the default. WMA applies linearly decreasing weight smoothing. RMA (Wilder smoothing) applies heavier dampening similar to the internal smoothing used in RSI.'
tt_smooth_len   = 'Lookback period for the output smoothing MA. Shorter lengths (2–4) add minimal lag while removing tick-to-tick noise. Longer lengths (6–10) produce a significantly smoother line at the cost of increased signal lag. Only active when smoothing type is not set to None. Default is 3.'
tt_color_preset = 'Pre-configured colour schemes optimised for different chart themes and visual preferences. Classic uses traditional red and green. Aqua provides ocean-inspired orange and blue. Cosmic offers futuristic purple and cyan. Cyber features warm orange and cool cyan contrast. Neon delivers high-contrast magenta and yellow for maximum visibility. Custom allows full colour control via the Overbought and Oversold colour inputs below.'
tt_ob_color     = 'Colour applied to the AFT-CCI line when the indicator is in overbought territory, i.e. above the upper threshold. Use warning or momentum colours to signal elevated, potentially overextended readings.'
tt_os_color     = 'Colour applied to the AFT-CCI line when the indicator is in oversold territory, i.e. below the lower threshold. Use relief or mean-reversion colours to signal depressed, potentially undervalued readings.'
tt_glow         = 'Enable or disable the neon glow effect around the AFT-CCI line. When enabled, three layered plots at increasing transparency produce a glowing appearance that makes the signal line more visually prominent. Disable for a clean, single-line appearance or when running multiple indicators where visual clarity is a priority.'
tt_upper        = 'Overbought threshold level. The AFT-CCI is considered overbought when above this value. Default is 100, consistent with traditional CCI interpretation. Increase to 150–200 for more selective overbought signals in strongly trending markets.'
tt_lower        = 'Oversold threshold level. The AFT-CCI is considered oversold when below this value. Default is -100. Decrease to -150 or -200 for more selective oversold signals in strongly trending markets.'

presetInput = input.string('Default', 'Preset Configuration',
     options = ['Default', 'Fast Response', 'Smooth Trend'],
     group   = grp_preset, tooltip = tt_preset)

dftWindow   = input.int(60,  'DFT Window',       group = grp_fourier, tooltip = tt_window)
minPeriod   = input.int(10,  'Min Cycle Period', group = grp_fourier, tooltip = tt_min_period)
maxPeriod   = input.int(40,  'Max Cycle Period', group = grp_fourier, tooltip = tt_max_period)
cycleSmooth = input.int(8,   'Cycle Smoothing',  group = grp_fourier, tooltip = tt_cycle_smooth)

lengthMult   = input.float(0.5,   'Length Multiplier', step = 0.05,  group = grp_cci, tooltip = tt_mult)
cciConstant  = input.float(0.015, 'CCI Constant',      step = 0.001, group = grp_cci, tooltip = tt_constant)
smoothType   = input.string('EMA', 'Output Smoothing Type',   options = ['None', 'SMA', 'EMA', 'WMA', 'RMA'], group = grp_cci, tooltip = tt_smooth_type)
smoothLength = input.int(3, 'Output Smoothing Length', group = grp_cci, tooltip = tt_smooth_len)

upperLevel = input.float( 100, 'Overbought Level', group = grp_levels, tooltip = tt_upper)
lowerLevel = input.float(-100, 'Oversold Level',   group = grp_levels, tooltip = tt_lower)

colorPreset  = input.string('Custom', 'Color Preset', options = ['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group = grp_visual, tooltip = tt_color_preset)
obColorInput = input.color(#ff0000,  'Overbought Color',       group = grp_visual, tooltip = tt_ob_color)
osColorInput = input.color(#00ffaa,  'Oversold Color',         group = grp_visual, tooltip = tt_os_color)
enableGlow   = input.bool(true,      'Enable Neon Glow Effect', group = grp_visual, tooltip = tt_glow)

if presetInput == 'Fast Response'
    dftWindow   := 30
    minPeriod   := 4
    maxPeriod   := 20
    cycleSmooth := 3
    lengthMult  := 0.75
else if presetInput == 'Smooth Trend'
    dftWindow   := 120
    minPeriod   := 20
    maxPeriod   := 60
    cycleSmooth := 20
    lengthMult  := 0.35

[obColor, osColor] = switch colorPreset
    'Classic' => [#ff0000, #00ff00]
    'Aqua'    => [#ff8c00, #00d4ff]
    'Cosmic'  => [#9932cc, #49ffce]
    'Cyber'   => [#ff6600, #00cccc]
    'Neon'    => [#ff00ff, #ffff00]
    'Custom'  => [obColorInput, osColorInput]

//              ╔════════════════════════════════╗              //
//              ║        PRE-CONDITIONING        ║              //
//              ╚════════════════════════════════╝              //

alpha_hp = 2.0 * math.pi / 48.0
a1       = (1.0 - math.sin(alpha_hp)) / math.cos(alpha_hp)
var float hp = 0.0
hp := 0.5 * (1.0 + a1) * (close - nz(close[1])) + a1 * nz(hp[1])

ss_a  = math.exp(-math.sqrt(2) * math.pi / 10)
ss_b  = 2 * ss_a * math.cos(math.sqrt(2) * math.pi / 10)
ss_c2 = ss_b
ss_c3 = -ss_a * ss_a
ss_c1 = 1 - ss_c2 - ss_c3
var float filt = 0.0
filt := ss_c1 * (hp + nz(hp[1])) / 2 + ss_c2 * nz(filt[1]) + ss_c3 * nz(filt[2])

//              ╔════════════════════════════════╗              //
//              ║   DISCRETE FOURIER TRANSFORM   ║              //
//              ╚════════════════════════════════╝              //

var float dominantPeriod = 20.0
maxPower   = 0.0
bestPeriod = minPeriod

for period = minPeriod to maxPeriod by 1
    re = 0.0
    im = 0.0
    for n = 0 to dftWindow - 1 by 1
        angle = 2.0 * math.pi * n / period
        re   := re + nz(filt[n]) * math.cos(angle)
        im   := im + nz(filt[n]) * math.sin(angle)
    power = re * re + im * im
    if power > maxPower
        maxPower   := power
        bestPeriod := period

dominantPeriod := ta.ema(float(bestPeriod), cycleSmooth)

//              ╔════════════════════════════════╗              //
//              ║          ADAPTIVE CCI          ║              //
//              ╚════════════════════════════════╝              //

adaptiveLen = math.max(5, math.min(60, int(math.round(dominantPeriod * lengthMult))))
tp          = (high + low + close) / 3

sumTP = 0.0
for i = 0 to adaptiveLen - 1 by 1
    sumTP := sumTP + nz(tp[i])
meanTP = sumTP / adaptiveLen

sumDev = 0.0
for i = 0 to adaptiveLen - 1 by 1
    sumDev := sumDev + math.abs(nz(tp[i]) - meanTP)
meanDev = sumDev / adaptiveLen

cciRaw = meanDev > 0 ? (tp - meanTP) / (cciConstant * meanDev) : 0.0

f_smooth(src, len, type) =>
    switch type
        'SMA' => ta.sma(src, len)
        'EMA' => ta.ema(src, len)
        'WMA' => ta.wma(src, len)
        'RMA' => ta.rma(src, len)
        =>       src

cci = f_smooth(cciRaw, smoothLength, smoothType)

//              ╔════════════════════════════════╗              //
//              ║          VISUALIZATION         ║              //
//              ╚════════════════════════════════╝              //

lineColor = cci >= upperLevel ? obColor : cci <= lowerLevel ? osColor : color.gray

plot(enableGlow ? cci : na, 'AFT-CCI Glow Outer', color.new(lineColor, 88), 20)
plot(enableGlow ? cci : na, 'AFT-CCI Glow Mid',   color.new(lineColor, 75), 10, display = display.none)
plot(enableGlow ? cci : na, 'AFT-CCI Glow Inner', color.new(lineColor, 50),  5, display = display.none)
plot(cci, 'AFT-CCI', color.new(lineColor, 0), 2)

var line upperLine = line.new(bar_index, upperLevel, bar_index + 1, upperLevel, extend = extend.both, style = line.style_dashed)
var line lowerLine = line.new(bar_index, lowerLevel, bar_index + 1, lowerLevel, extend = extend.both, style = line.style_dashed)

line.set_color(upperLine, color.new(obColor, 20))
line.set_color(lowerLine, color.new(osColor, 20))
line.set_y1(upperLine, upperLevel)
line.set_y2(upperLine, upperLevel)
line.set_y1(lowerLine, lowerLevel)
line.set_y2(lowerLine, lowerLevel)

hline(0, 'Zero Line', color.new(color.gray, 60), hline.style_dotted)

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

enteredOB   = ta.crossover(cci,  upperLevel)
exitedOB    = ta.crossunder(cci, upperLevel)
enteredOS   = ta.crossunder(cci, lowerLevel)
exitedOS    = ta.crossover(cci,  lowerLevel)
bullishZero = ta.crossover(cci,  0)
bearishZero = ta.crossunder(cci, 0)

alertcondition(enteredOB,   title = 'Entered Overbought',  message = 'AFT-CCI: Entered overbought territory on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(exitedOB,    title = 'Exited Overbought',   message = 'AFT-CCI: Exited overbought territory on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(enteredOS,   title = 'Entered Oversold',    message = 'AFT-CCI: Entered oversold territory on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(exitedOS,    title = 'Exited Oversold',     message = 'AFT-CCI: Exited oversold territory on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bullishZero, title = 'Bullish Zero Cross',  message = 'AFT-CCI: Crossed above zero line on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bearishZero, title = 'Bearish Zero Cross',  message = 'AFT-CCI: Crossed below zero line on {{exchange}}:{{ticker}} - {{interval}}')

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
