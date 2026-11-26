# Volume Profile Support & Resistance Matrix [HexaTrades]

- url: https://www.tradingview.com/script/p9qM6rTh-Volume-Profile-Support-Resistance-Matrix-HexaTrades/
- type: indicator
- pine_id: PUB;65e4aa82aa1542b881cf90046ca18dce
- version: 1.0

## Description

Most indicators tell you where the price went. This one shows you where the volume traded and then does the hard part for you: it reads that volume map and draws the support and resistance levels that genuinely matter right now.

VRVP Visible Range Support/Resistance Matrix is an all-in-one volume toolkit. It builds a buy/sell Volume Range Visible Profile over the last N candles (or the visible range), locates the heavy high-volume nodes, converts them into ranked support and resistance zones, and surrounds them with everything you need to act: Point of Control, Value Area, Low-Volume-Node levels, optional Fair Value Gaps, a corner dashboard, and breakout/touch/ approach alerts. Everything is configurable, and every level is explained

[b]✨ features[/b]

[b]✔️ Buy & Sell Volume Profile[/b]

- Volume-by-price histogram built from the chosen window, one row per price bin.
- Buy vs sell split:  each candle’s volume is classified as buying (close ≥ open) or selling (close < open) and stacked per row, so you see the order-flow balance at every level.
- Radiant intensity coloring: heavy rows render bright/opaque, light rows fade out, so the significant nodes jump off the chart.
- Right-of-price placement:  the profile sits in the gap to the right of the last candle (adjustable), so it never covers your price action, and it pans/zooms with the chart.
- Gap-free distribution: volume is spread across each candle’s full range, so the profile is solid rather than a sparse set of dots.

[b]✔️ Automatic Support & Resistance Zones[/b]

- High-volume node detection: the script repeatedly finds the biggest volume peaks and turns them into zones.
- Strength % score:  every zone is graded by its volume relative to the Point of Control (e.g. “Support 82%”), and the fill opacity scales with that strength.
- Retest count: counts how many times price has re-entered the zone (e.g. “x4”), so you can tell fresh levels from heavily-tested ones.
- Smart spacing: a minimum distance (in profile rows) and an anti-overlap floor keep zones cleanly separated, never stacked on top of each other.
- Per-side cap: limit how many support and resistance zones show, so the chart stays readable.
- Auto role flip:  a level above the last confirmed close is Resistance, below it is Support; zones recolor only when a candle actually closes through them.
- Adjustable thickness: zone band height from ATR or bin size, fully tunable.
Anchor options extend zones from the window start or from the last price touch.


[b]✔️ Point of Control & Value Area[/b]

- POC line: the single highest-volume price (the market’s fair-value magnet).
- Value Area (VAH / VAL) : the high/low boundaries that contain your chosen % of total traded volume (default 70%).
- Used both as optional on-chart lines and as the engine behind the dashboard’s trend bias.

[b]✔️ Low Volume Nodes (LVNs)[/b]

- Imbalance detection: finds the thin “valleys” in the profile where little volume traded.
- Dashed level lines mark these air pockets: price tends to move quickly through them and react at the thick nodes around them.

[b]✔️ Fair Value Gaps (FVG)[/b]

- 3-candle imbalance detection:  bullish & bearish gaps where price moved so fast it left an unfilled inefficiency.
-Unfilled-only boxes:  only gaps price hasn’t returned to are shown, as small yellow boxes labeled “FVG”. Capped to keep the chart clean. (Off by default.)

[b]✔️ Stat Dashboard[/b]

- A compact corner panel showing 📊 POC, 🔼 VAH, 🔽 VAL, 🟥 Nearest Resistance, 🟩 Nearest Support, 🧭 Trend Bias (Bullish / Bearish / Balanced) and 📐 zone counts.
- Dark, high-contrast styling that stays readable on light and dark chart themes; placeable in any of the four corners.

