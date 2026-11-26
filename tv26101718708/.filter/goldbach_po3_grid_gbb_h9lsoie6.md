# Goldbach + PO3 Grid [GBB]

- url: https://www.tradingview.com/script/H9Lsoie6-Goldbach-PO3-Grid-GBB/
- type: indicator
- pine_id: PUB;a527910ce7c34583a699850f172633a2
- version: 1.0

## Description

[b]Goldbach + PO3 Grid [GBB][/b]

An open-source visualization of two ICT concepts — the Goldbach dealing-range grid and the daily Power of 3 (PO3) cycle — combined with a transparent confluence signal layer. The Pine source is published as a "Free open-source script" so you can read every line, fork it, audit the math, and confirm the signals are computed exactly as documented.

This is a tool, not a strategy. Use it to make ICT structure visible on your chart at any timeframe, and to flag the moments when a Goldbach level tap aligns with a resolved PO3 bias.

[b]What it draws[/b]

Goldbach grid (canonical zone-based implementation).Once an IPDA (Interbank Price Delivery Algorithm — ICT terminology for the n-bar high/low window used as the dealing-range basis) range is established, the script overlays 14 prime-partition lines plus equilibrium and speed-bump references on it. The lines sit at the canonical Goldbach percentages — pairs of primes that sum to 100, per Goldbach's conjecture: 3+97, 11+89, 17+83, 29+71, 41+59, 47+53, plus the trivial 0/100 boundary.

Per ICT teaching, roles are zones between adjacent prime-partition lines, not the lines themselves. The teaching documents the rule explicitly: "To map the levels to an ICT concept, like rejection block, order block, we take the value of the level just below it until the current value." Each zone has a trigger line at its equilibrium-facing edge:

[list=1]
[*]RB (Rejection Block) — zone 0-3 / 97-100, triggers at 3 / 97
[*]OB (Order Block) — zone 3-11 / 89-97, triggers at 11 / 89
[*]FVG (Fair Value Gap) — zone 11-17 / 83-89, triggers at 17 / 83
[*]LV (Liquidity Void) — zone 29-41 / 59-71, triggers at 41 / 59
[*]BRK (Breaker) — zone 41-47 / 53-59, triggers at 47 / 53
[*]EQ (Equilibrium) at 50 — boundary between premium and discount, derived as midpoint between MB pair
[*]EXT — range extremes at 0 / 100
[/list]

The 17-29 / 71-83 region between FVG and LV has no canonical role name in ICT teaching; the script draws the 29 / 71 lines as neutral boundary markers. Within the LV zone, the script also draws non-prime "speed bump" lines at 35 and 65 — taught by ICT as partial-profit reference points, not as entry triggers. They are visual references only and do not generate signals.

Premium territory (above EQ) is tinted; discount territory (below EQ) is tinted in the inverse color. The grid updates automatically when the underlying IPDA range shifts.

Three range sources are available:

[list=1]
[*]PDA Lookback (default) — highest high and lowest low of the past 60 HTF bars. Computed natively in the chart's timeframe when the lookback fits Pine's max_bars_back budget (1H and above with daily HTF). Falls back to `request.security` on the HTF directly when the native lookback would exceed the budget (e.g., 15m with daily HTF needs 5,760 native bars; the fallback uses 60 daily bars instead). The status table shows which path is active.
[*]HTF Swing — most recent confirmed pivot high and pivot low on a higher timeframe.
[*]Manual— user-set price bounds.
[/list]

[b]Power of 3 module[/b]

The script anchors a daily PO3 cycle at NY midnight, then tracks three phases — Accumulation, Manipulation, Distribution — based on a Judas swing detection (false move beyond a recent extreme) followed by displacement (FVG-confirmed move in the opposite direction). Phase state, Judas direction, and resolved PO3 bias are shown in the on-chart status table. Historical Judas/Distribution markers are rendered for past periods so you can see how the cycle resolved historically.

[b]Signal layer (optional) [/b]

When a Goldbach trigger line is tapped [i]and[/i] the current PO3 bias agrees with the trade direction implied by that tap (e.g., bearish PO3 + premium tap → short setup), a signal fires. Three presets control which roles qualify:

[list=1]
[*]Strict — OB and FVG triggers only (lines 11 / 17 / 83 / 89). Requires bias resolved + dispMult ≥ 1.5× ATR + HTF bias agreement.
[*]Standard — adds LV and BRK triggers (lines 41 / 47 / 53 / 59). Requires bias resolved. HTF bias filter optional. This is what the backtest below was run on.
[*]Loose — adds RB and MB/EQ triggers (lines 3 / 50 / 97). Requires Manipulation or Distribution phase active. Speed bumps and boundary lines (35/65, 29/71) never trigger.
[/list]

Signals appear as triangles, a one-line label noting the role and PO3 bias, and a translucent vertical highlight on the firing bar. A 9-condition alert suite covers each signal type for automation.

[b]Settings walkthrough[/b]

The settings panel is grouped into modules. Defaults are tuned to match ICT-canonical conventions where they exist; everything else is what we used during backtesting. None of the values below were tuned against our test data, so they're starting points rather than optimized parameters.

Three choices for how the dealing range is determined:

[list=1]
[*]IPDA Lookback (default) — highest high and lowest low over the configured lookback window. Reproducible regardless of how much chart history is loaded. This is what the backtesting was done on.
[*]HTF Swing — uses the most recent confirmed pivot high and pivot low on a higher timeframe. Reactive to recent structure rather than a fixed window. Useful if you trade off explicit swing structure rather than a rolling N-day range.
[*]Manual — you set the high and low yourself. Use when you've already mapped a dealing range and just want the Goldbach grid drawn on it.
[/list]

[b]HTF Timeframe[/b]. The reference timeframe for both IPDA Lookback and HTF Swing. Default `D` (daily). Pick a timeframe higher than your chart timeframe — the indicator does not warn you if you set HTF below chart, but the result is meaningless. For 15m/1H charts, daily is appropriate. For 4H/D charts, weekly may make more sense.

[b]HTF Pivot Length[/b]. Used only by HTF Swing. Number of bars left and right needed to confirm a swing pivot on the HTF timeframe. Default 5. Lower values produce more reactive swings but more false swings; higher values produce more stable swings but lag.

[b]IPDA Lookback (bars)[/b]. Used only by IPDA Lookback. Number of HTF bars to scan for the highest high and lowest low. ICT canonically teaches three values: 20, 40, and 60. We used 60 for backtesting (60 daily bars ≈ 60 days of price action regardless of chart timeframe). Lower the value for a tighter, more reactive range; raise it for a more stable range that updates less often.

[b]Manual: Range High / Range Low[/b]. Used only when Range Source is `Manual`. Numeric prices for the range bounds. Default 0.0 (placeholder); set to your desired values when using the Manual source.

[b]Goldbach Grid[/b]

[b]Show Grid / Show Labels / Show Tints.[/b] Independently togglable. Show Grid draws the 17 horizontal lines (14 prime-partition lines, EQ at 50, plus speed bumps at 35/65). Show Labels adds the role text (OB_HIGH, FVG_LOW, LV_HIGH, BRK_LOW, RB_HIGH, etc.) at the right edge. Show Tints fills the premium half (above EQ) and discount half (below EQ) with colored overlay boxes.

[b]Invert on Bear.[/b] When on, the role labels flip vertically when the underlying range formed bearishly (low after high rather than high after low). The math doesn't change; only the labels swap. Most traders leave this on.

[b]PO3[/b]

[b]Enable PO3.[/b] Master toggle for the entire daily cycle module. When off, the Goldbach grid still draws but no PO3 detection or signaling happens.

[b]Anchor.[/b] When the daily cycle "starts." ICT canon is `Daily NY Midnight` — 00:00 New York time. The other option is `Session: Custom`, which lets you set an arbitrary anchor time for non-equity sessions or alternative trading regimes. For 24/7 crypto, the default works.

[b]Custom Anchor Time.[/b] Used only when Anchor is set to `Session: Custom`. HH:MM format in chart timezone.

[b]Accumulation Threshold (× ATR). [/b]During the early hours of the daily period, price is considered "still accumulating" if it stays within this multiple of ATR from the open. Default 0.5. Raise it for more permissive accumulation (longer manipulation phase delay); lower it for stricter accumulation.

