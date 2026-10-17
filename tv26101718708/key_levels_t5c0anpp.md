# Key Levels

- url: https://www.tradingview.com/script/t5c0AnPP-Key-Levels/
- type: indicator
- pine_id: PUB;a4c1ae449bda4b219e379298054b9a16
- version: 2.0

## Description

This indicator marks the key levels for you. Enjoy!

## Source Code

````pine
//@version=5
indicator(title='Key Levels', shorttitle='Key Levels', overlay=true)

// ─── TIMEZONE ─────────────────────────────────────────────────────────────────
tz = input.string("America/Chicago", "Timezone", options=["America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Sydney"])

// ─── DAILY LEVELS ─────────────────────────────────────────────────────────────
dailyhigh       = request.security(syminfo.tickerid, 'D', high)
dailylow        = request.security(syminfo.tickerid, 'D', low)
dayopen         = request.security(syminfo.tickerid, 'D', open)
previousdayhigh = request.security(syminfo.tickerid, 'D', high[1])
previousdaylow  = request.security(syminfo.tickerid, 'D', low[1])

// ─── OVERNIGHT HIGH / LOW (5:00 PM – 8:30 AM CT) ─────────────────────────────
t_on     = time("1440", "1700-0830", tz)
is_first = na(t_on[1]) and not na(t_on) or t_on[1] < t_on

end_hr  = 8
end_min = 30

on_high = float(na)
on_low  = float(na)

in_on_window = hour(time, tz) < end_hr or hour(time, tz) >= 17 or (hour(time, tz) == end_hr and minute(time, tz) < end_min)

if is_first and barstate.isnew and in_on_window
    on_high := high
    on_low  := low
else
    on_high := on_high[1]
    on_low  := on_low[1]

if high > on_high and in_on_window
    on_high := high

if low < on_low and in_on_window
    on_low := low

// ─── RTH OPEN (8:30 AM CT) ────────────────────────────────────────────────────
var float rth_open = na
t_rth_open = time(timeframe.period, "0830-0831", tz)
if not na(t_rth_open) and na(t_rth_open[1])
    rth_open := open
if is_first
    rth_open := na

// ─── RTH CLOSE: capture last bar before 3:00 PM CT ───────────────────────────
// Store close on every RTH bar; freezes at 3 PM when RTH session ends
var float rth_close      = na
var float rth_close_prev = na  // holds previous day's RTH close

in_rth = not na(time(timeframe.period, "0830-1500", tz))
was_rth = not na(time(timeframe.period, "0830-1500", tz)[1])

// While in RTH, keep updating rth_close with latest close
if in_rth
    rth_close := close

// When RTH ends (transition out), freeze it and save as prev
if was_rth and not in_rth
    rth_close_prev := rth_close

// Reset current rth_close at new overnight session
if is_first
    rth_close := na

// ─── GLOBEX CLOSE: capture last bar before 4:00 PM CT ────────────────────────
var float globex_close      = na
var float globex_close_prev = na  // holds previous day's Globex close

in_globex_close_window = not na(time(timeframe.period, "1500-1600", tz))
was_in_window          = not na(time(timeframe.period, "1500-1600", tz)[1])

if in_globex_close_window
    globex_close := close

if was_in_window and not in_globex_close_window
    globex_close_prev := globex_close

if is_first
    globex_close := na

// ─── LABEL OFFSET ─────────────────────────────────────────────────────────────
td = na(time[1]) ? 0 : time - time[1]
k  = -9999

// ─── PLOTS + LABELS ───────────────────────────────────────────────────────────
plot(dailyhigh,          'Day High',      color.new(#ffffff, 0), 1, trackprice=true, offset=k)
dh  = label.new(time + td, dailyhigh,          'Day High',      xloc=xloc.bar_time, style=label.style_none, textcolor=#ffffff, size=size.normal, textalign=text.align_center)
label.delete(dh[1])

plot(dailylow,           'Day Low',       color.new(#ffffff, 0), 1, trackprice=true, offset=k)
dl  = label.new(time + td, dailylow,           'Day Low',       xloc=xloc.bar_time, style=label.style_none, textcolor=#ffffff, size=size.normal, textalign=text.align_center)
label.delete(dl[1])

plot(previousdayhigh,    'Yd High',       color.new(#00ffff, 0), 1, trackprice=true, offset=k)
pdh = label.new(time + td, previousdayhigh,    'Yd High',       xloc=xloc.bar_time, style=label.style_none, textcolor=#00ffff, size=size.normal, textalign=text.align_center)
label.delete(pdh[1])

plot(previousdaylow,     'Yd Low',        color.new(#ff9800, 0), 1, trackprice=true, offset=k)
pdl = label.new(time + td, previousdaylow,     'Yd Low',        xloc=xloc.bar_time, style=label.style_none, textcolor=#ff9800, size=size.normal, textalign=text.align_center)
label.delete(pdl[1])

plot(rth_close_prev,     'Yd RTH Close',  color.new(#ffeb3b, 0), 1, trackprice=true, offset=k)
rc  = label.new(time + td, rth_close_prev,     'Yd RTH Close',  xloc=xloc.bar_time, style=label.style_none, textcolor=#ffeb3b, size=size.normal, textalign=text.align_center)
label.delete(rc[1])

plot(globex_close_prev,  'Yd Glbx Close', color.new(#ff9100, 0), 1, trackprice=true, offset=k)
gc  = label.new(time + td, globex_close_prev,  'Yd Glbx Close', xloc=xloc.bar_time, style=label.style_none, textcolor=#ff9100, size=size.normal, textalign=text.align_center)
label.delete(gc[1])

plot(dayopen,            'Globex Open',   color.new(#29b6f6, 0), 1, trackprice=true, offset=k)
go  = label.new(time + td, dayopen,            'Globex Open',   xloc=xloc.bar_time, style=label.style_none, textcolor=#29b6f6, size=size.normal, textalign=text.align_center)
label.delete(go[1])

plot(on_high,            'ON High',       color.new(#00e676, 0), 1, trackprice=true, offset=k)
onh = label.new(time + td, on_high,            'ON High',       xloc=xloc.bar_time, style=label.style_none, textcolor=#00e676, size=size.normal, textalign=text.align_center)
label.delete(onh[1])

plot(on_low,             'ON Low',        color.new(#ff1744, 0), 1, trackprice=true, offset=k)
onl = label.new(time + td, on_low,             'ON Low',        xloc=xloc.bar_time, style=label.style_none, textcolor=#ff1744, size=size.normal, textalign=text.align_center)
label.delete(onl[1])

plot(rth_open,           'RTH Open',      color.new(#e040fb, 0), 1, trackprice=true, offset=k)
ro  = label.new(time + td, rth_open,           'RTH Open',      xloc=xloc.bar_time, style=label.style_none, textcolor=#e040fb, size=size.normal, textalign=text.align_center)
label.delete(ro[1])
````
