<!-- tradingview-pine-id: PUB;b101b5ed7990426fb64e71c80f9cda1a -->
<!-- tradingviewscripts-format: 1 -->
# MAUI Body Gaps INEF

Source: https://www.tradingview.com/script/Hdlu2yFJ/

## Description

Body Gap Finder

This indicator identifies gaps between the closing price of one candle and the opening price of the next candle. It focuses exclusively on candle bodies, while the wicks are ignored for the initial gap detection.

Bullish and bearish body gaps can be displayed separately. The minimum gap size can be adjusted in ticks, making it possible to detect even very small gaps of only one or two ticks.

The indicator draws the upper and lower boundaries of each gap and extends them to the right. Lines can either stop or be removed once the gap has been completely filled. Users can also choose whether a gap is considered filled by a wick or by the candle body.

Customizable settings include:

Bullish and bearish gap visibility
Minimum gap size in ticks
Line color, style and thickness
Maximum number of displayed gaps
Wick-based or body-based gap mitigation
Automatic removal of filled gaps

This indicator is designed to help traders identify potentially relevant unfilled price areas and visualize how the market reacts when these areas are revisited.

---

## Source Code

````pine
//@version=6
indicator(
     title            = "MAUI Body Gaps INEF",
     shorttitle       = "MAUI Body Gaps INEF",
     overlay          = true,
     max_lines_count  = 500
)

//────────────────────────────────────────────────────────────
// EINSTELLUNGEN
//────────────────────────────────────────────────────────────

groupDetection = "Erkennung"

gapDefinition = input.string(
     defval  = "Schlusskurs → nächster Open",
     title   = "Definition der Body-Lücke",
     options = [
         "Schlusskurs → nächster Open",
         "Komplett getrennte Kerzenkörper"
     ],
     group = groupDetection
)

minimumTicks = input.int(
     defval = 1,
     title  = "Mindestgröße in Ticks",
     minval = 1,
     group  = groupDetection
)

showBullishGaps = input.bool(
     defval = true,
     title  = "Bullische Lücken anzeigen",
     group  = groupDetection
)

showBearishGaps = input.bool(
     defval = true,
     title  = "Bärische Lücken anzeigen",
     group  = groupDetection
)


//────────────────────────────────────────────────────────────

groupDisplay = "Darstellung"

bullishColor = input.color(
     defval = color.aqua,
     title  = "Farbe bullische Lücke",
     group  = groupDisplay
)

bearishColor = input.color(
     defval = color.orange,
     title  = "Farbe bärische Lücke",
     group  = groupDisplay
)

lineWidth = input.int(
     defval = 1,
     title  = "Linienstärke",
     minval = 1,
     maxval = 4,
     group  = groupDisplay
)

lineStyleInput = input.string(
     defval  = "Durchgezogen",
     title   = "Linienart",
     options = [
         "Durchgezogen",
         "Gestrichelt",
         "Gepunktet"
     ],
     group = groupDisplay
)

maximumZones = input.int(
     defval = 100,
     title  = "Maximale Anzahl angezeigter Lücken",
     minval = 1,
     maxval = 250,
     group  = groupDisplay
)


//────────────────────────────────────────────────────────────

groupMitigation = "Schließen der Lücken"

stopWhenFilled = input.bool(
     defval = true,
     title  = "Linien stoppen, wenn Lücke vollständig geschlossen",
     group  = groupMitigation
)

fillSource = input.string(
     defval  = "Docht",
     title   = "Lücke gilt als geschlossen durch",
     options = [
         "Docht",
         "Kerzenkörper"
     ],
     group = groupMitigation
)

deleteFilledZones = input.bool(
     defval = false,
     title  = "Geschlossene Lücken vollständig löschen",
     group  = groupMitigation
)


//────────────────────────────────────────────────────────────
// LINIENSTIL
//────────────────────────────────────────────────────────────

