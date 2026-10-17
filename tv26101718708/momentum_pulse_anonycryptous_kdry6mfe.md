# Momentum Pulse | Anonycryptous

- url: https://www.tradingview.com/script/KDry6mFe-Momentum-Pulse-Anonycryptous/
- type: indicator
- pine_id: PUB;034ac9e73c5743b7818beeb4e721f5dc
- version: 1.0

## Description

Momentum Pulse | Anonycryptous
Description & user manual

Why this indicator is different
Standard momentum indicators give you one line. RSI tells you whether the market is overbought or oversold at one specific lookback period. MACD tells you whether one moving average is pulling away from another. One perspective. One answer.
The problem is that momentum does not exist at one lookback period. A 14-period RSI can be flat while a 7-period RSI is already reversing. A 21-period RSI can still be bullish while the fast momentum has already rolled over. By looking at one line you are always missing what is happening at adjacent timescales — and those are precisely where the early signals live.

Momentum Pulse works differently.
Instead of one RSI it runs twenty simultaneously, each at a different lookback period. The shortest strand captures the fastest momentum shifts. The longest strand reflects the slower, sustained trend. Together they form a ribbon — a fluid, living visualization of where momentum is coming from, where it is heading, and how much agreement exists across timescales.
The ribbon does not just show direction. It shows compression and expansion. When the strands fan out, momentum is building with conviction. When they compress, the market is coiling — and that compression often precedes the next directional move. When the fast strands lead the slow strands, the trend has energy behind it. When they cross or collapse toward each other, momentum is fading before it is visible in price.
This is momentum before the move.

Important notice
Momentum Pulse is provided for analytical and educational purposes only.
It does not generate trading signals.
It does not predict market direction.
It does not guarantee any outcome.
All trading decisions remain entirely with the user.
Always apply your own judgment and manage your own risk.

1. Overview
Momentum Pulse is a twenty-strand RSI ribbon oscillator built on RSI processed through zero lag EMA smoothing. It maps momentum across twenty simultaneous lookback periods and visualizes the full structure of momentum strength, direction, compression, and divergence in a single pane.
What it includes:
- Twenty RSI strands normalized to a −50 to +50 scale around a zero midline
- Zero lag EMA smoothing applied per strand to reduce response lag
- Fast and slow group averaging with spread-based trend detection
- Twist/Squeeze detection when fast and slow groups compress below the threshold
- Momentum histogram showing the distance between fast and slow group averages
- Ribbon slope line showing the rate of change of the fast group average
- Divergence detection comparing price pivots with fast group momentum pivots
- Three presets: default for swing, fast for scalping, smooth for position trading
- Live dashboard showing momentum state, averages, spread, twist, zone, slope, and divergence
- Six alert conditions covering state changes, compression, and divergence events

2. Core components
2.1 RSI strands
Twenty RSI calculations run simultaneously, each at a different lookback period. The first strand uses the base length. Each subsequent strand adds the length step, spreading the ribbon from fast to slow momentum perspectives. All values are normalized to a −50 to +50 scale around a zero midline, making every strand directly comparable regardless of its period.

2.2 Zero lag EMA smoothing
Each RSI strand is smoothed using a zero lag EMA. Standard EMA smoothing introduces lag because it weights recent bars less than current price. ZLEMA compensates by incorporating the momentum of recent change before applying the average — the ribbon reacts to momentum shifts on the current bar, before the move has confirmed on price.

2.3 Fast and slow group trend detection
The ribbon is divided into two groups. The fast group uses strands one through five — the shortest lookback periods. The slow group uses strands sixteen through twenty — the longest. When the fast group average is above the slow group average, momentum is bullish. When it is below, momentum is bearish. When the spread between the two groups falls below the twist threshold, the oscillator enters a Twist/Squeeze state.
This logic is independent of overbought and oversold levels and works reliably in all market conditions.

