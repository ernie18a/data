# EURUSD Asian Session Engulfing Visualizer

- url: https://www.tradingview.com/script/mTbhftkB/
- type: indicator
- pine_id: PUB;d62d30e2009440d593873a7c6dceb0e6
- version: 1.0

## Description

- Marcar el maximo y minimo de la sesion asiatica en UTC +2 Madrid en 5 min en EUR/USD de 8am a 9am UTC+2 Madrid
- La primera vela envolvente a partir de las 8:05 UTC +2 Madrid no sirve para confirmar la entrada pendiente que haremos a mercado.
- Se realizaran dos operacion simultaneas apostandonos un 2% en cada una, la primera operacion nos apostamos un 2% de un capital de 50.000 euros con un ratio de operacion perdida ganacia de 1 a 1 en el que el SL son 5,5 pips y la entrada esta en el cuerpo de la vela que ha sido envuelta, y la segunda operacion en la que nos apostariamos otro 2% de 50.000 euros tendria un relacion 1 a 2 de perdida ganancia en el que la entrada estaria en el cuerpo de la vela que ha sido envuelta, el SL a 5,5 pips de la entrada y cuando en esta operacion el precio llega al 1 a 1 es decir a 5,5 pips de beneficio el Sl se mueveautomaticamente a BE y se deja terminar la operacion para que llegue al TP o a BE.

- En el caso de que todavia no hemos hecho la entrada a mercado porque no ha aparecido una vela envolvente pero manipula el maximo asitico anterior solo se permitira entrar a mercado con velas envolvente bajistas y en el caso de que haya manipulador el minimo asiatico de la sesion anterior solo nos permitirian entrar a mercado velas envolventes alcistas de 8 a 9 am UTC +2

## Source Code

````pine

//@version=5
indicator("EURUSD Asian Session Engulfing Visualizer", overlay = true, max_lines_count = 500, max_labels_count = 500)

string sessionTimezone = input.string("Europe/Madrid", "Zona horaria")
float accountCapital = input.float(50000.0, "Capital de referencia", step = 1000.0, minval = 1000.0)
float riskPercentPerTrade = input.float(2.0, "Riesgo por operacion (%)", step = 0.1, minval = 0.1)
float stopLossPips = input.float(5.5, "Stop loss (pips)", step = 0.1, minval = 0.1)
int asianStartHour = input.int(0, "Inicio sesion asiatica", minval = 0, maxval = 23)
int asianEndHour = input.int(8, "Fin sesion asiatica", minval = 0, maxval = 23)
int tradeStartHour = input.int(8, "Inicio ventana operativa", minval = 0, maxval = 23)
int firstSignalMinute = input.int(5, "Primer minuto valido para buscar envolventes", minval = 0, maxval = 59)
int tradeEndHour = input.int(9, "Fin ventana operativa", minval = 0, maxval = 23)
bool showAsianRange = input.bool(true, "Mostrar maximo y minimo asiatico")
bool showInfoTable = input.bool(true, "Mostrar panel informativo")

float pipSize = syminfo.mintick * 10.0
float stopDistance = stopLossPips * pipSize
float riskMoney = accountCapital * riskPercentPerTrade / 100.0

f_minute_of_day(_time, _timezone) =>
    hour(_time, _timezone) * 60 + minute(_time, _timezone)

f_day_key(_time, _timezone) =>
    year(_time, _timezone) * 10000 + month(_time, _timezone) * 100 + dayofmonth(_time, _timezone)

f_detect_engulfing() =>
    float currentBodyHigh = math.max(open, close)
    float currentBodyLow = math.min(open, close)
    float previousBodyHigh = math.max(open[1], close[1])
    float previousBodyLow = math.min(open[1], close[1])
    bool bullishCurrent = close > open
    bool bearishCurrent = close < open
    bool bullishPrevious = close[1] > open[1]
    bool bearishPrevious = close[1] < open[1]
    bool bodyEngulfs = currentBodyHigh >= previousBodyHigh and currentBodyLow <= previousBodyLow
    bullishCurrent and bearishPrevious and bodyEngulfs ? 1 : bearishCurrent and bullishPrevious and bodyEngulfs ? -1 : 0

