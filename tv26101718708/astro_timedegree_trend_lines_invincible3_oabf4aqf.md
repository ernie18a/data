# Astro: Time-Degree Trend Lines [invincible3]

- url: https://www.tradingview.com/script/OABF4AQf-Astro-Time-Degree-Trend-Lines-invincible3/
- type: indicator
- pine_id: PUB;5d66084bacec424d803df5da43bc9f61
- version: 1.0

## Description

[b]Astro-Gann Time-Degree Trend Lines – Invincible3[/b]

Astro-Gann Time-Degree Trend Lines is a range-based financial astrology and Gann timing tool designed to project planetary motion into price space.

Instead of plotting ordinary planetary positions, this indicator converts planetary movement into price-degree trend lines using a selected anchor price, anchor time, end time, user-defined planetary starting degrees, a motion harmonic multiplier, and a custom price-per-degree scale.

The concept is based on the Gann principle that time, price, and degrees can be harmonically related. Each planet’s movement over the selected range is converted into price movement, allowing traders to study planetary speed, time cycles, price vibration, and harmonic market geometry directly on the chart.

The indicator also includes a Gann-style aspect table that compares planet-to-planet angular relationships at the end of the selected range using each planet’s manually entered starting degree. This makes the aspect logic more meaningful because planets no longer begin from a common zero point. Each planet can start from its own real zodiac degree, ephemeris-based value, or symbolic Gann degree.

This tool is especially useful for traders who apply W.D. Gann methods, planetary time cycles, price-time squaring, astro-harmonics, Square of 9 logic, 360° degree geometry, and financial astrology to identify possible zones of trend continuation, support, resistance, vibration, or reversal timing.

[b]What This Indicator Does[/b]

The indicator starts from a selected anchor price and anchor time.

Each planet also has a user-defined starting degree at the anchor. From that point, the script calculates how many degrees each planet moves during the selected date range, adds that motion to the planet’s starting degree, and then converts the resulting degree value into a projected price level.

The projection model is:

Planetary Motion = Days × Average Daily Motion × Motion Harmonic Multiplier

Line Degree = Starting Degree + Planetary Motion

Projected Price = Anchor Price ± (Line Degree × Points Per Degree)

This means the starting degree directly affects the trend-line position.

For example, if the Sun starts at 4°, moves 30°, and the selected scale is 10 points per degree, then:

Line Degree = 4° + 30° = 34°

Projected Price = Anchor Price ± 340 points

So the line does not only represent planetary movement from zero. It represents the full start-degree-adjusted Gann line degree.

[b]Core Concept[/b]

This is not a standard astronomical aspect indicator. It is a Gann-style time-degree projection tool.

The purpose is to study:

How many degrees each planet moves during a selected market range.
How planetary motion can be translated into price.
How each planet’s starting degree changes the projected line position.
Which planets produce stronger or weaker price-time slopes.
Where planetary degree projections align with price structure.
Which planet pairs form Gann/astro harmonic relationships at the end of the range.

This makes the indicator useful for analyzing market vibration, planetary speed relationships, price-time geometry, harmonic projection, and range-based astro-Gann timing.

[b]Key Features[/b]

[b]Range-Based Astro-Gann Projection[/b]

Select a custom time range using:

Anchor Time
End Time
Anchor Price

The indicator calculates planetary movement across this exact range and projects it onto the price chart.

This allows traders to study planetary motion from an important market event such as:

Major swing high
Major swing low
Breakout point
Crash low
All-time high
Cycle start
First trading date
Gann anniversary date
Important planetary event
Major economic or market cycle date

The selected range becomes the measurement window for planetary movement and Gann degree projection.

[b]User-Defined Starting Degrees[/b]

Each planet has a manual starting degree input.

This allows traders to enter the actual zodiac degree or symbolic Gann degree of each planet at the anchor date.

The starting degree affects:

The plotted planetary trend-line position
The projected price level
The end label
The final line degree
The aspect-table end longitude

This correction is important because each planet no longer starts from 0°. Each body can begin from its own real, ephemeris-based, or symbolic starting degree.

For price projection, the indicator uses:

Line Degree = Starting Degree + Planetary Motion

For aspect calculations, the indicator uses:

End Longitude = Starting Degree + Signed Planetary Motion

[b]Planetary Time-Degree Trend Lines[/b]

The indicator plots planetary motion lines for:

☉ Sun
☾ Moon
☿ Mercury
♀ Venus
♂ Mars
♃ Jupiter
♄ Saturn
♅ Uranus
♆ Neptune
♇ Pluto
☊ Lunar Node

Each planet has:

Its own average daily motion
Its own starting degree
Its own projected line degree
Its own color setting
Its own visibility toggle

