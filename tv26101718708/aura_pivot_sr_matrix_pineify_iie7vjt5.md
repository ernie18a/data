# Aura Pivot S/R Matrix [Pineify]

- url: https://www.tradingview.com/script/IiE7vJT5-Aura-Pivot-S-R-Matrix-Pineify/
- type: indicator
- pine_id: PUB;548bb5500d52410b9aca9fc017464386
- version: 1.0

## Description

[b]Aura Pivot S/R Matrix [Pineify][/b]

This indicator turns confirmed swing pivots into volatility-adaptive support and resistance zones rather than single horizontal lines. The thickness of each zone is derived from a 200-bar ATR snapshot taken at the pivot bar itself — so a level formed during a quiet consolidation gets a narrower zone than one formed during a wide-range expansion, without any manual tuning per instrument. Each zone tracks forward with price until a full close breaks through it, at which point the zone is frozen and labeled as a breakout or breakdown.

[b]Key Features[/b]

[list]
[*]ATR-scaled zone thickness anchored to the volatility regime at the pivot bar, not the current bar

[*]Forward-extending zones that visually "track" price until broken, then freeze as a historical record

[*]Close-based break detection that filters out wick probes and test-and-reject candles

[*]Per-zone state management via a user-defined type — each zone behaves as an independent object with its own lifecycle

[*]Breakout and breakdown labels printed at the exact bar of confirmation
[/list]

[b]How It Works[/b]

Each zone is built through a three-stage pipeline — pivot confirmation, volatility-scaled construction, and lifecycle tracking.

[list=1]
[*]A swing is detected when a bar's high is higher than the surrounding [i]pivotLen[/i] bars on both sides (for resistance), or the low is lower (for support). Because the right-side requires N bars of confirmation, zones appear with a deterministic [i]pivotLen[/i]-bar lag and do not repaint once drawn

[*]At the moment a pivot confirms, the script measures the 200-bar ATR as it existed [i]pivotLen[/i] bars ago — that is the volatility context at the actual swing bar, not the current bar. The zone is then drawn as a box extending ±(ATR/2) around the pivot price

[*]Each zone is stored in an SRZone user-defined type that bundles its box, midline, label, pivot level, and a boolean broken flag. Two arrays — one for resistance, one for support — hold the active inventory

[*]On every bar, unbroken zones have their right edge extended forward. When the close exceeds the top of a resistance zone (or falls below the bottom of a support zone), the zone stops extending, is marked broken, and a labeled marker is drawn at the break bar
[/list]

[b]How the Components Work Together[/b]

Three design decisions interact to produce the final behavior.

The pivot detection answers [i]where[/i] market structure previously turned — these are locations where orders likely clustered and will likely cluster again on retest. The ATR scaling answers [i]how wide[/i] the reaction range around that pivot should be, because a pivot formed during a low-volatility session does not represent the same defensive range as one formed during a volatile expansion. Combining the two produces zones that are structurally anchored but volatility-proportional.

The close-based break filter then handles the noise problem. The most common false break is a wick that tags the level, prints a panic candle, and reverses immediately. By requiring a full close beyond the zone, the indicator rewards conviction moves and ignores exploratory probes — the break is registered only when price has [i]committed[/i] to the new regime.

[b]Trading Ideas and Insights[/b]

[list]
[*]Repeated tests of a fresh resistance zone without a closing break frequently precede a sustained reversal. The more times a zone is defended, the more meaningful the eventual breakout becomes

[*]When a resistance zone breaks and then holds as support on retest, that flip is a classic structural shift — an opportunity to align with the new direction using the flipped zone as a clear invalidation level

[*]Support zones broken during strong trending conditions rarely hold on retest. Support broken during ranging conditions often reforms because the market was simply oscillating — context from the broader trend matters

[*]A cluster of multiple pivots at similar prices (three or four zones stacking) marks a confluence area that carries more weight than an isolated swing
[/list]

Past behavior at these levels does not guarantee future reactions. Treat zones as bias filters rather than standalone signal generators.

[b]Unique Aspects[/b]

[list]
[*]Most S/R indicators use fixed-distance zones, round numbers, or percentage bands. This one scales zone thickness to a rolling ATR measured at the exact bar of the pivot — so a 2020 level and a 2024 level on the same chart can have very different zone widths depending on the volatility regime that produced them

[*]Zones freeze on break rather than being deleted, preserving a visual history of which structural levels have been tested and lost. This acts as a passive context map for traders reading price action

