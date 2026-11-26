# SMC Flip Zone Engine Viprasol

- url: https://www.tradingview.com/script/ZQqAWw1v-SMC-Flip-Zone-Engine-Viprasol/
- type: indicator
- pine_id: PUB;7425a2862bd748dc896fefaee9d4acec
- version: 1.0

## Description

Overview

The original detects a break of structure, walks back to find the reaction leg that preceded it, and draws a colored zone box, with optional Liquidity Sweep, Fair Value Gap, HTF EMA alignment, and OTE (discount/premium) filters that can be toggled on to reduce noise. This version keeps that zone-detection engine intact and adds a Viprasol confluence and lifecycle layer: a 0-4 confluence score with A/B/C grading, a minimum-score gate, zone mitigation (retest) and invalidation tracking, a per-side cooldown, and an ATR-free risk overlay that projects Entry/SL/TP from a zone when price returns to it.

It is built for traders who work with break-of-structure flip zones and want each zone graded by how much SMC confluence actually backs it, plus automatic tracking of when zones are retested or broken.

How It Works

Structure Break & Reaction Leg (from original):
A bullish flip is triggered when close crosses over the prior highest-high of the lookback window (supply broken); a bearish flip when close crosses under the prior lowest-low (demand broken). On a break, the script walks back over the reaction-leg length to find the extreme of the trap leg — for a bull flip, the lowest low in that window and its bar's high define the zone's bottom and top. A box is drawn from that reaction bar forward.

SMC Filters (from original, toggle-gated):
Four optional filters can each be required before a zone is drawn:
- Liquidity Sweep — the reaction leg must have exceeded the prior structural extreme (taken liquidity).
- FVG / Displacement — a fair value gap must be present around the break (e.g. low > high[2]).
- HTF Alignment — bull zones only above, bear zones only below, the 50 EMA of a higher timeframe.
- OTE (Discount/Premium) — the zone midpoint must sit in the discount half (bull) or premium half (bear) of the leg, where equilibrium = leg low + (leg high − leg low) × 0.5.

Confluence Score & Grade (new):
Independently of which filters are toggled on, the script evaluates all four confluence conditions as raw booleans on every new zone and sums them into a 0-4 score:
  score = sweep? + fvg? + ote? + htfAligned?
The score is mapped to a grade — A (>= 3), B (= 2), C (<= 1) — and printed on the zone box. This means even with all filters off (so every break draws a zone), you can still see which zones are backed by genuine confluence. A "Minimum Confluence Score" input then lets you suppress any zone below a chosen score without having to hard-require specific filters.

Zone Mitigation & Invalidation (new):
Every existing zone is tracked across bars. A zone is mitigated the first time price trades back into its range (low <= top and high >= bot) — this fires a mitigation alert (a potential entry as the flip zone is retested). A zone is invalidated when price closes through it (close < bot for a bull zone, close > top for a bear zone); invalidated zones are recolored gray (or can be left as-is) and fire an invalidation alert. Each transition fires once per zone.

Risk Overlay on Mitigation (new):
When "Show SL/TP on Mitigation" is enabled, the first retest of a zone projects three lines: Entry at the near edge of the zone, Stop-Loss at the far edge (so the zone height is the risk), and Take-Profit at Entry ± zone-height × the Risk:Reward ratio. Colored ENTRY/SL/TP price labels mark the line ends. Only the most recent mitigation's projection is kept, to avoid clutter.

Per-Side Cooldown (new):
An optional cooldown enforces a minimum number of bars between new zones on the same side (tracked as bar_index − lastSideBar >= cooldown), preventing a burst of overlapping zones during a single fast move.

What Is Original (Viprasol Additions)

