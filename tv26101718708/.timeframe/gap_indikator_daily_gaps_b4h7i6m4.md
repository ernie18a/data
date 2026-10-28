# Gap Indikator (Daily Gaps)

- url: https://www.tradingview.com/script/B4H7I6m4/
- type: indicator
- pine_id: PUB;b33471b9a5674dc4afcf3b1cebaf85dd
- version: 1.0

## Description

This is an indicator showing all support/resistance gaps on the daily chart, with the logic of gap filling from Nick Drendel

## Source Code

````pine
//@version=5
indicator("Gap Indikator (Daily Gaps)", overlay=true, max_boxes_count=500)

// ── Einstellungen ───────────────────────────────────────
colorGray  = input.color(color.new(color.gray,  92), "Ungefüllt")
colorGreen = input.color(color.new(color.green, 92), "Gefüllt – unterhalb Preis")
colorRed   = input.color(color.new(color.red,   92), "Gefüllt – oberhalb Preis")
maxDist    = input.float(30.0, "Max. Distanz vom Preis (%)", minval=1.0, maxval=100.0, step=1.0)

// ── Daily Daten holen ───────────────────────────────────
dClose = request.security(syminfo.tickerid, "D", close, lookahead=barmerge.lookahead_off)
dOpen  = request.security(syminfo.tickerid, "D", open,  lookahead=barmerge.lookahead_off)
dHigh  = request.security(syminfo.tickerid, "D", high,  lookahead=barmerge.lookahead_off)
dLow   = request.security(syminfo.tickerid, "D", low,   lookahead=barmerge.lookahead_off)

isNewDay = ta.change(time("D")) != 0

// ── Arrays ──────────────────────────────────────────────
var box[]   gapBoxes  = array.new_box()
var bool[]  gapBull   = array.new_bool()
var float[] gapTop    = array.new_float()
var float[] gapBot    = array.new_float()
var bool[]  gapFilled = array.new_bool()

// ── Neuen Gap anlegen (am Start von Day 3) ───────────────
if isNewDay
    prevClose = dClose[2]  // Close Day 1
    day2Open  = dOpen[1]   // Open Day 2
    day2High  = dHigh[1]   // High Day 2
    day2Low   = dLow[1]    // Low Day 2

    // Up Gap:   Close Day1 → Low Day2   (Lücke zwischen Close D1 und Tief D2)
    if day2Open > prevClose and day2Low > prevClose
        gapT = day2Low
        gapB = prevClose
        b = box.new(bar_index, gapT, bar_index + 1, gapB, border_color=color.new(color.gray, 100), bgcolor=colorGray, border_width=0)
        array.push(gapBoxes,  b)
        array.push(gapBull,   true)
        array.push(gapTop,    gapT)
        array.push(gapBot,    gapB)
        array.push(gapFilled, false)

    // Down Gap: High Day2 → Close Day1  (Lücke zwischen Hoch D2 und Close D1)
    if day2Open < prevClose and day2High < prevClose
        gapT = prevClose
        gapB = day2High
        b = box.new(bar_index, gapT, bar_index + 1, gapB, border_color=color.new(color.gray, 100), bgcolor=colorGray, border_width=0)
        array.push(gapBoxes,  b)
        array.push(gapBull,   false)
        array.push(gapTop,    gapT)
        array.push(gapBot,    gapB)
        array.push(gapFilled, false)

// ── Boxen verwalten ─────────────────────────────────────
if array.size(gapBoxes) > 0
    i = array.size(gapBoxes) - 1
    while i >= 0
        top    = array.get(gapTop,    i)
        bot    = array.get(gapBot,    i)
        bull   = array.get(gapBull,   i)
        b      = array.get(gapBoxes,  i)
        filled = array.get(gapFilled, i)

        midpoint = (top + bot) / 2

        // ── Distanzfilter ────────────────────────────────
        distPct = math.abs(close - midpoint) / close * 100
        inRange = distPct <= maxDist

        // ── Farbe: wechselt sobald Intraday-Kurs in Box läuft ──
        intradayInBox = high > bot and low < top

        if intradayInBox and not filled
            array.set(gapFilled, i, true)
            filled := true

        // ── Box schrumpfen: NUR per Schlusskurs ──────────
        if isNewDay
            prevC = dClose[1]
            if bull
                // Up Gap: Preis füllt von oben nach unten → Top sinkt
                if prevC < top and prevC > bot
                    array.set(gapTop, i, prevC)
                    box.set_top(b, prevC)
            else
                // Down Gap: Preis füllt von unten nach oben → Bot steigt
                if prevC > bot and prevC < top
                    array.set(gapBot, i, prevC)
                    box.set_bottom(b, prevC)

        // ── Komplett gefüllt per Schlusskurs? → löschen ──
        fullyFilled = bull ? dClose[1] <= bot : dClose[1] >= top

        if isNewDay and fullyFilled
            box.delete(b)
            array.remove(gapBoxes,  i)
            array.remove(gapBull,   i)
            array.remove(gapTop,    i)
            array.remove(gapBot,    i)
            array.remove(gapFilled, i)
        else
            box.set_right(b, bar_index + 1)

            // ── Farbe setzen ──────────────────────────────
            if not inRange
                box.set_bgcolor(b, color.new(color.black, 100))
            else if not filled
                box.set_bgcolor(b, colorGray)
            else if close > midpoint
                box.set_bgcolor(b, colorGreen)
            else
                box.set_bgcolor(b, colorRed)

        i -= 1
````
