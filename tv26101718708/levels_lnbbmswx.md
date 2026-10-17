# Levels

- url: https://www.tradingview.com/script/LnBBMSwx-levels/
- type: indicator
- pine_id: PUB;311542567baf4b5ea9dbe2524da589e2
- version: 1.0

## Description

Title: Swing Levels with Chop Detection and Hold Alerts
This indicator draws horizontal levels from confirmed swing highs and lows, ends levels when repeated candle crossings indicate choppy price action, and supports real-time alerts after a touch followed by sustained price holding.
Automatic levels
Swing highs and lows are identified using configurable numbers of candles to the left and right of the pivot. An optional ATR(14) filter requires a minimum price move away from the pivot on both sides, helping reduce minor swing levels.
Each level is drawn as an independent horizontal segment. The history limit controls how many automatic levels are retained, including completed segments.
Chop detection
A crossing is counted when a closed candle’s low is strictly below the level and its high is strictly above it. A touch without crossing does not count.
When the number of crossing candles exceeds the configured allowance within a rolling time window, the level ends at that candle’s close. For example, with a 60-minute window and an allowance of 3 candles, the fourth crossing ends the level.
Completed levels remain visible until removed by the history limit, but no longer extend or trigger alerts.
Manual levels
Up to six manual price levels can be enabled in the indicator settings. Automatic levels can also be excluded by entering their prices in a semicolon-separated list.
Manual levels can optionally follow the same chop termination rule. They are calculated from the beginning of the loaded chart history, so historical crossings may end them before the current candle.
Real-time hold alerts
Alerts apply only to active levels:
• After approaching from below and touching or crossing a level, price must remain at or above it for longer than the configured hold duration.
• After approaching from above, price must remain at or below it.
• A return to the original side resets the timer.
The default hold duration is more than 10 seconds. Touch tolerance and the minimum interval between repeated alerts are configurable.
To enable notifications, create an alert with the condition “Any alert() function call”, then select the desired sound and notification options. One alert monitors all active levels for its selected symbol and timeframe.
Confirmation delay and limitations
Pivot levels become available only after the required right-side candles have closed. Lines are anchored to the original pivot candle, so their historical starting points precede the time the levels were actually confirmed.
Second-based holding is evaluated only in real time when price updates arrive. It cannot be reconstructed from historical candles, and a signal is generated on the first update after the hold duration has been exceeded.
The indicator reads manual levels entered through its own settings; it does not read TradingView drawing objects.
Use an intraday timeframe. Recreate the alert after changing indicator settings, manual prices, code, symbol, or timeframe, because an existing alert retains the configuration captured when it was created.

## Source Code

````pine
//@version=6
indicator("Экстремумы • уровни до запила", overlay = true, max_lines_count = 350, max_bars_back = 500)

int leftBars = input.int(10, "Свечей слева", minval = 1, maxval = 50, group = "Экстремумы")
int rightBars = input.int(10, "Свечей справа для подтверждения", minval = 1, maxval = 50, group = "Экстремумы")
bool useHigh = input.bool(true, "Максимумы", group = "Экстремумы")
bool useLow = input.bool(true, "Минимумы", group = "Экстремумы")
int keepLevels = input.int(25, "Количество сохраняемых уровней", minval = 10, maxval = 300, group = "Экстремумы")
float minSwing = input.float(2.0, "Минимальный разворот, ATR", minval = 0, step = 0.25, tooltip = "0 — все подтверждённые экстремумы. При 2 цена должна отойти от экстремума с обеих сторон минимум на два средних диапазона свечи.", group = "Экстремумы")
color levelColor = input.color(color.rgb(218, 25, 112), "Цвет уровней", group = "Экстремумы")
int lineWidth = input.int(2, "Толщина", minval = 1, maxval = 4, group = "Экстремумы")
string excludedInput = input.string("", "Исключить цены (через ;)", group = "Экстремумы")
int windowMinutes = input.int(60, "Окно запила, минут", minval = 1, maxval = 1440, group = "Запил")
int maxCrossings = input.int(3, "Допустимо пробивающих свечей", minval = 1, maxval = 100, tooltip = "При 3 уровень заканчивается на четвёртой закрытой свече за окно. Пробой: минимум строго ниже, максимум строго выше уровня. Касание одной тенью без пересечения не считается.", group = "Запил")
bool stopManual = input.bool(true, "Завершать также ручные уровни", group = "Запил")
bool manualOn1 = input.bool(false, "Уровень 1", inline = "m1", group = "Ручные уровни")
float manualPrice1 = input.price(0.0, "Цена", inline = "m1", group = "Ручные уровни")
bool manualOn2 = input.bool(false, "Уровень 2", inline = "m2", group = "Ручные уровни")
float manualPrice2 = input.price(0.0, "Цена", inline = "m2", group = "Ручные уровни")
bool manualOn3 = input.bool(false, "Уровень 3", inline = "m3", group = "Ручные уровни")
float manualPrice3 = input.price(0.0, "Цена", inline = "m3", group = "Ручные уровни")
bool manualOn4 = input.bool(false, "Уровень 4", inline = "m4", group = "Ручные уровни")
float manualPrice4 = input.price(0.0, "Цена", inline = "m4", group = "Ручные уровни")
bool manualOn5 = input.bool(false, "Уровень 5", inline = "m5", group = "Ручные уровни")
float manualPrice5 = input.price(0.0, "Цена", inline = "m5", group = "Ручные уровни")
bool manualOn6 = input.bool(false, "Уровень 6", inline = "m6", group = "Ручные уровни")
float manualPrice6 = input.price(0.0, "Цена", inline = "m6", group = "Ручные уровни")


