# Volume Profile Analysis

- url: https://www.tradingview.com/script/Q0Wg8Gv4-Volume-Profile-Analysis/
- type: indicator
- pine_id: PUB;cd253d64ff814e3698985a860d66e40e
- version: 1.0

## Description

Volume Profile Analysis 📊

Advanced horizontal volume profile with order size analysis, buy/sell split, POC, and Value Area — all calculated from real tick-level volume delta.

Core Features:

🔹 Bidirectional Volume Profile Horizontal histogram showing volume distribution across price levels. Buy volume extends RIGHT, sell volume extends LEFT from candles. Delta is proportionally distributed across each bar's price range — no inflation.

🔹 Order Size Analysis Automatically categorizes volume into Large (>1.5× SMA) and Small orders using real volume data. Color-coded so you can see institutional vs retail activity at each price level.

🔹 Point of Control (POC) Yellow line marking the price level with the highest volume — the "fair value" where most trading occurred.

🔹 Value Area (VA) Gray zone containing 68% of total volume around the POC. Price tends to revert to this zone. Trading above/below VA indicates imbalance.

🔹 Buy/Sell Split Each profile level shows separate bars for buying and selling pressure. Labels display exact volumes (e.g., "4.5K | 3.2K").

🔹 Large Order Detection Highlights price levels where >75% of volume comes from large orders — potential institutional accumulation/distribution zones.

🔹 Real-Time Dashboard POC, VA High/Low, distance from POC in ATR units, position (Above/Inside/Below VA), current delta, and profile range.

How to Use:

Signal	Meaning
Price at POC	Fair value — range-bound market
Price above VA	Bullish imbalance — may mean-revert down
Price below VA	Bearish imbalance — may mean-revert up
High large order %	Institutional activity — watch for reversals
Buy >> Sell at level	Buyers absorbed selling at that price
Sell >> Buy at level	Sellers absorbed buying at that price
Recommended Settings:

