<!-- tradingview-pine-id: PUB;3b2d7ca33e5e483389a240805af0fe7c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Gold/Silver Pairs Scalper

Source: https://www.tradingview.com/script/GUigiYRV-Gold-Silver-Pairs-Scalper/

## Description

🟢 Gold/Silver Pairs Scalper
Gold/Silver Pairs Scalper identifies temporary relative-value gaps between Gold and Silver and generates market-neutral pair signals:
LONG GOLD  / SHORT SILVER
SHORT GOLD / LONG SILVER
[image]https://www.tradingview.com/x/2PDkKLsF/[/image]
It does not predict the outright direction of precious metals. It trades the relative movement between the two assets.
This is statistical arbitrage, not risk-free arbitrage.

🟢 MODEL
Signals are calculated from fixed reference markets:
Gold   — OANDA:XAUUSD
Silver — OANDA:XAGUSD
The model combines:
- Beta-adjusted Gold/Silver return divergence
- Gold/Silver price-ratio deviation
- Rolling correlation validation
- Rolling beta hedge sizing
The calculations follow the active chart timeframe. 
The recommended timeframes are 3 minutes and 5 minutes.

🟢 GAP SIGNAL
The return gap measures Silver’s movement relative to its expected movement based on Gold:
Return Residual
= Silver Return − Beta × Gold Return
The model also evaluates the Gold/Silver price ratio.
High Gold/Silver ratio → Adds Short Gold / Long Silver pressure
Low Gold/Silver ratio  → Adds Long Gold / Short Silver pressure
Both components are standardized and combined into one pair score.
When an extreme gap begins moving back toward its mean:
Positive extreme → LONG GOLD  / SHORT SILVER
Negative extreme → SHORT GOLD / LONG SILVER
New positions are allowed only while the Gold/Silver correlation and beta remain valid.

⚖️ POSITION SIZE
The displayed position size adjusts for both the absolute price difference and rolling beta:
1 GOLD : 24.82 SILVER
This is an ounce-equivalent hedge ratio, not a futures contract ratio.
For futures, contract multipliers must be applied separately:
GC — 100 troy ounces
SI — 5,000 troy ounces
Because futures contracts use fixed sizes, the actual hedge may differ from the theoretical ratio after contract rounding.

🔺 SIGNAL MARKERS
Green upward triangle   — Long entry
Red downward triangle   — Short entry
Green circle            — Long exit
Red circle              — Short exit
Gold and Silver are managed as one pair position. Both legs enter and exit from the same pair signal.
For example:
Gold chart   → Green upward triangle
Silver chart → Red downward triangle
This represents Long Gold / Short Silver.

⏹ EXIT CONDITIONS
The complete pair is closed when:
- The gap returns to the mean-reversion threshold
- The gap expands another 1.25σ against the position
- Correlation or beta becomes invalid
- The position reaches the 100-bar holding limit
- Leveraged pair loss reaches −100%

📊 STATUS
READY       (Waiting for a valid entry)
LONG        (Current chart asset is long)
SHORT       (Current chart asset is short)
WARMUP      (Collecting required historical data)
BLOCKED     (Correlation or beta is invalid)
COOLDOWN    (Waiting briefly after an exit)
LIQUIDATED  (Equity reached −100%; trading halted)
LONG and SHORT always describe the asset displayed on the current chart.
During the same pair trade, the Gold chart and Silver chart therefore display opposite directions.

〽️ OSCILLATOR
The lower oscillator displays the final Gold/Silver pair score.
On a Gold chart:
Above zero → Gold
Below zero → Silver
On a Silver chart:
Above zero → Silver
Below zero → Gold
The oscillator is inverted on the Silver chart so its direction corresponds to the active Silver leg.
[image]https://www.tradingview.com/x/GD37Peh0/[/image]
🖥️ RECOMMENDED LAYOUT
Use a two-chart layout or two separate windows:
Chart 1 — Gold
Chart 2 — Silver
Both charts should use the same 3-minute or 5-minute timeframe.
If only one chart is used, only that asset’s signals are displayed, so the complete Gold/Silver pair trade cannot be followed.
For a synchronized two-chart layout, use:
Symbol       OFF
Interval     ON
Crosshair    ON
Time         ON
Date range   ON
Keeping Symbol disabled allows one chart to remain on Gold and the other on Silver. The remaining options keep both charts aligned to the same timeframe and time position.

