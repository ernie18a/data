# Alex London ORB v3 - Zones + Bias + Mid Entry

- url: https://www.tradingview.com/script/cbPesHQp-Alex-London-ORB-v3-Zones-Bias-Mid-Entry/
- type: indicator
- pine_id: PUB;4b49ec0ea13f4ae2a4b412b366bf2bc8
- version: 1.0

## Description

6:30 candle. With this setup we can take a trade on London session

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
// ALEX LONDON ORB v3 — RANGE ZONES + BIAS + MID ENTRY  (15m ONLY)
// ───────────────────────────────────────────────────────────────────────────
// RANGE (unchanged from v2 — you liked it):
//   • 15m only. Observation starts on the candle AFTER 06:30 UK.
//   • A side (high/low) locks only when REJECTED: an extreme, then
//     `Swing Confirm Candles` bars with no new extreme. Both sides => range done.
//   • Two WIDE zone boxes: HIGH zone = highest body → highest wick; LOW zone =
//     lowest wick → lowest body. Middle of the range left open.
//
// WHAT'S NEW IN v3:
//   1. The boxes now EXTEND to the right — from the candle after 06:30, through
//      the breakout, up to the moment the TRADE starts (price returns to the
//      midpoint). Then they FREEZE. They do not run further across the day.
//   2. Breakout needs BODY, not just a wick: a candle must CLOSE beyond the zone
//      AND have at least `Breakout body beyond zone` of its body poking out.
//      It does NOT have to fully clear — just a bit of body out.
//   3. After breakout, wait for price to come back and the trade starts at the
//      MIDPOINT between high and low, in the breakout's direction.
//   4. Every day's 06:30 formation is shaded the same in the background.
//
// (Backtest version with real TP/SL orders = alex_london_orb_strategy_v1.pine)
// ═══════════════════════════════════════════════════════════════════════════

