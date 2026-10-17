# TPrecision MARKET PULSE  Read the Energy, Not the Direction

- url: https://www.tradingview.com/script/O19SgyAh-TPrecision-MARKET-PULSE-Read-the-Energy-Not-the-Direction/
- type: indicator
- pine_id: PUB;b951975b57b4458d9b7574c82ce92180
- version: 2.0

## Description

Here's the full TradingView description text, ready to paste:

MARKET PULSE — Read the Energy, Not the Direction
Every indicator you've ever used tells you the same thing: which way price might go. RSI, MACD, stochastics — they're all measuring direction in different ways. Market Pulse does something fundamentally different. It measures the energy state of the market — the rhythm underneath price that exists before any move happens.
The concept is simple: markets breathe. Before every significant move, price compresses — ranges tighten, candles shrink, volatility collapses inward. The market is inhaling. Then it exhales. Price erupts, ranges expand, energy releases. Market Pulse makes that cycle visible in real time across four components stacked in a single clean pane.

BREATH (top section — blue/amber line)
This is the core reading. True range normalized against its own long-term average, so 1.0 always means "normal." When the line drops below the blue band (0.7), the market is compressing — inhaling, coiling, building potential energy. When it rises above the amber band (1.3), the market is expanding — exhaling, releasing, moving with conviction. A breath line that stays flat and low for many consecutive bars is the most important signal this indicator produces. That is a spring being loaded.

RHYTHM (middle section — green/red histogram)
Rhythm measures the rate of change of breath. Are we expanding faster than we were, or compressing faster? Green bars above the midline mean expansion is accelerating — the exhale is gaining momentum. Red bars below mean compression is deepening — the coil is getting tighter. The most powerful moment is when rhythm crosses from red to green after a prolonged compression period. That is the first sign the exhale has begun.

TENSION (bottom section — gradient fill)
Every bar that breath spends below 1.0 (below-normal range) accumulates tension. The fill builds from blue to amber as pressure increases. High tension means the spring has been coiled for a long time and release is statistically overdue. Tension does not decay instantly — it bleeds out slowly on expansion bars, reflecting how energy releases gradually after a long coil. When tension is at its peak and breath is still compressed, you are looking at maximum potential energy in the market.

PULSE RATE (dotted circles — overlay on breath section)
This tracks the average interval between breath peaks — how fast energy cycles are completing. When the dots are high, cycles are churning quickly (active, volatile market). When dots drop, cycles are slowing down. A decelerating pulse rate often precedes market exhaustion, regime change, or a significant transition in character. It is the one component that operates on a longer timescale than the others.

BACKGROUND ALERTS
🔵Blue background tint — Tension above 75% AND breath compressed below 0.7. The coil is tight. Maximum potential energy. The market is wound up.
🟠Amber background tint — Breath above 1.3 AND rhythm positive. Active release in progress. Energy is being deployed.

HOW TO USE IT
This indicator does not tell you to buy or sell. It tells you what state the market is in so you can make better decisions with whatever strategy you already use.

Use it to avoid trading in the wrong state — entering a trend trade during deep compression usually means getting chopped. Entering a range trade during active expansion means getting run over.
Use it to time entries on your existing signals — a buy signal that fires while tension is at extreme highs and breath is turning up is a very different trade than the same signal firing in a neutral state.
Use it to identify when something is about to happen — not what, but when the energy conditions are right for a significant move.
Use it across timeframes — compression on the daily while expansion fires on the 4H often means a powerful intraday move within a larger coiling structure.


SETTINGS
Base Period (default 20) — The lookback for ATR and breath calculation. Higher values = smoother, slower readings. Lower = more reactive.
Smoothing (default 5) — Applied to all components. Increase to reduce noise on lower timeframes.
Tension Lookback (default 50) — How far back tension and rhythm normalize themselves. Higher = tension builds more slowly, more selective extremes.
Pulse Rate Period (default 10) — How many breath cycles to average for the pulse rate calculation.

WORKS ON
All markets (Forex, Crypto, Equities, Futures, Indices) — All timeframes — Pine Script v6

This is not a signal generator. It is a market state reader. Learn the rhythm before you trade the move.

👉 Join the community, ask questions, share setups: discord.gg/8H4qdBDaEu

## Source Code

````pine
//@version=6
indicator("Market Pulse", shorttitle="PULSE", overlay=false, max_lines_count=0, max_labels_count=0)

