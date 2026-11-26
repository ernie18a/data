#   Android Smart Trend (AST)

- url: https://www.tradingview.com/script/FWmID1A8/
- type: indicator
- pine_id: PUB;279c56ce58204ab4bd3c6f981ce02465
- version: 7.0

## Description

# 🤖 Android Smart Trend (AST)

Android Smart Trend (AST) is a multi-engine trend intelligence system designed to transform complex market information into a single adaptive trend structure.

Instead of relying on one indicator or a single market condition, AST combines multiple layers of analysis including trend strength, momentum, volatility, market structure, volume behavior, moving average relationships, and multi-timeframe confirmation. The result is a clean and easy-to-read trend environment that helps traders focus on direction rather than noise.

The core philosophy behind AST is simple:

**Hide complexity. Show clarity.**

While many indicators overwhelm the chart with dozens of signals, panels, and calculations, AST processes those components internally and presents only the information that matters most:

• Smart Trend Line
• Adaptive Power Strength
• Multi-Timeframe Confirmation
• Dynamic Trend Aura
• Visual Market Direction

The trend line automatically adapts to changing market conditions. As trend strength increases, the visual structure becomes more dominant, helping traders quickly identify high-confidence environments. During weaker or uncertain conditions, the system naturally reduces visual intensity, allowing traders to recognize potential consolidation phases.

### Key Features

✅ Adaptive Smart Trend Line

A dynamic trend structure that adjusts according to market strength and directional conviction.

✅ Power-Based Visualization

Trend intensity is visually represented through line strength and aura expansion, making market conditions instantly recognizable.

✅ Multi-Timeframe Intelligence

Combines information from multiple timeframes to create a more balanced and reliable directional assessment.

✅ Clean Chart Experience

Designed to reduce chart clutter while maintaining high informational value.

✅ Non-Repainting Logic

Signals and trend state changes are generated using confirmed market data.

### How To Read AST

🟢 Green Environment

Bullish trend conditions with positive directional strength.

🔴 Red Environment

Bearish trend conditions with negative directional strength.

🟡 Neutral Environment

Market is transitioning, consolidating, or lacking directional conviction.

Higher power values indicate stronger trend alignment and broader market agreement across the underlying engines.

### Philosophy

AST is not designed to predict the future.

Its purpose is to organize market information, measure trend quality, and help traders make more informed decisions within existing market conditions.

The goal is simple:

**Less noise. More clarity. Smarter trends.**

Android Smart Trend (AST)
Adaptive Market Intelligence.

## Source Code