2.4 Momentum histogram
The histogram plots the distance between the fast and slow group averages near the zero midline. Wide bars indicate strong momentum separation — the trend has conviction. Narrow bars indicate the ribbon is compressing — momentum is fading or transitioning.

2.5 Ribbon slope
The slope line measures the rate of change of the fast group average over a configurable number of bars. A rising slope indicates momentum is accelerating into the trend. A falling slope indicates momentum is decelerating, a possible sign of exhaustion. A flat slope indicates consolidation or a transition that has not committed to a direction.

2.6 Divergence detection
The indicator compares recent price pivots against fast group average pivots over a configurable lookback window. A bullish divergence fires when price makes a lower low but the fast group average holds higher — hidden strength beneath the surface. A bearish divergence fires when price makes a higher high but the fast group average rolls over — hidden weakness. Both conditions trigger a background flash on the pane.

3. Presets
Three preset configurations are available. Selecting a preset overrides the core calculation parameters.
-Default — swing trading on 4H and daily charts
RSI base 10 | ZLEMA 5 | step 2 | twist threshold 1.5
Balanced ribbon for trend following and swing setups across most market conditions.

-Fast — scalping on 1 minute to 15 minute charts
RSI base 7 | ZLEMA 3 | step 2 | twist threshold 1.0
Shorter periods and a tighter twist threshold for early detection of momentum shifts and reversals before they appear in price.

-Smooth — position trading on daily and weekly charts
RSI base 14 | ZLEMA 8 | step 3 | twist threshold 2.5
Wider spread and longer periods. Only high-conviction momentum moves register. Filters out intraday noise.

4. Visual guide
Ribbon fanning upward — bullish momentum expanding across multiple timescales.
Ribbon fanning downward — bearish momentum expanding.
Ribbon compressing toward center — Twist/Squeeze state, potential breakout building.
Grey background shading — active Twist/Squeeze state.
Green background flash — bullish breakout bar, ribbon exiting compression.
Red background flash — bearish breakout bar.
Warm/orange flash — bullish divergence detected.
Red dim flash — bearish divergence detected.
Green circle at oversold — bullish signal condition.
Red circle at overbought — bearish signal condition.

Histogram bars — momentum strength between fast and slow groups. Wide = strong trend. Narrow = compression.
Slope line — acceleration or deceleration of fast group momentum.

5. Dashboard reference
The dashboard provides live readings across all components.
Momentum — current ribbon state: bullish, bearish, or twist.
Fast avg — average of the five fastest strands.
Slow avg — average of the five slowest strands.
Spread — distance between fast and slow group averages.
Twist — whether the ribbon is compressed below the twist threshold.
Zone — whether the ribbon is extended, compressed, or neutral relative to overbought/oversold levels.
Slope — momentum acceleration state: accel, decel, or flat.
Divergence — active bullish divergence, bearish divergence, or none.
Signal — last signal fired.

6. Alerts
Six alert conditions are available:
- Bullish: ribbon flips to bullish state.
- Bearish: ribbon flips to bearish state.
- Twist: ribbon enters Twist/Squeeze compression.
- Bullish divergence: price makes a lower low while momentum holds higher.
- Bearish divergence: price makes a higher high while momentum weakens.
- Any change: fires on any of the above transitions.
All alerts include exchange, ticker, and interval in the message.

7. Settings reference
Calculation parameters
- Source: price input for RSI calculations
- Base length: lookback period for the fastest ribbon strand
- Length step: increment between each subsequent strand
- RSI length: base RSI period for all strand calculations
- ZLEMA length: zero lag EMA smoothing period per strand
- Twist threshold: minimum spread required to declare a trend; below this = Twist/Squeeze
- Divergence lookback: window for comparing price and momentum pivots
- Slope length: bars used to calculate ribbon acceleration
- Preset: default, fast, or smooth

Visualization settings
- Color preset: classic (green/red) or custom
- Bullish, bearish, and twist/squeeze colors
- Min transparency: opacity of the fastest (leading) strand
- Max transparency: opacity of the slowest (lagging) strand