[b]Displacement Multiplier (× ATR). [/b]Required size of the displacement candle that confirms a transition into Distribution phase. Default 1.0. Higher values require more decisive moves to confirm bias; lower values accept smaller candles as confirmation. Strict preset overrides this with 1.5.

[b]Require FVG Confirmation.[/b]When on, the displacement step also requires a fair value gap of the correct polarity within the last 3 bars before bias is resolved. Default on. This is a meaningful filter — turning it off roughly doubles signal frequency but reduces signal quality.

[b]Max Historical Periods.[/b] Cap on how many past PO3 periods retain their visual markers (J↑/J↓ Judas labels and D Distribution labels) on the chart. Default 50. Lower for cleaner charts; higher to see further back. Old markers are deleted as new ones close.

[b]Signal Layer[/b]
[b]
Preset. [/b]Three confluence configurations:

[list=1]
[*]trict — only OB and FVG triggers qualify (lines at 11/17/83/89). Requires resolved PO3 bias, displacement ≥ 1.5× ATR, and HTF bias agreement. Highest signal-to-noise ratio, lowest signal frequency.
[*]Standard (default) — adds LV and BRK triggers (lines at 41/47/53/59). Requires resolved PO3 bias. HTF bias filter is optional. This is what the backtesting was done on.
[*]Loose — adds RB and MB/EQ triggers (lines at 3/50/97). Requires Manipulation or Distribution phase active. Speed bump levels (35/65) and boundary lines (29/71) are excluded from all presets — they are visual references only.
[/list]

The presets aren't magic — they're three reasonable points on a precision/recall curve. Strict misses many real setups; Loose generates many false ones. I used Standard as the middle ground.

[b]Require HTF Bias Filter.[/b] When on, signals only fire if the higher-timeframe trend (measured by HTF SMA slope) agrees with the signal direction. Always on for Strict, always off for Loose, optional for Standard. Useful in trending markets to avoid counter-trend signals; restrictive in choppy markets.

[b]Signal Cooldown (bars)[/b]. Minimum bars between consecutive signals. Default 10. Prevents rapid-fire repeat signals against the same level when price oscillates around it.

[b]Show Signal Labels[/b]. When on, every signal gets a verbose one-line label noting the role tapped, the PO3 bias, and the active preset (e.g., "OB_HIGH 89% • Bear • Standard"). When off, only the triangle marker appears.

[b]Highlight Signal Bar.[/b] Translucent vertical strip behind the firing bar. Makes signals identifiable at any zoom level. Default on.

[b]
Style & Display[/b]
[b]
Show Period Boxes. [/b]Renders historical PO3 period markers (Judas direction labels, distribution markers, period borders). Useful for studying past cycle resolutions.

[b]Show True Open Line.[/b] Draws a horizontal line at the daily open price, extended through the day. Reference for premium/discount intraday.

[b]Status Table Position[/b]. Where the on-chart status table sits. Default top-right. The table shows current range, EQ price, position percentage, current PO3 phase, and most recent signal — keep it visible.

[b]Status Table Text Size. [/b]Self-explanatory. Smaller is less obtrusive but harder to read on high-DPI displays.

[b]Colors.[/b] All colors (premium tint, discount tint, level role colors, period borders, signal markers) are configurable per-element. The defaults are designed for dark charts; on light charts you'll likely want to adjust the tints to lower opacity.
[b]
Alerts[/b]

The script defines 9 named alertconditions, each subscribable separately in TradingView's alert dialog:

Goldbach: EQ tap — price tapped equilibrium (the 50% line)
Goldbach: Premium tap — any tap in the premium half
Goldbach: Discount tap — any tap in the discount half
Goldbach: Sweep — tap of the 0% or 100% extreme
PO3: Manipulation phase entered
PO3: Distribution confirmed bullish
PO3: Distribution confirmed bearish
Signal: Long
Signal: Short

In the alert creation dialog, select this indicator, then pick the specific condition you want. All alerts include `{{ticker}}` and `{{interval}}` placeholders so the message identifies the chart. You can run multiple alerts on the same chart simultaneously (e.g., one for Long signals and one for Distribution-confirmed-bearish).

[b]Notes for first-time use[/b]

After adding the indicator to your chart, scroll back to load enough history for the IPDA Lookback computation to populate (typically a few seconds on a fully-loaded chart). The grid will appear once range data is available. The status table on the right shows current range bounds, EQ price, position percentage, current PO3 phase, and most recent signal — use this as a quick health check that the indicator is reading the chart correctly.

If grid lines or labels appear misaligned with price candles, the indicator may be pinned to a separate price scale. The script declares `linktoseries=true` to prevent this, but if you encounter it: right-click the indicator name → Pin to Scale → match the scale your price chart uses.

License & contributions

Source available under TradingView's Free Open-source license. Forks, modifications, and pull requests welcome. We will respond to bug reports in the comments below this publication.

Built by The Good, the Bad and the Bitcoin.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
// Goldbach + PO3 Grid [GBB] — v3
//
// Open-source visualization of two ICT concepts: the Goldbach dealing-range
// grid (canonical implementation: levels at the prime-partition values from
// Goldbach's conjecture, sums to 100, applied to the 0-100% range) and the
// daily Power of 3 cycle (Accumulation → Manipulation → Distribution). An
// optional confluence signal layer fires when a Goldbach level tap aligns
// with the resolved PO3 bias. This is a visualization tool, not a trading
// strategy.
//
// Goldbach levels (from ICT teaching):
//
// Roles are ZONES, not individual lines. The line at the equilibrium-facing
// boundary of each zone is the trigger for that role. Per ICT teaching:
// "we take the value of the level just below it until the current value"
// — i.e., the role for the line at 11% is determined by the zone bounded
// by the next-deeper line (3%) and that line.
//
//   Zone 0-3 / 97-100 — Rejection Block (RB)            [trigger: 3 / 97]
//   Zone 3-11 / 89-97 — Order Block (OB)                [trigger: 11 / 89]
//   Zone 11-17 / 83-89 — Fair Value Gap (FVG)           [trigger: 17 / 83]
//   Zone 17-29 / 71-83 — boundary region (no role)
//   Zone 29-41 / 59-71 — Liquidity Void (LV)            [trigger: 41 / 59]
//   Zone 41-47 / 53-59 — Breaker (BRK)                  [trigger: 47 / 53]
//   Zone 47-53 — Mitigation Block (MB) / Equilibrium    [trigger: 50]
//
// Within the Liquidity Void zone, ICT teaches non-prime "speed bump" levels
// at 35 and 65 — used for partial-profit reference, not as entry triggers.
// These are drawn on the chart but excluded from the signal layer.
//
// Three modules:
//   1. Range — IPDA Lookback (default), HTF Swing, or Manual range source.
//   2. Goldbach Grid — 14 prime-partition levels (3, 11, 17, 29, 41, 47,
//      and their premium mirrors) plus 0/50/100, plus speed bumps at 35/65.
//   3. PO3 — anchors a daily cycle at 00:00 NY, detects Judas swings and
//      FVG-confirmed displacement, resolves the daily bias.
//
// The signal layer combines all three: a Goldbach trigger-line tap that
// agrees with the active PO3 bias fires a long/short signal. Three presets:
//   Strict    — OB and FVG only (4 trigger lines: 11/17/83/89)
//   Standard  — adds BRK and LV (8 trigger lines: 11/17/41/47/53/59/83/89)
//   Loose     — all roles except EXT (10 trigger lines: drops 0/100)
//
// Note: Consequent Encroachment (CE) sub-levels — geometric midpoints
// between adjacent Goldbach pairs — are taught in ICT methodology as
// confluence references for market structure shifts. They are not drawn
// in v3 to keep the chart readable. May be added as an opt-in toggle in
// a future version.
//
// IPDA computation: native in the chart timeframe by default (deterministic
// regardless of chart load state). Falls back to request.security on
// timeframes where the native lookback would exceed Pine's max_bars_back
// budget — typically intraday timeframes below 1H. On the fallback path,
// ensure the chart has loaded enough HTF history before relying on
// historical signals.
//
// ─── Attribution ────────────────────────────────────────────────────────────
// Author:        The Good, the Bad and the Bitcoin
// Walkthrough:   https://www.youtube.com/@TheGoodTheBadAndTheBitcoin
// Source:        Free open-source on TradingView
// Bug reports:   Comments below the TradingView publication
// License:       TradingView Free Open-source license
// ════════════════════════════════════════════════════════════════════════════
indicator(
     title             = "Goldbach + PO3 Grid [GBB]",
     shorttitle        = "GBB Grid",
     overlay           = true,
     scale             = scale.none,
     linktoseries      = true,
     max_bars_back     = 5000,
     max_lines_count   = 500,
     max_labels_count  = 500,
     max_boxes_count   = 500)

