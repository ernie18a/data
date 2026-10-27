# FT - Volume Indicator

- url: https://www.tradingview.com/script/udxq2kWL/
- type: indicator
- pine_id: PUB;2b05113b89264425a6e377852733ac33
- version: 2.0

## Description

FT - VOLUME INDICATOR

A multi-condition volume and range analysis tool that highlights six distinct market behaviors by painting vertical background columns behind qualifying candles. Designed to help traders visually identify institutional activity, absorption zones, breakouts, and dead zones at a glance — without cluttering the chart with arrows or labels.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT MAKES IT DIFFERENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Most volume indicators show only one dimension: "high volume" or "low volume". This indicator cross-references volume with candle range, producing six distinct contextual signals instead of one. The combination reveals the INTENT behind the volume, not just its magnitude.

For example, a candle can have abnormally high volume but a tiny range — that is classic absorption (large orders being absorbed without moving price). A different candle can have high volume AND expanded range — that is impulsive directional movement. These two behaviors look identical to a basic volume indicator but mean completely opposite things.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THE SIX CONDITIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1) HIGH VOLUME
   Volume exceeds the N-period SMA multiplied by a configurable factor.
   Marks candles with abnormal trading activity without range context.

2) HIGH VOLUME + SMALL CANDLE (ABSORPTION)
   High volume combined with a range SMALLER than the average range.
   Indicates strong orders being absorbed at a level. Classic signal at
   supports and resistances where institutional players defend price.

3) HIGH VOLUME + LARGE CANDLE (IMPULSE)
   High volume combined with a range LARGER than the average range.
   Indicates aggressive directional movement: breakouts, news reactions,
   and trend initiations.

4) LOW VOLUME
   Volume well below the SMA divided by a configurable factor.
   Identifies periods of reduced participation and consolidation.

5) LOW VOLUME + LARGE CANDLE (WEAK MOVE)
   Low volume combined with a large range.
   Warning signal: price is moving without real participation. Often
   precedes reversals or indicates manipulated/thin-liquidity moves.

6) LOW VOLUME + SMALL CANDLE (DEAD ZONE)
   Low volume combined with a small range.
   Identifies dead zones, lunch-hour consolidations, and low-liquidity
   periods where trading is generally avoided.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CALCULATION METHOD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Volume reference: Simple Moving Average of volume over N bars (configurable per condition).
- Range reference: Simple Moving Average of (High - Low) over N bars (configurable per condition).
- High volume trigger: volume >= avgVolume × multiplier
- Low volume trigger: volume <= avgVolume ÷ divisor
- Small candle trigger: range <= avgRange × maxRangeFactor (default 0.8)
- Large candle trigger: range >= avgRange × minRangeFactor (default 3.0)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRIORITY LOGIC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
When a candle satisfies multiple conditions simultaneously, the most
specific one prevails. The priority order is:

   3 (High Vol + Large) > 2 (High Vol + Small) > 1 (High Vol) >
   5 (Low Vol + Large) > 6 (Low Vol + Small) > 4 (Low Vol)

This prevents a breakout candle (condition 3) from being painted as just
"high volume" (condition 1), preserving the most meaningful interpretation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Each of the 6 conditions can be independently enabled/disabled.
- Fully customizable colors for each condition.
- Adjustable parameters per condition: SMA length, multipliers,
  divisors, and range thresholds — allowing fine-tuning for any asset
  or timeframe.
- Time filter with configurable GMT offset: restricts painting to
  a specific trading session (e.g., US session, Asian session).
- Vertical background columns instead of candle painting: keeps
  candlestick colors intact for reading price action clearly while still
  highlighting the volume context.
- Six independent alerts (one per condition) for real-time notifications.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- SCALPING: Watch for absorption (condition 2) at key supports/resistances
  to anticipate reversals. A small candle with large volume at a level
  often signals that larger players are positioning before the move.

- BREAKOUT TRADING: Only consider breakouts confirmed by condition 3
  (high volume + large range). Breakouts without volume expansion are
  statistically prone to fail.

- TREND CONTINUATION: Multiple consecutive condition 3 candles in the
  same direction confirm institutional alignment.

- FADE / REVERSAL: Condition 5 (low volume + large range) warns of
  unsustainable moves. Combined with exhaustion signals from other tools,
  it can signal reversal opportunities.

- FILTERING: Condition 6 (dead zones) helps avoid taking trades during
  unproductive periods. Some traders pause strategies entirely when
  condition 6 dominates the recent price action.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RECOMMENDED CONFIGURATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Default values are calibrated for active intraday assets (NQ futures,
BTC, major forex pairs on 1m-15m timeframes). For less volatile assets
or higher timeframes, consider:
- Lowering the HIGH VOLUME multipliers (3 → 2).
- Increasing SMA lengths for smoother references.
- Adjusting range thresholds based on ATR of the specific asset.

All parameters are fully configurable to adapt to any asset and timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- This indicator is a context/confluence tool, not a standalone trading
  system. It identifies market behaviors but does not generate
  buy/sell signals on its own.
- Works best when combined with structural analysis (support/resistance,
  trendlines, or tools like VWAP and EMAs).
