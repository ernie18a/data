# Candlestick Reversal Scanner by Forthius

- url: https://www.tradingview.com/script/0A07dkTU-Candlestick-Reversal-Scanner-by-Forthius/
- type: indicator
- pine_id: PUB;4dc9c2130ae24828bd33c6248f4562df
- version: 2.0

## Description

Tracks the major candlestick patterns and reversals coming out of them. The reversals help you to take the decisions alongwith Moving Averages

## Source Code

````pine
//@version=6
indicator("Forthius Reversal Scanner v5", overlay=true, max_labels_count=500)

// ─── Color refresh ────────────────────────────────────────────────────────
// Label backgrounds now use saturated custom hex colors for high contrast
// on dark TradingView themes. Text is white by default; black only on the
// two intentionally light backgrounds (BullEng lime, DragDoji cyan).
// Transparency reduced so B/C grade labels don't wash out.
// All scanner logic is unchanged from the prior v5.

// ═══ INPUTS ════════════════════════════════════════════════════════════════
grpT = "Trend & Filters"
emaFast    = input.int(20, "Fast EMA", minval=5, group=grpT)
emaSlow    = input.int(50, "Slow EMA", minval=10, group=grpT)
atrLen     = input.int(14, "ATR Length", minval=5, group=grpT)
rsiLen     = input.int(14, "RSI Length", minval=5, group=grpT)
adxMin     = input.float(18, "Min ADX (trend strength)", minval=0, group=grpT)

grpC = "Strength Grading"
minGrade   = input.string("C", "Min Grade to Show", options=["A","B","C"], group=grpC)
volMult    = input.float(1.0, "Volume vs 20-SMA mult", minval=0.5, step=0.1, group=grpC)
srTol      = input.float(0.6, "S/R Proximity (× ATR)", minval=0.1, step=0.1, group=grpC)
pvtLen     = input.int(5, "Pivot Lookback", minval=2, group=grpC)
divLook    = input.int(10, "Divergence Lookback", minval=5, group=grpC)

grpM = "Behaviour"
minBodyPct  = input.float(0.3, "Min Body % of Price (engulfing/etc)", minval=0.0, step=0.05, group=grpM)
dojiBpMax   = input.float(0.10, "Doji Max Body % of Range", minval=0.01, step=0.01, group=grpM)
wickAtrMult = input.float(2.0, "Min Reversal Wick (× ATR)", minval=0.5, step=0.1, group=grpM)
wickTolPct  = input.float(15, "Clean-Wick Tolerance (% of ATR)", minval=5, step=1, group=grpM)
requireGap  = input.bool(false, "Require true gap (Star/Pierce)", group=grpM)
relaxTrend  = input.bool(false, "Relax trend context (allow ranging markets)", group=grpM)
cooldown    = input.int(3, "Bars between same-dir signals", minval=0, group=grpM)
confirmOnly = input.bool(true, "Non-repaint (confirmed bars only)", group=grpM)
showDash    = input.bool(true, "Show dashboard", group=grpM)
theme       = input.string("Auto", "Dashboard Theme", options=["Dark","Light","Auto"], group=grpM)

minStrengthByGrade = minGrade == "A" ? 8 : minGrade == "B" ? 5 : 3

// ═══ BASE CALCS ════════════════════════════════════════════════════════════
bull = close > open
bear = close < open
bod  = math.abs(close - open)
cr   = high - low
uw   = high - math.max(open, close)
lw   = math.min(open, close) - low
bp   = cr > 0 ? bod / cr : 0.0

atr    = ta.atr(atrLen)
rsi    = ta.rsi(close, rsiLen)
volAvg = ta.sma(volume, 20)
volOK  = na(volume) ? false : volume > volAvg * volMult
[diP, diM, adx] = ta.dmi(14, 14)
strongTrend = adx > adxMin

ema20 = ta.ema(close, emaFast)
ema50 = ta.ema(close, emaSlow)
emaSlope = (ema20 - ema20[3]) / (atr * 3)

