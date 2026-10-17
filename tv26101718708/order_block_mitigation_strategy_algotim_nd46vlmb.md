# Order Block Mitigation Strategy [algotim]

- url: https://www.tradingview.com/script/ND46VLmB-Order-Block-Mitigation-Strategy-algotim/
- type: indicator
- pine_id: PUB;bb43971d87234b889a87fdc2bf8ae924
- version: 1.0

## Description

[b]Overview[/b]
Order Block Mitigation Strategy identifies bullish and bearish order blocks from confirmed structure breaks and tracks the exact degree to which each zone has been consumed by subsequent price action. Rather than treating every order block as equally tradable, the script continuously measures how deep into a zone price has traveled and only signals reactions occurring at zones that are still statistically fresh, while allowing the trader to see heavily used zones visibly fade on the chart.

[b]Problem Statement[/b]
Most order block tools draw a zone once and leave it static until price closes through it entirely. This binary treatment ignores a critical distinction: a zone that has been wicked into by 10% of its range carries very different odds than one that has already been penetrated 70% of the way through. Traders using static zones frequently take reaction entries at institutional levels that have already been substantially absorbed, with no way to quantify how much of the zone's liquidity remains untouched.

[b]Methodology[/b]
Structure is established using confirmed swing pivots. A Break of Structure is only confirmed on a bar close that clears the swing level by a minimum ATR-based buffer, filtering marginal breaks. Once a break is confirmed, the script scans backward from the broken pivot for the last opposite-colored candle within a fixed window, since this candle (not the pivot bar itself) is the true origin of the displacement leg. That candle's high-low range becomes the order block, provided its range also exceeds a minimum ATR multiple.

From the moment a zone is created, the script tracks the deepest price extreme that has traded into it on every confirmed bar. This extreme can only advance in the direction of consumption, never retreat, and from it a Mitigation Percentage is calculated as the proportion of the zone's height that has been traded through. This percentage is classified into one of four bands (Fresh, Light, Moderate, Heavy) using user-defined thresholds, and a fifth state (Invalidated) removes the zone once the percentage crosses a final threshold.

The Mitigation Percentage also drives the zone's fill transparency directly, on a continuous interpolation between a fresh-zone opacity and a near-invalid opacity. A zone at 10% mitigation renders visibly more solid than one at 55%, and the fade is smooth rather than stepped between discrete color states. This means zone health can be read from the chart at a glance without a label or panel.

Entry signals are only evaluated at zones whose live Mitigation Percentage has not yet exceeded a separate, user-defined entry cap. When price trades into a qualifying zone, the closed candle is checked against a selectable rejection pattern (a dominant wick, an engulfing candle, a strong directional close, or a combination of wick and close). Optional filters can additionally require the candle to close beyond the zone's midpoint, require the candle's range to exceed an ATR multiple, and require volume above its rolling average. Each signal is issued once per zone's lifecycle.

Every signal carries a composite confidence score built from five equally weighted, disclosed factors: the ATR-normalized strength of the structure break that created the zone, the ATR-normalized size of the origin candle, the zone's freshness at the moment of the signal (the inverse of its mitigation percentage), the expansion of ATR since the zone was formed, and the ATR-normalized distance price traveled from the origin candle to the structure break. The score is displayed next to the signal marker.

[b]Signal Workflow[/b]
Step 1: A swing high or low is confirmed once the required number of bars exist on both sides.
Step 2: A close beyond that swing level by the minimum ATR buffer confirms a Break of Structure.
Step 3: The script scans backward from the broken pivot for the last opposite-colored candle and builds the order block from its full range, provided the candle passes the minimum impulse size filter.
Step 4: On every subsequent confirmed bar, the zone's deepest intrusion is ratcheted forward and the Mitigation Percentage is recalculated, driving both the quality band and the continuous fade.
Step 5: When price re-enters a zone below the entry mitigation cap and a rejection pattern confirms on the closed candle, along with any enabled midpoint, ATR-expansion, and volume filters, a scored entry signal is generated.

[b]Why This Indicator Is Different[/b]
Zone consumption is tracked as a continuous, monotonically increasing percentage rather than a binary tested or mitigated flag, so the trader always knows how much of a zone's original range remains untouched.
Fill transparency is interpolated in real time directly from that percentage, making zone health visible without any label, table, or dashboard.
The order block's origin candle is located by scanning back from the structure break for the true opposite-colored displacement candle, rather than defaulting to the pivot candle itself.
Entry signals are gated by a separate, independently configurable mitigation cap, so a trader can permit signals only at zones that remain within a defined freshness range.
Every signal discloses a five-factor confidence score built from break displacement, origin candle size, live freshness, ATR expansion since formation, and travel distance, so the score can be audited rather than trusted blindly.

[b]Inputs[/b]

Detection
Swing Pivot Length
ATR Length
Min BOS Size (x ATR)
Min Impulse Candle Size (x ATR)

[b]Zones[/b]
Maximum Zones (per side)
Zone Extension
Fixed Extension Length
Show Zone Midline
Dynamic Opacity by Mitigation %

[b]Mitigation[/b]
Fresh Threshold %
Partial Threshold %
Heavy Threshold %
Invalidate Threshold %

[b]Entries[/b]
Enable Entry Signals
Max Mitigation % Allowed for Entry
Rejection Pattern
Require Close Beyond Zone Midpoint
Require ATR Expansion
Require Volume Confirmation
High Confidence Threshold %

[b]Appearance
[/b]Bullish Zone Color
Bearish Zone Color
Fresh Zone Transparency
Near-Invalid Zone Transparency
Signal Marker Size

[b]Alerts[/b]
Enable All Alerts
Alert: New Order Block
Alert: Mitigation Milestones
Alert: Entry Signals

