# Phase Exhaustion Reversal [BullByte]

- url: https://www.tradingview.com/script/XMXlfzMW-Phase-Exhaustion-Reversal-BullByte/
- type: indicator
- pine_id: PUB;19cf9554dbfa425fa374ad82769a284f
- version: 2.0

## Description

[b]Phase Exhaustion Reversal (PXR)[/b] is an intraday reversal engine that measures one specific market phenomenon: the moment a short-horizon directional burst exhausts itself against a broader structural gradient. It is built on a single mathematical primitive - directional efficiency - applied at two horizons, and turns the gap between them into an exhaustion-detection framework.

This is not a mashup of existing indicators. The entire engine is derived from one calculation family: how cleanly price travels over a window. The regime classifier, the signal trigger, the risk engine, and the dashboard are all layers of that single concept rather than separate components.

---

[b]Why This Indicator Exists[/b]

Most reversal tools fire on oscillator extremes or candlestick patterns. They answer the question [b]"is price stretched?"[/b] but not [b]"has the energy actually run out?[/b]" A market can stay stretched for a long time before reverting. PXR was built to answer a more precise question: when has a short-horizon momentum burst exhausted its energy against the prevailing structural direction? That moment - the exhaustion-and-recede - is what PXR isolates.

The phenomenon being studied can be observed on historical price data.

When price moves with high short-horizon efficiency in a direction that contradicts the medium-horizon efficiency gradient, that move is consuming energy faster than structure supports. Such bursts can appear to exhaust and then realign with the broader gradient on historical data. PXR visualizes that potential realignment as an observation worth studying.

---

[b]Why a Trader Might Use It[/b]

Intraday traders on 5-minute and 15-minute charts frequently face counter-trend bursts that look like reversals but are actually just temporary dislocations. PXR offers a structured way to read those bursts: it waits for the burst to peak, confirms the peak has begun receding, and only then marks the realignment as armed. The next-bar open execution model means the entry price on the chart matches what a real-time observer could actually have achieved.

PXR is designed for traders who want a single coherent reading of market state - regime, bias, setup progression, and signal - rather than juggling multiple unrelated indicators.

---

[b]The Concept[/b]

Imagine price as a hiker walking through terrain. Two things can be measured about that hiker over any window of time:

[b]One[/b] - how far they ended up from where they started. This is transport.

[b]Two [/b]- how much total ground they covered while getting there. This is agitation.

The ratio of transport to agitation is efficiency. If a hiker walked 100 meters in a straight line, transport equals agitation, and efficiency is 1.0 - perfectly directional. If a hiker zigzagged 500 meters total but ended up only 100 meters away, efficiency is 0.2 - most of the energy was wasted on the zigzag.

[b]PXR computes this efficiency at two horizons simultaneously.[/b] The short horizon (around 35 minutes of bars, regardless of timeframe, by default) captures reactive bursts. The medium horizon (around 2 hours of bars by default) captures the structural gradient - the broader direction price is actually flowing in.

When the short-horizon efficiency spikes far from the medium-horizon efficiency, the two have dislocated. PXR normalizes this dislocation into a value called the Phase Gap. When the Phase Gap stretches to an extreme and then begins to recede, the short-horizon burst is exhausting. If the medium-horizon gradient points the opposite direction at that moment, PXR marks a realignment signal - the observed behavior is a possible realignment with the structural gradient.

---

[b]What Makes This Different From a Standard Momentum Tool[/b]

Three architectural choices separate PXR from typical oscillator-based reversal tools.

[b]First, the use of two-horizon efficiency phase-gap normalization. [/b]The raw difference between two efficiency readings is rescaled by its own rolling maximum so the threshold stays meaningful across all volatility regimes. A 0.6 reading means the same thing on a quiet day as on a volatile one.

[b]Second, regime-conditional adaptive thresholds. [/b]The signal threshold is not a fixed constant. It adapts based on whether the market is currently classified as Extended (clean trend), Compressed (range), Transitioning (regime shifting), or Neutral. Each regime gets a different sensitivity, and each timeframe gets its own scaling on top of that.

[b]Third, an exhaustion-and-recede state machine gated by structural gradient sign.[/b] The signal does not fire when the Phase Gap simply crosses a level. It fires only when the gap has first reached a qualified peak and then receded by a meaningful fraction of that peak - confirming exhaustion has begun - and only when that exhaustion direction opposes the sign of the medium-horizon efficiency. This is a directional fade of short-horizon energy against the prevailing structural gradient.

---

[b]Mathematical Foundation[/b]

The script is built from three primitive calculations. All other logic flows from these.

[b]Transport[/b] over n bars equals close minus close n bars ago. This measures net displacement.

[b]Agitation[/b] over n bars equals the sum of absolute bar-to-bar price changes across that window. This measures total path length.

[b]Efficiency[/b] over n bars equals transport divided by agitation. This produces a signed value bounded between -1 and +1. Positive values indicate net upward directional purity, negative values indicate net downward directional purity, and values near zero indicate chop.

The [b]Phase Gap[/b] is the short-horizon efficiency minus the medium-horizon efficiency, divided by the rolling maximum of the absolute raw gap. This normalization keeps the Phase Gap roughly within plus or minus one regardless of market conditions.

A [b]realignment signal[/b] fires when the Phase Gap has peaked beyond a regime-adjusted threshold and then receded by a meaningful fraction of that peak, AND the sign of the medium-horizon efficiency points in the direction opposite to the burst that just exhausted.

This calculation family is conceptually related to efficiency-ratio style measurements. PXR's originality lies in the multi-horizon phase-gap construction, the regime-adaptive thresholding, and the exhaustion-and-recede state machine. 

---

[b]Recommended Timeframes and Markets[/b]

PXR is built for intraday operation. The timeframe-adaptive logic is tuned for [b]1-minute through 15-minute charts.[/b] The default Auto-Scale setting recalibrates the horizons so the same physical time window of analysis is used regardless of timeframe.

The phenomenon PXR studies appears most cleanly on liquid intraday instruments. Crypto majors such as [b]BTCUSDT [/b]and [b]ETHUSDT [/b]on 5-minute and 15-minute charts work well because crypto exhibits meaningful path tortuosity - the agitation-to-transport ratio carries real information. Index futures such as [b]NQ and ES[/b] on 5-minute and 15-minute charts also work, though session boundaries can affect the normalization window on overnight sessions.

PXR is built for intraday use. Higher timeframes such as 1H, 4H, or daily may behave differently because the regime thresholds and recede fractions are tuned for intraday energy cycles rather than multi-day structural shifts.


---

[b]Chart Examples[/b]

The two examples below are illustrative historical signals chosen to show the engine's mechanics and visual elements. They are not representative of typical or expected outcomes. Many signals fail and reach the INVALIDATION level instead. These examples are educational only.

