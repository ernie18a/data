# Timeline

- url: https://www.tradingview.com/script/YuSNFH6l/
- type: indicator
- pine_id: PUB;189d5e1d039a4b9592ead685528676cc
- version: 1.0

## Description

Custom Timeline
• Orario personalizzabile (ora e minuti)
• Gestione timezone dedicata indipendente dal broker/exchange
• Supporto multi mercato tramite selezione rapida del fuso orario:
Europe/Rome
America/New_York
UTC
Asia/Tokyo
Asia/Hong_Kong
Australia/Sydney
• Personalizzazione grafica completa:
colore linea
spessore
stile (continua, tratteggiata, puntinata)
• Possibilità di limitare il numero massimo di linee visualizzate
L’indicatore utilizza il timezone selezionato direttamente nel calcolo dell’orario, garantendo maggiore coerenza tra strumenti differenti, CFD, futures, forex e crypto.

## Source Code

````pine
//@version=5
indicator("Timeline", overlay=true, max_lines_count=500)

//=========================
// INPUT
//=========================

nLines = input.int(20, "Numero linee", minval=1, maxval=500)

targetHour = input.int(8, "Ora", minval=0, maxval=23)
targetMinute = input.int(0, "Minuto", minval=0, maxval=59)

tz = input.string("Europe/Rome", "Fuso orario", options=[ "Europe/Rome", "America/New_York", "UTC", "Asia/Tokyo","Asia/Hong_Kong","Australia/Sydney"])

lineColor = input.color(color.red, "Colore linea")
lineWidth = input.int(1, "Spessore", minval=1, maxval=5)

lineStyleInput = input.string("Dashed", "Stile linea", options=["Solid", "Dashed", "Dotted"])

lineStyle = switch lineStyleInput
    "Solid" => line.style_solid
    "Dashed" => line.style_dashed
    => line.style_dotted

//=========================
// CONDIZIONE ORARIA
//=========================

curHour = hour(time, tz)
curMinute = minute(time, tz)

isTargetBar = curHour == targetHour and curMinute == targetMinute

//=========================
// STORAGE
//=========================

var line[] vLines = array.new_line()

//=========================
// DISEGNO
//=========================

if isTargetBar

    l = line.new(x1=bar_index, y1=low - ta.atr(14) * 5, x2=bar_index, y2=high + ta.atr(14) * 5, xloc=xloc.bar_index, extend=extend.both, color=lineColor, style=lineStyle, width=lineWidth)

    array.push(vLines, l)

    if array.size(vLines) > nLines
        oldLine = array.shift(vLines)
        line.delete(oldLine)
````