downTrend = close < ema20 and ema20 < ema50 and emaSlope < -0.1
upTrend   = close > ema20 and ema20 > ema50 and emaSlope >  0.1
ranging   = not upTrend and not downTrend

downCtx = downTrend or (relaxTrend and ranging)
upCtx   = upTrend   or (relaxTrend and ranging)

minBody = close * minBodyPct / 100
wickTol = atr * wickTolPct / 100

// ═══ SUPPORT / RESISTANCE ══════════════════════════════════════════════════
ph = ta.pivothigh(high, pvtLen, pvtLen)
plv= ta.pivotlow(low,  pvtLen, pvtLen)
var float lastRes = na
var float lastSup = na
if not na(ph)
    lastRes := ph
if not na(plv)
    lastSup := plv
nearSupport    = not na(lastSup) and math.abs(low  - lastSup) <= atr * srTol
nearResistance = not na(lastRes) and math.abs(high - lastRes) <= atr * srTol

// ═══ RSI DIVERGENCE ════════════════════════════════════════════════════════
bullDiv = low  < ta.lowest(low,  divLook)[1] and rsi > ta.lowest(rsi,  divLook)[1]
bearDiv = high > ta.highest(high,divLook)[1] and rsi < ta.highest(rsi, divLook)[1]

// ═══ CONFLUENCE SCORE (0-5) ════════════════════════════════════════════════
bullConf = (volOK ? 1 : 0) + (nearSupport ? 1 : 0) + (rsi < 55 ? 1 : 0) + (strongTrend ? 1 : 0) + (bullDiv ? 1 : 0)
bearConf = (volOK ? 1 : 0) + (nearResistance ? 1 : 0) + (rsi > 45 ? 1 : 0) + (strongTrend ? 1 : 0) + (bearDiv ? 1 : 0)

// ═══ DOJI DETECTION ════════════════════════════════════════════════════════
isDoji         = bp <= dojiBpMax
dragonflyDoji  = isDoji and lw >= wickAtrMult * atr and uw <= wickTol and cr >= atr * 1.5
gravestoneDoji = isDoji and uw >= wickAtrMult * atr and lw <= wickTol and cr >= atr * 1.5

// ═══ PATTERN GEOMETRY ══════════════════════════════════════════════════════
be = (bear[1] and bull and close >= open[1] and open <= close[1] and bod > math.abs(open[1]-close[1])*1.1 and bod > minBody and bod[1] > minBody)
se = (bull[1] and bear and close <= open[1] and open >= close[1] and bod > math.abs(open[1]-close[1])*1.1 and bod > minBody and bod[1] > minBody)

shapeHammer  = bp <= 0.35 and lw >= wickAtrMult*atr and uw <= math.max(bod*0.4, wickTol) and cr >= atr*1.5
shapeInvStar = bp <= 0.35 and uw >= wickAtrMult*atr and lw <= math.max(bod*0.4, wickTol) and cr >= atr*1.5

hm = shapeHammer  or dragonflyDoji
ss = shapeInvStar or gravestoneDoji

mid2  = math.avg(open[2], close[2])
doji1 = bod[1] / math.max(cr[1], 1e-9) < 0.3
gapDn = requireGap ? high[1] < low[2]  : open[1] < close[2]
gapUp = requireGap ? low[1]  > high[2] : open[1] > close[2]
ms = (bear[2] and bod[2] > minBody*2 and doji1 and bull and bod > minBody*2 and close > mid2 and gapDn)
es = (bull[2] and bod[2] > minBody*2 and doji1 and bear and bod > minBody*2 and close < mid2 and gapUp)

plOpen = requireGap ? open < low[1]  : open < close[1]
dcOpen = requireGap ? open > high[1] : open > close[1]
pl_ = (bear[1] and bod[1] > minBody and bull and plOpen and close > math.avg(open[1],close[1]) and close < open[1] and bod > minBody)
dc  = (bull[1] and bod[1] > minBody and bear and dcOpen and close < math.avg(open[1],close[1]) and close > open[1] and bod > minBody)

