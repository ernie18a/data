# AirForce FX - BTC Infinite Golden_1.2

- url: https://www.tradingview.com/script/NlJ1aKTN/
- type: indicator
- pine_id: PUB;dbbbd2ac17a04497899c6aef2d1c2304
- version: 1.0

## Description

AirForce FX - BTC Infinite Golden-1.2 (Lot 0.1 Edition)
Overview
BTC Infinite Golden-1.2 adalah modul navigasi tempur khusus Bitcoin (BTCUSD) yang dirancang untuk presisi tinggi di pasar crypto. Menggunakan fondasi strategi EMA Trinity, script ini bukan sekadar indikator sinyal, melainkan sebuah Interactive Trading Station yang memonitor ekuitas, PnL real-time, dan manajemen risiko secara otomatis langsung di chart Anda.

Key Performance Systems
The Trinity Core: Memanfaatkan sinkronisasi EMA 8 (Momentum), EMA 21 (Base), dan EMA 125 (Filter Tren Utama) untuk mendeteksi peluang pantulan (retest) yang akurat.

Mission-Based Execution:

Mission RED: Eksekusi taktis pada momentum EMA 8.

Mission YLW: Eksekusi strategis pada pertahanan EMA 21.

Safe-Lot & Distance Logic: Dikalibrasi khusus dengan Fixed Lot 0.1 dan Target Jarak $300 (300 Points) per misi. Rasio ini dirancang untuk menjaga akun tetap stabil dari volatilitas Bitcoin yang ekstrem.

Advanced Features
Real-Time PnL Tracker: Label dinamis yang mengikuti harga untuk menunjukkan profit/loss berjalan secara aktual pada setiap posisi aktif.

Integrated Commander Dashboard: Panel statistika di pojok kanan atas yang menampilkan:

Equity Tracker: Pantauan modal awal ($5000) hingga ekuitas berjalan.

Performance Stats: Winrate, Total Misi, serta perbandingan TP vs SL.

PnL History: Ringkasan hasil harian dan performa akumulatif dalam 7 hari terakhir.

Visual Precision: Dilengkapi dengan garis target (TP/SL) otomatis dan label informasi lengkap agar trader tidak kehilangan arah saat market bergerak cepat.

Cara Penggunaan (Tactical Guide)
Status Kipas: Pastikan EMA dalam kondisi "Membuka" (Bullish/Bearish).

Entry Alert: Sinyal BUY/SELL akan muncul otomatis saat harga melakukan retest ke zona emas (EMA 8/21).

Automatic Monitoring: Setelah sinyal muncul, script akan mengambil alih monitoring hingga target $300 tercapai atau terkena proteksi SL.

"Trading bukan tentang seberapa sering Anda menarik pelatuk, tapi seberapa akurat peluru Anda mengenai sasaran. Let's hunt with precision." > — Asta Asyura, Founder of AirForce FX

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstaAsyura_AirForceFX
// Kode Protokol: Golden-1.2 (BTCUSD - LOT 0.1 - 300 PTS EDITION)

//@version=6
indicator("AirForce FX - BTC Infinite Golden-1.2 Pro", overlay=true, max_labels_count=500)

// --- [SISTEM INTI: BTC CALIBRATED] ---
ema8_len   = input.int(8, "EMA Merah (Momentum)")
ema21_len  = input.int(21, "EMA Kuning (Base)")
ema125_len = input.int(125, "EMA Ungu (Filter)")
min_gap_pts_btc = input.float(50.0, "Gap Merah-Kuning (BTC Points)", step=10.0)

// --- [FILTER WAKTU: 1 MINGGU TERAKHIR] ---
one_week_ms = 7 * 24 * 60 * 60 * 1000
is_active = (timenow - time) <= one_week_ms

// --- [FIXED LOT 0.1 & DYNAMIC STATS] ---
var float total_pnl = 0.0
var float daily_pnl = 0.0
var int wins = 0
var int losses = 0
var int total_completed = 0
initial_balance = 5000.0
float btc_lot = 0.1  
float btc_target = 300.0 // UPDATE: JARAK 300 DOLAR

// RUMUS BTC: (Exit - Entry) * Lot 0.1
calc_pnl_btc(entry, exit, lot, is_buy) =>
    mult = is_buy ? (exit - entry) : (entry - exit)
    mult * lot

if ta.change(time("D")) != 0
    daily_pnl := 0.0

