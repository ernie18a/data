# FVG Magnet Engine 3D [Neblok]

- url: https://www.tradingview.com/script/ReNFH0Hb-FVG-Magnet-Engine-3D-Neblok/
- type: indicator
- pine_id: PUB;6598e19b619347f38c4724846168a2c8
- version: 1.0

## Description

FVG MAGNET ENGINE 3D [Neblok]

Most fair value gap indicators assume every gap is a magnet that price will return to. This one tests that assumption. FVG Magnet Engine 3D measures how often gaps on the chart you are viewing actually get filled, and prints the odds directly on every live gap. You can see at a glance which imbalances are likely to attract price and which ones the market tends to leave behind.

━━━━━━━━━━━━━━━━━━━━
WHAT IS A FAIR VALUE GAP?
━━━━━━━━━━━━━━━━━━━━

A fair value gap (FVG) is a three-candle imbalance. It forms when price moves so fast that the first and third candles do not overlap, leaving a price range that was traded on only one side.

- Bullish FVG: the low of the current candle is above the high of the candle two bars back. The gap sits below price.
- Bearish FVG: the high of the current candle is below the low of the candle two bars back. The gap sits above price.

Traders watch these zones because price often returns to "rebalance" them. The key word is often, not always. This script tells you how often.

━━━━━━━━━━━━━━━━━━━━
HOW THE ODDS ARE CALCULATED
━━━━━━━━━━━━━━━━━━━━

1. Every new gap is sorted into a bucket by direction (bull or bear) and by size measured in ATRs: under 0.5, 0.5 to 1, 1 to 2, and 2+ ATR. That gives 8 buckets in total.
2. Each gap is tracked until it either fills or runs out of time (the Fill Window). The result is recorded for its bucket: "filled after X bars" or "did not fill."
3. Each live gap shows the share of past gaps in its bucket that went on to fill.

The odds also account for age. A gap that has already gone 40 bars unfilled is compared only against past gaps that also lasted at least 40 bars unfilled. Gaps that hold for a long time tend to fill less often, and the odds on each label reflect that as the gap ages.

Two safeguards keep the numbers honest:
- A small statistical correction stops tiny samples from showing extreme values like 100% or 0%.
- No odds are shown until a bucket has enough history (Min Samples). Until then the label reads LEARNING.

━━━━━━━━━━━━━━━━━━━━
HOW TO READ THE CHART
━━━━━━━━━━━━━━━━━━━━

NEON 3D BLOCKS
- Green block = bullish gap below price.
- Pink block = bearish gap above price.
- The solid block is the part of the gap that has not been filled yet. It shrinks as price trades into it.
- The 3D top and side faces are only there to make the zones easier to see. They do not represent extra price levels.

DOTTED OUTLINE
- The original size of the gap before any fill. Compare it with the solid block to see how much has already been absorbed.

DASHED LINE
- The 50% level of the gap, also called consequent encroachment (CE). Price often reacts here.

YELLOW OUTLINE + ★ HIGH ODDS
- The gap's fill odds are at or above your High-Odds Threshold (70% by default). These are the strongest magnets on the chart.

GAP LABEL (3 lines)
- Line 1: direction, plus ★ HIGH ODDS if it qualifies.
- Line 2: fill odds and sample size, e.g. "FILL ODDS 72% (n=48)". The sample size matters: 72% from 48 gaps is far more reliable than 72% from 16.
- Line 3: gap size in ATRs, % already filled, and age vs. the Fill Window, e.g. "1.25× ATR · 35% filled · 27/150 bars".

MAGNET ARROWS (cyan)
- One arrow points from current price to the nearest gap above, and one to the nearest gap below.
- The thicker the arrow, the higher that gap's fill odds. A thin dashed arrow means the gap is still in LEARNING mode.
- Each arrow's label shows the odds plus the distance in points and in ATRs, so you can judge whether the target is realistic for your trade.