tws = (bull and bull[1] and bull[2] and close > close[1] and close[1] > close[2] and open <= close[1] and open >= open[1] and open[1] <= close[2] and open[1] >= open[2] and bod > minBody and bod[1] > minBody and bod[2] > minBody)
tbc = (bear and bear[1] and bear[2] and close < close[1] and close[1] < close[2] and open >= close[1] and open <= open[1] and open[1] >= close[2] and open[1] <= open[2] and bod > minBody and bod[1] > minBody and bod[2] > minBody)

tweezTol = atr * 0.12
twb = (bear[1] and bull and math.abs(low  - low[1])  <= tweezTol and lw >= bod)
twt = (bull[1] and bear and math.abs(high - high[1]) <= tweezTol and uw >= bod)

prevBodyHi = math.max(open[1], close[1])
prevBodyLo = math.min(open[1], close[1])
currBodyHi = math.max(open, close)
currBodyLo = math.min(open, close)
bullHar = bear[1] and bod[1] > minBody*2 and bull and currBodyHi <= prevBodyHi and currBodyLo >= prevBodyLo and bod < bod[1] * 0.6
bearHar = bull[1] and bod[1] > minBody*2 and bear and currBodyHi <= prevBodyHi and currBodyLo >= prevBodyLo and bod < bod[1] * 0.6

// ═══ PATTERN QUALITY SCORES (0-3 each unless noted) ════════════════════════
engRatio_b = bod / math.max(bod[1], 1e-9)
closeTop = cr > 0 ? (close - low) / cr : 0.0
closeBot = cr > 0 ? (high - close) / cr : 0.0
qBE_r = engRatio_b >= 2.0 ? 2 : engRatio_b >= 1.5 ? 1 : 0
qBE_c = closeTop >= 0.9 ? 2 : closeTop >= 0.75 ? 1 : 0
qBE = math.min(3, qBE_r + qBE_c)
qSE_r = engRatio_b >= 2.0 ? 2 : engRatio_b >= 1.5 ? 1 : 0
qSE_c = closeBot >= 0.9 ? 2 : closeBot >= 0.75 ? 1 : 0
qSE = math.min(3, qSE_r + qSE_c)

lwATR = lw / math.max(atr, 1e-9)
uwATR = uw / math.max(atr, 1e-9)
bodyTopPos = cr > 0 ? (math.min(open,close) - low) / cr : 0.0
bodyBotPos = cr > 0 ? (high - math.max(open,close)) / cr : 0.0
qHM_s = lwATR >= 4 ? 2 : lwATR >= 3 ? 1 : 0
qHM_b = bodyTopPos >= 0.65 ? 1 : 0
qHM_c = uw <= math.max(bod * 0.2, atr * 0.1) ? 1 : 0
qHM = math.min(3, qHM_s + qHM_b + qHM_c)
qSS_s = uwATR >= 4 ? 2 : uwATR >= 3 ? 1 : 0
qSS_b = bodyBotPos >= 0.65 ? 1 : 0
qSS_c = lw <= math.max(bod * 0.2, atr * 0.1) ? 1 : 0
qSS = math.min(3, qSS_s + qSS_b + qSS_c)

qDFD = math.min(3, (lwATR >= 4 ? 2 : lwATR >= 3 ? 1 : 0) + (uw <= wickTol ? 1 : 0))
qGSD = math.min(3, (uwATR >= 4 ? 2 : uwATR >= 3 ? 1 : 0) + (lw <= wickTol ? 1 : 0))

qIH   = math.min(2, qSS_s + (bodyBotPos >= 0.65 ? 1 : 0))
qHANG = math.min(2, qHM_s + (bodyTopPos >= 0.65 ? 1 : 0))

dojiness = bod[1] / math.max(cr[1], 1e-9)
pen_ms = (close - close[2]) / math.max(open[2] - close[2], 1e-9)
pen_es = (close[2] - close) / math.max(close[2] - open[2], 1e-9)
qMS_d = dojiness <= 0.1 ? 2 : dojiness <= 0.2 ? 1 : 0
qMS_p = pen_ms >= 1.0 ? 2 : pen_ms >= 0.75 ? 1 : 0
qMS = math.min(3, qMS_d + qMS_p)
qES_d = dojiness <= 0.1 ? 2 : dojiness <= 0.2 ? 1 : 0
qES_p = pen_es >= 1.0 ? 2 : pen_es >= 0.75 ? 1 : 0
qES = math.min(3, qES_d + qES_p)