[b]1. Example - Bull Realignment on BTCUSDT 15m[/b]

The annotated chart shows a complete PXR realignment cycle.

[image]https://www.tradingview.com/x/5P8c0eQf/[/image]

Price experienced a sharp [b]short-horizon bearish burst[/b] from roughly 77,650 down to 76,150. During this drop, the [b]medium-horizon efficiency gradient remained bullish[/b] - the slower 24-bar window still carried the structural upward bias from earlier hours. The yellow diagonal line traces this bullish medium-horizon gradient that the bearish burst was working against.

At the bottom of the move, the [b]Phase Gap reached its negative peak[/b]. The bearish burst's energy was fully spent. The yellow rectangle marks the exhaustion zone where two indecision candles stalled the fall.

Beginning shortly after, the Phase Gap began receding from its negative peak. Once it had receded by the configured fraction, the exhaustion-and-recede condition was satisfied. The medium-horizon efficiency was still positive, so the structural gradient gate qualified the direction. The state machine flipped upward and the signal armed on the close of the trigger bar.

On the next bar, the entry executed at the open at 76,410. The four rails drew automatically -[b] INVALIDATION at 75,982, TARGET 1 at 76,923, TARGET 2 at 77,351.[/b]

In this illustrative example, the price moved upward after the signal and later reached TARGET 1 and TARGET 2. This is one historical instance only. Outcomes vary, and many signals reach the INVALIDATION level instead.


[b]2. Example - Bear Realignment and Engine[/b]

This chart illustrates three aspects of PXR that complement the phenomenon view.

[image]https://www.tradingview.com/x/WPDoyn2q/[/image]

First, the engine is bidirectional. The red downward callout marks a BEAR realignment signal. A [b]short-horizon bullish burst pushed price upward[/b] over several hours. When that burst exhausted near 77,400, the [b]Phase Gap reached its positive peak[/b]. As the gap began receding and the medium-horizon gradient pointed bearish, the exhaustion-and-recede condition triggered a [b]BEAR signal[/b]. The four rails drew at INVALIDATION 77,465, ENTRY 76,765, TARGET 1 75,925, and TARGET 2 75,226.

Second, the [b]regime ribbon[/b] is visible across the background. Subtle orange tints mark [b]COMPRESSED [/b]periods where both efficiencies are low and the market is consolidating. Subtle cyan tints mark [b]TRANSITIONING [/b]periods where the Phase Gap has stretched far and a regime shift is underway. These background colors give an at-a-glance read of market state without requiring a glance at the dashboard.

Third, the live dashboard in the top-right shows engine state in real time. State, Setup, Bias, Phase Gap, and Last all update on every bar. The five-line legend overlay explains what each field represents. At the moment of this screenshot, the BEAR signal was Triggered, the regime was [b]COMPRESSED[/b], and the Phase Gap reading was -0.07 - a sign the dislocation had largely normalized after the signal fired.

Together with the dashboard and regime ribbon, the engine provides a continuous reading of market state - not just point-in-time signals, but a live framework that contextualizes each signal as it forms.

---

[b]How to Read the Chart[/b]

PXR draws several elements. Each one represents something specific.

The [b]PHASE EXHAUSTION[/b] label, marked with an upward or downward arrow, appears at the bar where the signal arms. An upward arrow with the text "[b]Realign Up[/b]" means a [b]short-horizon bearish burst has exhausted against a bullish gradient[/b], and the studied behavior is upward realignment. A downward arrow means the opposite. The label is anchored outside the bar's price extreme so it does not clash with other chart elements.

The [b]ENTRY rail[/b] is a dashed line drawn at the open of the bar immediately after the signal armed. This is the reference entry level. The script does not place orders - it visualizes the reference level a real-time user could have acted on.

The [b]INVALIDATION rail[/b] is a solid red line. If price reaches this level, the realignment thesis is rejected. This level is calculated as the worse of two values: a structural swing high or low with an ATR buffer, or a minimum ATR-floored distance from entry. Whichever is further from entry is used. This guarantees the invalidation level is never crammed inside short-term noise.

The [b]TARGET 1[/b] and [b]TARGET 2 rails[/b] are teal solid lines placed at user-configurable R-multiples of the invalidation distance. These represent profit objectives. The defaults are 1.2R and 2.2R, which can be modified in the Risk Settings group.

All four rails extend forward bar by bar while the trade is conceptually active, and their labels trail slightly ahead of the live bar so they remain visible at the right edge of the chart.

The [b]regime ribbon[/b] is a subtle background tint. Red indicates an Extended regime, orange indicates Compressed, cyan indicates Transitioning, and faint grey indicates Neutral. The ribbon helps users see at a glance which regime the engine currently classifies the market in.

The [b]active tint[/b] colors bars green during an active long observation and red during an active short observation. This is purely visual and can be toggled off.

---

[b]How to Read the Dashboard[/b]

The dashboard sits in the top-right of the chart and shows six live readings.

[b]State[/b] shows the current regime classification. [b]Extended [/b]means the medium-horizon efficiency is high - the market has a clean directional gradient. [b]Compressed [/b]means both efficiencies are low - the market is ranging. [b]Transitioning [/b]means the Phase Gap has stretched far - a regime change is in progress. [b]Neutral [/b]means none of the above.

[b]Setup[/b] shows the realignment setup progress. [b]No Setup[/b] means nothing is forming. [b]Forming [/b]means the Phase Gap has reached 60 percent of the threshold. [b]Watching[/b] means the Phase Gap has reached 85 percent of the threshold - a setup is building but no signal has fired yet. [b]Armed [/b]means a confirmed signal has fired and is awaiting next-bar execution. [b]Triggered [/b]means a trade observation is currently active.

[b]Bias[/b] shows the direction of the medium-horizon efficiency gradient. [b]BULL [/b]means the structural gradient points up. [b]BEAR [/b]means it points down. A dash means it is neutral.

[b]Phase Gap[/b] shows the live normalized Phase Gap value, roughly bounded within plus or minus one. The color brightens when the absolute value exceeds the threshold.

[b]Last[/b] shows the direction of the most recently triggered realignment.

---

[b]Settings Explained[/b]

[b]Core Settings.[/b]

[b]Auto-Scale Horizons:[/b] when on, the Short and Medium horizons are automatically recomputed per timeframe so the analysis covers similar physical time on every chart. When off, the manually entered horizon lengths are used. Recommended on for users who switch between timeframes.

[b]Short Horizon:[/b] bars used to measure short-horizon efficiency. Lower values are more reactive but noisier. Default 7. Ignored when Auto-Scale is on.

[b]Medium Horizon:[/b] bars used to measure the structural efficiency gradient. Should span one meaningful intraday cycle. Default 24. Ignored when Auto-Scale is on.

