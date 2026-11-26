# Delta Flow Profile 3D [NeBlok]

- url: https://www.tradingview.com/script/aRN5FNRU-Delta-Flow-Profile-3D-NeBlok/
- type: indicator
- pine_id: PUB;e3f21345a36e4c089796d5566607179f
- version: 1.0

## Description

DELTA FLOW PROFILE 3D [NeBlok]

OVERVIEW
Delta Flow Profile 3D shows where buyers and sellers were aggressive inside a lookback window, and at which prices. It combines four tools in one overlay:

1. A 3D delta profile that shows net buying or selling at each price level
2. A Point of Control (POC) and Value Area built from total volume
3. Delta spike detection that flags bars with unusually strong buying or selling
4. Imbalance levels anchored to each spike, drawn as 3D plates that stay on the chart until price returns to them

The goal is to show not just where volume traded, but who was in control at each price.


HOW THE DELTA IS CALCULATED
Delta is the difference between buying volume and selling volume. This script estimates it in one of two ways, selected under Delta Method:

- Intrabar (default and recommended): The script requests lower-timeframe bars inside each chart bar. Each intrabar is classified as buying if it closed above its open, or selling if it closed below its open. When an intrabar opens and closes at the same price, the script compares its close to the previous intrabar's close (the tick rule). Adding these up gives a more detailed buy/sell estimate than the chart bar alone can provide.

- Bar Geometry: Each bar's volume is split by where it closed within its high-low range. A close near the high counts mostly as buying, and a close near the low counts mostly as selling. This works on any symbol and timeframe but is less precise.

If Intrabar mode is selected but lower-timeframe data is not available for a bar, that bar automatically falls back to Bar Geometry. The summary label shows the "Intrabar coverage" percentage so you always know how much of the profile is built from intrabar data. Higher is better.

Automatic intrabar timeframe selection (when the Intrabar Timeframe input is left blank):
- Chart at 1 minute or lower: the chart's own timeframe
- Chart up to 1 hour: 1 minute
- Chart up to 4 hours: 5 minutes
- Chart up to 1 day: 15 minutes
- Higher timeframes: 60 minutes

Important: This is an ESTIMATE of order flow built from price and volume data. It is not true bid/ask footprint data from the exchange.


READING THE 3D PROFILE
The profile sits to the right of current price and is split by a vertical dotted axis.

- Bars extending RIGHT of the axis (buy color) = net buying at that price level
- Bars extending LEFT of the axis (sell color) = net selling at that price level
- Bar length = the size of the net delta at that price compared with the largest row in the profile
- Yellow row = POC, the price level with the most total volume (buying plus selling) in the window
- Brighter rows = inside the Value Area (70% of total volume by default)
- Dimmed rows = outside the Value Area

A dotted POC line extends from the start of the lookback window to the profile, so you can see how price has interacted with it over time.

A 3D frame outlines the lookback window, so you can see exactly which bars the profile is measuring.

How traders commonly read it:
- Strong buying below current price can show where buyers defended.
- Strong selling above current price can show where sellers were active.
- The POC is often treated as a "fair value" area that price tends to revisit.
- The Value Area edges mark where most business was done. Moves outside the Value Area are often watched for acceptance (price holds there) or rejection (price returns inside).
- A price level with high total volume but near-zero delta means buyers and sellers were evenly matched there.


DELTA SPIKES (GLOW PILLARS)
A delta spike is a bar whose delta is a statistical outlier compared with recent bars. The script measures this with a z-score over the Spike Baseline Length (default 100 bars).

- Buy-colored pillar = unusually strong buying on that bar
- Sell-colored pillar = unusually strong selling on that bar

Because the threshold is based on standard deviations rather than a fixed volume number, it adapts to each symbol's normal activity. A spike on a thinly traded stock and a spike on a heavily traded index future are both measured against their own recent behavior.

Pillars are only drawn inside the lookback window.