1. Confluence score (0-4) and A/B/C grade printed on each zone, computed from raw sweep/FVG/OTE/HTF conditions regardless of which filters are toggled.
2. Minimum-confluence-score gate — suppress low-quality zones without hard-requiring individual filters.
3. Zone mitigation (retest) detection with a dedicated alert.
4. Zone invalidation detection (price closes through) with recoloring and a dedicated alert.
5. Risk overlay — Entry/SL/TP projection with colored price labels drawn on the first mitigation of a zone, sized by zone height and the Risk:Reward ratio.
6. Per-side zone cooldown to prevent clustering.

Key Features

From the Original:
- Break-of-structure detection via crossover/crossunder of the lookback high/low
- Reaction-leg walk-back to locate the trap zone behind the break
- Bullish and bearish flip-zone boxes with labels
- Optional Liquidity Sweep, FVG, HTF 50-EMA alignment, and OTE filters
- Oldest-zone pruning to limit chart clutter

Added in This Version (Viprasol):
- 0-4 confluence score with A/B/C grade on every zone
- Minimum-score quality gate
- Mitigation (retest) and invalidation lifecycle tracking with recoloring
- Entry/SL/TP risk overlay with colored price labels on mitigation
- Per-side cooldown
- Info dashboard (active zone counts, HTF state, filters-on count, min score)
- Six alert conditions with dynamic {{ticker}}/{{close}}/{{interval}} messages

How to Use

Getting Started:
1. Add to a standard candlestick chart (not Heikin Ashi).
2. With all filters off (default), every structure break draws a graded zone — read the A/B/C grade to judge quality.
3. To trade only stronger setups, either raise "Minimum Confluence Score" or turn on the specific filters you require.

Reading the Chart:
- Green zone = bullish flip (drawn after a supply break); red zone = bearish flip (after a demand break).
- The bracket on each zone, e.g. [A 3/4], is the confluence grade and score.
- A zone turning gray means price closed through it — it is invalidated.
- When price returns into a zone and SL/TP is enabled, Entry/SL/TP lines and price labels project to the right.

Recommended Starting Points:
- Intraday (5m-15m): Lookback 20, Reaction 7, Min Score 0-1, Cooldown 0-3
- Swing (1H-4H): Lookback 30, Reaction 7-10, Min Score 2, enable HTF alignment
- Higher conviction: Min Score 3 (grade A only), or require Sweep + FVG

These are starting points only — every market and timeframe behaves differently. Backtest and adjust before trading live.

Settings

Market Structure: structure lookback period, reaction-leg length, and max zones kept per side.

SMC Strict Filters: toggles for Liquidity Sweep, FVG (displacement), HTF 50-EMA alignment (with HTF resolution), and OTE (discount/premium). All default off so zones appear immediately.

Confluence & Quality (Viprasol): minimum confluence score, show grade on zone, and per-side zone cooldown.

Risk Overlay (Viprasol): show SL/TP on mitigation, show price labels, and the Risk:Reward ratio.

Visuals: bullish/bearish fill and border colors, and a toggle to dim invalidated zones gray.

Dashboard / Display: dashboard toggle and position.

Alerts

1. New Bull Zone — a bullish flip zone was created
2. New Bear Zone — a bearish flip zone was created
3. Any New Zone — either direction created
4. Bull Mitigation — price returned to a bullish zone (potential long)
5. Bear Mitigation — price returned to a bearish zone (potential short)
6. Zone Invalidated — a zone was closed through and invalidated

All alerts include {{ticker}}, {{close}}, and {{interval}} for dynamic notification messages.

Limitations & Disclaimer

- Zones are created on the bar the structure break confirms; because detection uses crossover/crossunder of close versus the prior swing, signals are evaluated on the closing relationship and the reaction leg is identified after the fact.
- The HTF alignment filter uses request.security with lookahead disabled; HTF values update only as the higher-timeframe bar progresses.
- The FVG and OTE checks are simplified single-bar/leg-midpoint approximations, not full multi-leg ICT constructs.
- Mitigation is detected on the first wick back into a zone; this is an awareness signal, not a guaranteed reversal.
- SL/TP lines and price labels are visual references only and do not place or manage trades.
- Filters and the minimum-score gate reduce the number of zones; in choppy ranges valid zones may be suppressed, while in fast trends overlapping zones may appear if cooldown is off.
- Past performance does not guarantee future results. This indicator is for educational and analytical purposes only and is not financial advice. Always use proper risk management and test on historical data before trading live.

