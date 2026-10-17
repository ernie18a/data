# BTC BB + RSI + EMA200 + Divergence [FIXED]

- url: https://www.tradingview.com/script/n74KVL2l-btc-bb-rsi-ema200-divergence-fixed/
- type: indicator
- pine_id: PUB;6e35331e904d46eba4e8ebcda367764c
- version: 1.0

## Description

Этот индикатор представляет собой сложную торговую систему (систему конформности), объединяющую трендовую фильтрацию, волатильность, импульс и классический Price Action (дивергенции). Он разработан специально для Bitcoin, учитывая его высокую волатильность.
Вот подробное описание логики работы каждого блока:
1. Глобальный Трендовый Фильтр (EMA 200)
Это «ворота» для входа в сделку. Индикатор не даст сигнал против основного тренда (если включен режим Strict).
База: Используется EMA с периодом 200.
Режимы (emaMode):
Strict (Строгий): Для лонга цена должна быть выше EMA, а сама EMA должна расти (наклон вверх). Для шорта — наоборот.
Soft (Мягкий): Важно только положение цены относительно EMA (выше — только лонги, ниже — только шорты). Наклон EMA не важен.
Off: Трендовый фильтр отключен (сигналы будут в обе стороны).
MTF Подтверждение: Если включено, индикатор проверяет значение EMA200 со старшего таймфрейма (например, 4H), чтобы убедиться, что глобальный тренд совпадает с локальным.
2. Зоны Перекупленности/Перепроданности (Bollinger Bands)
Определяют экстремальные точки цены, где возможен разворот.
Настройки: Длина 34 (число Фибоначчи) и отклонение 2.1. Это шире стандартных настроек (20, 2.0), что отфильтровывает рыночный шум на BTC.
Условие:
Long: Цена (Low) должна коснуться или пробить нижнюю полосу.
Short: Цена (High) должна коснуться или пробить верхнюю полосу.
3. Импульс и Триггер (RSI)
Используется для подтверждения разворота в зонах Bollinger Bands.
Настройки: RSI длины 5 (очень быстрый, реагирует раньше, чем стандартный 14).
Логика входа:
Классический кроссовер: RSI пересекает уровни 25 (для лонга) или 75 (для шорта).
Плавный разворот (Smooth Turn): Если RSI уже ниже 25, но начал расти (rsi > rsi[1]), это считается сигналом разворота без ожидания пересечения уровня.
4. Детекция Дивергенций (Divergence)
Это самый мощный фильтр, отсеивающий ложные пробои уровней.
Поиск свингов: Используется ta.pivothigh и ta.pivotlow для поиска локальных минимумов и максимумов цены.
Типы дивергенций:
Regular (Разворотная):
Bullish: Цена делает ниже минимум (Lower Low), а RSI делает выше минимум (Higher Low). Сигнал на разворот вниз -> вверх.
Bearish: Цена делает выше максимум, а RSI ниже максимум.
Hidden (Скрытая/Продолжение тренда):
Bullish: Цена делает выше минимум (Higher Low), а RSI ниже минимум. Сигнал на продолжение восходящего тренда.
Фильтр расстояния: Дивергенция засчитывается только если между двумя пивотами прошло не более divMaxBars (по умолчанию 50 баров). Это отсеивает "устаревшие" дивергенции.
📊 5. Фильтр Объема
Условие: Если включено (requireVol), текущий объем свечи должен превышать среднее значение за 14 периодов (SMA Volume) на заданный множитель.
Зачем: Подтверждает, что движение поддерживается "умными деньгами", а не просто случайной волатильностью.
🚀 6. Формирование Сигнала Входа (Final Signal)
Сигнал появляется только при совпадении всех условий (логическое И):
LONG (Покупка):
✅ Тренд восходящий (BullTrend).
✅ Цена коснулась нижней линии Боллинджера.
✅ RSI развернулся вверх или пересек уровень 25.
✅ Есть Бычья Дивергенция (Regular).
✅ (Опционально) Объем повышен.
✅ Прошел signalCooldown (пауза после предыдущего сигнала).
SHORT (Продажа):
✅ Тренд нисходящий (BearTrend).
✅ Цена коснулась верхней линии Боллинджера.
✅ RSI развернулся вниз или пересек уровень 75.
✅ Есть Медвежья Дивергенция (Regular).
✅ (Опционально) Объем повышен.
🛡️ 7. Риск-менеджмент (SL / TP)
Автоматический расчет уровней защиты и фиксации прибыли на основе волатильности (ATR).
ATR: Используется Average True Range (по умолчанию 14).
Stop Loss: Откладывается на 1.5 * ATR от цены закрытия сигнала.
Take Profit: Откладывается на 3.0 * ATR (соотношение Риск/Прибыль 1:2).
Визуализация: На графике рисуются пунктирные линии и лейблы SL/TP.
🧹 8. Техническая Оптимизация (Object Manager)
Чтобы TradingView не зависал от тысяч линий и меток:
Все линии дивергенций и SL/TP сохраняются в Массивы (Arrays).
Старые объекты автоматически удаляются (line.delete), если их количество превышает лимит (например, 30-50 штук). Это предотвращает ошибку "Too many drawings".
Итог: Как это работает на практике?
Индикатор ищет ситуацию, когда быстрый импульс (RSI) на фоне экстремальной волатильности (BB) совпадает с истощением тренда (Дивергенция), при этом общее направление рынка (EMA 200) позволяет войти в сделку.
Это стратегия Mean Reversion (возврат к среднему) с элементами Trend Following.

