# iFCPO Holiday Skip

- url: https://www.tradingview.com/script/EsiGC4sw-iFCPO-Holiday-Skip/
- type: indicator
- pine_id: PUB;abc8efbb712a4134a7db3b792489263c
- version: 3.0

## Description

iFCPO Holiday Skip — Bursa Malaysia public-holiday calendar overlay for FCPO traders.

Grey-washes holiday bars + prints holiday name label. Covers all Bursa public holidays for 2024-2026: New Year, Thaipusam, CNY, Hari Raya Aidilfitri/Haji, Wesak, Labour Day, Agong Birthday, Awal Muharram, National Day, Malaysia Day, Maulidur Rasul, Deepavali, Christmas + Federal Territory Day.

Outputs in_Holiday boolean (chainable from other indicators).

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Holiday Skip — Bursa Malaysia public-holiday calendar overlay
// Tier: FREE | Category: Sessions / Utility | Free-Tier GATE layer
// Source: Bursa Malaysia Trading Holidays 2024–2026 (47 hardcoded dates)
// Output: in_holiday boolean (chainable), grey wash overlay, holiday name + countdown to next
// Pair with: session-law-enforcer (window), regime-meter (gate), wick-hunter-lite (entry)
indicator("iFCPO Holiday Skip", "iFCPO Hldy", overlay = true, max_labels_count = 250)

// ── Inputs ──
show_overlay = input.bool(true,  "Grey-wash holiday bars",   group = "Display")
show_label   = input.bool(true,  "Print holiday name on day", group = "Display")
show_table   = input.bool(true,  "Show next-holiday status table", group = "Display")
show_pre_warn = input.bool(true, "Warn 1 day before (gap-down risk)", group = "Display")
overlay_col  = input.color(color.new(color.gray, 80), "Holiday overlay", group = "Colors")
table_pos    = input.string("top_right", "Table position", options = ["top_right","top_left","bottom_right","bottom_left"], group = "Display")

// ── Helper ──
TZ = "Asia/Kuala_Lumpur"
is_date(_yr, _mo, _dy) =>
    year(time, TZ) == _yr and month(time, TZ) == _mo and dayofmonth(time, TZ) == _dy

// ── Bursa Malaysia public holidays 2024–2026 ──
h1  = is_date(2024, 1, 1)
h2  = is_date(2024, 1, 25)
h3  = is_date(2024, 2, 1)
h4  = is_date(2024, 2, 12)
h5  = is_date(2024, 2, 13)
h6  = is_date(2024, 3, 28)
h7  = is_date(2024, 4, 10)
h8  = is_date(2024, 4, 11)
h9  = is_date(2024, 5, 1)
h10 = is_date(2024, 5, 22)
h11 = is_date(2024, 6, 3)
h12 = is_date(2024, 6, 17)
h13 = is_date(2024, 7, 8)
h14 = is_date(2024, 9, 2)
h15 = is_date(2024, 9, 16)
h16 = is_date(2024, 9, 17)
h17 = is_date(2024, 10, 31)
h18 = is_date(2024, 12, 25)
h19 = is_date(2025, 1, 1)
h20 = is_date(2025, 1, 29)
h21 = is_date(2025, 1, 30)
h22 = is_date(2025, 2, 11)
h23 = is_date(2025, 3, 18)
h24 = is_date(2025, 3, 31)
h25 = is_date(2025, 4, 1)
h26 = is_date(2025, 5, 1)
h27 = is_date(2025, 5, 12)
h28 = is_date(2025, 6, 2)
h29 = is_date(2025, 6, 7)
h30 = is_date(2025, 6, 27)
h31 = is_date(2025, 9, 1)
h32 = is_date(2025, 9, 5)
h33 = is_date(2025, 9, 16)
h34 = is_date(2025, 10, 20)
h35 = is_date(2025, 12, 25)
h36 = is_date(2026, 1, 1)
h37 = is_date(2026, 2, 2)
h38 = is_date(2026, 2, 17)
h39 = is_date(2026, 2, 18)
h40 = is_date(2026, 3, 21)
h41 = is_date(2026, 3, 22)
h42 = is_date(2026, 5, 1)
h43 = is_date(2026, 6, 1)
h44 = is_date(2026, 8, 31)
h45 = is_date(2026, 9, 16)
h46 = is_date(2026, 11, 8)
h47 = is_date(2026, 12, 25)

// ── Composite holiday flag ──
in_holiday = h1  or h2  or h3  or h4  or h5  or h6  or h7  or h8  or h9  or h10 or h11 or h12 or h13 or h14 or h15 or h16 or h17 or h18 or h19 or h20 or h21 or h22 or h23 or h24 or h25 or h26 or h27 or h28 or h29 or h30 or h31 or h32 or h33 or h34 or h35 or h36 or h37 or h38 or h39 or h40 or h41 or h42 or h43 or h44 or h45 or h46 or h47

