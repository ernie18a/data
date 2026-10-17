# Monotonic Trend Consensus [QuantAlgo]

- url: https://www.tradingview.com/script/BMMefyPo-Monotonic-Trend-Consensus-QuantAlgo/
- type: indicator
- pine_id: PUB;2d70fa3c197d48e5aacd30da15bc45cc
- version: 1.0

## Description

[b]🟢 Overview[/b]

[b]Monotonic Trend Consensus[/b] is a trend-following oscillator built on rank correlation between price and time rather than moving averages or crossovers. It scores how consistently price is ordered across multiple lookback windows and combines them into a single bounded reading on a -1 to +1 scale, holding the same meaning on any symbol or timeframe so traders can separate a broadly aligned trend from directionless noise and read when a move has stretched to saturation.
[image]https://www.tradingview.com/x/dSQQxPWj/[/image]
[b]🟢 How It Works[/b]

The foundation is Spearman rank correlation between price and time, computed over each active window. Closes inside the window are ranked against one another, time forms its own rising sequence of ranks, and the difference between the two collapses to a single coefficient (rho):
[pine]float price_rank = less + (eq + 1.0) / 2.0
float time_rank  = float(len - i)
float rho = 1.0 - 6.0 * sumd2 / denom[/pine]
The coefficient reads +1 when each bar closes above the last in unbroken order, 0 when there is no consistent order, and -1 when each bar steps lower. Because it scores ordering rather than smoothing price into a line, it reflects the current window directly rather than trailing behind it, though it still needs a full window of bars to form. Ranking also limits the pull of any single outlier bar, and the bounded output is what lets one threshold hold across markets without rescaling.

A single window describes direction; the tool runs several and averages them into a consensus spanning fast, medium, and slow horizons:
[pine]consensus := array.avg(rhos)[/pine]
Agreement is then measured as the share of windows leaning the same way as the consensus, and this conviction figure must clear a floor before a direction prints, working alongside the strength threshold:
[pine]conviction := 100.0 * agree / active
raw_bull = consensus > threshold and conviction >= min_conviction
raw_bear = consensus < -threshold and conviction >= min_conviction[/pine]
A reading registers only when both clear at once: consensus past the threshold and windows aligned enough to meet the conviction floor. Fail either and the line stays flat. With Show Neutral on, those flat stretches reset to neutral; with it off, the line holds its last direction until the next qualifying move.
[image]https://www.tradingview.com/x/A1ccoQYt/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Bullish Consensus (Green):[/b] Consensus sits above the upper threshold with enough windows aligned, meaning recent bars are ordered upward across horizons. Trend traders read the turn into green as a possible long or continuation as the score presses toward +1. Mean-reversion traders treat a reading pinned near +1 as a stretched, broadly-agreed advance rather than a buy, and look to fade only once the line rolls back off the extreme, since the score can hold high through a sustained trend.

[b]▶ Bearish Consensus (Red):[/b] Consensus sits below the lower threshold with conviction met, with bars ordered downward across horizons. Trend traders read the turn into red as a possible short or continuation as the score presses toward -1. Mean-reversion traders treat a reading pinned near -1 as a saturated decline where a bounce becomes more plausible, and look to fade on the turn back up rather than at the low itself.

[b]▶ Neutral (Gray):[/b] With Show Neutral on, the line goes gray whenever no direction qualifies, either because consensus sits inside the threshold or conviction falls short. The zero line acts as the balance point and behaves like support or resistance for the reading itself: a score rejected at zero from above points to bullish order reasserting, a score capped at zero from below points to bearish order holding, and a clean break through leans toward a regime change. Reading this midline behavior against price is where market structure tools pair well, separating a base building above a structural level from a coil forming under overhead supply. Trend traders stand aside until the line commits; mean-reversion traders find less to work with here than at the edges.

