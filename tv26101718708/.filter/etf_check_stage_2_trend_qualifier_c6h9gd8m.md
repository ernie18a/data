# ETF Check + Stage 2 Trend Qualifier

- url: https://www.tradingview.com/script/c6H9gd8m-ETF-Check-Stage-2-Trend-Qualifier/
- type: indicator
- pine_id: PUB;9a10b1cb05604f9f8005487128897eb6
- version: 1.0

## Description

Stage 2 Trend Qualifier + ETF Check Pro is a trend and leadership dashboard for stocks and ETFs.

It combines a Stage 2 trend template, relative strength analysis, ETF theme scoring, entry timing, RS days, RS line status, and volume run rate into one simple chart table.

Key features:

Stage 2 trend qualification using 50, 150, and 200 SMA logic
ETF theme strength score
Entry timing score using 20 EMA extension
RS checks vs SPY and QQQ
RS scores across 1M, 3M, 6M, and 12M
RS days over 15D, 30D, and 60D
RS line new high / near high / weak status
Optional volume run rate vs 50-day average

Best used on the daily timeframe to identify strong Stage 2 leaders, confirm sector/ETF leadership, and avoid chasing extended moves.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © YourTradingViewUsername
//@version=5
indicator("Stage 2 Trend Qualifier + ETF Check Pro", shorttitle="S2TQ ETF Pro", overlay=true)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

grpDisplay   = "Display"
i_showTrend  = input.bool(true, "Show Trend Template", group=grpDisplay)
i_showETF    = input.bool(true, "Show ETF Check", group=grpDisplay)
i_showRS     = input.bool(true, "Show RS Score & RS Days", group=grpDisplay)
i_showVol    = input.bool(false, "Show Volume Run Rate", group=grpDisplay)
i_tablePos   = input.string("Bottom Right", "Table Position",
     options=["Top Right", "Bottom Right", "Top Left", "Bottom Left", "Middle Right", "Middle Left"], group=grpDisplay)
i_textSize   = input.string("normal", "Text Size", options=["tiny", "small", "normal"], group=grpDisplay)
i_theme      = input.string("Dark", "Theme", options=["Dark", "Light"], group=grpDisplay)

grpBench     = "Benchmark"
i_benchmark  = input.symbol("SPY", "Primary Benchmark Symbol", group=grpBench)
i_spyBench   = input.symbol("SPY", "ETF Check: SPY Benchmark", group=grpBench)
i_qqqBench   = input.symbol("QQQ", "ETF Check: QQQ Benchmark", group=grpBench)

// ══════════════════════════════════════════════════════════════════════════════
// MOVING AVERAGES
// ══════════════════════════════════════════════════════════════════════════════

ema20  = ta.ema(close, 20)
sma20  = ta.sma(close, 20)
sma50  = ta.sma(close, 50)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)

high52w = ta.highest(high, 252)
low52w  = ta.lowest(low, 252)

// ══════════════════════════════════════════════════════════════════════════════
// TREND TEMPLATE, 8 CRITERIA
// ══════════════════════════════════════════════════════════════════════════════

c1 = not na(sma150) and close > sma150
c2 = not na(sma200) and close > sma200
c3 = not na(sma50) and not na(sma150) and sma50 > sma150
c4 = not na(sma50) and not na(sma200) and sma50 > sma200
c5 = not na(sma200) and not na(sma200[21]) and sma200 > sma200[21]

pctAboveLow  = low52w > 0 and not na(low52w) ? ((close - low52w) / low52w) * 100 : 0
c6 = pctAboveLow >= 25

pctBelowHigh = high52w > 0 and not na(high52w) ? ((high52w - close) / high52w) * 100 : 100
c7 = pctBelowHigh <= 25

pctFromSma50 = not na(sma50) and sma50 > 0 ? ((close - sma50) / sma50) * 100 : -100
c8 = pctFromSma50 >= -10

passCount = (c1 ? 1 : 0) + (c2 ? 1 : 0) + (c3 ? 1 : 0) + (c4 ? 1 : 0) +
     (c5 ? 1 : 0) + (c6 ? 1 : 0) + (c7 ? 1 : 0) + (c8 ? 1 : 0)

