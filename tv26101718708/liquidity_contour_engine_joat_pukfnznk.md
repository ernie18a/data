# Liquidity Contour Engine [JOAT]

- url: https://www.tradingview.com/script/pUkFnZnK-Liquidity-Contour-Engine-JOAT/
- type: indicator
- pine_id: PUB;734f067c8b9b46ea96b896946934b781
- version: 1.0

## Description

[b]Liquidity Contour Engine [JOAT][/b]

[b]Introduction[/b]

Liquidity Contour Engine is an overlay indicator that identifies two distinct institutional price phenomena: liquidity sweeps at swing highs and lows, and order blocks formed before impulsive structural moves. Liquidity sweep zones mark levels where price reached beyond a prior swing, triggering stop orders, then reversed — the classic footprint of a sweep-and-reversal sequence. Order block zones mark the last opposing candle before a significant directional impulse, representing the area where a large position was initiated.

The underlying premise is that institutions build and exit positions through order flow that leaves identifiable marks on the chart. A liquidity sweep is one such mark: price extending beyond a well-established swing level, clearing stops, then reversing. This behavior is not random — it reflects deliberate order accumulation at levels where retail stops cluster. Similarly, order blocks at the origin of impulsive moves may act as re-entry areas when price later returns to them.

[image]https://www.tradingview.com/x/s88vYg74/[/image]

[b]Core Concepts[/b]

[b]1. Confirmed Swing Pivot Detection[/b]

Swings are identified using ta.pivothigh and ta.pivotlow with a configurable lookback. All pivot detections are confirmed — offset by the lookback bars — meaning no repainting occurs. Only when sufficient bars have closed on both sides of a potential pivot is it registered.

[b]2. Liquidity Sweep Detection[/b]

A bullish sweep is confirmed when: price wicks below the most recent swing low by at least a configurable ATR multiple, and the bar closes back above that swing low. This captures the wick-past-and-close-back pattern that characterizes institutional accumulation at liquidity levels. A bearish sweep is the mirror condition at swing highs.

Upon detection, a zone is created at the swept level, rendered as a dual-width line (thin solid + thick transparent shadow). Zones remain active until price sustains a close beyond the swept level by 0.5 ATR, at which point they convert to dotted lines (mitigated state).

[b]3. Order Block Detection[/b]

An order block is identified as the prior N candle(s) before a structural impulse. A bullish impulse is defined as a bar that closes above the most recent swing high. The order block is the last candle body before that impulse, rendered as a filled box from body open to the wick high. Mitigation occurs when price closes beyond the 50% level of the order block body, fading the box to indicate the zone has been traded through.

[b]4. Zone Lifecycle Management[/b]

The indicator uses arrays to track active zones and enforces a maximum count. When the maximum is exceeded, the oldest zone is removed from the chart. This prevents chart clutter while keeping the most recent and relevant zones visible.

[b]Features[/b]

[list]
[*][b]Liquidity Sweep Zones:[/b] Dual-width line rendering at swept swing levels, self-managing lifecycle
[*][b]Order Block Boxes:[/b] Filled zones at order block origin, with mitigation fading
[*][b]Swing Level Dotted Lines:[/b] Current swing high and low extensions as dotted reference lines
[*][b]9-Row Dashboard:[/b] Sweep state, active zone counts, order block counts, last swing levels
[*][b]Configurable ATR Threshold:[/b] Adjusts how far price must reach beyond a swing to qualify as a sweep
[*][b]Max Zone Limit:[/b] Prevents chart clutter with configurable maximum active zone count
[/list]

[b]Input Parameters[/b]

[list]
[*]Swing Lookback: Bars required each side for pivot confirmation (default: 8)
[*]Sweep ATR Threshold: Minimum sweep distance in ATR units (default: 0.3)
[*]Max Active Zones: Maximum concurrently displayed liquidity zones (default: 8)
[*]ATR Period: Period for ATR calculation (default: 14)
[*]Show Order Blocks: Toggle order block rendering
[*]OB Lookback: How many bars back to identify the order block candle (default: 3)
[/list]

