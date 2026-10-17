# vutruhanghoa1

- url: https://www.tradingview.com/script/2rpPpw28-vutruhanghoa1/
- type: indicator
- pine_id: PUB;9382b6103eb34300b3f456ad3a5dad85
- version: 1.0

## Description

### Overview

The **Sonic R System with Dynamic Support and Resistance** is an all-in-one trend-following and structural analysis indicator designed to help traders identify clear market trends, dynamic momentum zones, and critical support and resistance levels in real-time.

Based on the classic Sonic R trading strategy, this indicator combines the **Sonic Dragon (EMA Band)**, **Trend Baseline (EMA 89)**, and **Auto Support and Resistance Levels** to deliver clean, actionable insights directly on your charts.

---

### Key Features

1. **The Sonic Dragon (EMA 34 Band)**
   - Formed by the High, Close, and Low of the 34-period Exponential Moving Average (EMA).
   - Functions as dynamic support and resistance while visualizes short-to-medium term momentum.
   - Ideal for identifying high-probability pullback entry setups ("Wave" and "Dragon" retests).

2. **Trend Baseline (EMA 89)**
   - Acts as the main trend filter and higher-timeframe momentum guide.
   - **Bullish Bias:** Price trades above the EMA 89.
   - **Bearish Bias:** Price trades below the EMA 89.

3. **Dynamic Support and Resistance Levels**
   - Automatically detects and draws key market structure levels using recent swing highs and lows.
   - Highlights horizontal price zones where buyers and sellers historically react, simplifying breakout and bounce trades.

---

### How to Trade with Sonic R

* **Long Setup (Buy):**
  1. Price is trending **above** the EMA 89 (Baseline).
  2. Wait for price to pull back into or touch the **Sonic Dragon** (EMA 34 zone).
  3. Look for confirmation (rejection candle, bullish chart pattern, or bounce off a Support Level).
  4. Target the next major Resistance Level.

* **Short Setup (Sell):**
  1. Price is trending **below** the EMA 89 (Baseline).
  2. Wait for price to rally up into or touch the **Sonic Dragon**.
  3. Look for confirmation (bearish rejection candle, pattern, or bounce off a Resistance Level).
  4. Target the next major Support Level.

---

### Customization Settings

- **Sonic Dragon Settings:** Adjust EMA length (default: 34) and toggle visibility.
- **Baseline Settings:** Change EMA length (default: 89) and visual styling.
- **Support and Resistance:** Customize pivot detection lookback periods, line colors, and line styles to fit any time frame.

---

*Disclaimer: This indicator is designed for educational and informational purposes only. Always use proper risk management and apply stop-loss orders when executing trading strategies.*

## Source Code

````pine
//@version=6
indicator("vutruhanghoa1", overlay=true, max_boxes_count=500, max_labels_count=500)

// ============================================================================
// INPUTS - SONIC R
// ============================================================================
showSonic = input.bool(true, "Show Sonic R (PAC + EMAs)", group="Sonic R")
emaLen    = input.int(89, "EMA Signal", minval=1, group="Sonic R")
hiLoLen   = input.int(34, "High Low channel Length", minval=2, group="Sonic R")

// ============================================================================
// INPUTS - SUPPLY / DEMAND
// ============================================================================
showZones = input.bool(true, "Show Supply/Demand Zones", group="Zone Detection")
swingLen = input.int(12, "Swing Length (Sensitivity)", minval=3, maxval=50, tooltip="Higher = Less zones, more significant", group="Zone Detection")
maxZones = input.int(10, "Max Zones to Display", minval=3, maxval=30, group="Zone Detection")
maxZoneHeightATR = input.float(1.0, "Max Zone Height (ATR Multiplier)", minval=0.5, maxval=10.0, step=0.5, tooltip="Zones larger than this will be clamped", group="Zone Detection")
minZoneHeightATR = input.float(1.0, "Min Zone Height (ATR Multiplier)", minval=0.1, maxval=2.0, step=0.1, tooltip="Zones smaller than this will be rejected", group="Zone Detection")
forceZoneHeightATR = input.float(1.0, "Force Zone Height (ATR Multiplier)", minval=0.2, maxval=3.0, step=0.1, tooltip="All zones will be expanded to at least this height", group="Zone Detection")
minZoneDistance = input.int(44, "Min Distance Between Zones (bars)", minval=1, maxval=100, group="Zone Detection")

