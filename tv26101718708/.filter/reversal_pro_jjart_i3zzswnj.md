# Reversal Pro | jjart

- url: https://www.tradingview.com/script/i3ZZSWnj-reversal-pro-jjart/
- type: indicator
- pine_id: PUB;497900528ea646959fb638462a9b602b
- version: 1.0

## Description

Reversal Pro hunts liquidity-sweep reversals and lets a machine-learning model decide which sweeps are worth acting on. The model is trained directly on your chart — on the exact symbol and timeframe you run it on — and retrains on a schedule as new bars arrive, so its scoring adapts to the instrument's current behavior instead of relying on fixed thresholds.

HOW IT WORKS

Trigger — pivot sweep. A candle takes out the lowest low (for longs) or highest high (for shorts) of the previous 8 bars and closes back in the opposite half of its own range — the classic stop-hunt / liquidity-sweep reversal footprint. Only these bars are candidates; the ML never fires in the middle of nowhere.
Features. Four context features are computed on the closed bar: RSI(14), relative volume (vs its 20-bar average), price Z-score over 20 bars, and ADX(14).
Models. Two independent model pairs — one for longs, one for shorts — each consisting of a classifier and a regressor built with the open-source Arbor gradient-boosting library by GainzAlgo:
the classifier's training target is "did price move at least 1 ATR in the trade direction within the next 15 bars?" — its output is the probability you see on the signal label;
the regressor's target is the actual forward excursion in ATR units — it drives the far take-profit (TP3). Models retrain every 75 bars on the last 500 bars (both configurable). Features are paired strictly with outcomes of already-closed forward windows, so training uses no lookahead.
Filters. A signal fires only when ALL of these pass: model score ≥ threshold (80% by default); the chosen direction's score exceeds the opposite one by a minimum edge (rejects "both sides look good" noise); ADX is inside the 12–38 regime window (no dead chop, no runaway trend); a cooldown has passed since the last signal. Optional extra filters (all OFF by default): CCI confirmation — a long requires a recent oversold CCI (≤ −100 within the last 3 bars), a short requires overbought; EMA trend filter — "with trend" takes longs only above the EMA(200) and shorts below it (pullback reversals), "counter-trend" does the opposite (fading stretched price back to the EMA); relative-volume floor — the signal bar's volume must be at least N× its 20-bar average.
No repaint. Signals are confirmed on bar close only — a printed mark never moves or disappears. Target/stop hits are evaluated on confirmed bars as well.
RISK MODULE

Stop-loss is anchored behind the signal bar's wick (the sweep extreme) plus a small ATR buffer; a minimum stop distance of 0.5 ATR is enforced.
TP1 = 1R (a true 1:1 to the initial risk, configurable). When TP1 is touched, the stop moves to entry (break-even, optional).
TP3 = the regressor's predicted excursion × ATR, floored at 2R so it never prints an unreasonably close target. TP2 = halfway between TP1 and TP3.
Level lines recolor as they fill; the trade completes at TP3 or at the stop. A stop hit after the break-even move is reported as a break-even exit, not a loss.
CHART OBJECTS & DASHBOARD

▲/▼ marks at the signal bar show the exact model score (e.g. 84.3%); 90%+ signals use the highlight color; the tooltip shows score, directional edge, ADX, RSI, CCI and the expected TP3 distance in R at signal time. The signal bar's background is softly tinted, and the Entry/SL/TP lines carry small price tags. Language: input names are bilingual (Russian / English); everything drawn on the chart — dashboard, statuses, level tags, tooltips — switches between English and Russian via the "🌐 Язык / Chart language" input. The dashboard shows: BIAS (higher-scored direction), GRADE (TRADE 80+ / WATCH 70-79 / NO EDGE) with the long-vs-short EDGE gap, LONG/SHORT scores, ADX vs its allowed window, RSI/RelVol, FEATURES (the model's live feature-importance split), FILTER status (READY / COOLDOWN / OFF-REGIME / TRAINING / IN TRADE), and STATS — live outcome statistics of completed signals on the chart (% reaching TP1 and TP3, % stopped out, % break-even).

HOW TO USE

Add to a liquid symbol; intraday timeframes 5m–1H work best. Let the model load history — the dashboard shows TRAINING until it has ~500 bars, then READY.
Wait for a ▲/▼ mark with the score. Entry reference is the close of the signal bar; SL/TP levels are drawn automatically.
Alerts are available for long/short entries, TP1/TP2/TP3, stop-loss and break-even exit.
Presets: 🕊 Relaxed (more signals) — score 0.70–0.75, edge 0.03–0.05, cooldown 5, ADX 10–45; 🔒 Strict (fewer, cleaner) — score 0.85–0.90, edge 0.10–0.15, cooldown 15–20, ADX 15–35. Every input's tooltip carries both recommendations.
WHAT IS ORIGINAL HERE / OPEN-SOURCE REUSE

The Arbor gradient-boosting library © GainzAlgo (MPL 2.0) provides the raw fit/predict algorithm and is credited in the code header. Everything trading-related is original: the pivot-sweep trigger gating the ML, the ATR-normalized forward-excursion labels and leak-free feature/label pairing, dual long/short model pairs with the directional edge filter, the ADX regime window, the bar-close no-repaint policy, the wick-anchored risk ladder with the model-driven TP3, break-even handling separated from stop-losses, the live hit-rate statistics, and the dashboard/labels/alerts layer.

DISCLAIMER

This is an analysis tool, not financial advice. Past performance of signals does not guarantee future results. Always manage your risk.

Описание — RU 
Reversal Pro — разворотный индикатор, в котором каждый пивот-свип оценивается моделью машинного обучения, обучающейся прямо на вашем графике (конкретный инструмент и таймфрейм) и регулярно переобучающейся под текущий характер рынка.

Как рождается сигнал: (1) бар снимает 8-барный экстремум и закрывается в противоположной половине диапазона — классический вынос ликвидности; (2) модель оценивает контекст по 4 признакам: RSI(14), относительный объём, Z-score цены, ADX; для лонга и шорта — отдельные пары «классификатор + регрессор» (библиотека Arbor © GainzAlgo); таргет классификатора — «прошла ли цена ≥1 ATR в сторону сделки за следующие 15 баров», таргет регрессора — фактический ход в ATR; переобучение каждые 75 баров на последних 500, без заглядывания в будущее; (3) фильтры: скор ≥80%, перевес над противоположным направлением, ADX в окне 12–38, пауза между сигналами; опциональные доп. фильтры (по умолчанию выкл): подтверждение CCI (перепроданность/перекупленность рядом с сигналом), трендовый фильтр EMA (по тренду / контртренд), минимальный относительный объём сигнального бара; (4) подтверждение только на закрытии бара — без перерисовки.