DIAMONDS
- A green diamond below a bar marks where a bullish gap was filled. A pink diamond above a bar marks where a bearish gap was filled. These show the history of fills on your chart.

ODDS DASHBOARD
- Shows fill odds and sample size for all 8 buckets, plus the average number of bars a gap takes to fill.
- Cells turn yellow when a bucket's base odds pass your High-Odds Threshold.
- Use it to learn how the instrument behaves. Some markets fill small gaps almost every time but rarely fill large ones; others are the opposite.

━━━━━━━━━━━━━━━━━━━━
SETTINGS GUIDE
━━━━━━━━━━━━━━━━━━━━

DETECTION
- Min Gap Size (× ATR): ignores gaps smaller than this. Raise it to remove noise on low timeframes.
- Min Displacement Body (× ATR): requires the middle candle to have a strong body, so only gaps created by forceful moves count. 0 = off.
- ATR Length: the ATR used for size buckets, the 3D depth, and distances.
- Confirm Gaps On Bar Close: on by default. New gaps only appear once the bar closes, so they never flicker on the live bar.

FILL STATISTICS
- Fill Definition: "Full Fill" requires price to trade completely through the gap. "50% (CE)" counts a fill when price reaches the midpoint. CE odds are always higher; choose the one that matches how you trade.
- Fill Window (bars): how long a gap has to fill before it counts as a miss and is removed. A longer window gives higher odds.
- Stats Memory: how many recent outcomes per bucket are used. Lower values adapt faster to changing conditions; higher values are steadier.
- Min Samples Before Showing Odds: odds stay hidden until a bucket has at least this many results.
- High-Odds Threshold (%): the level that triggers the yellow outline, the ★, and the high-odds tap alert.

DISPLAY
- Show Bullish / Bearish Gaps: toggle each side.
- Max Gaps On Chart: limits clutter (up to 20).
- Which Gaps To Show: "Nearest to price" (best for active trading) or "Most recent."
- Extend Right: how far the blocks project into the future.
- Outline, CE line, Magnet lines, Fill markers: turn each layer on or off.
- Label Size: Normal, Large, or Huge.

3D RENDERING
- 3D Blocks: turn the 3D effect on or off.
- 3D Depth / 3D Lift: control how far the 3D faces project. Reduce these if blocks overlap on a crowded chart.

NEON COLORS
- Every color is adjustable. Colors are flat neon with no gradients, so they stay readable on dark charts.

━━━━━━━━━━━━━━━━━━━━
SUGGESTED STARTING SETTINGS
━━━━━━━━━━━━━━━━━━━━

- Scalping futures (1m to 5m): Fill Definition 50% (CE), Fill Window 60 to 100, Min Gap Size 0.3 to 0.5.
- Intraday (15m to 1H): Fill Definition Full Fill or CE, Fill Window 100 to 150, Min Gap Size 0.25.
- Swing (4H to Daily): Fill Definition Full Fill, Fill Window 100 to 200, Stats Memory 150 to 300.

Load as much chart history as possible. More history means larger samples and more reliable odds.

━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT IN YOUR TRADING
━━━━━━━━━━━━━━━━━━━━

1. TARGETS
A high-odds gap in the direction of your trade is a reasonable profit target. The magnet arrow shows the distance in points and ATRs, so you can see whether the target fits your risk-to-reward.

2. CAUTION ZONES
A high-odds gap against your position marks where a pullback is statistically more likely. Consider tightening stops or taking partial profits before price reaches it.

3. FILTERING
Low-odds gaps on your market and timeframe do not deserve the same respect as high-odds ones. Use the odds to decide which zones to plan around and which to ignore.

4. ENTRIES ON THE FIRST TAP
When price first touches a high-odds gap, the "first tap" alert fires. Many traders watch the gap edge or the CE line for a reaction, then look for confirmation from their own system (structure break, momentum, volume) before entering.

5. CONFLUENCE
Odds work best combined with other context: higher-timeframe trend, key liquidity levels, session opens, or volume profile levels. A high-odds gap that lines up with another level is a stronger zone.

