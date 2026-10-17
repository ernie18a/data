# 0W/1W Siggi (v10) - Ultimativ

- url: https://www.tradingview.com/script/owChwWol/
- type: indicator
- pine_id: PUB;2451b9ae3f9b46668cb0056a6bf7c12f
- version: 1.0

## Description

nowich und one wick in 5 farben und labels ettiketuerbar

## Source Code

````pine
//@version=6
indicator("0W/1W Siggi (v10) - Ultimativ", overlay=true)

// ==========================================
// 1. EINSTELLUNGEN
// ==========================================
group_nw = "1. NoWick (Gar kein Docht)"
c_nw_bull = input.color(color.new(#00ffaa, 0), "Farbe Bullisch", group=group_nw)
c_nw_bear = input.color(color.new(#ff0055, 0), "Farbe Bärisch", group=group_nw)

group_ow_top = "2. OneWick: Oben Rasiert (Docht nur UNTEN)"
c_ow_top_bull = input.color(color.new(#00aaff, 0), "Farbe Bullisch", group=group_ow_top)
c_ow_top_bear = input.color(color.new(#ffaa00, 0), "Farbe Bärisch", group=group_ow_top)

group_ow_bot = "3. OneWick: Unten Rasiert (Docht nur OBEN)"
c_ow_bot_bull = input.color(color.new(#7a00ff, 0), "Farbe Bullisch", group=group_ow_bot)
c_ow_bot_bear = input.color(color.new(#ff5500, 0), "Farbe Bärisch", group=group_ow_bot)

group_alarm = "Alarm Einstellungen"
early_seconds = input.int(60, "Alarm X Sekunden vor Ende", minval=1, group=group_alarm)
tick_tolerance = input.int(0, "Tick-Toleranz", minval=0)

// ==========================================
// 2. LOGIK
// ==========================================
tick_size = syminfo.mintick
max_allowed_wick = tick_tolerance * tick_size

top_wick_size = high - math.max(open, close)
bot_wick_size = math.min(open, close) - low

is_nw_bull     = (top_wick_size <= max_allowed_wick and bot_wick_size <= max_allowed_wick) and close >= open
is_nw_bear     = (top_wick_size <= max_allowed_wick and bot_wick_size <= max_allowed_wick) and close < open
is_ow_top_bull = (top_wick_size <= max_allowed_wick and bot_wick_size > max_allowed_wick) and close >= open
is_ow_top_bear = (top_wick_size <= max_allowed_wick and bot_wick_size > max_allowed_wick) and close < open
is_ow_bot_bull = (top_wick_size > max_allowed_wick and bot_wick_size <= max_allowed_wick) and close >= open
is_ow_bot_bear = (top_wick_size > max_allowed_wick and bot_wick_size <= max_allowed_wick) and close < open

is_any_signal = is_nw_bull or is_nw_bear or is_ow_top_bull or is_ow_top_bear or is_ow_bot_bull or is_ow_bot_bear

// ==========================================
// 3. OPTIK (Labels nur bei Kerzenschluss)
// ==========================================
barcolor(barstate.isconfirmed ? (is_nw_bull ? c_nw_bull : is_nw_bear ? c_nw_bear : is_ow_top_bull ? c_ow_top_bull : is_ow_top_bear ? c_ow_top_bear : is_ow_bot_bull ? c_ow_bot_bull : is_ow_bot_bear ? c_ow_bot_bear : na) : na)

plotshape(barstate.isconfirmed and is_nw_bull, style=shape.triangleup, location=location.belowbar, color=c_nw_bull, size=size.small)
plotshape(barstate.isconfirmed and is_nw_bear, style=shape.triangledown, location=location.abovebar, color=c_nw_bear, size=size.small)
plotshape(barstate.isconfirmed and is_ow_top_bull, style=shape.arrowup, location=location.belowbar, color=c_ow_top_bull, size=size.small)
plotshape(barstate.isconfirmed and is_ow_top_bear, style=shape.arrowdown, location=location.abovebar, color=c_ow_top_bear, size=size.small)
plotshape(barstate.isconfirmed and is_ow_bot_bull, style=shape.circle, location=location.belowbar, color=c_ow_bot_bull, size=size.small)
plotshape(barstate.isconfirmed and is_ow_bot_bear, style=shape.cross, location=location.abovebar, color=c_ow_bot_bear, size=size.small)

// ==========================================
// 4. LATCHED-ALARM (Einrast-Logik)
// ==========================================
var bool alarm_fired_on_bar = false
if barstate.isnew
    alarm_fired_on_bar := false

remaining_ms = time_close - timenow

if not alarm_fired_on_bar and remaining_ms <= (early_seconds * 1000) and remaining_ms > 0
    // Live-Prüfung: Ist das Signal in diesem Tick gültig?
    if is_any_signal
        alert("Frühwarnung: Signal aktiv (" + str.tostring(early_seconds) + "s vor Ende)!", alert.freq_once_per_bar)
        alarm_fired_on_bar := true

// Dummy für das Alarm-Menü
alertcondition(alarm_fired_on_bar, title="--> HIER WÄHLEN FÜR FRÜHWARNUNG <--", message="Signal aktiv!")
````