// ─── INPUTS ─────────────────────────────────────────────────────────────────

// Range Engine
var string GRP_RNG = "Range Engine"
rangeSource  = input.string("IPDA Lookback", "Range Source",
     options=["HTF Swing", "IPDA Lookback", "Manual"], group=GRP_RNG)
htfTf        = input.timeframe("D", "HTF Timeframe", group=GRP_RNG,
     tooltip="Used by HTF Swing and IPDA Lookback. Pick HTF >= chart timeframe.")
pivotLen     = input.int(5, "Swing: Pivot Length", minval=2, maxval=50, group=GRP_RNG,
     tooltip="HTF Swing source only. Bars left/right needed to confirm a swing.")
ipdaLookback = input.int(60, "IPDA: Lookback (bars)", options=[20, 40, 60], group=GRP_RNG,
     tooltip="IPDA source. Number of HTF bars to scan for highest high / lowest low. Computed natively in the chart's timeframe — e.g. lookback=60 with HTF='D' equals 60 days of price action.")
manualHigh   = input.price(0.0, "Manual: Range High", group=GRP_RNG,
     tooltip="Used only when Range Source is set to 'Manual'.")
manualLow    = input.price(0.0, "Manual: Range Low",  group=GRP_RNG,
     tooltip="Used only when Range Source is set to 'Manual'.")

// Goldbach Grid
var string GRP_GB = "Goldbach Grid"
showGrid     = input.bool(true,  "Show Grid",                    group=GRP_GB)
showLabels   = input.bool(true,  "Show Role Labels",             group=GRP_GB)
showTints    = input.bool(true,  "Show Premium/Discount Tints",  group=GRP_GB)
labelSizeIn  = input.string("small", "Label Size",
     options=["tiny","small","normal","large"], group=GRP_GB)
invertOnBear = input.bool(false, "Invert Roles on Bearish Range", group=GRP_GB,
     tooltip="If on, OB/FVG/Breaker labels flip vertically when range formed bearishly.")

// Power of 3
var string GRP_PO3 = "Power of 3"
showPO3      = input.bool(true, "Enable PO3 Engine", group=GRP_PO3)
anchorMode   = input.string("Daily NY Midnight", "Anchor",
     options=["Daily NY Midnight","Daily UTC","Weekly","Monthly",
              "Session: Asian","Session: London","Session: NY","Session: Custom"],
     group=GRP_PO3,
     tooltip="ICT canon: Daily NY Midnight. UTC for clean 24/7 crypto without DST drift.")
customSess   = input.session("0700-1000", "Custom Session", group=GRP_PO3,
     tooltip="Used only when Anchor = 'Session: Custom'.")
customTz     = input.string("America/New_York", "Custom Timezone",
     options=["UTC","America/New_York","Europe/London","Asia/Tokyo","Asia/Shanghai"],
     group=GRP_PO3)
atrLen       = input.int(14, "ATR Length", minval=2, maxval=200, group=GRP_PO3)
accumThresh  = input.float(0.5, "Accumulation Threshold (× ATR)", step=0.1, minval=0.1, maxval=3.0, group=GRP_PO3,
     tooltip="Distance from open within which price is considered still accumulating.")
displaceMult = input.float(1.0, "Displacement Multiplier (× ATR)", step=0.1, minval=0.1, maxval=5.0, group=GRP_PO3,
     tooltip="Required distance from open in distribution direction to confirm phase transition.")
requireFVG   = input.bool(true, "Require FVG for Distribution", group=GRP_PO3,
     tooltip="When on, distribution must be confirmed by an FVG of correct polarity in the last 3 bars.")
showLiveBox  = input.bool(true,  "Show Live Period Background", group=GRP_PO3)
showHist     = input.bool(true,  "Show Historical Markers",     group=GRP_PO3)
maxHistPeriods = input.int(5, "Max Historical Periods", minval=0, maxval=30, group=GRP_PO3,
     tooltip="Cap on retained historical period drawings. Older periods are deleted as new ones close.")

// Status Table
var string GRP_TBL = "Status Table"
showStatusTable = input.bool(true, "Show Status Table", group=GRP_TBL)
tablePos        = input.string("top_right", "Position",
     options=["top_right","top_left","middle_right","middle_left","bottom_right","bottom_left"],
     group=GRP_TBL)
tableSizeIn     = input.string("small", "Text Size",
     options=["tiny","small","normal"], group=GRP_TBL)

// Signal Engine
var string GRP_SIG = "Signal Engine"
showSignals      = input.bool(true, "Enable Signals", group=GRP_SIG)
preset           = input.string("Standard", "Sensitivity Preset",
     options=["Strict","Standard","Loose"], group=GRP_SIG,
     tooltip="Strict: OB and FVG triggers only (lines 11/17/83/89). Requires bias resolved + dispMult ≥ 1.5× ATR + HTF bias agree.\nStandard: adds LV and BRK triggers (lines 11/17/41/47/53/59/83/89). Requires bias resolved. HTF bias optional.\nLoose: adds RB and MB triggers (10 lines total). Requires Manipulation or Distribution phase active.\nExcluded everywhere: extremes (0/100), boundary lines (29/71), and speed bumps (35/65).")
htfBiasFilter    = input.bool(false, "HTF Bias Filter (Standard only)", group=GRP_SIG,
     tooltip="When on, Standard preset also requires HTF bias to agree with signal direction. Always on for Strict, always off for Loose.")
htfBiasTf        = input.timeframe("W", "HTF Bias Timeframe", group=GRP_SIG)
htfBiasLen       = input.int(20, "HTF Bias SMA Length", minval=2, maxval=200, group=GRP_SIG)
cooldownBars     = input.int(10, "Cooldown (bars)", minval=0, maxval=200, group=GRP_SIG,
     tooltip="Minimum bars between consecutive signals.")
showSignalLabels = input.bool(true, "Show Signal Breakdown Labels", group=GRP_SIG,
     tooltip="If on, signals get a verbose label showing role, PO3 bias, preset.")
showSigHighlight = input.bool(true, "Highlight Signal Bar Background", group=GRP_SIG,
     tooltip="Paints a translucent vertical strip behind the firing bar so it's identifiable at any zoom level.")

