<!-- tradingview-pine-id: PUB;94c80c00f6544cef9bbefcf09b918c0e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Inducement Sweep Strategy [algotim]

Source: https://www.tradingview.com/script/BfwdOETc-Inducement-Sweep-Strategy-algotim/

## Description

Inducement Sweep Strategy [algo_aakash] enters trades only after the classic ICT inducement sequence has fully played out: an external liquidity pool is identified, an internal swing (the inducement) forms in front of it, that inducement is swept with genuine displacement, and price then confirms a Market Structure Shift back in the real direction. Every qualifying setup is scored by the Inducement Quality Index (IQI), a 0-to-100 composite that ranks how convincing the engineered move actually was before an entry signal is ever shown.

Problem Statement
Most public inducement or "sweep and BOS" scripts fire a signal the instant any minor swing is tagged and broken. They do not distinguish between an inducement that formed in front of a meaningful liquidity pool with a violent, high-conviction reversal, and a shallow internal wiggle that happened to get tapped during normal noise. Traders end up manually filtering every alert, checking chart context by hand, which defeats the purpose of automating inducement detection in the first place. This script instead separates structure identification from signal display: the full pipeline runs on every bar, but only setups that pass the quality bar are shown as entries.

Methodology
Two pivot lengths run in parallel. A longer length confirms External Structure — the major swing highs and lows that represent the real liquidity pool the market is engineered toward. A shorter length confirms Internal Structure — the minor swings that sit closer to current price. When a confirmed internal low forms above the most recent confirmed external low (or, for shorts, an internal high forms below the most recent external high), that internal point is flagged as an Inducement Candidate: a level structurally positioned to attract retail stops in front of the real liquidity pool.
The candidate remains active until price wicks through it and closes back on the correct side with a reversal body at least a user-defined ATR multiple in size — this is the Sweep, and the ATR displacement requirement filters out shallow wicks that reflect noise rather than an engineered stop run. Once swept, the script watches for a Market Structure Shift: a close beyond the internal high or low that sat between the external level and the inducement. Only this break confirms the real directional move is underway, and only then does the entry logic activate.
Each confirmed setup is scored by the IQI engine across four factors — displacement strength, sweep freshness, liquidity depth, and rejection wick quality — combined into a single 0-to-100 score. An entry signal is only displayed on the chart when the score meets the user's configured minimum, so lower-quality setups are tracked internally but never clutter the chart or trigger alerts.
If price fails to sweep the inducement within a maximum bar window, breaks the external level before the sweep, fails to confirm the MSS within its own bar window, or fails an optional retest, the setup is invalidated and the pipeline resets automatically. All structure is derived from confirmed pivots only, so nothing in the detection logic repaints.

Signal Workflow
1. Confirm a major external swing high or low using the External Structure Length.
2. Confirm a minor internal swing forming on the inducing side of that external level — this becomes the active Inducement Candidate.
3. Wait for price to wick through the inducement level and close back on the correct side with a reversal body meeting the ATR displacement threshold — this is the Sweep.
4. Wait for a confirmed close beyond the internal high/low recorded between the external level and the inducement — this is the Market Structure Shift.
5. Calculate the Inducement Quality Index from displacement, freshness, depth, and rejection wick quality.
6. If Require Retest is enabled, wait for price to pull back and hold the broken MSS level before confirming.
7. Display the entry signal with its IQI score only if the score meets the configured minimum, and fire the corresponding alert.

Why This Indicator Is Different
Standard inducement or liquidity-sweep-plus-BOS scripts treat every sweep-and-break sequence identically, regardless of how convincing the move actually was.
The Inducement Quality Index is a composite score built specifically around the mechanics of an engineered inducement move rather than a generic volatility or volume filter — it weighs how fresh the sweep was relative to the inducement, how deep the underlying liquidity pool is in ATR terms, how strong the displacement candle was, and how decisively the sweep bar rejected its extreme.
Because setups below the quality threshold are still tracked internally and simply not displayed, the pipeline status label can show a user exactly where an unfolding setup stands without forcing premature signals onto the chart.
The optional retest requirement gives discretionary traders a way to demand confirmation of the broken structure as new support or resistance before treating the setup as valid, without changing the core detection logic.