[b]How to Use This Indicator[/b]

[b]Sweep-and-Reverse Setups[/b]
When a bullish sweep fires (price wicked below a swing low and closed back above), the zone represents the level where stops were taken. If price subsequently builds structure above that zone and delta pressure is positive, the setup is a potential long entry with the swept level as reference for the stop.

[b]Order Block Re-Tests[/b]
When price returns to a bullish order block zone (shown in teal), it is revisiting the area where an institutional position was likely initiated. If the zone has not been mitigated (box remains filled), a reaction from that zone is plausible. A mitigated order block (faded) is a less reliable reference.

[image]https://www.tradingview.com/x/mUX1aTmc/[/image]

[b]Zone Confluence[/b]
When a liquidity sweep zone and an order block coincide at the same price level, the confluence represents a stronger structural reference than either zone alone.

[b]Limitations[/b]

[list]
[*]Swing pivot confirmation introduces a bar lag equal to the lookback period. Sweeps and order blocks are identified after the fact, not in the moment they form
[*]Not every liquidity sweep produces a reversal. Price can continue through a swept level without reversing
[*]Order block identification is mechanical and cannot account for all institutional order placement strategies
[*]On higher timeframes, zones cover wider price ranges and may require adjustment of the ATR threshold
[/list]

[b]Originality Statement[/b]

The unified framework for tracking liquidity sweeps and order blocks within a single indicator with a shared zone lifecycle management system is the original design contribution. Zone mitigation logic that converts active zones to passive reference lines (rather than deleting them) preserves structural context while visually indicating that a zone's primary relevance has passed. The dual-width shadow line rendering for sweep zones provides depth that distinguishes them clearly from standard horizontal lines.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. Liquidity sweep detection describes a pattern in historical price data. Past occurrences of this pattern do not guarantee future reactions. Order blocks are hypothetical areas of interest, not confirmed institutional levels. Always use proper risk management.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Liquidity Contour Engine [JOAT]", shorttitle="LCE [JOAT]", overlay=true,
         max_lines_count=400, max_boxes_count=300, max_labels_count=100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp_lq  = "Liquidity Settings"
i_piv   = input.int(8,  "Swing Lookback",      minval=3, maxval=25, group=grp_lq)
i_sweep = input.float(0.3, "Sweep ATR Threshold", minval=0.1, maxval=2.0, step=0.1, group=grp_lq,
          tooltip="How far beyond a swing (in ATR) qualifies as a liquidity sweep")
i_max_z = input.int(8,  "Max Active Zones",    minval=2, maxval=15, group=grp_lq)
i_atr   = input.int(14, "ATR Period",          minval=5, maxval=30, group=grp_lq)

grp_ob  = "Order Block Detection"
i_ob    = input.bool(true, "Show Order Blocks",         group=grp_ob)
i_ob_len= input.int(3, "OB Lookback (impulse bars)",   minval=2, maxval=10, group=grp_ob)

