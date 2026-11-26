# Sistema de Moises - Contexto Porcentual V3 DXY/Yields

- url: https://www.tradingview.com/script/59AglKAE/
- type: indicator
- pine_id: PUB;37f36fd0aaaa44838255fb1bf65a5358
- version: 1.0

## Description

Describe el contexto macro del dolar para usarlo como direccion divergente

## Source Code

````pine
//@version=6
indicator("Sistema de Moises - Contexto Porcentual V3 DXY/Yields", overlay=true, max_lines_count=20, max_labels_count=20, max_boxes_count=5)

// Contexto Porcentual V3 — Macro + HTF + Intradia + Liquidez + Desequilibrio + DXY/Yields
// No da entradas. Mide probabilidad contextual Bullish/Bearish para que el trader construya la tesis.
// Sistema de Moises — No operes el dibujo. Opera la intención.
// Stable: la lectura operativa se ancla al timeframe intradía configurado para no cambiar al mirar otro TF.
// V3: agrega presión externa automática para XAUUSD usando DXY + US10Y + US02Y.

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
i_useExternal = input.bool(true, "Usar presión externa para oro", group=G4)
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
// PRESIÓN EXTERNA PARA XAUUSD
// DXY/Yields arriba suelen presionar oro a la baja.
// DXY/Yields abajo suelen darle alivio/soporte a oro.
// ─────────────────────────────────────────────────────────
extBearScore = (dxyBull ? 1 : 0) + (us10yBull ? 1 : 0) + (us02yBull ? 1 : 0)
extBullScore = (dxyBear ? 1 : 0) + (us10yBear ? 1 : 0) + (us02yBear ? 1 : 0)

externalBearGold = i_useExternal and extBearScore >= 2 and extBearScore > extBullScore
externalBullGold = i_useExternal and extBullScore >= 2 and extBullScore > extBearScore
externalMixed = i_useExternal and not externalBearGold and not externalBullGold

externalText = not i_useExternal ? "Desactivado" :
     externalBearGold ? "Presión bajista oro" :
     externalBullGold ? "Presión alcista oro" :
     "Mixto / sin apoyo claro"

externalColor = not i_useExternal ? C_MUTED :
     externalBearGold ? C_RED :
     externalBullGold ? C_GREEN :
     C_AMBER

externalDetail = not i_useExternal ? "OFF" :
     "DXY " + (dxyBull ? "↑" : dxyBear ? "↓" : "→") +
     " | 10Y " + (us10yBull ? "↑" : us10yBear ? "↓" : "→") +
     " | 2Y " + (us02yBull ? "↑" : us02yBear ? "↓" : "→")

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

// Presión externa V3: peso moderado, no reemplaza estructura/precio.
bull += i_useExternal ? extBullScore * 4 : 0
bear += i_useExternal ? extBearScore * 4 : 0

bull := f_clamp(bull, 0, 100)
bear := f_clamp(bear, 0, 100)
total = math.max(bull + bear, 1)
bullPct = math.round(bull / total * 100)
bearPct = math.round(bear / total * 100)
diffPct = math.abs(bullPct - bearPct)

contextProb = bullPct > bearPct ? "BULLISH" : bearPct > bullPct ? "BEARISH" : "MIXTO"
contextColor = contextProb == "BULLISH" ? C_GREEN : contextProb == "BEARISH" ? C_RED : C_AMBER
confidence = diffPct >= 25 ? "ALTA" : diffPct >= 12 ? "MEDIA" : "BAJA"

imbText = recentBearImbalance and not recentBullImbalance ? "DESEQUILIBRIO BAJISTA" : recentBullImbalance and not recentBearImbalance ? "DESEQUILIBRIO ALCISTA" : recentBullImbalance and recentBearImbalance ? "DESEQUILIBRIO MIXTO" : "Sin desequilibrio claro"
imbColor = recentBearImbalance and not recentBullImbalance ? C_RED : recentBullImbalance and not recentBearImbalance ? C_GREEN : C_AMBER

