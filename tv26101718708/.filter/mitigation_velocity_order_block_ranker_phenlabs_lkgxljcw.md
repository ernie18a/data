# Mitigation Velocity Order Block Ranker [PhenLabs]

- url: https://www.tradingview.com/script/LKGXljcw-Mitigation-Velocity-Order-Block-Ranker-PhenLabs/
- type: indicator
- pine_id: PUB;c5697d62ca504bd9a210fe65ed939e82
- version: 1.0

## Description

[b]📊 Mitigation Velocity Order Block Ranker [PhenLabs][/b]

Version: PineScript™ v6

https://www.tradingview.com/x/LjKMgF1v/

[b]📌 Description[/b]

Most order block tools dump every candle that qualifies onto your chart and leave you to guess which ones actually matter. That works fine in clean trends and falls apart in ranges, where five or ten blocks are active at once and only one or two will ever produce a meaningful reaction. The Mitigation Velocity Order Block Ranker replaces that guesswork with an objective score.

Every active block is graded in real time on three independent dimensions: how quickly it gets tested after creation, how aggressive the volume was when it formed, and whether it sits in the right half of the higher-timeframe range. The result is a single composite score per block and a top-N ranking that updates with every bar — so the strongest zones stand out visually and the marginal ones fade into the background.

This is built for traders who already understand order block theory and want a way to filter for quality without flipping between timeframes or eyeballing volume. Use it as a confidence layer, a trigger filter, or a way to prioritize which zones deserve an alert.

[b]🚀 Points of Innovation[/b]

[list]
[*] Composite scoring engine that grades every block on velocity, volume, and HTF context instead of treating all OBs as equal
[*] Time-to-first-touch velocity metric — freshness is measured against a configurable bar horizon, so stale zones decay naturally
[*] Volume depth scoring uses the formation candle’s relative volume against a rolling SMA baseline, not raw volume
[*] HTF premium/discount alignment automatically rewards bullish OBs in discount and bearish OBs in premium
[*] Dynamic top-N ranking table with side, levels, and live score for every tracked block
[*] Rank-driven color fading visually separates the strongest zones from the rest at a glance
[/list]

[b]🔧 Core Components[/b]

[list]
[*] Velocity Score: Measures bars elapsed between OB creation and its first mitigation touch, normalized against a user-defined horizon. Untouched blocks decay as they age, so freshness is rewarded.
[*] Volume Score: Compares the formation candle’s volume to its rolling SMA baseline and maps the ratio to a 0-to-1 range, clamped at 3x baseline so a single spike can’t dominate.
[*] HTF Alignment Score: Pulls the high and low of the selected HTF lookback range and rewards bullish blocks below the midpoint, bearish blocks above it, scaled by how deep into the array the block sits.
[/list]

[b]🔥 Key Features[/b]

[list]
[*] Real-Time Composite Ranking: Every active block gets a fresh score on every bar, with ranks reassigned dynamically as conditions change.
[*] Configurable Metric Weights: Tune velocity, volume, and HTF weights independently to match your trading style or backtest results.
[*] Top-N Ranking Table: See your strongest zones at a glance with side, top, bottom, and live score in a clean on-chart table.
[*] Rank-Faded Zone Colors: The #1 zone shows vivid; lower-ranked zones fade progressively, making chart hierarchy instantly readable.
[*] Top-Block Mitigation Alerts: Get notified the moment a top-ranked OB is tested — no noise from low-quality zone touches.
[*] Wick or Body Mitigation Toggle: Choose whether wicks count as a touch or only the candle body, depending on your style.
[*] Configurable HTF Reference: Set any higher timeframe and lookback range for the premium/discount array.
[/list]

[b]🎨 Visualization[/b]

