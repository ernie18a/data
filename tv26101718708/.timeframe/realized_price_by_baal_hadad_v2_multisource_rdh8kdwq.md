# Realized Price by Baal Hadad v2 (multi-source)

- url: https://www.tradingview.com/script/rDh8KDwQ-Realized-Price-by-Baal-Hadad-v2-multi-source/
- type: indicator
- pine_id: PUB;1dc765e24e284520b7ae66aa348b43e1
- version: 1.0

## Description

Based on "Realized Price" by Baal Hadad (open-source, MPL 2.0).

The original relied on IntoTheBlock's MVRV feed, which stopped updating on August 15, 2025 and was marked as discontinued by TradingView — the indicator froze. This version fixes that with a multi-source data cascade and adds self-diagnostics.

WHAT IT SHOWS

Realized Price is the average price at which each coin last moved on-chain — the market's aggregate on-chain cost basis. When spot price falls below realized price, the average holder is underwater; historically this marks capitulation zones and potential cycle bottoms. Multiples above it mark overheated zones.

Realized Price = Realized Cap / Circulating Supply

DATA SOURCES (NEW)

Realized Cap, by priority: Custom symbol → CoinMetrics RealCap (direct) → Custom MVRV → IntoTheBlock MVRV (derived as Market Cap / MVRV).

Circulating Supply: Custom → Glassnode → IntoTheBlock → Market Cap / Price (unbreakable fallback).

A source is considered dead if it hasn't updated for N days (default 7, configurable) — the script automatically switches to the next live one. You can also force a specific source or plug in your own symbols.

DIAGNOSTICS (NEW)

An on-chart table shows every feed's status (live / lagging / dead), its last value, date and age in days; the source currently in use is marked with ►. If all Realized Cap sources go silent, the table shows FROZEN and a "data stale" alert fires — instead of silently plotting a frozen line.

DISPLAY

- Realized Price smoothed by MA (default EMA 30 as in the original; SMA / WMA / RMA / HMA / HEMA selectable), optional raw line
- Lower bands: −30% / −50% / −70% (green, accumulation zones)
- Upper bands: ×2 / ×3 / ×4 / ×5 (red, distribution zones)
- Background highlight when price crosses a band; band and signal logic unchanged from the original
- Synthetic MVRV = Market Cap / Realized Cap in the Data Window — replaces the dead ITB feed

ALERTS

Buy zone, Sell zone, Data stale.

NOTES

The coin is detected automatically from the chart ticker, so it works on any coin covered by CoinMetrics / Glassnode — not just BTC / ETH / LTC. On-chain metrics are daily; use on the D timeframe or higher.

==================================================================================

Основано на "Realized Price" от Baal Hadad (открытый код, MPL 2.0).

Оригинал опирался на фид MVRV от IntoTheBlock, который перестал обновляться 15 августа 2025 и помечен TradingView как discontinued — индикатор замер. 

Эта версия решает проблему каскадом источников данных и добавляет самодиагностику.

ЧТО ПОКАЗЫВАЕТ

Realized Price (реализованная цена) — средняя цена, по которой каждая монета в последний раз двигалась в блокчейне, то есть совокупная ончейн-себестоимость рынка. Когда спотовая цена уходит ниже реализованной, средний держатель в убытке — исторически это зоны капитуляции и потенциального дна цикла. Кратные превышения — зоны перегрева.

Realized Price = Realized Cap / Circulating Supply

ИСТОЧНИКИ ДАННЫХ (НОВОЕ)

Realized Cap, по приоритету: Custom-символ → CoinMetrics RealCap (напрямую) → Custom MVRV → IntoTheBlock MVRV (расчёт как Market Cap / MVRV).

Circulating Supply: Custom → Glassnode → IntoTheBlock → Market Cap / Price (несгораемый фолбэк).

Источник считается мёртвым, если не обновлялся N дней (по умолчанию 7, настраивается) — скрипт автоматически переключается на следующий живой. Можно принудительно выбрать конкретный источник или подключить свои символы.

ДИАГНОСТИКА (НОВОЕ)

Таблица на графике показывает статус каждого фида (live / lagging / dead), последнее значение, дату и возраст в днях; активный источник помечен ►. Если все источники Realized Cap замолчали, таблица показывает FROZEN и срабатывает алерт "data stale" — вместо того чтобы молча рисовать замороженную линию.

ОТОБРАЖЕНИЕ

