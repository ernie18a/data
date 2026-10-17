# Almazov Trade: Structure

- url: https://www.tradingview.com/script/hLL9QsJ3-almazov-trade-structure/
- type: indicator
- pine_id: PUB;8ab50321b8064abca95b1b84d404d8e0
- version: 2.0

## Description

[b]Almazov Trade: Structure[/b]

Almazov Trade: Structure is a market-structure visualization indicator that builds a continuous swing structure using a user-defined structure timeframe while keeping structural points aligned with the actual chart candles where the corresponding highs and lows occurred.

Instead of simply connecting every local pivot, the script first constructs its own structure bars from the candles of the current chart. For each completed structure bar, it stores its high and low together with the exact chart-bar positions where those extremes were formed.

This allows the structure to be calculated on a larger logical timeframe while its turning points remain attached to the actual price extremes visible on the current chart.

[b]How the structure is built[/b]

The indicator searches for confirmed Swing Highs and Swing Lows on the selected structure timeframe.

Swing High and Swing Low sensitivity can be configured independently.

A swing becomes confirmed only after the required number of structure bars has formed on both sides of the candidate point.

Once two valid opposite structural points are available, the indicator determines the structural direction and starts building a continuous sequence of branches.

During a bullish structure, the algorithm looks for new confirmed highs above the current structural high.

During a bearish structure, it looks for new confirmed lows below the current structural low.

When the current movement extends, the script searches for a valid opposite swing between the previous structural extreme and the newly confirmed extreme.

If a suitable intermediate swing exists, a new structural turn is formed.

If no suitable intermediate swing exists, the current final branch is extended to the new extreme instead of forcing an additional structural point.

This prevents every minor local pivot from automatically becoming part of the displayed structure.

[b]CHoCH logic[/b]

The indicator identifies Change of Character (CHoCH) when the protected structural extreme is broken.

In a bullish structure, a bearish CHoCH is confirmed when a completed structure bar has a low below the protected structural low.

In a bearish structure, a bullish CHoCH is confirmed when a completed structure bar has a high above the protected structural high.

The break is based on the price extreme and does not require the candle to close beyond the protected level.

Because CHoCH is evaluated when a structure bar is completed, the actual break can occur on a lower-timeframe candle before the indicator confirms and displays the CHoCH.

After a CHoCH, the broken side of the previous structure is reset and the algorithm begins forming structure in the opposite direction.

CHoCH lines and labels can be enabled or disabled in the settings.

[b]Structure direction value[/b]

After the initial market structure has been established, the indicator displays its current internal structure direction in the status line:

[list]
[*]1 — bullish structure;
[*]-1 — bearish structure.
[/list]

No direction value is displayed before the initial structure has been established.

This value represents the directional state used by the structure-building algorithm and is not a standalone trading signal.

[b]Structure timeframe[/b]

The structure timeframe is specified in minutes and is constructed internally from the candles of the current chart.

For example, this allows a trader to analyze a larger structural period while remaining on a lower-timeframe chart.

The selected structure timeframe must:

[list]
[*]be equal to or higher than the current chart timeframe;
[*]be exactly divisible by the chart timeframe;
[*]not exceed the chart timeframe by more than 100 times.
[/list]

The indicator works on minute-based and hourly chart intervals subject to these timeframe restrictions.

A structure bar is created only when the required lower-timeframe bars belong to the same structure-timeframe interval.

Incomplete intervals, including intervals affected by missing chart bars or session gaps, may therefore be skipped.

[b]Settings[/b]

"Structure timeframe (minutes)" defines the period used to build the market structure.

"Swing High: bars on each side" controls how many structure bars are required on each side of a candidate high before it can be confirmed as a Swing High.

"Swing Low: bars on each side" independently controls the same requirement for candidate lows.

Higher Swing High or Swing Low values make the corresponding structural points more selective and require a larger surrounding structure.

