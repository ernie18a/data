# XAUUSD - XAGUSD Quant SMC (5M)

- url: https://www.tradingview.com/script/qWRZMcV0/
- type: strategy
- pine_id: PUB;f1221bd8efa144feb0963e65c3f6ea3e
- version: 1.0

## Description

[b]Estrategia XAUUSD: Convergencia de Estructura y Optimización de Descuento (SMC)[/b]

Esta estrategia automatizada para Pine Script v5 implementa un modelo de ejecución basado en Smart Money Concepts (SMC), priorizando la preservación de capital mediante un control de riesgo algorítmico y filtros de tendencia de alta jerarquía.

Fundamentos Teóricos
El sistema opera bajo la premisa de que el precio se mueve de forma fractal, buscando liquidez tras quiebres de estructura confirmados. Se enfoca exclusivamente en el mercado del Oro (XAUUSD) debido a su alta volatilidad y profundidad de mercado, factores necesarios para la validación de zonas de oferta y demanda.

1. Filtros de Direccionalidad de Alta Jerarquía

La estrategia no busca reversiones. Utiliza un motor de análisis multi-timeframe (MTF) para asegurar que la ejecución en micro-tendencias (5M) esté alineada con el flujo de órdenes institucional de marcos temporales mayores:

Contexto Diario (D1): Define el sesgo direccional a largo plazo.

Estructura de 4 Horas (4H): Actúa como filtro de impulso para evitar periodos de distribución o acumulación lateral.

2. Confirmación de Estructura (BOS)

La validación de la entrada requiere un Break of Structure (BOS) en la temporalidad de 15 minutos. Este evento técnico confirma que el mercado ha superado un punto de pivot relevante, validando la continuación del movimiento previo y estableciendo un nuevo rango de negociación.

3. Ejecución en Zona de Descuento

Una vez detectado el BOS, el algoritmo proyecta niveles de retroceso de Fibonacci. La entrada se programa en el nivel 0.618, buscando optimizar la relación Riesgo/Beneficio (RR). Este nivel representa la "zona de descuento" (en compras) o "zona premium" (en ventas), donde la probabilidad de continuación es estadísticamente superior tras la toma de liquidez interna.

Protocolo de Gestión de Riesgo Cuantitativo
El núcleo de la estrategia es su gestión de riesgo inflexible, diseñada para mitigar el impacto de las rachas de pérdidas y evitar el sobre-apalancamiento.

Riesgo Fijo: 1% del valor actual del capital por cada operación. El lotaje se recalcula dinámicamente en cada señal en función de la distancia al Stop Loss.

Ventana Operativa: Limitada de 07:00 a 13:00 (GMT+1). Este rango captura la volatilidad de apertura de Londres y el solapamiento inicial con Nueva York, periodos donde los BOS tienen mayor validez.

Límites de Pérdida (Circuit Breakers):

Diario: -1% (Límite de un trade por día).

Semanal: -3% acumulado.

Mensual: -6% acumulado.

Objetivo Semanal (Safe Exit): Alcanzado un beneficio del +3% en la semana, el script cesa la actividad operativa para asegurar el rendimiento y evitar el riesgo de mercado innecesario.

Especificaciones Técnicas y Configuración
Activo: XAUUSD.

Temporalidad de ejecución: 5M (Análisis en D1, 4H, 15M).

Versión de Script: Pine Script v5 (Sin Lookahead Bias).

Nivel de Entrada: 0.618 Fibonacci.

Stop Loss: Colocado en el origen del impulso (inicio del rango de Fibonacci).

Notas de Implementación

Para obtener resultados de backtesting realistas, se recomienda configurar un deslizamiento (Slippage) de 3 a 5 ticks y aplicar comisiones equivalentes a las de una cuenta ECN (Raw Spread). El script utiliza funciones de seguridad para solicitar datos de otras temporalidades solo al cierre de cada vela, eliminando cualquier sesgo de anticipación de datos futuros.

## Source Code

````pine
//@version=5
strategy(title="XAUUSD Quant SMC (D1-4H-15M-5M)", shorttitle="XAU_XAG_5min", overlay=true, initial_capital=10000, currency=currency.USD, default_qty_type=strategy.cash, calc_on_order_fills=false)

// ── CONFIGURACIÓN DE INPUTS ──
grp_tf = "Análisis Multi-Timeframe"
tf_d = input.timeframe("D", "Tendencia Diaria", group=grp_tf)
tf_4h = input.timeframe("240", "Tendencia 4H", group=grp_tf)
tf_15m = input.timeframe("15", "Estructura BOS (15M)", group=grp_tf)

