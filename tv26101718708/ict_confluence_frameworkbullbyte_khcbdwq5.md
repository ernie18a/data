# ICT Confluence Framework[BullByte]

- url: https://www.tradingview.com/script/kHCBdWq5-ICT-Confluence-Framework-BullByte/
- type: indicator
- pine_id: PUB;4f2794f97aab45579105d19d877379f9
- version: 1.0

## Description

[b]ICT Confluence Framework[/b] is a structural price-action engine that monitors the chart for [b]five independent ICT-style behaviors [/b]and fires a directional setup only when several of them align inside a short structural window. Designed for intraday traders on 1m–15m charts in crypto, indices, and futures, with an auto-adapter that rescales every meaningful lookback to the chart timeframe.

Most ICT tools draw one element - order blocks, liquidity pools, BOS lines - and leave the trader to combine them mentally. This framework does the combining, scores the result against the current market regime and volatility phase, and prints one clean setup with an Entry, two Reference Levels, and an Invalidation level. The chart stays focused on what is currently relevant - no permanent boxes, no arrows on every candle, no flashing icons.

[b]WHY THIS IS NOT A MASHUP[/b]

No public indicator is imported, wrapped, or re-skinned. Every detector is written from first principles against raw OHLCV. The five detectors share four custom layers that no single public indicator provides:

- A common confluence scoring layer with adaptive per-pattern weighting
- A regime classifier based on path efficiency
- A volatility-phase filter based on rolling ATR percentile rank
- A signal lifecycle manager with deterministic outcome resolution

The originality is in how five orthogonal behaviors are unified into one decision - not in the behaviors themselves.

[b]THE FIVE BEHAVIORS MONITORED[/b]

[b]1. Liquidity Sweep + Reclaim[/b]
Price violates a recent swing extreme - taking out resting stops - then closes back inside the prior range within a short window. The classic stop-hunt-then-reverse footprint.

[b]2. Stopping Volume[/b]
A high-volume bar at a local extreme that closes with a strong rejection wick. Marks a level where aggressive flow was absorbed by passive flow.

[b]3. Range Compression to Expansion[/b]
A bar that is the narrowest of its recent window is immediately followed by an expansion bar of meaningful size. A bullish expansion contributes to a bullish setup; a bearish expansion to a bearish one.

[b]4. Break of Structure (BOS)[/b]
A close beyond the last confirmed pivot high or low. The script uses 3-bar right-confirmed pivots, so BOS prints with structural lag by design - this removes false breaks.

[b]5. Order Block Mitigation[/b]
Price returns to the last opposing candle preceding a strong impulse, wicks into it, and closes back outside the zone.

Each behavior is detected independently against raw price and volume.

[b]WHY THESE FIVE[/b]

At structural turning points markets do a small number of distinct things: they trap traders (sweep), they absorb flow (stopping volume), they release energy (compression-expansion), they confirm intent (BOS), and they retest origin (order block). When two or more of these align within the same structural window on the same side, the setup quality is materially higher than any one of them in isolation.

[b]WHAT MAKES THIS DIFFERENT[/b]

[b]Signals are stable.[/b] Detection and signal arming occur only on confirmed bar close. Once a setup prints, it does not move, redraw, or vanish on the next tick.

[b]The script adapts to your chart.[/b] Every pattern carries a rolling reliability score calculated from its own follow-through history on the instrument and timeframe you are viewing. Follow-through is measured as maximum favorable excursion in ATR multiples over a configurable evaluation window. Patterns that have been working get more weight; patterns that have been failing get less, bounded by a user-set floor so no pattern is fully silenced.

[b]Market regime is respected.[/b] An efficiency ratio (net displacement divided by path length) classifies the market as Trend Up, Trend Down, Range, Volatile, or Neutral. Inside this classification, BOS in a Range is soft-weighted to 0.4x and Expansion in a Volatile regime is soft-weighted to 0.5x. Counter-trend setups inside a strong trend are weighted down to 0.5x but still allowed.

[b]Volatility phase aware.[/b] The current ATR's percentile rank classifies the bar as Quiet, Normal, or Active. Active phase tightens the required pattern count by one (capped at five). Quiet and Normal use the user's setting unchanged.

[b]Confluence decay.[/b] A residual opposing score decays linearly by 1.0 per bar with no fresh pattern activity, so a stale opposing cluster cannot block a fresh signal indefinitely. The decayed value is also reset to zero on trade closure so the post-cooldown chart starts clean.

[b]The chart stays clean.[/b] While no trade is active, the Hunting Layer shows what the script is monitoring. The moment a signal fires, every hunting visual that did not contribute to the signal and is not contextually inside the trade's expected path is erased. Contributors and contextual zones are recolored to the signal's direction and promoted into permanent history.

[b]CHART EXAMPLE
[/b]
[b]1.ETH/USD 15m: Bullish Alignment: Expansion + BOS.[/b] Following a sharp bearish leg into a session low near 08:00, price entered a tight compression range between approximately 10:30 and 12:00. An expansion bar then broke above the last confirmed swing high (the LH pivot at ~11:00), firing the Compression-to-Expansion and Break of Structure detectors simultaneously. The framework printed a Bullish Alignment at 2036.60 with Invalidation at 2022.77. The market has advanced through Reference Level 1 (2050.43) and is approaching Reference Level 2 (2064.27).

[image]https://www.tradingview.com/x/G045NGxq/[/image]