[b]Phase Gap Threshold:[/b] the normalized Phase Gap level required for a peak to qualify as exhaustion-grade. Higher values yield fewer but stronger signals. Default 0.58.

[b]Cooldown Bars:[/b] minimum bars between two consecutive signals. Prevents clustering during noisy regimes. Default 3.

[b]Risk Settings.[/b]

[b]ATR Length:[/b] the ATR window used for the volatility-based stop floor. Default 14.

[b]ATR Floor Multiplier:[/b] minimum stop distance expressed as a multiple of ATR. Ensures the stop is never inside short-term noise. Default 1.0.

[b]TP1 R-Multiple:[/b] first profit target expressed as a multiple of the invalidation distance. Default 1.2.

[b]TP2 R-Multiple:[/b] final profit target expressed as a multiple of the invalidation distance. Default 2.2.

[b]Visuals.[/b]

[b]Show Regime Ribbon:[/b] toggles the background regime tint.

[b]Show Active Tint:[/b] toggles the green or red bar coloring during an active observation.

[b]Show Dashboard:[/b] toggles the top-right state dashboard.

---

[b]Execution Model - Why This Is Honest[/b]

PXR uses a strict two-bar workflow. The signal arms only on the close of a confirmed bar - this is enforced by a barstate-confirmed gate inside the engine. The entry then executes at the open of the next bar. This means the entry price shown on the chart matches what a real-time user could have achieved by placing a market order the moment the signal arms.

This workflow prevents the most common form of repaint illusion. The script does not use lookahead data. It does not use future bars. It does not modify past signal positions. Historical signals on the chart represent the same logic that fires in real time.

---

[b]What the Indicator Does Not Do[/b]

PXR does not predict future price. It identifies a measurable energy state and labels the observation. It does not place trades. It does not guarantee outcomes. It does not work on all markets in all conditions. It is not a substitute for risk management, position sizing, or contextual judgment.

The realignment behavior is an observed tendency on historical data, not a certainty or guarantee.

The invalidation rail exists precisely because failure is expected and must be bounded.

---

[b]Limitations You Should Know[/b]

Session boundaries on instruments such as NQ and ES can compress the rolling normalization window during overnight low-liquidity periods. This can make the Phase Gap appear weaker than it would on a continuous session.

The engine is intentionally reversal-focused. It does not generate continuation signals. In strong trending markets, reversal signals may underperform compared to a continuation tool because the structural gradient is not exhausting - it is reinforcing itself.

[b]Auto-Scale[/b] produces horizon values that may differ substantially from the manual input defaults. If a user toggles Auto-Scale off after operating with it on, the manual values will be used immediately and behavior will shift.

On very long historical lookbacks at 1-minute resolution, the efficiency calculation may require additional processing time due to the bar-by-bar path-length computation. If performance is a concern, reducing the Medium Horizon input or enabling Auto-Scale on faster timeframes will reduce the load.

---

[b]Disclaimer[/b]

This script is provided for educational and analytical use only. It does not provide financial, investment, or trading advice. It does not guarantee any specific outcome. Past behavior of the indicator on historical data does not imply future results. Markets carry risk. Use independent judgment, sound risk control, and full market context before acting on any signal or observation produced by this tool. The author is not responsible for any decisions made on the basis of this script.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════
//
//                    PHASE EXHAUSTION REVERSAL - PXR
//
// ───────────────────────────────────────────────────────────────────────────
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © BullByte
// ───────────────────────────────────────────────────────────────────────────
//
// WHAT THIS TOOL DOES
// ───────────────────
// PXR studies a measurable phenomenon: when short-horizon directional
// efficiency spikes far away from the medium-horizon efficiency baseline,
// that spike represents concentrated, transient energy. Such spikes tend
// to exhaust themselves and reconnect with the broader structural gradient.
// PXR identifies the moment that exhaustion completes and visualizes the
// realignment as an observation worth studying.
//
// THE CONCEPT IN PLAIN LANGUAGE
// ─────────────────────────────
// Price has two simultaneous qualities:
//   1. How far it traveled net  → transport
//   2. How much total distance it burned getting there → agitation
// The ratio (transport / agitation) is called efficiency.
//   • Efficiency near 1.0 = clean directional movement
//   • Efficiency near 0.0 = noisy chop with no net progress
//
// PXR computes two efficiencies in parallel:
//   • Short horizon  → reactive, captures bursts
//   • Medium horizon → structural, captures the prevailing gradient
//
// The normalized gap between them (the "Phase Gap") is the key signal.
// When the short horizon burns hard against the medium horizon's
// direction, the gap stretches. When that burst exhausts and the gap
// collapses back toward zero, price tends to realign with the medium
// horizon - the structural gradient reasserts.
//
// MATHEMATICAL BASIS
// ──────────────────
// transport(n)   = close − close[n]
// agitation(n)   = Σ |close[i] − close[i+1]|   for i = 0..n-1
// efficiency(n)  = transport / agitation       (≡ Kaufman Efficiency Ratio)
// phaseGap       = (eff_short − eff_med) / rolling_max(|eff_short − eff_med|)
//
// A realignment signal fires when phaseGap peaks against the medium-horizon
// efficiency sign and then recedes by a meaningful fraction of that peak.
//
// EDUCATIONAL USE
// ───────────────
// This script is built to study efficiency imbalance, phase compression
// and expansion, and structural realignment in intraday markets. It does
// not claim certainty. It visualizes when short-horizon directional energy
// appears spent relative to a broader efficiency trend.
//
// DISCLAIMER
// ──────────
// For educational and analytical use only. This script does not provide
// financial, investment, or trading advice and does not guarantee any
// outcome. Use independent judgment, sound risk control, and full market
// context before acting on any signal. Past observations do not imply
// future results.
//
// EXECUTION MODEL
// ───────────────
// Signal arms on the close of a confirmed bar. Entry executes at the open
// of the next bar. This is an honest, non-repainting workflow - the entry
// price shown on chart matches what a real-time user could have achieved.
//
// ═══════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Phase Exhaustion Reversal [BullByte]", shorttitle="PXR[BullByte]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50, max_bars_back=2000)

// ═══════════════════════════════════════════════════════════════════
// SECTION 1 - INPUTS
// ───────────────────────────────────────────────────────────────────
// All user-controllable parameters live here. Tooltips explain each
// knob in plain language so non-coders can experiment safely.
// ═══════════════════════════════════════════════════════════════════

var g_core   = "Core Settings"
var g_risk   = "Risk Settings"
var g_visual = "Visuals"
var g_dash   = "Dashboard"