[b]Alerts[/b]
Alerts are available for:
New Bullish Order Block formed
New Bearish Order Block formed
Bullish Order Block Partial Mitigation
Bearish Order Block Partial Mitigation
Bullish Order Block Heavy Mitigation
Bearish Order Block Heavy Mitigation
Bullish Order Block Invalidated
Bearish Order Block Invalidated
Bullish Rejection Entry
Bearish Rejection Entry
Premium Entry (High Confidence)

[b]Practical Usage[/b]
Lower the Max Mitigation % Allowed for Entry to restrict signals to only the freshest zones, or raise it to also capture reaction trades at moderately used levels.
Watch the continuous fade of a zone as a visual proxy for its remaining reliability without needing to check a percentage value directly.
Use the disclosed confidence score to compare two simultaneous signals rather than treating every marker as equally weighted.
Switch Zone Extension to Until New BOS on trending instruments to stop a zone from extending once the opposing side of structure has broken.
Combine the ATR expansion and volume filters on the Entries tab when trading instruments where displacement quality varies significantly by session.

[b]Limitations[/b]
Swing pivot confirmation introduces a lag equal to the pivot length setting, meaning a structure break can only be evaluated after that many bars have closed beyond the pivot.
The origin candle scan is bounded by a fixed lookback window, so on unusually extended displacement legs the true origin candle may fall outside that window and no zone will be created.
The confidence score is a disclosed, equally weighted composite of five factors and is not a probability of trade success.
Order blocks and their mitigation state are a price-action framework, not a standalone trading system, and should be evaluated alongside broader market context.

[b]Notes[/b]
All detection, structure break, mitigation state, and entry logic execute strictly on confirmed bars, so no drawing, classification, or alert changes retroactively once printed.
Zone counts per direction are capped, with the oldest zone removed first once the limit is reached, keeping drawing object usage bounded regardless of session length.
alert() calls are used for every event category so a single "Any alert() function call" condition in the TradingView alert dialog captures all messages from this script.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════
// Order Block Mitigation Strategy [algotim]
// Author : algotim
// Version: 1.0.0
//
// ── WHAT THIS SCRIPT DOES ─────────────────────────────────────────
// This is not another order block drawer. It answers one question
// for every institutional zone it plots: is this block still fresh
// enough to trade, or has it already been consumed?
//
// Pipeline (all steps run on confirmed data only):
//   1. Confirmed swing highs/lows (ta.pivothigh/low).
//   2. A Break of Structure (BOS) is confirmed only on a bar CLOSE
//      that clears the swing level by a minimum ATR displacement.
//   3. The order block's origin candle is located by scanning back
//      from the broken swing pivot for the last opposite-colored
//      candle within a fixed lookback (the true source of the
//      displacement leg).
//   4. A zone is created from that candle's full range (high/low),
//      with its midpoint cached for later use.
//
// ── CORE INNOVATION: CONTINUOUS MITIGATION ENGINE ─────────────────
// Instead of a binary "mitigated / not mitigated" flag, every zone
// carries a running Mitigation % computed every confirmed bar:
//     bullish zone: (zoneTop - deepestLowSeen) / zoneHeight * 100
//     bearish zone: (deepestHighSeen - zoneBot) / zoneHeight * 100
// This value is a ratchet — it can only grow, never shrink — and it
// directly drives TWO things simultaneously:
//   • A five-tier quality classification (Fresh / Light / Moderate /
//     Heavy / Invalidated) built from four user-defined thresholds.
//   • A continuously INTERPOLATED fill transparency (not a stepped
//     color swap). The box visibly fades in real time as price eats
//     into it, and disappears outright once the Invalidate threshold
//     is crossed. No labels are needed to read zone health — the
//     opacity itself is the readout.
//
// ── SMART REJECTION ENTRIES ───────────────────────────────────────
// A signal only fires once per zone (no repeat spam) and only when
// price is inside a zone that hasn't been mitigated beyond a user
// cap, AND a selectable rejection pattern confirms on a closed bar
// (Long Wick / Engulfing / Strong Close / Wick+Close combo), with
// optional midpoint-reclaim, ATR-expansion and volume filters.
//
// ── INSTITUTIONAL CONFIDENCE SCORE ────────────────────────────────
// Every signal carries a disclosed 0-100 confidence score averaging
// five factors: structure-break displacement, origin candle impulse
// size, current freshness (100 - Mitigation %), ATR expansion since
// the zone was born, and distance traveled before the retest. Shown
// only beside the signal marker — no dashboard, no clutter.
//
// ── NON-REPAINTING DESIGN ──────────────────────────────────────────
// Swing pivots confirm only once i_swingLen bars exist on both sides.
// BOS detection, band transitions, invalidation and entry signals are
// all gated on barstate.isconfirmed. Nothing referenced is a future
// bar. Once printed, no drawing or alert changes retroactively.
// ══════════════════════════════════════════════════════════════════

indicator(
     title            = "Order Block Mitigation Strategy [algotim]",
     shorttitle       = "OB Mitigation [algotim]",
     overlay          = true,
     max_bars_back    = 500,
     max_boxes_count  = 300,
     max_labels_count = 300,
     max_lines_count  = 300)

// ──────────────────────────────────────────────────────────────────
// SECTION 1 — INPUTS
// ──────────────────────────────────────────────────────────────────
GRP_DET   = "Detection"
GRP_ZONE  = "Zones"
GRP_MIT   = "Mitigation"
GRP_ENTRY = "Entries"
GRP_APP   = "Appearance"
GRP_ALERT = "Alerts"

// ── Detection ────────────────────────────────────────────────────
i_swingLen = input.int(10, "Swing Pivot Length", minval = 3, maxval = 50,
     group   = GRP_DET,
     tooltip = "Bars required on each side to confirm a swing high/low. Drives both order block placement and BOS structure breaks. Higher = fewer, stronger zones.")

i_atrLen = input.int(14, "ATR Length", minval = 5, maxval = 50,
     group   = GRP_DET,
     tooltip = "ATR period used throughout the script for displacement filters, mitigation transparency scaling and the confidence score.")

