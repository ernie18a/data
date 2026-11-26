# Tangram Bot 2 - Smartbot

- url: https://www.tradingview.com/script/b4QLKqqm-Tangram-Bot-2-Smartbot/
- type: strategy
- pine_id: PUB;jrNlVZN80DV9RKXAD5Pe9eontf5IHtJZ
- version: 2.0

## Description

Primeira Versão do Script Tangram Bot 2 da Smartbot para tradingview.

A intenção é agilizar e fazer um teste prévio e rápido do setup.
O resultado indicado aqui jamais corresponderá a um resultado real. É apenas uma ferramenta de estudo.
Ainda falta fazer e melhorar a parte de gestão de risco.
Caso queria fazer alguma sugestão ao cógido para melhorar a gestão de risco ou caso tenha encontrado algum erro, favor comunicar.

O tangram bot 2 combina o uso de até dez Indicadores de Análise Técnica com Gerenciamento de Risco (stop gain, stop loss, stop móvel, realização parcial, bloqueio de reversões, lucro máximo por dia e prejuízo máximo por dia) e Filtros Diversos (sentido das operações, uso do after-market, bloqueio de nova entrada após saída, hora inicial e hora final para negociação). São utilizados os indicadores Médias Móveis, HiLo Activator, MACD, ADX, Estocástico, VWAP, IFR, Bandas de Bollinger, Stop ATR e SAR Parabólico

## Source Code

````pine
//@version=3
strategy("Tangram Bot 2", "TB2", true, pyramiding=0, calc_on_order_fills=true, calc_on_every_tick=true, backtest_fill_limits_assumption=1, default_qty_value=2, linktoseries=false, slippage=1, commission_type=strategy.commission.cash_per_contract, commission_value=1)
// === GENERAL INPUTS ===

// Indicadores Tecnicos
iOPModo      = input(4, "[Estratégia] Modo: 0:Off 1:comprado, 2:vendido, ambos: 3:sem reversão, 4:com reversão", minval=0, maxval=4, step=1)
iPrevinir    = input(true, "[Estratégia] Prevenir entradas no mesmo sentido após uma saída")

iMMModo      = input(3, "[MM] Modo: 0:Off 1:entrada, 2:saída, 3:ambos", minval=0, maxval=3, step=1)
iMMForma     = input("acima/abaixo", "[MM] Forma de operação", options=["cruzamento", "acima/abaixo"])
iMMCurtaTipo = input("Exponencial", "[MM] Média Curta: Tipo", options=["Simples", "Exponencial"] )
iMMCurtaLen  = input(10, "[MM] Média Curta: Periodos", minval=1)
iMMCurtaDes  = input(0, "[MM] Média Curta: Deslocamento", minval=0)
iMMCurtaSrc  = input(close, "[MM] Média Curta: Fonte")
iMMLongaTipo = input("Simples", "[MM] Média Longa: Tipo", options=["Simples", "Exponencial"])
iMMLongaLen  = input(40, "[MM] Média Longa: Periodos", minval=1)
iMMLongaDes  = input(0, "[MM] Média Longa: Deslocamento", minval=0)
iMMLongaSrc  = input(close, "[MM] Média Longa: Fonte")

iHLModo  = input(0, "[HiLo] Modo: 0:Off 1:entrada, 2:saída, 3:ambos", minval=0, maxval=3, step=1)
iHLForma = input("Mudança de sentido", "[HiLo] Forma de operação", options=["Mudança de sentido", "Sentido da escada"])
iHLLen   = input(9, "[HiLo] Periodos", minval=2)

iMACDModo   = input(0, "[MACD] Modo: 0:Off 1:entrada, 2:saída, 3:ambos", minval=0, maxval=3, step=1)
iMACDForma  = input("cruzamento", "[MACD] Forma de operação", options=["cruzamento", "acima/abaixo"])
iMACDSrc    = input(close, "[MACD] Fonte usada nas médias")
iMACDTipo   = input("Simples", "[MACD] Tipo de média para cálculo", options=["Simples", "Exponencial"])
iMACDCurta  = input(12, "[MACD] Média Curta: Periodos", minval=1)
iMACDLonga  = input(26, "[MACD] Média Longa: Periodos", minval=2)
iMACDSinal  = input(9, "[MACD] Linha de sinal: Periodos", minval=1)
iMACDFiltro = input(false, "[MACD] Usar filtro para validar MACD")
iMACDFilVal = input(0.0, "[MACD] Valor do filtro compra acima e vende abaixo", minval=0)

