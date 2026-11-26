# Sistema de Moises - Matriz Institucional 

- url: https://www.tradingview.com/script/hDPguaIV/
- type: indicator
- pine_id: PUB;7406ef20a80642158aaefeb78103a8fc
- version: 1.0

## Description

Sistema de Moisés — Matriz Institucional V6

Este indicador no da señales de compra o venta.

Su función es ordenar el contexto del mercado para que el trader pueda construir una tesis con mayor claridad.

La matriz analiza:

Macro
HTF
Intradía
Liquidez
Intención
Ubicación del precio
DXY
US10Y
US02Y

El objetivo es responder una pregunta simple:

¿El mercado está alineado, en pullback, en contexto táctico o sin ventaja clara?

La matriz clasifica el entorno en diferentes estados:

Alineación alcista 3/3
Alineación bajista 3/3
Pullback intradía dentro de contexto mayor
Macro contra estructura
Mayoría 2/3
Contexto mixto / sin ventaja clara

También muestra el régimen operativo:

Expansión: contexto limpio
Táctico: no exigir recorrido
Pullback: esperar confirmación
Espera: contexto abierto

La lectura externa con DXY/Yields no altera la matriz principal.
Solo informa si el contexto externo acompaña, contradice o no confirma la lectura del oro.

Este script fue diseñado principalmente para XAUUSD, pero puede utilizarse como herramienta de lectura contextual en otros activos líquidos.

Sistema de Moisés se basa en una idea central:

No operes el dibujo. Opera la intención.

El indicador no reemplaza el criterio del trader.
No ejecuta por vos.
No predice el mercado.
Solo organiza información institucional para ayudarte a leer mejor el contexto.

Uso recomendado:

1. Revisar el estado general de la matriz.
2. Observar si las capas están alineadas o en conflicto.
3. Confirmar liquidez, intención y ubicación.
4. Evaluar si DXY/Yields acompañan o contradicen.
5. Construir una tesis propia antes de buscar cualquier ejecución.

Disclaimer:

Este indicador es una herramienta educativa y de análisis contextual. No constituye asesoramiento financiero ni recomendación de inversión. Toda decisión operativa es responsabilidad del usuario.

## Source Code

````pine
//@version=6
indicator("Sistema de Moises - Matriz Institucional V6 Comercial", overlay=true, max_lines_count=20, max_labels_count=20, max_boxes_count=5)

// Matriz Institucional V6 Comercial — Contexto, regimen y condicion del mercado.
// No da entradas ni señales. Su unica funcion es ordenar el contexto para que el trader construya la tesis.
// Sistema de Moises — No operes el dibujo. Opera la intención.
// Stable: la lectura operativa se ancla al timeframe intradía configurado para no cambiar al mirar otro TF.
// V6: version comercial. Lenguaje simple, lectura rapida, logica institucional.

// ─────────────────────────────────────────────────────────
// PALETA
// ─────────────────────────────────────────────────────────
C_BG     = color.rgb(7, 10, 18)
C_PANEL  = color.rgb(13, 18, 30)
C_ROW    = color.rgb(18, 24, 38)
C_DIV    = color.rgb(38, 48, 65)
C_TEXT   = color.rgb(232, 236, 245)
C_MUTED  = color.rgb(145, 153, 166)
C_GREEN  = color.rgb(0, 190, 115)
C_RED    = color.rgb(220, 60, 70)
C_AMBER  = color.rgb(255, 176, 0)
C_CYAN   = color.rgb(0, 190, 220)

// ─────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────
G0 = "00 — Visual"
i_pos      = input.string("Top Right", "Posición panel", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=G0)
i_size     = input.string("Grande", "Tamaño", options=["Normal", "Grande", "XL"], group=G0)
i_showEMA  = input.bool(false, "Mostrar EMA local", group=G0)
i_showPD   = input.bool(false, "Mostrar PDH/PDL/PWH/PWL", group=G0)

G1 = "01 — Timeframes"
i_tfMacro  = input.timeframe("240", "Macro", group=G1)
i_tfHTF    = input.timeframe("60", "HTF", group=G1)
i_tfMid    = input.timeframe("15", "Intradía medio", group=G1)
i_emaFast  = input.int(50, "EMA rápida", minval=1, group=G1)
i_emaSlow  = input.int(200, "EMA lenta", minval=1, group=G1)

