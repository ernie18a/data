# QX Live Footprint Heatmap 3m v0.5.5

- url: https://www.tradingview.com/script/ZTkPveUp-QX-Live-Footprint-Heatmap-3m-v0-5-5/
- type: indicator
- pine_id: PUB;e5abe63edc6540af9ae139d52cc047b5
- version: 1.0

## Description

**QX · Live Footprint Heatmap 3m**

QX Live Footprint Heatmap organizes recent traded volume into price bands beside the chart. Designed for standard 3-minute candles, it combines a rolling footprint profile, developing volume updates, directional activity, and historical reaction zones to help users examine where trading has concentrated and how price behaves around those areas.

The default window includes 60 candles—approximately three hours—including the developing candle. As new feed updates arrive, the indicator refreshes the current candle’s contribution without repeatedly adding its cumulative volume. Completed candles remain in the profile until they leave the selected window.

The display separates volume concentration from directional activity:

- **Light blue:** buy-classified volume dominance.
- **Violet:** sell-classified volume dominance.
- **Gray:** relatively balanced activity.
- **Brighter bands:** greater total traded volume relative to the busiest level.
- **Side profile:** bar length represents total volume at each displayed band.
- **Activity highlights:** temporarily emphasize levels whose developing footprint volume has increased.

Optional recency weighting gives newer activity more influence over band colors. Brightness continues to represent raw rolling volume, while label percentages use the unweighted buy/sell totals. This allows recent directional changes to appear without replacing the underlying volume measurements.

BUY-DOM and SELL-DOM labels identify the busiest displayed bands that meet the configured volume and dominance thresholds. Labels show the dominance gap in percentage points: for example, 65% buy volume and 35% sell volume produce **+30 pp versus sell**. This measures classified volume distribution, rather than a probability of price moving in that direction.

Each dominance label also shows **PRICE ABOVE**, **PRICE BELOW**, or **TESTING NOW**, describing the current price’s position relative to the band. Tooltips provide buy volume, sell volume, delta, side percentages, relative activity, and observed native diagonal imbalances. Bands can remain visible without labels when they fall outside the label limits or qualification filters.

The indicator includes additional context:

- **Current-candle POC:** a white line marking the center of the candle’s highest-volume footprint row.
- **Current-candle value area:** dotted boundaries based on the selected volume percentage.
- **S? and R? markers:** possible reaction areas ranked using volume, freshness, directional bias, and location relative to price.
- **Historical reaction zones:** separately calculated areas derived from confirmed price pivots and OHLCV history.

Historical zones use ATR-based widths and an evidence score incorporating relative volume, age, prior reactions, proximity, trend alignment, and available current footprint context. Zones can merge, expire, or become invalid after two qualifying closes beyond their far boundary. Nearby zones may be grouped visually, with individual details preserved in tooltips. Evidence scores are heuristic rankings, not calibrated probabilities.

Row sizing supports manual price ticks, quote-price units, and automatic five-unit bands for BTC markets quoted in USD, USDT, or USDC. Users can also adjust the rolling window, volume filters, color weighting, label limits, panel dimensions, and historical-zone settings.

A data-status dashboard reports footprint coverage, current buy/sell volume and delta, feed updates, and missing or rejected data. Incomplete windows suppress dominance and S?/R? labels. Missing candles retain their place in the window instead of being replaced with older observations.