Lower values make the structure more sensitive to local price movements.

The remaining settings control the visibility of CHoCH lines and labels and the colors used for bullish, bearish and CHoCH structure elements.

[b]Swing confirmation and historical behavior[/b]

Swing points are confirmed with a delay because bars to the right of the candidate extreme are required.

For example, if the Swing High setting is 2, a potential high becomes confirmed only after two additional structure bars have formed to its right.

After confirmation, the structural point is displayed on the chart candle where the corresponding price extreme actually occurred.

Therefore, the historical position of a swing point does not mean that the swing was already confirmed at that moment in real time.

The latest structural branch can also be extended to a later extreme when price continues in the same structural direction without producing a valid opposite structural swing.

As a result, the endpoint of the most recent structural branch can change as additional confirmed structure develops.

These behaviors should be taken into account when reviewing the indicator historically.

[b]Implementation details[/b]

The indicator combines several structural rules:

[list]
[*]Structure bars are constructed internally from the current chart timeframe.
[*]The exact chart candle containing each structure-bar high or low is preserved.
[*]Swing High and Swing Low confirmation depths can be configured independently.
[*]Intermediate counter-swings are searched only within the relevant structural movement.
[*]Candidate structural points are checked against subsequent price action before being accepted.
[*]If no valid counter-swing is available, the existing structural branch is extended instead of creating an additional pivot.
[*]CHoCH changes the internal structural state and starts the formation of structure in the opposite direction.
[/list]

The purpose of these rules is to display a connected structural path rather than an independent collection of local pivot points.

[b]Originality and purpose[/b]

Swing Highs, Swing Lows and CHoCH are established market-structure concepts and are not presented here as proprietary or original concepts.

The distinguishing behavior of this implementation comes from the way these concepts are combined: custom structure-bar construction, preservation of the exact chart candle containing each structural extreme, independent Swing High and Swing Low confirmation settings, validation of intermediate counter-swings within the active structural movement, and continuation of an existing branch when no suitable counter-swing is available.

The script is intended to provide a structured and inspectable representation of price swings rather than to generate standalone trading signals.

[b]Interface translations[/b]

The current indicator interface uses Russian text. English translations are provided below.

"Таймфрейм структуры (минуты)"
— "Structure timeframe (minutes)"

Tooltip:

"Например: 60 — 1 час, 120 — 2 часа. Значение должно быть не меньше таймфрейма графика, делиться на него без остатка и превышать его не более чем в 100 раз."
— "For example: 60 = 1 hour, 120 = 2 hours. The value must be no lower than the chart timeframe, must be divisible by it without a remainder, and cannot exceed it by more than 100 times."

"Swing high: баров слева и справа"
— "Swing High: bars on each side"

"Swing low: баров слева и справа"
— "Swing Low: bars on each side"

"Показывать линии и подписи CHoCH"
— "Show CHoCH lines and labels"

"Восходящая структура"
— "Bullish structure"

"Нисходящая структура"
— "Bearish structure"

"Линия CHoCH при пробое вниз"
— "Bearish CHoCH line"

"Линия CHoCH при пробое вверх"
— "Bullish CHoCH line"

Runtime message:

"Индикатор работает только на минутных и часовых графиках."
— "The indicator works only on minute-based and hourly chart intervals."

Runtime message:

"Таймфрейм структуры должен быть не меньше таймфрейма графика."
— "The structure timeframe must be equal to or higher than the chart timeframe."

Runtime message:

"Таймфрейм структуры должен делиться на таймфрейм графика без остатка."
— "The structure timeframe must be divisible by the chart timeframe without a remainder."

Runtime message:

"Таймфрейм структуры не может быть больше таймфрейма графика более чем в 100 раз."
— "The structure timeframe cannot exceed the chart timeframe by more than 100 times."

[b]Usage notice[/b]

This script is a market-structure visualization tool and not a trading strategy.

