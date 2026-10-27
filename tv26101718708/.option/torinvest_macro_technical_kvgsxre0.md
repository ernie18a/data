# TORINVEST - Macro Technical 

- url: https://www.tradingview.com/script/kVGSxRE0/
- type: indicator
- pine_id: PUB;db6a4b8556ec41c9b85e872ecb4c7965
- version: 1.0

## Description

[b]⚙️ COMMENT UTILISER TON INDICATEUR[/b]
🧭 1. LIRE LE RÉGIME (BASE)

➡️ Regime score

+0.25 → 🟢 RISK ON

< -0.25 → 🔴 RISK OFF
entre → 🟠 NEUTRE

👉 C’est ton point de départ, pas ton signal

⚖️ 2. IDENTIFIER QUI DOMINE
🟢 Risk On
Actions / BTC / Cuivre / Crédit
➡️ Appétit pour le risque
🔴 Risk Off
Dollar / Or / CHF / JPY
➡️ Peur / refuge

👉 Lecture clé :

Risk On > Risk Off → marché offensif
Risk Off > Risk On → marché défensif
Les deux forts → marché instable / piège
🧠 3. VALIDER LE CONTEXTE
🇺🇸 Macro US
Housing + Salaires
➡️ Santé économique US
📉 Rates
Taux + spreads + courbe
➡️ Pression monétaire globale
📊 Technique
RSI + CVD + MA
➡️ Timing réel de l’actif
🔍 4. LECTURE INTELLIGENTE
CAS 1 — ALIGNEMENT
Risk On ↑
Macro US ↑
Technique ↑

👉 ✅ Marché propre → opportunités fiables

CAS 2 — CONTRADICTION
Risk On ↑
Risk Off ↑

👉 ⚠️ Marché instable → pièges / fake moves

CAS 3 — FAIBLE STRUCTURE
Regime neutre
Scores proches de 0

👉 ❌ Pas d’avantage → attendre

🧨 5. ERREURS À ÉVITER

❌ Lire un seul indicateur
❌ Trader juste parce que “c’est vert”
❌ Ignorer les contradictions
❌ Ne pas adapter selon l’actif

🧠 6. UTILISATION PRO

👉 Ton indicateur sert à :

filtrer tes trades
comprendre le contexte
éviter les mauvais environnements

👉 Il ne sert PAS à :

donner un signal direct
remplacer ton Price Action
⚔️ 7. RÈGLE TORINVEST

👉 Le marché ne récompense pas les opinions,
il récompense l’alignement.

## Source Code

````pine
//@version=6
indicator("TORINVEST - Macro Technical Dashboard v2", shorttitle="TOR MacroTech v2", overlay=false, max_labels_count=500)

//====================================================
// INPUTS
//====================================================
groupMarket = "Actifs & FX"
symDxy     = input.symbol("TVC:DXY",         "Dollar Index", group=groupMarket)
symGold    = input.symbol("COMEX:GC1!",      "Or", group=groupMarket)
symOil     = input.symbol("NYMEX:CL1!",      "Pétrole", group=groupMarket)
symCopper  = input.symbol("COMEX:HG1!",      "Cuivre", group=groupMarket)
symUsdjpy  = input.symbol("OANDA:USDJPY",    "USDJPY", group=groupMarket)
symUsdchf  = input.symbol("OANDA:USDCHF",    "USDCHF", group=groupMarket)
symEurchf  = input.symbol("OANDA:EURCHF",    "EURCHF", group=groupMarket)
symBtc     = input.symbol("BINANCE:BTCUSDT", "BTCUSDT", group=groupMarket)
symSpx     = input.symbol("SP:SPX",          "S&P 500", group=groupMarket)
symAcwi    = input.symbol("AMEX:ACWI",       "MSCI World / ACWI", group=groupMarket)
symEem     = input.symbol("AMEX:EEM",        "MSCI EM / EEM", group=groupMarket)

