# Lunar Azimuth Day Partitions

- url: https://www.tradingview.com/script/Oyo8ZyJa-Lunar-Azimuth-Day-Partitions/
- type: indicator
- pine_id: PUB;8fa724e3a6184dfe8be03d4b145a9b94
- version: 1.0

## Description

What it does
Locks the Moon’s azimuth at a draggable time for CME (Chicago), then finds the moment on the next local calendar day when the Moon is closest to that same bearing. The gap between those two times is your “lunar day” (~24h 50m). That interval is split into equal fractions (½, ¼, ⅛, …) with vertical lines on the price chart.

Use case
Mark a significant High/Low (or any event), drag the blue anchor there, and use the next-day same-azimuth time plus the partition grid as a time map for the following session—possible reaction windows, turn timing, or structure between “same sky bearing” days—without using New/Full phase or declination.

## Source Code

````pine
//@version=6
indicator("Lunar Azimuth Day Partitions", overlay = true, max_lines_count = 500, max_labels_count = 20)

// ── Location (CME) ──────────────────────────────────────────────────────────
grpLoc = "Location"
latInput = input.float(41.8781, "Latitude", step = 0.0001, group = grpLoc)
lonInput = input.float(-87.6358, "Longitude", step = 0.0001, group = grpLoc)
tzInput  = input.string("America/Chicago", "Timezone", group = grpLoc)

// ── Anchor ──────────────────────────────────────────────────────────────────
grpA = "Anchor"
anchorTime = input.time(timestamp("2025-07-31 15:21"), "Azimuth Anchor (drag me)", confirm = true, group = grpA)
showAnchor = input.bool(true, "Show Anchor Line", group = grpA)

// ── Match / search ──────────────────────────────────────────────────────────
grpM = "Next-Day Match"
scanStepMin = input.int(1, "Scan Step (minutes)", minval = 1, maxval = 15, group = grpM,
     tooltip = "Finer = closer match, heavier on last bar.")
showEnd = input.bool(true, "Show Match Line (next day)", group = grpM)

// ── Partitions ──────────────────────────────────────────────────────────────
grpP = "Partitions"
showPartitions = input.bool(true, "Show Partition Lines", group = grpP)
scaleMultStr = input.string("1/4", "Partition Fraction",
     options = ["1", "1/2", "1/4", "1/8", "1/16", "1/32", "1/64", "1/128", "1/256", "1/512", "1/1024"], group = grpP)
partColor = input.color(color.new(color.gray, 50), "Partition Color", group = grpP)
partStyleStr = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = grpP)
endColor = input.color(color.orange, "Match Line Color", group = grpP)

float scaleMultiplier = switch scaleMultStr
    "1/1024" => 1.0 / 1024.0
    "1/512"  => 1.0 / 512.0
    "1/256"  => 1.0 / 256.0
    "1/128"  => 1.0 / 128.0
    "1/64"   => 1.0 / 64.0
    "1/32"   => 1.0 / 32.0
    "1/16"   => 1.0 / 16.0
    "1/8"    => 1.0 / 8.0
    "1/4"    => 1.0 / 4.0
    "1/2"    => 1.0 / 2.0
    => 1.0

// ── Astronomy helpers (compact Meeus → RA/Dec → Azimuth) ────────────────────
deg2rad(x) => x * math.pi / 180.0
rad2deg(x) => x * 180.0 / math.pi
mod360(x) =>
    v = x % 360.0
    v < 0 ? v + 360.0 : v

// atan2(y, x) — returns radians in (-pi, pi]
atan2(float y, float x) =>
    float a = na
    if x > 0
        a := math.atan(y / x)
    else if x < 0 and y >= 0
        a := math.atan(y / x) + math.pi
    else if x < 0 and y < 0
        a := math.atan(y / x) - math.pi
    else if x == 0 and y > 0
        a := math.pi / 2
    else if x == 0 and y < 0
        a := -math.pi / 2
    else
        a := 0.0
    a

// Julian Day from unix ms
jdFromMs(int t) =>
    t / 86400000.0 + 2440587.5

// Approximate Moon RA (deg), Dec (deg) — low-precision Meeus
moonRaDec(float jd) =>
    T = (jd - 2451545.0) / 36525.0
    Lp = mod360(218.3164477 + 481267.88123421 * T)
    D  = mod360(297.8501921 + 445267.1114034 * T)
    M  = mod360(357.5291092 + 35999.0502909 * T)
    Mp = mod360(134.9633964 + 477198.8675055 * T)
    F  = mod360(93.2720950 + 483202.0175233 * T)

    // Ecliptic longitude / latitude (leading terms)
    lam = Lp
         + 6.289 * math.sin(deg2rad(Mp))
         + 1.274 * math.sin(deg2rad(2*D - Mp))
         + 0.658 * math.sin(deg2rad(2*D))
         + 0.214 * math.sin(deg2rad(2*Mp))
         - 0.186 * math.sin(deg2rad(M))
         - 0.114 * math.sin(deg2rad(2*F))
    beta = 5.128 * math.sin(deg2rad(F))
         + 0.281 * math.sin(deg2rad(Mp + F))
         + 0.278 * math.sin(deg2rad(Mp - F))
         + 0.173 * math.sin(deg2rad(2*D - F))

    // Mean obliquity
    eps = 23.439291 - 0.0130042 * T

    lamR = deg2rad(mod360(lam))
    betaR = deg2rad(beta)
    epsR = deg2rad(eps)

    sinDec = math.sin(betaR) * math.cos(epsR) + math.cos(betaR) * math.sin(epsR) * math.sin(lamR)
    dec = rad2deg(math.asin(sinDec))

    y = math.sin(lamR) * math.cos(epsR) - math.tan(betaR) * math.sin(epsR)
    x = math.cos(lamR)
    ra = mod360(rad2deg(atan2(y, x)))
    [ra, dec]