int holdSeconds = input.int(10, "Удержание дольше, секунд", minval = 1, maxval = 3600, group = "Оповещения")
int toleranceTicks = input.int(0, "Допуск касания, шагов цены", minval = 0, maxval = 100, tooltip = "0 — точный уровень. Допуск влияет только на обнаружение касания; удержание всегда считается на самом уровне или за ним.", group = "Оповещения")
int cooldownSeconds = input.int(60, "Пауза между сигналами одного уровня, секунд", minval = 10, maxval = 3600, group = "Оповещения")


if not timeframe.isintraday
    runtime.error("Выберите внутридневной таймфрейм.")

type Level
    float price
    int uid
    string name
    line drawing
    array<int> crossings
    bool active
    bool manual

type Timer
    int direction = 0
    bool armed = false
    bool inside = false
    int started = na
    bool delivered = false
    int lastAlert = na

var array<Level> levels = array.new<Level>()
varip map<int, Timer> timers = map.new<int, Timer>()
var array<float> excluded = array.new<float>()
if barstate.isfirst and str.length(str.trim(excludedInput)) > 0
    for item in str.split(excludedInput, ";")
        string cleaned = str.replace_all(str.trim(item), ",", ".")
        if str.length(cleaned) > 0
            float p = str.tonumber(cleaned)
            if na(p)
                runtime.error("Неверная цена исключения: " + item)
            array.push(excluded, p)

f_excluded(float p) =>
    bool found = false
    for value in excluded
        if math.abs(p - value) <= syminfo.mintick * 0.5
            found := true
    found

// Only completed candles count. Each candle contributes at most one event.
f_cross(Level lev, float h, float l, int stamp) =>
    while array.size(lev.crossings) > 0
        if array.get(lev.crossings, 0) <= stamp - windowMinutes * 60000
            array.shift(lev.crossings)
        else
            break
    if h > lev.price and l < lev.price
        array.push(lev.crossings, stamp)
    if array.size(lev.crossings) > maxCrossings
        lev.active := false
        line.set_x2(lev.drawing, stamp)
    lev.active

f_add(float p, int start, int uid, string name, bool manualLevel, int bootstrap) =>
    bool duplicate = false
    if not manualLevel
        for lev in levels
            if lev.active and math.abs(lev.price - p) <= syminfo.mintick * 0.5
                duplicate := true
    if not na(p) and not duplicate and (manualLevel or not f_excluded(p))
        line drawing = line.new(start, p, time_close, p, xloc = xloc.bar_time, color = manualLevel ? color.yellow : levelColor, width = lineWidth)
        Level lev = Level.new(p, uid, name, drawing, array.new<int>(), true, manualLevel)
        // A pivot is known only after confirmation. Replay the intervening bars
        // chronologically, so a level already chopped during confirmation is stopped.
        if bootstrap > 0
            for step = 1 to bootstrap
                int offset = bootstrap - step
                if lev.active
                    f_cross(lev, high[offset], low[offset], time_close[offset])
        array.push(levels, lev)
    true

