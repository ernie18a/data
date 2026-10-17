# FP - SMA Crossover + Regime + Hold Filter

- url: https://www.tradingview.com/script/mmvcdSob/
- type: indicator
- pine_id: PUB;c9aaa45b75e94090b920d807db786735
- version: 1.0

## Description

This indicator is the visual implementation of Strategy 270, one of the top-performing systems from my quantitative backtesting pipeline (XAUUSD H1, walk-forward OOS validation).
What it does
It identifies high-probability long entries using a three-layer confirmation system, and manages exits with a dual grace period that prevents premature closes during pullbacks within a healthy trend.
Entry conditions (all must be true):

SMA Fast (15) crosses above SMA Slow (200) — trend shift confirmed
Price is above the Regime SMA (200) — macro structure is bullish
Price is at least 0.61% above EMA200 — minimum distance from the mean, filters low-conviction setups near the line

Exit logic — two layers:

Layer 1: SMA15 crosses below SMA200, OR price has been below the Regime SMA for N consecutive bars (grace_bars = 8)
Layer 2: If the exit trigger is caused by being below the regime (not a clean crossunder), the system waits for a second confirmation window (grace_bars_2 = 12) before closing. This eliminates false exits on brief pullbacks.

Minimum hold filter:
No exit is allowed during the first 96 bars after entry (4 days on H1). This comes directly from trade analysis: in backtesting, trades closed before 96 bars had a win rate near 0% and destroyed net P&L. Trades held between 8 and 20 days showed 73% win rate. The yellow dot marks the moment the hold lock is released — from that bar onward, exits are active.
Visual elements:

🟢 Green triangle below bar — long entry signal
🔴 Red triangle above bar — exit signal
🟡 Yellow dot — hold period unlocked (exits now active)
Green background — position is open
Lines: SMA15 (orange), SMA200 (blue), EMA200 (purple dashed), Regime SMA (gray)

Three built-in alerts: entry, exit, and hold unlock.
Recommended timeframe: H1. All parameters are adjustable from the inputs panel — the defaults match the optimized backtest configuration.
This indicator does not repaint. Entry and exit signals are generated on bar close.

## Source Code

````pine
// This Pine Script® code is subject to the Mozilla Public License 2.0
// © FranPineda — El Monje de los Mercados
// strategy_270_indicator.pine
//
// Indicador visual de strategy_270:
//   SMA Crossover (15/200) + Régimen + EMA200 gate + doble grace period + min_hold_bars
//   Flecha VERDE = entrada | Flecha ROJA = salida | Fondo = posición activa
//   Los parámetros coinciden con los DEFAULTS optimizados del backtest.

