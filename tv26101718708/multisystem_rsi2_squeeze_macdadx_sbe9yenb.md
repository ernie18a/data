# Multi-System (RSI2 + Squeeze + MACD/ADX)

- url: https://www.tradingview.com/script/Sbe9yenB-Multi-System-RSI2-Squeeze-MACD-ADX/
- type: indicator
- pine_id: PUB;12075789e7a6460389bacef59f24ad34
- version: 1.0

## Description

Confluence Multi-System combines three independent, well-documented signal frameworks into a single overlay and only fires alerts when two or more agree on direction. The goal is to filter noise: each system has its own logic and failure mode, so coincidence between them is statistically rarer and historically higher quality than any individual signal.

THE THREE SYSTEMS

System 1 — Mean Reversion (RSI-2 + Williams %R + 200 SMA)
Larry Connors-style countertrend setup. Trades only in the direction of the 200 SMA trend filter, requires RSI(2) at an extreme (<5 long, >95 short) and Williams %R(10) confirming (<-90 long, >-10 short). Designed for pullbacks within a trend, not reversals against it.

System 2 — TTM Squeeze
Classic John Carter volatility compression setup. Detects when Bollinger Bands(20, 2.0) contract inside Keltner Channels(20, 1.5) — a "squeeze" — then signals on the release in the direction of a linear-regression momentum oscillator. Catches breakouts after consolidation.

System 3 — Triple Confirmation (MACD + RSI + ADX)
Trend-following filter stack. Long requires MACD(12,26,9) bullish cross + RSI(14) > 50 + ADX(14) > 25. Short is the mirror. ADX gates out chop; RSI confirms the cross is in the dominant momentum side.

CONFLUENCE LOGIC

The indicator counts how many systems are signaling in the same direction on the same bar:
• 3/3 → STRONG signal (background tinted, label printed, dedicated alert)
• 2/3 → MEDIUM signal (lighter tint, dedicated alert)
• <2  → no signal, no alert

The minimum number of systems required can be configured (default 2). You can also disable any system individually if you want to test 2-of-2 confluence on specific pairs.

WHAT YOU SEE ON THE CHART

• Background tint on confluence bars (green/red strong, lime/fuchsia medium)
• Labels marking the bar where confluence first appears
• 200 SMA plotted as visual reference for the System 1 trend filter
• A status table (top-right) showing for each system: long/short state, key indicator values (RSI, Williams %R, ADX, squeeze state, momentum), plus a summary row with the current confluence level

ALERTS

Six alertconditions are exposed:
• STRONG LONG (3/3) / STRONG SHORT (3/3)
• MEDIUM LONG (2/3) / MEDIUM SHORT (2/3)
• ANY CONFLUENCE LONG / ANY CONFLUENCE SHORT (respect the configured minimum)

Alerts include ticker, interval, and close price via standard TradingView placeholders.

INPUTS

All three systems are fully parametrized: SMA length, RSI/Williams %R lengths and thresholds, Bollinger and Keltner lengths and multipliers, MACD periods, ADX length and minimum strength. Defaults match the original published values for each framework.

USE CASES

• Day trading on lower timeframes — wait for 2/3 or 3/3 to enter, exit on opposite confluence or your own stop
• Swing trading on 1H/4H/Daily — confluence becomes rare but high quality
• As a confirmation layer over your own strategy — read the table to see which systems agree before pulling the trigger

NOTES AND DISCLAIMERS

This is an indicator, not a strategy — it does not place orders, manage stops, or compute P&L. Win-rate ranges referenced for each underlying system come from the original literature (Connors, Carter, Wilder/Appel) and are heavily dependent on instrument, timeframe, and exit logic. Past performance does not guarantee future results. Always backtest with your own exit rules before trading live.

Open source — fork it, adapt the thresholds, plug in your own systems.

## Source Code

````pine
// © 2026 - Confluence Multi-System Indicator
//@version=5
indicator("Confluence Multi-System (RSI2 + Squeeze + MACD/ADX)", shorttitle="CONFLUENCE", overlay=true, max_labels_count=500)

// =============================================================================
// INPUTS — Parámetros configurables por sistema
// =============================================================================

