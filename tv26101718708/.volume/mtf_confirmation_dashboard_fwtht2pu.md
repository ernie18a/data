# MTF Confirmation Dashboard

- url: https://www.tradingview.com/script/fwTht2PU-MTF-Confirmation-Dashboard/
- type: indicator
- pine_id: PUB;d69b412814a646e6a9e818578e7e1423
- version: 7.0

## Description

multi time frame; 15 min, 1 hr., 4 hr., and 1 day; confirmation overlay using EMA to determine trend, RSI and MACD to determine momentum.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jayjetty1970
//@version=6
indicator("Pro MTF Dashboard by jayjetty1970", shorttitle = "Pro Dash - jayjetty", overlay = true)

// --- Constants ---
string GRP_TF = "Timeframes"
string GRP_ST = "Indicator Settings"
string GRP_CL = "Colors"
string GRP_AL = "Alerts"

color  BLUE   = #5b9cf6
color  BULL_STRONG = #089981
color  BULL_WEAK   = #006400 // Dark Green
color  BEAR_STRONG = #f23645
color  BEAR_WEAK   = #8b0000 // Dark Red
color  NEUTRAL     = #787b86

// --- Inputs ---
tfMode = input.string("Auto", "Timeframe Mode", options = ["Manual", "Auto"], group = GRP_TF)
tf1_in = input.timeframe("15", "Manual TF 1", group = GRP_TF)
tf2_in = input.timeframe("60", "Manual TF 2", group = GRP_TF)
tf3_in = input.timeframe("240", "Manual TF 3", group = GRP_TF)
tf4_in = input.timeframe("D", "Manual TF 4", group = GRP_TF)

emaFastLen = input.int(20, "EMA Fast Length", minval = 1, group = GRP_ST)
emaSlowLen = input.int(50, "EMA Slow Length", minval = 1, group = GRP_ST)
rsiLen     = input.int(14, "RSI Length", minval = 1, group = GRP_ST)
macdFast   = input.int(12, "MACD Fast", group = GRP_ST)
macdSlow   = input.int(26, "MACD Slow", group = GRP_ST)
macdSignal = input.int(9, "MACD Signal", group = GRP_ST)
stochLen   = input.int(14, "Stoch Length", group = GRP_ST)
adxLen     = input.int(14, "ADX Length", group = GRP_ST)
adxThresh  = input.int(20, "ADX Strength Threshold", minval = 1, group = GRP_ST)
volLen     = input.int(20, "Volume SMA Length", minval = 1, group = GRP_ST)

tablePos   = input.string("top_right", "Dashboard Position", options = ["top_right", "bottom_right", "top_left", "bottom_left", "middle_right"], group = GRP_ST)
tableSize  = input.string("small", "Dashboard Size", options = ["tiny", "small", "normal", "large"], group = GRP_ST)

alertGlobal = input.bool(true, "Alert on Global Sentiment Change", group = GRP_AL, tooltip = "Triggers an alert when Global Sentiment is aligned AND both 15m/60m timeframes have Strong signals with Volume confirmation.")

// --- Auto Adaptive Timeframe Logic ---
getAutoTF(int index) =>
    int sec = timeframe.in_seconds()
    string res = ""
    if sec <= 60 // 1m
        res := index == 0 ? "1" : index == 1 ? "5" : index == 2 ? "15" : "60"
    else if sec <= 300 // 5m
        res := index == 0 ? "5" : index == 1 ? "15" : index == 2 ? "60" : "240"
    else if sec <= 900 // 15m
        res := index == 0 ? "15" : index == 1 ? "60" : index == 2 ? "240" : "D"
    else if sec <= 3600 // 1h
        res := index == 0 ? "60" : index == 1 ? "240" : index == 2 ? "D" : "W"
    else if sec <= 14400 // 4h
        res := index == 0 ? "240" : index == 1 ? "D" : index == 2 ? "W" : "M"
    else // Daily or higher
        res := index == 0 ? "D" : index == 1 ? "W" : index == 2 ? "M" : "3M"
    res