Inputs
Structure Settings
External Structure Length — pivot length confirming the major swing that anchors the real liquidity pool
Internal Structure Length — pivot length confirming the minor swing used as the inducement candidate

Inducement Settings
Max Bars to Sweep — maximum age allowed for an inducement candidate before it is discarded as stale
Max Bars to Confirm MSS — maximum age allowed between the sweep and the structure shift confirmation

Displacement Filter
ATR Length — period for the ATR used in the displacement requirement
Min Displacement (x ATR) — minimum reversal candle body, as an ATR multiple, required to validate a sweep

Signal Quality
Minimum IQI to Show Signal — setups scoring below this 0-100 threshold are tracked but not displayed

Entry Options
Require Retest Before Entry — waits for a pullback that holds the broken MSS level before confirming the signal

Trade Levels
Show Entry / Stop / Target Lines — visual-only projected levels, not a managed strategy
Reward : Risk Ratio — target distance as a multiple of the stop distance
Level Projection Length — how far right the projected lines extend

Visual Settings
Show Inducement Level, Show Sweep Marker, Show MSS Break Line, Show Pipeline Status Label
Bullish / Bearish / Inducement / MSS / Sweep Marker colors

Alert Settings
Alert: Inducement Identified, Alert: Inducement Swept, Alert: Entry Signal, Alert: Setup Invalidated

Alerts
Alerts are available for:
Bullish Inducement Identified
Bearish Inducement Identified
Bullish Inducement Swept
Bearish Inducement Swept
Long Entry Signal (with IQI score, entry, and stop level)
Short Entry Signal (with IQI score, entry, and stop level)
Setup Invalidated (bullish and bearish, optional)

Practical Usage
Raise the Minimum IQI threshold on lower timeframes or noisy instruments to surface only the most convincing engineered moves.
Enable Require Retest for a more conservative entry style that waits for the broken structure to hold before committing.
Use the pipeline status label to monitor an unfolding setup in real time without needing a signal to already have fired.
The projected trade levels are a visual reference only — position sizing and trade management remain the trader's responsibility.
Combine with a higher timeframe bias tool to only act on Inducement Sweep signals that align with the broader directional context.

Limitations
Structure confirmation requires the full pivot look-right period to elapse before a swing is confirmed, so entries occur after price has already moved past the exact reversal point. This is standard confirmed-pivot behavior and is not repainting.
The IQI score is a relative ranking based on the four factors described above and does not guarantee trade outcomes. It should be used as a filtering aid, not a standalone trading signal.
The displacement filter is ATR-relative; on instruments with unusually low volatility, the ATR multiple may need to be reduced to detect qualifying sweeps.
The indicator does not manage open positions, calculate position size, or provide exits beyond the single visual target line. It identifies potential inducement-based entries only.

Notes
All structure levels and signals are drawn at the bar index of the actual pivot or event, not the confirmation bar, ensuring accurate visual placement.
The state machine for bullish and bearish setups runs independently and concurrently, so both directions can be tracked at the same time on ranging instruments.
For best results combine with Market Structure Break BOS/CHoCH Tracker [algo_aakash] to cross-check the higher timeframe structural context before acting on a signal.

---

## Source Code

````pine
// Author: algotim
// =============================================================================
// INNOVATION: Inducement Quality Index (IQI) — a 0-100 composite score unique
// to this indicator, built from four inducement-specific factors: displacement
// strength, sweep freshness, liquidity depth (ATR-normalized distance between
// the inducement and the anchoring external structure point), and rejection
// wick quality. Public inducement / MSS scripts fire a signal on every sweep
// + break sequence with no ranking — IQI lets traders filter for only the
// highest-probability engineered setups instead of treating every inducement
// the same way.
// =============================================================================