G2 = "02 — Lectura"
i_atrLen   = input.int(14, "ATR", minval=1, group=G2)
i_pivotLen = input.int(5, "Sensibilidad swings", minval=2, maxval=20, group=G2)
i_mem      = input.int(30, "Memoria liquidez/intención", minval=5, maxval=150, group=G2)
i_impATR   = input.float(1.05, "Impulso institucional × ATR", minval=0.3, step=0.05, group=G2)
i_bodyPct  = input.float(0.55, "Cuerpo mínimo impulso", minval=0.1, maxval=0.95, step=0.05, group=G2)
i_fvgATR   = input.float(0.12, "FVG mínimo × ATR", minval=0.02, step=0.01, group=G2)

G3 = "03 — Sesiones"
i_asia     = input.session("2000-2300", "Asia", group=G3)
i_london   = input.session("0300-0600", "London", group=G3)
i_ny       = input.session("0800-1100", "New York", group=G3)
i_nypm     = input.session("1300-1500", "NY Cierre", group=G3)

G4 = "04 — DXY / Yields"
i_useExternal = input.bool(true, "Mostrar contexto externo", group=G4)
i_extTf       = input.timeframe("15", "TF DXY/Yields", group=G4)
i_dxySym      = input.symbol("TVC:DXY", "DXY", group=G4)
i_us10ySym    = input.symbol("TVC:US10Y", "US10Y", group=G4)
i_us02ySym    = input.symbol("TVC:US02Y", "US02Y", group=G4)
i_extEma      = input.int(50, "EMA externa", minval=1, group=G4)
i_extRocLen   = input.int(5, "Momentum externo ROC", minval=1, group=G4)

// ─────────────────────────────────────────────────────────
// FUNCIONES
// ─────────────────────────────────────────────────────────
f_pos(_p) =>
    _p == "Top Left" ? position.top_left :
     _p == "Bottom Right" ? position.bottom_right :
     _p == "Bottom Left" ? position.bottom_left :
     position.top_right

f_txt() =>
    i_size == "XL" ? size.normal : i_size == "Grande" ? size.small : size.tiny

f_head() =>
    i_size == "XL" ? size.large : i_size == "Grande" ? size.normal : size.small

f_clamp(_v, _lo, _hi) =>
    math.max(_lo, math.min(_hi, _v))

f_bars(_cond) =>
    _bs = ta.barssince(_cond)
    na(_bs) ? 100000 : _bs

f_recent(_cond, _bars) =>
    f_bars(_cond) <= _bars

f_cell(_t, _c, _r, _txt, _tc, _bg, _align) =>
    table.cell(_t, _c, _r, _txt, text_color=_tc, bgcolor=_bg, text_size=f_txt(), text_halign=_align)

f_tfPack(_emaFast, _emaSlow, _atrLen, _pivotLen, _impATR, _bodyPct, _fvgATR) =>
    _fast = ta.ema(close, _emaFast)
    _slow = ta.ema(close, _emaSlow)
    _atr  = ta.atr(_atrLen)
    _ph   = ta.pivothigh(high, _pivotLen, _pivotLen)
    _pl   = ta.pivotlow(low, _pivotLen, _pivotLen)
    var float _lastPH = na
    var float _lastPL = na
    if not na(_ph)
        _lastPH := _ph
    if not na(_pl)
        _lastPL := _pl
    _rng = math.max(high - low, syminfo.mintick)
    _body = math.abs(close - open)
    _bodyOk = _body / _rng >= _bodyPct
    _bullImpulse = close > open and _bodyOk and _rng >= _atr * _impATR and close > high[1]
    _bearImpulse = close < open and _bodyOk and _rng >= _atr * _impATR and close < low[1]
    _bosBull = not na(_lastPH) and close > _lastPH
    _bosBear = not na(_lastPL) and close < _lastPL
    _bullFVG = low > high[2] and (low - high[2]) > _atr * _fvgATR
    _bearFVG = high < low[2] and (low[2] - high) > _atr * _fvgATR
    _slope = (_fast - _fast[5]) / math.max(_atr, syminfo.mintick)
    [close, _fast, _slow, _atr, _lastPH, _lastPL, _bullImpulse, _bearImpulse, _bosBull, _bosBear, _bullFVG, _bearFVG, _slope]

f_extPack(_emaLen, _rocLen) =>
    _ema = ta.ema(close, _emaLen)
    _roc = ta.roc(close, _rocLen)
    _bull = close > _ema and _roc > 0
    _bear = close < _ema and _roc < 0
    [close, _ema, _roc, _bull, _bear]