f_bias_text(_bias) =>
    _bias == 1 ? "Solo largos" : _bias == -1 ? "Solo cortos" : _bias == 2 ? "Dia bloqueado" : "Neutral"

f_direction_text(_direction) =>
    _direction == 1 ? "LONG" : _direction == -1 ? "SHORT" : "NONE"

f_finalize_line(_line, _x2) =>
    if not na(_line)
        line.set_extend(_line, extend.none)
        line.set_x2(_line, _x2)

bool isFiveMinuteChart = timeframe.isminutes and timeframe.multiplier == 5
bool isEurUsd = str.contains(str.upper(syminfo.tickerid), "EURUSD")

int minuteOfDay = f_minute_of_day(time, sessionTimezone)
int dayKey = f_day_key(time, sessionTimezone)
bool inAsianSession = minuteOfDay >= asianStartHour * 60 and minuteOfDay < asianEndHour * 60
bool inTradeWindow = minuteOfDay >= tradeStartHour * 60 and minuteOfDay < tradeEndHour * 60
bool afterFirstSignalTime = minuteOfDay >= tradeStartHour * 60 + firstSignalMinute

var int currentDayKey = na
var float asianHigh = na
var float asianLow = na
var bool asianReady = false
var bool firstEngulfingSkipped = false
var int entryBias = 0
var bool daySetupLocked = false

var bool pendingSetup = false
var int pendingDirection = 0
var int pendingDayKey = na
var int signalBarIndex = na
var float entryPrice = na
var float stopLossPrice = na
var float takeProfitOne = na
var float takeProfitTwo = na
var float breakEvenTrigger = na

var bool tradeOneActive = false
var bool tradeTwoActive = false
var bool tradeTwoMovedToBe = false
var float tradeTwoCurrentStop = na
var int entryBarIndex = na

var line activeEntryLine = na
var line activeStopLine = na
var line activeTpOneLine = na
var line activeTpTwoLine = na

var table infoTable = table.new(position.top_right, 1, 1, border_width = 1)

bool setupAcceptedThisBar = false
bool entryTriggeredThisBar = false
bool tradeOneClosedThisBar = false
bool tradeTwoClosedThisBar = false

