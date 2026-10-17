# Ghost Candle with Shadow Rail Px

- url: https://www.tradingview.com/script/AY5Gz97v-Ghost-Candle-with-Shadow-Rail-Px/
- type: indicator
- pine_id: PUB;8b27928150f14978b487933e08cb66b7
- version: 1.0

## Description

Ghost Candle with Shadow Rail draws smoothed "ghost" candles beside your real price and pairs them with an adaptive trailing line called the Shadow Rail. It marks where a new buy or sell trend starts.

[b]What's inside[/b]

[i]1. Ghost Candles[/i]

[image]https://www.tradingview.com/x/cCnKs6gE/[/image]

*Double-smoothed Heikin Ashi-style candles drawn next to the real candles, so the noise is filtered out and the trend is easier to read.

*They sit below price in an uptrend and above it in a downtrend.

*You can set the gap between them and price, force them above or below, and choose how smoothly they glide across when the trend flips.

*A soft glow (halo) surrounds them. It gets brighter when the trend is clean and fades when the market is choppy.

[i]2. Shadow Rail[/i]

[image]https://www.tradingview.com/x/no8V3zQJ/[/image]

*An adaptive trailing line that sits under price in an uptrend and over it in a downtrend.
It adjusts to volatility, how clean the move is, and buying versus selling volume.

*When price closes through the rail, the trend flips

[i]3. Buy Start / Sell Start labels[/i]

A green BUY START label appears where a new uptrend begins, and a red SELL START label where a new downtrend begins.


[i]4. Optional filters[/i]

*Higher Timeframe filter: Only confirms buys when the higher timeframe is above its EMA, and sells when it is below. Flips that disagree get no label.

*Minimum Trend Quality %: Skips flips that happen in choppy conditions.


[s]Notes[/s] 

*A flip can change while the current candle is still open, so wait for the candle to close before treating a label as final.

*This is a trend-reading tool.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartTrader-X

//@version=6
indicator(title = 'Ghost Candle with Shadow Rail', shorttitle = 'GCSR', overlay = true)

// ═════════════ Inputs ═════════════
swingBars = input.int(5, 'Trend Sensitivity Length', minval = 1, group = 'Shadow Rail Engine', tooltip = 'Bars used for the average swing size. Lower = more reactive.')
railSpread = input.float(1.6, 'Rail Spread', minval = 0.1, step = 0.1, group = 'Shadow Rail Engine', tooltip = 'Base distance between price and the Shadow Rail.')
railDrive = input.float(95.0, 'Rail Drive', minval = 0.0, maxval = 99.0, step = 0.1, group = 'Shadow Rail Engine', tooltip = 'Higher = the rail chases price harder. Above 96 gets very intense.')