f_execPack(_atrLen, _pivotLen, _impATR, _bodyPct, _fvgATR, _mem, _asia, _london, _ny, _nypm) =>
    _atr = ta.atr(_atrLen)
    _ph = ta.pivothigh(high, _pivotLen, _pivotLen)
    _pl = ta.pivotlow(low, _pivotLen, _pivotLen)
    var float _lastPH = na
    var float _lastPL = na
    if not na(_ph)
        _lastPH := _ph
    if not na(_pl)
        _lastPL := _pl

    var float _dayOpen = na
    var float _dayHigh = na
    var float _dayLow = na
    var float _prevDayHigh = na
    var float _prevDayLow = na
    _newDay = ta.change(time("D")) != 0
    if na(_dayHigh)
        _dayOpen := open
        _dayHigh := high
        _dayLow := low
    else if _newDay
        _prevDayHigh := _dayHigh
        _prevDayLow := _dayLow
        _dayOpen := open
        _dayHigh := high
        _dayLow := low
    else
        _dayHigh := math.max(_dayHigh, high)
        _dayLow := math.min(_dayLow, low)

    var float _weekHigh = na
    var float _weekLow = na
    var float _prevWeekHigh = na
    var float _prevWeekLow = na
    _newWeek = ta.change(time("W")) != 0
    if na(_weekHigh)
        _weekHigh := high
        _weekLow := low
    else if _newWeek
        _prevWeekHigh := _weekHigh
        _prevWeekLow := _weekLow
        _weekHigh := high
        _weekLow := low
    else
        _weekHigh := math.max(_weekHigh, high)
        _weekLow := math.min(_weekLow, low)

    _sweepHighPivot = not na(_lastPH) and high > _lastPH and close < _lastPH
    _sweepLowPivot  = not na(_lastPL) and low < _lastPL and close > _lastPL
    _sweepHighPD    = not na(_prevDayHigh) and high > _prevDayHigh and close < _prevDayHigh
    _sweepLowPD     = not na(_prevDayLow) and low < _prevDayLow and close > _prevDayLow
    _sweepHighPW    = not na(_prevWeekHigh) and high > _prevWeekHigh and close < _prevWeekHigh
    _sweepLowPW     = not na(_prevWeekLow) and low < _prevWeekLow and close > _prevWeekLow
    _sweepHigh = _sweepHighPivot or _sweepHighPD or _sweepHighPW
    _sweepLow = _sweepLowPivot or _sweepLowPD or _sweepLowPW
    _recentSweepHigh = f_recent(_sweepHigh, _mem)
    _recentSweepLow = f_recent(_sweepLow, _mem)

    _upperTarget = (not na(_lastPH) and close < _lastPH) or (not na(_prevDayHigh) and close < _prevDayHigh) or (not na(_prevWeekHigh) and close < _prevWeekHigh)
    _lowerTarget = (not na(_lastPL) and close > _lastPL) or (not na(_prevDayLow) and close > _prevDayLow) or (not na(_prevWeekLow) and close > _prevWeekLow)

    _rng = math.max(high - low, syminfo.mintick)
    _body = math.abs(close - open)
    _bodyOk = _body / _rng >= _bodyPct
    _bullImpulse = close > open and _bodyOk and _rng >= _atr * _impATR and close > high[1]
    _bearImpulse = close < open and _bodyOk and _rng >= _atr * _impATR and close < low[1]
    _bosBull = not na(_lastPH) and close > _lastPH
    _bosBear = not na(_lastPL) and close < _lastPL
    _bullFVG = low > high[2] and (low - high[2]) > _atr * _fvgATR
    _bearFVG = high < low[2] and (low[2] - high) > _atr * _fvgATR
    _recentBullIntent = f_recent(_bullImpulse or _bosBull or _bullFVG, _mem)
    _recentBearIntent = f_recent(_bearImpulse or _bosBear or _bearFVG, _mem)
    _recentBullImbalance = f_recent(_bullImpulse or _bullFVG, _mem)
    _recentBearImbalance = f_recent(_bearImpulse or _bearFVG, _mem)
    _bullAfterSweep = _recentSweepLow and _recentBullIntent and f_bars(_bullImpulse or _bosBull or _bullFVG) <= f_bars(_sweepLow)
    _bearAfterSweep = _recentSweepHigh and _recentBearIntent and f_bars(_bearImpulse or _bosBear or _bearFVG) <= f_bars(_sweepHigh)
    _exploringHigher = (_bosBull or _bullImpulse) and _recentBullImbalance and not _recentSweepHigh
    _exploringLower = (_bosBear or _bearImpulse) and _recentBearImbalance and not _recentSweepLow

    _rHigh = ta.highest(high, 120)
    _rLow = ta.lowest(low, 120)
    _span = math.max(_rHigh - _rLow, syminfo.mintick)
    _posPct = (close - _rLow) / _span * 100
    _inDiscount = _posPct <= 45
    _inPremium = _posPct >= 55
    _inMid = not _inDiscount and not _inPremium

    _inAsia = not na(time(timeframe.period, _asia))
    _inLondon = not na(time(timeframe.period, _london))
    _inNY = not na(time(timeframe.period, _ny))
    _inNYpm = not na(time(timeframe.period, _nypm))

    _prevDayMid = (_prevDayHigh + _prevDayLow) / 2
    _dayBiasBull = not na(_prevDayMid) and _dayOpen > _prevDayMid and _dayHigh <= _prevDayHigh
    _dayBiasBear = not na(_prevDayMid) and _dayOpen < _prevDayMid and _dayLow >= _prevDayLow
    _daySweptHigh = not na(_prevDayHigh) and _dayHigh > _prevDayHigh
    _daySweptLow = not na(_prevDayLow) and _dayLow < _prevDayLow

    [_lastPH, _lastPL, _sweepHigh, _sweepLow, _recentSweepHigh, _recentSweepLow, _upperTarget, _lowerTarget, _bullImpulse, _bearImpulse, _bosBull, _bosBear, _bullFVG, _bearFVG, _recentBullIntent, _recentBearIntent, _recentBullImbalance, _recentBearImbalance, _bullAfterSweep, _bearAfterSweep, _exploringHigher, _exploringLower, _posPct, _inDiscount, _inPremium, _inMid, _inAsia, _inLondon, _inNY, _inNYpm, _dayBiasBull, _dayBiasBear, _daySweptHigh, _daySweptLow]