It does not place orders, provide performance statistics, or imply that a CHoCH, structural direction, or the displayed 1 / -1 structure value should be used as a standalone entry or exit signal.

The source code is published openly so users can inspect the implementation and verify how the displayed structure is formed.


[b]РУССКАЯ ВЕРСИЯ[/b]

[b]Almazov Trade: Structure[/b]

Almazov Trade: Structure — индикатор визуализации рыночной структуры, который строит непрерывную последовательность структурных движений на выбранном пользователем таймфрейме структуры, сохраняя привязку структурных точек к конкретным свечам графика, на которых фактически находились соответствующие максимумы и минимумы.

Вместо простого соединения всех локальных pivot-точек индикатор сначала самостоятельно формирует структурные бары из свечей текущего графика.

Для каждого завершённого структурного бара сохраняются его максимум и минимум, а также позиции свечей графика, на которых эти экстремумы были сформированы.

Благодаря этому структура может рассчитываться на более крупном логическом периоде, а её точки остаются привязанными к фактическим ценовым экстремумам текущего графика.

[b]Как строится структура[/b]

Индикатор ищет подтверждённые Swing High и Swing Low на выбранном таймфрейме структуры.

Чувствительность Swing High и Swing Low настраивается отдельно.

Свинг становится подтверждённым только после появления заданного количества структурных баров с обеих сторон потенциального экстремума.

После появления двух подходящих противоположных структурных точек индикатор определяет направление структуры и начинает строить непрерывную последовательность её веток.

При восходящей структуре алгоритм ищет новые подтверждённые максимумы выше текущего структурного максимума.

При нисходящей структуре — новые подтверждённые минимумы ниже текущего структурного минимума.

Когда текущее движение продолжается, алгоритм ищет подходящий противоположный свинг между предыдущим структурным экстремумом и новым подтверждённым экстремумом.

Если подходящий промежуточный свинг существует, формируется новый структурный разворот.

Если подходящего промежуточного свинга нет, последняя ветка структуры продлевается до нового экстремума без искусственного добавления дополнительной структурной точки.

Таким образом, не каждый небольшой локальный pivot автоматически становится частью отображаемой структуры.

[b]Логика CHoCH[/b]

Индикатор определяет Change of Character (CHoCH) при пробое защищённого структурного экстремума.

При восходящей структуре медвежий CHoCH подтверждается, когда завершённый структурный бар имеет минимум ниже защищённого структурного минимума.

При нисходящей структуре бычий CHoCH подтверждается, когда завершённый структурный бар имеет максимум выше защищённого структурного максимума.

Для определения слома используется ценовой экстремум. Закрытие свечи за защищённым уровнем не требуется.

Поскольку CHoCH проверяется после завершения структурного бара, сам пробой может произойти на младшей свече раньше, чем индикатор подтвердит и отобразит CHoCH.

После CHoCH пробитая сторона предыдущей структуры сбрасывается, и алгоритм начинает формирование структуры противоположного направления.

Отображение линий и подписей CHoCH можно отключить в настройках.

[b]Значение направления структуры[/b]

После построения первоначальной структуры индикатор отображает в строке состояния текущее внутреннее направление структуры:

[list]
[*]1 — восходящая структура;
[*]-1 — нисходящая структура.
[/list]

До построения первоначальной структуры значение направления не отображается.

Это значение отражает состояние, используемое алгоритмом построения структуры, и не является самостоятельным торговым сигналом.

[b]Таймфрейм структуры[/b]

Таймфрейм структуры задаётся в минутах и формируется внутри индикатора из свечей текущего графика.

Например, это позволяет анализировать структуру более крупного периода, оставаясь на младшем таймфрейме.

Выбранный таймфрейм структуры должен:

[list]
[*]быть не меньше таймфрейма текущего графика;
[*]делиться на таймфрейм графика без остатка;
[*]не превышать таймфрейм графика более чем в 100 раз.
[/list]

