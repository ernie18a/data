# Code B - Flow Engine: Modular Oscillator & Data Layer

- url: https://www.tradingview.com/script/cs6qCSR8-code-b-flow-engine-modular-oscillator-data-layer/
- type: indicator
- pine_id: PUB;22145db8981c496d96c11779c14679f0
- version: 1.0

## Description

Code B — Modular Oscillator & Market State Panel

Code B is a dedicated sub-chart oscillator panel that operates as a complete, standalone market analysis system. It synthesizes momentum, volume flow, and trend health into a unified visual layer, giving the trader a real-time, multi-dimensional read of market state — without relying on price chart overlays.

Core Modules

Wave Oscillator (WaveCalc): A channel-based EMA oscillator measuring price deviation from its adaptive mean. Produces three outputs:

Momentum Wave Lt (wave1) — the fast wave, reflecting raw momentum pressure.
Momentum Wave (wave2) — a smoothed signal line (SMA-3 of wave1). Crossovers between wave1 and wave2 mark momentum shifts. A diamond marker appears at the crossover point when the cross occurs in extreme OB/OS territory (above +60 or below −60), highlighting high-conviction reversals.
Difference Momentum (difference = wave1 − wave2) — the primary impulse metric. Quantifies momentum acceleration: positive and growing = trend building; near zero = consolidation or indecision; negative = momentum fading or reversing. Traders use this value to gauge whether a move has real force behind it or is running out of steam.

Money Flow: A normalized volume-proxy indicator calculated as SMA(60) of the candle body-to-range ratio, scaled and offset to center around zero. Values above zero indicate bullish capital participation and accumulation; values below zero indicate distribution or bearish pressure. Displayed simultaneously as a line and histogram columns — the background fill of the panel also shifts color based on flow direction, providing an instant visual bias read.

Stochastic RSI (Dual Stoch): Two stochastic oscillators with different lookback periods (40 and 8), each smoothed with SMA(2). The faster stoch (period 8) is plotted as a colored line — green when above the slow stoch (bullish momentum bias), red when below (bearish bias). Their relative position provides a secondary momentum confirmation layer independent of the wave oscillator.

Bias Score / Trend Score (ChandleTrendScore): A trend health index that compares the current close against 10 historical bars (offsets 11–20). Each comparison contributes +1 (bullish) or −1 (bearish) to a cumulative score, smoothed with WMA(5) and scaled to a ±83 range. Displayed as a step-line with gradient color zones at ±33 / ±66 / ±83. This module measures trend persistence and structural stability — not just direction. A score above +33 confirms a healthy uptrend; below −33 confirms a healthy downtrend; values near zero indicate a weak or transitional market.

How to Read the Panel

The panel is designed to be read as a whole. A high-conviction bullish state looks like: wave1 above wave2, Difference Momentum positive and rising, Money Flow above zero (teal histogram), Stoch RSI line green, Trend Score above +33. A bearish state is the mirror image. Divergences between modules — e.g., price rising but Money Flow negative and Difference fading — are early warning signals of trend exhaustion.

Key Settings & Notes

Use Current Chart Resolution: Enabled by default. When disabled, a custom timeframe can be specified for multi-timeframe analysis.
Trend Score WMA: Toggle on/off. Smoothing period: 5 (range: 3–600).
OB/OS Levels: Fixed at ±60.
Trend Score Bands: Fixed at ±33 / ±66 / ±83.

⚠️ DISCLAIMER This software is provided for educational and informational purposes only. Trading involves significant risk of loss and is not suitable for every investor. Past performance is not indicative of future results. The developers of Code B do not guarantee any specific financial outcome. Use of this indicator is at your own risk. Always perform your own due diligence or consult with a licensed financial advisor before making any investment decisions.

Русская версия

Code B — модульный осциллятор и панель состояния рынка

Code B — нижняя панель осциллятора, работающая как полноценная самостоятельная аналитическая система. Она объединяет импульс, объёмный поток и здоровье тренда в единый визуальный слой, давая трейдеру многомерную картину состояния рынка в реальном времени — без привязки к оверлейным индикаторам на ценовом графике.

Основные модули

Wave Oscillator (WaveCalc): Канальный EMA-осциллятор, измеряющий отклонение цены от адаптивной средней. Выдаёт три значения:

Momentum Wave Lt (wave1) — быстрая волна, отражающая сырое давление импульса.
Momentum Wave (wave2) — сглаженная сигнальная линия (SMA-3 от wave1). Пересечения wave1 и wave2 маркируют смену импульса. Маркер-ромб появляется в точке пересечения, если оно происходит в зоне экстремальной перекупленности/перепроданности (выше +60 или ниже −60) — это сигнал высококонвикционного разворота.
Difference Momentum (difference = wave1 − wave2) — ключевая метрика импульса. Измеряет ускорение движения: положительное и растущее — тренд набирает силу; около нуля — консолидация или неопределённость; отрицательное — импульс угасает или разворачивается. Трейдер использует это значение, чтобы понять, есть ли за движением реальная сила или оно выдыхается.