// ─────────────────────────────────────────────────────────
// BASE LOCAL
// ─────────────────────────────────────────────────────────
emaFast = ta.ema(close, i_emaFast)
emaSlow = ta.ema(close, i_emaSlow)
atr     = ta.atr(i_atrLen)

plot(i_showEMA ? emaFast : na, "EMA rápida", color=color.new(C_CYAN, 0))
plot(i_showEMA ? emaSlow : na, "EMA lenta", color=color.new(C_MUTED, 25))

// ─────────────────────────────────────────────────────────
// DATOS MTF
// ─────────────────────────────────────────────────────────
[macroClose, macroFast, macroSlow, macroAtr, macroPH, macroPL, macroBullImp, macroBearImp, macroBosBull, macroBosBear, macroBullFVG, macroBearFVG, macroSlope] = request.security(syminfo.tickerid, i_tfMacro, f_tfPack(i_emaFast, i_emaSlow, i_atrLen, i_pivotLen, i_impATR, i_bodyPct, i_fvgATR))
[htfClose, htfFast, htfSlow, htfAtr, htfPH, htfPL, htfBullImp, htfBearImp, htfBosBull, htfBosBear, htfBullFVG, htfBearFVG, htfSlope] = request.security(syminfo.tickerid, i_tfHTF, f_tfPack(i_emaFast, i_emaSlow, i_atrLen, i_pivotLen, i_impATR, i_bodyPct, i_fvgATR))
[midClose, midFast, midSlow, midAtr, midPH, midPL, midBullImp, midBearImp, midBosBull, midBosBear, midBullFVG, midBearFVG, midSlope] = request.security(syminfo.tickerid, i_tfMid, f_tfPack(i_emaFast, i_emaSlow, i_atrLen, i_pivotLen, i_impATR, i_bodyPct, i_fvgATR))
[dxyClose, dxyEma, dxyRoc, dxyBull, dxyBear] = request.security(i_dxySym, i_extTf, f_extPack(i_extEma, i_extRocLen))
[us10yClose, us10yEma, us10yRoc, us10yBull, us10yBear] = request.security(i_us10ySym, i_extTf, f_extPack(i_extEma, i_extRocLen))
[us02yClose, us02yEma, us02yRoc, us02yBull, us02yBear] = request.security(i_us02ySym, i_extTf, f_extPack(i_extEma, i_extRocLen))
[pdh, pdl, dayOpen, dayHigh, dayLow, prevDayHigh, prevDayLow, prevDayClose] = request.security(syminfo.tickerid, "D", [high[1], low[1], open, high, low, high[1], low[1], close[1]])
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]])

plot(i_showPD ? pdh : na, "PDH", color=color.new(C_RED, 75), style=plot.style_linebr)
plot(i_showPD ? pdl : na, "PDL", color=color.new(C_GREEN, 75), style=plot.style_linebr)
plot(i_showPD ? pwh : na, "PWH", color=color.new(C_RED, 85), style=plot.style_linebr)
plot(i_showPD ? pwl : na, "PWL", color=color.new(C_GREEN, 85), style=plot.style_linebr)

