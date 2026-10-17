# Meridian Structure Lattice [JOAT]

- url: https://www.tradingview.com/script/S1bBwwBC-Meridian-Structure-Lattice-JOAT/
- type: indicator
- pine_id: PUB;fc6d38af14104434ac9e826c47280cc4
- version: 1.0

## Description

[b]Meridian Structure Lattice [JOAT][/b]

[b]Introduction[/b]

Meridian Structure Lattice is an open-source market structure and zone-mapping overlay designed to visualize how price interacts with prior swing liquidity, displacement, fair value gaps, structural blocks, and supply-demand regions. It focuses on the structural side of chart reading rather than on generic trend-following averages.

The problem this script solves is fragmentation. Traders often need separate tools for BOS detection, sweep identification, imbalance mapping, and supply-demand marking. Meridian Structure Lattice consolidates those ideas into one coordinated structure model so the user can see which event happened, where it happened, and which zones remain active or invalidated afterward.

[image]https://www.tradingview.com/x/DMUAqqEG/[/image]

[b]Core Concepts[/b]

[b]1. Pivot-Based Structure Engine[/b]
Confirmed swing highs and lows are tracked with symmetric pivot logic. Those pivots become the active structural reference points for bullish and bearish breaks, as well as the levels that can later be swept without closing through them.

[b]2. BOS Versus Shift Logic[/b]
When price closes beyond the latest active pivot high or low, the script classifies the event relative to the existing structure bias. Continuation breaks are labeled as BOS, while breaks against the prior bias are labeled as shifts.

[b]3. Liquidity Sweeps[/b]
Sweeps occur when price trades beyond a stored pivot but closes back through it. These are displayed with event lines anchored to the original pivot zone rather than floating labels only.

[b]4. Zone Families[/b]
The script can create and maintain fair value gaps, structural blocks, and ATR-width supply-demand zones. Each zone extends forward, can display a midpoint, can show a live price label on the right edge, and changes state when price mitigates it.

[b]Features[/b]

[list]
[*][b]Pivot-confirmed structure model:[/b] Swing highs and lows drive all event logic
[*][b]Bullish and bearish BOS detection:[/b] Confirmed continuation breaks
[*][b]Bullish and bearish shift detection:[/b] Regime-sensitive structural reversals
[*][b]Liquidity sweep detection:[/b] Wick-through and close-back behavior against stored pivots
[*][b]Fair value gap zones:[/b] Bullish and bearish imbalance regions
[*][b]Structural blocks:[/b] Structure-derived reaction zones that can be upgraded after displacement
[*][b]Supply and demand mapping:[/b] ATR-scaled zones projected forward
[*][b]Zone midlines and price labels:[/b] Optional midpoint and right-edge price tagging
[*][b]Mitigation logic:[/b] Zones can retire on close-through or wick-through behavior
[*][b]Dashboard:[/b] Active zone counts, last event, sweep age, displacement state, and pivot spread
[*][b]Confirmed-bar mode:[/b] Events can be restricted to confirmed candles only
[/list]

[b]Input Parameters[/b]

[b]Structure:[/b]
[list]
[*]Swing Length controls structural sensitivity
[*]BOS, sweep, and label toggles control the event layer
[/list]

[b]Zones And Display:[/b]
[list]
[*]Fair value gap, structural block, and supply-demand toggles
[*]Supply-demand ATR width and maximum active zones per side
[*]Displacement threshold, mitigation mode, confirmed-bar requirement, midline, price label, dashboard, and forward extension settings
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Identify the most recent event in the dashboard to understand whether structure is breaking or only sweeping.
[b]Step 2:[/b] Use BOS and shift labels to determine whether the current break is continuation or reversal behavior.
[b]Step 3:[/b] Use sweeps as failed acceptance signals around prior liquidity.
[b]Step 4:[/b] Use active zones as forward reference areas for mitigation, continuation, or rejection.
[b]Step 5:[/b] Monitor whether a zone remains active or has already been invalidated before treating it as tradeable.

[b]Indicator Limitations[/b]

[list]
[*]Pivot logic confirms after the pivot forms, so structural labels intentionally appear with delay to avoid repainting
[*]Fast moves may skip through multiple nearby zones before the chart can display a clean response
[*]Zone families are analytical references, not guaranteed reversal areas
[*]Dense structure on lower timeframes can still require selective display settings for clarity
[/list]

[b]Originality Statement[/b]