Язык: названия настроек двуязычные (рус/англ), вся графика — таблица, статусы, ценники уровней, подсказки — переключается тумблером «🌐 Язык / Chart language».

Риск-модуль: SL за фитилём сигнального бара + запас ×ATR (минимум 0.5 ATR); TP1 = 1R с переносом в безубыток; TP3 = прогноз регрессора с нижней планкой 2R; TP2 — середина. Стоп после переноса в БУ считается безубытком, а не лоссом.

На графике: метки ▲/▼ с точным скором (90%+ подсвечиваются), линии Entry/SL/TP с перекраской при достижении, дашборд (скоры, BIAS/EDGE/GRADE, режим ADX, важность признаков, статус движка, живая статистика отработки TP1/TP3/SL/BE) и алерты на все события.

Пресеты: 🕊 мягкий (больше сигналов) — скор 0.70–0.75, перевес 0.03–0.05, пауза 5, ADX 10–45; 🔒 строгий — скор 0.85–0.90, перевес 0.10–0.15, пауза 15–20, ADX 15–35.

Дисклеймер: инструмент анализа, не финансовая рекомендация. Управляйте риском.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// Reversal Pro | jjart — ML Reversal Signals (Gradient Boosting)
// Author: jjart
//
// ── Credits / open-source reuse ─────────────────────────────────────────────
// Machine-learning core: "Arbor" gradient-boosting library © GainzAlgo (MPL 2.0),
// imported as GainzAlgo/Arbor_Gradient_Boosting_GainzAlgo/1. The library provides
// the raw fit/predict boosting algorithm only.
// Everything trading-related is original work by jjart:
//  • pivot-sweep trigger that gates the ML scoring (8-bar liquidity sweep + close
//    back inside the range);
//  • dual long/short model pairs (classifier + regressor each) with a directional
//    edge filter that rejects ambiguous both-sides-look-good states;
//  • ATR-normalized forward-excursion training labels, strict feature/label pairing
//    on closed bars (no lookahead), scheduled retraining;
//  • ADX regime window, optional CCI / EMA-trend / relative-volume filters,
//    signal cooldown, bar-close confirmation (no repaint);
//  • wick-anchored SL with minimum stop distance, 1R TP1 + break-even engine,
//    regressor-driven TP3 with an R-multiple floor, TP2 midpoint;
//  • live outcome statistics (TP1/TP3/SL/BE hit rates), bilingual dashboard,
//    score labels, level price tags, entry/target/stop alerts.
// ─────────────────────────────────────────────────────────────────────────────
//
// v1.4 (2026-07-16) — двуязычная сборка + доп. фильтры:
//  • Переключатель «Язык / Language»: вся графика (таблица, статусы, подписи
//    уровней, подсказки меток) на русском или английском. Названия настроек
//    двуязычные всегда (ограничение Pine: заголовки инпутов нельзя менять на лету).
//  • Доп. фильтры (все опциональны, по умолчанию выкл): подтверждение CCI
//    (перепроданность/перекупленность рядом с сигналом), фильтр тренда EMA
//    (по тренду / контртренд), фильтр относительного объёма сигнального бара.
//  • Подписи цен у уровней Entry/SL/TP, подсветка фона сигнального бара,
//    в тултипе метки — ожидаемая цель в R и CCI; CCI также в дашборде.
// v1.3 (2026-07-16) — строка STATS в дашборде (TP1/TP3/SL/BE), отдельный алерт
//    «Безубыток»: стоп после переноса в БУ больше не считается стоп-лоссом.
// v1.2 (2026-07-12) — русские настройки с рекомендациями, метки-треугольники
//    остриём в бар, расшифровка дашборда в подсказке.
// v1.1 (2026-07-12) — убран scale.none (метки «плыли» при прокрутке), метки с точным
//    скором, дашборд, завершение сделки по TP3, хранение прошлых уровней (опция).
//@version=6
indicator("Reversal Pro | jjart", overlay = true, max_boxes_count = 20, max_lines_count = 500, max_labels_count = 500, max_bars_back = 750, calc_bars_count = 10000)

// Imports
import GainzAlgo/Arbor_Gradient_Boosting_GainzAlgo/1 as arbor

GRP_MDL  = "⚙️ ML-модель / ML Model"
GRP_FLT  = "🔎 Доп. фильтры / Extra Filters"
GRP_RISK = "🛡️ Риск / Risk"
GRP_VIS  = "🎨 Визуал и таблица / Visuals & Dashboard"

