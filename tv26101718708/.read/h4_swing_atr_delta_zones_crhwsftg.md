# H4 Swing ATR Delta Zones

- url: https://www.tradingview.com/script/crhwSftg-H4-Swing-ATR-Delta-Zones/
- type: indicator
- pine_id: PUB;68d5cb6094e84ae8bd1e44a5e71a985b
- version: 1.0

## Description

Cumulative Volume Delta-powered supply & demand zones on H4. CVD strength ratings (Weak/Moderate/Strong) + 15M BOS/CHoCH signals for precision execution.

**H4 Swing CVD Zones** is a professional supply & demand indicator powered by **Cumulative Volume Delta (CVD)** analysis. It identifies institutional accumulation/distribution zones on the 4-hour timeframe and grades each zone's strength using volume-weighted delta momentum.

---

## 🔹 Core Features

### **CVD-Powered Zone Strength**
Each swing point is analysed using a proprietary **CVD calculation** that combines:

- **Price Momentum**: (Close - Open) normalized by ATR — measures directional conviction of the swing candle
- **Volume Weighting**: Relative volume raised to a configurable power (0-1) — amplifies CVD during high-volume institutional moves
- **Dynamic Percentile Thresholds**: Rolling P20/P50/P80 thresholds adapt to recent market volatility

**Zone Classifications:**
| Strength | CVD Threshold | Visual |
|----------|---------------|--------|
| **Strong** | CVD > P80 | Bright colour, high conviction |
| **Moderate** | CVD > P50 | Medium intensity |
| **Weak** | CVD > P20 | Faded colour, lower conviction |
| **Neutral** | CVD ≤ P20 | Gray/orange, indecision zone |

### **H4 Institutional Zones (Locked Timeframe)**
- **Fractal-based swing detection** calculated exclusively on the 4-hour chart
- **ATR-adaptive sizing**: Zone height scales with H4 volatility
- **Smart Zone Management**:
  - Auto-mitigation when price pierces zones (fades to transparent shadow)
  - Distance filtering: Show only N closest zones above/below price
  - Deduplication prevents overlapping zones from same fractal event

### **15M Market Structure Overlay**
When viewing 15-minute charts, unlock execution signals:
- **BOS** (Break of Structure): Trend continuation — price breaks swing high/low in direction of EMA-50 trend
- **CHoCH** (Change of Character): Trend reversal — price breaks swing high/low against EMA-50 trend
- **Precision Projection**: Lines draw from exact pivot to the bar where close breaks through

---

## 🎯 How To Use

**Step 1 — Macro Context (H4 or any TF)**
Zones always calculate from H4. Identify **Strong CVD zones** (brightest colours) — these represent the highest-conviction institutional accumulation/distribution areas where CVD momentum was strongest.

**Step 2 — Set Alerts**
- Right-click zone lines → "Add Alert"
- Get notified when price enters high-CVD zones

**Step 3 — Execution (15M Chart)**
- Drop to 15M when price reaches a Strong/Moderate CVD zone
- **CHoCH** = Reversal entry (counter-trend, fade the move into zone)
- **BOS** = Continuation entry (trend-aligned, breakout from zone)

---

## ⚙️ Key Inputs

| Input | Description |
|-------|-------------|
| **Fractal Bars** | Swing strength (higher = fewer, stronger pivots) |
| **ATR Length** | Volatility lookback for zone sizing |
| **Volume Weight (0-1)** | CVD volume exponent — higher = more sensitive to volume spikes |
| **Threshold Lookback** | Rolling window for CVD percentile calculations |
| **Delta EMA Length** | Smooths CVD before percentile classification |
| **Smooth Percentile** | Apply EMA smoothing to P20/P50/P80 thresholds |
| **Zone Distance** | Max zones to display (closest to price) |
| **Show Mitigated** | Toggle faded shadows of hit zones |

---

## 📊 Best Practices

- **Strong CVD zones** = Highest probability — these formed on candles with both strong directional momentum AND elevated volume
- **Trending Markets**: Use BOS signals for pullbacks to H4 demand/supply zones with Strong CVD
- **Ranging Markets**: Use CHoCH signals for reversals at Strong/Moderate CVD zone extremes
- **Confluence**: Strong CVD zone + opposing liquidity sweep = highest probability setup

---

## 🔔 Alerts