iADXModo  = input(0, "[ADX] Modo: 0:Off 1:entrada, 2:saída, 3:ambos", minval=0, maxval=3, step=1)
iADXForma = input("cruzamento", "[ADX] Forma de operação", options=["cruzamento", "acima/abaixo"])
iADXLen   = input(14, "[ADX] Número de periodos", minval=1)
iADXSuave = input(14, "[ADX] Suavizador de ADX", minval=1)
iADXMin   = input(0, "[ADX] Filtro ADX mínimo", minval=0, maxval=100)
iADXMax   = input(100, "[ADX] Filtro ADX máximo", minval=10, maxval=100) 
iADXTrend = input(0, "[ADX] Tendência: 0:Off 1:ADX subindo, -1:ADX caindo", minval=-1, maxval=1, step=1)

iESTModo  = input(0, "[Estocastico] Modo: 0:Off 1:entrada, 2:saída, 3:ambos", minval=0, maxval=3, step=1)
iESTForma = input("acima/abaixo", "[Estocastico] Forma de operação", options=["cruzamento", "acima/abaixo"])
iESTLen   = input(14, "[Estocastico] Número de periodos", minval=1)
iESTSuavK = input(3, "[Estocastico] Suavizador da linha K", minval=0)
iESTSuavD = input(3, "[Estocastico] Suavizador da linha D", minval=0)
iESTMin   = input(100, "[Estocastico] Filtro Estocastico mínimo", minval=0, maxval=100)
iESTMax   = input(0, "[Estocastico] Filtro Estocastico máximo", minval=0, maxval=100)

iVWAPModo  = input(0, "[VWAP] Modo: 0:Off 1:entrada, 2:saída, 3:ambos", minval=0, maxval=3, step=1)
iVWAPForma = input("Compra acima/Vende abaixo", "[VWAP] Forma de Operação: ", options=["Rompimento", "Compra acima/Vende abaixo", "Vende acima/Compra abaixo"])

iIFRModo  = input(0, "[IFR] Modo: 0:Off 1:entrada, 2:saída, 3:ambos", minval=0, maxval=3, step=1)
iIFRForma = input("acima/abaixo", "[IFR] Forma de operação", options=["cruzamento", "acima/abaixo"])
iIFRSrc   = input(close, "[IFR] Fonte")
iIFRLen   = input(14, "[IFR] Número de periodos", minval=1)
iIFRMin   = input(20.0, "[IFR] linha de sobrevendido", minval=0, maxval=100)
iIFRMax   = input(80.0, "[IFR] linha de sobrecomprado", minval=30, maxval=100)

iBBModo  = input(0, "[BB] Modo: 0:Off 1:entrada, 2:saída, 3:ambos", minval=0, maxval=3, step=1)
iBBForma = input("cruzamento", "[BB] Forma de operação", options=["cruzamento", "acima/abaixo"])
iBBSrc   = input(close, "[BB] Fonte para Bolinger Bands")
iBBLen   = input(20, "[BB] Número de periodos", minval=1)
iBBDes   = input(2.0, "[BB] Desvio", minval=0.001, maxval=50)

iATRModo  = input(0, "[ATR] Modo: 0:Off 1:entrada, 2:saída, 3:ambos", minval=0, maxval=3, step=1)
iATRForma = input("Alteração de sentido", "[ATR] Forma de operação", options=["Alteração de sentido", "Seguindo o sentido"])
iATRTipo  = input("Exponencial", "[ATR] Tipo de média", options=["Simples", "Exponencial"] )
iATRLen   = input(6, "[ATR] Número de periodos", minval=1)
iATRMult  = input(3.5, "[ATR] Desvio", minval=0.001, maxval=50)

