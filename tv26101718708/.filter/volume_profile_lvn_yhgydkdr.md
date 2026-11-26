# Volume Profile + LVN

- url: https://www.tradingview.com/script/yhGyDKDr-Volume-Profile-LVN/
- type: indicator
- pine_id: PUB;248c6356a0594883afcc51c5fa4df556
- version: 1.0

## Description

[b]Volume Profile + Low Volume Nodes

A clean institutional-grade volume profile built for intraday traders. This indicator maps exactly where volume was traded across price levels during the session and automatically identifies the thin areas — the Low Volume Nodes — where price moves fast and institutions are likely to react.

What it does:

Volume Profile — displays a horizontal bar chart to the right of price showing how much volume traded at each price level. Green bars where buyers dominated, red bars where sellers dominated, yellow bar at the Point of Control — the single price level with the most volume traded.

Low Volume Nodes (LVN) — automatically detects the price zones where volume is significantly thinner than surrounding levels. These are the gaps in the market where price moved too fast for participants to trade much — creating imbalances that price tends to revisit and react to.

🟢 Green zones — LVN below current price = support. Price tends to bounce here or accelerate through on high volume.

🔴 Red zones — LVN above current price = resistance. Price tends to reject here or break through with momentum.

🟡 POC line — Point of Control extends left across the chart. The most important intraday reference level — price gravitates toward this level throughout the day.

How to use it:

When price approaches a green or red zone you have two scenarios — a bounce or a clean break.

Bounce — price touches the zone and closes back outside it. Look for a buy at green zones and a sell at red zones.

Break — price closes through the zone with volume. Trade the continuation in the direction of the break — buy above a broken red zone, sell below a broken green zone.

The thinner the zone the faster price will move through it. The POC acts as a magnet — if price is far from it expect it to get pulled back during the session.

Settings:

Profile Mode — Session resets each day for intraday use. Lookback uses a fixed bar count

Node Detection % — Controls how sensitive the LVN detection is. Higher finds more zones

Max LVN Nodes — Maximum number of zones shown — always displays the closest ones to current price

Zone Expand — Makes each zone slightly thicker to capture neighboring thin levels

Profile Offset — Controls the space between price and the profile


session mode - best for 1-5 minute timeframe
lookback mode - best for higher timeframe[/b]

## Source Code

````pine
//@version=6
indicator("Volume Profile + LVN", shorttitle="VP LVN",
     overlay=true, max_boxes_count=500, max_lines_count=50,
     max_labels_count=50, max_bars_back=5000)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
profileMode = input.string("Session", "Profile Mode",
     options=["Session", "Lookback"], group="Settings",
     tooltip="Session = resets each trading day. Lookback = fixed bar count")
lookback    = input.int(400,   "Lookback Bars",        group="Settings", minval=50, maxval=2000)
numRows     = input.int(100,   "Profile Rows",         group="Settings", minval=30, maxval=200)
profWidth   = input.int(50,    "Profile Width (bars)", group="Settings", minval=10, maxval=200)
profOffset  = input.int(50,    "Profile Offset",       group="Settings", minval=0,  maxval=200)
troughPct   = input.int(7,     "Node Detection %",     group="Settings", minval=1,  maxval=50)
volThresh   = input.float(1.0, "Volume Threshold %",   group="Settings", minval=0,  maxval=100)
maxNodes    = input.int(6,     "Max LVN Nodes",        group="Settings", minval=1,  maxval=20)
zoneExpand  = input.int(1,     "Zone Expand (rows)",   group="Settings", minval=0,  maxval=5)
lvnExtend   = input.int(500,   "LVN Extend Left",      group="Settings", minval=10, maxval=2000)