- Volume data quality depends on the data provider — some brokers
  report volume differently (tick volume vs. real volume).

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════
// FT - VOLUME INDICATOR
// ─────────────────────────────────────────────────────────────────────
// Pinta las velas del gráfico según 6 condiciones de volumen y rango:
//
//   1) Volumen Alto                       — volumen > promedio × multiplicador
//   2) Volumen Alto + Vela Chica          — volumen alto con rango reducido
//   3) Volumen Alto + Vela Grande         — volumen alto con rango expandido
//   4) Volumen Bajo                       — volumen < promedio ÷ divisor
//   5) Volumen Bajo + Vela Grande         — volumen bajo con rango grande
//   6) Volumen Bajo + Vela Chica          — volumen bajo con rango chico
//
// Cada condición se puede activar/desactivar independiente con su color.
// Incluye filtro horario con GMT offset configurable.
//
// Autor: FrancoTradingFT
// ═══════════════════════════════════════════════════════════════════
indicator("FT - Volume Indicator", shorttitle="FT - Volume Indicator", overlay=true)

// ════════════════════════════════════════════════════════════
// ⏰ FILTRO HORARIO
// ════════════════════════════════════════════════════════════
gT = "⏰ Filtro Horario"
useTimeFilter = input.bool(true, "Activar filtro horario", group=gT)
gmtOffset     = input.int(-3,    "GMT offset (ej: -3 para Argentina)", minval=-12, maxval=14, group=gT)
startHour     = input.int(9,     "Hora inicio",   minval=0, maxval=23, group=gT)
startMin      = input.int(0,     "Minuto inicio", minval=0, maxval=59, group=gT)
endHour       = input.int(18,    "Hora fin",      minval=0, maxval=23, group=gT)
endMin        = input.int(0,     "Minuto fin",    minval=0, maxval=59, group=gT)

startUTC_raw = startHour - gmtOffset
endUTC_raw   = endHour   - gmtOffset
startUTC = startUTC_raw % 24 < 0 ? startUTC_raw % 24 + 24 : startUTC_raw % 24
endUTC   = endUTC_raw   % 24 < 0 ? endUTC_raw   % 24 + 24 : endUTC_raw   % 24

currentMins = hour(time, "UTC") * 60 + minute(time, "UTC")
startMins   = startUTC * 60 + startMin
endMins     = endUTC   * 60 + endMin

inSession = startMins <= endMins ? (currentMins >= startMins and currentMins < endMins) : (currentMins >= startMins or currentMins < endMins)
timeOK = useTimeFilter ? inSession : true

// ════════════════════════════════════════════════════════════
// 📊 CÁLCULO BASE
// ════════════════════════════════════════════════════════════
candleRange = high - low

// ════════════════════════════════════════════════════════════
// 🔴 1 · VOLUMEN ALTO
// ════════════════════════════════════════════════════════════
g1 = "🔺 1 · Volumen Alto"
use1     = input.bool(true, "Activar", group=g1)
lenVol1  = input.int(20,  "Promedio de volumen (velas)",  minval=1, group=g1)
multVol1 = input.float(3.0, "Multiplicador (x)",           minval=0.1, step=0.1, group=g1)
color1   = input.color(color.new(color.yellow, 0), "Color", group=g1)

avgVol1 = ta.sma(volume, lenVol1)
cond1   = volume >= avgVol1 * multVol1

// ════════════════════════════════════════════════════════════
// 🟠 2 · VOLUMEN ALTO + VELA CHICA
// ════════════════════════════════════════════════════════════
g2 = "🔺 2 · Volumen Alto + Vela Chica"
use2       = input.bool(true, "Activar", group=g2)
lenVol2    = input.int(20,   "Promedio de volumen (velas)",      minval=1, group=g2)
multVol2   = input.float(2.0, "Multiplicador volumen (x)",       minval=0.1, step=0.1, group=g2)
lenRange2  = input.int(20,   "Promedio de rango (velas)",        minval=1, group=g2)
maxRange2  = input.float(0.8, "Rango máximo (x del promedio)",   minval=0.1, step=0.1, group=g2)
color2     = input.color(color.new(color.orange, 0), "Color", group=g2)

avgVol2   = ta.sma(volume, lenVol2)
avgRange2 = ta.sma(candleRange, lenRange2)
cond2     = volume >= avgVol2 * multVol2 and candleRange <= avgRange2 * maxRange2

// ════════════════════════════════════════════════════════════
// 🟢 3 · VOLUMEN ALTO + VELA GRANDE
// ════════════════════════════════════════════════════════════
g3 = "🔺 3 · Volumen Alto + Vela Grande"
use3       = input.bool(true, "Activar", group=g3)
lenVol3    = input.int(20,   "Promedio de volumen (velas)",      minval=1, group=g3)
multVol3   = input.float(4.0, "Multiplicador volumen (x)",       minval=0.1, step=0.1, group=g3)
lenRange3  = input.int(20,   "Promedio de rango (velas)",        minval=1, group=g3)
minRange3  = input.float(3.0, "Rango mínimo (x del promedio)",   minval=0.1, step=0.1, group=g3)
color3     = input.color(color.new(color.green, 0), "Color", group=g3)