if barstate.isconfirmed
    setupAcceptedThisBar := false
    entryTriggeredThisBar := false
    tradeOneClosedThisBar := false
    tradeTwoClosedThisBar := false

    if pendingSetup
        bool pendingExpired = dayKey != pendingDayKey or minuteOfDay >= tradeEndHour * 60
        if pendingExpired
            label.new(bar_index, entryPrice, "Orden pendiente cancelada\nNo hubo retorno antes de las " + str.tostring(tradeEndHour, "00") + ":00", style = label.style_label_left, color = color.new(color.gray, 0), textcolor = color.white)
            f_finalize_line(activeEntryLine, bar_index)
            f_finalize_line(activeStopLine, bar_index)
            f_finalize_line(activeTpOneLine, bar_index)
            f_finalize_line(activeTpTwoLine, bar_index)
            activeEntryLine := na
            activeStopLine := na
            activeTpOneLine := na
            activeTpTwoLine := na
            pendingSetup := false
        else if bar_index > signalBarIndex and low <= entryPrice and high >= entryPrice
            pendingSetup := false
            tradeOneActive := true
            tradeTwoActive := true
            tradeTwoMovedToBe := false
            tradeTwoCurrentStop := stopLossPrice
            entryBarIndex := bar_index
            entryTriggeredThisBar := true
            label.new(bar_index, entryPrice, "Entrada activada\n" + f_direction_text(pendingDirection), style = pendingDirection == 1 ? label.style_label_up : label.style_label_down, color = color.new(color.yellow, 0), textcolor = color.black)

    if tradeOneActive
        if pendingDirection == 1
            bool stopHit = low <= stopLossPrice
            bool tpHit = high >= takeProfitOne
            if stopHit
                tradeOneActive := false
                tradeOneClosedThisBar := true
                label.new(bar_index, stopLossPrice, "Operacion 1 cerrada\nSL", style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white)
            else if tpHit
                tradeOneActive := false
                tradeOneClosedThisBar := true
                label.new(bar_index, takeProfitOne, "Operacion 1 cerrada\nTP 1:1", style = label.style_label_up, color = color.new(color.green, 0), textcolor = color.white)
        else if pendingDirection == -1
            bool stopHit = high >= stopLossPrice
            bool tpHit = low <= takeProfitOne
            if stopHit
                tradeOneActive := false
                tradeOneClosedThisBar := true
                label.new(bar_index, stopLossPrice, "Operacion 1 cerrada\nSL", style = label.style_label_up, color = color.new(color.red, 0), textcolor = color.white)
            else if tpHit
                tradeOneActive := false
                tradeOneClosedThisBar := true
                label.new(bar_index, takeProfitOne, "Operacion 1 cerrada\nTP 1:1", style = label.style_label_down, color = color.new(color.green, 0), textcolor = color.white)

    if tradeTwoActive
        if pendingDirection == 1
            if not tradeTwoMovedToBe
                bool stopHit = low <= stopLossPrice
                bool oneRHit = high >= breakEvenTrigger
                if stopHit
                    tradeTwoActive := false
                    tradeTwoClosedThisBar := true
                    label.new(bar_index, stopLossPrice, "Operacion 2 cerrada\nSL", style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white)
                else if oneRHit
                    tradeTwoMovedToBe := true
                    tradeTwoCurrentStop := entryPrice
                    bool beHit = low <= entryPrice
                    bool tpHit = high >= takeProfitTwo
                    if beHit
                        tradeTwoActive := false
                        tradeTwoClosedThisBar := true
                        label.new(bar_index, entryPrice, "Operacion 2 cerrada\nBE", style = label.style_label_down, color = color.new(color.orange, 0), textcolor = color.white)
                    else if tpHit
                        tradeTwoActive := false
                        tradeTwoClosedThisBar := true
                        label.new(bar_index, takeProfitTwo, "Operacion 2 cerrada\nTP 1:2", style = label.style_label_up, color = color.new(color.green, 0), textcolor = color.white)
            else
                bool beHit = low <= entryPrice
                bool tpHit = high >= takeProfitTwo
                if beHit
                    tradeTwoActive := false
                    tradeTwoClosedThisBar := true
                    label.new(bar_index, entryPrice, "Operacion 2 cerrada\nBE", style = label.style_label_down, color = color.new(color.orange, 0), textcolor = color.white)
                else if tpHit
                    tradeTwoActive := false
                    tradeTwoClosedThisBar := true
                    label.new(bar_index, takeProfitTwo, "Operacion 2 cerrada\nTP 1:2", style = label.style_label_up, color = color.new(color.green, 0), textcolor = color.white)
        else if pendingDirection == -1
            if not tradeTwoMovedToBe
                bool stopHit = high >= stopLossPrice
                bool oneRHit = low <= breakEvenTrigger
                if stopHit
                    tradeTwoActive := false
                    tradeTwoClosedThisBar := true
                    label.new(bar_index, stopLossPrice, "Operacion 2 cerrada\nSL", style = label.style_label_up, color = color.new(color.red, 0), textcolor = color.white)
                else if oneRHit
                    tradeTwoMovedToBe := true
                    tradeTwoCurrentStop := entryPrice
                    bool beHit = high >= entryPrice
                    bool tpHit = low <= takeProfitTwo
                    if beHit
                        tradeTwoActive := false
                        tradeTwoClosedThisBar := true
                        label.new(bar_index, entryPrice, "Operacion 2 cerrada\nBE", style = label.style_label_up, color = color.new(color.orange, 0), textcolor = color.white)
                    else if tpHit
                        tradeTwoActive := false
                        tradeTwoClosedThisBar := true
                        label.new(bar_index, takeProfitTwo, "Operacion 2 cerrada\nTP 1:2", style = label.style_label_down, color = color.new(color.green, 0), textcolor = color.white)
            else
                bool beHit = high >= entryPrice
                bool tpHit = low <= takeProfitTwo
                if beHit
                    tradeTwoActive := false
                    tradeTwoClosedThisBar := true
                    label.new(bar_index, entryPrice, "Operacion 2 cerrada\nBE", style = label.style_label_up, color = color.new(color.orange, 0), textcolor = color.white)
                else if tpHit
                    tradeTwoActive := false
                    tradeTwoClosedThisBar := true
                    label.new(bar_index, takeProfitTwo, "Operacion 2 cerrada\nTP 1:2", style = label.style_label_down, color = color.new(color.green, 0), textcolor = color.white)

    if (tradeOneClosedThisBar or tradeTwoClosedThisBar) and not tradeOneActive and not tradeTwoActive and not pendingSetup
        f_finalize_line(activeEntryLine, bar_index)
        f_finalize_line(activeStopLine, bar_index)
        f_finalize_line(activeTpOneLine, bar_index)
        f_finalize_line(activeTpTwoLine, bar_index)
        activeEntryLine := na
        activeStopLine := na
        activeTpOneLine := na
        activeTpTwoLine := na
        entryPrice := na
        stopLossPrice := na
        takeProfitOne := na
        takeProfitTwo := na
        breakEvenTrigger := na
        pendingDirection := 0
        tradeTwoCurrentStop := na

    bool isNewDay = na(currentDayKey) or dayKey != currentDayKey
    if isNewDay
        currentDayKey := dayKey
        asianHigh := na
        asianLow := na
        asianReady := false
        firstEngulfingSkipped := false
        entryBias := 0
        daySetupLocked := false

    if inAsianSession
        asianHigh := na(asianHigh) ? high : math.max(asianHigh, high)
        asianLow := na(asianLow) ? low : math.min(asianLow, low)
        asianReady := true

    bool canSearchSetup = asianReady and inTradeWindow and not daySetupLocked and not na(open[1]) and not na(close[1])
    if canSearchSetup
        float tolerance = syminfo.mintick * 0.5
        bool sweptHigh = high > asianHigh + tolerance or math.abs(high - asianHigh) <= tolerance
        bool sweptLow = low < asianLow - tolerance or math.abs(low - asianLow) <= tolerance

        if entryBias != 2
            if sweptHigh and sweptLow
                entryBias := 2
                label.new(bar_index, high, "Barrido de ambos extremos\nDia bloqueado", style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white)
            else if sweptHigh
                if entryBias == 1
                    entryBias := 2
                    label.new(bar_index, high, "Barrido de ambos lados\nDia bloqueado", style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white)
                else if entryBias != -1
                    entryBias := -1
                    label.new(bar_index, high, "Barrido del maximo asiatico\nSolo cortos", style = label.style_label_down, color = color.new(color.orange, 0), textcolor = color.white)
            else if sweptLow
                if entryBias == -1
                    entryBias := 2
                    label.new(bar_index, low, "Barrido de ambos lados\nDia bloqueado", style = label.style_label_up, color = color.new(color.red, 0), textcolor = color.white)
                else if entryBias != 1
                    entryBias := 1
                    label.new(bar_index, low, "Barrido del minimo asiatico\nSolo largos", style = label.style_label_up, color = color.new(color.orange, 0), textcolor = color.white)

        if afterFirstSignalTime
            int direction = f_detect_engulfing()
            bool isEngulfing = direction != 0
            if isEngulfing and not firstEngulfingSkipped
                firstEngulfingSkipped := true
                label.new(bar_index, direction == 1 ? low : high, "Primera envolvente ignorada", style = direction == 1 ? label.style_label_up : label.style_label_down, color = color.new(color.gray, 0), textcolor = color.white)
            else if isEngulfing
                bool directionAllowed = entryBias == 0 or entryBias == direction
                bool dayEnabled = entryBias != 2
                if directionAllowed and dayEnabled
                    pendingDirection := direction
                    pendingDayKey := dayKey
                    signalBarIndex := bar_index
                    entryPrice := close[1]
                    stopLossPrice := direction == 1 ? entryPrice - stopDistance : entryPrice + stopDistance
                    takeProfitOne := direction == 1 ? entryPrice + stopDistance : entryPrice - stopDistance
                    takeProfitTwo := direction == 1 ? entryPrice + 2.0 * stopDistance : entryPrice - 2.0 * stopDistance
                    breakEvenTrigger := takeProfitOne
                    pendingSetup := true
                    daySetupLocked := true
                    setupAcceptedThisBar := true
                    tradeOneActive := false
                    tradeTwoActive := false
                    tradeTwoMovedToBe := false
                    tradeTwoCurrentStop := stopLossPrice
                    activeEntryLine := line.new(bar_index, entryPrice, bar_index + 1, entryPrice, extend = extend.right, color = color.new(color.yellow, 0), width = 2)
                    activeStopLine := line.new(bar_index, stopLossPrice, bar_index + 1, stopLossPrice, extend = extend.right, color = color.new(color.red, 0), width = 2)
                    activeTpOneLine := line.new(bar_index, takeProfitOne, bar_index + 1, takeProfitOne, extend = extend.right, color = color.new(color.green, 0), width = 2)
                    activeTpTwoLine := line.new(bar_index, takeProfitTwo, bar_index + 1, takeProfitTwo, extend = extend.right, color = color.new(color.aqua, 0), width = 2)
                    string setupText = str.format("Setup {0}\nEntrada: {1}\nSL: {2}\nTP1: {3}\nTP2: {4}\nRiesgo/op: {5} EUR", f_direction_text(direction), str.tostring(entryPrice, format.mintick), str.tostring(stopLossPrice, format.mintick), str.tostring(takeProfitOne, format.mintick), str.tostring(takeProfitTwo, format.mintick), str.tostring(riskMoney, "#.##"))
                    label.new(bar_index, direction == 1 ? low : high, setupText, style = direction == 1 ? label.style_label_up : label.style_label_down, color = color.new(direction == 1 ? color.green : color.red, 0), textcolor = color.white)
                else
                    label.new(bar_index, direction == 1 ? low : high, "Envolvente bloqueada\npor filtro asiatico", style = direction == 1 ? label.style_label_up : label.style_label_down, color = color.new(color.maroon, 0), textcolor = color.white)

