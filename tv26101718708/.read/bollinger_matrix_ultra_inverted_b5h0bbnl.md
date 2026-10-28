# Bollinger Matrix ULTRA inverted

- url: https://www.tradingview.com/script/B5h0BBnl-Bollinger-Matrix-ULTRA-inverted/
- type: strategy
- pine_id: PUB;8c34286d605a47869ba8efa64e1d5398
- version: 1.0

## Description

Strategy Title Suggestion: ### Bollinger Matrix ULTRA - Institutional Liquidity & Inverted Risk
Description:
Bollinger Matrix ULTRA is an advanced algorithmic mean-reversion engine designed for professional traders who seek to combine classical volatility indicators with Institutional Narrative (SMC/IPDA).

Unlike standard Bollinger Band strategies that "catch falling knives," this strategy utilizes a proprietary Liquidity Sweep logic to identify when the algorithm has neutralised retail liquidity before executing a high-precision matrix of orders.

🐊 Key Features:
Institutional Narrative Filter (HTF Trend): Aligns every trade with the higher-timeframe Order Flow using a customizable HTF EMA. It only buys when the institutional bias is bullish and sells when it's bearish.

Liquidity Sweep Entry (Neutralization): Instead of entering on a simple touch, the strategy waits for a "Sweep"—where price breaks the band (trapping retail) and closes back inside, confirming a return to efficiency.

The Matrix Logic: Instead of a single entry, the script deploys a "Matrix" of 7 layered orders. This allows for a better average price during volatility expansions.

Inverted Risk Model: A professional risk management approach where the largest volume is placed on the first (highest probability) entry, with decreasing lot sizes for deeper levels of the matrix.

Kapibara Time Engine: Integrated session filter (02:00 to 15:30) to capture London and New York volatility. At session end, the script automatically purges unfilled orders while protecting active trades with their original SL/TP.

ADX Range Filter: Ensures the matrix only operates during consolidation or corrective phases, avoiding "runaway" trends.

🚀 Automation Ready (PineConnector):
This strategy is fully optimized for PineConnector. The alerts are pre-formatted to send precise volume, stop loss, and take profit instructions directly to MetaTrader (MT4/5) for execution on brokers like Oanda.

How to Use:
Timeframe: Optimized for M1, M5, or M15.

HTF Filter: Set the HTF EMA to 1H if trading the M5, or 15m if trading the M1.

Risk: Set your "Total Matrix Risk ($)" in the settings. The script will automatically calculate the lot size for all 7 levels based on your Stop Loss pips.

Alerts: Set the alert message to {{strategy.order.comment}} for full automation.

## Source Code

````pine
//@version=5
strategy("Bollinger Matrix ULTRA - Kapibara Mentor Edition", overlay=true, pyramiding=15, initial_capital=1000)

// ========================================================================= //
// 0. CONFIGURACIÓN Y GESTIÓN DE RIESGO
// ========================================================================= //
grp_risk = "💰 Gestión de Capital"
pc_id    = input.string("TU_ID", "PineConnector ID", group=grp_risk)
riskCash = input.float(100.0, "Riesgo Total de la Matriz ($)", group=grp_risk)
invertLot = input.bool(true, "Invertir Lotaje (Mayor a Menor)", group=grp_risk)

grp_time  = "⏰ Filtro Horario Kapibara"
sessInput = input.session("0200-1530", "Ventana de Operativa (HHMM-HHMM)", group=grp_time)
// Comprobamos si estamos dentro del horario (usando el tiempo del intercambio/Exchange)
inSession = not na(time(timeframe.period, sessInput, "UTC-5")) // Ajusta UTC si tu servidor usa otro

grp_kap   = "🐊 Filtros Kapibara (Narrativa)"
useHTF    = input.bool(true, "Filtrar por Tendencia HTF (EMA)", group=grp_kap)
htfTime   = input.timeframe("60", "Temporalidad Mayor (HTF)", group=grp_kap)
emaLen    = input.int(200, "EMA HTF Periodos", group=grp_kap)
adxThresh = input.int(25, "Filtro ADX (Solo Rangos)", group=grp_kap)
useSweep  = input.bool(true, "Confirmar Neutralización (Sweep)", group=grp_kap)

grp_bb    = "📊 Bandas de Bollinger"
bbLen     = input.int(20, "Periodos", group=grp_bb)
bbMult    = input.float(2.0, "Desviación", group=grp_bb)

grp_grid  = "⛓️ Configuración de Matriz"
slPips    = input.int(35, "Stop Loss Total (Pips)", group=grp_grid)
useATR    = input.bool(true, "Step basado en ATR", group=grp_grid)
fixedStep = input.int(7, "Step Fijo (Pips)", group=grp_grid)
extraPips = input.float(5.0, "TP: Pips extras tras la Media", step=0.5, group=grp_grid)

