# Forex Trend Screener ST

- url: https://www.tradingview.com/script/HpdPTpww-forex-trend-screener-st/
- type: indicator
- pine_id: PUB;e5aff171b5f244cfa30833e971a9ca89
- version: 1.0

## Description

[b]Forex Trend Screener ST — Multi-Timeframe FlowTrend Scanner for 8 Instruments[/b]

[quote]This is a screening / diagnostic tool, not a trading system. It does not generate standalone buy/sell signals and does not predict future price action. Use it together with your own analysis and risk management.[/quote]

Forex Trend Screener ST is a compact dashboard that scans up to 8 instruments at once, each across up to 3 timeframes, and builds a per-instrument trend verdict, a set of scores, a 9-item checklist, and a US Dollar Index (DXY) correlation read — all in one table.

[b]What it does[/b]
[list]
[*] Tracks up to 8 instruments (default: EURUSD, GBPUSD, NZDUSD, AUDUSD, USDCHF, USDCAD, USDJPY, DXY), each on up to 3 independent timeframes.
[*] Computes a FlowTrend momentum reading on every timeframe and derives a BULL / BEAR / — trend verdict per instrument from how many enabled timeframes agree.
[*] Measures DXY Purity (correlation to the Dollar Index), DXY Stability (is that correlation holding or shifting), and Beta (amplitude vs DXY).
[*] Scores every instrument with a Trend Score, an Entry Score, and a combined Final Score, marking the top 3 fully-qualified instruments with 🥇🥈🥉.
[*] Reads current momentum state in plain language: BUILDING, RE-ACCEL, FLAT, FADING, EXTENDED.
[*] Runs a 9-item Checklist and shows a pass count with a hover tooltip explaining exactly what failed.
[*] Includes a separate Market Stability dashboard — a 0-100 diagnostic on whether the overall picture looks settled right now.
[*] Optional alerts and a scheduled daily alarm tied to a condition of your choice.
[/list]

[b]SETTINGS[/b]

[b]Display Mode[/b] [i](top-level, no group)[/i]
[list]
[*] [b]Summary mode (compact table)[/b] — shrinks the table down to just the header, Purity, Score, and Check. All timeframe rows, Trend, and Beta are hidden. Underlying calculations are unaffected, only what is displayed changes.
[*] [b]Show only medalists (🥇🥈🥉)[/b] — an extra column filter: only instruments currently holding a medal (top 3 by Final Score among those fully passing Check) are shown. Works the same in both the full table and Summary mode.
[/list]

[b]Dashboard[/b]
[list]
[*] [b]Theme[/b] — Light or Dark. Light keeps the original pastel-on-white look; Dark uses a near-black background with muted colors for legibility.
[*] [b]Position[/b] — corner/edge of the chart where the main table is drawn.
[*] [b]Text Size[/b] — table font size (Tiny / Small / Normal / Large / Huge).
[*] [b]Hide non-trending columns (Trend = —)[/b] — only show instruments that currently have an active Trend (BULL/BEAR). The DXY column is always shown regardless.
[*] [b]Table background transparency (%)[/b] — 0 = fully opaque. Higher values let the chart show through the table background.
[/list]

[b]Market Stability[/b]
[list]
[*] [b]Show Market Stability dashboard (diagnostic)[/b] — a single 0-100 read on whether the current picture across ALL configured instruments looks trustworthy right now, or is still settling (e.g. right after a major macro event). Purely diagnostic, shown as its own small table separate from the main one. Combines: how long the medalist set has held steady, what fraction of instruments are highly correlated with DXY, what fraction have an active trend, and how long 3+ medalists have held at once.
[*] [b]High-Purity threshold (%)[/b] — an instrument counts toward the "DXY correlation breadth" component once its own Purity is at or above this.
[*] [b]Streak normalization cap (bars)[/b] — how many consecutive bars a streak (medalist composition holding steady, or 3+ medalists holding at once) needs to reach before that component maxes out at 100.
[*] [b]Position[/b] — corner/edge where the Market Stability table is drawn (defaults to the same corner as the main table, usually right below it).
[*] [b]History length (closed chart bars)[/b] — how many recent closed chart bars the bar-to-bar change chain shows before the final current value.
[/list]

[b]Timeframes[/b] [i](up to 3, shared across all instruments)[/i]
[list]
[*] [b]TF 1 / TF 2 / TF 3[/b] — enable/disable each timeframe slot and set its period.
[*] [b]Trend[/b] — whether this timeframe counts toward the per-instrument Trend verdict. When off, the timeframe's value still shows in its own row, it just doesn't have to agree for the verdict.
[*] [b]Confirm[/b] — use the value from this timeframe's last CLOSED bar instead of the real-time (still forming) value. No repainting, but the value updates with a delay of up to one full bar of that timeframe.
[/list]

[b]Instruments[/b] [i](up to 8)[/i]
[list]
[*] [b]Symbol 1-8[/b] — enable/disable each slot and choose the symbol tracked in it. Defaults to a standard major/minor forex basket plus the Dollar Index.
[/list]

[b]DXY Purity[/b]
[list]
[*] [b]Show DXY Purity row[/b] — toggles the "DXY %" row (correlation strength to the Dollar Index).
[*] [b]DXY symbol[/b] — which symbol is treated as the Dollar Index reference.
[*] [b]Correlation timeframe[/b] — which of your 3 timeframe slots the DXY correlation is computed on. TF2 is the default macro-environment read; TF1 is faster/noisier, TF3 is slower.
[*] [b]Short Purity window[/b] — how many CLOSED bars of the chosen timeframe the short-window correlation is measured over.
[*] [b]Show Beta row[/b] — toggles the Beta row: how many times stronger/weaker each instrument moves vs DXY on the same timeframe/window as Purity (1.0 = moves exactly with DXY). A risk/amplitude gauge, not a quality score.
[*] [b]Quiet-guard: bars to SUPPRESS Beta[/b] — how many consecutive "DXY too quiet" bars must pass before Beta is hidden, to avoid a misleading spike when DXY itself is barely moving.
[*] [b]Quiet-guard: bars to RESTORE Beta[/b] — how many consecutive bars the quiet condition must have cleared before Beta is shown again. Kept longer than the suppress setting on purpose, to avoid a false all-clear.
[*] [b]Stable Purity window[/b] — a second, longer correlation window run alongside the Short window, feeding the DXY Stability row.
[*] [b]Show DXY Stability row[/b] — toggles the STABLE / SHIFTING / UNSTABLE row, based on how far apart Short Purity and Stable Purity currently are.
[*] [b]DXY Stability: STABLE threshold[/b] — max |Short − Stable| gap still labeled STABLE.
[*] [b]DXY Stability: SHIFTING threshold[/b] — max gap still labeled SHIFTING; above this it is UNSTABLE.
[/list]

[b]Checklist[/b] [i](9 independent pass/fail conditions; the Check row shows how many currently pass)[/i]
[list=1]
[*] [b]DXY 1h+4h synced[/b] — DXY's own two higher timeframes agree in sign on their closed values.
[*] [b]EUR 1h+4h synced[/b] — same idea, for EURUSD specifically (off by default).
[*] [b]DXY: no enabled higher TF is sign-flagged[/b] — none of DXY's non-fastest enabled timeframes currently disagree between their live and last-closed value.
[*] [b]Reject if DXY 15m is against the trade[/b] — fails if DXY's fastest reading is strongly opposed to the trade direction AND still building rather than fading. Minimum |15m value| against the trade is adjustable.
[*] [b]Trend Score above threshold[/b] — the structural read (older-timeframe strength blended with Purity) must clear a minimum. Threshold is adjustable.
[*] [b]Entry Score above threshold[/b] — the entry-readiness read (fastest-timeframe momentum) must clear a minimum. Threshold is adjustable.
[*] [b]No Trend-timeframe is sign-flagged[/b] — none of the timeframes actually used for this instrument's Trend verdict currently disagree between live and last-closed value.
[*] [b]Beta below threshold[/b] — this instrument's Beta must not be an extreme outlier amplification vs DXY. Maximum Beta is adjustable.
[*] [b]Every Trend-TF has |FlowTrend| above minimum[/b] — rejects a near-zero, noise-level timeframe reading from counting as genuine agreement. Minimum is adjustable.
[/list]

[b]Score[/b]
[list]
[*] [b]Strength: Absolute weight (vs Relative)[/b] — blends an absolute |FlowTrend| reading with a relative "strongest of your current candidates" reading for the Strength component of both scores.
[*] [b]Reset-recovery lookback (closed TF1 bars)[/b] — how far back Score looks to check whether momentum recently paused before building again (a "reset and re-accelerate" pattern).
[*] [b]Reset-recovery bonus (added to Freshness)[/b] — extra credit given to that reset-recovery pattern. Set to 0 to disable.
[*] [b]Trend Score: Purity weight (vs TF2 strength)[/b] — how much Trend Score leans on DXY Purity versus pure structural strength on TF2.
[*] [b]Entry Score: Freshness weight (vs Strength)[/b] — how much Entry Score leans on "is momentum still building" versus "how far has this already stretched."
[*] [b]Momentum: EXTENDED |FlowTrend| threshold[/b] — level above which, combined with fading momentum, the Momentum row labels an instrument EXTENDED.
[*] [b]Momentum: FLAT band[/b] — how close to zero momentum has to be to be labeled FLAT.
[/list]

[b]Alarm[/b] [i](one scheduled daily check, independent of the per-instrument Alerts below)[/i]
[list]
[*] [b]Enable scheduled alarm[/b] — fires once at the chosen time of day, only if the chosen condition is true at that moment. Needs a fine enough chart timeframe (1m or lower) to land exactly on the chosen minute.
[*] [b]Hour / Minute[/b] — time of day to check the condition.
[*] [b]UTC offset (hours)[/b] — your local timezone offset from UTC; whole-hour offsets only.
[*] [b]Condition[/b] — "3+ trend" (at least 3 instruments trending), "1+ medalists", "3 medalists" (all medal slots filled), or "3 medalists, full checklist 3+ bars" (stricter: each medalist has held a full pass for 3+ bars).
[/list]

[b]Alerts[/b] [i](TradingView alert() calls, fire on bar close unless noted)[/i]
[list]
[*] [b]Trend started (0 → BULL/BEAR)[/b] — an instrument's Trend verdict just went from neutral to active.
[*] [b]Check turned green[/b] — fires only on the transition from not-fully-passing to a full ✅ pass; does not re-fire on consecutive passing bars.
[*] [b]Medalist list changed[/b] — fires whenever the top-3 medalist list changes in any way (gained, lost, or reordered).
[*] [b]A medalist's Check streak reached x2[/b] — fires once a current medalist's passing streak reaches exactly 2 consecutive bars.
[/list]

[quote]All thresholds, weights, and lookback windows shown above ship with sensible defaults and can be left untouched — nothing needs to be configured to get a working table on your chart.[/quote]

═══════════════════════════════

[b]Forex Trend Screener ST — мультитаймфреймовый скринер тренда на FlowTrend для 8 инструментов[/b]

[quote]Это инструмент скрининга / диагностики, а не торговая система. Он не генерирует самостоятельные сигналы на покупку/продажу и не предсказывает будущее движение цены. Используйте его вместе с собственным анализом и управлением риском.[/quote]

Forex Trend Screener ST — компактная панель, которая одновременно сканирует до 8 инструментов, каждый по до 3 таймфреймам, и строит по каждому из них вердикт тренда, набор скоров, чек-лист из 9 пунктов и показатель корреляции с индексом доллара (DXY) — всё в одной таблице.

[b]Что делает индикатор[/b]
[list]
[*] Отслеживает до 8 инструментов (по умолчанию: EURUSD, GBPUSD, NZDUSD, AUDUSD, USDCHF, USDCAD, USDJPY, DXY), каждый — по до 3 независимым таймфреймам.
[*] Считает значение FlowTrend на каждом таймфрейме и на основе того, сколько включённых таймфреймов согласны между собой, выводит вердикт тренда: BULL / BEAR / —.
[*] Измеряет DXY Purity (корреляцию с индексом доллара), DXY Stability (устойчива ли эта корреляция или смещается) и Beta (амплитуду движения относительно DXY).
[*] Оценивает каждый инструмент через Trend Score, Entry Score и итоговый Final Score, отмечая топ-3 полностью прошедших чек-лист инструмента значками 🥇🥈🥉.
[*] Показывает текущее состояние моментума простым текстом: BUILDING, RE-ACCEL, FLAT, FADING, EXTENDED.
[*] Прогоняет чек-лист из 9 пунктов и показывает счётчик пройденных с подсказкой при наведении, объясняющей, что именно не прошло.
[*] Включает отдельную панель Market Stability — диагностику 0-100, насколько текущая картина выглядит устоявшейся.
[*] Опциональные алерты и ежедневный алярм по расписанию, привязанный к выбранному условию.
[/list]

[b]НАСТРОЙКИ[/b]

[b]Display Mode[/b] [i](верхний уровень, без группы)[/i]
[list]
[*] [b]Summary mode (compact table)[/b] — сворачивает таблицу до заголовка, Purity, Score и Check. Все строки таймфреймов, Trend и Beta скрыты. На расчёты не влияет — меняется только отображение.
[*] [b]Show only medalists (🥇🥈🥉)[/b] — дополнительный фильтр колонок: показываются только инструменты, у которых сейчас есть медаль (топ-3 по Final Score среди полностью прошедших Check). Работает одинаково и в полной таблице, и в Summary mode.
[/list]

[b]Dashboard[/b]
[list]
[*] [b]Theme[/b] — Light или Dark. Light — исходный пастельный вид на белом фоне; Dark — почти чёрный фон с приглушёнными цветами для читаемости.
[*] [b]Position[/b] — угол/край графика, где рисуется основная таблица.
[*] [b]Text Size[/b] — размер шрифта таблицы (Tiny / Small / Normal / Large / Huge).
[*] [b]Hide non-trending columns (Trend = —)[/b] — показывать только инструменты с активным трендом (BULL/BEAR). Колонка DXY показывается всегда, независимо от этой настройки.
[*] [b]Table background transparency (%)[/b] — 0 = полностью непрозрачный фон. Чем выше значение, тем сильнее просвечивает график сквозь фон таблицы.
[/list]

[b]Market Stability[/b]
[list]
[*] [b]Show Market Stability dashboard (diagnostic)[/b] — единый показатель 0-100: насколько доверия заслуживает текущая картина по всем настроенным инструментам прямо сейчас, или рынок ещё не "устаканился" (например, сразу после крупного макрособытия). Чисто диагностический показатель, отображается отдельной маленькой таблицей. Складывается из: как долго держится неизменным состав медалистов, какая доля инструментов сильно коррелирует с DXY, какая доля сейчас в тренде, и как долго держится 3+ медалиста одновременно.
[*] [b]High-Purity threshold (%)[/b] — при какой Purity инструмент засчитывается в компонент "доля коррелирующих с DXY".
[*] [b]Streak normalization cap (bars)[/b] — сколько баров подряд должна продержаться серия (неизменный состав медалистов или 3+ медалиста одновременно), чтобы соответствующий компонент достиг максимума в 100.
[*] [b]Position[/b] — угол/край, где рисуется таблица Market Stability (по умолчанию тот же угол, что и у основной таблицы, обычно прямо под ней).
[*] [b]History length (closed chart bars)[/b] — сколько последних закрытых баров графика показывается в цепочке изменений от бара к бару перед итоговым текущим значением.
[/list]

[b]Timeframes[/b] [i](до 3 таймфреймов, общие для всех инструментов)[/i]
[list]
[*] [b]TF 1 / TF 2 / TF 3[/b] — включение/выключение каждого слота таймфрейма и его период.
[*] [b]Trend[/b] — учитывать ли этот таймфрейм при формировании вердикта тренда по инструменту. Если выключено, значение таймфрейма всё равно показывается в своей строке, просто не обязано совпадать для вердикта.
[*] [b]Confirm[/b] — использовать значение с последнего ЗАКРЫТОГО бара этого таймфрейма вместо значения в реальном времени (ещё формирующегося бара). Без перерисовки, но значение обновляется с задержкой до одного полного бара этого таймфрейма.
[/list]

[b]Instruments[/b] [i](до 8 инструментов)[/i]
[list]
[*] [b]Symbol 1-8[/b] — включение/выключение каждого слота и выбор символа, отслеживаемого в нём. По умолчанию — стандартная корзина мажоров/минаров плюс индекс доллара.
[/list]

[b]DXY Purity[/b]
[list]
[*] [b]Show DXY Purity row[/b] — переключает строку "DXY %" (силу корреляции с индексом доллара).
[*] [b]DXY symbol[/b] — какой символ считается референсом индекса доллара.
[*] [b]Correlation timeframe[/b] — на каком из ваших 3 слотов таймфреймов считается корреляция с DXY. TF2 — дефолтное макро-прочтение; TF1 быстрее/шумнее, TF3 медленнее.
[*] [b]Short Purity window[/b] — на скольких ЗАКРЫТЫХ барах выбранного таймфрейма считается короткое окно корреляции.
[*] [b]Show Beta row[/b] — переключает строку Beta: во сколько раз сильнее/слабее каждый инструмент движется относительно DXY на том же таймфрейме/окне, что и Purity (1.0 = двигается точно как DXY). Это индикатор риска/амплитуды, а не качества.
[*] [b]Quiet-guard: bars to SUPPRESS Beta[/b] — сколько баров подряд должно продержаться условие "DXY слишком тихий", прежде чем Beta скрывается, чтобы избежать вводящего в заблуждение выброса при почти неподвижном DXY.
[*] [b]Quiet-guard: bars to RESTORE Beta[/b] — сколько баров подряд должно продержаться отсутствие этого условия, прежде чем Beta снова показывается. Специально дольше, чем настройка скрытия — чтобы избежать ложного "всё чисто".
[*] [b]Stable Purity window[/b] — второе, более длинное окно корреляции, работающее параллельно с коротким окном и питающее строку DXY Stability.
[*] [b]Show DXY Stability row[/b] — переключает строку STABLE / SHIFTING / UNSTABLE, основанную на том, насколько сильно расходятся Short Purity и Stable Purity прямо сейчас.
[*] [b]DXY Stability: STABLE threshold[/b] — максимальный разрыв |Short − Stable|, при котором ещё ставится метка STABLE.
[*] [b]DXY Stability: SHIFTING threshold[/b] — максимальный разрыв, при котором ещё ставится метка SHIFTING; выше — UNSTABLE.
[/list]

[b]Checklist[/b] [i](9 независимых условий "прошёл/не прошёл"; строка Check показывает, сколько сейчас проходит)[/i]
[list=1]
[*] [b]DXY 1h+4h synced[/b] — два старших таймфрейма самого DXY совпадают по знаку на закрытых значениях.
[*] [b]EUR 1h+4h synced[/b] — та же идея, но конкретно для EURUSD (по умолчанию выключено).
[*] [b]DXY: no enabled higher TF is sign-flagged[/b] — ни один из не самых быстрых включённых таймфреймов DXY сейчас не расходится между живым и последним закрытым значением.
[*] [b]Reject if DXY 15m is against the trade[/b] — не проходит, если самое быстрое значение DXY сильно направлено против сделки И всё ещё нарастает, а не затухает. Минимальный |15m value| против сделки настраивается.
[*] [b]Trend Score above threshold[/b] — структурное прочтение (сила старших таймфреймов в сочетании с Purity) должно превышать минимум. Порог настраивается.
[*] [b]Entry Score above threshold[/b] — готовность момента входа (моментум на самом быстром таймфрейме) должна превышать минимум. Порог настраивается.
[*] [b]No Trend-timeframe is sign-flagged[/b] — ни один из таймфреймов, реально участвующих в вердикте тренда этого инструмента, сейчас не расходится между живым и последним закрытым значением.
[*] [b]Beta below threshold[/b] — Beta этого инструмента не должна быть экстремальным выбросом амплитуды относительно DXY. Максимум настраивается.
[*] [b]Every Trend-TF has |FlowTrend| above minimum[/b] — отсекает околонулевые, шумовые значения таймфрейма от засчитывания как реального согласия. Минимум настраивается.
[/list]