// Softer muted colors
bullCol     = input.color(color.new(#089981, 30), "Bull Bars",   group="Colors")
bearCol     = input.color(color.new(#f23645, 30), "Bear Bars",   group="Colors")
pocCol      = input.color(#FFEB3B,                "POC",         group="Colors")
supCol      = input.color(color.new(#089981, 88), "Support LVN", group="Colors")
resCol      = input.color(color.new(#f23645, 88), "Resist LVN",  group="Colors")

showPOC     = input.bool(true,  "Show POC Line",   group="Display")
showLabels  = input.bool(true,  "Show LVN Labels", group="Display")

// ─── SESSION DETECTION ────────────────────────────────────────────────────────
isNewSession = ta.change(time("D")) != 0
var int sessionStart = 0
if isNewSession or barstate.isfirst
    sessionStart := bar_index

int barsBack = profileMode == "Session" ?
     math.max(bar_index - sessionStart, 2) : lookback

// ─── RANGE ────────────────────────────────────────────────────────────────────
float profHigh  = ta.highest(high, math.max(barsBack, 2))
float profLow   = ta.lowest(low,   math.max(barsBack, 2))
float priceStep = profHigh > profLow ? (profHigh - profLow) / numRows : 0.01

// ─── BUILD PROFILE ────────────────────────────────────────────────────────────
buildProfile(int bars) =>
    array<float> volArr = array.new<float>(numRows, 0.0)
    array<float> buyArr = array.new<float>(numRows, 0.0)
    int b = math.max(bars, 1)
    if priceStep > 0
        for i = 0 to b - 1
            float h    = nz(high[i])
            float l    = nz(low[i])
            float v    = nz(volume[i])
            bool  bull = close[i] >= open[i]
            if v > 0 and h > l
                int kS = math.max(math.floor((l - profLow) / priceStep), 0)
                int kE = math.min(math.floor((h - profLow) / priceStep), numRows - 1)
                float rng = h - l
                for k = kS to kE
                    float bL = profLow + k * priceStep
                    float oL = math.max(l, bL)
                    float oH = math.min(h, bL + priceStep)
                    if oH > oL
                        float aV = v * (oH - oL) / rng
                        volArr.set(k, volArr.get(k) + aV)
                        if bull
                            buyArr.set(k, buyArr.get(k) + aV)
    [volArr, buyArr]

// ─── VALLEY NODE DETECTION ────────────────────────────────────────────────────
findValleys(array<float> vol, float maxV) =>
    int n = math.max(int(numRows * troughPct / 100), 1)
    float threshold = maxV * (volThresh / 100)

    array<float> padded = array.new<float>(0)
    for i = 1 to n
        padded.push(maxV)
    for i = 0 to numRows - 1
        padded.push(vol.get(i))
    for i = 1 to n
        padded.push(maxV)

    array<bool> isValley = array.new<bool>(numRows, false)
    for k = 0 to numRows - 1
        int   pIdx   = k + n
        float binVol = padded.get(pIdx)

        if binVol <= threshold
            continue

        bool lowerThanAbove = true
        bool lowerThanBelow = true

        for j = pIdx + 1 to pIdx + n
            if binVol >= padded.get(j)
                lowerThanAbove := false
                break

        for j = pIdx - n to pIdx - 1
            if binVol >= padded.get(j)
                lowerThanBelow := false
                break

        if lowerThanAbove and lowerThanBelow
            isValley.set(k, true)

    isValley

// ─── STATE ────────────────────────────────────────────────────────────────────
var array<box>   profBoxes = array.new<box>()
var array<box>   lvnBoxes  = array.new<box>()
var array<label> lvnLabels = array.new<label>()
var line         pocLine   = na
var label        pocLbl    = na

// ─── DRAW ─────────────────────────────────────────────────────────────────────
if barstate.islast
    for b in profBoxes
        b.delete()
    profBoxes.clear()
    for b in lvnBoxes
        b.delete()
    lvnBoxes.clear()
    for l in lvnLabels
        l.delete()
    lvnLabels.clear()
    line.delete(pocLine)
    label.delete(pocLbl)

    [volArr, buyArr] = buildProfile(barsBack)

    if volArr.size() > 0
        float maxV = volArr.max()
        if maxV > 0
            int xRight = bar_index + profOffset
            int xLeft  = bar_index - lvnExtend
            float expand = priceStep * zoneExpand

            // POC
            int pocIdx = 0
            for k = 0 to numRows - 1
                if volArr.get(k) == maxV
                    pocIdx := k
                    break
            float pocPrice = profLow + pocIdx * priceStep + priceStep / 2

            // ── PROFILE BARS — no gaps between bins ───────────────────────────
            // Each bin box shares exact edges with neighbors = no lego gaps
            for k = 0 to numRows - 1
                float binL   = profLow + k * priceStep
                float binH   = binL + priceStep
                float v      = volArr.get(k)
                float bv     = buyArr.get(k)
                float ratio  = v / maxV
                int   w      = math.max(int(ratio * profWidth), 1)
                bool  isPOC  = k == pocIdx
                bool  buyDom = bv >= v * 0.5

                // Soft gradient — more transparent at low volume
                color barFill = color.from_gradient(ratio, 0, 1,
                     color.new(buyDom ? bullCol : bearCol, 95),
                     color.new(buyDom ? bullCol : bearCol, 20))

                if isPOC
                    barFill := color.new(pocCol, 15)

                // No border on normal bars = seamless look
                // POC gets a subtle border only
                color borderC = isPOC ? color.new(pocCol, 10) : color.new(color.black, 100)
                int   borderW = isPOC ? 1 : 0

                // Bins share exact top/bottom edges — no gap buffer
                profBoxes.push(box.new(
                     xRight - w, binH,
                     xRight,     binL,
                     borderC, borderW,
                     bgcolor=barFill))

            // ── VALLEY DETECTION ──────────────────────────────────────────────
            isValley = findValleys(volArr, maxV)

            array<float> allBots = array.new<float>()
            array<float> allTops = array.new<float>()
            array<float> allDist = array.new<float>()

            bool  inZone  = false
            float zoneBot = na
            float zoneTop = na

            for k = 0 to numRows - 1
                float binL = profLow + k * priceStep
                float binH = binL + priceStep
                bool  isV  = isValley.get(k)

                if isV and not inZone
                    zoneBot := binL
                    zoneTop := binH
                    inZone  := true
                else if isV and inZone
                    zoneTop := binH
                else if not isV and inZone
                    float mid = (zoneBot + zoneTop) / 2
                    allBots.push(zoneBot)
                    allTops.push(zoneTop)
                    allDist.push(math.abs(mid - close))
                    inZone := false

            if inZone and not na(zoneBot) and not na(zoneTop)
                float mid = (zoneBot + zoneTop) / 2
                allBots.push(zoneBot)
                allTops.push(zoneTop)
                allDist.push(math.abs(mid - close))

            // Profile top and bottom edges
            float topZoneH = profHigh
            float topZoneL = profHigh - priceStep * 3
            allBots.push(topZoneL)
            allTops.push(topZoneH)
            allDist.push(math.abs((topZoneH + topZoneL) / 2 - close))

            float botZoneH = profLow + priceStep * 3
            float botZoneL = profLow
            allBots.push(botZoneL)
            allTops.push(botZoneH)
            allDist.push(math.abs((botZoneH + botZoneL) / 2 - close))

            // ── DRAW CLOSEST N ZONES ──────────────────────────────────────────
            int total = allBots.size()
            if total > 0
                int drawN = math.min(maxNodes, total)
                array<bool> used = array.new<bool>(total, false)

                for n = 0 to drawN - 1
                    float minD = 999999.0
                    int   minI = 0
                    for z = 0 to total - 1
                        if not used.get(z) and allDist.get(z) < minD
                            minD := allDist.get(z)
                            minI := z
                    used.set(minI, true)

                    float gBot  = allBots.get(minI)
                    float gTop  = allTops.get(minI)
                    float gMid  = (gBot + gTop) / 2
                    bool  isSup = gMid < close

                    // Soft border — same hue as fill but less transparent
                    color fill  = isSup ? supCol : resCol
                    color bord  = isSup ?
                         color.new(#089981, 60) : color.new(#f23645, 60)

                    float drawBot = gBot - expand
                    float drawTop = gTop + expand

                    lvnBoxes.push(box.new(
                         xLeft, drawTop, xRight, drawBot,
                         bord, 2, bgcolor=fill))

                    if showLabels
                        lvnLabels.push(label.new(
                             xLeft + 2, gMid,
                             (isSup ? "SUP " : "RES ") +
                             str.tostring(math.round(gMid, 2)),
                             style=label.style_none,
                             textcolor=isSup ?
                                  color.new(#089981, 30) : color.new(#f23645, 30),
                             size=size.small))

            // ── POC LINE ──────────────────────────────────────────────────────
            if showPOC
                pocLine := line.new(xLeft, pocPrice, xRight, pocPrice,
                     color=color.new(pocCol, 30), width=1, style=line.style_dashed)
                pocLbl := label.new(xLeft + 2, pocPrice,
                     "POC " + str.tostring(math.round(pocPrice, 2)),
                     style=label.style_none,
                     textcolor=color.new(pocCol, 30), size=size.tiny)
````
