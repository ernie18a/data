# MMM Dragon Flow 3.0

- url: https://www.tradingview.com/script/veGDtusI/
- type: indicator
- pine_id: PUB;6c87eb12e8c84f7a9ab096f118f7fe5f
- version: 1.0

## Description

MMXM Dragon Flow is a custom technical analysis indicator designed to help traders read market structure, trend direction, dynamic support/resistance, pivot zones, previous session levels, PVA volume behavior, and dashboard-based market conditions in one chart.

MMXM Dragon Flow เป็นอินดิเคเตอร์วิเคราะห์ทางเทคนิคที่ออกแบบมาเพื่อช่วยให้นักเทรดอ่านโครงสร้างราคา ทิศทางแนวโน้ม แนวรับ/แนวต้านแบบไดนามิก โซน Pivot ระดับราคาของรอบก่อนหน้า พฤติกรรม PVA Volume และสภาพตลาดผ่าน Dashboard ได้ในกราฟเดียว

Main Features / คุณสมบัติหลัก

1. Dragon Flow Trend Channel
The Dragon Flow channel is based on EMA structure and helps visualize the current market direction. It can be used to identify bullish, bearish, or sideways conditions.

Dragon Flow Trend Channel ใช้โครงสร้าง EMA เพื่อช่วยแสดงทิศทางตลาดปัจจุบัน ใช้ดูว่าราคาอยู่ในภาวะขาขึ้น ขาลง หรือ Sideway

2. Trend Line
The indicator includes a longer-term trend line to help compare current price movement against the broader market direction.

อินดิเคเตอร์มีเส้นแนวโน้มระยะยาวเพื่อช่วยเปรียบเทียบการเคลื่อนไหวของราคาปัจจุบันกับทิศทางตลาดโดยรวม

3. PVA Candles and Volume Flow
The script can color price candles and volume bars based on PVA behavior, helping traders identify normal volume, rising volume, and climax volume conditions.

สคริปต์สามารถเปลี่ยนสีแท่งราคาและแท่ง Volume ตามพฤติกรรม PVA เพื่อช่วยแยกภาวะ Volume ปกติ Volume เพิ่มขึ้น และ Climax Volume

4. Previous Session Levels
The indicator displays Previous High, Previous Low, and Previous Close levels. These levels can be used as important reference zones for possible liquidity reactions and price response.

อินดิเคเตอร์แสดงระดับ Previous High, Previous Low และ Previous Close เพื่อใช้เป็นโซนอ้างอิงสำคัญที่ราคาอาจเกิดการตอบสนองหรือเกิดปฏิกิริยาจากสภาพคล่อง

5. Expanded Pivot Support and Resistance
This version includes adjustable Pivot S/R distance. Traders can expand or reduce the distance between Pivot, R1, R2, R3, S1, S2, and S3 using the Pivot S/R Distance Multiplier.

เวอร์ชันนี้มีระบบปรับระยะห่างของ Pivot S/R ได้ นักเทรดสามารถขยายหรือลดระยะระหว่าง Pivot, R1, R2, R3, S1, S2 และ S3 ได้ผ่านค่า Pivot S/R Distance Multiplier

A multiplier of 1.00 keeps the original classic pivot levels. Values above 1.00 expand support and resistance farther away from the Pivot, which may be useful for volatile markets such as gold, indices, and crypto.

ค่า 1.00 คือระดับ Pivot ดั้งเดิมแบบ Classic Pivot หากใช้ค่ามากกว่า 1.00 แนวรับและแนวต้านจะถูกขยายออกจาก Pivot มากขึ้น เหมาะกับตลาดที่มีความผันผวนสูง เช่น ทองคำ ดัชนี และคริปโต

6. Staggered Level Labels
The script includes staggered labels to reduce label overlap when support and resistance levels are close together. This improves chart readability without changing the actual price levels.

สคริปต์มีระบบขยับตำแหน่งป้ายชื่อระดับราคาแบบ Staggered Labels เพื่อลดการซ้อนกันของป้ายเมื่อแนวรับและแนวต้านอยู่ใกล้กัน ช่วยให้กราฟอ่านง่ายขึ้นโดยไม่เปลี่ยนระดับราคาจริง

7. Gap Line
The indicator can display a session gap line based on the difference between the session open and the previous close.

อินดิเคเตอร์สามารถแสดงเส้น Gap โดยอ้างอิงจากความต่างระหว่างราคาเปิดของ Session และราคาปิดก่อนหน้า

8. Dashboard Panel
The dashboard summarizes key market information including price, trend, pivot, main plan, guardrail, nearest level, R/S levels, PVA status, range, and market notes.

Dashboard สรุปข้อมูลสำคัญ เช่น ราคาปัจจุบัน แนวโน้ม Pivot แผนหลัก จุดเฝ้าระวัง ระดับราคาที่ใกล้ที่สุด ค่า R/S สถานะ PVA Range และ Note ของตลาด

How to Use / วิธีใช้งาน

- Use the Dragon Flow channel to identify the current market direction.
- ใช้ Dragon Flow Channel เพื่อดูทิศทางตลาดปัจจุบัน

- Use the trend line to compare short-term movement with the broader trend.
- ใช้เส้น Trend เพื่อเปรียบเทียบการเคลื่อนไหวระยะสั้นกับแนวโน้มใหญ่

- Use Previous High, Previous Low, and Previous Close as important reaction zones.
- ใช้ Previous High, Previous Low และ Previous Close เป็นโซนสำคัญที่ราคาอาจเกิดการตอบสนอง

- Use Pivot, R1-R3, and S1-S3 as support and resistance reference zones.
- ใช้ Pivot, R1-R3 และ S1-S3 เป็นโซนอ้างอิงแนวรับและแนวต้าน

- Adjust Pivot S/R Distance Multiplier if the support and resistance levels are too close together.
- ปรับค่า Pivot S/R Distance Multiplier หากแนวรับและแนวต้านอยู่ใกล้กันเกินไป

- Use Stagger Level Labels to make level labels easier to read.
- ใช้ Stagger Level Labels เพื่อให้ป้ายชื่อระดับราคาอ่านง่ายขึ้น

- Use PVA volume behavior to identify rising activity or climax conditions.
- ใช้พฤติกรรม PVA Volume เพื่อดูภาวะ Volume เพิ่มขึ้นหรือ Climax Volume

- Use the dashboard as a quick market summary, not as a standalone buy or sell signal.
- ใช้ Dashboard เป็นตัวช่วยสรุปสภาพตลาดอย่างรวดเร็ว ไม่ใช่สัญญาณซื้อขายเดี่ยว ๆ

Recommended Markets / ตลาดที่เหมาะสม

This indicator can be used on forex, gold, indices, crypto, stocks, and other liquid markets. It is especially useful for intraday analysis, session-based trading, and multi-timeframe market structure reading.

อินดิเคเตอร์นี้สามารถใช้ได้กับ Forex, Gold, Indices, Crypto, Stocks และตลาดที่มีสภาพคล่อง เหมาะสำหรับการวิเคราะห์ Intraday การเทรดตาม Session และการอ่านโครงสร้างราคาหลาย Timeframe

Important Note / หมายเหตุสำคัญ

Expanded Pivot S/R levels are modified reference levels. If the multiplier is set above 1.00, the levels are no longer pure classic pivot levels. They become expanded support and resistance zones designed to improve spacing and readability in volatile markets.

ระดับ Expanded Pivot S/R เป็นระดับอ้างอิงที่ถูกปรับแต่ง หากตั้งค่า Multiplier มากกว่า 1.00 ระดับเหล่านี้จะไม่ใช่ Classic Pivot ดั้งเดิม 100% แต่จะเป็นโซนแนวรับและแนวต้านแบบขยาย เพื่อเพิ่มระยะห่างและทำให้อ่านกราฟง่ายขึ้นในตลาดที่ผันผวน