6. KNOW YOUR MARKET
Check the dashboard on each instrument and timeframe you trade. The average bars-to-fill tells you how patient to be, and the odds tell you whether gaps on that market are worth trading at all.

━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━

Create an alert on the indicator and select "Any alert() function call." Turn each alert type on or off in the settings:
- New FVG: includes the gap's price range, size, and starting fill odds.
- First Tap Of A High-Odds FVG: fires when price first enters a gap whose odds are above your threshold.
- FVG Filled: fires when a gap fills, with how many bars it took.

All alerts fire once per bar close.

━━━━━━━━━━━━━━━━━━━━
NOTES & LIMITATIONS
━━━━━━━━━━━━━━━━━━━━

- Fill odds are historical frequencies from the loaded chart data, not predictions. Market conditions change, and past behavior may not repeat.
- Odds depend on your settings. Changing the Fill Definition, Fill Window, or size filters changes what counts as a fill, so the numbers will change.
- Statistics are built from the bars loaded on your chart. Different history lengths (or different TradingView plans) can produce slightly different odds.
- Fill tracking updates live on the current bar. New gaps only print on bar close when Confirm Gaps On Bar Close is enabled.
- This is a free script. Feedback and suggestions are welcome in the comments.

━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━

This indicator is provided for educational and informational purposes only. It is NOT financial advice, investment advice, trading advice, or a recommendation to buy, sell, or hold any security, futures contract, option, cryptocurrency, or other financial instrument.

All fill odds, statistics, and signals are based on historical data and do not guarantee future results. Past performance is not indicative of future performance.

Trading involves substantial risk of loss and is not suitable for every investor. Leveraged products such as futures and options can result in losses greater than your initial investment. Only trade with money you can afford to lose.

You are solely responsible for your own trading decisions. Always do your own research, test any tool thoroughly on a demo or paper account before using it with real money, and consult a licensed financial professional if you need personalized advice. The author accepts no liability for any losses or damages arising from the use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