Credits & Attribution

Based on an open-source "Advanced SMC Flip Zones" community indicator, which provided the break-of-structure detection (crossover/crossunder of the lookback high/low), the reaction-leg walk-back that locates the trap zone, the bullish and bearish flip-zone boxes, the optional Liquidity Sweep / FVG / HTF 50-EMA / OTE filters, and the oldest-zone pruning. Added by Viprasol: the 0-4 confluence score and A/B/C grading, the minimum-score quality gate, zone mitigation and invalidation lifecycle tracking with recoloring, the Entry/SL/TP risk overlay with colored price labels, the per-side cooldown, the info dashboard, and the six-condition dynamic alert set.

Published open-source per TradingView House Rules.

## Source Code

````pine
// This Pine Script™ v6 indicator is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// (c) Viprasol

//@version=6
indicator(
    title            = "[Viprasol] SMC Flip Zone Engine",
    shorttitle       = "VP - SMCFZ",
    overlay          = true,
    max_boxes_count  = 500,
    max_labels_count = 500,
    max_lines_count  = 100
)

// ══════════════════════════════════════════════════════════════
// Constants — Viprasol Visual Identity
// ══════════════════════════════════════════════════════════════

const color BULL_SIGNATURE = #00ffaa     // Viprasol bull green
const color BEAR_SIGNATURE = #ff3d71     // Viprasol bear pink-red
const color INVALID_GRAY   = #6b7280     // broken / invalidated zone
const color PANEL_BG        = #111725
const color PANEL_HEADER    = #18233a
const color PANEL_BORDER    = #000000
const color PANEL_TEXT      = #e6e9f0
const color PANEL_MUTED     = #8a93a6
const color TP_LABEL_COL    = #22c55e
const color ENTRY_LABEL_COL = #00bcd4
const color SL_LABEL_COL    = #ef4444

// ══════════════════════════════════════════════════════════════
// Inputs
// ══════════════════════════════════════════════════════════════

string GRP_STRUCT  = "Market Structure"
string GRP_FILTERS = "SMC Strict Filters (toggle on to filter noise)"
string GRP_QUALITY = "Confluence & Quality (Viprasol)"
string GRP_RISK    = "Risk Overlay (Viprasol)"
string GRP_VISUAL  = "Visuals"
string GRP_DASH    = "Dashboard / Display"

// — Structure
lookbackInput       = input.int(20, "Structure Lookback Period", minval = 5, group = GRP_STRUCT,
     tooltip = "Bars used to define the swing high/low that, when broken, triggers a flip zone.")
reactionLengthInput = input.int(7, "Reaction Leg Length", minval = 3, group = GRP_STRUCT,
     tooltip = "Bars looked back to locate the trap / reaction leg before the break.")
maxZonesInput       = input.int(20, "Max Zones Per Side", minval = 5, maxval = 100, group = GRP_STRUCT,
     tooltip = "Oldest zones beyond this count are pruned from the chart.")

// — SMC filters (default false so zones appear immediately — original behaviour)
useSweepInput = input.bool(false, "1. Require Liquidity Sweep", group = GRP_FILTERS,
     tooltip = "Only create a zone if the reaction leg swept the prior structural extreme (took liquidity).")
useFvgInput   = input.bool(false, "2. Require FVG (Displacement)", group = GRP_FILTERS,
     tooltip = "Only create a zone if a Fair Value Gap (displacement) is present around the break.")
useHtfInput   = input.bool(false, "3. HTF Alignment (50 EMA)", group = GRP_FILTERS,
     tooltip = "Only create bull zones above, and bear zones below, the higher-timeframe 50 EMA.")