// ═══════════════════════════════════════════════════════════════
//  MARKET PULSE
//
//  Concept: Price moves in cycles of compression and expansion.
//  Before every big move, the market "inhales" — ranges tighten,
//  candles shrink, volatility collapses. Then it "exhales" —
//  price erupts in one direction with conviction.
//
//  This indicator does NOT predict direction. It measures:
//    1. BREATH  — how compressed or expanded the market is right now
//    2. RHYTHM  — is compression/expansion accelerating or decelerating
//    3. TENSION — how long the market has been coiling (energy buildup)
//    4. PULSE RATE — the speed of recent energy cycles
//
//  Reading it:
//    • Flat low BREATH → coiling, potential energy building
//    • BREATH spiking upward → expansion/exhale phase
//    • RHYTHM crossing up from below zero → new expansion beginning
//    • TENSION at extremes → overdue for release (not direction)
//    • PULSE RATE slowing → market exhaustion / transition incoming
// ═══════════════════════════════════════════════════════════════

// ─── SETTINGS ────────────────────────────────────────────────
len         = input.int(20,   "Base Period",        minval=5,  maxval=100)
smoothing   = input.int(5,    "Smoothing",          minval=1,  maxval=20)
tensionLen  = input.int(50,   "Tension Lookback",   minval=20, maxval=200)
pulseLen    = input.int(10,   "Pulse Rate Period",  minval=3,  maxval=30)

// ─── COMPONENT 1: BREATH ─────────────────────────────────────
// True range normalized by ATR baseline — 1.0 = "normal" breathing
// Below 0.7 = compression (inhale), Above 1.3 = expansion (exhale)
atr         = ta.atr(len)
atrBaseline = ta.sma(atr, len * 3)
breath      = ta.sma(atr / atrBaseline, smoothing)

// ─── COMPONENT 2: RHYTHM ─────────────────────────────────────
// Rate of change of breath — are we expanding or compressing faster?
// Positive = expanding phase, Negative = compressing phase
rhythmRaw   = breath - breath[len]
rhythm      = ta.sma(rhythmRaw, smoothing)

// Normalize rhythm to -1 … +1 range over lookback
rhythmHigh  = ta.highest(rhythm, tensionLen)
rhythmLow   = ta.lowest(rhythm, tensionLen)
rhythmRange = rhythmHigh - rhythmLow
rhythmNorm  = rhythmRange > 0 ? (rhythm - rhythmLow) / rhythmRange * 2 - 1 : 0.0

// ─── COMPONENT 3: TENSION ────────────────────────────────────
// How long has the market been compressing continuously?
// Counts consecutive bars where breath < 1.0 (below-normal range)
// When tension is high, the spring is coiled — release is overdue
var float tension     = 0.0
var float tensionPeak = 0.0
isCompressing = breath < 1.0

if isCompressing
    tension := tension + (1.0 - breath)   // accumulate deficit vs normal
else
    tension := tension * 0.85             // decay on release (exponential bleed)

tensionPeak := ta.highest(tension, tensionLen)
tensionNorm  = tensionPeak > 0 ? math.min(tension / tensionPeak, 1.0) : 0.0

// ─── COMPONENT 4: PULSE RATE ─────────────────────────────────
// How fast are breath cycles completing?
// We count how many bars between breath peaks — longer = slower pulse
// Slow pulse = market exhausted / transitioning
// Fast pulse = active / volatile cycles churning

// Detect breath "peaks" (local maxima where breath > 1.0)
isPeak      = breath > 1.0 and breath > breath[1] and breath > breath[2] and breath[1] > breath[2]
var int     lastPeakBar = 0
var float   pulseRate   = 0.0
var float   pulseSum    = 0.0
var int     pulseCount  = 0

if isPeak
    if lastPeakBar > 0
        interval    = bar_index - lastPeakBar
        pulseSum   := pulseSum + interval
        pulseCount := pulseCount + 1
        if pulseCount > pulseLen
            pulseSum   := pulseSum - pulseSum / pulseCount
            pulseCount := pulseLen
        pulseRate := pulseCount > 0 ? pulseSum / pulseCount : 0.0
    lastPeakBar := bar_index

// Normalize: shorter interval = faster pulse = higher value
pulseRateSmooth = ta.sma(pulseRate, smoothing * 2)
pulseHigh       = ta.highest(pulseRateSmooth, tensionLen)
pulseLow        = ta.lowest(pulseRateSmooth, tensionLen)
pulseNorm       = pulseHigh > pulseLow and pulseHigh > 0 ?
     1.0 - (pulseRateSmooth - pulseLow) / (pulseHigh - pulseLow) : 0.5

// ─── BREATH ZONES ────────────────────────────────────────────
compressionZone = 0.7
expansionZone   = 1.3