isStage2 = passCount == 8

// ══════════════════════════════════════════════════════════════════════════════
// STAGE IDENTIFICATION
// ══════════════════════════════════════════════════════════════════════════════

isStage4 = not na(sma200) and not na(sma200[21]) and close < sma200 and sma200 < sma200[21]
isStage3 = not isStage2 and not isStage4 and not na(sma50) and not na(sma200) and close < sma50 and close > sma200
isStage1 = not isStage2 and not isStage3 and not isStage4

stageText  = isStage2 ? "STAGE 2" : isStage3 ? "STAGE 3" : isStage4 ? "STAGE 4" : "STAGE 1"
stageColor = isStage2 ? color.rgb(38, 166, 154) : isStage3 ? color.rgb(255, 171, 64) : isStage4 ? color.rgb(239, 83, 80) : color.rgb(120, 123, 134)

// ══════════════════════════════════════════════════════════════════════════════
// ETF CHECK PRO
// ══════════════════════════════════════════════════════════════════════════════

pctFromEma20 = not na(ema20) and ema20 > 0 ? ((close - ema20) / ema20) * 100 : na

isIdealExtension = not na(pctFromEma20) and pctFromEma20 >= 0 and pctFromEma20 <= 5
isOkExtension    = not na(pctFromEma20) and pctFromEma20 > 5 and pctFromEma20 <= 10
isExtended20     = not na(pctFromEma20) and pctFromEma20 > 10
isBelow20        = not na(pctFromEma20) and pctFromEma20 < 0

aboveKeyMAs = close > ema20 and close > sma50

higherHigh20 = high > ta.highest(high[1], 20)

// Improved higher low logic
recentLow10 = ta.lowest(low, 10)
priorLow10  = ta.lowest(low[10], 10)
higherLow20 = not na(recentLow10) and not na(priorLow10) and recentLow10 > priorLow10

spyClose = request.security(i_spyBench, timeframe.period, close)
qqqClose = request.security(i_qqqBench, timeframe.period, close)

rsSpy = spyClose > 0 ? close / spyClose : na
rsQqq = qqqClose > 0 ? close / qqqClose : na

rsSpySma20 = ta.sma(rsSpy, 20)
rsQqqSma20 = ta.sma(rsQqq, 20)

rsVsSpyStrong = not na(rsSpy) and not na(rsSpySma20) and rsSpy > rsSpySma20 and rsSpySma20 > rsSpySma20[10]
rsVsQqqStrong = not na(rsQqq) and not na(rsQqqSma20) and rsQqq > rsQqqSma20 and rsQqqSma20 > rsQqqSma20[10]

// Theme strength ignores extension, so strong ETFs are not downgraded just because they are stretched.
themeStrengthScore =
     (isStage2 ? 1 : 0) +
     (aboveKeyMAs ? 1 : 0) +
     (rsVsSpyStrong ? 1 : 0) +
     (rsVsQqqStrong ? 1 : 0) +
     ((higherHigh20 or higherLow20) ? 1 : 0)

themeGrade = themeStrengthScore >= 5 ? "THEME A" : themeStrengthScore >= 3 ? "THEME B" : "THEME C"

// Entry timing focuses on whether it is safe to chase now.
entryTimingScore =
     (aboveKeyMAs ? 1 : 0) +
     ((isIdealExtension or isOkExtension) ? 1 : 0) +
     (higherLow20 ? 1 : 0)

entryGrade = entryTimingScore >= 3 ? "ENTRY A" : entryTimingScore == 2 ? "ENTRY B" : "ENTRY C"

finalLabel =
     themeStrengthScore >= 5 and entryTimingScore >= 3 ? "LEADERSHIP CONFIRMED" :
     themeStrengthScore >= 5 and isExtended20 ? "STRONG BUT EXTENDED" :
     themeStrengthScore >= 3 ? "MIXED" :
     "AVOID"