Индикатор работает на минутных и часовых интервалах графика с учётом указанных ограничений.

Структурный бар формируется только в том случае, если необходимое количество младших баров относится к одному и тому же интервалу таймфрейма структуры.

Поэтому неполные интервалы, в том числе при отсутствии отдельных баров или наличии сессионных разрывов, могут быть пропущены.

[b]Настройки[/b]

"Таймфрейм структуры (минуты)" задаёт период, на основе которого строится рыночная структура.

"Swing high: баров слева и справа" определяет количество структурных баров с каждой стороны потенциального максимума, необходимое для его подтверждения как Swing High.

"Swing low: баров слева и справа" независимо задаёт аналогичное количество баров для потенциального минимума.

Более высокие значения Swing High или Swing Low делают соответствующие структурные точки более избирательными и требуют более крупного окружающего движения.

Более низкие значения делают структуру чувствительнее к локальным движениям цены.

Остальные настройки отвечают за отображение линий и подписей CHoCH, а также за цвета восходящей, нисходящей и CHoCH-структуры.

[b]Подтверждение свингов и поведение на истории[/b]

Структурные точки подтверждаются с задержкой, поскольку для определения свинга требуется появление баров справа от потенциального экстремума.

Например, при значении Swing High = 2 потенциальный максимум становится подтверждённым только после появления двух следующих структурных баров справа от него.

После подтверждения структурная точка отображается на той свече графика, где фактически находился соответствующий ценовой экстремум.

Поэтому историческое положение свинга не означает, что в реальном времени эта точка уже была подтверждена непосредственно на свече экстремума.

Последняя ветка структуры также может продлеваться до более позднего экстремума, если цена продолжает движение в текущем структурном направлении без появления подходящего противоположного структурного свинга.

Поэтому конечная точка последней ветки структуры может изменяться по мере формирования новых подтверждённых данных.

Это необходимо учитывать при анализе индикатора на истории.

[b]Особенности реализации[/b]

В индикаторе объединено несколько правил построения структуры:

[list]
[*]Структурные бары формируются внутри индикатора из свечей текущего графика.
[*]Сохраняется точная свеча графика, на которой находился максимум или минимум каждого структурного бара.
[*]Глубина подтверждения Swing High и Swing Low настраивается независимо.
[*]Промежуточные противоположные свинги ищутся только внутри соответствующего структурного движения.
[*]Потенциальные структурные точки дополнительно проверяются последующим движением цены.
[*]Если подходящего противоположного свинга нет, существующая ветка продлевается вместо добавления дополнительной pivot-точки.
[*]CHoCH изменяет внутреннее состояние структуры и запускает формирование структуры противоположного направления.
[/list]

Цель этих правил — отображать связанную последовательность структурных движений, а не независимый набор локальных pivot-точек.

[b]Оригинальность и назначение[/b]

Swing High, Swing Low и CHoCH являются общеизвестными концепциями анализа рыночной структуры и не заявляются как авторские или уникальные концепции данного индикатора.

Особенность этой реализации заключается в способе их совместного использования: собственном формировании структурных баров, сохранении точной свечи каждого структурного экстремума, раздельных настройках подтверждения Swing High и Swing Low, проверке промежуточных противоположных свингов внутри текущего структурного движения и продлении существующей ветки при отсутствии подходящего промежуточного свинга.

Индикатор предназначен для структурированного и наглядного представления ценовых движений, а не для генерации самостоятельных торговых сигналов.

[b]Примечание по использованию[/b]

Индикатор предназначен для визуального анализа рыночной структуры и не является торговой стратегией.

Он не открывает сделки, не рассчитывает статистику доходности и не предполагает, что CHoCH, направление структуры или отображаемое значение 1 / -1 должны использоваться как самостоятельный сигнал для входа или выхода.

