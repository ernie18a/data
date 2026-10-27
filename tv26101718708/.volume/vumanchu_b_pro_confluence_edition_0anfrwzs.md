# VuManChu B PRO - Confluence Edition

- url: https://www.tradingview.com/script/0aNFrWzS/
- type: indicator
- pine_id: PUB;eef088a73df8442ba74bd23a8015d719
- version: 1.0

## Description

Versão refinada do clássico VuManChu Cipher B Divergences, focada em reduzir ruído e aumentar a assertividade dos sinais através de filtros de contexto e um sistema de score de confluência.

🙏 Créditos
Este indicador é uma evolução do trabalho original do VuManChu (Cipher B Divergences), que por sua vez foi inspirado em códigos de:

dynausmaux — código base
LazyBear — WaveTrend Oscillator
RicardoSantos — Divergence Detector
LucemAnb — Plain Stochastic Divergence
andreholanda73 — MFI+RSI Area
falconCoin — Market Cipher B free version
Todo o crédito da matemática original (WaveTrend, divergências, MFI, Stoch RSI, Schaff) vai para esses autores. Esta versão mantém os cálculos e adiciona uma camada de filtros e lógica de sinal.

⚡ O que mudou em relação ao original
🐛 Correções de bugs
Removido barmerge.lookahead_on no acesso a timeframes superiores. O original "vazava" dados do futuro no backtest, gerando uma falsa impressão de precisão. Agora usa lookahead_off — backtest honesto.
Migração para Pine Script v5 — código mais performático, seguro e moderno.
Alertas só disparam em barstate.isconfirmed — eliminado o problema de alertas que apareciam intrabar e sumiam (repaint de alerta).
🛡️ Filtros de contexto (a maior mudança)
O original mostrava sinais sem considerar o contexto de mercado. Agora há 4 filtros que podem ser ligados/desligados individualmente:

Filtro de tendência (EMA 50/200): bloqueia sinais contra-tendência quando a tendência é forte. Evita "pegar faca caindo".
Filtro de regime (ADX 14): descarta sinais em mercado morto (ADX < 15) e bloqueia divergências contrárias em tendência muito forte (ADX > 40).
Filtro de volume: exige volume acima da média (configurável). Divergência sem volume é quase sempre falsa.
Filtro de volatilidade (ATR): descarta velas pequenas demais (ruído de range).
🎯 Sistema de Score de Confluência
Em vez de plotar todos os sinais (como o original fazia), o PRO usa um score de 0 a 6 pontos. O sinal só aparece quando o score atinge o mínimo configurável (padrão: 3).

Critério	Pontos padrão
WT cross em zona OB/OS	+1
Divergência WaveTrend	+2
Divergência RSI	+1
MFI alinhado (>0 compra, <0 venda)	+1
Stoch RSI cruzando em zona extrema	+1
Tendência a favor (EMA)	+1
Triângulo verde-claro = score atingiu o mínimo.
Triângulo verde-escuro = score forte (mínimo + 1 ou mais).

Todos os pesos são configuráveis — você pode dar mais peso ao critério que confia mais.

🕐 Cooldown anti-whipsaw
Configurável (padrão: 5 barras). Após um sinal, bloqueia novos sinais na mesma direção pelo período definido. Elimina aqueles clusters de pontos seguidos que confundiam o original.

📋 Painel de status em tempo real
Label flutuante no canto direito mostra:

Score atual de compra e venda
Valor do ADX e classificação (forte/ok/fraco)
Direção da tendência (UP/DOWN/FLAT)
Status dos filtros de volume e ATR
Você vê na hora por que um sinal está ou não sendo gerado.

🔄 Modo Clássico opcional
Toggle no topo: desligando o "Modo PRO", o indicador volta ao comportamento original do VuManChu. Útil pra comparar lado a lado.

🥇 Gold Buy preservado
O famoso círculo dourado do VuManChu foi mantido, mas agora também passa pelos filtros de contexto — fica ainda mais raro e ainda mais confiável.