📈 PERFORMANCE
Cumulative Return includes closed-trade results and the unrealized P&L of the active pair position after applying the selected leverage.
Sharpe is calculated from completed UTC daily mark-to-market equity returns. Trading Period runs from the first entry to the latest calculated bar.
Performance is simulated with no commissions, spread, slippage or financing costs, so actual results may differ.

⚠️ DISCLAIMER
This indicator is provided for informational and educational purposes only and does not constitute financial or investment advice.
Historical and simulated performance does not guarantee future results. High leverage can result in rapid and complete loss of capital. All trading decisions remain the sole responsibility of the user.

---

## Source Code

````pine
// © 2026 MantisAlgo
// All rights reserved.
//@version=6
indicator("Gold/Silver Pairs Scalper", shorttitle="GS Pairs Scalper", overlay=false)
int betaLength = 60
int gapMoveLength = 20
int zLookback = 100
int ratioLookback = 120
float ratioWeightPct = 30.0
float correlationEnter = 0.55
float correlationExit = 0.30
float minimumBeta = 0.10
float maximumBeta = 5.00
float entryZ = 1.50
float exitZ = 0.25
int turnBars = 1
float adverseZStop = 1.25
int maxHoldBars = 100
int cooldownBars = 3
float leveragePct = input.float(2000.0, "Leverage (% of total equity)", minval=0.0, maxval=10000.0, step=10.0,
     tooltip="Scales backtest pair returns. 100% = 1.0x equity, 250% = 2.5x equity.", display=display.none)

color bullColor = color.rgb(0, 185, 107)
color bearColor = color.rgb(242, 54, 69)
color goldColor = color.rgb(255, 160, 40)
color silverColor = color.rgb(150, 190, 215)
color neutralColor = color.rgb(110, 120, 140)

f_safeDiv(float a, float b) =>
    math.abs(b) > 1e-10 ? a / b : na

f_fmt(float x, string pattern) =>
    na(x) ? "—" : str.tostring(x, pattern)

string refGold = "OANDA:XAUUSD"
string refSilver = "OANDA:XAGUSD"