Money Flow (Денежный поток): Нормализованный прокси-индикатор объёма. Рассчитывается как SMA(60) от отношения тела свечи к её диапазону, масштабированного и смещённого к нулю. Значения выше нуля — бычье участие капитала и фаза накопления; ниже нуля — распределение или медвежье давление. Отображается одновременно как линия и гистограмма — фоновая заливка панели также меняет цвет в зависимости от направления потока, обеспечивая мгновенное визуальное считывание уклона.

Stochastic RSI (Двойной стохастик): Два стохастических осциллятора с разными периодами (40 и 8), каждый сглажен SMA(2). Более быстрый стохастик (период 8) отображается цветной линией — зелёной, когда выше медленного (бычий уклон импульса), красной, когда ниже (медвежий уклон). Их взаимное положение формирует независимый от волнового осциллятора слой подтверждения импульса.

Bias Score / Trend Score (ChandleTrendScore — Трендовый скор): Индекс здоровья тренда, сравнивающий текущую свечу с 10 историческими барами (смещения 11–20). Каждое сравнение добавляет +1 (бычий) или −1 (медвежий) к накопленному счёту, который сглаживается WMA(5) и масштабируется до диапазона ±83. Отображается как ступенчатая линия с градиентными зонами ±33 / ±66 / ±83. Этот модуль измеряет устойчивость и структурную стабильность тренда — не только его направление. Скор выше +33 подтверждает здоровый восходящий тренд; ниже −33 — здоровый нисходящий; значения около нуля указывают на слабый или переходный рынок.

Как читать панель

Панель читается как единое целое. Высококонвикционное бычье состояние: wave1 выше wave2, Difference Momentum положительный и растущий, Money Flow выше нуля (бирюзовая гистограмма), линия Stoch RSI зелёная, Trend Score выше +33. Медвежье состояние — зеркальное. Дивергенции между модулями — например, цена растёт, но Money Flow отрицательный и Difference угасает — ранние сигналы истощения тренда.

Ключевые настройки и примечания

Use Current Chart Resolution: Включено по умолчанию. При отключении можно задать произвольный таймфрейм для мультитаймфреймного анализа.
Trend Score WMA: Включение/отключение. Период сглаживания: 5 (диапазон: 3–600).
Уровни OB/OS: Зафиксированы на ±60.
Зоны Trend Score: Зафиксированы на ±33 / ±66 / ±83.

⚠️ ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ Данное программное обеспечение предоставляется исключительно в образовательных и ознакомительных целях. Торговля на финансовых рынках сопряжена с высоким риском и подходит не всем инвесторам. Результаты в прошлом не гарантируют доходности в будущем. Разработчики Code B не несут ответственности за любые финансовые убытки. Перед принятием инвестиционных решений рекомендуется провести самостоятельный анализ или проконсультироваться с лицензированным финансовым консультантом.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Indexrate
// @description: Momentum flow engine with wave oscillator and bias scoring

//@version=5
indicator("Code B — Flow Engine: Modular Oscillator & Data Layer", overlay=false)


////*** Inputs ***////   {

    // Flow Engine
_p0 = input.bool(true, "Use Current Chart Resolution?", group="Flow Engine")
_p1 = input.timeframe("", "Use Current Chart Resolution?", group="Flow Engine")
int _obLvl = 60
int _osLvl = -60


    // Bias Score
_u0 = input.bool(true, title="Bias Score", group="Bias Score")
_u1 = input.int(5, minval=3, maxval=600, title="Smoothing Period", group="Bias Score")

int _uB1 = 33
int _uB2 = 66
int _uB3 = 83
int _uL1 = -33
int _uL2 = -66
int _uL3 = -83

color _cx0 = #00bece
color _cx1 = #9995a3

////--- Inputs ---////   }




////*** Functions ***////   {

f_a1(float _s, int _cl, int _al) =>
    _e  = ta.ema(_s, _cl)
    _d  = ta.ema(math.abs(_s - _e), _cl)
    _ci = (_s - _e) / (0.015 * _d)
    _oA = ta.ema(_ci, _al)
    _oB = ta.sma(_oA, 3)
    _oDf = _oA - _oB
    [_oA, _oB, _oDf]


f_a2(_len, _m, _y) =>
    ta.sma(((close - open) / (high - low)) * _m, _len) - _y


f_a3(_offset) =>
    [_oA, _oB, _oDf] = f_a1(hlc3, 9, 12)
    _oMf = f_a2(60, 200, 2.25)
    _oK1 = ta.sma(ta.stoch(close, high, low, 40), 2)
    _oK2 = ta.sma(ta.stoch(close, high, low, 8),  2)
    [_oA[_offset], _oB[_offset], _oDf[_offset], _oMf[_offset], _oK1[_offset], _oK2[_offset]]