[list]
[*] Ranking Table: Top-right by default (position is configurable), shows rank number, side, top price, bottom price, and current score for each tracked block.
[*] Zone Boxes: Every active OB is drawn as a colored box from its formation bar forward. The #1 zone is fully vivid; rank 2, 3, 4… fade progressively toward transparency.
[*] Rank Labels: Top-N blocks display a label at the right edge showing “#rank  score” so you can map any box back to its row in the table without counting.
[*] Border Weight: Top-N zones get a heavier border to draw the eye; lower-ranked zones use a lighter border.
[*] Listed images displaying all necessary components
[/list]

[b]📖 Usage Guidelines[/b]

Order Block Detection

[list]
[*] Swing Pivot Length — Default: 5 — Range: 2-50 — Controls how many bars must confirm a swing before an OB is created. Higher values produce fewer, more significant zones; lower values catch more structure but generate more noise.
[*] Max Active Blocks — Default: 20 — Range: 5-50 — Hard cap on tracked unmitigated blocks. Oldest blocks are dropped first when the cap is exceeded.
[*] Use Wick Mitigation — Default: false — A wick touch counts as a mitigation when enabled; only the candle body counts when disabled. Wick mitigation is stricter and produces faster invalidations.
[/list]

Scoring Weights

[list]
[*] Velocity Weight — Default: 0.40 — Range: 0-1 — How much the time-to-first-touch metric contributes to the composite score.
[*] Volume Weight — Default: 0.35 — Range: 0-1 — How much the formation-candle relative volume contributes to the composite score.
[*] HTF Alignment Weight — Default: 0.25 — Range: 0-1 — How much the HTF premium/discount bonus contributes to the composite score.
[*] Velocity Horizon (bars) — Default: 50 — Range: 5-500 — Bar window used to normalize the velocity score. Shorter horizons make the velocity metric stricter; longer horizons are more forgiving.
[*] Volume Lookback — Default: 20 — Range: 5-200 — SMA length used as the relative volume baseline for the volume score.
[/list]

Higher Timeframe Alignment

[list]
[*] HTF Timeframe — Default: D (Daily) — Higher timeframe used to compute the premium/discount array. Common picks: 4H, D, W.
[*] HTF Range Lookback — Default: 20 — Range: 5-200 — Number of HTF bars used to construct the premium/discount range.
[/list]

Ranking Table

[list]
[*] Show Ranking Table — Default: true — Toggles the on-chart table.
[*] Top N Blocks — Default: 5 — Range: 1-15 — Number of top-ranked blocks displayed in the table and emphasized with vivid coloring on the chart.
[*] Table Position — Default: top_right — Choose where the table renders on the chart.
[*] Table Text Size — Default: small — Font size for table cells.
[/list]

Visual Settings

[list]
[*] Bullish Base Color — Default: teal — Base color for bullish zones. Top-ranked zones use this color at full opacity; lower ranks fade toward transparency.
[*] Bearish Base Color — Default: red — Base color for bearish zones, with the same rank-fading behavior.
[*] Show Rank Labels on Zones — Default: true — Toggles the rank/score labels at the right edge of top-N zones.
[*] Extend Zones to Right — Default: true — Extends boxes 10 bars past the current candle for easier visual targeting.
[/list]

[b]✅ Best Use Cases[/b]

[list]
[*] Smart Money and ICT traders looking to filter their order block list down to the highest-conviction zones
[*] Swing and position traders who want HTF premium/discount logic baked into their LTF entry zones
[*] Scalpers needing to prioritize which of several active blocks to actually trade in a range-bound session
[*] Discretionary traders who want a quantitative confidence layer on top of their existing order block process
[*] Markets with reliable volume data — futures, indices, crypto majors, large-cap equities
[/list]

[b]⚠️ Limitations[/b]

[list]
[*] Volume score depends on reliable volume data — spot forex and thinly traded instruments will produce noisy results
[*] The HTF alignment metric assumes the current HTF range is meaningful; in extended trends, premium/discount logic can lag
[*] Scores are relative within the active block set — a “high” score in a quiet market is not directly comparable to a “high” score in a volatile one
[*] Order block detection uses confirmed pivots, which means OBs are drawn with a swing-length bar delay
[*] Like all order block tools, this is a context indicator — it does not generate standalone buy or sell signals
[/list]

