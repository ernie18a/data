# TeimonXBT BTC CME Gaps

- url: https://www.tradingview.com/script/KuKzyUfY/
- type: indicator
- pine_id: PUB;f3f49665ac274531b1b7485f7959b79e
- version: 1.0

## Description

Automatically marks the CME Gap from Friday CME Close until Monday CME Open.

## Source Code

````pine
//@version=5
indicator("CME Gap Marker (Fr 22:45 - So 23:00 DE)", overlay=true, max_boxes_count=50, max_labels_count=50, max_lines_count=50)

// === Inputs ===
useDST        = input.bool(true,  "Sommerzeit (DST) aktiv?", tooltip="An = Berlin UTC+2 (Sommer). Aus = UTC+1 (Winter).")
startHourDE   = input.int(22, "Start Stunde (DE)",  minval=0, maxval=23)
startMinDE    = input.int(45, "Start Minute (DE)",  minval=0, maxval=59)
endHourDE     = input.int(23, "Ende Stunde (DE)",   minval=0, maxval=23)
endMinDE      = input.int(0,  "Ende Minute (DE)",   minval=0, maxval=59)

bullCol       = input.color(color.new(color.green, 65), "Farbe wenn Preis tiefer als Fr-Start")
bearCol       = input.color(color.new(color.red,   65), "Farbe wenn Preis hoeher als Fr-Start")
lineCol       = input.color(color.new(color.red,   0),  "Linienfarbe Fr-Start")
showLabel     = input.bool(true,  "Label 'CME Gap' anzeigen")

// === DE -> UTC Offset ===
offset = useDST ? 2 : 1
startHourUTC = startHourDE - offset
endHourUTC   = endHourDE   - offset

// === Zeit (UTC) ===
dow = dayofweek(time, "UTC")
hr  = hour(time, "UTC")
mn  = minute(time, "UTC")

nowMin   = hr * 60 + mn
startMin = startHourUTC * 60 + startMinDE
endMin   = endHourUTC   * 60 + endMinDE

// === Fenster ===
isFriStart = dow == dayofweek.friday and nowMin >= startMin
isSaturday = dow == dayofweek.saturday
isSunEnd   = dow == dayofweek.sunday and nowMin < endMin
inWindow   = isFriStart or isSaturday or isSunEnd

windowStart = inWindow and not inWindow[1]

// === State ===
var float startPrice = na
var int   startTime  = na   // fester Startzeitpunkt in ms
var int   endTime    = na   // fester Endzeitpunkt in ms (Sonntag 23:00 DE)
var line  refLine    = na
var label gapLabel   = na

if windowStart
    startPrice := close
    startTime  := time

    // Sonntag 23:00 DE als fester Endzeitpunkt:
    // wir suchen den naechsten Sonntag und setzen die Endzeit
    // einfacher: Startzeit + (Tage bis Sonntag) * 86400000 + Differenz Stunden/Minuten
    daysToSun = dow == dayofweek.friday ? 2 : dow == dayofweek.saturday ? 1 : 0
    // Mitternacht (UTC) des Sonntags berechnen
    sundayMidnight = (time - (hr * 3600000) - (mn * 60000)) + daysToSun * 86400000
    endTime := sundayMidnight + endHourUTC * 3600000 + endMinDE * 60000

    if not na(refLine)
        line.delete(refLine)
    if not na(gapLabel)
        label.delete(gapLabel)

    refLine := line.new(x1=startTime, y1=startPrice, x2=endTime, y2=startPrice, xloc=xloc.bar_time, extend=extend.none, color=lineCol, width=1, style=line.style_solid)

    if showLabel
        midTime = startTime + (endTime - startTime) / 2
        gapLabel := label.new(x=midTime, y=startPrice, text="CME Gap", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.black, 30), textcolor=color.white, size=size.small)

// === Fuellung ===
fillCol = inWindow and not na(startPrice) ? (close < startPrice ? bullCol : bearCol) : na

upper = inWindow ? startPrice : na
lower = inWindow ? close      : na

p1 = plot(upper, "Start-Linie", color=na, display=display.none)
p2 = plot(lower, "Preis",       color=na, display=display.none)
fill(p1, p2, color=fillCol, title="CME Gap Fill")

if not inWindow and inWindow[1]
    startPrice := na
````