Use standard **3-minute candles** and allow space to the right of price. TradingView currently requires a **Premium or Ultimate plan** for scripts using native footprint requests. Its buy/sell classification is based on intrabar price movement. [TradingView footprint documentation](https://www.tradingview.com/pine-script-docs/concepts/other-timeframes-and-data/#requestfootprint)

The heatmap represents classified traded volume; it does not reveal resting orders or guarantee exact aggressor-side execution data. Buy or sell dominance alone does not establish absorption or confirm support and resistance. Developing values can change intrabar and after reloading. Activity highlights advance with incoming feed updates, and their changes can include feed revisions.

## Source Code

````pine
//@version=6
indicator("QX · Live Footprint Heatmap 3m v0.5.5", overlay = true, scale = scale.none, max_boxes_count = 200, max_lines_count = 40, max_labels_count = 32, max_bars_back = 600, calc_bars_count = 600)
// Traded-volume heatmap, NOT resting liquidity / DOM or exact aggressor tape.
// Indicators execute on incoming realtime feed updates automatically.
// One footprint request; the developing bar is replaced, never accumulated twice.

string rowMode = input.string("Auto BTC / manual others", "Row sizing", options = ["Auto BTC / manual others", "Manual ticks", "Price units"])
float priceRowSize = input.float(5.0, "Row size in quote-price units", minval = 0.00000001,
     tooltip = "Used in Price units mode. On BTCUSDT, 5 means a 5 USDT price band, not 5 ticks.")
int manualRowTicks = input.int(1, "Manual price ticks per row", minval = 1, maxval = 100000,
     tooltip = "1 means one minimum PRICE increment, not one transaction per update. Increase if too many rows are reported. Native intrabar resolution is controlled by TradingView.")
bool btcDollarQuote = syminfo.basecurrency == "BTC" and (syminfo.currency == "USDT" or syminfo.currency == "USD" or syminfo.currency == "USDC")
// Symbol metadata and inputs keep ticks_per_row simple, as required by footprint.
// Fixed per run: no ATR-driven historical rebinning or data-dependent requests.
int rowTicks = rowMode == "Price units" ? int(math.max(1.0, math.min(1000000.0, math.ceil(priceRowSize / syminfo.mintick)))) : rowMode == "Auto BTC / manual others" and btcDollarQuote ? int(math.max(1.0, math.min(1000000.0, math.ceil(5.0 / syminfo.mintick)))) : manualRowTicks
int windowBars = input.int(60, "Recent 3m candles (60 = 180 minutes)", minval = 1, maxval = 90, tooltip = "Includes the developing 3m candle. The duration is nominal and is shorter during the open candle; session gaps can increase elapsed clock time.")
int visibleLevels = input.int(80, "Maximum heatmap bands", minval = 5, maxval = 80)
int belowAllocation = input.int(60, "Band allowance below price (%)", minval = 10, maxval = 90)
float belowHeat = input.float(1, "Minimum heat below price (% of busiest level)", minval = 0.1, maxval = 95, step = 0.5)
float supportRange = input.float(12, "Historical support search distance / ATR", minval = 1, maxval = 30)
int supportLevels = input.int(6, "Maximum historical support zones", minval = 1, maxval = 8)
float supportEvidence = input.float(25, "Minimum support evidence / 100", minval = 0, maxval = 90)
float minimumHeat = input.float(5, "Minimum heat (% of busiest level)", minval = 1, maxval = 95, step = 5)
float valueAreaPct = input.float(70, "Current candle value area (%)", minval = 1, maxval = 100)
float imbalancePct = input.float(300, "Diagonal imbalance (%)", minval = 100, maxval = 1000, step = 50)
bool showReferences = input.bool(true, "Show current candle POC / value area")
bool showCandidates = input.bool(true, "Mark possible support / resistance")
bool showParticipants = input.bool(true, "Label strong buyer / seller levels")
int participantLimit = input.int(3, "Maximum labels per side", minval = 1, maxval = 10)
float participantHeat = input.float(30, "Level volume minimum (% of busiest band)", minval = 1, maxval = 100)
float participantShare = input.float(60, "Minimum buyer / seller share (%)", minval = 56, maxval = 100,
     tooltip = "60 means at least 60% of the level's volume is classified on that side. This measures traded volume, not the number of traders or waiting orders.")
bool adaptiveFilter = input.bool(true, "Adaptive participant volume filter")
float volumePercentile = input.float(75, "Participant volume percentile", minval = 50, maxval = 99)
float halfLifeBars = input.float(5, "Activity half-life (3m bars)", minval = 1, maxval = 30)
bool recentColors = input.bool(true, "Use recency-weighted buy/sell colors")
bool showMemory = input.bool(true, "Show historical reaction projections")
int pivotSpan = input.int(3, "Historical pivot confirmation bars", minval = 2, maxval = 10)
int memoryAge = input.int(300, "Maximum zone age (3m bars)", minval = 30, maxval = 500)
float zoneAtrWidth = input.float(0.15, "Historical zone half-width / ATR", minval = 0.05, maxval = 0.5)
float projectionRange = input.float(4, "Maximum projection distance / ATR", minval = 1, maxval = 10)
int projectionCount = input.int(2, "Projected zones per side", minval = 1, maxval = 2)
float minimumEvidence = input.float(40, "Minimum projection evidence / 100", minval = 0, maxval = 90)
float heatContrast = input.float(1.5, "Heatmap contrast (higher dims quiet rows)", minval = 0.5, maxval = 3, step = 0.1)
float mergeGapAtr = input.float(0.10, "Historical zone merge gap / ATR", minval = 0, maxval = 0.5, step = 0.05)
float labelSpacingAtr = input.float(0.30, "Label spacing / ATR", minval = 0.1, maxval = 2, step = 0.05)
float displayGroupAtr = input.float(0.25, "Historical display grouping gap / ATR", minval = 0, maxval = 2, step = 0.05)
string labelSizeChoice = input.string("Normal", "Level label text size", options = ["Small", "Normal", "Large"])
string hudSizeChoice = input.string("Normal", "Dashboard text size", options = ["Small", "Normal", "Large"])
string levelTextSize = labelSizeChoice == "Large" ? size.large : labelSizeChoice == "Small" ? size.small : size.normal
string hudTextSize = hudSizeChoice == "Large" ? size.large : hudSizeChoice == "Small" ? size.small : size.normal
float labelSizeFactor = labelSizeChoice == "Large" ? 1.6 : labelSizeChoice == "Normal" ? 1.25 : 1.0
bool showNumbers = input.bool(false, "Show volume inside bands")
int panelGap = input.int(3, "Gap after current candle (bars)", minval = 1, maxval = 50)
int panelWidth = input.int(25, "Heatmap panel width (bars)", minval = 5, maxval = 200)
bool showSideProfile = input.bool(true, "Show buy/sell volume profile beside heatmap")
int profileWidth = input.int(10, "Side profile width (bars)", minval = 3, maxval = 30)
bool flashActivity = input.bool(true, "Flash updated price levels")
int flashMilliseconds = input.int(1200, "Activity highlight (milliseconds)", minval = 200, maxval = 5000, step = 100,
     tooltip = "A highlight fades on subsequent feed updates. Pine has no independent animation timer. Increased footprint volume can include feed revisions, not just a new trade.")

const int MAX_NATIVE_ROWS = 1000
const int MAX_PROFILE_BINS = 6000
float rowWidth = rowTicks * syminfo.mintick

type HeatRow
    int key
    float buy
    float sell
    int imbalance

type HeatFrame
    array<HeatRow> rows
    bool valid
    int index
    string problem
    int buyImbalances = 0
    int sellImbalances = 0

type HeatBin
    varip float buy = 0.0
    varip float sell = 0.0
    varip float recentBuy = 0.0
    varip float recentSell = 0.0
    varip bool buyImbalance = false
    varip bool sellImbalance = false

// Hue represents classified buy/sell dominance; brightness represents volume.
// Force every price drawing onto the main chart scale to prevent detached levels.
f_heat_color(float strength, float share) =>
    share > 0.10 ? color.from_gradient(strength, 0.0, 1.0, #233E50, #ADDFFF) : share < -0.10 ? color.from_gradient(strength, 0.0, 1.0, #241530, #7040A0) : color.from_gradient(strength, 0.0, 1.0, #252525, #B8B8B8)

f_finite(float x) =>
    not na(x) and math.abs(x) < 1e100

f_snap(float x) =>
    math.abs(x - math.round(x)) <= 1e-7 ? float(math.round(x)) : x

// Copy primitives, not footprint handles. Uniform allocation within a native
// row conserves volume when its boundaries straddle the fixed zero-origin grid.
f_frame(footprint fp, float width) =>
    HeatFrame frame = HeatFrame.new(array.new<HeatRow>(), false, bar_index, "NO FOOTPRINT")
    if not na(fp)
        array<volume_row> native = fp.rows()
        float total = fp.total_volume()
        float buy = fp.buy_volume()
        float sell = fp.sell_volume()
        float delta = fp.delta()
        bool valid = native.size() > 0 and native.size() <= MAX_NATIVE_ROWS and f_finite(total) and total > 0 and f_finite(buy) and f_finite(sell) and buy >= 0 and sell >= 0 and f_finite(delta)
        frame.problem := native.size() > MAX_NATIVE_ROWS ? "INCREASE TICKS / ROW" : "INVALID FOOTPRINT"
        float buySum = 0.0
        float sellSum = 0.0
        if valid
            valid := math.abs((buy + sell) / total - 1.0) <= 1e-6 and math.abs((buy - sell - delta) / total) <= 1e-6
        if valid
            for row in native
                float lo = row.down_price()
                float hi = row.up_price()
                // Permit a single quoted price at one-tick resolution.
                hi := hi == lo and rowTicks == 1 ? lo + syminfo.mintick : hi
                float b = row.buy_volume()
                float a = row.sell_volume()
                float v = row.total_volume()
                float d = row.delta()
                bool good = f_finite(lo) and f_finite(hi) and hi > lo and f_finite(b) and f_finite(a) and b >= 0 and a >= 0 and f_finite(v) and v >= 0 and f_finite(d)
                if not good
                    valid := false
                    break
                if (v == 0 and (b != 0 or a != 0 or d != 0)) or (v > 0 and (math.abs((b + a) / v - 1.0) > 1e-6 or math.abs((b - a - d) / v) > 1e-6))
                    valid := false
                    break
                float bottom = f_snap(lo / width)
                float top = f_snap(hi / width)
                if math.abs(bottom) >= 9e15 or math.abs(top) >= 9e15 or top <= bottom
                    valid := false
                    break
                int first = int(math.floor(bottom))
                int last = int(math.ceil(top)) - 1
                if last < first or last - first > 2
                    valid := false
                    break
                frame.buyImbalances += row.has_buy_imbalance() ? 1 : 0
                frame.sellImbalances += row.has_sell_imbalance() ? 1 : 0
                int flag = (row.has_buy_imbalance() ? 1 : 0) + (row.has_sell_imbalance() ? 2 : 0)
                float assignedBuy = 0.0
                float assignedSell = 0.0
                if b + a > 0
                    for key = first to last
                        float fraction = math.max(0.0, math.min(top, key + 1.0) - math.max(bottom, float(key))) / (top - bottom)
                        float partBuy = key == last ? math.max(0.0, b - assignedBuy) : b * fraction
                        float partSell = key == last ? math.max(0.0, a - assignedSell) : a * fraction
                        frame.rows.push(HeatRow.new(key, partBuy, partSell, flag))
                        assignedBuy += partBuy
                        assignedSell += partSell
                buySum += b
                sellSum += a
            valid := valid and math.abs((buySum - buy) / total) <= 1e-6 and math.abs((sellSum - sell) / total) <= 1e-6
        frame.valid := valid
        if valid
            frame.problem := ""
        else
            frame.rows.clear()
    frame

f_add(map<int, HeatBin> profile, HeatFrame frame) =>
    bool okay = true
    if frame.valid
        for row in frame.rows
            if not profile.contains(row.key)
                if profile.size() >= MAX_PROFILE_BINS
                    okay := false
                    break
                profile.put(row.key, HeatBin.new())
            HeatBin bin = profile.get(row.key)
            bin.buy += row.buy
            bin.sell += row.sell
            float weight = math.pow(0.5, math.max(0, bar_index - frame.index) / halfLifeBars)
            bin.recentBuy += row.buy * weight
            bin.recentSell += row.sell * weight
            bin.buyImbalance := bin.buyImbalance or row.imbalance == 1 or row.imbalance == 3
            bin.sellImbalance := bin.sellImbalance or row.imbalance == 2 or row.imbalance == 3
    okay

if barstate.isfirst and (not chart.is_standard or not timeframe.isminutes or timeframe.multiplier != 3)
    runtime.error("Use standard 3-minute candles. The live footprint still updates during the open candle; it does not wait three minutes to redraw.")

// Full native API: bar totals, buy/sell/delta, rows, POC, VAH/VAL and diagonal imbalances.
footprint fp = request.footprint(rowTicks, valueAreaPct, imbalancePct)
HeatFrame current = f_frame(fp, rowWidth)
int currentBuyImbalances = current.valid ? current.buyImbalances : 0
int currentSellImbalances = current.valid ? current.sellImbalances : 0
float currentBuy = current.valid ? fp.buy_volume() : na
float currentSell = current.valid ? fp.sell_volume() : na
float currentDelta = current.valid ? fp.delta() : na
float currentTotal = current.valid ? fp.total_volume() : na
volume_row pocRow = current.valid ? fp.poc() : na
volume_row vahRow = current.valid ? fp.vah() : na
volume_row valRow = current.valid ? fp.val() : na
float currentPoc = not na(pocRow) ? math.avg(pocRow.down_price(), pocRow.up_price()) : na
float currentVah = not na(vahRow) ? vahRow.up_price() : na
float currentVal = not na(valRow) ? valRow.down_price() : na

// This varip telemetry never adds volume to the
// rolling profile. Tick-by-tick highlights cannot be reconstructed after reload.
varip int observedBar = na
varip int realtimeUpdates = 0
varip int lastUpdateTime = na
varip bool haveLiveBaseline = false
varip map<int, float> previousLiveVolume = map.new<int, float>()
varip map<int, int> activityTime = map.new<int, int>()
if barstate.isrealtime
    if na(observedBar) or observedBar != bar_index
        observedBar := bar_index
        realtimeUpdates := 0
        previousLiveVolume.clear()
    realtimeUpdates += 1
    lastUpdateTime := timenow
    if flashActivity and current.valid
        map<int, float> liveVolume = map.new<int, float>()
        for row in current.rows
            liveVolume.put(row.key, nz(liveVolume.get(row.key)) + row.buy + row.sell)
        for key in liveVolume.keys()
            float amount = liveVolume.get(key)
            if haveLiveBaseline and amount > nz(previousLiveVolume.get(key))
                activityTime.put(key, timenow)
        previousLiveVolume := liveVolume
        haveLiveBaseline := true
    else if not current.valid
        // Recovery establishes a new baseline, not fictitious new executions.
        previousLiveVolume.clear()
        activityTime.clear()
        haveLiveBaseline := false
    for key in activityTime.keys()
        if timenow - activityTime.get(key) > flashMilliseconds
            activityTime.remove(key)

var array<HeatFrame> history = array.new<HeatFrame>()
// Intrabar-persistent cache contains ONLY completed frames. It is rebuilt once
// per chart bar from committed history, including missing-frame positions.
// Every live evaluation copies its primitive fields into independent objects.
varip map<int, HeatBin> closedCache = map.new<int, HeatBin>()
varip int cacheBar = na
varip int cachedAvailable = 0
varip int cachedMissing = 0
varip int cachedRejected = 0
varip bool cachedOkay = true
if barstate.islast and (na(cacheBar) or cacheBar != bar_index)
    closedCache.clear()
    cachedAvailable := 0
    cachedMissing := 0
    cachedRejected := 0
    cachedOkay := true
    for frame in history
        cachedAvailable += frame.valid ? 1 : 0
        cachedMissing += not frame.valid and frame.problem == "NO FOOTPRINT" ? 1 : 0
        cachedRejected += not frame.valid and frame.problem != "NO FOOTPRINT" ? 1 : 0
        if cachedOkay
            cachedOkay := f_add(closedCache, frame)
    cacheBar := bar_index
var array<box> bands = array.new<box>()
var array<line> references = array.new<line>()
var array<label> candidates = array.new<label>()
var table hud = table.new(position.bottom_right, 1, 6, bgcolor = color.new(color.black, 15))

if barstate.islast
    // Right-of-price display of the latest rolling profile, not a forecast or
    // historical order-book heatmap. No drawing covers the current candle.
    for b in bands
        box.delete(b)
    bands.clear()
    for l in references
        line.delete(l)
    references.clear()
    for l in candidates
        label.delete(l)
    candidates.clear()

    map<int, HeatBin> profile = map.new<int, HeatBin>()
    int available = cachedAvailable + (current.valid ? 1 : 0)
    bool capacityOkay = cachedOkay
    for key in closedCache.keys()
        HeatBin saved = closedCache.get(key)
        profile.put(key, saved.copy())
    if capacityOkay
        capacityOkay := f_add(profile, current)
    bool complete = capacityOkay and available == windowBars
    array<int> keys = profile.keys()
    array<float> volumes = array.new<float>()
    for key in keys
        HeatBin bin = profile.get(key)
        volumes.push(bin.buy + bin.sell)
    array<int> rank = array.sort_indices(volumes, order.descending)
    float peak = volumes.size() > 0 ? volumes.get(rank.get(0)) : 0.0
    float adaptiveMinimum = peak * participantHeat * 0.01
    if adaptiveFilter and volumes.size() > 0
        int percentileAt = int(math.floor((volumes.size() - 1) * (1.0 - volumePercentile * 0.01)))
        adaptiveMinimum := math.max(adaptiveMinimum, volumes.get(rank.get(percentileAt)))
    float bestSupportScore = -1.0
    float bestResistanceScore = -1.0
    int left = bar_index + panelGap
    int right = left + panelWidth
    int profileStart = right + 2
    int labelX = showSideProfile ? profileStart + profileWidth + 2 : right + 2
    float support = na
    float resistance = na
    int shown = 0
    int shownBelow = 0
    int shownOther = 0
    int belowBudget = int(math.round(visibleLevels * belowAllocation * 0.01))
    int otherBudget = visibleLevels - belowBudget
    int buyerLabels = 0
    int sellerLabels = 0
    array<int> participantKeys = array.new<int>()
    if capacityOkay and peak > 0
        for at in rank
            float total = volumes.get(at)
            if shown >= visibleLevels or total < peak * math.min(minimumHeat, belowHeat) * 0.01
                break
            int key = keys.get(at)
            HeatBin bin = profile.get(key)
            float lo = key * rowWidth
            float hi = (key + 1) * rowWidth
            bool belowPrice = hi < close
            bool budgetAvailable = belowPrice ? shownBelow < belowBudget : shownOther < otherBudget
            float requiredHeat = belowPrice ? belowHeat : minimumHeat
            if not budgetAvailable or total < peak * requiredHeat * 0.01
                continue
            float recentTotal = bin.recentBuy + bin.recentSell
            float recentShare = recentTotal > 0 ? (bin.recentBuy - bin.recentSell) / recentTotal : 0.0
            float share = recentColors ? recentShare : (bin.buy - bin.sell) / total
            float intensity = math.pow(total / peak, heatContrast)
            color tone = f_heat_color(intensity, share)
            int transparency = int(math.round(65.0 - 55.0 * intensity))
            color edge = color.new(tone, 100)
            bool activeNow = flashActivity and barstate.isrealtime and current.valid and activityTime.contains(key) and timenow - activityTime.get(key) <= flashMilliseconds
            transparency := activeNow ? 0 : transparency
            edge := activeNow ? color.white : edge
            string bandText = showNumbers ? "B " + str.tostring(bin.buy, format.volume) + " | S " + str.tostring(bin.sell, format.volume) : ""
            // Small visual gutter separates adjacent rows; calculations retain
            // the full original bin boundaries and all original volume.
            float gutter = rowWidth * 0.06
            bands.push(box.new(left, hi - gutter, right, lo + gutter, border_color = edge, border_width = 1, bgcolor = color.new(tone, transparency), text = bandText, text_color = share >= -0.10 and intensity >= 0.65 ? color.black : color.white, text_size = size.tiny, text_halign = text.align_right, force_overlay = true))
            if showSideProfile
                int length = math.max(1, int(math.round(profileWidth * total / peak)))
                color sideColor = share > 0.10 ? #ADDFFF : share < -0.10 ? #7040A0 : color.gray
                bands.push(box.new(profileStart, hi - gutter, profileStart + length, lo + gutter, border_color = color.new(sideColor, 100), bgcolor = color.new(sideColor, 20), force_overlay = true))
            // Rank is descending total volume: select the busiest qualifying
            // displayed bands independently for buyers and sellers.
            float buyerPct = 100.0 * bin.buy / total
            float sellerPct = 100.0 * bin.sell / total
            bool buyerLevel = buyerPct >= participantShare
            bool sellerLevel = sellerPct >= participantShare
            bool room = buyerLevel ? buyerLabels < participantLimit : sellerLevel and sellerLabels < participantLimit
            if showParticipants and complete and total >= adaptiveMinimum and room
                float levelPrice = math.avg(lo, hi)
                string sideName = buyerLevel ? "BUY-DOM" : "SELL-DOM"
                float dominanceGap = math.abs(buyerPct - sellerPct)
                string response = close > hi ? "PRICE ABOVE" : close < lo ? "PRICE BELOW" : "TESTING NOW"
                string levelText = sideName + " " + str.tostring(levelPrice, format.mintick) + " · " + "+" + str.tostring(dominanceGap, "#.0") + " pp vs " + (buyerLevel ? "sell" : "buy") + "\n" + response
                string detail = "Buy share: " + str.tostring(buyerPct, "#.0") + "% | Sell share: " + str.tostring(sellerPct, "#.0") + "%\nDominance gap: " + str.tostring(dominanceGap, "#.0") + " percentage points (pp). Computed from raw rolling volume, not recency-weighted color.\nTraded-volume concentration, not trader counts or resting orders.\nBuy: " + str.tostring(bin.buy, format.volume) + " | Sell: " + str.tostring(bin.sell, format.volume) + "\nDelta: " + str.tostring(bin.buy - bin.sell, format.volume) + "\nVolume relative to busiest band: " + str.tostring(100.0 * total / peak, "#.0") + "%\nDeveloping rolling-window level; can change intrabar. Directional activity alone does not prove support, resistance or absorption."
                detail += "\nRecency-weighted delta: " + str.tostring(100.0 * recentShare, "#.0") + "%\nPrice position: " + response + " (not a confirmed retest).\nNative diagonal imbalance observed in window: " + (bin.buyImbalance ? "BUY " : "") + (bin.sellImbalance ? "SELL" : "")
                candidates.push(label.new(labelX, levelPrice, levelText, style = label.style_label_left, color = buyerLevel ? #ADDFFF : #7040A0, textcolor = buyerLevel ? color.black : color.white, size = levelTextSize, tooltip = detail, force_overlay = true))
                participantKeys.push(key)
                buyerLabels += buyerLevel ? 1 : 0
                sellerLabels += sellerLevel ? 1 : 0
            // Candidate strength combines volume, recency and observed price
            // location. This is a ranking heuristic, never a probability.
            float freshness = recentTotal / total
            float supportScore = (total / peak) * (0.5 + 0.5 * freshness) * (1.0 + math.max(0.0, recentShare))
            float resistanceScore = (total / peak) * (0.5 + 0.5 * freshness) * (1.0 + math.max(0.0, -recentShare))
            if hi < close and supportScore > bestSupportScore
                support := math.avg(lo, hi)
                bestSupportScore := supportScore
            if lo > close and resistanceScore > bestResistanceScore
                resistance := math.avg(lo, hi)
                bestResistanceScore := resistanceScore
            shown += 1
            shownBelow += belowPrice ? 1 : 0
            shownOther += belowPrice ? 0 : 1
    if showCandidates and complete
        if not na(support) and not participantKeys.includes(int(math.floor(f_snap(support / rowWidth))))
            candidates.push(label.new(labelX, support, "S? " + str.tostring(support, format.mintick), style = label.style_label_left, color = color.new(#353535, 10), textcolor = color.white, size = levelTextSize, tooltip = "Highest-ranked displayed band wholly below price using volume, recency and buy bias. Possible reaction area, not resting bids or proven support.", force_overlay = true))
        if not na(resistance) and not participantKeys.includes(int(math.floor(f_snap(resistance / rowWidth))))
            candidates.push(label.new(labelX, resistance, "R? " + str.tostring(resistance, format.mintick), style = label.style_label_left, color = color.new(#353535, 10), textcolor = color.white, size = levelTextSize, tooltip = "Highest-ranked displayed band wholly above price using volume, recency and sell bias. Possible reaction area, not resting offers or proven resistance.", force_overlay = true))
    if showReferences and current.valid
        if not na(currentPoc)
            references.push(line.new(left, currentPoc, right, currentPoc, color = color.white, width = 2, force_overlay = true))
        if not na(currentVah)
            references.push(line.new(left, currentVah, right, currentVah, color = color.gray, style = line.style_dotted, force_overlay = true))
        if not na(currentVal)
            references.push(line.new(left, currentVal, right, currentVal, color = color.gray, style = line.style_dotted, force_overlay = true))
    bool coarseRows = rowTicks > 1 and profile.size() > 0 and profile.size() < 8 and available > 1
    string status = coarseRows and current.valid and capacityOkay ? "COARSE · LOWER TICKS / ROW" : not capacityOkay ? "INCREASE TICKS / ROW" : not current.valid ? current.problem + " · HIST ONLY" : complete ? barstate.isrealtime ? "LIVE" : "CLOSED" : "PARTIAL / WARMING"
    table.cell(hud, 0, 0, "QX FOOTPRINT HEAT · 3m · " + status, text_color = complete ? color.white : color.silver, text_size = hudTextSize)
    table.cell(hud, 0, 1, "Buy: light blue | Sell: violet | Hue: " + (recentColors ? "RECENT" : "RAW") + " | Brightness: raw volume", text_color = color.silver, text_size = hudTextSize)
    table.cell(hud, 0, 2, str.tostring(windowBars * 3) + "m nominal | Footprints " + str.tostring(available) + "/" + str.tostring(windowBars) + " | Bands " + str.tostring(shown) + " | Row " + str.tostring(rowWidth, format.mintick), text_color = color.silver, text_size = hudTextSize)
    table.cell(hud, 0, 3, current.valid ? "CURRENT B " + str.tostring(currentBuy, format.volume) + " | S " + str.tostring(currentSell, format.volume) + " | Δ " + str.tostring(currentDelta, format.volume) : "No current executed-volume estimate", text_color = color.silver, text_size = hudTextSize)
    string feedText = barstate.isrealtime ? (realtimeUpdates % 2 == 0 ? "● " : "○ ") + "Feed " + str.format_time(lastUpdateTime, "HH:mm:ss", syminfo.timezone) + " | " + str.tostring(realtimeUpdates) + " updates this bar" : "Historical snapshot · live activity flashes require realtime data"
    table.cell(hud, 0, 4, feedText, text_color = barstate.isrealtime ? color.white : color.silver, text_size = hudTextSize)
    int missingFrames = cachedMissing + (not current.valid and current.problem == "NO FOOTPRINT" ? 1 : 0)
    int rejectedFrames = cachedRejected + (not current.valid and current.problem != "NO FOOTPRINT" ? 1 : 0)
    int warmingFrames = math.max(0, windowBars - history.size() - 1)
    table.cell(hud, 0, 5, "Missing " + str.tostring(missingFrames) + " | Rejected " + str.tostring(rejectedFrames) + " | Warming " + str.tostring(warmingFrames), text_color = color.silver, text_size = hudTextSize)
    table.cell_set_tooltip(hud, 0, 5, "Missing = native request returned no footprint. Rejected = footprint failed validation or exceeded row limits; increase row size if needed. Warming = history slots not yet loaded. Coarser rows improve visibility and capacity, but cannot supply missing feed data. Participant labels require complete coverage.")
    table.cell_set_tooltip(hud, 0, 4, "Counts Pine realtime executions, not exchange trades. Time uses the symbol's exchange timezone. A white border/brightness flash means that level's current footprint volume increased since the previous valid update; revisions can also cause changes. If no feed update arrives, the display freezes rather than simulating activity. Flash state is visual only and does not survive reload.")
    table.cell_set_tooltip(hud, 0, 0, "Traded volume classified by TradingView from intrabar price movement. Not an order book or guaranteed aggressor-side tape. Light blue means classified buy dominance, violet means sell dominance, gray means balanced (absolute delta at most 10% of volume). This is order-flow bias, not a confirmed market regime. Brightness within each hue encodes relative rolling traded volume. Side bars show total volume by length with the same directional hues. Hue can use recency-weighted dominance while percentages always show raw volume share. BUYERS/SELLERS labels mark the busiest displayed bands meeting the adaptive volume and raw side-share filters; they measure classified volume, not trader counts. Neutral S?/R? labels identify location, not direction and are omitted where a participant label already exists. The right-side position is display space, not future liquidity. White line = current candle POC; gray dotted lines = current value area. Missing candles are not replaced with older candles; partial profiles do not publish S?/R? labels. Native row volume is allocated uniformly if it crosses the fixed heatmap grid. The current profile redraws intrabar and can change after reload.")


// OHLCV-derived zones are explicitly separate from measured footprint rows.
// A pivot enters memory only on confirmation; boundaries change only on a confirmed merge.
type ReactionZone
    float lo
    float hi
    int direction
    int born
    float prominence
    int touches = 0
    int rejections = 0
    int lastTouch = na
    bool touching = false
    int brokenCloses = 0

float memoryAtr = ta.atr(14)
float memoryTrend = ta.ema(close, 20)
float baselineVolume = ta.sma(volume, 30)
float pivotLow = ta.pivotlow(low, pivotSpan, pivotSpan)
float pivotHigh = ta.pivothigh(high, pivotSpan, pivotSpan)
var array<ReactionZone> zones = array.new<ReactionZone>()
var int memoryCommit = na
var array<box> projectedBoxes = array.new<box>()
var array<label> projectedLabels = array.new<label>()
var array<string> projectedDetails = array.new<string>()

// Merge connected same-side zones when a new confirmed pivot arrives.
// A changed boundary defines a new encounter history: never add old counts
// together, because the same price encounter may have touched both zones.
f_seed(array<ReactionZone> memory, float level, int direction, float width, float strength) =>
    int contained = -1
    if memory.size() > 0
        for i = 0 to memory.size() - 1
            ReactionZone zone = memory.get(i)
            if zone.direction == direction and level - width >= zone.lo and level + width <= zone.hi
                contained := i
                break
    if contained >= 0
        ReactionZone existing = memory.get(contained)
        existing.prominence := math.max(existing.prominence, strength)
    else
        float mergedLo = level - width
        float mergedHi = level + width
        float mergedStrength = strength
        int oldestBorn = bar_index
        float gap = memoryAtr * mergeGapAtr
        float maximumWidth = math.max(2.0 * width, memoryAtr)
        bool absorbed = true
        while absorbed
            absorbed := false
            if memory.size() > 0
                for i = memory.size() - 1 to 0
                    ReactionZone zone = memory.get(i)
                    float unionLo = math.min(mergedLo, zone.lo)
                    float unionHi = math.max(mergedHi, zone.hi)
                    if zone.direction == direction and zone.lo <= mergedHi + gap and zone.hi >= mergedLo - gap and unionHi - unionLo <= maximumWidth
                        mergedLo := unionLo
                        mergedHi := unionHi
                        mergedStrength := math.max(mergedStrength, zone.prominence)
                        oldestBorn := math.min(oldestBorn, zone.born)
                        memory.remove(i)
                        absorbed := true
        ReactionZone merged = ReactionZone.new(mergedLo, mergedHi, direction, oldestBorn, mergedStrength)
        merged.touching := high >= merged.lo and low <= merged.hi
        memory.push(merged)
        if memory.size() > 40
            int oldestIndex = 0
            for i = 1 to memory.size() - 1
                if memory.get(i).born < memory.get(oldestIndex).born
                    oldestIndex := i
            memory.remove(oldestIndex)
    // Explicit return: mutations above must not infer float vs ReactionZone.
    true

// Score is a bounded heuristic, NOT a calibrated probability. Directional
// Current-candle footprint bias is contextual, proximity-weighted, and omitted when missing.
f_evidence(ReactionZone zone, float atrValue, float liveDelta, bool validFlow) =>
    float ageWeight = math.pow(0.5, float(bar_index - zone.born) / (memoryAge * 0.5))
    float rejectionRate = zone.touches > 0 ? float(zone.rejections) / zone.touches : 0.0
    float distance = math.abs(close - math.avg(zone.lo, zone.hi)) / atrValue
    float proximity = math.exp(-distance)
    float alignment = validFlow ? math.max(-1.0, math.min(1.0, zone.direction * liveDelta)) : 0.0
    float trendAgreement = zone.direction * (close - memoryTrend) >= 0 ? 1.0 : 0.0
    float score = 25.0 * zone.prominence + 20.0 * ageWeight + 20.0 * rejectionRate + 10.0 * trendAgreement + 15.0 * proximity + 10.0 * alignment * proximity
    score -= math.min(15.0, zone.touches * 1.5)
    score -= validFlow ? 0.0 : 10.0
    math.max(0.0, math.min(100.0, score))

// Evaluate existing zones BEFORE seeding newly confirmed pivots. Consecutive
// touching candles form one encounter. Rejection requires a close away by 0.25 ATR.
if barstate.isconfirmed and (na(memoryCommit) or memoryCommit != bar_index)
    if zones.size() > 0
        for i = zones.size() - 1 to 0
            ReactionZone zone = zones.get(i)
            bool touch = high >= zone.lo and low <= zone.hi
            if touch and not zone.touching
                zone.touches += 1
                zone.lastTouch := bar_index
            bool reject = zone.direction == 1 ? close > zone.hi + memoryAtr * 0.25 : close < zone.lo - memoryAtr * 0.25
            if not na(zone.lastTouch) and bar_index - zone.lastTouch <= 3 and reject
                zone.rejections += 1
                zone.lastTouch := na
            bool broken = zone.direction == 1 ? close < zone.lo - memoryAtr * 0.1 : close > zone.hi + memoryAtr * 0.1
            zone.brokenCloses := broken ? zone.brokenCloses + 1 : 0
            zone.touching := touch
            if not na(zone.lastTouch) and bar_index - zone.lastTouch > 3
                zone.lastTouch := na
            if zone.brokenCloses >= 2 or bar_index - zone.born > memoryAge
                zones.remove(i)
    float seedWidth = math.max(syminfo.mintick, memoryAtr[pivotSpan] * zoneAtrWidth)
    float relativeVolume = not na(volume[pivotSpan]) and baselineVolume[pivotSpan] > 0 ? volume[pivotSpan] / baselineVolume[pivotSpan] : 0.0
    float prominence = math.min(1.0, relativeVolume / 2.0)
    if not na(seedWidth)
        if not na(pivotLow) and close >= pivotLow - seedWidth - memoryAtr * 0.1
            f_seed(zones, pivotLow, 1, seedWidth, prominence)
        if not na(pivotHigh) and close <= pivotHigh + seedWidth + memoryAtr * 0.1
            f_seed(zones, pivotHigh, -1, seedWidth, prominence)
    memoryCommit := bar_index

if barstate.islast
    for item in projectedBoxes
        box.delete(item)
    projectedBoxes.clear()
    for item in projectedLabels
        label.delete(item)
    projectedLabels.clear()
    projectedDetails.clear()
    if showMemory and not na(memoryAtr) and memoryAtr > 0 and zones.size() > 0
        array<float> evidence = array.new<float>()
        float livePressure = current.valid and currentTotal > 0 ? currentDelta / currentTotal : 0.0
        for zone in zones
            evidence.push(f_evidence(zone, memoryAtr, livePressure, current.valid))
        array<int> selection = array.sort_indices(evidence, order.descending)
        int supportCount = 0
        int resistanceCount = 0
        for index in selection
            ReactionZone zone = zones.get(index)
            float score = evidence.get(index)
            float distance = math.abs(close - math.avg(zone.lo, zone.hi)) / memoryAtr
            bool location = zone.direction == 1 ? close >= zone.hi : close <= zone.lo
            bool room = zone.direction == 1 ? supportCount < supportLevels : resistanceCount < projectionCount
            if score >= (zone.direction == 1 ? supportEvidence : minimumEvidence) and distance <= (zone.direction == 1 ? supportRange : projectionRange) and location and room
                color zoneColor = zone.direction == 1 ? #ADDFFF : #7040A0
                int x1 = bar_index + panelGap
                int x2 = x1 + panelWidth
                projectedBoxes.push(box.new(x1, zone.hi, x2, zone.lo, border_color = zoneColor, border_style = line.style_dashed, bgcolor = color.new(zoneColor, 94), force_overlay = true))
                string zoneText = (zone.direction == 1 ? "SUPPORT CANDIDATE " : "PROJECTED R ") + str.tostring(math.avg(zone.lo, zone.hi), format.mintick) + " | Evidence " + str.tostring(score, "#") + "/100"
                string zoneTip = "OHLCV historical zone; not resting liquidity or a footprint-volume estimate.\nEvidence score, not probability. Encounter counts restart only if zone geometry changes. Age: " + str.tostring(bar_index - zone.born) + " bars\nEncounters: " + str.tostring(zone.touches) + " | Rejections: " + str.tostring(zone.rejections) + "\nInvalidation: two closes beyond far edge by 0.1 ATR.\nLive footprint: " + (current.valid ? "available" : "missing; evidence penalized")
                projectedDetails.push(zoneTip)
                projectedLabels.push(label.new(x1, zone.direction == 1 ? zone.lo : zone.hi, zoneText, style = zone.direction == 1 ? label.style_label_up : label.style_label_down, color = color.new(zoneColor, 15), textcolor = zone.direction == 1 ? color.black : color.white, size = levelTextSize, tooltip = zoneTip, force_overlay = true))
                supportCount += zone.direction == 1 ? 1 : 0
                resistanceCount += zone.direction == -1 ? 1 : 0


// Layout-only grouping: never mutates ReactionZone memory or evidence scores.
// Group selected same-side outlines by connected price ranges. Hover preserves
// every member's original label and calculation details.
var array<line> labelLeaders = array.new<line>()
f_space_labels(array<label> items, array<line> leaders, float spacing, bool onLeft) =>
    array<float> prices = array.new<float>()
    for item in items
        prices.push(label.get_y(item))
    array<int> sorted = array.sort_indices(prices, order.ascending)
    float previousY = na
    for index in sorted
        label item = items.get(index)
        float actualY = prices.get(index)
        float displayY = na(previousY) ? actualY : math.max(actualY, previousY + spacing)
        int x = label.get_x(item)
        label.set_y(item, displayY)
        label.set_style(item, onLeft ? label.style_label_right : label.style_label_left)
        if displayY != actualY
            leaders.push(line.new(x, displayY, onLeft ? x + 2 : x - 2, actualY, color = color.silver, width = 1, force_overlay = true))
        previousY := displayY
    true

if barstate.islast
    for item in labelLeaders
        line.delete(item)
    labelLeaders.clear()
    bool regroup = true
    while regroup
        regroup := false
        if projectedBoxes.size() > 1
            for i = 0 to projectedBoxes.size() - 2
                if regroup
                    break
                for j = i + 1 to projectedBoxes.size() - 1
                    box firstBox = projectedBoxes.get(i)
                    box secondBox = projectedBoxes.get(j)
                    label firstLabel = projectedLabels.get(i)
                    label secondLabel = projectedLabels.get(j)
                    bool firstSupport = str.contains(label.get_text(firstLabel), "SUPPORT")
                    bool secondSupport = str.contains(label.get_text(secondLabel), "SUPPORT")
                    float gap = memoryAtr * displayGroupAtr
                    if firstSupport == secondSupport and box.get_bottom(firstBox) <= box.get_top(secondBox) + gap and box.get_top(firstBox) >= box.get_bottom(secondBox) - gap
                        float lo = math.min(box.get_bottom(firstBox), box.get_bottom(secondBox))
                        float hi = math.max(box.get_top(firstBox), box.get_top(secondBox))
                        string members = projectedDetails.get(i) + "\n---\n" + label.get_text(secondLabel) + "\n" + projectedDetails.get(j)
                        if not str.contains(label.get_text(firstLabel), "GROUP")
                            members := label.get_text(firstLabel) + "\n" + members
                        box.set_bottom(firstBox, lo)
                        box.set_top(firstBox, hi)
                        label.set_y(firstLabel, math.avg(lo, hi))
                        label.set_text(firstLabel, (firstSupport ? "SUPPORT GROUP " : "RESISTANCE GROUP ") + str.tostring(lo, format.mintick) + "–" + str.tostring(hi, format.mintick))
                        label.set_tooltip(firstLabel, members)
                        projectedDetails.set(i, members)
                        box.delete(secondBox)
                        label.delete(secondLabel)
                        projectedBoxes.remove(j)
                        projectedLabels.remove(j)
                        projectedDetails.remove(j)
                        regroup := true
                        break
    for item in projectedLabels
        label.set_x(item, bar_index + panelGap - 2)
    float spacing = math.max(rowWidth * 2.0, nz(memoryAtr, rowWidth) * labelSpacingAtr) * labelSizeFactor
    f_space_labels(candidates, labelLeaders, spacing, false)
    f_space_labels(projectedLabels, labelLeaders, spacing, true)

// Store exactly one completed snapshot per candle. Missing bars retain their
// place in the window. The current live candle is never stored with varip.
if barstate.isconfirmed
    if history.size() == 0 or history.last().index != bar_index
        history.push(current)
        while history.size() > windowBars - 1
            history.shift()

plot(currentTotal, "Current footprint total", display = display.data_window)
plot(currentBuy, "Current footprint buy", display = display.data_window)
plot(currentSell, "Current footprint sell", display = display.data_window)
plot(currentDelta, "Current footprint delta", display = display.data_window)
plot(currentPoc, "Current footprint POC", display = display.data_window)
plot(currentVah, "Current footprint VAH", display = display.data_window)
plot(currentVal, "Current footprint VAL", display = display.data_window)

plot(current.valid ? currentBuyImbalances : na, "Current buy imbalance rows", display = display.data_window)
plot(current.valid ? currentSellImbalances : na, "Current sell imbalance rows", display = display.data_window)
````