[b]Score[/b]
[list]
[*] [b]Strength: Absolute weight (vs Relative)[/b] — смешивает абсолютное значение |FlowTrend| с относительным ("сильнейший среди ваших текущих кандидатов") для компонента Strength обоих скоров.
[*] [b]Reset-recovery lookback (closed TF1 bars)[/b] — как далеко назад Score смотрит, чтобы проверить, не было ли недавно паузы в моментуме перед новым нарастанием (паттерн "пауза и разгон").
[*] [b]Reset-recovery bonus (added to Freshness)[/b] — дополнительный бонус за этот паттерн паузы-разгона. 0 — отключает бонус.
[*] [b]Trend Score: Purity weight (vs TF2 strength)[/b] — насколько сильно Trend Score опирается на DXY Purity против чисто структурной силы на TF2.
[*] [b]Entry Score: Freshness weight (vs Strength)[/b] — насколько сильно Entry Score опирается на "всё ещё нарастает ли моментум" против "насколько цена уже успела уйти".
[*] [b]Momentum: EXTENDED |FlowTrend| threshold[/b] — уровень, выше которого в сочетании с затухающим моментумом строка Momentum помечает инструмент как EXTENDED.
[*] [b]Momentum: FLAT band[/b] — насколько близко к нулю должен быть моментум, чтобы получить метку FLAT.
[/list]

[b]Alarm[/b] [i](одна проверка по расписанию раз в день, независимо от алертов по инструментам ниже)[/i]
[list]
[*] [b]Enable scheduled alarm[/b] — срабатывает один раз в выбранное время суток, только если в этот момент выполняется выбранное условие. Требует достаточно мелкого таймфрейма графика (1m и мельче), чтобы точно попасть на нужную минуту.
[*] [b]Hour / Minute[/b] — время суток для проверки условия.
[*] [b]UTC offset (hours)[/b] — смещение вашего часового пояса от UTC; только целые часы.
[*] [b]Condition[/b] — "3+ trend" (минимум 3 инструмента в тренде), "1+ medalists", "3 medalists" (заняты все места медалей) или "3 medalists, full checklist 3+ bars" (строже: каждый медалист держит полный проход чек-листа 3+ бара).
[/list]

[b]Alerts[/b] [i](вызовы alert() TradingView, срабатывают на закрытии бара, если не указано иное)[/i]
[list]
[*] [b]Trend started (0 → BULL/BEAR)[/b] — вердикт тренда инструмента только что перешёл из нейтрального в активный.
[*] [b]Check turned green[/b] — срабатывает только на переходе из не полностью пройденного в полный ✅. Не срабатывает повторно на подряд идущих проходящих барах.
[*] [b]Medalist list changed[/b] — срабатывает при любом изменении списка топ-3 медалистов (добавление, потеря или изменение порядка).
[*] [b]A medalist's Check streak reached x2[/b] — срабатывает, когда серия прохождения у текущего медалиста достигает ровно 2 баров подряд.
[/list]

[quote]Все пороги, веса и периоды подсчёта из списка выше идут с адекватными значениями по умолчанию и их можно не трогать — ничего не нужно настраивать, чтобы получить рабочую таблицу на графике.[/quote]

## Source Code

````pine
//@version=6
indicator("Forex Trend Screener ST", overlay = true)

summary_on_input = input.bool(false, "Summary mode (compact table)",
     tooltip = "Shrinks the table to just the header (with a colored trend marker next to each ticker), Purity, Score, and Check. Hides all TF rows, Trend, and Beta. Underlying calculations are unaffected — this only changes what's displayed.")
medals_only_on = input.bool(false, "Show only medalists (🥇🥈🥉)",
     tooltip = "An extra column filter that works the SAME in both the full table and Summary mode — only instruments currently holding a medal (top 3 by Final Score among those fully passing Check) are shown. Combine with Summary mode for the narrowest possible view, or leave Summary off to see medalists with the full row set.")

theme_choice = input.string("Light", "Theme", options = ["Light", "Dark"], group = "Dashboard",
     tooltip = "Light: white background, original colors. Dark: near-black background, colors adjusted to stay legible against it.")
bool theme_dark = theme_choice == "Dark"
db_position_s = input.string("Bottom Left", "Position", group = "Dashboard",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center",
                "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"])