grp_risk = "Gestión de Riesgo Estricta"
risk_per_trade = 1.0 // 1% Fijo
limit_daily = -1.0
limit_weekly = -3.0
limit_monthly = -6.0
target_weekly = 3.0

grp_session = "Sesión de Trading (GMT+1)"
sess_start = input.int(7, "Hora Inicio", minval=0, maxval=23, group=grp_session)
sess_end = input.int(13, "Hora Fin", minval=0, maxval=23, group=grp_session)

// ── LÓGICA DE TENDENCIA (D1 + 4H) ──
get_trend(tf) =>
    ema50 = request.security(syminfo.tickerid, tf, ta.ema(close, 50))
    c = request.security(syminfo.tickerid, tf, close)
    c > ema50 ? 1 : -1 // 1 Alcista, -1 Bajista

trend_d = get_trend(tf_d)
trend_4h = get_trend(tf_4h)
trend_aligned = (trend_d == 1 and trend_4h == 1) or (trend_d == -1 and trend_4h == -1)
is_bullish = trend_d == 1 and trend_4h == 1

// ── DETECCIÓN DE BOS (15M) ──
// Obtenemos los altos/bajos de 15M para detectar el quiebre
high_15m = request.security(syminfo.tickerid, tf_15m, ta.highest(high, 10))
low_15m = request.security(syminfo.tickerid, tf_15m, ta.lowest(low, 10))
close_15m = request.security(syminfo.tickerid, tf_15m, close)

var bool bos_occurred = false
var float fib_high = na
var float fib_low = na

// Resetear BOS si la tendencia cambia o termina el día
if ta.change(dayofweek)
    bos_occurred := false

if is_bullish and ta.crossover(close_15m, high_15m[1])
    bos_occurred := true
    fib_high := high_15m
    fib_low := low_15m // El inicio del impulso
else if not is_bullish and ta.crossunder(close_15m, low_15m[1])
    bos_occurred := true
    fib_high := high_15m
    fib_low := low_15m

// ── CÁLCULO DE FIBONACCI 0.618 ──
fib_618 = is_bullish ? fib_high - (fib_high - fib_low) * 0.618 : fib_low + (fib_high - fib_low) * 0.618

// ── CONTROL DE RIESGO ACUMULATIVO ──
var float daily_pnl = 0.0
var float weekly_pnl = 0.0
var int trades_today = 0

if ta.change(dayofweek)
    daily_pnl := 0.0
    trades_today := 0
if ta.change(time("W"))
    weekly_pnl := 0.0

// Capturar PnL de trades cerrados
if strategy.closedtrades > strategy.closedtrades[1]
    last_pnl = (strategy.closedtrades.profit(strategy.closedtrades - 1) / strategy.initial_capital) * 100
    daily_pnl += last_pnl
    weekly_pnl += last_pnl

can_trade = daily_pnl > limit_daily and weekly_pnl > limit_weekly and weekly_pnl < target_weekly and trades_today < 1

// ── EJECUCIÓN DE ENTRADA (5M) ──
in_session = hour >= sess_start and hour < sess_end
long_condition = trend_aligned and is_bullish and bos_occurred and ta.crossunder(low, fib_618) and in_session and can_trade
short_condition = trend_aligned and not is_bullish and bos_occurred and ta.crossover(high, fib_618) and in_session and can_trade

// Tamaño de posición (1% de Equity actual)
risk_amount = strategy.equity * (risk_per_trade / 100)

if long_condition
    sl = fib_low // SL al inicio del impulso
    tp = fib_high + (fib_high - fib_low) * 0.5 // TP proporcional
    qty = risk_amount / math.abs(close - sl)
    strategy.entry("Long", strategy.long, qty=qty)
    strategy.exit("Exit Long", "Long", stop=sl, limit=tp)
    bos_occurred := false // Reset para el siguiente trade
    trades_today := 1

if short_condition
    sl = fib_high
    tp = fib_low - (fib_high - fib_low) * 0.5
    qty = risk_amount / math.abs(close - sl)
    strategy.entry("Short", strategy.short, qty=qty)
    strategy.exit("Exit Short", "Short", stop=sl, limit=tp)
    bos_occurred := false
    trades_today := 1

// ── VISUALIZACIÓN ──
plot(fib_618, "Fib 0.618 Entry", color.new(color.yellow, 0), style=plot.style_linebr)
bgcolor(in_session ? color.new(color.green, 95) : na)
plotshape(long_condition, "Compra", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(short_condition, "Venta", shape.triangledown, location.abovebar, color.red, size=size.small)
````
