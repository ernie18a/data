# Fibo Control Engine PRO+ WOLFKING V1

- url: https://www.tradingview.com/script/ECEklpxZ/
- type: indicator
- pine_id: PUB;b0cc5a81bf6b43469e14d3946db70282
- version: 1.0

## Description

🔥 Fibo Control Engine PRO+
📌 Overview

Fibo Control Engine PRO+, piyasadaki klasik Fibonacci araçlarının ötesine geçerek dinamik range bazlı otomatik seviyeler sunan gelişmiş bir trade destek sistemidir.

Bu araç, belirlenen periyot içerisindeki en yüksek ve en düşük seviyeyi baz alarak:

Trend yönünü
Premium / Discount bölgelerini
Pullback (geri çekilme) seviyelerini
otomatik olarak analiz etmenizi sağlar.
⚙️ Core Logic

Sistem şu mantıkla çalışır:

👉 Belirlenen Range (len) içinde:

En yüksek seviye = liquidity (üst)
En düşük seviye = liquidity (alt)

Bu aralık üzerinden Fibonacci seviyeleri otomatik hesaplanır:

0.236 → Trend continuation
0.382 → Shallow pullback
0.5 → Equilibrium
0.618 → OTE (Optimal Trade Entry)
0.705 → Deep liquidity zone
🔁 Reverse Mode (Game Changer)

Reverse özelliği aktif edildiğinde:

👉 Fibonacci tamamen ters çevrilir

Bu sayede:

Trend içi continuation yerine
counter-trend / reversal fırsatları yakalanır

💣 Özellikle:

Fake breakout
Liquidity sweep sonrası dönüşlerde
çok güçlü çalışır
🧠 Nasıl Kullanılır?
🔵 Trend Trade (En Güçlü Setup)
Reverse: ❌ OFF
Kullanılacak seviyeler:
0.5
0.618
0.705

👉 Senaryo:

Fiyat düşer → 0.618 – 0.705’e gelir
Tepki + onay → SHORT

veya

Fiyat yükselir → 0.618 – 0.705’e iner
Tepki + onay → LONG
🟡 Scalping / Hızlı İşlem
Seviyeler:
0.236
0.382

👉 Küçük pullback’leri yakalamak için kullanılır
👉 Özellikle London session’da etkili

🔴 Reversal Trade
Reverse: ✅ ON
Seviyeler:
0.5
0.618

👉 Fake move sonrası dönüş yakalamak için

⏰ Session Kullanımı
London (Scalp Zone)
0.236 / 0.382 daha aktif çalışır
Fake hareket fazla
New York (Expansion Zone)
0.5 / 0.618 / 0.705 çok net çalışır
Gerçek kırılımlar burada gelir
🎯 Entry Model

Standart giriş modeli:

Fiyat fibo seviyesine gelir
Rejection / wick oluşur
Structure küçük TF’de kırılır
Entry alınır
🛑 Risk Management
SL → Range High / Low dışı
TP:
İlk hedef → 0.5
İkinci hedef → karşı likidite
🚫 Kaçınılması Gereken Durumlar
Range market (yatay piyasa)
Haber saatleri
Aynı seviyeye sürekli dokunan fiyat
🔔 Alerts

Sistem, fiyatın önemli fibo seviyelerine temas ettiğinde alarm üretir.

👉 Bu sayede ekran başında olmasan bile fırsatları kaçırmazsın.

💣 Final Not

Bu araç:

❌ Tek başına sinyal üretmez
✅ Doğru okunduğunda yüksek olasılıklı bölgeleri verir

Gerçek güç:

👉 Price Action + Liquidity + Fibo birleşiminde ortaya çıkar.

👉 “Best used with FVG / Liquidity concepts”

## Source Code

````pine
//@version=5
indicator("Fibo Control Engine PRO+", overlay=true)

//================ INPUTS =================//

len = input.int(50, "Range Length")

