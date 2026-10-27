# Hidden Liquidity Profile [Alpha Extract]

- url: https://www.tradingview.com/script/h9J9Wqh7-Hidden-Liquidity-Profile-Alpha-Extract/
- type: indicator
- pine_id: PUB;a1dd71a10ad4486f921ea9a5b7f780fc
- version: 2.0

## Description

A sophisticated liquidity-mapping and support/resistance profiling framework that analyzes historical candle structure, volume, wick behaviour, and price distribution to identify hidden supply and demand zones across the chart. Hidden Liquidity Profile is designed to reveal where meaningful liquidity may be concentrated by separating sell-side and buy-side pressure into price bins, then projecting those zones forward as heat boxes, horizon lines, key price tags, and a real-time support/resistance dashboard.

Rather than relying on simple pivot highs and lows, the system evaluates how volume interacted with candle ranges, upper wicks, lower wicks, candle bodies, and recency weighting. This creates a dynamic liquidity profile that highlights where price may encounter resistance, support, absorption, or reaction zones.

🔶 Hidden Liquidity Profiling Engine

Builds separate supply and demand profiles across the selected lookback range. The system divides price into configurable bins, then distributes liquidity strength into those bins based on volume, candle range, wick size, body size, and age decay.

[pine]energy = vol * rng * decay

sellStrength = energy * (upWick * wickWeight + body * bodyWeight * sellBias)
buyStrength  = energy * (dnWick * wickWeight + body * bodyWeight * buyBias)
[/pine]
This allows the indicator to estimate where sell liquidity and buy liquidity are most likely concentrated rather than only marking obvious visible highs and lows.

🔶 Supply & Demand Separation

The profile separates upper-wick and lower-wick pressure into two distinct liquidity maps.
Upper wick activity contributes to the supply profile, helping identify areas where sellers may have previously absorbed price movement. Lower wick activity contributes to the demand profile, helping identify zones where buyers may have previously defended price.

This separation gives traders a clearer view of whether nearby levels are more likely to behave as resistance, support, or balanced liquidity.

🔶 Age-Weighted Liquidity Decay

Applies a recency decay model so newer candles have stronger influence than older candles. This keeps the profile focused on liquidity that is more relevant to the current market environment while still preserving broader historical context.

The Age Decay Power setting controls how aggressively older liquidity fades. Higher values emphasize recent price action more strongly, while lower values retain more historical structure.

🔶 Price Bin Distribution System

Divides the analyzed price range into configurable price bins and assigns liquidity strength into each level. The Price Bins setting controls the resolution of the profile.

More bins create a finer, more detailed liquidity map. Fewer bins create a smoother, broader view of major supply and demand areas.

🔶 Distribution Radius Smoothing

Uses a configurable distribution radius to spread liquidity strength around nearby bins. This prevents the profile from becoming too fragmented and helps form smoother liquidity clusters.
This is especially useful on volatile assets where important liquidity zones often form across small ranges rather than at one exact tick.

🔶 Liquidity Heat Box Visualization

Displays supply and demand as horizontal heat boxes projected to the right side of the chart.
Supply liquidity is shown on the sell side using the selected sell color, while demand liquidity is shown on the buy side using the selected buy color. Wider and brighter boxes represent stronger normalized liquidity at that price level.

This creates a visual depth-style map that helps traders quickly identify where meaningful liquidity may be stacked above and below current price.

🔶 Forward Horizon Lines

Projects stronger liquidity levels forward using horizontal lines. These lines act as future reference zones where price may react, pause, reject, or accelerate through.
The Line Trigger setting controls how strong a liquidity level must be before it is projected. The Line Width Scale setting adjusts how visually dominant stronger levels appear.

🔶 Key Level Detection Framework

Identifies the strongest supply and demand levels from the profile and labels them directly on the chart.

The system can prioritize local peaks, helping avoid overcrowding and ensuring that selected levels represent distinct liquidity clusters rather than multiple nearby bins from the same zone.