- Realized Price, сглаженная скользящей средней (по умолчанию EMA 30, как в оригинале; на выбор SMA / WMA / RMA / HMA / HEMA), опционально сырая линия
- Нижние полосы: −30% / −50% / −70% (зелёные, зоны накопления)
- Верхние полосы: ×2 / ×3 / ×4 / ×5 (красные, зоны распределения)
- Подсветка фона при пересечении полос; уровни полос и логика сигналов не менялись
- Синтетический MVRV = Market Cap / Realized Cap в окне данных (Data Window) — замена умершему фиду ITB

АЛЕРТЫ

Зона покупки, зона продажи, протухание данных (data stale).

ПРИМЕЧАНИЯ

Монета определяется автоматически из тикера графика, поэтому индикатор работает на любой монете с покрытием CoinMetrics / Glassnode — не только BTC / ETH / LTC. Ончейн-метрики дневные; использовать на таймфрейме D и выше.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kard1nal001 — оригинал "Realized Price by Baal Hadad"
//
// ═══ v2.2: линии + диагностика свежести источников ═══
// Источники (IntoTheBlock умер 15.08.2025, помечен TradingView как discontinued):
//   • COINMETRICS:{X}_MARKETCAPREAL — реализованная капитализация (живой)
//   • GLASSNODE:{X}_SUPPLY          — циркулирующее предложение (живой)
//   • CRYPTOCAP:{X}                 — рыночная капа (живой, real-time)
// Линии и таблица свежести — по монете ТЕКУЩЕГО графика (тикер берётся автоматически).

//@version=6
indicator("Realized Price by Baal Hadad v2 (multi-source)", overlay = true)

// ─── Основные настройки ───
emaLength = input.int(30, title = "MA Length")
maType    = input.string("EMA", title = "MA Type", options = ["EMA", "SMA", "WMA", "RMA", "HMA", "HEMA"], tooltip = "EMA 30 = original. HMA/HEMA are faster but overshoot at reversals. Realized price is smooth anyway — the difference is minimal")
bandsOn   = input.bool(true, title = "Realized Price Bands", tooltip = "Levels: -30%, -50%, -70%, x2, x3, x4, x5 of Realized Price MA")
signalsOn = input.bool(true, title = "Signals")
showRaw   = input.bool(false, title = "Show raw Realized Price (no MA)")

// ─── Источники данных ───
GRP_SRC = "Data Sources"
srcMode      = input.string("Auto", "Realized Cap source", options = ["Auto", "CoinMetrics RealCap", "IntoTheBlock MVRV", "Custom"], group = GRP_SRC, tooltip = "Auto: first live source by priority Custom → CoinMetrics → IntoTheBlock MVRV")
customRcap   = input.symbol("", "Custom: Realized Cap symbol", group = GRP_SRC)
customMvrv   = input.symbol("", "Custom: MVRV symbol", group = GRP_SRC)
customSupply = input.symbol("", "Custom: Supply symbol", group = GRP_SRC)
maxStaleDays = input.int(7, "Source is dead after N silent days", minval = 1, group = GRP_SRC, tooltip = "If data hasn't updated for longer — auto-switch to the next source")

// ─── Диагностика ───
GRP_DIAG = "Diagnostics (current chart coin)"
showDiag = input.bool(true, "Data freshness table", group = GRP_DIAG)
diagPos  = input.string("bottom_left", "Table position", options = ["top_left", "top_right", "bottom_left", "bottom_right"], group = GRP_DIAG)

startDate = timestamp("05 Jan 15 00:00 +0000")
rightDate = time >= startDate

base   = syminfo.basecurrency
MS_DAY = 86400000.0
NO_SYM = "CRYPTOCAP:XXNOSYMBOL"

symRcapCu  = customRcap   == "" ? NO_SYM : customRcap
symMvrvCu  = customMvrv   == "" ? NO_SYM : customMvrv
symSupCu   = customSupply == "" ? NO_SYM : customSupply
symRcapCm  = "COINMETRICS:"  + base + "_MARKETCAPREAL"
symMvrvItb = "INTOTHEBLOCK:" + base + "_MVRV"
symSupGn   = "GLASSNODE:"    + base + "_SUPPLY"
symSupItb  = "INTOTHEBLOCK:" + base + "_CIRCULATINGSUPPLY"
symMcap    = "CRYPTOCAP:"    + base