indicator("Alex London ORB v3 - Zones + Bias + Mid Entry", overlay = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════
g_geom = "Red-Line Grid"
i_step   = input.float(25.0, "Grid Step ($)",   group = g_geom, minval = 1.0)
i_offset = input.float(12.5, "Grid Offset (.5)", group = g_geom, minval = 0.0)

g_orb = "London ORB"
i_piv       = input.int(1, "Min trend candles before a reversal locks a side", group = g_orb, minval = 1, maxval = 6, tooltip = "A side (high/low) locks when the trend REVERSES: candles close one way, then a candle closes the other way (that reversal candle confirms the extreme). This is the minimum candles the run must have before the reversal counts. 1 = a single reversal close confirms (literal).")
i_form      = input.session("0645-1000:23456", "Formation Window (after 06:30)", group = g_orb)
i_trade     = input.session("0645-1430:23456", "Trade Window (bias valid until)", group = g_orb)
i_tz        = input.string("Europe/London", "Timezone", group = g_orb, options = ["Europe/London", "UTC", "Europe/Bucharest", "America/New_York"])
i_prefer_rl = input.bool(false, "Entry: prefer red line in range over exact midpoint", group = g_orb)

g_bo = "Breakout"
i_bo_frac = input.float(0.10, "Breakout body beyond zone >= x of candle body", group = g_bo, minval = 0.0, maxval = 1.0, step = 0.05, tooltip = "0 = any body close beyond the zone counts. Raise it to demand more body sticking out (less wick-y breakouts).")

g_viz = "Visualization"
i_show_box   = input.bool(true, "Draw the high / low zone boxes",  group = g_viz)
i_show_mid   = input.bool(true, "Draw entry / retest level",       group = g_viz)
i_shade_form = input.bool(true, "Shade the 06:30 formation window each day", group = g_viz)
i_col_hi     = input.color(color.red,   "High zone colour", group = g_viz)
i_col_lo     = input.color(color.green, "Low zone colour",  group = g_viz)

// ═══════════════════════════════════════════════════════════════════════════
// TIMEFRAME GUARD — 15m only
// ═══════════════════════════════════════════════════════════════════════════
is15 = timeframe.period == "15"
var label warn_lbl = na
if not is15 and barstate.islast and na(warn_lbl)
    warn_lbl := label.new(bar_index, high, "Alex London ORB v3 works on the 15m chart only — switch to 15m.", style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white, size = size.normal)

// ═══════════════════════════════════════════════════════════════════════════
// SESSIONS
// ═══════════════════════════════════════════════════════════════════════════
in_form  = not na(time(timeframe.period, i_form,  i_tz))
in_trade = not na(time(timeframe.period, i_trade, i_tz))
in_open  = not na(time(timeframe.period, "0630-0645:23456", i_tz))   // the 06:30 candle itself

body     = math.abs(close - open)
body_top = math.max(open, close)
body_bot = math.min(open, close)

// ═══════════════════════════════════════════════════════════════════════════
// STATE (reset every day when the formation window opens)
// ═══════════════════════════════════════════════════════════════════════════
var float band_hi_wick = na
var float band_hi_top  = na
var float band_lo_bot  = na
var float band_lo_wick = na
var bool  high_locked  = false
var bool  low_locked   = false
var bool  range_locked = false
var int   form_start_b = na
var int   dir          = 0    // close-direction of the current leg: +1 up, -1 down
var float up_wick      = na   // highest high of the current up-leg
var float up_body      = na   // highest body-top of the current up-leg
var int   up_n         = 0    // candles in the current up-leg
var float dn_wick      = na   // lowest low of the current down-leg
var float dn_body      = na   // lowest body-bottom of the current down-leg
var int   dn_n         = 0    // candles in the current down-leg
var float form_hi      = na   // window-wide extremes (fallback for force-lock)
var float form_hibody  = na
var float form_lo      = na
var float form_lobody  = na
var bool  inside_seen  = false
var float orb_high     = na
var float orb_low      = na
var int   orb_bias     = 0
var bool  retested     = false
var bool  box_frozen   = false
var box   box_hi       = na
var box   box_lo       = na

form_started = is15 and in_form and not in_form[1]
if form_started
    band_hi_wick := na
    band_hi_top  := na
    band_lo_bot  := na
    band_lo_wick := na
    high_locked  := false
    low_locked   := false
    range_locked := false
    form_start_b := bar_index
    dir          := 0
    up_wick      := na
    up_body      := na
    up_n         := 0
    dn_wick      := na
    dn_body      := na
    dn_n         := 0
    form_hi      := na
    form_hibody  := na
    form_lo      := na
    form_lobody  := na
    inside_seen  := false
    orb_high     := na
    orb_low      := na
    orb_bias     := 0
    retested     := false
    box_frozen   := false
    box_hi       := na
    box_lo       := na

// ═══════════════════════════════════════════════════════════════════════════
// FORMATION — accumulate zones + lock each side when REJECTED
// ═══════════════════════════════════════════════════════════════════════════
if is15 and in_form and not range_locked
    // window-wide extremes (fallback for the force-lock at window end)
    form_hi     := na(form_hi)     ? high     : math.max(form_hi, high)
    form_hibody := na(form_hibody) ? body_top : math.max(form_hibody, body_top)
    form_lo     := na(form_lo)     ? low      : math.min(form_lo, low)
    form_lobody := na(form_lobody) ? body_bot : math.min(form_lobody, body_bot)
    // direction of THIS candle by its close vs the previous close
    c_up = close > close[1]
    c_dn = close < close[1]
    if c_up
        if dir == 1
            // still trending up -> extend the up-leg
            up_wick := math.max(up_wick, high)
            up_body := math.max(up_body, body_top)
            up_n    := up_n + 1
        else
            // trend just TURNED UP -> the finished down-leg's trough is the LOW
            if dir == -1 and not low_locked and dn_n >= i_piv
                band_lo_wick := dn_wick
                band_lo_bot  := dn_body
                low_locked   := true
            up_wick := high
            up_body := body_top
            up_n    := 1
            dir     := 1
    else if c_dn
        if dir == -1
            // still trending down -> extend the down-leg
            dn_wick := math.min(dn_wick, low)
            dn_body := math.min(dn_body, body_bot)
            dn_n    := dn_n + 1
        else
            // trend just TURNED DOWN -> the finished up-leg's peak is the HIGH
            if dir == 1 and not high_locked and up_n >= i_piv
                band_hi_wick := up_wick
                band_hi_top  := up_body
                high_locked  := true
            dn_wick := low
            dn_body := body_bot
            dn_n    := 1
            dir     := -1
    if high_locked and low_locked
        range_locked := true
        orb_high     := band_hi_wick
        orb_low      := band_lo_wick

// force-lock if the formation window ends before both sides reverse
form_ended = is15 and not in_form and in_form[1]
if form_ended and not range_locked
    if not high_locked and not na(form_hi)
        band_hi_wick := form_hi
        band_hi_top  := form_hibody
        high_locked  := true
    if not low_locked and not na(form_lo)
        band_lo_wick := form_lo
        band_lo_bot  := form_lobody
        low_locked   := true
    if high_locked and low_locked
        range_locked := true
        orb_high     := band_hi_wick
        orb_low      := band_lo_wick

just_locked = range_locked and not range_locked[1]

// create the two zone boxes on lock (right edge starts at the current bar)
if i_show_box and is15 and just_locked and not na(form_start_b) and not na(band_hi_wick) and not na(band_lo_wick)
    box_hi := box.new(form_start_b, band_hi_wick, bar_index, band_hi_top, border_color = color.new(i_col_hi, 0), bgcolor = color.new(i_col_hi, 85), border_width = 1, text = "ORB HIGH ZONE", text_color = color.new(i_col_hi, 0), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top)
    box_lo := box.new(form_start_b, band_lo_bot,  bar_index, band_lo_wick, border_color = color.new(i_col_lo, 0), bgcolor = color.new(i_col_lo, 85), border_width = 1, text = "ORB LOW ZONE",  text_color = color.new(i_col_lo, 0), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_bottom)

// ═══════════════════════════════════════════════════════════════════════════
// BREAKOUT — only AFTER price has pulled back INSIDE the range, then a candle
// CLOSES partially outside an edge (body beyond it, not just a wick).
// ═══════════════════════════════════════════════════════════════════════════
if is15 and range_locked and not inside_seen and not na(orb_high) and not na(orb_low) and close <= orb_high and close >= orb_low
    inside_seen := true
bo_up = inside_seen and close > orb_high and (close - orb_high) >= i_bo_frac * body
bo_dn = inside_seen and close < orb_low  and (orb_low - close)  >= i_bo_frac * body

if is15 and range_locked and in_trade and not na(orb_high) and not na(orb_low)
    if orb_bias == 0 and bo_up
        orb_bias := 1
    else if orb_bias == 0 and bo_dn
        orb_bias := -1
    else if orb_bias == 1 and bo_dn
        orb_bias := 2
    else if orb_bias == -1 and bo_up
        orb_bias := 2

// ═══════════════════════════════════════════════════════════════════════════
// ENTRY LEVEL — midpoint of high↔low (or nearest red line inside the range)
// ═══════════════════════════════════════════════════════════════════════════
orb_mid     = not na(orb_high) and not na(orb_low) ? (orb_high + orb_low) / 2 : na
rl_near_mid = na(orb_mid) ? na : math.round((orb_mid - i_offset) / i_step) * i_step + i_offset
use_rl      = i_prefer_rl and not na(rl_near_mid) and not na(orb_high) and not na(orb_low) and rl_near_mid <= orb_high and rl_near_mid >= orb_low
entry_level = use_rl ? rl_near_mid : orb_mid

// ═══════════════════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════════════════
breakout_done = orb_bias == 1 or orb_bias == -1
just_long     = orb_bias == 1  and ta.change(orb_bias) == 1
just_short    = orb_bias == -1 and ta.change(orb_bias) == -1
just_inval    = orb_bias == 2  and ta.change(orb_bias) != 0

crossed     = not na(entry_level) and low <= entry_level and high >= entry_level
retest_fire = is15 and range_locked and breakout_done and not retested and in_trade and crossed
if retest_fire
    retested := true

trade_ended = not in_trade and in_trade[1]
if trade_ended
    orb_bias := 0

// ═══════════════════════════════════════════════════════════════════════════
// EXTEND THE BOXES to the right until the TRADE STARTS, then FREEZE
// ═══════════════════════════════════════════════════════════════════════════
if is15 and not box_frozen and not na(box_hi)
    box.set_right(box_hi, bar_index)
    box.set_right(box_lo, bar_index)
if retest_fire or just_inval or trade_ended
    box_frozen := true

// ═══════════════════════════════════════════════════════════════════════════
// BACKGROUND — shade every day's 06:30 formation the same way
// ═══════════════════════════════════════════════════════════════════════════
bgcolor(i_shade_form and is15 and in_open ? color.new(color.orange, 80) : na, title = "06:30 candle")
bgcolor(i_shade_form and is15 and in_form ? color.new(color.blue,   92) : na, title = "Formation window")

// ═══════════════════════════════════════════════════════════════════════════
// PLOTS + MARKERS
// ═══════════════════════════════════════════════════════════════════════════
plot(i_show_mid and is15 and range_locked and breakout_done ? entry_level : na, "Entry / Retest level", color = color.new(color.yellow, 0), style = plot.style_linebr, linewidth = 2)

plotshape(just_long,  "Breakout Long",  shape.triangleup,   location.belowbar, color.new(color.green,  0), size = size.small, text = "BO")
plotshape(just_short, "Breakout Short", shape.triangledown, location.abovebar, color.new(color.red,    0), size = size.small, text = "BO")
plotshape(retest_fire and orb_bias == 1,  "Retest Long (entry)",  shape.labelup,   location.belowbar, color.new(color.lime,   0), size = size.small, text = "IN")
plotshape(retest_fire and orb_bias == -1, "Retest Short (entry)", shape.labeldown, location.abovebar, color.new(color.orange, 0), size = size.small, text = "IN")
plotshape(just_inval, "Invalidation", shape.xcross, location.abovebar, color.new(color.gray, 0), size = size.tiny, text = "X")

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(just_long,   "London Breakout Long",  "ALEX ORB: London breakout LONG bias")
alertcondition(just_short,  "London Breakout Short", "ALEX ORB: London breakout SHORT bias")
alertcondition(retest_fire, "London Mid Entry",      "ALEX ORB: price back at the midpoint - ENTER in the breakout direction")
alertcondition(just_inval,  "London Invalidation",   "ALEX ORB: opposite close - setup invalidated")
````