// Tooltips (RU + EN)
lang_tip = "Переключает язык всего, что рисуется на графике: таблица, статусы, подписи уровней, подсказки меток. Названия настроек всегда двуязычные — Pine не умеет менять их на лету.\n———\nEN: Switches the language of everything drawn on the chart: dashboard, statuses, level tags, label tooltips. Input names stay bilingual — Pine cannot change them at runtime."
train_tip = "Сколько последних баров модель использует при каждом переобучении. Больше баров — шире выборка и стабильнее модель, но тяжелее пересчёт.\n\n🕊 Мягкий: 300-400 (быстрее подстраивается). 🔒 Строгий: 500 (максимум статистики).\n———\nEN: Bars used for each retraining cycle. More = broader sample, stabler model, heavier compute. 🕊 Relaxed 300-400 · 🔒 Strict 500."
retrain_tip = "Раз в сколько баров модель заново обучается на свежих данных. Меньше — быстрее реагирует на смену рынка; больше — плавнее и стабильнее.\n\n🕊 Мягкий: 50. 🔒 Строгий: 100-150.\n———\nEN: How often (bars) the model retrains. Lower = faster adaptation, higher = smoother. 🕊 Relaxed 50 · 🔒 Strict 100-150."
rounds_tip = "Число деревьев (итераций бустинга). Больше — модель ловит сложнее закономерности, но растёт риск подгонки под шум.\n\n🕊 Мягкий: 15. 🔒 Строгий: 25-30 (при глубине 400+).\n———\nEN: Boosting rounds (trees). More = complex patterns but overfitting risk. 🕊 Relaxed 15 · 🔒 Strict 25-30 (with 400+ lookback)."
lr_tip = "Шаг обучения каждого раунда. Ниже — осторожнее и стабильнее; выше — быстрее, но возможна переподгонка.\n\n🕊 Мягкий: 0.3. 🔒 Строгий: 0.15-0.2 (с 25-30 раундами).\n———\nEN: Learning rate per round. Lower = stabler, higher = faster but may overfit. 🕊 Relaxed 0.3 · 🔒 Strict 0.15-0.2."
prob_tip = "Минимальная уверенность модели для сигнала (0.80 = 80%). Выше — реже, но чище; ниже — чаще, но больше ложных.\n\n🕊 Мягкий: 0.70-0.75. 🔒 Строгий: 0.85-0.90.\n———\nEN: Minimum model confidence for a signal. 🕊 Relaxed 0.70-0.75 · 🔒 Strict 0.85-0.90."
edge_tip = "Насколько скор выбранного направления должен превышать противоположный. Отсекает ситуации «модель видит и лонг, и шорт».\n\n🕊 Мягкий: 0.03-0.05. 🔒 Строгий: 0.10-0.15.\n———\nEN: Required gap between the chosen direction's score and the opposite one. 🕊 Relaxed 0.03-0.05 · 🔒 Strict 0.10-0.15."
cooldown_tip = "Минимум баров между входами — защита от серии сигналов на одном движении.\n\n🕊 Мягкий: 5. 🔒 Строгий: 15-20.\n———\nEN: Minimum bars between entries. 🕊 Relaxed 5 · 🔒 Strict 15-20."
repaint_tip = "ВКЛ: сигнал появляется только после закрытия бара и никогда не исчезнет (нет перерисовки). ВЫКЛ: сигнал может появиться на живом баре, но способен пропасть до закрытия.\n\n✅ Рекомендация: всегда ВКЛ.\n———\nEN: ON = signals confirm on bar close only, never repaint. ✅ Keep ON."
adxlen_tip = "Период ADX для фильтра режима рынка. Стандарт 14.\n———\nEN: ADX period for the regime filter. Standard 14."
adxmin_tip = "Сигналы только при ADX выше — отсекает мёртвый флэт.\n\n🕊 Мягкий: 10. 🔒 Строгий: 15-18.\n———\nEN: Signals only above this ADX — filters dead chop. 🕊 10 · 🔒 15-18."
adxmax_tip = "Сигналы только при ADX ниже — не ловим разворот против разогнавшегося тренда.\n\n🕊 Мягкий: 45. 🔒 Строгий: 30-35.\n———\nEN: Signals only below this ADX — no fading runaway trends. 🕊 45 · 🔒 30-35."
cci_tip = "Подтверждение осциллятором: лонг проходит, только если CCI недавно был в перепроданности (≤ −уровень), шорт — в перекупленности (≥ +уровень).\n\n🕊 Мягче: уровень 80. 🔒 Строже: 120-150.\n———\nEN: Oscillator confirmation: long requires a recent oversold CCI (≤ −level), short — overbought (≥ +level). 🕊 level 80 · 🔒 120-150."
ccilen_tip = "Период CCI.\n———\nEN: CCI length."
ccilvl_tip = "Порог перепроданности/перекупленности CCI.\n———\nEN: CCI oversold/overbought threshold."
ccibars_tip = "За сколько последних баров ищем экстремум CCI.\n———\nEN: How many recent bars to scan for the CCI extreme."
ema_tip = "«По тренду»: лонги только выше EMA, шорты только ниже — ловим развороты-откаты в сторону тренда. «Контртренд»: наоборот — возврат растянутой цены к EMA.\n———\nEN: \"With trend\": longs only above the EMA, shorts below (pullback reversals with the trend). \"Counter-trend\": the opposite — fading stretched price back to the EMA."
emalen_tip = "Период EMA трендового фильтра.\n———\nEN: EMA length for the trend filter."
vol_tip = "Сигнал проходит, только если относительный объём сигнального бара не ниже порога — вынос на объёме надёжнее.\n\n🕊 Мягче: 1.0-1.2. 🔒 Строже: 1.5-2.0.\n———\nEN: Signal passes only if the signal bar's relative volume is at or above the floor. 🕊 1.0-1.2 · 🔒 1.5-2.0."
minvol_tip = "Порог относительного объёма (1.0 = средний за 20 баров).\n———\nEN: Relative-volume floor (1.0 = 20-bar average)."
slbuffer_tip = "Стоп за экстремумом (фитилём) сигнального бара плюс запас в долях ATR. Держи небольшим — смысл в привязке риска к фитилю.\n\n🕊 Мягкий (шире): 0.4-0.5. 🔒 Строгий (короче): 0.15-0.25.\n———\nEN: Stop beyond the signal bar's wick plus this ATR buffer. 🕊 0.4-0.5 · 🔒 0.15-0.25."
tp1r_tip = "Первая цель в множителях риска. 1.0 = честный 1:1, не зависит от прогноза модели.\n\n🕊 Мягкий: 0.7-0.8. 🔒 Строгий: 1.0-1.5.\n———\nEN: TP1 as an R-multiple of initial risk; 1.0 = true 1:1. 🕊 0.7-0.8 · 🔒 1.0-1.5."
tp3floor_tip = "Нижняя планка TP3. Берётся БОЛЬШЕЕ из: прогноз модели (×ATR) и риск × планка. TP3 не бывает ближе разумного R:R, но тянется дальше при сильном прогнозе.\n\n🕊 Мягкий: 1.5. 🔒 Строгий: 2.5-3.0.\n———\nEN: TP3 floor: the larger of the model's predicted excursion and risk × floor is used. 🕊 1.5 · 🔒 2.5-3.0."
be_tip = "После касания TP1 стоп переносится на вход — остаток позиции не уйдёт в минус.\n\n✅ Рекомендация: ВКЛ.\n———\nEN: After TP1 the stop moves to entry. ✅ Keep ON."
bull_tip = "Цвет бычьих сигналов и целей лонга.\n———\nEN: Color of bullish signals and long targets."
bear_tip = "Цвет медвежьих сигналов и целей шорта.\n———\nEN: Color of bearish signals and short targets."
hit_tip = "Цвет достигнутых целей и сигналов 90%+.\n———\nEN: Color of filled targets and 90%+ signals."
lblsize_tip = "Размер треугольника и процента у сигнального бара.\n———\nEN: Size of the signal triangle and score text."
hl_tip = "Слегка подкрашивает фон сигнального бара в цвет направления.\n———\nEN: Softly tints the signal bar's background in the direction color."
tags_tip = "Маленькие подписи Вход/SL/TP1-TP3 с ценой у правого края линий.\n———\nEN: Small Entry/SL/TP tags with prices at the right end of the level lines."
history_tip = "ВКЛ: линии завершённых сделок остаются на графике (до лимита 500). ВЫКЛ: удаляются при новом сигнале.\n———\nEN: ON keeps finished trades' lines on the chart; OFF deletes them on a new signal."
dash_tip = "Таблица состояния. Строки: НАПРАВЛ/BIAS — направление с большим скором; ОЦЕНКА/GRADE — качество момента (ТОРГУЕМ 80+ / СМОТРИМ 70-79 / НЕТ СЕТАПА) и ПЕРЕВЕС/EDGE — разрыв скоров лонг-шорт; ЛОНГ и ШОРТ — скоры направлений (АКТИВЕН = ведётся сделка); ADX — сила тренда и рабочее окно (красный = сигналы заблокированы); RSI / RelVol / CCI — текущие значения; ПРИЗНАКИ/FEATURES — вклад признаков в решения модели; ФИЛЬТР/FILTER — порог скора и статус (ГОТОВ / ПАУЗА / ВНЕ РЕЖИМА / ОБУЧЕНИЕ / В СДЕЛКЕ); ПАМЯТКА/GUIDE — 70+ наблюдать, 80+ торговать; СТАТА/STATS — статистика завершённых сигналов: % до TP1 и TP3, % по стопу (SL) и в безубыток (БУ/BE), в скобках — их число.\n———\nEN: Status table. BIAS — higher-scored direction; GRADE — setup quality + EDGE (long-short score gap); LONG/SHORT — direction scores (ACTIVE = trade tracked); ADX — trend strength vs allowed window (red = blocked); RSI/RelVol/CCI — current values; FEATURES — model feature importance; FILTER — score threshold and engine status (READY/COOLDOWN/OFF-REGIME/TRAINING/IN TRADE); GUIDE — 70+ watch, 80+ trade; STATS — completed-signal outcomes: % to TP1/TP3, % stopped (SL), % break-even (BE), count in brackets."
dashpos_tip = "Угол графика для таблицы.\n———\nEN: Chart corner for the table."