Level settings
- Overbought level: reference line (does not affect trend logic)
- Oversold level: reference line (does not affect trend logic)

Dashboard settings
- Show dashboard
- Dashboard size: tiny, small, or normal

8. How to use
8.1 Lower timeframes (1 minute to 15 minutes)
Use the fast preset. Monitor the ribbon for compression before expansion — Twist/Squeeze states often precede directional moves. A rising slope combined with bullish ribbon expansion confirms momentum is accelerating. A divergence forming while the ribbon is still in compression indicates a directional move is building before it appears in price.
Only take bullish setups when the ribbon is bullish or just exiting a Twist state with a rising slope and no active bearish divergence. Only take bearish setups with the reverse conditions.

8.2 Higher timeframes (1H, 4H, daily)
Use the default preset on 1H and 4H. Use the smooth preset on daily and weekly charts.
A wide, sustained ribbon fan on higher timeframes confirms momentum has conviction. Ribbon compression while price action narrows indicates trend exhaustion — consider reducing exposure and waiting for re-expansion. Divergence on daily charts carries significant weight and should be treated as a major reversal warning.

8.3 Dashboard reading guide
Slope accel + momentum bullish — trend strengthening, momentum building.
Slope decel + momentum bullish — trend weakening, watch for reversal.
Divergence bear + trend bullish — exit warning, confluence fading.
Twist yes + spread narrowing — breakout setup forming, wait for direction.

8.4 Standalone use
Momentum Pulse works as a standalone oscillator for any strategy or existing indicator setup. The ribbon provides directional momentum bias. The divergence detector flags hidden reversals before they appear in price. The slope line shows whether momentum is building or fading. The histogram confirms trend strength between fast and slow groups. No other indicator is required.

9. Disclaimer
This indicator is provided for educational and informational purposes only.
All outputs are based on historical price action calculations and do not guarantee future results.
Trading financial instruments involves significant risk of loss.
Past performance does not indicate future results.
Use at your own discretion.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Anonycryptous

//@version=6
indicator('Momentum Pulse | Anonycryptous', shorttitle='Momentum Pulse', overlay=false, precision=2, max_bars_back=2000)

// ═══════════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════════

var string calc_group = '════════ Calculation Parameters ════════'
var string style_group = '════════ Visualization Settings ════════'
var string level_group = '════════ Level Settings ════════'
var string dash_group = '════════ Dashboard Settings ════════'

tt_preset = 'Pre-built configurations optimized for specific use cases.\n\nDefault: Balanced ribbon for swing trading on 4H and daily charts. RSI base 10, ZLEMA 5.\n\nFast: Shorter periods and tighter twist threshold designed to detect momentum shifts and potential reversals early. Ideal for 1-15m leading confirmation.\n\nSmooth: Wider spread and longer periods for high-conviction momentum reads on daily and weekly charts.'
tt_src = 'Price data used for RSI calculations. Close is standard and recommended for most setups.'
tt_base = 'Lookback period for the fastest (first) ribbon strand. The remaining 19 strands increment from this value using the Length Step. Shorter values produce a more responsive leading strand with earlier signals.'
tt_step = 'Increment added to the base length for each subsequent strand. Larger steps spread the ribbon across a wider range of lookback periods, creating a more pronounced fan effect during trends.'
tt_rsi = 'Base RSI period used for all strand calculations. This is overridden by the preset. Shorter values make the ribbon more reactive to price changes; longer values produce smoother, more deliberate momentum curves.'
tt_zlema = 'Length of the Zero Lag EMA applied to each RSI strand. ZLEMA compensates for inherent EMA lag by adding the momentum of recent change before smoothing, making the ribbon react earlier than standard EMA smoothing.'
tt_twist = 'Minimum spread between the fast group average (strands 1-5) and slow group average (strands 16-20) required to declare a trend. When below this threshold the ribbon is in Twist/Squeeze state.'
tt_divlen = 'Lookback window used for divergence detection. The indicator compares the most recent price pivot with the fastAvg pivot over this many bars. Shorter values detect divergence earlier but may produce more false signals. Longer values are more reliable but react later.'
tt_slope = 'Number of bars used to calculate ribbon slope and acceleration. fastAvg - fastAvg[n] measures how quickly momentum is changing. Lower values react faster; higher values produce smoother slope readings.'
tt_cpreset = 'Classic uses the standard green/red color scheme for visual consistency. Custom allows you to define your own colors.'
tt_bull = 'Color applied to all ribbon strands, fill, histogram, and signals during bullish momentum.'
tt_bear = 'Color applied to all ribbon strands, fill, histogram, and signals during bearish momentum.'
tt_neut = 'Color applied to the background during Twist/Squeeze state. Grey by default to clearly distinguish compression from directional states.'
tt_mint = 'Transparency of the fastest strand. Lower values make the leading edge more prominent.'
tt_maxt = 'Transparency of the slowest strand. Higher values fade the lagging edge, creating depth.'
tt_ob = 'Overbought reference line. Does not affect signal or trend detection logic.'
tt_os = 'Oversold reference line. Does not affect signal or trend detection logic.'
tt_dash = 'Displays a real-time dashboard showing momentum state, averages, spread, twist, zone, slope, and last signal.'
tt_dsize = 'Controls the text size of the dashboard.'

