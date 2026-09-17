<!-- tradingview-pine-id: PUB;4eb476fb097741088f60901dd2b04f12 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Regression Slope Oscillator [QuantAlgo]

Source: https://www.tradingview.com/script/EUeBe93y-Regression-Slope-Oscillator-QuantAlgo/

## Description

🟢 Overview

The Regression Slope Oscillator measures the rate of directional change in price using a robust regression estimator that resists outliers, then converts that slope into a scale free reading so a single threshold carries the same meaning across instruments and timeframes. Rather than fitting a least squares line, which a single spike or gap can pull off course, it takes the median of pairwise slopes inside a rolling window to produce a trend estimate that holds up through erratic data. A three state engine with separate entry and exit thresholds then translates the normalized slope into a bullish, bearish, or neutral regime, holding established states through pullbacks instead of flickering whenever the reading brushes the boundary.
[image]https://www.tradingview.com/x/5oLaNNsl/[/image]
🟢 How It Works

The indicator's core methodology lies in its combination of outlier resistant slope estimation and volatility relative normalization, where a trend regime is only established once the fitted rate of change clears a threshold expressed in units of the instrument's own volatility.

First, the source is optionally moved into log space so the fitted slope becomes a proportional rate of change rather than an absolute one, keeping readings comparable across instruments at very different price levels and across histories where price has moved by an order of magnitude:
[pine]srcMid = useLog ? math.log(srcSafe) : srcInput[/pine]
Then the slope is fitted across the window using a robust estimator rather than ordinary least squares, which has an effective breakdown point of zero and lets a single gap or liquidation wick tilt the fit for the entire window. Theil-Sen takes the median of every pairwise slope inside the window, tolerating roughly 29 percent contaminated data while staying close to a least squares fit on clean data:
[pine]for i = 0 to length - 2 by 1
    for j = i + 1 to length - 1 by 1
        array.push(slopes, (source - source[j]) / (j - i))
array.median(slopes)[/pine]
Repeated Median nests the same idea, taking a median of pairwise slopes anchored on each bar and then a median of those results, which lifts the breakdown point to 50 percent, the theoretical maximum, at several times the computational cost. Both estimators target the same underlying quantity, so switching between them changes robustness without shifting the scale.

The raw slope is then divided by a volatility unit to strip out the instrument's price scale and volatility regime, producing a reading that means the same thing on any chart:
[pine]normUnit = switch normMode
    'ATR'   => useLog ? atrUnit / srcSafe : atrUnit
    'Stdev' => sdevUnit
    =>         useLog ? 0.01 : srcSafe / 100.0
slope = rawMid / normUnit[/pine]
Each path is dimensionally self consistent with the log transform, so numerator and denominator always move together and the resulting reading stays dimensionless. In ATR mode a value of 0.10 means the trend is advancing at one tenth of an average true range per bar.

The normalized slope then drives a state engine where the level required to establish a regime and the level required to release it are deliberately different, creating a hysteresis band that suppresses boundary flicker:
[pine]if slope > entryTh
    state := 1
else if slope < -entryTh
    state := -1
else if useNeutral and state == 1 and slope < exitTh
    state := 0
else if useNeutral and state == -1 and slope > -exitTh
    state := 0[/pine]
Finally, in Candles display mode the estimator runs two additional passes against the chart high and the chart low, building a synthetic OHLC series in slope space where the body spans the change in slope and the wicks reveal how far trend disperses across the bar range, with an optional Heikin-Ashi transform applied on top:
[pine]barHigh = math.max(slopeHigh, math.max(barOpen, barClose))
barLow  = math.min(slopeLow, math.min(barOpen, barClose))
haClose = math.avg(barOpen, barHigh, barLow, barClose)[/pine]
[image]https://www.tradingview.com/x/Xe6fy9EI/[/image]
🟢 Signal Interpretation