currentDoubleSweep = sweepHigh and sweepLow
recentDoubleSweep = recentSweepHigh and recentSweepLow
liqText = currentDoubleSweep ? "Doble sweep confirmado" :
     sweepLow ? "Sweep lows confirmado" :
     sweepHigh ? "Sweep highs confirmado" :
     recentDoubleSweep ? "Doble sweep en memoria" :
     recentSweepLow ? "Lows recientes en memoria" :
     recentSweepHigh ? "Highs recientes en memoria" :
     "Sin sweep confirmado"
liqColor = currentDoubleSweep or recentDoubleSweep ? C_AMBER : (sweepLow or recentSweepLow) ? C_GREEN : (sweepHigh or recentSweepHigh) ? C_RED : C_AMBER

// ─────────────────────────────────────────────────────────
// ESCENARIO V3
// ─────────────────────────────────────────────────────────
macroDirBull = macroClose > macroFast
macroDirBear = macroClose < macroFast
htfDirBull = htfClose > htfFast
htfDirBear = htfClose < htfFast
midDirBull = exploringHigher or midClose > midFast
midDirBear = exploringLower or midClose < midFast

longContinuation = macroDirBull and htfDirBull and midDirBull
shortContinuation = macroDirBear and htfDirBear and midDirBear
bullPullback = macroDirBull and htfDirBull and midDirBear
bearPullback = macroDirBear and htfDirBear and midDirBull
macroBearStructBull = macroDirBear and htfDirBull and midDirBull
macroBullStructBear = macroDirBull and htfDirBear and midDirBear

scenarioText = longContinuation ? "Long continuación" :
     shortContinuation ? "Short continuación" :
     bullPullback ? "Pullback alcista: esperar reclaim" :
     bearPullback ? "Pullback bajista: esperar reclaim" :
     macroBearStructBull ? "Macro Bear vs estructura Bull" :
     macroBullStructBear ? "Macro Bull vs estructura Bear" :
     "Contexto mixto"

scenarioColor = longContinuation or bullPullback ? C_GREEN :
     shortContinuation or bearPullback ? C_RED :
     macroBearStructBull or macroBullStructBear ? C_AMBER :
     C_MUTED

managementText = longContinuation or shortContinuation ? "Expansión permitida / runner" :
     macroBearStructBull ? "Short táctico 1R-1.2R / long contra macro" :
     macroBullStructBear ? "Long táctico 1R-1.2R / short contra macro" :
     bullPullback or bearPullback ? "Esperar reclaim / ChoCH" :
     "Esperar claridad"

managementColor = longContinuation or shortContinuation ? C_GREEN :
     macroBearStructBull or macroBullStructBear ? C_AMBER :
     C_MUTED

targetText = confidence == "BAJA" ? "Esperar confirmación / contexto mixto" :
     contextProb == "BULLISH" ? "Buscar compras hacia liquidez superior" :
     contextProb == "BEARISH" ? "Buscar ventas hacia liquidez inferior" :
     "Esperar ruptura de intención"

warningText = contextProb == "BULLISH" and recentBearImbalance ? "Oferta cercana: esperar reclaim/ChoCH" :
     contextProb == "BEARISH" and recentBullImbalance ? "Demanda cercana: esperar reclaim/ChoCH" :
     macroBearStructBull ? "Si vendes macro: táctico, no expansión" :
     macroBullStructBear ? "Si compras macro: táctico, no expansión" :
     externalBearGold and contextProb == "BULLISH" ? "DXY/Yields presionan contra longs" :
     externalBullGold and contextProb == "BEARISH" ? "DXY/Yields presionan contra shorts" :
     exploringLower ? "Precio explora abajo: no comprar sin reclaim" :
     exploringHigher ? "Precio explora arriba: no vender sin reclaim" :
     "Armar tesis manual"

// ─────────────────────────────────────────────────────────
// PANEL
// ─────────────────────────────────────────────────────────
var table dash = table.new(f_pos(i_pos), 2, 18, frame_width=1, frame_color=C_DIV, border_width=1, border_color=C_DIV)