The indicator fires alerts when:
- Price enters any CVD-rated zone
- Price crosses zone boundaries
- Zone mitigation events (zone is tested/broken)

---

**Recommended Timeframes:** H4 for analysis, 15M for execution  
**Markets:** Forex, Crypto, Futures, Equities  
**Style:** Supply/Demand, Smart Money Concepts, Volume Delta, Swing Trading

## Source Code

````pine
//@version=6
indicator("H4 Swing ATR Delta Zones", overlay = true, max_boxes_count = 200, max_labels_count = 200)

// --- Inputs ---
atrLen           = input.int(14,    "ATR Length")
mult             = input.float(2.0, "ATR Multiplier")
fractalBars      = input.int(3,     "Fractal Bars Each Side", minval = 2, maxval = 10, tooltip = "Number of bars each side the swing bar must dominate. Higher = stronger swings only.")
volLen           = input.int(20,    "Volume Avg Length")
zonesAbove       = input.int(50,    "Max Active Above Price")
zonesBelow       = input.int(50,    "Max Active Below Price")
maxMitigated     = input.int(100,   "Max Mitigated Zones")

// --- Delta Enhancement Inputs ---
useDynamic       = input.bool(true,  "Use Dynamic Thresholds", group = "Delta Classification")
lookback         = input.int(100,    "Threshold Lookback",     group = "Delta Classification", minval = 20)
volWeight        = input.float(0.5,  "Volume Weight (0-1)",    group = "Delta Classification", minval = 0.0, maxval = 1.0)
neutralThreshold = input.int(10,    "Fixed Neutral Threshold (±)", tooltip = "Used if Dynamic is OFF", group = "Delta Classification")

// --- Adaptive Smoothing Inputs ---
smoothPercentile = input.bool(false, "Smooth Percentile Thresholds", group = "Adaptive Smoothing")
smoothLen        = input.int(10,     "Threshold Smoothing Length",   group = "Adaptive Smoothing", minval = 2, maxval = 50)
deltaEmaLen      = input.int(1,      "Delta EMA Length",             group = "Adaptive Smoothing", minval = 1, maxval = 20, tooltip = "Smooths delta BEFORE percentile calculation")

// --- Colour Inputs ---
supplyColor      = input.color(color.new(color.red,    60), "Supply Zone Colour  (–Delta)",   group = "Zone Colours")
demandColor      = input.color(color.new(color.green,  60), "Demand Zone Colour  (+Delta)",   group = "Zone Colours")
neutralColor     = input.color(color.new(color.orange, 60), "Neutral Zone Colour (≈0 Delta)", group = "Zone Colours")
showMitigated    = input.bool(true,  "Show Mitigated Shadows",   group = "Mitigated Zones")
mitigatedOpacity = input.int(85,     "Mitigated Shadow Opacity", group = "Mitigated Zones", minval = 0, maxval = 100)

// --- H4 ATR ---
h4Atr = request.security(syminfo.tickerid, "240", ta.atr(atrLen), lookahead = barmerge.lookahead_off)

// --- Fractal Swing Logic (H4) ---
f_h4_swings() =>
    int  fb     = fractalBars
    bool isHigh = true
    bool isLow  = true

    for j = 1 to fb
        if high[fb + 1] <= high[j]
            isHigh := false
        if low[fb + 1] >= low[j]
            isLow := false

    for j = fb + 2 to fb * 2 + 1
        if high[fb + 1] <= high[j]
            isHigh := false
        if low[fb + 1] >= low[j]
            isLow := false

    float ph  = isHigh ? high[fb + 1] : na
    float pl  = isLow  ? low[fb + 1]  : na
    int   ft  = time[fb + 1]
    float a   = ta.atr(atrLen)
    float av  = ta.sma(volume, volLen)
    float vRel = av[fb + 1] > 0 ? volume[fb + 1] / av[fb + 1] : 1.0
    float dBase = (close[fb + 1] - open[fb + 1]) / a[fb + 1] * 100
    float dVol  = dBase * math.pow(vRel, volWeight)
    float d     = math.max(-100.0, math.min(100.0, dVol))
    [ph, pl, ft, d]

[highSwing, lowSwing, swingTime, swingDelta] = request.security(syminfo.tickerid, "240", f_h4_swings(), lookahead = barmerge.lookahead_off)

