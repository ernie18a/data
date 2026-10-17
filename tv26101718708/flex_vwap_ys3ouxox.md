# Flex VWAP 

- url: https://www.tradingview.com/script/yS3ouXox-Flex-VWAP/
- type: indicator
- pine_id: PUB;f905f79c0b6d4bb2a85e0c69c38bf22d
- version: 1.0

## Description

# 🌊 Flex VWAP — Dynamic Anchor Waves & Value Bands

### 📌 Overview
Traditional **Volume Weighted Average Price (VWAP)** is one of the most respected institutional tools in technical analysis. However, standard 24-hour Session VWAP suffers from a major mathematical flaw for day traders: **Volume Saturation Lag**.

As the trading day progresses, accumulated volume becomes massive. Consequently, the standard VWAP line flattens out, loses its sensitivity, and fails to adapt to rapid afternoon momentum bursts or sudden intraday trends.

**Flex VWAP** solves this limitation by introducing **Dynamic Anchor Waves**. Rather than locking calculations to a single fixed session start, Flex VWAP periodically resets accumulators across customizable **Micro-Cycles, Structural Swing Pivots, or Volume Milestones**, keeping fair-value calculations tightly coupled to active price action.

---

## ⚡ 4 Adaptive Calculation Engines

Traders can switch between 4 calculation modes to fit their specific strategy and asset:

### 1. 🌊 Bar Cycle (Micro Wave) — *Recommended for Scalping*
- **Mechanism:** Periodically resets the VWAP anchor every *N* bars (default: 15 bars).
- **Application:** Solves VWAP lag by isolating the active momentum wave. Perfect for scalpers trading Gold (GC/XAUUSD), Nasdaq (NQ/NAS100) on 1-minute, 2-minute, or tick charts. Pullbacks into the centerline provide precise continuation entries.

### 2. 🏛️ Swing / Pivot Wave — *Market Structure Alignment*
- **Mechanism:** Dynamically resets at confirmed structural swing highs and lows detected via pivot logic.
- **Application:** Measures institutional participation *since the last local top or bottom*. A VWAP anchored to a swing low serves as rising dynamic support; a VWAP anchored to a swing high acts as dynamic overhead resistance.

### 3. 📦 Volume Threshold — *Order-Flow & Activity Equalization*
- **Mechanism:** Anchors to traded volume milestones (e.g., resets every 50,000 contracts/shares) rather than elapsed time.
- **Application:** High-volatility news events trigger rapid resets, while quiet periods let the cycle develop naturally. Ideal for futures contracts (ES, NQ, GC, CL) and footprint traders.

### 4. ☀️ Daily / Session Anchor — *Institutional Benchmark*
- **Mechanism:** Resets at the start of each daily session (24-hour day boundary).
- **Application:** Provides the classic institutional intraday benchmark and session Value Area reference with enhanced trend-coloring and live tags.

---

## 🎯 Multi-Tier Standard Deviation Volatility Bands

Flex VWAP plots three institutional volatility tiers:

- **Band 1 (R1 / S1 at ±1.0σ) + Value Cloud:** Represents the core 68.2% statistical equilibrium (Value Area). Price inside the translucent violet cloud is considered at fair value; price accepting outside indicates trend acceleration.
- **Band 2 (R2 / S2 at ±2.0σ):** Statistical exhaustion boundary (95.4% distribution). Ideal for mean-reversion targets and counter-trend rejections.
- **Band 3 (R3 / S3 at ±3.0σ):** Extreme 99.7% tail expansion levels during major breakout drives.

---

## 💡 How to Trade with Flex VWAP

### Setup 1: Trend-Continuation Pullbacks (Bar Cycle Mode)
1. **Identify Direction:** Centerline glows **Neon Green** (price > VWAP) or **Red** (price < VWAP).
2. **Wait for the Pullback:** In an uptrend, wait for price to retrace into the Flex VWAP centerline or the **S1 (-1.0σ)** lower band.
3. **Trigger:** Enter on a bullish rejection candle with Stop Loss placed below the swing low.
4. **Target:** Target the **R1 (+1.0σ)** or **R2 (+2.0σ)** upper bands.

### Setup 2: Mean Reversion from Volatility Extremes
1. Price pushes aggressively into the outer **R2 (+2.0σ)** or **S2 (-2.0σ)** band during a ranging or exhausted market.
2. Watch for long wicks rejecting the band.
3. Target a return to the Flex VWAP centerline (mean reversion).

---

## 🎨 Professional Visual Features