// ─────────────────────────────────────────────────────────
// LECTURA OPERATIVA FIJA
// Todo este bloque queda anclado al timeframe intradía configurado.
// Así el contexto no cambia por abrir el gráfico en 5m, 15m, 30m o 1H.
// ─────────────────────────────────────────────────────────
[lastPH, lastPL, sweepHigh, sweepLow, recentSweepHigh, recentSweepLow, upperTarget, lowerTarget, bullImpulse, bearImpulse, bosBull, bosBear, bullFVG, bearFVG, recentBullIntent, recentBearIntent, recentBullImbalance, recentBearImbalance, bullAfterSweep, bearAfterSweep, exploringHigher, exploringLower, posPct, inDiscount, inPremium, inMid, inAsia, inLondon, inNY, inNYpm, dayBiasBull, dayBiasBear, daySweptHigh, daySweptLow] = request.security(syminfo.tickerid, i_tfMid, f_execPack(i_atrLen, i_pivotLen, i_impATR, i_bodyPct, i_fvgATR, i_mem, i_asia, i_london, i_ny, i_nypm))

sessionText = inNY ? "NEW YORK" : inLondon ? "LONDON" : inAsia ? "ASIA" : inNYpm ? "NY CIERRE" : "FUERA KZ"

// ─────────────────────────────────────────────────────────
// CONTEXTO EXTERNO PARA XAUUSD
// DXY/Yields no entran al score principal: solo informan apoyo o contradicción.
// ─────────────────────────────────────────────────────────
extPressureDown = (dxyBull ? 1 : 0) + (us10yBull ? 1 : 0) + (us02yBull ? 1 : 0)
extPressureUp = (dxyBear ? 1 : 0) + (us10yBear ? 1 : 0) + (us02yBear ? 1 : 0)

externalPressuresGold = i_useExternal and extPressureDown >= 2 and extPressureDown > extPressureUp
externalRelievesGold = i_useExternal and extPressureUp >= 2 and extPressureUp > extPressureDown
externalMixed = i_useExternal and not externalPressuresGold and not externalRelievesGold

externalText = not i_useExternal ? "Desactivado" :
     externalPressuresGold ? "Presiona oro" :
     externalRelievesGold ? "Alivia oro" :
     "Mixto"

externalColor = not i_useExternal ? C_MUTED :
     externalPressuresGold ? C_RED :
     externalRelievesGold ? C_GREEN :
     C_AMBER

externalDetail = not i_useExternal ? "OFF" :
     "DXY " + (dxyBull ? "UP" : dxyBear ? "DN" : "NEU") +
     " | 10Y " + (us10yBull ? "UP" : us10yBear ? "DN" : "NEU") +
     " | 2Y " + (us02yBull ? "UP" : us02yBear ? "DN" : "NEU")

// ─────────────────────────────────────────────────────────
// MOTOR PORCENTUAL OBJETIVO
// ─────────────────────────────────────────────────────────
float bull = 0.0
float bear = 0.0

// Macro 30 pts
bull += macroClose > macroFast ? 6 : 0
bull += macroFast > macroSlow ? 6 : 0
bull += macroSlope > 0.25 ? 5 : macroSlope > 0 ? 3 : 0
bull += macroBosBull ? 5 : 0
bull += macroBullFVG ? 4 : 0
bull += macroClose > macroPH and not na(macroPH) ? 4 : 0

bear += macroClose < macroFast ? 6 : 0
bear += macroFast < macroSlow ? 6 : 0
bear += macroSlope < -0.25 ? 5 : macroSlope < 0 ? 3 : 0
bear += macroBosBear ? 5 : 0
bear += macroBearFVG ? 4 : 0
bear += macroClose < macroPL and not na(macroPL) ? 4 : 0

// HTF 25 pts
bull += htfClose > htfFast ? 5 : 0
bull += htfFast > htfSlow ? 5 : 0
bull += htfSlope > 0.20 ? 4 : htfSlope > 0 ? 2 : 0
bull += htfBosBull ? 5 : 0
bull += htfBullImp ? 3 : 0
bull += htfBullFVG ? 3 : 0

bear += htfClose < htfFast ? 5 : 0
bear += htfFast < htfSlow ? 5 : 0
bear += htfSlope < -0.20 ? 4 : htfSlope < 0 ? 2 : 0
bear += htfBosBear ? 5 : 0
bear += htfBearImp ? 3 : 0
bear += htfBearFVG ? 3 : 0

