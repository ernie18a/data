# Hot zones Profile [Cartel Console]

- url: https://www.tradingview.com/script/8YpfUIKd-Hot-zones-Profile-Cartel-Console/
- type: indicator
- pine_id: PUB;ac563a3c9f2f410984d0664e912ee58f
- version: 1.0

## Description

Overview
The Hot Zones Profile [Cartel Console] is a comprehensive market analysis tool designed to identify institutional interest areas through three primary lenses: Time-based Session Ranges, Volume Distribution (LVNs), and Delta-based Volume Profiles.

By combining session-specific volatility with historical volume gaps, this indicator highlights "Hot Zones" where price has historically moved quickly or is expected to find significant reaction levels.

Key Features

1. NY Session & Volatility Zones
The script tracks a specific user-defined time window (defaulting to the New York session transition). Once the session range is established, it projects a series of "Heatmap" levels based on standard deviations and range multipliers.

Bullish/Bearish Zones: Areas projected above and below the session range to identify potential overextension or reversal points.
Customization: Users can define the session time, timezone, and the extension length of these zones.
2. Heatmap Low Volume Nodes (LVN)
Market Profile theory suggests that Low Volume Nodes represent areas where price moved rapidly, often indicating a lack of auctioning or "unfair" prices.

Dynamic Detection: The script analyzes daily volume distribution to pinpoint these gaps.
Mitigation Logic: Zones can be set to "Fade" once price has re-tested and traded through them, helping traders identify which levels are still "fresh" and which have been mitigated.
Aesthetic Heatmaps: Uses glowing box visuals to represent the strength and location of these nodes.
3. Right-Side Delta Volume Profile
To provide a clear view of the current auction, the script plots a high-resolution Volume Profile on the right side of the chart.

Buy/Sell Delta: Unlike standard profiles, this highlights the "Stacked Delta," showing the ratio of buying vs. selling volume at every price level within the lookback period.
Volume Labels: Displays precise volume metrics (in Thousands) for high-activity nodes to assist in identifying Point of Control (POC) areas.
How to Use

Supply & Demand: Use the LVN zones as potential "magnets" or "rejection" zones where liquidity may be resting.
Session Bias: Use the NY Session boxes to define the intraday range and look for "Hot Zone" extensions for potential trend exhaustion.
Volume Confirmation: Observe the Right-Side Profile to see if price is currently trading in high-volume areas (balance) or low-volume areas (imbalance).
Settings

Session Time: Set your preferred anchor time (defaults to NY).
LVN Strength: Adjust how "quiet" a price level must be to qualify as a Low Volume Node.
VP Offset: Move the profile further right to clear space for price action.
Disclaimer:
This indicator is a tool for technical analysis and does not constitute financial advice. Always use proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CartelConsole

