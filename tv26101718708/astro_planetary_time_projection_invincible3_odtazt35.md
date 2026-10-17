# Astro: Planetary Time Projection [invincible3]

- url: https://www.tradingview.com/script/oDTazt35-Astro-Planetary-Time-Projection-invincible3/
- type: indicator
- pine_id: PUB;6908235e63c94207a75c55f93143c22f
- version: 2.0

## Description

[b]Astro: Planetary Time Projection [Invincible3][/b]

Astro: Planetary Time Projection is a time-analysis indicator inspired by the market philosophy of  W.D. Gann, who believed that markets are governed not only by price but also by recurring cycles of time.

Unlike traditional technical indicators that attempt to forecast future prices, this indicator is designed to project **potential market timing windows**. It starts from an important market high or low (the Anchor) and projects future dates based on the angular movement of selected celestial bodies.

The underlying idea is simple:

A significant market high or low establishes the starting point. As planets advance through specific angular distances from that anchor, the market may enter a period where a reversal, acceleration, breakout, or change in behavior becomes more likely.

The indicator does not predict price direction. Instead, it identifies when market participants may want to pay closer attention to price action.

-----------------------------------------------------------------------------------------------

 [b]Core Concept[/b]

The workflow follows four simple steps.

[b]Step 1 — Identify an Important Anchor[/b]

Select a meaningful market event to use as the Anchor Date.

Typical anchors include:

• Major swing highs

• Major swing lows

• Bull market bottoms

• Bear market tops

• Long-term support or resistance reversals

• Breakout or breakdown dates

• Major economic or geopolitical events

The quality of the anchor often determines the usefulness of the projected timing windows.

-----------------------------------------------------------------------------------------------

[b]Step 2 — Select One or More Planets[/b]

The indicator allows multiple planets to be enabled simultaneously.

Supported bodies include:

• Sun

• Moon

• Mercury

• Venus

• Mars

• Jupiter

• Saturn

• Uranus

• Neptune

• Pluto

• North Lunar Node

Each body moves at its own average angular speed, producing unique timing cycles.

-----------------------------------------------------------------------------------------------

[b]Step 3 — Select Planetary Angles[/b]

Choose one or more angular projections.

Available presets include:

15°

30°

45°

50°

60°

72°

75°

87°

90°

115°

120°

144°

180°

216°

240°

270°

315°

360°

Custom angles may also be entered to support individual trading methodologies.

-----------------------------------------------------------------------------------------------

[b]Step 4 — Project Future Time Windows[/b]

The indicator calculates the amount of time required for each selected planet to travel the chosen angular distance from the Anchor Date.

Those calculated dates are displayed as vertical timing lines on the chart.

These dates represent **potential periods of increased market significance**, where traders may observe:

• Trend reversals

• Trend continuation

• Breakouts

• Breakdown attempts

• Volatility expansion

• Momentum shifts

• Cycle completions

-----------------------------------------------------------------------------------------------

[b]The Gann Perspective[/b]

W.D. Gann believed that markets exhibit recurring mathematical and natural cycles.

One of his enduring principles was:

"When Time is fulfilled, Price becomes vulnerable."

Rather than attempting to predict exact prices, Gann often focused on identifying moments when the market had completed an important time cycle.

This indicator adopts that philosophy by using planetary angular movement as a timing mechanism.

It does not assume that planets directly influence financial markets. Instead, planetary cycles are used as a structured and repeatable way to measure the passage of time from significant market events.

-----------------------------------------------------------------------------------------------

[b]Time Projection Instead of Price Prediction[/b]

This indicator answers a different question than most technical tools.

Traditional indicators ask:

"Where might price go?"

Astro: Planetary Time Projection asks:

"When should I pay closer attention?"

The projected dates are intended to highlight periods where market behavior may become more dynamic. These dates should always be interpreted alongside price action and broader market context.

-----------------------------------------------------------------------------------------------

[b]Time Confluence[/b]

One of the most valuable features of the indicator is the ability to enable multiple planets simultaneously.

When projections from different planetary cycles occur close together, a time confluence is created.

Many Gann practitioners consider these clustered periods to be more significant than isolated timing projections, as multiple independent cycles converge within a relatively short time window.

-----------------------------------------------------------------------------------------------

[b]Repeat Cycle Projection[/b]

Markets often display repeating cyclical behavior over longer periods.

The Repeat Cycle option extends each selected planetary projection by additional 360° revolutions.

For example:

90°

450°

810°

1170°

-----------------------------------------------------------------------------------------------

This feature allows users to study both short-term and long-term timing relationships.

-----------------------------------------------------------------------------------------------

[b]Forward and Backward Analysis[/b]

The indicator supports both:

[b]Forward Projection[/b]

Projects future timing windows beyond the selected anchor.