IMBALANCE LEVELS (3D PLATES)
Every delta spike creates an imbalance level. The level is placed at the spike bar's intrabar VWAP (volume-weighted average price), which estimates where the aggressive volume actually traded. With Bar Geometry, it uses the bar's typical price instead.

- Buy-colored plates come from bullish spikes. They are watched as potential support.
- Sell-colored plates come from bearish spikes. They are watched as potential resistance.
- An active level extends to the right on every new bar until price comes back to it.
- Once price returns (mitigation), the level stops extending. If "Keep Mitigated Levels" is on, it stays on the chart in a faded color for reference.

Mitigation Trigger:
- Wick: The level is mitigated as soon as price trades through it (low below a bullish level, or high above a bearish level). This is more sensitive.
- Close: The level is mitigated only when a bar closes through it. This is more forgiving.

How traders commonly use these levels:
- As areas to watch for a reaction when price returns
- As confluence when a level lines up with the POC, a Value Area edge, or a large profile row
- As a record of where strong participants stepped in

An unmitigated level is not a guaranteed reaction point. Treat it as an area of interest, not a signal on its own.


SETTINGS GUIDE

Delta Engine
- Delta Method: Intrabar (more accurate) or Bar Geometry (works everywhere)
- Intrabar Timeframe: Leave blank for automatic, or set your own. If you choose a timeframe higher than the chart's, the script uses the chart timeframe instead.

Profile
- Lookback Bars (default 300): How many bars the profile, frame, and spike pillars cover
- Rows (default 28): Number of price levels. More rows give finer detail, fewer rows give a smoother picture.
- Max Bar Length (default 45): Length in bars of the largest row
- Offset From Last Bar (default 15): Gap between the current bar and the profile
- Value Area % (default 70): Share of total volume included in the Value Area
- Highlight POC + POC Line: Turns the yellow POC row and the POC line on or off
- Dim Rows Outside Value Area: Fades rows outside the Value Area
- Show Row Delta Values: Prints the net delta number beside each row
- Show Summary Label: Shows net delta, POC, Value Area range, and intrabar coverage

3D Style
- Depth X: Horizontal depth of the 3D effect, in bars
- Depth Y: Vertical depth of the 3D effect, as a multiple of row height
- Show 3D Window Frame: Turns the lookback frame on or off
Set both depth values to 0 for a flat 2D look.

Delta Spikes & Levels
- Show Delta Spike Pillars: Turns the pillars on or off
- Spike Baseline Length (default 100): Number of bars used to define "normal" delta
- Spike Threshold (default 2.5): Z-score required to count as a spike. Raise it for fewer, stronger spikes. Lower it for more frequent signals.
- Show Imbalance Levels: Turns the plates on or off
- Max Levels (default 20): Maximum number of levels kept on the chart
- Mitigation Trigger: Wick or Close
- Keep Mitigated Levels: Keeps or removes levels after price returns to them

Colors
- Buy Delta, Sell Delta, POC, and Frame/Axis colors are all adjustable.

Data Window
- "Bar Delta" and "Delta Z-Score" for each bar appear in the Data Window. You can use them to check how strong any individual bar was.


ALERTS
The script includes four alerts, each evaluated once per bar close:
- Bullish delta spike (includes the delta value and level price)
- Bearish delta spike (includes the delta value and level price)
- Price returned to a bullish imbalance level
- Price returned to a bearish imbalance level

To set them up: open the Alerts panel, choose this indicator as the condition, and select "Any alert() function call."


TIPS FOR BEST RESULTS
- Use symbols with reliable volume data: stocks, ETFs, futures, and crypto. The script stops with an error if the symbol has no volume data.
- Watch the Intrabar coverage percentage. TradingView limits how much lower-timeframe history is available, so older bars in a long lookback may fall back to Bar Geometry. Shorter lookbacks or a higher intrabar timeframe usually improve coverage.
- The profile spreads each bar's buy and sell volume evenly across that bar's high-low range. Using more bars in the lookback and a moderate row count gives a more stable picture.
- Spikes and levels on the live, unfinished bar can appear and disappear as the bar develops. They are final only once the bar closes.
- The profile, POC, Value Area, and frame are redrawn on every new bar as the lookback window moves forward.
- This tool works best as context alongside your own analysis, market structure, and risk management, not as a standalone entry signal.


