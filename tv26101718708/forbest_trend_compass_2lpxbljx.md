# FORBEST Trend Compass

- url: https://www.tradingview.com/script/2LPXbLjX-forbest-trend-compass/
- type: indicator
- pine_id: PUB;ebb2d3e0c52d4845a6de949225087006
- version: 1.0

## Description

Этот индикатор я создал не для поиска точек входа и не как источник сигналов. Его задача намного проще и, на мой взгляд, важнее — помочь быстро определить, кто сейчас контролирует рынок.

В основе индикатора лежат три скользящие средние:

🟢 MA 50 (зелёная) — отражает краткосрочный импульс рынка.

🟠 MA 100 (оранжевая) — показывает среднесрочное направление движения.

🟣 MA 200 (фиолетовая) — помогает определить долгосрочный тренд и общую структуру рынка.

Особое внимание стоит обратить на цвет фона.

🟢 Зелёный фон — цена находится выше MA 50, MA 100 и MA 200. Это означает, что преимущество находится на стороне покупателей. В классическом понимании рынок находится в бычьей фазе. Если ваша стратегия предполагает работу по тренду, именно в таких условиях стоит отдавать приоритет поиску покупок.

🔴 Красный фон — цена находится ниже MA 50, MA 100 и MA 200. Это говорит о преимуществе продавцов и медвежьем рынке. В подобных условиях покупки становятся более рискованными, а продажи соответствуют общему направлению движения.

🟠 Оранжевый фон — цена находится между MA 50 и MA 100. Это переходная зона. Рынок начинает менять краткосрочную структуру, но окончательного преимущества пока нет. Здесь важно проявлять терпение и ждать дополнительных подтверждений.

🟣 Фиолетовый фон — цена находится между MA 100 и MA 200. Это зона глубокой коррекции или восстановления. Долгосрочный тренд ещё не подтверждён, поэтому стоит быть более избирательным и осторожным.

⚪ Серый фон — смешанная структура. Мувинги не дают однозначной картины, а значит, рынок находится в состоянии неопределённости. Для новичков именно такие периоды часто оказываются самыми сложными.

Важно понимать: этот индикатор не предсказывает будущее и не гарантирует результат. Он лишь отвечает на один вопрос:

«Кто сейчас имеет преимущество — покупатели или продавцы?»

Используйте его как фильтр направления и дополнительный элемент анализа, а не как самостоятельную торговую систему.

## Source Code

````pine
//@version=6
indicator("FORBEST MA Trend", overlay=true)

maType = input.string("EMA", "Тип мувинга", options=["EMA", "SMA"])
showBg = input.bool(true, "Подсвечивать фон")
showTable = input.bool(true, "Показывать таблицу")

ma50 = maType == "EMA" ? ta.ema(close, 50) : ta.sma(close, 50)
ma100 = maType == "EMA" ? ta.ema(close, 100) : ta.sma(close, 100)
ma200 = maType == "EMA" ? ta.ema(close, 200) : ta.sma(close, 200)

aboveAll = close > ma50 and close > ma100 and close > ma200
belowAll = close < ma50 and close < ma100 and close < ma200
between50and100 = (close < ma50 and close > ma100) or (close > ma50 and close < ma100)
between100and200 = (close < ma100 and close > ma200) or (close > ma100 and close < ma200)

status = aboveAll ? "БЫЧИЙ РЕЖИМ" : belowAll ? "МЕДВЕЖИЙ РЕЖИМ" : between50and100 ? "МЕЖДУ MA 50 И MA 100" : between100and200 ? "МЕЖДУ MA 100 И MA 200" : "СМЕШАННАЯ ЗОНА"

statusColor = aboveAll ? color.green : belowAll ? color.red : between50and100 ? color.orange : between100and200 ? color.purple : color.gray

plot(ma50, title="MA 50 - зеленая", color=color.green, linewidth=2)
plot(ma100, title="MA 100 - оранжевая", color=color.orange, linewidth=2)
plot(ma200, title="MA 200 - фиолетовая", color=color.purple, linewidth=2)

bgcolor(showBg ? color.new(statusColor, 90) : na)

var table t = table.new(position.top_right, 1, 4, border_width=1)

if barstate.islast and showTable
    table.cell(t, 0, 0, "FORBEST MA TREND", bgcolor=color.black, text_color=color.white)
    table.cell(t, 0, 1, syminfo.ticker, bgcolor=color.black, text_color=color.white)
    table.cell(t, 0, 2, "TF: " + timeframe.period, bgcolor=color.black, text_color=color.white)
    table.cell(t, 0, 3, status, bgcolor=statusColor, text_color=color.white)

alertcondition(aboveAll, title="Бычий режим", message="Цена выше MA 50/100/200")
alertcondition(belowAll, title="Медвежий режим", message="Цена ниже MA 50/100/200")
````
