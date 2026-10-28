# Strong Liquidity Zones | ProjectSyndicate

- url: https://www.tradingview.com/script/rJyL4xXy-Strong-Liquidity-Zones-ProjectSyndicate/
- type: indicator
- pine_id: PUB;81064824c83440c284c0ef6bade4c765
- version: 1.0

## Description

[b]Strong Liquidity Zones

Strong Liquidity Zones finds the price levels where liquidity actually pools — then power-ranks them so you instantly know which zone is likely to hold and which is likely to give way. It detects three independent footprints of liquidity (swing pivots, wick-rejection traps, and volume spikes), merges overlapping detections into confluence clusters, and scores each cluster 0–10 from real, measurable level quality. Strong, multi-confluence zones are framed and highlighted; weak, single-touch zones stay faint. A live dashboard lists every viable level, ranked, so the whole map of support and resistance is readable at a glance.[/b]

🎯 Power-Ranking System (0–10) — every zone earns a live grade from four sign-stable factors: confluence (how many separate detections stack at the level, with diminishing returns so a single tap can't fake strength), detection diversity (a level confirmed by pivots and wick traps and volume carries far more weight than one confirmed a single way), detection strength (volume vs baseline, wick dominance, and range expansion on the forming candle), and recency (freshly defended levels score higher than stale ones). ELITE (9–10) is deliberately rare — it requires genuine all-three-type confluence on a strong, recent level, so the number reflects real edge, not decoration.
🏷️ In-Zone Strength Labels — each zone carries its grade inside the band: side (Bull/Bear), tier, the X/10 score, a star rating, the confluence count (×N detections that built it), and live distance from price in both % and pips. Quality and proximity read instantly without hunting through a panel.
🧲 Confluence Clustering — instead of plotting every raw detection as its own line, nearby detections are grouped into a single strength-weighted zone centered on where the liquidity truly sits. One clean level per pool, not a cluttered stack.
🥇 ELITE Highlighting — the strongest clusters are rendered as a brighter shade of the same side colour with a heavy border, so the levels that matter most stand out before you read a single number. Tier ladder: FAINT → WEAK → MEDIUM → STRONG → ELITE.

🎨 Strength-Shaded Fill — stronger zones render sharper and more opaque while weak ones stay faint, so the chart shows which levels carry weight at a glance.
📊 Live Level Dashboard — an on-chart leaderboard lists every active zone sorted by power and distance from price, with tier, side, exact price, score, and direction (▲ above / ▼ below). Adjustable position and text size (Small → Huge). See all viable levels at once, ranked.
📍 Origin-Anchored Zones — every zone is drawn from the bar where the level was first established and extends to the right, so each band is visually tied to the price action that created it — never floating in mid-air.
🔒 Stable, Lock-In Zones — zones are created only on confirmed bars and reconciled in place: once a zone is on the chart it keeps its grade, tier, and position and won't flicker or shuffle intraday. A zone is removed only when price genuinely breaches it or the level is invalidated — one clean transition, never random blinking.
🧹 Score Filter — hide every cluster below a chosen power rank so the chart only carries the levels that earned their place, plus a minimum-separation and minimum-distance-from-price control to keep the picture clean.

🔔 Native Alerts — dedicated alerts for an ELITE (9–10) cluster forming, a STRONG (7–8) cluster forming, a zone being breached, and fresh bullish / bearish liquidity detections — so you never miss a high-quality level appearing or failing.
🔧 Fully Customizable — detection sensitivity (pivot length, wick-dominance ratio, volume-spike multiplier, strength threshold), clustering (tolerance, lookback, minimum points, minimum rank, re-cluster interval, distance-from-price), zone geometry (ATR period, width, max active zones, separation), display (label size, fill opacity, elite border thickness), dashboard (position, rows, text size), and the full colour theme — all adjustable.
🎯 Why this is different — most "liquidity" or "support/resistance" tools dump every swing onto the chart and leave you to guess which line matters. This one fuses three independent liquidity footprints, clusters them into clean zones, and quantifies each one from real level quality — then tells you the probability-weighted answer: a STRONG/ELITE zone is one to fade, a WEAK zone is one that's likely to break. The scoring even informs how you trade each level (see below).

[b]🚀 Apply to Gold (XAUUSD), Silver, Forex, Crypto, and Indices on any timeframe.[/b]

🎯 How To Trade It — Two Approaches

The score is the filter that decides which approach fits. Strong, multi-confluence zones tend to hold and reverse; weak, thin zones tend to break. So play them differently.
1) Fade the Zone — Reversion (use on STRONG / ELITE zones, ≥7)
Best when the zone price is approaching is rated STRONG or ELITE — these carry the most confluence and are statistically the most likely to hold.

Wait for price to tap into the high-grade zone (the dashboard's ▲/▼ distance shows it approaching).
Look for rejection: a wick into the band and a close back out of it — the liquidity above/below the level gets swept, then price turns.
Entry: on the reversal back out of the zone (close rejecting the band).
Stop: just beyond the far edge of the zone — if price closes through and holds, the level has failed and the fade thesis is wrong.
Targets: the next zone in the dashboard, then the opposite side's nearest strong zone.
Use the STRONG / ELITE cluster alert to know the moment a high-grade level appears, and the distance readout to time the tap.

2) Trade the Break — Continuation (use on WEAK / MEDIUM zones, or once a strong zone breaches)
Best when the level is rated WEAK or MEDIUM (thin, single-type, or stale) — these are the levels most likely to give way.

