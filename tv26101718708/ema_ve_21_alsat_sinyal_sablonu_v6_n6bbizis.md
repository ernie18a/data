# EMA ve 21 Al-Sat Sinyal sablonu v6

- url: https://www.tradingview.com/script/n6BbIziS/
- type: indicator
- pine_id: PUB;97b71604806b4499b80496fd04c7fc7c
- version: 1.0

## Description

2 ema pinelerini birleştirdim 5dk lıkta kapanış mumundan sonra scalp işlem açabilirsiniz,herşeyin sorumluğu kişinin tercihine aittir çünkü hiç kimse finansal piyasarlarada hiç bir şeyi garanti edemez

## Source Code

````pine
//@version=6
indicator("EMA 9/21 Al-Sat Sinyal Şablonu v6", overlay=true)

// --- Girdiler ve Hesaplama ---
fast_len = input.int(9, title="Hızlı EMA")
slow_len = input.int(21, title="Yavaş EMA")

ema9  = ta.ema(close, fast_len)
ema21 = ta.ema(close, slow_len)

// --- Parlak Çizimler ---
plot(ema9, color=color.lime, linewidth=2, title="EMA 9 (Parlak Yeşil)")
plot(ema21, color=color.red, linewidth=2, title="EMA 21 (Parlak Kırmızı)")

// --- Al ve Sat Koşulları ---
al_sinyali   = ta.crossover(ema9, ema21)   // 9, 21'i yukarı keserse
sat_sinyali  = ta.crossunder(ema9, ema21)  // 9, 21'i aşağı keserse

// --- Grafik Görselleri (Şekiller ve Etiketler) ---
plotshape(series=al_sinyali, title="Al Ok", style=shape.triangleup, 
          location=location.belowbar, color=color.lime, size=size.small, text="AL", textcolor=color.lime)

plotshape(series=sat_sinyali, title="Sat Ok", style=shape.triangledown, 
          location=location.abovebar, color=color.red, size=size.small, text="SAT", textcolor=color.red)

// --- Arka Plan Renklendirmesi ---
bgcolor(al_sinyali ? color.new(color.lime, 90) : na, title="Al Arka Plan")
bgcolor(sat_sinyali ? color.new(color.red, 90) : na, title="Sat Arka Plan")

// --- Dinamik Şablonlu Alarm Tetikleyicileri ---
if al_sinyali
    alert("🟢 " + syminfo.ticker + " | " + str.tostring(close) + " | AL", alert.freq_once_per_bar_close)

if sat_sinyali
    alert("🔴 " + syminfo.ticker + " | " + str.tostring(close) + " | SAT", alert.freq_once_per_bar_close)
````