Disclaimer / ข้อจำกัดความรับผิดชอบ

This script is not financial advice, investment advice, or a solicitation to buy or sell any financial instrument. It is an algorithmic analysis and visualization tool only. Trading involves risk, and users are responsible for their own trading decisions.

สคริปต์นี้ไม่ใช่คำแนะนำทางการเงิน ไม่ใช่คำแนะนำการลงทุน และไม่ใช่การชักชวนให้ซื้อหรือขายสินทรัพย์ใด ๆ เป็นเพียงเครื่องมือช่วยวิเคราะห์และแสดงผลเชิงระบบเท่านั้น การเทรดมีความเสี่ยง ผู้ใช้งานต้องรับผิดชอบต่อการตัดสินใจของตนเอง

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ICT_Insight_Hub

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ICT_Insight_Hub

//@version=6
indicator("MMM Dragon Flow 3.0", shorttitle="MMM Dragon Flow 3.0", overlay=false, max_lines_count=500, max_labels_count=500)

// ============================================================================
// MMXM DragonFlow PVA [TV] v1.8
// Source-only Pine adaptation from the supplied MT4 files:
// - Sonic_1 Solid Dragon (White).mq4
// - Sonic_2 PVA Candles (White).mq4
// - Sonic_3 Trade Levels (White).mq4
// - Sonic_4 Access Panel (White).mq4
// - Sonic_5 FFCal Panel (White).mq4
// - Sonic_6 PVA Volumes (White).mq4
//
// Pine limitation notes:
// 1) Pine cannot read MT4/TradingView account orders like OrdersTotal(), OrderSelect(), TP/SL.
//    Trade Levels are therefore manual-input substitutes only.
// 2) Pine cannot import DLLs or read ForexFactory XML files like the MT4 FFCal panel.
// 3) Manual education annotations in the reference screenshots are not generated because
//    those strings are not present in the supplied .mq4 source files.
// ============================================================================

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
grpMain = "0) Master"
indicatorOn = input.bool(true, "Indicator On", group=grpMain)
maxTfMinutes = input.int(43200, "Display Max TF Minutes", minval=1, group=grpMain)

// Sonic_1 Solid Dragon source defaults.
grpAppearance = "0.1) Appearance"
themeMode = input.string("Dark", "Theme", options=["Dark", "Light"], group=grpAppearance)

grpDragon = "1) Sonic_1 Solid Dragon"
showDragon = input.bool(true, "Show Dragon", group=grpDragon)
showTrend  = input.bool(true, "Show Trend", group=grpDragon)
dragonPeriod = input.int(34, "Dragon Period", minval=1, group=grpDragon)
trendPeriod  = input.int(89, "Trend Period", minval=1, group=grpDragon)
dragonLineWidth = input.int(2, "Dragon Line Width", minval=1, maxval=5, group=grpDragon)
dragonCenterWidth = input.int(1, "Dragon Center Width", minval=1, maxval=5, group=grpDragon)
dragonFillTransparency = input.int(84, "Dragon Fill Transparency", minval=0, maxval=100, group=grpDragon)
dragonLineTransparency = input.int(35, "Dragon Line Transparency", minval=0, maxval=100, group=grpDragon)
showDragonSoftCenter = input.bool(false, "Show Dragon Soft Center", group=grpDragon)
dragonSoftCenterTransparency = input.int(92, "Soft Center Transparency", minval=0, maxval=100, group=grpDragon)

// Sonic_2 / Sonic_6 PVA source defaults.
grpPVA = "2) Sonic_2 / Sonic_6 PVA"
showPvaCandles = input.bool(true, "Color price candles by PVA", group=grpPVA)
showPvaVolumes = input.bool(true, "Show PVA volumes", group=grpPVA)
showVolumeAvg  = input.bool(false, "Show 10-bar previous volume average", group=grpPVA)
volAlertOn     = input.bool(false, "Climax Volume Alert", group=grpPVA)

// Sonic_3 Trade Levels source reads live MT4 orders.
// Removed from this TradingView version per user request: no Entry / SL / TP objects.

// Sonic_4 Access Panel levels/pivots/ranges/session lines.
grpLevels = "4) Sonic_4 Access Panel - Levels"
levelsOn = input.bool(false, "Levels On", group=grpLevels)
showHalfLines = input.bool(false, "Show Half Lines", group=grpLevels)
showQuarterLines = input.bool(false, "Show Quarter Lines", group=grpLevels)
levelsWholeMaxTF = input.int(10080, "Whole Max TF", group=grpLevels)
levelsHalfMaxTF = input.int(1440, "Half Max TF", group=grpLevels)
levelsQuarterMaxTF = input.int(240, "Quarter Max TF", group=grpLevels)
maxLevelLines = input.int(220, "Max level lines Pine can draw", minval=20, maxval=430, group=grpLevels)

grpPivots = "5) Sonic_4 Access Panel - Pivots"
pivotsPVTOn = input.bool(false, "Pivots PVT On", group=grpPivots)
pivotsSROn = input.bool(false, "Pivots S/R On", group=grpPivots)
showMidPivots = input.bool(false, "Show MidPivots", group=grpPivots)
showLevelsThrough = input.int(5, "Show Pivot Levels Through 2/3/4/5", minval=2, maxval=5, group=grpPivots)
pivotsFibonacci = input.bool(false, "Fibonacci Pivots", group=grpPivots)
pvtMaxTF = input.int(60, "PVT Max TF", group=grpPivots)
srMaxTF = input.int(60, "S/R Max TF", group=grpPivots)
labelPivotTZMark = input.string("^", "Pivot Label Suffix", options=["", "^", "<", ">"], group=grpPivots)

grpCama = "5.1) Daily Camarilla Pivot Points"
showCamarilla = input.bool(false, "Show Camarilla Center Pivot", group=grpCama)
camaMaxTF = input.int(240, "Camarilla Max TF", minval=1, group=grpCama)
showCamaLabels = input.bool(true, "Show Camarilla Pivot Label", group=grpCama)

// Adjustable Camarilla center pivot appearance on the upper price chart.
camaPivotInputColor = input.color(color.rgb(245, 210, 85), "Pivot Line Color", group=grpCama)
camaPivotInputWidth = input.int(1, "Pivot Line Size", minval=1, maxval=5, group=grpCama)

grpRanges = "6) Sonic_4 Access Panel - ADR / AWR"
rangeDayOn = input.bool(false, "Range Day On", group=grpRanges)
dayMinTF = input.int(1, "Day Min TF", group=grpRanges)
dayMaxTF = input.int(240, "Day Max TF", group=grpRanges)
rangeWeekOn = input.bool(false, "Range Week On", group=grpRanges)
weekMinTF = input.int(15, "Week Min TF", group=grpRanges)
weekMaxTF = input.int(240, "Week Max TF", group=grpRanges)
daysInRangeAvg = input.int(15, "Days in Range Day Avg", minval=1, group=grpRanges)
weeksInWeekATR = input.int(13, "Weeks in Week ATR", minval=1, group=grpRanges)

