# S/R Breakout Strategy LONG ONLY 

- url: https://www.tradingview.com/script/Djj394ka-S-R-Breakout-Strategy-LONG-ONLY/
- type: strategy
- pine_id: PUB;ce05ff51caa44d74a25ebbdbfe8c4a84
- version: 1.0

## Description

S/R Breakout Strategy is a long-only trend-following strategy that enters positions when price breaks above a confirmed resistance level. It features independent take-profit management per trade, a built-in cooldown mechanism, and a multi-timeframe SMA filter to ensure trades align with the broader market trend.

This strategy is designed for traders who prefer systematic breakout entries with strict risk controls and the ability to manage multiple positions simultaneously.

🔧 Key Features
1. Support & Resistance Breakout Entry

Identifies swing highs and swing lows using configurable left/right bar parameters.

Enters a long position when price crosses above a confirmed resistance level.

Validates that the channel width between support and resistance does not exceed a user-defined maximum percentage — ensuring entries occur only in reasonably tight ranges.

2. Independent Take Profit Per Trade

Each trade has its own dynamically calculated take-profit level based on the entry price.

Take profit is set as a percentage above entry, allowing consistent risk-to-reward structure across all positions.

3. Cooldown Mechanism

Prevents consecutive entries immediately after a trade is opened.

Configurable number of bars to wait before allowing a new entry — useful for avoiding overtrading in volatile conditions.

4. Multi-Timeframe SMA Filter

Optionally uses an SMA (Simple Moving Average) on a higher or custom timeframe to filter entries.

Ensures trades are taken only when price is above the SMA and beyond a minimum distance percentage — helping avoid trades against the dominant trend.

5. Position Management

Limits the maximum number of concurrent open trades to control exposure.

Allows pyramiding (multiple entries) with independent exits.

📈 How to Use
1. Add the strategy to your chart.

2. Configure the parameters according to your trading style and market conditions.

3. Enable or disable the SMA filter based on whether you want trend confirmation.

4. Backtest on your preferred symbols and timeframes to validate performance.

Recommended use: This strategy works well on 3-4 minutes timeframe cooldown bars must be 50 or above

## Source Code

````pine
//@version=6
strategy(
     title="S/R Breakout Strategy LONG ONLY Independent TP + Cooldown",
     overlay=true,
     initial_capital=1000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=100,
     pyramiding=100,
     process_orders_on_close=true)

// --------------------------------------------------
// ВХОДНЫЕ ПАРАМЕТРЫ
// --------------------------------------------------

// 1. Настройки S/R для входа
grp_sr_entry = "Настройки S/R Вход"
leftBarsEntry  = input.int(15, title="Entry Left Bars", group=grp_sr_entry, minval=1)
rightBarsEntry = input.int(15, title="Entry Right Bars", group=grp_sr_entry, minval=1)

// 2. Управление сделками
grp_mng = "Управление сделками"
allowLong       = input.bool(true, title="Активировать LONG?", group=grp_mng)
maxRangePerc    = input.float(2.0, title="Макс. ширина канала (%)", minval=0.1, step=0.1, group=grp_mng)
tpPercent       = input.float(1.0, title="Take Profit (%)", minval=0.1, step=0.1, group=grp_mng)
maxOpenTrades   = input.int(20, title="Макс. количество одновременных сделок", minval=1, group=grp_mng)
cooldownBars    = input.int(10, title="Cooldown bars после каждого входа", minval=0, group=grp_mng)

// 3. Настройки Фильтра SMA
grp_flt = "Фильтр SMA (Мульти-Таймфрейм)"
useSmaFilter           = input.bool(true, title="Использовать SMA фильтр?", group=grp_flt)
smaLength              = input.int(200, title="Период SMA", minval=1, group=grp_flt)
smaTf                  = input.timeframe("", title="Таймфрейм SMA", group=grp_flt)
minDistanceFromSmaPerc = input.float(1.0, title="Мин. расстояние от SMA (%)", minval=0.1, step=0.1, group=grp_flt)