presetConfig = input.string('Default', 'Preset', options=['Default', 'Fast', 'Smooth'], group=calc_group, tooltip=tt_preset)
src = input.source(close, 'Source', group=calc_group, tooltip=tt_src)
baseLen = input.int(10, 'Base Length', minval=2, step=1, group=calc_group, tooltip=tt_base)
lenStep = input.int(2, 'Length Step', minval=1, step=1, group=calc_group, tooltip=tt_step)
rsiLen = input.int(14, 'RSI Length', minval=2, group=calc_group, tooltip=tt_rsi)
zlemaLen = input.int(5, 'ZLEMA Length', minval=2, group=calc_group, tooltip=tt_zlema)
twistThresh = input.float(1.5, 'Twist Threshold', minval=0.1, step=0.1, group=calc_group, tooltip=tt_twist)
divLen = input.int(14, 'Divergence Lookback', minval=5, step=1, group=calc_group, tooltip=tt_divlen)
slopeLen = input.int(3, 'Slope Length', minval=1, step=1, group=calc_group, tooltip=tt_slope)

colorPreset = input.string('Classic', 'Color Preset', options=['Classic', 'Custom'], group=style_group, tooltip=tt_cpreset)
bullColorIn = input.color(#00ffaa, 'Bullish', group=style_group, tooltip=tt_bull)
bearColorIn = input.color(#ff0000, 'Bearish', group=style_group, tooltip=tt_bear)
neutColorIn = input.color(#808080, 'Twist / Squeeze', group=style_group, tooltip=tt_neut)
minTransp = input.int(10, 'Min Transparency', minval=0, maxval=100, group=style_group, tooltip=tt_mint)
maxTransp = input.int(75, 'Max Transparency', minval=0, maxval=100, group=style_group, tooltip=tt_maxt)

obLevel = input.float(70.0, 'Overbought', group=level_group, tooltip=tt_ob)
osLevel = input.float(30.0, 'Oversold', group=level_group, tooltip=tt_os)

showDash = input.bool(true, 'Show Dashboard', group=dash_group, tooltip=tt_dash)
dashSize = input.string('Tiny', 'Dashboard Size', options=['Tiny', 'Small', 'Normal'], group=dash_group, tooltip=tt_dsize)

// ── Preset overrides ─────────────────────────────────────────
p_rsiLen = presetConfig == 'Fast' ? 7 : presetConfig == 'Smooth' ? 21 : rsiLen
p_zLen = presetConfig == 'Fast' ? 3 : presetConfig == 'Smooth' ? 8 : zlemaLen
p_base = presetConfig == 'Fast' ? 7 : presetConfig == 'Smooth' ? 14 : baseLen
p_step = presetConfig == 'Fast' ? 2 : presetConfig == 'Smooth' ? 3 : lenStep
p_twist = presetConfig == 'Fast' ? 1.0 : presetConfig == 'Smooth' ? 2.5 : twistThresh

// ── Colors ───────────────────────────────────────────────────
bullColor = colorPreset == 'Classic' ? #00ff00 : bullColorIn
bearColor = colorPreset == 'Classic' ? #ff0000 : bearColorIn
neutColor = colorPreset == 'Classic' ? #808080 : neutColorIn

// ═══════════════════════════════════════════════════════════
// ZLEMA LAG
// ═══════════════════════════════════════════════════════════

zlag = math.floor((p_zLen - 1) / 2)

// ═══════════════════════════════════════════════════════════
// RSI PER STRAND
// ═══════════════════════════════════════════════════════════

r01 = ta.rsi(src, p_base + p_step * 0)
r02 = ta.rsi(src, p_base + p_step * 1)
r03 = ta.rsi(src, p_base + p_step * 2)
r04 = ta.rsi(src, p_base + p_step * 3)
r05 = ta.rsi(src, p_base + p_step * 4)
r06 = ta.rsi(src, p_base + p_step * 5)
r07 = ta.rsi(src, p_base + p_step * 6)
r08 = ta.rsi(src, p_base + p_step * 7)
r09 = ta.rsi(src, p_base + p_step * 8)
r10 = ta.rsi(src, p_base + p_step * 9)
r11 = ta.rsi(src, p_base + p_step * 10)
r12 = ta.rsi(src, p_base + p_step * 11)
r13 = ta.rsi(src, p_base + p_step * 12)
r14 = ta.rsi(src, p_base + p_step * 13)
r15 = ta.rsi(src, p_base + p_step * 14)
r16 = ta.rsi(src, p_base + p_step * 15)
r17 = ta.rsi(src, p_base + p_step * 16)
r18 = ta.rsi(src, p_base + p_step * 17)
r19 = ta.rsi(src, p_base + p_step * 18)
r20 = ta.rsi(src, p_base + p_step * 19)

// ═══════════════════════════════════════════════════════════
// ZLEMA PER STRAND — shifted to -50/+50
// ═══════════════════════════════════════════════════════════

o01 = ta.ema(r01 + (r01 - r01[zlag]), p_zLen) - 50.0
o02 = ta.ema(r02 + (r02 - r02[zlag]), p_zLen) - 50.0
o03 = ta.ema(r03 + (r03 - r03[zlag]), p_zLen) - 50.0
o04 = ta.ema(r04 + (r04 - r04[zlag]), p_zLen) - 50.0
o05 = ta.ema(r05 + (r05 - r05[zlag]), p_zLen) - 50.0
o06 = ta.ema(r06 + (r06 - r06[zlag]), p_zLen) - 50.0
o07 = ta.ema(r07 + (r07 - r07[zlag]), p_zLen) - 50.0
o08 = ta.ema(r08 + (r08 - r08[zlag]), p_zLen) - 50.0
o09 = ta.ema(r09 + (r09 - r09[zlag]), p_zLen) - 50.0
o10 = ta.ema(r10 + (r10 - r10[zlag]), p_zLen) - 50.0
o11 = ta.ema(r11 + (r11 - r11[zlag]), p_zLen) - 50.0
o12 = ta.ema(r12 + (r12 - r12[zlag]), p_zLen) - 50.0
o13 = ta.ema(r13 + (r13 - r13[zlag]), p_zLen) - 50.0
o14 = ta.ema(r14 + (r14 - r14[zlag]), p_zLen) - 50.0
o15 = ta.ema(r15 + (r15 - r15[zlag]), p_zLen) - 50.0
o16 = ta.ema(r16 + (r16 - r16[zlag]), p_zLen) - 50.0
o17 = ta.ema(r17 + (r17 - r17[zlag]), p_zLen) - 50.0
o18 = ta.ema(r18 + (r18 - r18[zlag]), p_zLen) - 50.0
o19 = ta.ema(r19 + (r19 - r19[zlag]), p_zLen) - 50.0
o20 = ta.ema(r20 + (r20 - r20[zlag]), p_zLen) - 50.0

// ═══════════════════════════════════════════════════════════
// TREND STATE
// ═══════════════════════════════════════════════════════════

fastAvg = (nz(o01) + nz(o02) + nz(o03) + nz(o04) + nz(o05)) / 5
slowAvg = (nz(o16) + nz(o17) + nz(o18) + nz(o19) + nz(o20)) / 5

isTwist = math.abs(fastAvg - slowAvg) < p_twist
isBull = not isTwist and fastAvg > slowAvg
isBear = not isTwist and fastAvg < slowAvg

ribbonColor = isTwist ? neutColor : isBull ? bullColor : bearColor

// ═══════════════════════════════════════════════════════════
// MOMENTUM STRENGTH — fastAvg - slowAvg histogram
// ═══════════════════════════════════════════════════════════

momentum = fastAvg - slowAvg
momColor = isTwist ? color.new(neutColor, 50) : momentum > 0 ? color.new(bullColor, 50) : color.new(bearColor, 50)

// ═══════════════════════════════════════════════════════════
// RIBBON SLOPE — acceleration of fastAvg
// ═══════════════════════════════════════════════════════════

slope = fastAvg - fastAvg[slopeLen]
slopeColor = slope > 0 ? color.new(bullColor, 30) : color.new(bearColor, 30)

// ═══════════════════════════════════════════════════════════
// DIVERGENCE DETECTION
// ═══════════════════════════════════════════════════════════

priceHigh = ta.highest(src, divLen)
priceLow = ta.lowest(src, divLen)
fastHigh = ta.highest(fastAvg, divLen)
fastLow = ta.lowest(fastAvg, divLen)

// Bearish divergence — price higher high, fastAvg lower high
bearDiv = src >= priceHigh and fastAvg < fastHigh and isBull
// Bullish divergence — price lower low, fastAvg higher low
bullDiv = src <= priceLow and fastAvg > fastLow and isBear

// ═══════════════════════════════════════════════════════════
// LEVELS
// ═══════════════════════════════════════════════════════════

obS = obLevel - 50.0
osS = osLevel - 50.0

hline(obS, 'Overbought', color.new(chart.fg_color, 60), linestyle=hline.style_dashed)
hline(osS, 'Oversold', color.new(chart.fg_color, 60), linestyle=hline.style_dashed)
hline(0, 'Midline', color.new(chart.fg_color, 40), linestyle=hline.style_solid, linewidth=1)

// ═══════════════════════════════════════════════════════════
// STRAND COLORS
// ═══════════════════════════════════════════════════════════

c00 = color.new(ribbonColor, minTransp)
c01 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 1 / 19))
c02 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 2 / 19))
c03 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 3 / 19))
c04 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 4 / 19))
c05 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 5 / 19))
c06 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 6 / 19))
c07 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 7 / 19))
c08 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 8 / 19))
c09 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 9 / 19))
c10 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 10 / 19))
c11 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 11 / 19))
c12 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 12 / 19))
c13 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 13 / 19))
c14 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 14 / 19))
c15 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 15 / 19))
c16 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 16 / 19))
c17 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 17 / 19))
c18 = color.new(ribbonColor, minTransp + int((maxTransp - minTransp) * 18 / 19))
c19 = color.new(ribbonColor, maxTransp)