grpSessions = "7) Sonic_4 Access Panel - vLines"
vLinesOn = input.bool(false, "vLines On", group=grpSessions)
sessionTZ = input.string("Etc/UTC", "Session Time Zone", group=grpSessions)
showAo = input.bool(false, "Show Ao", group=grpSessions)
showFo = input.bool(false, "Show Fo", group=grpSessions)
showLo = input.bool(true, "Show Lo", group=grpSessions)
showNy = input.bool(true, "Show Ny", group=grpSessions)
showLc = input.bool(true, "Show Lc", group=grpSessions)
sessAo = input.session("2100-2101", "Ao Window", group=grpSessions)
sessFo = input.session("0700-0701", "Fo Window", group=grpSessions)
sessLo = input.session("0800-0801", "Lo Window", group=grpSessions)
sessNy = input.session("1300-1301", "Ny Window", group=grpSessions)
sessLc = input.session("1600-1601", "Lc Window", group=grpSessions)

// Optional status panel based on visible, Pine-supported values only.
grpPanel = "8) Source-Faithful Status Panel"
showPanel = input.bool(true, "Show top-right dashboard", group=grpPanel)
dashboardLanguage = input.string("English", "Dashboard Language", options=["English"], group=grpPanel)

// -----------------------------------------------------------------------------
// Theme / colors
// -----------------------------------------------------------------------------
isDarkTheme = themeMode == "Dark"

dragonHLHisto = isDarkTheme ? color.rgb(225, 238, 255) : color.rgb(221, 238, 255)
dragonHLMA = isDarkTheme ? color.rgb(215, 235, 255) : color.rgb(210, 233, 255)
dragonCenterArea = isDarkTheme ? color.rgb(245, 250, 255) : color.rgb(240, 249, 255)
dragonCenterLine = color.rgb(32, 143, 255)
trendColor = isDarkTheme ? color.rgb(95, 105, 125) : color.black

wickColor = isDarkTheme ? color.rgb(185, 185, 210) : color.rgb(15, 15, 68)
pvaStdBull = color.rgb(163, 163, 163)
pvaStdBear = color.rgb(100, 100, 100)
pvaRisingBull = color.rgb(45, 81, 206)
pvaRisingBear = color.rgb(154, 38, 232)
pvaClimaxBull = color.rgb(0, 166, 100)
pvaClimaxBear = color.rgb(214, 12, 83)

levelWholeColor = isDarkTheme ? color.rgb(82, 90, 124) : color.rgb(235, 235, 252)
levelHalfColor = isDarkTheme ? color.rgb(70, 110, 70) : color.rgb(199, 250, 199)
levelQuarterColor = isDarkTheme ? color.rgb(106, 100, 86) : color.rgb(239, 235, 222)
pvtBackColor = isDarkTheme ? color.rgb(143, 130, 40) : color.rgb(255, 255, 155)
pvtTopColor = isDarkTheme ? color.rgb(170, 170, 170) : color.rgb(169, 169, 169)
rPivotColor = color.rgb(255, 53, 17)
sPivotColor = isDarkTheme ? color.rgb(116, 151, 255) : color.rgb(64, 64, 255)
midPivotColor = isDarkTheme ? color.rgb(165, 165, 75) : color.olive
rdhColor = color.rgb(255, 90, 62)
rdlColor = isDarkTheme ? color.rgb(116, 151, 255) : color.rgb(106, 106, 255)
rwhColor = color.rgb(255, 90, 62)
rwlColor = isDarkTheme ? color.rgb(116, 151, 255) : color.rgb(106, 106, 255)
camaRColor = color.rgb(255, 53, 17)
camaSColor = color.rgb(64, 200, 64)
camaPivotColor = isDarkTheme ? color.rgb(245, 210, 85) : color.rgb(160, 130, 0)
labelsColor = isDarkTheme ? color.rgb(185, 195, 255) : color.rgb(25, 25, 112)
vLineColor = isDarkTheme ? color.rgb(120, 120, 120) : color.silver
panelBg = isDarkTheme ? color.rgb(36, 38, 46) : color.rgb(238, 238, 242)
panelHeaderBg = isDarkTheme ? color.rgb(50, 54, 66) : color.rgb(238, 238, 242)
panelText = isDarkTheme ? color.rgb(225, 225, 225) : color.black
panelSubText = isDarkTheme ? color.rgb(175, 175, 175) : color.rgb(80, 80, 80)

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
f_tf_minutes() =>
    int out = 0
    if timeframe.isseconds
        out := 1
    else if timeframe.isintraday
        out := timeframe.multiplier
    else if timeframe.isdaily
        out := 1440 * timeframe.multiplier
    else if timeframe.isweekly
        out := 10080 * timeframe.multiplier
    else if timeframe.ismonthly
        out := 43200 * timeframe.multiplier
    else
        out := timeframe.multiplier
    out

f_tf_label() =>
    int tf = f_tf_minutes()
    tf == 1 ? "M1" : tf == 5 ? "M5" : tf == 15 ? "M15" : tf == 30 ? "M30" : tf == 60 ? "H1" : tf == 240 ? "H4" : tf == 1440 ? "Day" : tf == 10080 ? "Week" : tf == 43200 ? "Month" : timeframe.period

f_poin() =>
    float p = syminfo.mintick
    float out = p == 0.00001 ? 0.0001 : p == 0.001 ? 0.01 : p
    string s = syminfo.ticker
    if str.contains(s, "XAUUSD") or str.contains(s, "XAU")
        out := 0.1
    else if str.contains(s, "EURTRY") or str.contains(s, "USDTRY") or str.contains(s, "USDMXN") or str.contains(s, "USDCZK")
        out := 0.001
    out

f_number_ranges(int tf) =>
    tf == 1 ? 4 : tf == 5 ? 7 : tf == 15 ? 15 : tf == 30 ? 15 : tf == 60 ? 20 : tf == 240 ? 30 : tf == 1440 ? 60 : tf == 10080 ? 70 : tf == 43200 ? 60 : 15

f_session_start(string sess, string tz) =>
    bool inSess = not na(time(timeframe.period, sess, tz))
    inSess and not inSess[1]

f_round_tick(float x) =>
    math.round(x / syminfo.mintick) * syminfo.mintick

f_fmt(float x) =>
    str.tostring(x, format.mintick)

// -----------------------------------------------------------------------------
// Master visibility
// -----------------------------------------------------------------------------
tfMin = f_tf_minutes()
visible = indicatorOn and tfMin <= maxTfMinutes

// -----------------------------------------------------------------------------
// Sonic_1 Solid Dragon
// Source: Dragon = 34 EMA high/low/close, Trend = 89 EMA close.
// -----------------------------------------------------------------------------
dragonHigh = ta.ema(high, dragonPeriod)
dragonLow = ta.ema(low, dragonPeriod)
dragonClose = ta.ema(close, dragonPeriod)
trend = ta.ema(close, trendPeriod)

pDh = plot(visible and showDragon ? dragonHigh : na, "Dragon High / Top", color=color.new(dragonHLMA, dragonLineTransparency), linewidth=dragonLineWidth, force_overlay=true)
pDl = plot(visible and showDragon ? dragonLow : na, "Dragon Low / Bottom", color=color.new(dragonHLMA, dragonLineTransparency), linewidth=dragonLineWidth, force_overlay=true)
pDcArea = plot(visible and showDragon and showDragonSoftCenter ? dragonClose : na, "Dragon Center Area", color=color.new(dragonCenterArea, dragonSoftCenterTransparency), linewidth=2, force_overlay=true)
pDcLine = plot(visible and showDragon ? dragonClose : na, "Dragon Center Line", color=color.new(dragonCenterLine, dragonLineTransparency), linewidth=dragonCenterWidth, force_overlay=true)
fill(pDh, pDl, color=visible and showDragon ? color.new(dragonHLHisto, dragonFillTransparency) : na, title="Dragon H/L Solid Fill")
plot(visible and showTrend ? trend : na, "SonicR Trend", color=trendColor, linewidth=1, force_overlay=true)