invalidationMethod = input.string("Close", "Zone Invalidation", options=["Close", "Wick"], group="Zone Settings")
showHistoric = input.bool(true, "Show Historic Zones", group="Zone Settings")
activeLookback = input.int(1000, "Active Zones Lookback", minval=100, maxval=5000, group="Zone Settings")
historicBars = input.int(1000, "Historic Zones Lookback", minval=100, maxval=5000, group="Zone Settings")

showActiveLabels = input.bool(true, "Show Active Zone Info", group="Display")
showHistoricLabels = input.bool(false, "Show Historic Zone Info", group="Display")
labelSize = input.string("Large", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group="Display")

activeSupplyCol = input.color(color.new(color.red, 80), "Active Supply", group="Colors")
activeDemandCol = input.color(color.new(color.green, 80), "Active Demand", group="Colors")
historicCol = input.color(color.new(color.gray, 85), "Historic Zones", group="Colors")

showRetestMarkers = input.bool(true, "Show Retests", group="Retests")
retestBullCol = input.color(color.new(color.green, 0), "Demand Retest", group="Retests")
retestBearCol = input.color(color.new(color.red, 0), "Supply Retest", group="Retests")

alertsOn = input.bool(true, "Enable Alerts", group="Alerts")

// ============================================================================
// SONIC R
// ============================================================================
sonicDisp = showSonic ? display.all : display.none

pacC = ta.ema(close, hiLoLen)
pacL = ta.ema(low, hiLoLen)
pacH = ta.ema(high, hiLoLen)

dodgerBlue = #1E90FF

// Price Action Channel (PAC): EMA of high, low and close
plotPacL = plot(pacL, "Low PAC EMA", color.new(dodgerBlue, 50), 1, display=sonicDisp)
plotPacH = plot(pacH, "High PAC EMA", color.new(dodgerBlue, 50), 1, display=sonicDisp)
plot(pacC, "Close PAC EMA", dodgerBlue, 2, display=sonicDisp)
fill(plotPacL, plotPacH, color.new(color.aqua, 90), title="Fill HiLo PAC", display=sonicDisp)

// Moving averages
plot(ta.ema(close, 610), "EMA 610", color.white, 1, display=sonicDisp)
plot(ta.ema(close, 200), "EMA 200", color.fuchsia, 1, display=sonicDisp)
plot(ta.ema(close, emaLen), "EMA Signal", color.orange, 4, display=sonicDisp)

// ============================================================================
// FUNCTIONS
// ============================================================================
f_getPips() =>
    syminfo.type == "forex" ? (syminfo.currency == "JPY" ? 0.01 : 0.0001) : (syminfo.ticker == "XAUUSD" or syminfo.ticker == "GOLD") ? 0.1 : 0.0001

f_toPips(val) =>
    math.abs(val) / f_getPips()

f_getSession() =>
    h = hour(time, syminfo.timezone)
    h >= 0 and h < 9 ? "Asian" : h >= 8 and h < 13 ? "London" : h >= 13 and h < 22 ? "New York" : "Other"

f_getLabelSize() =>
    labelSize == "Tiny" ? size.tiny : labelSize == "Small" ? size.small : labelSize == "Normal" ? size.normal : size.large

f_calcStrength(retests, age) =>
    strVal = 8.0 - (retests * 0.8) - math.min(age / 500.0, 2.0)
    int(math.max(0, math.min(10, strVal)))

f_getLabelColor(zoneType, broken) =>
    if broken
        color.new(color.gray, 0)
    else
        zoneType == "Supply" ? color.new(color.red, 0) : color.new(color.green, 0)

// ============================================================================
// ATR for zone height filtering
// ============================================================================
atr = ta.atr(20)

// ============================================================================
// ZONE STORAGE
// ============================================================================
type ZoneData
    box zoneBox
    label infoLabel
    label retestLabel
    float top
    float bottom
    int startBar
    string session
    int retests
    bool broken
    string zoneType
    bool retestCounted

var array<ZoneData> allZones = array.new<ZoneData>()
var int lastSupplyBar = 0
var int lastDemandBar = 0

// ============================================================================
// ZONE DETECTION
// ============================================================================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