selectedLineStyle = switch lineStyleInput
    "Gestrichelt" => line.style_dashed
    "Gepunktet"   => line.style_dotted
    => line.style_solid


//────────────────────────────────────────────────────────────
// PREISWERTE
//────────────────────────────────────────────────────────────

minimumGapSize = minimumTicks * syminfo.mintick

previousClose = math.round_to_mintick(close[1])
currentOpen   = math.round_to_mintick(open)

previousBodyHigh = math.round_to_mintick(math.max(open[1], close[1]))
previousBodyLow  = math.round_to_mintick(math.min(open[1], close[1]))

currentBodyHigh = math.round_to_mintick(math.max(open, close))
currentBodyLow  = math.round_to_mintick(math.min(open, close))


//────────────────────────────────────────────────────────────
// GAP-VARIABLEN
//
// Richtung:
//  1 = bullische Lücke
// -1 = bärische Lücke
//────────────────────────────────────────────────────────────

int gapDirection = 0

float gapTop    = na
float gapBottom = na

int topLineStartBar    = na
int bottomLineStartBar = na


//────────────────────────────────────────────────────────────
// GAP-ERKENNUNG
//────────────────────────────────────────────────────────────

if not na(close[1])

    //────────────────────────────────────────────────────────
    // Variante 1:
    // Lücke zwischen vorherigem Schlusskurs und aktuellem Open
    //────────────────────────────────────────────────────────

    if gapDefinition == "Schlusskurs → nächster Open"

        float openingDifference = currentOpen - previousClose

        // Bullische Opening-Lücke
        if openingDifference >= minimumGapSize
            gapDirection := 1

            gapTop    := currentOpen
            gapBottom := previousClose

            // Aktuelles Open gehört zur aktuellen Kerze
            topLineStartBar := bar_index

            // Vorheriger Close gehört zur vorherigen Kerze
            bottomLineStartBar := bar_index - 1

        // Bärische Opening-Lücke
        else if openingDifference <= -minimumGapSize
            gapDirection := -1

            gapTop    := previousClose
            gapBottom := currentOpen

            // Vorheriger Close gehört zur vorherigen Kerze
            topLineStartBar := bar_index - 1

            // Aktuelles Open gehört zur aktuellen Kerze
            bottomLineStartBar := bar_index


    //────────────────────────────────────────────────────────
    // Variante 2:
    // Die vollständigen Bodys überschneiden sich nicht
    //────────────────────────────────────────────────────────

    else

        // Aktueller Body liegt vollständig über dem vorherigen
        if currentBodyLow - previousBodyHigh >= minimumGapSize
            gapDirection := 1

            gapTop    := currentBodyLow
            gapBottom := previousBodyHigh

            topLineStartBar    := bar_index
            bottomLineStartBar := bar_index - 1

        // Aktueller Body liegt vollständig unter dem vorherigen
        else if previousBodyLow - currentBodyHigh >= minimumGapSize
            gapDirection := -1

            gapTop    := previousBodyLow
            gapBottom := currentBodyHigh

            topLineStartBar    := bar_index - 1
            bottomLineStartBar := bar_index


//────────────────────────────────────────────────────────────
// SPEICHER FÜR DIE LÜCKEN
//────────────────────────────────────────────────────────────

var array<line> topLines       = array.new<line>()
var array<line> bottomLines    = array.new<line>()
var array<float> zoneTops      = array.new<float>()
var array<float> zoneBottoms   = array.new<float>()
var array<int> zoneDirections  = array.new<int>()
var array<int> creationBars    = array.new<int>()
var array<bool> activeZones    = array.new<bool>()


//────────────────────────────────────────────────────────────
// BEREITS VORHANDENE LÜCKEN PRÜFEN
//────────────────────────────────────────────────────────────

