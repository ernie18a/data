<!-- tradingview-pine-id: PUB;6860aab298714baaa51765089f5b474b -->
<!-- tradingviewscripts-format: 1 -->
# Kalman Trend Filter

Source: https://www.tradingview.com/script/96Y9dQtF/

## Description

### Overview
Kalman Trend Filter is a trend-following indicator based on the Kalman Filtering algorithm. Unlike traditional moving averages (SMA/EMA) that lag significantly due to fixed timeframes, this script treats price action as a "noisy signal" and dynamically estimates the true underlying trend by separating market noise from real price movement.

### Underlying Logic & Math Concept
The filter operates on a continuous two-step recursive loop:

1. **Prediction:** The algorithm predicts the next price state based on previous velocity and momentum.
2. **Measurement Update:** It compares the actual closing price with its prediction to measure the error margin.

The filter balances two critical dynamic parameters:
* **Process Noise ($Q$):** Represents the expected randomness or volatility of the market.
* **Measurement Noise ($R$):** Represents transient price fluctuations/noise.

By calculating the **Kalman Gain ($K$)**, the filter determines whether a price move is a genuine trend change or temporary noise.

### How to Use & Parameter Guide: Process Noise ($Q$)
* **Trend Pullbacks & Re-entries ($Q = 0.01 - 0.03$):** Filters out minor market noise. When price pulls back to the filter bands during an established trend, it highlights ideal low-risk entry/re-entry points.
* **Fast Response & Breakouts ($Q = 0.1$):** Increases sensitivity to capture rapid trend shifts, consolidation breakouts, and bottom/top reversals on daily or lower timeframes with minimal lag.
* **Warning:** Setting $Q$ below $0.01$ makes the filter overly sluggish, causing it to lag significantly during sharp market turns.

---

### Türkçe Açıklama (Turkish Description)

**Genel Bakış**
Kalman Trend Filter, Kalman Filtreleme algoritmasını temel alan bir trend takip indikatörüdür. Geleneksel hareketli ortalamaların aksine, fiyat hareketini "gürültülü bir sinyal" olarak ele alır ve piyasa gürültüsünü gerçek fiyattan ayırarak ana trendi minimum gecikmeyle süzmeyi amaçlar.

**Çalışma Mantığı**
İndikatör iki aşamalı bir döngüyle çalışır: Tahmin ve Ölçüm Güncellemesi. Süreç Gürültüsü ($Q$) ve Ölçüm Gürültüsü ($R$) parametrelerini kıyaslayarak Kalman Kazancını ($K$) hesaplar. Böylece fiyat hareketinin gerçek bir trend değişimi mi yoksa geçici bir gürültü mü olduğuna karar verir.

**Kullanım ve Parametre Rehberi ($Q$)**
* **Trende Giriş ve Düzeltmeler ($Q = 0.01 - 0.03$):** Gürültüyü süzerek trend içi düzeltmelerde (pullback) ideal giriş noktalarını tespit etmeye yardımcı olur.
* **Hızlı Tepki ve Kırılımlar ($Q = 0.1$):** Günlük ve altı zaman dilimlerinde dip/tepe dönüşlerini ve bant kırılımlarını erken tespit etmek için kullanılır.
* **Uyarı:** $Q$ değerini $0.01$'in altına düşürmek filtrenin tepkisini aşırı hantallaştırır.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International 
// https://creativecommons.org/licenses/by-nc-sa/4.0/

//@version=6
indicator("Kalman Trend Filter", overlay = true)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
int short_len       = input.int(50, "Kısa Periyot", minval = 1)
int long_len        = input.int(150, "Uzun Periyot", minval = 1)
float process_noise = input.float(0.01, "Süreç Gürültüsü (Q)", minval = 0.0001, step = 0.001)

color upper_col     = input.color(#13bd6e, "Yükseliş Rengi", inline = "colors")
color lower_col     = input.color(#af0d4b, "Düşüş Rengi", inline = "colors")
// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
// Kısa ve Uzun Filtreler İçin Bağımsız Durum Değişkenleri
var float short_x = na
var float short_p = 1.0
var float long_x  = na
var float long_p  = 1.0

// Kısa Kalman Hesaplaması
if na(short_x)
    short_x := close

float short_r      = short_len * 0.1
float short_p_pred = short_p + process_noise
float short_k      = short_p_pred / (short_p_pred + short_r)
short_x           := short_x + short_k * (close - short_x)
short_p           := (1.0 - short_k) * short_p_pred

// Uzun Kalman Hesaplaması
if na(long_x)
    long_x := close

float long_r      = long_len * 0.1
float long_p_pred = long_p + process_noise
float long_k      = long_p_pred / (long_p_pred + long_r)
long_x           := long_x + long_k * (close - long_x)
long_p           := (1.0 - long_k) * long_p_pred

bool trend_up = short_x > long_x

color trend_col  = trend_up ? upper_col : lower_col
color trend_col1 = short_x > short_x[2] ? upper_col : lower_col
// }

// ＰＬＯＴＳ ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
p1 = plot(short_x, "Kısa Kalman", color = trend_col1, linewidth = 1)
p2 = plot(long_x, "Uzun Kalman", color = trend_col, linewidth = 2)

fill(p1, p2, color = trend_up ? color.new(upper_col, 85) : color.new(lower_col, 85), title = "Trend Dolgusu")
// }
//
````
