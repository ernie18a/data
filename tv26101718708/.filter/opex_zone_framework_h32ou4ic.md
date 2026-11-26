# OPEX Zone Framework

- url: https://www.tradingview.com/script/h32oU4ic-OPEX-Zone-Framework/
- type: indicator
- pine_id: PUB;5882a7e3d503469c86eb97519623d7ee
- version: 1.0

## Description

OPEX Zone Framework
Description:

A weekly options expiration framework for QQQ that translates dealer gamma positioning into five actionable price zones. Updated every Sunday. Personally, I use Barchart's Max Pain and Gamma Exposure data. (This code is neither endorsed by Barchart, nor am I, in any way affiliated with them) Works on all timeframes — zone logic is governed by daily closes only, never intraday wicks.
Five zones:

Extended (above Call Res 3) — no edge, dealers selling every rally
Bullish (Pin → Call Res 3) — long bias, three upside targets labeled
Buy Dip (Gamma Flip → Pin) — dip entries, stop below gamma flip
Stand Aside (Put Floor → Gamma Flip) — no man's land, wait for daily close
Short (below Put Floor on daily close) — short framework active, target deep support

Eight inputs (update every Sunday):

Expiry date · Pin/Max Pain · Gamma Flip · Put Floor · Deep Support · Call Resistance 1/2/3
Alerts included:

· Daily close below gamma flip 
· Daily close below put floor 
· Daily close reclaims gamma flip 
· Daily close above pin

Auto-disables after expiry Friday close with a stale notice. Applicable to any liquid ETF with options data — SPY gives the ES read using the same workflow.
My data source: Barchart Premier — Max Pain & Vol Skew (OI, not volume) + Gamma Exposure by expiry date.

## Source Code

````pine
//@version=6
indicator('OPEX Zone Framework', overlay = true, max_lines_count = 14, max_labels_count = 50)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
expiry_date = input.time(timestamp('2026-06-19 00:00:00'), 'Expiry Date (Friday)')
pin = input.float(720.00, 'Pin / Max Pain Strike', step = 0.5)
gamma_flip = input.float(718.57, 'Gamma Flip Level', step = 0.01)
put_floor = input.float(715.00, 'First Put Floor', step = 0.5)
deep_support = input.float(700.00, 'Deep Support', step = 0.5)
call_res = input.float(725.00, 'Call Resistance 1', step = 0.5)
call_res2 = input.float(730.00, 'Call Resistance 2', step = 0.5)
call_res3 = input.float(735.00, 'Call Resistance 3', step = 0.5)

// ─────────────────────────────────────────────
// ACTIVE WEEK LOGIC
// ─────────────────────────────────────────────
is_active = time <= expiry_date

// ─────────────────────────────────────────────
// DAILY CLOSE — pulled on all timeframes
// ─────────────────────────────────────────────
daily_close = request.security(syminfo.tickerid, 'D', close, lookahead = barmerge.lookahead_on)

// ─────────────────────────────────────────────
// ZONE LOGIC — based on daily close only
// ─────────────────────────────────────────────
zone_bullish = daily_close >= pin
zone_buy_dip = daily_close >= gamma_flip and daily_close < pin
zone_stand_aside = daily_close >= put_floor and daily_close < gamma_flip
zone_short = daily_close < put_floor

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
col_bullish = color.new(color.green, 88)
col_buy_dip = color.new(color.yellow, 88)
col_stand_aside = color.new(color.gray, 88)
col_short = color.new(color.red, 88)
col_extended = color.new(color.blue, 92)

// ─────────────────────────────────────────────
// BACKGROUND ZONE SHADING
// ─────────────────────────────────────────────
bgcolor(is_active and high > call_res3 ? col_extended : na, title = 'Extended Zone (above call resistance 3)')
bgcolor(is_active and zone_bullish and high <= call_res3 ? col_bullish : na, title = 'Bullish Zone (pin to call resistance 3)')
bgcolor(is_active and zone_buy_dip ? col_buy_dip : na, title = 'Buy Dip Zone (gamma flip to pin)')
bgcolor(is_active and zone_stand_aside ? col_stand_aside : na, title = 'Stand Aside Zone (put floor to gamma flip)')
bgcolor(is_active and zone_short ? col_short : na, title = 'Short Zone (below put floor)')

// ─────────────────────────────────────────────
// HORIZONTAL LINES
// ─────────────────────────────────────────────
var line l_call_res = na
var line l_call_res2 = na
var line l_call_res3 = na
var line l_pin = na
var line l_gamma_flip = na
var line l_put_floor = na
var line l_deep_sup = na

if barstate.islast and is_active
    line.delete(l_call_res)
    line.delete(l_call_res2)
    line.delete(l_call_res3)
    line.delete(l_pin)
    line.delete(l_gamma_flip)
    line.delete(l_put_floor)
    line.delete(l_deep_sup)
    l_call_res := line.new(bar_index - 100, call_res, bar_index + 20, call_res, color = color.green, width = 1, style = line.style_dashed)
    l_call_res2 := line.new(bar_index - 100, call_res2, bar_index + 20, call_res2, color = color.green, width = 1, style = line.style_dashed)
    l_call_res3 := line.new(bar_index - 100, call_res3, bar_index + 20, call_res3, color = color.green, width = 2, style = line.style_dashed)
    l_pin := line.new(bar_index - 100, pin, bar_index + 20, pin, color = color.white, width = 2, style = line.style_solid)
    l_gamma_flip := line.new(bar_index - 100, gamma_flip, bar_index + 20, gamma_flip, color = color.orange, width = 2, style = line.style_dashed)
    l_put_floor := line.new(bar_index - 100, put_floor, bar_index + 20, put_floor, color = color.red, width = 2, style = line.style_dashed)
    l_deep_sup := line.new(bar_index - 100, deep_support, bar_index + 20, deep_support, color = color.red, width = 3, style = line.style_solid)
    l_deep_sup