// Intradía 25 pts
bull += midClose > midFast ? 4 : 0
bull += midFast > midSlow ? 4 : 0
bull += midBosBull ? 5 : 0
bull += midBullImp ? 4 : 0
bull += midBullFVG ? 4 : 0
bull += exploringHigher ? 4 : 0

bear += midClose < midFast ? 4 : 0
bear += midFast < midSlow ? 4 : 0
bear += midBosBear ? 5 : 0
bear += midBearImp ? 4 : 0
bear += midBearFVG ? 4 : 0
bear += exploringLower ? 4 : 0

// Liquidez / intención 20 pts
bull += recentSweepLow ? 6 : 0
bull += bullAfterSweep ? 6 : 0
bull += upperTarget ? 4 : 0
bull += dayBiasBull ? 2 : 0
bull += daySweptLow ? 2 : 0

bear += recentSweepHigh ? 6 : 0
bear += bearAfterSweep ? 6 : 0
bear += lowerTarget ? 4 : 0
bear += dayBiasBear ? 2 : 0
bear += daySweptHigh ? 2 : 0

// Penalización suave por desequilibrio contrario activo
bull -= recentBearImbalance ? 6 : 0
bear -= recentBullImbalance ? 6 : 0

bull := f_clamp(bull, 0, 100)
bear := f_clamp(bear, 0, 100)
total = math.max(bull + bear, 1)
bullPct = math.round(bull / total * 100)
bearPct = math.round(bear / total * 100)
diffPct = math.abs(bullPct - bearPct)

contextProb = bullPct > bearPct ? "BULLISH" : bearPct > bullPct ? "BEARISH" : "MIXTO"
contextColor = contextProb == "BULLISH" ? C_GREEN : contextProb == "BEARISH" ? C_RED : C_AMBER
confidence = diffPct >= 25 ? "ALTA" : diffPct >= 12 ? "MEDIA" : "BAJA"

macroBullPts = (macroClose > macroFast ? 2 : 0) + (macroFast > macroSlow ? 2 : 0) + (macroSlope > 0.25 ? 2 : macroSlope > 0 ? 1 : 0) + (macroBosBull ? 2 : 0) + (macroBullImp ? 1 : 0) + (macroBullFVG ? 1 : 0)
macroBearPts = (macroClose < macroFast ? 2 : 0) + (macroFast < macroSlow ? 2 : 0) + (macroSlope < -0.25 ? 2 : macroSlope < 0 ? 1 : 0) + (macroBosBear ? 2 : 0) + (macroBearImp ? 1 : 0) + (macroBearFVG ? 1 : 0)
htfBullPts = (htfClose > htfFast ? 2 : 0) + (htfFast > htfSlow ? 2 : 0) + (htfSlope > 0.20 ? 2 : htfSlope > 0 ? 1 : 0) + (htfBosBull ? 2 : 0) + (htfBullImp ? 1 : 0) + (htfBullFVG ? 1 : 0)
htfBearPts = (htfClose < htfFast ? 2 : 0) + (htfFast < htfSlow ? 2 : 0) + (htfSlope < -0.20 ? 2 : htfSlope < 0 ? 1 : 0) + (htfBosBear ? 2 : 0) + (htfBearImp ? 1 : 0) + (htfBearFVG ? 1 : 0)
midBullPts = (midClose > midFast ? 2 : 0) + (midFast > midSlow ? 2 : 0) + (midBosBull ? 2 : 0) + (midBullImp ? 2 : 0) + (midBullFVG ? 1 : 0) + (exploringHigher ? 1 : 0)
midBearPts = (midClose < midFast ? 2 : 0) + (midFast < midSlow ? 2 : 0) + (midBosBear ? 2 : 0) + (midBearImp ? 2 : 0) + (midBearFVG ? 1 : 0) + (exploringLower ? 1 : 0)

macroDirBull = macroBullPts >= macroBearPts + 2
macroDirBear = macroBearPts >= macroBullPts + 2
htfDirBull = htfBullPts >= htfBearPts + 2
htfDirBear = htfBearPts >= htfBullPts + 2
midDirBull = midBullPts >= midBearPts + 2
midDirBear = midBearPts >= midBullPts + 2

macroText = macroDirBull ? "ALCISTA" : macroDirBear ? "BAJISTA" : "MIXTO"
htfText = htfDirBull ? "ALCISTA" : htfDirBear ? "BAJISTA" : "MIXTO"
midText = midDirBull ? "ALCISTA" : midDirBear ? "BAJISTA" : "MIXTO"
macroColor = macroDirBull ? C_GREEN : macroDirBear ? C_RED : C_AMBER
htfColor = htfDirBull ? C_GREEN : htfDirBear ? C_RED : C_AMBER
midColor = midDirBull ? C_GREEN : midDirBear ? C_RED : C_AMBER