if stopWhenFilled and array.size(topLines) > 0

    for i = array.size(topLines) - 1 to 0

        bool zoneIsActive = array.get(activeZones, i)

        if zoneIsActive

            int creationBar = array.get(creationBars, i)

            // Die Gap-Kerze selbst wird nicht als spätere
            // Mitigation gewertet.
            if bar_index > creationBar

                int direction   = array.get(zoneDirections, i)
                float zoneTop   = array.get(zoneTops, i)
                float zoneBottom = array.get(zoneBottoms, i)

                float testedLow = fillSource == "Docht" ?
                     low :
                     math.min(open, close)

                float testedHigh = fillSource == "Docht" ?
                     high :
                     math.max(open, close)

                bool zoneFilled = direction == 1 ?
                     testedLow <= zoneBottom :
                     testedHigh >= zoneTop

                if zoneFilled

                    line upperLine = array.get(topLines, i)
                    line lowerLine = array.get(bottomLines, i)

                    if deleteFilledZones
                        line.delete(upperLine)
                        line.delete(lowerLine)

                        array.remove(topLines, i)
                        array.remove(bottomLines, i)
                        array.remove(zoneTops, i)
                        array.remove(zoneBottoms, i)
                        array.remove(zoneDirections, i)
                        array.remove(creationBars, i)
                        array.remove(activeZones, i)

                    else
                        line.set_extend(upperLine, extend.none)
                        line.set_extend(lowerLine, extend.none)

                        line.set_x2(upperLine, bar_index)
                        line.set_x2(lowerLine, bar_index)

                        array.set(activeZones, i, false)


//────────────────────────────────────────────────────────────
// NEUE LÜCKE ZEICHNEN
//────────────────────────────────────────────────────────────

bool displayCurrentGap =
     gapDirection == 1  ? showBullishGaps :
     gapDirection == -1 ? showBearishGaps :
     false

if barstate.isnew and displayCurrentGap

    color gapColor = gapDirection == 1 ?
         bullishColor :
         bearishColor

    line newTopLine = line.new(
         x1     = topLineStartBar,
         y1     = gapTop,
         x2     = bar_index + 1,
         y2     = gapTop,
         xloc   = xloc.bar_index,
         extend = extend.right,
         color  = gapColor,
         style  = selectedLineStyle,
         width  = lineWidth
    )

    line newBottomLine = line.new(
         x1     = bottomLineStartBar,
         y1     = gapBottom,
         x2     = bar_index + 1,
         y2     = gapBottom,
         xloc   = xloc.bar_index,
         extend = extend.right,
         color  = gapColor,
         style  = selectedLineStyle,
         width  = lineWidth
    )

    array.push(topLines, newTopLine)
    array.push(bottomLines, newBottomLine)
    array.push(zoneTops, gapTop)
    array.push(zoneBottoms, gapBottom)
    array.push(zoneDirections, gapDirection)
    array.push(creationBars, bar_index)
    array.push(activeZones, true)


//────────────────────────────────────────────────────────────
// ÄLTESTE LÜCKEN ENTFERNEN
//────────────────────────────────────────────────────────────

if array.size(topLines) > maximumZones

    line oldestTopLine    = array.shift(topLines)
    line oldestBottomLine = array.shift(bottomLines)

    line.delete(oldestTopLine)
    line.delete(oldestBottomLine)

    array.shift(zoneTops)
    array.shift(zoneBottoms)
    array.shift(zoneDirections)
    array.shift(creationBars)
    array.shift(activeZones)


//────────────────────────────────────────────────────────────
// ALARME
//────────────────────────────────────────────────────────────

bool newBullishGap =
     barstate.isnew and
     gapDirection == 1 and
     showBullishGaps

bool newBearishGap =
     barstate.isnew and
     gapDirection == -1 and
     showBearishGaps

alertcondition(
     condition = newBullishGap,
     title     = "Neue bullische Body-Lücke",
     message   = "Eine neue bullische Body-Lücke wurde erkannt."
)

alertcondition(
     condition = newBearishGap,
     title     = "Neue bärische Body-Lücke",
     message   = "Eine neue bärische Body-Lücke wurde erkannt."
)
````
