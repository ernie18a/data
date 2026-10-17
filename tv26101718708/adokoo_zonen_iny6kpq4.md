# Adokoo Zonen

- url: https://www.tradingview.com/script/InY6Kpq4/
- type: indicator
- pine_id: PUB;ce50cca0f4d2468ea1bf9e7b13b8fbe7
- version: 1.0

## Description

Dieser Indikator kombiniert Multi-Timeframe-Zonen, Trendfilter und Engulfing-Pattern in einem einzigen Werkzeug zur Marktanalyse.

Funktionen:

• Automatische Anzeige der aktuell stärksten 1H- und 4H-Zonen auf jedem Chart-Timeframe

• Darstellung der letzten vier Higher-Timeframe-Kerzen zur schnellen Marktstruktur- und Bias-Bewertung

• EMA 20 und EMA 50 zur Bestimmung des kurzfristigen und mittelfristigen Trends

• Erkennung von Bullish und Bearish Engulfing Patterns auf dem 15-Minuten-Chart

Anwendungsbeispiel:

Trendrichtung anhand der EMA 20/50 bestimmen
Reaktion des Preises an einer 1H- oder 4H-Zone beobachten
Auf ein 15-Minuten-Engulfing als Bestätigung warten
Trade in Trendrichtung ausführen

Der Indikator wurde entwickelt, um hochwertige Reaktionsbereiche mit einem klaren Trigger für den Einstieg zu kombinieren und dadurch die Chartanalyse zu vereinfachen.

## Source Code

````pine
//@version=6
indicator("Adokoo Zonen", overlay=true, max_boxes_count=100)

// ─────────────────────────────
// Inputs
// ─────────────────────────────
prd = input.int(10, "Pivot Period", minval=4, maxval=30)
ppsrc = input.string("High/Low", "Quelle", options=["High/Low", "Close/Open"])
channelW = input.int(2, "Maximum Channel Width %", minval=1, maxval=8)
minStrength = input.int(2, "Minimum Strength", minval=1)
maxZones = input.int(5, "Maximum Number of Zones", minval=1, maxval=5)
loopback = input.int(180, "Loopback Period", minval=100, maxval=400)

show1H = input.bool(true, "1H Zonen anzeigen")
show4H = input.bool(true, "4H Zonen anzeigen")

zone1HColor = input.color(color.new(color.blue, 85), "1H Zonenfarbe")
zone4HColor = input.color(color.new(color.purple, 80), "4H Zonenfarbe")

border1HColor = input.color(color.blue, "1H Rahmen")
border4HColor = input.color(color.purple, "4H Rahmen")

// ─────────────────────────────
// Channel Helper
// ─────────────────────────────
get_sr_vals(_pivots, _ind, _cwidth)=>
    float lo = array.get(_pivots, _ind)
    float hi = lo
    int numpp = 0

    for y = 0 to array.size(_pivots) - 1
        float cpp = array.get(_pivots, y)
        float wdth = cpp <= hi ? hi - cpp : cpp - lo

        if wdth <= _cwidth
            if cpp <= hi
                lo := math.min(lo, cpp)
            else
                hi := math.max(hi, cpp)

            numpp += 20

    [hi, lo, numpp]

changeit(_arr, x, y)=>
    tmp1 = array.get(_arr, y * 2)
    array.set(_arr, y * 2, array.get(_arr, x * 2))
    array.set(_arr, x * 2, tmp1)

    tmp2 = array.get(_arr, y * 2 + 1)
    array.set(_arr, y * 2 + 1, array.get(_arr, x * 2 + 1))
    array.set(_arr, x * 2 + 1, tmp2)