//@version=6
indicator("Inducement Sweep Strategy [algotim]",
     shorttitle       = "ISS [algotim]",
     overlay          = true,
     max_lines_count  = 200,
     max_labels_count = 300)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// — Structure —
i_extLen = input.int(21, "External Structure Length", minval=5, maxval=100,
     group="Structure Settings",
     tooltip="Pivot length used to confirm major (external) swing highs/lows. This anchors the real liquidity pool the setup is engineered around.")
i_intLen = input.int(5, "Internal Structure Length", minval=2, maxval=30,
     group="Structure Settings",
     tooltip="Pivot length used to confirm minor (internal) swing highs/lows. Internal lows/highs are the candidates for inducement.")

// — Inducement —
i_maxSweepBars = input.int(40, "Max Bars to Sweep", minval=5, maxval=200,
     group="Inducement Settings",
     tooltip="Maximum bars allowed between an inducement forming and being swept. Stale inducements beyond this age are discarded.")
i_maxMssBars = input.int(30, "Max Bars to Confirm MSS", minval=5, maxval=200,
     group="Inducement Settings",
     tooltip="Maximum bars allowed between the sweep and the Market Structure Shift confirmation. Stale sweeps beyond this age are discarded.")

// — Displacement Filter —
i_atrLen  = input.int(14, "ATR Length", minval=5, maxval=50, group="Displacement Filter")
i_atrMult = input.float(0.6, "Min Displacement (x ATR)", minval=0.1, step=0.1,
     group="Displacement Filter",
     tooltip="Minimum body size of the reversal candle, expressed as an ATR multiple, required to validate a sweep as genuine displacement rather than noise.")

// — Signal Quality —
i_iqiThresh = input.int(60, "Minimum IQI to Show Signal", minval=0, maxval=100,
     group="Signal Quality",
     tooltip="Inducement Quality Index (0-100). Setups scoring below this threshold are tracked internally but not displayed as entry signals.")

// — Entry Options —
i_requireRetest = input.bool(false, "Require Retest Before Entry", group="Entry Options",
     tooltip="If enabled, the entry signal waits for price to pull back and retest the broken structure level before triggering, instead of firing on the breakout close itself.")

// — Trade Levels (visual only) —
i_showLevels = input.bool(true, "Show Entry / Stop / Target Lines", group="Trade Levels",
     tooltip="Draws projected entry, stop and target reference lines. For visualization only — this indicator does not manage trades.")