Meridian Structure Lattice is original in the way it coordinates structural events and multiple forward zone families inside a single non-repainting framework. The different components are not merged for convenience alone; they are combined because BOS, shifts, sweeps, blocks, gaps, and supply-demand zones describe different parts of the same structure narrative.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not provide financial advice or guaranteed support and resistance levels. Structural events and zones are derived from historical price behavior and should be used with disciplined risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Meridian Structure Lattice [JOAT]", shorttitle="MSL [JOAT]", overlay=true, max_boxes_count=400, max_lines_count=400, max_labels_count=250)

//==============================================================================
// INPUTS
//==============================================================================
grp_structure = "Structure"
swing_length = input.int(9, "Swing Length", minval=2, group=grp_structure)
show_bos = input.bool(true, "Show Breaks In Structure", group=grp_structure)
show_sweeps = input.bool(true, "Show Liquidity Sweeps", group=grp_structure)
show_structure_labels = input.bool(true, "Show Structure Labels", group=grp_structure)

grp_zones = "Zones"
show_fvg = input.bool(true, "Show Fair Value Gaps", group=grp_zones)
show_blocks = input.bool(true, "Show Structural Blocks", group=grp_zones)
show_supply_demand = input.bool(true, "Show Supply And Demand", group=grp_zones)
zone_width_atr = input.float(1.2, "Supply Demand Width (ATR)", minval=0.2, step=0.1, group=grp_zones)
max_active_zones = input.int(5, "Max Active Zones Per Side", minval=1, maxval=20, group=grp_zones)

grp_filters = "Filters"
displacement_factor = input.float(1.1, "Displacement Threshold (ATR)", minval=0.2, step=0.1, group=grp_filters)
mitigation_on_close = input.bool(true, "Invalidate On Close Through Zone", group=grp_filters)
require_confirmed_bar = input.bool(true, "Only Emit Confirmed Events", group=grp_filters)

grp_visual = "Visuals"
show_midlines = input.bool(true, "Show Zone Midlines", group=grp_visual)
show_zone_prices = input.bool(true, "Show Zone Price Labels", group=grp_visual)
show_dashboard = input.bool(true, "Show Dashboard", group=grp_visual)
extend_bars = input.int(30, "Forward Extension Bars", minval=5, maxval=200, group=grp_visual)

//==============================================================================
// PALETTE
//==============================================================================
panel_bg = color.rgb(11, 17, 24)
panel_cell = color.rgb(17, 25, 35)
panel_header = color.rgb(22, 32, 44)
panel_grid = color.rgb(43, 58, 78)
text_main = color.rgb(227, 233, 242)
text_dim = color.rgb(145, 159, 177)

bull_zone = color.new(color.rgb(0, 196, 146), 84)
bull_zone_strong = color.new(color.rgb(0, 232, 174), 72)
bear_zone = color.new(color.rgb(242, 96, 131), 84)
bear_zone_strong = color.new(color.rgb(255, 130, 153), 72)
fvg_bull = color.new(color.rgb(77, 166, 255), 86)
fvg_bear = color.new(color.rgb(180, 116, 255), 86)
supply_fill = color.new(color.rgb(255, 110, 127), 86)
demand_fill = color.new(color.rgb(0, 176, 128), 86)
neutral_line = color.rgb(127, 145, 166)
accent_gold = color.rgb(226, 183, 78)

//==============================================================================
// TYPES
//==============================================================================
type ZoneRecord
    box region
    line midline
    label tag
    float top
    float bottom
    int dir
    bool active
    bool strong
    int born_bar
    string family

//==============================================================================
// STATE
//==============================================================================
var array<ZoneRecord> bull_zones = array.new<ZoneRecord>()
var array<ZoneRecord> bear_zones = array.new<ZoneRecord>()
var array<line> event_lines = array.new<line>()
var array<label> event_labels = array.new<label>()

var float last_pivot_high = na
var float last_pivot_low = na
var int last_pivot_high_bar = na
var int last_pivot_low_bar = na
var int structure_bias = 0
var string last_event_text = "Idle"
var color last_event_color = text_dim
var int last_sweep_bar = na

atr_value = ta.atr(14)

//==============================================================================
// HELPERS
//==============================================================================
f_prune_events() =>
    while array.size(event_lines) > 40
        line old_line = array.shift(event_lines)
        line.delete(old_line)
    while array.size(event_labels) > 40
        label old_label = array.shift(event_labels)
        label.delete(old_label)

f_add_event(_origin_bar, _price, _text, _is_bull, _style) =>
    color line_col = _is_bull ? color.new(color.rgb(0, 214, 143), 0) : color.new(color.rgb(255, 92, 126), 0)
    line ln = line.new(_origin_bar, _price, bar_index + 1, _price, color=color.new(line_col, 5), width=1, style=_style)
    label lb = na
    if show_structure_labels
        lb := label.new(bar_index + 2, _price, _text + "  " + str.tostring(_price, format.mintick), style=label.style_label_left, color=color.new(line_col, 6), textcolor=color.black, size=size.tiny)
    array.push(event_lines, ln)
    if not na(lb)
        array.push(event_labels, lb)
    f_prune_events()