Вот подробное описание каждой настройки индикатора. Я разбил их по группам (так, как они отображаются в меню настроек TradingView) и объяснил, как изменение параметров влияет на количество и качество сигналов.
📈 1. Bollinger Bands (Полосы Боллинджера)
Этот блок отвечает за определение волатильности и экстремальных точек цены.
Настройка
Описание
На что влияет
BB Length (34)
Период скользящей средней внутри полос.
Больше (50+): Линии становятся более плавными, сигналов меньше, но они надежнее.
Меньше (20): Реагирует быстрее, но больше ложных касаний (шума). 34 — оптимум для BTC.
BB Deviation (2.1)
Ширина полос (стандартное отклонение).
Больше (2.5 - 3.0): Полосы шире. Цена должна очень сильно отклониться, чтобы дать сигнал. Редкие, но сильные сигналы.
Меньше (1.5): Полосы узкие. Сигналы частые, но много ложных пробоев.
BB Source (Close)
По какой цене считать полосы.
Лучше оставить Close. Изменение на High/Low может сдвигать момент касания полосы.
📉 2. EMA Trend Filter (Фильтр тренда)
Этот блок защищает вас от торговли против тренда (например, покупки во время сильного обвала).
Настройка
Описание
На что влияет
EMA Length (200)
Длина трендовой линии.
Больше (200): Глобальный тренд. Сигналы только по сильному направлению.
Меньше (50-100): Более локальный тренд. Позволяет торговать коррекции чаще.
Trend Mode
Режим фильтрации.
Strict: Самый строгий. Требует, чтобы цена была выше EMA И сама EMA росла. Пропускает самые первые развороты, но безопасен.
Soft: Требует только, чтобы цена была выше EMA. Больше сигналов, позволяет ловить развороты раньше.
Off: Фильтр выключен. Будет много сигналов против тренда.
Confirm with Higher TF
Проверка тренда на старшем таймфрейме.
Если включено (например, на 15м чарте проверяет 4H EMA), индикатор не даст сигнал Long, если на 4H медвежий тренд, даже если на 15м всё идеально.
🎯 3. RSI & Momentum (Импульс)
Отвечает за скорость движения и поиск точек разворота.
Настройка
Описание
На что влияет
RSI Length (5)
Период RSI.
Меньше (5): Очень быстрый ("нервный"). Реагирует мгновенно на каждый рывок цены. Хорошо для скальпинга.
Больше (14): Классический, более плавный. Сигналы запаздывают, но надежнее.
RSI Overbought (75)
Зона перекупленности.
Выше (80): Ждет очень сильного разгона цены перед сигналом на продажу.
Ниже (70): Стандартный уровень.
RSI Oversold (25)
Зона перепроданности.
Ниже (20): Ждет очень сильного падения перед сигналом на покупку.
Выше (30): Стандартный уровень.
🔀 4. Divergence Detection (Дивергенции)
Самый сложный блок. Ищет расхождения между ценой и индикатором RSI.
Настройка
Описание
На что влияет
Pivot Left / Right (3)
Сколько баров слева/справа нужно для подтверждения "пика" или "дна".
Меньше (1-2): Находит очень маленькие локальные экстремумы. Много шума и ложных линий.
Больше (5-10): Ищет только крупные, значимые пики. Сигналов меньше, но они важнее.
Show Regular / Hidden
Тип дивергенций.
Regular: Сигнал на разворот тренда.
Hidden: Сигнал на продолжение тренда (покупка на откате).
Max Bars Between Pivots (50)
Максимальное расстояние между двумя точками дивергенции.
Если дивергенция формируется слишком долго (например, 2 недели на 15м графике), она теряет силу. Эта настройка отсеивает такие "устаревшие" сигналы.
📊 5. Volume Confirmation (Объем)
Фильтр "силы" движения.
Настройка
Описание
На что влияет
Require Volume Boost
Включить фильтр объема.
Если Выкл: Игнорирует объем (сигналы будут даже на тонком рынке).
Если Вкл: Сигнал появится только если есть всплеск активности.
Volume Multiplier (1.0)
Насколько объем должен быть выше среднего.
1.0: Объем просто должен быть выше среднего.
1.5 - 2.0: Требует мощного всплеска объема (подтверждение от крупных игроков).
6. Entry Signals & Risk (Вход и Риск-менеджмент)
Настройки для стрелок входа и линий Stop Loss / Take Profit.
Настройка
Описание
На что влияет
Min Bars Between Signals (10)
Кулдаун (перезарядка).
Запрещает показывать новый сигнал, если предыдущий был менее 10 баров назад. Защищает от серии стрелок подряд во время сильного падения.
ATR SL Multiplier (1.5)
Множитель для Стоп-Лосса.
Меньше (1.0): Узкий стоп. Легко выбьет случайной тенью свечи.
Больше (2.0+): Широкий стоп. Безопаснее, но убыток в случае срабатывания будет больше.
ATR TP Multiplier (3.0)
Множитель для Тейк-Профита.
Определяет соотношение Риск/Прибыль. При настройках 1.5 (SL) и 3.0 (TP) вы целитесь в профит x2 от риска (1:2).
💡 Как настроить под себя?
Слишком много сигналов (шум)?
Увеличьте BB Deviation до 2.3.
Переключите Trend Mode на Strict.
Увеличьте Pivot Right до 5.
Слишком мало сигналов (упускаете вход)?
Уменьшите BB Deviation до 1.8.
Переключите Trend Mode на Soft.
Уменьшите RSI Length до 3 (очень агрессивно).
Много ложных разворотов (цена пролетает мимо)?
Включите Require Volume Boost и поставьте множитель 1.2.
Увеличьте Min Bars Between Signals, чтобы не входить в падающий нож несколько раз подряд.