- **Dynamic Trend Centerline:** Automatically shifts between bullish green and bearish red based on price location relative to fair value.
- **Right-Margin Live Price Badges:** Real-time floating price tags for instant order execution without squinting at the axis.
- **Cycle Reset Markers:** Clean, unobtrusive gold markers identifying the exact bar where a fresh cycle began.
- **Live Corner HUD:** Corner status module tracking the active Anchor Mode and cycle progress (e.g., `BAR 11 / 15`).
- **Zero-Volume Protection:** Built-in safeguards allow flawless calculation on Spot Forex, CFDs, and indices where physical exchange volume is unavailable.

---

## 🔔 Built-In TradingView Alerts

Easily configure alerts with dynamic placeholders (`{{ticker}}`, `{{close}}`):
- `Bullish Cross Over Flex VWAP`
- `Bearish Cross Under Flex VWAP`
- `Upper R1 Band (+1.0σ) Touch`
- `Lower S1 Band (-1.0σ) Touch`
- `Upper R2 Band (+2.0σ) Touch (Overbought Exhaustion)`
- `Lower S2 Band (-2.0σ) Touch (Oversold Exhaustion)`
- `New Cycle Anchor Reset`

---

## ⚙️ Recommended Settings

| Trading Style | Recommended Anchor Mode | Suggested Parameter | Recommended Timeframes |
| :--- | :--- | :--- | :--- |
| **Fast Scalping** | `Bar Cycle (Micro Wave)` | `12 – 18 bars` | 100-Tick, 1m, 2m, 3m |
| **Intraday Swing** | `Swing / Pivot Wave` | Lookback: `5 – 8 bars` | 5m, 15m, 1h |
| **Order Flow / Futures** | `Volume Threshold` | `25,000 – 50,000` contracts | Any timeframe |
| **Session Bias** | `Daily / Session Anchor` | Default | 5m, 15m, 30m |

---

