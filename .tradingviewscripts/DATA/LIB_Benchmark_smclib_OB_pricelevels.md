<!-- tradingview-pine-id: PUB;423f82bafe0c42268bac18ee1fca4586 -->
<!-- tradingviewscripts-format: 1 -->
# LIB Benchmark: smc-lib OB + pricelevels уровни

Source: https://www.tradingview.com/script/nkMxQpcN-LIB-Benchmark-smc-lib-OB-pricelevels-greyICH/

## Description

Its my first try to use swing tradnig and smart money block with restriction by silent exit (without volume) and some more filters

---

## Source Code

````pine
//@version=6
// ============================================================================
// LIB BENCHMARK — порт двух python-библиотек для сравнения глазами.
// ЭТО НЕ НАШ КАНОН. Файл нарочно называется иначе (lib_benchmark), чтобы
// не путать с smc_blocks.pine.
//
// 1) БЛОКИ = smartmoneyconcepts 0.0.26 (joshyattridge/smart-money-concepts),
//    функции swing_highs_lows + ob, портированы 1:1 (2026-07-18):
//    - свинг: экстремум в окне swing_length назад и вперёд (подтверждение
//      с лагом swing_length баров); подряд одноимённые свинги схлопываются
//      в более экстремальный;
//    - бычий OB: первый пробой ЗАКРЫТИЕМ последнего свинг-максимума ->
//      блок = ВСЯ свеча минимального low в ноге между свингом и пробоем
//      (при равенстве - последняя); медвежий зеркально;
//    - митигация: заход цены за дальнюю границу -> «breaker» (серая рамка),
//      после возврата за ближнюю - блок удаляется (как в библиотеке);
//    - сила % = min/max объёмных сумм у бара пробоя (vol+vol[1] против vol[2]).
//    ВАЖНО: библиотека считает пакетно и «видит» свинг сразу (lookahead);
//    здесь свинг подтверждается только через swing_length баров, поэтому
//    пробои, случившиеся раньше подтверждения свинга, OB не создают —
//    на истории блоков может быть чуть меньше, чем в питон-прогоне.
// 2) УРОВНИ = pricelevels (day0market/support_resistance):
//    RawPriceClusterLevels - потенциальные уровни = ЗАКРЫТИЯ, являющиеся
//    rolling-экстремумом окна bars_for_peak; ZigZagClusterLevels - пивоты
//    зигзага по закрытиям; затем кластеризация с порогом
//    merge_percent% от средней цены окна. ПРИБЛИЖЕНИЕ: sklearn ward-linkage
//    заменён на single-linkage по отсортированным ценам (для 1D-разницы
//    невелики). Уровни пересчитываются на последнем баре по окну истории.
// 3) СКОРИНГ «ШТИЛЬ-4» (ревизия 2026-07-29, спека §2d, после причинной
//    ревизии фаз 28-29 и свипа ТФ фазы 31):
//    ДВА признака - ТП (тихий пробой: свеча <= 2 x AVG) и УР (живой
//    уровень-магнит 0.5-1% впереди; ПРИЧИННО, f_lvlAhead = levels.py).
//    ЦЕЛЬ-фрактал ИСКЛЮЧЁН ревизией (в 2024 не отличим от контроля).
//    >=1 признак = полразмера (normal), 2 или (>=1 и ТОБ) = полный (★).
//    ТОБ = объём пробойной ниже среднего 30 предыдущих; сам не открывает.
//    ФАЗА 32: ЛОНГ+ТОБ на ячейке 30m sl=15 НЕ ТОРГУЕТСЯ (минус во всех
//    годах: росту нужен объём покупателей, падению - нет); дроп
//    применяется автоматически только на 30m при swing_length=15.
//    Ячейки ансамбля Штиль-4: 30m 15/20/30, 1h 15, 4h 5 (график + инпут).
// ============================================================================
indicator('LIB Benchmark: smc-lib OB + pricelevels уровни', 'LIB-BENCH', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 2000)

