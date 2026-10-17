# Time Zone

- url: https://www.tradingview.com/script/ZvsF4ryw/
- type: indicator
- pine_id: PUB;8e79c030a4974659b1e0de322fbb2762
- version: 1.0

## Description

Time zones custom. London, NY, Asia.
Time zones custom. London, NY, Asia.
Time zones custom. London, NY, Asia.

## Source Code

````pine
//@version=5
indicator("Time Zone", overlay=true, max_lines_count=500, max_labels_count=500)

// ===== INPUTS =====
group1 = "Sesión 1"
show1 = input.bool(true, "Mostrar sesión 1", group=group1, display=display.none)
name1 = input.string("Londres", "Nombre sesión 1", group=group1, display=display.none)
col1 = input.color(color.new(color.blue, 85), "Color fondo sesión 1", group=group1, display=display.none)
lineCol1 = input.color(color.blue, "Color líneas sesión 1", group=group1, display=display.none)
showBg1 = input.bool(true, "Pintar fondo sesión 1", group=group1, display=display.none)
showLines1 = input.bool(true, "Mostrar líneas sesión 1", group=group1, display=display.none)
showLabel1 = input.bool(true, "Mostrar etiqueta sesión 1", group=group1, display=display.none)

group2 = "Sesión 2"
show2 = input.bool(true, "Mostrar sesión 2", group=group2, display=display.none)
name2 = input.string("Nueva York", "Nombre sesión 2", group=group2, display=display.none)
col2 = input.color(color.new(color.red, 85), "Color fondo sesión 2", group=group2, display=display.none)
lineCol2 = input.color(color.red, "Color líneas sesión 2", group=group2, display=display.none)
showBg2 = input.bool(true, "Pintar fondo sesión 2", group=group2, display=display.none)
showLines2 = input.bool(true, "Mostrar líneas sesión 2", group=group2, display=display.none)
showLabel2 = input.bool(true, "Mostrar etiqueta sesión 2", group=group2, display=display.none)

group3 = "Opciones generales"
extendLines = input.bool(true, "Extender líneas verticales", group=group3, display=display.none)
lineStyleInput = input.string("Dashed", "Estilo líneas", options=["Solid", "Dashed", "Dotted"], group=group3, display=display.none)
lineWidth = input.int(1, "Grosor líneas", minval=1, maxval=5, group=group3, display=display.none)

// ===== ESTILO DE LÍNEA =====
lineStyle = lineStyleInput == "Solid" ? line.style_solid : lineStyleInput == "Dotted" ? line.style_dotted : line.style_dashed

// ===== HORA REAL LONDRES =====
lonHour = hour(time, "Europe/London")
lonMin = minute(time, "Europe/London")
lonAfterOpen = lonHour > 7 or (lonHour == 7 and lonMin >= 0)
lonBeforeClose = lonHour < 16
in1 = show1 and lonAfterOpen and lonBeforeClose

// ===== HORA REAL NUEVA YORK =====
nyHour = hour(time, "America/New_York")
nyMin = minute(time, "America/New_York")
nyAfterOpen = nyHour > 9 or (nyHour == 9 and nyMin >= 30)
nyBeforeClose = nyHour < 16
in2 = show2 and nyAfterOpen and nyBeforeClose

// ===== INICIO / FIN =====
start1 = in1 and not in1[1]
end1 = not in1 and in1[1]

start2 = in2 and not in2[1]
end2 = not in2 and in2[1]

// ===== FONDO =====
bgcolor(showBg1 and in1 ? col1 : na)
bgcolor(showBg2 and in2 ? col2 : na)

// ===== ALTURA LÍNEAS =====
atrValue = ta.atr(14)
lineLow = low - atrValue * 5
lineHigh = high + atrValue * 5
plotLow = extendLines ? lineLow : low
plotHigh = extendLines ? lineHigh : high

// ===== LONDRES =====
if showLines1 and start1
    line.new(x1=bar_index, y1=plotLow, x2=bar_index, y2=plotHigh, xloc=xloc.bar_index, extend=extend.none, color=lineCol1, style=lineStyle, width=lineWidth)

if showLines1 and end1
    line.new(x1=bar_index, y1=plotLow, x2=bar_index, y2=plotHigh, xloc=xloc.bar_index, extend=extend.none, color=lineCol1, style=lineStyle, width=lineWidth)

if showLabel1 and start1
    label.new(x=bar_index, y=high, text=name1, style=label.style_label_down, color=lineCol1, textcolor=color.white, size=size.small)

// ===== NUEVA YORK =====
if showLines2 and start2
    line.new(x1=bar_index, y1=plotLow, x2=bar_index, y2=plotHigh, xloc=xloc.bar_index, extend=extend.none, color=lineCol2, style=lineStyle, width=lineWidth)

if showLines2 and end2
    line.new(x1=bar_index, y1=plotLow, x2=bar_index, y2=plotHigh, xloc=xloc.bar_index, extend=extend.none, color=lineCol2, style=lineStyle, width=lineWidth)

if showLabel2 and start2
    label.new(x=bar_index, y=high, text=name2, style=label.style_label_down, color=lineCol2, textcolor=color.white, size=size.small)
````