htfResInput   = input.timeframe("240", "HTF Resolution", group = GRP_FILTERS,
     tooltip = "Higher timeframe used for the 50 EMA alignment filter.")
useOteInput   = input.bool(false, "5. Require OTE (Discount/Premium)", group = GRP_FILTERS,
     tooltip = "Only create a zone if its midpoint sits in the discount (bull) / premium (bear) half of the leg.")

// — Confluence & quality (Viprasol)
minScoreInput      = input.int(0, "Minimum Confluence Score (0-4)", minval = 0, maxval = 4, group = GRP_QUALITY,
     tooltip = "Each zone scores 1 point per confluence met (sweep, FVG, OTE, HTF). Zones below this score are not drawn. 0 = draw all.")
showGradeInput     = input.bool(true, "Show Quality Grade on Zone", group = GRP_QUALITY,
     tooltip = "Label each zone A (>=3) / B (2) / C (<=1) based on its confluence score.")
zoneCooldownInput  = input.int(0, "Zone Cooldown (bars)", minval = 0, maxval = 200, group = GRP_QUALITY,
     tooltip = "Minimum bars between new zones on the same side. Prevents clustering. 0 = disabled.")

// — Risk overlay (Viprasol)
showLevelsInput      = input.bool(true, "Show SL/TP on Mitigation", group = GRP_RISK,
     tooltip = "When price returns to (mitigates) a zone, project Entry / SL / TP lines from it.")
showPriceLabelsInput = input.bool(true, "Show Price Labels (TP/Entry/SL)", group = GRP_RISK, active = showLevelsInput,
     tooltip = "Draw colored price tags at the end of the Entry / SL / TP projection lines.")
rrRatioInput         = input.float(2.0, "Risk : Reward", minval = 0.5, maxval = 10.0, step = 0.1, group = GRP_RISK, active = showLevelsInput,
     tooltip = "Take-profit distance as a multiple of the zone height (the risk).")

// — Visuals
bullFillInput   = input.color(color.new(BULL_SIGNATURE, 85), "Bullish Fill", group = GRP_VISUAL)
bullBorderInput = input.color(BULL_SIGNATURE, "Bullish Border", group = GRP_VISUAL)
bearFillInput   = input.color(color.new(BEAR_SIGNATURE, 85), "Bearish Fill", group = GRP_VISUAL)
bearBorderInput = input.color(BEAR_SIGNATURE, "Bearish Border", group = GRP_VISUAL)
dimInvalidInput = input.bool(true, "Dim Invalidated Zones", group = GRP_VISUAL,
     tooltip = "Recolor a zone gray once price closes through it (invalidation), instead of deleting it.")

// — Dashboard
showTableInput = input.bool(true, "Show Info Dashboard", group = GRP_DASH)
dashPosInput   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH)

// ══════════════════════════════════════════════════════════════
// User-Defined Type — Flip Zone  [v6 feature]
// ══════════════════════════════════════════════════════════════

type FlipZone
    box   bx
    label lbl
    float top
    float bot
    bool  isBull
    int   score
    bool  mitigated
    bool  invalid
    int   bornBar

// ══════════════════════════════════════════════════════════════
// Functions
// ══════════════════════════════════════════════════════════════

gradeOf(int score) =>
    score >= 3 ? "A" : score == 2 ? "B" : "C"

// ══════════════════════════════════════════════════════════════
// Calculations — Structure & HTF
// ══════════════════════════════════════════════════════════════

float localHigh = ta.highest(high, lookbackInput)
float localLow  = ta.lowest(low, lookbackInput)

float htfEma     = nz(request.security(syminfo.tickerid, htfResInput, ta.ema(close, 50), lookahead = barmerge.lookahead_off), close)
bool  htfBullRaw = close > htfEma
bool  htfBearRaw = close < htfEma
bool  htfBullOk  = not useHtfInput or htfBullRaw
bool  htfBearOk  = not useHtfInput or htfBearRaw

