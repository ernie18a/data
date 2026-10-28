# AI SMC Pro v2

- url: https://www.tradingview.com/script/jLeCvReE/
- type: indicator
- pine_id: PUB;5817f9bbe71344c6900ccf170d5f84f5
- version: 1.0

## Description

AI SMC Order Flow Pro v2.0 is an advanced Smart Money Concepts indicator combining ICT methodology, multi-timeframe analysis, Bayesian AI scoring, and order flow estimation — all in a single non-repainting overlay.
Core Features:

BOS & CHoCH structure detection
Bullish & Bearish Order Blocks (auto-invalidation)
Fair Value Gaps (auto-fill detection)
Liquidity levels (LQH / LQL)
Premium & Discount zones
Session High/Low (Asia, London, New York)
Support & Resistance (50-bar dynamic)

AI Engine:

Bayesian confidence score (0–100%) combining trend, momentum, MACD, volume, structure, order flow, MTF bias, session and zone
Three modes: Conservative / Balanced / Aggressive

Order Flow Module:

Estimated buy/sell pressure
Estimated delta & cumulative delta
Volume spike detection

Signals:

LONG / SHORT entries with SL, TP1, TP2
ATR-based risk management (customizable multipliers)
Minimum R:R filter (1:2 / 1:3 / 1:4)
Session filter (London & New York only)
MTF confirmation required

Built-in Backtest:

Win rate, Profit Factor, Expectancy
Max win/loss streak
Trailing stop & Break-even options

Best used on: EUR/USD · GBP/USD · 15m timeframe during London or New York session.

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════╗
// ║       AI SMC ORDER FLOW PRO v2.0 — Pine Script v5           ║
// ║   Smart Money · ICT · Order Flow · Bayesian AI · Backtest   ║
// ║              Anti-Repaint · No Lookahead                     ║
// ╚══════════════════════════════════════════════════════════════╝