▶ Bullish State (Oscillator Above the Upper Entry Band with Bullish Color)

The normalized slope has cleared the positive entry threshold, meaning price is advancing faster than the instrument's own recent volatility rather than simply drifting higher. Trend traders take the confirmation as a long entry and hold through pullbacks, since the state only releases once the slope retreats below the exit level rather than on every minor pause, and a reading that climbs deeper into the upper zones represents strengthening rather than a reason to exit. Mean reversion traders read the same plot for depth instead of direction. A reading sitting in the first zone is an ordinary trend and offers nothing to fade, but a push into the second or third upper zone means price is rising at two or three times the rate required for confirmation, which is statistically unusual and marks the region where an advance is most likely to decelerate and revert toward the band. The trigger for a fade is the turn back down out of the outer zone rather than arrival in it, because a steep slope can hold for a surprisingly long stretch in a genuine trend.

▶ Bearish State (Oscillator Below the Lower Entry Band with Bearish Color)

The normalized slope has cleared the negative entry threshold, confirming that price is declining at a rate meaningful relative to its own volatility. Trend traders use this for short entries or long exits and keep directional bias through corrective bounces that fail to reverse the underlying rate of change. Mean reversion traders again work from zone depth, treating a reading in the lower second or third zone as an accelerated decline that is stretched far enough for a bounce back toward the band to carry a favorable expected move. In either direction, a slope that decays back toward the entry band while price continues in the trend direction is an early rate of change divergence, giving mean reversion traders advance notice of exhaustion and trend traders a reason to tighten stops before the state formally releases.

▶ Neutral State (Oscillator Inside the Threshold Band with Neutral Color)

The oscillator has released into neutral, either because an established regime decayed back through its exit level or because the slope never cleared entry to begin with. This reading carries the same meaning for both styles, since price is neither trending quickly enough to follow nor stretched far enough to fade. Trend traders stand aside and watch for the compression that frequently precedes the next confirmed regime, while mean reversion traders treat the return into the band as a completed reversion and the natural place to close a fade, the move having exhausted itself by definition once the slope no longer clears the threshold.
[image]https://www.tradingview.com/x/qOj0rqm8/[/image]
🟢 Features

▶ Preconfigured Presets: Three optimized parameter sets tailored to different trading styles and timeframes, each configuring the slope window, normalization length, entry threshold, exit fraction, and normalization method together so the threshold always stays matched to the units it is measured in. "Default" balances noise filtering against responsiveness for swing trading on 4-hour and daily charts. "Fast Response" shortens the window and lowers the entry threshold to engage regimes early for intraday use on 5-minute to 1-hour charts, while a raised exit fraction releases them quickly. "Smooth Trend" lengthens the window and raises the entry threshold to produce few, high conviction regimes held through deep pullbacks, suited to position trading on daily and weekly charts.
[image]https://www.tradingview.com/x/yhqLlcFW/[/image]
▶ Built-in Alerts: Six alert conditions plus a dynamic alert message enable automated monitoring of regime transitions without constant chart observation. "Bullish State" and "Bearish State" trigger on first confirmation of a directional regime, "Neutral State" fires when a directional regime is released, and "Any State Change" provides a combined alert covering all transitions through a single setup. "Bullish Zero Cross" and "Bearish Zero Cross" track the moment the slope changes sign, offering an earlier and more sensitive trigger than threshold confirmation.
[image]https://www.tradingview.com/x/qQcNMOkV/[/image]
▶ Visual Customization: A Candles or Line display toggle switches between the full synthetic slope candle series and a single plotted value for a lighter, cleaner presentation. In Candles mode, an optional Heikin-Ashi transform makes sustained trend phases visually contiguous, and hollow up candles layer bar direction on top of the regime color so momentum inside a state can be read at a glance, for example a filled bar within a bullish phase indicating the slope eased on that bar. Graduated threshold zones fill at one, two, and three multiples of the entry threshold at progressively increasing transparency, giving an immediate sense of how far beyond confirmation the current reading sits.
[image]https://www.tradingview.com/x/IlEwtn41/[/image]
Six color presets (Classic, Aqua, Cosmic, Cyber, Neon, plus Custom) accommodate different chart themes with coordinated bullish and bearish schemes applied consistently across every element.
[image]https://www.tradingview.com/x/5P4wb85f/[/image]