// Create Supply Zone - only on confirmed bar
if showZones and not na(ph) and barstate.isconfirmed
    sess = f_getSession()
    if sess != "Other"
        top = high[swingLen]
        bot = low[swingLen]
        startBar = bar_index - swingLen

        if bar_index - lastSupplyBar >= minZoneDistance
            mid = (top + bot) / 2
            zoneHeight = top - bot

            // Force minimum height - expand thin zones
            if zoneHeight < atr * forceZoneHeightATR
                forcedHeight = atr * forceZoneHeightATR
                top := mid + (forcedHeight / 2)
                bot := mid - (forcedHeight / 2)
                zoneHeight := forcedHeight

            // Clamp if too large
            if zoneHeight > atr * maxZoneHeightATR
                maxHeight = atr * maxZoneHeightATR
                top := mid + (maxHeight / 2)
                bot := mid - (maxHeight / 2)
                zoneHeight := maxHeight

            // Reject if still too small
            if zoneHeight >= atr * minZoneHeightATR

                // Merge with overlapping existing zones
                mergedWithExisting = false
                if array.size(allZones) > 0
                    for i = array.size(allZones) - 1 to math.max(0, array.size(allZones) - 10)
                        z = array.get(allZones, i)
                        if z.zoneType == "Supply" and not z.broken
                            zonesOverlap = (top >= z.bottom and bot <= z.top)
                            if zonesOverlap
                                newTop = math.max(top, z.top)
                                newBot = math.min(bot, z.bottom)
                                z.top := newTop
                                z.bottom := newBot
                                box.set_top(z.zoneBox, newTop)
                                box.set_bottom(z.zoneBox, newBot)
                                mergedWithExisting := true
                                break

                if not mergedWithExisting
                    zoneBox = box.new(startBar, top, bar_index + 400, bot, bgcolor=activeSupplyCol, border_width=0)
                    zoneData = ZoneData.new(zoneBox, na, na, top, bot, startBar, sess, 0, false, "Supply", false)
                    array.push(allZones, zoneData)
                    lastSupplyBar := bar_index

                    if array.size(allZones) > maxZones * 4
                        array.shift(allZones)

// Create Demand Zone - only on confirmed bar
if showZones and not na(pl) and barstate.isconfirmed
    sess = f_getSession()
    if sess != "Other"
        top = high[swingLen]
        bot = low[swingLen]
        startBar = bar_index - swingLen

        if bar_index - lastDemandBar >= minZoneDistance
            mid = (top + bot) / 2
            zoneHeight = top - bot

            if zoneHeight < atr * forceZoneHeightATR
                forcedHeight = atr * forceZoneHeightATR
                top := mid + (forcedHeight / 2)
                bot := mid - (forcedHeight / 2)
                zoneHeight := forcedHeight

            if zoneHeight > atr * maxZoneHeightATR
                maxHeight = atr * maxZoneHeightATR
                top := mid + (maxHeight / 2)
                bot := mid - (maxHeight / 2)
                zoneHeight := maxHeight

            if zoneHeight >= atr * minZoneHeightATR

                mergedWithExisting = false
                if array.size(allZones) > 0
                    for i = array.size(allZones) - 1 to math.max(0, array.size(allZones) - 10)
                        z = array.get(allZones, i)
                        if z.zoneType == "Demand" and not z.broken
                            zonesOverlap = (top >= z.bottom and bot <= z.top)
                            if zonesOverlap
                                newTop = math.max(top, z.top)
                                newBot = math.min(bot, z.bottom)
                                z.top := newTop
                                z.bottom := newBot
                                box.set_top(z.zoneBox, newTop)
                                box.set_bottom(z.zoneBox, newBot)
                                mergedWithExisting := true
                                break

                if not mergedWithExisting
                    zoneBox = box.new(startBar, top, bar_index + 400, bot, bgcolor=activeDemandCol, border_width=0)
                    zoneData = ZoneData.new(zoneBox, na, na, top, bot, startBar, sess, 0, false, "Demand", false)
                    array.push(allZones, zoneData)
                    lastDemandBar := bar_index

                    if array.size(allZones) > maxZones * 4
                        array.shift(allZones)