````pine
//@version=6
indicator("ATS POWER LINE — POWER FIX + SIGNALS", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━ INPUTS
lang = input.string("EN", "Language", options=["EN", "TR", "DE", "FR", "ES", "PT", "RU", "AR", "JA", "ZH"])

tf1 = input.timeframe("15", "Fast TF")
tf2 = input.timeframe("60", "Mid TF")
tf3 = input.timeframe("240", "Macro TF")

trendLen  = input.int(55, "Organ Trend EMA")
momLen    = input.int(10, "Organ Momentum")
zLen      = input.int(34, "Z Lookback")
smoothLen = input.int(8, "Organ Smooth")

matcPct    = input.float(2.0, "MATC Band %", step=0.1)
matcSmooth = input.int(5, "MATC Smooth")
matcMirror = input.float(1.3, "MATC Mirror", step=0.1)

atrLen  = input.int(14, "ATR Length")
atrMult = input.float(2.4, "Trend Line Power", step=0.1)

bullTh = input.float(60.0, "Bull Power Level", step=1)
bearTh = input.float(40.0, "Bear Power Level", step=1)

strongTh = input.float(75.0, "Strong Power Level", step=1)
normalTh = input.float(60.0, "Normal Power Level", step=1)
weakTh   = input.float(45.0, "Weak Level", step=1)

useMtf      = input.bool(true, "Use MTF Power")
usePvmBoost = input.bool(true, "Use PVM Trend / Impulse Boost")
pvmWeight   = input.float(0.25, "PVM Boost Weight", minval=0.0, maxval=0.60, step=0.05)

showAura    = input.bool(true, "Premium Aura")
showSignals = input.bool(true, "BUY / SELL")
showBars    = input.bool(true, "Candle Color")
showPanel   = input.bool(true, "Mini Panel")
showStar    = input.bool(true, "Power Star")
showBadge   = input.bool(true, "Power Box")

bullC = input.color(color.lime, "Bull Color")
bearC = input.color(color.red, "Bear Color")
midC  = input.color(color.gray, "Neutral Color")
goldC = input.color(color.yellow, "Power Color")

//━━━━━━━━━━━━━━━━ LANGUAGE
t_power() =>
    lang == "TR" ? "Güç" : lang == "DE" ? "Kraft" : lang == "FR" ? "Puissance" : lang == "ES" ? "Potencia" : lang == "PT" ? "Força" : lang == "RU" ? "Сила" : lang == "AR" ? "القوة" : lang == "JA" ? "パワー" : lang == "ZH" ? "力量" : "Power"

t_avg() =>
    lang == "TR" ? "Ort. Güç" : lang == "DE" ? "Ø Kraft" : lang == "FR" ? "Moy. Puiss." : lang == "ES" ? "Pot. Media" : lang == "PT" ? "Força Méd." : lang == "RU" ? "Сред. сила" : lang == "AR" ? "متوسط القوة" : lang == "JA" ? "平均パワー" : lang == "ZH" ? "平均力量" : "AVG Power"

t_trend() =>
    lang == "TR" ? "Trend" : lang == "RU" ? "Тренд" : lang == "AR" ? "الاتجاه" : lang == "JA" ? "トレンド" : lang == "ZH" ? "趋势" : "Trend"

t_line() =>
    lang == "TR" ? "Çizgi" : lang == "DE" ? "Linie" : lang == "FR" ? "Ligne" : lang == "ES" ? "Línea" : lang == "PT" ? "Linha" : lang == "RU" ? "Линия" : lang == "AR" ? "الخط" : lang == "JA" ? "ライン" : lang == "ZH" ? "线" : "Line"

//━━━━━━━━━━━━━━━━ HELPERS
z(src, l) =>
    mean = ta.sma(src, l)
    dev  = ta.stdev(src, l)
    dev != 0 ? (src - mean) / dev : 0.0

clamp(x, lo, hi) =>
    math.max(math.min(x, hi), lo)

normalize(src, len) =>
    lo = ta.lowest(src, len)
    hi = ta.highest(src, len)
    hi != lo ? 100.0 * (src - lo) / (hi - lo) : 50.0

//━━━━━━━━━━━━━━━━ CORE SCORE
f_score() =>
    emaTrend = ta.ema(close, trendLen)
    trendRaw = emaTrend - emaTrend[1]
    momRaw = ta.roc(close, momLen)

    obvLocal = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0)
    obvRaw = obvLocal - obvLocal[1]

    atrLocal = ta.atr(atrLen)
    priceDir = close > ta.ema(close, 20) ? 1.0 : -1.0
    atrRaw = (atrLocal - atrLocal[1]) * priceDir

    trendZ = z(trendRaw, zLen)
    momZ   = z(momRaw, zLen)
    obvZ   = z(obvRaw, zLen)
    atrZ   = z(atrRaw, zLen)

    organRaw = trendZ * 2.0 + momZ * 1.5 + obvZ * 1.0 + atrZ * 0.5
    organ = ta.ema(organRaw, smoothLen)
    organPct = clamp(organ / 6.0 * 50.0 + 50.0, 0.0, 100.0)

    src = hl2
    upper = src * (1.0 + matcPct / 100.0)
    lower = src * (1.0 - matcPct / 100.0)
    mid = (upper + lower) / 2.0
    dist = (upper - lower) / 2.0
    resist = ta.ema(mid + dist * matcMirror, matcSmooth)
    support = ta.ema(mid - dist * matcMirror, matcSmooth)

    matcMid = (resist + support) / 2.0
    matcRange = math.max(resist - support, syminfo.mintick)
    matcPctNow = clamp((close - matcMid) / matcRange * 50.0 + 50.0, 0.0, 100.0)

    emaFast = ta.ema(close, 21)
    emaSlow = ta.ema(close, 55)
    ribbonPct = emaFast > emaSlow ? 65.0 : emaFast < emaSlow ? 35.0 : 50.0

    rsiVal = ta.rsi(close, 14)
    rsiPct = clamp(rsiVal, 0.0, 100.0)

    organPct * 0.40 + matcPctNow * 0.25 + ribbonPct * 0.20 + rsiPct * 0.15