// --- Cálculos de Indicadores ---
[basis, upper, lower] = ta.bb(close, bbLen, bbMult)
[_, _, adx] = ta.dmi(14, 14)
pipValue = syminfo.mintick * 10
actualStep = useATR ? (ta.atr(14) / syminfo.mintick / 10) * 0.75 : fixedStep
emaHTF = request.security(syminfo.tickerid, htfTime, ta.ema(close, emaLen))

// ========================================================================= //
// 1. LÓGICA DE ENTRADA (IPDA & LIQUIDEZ)
// ========================================================================= //
sweepLong  = useSweep ? (low[1] < lower[1] and close > lower) : ta.crossunder(low, lower)
sweepShort = useSweep ? (high[1] > upper[1] and close < upper) : ta.crossover(high, upper)

trendLong  = not useHTF or close > emaHTF
trendShort = not useHTF or close < emaHTF

// INCLUSIÓN DEL FILTRO HORARIO: Solo disparamos si inSession es verdadero
longTrigger  = sweepLong and adx < adxThresh and trendLong and inSession
shortTrigger = sweepShort and adx < adxThresh and trendShort and inSession

// --- Cálculo de Lotaje ---
pipValueCash = syminfo.pointvalue * syminfo.mintick * 10
f_calc_qty() =>
    float totalUnits = 0
    for i = 0 to 6
        pipsToSL = math.max(slPips - (i * actualStep), 0)
        multiplier = invertLot ? (7 - i) : (i + 1)
        totalUnits += (multiplier * pipsToSL)
    riskCash / (totalUnits * pipValueCash)

qBase = f_calc_qty()

// ========================================================================= //
// 2. MOTOR DE ÓRDENES Y CIERRE DE SESIÓN
// ========================================================================= //

// A) Si no hay posición, cancelamos todo para limpiar el gráfico
if strategy.position_size == 0
    strategy.cancel_all()

// B) Lógica de CIERRE DE SESIÓN (3:30 PM):
// Si salimos de la sesión y había órdenes pendientes, las borramos en TradingView y enviamos comando a Oanda.
sessionEndTrigger = not inSession and inSession[1]
if sessionEndTrigger
    // strategy.cancel_all() en Pine Script borra las órdenes LIMIT que no se ejecutaron.
    strategy.cancel_all()
    // Enviamos mensaje a PineConnector para cancelar órdenes pendientes en el broker sin cerrar la actual.
    if strategy.position_size != 0
        alert(pc_id + ",cancelall," + syminfo.ticker, alert.freq_once_per_bar)

float finalTP = strategy.position_size > 0 ? basis + (extraPips * pipValue) : basis - (extraPips * pipValue)

// Ejecución de Matriz
if (longTrigger or shortTrigger) and strategy.position_size == 0
    entryPrice = close
    sl = longTrigger ? entryPrice - (slPips * pipValue) : entryPrice + (slPips * pipValue)
    initTP = longTrigger ? basis + (extraPips * pipValue) : basis - (extraPips * pipValue)

    for i = 0 to 6
        float offset = i * actualStep * pipValue
        float price = longTrigger ? entryPrice - offset : entryPrice + offset
        float multiplier = invertLot ? (7 - i) : (i + 1)
        float size = qBase * multiplier
        
        string cmd = longTrigger ? "buy" : "sell"
        string msg = str.format("{0},{1},{2},volume={3},sl={4},tp={5}", pc_id, cmd, syminfo.ticker, str.tostring(size, "#.##"), str.tostring(sl, "#.#####"), str.tostring(initTP, "#.#####"))
        
        strategy.entry(cmd + str.tostring(i), longTrigger ? strategy.long : strategy.short, qty=size, limit= i==0 ? na : price, comment=msg)

// --- Gestión de Salida Inteligente ---
if strategy.position_size != 0
    bool touchTP = strategy.position_size > 0 ? ta.crossover(high, finalTP) : ta.crossunder(low, finalTP)
    if touchTP
        strategy.close_all(comment=pc_id + ",closeall," + syminfo.ticker)

    float firstEntry = strategy.opentrades.entry_price(0)
    float stopLevel = strategy.position_size > 0 ? firstEntry - (slPips * pipValue) : firstEntry + (slPips * pipValue)
    strategy.exit("X", stop=stopLevel, limit=finalTP, comment=pc_id + ",cancelall," + syminfo.ticker)

// --- Visualización ---
bgcolor(inSession ? color.new(color.green, 90) : color.new(color.red, 90), title="Zona de Operativa")
plot(emaHTF, color=color.new(color.orange, 0), linewidth=2, title="Filtro de Tendencia HTF")
plot(strategy.position_size != 0 ? finalTP : na, color=color.green, style=plot.style_linebr, linewidth=2, title="Objetivo Kapibara")
````