alignedBull = macroDirBull and htfDirBull and midDirBull
alignedBear = macroDirBear and htfDirBear and midDirBear
macroHtfBullMidBear = macroDirBull and htfDirBull and midDirBear
macroHtfBearMidBull = macroDirBear and htfDirBear and midDirBull
macroBearStructBull = macroDirBear and htfDirBull and midDirBull
macroBullStructBear = macroDirBull and htfDirBear and midDirBear
twoOfThreeBull = (macroDirBull ? 1 : 0) + (htfDirBull ? 1 : 0) + (midDirBull ? 1 : 0) >= 2
twoOfThreeBear = (macroDirBear ? 1 : 0) + (htfDirBear ? 1 : 0) + (midDirBear ? 1 : 0) >= 2

imbText = recentBearImbalance and not recentBullImbalance ? "Intencion bajista activa" : recentBullImbalance and not recentBearImbalance ? "Intencion alcista activa" : recentBullImbalance and recentBearImbalance ? "Intencion mixta" : "Sin intencion dominante"
imbColor = recentBearImbalance and not recentBullImbalance ? C_RED : recentBullImbalance and not recentBearImbalance ? C_GREEN : C_AMBER

currentDoubleSweep = sweepHigh and sweepLow
recentDoubleSweep = recentSweepHigh and recentSweepLow
liqText = currentDoubleSweep ? "Liquidez bilateral tomada" :
     sweepLow ? "Lows tomados y rechazados" :
     sweepHigh ? "Highs tomados y rechazados" :
     recentDoubleSweep ? "Liquidez bilateral reciente" :
     recentSweepLow ? "Lows tomados recientemente" :
     recentSweepHigh ? "Highs tomados recientemente" :
     "Sin liquidez tomada"
liqColor = currentDoubleSweep or recentDoubleSweep ? C_AMBER : (sweepLow or recentSweepLow) ? C_GREEN : (sweepHigh or recentSweepHigh) ? C_RED : C_AMBER

// ─────────────────────────────────────────────────────────
// MATRIZ INSTITUCIONAL V6
// ─────────────────────────────────────────────────────────
matrizText = alignedBull ? "Alineacion alcista 3/3" :
     alignedBear ? "Alineacion bajista 3/3" :
     macroBearStructBull ? "Macro bajista / estructura alcista" :
     macroBullStructBear ? "Macro alcista / estructura bajista" :
     macroHtfBullMidBear ? "Pullback intradia en contexto alcista" :
     macroHtfBearMidBull ? "Pullback intradia en contexto bajista" :
     twoOfThreeBull ? "Mayoría alcista 2/3" :
     twoOfThreeBear ? "Mayoría bajista 2/3" :
     "Mixto / sin ventaja clara"

matrizColor = alignedBull ? C_GREEN :
     alignedBear ? C_RED :
     macroBearStructBull or macroBullStructBear or macroHtfBullMidBear or macroHtfBearMidBull ? C_AMBER :
     twoOfThreeBull ? C_GREEN :
     twoOfThreeBear ? C_RED :
     C_AMBER

regimenText = alignedBull or alignedBear ? "Expansion: contexto limpio" :
     macroBearStructBull or macroBullStructBear ? "Tactico: no exigir recorrido" :
     macroHtfBullMidBear or macroHtfBearMidBull ? "Pullback: esperar confirmacion" :
     "Espera: contexto abierto"

regimenColor = alignedBull or alignedBear ? C_GREEN :
     macroBearStructBull or macroBullStructBear or macroHtfBullMidBear or macroHtfBearMidBull ? C_AMBER :
     C_MUTED

condicionText = alignedBull or alignedBear ? "Validar setup en zona de valor" :
     macroBearStructBull ? "Macro contra estructura: trade tactico" :
     macroBullStructBear ? "Macro contra estructura: trade tactico" :
     macroHtfBullMidBear ? "Esperar recuperacion intradia o toma de lows" :
     macroHtfBearMidBull ? "Esperar recuperacion intradia o toma de highs" :
     recentBearImbalance and contextProb == "BULLISH" ? "Impulso contrario activo" :
     recentBullImbalance and contextProb == "BEARISH" ? "Impulso contrario activo" :
     "Esperar que el precio revele intencion"

