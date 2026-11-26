# Liquidity Zones + VWAP & EMA System

- url: https://www.tradingview.com/script/uyCEA7Gx-Liquidity-Zones-VWAP-EMA-System/
- type: indicator
- pine_id: PUB;81748b356f434dd6994174748ca48f95
- version: 1.0

## Description

Liquidity Zones + VWAP & EMA System

Educational Guide for New Traders


⚠️ IMPORTANT DISCLAIMER

This indicator is provided for educational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss and is not suitable for every investor. Past performance of any trading system or methodology is not indicative of future results. You are solely responsible for all trading decisions you make. Always consult a licensed financial advisor before making any investment decisions. The creator of this indicator accepts no liability for any losses incurred from the use of this tool.


What Is This Indicator?

The Liquidity Zones + VWAP & EMA System is a multi-layered technical analysis tool designed to help traders identify:


Where significant market orders are concentrated (Liquidity Zones)
What the current trend and momentum direction is (VWAP + EMA System)
Whether the market is bullish, bearish, or neutral (Sentiment Background)
A real-time summary of all signals (Dashboard)


This indicator combines four powerful concepts into one clean, easy-to-read tool — making it especially useful for traders who want to understand market structure without switching between multiple charts.


Part 1 — Liquidity Zones

What Are Liquidity Zones?

Liquidity zones are price areas where a large number of buy or sell orders are likely to be sitting. These zones form around swing highs and swing lows — price levels where the market has previously reversed. Institutional traders (banks, hedge funds, market makers) tend to place large orders at these levels, which is why price often reacts strongly when it returns to them.

What Does the Indicator Show?

Each zone is drawn as a colored horizontal band:


🟢 Teal/Green zone — More bullish volume was traded at this level (buyers in control)
🔴 Red zone — More bearish volume was traded at this level (sellers in control)
⚫ Gray zone — Balanced between buyers and sellers (neutral)


The Label — Bull %, Bear % and Delta (Δ)

Each zone shows three pieces of information:

Label Part What It Means R or SR = Resistance (zone above current price) / S = Support (zone below) Price The exact price level of the zone Bull % / Bear %How much of the volume at that level was buying vs sellingΔ (Delta)The difference between bull and bear volume. Positive = more buyers. Negative = more sellers.

Example: A label reading S 1.2345 — 68% Bull / 32% Bear Δ +15,230 means:


This is a Support zone at price 1.2345
68% of the volume traded here was bullish (buyers)
The delta of +15,230 confirms buyers dominated
This is considered a high-probability support zone to watch for bounces


How to Use Liquidity Zones

✅ Look for price to return to a zone — when price pulls back to a bull-dominated support zone, it may bounce upward. When price rallies into a bear-dominated resistance zone, it may reject downward.

✅ Stronger zones have a higher bull/bear % skew — a 75% bull zone is stronger than a 55% bull zone.

✅ A large positive delta at a support zone means institutions were buying heavily there — price is likely to be defended when it returns.

⚠️ Zones can break — if price closes strongly through a zone with high volume, the zone may no longer hold. Always use a stop loss.


Part 2 — VWAP (Volume Weighted Average Price)

What Is VWAP?

VWAP stands for Volume Weighted Average Price. It is the average price of an asset, weighted by how much volume was traded at each price level. It resets at the start of each session (or week/month, depending on your settings).

VWAP is one of the most widely used tools by institutional traders and market makers because it represents the true "fair value" of an asset for the day.

The Golden Rule of VWAP


Price above VWAP = Bullish. Price below VWAP = Bearish.



When price is above VWAP, it means buyers are in control and the market is trading above its fair value — a bullish sign.
When price is below VWAP, sellers are in control — a bearish sign.

VWAP Bands (±1σ and ±2σ)

The indicator also shows standard deviation bands around VWAP:

BandMeaning+1σ (upper band 1)Price is moderately extended above fair value+2σ (upper band 2)Price is significantly overextended — potential reversal zone-1σ (lower band 1)Price is moderately extended below fair value-2σ (lower band 2)Price is significantly oversold — potential reversal zone

How to use the bands:


Price touching +2σ while overbought = consider tightening stops or watching for reversal
Price touching -2σ while oversold = potential buying opportunity (with confirmation)
Price bouncing off VWAP itself = strong continuation signal in the direction of the trend