// UI
langInput         = input.string("Русский", "🌐 Язык графики / Chart language", options = ["Русский", "English"], tooltip = lang_tip)
bool isRu = langInput == "Русский"

// Model params
lookbackInput     = input.int(500, "Глубина обучения (баров) / Training lookback", group = GRP_MDL, minval = 150, maxval = 500, tooltip = train_tip)
retrainFreqInput  = input.int(75, "Частота переобучения / Retrain frequency", group = GRP_MDL, minval = 25, maxval = 250, tooltip = retrain_tip)
nRoundsInput      = input.int(20, "Раунды бустинга / Boosting rounds", group = GRP_MDL, minval = 5, maxval = 40, tooltip = rounds_tip)
lrInput           = input.float(0.3, "Скорость обучения / Learning rate", step = 0.05, group = GRP_MDL, tooltip = lr_tip)
probThreshInput   = input.float(0.80, "Мин. скор для сигнала / Min model score", step = 0.01, minval = 0.50, maxval = 0.99, group = GRP_MDL, tooltip = prob_tip)
minEdgeInput      = input.float(0.08, "Мин. перевес направления / Min directional edge", step = 0.01, minval = 0.00, maxval = 0.50, group = GRP_MDL, tooltip = edge_tip)
cooldownBarsInput = input.int(10, "Пауза между сигналами / Signal cooldown (bars)", minval = 0, maxval = 100, group = GRP_MDL, tooltip = cooldown_tip)
waitForCloseInput = input.bool(true, "Подтверждение на закрытии (без перерисовки) / Confirm on close (no repaint)", group = GRP_MDL, tooltip = repaint_tip)

// ADX regime filter
adxLenInput       = input.int(14, "Период ADX / ADX length", group = GRP_MDL, tooltip = adxlen_tip)
adxMinInput       = input.float(12.0, "ADX минимум / ADX minimum", step = 1.0, group = GRP_MDL, tooltip = adxmin_tip)
adxMaxInput       = input.float(38.0, "ADX максимум / ADX maximum", step = 1.0, group = GRP_MDL, tooltip = adxmax_tip)

// Extra filters (all optional, default OFF)
useCciInput       = input.bool(false, "Фильтр CCI / CCI confirmation", group = GRP_FLT, tooltip = cci_tip)
cciLenInput       = input.int(20, "Период CCI / CCI length", group = GRP_FLT, minval = 5, tooltip = ccilen_tip)
cciLevelInput     = input.float(100, "Уровень CCI / CCI level", group = GRP_FLT, step = 10, minval = 50, tooltip = ccilvl_tip)
cciBarsInput      = input.int(3, "Окно CCI (баров) / CCI window (bars)", group = GRP_FLT, minval = 1, maxval = 10, tooltip = ccibars_tip)
emaModeInput      = input.string("Выкл / Off", "Фильтр EMA / EMA filter", options = ["Выкл / Off", "По тренду / With trend", "Контртренд / Counter-trend"], group = GRP_FLT, tooltip = ema_tip)
emaLenInput       = input.int(200, "Период EMA / EMA length", group = GRP_FLT, minval = 20, tooltip = emalen_tip)
useVolFilterInput = input.bool(false, "Фильтр объёма / Volume filter", group = GRP_FLT, tooltip = vol_tip)
minRelVolInput    = input.float(1.2, "Мин. отн. объём / Min relative volume", group = GRP_FLT, step = 0.1, minval = 0.5, tooltip = minvol_tip)

// Risk
slAtrMultInput    = input.float(0.25, "Запас SL за фитилём (×ATR) / SL wick buffer", step = 0.05, group = GRP_RISK, tooltip = slbuffer_tip)
tp1RInput         = input.float(1.0, "TP1 (×риск, R) / TP1 (×risk)", step = 0.1, group = GRP_RISK, tooltip = tp1r_tip)
tp3FloorRInput    = input.float(2.0, "TP3 минимум (×риск) / TP3 floor (×risk)", step = 0.25, group = GRP_RISK, tooltip = tp3floor_tip)
useBreakEvenInput = input.bool(true, "Безубыток после TP1 / Break-even after TP1", group = GRP_RISK, tooltip = be_tip)