pen_pl = (close - close[1]) / math.max(open[1] - close[1], 1e-9)
pen_dc = (close[1] - close) / math.max(close[1] - open[1], 1e-9)
qPL = pen_pl >= 0.9 ? 3 : pen_pl >= 0.75 ? 2 : pen_pl >= 0.6 ? 1 : 0
qDC = pen_dc >= 0.9 ? 3 : pen_dc >= 0.75 ? 2 : pen_dc >= 0.6 ? 1 : 0

avgBp = (bp + bp[1] + bp[2]) / 3
closeHi = ((cr > 0 ? (close-low)/cr : 0) + (cr[1] > 0 ? (close[1]-low[1])/cr[1] : 0) + (cr[2] > 0 ? (close[2]-low[2])/cr[2] : 0)) / 3
closeLo = ((cr > 0 ? (high-close)/cr : 0) + (cr[1] > 0 ? (high[1]-close[1])/cr[1] : 0) + (cr[2] > 0 ? (high[2]-close[2])/cr[2] : 0)) / 3
q3S_b = avgBp >= 0.7 ? 2 : avgBp >= 0.5 ? 1 : 0
q3S_c = closeHi >= 0.85 ? 1 : 0
q3S = math.min(3, q3S_b + q3S_c)
q3C_b = avgBp >= 0.7 ? 2 : avgBp >= 0.5 ? 1 : 0
q3C_c = closeLo >= 0.85 ? 1 : 0
q3C = math.min(3, q3C_b + q3C_c)

twb_tight = math.abs(low - low[1]) / math.max(atr, 1e-9)
twt_tight = math.abs(high - high[1]) / math.max(atr, 1e-9)
qTWB_t = twb_tight <= 0.04 ? 2 : twb_tight <= 0.08 ? 1 : 0
qTWB_w = lw / math.max(bod, 1e-9) >= 2.0 ? 1 : 0
qTWB = math.min(3, qTWB_t + qTWB_w)
qTWT_t = twt_tight <= 0.04 ? 2 : twt_tight <= 0.08 ? 1 : 0
qTWT_w = uw / math.max(bod, 1e-9) >= 2.0 ? 1 : 0
qTWT = math.min(3, qTWT_t + qTWT_w)

haramiRatio = bod / math.max(bod[1], 1e-9)
qHAR_r = haramiRatio <= 0.3 ? 2 : haramiRatio <= 0.5 ? 1 : 0
qHAR_b = bod[1] / math.max(atr, 1e-9) >= 1.5 ? 1 : 0
qHAR = math.min(3, qHAR_r + qHAR_b)

// ═══ PATTERN-INTERNAL VOLUME CONFIRMATION (0-2) ════════════════════════════
volR1 = volume / math.max(volAvg, 1e-9)
volR2 = volume / math.max(volume[1], 1e-9)
volR3 = volume / math.max(math.avg(volume[1], volume[2]), 1e-9)
vp1 = volR1 >= 1.5 ? 2 : volR1 >= 1.2 ? 1 : 0
vp2 = volR2 >= 1.5 ? 2 : volR2 >= 1.2 ? 1 : 0
vp3 = volR3 >= 1.5 ? 2 : volR3 >= 1.2 ? 1 : 0

// ═══ CONTEXT-GATED PATTERN FIRES ═══════════════════════════════════════════
bullDFD = dragonflyDoji and downCtx
bullRev = be          and downCtx[1]
bullMS  = ms          and downCtx[2]
bull3   = tws         and downCtx[3]
bullHam = shapeHammer and downCtx and not bullDFD
bullPL  = pl_         and downCtx[1]
bullHa  = bullHar     and downCtx[1]
bullTw  = twb         and downCtx
bullIH  = shapeInvStar and downCtx

