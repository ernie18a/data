# 30 Min Pivot 

- url: https://www.tradingview.com/script/refbFy4d-30-Min-Pivot/
- type: indicator
- pine_id: PUB;0fbb5e0b2abd4aeba35036c5e27f3716
- version: 3.0

## Description

Overview
The 30 Min Pivot Pullback Strategy is an execution toolkit designed for momentum and swing traders. Inspired by Mark Minervini's Volatility Contraction Pattern (VCP), William O'Neil's CANSLIM principles, and Patrick Walker's moving average pullback framework, this tool bridges the gap between daily macro trend identification and precise 30-minute intraday execution.

Rather than chasing extended breakout moves, this system identifies Stage 2 market leaders undergoing orderly, low-volume consolidations into key dynamic support (Daily 8 & 21 EMA) and automates entry, risk definition, and target projections.

Key Features
30-Minute Tactical Setup Engine:

Tracks constructive pullbacks touching Daily 8 & 21 EMA support levels.

Filters for supply dry-up conditions (low pullback volume / exhaustion).

Automatically tags qualifying setups with chronological badges (SETUP 1, SETUP 2).

Dynamic Risk & Execution Levels:

BUY: Placed at the trigger bar's high.

SL: Anchored to the structural low of the trigger bar, complete with exact price and dynamic risk percentage (Risk %).

T1 (+2R): Dashed line projecting a 2:1 reward-to-risk ratio.

T2 (Swing High): Trailing target anchored to recent 10-day swing highs.

Unified RS Engine with Leading Blue Dots:

Benchmarks price action directly against NSE:CNX500 (or chosen index).

Cyan Circles (Leading RS Dots): Highlights when Relative Strength reaches a 40-bar high before the stock's price breaks out—signaling institutional accumulation.

Blue Circles (Confirmed RS Dots): Flags simultaneous price and RS new highs.

Anchored between the 50 and 150 SMAs directly on the price chart to save vertical pane space.

Daily Metric Dashboard (A+ Setup Auditor):

Evaluates 10 structural metrics on the daily timeframe:

Setup Quality: Automated grading (A+ HEALTHY, MODERATE, TRAP/AVOID) based on duration, volume dry-up, wick rejection, and trend alignment.

Consolidation Duration: Flags ideal 3–8 day digestions vs. stale extensions.

Overhead Supply: Detects upper trap wicks exceeding 40% of the daily candle range.

Liquidity & Float: Classifies float profile based on share count or Rupee turnover.

Volume Buzz & Up/Down Ratio: Measures 50-day accumulation vs. distribution volume.

Intraday ADR% HUD:

Displays real-time 20-day Average Daily Range (ADR%) in the bottom-right corner.

Categorizes market velocity (Fast Leader, Moderate, Slow Range, High Vol / Downtrend) to confirm if the asset has enough daily velocity to reach +2R targets.

How to Use
Daily Screening: Identify Stage 2 market leaders with strong fundamentals and top industry group ranking resting near their rising Daily 8 or 21 EMA.

Setup Identification: Switch to the 30-minute chart. Ensure there is clear overhead space between entry and Target 1 (no descending 50/200 SMAs blocking the runway).

Trigger & Order Entry: When a SETUP badge prints, place a buy-stop at the labeled BUY price and an initial stop-loss at the labeled SL price.

Trade Management: Lock in partial gains at Target 1 (+2R) and trail the remaining position with a breakeven stop toward Target 2 (Swing High).

Credits & Methodology
Special acknowledgment to the momentum trading frameworks shared by Sean (@SRxTrades) and @1ChartMaster (Elite Swing Trading), whose tactical moving average pullback setups and execution clarity inspired this Pine Script implementation.

## Source Code