ghostBlur = input.int(10, 'Ghost Smoothing', minval = 1, group = 'Ghost Candles', tooltip = 'EMA length used for the ghost candles (applied twice).')
ghostOffset = input.float(0.0, 'Ghost Gap (x ATR)', step = 0.1, group = 'Ghost Candles', tooltip = 'Distance between the ghost candles and real price. 0 = original position. Negative flips direction.')
ghostPlacement = input.string('Trend', 'Ghost Side', options = ['Trend', 'Above', 'Below'], group = 'Ghost Candles', tooltip = 'Trend = below price in an uptrend, above price in a downtrend.')
ghostEase = input.int(5, 'Ghost Glide', minval = 1, group = 'Ghost Candles', tooltip = 'Bars used to glide the candles from one side to the other on a flip. 1 = instant.')
bullHue = input.color(color.new(#00e5a8, 0), 'Up / Down Colors', inline = 'cols', group = 'Ghost Candles')
bearHue = input.color(color.new(#ff3d71, 0), '', inline = 'cols', group = 'Ghost Candles')

drawRail = input.bool(true, 'Show Shadow Rail', group = 'Display')
paintBars = input.bool(false, 'Tint Real Candles by Trend', group = 'Display')
haloPulse = input.bool(true, 'Halo Brightness Follows Trend Quality', group = 'Display', tooltip = 'Cleaner trends glow brighter, choppy trends fade.')
drawMarkers = input.bool(true, 'Show Buy / Sell Start Labels', group = 'Display', tooltip = 'Marks the bar where a confirmed buy or sell starts.')

drawRiskMap = input.bool(false, 'Show Stop / Target Levels', group = 'Risk Map')
slAtrX = input.float(1.5, 'Stop (x ATR)', minval = 0.1, step = 0.1, group = 'Risk Map')
tpAtrX = input.float(3.0, 'Target (x ATR)', minval = 0.1, step = 0.1, group = 'Risk Map')

mtfGate = input.bool(false, 'Filter Flips by Higher Timeframe', group = 'Filters', tooltip = 'Only confirm up flips when the higher timeframe is above its EMA, and down flips when it is below. Flips that disagree are skipped.')
mtfFrame = input.timeframe('240', 'Higher Timeframe', group = 'Filters', tooltip = 'If this is not higher than the chart timeframe, the chart timeframe is used instead.')
mtfEmaBars = input.int(50, 'HTF EMA Length', minval = 2, group = 'Filters')
minTrendPct = input.float(0.0, 'Minimum Trend Quality % to Confirm', minval = 0.0, maxval = 100.0, group = 'Filters', tooltip = 'Flips with trend quality below this are rejected. 0 = confirm everything.')

// ═════════════ Fixed values ═════════════
qualBars = 10 // trend quality lookback
qualBias = 0.5 // quality weight on rail speed
kickWeight = 0.3 // impulse widening weight
flowWeight = 0.2 // volume flow weight
flowBars = 14 // volume flow smoothing
glowBars = 200 // halo width ATR length
offsetAtrBars = 14 // ghost gap ATR length
riskAtrBars = 14 // stop/target ATR length
tierHigh = 0.60 // quality at or above = strong flip

// ═════════════ Smoothed candle engine ═════════════
sdClose = (open + high + low + close) / 4
var float sdOpen = na
sdOpen := na(sdOpen[1]) ? (open + close) / 2 : (sdOpen[1] + sdClose[1]) / 2
sdHigh = math.max(high, math.max(sdOpen, sdClose))
sdLow = math.min(low, math.min(sdOpen, sdClose))
sdSpan = na(sdClose[1]) ? sdHigh - sdLow : math.max(sdHigh - sdLow, math.max(math.abs(sdHigh - sdClose[1]), math.abs(sdLow - sdClose[1])))

// ═════════════ Adaptive measures ═════════════
meanSpan = ta.sma(sdSpan, swingBars)

dirMove = math.abs(sdClose - sdClose[qualBars])
wanderMove = math.sum(math.abs(ta.change(sdClose)), qualBars)
cleanRatio = wanderMove == 0 ? 0.0 : dirMove / wanderMove

kick = meanSpan == 0 ? 0.0 : (sdClose - sdClose[1]) / meanSpan
liveSpread = railSpread * (1 + kickWeight * math.abs(kick))

rawFlow = sdHigh - sdLow == 0 ? 0.0 : (sdClose - sdOpen) / (sdHigh - sdLow) * nz(volume)
flowSmooth = ta.ema(rawFlow, flowBars)
volSmooth = ta.ema(nz(volume), flowBars)
flowBias = volSmooth == 0 ? 0.0 : math.max(-1.0, math.min(1.0, flowSmooth / volSmooth))

spreadDn = liveSpread * math.max(0.2, 1 + flowWeight * flowBias)
spreadUp = liveSpread * math.max(0.2, 1 - flowWeight * flowBias)

stepDamp = math.max(0.01, (100 - railDrive) * (1 - qualBias * (2 * cleanRatio - 1)))
slowDamp = 0.60 * stepDamp
fastDamp = 0.40 * stepDamp

topRef = sdClose + meanSpan * spreadUp
botRef = sdClose - meanSpan * spreadDn

// ═════════════ Shadow Rail state machine ═════════════
var int trendSide = 0
var float shadowLo = na
var float shadowHi = na
var float shadowPeak = na
var float shadowTrough = na

if trendSide == 0 and not na(topRef) and not na(botRef)
    trendSide := 1
    shadowLo := botRef
    shadowPeak := botRef
    shadowPeak
else if trendSide == 1
    oldPeak = shadowPeak
    shadowPeak := math.max(shadowPeak, botRef)
    if shadowPeak > oldPeak
        shadowLo := shadowLo + shadowPeak - oldPeak
        shadowLo
    else if botRef < nz(botRef[1], botRef)
        shadowLo := shadowLo - (botRef[1] - botRef) / slowDamp
        shadowLo
    else if botRef > nz(botRef[1], botRef)
        shadowLo := shadowLo + (botRef - botRef[1]) / fastDamp
        shadowLo
    if sdClose < shadowLo
        trendSide := -1
        shadowHi := topRef
        shadowTrough := topRef
        shadowLo := na
        shadowLo
else if trendSide == -1
    oldTrough = shadowTrough
    shadowTrough := math.min(shadowTrough, topRef)
    if shadowTrough < oldTrough
        shadowHi := shadowHi - (oldTrough - shadowTrough)
        shadowHi
    else if topRef > nz(topRef[1], topRef)
        shadowHi := shadowHi + (topRef - topRef[1]) / slowDamp
        shadowHi
    else if topRef < nz(topRef[1], topRef)
        shadowHi := shadowHi - (topRef[1] - topRef) / fastDamp
        shadowHi
    if sdClose > shadowHi
        trendSide := 1
        shadowLo := botRef
        shadowPeak := botRef
        shadowHi := na
        shadowHi

// ═════════════ Ghost candles ═════════════
avgO = ta.ema(open, ghostBlur)
avgC = ta.ema(close, ghostBlur)
avgH = ta.ema(high, ghostBlur)
avgL = ta.ema(low, ghostBlur)

phClose = (avgO + avgH + avgL + avgC) / 4
var float phOpen = na
phOpen := na(phOpen[1]) ? (avgO + avgC) / 2 : (phOpen[1] + phClose[1]) / 2

bodyO = ta.ema(phOpen, ghostBlur)
bodyC = ta.ema(phClose, ghostBlur)

offsetAtr = ta.rma(sdSpan, offsetAtrBars)

placeRaw = ghostPlacement == 'Above' ? 1.0 : ghostPlacement == 'Below' ? -1.0 : trendSide == 1 ? -1.0 : trendSide == -1 ? 1.0 : 0.0
placeEased = ghostEase > 1 ? ta.ema(placeRaw, ghostEase) : placeRaw
offsetAmt = placeEased * ghostOffset * offsetAtr

ghO = bodyO + offsetAmt
ghC = bodyC + offsetAmt
ghTop = math.max(ghO, ghC)
ghBot = math.min(ghO, ghC)

ghHue = trendSide == -1 ? bearHue : bullHue

// ═════════════ Halo (glow around ghost candles) ═════════════
glowHalf = ta.rma(sdSpan, glowBars) / 3
clearTone = color.new(color.white, 100)
glowTop = plot(ghTop + glowHalf, color = clearTone, editable = false)
glowBot = plot(ghBot - glowHalf, color = clearTone, editable = false)
glowTransp = haloPulse ? 92 - math.round(cleanRatio * 30) : 75
fill(glowTop, glowBot, color = color.new(ghHue, glowTransp))

plotcandle(ghO, ghTop, ghBot, ghC, title = 'Ghost Candles', color = ghHue, wickcolor = ghHue, bordercolor = ghHue)

// ═════════════ Shadow Rail plot ═════════════
plot(drawRail and trendSide == 1 ? shadowLo : na, 'Shadow Rail Up', color = bullHue, linewidth = 2, style = plot.style_linebr)
plot(drawRail and trendSide == -1 ? shadowHi : na, 'Shadow Rail Down', color = bearHue, linewidth = 2, style = plot.style_linebr)

barcolor(paintBars ? trendSide == 1 ? bullHue : trendSide == -1 ? bearHue : na : na)

// ═════════════ Flip detection and filters ═════════════
rawTurnUp = trendSide == 1 and trendSide[1] == -1
rawTurnDn = trendSide == -1 and trendSide[1] == 1

mtfUse = timeframe.in_seconds(mtfFrame) > timeframe.in_seconds() ? mtfFrame : timeframe.period
mtfBull = request.security(syminfo.tickerid, mtfUse, close[1] > ta.ema(close, mtfEmaBars)[1], lookahead = barmerge.lookahead_on)
mtfOkUp = not mtfGate or mtfBull
mtfOkDn = not mtfGate or not mtfBull
pctOk = cleanRatio * 100 >= minTrendPct

turnUp = rawTurnUp and mtfOkUp and pctOk
turnDn = rawTurnDn and mtfOkDn and pctOk

topTurnUp = turnUp and cleanRatio >= tierHigh
topTurnDn = turnDn and cleanRatio >= tierHigh

// ═════════════ Flip markers (confirmed vs rejected) ═════════════
plotshape(drawMarkers and turnUp, 'Buy Start', style = shape.labelup, location = location.belowbar, color = bullHue, text = 'BUY START', textcolor = color.white, size = size.small)
plotshape(drawMarkers and turnDn, 'Sell Start', style = shape.labeldown, location = location.abovebar, color = bearHue, text = 'SELL START', textcolor = color.white, size = size.small)

// ═════════════ Stop / target map ═════════════
riskRange = ta.atr(riskAtrBars)
var float entryLvl = na
var float stopLvl = na
var float targetLvl = na

if rawTurnUp or rawTurnDn
    entryLvl := na
    stopLvl := na
    targetLvl := na
    targetLvl
if turnUp
    entryLvl := close
    stopLvl := close - slAtrX * riskRange
    targetLvl := close + tpAtrX * riskRange
    targetLvl
if turnDn
    entryLvl := close
    stopLvl := close + slAtrX * riskRange
    targetLvl := close - tpAtrX * riskRange
    targetLvl

plot(drawRiskMap ? entryLvl : na, 'Entry', color = color.new(color.gray, 20), style = plot.style_linebr, linewidth = 1)
plot(drawRiskMap ? stopLvl : na, 'Stop', color = color.new(color.red, 10), style = plot.style_linebr, linewidth = 1)
plot(drawRiskMap ? targetLvl : na, 'Target', color = color.new(color.green, 10), style = plot.style_linebr, linewidth = 1)

// ═════════════ Alerts ═════════════
alertcondition(turnUp, title = 'Ghost Candle: Trend Flips Up')
alertcondition(turnDn, title = 'Ghost Candle: Trend Flips Down')
alertcondition(topTurnUp, title = 'Ghost Candle: STRONG Flip Up')
alertcondition(topTurnDn, title = 'Ghost Candle: STRONG Flip Down')
````