---

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Regression Slope Oscillator [QuantAlgo]', overlay = false, precision = 2, max_bars_back = 250)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string grp_estimator = '════════ Slope Estimator ════════'
var string grp_norm      = '════════ Normalization ════════'
var string grp_signals   = '════════ Signal Thresholds ════════'
var string grp_visual    = '════════ Visualization Settings ════════'

tt_preset       = 'Select a predefined configuration optimized for different trading styles and timeframes.\n\nDefault (Window 21, Norm 14, Entry 0.10, Exit 0.40): Balanced configuration suited to swing trading on 4H and daily charts. Wide enough to filter noise while still turning inside a multi week move.\n\nFast Response (Window 10, Norm 7, Entry 0.06, Exit 0.55): Fast reacting setup for intraday use on 5min to 1H charts. The shorter window and lower entry threshold engage states early, while the raised exit fraction releases them quickly.\n\nSmooth Trend (Window 34, Norm 30, Entry 0.15, Exit 0.30): High stability setup for position traders on daily and weekly charts. The long window and raised entry threshold produce few, high conviction regimes that are held through deep pullbacks.\n\nBoth presets normalize by ATR. The entry threshold is denominated in the units of the normalization method, so the two must stay matched for the threshold to carry its intended meaning.\n\nThe manual Normalization Method, Window, Normalization Length, Entry Threshold and Exit Fraction inputs below are ignored unless this is set to Default.'
tt_source       = 'Price series the estimator is fitted to. Close is the standard choice and produces the most stable readings. Using hl2 or hlc3 incorporates intrabar range and slightly smooths the input. Note that candle wicks are always derived from the chart high and low regardless of this setting, so selecting a non price series here still produces a meaningful body but less meaningful wicks.\n\nThe indicator does not repaint on closed bars. There is no higher timeframe request, no lookahead offset and no future referencing anywhere in the calculation, so once a bar closes its reading and its state are final and are never revised. The developing bar behaves differently: because the estimator fits across a window that includes the current bar, the reading updates on every tick and the state can flip intrabar before settling at the close.\n\nFor that reason set every alert to Once Per Bar Close when creating it, so alerts fire on confirmed states rather than on intrabar movement. The built-in alert message is already pinned to bar close internally, but the alert conditions listed in the dialog inherit whichever frequency is selected there.'
tt_log          = 'Applies a natural logarithm to the source before fitting. Log space converts the slope into a proportional rate of change, keeping readings comparable across instruments at very different price levels and across long histories where price has moved by an order of magnitude. Disable only when the source can reach zero or go negative, such as a spread or a differenced series. Default is enabled.'
tt_method       = 'Regression estimator used to fit the slope. Theil-Sen takes the median of all pairwise slopes inside the window and tolerates roughly 29 percent contaminated data before breaking down. It is the faster option and the recommended default. Repeated Median computes a median of pairwise slopes anchored on each individual bar, then takes the median of those results, tolerating up to 50 percent contamination. Repeated Median is noticeably more resistant to isolated spikes and gaps but costs substantially more computation per bar. This input is never overridden by the preset.'
tt_window       = 'Number of bars the estimator fits across. Shorter windows of 8 to 15 track turns quickly but produce a noisier slope. Longer windows of 30 to 40 yield a smooth, high conviction reading with more lag. Computation scales with the square of this value, so pairing a 40 bar window with Repeated Median in Candles mode is the heaviest configuration available. Only active when Preset Configuration is set to Default.'
tt_norm_mode    = 'Method used to convert the raw slope into a scale free reading so thresholds carry the same meaning across instruments and timeframes. ATR divides the slope by average true range, expressing trend as movement per bar in volatility units and adapting automatically as volatility regimes shift. Stdev divides by the standard deviation of bar to bar changes, producing a reading closer to a t statistic that reacts faster than ATR to volatility compression. Percent expresses the slope directly as percent change per bar and ignores volatility entirely, which suits a fixed economic threshold rather than a volatility adjusted one. Readings are not interchangeable between the three methods, so the entry threshold must be retuned whenever this is changed. Only active when Preset Configuration is set to Default.'
tt_norm_len     = 'Lookback used by the normalization unit, meaning the ATR period or the standard deviation period depending on the method selected. Shorter values of 5 to 10 make the oscillator adapt quickly to volatility shifts, compressing readings during expansions and amplifying them during contractions. Longer values of 30 to 50 hold the scale steadier so raw trend magnitude comes through more directly. Has no effect when Normalization is set to Percent. Only active when Preset Configuration is set to Default.'
tt_entry        = 'Slope magnitude required to establish a directional state. The oscillator turns bullish above this level and bearish below its negative. In ATR mode a value of 0.10 means the trend is advancing at one tenth of an ATR per bar. In Percent mode the same 0.10 means one tenth of one percent per bar, so this input needs retuning whenever the normalization method changes. Raise it to filter out marginal trends, lower it to engage earlier. Practical values sit between 0.05 and 0.30.\n\nSetting this to zero removes the threshold entirely and turns the oscillator into a pure sign follower that flips on every zero crossing. In that mode a neutral state becomes unreachable, so both the Neutral State toggle and the Exit Fraction have no effect, and the threshold zones fall back to a fixed 0.10 scale so the graduated fills remain visible.\n\nThe input is capped at 1.00. The zone fills are drawn out to three times this value and those fills set the pane scale, so a threshold near the cap stretches the pane to plus and minus 3.00 while the oscillator itself rarely sustains beyond 1.00 in ATR and Stdev modes. The result is a correct but visually compressed plot floating inside oversized zones. Stay well below the cap unless you are running Percent normalization on a higher timeframe. Only active when Preset Configuration is set to Default.'
tt_exit         = 'Fraction of the entry threshold at which an established state is released. At 0.40 a bullish state entered at 0.10 is held until the slope falls below 0.04, creating a hysteresis band that stops the state flickering while the slope hovers near the entry level. A value of 1.00 removes hysteresis entirely and exits at the entry level. Lower values hold states longer and produce fewer, more persistent regimes. Has no effect when Neutral State is disabled or when Entry Threshold is set to zero. Only active when Preset Configuration is set to Default.'
tt_neutral_st   = 'Allows the oscillator to hold a third, non directional state. When enabled, an established regime is released back to neutral once the slope decays past the exit level, marking ranging and transitional conditions where the estimator finds no reliable trend. When disabled the oscillator becomes a two state engine that stays committed to its last direction until the opposite entry threshold is cleared, producing continuous directional bias with no flat periods, which suits systems that are always positioned. Disabling this makes the Exit Fraction and Neutral Color inputs inert and prevents the Neutral State alert from firing. This toggle also has no effect when Entry Threshold is set to zero, because a neutral state is unreachable at that setting. Default is enabled.'
tt_display      = 'Controls how the oscillator is rendered. Candles builds a synthetic OHLC series in slope space, where the body spans the change in slope and the wicks come from fitting the estimator separately to the chart high and low, showing how far trend disperses across the bar range. Line plots the slope as a single value. Candles cost roughly three times the computation of Line because the estimator runs three passes per bar instead of one.'
tt_ha           = 'Applies a Heikin-Ashi transform to the slope candles. The transform averages each bar against the one before it, suppressing single bar noise and making sustained trend phases visually contiguous. Disable to see unsmoothed slope bars, which react faster but appear choppier. Only active in Candles display mode. Default is enabled.'
tt_hollow       = 'Draws candles closing above their open as hollow outlines rather than filled bodies. This layers bar direction on top of the state color, letting you read momentum inside a state, for example a filled bar within a bullish phase indicating the slope eased on that bar. Disable for solid candles throughout. Only active in Candles display mode.'
tt_color_preset = 'Pre-configured color schemes optimized for different chart themes and visual preferences. Classic uses traditional green and red. Aqua provides ocean inspired blue and orange. Cosmic offers futuristic mint and purple. Cyber features cool cyan and warm orange contrast. Neon delivers high contrast yellow and magenta for maximum visibility. Custom is the default and allows full color control via the three color inputs below.'
tt_bull         = 'Color applied while the oscillator holds a bullish state, meaning the normalized slope has cleared the entry threshold and has not yet retreated past the exit level. Also tints the upper threshold zones. Only active when Color Preset is set to Custom.'
tt_bear         = 'Color applied while the oscillator holds a bearish state, meaning the normalized slope has cleared the negative entry threshold and has not yet recovered past the exit level. Also tints the lower threshold zones. Only active when Color Preset is set to Custom.'
tt_neutral      = 'Color applied while the oscillator holds no directional state, meaning the slope sits inside the threshold band. Neutral bars mark ranging or transitional conditions where the estimator finds no reliable trend. Has no effect when Neutral State is disabled or when Entry Threshold is set to zero. Only active when Color Preset is set to Custom.'

