# POC Volume Profile v2

- url: https://www.tradingview.com/script/VmpdFg3k/
- type: indicator
- pine_id: PUB;6c66e90587054587b6bf9a3f087e2564
- version: 2.0

## Description

📊 POC Volume Profile v2 — What This Code Does (In Plain English)

This indicator draws a volume profile on top of your price chart. In simple terms, it shows you at which price levels the most trading happened during a chosen period.
📅 Picking a Range

    Works in two ways:

        Manual: You give it a start date and an end date, and it uses that period.

        Automatic: It looks at swing highs and lows (called pivots) and picks a range on its own.

    You can tell it which pivot to start from (e.g., the 25th most recent pivot).

    If you want, it marks those pivots on the chart with green and red dots.

📊 Building the Volume Profile

    It takes all the candles in the chosen range.

    It splits the price range into horizontal slices (called bins).

    For each candle, it spreads that candle's volume into the bins that the candle's price range covers.

    This shows how much volume piled up at each price level.

    If you turn on Delta mode, it also splits volume into buying (green) and selling (red) based on whether the candle closed up or down.

📌 Lines It Draws

    POC (Point of Control): The price level with the most volume. Drawn as a horizontal line with a label.

    VAH / VAL (Value Area High / Low): The upper and lower edges of the price band where most of the volume (usually 70%) is concentrated. Drawn as dashed lines.

    VWAP: The volume-weighted average price for the whole range. Drawn as a solid line.

    You can change the colors and styles of all these lines.

📈 Peak Boxes

    It finds local spikes in the volume profile (called peaks).

    Each peak is drawn as a horizontal box covering that price band.

    If two peaks are very close together, it merges them and keeps only the strongest one.

    It treats the two nearest peaks above the current price and the two nearest peaks below as "active" and extends them to the right.

    Other boxes are drawn only up to the last time price touched that area.

🎯 Supply / Demand Coloring

    It colors the peak boxes based on where price is:

        Above price → red (SUPPLY) — potential resistance.

        Below price → green (DEMAND) — potential support.

        Price inside the box → gray (PRICE-IN) — neutral.

    You can turn this coloring on or off, and change the colors.

🎨 Visual Stuff

    Automatically detects if your chart is light or dark and adjusts text color for readability.

    Can align the histogram to the right side of the chart or start it from the left.

    Can highlight the POC zone with a soft fill.

    Can show a summary label under the range with total volume, delta %, POC, and VWAP.

    Hovering over that label shows a detailed tooltip.

⚙️ Technical Limits

    Only calculates on the last bar, so it doesn't constantly redraw history.


🧠 In Short

This code is a volume map for your chart. It shows where trading activity was heaviest, where buyers and sellers concentrated, and which price levels might act as support or resistance.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════
// POC Volume Profile + Peak Boxes + S/D Colors       
// ══════════════════════════════════════════════════════════

indicator(
     title            = "POC Volume Profile v2",
     shorttitle       = "POC v2",
     overlay          = true,
     max_labels_count = 500,
     max_lines_count  = 500,
     max_boxes_count  = 500,
     max_bars_back    = 4900,
     calc_bars_count  = 5000
)

// ══════════════════════════════════════
// CONSTANTS
// ══════════════════════════════════════
GRP_TIME   = "📅 Date Range"
GRP_AUTO   = "🔄 Auto Range Mode"
GRP_MAIN   = "⚙️ Main Settings"
GRP_VISUAL = "🎨 Visual Settings"
GRP_COLORS = "🎨 Colors"
GRP_PEAK   = "📈 Histogram Peaks"
GRP_SDCLR  = "🎯 S/D Peak Colors"

