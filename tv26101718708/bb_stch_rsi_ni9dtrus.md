# BB% STCH RSI

- url: https://www.tradingview.com/script/ni9dTRuS/
- type: indicator
- pine_id: PUB;7c700ac9ccdc4476a59b5c521dca836b
- version: 1.0

## Description

indikatör bb% ve stokastik rsı dikkate alınara trend dönüş arayan bir indikatördür. daha çok scalp işlemler için tasarlanmıştır. başka indikatörlerle desteklenmelidir. sadece bu indikatöre göre yapacağınız işlemler zararla sonuçlanabilir.

## Source Code

````pine
//@version=6
indicator("BB% STCH RSI", overlay=true, max_labels_count=500)

// --- GİRDİLER ---
int   bb_length         = input.int(55, "BB %B Periyodu", minval=1)
float bb_mult           = input.float(2.0, "BB %B Sapma", step=0.1)
int   srsi_smoothK      = input.int(3, "Stoch RSI K Düzeltme")
int   srsi_smoothD      = input.int(3, "Stoch RSI D Düzeltme")
int   srsi_lengthRSI    = input.int(14, "RSI Periyodu")
int   srsi_lengthStoch  = input.int(14, "Stoch Periyodu")

// --- HESAPMALAR ---
// 1. Bollinger Bands %B
[middle, upper, lower] = ta.bb(close, bb_length, bb_mult)
float bbp = (upper - lower) != 0 ? (close - lower) / (upper - lower) : 0

// 2. Stoch RSI
float rsiValue = ta.rsi(close, srsi_lengthRSI)
float stoch    = ta.stoch(rsiValue, rsiValue, rsiValue, srsi_lengthStoch)
float k        = ta.sma(stoch, srsi_smoothK)
float d        = ta.sma(k, srsi_smoothD)

// --- DEĞİŞKEN TANIMLAMALARI ---
var bool buy_triggered  = false
var bool sell_triggered = false
var float last_low      = na
var float last_high     = na

// --- ALIM (LONG) MANTIĞI ---
if ta.crossunder(bbp, 0)
    buy_triggered := true

bool k_cross_up = ta.crossover(k, d)

if k_cross_up
    float current_low = low
    if buy_triggered and not na(last_low) and current_low > last_low
        label.new(bar_index, low, "AL", color=color.new(color.green, 0), style=label.style_label_up, textcolor=color.white, size=size.normal)
        buy_triggered := false
    last_low := current_low

// --- SATIŞ (SHORT) MANTIĞI ---
// Şart 1: BB %B'nin 1'i (üst bant) yukarı kesmesi
if ta.crossover(bbp, 1)
    sell_triggered := true

// Şart 2: Stoch RSI K'nın D'yi aşağı kesmesi
bool k_cross_down = ta.crossunder(k, d)

if k_cross_down
    float current_high = high
    // Şart 3: BB tetiklenmiş olmalı VE fiyat bir önceki tepeye göre daha düşük tepe yapmalı
    if sell_triggered and not na(last_high) and current_high < last_high
        label.new(bar_index, high, "SAT", color=color.new(color.red, 0), style=label.style_label_down, textcolor=color.white, size=size.normal)
        sell_triggered := false
    
    // Her kesişimde bir sonraki kıyaslama için tepe fiyatını kaydet
    last_high := current_high

// --- GÖRSELLEŞTİRME ---
// Tetikleyicileri takip etmek için (Küçük oklar)
plotshape(ta.crossunder(bbp, 0), "BB Alt Bant Kırılımı", shape.arrowup, location.bottom, color.new(color.green, 50), size=size.tiny)
plotshape(ta.crossover(bbp, 1), "BB Üst Bant Kırılımı", shape.arrowdown, location.top, color.new(color.red, 50), size=size.tiny)

// Stoch RSI kesişim noktaları
plotchar(k_cross_up, "Boğa Kesişimi", "•", location.belowbar, color.new(color.green, 70), size=size.tiny)
plotchar(k_cross_down, "Ayı Kesişimi", "•", location.abovebar, color.new(color.red, 70), size=size.tiny)
````