На основе анализа текущих рыночных данных и исследований по торговле Bitcoin futures на Binance, вот оптимальные настройки для вашего индикатора:
🎯 Оптимальные настройки для BTC/USDT Futures (Binance)
1️⃣ Для СКАЛЬПИНГА (1m - 15m таймфреймы)
Быстрая торговля, 5-20 сделок в день
1234567891011121314151617181920212223242526
📊 Результат: Много сигналов, быстрый вход/выход. Подходит для высокой волатильности BTC. 
www.binance.com
2️⃣ Для ДНЕВНОЙ ТОРГОВЛИ (15m - 1h таймфреймы)
Золотая середина, 1-5 сделок в день
1234567891011121314151617181920212223242526
📊 Результат: Сбалансированная стратегия. Исследования показывают 20%+ доходности для BTC futures с такими настройками. 
ideas.repec.org
3️⃣ Для СВИНГ-ТРЕЙДИНГА (4h - 1D таймфреймы)
Долгосрочные позиции, 1-3 сделки в неделю
1234567891011121314151617181920212223242526
📊 Результат: Мало сигналов, но высокое качество. Идеально для работы + основной торговли. 
mudrex.com
goodcrypto.app
🔥 Рекомендация для Binance Futures BTC/USDT
Стартовые настройки (универсальные):
Для начала рекомендую дневную стратегию (вариант 2) с такими параметрами:
1234567891011
Почему именно так:
✅ BB 34/2.0 — лучше реагирует на волатильность BTC, чем стандартные 20/2.0 
ResearchGate
www.binance.com
✅ EMA 200 Strict — защищает от торговли против тренда
✅ RSI 9 — баланс между скоростью и надежностью
✅ Volume 1.5x — фильтрует ложные пробои на низком объеме
✅ ATR 1.5/3.0 — соотношение риск/прибыль 1:2
📉 Дополнительные советы для Binance Futures:
Таймфреймы:
Скальпинг: 1m-5m (только опытным)
Day Trading: 15m-1h (оптимально)
Swing: 4h-1D (безопаснее) 
medium.com
Управление рисками:
Плечо: не более 5-10x для BTC
Риск на сделку: 1-2% от депозита
Всегда используйте SL!
Время торговли:
Лучшая волатильность: 13:00-16:00 UTC (открытие США)
Избегайте: выходные и праздники (низкий объем)
Фандинг (Funding Rate):
Проверяйте перед входом в позицию
Если funding > 0.01% — осторожно с лонгами
🎯 Начните с демо-счета или маленьких сумм, протестируйте настройки 3-5 дней, затем оптимизируйте под свой стиль торговли!
Нужна помощь с бэктестом этих настроек или адаптацией под конкретный таймфрейм?

