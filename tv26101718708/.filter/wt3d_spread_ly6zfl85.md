# WT3D Spread

- url: https://www.tradingview.com/script/Ly6zfL85-WT3D-Spread/
- type: indicator
- pine_id: PUB;47174dd787514142903919433deea72f
- version: 1.0

## Description

WT3D measures momentum on one asset. WT3D Spread measures relative momentum between two — and that's a different signal entirely. Set any second symbol as your reference; the oscillator runs on the spread between the chart and that reference. NVDA/SPY shows when NVDA is outpacing the market. GDX/GLD shows when miners are leading gold. Altcoin/BTC shows when an alt is decoupling. Same WT3D engine, different question.
Watchlist workflow: leg 1 follows the chart, leg 2 stays pinned. Arrow through your list and watch each name update against your fixed reference in succession.
Built on jdehorty's open-source WaveTrend 3D — full credit chain in the description (jdehorty, LazyBear, PineCoders, veryfid). Additions on top: two-symbol spread layer, anchor-lead tracking from the left visible bar, and an optional currency-debasement view using FRED T10YIFR with calendar-time inflation decay (so the math is right on any chart timeframe, not just daily).
Open-source under MPL 2.0. Feedback welcome.

█ TECHNICAL OVERVIEW

WT3D Spread takes a two-symbol spread — either subtract or ratio — and feeds it into the WaveTrend 3D (WT3D) oscillator engine. WT3D operates on tanh-bounded, quadratic-mean-normalised derivatives, which means the absolute scale of the input is irrelevant; only the rate-of-change shape matters. That property makes spreads a natural fit, because pair-trade dynamics, relative outperformance, and cross-asset divergence are all rate-of-change questions on relative price.

This script is not a re-skin of WT3D. The oscillator core is jdehorty's open-source WaveTrend 3D — credited and linked in full at the bottom — but the surrounding machinery is new and addresses problems the original wasn't built to solve.


█ WHAT THIS SCRIPT ADDS ON TOP OF WT3D

1. Two-symbol spread layer

   A second symbol is selectable as an input. The script computes either close1 − close2 (Subtract) or close1 / close2 (Ratio) on the chart's timeframe and routes the resulting series through WT3D's normalisation pipeline as the source. Leg 1 is always the chart symbol and is read directly from `close` rather than through `request.security()` — one fewer security call and no exchange-prefix ambiguity.

   Leg 2 is the reference you're measuring against. Common patterns: a broad-market benchmark (SPY, QQQ) for relative-strength against the market; a sector index ETF (XLK for tech, XLE for energy, XLF for financials, GDX for miners, etc.) for sector-relative strength; a single peer ticker for direct pair comparison; or a macro proxy (DXY, GLD, BTC) for currency or hard-asset framing. Because leg 1 follows the chart automatically, you can pin leg 2 to a fixed reference and arrow through a watchlist to rip through comparisons in sequence — each chart change reruns the spread, the oscillator, and the info table against the new chart ticker.

   Subtract is the right choice when both legs trade at similar absolute prices (FX crosses, sector ETFs in the same band). Ratio is the right choice when prices differ by an order of magnitude (a $30 stock vs a $500 index ETF, or an altcoin vs BTC), and is also the more honest framing for "outperformance" — d(A/B)/dt carries a B term that doesn't cancel under quadratic-mean normalisation, so the signal genuinely responds to relative dynamics rather than to whichever leg happens to have the larger absolute moves.