tf1 = tfMode == "Auto" ? getAutoTF(0) : tf1_in
tf2 = tfMode == "Auto" ? getAutoTF(1) : tf2_in
tf3 = tfMode == "Auto" ? getAutoTF(2) : tf3_in
tf4 = tfMode == "Auto" ? getAutoTF(3) : tf4_in

// --- Helper Functions ---
calcSignals() =>
    fEma = ta.ema(close, emaFastLen)
    sEma = ta.ema(close, emaSlowLen)
    rsi  = ta.rsi(close, rsiLen)
    [macdLine, signalLine, _] = ta.macd(close, macdFast, macdSlow, macdSignal)
    k = ta.sma(ta.stoch(close, high, low, stochLen), 3)
    d = ta.sma(k, 3)
    [plusDI, minusDI, adx] = ta.dmi(adxLen, adxLen)
    rvol = volume / ta.sma(volume, volLen)
    
    bool trendBull  = fEma > sEma
    bool momBull    = rsi > 50
    bool macdBull   = macdLine > signalLine
    bool stochBull  = k > d
    bool adxBull    = plusDI > minusDI and adx > adxThresh
    bool adxBear    = minusDI > plusDI and adx > adxThresh
    bool volConf    = rvol > 1.0
    
    float bScore = 0.0
    bScore += trendBull ? 20 : 0
    bScore += momBull   ? 20 : 0
    bScore += macdBull  ? 20 : 0
    bScore += stochBull ? 20 : 0
    bScore += adxBull   ? 10 : 0
    bScore += (volConf and trendBull) ? 10 : 0
    
    float rScore = 0.0
    rScore += not trendBull ? 20 : 0
    rScore += not momBull   ? 20 : 0
    rScore += not macdBull  ? 20 : 0
    rScore += not stochBull ? 20 : 0
    rScore += adxBear       ? 10 : 0
    rScore += (volConf and not trendBull) ? 10 : 0
    
    [trendBull, momBull, macdBull, stochBull, adx, rvol, bScore, rScore]

// --- Logic ---
[t1Trend, t1Mom, t1Macd, t1Stoch, t1Adx, t1Vol, t1BS, t1RS] = request.security(syminfo.tickerid, tf1, calcSignals())
[t2Trend, t2Mom, t2Macd, t2Stoch, t2Adx, t2Vol, t2BS, t2RS] = request.security(syminfo.tickerid, tf2, calcSignals())
[t3Trend, t3Mom, t3Macd, t3Stoch, t3Adx, t3Vol, t3BS, t3RS] = request.security(syminfo.tickerid, tf3, calcSignals())
[t4Trend, t4Mom, t4Macd, t4Stoch, t4Adx, t4Vol, t4BS, t4RS] = request.security(syminfo.tickerid, tf4, calcSignals())

// --- Global Sentiment Calculation ---
avgBS = (t1BS + t2BS + t3BS + t4BS) / 4
avgRS = (t1RS + t2RS + t3RS + t4RS) / 4

// --- Enhanced Global Alert Logic ---
// Alert triggers when:
// 1. Global score >= 70%
// 2. 15m (TF1) is Strong (Score >= 80%) AND has Volume Confirmation (> 1.0)
// 3. 60m (TF2) is Strong (Score >= 80%) AND has Volume Confirmation (> 1.0)
longConfirm  = (avgBS >= 70) and (t1BS >= 80 and t1Vol > 1.0) and (t2BS >= 80 and t2Vol > 1.0)
shortConfirm = (avgRS >= 70) and (t1RS >= 80 and t1Vol > 1.0) and (t2RS >= 80 and t2Vol > 1.0)