[b]✔️ Alerts[/b]
The tool features a comprehensive, built-in alert system that triggers notifications for a variety of critical price movements, such as breakouts above resistance, breakdowns below support, support touches, resistance rejections, and upcoming zone warnings. Traders can also enable an optional volume confirmation filter to help minimize false signals during low-liquidity periods.

[b]✔️ Window & Customization[/b]

- Two modes: a fixed candle window (default 360) for consistency, or the visible range so the profile follows whatever you’re looking at.
- Adjustable resolution: set the number of profile rows for coarse or fine detail.
- Full color control: buy/sell profile, support/resistance fills, POC, value area, LVN and FVG colors are all editable.

Find all mentioned features in the chart below.
https://www.tradingview.com/x/vmua7rBt/


[b]⚙️ How it works[/b]

- Range & rows. It takes the high/low of the last N candles (or the visible range) and slices that range into bins (rows).

- Volume mapping. Each candle spreads its volume across the rows its range covers, then splits it into buy vs sell, giving a solid, gap-free volume-by-price map.

- POC & Value Area. The busiest row is the Point of Control; the script expands outward until it captures your chosen % of total volume → VAH / VAL.

- Zone selection. It picks the biggest volume peaks, keeps them spaced apart so they never overlap, scores each by strength, and counts retests.

- Role & signals. Levels above the last confirmed close are Resistance; below are Support, and breakout/touch / reject / approach events fire from the nearest live zone.


[b]🚀How to use it- step by step[/b]

Add the indicator to any symbol that has volume, on any timeframe. The defaults work out of the box. Two decisions set the context:

- Timeframe: use your trading timeframe. Higher timeframes (1H/4H/1D) give fewer, stronger zones; lower timeframes give more, faster-moving ones.
- Window: keep Use Fixed Candle Count on (default 360) for a stable, repeatable profile, or turn it off to let the profile follow the visible range as you scroll.

[b]⭐️ Read the structure with the dashboard[/b]

-  Trend Bias is your regime filter: Bullish when price is above the Value Area High (favour longs), Bearish below the Value Area Low (favour shorts), Balanced inside the value area (favour fading the edges / mean-reversion).
- 🎯 POC / 🔼 VAH / 🔽 VAL give you the fair-value zone where most business was done.
- 🟥 Nearest Resistance / 🟩 Nearest Support are your immediate targets and invalidation prices
https://www.tradingview.com/x/3qQLcK16/


[b]⭐️ Find the zones that actually matter[/b]

Not all zones are equal — let the labels rank them for you:

- Strength % :  higher = more volume traded there = a stronger level. A “Support 95%” is far more significant than a “Support 48%”. Prioritise the high-% zones.

- Retest count (x N): a low count means a fresh, untested level (often the cleanest reactions); a high count means it’s been hit many times and may be weakening toward a break.

- Profile shape: the long bars are High-Volume Nodes (acceptance/magnets); the thin LVN dashed lines are Low-Volume Nodes (rejection / fast-travel zones).

[b]⭐️ Trade the three core plays[/b]

Almost every setup is one of these. Use the zone edges for entries and stops:

[b]Bounce (long at support)[/b]
- Price drops into a strong green Support zone with the bias bullish or balanced.
- Wait for a reaction candle (rejection wick/engulfing) inside or at the zone.
- Entry on the reaction; stop just below the zone; first target = POC or the nearest resistance.

https://www.tradingview.com/x/QW7nbJMb/

[b] Reject (short at resistance)[/b]
- Price rallies into a strong red Resistance zone with the bias bearish or balanced.
- Look for a rejection / the “Resistance Reject” marker.
- Entry on the reaction; stop just above the zone; target = POC or nearest support.

https://www.tradingview.com/x/5DJ63mci/


[b] Breakout / Breakdown (momentum)[/b]
-A decisive close through a zone (ideally with the BUY/SELL signal and volume confirmation on) flips it from resistance to support (or vice-versa).
-Enter on the break or the retest of the flipped zone; target the next zone up/down.
- Breaks through a thin LVN tend to run fast to the next High-Volume Node.

 https://www.tradingview.com/x/z65mIRTL/