[b]2.ETH/USD 15m: Bullish High-Confluence: Sweep + BOS + OB.[/b] During a Range regime under Active volatility phase (which tightened the confluence requirement to three patterns), price swept the sellside liquidity at approximately 10:30 below a confirmed swing low. After consolidation, the entry bar at approximately 13:30 mitigated a bullish Order Block and broke above the local pivot. Three patterns aligned at signal close, firing a Bullish High-Confluence setup at 2118.34 with Invalidation at 2097.19. The market is currently advancing toward Reference Level 1 (2139.49) and Reference Level 2 (2160.64

[image]https://www.tradingview.com/x/lvE6vG4P/[/image]

[b]3.ETH/USD 15m: Bearish Alignment: StopVol + BOS.[/b] Following a multi-hour consolidation between approximately 10:00 and 13:00 near the 2115–2125 area, price rejected the consolidation high with a high-volume bar at approximately 13:00, then broke below the local pivot. Stopping Volume and Break of Structure aligned on the same bar in a Volatile regime, firing a Bearish Alignment at 2110.89 with Invalidation at 2133.24. The setup is currently in progress, advancing toward Reference Level 1 (2088.54) and Reference Level 2 (2066.18), with a large sellside liquidity pool sitting in the path.

[image]https://www.tradingview.com/x/DhKfbcHa/[/image]

[b]HOW TO READ THE OUTPUT[/b]

When a setup fires you will see four horizontal levels with right-side labels:

[b]ENTRY[/b] (solid line, signal-direction color)
The closing price of the signal bar.

[b]REFERENCE LEVEL 1[/b] (dashed line, reference color)
Placed at 1R by default. Informational only - the setup does not close here. Useful for partial-exit planning or scaling.

[b]REFERENCE LEVEL 2[/b] (dashed line, reference color)
Placed at 2R by default. Reaching this level closes the setup as a success.

[b]INVALIDATION[/b] (dotted line, invalidation color)
Placed at 3 ATR from entry by default. Reaching this level closes the setup as a failure.

[b]Outcome and historical record[/b]
The setup closes when either Reference Level 2 or Invalidation is reached intrabar. Outcome is detected on the bar's high/low. When a single bar's range spans both levels, the setup closes on that bar; the script does not assume intrabar order, so the user should treat such ambiguous closures cautiously when reviewing historical results.

When the trade closes, right-side labels and connectors are removed and the four lines freeze at the closure bar. The signal label at the firing bar remains as a permanent record. To keep object counts within TradingView limits on long histories, the script retains the most recent 400 signal labels and the most recent 400 closed-trade lines; older items are recycled automatically.

[b]COOLDOWN[/b]
After any trade closes, the script waits a configurable number of bars before arming the next setup. Prevents back-to-back firing on noisy moves.

[b]THE DASHBOARD[/b]

A 9-row status panel reports:

[b]Regime[/b] - Trend Up, Trend Down, Range, Volatile, or Neutral.
[b]Phase[/b] - Quiet, Normal, or Active.
[b]Pattern rows[/b] - for each of the five behaviors: rolling Activity count and a Low / Medium / High Emphasis rating based on recent follow-through reliability on this chart.
[b]Patterns Required[/b] - the integer minimum that must align for a signal to fire on the current bar. Equal to your "Minimum Patterns Required" input in Quiet and Normal phases; tightened by one (capped at five) in Active phase.
[b]Status[/b] - Ready, Cooldown, or Signal Active.

[b]THE HUNTING LAYER[/b]

Drawn while no trade is active and the script is hunting for confluence:

[b]Buyside Liquidity zones[/b] - blue boxes above swing highs.
[b]Sellside Liquidity zones[/b] - teal boxes below swing lows.
[b]Bullish Order Blocks[/b] - teal boxes at the last bearish candle before a strong bullish impulse.
[b]Bearish Order Blocks[/b] - red boxes at the last bullish candle before a strong bearish impulse.
[b]Compression bars[/b] - amber boxes on narrow-range candles.
[b]Stopping Volume markers[/b] - amber triangles at high-volume rejection candles at local extremes.
[b]BOS labels[/b] - text labels at confirmed structural breaks, centered on the broken level.
[b]Sweep markers[/b] - text labels at the bar where price violated a confirmed pivot extreme, marking where liquidity was taken.
[b]Reclaim labels[/b] - text labels at the bar where price closed back inside the prior range, confirming the sweep. Together with the Sweep marker, these tell the complete two-event Sweep+Reclaim story.
[b]HH / HL / LH / LL pivot labels[/b] - market structure narration. Pivots are independent of the BOS module switch and are shown whenever the pivot toggle is enabled.

Duplicate BOS, Sweep, and Reclaim markers at the same price level within a recent window are automatically suppressed. Each confirmed pivot can be swept and reclaimed at most once until a new pivot forms.

[b]At signal fire[/b]
[b]Each active hunting item is evaluated:[/b]

- If its pattern type contributed to the signal, it is recolored to the signal's direction and promoted to history.
- If it is a liquidity zone or order block sitting inside the trade's expected path AND structurally aligned with the trade, it is promoted as context.
- Everything else is erased instantly.

At signal fire, BOS and Reclaim markers are explicitly drawn so every fired setup carries its structural anchor. The Reclaim marker is guaranteed when the Sweep pattern contributed; the BOS marker is drawn when BOS contributed and no recent BOS marker exists at the same level.

[b]TIMEFRAME GUIDANCE[/b]

[b]1m and 3m[/b] - high-frequency scalping on liquid pairs (BTC/USDT, ETH/USDT, NQ, ES).
[b]5m and 15m[/b] - intraday swing entries on the same instruments and other liquid markets.
[b]30m and above[/b] - functional but signal frequency drops noticeably; suitable for positional approaches.

The [b]Auto-Calibrate by Timeframe[/b] input automatically scales swing lookback, ATR length, volume lookback, sweep window, stopping-volume percentile, and compression lookback. Disable only for full manual control.

[b]HOW TO USE IT[/b]

1. Load on a clean chart. Leave Auto-Calibrate enabled.
2. Watch the Hunting Layer to see what the script is monitoring.
3. Wait for a signal label to print at bar close. The label text lists the contributing patterns.
4. The four levels appear automatically.
5. The setup auto-closes when Reference Level 2 or Invalidation is reached. After cooldown, hunting resumes.

[b]INPUTS GUIDE[/b]

[b]Auto-Calibrate by Timeframe[/b] - master switch that scales all lookbacks to the chart timeframe.

[b]Pattern Modules[/b] - enable or disable any of the five detectors individually.

[b]Core Parameters[/b] - manual swing, ATR, and volume lookbacks (used when Auto-Calibrate is OFF).

[b]Pattern Tuning[/b] - per-pattern sensitivity controls.

[b]Adaptive Learning[/b] - evaluation window, follow-through threshold in ATR multiples, learning memory, and minimum emphasis floor.

[b]Regime Filter[/b] - toggle regime awareness and set its lookback.

[b]Volatility Phase[/b] - toggle phase-based threshold tightening and set its lookback.

[b]Confluence Decay[/b] - toggle linear decay of residual opposing scores.

[b]Output[/b] - Quiet Mode (only High-Confluence tier fires), minimum patterns required, cooldown bars, RR for Reference Levels 1 and 2, Invalidation distance in ATR multiples, and label offset from the last bar.

[b]Visual[/b] - color tones for bullish, bearish, reference, invalidation, and label background.

[b]ICT Hunting Layer[/b] - individual toggles and color controls for every visual element and the legend panel.

[b]ALERTS[/b]

[b]Six alert[/b] conditions cover every tier and direction combination:

- Bullish High-Confluence
- Bearish High-Confluence
- Bullish Alignment
- Bearish Alignment
- Bullish Watch
- Bearish Watch
Add through the standard TradingView alert dialog.

[b]TECHNICAL NOTES[/b]

- All pattern detection and signal arming occur on confirmed bar close. No intrabar fires, no repaint.
- No request.security() calls. No higher-timeframe lookups. No lookahead modifiers. No future leakage.
- Pivots use 3-bar right confirmation - structural lag is intentional and removes false breaks.
- The script uses one active trade slot at a time. New setups can only arm after the current one closes and cooldown expires.
- Same-bar conflict between Reference Level 2 and Invalidation resolves conservatively as invalidation. This is the honest interpretation when intrabar order is unknown.
- Object retention is bounded: 400 signal labels, 400 closed-trade lines, 400 hunting-history items. Adaptive learning memory is configurable up to 1000 bars per pattern.

[b]WHAT THIS SCRIPT IS NOT[/b]

- Not a strategy. It does not place trades or compute P&L.
- Not a holy grail. No indicator is.
- Not a black box. Every threshold and lookback is exposed as an input.
- Not predictive. It reacts to confirmed structural events at bar close.

[b]DISCLAIMER[/b]

This script is published as an open-source educational and analytical tool. It does not constitute financial advice, a recommendation to buy or sell any instrument, or any guarantee of future performance. Past behavior of any pattern on any chart does not guarantee future results. You are solely responsible for your trading decisions, your risk management, and your testing on a demo environment before any live use. The author and TradingView accept no liability for losses incurred from use of this script.

[b]CREDITS[/b]

Concepts inspired by public ICT (Inner Circle Trader) educational material. All detection logic, scoring, regime classification, adaptive learning, lifecycle management, and visualization is original implementation by the author.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  ICT CONFLUENCE FRAMEWORK
//  ─────────────────────────────────────────────────────────────────────────
//  Author      : © BullByte
//  License     : Mozilla Public License 2.0 - https://mozilla.org/MPL/2.0/
//  Version     : 1.0  (Pine Script v6)
// ────────────────────────────────────────────────────────────────────────────
//  PURPOSE
//  An institutional-style confluence engine built on five orthogonal price
//  behaviors derived from ICT methodology:
//      1. Liquidity Sweep + Reclaim       - stop-hunt then rejection
//      2. Stopping Volume                 - institutional defense bar
//      3. Range Compression → Expansion   - coiled energy release
//      4. Break of Structure (BOS)        - market structure shift
//      5. Order Block Mitigation          - return to origin of impulse
//
//  When N or more patterns align on the same bar, a directional setup is
//  fired with Entry, two Reference Levels (R1 / R2), and an Invalidation
//  level. Trade outcome is binary: price reaches Reference Level 2
//  (success) or Invalidation (failure). After closure, all dynamic labels
//  are removed; the four horizontal levels and the original Trigger label
//  remain on the chart as a clean historical record.
//
//  WHAT MAKES THIS DIFFERENT
//  • The script learns this chart. Pattern weights are recalculated from
//    the actual follow-through history on the instrument and timeframe
//    you are viewing - no global presets, no one-size-fits-all bias.
//  • Market state matters. A breakout in a range is treated differently
//    from the same breakout in a trend. The regime classifier and the
//    volatility-phase detector adjust thresholds in real time.
//  • The chart stays clean. Structural visuals appear while the script
//    is "hunting" for confluence, then either lock in as part of the
//    setup's record or disappear the moment a signal fires.
//  • Signals are stable. Once a setup prints, it does not move, redraw,
//    or vanish on the next tick. What you see at bar close is final.
//
//  HOW TO READ IT
//  1. Watch the hunting layer - liquidity, order blocks, compression -
//     to see what the script is monitoring in real time.
//  2. When confluence forms, a labeled signal prints at the bar and four
//     levels appear: Entry, Reference 1, Reference 2, Invalidation.
//  3. The trade resolves on either Reference 2 (success) or Invalidation
//     (failure). After resolution, the levels remain as a historical
//     reference and the script enters a short cooldown.
//  4. The dashboard reports current regime, volatility phase, per-pattern
//     reliability on this chart, and system readiness.
//
//  DISCLAIMER
//  This script is an analytical and educational framework, not financial
//  advice. Past pattern behavior on a given chart does not guarantee future
//  performance. You are solely responsible for your trading decisions and
//  for testing thoroughly before any live deployment.
// ════════════════════════════════════════════════════════════════════════════

indicator('ICT Confluence Framework[BullByte]', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)


// ════════════════════════════════════════════════════════════════════════════
// SECTION 1 - INPUTS
// All user-facing parameters. Grouped by concern. Defaults are tuned for
// intraday trading on 1m–15m timeframes.
// ════════════════════════════════════════════════════════════════════════════

// ─── Auto-Calibration ──────────────────────────────────────────────────────
grpA     = 'Auto-Adapter'
autoMode = input.bool(true, 'Auto-Calibrate by Timeframe', group = grpA, tooltip = 'When enabled, key parameters scale to the chart timeframe. Disable for full manual control.')

// ─── Pattern Module Switches ───────────────────────────────────────────────
grpS      = 'Pattern Modules'
sigSweep  = input.bool(true, 'Liquidity Sweep + Reclaim',     group = grpS, tooltip = 'Price violates a recent swing extreme then closes back inside within N bars.')
sigStop   = input.bool(true, 'Stopping Volume',               group = grpS, tooltip = 'High-volume bar at a local extreme with strong rejection wick.')
sigExpand = input.bool(true, 'Range Compression → Expansion', group = grpS, tooltip = 'A narrow-range bar followed by an expansion bar of either direction.')
sigBOS    = input.bool(true, 'Break of Structure',            group = grpS, tooltip = 'Close beyond the last confirmed swing high or low.')
sigOB     = input.bool(true, 'Order Block Mitigation',        group = grpS, tooltip = 'Price returns to the candle preceding a prior impulse and reacts.')

// ─── Core Math Parameters ──────────────────────────────────────────────────
grpC      = 'Core Parameters'
swingLenI = input.int(10, 'Swing Lookback',  minval = 3,  maxval = 50,  group = grpC)
atrLenI   = input.int(14, 'ATR Length',      minval = 5,  maxval = 50,  group = grpC)
volLookI  = input.int(50, 'Volume Lookback', minval = 10, maxval = 200, group = grpC)

// ─── Pattern Tuning ────────────────────────────────────────────────────────
grpT      = 'Pattern Tuning'
sweepKI   = input.int(3,     'Sweep: bars to reclaim',          minval = 1,   maxval = 10,   group = grpT)
stopVPctI = input.float(90,  'Stopping Vol: percentile',        minval = 50,  maxval = 99,   step = 1,    group = grpT)
stopRej   = input.float(0.66,'Stopping Vol: rejection ratio',   minval = 0.5, maxval = 0.95, step = 0.05, group = grpT)
compNI    = input.int(7,     'Compression: narrowest lookback', minval = 3,   maxval = 20,   group = grpT)
expMult   = input.float(1.5, 'Expansion: range vs ATR',         minval = 1.0, maxval = 4.0,  step = 0.1,  group = grpT)
obImpMult = input.float(1.5, 'Order Block: impulse vs ATR',     minval = 1.0, maxval = 4.0,  step = 0.1,  group = grpT)

// ─── Adaptive Learning Engine ──────────────────────────────────────────────
grpL        = 'Adaptive Learning'
adaptOn     = input.bool(true,  'Enable Adaptive Pattern Emphasis', group = grpL, tooltip = 'Each pattern weight shifts with its rolling follow-through rate on this chart.')
evalWindow  = input.int(10,     'Pattern Evaluation Window (bars)', minval = 3,   maxval = 50,   group = grpL, tooltip = 'Bars after a pattern fires used to measure follow-through.')
winThresh   = input.float(1.0,  'Follow-through Threshold (ATR)',   minval = 0.3, maxval = 5.0,  step = 0.1,  group = grpL, tooltip = 'Required favorable excursion measured in ATR multiples.')
trackBars   = input.int(200,    'Learning Memory (bars)',           minval = 50,  maxval = 1000, group = grpL)
weightFloor = input.float(0.2,  'Minimum Pattern Emphasis',         minval = 0.0, maxval = 0.5,  step = 0.05, group = grpL, tooltip = 'Floor so no pattern is fully silenced regardless of history.')

// ─── Regime Filter ─────────────────────────────────────────────────────────
grpR     = 'Regime Filter'
regimeOn = input.bool(true, 'Apply Regime Awareness', group = grpR, tooltip = 'Soft-weights structurally suspect patterns and reduces counter-trend signals.')
regLook  = input.int(30,    'Regime Lookback', minval = 10, maxval = 100, group = grpR)

// ─── Volatility Phase ──────────────────────────────────────────────────────
grpV      = 'Volatility Phase'
phaseOn   = input.bool(true, 'Volatility-Phase Aware Threshold', group = grpV, tooltip = 'ATR percentile classifies the bar as Quiet, Normal, or Active. Active phase tightens the confluence threshold by 25%; Quiet and Normal leave it unchanged.')
phaseLook = input.int(100,   'Phase Lookback',  minval = 30, maxval = 500, group = grpV)

// ─── Confluence Decay ──────────────────────────────────────────────────────
grpD    = 'Confluence Decay'
decayOn = input.bool(true, 'Enable Confluence Decay', group = grpD, tooltip = 'Each bar with no active pattern subtracts 1.0 from the residual confluence score so a stale opposing cluster cannot block a fresh signal.')

// ─── Output & Trade Levels ─────────────────────────────────────────────────
grpO        = 'Output'
quietMode   = input.bool(false,'Quiet Mode (only High-Confluence)', group = grpO, tooltip = 'Hides Watch and Alignment tiers; only 3+ patterns fire.')
minConf     = input.int(2,     'Minimum Patterns Required',         minval = 1,   maxval = 5, group = grpO, tooltip = 'Hard floor for the number of patterns required to fire. The tier name (Watch/Alignment/High-Confluence) reflects how many patterns aligned at fire time.')
cooldown    = input.int(5,     'Cooldown after signal (bars)',      minval = 1,   maxval = 50, group = grpO)
rrTarget    = input.float(2.0, 'Reference Level 2 - RR multiple',   minval = 0.5, step = 0.1,  group = grpO)
rrTarget1   = input.float(1.0, 'Reference Level 1 - RR multiple',   minval = 0.3, step = 0.1,  group = grpO)
slAtrMult   = input.float(3.0, 'Invalidation distance (ATR x)',     minval = 0.5, maxval = 8.0, step = 0.1, group = grpO)
labelOffset = input.int(20,    'Label distance from last bar',      minval = 5,   maxval = 100, group = grpO)

// ─── Visual Theme ──────────────────────────────────────────────────────────
grpVis   = 'Visual'
showDash = input.bool(true, 'Show Educational Dashboard', group = grpVis)
dashPos  = input.string('Top Right', 'Dashboard Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = grpVis)
cBull    = input.color(#00BFA5, 'Bullish Tone',      group = grpVis)
cBear    = input.color(#FF5252, 'Bearish Tone',      group = grpVis)
cInval   = input.color(#FFA000, 'Invalidation Tone', group = grpVis)
cRef     = input.color(#3D5AFE, 'Reference Tone',    group = grpVis)
cLabel   = input.color(color.new(#263238, 15), 'Label Background', group = grpVis)

// ─── ICT Hunting Layer ─────────────────────────────────────────────────────
grpH        = 'ICT Hunting Layer'
huntOn      = input.bool(true, 'Show Pattern Hunting Visuals', group = grpH, tooltip = 'Live structural visuals drawn while no trade is active. At signal fire: contributing items become permanent, non-contributors wipe.')
showLiq     = input.bool(true, 'Liquidity Zones',         group = grpH)
showOBv     = input.bool(true, 'Order Blocks',            group = grpH)
showComp    = input.bool(true, 'Compression Bars',        group = grpH)
showStop    = input.bool(true, 'Stopping Volume Markers', group = grpH)
showBOS     = input.bool(true, 'BOS Event Labels',        group = grpH)
showReclaim = input.bool(true, 'Sweep & Reclaim Labels',    group = grpH)
showPivots  = input.bool(true, 'HH / HL / LH / LL Pivots', group = grpH)
showLegend  = input.bool(true, 'Color Legend (BR corner)', group = grpH)
cBOStxt     = input.color(color.new(#ECEFF1, 0),  'BOS / Reclaim Text',  group = grpH)
cPivot      = input.color(color.new(#90A4AE, 10), 'Pivot Text',          group = grpH)
cLiqBuy     = input.color(color.new(#3D5AFE, 82), 'Buyside Liquidity',   group = grpH)
cLiqSell    = input.color(color.new(#00BFA5, 82), 'Sellside Liquidity',  group = grpH)
cOBbull     = input.color(color.new(#00BFA5, 72), 'Bullish Order Block', group = grpH)
cOBbear     = input.color(color.new(#FF5252, 72), 'Bearish Order Block', group = grpH)
cCompTone   = input.color(color.new(#FFA000, 72), 'Compression Bar',     group = grpH)
cStopDot    = input.color(color.new(#FFAB00, 10), 'Stopping Volume',     group = grpH)


// ════════════════════════════════════════════════════════════════════════════
// SECTION 2 - CALIBRATED PARAMETERS
// Auto-Adapter logic: scale every meaningful lookback to the chart timeframe.
// `simple` qualifiers required so ta.* functions accept the result.
// ════════════════════════════════════════════════════════════════════════════

simple int tfMin = timeframe.in_seconds() / 60

simple int   swL = autoMode ? (tfMin <= 1 ? 8  : tfMin <= 3 ? 10 : tfMin <= 5 ? 12 : tfMin <= 15 ? 15 : 20) : swingLenI
simple int   aL  = autoMode ? (tfMin <= 1 ? 10 : tfMin <= 3 ? 14 : tfMin <= 5 ? 14 : tfMin <= 15 ? 14 : 14) : atrLenI
simple int   vL  = autoMode ? (tfMin <= 1 ? 50 : tfMin <= 3 ? 50 : tfMin <= 5 ? 50 : tfMin <= 15 ? 60 : 80) : volLookI
simple int   swK = autoMode ? (tfMin <= 1 ? 2  : tfMin <= 3 ? 3  : tfMin <= 5 ? 3  : tfMin <= 15 ? 4  : 5)  : sweepKI
simple float svP = autoMode ? (tfMin <= 1 ? 88.0 : tfMin <= 3 ? 90.0 : 92.0) : stopVPctI
simple int   cN  = autoMode ? (tfMin <= 1 ? 5  : tfMin <= 3 ? 7  : tfMin <= 5 ? 7  : tfMin <= 15 ? 10 : 12) : compNI


// ════════════════════════════════════════════════════════════════════════════
// SECTION 3 - CACHED PRIMITIVES
// One-time evaluations reused across modules.
// ════════════════════════════════════════════════════════════════════════════

atr       = ta.atr(aL)
barRange  = high - low
volPctile = ta.percentile_linear_interpolation(volume, vL, svP)
priorHigh = ta.highest(high, swL)[1]
priorLow  = ta.lowest(low,   swL)[1]


// ════════════════════════════════════════════════════════════════════════════
// SECTION 4 - VOLATILITY PHASE DETECTOR
// Classifies the current bar's volatility against its rolling distribution
// and returns a multiplier applied to the confluence threshold.
// Active phase requires more confluence (1.25x). Quiet and Normal phases use 1.0x.
// ════════════════════════════════════════════════════════════════════════════

atrRankPhase    = ta.percentrank(atr, phaseLook) / 100.0
phaseId         = atrRankPhase >= 0.75 ? 2 : atrRankPhase <= 0.30 ? 0 : 1
phaseName       = phaseId == 2 ? 'Active' : phaseId == 0 ? 'Quiet' : 'Normal'
phaseMultiplier = not phaseOn ? 1.0 : phaseId == 2 ? 1.25 : 1.0


// ─── Warmup guard: ensure every rolling statistic has filled its window ────
warmupBars = math.max(math.max(swL, aL), math.max(vL, math.max(regLook * 2, phaseLook))) + 10
isWarmedUp = bar_index >= warmupBars and not na(atr) and not na(volPctile) and not na(priorHigh) and not na(priorLow)

confirmed = barstate.isconfirmed


// ════════════════════════════════════════════════════════════════════════════
// SECTION 5 - PATTERN DETECTION
// Each pattern resolves on bar close. No future leakage, no repainting.
// ════════════════════════════════════════════════════════════════════════════

// ─── Liquidity Sweep + Reclaim ─────────────────────────────────────────────
// Sweep = current bar violates the last confirmed pivot extreme.
// Reclaim = within swK bars after, price closes back inside the violated pivot.
// Each pivot can be swept and reclaimed at most once. Once a new pivot forms,
// the cycle resets.
var int   sweepHighBar = na
var float sweepHighLvl = na
var int   sweepLowBar  = na
var float sweepLowLvl  = na

// Detection moved to AFTER pivot tracking — see below.

// ─── Stopping Volume ───────────────────────────────────────────────────────
// High-volume bar at a local extreme with strong rejection in the wick.
// volPctile > 0 guard prevents false positives on illiquid bars where the
// percentile collapses to zero.
highVol    = volPctile > 0 and volume >= volPctile
closeInTop = barRange > 0 and (close - low)  / barRange >= stopRej
closeInBot = barRange > 0 and (high - close) / barRange >= stopRej

simple int stopExtremeLen = math.max(3, swL / 2)
atLow_  = low  <= ta.lowest(low,   stopExtremeLen)[1]
atHigh_ = high >= ta.highest(high, stopExtremeLen)[1]

stopBull = confirmed and sigStop and highVol and closeInTop and atLow_
stopBear = confirmed and sigStop and highVol and closeInBot and atHigh_

// ─── Range Compression to Expansion ────────────────────────────────────────
// Previous bar must be the narrowest of its cN-bar window; current bar must
// expand to expMult x ATR.
narrowestPrev = ta.lowest(barRange, cN)[1]
wasCompressed = barRange[1] <= narrowestPrev
expansion     = barRange >= expMult * atr
expandBull    = confirmed and sigExpand and wasCompressed and expansion and close > open
expandBear    = confirmed and sigExpand and wasCompressed and expansion and close < open

// ─── Break of Structure ────────────────────────────────────────────────────
// Pivots use 3-bar right confirmation (structural lag, by design).
pivH = ta.pivothigh(high, 3, 3)
pivL = ta.pivotlow(low,  3, 3)

var float lastSwingH = na
var float lastSwingL = na

if confirmed and not na(pivH)
    lastSwingH := pivH
if confirmed and not na(pivL)
    lastSwingL := pivL

bosBull = confirmed and sigBOS and not na(lastSwingH) and close > lastSwingH and close[1] <= lastSwingH
bosBear = confirmed and sigBOS and not na(lastSwingL) and close < lastSwingL and close[1] >= lastSwingL

var float lastSweptH = na
var float lastSweptL = na

bool sweepHitHigh = confirmed and not na(lastSwingH) and high > lastSwingH and (na(lastSweptH) or lastSwingH != lastSweptH)
bool sweepHitLow  = confirmed and not na(lastSwingL) and low  < lastSwingL and (na(lastSweptL) or lastSwingL != lastSweptL)

if sweepHitHigh
    lastSweptH   := lastSwingH
    sweepHighBar := bar_index
    sweepHighLvl := lastSwingH
if sweepHitLow
    lastSweptL   := lastSwingL
    sweepLowBar  := bar_index
    sweepLowLvl  := lastSwingL

sweepBear = confirmed and sigSweep and not na(sweepHighBar) and bar_index > sweepHighBar and (bar_index - sweepHighBar) <= swK and close < sweepHighLvl and high >= sweepHighLvl
sweepBull = confirmed and sigSweep and not na(sweepLowBar)  and bar_index > sweepLowBar  and (bar_index - sweepLowBar)  <= swK and close > sweepLowLvl  and low  <= sweepLowLvl

if sweepBear
    sweepHighBar := na
if sweepBull
    sweepLowBar  := na

if not na(pivH)
    lastSweptH := na
if not na(pivL)
    lastSweptL := na

// ─── Order Block Mitigation ────────────────────────────────────────────────
// Capture the last opposing candle preceding a strong impulse. Mitigation
// requires the wick to touch the OB and the bar to close back outside.
impulseUp = (close - open) >= obImpMult * atr and close > open
impulseDn = (open - close) >= obImpMult * atr and close < open

var float bullObTop = na
var float bullObBot = na
var float bearObTop = na
var float bearObBot = na

if confirmed and impulseUp and close[1] < open[1]
    bullObTop := high[1]
    bullObBot := low[1]
if confirmed and impulseDn and close[1] > open[1]
    bearObTop := high[1]
    bearObBot := low[1]

obBullMit = confirmed and sigOB and not na(bullObBot) and low  <= bullObTop and low  >= bullObBot and close > bullObTop
obBearMit = confirmed and sigOB and not na(bearObTop) and high >= bearObBot and high <= bearObTop and close < bearObBot

if obBullMit
    bullObTop := na
    bullObBot := na
if obBearMit
    bearObTop := na
    bearObBot := na

// ─── Confluence Window: pattern memory across N bars ──────────────────────
simple int confWin = tfMin <= 1 ? 4 : tfMin <= 3 ? 3 : 2

var int wSweepBullBar  = -999
var int wSweepBearBar  = -999
var int wStopBullBar   = -999
var int wStopBearBar   = -999
var int wExpandBullBar = -999
var int wExpandBearBar = -999
var int wBOSBullBar    = -999
var int wBOSBearBar    = -999
var int wOBBullBar     = -999
var int wOBBearBar     = -999

if sweepBull
    wSweepBullBar  := bar_index
if sweepBear
    wSweepBearBar  := bar_index
if stopBull
    wStopBullBar   := bar_index
if stopBear
    wStopBearBar   := bar_index
if expandBull
    wExpandBullBar := bar_index
if expandBear
    wExpandBearBar := bar_index
if bosBull
    wBOSBullBar    := bar_index
if bosBear
    wBOSBearBar    := bar_index
if obBullMit
    wOBBullBar     := bar_index
if obBearMit
    wOBBearBar     := bar_index

windowActive(int firedBar) =>
    bar_index - firedBar <= confWin

sweepBullW  = sigSweep  and windowActive(wSweepBullBar)
sweepBearW  = sigSweep  and windowActive(wSweepBearBar)
stopBullW   = sigStop   and windowActive(wStopBullBar)
stopBearW   = sigStop   and windowActive(wStopBearBar)
expandBullW = sigExpand and windowActive(wExpandBullBar)
expandBearW = sigExpand and windowActive(wExpandBearBar)
bosBullW    = sigBOS    and windowActive(wBOSBullBar)
bosBearW    = sigBOS    and windowActive(wBOSBearBar)
obBullW     = sigOB     and windowActive(wOBBullBar)
obBearW     = sigOB     and windowActive(wOBBearBar)

// ════════════════════════════════════════════════════════════════════════════
// SECTION 6 - ADAPTIVE PATTERN EMPHASIS ENGINE
// Each pattern keeps a rolling log of fires and their follow-through. The
// follow-through ratio drives an emphasis weight bounded by weightFloor.
// Follow-through = max favorable excursion during evalWindow bars >= ATR*winThresh.
// ════════════════════════════════════════════════════════════════════════════

type Tracker
    array<int>   bars
    array<float> prices
    array<int>   dirs
    array<float> maxFav
    array<int>   wins
    array<int>   totals

makeTracker() =>
    Tracker.new(array.new<int>(), array.new<float>(), array.new<int>(), array.new<float>(), array.new<int>(), array.new<int>())

var Tracker trkSweep  = makeTracker()
var Tracker trkStop   = makeTracker()
var Tracker trkExpand = makeTracker()
var Tracker trkBOS    = makeTracker()
var Tracker trkOB     = makeTracker()

registerSignal(Tracker t, bool fired, int dir) =>
    if fired
        array.push(t.bars,   bar_index)
        array.push(t.prices, close)
        array.push(t.dirs,   dir)
        array.push(t.maxFav, 0.0)

resolveTracker(Tracker t, float curHigh, float curLow, float curAtr) =>
    int i = 0
    while i < array.size(t.bars)
        int   entryBar = array.get(t.bars,   i)
        float entryPx  = array.get(t.prices, i)
        int   entryDir = array.get(t.dirs,   i)
        float prevFav  = array.get(t.maxFav, i)
        float curFav   = entryDir == 1 ? curHigh - entryPx : entryPx - curLow
        float newFav   = math.max(prevFav, curFav)
        array.set(t.maxFav, i, newFav)
        if bar_index - entryBar >= evalWindow
            float threshold = winThresh * curAtr
            bool  won       = newFav >= threshold
            array.push(t.wins,   won ? 1 : 0)
            array.push(t.totals, 1)
            array.remove(t.bars,   i)
            array.remove(t.prices, i)
            array.remove(t.dirs,   i)
            array.remove(t.maxFav, i)
        else
            i := i + 1
    while array.size(t.wins) > trackBars
        array.shift(t.wins)
        array.shift(t.totals)

registerSignal(trkSweep,  sweepBull,  1)
registerSignal(trkSweep,  sweepBear, -1)
registerSignal(trkStop,   stopBull,   1)
registerSignal(trkStop,   stopBear,  -1)
registerSignal(trkExpand, expandBull, 1)
registerSignal(trkExpand, expandBear,-1)
registerSignal(trkBOS,    bosBull,    1)
registerSignal(trkBOS,    bosBear,   -1)
registerSignal(trkOB,     obBullMit,  1)
registerSignal(trkOB,     obBearMit, -1)

resolveTracker(trkSweep,  high, low, atr)
resolveTracker(trkStop,   high, low, atr)
resolveTracker(trkExpand, high, low, atr)
resolveTracker(trkBOS,    high, low, atr)
resolveTracker(trkOB,     high, low, atr)

followThrough(Tracker t) =>
    int   totN   = array.size(t.totals)
    float result = 0.5
    if totN >= 5
        float wsum = 0.0
        for j = 0 to totN - 1 by 1
            wsum := wsum + array.get(t.wins, j)
        result := wsum / totN
    result

emphasisWeight(float ft) =>
    adaptOn ? weightFloor + (1.0 - weightFloor) * ft : 1.0

ftSweep  = followThrough(trkSweep)
ftStop   = followThrough(trkStop)
ftExpand = followThrough(trkExpand)
ftBOS    = followThrough(trkBOS)
ftOB     = followThrough(trkOB)

wSweep  = emphasisWeight(ftSweep)
wStop   = emphasisWeight(ftStop)
wExpand = emphasisWeight(ftExpand)
wBOS    = emphasisWeight(ftBOS)
wOB     = emphasisWeight(ftOB)

countActivity(Tracker t) =>
    array.size(t.wins) + array.size(t.bars)

emphasisLabel(float w) =>
    w >= 0.7 ? 'High' : w >= 0.4 ? 'Medium' : 'Low'


// ════════════════════════════════════════════════════════════════════════════
// SECTION 7 - REGIME CLASSIFIER
// Efficiency ratio (net displacement / path length) classifies market state.
//   Soft weight: BOS in Range reduced to 0.4x, Expansion in Volatile to 0.5x.
//   Counter-trend signals in strong trends reduced to 0.5x.
// ════════════════════════════════════════════════════════════════════════════

netMove = math.abs(close - close[regLook])

float pathSum = 0.0
for ii = 0 to regLook - 1 by 1
    pathSum := pathSum + math.abs(close[ii] - close[ii + 1])

efficiency  = pathSum == 0 ? 0.0 : netMove / pathSum
atrRankReg  = ta.percentrank(atr, regLook * 2) / 100.0
regSlope    = (close - close[regLook]) / regLook
regTrend    = efficiency >= 0.4
regRange    = efficiency <  0.25
regVolatile = atrRankReg >= 0.85

regimeId   = regTrend and regSlope > 0 ? 1 : regTrend and regSlope < 0 ? 2 : regRange ? 3 : regVolatile ? 4 : 0
regimeName = regimeId == 1 ? 'Trend Up' : regimeId == 2 ? 'Trend Down' : regimeId == 3 ? 'Range' : regimeId == 4 ? 'Volatile' : 'Neutral'


softWeight(string typ, int rid) =>
    float w = 1.0
    if regimeOn
        if rid == 3 and typ == 'BOS'
            w := 0.4
        if rid == 4 and typ == 'Expand'
            w := 0.5
    w

regimeWeight(int dir) =>
    float w = 1.0
    if regimeOn
        if regimeId == 1 and dir == -1
            w := 0.5
        else if regimeId == 2 and dir == 1
            w := 0.5
    w

sweepBullF  = sweepBullW
sweepBearF  = sweepBearW
stopBullF   = stopBullW
stopBearF   = stopBearW
expandBullF = expandBullW
expandBearF = expandBearW
bosBullF    = bosBullW
bosBearF    = bosBearW
obBullF     = obBullW
obBearF     = obBearW


// ════════════════════════════════════════════════════════════════════════════
// SECTION 8 - CONFLUENCE SCORING + DECAY
// Sum surviving patterns, scale by emphasis and regime weight, then apply
// linear decay so post-fire residual cannot block fresh signals indefinitely.
// ════════════════════════════════════════════════════════════════════════════

bullCount = (sweepBullF ? 1 : 0) + (stopBullF ? 1 : 0) + (expandBullF ? 1 : 0) + (bosBullF ? 1 : 0) + (obBullF ? 1 : 0)
bearCount = (sweepBearF ? 1 : 0) + (stopBearF ? 1 : 0) + (expandBearF ? 1 : 0) + (bosBearF ? 1 : 0) + (obBearF ? 1 : 0)

float regWBull = regimeWeight(1)
float regWBear = regimeWeight(-1)
float bosSoft = softWeight('BOS',    regimeId) * 0.7
float expSoft = softWeight('Expand', regimeId)

rawBull = ((sweepBullF ? wSweep : 0.0) + (stopBullF ? wStop : 0.0) + (expandBullF ? wExpand * expSoft : 0.0) + (bosBullF ? wBOS * bosSoft : 0.0) + (obBullF ? wOB : 0.0)) * regWBull
rawBear = ((sweepBearF ? wSweep : 0.0) + (stopBearF ? wStop : 0.0) + (expandBearF ? wExpand * expSoft : 0.0) + (bosBearF ? wBOS * bosSoft : 0.0) + (obBearF ? wOB : 0.0)) * regWBear

var float decayedBull = 0.0
var float decayedBear = 0.0
decayedBull := rawBull > 0 ? rawBull : decayOn ? math.max(0.0, decayedBull - 1.0) : decayedBull
decayedBear := rawBear > 0 ? rawBear : decayOn ? math.max(0.0, decayedBear - 1.0) : decayedBear



tierByCount(int n) =>
    n >= 3 ? 'High-Confluence' : n == 2 ? 'Alignment' : n == 1 ? 'Watch' : ''

bullTier = tierByCount(bullCount)
bearTier = tierByCount(bearCount)

patternList(bool a, bool b, bool c, bool d, bool e) =>
    string s = ''
    if a
        s := s + 'Sweep'
    if b
        s := s == '' ? 'StopVol' : s + ' + StopVol'
    if c
        s := s == '' ? 'Expansion' : s + ' + Expansion'
    if d
        s := s == '' ? 'BOS' : s + ' + BOS'
    if e
        s := s == '' ? 'OB' : s + ' + OB'
    s

bullPatterns = patternList(sweepBullF, stopBullF, expandBullF, bosBullF, obBullF)
bearPatterns = patternList(sweepBearF, stopBearF, expandBearF, bosBearF, obBearF)

bullLabelTxt = bullTier == '' ? '' : 'Bullish ' + bullTier + ': ' + bullPatterns
bearLabelTxt = bearTier == '' ? '' : 'Bearish ' + bearTier + ': ' + bearPatterns

allowTier(string t) =>
    not quietMode or t == 'High-Confluence'


// ════════════════════════════════════════════════════════════════════════════
// SECTION 9 - SIGNAL LIFECYCLE & LEVEL MANAGEMENT
// One active trade at a time. On closure, lines freeze at the closure bar
// and labels/connectors delete. The signal label at the bar persists as
// permanent historical record.
// ════════════════════════════════════════════════════════════════════════════

var int   cooldownEnd     = 0
var int   activeDir       = 0
var int   activeSignalBar = na
var float entryPx         = na
var float ref1Px          = na
var float ref2Px          = na
var float invalPx         = na

var line  entryLine  = na
var line  ref1Line   = na
var line  ref2Line   = na
var line  invalLine  = na

var label entryLabel = na
var label ref1Label  = na
var label ref2Label  = na
var label invalLabel = na

var line  entryConn  = na
var line  ref1Conn   = na
var line  ref2Conn   = na
var line  invalConn  = na

var array<label> signalLabels = array.new<label>()
int maxSignalLabels = 400

var array<line> closedLines = array.new<line>()
int maxClosedLines = 400

minPatternCount = math.min(5, math.max(minConf, int(math.ceil(minConf * phaseMultiplier))))

canSignal   = confirmed and isWarmedUp and bar_index >= cooldownEnd and activeDir == 0
bullTrigger = canSignal and bullCount >= minPatternCount and bullCount > bearCount and bullTier != '' and allowTier(bullTier) and decayedBear < minPatternCount
bearTrigger = canSignal and bearCount >= minPatternCount and bearCount > bullCount and bearTier != '' and allowTier(bearTier) and decayedBull < minPatternCount

drawLevels(int dir, float px, float r1, float r2, float inval) =>
    int   xRight  = bar_index + labelOffset
    color toneDir = dir == 1 ? cBull : cBear
    color toneRef = cRef
    color toneInv = cInval

    line  el   = line.new(bar_index, px,    xRight, px,    color = toneDir, width = 2, style = line.style_solid,  extend = extend.none)
    line  r1l  = line.new(bar_index, r1,    xRight, r1,    color = toneRef, width = 1, style = line.style_dashed, extend = extend.none)
    line  r2l  = line.new(bar_index, r2,    xRight, r2,    color = toneRef, width = 1, style = line.style_dashed, extend = extend.none)
    line  il   = line.new(bar_index, inval, xRight, inval, color = toneInv, width = 1, style = line.style_dotted, extend = extend.none)
    line  ec   = line.new(xRight, px,    xRight + 2, px,    color = toneDir, width = 1, style = line.style_solid)
    line  rc1  = line.new(xRight, r1,    xRight + 2, r1,    color = toneRef, width = 1, style = line.style_solid)
    line  rc2  = line.new(xRight, r2,    xRight + 2, r2,    color = toneRef, width = 1, style = line.style_solid)
    line  ic   = line.new(xRight, inval, xRight + 2, inval, color = toneInv, width = 1, style = line.style_solid)
    label el_l = label.new(xRight + 2, px,    text = 'Entry  '  + str.tostring(px,    format.mintick), style = label.style_label_left, color = cLabel, textcolor = toneDir, size = size.small)
    label r1_l = label.new(xRight + 2, r1,    text = 'Ref L1 '  + str.tostring(r1,    format.mintick), style = label.style_label_left, color = cLabel, textcolor = toneRef, size = size.small)
    label r2_l = label.new(xRight + 2, r2,    text = 'Ref L2 '  + str.tostring(r2,    format.mintick), style = label.style_label_left, color = cLabel, textcolor = toneRef, size = size.small)
    label iv_l = label.new(xRight + 2, inval, text = 'Invalid ' + str.tostring(inval, format.mintick), style = label.style_label_left, color = cLabel, textcolor = toneInv, size = size.small)
    [el, r1l, r2l, il, el_l, r1_l, r2_l, iv_l, ec, rc1, rc2, ic]

// ─── Bullish setup arming ─────────────────────────────────────────────────
if bullTrigger
    entryPx   := close
    invalPx   := close - slAtrMult * atr
    float risk = close - invalPx
    ref1Px    := close + rrTarget1 * risk
    ref2Px    := close + rrTarget  * risk
    activeDir       := 1
    activeSignalBar := bar_index
    [el, r1l, r2l, il, el_l, r1_l, r2_l, iv_l, ec, rc1, rc2, ic] = drawLevels(1, entryPx, ref1Px, ref2Px, invalPx)
    entryLine  := el
    ref1Line   := r1l
    ref2Line   := r2l
    invalLine  := il
    entryLabel := el_l
    ref1Label  := r1_l
    ref2Label  := r2_l
    invalLabel := iv_l
    entryConn  := ec
    ref1Conn   := rc1
    ref2Conn   := rc2
    invalConn  := ic

// ─── Bearish setup arming ─────────────────────────────────────────────────
if bearTrigger
    entryPx   := close
    invalPx   := close + slAtrMult * atr
    float risk = invalPx - close
    ref1Px    := close - rrTarget1 * risk
    ref2Px    := close - rrTarget  * risk
    activeDir       := -1
    activeSignalBar := bar_index
    [el, r1l, r2l, il, el_l, r1_l, r2_l, iv_l, ec, rc1, rc2, ic] = drawLevels(-1, entryPx, ref1Px, ref2Px, invalPx)
    entryLine  := el
    ref1Line   := r1l
    ref2Line   := r2l
    invalLine  := il
    entryLabel := el_l
    ref1Label  := r1_l
    ref2Label  := r2_l
    invalLabel := iv_l
    entryConn  := ec
    ref1Conn   := rc1
    ref2Conn   := rc2
    invalConn  := ic

// ─── Permanent signal label at the firing bar ─────────────────────────────
if bullTrigger
    label lb = label.new(bar_index, low,  text = bullLabelTxt, yloc = yloc.belowbar, style = label.style_label_up,   color = cBull, textcolor = color.white, size = size.small, force_overlay = true)
    array.push(signalLabels, lb)
if bearTrigger
    label lb = label.new(bar_index, high, text = bearLabelTxt, yloc = yloc.abovebar, style = label.style_label_down, color = cBear, textcolor = color.white, size = size.small, force_overlay = true)
    array.push(signalLabels, lb)
while array.size(signalLabels) > maxSignalLabels
    label.delete(array.shift(signalLabels))
while array.size(closedLines) > maxClosedLines
    line.delete(array.shift(closedLines))

// ─── Outcome detection: Reference Level 2 or Invalidation ─────────────────
hitInvalBull = activeDir ==  1 and not na(activeSignalBar) and bar_index > activeSignalBar and low  <= invalPx
hitRef2Bull  = activeDir ==  1 and not na(activeSignalBar) and bar_index > activeSignalBar and high >= ref2Px
hitInvalBear = activeDir == -1 and not na(activeSignalBar) and bar_index > activeSignalBar and high >= invalPx
hitRef2Bear  = activeDir == -1 and not na(activeSignalBar) and bar_index > activeSignalBar and low  <= ref2Px

closedBull = hitInvalBull or hitRef2Bull
closedBear = hitInvalBear or hitRef2Bear

// ─── Trade closure: freeze lines, remove labels and connectors ────────────
if closedBull or closedBear
    if not na(entryLine)
        line.set_x2(entryLine, bar_index)
        array.push(closedLines, entryLine)
    if not na(ref1Line)
        line.set_x2(ref1Line, bar_index)
        array.push(closedLines, ref1Line)
    if not na(ref2Line)
        line.set_x2(ref2Line, bar_index)
        array.push(closedLines, ref2Line)
    if not na(invalLine)
        line.set_x2(invalLine, bar_index)
        array.push(closedLines, invalLine)
    label.delete(entryLabel)
    label.delete(ref1Label)
    label.delete(ref2Label)
    label.delete(invalLabel)
    line.delete(entryConn)
    line.delete(ref1Conn)
    line.delete(ref2Conn)
    line.delete(invalConn)
    entryLine  := na
    ref1Line   := na
    ref2Line   := na
    invalLine  := na
    entryLabel := na
    ref1Label  := na
    ref2Label  := na
    invalLabel := na
    entryConn  := na
    ref1Conn   := na
    ref2Conn   := na
    invalConn  := na
    activeDir       := 0
    activeSignalBar := na
    cooldownEnd     := bar_index + cooldown
    decayedBull     := 0.0
    decayedBear     := 0.0

// ─── Live extension of active trade visuals to the right edge ─────────────
if activeDir != 0 and barstate.islast
    int xR = bar_index + labelOffset
    if not na(entryLine)
        line.set_x2(entryLine, xR)
    if not na(ref1Line)
        line.set_x2(ref1Line, xR)
    if not na(ref2Line)
        line.set_x2(ref2Line, xR)
    if not na(invalLine)
        line.set_x2(invalLine, xR)
    if not na(entryConn)
        line.set_xy1(entryConn, xR,     entryPx)
        line.set_xy2(entryConn, xR + 2, entryPx)
    if not na(ref1Conn)
        line.set_xy1(ref1Conn,  xR,     ref1Px)
        line.set_xy2(ref1Conn,  xR + 2, ref1Px)
    if not na(ref2Conn)
        line.set_xy1(ref2Conn,  xR,     ref2Px)
        line.set_xy2(ref2Conn,  xR + 2, ref2Px)
    if not na(invalConn)
        line.set_xy1(invalConn, xR,     invalPx)
        line.set_xy2(invalConn, xR + 2, invalPx)
    if not na(entryLabel)
        label.set_xy(entryLabel, xR + 2, entryPx)
    if not na(ref1Label)
        label.set_xy(ref1Label,  xR + 2, ref1Px)
    if not na(ref2Label)
        label.set_xy(ref2Label,  xR + 2, ref2Px)
    if not na(invalLabel)
        label.set_xy(invalLabel, xR + 2, invalPx)


// ════════════════════════════════════════════════════════════════════════════
// SECTION 10 - EDUCATIONAL DASHBOARD
// Compact 9-row status panel: regime, phase, pattern activity & emphasis,
// patterns required, and current system state.
// ════════════════════════════════════════════════════════════════════════════

var table dash = na

if barstate.islast and showDash
    table.delete(dash)
    tablePos = dashPos == 'Top Right' ? position.top_right : dashPos == 'Top Left' ? position.top_left : dashPos == 'Bottom Right' ? position.bottom_right : position.bottom_left
    dash := table.new(tablePos, 3, 9, bgcolor = color.new(#263238, 10), border_width = 1, border_color = color.new(#546E7A, 40))

    color headerCol = color.new(#3D5AFE, 25)
    color titleTxt  = color.new(#FFFFFF, 0)
    color softTxt   = color.new(#B0BEC5, 0)
    color accent    = color.new(#00BFA5, 0)

    table.cell(dash, 0, 0, 'ICT Confluence Framework', text_color = titleTxt, bgcolor = headerCol, text_size = size.normal, text_halign = text.align_center)
    table.merge_cells(dash, 0, 0, 2, 0)

    table.cell(dash, 0, 1, 'Regime',             text_color = softTxt, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, regimeName,           text_color = accent,  text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 2, 1, phaseName + ' Phase', text_color = accent,  text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 2, 'Pattern',  text_color = softTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 2, 'Activity', text_color = softTxt, text_size = size.tiny, text_halign = text.align_center)
    table.cell(dash, 2, 2, 'Emphasis', text_color = softTxt, text_size = size.tiny, text_halign = text.align_right)

    table.cell(dash, 0, 3, 'Sweep + Reclaim',                       text_color = titleTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(countActivity(trkSweep)),   text_color = titleTxt, text_size = size.tiny, text_halign = text.align_center)
    table.cell(dash, 2, 3, emphasisLabel(wSweep),                   text_color = titleTxt, text_size = size.tiny, text_halign = text.align_right)

    table.cell(dash, 0, 4, 'Stopping Volume',                       text_color = titleTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(countActivity(trkStop)),    text_color = titleTxt, text_size = size.tiny, text_halign = text.align_center)
    table.cell(dash, 2, 4, emphasisLabel(wStop),                    text_color = titleTxt, text_size = size.tiny, text_halign = text.align_right)

    table.cell(dash, 0, 5, 'Compression Exp.',                      text_color = titleTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(countActivity(trkExpand)),  text_color = titleTxt, text_size = size.tiny, text_halign = text.align_center)
    table.cell(dash, 2, 5, emphasisLabel(wExpand),                  text_color = titleTxt, text_size = size.tiny, text_halign = text.align_right)

    table.cell(dash, 0, 6, 'Break of Struct.',                      text_color = titleTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(countActivity(trkBOS)),     text_color = titleTxt, text_size = size.tiny, text_halign = text.align_center)
    table.cell(dash, 2, 6, emphasisLabel(wBOS),                     text_color = titleTxt, text_size = size.tiny, text_halign = text.align_right)

    table.cell(dash, 0, 7, 'Order Block',                           text_color = titleTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(countActivity(trkOB)),      text_color = titleTxt, text_size = size.tiny, text_halign = text.align_center)
    table.cell(dash, 2, 7, emphasisLabel(wOB),                      text_color = titleTxt, text_size = size.tiny, text_halign = text.align_right)

    table.cell(dash, 0, 8, 'Patterns Required',                 text_color = softTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 8, str.tostring(minPatternCount),         text_color = softTxt, text_size = size.tiny, text_halign = text.align_center)
    table.cell(dash, 2, 8, activeDir != 0 ? 'Signal Active' : bar_index < cooldownEnd ? 'Cooldown' : 'Ready', text_color = accent, text_size = size.tiny, text_halign = text.align_right)


// ════════════════════════════════════════════════════════════════════════════
// SECTION 11 - ALERTS
// Six alert conditions covering all tier × direction combinations.
// ════════════════════════════════════════════════════════════════════════════

alertcondition(bullTrigger and bullTier == 'High-Confluence', 'Bullish High-Confluence', 'Bullish High-Confluence setup detected')
alertcondition(bearTrigger and bearTier == 'High-Confluence', 'Bearish High-Confluence', 'Bearish High-Confluence setup detected')
alertcondition(bullTrigger and bullTier == 'Alignment',       'Bullish Alignment',       'Bullish Alignment detected')
alertcondition(bearTrigger and bearTier == 'Alignment',       'Bearish Alignment',       'Bearish Alignment detected')
alertcondition(bullTrigger and bullTier == 'Watch',           'Bullish Watch',           'Bullish Watch tier')
alertcondition(bearTrigger and bearTier == 'Watch',           'Bearish Watch',           'Bearish Watch tier')


// ════════════════════════════════════════════════════════════════════════════
// SECTION 12 - ICT HUNTING LAYER
// Live structural visuals (liquidity, OBs, compression, stopping volume,
// BOS, reclaim, pivots) drawn while no trade is active. At signal fire,
// contributors and contextual items promote to permanent history; the rest
// are wiped instantly for a clean visual record.
// ════════════════════════════════════════════════════════════════════════════

int eventAgeMax = 15
int compAgeMax  = 5
int zoneCapEach = 5
int obCapEach   = 5

type HuntItem
    box    b
    line   l
    label  lb
    string pattern
    string kind
    int    bornBar
    float  yTop
    float  yBot
    int    dir
    color  fillCol

newHunt(box bx, line ln, label lbl, string p, string k, float yT, float yB, int d, color fc) =>
    HuntItem.new(bx, ln, lbl, p, k, bar_index, yT, yB, d, fc)

var array<HuntItem> activeHunts  = array.new<HuntItem>()
var array<HuntItem> historyHunts = array.new<HuntItem>()

huntingActive = isWarmedUp and activeDir == 0 and bar_index >= cooldownEnd and huntOn and not (bullTrigger or bearTrigger)

killHunt(HuntItem h) =>
    if not na(h.b)
        box.delete(h.b)
    if not na(h.l)
        line.delete(h.l)
    if not na(h.lb)
        label.delete(h.lb)

hasRecentMarkerAtLevel(string targetKind, float level, float tol, int maxAge) =>
    bool found = false
    int  na_ck = array.size(activeHunts)
    if na_ck > 0
        for i = 0 to na_ck - 1 by 1
            HuntItem h = array.get(activeHunts, i)
            if not found and h.kind == targetKind and math.abs(h.yTop - level) <= tol and (bar_index - h.bornBar) <= maxAge
                found := true
    int nh_ck = array.size(historyHunts)
    if not found and nh_ck > 0
        for j = 0 to nh_ck - 1 by 1
            HuntItem h2 = array.get(historyHunts, j)
            if not found and h2.kind == targetKind and math.abs(h2.yTop - level) <= tol and (bar_index - h2.bornBar) <= maxAge
                found := true
    found



// Cap retained history to avoid runaway draw counts on long charts.
int historyCap = 400
while array.size(historyHunts) > historyCap
    killHunt(array.shift(historyHunts))

countActiveByKindDir(string targetKind, int targetDir) =>
    int c = 0
    int n = array.size(activeHunts)
    if n > 0
        for i = 0 to n - 1 by 1
            HuntItem h = array.get(activeHunts, i)
            if h.kind == targetKind and h.dir == targetDir
                c := c + 1
    c

purgeOldestOfKindDir(string targetKind, int targetDir) =>
    int oldestIdx  = -1
    int oldestBorn = bar_index + 1
    int n = array.size(activeHunts)
    if n > 0
        for i = 0 to n - 1 by 1
            HuntItem h = array.get(activeHunts, i)
            if h.kind == targetKind and h.dir == targetDir and h.bornBar < oldestBorn
                oldestBorn := h.bornBar
                oldestIdx  := i
    if oldestIdx >= 0
        killHunt(array.get(activeHunts, oldestIdx))
        array.remove(activeHunts, oldestIdx)

bool signalFiringThisBar = bullTrigger or bearTrigger

// ─── Per-bar maintenance: invalidation, age expiry, right-edge extension ──
if huntingActive and confirmed and array.size(activeHunts) > 0
    int idx = 0
    while idx < array.size(activeHunts)
        HuntItem h = array.get(activeHunts, idx)
        bool kill  = false
        int  age   = bar_index - h.bornBar

        if not signalFiringThisBar
            if h.kind == 'liq'
                if h.dir == 1  and close > h.yTop
                    kill := true
                if h.dir == -1 and close < h.yBot
                    kill := true
            else if h.kind == 'ob'
                if h.dir == 1  and close < h.yBot
                    kill := true
                if h.dir == -1 and close > h.yTop
                    kill := true

        if not kill
            if h.kind == 'comp' and age > compAgeMax
                kill := true
            else if (h.kind == 'bos' or h.kind == 'reclaim' or h.kind == 'pivot' or h.kind == 'stop' or h.kind == 'sweep') and age > eventAgeMax
                kill := true

        if kill
            killHunt(h)
            array.remove(activeHunts, idx)
        else
            if (h.kind == 'liq' or h.kind == 'ob') and not na(h.b)
                box.set_right(h.b, bar_index + 1)
            idx := idx + 1

// ─── Buyside / Sellside Liquidity zones ───────────────────────────────────
if huntingActive and confirmed and sigSweep and showLiq and not na(pivH)
    if countActiveByKindDir('liq', 1) >= zoneCapEach
        purgeOldestOfKindDir('liq', 1)
    int   pivBar = bar_index - 3
    float yT     = pivH
    float yB     = pivH - atr * 0.08
    box   bx     = box.new(pivBar, yT, bar_index + 1, yB, bgcolor = cLiqBuy, border_color = color.new(#3D5AFE, 50), border_width = 1)
    array.push(activeHunts, newHunt(bx, na, na, 'Sweep', 'liq', yT, yB, 1, cLiqBuy))

if huntingActive and confirmed and sigSweep and showLiq and not na(pivL)
    if countActiveByKindDir('liq', -1) >= zoneCapEach
        purgeOldestOfKindDir('liq', -1)
    int   pivBar = bar_index - 3
    float yT     = pivL + atr * 0.08
    float yB     = pivL
    box   bx     = box.new(pivBar, yT, bar_index + 1, yB, bgcolor = cLiqSell, border_color = color.new(#00BFA5, 50), border_width = 1)
    array.push(activeHunts, newHunt(bx, na, na, 'Sweep', 'liq', yT, yB, -1, cLiqSell))

// ─── Order Blocks ─────────────────────────────────────────────────────────
if huntingActive and confirmed and sigOB and showOBv and impulseUp and close[1] < open[1]
    if countActiveByKindDir('ob', 1) >= obCapEach
        purgeOldestOfKindDir('ob', 1)
    float yT = high[1]
    float yB = low[1]
    box   bx = box.new(bar_index - 1, yT, bar_index + 1, yB, bgcolor = cOBbull, border_color = color.new(#00BFA5, 40), border_width = 1)
    array.push(activeHunts, newHunt(bx, na, na, 'OB', 'ob', yT, yB, 1, cOBbull))

if huntingActive and confirmed and sigOB and showOBv and impulseDn and close[1] > open[1]
    if countActiveByKindDir('ob', -1) >= obCapEach
        purgeOldestOfKindDir('ob', -1)
    float yT = high[1]
    float yB = low[1]
    box   bx = box.new(bar_index - 1, yT, bar_index + 1, yB, bgcolor = cOBbear, border_color = color.new(#FF5252, 40), border_width = 1)
    array.push(activeHunts, newHunt(bx, na, na, 'OB', 'ob', yT, yB, -1, cOBbear))

// ─── Compression bars ─────────────────────────────────────────────────────
bool isNarrowBar = barRange <= narrowestPrev and barRange > 0
if huntingActive and confirmed and sigExpand and showComp and isNarrowBar
    box bx = box.new(bar_index, high, bar_index + 1, low, bgcolor = cCompTone, border_color = color.new(#FFA000, 55), border_width = 1)
    array.push(activeHunts, newHunt(bx, na, na, 'Expand', 'comp', high, low, 0, cCompTone))

// ─── Stopping Volume triangles ────────────────────────────────────────────
bool stopCandidate = highVol and ((atLow_ and closeInTop) or (atHigh_ and closeInBot))
if huntingActive and confirmed and sigStop and showStop and stopCandidate
    float  yPos  = close >= (high + low) / 2 ? low - atr * 0.4 : high + atr * 0.4
    string styl_ = close >= (high + low) / 2 ? label.style_triangleup : label.style_triangledown
    label  lb    = label.new(bar_index, yPos, '', style = styl_, color = cStopDot, textcolor = color.new(#FFAB00, 0), size = size.tiny)
    array.push(activeHunts, newHunt(na, na, lb, 'Stop', 'stop', yPos, yPos, 0, na))

// ─── BOS / CHoCH event labels (deduped by level within eventAgeMax) ───────
if huntingActive and sigBOS and showBOS and bosBull and not hasRecentMarkerAtLevel('bos', lastSwingH, atr * 0.1, eventAgeMax)
    line  ln = line.new(bar_index - 5, lastSwingH, bar_index + 1, lastSwingH, color = color.new(#B0BEC5, 25), style = line.style_dashed, width = 1)
    label lb = label.new(bar_index - 2, lastSwingH, 'BOS', style = label.style_label_down, color = color.new(color.black, 100), textcolor = cBOStxt, size = size.tiny)
    array.push(activeHunts, newHunt(na, ln, lb, 'BOS', 'bos', lastSwingH, lastSwingH, 1, na))

if huntingActive and sigBOS and showBOS and bosBear and not hasRecentMarkerAtLevel('bos', lastSwingL, atr * 0.1, eventAgeMax)
    line  ln = line.new(bar_index - 5, lastSwingL, bar_index + 1, lastSwingL, color = color.new(#B0BEC5, 25), style = line.style_dashed, width = 1)
    label lb = label.new(bar_index - 2, lastSwingL, 'BOS', style = label.style_label_up, color = color.new(color.black, 100), textcolor = cBOStxt, size = size.tiny)
    array.push(activeHunts, newHunt(na, ln, lb, 'BOS', 'bos', lastSwingL, lastSwingL, -1, na))

// ─── Sweep markers (on the bar where price violated the last confirmed pivot) ──
if huntingActive and sigSweep and showReclaim and sweepHitHigh and not hasRecentMarkerAtLevel('sweep', lastSwingH, atr * 0.3, eventAgeMax)
    label lb = label.new(bar_index, high, 'Sweep', style = label.style_label_down, yloc = yloc.abovebar, color = color.new(color.black, 100), textcolor = cBOStxt, size = size.tiny)
    array.push(activeHunts, newHunt(na, na, lb, 'Sweep', 'sweep', lastSwingH, lastSwingH, -1, na))

if huntingActive and sigSweep and showReclaim and sweepHitLow and not hasRecentMarkerAtLevel('sweep', lastSwingL, atr * 0.3, eventAgeMax)
    label lb = label.new(bar_index, low, 'Sweep', style = label.style_label_up, yloc = yloc.belowbar, color = color.new(color.black, 100), textcolor = cBOStxt, size = size.tiny)
    array.push(activeHunts, newHunt(na, na, lb, 'Sweep', 'sweep', lastSwingL, lastSwingL, 1, na))

// ─── Reclaim event labels (deduped by level within eventAgeMax) ───────────
if huntingActive and sigSweep and showReclaim and sweepBull and not na(sweepLowLvl) and not hasRecentMarkerAtLevel('reclaim', sweepLowLvl, atr * 0.3, eventAgeMax)
    label lb = label.new(bar_index, low, 'Reclaim', style = label.style_label_up, yloc = yloc.belowbar, color = color.new(color.black, 100), textcolor = cBOStxt, size = size.tiny)
    array.push(activeHunts, newHunt(na, na, lb, 'Sweep', 'reclaim', sweepLowLvl, sweepLowLvl, 1, na))

if huntingActive and sigSweep and showReclaim and sweepBear and not na(sweepHighLvl) and not hasRecentMarkerAtLevel('reclaim', sweepHighLvl, atr * 0.3, eventAgeMax)
    label lb = label.new(bar_index, high, 'Reclaim', style = label.style_label_down, yloc = yloc.abovebar, color = color.new(color.black, 100), textcolor = cBOStxt, size = size.tiny)
    array.push(activeHunts, newHunt(na, na, lb, 'Sweep', 'reclaim', sweepHighLvl, sweepHighLvl, -1, na))

// ─── HH / HL / LH / LL pivots ─────────────────────────────────────────────
// Pivot labels are state-driven. State (prevHigh / prevLow) updates on every
// confirmed pivot regardless of hunting gate, so labels stay correct even
// when hunting is paused during an active trade.
var float prevHigh = na
var float prevLow  = na


string pivHTxt = na
string pivLTxt = na
if confirmed and not na(pivH)
    pivHTxt  := na(prevHigh) ? 'HH' : pivH > prevHigh ? 'HH' : 'LH'
    prevHigh := pivH
if confirmed and not na(pivL)
    pivLTxt  := na(prevLow) ? 'LL' : pivL < prevLow ? 'LL' : 'HL'
    prevLow  := pivL

if huntingActive and confirmed and showPivots and not na(pivH)
    label lb = label.new(bar_index - 3, pivH, pivHTxt, style = label.style_label_down, color = color.new(color.black, 100), textcolor = cPivot, size = size.tiny, yloc = yloc.abovebar)
    array.push(activeHunts, newHunt(na, na, lb, 'Pivot', 'pivot', pivH, pivH, 1, na))

if huntingActive and confirmed and showPivots and not na(pivL)
    label lb = label.new(bar_index - 3, pivL, pivLTxt, style = label.style_label_up, color = color.new(color.black, 100), textcolor = cPivot, size = size.tiny, yloc = yloc.belowbar)
    array.push(activeHunts, newHunt(na, na, lb, 'Pivot', 'pivot', pivL, pivL, -1, na))

// ─── Signal-fire reconciliation: promote contributors, wipe the rest ──────
// On signal fire each active hunting item is evaluated for two reasons it
// might survive into history:
//   1. isFiring  - its pattern is one of the ones that triggered the signal
//   2. isContext - for liquidity & OB zones: located inside the trade's
//                  expected price path AND structurally aligned (e.g. an
//                  opposing liquidity pool sitting ahead of the trade is
//                  contextual; a same-side OB before the entry is contextual)
if bullTrigger or bearTrigger
    array<string> firing = array.new<string>()
    bool sw_ = bullTrigger ? sweepBullF  : sweepBearF
    bool st_ = bullTrigger ? stopBullF   : stopBearF
    bool ex_ = bullTrigger ? expandBullF : expandBearF
    bool bo_ = bullTrigger ? bosBullF    : bosBearF
    bool ob_ = bullTrigger ? obBullF     : obBearF
    if sw_
        array.push(firing, 'Sweep')
    if st_
        array.push(firing, 'Stop')
    if ex_
        array.push(firing, 'Expand')
    if bo_
        array.push(firing, 'BOS')
    if ob_
        array.push(firing, 'OB')

    color sigDirCol = bullTrigger ? cBull : cBear

    if bullTrigger and bosBullF and showBOS and not na(lastSwingH) and not hasRecentMarkerAtLevel('bos', lastSwingH, atr * 0.1, eventAgeMax)
        line  bosLn = line.new(bar_index - 5, lastSwingH, bar_index + 1, lastSwingH, color = sigDirCol, style = line.style_dashed, width = 2)
        label bosLb = label.new(bar_index - 2, lastSwingH, 'BOS', style = label.style_label_down, color = color.new(color.black, 100), textcolor = sigDirCol, size = size.tiny)
        array.push(historyHunts, HuntItem.new(na, bosLn, bosLb, 'BOS', 'bos', bar_index, lastSwingH, lastSwingH, 1, na))
    if bearTrigger and bosBearF and showBOS and not na(lastSwingL) and not hasRecentMarkerAtLevel('bos', lastSwingL, atr * 0.1, eventAgeMax)
        line  bosLn = line.new(bar_index - 5, lastSwingL, bar_index + 1, lastSwingL, color = sigDirCol, style = line.style_dashed, width = 2)
        label bosLb = label.new(bar_index - 2, lastSwingL, 'BOS', style = label.style_label_up, color = color.new(color.black, 100), textcolor = sigDirCol, size = size.tiny)
        array.push(historyHunts, HuntItem.new(na, bosLn, bosLb, 'BOS', 'bos', bar_index, lastSwingL, lastSwingL, -1, na))
    if bullTrigger and sweepBullF and showReclaim and not na(sweepLowLvl)
        label rcLb = label.new(bar_index, low, 'Reclaim', style = label.style_label_up, yloc = yloc.belowbar, color = color.new(color.black, 100), textcolor = sigDirCol, size = size.tiny)
        array.push(historyHunts, HuntItem.new(na, na, rcLb, 'Sweep', 'reclaim', bar_index, sweepLowLvl, sweepLowLvl, 1, na))
    if bearTrigger and sweepBearF and showReclaim and not na(sweepHighLvl)
        label rcLb = label.new(bar_index, high, 'Reclaim', style = label.style_label_down, yloc = yloc.abovebar, color = color.new(color.black, 100), textcolor = sigDirCol, size = size.tiny)
        array.push(historyHunts, HuntItem.new(na, na, rcLb, 'Sweep', 'reclaim', bar_index, sweepHighLvl, sweepHighLvl, -1, na))

    float tradeRange = math.abs(ref2Px - invalPx)

    float pathTop    = bullTrigger ? ref2Px + tradeRange : invalPx
    float pathBot    = bullTrigger ? invalPx             : ref2Px - tradeRange
    float entryRef   = entryPx

    int fi = 0
    while fi < array.size(activeHunts)
        HuntItem h = array.get(activeHunts, fi)
        bool isFiring = array.includes(firing, h.pattern)

        bool isContext = false
        if h.kind == 'liq' or h.kind == 'ob'
            float zoneMid = (h.yTop + h.yBot) / 2
            bool  inPath  = zoneMid >= pathBot and zoneMid <= pathTop
            bool  dirOk   = false
            if bullTrigger
                if zoneMid < entryRef
                    dirOk := (h.kind == 'liq' and h.dir == -1) or (h.kind == 'ob' and h.dir == 1)
                else
                    dirOk := (h.kind == 'liq' and h.dir == 1)  or (h.kind == 'ob' and h.dir == -1)
            else
                if zoneMid > entryRef
                    dirOk := (h.kind == 'liq' and h.dir == 1)  or (h.kind == 'ob' and h.dir == -1)
                else
                    dirOk := (h.kind == 'liq' and h.dir == -1) or (h.kind == 'ob' and h.dir == 1)
            isContext := inPath and dirOk

        if h.kind == 'pivot'
            float pivTol = atr * 0.5
            bool  nearBOS = bullTrigger and bosBullF and not na(lastSwingH) and math.abs(h.yTop - lastSwingH) <= pivTol
            nearBOS := nearBOS or (bearTrigger and bosBearF and not na(lastSwingL) and math.abs(h.yTop - lastSwingL) <= pivTol)
            bool  nearSweep = bullTrigger and sweepBullF and not na(sweepLowLvl) and math.abs(h.yTop - sweepLowLvl) <= pivTol
            nearSweep := nearSweep or (bearTrigger and sweepBearF and not na(sweepHighLvl) and math.abs(h.yTop - sweepHighLvl) <= pivTol)
            isContext := nearBOS or nearSweep

        if isFiring or isContext
            if not na(h.b)
                box.set_right(h.b, math.max(h.bornBar + 1, bar_index))
            if isFiring
                if not na(h.b) and not na(h.fillCol)
                    box.set_border_color(h.b, sigDirCol)
                    box.set_border_width(h.b, 2)
                    box.set_bgcolor(h.b, color.new(color.rgb(color.r(h.fillCol), color.g(h.fillCol), color.b(h.fillCol)), 45))
                if not na(h.l)
                    line.set_color(h.l, sigDirCol)
                    line.set_width(h.l, 2)
                if not na(h.lb)
                    label.set_textcolor(h.lb, sigDirCol)
            array.push(historyHunts, h)
        else
            killHunt(h)
        fi := fi + 1
    array.clear(activeHunts)


// ════════════════════════════════════════════════════════════════════════════
// SECTION 13 - COLOR LEGEND
// Bottom-right reference panel for visual element identification.
// ════════════════════════════════════════════════════════════════════════════

var table legend = na

if barstate.islast and showLegend
    table.delete(legend)
    legend := table.new(position.bottom_right, 2, 9, bgcolor = color.new(#263238, 12), border_width = 1, border_color = color.new(#546E7A, 45), frame_color = color.new(#546E7A, 30), frame_width = 1)

    color titleC = color.new(#FFFFFF, 0)
    color softC  = color.new(#B0BEC5, 0)

    table.cell(legend, 0, 0, 'ICT Legend', text_color = titleC, text_size = size.small, bgcolor = color.new(#3D5AFE, 35), text_halign = text.align_center)
    table.cell(legend, 1, 0, '',           bgcolor = color.new(#3D5AFE, 35))

    table.cell(legend, 0, 1, 'Buyside Liquidity',   text_color = softC, text_size = size.tiny,   text_halign = text.align_left)
    table.cell(legend, 1, 1, '█',                   text_color = color.new(#3D5AFE, 30), text_size = size.normal, text_halign = text.align_center)

    table.cell(legend, 0, 2, 'Sellside Liquidity',  text_color = softC, text_size = size.tiny,   text_halign = text.align_left)
    table.cell(legend, 1, 2, '█',                   text_color = color.new(#00BFA5, 30), text_size = size.normal, text_halign = text.align_center)

    table.cell(legend, 0, 3, 'Bullish Order Block', text_color = softC, text_size = size.tiny,   text_halign = text.align_left)
    table.cell(legend, 1, 3, '█',                   text_color = color.new(#00BFA5, 50), text_size = size.normal, text_halign = text.align_center)

    table.cell(legend, 0, 4, 'Bearish Order Block', text_color = softC, text_size = size.tiny,   text_halign = text.align_left)
    table.cell(legend, 1, 4, '█',                   text_color = color.new(#FF5252, 50), text_size = size.normal, text_halign = text.align_center)

    table.cell(legend, 0, 5, 'Compression',         text_color = softC, text_size = size.tiny,   text_halign = text.align_left)
    table.cell(legend, 1, 5, '█',                   text_color = color.new(#FFA000, 40), text_size = size.normal, text_halign = text.align_center)

    table.cell(legend, 0, 6, 'Stopping Volume',     text_color = softC, text_size = size.tiny,   text_halign = text.align_left)
    table.cell(legend, 1, 6, '▲',                   text_color = color.new(#FFAB00, 0),  text_size = size.small,  text_halign = text.align_center)

    table.cell(legend, 0, 7, 'BOS / Sweep / Reclaim', text_color = softC, text_size = size.tiny,   text_halign = text.align_left)
    table.cell(legend, 1, 7, 'BOS',                   text_color = color.new(#ECEFF1, 0),  text_size = size.tiny,   text_halign = text.align_center)

    table.cell(legend, 0, 8, 'HH/HL/LH/LL Pivots',  text_color = softC, text_size = size.tiny,   text_halign = text.align_left)
    table.cell(legend, 1, 8, 'HH',                  text_color = color.new(#90A4AE, 0),  text_size = size.tiny,   text_halign = text.align_center)
````