f_make_zone(_left_bar, _top, _bottom, _dir, _family, _strong) =>
    color fill_col = _family == "FVG" ? (_dir == 1 ? fvg_bull : fvg_bear) : _family == "SD" ? (_dir == 1 ? demand_fill : supply_fill) : (_dir == 1 ? bull_zone : bear_zone)
    if _strong
        fill_col := _dir == 1 ? bull_zone_strong : bear_zone_strong
    color border_col = color.new(fill_col, 0)
    string zone_text = _family == "FVG" ? (_dir == 1 ? "BULL FVG" : "BEAR FVG") : _family == "SD" ? (_dir == 1 ? "DEMAND" : "SUPPLY") : (_dir == 1 ? "BULL BLOCK" : "BEAR BLOCK")
    box bx = box.new(_left_bar, _top, bar_index + extend_bars, _bottom, bgcolor=fill_col, border_color=border_col, border_width=1, text="", text_color=text_main, text_size=size.tiny, text_halign=text.align_right)
    line md = na
    if show_midlines
        float midpoint = (_top + _bottom) * 0.5
        md := line.new(_left_bar, midpoint, bar_index + extend_bars, midpoint, color=color.new(border_col, 15), width=1, style=line.style_dotted)
    label tg = show_zone_prices ? label.new(bar_index + extend_bars + 1, (_top + _bottom) * 0.5, zone_text + "  " + str.tostring((_top + _bottom) * 0.5, format.mintick), style=label.style_label_left, color=color.new(border_col, 5), textcolor=text_main, size=size.tiny) : na
    ZoneRecord.new(bx, md, tg, _top, _bottom, _dir, true, _strong, bar_index, _family)

f_push_zone(_zones, _zone) =>
    array.push(_zones, _zone)
    while array.size(_zones) > max_active_zones
        ZoneRecord old_zone = array.shift(_zones)
        box.delete(old_zone.region)
        if not na(old_zone.midline)
            line.delete(old_zone.midline)
        if not na(old_zone.tag)
            label.delete(old_zone.tag)

f_refresh_zones(_zones, _dir) =>
    if array.size(_zones) > 0
        for i = array.size(_zones) - 1 to 0
            ZoneRecord zone = array.get(_zones, i)
            if zone.active
                box.set_right(zone.region, bar_index + extend_bars)
                if not na(zone.midline)
                    line.set_x2(zone.midline, bar_index + extend_bars)
                if not na(zone.tag)
                    float label_price = zone.dir == 1 ? zone.bottom : zone.top
                    string zone_text = zone.family == "FVG" ? (zone.dir == 1 ? "BULL FVG" : "BEAR FVG") : zone.family == "SD" ? (zone.dir == 1 ? "DEMAND" : "SUPPLY") : (zone.dir == 1 ? "BULL BLOCK" : "BEAR BLOCK")
                    label.set_x(zone.tag, bar_index + extend_bars + 1)
                    label.set_y(zone.tag, label_price)
                    label.set_text(zone.tag, zone_text + "  " + str.tostring(label_price, format.mintick))
                bool invalidate = false
                if mitigation_on_close
                    invalidate := _dir == 1 ? close < zone.bottom : close > zone.top
                else
                    invalidate := _dir == 1 ? low < zone.bottom : high > zone.top
                if invalidate and bar_index > zone.born_bar
                    zone.active := false
                    box.set_right(zone.region, bar_index)
                    color retired_col = zone.dir == 1 ? color.new(zone.strong ? bull_zone_strong : bull_zone, 12) : color.new(zone.strong ? bear_zone_strong : bear_zone, 12)
                    if zone.family == "FVG"
                        retired_col := zone.dir == 1 ? color.new(fvg_bull, 12) : color.new(fvg_bear, 12)
                    if zone.family == "SD"
                        retired_col := zone.dir == 1 ? color.new(demand_fill, 12) : color.new(supply_fill, 12)
                    box.set_bgcolor(zone.region, retired_col)
                    if not na(zone.midline)
                        line.set_x2(zone.midline, bar_index)
                    if not na(zone.tag)
                        label.set_x(zone.tag, bar_index + 1)
                        label.set_textcolor(zone.tag, text_dim)
                    array.set(_zones, i, zone)

