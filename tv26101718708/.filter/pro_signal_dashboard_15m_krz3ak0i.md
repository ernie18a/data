# PRO Signal Dashboard 15M

- url: https://www.tradingview.com/script/krz3AK0I/
- type: indicator
- pine_id: PUB;fe74f75cfd9448a6955d188cdc77e34e
- version: 1.0

## Description

Con este indicador podras ver y analizar movimientos

## Source Code

````pine
//@version=6
indicator("PRO Signal Dashboard 15M", overlay=true)

// =====================
// INPUTS
// =====================
sess = input.session("0930-1600", "Horario de trading")
inSession = not na(time(timeframe.period, sess))

// =====================
// INDICADORES BASE
// =====================
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
rsi = ta.rsi(close, 14)

volMA = ta.sma(volume, 20)
atr = ta.atr(14)
atrMA = ta.sma(atr, 20)

// =====================
// CONDICIONES
// =====================
trendBull = ema50 > ema200
trendBear = ema50 < ema200

momentumBull = rsi > 55
momentumBear = rsi < 45

volumeOK = volume > volMA
volatilityOK = atr > atrMA

// =====================
// SCORE SYSTEM
// =====================
bullScore = 0.0
bearScore = 0.0

bullScore += trendBull ? 35 : 0
bullScore += momentumBull ? 25 : 0
bullScore += volumeOK ? 20 : 0
bullScore += volatilityOK ? 20 : 0

bearScore += trendBear ? 35 : 0
bearScore += momentumBear ? 25 : 0
bearScore += volumeOK ? 20 : 0
bearScore += volatilityOK ? 20 : 0

// solo operar en horario
bullScore := inSession ? bullScore : 0
bearScore := inSession ? bearScore : 0

// =====================
// SEÑALES
// =====================
call = bullScore >= 80
put = bearScore >= 80

// =====================
// DASHBOARD
// =====================
var table t = table.new(position.top_right, 2, 6)

if barstate.islast
    table.cell(t, 0, 0, "SEÑAL", text_color=color.white)
    table.cell(t, 1, 0,
         call ? "🟢 CALL FUERTE" :
         put ? "🔴 PUT FUERTE" :
         "🟡 ESPERAR",
         text_color=color.white)

    table.cell(t, 0, 1, "CALL SCORE")
    table.cell(t, 1, 1, str.tostring(bullScore, "#"))

    table.cell(t, 0, 2, "PUT SCORE")
    table.cell(t, 1, 2, str.tostring(bearScore, "#"))

    table.cell(t, 0, 3, "RSI")
    table.cell(t, 1, 3, str.tostring(rsi, "#.0"))

    table.cell(t, 0, 4, "VOLUMEN")
    table.cell(t, 1, 4, volumeOK ? "ALTO" : "NORMAL")

    table.cell(t, 0, 5, "HORARIO")
    table.cell(t, 1, 5, inSession ? "ACTIVO" : "FUERA")

// =====================
// ALERTAS
// =====================
alertcondition(call, title="CALL", message="Señal CALL fuerte")
alertcondition(put, title="PUT", message="Señal PUT fuerte")

// =====================
// EMAs LIMPIAS
// =====================
plot(ema50, color=color.orange, linewidth=1)
plot(ema200, color=color.blue, linewidth=1)
````