DISCLAIMER
This indicator is provided free for educational and informational purposes only. It is not financial advice, investment advice, trading advice, or a recommendation to buy or sell any security, futures contract, or other financial instrument.

Order flow and delta values in this script are estimates built from price and volume data and may not reflect actual exchange-level buy and sell activity. Signals, levels, and alerts can be wrong, can change on the live bar, and may behave differently on different symbols, timeframes, and data feeds.

Trading involves substantial risk of loss and is not suitable for everyone. Past performance, whether actual or shown by any indicator, does not guarantee future results. You are solely responsible for your own trading decisions. Always do your own research, use proper risk management, and consider consulting a licensed financial professional before making any financial decisions.

By using this script, you agree that the author and NeBlok are not liable for any losses or damages resulting from its use.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © James_Mason

// © NeBlok
//
// Delta Flow Profile 3D [NeBlok]
// ------------------------------------------------------------------------------------
// What it does
//  1. Estimates buy vs. sell volume for every bar from lower-timeframe (intrabar) data.
//     Each intrabar is classified by its body direction (tick rule on dojis).
//     If intrabar data isn't available for a bar, it falls back to bar geometry
//     (close location inside the high-low range).
//  2. Builds a diverging 3D delta profile over the lookback window:
//     net buying extends RIGHT of the axis, net selling extends LEFT.
//     POC (highest total volume row) is highlighted; rows outside the Value Area dim.
//  3. Flags "delta spikes" (bars whose delta is a statistical outlier, z-score) with glow pillars.
//  4. Each spike anchors an imbalance level at that bar's intrabar VWAP, drawn as a 3D plate
//     that extends right until price mitigates it.
// ------------------------------------------------------------------------------------