// Toggles
showHigh = input.bool(false, "Show High")
showLow = input.bool(false, "Show Low")
show50 = input.bool(true, "Show Fibo 50")
show618 = input.bool(false, "Show 0.618")
show705 = input.bool(false, "Show 0.705")
show382 = input.bool(false, "Show 0.382")   // ✅ NEW
show236 = input.bool(false, "Show 0.236")   // ✅ NEW

// HTF
useHTF = input.bool(false, "Use Higher Timeframe")
htf_tf = input.timeframe("15", "HTF")

// Reverse
reverse = input.bool(false, "Reverse Fibo")

// Alerts
enableAlerts = input.bool(true, "Enable Touch Alerts")

//================ DATA =================//

srcHigh = useHTF ? request.security(syminfo.tickerid, htf_tf, high) : high
srcLow  = useHTF ? request.security(syminfo.tickerid, htf_tf, low)  : low

rangeHigh = ta.highest(srcHigh, len)
rangeLow  = ta.lowest(srcLow, len)

//================ LEVEL CALC =================//

// NORMAL
fib50_n  = rangeLow + (rangeHigh - rangeLow) * 0.5
fib618_n = rangeLow + (rangeHigh - rangeLow) * 0.618
fib705_n = rangeLow + (rangeHigh - rangeLow) * 0.705
fib382_n = rangeLow + (rangeHigh - rangeLow) * 0.382   // ✅ NEW
fib236_n = rangeLow + (rangeHigh - rangeLow) * 0.236   // ✅ NEW

// REVERSED
fib50_r  = rangeHigh - (rangeHigh - rangeLow) * 0.5
fib618_r = rangeHigh - (rangeHigh - rangeLow) * 0.618
fib705_r = rangeHigh - (rangeHigh - rangeLow) * 0.705
fib382_r = rangeHigh - (rangeHigh - rangeLow) * 0.382   // ✅ NEW
fib236_r = rangeHigh - (rangeHigh - rangeLow) * 0.236   // ✅ NEW

// SELECT MODE
fib50  = reverse ? fib50_r  : fib50_n
fib618 = reverse ? fib618_r : fib618_n
fib705 = reverse ? fib705_r : fib705_n
fib382 = reverse ? fib382_r : fib382_n   // ✅ NEW
fib236 = reverse ? fib236_r : fib236_n   // ✅ NEW

//================ PLOTS =================//

ph = plot(showHigh ? rangeHigh : na, "High", color=color.red, linewidth=2)
pl = plot(showLow ? rangeLow : na, "Low", color=color.green, linewidth=2)

p50  = plot(show50 ? fib50 : na, "Fibo 50", color=color.yellow, linewidth=2)
p618 = plot(show618 ? fib618 : na, "0.618", color=color.orange, linewidth=2)
p705 = plot(show705 ? fib705 : na, "0.705", color=color.purple, linewidth=2)
p382 = plot(show382 ? fib382 : na, "0.382", color=color.blue, linewidth=2)   // ✅ NEW
p236 = plot(show236 ? fib236 : na, "0.236", color=color.aqua, linewidth=2)   // ✅ NEW

// OTE Zone
fill(p618, p705, color=color.new(color.orange, 85))

//================ BG =================//

premium = close > fib50
bgcolor(premium ? color.new(color.red, 95) : color.new(color.green, 95))

//================ ALERTS =================//

touch50  = ta.cross(close, fib50)
touch618 = ta.cross(close, fib618)
touch705 = ta.cross(close, fib705)
touch382 = ta.cross(close, fib382)   // ✅ NEW
touch236 = ta.cross(close, fib236)   // ✅ NEW

if enableAlerts and touch50
    alert("Touch Fibo 50", alert.freq_once_per_bar)

if enableAlerts and touch618
    alert("Touch 0.618", alert.freq_once_per_bar)

if enableAlerts and touch705
    alert("Touch 0.705", alert.freq_once_per_bar)

if enableAlerts and touch382
    alert("Touch 0.382", alert.freq_once_per_bar)

if enableAlerts and touch236
    alert("Touch 0.236", alert.freq_once_per_bar)
````