// ─────────────────────────────
// MTF Channel Berechnung
// ─────────────────────────────
f_channels()=>
    float src1 = ppsrc == "High/Low" ? high : math.max(close, open)
    float src2 = ppsrc == "High/Low" ? low : math.min(close, open)

    float ph = ta.pivothigh(src1, prd, prd)
    float pl = ta.pivotlow(src2, prd, prd)

    prdhighest = ta.highest(high, 300)
    prdlowest = ta.lowest(low, 300)
    cwidth = (prdhighest - prdlowest) * channelW / 100

    var pivotvals = array.new_float()
    var pivotlocs = array.new_int()

    var sr = array.new_float(20, 0.0)

    if not na(ph) or not na(pl)
        array.unshift(pivotvals, not na(ph) ? ph : pl)
        array.unshift(pivotlocs, bar_index)

        if array.size(pivotvals) > 0
            for x = array.size(pivotvals) - 1 to 0
                if bar_index - array.get(pivotlocs, x) > loopback
                    array.pop(pivotvals)
                    array.pop(pivotlocs)
                else
                    break

        supres = array.new_float()
        stren = array.new_float(10, 0.0)

        if array.size(pivotvals) > 0
            for x = 0 to array.size(pivotvals) - 1
                [hi, lo, strength] = get_sr_vals(pivotvals, x, cwidth)
                array.push(supres, strength)
                array.push(supres, hi)
                array.push(supres, lo)

            for x = 0 to array.size(pivotvals) - 1
                h = array.get(supres, x * 3 + 1)
                l = array.get(supres, x * 3 + 2)
                s = 0

                for y = 0 to loopback
                    if (high[y] <= h and high[y] >= l) or (low[y] <= h and low[y] >= l)
                        s += 1

                array.set(supres, x * 3, array.get(supres, x * 3) + s)

            array.fill(sr, 0.0)

            src = 0
            for x = 0 to array.size(pivotvals) - 1
                stv = -1.0
                stl = -1

                for y = 0 to array.size(pivotvals) - 1
                    if array.get(supres, y * 3) > stv and array.get(supres, y * 3) >= minStrength * 20
                        stv := array.get(supres, y * 3)
                        stl := y

                if stl >= 0
                    hh = array.get(supres, stl * 3 + 1)
                    ll = array.get(supres, stl * 3 + 2)

                    array.set(sr, src * 2, hh)
                    array.set(sr, src * 2 + 1, ll)
                    array.set(stren, src, array.get(supres, stl * 3))

                    for y = 0 to array.size(pivotvals) - 1
                        if (array.get(supres, y * 3 + 1) <= hh and array.get(supres, y * 3 + 1) >= ll) or (array.get(supres, y * 3 + 2) <= hh and array.get(supres, y * 3 + 2) >= ll)
                            array.set(supres, y * 3, -1)

                    src += 1

                    if src >= 10
                        break

            for x = 0 to 8
                for y = x + 1 to 9
                    if array.get(stren, y) > array.get(stren, x)
                        tmp = array.get(stren, y)
                        array.set(stren, y, array.get(stren, x))
                        array.set(stren, x, tmp)
                        changeit(sr, x, y)

    [
     array.get(sr, 0), array.get(sr, 1),
     array.get(sr, 2), array.get(sr, 3),
     array.get(sr, 4), array.get(sr, 5),
     array.get(sr, 6), array.get(sr, 7),
     array.get(sr, 8), array.get(sr, 9)
     ]

// ─────────────────────────────
// 1H + 4H Daten
// ─────────────────────────────
[h1t1, h1b1, h1t2, h1b2, h1t3, h1b3, h1t4, h1b4, h1t5, h1b5] =
     request.security(syminfo.tickerid, "60", f_channels(), lookahead=barmerge.lookahead_off)

[h4t1, h4b1, h4t2, h4b2, h4t3, h4b3, h4t4, h4b4, h4t5, h4b5] =
     request.security(syminfo.tickerid, "240", f_channels(), lookahead=barmerge.lookahead_off)

// ─────────────────────────────
// Boxen
// ─────────────────────────────
var h1Boxes = array.new_box(5)
var h4Boxes = array.new_box(5)

drawZones(_boxes, _show, _max, _c, _bc, _t1, _b1, _t2, _b2, _t3, _b3, _t4, _b4, _t5, _b5)=>
    tops = array.from(_t1, _t2, _t3, _t4, _t5)
    btms = array.from(_b1, _b2, _b3, _b4, _b5)

    for i = 0 to 4
        bx = array.get(_boxes, i)
        top = array.get(tops, i)
        btm = array.get(btms, i)

        valid = _show and i < _max and not na(top) and not na(btm) and top != 0 and btm != 0

        if valid
            if na(bx)
                bx := box.new(
                     left=bar_index,
                     top=top,
                     right=bar_index + 1,
                     bottom=btm,
                     bgcolor=_c,
                     border_color=_bc,
                     border_width=1,
                     extend=extend.both)

                array.set(_boxes, i, bx)
            else
                box.set_top(bx, top)
                box.set_bottom(bx, btm)
                box.set_left(bx, bar_index)
                box.set_right(bx, bar_index + 1)
                box.set_bgcolor(bx, _c)
                box.set_border_color(bx, _bc)
        else
            if not na(bx)
                box.delete(bx)
                array.set(_boxes, i, na)

// ─────────────────────────────
// Zeichnen
// ─────────────────────────────
drawZones(h1Boxes, show1H, maxZones, zone1HColor, border1HColor, h1t1, h1b1, h1t2, h1b2, h1t3, h1b3, h1t4, h1b4, h1t5, h1b5)