presetInput   = input.string('Default', 'Preset Configuration',
     options = ['Default', 'Fast Response', 'Smooth Trend'],
     group   = grp_estimator, tooltip = tt_preset)

srcInput      = input.source(close, 'Source',        group = grp_estimator, tooltip = tt_source)
useLog        = input.bool  (true,  'Log Transform', group = grp_estimator, tooltip = tt_log)
estimator     = input.string('Theil-Sen', 'Estimator Method', options = ['Theil-Sen', 'Repeated Median'], group = grp_estimator, tooltip = tt_method)
slopeLenInput = input.int   (21, 'Slope Window', minval = 5, maxval = 40, group = grp_estimator, tooltip = tt_window)

normModeInput = input.string('ATR', 'Normalization Method', options = ['ATR', 'Stdev', 'Percent'], group = grp_norm, tooltip = tt_norm_mode)
normLenInput  = input.int   (14, 'Normalization Length', minval = 2, maxval = 200, group = grp_norm, tooltip = tt_norm_len)

entryThInput  = input.float (0.10, 'Entry Threshold', minval = 0.0, maxval = 1.0, step = 0.01, group = grp_signals, tooltip = tt_entry)
exitFracInput = input.float (0.40, 'Exit Fraction', minval = 0.0, maxval = 1.0, step = 0.05, group = grp_signals, tooltip = tt_exit)
useNeutral    = input.bool  (true, 'Enable Neutral State', group = grp_signals, tooltip = tt_neutral_st)