// ─── COLORS ──────────────────────────────────────────────────
// Breath: blue=inhale(compression) → amber=exhale(expansion)
breathCol   = breath < compressionZone ? color.new(#4a9edd, 0) :
              breath > expansionZone   ? color.new(#e8932a, 0) :
                                         color.new(#888888, 40)

// Rhythm: green=expanding, red=compressing
rhythmCol   = rhythm > 0 ? color.new(#5db87a, 20) : color.new(#e05c5c, 20)

// Tension fill (builds up like pressure)
tensionCol  = color.from_gradient(tensionNorm, 0, 1,
              color.new(#4a9edd, 85),
              color.new(#e8932a, 50))

// ─── PANE LAYOUT ─────────────────────────────────────────────
// We draw 4 sub-sections in one pane using offset scaling:
//   Top    (2.0–3.0):  Breath line
//   Mid-hi (1.0–2.0):  Rhythm histogram
//   Mid-lo (0.0–1.0):  Tension fill
//   (Pulse rate displayed as line overlay on breath section)

BREATH_BASE  = 2.5
RHYTHM_BASE  = 1.5
TENSION_BASE = 0.5

// Breath (centered at 2.5, scaled so 1.0 normal = mid)
breathPlot  = BREATH_BASE + (breath - 1.0) * 0.5
breathUpper = BREATH_BASE + (expansionZone   - 1.0) * 0.5
breathLower = BREATH_BASE + (compressionZone - 1.0) * 0.5
breathMid   = BREATH_BASE + 0.0

// Rhythm (centered at 1.5)
rhythmPlot  = RHYTHM_BASE + rhythmNorm * 0.4

// Tension (scaled from 0 to 1.0 section: 0.0–1.0)
tensionPlot = TENSION_BASE + tensionNorm * 0.45

// Pulse rate (shown as a slow overlay on the breath section)
pulsePlot   = BREATH_BASE + (pulseNorm - 0.5) * 0.6

// ─── SEPARATOR LINES ─────────────────────────────────────────
sepColor    = color.new(color.gray, 80)
plot(2.0, color=sepColor, linewidth=1, style=plot.style_line, title="Separator 1")
plot(1.0, color=sepColor, linewidth=1, style=plot.style_line, title="Separator 2")

// ─── BREATH ZONE BANDS ───────────────────────────────────────
breathUpperLine = plot(breathUpper, color=color.new(#e8932a, 75), linewidth=1, style=plot.style_line, title="Expansion threshold")
breathLowerLine = plot(breathLower, color=color.new(#4a9edd, 75), linewidth=1, style=plot.style_line, title="Compression threshold")
breathMidLine   = plot(breathMid,   color=color.new(color.gray, 85), linewidth=1, style=plot.style_line, title="Normal breath")

// ─── TENSION FILL (bottom section) ───────────────────────────
tensionBase = plot(TENSION_BASE, color=color.new(color.gray, 100), display=display.none, title="Tension base")
tensionLine = plot(tensionPlot,  color=tensionCol, linewidth=2, style=plot.style_line, title="Tension")
fill(tensionBase, tensionLine, color=tensionCol, title="Tension fill")

// ─── RHYTHM HISTOGRAM (middle section) ───────────────────────
rhythmBaseLine = plot(RHYTHM_BASE, color=color.new(color.gray, 100), display=display.none, title="Rhythm base")
rhythmLine     = plot(rhythmPlot,  color=rhythmCol,  linewidth=1, style=plot.style_line, title="Rhythm")
fill(rhythmBaseLine, rhythmLine, color=color.new(rhythmCol, 60), title="Rhythm fill")

// ─── BREATH LINE (top section) ───────────────────────────────
plot(breathPlot, color=breathCol, linewidth=2, style=plot.style_line, title="Breath")

// ─── PULSE RATE (dotted overlay on breath section) ───────────
plot(pulsePlot, color=color.new(color.white, 55), linewidth=1, style=plot.style_circles, title="Pulse rate")

// ─── COIL ALERT: Background flash when tension peaks + breath lowest ──
isCoiling    = tensionNorm > 0.75 and breath < compressionZone
isReleasing  = breath > expansionZone and rhythm > 0
bgcolor(isCoiling   ? color.new(#4a9edd, 92) : na, title="Coiling alert")
bgcolor(isReleasing ? color.new(#e8932a, 92) : na, title="Release alert")

// ─── LABELS (data window only) ────────────────────────────────
plot(breath,      "Breath raw",     display=display.data_window)
plot(rhythmNorm,  "Rhythm norm",    display=display.data_window)
plot(tensionNorm, "Tension norm",   display=display.data_window)
plot(pulseNorm,   "Pulse rate",     display=display.data_window)
````
