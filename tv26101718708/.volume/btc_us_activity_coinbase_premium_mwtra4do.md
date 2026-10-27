# BTC: US Activity & Coinbase Premium

- url: https://www.tradingview.com/script/mwTRA4dO-btc-us-activity-coinbase-premium/
- type: indicator
- pine_id: PUB;53367f90406b41bb944dc1059e10deb6
- version: 1.0

## Description

🇬🇧 ENGLISH

This indicator shows how active US participants in the Bitcoin market are right now and which way they are pushing the price. It compares two venues: Coinbase (BTC-USD), the main US exchange, and Binance (BTCUSDT spot), the largest global one.

1. US Activity (blue line)
The ratio of Coinbase BTC-USD volume to Binance BTCUSDT volume over the last 24 hours (rolling window), in log scale, expressed as a z-score against its 30-day mean.
• Above 0 — US traders are more active than usual.
• Below the threshold (default −0.5) — US activity is low; the background is highlighted orange.

2. Coinbase Premium (teal line)
Price of Coinbase BTC-USD relative to Binance BTCUSDT, adjusted for the USDT-USD rate (from Coinbase), expressed as a z-score against its 4-day mean.
• Above 0 — Bitcoin trades richer on Coinbase than usual: US buying pressure.
• Below 0 — cheaper on Coinbase: US selling pressure.

How to use
The indicator does not generate entry signals on its own. It is a context filter for other strategies:
• Orange background (low US activity) — a thin market. In my historical research, short-term signals from other systems performed worse during these periods; consider skipping them or reducing size.
• Coinbase premium on the side of your trade (long with premium above 0, short with premium below 0) means US demand is with you. Treat it as a hint, not a rule: historically the effect is visible mainly in 2023–2026 and was absent in 2021–2022.

Inputs: Coinbase BTC-USD, Binance BTCUSDT and Coinbase USDT-USD symbols; low US activity threshold in z units (default −0.5).
Timeframes: 15 minutes to 4 hours recommended. Windows (1 day, 4 days, 30 days) are converted into bars of the current timeframe. The US Activity line is empty for the first 30 days of history while the window fills.
Alerts: "US activity became low" and "US activity is back" (threshold crossings).

Disclaimer: for informational purposes only, not financial advice. Past performance does not guarantee future results.

———————————————

🇷🇺 РУССКИЙ

Индикатор показывает, насколько активны американские участники рынка биткоина прямо сейчас и в какую сторону они давят на цену. Сравниваются две площадки: Coinbase (BTC-USD) — основная биржа США, и Binance (BTCUSDT, спот) — крупнейшая мировая.

1. Активность США (синяя линия)
Отношение объёма торгов Coinbase BTC-USD к объёму Binance BTCUSDT за последние сутки (скользящее окно), в логарифме, в виде z-оценки — на сколько стандартных отклонений текущее значение отличается от среднего за 30 дней.
• Выше 0 — американцы торгуют активнее обычного.
• Ниже порога (по умолчанию −0.5) — активность США низкая, фон подсвечивается оранжевым.

2. Премия Coinbase (бирюзовая линия)
Цена Coinbase BTC-USD к цене Binance BTCUSDT с поправкой на курс USDT-USD (с Coinbase), в виде z-оценки относительно среднего за 4 дня.
• Выше 0 — на Coinbase дороже обычного: покупательский спрос из США.
• Ниже 0 — на Coinbase дешевле: преобладают продажи из США.

Как использовать
Индикатор не даёт сигналов входа сам по себе. Это фильтр контекста для других стратегий:
• Оранжевый фон (активность США низкая) — рынок тонкий. В моём исследовании на истории краткосрочные сигналы других систем в такие периоды отрабатывали хуже; их разумно пропускать или уменьшать объём.
• Премия Coinbase в сторону вашей сделки (покупка при премии выше 0, продажа при премии ниже 0) — спрос США на вашей стороне. Это подсказка, а не правило: на истории эффект заметен в основном в 2023–2026 годах, в 2021–2022 его не было.