avgVol3   = ta.sma(volume, lenVol3)
avgRange3 = ta.sma(candleRange, lenRange3)
cond3     = volume >= avgVol3 * multVol3 and candleRange >= avgRange3 * minRange3

// ════════════════════════════════════════════════════════════
// ⚫ 4 · VOLUMEN BAJO
// ════════════════════════════════════════════════════════════
g4 = "🔻 4 · Volumen Bajo"
use4     = input.bool(true, "Activar", group=g4)
lenVol4  = input.int(200, "Promedio de volumen (velas)", minval=1, group=g4)
divVol4  = input.float(14.0, "Divisor (x veces menor)",  minval=0.1, step=0.5, group=g4)
color4   = input.color(color.new(color.gray, 0), "Color", group=g4)

avgVol4 = ta.sma(volume, lenVol4)
cond4   = volume <= avgVol4 / divVol4

// ════════════════════════════════════════════════════════════
// 🟣 5 · VOLUMEN BAJO + VELA GRANDE
// ════════════════════════════════════════════════════════════
g5 = "🔻 5 · Volumen Bajo + Vela Grande"
use5       = input.bool(false, "Activar", group=g5)
lenVol5    = input.int(20,   "Promedio de volumen (velas)",      minval=1, group=g5)
divVol5    = input.float(2.0, "Divisor volumen (x veces menor)", minval=0.1, step=0.1, group=g5)
lenRange5  = input.int(20,   "Promedio de rango (velas)",        minval=1, group=g5)
minRange5  = input.float(2.0, "Rango mínimo (x del promedio)",   minval=0.1, step=0.1, group=g5)
color5     = input.color(color.new(color.purple, 0), "Color", group=g5)

avgVol5   = ta.sma(volume, lenVol5)
avgRange5 = ta.sma(candleRange, lenRange5)
cond5     = volume <= avgVol5 / divVol5 and candleRange >= avgRange5 * minRange5

// ════════════════════════════════════════════════════════════
// 🟡 6 · VOLUMEN BAJO + VELA CHICA
// ════════════════════════════════════════════════════════════
g6 = "🔻 6 · Volumen Bajo + Vela Chica"
use6       = input.bool(false, "Activar", group=g6)
lenVol6    = input.int(20,   "Promedio de volumen (velas)",       minval=1, group=g6)
divVol6    = input.float(2.0, "Divisor volumen (x veces menor)",  minval=0.1, step=0.1, group=g6)
lenRange6  = input.int(20,   "Promedio de rango (velas)",         minval=1, group=g6)
maxRange6  = input.float(0.8, "Rango máximo (x del promedio)",    minval=0.1, step=0.1, group=g6)
color6     = input.color(color.new(color.aqua, 0), "Color", group=g6)

avgVol6   = ta.sma(volume, lenVol6)
avgRange6 = ta.sma(candleRange, lenRange6)
cond6     = volume <= avgVol6 / divVol6 and candleRange <= avgRange6 * maxRange6

// ════════════════════════════════════════════════════════════
// 🎨 PINTADO DE VELAS (con prioridad descendente)
// ════════════════════════════════════════════════════════════
// Prioridad: 3 > 2 > 1 > 5 > 6 > 4
// Si se cumplen varias condiciones al mismo tiempo, se aplica la más específica.

barColor = color(na)
if timeOK
    if use3 and cond3
        barColor := color3
    else if use2 and cond2
        barColor := color2
    else if use1 and cond1
        barColor := color1
    else if use5 and cond5
        barColor := color5
    else if use6 and cond6
        barColor := color6
    else if use4 and cond4
        barColor := color4

// Pinta el fondo vertical detrás de la vela (columna de color translúcido)
// Este es el método principal y no depende de settings especiales de TradingView
bgColorFinal = na(barColor) ? color(na) : color.new(barColor, 70)
bgcolor(bgColorFinal, title="FT - Volume Background")

// También pinta la vela si el usuario tiene activado el setting "los indicadores colorean las barras"
barcolor(barColor, title="FT - Volume Bar Color")

// ════════════════════════════════════════════════════════════
// ALERTAS
// ════════════════════════════════════════════════════════════
alertcondition(timeOK and use1 and cond1, title="Volumen Alto",                 message="Volumen Alto detectado")
alertcondition(timeOK and use2 and cond2, title="Volumen Alto + Vela Chica",    message="Volumen Alto + Vela Chica detectado")
alertcondition(timeOK and use3 and cond3, title="Volumen Alto + Vela Grande",   message="Volumen Alto + Vela Grande detectado")
alertcondition(timeOK and use4 and cond4, title="Volumen Bajo",                 message="Volumen Bajo detectado")
alertcondition(timeOK and use5 and cond5, title="Volumen Bajo + Vela Grande",   message="Volumen Bajo + Vela Grande detectado")
alertcondition(timeOK and use6 and cond6, title="Volumen Bajo + Vela Chica",    message="Volumen Bajo + Vela Chica detectado")
````