f_upgrade_latest(_zones, _dir) =>
    if array.size(_zones) > 0
        for i = array.size(_zones) - 1 to 0
            ZoneRecord zone = array.get(_zones, i)
            if zone.active and zone.dir == _dir
                zone.strong := true
                color strong_col = _dir == 1 ? bull_zone_strong : bear_zone_strong
                box.set_bgcolor(zone.region, strong_col)
                box.set_border_color(zone.region, color.new(strong_col, 0))
                if not na(zone.tag)
                    label.set_color(zone.tag, color.new(strong_col, 5))
                array.set(_zones, i, zone)
                break

f_count_active(_zones) =>
    int active_count = 0
    if array.size(_zones) > 0
        for i = 0 to array.size(_zones) - 1
            ZoneRecord zone = array.get(_zones, i)
            active_count += zone.active ? 1 : 0
    active_count

//==============================================================================
// PIVOTS AND STRUCTURE
//==============================================================================
pivot_high = ta.pivothigh(high, swing_length, swing_length)
pivot_low = ta.pivotlow(low, swing_length, swing_length)

if not na(pivot_high)
    last_pivot_high := pivot_high
    last_pivot_high_bar := bar_index[swing_length]

if not na(pivot_low)
    last_pivot_low := pivot_low
    last_pivot_low_bar := bar_index[swing_length]

bool confirmed_bar = require_confirmed_bar ? barstate.isconfirmed : true
displacement = math.abs(close - open) >= atr_value * displacement_factor

bull_bos = confirmed_bar and not na(last_pivot_high) and close > last_pivot_high and close[1] <= last_pivot_high
bear_bos = confirmed_bar and not na(last_pivot_low) and close < last_pivot_low and close[1] >= last_pivot_low

bull_sweep = confirmed_bar and not na(last_pivot_high) and high > last_pivot_high and close < last_pivot_high
bear_sweep = confirmed_bar and not na(last_pivot_low) and low < last_pivot_low and close > last_pivot_low

if bull_bos
    int prior_bias = structure_bias
    structure_bias := structure_bias == -1 ? 1 : math.max(structure_bias, 1)
    last_event_text := prior_bias == -1 ? "Bullish Shift" : "Bullish BOS"
    last_event_color := color.rgb(0, 214, 143)
    if show_bos
        f_add_event(last_pivot_high_bar, last_pivot_high, prior_bias == -1 ? "Shift" : "BOS", true, line.style_dashed)

if bear_bos
    int prior_bias = structure_bias
    structure_bias := structure_bias == 1 ? -1 : math.min(structure_bias, -1)
    last_event_text := prior_bias == 1 ? "Bearish Shift" : "Bearish BOS"
    last_event_color := color.rgb(255, 92, 126)
    if show_bos
        f_add_event(last_pivot_low_bar, last_pivot_low, prior_bias == 1 ? "Shift" : "BOS", false, line.style_dashed)

if bull_sweep
    last_sweep_bar := bar_index
    last_event_text := "Buy-Side Sweep"
    last_event_color := accent_gold
    if show_sweeps
        f_add_event(last_pivot_high_bar, last_pivot_high, "Sweep", false, line.style_dotted)

if bear_sweep
    last_sweep_bar := bar_index
    last_event_text := "Sell-Side Sweep"
    last_event_color := accent_gold
    if show_sweeps
        f_add_event(last_pivot_low_bar, last_pivot_low, "Sweep", true, line.style_dotted)

//==============================================================================
// IMBALANCE AND BLOCK LOGIC
//==============================================================================
bull_fvg = confirmed_bar and low > high[2]
bear_fvg = confirmed_bar and high < low[2]

bull_block = confirmed_bar and bull_fvg and close[2] < open[2] and displacement
bear_block = confirmed_bar and bear_fvg and close[2] > open[2] and displacement

if show_fvg and bull_fvg
    ZoneRecord zone = f_make_zone(bar_index[2], low, high[2], 1, "FVG", false)
    f_push_zone(bull_zones, zone)

if show_fvg and bear_fvg
    ZoneRecord zone = f_make_zone(bar_index[2], low[2], high, -1, "FVG", false)
    f_push_zone(bear_zones, zone)

if show_blocks and bull_block
    float zone_top = high[2]
    float zone_bottom = math.min(open[2], low[2])
    ZoneRecord zone = f_make_zone(bar_index[2], zone_top, zone_bottom, 1, "OB", false)
    f_push_zone(bull_zones, zone)

if show_blocks and bear_block
    float zone_top = math.max(open[2], high[2])
    float zone_bottom = low[2]
    ZoneRecord zone = f_make_zone(bar_index[2], zone_top, zone_bottom, -1, "OB", false)
    f_push_zone(bear_zones, zone)