// --- General
grpGen      = "General"
showTable   = input.bool(true,  "Mostrar tabla de estado",          group=grpGen)
showBg      = input.bool(true,  "Pintar fondo en confluencia",      group=grpGen)
showLabels  = input.bool(true,  "Mostrar etiquetas de confluencia", group=grpGen)
minSystems  = input.int(2, "Mínimo de sistemas para alerta", minval=2, maxval=3, group=grpGen)

// --- Sistema 1: Mean Reversion (RSI-2 + Williams %R + 200 MA)
grpS1       = "Sistema 1 — Mean Reversion"
s1_enabled  = input.bool(true,  "Activar Sistema 1",          group=grpS1)
s1_maLen    = input.int(200,    "Longitud SMA tendencia",     minval=20, group=grpS1)
s1_rsiLen   = input.int(2,      "Longitud RSI",               minval=1,  group=grpS1)
s1_rsiBuy   = input.float(5.0,  "RSI nivel sobreventa",       minval=0, maxval=50, group=grpS1)
s1_rsiSell  = input.float(95.0, "RSI nivel sobrecompra",      minval=50, maxval=100, group=grpS1)
s1_wrLen    = input.int(10,     "Longitud Williams %R",       minval=1,  group=grpS1)
s1_wrBuy    = input.float(-90.0,"Williams %R sobreventa",     group=grpS1)
s1_wrSell   = input.float(-10.0,"Williams %R sobrecompra",    group=grpS1)

// --- Sistema 2: TTM Squeeze
grpS2       = "Sistema 2 — TTM Squeeze"
s2_enabled  = input.bool(true,  "Activar Sistema 2",          group=grpS2)
s2_len      = input.int(20,     "Longitud BB/KC",             minval=5,  group=grpS2)
s2_bbMult   = input.float(2.0,  "Multiplicador BB",           minval=0.1, group=grpS2)
s2_kcMult   = input.float(1.5,  "Multiplicador KC",           minval=0.1, group=grpS2)

// --- Sistema 3: MACD + RSI + ADX
grpS3       = "Sistema 3 — Triple Confirmación"
s3_enabled  = input.bool(true,  "Activar Sistema 3",          group=grpS3)
s3_macdFast = input.int(12,     "MACD rápida",                minval=1,  group=grpS3)
s3_macdSlow = input.int(26,     "MACD lenta",                 minval=1,  group=grpS3)
s3_macdSig  = input.int(9,      "MACD señal",                 minval=1,  group=grpS3)
s3_rsiLen   = input.int(14,     "Longitud RSI",               minval=1,  group=grpS3)
s3_adxLen   = input.int(14,     "Longitud ADX",               minval=1,  group=grpS3)
s3_adxMin   = input.float(25.0, "ADX mínimo (fuerza)",        minval=0,  group=grpS3)

// =============================================================================
// SISTEMA 1 — Mean Reversion (75-91% histórico)
// Filtro de tendencia (SMA 200) + RSI(2) extremo + Williams %R(10) confirmando
// =============================================================================
s1_ma   = ta.sma(close, s1_maLen)
s1_rsi  = ta.rsi(close, s1_rsiLen)
s1_wr   = ta.wpr(s1_wrLen)  // rango -100 (sobreventa) a 0 (sobrecompra)

s1_long  = s1_enabled and close > s1_ma and s1_rsi  < s1_rsiBuy  and s1_wr < s1_wrBuy
s1_short = s1_enabled and close < s1_ma and s1_rsi  > s1_rsiSell and s1_wr > s1_wrSell

// =============================================================================
// SISTEMA 2 — TTM Squeeze (70-92% en setups de calidad)
// BB dentro de KC = squeeze. Liberación + dirección del momentum
// =============================================================================
basis    = ta.sma(close, s2_len)
dev      = s2_bbMult * ta.stdev(close, s2_len)
bbUpper  = basis + dev
bbLower  = basis - dev
trRange  = ta.sma(ta.tr(true), s2_len)
kcUpper  = basis + trRange * s2_kcMult
kcLower  = basis - trRange * s2_kcMult