condicionColor = alignedBull or alignedBear ? C_GREEN :
     macroBearStructBull or macroBullStructBear or macroHtfBullMidBear or macroHtfBearMidBull ? C_AMBER :
     C_MUTED

clearBullMatrix = alignedBull or macroHtfBullMidBear
clearBearMatrix = alignedBear or macroHtfBearMidBull
externalAgainstBalance = (clearBullMatrix and externalPressuresGold) or (clearBearMatrix and externalRelievesGold)
externalSupportsBalance = (clearBullMatrix and externalRelievesGold) or (clearBearMatrix and externalPressuresGold)
externalSupportText = not i_useExternal ? "OFF" :
     externalSupportsBalance ? "Acompaña contexto" :
     externalAgainstBalance ? "No acompaña contexto" :
     "Sin confirmacion externa"
externalPanelText = not i_useExternal ? "OFF" : externalMixed ? "Externo mixto / sin confirmacion" : externalText + " | " + externalSupportText
externalPanelColor = externalAgainstBalance ? C_AMBER : externalSupportsBalance ? C_GREEN : externalColor

// ─────────────────────────────────────────────────────────
// PANEL
// ─────────────────────────────────────────────────────────
var table dash = table.new(f_pos(i_pos), 2, 14, frame_width=1, frame_color=C_DIV, border_width=1, border_color=C_DIV)

if barstate.islast
    table.cell(dash, 0, 0, "  SISTEMA DE MOISÉS", text_color=C_CYAN, bgcolor=C_BG, text_size=f_head(), text_halign=text.align_left)
    table.cell(dash, 1, 0, "MATRIZ V6  ", text_color=C_MUTED, bgcolor=C_BG, text_size=f_txt(), text_halign=text.align_right)

    table.cell(dash, 0, 1, "  ESTADO DEL MERCADO", text_color=C_TEXT, bgcolor=C_PANEL, text_size=f_head(), text_halign=text.align_left)
    table.cell(dash, 1, 1, matrizText + "  ", text_color=matrizColor, bgcolor=C_PANEL, text_size=f_head(), text_halign=text.align_right)

    f_cell(dash, 0, 2, "  Capas", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 2, "Macro " + macroText + " | HTF " + htfText + " | Intra " + midText + "  ", matrizColor, C_ROW, text.align_right)

    f_cell(dash, 0, 3, "  Régimen", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 3, regimenText + "  ", regimenColor, C_PANEL, text.align_right)

    table.cell(dash, 0, 4, "  ─────────────────", text_color=C_DIV, bgcolor=C_BG, text_size=f_txt(), text_halign=text.align_left)
    table.cell(dash, 1, 4, "", bgcolor=C_BG)

    f_cell(dash, 0, 5, "  Liquidez", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 5, liqText + "  ", liqColor, C_ROW, text.align_right)

    f_cell(dash, 0, 6, "  Intención", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 6, imbText + "  ", imbColor, C_PANEL, text.align_right)

    f_cell(dash, 0, 7, "  Ubicación", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 7, (inDiscount ? "Descuento" : inPremium ? "Premium" : "Equilibrio") + " " + str.tostring(math.round(posPct)) + "%  ", inDiscount ? C_GREEN : inPremium ? C_RED : C_AMBER, C_ROW, text.align_right)

    f_cell(dash, 0, 8, "  Sesión", C_MUTED, C_PANEL, text.align_left)
    f_cell(dash, 1, 8, sessionText + "  ", (inNY or inLondon) ? C_GREEN : (inAsia or inNYpm) ? C_CYAN : C_MUTED, C_PANEL, text.align_right)

    f_cell(dash, 0, 9, "  Externo", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 9, externalPanelText + "  ", externalPanelColor, C_ROW, text.align_right)

    f_cell(dash, 0, 10, "  DXY / 10Y / 2Y", C_MUTED, C_PANEL, text.align_left)
    f_cell(dash, 1, 10, externalDetail + "  ", externalColor, C_PANEL, text.align_right)

    f_cell(dash, 0, 11, "  Balance técnico", C_MUTED, C_ROW, text.align_left)
    f_cell(dash, 1, 11, str.tostring(bullPct) + "% / " + str.tostring(bearPct) + "% | " + confidence + "  ", contextColor, C_ROW, text.align_right)

    f_cell(dash, 0, 12, "  Condición", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 12, condicionText + "  ", condicionColor, C_PANEL, text.align_right)

    f_cell(dash, 0, 13, "  Uso", C_AMBER, C_BG, text.align_left)
    f_cell(dash, 1, 13, "Contexto, no señal.  ", C_AMBER, C_BG, text.align_right)
````