//@version=6
indicator("FVG Magnet Engine 3D [Neblok]", shorttitle = "FVG Magnet 3D [Neblok]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_polylines_count = 100)

// =====================================================================
//  FVG Magnet Engine 3D [Neblok]
//  Fair value gaps scored by their OWN measured fill rate on this chart.
//
//  Every gap is sorted into a bucket (direction x size in ATRs). When a
//  gap fills or expires, the outcome is recorded for its bucket. The odds
//  shown on each live gap are CONDITIONAL on its age:
//    "Of past gaps in this bucket that were still unfilled at this age,
//     what share went on to fill before the fill window expired?"
//  Odds use a Laplace (+1/+2) correction so small samples are not
//  overstated, and are hidden until a minimum sample size is reached.
// =====================================================================

// ── Input groups ──────────────────────────────────────────────────────
string G_DET  = "Detection"
string G_STAT = "Fill Statistics"
string G_DISP = "Display"
string G_3D   = "3D Rendering"
string G_COL  = "Neon Colors"
string G_TBL  = "Odds Dashboard"
string G_ALR  = "Alerts"

// ── Detection ─────────────────────────────────────────────────────────
minSizeAtr   = input.float(0.25, "Min Gap Size (× ATR)", minval = 0.0, step = 0.05, group = G_DET, tooltip = "Gaps smaller than this many ATRs are ignored.")
dispAtr      = input.float(0.0, "Min Displacement Body (× ATR)", minval = 0.0, step = 0.1, group = G_DET, tooltip = "Middle candle's body must be at least this many ATRs. 0 = off.")
atrLen       = input.int(14, "ATR Length", minval = 1, group = G_DET)
confirmClose = input.bool(true, "Confirm Gaps On Bar Close", group = G_DET, tooltip = "Prevents gaps from appearing and disappearing on the live bar.")

// ── Statistics ────────────────────────────────────────────────────────
fillMode   = input.string("Full Fill", "Fill Definition", options = ["Full Fill", "50% (CE)"], group = G_STAT, tooltip = "Full Fill = price trades through the far edge. 50% (CE) = price reaches the gap midpoint (consequent encroachment).")
horizon    = input.int(150, "Fill Window (bars)", minval = 5, maxval = 2000, group = G_STAT, tooltip = "A gap must fill within this many bars to count as a fill. Unfilled gaps are retired at the end of the window.")
memLen     = input.int(300, "Stats Memory (gaps per bucket)", minval = 20, maxval = 5000, group = G_STAT, tooltip = "Only the most recent N outcomes per bucket are used, so odds adapt to current conditions.")
minSamples = input.int(15, "Min Samples Before Showing Odds", minval = 1, group = G_STAT)
hiThrPct   = input.float(70.0, "High-Odds Threshold (%)", minval = 1.0, maxval = 99.0, group = G_STAT)
hiThr      = hiThrPct / 100.0

// ── Display ───────────────────────────────────────────────────────────
showBull      = input.bool(true, "Show Bullish Gaps", group = G_DISP)
showBear      = input.bool(true, "Show Bearish Gaps", group = G_DISP)
maxShow       = input.int(10, "Max Gaps On Chart", minval = 1, maxval = 20, group = G_DISP)
sortMode      = input.string("Nearest to price", "Which Gaps To Show", options = ["Nearest to price", "Most recent"], group = G_DISP)
extendBars    = input.int(20, "Extend Right (bars)", minval = 5, maxval = 300, group = G_DISP)
showGhost     = input.bool(true, "Show Original Gap Outline", group = G_DISP)
showCE        = input.bool(true, "Show 50% (CE) Line", group = G_DISP)
showMagnet    = input.bool(true, "Show Magnet Pull Lines", group = G_DISP)
showFillMarks = input.bool(true, "Mark Bars Where Gaps Filled", group = G_DISP)
labelSizeIn   = input.string("Large", "Label Size", options = ["Normal", "Large", "Huge"], group = G_DISP)

// ── 3D ────────────────────────────────────────────────────────────────
show3D    = input.bool(true, "3D Blocks", group = G_3D)
depthBars = input.int(4, "3D Depth (bars)", minval = 1, maxval = 30, group = G_3D)
depthAtr  = input.float(0.35, "3D Lift (× ATR)", minval = 0.0, step = 0.05, group = G_3D)

// ── Colors (flat neon, no gradients) ──────────────────────────────────
bullCol  = input.color(#39FF14, "Bullish Neon", group = G_COL)
bearCol  = input.color(#FF1E8C, "Bearish Neon", group = G_COL)
hiCol    = input.color(#FFF01F, "High-Odds Outline", group = G_COL)
magCol   = input.color(#00F0FF, "Magnet Line", group = G_COL)
panelCol = input.color(#05060D, "Label / Panel Background", group = G_COL)

// ── Dashboard ─────────────────────────────────────────────────────────
showTable   = input.bool(true, "Show Odds Dashboard", group = G_TBL)
tablePosIn  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = G_TBL)
tableSizeIn = input.string("Large", "Text Size", options = ["Normal", "Large", "Huge"], group = G_TBL)

// ── Alerts ────────────────────────────────────────────────────────────
alertNew  = input.bool(true, "Alert: New FVG", group = G_ALR)
alertTap  = input.bool(true, "Alert: First Tap Of A High-Odds FVG", group = G_ALR)
alertFill = input.bool(true, "Alert: FVG Filled", group = G_ALR)

// =====================================================================
//  Types & state
// =====================================================================
type FVG
    float top
    float bot
    float oTop
    float oBot
    int   xL
    int   born
    bool  bull
    int   bucket
    float sizeAtr
    bool  touched

type Stat
    array<int> outcomes   // fill age in bars, or horizon + 1 for a miss

var array<FVG>  gaps  = array.new<FVG>()
var array<Stat> stats = array.new<Stat>()
if stats.size() == 0
    for k = 0 to 7
        stats.push(Stat.new(array.new<int>()))

var array<box>      drawnBoxes  = array.new<box>()
var array<line>     drawnLines  = array.new<line>()
var array<label>    drawnLabels = array.new<label>()
var array<polyline> drawnPolys  = array.new<polyline>()
var table           tbl         = na

// =====================================================================
//  Helpers
// =====================================================================
f_size(string s) =>
    switch s
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.large

f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

// Size buckets: <0.5, 0.5-1, 1-2, 2+ ATR
f_bucket(float m) =>
    m < 0.5 ? 0 : m < 1.0 ? 1 : m < 2.0 ? 2 : 3

// Stat index: bullish 0-3, bearish 4-7
f_key(bool isBull, int b) =>
    (isBull ? 0 : 4) + b

f_record(int k, int v) =>
    Stat s = stats.get(k)
    s.outcomes.push(v)
    if s.outcomes.size() > memLen
        s.outcomes.shift()
    true

// Conditional fill odds for a gap of bucket k that has survived `age` bars
f_odds(int k, int age) =>
    Stat s = stats.get(k)
    int n = 0
    int h = 0
    for v in s.outcomes
        if v > age
            n += 1
            if v <= horizon
                h += 1
    float p = n > 0 ? (h + 1.0) / (n + 2.0) : na
    [p, n]

f_avgFill(int k) =>
    Stat s = stats.get(k)
    float sum = 0.0
    int c = 0
    for v in s.outcomes
        if v <= horizon
            sum += v
            c += 1
    c > 0 ? sum / c : na

f_oddsTxt(int k, int age) =>
    [p, n] = f_odds(k, age)
    n >= minSamples ? str.tostring(p * 100, "#") + "%" : "learning (n=" + str.tostring(n) + ")"

// =====================================================================
//  Core engine
// =====================================================================
float atr         = ta.atr(atrLen)
bool  bullFillBar = false
bool  bearFillBar = false
string alertMsg   = ""
string tfTxt      = syminfo.ticker + " " + timeframe.period

// ── 1) Update live gaps: shrink, detect taps, record fills / expiries ─
if gaps.size() > 0
    for i = gaps.size() - 1 to 0
        FVG g   = gaps.get(i)
        int age = bar_index - g.born
        if age > 0
            int   k      = f_key(g.bull, g.bucket)
            float mid    = (g.oTop + g.oBot) / 2.0
            bool  filled = false
            bool  tapped = false
            if g.bull
                if low < g.top
                    g.top := math.max(low, g.bot)
                    if not g.touched
                        g.touched := true
                        tapped    := true
                float target = fillMode == "Full Fill" ? g.oBot : mid
                filled := low <= target
            else
                if high > g.bot
                    g.bot := math.min(high, g.top)
                    if not g.touched
                        g.touched := true
                        tapped    := true
                float target = fillMode == "Full Fill" ? g.oTop : mid
                filled := high >= target

            if tapped and not filled and alertTap
                [tp, tn] = f_odds(k, age - 1)
                if tn >= minSamples and tp >= hiThr
                    alertMsg += (g.bull ? "BULL" : "BEAR") + " FVG first tap (high odds " + str.tostring(tp * 100, "#") + "%) " + tfTxt + " | " + str.tostring(g.oBot, format.mintick) + " – " + str.tostring(g.oTop, format.mintick) + "\n"

            if filled
                f_record(k, age)
                if g.bull
                    bullFillBar := true
                else
                    bearFillBar := true
                if alertFill
                    alertMsg += (g.bull ? "BULL" : "BEAR") + " FVG filled after " + str.tostring(age) + " bars " + tfTxt + " | " + str.tostring(g.oBot, format.mintick) + " – " + str.tostring(g.oTop, format.mintick) + "\n"
                gaps.remove(i)
            else if age >= horizon
                f_record(k, horizon + 1)
                gaps.remove(i)

// ── 2) Detect new gaps ────────────────────────────────────────────────
bool canDetect = confirmClose ? barstate.isconfirmed : true
if canDetect and not na(atr) and atr > 0 and bar_index >= 2
    float body1  = math.abs(close[1] - open[1])
    bool  dispOk = body1 >= dispAtr * atr

    if low > high[2] and dispOk
        float sz = low - high[2]
        if sz >= minSizeAtr * atr
            float m = sz / atr
            int   b = f_bucket(m)
            gaps.push(FVG.new(low, high[2], low, high[2], bar_index - 1, bar_index, true, b, m, false))
            if alertNew
                alertMsg += "New BULL FVG " + tfTxt + " | " + str.tostring(high[2], format.mintick) + " – " + str.tostring(low, format.mintick) + " | " + str.tostring(m, "#.##") + "× ATR | fill odds " + f_oddsTxt(f_key(true, b), 0) + "\n"

    if high < low[2] and dispOk
        float sz = low[2] - high
        if sz >= minSizeAtr * atr
            float m = sz / atr
            int   b = f_bucket(m)
            gaps.push(FVG.new(low[2], high, low[2], high, bar_index - 1, bar_index, false, b, m, false))
            if alertNew
                alertMsg += "New BEAR FVG " + tfTxt + " | " + str.tostring(high, format.mintick) + " – " + str.tostring(low[2], format.mintick) + " | " + str.tostring(m, "#.##") + "× ATR | fill odds " + f_oddsTxt(f_key(false, b), 0) + "\n"

if gaps.size() > 600
    gaps.shift()

// =====================================================================
//  Rendering (last bar only — redrawn cleanly each update)
// =====================================================================
if barstate.islast
    while drawnBoxes.size() > 0
        drawnBoxes.pop().delete()
    while drawnLines.size() > 0
        drawnLines.pop().delete()
    while drawnLabels.size() > 0
        drawnLabels.pop().delete()
    while drawnPolys.size() > 0
        drawnPolys.pop().delete()

    float dy     = show3D ? nz(atr) * depthAtr : 0.0
    int   dx     = show3D ? depthBars : 0
    int   xRight = bar_index + extendBars
    lblSize      = f_size(labelSizeIn)

    // Pick which gaps to draw
    array<float> keys = array.new<float>()
    array<int>   idxs = array.new<int>()
    for [i, g] in gaps
        bool want = g.bull ? showBull : showBear
        if want
            float d = close > g.top ? close - g.top : close < g.bot ? g.bot - close : 0.0
            keys.push(sortMode == "Nearest to price" ? d : float(-g.born))
            idxs.push(i)
    array<int> sorted = keys.sort_indices(order.ascending)
    int cnt = math.min(maxShow, sorted.size())

    // Nearest magnet targets above / below price
    float upD     = na
    float upEdge  = na
    float upP     = na
    bool  upValid = false
    float dnD     = na
    float dnEdge  = na
    float dnP     = na
    bool  dnValid = false

    if cnt > 0
        for j = 0 to cnt - 1
            FVG   g      = gaps.get(idxs.get(sorted.get(j)))
            int   k      = f_key(g.bull, g.bucket)
            int   age    = bar_index - g.born
            [p, n]       = f_odds(k, age)
            bool  valid  = n >= minSamples and not na(p)
            bool  hi     = valid and p >= hiThr
            color neon   = g.bull ? bullCol : bearCol
            color edge   = hi ? hiCol : neon
            float mid0   = (g.oTop + g.oBot) / 2.0
            float range0 = g.oTop - g.oBot
            float fillPct = range0 > 0 ? 1.0 - (g.top - g.bot) / range0 : 0.0

            // Original gap outline
            if showGhost
                drawnBoxes.push(box.new(left = g.xL, top = g.oTop, right = xRight, bottom = g.oBot, border_color = color.new(neon, 35), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(neon, 94)))

            // 3D faces (top = lit face, side = shadow face)
            if show3D
                array<chart.point> topPts = array.new<chart.point>()
                topPts.push(chart.point.from_index(g.xL, g.top))
                topPts.push(chart.point.from_index(xRight, g.top))
                topPts.push(chart.point.from_index(xRight + dx, g.top + dy))
                topPts.push(chart.point.from_index(g.xL + dx, g.top + dy))
                drawnPolys.push(polyline.new(points = topPts, curved = false, closed = true, xloc = xloc.bar_index, line_color = edge, fill_color = color.new(neon, 55), line_width = 1))

                array<chart.point> sidePts = array.new<chart.point>()
                sidePts.push(chart.point.from_index(xRight, g.top))
                sidePts.push(chart.point.from_index(xRight + dx, g.top + dy))
                sidePts.push(chart.point.from_index(xRight + dx, g.bot + dy))
                sidePts.push(chart.point.from_index(xRight, g.bot))
                drawnPolys.push(polyline.new(points = sidePts, curved = false, closed = true, xloc = xloc.bar_index, line_color = edge, fill_color = color.new(neon, 80), line_width = 1))

            // Front face = remaining unfilled part of the gap
            drawnBoxes.push(box.new(left = g.xL, top = g.top, right = xRight, bottom = g.bot, border_color = edge, border_width = hi ? 2 : 1, bgcolor = color.new(neon, 68)))

            if showCE
                drawnLines.push(line.new(x1 = g.xL, y1 = mid0, x2 = xRight, y2 = mid0, color = color.new(neon, 15), style = line.style_dashed, width = 1))

            // Info label
            string dirTxt  = g.bull ? "▲ BULL FVG" : "▼ BEAR FVG"
            string starTxt = hi ? "  ★ HIGH ODDS" : ""
            string oddsTxt = valid ? "FILL ODDS " + str.tostring(p * 100, "#") + "%  (n=" + str.tostring(n) + ")" : "LEARNING  (n=" + str.tostring(n) + "/" + str.tostring(minSamples) + ")"
            string infoTxt = str.tostring(g.sizeAtr, "#.##") + "× ATR · " + str.tostring(fillPct * 100, "#") + "% filled · " + str.tostring(age) + "/" + str.tostring(horizon) + " bars"
            drawnLabels.push(label.new(x = xRight + dx + 2, y = (g.top + g.bot) / 2.0 + dy / 2.0, text = dirTxt + starTxt + "\n" + oddsTxt + "\n" + infoTxt, xloc = xloc.bar_index, color = color.new(panelCol, 10), style = label.style_label_left, textcolor = edge, size = lblSize, textalign = text.align_left, text_font_family = font.family_monospace))

            // Track nearest gap above and below price for magnet lines
            if g.bot > close and (na(upD) or g.bot - close < upD)
                upD     := g.bot - close
                upEdge  := g.bot
                upP     := p
                upValid := valid
            if g.top < close and (na(dnD) or close - g.top < dnD)
                dnD     := close - g.top
                dnEdge  := g.top
                dnP     := p
                dnValid := valid

    // Magnet pull lines: thicker = higher fill odds
    if showMagnet
        int xMag = bar_index + math.round(extendBars * 0.5)
        if not na(upD)
            int w = upValid ? 1 + math.round(upP * 5) : 1
            drawnLines.push(line.new(x1 = bar_index, y1 = close, x2 = xMag, y2 = upEdge, color = magCol, style = upValid ? line.style_arrow_right : line.style_dashed, width = w))
            string t = "MAGNET ▲ " + (upValid ? str.tostring(upP * 100, "#") + "%" : "learning") + "\n+" + str.tostring(upD, format.mintick) + " pts · " + str.tostring(upD / nz(atr, 1), "#.##") + " ATR"
            drawnLabels.push(label.new(x = bar_index + 1, y = (close + upEdge) / 2.0, text = t, xloc = xloc.bar_index, color = color.new(panelCol, 10), style = label.style_label_left, textcolor = magCol, size = lblSize, textalign = text.align_left, text_font_family = font.family_monospace))
        if not na(dnD)
            int w = dnValid ? 1 + math.round(dnP * 5) : 1
            drawnLines.push(line.new(x1 = bar_index, y1 = close, x2 = xMag, y2 = dnEdge, color = magCol, style = dnValid ? line.style_arrow_right : line.style_dashed, width = w))
            string t = "MAGNET ▼ " + (dnValid ? str.tostring(dnP * 100, "#") + "%" : "learning") + "\n-" + str.tostring(dnD, format.mintick) + " pts · " + str.tostring(dnD / nz(atr, 1), "#.##") + " ATR"
            drawnLabels.push(label.new(x = bar_index + 1, y = (close + dnEdge) / 2.0, text = t, xloc = xloc.bar_index, color = color.new(panelCol, 10), style = label.style_label_left, textcolor = magCol, size = lblSize, textalign = text.align_left, text_font_family = font.family_monospace))

    // ── Odds dashboard ────────────────────────────────────────────────
    if showTable
        tSize = f_size(tableSizeIn)
        if na(tbl)
            tbl := table.new(f_pos(tablePosIn), 5, 6, bgcolor = panelCol, frame_color = magCol, frame_width = 2, border_color = color.new(magCol, 70), border_width = 1)
            table.merge_cells(tbl, 0, 0, 4, 0)
        table.cell(tbl, 0, 0, "FVG MAGNET ENGINE 3D  ·  FILL ODDS ≤ " + str.tostring(horizon) + " BARS  ·  " + fillMode, text_color = magCol, text_size = tSize, bgcolor = panelCol)
        table.cell(tbl, 0, 1, "SIZE (ATR)", text_color = color.white, text_size = tSize, bgcolor = panelCol)
        table.cell(tbl, 1, 1, "< 0.5", text_color = color.white, text_size = tSize, bgcolor = panelCol)
        table.cell(tbl, 2, 1, "0.5 – 1", text_color = color.white, text_size = tSize, bgcolor = panelCol)
        table.cell(tbl, 3, 1, "1 – 2", text_color = color.white, text_size = tSize, bgcolor = panelCol)
        table.cell(tbl, 4, 1, "2 +", text_color = color.white, text_size = tSize, bgcolor = panelCol)
        for d = 0 to 1
            bool  isBull = d == 0
            color dCol   = isBull ? bullCol : bearCol
            int   rOdds  = 2 + d * 2
            int   rAvg   = 3 + d * 2
            table.cell(tbl, 0, rOdds, isBull ? "▲ BULL odds" : "▼ BEAR odds", text_color = dCol, text_size = tSize, bgcolor = panelCol)
            table.cell(tbl, 0, rAvg, "   avg bars", text_color = dCol, text_size = tSize, bgcolor = panelCol)
            for b = 0 to 3
                int k = f_key(isBull, b)
                [p, n] = f_odds(k, 0)
                bool  ok    = n >= minSamples and not na(p)
                color cCol  = ok and p >= hiThr ? hiCol : dCol
                string oTxt = ok ? str.tostring(p * 100, "#") + "% · n" + str.tostring(n) : "— · n" + str.tostring(n)
                float avg   = f_avgFill(k)
                string aTxt = na(avg) ? "—" : str.tostring(avg, "#.#")
                table.cell(tbl, b + 1, rOdds, oTxt, text_color = cCol, text_size = tSize, bgcolor = panelCol)
                table.cell(tbl, b + 1, rAvg, aTxt, text_color = dCol, text_size = tSize, bgcolor = panelCol)

// =====================================================================
//  Fill markers & alerts
// =====================================================================
plotshape(showFillMarks and bullFillBar, title = "Bull FVG Filled", style = shape.diamond, location = location.belowbar, color = bullCol, size = size.small)
plotshape(showFillMarks and bearFillBar, title = "Bear FVG Filled", style = shape.diamond, location = location.abovebar, color = bearCol, size = size.small)

if alertMsg != ""
    alert(alertMsg, alert.freq_once_per_bar_close)
````
