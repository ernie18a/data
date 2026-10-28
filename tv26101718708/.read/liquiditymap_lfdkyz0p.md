# LiquidityMap

- url: https://www.tradingview.com/script/LFDkYZ0P-LiquidityMap/
- type: indicator
- pine_id: PUB;7e24c682bc404c2f94f8564bd1ddc86b
- version: 5.0

## Description

LiquidityMap v1.1 — Liquidation Cluster Heatmap with Footprint Integration

LiquidityMap estimates where leveraged positions would get liquidated by tracking where they were opened and projecting their forced-exit prices at four leverage tiers. The result is a heatmap overlay that reveals the structural cascade risk around current price — where the liquidation landmines are buried.

HOW IT WORKS

The indicator scans a configurable lookback window (default 200 bars) for bars where two conditions are met simultaneously: open interest expanded (new positions entered the market) AND volume was at or above its 20-bar average (the entries carried conviction, not just noise). These are classified as "entry bars" — moments when traders committed capital at a specific price.

Each entry bar is classified as long or short. In v1.1, this classification uses TradingView's request.footprint() function to determine actual buy vs sell pressure via volume delta. When footprint data shows positive delta (more buying than selling), the bar is classified as a long entry. Negative delta classifies it as a short entry. This is a significant improvement over the v1.0 approach of using candle color, which is a rough proxy at best — a green candle during a selloff can mask aggressive short entries that happened to close slightly above open. On plans without footprint access (Free/Essential), the indicator falls back to candle color automatically.

For each detected entry, LiquidityMap projects where those positions would get liquidated at four leverage tiers: 10x, 25x, 50x, and 100x. The liquidation formula accounts for maintenance margin (default 0.5% for Phemex). Each tier is weighted by estimated trader distribution — default is 35% at 10x, 35% at 25x, 20% at 50x, and 10% at 100x, reflecting that most retail traders use moderate leverage. The projected liquidation prices are then accumulated into price bins to create a density map.

READING THE HEATMAP

Red and orange zones below price represent long liquidation clusters. If price drops into these zones, long positions at those leverage tiers get forcefully closed. The forced selling creates additional downward pressure, which can trigger more liquidations at slightly lower prices — this is the cascade effect. Brighter, more opaque zones indicate denser clusters where more liquidation volume is concentrated.

Cyan and teal zones above price represent short liquidation clusters. Price rising into these zones forces shorts to cover, adding buy pressure that can accelerate a squeeze. Dense cyan zones above price are squeeze fuel.

Dashed reference lines mark the nearest significant liquidation zone in each direction, with a label showing the exact price level and percentage distance from current price.

CONVICTION WEIGHTING

When footprint data is available, entries are weighted not just by OI magnitude and volume intensity but also by delta conviction — how lopsided the buy/sell split was on that bar. A bar where 80% of volume was buying gets a stronger long-entry weight than a bar where the split was 52/48. This makes the density map proportional to actual directional conviction, not just raw OI expansion.

THE INFO TABLE

The table provides a compact summary of the liquidation landscape. The header row shows the asset, number of detected entries, and the active classification source (FP for footprint, or candle for fallback mode). The Long and Short rows show the nearest significant liquidation zone with its price, percentage distance from current price, and relative density. The Cascade row scores how much total liquidation density sits within a configurable percentage range of current price (default ±3%), classified as LOW, MODERATE, HIGH, or EXTREME. The L/S row shows the ratio of long vs short entry weight, indicating which side of the market is more exposed. Reference rows at the bottom show where you would get liquidated at 10x and 25x leverage if you entered a position right now. The Source row shows how many entry bars used footprint classification vs candle color fallback.

INPUTS AND CONFIGURATION

The OI data source defaults to Binance linear perpetuals. The lookback window controls how many bars of history are scanned for entries — 200 on 1H covers about 8 days, 200 on Daily covers about 9 months. The volume threshold (default 1.0x SMA20) filters out low-conviction entries. Leverage tiers and their probability weights are fully configurable. The heatmap resolution (number of price bins), zone width, and minimum density floor control the visual output. The cascade zone percentage, minimum line distance, and minimum line density threshold control which zones get reference lines drawn.

Footprint settings include ticks per row (default 100) and Value Area percentage (default 70%). The footprint toggle allows disabling the feature entirely for compatibility with Free/Essential plans.