The final trend-line position is based on the planet’s starting degree plus its movement over the selected range.

[b]Uptrend and Downtrend Projection[/b]

The indicator can plot:

Upward planetary projection lines
Downward planetary projection lines

Upward lines project planetary degree movement above the anchor price.

Downward lines project planetary degree movement below the anchor price.

This allows traders to study both bullish and bearish price-time pathways from the same anchor.

For example:

Up projection = Anchor Price + Line Degree × Points Per Degree

Down projection = Anchor Price - Line Degree × Points Per Degree

This gives a balanced way to study both expansion and contraction from a selected market point.

[b]Points Per Degree Scaling[/b]

The user can define how many price points represent one planetary degree.

Examples:

1 point per degree
10 points per degree
100 points per degree
Custom market-specific scaling

This is useful because every market has a different vibration.

Gold, Bitcoin, forex pairs, stocks, commodities, and indices may require different degree-to-price scaling.

The purpose is to find a scale where planetary degree projections align meaningfully with market structure, swing points, or harmonic price zones.

[b]Motion Harmonic Multiplier[/b]

The motion harmonic multiplier can be used to increase or decrease the speed of planetary projection.

Examples:

1x = normal planetary motion
2x = double-speed harmonic
0.5x = half-speed harmonic

This can be useful for traders who study:

Harmonic repetition
Accelerated cycles
Compressed planetary timing
Higher-frequency market vibration
Fractional planetary movement

The motion harmonic multiplier changes the planetary movement component of the line.

It affects the slope and speed of the planetary projection. It should be understood as a speed or cycle multiplier, not as a 360° price octave shift.

[b]Gann Aspect Table[/b]

The indicator includes a compact aspect table that compares planet-to-planet angular relationships at the end of the selected range.

The table uses each planet’s starting degree and signed planetary motion:

End Longitude = Starting Degree + Signed Planetary Motion

Then it calculates the angular separation between planet pairs and finds the nearest Gann/astro aspect.

Supported aspect angles include:

0° Conjunction
30° Semi-sextile
45° Semi-square
60° Sextile
72° Quintile
90° Square
120° Trine
135° Sesquiquadrate
144° Biquintile / Gann harmonic
150° Quincunx
180° Opposition

The table displays:

Planet pair
Nearest aspect
Angular delta at range end
Orb from exact aspect

This helps identify which planet pairs are in close harmonic relationship at the end of the selected range.

[b]Aspect Interpretation for Gann Traders[/b]

In financial astrology and Gann analysis, aspects are not used only as traditional astrology signals. They are also treated as geometric divisions of the 360° circle.

Important divisions include:

45° and 90° for square pressure and market action
60° and 120° for smoother harmonic flow
72° and 144° for fifth-harmonic and pentagonal geometry
180° for opposition, polarity, and possible culmination
30° and 150° for adjustment zones

When a planet pair forms a tight orb near one of these angles, it may indicate a time window where market rhythm, volatility, or direction can shift.

The table is not meant to be used as a standalone signal. It is designed to provide astro-Gann confluence with price structure, swing points, trendlines, Fibonacci levels, cycle dates, and market context.

[b]How to Use[/b]

[b]1. Choose an Important Market Anchor Point[/b]

Select a meaningful market point such as:

Major swing high
Major swing low
Breakout level
Crash low
All-time high
All-time low
First trading date
Cycle start
Gann anniversary date

This anchor becomes the origin point for the projection.

[b]2. Set the Anchor Price[/b]

Enter the price level from which the planetary degree lines will begin.

This is usually the price of the selected swing high, swing low, breakout, or cycle point.

[b]3. Set the Anchor Time and End Time[/b]

Choose the start and end dates of the range.

The indicator calculates planetary movement across this selected time window.

The range defines the time component of the Astro-Gann projection.

[b]4. Enter Starting Degrees for Each Planet[/b]

Enter the starting degree for each planet at the anchor date.

These can be:

Actual zodiac degrees from an ephemeris
Geocentric planetary degrees
Heliocentric planetary degrees
Symbolic Gann degrees
Custom cycle degrees chosen by the trader

The starting degree affects both the trend-line position and the aspect-table calculation.

[b]5. Adjust Points Per Degree[/b]

Increase or decrease the price-per-degree value until the projected planetary lines match the market’s vibration.

Different markets may require different scales.

For example:

Gold may respond better to one scale.
Bitcoin may require a larger scale.
Forex may require a smaller scale.
Stocks and indices may need symbol-specific calibration.

[b]6. Adjust the Motion Harmonic Multiplier[/b]

Use the motion harmonic multiplier to test faster or slower planetary projection rhythms.