// --- Dynamic Threshold Calculation ---
var float[] deltaHist = array.new<float>()
smoothedDelta = ta.ema(nz(swingDelta), deltaEmaLen)

if not na(swingDelta)
    deltaHist.push(math.abs(smoothedDelta))
    if deltaHist.size() > lookback
        deltaHist.shift()

f_get_percentile(float[] arr, float p) =>
    if arr.size() < 2
        na
    else
        float[] sorted = arr.copy()
        sorted.sort()
        int idx = math.max(0, math.min(sorted.size() - 1, math.floor(sorted.size() * p / 100.0)))
        sorted.get(idx)

rawP20 = useDynamic ? f_get_percentile(deltaHist, 20) : neutralThreshold
rawP50 = useDynamic ? f_get_percentile(deltaHist, 50) : 30.0
rawP80 = useDynamic ? f_get_percentile(deltaHist, 80) : 50.0

p20 = smoothPercentile ? ta.ema(rawP20, smoothLen) : rawP20
p50 = smoothPercentile ? ta.ema(rawP50, smoothLen) : rawP50
p80 = smoothPercentile ? ta.ema(rawP80, smoothLen) : rawP80

// --- Types ---
type Zone
    box    b
    label  l
    string txt
    float  level
    float  top
    float  bottom
    float  deltaPct
    color  baseColor
    bool   active
    bool   isHi
    int    startTime
    int    mitigatedTime

var Zone[] zones = array.new<Zone>()

// --- Delta UI Formatting ---
get_delta_ui(float finalPct) =>
    float  absPct    = math.abs(finalPct)
    bool   isNeutral = absPct <= nz(p20, neutralThreshold)
    string strength  = isNeutral ? "Neutral" : absPct > nz(p80, 50.0) ? "Strong" : absPct > nz(p50, 30.0) ? "Moderate" : "Weak"
    string icon      = isNeutral ? "↔" : finalPct > 0 ? "▲" : "▼"
    string txt       = str.format("{0} {1} {2,number,#}%", icon, strength, finalPct)
    color  zColor    = isNeutral ? neutralColor : finalPct > 0 ? demandColor : supplyColor
    [txt, zColor]

// --- Zone Creation with Deduplication ---
process_swing(float swingVal, int sTime, float dPct, bool isHi) =>
    if not na(swingVal)
        bool exists = false
        if zones.size() > 0
            for i = 0 to zones.size() - 1
                if zones.get(i).startTime == sTime and zones.get(i).level == swingVal
                    exists := true
                    break
        if not exists
            [dTxt, dCol] = get_delta_ui(dPct)
            float zTop = swingVal + (h4Atr * mult * 0.5)
            float zBot = swingVal - (h4Atr * mult * 0.5)
            box   b    = box.new(sTime, zTop, sTime, zBot, xloc = xloc.bar_time, border_color = color.new(dCol, 40), bgcolor = dCol)
            label lbl  = label.new(sTime, zTop, dTxt, xloc = xloc.bar_time, style = label.style_label_right, color = dCol, textcolor = color.white, size = size.normal)
            zones.push(Zone.new(b, lbl, dTxt, swingVal, zTop, zBot, dPct, dCol, true, isHi, sTime, na))

if not na(highSwing)
    process_swing(highSwing, swingTime, swingDelta, true)
if not na(lowSwing)
    process_swing(lowSwing, swingTime, swingDelta, false)