plot(showAsianRange and asianReady ? asianHigh : na, "Maximo asiatico", color.new(color.red, 0), 2, plot.style_linebr)
plot(showAsianRange and asianReady ? asianLow : na, "Minimo asiatico", color.new(color.blue, 0), 2, plot.style_linebr)
plot(showAsianRange and tradeTwoActive and tradeTwoMovedToBe ? entryPrice : na, "BE operacion 2", color.new(color.orange, 0), 1, plot.style_linebr)

alertcondition(setupAcceptedThisBar and pendingDirection == 1, "Setup long valido", "Se ha detectado un setup long valido en EURUSD M5.")
alertcondition(setupAcceptedThisBar and pendingDirection == -1, "Setup short valido", "Se ha detectado un setup short valido en EURUSD M5.")
alertcondition(entryTriggeredThisBar, "Entrada activada", "El precio ha vuelto al cierre de la vela envuelta y la entrada se ha activado.")

if showInfoTable and barstate.islast
    string contextText = not isFiveMinuteChart ? "Usa M5" : not isEurUsd ? "Usa EURUSD" : "Contexto correcto"
    string liveBiasText = f_bias_text(entryBias)
    string liveTradeText = pendingSetup ? "Pendiente" : (tradeOneActive or tradeTwoActive ? "En curso" : "Sin operacion")
    string tableText = str.format("Visualizer EURUSD M5\nContexto: {0}\nBias del dia: {1}\nEstado: {2}\nCapital ref: {3} EUR\nRiesgo/op: {4} EUR\nSL fijo: {5} pips\nSesion asiatica: {6}:00-{7}:00\nVentana trade: {8}:00-{9}:00", contextText, liveBiasText, liveTradeText, str.tostring(accountCapital, "#"), str.tostring(riskMoney, "#.##"), str.tostring(stopLossPips, "#.##"), str.tostring(asianStartHour, "00"), str.tostring(asianEndHour, "00"), str.tostring(tradeStartHour, "00"), str.tostring(tradeEndHour, "00"))
````