For example:

1x = normal planetary speed
2x = double-speed projection
0.5x = half-speed projection

This is useful when studying compressed cycles, expanded cycles, or harmonic repetitions of planetary motion.

[b]7. Enable the Planets You Want to Study[/b]

Enable or disable planets depending on your trading timeframe.

General use:

Moon, Mercury, Venus = faster short-term timing
Sun and Mars = intermediate timing
Jupiter and Saturn = larger cycle structure
Uranus, Neptune, Pluto = macro or long-term harmonic background
Node = long-cycle timing reference in financial astrology

[b]8. Use the Aspect Table[/b]

Look for tight orbs between planet pairs near important Gann aspects such as:

45°
60°
72°
90°
120°
135°
144°
150°
180°

The tighter the orb, the closer the pair is to an exact harmonic relationship at the end of the selected range.

Use this as timing confluence, not as a mechanical buy/sell signal.

[b]Practical Trading Applications[/b]

This indicator can be used to study:

Price-time squaring
Planetary degree projection
Market vibration
Time-cycle completion
Harmonic resistance and support zones
Planetary speed-based trend slopes
Start-degree-adjusted planetary projection
Possible reversal windows
Range-based astro-Gann confluence
Planet-to-planet harmonic relationships

It is best used together with normal market structure tools such as:

Swing highs and lows
Trendlines
Fibonacci levels
Support and resistance
Volume
Momentum indicators
Cycle dates
Seasonality
Volatility zones

The strongest use case is when planetary lines, motion harmonics, aspect-table harmonics, and technical market structure all point to the same zone.

[b]Important Notes[/b]

This indicator uses average daily planetary motion, not a full astronomical ephemeris engine.

The starting degrees are entered manually by the user. For more accurate astrology-based analysis, users should obtain planetary degrees from an ephemeris and enter them into the starting degree fields.

The starting degrees affect both:

Visual projection lines
Aspect-table calculations

This makes the tool more consistent with range-based Astro-Gann analysis.

The Lunar Node is commonly treated as retrograde in zodiac motion. For price-line projection, absolute motion may be used for clean visual direction, while aspect logic respects signed motion.

Because this is a Gann-style projection tool, the purpose is not to predict with certainty. The purpose is to map possible price-time harmonics and observe where market structure reacts around those projected levels.

[b]Known Limitations[/b]

Planetary positions are based on average motion, not high-precision ephemeris calculations.
Manual starting degrees are required for meaningful projection and aspect-table results.
The indicator does not automatically fetch real-time planetary longitude.
The motion harmonic multiplier changes projection speed, not a 360° price octave.
Results should be treated as analytical confluence, not standalone trade signals.

[b]Best Use Case[/b]

This tool is best suited for traders who already use or are studying:

W.D. Gann methods
Financial astrology
Planetary price-time projection
Square of 9 logic
360° degree geometry
Astro-cycle timing
Harmonic market geometry
Planetary speed relationships
Price-time squaring

It is designed for traders who want to visually connect planetary motion, starting degrees, time range, and price movement directly on the chart.

[b]Summary[/b]

Astro-Gann Time-Degree Trend Lines – Invincible3 converts planetary motion into price-degree projections using a selected market range.

The corrected logic combines:

Starting Degree
Planetary Motion
Motion Harmonic Multiplier
Price-per-degree scaling

This creates a practical Astro-Gann projection model where each planet has its own degree origin, its own movement, and its own projected price path.

The result is a charting tool for studying planetary price-time geometry, market vibration, harmonic resistance/support, and possible reversal timing.

[b]Disclaimer[/b]

This indicator is for educational and analytical purposes only. It does not provide financial advice or guaranteed market predictions. Always combine astro-Gann analysis with risk management, market structure, and independent trading judgment.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3

//@version=6
indicator("Astro: Time-Degree Trend Lines [invincible3]", overlay=true, max_labels_count=500, max_lines_count=50)

// ─────────────────────────────────────────────
// --- Inputs: Anchor PRICE + Anchor/End TIME ---
// ─────────────────────────────────────────────
GRP_RANGE = "Range Settings"

anchorPrice = input.price(45.0, "Anchor Price (start level)", confirm=true, group=GRP_RANGE)
anchorTime  = input.time(timestamp("2025-01-01T00:00:00"), "Anchor Time (start)", confirm=true, group=GRP_RANGE)
endTime     = input.time(timestamp("2025-02-01T00:00:00"), "End Time (stop)", confirm=true, group=GRP_RANGE)

GRP_SCALE = "Price Scale / Gann Degree Scale"