[gClose, gHigh, gLow] = request.security(refGold, timeframe.period, [close, high, low],
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[sClose, sHigh, sLow] = request.security(refSilver, timeframe.period, [close, high, low],
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

float gReturn = not na(gClose[1]) ? math.log(gClose / gClose[1]) : na
float sReturn = not na(sClose[1]) ? math.log(sClose / sClose[1]) : na
float correlation = ta.correlation(gReturn, sReturn, betaLength)
float gVol = ta.stdev(gReturn, betaLength)
float sVol = ta.stdev(sReturn, betaLength)
// OLS slope SilverReturn ~ beta * GoldReturn, expressed through rho and vol ratio.
float rollingBeta = not na(correlation) ? correlation * f_safeDiv(sVol, gVol) : na
bool betaValid = not na(rollingBeta) and rollingBeta >= minimumBeta and rollingBeta <= maximumBeta

float gMove = not na(gClose[gapMoveLength]) ? math.log(gClose / gClose[gapMoveLength]) : na
float sMove = not na(sClose[gapMoveLength]) ? math.log(sClose / sClose[gapMoveLength]) : na
float residual = betaValid and not na(gMove) and not na(sMove) ? sMove - rollingBeta * gMove : na
float residualMean = ta.sma(residual, zLookback)
float residualDev = ta.stdev(residual, zLookback)
float residualZ = not na(residualDev) and residualDev > 1e-8 ? (residual - residualMean) / residualDev : na

// Absolute relative-price layer. A high Gold/Silver ratio means Gold is rich:
// short Gold / long Silver. Invert its Z-score so positive always means
// long Gold / short Silver, matching the residual score convention.
float logRatio = not na(gClose) and not na(sClose) and sClose > 0 ? math.log(gClose / sClose) : na
float ratioMean = ta.sma(logRatio, ratioLookback)
float ratioDev = ta.stdev(logRatio, ratioLookback)
float ratioZ = not na(ratioDev) and ratioDev > 1e-8 ? (logRatio - ratioMean) / ratioDev : na
float ratioPairScore = not na(ratioZ) ? -ratioZ : na
float ratioWeight = ratioWeightPct / 100.0
float residualWeight = 1.0 - ratioWeight
float combinedScore = not na(residualZ) and not na(ratioPairScore) ? residualWeight * residualZ + ratioWeight * ratioPairScore : na

float corrEnterSafe = math.max(correlationEnter, correlationExit + 0.05)
float corrExitSafe = math.min(correlationExit, corrEnterSafe - 0.05)
var bool correlationValid = false
if barstate.isconfirmed and not na(correlation)
    if correlationValid and correlation < corrExitSafe
        correlationValid := false
    else if not correlationValid and correlation >= corrEnterSafe
        correlationValid := true

bool modelReady = correlationValid and betaValid and not na(combinedScore)
bool highExtreme = modelReady and combinedScore >= entryZ
bool lowExtreme = modelReady and combinedScore <= -entryZ

var int highTurnCount = 0
var int lowTurnCount = 0
if barstate.isconfirmed
    highTurnCount := highExtreme and combinedScore < combinedScore[1] ? highTurnCount + 1 : highExtreme ? 0 : 0
    lowTurnCount := lowExtreme and combinedScore > combinedScore[1] ? lowTurnCount + 1 : lowExtreme ? 0 : 0

bool highGapEntry = highTurnCount >= turnBars
bool lowGapEntry = lowTurnCount >= turnBars

// pairPosition: +1 = Long Gold / Short Silver; -1 = Long Silver / Short Gold.
var int pairPosition = 0
var float entryGold = na
var float entrySilver = na
var float entryBeta = na
var float entryScore = na
var float entryPriceRatio = na
var int holdingBars = 0
var int cooldownLeft = 0

var int closedTrades = 0
var int winningTrades = 0
var float cumulativeEquity = 1.0
var float dailyReturnSum = 0.0
var float dailyReturnSquaredSum = 0.0
var int dailyReturnCount = 0
var float priorDayEndEquity = na
var int testStartTime = na
var bool liquidated = false

bool pairEntryEvent = false
bool pairExitEvent = false
bool liquidationEvent = false
int exitedPairDirection = 0

if barstate.isconfirmed
    cooldownLeft := math.max(cooldownLeft - 1, 0)

    if pairPosition != 0
        holdingBars += 1
        float markGoldReturn = gClose / entryGold - 1.0
        float markSilverReturn = sClose / entrySilver - 1.0
        float markGrossExposure = entryBeta + 1.0
        float markPairReturn = pairPosition == 1 ? (entryBeta * markGoldReturn - markSilverReturn) / markGrossExposure : (markSilverReturn - entryBeta * markGoldReturn) / markGrossExposure
        float markLeveredReturn = markPairReturn * leveragePct / 100.0
        float adverseGoldReturn = (pairPosition == 1 ? gLow : gHigh) / entryGold - 1.0
        float adverseSilverReturn = (pairPosition == 1 ? sHigh : sLow) / entrySilver - 1.0
        float adversePairReturn = pairPosition == 1 ? (entryBeta * adverseGoldReturn - adverseSilverReturn) / markGrossExposure : (adverseSilverReturn - entryBeta * adverseGoldReturn) / markGrossExposure
        float adverseLeveredReturn = adversePairReturn * leveragePct / 100.0
        bool meanReverted = pairPosition == 1 ? combinedScore <= exitZ : combinedScore >= -exitZ
        bool adverseStop = pairPosition == 1 ? combinedScore >= entryScore + adverseZStop : combinedScore <= entryScore - adverseZStop
        bool relationshipBroken = not correlationValid or not betaValid
        bool timeExit = maxHoldBars > 0 and holdingBars >= maxHoldBars
        bool leverageLiquidation = adverseLeveredReturn <= -1.0

        if meanReverted or adverseStop or relationshipBroken or timeExit or leverageLiquidation
            float leveredPairReturn = leverageLiquidation ? -1.0 : markLeveredReturn
            cumulativeEquity *= math.max(1.0 + leveredPairReturn, 0.0)
            winningTrades += leveredPairReturn > 0 ? 1 : 0
            closedTrades += 1
            exitedPairDirection := pairPosition
            pairExitEvent := true
            liquidationEvent := leverageLiquidation
            liquidated := liquidated or leverageLiquidation
            pairPosition := 0
            entryGold := na
            entrySilver := na
            entryBeta := na
            entryScore := na
            entryPriceRatio := na
            holdingBars := 0
            cooldownLeft := cooldownBars

    if pairPosition == 0 and cooldownLeft == 0 and not liquidated
        if highGapEntry
            pairPosition := 1
            entryGold := gClose
            entrySilver := sClose
            entryBeta := rollingBeta
            entryScore := combinedScore
            entryPriceRatio := gClose / sClose
            testStartTime := na(testStartTime) ? time : testStartTime
            holdingBars := 0
            pairEntryEvent := true
            highTurnCount := 0
        else if lowGapEntry
            pairPosition := -1
            entryGold := gClose
            entrySilver := sClose
            entryBeta := rollingBeta
            entryScore := combinedScore
            entryPriceRatio := gClose / sClose
            testStartTime := na(testStartTime) ? time : testStartTime
            holdingBars := 0
            pairEntryEvent := true
            lowTurnCount := 0

int losingTrades = closedTrades - winningTrades
float winRate = closedTrades > 0 ? winningTrades * 100.0 / closedTrades : na
// Continuous account equity, including unrealized P&L while a pair is open.
float openPairReturn = 0.0
if pairPosition != 0 and not na(entryGold) and not na(entrySilver) and not na(entryBeta)
    float openGoldReturn = gClose / entryGold - 1.0
    float openSilverReturn = sClose / entrySilver - 1.0
    float openGrossExposure = entryBeta + 1.0
    openPairReturn := pairPosition == 1 ? (entryBeta * openGoldReturn - openSilverReturn) / openGrossExposure : (openSilverReturn - entryBeta * openGoldReturn) / openGrossExposure
float markedEquity = cumulativeEquity * math.max(1.0 + openPairReturn * leveragePct / 100.0, 0.0)
float cumulativeReturn = not na(testStartTime) ? (markedEquity - 1.0) * 100.0 : na

// At the first bar of each new exchange day, the previous bar is the completed
// day-end equity. Flat days are included, producing a legitimate 0% daily return.
// UTC boundaries keep the Daily MTM statistic identical on Gold and Silver
// charts even if their chart symbols use different exchange time zones.
int utcDay = int(math.floor(time / 86400000.0))
bool newTradingDay = ta.change(utcDay) != 0
if barstate.isconfirmed and newTradingDay and not na(testStartTime) and not na(markedEquity[1])
    float completedDayEquity = markedEquity[1]
    if not na(priorDayEndEquity) and priorDayEndEquity > 0
        float dailyReturn = completedDayEquity / priorDayEndEquity - 1.0
        dailyReturnSum += dailyReturn
        dailyReturnSquaredSum += dailyReturn * dailyReturn
        dailyReturnCount += 1
    priorDayEndEquity := completedDayEquity

float meanDailyReturn = dailyReturnCount > 0 ? dailyReturnSum / dailyReturnCount : na
float dailyReturnVariance = dailyReturnCount > 1 ? math.max((dailyReturnSquaredSum - dailyReturnCount * meanDailyReturn * meanDailyReturn) / (dailyReturnCount - 1), 0.0) : na
float dailyReturnDeviation = not na(dailyReturnVariance) ? math.sqrt(dailyReturnVariance) : na
float annualRiskFreeRate = 0.02
float dailyRiskFreeRate = math.pow(1.0 + annualRiskFreeRate, 1.0 / 252.0) - 1.0
float dailySharpe = dailyReturnCount > 1 and dailyReturnDeviation > 1e-10 ? (meanDailyReturn - dailyRiskFreeRate) / dailyReturnDeviation * math.sqrt(252.0) : na

string tickerUpper = str.upper(syminfo.ticker)
string rootUpper = str.upper(syminfo.root)
bool chartGold = str.contains(tickerUpper, "XAU") or str.contains(tickerUpper, "GOLD") or rootUpper == "GC" or rootUpper == "MGC"
bool chartSilver = str.contains(tickerUpper, "XAG") or str.contains(tickerUpper, "SILVER") or rootUpper == "SI" or rootUpper == "SIL"
bool pairChart = chartGold or chartSilver
int chartTimeframeSeconds = timeframe.in_seconds()
bool showTimeframeWarning = na(chartTimeframeSeconds) or chartTimeframeSeconds >= 600

bool goldLongEntry = pairEntryEvent and pairPosition == 1
bool goldShortEntry = pairEntryEvent and pairPosition == -1
bool silverLongEntry = pairEntryEvent and pairPosition == -1
bool silverShortEntry = pairEntryEvent and pairPosition == 1
bool goldLongExit = pairExitEvent and exitedPairDirection == 1
bool goldShortExit = pairExitEvent and exitedPairDirection == -1
bool silverLongExit = pairExitEvent and exitedPairDirection == -1
bool silverShortExit = pairExitEvent and exitedPairDirection == 1

float rawDisplayScore = chartSilver ? -combinedScore : combinedScore
// Visual smoothing only. Trading signals and all statistics continue to use the
// unsmoothed combinedScore, so this does not delay entries or exits.
float displayScore = ta.ema(rawDisplayScore, 3)
color positiveScoreColor = chartSilver ? silverColor : goldColor
color negativeScoreColor = chartSilver ? goldColor : silverColor
// A regular plot retains the complete chart history. Drawing one line object per
// bar would hit TradingView's 500-object limit and erase older oscillator data.
color scoreLineColor = displayScore >= 0 ? positiveScoreColor : negativeScoreColor
plot(displayScore, "Final pair score", color=scoreLineColor, linewidth=4, style=plot.style_line, display=display.pane)
plot(0.0, "Residual mean", color=color.new(neutralColor, 50), linewidth=1, display=display.pane)
plot(entryZ, "Long-side entry threshold", color=color.new(goldColor, 30), linewidth=1, style=plot.style_line, display=display.pane)
plot(-entryZ, "Short-side entry threshold", color=color.new(silverColor, 30), linewidth=1, style=plot.style_line, display=display.pane)
plot(exitZ, "Upper exit", color=color.new(neutralColor, 70), linewidth=1, style=plot.style_line, display=display.pane)
plot(-exitZ, "Lower exit", color=color.new(neutralColor, 70), linewidth=1, style=plot.style_line, display=display.pane)
color activePaneColor = chartSilver ? (pairPosition == -1 ? silverColor : goldColor) : (pairPosition == 1 ? goldColor : silverColor)
bgcolor(pairPosition != 0 ? color.new(activePaneColor, 94) : not correlationValid ? color.new(color.orange, 97) : na)

color markerGreen = color.rgb(0, 170, 75)
color markerRed = color.rgb(215, 25, 45)
float markerGap = math.max(nz(ta.atr(14)) * 0.35, syminfo.mintick * 16.0)
plotshape(chartGold and goldLongEntry ? low - markerGap : na, "Gold long entry", shape.triangleup, location.absolute, markerGreen, size=size.tiny, force_overlay=true, display=display.pane)
plotshape(chartGold and goldShortEntry ? high + markerGap : na, "Gold short entry", shape.triangledown, location.absolute, markerRed, size=size.tiny, force_overlay=true, display=display.pane)
plotshape(chartSilver and silverLongEntry ? low - markerGap : na, "Silver long entry", shape.triangleup, location.absolute, markerGreen, size=size.tiny, force_overlay=true, display=display.pane)
plotshape(chartSilver and silverShortEntry ? high + markerGap : na, "Silver short entry", shape.triangledown, location.absolute, markerRed, size=size.tiny, force_overlay=true, display=display.pane)
plotshape(chartGold and goldLongExit ? high + markerGap : na, "Gold long exit", shape.circle, location.absolute, markerGreen, size=size.tiny, force_overlay=true, display=display.pane)
plotshape(chartGold and goldShortExit ? low - markerGap : na, "Gold short exit", shape.circle, location.absolute, markerRed, size=size.tiny, force_overlay=true, display=display.pane)
plotshape(chartSilver and silverLongExit ? high + markerGap : na, "Silver long exit", shape.circle, location.absolute, markerGreen, size=size.tiny, force_overlay=true, display=display.pane)
plotshape(chartSilver and silverShortExit ? low - markerGap : na, "Silver short exit", shape.circle, location.absolute, markerRed, size=size.tiny, force_overlay=true, display=display.pane)
plotshape(pairChart and liquidationEvent ? high + markerGap * 1.6 : na, "Leverage liquidation", shape.xcross, location.absolute, markerRed, size=size.small, force_overlay=true, display=display.pane)

bool betaBlocked = not na(rollingBeta) and not betaValid
string positionText = liquidated ? "LIQUIDATED" : pairPosition == 0 ? (cooldownLeft > 0 ? "COOLDOWN" : betaBlocked or (not correlationValid and not na(correlation)) ? "BLOCKED" : na(combinedScore) ? "WARMUP" : "READY") : chartGold ? (pairPosition == 1 ? "LONG" : "SHORT") : chartSilver ? (pairPosition == 1 ? "SHORT" : "LONG") : pairPosition == 1 ? "GOLD LONG / SILVER SHORT" : "SILVER LONG / GOLD SHORT"
float currentPriceRatio = f_safeDiv(gClose, sClose)
float sizingBeta = pairPosition != 0 ? entryBeta : rollingBeta
float sizingPriceRatio = pairPosition != 0 ? entryPriceRatio : currentPriceRatio
float silverUnitsPerGold = not na(sizingBeta) and sizingBeta > 0 ? sizingPriceRatio / sizingBeta : na
string quantityText = "1 GOLD : " + f_fmt(silverUnitsPerGold, "0.00") + " SILVER"
float absoluteScore = math.abs(nz(combinedScore))
float signalStrengthRaw = absoluteScore <= entryZ ? 50.0 * f_safeDiv(absoluteScore, entryZ) : 50.0 + 50.0 * f_safeDiv(absoluteScore - entryZ, adverseZStop)
int signalStrength = int(math.round(math.max(0.0, math.min(100.0, nz(signalStrengthRaw)))))
string strengthText = str.tostring(signalStrength) + " / 100"
string tradesText = str.tostring(closedTrades)
string winText = closedTrades > 0 ? f_fmt(winRate, "0.0") + "% / W " + str.tostring(winningTrades) + " | L " + str.tostring(losingTrades) : "—"
string leverageText = f_fmt(leveragePct / 100.0, "0.0") + "X"
string returnText = liquidated ? "-100% / LIQUIDATED" : not na(cumulativeReturn) ? (cumulativeReturn > 0 ? "+" : "") + f_fmt(cumulativeReturn, "#.00") + "% / LEVERAGE " + leverageText : "— / LEVERAGE " + leverageText
string periodText = not na(testStartTime) ? str.format_time(testStartTime, "yyyy-MM-dd", syminfo.timezone) + " → " + str.format_time(time, "yyyy-MM-dd", syminfo.timezone) : "—"
string sharpeText = f_fmt(dailySharpe, "0.00")
int hudTextSize = 9

var table hud = table.new(position.top_left, 2, 9, bgcolor=color.new(color.black, 12), border_width=1, force_overlay=true)
// A two-row middle anchor keeps the warning clear of the top-left dashboard.
// The transparent spacer below shifts the visible warning slightly above center.
var table timeframeNotice = table.new(position.middle_center, 1, 2, frame_color=color.orange, frame_width=1, force_overlay=true)
if barstate.islast
    if not showTimeframeWarning
        table.clear(timeframeNotice, 0, 0, 0, 1)
        table.set_frame_color(timeframeNotice, color.new(color.orange, 100))
    else
        table.set_frame_color(timeframeNotice, color.orange)
        table.cell(timeframeNotice, 0, 0, "5MIN OR LOWER RECOMMENDED", text_color=color.orange, bgcolor=color.new(color.black, 5), text_size=size.normal)
        table.cell(timeframeNotice, 0, 1, "", bgcolor=color.new(color.black, 100), height=5)
    table.cell(hud, 0, 0, "GOLD/SILVER", text_color=color.white, bgcolor=color.new(color.orange, 35), text_size=hudTextSize)
    table.cell(hud, 1, 0, "ARBITRAGE SCALPER", text_color=color.white, bgcolor=color.new(color.orange, 55), text_size=hudTextSize)
    table.cell(hud, 0, 1, "STATUS", text_color=color.white, text_size=hudTextSize)
    table.cell(hud, 1, 1, positionText, text_color=positionText == "LONG" ? bullColor : positionText == "SHORT" or positionText == "LIQUIDATED" ? bearColor : positionText == "READY" ? bullColor : color.orange, text_size=hudTextSize)
    table.cell(hud, 0, 2, "SIGNAL STRENGTH", text_color=color.white, text_size=hudTextSize)
    table.cell(hud, 1, 2, strengthText, text_color=signalStrength >= 50 ? color.orange : color.white, text_size=hudTextSize)
    table.cell(hud, 0, 3, "POSITION SIZE", text_color=color.white, text_size=hudTextSize)
    table.cell(hud, 1, 3, quantityText, text_color=color.white, text_size=hudTextSize)
    table.cell(hud, 0, 4, "CLOSED TRADES", text_color=color.white, text_size=hudTextSize)
    table.cell(hud, 1, 4, tradesText, text_color=color.white, text_size=hudTextSize)
    table.cell(hud, 0, 5, "WIN RATE", text_color=color.white, text_size=hudTextSize)
    table.cell(hud, 1, 5, winText, text_color=closedTrades > 0 and winRate >= 50 ? bullColor : color.orange, text_size=hudTextSize)
    table.cell(hud, 0, 6, "SHARPE (DAILY MTM)", text_color=color.white, text_size=hudTextSize)
    table.cell(hud, 1, 6, sharpeText, text_color=na(dailySharpe) ? color.gray : dailySharpe >= 1.0 ? bullColor : dailySharpe >= 0 ? color.orange : bearColor, text_size=hudTextSize)
    table.cell(hud, 0, 7, "CUMULATIVE RETURN", text_color=color.white, text_size=hudTextSize)
    table.cell(hud, 1, 7, returnText, text_color=liquidated ? bearColor : na(cumulativeReturn) ? color.gray : cumulativeReturn >= 0 ? bullColor : bearColor, text_size=hudTextSize)
    table.cell(hud, 0, 8, "TRADING PERIOD", text_color=color.white, text_size=hudTextSize)
    table.cell(hud, 1, 8, periodText, text_color=color.white, text_size=hudTextSize)

alertcondition(pairEntryEvent and pairPosition == 1, "Long Gold / Short Silver", "Combined return-residual and price-ratio score high: long Gold and short Silver using the locked beta hedge ratio.")
alertcondition(pairEntryEvent and pairPosition == -1, "Long Silver / Short Gold", "Combined return-residual and price-ratio score low: long Silver and short Gold using the locked beta hedge ratio.")
alertcondition(pairExitEvent, "Gold-Silver pair EXIT", "Combined pair score mean-reverted, correlation/beta invalidated, adverse Z-stop hit, or maximum holding time expired.")
alertcondition(liquidationEvent, "Gold-Silver pair LIQUIDATED", "Leveraged pair loss reached 100% of allocated equity. Trading is halted until the indicator is reset.")
````