// --- Zone Management ---
if zones.size() > 0

    // Step 1: Mitigation pass
    for i = zones.size() - 1 to 0
        Zone z = zones.get(i)
        if z.active
            bool mitigated = z.isHi ? close >= z.top : close <= z.bottom
            if mitigated
                z.active        := false
                z.mitigatedTime := time
                label.delete(z.l)
                z.l             := na
                box.set_right(z.b, time)
                box.set_bgcolor(z.b, color.new(z.baseColor, mitigatedOpacity))
                box.set_border_color(z.b, color.new(z.baseColor, mitigatedOpacity))

    // Step 2: Sync colours live
    for i = 0 to zones.size() - 1
        Zone  z         = zones.get(i)
        float absDelta  = math.abs(z.deltaPct)
        bool  isNeutral = absDelta <= nz(p20, neutralThreshold)
        color newCol    = isNeutral ? neutralColor : z.deltaPct > 0 ? demandColor : supplyColor
        z.baseColor    := newCol

    // Step 3: Count active zones each side of price
    int countAbove = 0
    int countBelow = 0
    for i = 0 to zones.size() - 1
        Zone z = zones.get(i)
        if z.active
            if z.level > close
                countAbove += 1
            else
                countBelow += 1

    // Step 4: Compute distance cutoffs
    float cutAbove = na
    float cutBelow = na

    if countAbove > zonesAbove
        float[] aboveDistances = array.new<float>()
        for i = 0 to zones.size() - 1
            Zone z = zones.get(i)
            if z.active and z.level > close
                aboveDistances.push(z.bottom - close)
        aboveDistances.sort(order.ascending)
        cutAbove := aboveDistances.get(zonesAbove - 1)

    if countBelow > zonesBelow
        float[] belowDistances = array.new<float>()
        for i = 0 to zones.size() - 1
            Zone z = zones.get(i)
            if z.active and z.level <= close
                belowDistances.push(close - z.top)
        belowDistances.sort(order.ascending)
        cutBelow := belowDistances.get(zonesBelow - 1)

    // Step 5: Show/hide active zones, freeze mitigated shadows
    for i = 0 to zones.size() - 1
        Zone z = zones.get(i)

        if z.active
            bool show = false
            if z.level > close
                show := na(cutAbove) or (z.bottom - close) <= cutAbove
            else
                show := na(cutBelow) or (close - z.top) <= cutBelow

            if show
                int rightEdge = time + 20 * 4 * 60 * 60 * 1000
                box.set_right(z.b, rightEdge)
                box.set_bgcolor(z.b, z.baseColor)
                box.set_border_color(z.b, color.new(z.baseColor, 40))
                if not na(z.l)
                    label.set_x(z.l, time + 20 * 4 * 60 * 60 * 1000)
                    label.set_y(z.l, (z.top + z.bottom) / 2.0)
                    label.set_text(z.l, z.txt)
                    label.set_style(z.l, label.style_label_right)
                    label.set_color(z.l, z.baseColor)
                    label.set_size(z.l, size.normal)
                    label.set_textcolor(z.l, color.white)
            else
                box.set_bgcolor(z.b, color.new(z.baseColor, 100))
                box.set_border_color(z.b, color.new(z.baseColor, 100))
                if not na(z.l)
                    label.set_color(z.l, color.new(z.baseColor, 100))
                    label.set_textcolor(z.l, color.new(color.white, 100))

        else
            if showMitigated
                box.set_right(z.b, z.mitigatedTime)
                box.set_bgcolor(z.b, color.new(z.baseColor, mitigatedOpacity))
                box.set_border_color(z.b, color.new(z.baseColor, mitigatedOpacity))
            else
                box.set_right(z.b, z.mitigatedTime)
                box.set_bgcolor(z.b, color.new(z.baseColor, 100))
                box.set_border_color(z.b, color.new(z.baseColor, 100))

    // Step 6: Trim mitigated zones
    int mitCount = 0
    for i = zones.size() - 1 to 0
        Zone z = zones.get(i)
        if not z.active
            mitCount += 1
            if mitCount > maxMitigated
                box.delete(z.b)
                zones.remove(i)

// ============================================================
// ——— ALERTS — Price enters zone ———
// ============================================================

if zones.size() > 0
    for i = 0 to zones.size() - 1
        Zone z = zones.get(i)
        if z.active
            bool inZone = high >= z.bottom and low <= z.top
            if inZone
                string dir = z.isHi ? "Supply" : "Demand"
                string dlt = str.format("{0,number,#}", z.deltaPct)
                alert("H4 " + dir + " zone hit at " + str.tostring(z.level, format.mintick) + " | Delta: " + dlt + "%", alert.freq_once_per_bar)

// ============================================================
// ——— 15M MARKET STRUCTURE — BOS & CHoCH ———
// Lines project from pivot and terminate exactly on the bar
// price closes through — learned from Fractal Break indicator.
// Only renders when chart timeframe is 15 minutes.
// ============================================================