groupRates = "Taux & Crédit"
symUS2Y    = input.symbol("FRED:DGS2",       "US 2Y", group=groupRates)
symUS5Y    = input.symbol("FRED:DGS5",       "US 5Y", group=groupRates)
symUS10Y   = input.symbol("FRED:DGS10",      "US 10Y", group=groupRates)
symDE10Y   = input.symbol("TVC:DE10Y",       "Bund 10Y", group=groupRates)
symJP10Y   = input.symbol("TVC:JP10Y",       "JGB 10Y", group=groupRates)
symCN10Y   = input.symbol("TVC:CN10Y",       "China 10Y", group=groupRates)
symHYG     = input.symbol("AMEX:HYG",        "HYG", group=groupRates)
symLQD     = input.symbol("AMEX:LQD",        "LQD", group=groupRates)
symFFR     = input.symbol("FRED:FEDFUNDS",   "Fed Funds Spot", group=groupRates)
symZQ      = input.symbol("CBOT:ZQ1!",       "Fed Funds Futures ZQ1!", group=groupRates)

groupMacro = "Macro US"
symHousing = input.symbol("FRED:HOUST",         "Housing Starts", group=groupMacro)
symPermit  = input.symbol("FRED:PERMIT",        "Building Permits", group=groupMacro)
symWages   = input.symbol("FRED:CES0500000003", "Average Hourly Earnings", group=groupMacro)

groupTech = "Technique"
anchorSym  = input.symbol("COMEX:GC1!", "Actif d'ancrage (RSI / MA / CVD)", group=groupTech)
rsiLen     = input.int(14, "RSI Length", minval=2, group=groupTech)
emaLen     = input.int(21, "EMA 21", minval=2, group=groupTech)
sma50Len   = input.int(50, "SMA 50", minval=2, group=groupTech)
sma100Len  = input.int(100, "SMA 100", minval=2, group=groupTech)
sma200Len  = input.int(200, "SMA 200", minval=2, group=groupTech)

groupDash = "Dashboard"
scoreLookback    = input.int(126, "Lookback normalisation", minval=20, group=groupDash)
showCoreScores   = input.bool(true, "Afficher scores principaux", group=groupDash)
showRateSpreads  = input.bool(true, "Afficher spreads de taux", group=groupDash)
showCurves       = input.bool(true, "Afficher courbes US", group=groupDash)
showCredit       = input.bool(true, "Afficher crédit HYG/LQD", group=groupDash)
showTechBlock    = input.bool(true, "Afficher bloc technique", group=groupDash)
showRawSeries    = input.bool(false, "Afficher séries brutes normalisées", group=groupDash)
showTable        = input.bool(true, "Afficher tableau dashboard", group=groupDash)
riskOnThreshold  = input.float(0.25, "Seuil Risk On", step=0.05, group=groupDash)
riskOffThreshold = input.float(-0.25, "Seuil Risk Off", step=0.05, group=groupDash)

groupColors = "Couleurs"
colRegime    = input.color(color.black, "Regime Score", group=groupColors)
colComposite = input.color(color.black, "Composite", group=groupColors)
colRiskOn    = input.color(color.new(color.green, 0), "Risk On", group=groupColors)
colRiskOff   = input.color(color.new(color.red, 0), "Risk Off", group=groupColors)
colMacroUS   = input.color(color.new(color.aqua, 0), "Macro US", group=groupColors)
colRates     = input.color(color.new(color.purple, 0), "Rates", group=groupColors)
colTech      = input.color(color.new(color.fuchsia, 0), "Technique", group=groupColors)
colUSDE      = input.color(color.new(color.blue, 0), "Spread US-DE", group=groupColors)
colUSJP      = input.color(color.new(color.navy, 0), "Spread US-JP", group=groupColors)
colUSCN      = input.color(color.new(color.orange, 0), "Spread US-CN", group=groupColors)
colDEJP      = input.color(color.new(color.teal, 0), "Spread DE-JP", group=groupColors)
colDECN      = input.color(color.new(color.maroon, 0), "Spread DE-CN", group=groupColors)
colCurve102  = input.color(color.new(color.gray, 0), "Courbe 10s2s", group=groupColors)
colCurve105  = input.color(color.new(color.silver, 0), "Courbe 10s5s", group=groupColors)
colCurve52   = input.color(color.new(color.yellow, 0), "Courbe 5s2s", group=groupColors)
colCredit    = input.color(color.new(color.green, 35), "HYG/LQD", group=groupColors)
colAnchorRSI = input.color(color.new(color.fuchsia, 30), "Anchor RSI Bias", group=groupColors)
colCVD       = input.color(color.new(color.gray, 0), "CVD Bias", group=groupColors)