bearGSD = gravestoneDoji and upCtx
bearRev = se          and upCtx[1]
bearES  = es          and upCtx[2]
bear3   = tbc         and upCtx[3]
bearSS  = shapeInvStar and upCtx and not bearGSD
bearDC  = dc          and upCtx[1]
bearHa  = bearHar     and upCtx[1]
bearTw  = twt         and upCtx
bearHM  = shapeHammer and upCtx

// ═══ COMPOSITE STRENGTH (0-10) ═════════════════════════════════════════════
bullQ = bullRev ? qBE : bullMS ? qMS : bull3 ? q3S : bullDFD ? qDFD : bullHam ? qHM : bullPL ? qPL : bullHa ? qHAR : bullTw ? qTWB : bullIH ? qIH : 0
bullV = bullRev ? vp2 : bullMS ? vp3 : bull3 ? vp3 : bullDFD ? vp1 : bullHam ? vp1 : bullPL ? vp2 : bullHa ? vp2 : bullTw ? vp2 : bullIH ? vp1 : 0
bullName = bullRev ? "BullEng" : bullMS ? "MornStar" : bull3 ? "3Soldiers" : bullDFD ? "DragDoji" : bullHam ? "Hammer" : bullPL ? "Pierce" : bullHa ? "BullHarami" : bullTw ? "Tweezer" : bullIH ? "InvHammer" : ""
bullGeom = bullRev or bullMS or bull3 or bullDFD or bullHam or bullPL or bullHa or bullTw or bullIH
bullStrength = bullQ + bullConf + bullV

bearQ = bearRev ? qSE : bearES ? qES : bear3 ? q3C : bearGSD ? qGSD : bearSS ? qSS : bearDC ? qDC : bearHa ? qHAR : bearTw ? qTWT : bearHM ? qHANG : 0
bearV = bearRev ? vp2 : bearES ? vp3 : bear3 ? vp3 : bearGSD ? vp1 : bearSS ? vp1 : bearDC ? vp2 : bearHa ? vp2 : bearTw ? vp2 : bearHM ? vp1 : 0
bearName = bearRev ? "BearEng" : bearES ? "EveStar" : bear3 ? "3Crows" : bearGSD ? "GraveDoji" : bearSS ? "ShootStar" : bearDC ? "DkCloud" : bearHa ? "BearHarami" : bearTw ? "Tweezer" : bearHM ? "HangMan" : ""
bearGeom = bearRev or bearES or bear3 or bearGSD or bearSS or bearDC or bearHa or bearTw or bearHM
bearStrength = bearQ + bearConf + bearV

bullGrade = bullStrength >= 8 ? "A" : bullStrength >= 5 ? "B" : bullStrength >= 3 ? "C" : ""
bearGrade = bearStrength >= 8 ? "A" : bearStrength >= 5 ? "B" : bearStrength >= 3 ? "C" : ""

// ═══ COOLDOWN + NON-REPAINT ════════════════════════════════════════════════
confirmed = confirmOnly ? barstate.isconfirmed : true
var int lastBullBar = -100000
var int lastBearBar = -100000
var float lastStrength = na
var string lastDir = ""
var string lastGrade = ""
var string lastPat = ""

bullFire = bullGeom and confirmed and bullStrength >= minStrengthByGrade and (bar_index - lastBullBar > cooldown)
bearFire = bearGeom and confirmed and bearStrength >= minStrengthByGrade and (bar_index - lastBearBar > cooldown)

if bullFire
    lastBullBar := bar_index
    lastStrength := bullStrength
    lastDir := "BUY"
    lastGrade := bullGrade
    lastPat := bullName
if bearFire
    lastBearBar := bar_index
    lastStrength := bearStrength
    lastDir := "SELL"
    lastGrade := bearGrade
    lastPat := bearName

// ═══ LABELS — color refresh ════════════════════════════════════════════════
bullLblSize = bullGrade == "A" ? size.large : bullGrade == "B" ? size.normal : size.small
bearLblSize = bearGrade == "A" ? size.large : bearGrade == "B" ? size.normal : size.small