var string GRP_MS = "━━━  15M Market Structure  ━━━"
i_show_ms    = input.bool(true,    "Show BOS / CHoCH",              group = GRP_MS)
i_ms_ema     = input.int(50,       "Trend EMA Length",              minval = 5,  maxval = 200, group = GRP_MS)
i_ms_pivlen  = input.int(3,        "Pivot Length (bars each side)", minval = 2,  maxval = 10,  group = GRP_MS)
i_ms_history = input.int(5,        "Max Lines to Show",             minval = 1,  maxval = 20,  group = GRP_MS)
i_col_bos    = input.color(#7F77DD,"BOS Colour",                    group = GRP_MS)
i_col_choch  = input.color(#EF9F27,"CHoCH Colour",                  group = GRP_MS)
i_ms_width   = input.int(1,        "Line Width",                    minval = 1,  maxval = 4,   group = GRP_MS)

var color MS_BOS_COL   = color.new(#7F77DD, 30)
var color MS_CHOCH_COL = color.new(#EF9F27, 30)

var float ms_top_val    = na
var float ms_bot_val    = na
var line  ms_top_line   = na
var line  ms_bot_line   = na
var bool  ms_top_broken = false
var bool  ms_bot_broken = false

var float  ms_last_hi = na
var float  ms_last_lo = na
var line[]  ms_lines  = array.new<line>()
var label[] ms_labels = array.new<label>()

is_15m = timeframe.period == "15"

ms_ema  = ta.ema(close, i_ms_ema)
ms_bull = close > ms_ema
ms_bear = close < ms_ema

ms_phi = ta.pivothigh(high, i_ms_pivlen, i_ms_pivlen)
ms_plo = ta.pivotlow(low,   i_ms_pivlen, i_ms_pivlen)

if not na(ms_phi)
    ms_last_hi := ms_phi
if not na(ms_plo)
    ms_last_lo := ms_plo

f_ms_trim() =>
    if array.size(ms_lines) >= i_ms_history
        line.delete(array.shift(ms_lines))
        label.delete(array.shift(ms_labels))

if i_show_ms and is_15m

    // New swing HIGH — start projecting line from pivot bar
    if not na(ms_phi)
        ms_top_broken := false
        ms_top_val    := ms_phi
        if not na(ms_top_line)
            line.delete(ms_top_line)
        ms_top_line := line.new(
             bar_index - i_ms_pivlen, ms_top_val,
             bar_index, ms_top_val,
             color = MS_BOS_COL, style = line.style_solid,
             width = i_ms_width)

    // New swing LOW — start projecting line from pivot bar
    if not na(ms_plo)
        ms_bot_broken := false
        ms_bot_val    := ms_plo
        if not na(ms_bot_line)
            line.delete(ms_bot_line)
        ms_bot_line := line.new(
             bar_index - i_ms_pivlen, ms_bot_val,
             bar_index, ms_bot_val,
             color = MS_BOS_COL, style = line.style_solid,
             width = i_ms_width)

    // Extend active lines to current bar every bar
    if not na(ms_top_line) and not ms_top_broken
        line.set_x2(ms_top_line, bar_index)
    if not na(ms_bot_line) and not ms_bot_broken
        line.set_x2(ms_bot_line, bar_index)

    // Top level broken — freeze, recolour, label
    if not ms_top_broken and not na(ms_top_val)
        if ta.crossover(close, ms_top_val)
            ms_top_broken := true
            line.set_x2(ms_top_line, bar_index)
            is_bos = ms_bull
            col    = is_bos ? MS_BOS_COL : MS_CHOCH_COL
            txt    = is_bos ? "BOS ▲" : "CHoCH ▲"
            line.set_color(ms_top_line, col)
            f_ms_trim()
            array.push(ms_lines,  ms_top_line)
            array.push(ms_labels, label.new(
                 bar_index, ms_top_val, txt,
                 style = label.style_label_up,
                 color = col, textcolor = color.white,
                 size = size.small))
            ms_top_line := na

    // Bottom level broken — freeze, recolour, label
    if not ms_bot_broken and not na(ms_bot_val)
        if ta.crossunder(close, ms_bot_val)
            ms_bot_broken := true
            line.set_x2(ms_bot_line, bar_index)
            is_bos = ms_bear
            col    = is_bos ? MS_BOS_COL : MS_CHOCH_COL
            txt    = is_bos ? "BOS ▼" : "CHoCH ▼"
            line.set_color(ms_bot_line, col)
            f_ms_trim()
            array.push(ms_lines,  ms_bot_line)
            array.push(ms_labels, label.new(
                 bar_index, ms_bot_val, txt,
                 style = label.style_label_down,
                 color = col, textcolor = color.white,
                 size = size.small))
            ms_bot_line := na
````