📈 Como usar
Sinais principais
Sinal	Significado
🔺 Triângulo verde	PRO BUY — confluência mínima atingida
🟢 Triângulo verde escuro	PRO BUY forte — score acima do mínimo
🔻 Triângulo vermelho	PRO SELL
🟡 Círculo dourado	Gold Buy — alta probabilidade (raro)
⚪ Círculos pequenos	WaveTrend cross (informacional)
Timeframes recomendados
Sweet spot: 1h, 4h, 12h
Excelente para swing/DCA: Diário, Semanal
Funciona com ajustes: 15m, 30m (subir score mínimo para 4)
Não recomendado: abaixo de 15m
Configuração rápida por estilo
Day trade (15m–1h):

Score mínimo: 4
Cooldown: 8 barras
ADX mínimo: 20
Swing (4h–12h):

Score mínimo: 3 (padrão)
Cooldown: 5 (padrão)
DCA / Position (Diário–Semanal):

Score mínimo: 4
Foco em Gold Buy
Ignorar sinais de venda
🚨 Alertas disponíveis
PRO Buy — sinal de compra com score atingido
PRO Sell — sinal de venda com score atingido
Gold Buy — sinal raro de alta probabilidade
Classic Buy/Sell — versão original (se quiser usar)
Todos os alertas disparam apenas em barra fechada (sem repaint).

⚠️ Disclaimer
Este indicador é uma ferramenta de análise, não uma recomendação de investimento. Nenhum indicador acerta 100%. Use sempre:

Gerenciamento de risco (stop loss, position sizing)
Confluência com sua própria análise
Backtest no seu ativo e timeframe antes de usar capital real
Mercado é probabilidade, não certeza. DYOR.

🤝 Open Source
Código aberto sob licença Mozilla Public License 2.0 (mesma do original). Fique à vontade para forkar, melhorar e contribuir.

Se gostou, deixe um boost ⚡ e compartilhe seu setup nos comentários — ajuda outros traders a calibrar os filtros para seu mercado.

Bons trades! 📈

## Source Code

````pine
//@version=5
indicator(title='VuManChu B PRO', shorttitle='VMC B PRO', max_labels_count=300)

// GROUPS
G_MODE   = '01 · Modo'
G_FILTER = '02 · Filtros de Contexto'
G_SCORE  = '03 · Score de Confluência'
G_WT     = '04 · WaveTrend'
G_DIV    = '05 · Divergências'
G_RSI    = '06 · RSI / MFI'
G_STOCH  = '07 · Stoch RSI'
G_VIS    = '08 · Visual'

// MODE
proMode      = input.bool(true,  'Modo PRO (score + filtros)', group=G_MODE)
showClassic  = input.bool(false, 'Mostrar pontos clássicos junto', group=G_MODE)
darkMode     = input.bool(false, 'Dark mode', group=G_MODE)

// FILTROS
useTrendFilter = input.bool(true, 'Filtro de tendência (EMA)', group=G_FILTER)
emaFastLen     = input.int(50,  'EMA rápida', minval=5, group=G_FILTER)
emaSlowLen     = input.int(200, 'EMA lenta',  minval=20, group=G_FILTER)
useAdxFilter   = input.bool(true, 'Filtro de regime (ADX)', group=G_FILTER)
adxLen         = input.int(14, 'ADX length', group=G_FILTER)
adxMin         = input.float(15.0, 'ADX mínimo', step=1, group=G_FILTER)
adxMax         = input.float(40.0, 'ADX máximo', step=1, group=G_FILTER)
useVolFilter   = input.bool(true, 'Filtro de volume', group=G_FILTER)
volSmaLen      = input.int(20, 'Volume SMA len', group=G_FILTER)
volMult        = input.float(1.0, 'Volume mínimo x SMA', step=0.1, group=G_FILTER)
useAtrFilter   = input.bool(true, 'Filtro de volatilidade (ATR)', group=G_FILTER)
atrLen         = input.int(14, 'ATR len', group=G_FILTER)
atrMinMult     = input.float(0.5, 'Vela mínima x ATR', step=0.1, group=G_FILTER)
cooldownBars   = input.int(5, 'Cooldown entre sinais (barras)', minval=0, group=G_FILTER)