//@version=6
indicator("Delta Flow Profile 3D [NeBlok]", shorttitle = "DFP3D [NeBlok]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_polylines_count = 100)

// ═════════════════════════════════════════ INPUTS ═════════════════════════════════════════
grpD = "Delta Engine"
deltaMethod = input.string("Intrabar", "Delta Method", options = ["Intrabar", "Bar Geometry"], group = grpD, tooltip = "Intrabar: classifies lower-timeframe bars as buying or selling (more accurate).\nBar Geometry: splits each bar's volume by where it closed in its range (works everywhere, less precise).\nIntrabar mode falls back to Bar Geometry on any bar without intrabar data.")
ltfInput    = input.timeframe("", "Intrabar Timeframe (blank = auto)", group = grpD)

grpP = "Profile"
lookback    = input.int(300, "Lookback Bars", minval = 20, maxval = 2000, group = grpP)
rows        = input.int(28, "Rows", minval = 5, maxval = 40, group = grpP)
profWidth   = input.int(45, "Max Bar Length (bars)", minval = 10, maxval = 150, group = grpP)
profOffset  = input.int(15, "Offset From Last Bar (bars)", minval = 2, maxval = 100, group = grpP)
vaPct       = input.float(70.0, "Value Area %", minval = 10.0, maxval = 100.0, group = grpP) / 100.0
showPOC     = input.bool(true, "Highlight POC + POC Line", group = grpP)
dimOutVA    = input.bool(true, "Dim Rows Outside Value Area", group = grpP)
showRowVals = input.bool(false, "Show Row Delta Values", group = grpP)
showHeader  = input.bool(true, "Show Summary Label", group = grpP)

grp3 = "3D Style"
depthX      = input.int(4, "Depth X (bars)", minval = 0, maxval = 20, group = grp3)
depthY      = input.float(0.6, "Depth Y (× row height)", minval = 0.0, maxval = 3.0, step = 0.1, group = grp3)
showFrame   = input.bool(true, "Show 3D Window Frame", group = grp3)

grpS = "Delta Spikes & Levels"
showSpikes    = input.bool(true, "Show Delta Spike Pillars", group = grpS)
zLen          = input.int(100, "Spike Baseline Length", minval = 10, group = grpS)
zThr          = input.float(2.5, "Spike Threshold (z-score)", minval = 0.5, step = 0.1, group = grpS, tooltip = "How many standard deviations a bar's delta must be from its baseline to count as a spike. Higher = fewer, stronger spikes.")
showLevels    = input.bool(true, "Show Imbalance Levels", group = grpS)
maxLevels     = input.int(20, "Max Levels", minval = 1, maxval = 40, group = grpS)
mitigation    = input.string("Wick", "Mitigation Trigger", options = ["Wick", "Close"], group = grpS)
keepMitigated = input.bool(true, "Keep Mitigated Levels (faded)", group = grpS)

grpC = "Colors"
bullCol  = input.color(#14b8a6, "Buy Delta", group = grpC)
bearCol  = input.color(#f23645, "Sell Delta", group = grpC)
pocCol   = input.color(#ffd600, "POC", group = grpC)
frameCol = input.color(#787b8680, "Frame / Axis", group = grpC)

// ═════════════════════════════════════════ TYPES & STORAGE ═════════════════════════════════════════
type Level
    float price
    int   left
    int   right
    bool  bull
    bool  active

var array<float> hArr = array.new<float>()   // bar highs
var array<float> lArr = array.new<float>()   // bar lows
var array<float> bArr = array.new<float>()   // buy volume
var array<float> sArr = array.new<float>()   // sell volume
var array<int>   xArr = array.new<int>()     // bar indexes
var array<int>   cArr = array.new<int>()     // 1 = intrabar data used, 0 = fallback
var array<Level> levels = array.new<Level>()

var array<box>      pBoxes  = array.new<box>()
var array<polyline> pPolys  = array.new<polyline>()
var array<line>     pLines  = array.new<line>()
var array<label>    pLabels = array.new<label>()

f_line(int x1, float y1, int x2, float y2, color c, int w, string st) =>
    pLines.push(line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = c, width = w, style = st))

f_fmtDelta(float d) =>
    (d >= 0 ? "+" : "") + str.tostring(d, format.volume)

// ═════════════════════════════════════════ DELTA ENGINE ═════════════════════════════════════════
chartSec = timeframe.in_seconds()
autoLTF  = chartSec <= 60 ? timeframe.period : chartSec <= 3600 ? "1" : chartSec <= 14400 ? "5" : chartSec <= 86400 ? "15" : "60"
ltfTF    = ltfInput == "" ? autoLTF : timeframe.in_seconds(ltfInput) > chartSec ? timeframe.period : ltfInput

[ltfO, ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, ltfTF, [open, close, volume], ignore_invalid_timeframe = true)

float buyV  = 0.0
float sellV = 0.0
float pvSum = 0.0
float vSum  = 0.0
int   nIntra   = ltfC.size()
bool  useIntra = deltaMethod == "Intrabar" and nIntra > 0

if useIntra
    float prevC = na
    for i = 0 to nIntra - 1
        float o = ltfO.get(i)
        float c = ltfC.get(i)
        float v = nz(ltfV.get(i))
        float dir = c > o ? 1.0 : c < o ? -1.0 : na(prevC) ? 0.0 : c > prevC ? 1.0 : c < prevC ? -1.0 : 0.0
        if dir > 0
            buyV += v
        else if dir < 0
            sellV += v
        else
            buyV  += v * 0.5
            sellV += v * 0.5
        pvSum += c * v
        vSum  += v
        prevC := c
else
    float v   = nz(volume)
    float rng = high - low
    buyV  := rng > 0 ? v * (close - low) / rng : v * 0.5
    sellV := v - buyV
    pvSum := hlc3 * v
    vSum  := v

float barDelta = buyV - sellV
float anchor   = vSum > 0 ? pvSum / vSum : hlc3   // intrabar VWAP of this bar

// ═════════════════════════════════════════ SPIKE DETECTION ═════════════════════════════════════════
float dMean = ta.sma(barDelta, zLen)
float dDev  = ta.stdev(barDelta, zLen)
float z     = dDev > 0 ? (barDelta - dMean) / dDev : 0.0
bool bullSpike = z >= zThr and barDelta > 0
bool bearSpike = z <= -zThr and barDelta < 0
bool inWindow  = bar_index > last_bar_index - lookback

if showSpikes and inWindow and (bullSpike or bearSpike)
    color sc = bullSpike ? bullCol : bearCol
    line.new(bar_index, high, bar_index, low, color = color.new(sc, 80), width = 8)
    line.new(bar_index, high, bar_index, low, color = color.new(sc, 20), width = 2)

// ═════════════════════════════════════════ ROLLING WINDOW ═════════════════════════════════════════
hArr.push(high)
lArr.push(low)
bArr.push(buyV)
sArr.push(sellV)
xArr.push(bar_index)
cArr.push(useIntra ? 1 : 0)
if hArr.size() > lookback
    hArr.shift()
    lArr.shift()
    bArr.shift()
    sArr.shift()
    xArr.shift()
    cArr.shift()

// ═════════════════════════════════════════ IMBALANCE LEVELS ═════════════════════════════════════════
bool bullLevelHit = false
bool bearLevelHit = false

for lv in levels
    if lv.active
        bool hit = mitigation == "Wick" ? (lv.bull ? low < lv.price : high > lv.price) : (lv.bull ? close < lv.price : close > lv.price)
        lv.right := bar_index
        if hit
            lv.active := false
            if lv.bull
                bullLevelHit := true
            else
                bearLevelHit := true

if not keepMitigated and levels.size() > 0
    for i = levels.size() - 1 to 0
        if not levels.get(i).active
            levels.remove(i)

if showLevels and (bullSpike or bearSpike)
    levels.unshift(Level.new(anchor, bar_index, bar_index, bullSpike, true))
    if levels.size() > maxLevels
        levels.pop()

// ═════════════════════════════════════════ VOLUME CHECK ═════════════════════════════════════════
float cumVol = ta.cum(nz(volume))
if barstate.islast and cumVol == 0
    runtime.error("No volume data on this symbol. The delta profile needs volume.")

// ═════════════════════════════════════════ RENDER (last bar only) ═════════════════════════════════════════
if barstate.islast
    for b in pBoxes
        b.delete()
    pBoxes.clear()
    for p in pPolys
        p.delete()
    pPolys.clear()
    for ln in pLines
        ln.delete()
    pLines.clear()
    for lb in pLabels
        lb.delete()
    pLabels.clear()

    int   n     = hArr.size()
    float top   = hArr.max()
    float bot   = lArr.min()
    float rowH  = n > 1 ? (top - bot) / rows : 0.0

    if n > 1 and rowH > 0
        // ── Distribute each bar's buy/sell volume across the rows its range covers
        array<float> rBuy  = array.new<float>(rows, 0.0)
        array<float> rSell = array.new<float>(rows, 0.0)
        for i = 0 to n - 1
            float h   = hArr.get(i)
            float l   = lArr.get(i)
            float bv  = bArr.get(i)
            float sv  = sArr.get(i)
            float rng = h - l
            if rng <= 0
                int r = math.max(0, math.min(rows - 1, int(math.floor((h - bot) / rowH))))
                rBuy.set(r, rBuy.get(r) + bv)
                rSell.set(r, rSell.get(r) + sv)
            else
                int r0 = math.max(0, math.min(rows - 1, int(math.floor((l - bot) / rowH))))
                int r1 = math.max(0, math.min(rows - 1, int(math.floor((h - bot) / rowH))))
                for r = r0 to r1
                    float rb = bot + r * rowH
                    float ov = math.min(h, rb + rowH) - math.max(l, rb)
                    if ov > 0
                        float f = ov / rng
                        rBuy.set(r, rBuy.get(r) + bv * f)
                        rSell.set(r, rSell.get(r) + sv * f)

        // ── Row totals, deltas, POC
        array<float> rTot = array.new<float>(rows, 0.0)
        array<float> rDel = array.new<float>(rows, 0.0)
        float totVol = 0.0
        float netDel = 0.0
        float maxAbs = 0.0
        int   poc    = 0
        for r = 0 to rows - 1
            float t = rBuy.get(r) + rSell.get(r)
            float d = rBuy.get(r) - rSell.get(r)
            rTot.set(r, t)
            rDel.set(r, d)
            totVol += t
            netDel += d
            maxAbs := math.max(maxAbs, math.abs(d))
            if t > rTot.get(poc)
                poc := r

        // ── Value Area (expand from POC toward the heavier neighbor)
        int   vaUp  = poc
        int   vaDn  = poc
        float vaVol = rTot.get(poc)
        while vaVol < totVol * vaPct and (vaUp < rows - 1 or vaDn > 0)
            float nextUp = vaUp < rows - 1 ? rTot.get(vaUp + 1) : -1.0
            float nextDn = vaDn > 0 ? rTot.get(vaDn - 1) : -1.0
            if nextUp >= nextDn
                vaUp  += 1
                vaVol += nextUp
            else
                vaDn  -= 1
                vaVol += nextDn

        int   xStart   = xArr.get(0)
        int   xAxis    = last_bar_index + profOffset + profWidth
        float dy       = rowH * depthY
        float gap      = rowH * 0.06
        float pocPrice = bot + (poc + 0.5) * rowH

        // ── 3D window frame
        if showFrame
            int xe = last_bar_index
            // front
            f_line(xStart, top, xe, top, frameCol, 1, line.style_solid)
            f_line(xStart, bot, xe, bot, frameCol, 1, line.style_solid)
            f_line(xStart, bot, xStart, top, frameCol, 1, line.style_solid)
            f_line(xe, bot, xe, top, frameCol, 1, line.style_solid)
            // back
            f_line(xStart + depthX, top + dy, xe + depthX, top + dy, frameCol, 1, line.style_solid)
            f_line(xStart + depthX, bot + dy, xe + depthX, bot + dy, frameCol, 1, line.style_solid)
            f_line(xStart + depthX, bot + dy, xStart + depthX, top + dy, frameCol, 1, line.style_solid)
            f_line(xe + depthX, bot + dy, xe + depthX, top + dy, frameCol, 1, line.style_solid)
            // connectors
            f_line(xStart, top, xStart + depthX, top + dy, frameCol, 1, line.style_solid)
            f_line(xe, top, xe + depthX, top + dy, frameCol, 1, line.style_solid)
            f_line(xStart, bot, xStart + depthX, bot + dy, frameCol, 1, line.style_solid)
            f_line(xe, bot, xe + depthX, bot + dy, frameCol, 1, line.style_solid)

        // ── Profile axis
        f_line(xAxis, bot, xAxis, top, frameCol, 1, line.style_dotted)

        // ── POC line across the window
        if showPOC
            f_line(xStart, pocPrice, xAxis, pocPrice, color.new(pocCol, 40), 1, line.style_dotted)

        // ── Imbalance level plates
        if showLevels and levels.size() > 0
            float ldy = dy * 0.5
            for lv in levels
                if lv.active or keepMitigated
                    color lc = lv.bull ? bullCol : bearCol
                    int   tr = lv.active ? 45 : 80
                    array<chart.point> lp = array.from(chart.point.from_index(lv.left, lv.price), chart.point.from_index(lv.right, lv.price), chart.point.from_index(lv.right + depthX, lv.price + ldy), chart.point.from_index(lv.left + depthX, lv.price + ldy))
                    pPolys.push(polyline.new(lp, closed = true, xloc = xloc.bar_index, line_color = color.new(lc, math.min(100, tr + 10)), fill_color = color.new(lc, tr)))
                    f_line(lv.left, lv.price, lv.right, lv.price, color.new(lc, lv.active ? 10 : 60), 1, line.style_solid)

        // ── 3D profile rows (top row first so lower rows overlap correctly)
        if maxAbs > 0
            for k = 0 to rows - 1
                int   r = rows - 1 - k
                float d = rDel.get(r)
                if rTot.get(r) > 0
                    int   len  = math.max(1, int(math.round(math.abs(d) / maxAbs * profWidth)))
                    int   xL   = d >= 0 ? xAxis : xAxis - len
                    int   xR   = d >= 0 ? xAxis + len : xAxis
                    float yB   = bot + r * rowH + gap
                    float yT   = bot + (r + 1) * rowH - gap
                    bool  inVA = r >= vaDn and r <= vaUp
                    bool  isPoc = showPOC and r == poc
                    color base = isPoc ? pocCol : d >= 0 ? bullCol : bearCol
                    int   tf   = dimOutVA and not inVA and not isPoc ? 55 : 10

                    // front face
                    pBoxes.push(box.new(xL, yT, xR, yB, xloc = xloc.bar_index, border_color = color.new(base, tf), border_width = 1, bgcolor = color.new(base, tf)))

                    // top + side faces (single extrusion polygon) + edge highlight
                    if depthX > 0 or dy > 0
                        array<chart.point> ep = array.from(chart.point.from_index(xL, yT), chart.point.from_index(xR, yT), chart.point.from_index(xR, yB), chart.point.from_index(xR + depthX, yB + dy), chart.point.from_index(xR + depthX, yT + dy), chart.point.from_index(xL + depthX, yT + dy))
                        pPolys.push(polyline.new(ep, closed = true, xloc = xloc.bar_index, line_color = color.new(base, math.min(100, tf + 20)), fill_color = color.new(base, math.min(100, tf + 40))))
                        f_line(xR, yT, xR + depthX, yT + dy, color.new(base, tf), 1, line.style_solid)

                    // optional value label
                    if showRowVals
                        int lx = d >= 0 ? xR + depthX + 1 : xL - 1
                        pLabels.push(label.new(lx, (yB + yT) / 2, f_fmtDelta(d), xloc = xloc.bar_index, style = d >= 0 ? label.style_label_left : label.style_label_right, color = #00000000, textcolor = color.new(base, 0), size = size.tiny))

        // ── Summary label
        if showHeader
            float cov = cArr.size() > 0 ? cArr.sum() / cArr.size() : 0.0
            string txt = "Delta Flow Profile [NeBlok]" + "\nNet Δ " + f_fmtDelta(netDel) + "\nPOC " + str.tostring(pocPrice, format.mintick) + "\nVA " + str.tostring(bot + vaDn * rowH, format.mintick) + " – " + str.tostring(bot + (vaUp + 1) * rowH, format.mintick) + "\nIntrabar coverage " + str.tostring(cov * 100, "#") + "% (" + ltfTF + ")"
            pLabels.push(label.new(xAxis, top + dy + rowH, txt, xloc = xloc.bar_index, style = label.style_label_down, color = #00000000, textcolor = chart.fg_color, size = size.small))

// ═════════════════════════════════════════ OUTPUTS & ALERTS ═════════════════════════════════════════
plot(barDelta, "Bar Delta", color = barDelta >= 0 ? bullCol : bearCol, display = display.data_window)
plot(z, "Delta Z-Score", display = display.data_window)

if bullSpike
    alert(syminfo.ticker + " | Bullish delta spike | Δ " + f_fmtDelta(barDelta) + " | Level " + str.tostring(anchor, format.mintick), alert.freq_once_per_bar_close)
if bearSpike
    alert(syminfo.ticker + " | Bearish delta spike | Δ " + f_fmtDelta(barDelta) + " | Level " + str.tostring(anchor, format.mintick), alert.freq_once_per_bar_close)
if bullLevelHit
    alert(syminfo.ticker + " | Price returned to a bullish imbalance level @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if bearLevelHit
    alert(syminfo.ticker + " | Price returned to a bearish imbalance level @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
````