[b]Stack confluence for the best setups[/b]

The highest-probability trades are where several things line up:

Zone + POC: a level sitting on the Point of Control is a heavy magnet.
Zone + Value Area edge: VAH/VAL rejections are classic mean-reversion spots.
Zone + Fair Value Gap turn on FVGs: a gap that overlaps a zone is a strong target.
Zone + LVN beyond it: if there’s an air pocket just past a zone, a break can accelerate quickly.
High Strength % + low retest count: fresh, heavy levels react best.

Feel free to explore, learn from, and build upon this indicator. Feedback, suggestions, and ideas for future improvements are always welcome and appreciated.

[i]This indicator is provided for educational and analytical purposes only and does not constitute financial, investment, or trading advice. All signals, levels, and zones are based on historical market data and should be used alongside your own analysis and risk management. Trading involves risk, and past performance or historical price reactions do not guarantee future results.
[/i]

## Source Code

````pine
//@version=6
indicator("HexaTrades - VRVP Visible Range Support Resistance Matrix", "HexaTrades Volume Profile S/R Matrix", overlay = true,
     max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ==================== INPUTS ====================
// --- Profile window ---
useFixed   = input.bool(true, "Use Fixed Candle Count", group="Profile")
lookback   = input.int(360, "Fixed Candles", minval=10, maxval=5000, group="Profile")
bins       = input.int(110, "Profile Bins / Rows", minval=20, maxval=200, group="Profile")
visScan    = input.int(3000, "Max Bars To Scan (Visible Range)", minval=50, maxval=5000, group="Profile")

// --- S/R zones ---
numZones    = input.int(16, "Max Volume Peaks To Test", minval=1, maxval=40, group="Zones")
maxPerSide  = input.int(5, "Max Zones Per Side", minval=1, maxval=12, group="Zones")
hvnPct      = input.float(45, "Min Zone Strength (% of POC)", minval=5, maxval=100, group="Zones")
minRows     = input.int(10, "Min Distance Between Zones (rows)", minval=1, maxval=100, group="Zones")
widthMult   = input.float(0.6, "Zone Thickness Mult", minval=0.1, step=0.1, group="Zones")
useATR      = input.bool(true, "Thickness From ATR", group="Zones")
anchorTouch = input.bool(false, "Zones Start At Last Touch", group="Zones")
showStrength = input.bool(true, "Show Strength %", group="Zones")
showTouches  = input.bool(true, "Show Retest Count", group="Zones")

// --- Value Area / POC ---
showPOC     = input.bool(false, "Show POC Line", group="Value Area")
showVAHVAL  = input.bool(false, "Show VAH / VAL Lines", group="Value Area")
vaPct       = input.float(70, "Value Area %", minval=30, maxval=95, group="Value Area")

// --- Dashboard ---
showStats   = input.bool(true, "Show Stats Dashboard", group="Dashboard")
statsPos    = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Dashboard")

// --- Profile drawing ---
showProfile = input.bool(true, "Show Volume Profile", group="Profile View")
profWidth   = input.int(110, "Profile Width (bars)", minval=10, maxval=400, group="Profile View")
profOffset  = input.int(40, "Profile Gap From Candles (bars)", minval=0, maxval=300, group="Profile View")

// --- Low volume nodes ---
showLVN    = input.bool(true, "Show LVN Levels", group="Nodes")
lvnPct     = input.float(25, "LVN Pct Of POC", minval=1, maxval=90, group="Nodes")

// --- Smart Money / FVG ---
showFVG      = input.bool(false, "Show Fair Value Gaps", group="Smart Money")
maxFVG       = input.int(6, "Max FVGs", minval=1, maxval=20, group="Smart Money")

// --- Signals ---
useVolConf = input.bool(true, "Volume Confirm", group="Signals")
volMaLen   = input.int(20, "Volume MA Length", minval=2, group="Signals")
useAlerts  = input.bool(true, "Enable Alerts", group="Signals")
approachPct = input.float(0.5, "Approach Alert Distance %", minval=0.05, step=0.05, group="Signals")

// --- Style ---
showLabels = input.bool(true, "Show Labels", group="Style")
supCol     = input.color(color.new(color.green, 55), "Support Fill (strong)", group="Style")
resCol     = input.color(color.new(color.red, 55), "Resistance Fill (strong)", group="Style")
buyCol     = input.color(color.new(#00897b, 0), "Buy Volume (dark teal)", group="Style")
sellColUp  = input.color(color.new(#6a1b9a, 0), "Sell Volume Above Price", group="Style")
sellColDn  = input.color(color.new(#9c27b0, 0), "Sell Volume Below Price", group="Style")
pocCol     = input.color(color.new(color.orange, 0), "POC Color", group="Style")
vaCol      = input.color(color.new(#2962ff, 0), "VAH / VAL Line Color", group="Style")
lvnCol     = input.color(color.new(color.gray, 45), "LVN Color", group="Style")
fvgCol     = input.color(color.new(color.yellow, 80), "FVG Box", group="Style")

// ==================== GLOBALS ====================
atr   = ta.atr(14)
volMa = ta.sma(volume, volMaLen)

leftT  = chart.left_visible_bar_time
rightT = chart.right_visible_bar_time

var array<box>   zBoxes  = array.new<box>()
var array<box>   pBoxes  = array.new<box>()
var array<line>  zLines  = array.new<line>()
var array<label> zLabels = array.new<label>()

var float nearestRes = na
var float nearestSup = na

var table statsTbl = table.new(position.top_right, 2, 8, border_width = 1,
     border_color = color.new(color.gray, 40), frame_color = color.new(color.gray, 20),
     frame_width = 2)

// ==================== HELPERS ====================
// Local-minimum (thin-volume) test, bounds-guarded.
isLvnBin(arr, idx, n, lvnT, floorT) =>
    bool res = false
    if idx > 0 and idx < n - 1
        v  = array.get(arr, idx)
        vl = array.get(arr, idx - 1)
        vr = array.get(arr, idx + 1)
        res := v < lvnT and v > floorT and v <= vl and v <= vr
    res

// Most recent bar offset whose range touched the band (newest hit, stops early).
lastTouch(price, band, maxJ) =>
    int found = maxJ
    for j = 0 to maxJ
        if high[j] >= price - band and low[j] <= price + band
            found := j
            break
    found

// Count distinct retests: each time price re-enters the band from outside.
zoneRetests(price, band, oldest, newest) =>
    int c = 0
    bool wasInside = false
    for j = oldest to newest          // oldest>newest => walks forward in time
        bool nowInside = high[j] >= price - band and low[j] <= price + band
        if nowInside and not wasInside
            c += 1
        wasInside := nowInside
    c

// ==================== BUILD + DRAW ====================
// Fixed mode always runs; Visible-Range mode needs valid visible times.
if barstate.islast and (useFixed or (not na(leftT) and not na(rightT)))
    for b in zBoxes
        box.delete(b)
    for pb in pBoxes
        box.delete(pb)
    for l in zLines
        line.delete(l)
    for la in zLabels
        label.delete(la)
    array.clear(zBoxes)
    array.clear(pBoxes)
    array.clear(zLines)
    array.clear(zLabels)

    // ----- Pass 1: bar range [rightIdx..leftIdx] + window high/low -----
    float hi = na
    float lo = na
    int rightIdx = 0
    int leftIdx  = 0
    bool started = false

    if useFixed
        leftIdx := math.min(lookback - 1, bar_index)
        for i = 0 to leftIdx
            hi := na(hi) ? high[i] : math.max(hi, high[i])
            lo := na(lo) ? low[i]  : math.min(lo, low[i])

    if not useFixed
        for i = 0 to visScan
            int t = time[i]
            if na(t)
                break
            if t > rightT
                continue
            if t < leftT
                break
            if not started
                rightIdx := i
                started := true
            leftIdx := i
            hi := na(hi) ? high[i] : math.max(hi, high[i])
            lo := na(lo) ? low[i]  : math.min(lo, low[i])

    float binSize = na(hi) or na(lo) ? na : (hi - lo) / bins

    if not na(binSize) and binSize > 0
        // ----- Pass 2: volume-by-price, split into buy (up) / sell (down) -----
        vp   = array.new_float(bins, 0.0)
        vpUp = array.new_float(bins, 0.0)
        vpDn = array.new_float(bins, 0.0)
        for i = rightIdx to leftIdx
            int loBin = math.max(0, math.min(bins - 1, int((low[i]  - lo) / binSize)))
            int hiBin = math.max(0, math.min(bins - 1, int((high[i] - lo) / binSize)))
            float share = volume[i] / (hiBin - loBin + 1)
            bool up = close[i] >= open[i]
            for bb = loBin to hiBin
                array.set(vp, bb, array.get(vp, bb) + share)
                if up
                    array.set(vpUp, bb, array.get(vpUp, bb) + share)
                else
                    array.set(vpDn, bb, array.get(vpDn, bb) + share)

        float pocVol = array.max(vp)
        float halfW = (useATR ? atr : binSize) * widthMult / 2.0
        int zoneLeftX = bar_index - leftIdx
        int profRightX = bar_index + profOffset + profWidth   // right edge of the profile

        // Role reference: flip support<->resistance only on a confirmed close.
        float refClose = barstate.isconfirmed ? close : close[1]

        // ----- POC + Value Area (always computed; reused by lines + dashboard) -----
        int   pocIdx = array.indexof(vp, pocVol)
        float pocPx  = lo + (pocIdx + 0.5) * binSize
        float totVol = array.sum(vp)
        float vaVol  = pocVol
        int   upI = pocIdx
        int   dnI = pocIdx
        while vaVol < totVol * vaPct / 100.0 and (upI < bins - 1 or dnI > 0)
            float vUp = upI < bins - 1 ? array.get(vp, upI + 1) : -1.0
            float vDn = dnI > 0        ? array.get(vp, dnI - 1) : -1.0
            if vUp < 0 and vDn < 0
                break
            if vUp >= vDn
                upI += 1
                vaVol += vUp
            else
                dnI -= 1
                vaVol += vDn
        float vahPx = lo + (upI + 0.5) * binSize
        float valPx = lo + (dnI + 0.5) * binSize

        // ----- Volume profile (buy/sell split, radiant, faces LEFT, right of price) -----
        if showProfile and pocVol > 0
            float pocUp = math.max(array.max(vpUp), 1.0)
            float pocDn = math.max(array.max(vpDn), 1.0)
            int rightX = profRightX
            for k = 0 to bins - 1
                float up = array.get(vpUp, k)
                float dn = array.get(vpDn, k)
                float vTot = up + dn
                if vTot > 0
                    float mid = lo + (k + 0.5) * binSize
                    float top = mid + binSize / 2.0
                    float bot = mid - binSize / 2.0
                    int upLen = int(up / pocVol * profWidth)
                    int dnLen = int(dn / pocVol * profWidth)
                    if upLen + dnLen < 1
                        upLen := up >= dn ? 1 : 0
                        dnLen := up >= dn ? 0 : 1
                    // Buy (teal) hugs the axis; color radiant by buy intensity.
                    if upLen > 0
                        color buyG = color.from_gradient(up, 0, pocUp, color.new(buyCol, 90), buyCol)
                        array.push(pBoxes, box.new(rightX - upLen, top, rightX, bot,
                             border_width = 0, bgcolor = buyG))
                    // Sell (purple) stacks to the left; brighter above price.
                    if dnLen > 0
                        color sellBase = mid > close ? sellColUp : sellColDn
                        color sellG = color.from_gradient(dn, 0, pocDn, color.new(sellBase, 90), sellBase)
                        array.push(pBoxes, box.new(rightX - upLen - dnLen, top, rightX - upLen, bot,
                             border_width = 0, bgcolor = sellG))

        // ----- POC line -----
        if showPOC and pocVol > 0
            array.push(zLines, line.new(zoneLeftX, pocPx, profRightX, pocPx,
                 color = pocCol, width = 2))
            if showLabels
                array.push(zLabels, label.new(bar_index + profOffset, pocPx, "POC",
                     color = pocCol, textcolor = color.white,
                     style = label.style_label_left, size = size.tiny))

        // ----- VAH / VAL lines -----
        if showVAHVAL and pocVol > 0
            array.push(zLines, line.new(zoneLeftX, vahPx, profRightX, vahPx,
                 color = vaCol, style = line.style_dashed))
            array.push(zLines, line.new(zoneLeftX, valPx, profRightX, valPx,
                 color = vaCol, style = line.style_dashed))
            if showLabels
                array.push(zLabels, label.new(bar_index + profOffset, vahPx, "VAH",
                     color = vaCol, textcolor = color.white,
                     style = label.style_label_left, size = size.tiny))
                array.push(zLabels, label.new(bar_index + profOffset, valPx, "VAL",
                     color = vaCol, textcolor = color.white,
                     style = label.style_label_left, size = size.tiny))

        // ----- S/R zones (strength + retests + spacing + per-side cap) -----
        float nr = na
        float ns = na
        int resCount = 0
        int supCount = 0
        array<float> zonePrices = array.new<float>()
        if pocVol > 0
            vpCopy = array.copy(vp)
            float hvnT = pocVol * hvnPct / 100.0
            int scanned = 0
            while scanned < numZones
                if resCount >= maxPerSide and supCount >= maxPerSide
                    break
                float m = array.max(vpCopy)
                if m < hvnT
                    break
                int bi = array.indexof(vpCopy, m)
                float price = lo + (bi + 0.5) * binSize
                int strength = int(m / pocVol * 100)

                // Min gap measured in profile rows; floored at the zone thickness
                // so neighbouring boxes never overlap.
                float gapDist = math.max(minRows * binSize, halfW * 2.0)
                int sepBins = math.max(1, int(gapDist / binSize))
                int s0 = math.max(0, bi - sepBins)
                int s1 = math.min(bins - 1, bi + sepBins)
                for s = s0 to s1
                    array.set(vpCopy, s, -1.0)

                // hard minimum distance vs already-kept zones
                bool tooClose = false
                if array.size(zonePrices) > 0
                    for zi = 0 to array.size(zonePrices) - 1
                        if math.abs(array.get(zonePrices, zi) - price) < gapDist
                            tooClose := true
                            break

                bool isSup = price < refClose
                bool sideFull = isSup ? supCount >= maxPerSide : resCount >= maxPerSide

                if not tooClose and not sideFull
                    array.push(zonePrices, price)
                    int touches = zoneRetests(price, halfW, leftIdx, rightIdx)
                    color hue   = isSup ? color.green : color.red
                    color fillC = color.from_gradient(strength, 0, 100, color.new(hue, 90), isSup ? supCol : resCol)
                    color bordC = color.new(hue, 0)

                    int lx = anchorTouch ? bar_index - lastTouch(price, halfW, leftIdx) : zoneLeftX
                    array.push(zBoxes, box.new(lx, price + halfW, profRightX, price - halfW,
                         border_color = bordC, border_width = 1, bgcolor = fillC))

                    if showLabels
                        string txt = (isSup ? "Support" : "Resistance") +
                             (showStrength ? " " + str.tostring(strength) + "%" : "") +
                             (showTouches and touches > 1 ? "  x" + str.tostring(touches) : "")
                        array.push(zLabels, label.new(bar_index + profOffset, price, txt,
                             color = bordC, textcolor = color.white,
                             style = label.style_label_left, size = size.small))

                    if isSup
                        ns := na(ns) ? price : math.max(ns, price)
                        supCount += 1
                    else
                        nr := na(nr) ? price : math.min(nr, price)
                        resCount += 1
                scanned += 1

        // ----- LVN imbalance levels (nearest local minima) -----
        if showLVN and pocVol > 0
            float lvnT = pocVol * lvnPct / 100.0
            float floorT = pocVol * 0.03
            int curIdx = math.max(0, math.min(bins - 1,
                 int((close - lo) / binSize)))
            int maxLvn = math.min(numZones, 5)
            int foundLvn = 0
            for d = 1 to bins - 1
                if foundLvn >= maxLvn
                    break
                int li = curIdx - d
                int ri = curIdx + d
                if li >= 0 and isLvnBin(vp, li, bins, lvnT, floorT)
                    float pl = lo + (li + 0.5) * binSize
                    array.push(zLines, line.new(zoneLeftX, pl, profRightX, pl,
                         color = lvnCol, style = line.style_dashed))
                    if showLabels
                        array.push(zLabels, label.new(bar_index + profOffset, pl, "LVN",
                             color = color.gray, textcolor = color.white,
                             style = label.style_label_left, size = size.tiny))
                    foundLvn += 1
                if foundLvn < maxLvn and ri <= bins - 1 and
                     isLvnBin(vp, ri, bins, lvnT, floorT)
                    float pr = lo + (ri + 0.5) * binSize
                    array.push(zLines, line.new(zoneLeftX, pr, profRightX, pr,
                         color = lvnCol, style = line.style_dashed))
                    if showLabels
                        array.push(zLabels, label.new(bar_index + profOffset, pr, "LVN",
                             color = color.gray, textcolor = color.white,
                             style = label.style_label_left, size = size.tiny))
                    foundLvn += 1

        // ----- Fair Value Gaps (small yellow boxes, unfilled only) -----
        if showFVG and leftIdx > 3
            float minLowNewer  = low[0]
            float maxHighNewer = high[0]
            int foundFVG = 0
            for j = 1 to leftIdx - 2
                if foundFVG >= maxFVG
                    break
                bool isBull = high[j + 2] < low[j]
                bool isBear = low[j + 2] > high[j]
                if isBull or isBear
                    float gTop = isBull ? low[j] : low[j + 2]
                    float gBot = isBull ? high[j + 2] : high[j]
                    bool isOpen = isBull ? (minLowNewer > gBot) : (maxHighNewer < gTop)
                    if isOpen
                        array.push(zBoxes, box.new(bar_index - j, gTop, bar_index, gBot,
                             border_color = color.new(color.yellow, 30), border_width = 1,
                             bgcolor = fvgCol, text = "FVG", text_color = color.new(color.orange, 0),
                             text_size = size.tiny, text_halign = text.align_center,
                             text_valign = text.align_center))
                        foundFVG += 1
                minLowNewer  := math.min(minLowNewer, low[j])
                maxHighNewer := math.max(maxHighNewer, high[j])

        // ----- Stats dashboard -----
        if showStats and pocVol > 0
            color hdrBg  = color.new(#1e222d, 0)
            color cellBg = color.new(#2a2e39, 0)
            color txtC   = color.white
            string bias  = close > vahPx ? "Bullish" : close < valPx ? "Bearish" : "Balanced"
            color  biasC = close > vahPx ? color.lime : close < valPx ? color.red : color.gray
            table.set_position(statsTbl, statsPos == "Top Left" ? position.top_left :
                 statsPos == "Bottom Right" ? position.bottom_right :
                 statsPos == "Bottom Left" ? position.bottom_left : position.top_right)
            table.cell(statsTbl, 0, 0, "📊 VRVP Stats", text_color = txtC, bgcolor = hdrBg, text_size = size.small)
            table.cell(statsTbl, 1, 0, "", bgcolor = hdrBg)
            table.cell(statsTbl, 0, 1, "🎯 POC", text_color = txtC, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 1, 1, str.tostring(pocPx, format.mintick), text_color = color.orange, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 0, 2, "🔼 VAH", text_color = txtC, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 1, 2, str.tostring(vahPx, format.mintick), text_color = txtC, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 0, 3, "🔽 VAL", text_color = txtC, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 1, 3, str.tostring(valPx, format.mintick), text_color = txtC, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 0, 4, "🟥 Nearest Res", text_color = txtC, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 1, 4, na(nr) ? "-" : str.tostring(nr, format.mintick), text_color = #ff5252, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 0, 5, "🟩 Nearest Sup", text_color = txtC, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 1, 5, na(ns) ? "-" : str.tostring(ns, format.mintick), text_color = #26a69a, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 0, 6, "🧭 Trend Bias", text_color = txtC, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 1, 6, bias, text_color = biasC, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 0, 7, "📐 Zones R / S", text_color = txtC, bgcolor = cellBg, text_size = size.small)
            table.cell(statsTbl, 1, 7, str.tostring(resCount) + " / " + str.tostring(supCount), text_color = txtC, bgcolor = cellBg, text_size = size.small)

        nearestRes := nr
        nearestSup := ns

// ==================== SIGNALS ====================
volOk = not useVolConf or volume > volMa

buySignal  = not na(nearestRes) and ta.crossover(close, nearestRes) and volOk
sellSignal = not na(nearestSup) and ta.crossunder(close, nearestSup) and volOk

supTouch  = not na(nearestSup) and low <= nearestSup and close > nearestSup
resReject = not na(nearestRes) and high >= nearestRes and close < nearestRes

plotshape(buySignal, title = "Buy", text = "BUY",
     style = shape.labelup, location = location.belowbar,
     color = color.green, textcolor = color.white, size = size.small)
plotshape(sellSignal, title = "Sell", text = "SELL",
     style = shape.labeldown, location = location.abovebar,
     color = color.red, textcolor = color.white, size = size.small)
plotshape(supTouch, title = "Support Touch",
     style = shape.triangleup, location = location.belowbar,
     color = color.green, size = size.tiny)
plotshape(resReject, title = "Resistance Reject",
     style = shape.triangledown, location = location.abovebar,
     color = color.red, size = size.tiny)

// ==================== ALERTS ====================
alertcondition(buySignal, title = "VRVP Breakout",
     message = "Bullish breakout above VRVP resistance")
alertcondition(sellSignal, title = "VRVP Breakdown",
     message = "Bearish breakdown below VRVP support")
alertcondition(supTouch, title = "VRVP Support Touch",
     message = "Price reacting at VRVP support")
alertcondition(resReject, title = "VRVP Resistance Reject",
     message = "Price rejected at VRVP resistance")

if buySignal and useAlerts
    alert("VRVP bullish breakout", alert.freq_once_per_bar_close)
if sellSignal and useAlerts
    alert("VRVP bearish breakdown", alert.freq_once_per_bar_close)

// Approaching-zone alerts (fire before price reaches the nearest zone)
approachRes = not na(nearestRes) and close < nearestRes and (nearestRes - close) <= nearestRes * approachPct / 100.0
approachSup = not na(nearestSup) and close > nearestSup and (close - nearestSup) <= nearestSup * approachPct / 100.0

alertcondition(approachRes, title = "VRVP Approaching Resistance",
     message = "Price approaching VRVP resistance")
alertcondition(approachSup, title = "VRVP Approaching Support",
     message = "Price approaching VRVP support")

if approachRes and useAlerts
    alert("VRVP approaching resistance", alert.freq_once_per_bar)
if approachSup and useAlerts
    alert("VRVP approaching support", alert.freq_once_per_bar)
````