// --- [LOGIKA RADAR] ---
ema8 = ta.ema(close, ema8_len), ema21 = ta.ema(close, ema21_len), ema125 = ta.ema(close, ema125_len)
gap_mk = math.abs(ema8 - ema21)
is_bullish = (ema8 > ema21) and (gap_mk >= min_gap_pts_btc)
is_bearish = (ema8 < ema21) and (gap_mk >= min_gap_pts_btc)

// --- [STORAGE & VISUAL LINES] ---
var bool act8 = false, var float e8 = na, var float tp8 = na, var float sl8 = na, var int b8 = 0
var label float_lab8 = na
var bool act21 = false, var float e21 = na, var float tp21 = na, var float sl21 = na, var int b21 = 0
var label float_lab21 = na

var line f_tp8 = line.new(na, na, na, na, color=color.new(color.lime, 20), style=line.style_dashed)
var line f_sl8 = line.new(na, na, na, na, color=color.new(color.red, 20), style=line.style_dashed)
var line f_tp21 = line.new(na, na, na, na, color=color.new(color.lime, 20), style=line.style_dashed)
var line f_sl21 = line.new(na, na, na, na, color=color.new(color.red, 20), style=line.style_dashed)

// --- [MONITORING & ALERT BTC] ---
var bool alert_entry = false
var bool alert_exit = false
var string alert_msg = ""

if act8
    line.set_xy1(f_tp8, b8, tp8), line.set_xy2(f_tp8, bar_index + 10, tp8)
    line.set_xy1(f_sl8, b8, sl8), line.set_xy2(f_sl8, bar_index + 10, sl8)
    cur_p8 = calc_pnl_btc(e8, close, btc_lot, tp8 > sl8)
    label.set_xy(float_lab8, bar_index + 2, close)
    label.set_text(float_lab8, "RED PnL: $" + str.tostring(cur_p8, "#.##"))
    label.set_textcolor(float_lab8, cur_p8 >= 0 ? color.lime : color.red)
    
    hit_tp8 = tp8 > sl8 ? high >= tp8 : low <= tp8
    hit_sl8 = tp8 > sl8 ? low <= sl8 : high >= sl8
    if hit_tp8 or hit_sl8
        alert_exit := true
        alert_msg := "BTC RED MISSION COMPLETED: " + (hit_tp8 ? "TP 🎯" : "SL 💀")
        total_completed += 1
        pnl_8 = calc_pnl_btc(e8, hit_tp8 ? tp8 : sl8, btc_lot, tp8 > sl8)
        total_pnl += pnl_8
        daily_pnl += pnl_8
        if hit_tp8
            wins += 1
        else
            losses += 1
        label.new(bar_index, high, "MISSION RED: " + (hit_tp8 ? "TP 🎯" : "SL 💀"), color=color.new(color.red, 20), textcolor=color.white, size=size.small)
        act8 := false, label.delete(float_lab8), line.set_xy1(f_tp8, na, na), line.set_xy1(f_sl8, na, na)

if act21
    line.set_xy1(f_tp21, b21, tp21), line.set_xy2(f_tp21, bar_index + 10, tp21)
    line.set_xy1(f_sl21, b21, sl21), line.set_xy2(f_sl21, bar_index + 10, sl21)
    cur_p21 = calc_pnl_btc(e21, close, btc_lot, tp21 > sl21)
    label.set_xy(float_lab21, bar_index + 2, close)
    label.set_text(float_lab21, "YLW PnL: $" + str.tostring(cur_p21, "#.##"))
    label.set_textcolor(float_lab21, cur_p21 >= 0 ? color.lime : color.red)
    
    hit_tp21 = tp21 > sl21 ? high >= tp21 : low <= tp21
    hit_sl21 = tp21 > sl21 ? low <= sl21 : high >= sl21
    if hit_tp21 or hit_sl21
        alert_exit := true
        alert_msg := "BTC YELLOW MISSION COMPLETED: " + (hit_tp21 ? "TP 🎯" : "SL 💀")
        total_completed += 1
        pnl_21 = calc_pnl_btc(e21, hit_tp21 ? tp21 : sl21, btc_lot, tp21 > sl21)
        total_pnl += pnl_21
        daily_pnl += pnl_21
        if hit_tp21
            wins += 1
        else
            losses += 1
        label.new(bar_index, high, "MISSION YLW: " + (hit_tp21 ? "TP 🎯" : "SL 💀"), color=color.new(color.yellow, 10), textcolor=color.black, size=size.small)
        act21 := false, label.delete(float_lab21), line.set_xy1(f_tp21, na, na), line.set_xy1(f_sl21, na, na)

