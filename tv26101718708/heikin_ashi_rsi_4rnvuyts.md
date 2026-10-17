# HEIKIN ASHI RSI

- url: https://www.tradingview.com/script/4RNVuyTS/
- type: indicator
- pine_id: PUB;0153cc18c0c94876a60408a7c5035e0b
- version: 1.0

## Description

rsı indikatöründeki gürültüyü azaltmak için tasarlanmış rsı heikin ashi versiyonudur. tek başına kullanılması zarar etmenize sebep olabilir. fiyatın kendisinde de heikin ashi formatı ayarlanması daha gürültüsüz sonuçlar verebilir.

"This is a Heikin Ashi version of the RSI, specifically designed to reduce market noise. Using it as a standalone indicator may lead to losses. For even cleaner results, applying the Heikin Ashi format to the price chart itself is recommended."

## Source Code

````pine
//@version=5
indicator("HEIKIN ASHI RSI", overlay=false, precision=2, max_labels_count=500)

// --- Ayarlar ---
rsi_len = input.int(14, "RSI Periyodu", minval=1)

// --- Standart RSI Hesaplamaları ---
rsi_open  = ta.rsi(open, rsi_len)
rsi_high  = ta.rsi(high, rsi_len)
rsi_low   = ta.rsi(low, rsi_len)
rsi_close = ta.rsi(close, rsi_len)

// --- Heikin Ashi Formülü Uygulama ---
var float ha_open = na
float ha_close = (rsi_open + rsi_high + rsi_low + rsi_close) / 4

if na(ha_open)
    ha_open := (rsi_open + rsi_close) / 2
else
    ha_open := (ha_open + ha_close[1]) / 2

float ha_high = math.max(rsi_high, math.max(ha_open, ha_close))
float ha_low  = math.min(rsi_low, math.min(ha_open, ha_close))

// --- Renk ve Sinyal Mantığı ---
bool is_green = ha_close >= ha_open
bool is_red   = ha_close < ha_open

buy_signal  = is_green and is_red[1]
sell_signal = is_red and is_green[1]

color candle_color = is_green ? color.green : color.red

// --- Mumları Çizme ---
plotcandle(ha_open, ha_high, ha_low, ha_close, 
     title="HEIKIN ASHI RSI Mumları", 
     color=candle_color, 
     wickcolor=candle_color, 
     bordercolor=candle_color)

// --- Metin Sinyallerini Çizme ---
// yloc hatasını önlemek için doğrudan ha_low/ha_high değerlerini kullanıyoruz
if buy_signal
    label.new(bar_index, ha_low, text="AL", xloc=xloc.bar_index, color=color.new(color.white, 100), textcolor=color.green, style=label.style_none, size=size.normal)

if sell_signal
    label.new(bar_index, ha_high, text="SAT", xloc=xloc.bar_index, color=color.new(color.white, 100), textcolor=color.red, style=label.style_none, size=size.normal)

// --- Seviye Çizgileri ---
hline(70, "Aşırı Alım", color=color.new(color.red, 50), linestyle=hline.style_dashed)
hline(30, "Aşırı Satım", color=color.new(color.green, 50), linestyle=hline.style_dashed)
hline(50, "Orta Hat", color=color.new(color.gray, 70))

// --- Alarm Tanımları ---
alertcondition(buy_signal, title="HA RSI AL", message="HEIKIN ASHI RSI: AL Sinyali!")
alertcondition(sell_signal, title="HA RSI SAT", message="HEIKIN ASHI RSI: SAT Sinyali!")
````
