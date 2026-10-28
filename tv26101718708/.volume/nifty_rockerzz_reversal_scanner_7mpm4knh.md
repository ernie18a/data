# NIFTY Rockerzz Reversal Scanner

- url: https://www.tradingview.com/script/7Mpm4kNH-NIFTY-Rockerzz-Reversal-Scanner/
- type: indicator
- pine_id: PUB;1f9826a80f1c4a8a82a753f3c4d812d5
- version: 1.0

## Description

RSI Bullish Divergence
CMF below -0.35
Stochastic Oversold (<20)

## Source Code

````pine
//@version=6
indicator("NIFTY Rockerzz Reversal Scanner", overlay=true, max_labels_count=500, max_lines_count=500)

//#region inputs
scanTf1 = input.timeframe("15", "Scan TF 1")
scanTf2 = input.timeframe("60", "Scan TF 2")
scanTf3 = input.timeframe("240", "Scan TF 3")
scanTf4 = input.timeframe("D", "Scan TF 4")
showTf1 = input.bool(true, "Show TF1")
showTf2 = input.bool(true, "Show TF2")
showTf3 = input.bool(true, "Show TF3")
showTf4 = input.bool(true, "Show TF4")
showTable = input.bool(true, "Show Table")
stochK = input.int(14, "Stoch %K Length", minval=3, maxval=100, tooltip="Stochastic %K lookback period")
stochDSmooth = input.int(3, "Stoch %D Smooth", minval=1, maxval=20, tooltip="Stochastic %D smoothing")
stochSmooth = input.int(3, "Stoch Smooth", minval=1, maxval=20, tooltip="Stochastic internal smoothing")
pivotLeft = input.int(5, "DIV Pivot Left", minval=2, maxval=50, tooltip="Bars to the left of the pivot point")
pivotRight = input.int(5, "DIV Pivot Right", minval=2, maxval=50, tooltip="Bars to the right of the pivot point (confirmation)")
cmfBuyThresh = input.float(-0.30, "CMF Buy Threshold", minval=-1.00, maxval=1.00, step=0.01, tooltip="CMF at or below this triggers Buy signal")
cmfSellThresh = input.float(0.30, "CMF Sell Threshold", minval=-1.00, maxval=1.00, step=0.01, tooltip="CMF at or above this triggers Sell signal")
//#endregion

//#region helpers
fmt(value) => str.tostring(value, "#.##")

f_tfLabel(tf) =>
    tf == "15" ? "15M" : tf == "60" ? "1H" : tf == "240" ? "4H" : tf == "D" ? "1D" : tf == "W" ? "1W" : tf == "M" ? "1M" : tf

bold(textValue) => textValue

labelLeft(textValue) => textValue

rowBg(row) => row % 2 == 0 ? color.rgb(248, 248, 248) : color.rgb(240, 240, 240)

//@function Manual Stochastic %K with configurable smoothing.
//@param len Lookback period.
//@param smoothK Internal smoothing for %K.
//@param smoothD Smoothing for %D (the final line).
//@returns Smoothed %K value.
f_stochK(len, smoothK, smoothD) =>
    ll = ta.lowest(low, len)
    hh = ta.highest(high, len)
    rawK = 100 * (close - ll) / (hh - ll)
    k = ta.sma(rawK, smoothK)
    k

//@function Manual Stochastic %D with configurable smoothing.
//@param len Lookback period.
//@param smoothK Internal smoothing for %K.
//@param smoothD Smoothing for %D (the final line).
//@returns Smoothed %D value.
f_stochD(len, smoothK, smoothD) =>
    ll = ta.lowest(low, len)
    hh = ta.highest(high, len)
    rawK = 100 * (close - ll) / (hh - ll)
    k = ta.sma(rawK, smoothK)
    ta.sma(k, smoothD)