//@version=5
indicator("FP - Strategy 270", shorttitle="FP-S270", overlay=true, max_bars_back=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
grp_emas   = "Medias Móviles"
grp_fil    = "Filtros de Entrada"
grp_exit   = "Lógica de Salida"
grp_vis    = "Visual"

fast_len    = input.int(15,     "SMA Rápida",            minval=2,    group=grp_emas)
slow_len    = input.int(200,    "SMA Lenta",             minval=10,   group=grp_emas)
regime_len  = input.int(200,    "SMA Régimen",           minval=10,   group=grp_emas)

ema200_thr  = input.float(0.61, "EMA200 Dist Mín (%)",  step=0.01,   group=grp_fil,
              tooltip="El precio debe estar al menos X% por encima del EMA200 para entrar.")

grace1      = input.int(8,      "Grace Barras (Cap.1)",  minval=1,    group=grp_exit,
              tooltip="Barras consecutivas bajo régimen para activar señal de salida.")
grace2      = input.int(12,     "Grace Barras (Cap.2)",  minval=1,    group=grp_exit,
              tooltip="Si la salida es por estar bajo régimen, espera N barras adicionales.")
min_hold    = input.int(96,     "Min Hold Barras",       minval=1,    group=grp_exit,
              tooltip="Bloquea cualquier salida durante los primeros N bars. 96 = 4 días en H1.")

show_sma_f  = input.bool(true,  "Mostrar SMA Rápida",                 group=grp_vis)
show_lines  = input.bool(true,  "Mostrar SMA Lenta + EMA200",         group=grp_vis)
show_bg     = input.bool(true,  "Fondo posición activa",              group=grp_vis)


// ─── INDICADORES ──────────────────────────────────────────────────────────────
sma_f  = ta.sma(close, fast_len)
sma_s  = ta.sma(close, slow_len)
sma_r  = ta.sma(close, regime_len)
ema200 = ta.ema(close, 200)

ema_dist_pct = (close - ema200) / ema200 * 100


// ─── CONDICIONES BASE ─────────────────────────────────────────────────────────
bull_regime = close > sma_r
ema_ok      = ema_dist_pct > ema200_thr
cross_up    = ta.crossover(sma_f, sma_s)
cross_dn    = ta.crossunder(sma_f, sma_s)


// ─── LÓGICA DE SALIDA (doble grace period) ────────────────────────────────────
below_int = close < sma_r ? 1 : 0
sum1      = math.sum(below_int, grace1)
sum2      = math.sum(below_int, grace2)

// Capa 1: exit por cruce bajista o N barras seguidas bajo régimen
exit_raw      = cross_dn or (sum1 >= grace1)

// Capa 2: si el exit es por estar bajo régimen, requiere grace2 barras consecutivas
exit_above    = exit_raw and not (close < sma_r)           // exit por cruce: inmediato
exit_bel_ok   = exit_raw and (close < sma_r) and (sum2 >= grace2)  // exit bajo régimen: tardío
exits_base    = exit_above or exit_bel_ok


// ─── SEÑAL DE ENTRADA PURA ────────────────────────────────────────────────────
entry_raw = cross_up and bull_regime and ema_ok


// ─── STATE MACHINE — min_hold_bars ────────────────────────────────────────────
var bool in_pos  = false
var int  entry_b = 0

bool do_entry = false
bool do_exit  = false

if not in_pos
    if entry_raw
        do_entry := true
else
    bars_held = bar_index - entry_b
    if bars_held >= min_hold and exits_base
        do_exit := true

if do_entry
    in_pos  := true
    entry_b := bar_index

if do_exit
    in_pos := false


// ─── PLOTS DE LÍNEAS ──────────────────────────────────────────────────────────
plot(show_sma_f ? sma_f  : na, "SMA Rápida",  color=color.new(color.orange, 0),   linewidth=1)
plot(show_lines ? sma_s  : na, "SMA Lenta",   color=color.new(color.blue, 20),    linewidth=2)
plot(show_lines ? ema200 : na, "EMA 200",     color=color.new(color.purple, 20),  linewidth=1, style=plot.style_linebr)
plot(show_lines ? sma_r  : na, "SMA Régimen", color=color.new(color.gray, 50),    linewidth=1, style=plot.style_line)


// ─── FONDO DE POSICIÓN ACTIVA ─────────────────────────────────────────────────
bgcolor(show_bg and in_pos ? color.new(color.green, 90) : na, title="Posición activa")


// ─── FLECHAS DE ENTRADA Y SALIDA ──────────────────────────────────────────────
plotshape(do_entry,
  title    = "ENTRADA",
  style    = shape.triangleup,
  location = location.belowbar,
  color    = color.new(color.lime, 0),
  size     = size.normal,
  text     = "L",
  textcolor= color.white)

plotshape(do_exit,
  title    = "SALIDA",
  style    = shape.triangledown,
  location = location.abovebar,
  color    = color.new(color.red, 0),
  size     = size.normal,
  text     = "X",
  textcolor= color.white)


// ─── BARRA DE HOLD PROGRESS (info visual) ─────────────────────────────────────
// Marca con un punto cuando se cumplen los min_hold_bars (ya puede salir)
bars_in_now  = in_pos ? bar_index - entry_b : 0
unlock_bar   = in_pos and bars_in_now == min_hold
plotshape(unlock_bar,
  title    = "Hold desbloqueado",
  style    = shape.circle,
  location = location.belowbar,
  color    = color.new(color.yellow, 30),
  size     = size.tiny)


// ─── ALERTAS ──────────────────────────────────────────────────────────────────
alertcondition(do_entry, title="S270 — ENTRADA LONG",  message="Strategy 270 | ENTRADA LONG | {{ticker}} {{interval}}")
alertcondition(do_exit,  title="S270 — SALIDA",        message="Strategy 270 | SALIDA | {{ticker}} {{interval}}")
alertcondition(unlock_bar, title="S270 — Hold desbloqueado", message="Strategy 270 | Hold desbloqueado — ya puede salir | {{ticker}}")
````