pointsPerDeg = input.float(1.0, "Points per 1°", step=0.01, group=GRP_SCALE)
speedHarmonic = input.float(
     1.0,
     "Speed Harmonic Multiplier",
     minval=0.01,
     maxval=2000,
     step=0.01,
     group=GRP_SCALE,
     tooltip="Multiplies planetary motion speed. Example: 2 = double motion speed. This is not a +360° octave shift."
)

showUpTrend   = input.bool(true,  "Show UpTrend Lines", group=GRP_SCALE)
showDownTrend = input.bool(false, "Show DownTrend Lines", group=GRP_SCALE)

showAnchorV = input.bool(true, "Show Anchor Vertical Line", group=GRP_RANGE)
showEndV    = input.bool(true, "Show End Vertical Line", group=GRP_RANGE)

// ─────────────────────────────────────────────
// --- Aspect Table inputs ---
// ─────────────────────────────────────────────
GRP_ASPECT = "Aspect Table"

showAspectTable = input.bool(true, "Show Aspect Table", group=GRP_ASPECT)
aspectMaxOrb    = input.float(
     6.0,
     "Max Orb to Show",
     minval=0.0,
     maxval=180.0,
     step=0.1,
     group=GRP_ASPECT,
     tooltip="Only planet pairs with orb less than or equal to this value are shown."
)

aspectTablePos  = input.string(
     "Top Right",
     "Table Position",
     options=[
         "Top Left", "Top Center", "Top Right",
         "Middle Left", "Middle Center", "Middle Right",
         "Bottom Left", "Bottom Center", "Bottom Right"
     ],
     group=GRP_ASPECT
)

// ─────────────────────────────────────────────
// --- Planet Starting Degrees at Anchor ---
// These are user-defined zodiac/Gann starting degrees.
// Aspect table uses: startDegree + range motion.
// ─────────────────────────────────────────────
GRP_START = "Planet Starting Degrees at Anchor"

sunStartDeg     = input.float(0.0, "☉ Sun Start Degree",     minval=0.0, maxval=360.0, step=0.01, group=GRP_START)
moonStartDeg    = input.float(0.0, "☾ Moon Start Degree",    minval=0.0, maxval=360.0, step=0.01, group=GRP_START)
mercuryStartDeg = input.float(0.0, "☿ Mercury Start Degree", minval=0.0, maxval=360.0, step=0.01, group=GRP_START)
venusStartDeg   = input.float(0.0, "♀ Venus Start Degree",   minval=0.0, maxval=360.0, step=0.01, group=GRP_START)
marsStartDeg    = input.float(0.0, "♂ Mars Start Degree",    minval=0.0, maxval=360.0, step=0.01, group=GRP_START)
jupiterStartDeg = input.float(0.0, "♃ Jupiter Start Degree", minval=0.0, maxval=360.0, step=0.01, group=GRP_START)
saturnStartDeg  = input.float(0.0, "♄ Saturn Start Degree",  minval=0.0, maxval=360.0, step=0.01, group=GRP_START)
uranusStartDeg  = input.float(0.0, "♅ Uranus Start Degree",  minval=0.0, maxval=360.0, step=0.01, group=GRP_START)
neptuneStartDeg = input.float(0.0, "♆ Neptune Start Degree", minval=0.0, maxval=360.0, step=0.01, group=GRP_START)
plutoStartDeg   = input.float(0.0, "♇ Pluto Start Degree",   minval=0.0, maxval=360.0, step=0.01, group=GRP_START)
nodeStartDeg    = input.float(0.0, "☊ Node Start Degree",    minval=0.0, maxval=360.0, step=0.01, group=GRP_START)

// ─────────────────────────────────────────────
// --- Planet toggles ---
// ─────────────────────────────────────────────
GRP_PLANETS = "Planet Visibility"

showSun     = input.bool(true,  "☉ Sun",     group=GRP_PLANETS)
showMoon    = input.bool(false, "☾ Moon",    group=GRP_PLANETS)
showMercury = input.bool(true,  "☿ Mercury", group=GRP_PLANETS)
showVenus   = input.bool(false, "♀ Venus",   group=GRP_PLANETS)
showMars    = input.bool(true,  "♂ Mars",    group=GRP_PLANETS)
showJupiter = input.bool(true,  "♃ Jupiter", group=GRP_PLANETS)
showSaturn  = input.bool(true,  "♄ Saturn",  group=GRP_PLANETS)
showUranus  = input.bool(false, "♅ Uranus",  group=GRP_PLANETS)
showNeptune = input.bool(false, "♆ Neptune", group=GRP_PLANETS)
showPluto   = input.bool(false, "♇ Pluto",   group=GRP_PLANETS)
showNode    = input.bool(false, "☊ Node",    group=GRP_PLANETS)