if alertGlobal
    if longConfirm and not longConfirm[1]
        alert(str.format("ULTRA GLOBAL BUY ({0}): Full alignment on 15m/60m with Volume Confirmation!", syminfo.ticker), alert.freq_once_per_bar)
    if shortConfirm and not shortConfirm[1]
        alert(str.format("ULTRA GLOBAL SELL ({0}): Full alignment on 15m/60m with Volume Confirmation!", syminfo.ticker), alert.freq_once_per_bar)

// --- Table Visualization ---
var table dash = table.new(tablePos, 8, 6, frame_color = color.gray, frame_width = 1, border_color = color.gray, border_width = 1)

if barstate.islast
    // Headers
    table.cell(dash, 0, 0, "TF", bgcolor = NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 1, 0, "EMA", bgcolor = NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 2, 0, "RSI", bgcolor = NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 3, 0, "MACD", bgcolor = NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 4, 0, "STOCH", bgcolor = NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 5, 0, "ADX", bgcolor = NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 6, 0, "VOL", bgcolor = NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 7, 0, "SCORE %", bgcolor = NEUTRAL, text_color = color.white, text_size = tableSize)

    // Row 1
    table.cell(dash, 0, 1, tf1, text_color = BLUE, text_size = tableSize)
    table.cell(dash, 1, 1, t1Trend ? "▲" : "▼", bgcolor = t1Trend ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 2, 1, t1Mom ? "▲" : "▼", bgcolor = t1Mom ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 3, 1, t1Macd ? "▲" : "▼", bgcolor = t1Macd ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 4, 1, t1Stoch ? "▲" : "▼", bgcolor = t1Stoch ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 5, 1, str.tostring(t1Adx, "##"), bgcolor = t1Adx > adxThresh ? BULL_STRONG : NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 6, 1, str.tostring(t1Vol, "#.#"), bgcolor = t1Vol > 1.0 ? BLUE : NEUTRAL, text_color = color.white, text_size = tableSize)
    score1 = math.max(t1BS, t1RS)
    vTxt1 = t1BS >= 80 ? "STR BUY" : t1RS >= 80 ? "STR SELL" : t1BS >= 50 ? "BULL" : t1RS >= 50 ? "BEAR" : "NEUT"
    vCol1 = t1BS >= 80 ? BULL_STRONG : t1RS >= 80 ? BEAR_STRONG : t1BS >= 50 ? BULL_WEAK : t1RS >= 50 ? BEAR_WEAK : NEUTRAL
    table.cell(dash, 7, 1, vTxt1 + " (" + str.tostring(score1, "#") + "%)", bgcolor = vCol1, text_color = color.white, text_size = tableSize)

    // Row 2
    table.cell(dash, 0, 2, tf2, text_color = BLUE, text_size = tableSize)
    table.cell(dash, 1, 2, t2Trend ? "▲" : "▼", bgcolor = t2Trend ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 2, 2, t2Mom ? "▲" : "▼", bgcolor = t2Mom ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 3, 2, t2Macd ? "▲" : "▼", bgcolor = t2Macd ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 4, 2, t2Stoch ? "▲" : "▼", bgcolor = t2Stoch ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 5, 2, str.tostring(t2Adx, "##"), bgcolor = t2Adx > adxThresh ? BULL_STRONG : NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 6, 2, str.tostring(t2Vol, "#.#"), bgcolor = t2Vol > 1.0 ? BLUE : NEUTRAL, text_color = color.white, text_size = tableSize)
    score2 = math.max(t2BS, t2RS)
    vTxt2 = t2BS >= 80 ? "STR BUY" : t2RS >= 80 ? "STR SELL" : t2BS >= 50 ? "BULL" : t2RS >= 50 ? "BEAR" : "NEUT"
    vCol2 = t2BS >= 80 ? BULL_STRONG : t2RS >= 80 ? BEAR_STRONG : t2BS >= 50 ? BULL_WEAK : t2RS >= 50 ? BEAR_WEAK : NEUTRAL
    table.cell(dash, 7, 2, vTxt2 + " (" + str.tostring(score2, "#") + "%)", bgcolor = vCol2, text_color = color.white, text_size = tableSize)

    // Row 3
    table.cell(dash, 0, 3, tf3, text_color = BLUE, text_size = tableSize)
    table.cell(dash, 1, 3, t3Trend ? "▲" : "▼", bgcolor = t3Trend ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 2, 3, t3Mom ? "▲" : "▼", bgcolor = t3Mom ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 3, 3, t3Macd ? "▲" : "▼", bgcolor = t3Macd ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 4, 3, t3Stoch ? "▲" : "▼", bgcolor = t3Stoch ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 5, 3, str.tostring(t3Adx, "##"), bgcolor = t3Adx > adxThresh ? BULL_STRONG : NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 6, 3, str.tostring(t3Vol, "#.#"), bgcolor = t3Vol > 1.0 ? BLUE : NEUTRAL, text_color = color.white, text_size = tableSize)
    score3 = math.max(t3BS, t3RS)
    vTxt3 = t3BS >= 80 ? "STR BUY" : t3RS >= 80 ? "STR SELL" : t3BS >= 50 ? "BULL" : t3RS >= 50 ? "BEAR" : "NEUT"
    vCol3 = t3BS >= 80 ? BULL_STRONG : t3RS >= 80 ? BEAR_STRONG : t3BS >= 50 ? BULL_WEAK : t3RS >= 50 ? BEAR_WEAK : NEUTRAL
    table.cell(dash, 7, 3, vTxt3 + " (" + str.tostring(score3, "#") + "%)", bgcolor = vCol3, text_color = color.white, text_size = tableSize)

    // Row 4
    table.cell(dash, 0, 4, tf4, text_color = BLUE, text_size = tableSize)
    table.cell(dash, 1, 4, t4Trend ? "▲" : "▼", bgcolor = t4Trend ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 2, 4, t4Mom ? "▲" : "▼", bgcolor = t4Mom ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 3, 4, t4Macd ? "▲" : "▼", bgcolor = t4Macd ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 4, 4, t4Stoch ? "▲" : "▼", bgcolor = t4Stoch ? BULL_STRONG : BEAR_STRONG, text_color = color.white, text_size = tableSize)
    table.cell(dash, 5, 4, str.tostring(t4Adx, "##"), bgcolor = t4Adx > adxThresh ? BULL_STRONG : NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 6, 4, str.tostring(t4Vol, "#.#"), bgcolor = t4Vol > 1.0 ? BLUE : NEUTRAL, text_color = color.white, text_size = tableSize)
    score4 = math.max(t4BS, t4RS)
    vTxt4 = t4BS >= 80 ? "STR BUY" : t4RS >= 80 ? "STR SELL" : t4BS >= 50 ? "BULL" : t4RS >= 50 ? "BEAR" : "NEUT"
    vCol4 = t4BS >= 80 ? BULL_STRONG : t4RS >= 80 ? BEAR_STRONG : t4BS >= 50 ? BULL_WEAK : t4RS >= 50 ? BEAR_WEAK : NEUTRAL
    table.cell(dash, 7, 4, vTxt4 + " (" + str.tostring(score4, "#") + "%)", bgcolor = vCol4, text_color = color.white, text_size = tableSize)

    // Global Sentiment Row
    gScore = math.max(avgBS, avgRS)
    gTxt = avgBS >= 70 ? "GLOBAL BUY" : avgRS >= 70 ? "GLOBAL SELL" : "WAITING"
    gCol = avgBS >= 70 ? BULL_STRONG : avgRS >= 70 ? BEAR_STRONG : NEUTRAL
    table.merge_cells(dash, 0, 5, 6, 5)
    table.cell(dash, 0, 5, "GLOBAL MARKET SENTIMENT", bgcolor = NEUTRAL, text_color = color.white, text_size = tableSize)
    table.cell(dash, 7, 5, gTxt + " (" + str.tostring(gScore, "#") + "%)", bgcolor = gCol, text_color = color.white, text_size = tableSize)
````