// ---------------- инпуты ----------------
grpOB = 'Блоки (smartmoneyconcepts)'
showOB = input.bool(true, 'Показывать OB', group = grpOB)
swLen = input.int(15, 'swing_length (ячейки Штиль-4)', minval = 3, group = grpOB, tooltip = 'Ячейки ансамбля Штиль-4 (фаза 31): график 30m - свинг' + ' 15/20/30; график 1h - свинг 15; график 4h - свинг 5. Подтверждение' + ' свинга приходит с лагом swing_length баров.')
grpFlt = 'Скоринг системы «Штиль-4» (спека §2d)'
fltTp = input.float(2.0, 'ТП: пробойная свеча <= k*AVG30', minval = 0.5, step = 0.25, group = grpFlt, tooltip = '«Тихий пробой»: диапазон пробойной свечи не больше k IQR-средних' + ' тел 30 баров. Принятый порог системы: 2.0 (рабочая полоса 2.0-2.5).')
showTags = input.bool(false, 'Текст в маркере входа (цена + признаки)', group = grpFlt, tooltip = 'Маркер входа - указатель, остриё которого КАСАЕТСЯ цены' + ' входа (закрытие сигнальной свечи): снизу у лонга, сверху у шорта;' + ' компактный = полразмера, крупный яркий = полный размер. Этот' + ' тумблер добавляет в маркер текст: цену и признаки (ТП/УР/+ТОБ).' + ' По умолчанию выключен - чистый график.')
dropLT = input.bool(true, 'Не торговать ЛОНГ+ТОБ (правило 30m-15)', group = grpFlt, tooltip = 'Фаза 32: лонги с тихим объёмом на ячейке 30m/свинг-15' + ' убыточны во всех трёх годах (росту нужен приток покупателей).' + ' Дроп срабатывает АВТОМАТИЧЕСКИ только на графике 30m при' + ' swing_length=15 - на других ячейках правило не подтверждено.' + ' Отсеянные сигналы видны как бледные треугольники.')
fltLvlMin = input.float(0.5, 'УРОВЕНЬ: живой уровень не ближе, %', minval = 0.0, step = 0.1, group = grpFlt)
fltLvlMax = input.float(1.0, 'УРОВЕНЬ: живой уровень не дальше, %', minval = 0.1, step = 0.1, group = grpFlt, tooltip = 'Фаза 25: живой уровень (правила уровней ниже: >=3 касания,' + ' не убит >2 пробитиями) впереди по ходу сделки в 0.5-1% от входа -' + ' магнит. Третий признак скоринга: >=1 признак = полразмера,' + ' >=2 = полный размер.')
showWeak = input.bool(true, 'Показывать неотобранные входы (бледные)', group = grpFlt)
closeMit = input.bool(false, 'close_mitigation (митигация по телу)', group = grpOB)
keepDead = input.bool(true, 'Честная история: не стирать пробитые блоки', group = grpOB, tooltip = 'Библиотека УДАЛЯЕТ блоки, которые митигированы и затем перебиты' + ' (на выборке 38% блоков стёрто задним числом) - на истории остаются только' + ' выжившие. Вкл: пробитые тускнеют, но остаются. Выкл: поведение библиотеки.')
showBirth = input.bool(true, 'Маркер ВХОДА (появление блока)', group = grpOB, tooltip = 'Блок рисуется задним числом на свече экстремума, а ПОЯВЛЯЕТСЯ на' + ' баре пробоя свинга - это и есть момент входа (фаза 20c/20d: перевес' + ' ~53/46 в сторону блока). Маркер = крупный треугольник + метка с силой' + ' на баре появления + пунктирная связка с блоком. Есть алерты.')
showBoxes = input.bool(false, 'Показывать сами блоки (ящики)', group = grpOB, tooltip = 'По запросу владельца 2026-07-21 выключено: на графике только' + ' метки входа (треугольник + «ВХОД OB N%»). Включи, чтобы вернуть ящики' + ' с их жизненным циклом (живой/митигированный/мёртвый).')
showLink = input.bool(false, 'Связка «вход -> блок» пунктиром', group = grpOB)
colObUp = input.color(color.new(color.blue, 72), 'Бычий OB', group = grpOB)
colObDn = input.color(color.new(color.purple, 72), 'Медвежий OB', group = grpOB)