// Все запросы тянут [значение, время последнего бара метрики] — время нужно для детекта протухания
[rcapCm,  tRcapCm ] = request.security(symRcapCm,  "D", [close, time], ignore_invalid_symbol = true)
[rcapCu,  tRcapCu ] = request.security(symRcapCu,  "D", [close, time], ignore_invalid_symbol = true)
[mvrvItb, tMvrvItb] = request.security(symMvrvItb, "D", [close, time], ignore_invalid_symbol = true)
[mvrvCu,  tMvrvCu ] = request.security(symMvrvCu,  "D", [close, time], ignore_invalid_symbol = true)
[supGn,   tSupGn  ] = request.security(symSupGn,   "D", [close, time], ignore_invalid_symbol = true)
[supItb,  tSupItb ] = request.security(symSupItb,  "D", [close, time], ignore_invalid_symbol = true)
[supCu,   tSupCu  ] = request.security(symSupCu,   "D", [close, time], ignore_invalid_symbol = true)
[mcap,    tMcap   ] = request.security(symMcap,    "D", [close, time], ignore_invalid_symbol = true)
dClose = request.security(syminfo.tickerid, "D", close)

// ─── Свежесть ───
f_ageBar(t) => na(t) ? 1.0e9 : math.max(0.0, (time - t) / MS_DAY)
f_fresh(v, t) => not na(v) and f_ageBar(t) <= maxStaleDays
f_ageNow(t) => na(t) ? float(na) : math.max(0.0, (timenow - t) / MS_DAY)

// ─── Supply: Custom → Glassnode → IntoTheBlock → MCap/Price (несгораемый фолбэк) ───
supDerived = mcap / dClose
supply = f_fresh(supCu, tSupCu) ? supCu : f_fresh(supGn, tSupGn) ? supGn : f_fresh(supItb, tSupItb) ? supItb : supDerived
supSrc = f_fresh(supCu, tSupCu) ? "Custom" : f_fresh(supGn, tSupGn) ? "Glassnode" : f_fresh(supItb, tSupItb) ? "ITB" : "MCap/Price"

// ─── Realized Cap: напрямую (CoinMetrics) или через MVRV (MCap / MVRV) ───
rcapViaItb = mcap / mvrvItb
rcapViaCu  = mcap / mvrvCu

autoCap = f_fresh(rcapCu, tRcapCu) ? rcapCu :
     f_fresh(rcapCm, tRcapCm) ? rcapCm :
     f_fresh(mvrvCu, tMvrvCu) ? rcapViaCu :
     f_fresh(mvrvItb, tMvrvItb) ? rcapViaItb :
     f_ageBar(tRcapCm) <= f_ageBar(tMvrvItb) ? rcapCm : rcapViaItb
autoCapSrc = f_fresh(rcapCu, tRcapCu) ? "Custom RCap" :
     f_fresh(rcapCm, tRcapCm) ? "CoinMetrics" :
     f_fresh(mvrvCu, tMvrvCu) ? "Custom MVRV" :
     f_fresh(mvrvItb, tMvrvItb) ? "ITB MVRV" :
     f_ageBar(tRcapCm) <= f_ageBar(tMvrvItb) ? "CoinMetrics (dead)" : "ITB MVRV (dead)"

realizedCap = srcMode == "CoinMetrics RealCap" ? rcapCm :
     srcMode == "IntoTheBlock MVRV" ? rcapViaItb :
     srcMode == "Custom" ? (not na(rcapCu) ? rcapCu : rcapViaCu) : autoCap
capSrc = srcMode == "Auto" ? autoCapSrc : srcMode

realizedPrice = realizedCap / supply
rpSrc         = fixnan(realizedPrice)

// Все варианты MA считаются на каждом баре (требование Pine), выбирается один
halfLen = math.max(1, math.round(emaLength / 2))
sqrtLen = math.max(1, math.round(math.sqrt(emaLength)))
maEma   = ta.ema(rpSrc, emaLength)
maSma   = ta.sma(rpSrc, emaLength)
maWma   = ta.wma(rpSrc, emaLength)
maRma   = ta.rma(rpSrc, emaLength)
maHma   = ta.wma(2 * ta.wma(rpSrc, halfLen) - ta.wma(rpSrc, emaLength), sqrtLen)
maHema  = ta.ema(2 * ta.ema(rpSrc, halfLen) - ta.ema(rpSrc, emaLength), sqrtLen)
realizedPriceEMA = maType == "SMA" ? maSma : maType == "WMA" ? maWma : maType == "RMA" ? maRma : maType == "HMA" ? maHma : maType == "HEMA" ? maHema : maEma