// State
var array<FlipZone> bullZones = array.new<FlipZone>()
var array<FlipZone> bearZones = array.new<FlipZone>()
var int lastBullBar = -100000
var int lastBearBar = -100000

// Per-bar alert flags
bool newBullZone   = false
bool newBearZone   = false
bool bullMitigated = false
bool bearMitigated = false
bool zoneInvalid   = false

// Risk overlay drawings (latest only)
var line  enLine = na
var line  slLine = na
var line  tpLine = na
var label enLbl  = na
var label slLbl  = na
var label tpLbl  = na

// ══════════════════════════════════════════════════════════════
// Mitigation & invalidation of EXISTING zones  [new — Viprasol]
// (processed before new-zone creation so a fresh zone is not self-mitigated)
// ══════════════════════════════════════════════════════════════

// Combined pass over both sides (inline — Pine functions cannot reassign globals)
for z in array.concat(array.copy(bullZones), bearZones)
    if not z.invalid
        // Mitigation: price re-enters the zone for the first time
        if not z.mitigated and low <= z.top and high >= z.bot
            z.mitigated := true
            if z.isBull
                bullMitigated := true
            else
                bearMitigated := true
            if showLevelsInput
                float entry = z.isBull ? z.top : z.bot
                float sl    = z.isBull ? z.bot : z.top
                float risk  = z.top - z.bot
                float tp    = z.isBull ? entry + risk * rrRatioInput : entry - risk * rrRatioInput
                int x2 = bar_index + 12
                line.delete(enLine)
                line.delete(slLine)
                line.delete(tpLine)
                label.delete(enLbl)
                label.delete(slLbl)
                label.delete(tpLbl)
                enLine := line.new(bar_index, entry, x2, entry, color = color.new(ENTRY_LABEL_COL, 10), width = 1)
                slLine := line.new(bar_index, sl,    x2, sl,    color = color.new(SL_LABEL_COL, 10), width = 1, style = line.style_dashed)
                tpLine := line.new(bar_index, tp,    x2, tp,    color = color.new(TP_LABEL_COL, 10), width = 1, style = line.style_dashed)
                if showPriceLabelsInput
                    enLbl := label.new(x2, entry, "ENTRY " + str.tostring(entry, format.mintick), style = label.style_label_left, color = ENTRY_LABEL_COL, textcolor = color.white, size = size.small)
                    slLbl := label.new(x2, sl,    "SL "    + str.tostring(sl,    format.mintick), style = label.style_label_left, color = SL_LABEL_COL,    textcolor = color.white, size = size.small)
                    tpLbl := label.new(x2, tp,    "TP "    + str.tostring(tp,    format.mintick), style = label.style_label_left, color = TP_LABEL_COL,    textcolor = color.white, size = size.small)
        // Invalidation: price closes through the zone
        bool broke = z.isBull ? close < z.bot : close > z.top
        if broke
            z.invalid := true
            zoneInvalid := true
            if dimInvalidInput
                box.set_bgcolor(z.bx, color.new(INVALID_GRAY, 88))
                box.set_border_color(z.bx, color.new(INVALID_GRAY, 40))

// ══════════════════════════════════════════════════════════════
// Bullish Flip Zone  [original logic + confluence scoring]
// ══════════════════════════════════════════════════════════════

bool supplyBroken = ta.crossover(close, localHigh[1])

