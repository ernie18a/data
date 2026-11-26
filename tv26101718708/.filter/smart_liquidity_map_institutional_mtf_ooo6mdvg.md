# Smart Liquidity Map - Institutional MTF

- url: https://www.tradingview.com/script/ooO6MdvG/
- type: indicator
- pine_id: PUB;b7feb4894eb44dcba166069e9456f883
- version: 2.0

## Description

Smart Liquidity Map (SLM) - Multi-Timeframe Institutional Orderblocks

Description:
This advanced trading tool generates a fully automated institutional liquidity map directly on your price chart. By scanning key algorithmic levels, it precisely targets institutional resting orders (Buy-Side & Sell-Side Liquidity). Thanks to a smart adaptive script engine, it works perfectly across any chart resolution, maintaining a rock-solid, constant multi-timeframe perspective.

Core Features:

Fixed Multi-Timeframe Matrix (1H, 4H, 1D):
Removes lower-timeframe noise. The indicator strictly tracks the three most critical institutional horizons: 1-Hour, 4-Hour, and Daily pivots.

Smart Confluence Engine (Combo Zones):
When opposing liquidity levels (BSL & SSL) collide within a narrow price threshold, they instantly merge into a highly significant, dark orange Combo Zone .

Overlay & Cluster Aggregation:
If same-direction levels overlap across different timeframes (e.g., 1H BSL + 4H BSL), the chart remains clean. The dynamic label automatically lists all involved timeframes (e.g., BSL [1H, 4H]).

Volume Profile POC Box:
Dynamically computes the Point of Control (POC) based on historical volume distribution and renders it as a clean, custom gray box with high-contrast labeling.

Real-Time Sweep Mitigation:
As soon as price sweeps a liquidity level, the zone gets updated instantly (removed or faded) to keep your workspace clean and efficient.

Visual Color Guide:
Red: Pure Buy-Side Liquidity (BSL) – Resistance / Short Targets.
Green: Pure Sell-Side Liquidity (SSL) – Support / Long Targets.
Orange: Mixed Combo Zones (BSL + SSL Confluence).
Gray: Volume Profile Point of Control (POC).

## Source Code