mvrvSynth = mcap / realizedCap   // расчётный MVRV — замена умершему фиду

anyCapFresh = f_fresh(rcapCu, tRcapCu) or f_fresh(rcapCm, tRcapCm) or f_fresh(mvrvCu, tMvrvCu) or f_fresh(mvrvItb, tMvrvItb)
dataStale   = not anyCapFresh

// ─── Полосы и сигналы (логика оригинала без изменений) ───
lb30 = realizedPriceEMA * 0.7
lb50 = realizedPriceEMA * 0.5
lb70 = realizedPriceEMA * 0.3

ub2 = realizedPriceEMA * 2
ub3 = realizedPriceEMA * 3
ub4 = realizedPriceEMA * 4
ub5 = realizedPriceEMA * 5

buySignal1 = ta.crossunder(lb30, close)
buySignal2 = ta.crossunder(lb50, close)
buySignal3 = ta.crossunder(lb70, close)

sellSignal1 = ta.crossover(ub2, close)
sellSignal2 = ta.crossover(ub3, close)
sellSignal3 = ta.crossover(ub4, close)
sellSignal4 = ta.crossover(ub5, close)

bgcolor(buySignal3 and signalsOn ? color.rgb(0, 255, 0, 50) : buySignal2 and signalsOn ? color.rgb(0, 255, 0, 70) : buySignal1 and signalsOn ? color.rgb(0, 100, 0, 70) : na)
bgcolor(sellSignal4 and signalsOn ? color.rgb(255, 0, 0, 50) : sellSignal3 and signalsOn ? color.rgb(255, 0, 0, 50) : sellSignal2 and signalsOn ? color.rgb(255, 0, 0, 70) : sellSignal1 and signalsOn ? color.rgb(100, 0, 0, 70) : na)

plot(rightDate ? realizedPriceEMA : na, color = color.orange, title = "RealizedPrice MA", linewidth = 2)
plot(showRaw and rightDate ? realizedPrice : na, color = color.new(color.orange, 55), title = "Realized Price (raw)", linewidth = 1)

plot(rightDate and bandsOn ? lb30 : na, color = color.rgb(169, 255, 171, 50), title = "Falling 30%", linewidth = 2)
plot(rightDate and bandsOn ? lb50 : na, color = color.rgb(169, 255, 171, 50), title = "Falling 50%", linewidth = 2)
plot(rightDate and bandsOn ? lb70 : na, color = color.rgb(169, 255, 171, 50), title = "Falling 70%", linewidth = 2)

plot(rightDate and bandsOn ? ub2 : na, color = color.rgb(255, 0, 0, 50), title = "Growth x2", linewidth = 2)
plot(rightDate and bandsOn ? ub3 : na, color = color.rgb(255, 0, 0, 50), title = "Growth x3", linewidth = 2)
plot(rightDate and bandsOn ? ub4 : na, color = color.rgb(255, 0, 0, 50), title = "Growth x4", linewidth = 2)
plot(rightDate and bandsOn ? ub5 : na, color = color.rgb(255, 0, 0, 50), title = "Growth x5", linewidth = 2)

// MVRV виден в окне данных (Data Window), на график не выводится
plot(mvrvSynth, title = "MVRV (synthetic)", color = color.gray, display = display.data_window)

// ─── Алерты ───
alertcondition(dataStale and not dataStale[1], title = "RP: data stale", message = "Realized Price: all Realized Cap/MVRV sources stopped updating!")
alertcondition(buySignal1 or buySignal2 or buySignal3, title = "RP: Buy zone", message = "Price crossed the lower Realized Price band")
alertcondition(sellSignal1 or sellSignal2 or sellSignal3 or sellSignal4, title = "RP: Sell zone", message = "Price crossed the upper Realized Price band")

// ─── Общие помощники таблиц ───
f_cell(tbl, c, r, txt, bg, fg) =>
    table.cell(tbl, c, r, txt, text_size = size.small, bgcolor = bg, text_color = fg)

f_dateStr(t) => na(t) ? "—" : str.format("{0,date,dd.MM.yy}", t)

// ─── Таблица диагностики свежести (монета текущего графика) ───
posTbl = diagPos == "top_left" ? position.top_left : diagPos == "top_right" ? position.top_right : diagPos == "bottom_right" ? position.bottom_right : position.bottom_left
var table diag = table.new(posTbl, 6, 13, border_width = 1, frame_color = color.new(color.gray, 60), border_color = color.new(color.gray, 80))

