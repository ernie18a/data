# EMA 9/21/200 buy sel

- url: https://www.tradingview.com/script/VMZWEaTX/
- type: indicator
- pine_id: PUB;e0b52944bf0543d59c7310649ddc3b1c
- version: 2.0

## Description

ema 9 ema 21 ema 200 kalın sarı çizgi buy and sell for 15 minutes

## Source Code

````pine
//@version=6
indicator("EMA 13/34 Anlık 15DK Sinyal Şablonu (Filtresiz)", overlay=true)

// --- Girdiler ve Hesaplama ---
fast_len   = input.int(13, title="Hızlı Kesim EMA (13)")
slow_len   = input.int(34, title="Yavaş Kesim EMA (34)")
filter_len = input.int(200, title="Trend Filtre EMA (200)")

ema_fast   = ta.ema(close, fast_len)
ema_slow   = ta.ema(close, slow_len)
ema_filter = ta.ema(close, filter_len)

// --- Çizimler ---
plot(ema_fast, color=color.lime, linewidth=2, title="EMA 13 (Parlak Yeşil)")
plot(ema_slow, color=color.red, linewidth=2, title="EMA 34 (Parlak Kırmızı)")
plot(ema_filter, color=color.yellow, linewidth=2, title="EMA 200 (Sarı)")

// --- Kesişim Koşulları (13 ve 34'e göre anlık) ---
al_sinyali   = ta.crossover(ema_fast, ema_slow)   
sat_sinyali  = ta.crossunder(ema_fast, ema_slow)  

// --- Beyaz Yazılı Parlak BUY ve SELL Etiketleri ---
plotshape(series=al_sinyali, title="Al Ok", style=shape.triangleup, 
          location=location.belowbar, color=color.lime, size=size.normal, 
          text="BUY", textcolor=color.white, display=display.all)

plotshape(series=sat_sinyali, title="Sat Ok", style=shape.triangledown, 
          location=location.abovebar, color=color.red, size=size.normal, 
          text="SELL", textcolor=color.white, display=display.all)

// --- Arka Plan Renklendirmesi (%95 Şeffaf) ---
bgcolor(al_sinyali ? color.new(color.lime, 95) : na, title="Al Arka Plan")
bgcolor(sat_sinyali ? color.new(color.red, 95) : na, title="Sat Arka Plan")

// --- Noktalı ve Anlık Alarm Sistemi ---
alertcondition(condition=al_sinyali, title="EMA BUY Sinyali", message="🟢 BUY {{ticker}} {{close}}")
alertcondition(condition=sat_sinyali, title="EMA SELL Sinyali", message="🔴 SELL {{ticker}} {{close}}")
````