// Original ETF score kept for compatibility
etfScore =
     (isStage2 ? 1 : 0) +
     (aboveKeyMAs ? 1 : 0) +
     ((isIdealExtension or isOkExtension) ? 1 : 0) +
     (rsVsSpyStrong ? 1 : 0) +
     (rsVsQqqStrong ? 1 : 0)

etfGrade = etfScore >= 5 ? "ETF A" : etfScore >= 3 ? "ETF B" : "ETF C"

// ══════════════════════════════════════════════════════════════════════════════
// RELATIVE STRENGTH vs PRIMARY BENCHMARK
// ══════════════════════════════════════════════════════════════════════════════

benchClose   = request.security(i_benchmark, timeframe.period, close)
benchTicker  = request.security(i_benchmark, timeframe.period, syminfo.tickerid)
isSameSym    = syminfo.tickerid == benchTicker

safePerf(float current, float previous) =>
    na(current) or na(previous) or previous == 0 ? 0.0 : ((current - previous) / previous) * 100.0

stockChg1M  = safePerf(close, close[21])
stockChg3M  = safePerf(close, close[63])
stockChg6M  = safePerf(close, close[126])
stockChg12M = safePerf(close, close[252])

benchChg1M  = safePerf(benchClose, benchClose[21])
benchChg3M  = safePerf(benchClose, benchClose[63])
benchChg6M  = safePerf(benchClose, benchClose[126])
benchChg12M = safePerf(benchClose, benchClose[252])

rs1M  = stockChg1M  - benchChg1M
rs3M  = stockChg3M  - benchChg3M
rs6M  = stockChg6M  - benchChg6M
rs12M = stockChg12M - benchChg12M

rsScoreCalc(float relPerf, float scale) =>
    int(math.max(1, math.min(99, math.round(50 + relPerf * scale))))

rsScore1M  = isSameSym ? 0 : rsScoreCalc(rs1M,  2.5)
rsScore3M  = isSameSym ? 0 : rsScoreCalc(rs3M,  1.25)
rsScore6M  = isSameSym ? 0 : rsScoreCalc(rs6M,  0.83)
rsScore12M = isSameSym ? 0 : rsScoreCalc(rs12M, 0.5)

// ══════════════════════════════════════════════════════════════════════════════
// RS DAYS, OUTPERFORMANCE DAY COUNT
// ══════════════════════════════════════════════════════════════════════════════

dailyOutperf = not na(benchClose) and not na(benchClose[1]) and benchClose[1] > 0 and close[1] > 0 ?
     (close / close[1]) > (benchClose / benchClose[1]) : false

rsDays15  = math.sum(dailyOutperf ? 1 : 0, 15)
rsDays30  = math.sum(dailyOutperf ? 1 : 0, 30)
rsDays60  = math.sum(dailyOutperf ? 1 : 0, 60)

rsDaysPct15 = rsDays15 / 15.0 * 100
rsDaysPct30 = rsDays30 / 30.0 * 100
rsDaysPct60 = rsDays60 / 60.0 * 100

// ══════════════════════════════════════════════════════════════════════════════
// RS LINE, NEW 52-WEEK HIGH
// ══════════════════════════════════════════════════════════════════════════════

rsLine       = not na(benchClose) and benchClose > 0 ? close / benchClose : na
rsLine52H    = ta.highest(rsLine, 252)
rsLinePct    = not na(rsLine) and not na(rsLine52H) and rsLine52H > 0 ? rsLine / rsLine52H : 0

rsLineIsHigh  = not isSameSym and rsLinePct >= 1.0
rsLineNear    = not isSameSym and rsLinePct >= 0.97 and rsLinePct < 1.0
rsLineNeutral = not isSameSym and rsLinePct >= 0.85 and rsLinePct < 0.97
rsLineWeak    = not isSameSym and rsLinePct < 0.85

// ══════════════════════════════════════════════════════════════════════════════
// VOLUME RUN RATE vs 50-DAY MA
// ══════════════════════════════════════════════════════════════════════════════

volMA50 = ta.sma(volume[1], 50)

isLive    = not barstate.isconfirmed
isDailyTF = timeframe.isdaily