// Auto-scale: if true, Short and Medium horizons recompute per timeframe
// so Short ≈ 35 minutes of bars and Medium ≈ 2 hours of bars.
i_autoScale = input.bool(true,  "Auto-Scale Horizons", group=g_core, tooltip="When ON, Short and Medium horizons auto-adapt per timeframe (Short ≈ 35 min, Medium ≈ 2 hours of bars). Turn OFF to override manually using the two inputs below.")
i_shortLen  = input.int(7,      "Short Horizon",       minval=3,   maxval=60,  group=g_core, tooltip="Bars used to measure short-horizon efficiency. Smaller = more reactive, more noise. Ignored when Auto-Scale is ON.")
i_medLen    = input.int(24,     "Medium Horizon",      minval=8,   maxval=120, group=g_core, tooltip="Bars used to measure structural efficiency gradient. Should span one meaningful intraday cycle. Ignored when Auto-Scale is ON.")
i_gapThresh = input.float(0.58, "Phase Gap Threshold", minval=0.1, maxval=1.0, step=0.01, group=g_core, tooltip="Normalized phase-gap level required for a peak to qualify as exhaustion-grade. Higher = fewer but stronger signals.")
i_cooldown  = input.int(3,      "Cooldown Bars",       minval=1,   maxval=15,  group=g_core, tooltip="Minimum bars between two consecutive signals. Prevents clustering during noisy regimes.")

// Risk-management inputs control stop placement and target distances.
i_atrLen    = input.int(14,     "ATR Length",           minval=5,   maxval=30,  group=g_risk, tooltip="ATR window for volatility-based stop floor.")
i_atrFloor  = input.float(1.0,  "ATR Floor Multiplier", minval=0.5, maxval=3.0, step=0.1, group=g_risk, tooltip="Minimum stop distance as a multiple of ATR, so the SL is never crammed inside noise.")
i_tp1R      = input.float(1.2,  "TP1 R-Multiple",       minval=0.5, maxval=5.0, step=0.1, group=g_risk, tooltip="First profit target expressed in R-multiples of the stop distance.")
i_tp2R      = input.float(2.2,  "TP2 R-Multiple",       minval=1.0, maxval=8.0, step=0.1, group=g_risk, tooltip="Final profit target expressed in R-multiples of the stop distance.")

// Visual toggles let users declutter the chart.
i_showRibbon = input.bool(true, "Show Regime Ribbon", group=g_visual, tooltip="Background tint showing the current regime: Extended, Compressed, Transitioning, or Neutral.")
i_showTint   = input.bool(true, "Show Active Tint",   group=g_visual, tooltip="Colors bars while a trade is active (green for long, red for short).")
i_showDash   = input.bool(true, "Show Dashboard",     group=g_dash,   tooltip="Top-right dashboard with live engine state.")


// ═══════════════════════════════════════════════════════════════════
// SECTION 2 - STATE VARIABLES
// ───────────────────────────────────────────────────────────────────
// Persistent state across bars. `var` keeps a value alive between bar
// updates; without it, every bar would reset to the default.
// ═══════════════════════════════════════════════════════════════════

// Trade state
var int    tradeDir        = 0      // 0 = flat, 1 = long, -1 = short
var float  entryPrice      = na
var float  slLevel         = na
var float  tp1Level        = na
var float  tp2Level        = na
var bool   tp1Hit          = false
var bool   tradeActive     = false

// Cooldown bookkeeping - when each kind of signal last fired/exited
var int    lastSigBar      = -999
var int    lastOutcomeBar  = -999
var int    lastLongSigBar  = -999
var int    lastShortSigBar = -999

// Pending entry: a signal armed but not yet executed (executes at next bar open)
var int    pendingDir      = 0      // 0 = nothing pending, 1 = long, -1 = short
var int    pendingBar      = -1     // bar_index where the signal armed; -1 = none

// Dashboard feed values
var string lastSignal      = "-"
var string setupState      = "No Setup"
var string tradeBias       = "-"

// Drawing handles - kept so they can be updated/closed on later bars
var line   ln_entry        = na
var line   ln_sl           = na
var line   ln_tp1          = na
var line   ln_tp2          = na
var label  lb_entry        = na
var label  lb_sl           = na
var label  lb_tp1          = na
var label  lb_tp2          = na


// ═══════════════════════════════════════════════════════════════════
// SECTION 3 - CORE MATH
// ───────────────────────────────────────────────────────────────────
// The three primitive functions that everything else builds on:
// transport, agitation, and efficiency.
// ═══════════════════════════════════════════════════════════════════

// Transport - net displacement over `len` bars.
// Returns na for the first `len` bars where history is not yet built.
f_transport(src, len) =>
    bar_index >= len ? src - src[len] : na

// Agitation - total path length traveled over `len` bars.
// Sum of absolute bar-to-bar changes; this is the "energy spent" on the path.
f_agitation(src, len) =>
    float total = na
    if bar_index >= len
        total := 0.0
        for i = 0 to len - 1
            total += math.abs(src[i] - src[i + 1])
    total

// Efficiency - directional purity. 1.0 = perfectly straight move, 0.0 = chop.
// Mathematically identical to the Kaufman Efficiency Ratio (signed).
f_efficiency(src, len) =>
    float ag = f_agitation(src, len)
    float tr = f_transport(src, len)
    na(tr) or na(ag) or ag == 0.0 ? 0.0 : tr / ag

// Small helpers used to safely close lines and delete labels.
f_closeLine(line ln, int barIdx) =>
    if not na(ln)
        line.set_x2(ln, barIdx)

f_delLabel(label lb) =>
    if not na(lb)
        label.delete(lb)


// ═══════════════════════════════════════════════════════════════════
// SECTION 4 - TIMEFRAME ADAPTATION
// ───────────────────────────────────────────────────────────────────
// When Auto-Scale is ON, horizon lengths are recomputed so each timeframe
// gets the same physical-time window of analysis.
// ═══════════════════════════════════════════════════════════════════

tfMin = timeframe.in_seconds() / 60.0

int shortLen = i_shortLen
int medLen   = i_medLen

if i_autoScale
    // Target windows: short ≈ 35 minutes, medium ≈ 2 hours
    shortLen := math.max(3, int(math.round(35.0 / tfMin)))
    medLen   := math.max(shortLen + 2, int(math.round(120.0 / tfMin)))


// ═══════════════════════════════════════════════════════════════════
// SECTION 5 - PHASE GAP
// ───────────────────────────────────────────────────────────────────
// Compute both efficiencies, take their difference, and normalize so the
// gap is bounded roughly within [-1, +1]. Normalization uses a rolling
// max of the absolute raw gap so the threshold stays meaningful across
// volatility regimes.
// ═══════════════════════════════════════════════════════════════════

effShort = f_efficiency(close, shortLen)
effMed   = f_efficiency(close, medLen)
rawGap   = effShort - effMed

// Rolling window for normalization, adjusted per timeframe so the lookback
// covers similar physical time on each chart.
int normWindow = 200
if tfMin <= 1
    normWindow := 300
else if tfMin <= 3
    normWindow := 250