// --- [EXECUTION BTC] ---
if (is_active and not act8) and ((is_bullish and low <= ema8 and low[1] > ema8[1]) or (is_bearish and high >= ema8 and high[1] < ema8[1]))
    act8 := true, b8 := bar_index, e8 := ema8
    tp8 := is_bullish ? e8 + btc_target : e8 - btc_target
    sl8 := is_bullish ? e8 - btc_target : e8 + btc_target
    alert_entry := true
    alert_msg := "BTC RED ENTRY: " + str.tostring(e8)
    txt = (is_bullish ? "🚀 BUY BTC RED\n" : "📉 SELL BTC RED\n") + "Entry: " + str.tostring(e8, "#") + "\nLot: 0.10\nTP: " + str.tostring(tp8, "#") + "\nSL: " + str.tostring(sl8, "#")
    label.new(bar_index, is_bullish ? low : high, txt, color=color.new(color.red, 20), textcolor=color.white, style=is_bullish ? label.style_label_up : label.style_label_down)
    float_lab8 := label.new(bar_index, high, "RED PnL: $0.00", color=color.new(color.black, 10), textcolor=color.white, style=label.style_label_left)

if (is_active and not act21) and ((is_bullish and low <= ema21 and low[1] > ema21[1]) or (is_bearish and high >= ema21 and high[1] < ema21[1]))
    act21 := true, b21 := bar_index, e21 := ema21
    tp21 := is_bullish ? e21 + btc_target : e21 - btc_target
    sl21 := is_bullish ? e21 - btc_target : e21 + btc_target
    alert_entry := true
    alert_msg := "BTC YELLOW ENTRY: " + str.tostring(e21)
    txt = (is_bullish ? "🚀 BUY BTC YLW\n" : "📉 SELL BTC YLW\n") + "Entry: " + str.tostring(e21, "#") + "\nLot: 0.10\nTP: " + str.tostring(tp21, "#") + "\nSL: " + str.tostring(sl21, "#")
    label.new(bar_index, is_bullish ? low : high, txt, color=color.new(color.yellow, 10), textcolor=color.black, style=is_bullish ? label.style_label_up : label.style_label_down)
    float_lab21 := label.new(bar_index, high, "YLW PnL: $0.00", color=color.new(color.black, 10), textcolor=color.white, style=label.style_label_left)

// --- [DASHBOARD 8 BARIS] ---
wr = total_completed > 0 ? (wins * 100.0 / total_completed) : 0
var table tb = table.new(position.top_right, 2, 8, border_color=color.new(color.gray, 70), border_width=1)
if barstate.islast
    bg = color.new(color.black, 15)
    table.cell(tb, 0, 0, "COMMANDER", bgcolor=bg, text_color=color.orange)
    table.cell(tb, 1, 0, "AIRFORCE FX", bgcolor=bg, text_color=color.white)
    table.cell(tb, 0, 1, "Initial Capital", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 1, "$" + str.tostring(initial_balance, "#"), bgcolor=bg, text_color=color.white)
    table.cell(tb, 0, 2, "Current Equity", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 2, "$" + str.tostring(initial_balance + total_pnl, "#.##"), bgcolor=bg, text_color=color.lime)
    table.cell(tb, 0, 3, "Hasil BTC Harian", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 3, "$" + str.tostring(daily_pnl, "#.##"), bgcolor=bg, text_color=daily_pnl >= 0 ? color.lime : color.red)
    table.cell(tb, 0, 4, "Total PnL (7D)", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 4, "$" + str.tostring(total_pnl, "#.##"), bgcolor=bg, text_color=total_pnl >= 0 ? color.lime : color.red)
    table.cell(tb, 0, 5, "Jumlah Misi BTC", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 5, str.tostring(total_completed) + " MISI", bgcolor=bg, text_color=color.white)
    table.cell(tb, 0, 6, "BTC TP vs SL", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 6, str.tostring(wins) + " ✅ / " + str.tostring(losses) + " ❌", bgcolor=bg, text_color=color.yellow)
    table.cell(tb, 0, 7, "Winrate / Lot", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 7, str.tostring(wr, "#.#") + "% / 0.10", bgcolor=bg, text_color=color.orange)

plot(ema8, color=color.red, linewidth=2), plot(ema21, color=color.yellow, linewidth=2), plot(ema125, color=color.purple, linewidth=3)
````