// ═══════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════

p01 = plot(o01, 'S01', c00, linewidth=1)
p02 = plot(o02, 'S02', c01, linewidth=1)
p03 = plot(o03, 'S03', c02, linewidth=1)
p04 = plot(o04, 'S04', c03, linewidth=1)
p05 = plot(o05, 'S05', c04, linewidth=1)
p06 = plot(o06, 'S06', c05, linewidth=1)
p07 = plot(o07, 'S07', c06, linewidth=1)
p08 = plot(o08, 'S08', c07, linewidth=1)
p09 = plot(o09, 'S09', c08, linewidth=1)
p10 = plot(o10, 'S10', c09, linewidth=1)
p11 = plot(o11, 'S11', c10, linewidth=1)
p12 = plot(o12, 'S12', c11, linewidth=1)
p13 = plot(o13, 'S13', c12, linewidth=1)
p14 = plot(o14, 'S14', c13, linewidth=1)
p15 = plot(o15, 'S15', c14, linewidth=1)
p16 = plot(o16, 'S16', c15, linewidth=1)
p17 = plot(o17, 'S17', c16, linewidth=1)
p18 = plot(o18, 'S18', c17, linewidth=1)
p19 = plot(o19, 'S19', c18, linewidth=1)
p20 = plot(o20, 'S20', c19, linewidth=1)