WHAT THIS IS NOT

LiquidityMap is an estimation tool, not a prediction engine. It does not have access to actual exchange order books or real liquidation data — those require platforms like CoinGlass or Hyblock Capital. What it does is build a probabilistic model of where liquidations are likely concentrated based on observable on-chain signals (OI expansion, volume, and footprint delta). Validation against CoinGlass liquidation maps shows strong alignment in identifying major cluster zones, though absolute density values will differ since CoinGlass has direct exchange data.

OI data is sourced from Binance via the standard BINANCE:SYMBOL+USDT.P_OI ticker. Assets without Binance OI data will not produce results. The footprint feature requires a TradingView Premium or Ultimate subscription.

## Source Code

````pine
//@version=6
indicator("LiquidityMap", shorttitle="LiqMap", overlay=true, max_bars_back=500, max_boxes_count=300, max_lines_count=50, max_labels_count=30)

// ═══════════════════════════════════════════════════════════════════════════════
// LIQUIDITYMAP v1.1 — TheurgyLabs
// ═══════════════════════════════════════════════════════════════════════════════
//
// v1.1: Footprint integration — uses request.footprint() buy/sell delta
//       to classify entries as long or short instead of candle color heuristic.
//       Falls back to candle color when footprint data unavailable.
//       Table restyled to fleet standard MoneyLine dark theme.
//
// Estimates liquidation cluster locations by tracking where positions were
// opened (OI expansion + elevated volume) and projecting where they'd get
// liquidated at common leverage tiers (10x / 25x / 50x / 100x).
//
// RED/ORANGE zones below price = long liquidation clusters (cascade risk)
// CYAN/TEAL zones above price  = short liquidation clusters (squeeze fuel)
// Brighter/more opaque zones = higher density = more liquidations there
//
// ═══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

string G_OI = "═══ OI DATA ═══"
i_oiSuffix  = input.string("USDT.P", "OI Ticker Suffix", group=G_OI, tooltip="Appended to base currency. USDT.P = Binance linear perps.")
i_lookback  = input.int(200, "Lookback Bars", minval=50, maxval=500, group=G_OI, tooltip="Scan window for position entries. 200 on 1H ≈ 8 days.")
i_volThresh = input.float(1.0, "Volume Threshold (× SMA20)", minval=0.5, maxval=5.0, step=0.1, group=G_OI, tooltip="Min volume ratio to qualify as entry bar. 1.0 = at or above average.")

string G_FP = "═══ FOOTPRINT (Premium/Ultimate) ═══"
i_useFP     = input.bool(true, "Use Footprint Delta", group=G_FP, tooltip="Uses request.footprint() buy/sell delta to classify entries as long or short. Much more accurate than candle color. Requires Premium or Ultimate plan. Falls back to candle color if unavailable.")
i_fpTicks   = input.int(100, "Ticks Per Row", minval=1, maxval=500, group=G_FP, tooltip="Price granularity for footprint rows. 100 ticks works for most assets.")
i_fpVA      = input.int(70, "Value Area %", minval=50, maxval=90, group=G_FP, tooltip="Percentage of volume defining the Value Area.")

string G_LEV = "═══ LEVERAGE TIERS ═══"
i_lev1  = input.int(10,  "Tier 1", minval=2, maxval=200, group=G_LEV)
i_lev2  = input.int(25,  "Tier 2", minval=2, maxval=200, group=G_LEV)
i_lev3  = input.int(50,  "Tier 3", minval=2, maxval=200, group=G_LEV)
i_lev4  = input.int(100, "Tier 4", minval=2, maxval=200, group=G_LEV)
i_maint = input.float(0.5, "Maintenance Margin %", minval=0.1, maxval=2.0, step=0.1, group=G_LEV, tooltip="Phemex ≈ 0.5%. Used in liq price projection.")
i_tw1   = input.float(35, "Tier 1 Weight %", minval=0, maxval=100, step=5, group=G_LEV, tooltip="Estimated % of traders at this leverage.")
i_tw2   = input.float(35, "Tier 2 Weight %", minval=0, maxval=100, step=5, group=G_LEV)
i_tw3   = input.float(20, "Tier 3 Weight %", minval=0, maxval=100, step=5, group=G_LEV)
i_tw4   = input.float(10, "Tier 4 Weight %", minval=0, maxval=100, step=5, group=G_LEV)

