# Volume fight strategy

- url: https://www.tradingview.com/script/alrI0TBw-volume-fight-strategy/
- type: strategy
- pine_id: PUB;739575c164ef4ab7ba43a141bee446bc
- version: 1.0

## Description

The Volume fight strategy looks for the predominance of bullish or bearish trading volume on the chart by dividing the trading volume in the bar into 2 parts - "bullish volume" and "bearish volume", and comparing the weighted average values by volume with each other at a given distance.

This strategy is suitable for any instrument (cryptocurrency, Forex, stocks) and is able to work on any TF.

The Volume fight strategy should be used as an auxiliary indicator that tells you who is currently prevailing in the market - " bulls "or"bears".

To configure the strategy , it is necessary to set the range of evaluation of the predominance of bullish or bearish volume (the number of bars, by default-24 bars for TF=1H). The smaller the TF, the higher the range value should be used to filter out false signals.

When there is a predominance of "bulls" on the chart, a green triangle appears (relevant at the close of the bar) and the histogram is highlighted in green, when "bears" appear on the chart, a red triangle appears (relevant at the close of the bar) and the histogram is highlighted in red.

In the strategy settings, there is smoothing to reduce false signals and highlight the flat zone by specifying a percentage, at least which should be the difference between the forces of the "bullish" and "bearish" volume . If the difference between the volume forces is less than the specified one (by default-15%), the zone is considered flat and is displayed in gray on the histogram.
If you set the percentage to zero, the flat zones will not be highlighted, but there will be much more false signals, since the strategy becomes very sensitive when the smoothing percentage decreases.

There is a function-to show the color background of the current trading zone. For" bullish "- green, for" bearish " - red.
In the settings, you can enable the display and use of each signal in the trading zone, not only the initial one, but also each after the flat zone. By default, only the signal of the beginning of the ascending/descending zone is used.
The strategy has alerts for "bullish" and "bearish" movements. 
👉Use alerts - "alert() function calls only"

If you have any questions, you can write to me in private messages or by using the contacts in my signature.

----------------------------------------------------

Стратегия Volume fight ищет на графике преобладание бычьего или медвежьего объёма торгов путём разделения торгового объёма в баре на 2 части - "бычий объём" и "медвежий объём", и сравнения средне-взвешенных значений по объёму между собой на заданной дистанции.

Данная стратегия подходит для любого инструмента (криптовалюта, Forex, акции) и способен работать на любом ТФ.

Стратегию Volume fight следует использовать как вспомогательный индикатор, который подсказывает Вам кто сейчас преобладает на рынке - "быки" или "медведи".

Для настройки стратегии необходимо выставить диапазон оценки преобладания бычьего или медвежьего объема (количество баров, по умолчанию - 24 бара для ТФ=1Ч). Чем меньше ТФ, тем выше следует использовать значение диапазона, чтобы отфильтровать ложные сигналы.

При возникновении преобладания на графике "быков" появляется зелёный треугольник (актуален по закрытию бара) и гистограмма подсвечивается зелёным цветом, при возникновении на графике "медведей" появляется красный треугольник (актуален по закрытию бара) и гистограмма подсвечивается красным цветом.

В настройках стратегии есть сглаживание для уменьшения ложных сигналов и выделения зоны флета с помощью указания процента, не менее которого, должна быть разница между силами "бычьего" и "медвежьего" объёма. Если разница между силами объёмов меньше заданного (по умолчанию - 15%), то зона считается флетовой и отображается на гистограмме серым цветом.
Если выставить процент равным нулю, то зоны флета выделяться не будут, но будет гораздо больше ложных сигналов, так как стратегия становится очень чувствительной при снижении процента сглаживания.

Есть функция - показывать цветовой фон текущей торговой зоны. Для "бычьего" - зелёный, для "медвежьего" - красный.
В настройках можно включить отображение и использование каждого сигнал в торговой зоне, не только начального, но и каждого после зоны флета. По умолчанию - только сигнал начала восходящей/нисходящей зоны.
Стратегия имеет оповещения для "бычьего" и "медвежьего" движения. 
👉 Используйте оповещения - "Только при вызове функции alert()".

По любым вопросам Вы можете написать мне в личные сообщения или по контактам в моей подписи.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Shuttle_Club
//@version=5

strategy('Volume fight strategy', default_qty_type=strategy.cash, default_qty_value=10000, currency='USD', commission_value=0.04, calc_on_order_fills=false, calc_on_every_tick=false, initial_capital=10000)