//@function True swing-point RSI divergence detector.
//@param len RSI length.
//@param leftBars Bars to the left of the pivot.
//@param rightBars Bars to the right of the pivot (confirmation).
//@returns 1 = bearish divergence, -1 = bullish divergence, 0 = none.
f_divSwing(len, leftBars, rightBars) =>
    rsiVal = ta.rsi(close, len)
    
    phPrice = ta.pivothigh(close, leftBars, rightBars)
    phRsi   = ta.pivothigh(rsiVal, leftBars, rightBars)
    
    lastPhPrice = ta.valuewhen(not na(phPrice), phPrice, 0)
    prevPhPrice = ta.valuewhen(not na(phPrice), phPrice, 1)
    lastPhRsi   = ta.valuewhen(not na(phRsi), phRsi, 0)
    prevPhRsi   = ta.valuewhen(not na(phRsi), phRsi, 1)
    
    plPrice = ta.pivotlow(close, leftBars, rightBars)
    plRsi   = ta.pivotlow(rsiVal, leftBars, rightBars)
    
    lastPlPrice = ta.valuewhen(not na(plPrice), plPrice, 0)
    prevPlPrice = ta.valuewhen(not na(plPrice), plPrice, 1)
    lastPlRsi   = ta.valuewhen(not na(plRsi), plRsi, 0)
    prevPlRsi   = ta.valuewhen(not na(plRsi), plRsi, 1)
    
    bearDiv = not na(lastPhPrice) and not na(prevPhPrice) and lastPhPrice > prevPhPrice and lastPhRsi < prevPhRsi
    bullDiv = not na(lastPlPrice) and not na(prevPlPrice) and lastPlPrice < prevPlPrice and lastPlRsi > prevPlRsi
    
    bearDiv ? 1 : bullDiv ? -1 : 0

//@function Calculate CMF value.
//@param length Lookback length.
//@returns CMF value.
f_cmf(length) =>
    mf = close == high and close == low ? 0.0 : ((close - low) - (high - close)) / (high - low) * volume
    sumMf = math.sum(mf, length)
    sumVol = math.sum(volume, length)
    sumVol != 0 ? sumMf / sumVol : 0.0

//@function Calculate CHOP value.
//@param length Lookback length.
//@returns CHOP value.
f_chop(length) =>
    trSum = math.sum(ta.tr, length)
    hh = ta.highest(high, length)
    ll = ta.lowest(low, length)
    rng = hh - ll
    rng != 0 ? 100 * math.log10(trSum / rng) / math.log10(length) : 0.0

//@function Calculate CMF signal state.
//@param cmfValue CMF value.
//@returns Signal text and background color.
f_cmfSignal(cmfValue) =>
    string signalText = "⚪ Neutral"
    color signalBg = color.rgb(225, 225, 225)
    if cmfValue <= cmfBuyThresh
        signalText := "🟢 Buy"
        signalBg := color.rgb(204, 255, 204)
    else if cmfValue >= cmfSellThresh
        signalText := "🔴 Sell"
        signalBg := color.rgb(255, 204, 204)
    [signalText, signalBg]

//@function Calculate stochastic signal label.
//@param stochVal Stochastic value.
//@param stochSig Stochastic crossover state.
//@returns Signal text and background color.
f_signalLabel(stochVal, stochSig) =>
    string signalText = "Neutral"
    color signalBg = color.rgb(225, 225, 225)
    if stochSig == 1 and stochVal <= 20
        signalText := "Oversold-PCO"
        signalBg := color.rgb(204, 255, 204)
    else if stochSig == 1
        signalText := "PCO"
        signalBg := color.rgb(204, 255, 204)
    else if stochSig == -1 and stochVal >= 80
        signalText := "Overbought-NCO"
        signalBg := color.rgb(255, 204, 204)
    else if stochSig == -1
        signalText := "NCO"
        signalBg := color.rgb(255, 204, 204)
    else if stochVal > 80 and stochSig == 0
        signalText := "Overbought"
        signalBg := color.rgb(255, 204, 204)
    else if stochVal < 20 and stochSig == 0
        signalText := "Oversold"
        signalBg := color.rgb(204, 255, 204)
    [signalText, signalBg]
//#endregion