[b]Backward Projection[/b]

Projects historical timing relationships prior to the anchor, making it useful for research and historical cycle analysis.

-----------------------------------------------------------------------------------------------

[b]Suggested Workflow[/b]

A common workflow is:

1. Identify a significant market high or low.
2. Set the Anchor Date.
3. Enable one or more planets.
4. Select the desired angular projections.
5. Observe where multiple planetary timing lines cluster.
6. Monitor those dates for technical confirmation using market structure, support and resistance, trend analysis, volume, or momentum indicators.

The indicator is intended to complement—not replace—traditional technical analysis.

-----------------------------------------------------------------------------------------------

[b]Features[/b]

• Multiple planetary selection

• Planet-specific color coding

• User-defined Anchor Date

• Multiple angle projections

• Custom angular inputs

• Forward and backward projections

• Repeat 360° cycle projections

• Vertical timing windows

• Optional labels

• Lightweight TradingView implementation

-----------------------------------------------------------------------------------------------

[b]Current Calculation Model[/b]

The current version estimates planetary movement using average angular speeds to generate practical timing projections within Pine Script.

It is designed as a lightweight and educational implementation suitable for market timing studies.

It is not intended to reproduce high-precision astronomical ephemeris calculations or professional astrology software.

-----------------------------------------------------------------------------------------------

[b]Disclaimer[/b]

Astro: Planetary Time Projection is an educational market timing tool inspired by Gann's time-cycle methodology.

The projected dates identify potential timing windows, not guaranteed market reversals or price targets.

No indicator can predict future market movements with certainty. Users should combine this tool with sound technical analysis, disciplined risk management, and independent judgment before making trading decisions.

## Source Code

