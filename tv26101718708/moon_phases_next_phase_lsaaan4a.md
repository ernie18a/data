# Moon Phases + Next Phase

- url: https://www.tradingview.com/script/lSAaAn4a-Moon-Phases-Next-Phase/
- type: indicator
- pine_id: PUB;f7e9bff46c5d4876806990681c61fdc7
- version: 1.0

## Description

Moon Phases + Next Phase Projection is a visual lunar-cycle indicator that displays New Moon and Full Moon transitions directly on the price chart while also projecting the next upcoming lunar phase.

The indicator highlights the current lunar cycle using background shading and places markers on historical New Moon and Full Moon transitions. It also calculates the estimated timestamp of the next lunar phase change and displays a vertical line ahead of price action, making it easier to visually compare market behavior around lunar-cycle dates.

Features

Displays New Moon markers above the chart.

Displays Full Moon markers below the chart.

Uses configurable background colors to distinguish waxing and waning lunar periods.

Projects the next New Moon or Full Moon with a vertical line.

Optional label identifies the upcoming lunar phase.

Customizable line width, line style, and lunar phase colors.

Uses astronomical lunar-cycle calculations rather than fixed calendar intervals.

How to Use

This indicator is designed primarily as a visual and research tool. Traders can use it to study whether historical or upcoming lunar-cycle transitions show any relationship with market volatility, sentiment, reversals, or other price behavior.

A New Moon marks the beginning of the waxing phase, while a Full Moon marks the beginning of the waning phase. The projected vertical line indicates the estimated timing of the next transition between these two phases.

Important Note

Lunar phases should not be considered standalone trading signals. Any apparent relationship between lunar cycles and financial markets may be coincidental and should be evaluated alongside price action, risk management, technical analysis, and other relevant information.

This script is intended for educational, analytical, and experimental purposes only.

## Source Code

````pine
//@version=6
indicator("Moon Phases + Next Phase", overlay = true, max_lines_count = 10, max_labels_count = 10)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────

waxingMoonColorInput = input.color(color.blue, "Waxing Moon")
waningMoonColorInput = input.color(color.white, "Waning Moon")

showNextPhaseLine = input.bool(true, "Show Next Moon Phase Line")
showNextPhaseLabel = input.bool(true, "Show Next Moon Phase Label")
nextLineWidth = input.int(2, "Next Phase Line Width", minval = 1, maxval = 5)
nextLineStyleInput = input.string(
     "Dashed",
     "Next Phase Line Style",
     options = ["Solid", "Dashed", "Dotted"]
)

nextLineStyle =
     nextLineStyleInput == "Solid" ? line.style_solid :
     nextLineStyleInput == "Dotted" ? line.style_dotted :
     line.style_dashed


if timeframe.ismonthly
    runtime.error("Unsupported timeframe.")

// ─────────────────────────────────────────────────────────────
// DAY OF YEAR
// ─────────────────────────────────────────────────────────────

dayofyear(_time) =>
    _year = year(_time)

    leapYear =
         (_year % 400 == 0) or
         (_year % 4 == 0 and _year % 100 != 0)

    dayCount = array.from(
         31,
         leapYear ? 29 : 28,
         31,
         30,
         31,
         30,
         31,
         31,
         30,
         31,
         30,
         31
    )

    timeMonth = month(_time)

    dayofyear = 0

    if timeMonth > 1
        for i = 0 to timeMonth - 2
            dayofyear += dayCount.get(i)

    dayofyear + dayofmonth(_time)


// ─────────────────────────────────────────────────────────────
// JULIAN DATE → UNIX TIME
// ─────────────────────────────────────────────────────────────

getUNIXTimeFromJD(julianDay) =>
    z = math.floor(julianDay + 0.5)
    f = (julianDay + 0.5) % 1

    alpha = math.floor((z - 1867216.25) / 36524.25)

    a =
         z < 2299161 ?
         z :
         z + 1 + alpha - math.floor(alpha / 4.0)

    b = a + 1524
    c = math.floor((b - 122.1) / 365.25)
    d = math.floor(365.25 * c)
    e = math.floor((b - d) / 30.6001)

    dayFloat = b - d - math.floor(30.6001 * e) + f

    _day = int(dayFloat)

    _month =
         e < 13.5 ?
         int(e - 1) :
         int(e - 13)

    _year =
         _month > 2.5 ?
         int(c - 4716) :
         int(c - 4715)

    secondTotal = int((dayFloat % 1) * 60 * 60 * 24)

    _hour = int(secondTotal / (60 * 60))

    _minute =
         int(
             (secondTotal - (_hour * 60 * 60)) / 60
         )

    _second = secondTotal % 60

    timestamp(
         _year,
         _month,
         _day,
         _hour,
         _minute,
         _second
    )


// ─────────────────────────────────────────────────────────────
// CALCULATE MOON PHASE TIME FROM K
//
// Integer K     = New Moon
// Integer + 0.5 = Full Moon
// ─────────────────────────────────────────────────────────────

