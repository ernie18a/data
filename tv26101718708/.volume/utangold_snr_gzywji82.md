# UtaNGOLD SnR

- url: https://www.tradingview.com/script/gZyWji82/
- type: indicator
- pine_id: PUB;161cb1cc463c4cf2a802039011e711a4
- version: 1.0

## Description

Support & Resistance Levels + ALARM

Indikator ini membantu mengidentifikasi level Support dan Resistance secara otomatis menggunakan sistem pivot, dilengkapi dengan deteksi breakout berbasis volume serta sistem alarm ketika level Support atau Resistance baru terbentuk.

Fitur Utama

🔴 Resistance

- Menampilkan level Resistance berdasarkan pivot high.
- Garis Resistance ditampilkan secara otomatis pada chart.

🔵 Support

- Menampilkan level Support berdasarkan pivot low.
- Garis Support ditampilkan secara otomatis pada chart.

📊 Volume Breakout Filter

- Menggunakan perbandingan EMA volume 5 dan EMA volume 10.
- Breakout difilter menggunakan "Volume Threshold".
- Membantu mengidentifikasi breakout yang disertai peningkatan aktivitas volume.

⚡ Break Detection

- Menampilkan tanda "B" ketika Support atau Resistance ditembus dengan kondisi volume yang memenuhi filter.
- Mendeteksi breakout bullish maupun bearish.

🕯️ Bull Wick & Bear Wick

- Menampilkan "Bull Wick" ketika terjadi breakout Resistance dengan karakteristik candle bullish wick.
- Menampilkan "Bear Wick" ketika terjadi breakout Support dengan karakteristik candle bearish wick.

🔔 Alarm Support & Resistance Broken
Tersedia alert untuk:

- Support Broken
- Resistance Broken

🔔 Alarm Level Baru
Indikator juga dilengkapi alarm ketika:

- Resistance baru terbentuk.
- Support baru terbentuk.

Alarm dapat digunakan melalui fitur Create Alert di TradingView.

Pengaturan

Pengguna dapat mengatur:

- Show Breaks
- Left Bars
- Right Bars
- Volume Threshold

Pengaturan default:

- Left Bars: 15
- Right Bars: 15
- Volume Threshold: 20

Catatan

Indikator ini merupakan alat bantu analisis teknikal dan tidak menjamin profit atau hasil trading tertentu. Gunakan bersama manajemen risiko dan analisis tambahan sebelum mengambil keputusan trading.

© Sultan Al Bahri — Mod by PRO MAX V11.1

Licensed under CC BY-NC-SA 4.0.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Sultan Al Bahri - Mod by PRO MAX V11.1

//@version=6
indicator(title=' Support and Resistance Levels', shorttitle=' brek [Sultan Al Bahri] + ALARM', overlay=true, max_bars_back=1000)

toggleBreaks = input(true, title='Show Breaks')
leftBars = input(15, title='Left Bars ')
rightBars = input(15, title='Right Bars')
volumeThresh = input(20, title='Volume Threshold')

highUsePivot = fixnan(ta.pivothigh(leftBars, rightBars)[1])
lowUsePivot = fixnan(ta.pivotlow(leftBars, rightBars)[1])

r1 = plot(highUsePivot, color=ta.change(highUsePivot) != 0 ? na : #FF0000, linewidth=3, offset=-(rightBars + 1), title='Resistance')
s1 = plot(lowUsePivot, color=ta.change(lowUsePivot) != 0 ? na : #233dee, linewidth=3, offset=-(rightBars + 1), title='Support')

// Volume % Calculation
short = ta.ema(volume, 5)
long = ta.ema(volume, 10)
osc = 100 * (short - long) / long

// For breaks with volume
plotshape(toggleBreaks and ta.crossunder(close, lowUsePivot) and not(open - close < high - open) and osc > volumeThresh, title='Break', text='B', style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.new(color.white, 0), size=size.tiny)

plotshape(toggleBreaks and ta.crossover(close, highUsePivot) and not(open - low > close - open) and osc > volumeThresh, title='Break', text='B', style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.new(color.white, 0), size=size.tiny)

// For bull / bear wicks
plotshape(toggleBreaks and ta.crossover(close, highUsePivot) and open - low > close - open, title='Break', text='Bull Wick', style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.new(color.white, 0), size=size.tiny)

plotshape(toggleBreaks and ta.crossunder(close, lowUsePivot) and open - close < high - open, title='Break', text='Bear Wick', style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.new(color.white, 0), size=size.tiny)

// === ALARM LAMA (BREAK) - SUDAH ADA ===
alertcondition(ta.crossunder(close, lowUsePivot) and osc > volumeThresh, title='Support Broken', message='Support Broken - {{ticker}} Jebol Support di {{close}}')

alertcondition(ta.crossover(close, highUsePivot) and osc > volumeThresh, title='Resistance Broken', message='Resistance Broken - {{ticker}} Jebol Resistance di {{close}}')

// === ALARM BARU (GARIS BARU MUNCUL) - TAMBAHAN PRO MAX ===
// Deteksi perubahan level
isNewResistance = ta.change(highUsePivot) != 0
isNewSupport = ta.change(lowUsePivot) != 0

// AlertCondition biar muncul di menu Create Alert
alertcondition(isNewResistance, title='⚠️ Resistance BARU Muncul', message='RESISTANCE BARU muncul di {{ticker}} Level: {{plot("Resistance")}} - Harga sekarang {{close}}')

alertcondition(isNewSupport, title='⚠️ Support BARU Muncul', message='SUPPORT BARU muncul di {{ticker}} Level: {{plot("Support")}} - Harga sekarang {{close}}')

// Alert() otomatis - lebih keras, langsung bunyi tanpa setting manual
if isNewResistance
    alert('🔴 RESISTANCE BARU TERBENTUK: ' + syminfo.ticker + ' Level ' + str.tostring(highUsePivot) + ' | Harga: ' + str.tostring(close), alert.freq_once_per_bar_close)

if isNewSupport
    alert('🔵 SUPPORT BARU TERBENTUK: ' + syminfo.ticker + ' Level ' + str.tostring(lowUsePivot) + ' | Harga: ' + str.tostring(close), alert.freq_once_per_bar_close)
````