if supplyBroken
    // Locate the trap / reaction leg before the breakout  [from original]
    float flipLow  = low
    float flipHigh = high
    for i = 1 to reactionLengthInput
        if low[i] < flipLow
            flipLow  := low[i]
            flipHigh := high[i]

    // Confluence conditions (raw — independent of toggles)  [new scoring]
    float prevStructLow = ta.lowest(low, lookbackInput)[reactionLengthInput + 1]
    bool  sweptRaw = flipLow < prevStructLow
    bool  fvgRaw   = low > high[2] or low[1] > high[3]
    float legHigh  = high
    float equilib  = flipLow + (legHigh - flipLow) * 0.5
    float flipMid  = (flipHigh + flipLow) / 2
    bool  oteRaw   = flipMid <= equilib

    int score = (sweptRaw ? 1 : 0) + (fvgRaw ? 1 : 0) + (oteRaw ? 1 : 0) + (htfBullRaw ? 1 : 0)

    // Original gating (toggle-respecting) + new quality/cooldown gates
    bool passFilters = (not useSweepInput or sweptRaw) and (not useFvgInput or fvgRaw) and (not useOteInput or oteRaw) and htfBullOk
    bool passQuality = score >= minScoreInput
    bool passCool    = zoneCooldownInput == 0 or (bar_index - lastBullBar) >= zoneCooldownInput

    if passFilters and passQuality and passCool
        bool filtered = useFvgInput or useOteInput or useSweepInput or useHtfInput
        string zoneTxt = (filtered ? "Bull Flip (Filtered)" : "Bull Flip") + (showGradeInput ? "  [" + gradeOf(score) + " " + str.tostring(score) + "/4]" : "")
        box bx = box.new(bar_index - reactionLengthInput, flipHigh, bar_index + 15, flipLow,
             bgcolor = bullFillInput, border_color = bullBorderInput, border_width = 2,
             text = zoneTxt, text_color = bullBorderInput, text_size = size.small, text_valign = text.align_bottom)
        FlipZone z = FlipZone.new(bx, na, flipHigh, flipLow, true, score, false, false, bar_index)
        array.push(bullZones, z)
        lastBullBar := bar_index
        newBullZone := true

// ══════════════════════════════════════════════════════════════
// Bearish Flip Zone  [original logic + confluence scoring]
// ══════════════════════════════════════════════════════════════

bool demandBroken = ta.crossunder(close, localLow[1])

if demandBroken
    float flipHigh = high
    float flipLow  = low
    for i = 1 to reactionLengthInput
        if high[i] > flipHigh
            flipHigh := high[i]
            flipLow  := low[i]

    float prevStructHigh = ta.highest(high, lookbackInput)[reactionLengthInput + 1]
    bool  sweptRaw = flipHigh > prevStructHigh
    bool  fvgRaw   = high < low[2] or high[1] < low[3]
    float legLow   = low
    float equilib  = flipHigh - (flipHigh - legLow) * 0.5
    float flipMid  = (flipHigh + flipLow) / 2
    bool  oteRaw   = flipMid >= equilib

    int score = (sweptRaw ? 1 : 0) + (fvgRaw ? 1 : 0) + (oteRaw ? 1 : 0) + (htfBearRaw ? 1 : 0)

    bool passFilters = (not useSweepInput or sweptRaw) and (not useFvgInput or fvgRaw) and (not useOteInput or oteRaw) and htfBearOk
    bool passQuality = score >= minScoreInput
    bool passCool    = zoneCooldownInput == 0 or (bar_index - lastBearBar) >= zoneCooldownInput

    if passFilters and passQuality and passCool
        bool filtered = useFvgInput or useOteInput or useSweepInput or useHtfInput
        string zoneTxt = (filtered ? "Bear Flip (Filtered)" : "Bear Flip") + (showGradeInput ? "  [" + gradeOf(score) + " " + str.tostring(score) + "/4]" : "")
        box bx = box.new(bar_index - reactionLengthInput, flipHigh, bar_index + 15, flipLow,
             bgcolor = bearFillInput, border_color = bearBorderInput, border_width = 2,
             text = zoneTxt, text_color = bearBorderInput, text_size = size.small, text_valign = text.align_top)
        FlipZone z = FlipZone.new(bx, na, flipHigh, flipLow, false, score, false, false, bar_index)
        array.push(bearZones, z)
        lastBearBar := bar_index
        newBearZone := true