[b]💡 What Makes This Unique[/b]

Existing order block indicators either show every block equally or filter on a single dimension like volume. This script is the first to combine velocity, volume, and HTF context into a single composite score and rank every active block against the others in real time. The output is a clean hierarchy of zones you can act on with confidence — strongest first, weakest faded out — instead of a chart cluttered with equally-weighted boxes.

[b]🔬 How It Works[/b]

[b]1. Detect and Track[/b]
The script scans for confirmed swing highs and lows using your pivot length. For each one, it walks back to find the last opposing-color candle, marks that as the order block, and stores its top, bottom, formation volume, and creation bar. Active blocks are tracked in a managed array up to your configured max.

[b]2. Score Every Bar[/b]
On every new bar, each unmitigated block is re-scored on three independent metrics — velocity (how fresh), volume (how aggressive at formation), and HTF alignment (whether it sits in the right half of the higher-timeframe range). The three sub-scores are normalized to 0–1 and combined using your configured weights into a single composite score.

[b]3. Rank, Render, Alert[/b]
All active blocks are sorted by composite score descending. The top-N get vivid coloring, rank labels, and rows in the on-chart table. Lower-ranked blocks fade progressively. When price returns to a top-ranked zone and mitigates it, an alert fires so you never miss a test on a zone you actually care about.

💡 Note:
This indicator is a context and prioritization tool, not a signal generator. Use the scores and rankings to qualify zones you would already be watching, not as standalone entry triggers. Backtest the weight combinations on your instrument and timeframe before committing them to live trading — the right mix of velocity, volume, and HTF weighting depends heavily on the market you trade.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PhenLabs

