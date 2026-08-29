<!-- tradingview-pine-id: PUB;1b03d553f68a4038b4af65b277e438c9 -->
<!-- tradingviewscripts-format: 1 -->
# NY Session Open Lines (00:00, 08:30 & 10:00)

Source: https://www.tradingview.com/script/6ClZvm9G-Important-Key-Opens/

## Description

Marks out the 8.30,10am and midnight open. Adjustable lines and tags.

---

## Source Code

````pine
//@version=6
indicator('NY Session Open Lines (00:00, 08:30 & 10:00)', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ============ EINSTELLUNGEN ============

// --- 00:00 NY Open ---
show00 = input.bool(true, '00:00 Linie anzeigen', group = '00:00 NY Open (Midnight Open)')
color00 = input.color(color.blue, 'Farbe', group = '00:00 NY Open (Midnight Open)')
name00 = input.string('Midnight Open', 'Name der Linie', group = '00:00 NY Open (Midnight Open)')
lineStyleIn00 = input.string('Durchgezogen', 'Linienstil', options = ['Durchgezogen', 'Gestrichelt', 'Gepunktet'], group = '00:00 NY Open (Midnight Open)')

// --- 08:30 NY Open ---
show0830 = input.bool(true, '08:30 Linie anzeigen', group = '08:30 NY Open')
color0830 = input.color(color.red, 'Farbe', group = '08:30 NY Open')
name0830 = input.string('08:30 Open', 'Name der Linie', group = '08:30 NY Open')
lineStyleIn0830 = input.string('Durchgezogen', 'Linienstil', options = ['Durchgezogen', 'Gestrichelt', 'Gepunktet'], group = '08:30 NY Open')

// --- 10:00 NY Open ---
show1000 = input.bool(true, '10:00 Linie anzeigen', group = '10:00 NY Open')
color1000 = input.color(color.orange, 'Farbe', group = '10:00 NY Open')
name1000 = input.string('10:00 Open', 'Name der Linie', group = '10:00 NY Open')
lineStyleIn1000 = input.string('Durchgezogen', 'Linienstil', options = ['Durchgezogen', 'Gestrichelt', 'Gepunktet'], group = '10:00 NY Open')

// --- Allgemein ---
lineWidth = input.int(1, 'Linienbreite', minval = 1, maxval = 5, group = 'Allgemein')
extendBars = input.int(0, 'Linien nach rechts verschieben (Anzahl Bars)', minval = 0, maxval = 5000, group = 'Allgemein')

lineStyle00 = lineStyleIn00 == 'Gestrichelt' ? line.style_dashed : lineStyleIn00 == 'Gepunktet' ? line.style_dotted : line.style_solid
lineStyle0830 = lineStyleIn0830 == 'Gestrichelt' ? line.style_dashed : lineStyleIn0830 == 'Gepunktet' ? line.style_dotted : line.style_solid
lineStyle1000 = lineStyleIn1000 == 'Gestrichelt' ? line.style_dashed : lineStyleIn1000 == 'Gepunktet' ? line.style_dotted : line.style_solid

// ============ ZEIT LOGIK (New York Zeit, berücksichtigt automatisch EST/EDT) ============

nyHour = hour(time, 'America/New_York')
nyMinute = minute(time, 'America/New_York')

is0000 = nyHour == 0 and nyMinute == 0
is0830 = nyHour == 8 and nyMinute == 30
is1000 = nyHour == 10 and nyMinute == 0

// nur auf 30min Timeframe und darunter anzeigen
tfSeconds = timeframe.in_seconds()
isVisibleTF = tfSeconds > 0 and tfSeconds <= 1800

// ============ LINIEN / LABEL VERWALTUNG ============

var line line00 = na
var label lbl00 = na
var line line0830 = na
var label lbl0830 = na
var line line1000 = na
var label lbl1000 = na

if isVisibleTF
    // ---- 10:00 Linie löschen um Mitternacht (nur heutiges 10:00 Open anzeigen) ----
    if is0000
        if not na(line1000)
            line.delete(line1000)
            line1000 := na
            line1000
        if not na(lbl1000)
            label.delete(lbl1000)
            lbl1000 := na
            lbl1000

    // ---- 00:00 Linie ----
    if is0000 and show00
        if not na(line00)
            line.delete(line00)
        if not na(lbl00)
            label.delete(lbl00)
        line00 := line.new(bar_index, open, bar_index + extendBars, open, xloc = xloc.bar_index, extend = extend.none, color = color00, width = lineWidth, style = lineStyle00)
        lbl00 := label.new(bar_index + extendBars, open, name00, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.white, 100), textcolor = color00, size = size.small)
        lbl00
    else if not na(line00)
        line.set_x2(line00, bar_index + extendBars)
        if not na(lbl00)
            label.set_x(lbl00, bar_index + extendBars)

    // ---- 08:30 Linie ----
    if is0830 and show0830
        if not na(line0830)
            line.delete(line0830)
        if not na(lbl0830)
            label.delete(lbl0830)
        line0830 := line.new(bar_index, open, bar_index + extendBars, open, xloc = xloc.bar_index, extend = extend.none, color = color0830, width = lineWidth, style = lineStyle0830)
        lbl0830 := label.new(bar_index + extendBars, open, name0830, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.white, 100), textcolor = color0830, size = size.small)
        lbl0830
    else if not na(line0830)
        line.set_x2(line0830, bar_index + extendBars)
        if not na(lbl0830)
            label.set_x(lbl0830, bar_index + extendBars)

    // ---- 10:00 Linie ----
    if is1000 and show1000
        if not na(line1000)
            line.delete(line1000)
        if not na(lbl1000)
            label.delete(lbl1000)
        line1000 := line.new(bar_index, open, bar_index + extendBars, open, xloc = xloc.bar_index, extend = extend.none, color = color1000, width = lineWidth, style = lineStyle1000)
        lbl1000 := label.new(bar_index + extendBars, open, name1000, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.white, 100), textcolor = color1000, size = size.small)
        lbl1000
    else if not na(line1000)
        line.set_x2(line1000, bar_index + extendBars)
        if not na(lbl1000)
            label.set_x(lbl1000, bar_index + extendBars)
else // Auf höheren Timeframes: vorhandene Zeichnungen entfernen
    if not na(line00)
        line.delete(line00)
        line00 := na
        line00
    if not na(lbl00)
        label.delete(lbl00)
        lbl00 := na
        lbl00
    if not na(line0830)
        line.delete(line0830)
        line0830 := na
        line0830
    if not na(lbl0830)
        label.delete(lbl0830)
        lbl0830 := na
        lbl0830
    if not na(line1000)
        line.delete(line1000)
        line1000 := na
        line1000
    if not na(lbl1000)
        label.delete(lbl1000)
        lbl1000 := na
        lbl1000
````