drawZones(h4Boxes, show4H, maxZones, zone4HColor, border4HColor, h4t1, h4b1, h4t2, h4b2, h4t3, h4b3, h4t4, h4b4, h4t5, h4b5)


// Funktion zur Identifizierung eines Bullish Engulfing
bullish_engulfing() =>
    is_bullish_engulfing = open[1] > close[1] ? close > open ? close >= open[1] ? close[1] >= open ? close - open > open[1] - close[1] ? true :false :false : false : false : false
    is_bullish_engulfing

// Funktion zur Identifizierung eines Bearish Engulfing
bearish_engulfing() =>
    is_bearish_engulfing = close[1] > open[1] ? open > close ? open >= close[1] ? open[1] >= close ? open - close > close[1] - open[1] ? true :false :false : false : false : false
    is_bearish_engulfing

// Nur für den M15-Chart aktiv
is_m15_chart = timeframe.period == "15"

// Prüfen, ob ein Bullish Engulfing Muster vorliegt
is_bullish_pattern = bullish_engulfing() and is_m15_chart

// Prüfen, ob ein Bearish Engulfing Muster vorliegt
is_bearish_pattern = bearish_engulfing() and is_m15_chart

period_to_monitor = input.timeframe(defval="15", title="Period of the candle you want to set an alert")
seconds_before_close = input.int(defval=60, title="Alert seconds before close")

// Calculate the remaining seconds of the current bar (the living one)
var float remaining_seconds = na
if (timeframe.isintraday and timeframe.period == period_to_monitor)
    remaining_seconds := (time_close(timeframe.period) - timenow) / 1000

// Alarm-Bedingung vor Kerzenschluss
five_min_before_close = remaining_seconds < seconds_before_close

// Alarm auslösen, wenn Bedingung erfüllt ist
alertcondition(is_bullish_pattern and five_min_before_close, title="Bullish Engulfing Alert", message="Bullish Engulfing erkannt!")
alertcondition(is_bearish_pattern and five_min_before_close, title="Bearish Engulfing Alert", message="Bearish Engulfing erkannt!")

// Visualisierung
barcolor(is_bullish_pattern ? color.new(color.green, 85) : na, title="Bullish Engulfing Hintergrund")
barcolor(is_bearish_pattern ? color.new(color.red, 85) : na, title="Bearish Engulfing Hintergrund")
// ─────────────────────────────
// EMA 20 / EMA 50
// ─────────────────────────────

showEMA = input.bool(true, "EMA 20/50 anzeigen")

ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)

plot(showEMA ? ema20 : na,
     title="EMA 20",
     color=color.red,
     linewidth=1)

plot(showEMA ? ema50 : na,
     title="EMA 50",
     color=color.blue,
     linewidth=1)

//@version=5
// ─────────────────────────────
// Inputs
// ─────────────────────────────
htf_opt = input.string("Auto", "HTF Selection", options=["Auto", "Fixed"], group="HTF")
htf_fixed = input.timeframe("240", "Fixed HTF", group="HTF")

show_candle = input.bool(true, "Show HTF Candle", group="HTF")
dx = input.int(0, "Start from ahead", group="HTF")

bull_color = input.color(color.rgb(255, 255, 255), "Bull Color", group="Colors")
bear_color = input.color(color.rgb(15, 15, 15), "Bear Color", group="Colors")
range_color = input.color(color.navy, "Range Color", group="Colors")
can_br_color = input.color(color.black, "Candles Border Color", group="Colors")

tf = timeframe.period

// ─────────────────────────────
// Auto HTF Auswahl
// ─────────────────────────────
f_look_tf(_tf)=>
    dtf =
         _tf == "15S" ? "5" :
         _tf == "1"   ? "15" :
         _tf == "2"   ? "60" :
         _tf == "3"   ? "30" :
         _tf == "5"   ? "60" :
         _tf == "15"  ? "240" :
         _tf == "30"  ? "720" :
         _tf == "60"  ? "1D" :
         _tf == "240" ? "1W" :
         _tf == "D"   ? "1M" :
         _tf == "W"   ? "3M" : _tf
    dtf

htf = htf_opt == "Auto" ? f_look_tf(tf) : htf_fixed

// ─────────────────────────────
// Text HTF
// ─────────────────────────────
f_text(string _tf)=>
    _text = str.tonumber(_tf) < 59 ? _tf + "m" :
         str.tonumber(_tf) > 59 ? "h" + str.tostring(math.floor(str.tonumber(_tf) / 60)) : _tf
    _text := _tf == "1D" ? "D" : _tf == "1W" ? "W" : _tf == "1M" ? "M" : _text