2. Currency Mode — calendar-time inflation drag

   Optional. When enabled, the info table shows the spread's real (inflation-adjusted) value alongside the nominal value, plus a running purchasing-power drag percentage. Inflation can be pulled live from FRED's T10YIFR series (the bond market's 5-year-5-year forward inflation expectation, used in preference to backward-looking CPI because the indicator is forward-anchored) or set manually for non-USD currencies or scenario testing.

   The decay is calendar-time-based, not bar-based: pp_value at any bar equals (1 − inflation)^(years_since_anchor), with years_since_anchor computed from wall-clock timestamps. This matters because the conventional approach of compounding a daily decay factor per bar over-applies the drag on intraday timeframes (six 4H bars × one daily decay each per session) and under-applies it across weekends (no chart bars form while inflation continues). The calendar-time formulation works identically on 1H, daily, or weekly charts and correctly accounts for weekend and holiday gaps.

   This adjustment is display-only and does not affect oscillator signals.

3. Anchor Lead tracking

   Optional. Locks an anchor bar at the left visible edge on first render and tracks each leg's percentage return from that anchor onward. The info table shows which leg is leading "since anchor," by how many percentage points, and the underlying returns of both legs for context. Useful for separating long-baseline winners from short-term noise — the rolling lead/trend rows above answer "who's winning right now," and the anchor row answers "who's actually won over the period you've been watching."

4. Lead and trend analysis

   Always on. Two rows in the info table summarise the current state of the spread: "Leading" identifies which leg is currently outperforming, measured against a 20-bar SMA of the spread and gated by a volatility-aware tie threshold so noise doesn't flip the label. "Trend" answers whether that lead is expanding, holding, or contracting versus five bars ago. Helps interpret the oscillator at a glance.

5. Info table

   Theme-aware (auto-detects from the chart background, or force Dark/Light). Shows the two legs colour-tinted to match the bullish/bearish oscillator palette, the live spread value, the lead and trend rows, the optional anchor row, and the optional Currency Mode block.


█ READING THE OSCILLATOR

A bearish reading in this script is not a value judgment. It means Leg 2 is currently outperforming Leg 1 — exactly the same information as "Leg 1 is currently underperforming Leg 2," but the colour convention narrates one of those two readings and silences the other. Whether a red oscillator is good news for you depends entirely on which leg you own, are considering rotating into, or are using as a benchmark.

The green/red colour scheme is inherited from absolute-asset analysis, where in jdehorty's original WT3D red = bad makes perfect sense because there is only one asset and one perspective. On a relative-strength indicator the same colours code "which side is currently winning the spread," not "good versus bad." This is the central conceptual difference between WT3D Spread and the original.

Two pieces of the UI exist to keep this explicit. The "Above 0 ▲" and "Below 0 ▼" rows at the top of the info table show, in live tickers, exactly which symbol the convention maps to for your current pair — so the framing stays visible on every glance and you never have to memorise which colour means what. The "Leading" row further down names the actual winner in plain language regardless of the colour shown. If you want to soften the framing visually, the Use Mirror toggle in Signal Settings renders the chart symmetrically, making both perspectives equally weighted.


█ WHEN TO USE WHICH SPREAD MODE

The default is Ratio because it works universally. Stock divided by SPY, altcoin divided by BTC, a sector ETF divided by a broad-market ETF — all are dimensionless, bounded, and read as relative-strength in the conventional way. The oscillator responds to genuine relative dynamics regardless of how differently the two legs are priced.

Use Subtract instead when both legs trade at similar absolute levels and you specifically want the spread in raw price units. EUR/USD vs GBP/USD, two large-caps in the same band, two sector ETFs around the same price — Subtract gives you a clean dollar (or basis-point) reading. With unequally-priced legs, Subtract is misleading: a 2% move on the cheaper leg is dwarfed by a 0.5% move on the more expensive leg, so the oscillator ends up tracking the dominant leg's volatility rather than the actual relative dynamic.


█ WHAT THIS ISN'T

This is a momentum and divergence tool for spreads, not a statistical-arbitrage toolkit. If your workflow requires cointegration testing, residual half-life estimation, rolling hedge-ratio computation, or stationarity diagnostics, this isn't that. Use it for timing relative-strength shifts and spotting divergences within the WT3D framework, applied to a custom spread you've chosen.

Currency Mode is a display feature for showing real-value erosion against an inflation series. It does not feed back into the oscillator, and it makes the most sense when at least one leg of the spread carries fiat-currency exposure (a USD-denominated commodity, a currency index, a real-asset-vs-fiat pair). On a pure equity-vs-equity spread the Real Value row is technically computable but conceptually thin.

Anchor Lead locks to the left visible bar on first render. If you scroll the chart and want to re-anchor, reload the indicator.


█ CREDITS

Built on jdehorty's open-source WaveTrend 3D (WT3D):
https://www.tradingview.com/script/clUzC70G-WaveTrend-3D/

WT3D in turn credits and inherits from:
• LazyBear — original WaveTrend port to Pine (2014)
• PineCoders — colour-gradient framework (the getColorGradientFromSource / getColorGradientFromSteps helpers used throughout)
• veryfid — mirrored-signal cycle analysis and multi-lookback timeframe proxies (the Use Mirror toggle and the Fast/Normal/Slow oscillator structure)

The KernelFunctions library used for the optional kernel overlays is also jdehorty's, imported by reference.

Released under the Mozilla Public License 2.0 — the TradingView default for open-source Pine publications.


█ DISCLAIMER

For analytical and educational use. Past behaviour of any spread, oscillator, or signal carries no guarantee about future behaviour. Do your own due diligence.

## Source Code

````pine
//@version=6
// =============================================================================
// WT3D Spread — comparative-spread oscillator with currency-debasement awareness.
//
// Built on jdehorty's open-source WaveTrend 3D (WT3D):
//   https://www.tradingview.com/script/clUzC70G-WaveTrend-3D/
//
// WT3D in turn credits and inherits from:
//   • LazyBear  — original WaveTrend port to Pine (2014)
//   • PineCoders — colour-gradient framework (getColorGradientFromSource / Steps)
//   • veryfid   — mirrored-signal cycle analysis and multi-lookback timeframe proxies
//
// Additions in this script:
//   • Two-symbol spread (Subtract or Ratio) feeding the WT3D normalisation pipeline
//   • Anchor-Lead tracking from the left visible bar
//   • Currency Mode — calendar-time inflation drag using FRED T10YIFR or a manual rate
//   • Info table covering lead direction, trend, anchor outperformance, and real value
//
// Released under the Mozilla Public License 2.0 (mozilla.org/MPL/2.0/),
// per TradingView's open-source publishing convention.
// =============================================================================
indicator('WT3D Spread', max_lines_count = 500, explicit_plot_zorder = true)
import jdehorty/KernelFunctions/2 as kernels

// =============================================================================
// THEME
// Auto-detects from chart background, or forces a specific palette.
// Controls the info table's internal colors. Oscillator colors below are
// user inputs and aren't auto-swapped — defaults are picked to work on
// both backgrounds, but you can override them however you like.
// =============================================================================
themeMode = input.string('Auto', 'Theme', options = ['Auto', 'Dark', 'Light'],
     group = 'Theme',
     tooltip = 'Auto: chooses dark or light based on your chart background. Dark / Light: forces a specific palette.')

float _bg_lum = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
bool  isLight = themeMode == 'Light' or (themeMode == 'Auto' and _bg_lum > 128)

color UI_HEADER_BG = isLight ? #ECEFF1 : #1C252C
color UI_VALUE_BG  = isLight ? #FFFFFF : #0B1215
color UI_LABEL_TXT = isLight ? #546E7A : #9E9E9E
color UI_VALUE_TXT = isLight ? #263238 : #E0E0E0
color UI_NEUTRAL   = isLight ? #CFD8DC : #37474F
color UI_BORDER    = isLight ? #B0BEC5 : color.gray

// =============================================================================
// SPREAD SOURCE
// Feed a two-symbol spread into WT3D's normalisation pipeline.
// WT3D operates on tanh-bounded, quadratic-mean-normalised derivatives, so the
// absolute scale of the input is irrelevant — only the rate-of-change shape
// matters. That makes spreads a natural fit: pair-trade dynamics, relative
// outperformance, equity-vs-commodity divergence, etc.
//
// Subtract: close1 - close2. Use when both assets trade at similar levels
//           (FX pairs, two ETFs in the same price band).
// Ratio:    close1 / close2.  Use when the two assets trade at very different
//           absolute prices (a $30 stock vs a $500 index ETF, or an altcoin
//           vs BTC). Ratio is also the natural framing for "outperformance"
//           — d(A/B)/dt carries a B term that doesn't cancel under
//           quadratic-mean normalisation, so the signal genuinely responds
//           to relative dynamics rather than to whichever leg happens to
//           have the larger absolute moves.
//
// Leg 1 is always the chart symbol — we use `close` directly rather than a
// request.security() call. That's both faster (one fewer security request)
// and safer (no exchange-prefix ambiguity from syminfo.ticker).
// =============================================================================
string symbol1    = syminfo.ticker
string symbol2    = input.symbol('AMEX:SPY', 'Leg 2', group = 'Spread',
     tooltip = 'The reference you\'re measuring the chart symbol against. Common patterns: a broad-market benchmark (SPY, QQQ) for relative-strength against the market; a sector index ETF (XLK for tech, XLE for energy, XLF for financials, GDX for miners, etc.) for sector-relative strength; a single peer ticker for direct pair comparison; or a macro proxy (DXY, GLD, BTC) for currency or hard-asset framing. Leg 1 is always the chart symbol — change the chart to change leg 1, which lets you arrow through a watchlist with leg 2 pinned and rip through comparisons in sequence.')
string spreadMode = input.string('Ratio', 'Spread Mode', options = ['Ratio', 'Subtract'],
     group = 'Spread',
     tooltip = 'Ratio: leg 1 divided by leg 2. The safer default — works regardless of how differently the two legs are priced, and matches how relative-strength is conventionally read (stock/index, altcoin/BTC, etc.). Subtract: leg 1 minus leg 2. Use when both legs trade at similar absolute prices (FX crosses, two ETFs in the same band) and you want the spread in raw price units.')

float close1 = close
float close2 = request.security(symbol2, timeframe.period, close)
float spread = spreadMode == 'Subtract' ? close1 - close2 : close1 / nz(close2, 1.0)

// =============================================================================
// CURRENCY MODE & ANCHOR LEAD
// Currency Mode adds real-value and currency-drag rows to the info table.
// Anchor Lead tracks cumulative outperformance since the left-visible anchor.
// Both features share the exact same visible-left anchor lock.
// =============================================================================
bool   useCurrencyMode = input.bool(false, 'Enable Currency Mode', group = 'Currency Mode',
     tooltip = 'Show the spread\'s real (inflation-adjusted) value alongside the nominal value. Useful when one leg is a fiat currency (USD, EUR) or a currency index (DXY). Has no effect on the oscillator signals — purely a display. Decay is calendar-time-based, so the result is the same whether you\'re on a 1H, daily, or weekly chart.')
string inflationSource = input.string('FRED T10YIFR (USD)', 'Inflation Source',
     options = ['FRED T10YIFR (USD)', 'Manual Rate'],
     group = 'Currency Mode',
     tooltip = 'T10YIFR is the bond market\'s forecast for US inflation 5–10 years out, pulled live from FRED. For non-USD currencies or scenario testing, switch to Manual Rate.')
float  manualInflation = input.float(2.5, 'Manual Inflation %', minval = 0.0, maxval = 50.0, step = 0.1,
     group = 'Currency Mode',
     tooltip = 'Annual inflation rate to apply when source is set to Manual Rate. Example: 2.5 = 2.5% per year.')

bool   useAnchorLead = input.bool(false, 'Show Anchor Lead', group = 'Anchor Lead',
     tooltip = 'Show which leg has gained more since the anchor bar (the left visible edge), and by how many percentage points. Useful for seeing the long-baseline winner — who has actually outperformed since you started watching. Has no effect on the oscillator signals — purely a display.')

float inf_exp_raw = request.security('FRED:T10YIFR', 'D', close,
     gaps = barmerge.gaps_on, ignore_invalid_symbol = true)
float inf_rate    = inflationSource == 'FRED T10YIFR (USD)' ? math.max(0.0, nz(inf_exp_raw, manualInflation)) : manualInflation

// -----------------------------------------------------------------------------
// Shared anchor lock — captures the bar at the left visible edge on first
// render and freezes from there. Used by both Currency Mode and Anchor Lead.
// -----------------------------------------------------------------------------
var bool  anchor_locked = false
var int   anchor_time   = na
var float anchor_close1 = na
var float anchor_close2 = na

bool is_anchor_bar = (useCurrencyMode or useAnchorLead) and not anchor_locked and time == chart.left_visible_bar_time

if is_anchor_bar
    anchor_time   := time
    anchor_close1 := close1
    anchor_close2 := close2
    anchor_locked := true

// -----------------------------------------------------------------------------
// Calendar-time purchasing-power decay.
//
// The conventional approach — compounding a per-bar daily decay factor across
// chart bars — is wrong on every timeframe except daily. On 4H you get ~6×
// over-drag (six bars per session, one daily factor each). On weekly you get
// under-drag (one bar covers five trading days but only one decay applied).
// And weekend/holiday inflation never accrues because chart bars don't form.
//
// Wall-clock elapsed time avoids all three errors: pp_value at any bar is
// just (1 - inflation)^(years_since_anchor), regardless of how many bars
// have printed in between or what timeframe you're on.
// -----------------------------------------------------------------------------
float ms_per_year        = 365.25 * 24.0 * 60.0 * 60.0 * 1000.0
float years_since_anchor = anchor_locked ? (time - anchor_time) / ms_per_year : na
float pp_value           = useCurrencyMode and anchor_locked ? math.pow(1.0 - inf_rate / 100.0, years_since_anchor) : na

// Currency Mode outputs
float realSpread = useCurrencyMode and anchor_locked ? spread * pp_value : na
float pp_drift   = useCurrencyMode and anchor_locked ? (pp_value - 1.0) * 100.0 : na

// Anchor Lead outputs
float ret1 = useAnchorLead and anchor_locked ? ((close1 - anchor_close1) / anchor_close1) * 100.0 : na
float ret2 = useAnchorLead and anchor_locked ? ((close2 - anchor_close2) / anchor_close2) * 100.0 : na
float anchorGap = useAnchorLead and anchor_locked ? ret1 - ret2 : na

string str_ret1 = str.tostring(ret1, '#.#') + '%'
string str_ret2 = str.tostring(ret2, '#.#') + '%'

string anchorLeaderName = not anchor_locked ? '—' : math.abs(anchorGap) < 1.0 ? 'Tied' : anchorGap > 0 ? symbol1 : symbol2

// Format: (Leader Return vs Laggard Return). If tied, just shows (Leg 1 vs Leg 2).
string retContext = not anchor_locked ? '' : anchorGap > 0 ? '(' + str_ret1 + ' vs ' + str_ret2 + ')' : '(' + str_ret2 + ' vs ' + str_ret1 + ')'

string anchorGapText = not anchor_locked ? 'Awaiting anchor' :
     math.abs(anchorGap) < 1.0 ? '— (' + str_ret1 + ' vs ' + str_ret2 + ')' :
     '+' + str.tostring(math.abs(anchorGap), '#.#') + 'pp ' + retContext

color  anchorLeaderBg   = not anchor_locked or math.abs(anchorGap) < 1.0 ? UI_NEUTRAL : anchorGap > 0 ? color.new(#26A69A, 50) : color.new(#FF5252, 50)

// =============================================================================
// SIGNAL SETTINGS
// The oscillator engine operates on the spread series. Optional EMA / CoG
// smoothing is applied before normalisation if you want to tame chop.
// =============================================================================
useMirror           = input.bool(false,  'Use Mirror',   group = 'Signal Settings',
     tooltip = 'Plots a symmetrical mirror of the oscillator across the zero line. Its original purpose in jdehorty\'s WT3D was visualising cyclic structure — repeated patterns become clearer as wave shapes when mirrored. In the spread context, it also softens the implicit "above-zero = good" framing by making the chart visually symmetric; signals look equally weighted on both sides of zero rather than privileging Leg 1\'s perspective.')
useEma              = input.bool(false,  'Use EMA',      group = 'Signal Settings', inline = 'ema')
emaLength           = input.int(3,       'Length',       group = 'Signal Settings', inline = 'ema',   minval = 1,
     tooltip = 'Bars used to calculate EMA smoothing.')
useCog              = input.bool(false,  '[Advanced] Use CoG', group = 'Signal Settings', inline = 'smoothing',
     tooltip = 'Apply a centre-of-gravity smoothing to the source. More responsive than EMA on choppy data.')
cogLength           = input.int(6,       'Length',       group = 'Signal Settings', inline = 'smoothing', minval = 1,
     tooltip = 'CoG smoothing length.')
oscillatorLookback  = input.int(20,      'Lookback',     group = 'Signal Settings', inline = 'osc',   minval = 2,
     tooltip = 'Bars used for signal smoothing. Scaled internally across the fast / normal / slow oscillators.')
quadraticMeanLength = input.int(50,      '[Advanced] Quad Mean', group = 'Signal Settings', inline = 'osc',   minval = 2,
     tooltip = 'How many bars to use when measuring typical movement size. The signal is normalised against this so the indicator works regardless of the spread\'s absolute scale.')
speedToEmphasize    = input.string('Slow', 'Emphasize',  group = 'Signal Settings', inline = 'emphasis',
     options = ['Slow', 'Normal', 'Fast', 'None'],
     tooltip = 'Which oscillator (fast / normal / slow) to visually highlight.')
emphasisWidth       = input.int(2,       'Width',        group = 'Signal Settings', inline = 'emphasis',
     tooltip = 'Line width of the emphasised oscillator.')
useKernelMA         = input.bool(false,  '[Advanced] Kernel MA', group = 'Signal Settings', inline = 'kernel',
     tooltip = 'Overlay a smoothed kernel estimate of the emphasised oscillator. Helps confirm trend direction.')
useKernelEmphasis   = input.bool(false,  '[Advanced] Kernel Signal', group = 'Signal Settings', inline = 'kernel',
     tooltip = 'Overlay a tighter, more responsive kernel estimate. Useful for spotting shorter-term reversals.')

float src = spread
src := useEma ? ta.ema(src, emaLength) : src
src := useCog ? ta.cog(src, cogLength) : src

// =============================================================================
// OSCILLATOR SETTINGS
// =============================================================================
offset      = input.int(0,    'Separation',   group = 'Oscillators', inline = 'toggleOsc',
     tooltip = 'Separates signal from source by N bars for isolated comparison.')
showOsc     = input.bool(true,'Show Lines',   group = 'Oscillators', inline = 'toggleOsc')
f_length    = input.float(0.75,'Fast Length', group = 'Oscillators', inline = 'fast',   step = 0.05)
f_smoothing = input.float(0.45,'Smoothing',   group = 'Oscillators', inline = 'fast',   step = 0.05)
n_length    = input.float(1.0, 'Norm Length', group = 'Oscillators', inline = 'normal', step = 0.05)
n_smoothing = input.float(1.0, 'Smoothing',   group = 'Oscillators', inline = 'normal', step = 0.05)
s_length    = input.float(1.75,'Slow Length', group = 'Oscillators', inline = 'slow',   step = 0.05)
s_smoothing = input.float(2.5, 'Smoothing',   group = 'Oscillators', inline = 'slow',   step = 0.05)

// =============================================================================
// DIVERGENCE DETECTION
// =============================================================================
divThreshold = input.int(30, 'Divergence Distance', group = 'Divergence Detection', inline = 'divergence', minval = 1,
     tooltip = 'Bars within which a smaller cross qualifies as a divergence trigger.')
sizePercent  = input.int(40, 'Percent Size',        group = 'Divergence Detection', inline = 'divergence',
     tooltip = 'Current wave size relative to previous — smaller wave triggers divergence.')

// =============================================================================
// OVERBOUGHT / OVERSOLD ZONES
// =============================================================================
showObOs         = input.bool(false,  'Show OB/OS',       group = 'Overbought/Oversold Zones', inline = 'zones')
invertObOsColors = input.bool(false,  'Invert Colors',     group = 'Overbought/Oversold Zones', inline = 'zones')
ob1 = input.float( 0.5,  'OB Primary',   group = 'Overbought/Oversold Zones', inline = 'ob', minval = 0,  maxval = 1,  step = 0.05)
ob2 = input.float( 0.75, 'OB Secondary', group = 'Overbought/Oversold Zones', inline = 'ob', minval = 0,  maxval = 1,  step = 0.05)
os1 = input.float(-0.5,  'OS Primary',   group = 'Overbought/Oversold Zones', inline = 'os', minval = -1, maxval = 0,  step = 0.05)
os2 = input.float(-0.75, 'OS Secondary', group = 'Overbought/Oversold Zones', inline = 'os', minval = -1, maxval = 0,  step = 0.05)

// =============================================================================
// TRANSPARENCIES & GRADIENTS
// =============================================================================
areaBackgroundTrans = input.float(128., 'BG Area Trans',  group = 'Transparencies and Gradients', minval = 0., step = 1)
areaForegroundTrans = input.float(64.,  'FG Area Trans',  group = 'Transparencies and Gradients', minval = 0., step = 1)
lineBackgroundTrans = input.float(2.6,  'BG Line Trans',  group = 'Transparencies and Gradients', minval = 0., step = 1)
lineForegroundTrans = input.float(2.,   'FG Line Trans',  group = 'Transparencies and Gradients', minval = 0., step = 1)
customTransparency  = input.int(30,     'Custom Trans',   group = 'Transparencies and Gradients', minval = 0, maxval = 100, step = 5)
maxStepsForGradient = input.int(8,      'Gradient Steps', group = 'Transparencies and Gradients', minval = 2, maxval = 256)

// =============================================================================
// COLORS
// Defaults are picked to have contrast on both dark and light chart backgrounds.
// You can override any of them; user-set values are saved per chart.
// =============================================================================
var color fastBullishColor   = input.color(#26A69A,            'Fast ▲',      group = 'Colors', inline = 'fast',
     tooltip = '▲ colours apply when the oscillator is above zero (Leg 1 outperforming Leg 2). ▼ colours apply when below zero (Leg 2 outperforming Leg 1). The green/red convention is inherited from absolute-asset analysis; on a spread it codes "which side is currently winning," not "good versus bad."')
var color normalBullishColor = input.color(#26A69ABE,          'Norm ▲',      group = 'Colors', inline = 'normal')
var color slowBullishColor   = input.color(#26A69A80,          'Slow ▲',      group = 'Colors', inline = 'slow')
var color fastBearishColor   = input.color(#ff2f00,            'Fast ▼',      group = 'Colors', inline = 'fast')
var color normalBearishColor = input.color(#fa3003c0,          'Norm ▼',      group = 'Colors', inline = 'normal')
var color slowBearishColor   = input.color(#ff310380,          'Slow ▼',      group = 'Colors', inline = 'slow')
var color c_bullish          = input.color(#26A69A,            'Signal ▲',    group = 'Colors', inline = 'divergence')
var color c_bearish          = input.color(color.rgb(253,50,4),'Signal ▼',    group = 'Colors', inline = 'divergence')
var color emphasisColor      = input.color(#00ff2a,            'Emphasis Line', group = 'Colors')

lineBackgroundTrans := lineBackgroundTrans * customTransparency
areaBackgroundTrans := areaBackgroundTrans * customTransparency
lineForegroundTrans := lineForegroundTrans * customTransparency
areaForegroundTrans := areaForegroundTrans * customTransparency

areaFastTrans   = areaBackgroundTrans
lineFastTrans   = lineBackgroundTrans
areaNormalTrans = areaBackgroundTrans
lineNormalTrans = lineBackgroundTrans
areaSlowTrans   = areaForegroundTrans
lineSlowTrans   = lineForegroundTrans

switch speedToEmphasize
    'Slow'   =>
        areaSlowTrans   := areaForegroundTrans
        lineSlowTrans   := lineForegroundTrans
    'Normal' =>
        areaNormalTrans := areaForegroundTrans
        lineNormalTrans := lineForegroundTrans
    'Fast'   =>
        areaFastTrans   := areaForegroundTrans
        lineFastTrans   := lineForegroundTrans

// =============================================================================
// COLOR HELPER FUNCTIONS
// Originally from PineCoders' colour-gradient framework (see WT3D credits).
// =============================================================================
getPlotColor(signal, bullColor, bearColor) =>
    signal >= 0.0 ? bullColor : bearColor

getColorGradientFromSteps(_source, _center, _steps, weakColor, strongColor) =>
    var float _qtyAdvDec = 0.
    var float _maxSteps  = math.max(1, _steps)
    bool  _xUp    = ta.crossover(_source, _center)
    bool  _xDn    = ta.crossunder(_source, _center)
    float _chg    = ta.change(_source)
    bool  _up     = _chg > 0
    bool  _dn     = _chg < 0
    bool  _srcBull = _source > _center
    bool  _srcBear = _source < _center
    _qtyAdvDec   := _srcBull ? _xUp ? 1 : _up ? math.min(_maxSteps, _qtyAdvDec + 1) : _dn ? math.max(1, _qtyAdvDec - 1) : _qtyAdvDec
                  : _srcBear ? _xDn ? 1 : _dn ? math.min(_maxSteps, _qtyAdvDec + 1) : _up ? math.max(1, _qtyAdvDec - 1) : _qtyAdvDec
                  : _qtyAdvDec
    color.from_gradient(_qtyAdvDec, 1, _maxSteps, weakColor, strongColor)

getColorGradientFromSource(series, _min, _max, weakColor, strongColor) =>
    var float mid = _min + (_max - _min) / 2
    series >= mid ? color.from_gradient(series, mid,  _max, weakColor,  strongColor) : color.from_gradient(series, _min, mid,  strongColor, weakColor)

// =============================================================================
// MAIN HELPER FUNCTIONS
// The normalisation pipeline (normalizeDeriv → tanh → dualPoleFilter) is the
// WT3D core, inherited from jdehorty's implementation.
// =============================================================================
normalizeDeriv(_src, _qml) =>
    float deriv = _src - _src[2]
    float qm    = math.sqrt(nz(math.sum(math.pow(deriv, 2), _qml) / _qml))
    deriv / qm

tanh(series float _src) =>
    -1.0 + 2.0 / (1.0 + math.exp(-2.0 * _src))

dualPoleFilter(float _src, float _lookback) =>
    float _omega = -99.0 * math.pi / (70.0 * _lookback)
    float _alpha = math.exp(_omega)
    float _beta  = -math.pow(_alpha, 2)
    float _gamma = math.cos(_omega) * 2.0 * _alpha
    float _delta = 1.0 - _gamma - _beta
    float _avg   = 0.5 * (_src + nz(_src[1], _src))
    float _f     = na
    _f          := _delta * _avg + _gamma * nz(_f[1]) + _beta * nz(_f[2])
    _f

getOscillator(float s, float freq, int qml) =>
    dualPoleFilter(tanh(normalizeDeriv(s, qml)), freq)

// =============================================================================
// OSCILLATOR CALCULATIONS
// =============================================================================
offsetFast         = offset
f_lookback         = f_smoothing * oscillatorLookback
signalFast         = getOscillator(src, f_lookback, quadraticMeanLength)
seriesFast         = f_length * signalFast + offsetFast
seriesFastMirror   = useMirror ? -seriesFast + 2 * offsetFast : na

offsetNormal       = 0
n_lookback         = n_smoothing * oscillatorLookback
signalNormal       = getOscillator(src, n_lookback, quadraticMeanLength)
seriesNormal       = n_length * signalNormal + offsetNormal
seriesNormalMirror = useMirror ? -seriesNormal + 2 * offsetNormal : na

offsetSlow         = -offset
s_lookback         = s_smoothing * oscillatorLookback
signalSlow         = getOscillator(src, s_lookback, quadraticMeanLength)
seriesSlow         = s_length * signalSlow + offsetSlow
seriesSlowMirror   = useMirror ? -seriesSlow + 2 * offsetSlow : na

// =============================================================================
// COLOR GRADIENT CALCULATIONS
// =============================================================================
fastBaseColor     = getPlotColor(signalFast,   fastBullishColor,   fastBearishColor)
fastBaseInverse   = getPlotColor(signalFast,   fastBearishColor,   fastBullishColor)
normalBaseColor   = getPlotColor(signalNormal, normalBullishColor, normalBearishColor)
normalBaseInverse = getPlotColor(signalNormal, normalBearishColor, normalBullishColor)
slowBaseColor     = getPlotColor(signalSlow,   slowBullishColor,   slowBearishColor)
slowBaseInverse   = getPlotColor(signalSlow,   slowBearishColor,   slowBullishColor)

fastAreaGradientFromSource      = getColorGradientFromSource(seriesFast,   -1.   + offsetFast,   1.   + offsetFast,   color.new(fastBaseColor,   areaFastTrans),   fastBaseColor)
fastAreaGradientFromSteps       = getColorGradientFromSteps( seriesFast,          offsetFast,   maxStepsForGradient,   color.new(fastBaseColor,   areaFastTrans),   fastBaseColor)
fastLineGradientFromSource      = getColorGradientFromSource(seriesFast,   -1.   + offsetFast,   1.   + offsetFast,   color.new(fastBaseColor,   lineFastTrans),   fastBaseColor)
fastLineGradientFromSteps       = getColorGradientFromSteps( seriesFast,          offsetFast,   maxStepsForGradient,   color.new(fastBaseColor,   lineFastTrans),   fastBaseColor)
fastAreaGradientFromStepsInverse= getColorGradientFromSteps( seriesFast,          offsetFast,   maxStepsForGradient,   color.new(fastBaseInverse, areaFastTrans),   fastBaseInverse)

normalAreaGradientFromSource      = getColorGradientFromSource(seriesNormal, -1.   + offsetNormal, 1.   + offsetNormal, color.new(normalBaseColor,   areaNormalTrans), normalBaseColor)
normalAreaGradientFromSteps       = getColorGradientFromSteps( seriesNormal,        offsetNormal, maxStepsForGradient,   color.new(normalBaseColor,   areaNormalTrans), normalBaseColor)
normalLineGradientFromSource      = getColorGradientFromSource(seriesNormal, -1.   + offsetNormal, 1.   + offsetNormal, color.new(normalBaseColor,   lineNormalTrans), normalBaseColor)
normalLineGradientFromSteps       = getColorGradientFromSteps( seriesNormal,        offsetNormal, maxStepsForGradient,   color.new(normalBaseColor,   lineNormalTrans), normalBaseColor)
normalAreaGradientFromStepsInverse= getColorGradientFromSteps( seriesNormal,        offsetNormal, maxStepsForGradient,   color.new(normalBaseInverse, areaNormalTrans), normalBaseInverse)

slowAreaGradientFromSource  = getColorGradientFromSource(seriesSlow, -1.75 + offsetSlow, 1.75 + offsetSlow, color.new(slowBaseColor, areaSlowTrans), slowBaseColor)
slowAreaGradientFromSteps   = getColorGradientFromSteps( seriesSlow,        offsetSlow, maxStepsForGradient, color.new(slowBaseColor, areaSlowTrans), slowBaseColor)
slowLineGradientFromSource  = getColorGradientFromSource(seriesSlow, -1.75 + offsetSlow, 1.75 + offsetSlow, color.new(slowBaseColor, lineSlowTrans), slowBaseColor)
slowLineGradientFromSteps   = getColorGradientFromSteps( seriesSlow,        offsetSlow, maxStepsForGradient, color.new(slowBaseColor, lineSlowTrans), slowBaseColor)

// =============================================================================
// PLOT PARAMETERS & LOGIC GATES
// =============================================================================
isSlow   = speedToEmphasize == 'Slow'
isNormal = speedToEmphasize == 'Normal'
isFast   = speedToEmphasize == 'Fast'

seriesSlowColor         = showOsc or isSlow   ? color.new(slowLineGradientFromSource,   lineSlowTrans)   : na
seriesNormalColor       = showOsc or isNormal ? color.new(normalLineGradientFromSource, lineNormalTrans) : na
seriesFastColor         = showOsc or isFast   ? color.new(fastLineGradientFromSource,   lineFastTrans)   : na
seriesSlowMirrorColor   = useMirror ? seriesSlowColor   : na
seriesNormalMirrorColor = useMirror ? seriesNormalColor : na
seriesFastMirrorColor   = useMirror ? seriesFastColor   : na

seriesSlowWidth         = isSlow   ? emphasisWidth : 1
seriesNormalWidth       = isNormal ? emphasisWidth : 1
seriesFastWidth         = isFast   ? emphasisWidth : 1
seriesSlowMirrorWidth   = useMirror ? seriesSlowWidth   : na
seriesNormalMirrorWidth = useMirror ? seriesNormalWidth : na
seriesFastMirrorWidth   = useMirror ? seriesFastWidth   : na

seriesEmphasis    = switch
    isFast   => seriesFast
    isNormal => seriesNormal
    isSlow   => seriesSlow
    => na

colorLineEmphasis = switch
    isFast   => fastLineGradientFromSource
    isNormal => normalLineGradientFromSource
    isSlow   => slowLineGradientFromSource
    => na

colorAreaEmphasis = switch
    isFast   => fastAreaGradientFromSource
    isNormal => normalAreaGradientFromSource
    isSlow   => slowAreaGradientFromSource
    => na

// =============================================================================
// CROSSOVER SIGNALS
// =============================================================================
bearishCross             = ta.crossunder(seriesFast,   seriesNormal) and seriesNormal > 0
bullishCross             = ta.crossover( seriesFast,   seriesNormal) and seriesNormal < 0
slowBearishMedianCross   = ta.crossunder(seriesSlow,   0)
slowBullishMedianCross   = ta.crossover( seriesSlow,   0)
normalBearishMedianCross = ta.crossunder(seriesNormal, 0)
normalBullishMedianCross = ta.crossover( seriesNormal, 0)
fastBearishMedianCross   = ta.crossunder(seriesFast,   0)
fastBullishMedianCross   = ta.crossover( seriesFast,   0)

lastBearishCrossValue = ta.valuewhen(bearishCross, seriesNormal, 1)
lastBullishCrossValue = ta.valuewhen(bullishCross, seriesNormal, 1)

triggerWaveFactor     = sizePercent / 100
isSmallerBearishCross = bearishCross and seriesNormal < lastBearishCrossValue * triggerWaveFactor
isSmallerBullishCross = bullishCross and seriesNormal > lastBullishCrossValue * triggerWaveFactor

// =============================================================================
// KERNEL ESTIMATORS
// =============================================================================
yhat0 = kernels.gaussian(seriesEmphasis, 6, 6)
yhat1 = kernels.gaussian(seriesEmphasis, 3, 2)

isBearishKernelTrend = yhat0 < seriesSlow
isBullishKernelTrend = yhat0 > seriesSlow

p  = plot(seriesEmphasis,                  'Series Emphasis',          color = emphasisColor)
p0 = plot(useKernelMA      ? yhat0 : na,   'Kernel Estimate — Trend',  color = colorLineEmphasis)
p1 = plot(useKernelEmphasis ? yhat1 : na,  'Kernel Estimate — Signal', color = colorLineEmphasis)
fill(p, p0, color = fastLineGradientFromSource)
fill(p, p1, color = fastLineGradientFromSource)

isBearishDivZone     = ta.barssince(bearishCross[1]) < divThreshold
isBullishDivZone     = ta.barssince(bullishCross[1]) < divThreshold
isBearishTriggerWave = isSmallerBearishCross and isBearishDivZone and isBearishKernelTrend
isBullishTriggerWave = isSmallerBullishCross and isBullishDivZone and isBullishKernelTrend

// =============================================================================
// PLOTS & FILLS
// =============================================================================
obPlot1 = plot(ob1, 'OB Primary',   color = na)
obPlot2 = plot(ob2, 'OB Secondary', color = na)
osPlot1 = plot(os1, 'OS Primary',   color = na)
osPlot2 = plot(os2, 'OS Secondary', color = na)
fill(obPlot1, obPlot2, offset == 0 and showObOs ? invertObOsColors ? normalAreaGradientFromStepsInverse : normalAreaGradientFromSteps : na)
fill(osPlot1, osPlot2, offset == 0 and showObOs ? invertObOsColors ? normalAreaGradientFromStepsInverse : normalAreaGradientFromSteps : na)

slowOscPlot         = plot(seriesSlow,         'Slow Oscillator',        color = seriesSlowColor,         linewidth = math.max(1, seriesSlowWidth))
slowOscPlotMirror   = plot(seriesSlowMirror,   'Slow Oscillator Mirror', color = seriesSlowMirrorColor,   linewidth = math.max(1, seriesSlowMirrorWidth))
baseLineSlow        = plot(offsetSlow,         'Baseline Slow',          slowLineGradientFromSteps,        style = plot.style_line, linewidth = 1)
fill(baseLineSlow, slowOscPlot,       slowAreaGradientFromSource)
fill(baseLineSlow, slowOscPlotMirror, slowAreaGradientFromSource)

normalOscPlot       = plot(seriesNormal,       'Normal Oscillator',        color = seriesNormalColor,       linewidth = math.max(1, seriesNormalWidth))
normalOscPlotMirror = plot(seriesNormalMirror, 'Normal Oscillator Mirror', color = seriesNormalMirrorColor, linewidth = math.max(1, seriesNormalMirrorWidth))
baseLineNormal      = plot(offsetNormal,       'Baseline Normal',          normalLineGradientFromSteps,      style = plot.style_line, linewidth = 1)
fill(baseLineNormal, normalOscPlot,       normalAreaGradientFromSource)
fill(baseLineNormal, normalOscPlotMirror, normalAreaGradientFromSource)

fastOscPlot         = plot(seriesFast,         'Fast Oscillator',        color = seriesFastColor,         linewidth = math.max(1, seriesFastWidth))
fastOscPlotMirror   = plot(seriesFastMirror,   'Fast Oscillator Mirror', color = seriesFastMirrorColor,   linewidth = math.max(1, seriesFastMirrorWidth))
baseLineFast        = plot(offsetFast,          'Baseline Fast',          fastLineGradientFromSteps,        style = plot.style_line, linewidth = 1)
fill(baseLineFast, fastOscPlot,       fastAreaGradientFromSource)
fill(baseLineFast, fastOscPlotMirror, fastAreaGradientFromSource)

plot(bearishCross         ? useMirror ? 0 : seriesNormal : na, 'Bearish Cross',         style = plot.style_circles, linewidth = 1, color = c_bearish, offset = -1)
plot(isBearishTriggerWave ? useMirror ? 0 : seriesNormal : na, 'Bearish Trigger Cross', style = plot.style_circles, linewidth = 3, color = c_bearish, offset = -1)
plot(bullishCross         ? useMirror ? 0 : seriesNormal : na, 'Bullish Cross',         style = plot.style_circles, linewidth = 1, color = c_bullish, offset = -1)
plot(isBullishTriggerWave ? useMirror ? 0 : seriesNormal : na, 'Bullish Trigger Cross', style = plot.style_circles, linewidth = 3, color = c_bullish, offset = -1)

// =============================================================================
// ALERTS
// =============================================================================
alertcondition(bearishCross,             'Bearish Cross',               'WT3D Spread: {{ticker}} ({{interval}}) Bearish Cross ▼ [{{close}}]')
alertcondition(bullishCross,             'Bullish Cross',               'WT3D Spread: {{ticker}} ({{interval}}) Bullish Cross ▲ [{{close}}]')
alertcondition(isBearishTriggerWave,     'Bearish Divergence',          'WT3D Spread: {{ticker}} ({{interval}}) Bearish Divergence ▼ [{{close}}]')
alertcondition(isBullishTriggerWave,     'Bullish Divergence',          'WT3D Spread: {{ticker}} ({{interval}}) Bullish Divergence ▲ [{{close}}]')
alertcondition(slowBearishMedianCross,   'Slow Bearish Median Cross',   'WT3D Spread: {{ticker}} ({{interval}}) Slow Bearish Median Cross ▼ [{{close}}]')
alertcondition(slowBullishMedianCross,   'Slow Bullish Median Cross',   'WT3D Spread: {{ticker}} ({{interval}}) Slow Bullish Median Cross ▲ [{{close}}]')
alertcondition(normalBearishMedianCross, 'Normal Bearish Median Cross', 'WT3D Spread: {{ticker}} ({{interval}}) Normal Bearish Median Cross ▼ [{{close}}]')
alertcondition(normalBullishMedianCross, 'Normal Bullish Median Cross', 'WT3D Spread: {{ticker}} ({{interval}}) Normal Bullish Median Cross ▲ [{{close}}]')
alertcondition(fastBearishMedianCross,   'Fast Bearish Median Cross',   'WT3D Spread: {{ticker}} ({{interval}}) Fast Bearish Median Cross ▼ [{{close}}]')
alertcondition(fastBullishMedianCross,   'Fast Bullish Median Cross',   'WT3D Spread: {{ticker}} ({{interval}}) Fast Bullish Median Cross ▲ [{{close}}]')

// =============================================================================
// BACKTESTING STREAM
// =============================================================================
condition = switch
    bearishCross             => 1
    bullishCross             => 2
    isBearishTriggerWave     => 3
    isBullishTriggerWave     => 4
    slowBearishMedianCross   => 5
    slowBullishMedianCross   => 6
    normalBearishMedianCross => 7
    normalBullishMedianCross => 8
    fastBearishMedianCross   => 9
    fastBullishMedianCross   => 10

plot(condition, 'Alert Stream', display = display.none)

// =============================================================================
// LEAD ANALYSIS
// Who's currently winning the spread, and is that lead widening or shrinking?
// Spread up → leg 1 outperforming. Spread down → leg 2 outperforming.
// =============================================================================
int   leadLookback = 20
float spreadRef    = ta.sma(spread, leadLookback)
float lead         = spread - spreadRef
float leadPrev     = nz(lead[5], 0.0)
float leadDelta    = lead - leadPrev
float leadScale    = nz(ta.stdev(spread, leadLookback), 0.0)
float tiedThresh   = leadScale * 0.10
float holdThresh   = leadScale * 0.05

bool   ready       = bar_index > leadLookback + 5 and leadScale > 0.0
bool   tied        = ready and math.abs(lead) < tiedThresh
bool   leg1Lead    = ready and not tied and lead > 0
bool   leg2Lead    = ready and not tied and lead < 0
bool   holding     = ready and math.abs(leadDelta) < holdThresh
bool   expanding   = ready and not holding and lead * leadDelta > 0
bool   contracting = ready and not holding and lead * leadDelta < 0

string leaderName  = not ready ? '—' : tied ? 'Tied' : leg1Lead ? symbol1 + ' ▲' : symbol2 + ' ▲'
string trendName   = not ready ? '—' : tied ? 'Forming' : holding ? 'Holding →' : expanding ? 'Expanding ▲' : 'Contracting ▼'

color  leg1Tint    = color.new(#26A69A, 80)
color  leg2Tint    = color.new(#FF5252, 80)
color  leaderBg    = not ready or tied ? UI_NEUTRAL : leg1Lead ? color.new(#26A69A, 50) : color.new(#FF5252, 50)
color  trendBg     = not ready or tied or holding ? UI_NEUTRAL : expanding ? color.new(#26A69A, 50) : color.new(#FF9800, 50)

// =============================================================================
// INFO TABLE
// Base 8 rows always shown (Title, Column Headers, 3 Core lines, 1 Section Divider, 2 Analytics);
// +1 when Anchor Lead ("Since Anchor") is enabled;
// +4 when Currency Mode is enabled (1 Section Divider + 3 Metrics).
// =============================================================================
int tableRows = 8
if useAnchorLead
    tableRows += 1
if useCurrencyMode
    tableRows += 4

var table t = table.new(position.top_right, 2, tableRows, border_width = 1, border_color = UI_BORDER)

if barstate.islast
    int currentRow = 0

    // 1. MAIN TABLE HEADER
    table.cell(t, 0, currentRow, '\nWT3D SPREAD ANALYSIS', bgcolor = UI_HEADER_BG, text_color = UI_VALUE_TXT, text_size = size.normal)
    table.merge_cells(t, 0, currentRow, 1, currentRow)
    currentRow += 1

    // 2. COLUMN HEADERS
    table.cell(t, 0, currentRow, 'Field',   bgcolor = UI_HEADER_BG, text_color = UI_LABEL_TXT, text_size = size.small)
    table.cell(t, 1, currentRow, 'Value',   bgcolor = UI_HEADER_BG, text_color = UI_LABEL_TXT, text_size = size.small)
    currentRow += 1

    // 3. DIRECTION KEY + CORE SPREAD DATA
    // Direction-key rows replace the conventional Leg 1 / Leg 2 labels with
    // explicit "above 0 = this symbol winning" / "below 0 = that symbol winning"
    // framing. This neutralises the cognitive bias where red below zero reads
    // as "bad" when it actually means "Leg 2 is outperforming Leg 1" — exactly
    // equivalent information, just framed from the other side.
    table.cell(t, 0, currentRow, 'Above 0 ▲',   bgcolor = UI_HEADER_BG, text_color = UI_LABEL_TXT, text_size = size.small,
         tooltip = 'When the oscillator is above zero, this symbol is outperforming the other. Teal tint matches the bullish oscillator colour.')
    table.cell(t, 1, currentRow, symbol1,   bgcolor = leg1Tint,     text_color = UI_VALUE_TXT, text_size = size.small)
    currentRow += 1

    table.cell(t, 0, currentRow, 'Below 0 ▼',   bgcolor = UI_HEADER_BG, text_color = UI_LABEL_TXT, text_size = size.small,
         tooltip = 'When the oscillator is below zero, this symbol is outperforming the other. The red tint matches the bearish oscillator colour, but a "bearish" reading is not a value judgment — it just means this leg is currently winning the spread.')
    table.cell(t, 1, currentRow, symbol2,   bgcolor = leg2Tint,     text_color = UI_VALUE_TXT, text_size = size.small)
    currentRow += 1

    table.cell(t, 0, currentRow, spreadMode == 'Subtract' ? 'L1 − L2' : 'L1 / L2',
         bgcolor = UI_HEADER_BG, text_color = UI_LABEL_TXT, text_size = size.small,
         tooltip = 'The current spread value. The oscillator responds to how this changes, not the absolute number.')
    table.cell(t, 1, currentRow, str.tostring(nz(spread, 0.0), '#.####'),
         bgcolor = UI_VALUE_BG, text_color = UI_VALUE_TXT, text_size = size.small)
    currentRow += 1

    // 4. PERFORMANCE ANALYSIS SECTION HEADER
    table.cell(t, 0, currentRow, 'Performance Analysis', bgcolor = UI_HEADER_BG, text_color = UI_VALUE_TXT, text_size = size.normal)
    table.merge_cells(t, 0, currentRow, 1, currentRow)
    currentRow += 1

    // 5. ROLLING PERFORMANCE METRICS
    table.cell(t, 0, currentRow, 'Leading', bgcolor = UI_HEADER_BG, text_color = UI_LABEL_TXT, text_size = size.small,
         tooltip = 'Which leg is currently ahead, measured against the 20-bar average of the spread. "Tied" means the lead is small relative to recent volatility.')
    table.cell(t, 1, currentRow, leaderName, bgcolor = leaderBg, text_color = UI_VALUE_TXT, text_size = size.small)
    currentRow += 1

    table.cell(t, 0, currentRow, 'Trend',   bgcolor = UI_HEADER_BG, text_color = UI_LABEL_TXT, text_size = size.small,
         tooltip = 'Is the current lead widening or shrinking, compared to 5 bars ago? Expanding = winner gaining more. Contracting = winner losing ground. Holding = stable.')
    table.cell(t, 1, currentRow, trendName, bgcolor = trendBg, text_color = UI_VALUE_TXT, text_size = size.small)
    currentRow += 1

    // 6. LONG-BASELINE OPT-IN (SINCE ANCHOR)
    if useAnchorLead
        table.cell(t, 0, currentRow, 'Since Anchor', bgcolor = UI_HEADER_BG, text_color = UI_LABEL_TXT, text_size = size.small,
             tooltip = 'Which leg has outperformed since the anchor point (left visible edge), showing raw percentage points gap alongside relative baseline changes.')
        table.cell(t, 1, currentRow, anchorLeaderName != '—' ? anchorLeaderName + ' ' + anchorGapText : anchorGapText,
             bgcolor = anchorLeaderBg, text_color = UI_VALUE_TXT, text_size = size.small)
        currentRow += 1

    // 7. MACRO DECAY OPT-IN (REAL VALUE ANALYSIS)
    if useCurrencyMode
        color c_drift = na(pp_drift) ? UI_HEADER_BG : pp_drift < -3.0 ? color.new(#FF5252, 20) : pp_drift < -1.0 ? color.new(#FF9800, 20) : color.new(UI_NEUTRAL, 20)

        table.cell(t, 0, currentRow, 'Real Value Analysis', bgcolor = UI_HEADER_BG, text_color = UI_VALUE_TXT, text_size = size.normal)
        table.merge_cells(t, 0, currentRow, 1, currentRow)
        currentRow += 1

        table.cell(t, 0, currentRow, 'Real Value', bgcolor = UI_HEADER_BG, text_color = UI_LABEL_TXT, text_size = size.small,
             tooltip = 'The current spread expressed in the buying power of money on the anchor bar. If a dollar today buys less than at the anchor, real value will be lower than nominal. Does not affect the oscillator signals.')
        table.cell(t, 1, currentRow, na(realSpread) ? 'Awaiting anchor' : str.tostring(realSpread, '#.####'),
             bgcolor = UI_VALUE_BG, text_color = UI_VALUE_TXT, text_size = size.small)
        currentRow += 1

        table.cell(t, 0, currentRow, 'Currency Drag', bgcolor = UI_HEADER_BG, text_color = UI_LABEL_TXT, text_size = size.small,
             tooltip = 'How much buying power has been lost since the anchor bar, as a percent. Amber after −1%, red after −3%.')
        table.cell(t, 1, currentRow, na(pp_drift) ? '—' : str.tostring(pp_drift, '#.##') + '%',
             bgcolor = c_drift, text_color = UI_VALUE_TXT, text_size = size.small)
        currentRow += 1

        table.cell(t, 0, currentRow, 'Inflation', bgcolor = UI_HEADER_BG, text_color = UI_LABEL_TXT, text_size = size.small,
             tooltip = 'The annual inflation rate currently being applied to the buying-power decay.')
        table.cell(t, 1, currentRow, str.tostring(inf_rate, '#.##') + '%' + (inflationSource == 'FRED T10YIFR (USD)' ? ' (T10YIFR)' : ' (manual)'),
             bgcolor = UI_VALUE_BG, text_color = UI_VALUE_TXT, text_size = size.small)
````