nowH    = hour(timenow, syminfo.timezone)
nowM    = minute(timenow, syminfo.timezone)
nowMins = nowH * 60 + nowM

minsIntoSession = nowMins - 570
isInSession     = isDailyTF and isLive and minsIntoSession > 0 and minsIntoSession <= 390

sessionFrac  = isInSession ? math.max(0.05, minsIntoSession / 390.0) : na
projectedVol = not na(sessionFrac) ? volume / sessionFrac : na
volRunRate   = not na(projectedVol) and not na(volMA50) and volMA50 > 0 ? (projectedVol - volMA50) / volMA50 * 100 : na

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

prevPass           = nz(passCount[1], 0)
newlyQualified     = prevPass < 8 and passCount == 8
newlyDisqualified  = prevPass == 8 and passCount < 8
rsLineNewHighAlert = not isSameSym and rsLineIsHigh and not nz(rsLineIsHigh[1], false)
themeAAlert        = themeStrengthScore >= 5 and themeStrengthScore[1] < 5
leadershipAlert    = finalLabel == "LEADERSHIP CONFIRMED" and finalLabel[1] != "LEADERSHIP CONFIRMED"

alertcondition(newlyQualified, title="Stage 2 Qualified",
     message="{{ticker}} now qualifies as Stage 2")
alertcondition(newlyDisqualified, title="Stage 2 Lost",
     message="{{ticker}} lost Stage 2 qualification")
alertcondition(rsLineNewHighAlert, title="RS Line New High",
     message="{{ticker}} RS line making new 52-week high vs benchmark")
alertcondition(themeAAlert, title="Theme Grade A",
     message="{{ticker}} now qualifies as Theme Grade A")
alertcondition(leadershipAlert, title="Leadership Confirmed",
     message="{{ticker}} now shows leadership confirmed")

// ══════════════════════════════════════════════════════════════════════════════
// TABLE DISPLAY
// ══════════════════════════════════════════════════════════════════════════════

tablePos = switch i_tablePos
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    => position.middle_left

txtSize = switch i_textSize
    "tiny"   => size.tiny
    "small"  => size.small
    => size.normal

dataSize = switch i_textSize
    "tiny"   => size.tiny
    "small"  => size.tiny
    => size.small

isDark     = i_theme == "Dark"
COL_BG     = isDark ? color.rgb(22, 26, 37, 5) : color.rgb(240, 243, 250, 5)
COL_HDR    = isDark ? color.rgb(13, 15, 22, 0) : color.rgb(220, 225, 235, 0)
COL_TRANS  = color.rgb(0, 0, 0, 100)
COL_TEXT   = isDark ? color.rgb(178, 181, 190) : color.rgb(55, 60, 75)
COL_DIM    = isDark ? color.rgb(100, 103, 114) : color.rgb(130, 135, 150)
COL_GREEN  = color.rgb(38, 166, 154)
COL_BGREEN = color.rgb(0, 230, 118)
COL_RED    = color.rgb(239, 83, 80)
COL_YELLOW = color.rgb(255, 171, 64)

rsScoreCol(int score) =>
    score >= 80 ? COL_BGREEN : score >= 60 ? COL_GREEN : score >= 40 ? COL_TEXT : COL_RED

rsDaysCol(float pct) =>
    pct >= 60 ? COL_GREEN : pct >= 40 ? COL_TEXT : COL_RED

volRunRateCol(float pct) =>
    pct >= 50 ? COL_BGREEN : pct >= 0 ? COL_GREEN : pct >= -30 ? COL_YELLOW : COL_RED

themeColor = themeStrengthScore >= 5 ? COL_BGREEN : themeStrengthScore >= 3 ? COL_YELLOW : COL_RED
entryColor = entryTimingScore >= 3 ? COL_BGREEN : entryTimingScore == 2 ? COL_YELLOW : COL_RED
finalColor = finalLabel == "LEADERSHIP CONFIRMED" ? COL_BGREEN :
     finalLabel == "STRONG BUT EXTENDED" ? COL_YELLOW :
     finalLabel == "MIXED" ? COL_YELLOW : COL_RED

