#  Multi-TF Dashboard 

- url: https://www.tradingview.com/script/iMEJzGE6/
- type: indicator
- pine_id: PUB;ade36859a4454cd69e3397c9e3369cc2
- version: 1.0

## Description

📊 MULTI-TIMEFRAME DASHBOARD — Everything in one table

Stop jumping between charts to check timeframe confluence. 
This dashboard shows you, in a single configurable table:

✅ RSI (14) — automatically color-coded for overbought/oversold
✅ MACD — bullish/bearish direction based on line/signal crossover
✅ EMA Bias — trend based on price vs your EMA (configurable period)
✅ ATR — volatility classified as High/Medium/Low vs its own historical average
✅ MACD Divergences — both regular AND hidden, detected automatically

🔧 100% CONFIGURABLE
— Pick your own 4 timeframes
— Adjust EMA period, MACD parameters, and ATR settings
— Toggle regular/hidden divergence detection on or off
— Customize table position and text size

🌐 WORKS ON ANY MARKET
Forex, indices (Nasdaq, S&P), cryptocurrencies — the script is symbol-agnostic, 
so you can use it no matter what you're trading.

🔔 ALERTS INCLUDED
Turn on the alert and get notified the moment a MACD divergence is detected 
on any of your 4 configured timeframes.

💬 What metric would you like to see added in a future version? 
Drop your suggestion in the comments — I'll keep improving this script 
based on community feedback.

If you found this useful, a like helps it reach more traders 🙏

## Source Code

````pine
//@version=6
indicator("Multi-TF Dashboard Completo | RSI · MACD · Bias · ATR · Divergencias", overlay=true, max_labels_count=500)

// ============================================================
// INPUTS
// ============================================================
g_tf = "Temporalidades"
tf1 = input.timeframe("15", "Timeframe 1", group=g_tf)
tf2 = input.timeframe("60", "Timeframe 2", group=g_tf)
tf3 = input.timeframe("240", "Timeframe 3", group=g_tf)
tf4 = input.timeframe("D", "Timeframe 4", group=g_tf)

g_ema = "Bias EMA"
emaLen = input.int(50, "Período EMA", minval=1, group=g_ema)

g_macd = "MACD"
macdFast = input.int(12, "MACD Fast", group=g_macd)
macdSlow = input.int(26, "MACD Slow", group=g_macd)
macdSignal = input.int(9, "MACD Signal", group=g_macd)

g_atr = "ATR / Volatilidad"
atrLen = input.int(14, "Período ATR", group=g_atr)
atrLookback = input.int(100, "Períodos para promedio histórico ATR", group=g_atr)
atrHighMult = input.float(1.2, "Umbral Alta (x promedio)", step=0.1, group=g_atr)
atrLowMult = input.float(0.8, "Umbral Baja (x promedio)", step=0.1, group=g_atr)

g_piv = "Divergencias - Pivots"
pivLeft = input.int(5, "Velas a la izquierda", minval=1, group=g_piv)
pivRight = input.int(5, "Velas a la derecha (confirmación)", minval=1, group=g_piv)

g_div = "Divergencias - Tipos"
showRegular = input.bool(true, "Detectar divergencias regulares", group=g_div)
showHidden = input.bool(true, "Detectar divergencias ocultas", group=g_div)

g_tbl = "Tabla"
tblPos = input.string("top_right", "Posición", options=["top_right", "top_left", "bottom_right", "bottom_left"], group=g_tbl)
tblSize = input.string("normal", "Tamaño de texto", options=["small", "normal", "large"], group=g_tbl)

g_alert = "Alertas"
alertOnAny = input.bool(true, "Alertar ante cualquier divergencia detectada", group=g_alert)

// ============================================================
// FUNCIONES — RSI / MACD dirección / BIAS EMA / ATR
// ============================================================
f_rsi(_tf) =>
    request.security(syminfo.tickerid, _tf, ta.rsi(close, 14), lookahead=barmerge.lookahead_off)

f_macdDir(_tf) =>
    [macdLine, signalLine, _] = request.security(syminfo.tickerid, _tf, ta.macd(close, macdFast, macdSlow, macdSignal), lookahead=barmerge.lookahead_off)
    macdLine > signalLine