iSARModo  = input(0, "[SAR] Modo: 0:Off 1:entrada, 2:saída, 3:ambos", minval=0, maxval=3, step=1)
iSARForma = input("Alteração de sentido", "[SAR] Forma de operação", options=["Alteração de sentido", "Seguindo o sentido"])
iSARFA    = input(0.02, "[SAR] Fator de aceleração", minval=0.001, maxval=50)
iSARFI    = input(0.02, "[SAR] Fator de incremento", minval=0.001, maxval=50)
iSARLim   = input(0.20, "[SAR] Valor máximo de fator", minval=0.001, maxval=50)


// === RISK MANAGEMENT VALUE PREP ===
// if an input is less than 1, assuming not wanted so we assign 'na' value to disable it.
iSaidaAll     = input(false, "[Saída] Somente com todos os indicadores de saida")

iEStopFixo    = input(0.0, "[Stop Fixo] Stop em valor absoluto")
iETakeFixo    = input(0.0, "[Take Fixo] Stop de ganho em valor absoluto")
iETSAtivar    = input(0.0, "[Trailing Stop] Ativa trailling stop em X pontos/centavos")
iETSDistancia = input(0.0, "[Trailing Stop] Manter distancia em X pontos/centavos")
iEParcialT    = input(0.0, "[Parcial] Número de ticks para saída parcial")

iEParcialBE = input(true, "[Parcial] após parcial, mover stop ao Break Even")

iSDPerda    = input(50000.0, "[Stop no Dia] Parar caso haja perda de", minval = 0)
iSDGanho    = input(50000.0, "[Stop no Dia] Parar caso haja ganho de", minval = 0)
iSDXTrades  = input(999, "[Stop no Dia] Parar após número X de operações", minval = 1)


// Work time and Order time restrictions.
iTtz   = syminfo.timezone // input("GMT-3", "What is the Time Zone")
iTdate = input(20190101, " Data inicial para backtest: YYYYMMDD")
iTdias = input(365, "Dias após a data inicial em backtest")
iTot   = input("0900-1730", "Horário permitido abrir posições ", type=session)
iTwt   = input("0900-1755", "Horário final para zerar posições se abertas", type=session)


// Fix Tick on especial assets
iFixMinTick = input(0.0, "Ajusta o tick no Tradingview", minval=0.0)

// === DEPENDENCE AND FUNCTIONS ===
roundTo(v, t) =>
    r = round(v * (1/t)) / (1/t)

getNum(n, d) =>
    r = floor((n % pow(10, d)) / pow(10, d-1))

// === ESTRATEGIAS ===
mmEntrada = (iMMModo == 1 or iMMModo >= 3)
mmSaida   = iMMModo > 1
mmCurta   = 0.0
mmLonga   = 0.0
if iMMModo
	mmCurta := iff(iMMCurtaTipo == "Simples", sma(iMMCurtaSrc[iMMCurtaDes], iMMCurtaLen), ema(iMMCurtaSrc[iMMCurtaDes], iMMCurtaLen))
	mmLonga := iff(iMMLongaTipo == "Simples", sma(iMMLongaSrc[iMMLongaDes], iMMLongaLen), ema(iMMLongaSrc[iMMLongaDes], iMMLongaLen))
