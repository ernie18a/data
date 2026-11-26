# x4 mm black po

- url: https://www.tradingview.com/script/MxuERv5E/
- type: indicator
- pine_id: PUB;7e0473d5c7914714b5566610b51324a5
- version: 1.0

## Description

x4 mm black po by 221, Danimanipulation e Matte, based on mm model 4 black project

## Source Code

````pine
//@version=6
// =============================================================================
// Day Labels - TradingView port
// Original: "Day Labels (4).ex4"
// Disegna verticali e label con il nome del giorno (MON/TUE/WED/THU/FRI/SAT/SUN)
// all'inizio di ogni nuovo giorno. Utile su intraday.
// =============================================================================
indicator("x4 mm black po", overlay=true, max_lines_count=500, max_labels_count=500)

showLine   = input.bool(true,  "Linea verticale a inizio giorno")
showLabel  = input.bool(true,  "Label nome giorno")
labelPos   = input.string("top", "Posizione label", options=["top","bottom"])
lineCol    = input.color(color.new(color.gray, 60), "Color linea")
lineStyle  = input.string("dashed", "Stile linea", options=["solid","dashed","dotted"])
lblCol     = input.color(color.new(color.blue, 30), "Color label")
useShort   = input.bool(true,  "Nomi corti (MON/TUE/...)")
markFriday = input.bool(true,  "Evidenzia venerdì")
markSunday = input.bool(true,  "Evidenzia domenica (apertura settimana)")

isNewDay = ta.change(time("D")) != 0

dayName(d) =>
    short = useShort
    d == 1 ? (short ? "SUN" : "Sunday") : d == 2 ? (short ? "MON" : "Monday") : d == 3 ? (short ? "TUE" : "Tuesday") : d == 4 ? (short ? "WED" : "Wednesday") : d == 5 ? (short ? "THU" : "Thursday") : d == 6 ? (short ? "FRI" : "Friday") : (short ? "SAT" : "Saturday")

lstyle = lineStyle == "solid" ? line.style_solid : lineStyle == "dotted" ? line.style_dotted : line.style_dashed

if isNewDay
    dow = dayofweek(time)
    nm  = dayName(dow)
    spec = (markFriday and dow == 6) or (markSunday and dow == 1)
    if showLine
        line.new(bar_index, low - syminfo.mintick*50, bar_index, high + syminfo.mintick*50,
                 xloc=xloc.bar_index, extend=extend.both,
                 color=spec ? color.new(color.orange, 30) : lineCol,
                 style=lstyle, width=spec ? 2 : 1)
    if showLabel
        ypos = labelPos == "top" ? high : low
        st   = labelPos == "top" ? label.style_label_down : label.style_label_up
        label.new(bar_index, ypos, nm,
                  style=st,
                  color=spec ? color.new(color.orange, 0) : lblCol,
                  textcolor=color.white, size=size.small)
````