f_emaBias(_tf) =>
    ema_ = request.security(syminfo.tickerid, _tf, ta.ema(close, emaLen), lookahead=barmerge.lookahead_off)
    px_ = request.security(syminfo.tickerid, _tf, close, lookahead=barmerge.lookahead_off)
    px_ > ema_

f_atrState(_tf) =>
    atrNow = request.security(syminfo.tickerid, _tf, ta.atr(atrLen), lookahead=barmerge.lookahead_off)
    atrAvg = request.security(syminfo.tickerid, _tf, ta.sma(ta.atr(atrLen), atrLookback), lookahead=barmerge.lookahead_off)
    ratio = atrNow / atrAvg
    ratio >= atrHighMult ? "Alta" : ratio <= atrLowMult ? "Baja" : "Media"

// ============================================================
// FUNCIÓN — DIVERGENCIA MACD (regular + oculta) por timeframe
// ============================================================
f_divState(_tf) =>
    [macdLine, _, _] = request.security(syminfo.tickerid, _tf, ta.macd(close, macdFast, macdSlow, macdSignal), lookahead=barmerge.lookahead_off)
    pivHigh = request.security(syminfo.tickerid, _tf, ta.pivothigh(high, pivLeft, pivRight), lookahead=barmerge.lookahead_off)
    pivLow = request.security(syminfo.tickerid, _tf, ta.pivotlow(low, pivLeft, pivRight), lookahead=barmerge.lookahead_off)

    var float lastPivHighPrice = na
    var float lastPivHighMacd = na
    var float prevPivHighPrice = na
    var float prevPivHighMacd = na

    var float lastPivLowPrice = na
    var float lastPivLowMacd = na
    var float prevPivLowPrice = na
    var float prevPivLowMacd = na

    string state = "—"

    if not na(pivHigh)
        prevPivHighPrice := lastPivHighPrice
        prevPivHighMacd := lastPivHighMacd
        lastPivHighPrice := pivHigh
        lastPivHighMacd := macdLine[pivRight]

        if showRegular and not na(prevPivHighPrice) and lastPivHighPrice > prevPivHighPrice and lastPivHighMacd < prevPivHighMacd
            state := "Bajista Reg"
        if showHidden and not na(prevPivHighPrice) and lastPivHighPrice < prevPivHighPrice and lastPivHighMacd > prevPivHighMacd
            state := "Bajista Oculta"

    if not na(pivLow)
        prevPivLowPrice := lastPivLowPrice
        prevPivLowMacd := lastPivLowMacd
        lastPivLowPrice := pivLow
        lastPivLowMacd := macdLine[pivRight]

        if showRegular and not na(prevPivLowPrice) and lastPivLowPrice < prevPivLowPrice and lastPivLowMacd > prevPivLowMacd
            state := "Alcista Reg"
        if showHidden and not na(prevPivLowPrice) and lastPivLowPrice > prevPivLowPrice and lastPivLowMacd < prevPivLowMacd
            state := "Alcista Oculta"

    state

// ============================================================
// COLORES
// ============================================================
colBull = color.new(color.green, 0)
colBear = color.new(color.red, 0)
colNeutral = color.new(color.gray, 0)
colHeader = color.new(color.blue, 70)
colBg = color.new(color.black, 85)

f_rsiColor(_rsi) =>
    _rsi >= 70 ? colBear : _rsi <= 30 ? colBull : colNeutral

f_atrColor(_state) =>
    _state == "Alta" ? colBear : _state == "Baja" ? colNeutral : color.new(color.orange, 0)

f_divColor(_state) =>
    _state == "Alcista Reg" or _state == "Alcista Oculta" ? colBull : _state == "Bajista Reg" or _state == "Bajista Oculta" ? colBear : colNeutral

// ============================================================
// POSICIÓN Y TAMAÑO TABLA
// ============================================================
tblPosition = tblPos == "top_right" ? position.top_right : tblPos == "top_left" ? position.top_left : tblPos == "bottom_right" ? position.bottom_right : position.bottom_left
tblTextSize = tblSize == "small" ? size.small : tblSize == "large" ? size.large : size.normal