fill(p01, p20, color.new(ribbonColor, 88), title='Ribbon Fill')

// ── Momentum histogram ───────────────────────────────────────
momentumScaled = momentum / math.max(math.abs(ta.highest(momentum, 100)), math.abs(ta.lowest(momentum, 100)), 0.001) * 5.0
plot(momentumScaled, 'Momentum', color=momColor, style=plot.style_histogram, linewidth=2)


// ── Slope line ───────────────────────────────────────────────
plot(slope, 'Slope', color=slopeColor, linewidth=1, style=plot.style_line)

// ═══════════════════════════════════════════════════════════
// BACKGROUNDS
// ═══════════════════════════════════════════════════════════

bgcolor(isTwist ? color.new(neutColor, 88) : na, title='Twist Background')
bgcolor(isBull and not isBull[1] ? color.new(bullColor, 88) : na, title='Bull Flash')
bgcolor(isBear and not isBear[1] ? color.new(bearColor, 88) : na, title='Bear Flash')
bgcolor(bullDiv ? color.new(bullColor, 82) : na, title='Bullish Divergence Flash')
bgcolor(bearDiv ? color.new(bearColor, 82) : na, title='Bearish Divergence Flash')

// ═══════════════════════════════════════════════════════════
// SIGNALS
// ═══════════════════════════════════════════════════════════

