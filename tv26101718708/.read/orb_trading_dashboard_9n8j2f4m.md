# ORB Trading Dashboard

- url: https://www.tradingview.com/script/9n8j2F4m-ORB-Trading-Dashboard/
- type: indicator
- pine_id: PUB;b556aa5ee9534c3495c45aef66cce79d
- version: 4.0

## Description

[b]ORB Trading Dashboard[/b] is a multi-factor intraday decision-support indicator built for fast market context.
It combines opening range behavior, trend structure, momentum, volume, and key levels into a single table with a weighted directional bias.

[b]Features[/b]

[b]Multi-timeframe ORB Status (5m / 15m / 30m)[/b]
[list]
[*]Location-based ORB logic after each window completes
[*]Bullish above ORB high
[*]Bearish below ORB low
[*]Inside = price within range
[*]Time gates:
[list]
[*]5m after 9:35 ET
[*]15m after 9:45 ET
[*]30m after 10:00 ET
[/list]
[/list]

[b]Weighted Bias Model (max +/-21)[/b]
[list]
[*]Converts multiple market factors into a single directional score
[*]Bias states:
[list]
[*]Strong Bull
[*]Bullish
[*]Lean Bull
[*]Neutral
[*]Lean Bear
[*]Bearish
[*]Strong Bear
[/list]
[/list]

[b]EMA Trend Structure[/b]
[list]
[*]Price vs Daily EMA 8 / 21 / 50 / 100 / 200
[*]EMA stacking used to grade trend quality
[/list]

[b]VWAP Context with Volatility Bands[/b]
[list]
[*]Session VWAP with SD1 / SD2 levels
[*]Bias adjusts based on price relative to VWAP and SD1
[/list]

[b]Key Level Context[/b]
[list]
[*]Yesterday high/low behavior
[*]Premarket high/low behavior
[*]Session position (top / mid / bottom of intraday range)
[/list]

[b]Higher Timeframe Directional Filter[/b]
[list]
[*]Current week open status
[*]Current month open status
[/list]

[b]Momentum & Participation[/b]
[list]
[*]DMI / ADX direction and trend strength
[*]Relative Volume (RVOL) confirmation or low-conviction penalty
[/list]

[b]Extension Awareness[/b]
[list]
[*]ATR multiples from Daily EMA50 to identify trend health vs overextension
[/list]

[b]Practical Dashboard Metrics[/b]
[list]
[*]LoD distance %
[*]ATR / DTR %
[*]RVOL
[*]Weekly / monthly status
[*]Optional EMA and key level plots
[/list]

[b]Settings[/b]

[b]Display Options[/b]
[list]
[*]Table position
[*]Text size
[*]Toggle rows:
[list]
[*]ORB 5-Min
[*]ORB 30-Min
[*]Session High/Low
[/list]
[*]Toggle chart plots:
[list]
[*]Daily EMA 8 / 21 / 50 / 100 / 200
[*]Yesterday High/Low
[*]Premarket High/Low
[/list]
[/list]

[b]Alert Options[/b]
[list]
[*]Enable 5-Min ORB alerts
[*]Enable 15-Min ORB alerts
[*]Enable 30-Min ORB alerts
[/list]

[b]Indicator Inputs[/b]
[list]
[*]DMI/ADX length
[*]ADX smoothing
[/list]

[b]How to Use[/b]
[quote]
Use the bias score as a structured context layer, not as a standalone signal.
Combine it with your own entries, risk management, and session awareness.
[/quote]

[b]Optional: How to Read the Table[/b]
[list]
[*]Bias: composite directional score
[*]ORB 5/15/30: opening range state (Bullish / Bearish / Inside)
[*]VWAP / SD1 / SD2: mean and volatility context
[*]ADX / DI: trend strength and direction
[*]Key levels: yesterday, premarket, session positioning
[*]Metrics: LoD %, ATR/DTR, ATR vs EMA50, RVOL
[/list]

[b]Disclaimer[/b]
[quote]
This indicator is for educational and informational purposes only.
Always perform your own analysis and manage risk appropriately.
[/quote]

## Source Code

````pine
//@version=6
indicator("ORB Trading Dashboard", overlay=true, max_lines_count=500, max_labels_count=500)

// ==================================================================================
// CHANGES vs the previous version (see git history)
// 1. ORB state machine: buffered failure from any stage, failed side re-arms, net
//    direction follows the latest active side, 30-min ORB is exactly 9:30-10:00.
// 2. Daily reset by the ET date of each 1-min bar (no 9:30 chart bar needed).
// 3. Alerts use completed 1-min bars; 30-min and bias-flip alerts fire at bar close.
// 4. D/W/M values come from the last completed period (previously repainted on history).
// 5. RVOL vs average cumulative volume at the same minute; "(lin)" = fallback.
// 6. DMI/ADX removed; Confidence has 5 votes (High >= 4, Medium >= 2).
// 7. Daily MAs are SMA (default) or EMA via "Daily MA Type" (were EMA only).
// ==================================================================================

// SCORING
// Bias:  MA trend/stack, ORB/VWAP, key levels, week/month opens, market regime,
//        relative strength, target room, MA50 ATR extension.
// Setup: ORB stage and failures, ORB range vs ATR, RVOL, DTR room, extension.

// ==================== INPUTS ====================
// Display settings
showDashboard = input.bool(true, "Show Dashboard Table", group="Display Options")
tablePosition = input.string("Bottom Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Display Options")
textSizeOption = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group="Display Options")
showORB5 = input.bool(false, "Show ORB 5-Min Row", group="Display Options")
showORB30 = input.bool(true, "Show ORB 30-Min Row", group="Display Options")
showSessionHL = input.bool(false, "Show Session High/Low Row", group="Display Options")
showSetupRow = input.bool(false, "Show Setup Row", group="Display Options")
showScoreBreakdown = input.bool(false, "Show Score Breakdown Rows", group="Display Options")
showHTFRows = input.bool(false, "Show Current Week/Month Rows", group="Display Options")
showDailyMARows = input.bool(false, "Show Daily MA Rows", group="Display Options")
showATRFromMA50Row = input.bool(false, "Show ATR×MA50 Row", group="Display Options")
showMA100 = input.bool(false, "Show Daily MA 100", group="Display Options")
showMA200 = input.bool(false, "Show Daily MA 200", group="Display Options")
showMA8 = input.bool(false, "Show Daily MA 8 Plot", group="Display Options")
showMA21 = input.bool(false, "Show Daily MA 21 Plot", group="Display Options")
showMA50 = input.bool(false, "Show Daily MA 50 Plot", group="Display Options")
showYesterdayLevels = input.bool(false, "Show Yesterday High/Low", group="Display Options")
showPremarketLevels = input.bool(false, "Show Premarket High/Low", group="Display Options")

// Chart line settings (from ORB Breakout & Retest)
showORBLines = input.bool(false, "Show ORB Lines on Chart", group="Chart Lines")
show5MinLines = input.bool(false, "Show 5-Min ORB Lines", group="Chart Lines")
show15MinLines = input.bool(false, "Show 15-Min ORB Lines", group="Chart Lines")
show30MinLines = input.bool(false, "Show 30-Min ORB Lines", group="Chart Lines")
orbLineColor = color.rgb(76, 175, 80)
orbLineWidth = input.int(2, "Line Width", minval=1, maxval=5, group="Chart Lines")
orbLineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Chart Lines")
showORBLabels = input.bool(true, "Show ORB Labels", group="Chart Lines")
showORBFill = input.bool(true, "Show Range Fill", group="Chart Lines")
showMidline = input.bool(false, "Show Midline", group="Chart Lines")
orbLabelOffset = input.int(10, "Label Offset (bars)", minval=1, maxval=50, group="Chart Lines")