// ── Holiday name lookup ──
holiday_name() =>
    h1 ? "New Year" : h2 ? "Thaipusam" : h3 ? "Federal Territory Day" : h4 ? "Chinese New Year" : h5 ? "CNY Day 2" : h6 ? "Nuzul Al-Quran" : h7 ? "Hari Raya Aidilfitri" : h8 ? "Aidilfitri Day 2" : h9 ? "Labour Day" : h10 ? "Wesak Day" : h11 ? "Agong Birthday" : h12 ? "Hari Raya Haji" : h13 ? "Awal Muharram" : h14 ? "National Day" : h15 ? "Malaysia Day" : h16 ? "Maulidur Rasul" : h17 ? "Deepavali" : h18 ? "Christmas" : h19 ? "New Year" : h20 ? "Chinese New Year" : h21 ? "CNY Day 2" : h22 ? "Thaipusam" : h23 ? "Nuzul Al-Quran" : h24 ? "Hari Raya Aidilfitri" : h25 ? "Aidilfitri Day 2" : h26 ? "Labour Day" : h27 ? "Wesak Day" : h28 ? "Agong Birthday" : h29 ? "Hari Raya Haji" : h30 ? "Awal Muharram" : h31 ? "National Day" : h32 ? "Maulidur Rasul" : h33 ? "Malaysia Day" : h34 ? "Deepavali" : h35 ? "Christmas" : h36 ? "New Year" : h37 ? "Federal Territory Day" : h38 ? "Chinese New Year" : h39 ? "CNY Day 2" : h40 ? "Hari Raya Aidilfitri" : h41 ? "Aidilfitri Day 2" : h42 ? "Labour Day" : h43 ? "Wesak Day" : h44 ? "National Day" : h45 ? "Malaysia Day" : h46 ? "Deepavali" : h47 ? "Christmas" : ""

// ── Next-holiday lookup (computed every bar; persistent until passed) ──
// Encode each holiday as a serial date number (yr*10000 + mo*100 + dy) for ordering
serial_now = year(time, TZ) * 10000 + month(time, TZ) * 100 + dayofmonth(time, TZ)
next_serial = 99999999
next_name = ""

// We can't iterate over arrays of dates for "next holiday" cleanly in Pine without arrays, so build a chain
check(_y, _m, _d, _name) =>
    s = _y * 10000 + _m * 100 + _d
    [s, _name]
[s_h1, n_h1]   = check(2024, 1, 1,   "New Year")
[s_h2, n_h2]   = check(2024, 1, 25,  "Thaipusam")
[s_h3, n_h3]   = check(2024, 2, 1,   "Federal Territory Day")
[s_h4, n_h4]   = check(2024, 2, 12,  "Chinese New Year")
[s_h5, n_h5]   = check(2024, 2, 13,  "CNY Day 2")
[s_h6, n_h6]   = check(2024, 3, 28,  "Nuzul Al-Quran")
[s_h7, n_h7]   = check(2024, 4, 10,  "Hari Raya Aidilfitri")
[s_h8, n_h8]   = check(2024, 4, 11,  "Aidilfitri Day 2")
[s_h9, n_h9]   = check(2024, 5, 1,   "Labour Day")
[s_h10, n_h10] = check(2024, 5, 22,  "Wesak Day")
[s_h11, n_h11] = check(2024, 6, 3,   "Agong Birthday")
[s_h12, n_h12] = check(2024, 6, 17,  "Hari Raya Haji")
[s_h13, n_h13] = check(2024, 7, 8,   "Awal Muharram")
[s_h14, n_h14] = check(2024, 9, 2,   "National Day")
[s_h15, n_h15] = check(2024, 9, 16,  "Malaysia Day")
[s_h16, n_h16] = check(2024, 9, 17,  "Maulidur Rasul")
[s_h17, n_h17] = check(2024, 10, 31, "Deepavali")
[s_h18, n_h18] = check(2024, 12, 25, "Christmas")
[s_h19, n_h19] = check(2025, 1, 1,   "New Year")
[s_h20, n_h20] = check(2025, 1, 29,  "Chinese New Year")
[s_h21, n_h21] = check(2025, 1, 30,  "CNY Day 2")
[s_h22, n_h22] = check(2025, 2, 11,  "Thaipusam")
[s_h23, n_h23] = check(2025, 3, 18,  "Nuzul Al-Quran")
[s_h24, n_h24] = check(2025, 3, 31,  "Hari Raya Aidilfitri")
[s_h25, n_h25] = check(2025, 4, 1,   "Aidilfitri Day 2")
[s_h26, n_h26] = check(2025, 5, 1,   "Labour Day")
[s_h27, n_h27] = check(2025, 5, 12,  "Wesak Day")
[s_h28, n_h28] = check(2025, 6, 2,   "Agong Birthday")
[s_h29, n_h29] = check(2025, 6, 7,   "Hari Raya Haji")
[s_h30, n_h30] = check(2025, 6, 27,  "Awal Muharram")
[s_h31, n_h31] = check(2025, 9, 1,   "National Day")
[s_h32, n_h32] = check(2025, 9, 5,   "Maulidur Rasul")
[s_h33, n_h33] = check(2025, 9, 16,  "Malaysia Day")
[s_h34, n_h34] = check(2025, 10, 20, "Deepavali")
[s_h35, n_h35] = check(2025, 12, 25, "Christmas")
[s_h36, n_h36] = check(2026, 1, 1,   "New Year")
[s_h37, n_h37] = check(2026, 2, 2,   "Federal Territory Day")
[s_h38, n_h38] = check(2026, 2, 17,  "Chinese New Year")
[s_h39, n_h39] = check(2026, 2, 18,  "CNY Day 2")
[s_h40, n_h40] = check(2026, 3, 21,  "Hari Raya Aidilfitri")
[s_h41, n_h41] = check(2026, 3, 22,  "Aidilfitri Day 2")
[s_h42, n_h42] = check(2026, 5, 1,   "Labour Day")
[s_h43, n_h43] = check(2026, 6, 1,   "Wesak Day")
[s_h44, n_h44] = check(2026, 8, 31,  "National Day")
[s_h45, n_h45] = check(2026, 9, 16,  "Malaysia Day")
[s_h46, n_h46] = check(2026, 11, 8,  "Deepavali")
[s_h47, n_h47] = check(2026, 12, 25, "Christmas")

