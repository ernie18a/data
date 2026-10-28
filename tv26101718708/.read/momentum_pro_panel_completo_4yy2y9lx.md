# Momentum PRO - Panel Completo

- url: https://www.tradingview.com/script/4yY2Y9lX/
- type: indicator
- pine_id: PUB;537024445fa845079b03b8e4f5dcc1e0
- version: 1.0

## Description

Erosteko seinaleak emoten dau Indikadore honek. Erabili SP500 gorantza doanean bakarrik. Ondoen funzionaten dauen akzinoak honeek direz: NVDA, PLTR, TSLA eta AMD. Erosi BUY seinalean + score >=4 + Mercado alcista.

## Source Code

````pine
//@version=5
indicator("Momentum PRO - Panel Completo", overlay=true)

// =====================
// INPUTS
// =====================
mode = input.string("Balanceado", options=["Conservador", "Balanceado", "Agresivo"])
sp500 = input.symbol("SPX", "Benchmark")

// =====================
// MERCADO GLOBAL
// =====================
spClose = request.security(sp500, timeframe.period, close)
spEMA50 = request.security(sp500, timeframe.period, ta.ema(close, 50))
marketBull = spClose > spEMA50
marketText = marketBull ? "ALCISTA" : "BAJISTA"

// =====================
// FUNCIÓN
// =====================
f_signal(sym) =>
    close_ = request.security(sym, timeframe.period, close)
    ema20_ = request.security(sym, timeframe.period, ta.ema(close, 20))
    ema50_ = request.security(sym, timeframe.period, ta.ema(close, 50))
    rsi_ = request.security(sym, timeframe.period, ta.rsi(close, 14))
    [macd_, signal_, _] = request.security(sym, timeframe.period, ta.macd(close, 12, 26, 9))
    vol_ = request.security(sym, timeframe.period, volume)
    volAvg_ = request.security(sym, timeframe.period, ta.sma(volume, 20))

    volCond = vol_ > volAvg_

    score = 0
    score += close_ > ema50_ ? 1 : 0
    score += ema20_ > ema50_ ? 1 : 0
    score += macd_ > signal_ ? 1 : 0
    score += rsi_ > 55 ? 1 : 0
    score += volCond ? 1 : 0

    base = close_ > ema50_ and ema20_ > ema50_ and marketBull

    buy = false
    sell = false

    if mode == "Conservador"
        buy := base and score >= 4 and rsi_ > 60
    if mode == "Balanceado"
        buy := base and score >= 3 and rsi_ > 55
    if mode == "Agresivo"
        buy := base and score >= 2 and rsi_ > 50

    sell := (ema20_ < ema50_) or (rsi_ < 50)

    buySignal = buy and not buy[1]
    sellSignal = sell and not sell[1]

    [buy, sell, buySignal, sellSignal, score]

// =====================
// GRÁFICO ACTUAL
// =====================
[chartBuy, chartSell, chartBuySignal, chartSellSignal, chartScore] = f_signal(syminfo.ticker)

plotshape(chartBuySignal, location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(chartSellSignal, location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// =====================
// ACCIONES
// =====================
[nvdaBuy, nvdaSell, _, _, nvdaScore] = f_signal("NVDA")
[tslaBuy, tslaSell, _, _, tslaScore] = f_signal("TSLA")
[pltrBuy, pltrSell, _, _, pltrScore] = f_signal("PLTR")
[amdBuy, amdSell, _, _, amdScore] = f_signal("AMD")

// =====================
// TEXTO
// =====================
f_text(buy, sell) =>
    buy ? "COMPRAR" : sell ? "VENDER" : "ESPERAR"

// =====================
// PANEL
// =====================
var table panel = table.new(position.top_right, 3, 7)

if barstate.islast
    // Cabecera
    table.cell(panel, 0, 0, "Acción")
    table.cell(panel, 1, 0, "Estado")
    table.cell(panel, 2, 0, "Score")

    // NVDA
    table.cell(panel, 0, 1, "NVDA")
    table.cell(panel, 1, 1, f_text(nvdaBuy, nvdaSell))
    table.cell(panel, 2, 1, str.tostring(nvdaScore))

    // TSLA
    table.cell(panel, 0, 2, "TSLA")
    table.cell(panel, 1, 2, f_text(tslaBuy, tslaSell))
    table.cell(panel, 2, 2, str.tostring(tslaScore))

    // PLTR
    table.cell(panel, 0, 3, "PLTR")
    table.cell(panel, 1, 3, f_text(pltrBuy, pltrSell))
    table.cell(panel, 2, 3, str.tostring(pltrScore))

    // AMD
    table.cell(panel, 0, 4, "AMD")
    table.cell(panel, 1, 4, f_text(amdBuy, amdSell))
    table.cell(panel, 2, 4, str.tostring(amdScore))

    // Info global
    table.cell(panel, 0, 5, "Modo")
    table.cell(panel, 1, 5, mode)

    table.cell(panel, 0, 6, "Mercado")
    table.cell(panel, 1, 6, marketText)
    // =====================
// ALERTA COMBINADA (CONDICIÓN FINAL)
// =====================
strongBuy = chartBuySignal and chartScore >= 4 and marketBull

alertcondition(
     strongBuy,
     title="STRONG BUY SETUP",
     message="BUY fuerte: mercado alcista + score ≥4 + señal BUY")
````