i_minBosAtr = input.float(0.25, "Min BOS Size (× ATR)", minval = 0.0, step = 0.05,
     group   = GRP_DET,
     tooltip = "The breaking candle's close must clear the swing level by this ATR multiple before a Break of Structure is confirmed. Filters marginal, low-conviction breaks.")

i_minImpulseAtr = input.float(0.5, "Min Impulse Candle Size (× ATR)", minval = 0.0, step = 0.05,
     group   = GRP_DET,
     tooltip = "The order block's origin candle must exceed this ATR multiple in range. Filters thin, insignificant candles from becoming zones.")

// ── Zones ────────────────────────────────────────────────────────
i_maxZones = input.int(12, "Maximum Zones (per side)", minval = 2, maxval = 50,
     group   = GRP_ZONE,
     tooltip = "Oldest active zone is removed first once this limit is reached, per direction. Keeps the chart focused on the most recent institutional activity.")

i_extMode = input.string("Until Invalidated", "Zone Extension",
     options = ["Until Invalidated", "Fixed Bars", "Until New BOS"],
     group   = GRP_ZONE,
     tooltip = "Until Invalidated: zone grows right until it's mitigated past the Invalidate threshold.\nFixed Bars: zone stops growing after a set number of bars.\nUntil New BOS: zone stops growing the moment an opposing structure break occurs.")

i_extBars = input.int(150, "Fixed Extension Length (bars)", minval = 20, maxval = 1000,
     group   = GRP_ZONE,
     tooltip = "Used only when Zone Extension is set to Fixed Bars.")

i_showMid = input.bool(true, "Show Zone Midline",
     group   = GRP_ZONE,
     tooltip = "Draws a dashed line through the center of each active zone. Many institutional reactions occur at this midpoint.")

i_dynamicFade = input.bool(true, "Dynamic Opacity by Mitigation %",
     group   = GRP_ZONE,
     tooltip = "When ON, zone fill transparency continuously interpolates with the live Mitigation % — fresh zones render solid, consumed zones fade toward invisible. This is the primary visual language of the indicator.")

// ── Mitigation ───────────────────────────────────────────────────
i_freshPct = input.float(20.0, "Fresh Threshold (%)", minval = 1.0, maxval = 100.0, step = 1.0,
     group   = GRP_MIT,
     tooltip = "Mitigation % below this value classifies a zone as Fresh (highest probability).")

i_partialPct = input.float(40.0, "Partial Threshold (%)", minval = 1.0, maxval = 150.0, step = 1.0,
     group   = GRP_MIT,
     tooltip = "Mitigation % below this value (and above Fresh) classifies a zone as Light Mitigation.")

i_heavyPct = input.float(60.0, "Heavy Threshold (%)", minval = 1.0, maxval = 150.0, step = 1.0,
     group   = GRP_MIT,
     tooltip = "Mitigation % below this value (and above Partial) classifies a zone as Moderate Mitigation. At or above it, the zone is Heavily Mitigated.")

i_invalidatePct = input.float(100.0, "Invalidate Threshold (%)", minval = 1.0, maxval = 200.0, step = 1.0,
     group   = GRP_MIT,
     tooltip = "Mitigation % at or above this value invalidates and removes the zone. 100% represents a full breach through the far edge of the zone.")

// ── Entries ──────────────────────────────────────────────────────
i_enableEntries = input.bool(true, "Enable Entry Signals",
     group = GRP_ENTRY)

i_maxMitForEntry = input.float(60.0, "Max Mitigation % Allowed for Entry", minval = 0.0, maxval = 150.0, step = 1.0,
     group   = GRP_ENTRY,
     tooltip = "Zones mitigated beyond this percentage are ignored by the entry engine, even if a rejection pattern appears.")

i_rejectionType = input.string("Wick + Close", "Rejection Pattern",
     options = ["Long Wick", "Engulfing", "Strong Close", "Wick + Close"],
     group   = GRP_ENTRY,
     tooltip = "Long Wick: rejecting wick ≥ 50% of candle range.\nEngulfing: candle engulfs the prior candle's body in the reaction direction.\nStrong Close: candle closes in the outer 25% of its range.\nWick + Close: requires both the wick and strong-close conditions together (strictest).")

i_useMidFilter = input.bool(true, "Require Close Beyond Zone Midpoint",
     group = GRP_ENTRY,
     tooltip = "Requires the rejection candle to close beyond the zone's midline, confirming the reaction traveled through the most contested part of the zone.")

i_useAtrFilter = input.bool(false, "Require ATR Expansion",
     group = GRP_ENTRY,
     tooltip = "Requires the rejection candle's range to exceed a multiple of ATR, confirming a genuine expansion move rather than a quiet drift.")

i_atrFilterMult = input.float(1.2, "ATR Expansion Multiplier", minval = 1.0, maxval = 3.0, step = 0.1,
     group = GRP_ENTRY)

i_useVolFilter = input.bool(false, "Require Volume Confirmation",
     group = GRP_ENTRY,
     tooltip = "Requires the rejection candle's volume to exceed a multiple of its rolling average.")

i_volMaLen = input.int(20, "Volume MA Length", minval = 5, maxval = 100,
     group = GRP_ENTRY)

i_volMult = input.float(1.2, "Volume Multiplier", minval = 0.5, maxval = 5.0, step = 0.1,
     group = GRP_ENTRY)

i_highConfThresh = input.int(75, "High Confidence Threshold (%)", minval = 50, maxval = 95,
     group   = GRP_ENTRY,
     tooltip = "Signals scoring at or above this confidence value additionally raise the High Confidence / Premium Entry alert.")