Part 3 — EMA System (Exponential Moving Averages)

What Are EMAs?

An Exponential Moving Average (EMA) is a line that shows the average price over a set number of bars, with more weight given to recent prices. EMAs help identify the direction of the trend.

This indicator uses three EMAs by default:

EMA Default Length Purpose EMA 1 (Blue)9 bars Fast — shows short-term momentum EMA 2 (Orange)21 bars Medium — shows intermediate trend EMA 3 (Purple)200 bars Slow — shows the major long-term trend

How to Read the EMAs


All three EMAs pointing up + price above all three = strong uptrend
All three EMAs pointing down + price below all three = strong downtrend
EMA 1 crossing above EMA 2 = short-term bullish signal (golden cross)
EMA 1 crossing below EMA 2 = short-term bearish signal (death cross)



Part 4 — The Trend Sentiment Background

The chart background color gives you an instant visual summary of market sentiment:

Background Color Meaning🟢 Light Green Highly Bullish — price is above EMA 1, EMA 2, AND VWAP🔴 Light Red Highly Bearish — price is below EMA 1, EMA 2, AND VWAP⬜ No Color Neutral — mixed signals, no clear directional bias

The Most Powerful Setup


When the background is green AND price is approaching a teal (bull) liquidity zone from above — this is a high-probability long setup.




When the background is red AND price is approaching a red (bear) liquidity zone from below — this is a high-probability short setup.




Part 5 — The Dashboard (Top Right Table)

The dashboard gives you a real-time summary of everything at a glance:

Row What It Shows SENTIMENT Highly Bullish / Highly Bearish / Neutral vs VWAP How far price is from VWAP as a percentage vs EMA 1/2/3Whether price is above or below each EMABAR DELTA Current bar's bull volume minus bear volume VWAP BAND Which VWAP band price is currently in SIGNAL STRONG BUY / BUY / SELL / STRONG SELL / WAIT


Complete Trading Checklist (How to Use All Parts Together)

Before entering any trade, go through this checklist:

✅ For a Long (Buy) Trade:


Sentiment background is green (price above EMA 1, EMA 2, and VWAP)
Price is at or approaching a teal (bull-dominated) liquidity zone
Zone shows high bull % and positive delta
VWAP band shows price is above VWAP but not overextended past +2σ
Dashboard shows BUY or STRONG BUY


✅ For a Short (Sell) Trade:


Sentiment background is red (price below EMA 1, EMA 2, and VWAP)
Price is at or approaching a red (bear-dominated) liquidity zone
Zone shows high bear % and negative delta
VWAP band shows price is below VWAP but not overextended past -2σ
Dashboard shows SELL or STRONG SELL


❌ Avoid Trading When:


Background has no color (neutral/mixed signals)
Price is between liquidity zones with no clear level nearby
Dashboard shows WAIT
Volume is very low (no spike, ratio below 1x average)



Recommended Settings for Different Markets

Market VWAP Anchor EMA 1EMA 2EMA 3Stocks (Day Trading)Session921200ForexSession or Week921200CryptoSession921200Swing TradingWeek2150200


Important Risk Management Rules


⚠️ Never risk more than 1-2% of your account on any single trade.




Always use a stop loss — place it just below the liquidity zone for longs, just above for shorts
Never trade against the major trend (EMA 200 direction)
Wait for confirmation — do not enter the moment price touches a zone; wait for a candle to close at or above/below the zone
The indicator does not guarantee profits — it is a tool to help identify probability, not certainty
Practice on a demo account first before using real money



Final Notes

This indicator works best when used alongside other analysis tools such as:


Support and Resistance levels
Candlestick patterns
Market Structure (Higher Highs, Higher Lows)
News and economic calendar awareness


No single indicator is 100% accurate. The goal is to stack multiple confirmations before entering a trade to improve your probability of success.

Trade safe. Manage your risk. Always keep learning.


This document is for educational purposes only and does not constitute financial advice. Trading carries significant risk of loss.

## Source Code

````pine
//@version=6
indicator('Liquidity Zones + VWAP & EMA System', overlay = true, max_boxes_count = 200, max_labels_count = 200, max_lines_count = 200)