//━━━━━━━━━━━━━━━━ PVM ENGINE
f_pvm() =>
    priceChange = ta.change(close)
    volumeChange = ta.change(volume)

    corrRaw = nz(ta.correlation(priceChange, volumeChange, 55), 0)
    trendEngine = ta.ema((corrRaw + 1.0) * 50.0, 9)

    relVolBase = ta.ema(volume, 34)
    relVol = volume / math.max(relVolBase, 1.0)

    atrNow = ta.atr(14)
    atrBase = ta.ema(atrNow, 34)
    atrExpansion = atrNow / math.max(atrBase, syminfo.mintick)

    impulseRaw = atrExpansion * relVol
    impulseEngine = ta.ema(normalize(impulseRaw, 100), 9)

    priceRoc = ta.roc(close, 14)
    directionEngine = ta.ema(normalize(priceRoc, 100), 9)

    trendEngine * 0.40 + impulseEngine * 0.35 + directionEngine * 0.25

//━━━━━━━━━━━━━━━━ SCORE
basePct = f_score()
pvmPct  = f_pvm()

tf1Pct = request.security(syminfo.tickerid, tf1, f_score()[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf2Pct = request.security(syminfo.tickerid, tf2, f_score()[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf3Pct = request.security(syminfo.tickerid, tf3, f_score()[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf1Pvm = request.security(syminfo.tickerid, tf1, f_pvm()[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf2Pvm = request.security(syminfo.tickerid, tf2, f_pvm()[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf3Pvm = request.security(syminfo.tickerid, tf3, f_pvm()[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
 
mtfPct = tf1Pct * 0.30 + tf2Pct * 0.35 + tf3Pct * 0.35
mtfPvm = tf1Pvm * 0.30 + tf2Pvm * 0.35 + tf3Pvm * 0.35

rawPower = useMtf ? basePct * 0.45 + mtfPct * 0.55 : basePct
pvmPower = useMtf ? pvmPct * 0.45 + mtfPvm * 0.55 : pvmPct

powerPct = usePvmBoost ? rawPower * (1.0 - pvmWeight) + pvmPower * pvmWeight : rawPower
powerPct := clamp(powerPct, 0.0, 100.0)

//━━━━━━━━━━━━━━━━ AVG REFERENCE
avgRawPower = (basePct + tf1Pct + tf2Pct + tf3Pct) / 4.0
avgPvmPower = (pvmPct + tf1Pvm + tf2Pvm + tf3Pvm) / 4.0

avgPower = usePvmBoost ? avgRawPower * (1.0 - pvmWeight) + avgPvmPower * pvmWeight : avgRawPower
avgPower := clamp(avgPower, 0.0, 100.0)

powerEdge = powerPct - avgPower

//━━━━━━━━━━━━━━━━ POWER STATE
powerStrongBull = powerPct >= strongTh
powerBull       = powerPct >= normalTh and powerPct < strongTh
powerNeutral    = powerPct >= weakTh and powerPct < normalTh
powerBear       = powerPct < weakTh

powerStateTxt = powerStrongBull ? "STRONG" : powerBull ? "BULL" : powerNeutral ? "NEUTRAL" : "WEAK"
powerStateCol = powerStrongBull ? goldC : powerBull ? bullC : powerNeutral ? midC : bearC

//━━━━━━━━━━━━━━━━ STATE
bullPower = powerPct >= bullTh
bearPower = powerPct <= bearTh

cascadeBull = tf1Pct > bullTh and tf2Pct > bullTh and tf3Pct > bullTh
cascadeBear = tf1Pct < bearTh and tf2Pct < bearTh and tf3Pct < bearTh

//━━━━━━━━━━━━━━━━ TREND LINE
atr = ta.atr(atrLen)
basis = ta.ema(close, 34)

var int trendDir = 0
var float trendLine = na

directionalPowerPre = powerPct >= 50 ? powerPct : 100.0 - powerPct
directionalPvmPre   = pvmPower >= 50 ? pvmPower : 100.0 - pvmPower

pvmHotImpulsePre = directionalPvmPre >= 75

dynamicAtrMult = atrMult
if usePvmBoost and pvmHotImpulsePre
    dynamicAtrMult := atrMult * 1.08
else if usePvmBoost and directionalPvmPre < 55
    dynamicAtrMult := atrMult * 0.92

bullBase = basis - atr * dynamicAtrMult
bearBase = basis + atr * dynamicAtrMult

newBuy = barstate.isconfirmed and bullPower and trendDir != 1
newSell = barstate.isconfirmed and bearPower and trendDir != -1

if newBuy
    trendDir := 1
    trendLine := bullBase

if newSell
    trendDir := -1
    trendLine := bearBase

if trendDir == 1
    trendLine := math.max(nz(trendLine[1], bullBase), bullBase)

if trendDir == -1
    trendLine := math.min(nz(trendLine[1], bearBase), bearBase)

lineCol = trendDir == 1 ? bullC : trendDir == -1 ? bearC : midC

//━━━━━━━━━━━━━━━━ DIRECTIONAL POWER
directionalPower = trendDir == 1 ? powerPct : trendDir == -1 ? 100.0 - powerPct : 50.0
directionalPvm   = trendDir == 1 ? pvmPower : trendDir == -1 ? 100.0 - pvmPower : 50.0

finalLinePower = usePvmBoost ? directionalPower * 0.70 + directionalPvm * 0.30 : directionalPower

pvmBullSupport = pvmPower > 60
pvmBearSupport = pvmPower < 40

weakTrend   = finalLinePower < 60
mediumTrend = finalLinePower >= 60 and finalLinePower < 80
strongTrend = finalLinePower >= 80

//━━━━━━━━━━━━━━━━ PLOTS
pWeak = plot(weakTrend ? trendLine : na, title="Weak Trend", color=color.new(lineCol, 0), linewidth=2, style=plot.style_linebr)
pMid = plot(mediumTrend ? trendLine : na, title="Medium Trend", color=color.new(lineCol, 0), linewidth=4, style=plot.style_linebr)
pStrong = plot(strongTrend ? trendLine : na, title="Strong Trend", color=color.new(lineCol, 0), linewidth=7, style=plot.style_linebr)

pPrice = plot(close, title="Price Base", color=color.new(color.white, 100))

auraPower = finalLinePower
auraTransp = auraPower >= 80 ? 74 : auraPower >= 60 ? 86 : 97

fill(pPrice, pWeak, color=showAura and trendDir == 1 ? color.new(bullC, auraTransp) : na)
fill(pPrice, pWeak, color=showAura and trendDir == -1 ? color.new(bearC, auraTransp) : na)
fill(pPrice, pMid, color=showAura and trendDir == 1 ? color.new(bullC, auraTransp) : na)
fill(pPrice, pMid, color=showAura and trendDir == -1 ? color.new(bearC, auraTransp) : na)
fill(pPrice, pStrong, color=showAura and trendDir == 1 ? color.new(bullC, auraTransp) : na)
fill(pPrice, pStrong, color=showAura and trendDir == -1 ? color.new(bearC, auraTransp) : na)

plot(showAura and mediumTrend and trendDir == 1 ? trendLine + atr * 0.16 : na, title="Medium Bull Glow", color=color.new(bullC, 78), linewidth=6, style=plot.style_linebr)
plot(showAura and mediumTrend and trendDir == -1 ? trendLine - atr * 0.16 : na, title="Medium Bear Glow", color=color.new(bearC, 78), linewidth=6, style=plot.style_linebr)

plot(showAura and strongTrend and trendDir == 1 ? trendLine + atr * 0.20 : na, title="Strong Bull Glow", color=color.new(bullC, 66), linewidth=10, style=plot.style_linebr)
plot(showAura and strongTrend and trendDir == -1 ? trendLine - atr * 0.20 : na, title="Strong Bear Glow", color=color.new(bearC, 66), linewidth=10, style=plot.style_linebr)

barCol = trendDir == 1 ? color.new(bullC, pvmBullSupport ? 48 : 65) : trendDir == -1 ? color.new(bearC, pvmBearSupport ? 48 : 65) : na
barcolor(showBars ? barCol : na)

//━━━━━━━━━━━━━━━━ BUY / SELL SIGNALS ACTIVE
plotshape(showSignals and newBuy, title="BUY", style=shape.labelup, location=location.belowbar, color=bullC, textcolor=color.black, text="BUY", size=size.small)
plotshape(showSignals and newSell, title="SELL", style=shape.labeldown, location=location.abovebar, color=bearC, textcolor=color.white, text="SELL", size=size.small)

//━━━━━━━━━━━━━━━━ POWER STAR
var label avgStar = na

if barstate.islast and showStar and not na(trendLine)
    label.delete(avgStar)
    starText = "✪\n" + t_power() + " " + str.tostring(powerPct, "#.0") + "\n" + powerStateTxt
    avgStar := label.new(bar_index, trendLine, starText, xloc=xloc.bar_index, style=label.style_label_center, color=color.new(color.black, 100), textcolor=powerStateCol, size=size.normal)

//━━━━━━━━━━━━━━━━ POWER BOX
var label badge = na

if barstate.islast and showBadge
    label.delete(badge)

    edgeTxt = powerEdge >= 0 ? "+" + str.tostring(powerEdge, "#.0") : str.tostring(powerEdge, "#.0")

    badgeTxt =
         t_power() + "  " + str.tostring(powerPct, "#.0") + "\n" +
         "Status  " + powerStateTxt + "\n" +
         t_avg() + "  " + str.tostring(avgPower, "#.0") + "\n" +
         "Diff  " + edgeTxt

    badgeY = trendDir == 1 ? low - atr : high + atr

    badge := label.new(bar_index + 5, badgeY, badgeTxt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(powerStateCol, 0), textcolor=color.black, size=size.normal)

//━━━━━━━━━━━━━━━━ PANEL
var table pan = table.new(position.top_right, 2, 7, border_width=1)

if showPanel and barstate.islast
    trendTxt = trendDir == 1 ? "BULL" : trendDir == -1 ? "BEAR" : "WAIT"
    trendCol = trendDir == 1 ? bullC : trendDir == -1 ? bearC : midC

    mtfTxt = cascadeBull ? "3/3 BULL" : cascadeBear ? "3/3 BEAR" : "MIXED"
    mtfCol = cascadeBull ? bullC : cascadeBear ? bearC : goldC

    lineTxt = strongTrend ? "STRONG" : mediumTrend ? "MEDIUM" : "WEAK"
    lineTxtCol = strongTrend ? goldC : mediumTrend ? trendCol : midC

    pvmTxt = directionalPvm >= 75 ? "PVM HIGH" : directionalPvm >= 60 ? "PVM OK" : directionalPvm < 45 ? "PVM LOW" : "PVM MID"
    pvmCol = directionalPvm >= 75 ? goldC : directionalPvm >= 60 ? trendCol : midC

    table.cell(pan, 0, 0, "ATS", text_color=color.white, bgcolor=color.black)
    table.cell(pan, 1, 0, "POWER FIX", text_color=powerStateCol, bgcolor=color.black)

    table.cell(pan, 0, 1, t_trend(), text_color=color.white)
    table.cell(pan, 1, 1, trendTxt, text_color=trendCol)

    table.cell(pan, 0, 2, t_power(), text_color=color.white)
    table.cell(pan, 1, 2, str.tostring(powerPct, "#.0") + "% / " + powerStateTxt, text_color=powerStateCol)

    table.cell(pan, 0, 3, t_avg(), text_color=color.white)
    table.cell(pan, 1, 3, str.tostring(avgPower, "#.0") + "%", text_color=midC)

    table.cell(pan, 0, 4, "MTF", text_color=color.white)
    table.cell(pan, 1, 4, mtfTxt, text_color=mtfCol)

    table.cell(pan, 0, 5, t_line(), text_color=color.white)
    table.cell(pan, 1, 5, lineTxt, text_color=lineTxtCol)

    table.cell(pan, 0, 6, "PVM", text_color=color.white)
    table.cell(pan, 1, 6, pvmTxt, text_color=pvmCol)

//━━━━━━━━━━━━━━━━ ALERTS
alertcondition(newBuy, "ATS BUY", "ATS Power Line BUY")
alertcondition(newSell, "ATS SELL", "ATS Power Line SELL")
alertcondition(powerStrongBull, "ATS STRONG POWER", "ATS Power is strong.")
alertcondition(powerBull, "ATS BULL POWER", "ATS Power is bullish.")
````