This scoring model favors levels with strong dominant liquidity while still accounting for total combined activity.

🔶 Supply HVN & Demand HVN Labels

Marks high-volume liquidity nodes as Supply HVN or Demand HVN depending on which side of the profile dominates at that price.

Each label includes the level type, normalized strength percentage, and exact price. This allows traders to quickly identify the most important liquidity levels without manually reading the full heat map.

🔶 Nearest Support & Resistance Logic

Calculates the most relevant resistance above price and support below price using both liquidity strength and distance from current price.
Levels closer to current price receive more practical importance, while still needing enough liquidity strength to qualify. This helps the dashboard focus on actionable nearby zones instead of simply displaying the strongest level anywhere in the lookback range.

🔶 Aura Point Of Control

Identifies the strongest combined liquidity level across the profile. This Aura POC represents the price zone with the highest combined supply and demand activity.
The POC can act as a major reference point for balance, rotation, acceptance, rejection, or future retests.

🔶 Liquidity Pressure Balance

Compares total normalized demand against total normalized supply to estimate the broader pressure bias across the analyzed range.
When demand is meaningfully stronger, the dashboard shows a demand bias. When supply dominates, it shows a supply bias. When the two sides are close, the market is classified as balanced.

🔶 Real-Time S/R Dashboard

Includes a compact dashboard showing the most important liquidity information directly on the chart:

• Nearest resistance level
• Nearest support level
• Aura POC
• Supply, demand, or balanced pressure
• Active liquidity level count
• Current ticker reference  

This gives traders a quick summary of where the strongest nearby reaction zones are and whether the broader liquidity profile is tilted toward supply or demand.

🔶 Customizable Visual Controls

Provides flexible display controls for heat boxes, horizon lines, key level tags, dotted key level lines, and the dashboard.

Traders can adjust the number of analyzed bars, price bin resolution, liquidity smoothing, projection distance, box width, line width, and trigger thresholds to match different assets and timeframes.

🔶 Clean Overlay Design

The full liquidity map is displayed directly on price without requiring a separate oscillator pane. Heat boxes appear to the right of the chart, while key levels and labels extend across the active lookback area.

This keeps the chart readable while still providing a detailed view of hidden supply and demand structure.

🔶 Why Choose Hidden Liquidity Profile [Alpha Extract]?

Hidden Liquidity Profile provides a more advanced way to identify potential support, resistance, and liquidity reaction zones by analyzing volume-weighted candle structure across the full price range. Instead of marking only visible swing highs and lows, it evaluates where supply and demand pressure may be concentrated based on wick behaviour, candle body participation, volume energy, and recency-weighted price distribution.
The heat boxes reveal liquidity density, the horizon lines project important levels forward, the HVN labels highlight the strongest zones, and the dashboard summarizes nearest support, resistance, POC, and pressure bias in real time.
Perfect for liquidity traders, support/resistance traders, intraday traders, swing traders, and market structure analysts who want a cleaner way to visualize hidden supply and demand zones directly on the chart.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Hidden Liquidity Profile [Alpha Extract]", overlay = true, max_lines_count = 500, max_boxes_count = 400, max_labels_count = 200, max_bars_back = 5000)