else if tfMin <= 5
    normWindow := 200
else if tfMin <= 15
    normWindow := 120
else
    normWindow := 80

absRaw   = na(rawGap) ? 0.0 : math.abs(rawGap)
rollMax  = ta.highest(absRaw, normWindow)
denom    = rollMax > 0.0 ? rollMax : 1.0
phaseGap = na(rawGap) ? 0.0 : rawGap / denom


// ═══════════════════════════════════════════════════════════════════
// SECTION 6 - REGIME STATE
// ───────────────────────────────────────────────────────────────────
// Classify the current market into one of four regimes. The thresholds
// adapt per timeframe because shorter charts produce more raw efficiency
// turbulence.
// ═══════════════════════════════════════════════════════════════════

absGap    = math.abs(phaseGap)
absEffMed = math.abs(effMed)

float extThresh  = 0.6
float compThresh = 0.25
float transMult  = 0.9

if tfMin <= 1
    extThresh  := 0.5
    compThresh := 0.30
    transMult  := 0.75
else if tfMin <= 3
    extThresh  := 0.55
    compThresh := 0.28
    transMult  := 0.80
else if tfMin <= 5
    extThresh  := 0.6
    compThresh := 0.25
    transMult  := 0.9
else if tfMin <= 15
    extThresh  := 0.45
    compThresh := 0.30
    transMult  := 0.65
else
    extThresh  := 0.40
    compThresh := 0.35
    transMult  := 0.55

// Four regimes:
//   EXTENDED      - medium-horizon efficiency is high (clean trend)
//   COMPRESSED    - both efficiencies low (range/chop)
//   TRANSITIONING - phase gap has stretched far, regime is shifting
//   NEUTRAL       - none of the above
string regimeState = "NEUTRAL"
if absEffMed > extThresh
    regimeState := "EXTENDED"
else if absEffMed < compThresh and absGap < 0.4
    regimeState := "COMPRESSED"
else if absGap > i_gapThresh * transMult
    regimeState := "TRANSITIONING"


// ═══════════════════════════════════════════════════════════════════
// SECTION 7 - SIGNAL ENGINE
// ───────────────────────────────────────────────────────────────────
// The realignment trigger. The engine watches for a phase-gap peak
// against the medium-horizon trend, then waits for it to recede by a
// meaningful fraction. That recede is the exhaustion confirmation.
// ═══════════════════════════════════════════════════════════════════

// Threshold scaling - relax slightly on 15m so signals are still findable
// while staying strict on faster charts.
float tfThreshScale = 1.0
if tfMin <= 15
    tfThreshScale := 0.65

// Active threshold depends on current regime - different regimes deserve
// different sensitivities.
float activeThr = i_gapThresh
if regimeState == "EXTENDED"
    activeThr := i_gapThresh * 0.95
else if regimeState == "COMPRESSED"
    activeThr := i_gapThresh * 0.80
else if regimeState == "TRANSITIONING"
    activeThr := i_gapThresh * 0.85
activeThr *= tfThreshScale

// Peak-detection window and recede fraction - adapt per timeframe.
int   peakWindow     = 12
float recedeFraction = 0.35

if tfMin <= 1
    peakWindow     := 18
    recedeFraction := 0.30
else if tfMin <= 3
    peakWindow     := 14
    recedeFraction := 0.32
else if tfMin <= 5
    peakWindow     := 12
    recedeFraction := 0.35
else if tfMin <= 15
    peakWindow     := 14
    recedeFraction := 0.25
else
    peakWindow     := 8
    recedeFraction := 0.40

// Recent extremes of phaseGap inside the peak window
posPeak = ta.highest(phaseGap, peakWindow)
negPeak = ta.lowest(phaseGap, peakWindow)

// Did the gap reach an extreme strong enough to qualify?
peakedBull = posPeak > activeThr
peakedBear = negPeak < -activeThr

// Has the gap meaningfully receded from that extreme?
recedingBull = phaseGap < posPeak * (1.0 - recedeFraction)
recedingBear = phaseGap > negPeak * (1.0 - recedeFraction)

// Trend proxy uses the SIGN of the medium-horizon efficiency.
// This is architecturally consistent with the engine's own math.
trendBull = effMed > 0.0
trendBear = effMed < 0.0

// Realignment definition:
//   LONG  realign = short-horizon BEAR burst exhausted against BULL gradient
//   SHORT realign = short-horizon BULL burst exhausted against BEAR gradient
isRealignLong  = peakedBear and recedingBear and trendBull
isRealignShort = peakedBull and recedingBull and trendBear

// State machine that fires only once per peak/recede cycle.
// resetTrig clears the latch when both peaks are absent.
var int trigState = 0

bool resetTrig = not peakedBull and not peakedBear
bool setLong   = isRealignLong  and trigState != 1
bool setShort  = isRealignShort and trigState != -1

trigState := resetTrig ? 0 : setLong ? 1 : setShort ? -1 : trigState

// Detect the moment the state machine flips. nz() guards against the
// na value on the very first bar.
crossUp = trigState == 1  and nz(trigState[1], 0) != 1
crossDn = trigState == -1 and nz(trigState[1], 0) != -1

// Cooldown: bars between any signals, plus extra cooldown between same-direction signals.
int sameDirMult = tfMin >= 15 ? 2 : 3

generalCooldownOk = (bar_index - lastSigBar     >= i_cooldown) and  (bar_index - lastOutcomeBar  >= i_cooldown)
longCooldownOk    =  bar_index - lastLongSigBar  >= i_cooldown * sameDirMult
shortCooldownOk   =  bar_index - lastShortSigBar >= i_cooldown * sameDirMult

// Raw signal: state-machine flipped, regime is valid, nothing else is in flight.
sigLong  = crossUp and regimeState != "NEUTRAL" and not tradeActive and pendingDir == 0 and generalCooldownOk and longCooldownOk
sigShort = crossDn and regimeState != "NEUTRAL" and not tradeActive and pendingDir == 0 and generalCooldownOk and shortCooldownOk

// Only arm on confirmed (closed) bars - this prevents intra-bar repaint.
armedLong  = sigLong  and barstate.isconfirmed
armedShort = sigShort and barstate.isconfirmed

// ATR is needed both for risk and for visual anchoring of the signal label,
// so compute it once here.
atrVal = ta.atr(i_atrLen)

