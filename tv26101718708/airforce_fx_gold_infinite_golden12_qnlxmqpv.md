# AirForce FX - Gold Infinite Golden-1.2 

- url: https://www.tradingview.com/script/QNLxMQpV/
- type: indicator
- pine_id: PUB;0d33d124dc2d4c658e387205850d1287
- version: 4.0

## Description

AirForce FX - Gold Infinite (Golden-1.2 Precision)
Overview
Golden-1.2 adalah sistem navigasi perdagangan presisi tinggi yang dirancang khusus untuk instrumen XAUUSD (Gold) dan Major Forex Pairs. Indikator ini menggabungkan momentum moving average dengan sistem manajemen risiko dinamis dan dashboard statistik real-time untuk memberikan kendali penuh kepada "Squadron" (pengguna) dalam medan tempur market.

Key Features (Protocol 1.2)
Triple Threat EMA Radar: Menggunakan EMA 8 (Momentum/Red), EMA 21 (Base/Yellow), dan EMA 125 (Filter/Purple) untuk menentukan arah tren dan area entri yang valid.

Dynamic Command Dashboard: Panel info di sudut kanan atas yang melacak:

Initial Capital & Current Equity.

Daily PnL & Total PnL (7 Hari Terakhir).

Mission Stats: Jumlah target (TP) yang tercapai vs kegagalan (SL).

Winrate & Adaptive Lot Power.

Real-Time Tactical Labels: Setiap sinyal entri dilengkapi dengan harga entri yang presisi, ukuran lot otomatis, serta target TP/SL yang divisualisasikan langsung di chart.

Visual Tracking System: Garis proyeksi dinamis dan label PnL mengambang yang memantau profit/loss posisi berjalan secara real-time.

How to Deploy
Trend Alignment: Pastikan EMA 8 dan 21 berada di sisi yang benar dari EMA 125 untuk filter tren jangka panjang.

Gap Analysis: Sistem hanya akan aktif jika terdapat jarak (gap) yang cukup antara EMA Merah dan Kuning, menandakan momentum yang sehat.

The Mission: Masuk saat harga melakukan retest ke area EMA 8 (Red Layer) atau EMA 21 (Yellow Layer). Ikuti instruksi TP/SL pada laber yang muncul.

Risk Disclaimer
Perdagangan finansial memiliki risiko tinggi. Golden-1.2 adalah alat bantu analisis teknis. Keputusan akhir tetap berada di tangan masing-masing pilot.

"Fly with Precision, Trade with Discipline."
Developed by Asta Asyura - AirForce FX Command Center.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstaAsyura_AirForceFX
// Kode Protokol: Golden-1.2 (INSTANT EXECUTION & VISUAL LOCKED)

//@version=6
indicator("AirForce FX - Gold Infinite Golden-1.2 Instant", overlay=true, max_labels_count=500)

// --- [SISTEM INTI: LOCKED] ---
ema8_len   = input.int(8, "EMA Merah (Momentum)")
ema21_len  = input.int(21, "EMA Kuning (Base)")
ema125_len = input.int(125, "EMA Ungu (Filter)")
min_gap_pts_mom = input.float(1.5, "Gap Merah-Kuning (Point)", step=0.1)
warn_dist = input.float(1.0, "Radar Radius (Gold Points)", step=0.1) 

// --- [FILTER WAKTU: 1 MINGGU TERAKHIR] ---
one_week_ms = 7 * 24 * 60 * 60 * 1000
is_active = (timenow - time) <= one_week_ms

// --- [FIXED LOT & DYNAMIC STATS] ---
var float total_pnl = 0.0, var float daily_pnl = 0.0
var int wins = 0, var int losses = 0, var int total_completed = 0
initial_balance = 5000.0
float full_lot = 0.1 

calc_pnl(entry, exit, lot, is_buy) =>
    mult = is_buy ? (exit - entry) : (entry - exit)
    mult * 100 * lot

if ta.change(time("D")) != 0
    daily_pnl := 0.0

// --- [LOGIKA RADAR] ---
ema8 = ta.ema(close, ema8_len), ema21 = ta.ema(close, ema21_len), ema125 = ta.ema(close, ema125_len)
gap_mk = math.abs(ema8 - ema21)
is_bullish = (ema8 > ema21) and (gap_mk >= min_gap_pts_mom)
is_bearish = (ema8 < ema21) and (gap_mk >= min_gap_pts_mom)