Исходный код опубликован открыто, поэтому пользователи могут ознакомиться с реализацией и самостоятельно проверить, каким образом формируется отображаемая структура.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Algorithms_ATS

//@version=6
indicator("Almazov Trade: Structure", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

bool use_chart_tf = input.bool(true, "Использовать таймфрейм графика", display=display.none)

int manual_structure_tf = input.int(60, "Таймфрейм структуры (минуты)", minval=1, tooltip="Например: 60 — 1 час, 120 — 2 часа. Значение должно быть не меньше таймфрейма графика, делиться на него без остатка и превышать его не более чем в 100 раз.", display=display.none, active=not use_chart_tf)

int structure_tf = use_chart_tf ? timeframe.multiplier : manual_structure_tf

if barstate.isfirst
    if not timeframe.isminutes
        runtime.error("Индикатор работает только на минутных и часовых графиках.")
    if structure_tf<timeframe.multiplier
        runtime.error("Таймфрейм структуры должен быть не меньше таймфрейма графика.")
    if structure_tf%timeframe.multiplier!=0
        runtime.error("Таймфрейм структуры должен делиться на таймфрейм графика без остатка.")
    if structure_tf>100*timeframe.multiplier
        runtime.error("Таймфрейм структуры не может быть больше таймфрейма графика более чем в 100 раз.")

int tf = int(structure_tf/timeframe.multiplier)

int D_swing_high = input.int(2, "Swing high: баров слева и справа", minval=1, maxval=60, display=display.none)
int D_swing_low = input.int(2, "Swing low: баров слева и справа", minval=1, maxval=60, display=display.none)
var int need_choch = input.bool(true, "Показывать линии и подписи CHoCH", display=display.none) ? 1 : 0

color up_trend = input.color(color.green, "Восходящая структура", display=display.none)
color down_trend = input.color(color.red, "Нисходящая структура", display=display.none)
color choch_up_trend = input.color(color.black, "Линия CHoCH при пробое вниз", display=display.none)
color choch_down_trend = input.color(color.black, "Линия CHoCH при пробое вверх", display=display.none)

type mypair
    float q
    int bar_id
    int sup_id

type mybar
    float hg
    float lw
    int high_id
    int low_id

var array< mybar > bars = array.new<mybar>(0)

var int sz_bars=0

var int dh = D_swing_high+1
var int dl = D_swing_low+1

get_high_id(int cnt)=>
    float mx = high
    int ans = bar_index
    int pos=bar_index
    for int i=0 to cnt-1
        if high[i]>mx
            mx:=high[i]
            ans:=pos
        pos-=1
    ans
get_low_id(int cnt)=>
    float mn = low
    int ans = bar_index
    int pos=bar_index
    for int i=0 to cnt-1
        if low[i]<mn
            mn:=low[i]
            ans:=pos
        pos-=1
    ans

get_high(int cnt)=>
    float mx = high
    for int i=0 to cnt-1
        if high[i]>mx
            mx:=high[i]
    mx
get_low(int cnt)=>
    float mn = low
    for int i=0 to cnt-1
        if low[i]<mn
            mn:=low[i]
    mn

cT = time
currentTime = int(cT / (1000*60*timeframe.multiplier))

is_swing_high(int pos)=>
    ans = true
    if pos-D_swing_high<0 or pos+D_swing_high>=sz_bars
        ans:=false
    else
        float H = bars.get(pos).hg
        for int i=pos-D_swing_high to pos+D_swing_high
            if bars.get(i).hg>H and i!=pos
                ans:=false
    ans
is_swing_low(int pos)=>
    ans = true
    if pos-D_swing_low<0 or pos+D_swing_low>=sz_bars
        ans:=false
    else
        float L = bars.get(pos).lw
        for int i=pos-D_swing_low to pos+D_swing_low
            if bars.get(i).lw<L and i!=pos
                ans:=false
    ans
get_min(int l, int r)=>
    float ans = 100000000
    if l<=r
        for int i=l to r
            ans:=math.min(ans, bars.get(i).lw)
    ans
get_max(int l, int r)=>
    float ans = -1
    if l<=r
        for int i=l to r
            ans:=math.max(ans, bars.get(i).hg)
    ans
fnd_sw_low(int l, int r, int from_bar, int to_bar)=>
    mypair res = mypair.new(-1, -1, -1)
    if l<=r
        for int i=l to r
            if bars.get(i).low_id>from_bar and bars.get(i).low_id<to_bar and (res.q==-1 or res.q>bars.get(i).lw) and is_swing_low(i)
                res := mypair.new(bars.get(i).lw, bars.get(i).low_id, i)
    res
fnd_sw_high(int l, int r, int from_bar, int to_bar)=>
    mypair res = mypair.new(-1, -1, -1)

    if l<=r
        for int i=l to r
            if bars.get(i).high_id>from_bar and bars.get(i).high_id<to_bar and (res.q==-1 or res.q<bars.get(i).hg) and is_swing_high(i)
                res := mypair.new(bars.get(i).hg, bars.get(i).high_id, i)
    res

var line[] lines_trand = array.new_line(0)

var mypair now_low = mypair.new(-1, -1, -1)
var mypair now_high = mypair.new(-1, -1, -1)
var int first_build = -2
var int started = -1

var int type_of_trend = 0

if barstate.isconfirmed and bar_index>=tf-1 and (currentTime+1)%tf==0 and int(time[tf-1]/(60000*structure_tf))==int(time/(60000*structure_tf))
    bars.push(mybar.new(get_high(tf), get_low(tf), get_high_id(tf), get_low_id(tf)))
    sz_bars+=1

    sw_low = is_swing_low(sz_bars-D_swing_low-1)
    sw_high = is_swing_high(sz_bars-D_swing_high-1)
    if first_build!=0
        if sw_low==true and now_low.q==-1
            now_low:=mypair.new(bars.get(sz_bars-dl).lw, bars.get(sz_bars-dl).low_id, sz_bars-dl)
            first_build+=1
        if sw_high==true and now_high.q==-1
            now_high:=mypair.new(bars.get(sz_bars-dh).hg, bars.get(sz_bars-dh).high_id, sz_bars-dh)
            first_build+=1

    if started==-1
        if now_low.q!=-1 and now_low.q>get_min(now_low.sup_id, sz_bars-1)
            now_low:=fnd_sw_low(now_low.sup_id+1, sz_bars-dl, -1, bar_index+1)
            if now_low.q!=-1 and now_low.q>get_min(now_low.sup_id, sz_bars-1)
                now_low:=mypair.new(-1, -1, -1)

        if now_high.q!=-1 and now_high.q<get_max(now_high.sup_id, sz_bars-1)
            now_high:=fnd_sw_high(now_high.sup_id+1, sz_bars-dh, -1, bar_index+1)
            if now_high.q!=-1 and now_high.q<get_max(now_high.sup_id, sz_bars-1)
                now_high:=mypair.new(-1, -1, -1)

        first_build:=(now_low.q==-1 ? -1 : 0)+(now_high.q==-1 ? -1 : 0)

    if started==1
        if type_of_trend==1
            if sw_high==true and bars.get(sz_bars-dh).hg>now_high.q 
                new_low = fnd_sw_low(now_high.sup_id, math.min(sz_bars-dl, sz_bars-dh), now_high.bar_id, bars.get(sz_bars-dh).high_id)
                new_high = mypair.new(bars.get(sz_bars-dh).hg, bars.get(sz_bars-dh).high_id, sz_bars-dh)

                if new_low.q!=-1 and new_low.q<=get_min(new_low.sup_id, sz_bars-1) and new_low.bar_id>now_high.bar_id and new_low.q<now_high.q
                    now = line.new(x1=now_high.bar_id, y1=now_high.q, x2=new_low.bar_id, y2=new_low.q, color=up_trend, width = 3) 
                    lines_trand.push(now)
                    now := line.new(x1=new_low.bar_id, y1=new_low.q, x2=new_high.bar_id, y2=new_high.q, color=up_trend, width = 3) 
                    lines_trand.push(now)

                    now_high:=new_high
                    now_low:=new_low
                else
                    last = lines_trand.get(lines_trand.size()-1)
                    last.set_x2(new_high.bar_id)
                    last.set_y2(new_high.q)
                    now_high:=new_high

            if bars.get(sz_bars-1).lw<now_low.q
                if need_choch==1
                    line.new(x1=now_low.bar_id, y1=now_low.q, x2=bar_index, y2=now_low.q, color=choch_up_trend, width = 2)
                    label.new(int((now_low.bar_id+bar_index)/2), now_low.q, color=color.white, textcolor=down_trend, style = label.style_label_center, text="CHoCH")

                now_low:=mypair.new(-1, -1, -1)
                first_build:=-1
                started:=-1
                type_of_trend:=0
        else
            if sw_low==true and bars.get(sz_bars-dl).lw<now_low.q
                new_high = fnd_sw_high(now_low.sup_id, math.min(sz_bars-dh, sz_bars-dl), now_low.bar_id, bars.get(sz_bars-dl).low_id)
                new_low = mypair.new(bars.get(sz_bars-dl).lw, bars.get(sz_bars-dl).low_id, sz_bars-dl)
                if new_high.q!=-1 and new_high.q>=get_max(new_high.sup_id, sz_bars-1) and new_high.bar_id>now_low.bar_id and new_high.q>now_low.q
                    now = line.new(x1=now_low.bar_id, y1=now_low.q, x2=new_high.bar_id, y2=new_high.q, color=down_trend, width = 3) 
                    lines_trand.push(now)
                    now := line.new(x1=new_high.bar_id, y1=new_high.q, x2=new_low.bar_id, y2=new_low.q, color=down_trend, width = 3) 
                    lines_trand.push(now)

                    now_low:=new_low
                    now_high:=new_high
                else
                    last = lines_trand.get(lines_trand.size()-1)
                    last.set_x2(new_low.bar_id)
                    last.set_y2(new_low.q)
                    now_low:=new_low

            if bars.get(sz_bars-1).hg>now_high.q
                if need_choch==1
                    line.new(x1=now_high.bar_id, y1=now_high.q, x2= bar_index, y2=now_high.q, color=choch_down_trend, width = 2)
                    label.new(int((now_high.bar_id+bar_index)/2), now_high.q, color=color.white, textcolor=up_trend, style = label.style_label_center, text="CHoCH")

                now_high:=mypair.new(-1, -1, -1)
                first_build:=-1
                started:=-1
                type_of_trend:=1

    if started==-1 and first_build==0
        started:=1
        if now_low.bar_id<now_high.bar_id
            if lines_trand.size()>0
                last = lines_trand.get(lines_trand.size()-1)
                last.set_x2(now_low.bar_id)
                last.set_y2(now_low.q)

            now = line.new(x1=now_low.bar_id, y1=now_low.q, x2=now_high.bar_id, y2=now_high.q, color=up_trend, width = 3) 
            lines_trand.push(now)
            type_of_trend:=1
        else
            if lines_trand.size()>0
                last = lines_trand.get(lines_trand.size()-1)
                last.set_x2(now_high.bar_id)
                last.set_y2(now_high.q)

            now = line.new(x1=now_high.bar_id, y1=now_high.q, x2=now_low.bar_id, y2=now_low.q, color=down_trend, width = 3) 
            lines_trand.push(now)
            type_of_trend:=0

plot((type_of_trend==1 ? 1 : -1), color = (type_of_trend==1 ? color.green : color.red), title = 'type_of_trend', display = display.status_line)
````
