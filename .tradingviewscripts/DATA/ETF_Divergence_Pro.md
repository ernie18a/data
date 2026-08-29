<!-- tradingview-pine-id: PUB;b25c53b5f55a4cd0ba61a9cafbfbfcdd -->
<!-- tradingviewscripts-format: 1 -->
# ETF Divergence Pro

Source: https://www.tradingview.com/script/yg8f9jcT/

## Description

ETF Divergence Pro flags moments when US Spot Bitcoin ETF flows stop confirming BTC price action. 

It isolates the portion of flow that price movement does not explain, via rolling regression, and reports it as a standardised divergence score. Flows derive from ETF assets under management adjusted for BTC return — an approximation of net creations and redemptions, not trading volume. Signals must persist across sessions and respect a cooldown, so they are rare by design. 
Buy signals are gated by a long-term trend filter, because institutional assets decline more slowly than price in drawdowns. The lower pane plots daily flows, cumulative flows and the score on a shared scale; arrows print at bar close, no repainting. 

Two caveats: flow data is estimated from AUM rather than official figures, and Spot ETFs only date from January 2024.

all the best, 
and stay green

---

## Source Code

````pine
//@version=6
indicator("ETF Divergence Pro", "ETF DIV PRO", overlay = false, max_labels_count = 500)

// ===== 1 . SOURCES =====
gSrc = "1 - Sources de flux"
srcMode = input.string("AUM", "Methode de calcul", options = ["AUM", "Volume", "Seeds"], group = gSrc)
seedSym = input.string("", "Symbole Pine Seeds", group = gSrc)
useSeed = srcMode == "Seeds"
useAUM = srcMode == "AUM"

e01 = input.bool(true, "IBIT", inline = "a1", group = gSrc)
s01 = input.symbol("NASDAQ:IBIT", "", inline = "a1", group = gSrc)
e02 = input.bool(true, "FBTC", inline = "a2", group = gSrc)
s02 = input.symbol("CBOE:FBTC", "", inline = "a2", group = gSrc)
e03 = input.bool(true, "ARKB", inline = "a3", group = gSrc)
s03 = input.symbol("CBOE:ARKB", "", inline = "a3", group = gSrc)
e04 = input.bool(true, "BITB", inline = "a4", group = gSrc)
s04 = input.symbol("AMEX:BITB", "", inline = "a4", group = gSrc)
e05 = input.bool(true, "HODL", inline = "a5", group = gSrc)
s05 = input.symbol("CBOE:HODL", "", inline = "a5", group = gSrc)
e06 = input.bool(true, "BRRR", inline = "a6", group = gSrc)
s06 = input.symbol("NASDAQ:BRRR", "", inline = "a6", group = gSrc)
e07 = input.bool(true, "EZBC", inline = "a7", group = gSrc)
s07 = input.symbol("CBOE:EZBC", "", inline = "a7", group = gSrc)
e08 = input.bool(true, "BTCO", inline = "a8", group = gSrc)
s08 = input.symbol("CBOE:BTCO", "", inline = "a8", group = gSrc)
e09 = input.bool(false, "GBTC", inline = "a9", group = gSrc)
s09 = input.symbol("AMEX:GBTC", "", inline = "a9", group = gSrc)
e10 = input.bool(false, "BTC mini", inline = "a10", group = gSrc)
s10 = input.symbol("AMEX:BTC", "", inline = "a10", group = gSrc)

// ===== 2 . MODELE =====
gMod = "2 - Modele"
lenStat = input.int(60, "Fenetre statistique", minval = 20, maxval = 250, group = gMod)
persist = input.int(2, "Persistance", minval = 1, maxval = 15, group = gMod)
thr = input.float(1.5, "Seuil de score", minval = 0.5, step = 0.1, group = gMod)

// ===== 3 . FILTRES =====
gFlt = "3 - Filtres"
useTrend = input.bool(true, "Achats seulement si marche haussier", group = gFlt)
trendLen = input.int(200, "Moyenne de tendance en jours", minval = 20, maxval = 400, group = gFlt)
kMove = input.float(0.0, "Mouvement prix minimal", minval = 0.0, step = 0.1, group = gFlt)
minFlowUSD = input.float(0, "Flux minimal en millions", minval = 0, step = 25, group = gFlt)
cooldown = input.int(10, "Seances entre deux signaux", minval = 0, group = gFlt)
confirmClose = input.bool(true, "Signal sur bougie cloturee", group = gFlt)