// ===================== INPUTS =====================
// Liquidity Zones
grp_liq = 'Liquidity Zones'
showLiq = input.bool(true, 'Show Liquidity Zones', group = grp_liq)
liqPivLen = input.int(10, 'Pivot Length', minval = 2, maxval = 50, group = grp_liq)
liqLookback = input.int(200, 'Lookback (bars)', minval = 20, maxval = 500, group = grp_liq)
liqATRMult = input.float(0.3, 'Zone Thickness (x ATR)', minval = 0.05, step = 0.05, group = grp_liq)
maxLiqZones = input.int(5, 'Max Zones per Side', minval = 1, maxval = 10, group = grp_liq)
minLiqSep = input.float(1.5, 'Min Zone Separation (x ATR)', minval = 0.5, step = 0.1, group = grp_liq)
volLookback = input.int(20, 'Volume Lookback per Zone (bars)', minval = 5, maxval = 100, group = grp_liq)
showRatio = input.bool(true, 'Show Bull/Bear Volume Ratio', group = grp_liq)
showDelta = input.bool(true, 'Show Volume Delta', group = grp_liq)
extendZones = input.bool(true, 'Extend Zones Right', group = grp_liq)
zoneProjection = input.int(40, 'Zone Projection (bars)', minval = 5, maxval = 200, group = grp_liq)