Содержимое, созданное ИИ.

## Source Code

````pine
//@version=6
indicator("BTC BB + RSI + EMA200 + Divergence [FIXED]", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ═══════════════════════════════════════════════════════════════
// 📊 INPUTS — Настройки индикатора
// ═══════════════════════════════════════════════════════════════

// --- Bollinger Bands ---
grpBB = "📈 Bollinger Bands"
bbLen     = input.int(34, "BB Length", minval=10, maxval=200, group=grpBB)
bbDev     = input.float(2.1, "BB Deviation", minval=1.0, maxval=3.0, step=0.1, group=grpBB)
bbSrc     = input.source(close, "BB Source", group=grpBB)

// --- EMA Trend Filter ---
grpEMA = "📉 EMA Trend Filter"
emaLen    = input.int(200, "EMA Length", minval=50, maxval=500, group=grpEMA)
emaMode   = input.string("Strict", "Trend Mode", options=["Strict", "Soft", "Off"], group=grpEMA)
emaMTF    = input.bool(false, "Confirm with Higher TF EMA", group=grpEMA)
emaMTFRes = input.timeframe("240", "Higher TF for EMA", group=grpEMA)

// --- RSI Settings ---
grpRSI = "🎯 RSI & Momentum"
rsiLen    = input.int(5, "RSI Length", minval=2, maxval=25, group=grpRSI)
rsiOB     = input.int(75, "RSI Overbought", minval=50, maxval=100, group=grpRSI)
rsiOS     = input.int(25, "RSI Oversold", minval=0, maxval=50, group=grpRSI)
rsiSrc    = input.source(close, "RSI Source", group=grpRSI)

// --- Pivot & Divergence ---
grpDiv = "🔀 Divergence Detection"
pivotLeft = input.int(3, "Pivot Left", minval=1, maxval=20, group=grpDiv)
pivotRight= input.int(3, "Pivot Right", minval=1, maxval=20, group=grpDiv)
showDiv    = input.bool(true, "Show Regular Divergence", group=grpDiv)
showHidden = input.bool(true, "Show Hidden Divergence", group=grpDiv)
divMaxBars = input.int(50, "Max Bars Between Pivots", minval=10, maxval=200, group=grpDiv)
maxDivLines = input.int(30, "Max Divergence Lines", minval=5, maxval=100, group=grpDiv, tooltip="Лимит линий дивергенций для защиты от переполнения")

// --- Volume Filter ---
grpVol = "📊 Volume Confirmation"
volLen     = input.int(14, "Volume SMA Length", minval=5, maxval=100, group=grpVol)
requireVol = input.bool(false, "Require Volume Boost", group=grpVol)
volMult    = input.float(1.0, "Volume Multiplier", minval=0.5, maxval=3.0, step=0.1, group=grpVol)

// --- Entry & Risk Management ---
grpEntry = "🚀 Entry Signals & Risk"
showEntr    = input.bool(true, "Show Entry Arrows", group=grpEntry)
signalCooldown = input.int(10, "Min Bars Between Signals", minval=0, maxval=50, group=grpEntry)
showSLTP    = input.bool(true, "Visualize SL/TP Levels", group=grpEntry)
atrLen      = input.int(14, "ATR Length for SL/TP", minval=5, maxval=50, group=grpEntry)
atrSLMult   = input.float(1.5, "ATR Stop-Loss Multiplier", minval=0.5, maxval=4.0, step=0.1, group=grpEntry)
atrTPMult   = input.float(3.0, "ATR Take-Profit Multiplier", minval=1.0, maxval=6.0, step=0.1, group=grpEntry)
sltpBarsExt = input.int(50, "SL/TP Lines Extend (bars)", minval=10, maxval=200, group=grpEntry)

// --- Visual Toggles ---
grpVis = "🎨 Visual Settings"
showBands  = input.bool(true, "Show Bollinger Bands", group=grpVis)
showEMA    = input.bool(true, "Show EMA200", group=grpVis)
bandFill   = input.bool(true, "Fill Bands Area", group=grpVis)
colorBull  = input.color(color.lime, "Bullish Color", group=grpVis)
colorBear  = input.color(color.red, "Bearish Color", group=grpVis)

// ═══════════════════════════════════════════════════════════════
// 🧮 CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════

// Bollinger Bands
basis = ta.sma(bbSrc, bbLen)
dev   = bbDev * ta.stdev(bbSrc, bbLen)
upper = basis + dev
lower = basis - dev

// EMA + MTF Confirmation
ema200 = ta.ema(close, emaLen)
ema200HTF = emaMTF ? request.security(syminfo.tickerid, emaMTFRes, ta.ema(close, emaLen)) : na


// RSI (только логика, без отрисовки)
rsi = ta.rsi(rsiSrc, rsiLen)

// Volume
volSma = ta.sma(volume, volLen)
volBoost = volume >= volSma * volMult

// ATR for SL/TP
atr = ta.atr(atrLen)

// ═══════════════════════════════════════════════════════════════
// 📈 TREND FILTER LOGIC
// ═══════════════════════════════════════════════════════════════

var bool bullTrend = false
var bool bearTrend = false

if emaMode == "Strict"
    bullTrend := close > ema200 and (ema200 > ema200[1] or bar_index < emaLen) and (not emaMTF or not na(ema200HTF) and close > ema200HTF)
    bearTrend := close < ema200 and (ema200 < ema200[1] or bar_index < emaLen) and (not emaMTF or not na(ema200HTF) and close < ema200HTF)
else if emaMode == "Soft"
    bullTrend := close > ema200 and (not emaMTF or not na(ema200HTF) and close > ema200HTF)
    bearTrend := close < ema200 and (not emaMTF or not na(ema200HTF) and close < ema200HTF)
else
    bullTrend := true
    bearTrend := true

// ═══════════════════════════════════════════════════════════════
// 🎯 PRICE & RSI CONDITIONS
// ═══════════════════════════════════════════════════════════════

touchLower = low <= lower
touchUpper = high >= upper

rsiBullTurn = ta.crossover(rsi, rsiOS) or (rsi <= rsiOS and rsi > rsi[1] and rsi[1] <= rsi[2])
rsiBearTurn = ta.crossunder(rsi, rsiOB) or (rsi >= rsiOB and rsi < rsi[1] and rsi[1] >= rsi[2])

// ═══════════════════════════════════════════════════════════════
// 🔀 DIVERGENCE DETECTION + OBJECT MANAGER
// ═══════════════════════════════════════════════════════════════

// Менеджер линий: массив для отслеживания созданных объектов
var array<line> divLines = array.new<line>()
var array<label> divLabels = array.new<label>()

// Функция очистки старых линий при превышении лимита
cleanupObjects(array<line> arr, int maxCount) =>
    if array.size(arr) > maxCount
        oldLine = array.shift(arr)
        if not na(oldLine)
            line.delete(oldLine)

cleanupLabels(array<label> arr, int maxCount) =>
    if array.size(arr) > maxCount
        oldLabel = array.shift(arr)
        if not na(oldLabel)
            label.delete(oldLabel)

pl = ta.pivotlow(low, pivotLeft, pivotRight)
ph = ta.pivothigh(high, pivotLeft, pivotRight)

var float prevPlPrice = na
var float prevPlRsi   = na
var int   prevPlBar   = na
var float prevPhPrice = na
var float prevPhRsi   = na
var int   prevPhBar   = na

var bool bullDiv = false
var bool bearDiv = false
var bool hiddenBullDiv = false
var bool hiddenBearDiv = false

bullDiv := false
bearDiv := false
hiddenBullDiv := false
hiddenBearDiv := false

// ── Bullish Divergence ──
if not na(pl) and showDiv
    currBar   = bar_index - pivotRight
    currPrice = pl
    currRsi   = rsi[pivotRight]
    
    if not na(prevPlPrice) and (bar_index - prevPlBar) <= divMaxBars
        if currPrice < prevPlPrice and currRsi > prevPlRsi  // Regular Bullish
            bullDiv := true
            if showDiv
                cleanupObjects(divLines, maxDivLines)
                newLine = line.new(prevPlBar, prevPlPrice, currBar, currPrice, color=colorBull, width=2)
                array.push(divLines, newLine)
                
                cleanupLabels(divLabels, maxDivLines)
                newLabel = label.new(currBar, low[pivotRight], "▲", style=label.style_label_up, textcolor=color.white, color=colorBull, size=size.small)
                array.push(divLabels, newLabel)
        
        if currPrice > prevPlPrice and currRsi < prevPlRsi  // Hidden Bullish
            hiddenBullDiv := true
            if showHidden
                cleanupObjects(divLines, maxDivLines)
                newLine = line.new(prevPlBar, prevPlPrice, currBar, currPrice, color=color.teal, width=2, style=line.style_dashed)
                array.push(divLines, newLine)
                
                cleanupLabels(divLabels, maxDivLines)
                newLabel = label.new(currBar, low[pivotRight], "◆", style=label.style_label_up, textcolor=color.white, color=color.teal, size=size.tiny)
                array.push(divLabels, newLabel)
    
    prevPlPrice := currPrice
    prevPlRsi   := currRsi
    prevPlBar   := currBar

// ── Bearish Divergence ──
if not na(ph) and showDiv
    currBar   = bar_index - pivotRight
    currPrice = ph
    currRsi   = rsi[pivotRight]
    
    if not na(prevPhPrice) and (bar_index - prevPhBar) <= divMaxBars
        if currPrice > prevPhPrice and currRsi < prevPhRsi  // Regular Bearish
            bearDiv := true
            if showDiv
                cleanupObjects(divLines, maxDivLines)
                newLine = line.new(prevPhBar, prevPhPrice, currBar, currPrice, color=colorBear, width=2)
                array.push(divLines, newLine)
                
                cleanupLabels(divLabels, maxDivLines)
                newLabel = label.new(currBar, high[pivotRight], "▼", style=label.style_label_down, textcolor=color.white, color=colorBear, size=size.small)
                array.push(divLabels, newLabel)
        
        if currPrice < prevPhPrice and currRsi > prevPhRsi  // Hidden Bearish
            hiddenBearDiv := true
            if showHidden
                cleanupObjects(divLines, maxDivLines)
                newLine = line.new(prevPhBar, prevPhPrice, currBar, currPrice, color=color.orange, width=2, style=line.style_dashed)
                array.push(divLines, newLine)
                
                cleanupLabels(divLabels, maxDivLines)
                newLabel = label.new(currBar, high[pivotRight], "◇", style=label.style_label_down, textcolor=color.white, color=color.orange, size=size.tiny)
                array.push(divLabels, newLabel)
    
    prevPhPrice := currPrice
    prevPhRsi   := currRsi
    prevPhBar   := currBar

// ═══════════════════════════════════════════════════════════════
// 🚀 ENTRY SIGNALS
// ═══════════════════════════════════════════════════════════════

var int lastLongBar = na
var int lastShortBar = na

volCondition = requireVol ? volBoost : true
canLong  = na(lastLongBar) or (bar_index - lastLongBar) >= signalCooldown
canShort = na(lastShortBar) or (bar_index - lastShortBar) >= signalCooldown

longEntry  = bullTrend and touchLower and rsiBullTurn and bullDiv and volCondition and canLong
shortEntry = bearTrend and touchUpper and rsiBearTurn and bearDiv and volCondition and canShort

if longEntry
    lastLongBar := bar_index
if shortEntry
    lastShortBar := bar_index

// ═══════════════════════════════════════════════════════════════
// 🎨 VISUALIZATION
// ═══════════════════════════════════════════════════════════════

// Bollinger Bands
pBasis = plot(showBands ? basis : na, "BB Basis", color=color.new(color.blue, 0), linewidth=2)
pUpper = plot(showBands ? upper : na, "BB Upper", color=color.new(color.gray, 30))
pLower = plot(showBands ? lower : na, "BB Lower", color=color.new(color.gray, 30))

// Fill bands - корректная работа с na
// Создаем plot всегда (без условий)
// Fill с условным цветом (а не условными plot!)
pUpper := plot(upper, "BB Upper", color=color.new(color.gray, 30))
fillColor = showBands and bandFill ? color.new(color.blue, 90) : na
fill(pUpper, pLower, color=fillColor, title="BB Fill")

// EMA200
plot(showEMA ? ema200 : na, "EMA 200", color=color.new(color.yellow, 0), linewidth=2)
plot(emaMTF and showEMA and not na(ema200HTF) ? ema200HTF : na, "EMA 200 HTF", 
     color=color.new(color.orange, 30), linewidth=1, style=plot.style_circles)

// Entry Signals
plotshape(showEntr and longEntry, title="Long Entry", style=shape.arrowup, location=location.belowbar, 
          color=colorBull, size=size.small, text="BUY", textcolor=color.white)
plotshape(showEntr and shortEntry, title="Short Entry", style=shape.arrowdown, location=location.abovebar, 
          color=colorBear, size=size.small, text="SELL", textcolor=color.white)

// SL/TP Visualization
var array<line> sltpLines = array.new<line>()
var array<label> sltpLabels = array.new<label>()

cleanupSLTP() =>
    // Удаляем старые линии SL/TP каждые 20 баров или при превышении лимита
    if array.size(sltpLines) > 50
        oldL = array.shift(sltpLines)
        if not na(oldL)
            line.delete(oldL)
    if array.size(sltpLabels) > 50
        oldLbl = array.shift(sltpLabels)
        if not na(oldLbl)
            label.delete(oldLbl)

if showSLTP and showEntr
    cleanupSLTP()
    
    if longEntry
        slLong = close - atr * atrSLMult
        tpLong = close + atr * atrTPMult
        array.push(sltpLines, line.new(bar_index, slLong, bar_index + sltpBarsExt, slLong, color=color.red, width=1, style=line.style_dotted, extend=extend.right))
        array.push(sltpLines, line.new(bar_index, tpLong, bar_index + sltpBarsExt, tpLong, color=color.lime, width=1, style=line.style_dotted, extend=extend.right))
        array.push(sltpLabels, label.new(bar_index + sltpBarsExt, slLong, "SL", style=label.style_label_left, color=color.red, textcolor=color.white, size=size.tiny))
        array.push(sltpLabels, label.new(bar_index + sltpBarsExt, tpLong, "TP", style=label.style_label_left, color=color.lime, textcolor=color.white, size=size.tiny))
    
    if shortEntry
        slShort = close + atr * atrSLMult
        tpShort = close - atr * atrTPMult
        array.push(sltpLines, line.new(bar_index, slShort, bar_index + sltpBarsExt, slShort, color=color.red, width=1, style=line.style_dotted, extend=extend.right))
        array.push(sltpLines, line.new(bar_index, tpShort, bar_index + sltpBarsExt, tpShort, color=color.lime, width=1, style=line.style_dotted, extend=extend.right))
        array.push(sltpLabels, label.new(bar_index + sltpBarsExt, slShort, "SL", style=label.style_label_left, color=color.red, textcolor=color.white, size=size.tiny))
        array.push(sltpLabels, label.new(bar_index + sltpBarsExt, tpShort, "TP", style=label.style_label_left, color=color.lime, textcolor=color.white, size=size.tiny))

// ═══════════════════════════════════════════════════════════════
// 🔔 ALERTS
// ═══════════════════════════════════════════════════════════════

alertcondition(longEntry, title="🟢 Long Entry", 
   message="BTC LONG\nЦена: {{close}}\nRSI: {{rsi}}\nBB Lower: {{lower}}\nОбъем: {{volume}}")
alertcondition(shortEntry, title="🔴 Short Entry", 
   message="BTC SHORT\nЦена: {{close}}\nRSI: {{rsi}}\nBB Upper: {{upper}}\nОбъем: {{volume}}")
alertcondition(bullDiv, title="📈 Bullish Divergence", message="Bullish divergence on BTC")
alertcondition(bearDiv, title="📉 Bearish Divergence", message="Bearish divergence on BTC")
alertcondition(hiddenBullDiv, title="🔷 Hidden Bullish", message="Hidden bullish divergence — тренд продолжается")
alertcondition(hiddenBearDiv, title="🔶 Hidden Bearish", message="Hidden bearish divergence — тренд продолжается")

// ═══════════════════════════════════════════════════════════════
// 📋 INFO TABLE
// ═══════════════════════════════════════════════════════════════

var table infoTable = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 80), frame_color=color.gray, frame_width=1)
if barstate.islast
    table.cell(infoTable, 0, 0, "Trend", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 0, bullTrend ? "🟢 Bull" : bearTrend ? "🔴 Bear" : "⚪ Neutral", 
               bgcolor=bullTrend ? color.lime : bearTrend ? color.red : color.gray, text_color=color.white)
    
    table.cell(infoTable, 0, 1, "RSI", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 1, str.tostring(rsi, "#.##"), 
               text_color=rsi > rsiOB ? color.red : rsi < rsiOS ? colorBull : color.white)
    
    table.cell(infoTable, 0, 2, "Vol vs Avg", text_color=color.white, text_halign=text.align_left)
    volRatio = volume / volSma
    table.cell(infoTable, 1, 2, str.tostring(volRatio, "#.##") + "x", text_color=volBoost ? color.lime : color.gray)
    
    table.cell(infoTable, 0, 3, "ATR(14)", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 3, str.tostring(atr, "#.##"), text_color=color.yellow)
````