f_a4() =>
    int _s = 0
    for i = 11 to 20
        if close > close[i]
            _s += 1
        else
            _s -= 1
    ta.wma(_s, _u1)

////--- Functions ---////   }




////*** Calculating ***////   {

    // Flow Engine
_tf = _p0 ? timeframe.period : _p1
[_oA, _oB, _oDf, _oMf, _oK1, _oK2] = request.security(syminfo.tickerid, _tf, f_a3(not _p0 and barstate.isrealtime ? 1 : 0))

    // Bias Score
_bsRaw  = f_a4()
float _bsCorr = 8.333
color _bsCol  = _bsRaw > 2 ? #00bdce : #9995a3
float _bsVal  = _bsRaw * _bsCorr

////--- Calculating ---////   }




////*** Draw plotting ***////   {

_dspH = display.all - display.status_line

    // Flow Engine
_pW1 = plot(_oA,  "Momentum Wave Lt", color.new(#ff00f7, 0), 1, plot.style_linebr)
_pW2 = plot(_oB,  "Momentum Wave",    color.new(#a200ff, 0), 1, plot.style_linebr)
fill(_pW1, _pW2, color=color.new(color.purple, 30), title="Wave filling")

plot(_oDf,  "Difference Momentum", color.new(#ff7300, 0), 1, plot.style_linebr)
plot(_oMf,  "Money Flow line",  _oMf > 0 ? color.new(#00bece, 10) : color.new(#d4d4d4, 10), 2, plot.style_line)
plot(_oMf,  "Money Flow",       _oMf > 0 ? color.new(#00bece, 60) : color.new(#d4d4d4, 50), 2, plot.style_columns)

plotshape(ta.crossunder(_oA, _oB) and _oA > _obLvl, "Sell", shape.diamond, location.top,    _cx1, size=size.tiny, display=_dspH)
plotshape(ta.crossover(_oA, _oB)  and _oA < _osLvl, "Buy",  shape.diamond, location.bottom, _cx0, size=size.tiny, display=_dspH)

plot(ta.crossover(_oA, _oB)  ? _oB : na, "Wave Crossing UP",   color.new(#00bece, 0), 3, plot.style_areabr, display=_dspH)
plot(ta.crossunder(_oA, _oB) ? _oB : na, "Wave Crossing Down", color.new(#bbbbc4, 0), 3, plot.style_areabr, display=_dspH)

plotshape(ta.crossover(_oA, _oB),  "Wave Crossing UP",   shape.cross, location.bottom, _cx0, size=size.tiny, display=_dspH)
plotshape(ta.crossunder(_oA, _oB), "Wave Crossing Down", shape.cross, location.top,    _cx1, size=size.tiny, display=_dspH)

plot(0,      "Zero",      #d4d4d4, display=_dspH)
plot(_obLvl, "OB 1 Solid", #d4d4d4, 1, display=_dspH)
plot(_osLvl, "OS 1 Solid", color.new(#d4d4d4, 0), 1, display=_dspH)

plot(_oK2, "Stoch RSI", _oK1 > _oK2 ? #03FC04 : #d91702, 2, plot.style_line)

_p2 = plot(100, "Bottom line 1", color.new(color.white, 100), display=display.none, editable=false)
_p3 = plot(120, "Bottom line 2", color.new(color.white, 100), display=display.none, editable=false)
fill(_p2, _p3, _oMf > 0 ? color.new(#00bece, 20) : color.new(#d4d4d5, 20), title="Bottom line")


    // Bias Score
plot(_u0 ? _bsVal : na, title="Bias Score", style=plot.style_steplinebr, color=_bsCol, linewidth=2)

_pU1 = plot(_u0 ? _uB1 : na, editable=false, display=display.none)
_pU2 = plot(_u0 ? _uB2 : na, editable=false, display=display.none)
_pU3 = plot(_u0 ? _uB3 : na, editable=false, display=display.none)
fill(_pU1, _pU2, color=color.new(_cx0, 70), title="Upper band fill in #1")
fill(_pU2, _pU3, color=color.new(_cx0, 40), title="Upper band fill in #2")

_pL1 = plot(_u0 ? _uL1 : na, editable=false, display=display.none)
_pL2 = plot(_u0 ? _uL2 : na, editable=false, display=display.none)
_pL3 = plot(_u0 ? _uL3 : na, editable=false, display=display.none)
fill(_pL1, _pL2, color=color.new(_cx1, 70), title="Lower band fill in #1")
fill(_pL2, _pL3, color=color.new(_cx1, 40), title="Lower band fill in #2")

plot(170,  title="", color=color.new(color.white, 100), display=display.pane, editable=false)
plot(-130, title="", color=color.new(color.white, 100), display=display.pane, editable=false)

////--- Draw plotting ---////   }
````