````pine
//@version=6
indicator("30 Min Pivot", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 1. TIMEFRAME & SESSION DETECTION
// ==========================================
isWeeklyOrHigher = (timeframe.isweekly or timeframe.ismonthly or (timeframe.isminutes and timeframe.multiplier >= 10080))
isDailyOrLower   = not isWeeklyOrHigher
isExact30m       = timeframe.isminutes and timeframe.multiplier == 30
isExactDaily     = timeframe.isdaily
isHigherTF       = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly

isInNseSession   = not na(time(timeframe.period, "0915-1530:23456", "Asia/Kolkata"))
int nseDayAnchor = time("D", "0915-1530:23456", "Asia/Kolkata")
bool isNewIseDay = ta.change(nz(nseDayAnchor, time("D", "Asia/Kolkata"))) != 0

bool isFirstSessionBar = isInNseSession and (hour(time, "Asia/Kolkata") == 9 and minute(time, "Asia/Kolkata") == 15)

var float todaySessionLow  = na
var int   sessionBarsCount = 0

if isNewIseDay
    sessionBarsCount := isFirstSessionBar ? 1 : (isInNseSession ? 1 : 0)
    todaySessionLow  := low
else if isInNseSession
    sessionBarsCount := isFirstSessionBar ? 1 : sessionBarsCount + 1
    todaySessionLow  := sessionBarsCount == 1 ? low : math.min(nz(todaySessionLow, low), low)

var bool d21ResetDoneToday = false
if isNewIseDay
    d21ResetDoneToday := false

// ==========================================
// 1.1 RISK MANAGEMENT & UNIFIED POSITION SIZER
// ==========================================
grpRisk             = "Portfolio Risk Management & Position Sizer"
acctCapital         = input.float(15000.0, "Total Portfolio Capital (₹)", group=grpRisk, step=5000.0)
maxRiskRs           = input.float(250.0,   "Per-Trade Fixed Max Risk (₹)", group=grpRisk, step=50.0)
enforceMinRRR       = input.bool(true,     "Enforce Minimum 2R to Overhead Resistance (Trend Mode)?", group=grpRisk)
enforceEma21Res     = input.bool(true,     "-> Treat 21 EMA as Resistance?", group=grpRisk)
enforceSma50Res     = input.bool(true,     "-> Treat 50 SMA as Resistance?", group=grpRisk)
enforceMajorMaRes   = input.bool(true,     "-> Treat Major MAs (150 SMA / 200 SMA) as Resistance?", group=grpRisk)
maxGapRiskMult      = input.float(1.0,     "Max Allowable Gap Risk Multiplier (Cancel if gap > N * Risk)", minval=0.5, maxval=2.5, step=0.25, group=grpRisk)

grpTrail            = "Runner Trailing Stop Management"
trailEmaSource      = input.string("Chart (30m 8 EMA)", "Runner Trailing EMA Reference", options=["Chart (30m 8 EMA)", "Daily (Daily 8 EMA)"], group=grpTrail)
skipFirst30mBar     = input.bool(true,     "Ignore Opening 30m Candle Trail Violations (Shakeout Filter)", group=grpTrail)

grpPending          = "Pending Orders & Expirations (Unfilled / EOD)"
expireEndOfDay      = input.bool(false,    "Expire Active Trades at Day End (15:30 IST)? [Keep OFF for CNC Swing]", group=grpPending)
maxUnfilledBars     = input.int(4,         "Max 30m Bars Pending Before Timeout (Unfilled)", minval=1, maxval=10, group=grpPending)
showUnfilledLabels  = input.bool(true,     "Show 'UNFILLED' / 'CANCEL' / 'EXPIRED' Badges", group=grpPending)

// ==========================================
// 1.2 DASHBOARD SETTINGS
// ==========================================
grpDash         = "Dashboard & Visual Settings"
showMainDash    = input.bool(true,  "Show Higher-TF Checklist Dashboard", group=grpDash)
showMktHud      = input.bool(true,  "Show Market Status HUD (All Timeframes)", group=grpDash)
showTrendHist   = input.bool(true,  "Show Historical Trend Setups", group=grpDash)
showPDH         = input.bool(true,  "Show Previous Day's High (PDH)?", group=grpDash)
showPDL         = input.bool(true,  "Show Previous Day's Low (PDL)?", group=grpDash)
indexTicker     = input.symbol("NSE:NIFTY", "Market Benchmark Symbol", group=grpDash)
dashPosInput    = input.string("Middle Right", "Order / Checklist Dashboard Position", options=["Middle Right", "Top Right", "Bottom Right"], group=grpDash)
mktTablePos     = input.string("Top Left", "Market Status Position", options=["Top Left", "Middle Left", "Bottom Left"], group=grpDash)
showMaLabels    = input.bool(true,  "Show Moving Average Edge Labels (8, 21, 50...)", group=grpDash)

var mainTblPos = position.middle_right
if dashPosInput == "Top Right"
    mainTblPos := position.top_right
else if dashPosInput == "Bottom Right"
    mainTblPos := position.bottom_right
else
    mainTblPos := position.middle_right

var mktTblPos = position.top_left
if mktTablePos == "Middle Left"
    mktTblPos := position.middle_left
else if mktTablePos == "Bottom Left"
    mktTblPos := position.bottom_left
else
    mktTblPos := position.top_left

// ==========================================
// 2. TRUE HORIZONTAL 52-WEEK HIGH & SWING HIGH (IPO INTEGRATED)
// ==========================================
f_getIpoHigh() =>
    var float maxH = na
    maxH := na(maxH) ? high : math.max(maxH, high)
    maxH

[current52WH, rawIpoHigh, d_swingHigh] = request.security(syminfo.tickerid, "D", [ta.highest(high, 252), f_getIpoHigh(), ta.highest(high, 10)], barmerge.gaps_off, barmerge.lookahead_off)
float effective52WH = not na(current52WH) ? current52WH : rawIpoHigh

var line  line_52w   = na
var label lbl_52w    = na
var line  line_swing = na
var label lbl_swing  = na
var line  line_pdh   = na
var label lbl_pdh    = na
var line  line_pdl   = na
var label lbl_pdl    = na

// ==========================================
// 3. ADAPTIVE MOVING AVERAGES & LABELS
// ==========================================
chart_ema8   = ta.ema(close, 8)
chart_ema21  = ta.ema(close, 21)

chart_sma50  = bar_index >= 50  ? ta.sma(close, 50)  : ta.sma(close, math.max(1, bar_index + 1))
chart_sma150 = bar_index >= 150 ? ta.sma(close, 150) : na
chart_sma200 = bar_index >= 200 ? ta.sma(close, 200) : na

chart_sma10  = bar_index >= 10  ? ta.sma(close, 10)  : ta.sma(close, math.max(1, bar_index + 1))
chart_sma30  = bar_index >= 30  ? ta.sma(close, 30)  : na
chart_sma40  = bar_index >= 40  ? ta.sma(close, 40)  : na

f_adaptiveVolMa(int len) =>
    ta.sma(volume, math.min(len, math.max(1, bar_index + 1)))

[daily_ema8, daily_ema21, daily_volMA, daily_atr] = request.security(syminfo.tickerid, "D", [ta.ema(close[1], 8), ta.ema(close[1], 21), f_adaptiveVolMa(20), ta.atr(14)], barmerge.gaps_off, barmerge.lookahead_off)

plot(isDailyOrLower ? chart_ema8   : na, title="8 EMA",   color=color.orange, linewidth=1, display=display.all)
plot(isDailyOrLower ? chart_ema21  : na, title="21 EMA",  color=color.purple, linewidth=1, display=display.all)
plot(isDailyOrLower ? chart_sma50  : na, title="50 SMA",  color=color.blue,   linewidth=1, display=display.all)
plot(isDailyOrLower ? chart_sma150 : na, title="150 SMA", color=color.green,  linewidth=1, display=display.all)
plot(isDailyOrLower ? chart_sma200 : na, title="200 SMA", color=color.red,    linewidth=1, display=display.all)

plot(isWeeklyOrHigher ? chart_ema8  : na, title="W-8 EMA",  color=color.orange, linewidth=1, display=display.all)
plot(isWeeklyOrHigher ? chart_ema21 : na, title="W-21 EMA", color=color.purple, linewidth=1, display=display.all)
plot(isWeeklyOrHigher ? chart_sma10 : na, title="W-10 SMA", color=color.blue,   linewidth=1, display=display.all)
plot(isWeeklyOrHigher ? chart_sma30 : na, title="W-30 SMA", color=color.green,  linewidth=1, display=display.all)
plot(isWeeklyOrHigher ? chart_sma40 : na, title="W-40 SMA", color=color.red,    linewidth=1, display=display.all)

var label lbl_ma_8   = na
var label lbl_ma_21  = na
var label lbl_ma_50  = na
var label lbl_ma_150 = na
var label lbl_ma_200 = na

if barstate.islast
    label.delete(lbl_ma_8)
    label.delete(lbl_ma_21)
    label.delete(lbl_ma_50)
    label.delete(lbl_ma_150)
    label.delete(lbl_ma_200)

    if showMaLabels
        if not na(chart_ema8)
            lbl_ma_8 := label.new(bar_index + 2, chart_ema8, "8", color=color.orange, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        if not na(chart_ema21)
            lbl_ma_21 := label.new(bar_index + 2, chart_ema21, "21", color=color.purple, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        
        float val50 = isHigherTF and not isExactDaily ? chart_sma10 : chart_sma50
        if not na(val50)
            lbl_ma_50 := label.new(bar_index + 2, val50, isHigherTF and not isExactDaily ? "10" : "50", color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        
        float val150 = isHigherTF and not isExactDaily ? chart_sma30 : chart_sma150
        if not na(val150)
            lbl_ma_150 := label.new(bar_index + 2, val150, isHigherTF and not isExactDaily ? "30" : "150", color=color.green, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        
        float val200 = isHigherTF and not isExactDaily ? chart_sma40 : chart_sma200
        if not na(val200)
            lbl_ma_200 := label.new(bar_index + 2, val200, isHigherTF and not isExactDaily ? "40" : "200", color=color.red, textcolor=color.white, style=label.style_label_left, size=size.tiny)

// ==========================================
// 4. RELATIVE STRENGTH (RS ENGINE - PRICE-ANCHORED)
// ==========================================
rsBenchmark    = input.string("NSE:CNX500", title="RS Comparison Index", options=["NSE:CNX500", "NSE:NIFTY", "NSE:NIFTYSMLCAP250", "NSE:CNXSMALLCAP"], group="Relative Strength")
rsLookbackBars = input.int(40, title="RS New High Lookback Bars", minval=10, maxval=100, group="Relative Strength")
rsSmooth       = input.int(60, title="RS Baseline Window", group="Relative Strength")

benchClose = request.security(rsBenchmark, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
benchCloseClean = not na(benchClose) and benchClose > 0 ? benchClose : nz(benchClose[1], close)
rawRsRatio = benchCloseClean > 0 ? (close / benchCloseClean) : 1.0

float rsBase = not na(chart_ema21) ? chart_ema21 : close
float rsFloor = rsBase * 0.94
float rsCeiling = rsBase * 0.98
float rsSpan = math.max(rsCeiling - rsFloor, syminfo.mintick * 10)

rsRatioMax = ta.highest(rawRsRatio, rsSmooth)
rsRatioMin = ta.lowest(rawRsRatio, rsSmooth)

float normRS = na
if not na(rawRsRatio) and (rsRatioMax != rsRatioMin)
    normRS := rsFloor + ((rawRsRatio - rsRatioMin) / (rsRatioMax - rsRatioMin)) * rsSpan
else
    normRS := (rsCeiling + rsFloor) / 2.0

rsSlopeUp = rawRsRatio >= nz(rawRsRatio[1], rawRsRatio)
color rsLineColor = rsSlopeUp ? #00C853 : #D50000

plot(normRS, title="Unified RS Line", color=rsLineColor, linewidth=2, display=display.all)

rsHighestPast = ta.highest(rawRsRatio[1], rsLookbackBars)
prHighestPast = ta.highest(high[1], rsLookbackBars)

isRsAtNewHigh    = rawRsRatio > rsHighestPast
isPriceAtNewHigh = high > prHighestPast
isLeadingRsDot   = isRsAtNewHigh and not isPriceAtNewHigh

color leadingDotColor = #00E5FF
plot(isLeadingRsDot ? normRS : na, title="Leading RS Dot (Before Price)", style=plot.style_circles, linewidth=5, color=leadingDotColor, display=display.all)
plot((isRsAtNewHigh and isPriceAtNewHigh) ? normRS : na, title="Confirmed RS High Dot", style=plot.style_circles, linewidth=3, color=#0070F3, display=display.all)

// ==========================================
// 5. DAILY CHECKLIST METRICS DATA (TIMEFRAME-AWARE & REPAINT SAFE)
// ==========================================
f_getDailyPeakOffset() =>
    int rawOffset = ta.highestbars(high[1], 30)
    bar_index < 30 or na(rawOffset) ? 0 : math.max(1, math.abs(rawOffset))

[dHigh, dLow, dClose, dOpen, dVol, secH1, secC1, secO1, secL1, sumUpVol, sumDnVol, dailyTurnoverVal, volMA50, d_barsSincePeak] = request.security(syminfo.tickerid, "D", [high, low, close, open, volume, high[1], close[1], open[1], low[1], math.sum(close[1] > close[2] ? volume[1] : 0.0, 50), math.sum(close[1] < close[2] ? volume[1] : 0.0, 50), ta.sma(volume * close, 50) / 10000000.0, f_adaptiveVolMa(50), f_getDailyPeakOffset()], barmerge.gaps_off, barmerge.lookahead_off)

// Render 52WH, Swing High, PDH, and PDL lines on the last bar
if barstate.islast
    line.delete(line_52w)
    label.delete(lbl_52w)
    line.delete(line_swing)
    label.delete(lbl_swing)
    line.delete(line_pdh)
    label.delete(lbl_pdh)
    line.delete(line_pdl)
    label.delete(lbl_pdl)

    int safeX1 = math.max(0, bar_index - 60)
    int safeLabelOffset = math.min(10, math.max(2, bar_index / 4))
    bool isSameLevel = not na(d_swingHigh) and not na(effective52WH) and (math.abs(effective52WH - d_swingHigh) / effective52WH < 0.0075)

    if isSameLevel
        line_52w := line.new(safeX1, effective52WH, bar_index + safeLabelOffset, effective52WH, color=color.red, width=1, style=line.style_solid, extend=extend.right)
        lbl_52w  := label.new(bar_index + math.max(2, safeLabelOffset - 4), effective52WH, "52WH / SWING HIGH: " + str.tostring(effective52WH, "#.00"), color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_lower_left, size=size.tiny)
    else
        line_52w := line.new(safeX1, effective52WH, bar_index + safeLabelOffset, effective52WH, color=color.red, width=1, style=line.style_solid, extend=extend.right)
        lbl_52w  := label.new(bar_index + safeLabelOffset, effective52WH, "52WH: " + str.tostring(effective52WH, "#.00"), color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_lower_left, size=size.tiny)

        if not na(d_swingHigh)
            line_swing := line.new(safeX1, d_swingHigh, bar_index + safeLabelOffset, d_swingHigh, color=color.maroon, width=1, style=line.style_dashed, extend=extend.right)
            lbl_swing  := label.new(bar_index + math.max(2, safeLabelOffset - 4), d_swingHigh, "SWING HIGH: " + str.tostring(d_swingHigh, "#.00"), color=color.new(color.white, 100), textcolor=color.maroon, style=label.style_label_lower_left, size=size.tiny)

    // Plot Previous Day's High (PDH) Line
    if showPDH and not na(secH1)
        line_pdh := line.new(safeX1, secH1, bar_index + safeLabelOffset, secH1, color=color.navy, width=1, style=line.style_dashed, extend=extend.right)
        lbl_pdh  := label.new(bar_index + safeLabelOffset, secH1, "PDH: " + str.tostring(secH1, "#.00"), color=color.new(color.white, 100), textcolor=color.navy, style=label.style_label_lower_left, size=size.tiny)

    // Plot Previous Day's Low (PDL) Line
    if showPDL and not na(secL1)
        line_pdl := line.new(safeX1, secL1, bar_index + safeLabelOffset, secL1, color=color.maroon, width=1, style=line.style_dashed, extend=extend.right)
        lbl_pdl  := label.new(bar_index + safeLabelOffset, secL1, "PDL: " + str.tostring(secL1, "#.00"), color=color.new(color.white, 100), textcolor=color.maroon, style=label.style_label_upper_left, size=size.tiny)

bool isBreakoutRun     = not na(d_swingHigh) and close >= (d_swingHigh * 0.99)
bool isIpoStock        = na(d_barsSincePeak) or d_barsSincePeak == 0
bool isHealthyDuration = not isIpoStock and ((d_barsSincePeak >= 3 and d_barsSincePeak <= 8) or isBreakoutRun)
bool isDailyRed        = dClose < dOpen
bool isHealthyVolDry   = not isDailyRed or (dVol <= daily_volMA * 1.05)

d_prevHigh  = secH1
d_prevClose = secC1
d_prevOpen  = secO1
d_prevLow   = secL1

safeDailyAtr    = nz(daily_atr, math.max(ta.atr(14), close * 0.015))
atrBuffer       = safeDailyAtr * 0.75

d_prevRange     = math.max(d_prevHigh - d_prevLow, syminfo.mintick)
d_prevUpperWick = d_prevHigh - math.max(d_prevClose, d_prevOpen)
hasHeavyWick    = (d_prevRange > safeDailyAtr * 0.20) and ((d_prevUpperWick / d_prevRange) >= 0.40)

dailyTrendUp = not na(daily_ema8) and not na(daily_ema21) ? (daily_ema8 >= (daily_ema21 * 0.990)) : true

int qualityScore = 0
if isHealthyDuration
    qualityScore += 1
if isHealthyVolDry
    qualityScore += 1
if not hasHeavyWick
    qualityScore += 1
if dailyTrendUp
    qualityScore += 1

string setupGrade = qualityScore >= 3 ? "A+ HEALTHY" : (qualityScore == 2 ? "MODERATE" : "TRAP / AVOID")
color  gradeColor = qualityScore >= 3 ? color.lime : (qualityScore == 2 ? color.yellow : color.red)

bool  isTrue52W      = not na(current52WH) and current52WH > 0
bool  has52WData     = not na(effective52WH) and effective52WH > 0
float pctOff52WH     = has52WData ? ((close - effective52WH) / effective52WH) * 100.0 : 0.0
string pctOff52WHTxt = not has52WData ? "N/A (No Data)" : 
     not isTrue52W ? (str.tostring(pctOff52WH, "0.0") + "% (IPO High)") : 
     ((pctOff52WH > 0 ? "+" : "") + str.tostring(pctOff52WH, "0.0") + "%" + (pctOff52WH > 0 ? " (Breakout)" : ""))
color  pctOff52WHCol = not has52WData ? color.gray : pctOff52WH > 0 ? color.lime : (pctOff52WH >= -3.0 ? color.yellow : color.white)

bool hasValidVolume = not na(dVol) and dVol > 0 and nz(volMA50) > 0

int nseSessionMins      = 375
bool isLiveFormingBar   = barstate.islast and (year(time, "Asia/Kolkata") == year(timenow, "Asia/Kolkata")) and (month(time, "Asia/Kolkata") == month(timenow, "Asia/Kolkata")) and (dayofmonth(time, "Asia/Kolkata") == dayofmonth(timenow, "Asia/Kolkata"))
bool isLiveTradingNow   = isLiveFormingBar and isInNseSession
bool isLiveDailySession = isExactDaily and barstate.islast and isLiveFormingBar and isInNseSession

int liveHour            = (isLiveTradingNow or isLiveDailySession) ? hour(timenow, "Asia/Kolkata") : hour(time, "Asia/Kolkata")
int liveMin             = (isLiveTradingNow or isLiveDailySession) ? minute(timenow, "Asia/Kolkata") : minute(time, "Asia/Kolkata")
int rawElapsedMins      = (liveHour - 9) * 60 + liveMin - 15
int elapsedMins         = math.max(1, math.min(nseSessionMins, rawElapsedMins))

bool isPreMarketToday   = barstate.islast and isLiveFormingBar and (hour(timenow, "Asia/Kolkata") < 9 or (hour(timenow, "Asia/Kolkata") == 9 and minute(timenow, "Asia/Kolkata") < 15))
float sessionProgress   = isPreMarketToday ? 1.0 : (isLiveTradingNow or isLiveDailySession) ? math.max(1.0 / float(nseSessionMins), elapsedMins / float(nseSessionMins)) : 1.0
float expectedVolToNow  = volMA50 * sessionProgress

bool canCalcBuzz   = hasValidVolume and expectedVolToNow > 0 and not isPreMarketToday
float volBuzz      = canCalcBuzz ? 100.0 * (dVol / expectedVolToNow - 1.0) : 0.0
color volBuzzColor = isPreMarketToday ? color.gray : not canCalcBuzz ? color.gray : (volBuzz >= 20.0 ? color.lime : (volBuzz >= -20.0 ? color.yellow : color.red))
string volBuzzText = isPreMarketToday ? "Pre-Market / Off-Hours" : not hasValidVolume ? "N/A (No Vol)" : not canCalcBuzz ? "Calculating..." : ((volBuzz > 0 ? "+" : "") + str.tostring(volBuzz, "0") + "%")

upDnRatio = nz(sumDnVol) > 0 ? (sumUpVol / sumDnVol) : 1.0

string liqText  = na(dailyTurnoverVal) ? "Moderate" : dailyTurnoverVal >= 50.0 ? "High Liq (₹" + str.tostring(dailyTurnoverVal, "0") + "Cr)" : dailyTurnoverVal >= 15.0 ? "Mid Liq (₹" + str.tostring(dailyTurnoverVal, "0") + "Cr)" : "Thin / Illiquid"
color  liqColor = na(dailyTurnoverVal) ? color.yellow : dailyTurnoverVal >= 50.0 ? color.lime : dailyTurnoverVal >= 15.0 ? color.yellow : color.red

// ==========================================
// 6. REACTION & BOUNCE ENGINE
// ==========================================
grpSetups          = "Setup Limits & Filters"
restrictMaxSetups  = input.bool(false, title="Restrict Max Setup Triggers Per Wave?", group=grpSetups)
maxAllowedSetups   = input.int(3,     title="Max Setups Allowed (If Restrict Enabled)", minval=1, maxval=10, group=grpSetups)
recentSetupsToKeep = input.int(2,     title="Recent Historical Setups to Display on Chart", minval=1, maxval=50, group=grpSetups)
requireVolDryUp    = input.bool(false, title="Enforce Strict Volume Dry-Up on Pullback?", group=grpSetups)

d_bandUpper = math.max(nz(daily_ema8, close), nz(daily_ema21, close))
d_bandLower = math.min(nz(daily_ema8, close), nz(daily_ema21, close))

bool isTestingDaily8EMA = (low <= (daily_ema8 + atrBuffer * 0.65) and low >= (daily_ema8 - atrBuffer)) or (low < (daily_ema8 - atrBuffer) and close >= (daily_ema8 - atrBuffer))
bool isPriceNear21Base   = (low <= (daily_ema21 + atrBuffer * 0.65) and low >= (daily_ema21 - atrBuffer) and (low < daily_ema8 or daily_ema8 <= daily_ema21))
bool isTestingDaily21EMA = isPriceNear21Base or (low < (daily_ema21 - atrBuffer) and close >= (daily_ema21 - atrBuffer))
bool isInsideDailyBand   = (close >= (d_bandLower - atrBuffer) and close <= (d_bandUpper + atrBuffer))

bool didUndercutPriorDayLow = not na(d_prevLow) and (todaySessionLow < d_prevLow or low < d_prevLow)
bool isNearReclaimLevel     = not na(d_prevLow) and (math.abs(close - d_prevLow) <= (atrBuffer * 0.75))
bool isReclaimingPriorLow   = didUndercutPriorDayLow and (close >= d_prevLow) and isNearReclaimLevel

bool isAtCoreDailySupport = dailyTrendUp and (isTestingDaily8EMA or isTestingDaily21EMA or isInsideDailyBand or isReclaimingPriorLow)

bool isGreenCandle       = close > open
bool isRedCandle         = close < open
bool isFirstGreenAfterRed = isGreenCandle and isRedCandle[1]

bool isTestingChartEma8  = low <= chart_ema8 and close >= chart_ema8
bool isTestingChartEma21 = low <= chart_ema21 and close >= chart_ema21
bool isBounceSupport     = isTestingChartEma8 or isTestingChartEma21 or isAtCoreDailySupport

bool isOpeningBar30m        = isExact30m and (sessionBarsCount == 1)
bool isConfirmed30mReaction = isGreenCandle and (isFirstGreenAfterRed or isBounceSupport or not isOpeningBar30m)

var int setupCount        = 0
var int lastExitBarIndex  = na

var line  activeEntryLine = na
var line  activeStopLine  = na
var line  activeT1Line    = na
var line  activeT2Line    = na
var label activeEntryLabel= na
var label activeStopLabel = na
var label activeT1Label   = na
var label activeT2Label   = na
var label activeSetupBadge= na
var line  activeAnchorStem= na
var label activeT1HitBadge= na
var label expTermLbl      = na

var float currentEntry      = na
var float currentStop       = na
var float currentRiskPct    = na
var float currentT1         = na
var float currentT2         = na
var float initialRiskDist   = na
var float actualFillPrice   = na
var int   setupBarIndex     = na
var int   fillBarIndex      = na
var int   setupSessionTime  = na
var bool  isTradeActive     = false
var bool  isSetupPending    = false
var bool  t1Achieved        = false
var int   t1HitBar          = na
var int   activeOrderQty    = 0

var bool alertT1Triggered        = false
var bool alertExitTriggered      = false
var bool barHadT1Alert           = false
var bool barHadTradeExitAlert    = false

var bool wasTradeStoppedThisBar  = false
var bool wasTradeT2HitThisBar    = false

if ta.change(time) != 0
    barHadT1Alert            := false
    barHadTradeExitAlert     := false
    wasTradeStoppedThisBar   := false
    wasTradeT2HitThisBar     := false

f_safeDeleteLine(line ln) =>
    if not na(ln)
        line.delete(ln)
    line(na)

f_safeDeleteLabel(label lbl) =>
    if not na(lbl)
        label.delete(lbl)
    label(na)

bool doResetTradeState = false
bool isNewSwingHigh    = not na(d_swingHigh) and high > d_swingHigh

int  barsSinceLastD21Test = ta.barssince(isTestingDaily21EMA)

bool isAwayFromD21Band = math.abs(close - nz(daily_ema21, close)) > atrBuffer
if isAwayFromD21Band
    d21ResetDoneToday := false

bool wasAwayFromD21      = (not na(barsSinceLastD21Test[1]) and barsSinceLastD21Test[1] >= 6) or (isNewIseDay and math.abs(open - nz(daily_ema21, open)) > atrBuffer)
bool isEligibleD21Reset = isTestingDaily21EMA and wasAwayFromD21 and not d21ResetDoneToday
bool isFreshD21Retest   = isEligibleD21Reset

bool canResetWave = not isTradeActive and not isSetupPending
if canResetWave and (isNewSwingHigh or isFreshD21Retest)
    setupCount := 0
    if isNewSwingHigh
        d21ResetDoneToday := false
    else if isEligibleD21Reset
        d21ResetDoneToday := true

// ==========================================
// UNIFIED GRAPHIC MANAGEMENT (TRUE TERMINAL OUTCOME ARCHIVING)
// ==========================================
type SetupPackage
    label[] labels
    int     trigBar
    int     exitBar
    float   entryPrice
    float   stopPrice
    float   t1Price
    float   t2Price

var SetupPackage[] histPackages    = array.new<SetupPackage>()
var SetupPackage[] timeoutPackages = array.new<SetupPackage>()
var label[] currLabels             = array.new<label>()
var int   currTrigBar              = na
var int   currExitBar              = na
var float currEntryPrice           = na
var float currStopPrice            = na
var float currT1Price              = na
var float currT2Price              = na

f_trackGraphic(label lbl) =>
    if isExact30m
        if not na(lbl) and not array.includes(currLabels, lbl)
            array.push(currLabels, lbl)

f_archiveCurrentSetup(label termLbl = na, bool forceArchive = false, bool isTimeoutPkg = false) =>
    if not na(termLbl) and not array.includes(currLabels, termLbl)
        array.push(currLabels, termLbl)
    bool canArchive = isExact30m and (forceArchive or barstate.isconfirmed or barstate.ishistory)
    if canArchive and (array.size(currLabels) > 0 or not na(currEntryPrice))
        int determinedExitBar = nz(currExitBar, bar_index)
        pkg = SetupPackage.new(array.copy(currLabels), nz(currTrigBar, bar_index - 5), determinedExitBar, nz(currEntryPrice, close), nz(currStopPrice, low), nz(currT1Price, close), nz(currT2Price, close))
        array.clear(currLabels)
        
        if isTimeoutPkg
            array.push(timeoutPackages, pkg)
            while array.size(timeoutPackages) > recentSetupsToKeep
                oldTimeout = array.shift(timeoutPackages)
                if not na(oldTimeout) and array.size(oldTimeout.labels) > 0
                    for i = 0 to array.size(oldTimeout.labels) - 1
                        label.delete(array.get(oldTimeout.labels, i))
                    array.clear(oldTimeout.labels)
        else
            array.push(histPackages, pkg)
            while array.size(histPackages) > recentSetupsToKeep
                oldPkg = array.shift(histPackages)
                if not na(oldPkg) and array.size(oldPkg.labels) > 0
                    for i = 0 to array.size(oldPkg.labels) - 1
                        label.delete(array.get(oldPkg.labels, i))
                    array.clear(oldPkg.labels)

// Render historical setup packages ensuring intermediate T1 milestones don't prematurely close lines
if barstate.islast and showTrendHist
    if array.size(histPackages) > 0
        for i = 0 to array.size(histPackages) - 1
            pkg = array.get(histPackages, i)
            if not na(pkg)
                int   pX1 = pkg.trigBar
                int   pX2 = math.max(pX1 + 2, pkg.exitBar)
                float pEn = pkg.entryPrice
                float pSt = pkg.stopPrice
                float pT1 = pkg.t1Price
                float pT2 = pkg.t2Price

                if not na(pEn)
                    line.new(pX1, pEn, pX2, pEn, color=color.teal, width=2, style=line.style_solid)
                if not na(pSt)
                    line.new(pX1, pSt, pX2, pSt, color=color.red, width=2, style=line.style_solid)
                if not na(pT1)
                    line.new(pX1, pT1, pX2, pT1, color=color.green, width=1, style=line.style_dotted)
                if not na(pT2)
                    line.new(pX1, pT2, pX2, pT2, color=color.maroon, width=1, style=line.style_solid)

                bool hasTerminalLabel = false
                if array.size(pkg.labels) > 0
                    for j = 0 to array.size(pkg.labels) - 1
                        lbl = array.get(pkg.labels, j)
                        if not na(lbl)
                            string txt = label.get_text(lbl)
                            if str.contains(txt, "STOPPED") or str.contains(txt, "T2 HIT") or str.contains(txt, "CANCEL") or str.contains(txt, "EXPIRED") or str.contains(txt, "CLOSED") or str.contains(txt, "TIMEOUT")
                                hasTerminalLabel := true
                            label.copy(lbl)
                
                if not hasTerminalLabel
                    label.new(pX2, pEn, "CLOSED", color=color.gray, textcolor=color.white, style=label.style_label_down, size=size.tiny)

// ==========================================
// 6.1 RISK & SIZER CALCULATION (PREVIEW & SIZING)
// ==========================================
float minFloorRange = syminfo.mintick * 4
float effectiveRiskPool = maxRiskRs
float rawEntryVal       = (isTradeActive or isSetupPending) and not na(currentEntry) ? currentEntry : high
float rawStopVal        = (isTradeActive or isSetupPending) and not na(currentStop)  ? currentStop  : low

float calcEntry     = math.ceil(rawEntryVal / syminfo.mintick) * syminfo.mintick
float calcStop      = math.floor(rawStopVal / syminfo.mintick) * syminfo.mintick
float riskDistShare = math.max(calcEntry - calcStop, minFloorRange)

float previewSpread = math.max(riskDistShare, calcEntry * 0.012)
int previewRiskQty  = previewSpread > 0 ? math.floor(effectiveRiskPool / previewSpread) : 0
int previewCashQty  = calcEntry > 0 ? math.floor(acctCapital / calcEntry) : 0

int previewCalculatedQty = 0
if not isTradeActive and not isSetupPending
    if isExact30m
        int rawQty = math.min(previewRiskQty, previewCashQty)
        previewCalculatedQty := (rawQty == 0 and acctCapital >= calcEntry) ? 1 : rawQty

// ==========================================
// 6.2 ORDER RESOLUTION (PENDING CHECK BEFORE NEW TRIGGER)
// ==========================================
int  curHourIST             = hour(timenow, "Asia/Kolkata")
int  curMinIST              = minute(timenow, "Asia/Kolkata")
bool isClockPastSquareOff   = curHourIST > 15 or (curHourIST == 15 and curMinIST >= 25)
bool isLiveFormingSession   = (year(time, "Asia/Kolkata") == year(timenow, "Asia/Kolkata")) and (month(time, "Asia/Kolkata") == month(timenow, "Asia/Kolkata")) and (dayofmonth(time, "Asia/Kolkata") == dayofmonth(timenow, "Asia/Kolkata"))

bool isClosingBar          = hour(time, "Asia/Kolkata") == 15 and minute(time, "Asia/Kolkata") >= 15
bool isNotClosingBar       = not isClosingBar
bool isSessionEodConfirmed = isClosingBar and barstate.isconfirmed
bool isPastSquareOffTime   = barstate.islast and not barstate.isconfirmed and isLiveFormingSession and isClockPastSquareOff
bool isLastBarOfDay        = isExact30m and (isSessionEodConfirmed or isPastSquareOffTime)
bool isDifferentDay        = not na(setupSessionTime) and (nseDayAnchor != setupSessionTime)

bool isOrderStaleTimeout   = not na(setupBarIndex) and ((bar_index - setupBarIndex) > maxUnfilledBars or ((bar_index - setupBarIndex) == maxUnfilledBars))
bool isPendingExpiredDay   = (expireEndOfDay and (isLastBarOfDay or isDifferentDay)) or isOrderStaleTimeout
bool isActiveTradeEodExit  = expireEndOfDay and isLastBarOfDay

float currentPendingRiskTransient    = not na(initialRiskDist) ? initialRiskDist : riskDistShare
bool  isGapTooLargeTransient         = isSetupPending and not isTradeActive and (open > (currentEntry + currentPendingRiskTransient * maxGapRiskMult))
bool  isStopBreachedAtOpenTransient = isSetupPending and not isTradeActive and (open <= currentStop)
bool  isDeadOnOpenTransient          = isSetupPending and not isTradeActive and (isGapTooLargeTransient or isStopBreachedAtOpenTransient or isPendingExpiredDay)

var bool wasOrderCancelledThisBar = false
if ta.change(time) != 0
    wasOrderCancelledThisBar := false

bool isPendingBaseBreached = isSetupPending and not isTradeActive and not na(currentStop) and ((low <= currentStop) and (open < currentEntry))

if isExact30m and isSetupPending and not isTradeActive and bar_index > setupBarIndex
    if isDeadOnOpenTransient or isPendingBaseBreached
        wasOrderCancelledThisBar := true
        if not na(activeEntryLine)
            line.set_x2(activeEntryLine, bar_index)
        if not na(activeStopLine)
            line.set_x2(activeStopLine, bar_index)
        if not na(activeT1Line)
            line.set_x2(activeT1Line, bar_index)
        if not na(activeT2Line)
            line.set_x2(activeT2Line, bar_index)

        currTrigBar    := setupBarIndex
        currExitBar    := bar_index
        currEntryPrice := currentEntry
        currStopPrice  := currentStop
        currT1Price    := currentT1
        currT2Price    := currentT2

        activeStopLine   := f_safeDeleteLine(activeStopLine)
        activeT1Line     := f_safeDeleteLine(activeT1Line)
        activeT2Line     := f_safeDeleteLine(activeT2Line)
        activeStopLabel  := f_safeDeleteLabel(activeStopLabel)
        activeT1Label    := f_safeDeleteLabel(activeT1Label)
        activeT2Label    := f_safeDeleteLabel(activeT2Label)
        
        array.clear(currLabels)

        line cancelStem     = line(na)
        label cancelTermLbl = label(na)
        if isExact30m
            int trigBar = setupBarIndex
            float cancelY = high + (ta.tr * 0.40)
            string cancelTxt = isPendingBaseBreached ? "CANCEL (SL)" : isGapTooLargeTransient ? "CANCEL (GAP RISK)" : isStopBreachedAtOpenTransient ? "CANCEL (GAP SL)" : isOrderStaleTimeout ? "TIMEOUT" : isPendingExpiredDay ? "EXPIRED (EOD)" : "CANCEL (SL)"
            cancelStem     := line.new(bar_index, high, bar_index, cancelY, color=color.gray, width=1, style=line.style_dotted)
            cancelTermLbl  := label.new(bar_index, cancelY, cancelTxt, color=color.gray, textcolor=color.white, style=label.style_label_down, size=size.tiny)

        if showUnfilledLabels
            f_trackGraphic(activeSetupBadge)
            f_archiveCurrentSetup(cancelTermLbl, true, true)
        else
            activeEntryLine  := f_safeDeleteLine(activeEntryLine)
            activeEntryLabel := f_safeDeleteLabel(activeEntryLabel)
            activeSetupBadge := f_safeDeleteLabel(activeSetupBadge)
            activeAnchorStem := f_safeDeleteLine(activeAnchorStem)
            line.delete(cancelStem)
            label.delete(cancelTermLbl)
        
        activeEntryLine  := na
        activeEntryLabel := na
        activeSetupBadge := na
        activeAnchorStem := na

        currentEntry       := na
        currentStop        := na
        currentT1          := na
        currentT2          := na
        actualFillPrice    := na
        isTradeActive      := false
        isSetupPending     := false
        t1Achieved         := false
        t1HitBar           := na
        activeT1HitBadge   := na
        activeOrderQty     := 0
        initialRiskDist    := na
        setupBarIndex      := na
        fillBarIndex       := na
        setupSessionTime   := na
        lastExitBarIndex   := bar_index - 1
        doResetTradeState  := false

        currTrigBar    := na
        currExitBar    := na
        currEntryPrice := na
        currStopPrice  := na
        currT1Price    := na
        currT2Price    := na

    else if high >= currentEntry
        wasOrderCancelledThisBar := false
        isTradeActive    := true
        isSetupPending   := false
        fillBarIndex     := bar_index
        setupSessionTime := nseDayAnchor
        
        actualFillPrice  := open > currentEntry ? (math.ceil(open / syminfo.mintick) * syminfo.mintick) : currentEntry

        if isExact30m
            if not na(activeEntryLine)
                line.set_color(activeEntryLine, color.teal)
                line.set_style(activeEntryLine, line.style_solid)
                if actualFillPrice > currentEntry
                    line.set_y1(activeEntryLine, actualFillPrice)
                    line.set_y2(activeEntryLine, actualFillPrice)
            if not na(activeEntryLabel)
                label.set_color(activeEntryLabel, color.teal)
                string fillBadgeText = actualFillPrice > currentEntry ? "FILLED: " + str.tostring(actualFillPrice, "#.00") : "BUY: " + str.tostring(currentEntry, "#.00")
                label.set_text(activeEntryLabel, fillBadgeText)
                label.set_style(activeEntryLabel, label.style_label_left)
                if actualFillPrice > currentEntry
                    label.set_y(activeEntryLabel, actualFillPrice)

        if actualFillPrice > currentEntry
            float executedRisk = math.max(actualFillPrice - currentStop, syminfo.mintick)
            initialRiskDist    := executedRisk
            currentRiskPct     := actualFillPrice > 0 ? (executedRisk / actualFillPrice) * 100.0 : 0.0
            activeOrderQty     := math.max(1, math.min(activeOrderQty, math.floor(maxRiskRs / executedRisk)))
            currentT1          := math.round((actualFillPrice + (executedRisk * 2.0)) / syminfo.mintick) * syminfo.mintick

            float targetAnchor = not na(d_swingHigh) and d_swingHigh > actualFillPrice ? d_swingHigh : 
                               not na(effective52WH) and effective52WH > actualFillPrice ? effective52WH : 
                               actualFillPrice + (executedRisk * 3.5)
            currentT2 := math.round(math.max(targetAnchor, actualFillPrice + (executedRisk * 2.5)) / syminfo.mintick) * syminfo.mintick

            line.set_y1(activeT1Line, currentT1)
            line.set_y2(activeT1Line, currentT1)
            line.set_y1(activeT2Line, currentT2)
            line.set_y2(activeT2Line, currentT2)
            label.set_y(activeT1Label, currentT1)
            label.set_text(activeT1Label, "T1: " + str.tostring(currentT1, "#.00"))
            label.set_y(activeT2Label, currentT2)
            label.set_text(activeT2Label, "T2: " + str.tostring(currentT2, "#.00"))

bool isPendingDeadOrBreached = isSetupPending and not isTradeActive and (isDeadOnOpenTransient or isPendingBaseBreached)

// Step B: Evaluate potential NEW setup (Strict lockout on exit bar)
float tempEntry = math.ceil(high / syminfo.mintick) * syminfo.mintick
float tempStop  = math.floor(low / syminfo.mintick) * syminfo.mintick
float candleSpread  = tempEntry - tempStop
float tempRisk      = math.max(candleSpread, minFloorRange)

// Dynamic Overhead MA Resistance Check with separate 21 EMA & 50 SMA toggles
float maResist = na
if enforceEma21Res
    if chart_ema21 > tempEntry or close < chart_ema21
        maResist := chart_ema21

if enforceSma50Res
    if not na(chart_sma50) and (chart_sma50 > tempEntry or close < chart_sma50) and (na(maResist) or chart_sma50 < maResist)
        maResist := chart_sma50

if enforceMajorMaRes
    if not na(chart_sma150) and (chart_sma150 > tempEntry or close < chart_sma150) and (na(maResist) or chart_sma150 < maResist)
        maResist := chart_sma150
    if not na(chart_sma200) and (chart_sma200 > tempEntry or close < chart_sma200) and (na(maResist) or chart_sma200 < maResist)
        maResist := chart_sma200

float structResist = not na(d_swingHigh) and d_swingHigh > tempEntry ? d_swingHigh : 
                     not na(effective52WH) and effective52WH > tempEntry ? effective52WH : na

float nearestResist = na
bool  useMaCheck    = enforceEma21Res or enforceSma50Res or enforceMajorMaRes
if useMaCheck and not na(maResist)
    nearestResist := not na(structResist) ? math.min(maResist, structResist) : maResist
else
    nearestResist := structResist

bool isPriceTrappedBelowMa     = (enforceEma21Res and close < chart_ema21) or (enforceSma50Res and not na(chart_sma50) and close < chart_sma50) or (enforceMajorMaRes and ((not na(chart_sma150) and close < chart_sma150) or (not na(chart_sma200) and close < chart_sma200)))
bool isOverheadResistanceClose = not na(nearestResist) and ((nearestResist - tempEntry) < tempRisk * 2.0)
bool hasHealthyRR              = not enforceMinRRR or not isOverheadResistanceClose
bool canTriggerNow             = na(lastExitBarIndex) or (bar_index > lastExitBarIndex)
bool volDryPass                = not requireVolDryUp or isHealthyVolDry
bool isBaseTrigger             = canTriggerNow and not isTradeActive and not isSetupPending and isExact30m and isInNseSession and isNotClosingBar and isAtCoreDailySupport and isConfirmed30mReaction and hasHealthyRR and volDryPass and not isPriceTrappedBelowMa

bool newSetupTrigger         = isBaseTrigger and (not restrictMaxSetups or setupCount < maxAllowedSetups)

float evalProposedEntry = math.ceil(high / syminfo.mintick) * syminfo.mintick
float evalProposedStop  = math.floor(low / syminfo.mintick) * syminfo.mintick
float evalTrigRiskDist  = math.max(evalProposedEntry - evalProposedStop, minFloorRange)
float evalTrigBudget    = maxRiskRs
int   evalTrigRiskQty   = evalTrigRiskDist > 0 ? math.floor(evalTrigBudget / evalTrigRiskDist) : 0
int   evalTrigCashQty   = evalProposedEntry > 0 ? math.floor(acctCapital / evalProposedEntry) : 0
int   rawCalculatedQty  = math.min(evalTrigRiskQty, evalTrigCashQty)
int   evalCalculatedQty = (rawCalculatedQty == 0 and acctCapital >= evalProposedEntry) ? 1 : rawCalculatedQty

bool validSetupFired = newSetupTrigger and (evalCalculatedQty > 0)

if validSetupFired
    doResetTradeState := false

    if array.size(currLabels) > 0
        for i = 0 to array.size(currLabels) - 1
            label.delete(array.get(currLabels, i))
        array.clear(currLabels)

    setupCount += 1
    int activeSequenceNum = setupCount

    expTermLbl         := f_safeDeleteLabel(expTermLbl)
    activeEntryLine    := f_safeDeleteLine(activeEntryLine)
    activeStopLine     := f_safeDeleteLine(activeStopLine)
    activeT1Line       := f_safeDeleteLine(activeT1Line)
    activeT2Line       := f_safeDeleteLine(activeT2Line)
    activeEntryLabel   := f_safeDeleteLabel(activeEntryLabel)
    activeStopLabel    := f_safeDeleteLabel(activeStopLabel)
    activeT1Label      := f_safeDeleteLabel(activeT1Label)
    activeT2Label      := f_safeDeleteLabel(activeT2Label)
    activeT1HitBadge   := f_safeDeleteLabel(activeT1HitBadge)

    currentEntry      := evalProposedEntry
    currentStop       := evalProposedStop
    float risk        = currentEntry - currentStop
    currentRiskPct    = currentEntry > 0 ? (risk / currentEntry) * 100.0 : 0.0

    currentT1 := math.round((currentEntry + (risk * 2.0)) / syminfo.mintick) * syminfo.mintick
    float targetAnchor = not na(d_swingHigh) and d_swingHigh > currentEntry ? d_swingHigh : 
                       not na(effective52WH) and effective52WH > currentEntry ? effective52WH : 
                       currentEntry + (risk * 3.5)
    if useMaCheck and not na(maResist)
        targetAnchor := math.min(targetAnchor, maResist)
    currentT2 := math.round(math.max(targetAnchor, currentEntry + (risk * 2.5)) / syminfo.mintick) * syminfo.mintick

    initialRiskDist    := evalTrigRiskDist
    activeOrderQty     := evalCalculatedQty
    actualFillPrice    := na

    setupBarIndex      := bar_index
    fillBarIndex       := na
    setupSessionTime   := nseDayAnchor
    isSetupPending     := true
    isTradeActive      := false
    t1Achieved         := false
    t1HitBar           := na

    currTrigBar        := setupBarIndex
    currExitBar        := setupBarIndex + 4
    currEntryPrice     := currentEntry
    currStopPrice      := currentStop
    currT1Price        := currentT1
    currT2Price        := currentT2

    alertT1Triggered     := false
    alertExitTriggered   := false
    barHadT1Alert        := false
    barHadTradeExitAlert := false

    bool hasStarQuality = (qualityScore >= 3 or dVol < daily_volMA)
    string qualityStar  = hasStarQuality ? " *" : ""
    string badgeTitle   = "SETUP " + str.tostring(activeSequenceNum) + qualityStar

    color setupBadgeColor = (activeSequenceNum == 1 ? #00897B : activeSequenceNum == 2 ? #1565C0 : #E65100)
    color badgeTextColor  = color.white

    if isExact30m
        int trigBar = setupBarIndex
        float badgeY = low - (ta.tr * 0.50)
        activeAnchorStem := line.new(trigBar, low, trigBar, badgeY, color=setupBadgeColor, width=1, style=line.style_dotted)
        activeSetupBadge := label.new(trigBar, badgeY, badgeTitle, color=setupBadgeColor, textcolor=badgeTextColor, style=label.style_label_up, size=size.tiny)
        f_trackGraphic(activeSetupBadge)

        int initRightX = trigBar + 6
        activeEntryLine := line.new(trigBar, currentEntry, initRightX, currentEntry, color=color.teal, width=2, style=line.style_solid)
        activeStopLine  := line.new(trigBar, currentStop,  initRightX, currentStop,  color=color.red,  width=2, style=line.style_solid)
        activeT1Line    := line.new(trigBar, currentT1,    initRightX, currentT1,    color=color.green,  width=1, style=line.style_dotted)
        activeT2Line    := line.new(trigBar, currentT2,    initRightX, currentT2,    color=color.maroon, width=1, style=line.style_solid)

        activeEntryLabel := label.new(initRightX, currentEntry, "BUY: " + str.tostring(currentEntry, "#.00"), color=color.teal, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        string slText = "SL: " + str.tostring(currentStop, "#.00")
        activeStopLabel  := label.new(initRightX, currentStop, slText, color=color.red, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        string t1LabelText = "T1: " + str.tostring(currentT1, "#.00")
        activeT1Label    := label.new(initRightX, currentT1, t1LabelText, color=color.green, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        string t2LabelText = "T2: " + str.tostring(currentT2, "#.00")
        activeT2Label    := label.new(initRightX, currentT2, t2LabelText, color=color.maroon, textcolor=color.white, style=label.style_label_left, size=size.tiny)

        f_trackGraphic(activeEntryLabel)
        f_trackGraphic(activeStopLabel)
        f_trackGraphic(activeT1Label)
        f_trackGraphic(activeT2Label)

float execReferencePrice = not na(actualFillPrice) ? actualFillPrice : calcEntry
float previewTotalCap    = previewCalculatedQty * calcEntry
float dispTotalCap       = (isTradeActive or isSetupPending) ? (activeOrderQty * execReferencePrice) : previewTotalCap
float dispCapPct         = acctCapital > 0 ? (dispTotalCap / acctCapital) * 100.0 : 0.0
float targetDistShare    = math.max(nz(currentT1, calcEntry) - execReferencePrice, 0.0)
float expectedT1Profit   = activeOrderQty * targetDistShare

float liveStopDist   = (isTradeActive or isSetupPending) and not na(currentStop) ? math.max(execReferencePrice - currentStop, 0.0) : riskDistShare
float liveRupeeRisk  = (isTradeActive or isSetupPending) ? (activeOrderQty * liveStopDist) : (previewCalculatedQty * riskDistShare)
float liveRiskPct    = execReferencePrice > 0 ? (liveStopDist / execReferencePrice) * 100.0 : 0.0
float lockedInGain   = (isTradeActive and not na(currentStop) and not na(actualFillPrice) and currentStop > actualFillPrice) ? activeOrderQty * (currentStop - actualFillPrice) : 0.0

bool condT1HitAlert     = barHadT1Alert
bool condTradeExitAlert = barHadTradeExitAlert and not validSetupFired

// Step C: Active trade target & stop management
bool hitT2Target = false
bool hitStop     = false

bool isOpeningSessionBar = isExact30m and (sessionBarsCount == 1 or isNewIseDay)
bool isGapDownBreachNow    = isTradeActive and not na(fillBarIndex) and (bar_index > fillBarIndex) and (open <= currentStop)

bool isOpeningBarOfDay    = isExact30m and (sessionBarsCount == 1)
bool allowTrailingCheck   = not skipFirst30mBar or not isOpeningBarOfDay
bool isTrailBreachedIntra = isTradeActive and t1Achieved and not na(t1HitBar) and (bar_index >= t1HitBar) and allowTrailingCheck and (open <= currentStop or low <= currentStop or (close < currentStop))
bool isInitialStopBreachedIntra = isTradeActive and not t1Achieved and not na(fillBarIndex) and (bar_index >= fillBarIndex) and (low <= currentStop or open <= currentStop)

if isTradeActive and not na(currentEntry) and not na(currentT1) and not na(currentStop)
    if not t1Achieved and not na(fillBarIndex) and (bar_index >= fillBarIndex) and high >= currentT1
        t1Achieved := true
        t1HitBar   := bar_index
        
        if not alertT1Triggered
            barHadT1Alert    := true
            condT1HitAlert   := true
            alertT1Triggered := true

        if isExact30m
            string t1HitText = "T1 HIT (+₹" + str.tostring(expectedT1Profit, "#,###") + ")"
            activeT1HitBadge := label.new(bar_index, currentT1, t1HitText, color=color.lime, textcolor=color.black, style=label.style_label_lower_right, size=size.tiny)
            f_trackGraphic(activeT1HitBadge)

        float baseFillCost   = nz(actualFillPrice, currentEntry)
        currentStop := baseFillCost
        currStopPrice := currentStop

        if isExact30m
            line.set_y1(activeStopLine, currentStop)
            line.set_y2(activeStopLine, currentStop)
            line.set_color(activeStopLine, color.aqua)
            line.set_style(activeStopLine, line.style_dashed)
            label.set_color(activeStopLabel, color.aqua)
            label.set_textcolor(activeStopLabel, color.black)
            label.set_x(activeStopLabel, bar_index + 6)
            label.set_y(activeStopLabel, currentStop)
            string lockTxt = "SL: COST (" + str.tostring(currentStop, "#.00") + ")"
            label.set_text(activeStopLabel, lockTxt)

    if t1Achieved and not na(t1HitBar) and (bar_index > t1HitBar)
        float floorCostStop       = nz(actualFillPrice, currentEntry)
        float minRunnerFloor     = floorCostStop
        
        float selectedEma = trailEmaSource == "Daily (Daily 8 EMA)" ? daily_ema8 : chart_ema8
        float dynamicEmaStop = math.floor(selectedEma / syminfo.mintick) * syminfo.mintick
        
        if dynamicEmaStop > currentStop and dynamicEmaStop >= minRunnerFloor
            currentStop := dynamicEmaStop
            currStopPrice := currentStop
            if isExact30m
                line.set_y1(activeStopLine, currentStop)
                line.set_y2(activeStopLine, currentStop)
                label.set_y(activeStopLabel, currentStop)
                string trailLblText = (trailEmaSource == "Daily (Daily 8 EMA)" ? "TRAIL (D-8 EMA): " : "TRAIL (8 EMA): ") + str.tostring(currentStop, "#.00")
                label.set_text(activeStopLabel, trailLblText)

    hitT2Target := not na(currentT2) and (high >= currentT2)

    if (isGapDownBreachNow or isInitialStopBreachedIntra) and not alertExitTriggered
        barHadTradeExitAlert := true
        condTradeExitAlert   := not validSetupFired
        alertExitTriggered   := true

    if not hitT2Target
        if t1Achieved
            hitStop := ((bar_index >= t1HitBar) and allowTrailingCheck and (close < currentStop)) or isGapDownBreachNow
        else
            hitStop := ((bar_index >= fillBarIndex) and (close <= currentStop or open <= currentStop or low <= currentStop)) or isGapDownBreachNow

    if not hitStop and not hitT2Target
        alertExitTriggered := false

    if hitT2Target
        wasTradeT2HitThisBar := true
        if not alertExitTriggered
            barHadTradeExitAlert := true
            condTradeExitAlert   := not validSetupFired
            alertExitTriggered   := true

        currTrigBar    := setupBarIndex
        currExitBar    := bar_index
        currEntryPrice := nz(actualFillPrice, currentEntry)
        currStopPrice  := currentStop
        currT1Price    := currentT1
        currT2Price    := currentT2

        label t2TermLbl = label(na)
        if isExact30m
            line.set_color(activeT2Line, color.lime)
            line.set_width(activeT2Line, 2)
            line.set_x2(activeT2Line, bar_index)
            t2TermLbl := label.new(bar_index, currentT2, "T2 HIT", color=color.lime, textcolor=color.black, style=label.style_label_down, size=size.tiny)

            if not na(activeEntryLine)
                line.set_x2(activeEntryLine, bar_index)
            if not na(activeStopLine)
                line.set_x2(activeStopLine, bar_index)
            if not na(activeT2Line)
                line.set_x2(activeT2Line, bar_index)

        activeEntryLine  := na
        activeStopLine   := na
        activeT1Line     := na
        activeT2Line     := na

        label.delete(activeStopLabel)
        label.delete(activeEntryLabel)
        label.delete(activeT1Label)
        label.delete(activeT2Label)
        activeStopLabel  := na
        activeEntryLabel := na
        activeT1Label    := na
        activeT2Label    := na

        bool canArchiveTrade = showTrendHist
        array.clear(currLabels)

        if canArchiveTrade
            f_archiveCurrentSetup(t2TermLbl, true)
        else
            label.delete(activeSetupBadge)
            line.delete(activeAnchorStem)
            label.delete(t2TermLbl)
            label.delete(activeT1HitBadge)

        activeSetupBadge := na
        activeAnchorStem := na
        activeT1HitBadge := na

        isTradeActive     := false
        isSetupPending    := false
        lastExitBarIndex  := bar_index
        doResetTradeState := true

        currTrigBar    := na
        currExitBar    := na
        currEntryPrice := na
        currStopPrice  := na
        currT1Price    := na
        currT2Price    := na

    else if hitStop
        wasTradeStoppedThisBar := true
        if not alertExitTriggered
            barHadTradeExitAlert := true
            condTradeExitAlert   := not validSetupFired
            alertExitTriggered   := true

        currTrigBar    := setupBarIndex
        currExitBar    := bar_index
        currEntryPrice := nz(actualFillPrice, currentEntry)
        currStopPrice  := currentStop
        currT1Price    := currentT1
        currT2Price    := currentT2

        if isExact30m
            if not na(activeStopLine)
                color executedStopColor = t1Achieved ? color.orange : color.maroon
                line.set_color(activeStopLine, executedStopColor)
                line.set_x2(activeStopLine, bar_index)
            if not na(activeEntryLine)
                line.set_x2(activeEntryLine, bar_index)

        activeStopLine   := na
        activeEntryLine  := na
        activeEntryLabel := na
        activeT1Line     := na
        activeT2Line     := na
        
        line  stopStem    = line(na)
        label stopTermLbl = label(na)
        if isExact30m
            float stopY = high + (ta.tr * 0.40)
            color stopBadgeCol  = t1Achieved ? color.orange : color.red
            string stopBadgeTxt = isGapDownBreachNow ? (t1Achieved ? "GAP STOPPED (RUNNER)" : "GAP STOPPED") : t1Achieved ? "RUNNER CLOSED (8 EMA)" : "STOPPED"
            stopStem    := line.new(bar_index, high, bar_index, stopY, color=stopBadgeCol, width=1, style=line.style_dotted)
            stopTermLbl := label.new(bar_index, stopY, stopBadgeTxt, color=stopBadgeCol, textcolor=color.white, style=label.style_label_down, size=size.tiny)

        label.delete(activeStopLabel)
        label.delete(activeT1Label)
        label.delete(activeT2Label)
        activeStopLabel  := na
        activeT1Label    := na
        activeT2Label    := na

        bool canArchiveTrade = showTrendHist
        array.clear(currLabels)

        if canArchiveTrade
            f_archiveCurrentSetup(stopTermLbl, true)
        else
            label.delete(activeSetupBadge)
            line.delete(activeAnchorStem)
            label.delete(stopTermLbl)
            label.delete(activeT1HitBadge)

        activeSetupBadge := na
        activeAnchorStem := na
        activeT1HitBadge := na

        isTradeActive     := false
        isSetupPending    := false
        lastExitBarIndex  := bar_index
        doResetTradeState := true

        currTrigBar    := na
        currExitBar    := na
        currEntryPrice := na
        currStopPrice  := na
        currT1Price    := na
        currT2Price    := na

    else if isActiveTradeEodExit
        int closeIdx = bar_index

        currTrigBar    := setupBarIndex
        currExitBar    := closeIdx
        currEntryPrice := nz(actualFillPrice, currentEntry)
        currStopPrice  := currentStop
        currT1Price    := currentT1
        currT2Price    := currentT2

        activeT2Line   := f_safeDeleteLine(activeT2Line)
        activeStopLine := na
        activeT1Line   := f_safeDeleteLine(activeT1Line)

        if isExact30m
            if not na(activeEntryLine)
                line.set_color(activeEntryLine, t1Achieved ? color.teal : color.gray)
                line.set_style(activeEntryLine, line.style_dotted)
                line.set_x2(activeEntryLine, closeIdx)

        line  expStem    = line(na)
        label expTermLblLocal = label(na)
        if isExact30m
            float expY = high + (ta.tr * 0.40)
            color expCol = t1Achieved ? color.teal : color.gray
            expStem    := line.new(closeIdx, high, closeIdx, expY, color=expCol, width=1, style=line.style_dotted)
            expTermLblLocal := label.new(closeIdx, expY, "EXPIRED (EOD)", color=expCol, textcolor=color.white, style=label.style_label_down, size=size.tiny)
    
        label.delete(activeStopLabel)
        label.delete(activeEntryLabel)
        label.delete(activeT1Label)
        label.delete(activeT2Label)
        activeStopLabel  := na
        activeEntryLabel := na
        activeT1Label    := na
        activeT2Label    := na

        bool canArchiveTrade = showTrendHist
        array.clear(currLabels)

        if canArchiveTrade
            f_archiveCurrentSetup(expTermLblLocal, true)
        else
            label.delete(activeSetupBadge)
            line.delete(activeAnchorStem)
            label.delete(expTermLblLocal)
            label.delete(activeT1HitBadge)

        activeEntryLine  := na
        activeSetupBadge := na
        activeAnchorStem := na
        activeT1HitBadge := na

        isTradeActive     := false
        isSetupPending    := false
        lastExitBarIndex  := bar_index
        doResetTradeState := true

        currTrigBar    := na
        currExitBar    := na
        currEntryPrice := na
        currStopPrice  := na
        currT1Price    := na
        currT2Price    := na

// Step D: Line projections
bool isConfirmedExit = (hitStop or isActiveTradeEodExit)
bool shouldProject   = barstate.islast and isExact30m and isTradeActive and not isConfirmedExit and not hitT2Target and not isGapDownBreachNow and not isTrailBreachedIntra and not isInitialStopBreachedIntra

if shouldProject
    int targetX = bar_index + 6
    if not na(activeEntryLine)
        line.set_x2(activeEntryLine, targetX)
    if not na(activeStopLine)
        line.set_x2(activeStopLine, targetX)
    if not t1Achieved and not na(activeT1Line)
        line.set_x2(activeT1Line, targetX)
    if not na(activeT2Line)
        line.set_x2(activeT2Line, targetX)

    if not na(activeEntryLabel) and not na(currentEntry)
        label.set_x(activeEntryLabel, targetX)
        float entryYTarget = not na(actualFillPrice) and actualFillPrice > currentEntry ? actualFillPrice : currentEntry
        label.set_y(activeEntryLabel, entryYTarget)
    if not na(activeStopLabel) and not na(currentStop)
        label.set_x(activeStopLabel, targetX)
        label.set_y(activeStopLabel, currentStop)
    if not t1Achieved and not na(activeT1Label) and not na(currentT1)
        label.set_x(activeT1Label, targetX)
        label.set_y(activeT1Label, currentT1)
    if not t1Achieved and not na(activeT2Label) and not na(currentT2)
        label.set_x(activeT2Label, targetX)
        label.set_y(activeT2Label, currentT2)

if not isExact30m
    expTermLbl         := f_safeDeleteLabel(expTermLbl)
    activeEntryLine    := f_safeDeleteLine(activeEntryLine)
    activeStopLine     := f_safeDeleteLine(activeStopLine)
    activeT1Line       := f_safeDeleteLine(activeT1Line)
    activeT2Line       := f_safeDeleteLine(activeT2Line)
    activeEntryLabel   := f_safeDeleteLabel(activeEntryLabel)
    activeStopLabel    := f_safeDeleteLabel(activeStopLabel)
    activeT1Label      := f_safeDeleteLabel(activeT1Label)
    activeT2Label      := f_safeDeleteLabel(activeT2Label)
    activeT1HitBadge   := f_safeDeleteLabel(activeT1HitBadge)
    activeSetupBadge   := f_safeDeleteLabel(activeSetupBadge)
    activeAnchorStem   := f_safeDeleteLine(activeAnchorStem)
    array.clear(currLabels)
    currentRiskPct     := na

// ==========================================
// 6.3 UNIFIED DASHBOARD
// ==========================================
color pleasantHeaderBg = #1E2235
color pleasantBorder   = #363D52
color pleasantBodyBg   = color.new(#11131F, 10)
color pleasantHeadText = #ECEFF4

var table hudTable = table.new(mainTblPos, 2, 11, bgcolor=pleasantBodyBg, border_width=1, border_color=pleasantBorder)

if barstate.islast
    table.clear(hudTable, 0, 0, 1, 10)

    if isHigherTF and showMainDash
        table.cell(hudTable, 0, 0, "METRIC", bgcolor=pleasantHeaderBg, text_color=pleasantHeadText, text_size=size.small)
        table.cell(hudTable, 1, 0, "STATUS", bgcolor=pleasantHeaderBg, text_color=pleasantHeadText, text_size=size.small)
        table.cell(hudTable, 0, 1, "Setup Quality", text_color=color.white, text_size=size.small)
        table.cell(hudTable, 1, 1, setupGrade, text_color=gradeColor, text_size=size.small)
        
        table.cell(hudTable, 0, 2, "Consol. Days", text_color=color.white, text_size=size.small)
        string consolDaysText = isIpoStock ? "IPO (New)" : d_barsSincePeak <= 1 ? "1d (Breakout)" : str.tostring(d_barsSincePeak) + (isHealthyDuration ? "d (Good)" : "d (Climax/Stale)")
        color  consolDaysCol  = isIpoStock ? color.gray : d_barsSincePeak <= 1 ? color.lime : (isHealthyDuration ? color.lime : color.yellow)
        table.cell(hudTable, 1, 2, consolDaysText, text_color=consolDaysCol, text_size=size.small)
        
        table.cell(hudTable, 0, 3, "Pullback Vol", text_color=color.white, text_size=size.small)
        table.cell(hudTable, 1, 3, isHealthyVolDry ? "Dry-Up / Low" : "Heavy Supply", text_color=isHealthyVolDry ? color.lime : color.red, text_size=size.small)
        table.cell(hudTable, 0, 4, "Overhead Supply", text_color=color.white, text_size=size.small)
        table.cell(hudTable, 1, 4, hasHeavyWick ? "Trap Wick Found" : "Clean Closes", text_color=hasHeavyWick ? color.red : color.lime, text_size=size.small)
        table.cell(hudTable, 0, 5, "Off 52W High", text_color=color.white, text_size=size.small)
        table.cell(hudTable, 1, 5, pctOff52WHTxt, text_color=pctOff52WHCol, text_size=size.small)
        table.cell(hudTable, 0, 6, "Vol. Buzz", text_color=color.white, text_size=size.small)
        table.cell(hudTable, 1, 6, volBuzzText, text_color=volBuzzColor, text_size=size.small)
        table.cell(hudTable, 0, 7, "U/D Vol Ratio", text_color=color.white, text_size=size.small)
        table.cell(hudTable, 1, 7, str.tostring(upDnRatio, "0.00"), text_color=upDnRatio >= 1.2 ? color.lime : (upDnRatio >= 1.0 ? color.yellow : color.red), text_size=size.small)
        table.cell(hudTable, 0, 8, "Turnover (50D)", text_color=color.white, text_size=size.small)
        table.cell(hudTable, 1, 8, liqText, text_color=liqColor, text_size=size.small)
        table.cell(hudTable, 0, 9, "Daily ATR(14)", text_color=color.white, text_size=size.small)
        float atrPctOfPrice = close > 0 ? (safeDailyAtr / close) * 100.0 : 0.0
        table.cell(hudTable, 1, 9, "₹" + str.tostring(safeDailyAtr, "#.00") + " (" + str.tostring(atrPctOfPrice, "0.1") + "%)", text_color=color.white, text_size=size.small)
        
        table.cell(hudTable, 0, 10, "RS Trend", text_color=color.white, text_size=size.small)
        table.cell(hudTable, 1, 10, rsSlopeUp ? "RISING ▲" : "FALLING ▼", text_color=rsSlopeUp ? color.lime : color.red, text_size=size.small)

    else if isExact30m
        string qtyStr = isGapDownBreachNow ? "GAP STOPPED (EXIT)" :
             wasTradeT2HitThisBar ? "TARGET 2 HIT (EXIT)" :
             wasTradeStoppedThisBar ? "STOPPED OUT (EXIT)" :
             (isPendingDeadOrBreached or wasOrderCancelledThisBar) ? "ORDER CANCELLED" :
             isTradeActive ? str.tostring(activeOrderQty) + " SHARES (FILLED)" : 
             isSetupPending ? str.tostring(activeOrderQty) + " SHARES (PENDING)" : 
             previewCalculatedQty == 0 ? "0 (INSUFFICIENT CAP)" : 
             str.tostring(previewCalculatedQty) + " SHARES (PREVIEW)"
        color  qtyCol = (isGapDownBreachNow or wasTradeStoppedThisBar or isPendingDeadOrBreached or wasOrderCancelledThisBar) ? color.red : wasTradeT2HitThisBar ? color.lime : (isTradeActive or isSetupPending) ? color.lime : (previewCalculatedQty == 0 ? color.red : color.yellow)
        table.cell(hudTable, 0, 0, "ORDER QTY", bgcolor=pleasantBodyBg, text_color=color.white, text_size=size.small)
        table.cell(hudTable, 1, 0, qtyStr, bgcolor=pleasantBodyBg, text_color=qtyCol, text_size=size.small)

        string capDisplay  = (isGapDownBreachNow or wasTradeStoppedThisBar or wasTradeT2HitThisBar or isPendingDeadOrBreached or wasOrderCancelledThisBar) ? "₹0.00 (Cancelled/Exited)" : "₹" + str.tostring(dispTotalCap, "#,###.00") + " (" + str.tostring(dispCapPct, "0") + "% Cap)"
        table.cell(hudTable, 0, 1, "Capital Outlay", bgcolor=pleasantBodyBg, text_color=color.white, text_size=size.small)
        table.cell(hudTable, 1, 1, capDisplay, bgcolor=pleasantBodyBg, text_color=color.white, text_size=size.small)

        string riskTitle   = isGapDownBreachNow ? "Exit Status" : wasTradeT2HitThisBar ? "Exit Status" : wasTradeStoppedThisBar ? "Exit Status" : (isPendingDeadOrBreached or wasOrderCancelledThisBar) ? "Order Status" : (isTradeActive or isSetupPending) ? (lockedInGain > 0 ? "Locked Gain" : "Max Loss (Live)") : "Risk Pool (Preview)"
        string riskDisplay = isGapDownBreachNow ? "BREACHED (Execute Stop)" :
             wasTradeT2HitThisBar ? "TARGET REACHED (Profit Banked)" :
             wasTradeStoppedThisBar ? "STOPPED OUT (Position Closed)" :
             (isPendingDeadOrBreached or wasOrderCancelledThisBar) ? "INVALIDATED (No Fill)" :
             isTradeActive ? (lockedInGain > 0 ? "+₹" + str.tostring(lockedInGain, "#,###") + " (Trailing Profit)" : liveRupeeRisk == 0.0 ? "₹0.00 (Risk Free / Cost SL)" : "-₹" + str.tostring(liveRupeeRisk, "#,###") + " (" + str.tostring(liveRiskPct, "0.00") + "% SL)") : 
             isSetupPending ? "-₹" + str.tostring(liveRupeeRisk, "#,###") + " (Pending Order)" : 
             "-₹" + str.tostring(effectiveRiskPool, "#,###") + " (Idle / Max Risk)"
        color  riskDisplayCol = (isGapDownBreachNow or wasTradeStoppedThisBar or isPendingDeadOrBreached or wasOrderCancelledThisBar) ? color.red : wasTradeT2HitThisBar ? color.lime : isTradeActive ? (lockedInGain > 0 ? color.lime : liveRupeeRisk == 0.0 ? color.aqua : color.yellow) : color.gray
        table.cell(hudTable, 0, 2, riskTitle, bgcolor=pleasantBodyBg, text_color=color.white, text_size=size.small)
        table.cell(hudTable, 1, 2, riskDisplay, bgcolor=pleasantBodyBg, text_color=riskDisplayCol, text_size=size.small)

// ==========================================
// 7. ADR% METRIC DISPLAY (TRUE 20-DAY DAILY CALCULATION)
// ==========================================
adrLength = input.int(20, "ADR% Lookback (Days)", minval=5, group="ADR Settings")

f_calcDailyAdr(int len) =>
    float dRange = math.max(high - low, syminfo.mintick)
    float dBase  = math.max(low, syminfo.mintick)
    ta.sma((dRange / dBase) * 100.0, len)

adrPct = request.security(syminfo.tickerid, "D", f_calcDailyAdr(adrLength), barmerge.gaps_off, barmerge.lookahead_off)

var adrTblPos = dashPosInput == "Bottom Right" ? position.bottom_center : position.bottom_right
var table adrTable = table.new(adrTblPos, 2, 2, bgcolor=pleasantBodyBg, border_width=1, border_color=pleasantBorder)

bool isTrendingUp = close >= daily_ema8 and daily_ema8 >= daily_ema21

string velocityText  = ""
color  velocityColor = color.white
color  adrColor      = adrPct >= 3.5 ? color.lime : (adrPct >= 2.5 ? color.yellow : color.red)

if isTrendingUp
    if adrPct >= 3.5
        velocityText  := "Fast Leader"
        velocityColor := color.lime
    else if adrPct >= 2.5
        velocityText  := "Moderate"
        velocityColor := color.yellow
    else
        velocityText  := "Slow Range"
        velocityColor := color.orange
else
    if adrPct >= 3.5
        velocityText  := "High Vol (Falling)"
        velocityColor := color.red
    else
        velocityText  := "Downtrend"
        velocityColor := color.red

if barstate.islast
    table.cell(adrTable, 0, 0, "ADR", bgcolor=pleasantHeaderBg, text_color=pleasantHeadText, text_size=size.tiny)
    table.cell(adrTable, 1, 0, str.tostring(adrPct, "#.##") + "%", bgcolor=pleasantHeaderBg, text_color=adrColor, text_size=size.tiny)
    table.cell(adrTable, 0, 1, "Status", bgcolor=pleasantBodyBg, text_color=color.gray, text_size=size.tiny)
    table.cell(adrTable, 1, 1, velocityText, bgcolor=pleasantBodyBg, text_color=velocityColor, text_size=size.tiny)

// ==========================================
// 8. INTEGRATED MARKET STATUS DASHBOARD
// ==========================================
[niftyOpen, niftyHigh, niftyLow, niftyClose, niftyVol, niftyVolMA20] = request.security(indexTicker, "D", [open, high, low, close, volume, ta.sma(volume, 20)], barmerge.gaps_off, barmerge.lookahead_off)

[niftyM15Close, niftyM15Prev] = request.security(indexTicker, "15", [close, close[1]], barmerge.gaps_off, barmerge.lookahead_off)

niftyLiveClose = request.security(indexTicker, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
niftyM30Close  = isExact30m ? niftyLiveClose : request.security(indexTicker, "30", close, barmerge.gaps_off, barmerge.lookahead_off)

f_getNiftyVwap() =>
    bool isSecNewDay = ta.change(time("D", "0915-1530:23456", "Asia/Kolkata")) != 0
    ta.vwap(close, isSecNewDay)

niftyVwap = request.security(indexTicker, "5", f_getNiftyVwap(), barmerge.gaps_off, barmerge.lookahead_off)

f_getNifty30mContext() =>
    var float orbH = na
    var float orbL = na
    bool isSecNewDay = ta.change(time("D", "0915-1530:23456", "Asia/Kolkata")) != 0
    if isSecNewDay
        orbH := high
        orbL := low
    else if hour(time, "Asia/Kolkata") == 9 and minute(time, "Asia/Kolkata") == 15
        orbH := math.max(nz(orbH, high), high)
        orbL := math.min(nz(orbL, low), low)
    bool isOrbDone = not (hour(time, "Asia/Kolkata") == 9 and minute(time, "Asia/Kolkata") < 45)
    
    float sOpen = ta.valuewhen(isSecNewDay, open, 0)
    
    var float bHigh = na
    var float bLow  = na
    if isSecNewDay
        bHigh := high
        bLow  := low
    else
        bHigh := math.max(nz(bHigh, high), high)
        bLow  := math.min(nz(bLow, low), low)
    [orbH, orbL, isOrbDone, sOpen, bHigh, bLow]

[niftyOrbHigh, niftyOrbLow, isPastOrbWindow, niftySessionOpen, liveNiftyDayHigh, liveNiftyDayLow] = request.security(indexTicker, "30", f_getNifty30mContext(), barmerge.gaps_off, barmerge.lookahead_off)

bool isOrbActive    = not na(niftyOrbHigh) and not na(niftyOrbLow)
bool isAboveOrbHigh = isOrbActive and isPastOrbWindow and niftyM30Close > niftyOrbHigh
bool isBelowOrbLow  = isOrbActive and isPastOrbWindow and niftyM30Close < niftyOrbLow

string orbText  = "ORB: INSIDE"
color  orbColor = color.yellow

if isOrbActive
    if not isPastOrbWindow
        orbText  := "ORB: FORMING"
        orbColor := color.gray
    else if isAboveOrbHigh
        orbText  := "ORB: BREAKOUT ▲"
        orbColor := color.lime
    else if isBelowOrbLow
        orbText  := "ORB: BREAKDOWN ▼"
        orbColor := color.red
    else
        orbText  := "ORB: INSIDE"
        orbColor := color.yellow

float safeNiftyOpen = not na(niftySessionOpen) and niftySessionOpen > 0 ? niftySessionOpen : (not na(niftyOpen) and niftyOpen > 0 ? niftyOpen : nz(niftyM30Close, 1.0))
pctFromOpen = ((niftyM30Close - safeNiftyOpen) / safeNiftyOpen) * 100.0

float rawDaySpread     = not na(liveNiftyDayHigh) and not na(liveNiftyDayLow) ? (liveNiftyDayHigh - liveNiftyDayLow) : 0.0
float dayRange         = math.max(rawDaySpread, 1.0)
float benchRefPrice    = not na(niftyClose) and niftyClose > 0 ? niftyClose : 1000.0
float minDynamicSpread = math.max(benchRefPrice * 0.0001, syminfo.mintick)

bool  hasEstablishedDaySpread = rawDaySpread >= minDynamicSpread
float rangePosition            = hasEstablishedDaySpread and not na(niftyM30Close) and not na(liveNiftyDayLow) ? 
     math.max(0.0, math.min(100.0, ((niftyM30Close - liveNiftyDayLow) / dayRange) * 100.0)) : 0.0

bool isPushingHigher = niftyM15Close > niftyM15Prev
string flowText = isPushingHigher ? "FLOW: UP ▲" : "FLOW: DN ▼"
color  flowColor = isPushingHigher ? color.lime : color.red

bool isAboveVwap = not na(niftyVwap) ? (niftyM30Close >= niftyVwap) : true
float vwapDistPct = not na(niftyVwap) and niftyVwap > 0 ? ((niftyM30Close - niftyVwap) / niftyVwap) * 100.0 : 0.0

string liveBias = ""
color  biasColor = color.white

if isAboveOrbHigh and isAboveVwap and isPushingHigher
    liveBias  := "BIAS: AGGRESSIVE"
    biasColor := color.lime
else if (isAboveOrbHigh or (hasEstablishedDaySpread and rangePosition >= 50.0)) and isAboveVwap
    liveBias  := "BIAS: NORMAL"
    biasColor := color.aqua
else if isBelowOrbLow or (hasEstablishedDaySpread and rangePosition < 40.0 and not isAboveVwap and not isPushingHigher)
    liveBias  := "BIAS: STAND ASIDE"
    biasColor := color.red
else
    liveBias  := "BIAS: DEFENSIVE"
    biasColor := color.yellow

var table mktHud = table.new(mktTblPos, 1, 7, bgcolor=pleasantBodyBg, border_width=1, border_color=pleasantBorder)

if barstate.islast
    table.clear(mktHud, 0, 0, 0, 6)
    
    if showMktHud
        table.cell(mktHud, 0, 0, "NIFTY STATUS", bgcolor=pleasantHeaderBg, text_color=pleasantHeadText, text_size=size.tiny)
        table.cell(mktHud, 0, 1, liveBias, bgcolor=pleasantBodyBg, text_color=biasColor, text_size=size.tiny)
        table.cell(mktHud, 0, 2, orbText, bgcolor=pleasantBodyBg, text_color=orbColor, text_size=size.tiny)

        string rangeText = not hasEstablishedDaySpread ? "RANGE: INIT" : "RANGE: " + str.tostring(rangePosition, "0") + "% (" + (rangePosition >= 60 ? "High" : rangePosition <= 30 ? "Low" : "Mid") + ")"
        color rangeCol = not hasEstablishedDaySpread ? color.gray : rangePosition >= 60 ? color.lime : (rangePosition <= 30 ? color.red : color.yellow)
        table.cell(mktHud, 0, 3, rangeText, bgcolor=pleasantBodyBg, text_color=rangeCol, text_size=size.tiny)

        string openMoveText = "OPEN: " + (pctFromOpen > 0 ? "+" : "") + str.tostring(pctFromOpen, "0.00") + "%"
        color openMoveCol = pctFromOpen >= 0.25 ? color.lime : (pctFromOpen <= -0.25 ? color.red : color.white)
        table.cell(mktHud, 0, 4, openMoveText, bgcolor=pleasantBodyBg, text_color=openMoveCol, text_size=size.tiny)

        string vwapText = na(niftyVwap) ? "VWAP: INIT" : (isAboveVwap ? "VWAP: +" : "VWAP: ") + str.tostring(vwapDistPct, "0.2") + "%"
        color  vwapCol  = na(niftyVwap) ? color.gray : isAboveVwap ? color.lime : color.red

        table.cell(mktHud, 0, 5, vwapText, bgcolor=pleasantBodyBg, text_color=vwapCol, text_size=size.tiny)

        table.cell(mktHud, 0, 6, flowText, bgcolor=pleasantBodyBg, text_color=flowColor, text_size=size.tiny)

if doResetTradeState
    currentEntry        := na
    currentStop         := na
    currentT1           := na
    currentT2           := na
    actualFillPrice     := na
    isTradeActive       := false
    isSetupPending      := false
    t1Achieved          := false
    t1HitBar            := na
    activeT1HitBadge    := na
    activeSetupBadge    := na
    activeAnchorStem    := na
    expTermLbl          := na
    activeOrderQty      := 0
    initialRiskDist     := na
    setupBarIndex       := na
    fillBarIndex        := na
    setupSessionTime    := na

alertcondition(validSetupFired, 
               title="1. 30m Pivot Buy Alert", 
               message="🟢 30m PIVOT SETUP: {{ticker}} formed at ₹{{close}}! Buy stop order pending above high. Check chart for Entry, SL, T1/T2 & Qty.")

alertcondition(condT1HitAlert, 
               title="2. T1 Hit: Move SL to Cost", 
               message="🎯 TARGET 1 HIT on {{ticker}}! Bank partial profits and modify Stop Loss in broker to Cost / Breakeven now.")

alertcondition(condTradeExitAlert, 
               title="3. Trade Exit: SL / T2 / Trail", 
               message="🚨 TRADE EXIT on {{ticker}}! Exit remaining shares now (Reason: Hard Stop Loss Breached, Target 2 Reached, or 30m Close below 8 EMA Trail).")
````