// Find next holiday > today's serial
pick(_curr_min, _curr_name, _s, _name) =>
    use_this = _s > serial_now and _s < _curr_min
    new_min = use_this ? _s : _curr_min
    new_name = use_this ? _name : _curr_name
    [new_min, new_name]

[m1,  nm1]  = pick(99999999, "",  s_h1,  n_h1)
[m2,  nm2]  = pick(m1,   nm1,  s_h2,  n_h2)
[m3,  nm3]  = pick(m2,   nm2,  s_h3,  n_h3)
[m4,  nm4]  = pick(m3,   nm3,  s_h4,  n_h4)
[m5,  nm5]  = pick(m4,   nm4,  s_h5,  n_h5)
[m6,  nm6]  = pick(m5,   nm5,  s_h6,  n_h6)
[m7,  nm7]  = pick(m6,   nm6,  s_h7,  n_h7)
[m8,  nm8]  = pick(m7,   nm7,  s_h8,  n_h8)
[m9,  nm9]  = pick(m8,   nm8,  s_h9,  n_h9)
[m10, nm10] = pick(m9,   nm9,  s_h10, n_h10)
[m11, nm11] = pick(m10,  nm10, s_h11, n_h11)
[m12, nm12] = pick(m11,  nm11, s_h12, n_h12)
[m13, nm13] = pick(m12,  nm12, s_h13, n_h13)
[m14, nm14] = pick(m13,  nm13, s_h14, n_h14)
[m15, nm15] = pick(m14,  nm14, s_h15, n_h15)
[m16, nm16] = pick(m15,  nm15, s_h16, n_h16)
[m17, nm17] = pick(m16,  nm16, s_h17, n_h17)
[m18, nm18] = pick(m17,  nm17, s_h18, n_h18)
[m19, nm19] = pick(m18,  nm18, s_h19, n_h19)
[m20, nm20] = pick(m19,  nm19, s_h20, n_h20)
[m21, nm21] = pick(m20,  nm20, s_h21, n_h21)
[m22, nm22] = pick(m21,  nm21, s_h22, n_h22)
[m23, nm23] = pick(m22,  nm22, s_h23, n_h23)
[m24, nm24] = pick(m23,  nm23, s_h24, n_h24)
[m25, nm25] = pick(m24,  nm24, s_h25, n_h25)
[m26, nm26] = pick(m25,  nm25, s_h26, n_h26)
[m27, nm27] = pick(m26,  nm26, s_h27, n_h27)
[m28, nm28] = pick(m27,  nm27, s_h28, n_h28)
[m29, nm29] = pick(m28,  nm28, s_h29, n_h29)
[m30, nm30] = pick(m29,  nm29, s_h30, n_h30)
[m31, nm31] = pick(m30,  nm30, s_h31, n_h31)
[m32, nm32] = pick(m31,  nm31, s_h32, n_h32)
[m33, nm33] = pick(m32,  nm32, s_h33, n_h33)
[m34, nm34] = pick(m33,  nm33, s_h34, n_h34)
[m35, nm35] = pick(m34,  nm34, s_h35, n_h35)
[m36, nm36] = pick(m35,  nm35, s_h36, n_h36)
[m37, nm37] = pick(m36,  nm36, s_h37, n_h37)
[m38, nm38] = pick(m37,  nm37, s_h38, n_h38)
[m39, nm39] = pick(m38,  nm38, s_h39, n_h39)
[m40, nm40] = pick(m39,  nm39, s_h40, n_h40)
[m41, nm41] = pick(m40,  nm40, s_h41, n_h41)
[m42, nm42] = pick(m41,  nm41, s_h42, n_h42)
[m43, nm43] = pick(m42,  nm42, s_h43, n_h43)
[m44, nm44] = pick(m43,  nm43, s_h44, n_h44)
[m45, nm45] = pick(m44,  nm44, s_h45, n_h45)
[m46, nm46] = pick(m45,  nm45, s_h46, n_h46)
[next_serial_v, next_name_v] = pick(m46, nm46, s_h47, n_h47)

