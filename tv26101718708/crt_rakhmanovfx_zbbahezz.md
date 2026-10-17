# CRT - RakhmanovFX

- url: https://www.tradingview.com/script/ZbBAhEzZ-CRT-RakhmanovFX/
- type: indicator
- pine_id: PUB;fd4c7e1f4c2746c28f646fdc04f7f6f1
- version: 1.0

## Description

Candle Range Theory: 

Bu indikator Daily (kunlik), Weekly (haftalik), 4 soatlik va 1 soatlik vaqt oraliqlarida maxsus sham shakllanishini aniqlaydi.
Qanday ishlaydi:
Indikator har bir shamni kuzatib, quyidagi holatni qidiradi:

1-sham — istalgan sham bo'lib, uning yuqori va quyi chegaralari asosiy diapazon sifatida belgilanadi
2-sham — 1-shamning yuqori yoki quyi chegarasini wick (soya) bilan kesib o'tadi, lekin tanasi (body) 1-shamning diapazoni ichida yopiladi
Agar bu shart bajarilsa, indikator 1-shamning yuqori va quyi chegaralarida ikkita qora chiziq chizadi

Bu nimani anglatadi:
2-sham 1-shamning yuqori yoki quyi tomonini "sweep" qilganda va diapazon ichida yopilganda, narx keyingi shamda qarama-qarshi tomonga harakat qilishi kutiladi.
Sozlamalar:

Line Length — chiziqlar necha bar davomida ko'rsatiladi
Line Width — chiziq qalinligi

Muhim: Indikator faqat oxirgi 3 ta shamni tekshiradi, shuning uchun grafik toza va tartibli ko'rinadi.


**Candle Range Theory**

This indicator identifies a specific candle pattern on the Daily, Weekly, 4-hour, and 1-hour timeframes.

**How it works:**

The indicator monitors each candle looking for the following setup:

- **Candle 1** — any candle whose high and low establish the reference range
- **Candle 2** — wicks above or below Candle 1's high or low, but the body closes back inside Candle 1's range
- When this condition is met, the indicator draws two black horizontal lines at Candle 1's high and low

**What this means:**

When Candle 2 sweeps Candle 1's high or low and closes back inside the range, it signals that price is likely to target the opposite side of Candle 1's range on the next candle.

**Settings:**

- **Line Length** — how many bars the lines extend to the right
- **Line Width** — the thickness of the lines

**Note:** The indicator only looks at the last 3 candles, keeping the chart clean and uncluttered.

## Source Code

````pine
//@version=5
indicator("Candle Range Sweep", overlay=true, max_lines_count=500)

lineLength = input.int(4, "Line Length (bars)", minval=1, maxval=20)
lineWidth  = input.int(1, "Line Width", minval=1, maxval=4)

validTF = timeframe.isdaily or timeframe.isweekly or
          (timeframe.isintraday and (timeframe.multiplier == 240 or timeframe.multiplier == 60))

c1_high  = high[1]
c1_low   = low[1]
c2_high  = high[0]
c2_low   = low[0]
c2_open  = open[0]
c2_close = close[0]

swept_high = (c2_high > c1_high) and
             (math.max(c2_open, c2_close) <= c1_high) and
             (math.min(c2_open, c2_close) >= c1_low)

swept_low  = (c2_low < c1_low) and
             (math.min(c2_open, c2_close) >= c1_low) and
             (math.max(c2_open, c2_close) <= c1_high)

if validTF and barstate.isconfirmed and bar_index >= last_bar_index - 3
    if swept_high or swept_low
        startBar = bar_index - 1

        line.new(
             x1    = startBar,
             y1    = c1_high,
             x2    = startBar + lineLength,
             y2    = c1_high,
             xloc  = xloc.bar_index,
             color = color.black,
             width = lineWidth,
             style = line.style_solid
             )

        line.new(
             x1    = startBar,
             y1    = c1_low,
             x2    = startBar + lineLength,
             y2    = c1_low,
             xloc  = xloc.bar_index,
             color = color.black,
             width = lineWidth,
             style = line.style_solid
             )
````