// ============================================================
// CÁLCULO POR TIMEFRAME (una sola llamada por TF, fuera de loops, por límite de Pine)
// ============================================================
rsi1 = f_rsi(tf1)
rsi2 = f_rsi(tf2)
rsi3 = f_rsi(tf3)
rsi4 = f_rsi(tf4)

macdDir1 = f_macdDir(tf1)
macdDir2 = f_macdDir(tf2)
macdDir3 = f_macdDir(tf3)
macdDir4 = f_macdDir(tf4)

emaBias1 = f_emaBias(tf1)
emaBias2 = f_emaBias(tf2)
emaBias3 = f_emaBias(tf3)
emaBias4 = f_emaBias(tf4)

atrState1 = f_atrState(tf1)
atrState2 = f_atrState(tf2)
atrState3 = f_atrState(tf3)
atrState4 = f_atrState(tf4)

divState1 = f_divState(tf1)
divState2 = f_divState(tf2)
divState3 = f_divState(tf3)
divState4 = f_divState(tf4)

// ============================================================
// TABLA — 6 columnas x 5 filas (header + 4 timeframes)
// ============================================================
var table dash = table.new(tblPosition, 6, 5, border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

f_drawRow(_row, _tf, _rsi, _macdBull, _emaBull, _atrState, _divState) =>
    table.cell(dash, 0, _row, _tf, bgcolor=colBg, text_color=color.white, text_size=tblTextSize)
    table.cell(dash, 1, _row, str.tostring(_rsi, "#.#"), bgcolor=colBg, text_color=f_rsiColor(_rsi), text_size=tblTextSize)
    table.cell(dash, 2, _row, _macdBull ? "▲" : "▼", bgcolor=colBg, text_color=_macdBull ? colBull : colBear, text_size=tblTextSize)
    table.cell(dash, 3, _row, _emaBull ? "▲" : "▼", bgcolor=colBg, text_color=_emaBull ? colBull : colBear, text_size=tblTextSize)
    table.cell(dash, 4, _row, _atrState, bgcolor=colBg, text_color=f_atrColor(_atrState), text_size=tblTextSize)
    table.cell(dash, 5, _row, _divState, bgcolor=colBg, text_color=f_divColor(_divState), text_size=tblTextSize)

if barstate.islast
    table.cell(dash, 0, 0, "TF", bgcolor=colHeader, text_color=color.white, text_size=tblTextSize)
    table.cell(dash, 1, 0, "RSI", bgcolor=colHeader, text_color=color.white, text_size=tblTextSize)
    table.cell(dash, 2, 0, "MACD", bgcolor=colHeader, text_color=color.white, text_size=tblTextSize)
    table.cell(dash, 3, 0, "Bias EMA", bgcolor=colHeader, text_color=color.white, text_size=tblTextSize)
    table.cell(dash, 4, 0, "ATR", bgcolor=colHeader, text_color=color.white, text_size=tblTextSize)
    table.cell(dash, 5, 0, "Divergencia", bgcolor=colHeader, text_color=color.white, text_size=tblTextSize)

    f_drawRow(1, tf1, rsi1, macdDir1, emaBias1, atrState1, divState1)
    f_drawRow(2, tf2, rsi2, macdDir2, emaBias2, atrState2, divState2)
    f_drawRow(3, tf3, rsi3, macdDir3, emaBias3, atrState3, divState3)
    f_drawRow(4, tf4, rsi4, macdDir4, emaBias4, atrState4, divState4)

// ============================================================
// ALERTAS
// ============================================================
anyDivergence = divState1 != "—" or divState2 != "—" or divState3 != "—" or divState4 != "—"

if alertOnAny and anyDivergence
    alertMsg = "Divergencia MACD detectada → " + tf1 + ": " + divState1 + " | " + tf2 + ": " + divState2 + " | " + tf3 + ": " + divState3 + " | " + tf4 + ": " + divState4
    alert(alertMsg, alert.freq_once_per_bar_close)

alertcondition(anyDivergence, title="Divergencia MACD (cualquier TF)", message="Se detectó divergencia MACD en al menos un timeframe del dashboard")
````
