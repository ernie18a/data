# Momentum Candle By KempotStywn3435

- url: https://www.tradingview.com/script/yP7rke3t/
- type: indicator
- pine_id: PUB;b1b0765de73c485aa5bafe10e9421f02
- version: 2.0

## Description

Indikator ini dirancang khusus untuk mendeteksi lonjakan momentum (momentum spike) atau pergerakan breakout yang tiba-tiba dan signifikan di pasar. Indikator ini sangat cocok untuk trader dengan gaya scalping atau day trading yang mencari peluang masuk saat volume dan volatilitas pasar sedang tinggi.

Bagaimana Cara Kerjanya?
Indikator ini tidak sembarangan memberi sinyal pada setiap candle besar. Ada dua filter utama agar sinyal yang muncul benar-benar valid:

Perbandingan Relatif: Indikator akan menghitung rata-rata ukuran body dari 3 candle sebelumnya. Candle yang sedang berjalan harus lebih besar dari rata-rata tersebut berdasarkan faktor pengali (multiplier) yang bisa diatur. Ini memastikan kita menangkap pergerakan yang menonjol dari price action sebelumnya.

Filter Noise (Minimal Body Size): Untuk menghindari sinyal palsu saat pasar sedang konsolidasi/sepi (sideways), candle saat ini wajib mencapai ukuran minimum tertentu secara absolut.

Jika kedua syarat tersebut terpenuhi, indikator akan memunculkan tanda panah (hijau ke atas untuk momentum Bullish, dan merah ke bawah untuk momentum Bearish).

Fitur yang Bisa Disesuaikan (Settings):

Minimal Panjang Body: Kamu bisa mengatur seberapa besar ukuran murni body candle agar bisa divalidasi.

Pengali Ukuran (Multiplier): Standarnya adalah 1.5x lebih besar dari rata-rata 3 candle sebelumnya. Angka ini bisa kamu ubah sesuai dengan tingkat sensitivitas yang diinginkan.

⚠️ TIPS PENTING PENGGUNAAN (WAJIB DIBACA): ⚠️
Pengaturan "Minimal Panjang Body" menggunakan skala harga asli dari instrumen yang sedang kamu buka, bukan otomatis berbentuk pips. Kamu wajib menyesuaikan angka ini berdasarkan aset (pair) yang kamu tradingkan:

XAUUSD (Gold): Pergerakan 70 pips biasanya ditulis dengan angka 7.0 atau 0.7 (tergantung desimal broker kamu dan timeframe). Jika kamu biarkan angka 70, indikator mungkin tidak akan memunculkan panah sama sekali.

Forex Major (misal EURUSD): Pergerakan 70 pips ditulis dalam bentuk desimal seperti 0.0070.

Crypto (misal BTCUSDT): Kamu mungkin perlu menaikkan angkanya ke puluhan atau ratusan poin tergantung volatilitasnya.

Catatan: Indikator ini berfungsi sangat baik sebagai alat konfirmasi. Pastikan untuk selalu menggabungkannya dengan analisa teknikal lain

## Source Code

````pine
//@version=5
indicator("Momentum By KempotStywn3435", overlay=true)

// --- Menu Pengaturan ---
// Nilai bawaan diubah menjadi 9 sesuai permintaan
min_body_size = input.float(9.0, title="Minimal Panjang Body (Lebih dari ...)", step=1.0)

// Nilai bawaan pengali diubah menjadi 2 sesuai permintaan
size_multiplier = input.float(2.0, title="Pengali Ukuran dari 3 Candle Sebelumnya", step=0.1)

// --- Perhitungan Ukuran Body ---
// Math.abs digunakan agar hasilnya selalu positif (jarak absolut)
body_current = math.abs(close - open)       // Body candle saat ini
body_1 = math.abs(close[1] - open[1])       // Body 1 candle lalu
body_2 = math.abs(close[2] - open[2])       // Body 2 candle lalu
body_3 = math.abs(close[3] - open[3])       // Body 3 candle lalu

// Menghitung rata-rata dari 3 candle sebelumnya
avg_3_prev = (body_1 + body_2 + body_3) / 3

// --- Syarat Kondisi ---
// 1. Body candle saat ini HARUS LEBIH DARI batas minimal (9)
is_valid_size = body_current > min_body_size

// 2. Body saat ini lebih besar dari rata-rata 3 candle sebelumnya dikalikan faktor pengali (2)
is_breakout = body_current > (avg_3_prev * size_multiplier)

// Arah Candle
is_bullish = close > open
is_bearish = close < open

// Gabungan semua syarat
trigger_bull = is_valid_size and is_breakout and is_bullish
trigger_bear = is_valid_size and is_breakout and is_bearish

// --- Menampilkan Panah ---
// Panah ke atas warna hijau, diletakkan DI BAWAH candle jika momentum naik
plotshape(trigger_bull, title="Buy Arrow", style=shape.arrowup, location=location.belowbar, color=color.green, size=size.normal)

// Panah ke bawah warna merah, diletakkan DI ATAS candle jika momentum turun
plotshape(trigger_bear, title="Sell Arrow", style=shape.arrowdown, location=location.abovebar, color=color.red, size=size.normal)
````
