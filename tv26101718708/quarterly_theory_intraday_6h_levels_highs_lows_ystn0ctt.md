# Quarterly Theory: Intraday 6H Levels Highs & Lows

- url: https://www.tradingview.com/script/ysTn0cTt-Quarterly-Theory-Intraday-6H-Levels-Highs-Lows/
- type: indicator
- pine_id: PUB;6a81ad9e56fb4d5fb72a54290268cc7e
- version: 1.0

## Description

It drows Highs & Lows of 6Hours sessions till they are mitigated.
Lines expires after 24 hours

## Source Code

````pine
// © Richard Bvuwayi - Modificato per inserimento livelli 6H
// @version=6
indicator("Quarterly Theory: Intraday Quarters + 6H Levels",
     overlay = true,
     max_bars_back = 500,
     max_lines_count = 500,
     max_boxes_count = 500,
     max_labels_count = 500)

//------------------------------------------------------------------------------
// SESSIONI 6H
//------------------------------------------------------------------------------
sesq_ses = "1800-0000"
sesr_ses = "0000-0600"
sess_ses = "0600-1200"
sest_ses = "1200-1800"

TZ = "America/New_York"

tf = timeframe.period

// FIX: conversione esplicita a boolean
is_sesq = math.sign(nz(time(tf, sesq_ses, TZ))) != 0
is_sesr = math.sign(nz(time(tf, sesr_ses, TZ))) != 0
is_sess = math.sign(nz(time(tf, sess_ses, TZ))) != 0
is_sest = math.sign(nz(time(tf, sest_ses, TZ))) != 0

//------------------------------------------------------------------------------
// INPUT
//------------------------------------------------------------------------------
show6HLevels = input.bool(true, "Mostra livelli 6H")

name6HHigh = input.string("6H HIGH", "Nome massimo")
name6HLow  = input.string("6H LOW", "Nome minimo")

color6HHigh = input.color(color.red, "Colore massimo")
color6HLow  = input.color(color.green, "Colore minimo")

//------------------------------------------------------------------------------
// LOGICA 6H
//------------------------------------------------------------------------------
var float h6 = na
var float l6 = na
var int active_6h_id = 0

// FIX ERRORE OPERATORE ?:
// gli is_ses* devono essere boolean
int current_6h_id =
     is_sesq ? 1 :
     is_sesr ? 2 :
     is_sess ? 3 :
     is_sest ? 4 : 0

// Arrays HIGH
var line[] h6_lines = array.new_line()
var label[] h6_labels = array.new_label()
var int[] h6_expiry = array.new_int()

// Arrays LOW
var line[] l6_lines = array.new_line()
var label[] l6_labels = array.new_label()
var int[] l6_expiry = array.new_int()

// Fine giorno successivo
f_get_expiry() =>
    int y = year(time, TZ)
    int m = month(time, TZ)
    int d = dayofmonth(time, TZ)

    timestamp(TZ, y, m, d + 1, 23, 59)

//------------------------------------------------------------------------------
// CREAZIONE LIVELLI
//------------------------------------------------------------------------------
if show6HLevels

    if current_6h_id != 0

        if current_6h_id != active_6h_id

            if active_6h_id != 0 and not na(h6)

                int expiry_time = f_get_expiry()

                // HIGH
                line h_ln = line.new(
                     x1 = bar_index,
                     y1 = h6,
                     x2 = bar_index + 1,
                     y2 = h6,
                     color = color6HHigh,
                     width = 1)

                label h_lb = label.new(
                     x = bar_index,
                     y = h6,
                     text = name6HHigh,
                     style = label.style_label_left,
                     textcolor = color6HHigh,
                     color = color.new(color.white, 100),
                     size = size.tiny)

                array.push(h6_lines, h_ln)
                array.push(h6_labels, h_lb)
                array.push(h6_expiry, expiry_time)

                // LOW
                line l_ln = line.new(
                     x1 = bar_index,
                     y1 = l6,
                     x2 = bar_index + 1,
                     y2 = l6,
                     color = color6HLow,
                     width = 1)

                label l_lb = label.new(
                     x = bar_index,
                     y = l6,
                     text = name6HLow,
                     style = label.style_label_left,
                     textcolor = color6HLow,
                     color = color.new(color.white, 100),
                     size = size.tiny)

                array.push(l6_lines, l_ln)
                array.push(l6_labels, l_lb)
                array.push(l6_expiry, expiry_time)

            h6 := high
            l6 := low
            active_6h_id := current_6h_id

        else

            h6 := math.max(h6, high)
            l6 := math.min(l6, low)

//------------------------------------------------------------------------------
// GESTIONE HIGH
//------------------------------------------------------------------------------
if array.size(h6_lines) > 0

    for i = array.size(h6_lines) - 1 to 0

        line ln = array.get(h6_lines, i)
        label lb = array.get(h6_labels, i)
        int expiry = array.get(h6_expiry, i)

        float val = line.get_y1(ln)

        line.set_x2(ln, bar_index)
        label.set_x(lb, bar_index)

        bool touched = low <= val and high >= val
        bool expired = time > expiry

        if touched or expired

            line.set_x2(ln, bar_index)

            array.remove(h6_lines, i)
            array.remove(h6_labels, i)
            array.remove(h6_expiry, i)

//------------------------------------------------------------------------------
// GESTIONE LOW
//------------------------------------------------------------------------------
if array.size(l6_lines) > 0

    for i = array.size(l6_lines) - 1 to 0

        line ln = array.get(l6_lines, i)
        label lb = array.get(l6_labels, i)
        int expiry = array.get(l6_expiry, i)

        float val = line.get_y1(ln)

        line.set_x2(ln, bar_index)
        label.set_x(lb, bar_index)

        bool touched = low <= val and high >= val
        bool expired = time > expiry

        if touched or expired

            line.set_x2(ln, bar_index)

            array.remove(l6_lines, i)
            array.remove(l6_labels, i)
            array.remove(l6_expiry, i)
````