//====================================================
// HELPERS
//====================================================
f_sec(_sym) =>
    request.security(_sym, timeframe.period, close, gaps=barmerge.gaps_off)

f_norm(_src, _len) =>
    _lo = ta.lowest(_src, _len)
    _hi = ta.highest(_src, _len)
    _rng = _hi - _lo
    _rng != 0 ? ((_src - _lo) / _rng) * 2.0 - 1.0 : 0.0

f_mom(_src) =>
    _src[1] != 0 ? ((_src / _src[1]) - 1.0) * 100.0 : 0.0

f_yoy(_src) =>
    _src[12] != 0 ? ((_src / _src[12]) - 1.0) * 100.0 : 0.0

f_txt(_v) =>
    str.tostring(_v, format.mintick)

f_bg(_v) =>
    _v > 0 ? color.new(color.green, 82) : _v < 0 ? color.new(color.red, 82) : color.new(color.orange, 82)

//====================================================
// DATA
//====================================================
dxy    = f_sec(symDxy)
gold   = f_sec(symGold)
oil    = f_sec(symOil)
copper = f_sec(symCopper)
usdjpy = f_sec(symUsdjpy)
usdchf = f_sec(symUsdchf)
eurchf = f_sec(symEurchf)
btc    = f_sec(symBtc)
spx    = f_sec(symSpx)
acwi   = f_sec(symAcwi)
eem    = f_sec(symEem)

us2y   = f_sec(symUS2Y)
us5y   = f_sec(symUS5Y)
us10y  = f_sec(symUS10Y)
de10y  = f_sec(symDE10Y)
jp10y  = f_sec(symJP10Y)
cn10y  = f_sec(symCN10Y)
hyg    = f_sec(symHYG)
lqd    = f_sec(symLQD)
ffr    = f_sec(symFFR)
zq     = f_sec(symZQ)

housing = f_sec(symHousing)
permit  = f_sec(symPermit)
wages   = f_sec(symWages)

wageMoM = f_mom(wages)
wageYoY = f_yoy(wages)

//====================================================
// TECH BLOCK ON ANCHOR SYMBOL
//====================================================
anchorClose  = request.security(anchorSym, timeframe.period, close, gaps=barmerge.gaps_off)
anchorRSI    = request.security(anchorSym, timeframe.period, ta.rsi(close, rsiLen), gaps=barmerge.gaps_off)
anchorEMA    = request.security(anchorSym, timeframe.period, ta.ema(close, emaLen), gaps=barmerge.gaps_off)
anchorSMA50  = request.security(anchorSym, timeframe.period, ta.sma(close, sma50Len), gaps=barmerge.gaps_off)
anchorSMA100 = request.security(anchorSym, timeframe.period, ta.sma(close, sma100Len), gaps=barmerge.gaps_off)
anchorSMA200 = request.security(anchorSym, timeframe.period, ta.sma(close, sma200Len), gaps=barmerge.gaps_off)

// CVD proxy compatible partout
anchorDelta = request.security(anchorSym, timeframe.period, close > close[1] ? volume : close < close[1] ? -volume : 0.0, gaps=barmerge.gaps_off)
anchorCVD   = ta.cum(anchorDelta)