// Exact days-to-next via timestamp diff (was 360/30 approximation — would mis-fire across year boundaries)
next_yr = math.floor(next_serial_v / 10000)
next_mo = math.floor((next_serial_v - next_yr * 10000) / 100)
next_dy = next_serial_v - next_yr * 10000 - next_mo * 100
now_ts  = timestamp(TZ, year(time, TZ), month(time, TZ), dayofmonth(time, TZ), 0, 0)
next_ts = timestamp(TZ, next_yr, next_mo, next_dy, 0, 0)
days_to_next = math.round((next_ts - now_ts) / 86400000)

// Adjacent-day warning (next holiday in <= 1 day → today is potential gap-risk Friday)
holiday_imminent = days_to_next <= 1 and days_to_next > 0

// ── Visualization ──
bgcolor(show_overlay and in_holiday ? overlay_col : na, title = "Holiday overlay")
bgcolor(show_pre_warn and holiday_imminent ? color.new(#E0B544, 92) : na, title = "Holiday imminent")

new_holiday = in_holiday and not in_holiday[1]
if show_label and new_holiday
    label.new(bar_index, high, "🚫 " + holiday_name() + " — Bursa CLOSED",
       color = color.new(color.gray, 30), textcolor = color.white,
       style = label.style_label_down, size = size.small)

// ── Status table ──
tbl_pos = table_pos == "top_right" ? position.top_right : table_pos == "top_left" ? position.top_left : table_pos == "bottom_right" ? position.bottom_right : position.bottom_left
var table tbl = table.new(tbl_pos, 2, 6, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.new(color.gray, 60))
if show_table and barstate.islast
    table.cell(tbl, 0, 0, "iFCPO • Holiday Skip", bgcolor = color.new(color.gray, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 1, 0)
    state_lbl = in_holiday ? "🚫 HOLIDAY (Bursa closed)" : holiday_imminent ? "⚠ Tomorrow holiday" : "Trading day"
    state_col = in_holiday ? #FF3B5C : holiday_imminent ? #E0B544 : #1FC77E
    table.cell(tbl, 0, 1, "Today", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 1, state_lbl, text_color = state_col, text_size = size.small)
    table.cell(tbl, 0, 2, "Next holiday", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 2, next_name_v, text_color = color.white, text_size = size.tiny)
    days_col = days_to_next <= 1 ? #E0B544 : days_to_next <= 7 ? color.new(#E0B544, 40) : color.new(color.white, 60)
    table.cell(tbl, 0, 3, "In", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 3, str.tostring(days_to_next) + " days", text_color = days_col, text_size = size.tiny)
    table.cell(tbl, 0, 4, "Calendar", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 4, "47 Bursa dates", text_color = color.new(color.white, 80), text_size = size.tiny)
    table.cell(tbl, 0, 5, "Pair with", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 5, "session-law, regime-meter", text_color = color.new(#3B82F6, 0), text_size = size.tiny)

// ── Alerts ──
alertcondition(holiday_imminent and not holiday_imminent[1], title = "Tomorrow is a Bursa holiday", message = "iFCPO Holiday Skip — tomorrow is a Bursa public holiday. Consider sizing down or closing positions.")
alertcondition(new_holiday, title = "Holiday today", message = "iFCPO Holiday Skip — Bursa is closed today.")

// ── Chainable boolean outputs ──
plot(in_holiday ? 1 : 0,        "in_holiday",        display = display.data_window)
plot(holiday_imminent ? 1 : 0,  "holiday_imminent",  display = display.data_window)
plot(days_to_next,              "days_to_holiday",   display = display.data_window)
````
