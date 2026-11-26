# MSNR by kichgds

- url: https://www.tradingview.com/script/4RwbQ1ji-msnr-by-kichgds/
- type: indicator
- pine_id: PUB;cffa7f12889c4527a8c302913dcc99d7
- version: 2.0

## Description

ENGLISH

MSNR by kichgds

MSNR by kichgds is an indicator designed to automatically identify potential supply and demand zones based on the MSNR methodology.

Its purpose is to simplify chart analysis by reducing manual zone marking while keeping the trader in control of the decision-making process.

Features

• Automatic A Shape and V Shape detection.
• Zone construction based on candle bodies.
• Configurable zone display.
• Adjustable labels and visual elements.
• Compatible with any symbol and timeframe.

Settings

A Shape — Displays potential supply zones.
V Shape — Displays potential demand zones.
Freshness — Filters zones based on freshness criteria.
Labels — Shows or hides zone labels.

Disclaimer

This indicator does not generate buy or sell signals and should not be considered a trading system.

It is designed as a market structure visualization tool and should be used as part of your own analysis.


РУССКИЙ

MSNR by kichgds

MSNR by kichgds — индикатор, предназначенный для автоматического определения потенциальных зон спроса и предложения на основе методологии MSNR.

Его задача — упростить анализ графика, сократив объём ручной разметки, при этом оставляя принятие торговых решений за трейдером.

Возможности

• Автоматическое построение A Shape и V Shape.
• Построение зон по телам свечей.
• Настраиваемое отображение зон.
• Настраиваемые подписи и визуальные элементы.
• Поддержка любых инструментов и таймфреймов.

Настройки

A Shape — отображение потенциальных зон предложения.
V Shape — отображение потенциальных зон спроса.
Freshness — фильтрация зон по критериям свежести.
Labels — отображение или скрытие подписей.

Важно

Индикатор не генерирует сигналы на покупку или продажу и не является торговой системой.

Он предназначен для визуализации структуры рынка и должен использоваться как часть собственного анализа.

## Source Code