````pine
//@version=6
// ============================================================================
//  Smart Liquidity Map - Multi-Timeframe Pivot Levels
//  ---------------------------------------------------------------------------
//  Marks confirmed pivot highs and lows from a fixed 1H / 4H / 1D grid, merges
//  levels that coincide across timeframes, and clears them once price either
//  sweeps through and rejects, or closes decisively beyond. A timeframe is only
//  evaluated when the chart resolution is equal to or finer than it, so a level
//  always means what its tag says.
// ============================================================================
indicator("Smart Liquidity Map - Institutional MTF", "SLM MTF", overlay = true,
     max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ------------------------------------------------------------------ inputs --
const string G_TF  = "Timeframe grid"
const string G_REL = "Confluence"
const string G_SWP = "Sweep logic"
const string G_VIS = "Appearance"
const string G_POC = "Volume point of control"

bool use1H    = input.bool(true, "1H levels", inline = "t1", group = G_TF)
int  pivLen1H = input.int(5, "strength", minval = 1, inline = "t1", group = G_TF)
bool use4H    = input.bool(true, "4H levels", inline = "t2", group = G_TF)
int  pivLen4H = input.int(3, "strength", minval = 1, inline = "t2", group = G_TF)
bool use1D    = input.bool(true, "1D levels", inline = "t3", group = G_TF)
int  pivLen1D = input.int(2, "strength", minval = 1, inline = "t3", group = G_TF)
bool showNote = input.bool(true, "Show availability note", group = G_TF,
     tooltip = "A timeframe is skipped when the chart resolution is coarser than it. Reading a 1H pivot off a 4H chart would return a 4H pivot wearing a 1H label, so the level is dropped instead of approximated.")

int   maxLevels = input.int(15, "Maximum levels per side", minval = 3, maxval = 50, group = G_REL)
float equalTol  = input.float(0.15, "Merge tolerance (x ATR)", minval = 0.01, step = 0.05,
     group = G_REL,
     tooltip = "Two levels closer than this are treated as one. Same direction merges into a single zone carrying both tags, opposite directions form a combo zone.")

bool needCloseBack = input.bool(true, "Require close-back for sweep", group = G_SWP,
     tooltip = "On: a sweep needs price to pierce the level and close back on the original side. Off: any wick through the level counts.")
bool dropBroken    = input.bool(true, "Also clear levels broken by a close", group = G_SWP,
     active = needCloseBack,
     tooltip = "A level that price closes decisively beyond has been accepted, not defended, and is no longer a level. Without this, only wick-and-reject sweeps are recognised and broken levels accumulate on the chart indefinitely.")
bool removeSwept   = input.bool(true, "Remove swept levels", group = G_SWP)
bool fadeSwept     = input.bool(false, "Fade swept levels instead", group = G_SWP,
     tooltip = "Applies to sweeps only. Levels cleared by a close-through are always removed, since nothing was defended there.")

color bslColor   = input.color(#b22833, "Buy-side (BSL)",  group = G_VIS)
color sslColor   = input.color(#056656, "Sell-side (SSL)", group = G_VIS)
color mixedColor = input.color(#f57f17, "Combo zone",      group = G_VIS)
color pocColor   = input.color(#b8b8b8, "POC",             group = G_VIS)
int   extendBars = input.int(40, "Extend right (bars)", minval = 5, group = G_VIS)
bool  showLabels = input.bool(true, "Show tags", group = G_VIS)
string lblSizeIn = input.string("tiny", "Tag size", options = ["tiny", "small", "normal", "large"], group = G_VIS)
float boxHeight  = input.float(0.1, "Zone height (x ATR)", minval = 0.01, step = 0.01, group = G_VIS)

bool useVPOC      = input.bool(true, "Enable POC", group = G_POC)
int  vpocLookback = input.int(100, "Lookback (bars)", minval = 20, maxval = 500, group = G_POC)
int  vpocBins     = input.int(50, "Resolution (bins)", minval = 10, maxval = 200, group = G_POC,
     tooltip = "Volume is spread evenly across each bar's range before binning. This approximates a volume profile without tick data.")

string lblSize = lblSizeIn == "small" ? size.small : lblSizeIn == "tiny" ? size.tiny : lblSizeIn == "large" ? size.large : size.normal

// -------------------------------------------------------- grid availability --
// A timeframe is usable only when the chart resolution is equal to or finer
// than it. Above that, request.security returns one value per chart bar and
// most pivots on the requested timeframe are never seen.
float chartMin = timeframe.in_seconds(timeframe.period) / 60.0

bool ok1H = use1H and chartMin <= 60
bool ok4H = use4H and chartMin <= 240
bool ok1D = use1D and chartMin <= 1440

// Requesting a timeframe below the chart's is pointless, so clamp it.
string tf1H = chartMin > 60   ? timeframe.period : "60"
string tf4H = chartMin > 240  ? timeframe.period : "240"
string tf1D = chartMin > 1440 ? timeframe.period : "D"

float atr = ta.atr(14)

// One request per timeframe instead of one per pivot direction.
[ph1H, pl1H] = request.security(syminfo.tickerid, tf1H,
     [ta.pivothigh(high, pivLen1H, pivLen1H), ta.pivotlow(low, pivLen1H, pivLen1H)],
     lookahead = barmerge.lookahead_off)
[ph4H, pl4H] = request.security(syminfo.tickerid, tf4H,
     [ta.pivothigh(high, pivLen4H, pivLen4H), ta.pivotlow(low, pivLen4H, pivLen4H)],
     lookahead = barmerge.lookahead_off)
[ph1D, pl1D] = request.security(syminfo.tickerid, tf1D,
     [ta.pivothigh(high, pivLen1D, pivLen1D), ta.pivotlow(low, pivLen1D, pivLen1D)],
     lookahead = barmerge.lookahead_off)

// ------------------------------------------------------------------- state --
type LiqLevel
    float price
    int   barIdx
    bool  isOverlap
    bool  isMixed
    string tfs
    box   bx
    label lbl
    bool  swept
    bool  isBuy

var array<LiqLevel> bsl = array.new<LiqLevel>()
var array<LiqLevel> ssl = array.new<LiqLevel>()

var box   pocBox   = na
var label pocLabel = na
var float pocPrice = na

// ---------------------------------------------------------------- helpers ---
// A pivot value is held across every chart bar that maps to the same reference
// bar, so presence alone fires repeatedly. Only a change to a new non-na value
// marks a genuinely new pivot.
isNewPivot(float v) =>
    not na(v) and (na(v[1]) or v != v[1])

// A pivot is confirmed pivLen bars after it printed. Walk the box back to where
// the extreme actually sits rather than to where it was detected.
pivotBarOffset(float tfMin, int pivLen) =>
    int back = math.round(pivLen * tfMin / math.max(chartMin, 1.0))
    math.min(math.max(back, 0), bar_index)

// ------------------------------------------------------ placement & merge ---
placeLevel(array<LiqLevel> arr, array<LiqLevel> oppositeArr, float newPrice, int targetBar, bool isBuy, string tag) =>
    float tol = atr * equalTol
    bool merged = false

    // Opposite directions meeting at one price form a combo zone.
    if array.size(oppositeArr) > 0
        for i = 0 to array.size(oppositeArr) - 1
            LiqLevel opp = array.get(oppositeArr, i)
            if not opp.swept and math.abs(opp.price - newPrice) <= tol
                opp.isMixed := true
                opp.isOverlap := true
                if not str.contains(opp.tfs, tag)
                    opp.tfs := opp.tfs + ", " + tag
                box.set_bgcolor(opp.bx, mixedColor)
                box.set_border_color(opp.bx, mixedColor)
                merged := true
                break

    // Same direction: only count as confluence when the tag is genuinely new.
    if not merged and array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            LiqLevel lvl = array.get(arr, i)
            if not lvl.swept and math.abs(lvl.price - newPrice) <= tol
                if not str.contains(lvl.tfs, tag)
                    lvl.tfs := lvl.tfs + ", " + tag
                    lvl.isOverlap := true
                merged := true
                break

    if not merged
        color clr = isBuy ? bslColor : sslColor
        float h = atr * boxHeight

        box newBx = box.new(targetBar, newPrice + h, bar_index + extendBars, newPrice - h,
             bgcolor = clr, border_color = clr, border_width = 1)

        label newLbl = na
        if showLabels
            newLbl := label.new(bar_index + extendBars, newPrice,
                 (isBuy ? "BSL" : "SSL") + " [" + tag + "]",
                 style = label.style_label_left, color = color.new(color.black, 85),
                 textcolor = clr, size = lblSize)

        array.push(arr, LiqLevel.new(newPrice, targetBar, false, false, tag, newBx, newLbl, false, isBuy))

    while array.size(arr) > maxLevels
        LiqLevel old = array.shift(arr)
        box.delete(old.bx)
        if not na(old.lbl)
            label.delete(old.lbl)

// ------------------------------------------------------------- detection ----
if ok1H
    if isNewPivot(ph1H)
        placeLevel(bsl, ssl, ph1H, bar_index - pivotBarOffset(60, pivLen1H), true, "1H")
    if isNewPivot(pl1H)
        placeLevel(ssl, bsl, pl1H, bar_index - pivotBarOffset(60, pivLen1H), false, "1H")

if ok4H
    if isNewPivot(ph4H)
        placeLevel(bsl, ssl, ph4H, bar_index - pivotBarOffset(240, pivLen4H), true, "4H")
    if isNewPivot(pl4H)
        placeLevel(ssl, bsl, pl4H, bar_index - pivotBarOffset(240, pivLen4H), false, "4H")

if ok1D
    if isNewPivot(ph1D)
        placeLevel(bsl, ssl, ph1D, bar_index - pivotBarOffset(1440, pivLen1D), true, "1D")
    if isNewPivot(pl1D)
        placeLevel(ssl, bsl, pl1D, bar_index - pivotBarOffset(1440, pivLen1D), false, "1D")

// -------------------------------------------------------- disabled cleanup --
// A merged level carries several tags. It only leaves the chart once none of
// its source timeframes is active any more.
dropDisabled(array<LiqLevel> arr) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            LiqLevel lvl = array.get(arr, i)
            bool alive = (ok1H and str.contains(lvl.tfs, "1H")) or
                 (ok4H and str.contains(lvl.tfs, "4H")) or
                 (ok1D and str.contains(lvl.tfs, "1D"))
            if not alive
                box.delete(lvl.bx)
                if not na(lvl.lbl)
                    label.delete(lvl.lbl)
                array.remove(arr, i)

dropDisabled(bsl)
dropDisabled(ssl)

// ------------------------------------------------- sweep and break handling --
// Two distinct events end a level's life:
//   sweep  - price pierces it and closes back on the original side. Liquidity
//            was taken and the level defended. This is the tradeable signal.
//   break  - price closes beyond it. The level was accepted, not defended, and
//            carries no further meaning. Cleared silently.
updateLevels(array<LiqLevel> arr) =>
    bool sweepFired = false
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            LiqLevel lvl = array.get(arr, i)
            if not lvl.swept
                bool pierced      = lvl.isBuy ? high  > lvl.price : low   < lvl.price
                bool closedBeyond = lvl.isBuy ? close > lvl.price : close < lvl.price

                bool sweep = needCloseBack ? (pierced and not closedBeyond) : pierced
                bool brk   = needCloseBack and dropBroken and closedBeyond and not sweep

                if sweep
                    sweepFired := true
                    lvl.swept := true
                    if fadeSwept
                        box.set_bgcolor(lvl.bx, color.new(color.gray, 92))
                        box.set_border_color(lvl.bx, color.new(color.gray, 75))
                        box.set_right(lvl.bx, bar_index)
                        if not na(lvl.lbl)
                            label.delete(lvl.lbl)
                            lvl.lbl := na
                    else if removeSwept
                        box.delete(lvl.bx)
                        if not na(lvl.lbl)
                            label.delete(lvl.lbl)
                        array.remove(arr, i)
                else if brk
                    box.delete(lvl.bx)
                    if not na(lvl.lbl)
                        label.delete(lvl.lbl)
                    array.remove(arr, i)
                else
                    box.set_right(lvl.bx, bar_index + extendBars)
                    if not na(lvl.lbl)
                        label.set_x(lvl.lbl, bar_index + extendBars)
    sweepFired

bool bslSweep = updateLevels(bsl)
bool sslSweep = updateLevels(ssl)

// -------------------------------------------------------------------- POC ---
// Volume is distributed evenly across each bar's high-low range, then binned.
// Recomputed on the last bar, so the level shifts as new bars arrive.
if useVPOC and barstate.islast
    if not na(pocBox)
        box.delete(pocBox)
    if not na(pocLabel)
        label.delete(pocLabel)

    float vpHigh = ta.highest(high, vpocLookback)
    float vpLow  = ta.lowest(low, vpocLookback)
    float binSize = (vpHigh - vpLow) / vpocBins

    if binSize > 0 and not na(vpHigh) and not na(vpLow)
        array<float> bins = array.new<float>(vpocBins, 0.0)

        for i = 0 to vpocLookback - 1
            float barL = low[i]
            float barH = high[i]
            float barV = volume[i]
            if not na(barV) and not na(barH) and not na(barL) and barH > barL
                int startBin = math.max(0, math.floor((barL - vpLow) / binSize))
                int endBin   = math.min(vpocBins - 1, math.floor((barH - vpLow) / binSize))
                int touched  = endBin - startBin + 1
                if touched > 0
                    float vPerBin = barV / touched
                    for b = startBin to endBin
                        array.set(bins, b, array.get(bins, b) + vPerBin)

        float maxV = 0.0
        int maxBin = 0
        for b = 0 to vpocBins - 1
            if array.get(bins, b) > maxV
                maxV := array.get(bins, b)
                maxBin := b

        pocPrice := vpLow + (maxBin + 0.5) * binSize
        float h = atr * boxHeight

        pocBox := box.new(bar_index - vpocLookback + 1, pocPrice + h, bar_index + extendBars, pocPrice - h,
             bgcolor = pocColor, border_color = pocColor, border_width = 1)
        pocLabel := label.new(bar_index + extendBars, pocPrice,
             "POC " + str.tostring(pocPrice, format.mintick),
             style = label.style_label_left, color = color.new(color.black, 85),
             textcolor = color.white, size = lblSize)

// ------------------------------------------------------------ tag refresh ---
refreshTags(array<LiqLevel> arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            LiqLevel lvl = array.get(arr, i)
            if not lvl.swept and showLabels and not na(lvl.lbl)
                label.set_text(lvl.lbl,
                     (lvl.isMixed ? "Combo" : lvl.isBuy ? "BSL" : "SSL") + " [" + lvl.tfs + "]")
                label.set_size(lvl.lbl, lblSize)
                label.set_textcolor(lvl.lbl,
                     lvl.isMixed ? mixedColor : lvl.isBuy ? bslColor : sslColor)

if barstate.islast
    refreshTags(bsl)
    refreshTags(ssl)

// ------------------------------------------------------- availability note --
if showNote and barstate.islast and (not ok1H or not ok4H or not ok1D)
    string active = (ok1H ? "1H " : "") + (ok4H ? "4H " : "") + (ok1D ? "1D" : "")
    string note = str.length(str.trim(active)) == 0
         ? "No pivot timeframe available at this chart resolution.\nSwitch to 1D or finer."
         : "Pivot timeframes active: " + str.trim(active)

    var table tNote = table.new(position.top_right, 1, 1)
    table.cell(tNote, 0, 0, note, text_size = size.tiny,
         text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 20))

// ----------------------------------------------------------------- alerts ---
alertcondition(bslSweep, "Buy-side level swept", "A buy-side pivot level was pierced and rejected.")
alertcondition(sslSweep, "Sell-side level swept", "A sell-side pivot level was pierced and rejected.")
````