[b]▶ Reading the Extremes:[/b] The axis caps at +1 and -1, marking maximum agreement across every active window. Trend traders take an extreme as a sign a move is still in force; mean-reversion traders take it as a stretched zone and watch for the score to turn back toward zero as agreement breaks. An extreme that aligns with a known structural level gives a fade a cleaner reference than one in open space, and neither read holds on the extreme alone, since a strong trend can stay saturated before it cools.
[image]https://www.tradingview.com/x/oJgsg5zk/[/image]
[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Three setups map to different holding styles. "Default" suits swing work on 4-hour and daily charts, pairing a mid-range window spread of 8, 13, 21, and 34 with a 0.35 threshold and a 60% conviction floor, so a direction needs both strength and agreement before it flags. "Fast Response" pulls the windows in to 5, 8, 13, and 21 and eases the threshold and conviction floor so the reading keeps pace with quicker intraday swings. "Smooth Trend" stretches the windows out to 21, 34, 55, and 89 and raises both gates for daily and weekly position trading, where a premature flip costs more than a late one. Choosing a preset takes over the manual window, threshold, and conviction fields.
[image]https://www.tradingview.com/x/onh4HqGn/[/image]
[b]▶ Built-in Alerts:[/b] Four conditions track every change in state. "Bullish Trend Signal" triggers when the consensus confirms to the upside. "Bearish Trend Signal" triggers when it confirms to the downside. "Trend Lost / Neutral" triggers when an active direction fades back to flat, which is also the event a mean-reversion trader watches for after an extreme. "Any Trend Change" rolls the two directional events into a single notification for anyone who wants one alert covering both ways.
[image]https://www.tradingview.com/x/UB3uhchd/[/image]
[b]▶ Visual Customization:[/b] Six color schemes (Classic, Aqua, Cosmic, Cyber, Neon, and Custom) carry a matched pair of bullish and bearish colors through the consensus line, its tiered gradient fill down to the zero baseline, and the optional bar and background tints. Marker lines sit at the positive and negative trigger levels to show the zone the consensus has to cross, and each window's own score can be switched on as a faint backing line so you can see which horizons are driving or dragging the combined figure. Bar coloring paints the price candles in the active trend color at an adjustable transparency, while background coloring spreads that tint across the pane.
[image]https://www.tradingview.com/x/G2NjjpVF/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Monotonic Trend Consensus [QuantAlgo]', overlay = false, max_bars_back = 300)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string core_settings      = '════════ Core Settings ════════'
var string timescale_settings = '════════ Timescale Settings ════════'
var string visual_settings    = '════════ Visual Settings ════════'

tooltip_preset       = 'Select a predefined configuration optimized for different trading styles and timeframes. Default applies your manual Timescale, Threshold, and Conviction inputs as-is. Fast Response and Smooth Trend override those values with tuned presets.'
tooltip_preset_det   = 'Default (Windows 8/13/21/34, Threshold 0.35, Conviction 60%): Balanced configuration for swing trading on 4H and daily charts. A spread of mid-range timescales that confirms genuine directional moves while filtering routine noise.\n\nFast Response (Windows 5/8/13/21, Threshold 0.25, Conviction 50%): Aggressive configuration for intraday trading on 5min to 1H charts. Shorter windows and a lower threshold react quickly to emerging trends at the cost of more frequent flips.\n\nSmooth Trend (Windows 21/34/55/89, Threshold 0.45, Conviction 75%): Conservative configuration for position trading on daily and weekly charts. Longer windows and a higher conviction requirement produce a stable directional baseline with minimal whipsaw.'
tooltip_src          = 'Price data used as input for the rank-correlation engine. Close is standard and works well in most conditions. hl2 incorporates the bar range and can reduce wick-driven noise. hlc3 adds further stability by averaging high, low, and close equally.'
tooltip_threshold    = 'The minimum strength the consensus must reach, in either direction, before a trend is registered. The engine scores how monotonically price is moving across all active timescales on a fixed -1 to +1 scale, so this single threshold behaves identically on any symbol or timeframe with no volatility input required. Higher values demand cleaner, more sustained moves and produce fewer, higher-conviction direction changes. Lower values register trends earlier and increase signal frequency.'
tooltip_conviction   = 'The minimum percentage of active timescales that must agree on direction before a trend is flagged. At 100 percent every window must point the same way, yielding the highest-quality but least frequent signals. Lower values allow a trend to register while shorter and longer horizons are still aligning, catching moves earlier at the cost of some reliability.'
tooltip_windows      = 'Each window measures how strongly price has moved in one direction over that many bars, scored from -1 (a clean staircase down) through 0 (no consistent direction) to +1 (a clean staircase up). Because the score is rank-based, a single spike bar cannot dominate the reading and no smoothing is applied, so the engine responds without the lag of a moving average. Running several windows together captures short, medium, and long horizons at once, and the trend is strongest when they agree. Toggle each window with its checkbox and set its length in the field beside it. Note that computation grows with the square of window length, so very large windows on long history can slow the chart.'
tooltip_show_neutral = 'When enabled, the line and fills turn neutral color whenever no trend qualifies, meaning the consensus is inside the threshold or conviction is below the minimum. When disabled, the line holds its last bullish or bearish color through those flat stretches.'
tooltip_show_comp    = 'Overlay the individual score of each active window as a faint line behind the consensus. Useful for seeing which timescales are leading or diverging from the combined reading. Disable for a clean consensus-only view.'
tooltip_color_preset = 'Pre-configured color schemes optimized for different chart themes and visual preferences. Classic uses traditional green and red. Aqua provides ocean inspired blue and orange. Cosmic offers cyan and purple. Cyber features warm orange against cool cyan. Neon delivers high contrast yellow and magenta. Custom lets you set the bull and bear colors yourself.'
tooltip_bullish      = 'Color applied to the line and gradient fill when the consensus is trending upward.'
tooltip_bearish      = 'Color applied to the line and gradient fill when the consensus is trending downward.'
tooltip_neutral_col  = 'Color shown when no trend qualifies and Show Neutral is enabled. Gray is recommended as a clear cue that separates a flat reading from an active directional move.'
tooltip_candles      = 'Enable/disable price bar coloring based on the current trend state. When enabled, bars on the main chart are tinted with the bullish, bearish, or neutral color, giving instant confirmation of trend direction without watching the pane.'
tooltip_bar_trans    = 'Transparency of the bar coloring overlay. Lower values produce vivid bars that make trend direction immediately obvious. Higher values apply a subtle tint that signals state without overwhelming price action.'
tooltip_bgcolor      = 'Enable/disable background coloring of the indicator pane based on the current trend state. Tints the pane with the bullish, bearish, or neutral color to reinforce trend state.'
tooltip_bg_trans     = 'Transparency of the background coloring overlay. Lower values produce a vivid tint. Higher values apply a subtle wash that signals state without obscuring the line.'

preset         = input.string('Default', 'Preset Configuration', options = ['Default', 'Fast Response', 'Smooth Trend'], group = core_settings, tooltip = tooltip_preset + '\n\n' + tooltip_preset_det)
src            = input.source(close, 'Price Source', group = core_settings, tooltip = tooltip_src)
threshold      = input.float(0.35, 'Trend Threshold', minval = 0.0, maxval = 1.0, step = 0.05, group = core_settings, tooltip = tooltip_threshold)
min_conviction = input.int(60, 'Min Conviction %', minval = 0, maxval = 100, step = 10, group = core_settings, tooltip = tooltip_conviction)

e1 = input.bool(true,  'Window 1', inline = 'w1', group = timescale_settings, tooltip = tooltip_windows)
l1 = input.int(8,   '', minval = 3, maxval = 200, inline = 'w1', group = timescale_settings)
e2 = input.bool(true,  'Window 2', inline = 'w2', group = timescale_settings)
l2 = input.int(13,  '', minval = 3, maxval = 200, inline = 'w2', group = timescale_settings)
e3 = input.bool(true,  'Window 3', inline = 'w3', group = timescale_settings)
l3 = input.int(21,  '', minval = 3, maxval = 200, inline = 'w3', group = timescale_settings)
e4 = input.bool(true,  'Window 4', inline = 'w4', group = timescale_settings)
l4 = input.int(34,  '', minval = 3, maxval = 200, inline = 'w4', group = timescale_settings)
e5 = input.bool(false, 'Window 5', inline = 'w5', group = timescale_settings)
l5 = input.int(55,  '', minval = 3, maxval = 200, inline = 'w5', group = timescale_settings)

show_neutral  = input.bool(true,  'Show Neutral', group = visual_settings, tooltip = tooltip_show_neutral)
show_comp     = input.bool(false, 'Show Component Lines', group = visual_settings, tooltip = tooltip_show_comp)
color_preset  = input.string('Custom', 'Color Preset', options = ['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group = visual_settings, tooltip = tooltip_color_preset)
bullish_input = input.color(#00ffaa, 'Bullish Color', group = visual_settings, tooltip = tooltip_bullish)
bearish_input = input.color(#ff0000, 'Bearish Color', group = visual_settings, tooltip = tooltip_bearish)
neutral_input = input.color(#808080, 'Neutral Color', group = visual_settings, tooltip = tooltip_neutral_col)
show_candles  = input.bool(false, 'Enable Bar Coloring', group = visual_settings, tooltip = tooltip_candles)
bar_trans     = input.int(0, 'Bar Color Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bar_trans)
show_bgcolor  = input.bool(false, 'Enable Background Coloring', group = visual_settings, tooltip = tooltip_bgcolor)
bg_trans      = input.int(90, 'Background Color Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bg_trans)

if preset == 'Fast Response'
    e1 := true
    e2 := true
    e3 := true
    e4 := true
    e5 := false
    l1 := 5
    l2 := 8
    l3 := 13
    l4 := 21
    threshold      := 0.25
    min_conviction := 50
else if preset == 'Smooth Trend'
    e1 := true
    e2 := true
    e3 := true
    e4 := true
    e5 := false
    l1 := 21
    l2 := 34
    l3 := 55
    l4 := 89
    threshold      := 0.45
    min_conviction := 75

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

f_spearman(s, len) =>
    float sumd2 = 0.0
    for i = 0 to len - 1
        float pi   = s[i]
        float less = 0.0
        float eq   = 0.0
        for j = 0 to len - 1
            float pj = s[j]
            if pj < pi
                less += 1.0
            else if pj == pi
                eq += 1.0
        float price_rank = less + (eq + 1.0) / 2.0
        float time_rank  = float(len - i)
        float d = price_rank - time_rank
        sumd2 += d * d
    float denom = float(len) * len * len - len
    float rho = denom > 0 ? 1.0 - 6.0 * sumd2 / denom : 0.0
    math.max(-1.0, math.min(1.0, rho))

r1 = e1 and bar_index >= l1 ? f_spearman(src, l1) : na
r2 = e2 and bar_index >= l2 ? f_spearman(src, l2) : na
r3 = e3 and bar_index >= l3 ? f_spearman(src, l3) : na
r4 = e4 and bar_index >= l4 ? f_spearman(src, l4) : na
r5 = e5 and bar_index >= l5 ? f_spearman(src, l5) : na

rhos = array.new<float>()
if not na(r1)
    array.push(rhos, r1)
if not na(r2)
    array.push(rhos, r2)
if not na(r3)
    array.push(rhos, r3)
if not na(r4)
    array.push(rhos, r4)
if not na(r5)
    array.push(rhos, r5)

int active = array.size(rhos)
float consensus = 0.0
if active > 0
    consensus := array.avg(rhos)

int agree = 0
if active > 0
    int sgn = consensus >= 0 ? 1 : -1
    for i = 0 to active - 1
        float v = array.get(rhos, i)
        if (v >= 0 ? 1 : -1) == sgn
            agree += 1
float conviction = active > 0 ? 100.0 * agree / active : 0.0

bool raw_bull = consensus >  threshold and conviction >= min_conviction
bool raw_bear = consensus < -threshold and conviction >= min_conviction
int  raw_state = raw_bull ? 1 : raw_bear ? -1 : 0

var int trend_dir = 0
trend_dir := raw_state != 0 ? raw_state : (show_neutral ? 0 : trend_dir)

turned_bullish = trend_dir ==  1 and trend_dir[1] !=  1
turned_bearish = trend_dir == -1 and trend_dir[1] != -1
turned_neutral = trend_dir ==  0 and trend_dir[1] !=  0
trend_changed  = turned_bullish or turned_bearish

//              ╔════════════════════════════════╗              //
//              ║         VISUALIZATION          ║              //
//              ╚════════════════════════════════╝              //

line_color = trend_dir == 1 ? bullish_color : trend_dir == -1 ? bearish_color : neutral_input

g1 = consensus * 0.75
g2 = consensus * 0.50
g3 = consensus * 0.25

p_line = plot(consensus, 'Consensus', color = line_color, linewidth = 3)
p_zero = plot(0,  display = display.none)
p_g1   = plot(g1, display = display.none)
p_g2   = plot(g2, display = display.none)
p_g3   = plot(g3, display = display.none)

fill(p_line, p_g1, color = color.new(line_color, 55))
fill(p_g1, p_g2,   color = color.new(line_color, 70))
fill(p_g2, p_g3,   color = color.new(line_color, 82))
fill(p_g3, p_zero, color = color.new(line_color, 92))

plot(show_comp and not na(r1) ? r1 : na, 'Window 1', color = color.blue, linewidth = 1)
plot(show_comp and not na(r2) ? r2 : na, 'Window 2', color = color.orange, linewidth = 1)
plot(show_comp and not na(r3) ? r3 : na, 'Window 3', color = color.lime, linewidth = 1)
plot(show_comp and not na(r4) ? r4 : na, 'Window 4', color = color.fuchsia, linewidth = 1)
plot(show_comp and not na(r5) ? r5 : na, 'Window 5', color = color.yellow, linewidth = 1)

plot( threshold, 'Bull Threshold', color = color.new(bullish_color, 60), linewidth = 1)
plot(-threshold, 'Bear Threshold', color = color.new(bearish_color, 60), linewidth = 1)
hline(0,  'Zero', color.new(neutral_input, 70))
hline(1,  '+1',   color.new(neutral_input, 85), linestyle = hline.style_dotted)
hline(-1, '-1',   color.new(neutral_input, 85), linestyle = hline.style_dotted)

barcolor(show_candles ? color.new(line_color, bar_trans) : na, title = 'Trend Bar Color')
bgcolor(show_bgcolor  ? color.new(line_color, bg_trans)  : na, title = 'Trend Background Color')

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

alertcondition(turned_bullish, title = 'Bullish Trend Signal', message = 'Monotonic Trend Consensus: BULLISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(turned_bearish, title = 'Bearish Trend Signal', message = 'Monotonic Trend Consensus: BEARISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(turned_neutral, title = 'Trend Lost / Neutral', message = 'Monotonic Trend Consensus: trend lost, consensus flat on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(trend_changed,  title = 'Any Trend Change',     message = 'Monotonic Trend Consensus: trend direction changed on {{exchange}}:{{ticker}} - {{interval}}')

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