// ─────────────────────────────────────────────
// --- Colors ---
// ─────────────────────────────────────────────
GRP_COLORS = "Colors"

colSun     = input.color(color.orange,  "Sun Color",     group=GRP_COLORS)
colMoon    = input.color(color.silver,  "Moon Color",    group=GRP_COLORS)
colMercury = input.color(color.green,   "Mercury Color", group=GRP_COLORS)
colVenus   = input.color(color.fuchsia, "Venus Color",   group=GRP_COLORS)
colMars    = input.color(color.red,     "Mars Color",    group=GRP_COLORS)
colJupiter = input.color(color.lime,    "Jupiter Color", group=GRP_COLORS)
colSaturn  = input.color(color.rgb(238, 218, 43),  "Saturn Color",  group=GRP_COLORS)
colUranus  = input.color(color.teal,    "Uranus Color",  group=GRP_COLORS)
colNeptune = input.color(color.blue,    "Neptune Color", group=GRP_COLORS)
colPluto   = input.color(color.purple,  "Pluto Color",   group=GRP_COLORS)
colNode    = input.color(color.aqua,    "Node Color",    group=GRP_COLORS)

// ─────────────────────────────────────────────
// --- Average daily motion deg/day ---
// Node is negative because lunar nodes are normally retrograde.
// For price projection, absolute motion is used so lines stay visually directional.
// For aspect table, signed motion is used.
// ─────────────────────────────────────────────
SUN_D      = 0.9856
MOON_D     = 13.1764
MERCURY_D  = 4.092
VENUS_D    = 1.602
MARS_D     = 0.524
JUPITER_D  = 0.083
SATURN_D   = 0.033
URANUS_D   = 0.012
NEPTUNE_D  = 0.006
PLUTO_D    = 0.004
NODE_D     = -0.053

// ─────────────────────────────────────────────
// --- Helpers ---
// ─────────────────────────────────────────────
daysBetween(t1, t2) =>
    (t2 - t1) / 86400000.0

norm360(x) =>
    r = x % 360.0
    r < 0 ? r + 360.0 : r

angleDelta(degA, degB) =>
    raw = math.abs(norm360(degA) - norm360(degB))
    raw > 180.0 ? 360.0 - raw : raw

fmt(x) =>
    str.tostring(x, "#.##")

inWindow = time >= anchorTime and time <= endTime

daysFromAnchor_live = math.max((time - anchorTime) / 86400000.0, 0)
totalDays           = math.max(daysBetween(anchorTime, endTime), 0)

// Planetary motion from anchor.
motionDegFromAnchor_live(rate) =>
    daysFromAnchor_live * math.abs(rate) * speedHarmonic

motionDegTotal(rate) =>
    totalDays * math.abs(rate) * speedHarmonic

// Total Gann line degree includes planet starting degree.
// Example: startDeg = 4°, motion = 30° → line degree = 34°.
lineDegFromAnchor_live(startDeg, rate) =>
    startDeg + motionDegFromAnchor_live(rate)

lineDegTotal(startDeg, rate) =>
    startDeg + motionDegTotal(rate)

// Aspect longitude uses signed planetary motion.
rangeEndLongitude(startDeg, rate) =>
    norm360(startDeg + totalDays * rate * speedHarmonic)

// Price projection now uses starting degree also.
projPrice_live(startDeg, rate, isUp) =>
    deg = lineDegFromAnchor_live(startDeg, rate)
    isUp ? anchorPrice + deg * pointsPerDeg : anchorPrice - deg * pointsPerDeg

endPrice(startDeg, rate, isUp) =>
    deg = lineDegTotal(startDeg, rate)
    isUp ? anchorPrice + deg * pointsPerDeg : anchorPrice - deg * pointsPerDeg