// Alert settings
// ORB alerts default ON; they do nothing until an "Any alert() function call" alert exists.
enableAlerts5Min = input.bool(true, "Enable 5-Min ORB Alerts", group="Alert Options")
enableAlerts15Min = input.bool(true, "Enable 15-Min ORB Alerts", group="Alert Options")
enableAlerts30Min = input.bool(true, "Enable 30-Min ORB Alerts", group="Alert Options")
enableBiasFlipAlerts = input.bool(false, "Enable Bias Flip Alerts", group="Alert Options")
reAlertAfterFail = input.bool(false, "Re-alert if a failed ORB side confirms again", group="Alert Options", tooltip="Off: one 5/15-min CONFIRMED alert per side per day. On: a side that fails and then completes a new breakout -> retest -> confirm sequence alerts again. The dashboard rows re-arm either way.")

// Indicator settings
maType = input.string("SMA", "Daily MA Type", options=["EMA", "SMA"], group="Indicators", tooltip="Moving average type for the daily 8/21/50/100/200 MAs used in the trend score, extension, rows and plots.")
avgVolumeLength = input.int(20, "Average Volume Length", minval=1, group="Indicators")
benchmarkSymbol = input.symbol("SPY", "Relative Strength Benchmark", group="Indicators")

// ORB logic
orbBufferPct = input.float(10.0, "ORB Failure Buffer (% of OR range)", minval=0.0, maxval=50.0, step=1.0, group="ORB Logic", tooltip="A breakout fails only when a completed 1-min bar closes back inside the range by more than this distance, so a retest that dips just inside doesn't count as a failure. A retest still has to touch the level. 0 = any close back inside fails.")

// Session constants (US equities, regular session in ET)
TZ = "America/New_York"
RTH_OPEN_MIN = 9 * 60 + 30
RTH_CLOSE_MIN = 16 * 60
RTH_MINUTES = 390

clampScore(value, minValue, maxValue) =>
    value < minValue ? minValue : value > maxValue ? maxValue : value

dirLabel(score) =>
    score > 0 ? "+" + str.tostring(score, "#") : str.tostring(score, "#")

formatVolume(value) =>
    na(value) ? "N/A" : value >= 1000000000 ? str.tostring(value / 1000000000, "#.##") + "B" : value >= 1000000 ? str.tostring(value / 1000000, "#.##") + "M" : value >= 1000 ? str.tostring(value / 1000, "#.##") + "K" : str.tostring(value, "#")

biasLabelFromScore(score) =>
    score >= 18 ? "Strong Bull" : score >= 11 ? "Bullish" : score >= 5 ? "Lean Bull" : score <= -18 ? "Strong Bear" : score <= -11 ? "Bearish" : score <= -5 ? "Lean Bear" : "Neutral"

biasColorFromScore(score) =>
    score >= 18 ? color.rgb(0, 150, 0) : score >= 11 ? color.rgb(38, 166, 154) : score >= 5 ? color.rgb(76, 175, 80) : score <= -18 ? color.rgb(180, 0, 0) : score <= -11 ? color.rgb(239, 83, 80) : score <= -5 ? color.rgb(244, 67, 54) : color.rgb(255, 152, 0)

setupLabelFromScore(score) =>
    score >= 8 ? "A+" : score >= 5 ? "A" : score >= 2 ? "B" : score <= -5 ? "Failed" : score <= -2 ? "Weak" : "Wait"

setupColorFromScore(score) =>
    score >= 8 ? color.rgb(0, 150, 0) : score >= 5 ? color.rgb(38, 166, 154) : score >= 2 ? color.rgb(76, 175, 80) : score <= -5 ? color.rgb(180, 0, 0) : score <= -2 ? color.rgb(239, 83, 80) : color.rgb(255, 152, 0)

confidenceLabelFromScore(score) =>
    score >= 4 ? "High" : score >= 2 ? "Medium" : "Low"

orbStageText(stage, status) =>
    stage == 3 ? "Confirmed" : stage == 2 ? "Retest" : stage == 1 ? "Breakout" : stage == -1 ? "Failed" : status

// ==================== CALCULATIONS ====================
// --- Higher-timeframe data, non-repainting ---
// lookahead_on returns the mapped HTF bar and its [1]. Use the bar itself only if it closed on an
// earlier ET date, else [1], so only completed periods are read. RTH ticker keeps levels RTH-based.
rthTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.regular)

pickClosed(isClosed, cur, prev) =>
    isClosed ? cur : prev

// ET calendar day key (yyyymmdd)
f_dayKey(t) =>
    year(t, TZ) * 10000 + month(t, TZ) * 100 + dayofmonth(t, TZ)

// True if the HTF bar closed on an earlier ET date (after-hours still shows the prior session).
f_closedBefore(htfClose) =>
    not na(htfClose) and htfClose <= time and f_dayKey(htfClose) != f_dayKey(time)

// Both MAs are computed on every bar so each keeps its own history; the input picks one.
f_ma(len) =>
    e = ta.ema(close, len)
    s = ta.sma(close, len)
    maType == "EMA" ? e : s

f_dailyData() =>
    m8_ = f_ma(8)
    m21_ = f_ma(21)
    m50_ = f_ma(50)
    m100_ = f_ma(100)
    m200_ = f_ma(200)
    atr_ = ta.atr(14)
    vol_ = ta.sma(volume, avgVolumeLength)
    [time_close, high, low, close, m8_, m21_, m50_, m100_, m200_, atr_, vol_, high[1], low[1], close[1], m8_[1], m21_[1], m50_[1], m100_[1], m200_[1], atr_[1], vol_[1]]

f_periodData() =>
    [time, time_close, open, open[1], high, low, high[1], low[1]]

[dTC, dH0, dL0, dC0, dM8_0, dM21_0, dM50_0, dM100_0, dM200_0, dATR0, dVol0, dH1, dL1, dC1, dM8_1, dM21_1, dM50_1, dM100_1, dM200_1, dATR1, dVol1] = request.security(rthTicker, "D", f_dailyData(), lookahead=barmerge.lookahead_on)
[wT, wTC, wO, wO1, wH0, wL0, wH1, wL1] = request.security(rthTicker, "W", f_periodData(), lookahead=barmerge.lookahead_on)
[mT, mTC, mO, mO1, mH0, mL0, mH1, mL1] = request.security(rthTicker, "M", f_periodData(), lookahead=barmerge.lookahead_on)
[benchClose, benchVwap] = request.security(benchmarkSymbol, timeframe.period, [close, ta.vwap(close)], lookahead=barmerge.lookahead_off)
[bTC, bC0, bC1] = request.security(benchmarkSymbol, "D", [time_close, close, close[1]], lookahead=barmerge.lookahead_on)

dClosed = f_closedBefore(dTC)
wClosed = f_closedBefore(wTC)
mClosed = f_closedBefore(mTC)
bClosed = f_closedBefore(bTC)

// Last completed session/week/month values
yesterdayHigh = pickClosed(dClosed, dH0, dH1)
yesterdayLow = pickClosed(dClosed, dL0, dL1)
prevDailyClose = pickClosed(dClosed, dC0, dC1)
ma8 = pickClosed(dClosed, dM8_0, dM8_1)
ma21 = pickClosed(dClosed, dM21_0, dM21_1)
ma50 = pickClosed(dClosed, dM50_0, dM50_1)
ma100 = pickClosed(dClosed, dM100_0, dM100_1)
ma200 = pickClosed(dClosed, dM200_0, dM200_1)
dailyATR = pickClosed(dClosed, dATR0, dATR1)
avgDailyVol = pickClosed(dClosed, dVol0, dVol1)
prevWeekHigh = pickClosed(wClosed, wH0, wH1)
prevWeekLow = pickClosed(wClosed, wL0, wL1)
prevMonthHigh = pickClosed(mClosed, mH0, mH1)
prevMonthLow = pickClosed(mClosed, mL0, mL1)
// Current week/month open once that period has started, else the prior period's open.
currWeekOpen = not na(wT) and wT <= time ? wO : wO1
currMonthOpen = not na(mT) and mT <= time ? mO : mO1
benchPrevDailyClose = pickClosed(bClosed, bC0, bC1)

rVol = ta.sma(volume, avgVolumeLength)
liveBarForming = barstate.isrealtime and not barstate.isconfirmed