// --- Inputs ---------------------------------------------------------------------
lookbackBars   = input.int(400,  "Bars Analyzed", minval = 50, maxval = 1200)
priceBins      = input.int(200,   "Price Bins", minval = 12, maxval = 500)
smearRadius    = input.int(2,    "Distribution Radius", minval = 0, maxval = 8)
decayPower     = input.float(4.,"Age Decay Power", minval = 0.3, maxval = 4.)
wickWeight     = input.float(1.0,"Wick Weight", minval = 0.1, maxval = 3.)
bodyWeight     = input.float(0.1,"Body Weight", minval = 0.1, maxval = 2.)
projectionBars = input.int(51,   "Forward Projection Bars", minval = 5, maxval = 80)
boxGap         = input.int(60,    "Right Offset (bars)", minval = 2, maxval = 90)
boxScale       = input.int(51,   "Box Width Scale", minval = 5, maxval = 100)
lineScale      = input.int(1,    "Line Width Scale", minval = 1, maxval = 20)
lineTrigger    = input.float(0.05,"Line Trigger (0-1)", minval = 0.05, maxval = 0.95)
keyLevelCount  = input.int(12,    "Key Price Levels", minval = 1, maxval = 12, group = "Key Levels")
keyLevelTrigger = input.float(0.15,"Key Level Trigger (0-1)", minval = 0.05, maxval = 0.95, group = "Key Levels")
preferLocalPeaks = input.bool(true, "Prefer Local Peaks", group = "Key Levels")
showKeyLabels  = input.bool(true,"Display Price Tags", group = "Key Levels")
showKeyLines   = input.bool(true,"Display Key Level Lines", group = "Key Levels")
showDashboard  = input.bool(true,"Display S/R Dashboard", group = "Key Levels")
showBoxes      = input.bool(true,"Display Heat Boxes", group = "Style")
showLines      = input.bool(true,"Display Horizon Lines", group = "Style")
sellColor      = input.color(color.rgb(190, 45, 65), "Sell Liquidity Color", group = "Style")
buyColor       = input.color(color.rgb(8, 153, 129),   "Buy Liquidity Color", group = "Style")
neutralBg      = color.new(color.silver, 90)
panelBg        = color.new(color.black, 82)
panelHeaderBg  = color.new(color.silver, 80)
panelText      = color.new(color.white, 0)

// --- Persistent Containers -------------------------------------------------------
var float[] supplyProfile = array.new_float()
var float[] demandProfile = array.new_float()
var line[]  projectedLines = array.new_line()
var line[]  keyLevelLines = array.new_line()
var box[]   depthBoxes = array.new_box()
var label[] keyLabels = array.new_label()
var table   srDashboard = table.new(position.bottom_right, 2, 6, bgcolor = panelBg, border_color = color.new(color.silver, 70), border_width = 1)

// --- Utility Functions -----------------------------------------------------------
f_reset_profile(float[] profile, int size) =>
    array.clear(profile)
    for _ = 0 to size - 1
        array.push(profile, 0.)

f_clamp_price(float value, float floor, float ceiling) =>
    math.max(floor, math.min(ceiling, value))

f_smear_profile(float[] profile, float price, float strength, float anchor, float step, int bins, int radius) =>
    if step > 0
        clipped = f_clamp_price(price, anchor, anchor + step * bins)
        center  = math.floor((clipped - anchor) / step)
        center := math.min(math.max(center, 0), bins - 1)
        validRadius = math.max(radius, 0)
        for offset = -validRadius to validRadius
            idx = center + offset
            if idx >= 0 and idx < bins
                distance = math.abs(offset)
                spread   = validRadius == 0 ? 0. : distance / validRadius
                weight   = validRadius == 0 ? 1. : math.exp(-spread * spread)
                array.set(profile, idx, array.get(profile, idx) + strength * weight)

f_clear_lines(line[] storage) =>
    count = array.size(storage)
    if count > 0
        for i = 0 to count - 1
            ln = array.get(storage, i)
            line.delete(ln)
    array.clear(storage)

f_clear_boxes(box[] storage) =>
    count = array.size(storage)
    if count > 0
        for i = 0 to count - 1
            bx = array.get(storage, i)
            box.delete(bx)
    array.clear(storage)

f_clear_labels(label[] storage) =>
    count = array.size(storage)
    if count > 0
        for i = 0 to count - 1
            lb = array.get(storage, i)
            label.delete(lb)
    array.clear(storage)

f_bin_is_near(int[] selectedBins, int bin, int minDistance) =>
    near = false
    count = array.size(selectedBins)
    if count > 0
        for i = 0 to count - 1
            near := near or math.abs(bin - array.get(selectedBins, i)) <= minDistance
    near