// Lower transparency than before — was 0/25/55, now 0/10/30
bullTrans = bullGrade == "A" ? 0 : bullGrade == "B" ? 10 : 30
bearTrans = bearGrade == "A" ? 0 : bearGrade == "B" ? 10 : 30

// Saturated custom backgrounds — each pattern gets a distinct, readable color
bullBase = bullRev ? #00c853 :   // BullEng — vivid green
           bullMS  ? #00897b :   // MornStar — teal
           bull3   ? #2e7d32 :   // 3Soldiers — forest green
           bullDFD ? #00bcd4 :   // DragDoji — cyan
           bullHam ? #43a047 :   // Hammer — medium green
           bullPL  ? #1e88e5 :   // Pierce — vivid blue
           bullHa  ? #6a1b9a :   // BullHarami — deep purple
           bullTw  ? #c2185b :   // Tweezer — magenta
           bullIH  ? #5d4037 :   // InvHammer — brown
                     #455a64     // default — slate

bearBase = bearRev ? #d32f2f :   // BearEng — vivid red
           bearES  ? #6a1b9a :   // EveStar — deep purple
           bear3   ? #b71c1c :   // 3Crows — dark red
           bearGSD ? #e91e63 :   // GraveDoji — pink-red
           bearSS  ? #c62828 :   // ShootStar — dark red
           bearDC  ? #ef6c00 :   // DkCloud — dark orange
           bearHa  ? #4e342e :   // BearHarami — dark brown
           bearTw  ? #ad1457 :   // Tweezer — dark magenta
           bearHM  ? #424242 :   // HangMan — dark gray
                     #37474f     // default — dark slate

// Text color: white on dark backgrounds, black on the two light ones (BullEng lime, DragDoji cyan)
bullText = (bullRev or bullDFD) ? color.black : color.white
bearText = color.white  // all bear backgrounds are dark enough for white

if bullFire
    label.new(bar_index, low, text=bullGrade + " | " + bullName + " " + str.tostring(bullStrength) + "/10", yloc=yloc.belowbar, style=label.style_label_up, color=color.new(bullBase, bullTrans), textcolor=bullText, size=bullLblSize)
if bearFire
    label.new(bar_index, high, text=bearGrade + " | " + bearName + " " + str.tostring(bearStrength) + "/10", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(bearBase, bearTrans), textcolor=bearText, size=bearLblSize)

bullBarTrans = bullGrade == "A" ? 30 : bullGrade == "B" ? 50 : 70
bearBarTrans = bearGrade == "A" ? 30 : bearGrade == "B" ? 50 : 70
barcolor(bullFire ? color.new(color.lime, bullBarTrans) : bearFire ? color.new(color.red, bearBarTrans) : na)

plot(ema20, "EMA Fast", color.new(color.yellow,0))
plot(ema50, "EMA Slow", color.new(color.orange,0))

// ═══ SCREENER OUTPUTS ══════════════════════════════════════════════════════
bullSig = bullFire ? bullStrength : 0
bearSig = bearFire ? -bearStrength : 0
plot(bullSig, "BullishStrength", display=display.none)
plot(bearSig, "BearishStrength", display=display.none)

