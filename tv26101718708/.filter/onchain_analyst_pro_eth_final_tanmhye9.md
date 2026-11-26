# Onchain Analyst PRO - ETH FINAL

- url: https://www.tradingview.com/script/TAnmHye9/
- type: indicator
- pine_id: PUB;c22f63a6b8854b29b38f0aacd918dc11
- version: 1.0

## Description

Onchain seviyeler, günlük haftalık seviyeleri destek ve dirençleri  yakından takip edebilmek için hazırlandı

## Source Code

````pine
//@version=5
indicator("Onchain Analyst PRO - ETH FINAL", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

// =====================================================
// 1) GENEL AYARLAR
// =====================================================
grp_genel = "1. Genel Ayarlar"
etiketleri_goster = input.bool(true, "Etiketleri Goster", group=grp_genel)
fiyatlari_goster = input.bool(true, "Etiketlerde Fiyat Goster", group=grp_genel)
cizgi_kalinligi = input.int(2, "Cizgi Kalinligi", minval=1, maxval=5, group=grp_genel)
bolge_seffaflik = input.int(85, "Bolge Seffafligi", minval=0, maxval=100, group=grp_genel)
etiket_boyutu = input.string("normal", "Etiket Boyutu", options=["small", "normal", "large"], group=grp_genel)
etiket_offset = input.int(8, "Etiket Mesafesi (Bar)", minval=1, maxval=100, group=grp_genel)

labelSize = size.normal
if etiket_boyutu == "small"
    labelSize := size.small
else if etiket_boyutu == "large"
    labelSize := size.large
else
    labelSize := size.normal

// =====================================================
// 2) RENKLER
// =====================================================
grp_renk = "2. Renkler"
renk_direnc = input.color(color.red, "Direnc Rengi", group=grp_renk)
renk_destek = input.color(color.lime, "Destek Rengi", group=grp_renk)
renk_notr = input.color(color.yellow, "Notr Rengi", group=grp_renk)
renk_likidite = input.color(color.purple, "Likidite Rengi", group=grp_renk)

renk_hafta_open = input.color(color.rgb(70, 120, 255), "Hafta Acilis Rengi", group=grp_renk)
renk_hafta_high = input.color(color.red, "Hafta Yuksek Rengi", group=grp_renk)
renk_hafta_low = input.color(color.lime, "Hafta Dusuk Rengi", group=grp_renk)
renk_eq = input.color(color.white, "EQ Rengi", group=grp_renk)

renk_ay_open = input.color(color.rgb(70, 120, 255), "Ay Acilis Rengi", group=grp_renk)
renk_ay_high = input.color(color.red, "Ay Yuksek Rengi", group=grp_renk)
renk_ay_low = input.color(color.lime, "Ay Dusuk Rengi", group=grp_renk)

renk_acc_dir = input.color(color.rgb(220, 60, 80), "Akumulasyon Direnc Bolgesi Rengi", group=grp_renk)
renk_acc_des = input.color(color.rgb(50, 210, 210), "Akumulasyon Destek Bolgesi Rengi", group=grp_renk)

renk_bolge1 = input.color(color.fuchsia, "Ekstra Bolge 1 Rengi", group=grp_renk)
renk_bolge2 = input.color(color.teal, "Ekstra Bolge 2 Rengi", group=grp_renk)
renk_bolge3 = input.color(color.purple, "Ekstra Bolge 3 Rengi", group=grp_renk)
renk_bolge4 = input.color(color.green, "Ekstra Bolge 4 Rengi", group=grp_renk)

// =====================================================
// 3) ANA ETH SEVIYELERI - HAZIR PRESET
// =====================================================
grp_core = "3. ETH Ana Seviyeler"

// ETH Price
show_1 = input.bool(true, "ETH Price Goster", group=grp_core)
name_1 = input.string("ETH Price [USD]", "ETH Price Ismi", group=grp_core)
price_1 = input.float(2327.71, "ETH Price", group=grp_core)
type_1 = input.string("Notr", "ETH Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// ETH Realized Price
show_2 = input.bool(true, "ETH Realized Price Goster", group=grp_core)
name_2 = input.string("ETH Realized Price [USD]", "ETH Realized Price Ismi", group=grp_core)
price_2 = input.float(2341.06, "ETH Realized Price", group=grp_core)
type_2 = input.string("Notr", "ETH Realized Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// Spent Price
show_3 = input.bool(true, "Spent Price Goster", group=grp_core)
name_3 = input.string("Spent Price", "Spent Price Ismi", group=grp_core)
price_3 = input.float(2380.63386395, "Spent Price", group=grp_core)
type_3 = input.string("Direnc", "Spent Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// Investor Price
show_4 = input.bool(true, "Investor Price Goster", group=grp_core)
name_4 = input.string("Investor Price", "Investor Price Ismi", group=grp_core)
price_4 = input.float(2056.39867826, "Investor Price", group=grp_core)
type_4 = input.string("Destek", "Investor Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// 111D MA
show_5 = input.bool(true, "111D MA Goster", group=grp_core)
name_5 = input.string("111D MA", "111D MA Ismi", group=grp_core)
price_5 = input.float(2371.8587502, "111D MA", group=grp_core)
type_5 = input.string("Direnc", "111D MA Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// 200D MA
show_6 = input.bool(true, "200D MA Goster", group=grp_core)
name_6 = input.string("200D MA", "200D MA Ismi", group=grp_core)
price_6 = input.float(2835.4062265, "200D MA", group=grp_core)
type_6 = input.string("Direnc", "200D MA Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// 200W MA
show_7 = input.bool(true, "200W MA Goster", group=grp_core)
name_7 = input.string("200W MA", "200W MA Ismi", group=grp_core)
price_7 = input.float(2444.34081313, "200W MA", group=grp_core)
type_7 = input.string("Direnc", "200W MA Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// STH
show_8 = input.bool(true, "STH Goster", group=grp_core)
name_8 = input.string("STH", "STH Ismi", group=grp_core)
price_8 = input.float(2574.30243068, "STH", group=grp_core)
type_8 = input.string("Direnc", "STH Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// LTH
show_9 = input.bool(true, "LTH Goster", group=grp_core)
name_9 = input.string("LTH", "LTH Ismi", group=grp_core)
price_9 = input.float(2006.72756204, "LTH", group=grp_core)
type_9 = input.string("Destek", "LTH Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// EMA7
show_10 = input.bool(true, "EMA7 Goster", group=grp_core)
name_10 = input.string("EMA7", "EMA7 Ismi", group=grp_core)
price_10 = input.float(2320.22176289, "EMA7", group=grp_core)
type_10 = input.string("Notr", "EMA7 Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// EMA20
show_11 = input.bool(true, "EMA20 Goster", group=grp_core)
name_11 = input.string("EMA20", "EMA20 Ismi", group=grp_core)
price_11 = input.float(2260.58891605, "EMA20", group=grp_core)
type_11 = input.string("Destek", "EMA20 Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// <3M Price
show_12 = input.bool(true, "< 3M Price Goster", group=grp_core)
name_12 = input.string("< 3M Price", "< 3M Price Ismi", group=grp_core)
price_12 = input.float(1612.46607057, "< 3M Price", group=grp_core)
type_12 = input.string("Destek", "< 3M Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// <6M Price
show_13 = input.bool(true, "< 6M Price Goster", group=grp_core)
name_13 = input.string("< 6M Price", "< 6M Price Ismi", group=grp_core)
price_13 = input.float(3915.46322243, "< 6M Price", group=grp_core)
type_13 = input.string("Direnc", "< 6M Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// <12M Price
show_14 = input.bool(true, "< 12M Price Goster", group=grp_core)
name_14 = input.string("< 12M Price", "< 12M Price Ismi", group=grp_core)
price_14 = input.float(4321.58542465, "< 12M Price", group=grp_core)
type_14 = input.string("Direnc", "< 12M Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// <2Y Price
show_15 = input.bool(true, "< 2Y Price Goster", group=grp_core)
name_15 = input.string("< 2Y Price", "< 2Y Price Ismi", group=grp_core)
price_15 = input.float(4336.41568129, "< 2Y Price", group=grp_core)
type_15 = input.string("Direnc", "< 2Y Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// <3Y Price
show_16 = input.bool(true, "< 3Y Price Goster", group=grp_core)
name_16 = input.string("< 3Y Price", "< 3Y Price Ismi", group=grp_core)
price_16 = input.float(4259.10468862, "< 3Y Price", group=grp_core)
type_16 = input.string("Direnc", "< 3Y Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// <5Y Price
show_17 = input.bool(true, "< 5Y Price Goster", group=grp_core)
name_17 = input.string("< 5Y Price", "< 5Y Price Ismi", group=grp_core)
price_17 = input.float(4108.47538204, "< 5Y Price", group=grp_core)
type_17 = input.string("Direnc", "< 5Y Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// <7Y Price
show_18 = input.bool(true, "< 7Y Price Goster", group=grp_core)
name_18 = input.string("< 7Y Price", "< 7Y Price Ismi", group=grp_core)
price_18 = input.float(3814.4672269, "< 7Y Price", group=grp_core)
type_18 = input.string("Direnc", "< 7Y Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// True Mean
show_19 = input.bool(true, "True Mean Price Goster", group=grp_core)
name_19 = input.string("True Mean Price", "True Mean Price Ismi", group=grp_core)
price_19 = input.float(2859.57106268, "True Mean Price", group=grp_core)
type_19 = input.string("Direnc", "True Mean Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// Active Realized Price
show_20 = input.bool(true, "Active Realized Price Goster", group=grp_core)
name_20 = input.string("Active Realized Price", "Active Realized Price Ismi", group=grp_core)
price_20 = input.float(3255.4095381, "Active Realized Price", group=grp_core)
type_20 = input.string("Direnc", "Active Realized Price Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_core)

// =====================================================
// 4) ETH AKUMULASYON FIYAT SEVIYELERI
// Simdilik kapali preset
// =====================================================
grp_acc = "4. ETH Akumulasyon Fiyat Seviyeleri"

acc_show_1w_res = input.bool(false, "1W Acc Direnc Goster", group=grp_acc)
acc_name_1w_res = input.string("1W Acc. Direnc", "1W Acc. Direnc Ismi", group=grp_acc)
acc_price_1w_res = input.float(2413.0, "1W Acc. Direnc Fiyati", group=grp_acc)

acc_show_1w_sup = input.bool(false, "1W Acc Destek Goster", group=grp_acc)
acc_name_1w_sup = input.string("1W Acc. Destek", "1W Acc. Destek Ismi", group=grp_acc)
acc_price_1w_sup = input.float(2328.0, "1W Acc. Destek Fiyati", group=grp_acc)

acc_show_1m_res = input.bool(false, "1M Acc Direnc Goster", group=grp_acc)
acc_name_1m_res = input.string("1M Acc. Direnc", "1M Acc. Direnc Ismi", group=grp_acc)
acc_price_1m_res = input.float(2413.0, "1M Acc. Direnc Fiyati", group=grp_acc)

acc_show_1m_sup = input.bool(false, "1M Acc Destek Goster", group=grp_acc)
acc_name_1m_sup = input.string("1M Acc. Destek", "1M Acc. Destek Ismi", group=grp_acc)
acc_price_1m_sup = input.float(2328.0, "1M Acc. Destek Fiyati", group=grp_acc)

acc_show_3m_res = input.bool(false, "3M Acc Direnc Goster", group=grp_acc)
acc_name_3m_res = input.string("3M Acc. Direnc", "3M Acc. Direnc Ismi", group=grp_acc)
acc_price_3m_res = input.float(2413.0, "3M Acc. Direnc Fiyati", group=grp_acc)

acc_show_3m_sup = input.bool(false, "3M Acc Destek Goster", group=grp_acc)
acc_name_3m_sup = input.string("3M Acc. Destek", "3M Acc. Destek Ismi", group=grp_acc)
acc_price_3m_sup = input.float(2328.0, "3M Acc. Destek Fiyati", group=grp_acc)

acc_show_6m_res = input.bool(false, "6M Acc Direnc Goster", group=grp_acc)
acc_name_6m_res = input.string("6M Acc. Direnc", "6M Acc. Direnc Ismi", group=grp_acc)
acc_price_6m_res = input.float(2413.0, "6M Acc. Direnc Fiyati", group=grp_acc)

acc_show_6m_sup = input.bool(false, "6M Acc Destek Goster", group=grp_acc)
acc_name_6m_sup = input.string("6M Acc. Destek", "6M Acc. Destek Ismi", group=grp_acc)
acc_price_6m_sup = input.float(2328.0, "6M Acc. Destek Fiyati", group=grp_acc)

// =====================================================
// 5) GENEL AKUMULASYON KUTULARI
// =====================================================
grp_acc_box = "5. Akumulasyon Bolgeleri"
acc_box_show_1 = input.bool(false, "Akumulasyon Direnc Bolgesi Goster", group=grp_acc_box)
acc_box_name_1 = input.string("AKUMULASYON DIRENC BOLGESI", "Akumulasyon Direnc Ismi", group=grp_acc_box)
acc_box_top_1 = input.float(2413.0, "Akumulasyon Direnc Ust", group=grp_acc_box)
acc_box_bot_1 = input.float(2380.63, "Akumulasyon Direnc Alt", group=grp_acc_box)

acc_box_show_2 = input.bool(false, "Akumulasyon Destek Bolgesi Goster", group=grp_acc_box)
acc_box_name_2 = input.string("AKUMULASYON DESTEK BOLGESI", "Akumulasyon Destek Ismi", group=grp_acc_box)
acc_box_top_2 = input.float(2328.0, "Akumulasyon Destek Ust", group=grp_acc_box)
acc_box_bot_2 = input.float(2260.58, "Akumulasyon Destek Alt", group=grp_acc_box)

// =====================================================
// 6) ONCEKI HAFTA
// =====================================================
grp_week = "6. Onceki Hafta Seviyeleri"
week_show_open = input.bool(true, "Onceki Hafta Acilis", group=grp_week)
week_show_high = input.bool(true, "Onceki Hafta Yuksek", group=grp_week)
week_show_low = input.bool(true, "Onceki Hafta Dusuk", group=grp_week)
week_show_eq = input.bool(true, "Onceki Hafta EQ", group=grp_week)

prev_week_open = request.security(syminfo.tickerid, "W", open[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prev_week_high = request.security(syminfo.tickerid, "W", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prev_week_low = request.security(syminfo.tickerid, "W", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prev_week_eq = (prev_week_high + prev_week_low) / 2.0

// =====================================================
// 7) ONCEKI AY
// =====================================================
grp_month = "7. Onceki Ay Seviyeleri"
month_show_open = input.bool(true, "Onceki Ay Acilis", group=grp_month)
month_show_high = input.bool(true, "Onceki Ay Yuksek", group=grp_month)
month_show_low = input.bool(true, "Onceki Ay Dusuk", group=grp_month)
month_show_eq = input.bool(true, "Onceki Ay EQ", group=grp_month)

prev_month_open = request.security(syminfo.tickerid, "M", open[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prev_month_high = request.security(syminfo.tickerid, "M", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prev_month_low = request.security(syminfo.tickerid, "M", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prev_month_eq = (prev_month_high + prev_month_low) / 2.0

// =====================================================
// 7A) HAFTA / AY BASLANGIC BARLARI
// =====================================================
new_week_bar = ta.change(time("W")) != 0
new_month_bar = ta.change(time("M")) != 0

var int this_week_start_bar = na
var int this_month_start_bar = na

if new_week_bar
    this_week_start_bar := bar_index
if new_month_bar
    this_month_start_bar := bar_index

week_active = not na(this_week_start_bar) and bar_index >= this_week_start_bar
month_active = not na(this_month_start_bar) and bar_index >= this_month_start_bar

// =====================================================
// 8) ETH EKSTRA FIYAT SEVIYELERI
// =====================================================
grp_extra = "8. ETH Ekstra Fiyat Seviyeleri"

extra_show_1 = input.bool(true, "Ekstra 1 Goster", group=grp_extra)
extra_name_1 = input.string("4H Teknik Direnc", "Ekstra 1 Ismi", group=grp_extra)
extra_price_1 = input.float(2413.0, "Ekstra 1 Fiyat", group=grp_extra)
extra_type_1 = input.string("Direnc", "Ekstra 1 Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_extra)

extra_show_2 = input.bool(true, "Ekstra 2 Goster", group=grp_extra)
extra_name_2 = input.string("4H Teknik Destek", "Ekstra 2 Ismi", group=grp_extra)
extra_price_2 = input.float(2328.0, "Ekstra 2 Fiyat", group=grp_extra)
extra_type_2 = input.string("Destek", "Ekstra 2 Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_extra)

extra_show_3 = input.bool(true, "Ekstra 3 Goster", group=grp_extra)
extra_name_3 = input.string("RP 0.8", "Ekstra 3 Ismi", group=grp_extra)
extra_price_3 = input.float(1872.84588482, "Ekstra 3 Fiyat", group=grp_extra)
extra_type_3 = input.string("Destek", "Ekstra 3 Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_extra)

extra_show_4 = input.bool(true, "Ekstra 4 Goster", group=grp_extra)
extra_name_4 = input.string("RP 2.4", "Ekstra 4 Ismi", group=grp_extra)
extra_price_4 = input.float(5618.53765445, "Ekstra 4 Fiyat", group=grp_extra)
extra_type_4 = input.string("Direnc", "Ekstra 4 Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_extra)

// =====================================================
// 9) ETH EKSTRA BOLGE KUTULARI
// =====================================================
grp_boxes = "9. ETH Ekstra Bolge Kutulari"

box_show_1 = input.bool(false, "Bolge 1 Goster", group=grp_boxes)
box_name_1 = input.string("Direnc Bolgesi", "Bolge 1 Ismi", group=grp_boxes)
box_top_1 = input.float(2413.0, "Bolge 1 Ust", group=grp_boxes)
box_bot_1 = input.float(2380.63, "Bolge 1 Alt", group=grp_boxes)
box_type_1 = input.string("Direnc", "Bolge 1 Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_boxes)

box_show_2 = input.bool(false, "Bolge 2 Goster", group=grp_boxes)
box_name_2 = input.string("Destek Bolgesi", "Bolge 2 Ismi", group=grp_boxes)
box_top_2 = input.float(2328.0, "Bolge 2 Ust", group=grp_boxes)
box_bot_2 = input.float(2260.58, "Bolge 2 Alt", group=grp_boxes)
box_type_2 = input.string("Destek", "Bolge 2 Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_boxes)

box_show_3 = input.bool(false, "Bolge 3 Goster", group=grp_boxes)
box_name_3 = input.string("Likidite Direnci", "Bolge 3 Ismi", group=grp_boxes)
box_top_3 = input.float(2859.57, "Bolge 3 Ust", group=grp_boxes)
box_bot_3 = input.float(2574.30, "Bolge 3 Alt", group=grp_boxes)
box_type_3 = input.string("Likidite", "Bolge 3 Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_boxes)

box_show_4 = input.bool(false, "Bolge 4 Goster", group=grp_boxes)
box_name_4 = input.string("Makro Destek", "Bolge 4 Ismi", group=grp_boxes)
box_top_4 = input.float(2056.39, "Bolge 4 Ust", group=grp_boxes)
box_bot_4 = input.float(1872.84, "Bolge 4 Alt", group=grp_boxes)
box_type_4 = input.string("Destek", "Bolge 4 Tur", options=["Direnc", "Destek", "Notr", "Likidite"], group=grp_boxes)

// =====================================================
// 10) OBJE DIZILERI
// =====================================================
var line[] linesArr = array.new_line()
var label[] labelsArr = array.new_label()
var box[] boxesArr = array.new_box()

// =====================================================
// 11) YARDIMCI FONKSIYONLAR
// =====================================================
f_fmt(_v) =>
    str.tostring(_v, "#.##")

f_color(_type, _name) =>
    color c = renk_notr
    if _name == acc_box_name_1
        c := renk_acc_dir
    else if _name == acc_box_name_2
        c := renk_acc_des
    else if _name == box_name_1
        c := renk_bolge1
    else if _name == box_name_2
        c := renk_bolge2
    else if _name == box_name_3
        c := renk_bolge3
    else if _name == box_name_4
        c := renk_bolge4
    else if _type == "Direnc"
        c := renk_direnc
    else if _type == "Destek"
        c := renk_destek
    else if _type == "Likidite"
        c := renk_likidite
    else
        c := renk_notr
    c

f_label_text(_name, _price) =>
    string txt = _name
    if fiyatlari_goster
        txt := _name + " | $" + f_fmt(_price)
    txt

f_clear_all() =>
    int lnSize = array.size(linesArr)
    if lnSize > 0
        for i = 0 to lnSize - 1
            line.delete(array.get(linesArr, i))
    int lbSize = array.size(labelsArr)
    if lbSize > 0
        for i = 0 to lbSize - 1
            label.delete(array.get(labelsArr, i))
    int bxSize = array.size(boxesArr)
    if bxSize > 0
        for i = 0 to bxSize - 1
            box.delete(array.get(boxesArr, i))
    array.clear(linesArr)
    array.clear(labelsArr)
    array.clear(boxesArr)

f_draw_line(_price, _name, _type, _show) =>
    if _show and not na(_price)
        color c = f_color(_type, _name)
        line ln = line.new(x1=bar_index, y1=_price, x2=bar_index + 1, y2=_price, xloc=xloc.bar_index, extend=extend.right, color=c, width=cizgi_kalinligi)
        array.push(linesArr, ln)
        if etiketleri_goster
            label lb = label.new(x=bar_index + etiket_offset, y=_price, text=f_label_text(_name, _price), xloc=xloc.bar_index, style=label.style_label_left, color=c, textcolor=color.white, size=labelSize)
            array.push(labelsArr, lb)

f_draw_box(_top, _bot, _name, _type, _show) =>
    if _show and not na(_top) and not na(_bot)
        float topV = math.max(_top, _bot)
        float botV = math.min(_top, _bot)
        float midV = (topV + botV) / 2.0
        color c = f_color(_type, _name)
        box bx = box.new(left=bar_index, top=topV, right=bar_index + 1, bottom=botV, xloc=xloc.bar_index, extend=extend.right, border_color=c, bgcolor=color.new(c, bolge_seffaflik))
        array.push(boxesArr, bx)
        if etiketleri_goster
            string txt = _name
            if fiyatlari_goster
                txt := _name + " | $" + f_fmt(botV) + " - $" + f_fmt(topV)
            label lb = label.new(x=bar_index + etiket_offset, y=midV, text=txt, xloc=xloc.bar_index, style=label.style_label_left, color=c, textcolor=color.white, size=labelSize)
            array.push(labelsArr, lb)

// =====================================================
// 11A) HAFTA / AY MARKER SERILERI
// =====================================================
week_open_plot = week_show_open and week_active ? prev_week_open : na
week_high_plot = week_show_high and week_active ? prev_week_high : na
week_low_plot = week_show_low and week_active ? prev_week_low : na
week_eq_plot = week_show_eq and week_active ? prev_week_eq : na

month_open_plot = month_show_open and month_active ? prev_month_open : na
month_high_plot = month_show_high and month_active ? prev_month_high : na
month_low_plot = month_show_low and month_active ? prev_month_low : na
month_eq_plot = month_show_eq and month_active ? prev_month_eq : na

// =====================================================
// 12) HER SON BARDA TEMIZLE VE YENIDEN CIZ
// =====================================================
if barstate.islast
    f_clear_all()

    f_draw_line(price_1, name_1, type_1, show_1)
    f_draw_line(price_2, name_2, type_2, show_2)
    f_draw_line(price_3, name_3, type_3, show_3)
    f_draw_line(price_4, name_4, type_4, show_4)
    f_draw_line(price_5, name_5, type_5, show_5)
    f_draw_line(price_6, name_6, type_6, show_6)
    f_draw_line(price_7, name_7, type_7, show_7)
    f_draw_line(price_8, name_8, type_8, show_8)
    f_draw_line(price_9, name_9, type_9, show_9)
    f_draw_line(price_10, name_10, type_10, show_10)
    f_draw_line(price_11, name_11, type_11, show_11)
    f_draw_line(price_12, name_12, type_12, show_12)
    f_draw_line(price_13, name_13, type_13, show_13)
    f_draw_line(price_14, name_14, type_14, show_14)
    f_draw_line(price_15, name_15, type_15, show_15)
    f_draw_line(price_16, name_16, type_16, show_16)
    f_draw_line(price_17, name_17, type_17, show_17)
    f_draw_line(price_18, name_18, type_18, show_18)
    f_draw_line(price_19, name_19, type_19, show_19)
    f_draw_line(price_20, name_20, type_20, show_20)

    f_draw_line(acc_price_1w_res, acc_name_1w_res, "Direnc", acc_show_1w_res)
    f_draw_line(acc_price_1w_sup, acc_name_1w_sup, "Destek", acc_show_1w_sup)
    f_draw_line(acc_price_1m_res, acc_name_1m_res, "Direnc", acc_show_1m_res)
    f_draw_line(acc_price_1m_sup, acc_name_1m_sup, "Destek", acc_show_1m_sup)
    f_draw_line(acc_price_3m_res, acc_name_3m_res, "Direnc", acc_show_3m_res)
    f_draw_line(acc_price_3m_sup, acc_name_3m_sup, "Destek", acc_show_3m_sup)
    f_draw_line(acc_price_6m_res, acc_name_6m_res, "Direnc", acc_show_6m_res)
    f_draw_line(acc_price_6m_sup, acc_name_6m_sup, "Destek", acc_show_6m_sup)

    f_draw_box(acc_box_top_1, acc_box_bot_1, acc_box_name_1, "Direnc", acc_box_show_1)
    f_draw_box(acc_box_top_2, acc_box_bot_2, acc_box_name_2, "Destek", acc_box_show_2)

    f_draw_line(extra_price_1, extra_name_1, extra_type_1, extra_show_1)
    f_draw_line(extra_price_2, extra_name_2, extra_type_2, extra_show_2)
    f_draw_line(extra_price_3, extra_name_3, extra_type_3, extra_show_3)
    f_draw_line(extra_price_4, extra_name_4, extra_type_4, extra_show_4)

    f_draw_box(box_top_1, box_bot_1, box_name_1, box_type_1, box_show_1)
    f_draw_box(box_top_2, box_bot_2, box_name_2, box_type_2, box_show_2)
    f_draw_box(box_top_3, box_bot_3, box_name_3, box_type_3, box_show_3)
    f_draw_box(box_top_4, box_bot_4, box_name_4, box_type_4, box_show_4)

// =====================================================
// 13) HYBLOCK TARZI HAFTA / AY MARKERLARI
// =====================================================
plot(week_open_plot, title="Onceki Hafta Acilis", color=renk_hafta_open, linewidth=3, style=plot.style_circles)
plot(week_high_plot, title="Onceki Hafta Yuksek", color=renk_hafta_high, linewidth=3, style=plot.style_circles)
plot(week_low_plot, title="Onceki Hafta Dusuk", color=renk_hafta_low, linewidth=3, style=plot.style_circles)
plot(week_eq_plot, title="Onceki Hafta EQ", color=renk_eq, linewidth=3, style=plot.style_circles)

plot(month_open_plot, title="Onceki Ay Acilis", color=renk_ay_open, linewidth=3, style=plot.style_cross)
plot(month_high_plot, title="Onceki Ay Yuksek", color=renk_ay_high, linewidth=3, style=plot.style_cross)
plot(month_low_plot, title="Onceki Ay Dusuk", color=renk_ay_low, linewidth=3, style=plot.style_cross)
plot(month_eq_plot, title="Onceki Ay EQ", color=renk_eq, linewidth=3, style=plot.style_cross)
````