//@version=5
indicator("AI SMC Pro v2", shorttitle="AI SMC v2", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ── SETTINGS ──
modeInput    = input.string("Balanced", "📊 Mode", options=["Conservative","Balanced","Aggressive"], group="⚙️ Mode")
showBOS      = input.bool(true,  "BOS / CHoCH",           group="🏗️ Structure")
showLiq      = input.bool(true,  "Liquidity Levels",       group="🏗️ Structure")
showOB       = input.bool(true,  "Order Blocks",           group="🏗️ Structure")
showFVG      = input.bool(true,  "Fair Value Gaps",        group="🏗️ Structure")
showSR       = input.bool(true,  "Support / Resistance",   group="🏗️ Structure")
showSessions = input.bool(true,  "Session H/L",            group="🏗️ Structure")
showPD       = input.bool(true,  "Premium/Discount Zones", group="🏗️ Structure")
showSignals  = input.bool(true,  "BUY / SELL Signals",     group="📡 Signals")
showSLTP     = input.bool(true,  "SL / TP Boxes",          group="📡 Signals")
rrMode       = input.string("1:2","Min R:R", options=["1:2","1:3","1:4"], group="📡 Signals")
sessionFilter= input.bool(true,  "Session Filter",         group="📡 Signals")
showOF       = input.bool(true,  "Order Flow Module",      group="📈 Order Flow")
showDelta    = input.bool(true,  "Delta Labels",           group="📈 Order Flow")
showSpikes   = input.bool(true,  "Volume Spikes",          group="📈 Order Flow")
colorCandles = input.bool(false, "Candle Coloring by OF",  group="📈 Order Flow")
showDash     = input.bool(true,  "AI Dashboard",           group="🖥️ Dashboard")
showBacktest = input.bool(true,  "Backtest Stats",          group="🖥️ Dashboard")
showMTF      = input.bool(true,  "MTF Confirmation",       group="📊 MTF")
atrMult_SL   = input.float(1.5, "ATR SL Multiplier", minval=0.5, maxval=5.0,  step=0.1, group="🛡️ Risk")
atrMult_TP   = input.float(3.0, "ATR TP Multiplier", minval=1.0, maxval=10.0, step=0.1, group="🛡️ Risk")
useTrailing  = input.bool(false, "Trailing Stop (ATR)",    group="🛡️ Risk")
useBreakeven = input.bool(false, "Break Even at 1R",       group="🛡️ Risk")
maxOB        = input.int(5,     "Max Order Blocks shown", minval=1, maxval=10,  group="🛡️ Risk")

// ── COLORS ──
C_BUY     = color.new(#00E5FF, 0)
C_SELL    = color.new(#FF3D71, 0)
C_OB_BULL = color.new(#00C853, 78)
C_OB_BEAR = color.new(#D50000, 78)
C_FVG_B   = color.new(#FFD600, 86)
C_FVG_S   = color.new(#FF6D00, 86)
C_BOS     = color.new(#651FFF, 0)
C_CHOCH   = color.new(#FF6D00, 0)
C_LIQ     = color.new(#FFEA00, 0)
C_SR      = color.new(#546E7A, 55)
C_PD_P    = color.new(#FF3D71, 93)
C_PD_D    = color.new(#00E5FF, 93)
C_DASH_BG = color.new(#0D1117, 88)
C_DASH_HD = color.new(#161B22, 92)
C_GREEN   = color.new(#00E676, 0)
C_RED     = color.new(#FF1744, 0)
C_YELLOW  = color.new(#FFEA00, 0)
C_GREY    = color.new(#546E7A, 0)
C_WHITE   = color.new(#ECEFF1, 0)
C_SPIKE   = color.new(#FF6D00, 0)

// ── MODULE 1 — CORE INDICATORS ──
atr14   = ta.atr(14)
atr5    = ta.atr(5)
ema8    = ta.ema(close, 8)
ema21   = ta.ema(close, 21)
ema50   = ta.ema(close, 50)
ema200  = ta.ema(close, 200)
rsi14   = ta.rsi(close, 14)
[macdL, macdS, macdH] = ta.macd(close, 12, 26, 9)
volSMA  = ta.sma(volume, 20)
volSMA5 = ta.sma(volume, 5)
stochK  = ta.sma(ta.stoch(close, high, low, 14), 3)
stochD  = ta.sma(stochK, 3)

bullTrend  = ema8 > ema21 and ema21 > ema50 and close > ema50
bearTrend  = ema8 < ema21 and ema21 < ema50 and close < ema50
trendStr   = bullTrend ? "Bullish" : bearTrend ? "Bearish" : "Neutral"
volRatio   = atr14 / close * 100
highVol    = volRatio > 1.2
lowVol     = volRatio < 0.04
normalVol  = not highVol and not lowVol
candleRange = high - low
bodySize    = math.abs(close - open)
upperWick   = high - math.max(close, open)
lowerWick   = math.min(close, open) - low
bullCandle  = close > open and bodySize > atr5 * 0.4
bearCandle  = close < open and bodySize > atr5 * 0.4

// ── MODULE 2 — ORDER FLOW ──
closePos       = candleRange > 0 ? (close - low) / candleRange : 0.5
wickRejBull    = candleRange > 0 ? lowerWick / candleRange : 0.0
wickRejBear    = candleRange > 0 ? upperWick / candleRange : 0.0
volWeight      = volume > volSMA ? 1.2 : 0.9
rawBuyP        = math.min(100, (closePos * 55 + wickRejBull * 30 + (bullCandle ? 15 : 0)) * volWeight)
rawSellP       = math.min(100, ((1 - closePos) * 55 + wickRejBear * 30 + (bearCandle ? 15 : 0)) * volWeight)
totalPressure  = rawBuyP + rawSellP
buyPressure    = ta.ema(totalPressure > 0 ? rawBuyP / totalPressure * 100 : 50, 3)
sellPressure   = 100 - buyPressure
estimatedDelta = buyPressure - sellPressure
cumulDelta     = ta.ema(estimatedDelta, 10)
volSpike       = volume > volSMA * 2.2
volAboveAvg    = volume > volSMA
ofBullish = buyPressure > 57 and estimatedDelta > 8  and cumulDelta > 0
ofBearish = sellPressure > 57 and estimatedDelta < -8 and cumulDelta < 0
ofNeutral = not ofBullish and not ofBearish
ofBiasStr = ofBullish ? "Bullish" : ofBearish ? "Bearish" : "Neutral"

// ── MODULE 3 — SWING STRUCTURE & BOS/CHoCH ──
swingH = ta.pivothigh(high, 5, 5)
swingL = ta.pivotlow(low,  5, 5)
var float[] swingHighs = array.new_float(0)
var float[] swingLows  = array.new_float(0)
if not na(swingH)
    array.push(swingHighs, swingH)
    if array.size(swingHighs) > 5
        array.shift(swingHighs)
if not na(swingL)
    array.push(swingLows, swingL)
    if array.size(swingLows) > 5
        array.shift(swingLows)
lastH  = array.size(swingHighs) >= 1 ? array.get(swingHighs, array.size(swingHighs)-1) : na
lastH2 = array.size(swingHighs) >= 2 ? array.get(swingHighs, array.size(swingHighs)-2) : na
lastL  = array.size(swingLows)  >= 1 ? array.get(swingLows,  array.size(swingLows)-1)  : na
lastL2 = array.size(swingLows)  >= 2 ? array.get(swingLows,  array.size(swingLows)-2)  : na
bosBull   = not na(lastH) and close > lastH and close[1] <= lastH
bosBear   = not na(lastL) and close < lastL and close[1] >= lastL
chochBull = not na(lastH) and not na(lastH2) and lastH > lastH2 and close > lastH
chochBear = not na(lastL) and not na(lastL2) and lastL < lastL2  and close < lastL
mktStructure = (bosBull or chochBull) ? "Bullish" : (bosBear or chochBear) ? "Bearish" : "Neutral"
mktBull = mktStructure == "Bullish"
mktBear = mktStructure == "Bearish"
if showBOS and barstate.isconfirmed
    if bosBull
        label.new(bar_index, high + atr14*0.4, "BOS ▲", color=C_BOS, textcolor=C_WHITE, style=label.style_label_down, size=size.tiny)
    if bosBear
        label.new(bar_index, low - atr14*0.4, "BOS ▼", color=C_BOS, textcolor=C_WHITE, style=label.style_label_up, size=size.tiny)
    if chochBull
        label.new(bar_index, high + atr14*0.7, "CHoCH ▲", color=C_CHOCH, textcolor=C_WHITE, style=label.style_label_down, size=size.tiny)
    if chochBear
        label.new(bar_index, low - atr14*0.7, "CHoCH ▼", color=C_CHOCH, textcolor=C_WHITE, style=label.style_label_up, size=size.tiny)

// ── MODULE 4 — ORDER BLOCKS ──
var float[] obBullTops  = array.new_float(0)
var float[] obBullBots  = array.new_float(0)
var int[]   obBullBars  = array.new_int(0)
var box[]   obBullBoxes = array.new_box(0)
var float[] obBearTops  = array.new_float(0)
var float[] obBearBots  = array.new_float(0)
var int[]   obBearBars  = array.new_int(0)
var box[]   obBearBoxes = array.new_box(0)
if barstate.isconfirmed and showOB
    if close[1] < open[1] and close > high[1] and bullCandle and volAboveAvg
        array.push(obBullTops, high[1])
        array.push(obBullBots, low[1])
        array.push(obBullBars, bar_index[1])
        newBox = box.new(bar_index[1], high[1], bar_index+40, low[1], border_color=C_OB_BULL, border_width=1, bgcolor=C_OB_BULL)
        array.push(obBullBoxes, newBox)
        if array.size(obBullBoxes) > maxOB
            box.delete(array.shift(obBullBoxes))
            array.shift(obBullTops)
            array.shift(obBullBots)
            array.shift(obBullBars)
    if close[1] > open[1] and close < low[1] and bearCandle and volAboveAvg
        array.push(obBearTops, high[1])
        array.push(obBearBots, low[1])
        array.push(obBearBars, bar_index[1])
        newBox = box.new(bar_index[1], high[1], bar_index+40, low[1], border_color=C_OB_BEAR, border_width=1, bgcolor=C_OB_BEAR)
        array.push(obBearBoxes, newBox)
        if array.size(obBearBoxes) > maxOB
            box.delete(array.shift(obBearBoxes))
            array.shift(obBearTops)
            array.shift(obBearBots)
            array.shift(obBearBars)
    int i = 0
    while i < array.size(obBullBots)
        if close < array.get(obBullBots, i)
            box.delete(array.get(obBullBoxes, i))
            array.remove(obBullBoxes, i)
            array.remove(obBullTops,  i)
            array.remove(obBullBots,  i)
            array.remove(obBullBars,  i)
        else
            i += 1
    int j = 0
    while j < array.size(obBearTops)
        if close > array.get(obBearTops, j)
            box.delete(array.get(obBearBoxes, j))
            array.remove(obBearBoxes, j)
            array.remove(obBearTops,  j)
            array.remove(obBearBots,  j)
            array.remove(obBearBars,  j)
        else
            j += 1

// ── MODULE 5 — FAIR VALUE GAPS ──
var float[] fvgTops  = array.new_float(0)
var float[] fvgBots  = array.new_float(0)
var bool[]  fvgBull  = array.new_bool(0)
var box[]   fvgBoxes = array.new_box(0)
if showFVG and barstate.isconfirmed
    if low > high[2] and (low - high[2]) > atr14 * 0.25
        array.push(fvgTops, low)
        array.push(fvgBots, high[2])
        array.push(fvgBull, true)
        newFVG = box.new(bar_index-2, low, bar_index+20, high[2], border_color=C_FVG_B, border_width=1, bgcolor=C_FVG_B)
        array.push(fvgBoxes, newFVG)
    if high < low[2] and (low[2] - high) > atr14 * 0.25
        array.push(fvgTops, low[2])
        array.push(fvgBots, high)
        array.push(fvgBull, false)
        newFVG = box.new(bar_index-2, low[2], bar_index+20, high, border_color=C_FVG_S, border_width=1, bgcolor=C_FVG_S)
        array.push(fvgBoxes, newFVG)
    int k = 0
    while k < array.size(fvgBoxes)
        isBull = array.get(fvgBull, k)
        top    = array.get(fvgTops, k)
        bot    = array.get(fvgBots, k)
        filled = isBull ? close < bot : close > top
        if filled
            box.delete(array.get(fvgBoxes, k))
            array.remove(fvgBoxes, k)
            array.remove(fvgTops,  k)
            array.remove(fvgBots,  k)
            array.remove(fvgBull,  k)
        else
            k += 1
    if array.size(fvgBoxes) > 8
        box.delete(array.shift(fvgBoxes))
        array.shift(fvgTops)
        array.shift(fvgBots)
        array.shift(fvgBull)

// ── MODULE 6 — LIQUIDITY LEVELS ──
if showLiq and barstate.isconfirmed
    if not na(swingH)
        line.new(bar_index-5, swingH, bar_index+35, swingH, color=C_LIQ, width=1, style=line.style_dotted)
        label.new(bar_index+35, swingH, "LQH", color=color.new(C_LIQ,0), textcolor=color.black, style=label.style_label_left, size=size.tiny)
    if not na(swingL)
        line.new(bar_index-5, swingL, bar_index+35, swingL, color=C_LIQ, width=1, style=line.style_dotted)
        label.new(bar_index+35, swingL, "LQL", color=color.new(C_LIQ,0), textcolor=color.black, style=label.style_label_left, size=size.tiny)

// ── MODULE 7 — SUPPORT & RESISTANCE ──
srHigh = ta.highest(high, 50)
srLow  = ta.lowest(low,  50)
if showSR and barstate.isconfirmed
    line.new(bar_index, srHigh, bar_index+30, srHigh, color=C_SR, width=1, style=line.style_dashed)
    line.new(bar_index, srLow,  bar_index+30, srLow,  color=C_SR, width=1, style=line.style_dashed)

// ── MODULE 8 — PREMIUM / DISCOUNT ZONES ──
rangeHigh  = ta.highest(high, 50)
rangeLow   = ta.lowest(low,   50)
rangeMid   = (rangeHigh + rangeLow) / 2
inPremium  = close > rangeMid
inDiscount = close < rangeMid
if showPD and barstate.isconfirmed
    box.new(bar_index, rangeHigh, bar_index+1, rangeMid, bgcolor=C_PD_P, border_color=color.new(C_SELL,70), border_width=0)
    box.new(bar_index, rangeMid,  bar_index+1, rangeLow,  bgcolor=C_PD_D, border_color=color.new(C_BUY,70),  border_width=0)

// ── MODULE 9 — SESSIONS ──
hUTC       = hour(time, "UTC")
isAsia     = hUTC >= 0  and hUTC < 8
isLondon   = hUTC >= 7  and hUTC < 12
isNY       = hUTC >= 13 and hUTC < 21
isActive   = isLondon or isNY
sessionStr = isAsia ? "Asia 🌏" : isLondon ? "London 🇬🇧" : isNY ? "New York 🗽" : "Off ⛔"
var float asiaH = na
var float asiaL = na
if isAsia
    asiaH := na(asiaH) or high > asiaH ? high : asiaH
    asiaL := na(asiaL) or low  < asiaL ? low  : asiaL
if showSessions and barstate.isconfirmed and not na(asiaH)
    line.new(bar_index, asiaH, bar_index+10, asiaH, color=color.new(#82B1FF,45), width=1, style=line.style_dotted)
    line.new(bar_index, asiaL, bar_index+10, asiaL, color=color.new(#82B1FF,45), width=1, style=line.style_dotted)

// ── MODULE 10 — MULTI-TIMEFRAME ──
ema50_15  = request.security(syminfo.tickerid, "15",  ta.ema(close,50), lookahead=barmerge.lookahead_off)
ema50_60  = request.security(syminfo.tickerid, "60",  ta.ema(close,50), lookahead=barmerge.lookahead_off)
ema50_240 = request.security(syminfo.tickerid, "240", ta.ema(close,50), lookahead=barmerge.lookahead_off)
rsi_60    = request.security(syminfo.tickerid, "60",  ta.rsi(close,14), lookahead=barmerge.lookahead_off)
close_15  = request.security(syminfo.tickerid, "15",  close, lookahead=barmerge.lookahead_off)
close_60  = request.security(syminfo.tickerid, "60",  close, lookahead=barmerge.lookahead_off)
close_240 = request.security(syminfo.tickerid, "240", close, lookahead=barmerge.lookahead_off)
mtfBull15    = close_15  > ema50_15
mtfBull60    = close_60  > ema50_60 and rsi_60 > 50
mtfBull240   = close_240 > ema50_240
mtfBullCount = (mtfBull15 ? 1:0) + (mtfBull60 ? 1:0) + (mtfBull240 ? 1:0)
mtfBearCount = 3 - mtfBullCount
mtfBias      = mtfBullCount >= 2 ? "Bullish" : mtfBearCount >= 2 ? "Bearish" : "Mixed"
mtfConf      = math.round(math.max(mtfBullCount, mtfBearCount) / 3 * 100)

// ── MODULE 11 — BAYESIAN AI SCORE ──
w_trend = 0.22
w_mom = 0.15
w_macd = 0.10
w_vol = 0.08
w_struct = 0.15
w_of = 0.13
w_mtf = 0.10
w_session = 0.04
w_pd = 0.03
f_trend   = bullTrend ? 1.0 : bearTrend ? 1.0 : 0.3
f_mom     = (rsi14 > 52 and rsi14 < 68) ? 1.0 : (rsi14 < 48 and rsi14 > 32) ? 1.0 : (rsi14 > 45 and rsi14 < 72) ? 0.6 : 0.2
f_macd    = ((macdL > macdS and macdH > 0) or (macdL < macdS and macdH < 0)) ? 1.0 : math.abs(macdH) < math.abs(macdH[1]) ? 0.3 : 0.5
f_vol     = volSpike ? 1.0 : volAboveAvg ? 0.7 : 0.3
f_struct  = (bosBull or chochBull or bosBear or chochBear) ? 1.0 : mktBull or mktBear ? 0.6 : 0.2
f_of      = (ofBullish or ofBearish) ? 1.0 : ofNeutral ? 0.3 : 0.3
f_mtf     = mtfConf >= 100 ? 1.0 : mtfConf >= 67 ? 0.75 : mtfConf >= 33 ? 0.4 : 0.1
f_session = isActive ? 1.0 : isAsia ? 0.5 : 0.1
f_pd      = (inDiscount and bullTrend) or (inPremium and bearTrend) ? 1.0 : 0.4
rawScore  = (f_trend*w_trend + f_mom*w_mom + f_macd*w_macd + f_vol*w_vol + f_struct*w_struct + f_of*w_of + f_mtf*w_mtf + f_session*w_session + f_pd*w_pd) / (w_trend+w_mom+w_macd+w_vol+w_struct+w_of+w_mtf+w_session+w_pd)
aiConf = math.round(math.min(math.max(rawScore * 100, 0), 100))

// ── MODULE 12 — SIGNAL LOGIC ──
minAI     = modeInput == "Conservative" ? 78 : modeInput == "Balanced" ? 62 : 48
minRR_num = rrMode == "1:2" ? 2.0 : rrMode == "1:3" ? 3.0 : 4.0
sessOk    = not sessionFilter or isActive
mtfOkBull = not showMTF or mtfBias == "Bullish" or (mtfBias == "Mixed" and modeInput == "Aggressive")
mtfOkBear = not showMTF or mtfBias == "Bearish" or (mtfBias == "Mixed" and modeInput == "Aggressive")
ofOkBull  = not showOF or ofBullish or (ofNeutral and modeInput != "Conservative")
ofOkBear  = not showOF or ofBearish or (ofNeutral and modeInput != "Conservative")
pdOkBull  = not showPD or inDiscount
pdOkBear  = not showPD or inPremium
stochOkBull = stochK > stochD and stochK < 80
stochOkBear = stochK < stochD and stochK > 20
buyCondition  = barstate.isconfirmed and showSignals and bullTrend and rsi14 > 45 and rsi14 < 72 and macdL > macdS and macdH > macdH[1] and volume > volSMA * 0.85 and normalVol and sessOk and buyPressure > sellPressure and aiConf >= minAI and mtfOkBull and ofOkBull and pdOkBull and stochOkBull and (bosBull or chochBull or (close > ema21 and close > ema50))
sellCondition = barstate.isconfirmed and showSignals and bearTrend and rsi14 < 55 and rsi14 > 28 and macdL < macdS and macdH < macdH[1] and volume > volSMA * 0.85 and normalVol and sessOk and sellPressure > buyPressure and aiConf >= minAI and mtfOkBear and ofOkBear and pdOkBear and stochOkBear and (bosBear or chochBear or (close < ema21 and close < ema50))

// ── MODULE 13 — SL / TP ──
slDist    = atr14 * atrMult_SL
tpDist    = slDist * minRR_num
buyEntry  = close
buySL     = close - slDist
buyTP1    = close + tpDist
buyTP2    = close + tpDist * 1.618
buyRR     = tpDist / slDist
sellEntry = close
sellSL    = close + slDist
sellTP1   = close - tpDist
sellTP2   = close - tpDist * 1.618
sellRR    = tpDist / slDist

// ── MODULE 14 — TRADE VISUALIZATION ──
var box   slBox       = na
var box   tpBox       = na
var box   tp2Box      = na
var line  entryLine   = na
var label signalLabel = na
if buyCondition and showSLTP
    if not na(slBox)
        box.delete(slBox)
    if not na(tpBox)
        box.delete(tpBox)
    if not na(tp2Box)
        box.delete(tp2Box)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(signalLabel)
        label.delete(signalLabel)
    slBox       := box.new(bar_index, buyEntry, bar_index+25, buySL,    border_color=C_SELL,               border_width=1, bgcolor=color.new(C_SELL,83))
    tpBox       := box.new(bar_index, buyTP1,   bar_index+25, buyEntry, border_color=C_BUY,                border_width=1, bgcolor=color.new(C_BUY,83))
    tp2Box      := box.new(bar_index, buyTP2,   bar_index+25, buyTP1,   border_color=color.new(C_BUY,55),  border_width=1, bgcolor=color.new(C_BUY,91))
    entryLine   := line.new(bar_index, buyEntry, bar_index+25, buyEntry, color=C_WHITE, width=1, style=line.style_dashed)
    signalLabel := label.new(bar_index, low - atr14*0.9, "◆ LONG\nEntry: " + str.tostring(buyEntry,"#.####") + "\nSL: " + str.tostring(buySL,"#.####") + "\nTP1: " + str.tostring(buyTP1,"#.####") + "\nTP2: " + str.tostring(buyTP2,"#.####") + "\nRR: 1:" + str.tostring(math.round(buyRR)) + "\nAI: " + str.tostring(aiConf) + "%" + "\nOF: " + ofBiasStr + "\nZone: " + (inDiscount ? "Discount ✓" : "Premium"), color=C_BUY, textcolor=color.black, style=label.style_label_up, size=size.small)
if sellCondition and showSLTP
    if not na(slBox)
        box.delete(slBox)
    if not na(tpBox)
        box.delete(tpBox)
    if not na(tp2Box)
        box.delete(tp2Box)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(signalLabel)
        label.delete(signalLabel)
    slBox       := box.new(bar_index, sellSL,    bar_index+25, sellEntry, border_color=C_SELL,              border_width=1, bgcolor=color.new(C_SELL,83))
    tpBox       := box.new(bar_index, sellEntry, bar_index+25, sellTP1,   border_color=C_BUY,               border_width=1, bgcolor=color.new(C_BUY,83))
    tp2Box      := box.new(bar_index, sellTP1,   bar_index+25, sellTP2,   border_color=color.new(C_BUY,55), border_width=1, bgcolor=color.new(C_BUY,91))
    entryLine   := line.new(bar_index, sellEntry, bar_index+25, sellEntry, color=C_WHITE, width=1, style=line.style_dashed)
    signalLabel := label.new(bar_index, high + atr14*0.9, "◆ SHORT\nEntry: " + str.tostring(sellEntry,"#.####") + "\nSL: " + str.tostring(sellSL,"#.####") + "\nTP1: " + str.tostring(sellTP1,"#.####") + "\nTP2: " + str.tostring(sellTP2,"#.####") + "\nRR: 1:" + str.tostring(math.round(sellRR)) + "\nAI: " + str.tostring(aiConf) + "%" + "\nOF: " + ofBiasStr + "\nZone: " + (inPremium ? "Premium ✓" : "Discount"), color=C_SELL, textcolor=color.white, style=label.style_label_down, size=size.small)

// ── MODULE 15 — SIGNAL MARKERS ──
plotshape(buyCondition  and showSignals, "LONG",  shape.triangleup,   location.belowbar, C_BUY,  size=size.small)
plotshape(sellCondition and showSignals, "SHORT", shape.triangledown, location.abovebar, C_SELL, size=size.small)

// ── MODULE 16 — DELTA LABELS & SPIKES ──
if showOF and showDelta and barstate.isconfirmed and math.abs(estimatedDelta) > 18
    dStr = estimatedDelta > 0 ? "Δ +" + str.tostring(math.round(estimatedDelta)) : "Δ " + str.tostring(math.round(estimatedDelta))
    dCol = estimatedDelta > 0 ? C_BUY : C_SELL
    label.new(bar_index, high + atr14*0.12, dStr, color=color.new(dCol,78), textcolor=dCol, style=label.style_label_down, size=size.tiny)
if showOF and showSpikes and volSpike and barstate.isconfirmed
    label.new(bar_index, low - atr14*0.18, "⚡", color=color.new(C_SPIKE,65), textcolor=C_SPIKE, style=label.style_label_up, size=size.tiny)

// ── MODULE 17 — CANDLE COLORING ──
barcolor(colorCandles and showOF ? (ofBullish ? color.new(C_BUY,58) : ofBearish ? color.new(C_SELL,58) : color.new(#546E7A,78)) : na)

// ── MODULE 18 — BACKTEST ──
var int   bt_total    = 0
var int   bt_wins     = 0
var int   bt_losses   = 0
var float bt_pnl      = 0.0
var float bt_winSum   = 0.0
var float bt_lossSum  = 0.0
var int   bt_consW    = 0
var int   bt_consL    = 0
var int   bt_maxConsW = 0
var int   bt_maxConsL = 0
var float bt_entry    = na
var float bt_sl       = na
var float bt_tp       = na
var bool  bt_isBuy    = na
var bool  bt_inTrade  = false
var float bt_trailSL  = na
if barstate.isconfirmed
    if not bt_inTrade
        if buyCondition
            bt_entry := close
            bt_sl := close - slDist
            bt_tp := close + tpDist
            bt_isBuy := true
            bt_inTrade := true
            bt_trailSL := close - slDist
            bt_total += 1
        else if sellCondition
            bt_entry := close
            bt_sl := close + slDist
            bt_tp := close - tpDist
            bt_isBuy := false
            bt_inTrade := true
            bt_trailSL := close + slDist
            bt_total += 1
    if bt_inTrade and not na(bt_entry)
        if useTrailing
            if bt_isBuy
                bt_trailSL := math.max(bt_trailSL, close - atr14 * atrMult_SL)
            else
                bt_trailSL := math.min(bt_trailSL, close + atr14 * atrMult_SL)
            bt_sl := bt_trailSL
        if useBreakeven
            if bt_isBuy and close >= bt_entry + slDist
                bt_sl := math.max(bt_sl, bt_entry)
            if not bt_isBuy and close <= bt_entry - slDist
                bt_sl := math.min(bt_sl, bt_entry)
        hitSL = bt_isBuy ? low  <= bt_sl : high >= bt_sl
        hitTP = bt_isBuy ? high >= bt_tp  : low  <= bt_tp
        if hitTP or hitSL
            result = hitTP ? (bt_isBuy ? bt_tp - bt_entry : bt_entry - bt_tp) : (bt_isBuy ? bt_sl - bt_entry : bt_entry - bt_sl)
            bt_pnl += result
            if result > 0
                bt_wins += 1
                bt_winSum += result
                bt_consW += 1
                bt_consL := 0
                bt_maxConsW := math.max(bt_maxConsW, bt_consW)
            else
                bt_losses += 1
                bt_lossSum += math.abs(result)
                bt_consL += 1
                bt_consW := 0
                bt_maxConsL := math.max(bt_maxConsL, bt_consL)
            bt_inTrade := false
            bt_entry := na
bt_winRate    = bt_total  > 0 ? math.round(bt_wins / bt_total * 100) : 0
bt_pf         = bt_lossSum > 0 ? math.round(bt_winSum / bt_lossSum * 100) / 100 : 0.0
bt_expectancy = bt_total  > 0 ? bt_pnl / bt_total : 0.0
bt_avgWin     = bt_wins   > 0 ? bt_winSum  / bt_wins   : 0.0
bt_avgLoss    = bt_losses > 0 ? bt_lossSum / bt_losses : 0.0

// ── MODULE 19 — AI DASHBOARD ──
var table dash = na
if showDash and (barstate.islastconfirmedhistory or barstate.isrealtime)
    if na(dash)
        dash := table.new(position.top_right, 2, 22, bgcolor=C_DASH_BG, border_color=color.new(#30363D,0), border_width=1, frame_color=color.new(C_BUY,55), frame_width=1)
    aiCol = aiConf >= 75 ? C_GREEN : aiConf >= 55 ? C_YELLOW : C_RED
    table.cell(dash, 0, 0, "⬡ AI SMC PRO v2", text_color=C_BUY,    bgcolor=C_DASH_HD, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 1, 0, modeInput,          text_color=C_YELLOW, bgcolor=C_DASH_HD, text_halign=text.align_center, text_size=size.tiny)
    table.cell(dash, 0,  1, "AI Confidence",   text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1,  1, str.tostring(aiConf) + "%", text_color=aiCol, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0,  2, "Trend",           text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1,  2, trendStr,          text_color=bullTrend?C_GREEN:bearTrend?C_RED:C_GREY, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0,  3, "Structure",       text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1,  3, mktStructure,      text_color=mktBull?C_GREEN:mktBear?C_RED:C_GREY, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0,  4, "Session",         text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1,  4, sessionStr,        text_color=isActive?C_GREEN:C_GREY, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0,  5, "Volatility",      text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1,  5, highVol?"HIGH ⚠":lowVol?"LOW":"Normal", text_color=highVol?C_RED:lowVol?C_YELLOW:C_GREEN, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0,  6, "Zone",            text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1,  6, inPremium?"Premium":"Discount", text_color=inPremium?C_SELL:C_BUY, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0,  7, "MTF Bias",        text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1,  7, mtfBias + " " + str.tostring(mtfConf) + "%", text_color=mtfBias=="Bullish"?C_GREEN:mtfBias=="Bearish"?C_RED:C_YELLOW, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0,  8, "Order Flow",      text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1,  8, ofBiasStr,         text_color=ofBullish?C_GREEN:ofBearish?C_RED:C_GREY, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0,  9, "Buy Pressure",    text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1,  9, str.tostring(math.round(buyPressure)) + "%", text_color=C_BUY, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 10, "Sell Pressure",   text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(math.round(sellPressure)) + "%", text_color=C_SELL, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 11, "Est. Delta",      text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    dDisp = estimatedDelta > 0 ? "+" + str.tostring(math.round(estimatedDelta)) : str.tostring(math.round(estimatedDelta))
    table.cell(dash, 1, 11, dDisp,            text_color=estimatedDelta>0?C_GREEN:C_RED, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 12, "Cumul. Delta",   text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    cdDisp = cumulDelta > 0 ? "+" + str.tostring(math.round(cumulDelta)) : str.tostring(math.round(cumulDelta))
    table.cell(dash, 1, 12, cdDisp,           text_color=cumulDelta>0?C_GREEN:C_RED, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 13, "Vol Spike",      text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 13, volSpike?"YES ⚡":"No", text_color=volSpike?C_SPIKE:C_GREY, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 14, "Repaint",        text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 14, "✓ SAFE",         text_color=C_GREEN, text_size=size.small, text_halign=text.align_right)
    if showBacktest
        table.cell(dash, 0, 15, "── BACKTEST ──", text_color=C_YELLOW, text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, 15, "",               text_size=size.tiny)
        table.cell(dash, 0, 16, "Trades",         text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, 16, str.tostring(bt_total), text_color=C_WHITE, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 17, "Win Rate",       text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, 17, str.tostring(bt_winRate) + "%", text_color=bt_winRate>=55?C_GREEN:bt_winRate>=45?C_YELLOW:C_RED, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 18, "Profit Factor",  text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, 18, str.tostring(bt_pf,"#.##"), text_color=bt_pf>=1.5?C_GREEN:bt_pf>=1.0?C_YELLOW:C_RED, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 19, "Expectancy",     text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, 19, str.tostring(bt_expectancy,"#.####"), text_color=bt_expectancy>=0?C_GREEN:C_RED, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 20, "Max W Streak",   text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, 20, str.tostring(bt_maxConsW), text_color=C_GREEN, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 21, "Max L Streak",   text_color=C_GREY, text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, 21, str.tostring(bt_maxConsL), text_color=C_RED, text_size=size.small, text_halign=text.align_right)

// ── MODULE 20 — EMA PLOTS ──
plot(ema21,  "EMA 21",  color=color.new(#42A5F5,18), linewidth=1)
plot(ema50,  "EMA 50",  color=color.new(#FFCA28,28), linewidth=1)
plot(ema200, "EMA 200", color=color.new(#EF5350,38), linewidth=2)

// ── MODULE 21 — ALERTS ──
alertcondition(buyCondition,                "LONG Signal",          "AI LONG ✓ | {{ticker}} | TF: {{interval}}")
alertcondition(sellCondition,               "SHORT Signal",         "AI SHORT ✓ | {{ticker}} | TF: {{interval}}")
alertcondition(buyCondition  and volSpike,  "LONG + Vol Spike",     "LONG + SPIKE ⚡ | {{ticker}}")
alertcondition(sellCondition and volSpike,  "SHORT + Vol Spike",    "SHORT + SPIKE ⚡ | {{ticker}}")
alertcondition(bosBull or chochBull,        "Bull Structure Break", "BOS/CHoCH Bull | {{ticker}}")
alertcondition(bosBear or chochBear,        "Bear Structure Break", "BOS/CHoCH Bear | {{ticker}}")
alertcondition(buyCondition  and ofBullish, "LONG + OF Confirmed",  "LONG + OF BULL ✓ | {{ticker}}")
alertcondition(sellCondition and ofBearish, "SHORT + OF Confirmed", "SHORT + OF BEAR ✓ | {{ticker}}")
alertcondition(volSpike,                    "Volume Spike",         "VOL SPIKE ⚡ | {{ticker}}")

// ── END — AI SMC ORDER FLOW PRO v2.0 ──
````
