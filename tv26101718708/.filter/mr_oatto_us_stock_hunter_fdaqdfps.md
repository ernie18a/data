# Mr Oatto US Stock Hunter

- url: https://www.tradingview.com/script/FdaqDfPs/
- type: indicator
- pine_id: PUB;7040af8c586b47f2a1d7183d510466e0
- version: 3.0

## Description

**Mr Oatto Runtrend Stock — Daily-Anchored Trend & Pullback Analyzer**

A trend-following / swing-trading toolkit built around a 5-EMA ribbon (5/15/35/89/200), designed to answer one question whenever you open any symbol: *is this a good time to run the trend, or should I wait for a pullback?*

**Why "Daily-anchored"?**
Every analytical metric in this script (trend classification, trade-ready status, ATR stop/target, extension, swing-leg count, trend age, and relative strength) is computed on the Daily timeframe internally via `request.security`, regardless of which chart timeframe you currently have open. This means the numbers stay consistent whether you're looking at a 1H, 4H, or Weekly chart. Only the plotted EMA lines on the chart follow your current chart resolution, so the visual stays clean and relevant to whatever timeframe you're zoomed into.

**Key Features**

- **EMA Trend Classification** — Super Bullish / Bullish / Sideway Up / Sideway Down / Downtrend / Super Bear, based on EMA stack alignment (Daily).
- **Weekly MTF Filter** — confirms whether the Daily trend aligns with the Weekly trend (higher-timeframe confirmation).
- **Relative Strength vs SET Index** — measures whether the stock is outperforming or underperforming the SET index over the same Daily lookback window.
- **Chase-Risk Filter** — flags when price has already run too far from the EMA35 (in ATR multiples or %) or has formed too many swing legs since the trend began, switching the recommendation from "ready to run the trend" to "wait for a pullback" instead of chasing an extended move.
- **Swing-Leg Counter** — a simplified pivot-based proxy for "how many legs has this move made." This is NOT a true Elliott Wave count. Automated Elliott Wave labeling is inherently subjective and unreliable; this feature is intentionally a rough heuristic, not a wave-count claim.
- **ATR-Based Stop/Target** — suggested stop-loss and take-profit levels sized by Daily ATR, with a configurable reward:risk ratio.
- **Trend Age / Overextension Warning** — flags when the current trend regime has persisted unusually long.
- **Fundamentals Snapshot** — PE ratio, profitability, and YoY earnings growth for the symbol on your chart.
- **Market Overview** — SET / SET50 / SET100 index trend at a glance.
- **Built-in Alerts** — trend flips, cut warnings, overextension, chase-risk, and pullback-entry signals.
- **Three independent panels** (Trend / Edge Metrics / Market) that can each be repositioned and resized independently to avoid overlap on your chart.

**How to Read It**

1. Check the **Trend Panel** (bottom-right by default) for the overall Trade Status — this is the quick answer.
2. Check the **Edge Panel** (bottom-left by default) for the reasoning behind that status: Weekly alignment, relative strength, extension, swing legs, and suggested risk levels.
3. Check the **Market Panel** (top-right by default) for the broader SET market context.

**Settings**
All EMA periods, ATR multipliers, extension thresholds, swing-pivot sensitivity, and panel positions/text size are configurable via the indicator settings, organized into logical groups.

**Disclaimer**
This script is for educational and informational purposes only. It does not constitute financial advice, and past trend behavior does not guarantee future results. The swing-leg counter is a simplified heuristic, not a validated Elliott Wave count. Always apply your own risk management and position sizing. Trade at your own risk.

## Source Code

````pine
//@version=6
indicator("Mr Oatto US Stock Hunter", shorttitle="OattoUSHunter", overlay=true)

// ============================================================
// EMA TREND ANALYZER (US) — วิเคราะห์ symbol ปัจจุบันที่เปิดบนกราฟ (run trend / swing trade)
// ค่า EMA: 10 / 25 / 75 / 75 / 200 (EMA Slow = EMA Filter = 75 โดยตั้งใจ)
// ทุก metric ของ current symbol คำนวณบน DAILY เสมอ ผ่าน request.security
// (ไม่ขึ้นกับ timeframe ที่เปิดกราฟ) เส้น EMA บนกราฟยังวิ่งตาม timeframe ที่เปิดอยู่
// + ประเภทหุ้น: 1 ขาขึ้นแข็ง (ยืนเหนือ EMA200) / 2 กลับตัว (เคยอยู่ใต้ 200 แล้วยืนเหนือ 75)
//              / 3 ขาลงแต่หยุดทำ low ใหม่ / 4 ทำ New Low (ไม่เล่น)
// + Trade status + จุด Buy-on-dip ที่ EMA + Support zone ตามกฎ RSI
// + Weekly trend filter + Relative Strength vs Nasdaq100
// + Chase-risk filter (extension จาก EMA / จำนวน swing leg) -> กันไล่ซื้อยอด
// + Stop/Target: Stop ใต้แนวรับ EMA, Target = swing high ล่าสุดที่อยู่เหนือราคา + R:R
// + Trend age
// + Fundamentals (PE / P/BV / EPS / กำไร / รายได้ / FCF / D/E / ROE / งบล่าสุด) รายไตรมาส
// + Market overview (Nasdaq100 / S&P500)
// + Alerts (trend flip, cut warning, overextended, chase-risk, pullback entry, RSI หลุด 50, เข้าประเภท 2, ทำ New Low)
// แสดงผลเป็น Dashboard ตารางเดียว + ตาราง Market (เหมาะกับการดูบนมือถือ)
// ============================================================

