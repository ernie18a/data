# SMC - BUY and SELL Signal

- url: https://www.tradingview.com/script/GnWfnYiN/
- type: indicator
- pine_id: PUB;3d682be19537416e889b6eb8c7fe4812
- version: 2.0

## Description

SMC — BUY & SELL Signal adalah indikator berbasis Smart Money Concept (SMC) yang dirancang untuk membantu trader mengidentifikasi peluang entry BUY dan SELL dengan lebih akurat menggunakan kombinasi analisis struktur pasar, Order Block, dan filter trend.
Fitur Utama:

✅ Signal BUY & SELL otomatis dengan filter ketat (EMA + RSI + Body Candle)
✅ Supply Zone (merah) & Demand Zone (biru) — Order Block otomatis
✅ BOS (Break of Structure) — konfirmasi perubahan struktur pasar
✅ EMA Fast & Slow sebagai filter trend
✅ Kill Zone — highlight waktu London Open & New York Open
✅ Key Level — garis support/resistance manual
✅ Alert siap pakai untuk notifikasi HP

Cara Penggunaan:

Signal BUY muncul saat harga di atas kedua EMA, trend naik, dan terjadi pembalikan bullish
Signal SELL muncul saat harga di bawah kedua EMA, trend turun, dan terjadi pembalikan bearish
Gunakan Supply Zone sebagai area take profit untuk posisi BUY
Gunakan Demand Zone sebagai area take profit untuk posisi SELL
BOS mengkonfirmasi bahwa struktur pasar telah berubah arah
Trading pada Kill Zone (area kuning/oranye) memberikan probabilitas lebih tinggi

Recommended Timeframe: 5M, 15M, 1H
Cocok untuk: XAU/USD, Forex Major, Crypto, Indices

## Source Code

````pine
//@version=5
indicator("SMC — BUY & SELL Signal", overlay=true, max_labels_count=500, max_boxes_count=50)

// ─── INPUT ───────────────────────────────────
ema_fast  = input.int(20,    "EMA Fast")
ema_slow  = input.int(50,    "EMA Slow")
rsi_len   = input.int(14,    "RSI Length")
show_ema  = input.bool(true, "Show EMA")
show_bos  = input.bool(true, "Show BOS")
show_zone = input.bool(true, "Show Zone")
show_kz   = input.bool(true, "Show Kill Zone")
zone_ext  = input.int(20,    "Zone Extend")
swing_len = input.int(10,    "Swing Length")
key_price = input.float(0.0, "Key Level (0=off)")

// ─── EMA ─────────────────────────────────────
ema1 = ta.ema(close, ema_fast)
ema2 = ta.ema(close, ema_slow)
plot(show_ema ? ema1 : na, "EMA Fast", color=color.red,    linewidth=2)
plot(show_ema ? ema2 : na, "EMA Slow", color=color.orange, linewidth=2)

bullish_trend = ema1 > ema2
bearish_trend = ema1 < ema2

// ─── RSI ─────────────────────────────────────
rsi = ta.rsi(close, rsi_len)

// ─── CANDLE FILTER ───────────────────────────
body     = math.abs(close - open)
avg_body = ta.sma(body, 14)
big_body = body > avg_body * 1.5

// ─── BUY SIGNAL ──────────────────────────────
buy_signal = close > open and close[1] < open[1] and close[2] < open[2] and close > ema1 and close > ema2 and bullish_trend and big_body and rsi < 60 and rsi > 40

if buy_signal
    label.new(bar_index, low, "BUY", yloc=yloc.belowbar, style=label.style_label_up, color=color.new(color.green, 10), textcolor=color.white, size=size.small)

// ─── SELL SIGNAL ─────────────────────────────
sell_signal = close < open and close[1] > open[1] and close[2] > open[2] and close < ema1 and close < ema2 and bearish_trend and big_body and rsi > 40 and rsi < 60

if sell_signal
    label.new(bar_index, high, "SELL", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.red, 10), textcolor=color.white, size=size.small)

// ─── BOS ─────────────────────────────────────
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low,   swing_len, swing_len)

var float last_ph = na
var float last_pl = na

if not na(ph)
    last_ph := ph
if not na(pl)
    last_pl := pl

bear_bos = not na(last_pl) and close < last_pl
bull_bos = not na(last_ph) and close > last_ph

if show_bos and bear_bos
    label.new(bar_index, low, "BOS", yloc=yloc.belowbar, style=label.style_label_up, color=color.new(color.red, 30), textcolor=color.white, size=size.tiny)
    last_pl := na

if show_bos and bull_bos
    label.new(bar_index, high, "BOS", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.green, 30), textcolor=color.white, size=size.tiny)
    last_ph := na

// ─── SUPPLY ZONE ─────────────────────────────
var box[] s_boxes = array.new_box()
var label[] s_labels = array.new_label()

// Supply Zone — terbentuk saat harga TURUN dari atas (bearish OB)
// Harus terjadi saat harga masih TINGGI, bukan di bawah
bear_ob = close[1] > open[1] and close < open and high[1] > ema1 and high[1] > ema2
if show_zone and bear_ob
    if array.size(s_boxes) >= 5
        box.delete(array.shift(s_boxes))
        label.delete(array.shift(s_labels))
    b = box.new(bar_index-1, high[1], bar_index+zone_ext, low[1],
      bgcolor=color.new(color.red, 85),
      border_color=color.new(color.red, 50), border_width=1)
    l = label.new(bar_index-1, high[1], "⚡ Supply Zone (OB)",
      style=label.style_label_lower_right,
      color=color.new(color.red, 85),
      textcolor=color.new(color.red, 10),
      size=size.normal)
    array.push(s_boxes, b)
    array.push(s_labels, l)

// ─── DEMAND ZONE ─────────────────────────────
var box[] d_boxes = array.new_box()
var label[] d_labels = array.new_label()

// Demand Zone — terbentuk saat harga NAIK dari bawah (bullish OB)  
// Harus terjadi saat harga masih RENDAH, bukan di atas
bull_ob = close[1] < open[1] and close > open and low[1] < ema1 and low[1] < ema2
if show_zone and bull_ob
    if array.size(d_boxes) >= 5
        box.delete(array.shift(d_boxes))
        label.delete(array.shift(d_labels))
    b = box.new(bar_index-1, high[1], bar_index+zone_ext, low[1],
      bgcolor=color.new(color.blue, 85),
      border_color=color.new(color.blue, 50), border_width=1)
    l = label.new(bar_index-1, high[1], "⚡ Demand Zone (OB)",
      style=label.style_label_lower_right,
      color=color.new(color.blue, 85),
      textcolor=color.new(color.blue, 10),
      size=size.normal)
    array.push(d_boxes, b)
    array.push(d_labels, l)
    
// ─── KILL ZONE ───────────────────────────────
london = not na(time(timeframe.period, "0800-1000", "Europe/London"))
ny     = not na(time(timeframe.period, "0930-1130", "America/New_York"))
bgcolor(show_kz ? (london ? color.new(color.yellow, 92) : ny ? color.new(color.orange, 92) : na) : na)

if show_kz and (london or ny) and not (london[1] or ny[1])
    label.new(bar_index, high, "K", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.yellow, 20), textcolor=color.black, size=size.tiny)

// ─── KEY LEVEL ───────────────────────────────
hline(key_price, "Key Level", color=key_price > 0 ? color.red : color.new(color.red, 100), linewidth=2)

// ─── ALERT ───────────────────────────────────
alertcondition(buy_signal,  "BUY",  "BUY Signal!")
alertcondition(sell_signal, "SELL", "SELL Signal!")
````