if barstate.islast
    table.cell(dash, 0, 0, "  SISTEMA DE MOISÉS", text_color=C_CYAN, bgcolor=C_BG, text_size=f_head(), text_halign=text.align_left)
    table.cell(dash, 1, 0, "CONTEXTO % V3  ", text_color=C_MUTED, bgcolor=C_BG, text_size=f_txt(), text_halign=text.align_right)

    table.cell(dash, 0, 1, "  CONTEXTO PROBABLE", text_color=C_TEXT, bgcolor=C_PANEL, text_size=f_head(), text_halign=text.align_left)
    table.cell(dash, 1, 1, contextProb + "  ", text_color=contextColor, bgcolor=C_PANEL, text_size=f_head(), text_halign=text.align_right)

    f_cell(dash, 0, 2, "  Bullish / Bearish", C_MUTED, C_ROW, text.align_left)
    f_cell(dash, 1, 2, str.tostring(bullPct) + "% / " + str.tostring(bearPct) + "%  ", contextColor, C_ROW, text.align_right)

    f_cell(dash, 0, 3, "  Confianza", C_MUTED, C_PANEL, text.align_left)
    f_cell(dash, 1, 3, confidence + "  ", confidence == "ALTA" ? C_GREEN : confidence == "MEDIA" ? C_AMBER : C_MUTED, C_PANEL, text.align_right)

    table.cell(dash, 0, 4, "  ─────────────────", text_color=C_DIV, bgcolor=C_BG, text_size=f_txt(), text_halign=text.align_left)
    table.cell(dash, 1, 4, "", bgcolor=C_BG)

    f_cell(dash, 0, 5, "  Macro", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 5, (macroClose > macroFast ? "Bull" : macroClose < macroFast ? "Bear" : "Mixto") + " | " + i_tfMacro + "  ", macroClose > macroFast ? C_GREEN : C_RED, C_ROW, text.align_right)

    f_cell(dash, 0, 6, "  HTF", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 6, (htfClose > htfFast ? "Bull" : htfClose < htfFast ? "Bear" : "Mixto") + " | " + i_tfHTF + "  ", htfClose > htfFast ? C_GREEN : C_RED, C_PANEL, text.align_right)

    f_cell(dash, 0, 7, "  Intradía", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 7, (exploringLower ? "Explora abajo" : exploringHigher ? "Explora arriba" : midClose > midFast ? "Bull" : midClose < midFast ? "Bear" : "Mixto") + "  ", exploringLower ? C_RED : exploringHigher ? C_GREEN : midClose > midFast ? C_GREEN : C_RED, C_ROW, text.align_right)

    f_cell(dash, 0, 8, "  Liquidez", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 8, liqText + "  ", liqColor, C_PANEL, text.align_right)

    f_cell(dash, 0, 9, "  Desequilibrio", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 9, imbText + "  ", imbColor, C_ROW, text.align_right)

    f_cell(dash, 0, 10, "  Ubicación", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 10, (inDiscount ? "Descuento" : inPremium ? "Premium" : "Equilibrio") + " " + str.tostring(math.round(posPct)) + "%  ", inDiscount ? C_GREEN : inPremium ? C_RED : C_AMBER, C_PANEL, text.align_right)

    f_cell(dash, 0, 11, "  Sesión", C_MUTED, C_ROW, text.align_left)
    f_cell(dash, 1, 11, sessionText + "  ", (inNY or inLondon) ? C_GREEN : (inAsia or inNYpm) ? C_CYAN : C_MUTED, C_ROW, text.align_right)

    f_cell(dash, 0, 12, "  DXY/Yields", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 12, externalText + "  ", externalColor, C_PANEL, text.align_right)

    f_cell(dash, 0, 13, "  Detalle externo", C_MUTED, C_ROW, text.align_left)
    f_cell(dash, 1, 13, externalDetail + "  ", externalColor, C_ROW, text.align_right)

    f_cell(dash, 0, 14, "  Escenario V3", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 14, scenarioText + "  ", scenarioColor, C_PANEL, text.align_right)

    f_cell(dash, 0, 15, "  Gestión", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 15, managementText + "  ", managementColor, C_ROW, text.align_right)

    f_cell(dash, 0, 16, "  Lectura", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 16, targetText + "  ", contextColor, C_PANEL, text.align_right)

    f_cell(dash, 0, 17, "  Nota", C_AMBER, C_BG, text.align_left)
    f_cell(dash, 1, 17, warningText + "  ", C_AMBER, C_BG, text.align_right)
````