direction = input.string('ANY', 'Direction', options=['LONG', 'SHORT', 'ANY'], tooltip='Select the direction of trade.\n\nВыберите направление торговли.')
ma = input.int(11, 'Search_range', minval=1, tooltip='The range of estimation of the predominance of bullish or bearish volume (quantity bars). The smaller the TF, the higher the range value should be used to filter out false signals.\n\nДиапазон оценки преобладания бычьего или медвежьего объема (количество баров). Чем меньше ТФ, тем выше следует использовать значение диапазона, чтобы отфильтровать ложные сигналы.')
delta = input.float(15, 'Smoothing_for_flat,%', step=0.5, minval=0, tooltip='Smoothing to reduce false signals and highlight the flat zone. If you set the percentage to zero, the flat zones will not be highlighted, but there will be much more false signals, since the indicator becomes very sensitive when the smoothing percentage decreases.\n\nСглаживание для уменьшения ложных сигналов и выделения зоны флета. Если выставить процент равным нулю, то зоны флета выделяться не будут, но будет гораздо больше ложных сигналов, так как индикатор становится очень чувствительным при снижении процента сглаживания')
bgshow = input.bool(true, 'Show background zones', tooltip='Show the color background of the current trading zone.\n\nПоказывать цветовой фон текущей торговой зоны.')
all_signal_show = input.bool(false, 'Show each setup in zone', tooltip='Show every signals into trading zone.\n\nПоказывать каждый сигнал внутри торговой зоны.')

/////   CALCULATION
bull_vol = open < close ? volume : volume * (high - open) / (high - low)  //determine the share of bullish volume
bear_vol = open > close ? volume : volume * (open - low) / (high - low)  //determine the share of bearish volume
avg_bull_vol = ta.vwma(bull_vol, ma)  //determine vwma
avg_bear_vol = ta.vwma(bear_vol, ma)
diff_vol = ta.sma(avg_bull_vol / volume - 1 - (avg_bear_vol / volume - 1), ma)  //normalize and smooth the values
vol_flat = math.abs(avg_bull_vol + avg_bear_vol) / 2  //determine average value for calculation flat-filter

/////   SIGNALS
up = int(na), up := nz(up[1])
dn = int(na), dn := nz(dn[1])
bull = avg_bull_vol > avg_bear_vol and vol_flat / avg_bull_vol < 1 - delta / 100  //determine up zones
bear = avg_bull_vol < avg_bear_vol and vol_flat / avg_bear_vol < 1 - delta / 100  //determine dn zones

if bull
    up += 1, dn := 0
    dn
if bear
    dn += 1, up := 0
    up
if not bull and not bear and all_signal_show
    up := 0, dn := 0
    dn

/////   PLOTTING
plotshape(bull and up == 1, 'UP', location=location.bottom, style=shape.triangleup, color=color.new(color.green, 0), size=size.tiny)
plotshape(bear and dn == 1, 'DN', location=location.top, style=shape.triangledown, color=color.new(color.red, 0), size=size.tiny)
bgcolor(title='Trading zones', color=bgshow and avg_bull_vol > avg_bear_vol and vol_flat / avg_bull_vol < 1 - delta / 100 ? color.new(color.green, 85) : bgshow and avg_bull_vol < avg_bear_vol and vol_flat / avg_bear_vol < 1 - delta / 100 ? color.new(color.red, 85) : na)
plot(diff_vol, 'Volume difference', style=plot.style_area, color=avg_bull_vol > avg_bear_vol and vol_flat / avg_bull_vol < 1 - delta / 100 ? color.new(color.green, 0) : avg_bull_vol < avg_bear_vol and vol_flat / avg_bear_vol < 1 - delta / 100 ? color.new(color.red, 0) : color.new(color.gray, 50))

strategy.close('Short', comment='close', when=bull and up == 1)
strategy.close('Long', comment='close', when=bear and dn == 1)
strategy.entry('Long', strategy.long, when=direction != 'SHORT' and bull and up == 1)
strategy.entry('Short', strategy.short, when=direction != 'LONG' and bear and dn == 1)

if bull and up==1
    alert('Bullish movement! LONG trading zone', alert.freq_once_per_bar_close)
if bear and dn==1
    alert('Bearish movement! SHORT trading zone', alert.freq_once_per_bar_close)
````