// Visuals
bullColor         = input.color(#7FC7B8, "Цвет лонга / Bullish", group = GRP_VIS, tooltip = bull_tip)
bearColor         = input.color(#D59AA8, "Цвет шорта / Bearish", group = GRP_VIS, tooltip = bear_tip)
hitColor          = input.color(#B7D6E8, "Взятая цель, 90%+ / Target hit, 90%+", group = GRP_VIS, tooltip = hit_tip)
lblSizeInput      = input.string("Средний / Small", "Размер меток / Label size", options = ["Мелкий / Tiny", "Средний / Small", "Крупный / Normal"], group = GRP_VIS, tooltip = lblsize_tip)
highlightBarInput = input.bool(true, "Подсветка сигнального бара / Highlight signal bar", group = GRP_VIS, tooltip = hl_tip)
showLevelTagsInput = input.bool(true, "Ценники у уровней / Price tags on levels", group = GRP_VIS, tooltip = tags_tip)
keepHistoryInput  = input.bool(false, "Хранить уровни прошлых сделок / Keep past trade levels", group = GRP_VIS, tooltip = history_tip)
showDashInput     = input.bool(true, "Показывать таблицу / Show dashboard", group = GRP_VIS, tooltip = dash_tip)
dashPosInput      = input.string("Справа снизу / Bottom right", "Положение таблицы / Dashboard position", options = ["Справа снизу / Bottom right", "Справа сверху / Top right", "Слева сверху / Top left", "Слева снизу / Bottom left"], group = GRP_VIS, tooltip = dashpos_tip)

string lblSize = lblSizeInput == "Мелкий / Tiny" ? size.tiny : lblSizeInput == "Крупный / Normal" ? size.normal : size.small

// Feature engineering and targets
float atr = math.max(ta.atr(14), 0.0001)
[_, _, adx] = ta.dmi(adxLenInput, adxLenInput)

float f1 = ta.rsi(close, 14)
float f2 = nz(volume / ta.sma(volume, 20), 1.0) // Relative Volume
float f3 = (close - ta.sma(close, 20)) / math.max(ta.stdev(close, 20), 0.0001) // Z-Score
float f4 = adx // ADX is actively used as feature #4

bool isValid = not (na(f1) or na(f2) or na(f3) or na(f4))

int   fwdWindow = 15
float futureMax = ta.highest(high, fwdWindow)
float futureMin = ta.lowest(low, fwdWindow)

// long
float targClsLong = (futureMax[1] - close[fwdWindow]) > (atr[fwdWindow] * 1.0) ? 1.0 : 0.0
float targRegLong = math.max((futureMax[1] - close[fwdWindow]) / atr[fwdWindow], 0.0)

// short
float targClsShort = (close[fwdWindow] - futureMin[1]) > (atr[fwdWindow] * 1.0) ? 1.0 : 0.0
float targRegShort = math.max((close[fwdWindow] - futureMin[1]) / atr[fwdWindow], 0.0)

// Extra filter series
float cciVal = ta.cci(hlc3, cciLenInput)
float emaVal = ta.ema(close, emaLenInput)
bool  emaWith    = emaModeInput == "По тренду / With trend"
bool  emaCounter = emaModeInput == "Контртренд / Counter-trend"

bool cciOkLong  = not useCciInput or ta.lowest(cciVal, cciBarsInput) <= -cciLevelInput
bool cciOkShort = not useCciInput or ta.highest(cciVal, cciBarsInput) >= cciLevelInput
bool emaOkLong  = emaWith ? close > emaVal : emaCounter ? close < emaVal : true
bool emaOkShort = emaWith ? close < emaVal : emaCounter ? close > emaVal : true
bool volOk      = not useVolFilterInput or f2 >= minRelVolInput

plot(emaWith or emaCounter ? emaVal : na, "EMA фильтр / EMA filter", color = color.new(#C9A66B, 40))

// Training
var array<float> arrF1 = array.new<float>()
var array<float> arrF2 = array.new<float>()
var array<float> arrF3 = array.new<float>()
var array<float> arrF4 = array.new<float>()
var array<float> arrTClsL = array.new<float>()
var array<float> arrTRegL = array.new<float>()
var array<float> arrTClsS = array.new<float>()
var array<float> arrTRegS = array.new<float>()

var arbor.GBM4 modelClsL = na
var arbor.GBM4 modelRegL = na
var arbor.GBM4 modelClsS = na
var arbor.GBM4 modelRegS = na

var array<float> featRecent = array.new<float>()
var array<float> impPct = array.new<float>(4, 25.0)

// Performance + no-repaint on retrain cadence:
// only evaluate/retrain once the bar is closed, instead of on every intrabar tick.
bool doTrain = bar_index % retrainFreqInput == 0 and bar_index > lookbackInput and isValid and barstate.isconfirmed

if doTrain
    array.clear(arrF1), array.clear(arrF2), array.clear(arrF3), array.clear(arrF4)
    array.clear(arrTClsL), array.clear(arrTRegL), array.clear(arrTClsS), array.clear(arrTRegS), array.clear(featRecent)

    for i = lookbackInput to fwdWindow + 1
        // Features at offset i are paired with the label describing the OUTCOME of an
        // entry at that same bar: targClsLong[i - fwdWindow] (min index = 1, always a
        // closed bar since the loop bottoms out at fwdWindow + 1 -> no lookahead).
        int targIdx = i - fwdWindow
        if not (na(f1[i]) or na(f2[i]) or na(f3[i]) or na(f4[i])) and not (na(targClsLong[targIdx]) or na(targRegLong[targIdx]) or na(targClsShort[targIdx]) or na(targRegShort[targIdx]))
            array.push(arrF1, f1[i])
            array.push(arrF2, f2[i])
            array.push(arrF3, f3[i])
            array.push(arrF4, f4[i])
            array.push(arrTClsL, targClsLong[targIdx])
            array.push(arrTRegL, targRegLong[targIdx])
            array.push(arrTClsS, targClsShort[targIdx])
            array.push(arrTRegS, targRegShort[targIdx])

    if array.size(arrTClsL) >= 20
        modelClsL := arbor.gbm4_fit(arrF1, arrF2, arrF3, arrF4, arrTClsL, n_rounds = nRoundsInput, lr = lrInput, is_classifier = true)
        modelRegL := arbor.gbm4_fit(arrF1, arrF2, arrF3, arrF4, arrTRegL, n_rounds = nRoundsInput, lr = lrInput, is_classifier = false)
        modelClsS := arbor.gbm4_fit(arrF1, arrF2, arrF3, arrF4, arrTClsS, n_rounds = nRoundsInput, lr = lrInput, is_classifier = true)
        modelRegS := arbor.gbm4_fit(arrF1, arrF2, arrF3, arrF4, arrTRegS, n_rounds = nRoundsInput, lr = lrInput, is_classifier = false)

        if not na(modelClsL) and not na(modelClsS)
            for fi = 0 to 3
                float impL = arbor.gbm4_importance_pct(modelClsL, fi)
                float impS = arbor.gbm4_importance_pct(modelClsS, fi)
                array.set(impPct, fi, (impL + impS) / 2.0)

        int dotN = math.min(array.size(arrF1), 30)
        for di = 0 to dotN - 1
            array.push(featRecent, array.get(arrF1, di) / 100.0)
            array.push(featRecent, math.min(array.get(arrF2, di) / 3.0, 1.0))
            array.push(featRecent, math.max(math.min(array.get(arrF3, di) / 4.0 + 0.5, 1.0), 0.0))
            array.push(featRecent, math.min(array.get(arrF4, di) / 100.0, 1.0)) // ADX normalization

// Predict
float probL = na, float regL = na
float probS = na, float regS = na

bool isBullPivot = low < ta.lowest(low, 8)[1] and close > low + (high - low) * 0.5
bool isBearPivot = high > ta.highest(high, 8)[1] and close < low + (high - low) * 0.5

// Predict both directions on the same closed feature vector.
// The directional score gap is used to reject ambiguous long/short states.
if not na(modelClsL) and not na(modelRegL) and not na(modelClsS) and not na(modelRegS) and isValid
    probL := arbor.gbm4_predict(modelClsL, f1, f2, f3, f4)
    regL  := arbor.gbm4_predict(modelRegL, f1, f2, f3, f4)
    probS := arbor.gbm4_predict(modelClsS, f1, f2, f3, f4)
    regS  := arbor.gbm4_predict(modelRegS, f1, f2, f3, f4)

    if na(regL) or regL < 0.0
        regL := 0.0
    if na(regS) or regS < 0.0
        regS := 0.0

float edgeL = not na(probL) and not na(probS) ? probL - probS : na
float edgeS = not na(probL) and not na(probS) ? probS - probL : na

bool adxRegimeOk = adx >= adxMinInput and adx <= adxMaxInput
var int lastSignalBar = na
bool cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBarsInput

bool fireLongRaw  = isBullPivot and not na(probL) and probL >= probThreshInput and edgeL >= minEdgeInput and adxRegimeOk and cooldownOk and cciOkLong and emaOkLong and volOk
bool fireShortRaw = isBearPivot and not na(probS) and probS >= probThreshInput and edgeS >= minEdgeInput and adxRegimeOk and cooldownOk and cciOkShort and emaOkShort and volOk

// Repaint prevention: isBullPivot/isBearPivot use the CURRENT bar's high/low/close, which
// are still live (can change) until the bar closes. Gating on barstate.isconfirmed means the
// signal, its lines/labels, and activeEntry/SL/TP levels are only committed once the triggering
// bar has actually closed, so nothing painted here can later change or vanish.
bool fireLong  = fireLongRaw  and (not waitForCloseInput or barstate.isconfirmed)
bool fireShort = fireShortRaw and (not waitForCloseInput or barstate.isconfirmed)

if fireLong or fireShort
    lastSignalBar := bar_index

// Signal bar background highlight
bgcolor(highlightBarInput and fireLong ? color.new(bullColor, 85) : highlightBarInput and fireShort ? color.new(bearColor, 85) : na, title = "Подсветка сигнала / Signal highlight")

// Trade tracking
var int   activeDir   = 0
var float activeEntry = na
var float activeSL    = na
var float activeTP1   = na
var float activeTP2   = na
var float activeTP3   = na
var int   activeEntryBar = na
var bool  beActive    = false
var bool  tp1Hit      = false
var bool  tp2Hit      = false
var bool  tp3Hit      = false

var line  lnEntry = na
var line  lnSL    = na
var line  lnTP1   = na
var line  lnTP2   = na
var line  lnTP3   = na

var label lbEntry = na
var label lbSL    = na
var label lbTP1   = na
var label lbTP2   = na
var label lbTP3   = na

// Alert event flags - reset every bar, only true on the exact bar the event happens
bool alertLongEntry  = false
bool alertShortEntry = false
bool alertTP1Hit     = false
bool alertTP2Hit     = false
bool alertTP3Hit     = false
bool alertSLHit      = false
bool alertBEExit     = false

// Signal outcome statistics (completed trades only; a trade superseded by a new
// signal before resolving is not counted)
var int statDone = 0
var int statTP1  = 0
var int statTP3  = 0
var int statSL   = 0
var int statBE   = 0

if fireLong or fireShort
    activeDir      := fireLong ? 1 : -1
    activeEntry    := close
    activeEntryBar := bar_index

    color themeColor = fireLong ? bullColor : bearColor

    if activeDir == 1
        float rawSL    = low - (atr * slAtrMultInput)
        float riskDist = activeEntry - rawSL
        if riskDist < atr * 0.5
            rawSL    := activeEntry - atr * 0.5
            riskDist := atr * 0.5
        activeSL := rawSL

        float mlObjective = math.max(regL * atr, riskDist * tp3FloorRInput)
        activeTP1 := activeEntry + riskDist * tp1RInput
        activeTP2 := activeEntry + (riskDist * tp1RInput + mlObjective) / 2.0
        activeTP3 := activeEntry + mlObjective
    else
        float rawSL    = high + (atr * slAtrMultInput)
        float riskDist = rawSL - activeEntry
        if riskDist < atr * 0.5
            rawSL    := activeEntry + atr * 0.5
            riskDist := atr * 0.5
        activeSL := rawSL

        float mlObjective = math.max(regS * atr, riskDist * tp3FloorRInput)
        activeTP1 := activeEntry - riskDist * tp1RInput
        activeTP2 := activeEntry - (riskDist * tp1RInput + mlObjective) / 2.0
        activeTP3 := activeEntry - mlObjective

    beActive := false
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false

    if not keepHistoryInput
        line.delete(lnEntry), line.delete(lnSL), line.delete(lnTP1), line.delete(lnTP2), line.delete(lnTP3)
        label.delete(lbEntry), label.delete(lbSL), label.delete(lbTP1), label.delete(lbTP2), label.delete(lbTP3)

    int x1 = bar_index
    int x2 = bar_index + 15
    lnEntry := line.new(x1, activeEntry, x2, activeEntry, color = color.new(color.white, 50), style = line.style_dotted)
    lnSL    := line.new(x1, activeSL, x2, activeSL, color = activeDir == 1 ? bearColor : bullColor, style = line.style_solid, width = 2)
    lnTP1   := line.new(x1, activeTP1, x2, activeTP1, color = color.new(themeColor, 40), style = line.style_dashed)
    lnTP2   := line.new(x1, activeTP2, x2, activeTP2, color = color.new(themeColor, 20), style = line.style_dashed)
    lnTP3   := line.new(x1, activeTP3, x2, activeTP3, color = themeColor, style = line.style_solid, width = 2)

    // Price tags at the right end of the level lines
    if showLevelTagsInput
        int tagX = x2 + 2
        lbEntry := label.new(tagX, activeEntry, (isRu ? "Вход " : "Entry ") + str.tostring(activeEntry, format.mintick), style = label.style_none, textcolor = color.new(color.white, 30), size = size.tiny)
        lbSL    := label.new(tagX, activeSL, "SL " + str.tostring(activeSL, format.mintick), style = label.style_none, textcolor = activeDir == 1 ? bearColor : bullColor, size = size.tiny)
        lbTP1   := label.new(tagX, activeTP1, "TP1 " + str.tostring(activeTP1, format.mintick), style = label.style_none, textcolor = color.new(themeColor, 30), size = size.tiny)
        lbTP2   := label.new(tagX, activeTP2, "TP2 " + str.tostring(activeTP2, format.mintick), style = label.style_none, textcolor = color.new(themeColor, 15), size = size.tiny)
        lbTP3   := label.new(tagX, activeTP3, "TP3 " + str.tostring(activeTP3, format.mintick), style = label.style_none, textcolor = themeColor, size = size.tiny)

    // Signal mark: label pinned to the signal bar itself (xloc.bar_index +
    // yloc.abovebar/belowbar), so it stays welded to the candle at any zoom/pan.
    // Two-line text puts the triangle tip right against the bar, score behind it.
    float p = fireLong ? probL : probS
    float e = fireLong ? edgeL : edgeS
    float riskAbs = math.abs(activeEntry - activeSL)
    float tgtR = riskAbs > 0 ? math.abs(activeTP3 - activeEntry) / riskAbs : na
    string pct = str.tostring(p * 100, "#.#") + "%"
    string ptxt = fireLong ? "▲\n" + pct : pct + "\n▼"
    color lblCol = p >= 0.90 ? hitColor : fireLong ? bullColor : bearColor
    string tip = (fireLong ? "LONG " : "SHORT ") + pct + (isRu ? " | перевес " : " | edge ") + str.tostring(e * 100, "#.#") + "%" + " | ADX " + str.tostring(adx, "#.#") + " | RSI " + str.tostring(f1, "#.#") + " | CCI " + str.tostring(cciVal, "#") + (isRu ? " | цель ~" : " | target ~") + str.tostring(tgtR, "#.#") + "R"
    label.new(bar_index, fireLong ? low : high, ptxt, xloc = xloc.bar_index, yloc = fireLong ? yloc.belowbar : yloc.abovebar, style = label.style_none, textcolor = lblCol, size = lblSize, tooltip = tip)

    if fireLong
        alertLongEntry := true
    else
        alertShortEntry := true


bool canCheckHit = activeDir != 0 and not na(activeEntryBar) and bar_index > activeEntryBar and barstate.isconfirmed

if activeDir != 0
    int extX = bar_index + 5
    line.set_x2(lnEntry, extX), line.set_x2(lnSL, extX), line.set_x2(lnTP1, extX), line.set_x2(lnTP2, extX), line.set_x2(lnTP3, extX)
    if showLevelTagsInput and not na(lbEntry)
        int tagX = extX + 2
        label.set_x(lbEntry, tagX), label.set_x(lbSL, tagX), label.set_x(lbTP1, tagX), label.set_x(lbTP2, tagX), label.set_x(lbTP3, tagX)

    if activeDir == 1
        if canCheckHit and high >= activeTP1 and not tp1Hit
            tp1Hit := true, line.set_color(lnTP1, hitColor), line.set_style(lnTP1, line.style_solid)
            alertTP1Hit := true

            if useBreakEvenInput and not beActive
                activeSL := activeEntry
                beActive := true
                line.set_xy1(lnSL, bar_index, activeSL), line.set_xy2(lnSL, extX, activeSL)
                line.set_color(lnSL, color.new(bearColor, 70))
                if showLevelTagsInput and not na(lbSL)
                    label.set_y(lbSL, activeSL)
                    label.set_text(lbSL, (isRu ? "БУ " : "BE ") + str.tostring(activeSL, format.mintick))
        if canCheckHit and high >= activeTP2 and not tp2Hit
            tp2Hit := true, line.set_color(lnTP2, hitColor), line.set_style(lnTP2, line.style_solid)
            alertTP2Hit := true
        if canCheckHit and high >= activeTP3 and not tp3Hit
            tp3Hit := true, line.set_color(lnTP3, hitColor)
            alertTP3Hit := true
            // Full objective reached — trade tracking completes here instead of
            // idling until an eventual SL touch (which fired a misleading SL alert).
            activeDir := 0
            line.set_color(lnEntry, color.new(color.gray, 60))
            statDone += 1, statTP3 += 1
            if tp1Hit
                statTP1 += 1
        if canCheckHit and activeDir != 0 and low <= activeSL
            activeDir := 0
            line.set_color(lnEntry, color.new(color.gray, 60))
            statDone += 1
            if tp1Hit
                statTP1 += 1
            if beActive
                statBE += 1
                alertBEExit := true
            else
                statSL += 1
                alertSLHit := true
    else
        if canCheckHit and low <= activeTP1 and not tp1Hit
            tp1Hit := true, line.set_color(lnTP1, hitColor), line.set_style(lnTP1, line.style_solid)
            alertTP1Hit := true
            if useBreakEvenInput and not beActive
                activeSL := activeEntry
                beActive := true
                line.set_xy1(lnSL, bar_index, activeSL), line.set_xy2(lnSL, extX, activeSL)
                line.set_color(lnSL, color.new(bullColor, 70))
                if showLevelTagsInput and not na(lbSL)
                    label.set_y(lbSL, activeSL)
                    label.set_text(lbSL, (isRu ? "БУ " : "BE ") + str.tostring(activeSL, format.mintick))
        if canCheckHit and low <= activeTP2 and not tp2Hit
            tp2Hit := true, line.set_color(lnTP2, hitColor), line.set_style(lnTP2, line.style_solid)
            alertTP2Hit := true
        if canCheckHit and low <= activeTP3 and not tp3Hit
            tp3Hit := true, line.set_color(lnTP3, hitColor)
            alertTP3Hit := true
            activeDir := 0
            line.set_color(lnEntry, color.new(color.gray, 60))
            statDone += 1, statTP3 += 1
            if tp1Hit
                statTP1 += 1
        if canCheckHit and activeDir != 0 and high >= activeSL
            activeDir := 0
            line.set_color(lnEntry, color.new(color.gray, 60))
            statDone += 1
            if tp1Hit
                statTP1 += 1
            if beActive
                statBE += 1
                alertBEExit := true
            else
                statSL += 1
                alertSLHit := true

// Alerts (bilingual messages)
alertcondition(alertLongEntry,  title = "Вход LONG / Long entry",   message = "Reversal Pro: вход в LONG / long entry signal")
alertcondition(alertShortEntry, title = "Вход SHORT / Short entry", message = "Reversal Pro: вход в SHORT / short entry signal")
alertcondition(alertTP1Hit,     title = "TP1 взят / TP1 hit",       message = "Reversal Pro: цель TP1 достигнута / TP1 reached")
alertcondition(alertTP2Hit,     title = "TP2 взят / TP2 hit",       message = "Reversal Pro: цель TP2 достигнута / TP2 reached")
alertcondition(alertTP3Hit,     title = "TP3 взят / TP3 hit",       message = "Reversal Pro: цель TP3 (прогноз модели) достигнута / TP3 (model objective) reached")
alertcondition(alertSLHit,      title = "Стоп-лосс / Stop loss",    message = "Reversal Pro: сработал стоп-лосс / stop loss hit")
alertcondition(alertBEExit,     title = "Безубыток / Break-even",   message = "Reversal Pro: выход в безубыток / break-even exit")

// Dashboard
color dashTxt = #D8E1EA
color dashDim = #8FA3B0

f_cell(table tbl, int c, int r, string txt, color col) =>
    table.cell(tbl, c, r, txt, text_color = col, text_size = size.small, text_halign = text.align_left)

f_statPct(int cnt, int total) =>
    total > 0 ? str.tostring(math.round(100.0 * cnt / total)) + "%" : "—"

var table dash = showDashInput ? table.new(dashPosInput == "Справа сверху / Top right" ? position.top_right : dashPosInput == "Слева сверху / Top left" ? position.top_left : dashPosInput == "Слева снизу / Bottom left" ? position.bottom_left : position.bottom_right, 3, 12, bgcolor = color.new(#0B1520, 10), frame_width = 1, frame_color = color.new(#8FA3B0, 60), border_width = 1, border_color = color.new(#8FA3B0, 88)) : na

if showDashInput and barstate.islast and not na(dash)
    float pl = nz(probL) * 100
    float ps = nz(probS) * 100
    bool  hasScores = not na(probL) and not na(probS)
    bool  biasLong  = pl >= ps
    float bestP     = math.max(pl, ps)
    float edgePct   = math.abs(pl - ps)
    float threshPct = probThreshInput * 100

    int st = na(modelClsL) ? 0 : activeDir != 0 ? 4 : not adxRegimeOk ? 2 : not cooldownOk ? 3 : 1
    string statusTxt = st == 0 ? (isRu ? "ОБУЧЕНИЕ" : "TRAINING") : st == 1 ? (isRu ? "ГОТОВ" : "READY") : st == 2 ? (isRu ? "ВНЕ РЕЖИМА" : "OFF-REGIME") : st == 3 ? (isRu ? "ПАУЗА" : "COOLDOWN") : (isRu ? "В СДЕЛКЕ" : "IN TRADE")
    color  statusCol = st == 1 ? bullColor : st == 0 ? dashDim : st == 4 ? hitColor : bearColor
    string gradeTxt  = not hasScores ? "—" : bestP >= threshPct ? (isRu ? "ТОРГУЕМ " : "TRADE ") + str.tostring(threshPct, "#") + "+" : bestP >= 70 ? (isRu ? "СМОТРИМ 70-" : "WATCH 70-") + str.tostring(threshPct - 1, "#") : (isRu ? "НЕТ СЕТАПА" : "NO EDGE")
    color  biasCol   = biasLong ? bullColor : bearColor
    string sActive   = isRu ? "АКТИВЕН" : "ACTIVE"

    f_cell(dash, 0, 0, "REVERSAL PRO", dashTxt)
    f_cell(dash, 1, 0, "| jjart", dashDim)
    f_cell(dash, 2, 0, statusTxt, statusCol)

    f_cell(dash, 0, 1, isRu ? "НАПРАВЛ" : "BIAS", dashDim)
    f_cell(dash, 1, 1, hasScores ? (biasLong ? (isRu ? "ЛОНГ" : "LONG") : (isRu ? "ШОРТ" : "SHORT")) : "—", biasCol)
    f_cell(dash, 2, 1, hasScores ? str.tostring(bestP, "#.#") + "%" : "—", biasCol)

    f_cell(dash, 0, 2, isRu ? "ОЦЕНКА" : "GRADE", dashDim)
    f_cell(dash, 1, 2, gradeTxt, dashTxt)
    f_cell(dash, 2, 2, hasScores ? (isRu ? "ПЕРЕВЕС " : "EDGE ") + str.tostring(edgePct, "#.#") + "%" : "—", dashTxt)

    f_cell(dash, 0, 3, isRu ? "ЛОНГ" : "LONG", dashDim)
    f_cell(dash, 1, 3, na(probL) ? "—" : str.tostring(pl, "#.#") + "%", bullColor)
    f_cell(dash, 2, 3, activeDir == 1 ? sActive : "—", activeDir == 1 ? hitColor : dashDim)

    f_cell(dash, 0, 4, isRu ? "ШОРТ" : "SHORT", dashDim)
    f_cell(dash, 1, 4, na(probS) ? "—" : str.tostring(ps, "#.#") + "%", bearColor)
    f_cell(dash, 2, 4, activeDir == -1 ? sActive : "—", activeDir == -1 ? hitColor : dashDim)

    f_cell(dash, 0, 5, "ADX", dashDim)
    f_cell(dash, 1, 5, str.tostring(adx, "#.#"), adxRegimeOk ? dashTxt : bearColor)
    f_cell(dash, 2, 5, str.tostring(adxMinInput, "#") + "-" + str.tostring(adxMaxInput, "#"), dashDim)

    f_cell(dash, 0, 6, "RSI", dashDim)
    f_cell(dash, 1, 6, str.tostring(f1, "#.#"), dashTxt)
    f_cell(dash, 2, 6, "RelVol " + str.tostring(f2, "#.#") + " • CCI " + str.tostring(cciVal, "#"), dashDim)

    f_cell(dash, 0, 7, isRu ? "ПРИЗНАКИ" : "FEATURES", dashDim)
    f_cell(dash, 1, 7, "RSI " + str.tostring(array.get(impPct, 0), "#") + "%", dashTxt)
    f_cell(dash, 2, 7, "VOL " + str.tostring(array.get(impPct, 1), "#") + "%", dashTxt)

    f_cell(dash, 0, 8, "", dashDim)
    f_cell(dash, 1, 8, "Z " + str.tostring(array.get(impPct, 2), "#") + "%", dashTxt)
    f_cell(dash, 2, 8, "ADX " + str.tostring(array.get(impPct, 3), "#") + "%", dashTxt)

    f_cell(dash, 0, 9, isRu ? "ФИЛЬТР" : "FILTER", dashDim)
    f_cell(dash, 1, 9, "≥" + str.tostring(threshPct, "#") + "%", dashTxt)
    f_cell(dash, 2, 9, statusTxt, statusCol)

    f_cell(dash, 0, 10, isRu ? "ПАМЯТКА" : "GUIDE", dashDim)
    f_cell(dash, 1, 10, isRu ? "70 НАБЛЮДАТЬ" : "70 WATCH", dashDim)
    f_cell(dash, 2, 10, str.tostring(threshPct, "#") + (isRu ? "+ ТОРГОВАТЬ" : "+ TRADE"), dashDim)

    f_cell(dash, 0, 11, (isRu ? "СТАТА (" : "STATS (") + str.tostring(statDone) + ")", dashDim)
    f_cell(dash, 1, 11, "TP1 " + f_statPct(statTP1, statDone) + " • TP3 " + f_statPct(statTP3, statDone), dashTxt)
    f_cell(dash, 2, 11, "SL " + f_statPct(statSL, statDone) + " • " + (isRu ? "БУ " : "BE ") + f_statPct(statBE, statDone), dashTxt)
````