// --- [LOGIKA PERINGATAN & INSTANT TRIGGER] ---
// Radar muncul saat harga mendekati radius 1.0
near_ema8  = math.abs(low - ema8) <= warn_dist or math.abs(high - ema8) <= warn_dist
near_ema21 = math.abs(low - ema21) <= warn_dist or math.abs(high - ema21) <= warn_dist
alert_radar = (near_ema8 or near_ema21) and (is_bullish or is_bearish)

// --- [STORAGE & VISUAL LINES] ---
var bool act8 = false, var float e8 = na, var float tp8 = na, var float sl8 = na, var int b8 = 0
var label float_lab8 = na
var bool act21 = false, var float e21 = na, var float tp21 = na, var float sl21 = na, var int b21 = 0
var label float_lab21 = na

var line f_tp8 = line.new(na, na, na, na, color=color.new(color.lime, 20), style=line.style_dashed)
var line f_sl8 = line.new(na, na, na, na, color=color.new(color.red, 20), style=line.style_dashed)
var line f_tp21 = line.new(na, na, na, na, color=color.new(color.lime, 20), style=line.style_dashed)
var line f_sl21 = line.new(na, na, na, na, color=color.new(color.red, 20), style=line.style_dashed)

// --- [MONITORING & ALERT LOGIC] ---
var bool alert_entry = false, var bool alert_exit = false, var string alert_msg = ""
alert_entry := false, alert_exit := false

if act8
    line.set_xy1(f_tp8, b8, tp8), line.set_xy2(f_tp8, bar_index + 10, tp8)
    line.set_xy1(f_sl8, b8, sl8), line.set_xy2(f_sl8, bar_index + 10, sl8)
    cur_p8 = calc_pnl(e8, close, full_lot, tp8 > sl8)
    label.set_xy(float_lab8, bar_index + 2, close)
    label.set_text(float_lab8, "RED PnL: $" + str.tostring(cur_p8, "#.##"))
    label.set_textcolor(float_lab8, cur_p8 >= 0 ? color.lime : color.red)
    
    hit_tp8 = tp8 > sl8 ? high >= tp8 : low <= tp8
    hit_sl8 = tp8 > sl8 ? low <= sl8 : high >= sl8
    if hit_tp8 or hit_sl8
        alert_exit := true
        pnl_8 = calc_pnl(e8, hit_tp8 ? tp8 : sl8, full_lot, tp8 > sl8)
        total_pnl += pnl_8, daily_pnl += pnl_8, total_completed += 1
        wins := hit_tp8 ? wins + 1 : wins, losses := hit_sl8 ? losses + 1 : losses
        label.new(bar_index, high, "MISSION: RED " + (hit_tp8 ? "TP 🎯" : "SL 💀"), color=color.new(color.red, 20), textcolor=color.white, size=size.small)
        act8 := false, label.delete(float_lab8), line.set_xy1(f_tp8, na, na), line.set_xy1(f_sl8, na, na)

if act21
    line.set_xy1(f_tp21, b21, tp21), line.set_xy2(f_tp21, bar_index + 10, tp21)
    line.set_xy1(f_sl21, b21, sl21), line.set_xy2(f_sl21, bar_index + 10, sl21)
    cur_p21 = calc_pnl(e21, close, full_lot, tp21 > sl21)
    label.set_xy(float_lab21, bar_index + 2, close)
    label.set_text(float_lab21, "YLW PnL: $" + str.tostring(cur_p21, "#.##"))
    label.set_textcolor(float_lab21, cur_p21 >= 0 ? color.lime : color.red)
    
    hit_tp21 = tp21 > sl21 ? high >= tp21 : low <= tp21
    hit_sl21 = tp21 > sl21 ? low <= sl21 : high >= sl21
    if hit_tp21 or hit_sl21
        alert_exit := true
        pnl_21 = calc_pnl(e21, hit_tp21 ? tp21 : sl21, full_lot, tp21 > sl21)
        total_pnl += pnl_21, daily_pnl += pnl_21, total_completed += 1
        wins := hit_tp21 ? wins + 1 : wins, losses := hit_sl21 ? losses + 1 : losses
        label.new(bar_index, high, "MISSION: YLW " + (hit_tp21 ? "TP 🎯" : "SL 💀"), color=color.new(color.yellow, 10), textcolor=color.black, size=size.small)
        act21 := false, label.delete(float_lab21), line.set_xy1(f_tp21, na, na), line.set_xy1(f_sl21, na, na)