// ============================================================================
// UPDATE ZONES
// ============================================================================
if showZones and array.size(allZones) > 0
    activeSupplyCount = 0
    activeDemandCount = 0
    historicSupplyCount = 0
    historicDemandCount = 0

    for i = 0 to array.size(allZones) - 1
        z = array.get(allZones, i)

        // Extend box to current bar + extra space for labels
        box.set_right(z.zoneBox, bar_index + 400)

        // Retest - only count once per touch
        if not z.broken
            priceInZone = high >= z.bottom and low <= z.top
            if priceInZone and not z.retestCounted
                z.retests += 1
                z.retestCounted := true
            else if not priceInZone
                z.retestCounted := false

        // Invalidation
        if not z.broken
            if z.zoneType == "Supply"
                breakLevel = invalidationMethod == "Close" ? close : high
                if breakLevel > z.top
                    z.broken := true
                    box.set_bgcolor(z.zoneBox, historicCol)
            else
                breakLevel = invalidationMethod == "Close" ? close : low
                if breakLevel < z.bottom
                    z.broken := true
                    box.set_bgcolor(z.zoneBox, historicCol)

        // Zone metrics
        age = bar_index - z.startBar
        zoneHeight = z.top - z.bottom

        shouldHide = false

        if z.broken and not showHistoric
            shouldHide := true

        if z.broken and age > historicBars
            shouldHide := true
        if not z.broken and age > activeLookback
            shouldHide := true

        // Quality rules for historic zones
        if z.broken and showHistoric
            if zoneHeight < atr * minZoneHeightATR
                shouldHide := true

            if z.zoneType == "Supply"
                if historicSupplyCount >= maxZones
                    shouldHide := true
                else if not shouldHide
                    historicSupplyCount += 1
            else
                if historicDemandCount >= maxZones
                    shouldHide := true
                else if not shouldHide
                    historicDemandCount += 1

        // Count active zones
        if not z.broken and not shouldHide
            if z.zoneType == "Supply"
                if activeSupplyCount >= maxZones
                    shouldHide := true
                else
                    activeSupplyCount += 1
            else
                if activeDemandCount >= maxZones
                    shouldHide := true
                else
                    activeDemandCount += 1

        // Visibility
        if shouldHide
            box.set_bgcolor(z.zoneBox, color.new(color.gray, 100))
            box.set_border_color(z.zoneBox, color.new(color.gray, 100))
            if not na(z.infoLabel)
                label.set_color(z.infoLabel, color.new(color.black, 100))
                label.set_textcolor(z.infoLabel, color.new(color.white, 100))
            if not na(z.retestLabel)
                label.set_color(z.retestLabel, color.new(color.white, 100))
                label.set_textcolor(z.retestLabel, color.new(color.white, 100))
        else
            if z.broken
                box.set_bgcolor(z.zoneBox, historicCol)
            else
                zoneCol = z.zoneType == "Supply" ? activeSupplyCol : activeDemandCol
                box.set_bgcolor(z.zoneBox, zoneCol)

            showThisLabel = z.broken ? showHistoricLabels : showActiveLabels

            if showThisLabel
                strength = f_calcStrength(z.retests, age)
                zoneName = z.zoneType == "Supply" ? "Vùng Bán" : "Vùng Mua"
                txt = zoneName + " || Độ mạnh " + str.tostring(strength) + "/10"
                mid = (z.top + z.bottom) / 2
                lblColor = f_getLabelColor(z.zoneType, z.broken)

                if na(z.infoLabel)
                    z.infoLabel := label.new(z.startBar + 10, mid, txt, color=color.new(color.black, 100), textcolor=lblColor, size=f_getLabelSize(), style=label.style_label_left)
                else
                    label.set_text(z.infoLabel, txt)
                    label.set_y(z.infoLabel, mid)
                    label.set_color(z.infoLabel, color.new(color.black, 100))
                    label.set_textcolor(z.infoLabel, lblColor)
                    label.set_size(z.infoLabel, f_getLabelSize())
                    label.set_style(z.infoLabel, label.style_label_left)
                    label.set_x(z.infoLabel, z.startBar + 10)
            else
                if not na(z.infoLabel)
                    label.set_color(z.infoLabel, color.new(color.black, 100))
                    label.set_textcolor(z.infoLabel, color.new(color.white, 100))

            // Retest marker
            if showRetestMarkers and z.retests > 0
                if na(z.retestLabel)
                    if z.zoneType == "Supply"
                        z.retestLabel := label.new(z.startBar + 3, z.top, "R", color=retestBearCol, textcolor=color.white, size=size.small, style=label.style_label_down)
                    else
                        z.retestLabel := label.new(z.startBar + 3, z.bottom, "R", color=retestBullCol, textcolor=color.white, size=size.small, style=label.style_label_up)
                else
                    retestCol = z.zoneType == "Supply" ? retestBearCol : retestBullCol
                    label.set_color(z.retestLabel, retestCol)
                    label.set_textcolor(z.retestLabel, color.white)
            else
                if not na(z.retestLabel)
                    label.set_color(z.retestLabel, color.new(color.white, 100))
                    label.set_textcolor(z.retestLabel, color.new(color.white, 100))

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(showZones and not na(ph) and barstate.isconfirmed and alertsOn, "New Supply Zone", "{{ticker}} - New Supply Zone @ {{close}}")
alertcondition(showZones and not na(pl) and barstate.isconfirmed and alertsOn, "New Demand Zone", "{{ticker}} - New Demand Zone @ {{close}}")
````