grp_v   = "Visual Settings"
i_dash  = input.bool(true, "Show Dashboard", group=grp_v)
i_bull  = input.color(#00bfa5, "Bullish Zone Color", group=grp_v)
i_bear  = input.color(#ef5350, "Bearish Zone Color", group=grp_v)
i_ob_bc = input.color(#ffd54f, "Order Block Color",  group=grp_v)
i_lbl   = input.bool(true, "Show Labels", group=grp_v)
i_fs    = input.string("Tiny", "Label Size", options=["Tiny","Small"], group=grp_v)

// ─────────────────────────────────────────────────────────────────────────────
// TYPES
// ─────────────────────────────────────────────────────────────────────────────
type LiqZone
    float level
    bool  isBull
    line  l1
    line  l2
    box   lbl
    bool  active

type OBZone
    float top
    float bot
    bool  isBull
    box   body
    box   lbl
    bool  mitigated

// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────
atr_val = ta.atr(i_atr)
fs_sz   = i_fs == "Tiny" ? size.tiny : size.small

// Confirmed pivots (non-repainting)
ph = ta.pivothigh(high, i_piv, i_piv)
pl = ta.pivotlow (low,  i_piv, i_piv)

var float last_ph = na
var float last_pl = na
var int   ph_bar  = na
var int   pl_bar  = na
var float prev_ph = na
var float prev_pl = na

if not na(ph)
    prev_ph := last_ph
    last_ph := ph
    ph_bar  := bar_index[i_piv]

if not na(pl)
    prev_pl := last_pl
    last_pl := pl
    pl_bar  := bar_index[i_piv]

// ─────────────────────────────────────────────────────────────────────────────
// LIQUIDITY SWEEP DETECTION
// A sweep = price wick reaches beyond prior swing by at least sweep_threshold ATR
// then CLOSES back on the other side (reversal confirmation)
// ─────────────────────────────────────────────────────────────────────────────
var array<LiqZone> zones = array.new<LiqZone>()

// Bullish sweep (below last_pl then closes above)
bull_sweep = barstate.isconfirmed and not na(last_pl) and
             low  < last_pl - (atr_val * i_sweep) and close > last_pl

// Bearish sweep (above last_ph then closes below)
bear_sweep = barstate.isconfirmed and not na(last_ph) and
             high > last_ph + (atr_val * i_sweep) and close < last_ph

// Create zone on sweep detection
if bull_sweep
    z = LiqZone.new(level=last_pl, isBull=true, active=true,
                    l1 = line.new(pl_bar, last_pl, bar_index, last_pl,
                                  color=i_bull, width=1, style=line.style_dashed),
                    l2 = line.new(pl_bar, last_pl, bar_index, last_pl,
                                  color=color.new(i_bull, 65), width=6),
                    lbl = i_lbl ? box.new(pl_bar, last_pl, bar_index, last_pl,
                                          text="LQS", text_size=fs_sz,
                                          text_color=i_bull,
                                          text_halign=text.align_center,
                                          text_valign=text.align_bottom,
                                          bgcolor=color.new(color.black,100),
                                          border_color=color.new(color.black,100)) : box.new(0,0,0,0))
    zones.push(z)

if bear_sweep
    z = LiqZone.new(level=last_ph, isBull=false, active=true,
                    l1 = line.new(ph_bar, last_ph, bar_index, last_ph,
                                  color=i_bear, width=1, style=line.style_dashed),
                    l2 = line.new(ph_bar, last_ph, bar_index, last_ph,
                                  color=color.new(i_bear, 65), width=6),
                    lbl = i_lbl ? box.new(ph_bar, last_ph, bar_index, last_ph,
                                          text="LQS", text_size=fs_sz,
                                          text_color=i_bear,
                                          text_halign=text.align_center,
                                          text_valign=text.align_top,
                                          bgcolor=color.new(color.black,100),
                                          border_color=color.new(color.black,100)) : box.new(0,0,0,0))
    zones.push(z)

// Manage active zones
if zones.size() > 0
    for i = zones.size() - 1 to 0
        z = zones.get(i)
        if z.active
            // Extend zone lines
            z.l1.set_x2(bar_index)
            z.l2.set_x2(bar_index)
            z.lbl.set_right(bar_index)
            // Check for zone violation (sustained break)
            violated = z.isBull ? close < z.level - atr_val * 0.5 :
                                  close > z.level + atr_val * 0.5
            if violated
                z.active := false
                z.l1.set_style(line.style_dotted)
                z.l2.delete()

// Enforce max zone count
if zones.size() > i_max_z
    expired = zones.shift()
    expired.l1.delete()
    expired.l2.delete()
    expired.lbl.delete()

// ─────────────────────────────────────────────────────────────────────────────
// ORDER BLOCK DETECTION
// OB = last opposite-direction candle before an impulsive structural move
// ─────────────────────────────────────────────────────────────────────────────
var array<OBZone> ob_zones = array.new<OBZone>()

// Impulse detection: close breaks structure significantly
bull_impulse = barstate.isconfirmed and not na(last_ph) and
               close > last_ph and ta.highest(i_ob_len)[1] < last_ph

bear_impulse = barstate.isconfirmed and not na(last_pl) and
               close < last_pl and ta.lowest(i_ob_len)[1]  > last_pl

if i_ob and bull_impulse
    // OB = the last bearish candle before impulse
    ob_hi = high[i_ob_len]
    ob_lo = low[i_ob_len]
    ob_top = math.max(open[i_ob_len], close[i_ob_len])
    ob_bot = math.min(open[i_ob_len], close[i_ob_len])
    ob_zone = OBZone.new(
        top      = ob_hi,
        bot      = ob_bot,
        isBull   = true,
        mitigated= false,
        body     = box.new(bar_index - i_ob_len, ob_hi, bar_index + 30, ob_bot,
                           bgcolor=color.new(i_bull, 82),
                           border_color=color.new(i_bull, 40),
                           border_style=line.style_dashed),
        lbl      = i_lbl ? box.new(bar_index - i_ob_len, ob_hi, bar_index + 30, ob_hi,
                                   text="OB", text_size=fs_sz,
                                   text_color=i_bull, text_halign=text.align_left,
                                   text_valign=text.align_bottom,
                                   bgcolor=color.new(color.black,100),
                                   border_color=color.new(color.black,100)) : box.new(0,0,0,0))
    ob_zones.push(ob_zone)

if i_ob and bear_impulse
    ob_hi  = high[i_ob_len]
    ob_top = math.max(open[i_ob_len], close[i_ob_len])
    ob_bot = math.min(open[i_ob_len], close[i_ob_len])
    ob_zone = OBZone.new(
        top      = ob_top,
        bot      = low[i_ob_len],
        isBull   = false,
        mitigated= false,
        body     = box.new(bar_index - i_ob_len, ob_top, bar_index + 30, low[i_ob_len],
                           bgcolor=color.new(i_bear, 82),
                           border_color=color.new(i_bear, 40),
                           border_style=line.style_dashed),
        lbl      = i_lbl ? box.new(bar_index - i_ob_len, ob_top, bar_index + 30, ob_top,
                                   text="OB", text_size=fs_sz,
                                   text_color=i_bear, text_halign=text.align_left,
                                   text_valign=text.align_top,
                                   bgcolor=color.new(color.black,100),
                                   border_color=color.new(color.black,100)) : box.new(0,0,0,0))
    ob_zones.push(ob_zone)

// Manage OB zones
if ob_zones.size() > 0
    for i = ob_zones.size() - 1 to 0
        ob = ob_zones.get(i)
        if not ob.mitigated
            ob.body.set_right(bar_index + 30)
            ob.lbl.set_right(bar_index + 30)
            // Mitigation: price closes inside OB 50%
            mid = (ob.top + ob.bot) / 2
            if ob.isBull and close < mid
                ob.mitigated := true
                ob.body.set_bgcolor(color.new(i_bull, 95))
                ob.body.set_border_color(color.new(i_bull, 80))
            if not ob.isBull and close > mid
                ob.mitigated := true
                ob.body.set_bgcolor(color.new(i_bear, 95))
                ob.body.set_border_color(color.new(i_bear, 80))

if ob_zones.size() > i_max_z
    old_ob = ob_zones.shift()
    old_ob.body.delete()
    old_ob.lbl.delete()

// ─────────────────────────────────────────────────────────────────────────────
// SWING LEVEL VISUALIZATION (dashed extension of recent pivots)
// ─────────────────────────────────────────────────────────────────────────────
var line sv_ph = na
var line sv_pl = na

if not na(ph)
    line.delete(sv_ph)
    sv_ph := line.new(ph_bar, last_ph, bar_index, last_ph,
                      color=color.new(i_bear, 60), width=1, style=line.style_dotted)
if not na(pl)
    line.delete(sv_pl)
    sv_pl := line.new(pl_bar, last_pl, bar_index, last_pl,
                      color=color.new(i_bull, 60), width=1, style=line.style_dotted)

if not na(sv_ph)
    sv_ph.set_x2(bar_index)
if not na(sv_pl)
    sv_pl.set_x2(bar_index)

// ─────────────────────────────────────────────────────────────────────────────
// ZONE COUNTS FOR DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
bull_zones_active = 0
bear_zones_active = 0
for z in zones
    if z.active
        bull_zones_active += z.isBull  ? 1 : 0
        bear_zones_active += not z.isBull ? 1 : 0

ob_bull_count = 0
ob_bear_count = 0
for ob in ob_zones
    if not ob.mitigated
        ob_bull_count += ob.isBull  ? 1 : 0
        ob_bear_count += not ob.isBull ? 1 : 0

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
var table _t = na
if i_dash and barstate.islast
    if na(_t)
        _t := table.new(position.top_right, 3, 9,
                        border_width=1, border_color=color.new(color.gray, 75),
                        frame_width=2,  frame_color=color.new(color.gray, 55))

    C0 = color.new(#0a1628, 0)
    C1 = color.new(#0f2341, 0)
    C2 = color.new(#152d52, 0)

    table.cell(_t, 0, 0, "LIQUIDITY CONTOUR ENGINE", bgcolor=C0,
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 0, 0, 2, 0)

    table.cell(_t, 0, 1, "Last Sweep", bgcolor=C1, text_color=color.gray, text_size=size.small)
    sweep_txt = bull_sweep ? "Bullish" : bear_sweep ? "Bearish" : "None"
    sweep_col = bull_sweep ? i_bull : bear_sweep ? i_bear : color.gray
    table.cell(_t, 1, 1, sweep_txt, bgcolor=C1, text_color=sweep_col, text_size=size.small)
    table.merge_cells(_t, 1, 1, 2, 1)

    table.cell(_t, 0, 2, "Bull LQS Zones", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 2, str.tostring(bull_zones_active),
               bgcolor=bull_zones_active > 0 ? color.new(i_bull, 40) : C2,
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 1, 2, 2, 2)

    table.cell(_t, 0, 3, "Bear LQS Zones", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 3, str.tostring(bear_zones_active),
               bgcolor=bear_zones_active > 0 ? color.new(i_bear, 40) : C1,
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 1, 3, 2, 3)

    table.cell(_t, 0, 4, "Bull OBs", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 4, str.tostring(ob_bull_count),
               bgcolor=ob_bull_count > 0 ? color.new(i_bull, 55) : C2,
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 1, 4, 2, 4)

    table.cell(_t, 0, 5, "Bear OBs", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 5, str.tostring(ob_bear_count),
               bgcolor=ob_bear_count > 0 ? color.new(i_bear, 55) : C1,
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 1, 5, 2, 5)

    table.cell(_t, 0, 6, "Last Swing H", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 6, not na(last_ph) ? str.tostring(last_ph, format.mintick) : "—",
               bgcolor=C2, text_color=i_bear, text_size=size.small)
    table.merge_cells(_t, 1, 6, 2, 6)

    table.cell(_t, 0, 7, "Last Swing L", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 7, not na(last_pl) ? str.tostring(last_pl, format.mintick) : "—",
               bgcolor=C1, text_color=i_bull, text_size=size.small)
    table.merge_cells(_t, 1, 7, 2, 7)

    table.cell(_t, 0, 8, "jackofalltrades", bgcolor=C0,
               text_color=color.new(color.white, 60), text_size=size.tiny)
    table.merge_cells(_t, 0, 8, 2, 8)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(bull_sweep, "LCE — Bullish Sweep", "Bullish Liquidity Sweep detected — {{ticker}}")
alertcondition(bear_sweep, "LCE — Bearish Sweep", "Bearish Liquidity Sweep detected — {{ticker}}")
alertcondition(bull_impulse, "LCE — Bullish Impulse", "Bullish structural impulse — {{ticker}}")
alertcondition(bear_impulse, "LCE — Bearish Impulse", "Bearish structural impulse — {{ticker}}")
````