// Persistent Levels for Premarket and Session
var float pmHigh = na
var float pmLow = na
var float sessionHigh = na
var float sessionLow = na
var float cumSessionVol = 0.0
var int lastVolumeBarTime = na
var float cumClosedVol = 0.0       // RTH volume through the last COMPLETED 1-min bar
var int lastClosedVolTime = na
var int sessionStartBar = na       // first chart bar that contains an RTH minute today
var int rthDayKey = na

// Time-of-day volume baseline: EMA of cumulative RTH volume per session minute from prior days.
// Arrays change only on confirmed executions, so realtime rollback can't affect them.
var array<float> rvolBaseCum = array.new_float(RTH_MINUTES, na)
var array<float> todayCum = array.new_float(RTH_MINUTES, na)
var int todayFirstIdx = na
var int todayLastIdx = na
var int rvolDaysFolded = 0
var int ltfDaysSeen = 0            // days with 1-min data before today
var bool todayHasLtf = false

dayKey = f_dayKey(time)
is_new_day = na(dayKey[1]) ? true : dayKey != dayKey[1]
if is_new_day
    // Fold yesterday into the baseline if it was a full session (open to within 10 min of the
    // close). Mean for the first days, then EMA; gaps carry forward.
    if barstate.isconfirmed
        fullDay = not na(todayFirstIdx) and not na(todayLastIdx) and todayLastIdx >= RTH_MINUTES - 10 and (todayFirstIdx == 0 or (todayFirstIdx <= 5 and ltfDaysSeen > 0))
        if fullDay
            alpha = math.max(2.0 / (avgVolumeLength + 1), 1.0 / (rvolDaysFolded + 1))
            float carry = na
            for i = 0 to RTH_MINUTES - 1
                v = array.get(todayCum, i)
                if not na(v)
                    carry := v
                if not na(carry)
                    b = array.get(rvolBaseCum, i)
                    array.set(rvolBaseCum, i, na(b) ? carry : b + (carry - b) * alpha)
            rvolDaysFolded += 1
        ltfDaysSeen += todayHasLtf ? 1 : 0
        todayHasLtf := false
        array.fill(todayCum, float(na))
        todayFirstIdx := na
        todayLastIdx := na
    pmHigh := na
    pmLow := na
    sessionHigh := na
    sessionLow := na
    cumSessionVol := 0.0
    lastVolumeBarTime := na
    cumClosedVol := 0.0
    lastClosedVolTime := na

// 1-min data, requested once and shared by the session stats and all ORB lengths
[ltfH, ltfL, ltfC, ltfT, ltfV] = request.security_lower_tf(syminfo.tickerid, "1", [high, low, close, time, volume])
ltfSize = array.size(ltfT)
// While a realtime bar forms, its last 1-min element may be incomplete, so signals skip it.
ltfLastClosedIdx = liveBarForming ? ltfSize - 2 : ltfSize - 1

if ltfSize > 0
    for i = 0 to ltfSize - 1
        h_ = array.get(ltfH, i)
        l_ = array.get(ltfL, i)
        t_ = array.get(ltfT, i)
        v_ = nz(array.get(ltfV, i))
        mins_ = hour(t_, TZ) * 60 + minute(t_, TZ)

        // Premarket (4:00 AM - 9:29 AM ET)
        if mins_ >= 4 * 60 and mins_ < RTH_OPEN_MIN
            pmHigh := na(pmHigh) ? h_ : math.max(pmHigh, h_)
            pmLow := na(pmLow) ? l_ : math.min(pmLow, l_)

        // Regular session (9:30 AM - 3:59 PM ET)
        if mins_ >= RTH_OPEN_MIN and mins_ < RTH_CLOSE_MIN
            dk_ = f_dayKey(t_)
            if na(rthDayKey) or dk_ != rthDayKey
                rthDayKey := dk_
                sessionStartBar := bar_index
            sessionHigh := na(sessionHigh) ? h_ : math.max(sessionHigh, h_)
            sessionLow := na(sessionLow) ? l_ : math.min(sessionLow, l_)
            if na(lastVolumeBarTime) or t_ > lastVolumeBarTime
                cumSessionVol := cumSessionVol + v_
                lastVolumeBarTime := t_
                if i <= ltfLastClosedIdx
                    cumClosedVol := cumSessionVol
                    lastClosedVolTime := t_
                    if barstate.isconfirmed
                        idx_ = mins_ - RTH_OPEN_MIN
                        array.set(todayCum, idx_, cumSessionVol)
                        todayFirstIdx := na(todayFirstIdx) ? idx_ : todayFirstIdx
                        todayLastIdx := idx_

if barstate.isconfirmed and ltfSize > 0
    todayHasLtf := true

// Current-bar RVOL; uses the last completed bar while a realtime bar forms.
relativeVol = liveBarForming ? (not is_new_day and rVol[1] > 0 ? volume[1] / rVol[1] : na) : (rVol > 0 ? volume / rVol : na)

// Today's RTH range (na before 9:30)
dailyHigh = sessionHigh
dailyLow = sessionLow
dailyTR = dailyHigh - dailyLow

// Breakout + retest + confirmation model for the 5/15/30-min ORB
openTotalMinutes = RTH_OPEN_MIN

orbLineStyle = switch orbLineStyleInput
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

// Completed RTH 1-min bars only. Stage per side: 0 idle, 1 breakout, 2 retest, 3 confirmed, -1 failed.
//   breakout: close beyond the level (re-arms a failed side)
//   retest:   a later bar touches the level
//   confirm:  a later bar closes beyond the level again
//   failure:  close back inside by more than the buffer, from any stage
// Resets on each new ET date. newConfirm: first confirm per side per day (every one if reAlert).
getORBSignalData(orbMinutes, tArr, hArr, lArr, cArr, lastIdx, bufferPct, reAlert) =>
    var int orbDay = na
    var float orbHigh = na
    var float orbLow = na
    var int upStage = 0
    var int downStage = 0
    var int upBreakTime = na
    var int upRetestTime = na
    var int downBreakTime = na
    var int downRetestTime = na
    var int upEventTime = na
    var int downEventTime = na
    var int upConfirms = 0
    var int downConfirms = 0

    newConfirmUp = false
    newConfirmDown = false

    nT = array.size(tArr)
    if nT > 0
        for i = 0 to nT - 1
            t = array.get(tArr, i)
            dk = f_dayKey(t)
            if na(orbDay) or dk != orbDay
                orbDay := dk
                orbHigh := na
                orbLow := na
                upStage := 0
                downStage := 0
                upBreakTime := na
                upRetestTime := na
                downBreakTime := na
                downRetestTime := na
                upEventTime := na
                downEventTime := na
                upConfirms := 0
                downConfirms := 0

            if i > lastIdx
                break

            m = hour(t, TZ) * 60 + minute(t, TZ)
            h = array.get(hArr, i)
            l = array.get(lArr, i)
            c = array.get(cArr, i)

            if m >= RTH_OPEN_MIN and m < RTH_OPEN_MIN + orbMinutes
                orbHigh := na(orbHigh) ? h : math.max(orbHigh, h)
                orbLow := na(orbLow) ? l : math.min(orbLow, l)
            else if m >= RTH_OPEN_MIN + orbMinutes and m < RTH_CLOSE_MIN and not na(orbHigh)
                tol = (orbHigh - orbLow) * bufferPct / 100.0

                // Upside
                if upStage <= 0
                    if c > orbHigh
                        upStage := 1
                        upBreakTime := t
                        upEventTime := t
                else if c < orbHigh - tol
                    upStage := -1
                    upEventTime := t
                else if upStage == 1 and t > upBreakTime and l <= orbHigh
                    upStage := 2
                    upRetestTime := t
                    upEventTime := t
                else if upStage == 2 and t > upRetestTime and c > orbHigh
                    upStage := 3
                    upEventTime := t
                    upConfirms += 1
                    if upConfirms == 1 or reAlert
                        newConfirmUp := true

                // Downside
                if downStage <= 0
                    if c < orbLow
                        downStage := 1
                        downBreakTime := t
                        downEventTime := t
                else if c > orbLow + tol
                    downStage := -1
                    downEventTime := t
                else if downStage == 1 and t > downBreakTime and h >= orbLow
                    downStage := 2
                    downRetestTime := t
                    downEventTime := t
                else if downStage == 2 and t > downRetestTime and c < orbLow
                    downStage := 3
                    downEventTime := t
                    downConfirms += 1
                    if downConfirms == 1 or reAlert
                        newConfirmDown := true

    // Most recent active side wins; a failed opposite side upgrades a breakout to 2.
    upActive = upStage >= 1
    downActive = downStage >= 1
    netStage = upActive and downActive ? (upEventTime >= downEventTime ? upStage : -downStage) : upActive ? (downStage == -1 and upStage == 1 ? 2 : upStage) : downActive ? (upStage == -1 and downStage == 1 ? -2 : -downStage) : 0

    [orbHigh, orbLow, upStage, downStage, netStage, newConfirmUp, newConfirmDown]

