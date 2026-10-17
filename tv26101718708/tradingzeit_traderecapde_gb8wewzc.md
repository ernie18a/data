# Tradingzeit Traderecap.de

- url: https://www.tradingview.com/script/GB8wEwzc/
- type: indicator
- pine_id: PUB;e71e2ab439a74b55830b2c4bd94c759f
- version: 1.0

## Description

Tradingzeit Traderecap.de

Dieser Indikator zeichnet automatisch vertikale Linien zu frei wählbaren Uhrzeiten im Chart ein.

Funktionen
Einstellbare „Von“- und „Bis“-Uhrzeit
Frei wählbare Zeitzone
Individuelle Farben für Start- und Endlinie
Anpassbare Linienstärke
Funktioniert auf allen Intraday-Timeframes
Anwendung

Ideal zum Markieren von:

London Open
New York Open
Killzones
Newszeiten
Eigene Trading Sessions
Hinweise

Für die beste Genauigkeit empfiehlt sich die Nutzung auf kleineren Timeframes wie:
1m, 5m, 15m oder 30m.

Einstellungen
Zeitzone
Von Stunde/Minute
Bis Stunde/Minute
Linienfarben
Linienstärke

## Source Code

````pine
//@version=5
indicator("Tradingzeit Traderecap.de", overlay=true, max_lines_count=500)

timezoneInput = input.string("Europe/Berlin", "Zeitzone", options=["Europe/Berlin", "Etc/UTC", "America/New_York", "America/Chicago", "America/Los_Angeles", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney"])

startHour = input.int(9, "Von Stunde", minval=0, maxval=23)
startMin  = input.int(0, "Von Minute", minval=0, maxval=59)

endHour = input.int(16, "Bis Stunde", minval=0, maxval=23)
endMin  = input.int(0, "Bis Minute", minval=0, maxval=59)

startLineColor = input.color(color.rgb(195, 195, 195), "Von Linie")
endLineColor   = input.color(color.rgb(41, 40, 40), "Bis Linie")

lineWidth = input.int(2, "Linienstärke", minval=1, maxval=5)

curTotal  = hour(time, timezoneInput) * 60 + minute(time, timezoneInput)
prevTotal = hour(time[1], timezoneInput) * 60 + minute(time[1], timezoneInput)

startTotal = startHour * 60 + startMin
endTotal   = endHour * 60 + endMin

isStart = curTotal >= startTotal and prevTotal < startTotal
isEnd   = curTotal >= endTotal and prevTotal < endTotal

// Startlinie
if isStart
    line.new(
         bar_index,
         low,
         bar_index,
         high,
         extend=extend.both,
         color=startLineColor,
         width=lineWidth)

// Endlinie
if isEnd
    line.new(
         bar_index,
         low,
         bar_index,
         high,
         extend=extend.both,
         color=endLineColor,
         width=lineWidth)
````