plot(iMMModo ? mmCurta : na, "MM Curta", #90CAF9, 1, line, 0, 15)
plot(iMMModo ? mmLonga : na, "MM Longa", #9575CD, 2, line, 0, 15)
eMM() =>
	r = 0
	if iMMForma == "cruzamento"
		if crossover(mmCurta, mmLonga)
			r := 1
		if crossunder(mmCurta, mmLonga)
			r := -1
	if iMMForma == "acima/abaixo"
		if mmCurta > mmLonga
			r := 1
		if mmCurta < mmLonga
			r := -1
	r

hlEntrada = (iHLModo == 1 or iHLModo >= 3)
hlSaida   = iHLModo > 1
hlHigh    = 0.0
hlLow     = 0.0
hlH       = 0.0
hlL       = 0.0
hlSentido = 0.0
hlStop    = 0.0
hlColor   = black

if iHLModo
	hlHigh := sma(high, iHLLen)
	hlLow  := sma(low, iHLLen)
	hlH := highest(high, iHLLen)
	hlL := lowest(low, iHLLen)
	hlSentido := iff(close > hlHigh, 1, iff(close < hlLow, -1, 0))
	hlStop := iff(close > hlHigh, hlL, iff(close < hlLow, hlH, hlStop[1]))
	hlColor := hlStop < low ? green : red
plot(iHLModo ? hlStop: na, "Hi Lo Activator", hlColor, 2, circles, 0, 15)
eHiLo() =>
	r = 0
	if iHLForma == "Sentido da escada"
		if hlStop < low
			r := 1
		else 
			r := -1
	if iHLForma == "Mudança de sentido"
		if hlSentido > 0 and hlSentido[1] < 0
			r := 1
		if hlSentido < 0 and hlSentido[1] > 0
			r := -1
	r

macdEntrada = (iMACDModo == 1 or iMACDModo >= 3)
macdSaida   = iMACDModo > 1
macdTipo    = iMACDTipo == "Simples"? true: false
macdCurta   = 0.0
macdLonga   = 0.0
macdLine    = 0.0
macdSinal   = 0.0
macdHist    = 0.0
if iMACDModo
	macdCurta := macdTipo ? sma(iMACDSrc, iMACDCurta) : ema(iMACDSrc, iMACDCurta)
	macdLonga := macdTipo ? sma(iMACDSrc, iMACDLonga) : ema(iMACDSrc, iMACDLonga)
	macdLine  := macdCurta - macdLonga
	macdSinal := macdTipo ? sma(macdLine, iMACDSinal) : ema(macdLine, iMACDSinal)
	macdHist  := macdLine - macdSinal
eMACD() =>
	r = 0
	if iMACDForma == "cruzamento"
		if crossover(macdLine, macdSinal)
			r :=  1
		if crossunder(macdLine, macdSinal)
			r := -1
	if iMACDForma == "acima/abaixo"
		if macdLine > macdSinal
			r := 1
		else
			r := -1
	if iMACDFiltro
		if r == 1 and macdLine < iMACDFilVal
			r := 0
		if r == -1 and macdLine > iMACDFilVal
			r := 0
	r

adxEntrada = (iADXModo == 1 or iADXModo >= 3)
adxSaida   = iADXModo > 1
adxUp = 0.0
adxDown = 0.0
adxPlusDM = 0.0
adxMinusDM = 0.0
adxTrur = 0.0
adxPlus = 0.0
adxMinus = 0.0
adxSum = 0.0
adxLine = 0.0
if iADXModo
	adxUp := change(high)
	adxDown := -change(low)
	adxPlusDM := na(adxUp) ? na : (adxUp > adxDown and adxUp > 0 ? adxUp : 0)
	adxMinusDM := na(adxDown) ? na : (adxDown > adxUp and adxDown > 0 ? adxDown : 0)
	adxTrur := rma(tr, iADXLen)
	adxPlus := fixnan(100 * rma(adxPlusDM, iADXLen) / adxTrur)
	adxMinus := fixnan(100 * rma(adxMinusDM, iADXLen) / adxTrur)
	adxSum := adxPlus + adxMinus
	adxLine := 100 * rma(abs(adxPlus - adxMinus) / (adxSum == 0 ? 1 : adxSum), iADXSuave)


eADX() =>
	r = 0
	if iADXForma == "cruzamento"
		if crossover(adxPlus, adxMinus)
			r := 1
		if crossover(adxMinus, adxPlus)
			r := -1
	if iADXForma == "acima/abaixo"
		if adxPlus > adxMinus
			r := 1
		if adxMinus > adxPlus
			r := -1
	if adxLine < iADXMin or adxLine > iADXMax
		r := 0
	if iADXTrend > 0 and (adxLine <= adxLine[1])
		r := 0
	if iADXTrend < 0 and (adxLine >= adxLine[1])
		r := 0
	r

estEntrada = (iESTModo == 1 or iESTModo >= 3)
estSaida   = iESTModo > 1
estK = 0.0
estD = 0.0
if iESTModo
	estK := sma(stoch(close, high, low, iESTLen), iESTSuavK)
	estD := sma(estK, iESTSuavD)
eEST() =>
	r = 0
	if iESTForma == "cruzamento"
		if crossover(estK, estD)
			r := 1
		if crossunder(estK, estD)
			r := -1
	if iESTForma == "acima/abaixo"
		if estK > estD
			r := 1
		if estK < estD
			r := -1
	if (r == 1 and estK > iESTMin) or (r == -1 and estK < iESTMax)
		r := 0
	r

vwEntrada = (iVWAPModo == 1 or iVWAPModo >= 3)
vwSaida   = iVWAPModo > 1
plot(iVWAPModo ? vwap : na, "VWAP", #9E9E9E, 3, line, 0, 15)
eVWAP() =>
	r = 0
	if iVWAPForma == "Rompimento"
		if crossover(close, vwap)
			r := 1
		if crossunder(close, vwap)
			r := -1
	if iVWAPForma == "Compra acima/Vende abaixo"
		if close > vwap
			r := 1
		if close < vwap
			r := -1
	if iVWAPForma == "Vende acima/Compra abaixo"
		if close > vwap
			r := -1
		if close < vwap
			r := 1
	r

ifrEntrada = (iIFRModo == 1 or iIFRModo >= 3)
ifrSaida   = iIFRModo > 1
ifrUp   = 0.0
ifrDown = 0.0
ifr     = 0.0
if iIFRModo
	ifrUp   := rma(max(change(iIFRSrc), 0), iIFRLen)
	ifrDown := rma(-min(change(iIFRSrc), 0), iIFRLen)
	ifr     := ifrDown == 0 ? 100 : ifrUp == 0 ? 0 : 100 - (100 / (1 + ifrUp / ifrDown))
eIFR() =>
	r = 0
	if iIFRForma == "cruzamento"
		if crossover(ifr, iIFRMin)
			r := 1
		if crossunder(ifr, iIFRMax)
			r := -1
	if iIFRForma == "acima/abaixo"
		if ifr < iIFRMin
			r := 1
		if ifr > iIFRMax
			r := -1
	r

bbEntrada = (iBBModo == 1 or iBBModo >= 3)
bbSaida   = iBBModo > 1
bbBase    = 0.0
bbDesvio  = 0.0
bbUp      = 0.0
bbDown    = 0.0
if iBBModo
	bbBase   := sma(iBBSrc, iBBLen)
	bbDesvio := iBBDes * stdev(iBBSrc, iBBLen) 
	bbUp     := bbBase + bbDesvio
	bbDown   := bbBase - bbDesvio
plot(iBBModo? bbBase: na, "BB Média base", #fb8c00, 1, circles, 0, 15)
plot(iBBModo? bbUp: na, "BB Up Line", #fb8c00, 1, line, 0, 15)
plot(iBBModo? bbDown: na, "BB Bottom Line", #fb8c00, 1, line, 0, 15)
eBB() =>
	r = 0
	if iBBForma == "cruzamento"
		if crossover(iBBSrc, bbDown)
			r := 1
		if crossunder(iBBSrc, bbUp)
			r := -1
	if iBBForma == "acima/abaixo"
		if iBBSrc < bbDown
			r := 1
		if iBBSrc > bbUp
			r := -1
	r


atrEntrada = (iATRModo == 1 or iATRModo >= 3)
atrSaida   = iATRModo > 1
atrX     = na
atrLoss  = na
atrStop  = na
atrPos   = na
atrColor = black
if iATRModo
	atrX     := atr(iATRLen)
	atrLoss  := iATRMult * atrX
	atrStop  := iff(close > nz(atrStop[1], 0) and close[1] > nz(atrStop[1], 0), max(nz(atrStop[1]), close - atrLoss), iff(close < nz(atrStop[1], 0) and close[1] < nz(atrStop[1], 0), min(nz(atrStop[1]), close + atrLoss), iff(close > nz(atrStop[1], 0), close - atrLoss, close + atrLoss)))
	atrPos   := iff(close[1] < nz(atrStop[1], 0) and close > nz(atrStop[1], 0), 1, iff(close[1] > nz(atrStop[1], 0) and close < nz(atrStop[1], 0), -1, nz(atrPos[1], 0)))
	atrColor := atrPos == -1 ? red: atrPos == 1 ? green : blue 
plot(iATRModo? atrStop: na, "Stop ATR", atrColor, 1, linebr, 0, 15) 
eATR() =>
	r = 0
	if iATRForma == "Alteração de sentido"
		if crossover(close, atrStop)
			r := 1
		if crossunder(close, atrStop)
			r := -1
	if iATRForma == "Seguindo o sentido"
		if close > atrStop
			r := 1
		if close < atrStop
			r := -1
	r


sarEntrada = (iSARModo == 1 or iSARModo >= 3)
sarSaida   = iSARModo > 1
sarVal   = 0.0
sarColor = black
if iSARModo
	sarVal   := sar(iSARFA, iSARFI, iSARLim)
	sarColor := iff(close > sarVal, #4dd0e1, #f06292)
plot(iSARModo? sarVal: na, "Parabolic SAR", sarColor, 2, circles, 0, 15)
eSAR() =>
	r = 0
	if iSARForma == "Alteração de sentido"
		if crossover(close, sarVal)
			r := 1
		if crossunder(close, sarVal)
			r := -1
	if iSARForma == "Seguindo o sentido"
		if close > sarVal
			r := 1
		if close < sarVal
			r := -1
	r

// === SERIES SETUP  GENERAL ===
minTick  = iFixMinTick ? iFixMinTick: syminfo.mintick
// minTickS = iFixMinTick ? iFixMinTick / syminfo.mintick: 1


// === MANEJO DE DAY TRADE ===
strategy.risk.max_intraday_filled_orders(iSDXTrades)
netProfit = 0.0
netProfit := nz(netProfit[1])
yesterday = 0.0
yesterday := nz(yesterday[1])
if yesterday != dayofmonth
    yesterday := dayofmonth
	netProfit := strategy.netprofit

dayProfit = strategy.netprofit - netProfit + strategy.openprofit
dayStop = dayProfit >= iSDGanho or dayProfit <= -iSDPerda


// === DAY TRADE TIME RESTRICTION ===
// you can put fixed values and comment the input to have a cleanner menu.
wy = getNum(iTdate, 8)*1000 + getNum(iTdate, 7)*100 + getNum(iTdate, 6)*10 + getNum(iTdate, 5)
wm = getNum(iTdate, 4)*10 + getNum(iTdate, 3)
wd = getNum(iTdate, 2)*10 + getNum(iTdate, 1)

wot = time('1', iTot)
wwt = time('1', iTwt)

woti = timestamp(iTtz, wy, wm, wd, 0, 0)
wotf = woti + (iTdias * 86400000)

orderTime = (time > woti and time < wotf) and not(na(wot)) and not dayStop
workTime  = (time > woti and time < wotf) and not(na(wwt))

// bgcolor(workTime ? na: #FFFFFF, transp=80)
bgcolor(orderTime? na: workTime ? yellow: #FFFFFF, transp=80)

// === STRATEGY FUNCTIONS ===

// === RISK MANAGEMENT VALUE PREP ===
// if an input is less than 1, assuming not wanted so we assign 'na' value to disable it.
eStop = iEStopFixo > 0    ? iEStopFixo / minTick: na
eTake = iETakeFixo > 0    ? iETakeFixo / minTick: na
eTS   = iETSAtivar > 0    ? iETSAtivar / minTick: na
eTSD  = iETSDistancia > 0 ? iETSDistancia / minTick: na
eParc = iEParcialT > 0    ? iEParcialT / minTick: na


// === CONTAGEM ===
cEntradas() =>
	c = 0
	c := mmEntrada   ? c + 1 : c
	c := hlEntrada   ? c + 1 : c
	c := macdEntrada ? c + 1 : c
	c := adxEntrada  ? c + 1 : c
	c := estEntrada  ? c + 1 : c
	c := vwEntrada   ? c + 1 : c
	c := ifrEntrada  ? c + 1 : c
	c := bbEntrada   ? c + 1 : c
	c := atrEntrada  ? c + 1 : c
	c := sarEntrada  ? c + 1 : c
	c

cSaidas() =>
	c = 0
	c := mmSaida   ? c + 1 : c
	c := hlSaida   ? c + 1 : c
	c := macdSaida ? c + 1 : c
	c := adxSaida  ? c + 1 : c
	c := estSaida  ? c + 1 : c
	c := vwSaida   ? c + 1 : c
	c := ifrSaida  ? c + 1 : c
	c := bbSaida   ? c + 1 : c
	c := atrSaida  ? c + 1 : c
	c := sarSaida  ? c + 1 : c
	c


entradaCompra() =>
	c = 0
	c := mmEntrada   and eMM()   > 0? c + 1: c
	c := hlEntrada   and eHiLo() > 0? c + 1: c
	c := macdEntrada and eMACD() > 0? c + 1: c
	c := adxEntrada  and eADX()  > 0? c + 1: c
	c := estEntrada  and eEST()  > 0? c + 1: c
	c := vwEntrada   and eVWAP() > 0? c + 1: c
	c := ifrEntrada  and eIFR()  > 0? c + 1: c
	c := bbEntrada   and eBB()   > 0? c + 1: c
	c := atrEntrada  and eATR()  > 0? c + 1: c
	c := sarEntrada  and eSAR()  > 0? c + 1: c
	prev = iff(iPrevinir and c[1] == cEntradas(), false, true)
	orderTime and (iOPModo == 1 or iOPModo >= 3) and c == cEntradas() and c > 0 and barstate.isconfirmed and prev


entradaVenda() =>
	c = 0
	c := mmEntrada   and eMM()   < 0? c + 1: c
	c := hlEntrada   and eHiLo() < 0? c + 1: c
	c := macdEntrada and eMACD() < 0? c + 1: c
	c := adxEntrada  and eADX()  < 0? c + 1: c
	c := estEntrada  and eEST()  < 0? c + 1: c
	c := vwEntrada   and eVWAP() < 0? c + 1: c
	c := ifrEntrada  and eIFR()  < 0? c + 1: c
	c := bbEntrada   and eBB()   < 0? c + 1: c
	c := atrEntrada  and eATR()  < 0? c + 1: c
	c := sarEntrada  and eSAR()  < 0? c + 1: c
	prev = iff(iPrevinir and c[1] == cEntradas(), false, true)
	orderTime and (iOPModo > 1) and c == cEntradas() and c > 0 and barstate.isconfirmed and prev


saidaCompra() =>
	c = 0
	c := mmSaida   and eMM()   < 0? c + 1: c
	c := hlSaida   and eHiLo() < 0? c + 1: c
	c := macdSaida and eMACD() < 0? c + 1: c
	c := adxSaida  and eADX()  < 0? c + 1: c
	c := estSaida  and eEST()  < 0? c + 1: c
	c := vwSaida   and eVWAP() < 0? c + 1: c
	c := ifrSaida  and eIFR()  < 0? c + 1: c
	c := bbSaida   and eBB()   < 0? c + 1: c
	c := atrSaida  and eATR()  < 0? c + 1: c
	c := sarSaida  and eSAR()  < 0? c + 1: c
	workTime and iff(iSaidaAll, c == cSaidas(), c > 0)

saidaVenda() =>
	c = 0
	c := mmSaida   and eMM()   > 0? c + 1: c
	c := hlSaida   and eHiLo() > 0? c + 1: c
	c := macdSaida and eMACD() > 0? c + 1: c
	c := adxSaida  and eADX()  > 0? c + 1: c
	c := estSaida  and eEST()  > 0? c + 1: c
	c := vwSaida   and eVWAP() > 0? c + 1: c
	c := ifrSaida  and eIFR()  > 0? c + 1: c
	c := bbSaida   and eBB()   > 0? c + 1: c
	c := atrSaida  and eATR()  > 0? c + 1: c
	c := sarSaida  and eSAR()  > 0? c + 1: c
	workTime and iff(iSaidaAll, c == cSaidas(), c > 0)


// === STRATEGY MANAGER ===


if iOPModo == 3 and strategy.position_size < 1
	strategy.order("Compra", strategy.long, when=entradaCompra())
	strategy.order("Venda", strategy.short, when=entradaVenda())
else
	strategy.entry("Compra", strategy.long, when=entradaCompra())
	strategy.entry("Venda", strategy.short, when=entradaVenda())

strategy.close("Compra", when=saidaCompra())
strategy.close("Venda", when=saidaVenda())


eStop := iff(abs(strategy.position_size) < 2 and eParc > 0 and iEParcialBE, 0, eStop)

strategy.exit("Parcial", qty=1, profit=eParc, loss=eStop, when=eParc > 0)
strategy.exit("Saida", profit=eTake, trail_points=eTS, trail_offset=eTSD, loss=eStop)

strategy.cancel_all(not orderTime)
strategy.close_all((not workTime) or dayStop)

plot(syminfo.mintick, "Valor do Tick")
````