//====================================================
// SPREADS / CURVES / RATIOS
//====================================================
spreadUSDE = us10y - de10y
spreadUSJP = us10y - jp10y
spreadUSCN = us10y - cn10y
spreadDEJP = de10y - jp10y
spreadDECN = de10y - cn10y

curve10s2s = us10y - us2y
curve10s5s = us10y - us5y
curve5s2s  = us5y - us2y

creditRatio = lqd != 0 ? hyg / lqd : na
ffrImplied  = 100.0 - zq

maBull = anchorClose > anchorEMA and anchorClose > anchorSMA50 and anchorClose > anchorSMA100 and anchorClose > anchorSMA200 and anchorSMA50 > anchorSMA100 and anchorSMA100 > anchorSMA200
maBear = anchorClose < anchorEMA and anchorClose < anchorSMA50 and anchorClose < anchorSMA100 and anchorClose < anchorSMA200 and anchorSMA50 < anchorSMA100 and anchorSMA100 < anchorSMA200

//====================================================
// NORMALISATION
//====================================================
nDxy        = f_norm(dxy, scoreLookback)
nGold       = f_norm(gold, scoreLookback)
nOil        = f_norm(oil, scoreLookback)
nCopper     = f_norm(copper, scoreLookback)
nUsdJpy     = f_norm(usdjpy, scoreLookback)
nUsdChf     = f_norm(usdchf, scoreLookback)
nEurChf     = f_norm(eurchf, scoreLookback)
nBtc        = f_norm(btc, scoreLookback)
nSpx        = f_norm(spx, scoreLookback)
nAcwi       = f_norm(acwi, scoreLookback)
nEem        = f_norm(eem, scoreLookback)

nUs2y       = f_norm(us2y, scoreLookback)
nUs5y       = f_norm(us5y, scoreLookback)
nUs10y      = f_norm(us10y, scoreLookback)
nSpreadUSDE = f_norm(spreadUSDE, scoreLookback)
nSpreadUSJP = f_norm(spreadUSJP, scoreLookback)
nSpreadUSCN = f_norm(spreadUSCN, scoreLookback)
nSpreadDEJP = f_norm(spreadDEJP, scoreLookback)
nSpreadDECN = f_norm(spreadDECN, scoreLookback)
nCurve102   = f_norm(curve10s2s, scoreLookback)
nCurve105   = f_norm(curve10s5s, scoreLookback)
nCurve52    = f_norm(curve5s2s, scoreLookback)
nCredit     = f_norm(creditRatio, scoreLookback)
nHousing    = f_norm(housing, scoreLookback)
nPermit     = f_norm(permit, scoreLookback)
nWageMoM    = f_norm(wageMoM, scoreLookback)
nWageYoY    = f_norm(wageYoY, scoreLookback)
nFFRSpot    = f_norm(ffr, scoreLookback)
nFFRImpl    = f_norm(ffrImplied, scoreLookback)
nCVD        = f_norm(anchorCVD, scoreLookback)
nAnchorRSI  = (anchorRSI - 50.0) / 50.0

//====================================================
// SCORES
//====================================================
riskOnScore  = (nSpx + nAcwi + nEem + nBtc + nCopper + nCredit) / 6.0
riskOffScore = (nDxy + nGold + nUsdJpy + nUsdChf) / 4.0
macroUSScore = (nHousing + nPermit + nWageMoM + nWageYoY) / 4.0
ratesScore   = (nUs2y + nUs5y + nUs10y + nSpreadUSDE + nSpreadUSJP + nSpreadUSCN + nSpreadDEJP + nSpreadDECN + nCurve102 + nCurve105 + nCurve52 + nFFRSpot + nFFRImpl) / 13.0

maScore   = maBull ? 1.0 : maBear ? -1.0 : 0.0
techScore = (nAnchorRSI + nCVD + maScore) / 3.0