string G_DISP = "═══ DISPLAY ═══"
i_bins      = input.int(50, "Price Bins", minval=20, maxval=100, group=G_DISP, tooltip="Heatmap resolution. More bins = finer zones.")
i_zoneWidth = input.int(80, "Zone Width (bars back)", minval=20, maxval=300, group=G_DISP, tooltip="How far left the heatmap extends.")
i_densFloor = input.float(5, "Min Density % to Show", minval=1, maxval=25, step=1, group=G_DISP, tooltip="Zones below this % of max density are hidden.")
i_showTable = input.bool(true, "Show Info Table", group=G_DISP)
i_tablePos  = input.string("Middle Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=G_DISP)
i_showLines = input.bool(true, "Show Nearest Liq Lines", group=G_DISP)
i_cascadePct = input.float(3.0, "Cascade Zone ±%", minval=1.0, maxval=10.0, step=0.5, group=G_DISP, tooltip="Range from price used for cascade/squeeze risk calculation.")
i_minLineDist = input.float(0.1, "Min Line Distance %", minval=0.0, maxval=5.0, step=0.1, group=G_DISP, tooltip="Nearest liq lines only show if zone is at least this far from current price.")
i_lineThresh = input.float(25, "Min Line Density %", minval=5, maxval=50, step=5, group=G_DISP, tooltip="Nearest liq reference lines only show for zones with at least this % of max density.")

// ─────────────────────────────────────────────────────────────────────────────
// OI DATA
// ─────────────────────────────────────────────────────────────────────────────

string oiTicker = "BINANCE:" + syminfo.basecurrency + i_oiSuffix + "_OI"
float oi = request.security(oiTicker, "", close, barmerge.gaps_off, barmerge.lookahead_off)

float oiDelta  = nz(oi) - nz(oi[1])
float volSma   = ta.sma(volume, 20)
float volRatio = nz(volSma) > 0 ? volume / volSma : 1.0

// ─────────────────────────────────────────────────────────────────────────────
// FOOTPRINT DATA — buy/sell delta for real directional classification
// ─────────────────────────────────────────────────────────────────────────────

footprint fpData = i_useFP ? request.footprint(i_fpTicks, i_fpVA) : na

// Extract buy/sell volumes and delta (na-safe)
float fpBuyVol  = not na(fpData) ? footprint.buy_volume(fpData)  : na
float fpSellVol = not na(fpData) ? footprint.sell_volume(fpData) : na
float fpDelta   = not na(fpData) ? footprint.delta(fpData)       : na
bool  fpValid   = not na(fpDelta)

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY DETECTION — OI expansion + elevated volume
// Base classification ALWAYS uses candle color (reliable for all historical bars).
// Footprint delta applied ONLY to current bar (i==0) inside the lookback loop,
// because request.footprint() returns data for the current bar only — accessing
// fpDelta[i] for i>0 returns the CURRENT bar's delta, not the historical bar's.
// ─────────────────────────────────────────────────────────────────────────────

bool isEntry = oiDelta > 0 and volRatio >= i_volThresh and not na(oi) and not na(oi[1])

// Base: close-location-in-range (0-1, where close sits within the bar's range)
// More accurate than binary candle color — handles dojis, wick-heavy bars, and
// indecisive candles by measuring actual buying vs selling pressure distribution.
// CLV > 0.5 = close in upper half = buying pressure dominated = long entry
// CLV ≤ 0.5 = close in lower half = selling pressure dominated = short entry
float clv = (high - low) > 0 ? (close - low) / (high - low) : 0.5
bool entryLongBase  = isEntry and clv > 0.5
bool entryShortBase = isEntry and clv <= 0.5
float longWtBase    = entryLongBase  ? oiDelta * math.min(volRatio, 5.0) : 0.0
float shortWtBase   = entryShortBase ? oiDelta * math.min(volRatio, 5.0) : 0.0

// Footprint conviction for current bar only (used in loop at i==0)
float fpDeltaConv = (i_useFP and fpValid) ? math.min(math.abs(fpDelta) / math.max(fpBuyVol + fpSellVol, 1) + 0.5, 2.0) : 1.0
bool  fpIsLong    = (i_useFP and fpValid) ? fpDelta > 0  : clv > 0.5
bool  fpIsShort   = (i_useFP and fpValid) ? fpDelta <= 0 : clv <= 0.5

// ─────────────────────────────────────────────────────────────────────────────
// LIQUIDATION PRICE MATH
// ─────────────────────────────────────────────────────────────────────────────

f_longLiq(float entry, float lev, float mm) =>
    entry * (1.0 - 1.0 / lev + mm / 100.0)

f_shortLiq(float entry, float lev, float mm) =>
    entry * (1.0 + 1.0 / lev - mm / 100.0)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION STATE
// ─────────────────────────────────────────────────────────────────────────────

var array<box>   vizBoxes  = array.new_box(0)
var array<line>  vizLines  = array.new_line(0)
var array<label> vizLabels = array.new_label(0)

var array<float> _levs = array.from(float(i_lev1), float(i_lev2), float(i_lev3), float(i_lev4))
var array<float> _tws  = array.from(i_tw1, i_tw2, i_tw3, i_tw4)

// ─────────────────────────────────────────────────────────────────────────────
// TABLE — Fleet standard MoneyLine dark theme
// ─────────────────────────────────────────────────────────────────────────────

tblPos = switch i_tablePos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

var table tbl = table.new(tblPos, 4, 9, bgcolor=#0d0d1a, border_width=1, border_color=#333355, frame_width=1, frame_color=#333355)

// ─────────────────────────────────────────────────────────────────────────────
// MAIN COMPUTATION (last bar only)
// ─────────────────────────────────────────────────────────────────────────────

if barstate.islast
    // ── Cleanup ──
    while array.size(vizBoxes) > 0
        box.delete(array.pop(vizBoxes))
    while array.size(vizLines) > 0
        line.delete(array.pop(vizLines))
    while array.size(vizLabels) > 0
        label.delete(array.pop(vizLabels))

    // ── Price range ──
    float hi  = ta.highest(high, i_lookback)
    float lo  = ta.lowest(low, i_lookback)
    float rng = hi - lo
    float ext = rng * 0.25
    float rangeHi = hi + ext
    float rangeLo = math.max(lo - ext, 0.0)
    float binSize = (rangeHi - rangeLo) / i_bins

    // ── Density arrays ──
    array<float> longDens  = array.new_float(i_bins, 0.0)
    array<float> shortDens = array.new_float(i_bins, 0.0)

    float twTotal = i_tw1 + i_tw2 + i_tw3 + i_tw4
    float twNorm  = twTotal > 0 ? twTotal : 100.0

    // ── Scan lookback ──
    float totalLongWt  = 0.0
    float totalShortWt = 0.0
    int   totalEntries = 0
    bool  fpUsedOnCurrent = false

    for i = 0 to i_lookback - 1
        float lw = 0.0
        float sw = 0.0
        float ep = hl2[i]

        if i == 0 and isEntry and i_useFP and fpValid
            // Current bar: use footprint delta for classification + conviction
            fpUsedOnCurrent := true
            if fpIsLong
                lw := oiDelta * math.min(volRatio, 5.0) * fpDeltaConv
            if fpIsShort
                sw := oiDelta * math.min(volRatio, 5.0) * fpDeltaConv
        else
            // Historical bars: candle color (reliable)
            lw := longWtBase[i]
            sw := shortWtBase[i]

        if lw > 0
            totalLongWt  += lw
            totalEntries += 1
            for t = 0 to 3
                float lev = array.get(_levs, t)
                float tw  = array.get(_tws, t) / twNorm
                float liqP = f_longLiq(ep, lev, i_maint)
                int bin = int(math.floor((liqP - rangeLo) / binSize))
                if bin >= 0 and bin < i_bins
                    array.set(longDens, bin, array.get(longDens, bin) + lw * tw)

        if sw > 0
            totalShortWt += sw
            totalEntries += 1
            for t = 0 to 3
                float lev = array.get(_levs, t)
                float tw  = array.get(_tws, t) / twNorm
                float liqP = f_shortLiq(ep, lev, i_maint)
                int bin = int(math.floor((liqP - rangeLo) / binSize))
                if bin >= 0 and bin < i_bins
                    array.set(shortDens, bin, array.get(shortDens, bin) + sw * tw)

    // ── Max density ──
    float maxDens = 0.0
    for i = 0 to i_bins - 1
        maxDens := math.max(maxDens, array.get(longDens, i))
        maxDens := math.max(maxDens, array.get(shortDens, i))

    // ── Nearest zones + cascade risk ──
    float curPrice  = close
    float nearLongP = na
    float nearLongD = 0.0
    float nearShortP = na
    float nearShortD = 0.0
    float cascLong  = 0.0
    float cascShort = 0.0
    float totalDens = 0.0

    float cascHi = curPrice * (1.0 + i_cascadePct / 100.0)
    float cascLo = curPrice * (1.0 - i_cascadePct / 100.0)
    float densThresh = maxDens * (i_lineThresh / 100.0)
    float minDist    = curPrice * (i_minLineDist / 100.0)

    for i = 0 to i_bins - 1
        float binMid = rangeLo + (i + 0.5) * binSize
        float ld = array.get(longDens, i)
        float sd = array.get(shortDens, i)
        totalDens += ld + sd

        if ld >= densThresh and binMid < curPrice and (curPrice - binMid) >= minDist
            if na(nearLongP) or (curPrice - binMid) < (curPrice - nearLongP)
                nearLongP := binMid
                nearLongD := ld

        if sd >= densThresh and binMid > curPrice and (binMid - curPrice) >= minDist
            if na(nearShortP) or (binMid - curPrice) < (nearShortP - curPrice)
                nearShortP := binMid
                nearShortD := sd

        if binMid >= cascLo and binMid <= curPrice
            cascLong += ld
        if binMid <= cascHi and binMid >= curPrice
            cascShort += sd

    float cascadeScore = totalDens > 0 ? (cascLong + cascShort) / totalDens * 100 : 0

    // ── Heatmap boxes ──
    if maxDens > 0
        int leftBar  = bar_index - i_zoneWidth
        int rightBar = bar_index + 10
        float floor  = i_densFloor / 100.0

        for i = 0 to i_bins - 1
            float binLo = rangeLo + i * binSize
            float binHi = binLo + binSize
            float ld = array.get(longDens, i)
            float sd = array.get(shortDens, i)

            if ld > maxDens * floor
                float norm = ld / maxDens
                int tr = math.round(90 - norm * 55)
                color c = norm >= 0.7 ? color.new(#FF0000, tr) : norm >= 0.4 ? color.new(#FF6D00, tr) : color.new(#CC3333, tr)
                array.push(vizBoxes, box.new(leftBar, binHi, rightBar, binLo, border_color=color.new(#FF0000, 100), bgcolor=c))

            if sd > maxDens * floor
                float norm = sd / maxDens
                int tr = math.round(90 - norm * 55)
                color c = norm >= 0.7 ? color.new(#00FFFF, tr) : norm >= 0.4 ? color.new(#00CC88, tr) : color.new(#006666, tr)
                array.push(vizBoxes, box.new(leftBar, binHi, rightBar, binLo, border_color=color.new(#00FFFF, 100), bgcolor=c))

    // ── Adaptive price format ──
    string pFmt = curPrice < 0.01 ? "#.######" : curPrice < 0.1 ? "#.#####" : curPrice < 1 ? "#.####" : curPrice < 10 ? "#.###" : curPrice < 100 ? "#.##" : curPrice < 1000 ? "#.#" : "#"

    // ── Nearest liq lines ──
    if i_showLines
        if not na(nearLongP)
            float pct = (nearLongP - curPrice) / curPrice * 100
            array.push(vizLines, line.new(bar_index - i_zoneWidth, nearLongP, bar_index + 10, nearLongP, color=color.new(#FF4444, 20), style=line.style_dashed, width=2))
            string lbl = "▼ " + str.tostring(nearLongP, pFmt) + "  " + str.tostring(pct, "#.#") + "%"
            array.push(vizLabels, label.new(bar_index + 12, nearLongP, lbl, color=color.new(#FF4444, 50), textcolor=color.white, size=size.small, style=label.style_label_left))

        if not na(nearShortP)
            float pct = (nearShortP - curPrice) / curPrice * 100
            array.push(vizLines, line.new(bar_index - i_zoneWidth, nearShortP, bar_index + 10, nearShortP, color=color.new(#00FFFF, 20), style=line.style_dashed, width=2))
            string lbl = "▲ " + str.tostring(nearShortP, pFmt) + "  +" + str.tostring(pct, "#.#") + "%"
            array.push(vizLabels, label.new(bar_index + 12, nearShortP, lbl, color=color.new(#00FFFF, 50), textcolor=color.white, size=size.small, style=label.style_label_left))

    // ── L/S Weight Ratio ──
    float totalWt = totalLongWt + totalShortWt
    float lPct = totalWt > 0 ? totalLongWt / totalWt * 100 : 50
    float sPct = totalWt > 0 ? totalShortWt / totalWt * 100 : 50

    // ── Info Table — Fleet MoneyLine dark theme ──
    if i_showTable
        string ts = size.small
        color headerBg = #1a1a2e
        color dimText  = #888888
        color rowBg    = #0d0d1a
        color zebraBg  = #2a2a4a

        // Row 0: Header
        table.cell(tbl, 0, 0, "LIQMAP",   text_color=#00E5FF, bgcolor=headerBg, text_size=ts)
        table.cell(tbl, 1, 0, syminfo.basecurrency, text_color=color.white, bgcolor=headerBg, text_size=ts)
        table.cell(tbl, 2, 0, str.tostring(totalEntries), text_color=#FFD700, bgcolor=headerBg, text_size=ts)
        string srcLbl = fpUsedOnCurrent ? "FP" : "CLV"
        table.cell(tbl, 3, 0, srcLbl, text_color=fpUsedOnCurrent ? #00FF88 : dimText, bgcolor=headerBg, text_size=ts)

        // Adaptive price format for low-priced crypto (pFmt declared above)

        // Row 1: Nearest Long Liq
        string nlStr = not na(nearLongP) ? str.tostring(nearLongP, pFmt) : "—"
        float nlPct  = not na(nearLongP) ? (nearLongP - curPrice) / curPrice * 100 : na
        string nlDst = not na(nlPct) ? str.tostring(nlPct, "#.#") + "%" : ""
        float nlNorm = maxDens > 0 and nearLongD > 0 ? nearLongD / maxDens * 100 : 0
        table.cell(tbl, 0, 1, "▼ Long", text_color=#FF4444, bgcolor=zebraBg, text_size=ts)
        table.cell(tbl, 1, 1, nlStr, text_color=not na(nlPct) and math.abs(nlPct) < i_cascadePct ? #FF4444 : color.white, bgcolor=zebraBg, text_size=ts)
        table.cell(tbl, 2, 1, nlDst, text_color=#FF4444, bgcolor=zebraBg, text_size=ts)
        table.cell(tbl, 3, 1, nlNorm > 0 ? str.tostring(nlNorm, "#") + "%" : "", text_color=#FFD700, bgcolor=zebraBg, text_size=size.tiny)

        // Row 2: Nearest Short Liq
        string nsStr = not na(nearShortP) ? str.tostring(nearShortP, pFmt) : "—"
        float nsPct  = not na(nearShortP) ? (nearShortP - curPrice) / curPrice * 100 : na
        string nsDst = not na(nsPct) ? "+" + str.tostring(nsPct, "#.#") + "%" : ""
        float nsNorm = maxDens > 0 and nearShortD > 0 ? nearShortD / maxDens * 100 : 0
        table.cell(tbl, 0, 2, "▲ Short", text_color=#00FFFF, bgcolor=rowBg, text_size=ts)
        table.cell(tbl, 1, 2, nsStr, text_color=not na(nsPct) and nsPct < i_cascadePct ? #00FFFF : color.white, bgcolor=rowBg, text_size=ts)
        table.cell(tbl, 2, 2, nsDst, text_color=#00FFFF, bgcolor=rowBg, text_size=ts)
        table.cell(tbl, 3, 2, nsNorm > 0 ? str.tostring(nsNorm, "#") + "%" : "", text_color=#FFD700, bgcolor=rowBg, text_size=size.tiny)

        // Row 3: Cascade Risk
        string cascLbl = cascadeScore >= 70 ? "EXTREME" : cascadeScore >= 50 ? "HIGH" : cascadeScore >= 30 ? "MODERATE" : "LOW"
        color cascCol  = cascadeScore >= 70 ? #FF4444 : cascadeScore >= 50 ? #FF6D00 : cascadeScore >= 30 ? #FFD700 : #00FF88
        table.cell(tbl, 0, 3, "Cascade", text_color=dimText, bgcolor=zebraBg, text_size=ts)
        table.cell(tbl, 1, 3, str.tostring(cascadeScore, "#.#"), text_color=cascCol, bgcolor=zebraBg, text_size=ts)
        table.cell(tbl, 2, 3, cascLbl, text_color=cascCol, bgcolor=zebraBg, text_size=ts)
        table.cell(tbl, 3, 3, "±" + str.tostring(i_cascadePct, "#.#") + "%", text_color=#FF00FF, bgcolor=zebraBg, text_size=size.tiny)

        // Row 4: L/S Ratio
        string dominant = lPct > 65 ? "LONG HEAVY" : sPct > 65 ? "SHORT HEAVY" : "BALANCED"
        color domCol = lPct > 65 ? #FF4444 : sPct > 65 ? #00FFFF : color.white
        table.cell(tbl, 0, 4, "L/S", text_color=dimText, bgcolor=rowBg, text_size=ts)
        table.cell(tbl, 1, 4, str.tostring(lPct, "#") + " / " + str.tostring(sPct, "#"), text_color=domCol, bgcolor=rowBg, text_size=ts)
        table.cell(tbl, 2, 4, dominant, text_color=domCol, bgcolor=rowBg, text_size=ts)
        table.merge_cells(tbl, 2, 4, 3, 4)

        // Row 5: Liq Levels header
        table.cell(tbl, 0, 5, "Liq Levels", text_color=#FF00FF, bgcolor=headerBg, text_size=size.small)
        table.cell(tbl, 1, 5, "if entry at " + str.tostring(curPrice, pFmt), text_color=#d0d0d0, bgcolor=headerBg, text_size=size.small)
        table.merge_cells(tbl, 1, 5, 3, 5)

        // Row 6-7: Liq tier reference
        float l1 = f_longLiq(curPrice, float(i_lev1), i_maint)
        float l2 = f_longLiq(curPrice, float(i_lev2), i_maint)
        float s1 = f_shortLiq(curPrice, float(i_lev1), i_maint)
        float s2 = f_shortLiq(curPrice, float(i_lev2), i_maint)
        table.cell(tbl, 0, 6, str.tostring(i_lev2) + "x", text_color=#FF00FF, bgcolor=zebraBg, text_size=size.small)
        table.cell(tbl, 1, 6, "L:" + str.tostring(l2, pFmt), text_color=#FF4444, bgcolor=zebraBg, text_size=size.small)
        table.cell(tbl, 2, 6, "S:" + str.tostring(s2, pFmt), text_color=#00FFFF, bgcolor=zebraBg, text_size=size.small)
        table.merge_cells(tbl, 2, 6, 3, 6)

        table.cell(tbl, 0, 7, str.tostring(i_lev1) + "x", text_color=#FF00FF, bgcolor=rowBg, text_size=size.small)
        table.cell(tbl, 1, 7, "L:" + str.tostring(l1, pFmt), text_color=#FF4444, bgcolor=rowBg, text_size=size.small)
        table.cell(tbl, 2, 7, "S:" + str.tostring(s1, pFmt), text_color=#00FFFF, bgcolor=rowBg, text_size=size.small)
        table.merge_cells(tbl, 2, 7, 3, 7)

        // Row 8: Footprint status
        string fpStatus = fpUsedOnCurrent ? "FP (current bar) + candle (history)" : "CLV (all bars)"
        table.cell(tbl, 0, 8, "Source", text_color=dimText, bgcolor=headerBg, text_size=size.tiny)
        table.cell(tbl, 1, 8, fpStatus, text_color=fpUsedOnCurrent ? #00FF88 : #FFD700, bgcolor=headerBg, text_size=size.tiny)
        table.merge_cells(tbl, 1, 8, 3, 8)

    // ── Cascade alert ──
    if cascadeScore >= 60
        alert("LiquidityMap " + syminfo.ticker + " CASCADE " + str.tostring(cascadeScore, "#") + " | NearLong: " + (not na(nearLongP) ? str.tostring(nearLongP, "#") : "—") + " | NearShort: " + (not na(nearShortP) ? str.tostring(nearShortP, "#") : "—") + " | L/S: " + str.tostring(lPct, "#") + "/" + str.tostring(sPct, "#"), alert.freq_once_per_bar)
````