// ===== 4 . AFFICHAGE =====
gDsp = "4 - Affichage"
normalise = input.bool(true, "Normaliser l affichage", group = gDsp)
normLen = input.int(120, "Fenetre de normalisation", minval = 30, maxval = 500, group = gDsp)
showFlows = input.bool(true, "Histogramme des flux", group = gDsp)
showCum = input.bool(true, "Flux cumules", group = gDsp)
showScore = input.bool(true, "Score de divergence", group = gDsp)
showLabels = input.bool(true, "Score sur le signal", group = gDsp)
tintBars = input.bool(false, "Colorer la bougie", group = gDsp)
colBuy = input.color(color.rgb(0, 200, 90), "Couleur achat", group = gDsp)
colSell = input.color(color.rgb(230, 40, 60), "Couleur allegement", group = gDsp)

// ===== FONCTIONS =====
f_flow(_sym, _on) =>
    float _v = request.security(_sym, timeframe.period, ((close - low) - (high - close)) / math.max(high - low, 0.0000001) * close * volume, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    _on ? nz(_v) : 0.0

f_flowAUM(_sym, _on, _btcRet) =>
    float _a = request.financial(_sym, "AUM", "D", ignore_invalid_symbol = true)
    float _d = na(_a) or na(_a[1]) ? 0.0 : (_a - _a[1]) - _a[1] * nz(_btcRet)
    _on ? nz(_d) : 0.0

f_time(_sym) =>
    request.security(_sym, timeframe.period, time, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

f_sumLast(_a, _k) =>
    float _s = 0.0
    int _n = array.size(_a)
    if _n > 0
        int _st = math.max(0, _n - _k)
        for _i = _st to _n - 1
            _s := _s + array.get(_a, _i)
    _s

f_norm(_src, _len) =>
    float _sd = ta.stdev(_src, _len)
    na(_sd) or _sd == 0 ? 0.0 : _src / _sd

// ===== AGREGATION =====
float btcRetSimple = nz(close / nz(close[1], close) - 1.0)

float proxyFlow = 0.0
proxyFlow := proxyFlow + f_flow(s01, e01)
proxyFlow := proxyFlow + f_flow(s02, e02)
proxyFlow := proxyFlow + f_flow(s03, e03)
proxyFlow := proxyFlow + f_flow(s04, e04)
proxyFlow := proxyFlow + f_flow(s05, e05)
proxyFlow := proxyFlow + f_flow(s06, e06)
proxyFlow := proxyFlow + f_flow(s07, e07)
proxyFlow := proxyFlow + f_flow(s08, e08)
proxyFlow := proxyFlow + f_flow(s09, e09)
proxyFlow := proxyFlow + f_flow(s10, e10)

float aumFlow = 0.0
aumFlow := aumFlow + f_flowAUM(s01, e01, btcRetSimple)
aumFlow := aumFlow + f_flowAUM(s02, e02, btcRetSimple)
aumFlow := aumFlow + f_flowAUM(s03, e03, btcRetSimple)
aumFlow := aumFlow + f_flowAUM(s04, e04, btcRetSimple)
aumFlow := aumFlow + f_flowAUM(s05, e05, btcRetSimple)
aumFlow := aumFlow + f_flowAUM(s06, e06, btcRetSimple)
aumFlow := aumFlow + f_flowAUM(s07, e07, btcRetSimple)
aumFlow := aumFlow + f_flowAUM(s08, e08, btcRetSimple)
aumFlow := aumFlow + f_flowAUM(s09, e09, btcRetSimple)
aumFlow := aumFlow + f_flowAUM(s10, e10, btcRetSimple)

float seedFlow = seedSym != "" ? request.security(seedSym, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true) : na
bool seedOn = useSeed and not na(seedFlow)
float netFlow = seedOn ? seedFlow : useAUM ? aumFlow : proxyFlow

float tSeed = seedSym != "" ? f_time(seedSym) : na
float tRef1 = f_time(s01)
float refT = seedOn ? tSeed : tRef1
bool isNew = not na(refT) and refT != nz(refT[1], 0)

// ===== FILTRE DE TENDANCE =====
float trendMA = ta.sma(close, trendLen)
bool bullMarket = not na(trendMA) and close > trendMA

// ===== MODELE RESIDUEL =====
var array<float> aFlow = array.new<float>()
var array<float> aRet = array.new<float>()
var array<float> aDiv = array.new<float>()
var float prevClose = na
var float divScore = na
var float cumScore = na
var float retWin = na
var float moveThr = na
var float rho = na
var int lastSig = na
int minObs = int(math.max(25.0, math.round(lenStat * 0.5)))

if isNew
    float r = na(prevClose) ? na : math.log(close / prevClose)
    prevClose := close
    if not na(r) and not na(netFlow)
        array.push(aFlow, netFlow)
        array.push(aRet, r)
        if array.size(aFlow) > lenStat
            array.shift(aFlow)
            array.shift(aRet)
        if array.size(aFlow) >= minObs
            float mF = array.avg(aFlow)
            float sF = math.max(array.stdev(aFlow), 0.0000000001)
            float mR = array.avg(aRet)
            float sR = math.max(array.stdev(aRet), 0.0000000001)
            rho := math.max(-0.95, math.min(0.95, array.covariance(aFlow, aRet) / (sF * sR)))
            float zF = (netFlow - mF) / sF
            float zR = (r - mR) / sR
            divScore := (zF - rho * zR) / math.sqrt(math.max(1 - rho * rho, 0.05))
            array.push(aDiv, divScore)
            if array.size(aDiv) > persist
                array.shift(aDiv)
            cumScore := f_sumLast(aDiv, persist) / math.sqrt(persist)
            retWin := f_sumLast(aRet, persist)
            moveThr := kMove * sR * math.sqrt(persist)

// ===== SIGNAUX =====
bool tfOK = timeframe.in_seconds(timeframe.period) >= 86400
bool ready = array.size(aDiv) >= persist and array.size(aFlow) >= minObs and not na(cumScore)
bool cool = na(lastSig) or (bar_index - lastSig) >= cooldown
bool flowOK = math.abs(netFlow) >= minFlowUSD * 1000000 or seedOn
bool conf = not confirmClose or barstate.isconfirmed
bool baseOK = isNew and tfOK and ready and cool and flowOK
bool trendOK = not useTrend or bullMarket
bool rawBuy = baseOK and trendOK and cumScore > thr and retWin < -moveThr
bool rawSell = baseOK and cumScore < -thr and retWin > moveThr
bool buySig = rawBuy and conf
bool sellSig = rawSell and conf

if buySig or sellSig
    lastSig := bar_index

// ===== AFFICHAGE =====
float strength = math.min(math.abs(nz(cumScore)) / math.max(thr, 0.1), 2.5)
int tr = int(math.max(0, 65 - 26 * strength))
color cB = color.new(colBuy, tr)
color cS = color.new(colSell, tr)

var float cumFlow = 0.0
if isNew and not na(netFlow)
    cumFlow := cumFlow + netFlow

float plotFlow = normalise ? f_norm(netFlow, normLen) : netFlow / 1000000
float plotCum = normalise ? f_norm(cumFlow - ta.sma(cumFlow, normLen), normLen) : cumFlow / 1000000

color colHist = netFlow >= 0 ? color.new(colBuy, 25) : color.new(colSell, 25)
plot(showFlows ? plotFlow : na, "Flux ETF quotidien", style = plot.style_columns, color = colHist)
plot(showCum ? plotCum : na, "Flux cumule", color = color.orange, linewidth = 2)
plot(showScore ? cumScore : na, "Score de divergence", color = color.aqua)
hline(0, "Zero", color = color.gray)
hline(thr, "Seuil haut", color = color.gray, linestyle = hline.style_dotted)
hline(-thr, "Seuil bas", color = color.gray, linestyle = hline.style_dotted)

plotshape(buySig, "Achat", shape.triangleup, location.belowbar, color = cB, size = size.small, force_overlay = true)
plotshape(sellSig, "Allegement", shape.triangledown, location.abovebar, color = cS, size = size.small, force_overlay = true)

if showLabels and buySig
    label.new(bar_index, low, "A " + str.tostring(cumScore, "#.00"), style = label.style_label_up, color = cB, textcolor = color.white, size = size.tiny, yloc = yloc.belowbar, force_overlay = true)

if showLabels and sellSig
    label.new(bar_index, high, "V " + str.tostring(cumScore, "#.00"), style = label.style_label_down, color = cS, textcolor = color.white, size = size.tiny, yloc = yloc.abovebar, force_overlay = true)

barcolor(tintBars and buySig ? cB : tintBars and sellSig ? cS : na)
plot(rho, "Correlation flux prix", display = display.data_window)

alertcondition(buySig, "ETF DIV PRO Achat", "Divergence haussiere flux ETF contre prix BTC")
alertcondition(sellSig, "ETF DIV PRO Allegement", "Divergence baissiere flux ETF contre prix BTC")
````