// ─────────────────────────────────────────────
// --- Projected prices ---
// ─────────────────────────────────────────────
sunUp  = projPrice_live(sunStartDeg,     SUN_D,     true),  sunDn  = projPrice_live(sunStartDeg,     SUN_D,     false)
moonUp = projPrice_live(moonStartDeg,    MOON_D,    true),  moonDn = projPrice_live(moonStartDeg,    MOON_D,    false)
merUp  = projPrice_live(mercuryStartDeg, MERCURY_D, true),  merDn  = projPrice_live(mercuryStartDeg, MERCURY_D, false)
venUp  = projPrice_live(venusStartDeg,   VENUS_D,   true),  venDn  = projPrice_live(venusStartDeg,   VENUS_D,   false)
marsUp = projPrice_live(marsStartDeg,    MARS_D,    true),  marsDn = projPrice_live(marsStartDeg,    MARS_D,    false)
jupUp  = projPrice_live(jupiterStartDeg, JUPITER_D, true),  jupDn  = projPrice_live(jupiterStartDeg, JUPITER_D, false)
satUp  = projPrice_live(saturnStartDeg,  SATURN_D,  true),  satDn  = projPrice_live(saturnStartDeg,  SATURN_D,  false)
uraUp  = projPrice_live(uranusStartDeg,  URANUS_D,  true),  uraDn  = projPrice_live(uranusStartDeg,  URANUS_D,  false)
nepUp  = projPrice_live(neptuneStartDeg, NEPTUNE_D, true),  nepDn  = projPrice_live(neptuneStartDeg, NEPTUNE_D, false)
pluUp  = projPrice_live(plutoStartDeg,   PLUTO_D,   true),  pluDn  = projPrice_live(plutoStartDeg,   PLUTO_D,   false)
nodUp  = projPrice_live(nodeStartDeg,    NODE_D,    true),  nodDn  = projPrice_live(nodeStartDeg,    NODE_D,    false)

// ─────────────────────────────────────────────
// --- Plots ---
// ─────────────────────────────────────────────
plot(showUpTrend and showSun     and inWindow ? sunUp  : na, title="Sun Up",     linewidth=2, color=colSun)
plot(showUpTrend and showMoon    and inWindow ? moonUp : na, title="Moon Up",    linewidth=2, color=colMoon)
plot(showUpTrend and showMercury and inWindow ? merUp  : na, title="Mercury Up", linewidth=2, color=colMercury)
plot(showUpTrend and showVenus   and inWindow ? venUp  : na, title="Venus Up",   linewidth=2, color=colVenus)
plot(showUpTrend and showMars    and inWindow ? marsUp : na, title="Mars Up",    linewidth=2, color=colMars)
plot(showUpTrend and showJupiter and inWindow ? jupUp  : na, title="Jupiter Up", linewidth=2, color=colJupiter)
plot(showUpTrend and showSaturn  and inWindow ? satUp  : na, title="Saturn Up",  linewidth=2, color=colSaturn)
plot(showUpTrend and showUranus  and inWindow ? uraUp  : na, title="Uranus Up",  linewidth=2, color=colUranus)
plot(showUpTrend and showNeptune and inWindow ? nepUp  : na, title="Neptune Up", linewidth=2, color=colNeptune)
plot(showUpTrend and showPluto   and inWindow ? pluUp  : na, title="Pluto Up",   linewidth=2, color=colPluto)
plot(showUpTrend and showNode    and inWindow ? nodUp  : na, title="Node Up",    linewidth=2, color=colNode)

plot(showDownTrend and showSun     and inWindow ? sunDn  : na, title="Sun Down",     linewidth=2, color=color.new(colSun, 25))
plot(showDownTrend and showMoon    and inWindow ? moonDn : na, title="Moon Down",    linewidth=2, color=color.new(colMoon, 25))
plot(showDownTrend and showMercury and inWindow ? merDn  : na, title="Mercury Down", linewidth=2, color=color.new(colMercury, 25))
plot(showDownTrend and showVenus   and inWindow ? venDn  : na, title="Venus Down",   linewidth=2, color=color.new(colVenus, 25))
plot(showDownTrend and showMars    and inWindow ? marsDn : na, title="Mars Down",    linewidth=2, color=color.new(colMars, 25))
plot(showDownTrend and showJupiter and inWindow ? jupDn  : na, title="Jupiter Down", linewidth=2, color=color.new(colJupiter, 25))
plot(showDownTrend and showSaturn  and inWindow ? satDn  : na, title="Saturn Down",  linewidth=2, color=color.new(colSaturn, 25))
plot(showDownTrend and showUranus  and inWindow ? uraDn  : na, title="Uranus Down",  linewidth=2, color=color.new(colUranus, 25))
plot(showDownTrend and showNeptune and inWindow ? nepDn  : na, title="Neptune Down", linewidth=2, color=color.new(colNeptune, 25))
plot(showDownTrend and showPluto   and inWindow ? pluDn  : na, title="Pluto Down",   linewidth=2, color=color.new(colPluto, 25))
plot(showDownTrend and showNode    and inWindow ? nodDn  : na, title="Node Down",    linewidth=2, color=color.new(colNode, 25))

// ─────────────────────────────────────────────
// --- Vertical lines ---
// ─────────────────────────────────────────────
isAnchorCross = time >= anchorTime and (na(time[1]) or time[1] < anchorTime)
isEndCross    = time >= endTime    and (na(time[1]) or time[1] < endTime)