````pine
//@version=6
indicator("Astro: Planetary Time Projection [invincible3]", overlay=true, scale=scale.none, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━ INPUTS
grpMain = "Anchor"
anchorTime = input.time(timestamp("2026-01-01T00:00:00"), "Anchor Time", group=grpMain)
showAnchor = input.bool(true, "Show Anchor Line", group=grpMain)

grpPlanet = "Planets"
showSun     = input.bool(true,  "Sun", group=grpPlanet)
showMoon    = input.bool(false, "Moon", group=grpPlanet)
showMercury = input.bool(false, "Mercury", group=grpPlanet)
showVenus   = input.bool(false, "Venus", group=grpPlanet)
showMars    = input.bool(false, "Mars", group=grpPlanet)
showJupiter = input.bool(false, "Jupiter", group=grpPlanet)
showSaturn  = input.bool(false, "Saturn", group=grpPlanet)
showUranus  = input.bool(false, "Uranus", group=grpPlanet)
showNeptune = input.bool(false, "Neptune", group=grpPlanet)
showPluto   = input.bool(false, "Pluto", group=grpPlanet)
showNorth   = input.bool(false, "North Node", group=grpPlanet)

direction = input.string("Forward", "Projection Direction", options=["Forward","Backward"], group=grpPlanet)

grpAngles = "Angles"
a1 = input.string("30", "Angle 1", options=["None","15","30","45","50","60","72","75","87","90","115","120","144","180","216","240","270","315","360","Custom"], group=grpAngles)
c1 = input.float(30, "Custom Angle 1", group=grpAngles)

a2 = input.string("50", "Angle 2", options=["None","15","30","45","50","60","72","75","87","90","115","120","144","180","216","240","270","315","360","Custom"], group=grpAngles)
c2 = input.float(50, "Custom Angle 2", group=grpAngles)

a3 = input.string("75", "Angle 3", options=["None","15","30","45","50","60","72","75","87","90","115","120","144","180","216","240","270","315","360","Custom"], group=grpAngles)
c3 = input.float(75, "Custom Angle 3", group=grpAngles)

a4 = input.string("115", "Angle 4", options=["None","15","30","45","50","60","72","75","87","90","115","120","144","180","216","240","270","315","360","Custom"], group=grpAngles)
c4 = input.float(115, "Custom Angle 4", group=grpAngles)

grpStyle = "Style"
repeatCycles = input.int(1, "Repeat 360° Cycles", minval=0, maxval=10, group=grpStyle)
showLabels = input.bool(true, "Show Labels", group=grpStyle)
lineWidth = input.int(1, "Line Width", minval=1, maxval=4, group=grpStyle)
lookback = input.int(300, "Vertical Height Lookback", minval=50, maxval=5000, group=grpStyle)
downExtend = input.float(3.0, "Downward Extension Multiplier", minval=0.5, maxval=20, step=0.5, group=grpStyle)

//━━━━━━━━━━━━━━━━━━━ PLANET DATA
planetSpeedDegPerDay(p) =>
    switch p
        "Sun"        => 0.9856
        "Moon"       => 13.1764
        "Mercury"    => 4.0923
        "Venus"      => 1.6021
        "Mars"       => 0.5240
        "Jupiter"    => 0.08309
        "Saturn"     => 0.03346
        "Uranus"     => 0.01173
        "Neptune"    => 0.00598
        "Pluto"      => 0.00396
        "North Node" => 0.05295
        => 1.0

planetColor(p) =>
    switch p
        "Sun"        => color.orange
        "Moon"       => color.silver
        "Mercury"    => color.green
        "Venus"      => color.fuchsia
        "Mars"       => color.red
        "Jupiter"    => color.yellow
        "Saturn"     => color.black
        "Uranus"     => color.teal
        "Neptune"    => color.blue
        "Pluto"      => color.gray
        "North Node" => color.purple
        => color.gray

angleValue(opt, customVal) =>
    opt == "None" ? na :
     opt == "Custom" ? customVal :
     str.tonumber(opt)

//━━━━━━━━━━━━━━━━━━━ STORAGE
var line[] lines = array.new_line()
var label[] labels = array.new_label()

clearObjects() =>
    while array.size(lines) > 0
        line.delete(array.pop(lines))
    while array.size(labels) > 0
        label.delete(array.pop(labels))

drawVertical(t, txt, col, yLow, yHigh) =>
    ln = line.new(
         x1=t,
         y1=yHigh,
         x2=t,
         y2=yLow,
         xloc=xloc.bar_time,
         extend=extend.both,
         color=col,
         width=lineWidth,
         style=line.style_solid)

    array.push(lines, ln)

    if showLabels
        lb = label.new(
             x=t,
             y=yHigh,
             text=txt,
             xloc=xloc.bar_time,
             style=label.style_label_down,
             textcolor=color.white,
             color=color.new(col, 0),
             size=size.small)

        array.push(labels, lb)

drawPlanetAngle(p, baseAngle, yLow, yHigh) =>
    if not na(baseAngle)
        speed = planetSpeedDegPerDay(p)
        col = planetColor(p)
        dir = direction == "Forward" ? 1 : -1

        for cycle = 0 to repeatCycles
            totalAngle = baseAngle + cycle * 360
            daysNeeded = totalAngle / speed
            tProjected = anchorTime + int(dir * daysNeeded * 86400000)

            labelTxt = p + " " + str.tostring(totalAngle, "#.##") + "°"
            drawVertical(tProjected, labelTxt, col, yLow, yHigh)

drawPlanet(p, enabled, yLow, yHigh, ang1, ang2, ang3, ang4) =>
    if enabled
        drawPlanetAngle(p, ang1, yLow, yHigh)
        drawPlanetAngle(p, ang2, yLow, yHigh)
        drawPlanetAngle(p, ang3, yLow, yHigh)
        drawPlanetAngle(p, ang4, yLow, yHigh)

//━━━━━━━━━━━━━━━━━━━ DRAW
rangeHigh = ta.highest(high, lookback)
rangeLow = ta.lowest(low, lookback)

if barstate.islast
    clearObjects()

    priceRange = rangeHigh - rangeLow
    yHigh = rangeHigh + priceRange * 0.10
    yLow = rangeLow

    if showAnchor
        drawVertical(anchorTime, "Anchor", color.gray, yLow, yHigh)

    ang1 = angleValue(a1, c1)
    ang2 = angleValue(a2, c2)
    ang3 = angleValue(a3, c3)
    ang4 = angleValue(a4, c4)

    drawPlanet("Sun",        showSun,     yLow, yHigh, ang1, ang2, ang3, ang4)
    drawPlanet("Moon",       showMoon,    yLow, yHigh, ang1, ang2, ang3, ang4)
    drawPlanet("Mercury",    showMercury, yLow, yHigh, ang1, ang2, ang3, ang4)
    drawPlanet("Venus",      showVenus,   yLow, yHigh, ang1, ang2, ang3, ang4)
    drawPlanet("Mars",       showMars,    yLow, yHigh, ang1, ang2, ang3, ang4)
    drawPlanet("Jupiter",    showJupiter, yLow, yHigh, ang1, ang2, ang3, ang4)
    drawPlanet("Saturn",     showSaturn,  yLow, yHigh, ang1, ang2, ang3, ang4)
    drawPlanet("Uranus",     showUranus,  yLow, yHigh, ang1, ang2, ang3, ang4)
    drawPlanet("Neptune",    showNeptune, yLow, yHigh, ang1, ang2, ang3, ang4)
    drawPlanet("Pluto",      showPluto,   yLow, yHigh, ang1, ang2, ang3, ang4)
    drawPlanet("North Node", showNorth,   yLow, yHigh, ang1, ang2, ang3, ang4)
````
