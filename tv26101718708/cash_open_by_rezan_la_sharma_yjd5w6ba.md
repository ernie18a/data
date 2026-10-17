# Cash Open by Rezan La Sharma

- url: https://www.tradingview.com/script/yJd5W6bA/
- type: indicator
- pine_id: PUB;a2607270f681453e8f3511c9ead34621
- version: 1.0

## Description

Dieser Indikator markiert automatisch jeden Handelstag den Cash Open – also den Eröffnungszeitpunkt der regulären Handelssitzung – mit einer vertikalen Linie und einem Label direkt am Chart.
Standardmäßig ist der New Yorker Cash Open um 9:30 AM (NY-Zeit) eingestellt. Optional lässt sich zusätzlich der London Cash Open (8:00 Uhr London-Zeit) einschalten, jeweils mit eigener Farbe, eigenem Text und eigenem Emoji.
Wofür ist das gut?
Der Cash Open ist für viele Trader der entscheidende Moment, ab dem sie aktiv werden. Diese Markierung hilft dir, auf einen Blick zu sehen, ab wann die Sitzung läuft – damit du nicht zu früh einsteigst und deinen Einstieg sauber am Open ausrichtest.
Einstellungen:

New York und London getrennt ein-/ausschaltbar
Frei wählbare Zeit, Zeitzone und Farbe pro Session
Anpassbarer Text in zwei Zeilen plus Emoji
Linienbreite und Linienstil (durchgezogen, gestrichelt, gepunktet)
Textausrichtung und Position oberhalb der Kerzen einstellbar

Die Labels positionieren sich automatisch im oberen sichtbaren Chartbereich und passen sich beim Zoomen und Scrollen an.

## Source Code

````pine
//@version=6
indicator("Cash Open by Rezan La Sharma", "Cash Open by Rezan La Sharma", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=2000)

// =====================================================================
// NEW YORK
// =====================================================================
showNY      = input.bool(true,  "New York anzeigen",            group="New York")
nySession   = input.session("0930-0931", "NY Cash Open Zeit",   group="New York")
nyTimezone  = input.string("America/New_York", "NY Zeitzone",   group="New York", options=["America/New_York","Europe/London","Europe/Berlin","UTC"])
nyColor     = input.color(color.new(#00C853, 0), "NY Farbe",    group="New York")
nyText1     = input.string("9:30 AM",   "NY Zeile 1",           group="New York")
nyText2     = input.string("Cash Open", "NY Zeile 2",           group="New York")
nyEmoji     = input.string("💵",        "NY Emoji",             group="New York")

// =====================================================================
// LONDON
// =====================================================================
showLondon  = input.bool(false, "London anzeigen",              group="London")
lonSession  = input.session("0800-0801", "London Cash Open Zeit", group="London")
lonTimezone = input.string("Europe/London", "London Zeitzone",  group="London", options=["America/New_York","Europe/London","Europe/Berlin","UTC"])
lonColor    = input.color(color.new(#FF9800, 0), "London Farbe", group="London")
lonText1    = input.string("8:00 AM",    "London Zeile 1",      group="London")
lonText2    = input.string("London Open","London Zeile 2",      group="London")
lonEmoji    = input.string("💷",         "London Emoji",        group="London")

// =====================================================================
// STIL
// =====================================================================
lineWidth    = input.int(2, "Linienbreite", minval=1, maxval=5,                                  group="Stil")
styleChoice  = input.string("Solid", "Linienstil", options=["Solid","Dashed","Dotted"],          group="Stil")
labelSize    = input.string("Normal", "Label-Größe", options=["Tiny","Small","Normal","Large"], group="Stil")
labelAlignIn = input.string("Mittig", "Text-Ausrichtung", options=["Links","Mittig","Rechts"],  group="Stil")
labelOffset  = input.int(0, "Label-Offset nach rechts (Bars)", minval=-10, maxval=20,           group="Stil")
topMarginPct = input.float(3.0, "Abstand zum Top (% der sichtbaren Range)", minval=0.0, maxval=30.0, step=0.5, group="Stil")

// =====================================================================
// HILFSWERTE
// =====================================================================
lineStyle = styleChoice == "Dashed" ? line.style_dashed : styleChoice == "Dotted" ? line.style_dotted : line.style_solid
lblSize   = labelSize == "Tiny" ? size.tiny : labelSize == "Small" ? size.small : labelSize == "Large" ? size.large : size.normal
lblAlign  = labelAlignIn == "Links" ? text.align_left : labelAlignIn == "Rechts" ? text.align_right : text.align_center

// =====================================================================
// SESSION ERKENNUNG
// =====================================================================
nyInSession  = showNY     and not na(time("", nySession,  nyTimezone))
nyIsOpen     = nyInSession  and not nyInSession[1]

lonInSession = showLondon and not na(time("", lonSession, lonTimezone))
lonIsOpen    = lonInSession and not lonInSession[1]

// =====================================================================
// LABEL-TRACKING
// =====================================================================
var array<label> labelArr = array.new<label>()

if nyIsOpen
    line.new(bar_index, low, bar_index, high, color=nyColor, width=lineWidth, style=lineStyle, extend=extend.both)
    nyTxt = nyText1 + "\n" + nyText2 + "\n" + nyEmoji
    nyLbl = label.new(bar_index + labelOffset, high, nyTxt, color=color.new(color.white, 100), textcolor=nyColor, style=label.style_none, size=lblSize, textalign=lblAlign)
    array.push(labelArr, nyLbl)

if lonIsOpen
    line.new(bar_index, low, bar_index, high, color=lonColor, width=lineWidth, style=lineStyle, extend=extend.both)
    lonTxt = lonText1 + "\n" + lonText2 + "\n" + lonEmoji
    lonLbl = label.new(bar_index + labelOffset, high, lonTxt, color=color.new(color.white, 100), textcolor=lonColor, style=label.style_none, size=lblSize, textalign=lblAlign)
    array.push(labelArr, lonLbl)

// =====================================================================
// DYNAMISCHES UMPOSITIONIEREN AUF DEN SICHTBAREN CHART-TOP
// =====================================================================
if barstate.islast and array.size(labelArr) > 0
    leftT  = chart.left_visible_bar_time
    rightT = chart.right_visible_bar_time

    float visHi = na
    float visLo = na

    if not na(leftT) and not na(rightT)
        maxBack = math.min(2000, bar_index + 1)
        for i = 0 to maxBack - 1
            t = time[i]
            if not na(t)
                if t >= leftT and t <= rightT
                    visHi := na(visHi) ? high[i] : math.max(visHi, high[i])
                    visLo := na(visLo) ? low[i]  : math.min(visLo, low[i])
                if t < leftT
                    break

    if na(visHi) or na(visLo)
        visHi := ta.highest(high, math.min(100, bar_index + 1))
        visLo := ta.lowest(low,   math.min(100, bar_index + 1))

    rng  = visHi - visLo
    topY = visHi + rng * (topMarginPct / 100)

    for i = 0 to array.size(labelArr) - 1
        label.set_y(array.get(labelArr, i), topY)
````
