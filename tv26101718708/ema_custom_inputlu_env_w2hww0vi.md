# EMA Custom (Inputlu) ENV

- url: https://www.tradingview.com/script/w2hWw0vi/
- type: indicator
- pine_id: PUB;36a86f1c6471444fae4cda85385e7011
- version: 1.0

## Description

Karmaşayı Önler: 13 farklı indikatör eklemek yerine tek bir indikatörle tüm ortalamaları görebilirsiniz.
Destek/Direnç Tespiti: Fiyatın bu çizgilerden hangisine çarpıp döndüğünü analiz ederek strateji geliştirebilirsiniz.
Trend Analizi: Çizgilerin birbirine göre dizilimi (kısadan uzuna) trendin gücünü gösterir.

## Source Code

````pine
//@version=5
indicator("EMA Custom (Inputlu)", overlay=true)

// EMA input kutuları (numaralı)
len800  = input.int(800,  "1 - EMA 800 (Turuncu)")
len2235 = input.int(2235, "2 - EMA 2235 (Yeşil)")
len1650 = input.int(1650, "3 - EMA 1650 (Siyah)")
len400  = input.int(400,  "4 - EMA 400 (Kırmızı)")
len50   = input.int(50,   "5 - EMA 50 (Mavi)")
len2170 = input.int(2170, "6 - EMA 2170 (Koyu Kırmızı)")

len600  = input.int(600,  "7 - EMA 600 (Maroon)")
len4999 = input.int(4999, "8 - EMA 4999 (Aqua)")
len180  = input.int(180,  "9 - EMA 180 (Fuşya)")
len3550 = input.int(3550, "10 - EMA 3550 (Lime)")

len500  = input.int(500,  "11 - EMA 500 (Sarı)")
len600b = input.int(600,  "12 - EMA 600 (Mor)")
len700  = input.int(700,  "13 - EMA 700 (Teal)")

// EMA hesapları
ema800  = ta.ema(close, len800)
ema2235 = ta.ema(close, len2235)
ema1650 = ta.ema(close, len1650)
ema400  = ta.ema(close, len400)
ema50   = ta.ema(close, len50)
ema2170 = ta.ema(close, len2170)

ema600  = ta.ema(close, len600)
ema4999 = ta.ema(close, len4999)
ema180  = ta.ema(close, len180)
ema3550 = ta.ema(close, len3550)

ema500  = ta.ema(close, len500)
ema600b = ta.ema(close, len600b)
ema700  = ta.ema(close, len700)

// Plotlar (title ile numaralandırma)
plot(ema800,  color=color.orange, title="1 - EMA 800")
plot(ema2235, color=color.green,  title="2 - EMA 2235")
plot(ema1650, color=color.black,  title="3 - EMA 1650")
plot(ema400,  color=color.red,    title="4 - EMA 400")
plot(ema50,   color=color.blue,   title="5 - EMA 50")
plot(ema2170, color=color.rgb(200, 0, 0), title="6 - EMA 2170")

plot(ema600,  color=color.maroon, title="7 - EMA 600")
plot(ema4999, color=color.aqua,   title="8 - EMA 4999")
plot(ema180,  color=color.fuchsia,title="9 - EMA 180")
plot(ema3550, color=color.lime,   title="10 - EMA 3550")

plot(ema500,  color=color.yellow, title="11 - EMA 500")
plot(ema600b, color=color.purple, title="12 - EMA 600 (2)")
plot(ema700,  color=color.teal,   title="13 - EMA 700")
````