//#region data
[close15, rsi15, cmf15, chop15, stochK15, stochD15, div15] = request.security(syminfo.tickerid, scanTf1, [close, ta.rsi(close, 14), f_cmf(20), f_chop(14), f_stochK(stochK, stochSmooth, stochDSmooth), f_stochD(stochK, stochSmooth, stochDSmooth), f_divSwing(14, pivotLeft, pivotRight)])
[close60, rsi60, cmf60, chop60, stochK60, stochD60, div60] = request.security(syminfo.tickerid, scanTf2, [close, ta.rsi(close, 14), f_cmf(20), f_chop(14), f_stochK(stochK, stochSmooth, stochDSmooth), f_stochD(stochK, stochSmooth, stochDSmooth), f_divSwing(14, pivotLeft, pivotRight)])
[close240, rsi240, cmf240, chop240, stochK240, stochD240, div240] = request.security(syminfo.tickerid, scanTf3, [close, ta.rsi(close, 14), f_cmf(20), f_chop(14), f_stochK(stochK, stochSmooth, stochDSmooth), f_stochD(stochK, stochSmooth, stochDSmooth), f_divSwing(14, pivotLeft, pivotRight)])
[closeD, rsiD, cmfD, chopD, stochKD, stochDD, divD] = request.security(syminfo.tickerid, scanTf4, [close, ta.rsi(close, 14), f_cmf(20), f_chop(14), f_stochK(stochK, stochSmooth, stochDSmooth), f_stochD(stochK, stochSmooth, stochDSmooth), f_divSwing(14, pivotLeft, pivotRight)])

var int stochSig15 = 0
var int stochSig60 = 0
var int stochSig240 = 0
var int stochSigD = 0

if ta.crossover(stochK15, stochD15)
    stochSig15 := 1
if ta.crossunder(stochK15, stochD15)
    stochSig15 := -1

if ta.crossover(stochK60, stochD60)
    stochSig60 := 1
if ta.crossunder(stochK60, stochD60)
    stochSig60 := -1

if ta.crossover(stochK240, stochD240)
    stochSig240 := 1
if ta.crossunder(stochK240, stochD240)
    stochSig240 := -1

if ta.crossover(stochKD, stochDD)
    stochSigD := 1
if ta.crossunder(stochKD, stochDD)
    stochSigD := -1

[_, _, adx15] = request.security(syminfo.tickerid, scanTf1, ta.dmi(14, 14))
[_, _, adx60] = request.security(syminfo.tickerid, scanTf2, ta.dmi(14, 14))
[_, _, adx240] = request.security(syminfo.tickerid, scanTf3, ta.dmi(14, 14))
[_, _, adxD] = request.security(syminfo.tickerid, scanTf4, ta.dmi(14, 14))
//#endregion

//#region table
var table t = table.new(position.top_right, 3, 31, frame_color=color.gray, border_color=color.gray, border_width=1)