// --- [INSTANT TOUCH EXECUTION] ---
// Trigger aktif SEBELUM sentuh (lewat Radar) dan KUNCI saat high/low menyentuh EMA
if (is_active and not act8) and ((is_bullish and low <= ema8 + warn_dist) or (is_bearish and high >= ema8 - warn_dist))
    if (is_bullish and low <= ema8) or (is_bearish and high >= ema8) // KUNCI SAAT SENTUH
        act8 := true, b8 := bar_index, e8 := ema8
        tp8 := is_bullish ? e8 + 10.0 : e8 - 10.0
        sl8 := is_bullish ? e8 - 10.0 : e8 + 10.0
        alert_entry := true
        txt = (is_bullish ? "🚀 BUY RED\n" : "📉 SELL RED\n") + "Entry: " + str.tostring(e8, "#.##") + "\nLot: 0.10\nTP: " + str.tostring(tp8, "#.##") + "\nSL: " + str.tostring(sl8, "#.##")
        label.new(bar_index, is_bullish ? low : high, txt, color=color.new(color.red, 20), textcolor=color.white, style=is_bullish ? label.style_label_up : label.style_label_down)
        float_lab8 := label.new(bar_index, high, "RED PnL: $0.00", color=color.new(color.black, 10), textcolor=color.white, style=label.style_label_left)

if (is_active and not act21) and ((is_bullish and low <= ema21 + warn_dist) or (is_bearish and high >= ema21 - warn_dist))
    if (is_bullish and low <= ema21) or (is_bearish and high >= ema21) // KUNCI SAAT SENTUH
        act21 := true, b21 := bar_index, e21 := ema21
        tp21 := is_bullish ? e21 + 10.0 : e21 - 10.0
        sl21 := is_bullish ? e21 - 10.0 : e21 + 10.0
        alert_entry := true
        txt = (is_bullish ? "🚀 BUY YLW\n" : "📉 SELL YLW\n") + "Entry: " + str.tostring(e21, "#.##") + "\nLot: 0.10\nTP: " + str.tostring(tp21, "#.##") + "\nSL: " + str.tostring(sl21, "#.##")
        label.new(bar_index, is_bullish ? low : high, txt, color=color.new(color.yellow, 10), textcolor=color.black, style=is_bullish ? label.style_label_up : label.style_label_down)
        float_lab21 := label.new(bar_index, high, "YLW PnL: $0.00", color=color.new(color.black, 10), textcolor=color.white, style=label.style_label_left)

// --- [ALERTS & DASHBOARD RETAINED] ---
alertcondition(alert_radar, title="RADAR: Mendekati Area", message="Siaga! Harga mendekati area.")
alertcondition(alert_entry, title="Mission Started", message="Entry Executed")

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
    table.cell(tb, 0, 3, "Hasil Trade Harian", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 3, "$" + str.tostring(daily_pnl, "#.##"), bgcolor=bg, text_color=daily_pnl >= 0 ? color.lime : color.red)
    table.cell(tb, 0, 4, "Total PnL (7D)", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 4, "$" + str.tostring(total_pnl, "#.##"), bgcolor=bg, text_color=total_pnl >= 0 ? color.lime : color.red)
    table.cell(tb, 0, 5, "Jumlah Trade (7D)", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 5, str.tostring(total_completed) + " MISI", bgcolor=bg, text_color=color.white)
    table.cell(tb, 0, 6, "Misi TP vs SL", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 6, str.tostring(wins) + " ✅ / " + str.tostring(losses) + " ❌", bgcolor=bg, text_color=color.yellow)
    table.cell(tb, 0, 7, "Winrate / Lot", bgcolor=bg, text_color=color.white)
    table.cell(tb, 1, 7, str.tostring(wr, "#.#") + "% / 0.10", bgcolor=bg, text_color=color.orange)

plot(ema8, color=color.red, linewidth=2), plot(ema21, color=color.yellow, linewidth=2), plot(ema125, color=color.purple, linewidth=3)
````