[orb5High, orb5Low, orb5UpStage, orb5DownStage, orb5NetStage, orb5NewUp, orb5NewDown] = getORBSignalData(5, ltfT, ltfH, ltfL, ltfC, ltfLastClosedIdx, orbBufferPct, reAlertAfterFail)
[orb15High, orb15Low, orb15UpStage, orb15DownStage, orb15NetStage, orb15NewUp, orb15NewDown] = getORBSignalData(15, ltfT, ltfH, ltfL, ltfC, ltfLastClosedIdx, orbBufferPct, reAlertAfterFail)
[orb30High, orb30Low, orb30UpStage, orb30DownStage, orb30NetStage, orb30NewUp, orb30NewDown] = getORBSignalData(30, ltfT, ltfH, ltfL, ltfC, ltfLastClosedIdx, orbBufferPct, reAlertAfterFail)

// Determine status for dashboard rows and bias inputs
isAfterTime(h, m) =>
    currentTime = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
    currentTime >= (h * 60 + m)

orb5Status = not isAfterTime(9, 35) ? "Inside" : (close > orb5High ? "Bullish" : close < orb5Low ? "Bearish" : "Inside")
orb15Status = not isAfterTime(9, 45) ? "Inside" : (close > orb15High ? "Bullish" : close < orb15Low ? "Bearish" : "Inside")
orb30Status = not isAfterTime(10, 0) ? "Inside" : (close > orb30High ? "Bullish" : close < orb30Low ? "Bearish" : "Inside")
// Row text/colour: active side first (▲/▼); "Failed" only when neither side is active.
orbRowText(netStage, upStage, downStage, status) =>
    netStage > 0 ? "▲ " + orbStageText(upStage, status) : netStage < 0 ? "▼ " + orbStageText(downStage, status) : upStage == -1 or downStage == -1 ? "Failed" : status

orbRowColor(netStage, upStage, downStage, status) =>
    netStage > 0 ? color.rgb(38, 166, 154) : netStage < 0 ? color.rgb(239, 83, 80) : upStage == -1 or downStage == -1 ? color.rgb(180, 0, 0) : status == "Bullish" ? color.rgb(76, 175, 80) : status == "Bearish" ? color.rgb(244, 67, 54) : color.rgb(255, 152, 0)

orb5StateText = orbRowText(orb5NetStage, orb5UpStage, orb5DownStage, orb5Status)
orb15StateText = orbRowText(orb15NetStage, orb15UpStage, orb15DownStage, orb15Status)
orb30StateText = orbRowText(orb30NetStage, orb30UpStage, orb30DownStage, orb30Status)

// Session RVOL vs the same-minute baseline; straight-line fallback until 5 full days exist.
currentEtMinutes = hour(time, TZ) * 60 + minute(time, TZ)
lastClosedIdxRth = na(lastClosedVolTime) ? na : hour(lastClosedVolTime, TZ) * 60 + minute(lastClosedVolTime, TZ) - RTH_OPEN_MIN
baseNow = not na(lastClosedIdxRth) and lastClosedIdxRth >= 0 and lastClosedIdxRth < RTH_MINUTES ? array.get(rvolBaseCum, lastClosedIdxRth) : na
baseFullDay = array.get(rvolBaseCum, RTH_MINUTES - 1)
useTodBaseline = rvolDaysFolded >= 5 and not na(baseNow) and baseNow > 0
rthElapsedMinutes = na(lastClosedIdxRth) ? na : math.min(math.max(lastClosedIdxRth + 1, 1), RTH_MINUTES)
linearProjectedVol = not na(rthElapsedMinutes) and cumClosedVol > 0 ? cumClosedVol / (rthElapsedMinutes / float(RTH_MINUTES)) : na
projectedVol = useTodBaseline and not na(baseFullDay) and baseFullDay > 0 ? cumClosedVol * baseFullDay / baseNow : linearProjectedVol
sessionRVOL = useTodBaseline ? cumClosedVol / baseNow : avgDailyVol > 0 and not na(linearProjectedVol) ? linearProjectedVol / avgDailyVol : na
sessionRVOLPct = not na(sessionRVOL) ? sessionRVOL * 100 : na

// Benchmark-relative strength
symbolDayChange = prevDailyClose > 0 ? (close / prevDailyClose - 1) * 100 : na
benchDayChange = benchPrevDailyClose > 0 ? (benchClose / benchPrevDailyClose - 1) * 100 : na
relativeStrength = not na(symbolDayChange) and not na(benchDayChange) ? symbolDayChange - benchDayChange : na
benchDir = benchClose >= benchVwap ? 1 : -1

// ATR multiples from MA 50
atrFromMa50 = not na(ma50) and not na(dailyATR) and dailyATR > 0 ? (close - ma50) / dailyATR : na

// VWAP and Standard Deviation Bands
vwapValue = ta.vwap(close)
var float sumSrcVwapSqSession = 0.0
var float sumVolSession = 0.0

if is_new_day
    sumSrcVwapSqSession := volume * math.pow(close - vwapValue, 2)
    sumVolSession := volume
else
    sumSrcVwapSqSession := sumSrcVwapSqSession + volume * math.pow(close - vwapValue, 2)
    sumVolSession := sumVolSession + volume

vwapStdev = math.sqrt(sumSrcVwapSqSession / math.max(1, sumVolSession))
vwapSD1Upper = vwapValue + vwapStdev
vwapSD1Lower = vwapValue - vwapStdev
vwapSD2Upper = vwapValue + 2 * vwapStdev
vwapSD2Lower = vwapValue - 2 * vwapStdev

// ==================== ALERTS ====================
// ORB confirm alerts use completed 1-min bars (no wicks). 30-min status and bias-flip alerts
// fire at bar close; their memory resets each ET day.
var string prevOrb30Status = "Inside"
var string prevBiasLabel = na
if is_new_day
    prevOrb30Status := "Inside"
    prevBiasLabel := na