TRANSPARENT = color.new(#000000, 100)
HIDDEN      = color.new(#000000, 100)

// ─── Hardcoded peak detection defaults ───
PEAK_LOOKBACK   = 1      // ± bins
PEAK_MIN_RATIO  = 0.05   // min volume fraction of max bin

// ══════════════════════════════════════
// INPUTS
// ══════════════════════════════════════
startTimeInput = input.time(timestamp("2027-09-01T00:03:00"), "Start Date", group = GRP_TIME, tooltip = "Start of the manual profile range.\nOnly used when Auto Range Mode is OFF.\nAll bars between Start Date and End Date are included in the volume profile.")
endTimeInput   = input.time(timestamp("2027-12-31T23:59:59"), "End Date",   group = GRP_TIME, tooltip = "End of the manual profile range.\nOnly used when Auto Range Mode is OFF.\nThe profile is recalculated live as long as the current bar falls inside this window.")

autoRangeInput     = input.bool(true, "Enable Auto Range Mode", group = GRP_AUTO, tooltip = "ON  → The range is detected automatically from pivots (no manual dates needed).\nOFF → Uses the manual Start/End Dates above.\n\nThe auto engine looks back over pivot highs/lows and starts the profile at the Nth most recent pivot.")
pivotLenInput      = input.int(5, "Pivot Length", minval = 1, maxval = 50, group = GRP_AUTO, tooltip = "Bars on each side used to confirm a pivot high/low.\nHigher = fewer, more significant pivots.\nLower = more frequent, noisier pivots.")
showPivotHighInput = input.bool(true, "Show Pivot High Markers (🟢)", group = GRP_AUTO, tooltip = "Draws a green dot above each confirmed pivot high.\nThese pivots are used as candidate range start points in Auto Range Mode.")
showPivotLowInput  = input.bool(true, "Show Pivot Low Markers (🔴)",  group = GRP_AUTO, tooltip = "Draws a red dot below each confirmed pivot low.\nThese pivots are used as candidate range start points in Auto Range Mode.")
nthPivotInput      = input.int(25, "Nearest Nth Pivot", minval = 1, maxval = 250, group = GRP_AUTO, tooltip = "How many pivots back (highs + lows combined, sorted by time) the range should start.\nExample: 25 = start the profile at the 25th most recent pivot.\n\nLarger values = wider range / longer lookback.\nSmaller values = tighter, more reactive range.")

binCountInput  = input.int(100, "Profile Bins", minval = 10, maxval = 250, step = 5, group = GRP_MAIN, tooltip = "Number of horizontal price rows used to build the volume profile.\nMore bins = finer price resolution but more drawing objects.\nFewer bins = smoother profile, lighter on resources.")
vaPercentInput = input.float(100.0, "Value Area %", minval = 1.0, maxval = 100.0, step = 1.0, group = GRP_MAIN, tooltip = "Percentage of total volume that defines the Value Area (VAH–VAL band).\nClassic setting: 70%.\n100% expands the VA to the entire range.")
VA_PERCENT = vaPercentInput / 100.0

showProfileInput = input.bool(true,  "Show Volume Profile", group = GRP_VISUAL, tooltip = "Master toggle for the volume histogram itself.\nTurn OFF to keep only the POC / VA / VWAP lines and peak boxes.")
alignRightInput  = input.bool(false, "Align to Right",       group = GRP_VISUAL, tooltip = "ON  → Histogram is drawn 5 bars to the right of the last bar (bars still grow left-to-right).\nOFF → Histogram is drawn from the range start bar (left-to-right).")
showDeltaInput   = input.bool(true,  "Show Delta Profile",  group = GRP_VISUAL, tooltip = "ON  → Each bin is split into Buy Volume (green) and Sell Volume (red).\nOFF → Each bin is drawn as a single Base Volume color.")
showPocInput     = input.bool(true,  "Show POC Line",       group = GRP_VISUAL, tooltip = "Draws the Point of Control (highest-volume price) as a horizontal line with a label.")
showPocFillInput = input.bool(true,  "Show POC Zone Fill",  group = GRP_VISUAL, tooltip = "Highlights the POC bin with a soft fill so the highest-volume price stands out clearly.")
showVaInput      = input.bool(true,  "Show Value Area",     group = GRP_VISUAL, tooltip = "Draws the Value Area High (VAH) and Value Area Low (VAL) as dashed lines with labels.\nUses the Value Area % from Main Settings.")
showVwapInput    = input.bool(true,  "Show VWAP",           group = GRP_VISUAL, tooltip = "Draws the Volume-Weighted Average Price over the whole range.\nA single line representing the fair average price paid within the range.")
showLabelsInput  = input.bool(false, "Show Range Label",    group = GRP_VISUAL, tooltip = "Prints a compact stats label under the range:\nTotal Volume, Delta %, POC and VWAP.\nHover the label to see the full tooltip summary.")

bullColorInput = input.color(#26A69A, "Buy Volume (Green)", inline = "colors",  group = GRP_COLORS, tooltip = "Color used for the buy-side portion of each bin in Delta mode.")
bearColorInput = input.color(#FF9100, "Sell Volume (Red)",  inline = "colors",  group = GRP_COLORS, tooltip = "Color used for the sell-side portion of each bin in Delta mode.")
baseColorInput = input.color(#90CAF9, "Base Volume",        inline = "colors2", group = GRP_COLORS, tooltip = "Color used when Delta mode is OFF (single-color histogram).")
pocColorInput  = input.color(#FF1744, "POC Line (Red)",     inline = "colors2", group = GRP_COLORS, tooltip = "Color of the POC (Point of Control) line.")
vaHighColor    = input.color(#2979FF, "VAH Line (Blue)",    inline = "colors3", group = GRP_COLORS, tooltip = "Color of the Value Area High dashed line.")
vaLowColor     = input.color(#FF9100, "VAL Line (Orange)",  inline = "colors3", group = GRP_COLORS, tooltip = "Color of the Value Area Low dashed line.")
vwapColorInput = input.color(#AB47BC, "VWAP",               inline = "colors4", group = GRP_COLORS, tooltip = "Color of the VWAP line.")

// --- Histogram Peaks ---
showPeaksInput     = input.bool(true, "Show Peak Boxes", group = GRP_PEAK, tooltip = "Highlights local volume peaks as horizontal boxes.\nEach box marks a price band where volume clustered noticeably higher than its neighbors.\nUseful for spotting hidden support/resistance from volume shelves.")
peakExtendInput    = input.int(15, "Peak Extend (bars)", minval = 5, maxval = 500, group = GRP_PEAK, tooltip = "How far to the right (in bars) active peak boxes are extended.\nActive boxes = the 2 nearest peaks above and 2 nearest below current price.")
peakShowLabelInput = input.bool(true, "Show Peak Labels", group = GRP_PEAK, tooltip = "Prints a label on each peak box showing its side (SUPPLY / DEMAND / PRICE-IN) and midpoint price.")
peakColorInput     = input.color(#FFC107, "Peak Fill (Neutral)",   inline = "pk", group = GRP_PEAK, tooltip = "Background color used when S/D coloring is disabled or when a peak is neutral.")
peakBorderInput    = input.color(#FF9800, "Peak Border (Neutral)", inline = "pk", group = GRP_PEAK, tooltip = "Border color used for neutral peaks.")
peakClusterGapInput = input.int(3, "Peak Cluster Gap (bins)", minval = 1, maxval = 20, group = GRP_PEAK, tooltip = "Peaks that are closer than this many bins are treated as the same cluster,\nand only the highest-volume peak in the cluster is kept.\n\nPrevents clutter from adjacent bins that form a single volume shelf.")

// --- S/D Peak Coloring ---
sdColorPeaksInput    = input.bool(true, "Color Peaks by S/D Position", group = GRP_SDCLR, tooltip = "Colors peak boxes based on their position relative to the last close:\n\n• Above price → SUPPLY (red)\n• Below price → DEMAND (green)\n• Containing price → neutral gray (PRICE-IN)\n\nThis gives a quick visual map of potential supply and demand zones.")
supplyPeakColorInput = input.color(#FF1744, "Supply Peak Color", inline = "sdp", group = GRP_SDCLR, tooltip = "Color applied to peak boxes located above the current price (potential supply).")
demandPeakColorInput = input.color(#00C853, "Demand Peak Color", inline = "sdp", group = GRP_SDCLR, tooltip = "Color applied to peak boxes located below the current price (potential demand).")

// ══════════════════════════════════════
// THEME (automatic detection)
// ══════════════════════════════════════
isDark = color.r(chart.bg_color) < 128

TEXT_COLOR = isDark ? #E0E0E0 : #1A1A1A
POC_FILL   = color.new(pocColorInput, 85)

// ══════════════════════════════════════
// FUNCTIONS
// ══════════════════════════════════════
safeDiv(float num, float den, float fallback = 0.0) =>
    den != 0 and not na(num) and not na(den) ? num / den : fallback

distributeVolume(float cOpen, float cClose, float cHigh, float cLow, float cVol, float bottom, float step, int bins, array<float> volArr, array<float> buyArr, array<float> sellArr) =>
    float candleTop   = math.max(cHigh, cLow)
    float candleBot   = math.min(cHigh, cLow)
    float candleRange = candleTop - candleBot
    bool isBullCandle = cClose >= cOpen
    if candleRange > 0 and cVol > 0
        for k = 0 to bins - 1
            float binLow  = bottom + k * step
            float binHigh = binLow + step
            float overlap = math.max(0.0, math.min(candleTop, binHigh) - math.max(candleBot, binLow))
            if overlap > 0
                float portion  = overlap / candleRange
                float allocVol = cVol * portion
                volArr.set(k, volArr.get(k) + allocVol)
                if isBullCandle
                    buyArr.set(k, buyArr.get(k) + allocVol)
                else
                    sellArr.set(k, sellArr.get(k) + allocVol)

// Returns [vaHigh, vaLow, upperBin, lowerBin]
calcValueArea(array<float> volArr, float totalVol, int pocBin, float bottom, float step, int bins) =>
    float target      = totalVol * VA_PERCENT
    float accumulated = volArr.get(pocBin)
    int   upperBin    = pocBin
    int   lowerBin    = pocBin
    int   safety      = 0
    while accumulated < target and safety < bins
        safety += 1
        float upVol   = upperBin + 1 < bins ? volArr.get(upperBin + 1) : 0.0
        float downVol = lowerBin - 1 >= 0   ? volArr.get(lowerBin - 1) : 0.0
        if upVol >= downVol and upperBin + 1 < bins
            upperBin    += 1
            accumulated += upVol
        else if lowerBin - 1 >= 0
            lowerBin    -= 1
            accumulated += downVol
        else if upperBin + 1 < bins
            upperBin    += 1
            accumulated += upVol
        else
            break
    float vaHigh = bottom + (upperBin + 1) * step
    float vaLow  = bottom + lowerBin * step
    [vaHigh, vaLow, upperBin, lowerBin]

// ══════════════════════════════════════
// PIVOT DETECTION
// ══════════════════════════════════════
int pLen = pivotLenInput

float ph = ta.pivothigh(high, pLen, pLen)
float pl = ta.pivotlow (low,  pLen, pLen)

if autoRangeInput and showPivotHighInput and not na(ph)
    label.new(bar_index[pLen], ph, "●", style = label.style_none, textcolor = color.new(#00E676, 0), size = size.tiny, yloc = yloc.abovebar)

if autoRangeInput and showPivotLowInput and not na(pl)
    label.new(bar_index[pLen], pl, "●", style = label.style_none, textcolor = color.new(#FF1744, 0), size = size.tiny, yloc = yloc.belowbar)

// ══════════════════════════════════════
// AUTO RANGE: Nth PIVOT SELECTION
// ══════════════════════════════════════
var array<int>   phBars   = array.new<int>()
var array<float> phPrices = array.new<float>()
var array<int>   plBars   = array.new<int>()
var array<float> plPrices = array.new<float>()

if not na(ph)
    phBars.push(bar_index[pLen])
    phPrices.push(ph)

if not na(pl)
    plBars.push(bar_index[pLen])
    plPrices.push(pl)

// ══════════════════════════════════════
// RANGE TRACKING
// ══════════════════════════════════════
var int   startIdx  = na
var int   endIdx    = na
var float rangeHigh = na
var float rangeLow  = na

if autoRangeInput
    if barstate.islast
        int nth = nthPivotInput
        bool useHigh = showPivotHighInput or not showPivotLowInput
        bool useLow  = showPivotLowInput  or not showPivotHighInput

        array<int> combinedBars = array.new<int>()

        if useHigh and phBars.size() > 0
            for i = 0 to phBars.size() - 1
                combinedBars.push(phBars.get(i))

        if useLow and plBars.size() > 0
            for i = 0 to plBars.size() - 1
                combinedBars.push(plBars.get(i))

        int csz = combinedBars.size()
        if csz > 1
            for i = 1 to csz - 1
                int key = combinedBars.get(i)
                int j   = i - 1
                while j >= 0 and combinedBars.get(j) < key
                    combinedBars.set(j + 1, combinedBars.get(j))
                    j -= 1
                combinedBars.set(j + 1, key)

        int autoStart = na
        if csz >= nth
            autoStart := combinedBars.get(nth - 1)

        if not na(autoStart)
            startIdx  := autoStart
            endIdx    := bar_index

            float rH = low[bar_index - autoStart]
            float rL = high[bar_index - autoStart]
            int   span = bar_index - autoStart
            if span > 0 and span < 4900
                for i = 0 to span
                    float h = nz(high[i], close[i])
                    float l = nz(low[i],  close[i])
                    rH := math.max(rH, h)
                    rL := math.min(rL, l)
            rangeHigh := rH
            rangeLow  := rL
else
    bool inRange = time >= startTimeInput and time <= endTimeInput
    if inRange
        if na(startIdx)
            startIdx := bar_index
        endIdx    := bar_index
        rangeHigh := na(rangeHigh) ? high : math.max(rangeHigh, high)
        rangeLow  := na(rangeLow)  ? low  : math.min(rangeLow,  low)

// ══════════════════════════════════════
// STATE VARIABLES
// ══════════════════════════════════════
var float lastPocPrice = na
var float lastVaHigh   = na
var float lastVaLow    = na
var float lastVwap     = na
var float lastTotalVol = na
var float lastDelta    = na

// Peak refs
var array<box>   peakBoxRefs   = array.new<box>()
var array<label> peakLabelRefs = array.new<label>()

// ══════════════════════════════════════
// MAIN PROFILE (ON LAST BAR)
// ══════════════════════════════════════
if barstate.islast and not na(startIdx)
    int finalEnd = na(endIdx) ? bar_index : endIdx
    int barSpan  = finalEnd - startIdx

    if barSpan > 0 and barSpan < 4900
        int   bins = binCountInput
        float step = (rangeHigh - rangeLow) / bins

        array<float> volBins  = array.new<float>(bins, 0.0)
        array<float> buyBins  = array.new<float>(bins, 0.0)
        array<float> sellBins = array.new<float>(bins, 0.0)

        float sumPV = 0.0
        float sumV  = 0.0

        for i = (bar_index - finalEnd) to (bar_index - startIdx)
            float cVol = nz(volume[i], 0.0)
            float cC   = nz(close[i],  0.0)
            float cH   = na(high[i])  ? cC : high[i]
            float cL   = na(low[i])   ? cC : low[i]
            float cO   = na(open[i])  ? cC : open[i]

            distributeVolume(cO, cC, cH, cL, cVol, rangeLow, step, bins, volBins, buyBins, sellBins)

            float typPrice = (cH + cL + cC) / 3.0
            sumPV += typPrice * cVol
            sumV  += cVol

        float totalVol = volBins.sum()
        float maxVol   = volBins.max()

        int pocBin = 0
        if maxVol > 0
            for k = 0 to bins - 1
                if volBins.get(k) == maxVol
                    pocBin := k
                    break

        float pocPrice = rangeLow + pocBin * step + step / 2.0

        float vaH = rangeHigh
        float vaL = rangeLow
        if totalVol > 0
            [calcVaH, calcVaL, calcVaHBin, calcVaLBin] = calcValueArea(volBins, totalVol, pocBin, rangeLow, step, bins)
            vaH := calcVaH
            vaL := calcVaL

        float rangeVwap = safeDiv(sumPV, sumV, pocPrice)

        lastPocPrice := pocPrice
        lastVaHigh   := vaH
        lastVaLow    := vaL
        lastVwap     := rangeVwap
        lastTotalVol := totalVol
        float totalBuy  = buyBins.sum()
        float totalSell = sellBins.sum()
        lastDelta := safeDiv(totalBuy - totalSell, totalVol, 0.0) * 100.0

        int drawSpan     = math.max(int(barSpan * 0.35), 2)
        int transValue   = 60
        int vaTransValue = 30

        int rightVisibleBarIdx = bar_index + math.max(0, int((chart.right_visible_bar_time - time) / (time - time[1])))
        int profileRightAnchor = alignRightInput ? rightVisibleBarIdx : bar_index
        int lineStartIdx = startIdx
        int lineEndIdx   = alignRightInput ? profileRightAnchor : bar_index
        int labelOffset  = alignRightInput ? startIdx : bar_index + 3
        string labelStyle = alignRightInput ? label.style_label_right : label.style_label_left

        // ─── HISTOGRAM BAR ANCHOR ───
        // Sağa yasla ON  → barlar son bardan 5 bar sağdan başlar, SOLDAN SAĞA büyür.
        // Sağa yasla OFF → barlar range başlangıcından başlar, SOLDAN SAĞA büyür.
        int barAnchor = alignRightInput ? (bar_index + 5) : startIdx

        // ─── VOLUME PROFILE ───
        for k = 0 to bins - 1
            float binL = rangeLow + k * step
            float binH = binL + step

            float volRatio = safeDiv(volBins.get(k), maxVol, 0.0)
            int profWidth  = math.max(int(volRatio * drawSpan), 0)

            float buyV        = buyBins.get(k)
            float sellV       = sellBins.get(k)
            float totalBinVol = buyV + sellV

            float buyRatio = safeDiv(buyV, totalBinVol, 0.0)
            int buyWidth   = math.max(int(profWidth * buyRatio), 0)
            int sellWidth  = math.max(int(profWidth - buyWidth), 0)

            bool inVA = binL >= vaL and binH <= vaH

            if showProfileInput
                if showDeltaInput
                    if buyWidth > 0
                        box.new(barAnchor, binH, barAnchor + buyWidth, binL, na, 0, bgcolor = color.new(bullColorInput, inVA ? vaTransValue : transValue))
                    if sellWidth > 0
                        box.new(barAnchor + buyWidth, binH, barAnchor + buyWidth + sellWidth, binL, na, 0, bgcolor = color.new(bearColorInput, inVA ? vaTransValue : transValue))
                else
                    if profWidth > 0
                        box.new(barAnchor, binH, barAnchor + profWidth, binL, na, 0, bgcolor = color.new(baseColorInput, inVA ? vaTransValue : transValue))

            if volRatio >= 0.99 and showPocInput and showPocFillInput
                box.new(barAnchor, binH, barAnchor + profWidth, binL, na, 0, bgcolor = POC_FILL)

        // ─── POC / VA / VWAP LINES ───
        if showPocInput
            line.new(lineStartIdx, pocPrice, lineEndIdx, pocPrice, color = pocColorInput, width = 2, style = line.style_solid)
            label.new(labelOffset, pocPrice, "POC: " + str.tostring(pocPrice, format.mintick), style = labelStyle, color = #2979FF, textcolor = color.white, size = size.small)

        if showVaInput and totalVol > 0
            line.new(lineStartIdx, vaH, lineEndIdx, vaH, color = vaHighColor, style = line.style_dashed, width = 2)
            label.new(labelOffset, vaH, "VAH: " + str.tostring(vaH, format.mintick), style = labelStyle, color = #2979FF, textcolor = color.white, size = size.small)
            line.new(lineStartIdx, vaL, lineEndIdx, vaL, color = vaLowColor, style = line.style_dashed, width = 2)
            label.new(labelOffset, vaL, "VAL: " + str.tostring(vaL, format.mintick), style = labelStyle, color = #FF9100, textcolor = color.white, size = size.small)

        // ✅ VWAP line + label
        if showVwapInput and totalVol > 0
            line.new(lineStartIdx, rangeVwap, lineEndIdx, rangeVwap, color = vwapColorInput, style = line.style_solid, width = 2)
            label.new(labelOffset, rangeVwap, "VWAP: " + str.tostring(rangeVwap, format.mintick), style = labelStyle, color = #AB47BC, textcolor = color.white, size = size.small)

        if showLabelsInput
            string deltaLblStr = str.tostring(lastDelta, "#.0") + "%"
            string tipText = "Range: " + str.tostring(barSpan) + " Bars\nTotal Vol: " + str.tostring(totalVol, format.volume) + "\nDelta: " + deltaLblStr + "\nPOC: " + str.tostring(pocPrice, format.mintick) + "\nVWAP: " + str.tostring(rangeVwap, format.mintick)
            label.new(labelOffset, rangeLow, "Vol: " + str.tostring(totalVol, format.volume), style = labelStyle, color = TRANSPARENT, textcolor = TEXT_COLOR, size = size.normal, tooltip = tipText)

        // ══════════════════════════════════════
        // 📈 PEAK BOXES (S/D colored + active tracking)
        // ══════════════════════════════════════
        if showPeaksInput and maxVol > 0
            array<int> peakBins = array.new<int>()

            for k = 0 to bins - 1
                float v = volBins.get(k)
                if v / maxVol < PEAK_MIN_RATIO
                    continue
                bool isPeak = true
                for j = 1 to PEAK_LOOKBACK
                    int kl = k - j
                    int kr = k + j
                    if kl >= 0 and volBins.get(kl) > v
                        isPeak := false
                        break
                    if kr < bins and volBins.get(kr) > v
                        isPeak := false
                        break
                if isPeak
                    peakBins.push(k)

            // ═══════════════════════════════════════
            // 🧩 CLUSTERING: among peaks closer than X bins,
            //     keep only the highest-volume one
            // ═══════════════════════════════════════
            int pRawN = peakBins.size()
            if pRawN > 0
                int clusterGap = peakClusterGapInput
                array<int> filteredPeakBins = array.new<int>()

                int clusterStart = 0
                for ci = 1 to pRawN
                    bool isLast = ci >= pRawN
                    bool gapFound = false
                    if not isLast
                        gapFound := (peakBins.get(ci) - peakBins.get(ci - 1)) > clusterGap

                    if isLast or gapFound
                        int cEnd = isLast ? pRawN - 1 : ci - 1
                        int   bestIdx = clusterStart
                        float bestVol = volBins.get(peakBins.get(clusterStart))
                        if cEnd > clusterStart
                            for cj = clusterStart + 1 to cEnd
                                float vj = volBins.get(peakBins.get(cj))
                                if vj > bestVol
                                    bestVol := vj
                                    bestIdx := cj
                        filteredPeakBins.push(peakBins.get(bestIdx))
                        clusterStart := ci

                peakBins := filteredPeakBins

            int pN = peakBins.size()

            int refsSize = peakBoxRefs.size()
            if refsSize < pN
                for i = refsSize to pN - 1
                    peakBoxRefs.push(box.new(bar_index, close, bar_index, close))
                    peakLabelRefs.push(label.new(bar_index, close, ""))

            int pRight = bar_index + peakExtendInput

            // S/D coloring reference: last close
            float refPrice = close

            // ─── Compute "last touch bar" for each peak bin ───
            array<int> peakLastTouch = array.new<int>()
            for i = 0 to pN - 1
                int   pb   = peakBins.get(i)
                float pTop = rangeLow + (pb + 1) * step
                float pBot = rangeLow + pb * step
                int lastT  = startIdx
                for j = 0 to barSpan
                    int biAbs  = finalEnd - j
                    int offset = bar_index - biAbs
                    float bh = nz(high[offset], close[offset])
                    float bl = nz(low[offset],  close[offset])
                    if bh >= pBot and bl <= pTop
                        lastT := biAbs
                        break
                peakLastTouch.push(lastT)

            // ─── Pick 2 boxes above and 2 boxes below current value ───
            array<int> aboveIdx = array.new<int>()
            array<int> belowIdx = array.new<int>()
            for i = 0 to pN - 1
                int   pb   = peakBins.get(i)
                float pTop = rangeLow + (pb + 1) * step
                float pBot = rangeLow + pb * step
                if pBot > refPrice
                    aboveIdx.push(i)
                else if pTop < refPrice
                    belowIdx.push(i)

            // Sort aboveIdx by pBot ascending (nearest first)
            int aN = aboveIdx.size()
            if aN > 1
                for ii = 0 to aN - 2
                    for jj = 0 to aN - 2 - ii
                        int ia = aboveIdx.get(jj)
                        int ib = aboveIdx.get(jj + 1)
                        float pa  = rangeLow + peakBins.get(ia) * step
                        float pb2 = rangeLow + peakBins.get(ib) * step
                        if pa > pb2
                            aboveIdx.set(jj, ib)
                            aboveIdx.set(jj + 1, ia)

            // Sort belowIdx by pTop descending (nearest first)
            int bN = belowIdx.size()
            if bN > 1
                for ii = 0 to bN - 2
                    for jj = 0 to bN - 2 - ii
                        int ia = belowIdx.get(jj)
                        int ib = belowIdx.get(jj + 1)
                        float pa  = rangeLow + (peakBins.get(ia) + 1) * step
                        float pb2 = rangeLow + (peakBins.get(ib) + 1) * step
                        if pa < pb2
                            belowIdx.set(jj, ib)
                            belowIdx.set(jj + 1, ia)

            // Active box set
            array<bool> isActiveBox = array.new<bool>(pN, false)
            if aN > 0
                int aLimit = math.min(2, aN) - 1
                for ii = 0 to aLimit
                    isActiveBox.set(aboveIdx.get(ii), true)
            if bN > 0
                int bLimit = math.min(2, bN) - 1
                for ii = 0 to bLimit
                    isActiveBox.set(belowIdx.get(ii), true)

            if pN > 0
                for i = 0 to pN - 1
                    int   pb   = peakBins.get(i)
                    float pTop = rangeLow + (pb + 1) * step
                    float pBot = rangeLow + pb * step
                    box   bx   = peakBoxRefs.get(i)
                    label lb   = peakLabelRefs.get(i)

                    bool priceInside = (pBot <= refPrice) and (refPrice <= pTop)
                    bool isSupply    = (not priceInside) and (pBot > refPrice)
                    bool isDemand    = (not priceInside) and (pTop < refPrice)

                    color labelCol = peakBorderInput
                    string sideStr = "·"

                    if sdColorPeaksInput
                        if isSupply
                            labelCol := supplyPeakColorInput
                            sideStr  := "SUPPLY"
                        else if isDemand
                            labelCol := demandPeakColorInput
                            sideStr  := "DEMAND"
                        else
                            sideStr  := "PRICE-IN"

                    color bgCol  = color.new(peakColorInput, 70)
                    color brdCol = peakBorderInput

                    if priceInside
                        bgCol  := color.new(color.gray, 70)
                        brdCol := color.gray
                    else if sdColorPeaksInput
                        if isSupply
                            bgCol  := color.new(supplyPeakColorInput, 70)
                            brdCol := supplyPeakColorInput
                        else if isDemand
                            bgCol  := color.new(demandPeakColorInput, 70)
                            brdCol := demandPeakColorInput

                    int rightEdge = isActiveBox.get(i) ? pRight : peakLastTouch.get(i)

                    box.set_left(bx, startIdx)
                    box.set_right(bx, rightEdge)
                    box.set_top(bx, pTop)
                    box.set_bottom(bx, pBot)
                    box.set_border_color(bx, brdCol)
                    box.set_border_width(bx, 1)
                    box.set_border_style(bx, line.style_solid)
                    box.set_bgcolor(bx, bgCol)

                    if peakShowLabelInput
                        string lblTxt = sdColorPeaksInput ? (sideStr + " " + str.tostring((pTop + pBot) / 2, format.mintick)) : ("PEAK " + str.tostring((pTop + pBot) / 2, format.mintick))
                        label.set_xy(lb, rightEdge, (pTop + pBot) / 2)
                        label.set_text(lb, lblTxt)
                        label.set_color(lb, color.new(labelCol, 15))
                        label.set_textcolor(lb, color.white)
                        label.set_style(lb, label.style_label_left)
                        label.set_size(lb, size.tiny)
                    else
                        label.set_text(lb, "")
                        label.set_color(lb, HIDDEN)
                        label.set_textcolor(lb, HIDDEN)

            if refsSize > pN
                for i = pN to refsSize - 1
                    box.set_bgcolor(peakBoxRefs.get(i), HIDDEN)
                    box.set_border_color(peakBoxRefs.get(i), HIDDEN)
                    label.set_text(peakLabelRefs.get(i), "")
                    label.set_color(peakLabelRefs.get(i), HIDDEN)
                    label.set_textcolor(peakLabelRefs.get(i), HIDDEN)
````