Timeframe: 1S (most precise delta)
Price Levels: 30 (good balance of detail)
Lookback: 100 bars (captures recent session)
Order Size: Enabled (see institutional activity)
Best For: Order flow traders, volume profile traders, identifying support/resistance, detecting institutional activity, understanding where value is established.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Volume Profile with Order Size Analysis — Real delta data, proportional distribution
//@version=6
indicator("Volume Profile Analysis Pro", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

import TradingView/ta/8

// ====================== CORE DATA ======================
grp1 = "⚙️ Core"
useCustomTF = input.bool(true, "Custom timeframe", group=grp1)
customTF    = input.timeframe("1S", "Timeframe", group=grp1, active=useCustomTF)
profileBars = input.int(30, "Price levels", group=grp1, minval=10, maxval=100)
lookback    = input.int(100, "Lookback bars", group=grp1, minval=20, maxval=500)

var lowerTF = switch
    useCustomTF => customTF
    timeframe.isseconds => "1S"
    timeframe.isintraday => "1S"
    timeframe.isdaily    => "1"
    => "5"

[openDelta, maxDelta, minDelta, lastDelta] = ta.requestVolumeDelta(lowerTF)

delta        = lastDelta
total_volume = volume
buy_volume   = math.max((total_volume + delta) / 2, 0)
sell_volume  = math.max((total_volume - delta) / 2, 0)

var float cumVol = 0.0
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("Data vendor doesn't provide volume data for this symbol.")

atr14 = ta.atr(14)
volSMA = ta.sma(volume, 20)

// ====================== DISPLAY SETTINGS ======================
grp2 = "📊 Display"
showProfile   = input.bool(true, "Show volume profile", group=grp2)
showPOC       = input.bool(true, "Show POC line", group=grp2)
showVA        = input.bool(true, "Show Value Area", group=grp2)
showBuySell   = input.bool(true, "Split buy/sell", group=grp2)
showLabels    = input.bool(true, "Show level labels", group=grp2)
profileSide   = input.string("right", "Profile side", options=["left", "right"], group=grp2)

// ====================== ORDER SIZE ======================
grp3 = "📦 Order Size"
useOrderSize  = input.bool(true, "Enable order size analysis", group=grp3)
largeThresh   = input.float(75, "Large order %", group=grp3, minval=50, maxval=95, step=5)

// ====================== COLORS ======================
grp4 = "🎨 Colors"
largeBuyColor  = input.color(color.rgb(0, 180, 255), "Large Buy", group=grp4, inline="ob")
largeSellColor = input.color(color.rgb(255, 80, 80), "Large Sell", group=grp4, inline="ob")
smallBuyColor  = input.color(color.rgb(0, 255, 170), "Small Buy", group=grp4, inline="os")
smallSellColor = input.color(color.rgb(255, 150, 100), "Small Sell", group=grp4, inline="os")
pocColor       = input.color(color.yellow, "POC line", group=grp4)
vaColor        = input.color(color.new(color.gray, 70), "Value Area", group=grp4)

// ====================== ALERTS ======================
grp5 = "🔔 Alerts"
showThreshold  = input.bool(true, "Show large order levels", group=grp5)
alertLarge     = input.bool(false, "Alert on large orders", group=grp5)

// ====================== PROFILE DATA (every bar) ======================
float profileHi    = ta.highest(high, lookback)
float profileLo    = ta.lowest(low, lookback)
float priceRange   = profileHi - profileLo
float lvlStep      = priceRange / profileBars

var float pocPrice = na
var float vaHigh   = na
var float vaLow    = na

var float[] lvlBuyLarge  = array.new_float(0)
var float[] lvlSellLarge = array.new_float(0)
var float[] lvlBuySmall  = array.new_float(0)
var float[] lvlSellSmall = array.new_float(0)
var float[] lvlPrices    = array.new_float(0)

// ====================== DRAWING ======================
var box[]   profBoxes  = array.new<box>()
var label[] profLabels = array.new<label>()
var line[]  profLines  = array.new<line>()

if barstate.islast and showProfile and priceRange > 0
    // Clean up
    if array.size(profBoxes) > 0
        for i = 0 to array.size(profBoxes) - 1
            box.delete(array.get(profBoxes, i))
        array.clear(profBoxes)
    if array.size(profLabels) > 0
        for i = 0 to array.size(profLabels) - 1
            label.delete(array.get(profLabels, i))
        array.clear(profLabels)
    if array.size(profLines) > 0
        for i = 0 to array.size(profLines) - 1
            line.delete(array.get(profLines, i))
        array.clear(profLines)

    // Init arrays
    array.clear(lvlBuyLarge)
    array.clear(lvlSellLarge)
    array.clear(lvlBuySmall)
    array.clear(lvlSellSmall)
    array.clear(lvlPrices)

    for i = 0 to profileBars - 1
        array.push(lvlBuyLarge, 0.0)
        array.push(lvlSellLarge, 0.0)
        array.push(lvlBuySmall, 0.0)
        array.push(lvlSellSmall, 0.0)
        array.push(lvlPrices, profileLo + (i + 0.5) * lvlStep)

    // Distribute volume (proportional)
    float totalBuy = 0.0
    float totalSell = 0.0

    for c = 0 to lookback - 1
        float barHi = high[c]
        float barLo = low[c]
        float barBuy = nz(buy_volume[c])
        float barSell = nz(sell_volume[c])

        int botLvl = math.max(0, int((barLo - profileLo) / lvlStep))
        int topLvl = math.min(profileBars - 1, int((barHi - profileLo) / lvlStep))
        int span = topLvl - botLvl + 1

        if span > 0
            float buyShare = barBuy / span
            float sellShare = barSell / span
            bool isLarge = (barBuy + barSell) > nz(volSMA[c]) * 1.5

            for L = botLvl to topLvl
                if isLarge
                    array.set(lvlBuyLarge, L, array.get(lvlBuyLarge, L) + buyShare)
                    array.set(lvlSellLarge, L, array.get(lvlSellLarge, L) + sellShare)
                else
                    array.set(lvlBuySmall, L, array.get(lvlBuySmall, L) + buyShare)
                    array.set(lvlSellSmall, L, array.get(lvlSellSmall, L) + sellShare)
                totalBuy += buyShare
                totalSell += sellShare

    // Find POC
    float maxVol = 0.0
    int pocIdx = 0
    for i = 0 to profileBars - 1
        float t = array.get(lvlBuyLarge, i) + array.get(lvlSellLarge, i) + array.get(lvlBuySmall, i) + array.get(lvlSellSmall, i)
        if t > maxVol
            maxVol := t
            pocIdx := i
    pocPrice := array.get(lvlPrices, pocIdx)

    // Value Area (68%)
    float totalAllVol = totalBuy + totalSell
    float vaTarget = totalAllVol * 0.68
    float vaAccum = array.get(lvlBuyLarge, pocIdx) + array.get(lvlSellLarge, pocIdx) + array.get(lvlBuySmall, pocIdx) + array.get(lvlSellSmall, pocIdx)
    int vaTopIdx = pocIdx
    int vaBotIdx = pocIdx

    while vaAccum < vaTarget and (vaTopIdx < profileBars - 1 or vaBotIdx > 0)
        float upVol = vaTopIdx < profileBars - 1 ? array.get(lvlBuyLarge, vaTopIdx + 1) + array.get(lvlSellLarge, vaTopIdx + 1) + array.get(lvlBuySmall, vaTopIdx + 1) + array.get(lvlSellSmall, vaTopIdx + 1) : 0.0
        float dnVol = vaBotIdx > 0 ? array.get(lvlBuyLarge, vaBotIdx - 1) + array.get(lvlSellLarge, vaBotIdx - 1) + array.get(lvlBuySmall, vaBotIdx - 1) + array.get(lvlSellSmall, vaBotIdx - 1) : 0.0
        if upVol >= dnVol and vaTopIdx < profileBars - 1
            vaTopIdx += 1
            vaAccum += upVol
        else if vaBotIdx > 0
            vaBotIdx -= 1
            vaAccum += dnVol
        else if vaTopIdx < profileBars - 1
            vaTopIdx += 1
            vaAccum += upVol
        else
            break

    vaHigh := array.get(lvlPrices, vaTopIdx) + lvlStep / 2
    vaLow  := array.get(lvlPrices, vaBotIdx) - lvlStep / 2

    // Max volume for scaling
    float maxLvlVol = 0.0
    for i = 0 to profileBars - 1
        float t = array.get(lvlBuyLarge, i) + array.get(lvlSellLarge, i) + array.get(lvlBuySmall, i) + array.get(lvlSellSmall, i)
        if t > maxLvlVol
            maxLvlVol := t

    if maxLvlVol > 0
        int maxBarLen = 30
        int offset = profileSide == "right" ? 3 : -3

        for i = 0 to profileBars - 1
            float price = array.get(lvlPrices, i)
            float buyL  = array.get(lvlBuyLarge, i)
            float sellL = array.get(lvlSellLarge, i)
            float buyS  = array.get(lvlBuySmall, i)
            float sellS = array.get(lvlSellSmall, i)
            float totalLvl = buyL + sellL + buyS + sellS
            if totalLvl <= 0
                continue

            float scale = totalLvl / maxLvlVol
            float halfH = lvlStep * 0.4

            if showBuySell
                float buyTotal = buyL + buyS
                int buyLen = math.max(1, int(buyTotal / maxLvlVol * maxBarLen))
                float sellTotal = sellL + sellS
                int sellLen = math.max(1, int(sellTotal / maxLvlVol * maxBarLen))

                int bxL = bar_index + offset
                int bxR = bar_index + offset
                if profileSide == "right"
                    bxR := bar_index + offset + buyLen
                else
                    bxL := bar_index + offset - buyLen

                color buyClr = buyL > buyS ? largeBuyColor : smallBuyColor
                array.push(profBoxes, box.new(bxL, price + halfH, bxR, price - halfH,
                     bgcolor=color.new(buyClr, 30), border_color=color.new(buyClr, 50)))

                int sxL = bar_index + offset
                int sxR = bar_index + offset
                if profileSide == "right"
                    sxL := bar_index + offset - sellLen
                else
                    sxR := bar_index + offset + sellLen

                color sellClr = sellL > sellS ? largeSellColor : smallSellColor
                array.push(profBoxes, box.new(sxL, price + halfH, sxR, price - halfH,
                     bgcolor=color.new(sellClr, 30), border_color=color.new(sellClr, 50)))

                if showLabels
                    string buyTxt = str.tostring(int(buyTotal), format.volume)
                    string sellTxt = str.tostring(int(sellTotal), format.volume)
                    int lblX = profileSide == "right" ? bxR + 1 : sxL - 1
                    string lblSt = profileSide == "right" ? label.style_label_left : label.style_label_right
                    array.push(profLabels, label.new(lblX, price, buyTxt + " | " + sellTxt,
                         yloc=yloc.price, style=lblSt, size=size.small, textcolor=color.white, color=color.new(color.gray, 90)))
            else
                int barLen = math.max(1, int(scale * maxBarLen))
                int bxL2 = bar_index + offset
                int bxR2 = bar_index + offset
                if profileSide == "right"
                    bxR2 := bar_index + offset + barLen
                else
                    bxL2 := bar_index + offset - barLen

                array.push(profBoxes, box.new(bxL2, price + halfH, bxR2, price - halfH,
                     bgcolor=color.new(color.blue, 40), border_color=na))

                if showLabels
                    int lblX2 = profileSide == "right" ? bxR2 + 1 : bxL2 - 1
                    string lblSt2 = profileSide == "right" ? label.style_label_left : label.style_label_right
                    array.push(profLabels, label.new(lblX2, price, str.tostring(int(totalLvl), format.volume),
                         yloc=yloc.price, style=lblSt2, size=size.small, textcolor=color.white, color=color.new(color.gray, 90)))

        // POC
        if showPOC
            array.push(profLines, line.new(bar_index - 5, pocPrice, bar_index + 35, pocPrice,
                 color=pocColor, style=line.style_solid, width=2))
            array.push(profLabels, label.new(bar_index + 36, pocPrice, "POC",
                 yloc=yloc.price, style=label.style_label_left, size=size.small,
                 textcolor=pocColor, color=color.new(color.black, 80)))

        // VA
        if showVA
            array.push(profBoxes, box.new(bar_index - 1, vaHigh, bar_index + 32, vaLow,
                 bgcolor=vaColor, border_color=color.new(color.gray, 50), border_width=1))
            array.push(profLabels, label.new(bar_index + 33, (vaHigh + vaLow) / 2, "VA",
                 yloc=yloc.price, style=label.style_label_left, size=size.tiny,
                 textcolor=color.gray, color=color.new(color.black, 90)))

// ====================== LARGE ORDER MARKERS ======================
if barstate.islast and showThreshold and priceRange > 0
    for i = 0 to profileBars - 1
        float buyL  = array.get(lvlBuyLarge, i)
        float sellL = array.get(lvlSellLarge, i)
        float totalLvl = buyL + sellL + array.get(lvlBuySmall, i) + array.get(lvlSellSmall, i)
        if totalLvl > 0
            float largeRatio = (buyL + sellL) / totalLvl
            if largeRatio > largeThresh / 100
                float price = array.get(lvlPrices, i)
                color markerClr = buyL > sellL ? largeBuyColor : largeSellColor
                array.push(profLabels, label.new(bar_index + 38, price, "●",
                     yloc=yloc.price, style=label.style_label_left, size=size.large,
                     textcolor=markerClr, color=color.new(color.black, 100)))

// ====================== ALERTS ======================
alertcondition(alertLarge and barstate.islast, title="Large Order Level", message="Large order cluster on {{ticker}}")

// ====================== DASHBOARD ======================
var table dash = table.new("top_right", 2, 8, border_width=1, border_color=color.gray)

if barstate.islast
    table.cell(dash, 0, 0, "VOLUME PROFILE", text_color=color.white, bgcolor=color.rgb(30, 30, 30), text_size=size.small)
    table.cell(dash, 1, 0, syminfo.ticker, text_color=color.yellow, bgcolor=color.rgb(30, 30, 30), text_size=size.small)

    table.cell(dash, 0, 1, "POC", text_color=color.gray, bgcolor=color.rgb(25, 25, 25), text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(pocPrice, format.mintick), text_color=pocColor, bgcolor=color.rgb(25, 25, 25), text_size=size.small)

    table.cell(dash, 0, 2, "VA High", text_color=color.gray, bgcolor=color.rgb(25, 25, 25), text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(vaHigh, format.mintick), text_color=color.white, bgcolor=color.rgb(25, 25, 25), text_size=size.small)

    table.cell(dash, 0, 3, "VA Low", text_color=color.gray, bgcolor=color.rgb(25, 25, 25), text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(vaLow, format.mintick), text_color=color.white, bgcolor=color.rgb(25, 25, 25), text_size=size.small)

    float closeDist = (close - pocPrice) / atr14
    table.cell(dash, 0, 4, "vs POC", text_color=color.gray, bgcolor=color.rgb(25, 25, 25), text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(closeDist, "0.00") + "σ", text_color=closeDist > 0 ? color.green : color.red, bgcolor=color.rgb(25, 25, 25), text_size=size.small)

    bool aboveVA = close > vaHigh
    bool belowVA = close < vaLow
    string posText = aboveVA ? "ABOVE VA" : belowVA ? "BELOW VA" : "INSIDE VA"
    color posClr = aboveVA ? color.green : belowVA ? color.red : color.gray
    table.cell(dash, 0, 5, "Position", text_color=color.gray, bgcolor=color.rgb(25, 25, 25), text_size=size.small)
    table.cell(dash, 1, 5, posText, text_color=posClr, bgcolor=color.rgb(25, 25, 25), text_size=size.small)

    table.cell(dash, 0, 6, "Delta", text_color=color.gray, bgcolor=color.rgb(25, 25, 25), text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(delta, format.volume), text_color=delta >= 0 ? color.green : color.red, bgcolor=color.rgb(25, 25, 25), text_size=size.small)

    table.cell(dash, 0, 7, "Range", text_color=color.gray, bgcolor=color.rgb(25, 25, 25), text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(int(priceRange), format.mintick), text_color=color.white, bgcolor=color.rgb(25, 25, 25), text_size=size.small)
````