if barstate.islast and showTable
    t.cell(0, 0, "TF", text_color=color.white, bgcolor=color.rgb(80, 80, 100))
    t.cell(1, 0, "VALUE", text_color=color.white, bgcolor=color.rgb(80, 80, 100))
    t.cell(2, 0, "SIGNAL", text_color=color.white, bgcolor=color.rgb(80, 80, 100))

    int row = 1

    if showTf1
        t.cell(0, row, bold("—— " + f_tfLabel(scanTf1) + " ——"), text_color=color.white, text_size=size.small, bgcolor=color.rgb(80, 80, 100), text_halign=text.align_center)
        t.cell(1, row, "", bgcolor=color.rgb(80, 80, 100))
        t.cell(2, row, "", bgcolor=color.rgb(80, 80, 100))
        table.merge_cells(t, 0, row, 2, row)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf1) + " CMF")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(cmf15)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        [cmf15Signal, cmf15Bg] = f_cmfSignal(cmf15)
        t.cell(2, row, bold(cmf15Signal), text_color=color.black, text_size=size.small, bgcolor=cmf15Bg)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf1) + " RSI")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(rsi15)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(rsi15 > 50 ? "🟢 Bull" : "🔴 Bear"), text_color=color.black, text_size=size.small, bgcolor=rsi15 > 50 ? color.rgb(204, 255, 204) : color.rgb(255, 204, 204))
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf1) + " ADX")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(adx15)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(adx15 > 20 ? "🟢 Trend" : "⚪ Weak"), text_color=color.black, text_size=size.small, bgcolor=adx15 > 20 ? color.rgb(255, 235, 204) : color.rgb(225, 225, 225))
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf1) + " CHOP")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(chop15)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(chop15 < 60 ? "🟢 Active" : "⚪ Sideways"), text_color=color.black, text_size=size.small, bgcolor=chop15 < 60 ? color.rgb(255, 218, 185) : color.rgb(225, 225, 225))
        row += 1

        [stoch15Signal, stoch15Bg] = f_signalLabel(stochK15, stochSig15)
        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf1) + " STOCH")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(stochK15)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(stoch15Signal), text_color=color.black, text_size=size.small, bgcolor=stoch15Bg)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf1) + " DIV")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(div15)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(div15 == 1 ? "🟠 Bear DIV" : div15 == -1 ? "🟢 Bull DIV" : "⚪ None"), text_color=color.black, text_size=size.small, bgcolor=div15 == 1 ? color.rgb(230, 215, 255) : div15 == -1 ? color.rgb(204, 255, 204) : color.rgb(225, 225, 225))
        row += 1

    if showTf2
        t.cell(0, row, bold("—— " + f_tfLabel(scanTf2) + " ——"), text_color=color.white, text_size=size.small, bgcolor=color.rgb(80, 80, 100), text_halign=text.align_center)
        t.cell(1, row, "", bgcolor=color.rgb(80, 80, 100))
        t.cell(2, row, "", bgcolor=color.rgb(80, 80, 100))
        table.merge_cells(t, 0, row, 2, row)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf2) + " CMF")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(cmf60)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        [cmf60Signal, cmf60Bg] = f_cmfSignal(cmf60)
        t.cell(2, row, bold(cmf60Signal), text_color=color.black, text_size=size.small, bgcolor=cmf60Bg)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf2) + " RSI")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(rsi60)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(rsi60 > 50 ? "🟢 Bull" : "🔴 Bear"), text_color=color.black, text_size=size.small, bgcolor=rsi60 > 50 ? color.rgb(204, 255, 204) : color.rgb(255, 204, 204))
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf2) + " ADX")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(adx60)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(adx60 > 20 ? "🟢 Trend" : "⚪ Weak"), text_color=color.black, text_size=size.small, bgcolor=adx60 > 20 ? color.rgb(255, 235, 204) : color.rgb(225, 225, 225))
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf2) + " CHOP")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(chop60)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(chop60 < 60 ? "🟢 Active" : "⚪ Sideways"), text_color=color.black, text_size=size.small, bgcolor=chop60 < 60 ? color.rgb(255, 218, 185) : color.rgb(225, 225, 225))
        row += 1

        [stoch60Signal, stoch60Bg] = f_signalLabel(stochK60, stochSig60)
        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf2) + " STOCH")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(stochK60)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(stoch60Signal), text_color=color.black, text_size=size.small, bgcolor=stoch60Bg)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf2) + " DIV")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(div60)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(div60 == 1 ? "🟠 Bear DIV" : div60 == -1 ? "🟢 Bull DIV" : "⚪ None"), text_color=color.black, text_size=size.small, bgcolor=div60 == 1 ? color.rgb(230, 215, 255) : div60 == -1 ? color.rgb(204, 255, 204) : color.rgb(225, 225, 225))
        row += 1

    if showTf3
        t.cell(0, row, bold("—— " + f_tfLabel(scanTf3) + " ——"), text_color=color.white, text_size=size.small, bgcolor=color.rgb(80, 80, 100), text_halign=text.align_center)
        t.cell(1, row, "", bgcolor=color.rgb(80, 80, 100))
        t.cell(2, row, "", bgcolor=color.rgb(80, 80, 100))
        table.merge_cells(t, 0, row, 2, row)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf3) + " CMF")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(cmf240)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        [cmf240Signal, cmf240Bg] = f_cmfSignal(cmf240)
        t.cell(2, row, bold(cmf240Signal), text_color=color.black, text_size=size.small, bgcolor=cmf240Bg)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf3) + " RSI")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(rsi240)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(rsi240 > 50 ? "🟢 Bull" : "🔴 Bear"), text_color=color.black, text_size=size.small, bgcolor=rsi240 > 50 ? color.rgb(204, 255, 204) : color.rgb(255, 204, 204))
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf3) + " ADX")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(adx240)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(adx240 > 20 ? "🟢 Trend" : "⚪ Weak"), text_color=color.black, text_size=size.small, bgcolor=adx240 > 20 ? color.rgb(255, 235, 204) : color.rgb(225, 225, 225))
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf3) + " CHOP")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(chop240)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(chop240 < 60 ? "🟢 Active" : "⚪ Sideways"), text_color=color.black, text_size=size.small, bgcolor=chop240 < 60 ? color.rgb(255, 218, 185) : color.rgb(225, 225, 225))
        row += 1

        [stoch240Signal, stoch240Bg] = f_signalLabel(stochK240, stochSig240)
        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf3) + " STOCH")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(stochK240)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(stoch240Signal), text_color=color.black, text_size=size.small, bgcolor=stoch240Bg)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf3) + " DIV")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(div240)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(div240 == 1 ? "🟠 Bear DIV" : div240 == -1 ? "🟢 Bull DIV" : "⚪ None"), text_color=color.black, text_size=size.small, bgcolor=div240 == 1 ? color.rgb(230, 215, 255) : div240 == -1 ? color.rgb(204, 255, 204) : color.rgb(225, 225, 225))
        row += 1

    if showTf4
        t.cell(0, row, bold("—— " + f_tfLabel(scanTf4) + " ——"), text_color=color.white, text_size=size.small, bgcolor=color.rgb(80, 80, 100), text_halign=text.align_center)
        t.cell(1, row, "", bgcolor=color.rgb(80, 80, 100))
        t.cell(2, row, "", bgcolor=color.rgb(80, 80, 100))
        table.merge_cells(t, 0, row, 2, row)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf4) + " CMF")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(cmfD)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        [cmfDSignal, cmfDBg] = f_cmfSignal(cmfD)
        t.cell(2, row, bold(cmfDSignal), text_color=color.black, text_size=size.small, bgcolor=cmfDBg)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf4) + " RSI")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(rsiD)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(rsiD > 50 ? "🟢 Bull" : "🔴 Bear"), text_color=color.black, text_size=size.small, bgcolor=rsiD > 50 ? color.rgb(204, 255, 204) : color.rgb(255, 204, 204))
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf4) + " ADX")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(adxD)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(adxD > 20 ? "🟢 Trend" : "⚪ Weak"), text_color=color.black, text_size=size.small, bgcolor=adxD > 20 ? color.rgb(255, 235, 204) : color.rgb(225, 225, 225))
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf4) + " CHOP")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(chopD)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(chopD < 60 ? "🟢 Active" : "⚪ Sideways"), text_color=color.black, text_size=size.small, bgcolor=chopD < 60 ? color.rgb(255, 218, 185) : color.rgb(225, 225, 225))
        row += 1

        [stochDSignal, stochDBg] = f_signalLabel(stochKD, stochSigD)
        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf4) + " STOCH")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(stochKD)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(stochDSignal), text_color=color.black, text_size=size.small, bgcolor=stochDBg)
        row += 1

        t.cell(0, row, bold(labelLeft(f_tfLabel(scanTf4) + " DIV")), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(1, row, bold(fmt(divD)), text_color=color.black, text_size=size.small, bgcolor=rowBg(row))
        t.cell(2, row, bold(divD == 1 ? "🟠 Bear DIV" : divD == -1 ? "🟢 Bull DIV" : "⚪ None"), text_color=color.black, text_size=size.small, bgcolor=divD == 1 ? color.rgb(230, 215, 255) : divD == -1 ? color.rgb(204, 255, 204) : color.rgb(225, 225, 225))
//#endregion
````