compositeScore  = (riskOnScore - riskOffScore + macroUSScore + ratesScore + techScore) / 5.0
riskRegimeScore = (riskOnScore + macroUSScore + techScore - riskOffScore) / 4.0
riskRegime      = riskRegimeScore >= riskOnThreshold ? 1 : riskRegimeScore <= riskOffThreshold ? -1 : 0
riskRegimeText  = riskRegime == 1 ? "RISK ON" : riskRegime == -1 ? "RISK OFF" : "NEUTRE"
riskRegimeColor = riskRegime == 1 ? color.lime : riskRegime == -1 ? color.red : color.orange

//====================================================
// PLOTS
//====================================================
hline(0, "Neutral", color=color.gray)
hline(riskOnThreshold, "Seuil Risk On", color=color.new(color.green, 75))
hline(riskOffThreshold, "Seuil Risk Off", color=color.new(color.red, 75))

plot(showCoreScores ? riskRegimeScore : na, "REGIME SCORE", color=colRegime, linewidth=4)
plot(showCoreScores ? compositeScore : na, "COMPOSITE SCORE", color=colComposite, linewidth=3)
plot(showCoreScores ? riskOnScore : na, "RISK ON SCORE", color=colRiskOn, linewidth=2)
plot(showCoreScores ? riskOffScore : na, "RISK OFF SCORE", color=colRiskOff, linewidth=2)
plot(showCoreScores ? macroUSScore : na, "MACRO US SCORE", color=colMacroUS, linewidth=2)
plot(showCoreScores ? ratesScore : na, "RATES SCORE", color=colRates, linewidth=2)
plot(showCoreScores and showTechBlock ? techScore : na, "TECH SCORE", color=colTech, linewidth=2)

plot(showRateSpreads ? f_norm(spreadUSDE, scoreLookback) : na, "SPREAD US10Y-DE10Y", color=colUSDE, linewidth=2)
plot(showRateSpreads ? f_norm(spreadUSJP, scoreLookback) : na, "SPREAD US10Y-JP10Y", color=colUSJP, linewidth=2)
plot(showRateSpreads ? f_norm(spreadUSCN, scoreLookback) : na, "SPREAD US10Y-CN10Y", color=colUSCN, linewidth=2)
plot(showRateSpreads ? f_norm(spreadDEJP, scoreLookback) : na, "SPREAD DE10Y-JP10Y", color=colDEJP, linewidth=2)
plot(showRateSpreads ? f_norm(spreadDECN, scoreLookback) : na, "SPREAD DE10Y-CN10Y", color=colDECN, linewidth=2)

plot(showCurves ? nCurve102 : na, "US CURVE 10s2s", color=colCurve102, linewidth=2)
plot(showCurves ? nCurve105 : na, "US CURVE 10s5s", color=colCurve105, linewidth=2)
plot(showCurves ? nCurve52 : na, "US CURVE 5s2s", color=colCurve52, linewidth=2)

plot(showCredit ? nCredit : na, "CREDIT HYG/LQD", color=colCredit, linewidth=3)
plot(showTechBlock ? nAnchorRSI : na, "ANCHOR RSI BIAS", color=colAnchorRSI, linewidth=2)
plot(showTechBlock ? nCVD : na, "CVD BIAS", color=colCVD, linewidth=2)

plot(showRawSeries ? nDxy : na, "DXY norm", color=color.new(color.blue, 55))
plot(showRawSeries ? nGold : na, "Gold norm", color=color.new(color.yellow, 45))
plot(showRawSeries ? nOil : na, "Oil norm", color=color.new(color.orange, 55))
plot(showRawSeries ? nCopper : na, "Copper norm", color=color.new(color.teal, 55))
plot(showRawSeries ? nUs10y : na, "US10Y norm", color=color.new(color.red, 55))

bgcolor(color.new(riskRegimeColor, 90))

//====================================================
// TABLE DASHBOARD - TEXTE NOIR
//====================================================
var table t = table.new(position.top_right, 2, 18, border_width=1)

