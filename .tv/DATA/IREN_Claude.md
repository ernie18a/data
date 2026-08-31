<!-- tradingview-pine-id: PUB;cc9025b56e7e47e0807f604c4bd256fb -->
<!-- tradingviewscripts-format: 1 -->
# IREN - איתות משולב (Claude)

Source: https://www.tradingview.com/script/lJ7GiTfe/

## Description

COMPOSITE SIGNAL WITH SELF-MEASURED STATISTICS

This indicator combines several classic factors into one buy/sell
signal — and, more importantly, measures its own track record on
whatever symbol and timeframe you load it on.

HOW THE SIGNAL WORKS
Each candle is scored by factors that vote independently: trend
(EMA 9 vs EMA 20), RSI extremes, volume surges, candlestick
patterns, Stochastic crosses in oversold/overbought zones, and
rejection at a confirmed prior pivot high. A signal fires only when
enough factors agree — you set the threshold. Buy stays "active"
until a sell fires and vice versa, so you get one label per turn
instead of a cluster.

WHAT MAKES IT DIFFERENT: THE MEASUREMENT
Every pattern and factor is backtested live across the full history
of the chart. Tables show, for each one: how many times it occurred,
what percentage worked, and average return.

Crucially, there is a BASELINE row measuring what happens after a
random candle. On a stock with strong upward drift, a pattern
scoring 55% may show no edge at all if the baseline is also 55%.
Read every row against the baseline, not against 50%.

WHAT IT MEASURES
- All 11 classic candlestick patterns, with trend context (hammer
  vs hanging man are the same shape — the prior trend decides which)
- Trend age and depth: how long and how far the current move has
  run, versus what is typical, plus the share of past moves that
  continued from this point
- Support/resistance zones tested from both directions
- Intraday floor and ceiling tests: did price pierce a level during
  the session and close back, or close through?
- Opening gap versus session move
- Correlation with a reference asset, sector ETFs and the index

SETTINGS
Signal threshold, evaluation horizon, zone boundaries and all
comparison symbols are configurable. Tables can be toggled off.

HONEST LIMITATIONS
- These are historical frequencies, not predictions. A 65% pattern
  is still wrong one time in three.
- Small sample sizes are shown deliberately. A percentage built on
  5 cases means nothing — always check the count.
- Testing many conditions at once means some will look good by
  chance. Treat only large differences on decent samples as real.
- Default zone levels and factor selection were tuned on one
  specific stock. On other symbols, check the tables first and
  adjust — what works on one stock often fails on another.

Not financial advice. For research and study.

---

## Source Code

````pine
// © Claude — software and chip sectors now get the same treatment as
// IREN's own sector: same-bar direction agreement with the stock, and
// the forward outcome after each sector rose. Note these already
// appeared in the script, but only measured against EACH OTHER (the
// rotation hypothesis) — never against IREN itself, which is what was
// actually being asked for. As with bitcoin, expect high agreement
// and no predictive value: things that move at the same time as the
// stock cannot be traded on, and the two rows are deliberately split
// so that distinction is visible rather than assumed.
//@version=6
indicator("IREN - איתות משולב (Claude)", overlay = true, max_labels_count = 500)

// ============ הקלט היחיד שבאמת חשוב לכוון ============
signalThreshold  = input.int(2, "כמה גורמים (מתוך 6) צריכים להסכים", minval = 1, maxval = 6)
useTrendInScore  = input.bool(true, "לכלול מגמה בציון (לכבות = תגובה מהירה יותר לתפניות)")
lookAhead        = input.int(10, "בדוק הצלחה אחרי כמה נרות", minval = 1)
showLabels       = input.bool(true, "הצג תוויות קנייה/מכירה על הגרף")
showTable        = input.bool(true, "הצג טבלת סיכום")
showPatternTable = input.bool(false, "הצג טבלת כל תבניות הנרות")
showZoneTable    = input.bool(false, "הצג טבלת אזורי תמיכה/התנגדות")
showGapTable     = input.bool(true, "הצג טבלת פרה-מרקט (פער פתיחה)")
strongPct        = input.float(5.0, "יום חזק = תנועה מעל כמה אחוז", minval = 0.5)
showPatternLabels = input.bool(false, "סמן על הגרף רק תבניות שעובדות")
showFloorTests   = input.bool(true, "סמן מבחני רצפה (ניסיון שבירה תוך-יומי)")
z5lo             = input.float(38.0, "אזור 5 - תחתון (עגול)", group = "אזור נוסף")
z5hi             = input.float(41.0, "אזור 5 - עליון (עגול)", group = "אזור נוסף")
labelMargin      = input.int(5, "כמה אחוז מעל הרקע נחשב 'עובד'", minval = 0, maxval = 30)
labelLookback    = input.int(300, "כמה נרות אחורה לסמן", minval = 50, maxval = 2000)
labelMinCases    = input.int(20, "מינימום מקרים כדי לסמן", minval = 5)
btcSymbol        = input.symbol("BINANCE:BTCUSDT", "סמל הביטקוין להשוואה")
swSymbol         = input.symbol("AMEX:IGV", "סקטור תוכנה (ETF)")
chipSymbol       = input.symbol("NASDAQ:SOXX", "סקטור שבבים (ETF)")
mktSymbol        = input.symbol("NASDAQ:IXIC", "מדד השוק להשוואה")
sectorSymbol     = input.symbol("AMEX:WGMI", "סקטור המניה (כורי ביטקוין)")