anchorBar = ta.valuewhen(isAnchorCross, bar_index, 0)
endBar    = ta.valuewhen(isEndCross,    bar_index, 0)

var line lnA = na
var line lnE = na

if barstate.islast
    if showAnchorV and not na(anchorBar)
        line.delete(lnA)
        lnA := line.new(anchorBar, low, anchorBar, high, extend=extend.both, width=1, style=line.style_dashed, color=chart.fg_color)

    if showEndV and not na(endBar)
        line.delete(lnE)
        lnE := line.new(endBar, low, endBar, high, extend=extend.both, width=1, style=line.style_dashed, color=chart.fg_color)

// ─────────────────────────────────────────────
// --- Labels at End Bar ---
// Label now shows:
// Δ = motion over selected range
// End = final range longitude after applying starting degree
// ─────────────────────────────────────────────
var label[] labs = array.new_label()

makeLab(on, name, rate, startDeg, col, isUp) =>
    if on and barstate.islast and not na(endBar)
        moveDeg = motionDegTotal(rate)
        lineDeg = lineDegTotal(startDeg, rate)
        lon     = rangeEndLongitude(startDeg, rate)
        p_val   = endPrice(startDeg, rate, isUp)

        dirTxt = isUp ? "▲" : "▼"

        txt = dirTxt + " " + name +
              " | Start " + fmt(startDeg) + "°" +
              " | Move " + fmt(moveDeg) + "°" +
              " | End " + fmt(lon) + "°" +
              " | " + fmt(p_val)

        lb = label.new(
             endBar,
             p_val,
             txt,
             style=label.style_label_left,
             textcolor=chart.bg_color,
             color=isUp ? col : color.new(col, 25),
             size=size.small
        )

        array.push(labs, lb)

if barstate.islast
    if array.size(labs) > 0
        for i = 0 to array.size(labs) - 1
            label.delete(array.get(labs, i))
    array.clear(labs)

    if showUpTrend
        makeLab(showSun,     "Sun",     SUN_D,     sunStartDeg,     colSun,     true)
        makeLab(showMoon,    "Moon",    MOON_D,    moonStartDeg,    colMoon,    true)
        makeLab(showMercury, "Mercury", MERCURY_D, mercuryStartDeg, colMercury, true)
        makeLab(showVenus,   "Venus",   VENUS_D,   venusStartDeg,   colVenus,   true)
        makeLab(showMars,    "Mars",    MARS_D,    marsStartDeg,    colMars,    true)
        makeLab(showJupiter, "Jupiter", JUPITER_D, jupiterStartDeg, colJupiter, true)
        makeLab(showSaturn,  "Saturn",  SATURN_D,  saturnStartDeg,  colSaturn,  true)
        makeLab(showUranus,  "Uranus",  URANUS_D,  uranusStartDeg,  colUranus,  true)
        makeLab(showNeptune, "Neptune", NEPTUNE_D, neptuneStartDeg, colNeptune, true)
        makeLab(showPluto,   "Pluto",   PLUTO_D,   plutoStartDeg,   colPluto,   true)
        makeLab(showNode,    "Node",    NODE_D,    nodeStartDeg,    colNode,    true)

    if showDownTrend
        makeLab(showSun,     "Sun",     SUN_D,     sunStartDeg,     colSun,     false)
        makeLab(showMoon,    "Moon",    MOON_D,    moonStartDeg,    colMoon,    false)
        makeLab(showMercury, "Mercury", MERCURY_D, mercuryStartDeg, colMercury, false)
        makeLab(showVenus,   "Venus",   VENUS_D,   venusStartDeg,   colVenus,   false)
        makeLab(showMars,    "Mars",    MARS_D,    marsStartDeg,    colMars,    false)
        makeLab(showJupiter, "Jupiter", JUPITER_D, jupiterStartDeg, colJupiter, false)
        makeLab(showSaturn,  "Saturn",  SATURN_D,  saturnStartDeg,  colSaturn,  false)
        makeLab(showUranus,  "Uranus",  URANUS_D,  uranusStartDeg,  colUranus,  false)
        makeLab(showNeptune, "Neptune", NEPTUNE_D, neptuneStartDeg, colNeptune, false)
        makeLab(showPluto,   "Pluto",   PLUTO_D,   plutoStartDeg,   colPluto,   false)
        makeLab(showNode,    "Node",    NODE_D,    nodeStartDeg,    colNode,    false)

