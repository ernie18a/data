# Sphinx Fixed Price Grid

- url: https://www.tradingview.com/script/lhtKeFpy-Sphinx-Fixed-Price-Grid/
- type: indicator
- pine_id: PUB;e3863b7a821e479ca77f856369835f75
- version: 1.0

## Description

A grid of horizontal lines at every N-point multiple of price, plus the order prices those multiples imply.

What it does

The grid is computed as floor(price / step) × step. It depends on price alone, so the same levels appear on every chart, every reload, and every timeframe. There is no anchor bar and no state carried between sessions.

Why that matters

Traditional Renko anchors its brick sequence to the start of available data rather than to a price grid. There is no offset input, and the anchor can move when the data window changes — loading more history, switching sessions, or reloading the chart. Brick boundaries are therefore not a stable price reference, even though they look like one.

Any method that places orders relative to brick edges inherits that instability. This indicator computes the levels arithmetically instead, so they are reproducible.

Order levels

Optionally marks the entry and protective stop implied by the current grid position, on both sides. Entry sits one tick beyond the next grid level so a stop order triggers on a break rather than a touch; the protective stop sits on the grid level a configurable number of steps away. The tick offset applies to the entry only — offsetting both ends would change the risk distance without it being obvious.

Distances are shown in points on the labels and exported to the data window.

Drift check

An optional readout comparing the current close against the nearest grid level. On a Renko chart this reveals whether the plotted brick boundaries sit on grid prices or somewhere between them. A non-zero reading means brick edges are not grid levels and should not be used as order prices.

Notes

Set the grid step to match your brick size. The indicator draws levels and reports distances only. It reads no trend, generates no signals, and takes no directional view.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// (c) MM Sphinx Fixed Price Grid
// Version 1.0.1
//
//   v1.0.1: order price labels are separately toggleable. The lines still draw
//   with labels off, and the prices stay in the data window either way.
//
// Version 1.0.0
//
//   A fixed grid of horizontal lines at every N-point multiple, plus the
//   working order prices those multiples imply.
//
//   Why this exists: TradingView's Traditional Renko anchors its brick
//   sequence to the start of available data, not to a price grid. There is no
//   offset input, and the anchor can move when the data window changes - load
//   more history, change session, reload the chart - so the drawn boundaries
//   are not a stable reference. A system whose entry is "one tick past the
//   next brick" and whose stop is exactly two bricks needs prices that do not
//   move when the chart reloads.
//
//   The grid here is computed from price alone: floor(price / step) * step.
//   It is identical on every chart, every reload, every timeframe, and it can
//   be compared against the Renko boundaries to see how far they have drifted.
//
//   This indicator draws levels and computes order prices. It places no
//   orders, reads no trend, and takes no view on direction.
//@version=6
indicator('Sphinx Fixed Price Grid', shorttitle = 'Price Grid', overlay = true, max_lines_count = 500, max_labels_count = 100)

// ============================================================
// === GRID ===
// ============================================================
g_grid = 'Grid'
i_step = input.float(5.0, 'Grid step (points)', minval = 0.25, step = 0.25, group = g_grid, tooltip = 'Spacing of the grid. Set this to the Renko brick size so the lines mark true brick boundaries. 5 points on NQ / MNQ is 20 ticks.')
i_count = input.int(40, 'Lines above / below price', minval = 2, maxval = 120, group = g_grid, tooltip = 'How many grid lines to draw on each side of the current price. Raise it if the grid does not fill a zoomed-out chart; lower it if the draw limit is reached with other indicators loaded.')
i_major = input.int(5, 'Major line every N steps', minval = 0, maxval = 20, group = g_grid, tooltip = 'Emphasises every Nth line - at step 5 and major 5 that is every 25 points. Set 0 for a uniform grid.')

