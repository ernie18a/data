# NY PDH/PDL/PDC + FBO

- url: https://www.tradingview.com/script/na2CIoIq-NY-PDH-PDL-PDC-FBO/
- type: indicator
- pine_id: PUB;9414e6bdfadf4bda9cc9c65a0788d897
- version: 1.0

## Description

Plots Previous Day High (PDH), Previous Day Low (PDL), and Previous Day Close (PDC) as labeled lines that follow price across the session. A white dot marks the first time price tags PDH or PDL.

Also detects Session Failed Breakouts (FBO): when price sweeps beyond an Asia or London session high/low then closes back inside, a pink dot marks the confirmation bar. Works on intraday timeframes only for Module B.

Session times default to UTC-4 (New York / EDT). To adjust for your timezone, go to Settings → Module B and update the session times manually. Alerts included for all signals.

**To set alerts: right-click the indicator name on the chart → Add alert, or use the Alert menu and select any of the named conditions from the dropdown.**

## Source Code

````pine
//@version=6
indicator("PDH/PDL/PDC + FBO", overlay=true)

// ============================================================
// MODULES ON/OFF
// ============================================================
moduleA_on = input.bool(true,  "Enable Module A (PDH / PDL / PDC)",          group="Modules")
moduleB_on = input.bool(true,  "Enable Module B (Session Failed Breakout)",   group="Modules")

// ============================================================
// MODULE A INPUTS — PDH / PDL / PDC
// ============================================================
show_pdh_line   = input.bool(true,           "Show PDH Line",             group="Module A: PDH / PDL / PDC")
show_pdl_line   = input.bool(true,           "Show PDL Line",             group="Module A: PDH / PDL / PDC")
show_pdc_line   = input.bool(true,           "Show PDC Line",             group="Module A: PDH / PDL / PDC")
pdh_color       = input.color(color.green,   "PDH Color",                 group="Module A: PDH / PDL / PDC")
pdl_color       = input.color(color.red,     "PDL Color",                 group="Module A: PDH / PDL / PDC")
pdc_color       = input.color(color.orange,  "PDC Color",                 group="Module A: PDH / PDL / PDC")
show_pdh_dot    = input.bool(true,           "Show PDH Tag Dot",          group="Module A: PDH / PDL / PDC")
show_pdl_dot    = input.bool(true,           "Show PDL Tag Dot",          group="Module A: PDH / PDL / PDC")
pdh_bg_on       = input.bool(false,          "PDH Background Highlight",  group="Module A: PDH / PDL / PDC")
pdl_bg_on       = input.bool(false,          "PDL Background Highlight",  group="Module A: PDH / PDL / PDC")

// ============================================================
// MODULE B INPUTS — SESSION 1
// ============================================================
// UTC-4 (NY time) session times:
//   Asia   → 2000-0400 (prior day 8pm to 4am)
//   London → 0300-1200
sess1_on        = input.bool(true,            "Enable Session 1",              group="Module B: Session 1")
sess1_name      = input.string("Asia",        "Session 1 Name",                group="Module B: Session 1")
sess1_time      = input.session("2000-0400",  "Session 1 Time (UTC-4 / NY)",   group="Module B: Session 1")
sess1_bull_bg   = input.bool(false,           "Bullish Background Highlight",  group="Module B: Session 1")
sess1_bear_bg   = input.bool(false,           "Bearish Background Highlight",  group="Module B: Session 1")

// ============================================================
// MODULE B INPUTS — SESSION 2
// ============================================================
sess2_on        = input.bool(true,            "Enable Session 2",              group="Module B: Session 2")
sess2_name      = input.string("London",      "Session 2 Name",                group="Module B: Session 2")
sess2_time      = input.session("0300-1200",  "Session 2 Time (UTC-4 / NY)",   group="Module B: Session 2")
sess2_bull_bg   = input.bool(false,           "Bullish Background Highlight",  group="Module B: Session 2")
sess2_bear_bg   = input.bool(false,           "Bearish Background Highlight",  group="Module B: Session 2")

// ============================================================
// TIMEZONE NOTE
// This version is hardcoded for UTC-4 (New York time, EDT):
//   Asia   → 2000-0400
//   London → 0300-1200
// If your chart is on a different timezone, adjust the
// session times in Settings → Module B Session 1/2.
// ============================================================

color FBO_COLOR = #FF69B4

