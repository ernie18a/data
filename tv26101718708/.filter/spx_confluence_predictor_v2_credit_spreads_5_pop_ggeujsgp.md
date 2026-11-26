# SPX Confluence Predictor v2  Credit Spreads 5 POP

- url: https://www.tradingview.com/script/GGEuJsgP-SPX-Confluence-Predictor-v2-Credit-Spreads-5-POP/
- type: indicator
- pine_id: PUB;b27d9f66791f447fb3bd6e0b8fb34a73
- version: 1.0

## Description

It's a confluence engine for SPX intraday options. It reads several independent market signals, blends them into a single directional bias, and then translates that bias into a concrete $5-wide credit-spread recommendation (which structure, which strikes, and the probability of profit) on 5- or 15-minute charts.
Where it runs. It must be applied to ES1! (E-mini futures) or SPY, not the SPX cash index, because VWAP, CVD, and MFI all need real volume and the index has none. The NYSE internals ([symbol="USI:TICK"]USI:TICK[/symbol], [symbol="USI:ADD"]USI:ADD[/symbol], [symbol="USI:VOLD"]USI:VOLD[/symbol]) and the VIX are pulled in separately via request.security, so they work regardless of the chart symbol.
How it reads direction. Eight components each produce a sub-score from −1 (bearish) to +1 (bullish): price location relative to VWAP plus VWAP slope; the smoothed TICKlevel;netup−volumeminusdown−volume(TICK level; net up-volume minus down-volume (
TICKlevel;netup−volumeminusdown−volume(VOLD); advance/decline breadth ([symbol="USI:ADD"]USI:ADD[/symbol]); cumulative volume delta (aggressive buying vs. selling); the MACD histogram; the Money Flow Index; and a Connors RSI(2) mean-reversion read that only contributes when the VIX is below the threshold (your "mean-reversion regime"). Each component is weighted, and the weighted average becomes a master Score between −1 and +1. Above +0.30 is bullish, below −0.30 is bearish, and in between is neutral/range.
How it picks the trade. The bias is inverted into a premium-selling structure: a bullish score points to a Put Credit Spread (Bull Put) sold below the market, a bearish score points to a Call Credit Spread (Bear Call) sold above it, and a neutral score points to a synthetic Iron Condor (both verticals at once). The short strike is placed a buffer away from price (default 1× ATR), rounded to the nearest $5, with the long leg exactly $5 further out.
Probability of profit (POP). For each spread it estimates the chance the trade finishes profitable using a normal-distribution model: it measures the distance from price to the short strike, divides by the expected move (σ), and shifts that by the directional bias. If you enter the real expected move from your platform's straddle, the POP is accurate; otherwise it estimates σ from ATR. If you input the credit received, it also shows break-even and risk-to-reward.
The 70% filter. A side is only flagged as a valid setup when the bias supports it and its POP clears the minimum you set (default 70%). Below that, the chart labels and alerts stay silent, and the structure line reads "ESPERAR — POP < 70%." The table marks each side with ✓ when it qualifies and ✗<min when it doesn't.
The two "probability" numbers — the key distinction. The Confidence figure just measures how aligned the eight components are right now; it's a heuristic, not a real probability. The Realized Survival figure is the honest one: every filtered signal is checked N bars later to see whether price stayed on the safe side of the short strike, giving you a measured, live hit-rate of the actual filtered trades. That's the number to trust when calibrating whether the 70% setting is realistic.
What you see. VWAP and its ±1σ/±2σ bands plot on price; the background tints green or red by bias; labels print on qualifying signals; alerts can fire on them; and a table summarizes bias, score, confidence, realized survival, VIX regime, the recommended structure, both spreads' strikes/POP/R:R, and each component's contribution.
One caveat worth keeping in the explanation: the POP model assumes European-style settlement at the close (correct for SPX), so it doesn't account for price touching a strike intraday if you exit early, and it excludes commissions and slippage. It's a confluence-reading tool, not an execution system — final strikes, credit, and sizing are confirmed in your broker.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════
//  SPX CONFLUENCE PREDICTOR  v2  —  CREDIT SPREADS
//  Dirección · Estructura ($5-wide) · Strikes · POP (prob. de ganancia)
// ────────────────────────────────────────────────────────────────────────
//  Sesgo ALCISTA  → PUT CREDIT SPREAD  (Bull Put,  vendes abajo)
//  Sesgo BAJISTA  → CALL CREDIT SPREAD (Bear Call, vendes arriba)
//  NEUTRAL/RANGO  → IRON CONDOR sintético (ambos verticales $5)
//
//  ⚠ Aplicar sobre ES1! o SPY (NO el índice SPX): VWAP/CVD/MFI requieren
//    volumen. Internos ($TICK/$ADD/$VOLD) y VIX llegan por request.security.
//  ⚠ Para una POP precisa, ingresa el EXPECTED MOVE de tu vencimiento
//    (precio del straddle de tu plataforma) en el grupo "Spreads".
//  Herramienta de análisis — no es asesoría ni garantía de resultado.
// ════════════════════════════════════════════════════════════════════════
indicator("SPX Confluence Predictor v2 — Credit Spreads $5 · POP", shorttitle="SPX CS $5", overlay=true, max_labels_count=500, max_lines_count=100)

// ============================ ENTRADAS ============================
grpD = "▣ Datos externos (internos NYSE / VIX)"
useTick = input.bool(true,  "Usar $TICK",            group=grpD)
tickSym = input.symbol("USI:TICK", "Símbolo TICK",   group=grpD)
useAdd  = input.bool(true,  "Usar $ADD",             group=grpD)
addSym  = input.symbol("USI:ADD",  "Símbolo ADD",    group=grpD)
useVold = input.bool(true,  "Usar $VOLD (UVOL-DVOL)",group=grpD)
uvolSym = input.symbol("USI:UVOL", "Símbolo UVOL",   group=grpD)
dvolSym = input.symbol("USI:DVOL", "Símbolo DVOL",   group=grpD)
useVix  = input.bool(true,  "Usar VIX (régimen)",    group=grpD)
vixSym  = input.symbol("CBOE:VIX", "Símbolo VIX",    group=grpD)
vixThr  = input.float(20.0, "VIX umbral mean-reversion", step=0.5, group=grpD)

grpW = "⚖ Pesos de cada componente"
w_vwap = input.float(1.4, "VWAP (ubicación+pendiente)", step=0.1, group=grpW)
w_tick = input.float(1.2, "$TICK",                      step=0.1, group=grpW)
w_vold = input.float(1.0, "$VOLD",                      step=0.1, group=grpW)
w_add  = input.float(0.8, "$ADD",                       step=0.1, group=grpW)
w_cvd  = input.float(1.1, "CVD / Delta",                step=0.1, group=grpW)
w_macd = input.float(1.0, "MACD histograma",            step=0.1, group=grpW)
w_mfi  = input.float(0.7, "MFI",                        step=0.1, group=grpW)
w_rsi  = input.float(0.9, "RSI(2) Connors (mean-rev)",  step=0.1, group=grpW)

grpS = "💵 Spreads $5-wide"
sigThr   = input.float(0.30, "Umbral de señal (|score| 0-1)", step=0.05, group=grpS)
emPts    = input.float(0.0,  "Expected Move del vencimiento (pts) · 0=auto ATR", step=0.5, group=grpS)
horizonB = input.int(78,     "Barras hasta cierre/venc. (auto ATR)", minval=1, group=grpS)
bufMode  = input.string("ATR (x)", "Distancia al strike corto", options=["ATR (x)","Puntos"], group=grpS)
bufATR   = input.float(1.0,  "  Buffer en ATR", step=0.1, group=grpS)
bufPts   = input.float(25.0, "  Buffer en puntos", step=1.0, group=grpS)
driftK   = input.float(0.40, "Sesgo direccional en POP (0=neutro)", step=0.05, group=grpS)
minPOP   = input.float(70.0, "POP mínima para mostrar señal (%)", minval=0.0, maxval=99.0, step=1.0, group=grpS)
pcsCr    = input.float(0.0,  "Crédito Bull Put (pts) · 0=oculta R:R", step=0.05, group=grpS)
ccsCr    = input.float(0.0,  "Crédito Bear Call (pts) · 0=oculta R:R", step=0.05, group=grpS)

grpT = "🎯 Otros / Forward test"
atrLen  = input.int(14, "ATR periodo", group=grpT)
useFwd  = input.bool(true, "Medir supervivencia real del spread", group=grpT)
fwdBars = input.int(8, "Barras a futuro a evaluar", minval=1, group=grpT)

grpV = "🎨 Visual"
showLbl   = input.bool(true, "Etiquetas de spread en señales", group=grpV)
showBands = input.bool(true, "Mostrar bandas VWAP",           group=grpV)
tblPos    = input.string("top_right", "Posición tabla", options=["top_right","top_left","bottom_right","bottom_left"], group=grpV)

// ============================ COLORES ============================
cBuy = color.rgb(38,208,124)
cSell= color.rgb(255,92,108)
cNeu = color.rgb(138,151,168)
cBg  = color.rgb(18,24,33)
cTxt = color.rgb(230,236,243)
cAcc = color.rgb(55,224,166)
cGold= color.rgb(245,185,66)

// ============================ HELPERS ============================
f_clamp(x) => math.max(-1.0, math.min(1.0, x))
f_z(src, len) =>
    m  = ta.sma(src, len)
    sd = ta.stdev(src, len)
    na(sd) or sd == 0 ? 0.0 : (src - m) / sd
f_floor5(x) => math.floor(x / 5.0) * 5.0
f_ceil5(x)  => math.ceil(x / 5.0) * 5.0
// CDF normal estándar (aprox. Zelen & Severo, ~7 decimales)
f_ncdf(x) =>
    t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    d = 0.3989422804014327 * math.exp(-x * x / 2.0)
    p = d * t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    x > 0 ? 1.0 - p : p

// ============================ DATOS ============================
volOk = not na(volume) and volume > 0

anchor = timeframe.change("D")
[vwapV,  vU1, vL1] = ta.vwap(hlc3, anchor, 1.0)
[vwapV2, vU2, vL2] = ta.vwap(hlc3, anchor, 2.0)

tickVal = request.security(tickSym, timeframe.period, close)
addVal  = request.security(addSym,  timeframe.period, close)
uvolVal = request.security(uvolSym, timeframe.period, close)
dvolVal = request.security(dvolSym, timeframe.period, close)
vixVal  = request.security(vixSym,  timeframe.period, close)
netVold = nz(uvolVal) - nz(dvolVal)

var float cvd = 0.0
if anchor
    cvd := 0.0
barDelta = volOk ? (close > open ? volume : close < open ? -volume : 0.0) : 0.0
cvd := cvd + barDelta

[macdLine, macdSig, macdHist] = ta.macd(close, 12, 26, 9)
rsi2 = ta.rsi(close, 2)
mfiV = volOk ? ta.mfi(hlc3, 14) : na
atr  = ta.atr(atrLen)

lowVol = useVix and not na(vixVal) ? vixVal < vixThr : true

// ============================ SCORES ============================
used_vwap = not na(vwapV)
loc   = close > vwapV ? 1.0 : close < vwapV ? -1.0 : 0.0
slope = vwapV > vwapV[1] ? 0.35 : vwapV < vwapV[1] ? -0.35 : 0.0
s_vwap = used_vwap ? f_clamp(0.75 * loc + slope) : 0.0

used_tick = useTick and not na(tickVal)
s_tick = used_tick ? f_clamp(ta.ema(tickVal, 5) / 600.0) : 0.0

used_vold = useVold and not na(uvolVal) and not na(dvolVal)
s_vold = used_vold ? f_clamp(f_z(netVold, 50) / 2.0) : 0.0

used_add = useAdd and not na(addVal)
s_add = used_add ? f_clamp(addVal / 1500.0) : 0.0

used_cvd = volOk
s_cvd = used_cvd ? f_clamp(f_z(cvd - cvd[5], 50) / 2.0) : 0.0

used_macd = not na(macdHist)
s_macd = used_macd ? f_clamp(macdHist / (atr * 0.5)) : 0.0

used_mfi = volOk and not na(mfiV)
s_mfi = used_mfi ? f_clamp((mfiV - 50.0) / 30.0) : 0.0

used_rsi = lowVol
s_rsi = 0.0
if used_rsi
    s_rsi := rsi2 < 10 ? 1.0 : rsi2 > 90 ? -1.0 : rsi2 < 30 ? 0.4 : rsi2 > 70 ? -0.4 : 0.0

s_vwap := nz(s_vwap)
s_tick := nz(s_tick)
s_vold := nz(s_vold)
s_add  := nz(s_add)
s_cvd  := nz(s_cvd)
s_macd := nz(s_macd)
s_mfi  := nz(s_mfi)
s_rsi  := nz(s_rsi)

num = w_vwap*s_vwap*(used_vwap?1:0) + w_tick*s_tick*(used_tick?1:0) + w_vold*s_vold*(used_vold?1:0) + w_add*s_add*(used_add?1:0) + w_cvd*s_cvd*(used_cvd?1:0) + w_macd*s_macd*(used_macd?1:0) + w_mfi*s_mfi*(used_mfi?1:0) + w_rsi*s_rsi*(used_rsi?1:0)
den = w_vwap*(used_vwap?1:0) + w_tick*(used_tick?1:0) + w_vold*(used_vold?1:0) + w_add*(used_add?1:0) + w_cvd*(used_cvd?1:0) + w_macd*(used_macd?1:0) + w_mfi*(used_mfi?1:0) + w_rsi*(used_rsi?1:0)
score = den > 0 ? num / den : 0.0

// ============================ SESGO / ESTRUCTURA ============================
isBull  = score > 0
biasTxt = score > 0.6 ? "ALCISTA FUERTE" : score > sigThr ? "ALCISTA" : score > -sigThr ? "NEUTRAL / RANGO" : score > -0.6 ? "BAJISTA" : "BAJISTA FUERTE"
biasCol = score > sigThr ? cBuy : score < -sigThr ? cSell : cNeu
conf = 50.0 + math.min(45.0, math.abs(score) * 55.0)

// ============================ STRIKES $5-WIDE ============================
D = bufMode == "ATR (x)" ? bufATR * atr : bufPts
kpShort = f_floor5(close - D)   // venta PUT  (estructura alcista)
kpLong  = kpShort - 5.0         // compra PUT
kcShort = f_ceil5(close + D)    // venta CALL (estructura bajista)
kcLong  = kcShort + 5.0         // compra CALL

// ============================ POP (prob. de ganancia) ============================
sigma = emPts > 0 ? emPts : atr * math.sqrt(math.max(1, horizonB))
sigma := math.max(sigma, 0.0001)
drift = score * driftK * sigma
popPut  = f_ncdf((close + drift - kpShort) / sigma)   // P(cierre > put corto)
popCall = f_ncdf((kcShort - close - drift) / sigma)   // P(cierre < call corto)
popPutPct  = popPut  * 100.0
popCallPct = popCall * 100.0

// R:R y break-even (si se ingresa crédito)
pcsBE = kpShort - pcsCr
ccsBE = kcShort + ccsCr
pcsRR = pcsCr > 0 ? (5.0 - pcsCr) / pcsCr : na
ccsRR = ccsCr > 0 ? (5.0 - ccsCr) / ccsCr : na

// relevancia por sesgo
pcsOn = score > -sigThr   // alcista o neutral
ccsOn = score <  sigThr   // bajista o neutral

// ============================ FILTRO POP MÍNIMA ============================
// Un lado solo es válido si está habilitado por el sesgo Y su POP supera el mínimo
pcsQual = pcsOn and popPutPct  >= minPOP
ccsQual = ccsOn and popCallPct >= minPOP

// Estructura recomendada (ya filtrada por POP)
structTxt = pcsQual and ccsQual ? "IRON CONDOR sintético" : pcsQual ? "PUT CREDIT SPREAD (Bull Put)" : ccsQual ? "CALL CREDIT SPREAD (Bear Call)" : "ESPERAR — POP < " + str.tostring(minPOP, "#") + "%"
structCol = pcsQual and ccsQual ? cGold : pcsQual ? cBuy : ccsQual ? cSell : cNeu

// ============================ FORWARD TEST: supervivencia del spread ============================
var int[]   pBar = array.new_int()
var int[]   pDir = array.new_int()
var float[] pStr = array.new_float()
var int wins = 0
var int tot  = 0

newBull = ta.crossover(score,  sigThr)
newBear = ta.crossunder(score, -sigThr)
// Señales filtradas por POP mínima (las que realmente operarías)
sigBull = newBull and popPutPct  >= minPOP
sigBear = newBear and popCallPct >= minPOP

if useFwd and barstate.isconfirmed
    if sigBull
        array.push(pBar, bar_index)
        array.push(pDir, 1)
        array.push(pStr, kpShort)
    if sigBear
        array.push(pBar, bar_index)
        array.push(pDir, -1)
        array.push(pStr, kcShort)
    while array.size(pBar) > 0 and (bar_index - array.get(pBar, 0) >= fwdBars)
        d0 = array.shift(pDir)
        k0 = array.shift(pStr)
        array.shift(pBar)
        survived = d0 == 1 ? close > k0 : close < k0
        tot := tot + 1
        if survived
            wins := wins + 1
realAcc = tot > 0 ? wins / tot * 100.0 : na

// ============================ PLOTS ============================
plot(used_vwap ? vwapV : na, "VWAP", color=color.new(cTxt, 0), linewidth=2)
plot(showBands and used_vwap ? vU1 : na, "VWAP +1σ", color=color.new(cNeu, 40))
plot(showBands and used_vwap ? vL1 : na, "VWAP -1σ", color=color.new(cNeu, 40))
plot(showBands and used_vwap ? vU2 : na, "VWAP +2σ", color=color.new(cNeu, 70))
plot(showBands and used_vwap ? vL2 : na, "VWAP -2σ", color=color.new(cNeu, 70))
bgcolor(score > sigThr ? color.new(cBuy, 90) : score < -sigThr ? color.new(cSell, 90) : na, title="Fondo sesgo")

if showLbl and sigBull and barstate.isconfirmed
    label.new(bar_index, low, "BULL PUT\nVende " + str.tostring(kpShort, "#") + " / Compra " + str.tostring(kpLong, "#") + "\nPOP " + str.tostring(math.round(popPutPct)) + "%", yloc=yloc.belowbar, style=label.style_label_up, color=color.new(cBuy, 0), textcolor=color.white, size=size.small)
if showLbl and sigBear and barstate.isconfirmed
    label.new(bar_index, high, "BEAR CALL\nVende " + str.tostring(kcShort, "#") + " / Compra " + str.tostring(kcLong, "#") + "\nPOP " + str.tostring(math.round(popCallPct)) + "%", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(cSell, 0), textcolor=color.white, size=size.small)

alertcondition(sigBull, "PUT CREDIT SPREAD (POP OK)", "SPX: señal PUT CREDIT SPREAD con POP >= mínimo")
alertcondition(sigBear, "CALL CREDIT SPREAD (POP OK)", "SPX: señal CALL CREDIT SPREAD con POP >= mínimo")

// ============================ TABLA ============================
posMap = tblPos == "top_left" ? position.top_left : tblPos == "bottom_right" ? position.bottom_right : tblPos == "bottom_left" ? position.bottom_left : position.top_right
var table tb = table.new(posMap, 2, 25, border_width=1, border_color=color.new(cNeu, 60))

f_kv(row, k, v, vcol) =>
    table.cell(tb, 0, row, k, text_size=size.small, text_color=cNeu, bgcolor=cBg, text_halign=text.align_left)
    table.cell(tb, 1, row, v, text_size=size.small, text_color=vcol, bgcolor=cBg, text_halign=text.align_right)

f_hdr(row, txt, col) =>
    table.cell(tb, 0, row, txt, text_size=size.small, text_color=col, bgcolor=cBg, text_halign=text.align_left)
    table.cell(tb, 1, row, "", bgcolor=cBg)

f_comp(row, name, sc, used) =>
    table.cell(tb, 0, row, name, text_size=size.small, text_color=cTxt, bgcolor=cBg, text_halign=text.align_left)
    txt = not used ? "N/A" : sc > 0.05 ? "▲ " + str.tostring(sc, "#.00") : sc < -0.05 ? "▼ " + str.tostring(sc, "#.00") : "•  0.00"
    col = not used ? cNeu : sc > 0.05 ? cBuy : sc < -0.05 ? cSell : cNeu
    table.cell(tb, 1, row, txt, text_size=size.small, text_color=color.white, bgcolor=color.new(col, 72), text_halign=text.align_right)

if barstate.islast
    table.cell(tb, 0, 0, "⚠ DATA", text_size=size.small, text_color=cGold, bgcolor=cBg, text_halign=text.align_left)
    table.cell(tb, 1, 0, volOk ? "OK" : "Usar ES1!/SPY", text_size=size.small, text_color=volOk ? cAcc : cSell, bgcolor=cBg, text_halign=text.align_right)
    f_kv(1, "SESGO", biasTxt, biasCol)
    f_kv(2, "Score (-1..+1)", str.tostring(score, "#.00"), cTxt)
    f_kv(3, "Confianza confluencia", str.tostring(math.round(conf)) + "%", cGold)
    f_kv(4, "Superv. real (" + str.tostring(fwdBars) + "b)", na(realAcc) ? "—" : str.tostring(math.round(realAcc)) + "% (n=" + str.tostring(tot) + ")", cAcc)
    f_kv(5, "Régimen VIX", (na(vixVal) ? "—" : str.tostring(vixVal, "#.0")) + (lowVol ? "  MEAN-REV" : "  DE-RISK"), lowVol ? cBuy : cSell)
    f_kv(6, "▶ ESTRUCTURA", structTxt, structCol)
    // PUT CREDIT (alcista)
    f_hdr(7, "── PUT CREDIT SPREAD (alcista)", pcsOn ? cBuy : cNeu)
    f_kv(8, "  Vende / Compra Put", str.tostring(kpShort, "#") + " / " + str.tostring(kpLong, "#"), pcsOn ? cTxt : cNeu)
    f_kv(9, "  POP", str.tostring(math.round(popPutPct)) + "%" + (pcsQual ? "  ✓" : pcsOn ? "  ✗<min" : ""), pcsQual ? cBuy : cNeu)
    f_kv(10, "  BE / R:R", pcsCr > 0 ? str.tostring(pcsBE, "#") + "  /  " + str.tostring(pcsRR, "#.0") + ":1" : "ingresa crédito", pcsCr > 0 ? cTxt : cNeu)
    // CALL CREDIT (bajista)
    f_hdr(11, "── CALL CREDIT SPREAD (bajista)", ccsOn ? cSell : cNeu)
    f_kv(12, "  Vende / Compra Call", str.tostring(kcShort, "#") + " / " + str.tostring(kcLong, "#"), ccsOn ? cTxt : cNeu)
    f_kv(13, "  POP", str.tostring(math.round(popCallPct)) + "%" + (ccsQual ? "  ✓" : ccsOn ? "  ✗<min" : ""), ccsQual ? cSell : cNeu)
    f_kv(14, "  BE / R:R", ccsCr > 0 ? str.tostring(ccsBE, "#") + "  /  " + str.tostring(ccsRR, "#.0") + ":1" : "ingresa crédito", ccsCr > 0 ? cTxt : cNeu)
    f_kv(15, "Exp.move σ · POPmín", str.tostring(sigma, "#.0") + "pts" + (emPts > 0 ? "[man]" : "[auto]") + " · " + str.tostring(minPOP, "#") + "%", cNeu)
    // Componentes
    f_hdr(16, "── COMPONENTES", cAcc)
    f_comp(17, "VWAP",         s_vwap, used_vwap)
    f_comp(18, "$TICK",        s_tick, used_tick)
    f_comp(19, "$VOLD",        s_vold, used_vold)
    f_comp(20, "$ADD",         s_add,  used_add)
    f_comp(21, "CVD/Delta",    s_cvd,  used_cvd)
    f_comp(22, "MACD hist",    s_macd, used_macd)
    f_comp(23, "MFI",          s_mfi,  used_mfi)
    f_comp(24, "RSI(2) m-rev", s_rsi,  used_rsi)
````