// -----------------------------------------------------------------------------
// Sonic_2 PVA Candles + Sonic_6 PVA Volumes
// Source exact rules:
// Climax: volume >= 200% of previous 10-bar avg OR spread*volume >= highest previous 10.
// Rising: volume >= 150% of previous 10-bar avg.
// -----------------------------------------------------------------------------
volAvg10Prev = ta.sma(volume[1], 10)
value2 = volume * (high - low)
hiValue2Prev = ta.highest(volume[1] * (high[1] - low[1]), 10)
pvaReady = not na(volAvg10Prev) and not na(hiValue2Prev)

vaRising = pvaReady and volume >= volAvg10Prev * 1.5
vaClimax = pvaReady and (value2 >= hiValue2Prev or volume >= volAvg10Prev * 2.0)

isBull = close >= open
pvaColor = vaClimax ? (isBull ? pvaClimaxBull : pvaClimaxBear) : vaRising ? (isBull ? pvaRisingBull : pvaRisingBear) : (isBull ? pvaStdBull : pvaStdBear)

barcolor(visible and showPvaCandles ? pvaColor : na)
plot(visible and showPvaVolumes ? volume : na, "SonicR PVA Volumes", color=pvaColor, style=plot.style_columns)
plot(visible and showPvaVolumes and showVolumeAvg ? volAvg10Prev : na, "Previous 10-Bar Volume Average", color=color.gray, linewidth=1)

// -----------------------------------------------------------------------------
// Drawing object pools
// -----------------------------------------------------------------------------
var line[] levelLines = array.new_line()
var line[] namedLines = array.new_line()
var label[] namedLabels = array.new_label()

if barstate.isfirst
    for i = 0 to maxLevelLines - 1
        array.push(levelLines, line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.white, 100), width=1, force_overlay=true))
    for i = 0 to 40
        array.push(namedLines, line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.white, 100), width=1, force_overlay=true))
        array.push(namedLabels, label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=color.new(color.white, 100), size=size.tiny, force_overlay=true))

f_style(int styleNum) =>
    styleNum == 2 ? line.style_dotted : styleNum == 3 ? line.style_dashed : line.style_solid

f_set_named(int idx, bool show, string txt, float y, color col, int width, int styleNum, int x1, int x2, bool showLbl) =>
    line ln = array.get(namedLines, idx)
    label lb = array.get(namedLabels, idx)
    if show and not na(y)
        line.set_xy1(ln, x1, y)
        line.set_xy2(ln, x2, y)
        line.set_color(ln, col)
        line.set_width(ln, width)
        line.set_style(ln, f_style(styleNum))
        label.set_x(lb, x2)
        label.set_y(lb, y)
        label.set_text(lb, showLbl ? txt : "")
        label.set_textcolor(lb, labelsColor)
        label.set_color(lb, color.new(color.white, 100))
        label.set_style(lb, label.style_none)
    else
        line.set_color(ln, color.new(color.white, 100))
        label.set_text(lb, "")
        label.set_textcolor(lb, color.new(color.white, 100))

// Dedicated Camarilla objects. These are separate from the source-level pool so they
// always render on the upper price chart through force_overlay=true.
var line[] camaLines = array.new_line()
var label[] camaLabels = array.new_label()

if barstate.isfirst
    for i = 0 to 6
        array.push(camaLines, line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.both, color=color.new(color.white, 100), width=1, style=line.style_dotted, force_overlay=true))
        array.push(camaLabels, label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(color.white, 100), textcolor=color.new(color.white, 100), size=size.tiny, force_overlay=true))

f_set_cama(int idx, bool show, string txt, float y, color col, int width, lstyle, int xLabel, bool showLbl) =>
    line ln = array.get(camaLines, idx)
    label lb = array.get(camaLabels, idx)
    if show and not na(y)
        line.set_xy1(ln, bar_index - 2500, y)
        line.set_xy2(ln, bar_index + 2500, y)
        line.set_extend(ln, extend.both)
        line.set_color(ln, col)
        line.set_width(ln, width)
        line.set_style(ln, lstyle)
        label.set_x(lb, xLabel)
        label.set_y(lb, y)
        label.set_text(lb, showLbl ? txt : "")
        label.set_textcolor(lb, col)
        label.set_color(lb, color.new(color.white, 100))
        label.set_style(lb, label.style_none)
    else
        line.set_color(ln, color.new(color.white, 100))
        label.set_text(lb, "")
        label.set_textcolor(lb, color.new(color.white, 100))

// -----------------------------------------------------------------------------
// Sonic_4 Levels removed
// Whole / half / quarter price levels are permanently disabled in v1.8 to keep the chart clean.
// -----------------------------------------------------------------------------
if barstate.islast
    for i = 0 to array.size(levelLines) - 1
        line ln = array.get(levelLines, i)
        line.set_color(ln, color.new(color.white, 100))

    if false
        float poin = f_poin()
        int nr = f_number_ranges(tfMin)
        int ssp1 = int(math.floor(close / poin))
        int bl = ssp1 % 100
        int count = 0
        int jStart = -bl - (100 * nr)
        int jStop = (100 - bl) + (100 * nr)
        for j = jStart to jStop
            int ssp = ssp1 + j
            int v1 = ((ssp % 100) + 100) % 100
            bool isWhole = v1 == 0
            bool isHalf = showHalfLines and tfMin <= levelsHalfMaxTF and v1 == 50
            bool isQuarter = showQuarterLines and tfMin <= levelsQuarterMaxTF and (v1 == 25 or v1 == 75)
            if (isWhole or isHalf or isQuarter) and count < maxLevelLines
                float lvl = f_round_tick(ssp * poin)
                color c = isWhole ? levelWholeColor : isHalf ? levelHalfColor : levelQuarterColor
                int w = isWhole ? 3 : 1
                line ln = array.get(levelLines, count)
                line.set_xy1(ln, bar_index - 500, lvl)
                line.set_xy2(ln, bar_index + 120, lvl)
                line.set_color(ln, c)
                line.set_width(ln, w)
                line.set_style(ln, line.style_solid)
                count += 1