// ============================================================
// INPUTS
// ============================================================
grpMarket = "Market Trend (Nasdaq100 / S&P500)"
showMarketTable  = input.bool(true, "Show Nasdaq100/S&P500 table", group=grpMarket)
marketTablePosStr = input.string("bottom_left", "Market table position", options=["top_right", "top_left", "bottom_right", "bottom_left"], group=grpMarket)

grpEMA = "EMA / Trend Settings (Daily - fixed)"
emaFast   = input.int(10,  "EMA Fast (Entry 1)", group=grpEMA)
emaMed    = input.int(25,  "EMA Medium (Entry 2)", group=grpEMA)
emaSlow   = input.int(75,  "EMA Slow (Entry 3)", group=grpEMA)
emaFilter = input.int(75,  "EMA Trade Filter", group=grpEMA)
emaMajor  = input.int(200, "EMA Major Trend", group=grpEMA)
cutDays   = input.int(5,   "Consecutive days below EMA-Filter -> cut warning", group=grpEMA)

grpType = "Stock Type Screening"
revLookback  = input.int(60, "Reversal: เคยอยู่ใต้ EMA200 ภายในกี่วัน (ประเภท 2)", minval=5, group=grpType)
newLowLen    = input.int(20, "New Low: เทียบกับ low ของกี่วัน (ประเภท 3/4)", minval=5, group=grpType)

grpSupport = "Support Zone (RSI rule)"
rsiLen     = input.int(14, "RSI length (Daily)", minval=2, group=grpSupport)
rsiStrong  = input.int(70, "RSI strong zone (>=)", minval=50, maxval=100, group=grpSupport)
rsiMid     = input.int(50, "RSI support break level", minval=30, maxval=70, group=grpSupport)

grpChart = "Chart Display (current symbol)"
showChartEMAs  = input.bool(true, "Show EMA lines on current chart", group=grpChart)
emaSetStr      = input.string("all", "EMA set to display", options=["all", "entry", "ribbon", "major"], group=grpChart)
showDashboard  = input.bool(true, "Show dashboard table", group=grpChart)
dashPosStr     = input.string("bottom_right", "Dashboard position", options=["top_right", "top_left", "bottom_right", "bottom_left"], group=grpChart)
showTradeReady = input.bool(true, "Show trade status row", group=grpChart)
showFundColumns = input.bool(true, "Show fundamentals rows (PE / Profit / Grow / D/E)", group=grpChart)
textSizeStr    = input.string("small", "Table text size", options=["tiny", "small", "normal", "large"], group=grpChart)

grpEdge = "Trend Edge (Weekly / Relative Strength / ATR Risk)"
useWeeklyFilter    = input.bool(true, "Use Weekly EMA trend as MTF filter", group=grpEdge)
rsLookback         = input.int(60, "Relative Strength lookback (Daily bars)", minval=5, group=grpEdge)
atrLen             = input.int(14, "ATR length (Daily)", minval=1, group=grpEdge)
stopBufferAtr      = input.float(0.5, "Stop: buffer below support (x ATR)", minval=0, step=0.1, group=grpEdge)
atrMultSL          = input.float(1.5, "Stop fallback: ATR multiplier (ไม่มีแนวรับ)", minval=0.1, step=0.1, group=grpEdge)
rrRatio            = input.float(2.0, "Target fallback: Reward:Risk (ไม่มีแนวต้าน)", minval=0.5, step=0.5, group=grpEdge)
overextendedBars   = input.int(60, "Overextended warning after N Daily bars in same trend regime", minval=5, group=grpEdge)

grpChase = "Chase Risk (avoid buying an extended move)"
extensionMethod    = input.string("ATR", "Extension measured by", options=["ATR", "Percent"], group=grpChase)
extensionATRMult   = input.float(3.0, "Extended if price > N x ATR from EMA Slow", minval=0.5, step=0.5, group=grpChase)
extensionPct       = input.float(15.0, "Extended if price > N% from EMA Slow", minval=1, step=1, group=grpChase)
pivotLeftBars      = input.int(5, "Swing pivot: left bars (Daily)", minval=1, group=grpChase)
pivotRightBars     = input.int(5, "Swing pivot: right bars (Daily)", minval=1, group=grpChase)
waveCautionCount   = input.int(3, "Caution if swing legs >= N since trend start", minval=1, group=grpChase)
showSwingMarkers   = input.bool(false, "Plot swing high/low markers on chart (approx.)", group=grpChase)

// ============================================================
// HELPERS
// ============================================================
f_pos(p) =>
    switch p
        "top_left"     => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left"  => position.bottom_left
        =>                position.top_right