````pine
//@version=6
// =============================================================
//  kichgds · MSNR helper  (v6.2)
//  ФИКС МТФ-свежести: уровень проверяется на пробой по закрытию
//  СВОЕГО таймфрейма (H4-уровень — по H4), а не по свечам графика.
//  Теперь H4-уровни одинаково живут на 5m / 15m / H1 / любом ТФ.
// =============================================================
indicator("kichgds MSNR", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ---------- ОБЩЕЕ ----------
grp0 = "Общее"
pivLeft  = input.int(10, "Пивот: баров СЛЕВА (значимость разворота)", minval = 1, group = grp0)
pivRight = input.int(2, "Пивот: баров СПРАВА (скорость появления, меньше = быстрее)", minval = 1, group = grp0)
maxLevels = input.int(4, "Сколько последних уровней держать (на каждый ТФ)", minval = 1, maxval = 40, group = grp0)
wLine     = input.int(2, "Толщина линии", minval = 1, maxval = 5, group = grp0)
killMode  = input.string("Закрытие тела за уровнем", "Что делает уровень unfresh", options = ["Закрытие тела за уровнем", "Пробой тенью (high/low)"], group = grp0)

// ---------- ТАЙМФРЕЙМЫ ----------
gT = "Таймфреймы"
showH1 = input.bool(false, "H1 (часовые)", group = gT)
showH4 = input.bool(true,  "H4 (4-часовые)", group = gT)
showD  = input.bool(false, "D (дневные)", group = gT)

// ---------- МЕТКА ----------
grpM = "Метка"
showTxt   = input.bool(true, "Показывать метку", group = grpM)
lblSize   = input.string("Обычный", "Размер текста", options = ["Мелкий", "Обычный", "Крупный"], group = grpM)
txtInLine = input.bool(true, "Текст в цвет линии", group = grpM)
cTxt      = input.color(color.white, "Цвет текста (если не в цвет линии)", group = grpM)

// ---------- ЦВЕТА ----------
grpC = "Цвета"
c1A = input.color(#ef5350, "H1 · A", inline = "h1", group = grpC)
c1V = input.color(#ffffff, "H1 · V", inline = "h1", group = grpC)
c4A = input.color(#ef5350, "H4 · A", inline = "h4", group = grpC)
c4V = input.color(#26a69a, "H4 · V", inline = "h4", group = grpC)
cDA = input.color(#ba68c8, "D · A",  inline = "d",  group = grpC)
cDV = input.color(#ffd54f, "D · V",  inline = "d",  group = grpC)
cDead    = input.color(color.new(#787b86, 35), "Unfresh (пробитый)", group = grpC)
showDead = input.bool(false, "Показывать пробитые (unfresh)", group = grpC)

// ---------- ТАБЛО ----------
gb = "Табло биаса"
showBias = input.bool(true, "Показывать табло", group = gb)
biasPos  = input.string("Сверху справа", "Позиция", options = ["Сверху справа", "Сверху слева", "Снизу справа"], group = gb)

lSize = lblSize == "Мелкий" ? size.small : lblSize == "Крупный" ? size.large : size.normal

// ---------- пивоты по телам + время ----------
f_piv() =>
    bh = math.max(open, close)
    bl = math.min(open, close)
    ph = ta.pivothigh(bh, pivLeft, pivRight)
    pl = ta.pivotlow(bl, pivLeft, pivRight)
    tp = time[pivRight]
    [ph, pl, tp]

[ph1, pl1, t1] = request.security(syminfo.tickerid, "60",  f_piv(), lookahead = barmerge.lookahead_off)
[ph4, pl4, t4] = request.security(syminfo.tickerid, "240", f_piv(), lookahead = barmerge.lookahead_off)
[phD, plD, tD] = request.security(syminfo.tickerid, "D",   f_piv(), lookahead = barmerge.lookahead_off)

// ---------- закрытия/тени каждого ТФ (для МТФ-свежести) ----------
f_chl() => [close, high, low]
[c1c, c1h, c1l] = request.security(syminfo.tickerid, "60",  f_chl(), lookahead = barmerge.lookahead_off)
[c4c, c4h, c4l] = request.security(syminfo.tickerid, "240", f_chl(), lookahead = barmerge.lookahead_off)
[cDc, cDh, cDl] = request.security(syminfo.tickerid, "D",   f_chl(), lookahead = barmerge.lookahead_off)

// ---------- биас по текущей D/W свече ----------
isNewDay  = ta.change(time("D")) != 0
isNewWeek = ta.change(time("W")) != 0
var float dOpen = na
var float wOpen = na
if isNewDay or na(dOpen)
    dOpen := open
if isNewWeek or na(wOpen)
    wOpen := open
dayLong  = close >= dOpen
weekLong = close >= wOpen

// ---------- хранилище ----------
var array<line>  L  = array.new<line>()
var array<label> LB = array.new<label>()
var array<float> LP = array.new<float>()
var array<int>   LD = array.new<int>()      // 1 = V, -1 = A
var array<int>   LT = array.new<int>()      // 0 = H1, 1 = H4, 2 = D
var array<bool>  LF = array.new<bool>()

addLevel(int tstart, float price, int dir, int tf, color col, string pfx) =>
    if not na(tstart) and not na(price)
        tcol = txtInLine ? col : cTxt
        ln = line.new(tstart, price, time, price, xloc = xloc.bar_time, color = col, width = wLine, style = line.style_solid, extend = extend.right)
        label lb = na
        if showTxt
            lb := label.new(tstart, price, pfx + (dir == 1 ? " V" : " A"), xloc = xloc.bar_time, style = label.style_none, textcolor = tcol, size = lSize, textalign = text.align_left)
        array.push(L, ln)
        array.push(LB, lb)
        array.push(LP, price)
        array.push(LD, dir)
        array.push(LT, tf)
        array.push(LF, true)
        if array.size(L) > maxLevels * 3
            line.delete(array.shift(L))
            old = array.shift(LB)
            if not na(old)
                label.delete(old)
            array.shift(LP)
            array.shift(LD)
            array.shift(LT)
            array.shift(LF)

isNew(float v) => not na(v) and (na(v[1]) or v != v[1])

handle(float ph, float pl, int tp, int tf, color colA, color colV, string pfx, bool show) =>
    if show
        if isNew(ph)
            addLevel(tp, ph, -1, tf, colA, pfx)
        if isNew(pl)
            addLevel(tp, pl, 1, tf, colV, pfx)

handle(ph1, pl1, t1, 0, c1A, c1V, "H1", showH1)
handle(ph4, pl4, t4, 1, c4A, c4V, "H4", showH4)
handle(phD, plD, tD, 2, cDA, cDV, "D",  showD)

// ---------- свежесть по закрытию РОДНОГО ТФ ----------
if array.size(L) > 0
    for i = array.size(L) - 1 to 0
        fresh = array.get(LF, i)
        if fresh
            price = array.get(LP, i)
            dir   = array.get(LD, i)
            tf    = array.get(LT, i)
            // берём close/high/low того ТФ, на котором построен уровень
            hc = tf == 0 ? c1c : tf == 1 ? c4c : cDc
            hh = tf == 0 ? c1h : tf == 1 ? c4h : cDh
            hl = tf == 0 ? c1l : tf == 1 ? c4l : cDl
            broke = killMode == "Закрытие тела за уровнем" ? (dir == 1 ? hc < price : hc > price) : (dir == 1 ? hl < price : hh > price)
            if broke
                array.set(LF, i, false)
                if showDead
                    ln = array.get(L, i)
                    line.set_color(ln, cDead)
                    line.set_style(ln, line.style_dashed)
                    line.set_width(ln, 1)
                    lb = array.get(LB, i)
                    if not na(lb)
                        label.set_textcolor(lb, cDead)
                else
                    line.delete(array.get(L, i))
                    lb = array.get(LB, i)
                    if not na(lb)
                        label.delete(lb)
                    array.remove(L, i)
                    array.remove(LB, i)
                    array.remove(LP, i)
                    array.remove(LD, i)
                    array.remove(LT, i)
                    array.remove(LF, i)

// ---------- табло 1W / 1D ----------
tPos = biasPos == "Сверху справа" ? position.top_right : biasPos == "Сверху слева" ? position.top_left : position.bottom_right
var table t = table.new(tPos, 2, 2, border_width = 1, frame_color = color.new(color.gray, 70), frame_width = 1)
if showBias and barstate.islast
    bg = color.new(color.black, 20)
    table.cell(t, 0, 0, "1W", bgcolor = bg, text_color = color.gray, text_size = size.normal)
    table.cell(t, 1, 0, weekLong ? "LONG" : "SHORT", bgcolor = bg, text_color = weekLong ? color.white : color.new(#ef5350, 0), text_size = size.normal)
    table.cell(t, 0, 1, "1D", bgcolor = bg, text_color = color.gray, text_size = size.normal)
    table.cell(t, 1, 1, dayLong ? "LONG" : "SHORT", bgcolor = bg, text_color = dayLong ? color.white : color.new(#ef5350, 0), text_size = size.normal)
// v1.0.1 - publication chart updated; calculation logic unchanged
````