squeezeOn      = bbLower > kcLower and bbUpper < kcUpper
squeezeRelease = not squeezeOn and squeezeOn[1]

// Momento estilo TTM: regresión lineal del precio respecto al midpoint del rango
src      = close
hh       = ta.highest(high, s2_len)
ll       = ta.lowest(low,   s2_len)
midRange = (hh + ll) / 2
midBB    = basis
mom      = ta.linreg(src - (midRange + midBB) / 2, s2_len, 0)

s2_long  = s2_enabled and squeezeRelease and mom > 0 and mom > nz(mom[1])
s2_short = s2_enabled and squeezeRelease and mom < 0 and mom < nz(mom[1])

// =============================================================================
// SISTEMA 3 — Triple Confirmación MACD + RSI + ADX (52-73%)
// =============================================================================
[macdLine, signalLine, _hist] = ta.macd(close, s3_macdFast, s3_macdSlow, s3_macdSig)
s3_rsi = ta.rsi(close, s3_rsiLen)

// ADX manual (Pine v5 no expone ADX directo en todas las versiones)
upMove    = high - high[1]
downMove  = low[1] - low
plusDM    = (upMove > downMove and upMove > 0) ? upMove : 0.0
minusDM   = (downMove > upMove and downMove > 0) ? downMove : 0.0
trAdx     = ta.rma(ta.tr(true), s3_adxLen)
plusDI    = 100 * ta.rma(plusDM,  s3_adxLen) / trAdx
minusDI   = 100 * ta.rma(minusDM, s3_adxLen) / trAdx
dx        = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI == 0 ? 1 : plusDI + minusDI)
adx       = ta.rma(dx, s3_adxLen)

macdCrossUp   = ta.crossover(macdLine, signalLine)
macdCrossDown = ta.crossunder(macdLine, signalLine)

s3_long  = s3_enabled and macdCrossUp   and s3_rsi > 50 and adx > s3_adxMin
s3_short = s3_enabled and macdCrossDown and s3_rsi < 50 and adx > s3_adxMin

// =============================================================================
// CONFLUENCIA — Conteo de sistemas alineados en la misma dirección
// =============================================================================
longCount  = (s1_long  ? 1 : 0) + (s2_long  ? 1 : 0) + (s3_long  ? 1 : 0)
shortCount = (s1_short ? 1 : 0) + (s2_short ? 1 : 0) + (s3_short ? 1 : 0)

confluenceLong   = longCount  >= minSystems
confluenceShort  = shortCount >= minSystems
strongLong       = longCount  >= 3
strongShort      = shortCount >= 3
mediumLong       = longCount  == 2
mediumShort      = shortCount == 2

// =============================================================================
// VISUALIZACIÓN
// =============================================================================

// Fondo
bgColor = not showBg ? na : strongLong ? color.new(color.green, 75) : strongShort ? color.new(color.red, 75) : mediumLong ? color.new(color.lime, 85) : mediumShort ? color.new(color.fuchsia, 85) : na
bgcolor(bgColor, title="Confluencia BG")

// Etiquetas
if showLabels and confluenceLong and not confluenceLong[1]
    txt = strongLong ? "STRONG LONG (3/3)" : "MEDIUM LONG (2/3)"
    label.new(bar_index, low, txt, style=label.style_label_up, color=strongLong ? color.green : color.lime, textcolor=color.white, size=size.small)

if showLabels and confluenceShort and not confluenceShort[1]
    txt = strongShort ? "STRONG SHORT (3/3)" : "MEDIUM SHORT (2/3)"
    label.new(bar_index, high, txt, style=label.style_label_down, color=strongShort ? color.red : color.fuchsia, textcolor=color.white, size=size.small)

// SMA 200 como referencia visual (filtro Sistema 1)
plot(s1_enabled ? s1_ma : na, "SMA Tendencia", color=color.new(color.orange, 30), linewidth=2)

// =============================================================================
// TABLA DE ESTADO
// =============================================================================
var table tbl = table.new(position.top_right, 4, 5, border_width=1)

f_cell(int row, int col, string txt, color bg, color fg) =>
    table.cell(tbl, col, row, txt, bgcolor=bg, text_color=fg, text_size=size.small)