[*]State is managed through a UDT array rather than a flat set of lines, which makes the extend-until-broken behavior clean and predictable — each zone owns its own break detection logic
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to any chart and timeframe you actively trade. 1H and 4H are good starting points for swing traders; lower timeframes work but will produce more zones and benefit from a higher pivot lookback value

[*]Identify the nearest active support zone (green) and resistance zone (red) — these are the first levels price is likely to react to

[*]Watch for one of two outcomes: a controlled approach followed by rejection (fade setup), or a decisive close through the zone (breakout setup). The indicator labels the breakout or breakdown automatically

[*]When a level breaks, expect a retest. Retests often offer better reward-to-risk entries than chasing the initial breakout bar itself
[/list]

[b]Customization[/b]

[list]
[*][b]Pivot Lookback Length[/b] (default: 15) — Bars required on each side of a swing for confirmation. Lower values (5-10) produce smaller, more frequent zones suitable for scalping. Higher values (20-30) isolate only major structural swings and reduce chart clutter

[*][b]Zone Width (ATR Multiplier)[/b] (default: 1.0) — Scales the ATR-derived zone thickness. Raise to 1.5-2.0 on volatile instruments where zones should absorb normal noise; lower to 0.5 for tighter precision-entry levels

[*][b]Support / Resistance Color[/b] — Visual differentiation between bullish and bearish zones, their midlines, and labels

[*][b]Zone Transparency[/b] (default: 85) — Controls the fill opacity of zone boxes. Values around 80-90 keep price action readable inside the zone
[/list]

[b]Limitations to Be Aware Of[/b]

[list]
[*]The pivot confirmation delay equals the lookback length. A 15-bar lookback means the zone is drawn 15 bars after the actual swing high or low. This is fine for levels (they do not repaint) but unsuitable for entries at the exact swing bar

[*]Zones do not automatically merge. When multiple pivots form within an ATR of each other, their zones will overlap on the chart. Increasing the pivot lookback reduces this visual clutter

[*]Break detection uses [i]close[/i], not wicks. A bar can spike well beyond the zone and return inside without triggering a break — by design, but worth remembering on volatile instruments with large intrabar swings
[/list]

[b]Conclusion[/b]

Rather than plotting dozens of static lines, the Aura Pivot S/R Matrix treats each structural pivot as a live object with a volatility-scaled range and a clear lifecycle — active, then broken. The ATR scaling grounds each zone in the volatility context of its own formation, and the close-based break detection emphasizes conviction moves over noise. Most useful as a structural framework for swing and position traders who want to see where the market has been defended, where those defenses have been lost, and how the battleground has evolved across different volatility regimes.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//======================================================================//
//                    ____  _            _  __                          //
//                   |  _ \(_)_ __   ___(_)/ _|_   _                    //
//                   | |_) | | '_ \ / _ \ | |_| | | |                   //
//                   |  __/| | | | |  __/ |  _| |_| |                   //
//                   |_|   |_|_| |_|\___|_|_|  \__, |                   //
//                                             |___/                    //
//======================================================================//
//
// Aura Pivot S/R Matrix
// ----------------------
// Turns confirmed swing pivots into volatility-adaptive support and
// resistance zones. Zone thickness is scaled by a 200-bar ATR snapshot
// taken at the pivot bar, so each level's reaction range matches the
// volatility regime that produced it — no per-instrument tuning needed.
//
// Zone lifecycle:
//   1. Confirmation — a pivot resolves after `pivotLen` bars of right-side validation
//   2. Active tracking — the zone's right edge advances forward with every bar
//   3. Break — a full close beyond the zone freezes it and prints a breakout/breakdown label
//