Настройки: символы Coinbase BTC-USD, Binance BTCUSDT и Coinbase USDT-USD; порог «активность США низкая» в единицах z (по умолчанию −0.5).
Таймфреймы: рекомендуются от 15 минут до 4 часов. Окна (сутки, 4 дня, 30 дней) пересчитываются в бары текущего таймфрейма. Первые 30 дней истории линия активности пустая — идёт накопление окна.
Оповещения: «Активность США стала низкой» и «Активность США вернулась» (пересечение порога).

Отказ от ответственности: индикатор носит информационный характер и не является инвестиционной рекомендацией. Прошлые результаты не гарантируют будущих.

## Source Code

````pine
//@version=6
// Индикатор BTC — «Активность и спрос США» (исследование 10–11.10.2026, стенды 78–109)
// 1) Активность США = доля объёма Coinbase BTC-USD к объёму спота Binance BTCUSDT за сутки, отклонение от среднего за 30 дней (z).
//    z < −0.5 → «активность США НИЗКАЯ»: торговые сигналы 2ч/30м/4ч исторически слабы (пропуск улучшал итог).
// 2) Премия Coinbase = цена Coinbase BTC-USD к Binance BTCUSDT (с поправкой на USDT-USD), отклонение от среднего за 4 дня (z).
//    Знак премии в сторону сигнала — «спрос США ЗА» (подсказка, эффект в основном 2025–2026).
// Работает на любом таймфрейме до 4ч; окна считаются в барах текущего таймфрейма.
// v2: двуязычные названия (RU / EN) для публикации.
indicator("BTC: US Activity & Coinbase Premium / Активность и спрос США", shorttitle = "US Activity / Активность США", overlay = false, precision = 2)

cbSym  = input.symbol("COINBASE:BTCUSD", "Coinbase BTC-USD")
bnSym  = input.symbol("BINANCE:BTCUSDT", "Binance BTCUSDT (spot / спот)")
usdSym = input.symbol("COINBASE:USDTUSD", "Coinbase USDT-USD")
thrLow = input.float(-0.5, "Low US activity threshold (z) / Порог «активность США низкая» (z)", step = 0.1)

barsPerDay = math.max(1, math.round(86400 / timeframe.in_seconds()))
cbVol  = request.security(cbSym, timeframe.period, volume)
bnVol  = request.security(bnSym, timeframe.period, volume)
cbCl   = request.security(cbSym, timeframe.period, close)
bnCl   = request.security(bnSym, timeframe.period, close)
usdtCl = request.security(usdSym, timeframe.period, close)

// доля объёма США за сутки и её z за 30 дней
share  = math.log(math.sum(cbVol, barsPerDay) / math.sum(bnVol, barsPerDay))
nZ     = 30 * barsPerDay
shareZ = (share - ta.sma(share, nZ)) / ta.stdev(share, nZ)

// премия Coinbase и её z за 4 дня
usdt   = na(usdtCl) ? 1.0 : usdtCl
prem   = cbCl / (bnCl * usdt) - 1
nP     = 4 * barsPerDay
premZ  = (prem - ta.sma(prem, nP)) / ta.stdev(prem, nP)

low = shareZ < thrLow
bgcolor(low ? color.new(color.orange, 85) : na, title = "Low US activity / Активность США низкая")
plot(shareZ, "US Activity (z) / Активность США (z)", color = color.new(color.blue, 0), linewidth = 2)
plot(premZ, "Coinbase Premium (z) / Премия Coinbase (z)", color = color.new(color.teal, 0))
hline(thrLow, "Low activity threshold / Порог низкой активности", color = color.orange, linestyle = hline.style_dashed)
hline(0, "Zero / Ноль", color = color.gray)

alertcondition(ta.crossunder(shareZ, thrLow), "US activity became low / Активность США стала низкой", "BTC: US activity below normal, short-term signals are weaker / Активность США ниже обычной — сигналы 2ч/30м слабее")
alertcondition(ta.crossover(shareZ, thrLow), "US activity is back / Активность США вернулась", "BTC: US activity back to normal / Активность США снова обычная")
````
