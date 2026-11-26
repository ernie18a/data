# Forthius Reversal Scanner

- url: https://www.tradingview.com/script/UnD8Y8RM-Forthius-Reversal-Scanner/
- type: indicator
- pine_id: PUB;e08bf7aced7e451f855ef501594c7099
- version: 1.0

## Description

This reversal scanner rates the candlestick patterns

## Source Code

````pine
//@version=6
indicator("Forthius Reversal Scanner v4", overlay=true, max_labels_count=500)

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
minBodyPct = input.float(0.3, "Min Body % of Price", minval=0.0, step=0.05, group=grpM)
requireGap = input.bool(false, "Require true gap (Star/Pierce)", group=grpM)
cooldown   = input.int(3, "Bars between same-dir signals", minval=0, group=grpM)
confirmOnly= input.bool(true, "Non-repaint (confirmed bars only)", group=grpM)
showDash   = input.bool(true, "Show dashboard", group=grpM)
theme      = input.string("Auto", "Dashboard Theme", options=["Dark","Light","Auto"], group=grpM)

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

minBody = close * minBodyPct / 100

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

// ═══ PATTERN GEOMETRY ══════════════════════════════════════════════════════
be = (bear[1] and bull and close >= open[1] and open <= close[1] and bod > math.abs(open[1]-close[1])*1.1 and bod > minBody and bod[1] > minBody)
se = (bull[1] and bear and close <= open[1] and open >= close[1] and bod > math.abs(open[1]-close[1])*1.1 and bod > minBody and bod[1] > minBody)
hm = (bp <= 0.35 and lw >= 2.0*atr and uw <= bod*0.4 and cr >= atr*1.5)
ss = (bp <= 0.35 and uw >= 2.0*atr and lw <= bod*0.4 and cr >= atr*1.5)
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

// ═══ PATTERN QUALITY SCORES (0-3 each) ═════════════════════════════════════
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
qHM_c = uw <= bod * 0.2 ? 1 : 0
qHM = math.min(3, qHM_s + qHM_b + qHM_c)
qSS_s = uwATR >= 4 ? 2 : uwATR >= 3 ? 1 : 0
qSS_b = bodyBotPos >= 0.65 ? 1 : 0
qSS_c = lw <= bod * 0.2 ? 1 : 0
qSS = math.min(3, qSS_s + qSS_b + qSS_c)

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

// ═══ PATTERN-INTERNAL VOLUME CONFIRMATION (0-2) ════════════════════════════
volR1 = volume / math.max(volAvg, 1e-9)
volR2 = volume / math.max(volume[1], 1e-9)
volR3 = volume / math.max(math.avg(volume[1], volume[2]), 1e-9)
vp1 = volR1 >= 1.5 ? 2 : volR1 >= 1.2 ? 1 : 0
vp2 = volR2 >= 1.5 ? 2 : volR2 >= 1.2 ? 1 : 0
vp3 = volR3 >= 1.5 ? 2 : volR3 >= 1.2 ? 1 : 0

// ═══ CONTEXT-GATED PATTERN FIRES ═══════════════════════════════════════════
bullRev = be  and downTrend[1]
bullMS  = ms  and downTrend[2]
bull3   = tws and downTrend[3]
bullHam = hm  and downTrend
bullPL  = pl_ and downTrend[1]
bullTw  = twb and downTrend

bearRev = se  and upTrend[1]
bearES  = es  and upTrend[2]
bear3   = tbc and upTrend[3]
bearSS  = ss  and upTrend
bearDC  = dc  and upTrend[1]
bearTw  = twt and upTrend

// ═══ COMPOSITE STRENGTH (0-10) ═════════════════════════════════════════════
bullQ = bullRev ? qBE : bullMS ? qMS : bull3 ? q3S : bullHam ? qHM : bullPL ? qPL : bullTw ? qTWB : 0
bullV = bullRev ? vp2 : bullMS ? vp3 : bull3 ? vp3 : bullHam ? vp1 : bullPL ? vp2 : bullTw ? vp2 : 0
bullName = bullRev ? "BullEng" : bullMS ? "MornStar" : bull3 ? "3Soldiers" : bullHam ? "Hammer" : bullPL ? "Pierce" : bullTw ? "Tweezer" : ""
bullGeom = bullRev or bullMS or bull3 or bullHam or bullPL or bullTw
bullStrength = bullQ + bullConf + bullV

bearQ = bearRev ? qSE : bearES ? qES : bear3 ? q3C : bearSS ? qSS : bearDC ? qDC : bearTw ? qTWT : 0
bearV = bearRev ? vp2 : bearES ? vp3 : bear3 ? vp3 : bearSS ? vp1 : bearDC ? vp2 : bearTw ? vp2 : 0
bearName = bearRev ? "BearEng" : bearES ? "EveStar" : bear3 ? "3Crows" : bearSS ? "ShootStar" : bearDC ? "DkCloud" : bearTw ? "Tweezer" : ""
bearGeom = bearRev or bearES or bear3 or bearSS or bearDC or bearTw
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

// ═══ LABELS (size + transparency reflect grade) ════════════════════════════
bullLblSize = bullGrade == "A" ? size.large : bullGrade == "B" ? size.normal : size.small
bearLblSize = bearGrade == "A" ? size.large : bearGrade == "B" ? size.normal : size.small
bullTrans = bullGrade == "A" ? 0 : bullGrade == "B" ? 25 : 55
bearTrans = bearGrade == "A" ? 0 : bearGrade == "B" ? 25 : 55

bullBase = bullRev ? color.lime : bullMS ? color.teal : bull3 ? color.green : bullHam ? color.green : bullPL ? color.blue : color.aqua
bearBase = bearRev ? color.red  : bearES ? color.purple : bear3 ? color.maroon : bearSS ? color.maroon : bearDC ? color.orange : color.fuchsia

if bullFire
    label.new(bar_index, low, text=bullGrade + " | " + bullName + " " + str.tostring(bullStrength) + "/10", yloc=yloc.belowbar, style=label.style_label_up, color=color.new(bullBase, bullTrans), textcolor=color.black, size=bullLblSize)
if bearFire
    label.new(bar_index, high, text=bearGrade + " | " + bearName + " " + str.tostring(bearStrength) + "/10", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(bearBase, bearTrans), textcolor=color.white, size=bearLblSize)

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
    // Auto theme: luminance check on chart background
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

    table.cell(dash, 0, 0, "FORTHIUS SCANNER v4", text_color=color.white, bgcolor=bgHeader, text_size=size.small)
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

if bullFire
    alert("Forthius BUY " + bullGrade + " | " + bullName + " | Strength " + str.tostring(bullStrength) + "/10 on " + syminfo.ticker, alert.freq_once_per_bar_close)
if bearFire
    alert("Forthius SELL " + bearGrade + " | " + bearName + " | Strength " + str.tostring(bearStrength) + "/10 on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