colBullLiq = input.color(color.new(#26A69A, 75), 'Bullish Zone Color', group = grp_liq)
colBearLiq = input.color(color.new(#EF5350, 75), 'Bearish Zone Color', group = grp_liq)
colNeutralLiq = input.color(color.new(#787B86, 75), 'Neutral Zone Color', group = grp_liq)

// VWAP
grp_vwap = 'VWAP System'
showVWAP = input.bool(true, 'Show VWAP', group = grp_vwap)
showVWAPBands = input.bool(true, 'Show VWAP Bands (±1σ, ±2σ)', group = grp_vwap)
vwapSource = input.string('Session', 'VWAP Anchor', options = ['Session', 'Week', 'Month'], group = grp_vwap)
colVWAP = input.color(color.new(#FFD700, 0), 'VWAP Color', group = grp_vwap)
colVWAPBand1 = input.color(color.new(#FFD700, 70), 'VWAP Band 1 Color', group = grp_vwap)
colVWAPBand2 = input.color(color.new(#FFD700, 85), 'VWAP Band 2 Color', group = grp_vwap)

// EMA
grp_ema = 'EMA System'
showEMA1 = input.bool(true, 'Show EMA 1', group = grp_ema)
emaLen1 = input.int(9, 'EMA 1 Length', minval = 1, group = grp_ema)
colEMA1 = input.color(color.new(#2962FF, 0), 'EMA 1 Color', group = grp_ema)
showEMA2 = input.bool(true, 'Show EMA 2', group = grp_ema)
emaLen2 = input.int(21, 'EMA 2 Length', minval = 1, group = grp_ema)
colEMA2 = input.color(color.new(#FF6D00, 0), 'EMA 2 Color', group = grp_ema)
showEMA3 = input.bool(true, 'Show EMA 3', group = grp_ema)
emaLen3 = input.int(200, 'EMA 3 Length', minval = 1, group = grp_ema)
colEMA3 = input.color(color.new(#D500F9, 0), 'EMA 3 Color', group = grp_ema)

// Sentiment Display
grp_sent = 'Trend Sentiment'
showSentiment = input.bool(true, 'Show Sentiment Background', group = grp_sent)
showDash = input.bool(true, 'Show Dashboard', group = grp_sent)

// ===================== CORE =====================
atrVal = ta.atr(14)
volData = volume > 0 ? volume : 1.0
volAvail = ta.sma(volume, 20) > 0

// ===================== EMA =====================
ema1 = ta.ema(close, emaLen1)
ema2 = ta.ema(close, emaLen2)
ema3 = ta.ema(close, emaLen3)

plot(showEMA1 ? ema1 : na, 'EMA 1', color = colEMA1, linewidth = 2)
plot(showEMA2 ? ema2 : na, 'EMA 2', color = colEMA2, linewidth = 2)
plot(showEMA3 ? ema3 : na, 'EMA 3', color = colEMA3, linewidth = 2)

// ===================== VWAP =====================
// Anchor logic
isNewAnchor = vwapSource == 'Session' ? timeframe.change('D') : vwapSource == 'Week' ? timeframe.change('W') : timeframe.change('M')

var float cumPV = 0.0
var float cumVol = 0.0
var float cumPV2 = 0.0

if isNewAnchor or barstate.isfirst
    cumPV := 0.0
    cumVol := 0.0
    cumPV2 := 0.0
    cumPV2

typicalPrice = (high + low + close) / 3
cumPV := cumPV + typicalPrice * volData
cumVol := cumVol + volData
cumPV2 := cumPV2 + typicalPrice * typicalPrice * volData

vwapVal = cumVol > 0 ? cumPV / cumVol : typicalPrice
vwapVar = cumVol > 0 ? math.max(cumPV2 / cumVol - vwapVal * vwapVal, 0) : 0
vwapStdev = math.sqrt(vwapVar)

vwapUpper1 = vwapVal + vwapStdev
vwapLower1 = vwapVal - vwapStdev
vwapUpper2 = vwapVal + 2 * vwapStdev
vwapLower2 = vwapVal - 2 * vwapStdev

pVWAP = plot(showVWAP ? vwapVal : na, 'VWAP', color = colVWAP, linewidth = 2)
pVWAPU1 = plot(showVWAPBands ? vwapUpper1 : na, 'VWAP +1σ', color = colVWAPBand1, linewidth = 1)
pVWAPL1 = plot(showVWAPBands ? vwapLower1 : na, 'VWAP -1σ', color = colVWAPBand1, linewidth = 1)
pVWAPU2 = plot(showVWAPBands ? vwapUpper2 : na, 'VWAP +2σ', color = colVWAPBand2, linewidth = 1)
pVWAPL2 = plot(showVWAPBands ? vwapLower2 : na, 'VWAP -2σ', color = colVWAPBand2, linewidth = 1)

fill(pVWAPU1, pVWAPL1, color = showVWAPBands ? color.new(colVWAP, 93) : na, title = 'VWAP Band 1 Fill')
fill(pVWAPU2, pVWAPL2, color = showVWAPBands ? color.new(colVWAP, 97) : na, title = 'VWAP Band 2 Fill')

// ===================== TREND SENTIMENT =====================
aboveVWAP = close > vwapVal
aboveEMA1 = close > ema1
aboveEMA2 = close > ema2
aboveEMA3 = close > ema3

// Highly bullish: price above EMA1, EMA2, and VWAP
highlyBull = aboveVWAP and aboveEMA1 and aboveEMA2
highlyBear = not aboveVWAP and not aboveEMA1 and not aboveEMA2
neutral = not highlyBull and not highlyBear

bgcolor(showSentiment and highlyBull ? color.new(#26A69A, 95) : na, title = 'Bullish Sentiment')
bgcolor(showSentiment and highlyBear ? color.new(#EF5350, 95) : na, title = 'Bearish Sentiment')

// ===================== VOLUME DELTA PER BAR =====================
bullVol = close >= open ? volData : 0.0
bearVol = close < open ? volData : 0.0

// ===================== LIQUIDITY ZONE DETECTION =====================
liqPH = ta.pivothigh(high, liqPivLen, liqPivLen)
liqPL = ta.pivotlow(low, liqPivLen, liqPivLen)

var array<float> phPrices = array.new_float()
var array<int> phBars = array.new_int()
var array<float> plPrices = array.new_float()
var array<int> plBars = array.new_int()

if not na(liqPH)
    array.push(phPrices, liqPH)
    array.push(phBars, bar_index - liqPivLen)
    if array.size(phPrices) > 50
        array.shift(phPrices)
        array.shift(phBars)

if not na(liqPL)
    array.push(plPrices, liqPL)
    array.push(plBars, bar_index - liqPivLen)
    if array.size(plPrices) > 50
        array.shift(plPrices)
        array.shift(plBars)

// Storage
var array<box> liqBoxes = array.new_box()
var array<label> liqLabels = array.new_label()
var array<float> liqMids = array.new_float()
var array<float> liqTops = array.new_float()
var array<float> liqBots = array.new_float()
var array<bool> liqIsBull = array.new_bool()

clearLiq() =>
    if array.size(liqBoxes) > 0
        for i = 0 to array.size(liqBoxes) - 1 by 1
            box.delete(array.get(liqBoxes, i))
        array.clear(liqBoxes)
    if array.size(liqLabels) > 0
        for i = 0 to array.size(liqLabels) - 1 by 1
            label.delete(array.get(liqLabels, i))
        array.clear(liqLabels)
    array.clear(liqMids)
    array.clear(liqTops)
    array.clear(liqBots)
    array.clear(liqIsBull)

// Compute bull/bear volume at a price level over last N bars
getZoneVolume(lvl, lookback) =>
    float bVol = 0.0
    float beVol = 0.0
    for i = 0 to lookback - 1 by 1
        if high[i] >= lvl - atrVal * liqATRMult and low[i] <= lvl + atrVal * liqATRMult
            bVol := bVol + (close[i] >= open[i] ? volume[i] : 0.0)
            beVol := beVol + (close[i] < open[i] ? volume[i] : 0.0)
            beVol
    [bVol, beVol]

recalcLiq = not na(liqPH) or not na(liqPL)

if showLiq and recalcLiq and (array.size(phPrices) > 0 or array.size(plPrices) > 0)
    clearLiq()
    cutoff = bar_index - liqLookback
    sepThresh = atrVal * minLiqSep
    zHalf = atrVal * liqATRMult / 2
    lineEnd = bar_index + zoneProjection

    // ---- Resistance zones from pivot highs ----
    array<float> chosenRes = array.new_float()
    if array.size(phPrices) > 0
        for k = 0 to math.min(maxLiqZones - 1, array.size(phPrices) - 1) by 1
            lvl = array.get(phPrices, array.size(phPrices) - 1 - k)
            tooClose = false
            if array.size(chosenRes) > 0
                for c = 0 to array.size(chosenRes) - 1 by 1
                    if math.abs(lvl - array.get(chosenRes, c)) < sepThresh
                        tooClose := true
                        tooClose
            if not tooClose
                array.push(chosenRes, lvl)
                [bv, bev] = getZoneVolume(lvl, volLookback)
                totalV = bv + bev
                bullPct = totalV > 0 ? bv / totalV * 100 : 50.0
                bearPct = totalV > 0 ? bev / totalV * 100 : 50.0
                delta = bv - bev
                isBull = bullPct >= 50
                fillCol = isBull ? colBullLiq : bearPct > 60 ? colBearLiq : colNeutralLiq
                brdCol = isBull ? color.new(#26A69A, 30) : bearPct > 60 ? color.new(#EF5350, 30) : color.new(#787B86, 30)
                startBar = math.max(bar_index - liqLookback, 0)
                bx = box.new(startBar, lvl + zHalf, lineEnd, lvl - zHalf, bgcolor = fillCol, border_color = brdCol, border_width = 2, extend = extend.right)
                array.push(liqBoxes, bx)
                array.push(liqMids, lvl)
                array.push(liqTops, lvl + zHalf)
                array.push(liqBots, lvl - zHalf)
                array.push(liqIsBull, isBull)
                label lbl = na
                if showRatio or showDelta
                    ratioTxt = showRatio ? str.tostring(math.round(bullPct)) + '% Bull / ' + str.tostring(math.round(bearPct)) + '% Bear' : ''
                    deltaTxt = showDelta ? '  Δ ' + (delta >= 0 ? '+' : '') + str.tostring(math.round(delta)) : ''
                    lblTxt = 'R  ' + str.tostring(lvl, format.mintick) + '\n' + ratioTxt + deltaTxt
                    lbl := label.new(lineEnd + 2, lvl + zHalf, lblTxt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(brdCol, 0), textcolor = color.white, size = size.small)
                    lbl
                array.push(liqLabels, lbl)

    // ---- Support zones from pivot lows ----
    array<float> chosenSup = array.new_float()
    if array.size(plPrices) > 0
        for k = 0 to math.min(maxLiqZones - 1, array.size(plPrices) - 1) by 1
            lvl = array.get(plPrices, array.size(plPrices) - 1 - k)
            tooClose = false
            if array.size(chosenSup) > 0
                for c = 0 to array.size(chosenSup) - 1 by 1
                    if math.abs(lvl - array.get(chosenSup, c)) < sepThresh
                        tooClose := true
                        tooClose
            if not tooClose
                array.push(chosenSup, lvl)
                [bv, bev] = getZoneVolume(lvl, volLookback)
                totalV = bv + bev
                bullPct = totalV > 0 ? bv / totalV * 100 : 50.0
                bearPct = totalV > 0 ? bev / totalV * 100 : 50.0
                delta = bv - bev
                isBull = bullPct >= 50
                fillCol = isBull ? colBullLiq : bearPct > 60 ? colBearLiq : colNeutralLiq
                brdCol = isBull ? color.new(#26A69A, 30) : bearPct > 60 ? color.new(#EF5350, 30) : color.new(#787B86, 30)
                startBar = math.max(bar_index - liqLookback, 0)
                bx = box.new(startBar, lvl + zHalf, lineEnd, lvl - zHalf, bgcolor = fillCol, border_color = brdCol, border_width = 2, extend = extend.right)
                array.push(liqBoxes, bx)
                array.push(liqMids, lvl)
                array.push(liqTops, lvl + zHalf)
                array.push(liqBots, lvl - zHalf)
                array.push(liqIsBull, isBull)
                label lbl = na
                if showRatio or showDelta
                    ratioTxt = showRatio ? str.tostring(math.round(bullPct)) + '% Bull / ' + str.tostring(math.round(bearPct)) + '% Bear' : ''
                    deltaTxt = showDelta ? '  Δ ' + (delta >= 0 ? '+' : '') + str.tostring(math.round(delta)) : ''
                    lblTxt = 'S  ' + str.tostring(lvl, format.mintick) + '\n' + ratioTxt + deltaTxt
                    lbl := label.new(lineEnd + 2, lvl - zHalf, lblTxt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(brdCol, 0), textcolor = color.white, size = size.small)
                    lbl
                array.push(liqLabels, lbl)

// ===================== FLOAT LABELS RIGHT EDGE =====================
if array.size(liqLabels) > 0
    for i = 0 to array.size(liqLabels) - 1 by 1
        label lbl = array.get(liqLabels, i)
        if not na(lbl)
            label.set_x(lbl, bar_index + 7)

// ===================== DASHBOARD =====================
var table dash = table.new(position.top_right, 2, 10, bgcolor = color.new(#0D1117, 5), border_color = color.new(#FFD700, 40), border_width = 1, frame_color = color.new(#FFD700, 20), frame_width = 2)

if showDash and barstate.islast
    table.merge_cells(dash, 0, 0, 1, 0)
    table.cell(dash, 0, 0, 'LIQUIDITY + VWAP/EMA', text_color = color.new(#FFD700, 0), text_size = size.normal, bgcolor = color.new(#0A1628, 5), text_halign = text.align_center)

    // Sentiment
    sentTxt = highlyBull ? 'HIGHLY BULLISH' : highlyBear ? 'HIGHLY BEARISH' : 'NEUTRAL'
    sentCol = highlyBull ? color.new(#26A69A, 0) : highlyBear ? color.new(#EF5350, 0) : color.new(#787B86, 0)
    table.cell(dash, 0, 1, 'SENTIMENT', text_color = color.new(#546E8A, 0), text_size = size.small, bgcolor = color.new(#0D1117, 5))
    table.cell(dash, 1, 1, sentTxt, text_color = sentCol, text_size = size.small, bgcolor = color.new(#0D1117, 5))

    // VWAP
    vwapDist = (close - vwapVal) / vwapVal * 100
    vwapSign = vwapDist >= 0 ? '+' : ''
    table.cell(dash, 0, 2, 'vs VWAP', text_color = color.new(#546E8A, 0), text_size = size.small, bgcolor = color.new(#111923, 5))
    table.cell(dash, 1, 2, vwapSign + str.tostring(vwapDist, '#.##') + '%', text_color = close > vwapVal ? color.new(#26A69A, 0) : color.new(#EF5350, 0), text_size = size.small, bgcolor = color.new(#111923, 5))

    // EMA1
    table.cell(dash, 0, 3, 'vs EMA ' + str.tostring(emaLen1), text_color = color.new(#546E8A, 0), text_size = size.small, bgcolor = color.new(#0D1117, 5))
    table.cell(dash, 1, 3, close > ema1 ? 'ABOVE' : 'BELOW', text_color = close > ema1 ? color.new(#26A69A, 0) : color.new(#EF5350, 0), text_size = size.small, bgcolor = color.new(#0D1117, 5))

    // EMA2
    table.cell(dash, 0, 4, 'vs EMA ' + str.tostring(emaLen2), text_color = color.new(#546E8A, 0), text_size = size.small, bgcolor = color.new(#111923, 5))
    table.cell(dash, 1, 4, close > ema2 ? 'ABOVE' : 'BELOW', text_color = close > ema2 ? color.new(#26A69A, 0) : color.new(#EF5350, 0), text_size = size.small, bgcolor = color.new(#111923, 5))

    // EMA3
    table.cell(dash, 0, 5, 'vs EMA ' + str.tostring(emaLen3), text_color = color.new(#546E8A, 0), text_size = size.small, bgcolor = color.new(#0D1117, 5))
    table.cell(dash, 1, 5, close > ema3 ? 'ABOVE' : 'BELOW', text_color = close > ema3 ? color.new(#26A69A, 0) : color.new(#EF5350, 0), text_size = size.small, bgcolor = color.new(#0D1117, 5))

    // Volume Delta
    barDelta = bullVol - bearVol
    table.cell(dash, 0, 6, 'BAR DELTA', text_color = color.new(#546E8A, 0), text_size = size.small, bgcolor = color.new(#111923, 5))
    table.cell(dash, 1, 6, (barDelta >= 0 ? '+' : '') + str.tostring(math.round(barDelta)), text_color = barDelta >= 0 ? color.new(#26A69A, 0) : color.new(#EF5350, 0), text_size = size.small, bgcolor = color.new(#111923, 5))

    // VWAP Band position
    bandPos = close > vwapUpper2 ? 'ABOVE +2σ' : close > vwapUpper1 ? 'ABOVE +1σ' : close > vwapVal ? 'ABOVE VWAP' : close > vwapLower1 ? 'BELOW VWAP' : close > vwapLower2 ? 'BELOW -1σ' : 'BELOW -2σ'
    bandCol = close > vwapVal ? color.new(#26A69A, 0) : color.new(#EF5350, 0)
    table.cell(dash, 0, 7, 'VWAP BAND', text_color = color.new(#546E8A, 0), text_size = size.small, bgcolor = color.new(#0D1117, 5))
    table.cell(dash, 1, 7, bandPos, text_color = bandCol, text_size = size.small, bgcolor = color.new(#0D1117, 5))

    // Signal
    sigTxt = highlyBull and close > vwapUpper1 ? 'STRONG BUY' : highlyBull ? 'BUY' : highlyBear and close < vwapLower1 ? 'STRONG SELL' : highlyBear ? 'SELL' : 'WAIT'
    sigCol = str.contains(sigTxt, 'BUY') ? color.new(#26A69A, 0) : str.contains(sigTxt, 'SELL') ? color.new(#EF5350, 0) : color.new(#787B86, 0)
    table.cell(dash, 0, 8, 'SIGNAL', text_color = color.new(#546E8A, 0), text_size = size.small, bgcolor = color.new(#111923, 5))
    table.cell(dash, 1, 8, sigTxt, text_color = sigCol, text_size = size.small, bgcolor = color.new(#111923, 5))

    // Footer
    table.merge_cells(dash, 0, 9, 1, 9)
    table.cell(dash, 0, 9, 'Price above EMA + VWAP = Bullish', text_color = color.new(#3D5166, 0), text_size = size.tiny, bgcolor = color.new(#060A0F, 5), text_halign = text.align_center)

// ===================== ALERTS =====================
alertcondition(highlyBull and not highlyBull[1], 'Liquidity: Turned Highly Bullish', 'Price is now above EMA1, EMA2 and VWAP - highly bullish.')
alertcondition(highlyBear and not highlyBear[1], 'Liquidity: Turned Highly Bearish', 'Price is now below EMA1, EMA2 and VWAP - highly bearish.')
alertcondition(ta.crossover(close, vwapVal), 'VWAP Cross Up', 'Price crossed above VWAP.')
alertcondition(ta.crossunder(close, vwapVal), 'VWAP Cross Down', 'Price crossed below VWAP.')
````