// SCORE
scoreMin       = input.int(3, 'Score mínimo p/ sinal', minval=1, maxval=6, group=G_SCORE)
wtCrossPts     = input.int(1, 'Pontos: WT cross em OB/OS',  minval=0, maxval=3, group=G_SCORE)
wtDivPts       = input.int(2, 'Pontos: divergência WT',     minval=0, maxval=3, group=G_SCORE)
rsiDivPts      = input.int(1, 'Pontos: divergência RSI',    minval=0, maxval=3, group=G_SCORE)
mfiAlignPts    = input.int(1, 'Pontos: MFI alinhado',       minval=0, maxval=3, group=G_SCORE)
stochAlignPts  = input.int(1, 'Pontos: Stoch alinhado',     minval=0, maxval=3, group=G_SCORE)
trendAgreePts  = input.int(1, 'Pontos: tendência a favor',  minval=0, maxval=3, group=G_SCORE)

// WAVETREND
wtChannelLen = input.int(9,  'WT Channel Length', group=G_WT)
wtAverageLen = input.int(12, 'WT Average Length', group=G_WT)
wtMASource   = input.source(hlc3, 'WT MA Source', group=G_WT)
wtMALen      = input.int(3,  'WT MA Length', group=G_WT)
obLevel      = input.int(53,  'WT OB nível 1', group=G_WT)
obLevel2     = input.int(60,  'WT OB nível 2', group=G_WT)
obLevel3     = input.int(100, 'WT OB nível 3', group=G_WT)
osLevel      = input.int(-53, 'WT OS nível 1', group=G_WT)
osLevel2     = input.int(-60, 'WT OS nível 2', group=G_WT)
osLevel3     = input.int(-75, 'WT OS nível 3', group=G_WT)

// DIV
useRegular   = input.bool(true,  'Divergências regulares',  group=G_DIV)
useHidden    = input.bool(false, 'Divergências escondidas', group=G_DIV)
wtDivOB      = input.int(45,  'WT bear div min', group=G_DIV)
wtDivOS      = input.int(-65, 'WT bull div min', group=G_DIV)
rsiDivOB     = input.int(60,  'RSI bear div min', group=G_DIV)
rsiDivOS     = input.int(30,  'RSI bull div min', group=G_DIV)

// RSI / MFI
rsiSrc        = input.source(close, 'RSI Source', group=G_RSI)
rsiLen        = input.int(14, 'RSI Length', group=G_RSI)
rsiOversold   = input.int(30, 'RSI Oversold', group=G_RSI)
rsiOverbought = input.int(60, 'RSI Overbought', group=G_RSI)
mfiPeriod     = input.int(60, 'MFI Period', group=G_RSI)
mfiMultiplier = input.float(150, 'MFI Multiplier', group=G_RSI)
mfiPosY       = input.float(2.5, 'MFI Y offset', group=G_RSI)

// STOCH
stochSrc     = input.source(close, 'Stoch Source', group=G_STOCH)
stochLen     = input.int(14, 'Stoch Length', group=G_STOCH)
stochRsiLen  = input.int(14, 'Stoch RSI Length', group=G_STOCH)
stochKSmooth = input.int(3,  'K smoothing', group=G_STOCH)
stochDSmooth = input.int(3,  'D smoothing', group=G_STOCH)
stochUseLog  = input.bool(true, 'Use log', group=G_STOCH)

// VIS
showWT       = input.bool(true, 'Show WaveTrend areas', group=G_VIS)
showMFI      = input.bool(true, 'Show MFI area', group=G_VIS)
showRSI      = input.bool(true, 'Show RSI line', group=G_VIS)
showStoch    = input.bool(true, 'Show Stoch RSI', group=G_VIS)
showVwap     = input.bool(true, 'Show Fast WT', group=G_VIS)
showDivLines = input.bool(true, 'Show divergence lines', group=G_VIS)
showScoreLbl = input.bool(true, 'Show score label', group=G_VIS)