//@version=6
indicator("Mitigation Velocity Order Block Ranker [PhenLabs]",
     shorttitle = "MVOBR [PhenLabs]",
     overlay = true,
     max_boxes_count = 500,
     max_lines_count = 500,
     max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Detection Settings ────────────────────────────────────────────────────────
grpDetect    = "Order Block Detection"
swingLen     = input.int(5,    "Swing Pivot Length",           minval = 2,  maxval = 50, group = grpDetect, tooltip = "Bars on each side of a pivot used to qualify a swing high/low for OB detection.")
maxActive    = input.int(20,   "Max Active Blocks",            minval = 5,  maxval = 50, group = grpDetect, tooltip = "Maximum number of unmitigated order blocks tracked at one time. Older blocks are dropped first.")
useWick      = input.bool(false,"Use Wick Mitigation",                                   group = grpDetect, tooltip = "If enabled, OBs are mitigated by wick touch. If disabled, only the candle body counts as a touch.")

// ── Scoring Weights ───────────────────────────────────────────────────────────
grpWeights   = "Scoring Weights"
wVelocity    = input.float(0.40, "Velocity Weight",   minval = 0, maxval = 1, step = 0.05, group = grpWeights, tooltip = "Weight applied to the time-to-first-touch velocity metric.")
wVolume      = input.float(0.35, "Volume Weight",     minval = 0, maxval = 1, step = 0.05, group = grpWeights, tooltip = "Weight applied to the formation-candle relative volume metric.")
wHTF         = input.float(0.25, "HTF Alignment Weight", minval = 0, maxval = 1, step = 0.05, group = grpWeights, tooltip = "Weight applied to the HTF premium/discount alignment bonus.")

velocityHorizon = input.int(50, "Velocity Horizon (bars)", minval = 5, maxval = 500, group = grpWeights, tooltip = "Bar window used to normalize the velocity score. Touches within this window receive a non-zero score.")
volumeLookback  = input.int(20, "Volume Lookback",         minval = 5, maxval = 200, group = grpWeights, tooltip = "SMA length for the relative volume baseline used in the volume score.")

// ── HTF Settings ──────────────────────────────────────────────────────────────
grpHTF       = "Higher Timeframe Alignment"
htfTF        = input.timeframe("D",  "HTF Timeframe",                                    group = grpHTF, tooltip = "Higher timeframe used to compute the premium/discount array.")
htfLookback  = input.int(20,         "HTF Range Lookback", minval = 5, maxval = 200,     group = grpHTF, tooltip = "Number of HTF bars used to build the premium/discount range.")

// ── Ranking Table ─────────────────────────────────────────────────────────────
grpTable     = "Ranking Table"
showTable    = input.bool(true,            "Show Ranking Table",                         group = grpTable)
topN         = input.int(5, "Top N Blocks", minval = 1, maxval = 15,                     group = grpTable, tooltip = "Number of top-ranked OBs displayed in the table and emphasized on the chart.")
tblPos       = input.string("top_right",   "Table Position",
     options = ["top_left","top_right","middle_left","middle_right","bottom_left","bottom_right"], group = grpTable)
tblSize      = input.string("small",       "Table Text Size",
     options = ["tiny","small","normal","large"],                                        group = grpTable)

// ── Visual Settings ───────────────────────────────────────────────────────────
grpVisual    = "Visual Settings"
bullColor    = input.color(color.new(#26a69a, 0), "Bullish Base Color", group = grpVisual)
bearColor    = input.color(color.new(#ef5350, 0), "Bearish Base Color", group = grpVisual)
showLabels   = input.bool(true, "Show Rank Labels on Zones", group = grpVisual)
extendRight  = input.bool(true, "Extend Zones to Right",     group = grpVisual)

// ═══════════════════════════════════════════════════════════════════════════════
// HTF DATA
// ═══════════════════════════════════════════════════════════════════════════════

// Pull HTF high/low ranges (lookahead off to avoid repaint of historical signals)
htfHigh = request.security(syminfo.tickerid, htfTF, ta.highest(high, htfLookback), lookahead = barmerge.lookahead_off)
htfLow  = request.security(syminfo.tickerid, htfTF, ta.lowest(low,  htfLookback),  lookahead = barmerge.lookahead_off)
htfMid  = (htfHigh + htfLow) / 2.0

// ═══════════════════════════════════════════════════════════════════════════════
// ORDER BLOCK TYPE
// ═══════════════════════════════════════════════════════════════════════════════

type OrderBlock
    int     id              // unique identifier
    bool    isBull          // true = bullish, false = bearish
    float   top             // upper bound
    float   bot             // lower bound
    int     createdBar      // bar_index at creation
    int     createdTime     // time at creation
    float   formationVol    // volume at formation candle
    float   avgVol          // SMA volume at formation
    bool    mitigated       // mitigation state
    int     firstTouchBar   // bar_index of first touch (na if untouched)
    float   score           // composite score [0-1]
    int     rank            // 1 = highest; 0 = unranked
    box     zone            // chart box reference
    label   tag             // chart label reference

// ═══════════════════════════════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════════════════════════════

var array<OrderBlock> blocks = array.new<OrderBlock>()
var int nextId = 0
var table rankTable = na

// Volume baseline (used for the formation candle's relative volume)
volSMA = ta.sma(volume, volumeLookback)

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

// Compute a single OB composite score from its three metrics.
// All sub-scores are normalized to [0,1] before weighting.
calcScore(OrderBlock ob) =>
    // 1) Velocity: fresher first-touch = higher score.
    //    If still untouched, use current age vs horizon (decays over time).
    int referenceBar = na(ob.firstTouchBar) ? bar_index : ob.firstTouchBar
    int ageBars      = math.max(referenceBar - ob.createdBar, 0)
    float velScore   = math.max(0.0, 1.0 - (ageBars / math.max(velocityHorizon, 1)))

    // 2) Volume: relative volume of the formation candle vs its SMA baseline.
    //    Clamp at 3x baseline to keep the score in [0,1].
    float volRatio   = ob.avgVol > 0 ? ob.formationVol / ob.avgVol : 1.0
    float volScore   = math.min(1.0, math.max(0.0, (volRatio - 1.0) / 2.0))

    // 3) HTF alignment: bullish OBs reward discount (below mid); bearish reward premium.
    //    Distance from mid as a fraction of the HTF half-range = bonus magnitude.
    float halfRange  = math.max((htfHigh - htfLow) / 2.0, syminfo.mintick)
    float obMid      = (ob.top + ob.bot) / 2.0
    float htfBonus   = 0.0
    if ob.isBull and obMid < htfMid
        htfBonus := math.min(1.0, (htfMid - obMid) / halfRange)
    else if (not ob.isBull) and obMid > htfMid
        htfBonus := math.min(1.0, (obMid - htfMid) / halfRange)

    // Weighted composite
    float totalW = math.max(wVelocity + wVolume + wHTF, 0.0001)
    (velScore * wVelocity + volScore * wVolume + htfBonus * wHTF) / totalW

// Test if the current candle has mitigated the OB (price re-enters the zone).
isMitigated(OrderBlock ob) =>
    float testHigh = useWick ? high : math.max(open, close)
    float testLow  = useWick ? low  : math.min(open, close)
    ob.isBull ? (testLow  <= ob.top and testLow  >= ob.bot) or (testHigh >= ob.bot and testLow <= ob.top)
              : (testHigh >= ob.bot and testHigh <= ob.top) or (testHigh >= ob.bot and testLow <= ob.top)

// Faded color helper: rank 1 = vivid, higher ranks = more transparent.
rankColor(color base, int rnk, int total) =>
    int safeTotal = math.max(total, 1)
    int safeRank  = math.max(rnk, 1)
    float t       = (safeRank - 1) / safeTotal
    color.new(base, math.min(85, math.round(20 + t * 60)))

// ═══════════════════════════════════════════════════════════════════════════════
// ORDER BLOCK DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

// Pivots (confirmed swingLen bars back)
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

// Bearish OB: last up-candle before a confirmed swing high
if not na(ph)
    int pivotBar = bar_index - swingLen
    // Walk back from the pivot to find the most recent up-close candle (the OB candle).
    int searchBar = pivotBar
    bool found = false
    for i = 0 to 10
        int testBar = pivotBar - i
        if testBar >= 0 and close[bar_index - testBar] > open[bar_index - testBar]
            searchBar := testBar
            found     := true
            break
    if found
        int back   = bar_index - searchBar
        float obTop = high[back]
        float obBot = math.min(open[back], close[back])
        OrderBlock nb = OrderBlock.new(
             id           = nextId,
             isBull       = false,
             top          = obTop,
             bot          = obBot,
             createdBar   = searchBar,
             createdTime  = time[back],
             formationVol = volume[back],
             avgVol       = nz(volSMA[back], volume[back]),
             mitigated    = false,
             firstTouchBar = na,
             score        = 0.0,
             rank         = 0,
             zone         = na,
             tag          = na)
        array.push(blocks, nb)
        nextId += 1

// Bullish OB: last down-candle before a confirmed swing low
if not na(pl)
    int pivotBar = bar_index - swingLen
    int searchBar = pivotBar
    bool found = false
    for i = 0 to 10
        int testBar = pivotBar - i
        if testBar >= 0 and close[bar_index - testBar] < open[bar_index - testBar]
            searchBar := testBar
            found     := true
            break
    if found
        int back   = bar_index - searchBar
        float obTop = math.max(open[back], close[back])
        float obBot = low[back]
        OrderBlock nb = OrderBlock.new(
             id           = nextId,
             isBull       = true,
             top          = obTop,
             bot          = obBot,
             createdBar   = searchBar,
             createdTime  = time[back],
             formationVol = volume[back],
             avgVol       = nz(volSMA[back], volume[back]),
             mitigated    = false,
             firstTouchBar = na,
             score        = 0.0,
             rank         = 0,
             zone         = na,
             tag          = na)
        array.push(blocks, nb)
        nextId += 1

// Cap active blocks: drop oldest when over the limit
while array.size(blocks) > maxActive
    OrderBlock removed = array.shift(blocks)
    if not na(removed.zone)
        box.delete(removed.zone)
    if not na(removed.tag)
        label.delete(removed.tag)

// ═══════════════════════════════════════════════════════════════════════════════
// MITIGATION + SCORING (every bar)
// ═══════════════════════════════════════════════════════════════════════════════

// Track which top-ranked IDs were mitigated this bar (for alerts).
var int mitigatedTopId = na
mitigatedTopId := na

if array.size(blocks) > 0
    // Mitigation pass
    for i = 0 to array.size(blocks) - 1
        OrderBlock ob = array.get(blocks, i)
        if not ob.mitigated
            if na(ob.firstTouchBar) and isMitigated(ob)
                ob.firstTouchBar := bar_index
                ob.mitigated     := true
                if ob.rank > 0 and ob.rank <= topN
                    mitigatedTopId := ob.id

    // Score all non-mitigated blocks
    for i = 0 to array.size(blocks) - 1
        OrderBlock ob = array.get(blocks, i)
        if not ob.mitigated
            ob.score := calcScore(ob)
        else
            ob.score := 0.0

    // Rank: bubble sort by score (descending) on a copy of indices.
    // Practical for the small array sizes (capped at maxActive ≤ 50).
    array<int> activeIdx = array.new<int>()
    for i = 0 to array.size(blocks) - 1
        OrderBlock ob = array.get(blocks, i)
        if not ob.mitigated
            array.push(activeIdx, i)

    int n = array.size(activeIdx)
    if n > 1
        for i = 0 to n - 2
            for j = 0 to n - 2 - i
                int idxA = array.get(activeIdx, j)
                int idxB = array.get(activeIdx, j + 1)
                OrderBlock obA = array.get(blocks, idxA)
                OrderBlock obB = array.get(blocks, idxB)
                if obB.score > obA.score
                    array.set(activeIdx, j,     idxB)
                    array.set(activeIdx, j + 1, idxA)

    // Assign ranks
    if array.size(activeIdx) > 0
        for r = 0 to array.size(activeIdx) - 1
            int idx = array.get(activeIdx, r)
            OrderBlock ob = array.get(blocks, idx)
            ob.rank := r + 1

// ═══════════════════════════════════════════════════════════════════════════════
// RENDERING (last bar only)
// ═══════════════════════════════════════════════════════════════════════════════

if barstate.islast and array.size(blocks) > 0
    for i = 0 to array.size(blocks) - 1
        OrderBlock ob = array.get(blocks, i)

        // Clean up old visuals first
        if not na(ob.zone)
            box.delete(ob.zone)
            ob.zone := na
        if not na(ob.tag)
            label.delete(ob.tag)
            ob.tag := na

        if not ob.mitigated
            color baseCol = ob.isBull ? bullColor : bearColor
            color zoneCol = rankColor(baseCol, ob.rank, math.max(topN, 1))
            int   rightX  = extendRight ? bar_index + 10 : bar_index
            ob.zone := box.new(
                 left        = ob.createdBar,
                 top         = ob.top,
                 right       = rightX,
                 bottom      = ob.bot,
                 bgcolor     = zoneCol,
                 border_color = color.new(baseCol, 30),
                 border_width = ob.rank <= topN ? 2 : 1)

            if showLabels and ob.rank <= topN
                string lbl = "#" + str.tostring(ob.rank) + "  " + str.tostring(ob.score, "0.00")
                ob.tag := label.new(
                     x         = rightX,
                     y         = (ob.top + ob.bot) / 2.0,
                     text      = lbl,
                     style     = ob.isBull ? label.style_label_left : label.style_label_left,
                     color     = color.new(baseCol, 20),
                     textcolor = color.white,
                     size      = size.small)

// ═══════════════════════════════════════════════════════════════════════════════
// RANKING TABLE
// ═══════════════════════════════════════════════════════════════════════════════

if barstate.islast and showTable
    if not na(rankTable)
        table.delete(rankTable)

    posEnum = tblPos == "top_left"     ? position.top_left     :
              tblPos == "top_right"    ? position.top_right    :
              tblPos == "middle_left"  ? position.middle_left  :
              tblPos == "middle_right" ? position.middle_right :
              tblPos == "bottom_left"  ? position.bottom_left  :
                                         position.bottom_right

    sizeEnum = tblSize == "tiny"   ? size.tiny   :
                 tblSize == "small"  ? size.small  :
                 tblSize == "normal" ? size.normal :
                                     size.large

    rankTable := table.new(posEnum, 5, topN + 1, bgcolor = color.new(color.black, 80), border_width = 1, border_color = color.new(color.gray, 50))

    table.cell(rankTable, 0, 0, "Rank",  text_color = color.white, text_size = sizeEnum, bgcolor = color.new(color.gray, 50))
    table.cell(rankTable, 1, 0, "Side",  text_color = color.white, text_size = sizeEnum, bgcolor = color.new(color.gray, 50))
    table.cell(rankTable, 2, 0, "Top",   text_color = color.white, text_size = sizeEnum, bgcolor = color.new(color.gray, 50))
    table.cell(rankTable, 3, 0, "Bot",   text_color = color.white, text_size = sizeEnum, bgcolor = color.new(color.gray, 50))
    table.cell(rankTable, 4, 0, "Score", text_color = color.white, text_size = sizeEnum, bgcolor = color.new(color.gray, 50))

    // Fill rows for top N
    int rowsFilled = 0
    if array.size(blocks) > 0
        for r = 1 to topN
            bool placed = false
            for i = 0 to array.size(blocks) - 1
                OrderBlock ob = array.get(blocks, i)
                if not ob.mitigated and ob.rank == r
                    color rowCol  = ob.isBull ? color.new(bullColor, 70) : color.new(bearColor, 70)
                    string sideTxt = ob.isBull ? "BULL" : "BEAR"
                    table.cell(rankTable, 0, r, "#" + str.tostring(r),                       text_color = color.white, text_size = sizeEnum, bgcolor = rowCol)
                    table.cell(rankTable, 1, r, sideTxt,                                      text_color = color.white, text_size = sizeEnum, bgcolor = rowCol)
                    table.cell(rankTable, 2, r, str.tostring(ob.top, format.mintick),         text_color = color.white, text_size = sizeEnum, bgcolor = rowCol)
                    table.cell(rankTable, 3, r, str.tostring(ob.bot, format.mintick),         text_color = color.white, text_size = sizeEnum, bgcolor = rowCol)
                    table.cell(rankTable, 4, r, str.tostring(ob.score, "0.000"),              text_color = color.white, text_size = sizeEnum, bgcolor = rowCol)
                    placed   := true
                    rowsFilled += 1
                    break
            if not placed
                table.cell(rankTable, 0, r, "—", text_color = color.gray, text_size = sizeEnum)
                table.cell(rankTable, 1, r, "",  text_color = color.gray, text_size = sizeEnum)
                table.cell(rankTable, 2, r, "",  text_color = color.gray, text_size = sizeEnum)
                table.cell(rankTable, 3, r, "",  text_color = color.gray, text_size = sizeEnum)
                table.cell(rankTable, 4, r, "",  text_color = color.gray, text_size = sizeEnum)

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(not na(mitigatedTopId),
     title   = "Top-Ranked OB Mitigated",
     message = "A top-ranked Order Block was just mitigated on {{ticker}} ({{interval}}).")

if not na(mitigatedTopId)
    alert("Top-ranked OB mitigated on " + syminfo.ticker + " (" + timeframe.period + ") — ID #" + str.tostring(mitigatedTopId), alert.freq_once_per_bar)
````