// ── Appearance ───────────────────────────────────────────────────
i_bullColor = input.color(#26a69a, "Bullish Zone Color", group = GRP_APP)
i_bearColor = input.color(#ef5350, "Bearish Zone Color", group = GRP_APP)

i_freshTransp = input.int(15, "Fresh Zone Transparency", minval = 0, maxval = 50,
     group   = GRP_APP,
     tooltip = "Fill transparency applied to a brand-new, untested zone. Lower = more solid/opaque.")

i_invalidTransp = input.int(95, "Near-Invalid Zone Transparency", minval = 70, maxval = 98,
     group   = GRP_APP,
     tooltip = "Fill transparency approached as a zone nears the Invalidate threshold. Higher = more transparent, fading toward invisible.")

i_signalSize = input.string("Normal", "Signal Marker Size", options = ["Tiny", "Small", "Normal"],
     group = GRP_APP)

// ── Alerts ───────────────────────────────────────────────────────
i_alertsEnabled = input.bool(true, "Enable All Alerts", group = GRP_ALERT)
i_alertOB       = input.bool(true, "Alert: New Order Block", group = GRP_ALERT)
i_alertMit      = input.bool(true, "Alert: Mitigation Milestones", group = GRP_ALERT)
i_alertEntry    = input.bool(true, "Alert: Entry Signals", group = GRP_ALERT)

// ──────────────────────────────────────────────────────────────────
// SECTION 2 — TYPES
// ──────────────────────────────────────────────────────────────────
type OrderBlock
    bool  isBull        // true = bullish (demand) zone, false = bearish (supply) zone
    float top            // zone upper boundary
    float bot            // zone lower boundary
    float mid            // zone midpoint (cached)
    int   birthBar        // bar index of the origin candle
    float deepest         // ratcheted extreme price reached inside the zone
    float mitPct          // running Mitigation % (monotonic, never decreases)
    int   band            // 0=Fresh 1=Light 2=Moderate 3=Heavy (Invalidated = removed, not stored)
    bool  signaled         // true once an entry signal has fired for this zone's lifecycle
    bool  frozen           // true once the zone has stopped extending (extension-mode dependent)
    float dispAtr          // BOS displacement strength, in ATR multiples, at creation
    float impulseAtr        // origin candle range, in ATR multiples, at creation
    float birthAtrVal        // ATR value at the moment the zone was created
    float distanceAtr        // distance traveled from origin to the BOS bar, in ATR multiples
    box   zoneBox
    line  midLine

// ──────────────────────────────────────────────────────────────────
// SECTION 3 — PERSISTENT STATE
// ──────────────────────────────────────────────────────────────────
var OrderBlock[] bullOBs = array.new<OrderBlock>()
var OrderBlock[] bearOBs = array.new<OrderBlock>()

var float lastSwingHigh = na
var float lastSwingLow  = na
var int   lastSHBar     = na
var int   lastSLBar     = na
var bool  highBroken    = false
var bool  lowBroken     = false


// Per-bar event flags used to drive alert() exactly once per qualifying
// bar close. Stored as single-element arrays because Pine Script v6
// forbids user-defined functions from reassigning outer-scope plain
// variables — arrays are reference types, so array.set() from inside a
// function is legal and this is the standard workaround.
var bool[] evt_newBullOB     = array.new<bool>(1, false)
var bool[] evt_newBearOB     = array.new<bool>(1, false)
var bool[] evt_bullPartial   = array.new<bool>(1, false)
var bool[] evt_bearPartial   = array.new<bool>(1, false)
var bool[] evt_bullHeavy     = array.new<bool>(1, false)
var bool[] evt_bearHeavy     = array.new<bool>(1, false)
var bool[] evt_bullInvalid   = array.new<bool>(1, false)
var bool[] evt_bearInvalid   = array.new<bool>(1, false)
var bool[] evt_buySignal     = array.new<bool>(1, false)
var bool[] evt_sellSignal    = array.new<bool>(1, false)
var bool[] evt_highConfBuy   = array.new<bool>(1, false)
var bool[] evt_highConfSell  = array.new<bool>(1, false)

var float[] lastEvtTop = array.new<float>(1, na)
var float[] lastEvtBot = array.new<float>(1, na)


// ──────────────────────────────────────────────────────────────────
// SECTION 4 — UTILITY FUNCTIONS
// ──────────────────────────────────────────────────────────────────
atr   = ta.atr(i_atrLen)
volMa = ta.sma(volume, i_volMaLen)


// Clip a value into [0, 100].
f_clip100(float v) => math.max(0.0, math.min(100.0, v))

// ── Rejection pattern detection (evaluated on the confirmed bar) ───
// Long Wick: the wick opposing the reaction direction covers at
// least half the candle's total range.
f_longWick(bool isBull) =>
    float rng = high - low
    if rng <= 0
        false
    else
        float wick = isBull ? (math.min(open, close) - low) : (high - math.max(open, close))
        (wick / rng) >= 0.5

// Engulfing: candle body engulfs the prior candle's body in the
// reaction direction.
f_engulfing(bool isBull) =>
    isBull ? (close > open and close > open[1] and open <= close[1]) :
             (close < open and close < open[1] and open >= close[1])

// Strong Close: candle closes within the outer 25% of its own range,
// in the reaction direction.
f_strongClose(bool isBull) =>
    float rng = high - low
    if rng <= 0
        false
    else
        isBull ? ((close - low) / rng) >= 0.75 : ((high - close) / rng) >= 0.75

// Combined rejection filter dispatcher, per user selection.
f_rejectionOk(bool isBull) =>
    switch i_rejectionType
        "Long Wick"     => f_longWick(isBull)
        "Engulfing"     => f_engulfing(isBull)
        "Strong Close"  => f_strongClose(isBull)
        "Wick + Close"  => f_longWick(isBull) and f_strongClose(isBull)
        => false

// ATR expansion filter: current candle range must exceed a multiple
// of ATR, confirming genuine displacement rather than a quiet drift.
f_atrExpansionOk() =>
    not i_useAtrFilter or (atr > 0 and (high - low) >= atr * i_atrFilterMult)

// Volume confirmation filter.
f_volumeOk() =>
    not i_useVolFilter or (volMa > 0 and volume / volMa >= i_volMult)

// ── Confidence score sub-factors (each returns 0-100) ──────────────
// Structure-break displacement strength, capped at 2.0 ATR = 100.
f_scoreDisp(float dispAtr) => f_clip100((dispAtr / 2.0) * 100.0)

// Origin candle impulse size, capped at 3.0 ATR = 100.
f_scoreImpulse(float impulseAtr) => f_clip100((impulseAtr / 3.0) * 100.0)

// Freshness: inverse of current mitigation percentage.
f_scoreFresh(float mitPct) => f_clip100(100.0 - mitPct)

// ATR expansion since the zone was born (current ATR vs birth ATR),
// capped so a 2x expansion scores 100.
f_scoreAtrExp(float birthAtr) =>
    birthAtr > 0 ? f_clip100(((atr / birthAtr) - 1.0) * 100.0) : 0.0

// Distance traveled from origin candle to the BOS bar, in ATR
// multiples, capped at 4.0 ATR = 100.
f_scoreDistance(float distAtr) => f_clip100((distAtr / 4.0) * 100.0)

// Equally-weighted, five-factor composite confidence score. All five
// inputs are disclosed in the header comments above — no hidden
// weighting, no black-box label.
f_confidenceScore(float dispAtr, float impulseAtr, float mitPct, float birthAtr, float distAtr) =>
    float s1 = f_scoreDisp(dispAtr)
    float s2 = f_scoreImpulse(impulseAtr)
    float s3 = f_scoreFresh(mitPct)
    float s4 = f_scoreAtrExp(birthAtr)
    float s5 = f_scoreDistance(distAtr)
    int(math.round((s1 + s2 + s3 + s4 + s5) / 5.0))

// ── Mitigation band + transparency helpers ─────────────────────────
// Classifies a mitigation percentage into one of four bands. A value
// at or above the Invalidate threshold is handled separately by the
// caller (the zone is deleted, not classified).
f_mitBand(float mitPct) =>
    mitPct < i_freshPct ? 0 : mitPct < i_partialPct ? 1 : mitPct < i_heavyPct ? 2 : 3

// Continuously interpolated transparency: 0% mitigation renders at
// i_freshTransp, and the Invalidate threshold renders at
// i_invalidTransp. This is the core visual innovation — opacity is a
// direct, real-time readout of zone health, not a stepped palette.
f_mitTransp(float mitPct) =>
    float span = math.max(1.0, i_invalidatePct)
    float t    = f_clip100(100.0 * mitPct / span) / 100.0
    int(math.round(i_freshTransp + t * (i_invalidTransp - i_freshTransp)))

// ──────────────────────────────────────────────────────────────────
// SECTION 4.5 — PER-BAR EVENT FLAG RESET

// ──────────────────────────────────────────────────────────────────
// Every alert-worthy flag is cleared at the start of each bar so a
// prior bar's event never leaks into the current one. Flags are only
// ever set to true further down, inside logic already gated on
// barstate.isconfirmed — so on a real-time (unconfirmed) bar they
// simply remain false, and no premature alert can fire.
array.set(evt_newBullOB,    0, false)
array.set(evt_newBearOB,    0, false)
array.set(evt_bullPartial,  0, false)
array.set(evt_bearPartial,  0, false)
array.set(evt_bullHeavy,    0, false)
array.set(evt_bearHeavy,    0, false)
array.set(evt_bullInvalid,  0, false)
array.set(evt_bearInvalid,  0, false)
array.set(evt_buySignal,    0, false)
array.set(evt_sellSignal,   0, false)
array.set(evt_highConfBuy,  0, false)
array.set(evt_highConfSell, 0, false)

// ──────────────────────────────────────────────────────────────────
// SECTION 5 — STRUCTURE ENGINE (confirmed BOS break events)
// ──────────────────────────────────────────────────────────────────

// Confirmed pivots only (ta.pivothigh/low inherently lag i_swingLen
// bars, so they cannot repaint once printed). A structure break fires
// exactly once per swing level — the "broken" flag resets only when a
// fresh pivot replaces the level, preventing the same break from
// re-firing on every subsequent bar beyond it.

float pivHigh = ta.pivothigh(high, i_swingLen, i_swingLen)
float pivLow  = ta.pivotlow(low,  i_swingLen, i_swingLen)

if not na(pivHigh)
    lastSwingHigh := pivHigh
    lastSHBar     := bar_index - i_swingLen
    highBroken    := false

if not na(pivLow)
    lastSwingLow := pivLow
    lastSLBar    := bar_index - i_swingLen
    lowBroken    := false

float bosBuf = atr * i_minBosAtr

bool bosUp   = not na(lastSwingHigh) and not highBroken and barstate.isconfirmed and close > lastSwingHigh + bosBuf
bool bosDown = not na(lastSwingLow)  and not lowBroken   and barstate.isconfirmed and close < lastSwingLow  - bosBuf

if bosUp
    highBroken := true

if bosDown
    lowBroken  := true


// Displacement of the current break event, in ATR multiples, cached
// once per bar so the resulting order block shares the same measured
// break strength as the structure event that created it.
float curBosUpDisp   = bosUp   and atr > 0 ? math.abs(close - lastSwingHigh) / atr : 0.0
float curBosDownDisp = bosDown and atr > 0 ? math.abs(close - lastSwingLow)  / atr : 0.0

// ──────────────────────────────────────────────────────────────────
// SECTION 6 — ORDER BLOCK CREATION
// ──────────────────────────────────────────────────────────────────
// The origin candle is the last opposite-colored candle at or
// immediately before the broken swing pivot, within a fixed lookback.
// This is the true source of the displacement leg — not merely the
// pivot candle itself. If no qualifying candle exists in the lookback,
// no zone is created for that break.

var int ORIGIN_LOOKBACK = 6

// Bar offset (bars back from current bar) of the last bearish candle
// within the lookback window anchored at the pivot bar. The window is
// scanned from the pivot outward toward the break, and the match is
// continually overwritten so the result ends up being the candle
// CLOSEST to the break (the true final opposite candle before the
// displacement leg), not merely the first one encountered.
f_findBearOrigin(int pivotBarIndex) =>
    int found = na
    int startOffset = bar_index - pivotBarIndex
    int endOffset   = math.max(0, startOffset - ORIGIN_LOOKBACK)
    for i = startOffset to endOffset
        if close[i] < open[i]
            found := i
    found

// Bar offset of the last bullish candle within the lookback window
// anchored at the pivot bar (see f_findBearOrigin for the scan logic).
f_findBullOrigin(int pivotBarIndex) =>
    int found = na
    int startOffset = bar_index - pivotBarIndex
    int endOffset   = math.max(0, startOffset - ORIGIN_LOOKBACK)
    for i = startOffset to endOffset
        if close[i] > open[i]
            found := i
    found


// Creates a new zone, draws its box/midline, enforces the per-
// direction cap (oldest is dropped first), and raises the "new OB"
// event flag consumed by the alert block.
f_createOB(bool isBull, int originOffset, float dispAtr, int breakBarIndex) =>
    float top  = high[originOffset]
    float bot  = low[originOffset]
    float mid  = (top + bot) / 2.0
    float impulseAtrVal = atr[originOffset] > 0 ? (high[originOffset] - low[originOffset]) / atr[originOffset] : 0.0
    int   originBar  = bar_index - originOffset
    float distAtrVal = atr > 0 ? math.abs(close - mid) / atr : 0.0

    color baseCol = isBull ? i_bullColor : i_bearColor
    int   transp0 = f_mitTransp(0.0)

    box zoneBox = box.new(
         left        = originBar, right = breakBarIndex,
         top         = top, bottom = bot,
         border_color = color.new(baseCol, 30),
         border_width = 1,
         bgcolor      = i_dynamicFade ? color.new(baseCol, transp0) : color.new(baseCol, i_freshTransp),
         extend       = extend.none)

    line midLine = i_showMid ? line.new(
         originBar, mid, breakBarIndex, mid,
         color = color.new(baseCol, 40), style = line.style_dashed, width = 1) : na

    OrderBlock ob = OrderBlock.new(
         isBull      = isBull,
         top         = top,
         bot         = bot,
         mid         = mid,
         birthBar    = originBar,
         deepest     = isBull ? top : bot,
         mitPct      = 0.0,
         band        = 0,
         signaled    = false,
         frozen      = false,
         dispAtr     = dispAtr,
         impulseAtr  = impulseAtrVal,
         birthAtrVal = atr,
         distanceAtr = distAtrVal,
         zoneBox     = zoneBox,
         midLine     = midLine)

    OrderBlock[] targetArr = isBull ? bullOBs : bearOBs
    array.push(targetArr, ob)

    if array.size(targetArr) > i_maxZones
        OrderBlock oldest = array.shift(targetArr)
        box.delete(oldest.zoneBox)
        line.delete(oldest.midLine)

    array.set(lastEvtTop, 0, top)
    array.set(lastEvtBot, 0, bot)
    if isBull
        array.set(evt_newBullOB, 0, true)
    else
        array.set(evt_newBearOB, 0, true)

// New bullish OB (demand zone) at a confirmed upside BOS — the origin
// is the last bearish candle before the break.
if bosUp and not na(lastSHBar)
    int originOffset = f_findBearOrigin(lastSHBar)
    if not na(originOffset) and atr[originOffset] > 0 and (high[originOffset] - low[originOffset]) >= i_minImpulseAtr * atr[originOffset]
        f_createOB(true, originOffset, curBosUpDisp, bar_index)

// New bearish OB (supply zone) at a confirmed downside BOS — the
// origin is the last bullish candle before the break.
if bosDown and not na(lastSLBar)
    int originOffset = f_findBullOrigin(lastSLBar)
    if not na(originOffset) and atr[originOffset] > 0 and (high[originOffset] - low[originOffset]) >= i_minImpulseAtr * atr[originOffset]
        f_createOB(false, originOffset, curBosDownDisp, bar_index)

// ──────────────────────────────────────────────────────────────────
// SECTION 7 — MITIGATION ENGINE
// ──────────────────────────────────────────────────────────────────
// Runs once per confirmed bar over every live zone. For each zone:
//   1. Ratchet the deepest intrusion price using this bar's wick.
//   2. Recompute Mitigation % from that ratcheted extreme.
//   3. Update box right-edge (extension), fill transparency and
//      midline position to match.
//   4. Reclassify the quality band and fire a milestone alert flag
//      exactly once when the zone crosses into a new (worse) band.
//   5. Delete the zone outright once it crosses the Invalidate
//      threshold, or once an opposing BOS/fixed-bar limit ends its
//      extension (per the selected Zone Extension mode).
f_updateZones(OrderBlock[] arr, bool isBull) =>
    int n = array.size(arr)
    // Guard against n == 0: Pine's for-loop direction is resolved at
    // runtime by comparing start/end, so "n - 1 to 0" would otherwise
    // become an ascending loop (-1 to 0) on an empty array and throw
    // an out-of-bounds error on array.get(arr, -1).
    if n > 0
        for idx = n - 1 to 0
            OrderBlock ob = array.get(arr, idx)

            float intrusion = isBull ? math.min(ob.deepest, low) : math.max(ob.deepest, high)
            ob.deepest := intrusion

            float height = ob.top - ob.bot
            float mitPctNow = height > 0 ? (isBull ? (ob.top - ob.deepest) / height * 100.0 : (ob.deepest - ob.bot) / height * 100.0) : 0.0
            mitPctNow := math.max(0.0, mitPctNow)
            int prevBand = ob.band
            ob.mitPct := mitPctNow

            bool invalidated  = mitPctNow >= i_invalidatePct
            bool oppositeBos  = isBull ? bosDown : bosUp
            bool exceededBars = i_extMode == "Fixed Bars" and (bar_index - ob.birthBar) >= i_extBars
            bool stopByBos    = i_extMode == "Until New BOS" and oppositeBos and not ob.frozen

            if invalidated
                box.delete(ob.zoneBox)
                line.delete(ob.midLine)
                array.remove(arr, idx)
                array.set(lastEvtTop, 0, ob.top)
                array.set(lastEvtBot, 0, ob.bot)
                if isBull
                    array.set(evt_bullInvalid, 0, true)
                else
                    array.set(evt_bearInvalid, 0, true)
            else
                if not ob.frozen
                    box.set_right(ob.zoneBox, bar_index)
                    if not na(ob.midLine)
                        line.set_x2(ob.midLine, bar_index)

                color baseCol   = isBull ? i_bullColor : i_bearColor
                int   transpNow = i_dynamicFade ? f_mitTransp(mitPctNow) : i_freshTransp
                box.set_bgcolor(ob.zoneBox, color.new(baseCol, transpNow))

                if exceededBars or stopByBos
                    ob.frozen := true

                int newBand = f_mitBand(mitPctNow)
                ob.band := newBand
                if newBand > prevBand
                    array.set(lastEvtTop, 0, ob.top)
                    array.set(lastEvtBot, 0, ob.bot)
                    if newBand == 1
                        if isBull
                            array.set(evt_bullPartial, 0, true)
                        else
                            array.set(evt_bearPartial, 0, true)
                    else if newBand == 3
                        if isBull
                            array.set(evt_bullHeavy, 0, true)
                        else
                            array.set(evt_bearHeavy, 0, true)

if barstate.isconfirmed
    f_updateZones(bullOBs, true)
    f_updateZones(bearOBs, false)


// ──────────────────────────────────────────────────────────────────
// SECTION 8 — SMART REJECTION ENTRY ENGINE
// ──────────────────────────────────────────────────────────────────
// Scans active zones for a qualifying retest. A zone qualifies when:
//   • price traded inside its range on the current confirmed bar,
//   • its live Mitigation % has not yet exceeded the user's entry cap,
//   • it has not already produced a signal in its lifecycle,
//   • the selected rejection pattern confirms on this closed candle,
//   • optional midpoint / ATR-expansion / volume filters all pass.
// Only the most recent qualifying zone per direction signals on a
// given bar, avoiding duplicate markers when zones overlap. The
// composite confidence score is computed once and travels with the
// signal for both the plotted label and the alert payload.
var int sigConfBuy  = na
var int sigConfSell = na


bool wantBuy  = false
bool wantSell = false

if i_enableEntries and barstate.isconfirmed
    // Bullish retests: price wicked into a demand zone this bar. Array
    // order is oldest-to-newest, so iterating from the last index down
    // to 0 visits the newest zones first — the loop breaks on the
    // first (i.e. most recent) qualifying zone, matching the "most
    // recent zone signals" behavior described above. Guarded against
    // an empty array for the same reason as f_updateZones above.
    if array.size(bullOBs) > 0
        for idx = array.size(bullOBs) - 1 to 0
            OrderBlock ob = array.get(bullOBs, idx)
            bool touched = low <= ob.top and low >= ob.bot
            if touched and not ob.signaled and ob.mitPct <= i_maxMitForEntry
                bool patternOk = f_rejectionOk(true)
                bool midOk     = not i_useMidFilter or close >= ob.mid
                if patternOk and midOk and f_atrExpansionOk() and f_volumeOk()
                    ob.signaled := true
                    sigConfBuy  := f_confidenceScore(ob.dispAtr, ob.impulseAtr, ob.mitPct, ob.birthAtrVal, ob.distanceAtr)
                    wantBuy     := true
                    break


    // Bearish retests: price wicked into a supply zone this bar (same
    // newest-first, break-on-first-match logic as above).
    if array.size(bearOBs) > 0
        for idx = array.size(bearOBs) - 1 to 0
            OrderBlock ob = array.get(bearOBs, idx)
            bool touched = high >= ob.bot and high <= ob.top
            if touched and not ob.signaled and ob.mitPct <= i_maxMitForEntry
                bool patternOk = f_rejectionOk(false)
                bool midOk     = not i_useMidFilter or close <= ob.mid
                if patternOk and midOk and f_atrExpansionOk() and f_volumeOk()
                    ob.signaled := true
                    sigConfSell := f_confidenceScore(ob.dispAtr, ob.impulseAtr, ob.mitPct, ob.birthAtrVal, ob.distanceAtr)
                    wantSell    := true
                    break




if wantBuy
    array.set(evt_buySignal, 0, true)
    if sigConfBuy >= i_highConfThresh
        array.set(evt_highConfBuy, 0, true)

if wantSell
    array.set(evt_sellSignal, 0, true)
    if sigConfSell >= i_highConfThresh
        array.set(evt_highConfSell, 0, true)


// ──────────────────────────────────────────────────────────────────
// SECTION 9 — SIGNAL VISUALIZATION
// ──────────────────────────────────────────────────────────────────
// Institutional diamond markers replace generic arrows. Each marker
// carries its disclosed confidence score as a small text readout
// directly beside it — no dashboard, no separate panel, no extra
// chart real estate consumed.
// Note: plotshape() must be called unconditionally at the script's
// top level — Pine Script v6 forbids calling plotting functions
// inside if/else blocks ("local scope"). It also requires size= to be
// a true compile-time-constant literal, not a ternary result. To
// honor the user's dropdown while satisfying both constraints, all
// three sizes are called unconditionally, and the dropdown selection
// is folded into each call's boolean series argument instead — only
// the matching size actually draws a marker on any given bar.
plotshape(wantBuy  and i_signalSize == "Tiny",   title = "Bullish Rejection Entry (Tiny)",   style = shape.diamond, location = location.belowbar, color = i_bullColor, size = size.tiny)
plotshape(wantBuy  and i_signalSize == "Small",  title = "Bullish Rejection Entry (Small)",  style = shape.diamond, location = location.belowbar, color = i_bullColor, size = size.small)
plotshape(wantBuy  and i_signalSize == "Normal", title = "Bullish Rejection Entry (Normal)", style = shape.diamond, location = location.belowbar, color = i_bullColor, size = size.normal)

plotshape(wantSell and i_signalSize == "Tiny",   title = "Bearish Rejection Entry (Tiny)",   style = shape.diamond, location = location.abovebar, color = i_bearColor, size = size.tiny)
plotshape(wantSell and i_signalSize == "Small",  title = "Bearish Rejection Entry (Small)",  style = shape.diamond, location = location.abovebar, color = i_bearColor, size = size.small)
plotshape(wantSell and i_signalSize == "Normal", title = "Bearish Rejection Entry (Normal)", style = shape.diamond, location = location.abovebar, color = i_bearColor, size = size.normal)

if wantBuy
    label.new(bar_index, low - atr * 0.6, str.tostring(sigConfBuy) + "%",
         style     = label.style_none,
         textcolor = color.new(i_bullColor, 0),
         size      = size.tiny)

if wantSell
    label.new(bar_index, high + atr * 0.6, str.tostring(sigConfSell) + "%",
         style     = label.style_none,
         textcolor = color.new(i_bearColor, 0),
         size      = size.tiny)

// ──────────────────────────────────────────────────────────────────
// SECTION 10 — ALERT DISPATCH
// ──────────────────────────────────────────────────────────────────
// alert() is used exclusively (per brief) instead of alertcondition(),
// so a single "Any alert() function call" trigger on the alert dialog
// captures every event below. Each message is a compact, human-
// readable string carrying the zone's price levels and, for entries,
// the disclosed confidence score. All dispatch is gated on the master
// switch plus its category toggle, and every underlying flag was only
// ever set inside barstate.isconfirmed logic — so alerts cannot repaint.
if i_alertsEnabled
    float evTop  = array.get(lastEvtTop, 0)
    float evBot  = array.get(lastEvtBot, 0)
    // Note: confidence values for entry alerts are read directly from
    // sigConfBuy / sigConfSell (not from a shared array slot). This
    // avoids a race where a buy and sell signal on the same bar would
    // otherwise overwrite a single shared confidence value before both
    // alert messages are built.


    if i_alertOB and array.get(evt_newBullOB, 0)
        alert("New Bullish Order Block on " + syminfo.ticker + " | Zone " + str.tostring(evBot, format.mintick) + " - " + str.tostring(evTop, format.mintick), alert.freq_once_per_bar_close)

    if i_alertOB and array.get(evt_newBearOB, 0)
        alert("New Bearish Order Block on " + syminfo.ticker + " | Zone " + str.tostring(evBot, format.mintick) + " - " + str.tostring(evTop, format.mintick), alert.freq_once_per_bar_close)

    if i_alertMit and array.get(evt_bullPartial, 0)
        alert("Bullish OB Partial Mitigation on " + syminfo.ticker + " | Zone " + str.tostring(evBot, format.mintick) + " - " + str.tostring(evTop, format.mintick), alert.freq_once_per_bar_close)

    if i_alertMit and array.get(evt_bearPartial, 0)
        alert("Bearish OB Partial Mitigation on " + syminfo.ticker + " | Zone " + str.tostring(evBot, format.mintick) + " - " + str.tostring(evTop, format.mintick), alert.freq_once_per_bar_close)

    if i_alertMit and array.get(evt_bullHeavy, 0)
        alert("Bullish OB Heavy Mitigation on " + syminfo.ticker + " | Zone " + str.tostring(evBot, format.mintick) + " - " + str.tostring(evTop, format.mintick), alert.freq_once_per_bar_close)

    if i_alertMit and array.get(evt_bearHeavy, 0)
        alert("Bearish OB Heavy Mitigation on " + syminfo.ticker + " | Zone " + str.tostring(evBot, format.mintick) + " - " + str.tostring(evTop, format.mintick), alert.freq_once_per_bar_close)

    if i_alertMit and array.get(evt_bullInvalid, 0)
        alert("Bullish OB Invalidated on " + syminfo.ticker + " | Zone " + str.tostring(evBot, format.mintick) + " - " + str.tostring(evTop, format.mintick), alert.freq_once_per_bar_close)

    if i_alertMit and array.get(evt_bearInvalid, 0)
        alert("Bearish OB Invalidated on " + syminfo.ticker + " | Zone " + str.tostring(evBot, format.mintick) + " - " + str.tostring(evTop, format.mintick), alert.freq_once_per_bar_close)

    if i_alertEntry and array.get(evt_buySignal, 0)
        alert("Bullish Rejection Entry on " + syminfo.ticker + " | Confidence " + str.tostring(sigConfBuy) + "%", alert.freq_once_per_bar_close)

    if i_alertEntry and array.get(evt_sellSignal, 0)
        alert("Bearish Rejection Entry on " + syminfo.ticker + " | Confidence " + str.tostring(sigConfSell) + "%", alert.freq_once_per_bar_close)

    if i_alertEntry and array.get(evt_highConfBuy, 0)
        alert("Premium Entry (High Confidence BUY) on " + syminfo.ticker + " | Confidence " + str.tostring(sigConfBuy) + "%", alert.freq_once_per_bar_close)

    if i_alertEntry and array.get(evt_highConfSell, 0)
        alert("Premium Entry (High Confidence SELL) on " + syminfo.ticker + " | Confidence " + str.tostring(sigConfSell) + "%", alert.freq_once_per_bar_close)
````