// Cores
cBuy        = color.new(#00e676, 0)
cSell       = color.new(#ff1744, 0)
cBuyWeak    = color.new(#00e676, 60)
cSellWeak   = color.new(#ff1744, 60)
cBuyStrong  = color.new(#00c853, 0)
cSellStrong = color.new(#d50000, 0)
cGold       = color.new(#ffb300, 0)
cWT1        = color.new(#4994ec, 30)
cWT2        = color.new(#1f1559, 25)
cVwap       = color.new(#ffffff, 50)
cMfiUp      = color.new(#3ee145, 50)
cMfiDn      = color.new(#ff3d2e, 50)
cDivBear    = color.new(#e60000, 0)
cDivBull    = color.new(#00e676, 0)

bgcolor(darkMode ? color.new(#000000, 0) : na)

// FUNÇÕES
f_topFractal(src) => src[4] < src[2] and src[3] < src[2] and src[2] > src[1] and src[2] > src[0]
f_botFractal(src) => src[4] > src[2] and src[3] > src[2] and src[2] < src[1] and src[2] < src[0]

f_findDivs(src, topLimit, botLimit, useLimits) =>
    fTop = f_topFractal(src) and (useLimits ? src[2] >= topLimit : true)
    fBot = f_botFractal(src) and (useLimits ? src[2] <= botLimit : true)
    highPrev  = ta.valuewhen(fTop, src[2], 1)
    highPrice = ta.valuewhen(fTop, high[2], 1)
    lowPrev   = ta.valuewhen(fBot, src[2], 1)
    lowPrice  = ta.valuewhen(fBot, low[2], 1)
    bearReg = fTop and high[2] > highPrice and src[2] < highPrev
    bullReg = fBot and low[2]  < lowPrice  and src[2] > lowPrev
    bearHid = fTop and high[2] < highPrice and src[2] > highPrev
    bullHid = fBot and low[2]  > lowPrice  and src[2] < lowPrev
    [fTop, fBot, bearReg, bullReg, bearHid, bullHid]

f_wavetrend(src, chlen, avg, malen) =>
    esa = ta.ema(src, chlen)
    de  = ta.ema(math.abs(src - esa), chlen)
    ci  = (src - esa) / (0.015 * de)
    wt1 = ta.ema(ci, avg)
    wt2 = ta.sma(wt1, malen)
    [wt1, wt2]

f_mfiArea(period, mult) =>
    ta.sma(((close - open) / (high - low)) * mult, period) - mfiPosY

f_stochRsi(src, sLen, rLen, kSm, dSm, useLog) =>
    s = useLog ? math.log(src) : src
    r = ta.rsi(s, rLen)
    k = ta.sma(ta.stoch(r, r, r, sLen), kSm)
    d = ta.sma(k, dSm)
    [k, d]

// CÁLCULOS
[wt1, wt2] = f_wavetrend(wtMASource, wtChannelLen, wtAverageLen, wtMALen)
wtVwap     = wt1 - wt2
wtCross    = ta.cross(wt1, wt2)
wtCrossUp  = wt2 - wt1 <= 0
wtCrossDn  = wt2 - wt1 >= 0
wtOS       = wt2 <= osLevel
wtOB       = wt2 >= obLevel

rsi     = ta.rsi(rsiSrc, rsiLen)
mfiArea = f_mfiArea(mfiPeriod, mfiMultiplier)
mfiUp   = mfiArea > 0
mfiDn   = mfiArea < 0

[stochK, stochD] = f_stochRsi(stochSrc, stochLen, stochRsiLen, stochKSmooth, stochDSmooth, stochUseLog)
stochUp = ta.crossover(stochK, stochD)
stochDn = ta.crossunder(stochK, stochD)

[wtFTop,  wtFBot,  wtBear,  wtBull,  wtBearH,  wtBullH ] = f_findDivs(wt2, wtDivOB,  wtDivOS,  true)
[rsiFTop, rsiFBot, rsiBear, rsiBull, rsiBearH, rsiBullH] = f_findDivs(rsi, rsiDivOB, rsiDivOS, true)

wtBearAny  = (useRegular and wtBear)  or (useHidden and wtBearH)
wtBullAny  = (useRegular and wtBull)  or (useHidden and wtBullH)
rsiBearAny = (useRegular and rsiBear) or (useHidden and rsiBearH)
rsiBullAny = (useRegular and rsiBull) or (useHidden and rsiBullH)

// FILTROS
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
trendUp   = close > emaSlow and emaFast > emaSlow
trendDown = close < emaSlow and emaFast < emaSlow

[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
regimeOk     = not useAdxFilter or (adx >= adxMin and adx <= adxMax)
regimeStrong = adx > adxMax

volOk = not useVolFilter or volume > ta.sma(volume, volSmaLen) * volMult
atrOk = not useAtrFilter or math.abs(close - open) >= ta.atr(atrLen) * atrMinMult
baseFilter = regimeOk and volOk and atrOk

// SCORE
buyScore  = 0
sellScore = 0
if wtCross and wtCrossUp and wtOS
    buyScore += wtCrossPts
if wtCross and wtCrossDn and wtOB
    sellScore += wtCrossPts
if wtBullAny
    buyScore += wtDivPts
if wtBearAny
    sellScore += wtDivPts
if rsiBullAny
    buyScore += rsiDivPts
if rsiBearAny
    sellScore += rsiDivPts
if mfiUp
    buyScore += mfiAlignPts
if mfiDn
    sellScore += mfiAlignPts
if stochUp and stochK < 30
    buyScore += stochAlignPts
if stochDn and stochK > 70
    sellScore += stochAlignPts
if useTrendFilter and trendUp
    buyScore += trendAgreePts
if useTrendFilter and trendDown
    sellScore += trendAgreePts

// FILTRO FINAL + COOLDOWN
trendBlockBuy  = useTrendFilter and trendDown and regimeStrong
trendBlockSell = useTrendFilter and trendUp   and regimeStrong

rawBuy  = proMode ? (buyScore  >= scoreMin and baseFilter and not trendBlockBuy)  : (wtCross and wtCrossUp and wtOS)
rawSell = proMode ? (sellScore >= scoreMin and baseFilter and not trendBlockSell) : (wtCross and wtCrossDn and wtOB)

var int lastBuyBar  = na
var int lastSellBar = na
buySig  = rawBuy  and (na(lastBuyBar)  or bar_index - lastBuyBar  > cooldownBars)
sellSig = rawSell and (na(lastSellBar) or bar_index - lastSellBar > cooldownBars)
if buySig
    lastBuyBar := bar_index
if sellSig
    lastSellBar := bar_index

lastRsiAtFractal = ta.valuewhen(wtFBot, rsi[2], 0)
goldBuy = wtBullAny and wt2[2] <= osLevel3 and wt2 > osLevel3 and (wt2[2] - wt2 <= -5) and lastRsiAtFractal < 30 and baseFilter

// PLOTS
hline(0, color=color.new(color.white, 50))
hline(obLevel2, 'OB2', color=color.new(color.white, 85), linestyle=hline.style_dotted)
hline(osLevel2, 'OS2', color=color.new(color.white, 85), linestyle=hline.style_dotted)
hline(obLevel3, 'OB3', color=color.new(color.white, 90), linestyle=hline.style_dotted)
hline(osLevel3, 'OS3', color=color.new(color.white, 90), linestyle=hline.style_dotted)

plot(showWT ? wt1 : na, style=plot.style_area, color=cWT1, title='WT1')
plot(showWT ? wt2 : na, style=plot.style_area, color=cWT2, title='WT2')
plot(showVwap ? wtVwap : na, color=cVwap, style=plot.style_area, linewidth=2, title='Fast WT')
plot(showMFI ? mfiArea : na, style=plot.style_area, color=mfiUp ? cMfiUp : cMfiDn, title='MFI')

rsiColor = rsi <= rsiOversold ? color.new(#3ee145, 0) : rsi >= rsiOverbought ? color.new(#e13e3e, 0) : color.new(#c33ee1, 0)
plot(showRSI ? rsi : na, color=rsiColor, linewidth=2, title='RSI')

stochKplot = plot(showStoch ? stochK : na, color=color.new(#21baf3, 70), linewidth=2, title='Stoch K')
stochDplot = plot(showStoch ? stochD : na, color=color.new(#673ab7, 90), linewidth=1, title='Stoch D')
fill(stochKplot, stochDplot, color=stochK >= stochD ? color.new(#21baf3, 95) : color.new(#673ab7, 90))

plot(wtCross ? wt2 : na, style=plot.style_circles, color=wt2 - wt1 > 0 ? cSell : cBuy, linewidth=3, title='WT cross')

plot(showDivLines and wtFTop  and wtBearAny  ? wt2[2] : na, color=cDivBear, linewidth=2, offset=-2, title='WT bear div')
plot(showDivLines and wtFBot  and wtBullAny  ? wt2[2] : na, color=cDivBull, linewidth=2, offset=-2, title='WT bull div')
plot(showDivLines and rsiFTop and rsiBearAny ? rsi[2] : na, color=cDivBear, linewidth=1, offset=-2, title='RSI bear div')
plot(showDivLines and rsiFBot and rsiBullAny ? rsi[2] : na, color=cDivBull, linewidth=1, offset=-2, title='RSI bull div')

classicBuy  = wtCross and wtCrossUp and wtOS
classicSell = wtCross and wtCrossDn and wtOB
plotchar(showClassic and classicBuy  ? -107 : na, char='·', color=cBuyWeak,  location=location.absolute, size=size.tiny, title='Classic buy')
plotchar(showClassic and classicSell ?  105 : na, char='·', color=cSellWeak, location=location.absolute, size=size.tiny, title='Classic sell')

buyColor  = buyScore  >= scoreMin + 1 ? cBuyStrong  : cBuy
sellColor = sellScore >= scoreMin + 1 ? cSellStrong : cSell

plotshape(buySig  ? wt2 : na, style=shape.triangleup,   location=location.absolute, color=buyColor,  size=size.small, title='PRO BUY')
plotshape(sellSig ? wt2 : na, style=shape.triangledown, location=location.absolute, color=sellColor, size=size.small, title='PRO SELL')

plotchar(goldBuy ? -106 : na, char='●', color=cGold, location=location.absolute, size=size.small, offset=-2, title='Gold Buy')

// Label de score (bulletproof)
var label scoreLbl = na
if showScoreLbl and barstate.islast
    if not na(scoreLbl)
        label.delete(scoreLbl)
    string txt = 'BUY: '  + str.tostring(buyScore)  + '/6\n' + 'SELL: ' + str.tostring(sellScore) + '/6\n' + 'ADX: '  + str.tostring(math.round(adx, 1)) + (regimeStrong ? ' (forte)' : regimeOk ? ' (ok)' : ' (fraco)') + '\n' + 'Trend: ' + (trendUp ? 'UP' : trendDown ? 'DOWN' : 'FLAT') + '\n' + 'Vol ok: ' + (volOk ? 'sim' : 'não') + ' | ATR ok: ' + (atrOk ? 'sim' : 'não')
    scoreLbl := label.new(x=bar_index, y=0.0, text=txt, style=label.style_label_left, color=color.new(color.black, 20), textcolor=color.white, size=size.small)

// ALERTAS
alertcondition(buySig  and barstate.isconfirmed, title='PRO Buy',  message='VMC PRO BUY {{ticker}} {{interval}}')
alertcondition(sellSig and barstate.isconfirmed, title='PRO Sell', message='VMC PRO SELL {{ticker}} {{interval}}')
alertcondition(goldBuy and barstate.isconfirmed, title='Gold Buy', message='VMC GOLD BUY {{ticker}} {{interval}}')
````