// ============================================================
// MODULE A — PDH / PDL / PDC VALUES
// ============================================================
pdh = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
pdc = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

var line  pdh_line  = na
var line  pdl_line  = na
var line  pdc_line  = na
var label pdh_label = na
var label pdl_label = na
var label pdc_label = na
var int   day_start_bar = na

var label dot_slot0 = na
var label dot_slot1 = na

var label s1_bull_s0 = na
var label s1_bull_s1 = na
var label s1_bear_s0 = na
var label s1_bear_s1 = na
var label s2_bull_s0 = na
var label s2_bull_s1 = na
var label s2_bear_s0 = na
var label s2_bear_s1 = na

is_new_day = ta.change(time("D")) != 0
int STUB = 8

if moduleA_on and is_new_day
    day_start_bar := bar_index
    line.delete(pdh_line)
    line.delete(pdl_line)
    line.delete(pdc_line)
    label.delete(pdh_label)
    label.delete(pdl_label)
    label.delete(pdc_label)

    if show_pdh_line
        pdh_line  := line.new(bar_index, pdh, bar_index + STUB, pdh,
             extend=extend.none, color=pdh_color, width=2, style=line.style_solid)
        pdh_label := label.new(bar_index, pdh, "PDH",
             style=label.style_label_right,
             color=color.new(color.black, 100),
             textcolor=pdh_color,
             size=size.normal)

    if show_pdl_line
        pdl_line  := line.new(bar_index, pdl, bar_index + STUB, pdl,
             extend=extend.none, color=pdl_color, width=2, style=line.style_solid)
        pdl_label := label.new(bar_index, pdl, "PDL",
             style=label.style_label_right,
             color=color.new(color.black, 100),
             textcolor=pdl_color,
             size=size.normal)

    if show_pdc_line
        pdc_line  := line.new(bar_index, pdc, bar_index + STUB, pdc,
             extend=extend.none, color=pdc_color, width=2, style=line.style_solid)
        pdc_label := label.new(bar_index, pdc, "PDC",
             style=label.style_label_right,
             color=color.new(color.black, 100),
             textcolor=pdc_color,
             size=size.normal)

if moduleA_on and not is_new_day and not na(day_start_bar)
    if show_pdh_line and not na(pdh_line)
        line.set_x2(pdh_line, bar_index + STUB)
        label.set_x(pdh_label, bar_index)
    if show_pdl_line and not na(pdl_line)
        line.set_x2(pdl_line, bar_index + STUB)
        label.set_x(pdl_label, bar_index)
    if show_pdc_line and not na(pdc_line)
        line.set_x2(pdc_line, bar_index + STUB)
        label.set_x(pdc_label, bar_index)

pdh_tag = moduleA_on and high >= pdh and high[1] < pdh
pdl_tag = moduleA_on and low  <= pdl and low[1]  > pdl

if show_pdh_dot and pdh_tag
    label.delete(dot_slot0)
    dot_slot0 := dot_slot1
    dot_slot1 := label.new(bar_index, high, "●",
         style=label.style_label_down,
         color=color.new(color.black, 100),
         textcolor=color.white,
         size=size.small)

if show_pdl_dot and pdl_tag
    label.delete(dot_slot0)
    dot_slot0 := dot_slot1
    dot_slot1 := label.new(bar_index, low, "●",
         style=label.style_label_up,
         color=color.new(color.black, 100),
         textcolor=color.white,
         size=size.small)

bgcolor(pdh_bg_on and pdh_tag ? color.new(color.green, 85) : na, title="PDH BG")
bgcolor(pdl_bg_on and pdl_tag ? color.new(color.red,   85) : na, title="PDL BG")

// ============================================================
// MODULE B — SESSION FAILED BREAKOUT LOGIC
// ============================================================
isIntraday = timeframe.isintraday

f_session_hl(bool in_sess) =>
    var float sh         = na
    var float sl         = na
    var float frozen_sh  = na
    var float frozen_sl  = na
    var bool  was_active = false

    if in_sess
        if not was_active
            sh := high
            sl := low
        else
            sh := math.max(sh, high)
            sl := math.min(sl, low)
        was_active := true
    else
        if was_active
            frozen_sh := sh
            frozen_sl := sl
        was_active := false

    [frozen_sh, frozen_sl]