if barstate.islast
    if showTable
        table.cell(t, 0, 0, "Bloc", text_color=color.black, bgcolor=color.new(color.gray, 75))
        table.cell(t, 1, 0, "Valeur", text_color=color.black, bgcolor=color.new(color.gray, 75))

        table.cell(t, 0, 1, "Régime marché", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 1, riskRegimeText, text_color=color.black, bgcolor=color.new(riskRegimeColor, 80))

        table.cell(t, 0, 2, "Regime score", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 2, f_txt(riskRegimeScore), text_color=color.black, bgcolor=f_bg(riskRegimeScore))

        table.cell(t, 0, 3, "Composite", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 3, f_txt(compositeScore), text_color=color.black, bgcolor=f_bg(compositeScore))

        table.cell(t, 0, 4, "Risk On", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 4, f_txt(riskOnScore), text_color=color.black, bgcolor=f_bg(riskOnScore))

        table.cell(t, 0, 5, "Risk Off", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 5, f_txt(riskOffScore), text_color=color.black, bgcolor=f_bg(riskOffScore))

        table.cell(t, 0, 6, "Macro US", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 6, f_txt(macroUSScore), text_color=color.black, bgcolor=f_bg(macroUSScore))

        table.cell(t, 0, 7, "Rates", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 7, f_txt(ratesScore), text_color=color.black, bgcolor=f_bg(ratesScore))

        table.cell(t, 0, 8, "Technique", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 8, f_txt(techScore), text_color=color.black, bgcolor=f_bg(techScore))

        table.cell(t, 0, 9, "US10Y-DE10Y", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 9, f_txt(spreadUSDE), text_color=color.black, bgcolor=color.new(color.blue, 85))

        table.cell(t, 0, 10, "US10Y-JP10Y", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 10, f_txt(spreadUSJP), text_color=color.black, bgcolor=color.new(color.blue, 88))

        table.cell(t, 0, 11, "US10Y-CN10Y", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 11, f_txt(spreadUSCN), text_color=color.black, bgcolor=color.new(color.orange, 82))

        table.cell(t, 0, 12, "DE10Y-JP10Y", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 12, f_txt(spreadDEJP), text_color=color.black, bgcolor=color.new(color.teal, 82))

        table.cell(t, 0, 13, "DE10Y-CN10Y", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 13, f_txt(spreadDECN), text_color=color.black, bgcolor=color.new(color.maroon, 84))

        table.cell(t, 0, 14, "Courbe US 10s2s", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 14, f_txt(curve10s2s), text_color=color.black, bgcolor=color.new(color.yellow, 82))

        table.cell(t, 0, 15, "HYG/LQD", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 15, f_txt(creditRatio), text_color=color.black, bgcolor=color.new(color.green, 82))

        table.cell(t, 0, 16, "FFR implicite", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 16, f_txt(ffrImplied), text_color=color.black, bgcolor=color.new(color.purple, 84))

        table.cell(t, 0, 17, "RSI ancre", text_color=color.black, bgcolor=color.white)
        table.cell(t, 1, 17, f_txt(anchorRSI), text_color=color.black, bgcolor=color.new(color.fuchsia, 84))
    else
        table.clear(t, 0, 0, 1, 17)

//====================================================
// ALERTS
//====================================================
alertcondition(riskRegime == 1, "Risk On", "Régime de marché = RISK ON")
alertcondition(riskRegime == -1, "Risk Off", "Régime de marché = RISK OFF")
alertcondition(riskRegime == 0, "Neutral", "Régime de marché = NEUTRE")
alertcondition(ta.crossover(riskRegimeScore, riskOnThreshold), "Cross Risk On", "Le score de régime passe en Risk On")
alertcondition(ta.crossunder(riskRegimeScore, riskOffThreshold), "Cross Risk Off", "Le score de régime passe en Risk Off")
````
