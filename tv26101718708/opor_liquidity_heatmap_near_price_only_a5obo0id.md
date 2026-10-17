# Opor Liquidity Heatmap  - Near Price Only

- url: https://www.tradingview.com/script/a5obO0Id-Opor-Liquidity-Heatmap-Near-Price-Only/
- type: indicator
- pine_id: PUB;08b07d92d93e4aeb9665506fd36dc0e3
- version: 1.0

## Description

How to Use – Opor Liquidity Heatmap
🔎 Overview
This tool is designed to visualize liquidity zones (stop-loss clusters) in the market.
🔴 Red Zones = Buy-side liquidity (areas where buyers may get stopped out)
🟢 Green Zones = Sell-side liquidity (areas where sellers may get stopped out)
These zones represent potential targets where price is likely to move before reversing.
🧠 Core Concept
The market does not move randomly.
It moves to collect liquidity first, then makes the real move.
This tool helps you identify where liquidity is located, not where to enter immediately.
⚠️ Important
❌ This is NOT a buy/sell signal indicator
❌ Do NOT trade just because price touches a zone
✔ This is a context tool to guide your decision-making
🎯 Step-by-Step Usage
1. Identify the Nearest Liquidity
Use the dashboard:
Upper Dist → distance to upper liquidity
Lower Dist → distance to lower liquidity
👉 Price often moves toward the closer liquidity first
2. Wait for Price to Reach the Zone
Do nothing until price enters:
🔴 Upper (red) zone
🟢 Lower (green) zone
3. Wait for Confirmation
Only consider a trade when BOTH occur:
✔ Sweep (liquidity grab / stop hunt)
✔ Rejection candle (strong wick or reversal candle)
4. Execute with Precision
🔴 Sell Setup
Price enters red zone
Sweep high occurs
Bearish rejection appears
👉 Look for short entries
🟢 Buy Setup
Price enters green zone
Sweep low occurs
Bullish rejection appears
👉 Look for long entries
💡 Pro Insight
Liquidity zones are targets, not entries.
The edge comes from:
Waiting for liquidity to be taken
Entering only after confirmation
🚫 When NOT to Trade
Price is between zones (middle of the range)
No sweep has occurred
No clear rejection candle
Structure is unclear
👉 In these cases: No trade
🧩 Best Practice
Combine this tool with:
Market structure (W / M / H&S / flags)
Multi-timeframe analysis
Risk-to-reward validation (RR ≥ 3:1)
🔥 Summary
Find liquidity → Wait → Confirm → Execute

## Source Code

````pine
//@version=6
indicator("Opor Liquidity Heatmap V3 - Near Price Only", overlay=true, max_boxes_count=200, max_lines_count=100, max_labels_count=50)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPOR LIQUIDITY HEATMAP V3 - NEAR PRICE ONLY
// Purpose:
// - วาดเฉพาะ Liquidity Zone ที่อยู่ใกล้ราคาปัจจุบัน
// - ลดความรกบนกราฟ
// - โฟกัสเฉพาะโซนที่มีโอกาสเกี่ยวข้องกับไม้ถัดไป
// - สีแดง = liquidity ด้านบน / สีเขียว = liquidity ด้านล่าง
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// INPUTS
lookbackBars   = input.int(200, "Lookback Bars", minval=30, maxval=800)
wickRatio      = input.float(1.5, "Wick / Body Ratio", minval=0.5, step=0.1)
minWickAtr     = input.float(0.25, "Min Wick Size ATR", minval=0.05, step=0.05)
zoneHeightAtr  = input.float(0.22, "Zone Height ATR", minval=0.03, step=0.03)
zoneExtendBars = input.int(60, "Extend Zone To Right", minval=10, maxval=300)

nearRangeAtr   = input.float(4.0, "Only Show Zones Within ATR", minval=0.5, step=0.5)
maxZonesSide   = input.int(3, "Max Zones Per Side Near Price", minval=1, maxval=10)
mergeDistanceAtr = input.float(0.35, "Merge Nearby Zones ATR", minval=0.05, step=0.05)

showUpperZones = input.bool(true, "Show Upper Liquidity Zones")
showLowerZones = input.bool(true, "Show Lower Liquidity Zones")
showLabels     = input.bool(true, "Show Nearest Zone Labels")
showDash       = input.bool(true, "Show Dashboard")

upperColor = input.color(color.new(color.red, 82), "Upper Zone Color")
lowerColor = input.color(color.new(color.green, 82), "Lower Zone Color")
borderUpper = input.color(color.new(color.red, 35), "Upper Border")
borderLower = input.color(color.new(color.green, 35), "Lower Border")