Wait for a decisive close through the zone on expanding volume — not a single wick.
The zone flipping from active to breached on the chart is your confirmation it's a genuine break, not a stop-hunt.
Entry: in the direction of the break on the close beyond the zone, or on a retest of the broken zone (a broken bull zone flips to resistance; a broken bear zone flips to support).
Stop: back inside the broken zone.
Targets: the next zone in that direction on the dashboard, trailing as the move extends.

[b]Rule of thumb: ⭐ STRONG / ELITE → expect a reaction, fade the tap. ⭐ WEAK / MEDIUM on volume → expect follow-through, trade the break.[/b]

⚠️ IMPORTANT NOTICE: This indicator identifies high-probability liquidity levels and frames fade-vs-break scenarios. It should NOT be used as a standalone signal for entering trades. Always combine it with your own strategy, price-action analysis, and risk management to confirm setups. Past statistical behavior does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Strong Liquidity Zones", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

pivotLength       = input.int(10, "Pivot Detection Length", minval=3, maxval=50, group="Detection", tooltip="Bars to look left/right for a fractal pivot")
wickRatio         = input.float(0.5, "Wick Dominance Ratio", minval=0.3, maxval=0.85, step=0.05, group="Detection", tooltip="Minimum wick-to-range ratio for a liquidity trap")
volMultiplier     = input.float(1.3, "Volume Spike Multiplier", minval=1.0, maxval=4.0, step=0.1, group="Detection", tooltip="Volume must exceed its average by this factor")
strengthThreshold = input.float(1.5, "Detection Strength Threshold", minval=1.0, maxval=3.0, step=0.1, group="Detection", tooltip="Minimum raw strength for a detection point to count")

enableClustering    = input.bool(true, "Enable Confluence Clustering", group="Clustering", tooltip="Group nearby detections into power-ranked clusters")
lookbackBars        = input.int(750, "Cluster Lookback Bars", minval=50, maxval=1000, group="Clustering", tooltip="How far back to keep detection points")
clusterTolerance    = input.float(0.6, "Cluster Tolerance (ATR Multiple)", minval=0.2, maxval=2.0, step=0.1, group="Clustering", tooltip="Max distance to merge points into one cluster")
minClusterSize      = input.int(1, "Min Points per Cluster", minval=1, maxval=5, group="Clustering", tooltip="Minimum detections needed to plot a cluster")
minPowerRank        = input.int(3, "Min Power Rank to Display", minval=0, maxval=10, group="Clustering", tooltip="Hide clusters weaker than this")
reclusterInterval   = input.int(5, "Re-cluster Every N Bars", minval=1, maxval=50, group="Clustering", tooltip="How often clusters are recomputed")
minDistanceFromPrice= input.float(1.5, "Min Distance from Price (ATR)", minval=0.0, maxval=10.0, step=0.5, group="Clustering", tooltip="Hide zones nearer than this to current price")

zoneAtrPeriod       = input.int(14, "Zone ATR Period", minval=10, maxval=50, group="Zone Settings")
zoneWidthMultiplier = input.float(0.5, "Zone Width (ATR Multiple)", minval=0.2, maxval=1.5, step=0.1, group="Zone Settings")
maxZones            = input.int(10, "Max Active Zones", minval=2, maxval=20, group="Zone Settings")
minSeparation       = input.float(1.8, "Min Zone Separation (ATR)", minval=0.5, maxval=5.0, step=0.25, group="Zone Settings")

showCurrentZones  = input.bool(true,  "Show Active Zones", group="Display")
showHistoricZones = input.bool(false, "Show Breached Zones", group="Display")
showZoneLabels    = input.bool(true,  "Show Zone Labels", group="Display")
showEliteTag      = input.bool(true,  "Tag + Frame ELITE Zones", group="Display", tooltip="Mark elite (9-10) clusters with a heavy border and brighter fill")
showPivotMarkers  = input.bool(false, "Show Pivot Markers", group="Display")
showDistancePct   = input.bool(true,  "Show Distance %", group="Display")
showDistancePips  = input.bool(true,  "Show Distance Pips", group="Display")
zoneLabelSize     = input.string("Normal", "Zone Label Size", options=["Small","Normal","Large","Huge"], group="Display")
eliteBorderWidth  = input.int(3, "Elite Border Thickness", minval=1, maxval=6, group="Display")
zoneOpacity       = input.int(85, "Base Zone Opacity", minval=20, maxval=95, group="Display", tooltip="Transparency of weaker zones; stronger tiers are progressively brighter")

showDashboard = input.bool(true, "Show Dashboard", group="Dashboard")
dashPosInput  = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group="Dashboard")
maxDashRows   = input.int(12, "Max Levels Listed", minval=3, maxval=25, group="Dashboard", tooltip="How many viable levels to list in the dashboard")
dashTextSize  = input.string("Normal", "Dashboard Text Size", options=["Small","Normal","Large","Huge"], group="Dashboard")