g_style = 'Style'
col_minor = input.color(color.new(#787b86, 72), 'Minor', group = g_style, inline = 'gc')
col_major = input.color(color.new(#787b86, 40), 'Major', group = g_style, inline = 'gc')
i_sty = input.string('Dotted', 'Line style', options = ['Solid', 'Dashed', 'Dotted'], group = g_style)
i_wid_minor = input.int(1, 'Minor width', minval = 1, maxval = 3, group = g_style, inline = 'gw')
i_wid_major = input.int(1, 'Major width', minval = 1, maxval = 3, group = g_style, inline = 'gw')
i_left = input.int(300, 'Draw back (bars)', minval = 20, maxval = 2000, group = g_style, tooltip = 'How far left the grid lines extend. They always extend right to the current bar.')

// ============================================================
// === ORDER PRICES ===
// ============================================================
//   The prices the grid implies, computed rather than read off the chart.
//   Long:  buy stop one tick above the next grid level up.
//          stop  one tick below the level i_stop_steps below that entry level.
//   Short: mirrored.
g_ord = 'Order prices'
i_orders = input.bool(true, 'Show working order prices', group = g_ord, tooltip = 'Marks the buy stop, sell stop and their corresponding protective stops implied by the current grid position. These are arithmetic, not chart reads - they are the same regardless of where the Renko sequence happens to be anchored.')
i_ord_lbl = input.bool(true, '  Show price labels', group = g_ord, tooltip = 'Off draws the order lines with no text. The prices remain in the data window, so they can still be read without putting them on the chart.')
i_stop_steps = input.int(2, '  Protective stop (steps)', minval = 1, maxval = 10, group = g_ord, tooltip = 'Distance from entry to protective stop, in grid steps. Two steps at a 5 point grid is the 10 point stop.')
i_tick_off = input.bool(true, '  Add one tick offset', group = g_ord, tooltip = 'Entry one tick beyond the level rather than at it, and the protective stop one tick beyond its level. Matches a stop order placed just past the boundary.')
col_buy = input.color(#26a69a, 'Buy side', group = g_ord, inline = 'oc')
col_sell = input.color(#ef5350, 'Sell side', group = g_ord, inline = 'oc')
col_stop = input.color(#ff9800, 'Protective stops', group = g_ord)
i_lbl_off = input.int(12, '  Label offset (bars)', minval = 0, maxval = 80, group = g_ord)

// ============================================================
// === RENKO DRIFT CHECK ===
// ============================================================
g_drift = 'Renko drift check'
i_drift = input.bool(false, 'Show drift readout', group = g_drift, tooltip = 'On a Renko chart, compares the current brick boundaries against the true grid. A non-zero drift means the chart brick sequence is anchored somewhere other than a multiple of the step, so brick edges are NOT at grid prices and cannot be used as order levels.\n\nOn a time-based chart this reads n/a - there are no bricks to compare.')
i_drift_pos = input.string('Bottom Right', 'Position', options = ['Top Left', 'Top Right', 'Middle Left', 'Middle Right', 'Bottom Left', 'Bottom Right'], group = g_drift)

// ============================================================
// === HELPERS ===
// ============================================================
_sty(s) =>
    s == 'Dashed' ? line.style_dashed : s == 'Dotted' ? line.style_dotted : line.style_solid

_pos(s) =>
    switch s
        'Top Left' => position.top_left
        'Top Right' => position.top_right
        'Middle Left' => position.middle_left
        'Middle Right' => position.middle_right
        'Bottom Left' => position.bottom_left
        => position.bottom_right

// Nearest grid level at or below a price. This is the whole mechanism: it
// depends on price only, so it is identical on every chart and every reload.
_floor_grid(p) =>
    math.floor(p / i_step) * i_step

// ============================================================
// === STATE ===
// ============================================================
var array<line> glines = array.new_line()
var array<label> glabels = array.new_label()

_tick = i_tick_off ? syminfo.mintick : 0.0

// Grid levels bracketing current price
_below = _floor_grid(close)
_above = _below + i_step
// A close sitting exactly on a level has no room above it within the step;
// treat the next level up as the one to break.
_next_up = math.abs(close - _above) < syminfo.mintick / 2 ? _above + i_step : _above
_next_dn = math.abs(close - _below) < syminfo.mintick / 2 ? _below - i_step : _below

// Working order prices, computed.
//   The tick offset belongs to the ENTRY only. Entry sits one tick beyond the
//   grid level so the stop order triggers on a break rather than a touch; the
//   protective stop sits on the grid level i_stop_steps away, unoffset. Total
//   risk is therefore i_stop_steps x i_step plus one tick - 10.25 points at a
//   5 point grid with a 2 step stop. Offsetting both ends would make it 10.50
//   and quietly change R.
_buy_entry = _next_up + _tick
_buy_stop = _next_up - i_stop_steps * i_step
_sell_entry = _next_dn - _tick
_sell_stop = _next_dn + i_stop_steps * i_step

// ============================================================
// === DRAW ===
// ============================================================
if barstate.islast
    if array.size(glines) > 0
        for _i = 0 to array.size(glines) - 1 by 1
            line.delete(array.get(glines, _i))
    if array.size(glabels) > 0
        for _i = 0 to array.size(glabels) - 1 by 1
            label.delete(array.get(glabels, _i))
    array.clear(glines)
    array.clear(glabels)

    int _l = math.max(0, bar_index - i_left)
    int _r = bar_index + 1

    // grid
    for _k = -i_count to i_count by 1
        float _p = _below + _k * i_step
        if _p > 0
            // major every Nth step, measured from zero so the emphasis does
            // not shift as price moves through the grid
            bool _is_major = i_major > 0 and math.round(_p / i_step) % i_major == 0
            color _c = _is_major ? col_major : col_minor
            int _w = _is_major ? i_wid_major : i_wid_minor
            array.push(glines, line.new(_l, _p, _r, _p, xloc = xloc.bar_index, extend = extend.right, color = _c, width = _w, style = _sty(i_sty)))

    // working order prices
    if i_orders
        _lx = bar_index + i_lbl_off
        array.push(glines, line.new(_l, _buy_entry, _r, _buy_entry, xloc = xloc.bar_index, extend = extend.right, color = col_buy, width = 2, style = line.style_solid))
        array.push(glines, line.new(_l, _buy_stop, _r, _buy_stop, xloc = xloc.bar_index, extend = extend.right, color = col_stop, width = 1, style = line.style_dashed))
        array.push(glines, line.new(_l, _sell_entry, _r, _sell_entry, xloc = xloc.bar_index, extend = extend.right, color = col_sell, width = 2, style = line.style_solid))
        array.push(glines, line.new(_l, _sell_stop, _r, _sell_stop, xloc = xloc.bar_index, extend = extend.right, color = col_stop, width = 1, style = line.style_dashed))
        if i_ord_lbl
            array.push(glabels, label.new(_lx, _buy_entry, 'buy stop ' + str.tostring(_buy_entry, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_buy, size = size.small))
            array.push(glabels, label.new(_lx, _buy_stop, 'long SL ' + str.tostring(_buy_stop, format.mintick) + '  (' + str.tostring(_buy_entry - _buy_stop, format.mintick) + ' pts)', xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_stop, size = size.small))
            array.push(glabels, label.new(_lx, _sell_entry, 'sell stop ' + str.tostring(_sell_entry, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_sell, size = size.small))
            array.push(glabels, label.new(_lx, _sell_stop, 'short SL ' + str.tostring(_sell_stop, format.mintick) + '  (' + str.tostring(_sell_stop - _sell_entry, format.mintick) + ' pts)', xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_stop, size = size.small))

// ============================================================
// === DRIFT READOUT ===
// ============================================================
//   On a Renko chart the plotted open/close ARE brick boundaries. If those
//   boundaries are not multiples of the step, the chart's bricks are anchored
//   off-grid and their edges are not usable as order prices.
_brick_edge = close
_drift_raw = _brick_edge - _floor_grid(_brick_edge)
// report the smaller of the two distances to a grid line
_drift = math.min(_drift_raw, i_step - _drift_raw)
_is_renko = str.contains(str.lower(syminfo.type), 'renko') or timeframe.period == ''

var table dt = na
if i_drift and barstate.islast
    if not na(dt)
        table.delete(dt)
    dt := table.new(_pos(i_drift_pos), 2, 3, border_width = 1, border_color = color.new(color.gray, 55))
    table.cell(dt, 0, 0, 'Grid', text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(dt, 1, 0, str.tostring(i_step, format.mintick) + ' pt', text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(dt, 0, 1, 'Last close', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(dt, 1, 1, str.tostring(close, format.mintick), text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(dt, 0, 2, 'Off grid by', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    // Under a tick from a grid line counts as on-grid.
    bool _aligned = _drift < syminfo.mintick / 2
    table.cell(dt, 1, 2, _aligned ? 'aligned' : str.tostring(_drift, format.mintick), text_color = color.white, bgcolor = _aligned ? color.new(#26a69a, 40) : color.new(#ff9800, 40), text_size = size.small)

// ============================================================
// === DATA WINDOW EXPORTS ===
// ============================================================
plot(_next_up, 'next grid up', color = na, display = display.data_window)
plot(_next_dn, 'next grid down', color = na, display = display.data_window)
plot(_buy_entry, 'buy stop', color = na, display = display.data_window)
plot(_buy_stop, 'long SL', color = na, display = display.data_window)
plot(_sell_entry, 'sell stop', color = na, display = display.data_window)
plot(_sell_stop, 'short SL', color = na, display = display.data_window)
plot(_buy_entry - _buy_stop, 'risk (points)', color = na, display = display.data_window)
plot(_drift, 'off-grid distance', color = na, display = display.data_window)
````