// ═══ DASHBOARD ═════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 8, border_width=1, border_color=color.new(color.gray, 50))
if showDash and barstate.islast
    bgLum = color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)
    useDark = theme == "Dark" ? true : theme == "Light" ? false : bgLum < 384

    bgPanel  = useDark ? color.new(#1e222d, 0) : color.new(#ffffff, 0)
    bgHeader = color.new(#2962ff, 0)
    txtLight = useDark ? color.new(#d1d4dc, 0) : color.new(#1e222d, 0)
    txtBright= useDark ? color.new(#ffffff, 0) : color.new(#000000, 0)
    greenC   = color.new(#26a69a, 0)
    redC     = color.new(#ef5350, 0)
    grayC    = color.new(#787b86, 0)

    trendTxt = upTrend ? "UP" : downTrend ? "DOWN" : "RANGE"
    trendCol = upTrend ? greenC : downTrend ? redC : grayC

    table.cell(dash, 0, 0, "FORTHIUS SCANNER v5", text_color=color.white, bgcolor=bgHeader, text_size=size.small)
    table.cell(dash, 1, 0, "", bgcolor=bgHeader)

    table.cell(dash, 0, 1, "Trend", text_color=txtLight, bgcolor=bgPanel, text_size=size.small)
    table.cell(dash, 1, 1, trendTxt, text_color=color.white, bgcolor=trendCol, text_size=size.small)

    table.cell(dash, 0, 2, "ADX", text_color=txtLight, bgcolor=bgPanel, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(adx, "#.0") + (strongTrend ? " ✓" : ""), text_color=strongTrend ? greenC : txtLight, bgcolor=bgPanel, text_size=size.small)

    table.cell(dash, 0, 3, "RSI", text_color=txtLight, bgcolor=bgPanel, text_size=size.small)
    rsiCol = rsi > 70 ? redC : rsi < 30 ? greenC : txtBright
    table.cell(dash, 1, 3, str.tostring(rsi, "#.0"), text_color=rsiCol, bgcolor=bgPanel, text_size=size.small)

    table.cell(dash, 0, 4, "Vol vs Avg", text_color=txtLight, bgcolor=bgPanel, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(volR1, "#.0") + "x" + (volOK ? " ✓" : ""), text_color=volOK ? greenC : txtLight, bgcolor=bgPanel, text_size=size.small)

    table.cell(dash, 0, 5, "Near S/R", text_color=txtLight, bgcolor=bgPanel, text_size=size.small)
    srTxt = nearSupport ? "Support" : nearResistance ? "Resist" : "—"
    srCol = nearSupport ? greenC : nearResistance ? redC : txtLight
    table.cell(dash, 1, 5, srTxt, text_color=srCol, bgcolor=bgPanel, text_size=size.small)

    table.cell(dash, 0, 6, "Last Signal", text_color=txtLight, bgcolor=bgPanel, text_size=size.small)
    lastTxt = na(lastStrength) ? "—" : lastDir + " " + lastPat
    lastCol = lastDir == "BUY" ? greenC : lastDir == "SELL" ? redC : grayC
    table.cell(dash, 1, 6, lastTxt, text_color=color.white, bgcolor=lastCol, text_size=size.small)

    table.cell(dash, 0, 7, "Strength", text_color=txtLight, bgcolor=bgPanel, text_size=size.small)
    strTxt = na(lastStrength) ? "—" : lastGrade + " | " + str.tostring(lastStrength) + "/10"
    strCol = lastGrade == "A" ? color.new(#ffd700, 0) : lastGrade == "B" ? color.new(#00bcd4, 0) : grayC
    strTxtCol = lastGrade == "A" ? color.new(#000000, 0) : color.white
    table.cell(dash, 1, 7, strTxt, text_color=strTxtCol, bgcolor=strCol, text_size=size.small)

// ═══ ALERTS ════════════════════════════════════════════════════════════════
alertcondition(bullFire, "Bullish Reversal (any grade)", "Forthius BUY on {{ticker}} ({{interval}})")
alertcondition(bearFire, "Bearish Reversal (any grade)", "Forthius SELL on {{ticker}} ({{interval}})")
alertcondition(bullFire and bullStrength >= 8, "Bullish Reversal Grade A", "Forthius BUY Grade A on {{ticker}}")
alertcondition(bearFire and bearStrength >= 8, "Bearish Reversal Grade A", "Forthius SELL Grade A on {{ticker}}")
alertcondition(bullDFD and confirmed, "Dragonfly Doji at downtrend", "Forthius DragDoji on {{ticker}} ({{interval}})")
alertcondition(bearGSD and confirmed, "Gravestone Doji at uptrend", "Forthius GraveDoji on {{ticker}} ({{interval}})")

if bullFire
    alert("Forthius BUY " + bullGrade + " | " + bullName + " | Strength " + str.tostring(bullStrength) + "/10 on " + syminfo.ticker, alert.freq_once_per_bar_close)
if bearFire
    alert("Forthius SELL " + bearGrade + " | " + bearName + " | Strength " + str.tostring(bearStrength) + "/10 on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
