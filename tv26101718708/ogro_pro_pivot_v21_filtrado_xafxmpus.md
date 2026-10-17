# OGRO PRO PIVOT v2.1 FILTRADO

- url: https://www.tradingview.com/script/xAfxmpuS/
- type: indicator
- pine_id: PUB;27efee01ad6f472288ea36344f048f65
- version: 1.0

## Description

Identifica pivots com a Entrada para compra e venda

## Source Code

````pine
//@version=5
indicator("OGRO PRO PIVOT v2.1 FILTRADO", overlay=true, max_labels_count=500)

//=========================
// 🔹 CONFIGURAÇÕES
//=========================
length = input.int(50, "Pivot Length")
modo = input.string("Agressivo", options=["Agressivo", "Moderado"])

usarEMA200   = input.bool(true, "Filtro EMA 200")
distMinEMA   = input.float(0.2, "Distância mínima da EMA (%)", step=0.1) / 100.0

usarReteste  = input.bool(true, "Exigir Reteste")
cooldownBars = input.int(5, "Cooldown (barras)")

ativarCompra = input.bool(true, "Alerta Compra")
ativarVenda  = input.bool(true, "Alerta Venda")

tpPerc = input.float(0.5, "Take Profit (%)") / 100
slPerc = input.float(0.3, "Stop Loss (%)") / 100

//=========================
// 🔹 BASE PIVOT
//=========================
ph = ta.pivothigh(length, length)
pl = ta.pivotlow(length, length)

// guardar último pivot válido
var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

//=========================
// 🔹 EMA 200 + DISTÂNCIA
//=========================
ema200 = ta.ema(close, 200)
tendAlta  = close > ema200
tendBaixa = close < ema200

distEMA = math.abs(close - ema200) / ema200
filtroDist = distEMA > distMinEMA

//=========================
// 🔹 ESTRUTURA (HH / LL)
//=========================
hh = not na(lastPH) and high > lastPH     // rompe topo anterior
ll = not na(lastPL) and low  < lastPL     // rompe fundo anterior

//=========================
// 🔹 LIQUIDEZ REAL (SWEEP)
// precisa romper e voltar (rejeição)
//=========================
liqSell = hh and close < lastPH and close < open   // varreu topo e rejeitou
liqBuy  = ll and close > lastPL and close > open   // varreu fundo e rejeitou

//=========================
// 🔹 RETESTE (opcional)
//=========================
retesteSell = high >= lastPH and close < open
retesteBuy  = low  <= lastPL and close > open

//=========================
// 🔹 MODOS
//=========================
buyAgressivo  = liqBuy
sellAgressivo = liqSell

buyModerado  = not na(pl)
sellModerado = not na(ph)

buyBase  = modo == "Agressivo" ? buyAgressivo : buyModerado
sellBase = modo == "Agressivo" ? sellAgressivo : sellModerado

//=========================
// 🔹 FILTROS FINAIS
//=========================
buySignal  = buyBase
sellSignal = sellBase

// EMA + distância (evita lateral)
if usarEMA200
    buySignal  := buySignal and tendAlta and filtroDist
    sellSignal := sellSignal and tendBaixa and filtroDist

// reteste
if usarReteste
    buySignal  := buySignal and retesteBuy
    sellSignal := sellSignal and retesteSell

//=========================
// 🔹 BLOQUEIO DE REPETIÇÃO + COOLDOWN
//=========================
var int lastDir = 0   // 1 buy, -1 sell
var int lastBar = na

canTrade = na(lastBar) or (bar_index - lastBar > cooldownBars)

finalBuy  = buySignal  and lastDir != 1  and canTrade
finalSell = sellSignal and lastDir != -1 and canTrade

if finalBuy
    lastDir := 1
    lastBar := bar_index

if finalSell
    lastDir := -1
    lastBar := bar_index

//=========================
// 🔹 VISUAL
//=========================
plotshape(finalBuy,  title="BUY",  location=location.belowbar, color=color.green, style=shape.labelup,   text="BUY")
plotshape(finalSell, title="SELL", location=location.abovebar, color=color.red,   style=shape.labeldown, text="SELL")

plot(ema200, color=color.orange)

//=========================
// 🔹 CONTROLE DE TRADE
//=========================
var float entryPrice = na
var int direction  = 0
var int wins = 0
var int losses = 0
var int total = 0

if finalBuy and direction == 0
    entryPrice := close
    direction := 1

if finalSell and direction == 0
    entryPrice := close
    direction := -1

takeProfit = direction == 1 ? entryPrice * (1 + tpPerc) : entryPrice * (1 - tpPerc)
stopLoss   = direction == 1 ? entryPrice * (1 - slPerc) : entryPrice * (1 + slPerc)

if direction != 0
    winCond  = (direction == 1 and high >= takeProfit) or (direction == -1 and low <= takeProfit)
    lossCond = (direction == 1 and low <= stopLoss) or (direction == -1 and high >= stopLoss)

    if winCond
        wins += 1
        total += 1
        direction := 0
    else if lossCond
        losses += 1
        total += 1
        direction := 0

winrate = total > 0 ? (wins / total) * 100 : 0

//=========================
// 🔹 PAINEL (inferior esquerdo)
//=========================
var table painel = table.new(position.bottom_left, 1, 5)

if barstate.islast
    table.cell(painel, 0, 0, "OGRO PRO v2.1", text_color=color.white, bgcolor=color.black)
    table.cell(painel, 0, 1, "Trades: " + str.tostring(total), text_color=color.white)
    table.cell(painel, 0, 2, "Wins: " + str.tostring(wins), text_color=color.green)
    table.cell(painel, 0, 3, "Losses: " + str.tostring(losses), text_color=color.red)
    table.cell(painel, 0, 4, "Winrate: " + str.tostring(winrate, "#.##") + "%", text_color=color.yellow)

//=========================
// 🔹 ALERTAS
//=========================
alertcondition(finalBuy and ativarCompra,  title="BUY OGRO",  message="COMPRA OGRO PRO (FILTRADO)")
alertcondition(finalSell and ativarVenda, title="SELL OGRO", message="VENDA OGRO PRO (FILTRADO)")
````
