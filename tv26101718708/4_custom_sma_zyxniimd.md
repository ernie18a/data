# 4 Custom SMA

- url: https://www.tradingview.com/script/zYxNIimd/
- type: indicator
- pine_id: PUB;c0a12b35f5a84943ad05d46646010f10
- version: 2.0

## Description

Saya ingin membagikan skrip indikator sederhana namun sangat esensial untuk menjaga chart tetap bersih (clean chart). Dibandingkan harus memasukkan 4 indikator Moving Average terpisah yang memakan kuota slot indikator (terutama untuk pengguna akun gratis), skrip ini menggabungkan 4 garis Simple Moving Average (SMA) sekaligus ke dalam satu indikator.

Skrip ini sudah ditulis menggunakan Pine Script Versi 6 terbaru, sehingga kodenya lebih optimal, ringan, dan mengikuti standar sintaksis TradingView masa kini.

Fitur Utama:
Multiguna dalam Satu Indikator: Menghemat ruang chart dengan menggabungkan 4 SMA (misalnya untuk melihat tren jangka pendek, menengah, hingga jangka panjang sekaligus).

Fully Customizable: Panjang periode (length) dan warna masing-masing garis SMA bisa diubah dengan sangat mudah melalui menu pengaturan.

Tampilan Pengaturan yang Rapi: Input telah dikelompokkan (grouped) ke dalam blok "Pengaturan Panjang" dan "Pengaturan Warna" agar nyaman dilihat dan mudah dikonfigurasi.

Optimasi Versi 6: Menggunakan namespace ta.sma() dan fungsi input modern (input.int & input.color).

## Source Code

````pine
//@version=6
indicator("4 Custom SMA (Simple)", shorttitle="4xSMA", overlay=true)

// --- INPUT & KONFIGURASI (Kombinasi On/Off, Length, Warna dalam 1 Baris) ---
show1 = input.bool(true, "", inline="SMA1")
len1  = input.int(13, "SMA 1", minval=1, inline="SMA1")
col1  = input.color(color.blue, "", inline="SMA1")

show2 = input.bool(true, "", inline="SMA2")
len2  = input.int(26, "SMA 2", minval=1, inline="SMA2")
col2  = input.color(color.red, "", inline="SMA2")

show3 = input.bool(true, "", inline="SMA3")
len3  = input.int(50, "SMA 3", minval=1, inline="SMA3")
col3  = input.color(color.orange, "", inline="SMA3")

show4 = input.bool(true, "", inline="SMA4")
len4  = input.int(200, "SMA 4", minval=1, inline="SMA4")
col4  = input.color(color.green, "", inline="SMA4")

// --- KALKULASI & PLOT ---
plot(show1 ? ta.sma(close, len1) : na, color=col1, title="SMA 1", linewidth=2)
plot(show2 ? ta.sma(close, len2) : na, color=col2, title="SMA 2", linewidth=2)
plot(show3 ? ta.sma(close, len3) : na, color=col3, title="SMA 3", linewidth=2)
plot(show4 ? ta.sma(close, len4) : na, color=col4, title="SMA 4", linewidth=2)
````