//@version=6
indicator("Hot zones Profile [Cartel Console]", "Hot zones profile", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// --- CONSTANTS & COLORS ---
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color BULL_CLR    = #089981
color BEAR_CLR    = #f23645
color NEUTRAL_CLR = #5b9cf6
color GOLD_CLR    = #f2a900
color TRANS_CLR   = color.new(color.white, 100)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// --- INPUTS ---
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// --- NY Session & Zones ---
grp_zones    = "NY Session & Zones"
sessionInput = input.session("1600-1700", "Session Time", group = grp_zones, tooltip = "The time range to calculate the high and low. Use NY time.")
timezone     = input.string("America/New_York", "Timezone", group = grp_zones, tooltip = "The timezone for the session.")
boxWidth     = input.int(40, "Box Extension (Bars)", minval = 1, group = grp_zones)
sessionColor = input.color(color.new(GOLD_CLR, 90), "Session Range Fill", group = grp_zones)

// --- LVN Logic ---
grp_lvn      = "Heatmap LVN Zones"
rowCount     = input.int(50, "Profile Rows", minval = 20, maxval = 200, group = grp_lvn)
lvnStrength  = input.float(0.1, "LVN Strength", minval = 0.1, maxval = 1.0, step = 0.05, group = grp_lvn)
zoneMult     = input.float(1.2, "Zone Height Multiplier", minval = 0.1, step = 0.1, group = grp_lvn)
lvnZoneColor = input.color(color.new(GOLD_CLR, 80), "LVN Base Color", group = grp_lvn)
mitFade      = input.bool(true, "Fade Mitigated Zones", group = grp_lvn)

// --- Heatmap Volume Profile (Right Side) ---
grp_vp       = "Heatmap Volume Profile"
showVP       = input.bool(true, "Show Profile", group = grp_vp)
vpLookback   = input.int(150, "Lookback (Bars)", minval = 10, group = grp_vp)
vpRows       = input.int(40, "VP Rows", minval = 10, maxval = 100, group = grp_vp)
vpWidth      = input.int(30, "Max Width (Bars)", minval = 5, group = grp_vp)
vpOffset     = input.int(20, "Offset from Current (Bars)", minval = 0, group = grp_vp, tooltip = "Distance of the Volume Profile from the latest bar.")
upVolColor   = input.color(color.new(BULL_CLR, 30), "Buy Volume", group = grp_vp)
dnVolColor   = input.color(color.new(BEAR_CLR, 30), "Sell Volume", group = grp_vp)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// --- STATE & UTILS ---
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float sessionHigh     = na
var float sessionLow      = na
var int   sessionStartBar = na

// LVN State
var float dayHigh = high
var float dayLow  = low
var float[] prices  = array.new_float()
var float[] volumes = array.new_float()
var box[] activeBoxes     = array.new_box()
var box[] currentDayBoxes = array.new_box()

// VP Persistence
var box[] vpBoxes     = array.new_box()
var label[] vpLabels  = array.new_label()

// Profile Metrics
vpHigh_global = ta.highest(vpLookback)
vpLow_global  = ta.lowest(vpLookback)

// Heatmap Helper
f_createHeatmapBox(left, top, right, bottom, baseColor) =>
    // Main fill
    box.new(left, top, right, bottom, bgcolor = color.new(baseColor, 85), border_color = color.new(baseColor, 60))
    // Glow layers
    float mid = (top + bottom) / 2
    float h = (top - bottom)
    box.new(left, mid + h*0.2, right, mid - h*0.2, bgcolor = color.new(baseColor, 75), border_color = TRANS_CLR)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// --- SESSION LOGIC ---
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

t = time(timeframe.period, sessionInput, timezone)
isSession = not na(t)
isNewSession = isSession and not isSession[1]
isSessionEnd = not isSession and isSession[1]

if isNewSession
    sessionHigh     := high
    sessionLow      := low
    sessionStartBar := bar_index
else if isSession
    sessionHigh := math.max(sessionHigh, high)
    sessionLow  := math.min(sessionLow, low)

if isSessionEnd and not na(sessionHigh)
    float sRange = sessionHigh - sessionLow
    int endBar   = bar_index - 1
    int extBar   = endBar + boxWidth
    
    // Aesthetic Session Box
    box.new(sessionStartBar, sessionHigh, endBar, sessionLow, bgcolor = sessionColor, border_color = color.new(GOLD_CLR, 50), border_style = line.style_dotted)
    
    // Calculated Zones with Heatmap look
    float[] levels = array.from(5.2, 4.7, 2.9, 2.3, -2.3, -2.9, -4.7, -5.2)
    color[] colors = array.from(BEAR_CLR, BEAR_CLR, NEUTRAL_CLR, NEUTRAL_CLR, NEUTRAL_CLR, NEUTRAL_CLR, BULL_CLR, BULL_CLR)
    
    for i = 0 to 6 by 2
        float y1 = i < 4 ? sessionHigh + array.get(levels, i) * sRange : sessionLow + array.get(levels, i) * sRange
        float y2 = i < 4 ? sessionHigh + array.get(levels, i+1) * sRange : sessionLow + array.get(levels, i+1) * sRange
        f_createHeatmapBox(endBar, y1, extBar, y2, array.get(colors, i))

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// --- LVN LOGIC ---
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isNewDay = timeframe.change("D")

if isNewDay
    array.clear(currentDayBoxes)
    if array.size(prices) > 10
        pRange = dayHigh - dayLow
        binSize = pRange / rowCount
        if binSize > 0
            float[] binVols = array.new_float(rowCount, 0.0)
            for i = 0 to array.size(prices) - 1
                int idx = int(math.max(0, math.min(rowCount - 1, math.floor((array.get(prices, i) - dayLow) / binSize))))
                array.set(binVols, idx, array.get(binVols, idx) + array.get(volumes, i))

            for i = 2 to rowCount - 3
                lAvg = (array.get(binVols, i-1) + array.get(binVols, i-2)) / 2
                rAvg = (array.get(binVols, i+1) + array.get(binVols, i+2)) / 2
                if array.get(binVols, i) < lAvg * lvnStrength and array.get(binVols, i) < rAvg * lvnStrength
                    lvnP = dayLow + (i + 0.5) * binSize
                    hH = (binSize * zoneMult) / 2
                    bx = box.new(bar_index, lvnP + hH, bar_index, lvnP - hH, bgcolor = color.new(lvnZoneColor, 85), border_color = color.new(lvnZoneColor, 50))
                    array.push(activeBoxes, bx)
                    array.push(currentDayBoxes, bx)

    dayHigh := high, dayLow := low
    array.clear(prices), array.clear(volumes)

dayHigh := math.max(dayHigh, high), dayLow := math.min(dayLow, low)
array.push(prices, close), array.push(volumes, volume)

for bx in currentDayBoxes
    box.set_right(bx, bar_index)

if mitFade and array.size(activeBoxes) > 0
    for i = array.size(activeBoxes) - 1 to 0
        bx = array.get(activeBoxes, i)
        if (close > box.get_top(bx) and close[1] <= box.get_top(bx)) or (close < box.get_bottom(bx) and close[1] >= box.get_bottom(bx))
            box.set_bgcolor(bx, color.new(color.gray, 95))
            box.set_border_color(bx, color.new(color.gray, 90))
            array.remove(activeBoxes, i)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// --- HEATMAP VOLUME PROFILE (RIGHT SIDE) ---
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showVP and barstate.islast
    // Cleanup previous objects
    for b in vpBoxes
        box.delete(b)
    array.clear(vpBoxes)
    for l in vpLabels
        label.delete(l)
    array.clear(vpLabels)

    vH = vpHigh_global, vL = vpLow_global
    bS = (vH - vL) / vpRows
    if bS > 0
        float[] upBins = array.new_float(vpRows, 0.0)
        float[] dnBins = array.new_float(vpRows, 0.0)
        for i = 0 to vpLookback - 1
            int idx = int(math.max(0, math.min(vpRows - 1, math.floor((close[i] - vL) / bS))))
            if close[i] >= (i < vpLookback - 1 ? open[i] : close[i+1])
                array.set(upBins, idx, array.get(upBins, idx) + volume[i])
            else
                array.set(dnBins, idx, array.get(dnBins, idx) + volume[i])
        
        maxV = 0.0
        for i = 0 to vpRows - 1
            maxV := math.max(maxV, array.get(upBins, i) + array.get(dnBins, i))
        
        if maxV > 0
            for i = 0 to vpRows - 1
                uV = array.get(upBins, i)
                dV = array.get(dnBins, i)
                totalV = uV + dV
                if totalV > 0
                    yMid = vL + (i + 0.5) * bS
                    uW = math.round((uV / maxV) * vpWidth)
                    dW = math.round((dV / maxV) * vpWidth)
                    
                    // Heatmap Bars (Stacked Delta Style)
                    array.push(vpBoxes, box.new(bar_index + vpOffset, yMid + bS*0.4, bar_index + vpOffset + uW, yMid - bS*0.4, 
                             bgcolor = upVolColor, border_color = TRANS_CLR))
                    array.push(vpBoxes, box.new(bar_index + vpOffset + uW, yMid + bS*0.4, bar_index + vpOffset + uW + dW, yMid - bS*0.4, 
                             bgcolor = dnVolColor, border_color = TRANS_CLR))
                    
                    if totalV > maxV * 0.1
                        array.push(vpLabels, label.new(bar_index + vpOffset + 1 + uW + dW, yMid, str.tostring(totalV/1000, "#.#") + "K", 
                                 color = TRANS_CLR, textcolor = chart.fg_color, style = label.style_label_left, size = size.tiny))

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// --- DASHBOARD / CLEANUP ---
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(close, "Ref", color = TRANS_CLR, display = display.none)
````