if enableAlerts5Min and orb5NewUp
    alert("5-Min ORB: Breakout+Retest CONFIRMED (Upside) on " + syminfo.ticker + " | ORB High: " + str.tostring(orb5High, format.mintick) + " | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

if enableAlerts5Min and orb5NewDown
    alert("5-Min ORB: Breakdown+Retest CONFIRMED (Downside) on " + syminfo.ticker + " | ORB Low: " + str.tostring(orb5Low, format.mintick) + " | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

if enableAlerts15Min and orb15NewUp
    alert("15-Min ORB: Breakout+Retest CONFIRMED (Upside) on " + syminfo.ticker + " | ORB High: " + str.tostring(orb15High, format.mintick) + " | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

if enableAlerts15Min and orb15NewDown
    alert("15-Min ORB: Breakdown+Retest CONFIRMED (Downside) on " + syminfo.ticker + " | ORB Low: " + str.tostring(orb15Low, format.mintick) + " | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

orb30Window = currentEtMinutes >= RTH_OPEN_MIN + 30 and currentEtMinutes < RTH_CLOSE_MIN
if enableAlerts30Min and barstate.isconfirmed and orb30Window and orb30Status != prevOrb30Status and orb30Status != "Inside"
    alert("30-Min ORB: " + orb30Status + " on " + syminfo.ticker, alert.freq_once_per_bar_close)
    prevOrb30Status := orb30Status

// ==================== TABLE DISPLAY ====================
tablePos = switch tablePosition
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Top Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

txtSize = switch textSizeOption
    "Tiny" => size.tiny
    "Small" => size.small
    "Large" => size.large
    => size.normal

var table dashboard = na

if barstate.islast
    if not showDashboard
        table.delete(dashboard)
        dashboard := na

    // === SCORING ===
    biasScore = 0
    setupScore = 0

    // --- MA trend / structure ---
    maAbove = (close > ma8 ? 1 : 0) + (close > ma21 ? 1 : 0) + (close > ma50 ? 1 : 0) + (close > ma100 ? 1 : 0) + (close > ma200 ? 1 : 0)
    maPosScore = maAbove >= 5 ? 3 : maAbove >= 4 ? 2 : maAbove >= 3 ? 1 : maAbove >= 2 ? -1 : maAbove >= 1 ? -2 : -3
    bullPairs = (ma8 > ma21 ? 1 : 0) + (ma21 > ma50 ? 1 : 0) + (ma50 > ma100 ? 1 : 0) + (ma100 > ma200 ? 1 : 0)
    maStackScore = bullPairs >= 4 ? 2 : bullPairs >= 3 ? 1 : bullPairs <= 0 ? -2 : bullPairs <= 1 ? -1 : 0
    trendScore = maPosScore + maStackScore
    biasScore += trendScore

    // --- Intraday context: richer ORB state plus VWAP location ---
    orbBiasScore = orb15NetStage == 3 ? 3 : orb15NetStage == -3 ? -3 : orb15NetStage == 2 ? 2 : orb15NetStage == -2 ? -2 : orb15Status == "Bullish" ? 1 : orb15Status == "Bearish" ? -1 : 0
    orbBiasScore += orb5NetStage == 3 ? 1 : orb5NetStage == -3 ? -1 : orb5Status == "Bullish" ? 1 : orb5Status == "Bearish" ? -1 : 0
    orbBiasScore := clampScore(orbBiasScore, -4, 4)
    vwapScore = 0
    vwapNearBand = not na(dailyATR) and dailyATR > 0 ? dailyATR * 0.05 : vwapStdev * 0.25
    if close >= vwapSD1Upper
        vwapScore := 5
    else if close >= vwapValue
        vwapScore := 4
    else if close >= vwapValue - vwapNearBand
        vwapScore := 2
    else if close <= vwapSD1Lower
        vwapScore := -5
    else
        vwapScore := -4

    orbFailureScore = 0
    if orb15UpStage == -1
        orbFailureScore -= 3
    if orb15DownStage == -1
        orbFailureScore += 3
    if orb5UpStage == -1
        orbFailureScore -= 1
    if orb5DownStage == -1
        orbFailureScore += 1
    orbFailureScore := clampScore(orbFailureScore, -4, 4)

    minutesFromOpen = currentEtMinutes - openTotalMinutes
    orbDir = orb15NetStage > 0 ? 1 : orb15NetStage < 0 ? -1 : 0
    sessionPhaseScore = 0
    if orbDir != 0
        if minutesFromOpen <= 75 and math.abs(orb15NetStage) == 3
            sessionPhaseScore := orbDir
        else if minutesFromOpen >= 300
            sessionPhaseScore := -orbDir * 2
        else if minutesFromOpen >= 150 and math.abs(orb15NetStage) < 3
            sessionPhaseScore := -orbDir

    intradayScore = orbBiasScore + vwapScore + orbFailureScore + sessionPhaseScore
    biasScore += intradayScore

    // --- Key levels ---
    keyScore = 0
    yestMid = (yesterdayHigh + yesterdayLow) / 2
    if close > yesterdayHigh
        keyScore += 1
    else if close < yesterdayLow
        keyScore -= 1
    else
        keyScore += close >= yestMid ? 1 : -1
    if not na(pmHigh) and not na(pmLow)
        pmMid = (pmHigh + pmLow) / 2
        if close > pmHigh
            keyScore += 1
        else if close < pmLow
            keyScore -= 1
        else
            keyScore += close >= pmMid ? 1 : -1
    // Session position: top 25% = +1, bottom 25% = -1
    if not na(sessionHigh) and not na(sessionLow) and sessionHigh > sessionLow
        sessRange = sessionHigh - sessionLow
        sessPct = (close - sessionLow) / sessRange
        keyScore += sessPct >= 0.75 ? 1 : sessPct <= 0.25 ? -1 : 0
    keyScore := clampScore(keyScore, -3, 3)
    biasScore += keyScore

    // --- Higher timeframe context ---
    htfScore = (close >= currWeekOpen ? 1 : -1) + (close >= currMonthOpen ? 1 : -1)
    biasScore += htfScore

    // --- Market regime / tape permission ---
    marketRegimeScore = 0
    if not na(benchDayChange)
        marketRegimeScore += benchClose >= benchVwap ? 2 : -2
        marketRegimeScore += benchDayChange > 0.20 ? 2 : benchDayChange > 0 ? 1 : benchDayChange < -0.20 ? -2 : benchDayChange < 0 ? -1 : 0
    marketRegimeScore := clampScore(marketRegimeScore, -4, 4)
    biasScore += marketRegimeScore

    // --- Relative strength vs benchmark ---
    rsScore = 0
    if not na(relativeStrength)
        rsScore := relativeStrength > 0.75 ? 5 : relativeStrength > 0.35 ? 4 : relativeStrength > 0.10 ? 2 : relativeStrength < -0.75 ? -5 : relativeStrength < -0.35 ? -4 : relativeStrength < -0.10 ? -2 : 0
        if orb15Status == "Bullish" and benchDir < 0 and relativeStrength > 0
            rsScore += 1
        if orb15Status == "Bearish" and benchDir > 0 and relativeStrength < 0
            rsScore -= 1
    rsScore := clampScore(rsScore, -6, 6)
    biasScore += rsScore

    // --- Nearby target / support-resistance room ---
    nearestResistance = na(yesterdayHigh) or yesterdayHigh <= close ? na : yesterdayHigh
    nearestResistance := not na(pmHigh) and pmHigh > close and (na(nearestResistance) or pmHigh < nearestResistance) ? pmHigh : nearestResistance
    nearestResistance := not na(prevWeekHigh) and prevWeekHigh > close and (na(nearestResistance) or prevWeekHigh < nearestResistance) ? prevWeekHigh : nearestResistance
    nearestResistance := not na(prevMonthHigh) and prevMonthHigh > close and (na(nearestResistance) or prevMonthHigh < nearestResistance) ? prevMonthHigh : nearestResistance
    nearestResistance := vwapSD2Upper > close and (na(nearestResistance) or vwapSD2Upper < nearestResistance) ? vwapSD2Upper : nearestResistance

    nearestSupport = na(yesterdayLow) or yesterdayLow >= close ? na : yesterdayLow
    nearestSupport := not na(pmLow) and pmLow < close and (na(nearestSupport) or pmLow > nearestSupport) ? pmLow : nearestSupport
    nearestSupport := not na(prevWeekLow) and prevWeekLow < close and (na(nearestSupport) or prevWeekLow > nearestSupport) ? prevWeekLow : nearestSupport
    nearestSupport := not na(prevMonthLow) and prevMonthLow < close and (na(nearestSupport) or prevMonthLow > nearestSupport) ? prevMonthLow : nearestSupport
    nearestSupport := vwapSD2Lower < close and (na(nearestSupport) or vwapSD2Lower > nearestSupport) ? vwapSD2Lower : nearestSupport

    targetRoomScore = 0
    if not na(dailyATR) and dailyATR > 0
        resistanceRoomAtr = not na(nearestResistance) ? (nearestResistance - close) / dailyATR : na
        supportRoomAtr = not na(nearestSupport) ? (close - nearestSupport) / dailyATR : na
        if biasScore > 0 and not na(resistanceRoomAtr)
            targetRoomScore := resistanceRoomAtr < 0.12 ? -3 : resistanceRoomAtr < 0.25 ? -2 : resistanceRoomAtr < 0.40 ? -1 : resistanceRoomAtr > 0.80 ? 1 : 0
        else if biasScore < 0 and not na(supportRoomAtr)
            targetRoomScore := supportRoomAtr < 0.12 ? 3 : supportRoomAtr < 0.25 ? 2 : supportRoomAtr < 0.40 ? 1 : supportRoomAtr > 0.80 ? -1 : 0
    biasScore += targetRoomScore

    // --- Mean-extension context ---
    extensionScore = 0
    if not na(atrFromMa50)
        absExt = math.abs(atrFromMa50)
        extDir = atrFromMa50 > 0 ? 1 : -1
        if absExt > 3.0
            extensionScore := -extDir * 2
        else if absExt > 2.0
            extensionScore := -extDir
        else if absExt >= 1.0
            extensionScore := extDir
    biasScore += extensionScore

    biasDir = biasScore > 0 ? 1 : biasScore < 0 ? -1 : 0
    confidenceScore = 0
    if biasDir != 0
        confidenceScore += trendScore * biasDir > 0 ? 1 : 0
        confidenceScore += intradayScore * biasDir > 0 ? 1 : 0
        confidenceScore += marketRegimeScore * biasDir > 0 ? 1 : 0
        confidenceScore += rsScore * biasDir > 0 ? 1 : 0
        confidenceScore += extensionScore * biasDir > 0 ? 1 : 0

    // --- Setup quality: ORB state, range quality, confirmation volume, failures, room, extension ---
    orbSetupScore = orb15NetStage == 3 ? 4 : orb15NetStage == -3 ? 4 : math.abs(orb15NetStage) == 2 ? 2 : math.abs(orb15NetStage) == 1 ? 1 : 0
    orbSetupScore += orb5NetStage == orb15NetStage and math.abs(orb15NetStage) > 0 ? 1 : 0
    // Failed-ORB penalty only when no side is active (a reversal scores by its active side).
    if orb15NetStage == 0 and (orb15UpStage == -1 or orb15DownStage == -1)
        orbSetupScore -= 3
    setupScore += orbSetupScore

    rangeQualityScore = 0
    if not na(orb15High) and not na(orb15Low) and not na(dailyATR) and dailyATR > 0
        orbRange = orb15High - orb15Low
        orbAtrPct = orbRange / dailyATR
        rangeQualityScore := orbAtrPct < 0.08 ? -1 : orbAtrPct <= 0.35 ? 2 : orbAtrPct <= 0.55 ? 1 : orbAtrPct >= 0.85 ? -2 : 0
    setupScore += rangeQualityScore

    volumeScore = 0
    // Straight-line fallback overstates early RVOL, so it scores only after the first hour.
    if not na(sessionRVOL) and (useTodBaseline or rthElapsedMinutes >= 60)
        volumeScore := sessionRVOL >= 1.8 ? 2 : sessionRVOL >= 1.2 ? 1 : sessionRVOL < 0.65 ? -2 : sessionRVOL < 0.85 ? -1 : 0
    if not na(relativeVol)
        volumeScore += relativeVol >= 1.5 ? 1 : relativeVol < 0.5 ? -1 : 0
    volumeScore := clampScore(volumeScore, -3, 3)
    setupScore += volumeScore

    dtrPctForScore = not na(dailyATR) and dailyATR > 0 ? dailyTR / dailyATR * 100 : na
    roomScore = 0
    if not na(dtrPctForScore)
        roomScore := dtrPctForScore > 120 ? -2 : dtrPctForScore > 95 ? -1 : dtrPctForScore < 45 and orb15Status != "Inside" ? 1 : 0
    setupScore += roomScore

    setupExtensionScore = 0
    if not na(atrFromMa50)
        setupExtensionScore := math.abs(atrFromMa50) > 3 ? -2 : math.abs(atrFromMa50) > 2 ? -1 : 0
    setupScore += setupExtensionScore

    biasLabel = biasLabelFromScore(biasScore)
    biasColor = biasColorFromScore(biasScore)
    confidenceLabel = confidenceLabelFromScore(confidenceScore)
    setupLabel = setupLabelFromScore(setupScore)
    setupColor = setupColorFromScore(setupScore)
    biasBreakdown = "T " + dirLabel(trendScore) + " | ORB/V " + dirLabel(intradayScore) + " | Mkt " + dirLabel(marketRegimeScore) + " | Key " + dirLabel(keyScore) + " | HTF " + dirLabel(htfScore) + " | RS " + dirLabel(rsScore) + " | Room " + dirLabel(targetRoomScore) + " | Ext " + dirLabel(extensionScore)
    setupBreakdown = "ORB " + dirLabel(orbSetupScore) + " | Rng " + dirLabel(rangeQualityScore) + " | Vol " + dirLabel(volumeScore) + " | DTR " + dirLabel(roomScore) + " | Ext " + dirLabel(setupExtensionScore)

    // Bias flip: bar close, RTH only; prevBiasLabel resets each ET day.
    rthBar = currentEtMinutes >= RTH_OPEN_MIN and currentEtMinutes < RTH_CLOSE_MIN
    if barstate.isconfirmed
        if enableBiasFlipAlerts and rthBar and barstate.isrealtime and not na(prevBiasLabel) and biasLabel != prevBiasLabel
            alert("Bias Flip: " + prevBiasLabel + " -> " + biasLabel + " on " + syminfo.ticker + " | Score: " + str.tostring(biasScore, "#") + " | Confidence: " + confidenceLabel, alert.freq_once_per_bar_close)
        prevBiasLabel := rthBar ? biasLabel : na

    if showDashboard
        dashboard := table.new(tablePos, 2, 31, border_width=1)
        currentRow = 0

        // Row: BIAS (always first)
        table.cell(dashboard, 0, currentRow, "Bias", bgcolor=color.rgb(30, 30, 50), text_color=color.white, text_size=txtSize)
        table.cell(dashboard, 1, currentRow, biasLabel + " (" + str.tostring(biasScore, "#") + ", " + confidenceLabel + ")", bgcolor=biasColor, text_color=color.white, text_size=txtSize)
        currentRow += 1

        // Row: Setup Quality (optional)
        if showSetupRow
            table.cell(dashboard, 0, currentRow, "Setup", bgcolor=color.rgb(30, 30, 50), text_color=color.white, text_size=txtSize)
            table.cell(dashboard, 1, currentRow, setupLabel + " (" + str.tostring(setupScore, "#") + ")", bgcolor=setupColor, text_color=color.white, text_size=txtSize)
            currentRow += 1

        // Rows: Score Breakdown (optional)
        if showScoreBreakdown
            table.cell(dashboard, 0, currentRow, "Bias Parts", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            table.cell(dashboard, 1, currentRow, biasBreakdown, bgcolor=color.rgb(33, 150, 243), text_color=color.white, text_size=txtSize)
            currentRow += 1

            table.cell(dashboard, 0, currentRow, "Setup Parts", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            table.cell(dashboard, 1, currentRow, setupBreakdown, bgcolor=color.rgb(33, 150, 243), text_color=color.white, text_size=txtSize)
            currentRow += 1

        // Row: ORB 5-Min (conditional)
        if showORB5
            table.cell(dashboard, 0, currentRow, "ORB 5-Min", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            orb5Color = orbRowColor(orb5NetStage, orb5UpStage, orb5DownStage, orb5Status)
            table.cell(dashboard, 1, currentRow, orb5StateText, bgcolor=orb5Color, text_color=color.white, text_size=txtSize)
            currentRow += 1

        // Row: ORB 15-Min
        table.cell(dashboard, 0, currentRow, "ORB 15-Min", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
        orb15Color = orbRowColor(orb15NetStage, orb15UpStage, orb15DownStage, orb15Status)
        table.cell(dashboard, 1, currentRow, orb15StateText, bgcolor=orb15Color, text_color=color.white, text_size=txtSize)
        currentRow += 1

        // Row: ORB 30-Min (conditional)
        if showORB30
            table.cell(dashboard, 0, currentRow, "ORB 30-Min", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            orb30Color = orbRowColor(orb30NetStage, orb30UpStage, orb30DownStage, orb30Status)
            table.cell(dashboard, 1, currentRow, orb30StateText, bgcolor=orb30Color, text_color=color.white, text_size=txtSize)
            currentRow += 1

        // Row: VWAP & Bands
        table.cell(dashboard, 0, currentRow, "VWAP/SD1/SD2", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
        vwapColor = close >= vwapValue ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
        vwapStr = close >= vwapValue ? str.tostring(vwapValue, format.mintick) + " / " + str.tostring(vwapSD1Upper, format.mintick) + " / " + str.tostring(vwapSD2Upper, format.mintick) : str.tostring(vwapValue, format.mintick) + " / " + str.tostring(vwapSD1Lower, format.mintick) + " / " + str.tostring(vwapSD2Lower, format.mintick)
        table.cell(dashboard, 1, currentRow, vwapStr, bgcolor=vwapColor, text_color=color.white, text_size=txtSize)
        currentRow += 1

        // Row: Yesterday High/Low Status
        table.cell(dashboard, 0, currentRow, "Yest H/L", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
        yesterdayStatus = close > yesterdayHigh ? "Bullish" : close < yesterdayLow ? "Bearish" : "Neutral"
        yesterdayColor = close > yesterdayHigh ? color.rgb(38, 166, 154) : close < yesterdayLow ? color.rgb(239, 83, 80) : color.rgb(255, 152, 0)
        table.cell(dashboard, 1, currentRow, yesterdayStatus, bgcolor=yesterdayColor, text_color=color.white, text_size=txtSize)
        currentRow += 1

        // Row: Premarket High/Low Status
        table.cell(dashboard, 0, currentRow, "PM H/L", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
        if not na(pmHigh) and not na(pmLow)
            pmStatus = close > pmHigh ? "Bullish" : close < pmLow ? "Bearish" : "Neutral"
            pmColor = close > pmHigh ? color.rgb(38, 166, 154) : close < pmLow ? color.rgb(239, 83, 80) : color.rgb(255, 152, 0)
            table.cell(dashboard, 1, currentRow, pmStatus, bgcolor=pmColor, text_color=color.white, text_size=txtSize)
        else
            table.cell(dashboard, 1, currentRow, "N/A", bgcolor=color.rgb(33, 150, 243), text_color=color.white, text_size=txtSize)
        currentRow += 1

        // Row: Session High/Low (conditional)
        if showSessionHL
            table.cell(dashboard, 0, currentRow, "Sess H/L", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            if not na(sessionHigh) and not na(sessionLow)
                sessStr = str.tostring(sessionHigh, format.mintick) + " / " + str.tostring(sessionLow, format.mintick)
                sessColor = close >= (sessionHigh + sessionLow) / 2 ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
                table.cell(dashboard, 1, currentRow, sessStr, bgcolor=sessColor, text_color=color.white, text_size=txtSize)
            else
                table.cell(dashboard, 1, currentRow, "N/A", bgcolor=color.rgb(33, 150, 243), text_color=color.white, text_size=txtSize)
            currentRow += 1

        // Row: Low of Day Distance %
        lodDist = dailyATR > 0 ? (close - dailyLow) / dailyATR * 100 : na
        lodDistStr = na(lodDist) ? "N/A" : str.tostring(lodDist, "#.##") + "%"
        lodColor = color.rgb(33, 150, 243)
        if not na(lodDist)
            if lodDist < 30
                lodColor := color.rgb(239, 83, 80)
            else if lodDist < 70
                lodColor := color.rgb(38, 166, 154)
            else if lodDist <= 100
                lodColor := color.rgb(129, 199, 132)
            else
                lodColor := color.rgb(255, 152, 0)
        table.cell(dashboard, 0, currentRow, "LoD Dist %", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
        table.cell(dashboard, 1, currentRow, lodDistStr, bgcolor=lodColor, text_color=color.white, text_size=txtSize)
        currentRow += 1

        // Row: ATR / DTR combined
        table.cell(dashboard, 0, currentRow, "ATR / DTR", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
        if not na(dailyATR) and not na(dailyTR) and dailyATR > 0
            dtrPct = dailyTR / dailyATR * 100
            atrDtrStr = "$" + str.tostring(dailyATR, format.mintick) + " / $" + str.tostring(dailyTR, format.mintick) + " (" + str.tostring(dtrPct, "#") + "%)"
            atrDtrColor = dtrPct > 100 ? color.rgb(255, 152, 0) : dtrPct > 75 ? color.rgb(129, 199, 132) : dtrPct > 50 ? color.rgb(38, 166, 154) : color.rgb(33, 150, 243)
            table.cell(dashboard, 1, currentRow, atrDtrStr, bgcolor=atrDtrColor, text_color=color.white, text_size=txtSize)
        else
            table.cell(dashboard, 1, currentRow, na(dailyATR) ? "N/A" : "$" + str.tostring(dailyATR, format.mintick), bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
        currentRow += 1

        // Row: ATR multiples from MA 50 (conditional)
        if showATRFromMA50Row
            table.cell(dashboard, 0, currentRow, "ATR×" + maType + "50", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            if not na(atrFromMa50)
                atrMaStr = str.tostring(atrFromMa50, "#.##") + "x"
                atrMaColor = math.abs(atrFromMa50) > 2 ? color.rgb(255, 152, 0) : atrFromMa50 > 0 ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
                table.cell(dashboard, 1, currentRow, atrMaStr, bgcolor=atrMaColor, text_color=color.white, text_size=txtSize)
            else
                table.cell(dashboard, 1, currentRow, "N/A", bgcolor=color.rgb(33, 150, 243), text_color=color.white, text_size=txtSize)
            currentRow += 1

        // Row: Relative Volume / Projected Volume
        table.cell(dashboard, 0, currentRow, "RVol / PVol", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
        if not na(sessionRVOL)
            rvolStr = str.tostring(sessionRVOLPct, "#") + "% / " + formatVolume(projectedVol) + (useTodBaseline ? "" : " (lin)")
            rvolColor = sessionRVOL >= 1.8 ? color.rgb(0, 150, 0) : sessionRVOL >= 1.2 ? color.rgb(38, 166, 154) : sessionRVOL >= 0.85 ? color.rgb(76, 175, 80) : sessionRVOL >= 0.65 ? color.rgb(255, 152, 0) : color.rgb(239, 83, 80)
            table.cell(dashboard, 1, currentRow, rvolStr, bgcolor=rvolColor, text_color=color.white, text_size=txtSize)
        else
            table.cell(dashboard, 1, currentRow, "N/A", bgcolor=color.rgb(33, 150, 243), text_color=color.white, text_size=txtSize)
        currentRow += 1

        // Row: Relative Strength
        table.cell(dashboard, 0, currentRow, "Rel. Str", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
        if not na(relativeStrength)
            rsStr = str.tostring(relativeStrength, "#.##") + "% vs " + benchmarkSymbol
            rsColor = relativeStrength > 0.10 ? color.rgb(38, 166, 154) : relativeStrength < -0.10 ? color.rgb(239, 83, 80) : color.rgb(255, 152, 0)
            table.cell(dashboard, 1, currentRow, rsStr, bgcolor=rsColor, text_color=color.white, text_size=txtSize)
        else
            table.cell(dashboard, 1, currentRow, "N/A", bgcolor=color.rgb(33, 150, 243), text_color=color.white, text_size=txtSize)
        currentRow += 1

        // Rows: Current Week/Month Status (conditional)
        if showHTFRows
            table.cell(dashboard, 0, currentRow, "Curr. Week", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            currWeekStatus = close >= currWeekOpen ? "Bullish" : "Bearish"
            currWeekColor = close >= currWeekOpen ? color.rgb(38, 166, 154) : color.rgb(239, 83, 80)
            table.cell(dashboard, 1, currentRow, currWeekStatus, bgcolor=currWeekColor, text_color=color.white, text_size=txtSize)
            currentRow += 1

            table.cell(dashboard, 0, currentRow, "Curr. Month", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            currMonthStatus = close >= currMonthOpen ? "Bullish" : "Bearish"
            currMonthColor = close >= currMonthOpen ? color.rgb(38, 166, 154) : color.rgb(239, 83, 80)
            table.cell(dashboard, 1, currentRow, currMonthStatus, bgcolor=currMonthColor, text_color=color.white, text_size=txtSize)
            currentRow += 1

        // Rows: Daily MAs (conditional)
        if showDailyMARows
            table.cell(dashboard, 0, currentRow, maType + " 8", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            ma8Color = close > ma8 ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
            table.cell(dashboard, 1, currentRow, str.tostring(ma8, format.mintick), bgcolor=ma8Color, text_color=color.white, text_size=txtSize)
            currentRow += 1

            table.cell(dashboard, 0, currentRow, maType + " 21", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            ma21Color = close > ma21 ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
            table.cell(dashboard, 1, currentRow, str.tostring(ma21, format.mintick), bgcolor=ma21Color, text_color=color.white, text_size=txtSize)
            currentRow += 1

            table.cell(dashboard, 0, currentRow, maType + " 50", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            ma50Color = close > ma50 ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
            table.cell(dashboard, 1, currentRow, str.tostring(ma50, format.mintick), bgcolor=ma50Color, text_color=color.white, text_size=txtSize)
            currentRow += 1

        // Row: Daily MA 100 (conditional)
        if showMA100
            table.cell(dashboard, 0, currentRow, maType + " 100", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            ma100Color = close > ma100 ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
            table.cell(dashboard, 1, currentRow, str.tostring(ma100, format.mintick), bgcolor=ma100Color, text_color=color.white, text_size=txtSize)
            currentRow += 1

        // Row: Daily MA 200 (conditional)
        if showMA200
            table.cell(dashboard, 0, currentRow, maType + " 200", bgcolor=color.rgb(67, 70, 81), text_color=color.white, text_size=txtSize)
            ma200Color = close > ma200 ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
            table.cell(dashboard, 1, currentRow, str.tostring(ma200, format.mintick), bgcolor=ma200Color, text_color=color.white, text_size=txtSize)

// ==================== PLOTS ====================
// Daily MAs
plot(showMA8 ? ma8 : na, title="Daily MA 8", color=color.new(color.green, 30), linewidth=2)
plot(showMA21 ? ma21 : na, title="Daily MA 21", color=color.new(color.orange, 30), linewidth=2)
plot(showMA50 ? ma50 : na, title="Daily MA 50", color=color.new(color.red, 30), linewidth=2)

// Yesterday levels
plot(showYesterdayLevels ? yesterdayHigh : na, title="Yesterday High", color=color.new(color.white, 40), linewidth=2, style=plot.style_linebr)
plot(showYesterdayLevels ? yesterdayLow : na, title="Yesterday Low", color=color.new(color.white, 40), linewidth=2, style=plot.style_linebr)

// Premarket levels
plot(showPremarketLevels ? pmHigh : na, title="Premarket High", color=color.new(color.yellow, 40), linewidth=2, style=plot.style_linebr)
plot(showPremarketLevels ? pmLow : na, title="Premarket Low", color=color.new(color.yellow, 40), linewidth=2, style=plot.style_linebr)

// ==================== ORB CHART LINES (ORB Breakout & Retest) ====================

var line orb5HighLine = na
var line orb5LowLine = na
var line orb5MidLine = na
var line orb15HighLine = na
var line orb15LowLine = na
var line orb15MidLine = na
var line orb30HighLine = na
var line orb30LowLine = na
var line orb30MidLine = na

var label orb5HighLabel = na
var label orb5LowLabel = na
var label orb5MidLabel = na
var label orb15HighLabel = na
var label orb15LowLabel = na
var label orb15MidLabel = na
var label orb30HighLabel = na
var label orb30LowLabel = na
var label orb30MidLabel = na

var linefill orb5Fill = na
var linefill orb15Fill = na
var linefill orb30Fill = na

drawORBLines(orbH, orbL, orbLabelText, showTF, startBar, highLine, lowLine, midLine, highLbl, lowLbl, midLbl, oldFill) =>
    line.delete(highLine)
    line.delete(lowLine)
    line.delete(midLine)
    label.delete(highLbl)
    label.delete(lowLbl)
    label.delete(midLbl)
    linefill.delete(oldFill)

    newHighLine = line(na)
    newLowLine = line(na)
    newMidLine = line(na)
    newHighLbl = label(na)
    newLowLbl = label(na)
    newMidLbl = label(na)
    newFill = linefill(na)

    if showORBLines and showTF and not na(orbH) and not na(orbL) and not na(startBar)
        newHighLine := line.new(startBar, orbH, bar_index + orbLabelOffset, orbH, color=orbLineColor, style=orbLineStyle, width=orbLineWidth)
        newLowLine := line.new(startBar, orbL, bar_index + orbLabelOffset, orbL, color=orbLineColor, style=orbLineStyle, width=orbLineWidth)

        if showORBLabels
            newHighLbl := label.new(bar_index + orbLabelOffset, orbH, text=orbLabelText, color=orbLineColor, style=label.style_label_left, textcolor=color.white, size=size.small)
            newLowLbl := label.new(bar_index + orbLabelOffset, orbL, text=orbLabelText, color=orbLineColor, style=label.style_label_left, textcolor=color.white, size=size.small)

        if showORBFill
            newFill := linefill.new(newHighLine, newLowLine, color=color.new(orbLineColor, 90))

        if showMidline
            orbMid = (orbH + orbL) / 2
            newMidLine := line.new(startBar, orbMid, bar_index + orbLabelOffset, orbMid, color=orbLineColor, style=line.style_dotted, width=1)
            if showORBLabels
                newMidLbl := label.new(bar_index + orbLabelOffset, orbMid, text=orbLabelText, color=color.new(orbLineColor, 50), style=label.style_label_left, textcolor=color.white, size=size.tiny)

    [newHighLine, newLowLine, newMidLine, newHighLbl, newLowLbl, newMidLbl, newFill]

if barstate.islast
    [h5, l5, m5, hl5, ll5, ml5, f5] = drawORBLines(orb5High, orb5Low, "ORB 5", show5MinLines, sessionStartBar, orb5HighLine, orb5LowLine, orb5MidLine, orb5HighLabel, orb5LowLabel, orb5MidLabel, orb5Fill)
    orb5HighLine := h5
    orb5LowLine := l5
    orb5MidLine := m5
    orb5HighLabel := hl5
    orb5LowLabel := ll5
    orb5MidLabel := ml5
    orb5Fill := f5

    [h15, l15, m15, hl15, ll15, ml15, f15] = drawORBLines(orb15High, orb15Low, "ORB 15", show15MinLines, sessionStartBar, orb15HighLine, orb15LowLine, orb15MidLine, orb15HighLabel, orb15LowLabel, orb15MidLabel, orb15Fill)
    orb15HighLine := h15
    orb15LowLine := l15
    orb15MidLine := m15
    orb15HighLabel := hl15
    orb15LowLabel := ll15
    orb15MidLabel := ml15
    orb15Fill := f15

    [h30, l30, m30, hl30, ll30, ml30, f30] = drawORBLines(orb30High, orb30Low, "ORB 30", show30MinLines, sessionStartBar, orb30HighLine, orb30LowLine, orb30MidLine, orb30HighLabel, orb30LowLabel, orb30MidLabel, orb30Fill)
    orb30HighLine := h30
    orb30LowLine := l30
    orb30MidLine := m30
    orb30HighLabel := hl30
    orb30LowLabel := ll30
    orb30MidLabel := ml30
    orb30Fill := f30
````
