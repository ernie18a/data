# Sequential Pivot Counter

- url: https://www.tradingview.com/script/j5R9DU8n-Sequential-Pivot-Counter/
- type: indicator
- pine_id: PUB;73652469efa64b0289ab8e9d325b0642
- version: 1.0

## Description

Normally scrips change direction after marking 3rd lower low or vice versa.this can be on daily weekly or any other time frame.This indicator will keep track on number of higher high or lower low. we will be able to track number whether they are fibonacci higher highs or lower lows

## Source Code

````pine
//@version=5
indicator("Sequential Pivot Counter (Extended)", overlay=true, max_labels_count=500)

lookback = input.int(50, "Lookback period (candles)", minval=5)

// ── State ────────────────────────────────────────────────
var int   phase          = 0
var int   up_count       = 0
var int   dn_count       = 0
var int   rev_count      = 0
var int   up_start_bar   = na
var int   dn_start_bar   = na
var int   rev_start_bar  = na
var float up_track_high  = na
var float up_anchor_low  = na
var float dn_track_low   = na
var float major_pivot_h  = na
var float rev_anchor_low = na
var float rev_track_low  = na
var line  watch_line     = na
var line  pivot_line     = na

// ── Label arrays ─────────────────────────────────────────
var label[] up_labels    = array.new_label()
var label[] dn_labels    = array.new_label()
var label[] rev_labels   = array.new_label()

// ── Lowest low in lookback — for upside start ────────────
ll_val = ta.lowest(low, lookback)
is_ll  = low == ll_val

// ── Highest low in lookback — for reverse start ──────────
hl_val = ta.highest(low, lookback)
is_hl  = low == hl_val

// ── UPSIDE PHASE ─────────────────────────────────────────
if phase == 0
    if is_ll
        for lbl in up_labels
            label.delete(lbl)
        array.clear(up_labels)

        up_count      := 1
        up_start_bar  := bar_index
        up_track_high := high
        up_anchor_low := low
        major_pivot_h := high
        dn_count      := 0
        dn_track_low  := na
        dn_start_bar  := na

        lbl = label.new(bar_index, high, "1",
             style     = label.style_none,
             textcolor = color.green,
             size      = size.small,
             yloc      = yloc.abovebar)
        array.push(up_labels, lbl)

    else if up_count >= 1 and high > up_track_high and (bar_index - up_start_bar) <= lookback
        up_count      += 1
        up_track_high := high
        major_pivot_h := high

        lbl = label.new(bar_index, high, str.tostring(up_count),
             style     = label.style_none,
             textcolor = color.green,
             size      = size.small,
             yloc      = yloc.abovebar)
        array.push(up_labels, lbl)

    if up_count >= 1 and (bar_index - up_start_bar) > lookback
        up_count      := 0
        up_track_high := na
        up_anchor_low := na
        up_start_bar  := na
        major_pivot_h := na

    if up_count >= 1 and low < up_anchor_low and (bar_index - up_start_bar) <= lookback
        for lbl in up_labels
            label.delete(lbl)
        array.clear(up_labels)

        phase         := 1
        dn_count      := 1
        dn_track_low  := low
        dn_start_bar  := bar_index

        for lbl in dn_labels
            label.delete(lbl)
        array.clear(dn_labels)

        dn_lbl = label.new(bar_index, low, "1",
             style     = label.style_none,
             textcolor = color.red,
             size      = size.small,
             yloc      = yloc.belowbar)
        array.push(dn_labels, dn_lbl)

// ── DOWNSIDE PHASE ────────────────────────────────────────
else if phase == 1
    if high > major_pivot_h
        for lbl in dn_labels
            label.delete(lbl)
        array.clear(dn_labels)

        phase         := 0
        up_count      := 0
        dn_count      := 0
        up_track_high := na
        up_anchor_low := na
        up_start_bar  := na
        dn_track_low  := na
        dn_start_bar  := na
        major_pivot_h := na

    else if dn_count >= 1 and low < dn_track_low and (bar_index - dn_start_bar) <= lookback
        dn_count     += 1
        dn_track_low := low
        dn_start_bar := bar_index

        dn_lbl = label.new(bar_index, low, str.tostring(dn_count),
             style     = label.style_none,
             textcolor = color.red,
             size      = size.small,
             yloc      = yloc.belowbar)
        array.push(dn_labels, dn_lbl)

    else if dn_count >= 1 and (bar_index - dn_start_bar) > lookback
        phase        := 0
        dn_count     := 0
        dn_track_low := na
        dn_start_bar := na

// ── REVERSE LOGIC (Highest Low Counter) ──────────────────
if is_hl
    for lbl in rev_labels
        label.delete(lbl)
    array.clear(rev_labels)

    rev_count     := 1
    rev_start_bar := bar_index
    rev_anchor_low:= low
    rev_track_low := low

    rev_lbl = label.new(bar_index, low, "1",
         style     = label.style_none,
         textcolor = color.red,
         size      = size.small,
         yloc      = yloc.belowbar)
    array.push(rev_labels, rev_lbl)

else if rev_count >= 1 and low < rev_track_low and (bar_index - rev_start_bar) <= lookback
    rev_count     += 1
    rev_track_low := low
    rev_start_bar := bar_index

    rev_lbl = label.new(bar_index, low, str.tostring(rev_count),
         style     = label.style_none,
         textcolor = color.red,
         size      = size.small,
         yloc      = yloc.belowbar)
    array.push(rev_labels, rev_lbl)

// Reset reverse counter once highest high is broken
if rev_count >= 1 and high > up_track_high
    for lbl in rev_labels
        label.delete(lbl)
    array.clear(rev_labels)
    rev_count     := 0
    rev_anchor_low:= na
    rev_track_low := na
    rev_start_bar := na
````