// -----------------------------------------------------------------------------
// Sonic_4 Daily Pivots and Mid-Pivots
// Source formulas copied from Sonic_4 Access Panel.
// -----------------------------------------------------------------------------
yHigh = request.security(syminfo.tickerid, "D", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
yLow = request.security(syminfo.tickerid, "D", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
yClose = request.security(syminfo.tickerid, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
q = yHigh - yLow
p = (yHigh + yLow + yClose) / 3.0

r1 = pivotsFibonacci ? p + q * 0.382 : (2.0 * p) - yLow
r2 = pivotsFibonacci ? p + q * 0.618 : p + (yHigh - yLow)
r3 = pivotsFibonacci ? p + q : (2.0 * p) + (yHigh - (2.0 * yLow))
r4 = pivotsFibonacci ? p + q * 1.618 : (3.0 * p) + (yHigh - (3.0 * yLow))
r5 = pivotsFibonacci ? p + q * 2.618 : (4.0 * p) + (yHigh - (4.0 * yLow))
s1 = pivotsFibonacci ? p - q * 0.382 : (2.0 * p) - yHigh
s2 = pivotsFibonacci ? p - q * 0.618 : p - (yHigh - yLow)
s3 = pivotsFibonacci ? p - q : (2.0 * p) - ((2.0 * yHigh) - yLow)
s4 = pivotsFibonacci ? p - q * 1.618 : (3.0 * p) - ((3.0 * yHigh) - yLow)
s5 = pivotsFibonacci ? p - q * 2.618 : (4.0 * p) - ((4.0 * yHigh) - yLow)

prefix = pivotsFibonacci ? "F" : "D"

// Daily Camarilla Pivot Points
camRange = yHigh - yLow
camPP = (yHigh + yLow + yClose) / 3.0
camR1 = yClose + (camRange * 1.1 / 12.0)
camR2 = yClose + (camRange * 1.1 / 6.0)
camR3 = yClose + (camRange * 1.1 / 4.0)
camS1 = yClose - (camRange * 1.1 / 12.0)
camS2 = yClose - (camRange * 1.1 / 6.0)
camS3 = yClose - (camRange * 1.1 / 4.0)

// Camarilla plots on the upper price chart.
// plot.style_circles is used to create a visible dotted-line effect on TradingView.
showCamaPlot = false  // removed per v1.7: no Camarilla/Pivot line on chart
plot(showCamaPlot ? camPP : na, "Camarilla Pivot", color=camaPivotInputColor, linewidth=camaPivotInputWidth, style=plot.style_linebr, force_overlay=true)

// -----------------------------------------------------------------------------
// Sonic_4 Day/Week Range levels
// Day range average uses previous daily ranges, excluding Sundays is not exactly
// available from all TradingView feeds; this uses previous daily bars supplied by TV.
// -----------------------------------------------------------------------------
dRange = request.security(syminfo.tickerid, "D", ta.sma(high[1] - low[1], daysInRangeAvg), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
wRange = request.security(syminfo.tickerid, "W", ta.atr(weeksInWeekATR), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

curDayHighTV = request.security(syminfo.tickerid, "D", high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
curDayLowTV = request.security(syminfo.tickerid, "D", low, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
prevDayClose = yClose
hiToday = math.max(curDayHighTV, prevDayClose)
loToday = math.min(curDayLowTV, prevDayClose)

dRangeHigh = hiToday - loToday <= dRange ? loToday + dRange : hiToday
dRangeLow = hiToday - loToday <= dRange ? hiToday - dRange : loToday

curWeekHighTV = request.security(syminfo.tickerid, "W", high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
curWeekLowTV = request.security(syminfo.tickerid, "W", low, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
prevWeekClose = request.security(syminfo.tickerid, "W", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
hiWeek = math.max(curWeekHighTV, prevWeekClose)
loWeek = math.min(curWeekLowTV, prevWeekClose)
wRangeHigh = hiWeek - loWeek <= wRange ? loWeek + wRange : hiWeek
wRangeLow = hiWeek - loWeek <= wRange ? hiWeek - wRange : loWeek

// Update named levels.
if barstate.islast
    int x1 = bar_index - 500
    int x2 = bar_index + 80
    string tzMark = labelPivotTZMark
    bool showPvt = false  // removed per v1.7: no Pivot Point line
    bool showSr = false
    bool showMid = false
    bool showCama = false  // removed per v1.7: no Camarilla center line
    bool showDayRange = false
    bool showWeekRange = false

    f_set_named(0, showPvt, "PVT" + tzMark, p, pvtBackColor, 3, 0, x1, x2, true)
    f_set_named(1, showPvt, "PVT" + tzMark, p, pvtTopColor, 1, 0, x1, x2, false)

    f_set_named(2, showSr, prefix + "R1" + tzMark, r1, rPivotColor, 1, 2, x1, x2, true)
    f_set_named(3, showSr, prefix + "R2" + tzMark, r2, rPivotColor, 1, 2, x1, x2, true)
    f_set_named(4, showSr, prefix + "S1" + tzMark, s1, sPivotColor, 1, 2, x1, x2, true)
    f_set_named(5, showSr, prefix + "S2" + tzMark, s2, sPivotColor, 1, 2, x1, x2, true)
    f_set_named(6, showSr and showLevelsThrough >= 3, prefix + "R3" + tzMark, r3, rPivotColor, 1, 2, x1, x2, true)
    f_set_named(7, showSr and showLevelsThrough >= 3, prefix + "S3" + tzMark, s3, sPivotColor, 1, 2, x1, x2, true)
    f_set_named(8, showSr and showLevelsThrough >= 4, prefix + "R4" + tzMark, r4, rPivotColor, 1, 2, x1, x2, true)
    f_set_named(9, showSr and showLevelsThrough >= 4, prefix + "S4" + tzMark, s4, sPivotColor, 1, 2, x1, x2, true)
    f_set_named(10, showSr and showLevelsThrough == 5, prefix + "R5" + tzMark, r5, rPivotColor, 1, 2, x1, x2, true)
    f_set_named(11, showSr and showLevelsThrough == 5, prefix + "S5" + tzMark, s5, sPivotColor, 1, 2, x1, x2, true)

    f_set_named(12, showMid, "MR1" + tzMark, (p + r1) / 2.0, midPivotColor, 1, 2, x1, x2, true)
    f_set_named(13, showMid, "MR2" + tzMark, (r1 + r2) / 2.0, midPivotColor, 1, 2, x1, x2, true)
    f_set_named(14, showMid, "MS1" + tzMark, (p + s1) / 2.0, midPivotColor, 1, 2, x1, x2, true)
    f_set_named(15, showMid, "MS2" + tzMark, (s1 + s2) / 2.0, midPivotColor, 1, 2, x1, x2, true)
    f_set_named(16, showMid and showLevelsThrough >= 3, "MR3" + tzMark, (r2 + r3) / 2.0, midPivotColor, 1, 2, x1, x2, true)
    f_set_named(17, showMid and showLevelsThrough >= 3, "MS3" + tzMark, (s2 + s3) / 2.0, midPivotColor, 1, 2, x1, x2, true)
    f_set_named(18, showMid and showLevelsThrough >= 4, "MR4" + tzMark, (r3 + r4) / 2.0, midPivotColor, 1, 2, x1, x2, true)
    f_set_named(19, showMid and showLevelsThrough >= 4, "MS4" + tzMark, (s3 + s4) / 2.0, midPivotColor, 1, 2, x1, x2, true)
    f_set_named(20, showMid and showLevelsThrough == 5, "MR5" + tzMark, (r4 + r5) / 2.0, midPivotColor, 1, 2, x1, x2, true)
    f_set_named(21, showMid and showLevelsThrough == 5, "MS5" + tzMark, (s4 + s5) / 2.0, midPivotColor, 1, 2, x1, x2, true)

    f_set_named(22, showDayRange, "RDH", dRangeHigh, rdhColor, 1, 0, x1, x2, true)
    f_set_named(23, showDayRange, "RDL", dRangeLow, rdlColor, 1, 0, x1, x2, true)
    f_set_named(24, showWeekRange, "RWH", wRangeHigh, rwhColor, 2, 0, x1, x2, true)
    f_set_named(25, showWeekRange, "RWL", wRangeLow, rwlColor, 2, 0, x1, x2, true)

    // Camarilla support/resistance levels removed. Keep center pivot only.
    f_set_cama(0, showCama, "Pivot", camPP, camaPivotInputColor, camaPivotInputWidth, line.style_solid, bar_index + 20, showCamaLabels)
    f_set_cama(1, false, "", camR1, camaPivotInputColor, 1, line.style_dotted, bar_index + 20, false)
    f_set_cama(2, false, "", camR2, camaPivotInputColor, 1, line.style_dotted, bar_index + 20, false)
    f_set_cama(3, false, "", camR3, camaPivotInputColor, 1, line.style_dotted, bar_index + 20, false)
    f_set_cama(4, false, "", camS1, camaPivotInputColor, 1, line.style_dotted, bar_index + 20, false)
    f_set_cama(5, false, "", camS2, camaPivotInputColor, 1, line.style_dotted, bar_index + 20, false)
    f_set_cama(6, false, "", camS3, camaPivotInputColor, 1, line.style_dotted, bar_index + 20, false)


// -----------------------------------------------------------------------------
// Sonic_4 vLines and labels: current session markers only.
// -----------------------------------------------------------------------------
f_draw_vline(bool cond, string txt) =>
    if cond
        line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=vLineColor, style=line.style_dotted, width=1, force_overlay=true)
        label.new(bar_index, high, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=labelsColor, size=size.tiny, force_overlay=true)

if false
    f_draw_vline(showAo and f_session_start(sessAo, sessionTZ), "Ao")
    f_draw_vline(showFo and f_session_start(sessFo, sessionTZ), "Fo")
    f_draw_vline(showLo and f_session_start(sessLo, sessionTZ), "Lo")
    f_draw_vline(showNy and f_session_start(sessNy, sessionTZ), "Ny")
    f_draw_vline(showLc and f_session_start(sessLc, sessionTZ), "Lc")

// -----------------------------------------------------------------------------
// Status panel moved below Daily Key Level module so it can read Pivot/R/S values.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Alerts from supplied PVA volume source behavior.
// -----------------------------------------------------------------------------
alertcondition(visible and volAlertOn and vaClimax, title="SonicR PVA Climax", message="SonicR PVA Climax volume on {{ticker}} {{interval}}")

// ============================================================================
// Daily Key Level module merged into Dragon Flow
// Notes:
// - Original script used overlay=true. This merged indicator keeps Dragon/PVA in
//   its own pane and forces Daily Key Level drawings onto the price chart.
// ============================================================================

// === Daily Key Level: User Inputs ===
showHigh   = input.bool(true,  "Show Previous High",  tooltip="Toggle previous session's high line.")
showLow    = input.bool(true,  "Show Previous Low",   tooltip="Toggle previous session's low line.")
showClose  = input.bool(true,  "Show Previous Close", tooltip="Toggle previous session's close line.")
showPivot  = input.bool(true,  "Show Pivot",          tooltip="Toggle pivot line (H+L+C)/3.")
showR1     = input.bool(true,  "Show R1",             tooltip="Toggle R1 resistance line.")
showR2     = input.bool(true,  "Show R2",             tooltip="Toggle R2 resistance line.")
showR3     = input.bool(true,  "Show R3",             tooltip="Toggle R3 resistance line.")
showS1     = input.bool(true,  "Show S1",             tooltip="Toggle S1 support line.")
showS2     = input.bool(true,  "Show S2",             tooltip="Toggle S2 support line.")
showS3     = input.bool(true,  "Show S3",             tooltip="Toggle S3 support line.")
showGap    = input.bool(true,  "Show Gap",            tooltip="Toggle gap line (Open - Prev Close).")

extend_right  = input.bool(true, "Extend Lines Right")
right_offset  = input.int(200, "Line Length (bars ahead)", minval=50, maxval=2000)

// Expands Daily Key Level S/R away from Pivot. 1.00 = original/classic pivot levels.
srDistanceMultiplier = input.float(1.50, "Pivot S/R Distance Multiplier", minval=0.50, maxval=5.00, step=0.05, tooltip="Expands R1/R2/R3 and S1/S2/S3 away from Pivot. 1.00 = original levels.")

// Visual-only label spacing. This does not change the actual price levels.
staggerLevelLabels = input.bool(true, "Stagger Level Labels", tooltip="Moves labels horizontally so close levels do not overlap. Price levels are unchanged.")
labelStepBars = input.int(8, "Label Stagger Step (bars)", minval=0, maxval=50)

// === Daily Key Level: Colors ===
pivotColor    = color.new(color.orange, 0)
closeColor    = color.new(color.yellow, 0)
highColor     = color.new(color.green,  0)
resColor      = color.new(color.teal,   0)
lowColor      = color.new(color.red,    0)
supColor      = color.new(color.maroon, 0)

// === Daily Key Level: Session & Time Logic ===
tz         = "America/New_York"
sess_open  = timestamp(tz, year(time), month(time), dayofmonth(time), 09, 30)
sess_close = timestamp(tz, year(time), month(time), dayofmonth(time), 16, 00)
in_session = time >= sess_open and time < sess_close

var float sessionHigh  = na
var float sessionLow   = na
var float sessionClose = na

if in_session
    sessionHigh  := na(sessionHigh) ? high : math.max(sessionHigh, high)
    sessionLow   := na(sessionLow)  ? low  : math.min(sessionLow, low)
    sessionClose := close

var float lastHigh  = na
var float lastLow   = na
var float lastClose = na
if not in_session and in_session[1]
    lastHigh  := sessionHigh
    lastLow   := sessionLow
    lastClose := sessionClose
    sessionHigh  := na
    sessionLow   := na
    sessionClose := na

// --- Plot trigger logic ---
current_hour_et   = hour(time, tz)
current_minute_et = minute(time, tz)
now_minutes       = current_hour_et * 60 + current_minute_et
market_open_et    = 9 * 60 + 30
market_close_et   = 16 * 60
after4pm   = now_minutes >= market_close_et
before930  = now_minutes < market_open_et

float refHigh  = na
float refLow   = na
float refClose = na
if not na(lastHigh) and (after4pm or before930)
    refHigh  := lastHigh
    refLow   := lastLow
    refClose := lastClose

canPlot = not na(refHigh) and not na(refLow) and not na(refClose)
plotTriggerBar = ta.valuewhen(canPlot, bar_index, 0)

// --- Calculate pivots ---
P  = (refHigh + refLow + refClose) / 3

// Classic pivot values before optional expansion.
rawR1 = 2 * P - refLow
rawS1 = 2 * P - refHigh
rawR2 = P + (refHigh - refLow)
rawS2 = P - (refHigh - refLow)
rawR3 = rawR1 + (refHigh - refLow)
rawS3 = rawS1 - (refHigh - refLow)

// Expanded S/R values. Multiplier = 1.00 keeps the original values.
R1 = P + (rawR1 - P) * srDistanceMultiplier
S1 = P + (rawS1 - P) * srDistanceMultiplier
R2 = P + (rawR2 - P) * srDistanceMultiplier
S2 = P + (rawS2 - P) * srDistanceMultiplier
R3 = P + (rawR3 - P) * srDistanceMultiplier
S3 = P + (rawS3 - P) * srDistanceMultiplier

// --- Robust Gap Detection (for both live and backtest) ---
sessionOpen_robust = request.security(syminfo.tickerid, "5", open, lookahead=barmerge.lookahead_on)
sessionTime_robust = request.security(syminfo.tickerid, "5", time, lookahead=barmerge.lookahead_on)
isSession930_robust = na(sessionTime_robust) ? false : (hour(sessionTime_robust, tz) == 9 and minute(sessionTime_robust, tz) == 30)
var float dailySessionOpen = na
var int   dailySessionOpenBar = na
if isSession930_robust
    dailySessionOpen    := sessionOpen_robust
    dailySessionOpenBar := bar_index
if not isSession930_robust
    dailySessionOpen    := dailySessionOpen
    dailySessionOpenBar := dailySessionOpenBar

float gap = na
if not na(lastClose) and not na(dailySessionOpen)
    gap := dailySessionOpen - lastClose

gapColor = gap > 0 ? color.new(color.green, 0) : gap < 0 ? color.new(color.red, 0) : color.gray
var line  gapLine  = na
var label gapLabel = na

end_x = bar_index + right_offset  // End point for all rays

// --- Plot Gap Line and Label ---
if showGap and not na(gap)
    // Draw a horizontal ray from 9:30 open
    if na(gapLine)
        gapLine := line.new(x1=bar_index, y1=dailySessionOpen, x2=end_x, y2=dailySessionOpen, color=gapColor, width=2, extend=extend.right, style=line.style_solid, force_overlay=true)
    else
        line.set_xy1(gapLine, bar_index, dailySessionOpen)
        line.set_xy2(gapLine, end_x, dailySessionOpen)
        line.set_color(gapLine, gapColor)
    // Place Gap label in the middle of the ray
    gap_mid_x = math.round((bar_index + end_x) / 2)
    gap_label_style = label.style_label_center
    if na(gapLabel)
        gapLabel := label.new(gap_mid_x, dailySessionOpen, "Gap: " + str.tostring(gap, format.mintick), color=gapColor, style=gap_label_style, textcolor=color.white, size=size.small, xloc=xloc.bar_index, force_overlay=true)
    else
        label.set_xy(gapLabel, gap_mid_x, dailySessionOpen)
        label.set_text(gapLabel, "Gap: " + str.tostring(gap, format.mintick))
        label.set_color(gapLabel, gapColor)
        label.set_style(gapLabel, gap_label_style)
else
    if not na(gapLine)
        line.delete(gapLine)
        gapLine := na
    if not na(gapLabel)
        label.delete(gapLabel)
        gapLabel := na

// --- Draw key levels only once per session ---
var line[] lines  = array.new<line>()
var label[] labels = array.new<label>()

plotLevels() =>
    for l in lines
        line.delete(l)
    array.clear(lines)
    for lb in labels
        label.delete(lb)
    array.clear(labels)

    mid_x = math.round((plotTriggerBar + end_x) / 2)
    labelStyle = label.style_label_center
    labelSize = size.small

    // Horizontal label staggering to reduce overlap when key levels are close.
    labelXHigh  = staggerLevelLabels ? mid_x - labelStepBars : mid_x
    labelXClose = staggerLevelLabels ? mid_x : mid_x
    labelXLow   = staggerLevelLabels ? mid_x + labelStepBars : mid_x
    labelXPivot = staggerLevelLabels ? mid_x : mid_x
    labelXR1    = staggerLevelLabels ? mid_x + labelStepBars : mid_x
    labelXR2    = staggerLevelLabels ? mid_x + labelStepBars * 2 : mid_x
    labelXR3    = staggerLevelLabels ? mid_x + labelStepBars * 3 : mid_x
    labelXS1    = staggerLevelLabels ? mid_x + labelStepBars : mid_x
    labelXS2    = staggerLevelLabels ? mid_x + labelStepBars * 2 : mid_x
    labelXS3    = staggerLevelLabels ? mid_x + labelStepBars * 3 : mid_x

    if showHigh
        array.push(lines, line.new(x1=plotTriggerBar, y1=refHigh,  x2=end_x, y2=refHigh, color=highColor, width=2, extend=extend_right ? extend.right : extend.none, force_overlay=true))
        array.push(labels, label.new(labelXHigh, refHigh, "Prev High", xloc=xloc.bar_index, yloc=yloc.price, color=highColor, style=labelStyle, textcolor=color.white, size=labelSize, force_overlay=true))

    if showLow
        array.push(lines, line.new(x1=plotTriggerBar, y1=refLow,  x2=end_x, y2=refLow, color=lowColor, width=2, extend=extend_right ? extend.right : extend.none, force_overlay=true))
        array.push(labels, label.new(labelXLow, refLow, "Prev Low", xloc=xloc.bar_index, yloc=yloc.price, color=lowColor, style=labelStyle, textcolor=color.white, size=labelSize, force_overlay=true))

    if showClose
        array.push(lines, line.new(x1=plotTriggerBar, y1=refClose,  x2=end_x, y2=refClose, color=closeColor, width=2, extend=extend_right ? extend.right : extend.none, force_overlay=true))
        array.push(labels, label.new(labelXClose, refClose, "Prev Close", xloc=xloc.bar_index, yloc=yloc.price, color=closeColor, style=labelStyle, textcolor=color.black, size=labelSize, force_overlay=true))

    if showPivot
        array.push(lines, line.new(x1=plotTriggerBar, y1=P,  x2=end_x, y2=P, color=pivotColor, width=2, extend=extend_right ? extend.right : extend.none, force_overlay=true))
        array.push(labels, label.new(labelXPivot, P, "Pivot", xloc=xloc.bar_index, yloc=yloc.price, color=pivotColor, style=labelStyle, textcolor=color.white, size=labelSize, force_overlay=true))

    if showR1
        array.push(lines, line.new(x1=plotTriggerBar, y1=R1,  x2=end_x, y2=R1, color=resColor, width=2, extend=extend_right ? extend.right : extend.none, force_overlay=true))
        array.push(labels, label.new(labelXR1, R1, "R1", xloc=xloc.bar_index, yloc=yloc.price, color=resColor, style=labelStyle, textcolor=color.white, size=labelSize, force_overlay=true))

    if showR2
        array.push(lines, line.new(x1=plotTriggerBar, y1=R2,  x2=end_x, y2=R2, color=resColor, width=2, extend=extend_right ? extend.right : extend.none, force_overlay=true))
        array.push(labels, label.new(labelXR2, R2, "R2", xloc=xloc.bar_index, yloc=yloc.price, color=resColor, style=labelStyle, textcolor=color.white, size=labelSize, force_overlay=true))

    if showR3
        array.push(lines, line.new(x1=plotTriggerBar, y1=R3,  x2=end_x, y2=R3, color=resColor, width=2, extend=extend_right ? extend.right : extend.none, force_overlay=true))
        array.push(labels, label.new(labelXR3, R3, "R3", xloc=xloc.bar_index, yloc=yloc.price, color=resColor, style=labelStyle, textcolor=color.white, size=labelSize, force_overlay=true))

    if showS1
        array.push(lines, line.new(x1=plotTriggerBar, y1=S1,  x2=end_x, y2=S1, color=supColor, width=2, extend=extend_right ? extend.right : extend.none, force_overlay=true))
        array.push(labels, label.new(labelXS1, S1, "S1", xloc=xloc.bar_index, yloc=yloc.price, color=supColor, style=labelStyle, textcolor=color.white, size=labelSize, force_overlay=true))

    if showS2
        array.push(lines, line.new(x1=plotTriggerBar, y1=S2,  x2=end_x, y2=S2, color=supColor, width=2, extend=extend_right ? extend.right : extend.none, force_overlay=true))
        array.push(labels, label.new(labelXS2, S2, "S2", xloc=xloc.bar_index, yloc=yloc.price, color=supColor, style=labelStyle, textcolor=color.white, size=labelSize, force_overlay=true))

    if showS3
        array.push(lines, line.new(x1=plotTriggerBar, y1=S3,  x2=end_x, y2=S3, color=supColor, width=2, extend=extend_right ? extend.right : extend.none, force_overlay=true))
        array.push(labels, label.new(labelXS3, S3, "S3", xloc=xloc.bar_index, yloc=yloc.price, color=supColor, style=labelStyle, textcolor=color.white, size=labelSize, force_overlay=true))

if canPlot and bar_index == plotTriggerBar
    plotLevels()


// -----------------------------------------------------------------------------
// Dragon Flow Decision Dashboard: bilingual TH/EN, anchored on the price chart.
// -----------------------------------------------------------------------------
isThaiDash = false

dashP  = ta.valuewhen(canPlot and not na(P),  P,  0)
dashR1 = ta.valuewhen(canPlot and not na(R1), R1, 0)
dashR2 = ta.valuewhen(canPlot and not na(R2), R2, 0)
dashR3 = ta.valuewhen(canPlot and not na(R3), R3, 0)
dashS1 = ta.valuewhen(canPlot and not na(S1), S1, 0)
dashS2 = ta.valuewhen(canPlot and not na(S2), S2, 0)
dashS3 = ta.valuewhen(canPlot and not na(S3), S3, 0)

f_lbl(string th, string en) =>
    isThaiDash ? th : en

f_level_line(string name, float value) =>
    name + " " + (na(value) ? "-" : f_fmt(value))

f_nearest_level(float price) =>
    string nearestName = "-"
    float nearestValue = na
    float nearestDist = 10e10
    if not na(dashR3)
        nearestName := "R3"
        nearestValue := dashR3
        nearestDist := math.abs(price - dashR3)
    if not na(dashR2) and math.abs(price - dashR2) < nearestDist
        nearestName := "R2"
        nearestValue := dashR2
        nearestDist := math.abs(price - dashR2)
    if not na(dashR1) and math.abs(price - dashR1) < nearestDist
        nearestName := "R1"
        nearestValue := dashR1
        nearestDist := math.abs(price - dashR1)
    if not na(dashP) and math.abs(price - dashP) < nearestDist
        nearestName := "Pivot"
        nearestValue := dashP
        nearestDist := math.abs(price - dashP)
    if not na(dashS1) and math.abs(price - dashS1) < nearestDist
        nearestName := "S1"
        nearestValue := dashS1
        nearestDist := math.abs(price - dashS1)
    if not na(dashS2) and math.abs(price - dashS2) < nearestDist
        nearestName := "S2"
        nearestValue := dashS2
        nearestDist := math.abs(price - dashS2)
    if not na(dashS3) and math.abs(price - dashS3) < nearestDist
        nearestName := "S3"
        nearestValue := dashS3
        nearestDist := math.abs(price - dashS3)
    nearestName + " " + (na(nearestValue) ? "-" : f_fmt(nearestValue))

var table status = table.new(position.top_right, 2, 13, bgcolor=panelBg, border_width=1, force_overlay=true)

if barstate.islast
    if visible and showPanel
        float poin = f_poin()
        float rangeAchieved = (hiToday - loToday) / syminfo.mintick
        float dayAvgPts = dRange / syminfo.mintick
        string pvaTxt = vaClimax ? f_lbl("Climax", "Climax") : vaRising ? f_lbl("Rising", "Rising") : f_lbl("Normal", "Normal")
        color bidCol = close >= close[1] ? color.rgb(26, 132, 39) : color.rgb(220, 20, 60)

        float atrNow = ta.atr(14)
        bool pivotReady = not na(dashP)
        bool abovePivot = pivotReady and close > dashP
        bool belowPivot = pivotReady and close < dashP
        bool nearPivot = pivotReady and not na(atrNow) and math.abs(close - dashP) <= atrNow * 0.10
        bool trendUp = close > dragonClose and dragonClose > trend
        bool trendDown = close < dragonClose and dragonClose < trend
        string trendTxt = trendUp ? f_lbl("Uptrend", "Uptrend") : trendDown ? f_lbl("Downtrend", "Downtrend") : f_lbl("Sideway", "Sideway")

        string mainPlan = f_lbl("Wait confirm", "Wait confirm")
        string guardrail = f_lbl("Wait break/pullback", "Wait break/pullback")
        color planCol = panelSubText
        if nearPivot
            mainPlan := f_lbl("Wait confirm", "Wait confirm")
            guardrail := f_lbl("Pivot zone", "Pivot zone")
            planCol := color.rgb(245, 180, 25)
        else if trendDown and belowPivot
            mainPlan := f_lbl("Sell-side bias", "Sell-side bias")
            guardrail := f_lbl("Avoid counter Buy", "Avoid counter Buy")
            planCol := color.rgb(227, 15, 68)
        else if trendUp and abovePivot
            mainPlan := f_lbl("Buy-side bias", "Buy-side bias")
            guardrail := f_lbl("Avoid counter Sell", "Avoid counter Sell")
            planCol := color.rgb(0, 166, 100)
        else if trendUp and belowPivot
            mainPlan := f_lbl("Mixed signal", "Mixed signal")
            guardrail := f_lbl("Wait above Pivot", "Wait above Pivot")
            planCol := color.rgb(245, 180, 25)
        else if trendDown and abovePivot
            mainPlan := f_lbl("Mixed signal", "Mixed signal")
            guardrail := f_lbl("Wait below Pivot", "Wait below Pivot")
            planCol := color.rgb(245, 180, 25)
        else
            mainPlan := f_lbl("Sideway", "Sideway")
            guardrail := f_lbl("Wait break/pullback", "Wait break/pullback")
            planCol := panelSubText

        table.cell(status, 0, 0, syminfo.ticker + "  " + f_tf_label(), text_color=panelText, bgcolor=panelHeaderBg, text_size=size.small)
        table.cell(status, 1, 0, "Dragon", text_color=color.rgb(40, 120, 255), bgcolor=panelHeaderBg, text_size=size.small)

        table.cell(status, 0, 1, f_lbl("Price", "Price"), text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 1, f_fmt(close), text_color=bidCol, bgcolor=panelBg, text_size=size.small)

        table.cell(status, 0, 2, f_lbl("Trend", "Trend"), text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 2, trendTxt, text_color=planCol, bgcolor=panelBg, text_size=size.tiny)

        table.cell(status, 0, 3, "Pivot", text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 3, na(dashP) ? "-" : f_fmt(dashP), text_color=abovePivot ? color.rgb(0, 166, 100) : belowPivot ? color.rgb(227, 15, 68) : panelSubText, bgcolor=panelBg, text_size=size.tiny)

        table.cell(status, 0, 4, f_lbl("Main Plan", "Main Plan"), text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 4, mainPlan, text_color=planCol, bgcolor=panelBg, text_size=size.tiny)

        table.cell(status, 0, 5, f_lbl("Guardrail", "Guardrail"), text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 5, guardrail, text_color=planCol, bgcolor=panelBg, text_size=size.tiny)

        table.cell(status, 0, 6, f_lbl("Nearest", "Nearest"), text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 6, f_nearest_level(close), text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)

        table.cell(status, 0, 7, "R1/R2/R3", text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 7, (na(dashR1) ? "-" : f_fmt(dashR1)) + " / " + (na(dashR2) ? "-" : f_fmt(dashR2)) + " / " + (na(dashR3) ? "-" : f_fmt(dashR3)), text_color=resColor, bgcolor=panelBg, text_size=size.tiny)

        table.cell(status, 0, 8, "S1/S2/S3", text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 8, (na(dashS1) ? "-" : f_fmt(dashS1)) + " / " + (na(dashS2) ? "-" : f_fmt(dashS2)) + " / " + (na(dashS3) ? "-" : f_fmt(dashS3)), text_color=supColor, bgcolor=panelBg, text_size=size.tiny)

        table.cell(status, 0, 9, "PVA", text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 9, pvaTxt, text_color=pvaColor, bgcolor=panelBg, text_size=size.tiny)

        table.cell(status, 0, 10, "Range", text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 10, str.tostring(dayAvgPts, "#") + ", " + str.tostring(rangeAchieved, "#"), text_color=panelSubText, bgcolor=panelBg, text_size=size.tiny)

        table.cell(status, 0, 11, f_lbl("Note", "Note"), text_color=color.new(panelSubText, 25), bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 11, f_lbl("Not investment advice/solicitation", "Not investment advice/solicitation"), text_color=color.new(panelSubText, 25), bgcolor=panelBg, text_size=size.tiny)

        table.cell(status, 0, 12, "", text_color=color.new(panelSubText, 25), bgcolor=panelBg, text_size=size.tiny)
        table.cell(status, 1, 12, f_lbl("Algorithmic analysis tool only", "Algorithmic analysis tool only"), text_color=color.new(panelSubText, 25), bgcolor=panelBg, text_size=size.tiny)
    else
        table.clear(status, 0, 0, 1, 12)
````