if barstate.isfirst
    array<float> prices = array.from(manualPrice1, manualPrice2, manualPrice3, manualPrice4, manualPrice5, manualPrice6)
    array<bool> enabled = array.from(manualOn1, manualOn2, manualOn3, manualOn4, manualOn5, manualOn6)
    for i = 0 to 5
        if array.get(enabled, i)
            f_add(array.get(prices, i), time, -i - 1, "Ручной " + str.tostring(i + 1), true, 0)

float ph = ta.pivothigh(high, leftBars, rightBars)
float pl = ta.pivotlow(low, leftBars, rightBars)
float atr = ta.atr(14)
float leftLow = ta.lowest(low, leftBars)
float rightLow = ta.lowest(low, rightBars)
float leftHigh = ta.highest(high, leftBars)
float rightHigh = ta.highest(high, rightBars)
float requiredSwing = nz(atr[rightBars], high[rightBars] - low[rightBars]) * minSwing
bool significantHigh = not na(ph) and ph - math.max(leftLow[rightBars + 1], rightLow) >= requiredSwing
bool significantLow = not na(pl) and math.min(leftHigh[rightBars + 1], rightHigh) - pl >= requiredSwing
if barstate.isconfirmed
    for lev in levels
        if lev.active and (not lev.manual or stopManual)
            f_cross(lev, high, low, time_close)
    if useHigh and significantHigh
        f_add(ph, time[rightBars], time[rightBars] * 2, "Максимум", false, rightBars)
    if useLow and significantLow
        f_add(pl, time[rightBars], time[rightBars] * 2 + 1, "Минимум", false, rightBars)
    // Bound drawing/history and timer memory, keeping manual slots separately.
    int autoCount = 0
    for lev in levels
        if not lev.manual
            autoCount += 1
    while autoCount > keepLevels
        int victim = -1
        for i = 0 to array.size(levels) - 1
            if not array.get(levels, i).manual
                victim := i
                break
        if victim >= 0
            Level gone = array.remove(levels, victim)
            line.delete(gone.drawing)
            map.remove(timers, gone.uid)
            autoCount -= 1

// Active segments end at the current candle; stopped segments never grow again.
for lev in levels
    if lev.active
        line.set_x2(lev.drawing, time_close)

varip float previousPrice = na
string message = ""
float band = toleranceTicks * syminfo.mintick
if barstate.isrealtime
    for lev in levels
        if not lev.active
            map.remove(timers, lev.uid)
        else
            if not map.contains(timers, lev.uid)
                map.put(timers, lev.uid, Timer.new())
            Timer state = map.get(timers, lev.uid)
            float p = lev.price
            bool inZone = math.abs(close - p) <= band
            bool crossed = not na(previousPrice) and ((previousPrice < p and close >= p) or (previousPrice > p and close <= p))
            bool contact = (inZone and not state.inside) or crossed
            if not state.armed
                if contact
                    int approach = state.direction
                    if not na(previousPrice)
                        approach := previousPrice < p ? 1 : previousPrice > p ? -1 : approach
                    if approach != 0
                        state.direction := approach
                        state.armed := true
                        state.started := na
                        state.delivered := false
                else if close != p
                    state.direction := close < p ? 1 : -1
            state.inside := inZone
            if state.armed
                bool qualifies = state.direction == 1 ? close >= p : close <= p
                if not qualifies
                    state.armed := false
                    state.started := na
                    state.delivered := false
                    state.direction := close < p ? 1 : -1
                    state.inside := false
                else
                    if na(state.started)
                        state.started := timenow
                    if timenow - state.started > holdSeconds * 1000 and not state.delivered
                        state.delivered := true
                        if na(state.lastAlert) or timenow - state.lastAlert >= cooldownSeconds * 1000
                            message += lev.name + " = " + str.tostring(p, format.mintick) + ": удержание " + (state.direction == 1 ? "на уровне или выше" : "на уровне или ниже") + " более " + str.tostring(holdSeconds) + " с\n"
                            state.lastAlert := timenow
    previousPrice := close
    if str.length(message) > 0
        alert(syminfo.tickerid + " • " + timeframe.period + "\n" + message, alert.freq_all)
````