// Style
var string GRP_STY = "Style"
colDiscount  = input.color(color.new(#26a69a, 85), "Discount Tint",         group=GRP_STY)
colPremium   = input.color(color.new(#ef5350, 85), "Premium Tint",          group=GRP_STY)
colEQ        = input.color(color.new(color.yellow,   0), "Equilibrium / MB (50)",  group=GRP_STY)
colExtreme   = input.color(color.new(color.silver,   0), "Extremes (0/100)",       group=GRP_STY)
colRB        = input.color(color.new(color.red,      0), "RB - Rejection Block (zone 0-3 / 97-100)", group=GRP_STY)
colOB        = input.color(color.new(color.orange,   0), "OB - Order Block (zone 3-11 / 89-97)",     group=GRP_STY)
colFVG       = input.color(color.new(color.aqua,     0), "FVG - Fair Value Gap (zone 11-17 / 83-89)", group=GRP_STY)
colNeutral   = input.color(color.new(color.gray,    50), "Boundary lines (29/71)", group=GRP_STY,
     tooltip="Lines at 29 and 71. The zone between FVG and LV (17-29 / 71-83) has no canonical role name in ICT teaching.")
colSpeedBump = input.color(color.new(color.gray,    60), "Speed Bumps (35/65)",    group=GRP_STY,
     tooltip="Non-prime levels within the Liquidity Void zone. ICT teaches these as partial-profit reference points, not as entry triggers. Drawn but not signal-generating.")
colLV        = input.color(color.new(color.lime,     0), "LV - Liquidity Void (zone 29-41 / 59-71)",  group=GRP_STY)
colBreaker   = input.color(color.new(color.fuchsia,  0), "BRK - Breaker (zone 41-47 / 53-59)",    group=GRP_STY)
lineWidth    = input.int(1, "Line Width", minval=1, maxval=4, group=GRP_STY)

// PO3 Style
var string GRP_PSTY = "PO3 Style"
colBullPeriod = input.color(color.new(#26a69a, 20), "Bullish Period Border", group=GRP_PSTY)
colBearPeriod = input.color(color.new(#ef5350, 20), "Bearish Period Border", group=GRP_PSTY)
colLivePeriod = input.color(color.new(color.gray, 40), "Live Period Border (Unresolved)", group=GRP_PSTY)
colTrueOpen   = input.color(color.new(color.white, 40), "True Open Line",   group=GRP_PSTY)
colJudasMark  = input.color(color.new(color.orange, 0), "Judas Marker",     group=GRP_PSTY)
colDistMark   = input.color(color.new(color.yellow, 0), "Distribution Marker", group=GRP_PSTY)

// Signal Style
var string GRP_SSTY = "Signal Style"
colLongSig    = input.color(color.new(#26a69a, 0), "Long Signal",  group=GRP_SSTY)
colShortSig   = input.color(color.new(#ef5350, 0), "Short Signal", group=GRP_SSTY)
sigBgAlpha    = input.int(75, "Signal Bar Highlight Transparency", minval=50, maxval=95, group=GRP_SSTY,
     tooltip="Higher = more subtle (background almost invisible). Lower = more prominent.")

// ─── TYPES ──────────────────────────────────────────────────────────────────

type Range
    float  high
    float  low
    int    highTime
    int    lowTime
    bool   isBullish
    string source

type GoldbachLevel
    float  price
    float  pct
    string role
    color  col

type PO3State
    float  trueOpen
    int    openTime
    int    openBar
    float  postHi
    float  postLo
    int    postHiTime
    int    postLoTime
    string phase           // "ACCUMULATION" | "MANIPULATION" | "DISTRIBUTION"
    bool   judasUp
    bool   judasDown
    int    biasResolved    // -1 / 0 / +1
    int    distTime
    float  distPrice
    float  distDispMult    // displacement at distribution time, in ATR units

type HistDrawings
    box   bg
    label judas
    label dist

type Signal
    int    sigBar
    int    sigTime
    float  price
    int    direction       // +1 long, -1 short
    string goldbachRole
    float  goldbachPct
    string po3Phase
    int    po3Bias
    string preset

// ─── UTILITIES ──────────────────────────────────────────────────────────────

labelSizeMap(string s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        =>          size.small

tableSizeMap(string s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        =>          size.small

posMap(string s) =>
    switch s
        "top_right"    => position.top_right
        "top_left"     => position.top_left
        "middle_right" => position.middle_right
        "middle_left"  => position.middle_left
        "bottom_right" => position.bottom_right
        "bottom_left"  => position.bottom_left
        =>                position.top_right

rangeChanged(Range a, Range b) =>
    na(a) or na(b)
         or a.high     != b.high
         or a.low      != b.low
         or a.highTime != b.highTime
         or a.lowTime  != b.lowTime
         or a.source   != b.source

// FVG detection across the last 3-bar window (current + 2 back) and the
// 3-bar window ending one bar back, giving "within last 4 bars" coverage.
hasBullishFVG() =>
    (low > high[2]) or (low[1] > high[3])

hasBearishFVG() =>
    (high < low[2]) or (high[1] < low[3])

// ─── MODULE 1: RANGE ENGINE ────────────────────────────────────────────────

htfPivotExpr(int pl) =>
    ph  = ta.pivothigh(pl, pl)
    pv  = ta.pivotlow(pl, pl)
    phT = not na(ph) ? time[pl] : na
    pvT = not na(pv) ? time[pl] : na
    [ph, pv, phT, pvT]

buildHTFRange(string tf, int pl) =>
    [htfPH, htfPL, htfPHTime, htfPLTime] = request.security(
         syminfo.tickerid, tf, htfPivotExpr(pl),
         lookahead=barmerge.lookahead_off)

    var float lastPH  = na
    var float lastPL  = na
    var int   lastPHt = na
    var int   lastPLt = na

    if not na(htfPH) and (na(lastPHt) or htfPHTime > lastPHt)
        lastPH  := htfPH
        lastPHt := htfPHTime
    if not na(htfPL) and (na(lastPLt) or htfPLTime > lastPLt)
        lastPL  := htfPL
        lastPLt := htfPLTime

    not na(lastPH) and not na(lastPL)
         ? Range.new(lastPH, lastPL, lastPHt, lastPLt, lastPLt < lastPHt, "HTF")
         : na

buildManualRange(float mh, float ml) =>
    mh > 0 and ml > 0 and mh > ml
         ? Range.new(mh, ml, time, time, true, "MANUAL")
         : na

// IPDA range — hybrid implementation.
//
// Default: compute natively in chart timeframe (no request.security) so the
// result is reproducible regardless of chart load state. Translates the HTF
// lookback to chart-native bars via timeframe.in_seconds.
//
// Fallback: on chart timeframes where the native lookback exceeds Pine's
// max_bars_back budget (e.g. IPDA-60 daily on a 15m chart needs 5,760
// native bars, but Pine caps at 5,000), fall back to request.security on
// the HTF timeframe directly. This requires only `lb` HTF bars of data,
// well within any practical limit. The fallback path has the well-known
// chart-load-state caveat: ensure the chart has loaded enough HTF history
// before relying on historical IPDA values.
//
// Implementation note: ta.* functions maintain historical state and must
// be called on every bar for consistency. We compute both native and
// security paths unconditionally, then select between them based on
// whether the native lookback fits within budget. This avoids Pine's
// "function called inside conditional" warning.
ipdaSecurityExpr(int lb) =>
    hh        = ta.highest(high, lb)
    ll        = ta.lowest(low,   lb)
    hhOffset  = -ta.highestbars(high, lb)
    llOffset  = -ta.lowestbars(low,   lb)
    hhTime    = time[hhOffset]
    llTime    = time[llOffset]
    [hh, ll, hhTime, llTime]

buildIPDARange(string tf, int lb) =>
    htfSeconds    = timeframe.in_seconds(tf)
    nativeSeconds = timeframe.in_seconds(timeframe.period)
    nativeBars    = math.max(1, math.round(lb * htfSeconds / nativeSeconds))
    useNative     = nativeBars <= 5000

    // Native path: clamp lookback to 5000 to stay within max_bars_back when
    // we're going to use it; we still call this every bar regardless of
    // useNative so ta.* internal state stays consistent.
    safeLookback  = math.min(nativeBars, 5000)
    nHigh         = ta.highest(high, safeLookback)
    nLow          = ta.lowest(low,   safeLookback)
    nHighOff      = -ta.highestbars(high, safeLookback)
    nLowOff       = -ta.lowestbars(low,   safeLookback)
    nHighTime     = time[nHighOff]
    nLowTime      = time[nLowOff]

    // Security path: always evaluated for the same consistency reason.
    [sHigh, sLow, sHighTime, sLowTime] = request.security(syminfo.tickerid, tf,
         ipdaSecurityExpr(lb), lookahead=barmerge.lookahead_off)

    // Select which path to use for this bar.
    hh     = useNative ? nHigh     : sHigh
    ll     = useNative ? nLow      : sLow
    hhTime = useNative ? nHighTime : sHighTime
    llTime = useNative ? nLowTime  : sLowTime
    source = useNative ? ("IPDA-" + str.tostring(lb) + tf + "-native")
                       : ("IPDA-" + str.tostring(lb) + tf + "-htf")

    not na(hh) and not na(ll) and hhTime != llTime
         ? Range.new(hh, ll, hhTime, llTime, llTime < hhTime, source)
         : na

// ─── MODULE 2: GOLDBACH GRID ───────────────────────────────────────────────

buildGoldbachGrid(Range r, bool invert) =>
    array<GoldbachLevel> levels = array.new<GoldbachLevel>()
    if not na(r)
        rng = r.high - r.low
        flipDir = invert and not r.isBullish

        // ICT canonical Goldbach levels — prime-partition values that sum to 100.
        // Each line carries the role of the ZONE between it and the next-deeper
        // line (the one closer to the extreme). Per ICT teaching: "we take the
        // value of the level just below it until the current value." flipDir
        // mirrors role labels when the underlying range formed bearishly.

        // 0 / 100 — Range extremes (Liquidity / Sweep zones)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.00, 0.00, flipDir ? "EXT_HIGH" : "EXT_LOW",  colExtreme))
        // 3 / 97 — RB trigger (zone 0-3 / 97-100 = Rejection Block)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.03, 0.03, flipDir ? "RB_HIGH"  : "RB_LOW",   colRB))
        // 11 / 89 — OB trigger (zone 3-11 / 89-97 = Order Block)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.11, 0.11, flipDir ? "OB_HIGH"  : "OB_LOW",   colOB))
        // 17 / 83 — FVG trigger (zone 11-17 / 83-89 = Fair Value Gap)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.17, 0.17, flipDir ? "FVG_HIGH" : "FVG_LOW",  colFVG))
        // 29 / 71 — boundary line (zone 17-29 / 71-83 has no canonical role)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.29, 0.29, flipDir ? "P29_HIGH" : "P29_LOW",  colNeutral))
        // 35 / 65 — non-prime "speed bump" levels within LV (visual reference only)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.35, 0.35, "SB_LOW",                          colSpeedBump))
        // 41 / 59 — LV trigger (zone 29-41 / 59-71 = Liquidity Void)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.41, 0.41, flipDir ? "LV_HIGH"  : "LV_LOW",   colLV))
        // 47 / 53 — BRK trigger (zone 41-47 / 53-59 = Breaker)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.47, 0.47, flipDir ? "BRK_HIGH" : "BRK_LOW",  colBreaker))
        // 50 — Equilibrium / MB (zone 47-53 = Mitigation Block, midpoint)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.50, 0.50, "EQ",                              colEQ))
        // 53 / 47 — BRK trigger (premium side)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.53, 0.53, flipDir ? "BRK_LOW"  : "BRK_HIGH", colBreaker))
        // 59 / 41 — LV trigger (premium side)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.59, 0.59, flipDir ? "LV_LOW"   : "LV_HIGH",  colLV))
        // 65 / 35 — speed bump (premium side)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.65, 0.65, "SB_HIGH",                         colSpeedBump))
        // 71 / 29 — boundary (premium side)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.71, 0.71, flipDir ? "P29_LOW"  : "P29_HIGH", colNeutral))
        // 83 / 17 — FVG trigger (premium side)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.83, 0.83, flipDir ? "FVG_LOW"  : "FVG_HIGH", colFVG))
        // 89 / 11 — OB trigger (premium side)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.89, 0.89, flipDir ? "OB_LOW"   : "OB_HIGH",  colOB))
        // 97 / 3 — RB trigger (premium side)
        array.push(levels, GoldbachLevel.new(r.low + rng * 0.97, 0.97, flipDir ? "RB_LOW"   : "RB_HIGH",  colRB))
        // 100 — Range extreme (premium side)
        array.push(levels, GoldbachLevel.new(r.low + rng * 1.00, 1.00, flipDir ? "EXT_LOW"  : "EXT_HIGH", colExtreme))
    levels

// ─── MODULE 3: PO3 ENGINE ──────────────────────────────────────────────────

// All anchor candidates evaluated unconditionally so ta.change/[1] history
// remains valid regardless of which mode the user selects.
detectAnchor() =>
    nyMidFire = ta.change(time("D", "", "America/New_York")) != 0
    utcFire   = ta.change(time("D", "", "UTC"))               != 0
    wkFire    = ta.change(time("W", "", "America/New_York")) != 0
    moFire    = ta.change(time("M", "", "America/New_York")) != 0

    // Session "in/out" detection — fire on first bar that enters the session
    asiaIn   = not na(time("",  "2000-2359", "America/New_York"))
    londonIn = not na(time("",  "0200-0500", "America/New_York"))
    nyIn     = not na(time("",  "0700-1000", "America/New_York"))
    custIn   = not na(time("",  customSess,  customTz))

    asiaFire   = asiaIn   and not asiaIn[1]
    londonFire = londonIn and not londonIn[1]
    nyFire     = nyIn     and not nyIn[1]
    custFire   = custIn   and not custIn[1]

    switch anchorMode
        "Daily NY Midnight" => nyMidFire
        "Daily UTC"         => utcFire
        "Weekly"            => wkFire
        "Monthly"           => moFire
        "Session: Asian"    => asiaFire
        "Session: London"   => londonFire
        "Session: NY"       => nyFire
        "Session: Custom"   => custFire
        =>                     false

// In-place mutation: returns same reference, modified.
updatePO3(PO3State s, float h, float l, float c, float atrVal) =>
    if not na(s)
        // Watermark updates
        if h > s.postHi
            s.postHi     := h
            s.postHiTime := time
        if l < s.postLo
            s.postLo     := l
            s.postLoTime := time

        distFromOpen = math.abs(c - s.trueOpen)

        // ACCUMULATION → MANIPULATION
        if s.phase == "ACCUMULATION" and distFromOpen > accumThresh * atrVal
            s.phase    := "MANIPULATION"
            s.judasUp  := c > s.trueOpen
            s.judasDown:= c < s.trueOpen

        // MANIPULATION → DISTRIBUTION
        if s.phase == "MANIPULATION" and s.biasResolved == 0
            crossedBack = s.judasUp ? (c < s.trueOpen) : (c > s.trueOpen)
            farEnough   = math.abs(c - s.trueOpen) >= displaceMult * atrVal
            fvgOK       = not requireFVG or (s.judasUp ? hasBearishFVG() : hasBullishFVG())
            if crossedBack and farEnough and fvgOK
                s.phase        := "DISTRIBUTION"
                s.biasResolved := s.judasUp ? -1 : +1
                s.distTime     := time
                s.distPrice    := c
                s.distDispMult := math.abs(c - s.trueOpen) / atrVal
    s

// ─── MODULE 4: SIGNAL ENGINE ───────────────────────────────────────────────

// HTF bias expression — returns +1 when HTF close above SMA, -1 otherwise.
htfBiasExpr(int len) =>
    close > ta.sma(close, len) ? 1 : -1

// Tap detection helpers — boolean for whether the current bar's wick range
// contains a level of the specified pct.
tappedLevel(array<GoldbachLevel> grid, float wantPct) =>
    bool result = false
    if array.size(grid) > 0
        for lvl in grid
            if lvl.pct == wantPct and low <= lvl.price and high >= lvl.price
                result := true
                break
    result

// Per-bar "any premium / any discount / sweep / EQ" flags
premiumTapped(array<GoldbachLevel> grid) =>
    bool result = false
    if array.size(grid) > 0
        for lvl in grid
            if lvl.pct > 0.5 and low <= lvl.price and high >= lvl.price
                result := true
                break
    result

discountTapped(array<GoldbachLevel> grid) =>
    bool result = false
    if array.size(grid) > 0
        for lvl in grid
            if lvl.pct < 0.5 and low <= lvl.price and high >= lvl.price
                result := true
                break
    result

sweepTapped(array<GoldbachLevel> grid) =>
    bool result = false
    if array.size(grid) > 0
        for lvl in grid
            if (lvl.pct == 0.0 or lvl.pct == 1.0) and low <= lvl.price and high >= lvl.price
                result := true
                break
    result

eqTapped(array<GoldbachLevel> grid) =>
    bool result = false
    if array.size(grid) > 0
        for lvl in grid
            if lvl.pct == 0.5 and low <= lvl.price and high >= lvl.price
                result := true
                break
    result

// Main signal evaluator. Walks the grid once per bar, finds the first level
// that satisfies all preset filters. Returns na if no signal qualifies.
evaluateSignal(Range r, array<GoldbachLevel> grid, PO3State p,
     string presetIn, bool htfFilterOn, int htfBias, int lastSigBar,
     int cooldown) =>
    Signal sig = na
    if not na(r) and array.size(grid) > 0 and not na(p)
        for lvl in grid
            // Skip EQ — ambiguous direction
            if lvl.pct == 0.5
                continue

            // Tap check
            if not (low <= lvl.price and high >= lvl.price)
                continue

            impliedDir = lvl.pct < 0.5 ? 1 : -1

            // Role filter — based on which zone's trigger line is being tapped:
            //   Strict:   OB (11/89) and FVG (17/83) only — 4 trigger lines
            //   Standard: adds LV (41/59) and BRK (47/53) — 8 trigger lines
            //   Loose:    all roles including RB (3/97) and MB (50) — 10 trigger lines
            // Excluded everywhere: EXT (0/100), boundary lines (29/71), speed bumps (35/65).
            isOB  = lvl.pct == 0.11 or lvl.pct == 0.89
            isFVG = lvl.pct == 0.17 or lvl.pct == 0.83
            isLV  = lvl.pct == 0.41 or lvl.pct == 0.59
            isBRK = lvl.pct == 0.47 or lvl.pct == 0.53
            isRB  = lvl.pct == 0.03 or lvl.pct == 0.97
            isMB  = lvl.pct == 0.50
            isEXT = lvl.pct == 0.00 or lvl.pct == 1.00
            isNeutral  = lvl.pct == 0.29 or lvl.pct == 0.71
            isSpeedBump = lvl.pct == 0.35 or lvl.pct == 0.65

            // Speed bumps and boundary lines never trigger signals
            triggerable = not isEXT and not isNeutral and not isSpeedBump

            roleOK = not triggerable ? false
                 : presetIn == "Strict"   ? (isOB or isFVG)
                 : presetIn == "Standard" ? (isOB or isFVG or isLV or isBRK)
                 : presetIn == "Loose"    ? true
                 : false

            // PO3 filter
            po3OK = false
            if presetIn == "Loose"
                po3OK := p.phase == "MANIPULATION" or p.phase == "DISTRIBUTION"
            else
                po3OK := p.biasResolved == impliedDir

            // Strict displacement requirement
            dispOK = presetIn != "Strict" or (not na(p.distDispMult) and p.distDispMult >= 1.5)

            // HTF bias filter
            useHTFBias = presetIn == "Strict" or (presetIn == "Standard" and htfFilterOn)
            htfOK = not useHTFBias or htfBias == impliedDir

            // Cooldown
            cooldownOK = na(lastSigBar) or (bar_index - lastSigBar) >= cooldown

            if roleOK and po3OK and dispOK and htfOK and cooldownOK
                sig := Signal.new(
                     sigBar=bar_index, sigTime=time, price=close,
                     direction=impliedDir,
                     goldbachRole=lvl.role, goldbachPct=lvl.pct,
                     po3Phase=p.phase, po3Bias=p.biasResolved,
                     preset=presetIn)
                break
    sig



// Range / Grid
var Range                activeRange = na
var array<GoldbachLevel> activeGrid  = array.new<GoldbachLevel>()
var array<line>          gridLines   = array.new<line>()
var array<label>         gridLabels  = array.new<label>()
var box                  premiumBox  = na
var box                  discountBox = na
var bool                 needsRender = false

// PO3
var PO3State            po3           = na
var box                 liveBox       = na
var line                trueOpenLine  = na
var label               trueOpenLabel = na
var array<HistDrawings> histList      = array.new<HistDrawings>()

// Signals
var Signal lastSig          = na
var int    lastSignalBar    = na
var string prevPhase        = ""
var int    prevBias         = 0

// Status Table (grown to 15 rows for signal section)
var table statusTbl = table.new(posMap(tablePos), 2, 15,
     bgcolor=color.new(color.black, 75),
     border_width=1,
     border_color=color.new(color.gray, 50))

clearGridArrays() =>
    for ln in gridLines
        line.delete(ln)
    array.clear(gridLines)
    for lb in gridLabels
        label.delete(lb)
    array.clear(gridLabels)

// ─── MAIN LOOP: RANGE / GRID ───────────────────────────────────────────────

candidate = switch rangeSource
    "HTF Swing"     => buildHTFRange(htfTf, pivotLen)
    "IPDA Lookback" => buildIPDARange(htfTf, ipdaLookback)
    "Manual"        => buildManualRange(manualHigh, manualLow)
    =>                 na

if rangeChanged(activeRange, candidate) and not na(candidate)
    activeRange := candidate
    activeGrid  := buildGoldbachGrid(activeRange, invertOnBear)
    needsRender := true

// ─── MAIN LOOP: PO3 ────────────────────────────────────────────────────────

atrVal       = ta.atr(atrLen)
anchorRaw    = detectAnchor()
anchorFired  = showPO3 and anchorRaw

if anchorFired
    // Archive previous period if it had a resolved bias
    if not na(po3) and po3.biasResolved != 0 and showHist
        histBorder = po3.biasResolved == 1 ? colBullPeriod : colBearPeriod

        bg = box.new(
             left=po3.openTime, top=po3.postHi,
             right=time[1],     bottom=po3.postLo,
             xloc=xloc.bar_time,
             bgcolor=color.new(color.white, 100),
             border_color=histBorder,
             border_width=2)

        judasPrice = po3.judasUp ? po3.postHi : po3.postLo
        judasTime  = po3.judasUp ? po3.postHiTime : po3.postLoTime
        judasText  = po3.judasUp ? "J↑" : "J↓"
        judasStyle = po3.judasUp ? label.style_label_down : label.style_label_up
        jl = label.new(
             x=judasTime, y=judasPrice, text=judasText,
             xloc=xloc.bar_time, style=judasStyle,
             color=color.new(color.black, 30),
             textcolor=colJudasMark, size=size.small)

        dl = label.new(
             x=po3.distTime, y=po3.distPrice, text="D",
             xloc=xloc.bar_time,
             style=po3.biasResolved == 1 ? label.style_label_up : label.style_label_down,
             color=color.new(color.black, 30),
             textcolor=colDistMark, size=size.small)

        array.push(histList, HistDrawings.new(bg, jl, dl))

        // Cap historical drawings
        while array.size(histList) > maxHistPeriods
            HistDrawings old = array.shift(histList)
            box.delete(old.bg)
            label.delete(old.judas)
            label.delete(old.dist)

    // Clean up live period box
    if not na(liveBox)
        box.delete(liveBox)
        liveBox := na
    if not na(trueOpenLine)
        line.delete(trueOpenLine)
        trueOpenLine := na
    if not na(trueOpenLabel)
        label.delete(trueOpenLabel)
        trueOpenLabel := na

    // Initialize new period
    po3 := PO3State.new(
         trueOpen=open, openTime=time, openBar=bar_index,
         postHi=high, postLo=low,
         postHiTime=time, postLoTime=time,
         phase="ACCUMULATION",
         judasUp=false, judasDown=false,
         biasResolved=0, distTime=na, distPrice=na, distDispMult=na)

// Update active period state
if showPO3 and not na(po3) and not na(atrVal)
    po3 := updatePO3(po3, high, low, close, atrVal)

// ─── MAIN LOOP: SIGNALS & ALERTS ───────────────────────────────────────────

// HTF bias (always computed; used only when filter is active)
htfBiasVal = request.security(syminfo.tickerid, htfBiasTf,
     htfBiasExpr(htfBiasLen), lookahead=barmerge.lookahead_off)

// Phase/bias transition detection (compare to previous-bar snapshots)
manipEntered     = showPO3 and not na(po3) and po3.phase == "MANIPULATION" and prevPhase == "ACCUMULATION"
distConfirmedBull = showPO3 and not na(po3) and po3.biasResolved == 1  and prevBias == 0
distConfirmedBear = showPO3 and not na(po3) and po3.biasResolved == -1 and prevBias == 0

// Per-bar Goldbach tap flags (for granular alerts)
gbEqTap       = not na(activeRange) and eqTapped(activeGrid)
gbPremiumTap  = not na(activeRange) and premiumTapped(activeGrid)
gbDiscountTap = not na(activeRange) and discountTapped(activeGrid)
gbSweepTap    = not na(activeRange) and sweepTapped(activeGrid)

// Signal evaluation
sig = showSignals
     ? evaluateSignal(activeRange, activeGrid, po3, preset, htfBiasFilter,
                     htfBiasVal, lastSignalBar, cooldownBars)
     : na

if not na(sig)
    lastSig        := sig
    lastSignalBar  := bar_index

// Boolean series for plotshape and alertcondition (must be at global scope)
longSignal  = not na(sig) and sig.direction == 1
shortSignal = not na(sig) and sig.direction == -1

// Snapshot phase/bias for next bar's transition detection
prevPhase := not na(po3) ? po3.phase : ""
prevBias  := not na(po3) ? po3.biasResolved : 0

// ─── RENDERING: GRID (barstate.islast guard) ───────────────────────────────

if barstate.islast and showGrid and not na(activeRange) and array.size(activeGrid) > 0 and needsRender
    clearGridArrays()
    if not na(premiumBox)
        box.delete(premiumBox)
        premiumBox := na
    if not na(discountBox)
        box.delete(discountBox)
        discountBox := na

    rng      = activeRange.high - activeRange.low
    eqPrice  = activeRange.low + rng * 0.5
    leftTime = math.min(activeRange.highTime, activeRange.lowTime)

    if showTints
        premiumBox := box.new(
             left=leftTime, top=activeRange.high, right=time, bottom=eqPrice,
             xloc=xloc.bar_time, border_color=color.new(color.white, 100),
             bgcolor=colPremium, extend=extend.right)
        discountBox := box.new(
             left=leftTime, top=eqPrice, right=time, bottom=activeRange.low,
             xloc=xloc.bar_time, border_color=color.new(color.white, 100),
             bgcolor=colDiscount, extend=extend.right)

    for lvl in activeGrid
        isEQ = lvl.pct == 0.5
        ln = line.new(
             x1=leftTime, y1=lvl.price, x2=time, y2=lvl.price,
             xloc=xloc.bar_time, extend=extend.right,
             color=lvl.col,
             width=isEQ ? lineWidth + 1 : lineWidth,
             style=isEQ ? line.style_solid : line.style_dashed)
        array.push(gridLines, ln)

        if showLabels
            txt = lvl.role + " " + str.tostring(lvl.pct * 100, "#.#") + "%"
            lb = label.new(
                 x=time, y=lvl.price, text=txt,
                 xloc=xloc.bar_time, style=label.style_label_left,
                 color=color.new(color.black, 70),
                 textcolor=lvl.col,
                 size=labelSizeMap(labelSizeIn))
            array.push(gridLabels, lb)

    needsRender := false

// ─── RENDERING: LIVE PERIOD BOX + TRUE OPEN ────────────────────────────────

if barstate.islast and showPO3 and showLiveBox and not na(po3)
    // Border color reflects current PO3 bias — uses the same input colors
    // as historical periods for visual consistency.
    borderCol = po3.biasResolved == 1 ? colBullPeriod
         : po3.biasResolved == -1 ? colBearPeriod
         : colLivePeriod

    if na(liveBox)
        liveBox := box.new(
             left=po3.openTime, top=po3.postHi,
             right=time, bottom=po3.postLo,
             xloc=xloc.bar_time,
             bgcolor=color.new(color.white, 100),
             border_color=borderCol,
             border_width=2,
             border_style=line.style_dashed)
    else
        box.set_top(liveBox, po3.postHi)
        box.set_bottom(liveBox, po3.postLo)
        box.set_right(liveBox, time)
        box.set_border_color(liveBox, borderCol)

    // True-open reference line — dotted, anchored at the period's true open price
    if na(trueOpenLine)
        trueOpenLine := line.new(
             x1=po3.openTime, y1=po3.trueOpen,
             x2=time,         y2=po3.trueOpen,
             xloc=xloc.bar_time, color=colTrueOpen,
             style=line.style_dotted, width=1)
        trueOpenLabel := label.new(
             x=po3.openTime, y=po3.trueOpen,
             text="Open",
             xloc=xloc.bar_time, style=label.style_label_left,
             color=color.new(color.black, 60),
             textcolor=colTrueOpen, size=size.tiny)
    else
        line.set_x2(trueOpenLine, time)

// ─── RENDERING: SIGNAL MARKERS ─────────────────────────────────────────────

// Triangle markers (declarative — rendered automatically when bool series fires).
// No text on the triangle itself; the colored direction is enough.
plotshape(longSignal,  title="Long Signal",  style=shape.triangleup,
     location=location.belowbar, color=colLongSig,  size=size.small)
plotshape(shortSignal, title="Short Signal", style=shape.triangledown,
     location=location.abovebar, color=colShortSig, size=size.small)

// ─── HIDDEN METADATA PLOTS FOR CSV EXPORT ──────────────────────────────────
// These don't render on the chart (display=display.data_window) but appear
// in the Data Window panel and TradingView's "Export chart data" CSV.
// Use them to do hit-rate / MFE-MAE / preset comparison analysis externally.
sigDirCSV   = not na(sig) ? sig.direction        : float(na)
sigPctCSV   = not na(sig) ? sig.goldbachPct      : float(na)
sigBiasCSV  = not na(sig) ? float(sig.po3Bias)   : float(na)
sigPriceCSV = not na(sig) ? sig.price            : float(na)
rngHiCSV    = not na(activeRange) ? activeRange.high : float(na)
rngLoCSV    = not na(activeRange) ? activeRange.low  : float(na)
posPctCSV   = not na(activeRange) and (activeRange.high - activeRange.low) > 0
     ? (close - activeRange.low) / (activeRange.high - activeRange.low) * 100
     : float(na)

// Preset → integer encoding (Strict=0, Standard=1, Loose=2). Always emitted
// (every bar) so cross-preset CSV exports can be concatenated and tagged.
presetCodeCSV = preset == "Strict" ? 0 : preset == "Standard" ? 1 : 2

plot(sigDirCSV,    title="sig_direction",  display=display.data_window, color=color.new(color.white, 100))
plot(sigPctCSV,    title="sig_pct",        display=display.data_window, color=color.new(color.white, 100))
plot(sigBiasCSV,   title="sig_po3_bias",   display=display.data_window, color=color.new(color.white, 100))
plot(sigPriceCSV,  title="sig_price",      display=display.data_window, color=color.new(color.white, 100))
plot(rngHiCSV,     title="range_high",     display=display.data_window, color=color.new(color.white, 100))
plot(rngLoCSV,     title="range_low",      display=display.data_window, color=color.new(color.white, 100))
plot(posPctCSV,    title="position_pct",   display=display.data_window, color=color.new(color.white, 100))
plot(presetCodeCSV, title="sig_preset",    display=display.data_window, color=color.new(color.white, 100))

// Bar background highlight on signal bars — translucent vertical strip behind
// the firing candle. Visible at any zoom level, regardless of chart density.
sigBgCol = showSigHighlight and longSignal  ? color.new(colLongSig, sigBgAlpha)
     : showSigHighlight and shortSignal ? color.new(colShortSig, sigBgAlpha)
     : na
bgcolor(sigBgCol, title="Signal Bar Highlight")

// Compact one-line breakdown label, offset 0.5×ATR from bar extreme to clear
// Goldbach grid role labels and the trueOpen line.
if not na(sig) and showSignalLabels
    biasTxt = sig.po3Bias == 1 ? "Bull" : sig.po3Bias == -1 ? "Bear" : "Unres"
    txt = sig.goldbachRole + " " + str.tostring(sig.goldbachPct * 100, "#.#") + "%"
         + "  •  " + biasTxt + "  •  " + sig.preset
    yOffset = na(atrVal) ? 0.0 : atrVal * 0.5
    ySig    = sig.direction == 1 ? low - yOffset : high + yOffset
    label.new(
         x=bar_index, y=ySig, text=txt,
         style=sig.direction == 1 ? label.style_label_up : label.style_label_down,
         color=color.new(sig.direction == 1 ? colLongSig : colShortSig, 30),
         textcolor=color.white, size=size.small)

// ─── STATUS TABLE ──────────────────────────────────────────────────────────

if barstate.islast and showStatusTable and not na(activeRange)
    rng     = activeRange.high - activeRange.low
    rngPct  = rng / activeRange.low * 100
    eq      = activeRange.low + rng * 0.5
    posPct  = (close - activeRange.low) / rng * 100
    posLbl  = posPct >= 50 ? "Premium" : "Discount"
    posCol  = posPct >= 50 ? #ef5350 : #26a69a
    txtSize = tableSizeMap(tableSizeIn)

    // Header
    table.cell(statusTbl, 0, 0, "GBB Grid", text_color=color.white,
         bgcolor=color.new(color.blue, 30), text_size=txtSize)
    table.cell(statusTbl, 1, 0, "v3", text_color=color.white,
         bgcolor=color.new(color.blue, 30), text_size=txtSize)

    // Range section
    table.cell(statusTbl, 0, 1, "Source",   text_color=color.gray, text_size=txtSize)
    table.cell(statusTbl, 1, 1, activeRange.source, text_color=color.white, text_size=txtSize)

    table.cell(statusTbl, 0, 2, "Bias",     text_color=color.gray, text_size=txtSize)
    table.cell(statusTbl, 1, 2, activeRange.isBullish ? "Bullish" : "Bearish",
         text_color=activeRange.isBullish ? #26a69a : #ef5350, text_size=txtSize)

    table.cell(statusTbl, 0, 3, "High",     text_color=color.gray, text_size=txtSize)
    table.cell(statusTbl, 1, 3, str.tostring(activeRange.high, format.mintick),
         text_color=color.white, text_size=txtSize)
    table.cell(statusTbl, 0, 4, "Low",      text_color=color.gray, text_size=txtSize)
    table.cell(statusTbl, 1, 4, str.tostring(activeRange.low, format.mintick),
         text_color=color.white, text_size=txtSize)

    table.cell(statusTbl, 0, 5, "Range",    text_color=color.gray, text_size=txtSize)
    table.cell(statusTbl, 1, 5, str.tostring(rng, format.mintick) + " (" + str.tostring(rngPct, "#.##") + "%)",
         text_color=color.white, text_size=txtSize)

    table.cell(statusTbl, 0, 6, "EQ (50%)", text_color=color.gray, text_size=txtSize)
    table.cell(statusTbl, 1, 6, str.tostring(eq, format.mintick),
         text_color=color.yellow, text_size=txtSize)

    table.cell(statusTbl, 0, 7, "Position", text_color=color.gray, text_size=txtSize)
    table.cell(statusTbl, 1, 7, str.tostring(posPct, "#.#") + "% " + posLbl,
         text_color=posCol, text_size=txtSize)

    // PO3 section separator (merged across both columns for clean look)
    table.cell(statusTbl, 0, 8, "── PO3 ──", text_color=color.gray,
         bgcolor=color.new(color.gray, 80), text_size=txtSize)
    table.cell(statusTbl, 1, 8, "", bgcolor=color.new(color.gray, 80), text_size=txtSize)
    table.merge_cells(statusTbl, 0, 8, 1, 8)

    if showPO3 and not na(po3)
        phaseTxt = po3.phase == "ACCUMULATION" ? "Accumulation"
             : po3.phase == "MANIPULATION" ? "Manipulation"
             : "Distribution"
        phaseCol = po3.phase == "ACCUMULATION" ? color.gray
             : po3.phase == "MANIPULATION" ? color.yellow
             : (po3.biasResolved == 1 ? #26a69a : #ef5350)

        judasTxt = po3.judasUp ? "Up ↑" : po3.judasDown ? "Down ↓" : "—"
        judasCol = po3.judasUp or po3.judasDown ? color.white : color.gray

        biasTxt = po3.biasResolved == 1 ? "Bullish PO3"
             : po3.biasResolved == -1 ? "Bearish PO3"
             : "Unresolved"
        biasCol = po3.biasResolved == 1 ? #26a69a
             : po3.biasResolved == -1 ? #ef5350
             : color.gray

        table.cell(statusTbl, 0, 9,  "Phase",     text_color=color.gray, text_size=txtSize)
        table.cell(statusTbl, 1, 9,  phaseTxt,    text_color=phaseCol,   text_size=txtSize)
        table.cell(statusTbl, 0, 10, "Judas",     text_color=color.gray, text_size=txtSize)
        table.cell(statusTbl, 1, 10, judasTxt,    text_color=judasCol,   text_size=txtSize)
        table.cell(statusTbl, 0, 11, "PO3 Bias",  text_color=color.gray, text_size=txtSize)
        table.cell(statusTbl, 1, 11, biasTxt,     text_color=biasCol,    text_size=txtSize)
    else
        table.cell(statusTbl, 0, 9,  "Phase",    text_color=color.gray, text_size=txtSize)
        table.cell(statusTbl, 1, 9,  "—",        text_color=color.gray, text_size=txtSize)
        table.cell(statusTbl, 0, 10, "Judas",    text_color=color.gray, text_size=txtSize)
        table.cell(statusTbl, 1, 10, "—",        text_color=color.gray, text_size=txtSize)
        table.cell(statusTbl, 0, 11, "PO3 Bias", text_color=color.gray, text_size=txtSize)
        table.cell(statusTbl, 1, 11, "—",        text_color=color.gray, text_size=txtSize)

    // Signals section separator
    table.cell(statusTbl, 0, 12, "── Signals ──", text_color=color.gray,
         bgcolor=color.new(color.gray, 80), text_size=txtSize)
    table.cell(statusTbl, 1, 12, "", bgcolor=color.new(color.gray, 80), text_size=txtSize)
    table.merge_cells(statusTbl, 0, 12, 1, 12)

    presetCol = preset == "Strict" ? color.aqua
         : preset == "Standard" ? color.white
         : color.orange
    table.cell(statusTbl, 0, 13, "Preset",   text_color=color.gray, text_size=txtSize)
    table.cell(statusTbl, 1, 13, preset,     text_color=presetCol,  text_size=txtSize)

    if not na(lastSig)
        barsAgo  = bar_index - lastSig.sigBar
        sigTxt   = (lastSig.direction == 1 ? "Long" : "Short")
             + " @ " + str.tostring(lastSig.price, format.mintick)
             + " (" + str.tostring(barsAgo) + "b)"
        sigCol   = lastSig.direction == 1 ? #26a69a : #ef5350
        table.cell(statusTbl, 0, 14, "Last Sig", text_color=color.gray, text_size=txtSize)
        table.cell(statusTbl, 1, 14, sigTxt,     text_color=sigCol,     text_size=txtSize)
    else
        table.cell(statusTbl, 0, 14, "Last Sig", text_color=color.gray, text_size=txtSize)
        table.cell(statusTbl, 1, 14, "—",        text_color=color.gray, text_size=txtSize)

// ─── ALERTS ─────────────────────────────────────────────────────────────────
// Granular conditions — each subscribable separately in TradingView's alert dialog.

// Goldbach taps
alertcondition(gbEqTap,
     title   = "Goldbach: EQ tap",
     message = "GBB EQ tap on {{ticker}} {{interval}} at {{close}}")
alertcondition(gbPremiumTap,
     title   = "Goldbach: Premium tap",
     message = "GBB Premium-half tap on {{ticker}} {{interval}} at {{close}}")
alertcondition(gbDiscountTap,
     title   = "Goldbach: Discount tap",
     message = "GBB Discount-half tap on {{ticker}} {{interval}} at {{close}}")
alertcondition(gbSweepTap,
     title   = "Goldbach: Sweep (0% / 100%)",
     message = "GBB Range-extreme sweep on {{ticker}} {{interval}} at {{close}}")

// PO3 phase transitions
alertcondition(manipEntered,
     title   = "PO3: Manipulation phase entered",
     message = "GBB Manipulation phase entered on {{ticker}} {{interval}}")
alertcondition(distConfirmedBull,
     title   = "PO3: Distribution confirmed bullish",
     message = "GBB Bullish distribution confirmed on {{ticker}} {{interval}} at {{close}}")
alertcondition(distConfirmedBear,
     title   = "PO3: Distribution confirmed bearish",
     message = "GBB Bearish distribution confirmed on {{ticker}} {{interval}} at {{close}}")

// Signals
alertcondition(longSignal,
     title   = "Signal: Long",
     message = "GBB LONG on {{ticker}} {{interval}} at {{close}}")
alertcondition(shortSignal,
     title   = "Signal: Short",
     message = "GBB SHORT on {{ticker}} {{interval}} at {{close}}")
````