i_rr       = input.float(2.0, "Reward : Risk Ratio", minval=0.5, step=0.5, group="Trade Levels")
i_projBars = input.int(25, "Level Projection Length (bars)", minval=5, maxval=100, group="Trade Levels")
i_entryColor  = input.color(#00E5FF, "Entry Line Color",  group="Trade Levels")
i_stopColor   = input.color(#E53935, "Stop Line Color",   group="Trade Levels")
i_targetColor = input.color(#4CAF50, "Target Line Color", group="Trade Levels")

// — Visual Settings —
i_showInducement = input.bool(true, "Show Inducement Level",       group="Visual Settings")
i_showSweep      = input.bool(true, "Show Sweep Marker",           group="Visual Settings")
i_showMss        = input.bool(true, "Show MSS Break Line",         group="Visual Settings")
i_showStatus     = input.bool(true, "Show Pipeline Status Label",  group="Visual Settings",
     tooltip="Displays a small label near price showing which stage the active bullish/bearish setup is currently in.")

i_bullColor  = input.color(#00C896, "Bullish Color",    group="Visual Settings")
i_bearColor  = input.color(#E53935, "Bearish Color",    group="Visual Settings")
i_indColor   = input.color(#D4A017, "Inducement Color", group="Visual Settings")
i_mssColor   = input.color(#29B6F6, "MSS Color",        group="Visual Settings")
i_sweepColor = input.color(#FF9800, "Sweep Marker Color", group="Visual Settings")

// — Alert Settings —
i_alertInducement = input.bool(true,  "Alert: Inducement Identified", group="Alert Settings")
i_alertSweep      = input.bool(true,  "Alert: Inducement Swept",      group="Alert Settings")
i_alertEntry      = input.bool(true,  "Alert: Entry Signal",          group="Alert Settings")
i_alertInvalid    = input.bool(false, "Alert: Setup Invalidated",     group="Alert Settings")

// ─────────────────────────────────────────────────────────────────────────────
// CORE CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────

atr = ta.atr(i_atrLen)

// Confirmed swing pivots (non-repainting — value only known i_xLen bars later)
extHi = ta.pivothigh(high, i_extLen, i_extLen)
extLo = ta.pivotlow(low,  i_extLen, i_extLen)
intHi = ta.pivothigh(high, i_intLen, i_intLen)
intLo = ta.pivotlow(low,  i_intLen, i_intLen)

bodySize   = math.abs(close - open)
barRange   = high - low
closePosUp = barRange > 0 ? (close - low)  / barRange : 0.5   // 1.0 = closed at the high (strong bull rejection)
closePosDn = barRange > 0 ? (high - close) / barRange : 0.5   // 1.0 = closed at the low  (strong bear rejection)

// ─────────────────────────────────────────────────────────────────────────────
// STATE MACHINE VARIABLES
// Stage codes: 0 = idle | 1 = inducement pending sweep | 2 = swept, awaiting MSS
//              3 = MSS confirmed, awaiting optional retest
// ─────────────────────────────────────────────────────────────────────────────

// Bullish pipeline
var int   bullStage         = 0
var float bullExtLow        = na
var float bullIndLow        = na
var int   bullIndBar         = na
var float bullMssHigh       = na
var int   bullMssBar        = na
var int   bullSweepBar      = na
var float bullSweepLow      = na
var float bullDispBody      = na
var float bullWickQ         = na
var float bullPendingIQI    = na
var int   bullRetestStartBar= na
var line  bullIndLine       = na
var line  bullMssLine       = na
var label bullStatusLbl     = na

// Bearish pipeline
var int   bearStage          = 0
var float bearExtHigh        = na
var float bearIndHigh        = na
var int   bearIndBar         = na
var float bearMssLow         = na
var int   bearMssBar         = na
var int   bearSweepBar       = na
var float bearSweepHigh      = na
var float bearDispBody       = na
var float bearWickQ          = na
var float bearPendingIQI     = na
var int   bearRetestStartBar = na
var line  bearIndLine        = na
var line  bearMssLine        = na
var label bearStatusLbl      = na

// Per-bar event flags, reset every bar — drive alertcondition() below
bool bullEntryEvent = false
bool bearEntryEvent = false
bool bullSweepEvent = false
bool bearSweepEvent = false

// Continuously-tracked most recent internal pivot — used to snapshot the MSS
// break level at the exact moment an inducement candidate is identified.
var float lastIntHigh    = na
var int   lastIntHighBar = na
var float lastIntLow     = na
var int   lastIntLowBar  = na

if not na(intHi)
    lastIntHigh    := intHi
    lastIntHighBar := bar_index - i_intLen
if not na(intLo)
    lastIntLow    := intLo
    lastIntLowBar := bar_index - i_intLen

// ─────────────────────────────────────────────────────────────────────────────
// IQI ENGINE — Inducement Quality Index (0-100)
// Four weighted factors unique to inducement-based setups. Each contributes
// up to 25 points. Displacement and rejection wick quality reward genuine
// engineered reversals; freshness and depth reward meaningful, recent
// structure rather than stale or shallow noise.
// ─────────────────────────────────────────────────────────────────────────────
calcIQI(bodyAtBreak, sweepBarIdx, indBarIdx, indPrice, extPrice, wickQuality) =>
    // 1. Displacement strength — reversal body relative to ATR (0-25)
    float dispScore = math.min(bodyAtBreak / (atr * 2.0), 1.0) * 25.0

    // 2. Sweep freshness — fewer bars between inducement and sweep = higher (0-25)
    int   sweepDelay = sweepBarIdx - indBarIdx
    float freshScore = math.max(0.0, 1.0 - (sweepDelay / float(i_maxSweepBars))) * 25.0

    // 3. Liquidity depth — ATR-normalized distance between the inducement and
    //    its anchoring external level. Deeper structure implies a more
    //    meaningful engineered pool rather than micro noise. (0-25)
    float depthAtr   = atr > 0 ? math.abs(indPrice - extPrice) / atr : 0.0
    float depthScore = math.min(depthAtr / 3.0, 1.0) * 25.0

    // 4. Rejection wick quality — how decisively the sweep bar closed away
    //    from its extreme, i.e. how strong the rejection was. (0-25)
    float wickScore = wickQuality * 25.0

    int iqiFinal = int(math.round(math.min(dispScore + freshScore + depthScore + wickScore, 100.0)))
    iqiFinal

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY SIGNAL HELPERS
// Draws the entry label + optional trade level lines and fires the entry
// alert. Setups scoring below the IQI threshold are still tracked by the
// state machine (so the pipeline stays accurate) but are suppressed here —
// only meaningful, high-probability signals reach the chart and alerts.
// ─────────────────────────────────────────────────────────────────────────────
fireBullEntry(iqi, entryPrice, stopPrice) =>
    if iqi >= i_iqiThresh
        _risk   = entryPrice - stopPrice
        _target = entryPrice + _risk * i_rr
        label.new(bar_index, stopPrice, "LONG  ·  IQI " + str.tostring(iqi, "#"),
             style=label.style_label_up, color=i_bullColor,
             textcolor=color.white, size=size.normal)
        if i_showLevels and _risk > 0
            line.new(bar_index, entryPrice, bar_index + i_projBars, entryPrice,
                 color=i_entryColor, style=line.style_dashed, width=1)
            line.new(bar_index, stopPrice, bar_index + i_projBars, stopPrice,
                 color=i_stopColor, style=line.style_dotted, width=1)
            line.new(bar_index, _target, bar_index + i_projBars, _target,
                 color=i_targetColor, style=line.style_dotted, width=1)
        if i_alertEntry
            alert("LONG Entry Signal on " + syminfo.ticker + " [" + timeframe.period +
                 "] | IQI: " + str.tostring(iqi, "#") + " | Entry: " + str.tostring(entryPrice) +
                 " | Stop: " + str.tostring(stopPrice), alert.freq_once_per_bar_close)

fireBearEntry(iqi, entryPrice, stopPrice) =>
    if iqi >= i_iqiThresh
        _risk   = stopPrice - entryPrice
        _target = entryPrice - _risk * i_rr
        label.new(bar_index, stopPrice, "SHORT  ·  IQI " + str.tostring(iqi, "#"),
             style=label.style_label_down, color=i_bearColor,
             textcolor=color.white, size=size.normal)
        if i_showLevels and _risk > 0
            line.new(bar_index, entryPrice, bar_index + i_projBars, entryPrice,
                 color=i_entryColor, style=line.style_dashed, width=1)
            line.new(bar_index, stopPrice, bar_index + i_projBars, stopPrice,
                 color=i_stopColor, style=line.style_dotted, width=1)
            line.new(bar_index, _target, bar_index + i_projBars, _target,
                 color=i_targetColor, style=line.style_dotted, width=1)
        if i_alertEntry
            alert("SHORT Entry Signal on " + syminfo.ticker + " [" + timeframe.period +
                 "] | IQI: " + str.tostring(iqi, "#") + " | Entry: " + str.tostring(entryPrice) +
                 " | Stop: " + str.tostring(stopPrice), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// BULLISH PIPELINE
// Sequence: External Low (real liquidity pool) -> an Internal Low forms
// above it (inducement candidate, where retail stops cluster) -> price
// sweeps the inducement low with a strong bullish displacement close ->
// price breaks the internal high recorded between the inducement and the
// sweep (Market Structure Shift) -> entry signal (optionally after retest).
// ─────────────────────────────────────────────────────────────────────────────

// Track the most recent confirmed external low as the anchor liquidity pool
var float lastExtLow    = na
var int   lastExtLowBar = na
if not na(extLo)
    lastExtLow    := extLo
    lastExtLowBar := bar_index - i_extLen

// Stage 0 -> 1: a fresh internal low forming ABOVE the last external low
// is flagged as the inducement candidate.
if bullStage == 0 and not na(intLo) and not na(lastExtLow)
    _indBar = bar_index - i_intLen
    if lastExtLowBar < _indBar and intLo > lastExtLow
        bullStage          := 1
        bullExtLow         := lastExtLow
        bullIndLow         := intLo
        bullIndBar         := _indBar
        bullMssHigh        := lastIntHigh
        bullMssBar         := lastIntHighBar
        if i_showInducement
            bullIndLine := line.new(_indBar, intLo, bar_index, intLo,
                 color=i_indColor, style=line.style_dotted, width=1)
        if i_alertInducement
            alert("Bullish Inducement identified on " + syminfo.ticker +
                 " [" + timeframe.period + "]", alert.freq_once_per_bar_close)

// Stage 1 -> 2: sweep — price wicks below the inducement low then closes
// back above it with genuine displacement (body >= ATR threshold).
if bullStage == 1
    _age = bar_index - bullIndBar
    if _age > i_maxSweepBars
        if not na(bullIndLine)
            line.delete(bullIndLine)
        bullStage := 0
        if i_alertInvalid
            alert("Bullish setup invalidated: inducement went stale on " +
                 syminfo.ticker + " [" + timeframe.period + "]", alert.freq_once_per_bar_close)
    else if low < bullIndLow and close > bullIndLow and bodySize >= atr * i_atrMult
        bullStage      := 2
        bullSweepBar   := bar_index
        bullSweepLow   := low
        bullDispBody   := bodySize
        bullWickQ      := closePosUp
        bullSweepEvent := true
        if not na(bullIndLine)
            line.delete(bullIndLine)
        if i_showSweep
            label.new(bar_index, low, "▲", style=label.style_none,
                 textcolor=i_sweepColor, size=size.small, color=color.new(color.white, 100))
        if i_alertSweep
            alert("Bullish Inducement Swept on " + syminfo.ticker +
                 " [" + timeframe.period + "]", alert.freq_once_per_bar_close)
    else if close < bullExtLow
        // Price broke the external low before sweeping the inducement —
        // the premise of deeper liquidity below is void.
        if not na(bullIndLine)
            line.delete(bullIndLine)
        bullStage := 0
        if i_alertInvalid
            alert("Bullish setup invalidated: external low broken on " +
                 syminfo.ticker + " [" + timeframe.period + "]", alert.freq_once_per_bar_close)

// Stage 2 -> 3/entry: Market Structure Shift — close breaks above the
// internal high recorded between the external low and the inducement.
if bullStage == 2
    _age = bar_index - bullSweepBar
    if _age > i_maxMssBars
        bullStage := 0
        if i_alertInvalid
            alert("Bullish setup invalidated: MSS not confirmed in time on " +
                 syminfo.ticker + " [" + timeframe.period + "]", alert.freq_once_per_bar_close)
    else if not na(bullMssHigh) and close > bullMssHigh
        _iqi = calcIQI(bullDispBody, bullSweepBar, bullIndBar, bullIndLow, bullExtLow, bullWickQ)
        if i_showMss
            bullMssLine := line.new(bullMssBar, bullMssHigh, bar_index, bullMssHigh,
                 color=i_mssColor, style=line.style_dashed, width=1)
        if i_requireRetest
            bullStage           := 3
            bullPendingIQI       := _iqi
            bullRetestStartBar  := bar_index
        else
            bullEntryEvent := true
            fireBullEntry(_iqi, close, bullSweepLow)
            bullStage := 0

// Stage 3: optional retest — the broken MSS level must hold as new support
// on the pullback before the entry signal is confirmed.
if bullStage == 3
    _age = bar_index - bullRetestStartBar
    if close < bullMssHigh
        bullStage := 0
        if i_alertInvalid
            alert("Bullish setup invalidated: retest failed on " +
                 syminfo.ticker + " [" + timeframe.period + "]", alert.freq_once_per_bar_close)
    else if _age > i_maxMssBars
        bullStage := 0
    else if low <= bullMssHigh
        bullEntryEvent := true
        fireBullEntry(bullPendingIQI, close, bullSweepLow)
        bullStage := 0

// ─────────────────────────────────────────────────────────────────────────────
// BEARISH PIPELINE (mirror of the bullish pipeline)
// Sequence: External High (real liquidity pool) -> an Internal High forms
// below it (inducement candidate) -> price sweeps the inducement high with
// a strong bearish displacement close -> price breaks the internal low
// recorded between the inducement and the sweep (MSS) -> entry signal
// (optionally after retest).
// ─────────────────────────────────────────────────────────────────────────────

var float lastExtHigh    = na
var int   lastExtHighBar = na
if not na(extHi)
    lastExtHigh    := extHi
    lastExtHighBar := bar_index - i_extLen

// Stage 0 -> 1: a fresh internal high forming BELOW the last external high
// is flagged as the inducement candidate.
if bearStage == 0 and not na(intHi) and not na(lastExtHigh)
    _indBar = bar_index - i_intLen
    if lastExtHighBar < _indBar and intHi < lastExtHigh
        bearStage   := 1
        bearExtHigh := lastExtHigh
        bearIndHigh := intHi
        bearIndBar  := _indBar
        bearMssLow  := lastIntLow
        bearMssBar  := lastIntLowBar
        if i_showInducement
            bearIndLine := line.new(_indBar, intHi, bar_index, intHi,
                 color=i_indColor, style=line.style_dotted, width=1)
        if i_alertInducement
            alert("Bearish Inducement identified on " + syminfo.ticker +
                 " [" + timeframe.period + "]", alert.freq_once_per_bar_close)

// Stage 1 -> 2: sweep — price wicks above the inducement high then closes
// back below it with genuine displacement (body >= ATR threshold).
if bearStage == 1
    _age = bar_index - bearIndBar
    if _age > i_maxSweepBars
        if not na(bearIndLine)
            line.delete(bearIndLine)
        bearStage := 0
        if i_alertInvalid
            alert("Bearish setup invalidated: inducement went stale on " +
                 syminfo.ticker + " [" + timeframe.period + "]", alert.freq_once_per_bar_close)
    else if high > bearIndHigh and close < bearIndHigh and bodySize >= atr * i_atrMult
        bearStage      := 2
        bearSweepBar   := bar_index
        bearSweepHigh  := high
        bearDispBody   := bodySize
        bearWickQ      := closePosDn
        bearSweepEvent := true
        if not na(bearIndLine)
            line.delete(bearIndLine)
        if i_showSweep
            label.new(bar_index, high, "▼", style=label.style_none,
                 textcolor=i_sweepColor, size=size.small, color=color.new(color.white, 100))
        if i_alertSweep
            alert("Bearish Inducement Swept on " + syminfo.ticker +
                 " [" + timeframe.period + "]", alert.freq_once_per_bar_close)
    else if close > bearExtHigh
        // Price broke the external high before sweeping the inducement —
        // the premise of deeper liquidity above is void.
        if not na(bearIndLine)
            line.delete(bearIndLine)
        bearStage := 0
        if i_alertInvalid
            alert("Bearish setup invalidated: external high broken on " +
                 syminfo.ticker + " [" + timeframe.period + "]", alert.freq_once_per_bar_close)

// Stage 2 -> 3/entry: Market Structure Shift — close breaks below the
// internal low recorded between the external high and the inducement.
if bearStage == 2
    _age = bar_index - bearSweepBar
    if _age > i_maxMssBars
        bearStage := 0
        if i_alertInvalid
            alert("Bearish setup invalidated: MSS not confirmed in time on " +
                 syminfo.ticker + " [" + timeframe.period + "]", alert.freq_once_per_bar_close)
    else if not na(bearMssLow) and close < bearMssLow
        _iqi = calcIQI(bearDispBody, bearSweepBar, bearIndBar, bearIndHigh, bearExtHigh, bearWickQ)
        if i_showMss
            bearMssLine := line.new(bearMssBar, bearMssLow, bar_index, bearMssLow,
                 color=i_mssColor, style=line.style_dashed, width=1)
        if i_requireRetest
            bearStage           := 3
            bearPendingIQI       := _iqi
            bearRetestStartBar  := bar_index
        else
            bearEntryEvent := true
            fireBearEntry(_iqi, close, bearSweepHigh)
            bearStage := 0

// Stage 3: optional retest — the broken MSS level must hold as new
// resistance on the pullback before the entry signal is confirmed.
if bearStage == 3
    _age = bar_index - bearRetestStartBar
    if close > bearMssLow
        bearStage := 0
        if i_alertInvalid
            alert("Bearish setup invalidated: retest failed on " +
                 syminfo.ticker + " [" + timeframe.period + "]", alert.freq_once_per_bar_close)
    else if _age > i_maxMssBars
        bearStage := 0
    else if high >= bearMssLow
        bearEntryEvent := true
        fireBearEntry(bearPendingIQI, close, bearSweepHigh)
        bearStage := 0

// ─────────────────────────────────────────────────────────────────────────────
// PIPELINE STATUS LABELS
// A single, small, continuously-updated label per active direction shows
// which stage the setup is in. Removed automatically once the setup
// resolves or invalidates, keeping the chart clean rather than cluttered
// with permanent markers.
// ─────────────────────────────────────────────────────────────────────────────
bullStageText(stg) =>
    switch stg
        1 => "Bull: Awaiting Sweep"
        2 => "Bull: Awaiting MSS"
        3 => "Bull: Awaiting Retest"
        => ""

bearStageText(stg) =>
    switch stg
        1 => "Bear: Awaiting Sweep"
        2 => "Bear: Awaiting MSS"
        3 => "Bear: Awaiting Retest"
        => ""

if i_showStatus
    if bullStage > 0
        _txt = bullStageText(bullStage)
        if na(bullStatusLbl)
            bullStatusLbl := label.new(bar_index, low - atr, _txt,
                 style=label.style_label_up, color=color.new(i_bullColor, 85),
                 textcolor=i_bullColor, size=size.tiny)
        else
            label.set_xy(bullStatusLbl, bar_index, low - atr)
            label.set_text(bullStatusLbl, _txt)
    else if not na(bullStatusLbl)
        label.delete(bullStatusLbl)
        bullStatusLbl := na

    if bearStage > 0
        _txt = bearStageText(bearStage)
        if na(bearStatusLbl)
            bearStatusLbl := label.new(bar_index, high + atr, _txt,
                 style=label.style_label_down, color=color.new(i_bearColor, 85),
                 textcolor=i_bearColor, size=size.tiny)
        else
            label.set_xy(bearStatusLbl, bar_index, high + atr)
            label.set_text(bearStatusLbl, _txt)
    else if not na(bearStatusLbl)
        label.delete(bearStatusLbl)
        bearStatusLbl := na

// ─────────────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS
// alertcondition() entries populate the TradingView "Create Alert" dropdown.
// The dynamic alert() calls throughout the pipelines above deliver the
// richer, context-specific messages (ticker, timeframe, IQI, price levels).
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(bullSweepEvent, "Bullish Inducement Swept",
     "Bullish inducement liquidity swept on {{ticker}} [{{interval}}]")
alertcondition(bearSweepEvent, "Bearish Inducement Swept",
     "Bearish inducement liquidity swept on {{ticker}} [{{interval}}]")
alertcondition(bullEntryEvent, "Long Entry Signal",
     "Long entry signal confirmed on {{ticker}} [{{interval}}]")
alertcondition(bearEntryEvent, "Short Entry Signal",
     "Short entry signal confirmed on {{ticker}} [{{interval}}]")
````