extensionColor = isExtended20 ? COL_RED : isOkExtension ? COL_YELLOW : isIdealExtension ? COL_GREEN : isBelow20 ? COL_RED : COL_DIM

var table dash = table.new(tablePos, 3, 34, bgcolor=COL_TRANS, border_width=0, frame_width=0)

if barstate.islast
    for r = 0 to 33
        for c = 0 to 2
            table.cell(dash, c, r, "", bgcolor=COL_TRANS)

    int row = 0

    table.cell(dash, 0, row, " " + stageText + " ", text_color=stageColor, text_size=txtSize,
         bgcolor=COL_HDR, text_halign=text.align_left)
    table.cell(dash, 1, row, " " + str.tostring(passCount) + " / 8 ", text_color=stageColor, text_size=txtSize,
         bgcolor=COL_HDR, text_halign=text.align_right)
    table.cell(dash, 2, row, isStage2 ? " ✓ " : " ✗ ", text_color=stageColor, text_size=txtSize,
         bgcolor=COL_HDR, text_halign=text.align_center)
    row += 1

    if i_showETF
        table.cell(dash, 0, row, " ETF CHECK PRO ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_left)
        table.cell(dash, 1, row, " Score ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_center)
        table.cell(dash, 2, row, " Grade ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " Theme Strength ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, str.tostring(themeStrengthScore) + " / 5", text_color=themeColor, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        table.cell(dash, 2, row, themeGrade, text_color=themeColor, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " Entry Timing ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, str.tostring(entryTimingScore) + " / 3", text_color=entryColor, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        table.cell(dash, 2, row, entryGrade, text_color=entryColor, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " Final Read ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_HDR)
        table.cell(dash, 2, row, finalLabel, text_color=finalColor, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " From 20 EMA ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, na(pctFromEma20) ? " — " : str.tostring(pctFromEma20, "#.#") + "%", text_color=extensionColor, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " Above 20 EMA & 50 ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, aboveKeyMAs ? " ✓ " : " ✗ ", text_color=aboveKeyMAs ? COL_GREEN : COL_RED, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " RS vs SPY ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, rsVsSpyStrong ? " ✓ " : " ✗ ", text_color=rsVsSpyStrong ? COL_GREEN : COL_RED, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " RS vs QQQ ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, rsVsQqqStrong ? " ✓ " : " ✗ ", text_color=rsVsQqqStrong ? COL_GREEN : COL_RED, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " 20D Structure ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, higherHigh20 ? " HH " : " — ", text_color=higherHigh20 ? COL_GREEN : COL_DIM, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        table.cell(dash, 2, row, higherLow20 ? " HL " : " — ", text_color=higherLow20 ? COL_GREEN : COL_DIM, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

    if i_showTrend
        table.cell(dash, 0, row, " TREND TEMPLATE ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_HDR)
        table.cell(dash, 2, row, "", bgcolor=COL_HDR)
        row += 1

        table.cell(dash, 0, row, " Price > 150 SMA ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, c1 ? " ✓ " : " ✗ ", text_color=c1 ? COL_GREEN : COL_RED, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " Price > 200 SMA ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, c2 ? " ✓ " : " ✗ ", text_color=c2 ? COL_GREEN : COL_RED, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " 50 SMA > 150 SMA ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, c3 ? " ✓ " : " ✗ ", text_color=c3 ? COL_GREEN : COL_RED, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " 50 SMA > 200 SMA ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, c4 ? " ✓ " : " ✗ ", text_color=c4 ? COL_GREEN : COL_RED, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " 200 SMA Rising ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, c5 ? " ✓ " : " ✗ ", text_color=c5 ? COL_GREEN : COL_RED, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " ≥25% Above 52W Low ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, c6 ? " ✓ " : " ✗ ", text_color=c6 ? COL_GREEN : COL_RED, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " Within 25% of 52W High ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, c7 ? " ✓ " : " ✗ ", text_color=c7 ? COL_GREEN : COL_RED, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " Within 10% of 50 SMA ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, c8 ? " ✓ " : " ✗ ", text_color=c8 ? COL_GREEN : COL_RED, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

    if i_showRS
        table.cell(dash, 0, row, "", bgcolor=COL_HDR)
        table.cell(dash, 1, row, " RS Score ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_center)
        table.cell(dash, 2, row, " RS Days ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_center)
        row += 1

        string naText = "—"

        table.cell(dash, 0, row, " 1M ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, isSameSym ? " " + naText + " " : " " + str.tostring(rsScore1M) + " ", text_color=isSameSym ? COL_DIM : rsScoreCol(rsScore1M), text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        table.cell(dash, 2, row, "", bgcolor=COL_BG)
        row += 1

        table.cell(dash, 0, row, " 3M ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, isSameSym ? " " + naText + " " : " " + str.tostring(rsScore3M) + " ", text_color=isSameSym ? COL_DIM : rsScoreCol(rsScore3M), text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        table.cell(dash, 2, row, "", bgcolor=COL_BG)
        row += 1

        table.cell(dash, 0, row, " 6M ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, isSameSym ? " " + naText + " " : " " + str.tostring(rsScore6M) + " ", text_color=isSameSym ? COL_DIM : rsScoreCol(rsScore6M), text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        table.cell(dash, 2, row, "", bgcolor=COL_BG)
        row += 1

        table.cell(dash, 0, row, " 12M ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, isSameSym ? " " + naText + " " : " " + str.tostring(rsScore12M) + " ", text_color=isSameSym ? COL_DIM : rsScoreCol(rsScore12M), text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        table.cell(dash, 2, row, "", bgcolor=COL_BG)
        row += 1

        d15text = str.tostring(rsDays15, "#") + " (" + str.tostring(rsDaysPct15, "#.#") + "%)"
        d30text = str.tostring(rsDays30, "#") + " (" + str.tostring(rsDaysPct30, "#.#") + "%)"
        d60text = str.tostring(rsDays60, "#") + " (" + str.tostring(rsDaysPct60, "#.#") + "%)"

        table.cell(dash, 0, row, " 15D ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, isSameSym ? " " + naText + " " : " " + d15text + " ", text_color=isSameSym ? COL_DIM : rsDaysCol(rsDaysPct15), text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " 30D ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, isSameSym ? " " + naText + " " : " " + d30text + " ", text_color=isSameSym ? COL_DIM : rsDaysCol(rsDaysPct30), text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        table.cell(dash, 0, row, " 60D ", text_color=COL_DIM, text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_BG)
        table.cell(dash, 2, row, isSameSym ? " " + naText + " " : " " + d60text + " ", text_color=isSameSym ? COL_DIM : rsDaysCol(rsDaysPct60), text_size=dataSize, bgcolor=COL_BG, text_halign=text.align_center)
        row += 1

        rsLineText = isSameSym ? "SELF" : rsLineIsHigh ? "NEW HIGH" : rsLineNear ? "NEAR HIGH" : rsLineNeutral ? "NEUTRAL" : "WEAK"
        rsLineCol  = isSameSym ? COL_DIM : rsLineIsHigh ? COL_BGREEN : rsLineNear ? COL_YELLOW : rsLineNeutral ? COL_DIM : COL_RED

        table.cell(dash, 0, row, " RS Line ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_HDR)
        table.cell(dash, 2, row, " " + rsLineText + " ", text_color=rsLineCol, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_center)
        row += 1

    if i_showVol
        string volSign  = not na(volRunRate) and volRunRate >= 0 ? "+" : ""
        string volText  = na(volRunRate) ? " — " : " " + volSign + str.tostring(volRunRate, "#.#") + "% "
        color  volCol   = na(volRunRate) ? COL_DIM : volRunRateCol(volRunRate)

        table.cell(dash, 0, row, " Vol. RR (MA50) ", text_color=COL_TEXT, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_left)
        table.cell(dash, 1, row, "", bgcolor=COL_HDR)
        table.cell(dash, 2, row, volText, text_color=volCol, text_size=dataSize, bgcolor=COL_HDR, text_halign=text.align_center)
        row += 1
````