// ============ הכול מתחת לשורה הזאת - ערכים קבועים, לא קלט ============
maShort = ta.ema(close, 9)
maLong  = ta.ema(close, 20)
plot(maShort, "קצב מהיר", color = #E8A33D, linewidth = 2)
plot(maLong, "קצב איטי", color = #6FA3C4, linewidth = 2)

// ============ אורך ועומק מגמות - כמה נרות וכמה אחוזים מגמה רצה בדרך כלל ============
trendUpNow = maShort > maLong
var int phaseAge = 1
var int[] upPhaseLens = array.new_int()
var int[] downPhaseLens = array.new_int()
var float phaseStartPrice = na
var float phaseExtreme = na
var float[] upAmps = array.new_float()
var float[] downAmps = array.new_float()
if na(phaseStartPrice)
    phaseStartPrice := close
    phaseExtreme := trendUpNow ? high : low
if bar_index > 0
    if trendUpNow != trendUpNow[1]
        if trendUpNow[1]
            array.push(upPhaseLens, phaseAge)
            array.push(upAmps, (phaseExtreme - phaseStartPrice) / phaseStartPrice * 100)
        else
            array.push(downPhaseLens, phaseAge)
            array.push(downAmps, (phaseStartPrice - phaseExtreme) / phaseStartPrice * 100)
        phaseAge := 1
        phaseStartPrice := close
        phaseExtreme := trendUpNow ? high : low
    else
        phaseAge := phaseAge + 1
        phaseExtreme := trendUpNow ? math.max(phaseExtreme, high) : math.min(phaseExtreme, low)
curAmp = na(phaseStartPrice) ? 0.0 : trendUpNow ? (phaseExtreme - phaseStartPrice) / phaseStartPrice * 100 : (phaseStartPrice - phaseExtreme) / phaseStartPrice * 100

rsiVal   = ta.rsi(close, 14)
avgVol   = ta.sma(volume, 20)
volSpike = volume >= avgVol * 1.8
atrVal   = ta.atr(14)

stochKRaw = ta.stoch(close, high, low, 14)
stochK    = ta.sma(stochKRaw, 3)
stochD    = ta.sma(stochK, 3)
stochBullCross = ta.crossover(stochK, stochD) and stochK < 20
stochBearCross = ta.crossunder(stochK, stochD) and stochK > 80

wvf          = ((ta.highest(close, 22) - low) / ta.highest(close, 22)) * 100
wvfMid       = ta.sma(wvf, 20)
wvfUpperBand = wvfMid + 2.0 * ta.stdev(wvf, 20)
wvfRangeHigh = ta.highest(wvf, 50) * 0.85
vixSpike     = wvf >= wvfUpperBand or wvf >= wvfRangeHigh

// ============ התנגדות בשיא קודם ============
pivotHigh = ta.pivothigh(3, 3)
var float lastPivotHigh = na
if not na(pivotHigh)
    lastPivotHigh := pivotHigh
nearResistance = not na(lastPivotHigh) and math.abs(high - lastPivotHigh) / lastPivotHigh < 0.02
resRejection   = nearResistance and close < open

// ============ מבחני רצפה: ניסיון שבירה תוך-יומי ============
pivotLow = ta.pivotlow(3, 3)
var float lastPivotLow = na
if not na(pivotLow)
    lastPivotLow := pivotLow
floorAttempt = not na(lastPivotLow) and low < lastPivotLow and close[1] >= lastPivotLow
floorHeld    = floorAttempt and close >= lastPivotLow
floorBroke   = floorAttempt and close < lastPivotLow
var int flN = 0
var int flHeld = 0
var float flMinLevel = na
var float flMaxLevel = na
if floorAttempt
    flN := flN + 1
    if floorHeld
        flHeld := flHeld + 1
    flMinLevel := na(flMinLevel) ? lastPivotLow : math.min(flMinLevel, lastPivotLow)
    flMaxLevel := na(flMaxLevel) ? lastPivotLow : math.max(flMaxLevel, lastPivotLow)

// ============ מבחני תקרה: ניסיון פריצה תוך-יומי ============
ceilAttempt  = not na(lastPivotHigh) and high > lastPivotHigh and close[1] <= lastPivotHigh
ceilRejected = ceilAttempt and close <= lastPivotHigh
ceilBroke    = ceilAttempt and close > lastPivotHigh
var int ceN = 0
var int ceRej = 0
var float ceMinLevel = na
var float ceMaxLevel = na
if ceilAttempt
    ceN := ceN + 1
    if ceilRejected
        ceRej := ceRej + 1
    ceMinLevel := na(ceMinLevel) ? lastPivotHigh : math.min(ceMinLevel, lastPivotHigh)
    ceMaxLevel := na(ceMaxLevel) ? lastPivotHigh : math.max(ceMaxLevel, lastPivotHigh)

// ============ ביטקוין - האם יש קשר? (מעקב בלבד) ============
btcClose = request.security(btcSymbol, timeframe.period, close, lookahead = barmerge.lookahead_off)
btcUp    = not na(btcClose) and not na(btcClose[1]) and btcClose > btcClose[1]
btcDown  = not na(btcClose) and not na(btcClose[1]) and btcClose < btcClose[1]
irenUp   = close > close[1]
var int agreeN = 0
var int agreeHits = 0
if (btcUp or btcDown) and bar_index > 0
    agreeN := agreeN + 1
    if (btcUp and irenUp) or (btcDown and not irenUp)
        agreeHits := agreeHits + 1

// ---- ביטקוין בלילה: פער הפתיחה מול מהלך היום ----
btcOpen = request.security(btcSymbol, timeframe.period, open, lookahead = barmerge.lookahead_off)
btcNightUp   = not na(btcOpen) and not na(btcClose[1]) and btcOpen > btcClose[1]
btcNightDown = not na(btcOpen) and not na(btcClose[1]) and btcOpen < btcClose[1]
gapUp = open > close[1]
var int gapN = 0
var int gapHits = 0
if (btcNightUp or btcNightDown) and bar_index > 0
    gapN := gapN + 1
    if (btcNightUp and gapUp) or (btcNightDown and not gapUp)
        gapHits := gapHits + 1
// מה שנשאר אחרי הפתיחה: מהפתיחה ועד הסגירה של אותו נר
var int nightN = 0
var int nightHits = 0
var float nightSum = 0.0
if btcNightUp and bar_index > 0
    dayRet = (close - open) / open * 100
    nightN := nightN + 1
    nightSum := nightSum + dayRet
    if dayRet > 0
        nightHits := nightHits + 1

// ---- תוכנה מול שבבים ----
swClose   = request.security(swSymbol, timeframe.period, close, lookahead = barmerge.lookahead_off)
chipClose = request.security(chipSymbol, timeframe.period, close, lookahead = barmerge.lookahead_off)
swDown   = not na(swClose) and not na(swClose[1]) and swClose < swClose[1]
chipUp   = not na(chipClose) and not na(chipClose[1]) and chipClose > chipClose[1]
var int rotN = 0
var int rotHits = 0
var int rotNextN = 0
var int rotNextHits = 0
var int chipBaseN = 0
var int chipBaseHits = 0
if not na(chipClose) and not na(chipClose[1]) and bar_index > 0
    chipBaseN := chipBaseN + 1
    if chipUp
        chipBaseHits := chipBaseHits + 1
if swDown and bar_index > 0
    rotN := rotN + 1
    if chipUp
        rotHits := rotHits + 1
if bar_index > 1 and swDown[1]
    rotNextN := rotNextN + 1
    if chipUp
        rotNextHits := rotNextHits + 1

// ---- השוק הכללי ותאריכי דוחות ----
mktClose = request.security(mktSymbol, timeframe.period, close, lookahead = barmerge.lookahead_off)
mktUp    = not na(mktClose) and not na(mktClose[1]) and mktClose > mktClose[1]
earnVal  = request.earnings(syminfo.tickerid, earnings.actual, ignore_invalid_symbol = true)
isEarnDay = not na(earnVal)
afterEarnings = bar_index > 0 and isEarnDay[1]

// ---- הסקטור של המניה עצמה ----
secClose = request.security(sectorSymbol, timeframe.period, close, lookahead = barmerge.lookahead_off)
secUp    = not na(secClose) and not na(secClose[1]) and secClose > secClose[1]
secDown  = not na(secClose) and not na(secClose[1]) and secClose < secClose[1]
var int secAgreeN = 0
var int secAgreeHits = 0
if (secUp or secDown) and bar_index > 0
    secAgreeN := secAgreeN + 1
    if (secUp and close > close[1]) or (secDown and close <= close[1])
        secAgreeHits := secAgreeHits + 1

// ---- תוכנה ושבבים מול המניה עצמה ----
swUp     = not na(swClose) and not na(swClose[1]) and swClose > swClose[1]
chipDown = not na(chipClose) and not na(chipClose[1]) and chipClose < chipClose[1]
var int chipAgreeN = 0
var int chipAgreeHits = 0
var int swAgreeN = 0
var int swAgreeHits = 0
if (chipUp or chipDown) and bar_index > 0
    chipAgreeN := chipAgreeN + 1
    if (chipUp and close > close[1]) or (chipDown and close <= close[1])
        chipAgreeHits := chipAgreeHits + 1
if (swUp or swDown) and bar_index > 0
    swAgreeN := swAgreeN + 1
    if (swUp and close > close[1]) or (swDown and close <= close[1])
        swAgreeHits := swAgreeHits + 1

// ============ אזורי תמיכה/התנגדות (מעקב בלבד - לא חלק מהציון) ============
// כל אזור נבדק משני הכיוונים: הגעה מלמעלה = מבחן תמיכה (הצלחה = עלייה
// אחרי), הגעה מלמטה = מבחן התנגדות (הצלחה = ירידה אחרי).
zoneStats(loZ, hiZ) =>
    supTouch = low <= hiZ and close[1] > hiZ
    resTouch = high >= loZ and close[1] < loZ
    var int supN = 0
    var int supW = 0
    var float supS = 0.0
    var int resN = 0
    var int resW = 0
    var float resS = 0.0
    if bar_index >= lookAhead and supTouch[lookAhead]
        r = (close - close[lookAhead]) / close[lookAhead] * 100
        supN := supN + 1
        supS := supS + r
        if r > 0
            supW := supW + 1
    if bar_index >= lookAhead and resTouch[lookAhead]
        r = (close - close[lookAhead]) / close[lookAhead] * 100
        resN := resN + 1
        resS := resS + r
        if r < 0
            resW := resW + 1
    [supN, supW, supS, resN, resW, resS]

[z1SupN, z1SupW, z1SupS, z1ResN, z1ResW, z1ResS] = zoneStats(28.0, 32.0)
[z2SupN, z2SupW, z2SupS, z2ResN, z2ResW, z2ResS] = zoneStats(43.0, 47.0)
[z3SupN, z3SupW, z3SupS, z3ResN, z3ResW, z3ResS] = zoneStats(47.0, 50.0)
[z4SupN, z4SupW, z4SupS, z4ResN, z4ResW, z4ResS] = zoneStats(74.0, 77.0)
[z5SupN, z5SupW, z5SupS, z5ResN, z5ResW, z5ResS] = zoneStats(z5lo, z5hi)

hz1a = hline(28.0, "אזור 30 תחתון", color = color.new(#E8A33D, 100))
hz1b = hline(32.0, "אזור 30 עליון", color = color.new(#E8A33D, 100))
hz2a = hline(43.0, "אזור 45 תחתון", color = color.new(#6FA3C4, 100))
hz2b = hline(47.0, "אזור 45 עליון", color = color.new(#6FA3C4, 100))
hz3a = hline(47.0, "אזור 48 תחתון", color = color.new(#B08BC9, 100))
hz3b = hline(50.0, "אזור 48 עליון", color = color.new(#B08BC9, 100))
hz4a = hline(74.0, "אזור שיא תחתון", color = color.new(#DB6A54, 100))
hz4b = hline(77.0, "אזור שיא עליון", color = color.new(#DB6A54, 100))
fill(hz1a, hz1b, color = color.new(#E8A33D, 88), title = "אזור 28-32")
fill(hz2a, hz2b, color = color.new(#6FA3C4, 88), title = "אזור 43-47")
fill(hz3a, hz3b, color = color.new(#B08BC9, 90), title = "אזור 47-50")
fill(hz4a, hz4b, color = color.new(#DB6A54, 88), title = "אזור 74-77")
hz5a = hline(z5lo, "אזור עגול תחתון", color = color.new(#8C948F, 100))
hz5b = hline(z5hi, "אזור עגול עליון", color = color.new(#8C948F, 100))
fill(hz5a, hz5b, color = color.new(#8C948F, 88), title = "אזור עגול")

// ============ פרה-מרקט (פער פתיחה) מול מהלך יום המסחר ============
// הפער = פתיחה מול סגירת אתמול (שם הפרה-מרקט מתומחר).
// המסחר = מהפתיחה ועד הסגירה.
gapStats(active, expectUp) =>
    var int gN = 0
    var int gSame = 0
    var float gGapSum = 0.0
    var float gSesSum = 0.0
    if active and bar_index > 1
        gPct = (open - close[1]) / close[1] * 100
        sPct = (close - open) / open * 100
        gN := gN + 1
        gGapSum := gGapSum + gPct
        gSesSum := gSesSum + sPct
        if (expectUp and sPct > 0) or (not expectUp and sPct < 0)
            gSame := gSame + 1
    [gN, gSame, gGapSum, gSesSum]

gapUpDay   = open > close[1]
gapDownDay = open < close[1]
prevGreen  = close[1] > open[1]

[gu1N, gu1S, gu1G, gu1R] = gapStats(gapUpDay, true)
[gu2N, gu2S, gu2G, gu2R] = gapStats(gapUpDay and prevGreen, true)
[gu3N, gu3S, gu3G, gu3R] = gapStats(gapUpDay and not prevGreen, true)
[gd1N, gd1S, gd1G, gd1R] = gapStats(gapDownDay, false)
[gd2N, gd2S, gd2G, gd2R] = gapStats(gapDownDay and prevGreen, false)
[gd3N, gd3S, gd3G, gd3R] = gapStats(gapDownDay and not prevGreen, false)

// ---- מה קרה ביום שאחרי יום חזק ----
nextDayStats(active) =>
    var int nN = 0
    var int nUp = 0
    var float nSum = 0.0
    if active and bar_index > 2
        r = (close - close[1]) / close[1] * 100
        nN := nN + 1
        nSum := nSum + r
        if r > 0
            nUp := nUp + 1
    [nN, nUp, nSum]

prevMove   = bar_index > 2 ? (close[1] - close[2]) / close[2] * 100 : 0.0
strongUpDay = bar_index > 2 and prevMove >= strongPct
strongDnDay = bar_index > 2 and prevMove <= -strongPct

[suN, suUp, suSum] = nextDayStats(strongUpDay)
[sdN, sdUp, sdSum] = nextDayStats(strongDnDay)

// ============ מיקום המחיר ביחס לאזורים ============
float supEdge = na
float resEdge = na
string posTxt = ""
if close > 77
    supEdge := 77.0
    posTxt := "מעל כל האזורים"
else if close >= 74
    supEdge := 74.0
    resEdge := 77.0
    posTxt := "בתוך אזור 74-77"
else if close > 50
    supEdge := 50.0
    resEdge := 74.0
    posTxt := "בין 47-50 ל-74-77"
else if close >= 47
    supEdge := 47.0
    resEdge := 50.0
    posTxt := "בתוך אזור 47-50"
else if close >= 43
    supEdge := 43.0
    resEdge := 47.0
    posTxt := "בתוך אזור 43-47"
else if close > 32
    supEdge := 32.0
    resEdge := 43.0
    posTxt := "בין 28-32 ל-43-47"
else if close >= 28
    supEdge := 28.0
    resEdge := 32.0
    posTxt := "בתוך אזור 28-32"
else
    resEdge := 28.0
    posTxt := "מתחת לכל האזורים"

// ============ צורות נרות - הסט המלא ============
bodyTop    = math.max(close, open)
bodyBottom = math.min(close, open)
bodySize   = bodyTop - bodyBottom
lowerWick  = bodyBottom - low
upperWick  = high - bodyTop

priorTrendUp = maShort[1] > maLong[1]

hammerShape = bodySize > 0 and lowerWick >= bodySize * 2 and upperWick <= bodySize * 0.5
starShape   = bodySize > 0 and upperWick >= bodySize * 2 and lowerWick <= bodySize * 0.5

isDoji          = bodySize <= (high - low) * 0.1 and (high - low) > 0
isHammer        = hammerShape and not priorTrendUp
isHangingMan    = hammerShape and priorTrendUp
isInvHammer     = starShape and not priorTrendUp
isShootingStar  = starShape and priorTrendUp

engulfBull = close[1] < open[1] and close > open and open <= close[1] and close >= open[1]
engulfBear = close[1] > open[1] and close < open and open >= close[1] and close <= open[1]

bullHarami = close[1] < open[1] and bodyTop <= open[1] and bodyBottom >= close[1] and bodySize < (open[1] - close[1])
bearHarami = close[1] > open[1] and bodyTop <= close[1] and bodyBottom >= open[1] and bodySize < (close[1] - open[1])

body2Ago = math.abs(close[2] - open[2])
body1Ago = math.abs(close[1] - open[1])
morningStar = close[2] < open[2] and body2Ago > 0 and body1Ago < body2Ago * 0.5 and close > open and close > (open[2] + close[2]) / 2
eveningStar = close[2] > open[2] and body2Ago > 0 and body1Ago < body2Ago * 0.5 and close < open and close < (open[2] + close[2]) / 2

// ============ הציון המשולב ============
trendScore  = maShort > maLong ? 1 : -1
rsiScore    = rsiVal < 30 ? 1 : rsiVal > 70 ? -1 : 0
volScore    = volSpike ? (close >= open ? 1 : -1) : 0
bullPattern = engulfBull or bullHarami or morningStar
bearPattern = engulfBear or isShootingStar or isHangingMan or bearHarami or eveningStar
patScore    = bullPattern ? 1 : bearPattern ? -1 : 0
stochScore  = stochBullCross ? 1 : stochBearCross ? -1 : 0
resScore    = resRejection ? -1 : 0

reactiveScore = rsiScore + volScore + patScore + stochScore + resScore
totalScore    = useTrendInScore ? trendScore + reactiveScore : reactiveScore

compositeBuy  = totalScore >= signalThreshold
compositeSell = totalScore <= -signalThreshold

// מתג מצב: קנייה נשארת בתוקף עד שמופיעה מכירה, ולהפך
var int sigState = 0
freshBuy  = compositeBuy and sigState != 1
freshSell = compositeSell and sigState != -1
if freshBuy
    sigState := 1
if freshSell
    sigState := -1

// ============ מעקב הצלחה - רץ על כל ההיסטוריה פעם אחת ============
var int   buyN = 0
var int   buyWins = 0
var float buySum = 0.0
var int   sellN = 0
var int   sellWins = 0
var float sellSum = 0.0

evalReady = bar_index >= lookAhead

if evalReady and freshBuy[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    buyN := buyN + 1
    buySum := buySum + r
    if r > 0
        buyWins := buyWins + 1

if evalReady and freshSell[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    sellN := sellN + 1
    sellSum := sellSum + r
    if r < 0
        sellWins := sellWins + 1

// ============ מנוע כללי לבדיקת רעיונות ============
// מודד כל תנאי באותה שיטה בדיוק: מה קרה אחרי lookAhead נרות.
condStats(active, winIsUp) =>
    var int cN = 0
    var int cW = 0
    var float cS = 0.0
    if bar_index >= lookAhead and active[lookAhead]
        r = (close - close[lookAhead]) / close[lookAhead] * 100
        cN := cN + 1
        cS := cS + r
        if (winIsUp and r > 0) or (not winIsUp and r < 0)
            cW := cW + 1
    [cN, cW, cS]

volHeavy = volume >= avgVol * 1.5

[mkuN, mkuW, mkuS] = condStats(freshBuy and mktUp, true)
[mkdN, mkdW, mkdS] = condStats(freshBuy and not mktUp, true)
[fbhN, fbhW, fbhS] = condStats(floorBroke and volHeavy, false)
[fblN, fblW, fblS] = condStats(floorBroke and not volHeavy, false)
[earN, earW, earS] = condStats(afterEarnings, true)
[dw1N, dw1W, dw1S] = condStats(dayofweek == dayofweek.monday, true)
[dw2N, dw2W, dw2S] = condStats(dayofweek == dayofweek.tuesday, true)
[dw3N, dw3W, dw3S] = condStats(dayofweek == dayofweek.wednesday, true)
[dw4N, dw4W, dw4S] = condStats(dayofweek == dayofweek.thursday, true)
[dw5N, dw5W, dw5S] = condStats(dayofweek == dayofweek.friday, true)
[secN, secW, secS] = condStats(secUp, true)
[chpN, chpW, chpS] = condStats(chipUp, true)
[sofN, sofW, sofS] = condStats(swUp, true)
divUp = secUp and close <= close[1]
divDn = secDown and close > close[1]
[dvuN, dvuW, dvuS] = condStats(divUp, true)
[dvdN, dvdW, dvdS] = condStats(divDn, false)

// ============ מעקב הצלחה לכל תבנית/גורם בנפרד ============
var int dojiN = 0
var int dojiUp = 0
var float dojiSum = 0.0
var int hamN = 0
var int hamWins = 0
var float hamSum = 0.0
var int hmnN = 0
var int hmnWins = 0
var float hmnSum = 0.0
var int ihmN = 0
var int ihmWins = 0
var float ihmSum = 0.0
var int ssN = 0
var int ssWins = 0
var float ssSum = 0.0
var int ebuN = 0
var int ebuWins = 0
var float ebuSum = 0.0
var int ebeN = 0
var int ebeWins = 0
var float ebeSum = 0.0
var int bhaN = 0
var int bhaWins = 0
var float bhaSum = 0.0
var int beaN = 0
var int beaWins = 0
var float beaSum = 0.0
var int msN = 0
var int msWins = 0
var float msSum = 0.0
var int esN = 0
var int esWins = 0
var float esSum = 0.0
var int resN = 0
var int resWins = 0
var float resSum = 0.0
var int vixN = 0
var int vixWins = 0
var float vixSum = 0.0
var int sbuN = 0
var int sbuWins = 0
var float sbuSum = 0.0
var int sbeN = 0
var int sbeWins = 0
var float sbeSum = 0.0
var int bdN = 0
var int bdWins = 0
var float bdSum = 0.0
var int btcN = 0
var int btcWins = 0
var float btcSum = 0.0
var int baseN = 0
var int baseWins = 0
var float baseSum = 0.0

if evalReady
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    baseN := baseN + 1
    baseSum := baseSum + r
    if r > 0
        baseWins := baseWins + 1

if evalReady and btcUp[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    btcN := btcN + 1
    btcSum := btcSum + r
    if r > 0
        btcWins := btcWins + 1

if evalReady and isDoji[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    dojiN := dojiN + 1
    dojiSum := dojiSum + r
    if r > 0
        dojiUp := dojiUp + 1

if evalReady and isHammer[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    hamN := hamN + 1
    hamSum := hamSum + r
    if r > 0
        hamWins := hamWins + 1

if evalReady and isHangingMan[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    hmnN := hmnN + 1
    hmnSum := hmnSum + r
    if r < 0
        hmnWins := hmnWins + 1

if evalReady and isInvHammer[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    ihmN := ihmN + 1
    ihmSum := ihmSum + r
    if r > 0
        ihmWins := ihmWins + 1

if evalReady and isShootingStar[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    ssN := ssN + 1
    ssSum := ssSum + r
    if r < 0
        ssWins := ssWins + 1

if evalReady and engulfBull[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    ebuN := ebuN + 1
    ebuSum := ebuSum + r
    if r > 0
        ebuWins := ebuWins + 1

if evalReady and engulfBear[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    ebeN := ebeN + 1
    ebeSum := ebeSum + r
    if r < 0
        ebeWins := ebeWins + 1

if evalReady and bullHarami[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    bhaN := bhaN + 1
    bhaSum := bhaSum + r
    if r > 0
        bhaWins := bhaWins + 1

if evalReady and bearHarami[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    beaN := beaN + 1
    beaSum := beaSum + r
    if r < 0
        beaWins := beaWins + 1

if evalReady and morningStar[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    msN := msN + 1
    msSum := msSum + r
    if r > 0
        msWins := msWins + 1

if evalReady and eveningStar[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    esN := esN + 1
    esSum := esSum + r
    if r < 0
        esWins := esWins + 1

if evalReady and resRejection[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    resN := resN + 1
    resSum := resSum + r
    if r < 0
        resWins := resWins + 1

if evalReady and vixSpike[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    vixN := vixN + 1
    vixSum := vixSum + r
    if r > 0
        vixWins := vixWins + 1

if evalReady and stochBullCross[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    sbuN := sbuN + 1
    sbuSum := sbuSum + r
    if r > 0
        sbuWins := sbuWins + 1

if evalReady and stochBearCross[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    sbeN := sbeN + 1
    sbeSum := sbeSum + r
    if r < 0
        sbeWins := sbeWins + 1

// קנייה שנורתה בזמן שהממוצע המהיר מתחת לאיטי (מגמת ירידה)
buyInDown = freshBuy and not trendUpNow
if evalReady and buyInDown[lookAhead]
    p0 = close[lookAhead]
    r = (close - p0) / p0 * 100
    bdN := bdN + 1
    bdSum := bdSum + r
    if r > 0
        bdWins := bdWins + 1

// ============ תוויות על הגרף - רק ברגע שהאיתות מתחיל ============
if showLabels and freshBuy
    reason = ""
    if useTrendInScore and trendScore > 0
        reason := reason + "מגמה "
    if rsiScore > 0
        reason := reason + "RSI "
    if volScore > 0
        reason := reason + "נפח "
    if engulfBull
        reason := reason + "בליעה "
    if bullHarami
        reason := reason + "הראמי "
    if morningStar
        reason := reason + "כוכב בוקר "
    if stochBullCross
        reason := reason + "סטוכסטי "
    label.new(x = bar_index, y = low, text = "קנייה\n" + reason, yloc = yloc.belowbar, style = label.style_label_up, color = #4FB88A, textcolor = color.white, size = size.small)

if showLabels and freshSell
    reason = ""
    if useTrendInScore and trendScore < 0
        reason := reason + "מגמה "
    if rsiScore < 0
        reason := reason + "RSI "
    if volScore < 0
        reason := reason + "נפח "
    if isShootingStar
        reason := reason + "כוכב נופל "
    if isHangingMan
        reason := reason + "איש תלוי "
    if engulfBear
        reason := reason + "בליעה "
    if bearHarami
        reason := reason + "הראמי "
    if eveningStar
        reason := reason + "כוכב ערב "
    if stochBearCross
        reason := reason + "סטוכסטי "
    if resRejection
        reason := reason + "התנגדות "
    label.new(x = bar_index, y = high, text = "מכירה\n" + reason, yloc = yloc.abovebar, style = label.style_label_down, color = #DB6A54, textcolor = color.white, size = size.small)

// ============ סימון מבחני רצפה ותקרה על הגרף ============
if showFloorTests and ceilAttempt
    label.new(x = bar_index, y = high, text = (ceilRejected ? "נדחה " : "נפרץ ") + str.tostring(lastPivotHigh, "#.##"), yloc = yloc.abovebar, style = label.style_label_down, color = color.new(ceilRejected ? #DB6A54 : #4FB88A, 20), textcolor = color.white, size = size.tiny)

if showFloorTests and floorAttempt
    label.new(x = bar_index, y = low, text = (floorHeld ? "החזיקה " : "נשברה ") + str.tostring(lastPivotLow, "#.##"), yloc = yloc.belowbar, style = label.style_label_up, color = color.new(floorHeld ? #4FB88A : #DB6A54, 20), textcolor = color.white, size = size.tiny)

// ============ סימון תבניות שעובדות (לפי הרקע הנמדד) ============
patOK(wins, n, thresh) =>
    n >= labelMinCases and float(wins) / float(n) * 100 >= thresh

if showPatternLabels and bar_index > last_bar_index - labelLookback
    baseRate   = baseN > 0 ? float(baseWins) / float(baseN) * 100 : 50.0
    bullThresh = baseRate + labelMargin
    bearThresh = (100.0 - baseRate) + labelMargin
    txt = ""
    isBull = false
    if isHammer and patOK(hamWins, hamN, bullThresh)
        txt := "פטיש"
        isBull := true
    if isInvHammer and patOK(ihmWins, ihmN, bullThresh)
        txt := "פטיש הפוך"
        isBull := true
    if engulfBull and patOK(ebuWins, ebuN, bullThresh)
        txt := "בליעה עולה"
        isBull := true
    if bullHarami and patOK(bhaWins, bhaN, bullThresh)
        txt := "הראמי עולה"
        isBull := true
    if morningStar and patOK(msWins, msN, bullThresh)
        txt := "כוכב בוקר"
        isBull := true
    if isHangingMan and patOK(hmnWins, hmnN, bearThresh)
        txt := "איש תלוי"
    if isShootingStar and patOK(ssWins, ssN, bearThresh)
        txt := "כוכב נופל"
    if engulfBear and patOK(ebeWins, ebeN, bearThresh)
        txt := "בליעה יורדת"
    if bearHarami and patOK(beaWins, beaN, bearThresh)
        txt := "הראמי יורד"
    if eveningStar and patOK(esWins, esN, bearThresh)
        txt := "כוכב ערב"
    if resRejection and patOK(resWins, resN, bearThresh)
        txt := "התנגדות"
    if txt != ""
        label.new(x = bar_index, y = isBull ? low : high, text = txt, yloc = isBull ? yloc.belowbar : yloc.abovebar, style = isBull ? label.style_label_up : label.style_label_down, color = color.new(isBull ? #4FB88A : #DB6A54, 25), textcolor = color.white, size = size.tiny)

// ============ עזרי טקסט ============
pctStr(sum, n) =>
    txt = "—"
    if n > 0
        avg = sum / n
        sign = avg >= 0 ? "+" : ""
        txt := sign + str.tostring(avg, "#.#") + "%"
    txt

winStr(wins, n) =>
    txt = "—"
    if n > 0
        txt := str.tostring(float(wins) / float(n) * 100, "#") + "%"
    txt

medStr(arr) =>
    txt = "—"
    if array.size(arr) > 0
        txt := str.tostring(array.median(arr), "#") + " נרות"
    txt

medPctStr(arr) =>
    txt = "—"
    if array.size(arr) > 0
        txt := str.tostring(array.median(arr), "#") + "%"
    txt

// מבין מהלכי העבר שהגיעו לפחות עד הנקודה הנוכחית - כמה המשיכו הלאה
survStr(arr, cur) =>
    total = 0
    beyond = 0
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            v = array.get(arr, i)
            if v >= cur
                total := total + 1
                if v > cur
                    beyond := beyond + 1
    total > 0 ? str.tostring(float(beyond) / float(total) * 100, "#") + "% (מתוך " + str.tostring(total) + ")" : "—"


// ============ טבלת קנייה/מכירה ============
var table t = table.new(position.top_right, 4, 9, bgcolor = #171B19, border_width = 1, border_color = #2A2F2C)
stopLine = close - atrVal * 2.0

if showTable and barstate.islast
    table.cell(t, 0, 0, "איתות", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 1, 0, "כרגע", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 2, 0, "הצלחה", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 3, 0, "תשואה ל-" + str.tostring(lookAhead) + " נרות", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)

    bBuy = sigState == 1 ? color.new(#4FB88A, 75) : #171B19
    table.cell(t, 0, 1, "קנייה", text_color = #EDEAE3, bgcolor = bBuy, text_size = size.small)
    table.cell(t, 1, 1, sigState == 1 ? "בתוקף" : "-", text_color = #4FB88A, bgcolor = bBuy, text_size = size.small)
    table.cell(t, 2, 1, winStr(buyWins, buyN) + " (" + str.tostring(buyN) + ")", text_color = #EDEAE3, bgcolor = bBuy, text_size = size.small)
    table.cell(t, 3, 1, pctStr(buySum, buyN), text_color = #EDEAE3, bgcolor = bBuy, text_size = size.small)

    bSell = sigState == -1 ? color.new(#DB6A54, 75) : #171B19
    table.cell(t, 0, 2, "מכירה", text_color = #EDEAE3, bgcolor = bSell, text_size = size.small)
    table.cell(t, 1, 2, sigState == -1 ? "בתוקף" : "-", text_color = #DB6A54, bgcolor = bSell, text_size = size.small)
    table.cell(t, 2, 2, winStr(sellWins, sellN) + " (" + str.tostring(sellN) + ")", text_color = #EDEAE3, bgcolor = bSell, text_size = size.small)
    table.cell(t, 3, 2, pctStr(sellSum, sellN), text_color = #EDEAE3, bgcolor = bSell, text_size = size.small)

    table.cell(t, 0, 3, "רף יציאה משוער", text_color = #E8A33D, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 1, 3, "", bgcolor = #1E2320)
    table.cell(t, 2, 3, "תנודה יומית", text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 3, 3, str.tostring(stopLine, "#.##"), text_color = #DB6A54, bgcolor = #1E2320, text_size = size.small)

    table.cell(t, 0, 4, "מגמה נוכחית", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 1, 4, trendUpNow ? "עלייה" : "ירידה", text_color = trendUpNow ? #4FB88A : #DB6A54, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 2, 4, str.tostring(phaseAge) + " נרות", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 3, 4, "אופייני: " + (trendUpNow ? medStr(upPhaseLens) : medStr(downPhaseLens)) + "\nהמשיכו מנקודה זו: " + (trendUpNow ? survStr(upPhaseLens, phaseAge) : survStr(downPhaseLens, phaseAge)), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)

    table.cell(t, 0, 5, "עומק המהלך", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 1, 5, (trendUpNow ? "+" : "-") + str.tostring(curAmp, "#.#") + "%", text_color = trendUpNow ? #4FB88A : #DB6A54, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 2, 5, "עד כה", text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 3, 5, "אופייני: " + (trendUpNow ? medPctStr(upAmps) : medPctStr(downAmps)) + "\nהמשיכו מנקודה זו: " + (trendUpNow ? survStr(upAmps, curAmp) : survStr(downAmps, curAmp)), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)

    table.cell(t, 0, 6, "מיקום המחיר", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 1, 6, posTxt, text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 2, 6, na(supEdge) ? "אין תמיכה מתחת" : "עד תמיכה: " + str.tostring((supEdge - close) / close * 100, "#.#") + "%", text_color = #4FB88A, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 3, 6, na(resEdge) ? "אין התנגדות מעל" : "עד התנגדות: +" + str.tostring((resEdge - close) / close * 100, "#.#") + "%", text_color = #DB6A54, bgcolor = #1E2320, text_size = size.small)

    table.cell(t, 0, 7, "מבחני רצפה", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 1, 7, str.tostring(flN) + " ניסיונות", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 2, 7, "החזיקו: " + winStr(flHeld, flN) + "\nנשברו: " + winStr(flN - flHeld, flN), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 3, 7, na(flMinLevel) ? "—" : "טווח מחירים: " + str.tostring(flMinLevel, "#.##") + " - " + str.tostring(flMaxLevel, "#.##"), text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)

    table.cell(t, 0, 8, "מבחני תקרה", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 1, 8, str.tostring(ceN) + " ניסיונות", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 2, 8, "נדחו: " + winStr(ceRej, ceN) + "\nנפרצו: " + winStr(ceN - ceRej, ceN), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(t, 3, 8, na(ceMinLevel) ? "—" : "טווח מחירים: " + str.tostring(ceMinLevel, "#.##") + " - " + str.tostring(ceMaxLevel, "#.##"), text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)

plot(stopLine, "רף יציאה משוער", color = color.new(#DB6A54, 40), style = plot.style_circles, linewidth = 1)

// ============ טבלת כל תבניות הנרות והגורמים ============
var table p = table.new(position.bottom_right, 4, 43, bgcolor = #171B19, border_width = 1, border_color = #2A2F2C)

if showPatternTable and barstate.islast
    table.cell(p, 0, 0, "תבנית/גורם", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 1, 0, "קרה", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 2, 0, "הצליח", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 3, 0, "תשואה", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)

    table.cell(p, 0, 1, "דוג׳י (היסוס)", text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 1, str.tostring(dojiN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 1, winStr(dojiUp, dojiN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 1, pctStr(dojiSum, dojiN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 2, "פטיש (אחרי ירידה)", text_color = #4FB88A, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 2, str.tostring(hamN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 2, winStr(hamWins, hamN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 2, pctStr(hamSum, hamN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 3, "איש תלוי (אחרי עלייה)", text_color = #DB6A54, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 3, str.tostring(hmnN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 3, winStr(hmnWins, hmnN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 3, pctStr(hmnSum, hmnN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 4, "פטיש הפוך (אחרי ירידה)", text_color = #4FB88A, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 4, str.tostring(ihmN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 4, winStr(ihmWins, ihmN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 4, pctStr(ihmSum, ihmN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 5, "כוכב נופל (אחרי עלייה)", text_color = #DB6A54, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 5, str.tostring(ssN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 5, winStr(ssWins, ssN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 5, pctStr(ssSum, ssN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 6, "בליעה עולה", text_color = #4FB88A, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 6, str.tostring(ebuN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 6, winStr(ebuWins, ebuN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 6, pctStr(ebuSum, ebuN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 7, "בליעה יורדת", text_color = #DB6A54, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 7, str.tostring(ebeN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 7, winStr(ebeWins, ebeN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 7, pctStr(ebeSum, ebeN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 8, "הראמי עולה", text_color = #4FB88A, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 8, str.tostring(bhaN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 8, winStr(bhaWins, bhaN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 8, pctStr(bhaSum, bhaN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 9, "הראמי יורד", text_color = #DB6A54, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 9, str.tostring(beaN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 9, winStr(beaWins, beaN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 9, pctStr(beaSum, beaN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 10, "כוכב בוקר", text_color = #4FB88A, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 10, str.tostring(msN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 10, winStr(msWins, msN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 10, pctStr(msSum, msN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 11, "כוכב ערב", text_color = #DB6A54, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 11, str.tostring(esN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 11, winStr(esWins, esN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 11, pctStr(esSum, esN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 12, "התנגדות בשיא קודם", text_color = #DB6A54, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 12, str.tostring(resN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 12, winStr(resWins, resN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 12, pctStr(resSum, resN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 13, "VIX Fix קפץ (מעקב)", text_color = #4FB88A, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 13, str.tostring(vixN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 13, winStr(vixWins, vixN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 13, pctStr(vixSum, vixN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 14, "סטוכסטי חוצה למעלה (לבד)", text_color = #4FB88A, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 14, str.tostring(sbuN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 14, winStr(sbuWins, sbuN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 14, pctStr(sbuSum, sbuN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 15, "סטוכסטי חוצה למטה (לבד)", text_color = #DB6A54, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 15, str.tostring(sbeN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 15, winStr(sbeWins, sbeN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 15, pctStr(sbeSum, sbeN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 16, "קנייה בזמן מגמת ירידה", text_color = #E8A33D, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 16, str.tostring(bdN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 16, winStr(bdWins, bdN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 16, pctStr(bdSum, bdN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 17, "אחרי שביטקוין עלה", text_color = #E8A33D, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 17, str.tostring(btcN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 17, winStr(btcWins, btcN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 17, pctStr(btcSum, btcN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 18, "אותו כיוון כמו ביטקוין", text_color = #E8A33D, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 18, str.tostring(agreeN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 18, winStr(agreeHits, agreeN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 18, "—", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 19, "פער פתיחה בכיוון ביטקוין הלילה", text_color = #E8A33D, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 19, str.tostring(gapN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 19, winStr(gapHits, gapN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 19, "—", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 20, "ביטקוין עלה בלילה ← מהלך היום", text_color = #E8A33D, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 20, str.tostring(nightN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 20, winStr(nightHits, nightN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 20, pctStr(nightSum, nightN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 21, "תוכנה ירדה ← שבבים עלו (אותו נר)", text_color = #B08BC9, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 21, str.tostring(rotN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 21, winStr(rotHits, rotN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 21, "—", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 22, "תוכנה ירדה ← שבבים עלו (נר הבא)", text_color = #B08BC9, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 22, str.tostring(rotNextN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 22, winStr(rotNextHits, rotNextN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 22, "—", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 23, "רקע: שבבים עולים בכלל", text_color = #B08BC9, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 1, 23, str.tostring(chipBaseN), text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 2, 23, winStr(chipBaseHits, chipBaseN), text_color = #B08BC9, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 3, 23, "—", text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)

    table.cell(p, 0, 24, "רקע: כל הנרות (להשוואה)", text_color = #E8A33D, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 1, 24, str.tostring(baseN), text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 2, 24, winStr(baseWins, baseN), text_color = #E8A33D, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 3, 24, pctStr(baseSum, baseN), text_color = #E8A33D, bgcolor = #1E2320, text_size = size.small)

    table.cell(p, 0, 25, "קנייה כשהשוק עלה", text_color = #4FB88A, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 25, str.tostring(mkuN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 25, winStr(mkuW, mkuN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 25, pctStr(mkuS, mkuN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 26, "קנייה כשהשוק ירד", text_color = #DB6A54, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 26, str.tostring(mkdN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 26, winStr(mkdW, mkdN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 26, pctStr(mkdS, mkdN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 27, "שבירת רצפה בנפח גבוה", text_color = #B08BC9, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 27, str.tostring(fbhN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 27, winStr(fbhW, fbhN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 27, pctStr(fbhS, fbhN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 28, "שבירת רצפה בנפח רגיל", text_color = #B08BC9, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 28, str.tostring(fblN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 28, winStr(fblW, fblN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 28, pctStr(fblS, fblN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 29, "יום אחרי דוח כספי", text_color = #E8A33D, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 29, str.tostring(earN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 29, winStr(earW, earN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 29, pctStr(earS, earN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 30, "יום שני", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 30, str.tostring(dw1N), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 30, winStr(dw1W, dw1N), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 30, pctStr(dw1S, dw1N), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 31, "יום שלישי", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 31, str.tostring(dw2N), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 31, winStr(dw2W, dw2N), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 31, pctStr(dw2S, dw2N), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 32, "יום רביעי", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 32, str.tostring(dw3N), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 32, winStr(dw3W, dw3N), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 32, pctStr(dw3S, dw3N), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 33, "יום חמישי", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 33, str.tostring(dw4N), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 33, winStr(dw4W, dw4N), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 33, pctStr(dw4S, dw4N), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 34, "יום שישי", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 34, str.tostring(dw5N), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 34, winStr(dw5W, dw5N), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 34, pctStr(dw5S, dw5N), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 35, "אותו כיוון כמו הסקטור", text_color = #6FA3C4, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 35, str.tostring(secAgreeN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 35, winStr(secAgreeHits, secAgreeN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 35, "—", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 36, "אחרי שהסקטור עלה", text_color = #6FA3C4, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 36, str.tostring(secN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 36, winStr(secW, secN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 36, pctStr(secS, secN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 37, "אותו כיוון כמו השבבים", text_color = #B08BC9, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 37, str.tostring(chipAgreeN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 37, winStr(chipAgreeHits, chipAgreeN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 37, "—", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 38, "אחרי שהשבבים עלו", text_color = #B08BC9, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 38, str.tostring(chpN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 38, winStr(chpW, chpN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 38, pctStr(chpS, chpN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 39, "אותו כיוון כמו התוכנה", text_color = #B08BC9, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 39, str.tostring(swAgreeN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 39, winStr(swAgreeHits, swAgreeN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 39, "—", text_color = #8C948F, bgcolor = #171B19, text_size = size.small)

    table.cell(p, 0, 40, "אחרי שהתוכנה עלתה", text_color = #B08BC9, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 1, 40, str.tostring(sofN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 2, 40, winStr(sofW, sofN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 3, 40, pctStr(sofS, sofN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(p, 0, 41, "הסקטור עלה והמניה לא", text_color = #E8A33D, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 1, 41, str.tostring(dvuN), text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 2, 41, "עלתה אחרי: " + winStr(dvuW, dvuN), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 3, 41, pctStr(dvuS, dvuN), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)

    table.cell(p, 0, 42, "הסקטור ירד והמניה עלתה", text_color = #E8A33D, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 1, 42, str.tostring(dvdN), text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 2, 42, "ירדה אחרי: " + winStr(dvdW, dvdN), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(p, 3, 42, pctStr(dvdS, dvdN), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
// ============ טבלת אזורי תמיכה/התנגדות ============
var table z = table.new(position.bottom_left, 5, 11, bgcolor = #171B19, border_width = 1, border_color = #2A2F2C)

zoneRow(row, nameTxt, supN, supW, supS, resN, resW, resS) =>
    table.cell(z, 0, row, nameTxt, text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(z, 1, row, "תמיכה", text_color = #4FB88A, bgcolor = #171B19, text_size = size.small)
    table.cell(z, 2, row, str.tostring(supN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(z, 3, row, winStr(supW, supN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(z, 4, row, pctStr(supS, supN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(z, 0, row + 1, "", bgcolor = #171B19)
    table.cell(z, 1, row + 1, "התנגדות", text_color = #DB6A54, bgcolor = #171B19, text_size = size.small)
    table.cell(z, 2, row + 1, str.tostring(resN), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(z, 3, row + 1, winStr(resW, resN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(z, 4, row + 1, pctStr(resS, resN), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

if showZoneTable and barstate.islast
    table.cell(z, 0, 0, "אזור", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(z, 1, 0, "כיוון", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(z, 2, 0, "קרה", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(z, 3, 0, "הצליח", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(z, 4, 0, "תשואה", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    zoneRow(1, "28-32", z1SupN, z1SupW, z1SupS, z1ResN, z1ResW, z1ResS)
    zoneRow(3, "43-47", z2SupN, z2SupW, z2SupS, z2ResN, z2ResW, z2ResS)
    zoneRow(5, "47-50", z3SupN, z3SupW, z3SupS, z3ResN, z3ResW, z3ResS)
    zoneRow(7, "74-77", z4SupN, z4SupW, z4SupS, z4ResN, z4ResW, z4ResS)
    zoneRow(9, str.tostring(z5lo, "#.#") + "-" + str.tostring(z5hi, "#.#"), z5SupN, z5SupW, z5SupS, z5ResN, z5ResW, z5ResS)

// ============ טבלת פרה-מרקט ============
var table g = table.new(position.middle_center, 5, 9, bgcolor = #171B19, border_width = 1, border_color = #2A2F2C)

gapRow(row, nameTxt, n, same, gsum, ssum, col) =>
    table.cell(g, 0, row, nameTxt, text_color = col, bgcolor = #171B19, text_size = size.small)
    table.cell(g, 1, row, str.tostring(n), text_color = #8C948F, bgcolor = #171B19, text_size = size.small)
    table.cell(g, 2, row, winStr(same, n), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(g, 3, row, pctStr(gsum, n), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)
    table.cell(g, 4, row, pctStr(ssum, n), text_color = #EDEAE3, bgcolor = #171B19, text_size = size.small)

if showGapTable and barstate.islast
    table.cell(g, 0, 0, "פרה-מרקט", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 1, 0, "קרה", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 2, 0, "המשיך באותו כיוון", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 3, 0, "ממוצע פער", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 4, 0, "ממוצע מסחר", text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    gapRow(1, "פער חיובי (הכול)", gu1N, gu1S, gu1G, gu1R, #4FB88A)
    gapRow(2, "פער חיובי אחרי יום ירוק", gu2N, gu2S, gu2G, gu2R, #4FB88A)
    gapRow(3, "פער חיובי אחרי יום אדום", gu3N, gu3S, gu3G, gu3R, #4FB88A)
    gapRow(4, "פער שלילי (הכול)", gd1N, gd1S, gd1G, gd1R, #DB6A54)
    gapRow(5, "פער שלילי אחרי יום ירוק", gd2N, gd2S, gd2G, gd2R, #DB6A54)
    gapRow(6, "פער שלילי אחרי יום אדום", gd3N, gd3S, gd3G, gd3R, #DB6A54)

    table.cell(g, 0, 7, "יום אחרי עלייה חזקה (מעל " + str.tostring(strongPct, "#.#") + "%)", text_color = #E8A33D, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 1, 7, str.tostring(suN), text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 2, 7, "עלה: " + winStr(suUp, suN), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 3, 7, "—", text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 4, 7, pctStr(suSum, suN), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)

    table.cell(g, 0, 8, "יום אחרי ירידה חזקה (מעל " + str.tostring(strongPct, "#.#") + "%)", text_color = #E8A33D, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 1, 8, str.tostring(sdN), text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 2, 8, "עלה: " + winStr(sdUp, sdN), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 3, 8, "—", text_color = #8C948F, bgcolor = #1E2320, text_size = size.small)
    table.cell(g, 4, 8, pctStr(sdSum, sdN), text_color = #EDEAE3, bgcolor = #1E2320, text_size = size.small)

// ============ התראות - רק על תחילת איתות חדש ============
alertcondition(freshBuy, title = "קנייה", message = "IREN: איתות קנייה משולב")
alertcondition(freshSell, title = "מכירה", message = "IREN: איתות מכירה משולב")
````
