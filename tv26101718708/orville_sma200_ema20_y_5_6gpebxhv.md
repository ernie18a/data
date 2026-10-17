# ORVILLE: SMA-200 + EMA-20 Y 5

- url: https://www.tradingview.com/script/6gPebxHv/
- type: indicator
- pine_id: PUB;68ed54674af54ebfad5bca52900c3ffd
- version: 2.0

## Description

Combinación de una SMA 200 con una EMA 20 y una EMA-5

## Source Code

````pine
//@version=6
indicator("ORV-SMA-EMA", overlay=true)

// ── Períodos (editables desde el panel) ──────────────────────
per_sma  = input.int(200, title="Período SMA",    minval=1)
per_ema1 = input.int(20,  title="Período EMA 1",  minval=1)
per_ema2 = input.int(5,   title="Período EMA 2",  minval=1)

// ── Activar / Desactivar ──────────────────────────────────────
show_sma  = input.bool(true, title="Mostrar SMA")
show_ema1 = input.bool(true, title="Mostrar EMA 1")
show_ema2 = input.bool(true, title="Mostrar EMA 2")

// ── Colores ───────────────────────────────────────────────────
col_sma  = input.color(color.blue,   title="Color SMA")
col_ema1 = input.color(color.white,  title="Color EMA 1")
col_ema2 = input.color(color.yellow, title="Color EMA 2")

// ── Grosor ───────────────────────────────────────────────────
width_sma  = input.int(2, title="Grosor SMA",   minval=1, maxval=4)
width_ema1 = input.int(1, title="Grosor EMA 1", minval=1, maxval=4)
width_ema2 = input.int(1, title="Grosor EMA 2", minval=1, maxval=4)

// ── Cálculo ───────────────────────────────────────────────────
sma  = ta.sma(close, per_sma)
ema1 = ta.ema(close, per_ema1)
ema2 = ta.ema(close, per_ema2)

// ── Plot ──────────────────────────────────────────────────────
plot(show_sma  ? sma  : na, title="SMA",   color=col_sma,  linewidth=width_sma)
plot(show_ema1 ? ema1 : na, title="EMA 1", color=col_ema1, linewidth=width_ema1)
plot(show_ema2 ? ema2 : na, title="EMA 2", color=col_ema2, linewidth=width_ema2)
````