if showTable and barstate.islast
    table.clear(tbl, 0, 0, 3, 4)
    f_cell(0, 0, "Sistema",    color.new(color.gray, 0), color.white)
    f_cell(0, 1, "Long",       color.new(color.gray, 0), color.white)
    f_cell(0, 2, "Short",      color.new(color.gray, 0), color.white)
    f_cell(0, 3, "Detalle",    color.new(color.gray, 0), color.white)

    // S1
    f_cell(1, 0, "S1 MeanRev",  color.new(color.black, 70), color.white)
    f_cell(1, 1, s1_long  ? "ON" : "-", s1_long  ? color.green : color.new(color.gray, 70), color.white)
    f_cell(1, 2, s1_short ? "ON" : "-", s1_short ? color.red   : color.new(color.gray, 70), color.white)
    f_cell(1, 3, "RSI=" + str.tostring(s1_rsi, "#.0") + " W%R=" + str.tostring(s1_wr, "#.0"), color.new(color.black, 70), color.white)

    // S2
    f_cell(2, 0, "S2 Squeeze",  color.new(color.black, 70), color.white)
    f_cell(2, 1, s2_long  ? "ON" : "-", s2_long  ? color.green : color.new(color.gray, 70), color.white)
    f_cell(2, 2, s2_short ? "ON" : "-", s2_short ? color.red   : color.new(color.gray, 70), color.white)
    sqzTxt = squeezeOn ? "SQZ ON" : (squeezeRelease ? "RELEASE" : "OFF")
    f_cell(2, 3, sqzTxt + " mom=" + str.tostring(mom, "#.##"), color.new(color.black, 70), color.white)

    // S3
    f_cell(3, 0, "S3 MACD/ADX", color.new(color.black, 70), color.white)
    f_cell(3, 1, s3_long  ? "ON" : "-", s3_long  ? color.green : color.new(color.gray, 70), color.white)
    f_cell(3, 2, s3_short ? "ON" : "-", s3_short ? color.red   : color.new(color.gray, 70), color.white)
    f_cell(3, 3, "ADX=" + str.tostring(adx, "#.0") + " RSI=" + str.tostring(s3_rsi, "#.0"), color.new(color.black, 70), color.white)

    // Resumen
    sumColor = strongLong ? color.green : strongShort ? color.red : mediumLong ? color.lime : mediumShort ? color.fuchsia : color.new(color.gray, 50)
    sumTxt = strongLong ? "STRONG LONG (3/3)" : strongShort ? "STRONG SHORT (3/3)" : mediumLong ? "MEDIUM LONG (2/3)" : mediumShort ? "MEDIUM SHORT (2/3)" : "Sin confluencia"
    table.merge_cells(tbl, 0, 4, 3, 4)
    f_cell(4, 0, sumTxt, sumColor, color.white)

// =============================================================================
// ALERTAS — solo cuando hay confluencia (>= minSystems sistemas alineados)
// =============================================================================
alertcondition(strongLong,   title="STRONG LONG (3/3)",  message="CONFLUENCE STRONG LONG: 3/3 sistemas alineados en {{ticker}} {{interval}} @ {{close}}")
alertcondition(strongShort,  title="STRONG SHORT (3/3)", message="CONFLUENCE STRONG SHORT: 3/3 sistemas alineados en {{ticker}} {{interval}} @ {{close}}")
alertcondition(mediumLong,   title="MEDIUM LONG (2/3)",  message="CONFLUENCE MEDIUM LONG: 2/3 sistemas alineados en {{ticker}} {{interval}} @ {{close}}")
alertcondition(mediumShort,  title="MEDIUM SHORT (2/3)", message="CONFLUENCE MEDIUM SHORT: 2/3 sistemas alineados en {{ticker}} {{interval}} @ {{close}}")
alertcondition(confluenceLong,  title="ANY CONFLUENCE LONG",  message="Confluence LONG ({{ticker}} {{interval}}) — sistemas alineados >= mínimo configurado")
alertcondition(confluenceShort, title="ANY CONFLUENCE SHORT", message="Confluence SHORT ({{ticker}} {{interval}}) — sistemas alineados >= mínimo configurado")
````