f_textSize(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "large"  => size.large
        =>          size.normal

f_trendColor(t) =>
    t == "Super Bullish" ? color.new(color.lime, 0) : t == "Bullish" ? color.new(color.green, 0) : t == "Sideway Up" ? color.new(color.olive, 0) : t == "Sideway Down" ? color.new(color.orange, 0) : t == "Downtrend" ? color.new(color.red, 0) : t == "Super Bear" ? color.new(color.maroon, 0) : color.new(color.gray, 0)

f_classifyTrendDetailed(c, e1, e2, e3, e4, e5) =>
    // ใช้ >= / <= ระหว่าง EMA แต่ละคู่ เพื่อรองรับกรณี EMA Slow = EMA Filter (75 ทั้งคู่)
    superBull = c > e1 and e1 >= e2 and e2 >= e3 and e3 >= e4 and e4 >= e5
    bull = e1 >= e2 and e2 >= e3 and e3 >= e4 and e4 >= e5
    partialBull = e1 >= e2 and e2 >= e3 and e3 >= e4
    partialBear = e1 <= e2 and e2 <= e3 and e3 <= e4
    aboveEMA200 = c > e5
    belowEMA89 = c < e4

    if superBull
        "Super Bullish"
    else if bull
        "Bullish"
    else if aboveEMA200 and partialBull
        "Sideway Up"
    else if aboveEMA200 and not belowEMA89
        "Sideway Up"
    else if belowEMA89 and aboveEMA200 and not partialBear
        "Sideway Down"
    else if c < e5
        "Super Bear"
    else if belowEMA89
        "Downtrend"
    else
        "Sideway"

// ถ้าข้อมูลดึงไม่ได้ (na) ให้คืน N/A แทนการแสดง Sideway ที่ทำให้เข้าใจผิด
f_safeTrend(c, e1, e2, e3, e4, e5) =>
    na(c) or na(e1) or na(e2) or na(e3) or na(e4) or na(e5) ? "N/A" : f_classifyTrendDetailed(c, e1, e2, e3, e4, e5)

f_isBullishRegime(t) =>
    t == "Super Bullish" or t == "Bullish" or t == "Sideway Up"

f_isBearishRegime(t) =>
    t == "Downtrend" or t == "Super Bear" or t == "Sideway Down"

f_yesNo(v) =>
    na(v) ? "N/A" : v > 0 ? "Yes" : "No"

f_yoy(cur, prev) =>
    na(cur) or na(prev) ? "N/A" : cur > prev ? "Yes" : "No"

f_fmtNum(v) =>
    na(v) ? "N/A" : str.tostring(v, "#.##")

f_fmtPct(v) =>
    na(v) ? "N/A" : (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "%"

// PE = ราคาปัจจุบัน / EPS(TTM)
f_pe(px, eps) =>
    float res = na
    if not na(eps) and eps > 0
        res := px / eps
    res

// คำนวณทุกอย่างของ current symbol บน context ของ Daily bar จริง
f_dailyMetrics() =>
    c = close
    h = high
    l = low
    e1 = ta.ema(c, emaFast)
    e2 = ta.ema(c, emaMed)
    e3 = ta.ema(c, emaSlow)
    e4 = ta.ema(c, emaFilter)
    e5 = ta.ema(c, emaMajor)
    trend = f_classifyTrendDetailed(c, e1, e2, e3, e4, e5)
    regime = f_isBullishRegime(trend) ? 1 : f_isBearishRegime(trend) ? -1 : 0
    ageBars = ta.barssince(regime != regime[1])
    barsSinceAboveFilter = ta.barssince(c >= e4)
    atrV = ta.atr(atrLen)
    ph = ta.pivothigh(h, pivotLeftBars, pivotRightBars)
    pl = ta.pivotlow(l, pivotLeftBars, pivotRightBars)
    var float lastPH = na
    if not na(ph)
        lastPH := ph
    closeLookback = c[rsLookback]
    rsiV = ta.rsi(c, rsiLen)
    newLow = l < ta.lowest(l, newLowLen)[1]
    newLowAgo = ta.barssince(newLow)
    belowMajorAgo = ta.barssince(c < e5)
    var int swingCnt = 0
    var int rsiBroke = 0
    if regime != regime[1]
        swingCnt := 0
        rsiBroke := 0
    if regime == 1 and not na(ph)
        swingCnt := swingCnt + 1
    if regime == -1 and not na(pl)
        swingCnt := swingCnt + 1
    if regime == 1 and rsiV < rsiMid
        rsiBroke := 1
    [c, h, l, e1, e2, e3, e4, e5, atrV, ageBars, barsSinceAboveFilter, ph, pl, closeLookback, bar_index, swingCnt, rsiV, rsiBroke, newLowAgo, belowMajorAgo, lastPH]

// ============================================================
// MARKET TREND: Nasdaq100 / S&P500 (Daily EMA ribbon)
// ============================================================
[ndxC, ndxE1, ndxE2, ndxE3, ndxE4, ndxE5] = request.security("TVC:NDX", "D", [close, ta.ema(close, emaFast), ta.ema(close, emaMed), ta.ema(close, emaSlow), ta.ema(close, emaFilter), ta.ema(close, emaMajor)], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[spxC, spxE1, spxE2, spxE3, spxE4, spxE5] = request.security("TVC:SPX", "D", [close, ta.ema(close, emaFast), ta.ema(close, emaMed), ta.ema(close, emaSlow), ta.ema(close, emaFilter), ta.ema(close, emaMajor)], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

ndxTrend = f_safeTrend(ndxC, ndxE1, ndxE2, ndxE3, ndxE4, ndxE5)
spxTrend = f_safeTrend(spxC, spxE1, spxE2, spxE3, spxE4, spxE5)

// ============================================================
// WEEKLY TREND FILTER (multi-timeframe alignment)
// ============================================================
[wC, wE1, wE2, wE3, wE4, wE5] = request.security(syminfo.tickerid, "W", [close, ta.ema(close, emaFast), ta.ema(close, emaMed), ta.ema(close, emaSlow), ta.ema(close, emaFilter), ta.ema(close, emaMajor)], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
weeklyTrend = f_safeTrend(wC, wE1, wE2, wE3, wE4, wE5)

// ============================================================
// CURRENT SYMBOL (บังคับ Daily เสมอ)
// ============================================================
[dC, dH, dL, dE1, dE2, dE3, dE4, dE5, dATR, dAgeBars, dBarsSinceAboveFilter, dPH, dPL, dCloseLookback, dBarIndex, dSwingCnt, dRSI, dRsiBroke, dNewLowAgo, dBelowMajorAgo, dLastPH] =
     request.security(syminfo.tickerid, "D", f_dailyMetrics(), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

curTrend = f_safeTrend(dC, dE1, dE2, dE3, dE4, dE5)
curBelow89  = dC < dE4
curBelow200 = dC < dE5
curCutD = na(dBarsSinceAboveFilter) ? dBarIndex + 1 : int(dBarsSinceAboveFilter)
curCutW = curCutD >= cutDays
regimeState = f_isBullishRegime(curTrend) ? 1 : f_isBearishRegime(curTrend) ? -1 : 0

// --- ประเภทหุ้น ---
// 1 = ยืนเหนือ EMA200 และไม่เคยอยู่ใต้ EMA200 ในช่วง revLookback (ขาขึ้นแข็ง)
// 2 = เคยอยู่ใต้ EMA200 ในช่วง revLookback แล้วตอนนี้ยืนเหนือ EMA Filter (กลับตัว)
// 3 = อยู่ใต้ EMA Filter แต่ไม่ทำ New Low ในช่วง newLowLen (ขาลงที่เริ่มหมดแรง)
// 4 = อยู่ใต้ EMA Filter และทำ New Low ในช่วง newLowLen (ไม่เล่น)
// 0 = อื่นๆ (เช่น ย่ออยู่ในกรอบ EMA Filter-200 โดยไม่เคยหลุด EMA200)
wasBelowMajor = not na(dBelowMajorAgo) and dBelowMajorAgo <= revLookback
recentNewLow  = not na(dNewLowAgo) and dNewLowAgo <= newLowLen
stockType = dC > dE5 and not wasBelowMajor ? 1 : dC > dE4 and wasBelowMajor ? 2 : dC < dE4 and recentNewLow ? 4 : dC < dE4 ? 3 : 0
typeText  = stockType == 1 ? "1 ขาขึ้นแข็ง" : stockType == 2 ? "2 กลับตัว" : stockType == 3 ? "3 ขาลงหมดแรง" : stockType == 4 ? "4 ทำ New Low" : "0 ย่อในกรอบ"
typeColor = stockType == 1 ? color.lime : stockType == 2 ? color.aqua : stockType == 3 ? color.orange : stockType == 4 ? color.red : color.gray

// Multi-timeframe alignment (Daily trend confirmed by Weekly trend)
mtfAligned = (f_isBullishRegime(curTrend) and f_isBullishRegime(weeklyTrend)) or (f_isBearishRegime(curTrend) and f_isBearishRegime(weeklyTrend))
weeklyLabel = weeklyTrend == "N/A" ? "N/A" : not useWeeklyFilter ? weeklyTrend : weeklyTrend + (mtfAligned ? " ✅" : " ❌")

// Relative Strength vs Nasdaq100 (ทั้งสองฝั่งเทียบ N Daily bars ย้อนหลังเท่ากัน)
stockChangePct = (dC - dCloseLookback) / dCloseLookback * 100
ndxChangePct   = (ndxC - ndxC[rsLookback]) / ndxC[rsLookback] * 100
rsValue        = stockChangePct - ndxChangePct
rsColor        = na(rsValue) ? color.gray : rsValue > 0 ? color.green : color.red

// Trend age / overextension
trendAgeBars   = dAgeBars
isOverextended = regimeState != 0 and trendAgeBars >= overextendedBars
trendAgeLabel  = str.tostring(trendAgeBars) + (isOverextended ? " ⚠️" : "")
trendAgeColor  = isOverextended ? color.orange : color.white

// Chase-risk #1: extension จาก EMA Slow
atrVal     = dATR
extAmount  = f_isBullishRegime(curTrend) ? (dC - dE3) : f_isBearishRegime(curTrend) ? (dE3 - dC) : na
extATR     = (not na(extAmount) and atrVal > 0) ? extAmount / atrVal : na
extPct     = (not na(extAmount) and dE3 != 0) ? extAmount / dE3 * 100 : na
isExtended = extensionMethod == "ATR" ? (not na(extATR) and extATR > extensionATRMult) : (not na(extPct) and extPct > extensionPct)
extLabel   = extensionMethod == "ATR" ? (na(extATR) ? "N/A" : f_fmtNum(extATR) + "x ATR") : (na(extPct) ? "N/A" : f_fmtNum(extPct) + "%")

// Chase-risk #2: swing-leg counter (proxy ไม่ใช่ Elliott Wave จริง)
swingCount      = dSwingCnt
isLateStageWave = swingCount >= waveCautionCount

plotshape(showSwingMarkers and not na(dPH), title="Swing High", style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.tiny, offset=-pivotRightBars)
plotshape(showSwingMarkers and not na(dPL), title="Swing Low",  style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.tiny, offset=-pivotRightBars)

tooFarToChase = isExtended or isOverextended or isLateStageWave

// Support zone (กฎ RSI ของโค้ชซัน): 1 = รับ EMA Fast/Med, 2 = รับ EMA Slow/Filter, 3 = หลุด Filter ดู EMA200, 0 = ไม่ใช่ขาขึ้น
supportCode = regimeState != 1 ? 0 : dRsiBroke == 0 ? 1 : curBelow89 ? 3 : 2
supportText = supportCode == 1 ? "รับ " + str.tostring(emaFast) + "/" + str.tostring(emaMed) + ": " + f_fmtNum(dE1) + " / " + f_fmtNum(dE2) : supportCode == 2 ? "รับ " + str.tostring(emaSlow) + "/" + str.tostring(emaFilter) + ": " + f_fmtNum(dE3) + " / " + f_fmtNum(dE4) : supportCode == 3 ? "⚠️ หลุด " + str.tostring(emaFilter) + " รับ " + str.tostring(emaMajor) + ": " + f_fmtNum(dE5) : "—"
supportColor = supportCode == 1 ? color.green : supportCode == 2 ? color.orange : supportCode == 3 ? color.red : color.gray
rsiColor     = na(dRSI) ? color.gray : dRSI >= rsiStrong ? color.lime : dRsiBroke == 1 ? color.orange : color.white
rsiText      = f_fmtNum(dRSI) + (dRSI >= rsiStrong ? " 🔥" : dRsiBroke == 1 ? " (หลุด 50)" : "")

// Stop: ใต้แนวรับที่ใช้งานอยู่ เผื่อด้วย buffer เป็น ATR; ไม่มีแนวรับ -> ใช้ ATR จากราคาปิด
// Target: swing high ล่าสุดที่อยู่เหนือราคา; ไม่มี -> ใช้ R:R จากระยะ Stop
supportRef      = supportCode == 1 ? math.min(dE1, dE2) : supportCode == 2 ? math.min(dE3, dE4) : supportCode == 3 ? dE5 : na
atrStopFallback = dC - atrMultSL * atrVal
atrStop         = not na(supportRef) and supportRef - stopBufferAtr * atrVal < dC ? supportRef - stopBufferAtr * atrVal : atrStopFallback
riskAmt         = dC - atrStop
atrTarget       = not na(dLastPH) and dLastPH > dC ? dLastPH : dC + rrRatio * riskAmt
rrAchieved      = riskAmt > 0 ? (atrTarget - dC) / riskAmt : na

// Fundamentals (รายไตรมาส FQ; PE ใช้ EPS TTM) — sample ลง Daily เพื่อให้ YoY นับ 252 วันทำการ
curEPS    = showFundColumns ? request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_BASIC", "TTM", ignore_invalid_symbol=true) : na
curNIRaw  = showFundColumns ? request.financial(syminfo.tickerid, "NET_INCOME", "FQ", ignore_invalid_symbol=true) : na
[niDaily, niDailyLag] = request.security(syminfo.tickerid, "D", [curNIRaw, curNIRaw[252]], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
curPE     = f_pe(dC, curEPS)

// วันที่งบล่าสุด: วันที่ค่ากำไรเปลี่ยนครั้งล่าสุดบนกราฟ (ประมาณวันประกาศงบ ไม่ใช่วันสิ้นงวด)
chgNI      = curNIRaw != curNIRaw[1]
lastNIUpd  = ta.valuewhen(chgNI, time, 0)
lastNIText = na(lastNIUpd) ? "N/A" : str.format_time(lastNIUpd, "yyyy-MM-dd", syminfo.timezone)

// รายได้โต / FCF / D/E / ROE
curRev    = showFundColumns ? request.financial(syminfo.tickerid, "TOTAL_REVENUE", "FQ", ignore_invalid_symbol=true) : na
curFCF    = showFundColumns ? request.financial(syminfo.tickerid, "FREE_CASH_FLOW", "FQ", ignore_invalid_symbol=true) : na
curDebt   = showFundColumns ? request.financial(syminfo.tickerid, "TOTAL_DEBT", "FQ", ignore_invalid_symbol=true) : na
curEquity = showFundColumns ? request.financial(syminfo.tickerid, "TOTAL_EQUITY", "FQ", ignore_invalid_symbol=true) : na
[revDaily, revDailyLag] = request.security(syminfo.tickerid, "D", [curRev, curRev[252]], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
curDE  = na(curEquity) or curEquity <= 0 ? na : curDebt / curEquity
curROE = na(curEquity) or curEquity <= 0 ? na : niDaily / curEquity * 100

// P/BV ประมาณจาก EPS(รายไตรมาส) และกำไร(รายไตรมาส): จำนวนหุ้น ≈ กำไร / EPS, มูลค่าตามบัญชีต่อหุ้น ≈ ทุน / จำนวนหุ้น
curEpsFQ     = showFundColumns ? request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_BASIC", "FQ", ignore_invalid_symbol=true) : na
sharesApprox = na(curNIRaw) or na(curEpsFQ) or curEpsFQ <= 0 ? na : curNIRaw / curEpsFQ
bvpsApprox   = na(sharesApprox) or na(curEquity) or sharesApprox <= 0 ? na : curEquity / sharesApprox
curPB        = na(bvpsApprox) or bvpsApprox <= 0 ? na : dC / bvpsApprox

// --- EMA lines for CHART DISPLAY ONLY (วิ่งตาม timeframe ที่เปิดกราฟ) ---
chartE1 = ta.ema(close, emaFast)
chartE2 = ta.ema(close, emaMed)
chartE3 = ta.ema(close, emaSlow)
chartE4 = ta.ema(close, emaFilter)
chartE5 = ta.ema(close, emaMajor)

showE1 = showChartEMAs and (emaSetStr == "all" or emaSetStr == "entry")
showE2 = showChartEMAs and (emaSetStr == "all" or emaSetStr == "entry")
showE3 = showChartEMAs and (emaSetStr == "all" or emaSetStr == "entry")
showE4 = showChartEMAs and (emaSetStr == "all" or emaSetStr == "ribbon")
showE5 = showChartEMAs and (emaSetStr == "all" or emaSetStr == "major")

plot(showE1 ? chartE1 : na, title="EMA Fast",   color=color.new(color.yellow, 0), linewidth=1)
plot(showE2 ? chartE2 : na, title="EMA Medium", color=color.new(color.orange, 0), linewidth=1)
plot(showE3 ? chartE3 : na, title="EMA Slow",   color=color.new(color.aqua, 0),   linewidth=1)
plot(showE4 ? chartE4 : na, title="EMA Filter", color=color.new(color.aqua, 0),   linewidth=2)
plot(showE5 ? chartE5 : na, title="EMA Major",  color=color.new(color.white, 0),  linewidth=2)

// --- Trade status (ข้อความสั้นเพื่ออ่านบนมือถือ) ---
// ประเภท 4 (ทำ New Low)                                 -> ไม่เล่น
// Cut warning                                          -> คัตก่อน
// ประเภท 3 (ขาลงหมดแรง)                                 -> เฝ้าดู
// ประเภท 2 (กลับตัว) ยังต่ำกว่า EMA200                  -> เฝ้ารอยืนยัน
// ราคาต่ำกว่า EMA200 (ประเภทอื่น)                        -> ห้ามเล่น
// ขาขึ้น + ราคาใต้ EMA Filter                            -> เสี่ยง
// ขาขึ้น + extended/late-stage                          -> รอ Pullback
// ขาขึ้น + เหนือ EMA Filter                              -> Long
// ขาลง + ใต้ EMA Filter + extended                       -> รอ Pullback
// ขาลง + ใต้ EMA Filter                                  -> Short
// Else                                                   -> รอจังหวะ
f_readyStatus(trend, below89, below200, cutW, chase, stype) =>
    bull = trend == "Super Bullish" or trend == "Bullish" or trend == "Sideway Up"
    bear = trend == "Downtrend" or trend == "Super Bear" or trend == "Sideway Down"
    if stype == 4
        "❌ ทำ New Low"
    else if cutW
        "⚠️ คัตก่อน"
    else if stype == 3
        "👀 เฝ้าดู"
    else if stype == 2 and below200
        "👀 รอยืนยันเหนือ 200"
    else if below200
        "❌ ห้ามเล่น"
    else if bull and below89
        "⚠️ เสี่ยง"
    else if bull and chase
        "🔸 รอ Pullback"
    else if bull
        "✅ Long"
    else if bear and below89 and chase
        "🔸 รอ Pullback"
    else if bear and below89
        "✅ Short"
    else
        "⏳ รอจังหวะ"

curStatus = f_readyStatus(curTrend, curBelow89, curBelow200, curCutW, tooFarToChase, stockType)
curStatusColor = str.contains(curStatus, "Long") ? color.green : str.contains(curStatus, "Short") ? color.red : str.contains(curStatus, "❌") ? color.maroon : str.contains(curStatus, "⚠️") ? color.orange : str.contains(curStatus, "🔸") or str.contains(curStatus, "👀") ? color.olive : color.gray

// ============================================================
// DASHBOARD (ตารางเดียว 2 คอลัมน์: ป้ายชื่อ | ค่า) — รวมแถวให้ไม่เกิน 13 แถว
// ============================================================
nDash = 13 + (emaSlow != emaFilter ? 1 : 0) + (showTradeReady ? 1 : 0) + (showFundColumns ? 5 : 0)
txtSz = f_textSize(textSizeStr)
headerBg = color.new(color.blue, 40)
var table dashTbl = na
if showDashboard and barstate.isfirst
    dashTbl := table.new(f_pos(dashPosStr), 2, nDash, bgcolor=color.new(color.black, 60), border_width=1, border_color=color.gray)
if showDashboard and barstate.islast and not na(dashTbl)
    r = 0
    table.cell(dashTbl, 0, r, syminfo.ticker, text_color=color.white, bgcolor=headerBg, text_size=txtSz)
    table.cell(dashTbl, 1, r, curTrend, text_color=f_trendColor(curTrend), bgcolor=headerBg, text_size=txtSz)
    r := r + 1

    if showTradeReady
        table.cell(dashTbl, 0, r, "สถานะ", text_color=color.white, text_size=txtSz)
        table.cell(dashTbl, 1, r, curStatus, text_color=curStatusColor, text_size=txtSz)
        r := r + 1

    table.cell(dashTbl, 0, r, "ประเภท", text_color=color.white, text_size=txtSz)
    table.cell(dashTbl, 1, r, typeText, text_color=typeColor, text_size=txtSz)
    r := r + 1

    table.cell(dashTbl, 0, r, "Weekly/MTF", text_color=color.white, text_size=txtSz)
    table.cell(dashTbl, 1, r, weeklyLabel, text_color=f_trendColor(weeklyTrend), text_size=txtSz)
    r := r + 1

    table.cell(dashTbl, 0, r, "RS vs NDX", text_color=color.white, text_size=txtSz)
    table.cell(dashTbl, 1, r, f_fmtPct(rsValue), text_color=rsColor, text_size=txtSz)
    r := r + 1

    table.cell(dashTbl, 0, r, "Ext / Legs", text_color=color.white, text_size=txtSz)
    table.cell(dashTbl, 1, r, extLabel + " / " + str.tostring(swingCount), text_color=(isExtended or isLateStageWave ? color.orange : color.white), text_size=txtSz)
    r := r + 1

    table.cell(dashTbl, 0, r, "RSI(" + str.tostring(rsiLen) + ")", text_color=color.white, text_size=txtSz)
    table.cell(dashTbl, 1, r, rsiText, text_color=rsiColor, text_size=txtSz)
    r := r + 1

    table.cell(dashTbl, 0, r, "แนวรับ", text_color=color.white, text_size=txtSz)
    table.cell(dashTbl, 1, r, supportText, text_color=supportColor, text_size=txtSz)
    r := r + 1

    table.cell(dashTbl, 0, r, "Dip EMA " + str.tostring(emaFast), text_color=color.yellow, text_size=txtSz)
    table.cell(dashTbl, 1, r, f_fmtNum(dE1), text_color=color.yellow, text_size=txtSz)
    r := r + 1

    table.cell(dashTbl, 0, r, "Dip EMA " + str.tostring(emaMed), text_color=color.orange, text_size=txtSz)
    table.cell(dashTbl, 1, r, f_fmtNum(dE2), text_color=color.orange, text_size=txtSz)
    r := r + 1

    // EMA Slow กับ EMA Filter เท่ากันได้ (ค่าเริ่มต้น 75 ทั้งคู่) จึงแสดงแถวเดียวเมื่อค่าเท่ากัน ไม่ซ้อนกัน
    if emaSlow != emaFilter
        table.cell(dashTbl, 0, r, "Dip EMA " + str.tostring(emaSlow), text_color=color.aqua, text_size=txtSz)
        table.cell(dashTbl, 1, r, f_fmtNum(dE3), text_color=color.aqua, text_size=txtSz)
        r := r + 1

    table.cell(dashTbl, 0, r, "Dip EMA " + str.tostring(emaFilter), text_color=color.aqua, text_size=txtSz)
    table.cell(dashTbl, 1, r, f_fmtNum(dE4), text_color=color.aqua, text_size=txtSz)
    r := r + 1

    table.cell(dashTbl, 0, r, "EMA " + str.tostring(emaMajor), text_color=color.white, text_size=txtSz)
    table.cell(dashTbl, 1, r, f_fmtNum(dE5), text_color=color.white, text_size=txtSz)
    r := r + 1

    table.cell(dashTbl, 0, r, "Stop / Target", text_color=color.white, text_size=txtSz)
    table.cell(dashTbl, 1, r, f_fmtNum(atrStop) + " / " + f_fmtNum(atrTarget) + " (1:" + (na(rrAchieved) ? "N/A" : str.tostring(rrAchieved, "#.#")) + ")", text_color=color.white, text_size=txtSz)
    r := r + 1

    table.cell(dashTbl, 0, r, "Trend age (วัน)", text_color=color.white, text_size=txtSz)
    table.cell(dashTbl, 1, r, trendAgeLabel, text_color=trendAgeColor, text_size=txtSz)
    r := r + 1

    if showFundColumns
        table.cell(dashTbl, 0, r, "PE / P/BV / EPS", text_color=color.white, text_size=txtSz)
        table.cell(dashTbl, 1, r, f_fmtNum(curPE) + " / " + f_fmtNum(curPB) + " / " + f_fmtNum(curEPS), text_color=color.white, text_size=txtSz)
        r := r + 1

        table.cell(dashTbl, 0, r, "กำไร / โต YoY", text_color=color.white, text_size=txtSz)
        table.cell(dashTbl, 1, r, f_yesNo(niDaily) + " / " + f_yoy(niDaily, niDailyLag), text_color=color.white, text_size=txtSz)
        r := r + 1

        table.cell(dashTbl, 0, r, "รายได้โต / FCF", text_color=color.white, text_size=txtSz)
        table.cell(dashTbl, 1, r, f_yoy(revDaily, revDailyLag) + " / " + f_yesNo(curFCF), text_color=(f_yesNo(curFCF) == "Yes" ? color.green : color.red), text_size=txtSz)
        r := r + 1

        table.cell(dashTbl, 0, r, "D/E / ROE", text_color=color.white, text_size=txtSz)
        table.cell(dashTbl, 1, r, f_fmtNum(curDE) + " / " + f_fmtPct(curROE), text_color=color.white, text_size=txtSz)
        r := r + 1

        table.cell(dashTbl, 0, r, "งบล่าสุด (ไตรมาส)", text_color=color.white, text_size=txtSz)
        table.cell(dashTbl, 1, r, lastNIText, text_color=color.white, text_size=txtSz)

// ============================================================
// MARKET TABLE (Nasdaq100 / S&P500)
// ============================================================
var table marketTbl = na
if showMarketTable and barstate.isfirst
    marketTbl := table.new(f_pos(marketTablePosStr), 2, 3, bgcolor=color.new(color.black, 60), border_width=1, border_color=color.gray)
if showMarketTable and barstate.islast and not na(marketTbl)
    table.cell(marketTbl, 0, 0, "Index", text_color=color.white, bgcolor=headerBg, text_size=txtSz)
    table.cell(marketTbl, 1, 0, "Trend", text_color=color.white, bgcolor=headerBg, text_size=txtSz)
    table.cell(marketTbl, 0, 1, "Nasdaq100", text_color=color.white, text_size=txtSz)
    table.cell(marketTbl, 1, 1, ndxTrend, text_color=f_trendColor(ndxTrend), text_size=txtSz)
    table.cell(marketTbl, 0, 2, "S&P500", text_color=color.white, text_size=txtSz)
    table.cell(marketTbl, 1, 2, spxTrend, text_color=f_trendColor(spxTrend), text_size=txtSz)

// ============================================================
// ALERTS
// ============================================================
bullishFlip      = f_isBullishRegime(curTrend) and not f_isBullishRegime(curTrend[1])
bearishFlip      = f_isBearishRegime(curTrend) and not f_isBearishRegime(curTrend[1])
cutWarningFlip   = curCutW and not curCutW[1]
overextendedFlip = isOverextended and not isOverextended[1]
chaseRiskFlip    = tooFarToChase and not tooFarToChase[1]
rsiBreakFlip     = dRsiBroke == 1 and dRsiBroke[1] == 0
type2Flip        = stockType == 2 and stockType[1] != 2
newLowFlip       = stockType == 4 and stockType[1] != 4
pullbackEntry    = f_isBullishRegime(curTrend) and not curBelow89 and low <= dE1 and high >= dE1

alertcondition(bullishFlip, title="Trend Turned Bullish", message="{{ticker}} Daily trend turned Bullish")
alertcondition(bearishFlip, title="Trend Turned Bearish", message="{{ticker}} Daily trend turned Bearish")
alertcondition(cutWarningFlip, title="Cut Warning", message="{{ticker}} closed below Daily EMA Filter for too long - consider cutting")
alertcondition(overextendedFlip, title="Trend Overextended", message="{{ticker}} Daily trend has run long - watch for pullback/reversal")
alertcondition(chaseRiskFlip, title="Chase Risk - Wait for Pullback", message="{{ticker}} already extended or late-stage swing - avoid chasing, wait for pullback to EMA")
alertcondition(rsiBreakFlip, title="RSI Broke 50 - Support Shift", message="{{ticker}} Daily RSI broke below 50 in uptrend - support shifts to EMA Slow/Filter")
alertcondition(type2Flip, title="Reversal Type 2 Entered", message="{{ticker}} now a reversal stock - reclaimed EMA Filter after being below EMA200")
alertcondition(newLowFlip, title="New Low - Avoid", message="{{ticker}} made a new low below EMA Filter - avoid")
alertcondition(pullbackEntry, title="Pullback Entry Signal", message="{{ticker}} pulled back to Daily EMA Fast within an uptrend - possible entry")
````