//@version=6
indicator("Aura Pivot S/R Matrix [Pineify]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
GREEN = #089981
RED   = #F23645

grp_struct = "Structure Detection"
grp_style  = "Aesthetics & Colors"

pivotLen  = input.int(15, "Pivot Lookback Length", minval=3, group=grp_struct, tooltip="Bars required on each side of a swing for confirmation. Lower values (5-10) detect small, frequent swings suited to scalping. Higher values (20-30) isolate only major structural pivots and reduce chart clutter.")
zoneWidth = input.float(1.0, "Zone Width (ATR Multiplier)", minval=0.1, step=0.1, group=grp_struct, tooltip="Multiplies the 200-bar ATR to set each zone's vertical thickness. Raise (1.5-2.0) on volatile instruments where zones should absorb normal noise; lower (0.5) for tighter precision levels.")

bullColor = input.color(GREEN, "Support Color", group=grp_style, tooltip="Color for support zones, their midlines, and breakdown labels.")
bearColor = input.color(RED, "Resistance Color", group=grp_style, tooltip="Color for resistance zones, their midlines, and breakout labels.")
bgTransp  = input.int(85, "Zone Transparency", minval=0, maxval=100, group=grp_style, tooltip="Transparency of the zone fill. 0 is fully opaque, 100 invisible. Values around 80-90 keep price action readable inside the zone.")

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{
// A long ATR lookback produces a stable volatility baseline. Scaling zone width by this
// ATR makes each zone represent a proportional "reaction range" rather than a fixed price distance.
atr = ta.atr(200) * zoneWidth

// Standard two-sided pivot detection. Because both sides require `pivotLen` bars of confirmation,
// each pivot (and its zone) resolves with a deterministic `pivotLen`-bar lag and never repaints.
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

//---------------------------------------------------------------------------------------------------------------------}
// USER DEFINED TYPES
//---------------------------------------------------------------------------------------------------------------------{
// Bundling each zone's visual elements together with its state flag makes zones first-class
// objects. Each one owns its own extension and break-detection logic, stored in the arrays below.
type SRZone
    box   area
    line  avg
    label tag
    float level
    bool  isBroken

var array<SRZone> resZones = array.new<SRZone>()
var array<SRZone> supZones = array.new<SRZone>()

//---------------------------------------------------------------------------------------------------------------------}
// ZONE RENDERING
//---------------------------------------------------------------------------------------------------------------------{
// When a resistance pivot confirms, build the zone using the ATR from `pivotLen` bars ago —
// the volatility context at the actual swing bar, not the current bar. This anchors the zone
// to the market conditions that created it, which matters across volatility regime changes.
if not na(ph)
    float top = ph + (atr[pivotLen] / 2)
    float btm = ph - (atr[pivotLen] / 2)

    b   = box.new(bar_index[pivotLen], top, bar_index, btm, bgcolor=color.new(bearColor, bgTransp), border_color=color(na))
    l   = line.new(bar_index[pivotLen], ph, bar_index, ph, color=bearColor, style=line.style_dashed)
    lbl = label.new(bar_index[pivotLen], top, "Resistance", color=color(na), textcolor=bearColor, style=label.style_label_down, size=size.tiny)

    resZones.push(SRZone.new(b, l, lbl, ph, false))

// Mirror construction for support pivots — same volatility-anchored sizing on the opposite side of price
if not na(pl)
    float top = pl + (atr[pivotLen] / 2)
    float btm = pl - (atr[pivotLen] / 2)

    b   = box.new(bar_index[pivotLen], top, bar_index, btm, bgcolor=color.new(bullColor, bgTransp), border_color=color(na))
    l   = line.new(bar_index[pivotLen], pl, bar_index, pl, color=bullColor, style=line.style_dashed)
    lbl = label.new(bar_index[pivotLen], btm, "Support", color=color(na), textcolor=bullColor, style=label.style_label_up, size=size.tiny)

    supZones.push(SRZone.new(b, l, lbl, pl, false))

//---------------------------------------------------------------------------------------------------------------------}
// EXTENSION & BREAK DETECTION
//---------------------------------------------------------------------------------------------------------------------{
// Active resistance zones advance their right edge each bar so they visually "track" price.
// Break requires a full close ABOVE the zone top — wick probes don't flip state, filtering
// out the common test-and-reject pattern where price tags a level and reverses immediately.
if resZones.size() > 0
    for i = resZones.size() - 1 to 0
        SRZone z = resZones.get(i)
        if not z.isBroken
            z.area.set_right(bar_index)
            z.avg.set_x2(bar_index)

            if close > z.area.get_top()
                z.isBroken := true
                label.new(bar_index, high, "Breakout", color=bullColor, textcolor=color.white, style=label.style_label_down, size=size.tiny)

// Symmetric behavior for support: a full close BELOW the zone bottom confirms a breakdown
if supZones.size() > 0
    for i = supZones.size() - 1 to 0
        SRZone z = supZones.get(i)
        if not z.isBroken
            z.area.set_right(bar_index)
            z.avg.set_x2(bar_index)

            if close < z.area.get_bottom()
                z.isBroken := true
                label.new(bar_index, low, "Breakdown", color=bearColor, textcolor=color.white, style=label.style_label_up, size=size.tiny)
````