displayMode   = input.string('Candles', 'Display Style', options = ['Candles', 'Line'], group = grp_visual, tooltip = tt_display)
useHA         = input.bool  (true, 'Heikin-Ashi Transform', group = grp_visual, tooltip = tt_ha)
hollowUp      = input.bool  (true, 'Hollow Up Candles',     group = grp_visual, tooltip = tt_hollow)
colorPreset   = input.string('Custom', 'Color Preset', options = ['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group = grp_visual, tooltip = tt_color_preset)
bullInput     = input.color (#00ffaa,    'Bullish Color', group = grp_visual, tooltip = tt_bull)
bearInput     = input.color (#ff0000,    'Bearish Color', group = grp_visual, tooltip = tt_bear)
neutInput     = input.color (color.gray, 'Neutral Color', group = grp_visual, tooltip = tt_neutral)

[slopeLen, normLen, entryTh, exitFrac, normMode] = switch presetInput
    'Fast Response' => [10, 7,  0.06, 0.55, 'ATR']
    'Smooth Trend'  => [34, 30, 0.15, 0.30, 'ATR']
    =>                 [slopeLenInput, normLenInput, entryThInput, exitFracInput, normModeInput]

[bullColor, bearColor, neutColor] = switch colorPreset
    'Classic' => [#00ff00, #ff0000, color.gray]
    'Aqua'    => [#00d4ff, #ff8c00, color.gray]
    'Cosmic'  => [#49ffce, #9932cc, color.gray]
    'Cyber'   => [#00cccc, #ff6600, color.gray]
    'Neon'    => [#ffff00, #ff00ff, color.gray]
    'Custom'  => [bullInput, bearInput, neutInput]

//              ╔════════════════════════════════╗              //
//              ║     ROBUST SLOPE ESTIMATOR     ║              //
//              ╚════════════════════════════════╝              //

f_robustSlope(float source, simple int length, simple bool repeated) =>
    var slopes = array.new<float>()
    var anchor = array.new<float>()
    array.clear(slopes)
    if repeated
        for i = 0 to length - 1 by 1
            array.clear(anchor)
            for j = 0 to length - 1 by 1
                if j != i
                    float d = source[i] - source[j]
                    if not na(d)
                        array.push(anchor, d / (j - i))
            if array.size(anchor) > 0
                array.push(slopes, array.median(anchor))
    else
        for i = 0 to length - 2 by 1
            for j = i + 1 to length - 1 by 1
                float d = source[i] - source[j]
                if not na(d)
                    array.push(slopes, d / (j - i))
    array.size(slopes) > 0 ? array.median(slopes) : na

//              ╔════════════════════════════════╗              //
//              ║     NORMALIZATION AND STATE    ║              //
//              ╚════════════════════════════════╝              //

simple bool useRepeated = estimator == 'Repeated Median'
simple bool showCandles = displayMode == 'Candles'

float srcSafe  = math.max(srcInput, 1e-10)
float srcMid   = useLog ? math.log(srcSafe) : srcInput
float srcHigh  = useLog ? math.log(math.max(high, 1e-10)) : high
float srcLow   = useLog ? math.log(math.max(low, 1e-10)) : low

float atrUnit  = ta.atr(normLen)
float sdevUnit = ta.stdev(ta.change(srcMid), normLen)

float normUnit = switch normMode
    'ATR'   => useLog ? atrUnit / srcSafe : atrUnit
    'Stdev' => sdevUnit
    =>         useLog ? 0.01 : srcSafe / 100.0

float rawMid  = f_robustSlope(srcMid, slopeLen, useRepeated)
float rawHigh = showCandles ? f_robustSlope(srcHigh, slopeLen, useRepeated) : na
float rawLow  = showCandles ? f_robustSlope(srcLow, slopeLen, useRepeated) : na

bool  ready     = bar_index >= slopeLen and not na(normUnit) and normUnit > 0
float slope     = ready ? rawMid / normUnit : na
float slopeHigh = ready ? rawHigh / normUnit : na
float slopeLow  = ready ? rawLow / normUnit : na

float exitTh   = entryTh * exitFrac
float zoneUnit = entryTh > 0 ? entryTh : 0.10

var int state = 0
if slope > entryTh
    state := 1
else if slope < -entryTh
    state := -1
else if useNeutral and state == 1 and slope < exitTh
    state := 0
else if useNeutral and state == -1 and slope > -exitTh
    state := 0

if not useNeutral and state == 0 and ready and not na(slope)
    state := slope >= 0 ? 1 : -1

color stateColor = state == 1 ? bullColor : state == -1 ? bearColor : neutColor

//              ╔════════════════════════════════╗              //
//              ║    SLOPE CANDLE CONSTRUCTION   ║              //
//              ╚════════════════════════════════╝              //

float barOpen  = nz(slope[1], slope)
float barClose = slope
float barHigh  = math.max(slopeHigh, math.max(barOpen, barClose))
float barLow   = math.min(slopeLow, math.min(barOpen, barClose))

var float haOpen = na
float haClose = math.avg(barOpen, barHigh, barLow, barClose)
haOpen := na(haOpen[1]) ? math.avg(barOpen, barClose) : math.avg(haOpen[1], haClose[1])
float haHigh = math.max(barHigh, math.max(haOpen, haClose))
float haLow  = math.min(barLow, math.min(haOpen, haClose))

float plotOpen  = useHA ? haOpen : barOpen
float plotHigh  = useHA ? haHigh : barHigh
float plotLow   = useHA ? haLow : barLow
float plotClose = useHA ? haClose : barClose

color bodyColor = hollowUp and plotClose >= plotOpen ? color.new(stateColor, 100) : stateColor

//              ╔════════════════════════════════╗              //
//              ║          VISUALIZATION         ║              //
//              ╚════════════════════════════════╝              //

zoneU3 = plot(zoneUnit * 3,  'Upper Zone 3', display = display.none)
zoneU2 = plot(zoneUnit * 2,  'Upper Zone 2', display = display.none)
zoneU1 = plot(zoneUnit,      'Upper Entry Band', color.new(bullColor, 60), display = display.none)
zoneD1 = plot(-zoneUnit,     'Lower Entry Band', color.new(bearColor, 60), display = display.none)
zoneD2 = plot(-zoneUnit * 2, 'Lower Zone 2', display = display.none)
zoneD3 = plot(-zoneUnit * 3, 'Lower Zone 3', display = display.none)

fill(zoneU1, zoneU2, color.new(bullColor, 90), 'Upper Zone Fill 1')
fill(zoneU2, zoneU3, color.new(bullColor, 80), 'Upper Zone Fill 2')
fill(zoneD1, zoneD2, color.new(bearColor, 90), 'Lower Zone Fill 1')
fill(zoneD2, zoneD3, color.new(bearColor, 80), 'Lower Zone Fill 2')

plot(0, 'Zero Line', color.new(color.gray, 70), 1)

plotcandle(showCandles ? plotOpen : na, showCandles ? plotHigh : na, showCandles ? plotLow : na, showCandles ? plotClose : na,
     'Slope Candles', bodyColor, stateColor, bordercolor = stateColor)
plot(showCandles ? na : slope, 'Regression Slope', stateColor, 2)

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

bullishState = state ==  1 and state[1] !=  1
bearishState = state == -1 and state[1] != -1
neutralState = state ==  0 and state[1] !=  0
stateChange  = state != state[1] and not na(slope)
bullishZero  = ta.crossover (slope, 0)
bearishZero  = ta.crossunder(slope, 0)

string stateText = state == 1 ? 'Bullish state confirmed' : state == -1 ? 'Bearish state confirmed' : 'Directional state released'

if stateChange
    alert('Regression Slope: ' + stateText + ' on ' + syminfo.tickerid + ' - ' + timeframe.period, alert.freq_once_per_bar_close)

alertcondition(stateChange,  title = 'Any State Change',   message = 'Regression Slope: State changed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bullishState, title = 'Bullish State',      message = 'Regression Slope: Bullish state confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bearishState, title = 'Bearish State',      message = 'Regression Slope: Bearish state confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(neutralState, title = 'Neutral State',      message = 'Regression Slope: Directional state released on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bullishZero,  title = 'Bullish Zero Cross', message = 'Regression Slope: Crossed above zero line on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bearishZero,  title = 'Bearish Zero Cross', message = 'Regression Slope: Crossed below zero line on {{exchange}}:{{ticker}} - {{interval}}')

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