// ══════════════════════════════════════════════════════════════
// Cleanup — prune oldest zones  [from original, generalised]
// ══════════════════════════════════════════════════════════════

if array.size(bullZones) > maxZonesInput
    FlipZone old = array.shift(bullZones)
    box.delete(old.bx)
if array.size(bearZones) > maxZonesInput
    FlipZone old = array.shift(bearZones)
    box.delete(old.bx)

// ══════════════════════════════════════════════════════════════
// Dashboard — active-zone counts & state
// ══════════════════════════════════════════════════════════════

countActive(array<FlipZone> zones) =>
    int c = 0
    for z in zones
        if not z.invalid
            c += 1
    c

dashPos = switch dashPosInput
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table tbl = table.new(dashPos, 2, 7, bgcolor = PANEL_BG, border_color = PANEL_BORDER, border_width = 1, frame_color = PANEL_BORDER, frame_width = 1)

if barstate.islast and showTableInput
    int activeBull = countActive(bullZones)
    int activeBear = countActive(bearZones)
    string htfState = useHtfInput ? (htfBullRaw ? "▲ Bull" : "▼ Bear") : "Off"

    table.cell(tbl, 0, 0, "VP — SMC Flip Zones", text_color = PANEL_TEXT, text_size = size.small, bgcolor = PANEL_HEADER)
    table.cell(tbl, 1, 0, "● Live", text_color = BULL_SIGNATURE, text_size = size.small, bgcolor = PANEL_HEADER)

    table.cell(tbl, 0, 1, "Active Bull Zones", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 1, str.tostring(activeBull), text_color = bullBorderInput, text_size = size.small)

    table.cell(tbl, 0, 2, "Active Bear Zones", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 2, str.tostring(activeBear), text_color = bearBorderInput, text_size = size.small)

    table.cell(tbl, 0, 3, "HTF (50 EMA)", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 3, htfState, text_color = useHtfInput ? (htfBullRaw ? bullBorderInput : bearBorderInput) : PANEL_MUTED, text_size = size.small)

    table.cell(tbl, 0, 4, "Min Score", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 4, str.tostring(minScoreInput) + "/4", text_color = PANEL_MUTED, text_size = size.small)

    int filterCount = (useSweepInput ? 1 : 0) + (useFvgInput ? 1 : 0) + (useOteInput ? 1 : 0) + (useHtfInput ? 1 : 0)
    table.cell(tbl, 0, 5, "Filters On", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 5, str.tostring(filterCount) + "/4", text_color = filterCount > 0 ? BULL_SIGNATURE : PANEL_MUTED, text_size = size.small)

    table.cell(tbl, 0, 6, "Grade", text_color = PANEL_MUTED, text_size = size.tiny)
    table.cell(tbl, 1, 6, "A>=3 B=2 C<=1", text_color = PANEL_MUTED, text_size = size.tiny)

// ══════════════════════════════════════════════════════════════
// Alerts — dynamic messages with {{ticker}} {{close}} {{interval}}
// ══════════════════════════════════════════════════════════════

alertcondition(newBullZone, "VP SMCFZ New Bull Zone", "[Viprasol] SMC Flip Zone: new BULLISH flip zone on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(newBearZone, "VP SMCFZ New Bear Zone", "[Viprasol] SMC Flip Zone: new BEARISH flip zone on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(newBullZone or newBearZone, "VP SMCFZ Any New Zone", "[Viprasol] SMC Flip Zone: new flip zone on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(bullMitigated, "VP SMCFZ Bull Mitigation", "[Viprasol] SMC Flip Zone: price returned to a BULLISH zone (potential long) on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(bearMitigated, "VP SMCFZ Bear Mitigation", "[Viprasol] SMC Flip Zone: price returned to a BEARISH zone (potential short) on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(zoneInvalid, "VP SMCFZ Zone Invalidated", "[Viprasol] SMC Flip Zone: a flip zone was invalidated on {{ticker}} ({{interval}}) at {{close}}")
````