bullZoneColor = input.color(#2DD4A8, "Bull Zone (base hue)", group="Theme", tooltip="ELITE bull = a brighter shade of this same hue")
bearZoneColor = input.color(#E03E5C, "Bear Zone (base hue)", group="Theme", tooltip="ELITE bear = a brighter shade of this same hue")
breachedColor = input.color(#5C6370, "Breached Zone", group="Theme")
panelBg       = input.color(#0E1117, "Dashboard Background", group="Theme")
panelText     = input.color(#C8CDD6, "Dashboard Text", group="Theme")

zlSize = zoneLabelSize == "Small" ? size.small : zoneLabelSize == "Large" ? size.large : zoneLabelSize == "Huge" ? size.huge : size.normal
dTxt   = dashTextSize  == "Small" ? size.small : dashTextSize  == "Large" ? size.large : dashTextSize  == "Huge" ? size.huge : size.normal

zoneAtr                 = ta.atr(zoneAtrPeriod)
zoneWidth               = zoneAtr * zoneWidthMultiplier
minZoneGap              = zoneAtr * minSeparation
clusterToleranceDistance= zoneAtr * clusterTolerance
volSma                  = ta.sma(volume, 20)
avgRangeATR             = ta.atr(14)

pivotLeftBars  = math.floor(pivotLength / 2)
pivotRightBars = math.floor(pivotLength / 2)
pivotHigh = ta.pivothigh(high, pivotLeftBars, pivotRightBars)
pivotLow  = ta.pivotlow(low, pivotLeftBars, pivotRightBars)

candleRange = high - low
upperWick   = high - math.max(open, close)
lowerWick   = math.min(open, close) - low
highest10   = ta.highest(high, 10)
lowest10    = ta.lowest(low, 10)

isBearWickTrap = candleRange > 0 and upperWick / candleRange > wickRatio and close < open
isBearVolSpike = volume > volSma * volMultiplier and close < open and high == highest10
isBullWickTrap = candleRange > 0 and lowerWick / candleRange > wickRatio and close > open
isBullVolSpike = volume > volSma * volMultiplier and close > open and low == lowest10

volRatio = volume / volSma
commonBoost(float wick) =>
    (volRatio > 2.0 ? 0.8 : volRatio > 1.5 ? 0.5 : 0.0) + (candleRange > 0 ? wick / candleRange * 0.6 : 0.0) + (candleRange > avgRangeATR * 1.5 ? 0.4 : 0.0)

bearPivotStrength = not na(pivotHigh) ? 1.0 + commonBoost(upperWick) : 0.0
bearWickStrength  = isBearWickTrap   ? 1.2 + commonBoost(upperWick) : 0.0
bearVolStrength   = isBearVolSpike   ? 1.5 + commonBoost(upperWick) : 0.0
bullPivotStrength = not na(pivotLow)  ? 1.0 + commonBoost(lowerWick) : 0.0
bullWickStrength  = isBullWickTrap   ? 1.2 + commonBoost(lowerWick) : 0.0
bullVolStrength   = isBullVolSpike   ? 1.5 + commonBoost(lowerWick) : 0.0

type DetectionPoint
    float  price
    int    barIndex
    string detectionType
    float  strength
    bool   isBullish

type LiquidityCluster
    float centerPrice
    int   pointCount
    int   powerRank
    float avgStrength
    bool  isBullish
    int   firstBar
    int   lastBar
    bool  hasPivot
    bool  hasWick
    bool  hasVolume
    array<float> prices
    array<float> strengths

type ClusterZone
    float centerPrice
    int   powerRank
    int   pointCount
    bool  isBullish
    float avgStrength
    int   originBar
    box   zoneBox
    label zoneLabel
    bool  isActive
    int   touches
    float distancePercent
    float distancePips

var array<DetectionPoint> bullPoints = array.new<DetectionPoint>()
var array<DetectionPoint> bearPoints = array.new<DetectionPoint>()
var array<ClusterZone>    allZones   = array.new<ClusterZone>()

var int totalZonesCreated  = 0
var int totalZonesBreached = 0
var int totalDetections    = 0
var int lastClusterBar     = 0

getPipValue() =>
    float pv = syminfo.mintick * 10
    if str.contains(syminfo.ticker, "JPY")
        pv := 0.01
    else if str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")
        pv := 0.1
    else
        pv := 0.0001
    pv

tierName(int pr) =>
    pr >= 9 ? "ELITE" : pr >= 7 ? "STRONG" : pr >= 5 ? "MEDIUM" : pr >= 3 ? "WEAK" : "FAINT"

tierColor(int pr, bool isBull) =>
    base = isBull ? bullZoneColor : bearZoneColor
    pr >= 9 ? color.new(base, 0) : pr >= 7 ? color.new(base, 12) : pr >= 5 ? color.new(base, 28) : color.new(base, 48)

starStr(int pr) =>
    int filled = math.round(pr / 2.0)
    string s = ""
    for i = 1 to 5
        s += i <= filled ? "★" : "☆"
    s

calculatePowerRank(int pointCount, float avgStrength, bool hasPivot, bool hasWick, bool hasVolume, int barsAgo) =>
    float confluence = pointCount <= 1 ? 0.5 : pointCount == 2 ? 1.5 : pointCount == 3 ? 2.5 : pointCount == 4 ? 3.2 : pointCount == 5 ? 3.6 : pointCount == 6 ? 3.8 : 4.0
    int typeCount = (hasPivot ? 1 : 0) + (hasWick ? 1 : 0) + (hasVolume ? 1 : 0)
    float diversity = typeCount >= 3 ? 3.0 : typeCount == 2 ? 1.5 : 0.0
    float strength = avgStrength > 2.2 ? 1.8 : avgStrength > 1.9 ? 1.3 : avgStrength > 1.6 ? 0.8 : avgStrength > 1.3 ? 0.3 : 0.0
    float recency = barsAgo < 15 ? 0.8 : barsAgo < 50 ? 0.5 : barsAgo < 150 ? 0.2 : 0.0
    int pr = math.round(math.min(10, confluence + diversity + strength + recency))
    pr

clusterDetectionPoints(array<DetectionPoint> points, bool isBull) =>
    array<LiquidityCluster> clusters = array.new<LiquidityCluster>()
    int size = array.size(points)
    if size > 0
        if size > 1
            for i = 0 to size - 1
                int innerLimit = size - 2 - i
                if innerLimit >= 0
                    for j = 0 to innerLimit
                        p1 = array.get(points, j)
                        p2 = array.get(points, j + 1)
                        if p1.price > p2.price
                            array.set(points, j, p2)
                            array.set(points, j + 1, p1)
        for i = 0 to size - 1
            point = array.get(points, i)
            bool added = false
            int clusterSize = array.size(clusters)
            for j = 0 to (clusterSize > 0 ? clusterSize - 1 : 0)
                if clusterSize > 0
                    cluster = array.get(clusters, j)
                    if math.abs(point.price - cluster.centerPrice) <= clusterToleranceDistance
                        array.push(cluster.prices, point.price)
                        array.push(cluster.strengths, point.strength)
                        cluster.pointCount += 1
                        if str.contains(point.detectionType, "pivot")
                            cluster.hasPivot := true
                        if str.contains(point.detectionType, "wick")
                            cluster.hasWick := true
                        if str.contains(point.detectionType, "volume")
                            cluster.hasVolume := true
                        float sumW = 0.0
                        float sumS = 0.0
                        for k = 0 to array.size(cluster.prices) - 1
                            p = array.get(cluster.prices, k)
                            s = array.get(cluster.strengths, k)
                            sumW += p * s
                            sumS += s
                        cluster.centerPrice := sumW / sumS
                        cluster.avgStrength := sumS / cluster.pointCount
                        cluster.firstBar := math.min(cluster.firstBar, point.barIndex)
                        cluster.lastBar  := math.max(cluster.lastBar, point.barIndex)
                        array.set(clusters, j, cluster)
                        added := true
                        break
            if not added
                newCluster = LiquidityCluster.new(
                     centerPrice = point.price, pointCount = 1, powerRank = 0,
                     avgStrength = point.strength, isBullish = isBull,
                     firstBar = point.barIndex, lastBar = point.barIndex,
                     hasPivot = str.contains(point.detectionType, "pivot"),
                     hasWick  = str.contains(point.detectionType, "wick"),
                     hasVolume= str.contains(point.detectionType, "volume"),
                     prices = array.new<float>(), strengths = array.new<float>())
                array.push(newCluster.prices, point.price)
                array.push(newCluster.strengths, point.strength)
                array.push(clusters, newCluster)
        int clusterSize2 = array.size(clusters)
        for i = 0 to (clusterSize2 > 0 ? clusterSize2 - 1 : 0)
            if clusterSize2 > 0
                cluster = array.get(clusters, i)
                barsAgo = bar_index - cluster.lastBar
                cluster.powerRank := calculatePowerRank(cluster.pointCount, cluster.avgStrength, cluster.hasPivot, cluster.hasWick, cluster.hasVolume, barsAgo)
                array.set(clusters, i, cluster)
    clusters

isTooClose(float price, bool isBull) =>
    bool tooClose = false
    int size = array.size(allZones)
    if size > 0
        for i = 0 to size - 1
            zone = array.get(allZones, i)
            if zone.isActive and zone.isBullish == isBull
                if math.abs(price - zone.centerPrice) < minZoneGap
                    tooClose := true
                    break
    tooClose

getZoneStyle(int powerRank, bool isBull) =>
    base = isBull ? bullZoneColor : bearZoneColor
    color bgColor = na
    color borderColor = na
    color txtColor = na
    int borderWidth = 1
    if powerRank >= 9
        bgColor := color.new(base, math.max(40, zoneOpacity - 30))
        borderColor := color.new(base, 0)
        txtColor := color.new(base, 0)
        borderWidth := showEliteTag ? eliteBorderWidth : 2
    else if powerRank >= 7
        bgColor := color.new(base, math.max(55, zoneOpacity - 18))
        borderColor := color.new(base, 15)
        txtColor := color.new(base, 0)
        borderWidth := 2
    else if powerRank >= 5
        bgColor := color.new(base, math.max(70, zoneOpacity - 8))
        borderColor := color.new(base, 35)
        txtColor := color.new(base, 10)
        borderWidth := 1
    else if powerRank >= 3
        bgColor := color.new(base, zoneOpacity)
        borderColor := color.new(base, 55)
        txtColor := color.new(base, 30)
        borderWidth := 1
    else
        bgColor := color.new(base, math.min(96, zoneOpacity + 8))
        borderColor := color.new(base, 68)
        txtColor := color.new(base, 45)
        borderWidth := 1
    [bgColor, borderColor, txtColor, borderWidth]

buildLabelText(bool isBull, int pr, int pts, float distPct, float distPips) =>
    side = isBull ? "Bull" : "Bear"
    tname = tierName(pr)
    string head = pr >= 9 and showEliteTag ? "  ⬥ ELITE " + side + " Liquidity  " + starStr(pr) : "  " + side + " Liquidity ▸ " + tname + "  " + str.tostring(pr) + "/10"
    string conf = pts > 1 ? "  ×" + str.tostring(pts) : ""
    string dist = ""
    if showDistancePct and showDistancePips
        dist := "   " + str.tostring(distPct, "#.##") + "% | " + str.tostring(distPips, "#") + "p"
    else if showDistancePct
        dist := "   " + str.tostring(distPct, "#.##") + "%"
    else if showDistancePips
        dist := "   " + str.tostring(distPips, "#") + "p"
    head + conf + dist

createZoneFromCluster(LiquidityCluster cluster) =>
    bool created = false

    int activeNow = 0
    int azc = array.size(allZones)
    if azc > 0
        for i = 0 to azc - 1
            if array.get(allZones, i).isActive
                activeNow += 1
    float minDistance = zoneAtr * minDistanceFromPrice
    bool farEnough = math.abs(close - cluster.centerPrice) >= minDistance
    if cluster.powerRank >= minPowerRank and not isTooClose(cluster.centerPrice, cluster.isBullish) and farEnough and activeNow < maxZones
        zoneTop = cluster.centerPrice + zoneWidth
        zoneBottom = cluster.centerPrice - zoneWidth
        int originBar = cluster.firstBar
        [bgColor, borderColor, txtColor, borderWidth] = getZoneStyle(cluster.powerRank, cluster.isBullish)
        newBox = box.new(left = originBar, right = bar_index + 12, top = zoneTop, bottom = zoneBottom, bgcolor = bgColor, border_color = borderColor, border_width = borderWidth, extend = extend.right)
        newLabel = label(na)
        if showZoneLabels
            lblTxt = buildLabelText(cluster.isBullish, cluster.powerRank, cluster.pointCount, 0.0, 0.0)
            newLabel := label.new(x = originBar, y = cluster.centerPrice, text = lblTxt, color = color.new(color.white, 100), textcolor = txtColor, style = label.style_label_left, size = zlSize)
        newZone = ClusterZone.new(centerPrice = cluster.centerPrice, powerRank = cluster.powerRank, pointCount = cluster.pointCount, isBullish = cluster.isBullish, avgStrength = cluster.avgStrength, originBar = originBar, zoneBox = newBox, zoneLabel = newLabel, isActive = true, touches = 0, distancePercent = 0.0, distancePips = 0.0)
        array.push(allZones, newZone)
        created := true

        if array.size(allZones) > maxZones * 4
            int rs = array.size(allZones)
            for i = 0 to rs - 1
                z = array.get(allZones, i)
                if not z.isActive
                    box.delete(z.zoneBox)
                    if not na(z.zoneLabel)
                        label.delete(z.zoneLabel)
                    array.remove(allZones, i)
                    break
    created

updateAllZones() =>
    int newBreaches = 0
    int size = array.size(allZones)
    float pipValue = getPipValue()
    if size > 0
        for i = 0 to size - 1
            zone = array.get(allZones, i)
            float distFromPrice = math.abs(close - zone.centerPrice)
            if zone.isActive
                zoneTop = zone.centerPrice + zoneWidth
                zoneBottom = zone.centerPrice - zoneWidth
                zone.distancePercent := (distFromPrice / close) * 100
                zone.distancePips := distFromPrice / pipValue
                if close >= zoneBottom and close <= zoneTop
                    zone.touches += 1
                breached = false
                if zone.isBullish and close < zoneBottom
                    breached := true
                    newBreaches += 1
                else if not zone.isBullish and close > zoneTop
                    breached := true
                    newBreaches += 1
                if breached
                    zone.isActive := false
                    box.set_bgcolor(zone.zoneBox, color.new(breachedColor, 88))
                    box.set_border_color(zone.zoneBox, color.new(breachedColor, 70))
                    box.set_border_width(zone.zoneBox, 1)
                    if not na(zone.zoneLabel)
                        label.set_textcolor(zone.zoneLabel, color.new(breachedColor, 10))
                if not na(zone.zoneLabel) and zone.isActive
                    label.set_text(zone.zoneLabel, buildLabelText(zone.isBullish, zone.powerRank, zone.pointCount, zone.distancePercent, zone.distancePips))

            if zone.isActive and not showCurrentZones
                box.set_bgcolor(zone.zoneBox, color.new(color.white, 100))
                box.set_border_color(zone.zoneBox, color.new(color.white, 100))
                if not na(zone.zoneLabel)
                    label.set_textcolor(zone.zoneLabel, color.new(color.white, 100))
            else if zone.isActive and showCurrentZones
                [bgColor, borderColor, txtColor, borderWidth] = getZoneStyle(zone.powerRank, zone.isBullish)
                box.set_bgcolor(zone.zoneBox, bgColor)
                box.set_border_color(zone.zoneBox, borderColor)
                box.set_border_width(zone.zoneBox, borderWidth)
                if not na(zone.zoneLabel)
                    label.set_textcolor(zone.zoneLabel, txtColor)
            if not zone.isActive and not showHistoricZones
                box.set_bgcolor(zone.zoneBox, color.new(color.white, 100))
                box.set_border_color(zone.zoneBox, color.new(color.white, 100))
                if not na(zone.zoneLabel)
                    label.set_textcolor(zone.zoneLabel, color.new(color.white, 100))
            else if not zone.isActive and showHistoricZones
                box.set_bgcolor(zone.zoneBox, color.new(breachedColor, 88))
                box.set_border_color(zone.zoneBox, color.new(breachedColor, 70))
                if not na(zone.zoneLabel)
                    label.set_textcolor(zone.zoneLabel, color.new(breachedColor, 10))
            array.set(allZones, i, zone)
    newBreaches

addTargets(array<LiquidityCluster> clusters, bool isBull, array<float> tPrice, array<bool> tBull, array<int> tRank, array<int> tPts, array<int> tOrigin) =>
    int created = 0
    int n = array.size(clusters)
    if n > 0
        for i = 0 to n - 1
            if created >= maxZones / 2
                break
            c = array.get(clusters, i)
            float minDist = zoneAtr * minDistanceFromPrice
            bool farEnough = math.abs(close - c.centerPrice) >= minDist
            if c.pointCount >= minClusterSize and c.powerRank >= minPowerRank and farEnough
                bool dup = false
                int ts = array.size(tPrice)
                if ts > 0
                    for k = 0 to ts - 1
                        if array.get(tBull, k) == isBull and math.abs(array.get(tPrice, k) - c.centerPrice) < minZoneGap
                            dup := true
                            break
                if not dup
                    array.push(tPrice, c.centerPrice)
                    array.push(tBull, isBull)
                    array.push(tRank, c.powerRank)
                    array.push(tPts, c.pointCount)
                    array.push(tOrigin, c.firstBar)
                    created += 1

clusterSupportsLevel(float price, array<LiquidityCluster> clusters) =>
    bool ok = false
    int n = array.size(clusters)
    if n > 0
        for i = 0 to n - 1
            c = array.get(clusters, i)
            if c.powerRank >= minPowerRank and math.abs(c.centerPrice - price) < minZoneGap
                ok := true
                break
    ok

if barstate.isconfirmed
    if enableClustering
        if not na(pivotHigh) and bearPivotStrength >= strengthThreshold
            array.push(bearPoints, DetectionPoint.new(pivotHigh, bar_index - pivotRightBars, "pivot_high", bearPivotStrength, false))
            totalDetections += 1
        if isBearWickTrap and bearWickStrength >= strengthThreshold
            array.push(bearPoints, DetectionPoint.new(high, bar_index, "wick_trap", bearWickStrength, false))
            totalDetections += 1
        if isBearVolSpike and bearVolStrength >= strengthThreshold
            array.push(bearPoints, DetectionPoint.new(high, bar_index, "volume_spike", bearVolStrength, false))
            totalDetections += 1
        if not na(pivotLow) and bullPivotStrength >= strengthThreshold
            array.push(bullPoints, DetectionPoint.new(pivotLow, bar_index - pivotRightBars, "pivot_low", bullPivotStrength, true))
            totalDetections += 1
        if isBullWickTrap and bullWickStrength >= strengthThreshold
            array.push(bullPoints, DetectionPoint.new(low, bar_index, "wick_trap", bullWickStrength, true))
            totalDetections += 1
        if isBullVolSpike and bullVolStrength >= strengthThreshold
            array.push(bullPoints, DetectionPoint.new(low, bar_index, "volume_spike", bullVolStrength, true))
            totalDetections += 1
        int bullSize = array.size(bullPoints)
        if bullSize > 0
            for i = bullSize - 1 to 0
                if bar_index - array.get(bullPoints, i).barIndex > lookbackBars
                    array.remove(bullPoints, i)
        int bearSize = array.size(bearPoints)
        if bearSize > 0
            for i = bearSize - 1 to 0
                if bar_index - array.get(bearPoints, i).barIndex > lookbackBars
                    array.remove(bearPoints, i)
        if (bar_index - lastClusterBar) >= reclusterInterval or lastClusterBar == 0
            lastClusterBar := bar_index
            bullClusters = clusterDetectionPoints(bullPoints, true)
            int bcs = array.size(bullClusters)
            if bcs > 1
                for i = 0 to bcs - 1
                    int innerLimit = bcs - 2 - i
                    if innerLimit >= 0
                        for j = 0 to innerLimit
                            c1 = array.get(bullClusters, j)
                            c2 = array.get(bullClusters, j + 1)
                            if c1.powerRank < c2.powerRank
                                array.set(bullClusters, j, c2)
                                array.set(bullClusters, j + 1, c1)
            bearClusters = clusterDetectionPoints(bearPoints, false)
            int becs = array.size(bearClusters)
            if becs > 1
                for i = 0 to becs - 1
                    int innerLimit = becs - 2 - i
                    if innerLimit >= 0
                        for j = 0 to innerLimit
                            c1 = array.get(bearClusters, j)
                            c2 = array.get(bearClusters, j + 1)
                            if c1.powerRank < c2.powerRank
                                array.set(bearClusters, j, c2)
                                array.set(bearClusters, j + 1, c1)

            tPrice  = array.new<float>()
            tBull   = array.new<bool>()
            tRank   = array.new<int>()
            tPts    = array.new<int>()
            tOrigin = array.new<int>()
            addTargets(bullClusters, true,  tPrice, tBull, tRank, tPts, tOrigin)
            addTargets(bearClusters, false, tPrice, tBull, tRank, tPts, tOrigin)
            int tCount = array.size(tPrice)
            tCovered = array.new<bool>()
            if tCount > 0
                for k = 0 to tCount - 1
                    array.push(tCovered, false)

            int zs = array.size(allZones)
            if zs > 0
                for i = zs - 1 to 0
                    z = array.get(allZones, i)
                    if z.isActive
                        int mi = -1
                        if tCount > 0
                            for k = 0 to tCount - 1
                                if array.get(tBull, k) == z.isBullish and math.abs(array.get(tPrice, k) - z.centerPrice) < minZoneGap
                                    mi := k
                                    break
                        bool supported = clusterSupportsLevel(z.centerPrice, z.isBullish ? bullClusters : bearClusters)
                        if mi >= 0
                            array.set(tCovered, mi, true)
                        else if not supported
                            box.delete(z.zoneBox)
                            if not na(z.zoneLabel)
                                label.delete(z.zoneLabel)
                            array.remove(allZones, i)

            if tCount > 0
                for k = 0 to tCount - 1
                    if not array.get(tCovered, k)
                        synth = LiquidityCluster.new(centerPrice = array.get(tPrice, k), pointCount = array.get(tPts, k), powerRank = array.get(tRank, k), avgStrength = 0.0, isBullish = array.get(tBull, k), firstBar = array.get(tOrigin, k), lastBar = array.get(tOrigin, k), hasPivot = false, hasWick = false, hasVolume = false, prices = array.new<float>(), strengths = array.new<float>())
                        if createZoneFromCluster(synth)
                            totalZonesCreated += 1
    else

        if not na(pivotHigh) and bearPivotStrength >= strengthThreshold
            if createZoneFromCluster(LiquidityCluster.new(pivotHigh, 1, calculatePowerRank(1, bearPivotStrength, true, false, false, 0), bearPivotStrength, false, bar_index - pivotRightBars, bar_index - pivotRightBars, true, false, false, array.new<float>(), array.new<float>()))
                totalZonesCreated += 1
        if isBullWickTrap and bullWickStrength >= strengthThreshold
            if createZoneFromCluster(LiquidityCluster.new(low, 1, calculatePowerRank(1, bullWickStrength, false, true, false, 0), bullWickStrength, true, bar_index, bar_index, false, true, false, array.new<float>(), array.new<float>()))
                totalZonesCreated += 1
        if not na(pivotLow) and bullPivotStrength >= strengthThreshold
            if createZoneFromCluster(LiquidityCluster.new(pivotLow, 1, calculatePowerRank(1, bullPivotStrength, true, false, false, 0), bullPivotStrength, true, bar_index - pivotRightBars, bar_index - pivotRightBars, true, false, false, array.new<float>(), array.new<float>()))
                totalZonesCreated += 1
        if isBearWickTrap and bearWickStrength >= strengthThreshold
            if createZoneFromCluster(LiquidityCluster.new(high, 1, calculatePowerRank(1, bearWickStrength, false, true, false, 0), bearWickStrength, false, bar_index, bar_index, false, true, false, array.new<float>(), array.new<float>()))
                totalZonesCreated += 1

breachesThisBar = updateAllZones()
totalZonesBreached += breachesThisBar

plotshape(not na(pivotHigh) and showPivotMarkers, title="Resistance Pivot", location=location.abovebar, style=shape.triangledown, color=color.new(bearZoneColor, 20), size=size.tiny)
plotshape(not na(pivotLow) and showPivotMarkers, title="Support Pivot", location=location.belowbar, style=shape.triangleup, color=color.new(bullZoneColor, 20), size=size.tiny)

dashPos = dashPosInput == "Top Left" ? position.top_left : dashPosInput == "Bottom Right" ? position.bottom_right : dashPosInput == "Bottom Left" ? position.bottom_left : dashPosInput == "Middle Right" ? position.middle_right : position.top_right

var table dash = table.new(dashPos, 5, maxDashRows + 4, bgcolor = color.new(panelBg, 6), frame_color = color.new(bullZoneColor, 45), frame_width = 2, border_color = color.new(#2A2F3A, 40), border_width = 1)

if showDashboard and barstate.islast
    array<ClusterZone> viable = array.new<ClusterZone>()
    int total = array.size(allZones)
    int eliteCount = 0
    int strongCount = 0
    int bullCount = 0
    int bearCount = 0
    if total > 0
        for i = 0 to total - 1
            z = array.get(allZones, i)
            if z.isActive
                array.push(viable, z)
                if z.powerRank >= 9
                    eliteCount += 1
                else if z.powerRank >= 7
                    strongCount += 1
                if z.isBullish
                    bullCount += 1
                else
                    bearCount += 1
    int vs = array.size(viable)
    if vs > 1
        for i = 0 to vs - 1
            int innerLimit = vs - 2 - i
            if innerLimit >= 0
                for j = 0 to innerLimit
                    a = array.get(viable, j)
                    b = array.get(viable, j + 1)
                    bool swap = a.powerRank < b.powerRank or (a.powerRank == b.powerRank and a.distancePercent > b.distancePercent)
                    if swap
                        array.set(viable, j, b)
                        array.set(viable, j + 1, a)

    headerBg = color.new(panelBg, 0)
    subBg = color.new(#161B26, 10)
    table.cell(dash, 0, 0, "⬥ STRONG LIQUIDITY ZONES", text_color = #E8EAED, text_size = dTxt, text_halign = text.align_left, bgcolor = headerBg)
    table.merge_cells(dash, 0, 0, 4, 0)
    summary = "ELITE " + str.tostring(eliteCount) + "   STRONG " + str.tostring(strongCount) + "   ▲" + str.tostring(bearCount) + " bear  ▼" + str.tostring(bullCount) + " bull"
    table.cell(dash, 0, 1, summary, text_color = panelText, text_size = dTxt, text_halign = text.align_left, bgcolor = subBg)
    table.merge_cells(dash, 0, 1, 4, 1)
    table.cell(dash, 0, 2, "TIER",  text_color = #8B92A0, text_size = dTxt, text_halign = text.align_left,  bgcolor = subBg)
    table.cell(dash, 1, 2, "SIDE",  text_color = #8B92A0, text_size = dTxt, text_halign = text.align_center,bgcolor = subBg)
    table.cell(dash, 2, 2, "PRICE", text_color = #8B92A0, text_size = dTxt, text_halign = text.align_right, bgcolor = subBg)
    table.cell(dash, 3, 2, "PWR",   text_color = #8B92A0, text_size = dTxt, text_halign = text.align_center,bgcolor = subBg)
    table.cell(dash, 4, 2, "DIST",  text_color = #8B92A0, text_size = dTxt, text_halign = text.align_right, bgcolor = subBg)

    int rowsToShow = math.min(maxDashRows, array.size(viable))
    for r = 0 to maxDashRows - 1
        int rowIdx = r + 3
        if r < rowsToShow
            z = array.get(viable, r)
            tcol = tierColor(z.powerRank, z.isBullish)
            sideColBase = z.isBullish ? bullZoneColor : bearZoneColor
            rowBg = z.powerRank >= 9 ? color.new(sideColBase, 84) : (r % 2 == 0 ? color.new(#11161F, 8) : color.new(#0E1117, 8))
            sideTxt = z.isBullish ? "BULL" : "BEAR"
            arrow = z.centerPrice > close ? "▲" : "▼"
            distTxt = arrow + " " + str.tostring(z.distancePercent, "#.##") + "%"
            table.cell(dash, 0, rowIdx, tierName(z.powerRank), text_color = tcol, text_size = dTxt, text_halign = text.align_left, bgcolor = rowBg)
            table.cell(dash, 1, rowIdx, sideTxt, text_color = color.new(sideColBase, 0), text_size = dTxt, text_halign = text.align_center, bgcolor = rowBg)
            table.cell(dash, 2, rowIdx, str.tostring(z.centerPrice, format.mintick), text_color = panelText, text_size = dTxt, text_halign = text.align_right, bgcolor = rowBg)
            table.cell(dash, 3, rowIdx, str.tostring(z.powerRank) + "/10", text_color = tcol, text_size = dTxt, text_halign = text.align_center, bgcolor = rowBg)
            table.cell(dash, 4, rowIdx, distTxt, text_color = panelText, text_size = dTxt, text_halign = text.align_right, bgcolor = rowBg)
        else
            emptyBg = color.new(panelBg, 12)
            table.cell(dash, 0, rowIdx, "", bgcolor = emptyBg)
            table.cell(dash, 1, rowIdx, "", bgcolor = emptyBg)
            table.cell(dash, 2, rowIdx, "", bgcolor = emptyBg)
            table.cell(dash, 3, rowIdx, "", bgcolor = emptyBg)
            table.cell(dash, 4, rowIdx, "", bgcolor = emptyBg)
    footer = array.size(viable) == 0 ? "No viable levels yet" : "ATR" + str.tostring(zoneAtrPeriod) + " " + str.tostring(zoneAtr, "#.##") + "  ·  listing " + str.tostring(rowsToShow) + "/" + str.tostring(array.size(viable))
    table.cell(dash, 0, maxDashRows + 3, footer, text_color = #6B7280, text_size = dTxt, text_halign = text.align_left, bgcolor = color.new(panelBg, 0))
    table.merge_cells(dash, 0, maxDashRows + 3, 4, maxDashRows + 3)

alertEliteNow = false
alertStrongNow = false
if (bar_index - lastClusterBar) == 0
    int n = array.size(allZones)
    if n > 0
        for i = 0 to n - 1
            z = array.get(allZones, i)
            if z.isActive
                if z.powerRank >= 9
                    alertEliteNow := true
                else if z.powerRank >= 7
                    alertStrongNow := true

alertcondition(alertEliteNow,  title="Elite Liquidity Cluster",  message="PS Strong Liq: ELITE (9-10) cluster active on {{ticker}} at {{close}}")
alertcondition(alertStrongNow, title="Strong Liquidity Cluster", message="PS Strong Liq: STRONG (7-8) cluster active on {{ticker}} at {{close}}")
alertcondition(breachesThisBar > 0, title="Liquidity Zone Breached", message="PS Strong Liq: a liquidity zone was breached on {{ticker}} at {{close}}")
alertcondition(isBearWickTrap or isBearVolSpike or not na(pivotHigh), title="Bearish Liquidity Detected", message="PS Strong Liq: bearish liquidity detection on {{ticker}}")
alertcondition(isBullWickTrap or isBullVolSpike or not na(pivotLow), title="Bullish Liquidity Detected", message="PS Strong Liq: bullish liquidity detection on {{ticker}}")
````