// ─────────────────────────────
// HTF Candle Tracking
// ─────────────────────────────
var o0 = open
var h0 = high
var l0 = low
var c0 = close

var o1 = open
var h1 = high
var l1 = low
var c1 = close

var o2 = open
var h2 = high
var l2 = low
var c2 = close

var o3 = open
var h3 = high
var l3 = low
var c3 = close

if timeframe.change(htf)
    o0 := open
    h0 := high
    l0 := low

if high >= h0
    h0 := high

if low <= l0
    l0 := low

c0 := close

if timeframe.change(htf)
    o1 := o0[1]
    h1 := h0[1]
    l1 := l0[1]
    c1 := close[1]

    o2 := o1[1]
    h2 := h1[1]
    l2 := l1[1]
    c2 := c1[1]

    o3 := o2[1]
    h3 := h2[1]
    l3 := l2[1]
    c3 := c2[1]

// ─────────────────────────────
// HTF Candles rechts anzeigen
// ─────────────────────────────
if show_candle and barstate.islast
    col0 = c0 > o0 ? bull_color : c0 < o0 ? bear_color : range_color
    col1 = c1 > o1 ? bull_color : c1 < o1 ? bear_color : range_color
    col2 = c2 > o2 ? bull_color : c2 < o2 ? bear_color : range_color
    col3 = c3 > o3 ? bull_color : c3 < o3 ? bear_color : range_color

    bl0 = box.new(left=bar_index+dx+18, top=c0, right=bar_index+dx+20, bottom=o0, bgcolor=col0, border_color=can_br_color, text=f_text(htf), text_size=size.tiny, text_valign=text.align_center, text_halign=text.align_center, text_color=color.white)
    wup0 = box.new(left=bar_index+dx+19, top=h0, right=bar_index+dx+19, bottom=math.max(o0,c0), border_color=can_br_color, border_width=1)
    wdw0 = box.new(left=bar_index+dx+19, top=l0, right=bar_index+dx+19, bottom=math.min(o0,c0), border_color=can_br_color, border_width=1)

    bl1 = box.new(left=bar_index+dx+15, top=c1, right=bar_index+dx+17, bottom=o1, bgcolor=col1, border_color=can_br_color, text=f_text(htf), text_size=size.tiny, text_valign=text.align_center, text_halign=text.align_center, text_color=color.white)
    wup1 = box.new(left=bar_index+dx+16, top=h1, right=bar_index+dx+16, bottom=math.max(o1,c1), border_color=can_br_color, border_width=1)
    wdw1 = box.new(left=bar_index+dx+16, top=l1, right=bar_index+dx+16, bottom=math.min(o1,c1), border_color=can_br_color, border_width=1)

    bl2 = box.new(left=bar_index+dx+12, top=c2, right=bar_index+dx+14, bottom=o2, bgcolor=col2, border_color=can_br_color, text=f_text(htf), text_size=size.tiny, text_valign=text.align_center, text_halign=text.align_center, text_color=color.white)
    wup2 = box.new(left=bar_index+dx+13, top=h2, right=bar_index+dx+13, bottom=math.max(o2,c2), border_color=can_br_color, border_width=1)
    wdw2 = box.new(left=bar_index+dx+13, top=l2, right=bar_index+dx+13, bottom=math.min(o2,c2), border_color=can_br_color, border_width=1)

    bl3 = box.new(left=bar_index+dx+9, top=c3, right=bar_index+dx+11, bottom=o3, bgcolor=col3, border_color=can_br_color, text=f_text(htf), text_size=size.tiny, text_valign=text.align_center, text_halign=text.align_center, text_color=color.white)
    wup3 = box.new(left=bar_index+dx+10, top=h3, right=bar_index+dx+10, bottom=math.max(o3,c3), border_color=can_br_color, border_width=1)
    wdw3 = box.new(left=bar_index+dx+10, top=l3, right=bar_index+dx+10, bottom=math.min(o3,c3), border_color=can_br_color, border_width=1)

    box.delete(bl0[1])
    box.delete(wup0[1])
    box.delete(wdw0[1])

    box.delete(bl1[1])
    box.delete(wup1[1])
    box.delete(wdw1[1])

    box.delete(bl2[1])
    box.delete(wup2[1])
    box.delete(wdw2[1])

    box.delete(bl3[1])
    box.delete(wup3[1])
    box.delete(wdw3[1])
````