// ─────────────────────────────────────────────
// --- Aspect Table Logic ---
// Now uses corrected range-based longitude:
// End Longitude = Start Degree + signed planetary motion over selected range.
// ─────────────────────────────────────────────
nearestGannAspect(delta) =>
    float[] aspects = array.from(0.0, 30.0, 45.0, 60.0, 72.0, 90.0, 120.0, 135.0, 144.0, 150.0, 180.0)
    float bestAspect = 0.0
    float minOrb = 1000.0

    for a in aspects
        orb = math.abs(delta - a)
        if orb < minOrb
            minOrb := orb
            bestAspect := a

    [bestAspect, minOrb]

// Professional table colors
COLOR_BG     = #1e222d
COLOR_HEADER = #2a2e39
COLOR_TEXT   = #d1d4dc
COLOR_TIGHT  = color.new(#089981, 20)
COLOR_MED    = color.rgb(89, 8, 140, 20)
COLOR_WIDE   = color.new(#787b86, 20)

aspectCellBg(orb) =>
    orb <= 1.0 ? COLOR_TIGHT : orb <= 3.0 ? COLOR_MED : COLOR_BG

aspectPosition(pos) =>
    switch pos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

// Arrays for planet-pair loop
var string[] p_names = array.from(
     "Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter",
     "Saturn", "Uranus", "Neptune", "Pluto", "Node"
)

var float[] p_rates = array.from(
     SUN_D, MOON_D, MERCURY_D, VENUS_D, MARS_D, JUPITER_D,
     SATURN_D, URANUS_D, NEPTUNE_D, PLUTO_D, NODE_D
)

bool[] p_shows = array.from(
     showSun, showMoon, showMercury, showVenus, showMars, showJupiter,
     showSaturn, showUranus, showNeptune, showPluto, showNode
)

float[] p_starts = array.from(
     sunStartDeg, moonStartDeg, mercuryStartDeg, venusStartDeg, marsStartDeg, jupiterStartDeg,
     saturnStartDeg, uranusStartDeg, neptuneStartDeg, plutoStartDeg, nodeStartDeg
)

var table aspTbl = table.new(
     aspectPosition(aspectTablePos),
     4,
     60,
     border_width=1,
     border_color=#363a45,
     frame_width=1,
     frame_color=#363a45
)

if barstate.islast and showAspectTable
    table.clear(aspTbl, 0, 0, 3, 59)

    // Header
    table.cell(aspTbl, 0, 0, "Pair",       text_color=COLOR_TEXT, bgcolor=COLOR_HEADER, text_size=size.small)
    table.cell(aspTbl, 1, 0, "Aspect",     text_color=COLOR_TEXT, bgcolor=COLOR_HEADER, text_size=size.small)
    table.cell(aspTbl, 2, 0, "Delta@End",  text_color=COLOR_TEXT, bgcolor=COLOR_HEADER, text_size=size.small)
    table.cell(aspTbl, 3, 0, "Orb",        text_color=COLOR_TEXT, bgcolor=COLOR_HEADER, text_size=size.small)

    int n_planets = array.size(p_names)
    int rowIdx = 1

    if n_planets > 1
        for i = 0 to n_planets - 2
            for j = i + 1 to n_planets - 1
                if array.get(p_shows, i) and array.get(p_shows, j)
                    startA = array.get(p_starts, i)
                    startB = array.get(p_starts, j)

                    rateA = array.get(p_rates, i)
                    rateB = array.get(p_rates, j)

                    lonA = rangeEndLongitude(startA, rateA)
                    lonB = rangeEndLongitude(startB, rateB)

                    delta = angleDelta(lonA, lonB)
                    [asp, orb] = nearestGannAspect(delta)

                    if orb <= aspectMaxOrb and rowIdx < 60
                        bg = aspectCellBg(orb)

                        nameA = array.get(p_names, i)
                        nameB = array.get(p_names, j)

                        table.cell(aspTbl, 0, rowIdx, nameA + " / " + nameB, text_color=COLOR_TEXT, bgcolor=bg, text_size=size.small)
                        table.cell(aspTbl, 1, rowIdx, str.tostring(asp, "#") + "°", text_color=COLOR_TEXT, bgcolor=bg, text_size=size.small)
                        table.cell(aspTbl, 2, rowIdx, fmt(delta) + "°", text_color=COLOR_TEXT, bgcolor=bg, text_size=size.small)
                        table.cell(aspTbl, 3, rowIdx, fmt(orb) + "°", text_color=COLOR_TEXT, bgcolor=bg, text_size=size.small)

                        rowIdx += 1

    if rowIdx == 1
        table.cell(aspTbl, 0, 1, "No pairs within orb", text_color=COLOR_TEXT, bgcolor=COLOR_BG, text_size=size.small)
        table.merge_cells(aspTbl, 0, 1, 3, 1)

if barstate.islast and not showAspectTable
    table.clear(aspTbl, 0, 0, 3, 59)
````
