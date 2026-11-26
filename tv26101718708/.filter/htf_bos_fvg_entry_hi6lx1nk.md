# HTF | BOS | FVG | Entry

- url: https://www.tradingview.com/script/hi6lX1NK-HTF-BOS-FVG-Entry/
- type: indicator
- pine_id: PUB;7fc7bca803be40899bd87125c8fd4544
- version: 2.0

## Description

There are now 6 separate alerts you can set up independently in TradingView

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CirisAshley


//@version=6
indicator("HTF | BOS | FVG | Entry", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================================================
// ▌ INPUTS — HTF SETTINGS
// ============================================================
htf_group        = "═══ HTF ZONE SETTINGS ═══"
htf_tf           = input.string("1D", "HTF Timeframe", options=["1D", "240", "60"], group=htf_group, tooltip="1D = Daily | 240 = 4 Hour | 60 = 1 Hour")
show_htf_box     = input.bool(true,  "Show HTF Zone Box",       group=htf_group)
show_htf_lines   = input.bool(true,  "Show HTF High/Low Lines", group=htf_group)

// ============================================================
// ▌ INPUTS — BOS SETTINGS
// ============================================================
bos_group        = "═══ BREAK OF STRUCTURE ═══"
show_bos         = input.bool(true, "Show BOS Signal", group=bos_group)

// ============================================================
// ▌ INPUTS — FVG SETTINGS
// ============================================================
fvg_group         = "═══ FAIR VALUE GAP ═══"
show_fvg          = input.bool(true, "Show FVG Zone", group=fvg_group)
fvg_tick_confirm  = input.int(10, "Entry Confirmation Ticks", minval=1, maxval=30, group=fvg_group,
     tooltip="Ticks the rejection candle must CLOSE past before entry triggers. 10–15 recommended for Gold futures.")
entry_expire_bars = input.int(10, "Entry Signal Expires (bars)", minval=1, maxval=50, group=fvg_group,
     tooltip="How many bars after an entry signal fires before it auto-disappears.")
pin_bar_filter    = input.float(0.5, "Max Body/Range Ratio (Pin Bar Filter)", minval=0.1, maxval=0.9, step=0.05, group=fvg_group,
     tooltip="Touch candle body must be smaller than this % of its total range. 0.5 = body under 50% of range. Lower = stricter.")

// ============================================================
// ▌ INPUTS — COLORS
// ============================================================
col_group        = "═══ COLORS ═══"
col_htf_box_bull = input.color(color.new(color.teal,  80), "HTF Zone Box (Bullish)",  group=col_group)
col_htf_box_bear = input.color(color.new(color.red,   80), "HTF Zone Box (Bearish)",  group=col_group)
col_htf_high     = input.color(color.new(color.green,  0), "HTF High Line",           group=col_group)
col_htf_low      = input.color(color.new(color.red,    0), "HTF Low Line",            group=col_group)
col_bos_bull     = input.color(color.new(color.aqua,   0), "BOS Label (Bull)",        group=col_group)
col_bos_bear     = input.color(color.new(color.orange, 0), "BOS Label (Bear)",        group=col_group)
col_bos_zone     = input.color(color.new(color.yellow,75), "BOS Zone",                group=col_group)
col_fvg_bull     = input.color(color.new(color.teal,  65), "FVG Zone (Bullish)",      group=col_group)
col_fvg_bear     = input.color(color.new(color.red,   65), "FVG Zone (Bearish)",      group=col_group)
col_entry_bull   = input.color(color.new(color.lime,   0), "Entry Label (Bull)",      group=col_group)
col_entry_bear   = input.color(color.new(color.fuchsia,0), "Entry Label (Bear)",      group=col_group)

// ============================================================
// ▌ ATR FOR VERTICAL SPACING
// ============================================================
atr_val = ta.atr(14)

// ============================================================
// ▌ HTF DATA
// ============================================================
htf_prev_high  = request.security(syminfo.tickerid, htf_tf, high[1],  lookahead=barmerge.lookahead_on)
htf_prev_low   = request.security(syminfo.tickerid, htf_tf, low[1],   lookahead=barmerge.lookahead_on)
htf_prev_open  = request.security(syminfo.tickerid, htf_tf, open[1],  lookahead=barmerge.lookahead_on)
htf_prev_close = request.security(syminfo.tickerid, htf_tf, close[1], lookahead=barmerge.lookahead_on)
htf_time       = request.security(syminfo.tickerid, htf_tf, time,     lookahead=barmerge.lookahead_on)
htf_new_period = ta.change(htf_time) != 0
htf_col        = htf_prev_close >= htf_prev_open ? col_htf_box_bull : col_htf_box_bear

// ============================================================
// ▌ TRACKED DRAWING OBJECTS
// ============================================================
var box   htf_zone_box  = na
var line  htf_high_line = na
var line  htf_low_line  = na
var box   bos_box       = na
var label bos_lbl       = na
var box   fvg_box       = na
var line  fvg_mid_line  = na
var label fvg_lbl       = na
var label entry_lbl     = na
var line  entry_line    = na

// ============================================================
// ▌ SIGNAL STATE
// ============================================================
var bool  bos_bull_active = false
var bool  bos_bear_active = false
var float fvg_top         = na
var float fvg_bottom      = na
var float fvg_mid         = na
var bool  fvg_bull_on     = false
var bool  fvg_bear_on     = false
var bool  fvg_touched     = false
var float fvg_touch_close = na

// Bar-index guards
var int   bos_bull_bar  = na
var int   bos_bear_bar  = na
var int   fvg_bull_bar  = na
var int   fvg_bear_bar  = na
var int   fvg_touch_bar = na
var int   entry_bar     = na

// ============================================================
// ▌ ENTRY LABEL EXPIRY (runs every bar)
// ============================================================
if not na(entry_bar) and (bar_index - entry_bar >= entry_expire_bars)
    if not na(entry_lbl)
        label.delete(entry_lbl)
        entry_lbl := na
    if not na(entry_line)
        line.delete(entry_line)
        entry_line := na
    entry_bar := na

// ============================================================
// ▌ RESET ON NEW HTF PERIOD
// ============================================================
if htf_new_period
    if not na(htf_zone_box)
        box.delete(htf_zone_box)
        htf_zone_box := na
    if not na(htf_high_line)
        line.delete(htf_high_line)
        htf_high_line := na
    if not na(htf_low_line)
        line.delete(htf_low_line)
        htf_low_line := na
    if not na(bos_box)
        box.delete(bos_box)
        bos_box := na
    if not na(bos_lbl)
        label.delete(bos_lbl)
        bos_lbl := na
    if not na(fvg_box)
        box.delete(fvg_box)
        fvg_box := na
    if not na(fvg_mid_line)
        line.delete(fvg_mid_line)
        fvg_mid_line := na
    if not na(fvg_lbl)
        label.delete(fvg_lbl)
        fvg_lbl := na
    if not na(entry_lbl)
        label.delete(entry_lbl)
        entry_lbl := na
    if not na(entry_line)
        line.delete(entry_line)
        entry_line := na
    bos_bull_active := false
    bos_bear_active := false
    fvg_bull_on     := false
    fvg_bear_on     := false
    fvg_touched     := false
    fvg_top         := na
    fvg_bottom      := na
    fvg_mid         := na
    bos_bull_bar    := na
    bos_bear_bar    := na
    fvg_bull_bar    := na
    fvg_bear_bar    := na
    fvg_touch_bar   := na
    entry_bar       := na

// ============================================================
// ▌ HTF ZONE BOX + LINES
// ============================================================
if barstate.islast or htf_new_period
    if not na(htf_zone_box)
        box.delete(htf_zone_box)
    if not na(htf_high_line)
        line.delete(htf_high_line)
    if not na(htf_low_line)
        line.delete(htf_low_line)
    lb = math.max(0, bar_index - 50)
    if show_htf_box
        htf_zone_box := box.new(left=lb, top=htf_prev_high, right=bar_index + 8,
             bottom=htf_prev_low, border_color=htf_col, border_width=1, bgcolor=htf_col)
    if show_htf_lines
        htf_high_line := line.new(x1=lb, y1=htf_prev_high, x2=bar_index + 8, y2=htf_prev_high,
             color=col_htf_high, width=1, style=line.style_dashed)
        htf_low_line  := line.new(x1=lb, y1=htf_prev_low,  x2=bar_index + 8, y2=htf_prev_low,
             color=col_htf_low,  width=1, style=line.style_dashed)

// ============================================================
// ▌ BREAK OF STRUCTURE
// ============================================================
bos_bull = show_bos and ta.crossover(close,  htf_prev_high)
bos_bear = show_bos and ta.crossunder(close, htf_prev_low)

if bos_bull
    bos_bull_active := true
    bos_bear_active := false
    bos_bull_bar    := bar_index
    fvg_bull_on     := false
    fvg_bear_on     := false
    fvg_touched     := false
    fvg_bull_bar    := na
    fvg_bear_bar    := na
    fvg_touch_bar   := na
    if not na(bos_box)
        box.delete(bos_box)
    if not na(bos_lbl)
        label.delete(bos_lbl)
    bos_box := box.new(
         left=bar_index - 1, top=htf_prev_high + syminfo.mintick * 3,
         right=bar_index + 20, bottom=htf_prev_high - syminfo.mintick * 3,
         border_color=col_bos_bull, bgcolor=col_bos_zone, border_width=1)
    bos_lbl := label.new(bar_index, htf_prev_high,
         "BOS", color=color.new(color.black, 100), textcolor=col_bos_bull,
         style=label.style_label_right, size=size.tiny)
    alert("🔵 Bullish BOS — broke above HTF High: " + str.tostring(math.round(htf_prev_high, 2)), alert.freq_once_per_bar)

if bos_bear
    bos_bear_active := true
    bos_bull_active := false
    bos_bear_bar    := bar_index
    fvg_bull_on     := false
    fvg_bear_on     := false
    fvg_touched     := false
    fvg_bull_bar    := na
    fvg_bear_bar    := na
    fvg_touch_bar   := na
    if not na(bos_box)
        box.delete(bos_box)
    if not na(bos_lbl)
        label.delete(bos_lbl)
    bos_box := box.new(
         left=bar_index - 1, top=htf_prev_low + syminfo.mintick * 3,
         right=bar_index + 20, bottom=htf_prev_low - syminfo.mintick * 3,
         border_color=col_bos_bear, bgcolor=col_bos_zone, border_width=1)
    bos_lbl := label.new(bar_index, htf_prev_low,
         "BOS", color=color.new(color.black, 100), textcolor=col_bos_bear,
         style=label.style_label_right, size=size.tiny)
    alert("🔴 Bearish BOS — broke below HTF Low: " + str.tostring(math.round(htf_prev_low, 2)), alert.freq_once_per_bar)

// ============================================================
// ▌ FAIR VALUE GAP (only after BOS, must be a later bar)
// ============================================================
fvg_bull_raw     = show_fvg and (low  > high[2])
fvg_bear_raw     = show_fvg and (high < low[2])
fvg_bull_trigger = fvg_bull_raw and bos_bull_active and (not na(bos_bull_bar)) and (bar_index > bos_bull_bar)
fvg_bear_trigger = fvg_bear_raw and bos_bear_active and (not na(bos_bear_bar)) and (bar_index > bos_bear_bar)

// --- Bullish FVG ---
if fvg_bull_trigger and not fvg_bull_on and not fvg_bear_on
    fvg_top       := low
    fvg_bottom    := high[2]
    fvg_mid       := (fvg_top + fvg_bottom) / 2
    fvg_bull_on   := true
    fvg_bull_bar  := bar_index
    fvg_touched   := false
    fvg_touch_bar := na
    if not na(fvg_box)
        box.delete(fvg_box)
    if not na(fvg_mid_line)
        line.delete(fvg_mid_line)
    if not na(fvg_lbl)
        label.delete(fvg_lbl)
    fvg_box := box.new(left=bar_index - 2, top=fvg_top, right=bar_index + 40,
                       bottom=fvg_bottom, border_color=col_fvg_bull, bgcolor=col_fvg_bull, border_width=1)
    fvg_mid_line := line.new(x1=bar_index - 2, y1=fvg_mid, x2=bar_index + 40, y2=fvg_mid,
             color=color.new(color.white, 50), width=1, style=line.style_dotted)
    fvg_lbl := label.new(bar_index - 1, fvg_mid,
              "FVG ▲", color=color.new(col_fvg_bull, 100), textcolor=col_fvg_bull,
              style=label.style_label_right, size=size.tiny)
    alert("🟢 Bullish FVG — zone " + str.tostring(math.round(fvg_bottom,2)) + " to " + str.tostring(math.round(fvg_top,2)), alert.freq_once_per_bar)

// --- Bearish FVG ---
if fvg_bear_trigger and not fvg_bear_on and not fvg_bull_on
    fvg_top       := low[2]
    fvg_bottom    := high
    fvg_mid       := (fvg_top + fvg_bottom) / 2
    fvg_bear_on   := true
    fvg_bear_bar  := bar_index
    fvg_touched   := false
    fvg_touch_bar := na
    if not na(fvg_box)
        box.delete(fvg_box)
    if not na(fvg_mid_line)
        line.delete(fvg_mid_line)
    if not na(fvg_lbl)
        label.delete(fvg_lbl)
    fvg_box := box.new(left=bar_index - 2, top=fvg_top, right=bar_index + 40,
                       bottom=fvg_bottom, border_color=col_fvg_bear, bgcolor=col_fvg_bear, border_width=1)
    fvg_mid_line := line.new(x1=bar_index - 2, y1=fvg_mid, x2=bar_index + 40, y2=fvg_mid,
             color=color.new(color.white, 50), width=1, style=line.style_dotted)
    fvg_lbl := label.new(bar_index - 1, fvg_mid,
              "FVG ▼", color=color.new(col_fvg_bear, 100), textcolor=col_fvg_bear,
              style=label.style_label_right, size=size.tiny)
    alert("🔴 Bearish FVG — zone " + str.tostring(math.round(fvg_bottom,2)) + " to " + str.tostring(math.round(fvg_top,2)), alert.freq_once_per_bar)

// ============================================================
// ▌ FVG INVALIDATION
// ============================================================
if fvg_bull_on and close < fvg_bottom
    fvg_bull_on     := false
    fvg_touched     := false
    bos_bull_active := false
    if not na(fvg_box)
        box.set_border_color(fvg_box, color.new(color.gray, 60))
        box.set_bgcolor(fvg_box,      color.new(color.gray, 88))

if fvg_bear_on and close > fvg_top
    fvg_bear_on     := false
    fvg_touched     := false
    bos_bear_active := false
    if not na(fvg_box)
        box.set_border_color(fvg_box, color.new(color.gray, 60))
        box.set_bgcolor(fvg_box,      color.new(color.gray, 88))

// ============================================================
// ▌ ENTRY SIGNAL — TAP & REJECT ONLY (close confirmation)
// ============================================================
tick_size = syminfo.mintick * fvg_tick_confirm

// ── Pin bar ratio of current bar ──
bar_body  = math.abs(close - open)
bar_range = high - low
pin_ratio = bar_range > 0 ? bar_body / bar_range : 1.0

// ── BULLISH touch detection ──
// Wick enters zone, close stays AT or BELOW zone top, pin bar filter passes
if fvg_bull_on and not fvg_touched
    if (not na(fvg_bull_bar)) and (bar_index > fvg_bull_bar)
        if low <= fvg_top and high >= fvg_bottom
            if close <= fvg_top and pin_ratio < pin_bar_filter
                fvg_touched     := true
                fvg_touch_close := close
                fvg_touch_bar   := bar_index

// ── BULLISH entry: fires on bar AFTER touch bar, close confirmation ──
if fvg_bull_on and fvg_touched
    if (not na(fvg_touch_bar)) and (bar_index > fvg_touch_bar)
        if close >= fvg_touch_close + tick_size
            if not na(entry_lbl)
                label.delete(entry_lbl)
            if not na(entry_line)
                line.delete(entry_line)
            entry_price = fvg_touch_close + tick_size
            entry_line := line.new(x1=bar_index, y1=entry_price, x2=bar_index + 40, y2=entry_price,
                 color=col_entry_bull, width=2, style=line.style_solid)
            entry_lbl := label.new(bar_index + 40, entry_price,
                      "▲ FVG Entry  " + str.tostring(math.round(entry_price, 2)),
                      color=col_entry_bull, textcolor=color.white,
                      style=label.style_label_left, size=size.small)
            entry_bar := bar_index
            alert("✅ BULLISH ENTRY — FVG rejection confirmed! Price: " + str.tostring(math.round(close,2)), alert.freq_once_per_bar)
            fvg_bull_on     := false
            fvg_touched     := false
            bos_bull_active := false

// ── BEARISH touch detection ──
// Wick enters zone, close stays AT or ABOVE zone bottom, pin bar filter passes
if fvg_bear_on and not fvg_touched
    if (not na(fvg_bear_bar)) and (bar_index > fvg_bear_bar)
        if low <= fvg_top and high >= fvg_bottom
            if close >= fvg_bottom and pin_ratio < pin_bar_filter
                fvg_touched     := true
                fvg_touch_close := close
                fvg_touch_bar   := bar_index

// ── BEARISH entry: fires on bar AFTER touch bar, close confirmation ──
if fvg_bear_on and fvg_touched
    if (not na(fvg_touch_bar)) and (bar_index > fvg_touch_bar)
        if close <= fvg_touch_close - tick_size
            if not na(entry_lbl)
                label.delete(entry_lbl)
            if not na(entry_line)
                line.delete(entry_line)
            entry_price = fvg_touch_close - tick_size
            entry_line := line.new(x1=bar_index, y1=entry_price, x2=bar_index + 40, y2=entry_price,
                 color=col_entry_bear, width=2, style=line.style_solid)
            entry_lbl := label.new(bar_index + 40, entry_price,
                      "▼ FVG Entry  " + str.tostring(math.round(entry_price, 2)),
                      color=col_entry_bear, textcolor=color.white,
                      style=label.style_label_left, size=size.small)
            entry_bar := bar_index
            alert("🔻 BEARISH ENTRY — FVG rejection confirmed! Price: " + str.tostring(math.round(close,2)), alert.freq_once_per_bar)
            fvg_bear_on     := false
            fvg_touched     := false
            bos_bear_active := false

// ============================================================
// ▌ INVISIBLE PLOTS (scale anchors)
// ============================================================
plot(show_htf_lines ? htf_prev_high : na, "HTF High", color=col_htf_high, display=display.none)
plot(show_htf_lines ? htf_prev_low  : na, "HTF Low",  color=col_htf_low,  display=display.none)

// ============================================================
// ▌ ALERT CONDITIONS
// ============================================================
// — BOS —
alertcondition(bos_bull, "🔵 Bullish BOS",  "Bullish BOS — price broke above HTF High")
alertcondition(bos_bear, "🔴 Bearish BOS",  "Bearish BOS — price broke below HTF Low")

// — FVG Formed —
alertcondition(fvg_bull_trigger, "🟢 Bullish FVG Formed", "Bullish FVG zone formed — watch for price to return to zone")
alertcondition(fvg_bear_trigger, "🔴 Bearish FVG Formed", "Bearish FVG zone formed — watch for price to return to zone")

// — Entry Signals (recomputed fresh so state reset above doesn't break them) —
alertcondition(ta.crossover(close,  htf_prev_high), "✅ Bullish Entry Signal", "BULLISH ENTRY — FVG rejection confirmed, look to buy")
alertcondition(ta.crossunder(close, htf_prev_low),  "🔻 Bearish Entry Signal", "BEARISH ENTRY — FVG rejection confirmed, look to sell")
````