db_size_s     = input.string("Small", "Text Size", group = "Dashboard",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"])
hide_notrend_on_input = input.bool(false, "Hide non-trending columns (Trend = —)", group = "Dashboard",
     tooltip = "Only show instruments that currently have a Trend (BULL/BEAR). The DXY column is always shown regardless, even with no trend of its own.")
db_transparency = input.int(0, "Table background transparency (%)", minval = 0, maxval = 90, group = "Dashboard",
     tooltip = "0 = fully opaque (default). Higher values let the chart show through the table's background — useful if the table happens to sit over price action, since Pine tables always render in front of chart bars and there's no way to change that.")

market_stability_on = input.bool(true, "Show Market Stability dashboard (diagnostic)", group = "Market Stability",
     tooltip = "A single 0-100 read on whether the current picture across ALL your configured instruments looks trustworthy right now, or is still settling (e.g. right after a major macro event). NOT used to filter or gate anything else — purely diagnostic, shown as its own small dashboard, separate from the main table. Combines: how long the medalist SET has held steady, what fraction of instruments are highly correlated with DXY, what fraction have an active trend, and how long 3+ medalists have held at once.")
market_purity_threshold = input.float(60, "Market Stability: High-Purity threshold (%)", minval = 0, maxval = 100, group = "Market Stability",
     tooltip = "An instrument counts toward the 'DXY correlation breadth' component once its own Purity is at or above this.")
market_streak_cap = input.int(10, "Market Stability: streak normalization cap (bars)", minval = 1, group = "Market Stability",
     tooltip = "How many consecutive bars a streak (medalist composition holding steady, or 3+ medalists holding at once) needs to reach before that component of Market Stability maxes out at 100.")
market_stability_position = input.string("Bottom Right", "Market Stability: Position", group = "Market Stability",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center",
                "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     tooltip = "This is its own small, separate table — defaults to the same corner as the main table, which usually places it right below it. If it ever overlaps the main table instead, move it to a different corner.")
market_stability_history = input.int(6, "Market Stability: history length (closed chart bars)", minval = 2, maxval = 20, group = "Market Stability",
     tooltip = "How many recent closed chart bars the bar-to-bar change chain shows, before the final current value.")

f_tint(color lightHex, color darkHex) =>
    color base = theme_dark ? darkHex : lightHex
    color.new(base, db_transparency)

f_tier3_bg(float ratio, color weakL, color medL, color strongL, color weakD, color medD, color strongD) =>
    color w = f_tint(weakL, weakD)
    color m = f_tint(medL, medD)
    color s = f_tint(strongL, strongD)
    ratio < 0.34 ? w : ratio < 0.67 ? m : s

ft_ch_len  = 9
ft_avg_len = 12
ft_delta_len = 3

tf_1_enable = input.bool(true,  "TF 1", group = "Timeframes", inline = "tf1")
tf_1        = input.timeframe("15",  "", group = "Timeframes", inline = "tf1")
tf_1_trend  = input.bool(true,  "Trend", group = "Timeframes", inline = "tf1",
     tooltip = "Count this timeframe toward the per-instrument Trend verdict row at the bottom. When off, this TF's value still shows in its own row, it just doesn't have to agree for the verdict.")
tf_1_confirm = input.bool(false, "Confirm", group = "Timeframes", inline = "tf1",
     tooltip = "Use the value from this timeframe's last CLOSED bar instead of the real-time (still forming) value — no repainting, but the value updates with a delay of up to one full bar of this timeframe.")

tf_2_enable = input.bool(true,  "TF 2", group = "Timeframes", inline = "tf2")
tf_2        = input.timeframe("60",  "", group = "Timeframes", inline = "tf2")
tf_2_trend  = input.bool(true,  "Trend", group = "Timeframes", inline = "tf2",
     tooltip = "Count this timeframe toward the per-instrument Trend verdict row at the bottom. When off, this TF's value still shows in its own row, it just doesn't have to agree for the verdict.")
tf_2_confirm = input.bool(false, "Confirm", group = "Timeframes", inline = "tf2",
     tooltip = "Use the value from this timeframe's last CLOSED bar instead of the real-time (still forming) value — no repainting, but the value updates with a delay of up to one full bar of this timeframe.")

tf_3_enable = input.bool(true,  "TF 3", group = "Timeframes", inline = "tf3")
tf_3        = input.timeframe("240", "", group = "Timeframes", inline = "tf3")
tf_3_trend  = input.bool(true,  "Trend", group = "Timeframes", inline = "tf3",
     tooltip = "Count this timeframe toward the per-instrument Trend verdict row at the bottom. When off, this TF's value still shows in its own row, it just doesn't have to agree for the verdict.")
tf_3_confirm = input.bool(true, "Confirm", group = "Timeframes", inline = "tf3",
     tooltip = "Use the value from this timeframe's last CLOSED bar instead of the real-time (still forming) value — no repainting, but the value updates with a delay of up to one full bar of this timeframe.")

sym_1_enable = input.bool(true,  "Symbol 1", group = "Instruments", inline = "s1")
sym_1        = input.symbol("OANDA:EURUSD", "", group = "Instruments", inline = "s1")
sym_2_enable = input.bool(true,  "Symbol 2", group = "Instruments", inline = "s2")
sym_2        = input.symbol("OANDA:GBPUSD", "", group = "Instruments", inline = "s2")
sym_3_enable = input.bool(true,  "Symbol 3", group = "Instruments", inline = "s3")
sym_3        = input.symbol("OANDA:NZDUSD", "", group = "Instruments", inline = "s3")
sym_4_enable = input.bool(true,  "Symbol 4", group = "Instruments", inline = "s4")
sym_4        = input.symbol("OANDA:AUDUSD", "", group = "Instruments", inline = "s4")
sym_5_enable = input.bool(true,  "Symbol 5", group = "Instruments", inline = "s5")
sym_5        = input.symbol("OANDA:USDCHF", "", group = "Instruments", inline = "s5")
sym_6_enable = input.bool(true,  "Symbol 6", group = "Instruments", inline = "s6")
sym_6        = input.symbol("OANDA:USDCAD", "", group = "Instruments", inline = "s6")
sym_7_enable = input.bool(true,  "Symbol 7", group = "Instruments", inline = "s7")
sym_7        = input.symbol("OANDA:USDJPY", "", group = "Instruments", inline = "s7")
sym_8_enable = input.bool(true, "Symbol 8", group = "Instruments", inline = "s8")
sym_8        = input.symbol("TVC:DXY", "", group = "Instruments", inline = "s8")

bool hide_notrend_on = hide_notrend_on_input
bool summary_on      = summary_on_input

f_pos(string s) =>
    s == "Top Left"      ? position.top_left :
     s == "Top Center"    ? position.top_center :
     s == "Top Right"     ? position.top_right :
     s == "Middle Left"   ? position.middle_left :
     s == "Middle Center" ? position.middle_center :
     s == "Middle Right"  ? position.middle_right :
     s == "Bottom Left"   ? position.bottom_left :
     s == "Bottom Center" ? position.bottom_center :
     position.bottom_right

f_size(string s) =>
    s == "Tiny"   ? size.tiny :
     s == "Small"  ? size.small :
     s == "Normal" ? size.normal :
     s == "Large"  ? size.large :
     size.huge

f_short_sym(string s) =>
    int idx = str.pos(s, ":")
    idx >= 0 ? str.substring(s, idx + 1) : s

f_header_label(string sym, int verdict, bool isDxy) =>
    string base = f_short_sym(sym)
    summary_on and not isDxy and verdict != 0 ? base + " " + (verdict == 1 ? "📈" : "📉") : base

f_ft1(int chlen, int avglen) =>
    float src = hlc3
    float esa = ta.ema(src, chlen)
    float de  = ta.ema(math.abs(src - esa), chlen)
    float ci  = (src - esa) / (0.015 * de)
    ta.ema(ci, avglen)

f_ft_pair(int chlen, int avglen) =>
    float ft  = f_ft1(chlen, avglen)
    float ftc = ft[1]
    float cc  = close[1]
    float rc  = (close[1] - close[2]) / close[2]
    [ft, ftc, cc, rc]

f_ft_pair_tf1(int chlen, int avglen, int deltaLen) =>
    float ft    = f_ft1(chlen, avglen)
    float ftc   = ft[1]
    float cc    = close[1]
    float rc    = (close[1] - close[2]) / close[2]
    float slopePerBar = ta.linreg(ft[1], deltaLen, 0) - ta.linreg(ft[1], deltaLen, 1)
    float delta = slopePerBar * deltaLen

    [ft, ftc, cc, rc, delta]

f_instrument_fts(string sym) =>
    [w1, w1c, c1, r1, d1] = request.security(sym, tf_1, f_ft_pair_tf1(ft_ch_len, ft_avg_len, ft_delta_len), lookahead = barmerge.lookahead_off)
    [w2, w2c, c2, r2] = request.security(sym, tf_2, f_ft_pair(ft_ch_len, ft_avg_len), lookahead = barmerge.lookahead_off)
    [w3, w3c, c3, r3] = request.security(sym, tf_3, f_ft_pair(ft_ch_len, ft_avg_len), lookahead = barmerge.lookahead_off)
    float v1 = tf_1_confirm ? w1c : w1
    float v2 = tf_2_confirm ? w2c : w2
    float v3 = tf_3_confirm ? w3c : w3
    bool f1 = not tf_1_confirm and not na(w1) and not na(w1c) and math.sign(w1) != math.sign(w1c)
    bool f2 = not tf_2_confirm and not na(w2) and not na(w2c) and math.sign(w2) != math.sign(w2c)
    bool f3 = not tf_3_confirm and not na(w3) and not na(w3c) and math.sign(w3) != math.sign(w3c)
    [v1, v2, v3, c1, c2, c3, r1, r2, r3, d1, f1, f2, f3, w2c, w3c]

[w1_1, w1_2, w1_3, c1_1, c1_2, c1_3, r1_1, r1_2, r1_3, ftd_1, f1_1, f1_2, f1_3, w1_2c, w1_3c] = f_instrument_fts(sym_1)
[w2_1, w2_2, w2_3, c2_1, c2_2, c2_3, r2_1, r2_2, r2_3, ftd_2, f2_1, f2_2, f2_3, w2_2c, w2_3c] = f_instrument_fts(sym_2)
[w3_1, w3_2, w3_3, c3_1, c3_2, c3_3, r3_1, r3_2, r3_3, ftd_3, f3_1, f3_2, f3_3, w3_2c, w3_3c] = f_instrument_fts(sym_3)
[w4_1, w4_2, w4_3, c4_1, c4_2, c4_3, r4_1, r4_2, r4_3, ftd_4, f4_1, f4_2, f4_3, w4_2c, w4_3c] = f_instrument_fts(sym_4)
[w5_1, w5_2, w5_3, c5_1, c5_2, c5_3, r5_1, r5_2, r5_3, ftd_5, f5_1, f5_2, f5_3, w5_2c, w5_3c] = f_instrument_fts(sym_5)
[w6_1, w6_2, w6_3, c6_1, c6_2, c6_3, r6_1, r6_2, r6_3, ftd_6, f6_1, f6_2, f6_3, w6_2c, w6_3c] = f_instrument_fts(sym_6)
[w7_1, w7_2, w7_3, c7_1, c7_2, c7_3, r7_1, r7_2, r7_3, ftd_7, f7_1, f7_2, f7_3, w7_2c, w7_3c] = f_instrument_fts(sym_7)
[w8_1, w8_2, w8_3, c8_1, c8_2, c8_3, r8_1, r8_2, r8_3, ftd_8, f8_1, f8_2, f8_3, w8_2c, w8_3c] = f_instrument_fts(sym_8)

dxy_on          = input.bool(true, "Show DXY Purity row", group = "DXY Purity")
dxy_symbol      = input.symbol("TVC:DXY", "DXY symbol", group = "DXY Purity")
dxy_tf_choice   = input.string("TF2", "Correlation timeframe", options = ["TF1", "TF2", "TF3"], group = "DXY Purity",
     tooltip = "Which of your three screener timeframe slots to run the DXY correlation on. TF2 (1h by default) is the default: this reading answers 'is this pair's move connected to the dollar flow right now', which is a slower, macro-environment question — a fast TF like TF1 (15m) can flip its correlation reading quickly on ordinary noise, which is fine for momentum/entry-readiness (that's what TF1's own FT/FTΔ are for) but not ideal for this specific question. TF1/TF3 remain available if you want a faster or slower read instead.")
dxy_len         = input.int(20, "Short Purity window (CLOSED bars of the TF above, not chart bars)", minval = 5, maxval = 200, group = "DXY Purity")
beta_on         = input.bool(true, "Show Beta row", group = "DXY Purity",
     tooltip = "Beta = how many times stronger/weaker each instrument moves vs DXY on the same TF/window as Purity (1.0 = moves exactly with DXY). Only shown when the DXY Purity row above is also on.")
beta_quiet_enter_bars = input.int(2, "  Quiet-guard: bars to SUPPRESS Beta", minval = 1, group = "DXY Purity",
     tooltip = "How many consecutive bars the 'DXY too quiet' condition must hold before Beta actually gets suppressed. Kept short (and shorter than the 'bars to RESTORE' setting below) on purpose: wrongly hiding Beta for a bar or two costs little (Score just runs briefly without it), while wrongly showing it too early risks printing the misleading spike this guard exists to prevent — the two mistakes aren't equally costly, so the thresholds aren't equal either.")
beta_quiet_exit_bars = input.int(3, "  Quiet-guard: bars to RESTORE Beta", minval = 1, group = "DXY Purity",
     tooltip = "How many consecutive bars the condition must have CLEARED before Beta is trusted again. Kept longer than 'bars to SUPPRESS' above — a false all-clear brings back exactly the misleading-spike risk the guard exists to prevent, so restoring Beta earns a higher bar of confidence than suppressing it does. Note: these bars are counted on the Correlation timeframe (DXY Purity settings above), which defaults to TF2 (1h) — so 3 bars here means roughly 3 hours by default, not 3 fast bars.")

chk1_on = input.bool(true, "1. DXY 1h+4h synced (closed values, same sign)", group = "Checklist")
chk2_on = input.bool(false, "2. EUR 1h+4h synced (closed values, same sign)", group = "Checklist")
chk3_on = input.bool(true, "3. DXY: no enabled higher TF (all except the fastest) is sign-flagged", group = "Checklist")
chk4_on = input.bool(true, "4. Reject if DXY 15m is against the trade with |value| above threshold AND still building (not fading)", group = "Checklist")
chk4_min_abs = input.float(40, "  Minimum |15m value| against the trade (for check 4)", minval = 0, group = "Checklist")
chk5_on = input.bool(true, "5. Trend Score above threshold", group = "Checklist",
     tooltip = "Trend Score reflects the older-TF structure (TF2 strength blended with Purity) — this check asks whether that structural read is strong enough on its own, independent of how ready the entry moment itself looks (that's check 6).")
chk5_min_trend = input.float(55, "  Minimum Trend Score (for check 5)", minval = 0, maxval = 100, group = "Checklist",
     tooltip = "Trend Score usually runs a bit higher than Entry Score by default, because Purity (which normally isn't too low for a healthy pair) is blended in — so this threshold is set higher than Entry Score's own by default to account for that built-in lift, not because Trend Score itself needs to be 'better'.")
chk6_on = input.bool(true, "6. Entry Score above threshold", group = "Checklist",
     tooltip = "Entry Score reflects TF1 momentum readiness (Strength + Freshness, additively combined) — this check asks whether the entry moment itself looks ready right now, independent of the broader structure (that's check 5).")
chk6_min_entry = input.float(30, "  Minimum Entry Score (for check 6)", minval = 0, maxval = 100, group = "Checklist")
chk7_on = input.bool(true, "7. This instrument: none of the TFs used for Trend are sign-flagged ([live] already crossed vs closed)", group = "Checklist")
chk8_on = input.bool(true, "8. This instrument's Beta is below threshold (not an extreme/outlier amplification vs DXY)", group = "Checklist")
chk8_max_beta = input.float(2.0, "  Maximum Beta (for check 8)", minval = 0, group = "Checklist")
chk9_on = input.bool(true, "9. Every Trend-TF has |FT| above this instrument's own minimum (no near-zero, noise-level TF counted as agreeing)", group = "Checklist")
chk9_min_abs = input.float(10, "  Minimum |FT| per Trend TF (for check 9)", minval = 0, group = "Checklist",
     tooltip = "A TF with |FT| at or below this still technically has the 'right' sign for Trend, but is close enough to zero that it isn't really confirming anything — e.g. a BULL verdict where one TF reads +7.4 while the others read +38 and +40.")

bool checklist_any_on = chk1_on or chk2_on or chk3_on or chk4_on or chk5_on or chk6_on or chk7_on or chk8_on or chk9_on

score_abs_weight = input.float(0.5, "Strength: Absolute weight (vs Relative)", minval = 0, maxval = 1, step = 0.05, group = "Score",
     tooltip = "Score's Strength component blends two readings of TF1's FT: ABSOLUTE (|FT| on a fixed 0-60 scale, so it's stable regardless of what your other instruments are doing right now) and RELATIVE (FT vs the strongest instrument on this row right now, i.e. 'who's strongest of my current candidates'). This slider sets Absolute's share; Relative gets the rest (1 - this value). At 1.0, Strength no longer depends at all on what your other instruments are doing — a spike in one pair's FT can no longer drag down another pair's Score just by raising the row's own max. At 0.0, it's the original relative-only behavior (matches versions before this setting existed). Default 0.5 is a straight 50/50 blend: enough Absolute to stop one instrument's move from silently changing another's Score, while keeping enough Relative to still meaningfully separate your fixed watchlist's candidates from each other on days when the whole market is moving in a similarly muted or similarly strong way.")
score_reset_lookback = input.int(5, "Reset-recovery lookback (closed TF1 bars)", minval = 2, group = "Score",
     tooltip = "How far back (in closed TF1 bars) Score looks to check whether momentum recently paused before building again — a 'reset and re-accelerate' pattern (trend already established, had a brief pullback in momentum, now holding a rebuild), as opposed to momentum that's simply been climbing non-stop with no pause at all. Two conditions must BOTH hold within this window for the bonus below to apply: momentum (FTΔ in the trend's direction) dipped to zero or below at some point, AND the recovery already held for at least one full prior closed bar (not just this bar flipping positive) — a single-bar flip after a long slide doesn't count as a confirmed reset, only a pause that's already shown it survived does. A monotonic climb with no dip anywhere in this window gets no bonus — same Freshness as before this setting existed.")
score_reset_bonus = input.float(0.15, "Reset-recovery bonus (added to Freshness)", minval = 0, maxval = 1, step = 0.05, group = "Score",
     tooltip = "How much extra credit (0-1, added directly to the 0-1 Freshness ratio and then capped back at 1) an instrument gets for the reset-recovery pattern above. Reasoning: a fresh push right after a genuine pause can be a stronger continuation signal than an equally-positive FTΔ that's just been climbing the whole time with no pause at all — the pause+restart is evidence the trend already survived one hesitation and is still going. Set to 0 to disable this bonus entirely (Freshness behaves exactly as before this setting existed).")
trend_purity_weight = input.float(0.4, "Trend Score: Purity weight (vs TF2 strength)", minval = 0, maxval = 1, step = 0.05, group = "Score",
     tooltip = "Trend Score blends TF2's Strength (same absolute/relative blend as Entry Score uses on TF1, just computed on TF2 instead) with Short Purity — this slider sets Purity's share; TF2 Strength gets the rest. At 0, Trend Score is pure TF2 structural strength with no macro-environment read at all. At 1, it's pure Purity. Default 0.4 leans toward TF2 strength while still giving the dollar-environment reading real weight. Falls back to 100% TF2 Strength when Purity is unavailable (DXY Purity toggled off, or not enough history yet).")
dxy_len_stable = input.int(60, "Stable Purity window (CLOSED bars of the DXY TF, long-term reference)", minval = 10, group = "DXY Purity",
     tooltip = "A second, longer correlation window run alongside the Short window above (same TF, same method, just more bars) — feeds the new 'DXY Stab' row, which compares the two to flag when a Short Purity reading has shifted recently rather than held steady. Independent of Beta's own quiet-guard window (dxy_len x 5) and of dxy_len itself — changing this doesn't affect Beta or Short Purity at all.")
dxy_stability_on = input.bool(true, "Show DXY Stability row", group = "DXY Purity",
     tooltip = "STABLE / SHIFTING / UNSTABLE per instrument, based on how far apart Short Purity and Stable Purity currently are. A small gap means the correlation-to-dollar reading has held steady across both windows (trust the Short Purity number above more); a big gap means it's recently shifted (treat it with more caution). Only shown when the DXY Purity row above is also on.")
dxy_stable_thresh = input.float(10, "  DXY Stability: STABLE threshold (max |Short - Stable| gap)", minval = 0, group = "DXY Purity",
     tooltip = "If |Short Purity - Stable Purity| is at or below this, the instrument is labeled STABLE.")
dxy_shifting_thresh = input.float(25, "  DXY Stability: SHIFTING threshold (max |Short - Stable| gap)", minval = 0, group = "DXY Purity",
     tooltip = "If the gap is above the STABLE threshold but at or below this, the instrument is labeled SHIFTING. Above this value, it's labeled UNSTABLE.")
entry_freshness_weight = input.float(0.2, "Entry Score: Freshness weight (vs Strength)", minval = 0, maxval = 1, step = 0.05, group = "Score",
     tooltip = "Entry Score = Freshness weight x Freshness + (1 - that) x Strength, added together (not multiplied). This slider sets Freshness's share; Strength gets the rest. Additive on purpose: a young, just-starting move naturally has low |FT| (Strength) since price has barely pulled away from the average yet — under the old multiplicative design, low Strength suppressed the whole score even when Freshness (momentum building) was excellent, which worked against an entry style that specifically targets fresh flips right as a move begins. Default 0.5 is a straight 50/50 split between 'how far has this stretched' and 'is momentum still building' — raise this if you find good entries are scoring too low purely because the move is still young.")
mom_extended_ft = input.float(40, "Momentum: EXTENDED |FT| threshold", minval = 0, group = "Score",
     tooltip = "The Momentum row labels an instrument EXTENDED when TF1's |FT| is at or above this AND momentum (FTΔ in the trend's direction) is currently negative — i.e. the move has already stretched far from average and is now losing steam. Not a signal on its own, just a plain read: 'this has gone a long way already and is decelerating'.")
mom_flat_band = input.float(3, "Momentum: FLAT band (|momentum| below this)", minval = 0, group = "Score",
     tooltip = "The Momentum row labels an instrument FLAT when momentum (FTΔ in the trend's direction) is within +/- this value of zero — essentially unchanged, neither building nor fading in any meaningful way.")
alarm_on = input.bool(false, "Enable scheduled alarm", group = "Alarm",
     tooltip = "Fires once, at the specific time of day below, ONLY if the chosen condition is true at that moment — meant to feed an external wake-me-up pipeline (e.g. a webhook to a push service), not to be read as a regular trading signal. Needs a chart bar that actually starts at your chosen hour:minute to fire reliably — use a 1m (or finer) chart; on a coarser timeframe the exact minute may never land on a bar open, and it may simply never fire.")
alarm_hour = input.int(8, "Hour (0-23)", minval = 0, maxval = 23, group = "Alarm")
alarm_minute = input.int(0, "Minute (0-59)", minval = 0, maxval = 59, group = "Alarm")
alarm_utc_offset = input.int(3, "UTC offset (hours)", minval = -12, maxval = 14, group = "Alarm",
     tooltip = "How many hours your local time is ahead of UTC — e.g. Moscow = 3, London = 0 (1 in summer DST), New York = -5 (-4 in summer DST). The Hour/Minute above are interpreted at this offset, not the exchange's own timezone. Whole-hour offsets only (doesn't cover half-hour zones like India or Iran).")
alarm_condition = input.string("3+ trend", "Condition", options = ["3+ trend", "1+ medalists", "3 medalists", "3 medalists, full checklist 3+ bars"], group = "Alarm",
     tooltip = "3+ trend: at least 3 configured instruments (excluding DXY) currently have an active Trend verdict (BULL/BEAR), regardless of Score or Check. 1+ medalists: at least one 🥇/🥈/🥉 exists right now. 3 medalists: all three medal slots are filled (ties can push the count above 3, still counts). 3 medalists, full checklist 3+ bars: same as '3 medalists', but each of those medalists must ALSO have held a full ✅ Check for at least 3 consecutive closed TF1 bars — a stricter, 'not just freshly qualified' version.")

alert_trend_on = input.bool(true, "Trend alert: Trend started (0 -> BULL/BEAR)", group = "Alerts")
alert_check_on = input.bool(true, "Trend alert: Check turned green (was not fully passing, now is)", group = "Alerts",
     tooltip = "Fires only on the TRANSITION from not-fully-passing (🛑 or no trend) to fully passing (✅). Does not re-fire on consecutive ✅ bars.")
alert_medal_on = input.bool(true, "Trend alert: Medalist list changed (gained/lost/reordered)", group = "Alerts",
     tooltip = "Fires once whenever the top-3 medalist list (see Final Sc's 🥇🥈🥉) changes in ANY way — checked on each instrument's own TF1 bar close, not the chart's own bar close, so it stays in sync with when the medal display itself actually updates regardless of what timeframe the chart is on. If the number of medalists changed (someone gained or lost medal status), the message describes that and does NOT also separately report a reorder that same bar. Only reports 'order changed' when the exact same set of instruments are still medalists, just ranked differently among themselves.")
alert_medal_streak2_on = input.bool(true, "Trend alert: A medalist's Check streak reached x2", group = "Alerts",
     tooltip = "Fires the moment a CURRENT medalist's Check streak (the 'xN' next to Check's ✅) reaches exactly x2 — one more closed bar of holding a full pass beyond the first. Checked on that instrument's own TF1 bar close, same clock the streak itself already uses. Does not fire again as the streak keeps growing past x2, and does not fire for an instrument that isn't currently a medalist even if its own streak reaches 2.")

bool isDxy1 = f_short_sym(sym_1) == f_short_sym(dxy_symbol)
bool isDxy2 = f_short_sym(sym_2) == f_short_sym(dxy_symbol)
bool isDxy3 = f_short_sym(sym_3) == f_short_sym(dxy_symbol)
bool isDxy4 = f_short_sym(sym_4) == f_short_sym(dxy_symbol)
bool isDxy5 = f_short_sym(sym_5) == f_short_sym(dxy_symbol)
bool isDxy6 = f_short_sym(sym_6) == f_short_sym(dxy_symbol)
bool isDxy7 = f_short_sym(sym_7) == f_short_sym(dxy_symbol)
bool isDxy8 = f_short_sym(sym_8) == f_short_sym(dxy_symbol)

bool isEur1 = f_short_sym(sym_1) == "EURUSD"
bool isEur2 = f_short_sym(sym_2) == "EURUSD"
bool isEur3 = f_short_sym(sym_3) == "EURUSD"
bool isEur4 = f_short_sym(sym_4) == "EURUSD"
bool isEur5 = f_short_sym(sym_5) == "EURUSD"
bool isEur6 = f_short_sym(sym_6) == "EURUSD"
bool isEur7 = f_short_sym(sym_7) == "EURUSD"
bool isEur8 = f_short_sym(sym_8) == "EURUSD"

f_usd_is_base(string shortSym) => str.pos(shortSym, "USD") == 0
bool usdBase1 = f_usd_is_base(f_short_sym(sym_1))
bool usdBase2 = f_usd_is_base(f_short_sym(sym_2))
bool usdBase3 = f_usd_is_base(f_short_sym(sym_3))
bool usdBase4 = f_usd_is_base(f_short_sym(sym_4))
bool usdBase5 = f_usd_is_base(f_short_sym(sym_5))
bool usdBase6 = f_usd_is_base(f_short_sym(sym_6))
bool usdBase7 = f_usd_is_base(f_short_sym(sym_7))
bool usdBase8 = f_usd_is_base(f_short_sym(sym_8))

string dxy_tf = dxy_tf_choice == "TF1" ? tf_1 : dxy_tf_choice == "TF2" ? tf_2 : tf_3
[dxy_close_ref, dxy_ret_ref] = request.security(dxy_symbol, dxy_tf,
     [close[1], (close[1] - close[2]) / close[2]], lookahead = barmerge.lookahead_off)

f_select_ret(float r1, float r2, float r3) =>
    dxy_tf_choice == "TF1" ? r1 : dxy_tf_choice == "TF2" ? r2 : r3

f_push_capped(array<float> arr, float val, int cap) =>
    if not na(val)
        array.push(arr, val)
        if array.size(arr) > cap
            array.shift(arr)

f_corr_from_arrays(array<float> a, array<float> b) =>
    float result = na
    if array.size(a) >= 2 and array.size(a) == array.size(b)
        float sda = array.stdev(a)
        float sdb = array.stdev(b)
        if sda > 0 and sdb > 0
            result := array.covariance(a, b) / (sda * sdb)
    result

bool newTfBar = dxy_close_ref != dxy_close_ref[1]

var array<float> dxyRetsArr     = array.new<float>()
var array<float> dxyRetsLongArr = array.new<float>()
var array<float> c1RetsArr   = array.new<float>()
var array<float> c2RetsArr   = array.new<float>()
var array<float> c3RetsArr   = array.new<float>()
var array<float> c4RetsArr   = array.new<float>()
var array<float> c5RetsArr   = array.new<float>()
var array<float> c6RetsArr   = array.new<float>()
var array<float> c7RetsArr   = array.new<float>()
var array<float> c8RetsArr   = array.new<float>()

var array<float> dxyRetsArrStable = array.new<float>()
var array<float> c1RetsArrStable  = array.new<float>()
var array<float> c2RetsArrStable  = array.new<float>()
var array<float> c3RetsArrStable  = array.new<float>()
var array<float> c4RetsArrStable  = array.new<float>()
var array<float> c5RetsArrStable  = array.new<float>()
var array<float> c6RetsArrStable  = array.new<float>()
var array<float> c7RetsArrStable  = array.new<float>()
var array<float> c8RetsArrStable  = array.new<float>()

if newTfBar
    f_push_capped(dxyRetsArr, dxy_ret_ref, dxy_len)
    f_push_capped(dxyRetsLongArr, dxy_ret_ref, dxy_len * 5)
    f_push_capped(c1RetsArr, f_select_ret(r1_1, r1_2, r1_3), dxy_len)
    f_push_capped(c2RetsArr, f_select_ret(r2_1, r2_2, r2_3), dxy_len)
    f_push_capped(c3RetsArr, f_select_ret(r3_1, r3_2, r3_3), dxy_len)
    f_push_capped(c4RetsArr, f_select_ret(r4_1, r4_2, r4_3), dxy_len)
    f_push_capped(c5RetsArr, f_select_ret(r5_1, r5_2, r5_3), dxy_len)
    f_push_capped(c6RetsArr, f_select_ret(r6_1, r6_2, r6_3), dxy_len)
    f_push_capped(c7RetsArr, f_select_ret(r7_1, r7_2, r7_3), dxy_len)
    f_push_capped(c8RetsArr, f_select_ret(r8_1, r8_2, r8_3), dxy_len)
    f_push_capped(dxyRetsArrStable, dxy_ret_ref, dxy_len_stable)
    f_push_capped(c1RetsArrStable, f_select_ret(r1_1, r1_2, r1_3), dxy_len_stable)
    f_push_capped(c2RetsArrStable, f_select_ret(r2_1, r2_2, r2_3), dxy_len_stable)
    f_push_capped(c3RetsArrStable, f_select_ret(r3_1, r3_2, r3_3), dxy_len_stable)
    f_push_capped(c4RetsArrStable, f_select_ret(r4_1, r4_2, r4_3), dxy_len_stable)
    f_push_capped(c5RetsArrStable, f_select_ret(r5_1, r5_2, r5_3), dxy_len_stable)
    f_push_capped(c6RetsArrStable, f_select_ret(r6_1, r6_2, r6_3), dxy_len_stable)
    f_push_capped(c7RetsArrStable, f_select_ret(r7_1, r7_2, r7_3), dxy_len_stable)
    f_push_capped(c8RetsArrStable, f_select_ret(r8_1, r8_2, r8_3), dxy_len_stable)

f_purity(array<float> instRetsArr) =>
    float corr = f_corr_from_arrays(instRetsArr, dxyRetsArr)
    na(corr) ? na : math.abs(corr) * 100

f_purity_stable(array<float> instRetsArrStable) =>
    float corr = f_corr_from_arrays(instRetsArrStable, dxyRetsArrStable)
    na(corr) ? na : math.abs(corr) * 100

float dxy_std_now = array.size(dxyRetsArr) >= 2 ? array.stdev(dxyRetsArr) : na
float dxy_std_ref = array.size(dxyRetsLongArr) >= 2 ? array.stdev(dxyRetsLongArr) : na
bool  dxy_too_quiet_raw = not na(dxy_std_ref) and dxy_std_ref > 0 and not na(dxy_std_now) and dxy_std_now < dxy_std_ref * 0.5

var bool dxy_too_quiet   = false
var int  dxy_quiet_count  = 0
var int  dxy_active_count = 0
if dxy_too_quiet_raw
    dxy_quiet_count  := dxy_quiet_count + 1
    dxy_active_count := 0
else
    dxy_active_count := dxy_active_count + 1
    dxy_quiet_count  := 0
if dxy_quiet_count >= beta_quiet_enter_bars
    dxy_too_quiet := true
if dxy_active_count >= beta_quiet_exit_bars
    dxy_too_quiet := false

f_beta(array<float> instRetsArr) =>
    float result = na
    if not dxy_too_quiet and not na(dxy_std_now) and dxy_std_now > 0
        float corr    = f_corr_from_arrays(instRetsArr, dxyRetsArr)
        float instStd = array.size(instRetsArr) >= 2 ? array.stdev(instRetsArr) : na
        result := na(corr) or na(instStd) ? na : math.abs(corr) * (instStd / dxy_std_now)
    result

purity_1 = isDxy1 ? na : f_purity(c1RetsArr)
purity_2 = isDxy2 ? na : f_purity(c2RetsArr)
purity_3 = isDxy3 ? na : f_purity(c3RetsArr)
purity_4 = isDxy4 ? na : f_purity(c4RetsArr)
purity_5 = isDxy5 ? na : f_purity(c5RetsArr)
purity_6 = isDxy6 ? na : f_purity(c6RetsArr)
purity_7 = isDxy7 ? na : f_purity(c7RetsArr)
purity_8 = isDxy8 ? na : f_purity(c8RetsArr)

purityStable_1 = isDxy1 ? na : f_purity_stable(c1RetsArrStable)
purityStable_2 = isDxy2 ? na : f_purity_stable(c2RetsArrStable)
purityStable_3 = isDxy3 ? na : f_purity_stable(c3RetsArrStable)
purityStable_4 = isDxy4 ? na : f_purity_stable(c4RetsArrStable)
purityStable_5 = isDxy5 ? na : f_purity_stable(c5RetsArrStable)
purityStable_6 = isDxy6 ? na : f_purity_stable(c6RetsArrStable)
purityStable_7 = isDxy7 ? na : f_purity_stable(c7RetsArrStable)
purityStable_8 = isDxy8 ? na : f_purity_stable(c8RetsArrStable)

f_stability_text(float short_, float stable_) =>
    string result = "—"
    if not na(short_) and not na(stable_)
        float diff = math.abs(short_ - stable_)
        result := diff <= dxy_stable_thresh ? "STABLE" : diff <= dxy_shifting_thresh ? "SHIFTING" : "UNSTABLE"
    result

f_stability_bg(float short_, float stable_) =>
    color result = f_tint(color.new(#F7F8FA, 0), color.new(#12151A, 0))
    if not na(short_) and not na(stable_)
        float diff = math.abs(short_ - stable_)
        result := diff <= dxy_stable_thresh ? f_tint(#DCEEE0, #1B3A2E) : diff <= dxy_shifting_thresh ? f_tint(#F5E9C8, #3A331B) : f_tint(#F6DEDE, #3A1B1F)
    result

beta_1 = isDxy1 ? na : f_beta(c1RetsArr)
beta_2 = isDxy2 ? na : f_beta(c2RetsArr)
beta_3 = isDxy3 ? na : f_beta(c3RetsArr)
beta_4 = isDxy4 ? na : f_beta(c4RetsArr)
beta_5 = isDxy5 ? na : f_beta(c5RetsArr)
beta_6 = isDxy6 ? na : f_beta(c6RetsArr)
beta_7 = isDxy7 ? na : f_beta(c7RetsArr)
beta_8 = isDxy8 ? na : f_beta(c8RetsArr)

f_purity_bg(float p) =>
    color lo = f_tint(#E7EEF5, #16232E)
    color hi = f_tint(#2B5A82, #4FA8E8)
    na(p) ? f_tint(color.new(#F7F8FA, 0), color.new(#12151A, 0)) : color.from_gradient(p, 0, 100, lo, hi)

f_purity_text_color(float p) =>
    theme_dark ? color.new(#C7CBD1, 0) : (na(p) ? color.black : (p > 55 ? color.white : color.black))

f_purity_text(float p) =>
    na(p) ? "—" : str.tostring(math.round(p)) + "%"

f_beta_bg(float b) =>
    color lo = f_tint(#E3F1EE, #16302A)
    color hi = f_tint(#1F5C52, #3ECFAE)
    na(b) ? f_tint(color.new(#F7F8FA, 0), color.new(#12151A, 0)) : color.from_gradient(math.min(b, 2.0), 0, 2.0, lo, hi)

f_beta_text_color(float b) =>
    theme_dark ? color.new(#C7CBD1, 0) : (na(b) ? color.black : (b > 1.1 ? color.white : color.black))

f_beta_text(float b) =>
    na(b) ? "—" : str.tostring(math.round(b, 2)) + "x"

f_trend_verdict(float v1, float v2, float v3) =>
    bool t1in = tf_1_enable and tf_1_trend
    bool t2in = tf_2_enable and tf_2_trend
    bool t3in = tf_3_enable and tf_3_trend
    bool anyIn = t1in or t2in or t3in
    bool bull1 = not t1in or v1 > 0
    bool bull2 = not t2in or v2 > 0
    bool bull3 = not t3in or v3 > 0
    bool bear1 = not t1in or v1 < 0
    bool bear2 = not t2in or v2 < 0
    bool bear3 = not t3in or v3 < 0
    bool allBull = anyIn and bull1 and bull2 and bull3
    bool allBear = anyIn and bear1 and bear2 and bear3
    allBull ? 1 : allBear ? -1 : 0

int verdict_1 = f_trend_verdict(w1_1, w1_2, w1_3)
int verdict_2 = f_trend_verdict(w2_1, w2_2, w2_3)
int verdict_3 = f_trend_verdict(w3_1, w3_2, w3_3)
int verdict_4 = f_trend_verdict(w4_1, w4_2, w4_3)
int verdict_5 = f_trend_verdict(w5_1, w5_2, w5_3)
int verdict_6 = f_trend_verdict(w6_1, w6_2, w6_3)
int verdict_7 = f_trend_verdict(w7_1, w7_2, w7_3)
int verdict_8 = f_trend_verdict(w8_1, w8_2, w8_3)

bool newTf1Bar1 = c1_1 != c1_1[1]
bool newTf1Bar2 = c2_1 != c2_1[1]
bool newTf1Bar3 = c3_1 != c3_1[1]
bool newTf1Bar4 = c4_1 != c4_1[1]
bool newTf1Bar5 = c5_1 != c5_1[1]
bool newTf1Bar6 = c6_1 != c6_1[1]
bool newTf1Bar7 = c7_1 != c7_1[1]
bool newTf1Bar8 = c8_1 != c8_1[1]

f_fresh_raw(int verdict, float ftd) =>
    verdict == 1 ? ftd : (verdict == -1 ? -ftd : na)

float freshRaw1 = f_fresh_raw(verdict_1, ftd_1)
float freshRaw2 = f_fresh_raw(verdict_2, ftd_2)
float freshRaw3 = f_fresh_raw(verdict_3, ftd_3)
float freshRaw4 = f_fresh_raw(verdict_4, ftd_4)
float freshRaw5 = f_fresh_raw(verdict_5, ftd_5)
float freshRaw6 = f_fresh_raw(verdict_6, ftd_6)
float freshRaw7 = f_fresh_raw(verdict_7, ftd_7)
float freshRaw8 = f_fresh_raw(verdict_8, ftd_8)

var array<float> freshHist1 = array.new<float>()
var array<float> freshHist2 = array.new<float>()
var array<float> freshHist3 = array.new<float>()
var array<float> freshHist4 = array.new<float>()
var array<float> freshHist5 = array.new<float>()
var array<float> freshHist6 = array.new<float>()
var array<float> freshHist7 = array.new<float>()
var array<float> freshHist8 = array.new<float>()

f_had_recent_dip(array<float> hist) =>
    bool result = false
    if array.size(hist) > 0
        float lastVal = array.get(hist, array.size(hist) - 1)
        result := array.min(hist) <= 0 and lastVal > 0
    result

bool hadDip1 = f_had_recent_dip(freshHist1)
bool hadDip2 = f_had_recent_dip(freshHist2)
bool hadDip3 = f_had_recent_dip(freshHist3)
bool hadDip4 = f_had_recent_dip(freshHist4)
bool hadDip5 = f_had_recent_dip(freshHist5)
bool hadDip6 = f_had_recent_dip(freshHist6)
bool hadDip7 = f_had_recent_dip(freshHist7)
bool hadDip8 = f_had_recent_dip(freshHist8)

if newTf1Bar1
    f_push_capped(freshHist1, freshRaw1, score_reset_lookback)
if newTf1Bar2
    f_push_capped(freshHist2, freshRaw2, score_reset_lookback)
if newTf1Bar3
    f_push_capped(freshHist3, freshRaw3, score_reset_lookback)
if newTf1Bar4
    f_push_capped(freshHist4, freshRaw4, score_reset_lookback)
if newTf1Bar5
    f_push_capped(freshHist5, freshRaw5, score_reset_lookback)
if newTf1Bar6
    f_push_capped(freshHist6, freshRaw6, score_reset_lookback)
if newTf1Bar7
    f_push_capped(freshHist7, freshRaw7, score_reset_lookback)
if newTf1Bar8
    f_push_capped(freshHist8, freshRaw8, score_reset_lookback)

f_momentum_state(bool isDxy, int verdict, float freshRaw, float ftTf1, bool hadRecentDip) =>
    string result = "—"
    if not isDxy and verdict != 0 and not na(freshRaw)
        if math.abs(ftTf1) >= mom_extended_ft and freshRaw < 0
            result := "EXTENDED"
        else if hadRecentDip and freshRaw > 0
            result := "RE-ACCEL ↑↑"
        else if math.abs(freshRaw) < mom_flat_band
            result := "FLAT →"
        else if freshRaw > 0
            result := "BUILDING ↑"
        else
            result := "FADING ↓"
    result

f_momentum_bg(string state) =>
    color result = f_tint(color.new(#F7F8FA, 0), color.new(#12151A, 0))
    if state == "BUILDING ↑" or state == "RE-ACCEL ↑↑"
        result := f_tint(#DCEEE0, #1B3A2E)
    else if state == "FADING ↓" or state == "EXTENDED"
        result := f_tint(#F6DEDE, #3A1B1F)
    else if state == "FLAT →"
        result := f_tint(color.new(color.gray, 15), color.new(#252A31, 0))
    result

momentum1 = f_momentum_state(isDxy1, verdict_1, freshRaw1, w1_1, hadDip1)
momentum2 = f_momentum_state(isDxy2, verdict_2, freshRaw2, w2_1, hadDip2)
momentum3 = f_momentum_state(isDxy3, verdict_3, freshRaw3, w3_1, hadDip3)
momentum4 = f_momentum_state(isDxy4, verdict_4, freshRaw4, w4_1, hadDip4)
momentum5 = f_momentum_state(isDxy5, verdict_5, freshRaw5, w5_1, hadDip5)
momentum6 = f_momentum_state(isDxy6, verdict_6, freshRaw6, w6_1, hadDip6)
momentum7 = f_momentum_state(isDxy7, verdict_7, freshRaw7, w7_1, hadDip7)
momentum8 = f_momentum_state(isDxy8, verdict_8, freshRaw8, w8_1, hadDip8)

bool visible1 = sym_1_enable and (not hide_notrend_on or verdict_1 != 0 or isDxy1) and not (summary_on and isDxy1)
bool visible2 = sym_2_enable and (not hide_notrend_on or verdict_2 != 0 or isDxy2) and not (summary_on and isDxy2)
bool visible3 = sym_3_enable and (not hide_notrend_on or verdict_3 != 0 or isDxy3) and not (summary_on and isDxy3)
bool visible4 = sym_4_enable and (not hide_notrend_on or verdict_4 != 0 or isDxy4) and not (summary_on and isDxy4)
bool visible5 = sym_5_enable and (not hide_notrend_on or verdict_5 != 0 or isDxy5) and not (summary_on and isDxy5)
bool visible6 = sym_6_enable and (not hide_notrend_on or verdict_6 != 0 or isDxy6) and not (summary_on and isDxy6)
bool visible7 = sym_7_enable and (not hide_notrend_on or verdict_7 != 0 or isDxy7) and not (summary_on and isDxy7)
bool visible8 = sym_8_enable and (not hide_notrend_on or verdict_8 != 0 or isDxy8) and not (summary_on and isDxy8)

f_trend_alert(bool enabled, int verdict, string symName) =>
    if enabled and barstate.isconfirmed and verdict[1] == 0 and verdict != 0
        string dir = verdict == 1 ? "BULL" : "BEAR"
        alert(symName + ": trend started (" + dir + ")", alert.freq_once_per_bar_close)

f_trend_alert(sym_1_enable and alert_trend_on, verdict_1, f_short_sym(sym_1))
f_trend_alert(sym_2_enable and alert_trend_on, verdict_2, f_short_sym(sym_2))
f_trend_alert(sym_3_enable and alert_trend_on, verdict_3, f_short_sym(sym_3))
f_trend_alert(sym_4_enable and alert_trend_on, verdict_4, f_short_sym(sym_4))
f_trend_alert(sym_5_enable and alert_trend_on, verdict_5, f_short_sym(sym_5))
f_trend_alert(sym_6_enable and alert_trend_on, verdict_6, f_short_sym(sym_6))
f_trend_alert(sym_7_enable and alert_trend_on, verdict_7, f_short_sym(sym_7))
f_trend_alert(sym_8_enable and alert_trend_on, verdict_8, f_short_sym(sym_8))

f_tf_label(string tf, bool confirm) =>
    string base = tf == "1"   ? "1m"  :
                   tf == "3"   ? "3m"  :
                   tf == "5"   ? "5m"  :
                   tf == "15"  ? "15m" :
                   tf == "30"  ? "30m" :
                   tf == "45"  ? "45m" :
                   tf == "60"  ? "1h"  :
                   tf == "120" ? "2h"  :
                   tf == "180" ? "3h"  :
                   tf == "240" ? "4h"  :
                   tf == "360" ? "6h"  :
                   tf == "480" ? "8h"  :
                   tf == "720" ? "12h" :
                   tf == "D"   ? "1D"  :
                   tf == "W"   ? "1W"  :
                   tf == "M"   ? "1M"  :
                   tf
    confirm ? base + " (C)" : base

f_ft_text(float ft) =>
    na(ft) ? "—" : str.tostring(math.round(ft, 1))

f_ft_text_flagged(float ft, bool flag) =>
    na(ft) ? "—" : (flag ? "[" + str.tostring(math.round(ft, 1)) + "]" : str.tostring(math.round(ft, 1)))

f_row_extreme(float v1, float v2, float v3, float v4, float v5, float v6, float v7, float v8,
     bool e1, bool e2, bool e3, bool e4, bool e5, bool e6, bool e7, bool e8) =>
    var float[] arr = array.new<float>()
    array.clear(arr)
    if e1 and not na(v1)
        array.push(arr, v1)
    if e2 and not na(v2)
        array.push(arr, v2)
    if e3 and not na(v3)
        array.push(arr, v3)
    if e4 and not na(v4)
        array.push(arr, v4)
    if e5 and not na(v5)
        array.push(arr, v5)
    if e6 and not na(v6)
        array.push(arr, v6)
    if e7 and not na(v7)
        array.push(arr, v7)
    if e8 and not na(v8)
        array.push(arr, v8)
    float mx = array.size(arr) > 1 ? array.max(arr) : na
    float mn = array.size(arr) > 1 ? array.min(arr) : na
    [mx, mn]

f_ft_bg2(float ft, float rowMax, float rowMin) =>
    color result = na
    if ft >= 0
        float ref   = not na(rowMax) and rowMax > 0 ? rowMax : 60
        float ratio = math.min(math.abs(ft) / ref, 1)
        result := f_tier3_bg(ratio, #EDF5EF, #B9DDC5, #6FA287, #16261C, #234A34, #3ECF8E)
    else
        float ref   = not na(rowMin) and rowMin < 0 ? math.abs(rowMin) : 60
        float ratio = math.min(math.abs(ft) / ref, 1)
        result := f_tier3_bg(ratio, #F5EDED, #DDB9B9, #C97B7B, #2A1616, #4A2323, #EF5350)
    result

f_ft_text_color(float ft, float rowMax, float rowMin) =>
    color result = color.black
    if theme_dark
        result := color.new(#C7CBD1, 0)
    else if ft >= 0
        float ref   = not na(rowMax) and rowMax > 0 ? rowMax : 60
        float ratio = math.min(math.abs(ft) / ref, 1)
        result := ratio >= 0.67 ? color.white : color.black
    else
        float ref   = not na(rowMin) and rowMin < 0 ? math.abs(rowMin) : 60
        float ratio = math.min(math.abs(ft) / ref, 1)
        result := ratio >= 0.67 ? color.white : color.black
    result

f_verdict_text(int v) =>
    v == 1 ? "BULL" : v == -1 ? "BEAR" : "—"

f_verdict_bg(int v) =>
    v == 1 ? f_tint(#6FA287, #1B4A32) : v == -1 ? f_tint(#C97B7B, #5C2323) : f_tint(color.new(#F7F8FA, 0), color.new(#12151A, 0))

white = f_tint(color.new(#F7F8FA, 0), color.new(#12151A, 0))
black = theme_dark ? color.new(#C7CBD1, 0) : color.new(#30343A, 0)
gray  = f_tint(color.new(color.gray, 15), color.new(#252A31, 0))
labelBg   = f_tint(color.new(#ECEEF1, 0), color.new(#12151A, 0))
labelText = theme_dark ? color.new(#C7CBD1, 0) : color.new(#6B7078, 0)

bool isCur1 = f_short_sym(sym_1) == syminfo.ticker
bool isCur2 = f_short_sym(sym_2) == syminfo.ticker
bool isCur3 = f_short_sym(sym_3) == syminfo.ticker
bool isCur4 = f_short_sym(sym_4) == syminfo.ticker
bool isCur5 = f_short_sym(sym_5) == syminfo.ticker
bool isCur6 = f_short_sym(sym_6) == syminfo.ticker
bool isCur7 = f_short_sym(sym_7) == syminfo.ticker
bool isCur8 = f_short_sym(sym_8) == syminfo.ticker

[max1, min1] = f_row_extreme(w1_1, w2_1, w3_1, w4_1, w5_1, w6_1, w7_1, w8_1,
     visible1, visible2, visible3, visible4, visible5, visible6, visible7, visible8)
[max2, min2] = f_row_extreme(w1_2, w2_2, w3_2, w4_2, w5_2, w6_2, w7_2, w8_2,
     visible1, visible2, visible3, visible4, visible5, visible6, visible7, visible8)
[max3, min3] = f_row_extreme(w1_3, w2_3, w3_3, w4_3, w5_3, w6_3, w7_3, w8_3,
     visible1, visible2, visible3, visible4, visible5, visible6, visible7, visible8)

f_trend_score(int verdict, float ftTf2, float rowMax2, float rowMin2, float purity) =>
    float result = na
    if verdict != 0
        float absStrength = math.min(math.abs(ftTf2) / 60, 1)
        float relStrength = verdict == 1 ?
             (not na(rowMax2) and rowMax2 > 0 ? math.min(ftTf2 / rowMax2, 1) : absStrength) :
             (not na(rowMin2) and rowMin2 < 0 ? math.min(math.abs(ftTf2) / math.abs(rowMin2), 1) : absStrength)
        float tf2Strength = (score_abs_weight * absStrength + (1 - score_abs_weight) * relStrength) * 100
        float wPurity      = na(purity) ? 0.0 : trend_purity_weight
        float wStrength    = 1.0 - wPurity
        result := wStrength * tf2Strength + (na(purity) ? 0.0 : wPurity * purity)
    result

f_entry_score(int verdict, float ftTf1, float rowMax, float rowMin, float ftd, bool hadRecentDip) =>
    float result = na
    if verdict != 0
        float absStrength = math.min(math.abs(ftTf1) / 60, 1)
        float relStrength = verdict == 1 ?
             (not na(rowMax) and rowMax > 0 ? math.min(ftTf1 / rowMax, 1) : absStrength) :
             (not na(rowMin) and rowMin < 0 ? math.min(math.abs(ftTf1) / math.abs(rowMin), 1) : absStrength)
        float strength    = score_abs_weight * absStrength + (1 - score_abs_weight) * relStrength
        float freshRaw    = verdict == 1 ? ftd : -ftd
        float freshRatio  = na(freshRaw) ? 0.5 : math.max(0, math.min((freshRaw + 20) / 40, 1))
        if hadRecentDip and not na(freshRaw) and freshRaw > 0
            freshRatio := math.min(freshRatio + score_reset_bonus, 1)
        result := (entry_freshness_weight * freshRatio + (1 - entry_freshness_weight) * strength) * 100
    result

trendScore_1 = isDxy1 ? na : f_trend_score(verdict_1, w1_2, max2, min2, purity_1)
trendScore_2 = isDxy2 ? na : f_trend_score(verdict_2, w2_2, max2, min2, purity_2)
trendScore_3 = isDxy3 ? na : f_trend_score(verdict_3, w3_2, max2, min2, purity_3)
trendScore_4 = isDxy4 ? na : f_trend_score(verdict_4, w4_2, max2, min2, purity_4)
trendScore_5 = isDxy5 ? na : f_trend_score(verdict_5, w5_2, max2, min2, purity_5)
trendScore_6 = isDxy6 ? na : f_trend_score(verdict_6, w6_2, max2, min2, purity_6)
trendScore_7 = isDxy7 ? na : f_trend_score(verdict_7, w7_2, max2, min2, purity_7)
trendScore_8 = isDxy8 ? na : f_trend_score(verdict_8, w8_2, max2, min2, purity_8)

entryScore_1 = isDxy1 ? na : f_entry_score(verdict_1, w1_1, max1, min1, ftd_1, hadDip1)
entryScore_2 = isDxy2 ? na : f_entry_score(verdict_2, w2_1, max1, min1, ftd_2, hadDip2)
entryScore_3 = isDxy3 ? na : f_entry_score(verdict_3, w3_1, max1, min1, ftd_3, hadDip3)
entryScore_4 = isDxy4 ? na : f_entry_score(verdict_4, w4_1, max1, min1, ftd_4, hadDip4)
entryScore_5 = isDxy5 ? na : f_entry_score(verdict_5, w5_1, max1, min1, ftd_5, hadDip5)
entryScore_6 = isDxy6 ? na : f_entry_score(verdict_6, w6_1, max1, min1, ftd_6, hadDip6)
entryScore_7 = isDxy7 ? na : f_entry_score(verdict_7, w7_1, max1, min1, ftd_7, hadDip7)
entryScore_8 = isDxy8 ? na : f_entry_score(verdict_8, w8_1, max1, min1, ftd_8, hadDip8)

f_final_score(float trendScore, float entryScore) =>
    na(trendScore) or na(entryScore) ? na : math.sqrt(trendScore * entryScore)

finalScore_1 = f_final_score(trendScore_1, entryScore_1)
finalScore_2 = f_final_score(trendScore_2, entryScore_2)
finalScore_3 = f_final_score(trendScore_3, entryScore_3)
finalScore_4 = f_final_score(trendScore_4, entryScore_4)
finalScore_5 = f_final_score(trendScore_5, entryScore_5)
finalScore_6 = f_final_score(trendScore_6, entryScore_6)
finalScore_7 = f_final_score(trendScore_7, entryScore_7)
finalScore_8 = f_final_score(trendScore_8, entryScore_8)

f_pick8(bool is1, bool is2, bool is3, bool is4, bool is5, bool is6, bool is7, bool is8,
     float v1, float v2, float v3, float v4, float v5, float v6, float v7, float v8) =>
    is1 ? v1 : is2 ? v2 : is3 ? v3 : is4 ? v4 : is5 ? v5 : is6 ? v6 : is7 ? v7 : is8 ? v8 : na

f_pick8_bool(bool is1, bool is2, bool is3, bool is4, bool is5, bool is6, bool is7, bool is8,
     bool v1, bool v2, bool v3, bool v4, bool v5, bool v6, bool v7, bool v8) =>
    is1 ? v1 : is2 ? v2 : is3 ? v3 : is4 ? v4 : is5 ? v5 : is6 ? v6 : is7 ? v7 : is8 ? v8 : false

dxySlot_1h  = f_pick8(isDxy1, isDxy2, isDxy3, isDxy4, isDxy5, isDxy6, isDxy7, isDxy8,
     w1_2c, w2_2c, w3_2c, w4_2c, w5_2c, w6_2c, w7_2c, w8_2c)
dxySlot_4h  = f_pick8(isDxy1, isDxy2, isDxy3, isDxy4, isDxy5, isDxy6, isDxy7, isDxy8,
     w1_3c, w2_3c, w3_3c, w4_3c, w5_3c, w6_3c, w7_3c, w8_3c)
dxySlot_15m = f_pick8(isDxy1, isDxy2, isDxy3, isDxy4, isDxy5, isDxy6, isDxy7, isDxy8,
     w1_1, w2_1, w3_1, w4_1, w5_1, w6_1, w7_1, w8_1)
dxySlot_wtd = f_pick8(isDxy1, isDxy2, isDxy3, isDxy4, isDxy5, isDxy6, isDxy7, isDxy8,
     ftd_1, ftd_2, ftd_3, ftd_4, ftd_5, ftd_6, ftd_7, ftd_8)
dxySlot_f2 = f_pick8_bool(isDxy1, isDxy2, isDxy3, isDxy4, isDxy5, isDxy6, isDxy7, isDxy8,
     f1_2, f2_2, f3_2, f4_2, f5_2, f6_2, f7_2, f8_2)
dxySlot_f3 = f_pick8_bool(isDxy1, isDxy2, isDxy3, isDxy4, isDxy5, isDxy6, isDxy7, isDxy8,
     f1_3, f2_3, f3_3, f4_3, f5_3, f6_3, f7_3, f8_3)

eurSlot_1h  = f_pick8(isEur1, isEur2, isEur3, isEur4, isEur5, isEur6, isEur7, isEur8,
     w1_2c, w2_2c, w3_2c, w4_2c, w5_2c, w6_2c, w7_2c, w8_2c)
eurSlot_4h  = f_pick8(isEur1, isEur2, isEur3, isEur4, isEur5, isEur6, isEur7, isEur8,
     w1_3c, w2_3c, w3_3c, w4_3c, w5_3c, w6_3c, w7_3c, w8_3c)

bool chk1_pass = not na(dxySlot_1h) and not na(dxySlot_4h) and math.sign(dxySlot_1h) == math.sign(dxySlot_4h)
bool chk2_pass = not na(eurSlot_1h) and not na(eurSlot_4h) and math.sign(eurSlot_1h) == math.sign(eurSlot_4h)

bool chk3_pass = not (tf_2_enable and dxySlot_f2) and not (tf_3_enable and dxySlot_f3)

f_check4_pass(int verdict, bool usdIsBase) =>
    bool result = true
    if verdict != 0
        int expectedDxySign = usdIsBase ? verdict : -verdict
        bool dxyStrong    = not na(dxySlot_15m) and math.abs(dxySlot_15m) > chk4_min_abs and math.sign(dxySlot_15m) == -expectedDxySign
        bool dxyBuilding  = na(dxySlot_wtd) or math.sign(dxySlot_wtd) == math.sign(dxySlot_15m)
        result := not (dxyStrong and dxyBuilding)
    result

f_check5_pass(int verdict, float trendScore) =>
    verdict != 0 and not na(trendScore) and trendScore > chk5_min_trend

f_check6_pass(int verdict, float entryScore) =>
    verdict != 0 and not na(entryScore) and entryScore > chk6_min_entry

f_check7_pass(bool f1, bool f2, bool f3) =>
    bool bad1 = tf_1_enable and tf_1_trend and f1
    bool bad2 = tf_2_enable and tf_2_trend and f2
    bool bad3 = tf_3_enable and tf_3_trend and f3
    not (bad1 or bad2 or bad3)

f_check8_pass(float beta) =>
    na(beta) or beta < chk8_max_beta

f_check9_pass(float w1, float w2, float w3) =>
    bool bad1 = tf_1_enable and tf_1_trend and not na(w1) and math.abs(w1) <= chk9_min_abs
    bool bad2 = tf_2_enable and tf_2_trend and not na(w2) and math.abs(w2) <= chk9_min_abs
    bool bad3 = tf_3_enable and tf_3_trend and not na(w3) and math.abs(w3) <= chk9_min_abs
    not (bad1 or bad2 or bad3)

f_checklist_tally(bool c1pass, bool c2pass, bool c3pass, bool c4pass, bool c5pass, bool c6pass, bool c7pass, bool c8pass, bool c9pass) =>
    int total  = (chk1_on ? 1 : 0) + (chk2_on ? 1 : 0) + (chk3_on ? 1 : 0) + (chk4_on ? 1 : 0) + (chk5_on ? 1 : 0) + (chk6_on ? 1 : 0) + (chk7_on ? 1 : 0) + (chk8_on ? 1 : 0) + (chk9_on ? 1 : 0)
    int passed = (chk1_on and c1pass ? 1 : 0) + (chk2_on and c2pass ? 1 : 0) + (chk3_on and c3pass ? 1 : 0) + (chk4_on and c4pass ? 1 : 0) + (chk5_on and c5pass ? 1 : 0) + (chk6_on and c6pass ? 1 : 0) + (chk7_on and c7pass ? 1 : 0) + (chk8_on and c8pass ? 1 : 0) + (chk9_on and c9pass ? 1 : 0)
    [passed, total]

[check_p1, check_t1] = f_checklist_tally(chk1_pass, chk2_pass, chk3_pass, f_check4_pass(verdict_1, usdBase1), f_check5_pass(verdict_1, trendScore_1), f_check6_pass(verdict_1, entryScore_1), f_check7_pass(f1_1, f1_2, f1_3), f_check8_pass(beta_1), f_check9_pass(w1_1, w1_2, w1_3))
[check_p2, check_t2] = f_checklist_tally(chk1_pass, chk2_pass, chk3_pass, f_check4_pass(verdict_2, usdBase2), f_check5_pass(verdict_2, trendScore_2), f_check6_pass(verdict_2, entryScore_2), f_check7_pass(f2_1, f2_2, f2_3), f_check8_pass(beta_2), f_check9_pass(w2_1, w2_2, w2_3))
[check_p3, check_t3] = f_checklist_tally(chk1_pass, chk2_pass, chk3_pass, f_check4_pass(verdict_3, usdBase3), f_check5_pass(verdict_3, trendScore_3), f_check6_pass(verdict_3, entryScore_3), f_check7_pass(f3_1, f3_2, f3_3), f_check8_pass(beta_3), f_check9_pass(w3_1, w3_2, w3_3))
[check_p4, check_t4] = f_checklist_tally(chk1_pass, chk2_pass, chk3_pass, f_check4_pass(verdict_4, usdBase4), f_check5_pass(verdict_4, trendScore_4), f_check6_pass(verdict_4, entryScore_4), f_check7_pass(f4_1, f4_2, f4_3), f_check8_pass(beta_4), f_check9_pass(w4_1, w4_2, w4_3))
[check_p5, check_t5] = f_checklist_tally(chk1_pass, chk2_pass, chk3_pass, f_check4_pass(verdict_5, usdBase5), f_check5_pass(verdict_5, trendScore_5), f_check6_pass(verdict_5, entryScore_5), f_check7_pass(f5_1, f5_2, f5_3), f_check8_pass(beta_5), f_check9_pass(w5_1, w5_2, w5_3))
[check_p6, check_t6] = f_checklist_tally(chk1_pass, chk2_pass, chk3_pass, f_check4_pass(verdict_6, usdBase6), f_check5_pass(verdict_6, trendScore_6), f_check6_pass(verdict_6, entryScore_6), f_check7_pass(f6_1, f6_2, f6_3), f_check8_pass(beta_6), f_check9_pass(w6_1, w6_2, w6_3))
[check_p7, check_t7] = f_checklist_tally(chk1_pass, chk2_pass, chk3_pass, f_check4_pass(verdict_7, usdBase7), f_check5_pass(verdict_7, trendScore_7), f_check6_pass(verdict_7, entryScore_7), f_check7_pass(f7_1, f7_2, f7_3), f_check8_pass(beta_7), f_check9_pass(w7_1, w7_2, w7_3))
[check_p8, check_t8] = f_checklist_tally(chk1_pass, chk2_pass, chk3_pass, f_check4_pass(verdict_8, usdBase8), f_check5_pass(verdict_8, trendScore_8), f_check6_pass(verdict_8, entryScore_8), f_check7_pass(f8_1, f8_2, f8_3), f_check8_pass(beta_8), f_check9_pass(w8_1, w8_2, w8_3))

f_qualifies(int verdict, bool isDxy, int passed, int total) =>
    verdict != 0 and not isDxy and total > 0 and passed == total

bool qualifiesLive1 = f_qualifies(verdict_1, isDxy1, check_p1, check_t1)
bool qualifiesLive2 = f_qualifies(verdict_2, isDxy2, check_p2, check_t2)
bool qualifiesLive3 = f_qualifies(verdict_3, isDxy3, check_p3, check_t3)
bool qualifiesLive4 = f_qualifies(verdict_4, isDxy4, check_p4, check_t4)
bool qualifiesLive5 = f_qualifies(verdict_5, isDxy5, check_p5, check_t5)
bool qualifiesLive6 = f_qualifies(verdict_6, isDxy6, check_p6, check_t6)
bool qualifiesLive7 = f_qualifies(verdict_7, isDxy7, check_p7, check_t7)
bool qualifiesLive8 = f_qualifies(verdict_8, isDxy8, check_p8, check_t8)

var bool qualifies1 = false
var bool qualifies2 = false
var bool qualifies3 = false
var bool qualifies4 = false
var bool qualifies5 = false
var bool qualifies6 = false
var bool qualifies7 = false
var bool qualifies8 = false

if newTf1Bar1
    qualifies1 := qualifiesLive1
if newTf1Bar2
    qualifies2 := qualifiesLive2
if newTf1Bar3
    qualifies3 := qualifiesLive3
if newTf1Bar4
    qualifies4 := qualifiesLive4
if newTf1Bar5
    qualifies5 := qualifiesLive5
if newTf1Bar6
    qualifies6 := qualifiesLive6
if newTf1Bar7
    qualifies7 := qualifiesLive7
if newTf1Bar8
    qualifies8 := qualifiesLive8

f_top3_thresholds(float v1, float v2, float v3, float v4, float v5, float v6, float v7, float v8,
     bool e1, bool e2, bool e3, bool e4, bool e5, bool e6, bool e7, bool e8) =>
    array<float> arr = array.new<float>()
    if e1 and not na(v1)
        array.push(arr, v1)
    if e2 and not na(v2)
        array.push(arr, v2)
    if e3 and not na(v3)
        array.push(arr, v3)
    if e4 and not na(v4)
        array.push(arr, v4)
    if e5 and not na(v5)
        array.push(arr, v5)
    if e6 and not na(v6)
        array.push(arr, v6)
    if e7 and not na(v7)
        array.push(arr, v7)
    if e8 and not na(v8)
        array.push(arr, v8)
    array.sort(arr, order.descending)
    float t1 = array.size(arr) > 0 ? array.get(arr, 0) : na
    float t2 = array.size(arr) > 1 ? array.get(arr, 1) : na
    float t3 = array.size(arr) > 2 ? array.get(arr, 2) : na
    [t1, t2, t3]

[rankThresh1, rankThresh2, rankThresh3] = f_top3_thresholds(
     sym_1_enable ? finalScore_1 : na, sym_2_enable ? finalScore_2 : na, sym_3_enable ? finalScore_3 : na, sym_4_enable ? finalScore_4 : na,
     sym_5_enable ? finalScore_5 : na, sym_6_enable ? finalScore_6 : na, sym_7_enable ? finalScore_7 : na, sym_8_enable ? finalScore_8 : na,
     sym_1_enable and qualifies1, sym_2_enable and qualifies2, sym_3_enable and qualifies3, sym_4_enable and qualifies4,
     sym_5_enable and qualifies5, sym_6_enable and qualifies6, sym_7_enable and qualifies7, sym_8_enable and qualifies8)

f_rank_marker(float score, bool qualifies) =>
    string result = ""
    if qualifies and not na(score)
        if not na(rankThresh1) and score == rankThresh1
            result := "🥇 "
        else if not na(rankThresh2) and score == rankThresh2
            result := "🥈 "
        else if not na(rankThresh3) and score == rankThresh3
            result := "🥉 "
    result

f_is_medalist(float score, bool qualifies) =>
    qualifies and not na(score) and ((not na(rankThresh1) and score == rankThresh1) or (not na(rankThresh2) and score == rankThresh2) or (not na(rankThresh3) and score == rankThresh3))

bool isMedalist1 = f_is_medalist(finalScore_1, qualifies1)
bool isMedalist2 = f_is_medalist(finalScore_2, qualifies2)
bool isMedalist3 = f_is_medalist(finalScore_3, qualifies3)
bool isMedalist4 = f_is_medalist(finalScore_4, qualifies4)
bool isMedalist5 = f_is_medalist(finalScore_5, qualifies5)
bool isMedalist6 = f_is_medalist(finalScore_6, qualifies6)
bool isMedalist7 = f_is_medalist(finalScore_7, qualifies7)
bool isMedalist8 = f_is_medalist(finalScore_8, qualifies8)

bool effVisible1 = visible1 and (not medals_only_on or isMedalist1)
bool effVisible2 = visible2 and (not medals_only_on or isMedalist2)
bool effVisible3 = visible3 and (not medals_only_on or isMedalist3)
bool effVisible4 = visible4 and (not medals_only_on or isMedalist4)
bool effVisible5 = visible5 and (not medals_only_on or isMedalist5)
bool effVisible6 = visible6 and (not medals_only_on or isMedalist6)
bool effVisible7 = visible7 and (not medals_only_on or isMedalist7)
bool effVisible8 = visible8 and (not medals_only_on or isMedalist8)

bool summaryColVisible1 = effVisible1 and (not summary_on or qualifies1)
bool summaryColVisible2 = effVisible2 and (not summary_on or qualifies2)
bool summaryColVisible3 = effVisible3 and (not summary_on or qualifies3)
bool summaryColVisible4 = effVisible4 and (not summary_on or qualifies4)
bool summaryColVisible5 = effVisible5 and (not summary_on or qualifies5)
bool summaryColVisible6 = effVisible6 and (not summary_on or qualifies6)
bool summaryColVisible7 = effVisible7 and (not summary_on or qualifies7)
bool summaryColVisible8 = effVisible8 and (not summary_on or qualifies8)

f_rank_num(float score, bool qualifies) =>
    int result = 0
    if qualifies and not na(score)
        if not na(rankThresh1) and score == rankThresh1
            result := 1
        else if not na(rankThresh2) and score == rankThresh2
            result := 2
        else if not na(rankThresh3) and score == rankThresh3
            result := 3
    result

rankNow1 = f_rank_num(finalScore_1, qualifies1)
rankNow2 = f_rank_num(finalScore_2, qualifies2)
rankNow3 = f_rank_num(finalScore_3, qualifies3)
rankNow4 = f_rank_num(finalScore_4, qualifies4)
rankNow5 = f_rank_num(finalScore_5, qualifies5)
rankNow6 = f_rank_num(finalScore_6, qualifies6)
rankNow7 = f_rank_num(finalScore_7, qualifies7)
rankNow8 = f_rank_num(finalScore_8, qualifies8)

bool medalChanged1 = rankNow1 != rankNow1[1]
bool medalChanged2 = rankNow2 != rankNow2[1]
bool medalChanged3 = rankNow3 != rankNow3[1]
bool medalChanged4 = rankNow4 != rankNow4[1]
bool medalChanged5 = rankNow5 != rankNow5[1]
bool medalChanged6 = rankNow6 != rankNow6[1]
bool medalChanged7 = rankNow7 != rankNow7[1]
bool medalChanged8 = rankNow8 != rankNow8[1]
bool anyMedalChanged = medalChanged1 or medalChanged2 or medalChanged3 or medalChanged4 or medalChanged5 or medalChanged6 or medalChanged7 or medalChanged8

bool memberChanged1 = (rankNow1 > 0) != (rankNow1[1] > 0)
bool memberChanged2 = (rankNow2 > 0) != (rankNow2[1] > 0)
bool memberChanged3 = (rankNow3 > 0) != (rankNow3[1] > 0)
bool memberChanged4 = (rankNow4 > 0) != (rankNow4[1] > 0)
bool memberChanged5 = (rankNow5 > 0) != (rankNow5[1] > 0)
bool memberChanged6 = (rankNow6 > 0) != (rankNow6[1] > 0)
bool memberChanged7 = (rankNow7 > 0) != (rankNow7[1] > 0)
bool memberChanged8 = (rankNow8 > 0) != (rankNow8[1] > 0)
bool medalCompositionChanged = memberChanged1 or memberChanged2 or memberChanged3 or memberChanged4 or memberChanged5 or memberChanged6 or memberChanged7 or memberChanged8

var int medalCompStreak = 0
var int medal3Streak = 0

int medalistCountNow = (isMedalist1 ? 1 : 0) + (isMedalist2 ? 1 : 0) + (isMedalist3 ? 1 : 0) + (isMedalist4 ? 1 : 0) +
     (isMedalist5 ? 1 : 0) + (isMedalist6 ? 1 : 0) + (isMedalist7 ? 1 : 0) + (isMedalist8 ? 1 : 0)

var bool prevIsMedalist1 = false
var bool prevIsMedalist2 = false
var bool prevIsMedalist3 = false
var bool prevIsMedalist4 = false
var bool prevIsMedalist5 = false
var bool prevIsMedalist6 = false
var bool prevIsMedalist7 = false
var bool prevIsMedalist8 = false

if newTf1Bar1 or newTf1Bar2 or newTf1Bar3 or newTf1Bar4 or newTf1Bar5 or newTf1Bar6 or newTf1Bar7 or newTf1Bar8
    bool compChangedTf1 = (isMedalist1 != prevIsMedalist1) or (isMedalist2 != prevIsMedalist2) or (isMedalist3 != prevIsMedalist3) or
         (isMedalist4 != prevIsMedalist4) or (isMedalist5 != prevIsMedalist5) or (isMedalist6 != prevIsMedalist6) or
         (isMedalist7 != prevIsMedalist7) or (isMedalist8 != prevIsMedalist8)
    medalCompStreak := compChangedTf1 ? 0 : medalCompStreak + 1
    medal3Streak := medalistCountNow >= 3 ? medal3Streak + 1 : 0
    prevIsMedalist1 := isMedalist1
    prevIsMedalist2 := isMedalist2
    prevIsMedalist3 := isMedalist3
    prevIsMedalist4 := isMedalist4
    prevIsMedalist5 := isMedalist5
    prevIsMedalist6 := isMedalist6
    prevIsMedalist7 := isMedalist7
    prevIsMedalist8 := isMedalist8

int cfgTotal = (sym_1_enable and not isDxy1 ? 1 : 0) + (sym_2_enable and not isDxy2 ? 1 : 0) + (sym_3_enable and not isDxy3 ? 1 : 0) +
     (sym_4_enable and not isDxy4 ? 1 : 0) + (sym_5_enable and not isDxy5 ? 1 : 0) + (sym_6_enable and not isDxy6 ? 1 : 0) +
     (sym_7_enable and not isDxy7 ? 1 : 0) + (sym_8_enable and not isDxy8 ? 1 : 0)
int cfgHighPurity = (sym_1_enable and not isDxy1 and not na(purity_1) and purity_1 >= market_purity_threshold ? 1 : 0) +
     (sym_2_enable and not isDxy2 and not na(purity_2) and purity_2 >= market_purity_threshold ? 1 : 0) +
     (sym_3_enable and not isDxy3 and not na(purity_3) and purity_3 >= market_purity_threshold ? 1 : 0) +
     (sym_4_enable and not isDxy4 and not na(purity_4) and purity_4 >= market_purity_threshold ? 1 : 0) +
     (sym_5_enable and not isDxy5 and not na(purity_5) and purity_5 >= market_purity_threshold ? 1 : 0) +
     (sym_6_enable and not isDxy6 and not na(purity_6) and purity_6 >= market_purity_threshold ? 1 : 0) +
     (sym_7_enable and not isDxy7 and not na(purity_7) and purity_7 >= market_purity_threshold ? 1 : 0) +
     (sym_8_enable and not isDxy8 and not na(purity_8) and purity_8 >= market_purity_threshold ? 1 : 0)
int cfgTrending = (sym_1_enable and not isDxy1 and verdict_1 != 0 ? 1 : 0) + (sym_2_enable and not isDxy2 and verdict_2 != 0 ? 1 : 0) +
     (sym_3_enable and not isDxy3 and verdict_3 != 0 ? 1 : 0) + (sym_4_enable and not isDxy4 and verdict_4 != 0 ? 1 : 0) +
     (sym_5_enable and not isDxy5 and verdict_5 != 0 ? 1 : 0) + (sym_6_enable and not isDxy6 and verdict_6 != 0 ? 1 : 0) +
     (sym_7_enable and not isDxy7 and verdict_7 != 0 ? 1 : 0) + (sym_8_enable and not isDxy8 and verdict_8 != 0 ? 1 : 0)

float compA = math.min(medalCompStreak / float(market_streak_cap), 1) * 100
float compB = cfgTotal > 0 ? (cfgHighPurity / float(cfgTotal)) * 100 : na
float compC = cfgTotal > 0 ? (cfgTrending / float(cfgTotal)) * 100 : na
float compD = math.min(medal3Streak / float(market_streak_cap), 1) * 100

float marketStabilityLive = (not na(compB) and not na(compC)) ? (compA + compB + compC + compD) / 4 : na

var float marketStability = na
if newTf1Bar1 or newTf1Bar2 or newTf1Bar3 or newTf1Bar4 or newTf1Bar5 or newTf1Bar6 or newTf1Bar7 or newTf1Bar8
    marketStability := marketStabilityLive

var float[] marketStabHist = array.new<float>()
if newTf1Bar1 or newTf1Bar2 or newTf1Bar3 or newTf1Bar4 or newTf1Bar5 or newTf1Bar6 or newTf1Bar7 or newTf1Bar8
    array.push(marketStabHist, marketStability)
    if array.size(marketStabHist) > market_stability_history
        array.remove(marketStabHist, 0)

f_stability_chain(array<float> hist, float current) =>
    string result = ""
    int n = array.size(hist)
    if n >= 2
        for i = 1 to n - 1
            float prev = array.get(hist, i - 1)
            float now  = array.get(hist, i)
            if na(prev) or na(now)
                result := result + "—"
            else
                float d = now - prev
                result := result + (d >= 0 ? "+" : "") + str.tostring(math.round(d))
            if i < n - 1
                result := result + " » "
    result := result + (result == "" ? "" : "  ⇒  ") + (na(current) ? "—" : str.tostring(math.round(current))) + "/100"
    result

if alert_medal_on and (newTf1Bar1 or newTf1Bar2 or newTf1Bar3 or newTf1Bar4 or newTf1Bar5 or newTf1Bar6 or newTf1Bar7 or newTf1Bar8) and anyMedalChanged
    string joined = ""
    string left   = ""
    if rankNow1 > 0 and rankNow1[1] == 0
        joined := joined + (joined == "" ? "" : ", ") + f_short_sym(sym_1)
    if rankNow1 == 0 and rankNow1[1] > 0
        left := left + (left == "" ? "" : ", ") + f_short_sym(sym_1)
    if rankNow2 > 0 and rankNow2[1] == 0
        joined := joined + (joined == "" ? "" : ", ") + f_short_sym(sym_2)
    if rankNow2 == 0 and rankNow2[1] > 0
        left := left + (left == "" ? "" : ", ") + f_short_sym(sym_2)
    if rankNow3 > 0 and rankNow3[1] == 0
        joined := joined + (joined == "" ? "" : ", ") + f_short_sym(sym_3)
    if rankNow3 == 0 and rankNow3[1] > 0
        left := left + (left == "" ? "" : ", ") + f_short_sym(sym_3)
    if rankNow4 > 0 and rankNow4[1] == 0
        joined := joined + (joined == "" ? "" : ", ") + f_short_sym(sym_4)
    if rankNow4 == 0 and rankNow4[1] > 0
        left := left + (left == "" ? "" : ", ") + f_short_sym(sym_4)
    if rankNow5 > 0 and rankNow5[1] == 0
        joined := joined + (joined == "" ? "" : ", ") + f_short_sym(sym_5)
    if rankNow5 == 0 and rankNow5[1] > 0
        left := left + (left == "" ? "" : ", ") + f_short_sym(sym_5)
    if rankNow6 > 0 and rankNow6[1] == 0
        joined := joined + (joined == "" ? "" : ", ") + f_short_sym(sym_6)
    if rankNow6 == 0 and rankNow6[1] > 0
        left := left + (left == "" ? "" : ", ") + f_short_sym(sym_6)
    if rankNow7 > 0 and rankNow7[1] == 0
        joined := joined + (joined == "" ? "" : ", ") + f_short_sym(sym_7)
    if rankNow7 == 0 and rankNow7[1] > 0
        left := left + (left == "" ? "" : ", ") + f_short_sym(sym_7)
    if rankNow8 > 0 and rankNow8[1] == 0
        joined := joined + (joined == "" ? "" : ", ") + f_short_sym(sym_8)
    if rankNow8 == 0 and rankNow8[1] > 0
        left := left + (left == "" ? "" : ", ") + f_short_sym(sym_8)

    string message = ""
    if medalCompositionChanged
        message := "Medalists changed:"
        if joined != ""
            message := message + " +" + joined
        if left != ""
            message := message + " -" + left
    else
        string order = ""
        if rankNow1 == 1
            order := f_short_sym(sym_1)
        else if rankNow2 == 1
            order := f_short_sym(sym_2)
        else if rankNow3 == 1
            order := f_short_sym(sym_3)
        else if rankNow4 == 1
            order := f_short_sym(sym_4)
        else if rankNow5 == 1
            order := f_short_sym(sym_5)
        else if rankNow6 == 1
            order := f_short_sym(sym_6)
        else if rankNow7 == 1
            order := f_short_sym(sym_7)
        else if rankNow8 == 1
            order := f_short_sym(sym_8)
        if rankNow1 == 2
            order := order + " > " + f_short_sym(sym_1)
        else if rankNow2 == 2
            order := order + " > " + f_short_sym(sym_2)
        else if rankNow3 == 2
            order := order + " > " + f_short_sym(sym_3)
        else if rankNow4 == 2
            order := order + " > " + f_short_sym(sym_4)
        else if rankNow5 == 2
            order := order + " > " + f_short_sym(sym_5)
        else if rankNow6 == 2
            order := order + " > " + f_short_sym(sym_6)
        else if rankNow7 == 2
            order := order + " > " + f_short_sym(sym_7)
        else if rankNow8 == 2
            order := order + " > " + f_short_sym(sym_8)
        if rankNow1 == 3
            order := order + " > " + f_short_sym(sym_1)
        else if rankNow2 == 3
            order := order + " > " + f_short_sym(sym_2)
        else if rankNow3 == 3
            order := order + " > " + f_short_sym(sym_3)
        else if rankNow4 == 3
            order := order + " > " + f_short_sym(sym_4)
        else if rankNow5 == 3
            order := order + " > " + f_short_sym(sym_5)
        else if rankNow6 == 3
            order := order + " > " + f_short_sym(sym_6)
        else if rankNow7 == 3
            order := order + " > " + f_short_sym(sym_7)
        else if rankNow8 == 3
            order := order + " > " + f_short_sym(sym_8)
        message := "Medalist order changed: " + order

    alert(message, alert.freq_once_per_bar_close)

var int streak1 = 0
var int streak2 = 0
var int streak3 = 0
var int streak4 = 0
var int streak5 = 0
var int streak6 = 0
var int streak7 = 0
var int streak8 = 0

if newTf1Bar1
    streak1 := (verdict_1 != 0 and check_t1 > 0 and check_p1 == check_t1) ? streak1 + 1 : 0
if newTf1Bar2
    streak2 := (verdict_2 != 0 and check_t2 > 0 and check_p2 == check_t2) ? streak2 + 1 : 0
if newTf1Bar3
    streak3 := (verdict_3 != 0 and check_t3 > 0 and check_p3 == check_t3) ? streak3 + 1 : 0
if newTf1Bar4
    streak4 := (verdict_4 != 0 and check_t4 > 0 and check_p4 == check_t4) ? streak4 + 1 : 0
if newTf1Bar5
    streak5 := (verdict_5 != 0 and check_t5 > 0 and check_p5 == check_t5) ? streak5 + 1 : 0
if newTf1Bar6
    streak6 := (verdict_6 != 0 and check_t6 > 0 and check_p6 == check_t6) ? streak6 + 1 : 0
if newTf1Bar7
    streak7 := (verdict_7 != 0 and check_t7 > 0 and check_p7 == check_t7) ? streak7 + 1 : 0
if newTf1Bar8
    streak8 := (verdict_8 != 0 and check_t8 > 0 and check_p8 == check_t8) ? streak8 + 1 : 0

string alarm_tz_str = "UTC" + (alarm_utc_offset >= 0 ? "+" : "") + str.tostring(alarm_utc_offset)
bool alarmTimeMatch = hour(time, alarm_tz_str) == alarm_hour and minute(time, alarm_tz_str) == alarm_minute

int trendingCount = (not isDxy1 and verdict_1 != 0 ? 1 : 0) + (not isDxy2 and verdict_2 != 0 ? 1 : 0) +
     (not isDxy3 and verdict_3 != 0 ? 1 : 0) + (not isDxy4 and verdict_4 != 0 ? 1 : 0) +
     (not isDxy5 and verdict_5 != 0 ? 1 : 0) + (not isDxy6 and verdict_6 != 0 ? 1 : 0) +
     (not isDxy7 and verdict_7 != 0 ? 1 : 0) + (not isDxy8 and verdict_8 != 0 ? 1 : 0)

int medalistCount = (isMedalist1 ? 1 : 0) + (isMedalist2 ? 1 : 0) + (isMedalist3 ? 1 : 0) + (isMedalist4 ? 1 : 0) +
     (isMedalist5 ? 1 : 0) + (isMedalist6 ? 1 : 0) + (isMedalist7 ? 1 : 0) + (isMedalist8 ? 1 : 0)

int stableMedalistCount = (isMedalist1 and streak1 >= 3 ? 1 : 0) + (isMedalist2 and streak2 >= 3 ? 1 : 0) +
     (isMedalist3 and streak3 >= 3 ? 1 : 0) + (isMedalist4 and streak4 >= 3 ? 1 : 0) +
     (isMedalist5 and streak5 >= 3 ? 1 : 0) + (isMedalist6 and streak6 >= 3 ? 1 : 0) +
     (isMedalist7 and streak7 >= 3 ? 1 : 0) + (isMedalist8 and streak8 >= 3 ? 1 : 0)

bool alarmConditionMet = alarm_condition == "3+ trend" ? trendingCount >= 3 :
     alarm_condition == "1+ medalists" ? medalistCount >= 1 :
     alarm_condition == "3 medalists" ? medalistCount >= 3 :
     stableMedalistCount >= 3

if alarm_on and alarmTimeMatch and alarmConditionMet
    alert("Morning alarm: " + alarm_condition + " (medalists now: " + str.tostring(medalistCount) + ", trending now: " + str.tostring(trendingCount) + ")", alert.freq_once_per_bar_close)

f_check_alert(bool enabled, bool isDxy, int verdict, int passed, int total, string symName) =>
    bool fullNow = not isDxy and verdict != 0 and total > 0 and passed == total
    if enabled and barstate.isconfirmed and fullNow and not fullNow[1]
        alert(symName + ": Check turned green ✅ (" + str.tostring(passed) + "/" + str.tostring(total) + ")", alert.freq_once_per_bar_close)

f_check_alert(sym_1_enable and alert_check_on, isDxy1, verdict_1, check_p1, check_t1, f_short_sym(sym_1))
f_check_alert(sym_2_enable and alert_check_on, isDxy2, verdict_2, check_p2, check_t2, f_short_sym(sym_2))
f_check_alert(sym_3_enable and alert_check_on, isDxy3, verdict_3, check_p3, check_t3, f_short_sym(sym_3))
f_check_alert(sym_4_enable and alert_check_on, isDxy4, verdict_4, check_p4, check_t4, f_short_sym(sym_4))
f_check_alert(sym_5_enable and alert_check_on, isDxy5, verdict_5, check_p5, check_t5, f_short_sym(sym_5))
f_check_alert(sym_6_enable and alert_check_on, isDxy6, verdict_6, check_p6, check_t6, f_short_sym(sym_6))
f_check_alert(sym_7_enable and alert_check_on, isDxy7, verdict_7, check_p7, check_t7, f_short_sym(sym_7))
f_check_alert(sym_8_enable and alert_check_on, isDxy8, verdict_8, check_p8, check_t8, f_short_sym(sym_8))

f_medal_streak2_alert(bool enabled, bool isMedalist, int streak, bool newBar, string symName) =>
    if enabled and newBar and isMedalist and streak == 2 and streak[1] == 1
        alert(symName + ": medalist Check streak reached x2", alert.freq_once_per_bar_close)

f_medal_streak2_alert(sym_1_enable and alert_medal_streak2_on, isMedalist1, streak1, newTf1Bar1, f_short_sym(sym_1))
f_medal_streak2_alert(sym_2_enable and alert_medal_streak2_on, isMedalist2, streak2, newTf1Bar2, f_short_sym(sym_2))
f_medal_streak2_alert(sym_3_enable and alert_medal_streak2_on, isMedalist3, streak3, newTf1Bar3, f_short_sym(sym_3))
f_medal_streak2_alert(sym_4_enable and alert_medal_streak2_on, isMedalist4, streak4, newTf1Bar4, f_short_sym(sym_4))
f_medal_streak2_alert(sym_5_enable and alert_medal_streak2_on, isMedalist5, streak5, newTf1Bar5, f_short_sym(sym_5))
f_medal_streak2_alert(sym_6_enable and alert_medal_streak2_on, isMedalist6, streak6, newTf1Bar6, f_short_sym(sym_6))
f_medal_streak2_alert(sym_7_enable and alert_medal_streak2_on, isMedalist7, streak7, newTf1Bar7, f_short_sym(sym_7))
f_medal_streak2_alert(sym_8_enable and alert_medal_streak2_on, isMedalist8, streak8, newTf1Bar8, f_short_sym(sym_8))

f_check_text(bool isDxy, int verdict, int passed, int total, int streak) =>
    string result = "—"
    if isDxy
        result := ""
    else if verdict != 0
        result := (total > 0 and passed == total) ? "✅ (" + str.tostring(passed) + "/" + str.tostring(total) + ") x" + str.tostring(math.max(streak, 1)) : "🛑 (" + str.tostring(passed) + "/" + str.tostring(total) + ")"
    result

f_check_bg(int verdict, int passed, int total) =>
    white

f_check_tooltip(bool isDxy, int verdict, int total,
     bool c1en, bool c1pass, bool c2en, bool c2pass, bool c3en, bool c3pass, bool c4en, bool c4pass,
     bool c5en, bool c5pass, bool c6en, bool c6pass, bool c7en, bool c7pass, bool c8en, bool c8pass, bool c9en, bool c9pass) =>
    string result = ""
    if isDxy
        result := "DXY column — checklist not applicable"
    else if verdict == 0
        result := "No trend — checklist not evaluated"
    else if total == 0
        result := "No checklist items enabled"
    else
        string failed = ""
        if c1en and not c1pass
            failed := failed + (failed == "" ? "" : "\n") + "1. DXY 1h+4h not synced (closed values)"
        if c2en and not c2pass
            failed := failed + (failed == "" ? "" : "\n") + "2. EUR 1h+4h not synced (closed values)"
        if c3en and not c3pass
            failed := failed + (failed == "" ? "" : "\n") + "3. DXY has a sign-flagged higher TF"
        if c4en and not c4pass
            failed := failed + (failed == "" ? "" : "\n") + "4. DXY 15m against the trade, |value| above " + str.tostring(chk4_min_abs) + ", and still building"
        if c5en and not c5pass
            failed := failed + (failed == "" ? "" : "\n") + "5. Trend Score is at or below " + str.tostring(chk5_min_trend)
        if c6en and not c6pass
            failed := failed + (failed == "" ? "" : "\n") + "6. Entry Score is at or below " + str.tostring(chk6_min_entry)
        if c7en and not c7pass
            failed := failed + (failed == "" ? "" : "\n") + "7. This instrument has a sign-flagged Trend-TF"
        if c8en and not c8pass
            failed := failed + (failed == "" ? "" : "\n") + "8. Beta is " + str.tostring(chk8_max_beta) + "x or above (extreme amplification vs DXY)"
        if c9en and not c9pass
            failed := failed + (failed == "" ? "" : "\n") + "9. A Trend-TF's |FT| is at or below " + str.tostring(chk9_min_abs) + " (right sign, but too close to zero to really confirm)"
        result := failed == "" ? "All enabled checks passed" : "Failed:\n" + failed
    result

f_score_bg(int verdict, float score) =>
    color result = white
    if not na(score)
        float ratio = math.min(math.max(score, 0), 100) / 100
        result := verdict == 1 ? f_tier3_bg(ratio, #EDF5EF, #B9DDC5, #6FA287, #16261C, #234A34, #3ECF8E) :
             verdict == -1 ? f_tier3_bg(ratio, #F5EDED, #DDB9B9, #C97B7B, #2A1616, #4A2323, #EF5350) : result
    result

f_score_text_color(float score) =>
    theme_dark ? color.new(#C7CBD1, 0) : (na(score) ? color.black : (score >= 67 ? color.white : color.black))

f_score_text(float score) =>
    na(score) ? "—" : str.tostring(math.round(score))

f_final_bg(int verdict, float score) =>
    color result = white
    if not na(score) and verdict != 0
        float ratio = math.min(math.max(score, 0), 100) / 100
        color faintGreenL = color.from_gradient(ratio, 0, 1, color.new(#F7F8FA, 0), #DCEEE0)
        color faintGreenD = color.from_gradient(ratio, 0, 1, color.new(#12151A, 0), #1B3A2E)
        color faintRedL   = color.from_gradient(ratio, 0, 1, color.new(#F7F8FA, 0), #F6DEDE)
        color faintRedD   = color.from_gradient(ratio, 0, 1, color.new(#12151A, 0), #3A1B1F)
        result := verdict == 1 ? f_tint(faintGreenL, faintGreenD) : f_tint(faintRedL, faintRedD)
    result

if barstate.islast
    int nSym = (summaryColVisible1 ? 1 : 0) + (summaryColVisible2 ? 1 : 0) + (summaryColVisible3 ? 1 : 0) + (summaryColVisible4 ? 1 : 0) +
               (summaryColVisible5 ? 1 : 0) + (summaryColVisible6 ? 1 : 0) + (summaryColVisible7 ? 1 : 0) + (summaryColVisible8 ? 1 : 0)
    int nTf  = (tf_1_enable ? 1 : 0) + (tf_2_enable ? 1 : 0) + (tf_3_enable ? 1 : 0)

    if nSym > 0 and nTf > 0
        int displayedTfRows   = summary_on ? 0 : nTf
        int displayedTrend    = summary_on ? 0 : 1
        int displayedDxy      = (dxy_on and not summary_on) ? 1 : 0
        int displayedStability = (dxy_on and dxy_stability_on and not summary_on) ? 1 : 0
        int displayedBeta     = (not summary_on and dxy_on and beta_on) ? 1 : 0
        int displayedScore    = summary_on ? 1 : 3
        int displayedMomentum = 1
        int displayedCheck    = checklist_any_on ? 1 : 0
        int totalRows = 1 + displayedTfRows + displayedTrend + displayedDxy + displayedStability + displayedBeta + displayedScore + displayedMomentum + displayedCheck
        table scr = table.new(f_pos(db_position_s), nSym + 1, totalRows, border_width = 1, border_color = gray, frame_color = gray, frame_width = 1)
        sz = f_size(db_size_s)

        table.cell(scr, 0, 0, summary_on ? "" : "FT", text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "FlowTrend value on each timeframe row below — the raw momentum reading everything else in this table is built from.")

        int c = 1
        if summaryColVisible1
            table.cell(scr, c, 0, f_header_label(sym_1, verdict_1, isDxy1), text_color = isCur1 ? color.new(color.white, 0) : labelText, text_size = sz, bgcolor = isCur1 ? color.new(color.black, 0) : labelBg)
            c := c + 1
        if summaryColVisible2
            table.cell(scr, c, 0, f_header_label(sym_2, verdict_2, isDxy2), text_color = isCur2 ? color.new(color.white, 0) : labelText, text_size = sz, bgcolor = isCur2 ? color.new(color.black, 0) : labelBg)
            c := c + 1
        if summaryColVisible3
            table.cell(scr, c, 0, f_header_label(sym_3, verdict_3, isDxy3), text_color = isCur3 ? color.new(color.white, 0) : labelText, text_size = sz, bgcolor = isCur3 ? color.new(color.black, 0) : labelBg)
            c := c + 1
        if summaryColVisible4
            table.cell(scr, c, 0, f_header_label(sym_4, verdict_4, isDxy4), text_color = isCur4 ? color.new(color.white, 0) : labelText, text_size = sz, bgcolor = isCur4 ? color.new(color.black, 0) : labelBg)
            c := c + 1
        if summaryColVisible5
            table.cell(scr, c, 0, f_header_label(sym_5, verdict_5, isDxy5), text_color = isCur5 ? color.new(color.white, 0) : labelText, text_size = sz, bgcolor = isCur5 ? color.new(color.black, 0) : labelBg)
            c := c + 1
        if summaryColVisible6
            table.cell(scr, c, 0, f_header_label(sym_6, verdict_6, isDxy6), text_color = isCur6 ? color.new(color.white, 0) : labelText, text_size = sz, bgcolor = isCur6 ? color.new(color.black, 0) : labelBg)
            c := c + 1
        if summaryColVisible7
            table.cell(scr, c, 0, f_header_label(sym_7, verdict_7, isDxy7), text_color = isCur7 ? color.new(color.white, 0) : labelText, text_size = sz, bgcolor = isCur7 ? color.new(color.black, 0) : labelBg)
            c := c + 1
        if summaryColVisible8
            table.cell(scr, c, 0, f_header_label(sym_8, verdict_8, isDxy8), text_color = isCur8 ? color.new(color.white, 0) : labelText, text_size = sz, bgcolor = isCur8 ? color.new(color.black, 0) : labelBg)
            c := c + 1

        int r = 0
        if tf_1_enable and not summary_on
            r := r + 1
            table.cell(scr, 0, r, f_tf_label(tf_1, tf_1_confirm), text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "TF1 (fastest timeframe) — FlowTrend value here. \"(C)\" means Confirm is on: this shows the last CLOSED bar's value, not the live still-forming one.")
            int cc = 1
            if effVisible1
                table.cell(scr, cc, r, f_ft_text_flagged(w1_1, f1_1), text_color = f_ft_text_color(w1_1, max1, min1), text_size = sz, bgcolor = f_ft_bg2(w1_1, max1, min1))
                cc := cc + 1
            if effVisible2
                table.cell(scr, cc, r, f_ft_text_flagged(w2_1, f2_1), text_color = f_ft_text_color(w2_1, max1, min1), text_size = sz, bgcolor = f_ft_bg2(w2_1, max1, min1))
                cc := cc + 1
            if effVisible3
                table.cell(scr, cc, r, f_ft_text_flagged(w3_1, f3_1), text_color = f_ft_text_color(w3_1, max1, min1), text_size = sz, bgcolor = f_ft_bg2(w3_1, max1, min1))
                cc := cc + 1
            if effVisible4
                table.cell(scr, cc, r, f_ft_text_flagged(w4_1, f4_1), text_color = f_ft_text_color(w4_1, max1, min1), text_size = sz, bgcolor = f_ft_bg2(w4_1, max1, min1))
                cc := cc + 1
            if effVisible5
                table.cell(scr, cc, r, f_ft_text_flagged(w5_1, f5_1), text_color = f_ft_text_color(w5_1, max1, min1), text_size = sz, bgcolor = f_ft_bg2(w5_1, max1, min1))
                cc := cc + 1
            if effVisible6
                table.cell(scr, cc, r, f_ft_text_flagged(w6_1, f6_1), text_color = f_ft_text_color(w6_1, max1, min1), text_size = sz, bgcolor = f_ft_bg2(w6_1, max1, min1))
                cc := cc + 1
            if effVisible7
                table.cell(scr, cc, r, f_ft_text_flagged(w7_1, f7_1), text_color = f_ft_text_color(w7_1, max1, min1), text_size = sz, bgcolor = f_ft_bg2(w7_1, max1, min1))
                cc := cc + 1
            if effVisible8
                table.cell(scr, cc, r, f_ft_text_flagged(w8_1, f8_1), text_color = f_ft_text_color(w8_1, max1, min1), text_size = sz, bgcolor = f_ft_bg2(w8_1, max1, min1))
                cc := cc + 1

        if tf_2_enable and not summary_on
            r := r + 1
            table.cell(scr, 0, r, f_tf_label(tf_2, tf_2_confirm), text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "TF2 — FlowTrend value here. \"(C)\" means Confirm is on: this shows the last CLOSED bar's value, not the live still-forming one.")
            int cc = 1
            if effVisible1
                table.cell(scr, cc, r, f_ft_text_flagged(w1_2, f1_2), text_color = f_ft_text_color(w1_2, max2, min2), text_size = sz, bgcolor = f_ft_bg2(w1_2, max2, min2))
                cc := cc + 1
            if effVisible2
                table.cell(scr, cc, r, f_ft_text_flagged(w2_2, f2_2), text_color = f_ft_text_color(w2_2, max2, min2), text_size = sz, bgcolor = f_ft_bg2(w2_2, max2, min2))
                cc := cc + 1
            if effVisible3
                table.cell(scr, cc, r, f_ft_text_flagged(w3_2, f3_2), text_color = f_ft_text_color(w3_2, max2, min2), text_size = sz, bgcolor = f_ft_bg2(w3_2, max2, min2))
                cc := cc + 1
            if effVisible4
                table.cell(scr, cc, r, f_ft_text_flagged(w4_2, f4_2), text_color = f_ft_text_color(w4_2, max2, min2), text_size = sz, bgcolor = f_ft_bg2(w4_2, max2, min2))
                cc := cc + 1
            if effVisible5
                table.cell(scr, cc, r, f_ft_text_flagged(w5_2, f5_2), text_color = f_ft_text_color(w5_2, max2, min2), text_size = sz, bgcolor = f_ft_bg2(w5_2, max2, min2))
                cc := cc + 1
            if effVisible6
                table.cell(scr, cc, r, f_ft_text_flagged(w6_2, f6_2), text_color = f_ft_text_color(w6_2, max2, min2), text_size = sz, bgcolor = f_ft_bg2(w6_2, max2, min2))
                cc := cc + 1
            if effVisible7
                table.cell(scr, cc, r, f_ft_text_flagged(w7_2, f7_2), text_color = f_ft_text_color(w7_2, max2, min2), text_size = sz, bgcolor = f_ft_bg2(w7_2, max2, min2))
                cc := cc + 1
            if effVisible8
                table.cell(scr, cc, r, f_ft_text_flagged(w8_2, f8_2), text_color = f_ft_text_color(w8_2, max2, min2), text_size = sz, bgcolor = f_ft_bg2(w8_2, max2, min2))
                cc := cc + 1

        if tf_3_enable and not summary_on
            r := r + 1
            table.cell(scr, 0, r, f_tf_label(tf_3, tf_3_confirm), text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "TF3 — FlowTrend value here. \"(C)\" means Confirm is on: this shows the last CLOSED bar's value, not the live still-forming one.")
            int cc = 1
            if effVisible1
                table.cell(scr, cc, r, f_ft_text_flagged(w1_3, f1_3), text_color = f_ft_text_color(w1_3, max3, min3), text_size = sz, bgcolor = f_ft_bg2(w1_3, max3, min3))
                cc := cc + 1
            if effVisible2
                table.cell(scr, cc, r, f_ft_text_flagged(w2_3, f2_3), text_color = f_ft_text_color(w2_3, max3, min3), text_size = sz, bgcolor = f_ft_bg2(w2_3, max3, min3))
                cc := cc + 1
            if effVisible3
                table.cell(scr, cc, r, f_ft_text_flagged(w3_3, f3_3), text_color = f_ft_text_color(w3_3, max3, min3), text_size = sz, bgcolor = f_ft_bg2(w3_3, max3, min3))
                cc := cc + 1
            if effVisible4
                table.cell(scr, cc, r, f_ft_text_flagged(w4_3, f4_3), text_color = f_ft_text_color(w4_3, max3, min3), text_size = sz, bgcolor = f_ft_bg2(w4_3, max3, min3))
                cc := cc + 1
            if effVisible5
                table.cell(scr, cc, r, f_ft_text_flagged(w5_3, f5_3), text_color = f_ft_text_color(w5_3, max3, min3), text_size = sz, bgcolor = f_ft_bg2(w5_3, max3, min3))
                cc := cc + 1
            if effVisible6
                table.cell(scr, cc, r, f_ft_text_flagged(w6_3, f6_3), text_color = f_ft_text_color(w6_3, max3, min3), text_size = sz, bgcolor = f_ft_bg2(w6_3, max3, min3))
                cc := cc + 1
            if effVisible7
                table.cell(scr, cc, r, f_ft_text_flagged(w7_3, f7_3), text_color = f_ft_text_color(w7_3, max3, min3), text_size = sz, bgcolor = f_ft_bg2(w7_3, max3, min3))
                cc := cc + 1
            if effVisible8
                table.cell(scr, cc, r, f_ft_text_flagged(w8_3, f8_3), text_color = f_ft_text_color(w8_3, max3, min3), text_size = sz, bgcolor = f_ft_bg2(w8_3, max3, min3))
                cc := cc + 1

        if not summary_on
            r := r + 1
            table.cell(scr, 0, r, "Trend", text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "BULL/BEAR only if all TFs with the \"Trend\" checkbox on agree in direction; otherwise \"—\" (no trend).")
            int cv = 1
            if effVisible1
                table.cell(scr, cv, r, f_verdict_text(verdict_1), text_color = black, text_size = sz, bgcolor = f_verdict_bg(verdict_1))
                cv := cv + 1
            if effVisible2
                table.cell(scr, cv, r, f_verdict_text(verdict_2), text_color = black, text_size = sz, bgcolor = f_verdict_bg(verdict_2))
                cv := cv + 1
            if effVisible3
                table.cell(scr, cv, r, f_verdict_text(verdict_3), text_color = black, text_size = sz, bgcolor = f_verdict_bg(verdict_3))
                cv := cv + 1
            if effVisible4
                table.cell(scr, cv, r, f_verdict_text(verdict_4), text_color = black, text_size = sz, bgcolor = f_verdict_bg(verdict_4))
                cv := cv + 1
            if effVisible5
                table.cell(scr, cv, r, f_verdict_text(verdict_5), text_color = black, text_size = sz, bgcolor = f_verdict_bg(verdict_5))
                cv := cv + 1
            if effVisible6
                table.cell(scr, cv, r, f_verdict_text(verdict_6), text_color = black, text_size = sz, bgcolor = f_verdict_bg(verdict_6))
                cv := cv + 1
            if effVisible7
                table.cell(scr, cv, r, f_verdict_text(verdict_7), text_color = black, text_size = sz, bgcolor = f_verdict_bg(verdict_7))
                cv := cv + 1
            if effVisible8
                table.cell(scr, cv, r, f_verdict_text(verdict_8), text_color = black, text_size = sz, bgcolor = f_verdict_bg(verdict_8))
                cv := cv + 1

        if dxy_on and not summary_on
            r := r + 1
            table.cell(scr, 0, r, "DXY %", text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "Purity — |correlation| between this instrument and DXY (short window). Higher = this move is more explained by the dollar; lower = it's running on its own driver.")
            int cp = 1
            if effVisible1
                table.cell(scr, cp, r, f_purity_text(purity_1), text_color = f_purity_text_color(purity_1), text_size = sz, bgcolor = f_purity_bg(purity_1))
                cp := cp + 1
            if effVisible2
                table.cell(scr, cp, r, f_purity_text(purity_2), text_color = f_purity_text_color(purity_2), text_size = sz, bgcolor = f_purity_bg(purity_2))
                cp := cp + 1
            if effVisible3
                table.cell(scr, cp, r, f_purity_text(purity_3), text_color = f_purity_text_color(purity_3), text_size = sz, bgcolor = f_purity_bg(purity_3))
                cp := cp + 1
            if effVisible4
                table.cell(scr, cp, r, f_purity_text(purity_4), text_color = f_purity_text_color(purity_4), text_size = sz, bgcolor = f_purity_bg(purity_4))
                cp := cp + 1
            if effVisible5
                table.cell(scr, cp, r, f_purity_text(purity_5), text_color = f_purity_text_color(purity_5), text_size = sz, bgcolor = f_purity_bg(purity_5))
                cp := cp + 1
            if effVisible6
                table.cell(scr, cp, r, f_purity_text(purity_6), text_color = f_purity_text_color(purity_6), text_size = sz, bgcolor = f_purity_bg(purity_6))
                cp := cp + 1
            if effVisible7
                table.cell(scr, cp, r, f_purity_text(purity_7), text_color = f_purity_text_color(purity_7), text_size = sz, bgcolor = f_purity_bg(purity_7))
                cp := cp + 1
            if effVisible8
                table.cell(scr, cp, r, f_purity_text(purity_8), text_color = f_purity_text_color(purity_8), text_size = sz, bgcolor = f_purity_bg(purity_8))
                cp := cp + 1

            if dxy_stability_on
                r := r + 1
                table.cell(scr, 0, r, "DXY Stab", text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "How much the DXY % above has shifted between a short and a longer window. STABLE = trust it; SHIFTING/UNSTABLE = treat DXY % with more caution right now.")
                int cst = 1
                if effVisible1
                    table.cell(scr, cst, r, f_stability_text(purity_1, purityStable_1), text_color = black, text_size = sz, bgcolor = f_stability_bg(purity_1, purityStable_1))
                    cst := cst + 1
                if effVisible2
                    table.cell(scr, cst, r, f_stability_text(purity_2, purityStable_2), text_color = black, text_size = sz, bgcolor = f_stability_bg(purity_2, purityStable_2))
                    cst := cst + 1
                if effVisible3
                    table.cell(scr, cst, r, f_stability_text(purity_3, purityStable_3), text_color = black, text_size = sz, bgcolor = f_stability_bg(purity_3, purityStable_3))
                    cst := cst + 1
                if effVisible4
                    table.cell(scr, cst, r, f_stability_text(purity_4, purityStable_4), text_color = black, text_size = sz, bgcolor = f_stability_bg(purity_4, purityStable_4))
                    cst := cst + 1
                if effVisible5
                    table.cell(scr, cst, r, f_stability_text(purity_5, purityStable_5), text_color = black, text_size = sz, bgcolor = f_stability_bg(purity_5, purityStable_5))
                    cst := cst + 1
                if effVisible6
                    table.cell(scr, cst, r, f_stability_text(purity_6, purityStable_6), text_color = black, text_size = sz, bgcolor = f_stability_bg(purity_6, purityStable_6))
                    cst := cst + 1
                if effVisible7
                    table.cell(scr, cst, r, f_stability_text(purity_7, purityStable_7), text_color = black, text_size = sz, bgcolor = f_stability_bg(purity_7, purityStable_7))
                    cst := cst + 1
                if effVisible8
                    table.cell(scr, cst, r, f_stability_text(purity_8, purityStable_8), text_color = black, text_size = sz, bgcolor = f_stability_bg(purity_8, purityStable_8))
                    cst := cst + 1

            if beta_on and not summary_on
                r := r + 1
                table.cell(scr, 0, r, "Beta", text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "How many times stronger/weaker this instrument moves vs DXY (1.0x = moves exactly with it). Higher = more amplitude, but also more noise/risk — this is a risk gauge, not a quality score.")
                int cb = 1
                if effVisible1
                    table.cell(scr, cb, r, f_beta_text(beta_1), text_color = f_beta_text_color(beta_1), text_size = sz, bgcolor = f_beta_bg(beta_1))
                    cb := cb + 1
                if effVisible2
                    table.cell(scr, cb, r, f_beta_text(beta_2), text_color = f_beta_text_color(beta_2), text_size = sz, bgcolor = f_beta_bg(beta_2))
                    cb := cb + 1
                if effVisible3
                    table.cell(scr, cb, r, f_beta_text(beta_3), text_color = f_beta_text_color(beta_3), text_size = sz, bgcolor = f_beta_bg(beta_3))
                    cb := cb + 1
                if effVisible4
                    table.cell(scr, cb, r, f_beta_text(beta_4), text_color = f_beta_text_color(beta_4), text_size = sz, bgcolor = f_beta_bg(beta_4))
                    cb := cb + 1
                if effVisible5
                    table.cell(scr, cb, r, f_beta_text(beta_5), text_color = f_beta_text_color(beta_5), text_size = sz, bgcolor = f_beta_bg(beta_5))
                    cb := cb + 1
                if effVisible6
                    table.cell(scr, cb, r, f_beta_text(beta_6), text_color = f_beta_text_color(beta_6), text_size = sz, bgcolor = f_beta_bg(beta_6))
                    cb := cb + 1
                if effVisible7
                    table.cell(scr, cb, r, f_beta_text(beta_7), text_color = f_beta_text_color(beta_7), text_size = sz, bgcolor = f_beta_bg(beta_7))
                    cb := cb + 1
                if effVisible8
                    table.cell(scr, cb, r, f_beta_text(beta_8), text_color = f_beta_text_color(beta_8), text_size = sz, bgcolor = f_beta_bg(beta_8))
                    cb := cb + 1

        if not summary_on
            r := r + 1
            table.cell(scr, 0, r, "Trend Sc", text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "Trend Score (0-100) — how good the STRUCTURE is right now (TF2 strength blended with Purity). Answers \"is this a solid trend\", not \"is now the moment to enter\".")
            int cts = 1
            if effVisible1
                table.cell(scr, cts, r, f_score_text(trendScore_1), text_color = f_score_text_color(trendScore_1), text_size = sz, bgcolor = f_score_bg(verdict_1, trendScore_1))
                cts := cts + 1
            if effVisible2
                table.cell(scr, cts, r, f_score_text(trendScore_2), text_color = f_score_text_color(trendScore_2), text_size = sz, bgcolor = f_score_bg(verdict_2, trendScore_2))
                cts := cts + 1
            if effVisible3
                table.cell(scr, cts, r, f_score_text(trendScore_3), text_color = f_score_text_color(trendScore_3), text_size = sz, bgcolor = f_score_bg(verdict_3, trendScore_3))
                cts := cts + 1
            if effVisible4
                table.cell(scr, cts, r, f_score_text(trendScore_4), text_color = f_score_text_color(trendScore_4), text_size = sz, bgcolor = f_score_bg(verdict_4, trendScore_4))
                cts := cts + 1
            if effVisible5
                table.cell(scr, cts, r, f_score_text(trendScore_5), text_color = f_score_text_color(trendScore_5), text_size = sz, bgcolor = f_score_bg(verdict_5, trendScore_5))
                cts := cts + 1
            if effVisible6
                table.cell(scr, cts, r, f_score_text(trendScore_6), text_color = f_score_text_color(trendScore_6), text_size = sz, bgcolor = f_score_bg(verdict_6, trendScore_6))
                cts := cts + 1
            if effVisible7
                table.cell(scr, cts, r, f_score_text(trendScore_7), text_color = f_score_text_color(trendScore_7), text_size = sz, bgcolor = f_score_bg(verdict_7, trendScore_7))
                cts := cts + 1
            if effVisible8
                table.cell(scr, cts, r, f_score_text(trendScore_8), text_color = f_score_text_color(trendScore_8), text_size = sz, bgcolor = f_score_bg(verdict_8, trendScore_8))
                cts := cts + 1

        if not summary_on
            r := r + 1
            table.cell(scr, 0, r, "Entry Sc", text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "Entry Score (0-100) — how ready THIS MOMENT is on TF1 (Strength + Freshness). Answers \"is now a good time to enter\", not \"is this a good trend\".")
            int cs = 1
            if effVisible1
                table.cell(scr, cs, r, f_score_text(entryScore_1), text_color = f_score_text_color(entryScore_1), text_size = sz, bgcolor = f_score_bg(verdict_1, entryScore_1))
                cs := cs + 1
            if effVisible2
                table.cell(scr, cs, r, f_score_text(entryScore_2), text_color = f_score_text_color(entryScore_2), text_size = sz, bgcolor = f_score_bg(verdict_2, entryScore_2))
                cs := cs + 1
            if effVisible3
                table.cell(scr, cs, r, f_score_text(entryScore_3), text_color = f_score_text_color(entryScore_3), text_size = sz, bgcolor = f_score_bg(verdict_3, entryScore_3))
                cs := cs + 1
            if effVisible4
                table.cell(scr, cs, r, f_score_text(entryScore_4), text_color = f_score_text_color(entryScore_4), text_size = sz, bgcolor = f_score_bg(verdict_4, entryScore_4))
                cs := cs + 1
            if effVisible5
                table.cell(scr, cs, r, f_score_text(entryScore_5), text_color = f_score_text_color(entryScore_5), text_size = sz, bgcolor = f_score_bg(verdict_5, entryScore_5))
                cs := cs + 1
            if effVisible6
                table.cell(scr, cs, r, f_score_text(entryScore_6), text_color = f_score_text_color(entryScore_6), text_size = sz, bgcolor = f_score_bg(verdict_6, entryScore_6))
                cs := cs + 1
            if effVisible7
                table.cell(scr, cs, r, f_score_text(entryScore_7), text_color = f_score_text_color(entryScore_7), text_size = sz, bgcolor = f_score_bg(verdict_7, entryScore_7))
                cs := cs + 1
            if effVisible8
                table.cell(scr, cs, r, f_score_text(entryScore_8), text_color = f_score_text_color(entryScore_8), text_size = sz, bgcolor = f_score_bg(verdict_8, entryScore_8))
                cs := cs + 1

        r := r + 1
        table.cell(scr, 0, r, "Final Sc", text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "Final Score (0-100) — geometric mean of Trend Score and Entry Score. Rewards a BALANCED candidate (both scores genuinely high together) over one where only one of the two is high. Among instruments whose Check is a full ✅ pass, the top 3 by Final Score are marked 🥇🥈🥉 right in this row.")
        int cf = 1
        if summaryColVisible1
            table.cell(scr, cf, r, f_rank_marker(finalScore_1, qualifies1) + f_score_text(finalScore_1), text_color = black, text_size = sz, bgcolor = f_final_bg(verdict_1, finalScore_1))
            cf := cf + 1
        if summaryColVisible2
            table.cell(scr, cf, r, f_rank_marker(finalScore_2, qualifies2) + f_score_text(finalScore_2), text_color = black, text_size = sz, bgcolor = f_final_bg(verdict_2, finalScore_2))
            cf := cf + 1
        if summaryColVisible3
            table.cell(scr, cf, r, f_rank_marker(finalScore_3, qualifies3) + f_score_text(finalScore_3), text_color = black, text_size = sz, bgcolor = f_final_bg(verdict_3, finalScore_3))
            cf := cf + 1
        if summaryColVisible4
            table.cell(scr, cf, r, f_rank_marker(finalScore_4, qualifies4) + f_score_text(finalScore_4), text_color = black, text_size = sz, bgcolor = f_final_bg(verdict_4, finalScore_4))
            cf := cf + 1
        if summaryColVisible5
            table.cell(scr, cf, r, f_rank_marker(finalScore_5, qualifies5) + f_score_text(finalScore_5), text_color = black, text_size = sz, bgcolor = f_final_bg(verdict_5, finalScore_5))
            cf := cf + 1
        if summaryColVisible6
            table.cell(scr, cf, r, f_rank_marker(finalScore_6, qualifies6) + f_score_text(finalScore_6), text_color = black, text_size = sz, bgcolor = f_final_bg(verdict_6, finalScore_6))
            cf := cf + 1
        if summaryColVisible7
            table.cell(scr, cf, r, f_rank_marker(finalScore_7, qualifies7) + f_score_text(finalScore_7), text_color = black, text_size = sz, bgcolor = f_final_bg(verdict_7, finalScore_7))
            cf := cf + 1
        if summaryColVisible8
            table.cell(scr, cf, r, f_rank_marker(finalScore_8, qualifies8) + f_score_text(finalScore_8), text_color = black, text_size = sz, bgcolor = f_final_bg(verdict_8, finalScore_8))
            cf := cf + 1

        r := r + 1
        table.cell(scr, 0, r, "Moment", text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "TF1 momentum right now. RE-ACCEL = best (paused, now confirmed building again). BUILDING = good, less confirmed. FLAT = neutral. FADING = avoid, losing steam. EXTENDED = already stretched far, not a stop signal but be cautious entering right at the extreme.")
        int cm = 1
        if summaryColVisible1
            table.cell(scr, cm, r, momentum1, text_color = black, text_size = sz, bgcolor = f_momentum_bg(momentum1))
            cm := cm + 1
        if summaryColVisible2
            table.cell(scr, cm, r, momentum2, text_color = black, text_size = sz, bgcolor = f_momentum_bg(momentum2))
            cm := cm + 1
        if summaryColVisible3
            table.cell(scr, cm, r, momentum3, text_color = black, text_size = sz, bgcolor = f_momentum_bg(momentum3))
            cm := cm + 1
        if summaryColVisible4
            table.cell(scr, cm, r, momentum4, text_color = black, text_size = sz, bgcolor = f_momentum_bg(momentum4))
            cm := cm + 1
        if summaryColVisible5
            table.cell(scr, cm, r, momentum5, text_color = black, text_size = sz, bgcolor = f_momentum_bg(momentum5))
            cm := cm + 1
        if summaryColVisible6
            table.cell(scr, cm, r, momentum6, text_color = black, text_size = sz, bgcolor = f_momentum_bg(momentum6))
            cm := cm + 1
        if summaryColVisible7
            table.cell(scr, cm, r, momentum7, text_color = black, text_size = sz, bgcolor = f_momentum_bg(momentum7))
            cm := cm + 1
        if summaryColVisible8
            table.cell(scr, cm, r, momentum8, text_color = black, text_size = sz, bgcolor = f_momentum_bg(momentum8))
            cm := cm + 1

        if checklist_any_on
            r := r + 1
            table.cell(scr, 0, r, "Check", text_color = labelText, text_size = sz, bgcolor = labelBg, tooltip = "How many of your enabled Checklist items currently pass for this instrument. ✅ = all of them; 🛑 = at least one failed — hover the cell itself to see which.")
            int ck = 1
            if summaryColVisible1
                table.cell(scr, ck, r, f_check_text(isDxy1, verdict_1, check_p1, check_t1, streak1), text_color = black, text_size = sz, bgcolor = f_check_bg(verdict_1, check_p1, check_t1),
                     tooltip = f_check_tooltip(isDxy1, verdict_1, check_t1, chk1_on, chk1_pass, chk2_on, chk2_pass, chk3_on, chk3_pass, chk4_on, f_check4_pass(verdict_1, usdBase1), chk5_on, f_check5_pass(verdict_1, trendScore_1), chk6_on, f_check6_pass(verdict_1, entryScore_1), chk7_on, f_check7_pass(f1_1, f1_2, f1_3), chk8_on, f_check8_pass(beta_1), chk9_on, f_check9_pass(w1_1, w1_2, w1_3)))
                ck := ck + 1
            if summaryColVisible2
                table.cell(scr, ck, r, f_check_text(isDxy2, verdict_2, check_p2, check_t2, streak2), text_color = black, text_size = sz, bgcolor = f_check_bg(verdict_2, check_p2, check_t2),
                     tooltip = f_check_tooltip(isDxy2, verdict_2, check_t2, chk1_on, chk1_pass, chk2_on, chk2_pass, chk3_on, chk3_pass, chk4_on, f_check4_pass(verdict_2, usdBase2), chk5_on, f_check5_pass(verdict_2, trendScore_2), chk6_on, f_check6_pass(verdict_2, entryScore_2), chk7_on, f_check7_pass(f2_1, f2_2, f2_3), chk8_on, f_check8_pass(beta_2), chk9_on, f_check9_pass(w2_1, w2_2, w2_3)))
                ck := ck + 1
            if summaryColVisible3
                table.cell(scr, ck, r, f_check_text(isDxy3, verdict_3, check_p3, check_t3, streak3), text_color = black, text_size = sz, bgcolor = f_check_bg(verdict_3, check_p3, check_t3),
                     tooltip = f_check_tooltip(isDxy3, verdict_3, check_t3, chk1_on, chk1_pass, chk2_on, chk2_pass, chk3_on, chk3_pass, chk4_on, f_check4_pass(verdict_3, usdBase3), chk5_on, f_check5_pass(verdict_3, trendScore_3), chk6_on, f_check6_pass(verdict_3, entryScore_3), chk7_on, f_check7_pass(f3_1, f3_2, f3_3), chk8_on, f_check8_pass(beta_3), chk9_on, f_check9_pass(w3_1, w3_2, w3_3)))
                ck := ck + 1
            if summaryColVisible4
                table.cell(scr, ck, r, f_check_text(isDxy4, verdict_4, check_p4, check_t4, streak4), text_color = black, text_size = sz, bgcolor = f_check_bg(verdict_4, check_p4, check_t4),
                     tooltip = f_check_tooltip(isDxy4, verdict_4, check_t4, chk1_on, chk1_pass, chk2_on, chk2_pass, chk3_on, chk3_pass, chk4_on, f_check4_pass(verdict_4, usdBase4), chk5_on, f_check5_pass(verdict_4, trendScore_4), chk6_on, f_check6_pass(verdict_4, entryScore_4), chk7_on, f_check7_pass(f4_1, f4_2, f4_3), chk8_on, f_check8_pass(beta_4), chk9_on, f_check9_pass(w4_1, w4_2, w4_3)))
                ck := ck + 1
            if summaryColVisible5
                table.cell(scr, ck, r, f_check_text(isDxy5, verdict_5, check_p5, check_t5, streak5), text_color = black, text_size = sz, bgcolor = f_check_bg(verdict_5, check_p5, check_t5),
                     tooltip = f_check_tooltip(isDxy5, verdict_5, check_t5, chk1_on, chk1_pass, chk2_on, chk2_pass, chk3_on, chk3_pass, chk4_on, f_check4_pass(verdict_5, usdBase5), chk5_on, f_check5_pass(verdict_5, trendScore_5), chk6_on, f_check6_pass(verdict_5, entryScore_5), chk7_on, f_check7_pass(f5_1, f5_2, f5_3), chk8_on, f_check8_pass(beta_5), chk9_on, f_check9_pass(w5_1, w5_2, w5_3)))
                ck := ck + 1
            if summaryColVisible6
                table.cell(scr, ck, r, f_check_text(isDxy6, verdict_6, check_p6, check_t6, streak6), text_color = black, text_size = sz, bgcolor = f_check_bg(verdict_6, check_p6, check_t6),
                     tooltip = f_check_tooltip(isDxy6, verdict_6, check_t6, chk1_on, chk1_pass, chk2_on, chk2_pass, chk3_on, chk3_pass, chk4_on, f_check4_pass(verdict_6, usdBase6), chk5_on, f_check5_pass(verdict_6, trendScore_6), chk6_on, f_check6_pass(verdict_6, entryScore_6), chk7_on, f_check7_pass(f6_1, f6_2, f6_3), chk8_on, f_check8_pass(beta_6), chk9_on, f_check9_pass(w6_1, w6_2, w6_3)))
                ck := ck + 1
            if summaryColVisible7
                table.cell(scr, ck, r, f_check_text(isDxy7, verdict_7, check_p7, check_t7, streak7), text_color = black, text_size = sz, bgcolor = f_check_bg(verdict_7, check_p7, check_t7),
                     tooltip = f_check_tooltip(isDxy7, verdict_7, check_t7, chk1_on, chk1_pass, chk2_on, chk2_pass, chk3_on, chk3_pass, chk4_on, f_check4_pass(verdict_7, usdBase7), chk5_on, f_check5_pass(verdict_7, trendScore_7), chk6_on, f_check6_pass(verdict_7, entryScore_7), chk7_on, f_check7_pass(f7_1, f7_2, f7_3), chk8_on, f_check8_pass(beta_7), chk9_on, f_check9_pass(w7_1, w7_2, w7_3)))
                ck := ck + 1
            if summaryColVisible8
                table.cell(scr, ck, r, f_check_text(isDxy8, verdict_8, check_p8, check_t8, streak8), text_color = black, text_size = sz, bgcolor = f_check_bg(verdict_8, check_p8, check_t8),
                     tooltip = f_check_tooltip(isDxy8, verdict_8, check_t8, chk1_on, chk1_pass, chk2_on, chk2_pass, chk3_on, chk3_pass, chk4_on, f_check4_pass(verdict_8, usdBase8), chk5_on, f_check5_pass(verdict_8, trendScore_8), chk6_on, f_check6_pass(verdict_8, entryScore_8), chk7_on, f_check7_pass(f8_1, f8_2, f8_3), chk8_on, f_check8_pass(beta_8), chk9_on, f_check9_pass(w8_1, w8_2, w8_3)))
                ck := ck + 1

    else if summary_on or medals_only_on
        table empty = table.new(f_pos(db_position_s), 1, 1, border_width = 1, border_color = gray, frame_color = gray, frame_width = 1)
        table.cell(empty, 0, 0, "No candidates right now", text_color = black, text_size = f_size(db_size_s), bgcolor = white)

    if market_stability_on
        table stabDash = table.new(f_pos(market_stability_position), 1, 1, border_width = 1, border_color = gray, frame_color = gray, frame_width = 1)
        table.cell(stabDash, 0, 0, "Market Stab   " + f_stability_chain(marketStabHist, marketStability), text_color = black, text_size = f_size(db_size_s), bgcolor = white, tooltip = "0-100 diagnostic: how trustworthy the current picture looks across ALL configured instruments at once, not any single one. Combines medalist-composition steadiness, DXY-correlation breadth, trend breadth, and how long 3+ medalists have held at once. Shows the bar-to-bar CHANGE for recent closed TF1 bars, then the current value at the end — locked to TF1's own bar close, same reading regardless of what timeframe the chart itself is on. NOT a filter — purely a read on whether it's a settled or a still-shifting market moment.")
````