// --------------------------------------------------
// РАСЧЕТ ИНДИКАТОРОВ
// --------------------------------------------------

// SMA anti-repaint: только по закрытому бару выбранного ТФ
float smaValue = request.security(
     syminfo.tickerid,
     smaTf,
     ta.sma(close, smaLength)[1],
     lookahead=barmerge.lookahead_off)

// Рисуем SMA
plot(useSmaFilter ? smaValue : na, color=color.orange, title="SMA Filter", linewidth=2)

// Пивоты S/R для входа
float phEntry = ta.pivothigh(leftBarsEntry, rightBarsEntry)
float plEntry = ta.pivotlow(leftBarsEntry, rightBarsEntry)

var float resistanceLevel = na
var float supportLevel    = na

if not na(phEntry)
    resistanceLevel := phEntry

if not na(plEntry)
    supportLevel := plEntry

plot(resistanceLevel, color=color.new(color.red, 0), linewidth=2, title="Entry Resistance")
plot(supportLevel, color=color.new(color.blue, 0), linewidth=2, title="Entry Support")

// --------------------------------------------------
// ЛОГИКА СТРАТЕГИИ
// --------------------------------------------------

// A. Ширина канала входного S/R
float channelRange = na
if not na(resistanceLevel) and not na(supportLevel) and supportLevel != 0
    channelRange := ((resistanceLevel - supportLevel) / supportLevel) * 100

bool isRangeValid = not na(channelRange) and channelRange <= maxRangePerc

// B. Пробой уровня сопротивления
bool breakoutLong = not na(resistanceLevel) and ta.crossover(close, resistanceLevel)

// C. Проверка SMA фильтра
bool smaCondLong = not useSmaFilter or (not na(smaValue) and close > smaValue)

// D. Фильтр минимальной дистанции до SMA
float distanceFromSmaPerc = not na(smaValue) ? math.abs(close - smaValue) / smaValue * 100 : na
bool farEnoughFromSma = not useSmaFilter or (not na(distanceFromSmaPerc) and distanceFromSmaPerc > minDistanceFromSmaPerc)

// E. Ограничение по количеству открытых сделок
bool canOpenMoreTrades = strategy.opentrades < maxOpenTrades

// --------------------------------------------------
// COOLDOWN ПОСЛЕ КАЖДОГО ВХОДА
// --------------------------------------------------

var int lastEntryBarIndex = na

int barsSinceLastEntry = na(lastEntryBarIndex) ? 1000000 : (bar_index - lastEntryBarIndex)
bool cooldownPassed = cooldownBars <= 0 or barsSinceLastEntry >= cooldownBars

// F. Финальное условие входа
bool longCondition = barstate.isconfirmed and allowLong and breakoutLong and isRangeValid and smaCondLong and farEnoughFromSma and canOpenMoreTrades and cooldownPassed

// --------------------------------------------------
// ИСПОЛНЕНИЕ ВХОДОВ
// --------------------------------------------------

var int tradeCounter = 0

if longCondition
    tradeCounter += 1
    string entryId = "Long_" + str.tostring(tradeCounter)
    strategy.entry(id=entryId, direction=strategy.long, comment=entryId)
    lastEntryBarIndex := bar_index

// --------------------------------------------------
// НЕЗАВИСИМЫЕ ВЫХОДЫ ПО TAKE PROFIT
// --------------------------------------------------

int openTradesCount = strategy.opentrades

if openTradesCount > 0
    for i = 0 to openTradesCount - 1
        string currentEntryId = strategy.opentrades.entry_id(i)
        float currentEntryPrice = strategy.opentrades.entry_price(i)
        float currentTP = currentEntryPrice * (1 + tpPercent / 100)

        strategy.exit(
             id="TP_" + currentEntryId,
             from_entry=currentEntryId,
             limit=currentTP,
             comment="Independent TP")

// --------------------------------------------------
// ВИЗУАЛИЗАЦИЯ СИГНАЛОВ
// --------------------------------------------------

plotshape(longCondition, title="Long Entry", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small, text="L")
````