// When a signal arms, store the pending direction, mark cooldowns, and
// drop the PHASE EXHAUSTION label at the signal bar - placed outside the
// price extreme so it does not collide with the entry rails drawn later.
if armedLong
    pendingDir      := 1
    pendingBar      := bar_index
    lastSigBar      := bar_index
    lastLongSigBar  := bar_index
    lastSignal      := "BULL"
    bullAnchor = low - atrVal * 2.0
    label.new(bar_index, bullAnchor, "▲ PHASE EXHAUSTION\nRealign Up", color=color.new(#1b5e20, 0), textcolor=color.white, style=label.style_label_up, size=size.normal, yloc=yloc.price, tooltip="Short-horizon bearish burst has exhausted against the bullish medium-horizon gradient. Studied behavior is realignment to the upside. Reference entry at the next bar open.")

if armedShort
    pendingDir      := -1
    pendingBar      := bar_index
    lastSigBar      := bar_index
    lastShortSigBar := bar_index
    lastSignal      := "BEAR"
    bearAnchor = high + atrVal * 2.0
    label.new(bar_index, bearAnchor, "▼ PHASE EXHAUSTION\nRealign Down", color=color.new(#b71c1c, 0), textcolor=color.white, style=label.style_label_down, size=size.normal, yloc=yloc.price, tooltip="Short-horizon bullish burst has exhausted against the bearish medium-horizon gradient. Studied behavior is realignment to the downside. Reference entry at the next bar open.")

// Safety reset: if a pending signal never executed within 2 bars, clear the pending state.
// Prevents the indicator from getting permanently stuck with no new signals on replay edges.
if pendingDir != 0 and pendingBar >= 0 and bar_index > pendingBar + 2
    pendingDir := 0
    pendingBar := -1


// ═══════════════════════════════════════════════════════════════════
// SECTION 8 - RISK ENGINE
// ───────────────────────────────────────────────────────────────────
// Stop-loss is the worse (further) of:
//   • A structural swing high/low with an ATR buffer
//   • An ATR-floored distance from entry
// This guarantees the stop is never inside noise.
// ═══════════════════════════════════════════════════════════════════

f_swingLow(lb) =>
    float sl = low[1]
    for i = 2 to lb
        sl := math.min(sl, low[i])
    sl

f_swingHigh(lb) =>
    float sh = high[1]
    for i = 2 to lb
        sh := math.max(sh, high[i])
    sh

// Swing lookback adapts to timeframe so the structural stop is always meaningful.
// Faster charts need more bars to capture an equivalent price structure window.
int swingLB = tfMin <= 1 ? 20 : tfMin <= 3 ? 15 : tfMin <= 5 ? 12 : tfMin <= 15 ? 10 : 8

f_slLong(entryP) =>
    structural = f_swingLow(swingLB) - atrVal * 0.25
    atrFloor   = entryP - atrVal * i_atrFloor
    math.min(structural, atrFloor)

f_slShort(entryP) =>
    structural = f_swingHigh(swingLB) + atrVal * 0.25
    atrFloor   = entryP + atrVal * i_atrFloor
    math.max(structural, atrFloor)


// ═══════════════════════════════════════════════════════════════════
// SECTION 9 - ENTRY EXECUTION
// ───────────────────────────────────────────────────────────────────
// One bar after the signal arms, execute the entry at the open of this
// new bar. Draw entry, stop, and two target rails plus their labels.
// ═══════════════════════════════════════════════════════════════════

executeLong  = pendingDir == 1  and pendingBar >= 0 and bar_index == pendingBar + 1
executeShort = pendingDir == -1 and pendingBar >= 0 and bar_index == pendingBar + 1

if executeLong or executeShort
    isLong     = executeLong
    tradeDir   := isLong ? 1 : -1
    entryPrice := open
    slLevel    := isLong ? f_slLong(open) : f_slShort(open)

    // Guard against a near-zero stop distance (very rare structural collapse).
    float slDist = math.abs(entryPrice - slLevel)
    if slDist < atrVal * 0.1
        slDist := atrVal * i_atrFloor

    tp1Level    := isLong ? entryPrice + slDist * i_tp1R : entryPrice - slDist * i_tp1R
    tp2Level    := isLong ? entryPrice + slDist * i_tp2R : entryPrice - slDist * i_tp2R
    tradeActive := true
    tp1Hit      := false
    pendingDir  := 0
    pendingBar  := -1

    // Horizontal rails - these extend forward bar-by-bar in Section 10.
    ln_entry := line.new(bar_index, entryPrice, bar_index, entryPrice, color=color.new(#90a4ae, 0), width=1, style=line.style_dashed)
    ln_sl    := line.new(bar_index, slLevel,    bar_index, slLevel,    color=color.new(#c62828, 0), width=2, style=line.style_solid)
    ln_tp1   := line.new(bar_index, tp1Level,   bar_index, tp1Level,   color=color.new(#00897b, 0), width=2, style=line.style_solid)
    ln_tp2   := line.new(bar_index, tp2Level,   bar_index, tp2Level,   color=color.new(#00bfa5, 0), width=3, style=line.style_solid)

    // Rail text strings
    entryTxt  = "ENTRY  "        + str.tostring(entryPrice, format.mintick) + "  |  " + (isLong ? "REALIGN UP" : "REALIGN DOWN")
    slTxt     = "INVALIDATION  " + str.tostring(slLevel,    format.mintick)
    tp1Txt    = "TARGET 1  "     + str.tostring(tp1Level,   format.mintick) + "  |  " + str.tostring(i_tp1R) + "R"
    tp2Txt    = "TARGET 2  "     + str.tostring(tp2Level,   format.mintick) + "  |  " + str.tostring(i_tp2R) + "R"

    // Rail tooltips
    entryTip  = "Reference entry level marked at the open of this bar, one bar after the signal armed."
    slTip     = "Invalidation level. If price reaches this, the realignment thesis is rejected."
    tp1Tip    = "First profit objective at " + str.tostring(i_tp1R) + " R from entry."
    tp2Tip    = "Final profit objective at " + str.tostring(i_tp2R) + " R from entry."

    lb_entry := label.new(bar_index, entryPrice, entryTxt, color=color.new(#1565c0, 0), textcolor=color.white, style=label.style_label_left, size=size.small, tooltip=entryTip)
    lb_sl    := label.new(bar_index, slLevel,    slTxt,    color=color.new(#c62828, 0), textcolor=color.white, style=label.style_label_left, size=size.small, tooltip=slTip)
    lb_tp1   := label.new(bar_index, tp1Level,   tp1Txt,   color=color.new(#00695c, 0), textcolor=color.white, style=label.style_label_left, size=size.small, tooltip=tp1Tip)
    lb_tp2   := label.new(bar_index, tp2Level,   tp2Txt,   color=color.new(#00897b, 0), textcolor=color.white, style=label.style_label_left, size=size.small, tooltip=tp2Tip)


// ═══════════════════════════════════════════════════════════════════
// SECTION 10 - TRADE MANAGEMENT
// ───────────────────────────────────────────────────────────────────
// While a trade is active:
//   • Slide the four rail labels forward so they stay near current price.
//   • Extend the four rail lines forward to the current bar.
//   • Check for TP/SL events and close the trade cleanly when one fires.
//   • Named closure booleans exposed here for alert consumption.
// ═══════════════════════════════════════════════════════════════════

bool tp1JustHit    = false
bool tp2Hit        = false
bool slHit         = false
bool ambiguousExit = false

if tradeActive
    int labelTrail = bar_index + 3
    if not na(lb_entry)
        label.set_x(lb_entry, labelTrail)
    if not na(lb_sl)
        label.set_x(lb_sl, labelTrail)
    if not na(lb_tp1)
        label.set_x(lb_tp1, labelTrail)
    if not na(lb_tp2)
        label.set_x(lb_tp2, labelTrail)

    if not na(ln_entry)
        line.set_x2(ln_entry, bar_index)
    if not na(ln_sl)
        line.set_x2(ln_sl, bar_index)
    if not na(ln_tp1)
        line.set_x2(ln_tp1, bar_index)
    if not na(ln_tp2)
        line.set_x2(ln_tp2, bar_index)

    if tradeDir == 1
        if not tp1Hit and high >= tp1Level
            tp1Hit     := true
            tp1JustHit := true

        longAmbiguous = low <= slLevel and high >= tp2Level

        if longAmbiguous
            ambiguousExit  := true
            slHit          := true
            tradeActive    := false
            tradeDir       := 0
            lastOutcomeBar := bar_index
            f_closeLine(ln_entry, bar_index)
            f_closeLine(ln_sl,    bar_index)
            f_closeLine(ln_tp1,   bar_index)
            f_closeLine(ln_tp2,   bar_index)
            f_delLabel(lb_entry)
            lb_entry := na
            f_delLabel(lb_sl)
            lb_sl    := na
            f_delLabel(lb_tp1)
            lb_tp1   := na
            f_delLabel(lb_tp2)
            lb_tp2   := na
        else if high >= tp2Level
            tp2Hit         := true
            tradeActive    := false
            tradeDir       := 0
            lastOutcomeBar := bar_index
            f_closeLine(ln_entry, bar_index)
            f_closeLine(ln_sl,    bar_index)
            f_closeLine(ln_tp1,   bar_index)
            f_closeLine(ln_tp2,   bar_index)
            f_delLabel(lb_entry)
            lb_entry := na
            f_delLabel(lb_sl)
            lb_sl    := na
            f_delLabel(lb_tp1)
            lb_tp1   := na
            f_delLabel(lb_tp2)
            lb_tp2   := na
        else if low <= slLevel
            slHit          := true
            tradeActive    := false
            tradeDir       := 0
            lastOutcomeBar := bar_index
            f_closeLine(ln_entry, bar_index)
            f_closeLine(ln_sl,    bar_index)
            f_closeLine(ln_tp1,   bar_index)
            f_closeLine(ln_tp2,   bar_index)
            f_delLabel(lb_entry)
            lb_entry := na
            f_delLabel(lb_sl)
            lb_sl    := na
            f_delLabel(lb_tp1)
            lb_tp1   := na
            f_delLabel(lb_tp2)
            lb_tp2   := na

    if tradeDir == -1
        if not tp1Hit and low <= tp1Level
            tp1Hit     := true
            tp1JustHit := true

        shortAmbiguous = high >= slLevel and low <= tp2Level

        if shortAmbiguous
            ambiguousExit  := true
            slHit          := true
            tradeActive    := false
            tradeDir       := 0
            lastOutcomeBar := bar_index
            f_closeLine(ln_entry, bar_index)
            f_closeLine(ln_sl,    bar_index)
            f_closeLine(ln_tp1,   bar_index)
            f_closeLine(ln_tp2,   bar_index)
            f_delLabel(lb_entry)
            lb_entry := na
            f_delLabel(lb_sl)
            lb_sl    := na
            f_delLabel(lb_tp1)
            lb_tp1   := na
            f_delLabel(lb_tp2)
            lb_tp2   := na
        else if low <= tp2Level
            tp2Hit         := true
            tradeActive    := false
            tradeDir       := 0
            lastOutcomeBar := bar_index
            f_closeLine(ln_entry, bar_index)
            f_closeLine(ln_sl,    bar_index)
            f_closeLine(ln_tp1,   bar_index)
            f_closeLine(ln_tp2,   bar_index)
            f_delLabel(lb_entry)
            lb_entry := na
            f_delLabel(lb_sl)
            lb_sl    := na
            f_delLabel(lb_tp1)
            lb_tp1   := na
            f_delLabel(lb_tp2)
            lb_tp2   := na
        else if high >= slLevel
            slHit          := true
            tradeActive    := false
            tradeDir       := 0
            lastOutcomeBar := bar_index
            f_closeLine(ln_entry, bar_index)
            f_closeLine(ln_sl,    bar_index)
            f_closeLine(ln_tp1,   bar_index)
            f_closeLine(ln_tp2,   bar_index)
            f_delLabel(lb_entry)
            lb_entry := na
            f_delLabel(lb_sl)
            lb_sl    := na
            f_delLabel(lb_tp1)
            lb_tp1   := na
            f_delLabel(lb_tp2)
            lb_tp2   := na



// ═══════════════════════════════════════════════════════════════════
// SECTION 11 - STATE FEED
// ───────────────────────────────────────────────────────────────────
// Compute the live values shown in the top-right dashboard.
// ═══════════════════════════════════════════════════════════════════

// Bias = sign of medium-horizon efficiency, lightly thresholded for stability.
if effMed > compThresh
    tradeBias := "BULL"
else if effMed < -compThresh
    tradeBias := "BEAR"
else
    tradeBias := "-"

// Setup progress states
if tradeActive
    setupState := "TRIGGERED"
else if pendingDir != 0
    setupState := "ARMED"
else if absGap > i_gapThresh * 0.85
    setupState := "WATCHING"
else if absGap > i_gapThresh * 0.60
    setupState := "FORMING"
else
    setupState := "No Setup"


// ═══════════════════════════════════════════════════════════════════
// SECTION 12 - REGIME RIBBON
// ───────────────────────────────────────────────────────────────────
// Background tint indicating current regime. Helps users see at a
// glance whether the market is trending, ranging, or in transition.
// ═══════════════════════════════════════════════════════════════════

color ribbonColor = color.new(#90a4ae, 94)
if regimeState == "EXTENDED"
    ribbonColor := color.new(#ef5350, 88)
else if regimeState == "COMPRESSED"
    ribbonColor := color.new(#ffa726, 88)
else if regimeState == "TRANSITIONING"
    ribbonColor := color.new(#00e5ff, 82)

bgcolor(i_showRibbon ? ribbonColor : na, title="Regime Ribbon")


// ═══════════════════════════════════════════════════════════════════
// SECTION 13 - ACTIVE TINT
// ───────────────────────────────────────────────────────────────────
// Colors bars while a trade is active - green for long, red for short.
// ═══════════════════════════════════════════════════════════════════

color tintColor = na
if i_showTint and tradeActive
    tintColor := tradeDir == 1 ? color.new(#26a69a, 82) : color.new(#ef5350, 82)

barcolor(tintColor, title="Active Tint")


// ═══════════════════════════════════════════════════════════════════
// SECTION 14 - DASHBOARD
// ───────────────────────────────────────────────────────────────────
// Compact 2-column dashboard at top-right showing engine state.
// Color helpers translate string states into clean color codes.
// ═══════════════════════════════════════════════════════════════════

var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(#0d1117, 10), border_color=color.new(#30363d, 60), border_width=1, frame_color=color.new(#00e5ff, 40), frame_width=1)

f_stateColor(st) =>
    color c = color.new(#90a4ae, 0)
    if st == "EXTENDED"
        c := color.new(#ef5350, 0)
    else if st == "COMPRESSED"
        c := color.new(#ffa726, 0)
    else if st == "TRANSITIONING"
        c := color.new(#00e5ff, 0)
    c

f_setupColor(su) =>
    color c = color.new(#546e7a, 0)
    if su == "ARMED"
        c := color.new(#00e5ff, 0)
    else if su == "WATCHING"
        c := color.new(#b0bec5, 0)
    else if su == "FORMING"
        c := color.new(#ffa726, 0)
    else if su == "TRIGGERED"
        c := color.new(#26a69a, 0)
    c

f_biasColor(b) =>
    color c = color.new(#546e7a, 0)
    if b == "BULL"
        c := color.new(#26a69a, 0)
    else if b == "BEAR"
        c := color.new(#ef5350, 0)
    c

f_lastColor(l) =>
    color c = color.new(#546e7a, 0)
    if l == "BULL"
        c := color.new(#26a69a, 0)
    else if l == "BEAR"
        c := color.new(#ef5350, 0)
    c

if i_showDash and barstate.islast
    phaseGapDisp = na(phaseGap) ? "-" : str.tostring(phaseGap, "#.##")
    gapColor     = math.abs(phaseGap) > i_gapThresh ? color.new(#00e5ff, 0) : color.new(#546e7a, 0)

    table.cell(dash, 0, 0, "PXR ENGINE", text_color=color.new(#00e5ff, 0), bgcolor=color.new(#161b22, 20), text_size=size.small)
    table.cell(dash, 1, 0, "LIVE",        text_color=color.new(#00e5ff, 0), bgcolor=color.new(#161b22, 20), text_size=size.small)

    table.cell(dash, 0, 1, "State",       text_color=color.new(#8b949e, 0), text_size=size.small, bgcolor=color.new(#0d1117, 20), tooltip="Current regime classification from medium-horizon efficiency and phase gap.")
    table.cell(dash, 1, 1, regimeState,   text_color=f_stateColor(regimeState), text_size=size.small, bgcolor=color.new(#0d1117, 20))

    table.cell(dash, 0, 2, "Setup",       text_color=color.new(#8b949e, 0), text_size=size.small, bgcolor=color.new(#0d1117, 20), tooltip="Realignment setup progress: Forming → Armed → Triggered.")
    table.cell(dash, 1, 2, setupState,    text_color=f_setupColor(setupState), text_size=size.small, bgcolor=color.new(#0d1117, 20))

    table.cell(dash, 0, 3, "Bias",        text_color=color.new(#8b949e, 0), text_size=size.small, bgcolor=color.new(#0d1117, 20), tooltip="Direction of the medium-horizon efficiency gradient.")
    table.cell(dash, 1, 3, tradeBias,     text_color=f_biasColor(tradeBias), text_size=size.small, bgcolor=color.new(#0d1117, 20))

    table.cell(dash, 0, 4, "Phase Gap",   text_color=color.new(#8b949e, 0), text_size=size.small, bgcolor=color.new(#0d1117, 20), tooltip="Normalized dislocation between short and medium horizon efficiency.")
    table.cell(dash, 1, 4, phaseGapDisp,  text_color=gapColor, text_size=size.small, bgcolor=color.new(#0d1117, 20))

    table.cell(dash, 0, 5, "Last",        text_color=color.new(#8b949e, 0), text_size=size.small, bgcolor=color.new(#161b22, 20), tooltip="Most recent realignment direction triggered.")
    table.cell(dash, 1, 5, lastSignal,    text_color=f_lastColor(lastSignal), text_size=size.small, bgcolor=color.new(#161b22, 20))

// ═══════════════════════════════════════════════════════════════════
// SECTION 15 - ALERTS
// ───────────────────────────────────────────────────────────────────
// Set all alerts to "Once Per Bar Close" in TradingView to match the
// confirmed-bar execution model of this script.
// ═══════════════════════════════════════════════════════════════════

bool anySignal = armedLong or armedShort
bool anyAlert  = armedLong or armedShort or executeLong or executeShort or tp1JustHit or tp2Hit or slHit or ambiguousExit

alertcondition(anySignal,
     title   = "PXR - Any Signal Armed",
     message = "PXR Signal Armed | {{ticker}} {{interval}} | Check chart for direction.")

alertcondition(anyAlert,
     title   = "PXR - Any Alert",
     message = "PXR Alert | {{ticker}} {{interval}} | Check chart for event.")

alertcondition(armedLong,
     title   = "PXR - Bull Signal Armed",
     message = "PXR Bull Realignment Armed | {{ticker}} {{interval}} | Entry at next bar open.")

alertcondition(armedShort,
     title   = "PXR - Bear Signal Armed",
     message = "PXR Bear Realignment Armed | {{ticker}} {{interval}} | Entry at next bar open.")

alertcondition(executeLong,
     title   = "PXR - Long Entry Executed",
     message = "PXR Long Entry | {{ticker}} {{interval}} | Check chart for SL and TP levels.")

alertcondition(executeShort,
     title   = "PXR - Short Entry Executed",
     message = "PXR Short Entry | {{ticker}} {{interval}} | Check chart for SL and TP levels.")

alertcondition(tp1JustHit,
     title   = "PXR - Target 1 Reached",
     message = "PXR Target 1 Reached | {{ticker}} {{interval}} | Trade remains open toward Target 2.")

alertcondition(tp2Hit,
     title   = "PXR - Target 2 Reached",
     message = "PXR Target 2 Reached | {{ticker}} {{interval}} | Trade closed at final objective.")

alertcondition(slHit and not ambiguousExit,
     title   = "PXR - Invalidation Hit",
     message = "PXR Invalidation Hit | {{ticker}} {{interval}} | Realignment thesis rejected.")

alertcondition(ambiguousExit,
     title   = "PXR - Ambiguous Exit (SL Priority)",
     message = "PXR Ambiguous Exit | {{ticker}} {{interval}} | SL and TP2 both touched same bar. Closed at SL.")
````