//==============================================================================
// SUPPLY AND DEMAND
//==============================================================================
if show_supply_demand and not na(pivot_high)
    float supply_top = high[swing_length]
    float supply_bottom = supply_top - atr_value[swing_length] * zone_width_atr
    ZoneRecord zone = f_make_zone(bar_index[swing_length], supply_top, supply_bottom, -1, "SD", false)
    f_push_zone(bear_zones, zone)

if show_supply_demand and not na(pivot_low)
    float demand_bottom = low[swing_length]
    float demand_top = demand_bottom + atr_value[swing_length] * zone_width_atr
    ZoneRecord zone = f_make_zone(bar_index[swing_length], demand_top, demand_bottom, 1, "SD", false)
    f_push_zone(bull_zones, zone)

//==============================================================================
// ZONE UPGRADES
//==============================================================================
if bull_bos and (bull_fvg or bull_fvg[1] or bull_fvg[2])
    f_upgrade_latest(bull_zones, 1)

if bear_bos and (bear_fvg or bear_fvg[1] or bear_fvg[2])
    f_upgrade_latest(bear_zones, -1)

//==============================================================================
// ZONE MANAGEMENT
//==============================================================================
f_refresh_zones(bull_zones, 1)
f_refresh_zones(bear_zones, -1)

active_bull = f_count_active(bull_zones)
active_bear = f_count_active(bear_zones)

//==============================================================================
// PRICE CONTEXT LINES
//==============================================================================
plot(last_pivot_high, "Pivot High", color=color.new(neutral_line, 70), linewidth=1, style=plot.style_linebr)
plot(last_pivot_low, "Pivot Low", color=color.new(neutral_line, 70), linewidth=1, style=plot.style_linebr)

//==============================================================================
// DASHBOARD
//==============================================================================
var table dash = table.new(position.top_right, 2, 7, bgcolor=panel_bg, border_width=1, border_color=panel_grid, frame_color=panel_grid, frame_width=1)

f_dash_row(_row, _label, _value, _value_color, _bg) =>
    table.cell(dash, 0, _row, _label, text_color=text_dim, bgcolor=_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, _row, _value, text_color=_value_color, bgcolor=_bg, text_size=size.small, text_halign=text.align_right)

if show_dashboard and barstate.islast
    string bias_text = structure_bias == 1 ? "Accumulation" : structure_bias == -1 ? "Distribution" : "Transitional"
    color bias_color = structure_bias == 1 ? color.rgb(0, 214, 143) : structure_bias == -1 ? color.rgb(255, 92, 126) : accent_gold
    string sweep_text = na(last_sweep_bar) ? "None" : str.tostring(bar_index - last_sweep_bar) + " bars ago"
    table.cell(dash, 0, 0, "MERIDIAN STRUCTURE", text_color=text_main, bgcolor=panel_header, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, bias_text, text_color=bias_color, bgcolor=panel_header, text_size=size.small, text_halign=text.align_right)
    f_dash_row(1, "Bull Zones", str.tostring(active_bull), color.rgb(0, 214, 143), panel_cell)
    f_dash_row(2, "Bear Zones", str.tostring(active_bear), color.rgb(255, 92, 126), panel_bg)
    f_dash_row(3, "Last Event", last_event_text, last_event_color, panel_cell)
    f_dash_row(4, "Sweep Age", sweep_text, accent_gold, panel_bg)
    f_dash_row(5, "Displacement", displacement ? "Present" : "Muted", displacement ? accent_gold : text_dim, panel_cell)
    f_dash_row(6, "Pivot Spread", not na(last_pivot_high) and not na(last_pivot_low) ? str.tostring(last_pivot_high - last_pivot_low, format.mintick) : "n/a", text_main, panel_bg)

//==============================================================================
// ALERTS
//==============================================================================
alertcondition(bull_bos, "Bullish Structure Break", "Meridian Structure Lattice [JOAT] confirmed a bullish break of structure on {{ticker}} {{interval}}.")
alertcondition(bear_bos, "Bearish Structure Break", "Meridian Structure Lattice [JOAT] confirmed a bearish break of structure on {{ticker}} {{interval}}.")
alertcondition(bull_sweep, "Buy-Side Sweep", "Meridian Structure Lattice [JOAT] detected a buy-side liquidity sweep on {{ticker}} {{interval}}.")
alertcondition(bear_sweep, "Sell-Side Sweep", "Meridian Structure Lattice [JOAT] detected a sell-side liquidity sweep on {{ticker}} {{interval}}.")
````