bullSignal = isBull and not isBull[1]
bearSignal = isBear and not isBear[1]

plot(bullSignal ? osS : na, 'Bull', color=bullColor, style=plot.style_circles, linewidth=3)
plot(bullSignal ? osS : na, 'BullG', color=color.new(bullColor, 50), style=plot.style_circles, linewidth=5)
plot(bearSignal ? obS : na, 'Bear', color=bearColor, style=plot.style_circles, linewidth=3)
plot(bearSignal ? obS : na, 'BearG', color=color.new(bearColor, 50), style=plot.style_circles, linewidth=5)

// ═══════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════

var table dash = table.new(position.top_right, 2, 10, bgcolor=color.new(#0d1117, 10), border_color=color.new(#30363d, 20), border_width=1, frame_color=color.new(#30363d, 40), frame_width=1)

if showDash
    dSize = dashSize == 'Tiny' ? size.tiny : dashSize == 'Small' ? size.small : size.normal
    colorMuted = color.new(#8b949e, 0)
    colorLabel = color.new(#8b949e, 0)
    colorWhite = color.new(#ffffff, 0)
    colorPanel = color.new(#161b22, 0)
    colorHead = color.new(ribbonColor, 75)

    stateLabel = isTwist ? '◆ TWIST' : isBull ? '▲ BULLISH' : '▼ BEARISH'
    stateCol = isTwist ? neutColor : isBull ? bullColor : bearColor
    fastLabel = str.tostring(math.round(fastAvg, 2))
    slowLabel = str.tostring(math.round(slowAvg, 2))
    spreadLabel = str.tostring(math.round(math.abs(fastAvg - slowAvg), 2))
    twistLabel = isTwist ? 'YES' : 'NO'
    twistCol = isTwist ? neutColor : colorMuted
    obLabel = fastAvg > obS ? '▲ EXTENDED' : fastAvg < osS ? '▼ COMPRESSED' : '— NEUTRAL'
    obCol = fastAvg > obS ? bearColor : fastAvg < osS ? bullColor : colorMuted
    slopeLabel = slope > 1.0 ? '▲ ACCEL' : slope < -1.0 ? '▼ DECEL' : '— FLAT'
    slopeCol = slope > 1.0 ? bullColor : slope < -1.0 ? bearColor : colorMuted
    divLabel = bullDiv ? '▲ BULL DIV' : bearDiv ? '▼ BEAR DIV' : '— NONE'
    divCol = bullDiv ? bullColor : bearDiv ? bearColor : colorMuted
    signalLabel = bullSignal ? '▲ BUY' : bearSignal ? '▼ SELL' : '— NONE'
    signalCol = bullSignal ? bullColor : bearSignal ? bearColor : colorMuted
    presetLabel = presetConfig == 'Fast' ? 'FAST' : presetConfig == 'Smooth' ? 'SMOOTH' : 'DEFAULT'

    table.cell(dash, 0, 0, 'Momentum Pulse', text_color=colorWhite, text_size=dSize, bgcolor=colorHead, text_halign=text.align_left)
    table.cell(dash, 1, 0, presetLabel, text_color=color.new(ribbonColor, 0), text_size=dSize, bgcolor=colorHead, text_halign=text.align_right)
    table.cell(dash, 0, 1, 'Momentum', text_color=colorLabel, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_left)
    table.cell(dash, 1, 1, stateLabel, text_color=stateCol, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_right)
    table.cell(dash, 0, 2, 'Fast Avg', text_color=colorLabel, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_left)
    table.cell(dash, 1, 2, fastLabel, text_color=isBull ? bullColor : isBear ? bearColor : colorMuted, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_right)
    table.cell(dash, 0, 3, 'Slow Avg', text_color=colorLabel, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_left)
    table.cell(dash, 1, 3, slowLabel, text_color=colorMuted, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_right)
    table.cell(dash, 0, 4, 'Spread', text_color=colorLabel, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_left)
    table.cell(dash, 1, 4, spreadLabel, text_color=colorMuted, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_right)
    table.cell(dash, 0, 5, 'Twist', text_color=colorLabel, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_left)
    table.cell(dash, 1, 5, twistLabel, text_color=twistCol, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_right)
    table.cell(dash, 0, 6, 'Zone', text_color=colorLabel, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_left)
    table.cell(dash, 1, 6, obLabel, text_color=obCol, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_right)
    table.cell(dash, 0, 7, 'Slope', text_color=colorLabel, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_left)
    table.cell(dash, 1, 7, slopeLabel, text_color=slopeCol, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_right)
    table.cell(dash, 0, 8, 'Divergence', text_color=colorLabel, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_left)
    table.cell(dash, 1, 8, divLabel, text_color=divCol, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_right)
    table.cell(dash, 0, 9, 'Signal', text_color=colorLabel, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_left)
    table.cell(dash, 1, 9, signalLabel, text_color=signalCol, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_right)

// ═══════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════

alertcondition(bullSignal, title='Bullish', message='Momentum Pulse: BULLISH on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bearSignal, title='Bearish', message='Momentum Pulse: BEARISH on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(isTwist and not isTwist[1], title='Twist', message='Momentum Pulse: TWIST on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bullDiv, title='Bullish Divergence', message='Momentum Pulse: BULLISH DIVERGENCE on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bearDiv, title='Bearish Divergence', message='Momentum Pulse: BEARISH DIVERGENCE on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bullSignal or bearSignal, title='Any Change', message='Momentum Pulse: Momentum shift on {{exchange}}:{{ticker}} - {{interval}}')
````