*Disclaimer: This indicator is designed for educational and technical analysis purposes only. Past market behavior does not guarantee future results. Always practice prudent risk management and test strategies on demo accounts before trading live capital.*

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sithuphyo_21 — Flex VWAP Indicator (v6)
//@version=6
indicator("Flex VWAP [@sithuphyo_21]", shorttitle="Flex VWAP", overlay=true, 
     max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ============================================================================
// SECTION 1: USER INPUTS & CONFIGURATION
// ============================================================================

// ── 01. Dynamic Anchor Engine ────────────────────────────────────────────────
string grp_anchor           = "🌊 01. Flex VWAP Anchor Engine"
string anchorMode           = input.string("Bar Cycle (Micro Wave)", "Anchor Calculation Mode",
     options = ["Bar Cycle (Micro Wave)", "Swing / Pivot Wave", "Volume Threshold", "Daily / Session Anchor"], group = grp_anchor,
     tooltip = "Choose how Flex VWAP creates fresh reference zones:\n• Bar Cycle: Periodically resets every N bars to hug active intraday waves.\n• Swing / Pivot: Resets dynamically at structural swing highs and lows.\n• Volume Threshold: Resets whenever total accumulated volume hits a milestone.\n• Daily / Session: Standard 24-hour daily session anchored VWAP.")

int    barCycleLen          = input.int(15, "Bar Cycle Length (Bars)", minval = 5, maxval = 200, group = grp_anchor,
     tooltip = "Number of bars before resetting the anchor in Bar Cycle mode (10 to 20 is optimal for scalping).")
int    swingPivotLen        = input.int(5, "Swing Pivot Lookback", minval = 2, maxval = 50, group = grp_anchor,
     tooltip = "Neighboring bar count required to detect a swing pivot in Swing / Pivot mode.")
float  volMilestone         = input.float(50000.0, "Volume Reset Threshold (Contracts/Shares)", minval = 100.0, step = 5000.0, group = grp_anchor,
     tooltip = "Cumulative volume needed to trigger a new VWAP anchor in Volume Threshold mode.")

// ── 02. Source & Price Definition ────────────────────────────────────────────
string grp_calc             = "📐 02. Price Source & Calculation"
string srcType              = input.string("HLC3 (Typical Price)", "Price Source",
     options = ["HLC3 (Typical Price)", "OHLC4", "Close", "HL2 (Median)"], group = grp_calc)
bool   useContinuousStep    = input.bool(true, "Clean Step Line Breaks on Reset", group = grp_calc,
     tooltip = "Prevents diagonal connecting lines across new cycle transitions for a clean chart visual.")

// ── 03. Standard Deviation Bands ─────────────────────────────────────────────
string grp_bands            = "🎯 03. Standard Deviation Bands"
bool   showBands1           = input.bool(true, "Show Band 1 (R1 & S1)", group = grp_bands)
float  bandMult1            = input.float(1.0, "Band 1 Multiplier (±σ)", minval = 0.1, maxval = 5.0, step = 0.1, group = grp_bands)

bool   showBands2           = input.bool(false, "Show Band 2 (R2 & S2)", group = grp_bands)
float  bandMult2            = input.float(2.0, "Band 2 Multiplier (±σ)", minval = 0.5, maxval = 6.0, step = 0.1, group = grp_bands)

bool   showBands3           = input.bool(false, "Show Band 3 (R3 & S3)", group = grp_bands)
float  bandMult3            = input.float(3.0, "Band 3 Multiplier (±σ)", minval = 1.0, maxval = 8.0, step = 0.1, group = grp_bands)

// ── 04. Colors, Cloud & Aesthetic Styling ────────────────────────────────────
string grp_style            = "🎨 04. Colors & Visual Aesthetic"
bool   colorByTrend         = input.bool(true, "Color VWAP by Price Position (Bull/Bear)", group = grp_style)
color  colBullVwap          = input.color(#00e676, "Bullish VWAP Color", inline = "col_v", group = grp_style)
color  colBearVwap          = input.color(#ff1744, "Bearish VWAP Color", inline = "col_v", group = grp_style)
color  colNeutralVwap       = input.color(#fbc02d, "Neutral VWAP Center", inline = "col_v", group = grp_style)

color  colBand1             = input.color(color.new(#9c27b0, 20), "Band 1 (R1/S1) Color", inline = "b1", group = grp_style)
color  colBand2             = input.color(color.new(#2962ff, 30), "Band 2 (R2/S2) Color", inline = "b2", group = grp_style)
color  colBand3             = input.color(color.new(#ff6d00, 30), "Band 3 (R3/S3) Color", inline = "b3", group = grp_style)

bool   fillValueCloud       = input.bool(true, "Fill Value Zone Cloud (R1 - S1)", group = grp_style)
color  cloudColor           = input.color(color.new(#9c27b0, 92), "Value Cloud Shading", group = grp_style)

// ── 05. Live Tags, Cycle Markers & HUD ───────────────────────────────────────
string grp_hud              = "🏷️ 05. Live Tags & Cycle Markers"
bool   showRightPriceTags   = input.bool(true, "Show Real-Time Price Tags on Right Margin", group = grp_hud)
bool   showCycleMarkers     = input.bool(true, "Show Small Anchor Reset Markers", group = grp_hud)
bool   showHudStatus        = input.bool(true, "Show Cycle Info HUD in Corner", group = grp_hud)
string hudPos               = input.string("Top Right", "HUD Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grp_hud)


// ============================================================================
// SECTION 2: DYNAMIC ANCHOR DETECTION LOGIC
// ============================================================================

// Resolve calculation price
float priceSrc = switch srcType
    "OHLC4"              => ohlc4
    "Close"              => close
    "HL2 (Median)"       => hl2
    =>                      hlc3 // "HLC3 (Typical Price)"

// Safe volume resolution (ensures script works on Forex/Crypto/Indices without volume)
float barVol = na(volume) or volume <= 0 ? 1.0 : volume

// 1. Bar Cycle Tracking
var int barCounter = 0
barCounter += 1
bool isBarCycleReset = barCounter >= barCycleLen

// 2. Swing Pivot Tracking
float swingH = ta.pivothigh(high, swingPivotLen, swingPivotLen)
float swingL = ta.pivotlow(low, swingPivotLen, swingPivotLen)
bool isSwingReset = not na(swingH) or not na(swingL)

// 3. Volume Threshold Tracking
var float accumulatedVol = 0.0
accumulatedVol += barVol
bool isVolReset = accumulatedVol >= volMilestone

// 4. Session Anchor Tracking
bool isSessionReset = ta.change(time("D")) != 0

// Master Anchor Trigger
bool isNewCycle = false

if anchorMode == "Bar Cycle (Micro Wave)"
    isNewCycle := isBarCycleReset
else if anchorMode == "Swing / Pivot Wave"
    isNewCycle := isSwingReset
else if anchorMode == "Volume Threshold"
    isNewCycle := isVolReset
else
    isNewCycle := isSessionReset

// Reset internal cycle counters
if isNewCycle
    barCounter     := 0
    accumulatedVol := 0.0


// ============================================================================
// SECTION 3: MATHEMATICAL FLEX VWAP ENGINE
// ============================================================================

var float sumVolume = 0.0
var float sumPriceVolume = 0.0
var float sumPriceSquaredVolume = 0.0

// Clear accumulators at the start of a fresh cycle anchor
if isNewCycle
    sumVolume              := 0.0
    sumPriceVolume         := 0.0
    sumPriceSquaredVolume  := 0.0

sumVolume              += barVol
sumPriceVolume         += priceSrc * barVol
sumPriceSquaredVolume  += priceSrc * priceSrc * barVol

// Exact volume-weighted calculations
float flexVwap = sumVolume > 0.0 ? (sumPriceVolume / sumVolume) : priceSrc
float variance = math.max(0.0, (sumPriceSquaredVolume / sumVolume) - (flexVwap * flexVwap))
float stDev    = math.sqrt(variance)

// Multi-Tier Deviation Bands
float r1 = flexVwap + (stDev * bandMult1)
float s1 = flexVwap - (stDev * bandMult1)

float r2 = flexVwap + (stDev * bandMult2)
float s2 = flexVwap - (stDev * bandMult2)

float r3 = flexVwap + (stDev * bandMult3)
float s3 = flexVwap - (stDev * bandMult3)

// Filter out connecting line between previous cycle end and new cycle start
bool hideConnector = useContinuousStep and isNewCycle
float plotVwap = hideConnector ? na : flexVwap
float plotR1   = hideConnector ? na : r1
float plotS1   = hideConnector ? na : s1
float plotR2   = hideConnector ? na : r2
float plotS2   = hideConnector ? na : s2
float plotR3   = hideConnector ? na : r3
float plotS3   = hideConnector ? na : s3


// ============================================================================
// SECTION 4: VISUAL PLOTS, RIBBONS & VALUE SHADING
// ============================================================================

// Dynamic Centerline Color
color activeVwapCol = colorByTrend ? (close >= flexVwap ? colBullVwap : colBearVwap) : colNeutralVwap

p_vwap = plot(plotVwap, "Flex VWAP Center", color = activeVwapCol, linewidth = 2, style = plot.style_linebr)

// Band 1
p_r1 = plot(showBands1 ? plotR1 : na, "R1 Band (+1.0σ)", color = colBand1, linewidth = 1, style = plot.style_linebr)
p_s1 = plot(showBands1 ? plotS1 : na, "S1 Band (-1.0σ)", color = colBand1, linewidth = 1, style = plot.style_linebr)

// Band 2
p_r2 = plot(showBands2 ? plotR2 : na, "R2 Band (+2.0σ)", color = colBand2, linewidth = 1, style = plot.style_linebr)
p_s2 = plot(showBands2 ? plotS2 : na, "S2 Band (-2.0σ)", color = colBand2, linewidth = 1, style = plot.style_linebr)

// Band 3
p_r3 = plot(showBands3 ? plotR3 : na, "R3 Band (+3.0σ)", color = colBand3, linewidth = 1, style = plot.style_linebr)
p_s3 = plot(showBands3 ? plotS3 : na, "S3 Band (-3.0σ)", color = colBand3, linewidth = 1, style = plot.style_linebr)

// Shaded Value Cloud
fill(p_r1, p_s1, color = fillValueCloud and showBands1 ? cloudColor : na, title = "Value Zone Cloud (R1 - S1)")

// Small Cycle Reset Dots on the chart
plotshape(showCycleMarkers and isNewCycle, title = "New Cycle Anchor Marker", style = shape.circle,
     location = location.belowbar, color = color.new(#fbc02d, 40), size = size.tiny)


// ============================================================================
// SECTION 5: REAL-TIME RIGHT-SIDE PRICE TAGS & HUD
// ============================================================================

var label tagVwap = na
var label tagR1   = na
var label tagS1   = na
var label tagR2   = na
var label tagS2   = na

if showRightPriceTags and barstate.islast
    int xPos = bar_index + 3

    // VWAP Center Label
    string txtVwap = "VWAP: " + str.tostring(flexVwap, format.mintick)
    if na(tagVwap)
        tagVwap := label.new(xPos, flexVwap, txtVwap, color = activeVwapCol, textcolor = color.white, style = label.style_label_left, size = size.small)
    else
        label.set_xy(tagVwap, xPos, flexVwap)
        label.set_text(tagVwap, txtVwap)
        label.set_color(tagVwap, activeVwapCol)

    // R1 Label
    if showBands1
        string txtR1 = "R1: " + str.tostring(r1, format.mintick)
        if na(tagR1)
            tagR1 := label.new(xPos, r1, txtR1, color = colBand1, textcolor = color.white, style = label.style_label_left, size = size.small)
        else
            label.set_xy(tagR1, xPos, r1)
            label.set_text(tagR1, txtR1)

        string txtS1 = "S1: " + str.tostring(s1, format.mintick)
        if na(tagS1)
            tagS1 := label.new(xPos, s1, txtS1, color = colBand1, textcolor = color.white, style = label.style_label_left, size = size.small)
        else
            label.set_xy(tagS1, xPos, s1)
            label.set_text(tagS1, txtS1)

    // R2 Label
    if showBands2
        string txtR2 = "R2: " + str.tostring(r2, format.mintick)
        if na(tagR2)
            tagR2 := label.new(xPos, r2, txtR2, color = colBand2, textcolor = color.white, style = label.style_label_left, size = size.small)
        else
            label.set_xy(tagR2, xPos, r2)
            label.set_text(tagR2, txtR2)

        string txtS2 = "S2: " + str.tostring(s2, format.mintick)
        if na(tagS2)
            tagS2 := label.new(xPos, s2, txtS2, color = colBand2, textcolor = color.white, style = label.style_label_left, size = size.small)
        else
            label.set_xy(tagS2, xPos, s2)
            label.set_text(tagS2, txtS2)

// HUD Status Table in Corner
f_getHudPos(string pos) =>
    switch pos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>                position.top_right

var table hud = table.new(f_getHudPos(hudPos), 2, 3, bgcolor = color.new(#131722, 15), border_width = 1, border_color = #2a2e39)

if barstate.islast and showHudStatus
    color hdrBg = color.new(#1e222d, 10)
    color rowBg = color.new(#131722, 10)

    table.cell(hud, 0, 0, "FLEX VWAP", bgcolor = hdrBg, text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 0, "DYNAMIC",   bgcolor = hdrBg, text_color = #00e676,     text_size = size.small)

    table.cell(hud, 0, 1, "ANCHOR MODE", bgcolor = rowBg, text_color = color.gray, text_size = size.small)
    table.cell(hud, 1, 1, anchorMode, bgcolor = rowBg, text_color = color.white, text_size = size.small)

    string cycleText = anchorMode == "Bar Cycle (Micro Wave)" ? "BAR " + str.tostring(barCounter) + " / " + str.tostring(barCycleLen) : (anchorMode == "Volume Threshold" ? str.tostring(math.round(accumulatedVol)) + " / " + str.tostring(math.round(volMilestone)) : "ACTIVE")
    table.cell(hud, 0, 2, "CYCLE PROGRESS", bgcolor = rowBg, text_color = color.gray, text_size = size.small)
    table.cell(hud, 1, 2, cycleText, bgcolor = rowBg, text_color = #fbc02d, text_size = size.small)


// ============================================================================
// SECTION 6: TRADINGVIEW ALERTS
// ============================================================================

bool alertCrossOverVwap  = ta.crossover(close, flexVwap)
bool alertCrossUnderVwap = ta.crossunder(close, flexVwap)
bool alertTouchR1        = ta.crossover(high, r1)
bool alertTouchS1        = ta.crossunder(low, s1)
bool alertTouchR2        = ta.crossover(high, r2)
bool alertTouchS2        = ta.crossunder(low, s2)

alertcondition(alertCrossOverVwap,  "Flex VWAP: Bullish Cross Over",       "Price crossed ABOVE Flex VWAP Center on {{ticker}} at {{close}}")
alertcondition(alertCrossUnderVwap, "Flex VWAP: Bearish Cross Under",      "Price crossed BELOW Flex VWAP Center on {{ticker}} at {{close}}")
alertcondition(alertTouchR1,        "Flex VWAP: Upper R1 Band (+1σ) Touch", "Price touched Upper R1 Standard Deviation Band on {{ticker}} at {{high}}")
alertcondition(alertTouchS1,        "Flex VWAP: Lower S1 Band (-1σ) Touch", "Price touched Lower S1 Standard Deviation Band on {{ticker}} at {{low}}")
alertcondition(alertTouchR2,        "Flex VWAP: Upper R2 Band (+2σ) Touch", "Price reached Upper R2 Overbought Band on {{ticker}} at {{high}}")
alertcondition(alertTouchS2,        "Flex VWAP: Lower S2 Band (-2σ) Touch", "Price reached Lower S2 Oversold Band on {{ticker}} at {{low}}")
alertcondition(isNewCycle,          "Flex VWAP: New Cycle Anchor Reset",    "Flex VWAP anchor has reset for a new market cycle on {{ticker}}")
````