getMoonPhaseTime(k) =>

    t = k / 1236.85

    // Mean anomaly of the Sun
    anomalySun = math.toradians(
         359.2242 +
         (29.10535608 * k) -
         (0.0000333 * math.pow(t, 2)) -
         (0.00000347 * math.pow(t, 3))
    )

    // Mean anomaly of the Moon
    anomalyMoon = math.toradians(
         306.0253 +
         (385.81691806 * k) +
         (0.0107306 * math.pow(t, 2)) +
         (0.00001236 * math.pow(t, 3))
    )

    // Argument of latitude of the Moon
    f = math.toradians(
         21.2964 +
         (390.67050646 * k) -
         (0.0016528 * math.pow(t, 2)) -
         (0.00000239 * math.pow(t, 3))
    )

    dev =
         (0.1734 - (0.000393 * t)) * math.sin(anomalySun) +
         0.0021 * math.sin(2 * anomalySun) -
         0.4068 * math.sin(anomalyMoon) +
         0.0161 * math.sin(2 * anomalyMoon) -
         0.0004 * math.sin(3 * anomalyMoon) +
         0.0104 * math.sin(2 * f) -
         0.0051 * math.sin(anomalySun + anomalyMoon) -
         0.0074 * math.sin(anomalySun - anomalyMoon) +
         0.0004 * math.sin(2 * f + anomalySun) -
         0.0004 * math.sin(2 * f - anomalySun) -
         0.0006 * math.sin(2 * f + anomalyMoon) +
         0.0010 * math.sin(2 * f - anomalyMoon) +
         0.0005 * math.sin(anomalySun + 2 * anomalyMoon)

    julianDate =
         2415020.75933 +
         (29.53058868 * k) +
         (0.0001178 * math.pow(t, 2)) -
         (0.000000155 * math.pow(t, 3)) +
         (
             0.00033 *
             math.sin(
                 math.toradians(166.56) +
                 (math.toradians(132.87) * t) -
                 (math.toradians(0.009173) * math.pow(t, 2))
             )
         ) +
         dev

    getUNIXTimeFromJD(julianDate)


// ─────────────────────────────────────────────────────────────
// GET CURRENT + NEXT MOON PHASE
// ─────────────────────────────────────────────────────────────

getMoonPhaseInfo(_time) =>

    _year = year(_time)
    dayOfYear = dayofyear(_time)

    // Approximate lunar cycle number
    kApprox =
         (dayOfYear / 364.25 + _year - 1900) *
         12.3685

    // Round down to the closest New/Full Moon position.
    phaseK = math.floor(kApprox * 2.0) / 2.0

    phaseTime = getMoonPhaseTime(phaseK)

    // Astronomical corrections can move the calculated phase
    // slightly ahead of the current bar.
    // If so, go back half a lunar cycle.
    if phaseTime > _time
        phaseK := phaseK - 0.5
        phaseTime := getMoonPhaseTime(phaseK)

    // Current phase:
    // integer K     → New Moon occurred → waxing period
    // integer + .5  → Full Moon occurred → waning period
    int currentPhase =
         (phaseK % 1.0 == 0.0) ?
         1 :
         -1

    // Next phase is always half a lunation later.
    nextK = phaseK + 0.5

    nextPhaseTime = getMoonPhaseTime(nextK)

    int nextPhase =
         (nextK % 1.0 == 0.0) ?
         1 :
         -1

    [
         currentPhase,
         phaseTime,
         nextPhase,
         nextPhaseTime
    ]


// ─────────────────────────────────────────────────────────────
// GET DATA
// ─────────────────────────────────────────────────────────────

[
     moonPhase,
     currentPhaseTime,
     nextMoonPhase,
     nextMoonPhaseTime
] = getMoonPhaseInfo(time_close)


// Detect historical phase change
moonType =
     ta.change(moonPhase) != 0 ?
     moonPhase :
     na


// ─────────────────────────────────────────────────────────────
// EXISTING MOON MARKERS
// ─────────────────────────────────────────────────────────────

plotshape(
     moonType == 1,
     title = "New Moon",
     style = shape.circle,
     location = location.abovebar,
     color = color.new(waxingMoonColorInput, 50),
     size = size.normal
)

plotshape(
     moonType == -1,
     title = "Full Moon",
     style = shape.circle,
     location = location.belowbar,
     color = color.new(waningMoonColorInput, 50),
     size = size.normal
)


// Background
bgcolor(
     color.new(
         moonPhase == 1 ?
         waxingMoonColorInput :
         waningMoonColorInput,
         95
     )
)


// ─────────────────────────────────────────────────────────────
// NEXT MOON PHASE VERTICAL LINE
// ─────────────────────────────────────────────────────────────

var line nextPhaseLine = na
var label nextPhaseLabel = na

if barstate.islast

    // Delete old line/label before redrawing
    if not na(nextPhaseLine)
        line.delete(nextPhaseLine)

    if not na(nextPhaseLabel)
        label.delete(nextPhaseLabel)

    if showNextPhaseLine

        nextColor =
             nextMoonPhase == 1 ?
             waxingMoonColorInput :
             waningMoonColorInput

        // Because xloc.bar_time is used,
        // nextMoonPhaseTime is interpreted as a timestamp.
        //
        // extend.both causes the line to extend vertically
        // across the entire chart.
        nextPhaseLine := line.new(
             x1 = nextMoonPhaseTime,
             y1 = low,
             x2 = nextMoonPhaseTime,
             y2 = high,
             xloc = xloc.bar_time,
             extend = extend.both,
             color = nextColor,
             style = nextLineStyle,
             width = nextLineWidth
        )

        if showNextPhaseLabel

            phaseName =
                 nextMoonPhase == 1 ?
                 "Next New Moon" :
                 "Next Full Moon"

            nextPhaseLabel := label.new(
                 x = nextMoonPhaseTime,
                 y = high,
                 text = phaseName,
                 xloc = xloc.bar_time,
                 yloc = yloc.abovebar,
                 color = color.new(nextColor, 20),
                 textcolor = color.white,
                 style = label.style_label_down,
                 size = size.small
            )
````