atrLen = input.int(14, "ATR Length")
atr = ta.atr(atrLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[] boxes = array.new_box()
var label hiLabel = na
var label loLabel = na

var float nearestUpper = na
var float nearestLower = na
var int upperCount = 0
var int lowerCount = 0

f_clear_boxes() =>
    if array.size(boxes) > 0
        for i = array.size(boxes) - 1 to 0
            box.delete(array.get(boxes, i))
        array.clear(boxes)

f_is_merged(_level, _isUpper) =>
    bool merged = false
    if array.size(boxes) > 0
        for j = 0 to array.size(boxes) - 1
            b = array.get(boxes, j)
            mid = (box.get_top(b) + box.get_bottom(b)) / 2.0
            if math.abs(_level - mid) <= atr * mergeDistanceAtr
                merged := true
    merged

f_add_zone(_left, _level, _isUpper, _strength) =>
    h = atr * zoneHeightAtr * math.min(_strength, 3.0)
    top = _level + h
    bottom = _level - h
    bg = _isUpper ? upperColor : lowerColor
    brd = _isUpper ? borderUpper : borderLower
    b = box.new(left=_left, top=top, right=bar_index + zoneExtendBars, bottom=bottom, bgcolor=bg, border_color=brd, border_width=1)
    array.push(boxes, b)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DETECT + DRAW ONLY NEAR CURRENT PRICE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast
    f_clear_boxes()
    upperCount := 0
    lowerCount := 0
    nearestUpper := na
    nearestLower := na

    if not na(hiLabel)
        label.delete(hiLabel)
    if not na(loLabel)
        label.delete(loLabel)

    // scan recent bars from recent to older
    for i = 1 to lookbackBars
        body = math.abs(close[i] - open[i])
        bodySafe = math.max(body, syminfo.mintick)
        upWick = high[i] - math.max(open[i], close[i])
        lowWick = math.min(open[i], close[i]) - low[i]

        upperLevel = high[i]
        lowerLevel = low[i]

        upperNearCurrent = upperLevel > close and upperLevel <= close + atr * nearRangeAtr
        lowerNearCurrent = lowerLevel < close and lowerLevel >= close - atr * nearRangeAtr

        upperOK = showUpperZones and upperCount < maxZonesSide and upperNearCurrent and upWick / bodySafe >= wickRatio and upWick >= atr * minWickAtr
        lowerOK = showLowerZones and lowerCount < maxZonesSide and lowerNearCurrent and lowWick / bodySafe >= wickRatio and lowWick >= atr * minWickAtr

        if upperOK and not f_is_merged(upperLevel, true)
            strength = upWick / bodySafe
            f_add_zone(bar_index - i, upperLevel, true, strength)
            upperCount += 1
            if na(nearestUpper) or upperLevel < nearestUpper
                nearestUpper := upperLevel

        if lowerOK and not f_is_merged(lowerLevel, false)
            strength = lowWick / bodySafe
            f_add_zone(bar_index - i, lowerLevel, false, strength)
            lowerCount += 1
            if na(nearestLower) or lowerLevel > nearestLower
                nearestLower := lowerLevel

    if showLabels
        if not na(nearestUpper)
            hiLabel := label.new(bar_index + zoneExtendBars, nearestUpper, "Nearest Upper LQ", style=label.style_label_left, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
        if not na(nearestLower)
            loLabel := label.new(bar_index + zoneExtendBars, nearestLower, "Nearest Lower LQ", style=label.style_label_left, color=color.new(color.green, 0), textcolor=color.white, size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT PRICE NEAR NEAREST ZONE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
nearLatestUpper = not na(nearestUpper) and high >= nearestUpper - atr * zoneHeightAtr * 2
nearLatestLower = not na(nearestLower) and low <= nearestLower + atr * zoneHeightAtr * 2

plotshape(nearLatestUpper, title="Near Upper Liquidity", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), text="LQ", textcolor=color.white, size=size.tiny)
plotshape(nearLatestLower, title="Near Lower Liquidity", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), text="LQ", textcolor=color.white, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(position.top_right, 2, 5, border_width=1)

upperDistance = not na(nearestUpper) ? (nearestUpper - close) / atr : na
lowerDistance = not na(nearestLower) ? (close - nearestLower) / atr : na

if showDash and barstate.islast
    table.cell(dash, 0, 0, "OPOR", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0, "NEAR LQ HEATMAP", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 0, 1, "Upper Zones", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 1, str.tostring(upperCount), bgcolor=color.new(color.red, 75), text_color=color.white)
    table.cell(dash, 0, 2, "Lower Zones", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(lowerCount), bgcolor=color.new(color.green, 75), text_color=color.white)
    table.cell(dash, 0, 3, "Upper Dist", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 3, not na(upperDistance) ? str.tostring(upperDistance, "#.##") + " ATR" : "-", bgcolor=color.new(color.red, 82), text_color=color.white)
    table.cell(dash, 0, 4, "Lower Dist", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 4, not na(lowerDistance) ? str.tostring(lowerDistance, "#.##") + " ATR" : "-", bgcolor=color.new(color.green, 82), text_color=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(nearLatestUpper, title="Near Upper Liquidity", message="Price is near nearest upper liquidity zone. Wait for sweep/rejection.")
alertcondition(nearLatestLower, title="Near Lower Liquidity", message="Price is near nearest lower liquidity zone. Wait for sweep/rejection.")

// NOTES:
// - ตัวนี้วาดเฉพาะโซนใกล้ราคาปัจจุบัน
// - ปรับ Only Show Zones Within ATR ให้กว้าง/แคบตามต้องการ
// - Max Zones Per Side คุมจำนวนกล่องต่อฝั่ง
// - Merge Nearby Zones ATR ใช้รวมโซนที่ใกล้กันเพื่อลดความรก
// - สีแดง/เขียวคือ liquidity area ไม่ใช่สัญญาณเข้า
````
