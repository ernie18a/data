# indicador maverick

- url: https://www.tradingview.com/script/fpaT8zAo/
- type: indicator
- pine_id: PUB;b0cd1ca794764674b8800c71310b016e
- version: 1.0

## Description

indicador feito para ajudar na sua analise no trading. sempre faça uma avaliação previa

## Source Code

````pine
//@version=5
indicator("Dark Money GN50 PRO", overlay=true, max_labels_count=500)

// ==========================
// 🔧 CONFIGURAÇÕES
// ==========================
usarLondres = input.bool(true, "Ativar Sessão Londres")
usarNY = input.bool(true, "Ativar Sessão NY")

sessaoLondres = input.session("0300-0600", "Londres")
sessaoNY = input.session("0800-1100", "New York")

periodoLiquidez = input.int(10, "Período Liquidez", minval=5)

// ==========================
// ⏰ FILTRO DE SESSÃO
// ==========================
emLondres = not na(time(timeframe.period, sessaoLondres))
emNY = not na(time(timeframe.period, sessaoNY))

sessaoAtiva = (usarLondres and emLondres) or (usarNY and emNY)

// ==========================
// 💧 LIQUIDEZ (SWEEP)
// ==========================
topoAnterior = ta.highest(high, periodoLiquidez)[1]
fundoAnterior = ta.lowest(low, periodoLiquidez)[1]

sweepTopo = high > topoAnterior and close < topoAnterior
sweepFundo = low < fundoAnterior and close > fundoAnterior

// ==========================
// 🔶 FORÇA DA VELA
// ==========================
corpo = math.abs(close - open)
faixa = high - low   // <-- nome corrigido (era "range")

velaForteAlta = close > open and corpo > faixa * 0.6
velaForteBaixa = close < open and corpo > faixa * 0.6

// ==========================
// 🎯 SINAIS DARK MONEY
// ==========================
sinalCompra = sweepFundo and velaForteAlta and sessaoAtiva
sinalVenda = sweepTopo and velaForteBaixa and sessaoAtiva

// ==========================
// 🎨 COLORAÇÃO
// ==========================
barcolor(sinalCompra or sinalVenda ? color.yellow : na)

// ==========================
// 📊 INFORMAÇÕES
// ==========================
ativo = syminfo.ticker
tf = timeframe.period

// ==========================
// 🔔 ALERTA
// ==========================
alertcondition(sinalCompra or sinalVenda,
     title="SINAL DARK MONEY GN50",
     message="⚠️ SINAL no {{ticker}} | TF: {{interval}}")

// ==========================
// 🏷️ LABEL
// ==========================
if sinalCompra
    label.new(bar_index, low,
     "🟢 COMPRA\n" + ativo + "\nTF: " + tf,
     style=label.style_label_up,
     color=color.yellow,
     textcolor=color.black)

if sinalVenda
    label.new(bar_index, high,
     "🔴 VENDA\n" + ativo + "\nTF: " + tf,
     style=label.style_label_down,
     color=color.yellow,
     textcolor=color.black)

// ==========================
// 🎯 SETAS VISUAIS
// ==========================
plotshape(sinalCompra, title="Compra", location=location.belowbar, style=shape.triangleup, size=size.small, color=color.green)
plotshape(sinalVenda, title="Venda", location=location.abovebar, style=shape.triangledown, size=size.small, color=color.red)
````