grpLv = 'Уровни (pricelevels)'
showRawMax = input.bool(true, 'Сопротивления (по хаям, с тенями)', group = grpLv)
showRawMin = input.bool(true, 'Поддержки (по лоям, с тенями)', group = grpLv)
showZZ = input.bool(false, 'ZigZag-кластеры', group = grpLv)
lvlWin = input.int(1800, 'Окно истории, баров', minval = 100, maxval = 1900, group = grpLv, tooltip = 'В бенчмарке 2026-07-18 срез XRP был ~1800 баров 30m.')
barsPeak = input.int(21, 'bars_for_peak (нечётное)', minval = 3, group = grpLv)
mergePct = input.float(0.25, 'merge_percent, % от средней цены', minval = 0.01, step = 0.05, group = grpLv, tooltip = 'Порог склейки кластеров. В бенчмарке 0.1 и 0.25.')
zzDelta = input.float(1.0, 'ZigZag: разворот, %', minval = 0.1, step = 0.1, group = grpLv)
minPeaks = input.int(3, 'Уровень: касаний >=', minval = 1, group = grpLv, tooltip = 'Правило владельца: минимум 3 касания.')
brkMax = input.int(2, 'Уровень: пробитий не более', minval = 0, group = grpLv, tooltip = 'Правило владельца 2026-07-22: «уровни надо заканчивать,' + ' когда произошло более 2-х пробитий». Пробитие = смена стороны' + ' закрытий с закреплением 2 закрытий за мёртвой зоной 0.5*AVG30.' + ' На (N+1)-м пробитии линия ОБРЫВАЕТСЯ на том баре - мёртвый уровень' + ' остаётся виден как отрезок до момента смерти.')
colRawMax = input.color(color.new(color.orange, 15), 'Цвет Raw-max', group = grpLv)
colRawMin = input.color(color.new(#00bcd4, 15), 'Цвет Raw-min', group = grpLv)
colZZ = input.color(color.new(#ab47bc, 25), 'Цвет ZigZag', group = grpLv)

// ============================================================================
// ЧАСТЬ 0. Инфраструктура скоринга: AVG30 (IQR), тихий объём, уровни
// (логика 1:1 с engine.py/levels.py проекта swing_smartmoney_concept5)
// ============================================================================
f_avg30() =>
    arr = array.new<float>()
    for i = 1 to 30 by 1
        v = math.abs(close[i] - open[i])
        if not na(v)
            array.push(arr, v)
    float res = na
    if array.size(arr) == 30
        q1 = array.percentile_nearest_rank(arr, 25)
        q3 = array.percentile_nearest_rank(arr, 75)
        iqr = q3 - q1
        s = 0.0
        cnt = 0
        for i = 0 to array.size(arr) - 1 by 1
            v = array.get(arr, i)
            if v >= q1 - 1.5 * iqr and v <= q3 + 1.5 * iqr
                s := s + v
                cnt := cnt + 1
                cnt
        res := cnt > 0 ? s / cnt : na
        res
    res
avg30 = f_avg30()
// ТОБ («Штиль-2», фаза 27): средний объём 30 ПРЕДЫДУЩИХ баров (без
// текущего) - как в engine.compute_features (vol_ratio < 1)
volAvg30 = ta.sma(volume, 30)[1]

// ЦЕЛЬ-фильтр (фрактал-буферы + f_tgtDist) УДАЛЁН ревизией 2026-07-29:
// исключён из скоринга на причинных данных (spec §2c: в 2024 не отличим
// от контроля, Ц-одиночки разбавляли систему)

// Сбор кластеров в общий пул (без отрисовки): цена = медиана, рождение =
// самый ранний пивот, счёт = число пивотов, тип = 0 max / 1 min / 2 zz.
// Используется и отрисовкой уровней (islast), и скорингом УРОВНЯ.
collectClusters(array<float> prices, array<int> pbars, float dist, int typeId, array<float> medA, array<int> birthA, array<int> cntA, array<int> typeA) =>
    n0 = array.size(prices)
    if n0 > 0
        // сортировка вставками по цене, бары следуют за ценами
        // (границы и array.get разнесены - Pine не ленив, RE10045)
        if n0 > 1
            for i = 1 to n0 - 1 by 1
                p = array.get(prices, i)
                b = array.get(pbars, i)
                j = i - 1
                while j >= 0
                    if array.get(prices, j) > p
                        array.set(prices, j + 1, array.get(prices, j))
                        array.set(pbars, j + 1, array.get(pbars, j))
                        j := j - 1
                        j
                    else
                        break
                array.set(prices, j + 1, p)
                array.set(pbars, j + 1, b)
        int i0 = 0
        for i = 1 to n0 by 1
            last = i == n0
            bool gap = true
            if not last
                gap := array.get(prices, i) - array.get(prices, i - 1) > dist
                gap
            if last or gap
                n = i - i0
                if n >= minPeaks
                    int mid = i0 + int(math.floor((n - 1) / 2.0))
                    float med = n % 2 == 1 ? array.get(prices, mid) : (array.get(prices, mid) + array.get(prices, mid + 1)) / 2
                    int bMin = array.get(pbars, i0)
                    for q = i0 to i - 1 by 1
                        bMin := math.min(bMin, array.get(pbars, q))
                        bMin
                    array.push(medA, med)
                    array.push(birthA, bMin)
                    array.push(cntA, n)
                    array.push(typeA, typeId)
                i0 := i
                i0

// УРОВЕНЬ-фильтр (фаза 25, спека §2b): живой уровень по правилам владельца
// впереди по ходу сделки в [fltLvlMin, fltLvlMax)% от закрытия. ПРИЧИННО:
// вызывается на баре сигнала, пивоты подтверждены к этому бару (окно
// +-half), счёт пробитий с рождения по текущий бар. Логика 1:1 с
// levels.py движка (регресс на питон-стороне подтверждён фазой 25).
f_lvlAhead(int d) =>
    bool found = false
    W = math.min(lvlWin, bar_index - 1)
    int half = int(math.floor((barsPeak - (barsPeak % 2 == 0 ? 1 : 0) - 1) / 2.0))
    if W >= 2 * barsPeak
        float meanC = 0.0
        for o = 0 to W - 1 by 1
            meanC := meanC + close[o]
            meanC
        meanC := meanC / W
        dist = mergePct / 100 * meanC
        medA = array.new<float>()
        birthA = array.new<int>()
        cntA = array.new<int>()
        typeA = array.new<int>()
        arrMax = array.new<float>()
        barMax = array.new<int>()
        arrMin = array.new<float>()
        barMin = array.new<int>()
        for o = W - 1 - half to half by 1
            bool isMx = true
            bool isMn = true
            for k = -half to half by 1
                if high[o + k] > high[o]
                    isMx := false
                    isMx
                if low[o + k] < low[o]
                    isMn := false
                    isMn
            if isMx and not array.includes(arrMax, high[o])
                array.push(arrMax, high[o])
                array.push(barMax, bar_index - o)
            if isMn and not array.includes(arrMin, low[o])
                array.push(arrMin, low[o])
                array.push(barMin, bar_index - o)
        collectClusters(arrMax, barMax, dist, 0, medA, birthA, cntA, typeA)
        collectClusters(arrMin, barMin, dist, 1, medA, birthA, cntA, typeA)
        nL = array.size(medA)
        // сортировка по цене (зеркалим рождения), как в отрисовке
        if nL > 1
            for i2 = 1 to nL - 1 by 1
                pm = array.get(medA, i2)
                pb = array.get(birthA, i2)
                j2 = i2 - 1
                while j2 >= 0
                    if array.get(medA, j2) > pm
                        array.set(medA, j2 + 1, array.get(medA, j2))
                        array.set(birthA, j2 + 1, array.get(birthA, j2))
                        j2 := j2 - 1
                        j2
                    else
                        break
                array.set(medA, j2 + 1, pm)
                array.set(birthA, j2 + 1, pb)
        // объединение соседей ближе dist: побеждает поздний (его цена)
        fM = array.new<float>()
        fB = array.new<int>()
        if nL > 0
            float cM = array.get(medA, 0)
            int cB = array.get(birthA, 0)
            if nL > 1
                for i3 = 1 to nL - 1 by 1
                    if array.get(medA, i3) - cM <= dist
                        if array.get(birthA, i3) > cB
                            cM := array.get(medA, i3)
                            cB := array.get(birthA, i3)
                            cB
                    else
                        array.push(fM, cM)
                        array.push(fB, cB)
                        cM := array.get(medA, i3)
                        cB := array.get(birthA, i3)
                        cB
            array.push(fM, cM)
            array.push(fB, cB)
        // ближе к делу: уровень в полосе впереди, и жив ли он
        if array.size(fM) > 0
            for j3 = 0 to array.size(fM) - 1 by 1
                if not found
                    float medL = array.get(fM, j3)
                    int birthL = array.get(fB, j3)
                    float pctD = (medL - close) * d > 0 ? math.abs(medL - close) / close * 100 : -1.0
                    if pctD >= fltLvlMin and pctD < fltLvlMax
                        float mrgL = na(avg30) ? medL * 0.002 : avg30 * 0.5
                        bool aliveL = true
                        int sideL = 0
                        int cndL = 0
                        int stkL = 0
                        int crosses = 0
                        for o2 = bar_index - birthL to 0 by 1
                            s2 = close[o2] > medL + mrgL ? 1 : close[o2] < medL - mrgL ? -1 : 0
                            if s2 == 0 or s2 == sideL
                                cndL := 0
                                stkL := 0
                                stkL
                            else
                                if s2 == cndL
                                    stkL := stkL + 1
                                    stkL
                                else
                                    cndL := s2
                                    stkL := 1
                                    stkL
                                if stkL >= 2
                                    if sideL != 0
                                        crosses := crosses + 1
                                        crosses
                                    sideL := s2
                                    cndL := 0
                                    stkL := 0
                                    if crosses > brkMax
                                        aliveL := false
                                        break
                        if aliveL
                            found := true
                            found
    found

// ============================================================================
// ЧАСТЬ 1. smartmoneyconcepts: свинги + OB
// ============================================================================
// последние подтверждённые свинги (только нужное для OB состояние)
var int hiIdx = na // бар последнего свинг-максимума
var float hiPx = na
var bool hiCrossed = true
var int loIdx = na
var float loPx = na
var bool loCrossed = true
var int prevType = 0 // тип последнего свинга: 1/-1 (для схлопывания)

// подтверждение свинга с лагом swLen: кандидат = бар swLen назад,
// окно (swLen-1) назад и swLen вперёд от кандидата
candHiOk = true
candLoOk = true
if bar_index >= 2 * swLen
    for o = 0 to 2 * swLen - 1 by 1
        if o != swLen
            if high[o] > high[swLen]
                candHiOk := false
                candHiOk
            if low[o] < low[swLen]
                candLoOk := false
                candLoOk
else
    candHiOk := false
    candLoOk := false
    candLoOk

if candHiOk
    p = bar_index - swLen
    if prevType == 1
        // подряд два максимума: остаётся более высокий (тай-брейк - ранний)
        if high[swLen] > hiPx
            hiIdx := p
            hiPx := high[swLen]
            hiCrossed := false
            hiCrossed
    else
        hiIdx := p
        hiPx := high[swLen]
        hiCrossed := false
        prevType := 1
        prevType
if candLoOk and not candHiOk
    p = bar_index - swLen
    if prevType == -1
        if low[swLen] < loPx
            loIdx := p
            loPx := low[swLen]
            loCrossed := false
            loCrossed
    else
        loIdx := p
        loPx := low[swLen]
        loCrossed := false
        prevType := -1
        prevType

// активные OB
var array<int> obDir = array.new<int>()
var array<float> obTop = array.new<float>()
var array<float> obBot = array.new<float>()
var array<bool> obBrk = array.new<bool>()
var array<box> obBx = array.new<box>()
var array<label> obLb = array.new<label>()

mkOB(int dir_, int fromIdx) =>
    // нога: бары (fromIdx+1 .. bar_index-1); дефолт - предыдущая свеча
    // (в библиотеке в дефолтной ветке top/bottom ПЕРЕПУТАНЫ - воспроизводим,
    // но нормализуем при отрисовке)
    int bi = bar_index - 1
    float t_ = dir_ == 1 ? low[1] : high[1]
    float b_ = dir_ == 1 ? high[1] : low[1]
    int span = bar_index - 1 - (fromIdx + 1)
    if span >= 0
        float ext = na
        int extO = na
        for o = 1 to span + 1 by 1
            v = dir_ == 1 ? low[o] : high[o]
            // «последнее вхождение» минимума в питоне = ПЕРВОЕ с конца,
            // т.е. наименьший offset; идём от свежих к старым и берём
            // строго более экстремальное
            if na(ext) or (dir_ == 1 ? v < ext : v > ext)
                ext := v
                extO := o
                extO
        if not na(extO)
            t_ := high[extO]
            b_ := low[extO]
            bi := bar_index - extO
            bi
    // сила: объёмы у бара пробоя (текущего)
    vHi = volume + volume[1]
    vLo = volume[2]
    mx = math.max(vHi, vLo)
    pct = mx > 0 ? math.min(vHi, vLo) / mx * 100 : 100.0
    [bi, math.max(t_, b_), math.min(t_, b_), pct]

bool obNewL = false // на этом баре появился бычий OB (сигнал входа)
bool obNewS = false // ... медвежий
bool obL0 = false // скоринг: 0 признаков (бледный)
bool obL1 = false // 1 признак (ярче)
bool obL2 = false // оба признака (самый яркий)
bool obS0 = false
bool obS1 = false
bool obS2 = false
if showOB and barstate.isconfirmed
    // митигация/удаление существующих
    if array.size(obDir) > 0
        for i = array.size(obDir) - 1 to 0 by 1
            d_ = array.get(obDir, i)
            t_ = array.get(obTop, i)
            b_ = array.get(obBot, i)
            if array.get(obBrk, i)
                dead = d_ == 1 ? high > t_ : low < b_
                if dead
                    if keepDead
                        // не стираем историю: мёртвый блок блеклый, но
                        // РАЗЛИЧИМЫЙ, с сохранением цвета стороны и
                        // пунктирной рамкой (2026-07-21: серый 94 на тёмной
                        // теме был невидим - вопрос владельца по DOGE)
                        cDead = d_ == 1 ? color.new(color.teal, 87) : color.new(color.maroon, 87)
                        box.set_bgcolor(array.get(obBx, i), cDead)
                        box.set_border_color(array.get(obBx, i), color.new(color.gray, 35))
                        box.set_border_style(array.get(obBx, i), line.style_dashed)
                        label.delete(array.get(obLb, i))
                    else
                        box.delete(array.get(obBx, i))
                        label.delete(array.get(obLb, i))
                    array.remove(obDir, i)
                    array.remove(obTop, i)
                    array.remove(obBot, i)
                    array.remove(obBrk, i)
                    array.remove(obBx, i)
                    array.remove(obLb, i)
            else
                hitB = d_ == 1 ? (closeMit ? math.min(open, close) : low) < b_ : (closeMit ? math.max(open, close) : high) > t_
                if hitB
                    // митигирован (breaker): серый, рамка сплошная -
                    // отличается от мёртвого (цветной блеклый, пунктир)
                    array.set(obBrk, i, true)
                    box.set_border_color(array.get(obBx, i), color.new(color.gray, 45))
                    box.set_bgcolor(array.get(obBx, i), color.new(color.gray, 86))
    // новые OB
    if not na(hiIdx) and not hiCrossed and close > hiPx
        hiCrossed := true
        obNewL := true
        [bi, t_, b_, pct] = mkOB(1, hiIdx)
        // скоринг «Штиль-4» (§2d): ТП + УРОВЕНЬ; ТОБ = усилитель размера
        tpOk = not na(avg30) and high - low <= fltTp * avg30
        lvlOk = f_lvlAhead(1)
        sc = (tpOk ? 1 : 0) + (lvlOk ? 1 : 0)
        tobOk = not na(volAvg30) and volume < volAvg30
        // фаза 32: ЛОНГ+ТОБ не торгуется - ТОЛЬКО на ячейке 30m/sl15
        dropped = dropLT and tobOk and timeframe.period == '30' and swLen == 15
        full = not dropped and (sc >= 2 or sc >= 1 and tobOk)
        obL0 := sc == 0 or sc >= 1 and dropped
        obL1 := sc >= 1 and not dropped and not full
        obL2 := full
        if showBirth and sc >= 1 and not dropped
            // маркер-указатель: остриё КАСАЕТСЯ цены входа (закрытие
            // пробойного бара = реальный вход по рынку); текст - по тумблеру
            string txt = ''
            if showTags
                txt := tpOk ? 'ТП' : ''
                if lvlOk
                    txt := txt + (txt == '' ? '' : '+') + 'УР'
                    txt
                if tobOk
                    txt := txt + '+ТОБ'
                    txt
                txt := (full ? '★' : '') + str.tostring(close, format.mintick) + ' ' + txt
                txt
            label.new(bar_index, close, txt, style = label.style_label_up, textcolor = color.white, color = color.new(color.teal, full ? 0 : 20), size = full ? size.large : size.normal)
        if showLink
            line.new(bar_index, close, bi, t_, style = line.style_dotted, color = color.new(color.teal, 35), width = 1)
        if showBoxes
            bx = box.new(bi, t_, bar_index + 3, b_, border_color = color.new(colObUp, 20), bgcolor = colObUp, extend = extend.none)
            lb = label.new(bi, t_, 'lib OB ' + str.tostring(pct, '#') + '%', style = label.style_label_down, textcolor = color.white, color = color.new(colObUp, 40), size = size.tiny)
            array.push(obDir, 1)
            array.push(obTop, t_)
            array.push(obBot, b_)
            array.push(obBrk, false)
            array.push(obBx, bx)
            array.push(obLb, lb)
    if not na(loIdx) and not loCrossed and close < loPx
        loCrossed := true
        obNewS := true
        [bi, t_, b_, pct] = mkOB(-1, loIdx)
        // шорты: дроп НЕ применяется (шорт+ТОБ - сильнейшая группа, ф.32)
        tpOk = not na(avg30) and high - low <= fltTp * avg30
        lvlOk = f_lvlAhead(-1)
        sc = (tpOk ? 1 : 0) + (lvlOk ? 1 : 0)
        tobOk = not na(volAvg30) and volume < volAvg30
        full = sc >= 2 or sc >= 1 and tobOk
        obS0 := sc == 0
        obS1 := sc >= 1 and not full
        obS2 := full
        if showBirth and sc >= 1
            string txt = ''
            if showTags
                txt := tpOk ? 'ТП' : ''
                if lvlOk
                    txt := txt + (txt == '' ? '' : '+') + 'УР'
                    txt
                if tobOk
                    txt := txt + '+ТОБ'
                    txt
                txt := (full ? '★' : '') + str.tostring(close, format.mintick) + ' ' + txt
                txt
            label.new(bar_index, close, txt, style = label.style_label_down, textcolor = color.white, color = color.new(color.maroon, full ? 0 : 20), size = full ? size.large : size.normal)
        if showLink
            line.new(bar_index, close, bi, b_, style = line.style_dotted, color = color.new(color.maroon, 35), width = 1)
        if showBoxes
            bx = box.new(bi, t_, bar_index + 3, b_, border_color = color.new(colObDn, 20), bgcolor = colObDn, extend = extend.none)
            lb = label.new(bi, b_, 'lib OB ' + str.tostring(pct, '#') + '%', style = label.style_label_up, textcolor = color.white, color = color.new(colObDn, 40), size = size.tiny)
            array.push(obDir, -1)
            array.push(obTop, t_)
            array.push(obBot, b_)
            array.push(obBrk, false)
            array.push(obBx, bx)
            array.push(obLb, lb)

// маркеры входа: три уровня яркости по скорингу
// торгуемые сигналы рисуются label-указателями с остриём ровно на цене
// входа (2026-08-02, решение владельца: plotshape с location.above/below
// отлетал от свечи пропорционально размеру значка); плоттеры остались
// только у неторгуемых (бледные, точность не важна)
plotshape(showBirth and showWeak and obL0, 'Вход лонг (без признаков)', shape.triangleup, location.belowbar, color.new(color.teal, 45), size = size.small)
plotshape(showBirth and showWeak and obS0, 'Вход шорт (без признаков)', shape.triangledown, location.abovebar, color.new(color.maroon, 45), size = size.small)
alertcondition(obNewL, 'LIB OB: появился бычий блок (любой)', 'LIB-BENCH: бычий OB создан {{ticker}} {{interval}}')
alertcondition(obNewS, 'LIB OB: появился медвежий блок (любой)', 'LIB-BENCH: медвежий OB создан {{ticker}} {{interval}}')
alertcondition(obL1 or obL2, 'ШТИЛЬ-4: отобранный ЛОНГ', 'Штиль-4: лонг прошёл скоринг (дроп лонг+ТОБ учтён) {{ticker}} {{interval}}')
alertcondition(obS1 or obS2, 'ШТИЛЬ-4: отобранный ШОРТ', 'Штиль-4: шорт прошёл скоринг {{ticker}} {{interval}}')
alertcondition(obL2 or obS2, 'ШТИЛЬ-4: полный размер (2 признака или признак+ТОБ)', 'Штиль-4: сигнал полного размера {{ticker}} {{interval}}')

// ============================================================================
// ЧАСТЬ 2. pricelevels: кластеры уровней (пересчёт на последнем баре)
// ============================================================================
var array<line> lvLn = array.new<line>()
var array<label> lvLb = array.new<label>()

// collectClusters перенесён в ЧАСТЬ 0 (2026-07-27: нужен скорингу УРОВНЯ)

if barstate.islast
    for ln in lvLn
        line.delete(ln)
    for lb in lvLb
        label.delete(lb)
    array.clear(lvLn)
    array.clear(lvLb)
    W = math.min(lvlWin, bar_index - 1)
    int half = int(math.floor((barsPeak - (barsPeak % 2 == 0 ? 1 : 0) - 1) / 2.0))
    // средняя цена окна -> порог склейки
    float meanC = 0.0
    for o = 0 to W - 1 by 1
        meanC := meanC + close[o]
        meanC
    meanC := meanC / W
    dist = mergePct / 100 * meanC
    // общий пул уровней (max + min + zz) для объединения и отрисовки
    medA = array.new<float>()
    birthA = array.new<int>()
    cntA = array.new<int>()
    typeA = array.new<int>()
    // Raw: закрытия, являющиеся rolling-экстремумом окна barsPeak
    if showRawMax or showRawMin
        arrMax = array.new<float>()
        barMax = array.new<int>()
        arrMin = array.new<float>()
        barMin = array.new<int>()
        // Критерий владельца 2026-07-22 («считать уровни вместе с тенями»):
        // пивоты по ЭКСТРЕМУМАМ баров - сопротивления по хаям, поддержки
        // по лоям (у библиотеки было по закрытиям - уровни вставали внутри
        // толчеи, кейс LINK 8.46)
        for o = W - 1 - half to half by 1
            bool isMx = true
            bool isMn = true
            for k = -half to half by 1
                if high[o + k] > high[o]
                    isMx := false
                    isMx
                if low[o + k] < low[o]
                    isMn := false
                    isMn
            if isMx and showRawMax and not array.includes(arrMax, high[o])
                array.push(arrMax, high[o])
                array.push(barMax, bar_index - o)
            if isMn and showRawMin and not array.includes(arrMin, low[o])
                array.push(arrMin, low[o])
                array.push(barMin, bar_index - o)
        if showRawMax
            collectClusters(arrMax, barMax, dist, 0, medA, birthA, cntA, typeA)
        if showRawMin
            collectClusters(arrMin, barMin, dist, 1, medA, birthA, cntA, typeA)
    // ZigZag по закрытиям: разворот на zzDelta%
    if showZZ
        arrZZ = array.new<float>()
        barZZ = array.new<int>()
        int trend = 0
        float lastPx = close[W - 1]
        int lastOff = W - 1
        for o = W - 2 to 0 by 1
            x = close[o]
            r = x / lastPx - 1
            if trend <= 0
                if r >= zzDelta / 100
                    array.push(arrZZ, lastPx) // подтверждённая впадина
                    array.push(barZZ, bar_index - lastOff)
                    trend := 1
                    lastPx := x
                    lastOff := o
                    lastOff
                else if x < lastPx
                    lastPx := x
                    lastOff := o
                    lastOff
            else
                if r <= -zzDelta / 100
                    array.push(arrZZ, lastPx) // подтверждённый пик
                    array.push(barZZ, bar_index - lastOff)
                    trend := -1
                    lastPx := x
                    lastOff := o
                    lastOff
                else if x > lastPx
                    lastPx := x
                    lastOff := o
                    lastOff
        collectClusters(arrZZ, barZZ, dist, 2, medA, birthA, cntA, typeA)
    // -- ОБЪЕДИНЕНИЕ соседей ближе dist (решение владельца 2026-07-22):
    // побеждает уровень, появившийся ПОЗДНЕЕ (его цена, тип и цвет),
    // касания складываются --
    nL = array.size(medA)
    if nL > 1
        // сортировка по цене (вставками, зеркалим все массивы)
        for i2 = 1 to nL - 1 by 1
            pm = array.get(medA, i2)
            pb = array.get(birthA, i2)
            pc = array.get(cntA, i2)
            pt = array.get(typeA, i2)
            j2 = i2 - 1
            while j2 >= 0
                if array.get(medA, j2) > pm
                    array.set(medA, j2 + 1, array.get(medA, j2))
                    array.set(birthA, j2 + 1, array.get(birthA, j2))
                    array.set(cntA, j2 + 1, array.get(cntA, j2))
                    array.set(typeA, j2 + 1, array.get(typeA, j2))
                    j2 := j2 - 1
                    j2
                else
                    break
            array.set(medA, j2 + 1, pm)
            array.set(birthA, j2 + 1, pb)
            array.set(cntA, j2 + 1, pc)
            array.set(typeA, j2 + 1, pt)
    fM = array.new<float>()
    fB = array.new<int>()
    fC = array.new<int>()
    fT = array.new<int>()
    if nL > 0
        float cM = array.get(medA, 0)
        int cB = array.get(birthA, 0)
        int cC = array.get(cntA, 0)
        int cT = array.get(typeA, 0)
        if nL > 1
            for i3 = 1 to nL - 1 by 1
                if array.get(medA, i3) - cM <= dist
                    cC := cC + array.get(cntA, i3)
                    if array.get(birthA, i3) > cB
                        cM := array.get(medA, i3)
                        cB := array.get(birthA, i3)
                        cT := array.get(typeA, i3)
                        cT
                else
                    array.push(fM, cM)
                    array.push(fB, cB)
                    array.push(fC, cC)
                    array.push(fT, cT)
                    cM := array.get(medA, i3)
                    cB := array.get(birthA, i3)
                    cC := array.get(cntA, i3)
                    cT := array.get(typeA, i3)
                    cT
        array.push(fM, cM)
        array.push(fB, cB)
        array.push(fC, cC)
        array.push(fT, cT)
    // -- ОТРИСОВКА С ОКОНЧАНИЕМ (решение владельца 2026-07-22): после
    // более чем brkMax пробитий линия обрывается на баре смерти --
    if array.size(fM) > 0
        for j3 = 0 to array.size(fM) - 1 by 1
            float medL = array.get(fM, j3)
            int birthL = array.get(fB, j3)
            int cntL = array.get(fC, j3)
            int tidL = array.get(fT, j3)
            color colL = tidL == 0 ? colRawMax : tidL == 1 ? colRawMin : colZZ
            string tgL = tidL == 0 ? 'max' : tidL == 1 ? 'min' : 'zz'
            // пробития: смена стороны закрытий, закрепление 2 закрытия,
            // мёртвая зона 0.5*AVG30
            float mrgL = na(avg30) ? medL * 0.002 : avg30 * 0.5
            int endBar = bar_index
            bool aliveL = true
            int sideL = 0
            int cndL = 0
            int stkL = 0
            int crosses = 0
            for o2 = bar_index - birthL to 0 by 1
                s2 = close[o2] > medL + mrgL ? 1 : close[o2] < medL - mrgL ? -1 : 0
                if s2 == 0 or s2 == sideL
                    cndL := 0
                    stkL := 0
                    stkL
                else
                    if s2 == cndL
                        stkL := stkL + 1
                        stkL
                    else
                        cndL := s2
                        stkL := 1
                        stkL
                    if stkL >= 2
                        if sideL != 0
                            crosses := crosses + 1
                            crosses
                        sideL := s2
                        cndL := 0
                        stkL := 0
                        if crosses > brkMax
                            endBar := bar_index - o2
                            aliveL := false
                            break
            if endBar > birthL
                ln = line.new(birthL, medL, endBar, medL, extend = aliveL ? extend.right : extend.none, color = colL, width = cntL >= 4 ? 2 : 1, style = tidL == 2 ? line.style_dashed : line.style_solid)
                lb = label.new(endBar, medL, tgL + ' ' + str.tostring(cntL), style = label.style_label_left, textcolor = colL, color = color.new(color.black, 100), size = size.tiny)
                array.push(lvLn, ln)
                array.push(lvLb, lb)

// ---- плашка ----
var table info = na
if barstate.islast
    if na(info)
        info := table.new(position.bottom_right, 1, 1)
        info
    table.cell(info, 0, 0, 'LIB-BENCH: порт smartmoneyconcepts + pricelevels — НЕ наш канон', text_color = color.new(color.silver, 20), bgcolor = color.new(color.black, 40), text_size = size.small)
````
