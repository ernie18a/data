# ORV-SMA200 y EMA 20 + 5

- url: https://www.tradingview.com/script/B6erVOfB/
- type: indicator
- pine_id: PUB;e000d20d9311411790e5ac29968733a1
- version: 1.0

## Description

Para Swing Trading,  esta combinación ayuda a una entrada mas limpia, combinando una  SMA200 con una EMA20 y una EMA5, si la EMA 5 cruza la 20 hacia arriba es señal de compra y al contrario de venda, la SMA200 sirve como indicador de tendencia macro

## Source Code

````pine
//@version=6
indicator("ORV-SMA-EMA", overlay=true)

// ── Activar / Desactivar ──────────────────────────────────────
show_sma200 = input.bool(true,  title="Mostrar SMA 200")
show_ema20  = input.bool(true,  title="Mostrar EMA 20")
show_ema5   = input.bool(true,  title="Mostrar EMA 5")

// ── Colores (modificables desde el panel) ────────────────────
col_sma200 = input.color(color.blue,   title="Color SMA 200")
col_ema20  = input.color(color.white,  title="Color EMA 20")
col_ema5   = input.color(color.yellow, title="Color EMA 5")

// ── Grosor de línea ──────────────────────────────────────────
width_sma200 = input.int(2, title="Grosor SMA 200", minval=1, maxval=4)
width_ema20  = input.int(1, title="Grosor EMA 20",  minval=1, maxval=4)
width_ema5   = input.int(1, title="Grosor EMA 5",   minval=1, maxval=4)

// ── Cálculo ──────────────────────────────────────────────────
sma200 = ta.sma(close, 200)
ema20  = ta.ema(close, 20)
ema5   = ta.ema(close, 5)

// ── Plot ─────────────────────────────────────────────────────
plot(show_sma200 ? sma200 : na, title="SMA 200", color=col_sma200, linewidth=width_sma200)
plot(show_ema20  ? ema20  : na, title="EMA 20",  color=col_ema20,  linewidth=width_ema20)
plot(show_ema5   ? ema5   : na, title="EMA 5",   color=col_ema5,   linewidth=width_ema5)
````