f_daysStr(t) =>
    a = f_ageNow(t)
    na(a) ? "—" : str.tostring(a, "#")
f_status(v, t) =>
    a = f_ageNow(t)
    na(v) or na(a) ? "❌ none" : a <= maxStaleDays ? "✅ live" : a <= 45 ? "⚠️ lagging" : "❌ dead"
f_statusBg(v, t) =>
    a = f_ageNow(t)
    na(v) or na(a) ? color.new(color.red, 75) : a <= maxStaleDays ? color.new(color.green, 75) : a <= 45 ? color.new(color.orange, 70) : color.new(color.red, 70)

f_row(tbl, r, name, sym, v, t, big, used) =>
    bg = color.new(color.black, 40)
    fg = used ? color.white : color.silver
    f_cell(tbl, 0, r, (used ? "► " : "") + name, bg, fg)
    f_cell(tbl, 1, r, sym, bg, fg)
    f_cell(tbl, 2, r, na(v) ? "—" : big ? str.tostring(v, format.volume) : str.tostring(v, "#.##"), bg, fg)
    f_cell(tbl, 3, r, f_dateStr(t), bg, fg)
    f_cell(tbl, 4, r, f_daysStr(t), bg, fg)
    f_cell(tbl, 5, r, f_status(v, t), f_statusBg(v, t), color.white)
    r + 1

if barstate.islast and showDiag
    table.clear(diag, 0, 0, 5, 12)
    hbg = color.new(color.navy, 40)
    f_cell(diag, 0, 0, "Metric (" + base + ")", hbg, color.white)
    f_cell(diag, 1, 0, "Symbol", hbg, color.white)
    f_cell(diag, 2, 0, "Value", hbg, color.white)
    f_cell(diag, 3, 0, "Date", hbg, color.white)
    f_cell(diag, 4, 0, "Days", hbg, color.white)
    f_cell(diag, 5, 0, "Status", hbg, color.white)
    int r = 1
    r := f_row(diag, r, "RealCap CM", symRcapCm, rcapCm, tRcapCm, true, capSrc == "CoinMetrics" or srcMode == "CoinMetrics RealCap")
    if customRcap != ""
        r := f_row(diag, r, "RealCap Cust", symRcapCu, rcapCu, tRcapCu, true, capSrc == "Custom RCap")
    r := f_row(diag, r, "MVRV ITB", symMvrvItb, mvrvItb, tMvrvItb, false, capSrc == "ITB MVRV" or srcMode == "IntoTheBlock MVRV")
    if customMvrv != ""
        r := f_row(diag, r, "MVRV Cust", symMvrvCu, mvrvCu, tMvrvCu, false, capSrc == "Custom MVRV")
    r := f_row(diag, r, "Supply GN", symSupGn, supGn, tSupGn, true, supSrc == "Glassnode")
    r := f_row(diag, r, "Supply ITB", symSupItb, supItb, tSupItb, true, supSrc == "ITB")
    if customSupply != ""
        r := f_row(diag, r, "Supply Cust", symSupCu, supCu, tSupCu, true, supSrc == "Custom")
    r := f_row(diag, r, "MarketCap", symMcap, mcap, tMcap, true, supSrc == "MCap/Price")
    resBg = dataStale ? color.new(color.red, 55) : color.new(color.teal, 60)
    f_cell(diag, 0, r, "REALIZED PRICE " + base, resBg, color.white)
    f_cell(diag, 1, r, capSrc + " / " + supSrc, resBg, color.white)
    f_cell(diag, 2, r, na(realizedPrice) ? "—" : str.tostring(realizedPrice, format.mintick), resBg, color.white)
    f_cell(diag, 3, r, "MVRV=" + (na(mvrvSynth) ? "—" : str.tostring(mvrvSynth, "#.##")), resBg, color.white)
    f_cell(diag, 4, r, "", resBg, color.white)
    f_cell(diag, 5, r, dataStale ? "❌ FROZEN" : "✅ LIVE", resBg, color.white)
    if dataStale
        r := r + 1
        table.merge_cells(diag, 0, r, 5, r)
        f_cell(diag, 0, r, "⚠️ All Realized Cap sources are dead — the line is frozen. Check symbols or set a Custom source in settings.", color.new(color.red, 40), color.white)
````