in_s1 = isIntraday and sess1_on and not na(time(timeframe.period, sess1_time))
in_s2 = isIntraday and sess2_on and not na(time(timeframe.period, sess2_time))

[s1h, s1l] = f_session_hl(in_s1)
[s2h, s2l] = f_session_hl(in_s2)

s1_bear = moduleB_on and sess1_on and isIntraday
         and not in_s1 and not na(s1h)
         and close[1] > s1h
         and close    < s1h

s1_bull = moduleB_on and sess1_on and isIntraday
         and not in_s1 and not na(s1l)
         and close[1] < s1l
         and close    > s1l

s2_bear = moduleB_on and sess2_on and isIntraday
         and not in_s2 and not na(s2h)
         and close[1] > s2h
         and close    < s2h

s2_bull = moduleB_on and sess2_on and isIntraday
         and not in_s2 and not na(s2l)
         and close[1] < s2l
         and close    > s2l

if s1_bull
    label.delete(s1_bull_s0)
    s1_bull_s0 := s1_bull_s1
    s1_bull_s1 := label.new(bar_index, low, "●",
         style=label.style_label_up,
         color=color.new(color.black, 100),
         textcolor=FBO_COLOR,
         size=size.small)

if s1_bear
    label.delete(s1_bear_s0)
    s1_bear_s0 := s1_bear_s1
    s1_bear_s1 := label.new(bar_index, high, "●",
         style=label.style_label_down,
         color=color.new(color.black, 100),
         textcolor=FBO_COLOR,
         size=size.small)

bgcolor(sess1_bull_bg and s1_bull ? color.new(color.green, 85) : na, title="S1 Bull BG")
bgcolor(sess1_bear_bg and s1_bear ? color.new(color.red,   85) : na, title="S1 Bear BG")

if s2_bull
    label.delete(s2_bull_s0)
    s2_bull_s0 := s2_bull_s1
    s2_bull_s1 := label.new(bar_index, low, "●",
         style=label.style_label_up,
         color=color.new(color.black, 100),
         textcolor=FBO_COLOR,
         size=size.small)

if s2_bear
    label.delete(s2_bear_s0)
    s2_bear_s0 := s2_bear_s1
    s2_bear_s1 := label.new(bar_index, high, "●",
         style=label.style_label_down,
         color=color.new(color.black, 100),
         textcolor=FBO_COLOR,
         size=size.small)

bgcolor(sess2_bull_bg and s2_bull ? color.new(color.green, 85) : na, title="S2 Bull BG")
bgcolor(sess2_bear_bg and s2_bear ? color.new(color.red,   85) : na, title="S2 Bear BG")

// ============================================================
// CATCH-ALL ALERT
// ============================================================
any_signal = pdh_tag or pdl_tag or s1_bull or s1_bear or s2_bull or s2_bear

alertcondition(any_signal and barstate.isconfirmed,
     title="Any Signal",
     message="Signal fired | {{ticker}} | Price: {{close}} | Time: {{time}}")

// ============================================================
// ALERTS
// ============================================================
alertcondition(pdh_tag and barstate.isconfirmed,
     title="PDH Tagged",
     message="PDH Tagged | {{ticker}} | Price: {{close}} | Time: {{time}}")

alertcondition(pdl_tag and barstate.isconfirmed,
     title="PDL Tagged",
     message="PDL Tagged | {{ticker}} | Price: {{close}} | Time: {{time}}")

alertcondition(s1_bull and barstate.isconfirmed,
     title="Session 1 — Bullish Failed Breakout",
     message="Bullish Failed Breakout | Session: Asia | {{ticker}} | Price: {{close}} | Time: {{time}}")

alertcondition(s1_bear and barstate.isconfirmed,
     title="Session 1 — Bearish Failed Breakout",
     message="Bearish Failed Breakout | Session: Asia | {{ticker}} | Price: {{close}} | Time: {{time}}")

alertcondition(s2_bull and barstate.isconfirmed,
     title="Session 2 — Bullish Failed Breakout",
     message="Bullish Failed Breakout | Session: London | {{ticker}} | Price: {{close}} | Time: {{time}}")

alertcondition(s2_bear and barstate.isconfirmed,
     title="Session 2 — Bearish Failed Breakout",
     message="Bearish Failed Breakout | Session: London | {{ticker}} | Price: {{close}} | Time: {{time}}")
````