// GMST degrees at JD (approx)
gmstDeg(float jd) =>
    T = (jd - 2451545.0) / 36525.0
    mod360(280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * T * T)

// Moon azimuth degrees, 0 = North, clockwise (compass-style)
moonAzimuth(int tMs, float latDeg, float lonDeg) =>
    jd = jdFromMs(tMs)
    [ra, dec] = moonRaDec(jd)
    lst = mod360(gmstDeg(jd) + lonDeg)
    ha = deg2rad(mod360(lst - ra))
    phi = deg2rad(latDeg)
    decR = deg2rad(dec)

    y = math.sin(ha)
    x = math.cos(ha) * math.sin(phi) - math.tan(decR) * math.cos(phi)
    // atan2(y,x) with this x,y → azimuth from north, increasing east/clockwise
    az = mod360(rad2deg(atan2(y, x)))
    az

azDist(float a, float b) =>
    d = math.abs(mod360(a) - mod360(b))
    math.min(d, 360.0 - d)

// Start of local calendar day containing t (ms), tz-aware via components
localDayStartMs(int tMs, string tz) =>
    y = year(tMs, tz)
    m = month(tMs, tz)
    d = dayofmonth(tMs, tz)
    // timestamp() is exchange/UTC-based; build noon UTC then nudge — use hour/minute zero in tz:
    // Pine: timestamp(tz, year, month, day, hour, minute, second)
    timestamp(tz, y, m, d, 0, 0, 0)

nextLocalDayStartMs(int tMs, string tz) =>
    // local day start + 25h then re-floor → safe across DST
    s0 = localDayStartMs(tMs, tz)
    localDayStartMs(s0 + 25 * 60 * 60 * 1000, tz)

// ── Drawing state ───────────────────────────────────────────────────────────
var line anchorLine = na
var line matchLine  = na
var array<line> partLines = array.new<line>()
var label infoLab = na

clearParts() =>
    if array.size(partLines) > 0
        for i = 0 to array.size(partLines) - 1
            line.delete(array.get(partLines, i))
        array.clear(partLines)

if barstate.islast
    clearParts()

    float lat = latInput
    float lon = lonInput
    string tz = tzInput

    az0 = moonAzimuth(anchorTime, lat, lon)

    // Scan only the next local calendar day
    day0 = localDayStartMs(anchorTime, tz)
    day1 = nextLocalDayStartMs(anchorTime, tz)
    day2 = nextLocalDayStartMs(day1, tz)

    stepMs = scanStepMin * 60 * 1000
    int bestT = na
    float bestDist = 999.0
    float bestAz = na

    tScan = day1
    // hard cap iterations (~1 day / 1 min = 1440)
    maxIter = int(math.ceil((day2 - day1) / stepMs)) + 2
    for i = 0 to maxIter
        tScan := day1 + i * stepMs
        if tScan >= day2
            break
        az = moonAzimuth(tScan, lat, lon)
        dist = azDist(az, az0)
        if dist < bestDist
            bestDist := dist
            bestT := tScan
            bestAz := az

    // Anchor line
    if showAnchor
        if na(anchorLine)
            anchorLine := line.new(anchorTime, close, anchorTime, close, xloc = xloc.bar_time, extend = extend.both, color = color.blue, style = line.style_dashed, width = 2)
        else
            line.set_x1(anchorLine, anchorTime)
            line.set_x2(anchorLine, anchorTime)

    // Match line + partitions
    if not na(bestT) and bestT > anchorTime
        if showEnd
            if na(matchLine)
                matchLine := line.new(bestT, close, bestT, close, xloc = xloc.bar_time, extend = extend.both, color = endColor, style = line.style_solid, width = 2)
            else
                line.set_x1(matchLine, bestT)
                line.set_x2(matchLine, bestT)

        span = bestT - anchorTime
        if showPartitions and scaleMultiplier > 0 and span > 0
            lineStyle = partStyleStr == "Solid" ? line.style_solid : partStyleStr == "Dashed" ? line.style_dashed : line.style_dotted
            stepP = math.max(1, int(math.round(span * scaleMultiplier)))
            maxParts = 480
            est = int(math.floor(span / stepP))
            if est > maxParts
                stepP := int(math.ceil(span / maxParts))
            cur = anchorTime + stepP
            n = 0
            while cur < bestT and n < maxParts
                array.push(partLines, line.new(cur, close, cur, close, xloc = xloc.bar_time, extend = extend.both, color = partColor, style = lineStyle, width = 1))
                cur += stepP
                n += 1

        hrs = span / 3600000.0
        msg = "Az0 " + str.tostring(az0, "#.##") + "° → next day " + str.tostring(bestAz, "#.##") + "° (Δ " + str.tostring(bestDist, "#.##") + "°) | " + str.tostring(hrs, "#.##") + "h"
        if na(infoLab)
            infoLab := label.new(bestT, high, msg, xloc = xloc.bar_time, style = label.style_label_down, color = color.new(color.black, 25), textcolor = color.white, size = size.small)
        else
            label.set_xy(infoLab, bestT, high)
            label.set_text(infoLab, msg)
    else
        if not na(matchLine)
            line.delete(matchLine)
            matchLine := na
````