// ─────────────────────────────────────────────
// LABELS
// ─────────────────────────────────────────────
var label lbl_call_res = na
var label lbl_call_res2 = na
var label lbl_call_res3 = na
var label lbl_pin = na
var label lbl_gamma_flip = na
var label lbl_put_floor = na
var label lbl_deep_sup = na
var label lbl_status = na

if barstate.islast and is_active
    label.delete(lbl_call_res)
    label.delete(lbl_call_res2)
    label.delete(lbl_call_res3)
    label.delete(lbl_pin)
    label.delete(lbl_gamma_flip)
    label.delete(lbl_put_floor)
    label.delete(lbl_deep_sup)
    label.delete(lbl_status)
    lbl_call_res := label.new(bar_index + 2, call_res, 'CALL RES 1  ' + str.tostring(call_res, '#.##'), color = color.new(color.green, 80), textcolor = color.white, size = size.small, style = label.style_label_left)
    lbl_call_res2 := label.new(bar_index + 2, call_res2, 'CALL RES 2  ' + str.tostring(call_res2, '#.##'), color = color.new(color.green, 70), textcolor = color.white, size = size.small, style = label.style_label_left)
    lbl_call_res3 := label.new(bar_index + 2, call_res3, 'CALL RES 3  ' + str.tostring(call_res3, '#.##'), color = color.new(color.green, 60), textcolor = color.white, size = size.small, style = label.style_label_left)
    lbl_pin := label.new(bar_index + 2, pin, 'PIN  ' + str.tostring(pin, '#.##'), color = color.new(color.white, 70), textcolor = color.black, size = size.small, style = label.style_label_left)
    lbl_gamma_flip := label.new(bar_index + 2, gamma_flip, 'GFLIP  ' + str.tostring(gamma_flip, '#.##'), color = color.new(color.orange, 70), textcolor = color.white, size = size.small, style = label.style_label_left)
    lbl_put_floor := label.new(bar_index + 2, put_floor, 'PUT FLOOR  ' + str.tostring(put_floor, '#.##'), color = color.new(color.red, 70), textcolor = color.white, size = size.small, style = label.style_label_left)
    lbl_deep_sup := label.new(bar_index + 2, deep_support, 'DEEP SUP  ' + str.tostring(deep_support, '#.##'), color = color.new(color.red, 50), textcolor = color.white, size = size.small, style = label.style_label_left)

    zone_txt = zone_bullish ? 'BULLISH — targets ' + str.tostring(call_res, '#.##') + ' / ' + str.tostring(call_res2, '#.##') + ' / ' + str.tostring(call_res3, '#.##') : zone_buy_dip ? 'BUY DIP — stop below ' + str.tostring(gamma_flip, '#.##') : zone_stand_aside ? 'STAND ASIDE — wait for daily close' : zone_short ? 'SHORT — target ' + str.tostring(deep_support, '#.##') : 'EXTENDED — no edge above ' + str.tostring(call_res3, '#.##')
    zone_col = zone_bullish ? color.new(color.green, 60) : zone_buy_dip ? color.new(color.yellow, 60) : zone_stand_aside ? color.new(color.gray, 60) : zone_short ? color.new(color.red, 60) : color.new(color.blue, 60)

    lbl_status := label.new(bar_index + 2, close, 'OPEX ZONE: ' + zone_txt, color = zone_col, textcolor = color.white, size = size.normal, style = label.style_label_left)
    lbl_status

// ─────────────────────────────────────────────
// EXPIRED NOTICE
// ─────────────────────────────────────────────
var label lbl_expired = na

if barstate.islast and not is_active
    label.delete(lbl_expired)
    lbl_expired := label.new(bar_index, close, 'OPEX LEVELS STALE — update inputs for next expiry', color = color.new(color.gray, 60), textcolor = color.white, size = size.normal, style = label.style_label_left)
    lbl_expired

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
daily_close_current = request.security(syminfo.tickerid, 'D', close, lookahead = barmerge.lookahead_off)

alertcondition(ta.crossunder(daily_close_current, gamma_flip), 'Daily Close Below Gamma Flip', 'QQQ daily close below gamma flip — regime flips NEGATIVE GAMMA. Stand aside zone active.')
alertcondition(ta.crossunder(daily_close_current, put_floor), 'Daily Close Below Put Floor', 'QQQ daily close below put floor — SHORT framework active. Target deep support.')
alertcondition(ta.crossover(daily_close_current, gamma_flip), 'Daily Close Reclaims Gamma Flip', 'QQQ daily close reclaims gamma flip — long gamma restored. Bullish framework resumes.')
alertcondition(ta.crossover(daily_close_current, pin), 'Daily Close Above Pin', 'QQQ daily close above pin — bullish zone active. Target call resistance.')
````