f_pct_text(float value) =>
    str.tostring(int(math.round(value * 100.))) + "%"

f_price_text(float value) =>
    str.tostring(value, format.mintick)

f_dashboard_cell(table panel, int column, int row, string value, color bg, color txt) =>
    table.cell(panel, column, row, value, bgcolor = bg, text_color = txt, text_size = size.normal)

// --- Core Calculations -----------------------------------------------------------
hiRange = ta.highest(high, lookbackBars)
loRange = ta.lowest(low, lookbackBars)
priceSpan = math.max(hiRange - loRange, syminfo.mintick * priceBins)
binStep   = priceSpan / priceBins

if barstate.islast
    f_reset_profile(supplyProfile, priceBins)
    f_reset_profile(demandProfile, priceBins)

    for i = 0 to lookbackBars - 1
        rng = high[i] - low[i]
        vol = volume[i]
        if na(rng) or na(vol) or rng == 0
            continue

        decayBase = math.max(lookbackBars - i, 1) / lookbackBars
        decay     = math.pow(decayBase, decayPower)

        upWick   = math.max(high[i] - math.max(open[i], close[i]), 0.)
        dnWick   = math.max(math.min(open[i], close[i]) - low[i], 0.)
        body     = math.abs(close[i] - open[i])
        energy   = vol * rng * decay

        sellBias = close[i] <= open[i] ? 1.0 : 0.55
        buyBias  = close[i] >= open[i] ? 1.0 : 0.55

        sellStrength = energy * (upWick * wickWeight + body * bodyWeight * sellBias)
        buyStrength  = energy * (dnWick * wickWeight + body * bodyWeight * buyBias)

        supplyPrice = upWick > 0 ? high[i] - upWick * 0.45 : high[i] - rng * 0.2
        demandPrice = dnWick > 0 ? low[i] + dnWick * 0.45 : low[i] + rng * 0.2

        if sellStrength > 0
            f_smear_profile(supplyProfile, supplyPrice, sellStrength, loRange, binStep, priceBins, smearRadius)
        if buyStrength > 0
            f_smear_profile(demandProfile, demandPrice, buyStrength, loRange, binStep, priceBins, smearRadius)

    maxSupply = array.max(supplyProfile)
    maxDemand = array.max(demandProfile)
    maxCombined = 0.

    for bin = 0 to priceBins - 1
        maxCombined := math.max(maxCombined, array.get(supplyProfile, bin) + array.get(demandProfile, bin))

    f_clear_lines(projectedLines)
    f_clear_lines(keyLevelLines)
    f_clear_boxes(depthBoxes)
    f_clear_labels(keyLabels)

    float pocPrice = na
    float pocNorm = 0.
    float bestResistance = na
    float bestResistanceNorm = 0.
    float bestResistanceScore = 0.
    float bestSupport = na
    float bestSupportNorm = 0.
    float bestSupportScore = 0.
    float totalSupplyNorm = 0.
    float totalDemandNorm = 0.
    int activeLevels = 0

    for bin = 0 to priceBins - 1
        lower = loRange + binStep * bin
        upper = lower + binStep
        mid   = (lower + upper) * 0.5

        supplyValue = array.get(supplyProfile, bin)
        demandValue = array.get(demandProfile, bin)

        supplyNorm = maxSupply > 0 ? supplyValue / maxSupply : 0.
        demandNorm = maxDemand > 0 ? demandValue / maxDemand : 0.
        combinedNorm = maxCombined > 0 ? (supplyValue + demandValue) / maxCombined : 0.
        dominantNorm = math.max(supplyNorm, demandNorm)

        totalSupplyNorm += supplyNorm
        totalDemandNorm += demandNorm

        if dominantNorm >= keyLevelTrigger
            activeLevels += 1

        if combinedNorm > pocNorm
            pocNorm := combinedNorm
            pocPrice := mid

        if mid > close and supplyNorm >= keyLevelTrigger
            distanceScore = 1. + math.abs(mid - close) / priceSpan * 3.
            resistanceScore = supplyNorm / distanceScore
            if resistanceScore > bestResistanceScore
                bestResistanceScore := resistanceScore
                bestResistanceNorm := supplyNorm
                bestResistance := mid

        if mid < close and demandNorm >= keyLevelTrigger
            distanceScore = 1. + math.abs(mid - close) / priceSpan * 3.
            supportScore = demandNorm / distanceScore
            if supportScore > bestSupportScore
                bestSupportScore := supportScore
                bestSupportNorm := demandNorm
                bestSupport := mid

        rightEdge = bar_index + boxGap

        supplyWidth = int(math.round(supplyNorm * boxScale))
        demandWidth = int(math.round(demandNorm * boxScale))

        if showBoxes and supplyNorm > 0
            bx = box.new(rightEdge, upper, rightEdge + supplyWidth, lower,
                 bgcolor      = color.from_gradient(supplyNorm, 0, 1, neutralBg, color.new(sellColor, 10)),
                 border_color = color.new(sellColor, 70))
            array.push(depthBoxes, bx)

        if showBoxes and demandNorm > 0
            bx = box.new(rightEdge - demandWidth, upper, rightEdge, lower,
                 bgcolor      = color.from_gradient(demandNorm, 0, 1, neutralBg, color.new(buyColor, 10)),
                 border_color = color.new(buyColor, 70))
            array.push(depthBoxes, bx)

        lineStart = rightEdge + math.max(1, supplyWidth)
        lineEnd   = lineStart + projectionBars

        if showLines and supplyNorm >= lineTrigger
            width = math.max(1, int(math.round(supplyNorm * lineScale)))
            alpha = math.max(0, 85 - int(supplyNorm * 70))
            ln = line.new(lineStart, mid, lineEnd, mid,
                 color = color.new(sellColor, alpha),
                 width = width,
                 extend = extend.none)
            array.push(projectedLines, ln)

        if showLines and demandNorm >= lineTrigger
            width = math.max(1, int(math.round(demandNorm * lineScale)))
            alpha = math.max(0, 85 - int(demandNorm * 70))
            ln = line.new(lineStart, mid, lineEnd, mid,
                 color = color.new(buyColor, alpha),
                 width = width,
                 extend = extend.none)
            array.push(projectedLines, ln)

    selectedBins = array.new_int()
    labelX = bar_index + boxGap + boxScale + projectionBars + 4
    lineX1 = bar_index - lookbackBars + 1
    minLevelSpacing = math.max(1, int(math.round(smearRadius + priceBins / 45.)))

    if showKeyLabels or showKeyLines
        for rank = 0 to keyLevelCount - 1
            int bestBin = na
            float bestScore = 0.
            float bestSupplyNorm = 0.
            float bestDemandNorm = 0.

            for bin = 0 to priceBins - 1
                supplyValue = array.get(supplyProfile, bin)
                demandValue = array.get(demandProfile, bin)
                supplyNorm = maxSupply > 0 ? supplyValue / maxSupply : 0.
                demandNorm = maxDemand > 0 ? demandValue / maxDemand : 0.
                combinedNorm = maxCombined > 0 ? (supplyValue + demandValue) / maxCombined : 0.
                dominantNorm = math.max(supplyNorm, demandNorm)

                leftSupply = bin > 0 and maxSupply > 0 ? array.get(supplyProfile, bin - 1) / maxSupply : 0.
                leftDemand = bin > 0 and maxDemand > 0 ? array.get(demandProfile, bin - 1) / maxDemand : 0.
                rightSupply = bin < priceBins - 1 and maxSupply > 0 ? array.get(supplyProfile, bin + 1) / maxSupply : 0.
                rightDemand = bin < priceBins - 1 and maxDemand > 0 ? array.get(demandProfile, bin + 1) / maxDemand : 0.
                localPeak = dominantNorm >= math.max(leftSupply, leftDemand) and dominantNorm >= math.max(rightSupply, rightDemand)
                peakAllowed = not preferLocalPeaks or localPeak
                alreadySelected = f_bin_is_near(selectedBins, bin, minLevelSpacing)
                candidateScore = dominantNorm * 0.7 + combinedNorm * 0.3

                if peakAllowed and not alreadySelected and dominantNorm >= keyLevelTrigger and candidateScore > bestScore
                    bestScore := candidateScore
                    bestBin := bin
                    bestSupplyNorm := supplyNorm
                    bestDemandNorm := demandNorm

            if not na(bestBin)
                array.push(selectedBins, bestBin)
                lower = loRange + binStep * bestBin
                upper = lower + binStep
                mid = (lower + upper) * 0.5
                tagColor = bestSupplyNorm >= bestDemandNorm ? sellColor : buyColor
                tagSide = bestSupplyNorm >= bestDemandNorm ? "Supply HVN" : "Demand HVN"
                tagNorm = math.max(bestSupplyNorm, bestDemandNorm)
                tagText = tagSide + " " + f_pct_text(tagNorm) + " | " + f_price_text(mid)

                if showKeyLines
                    ln = line.new(lineX1, mid, labelX - 1, mid,
                         color = color.new(tagColor, 48),
                         width = math.max(1, int(math.round(tagNorm * 3.))),
                         style = line.style_dotted,
                         extend = extend.none)
                    array.push(keyLevelLines, ln)

                if showKeyLabels
                    lb = label.new(labelX, mid, tagText,
                         xloc = xloc.bar_index,
                         style = label.style_label_left,
                         color = color.new(tagColor, 8),
                         textcolor = color.white,
                         size = size.small)
                    array.push(keyLabels, lb)

    if showDashboard
        imbalance = totalSupplyNorm + totalDemandNorm > 0 ? (totalDemandNorm - totalSupplyNorm) / (totalSupplyNorm + totalDemandNorm) : 0.
        biasText = imbalance > 0.08 ? "Demand" : imbalance < -0.08 ? "Supply" : "Balanced"
        biasColor = imbalance > 0.08 ? buyColor : imbalance < -0.08 ? sellColor : color.silver

        f_dashboard_cell(srDashboard, 0, 0, "Aura Dashboard", panelHeaderBg, panelText)
        f_dashboard_cell(srDashboard, 1, 0, syminfo.ticker, panelHeaderBg, panelText)
        f_dashboard_cell(srDashboard, 0, 1, "Resistance", panelBg, color.new(sellColor, 0))
        f_dashboard_cell(srDashboard, 1, 1, na(bestResistance) ? "n/a" : f_price_text(bestResistance) + "  " + f_pct_text(bestResistanceNorm), panelBg, color.new(sellColor, 0))
        f_dashboard_cell(srDashboard, 0, 2, "Support", panelBg, color.new(buyColor, 0))
        f_dashboard_cell(srDashboard, 1, 2, na(bestSupport) ? "n/a" : f_price_text(bestSupport) + "  " + f_pct_text(bestSupportNorm), panelBg, color.new(buyColor, 0))
        f_dashboard_cell(srDashboard, 0, 3, "Aura POC", panelBg, panelText)
        f_dashboard_cell(srDashboard, 1, 3, na(pocPrice) ? "n/a" : f_price_text(pocPrice) + "  " + f_pct_text(pocNorm), panelBg, panelText)
        f_dashboard_cell(srDashboard, 0, 4, "Pressure", panelBg, biasColor)
        f_dashboard_cell(srDashboard, 1, 4, biasText + "  " + f_pct_text(math.abs(imbalance)), panelBg, biasColor)
        f_dashboard_cell(srDashboard, 0, 5, "Active Levels", panelBg, panelText)
        f_dashboard_cell(srDashboard, 1, 5, str.tostring(activeLevels), panelBg, panelText)
    else
        for column = 0 to 1
            for row = 0 to 5
                f_dashboard_cell(srDashboard, column, row, "", color.new(color.black, 100), color.new(color.white, 100))
````
