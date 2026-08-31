<!-- tradingview-pine-id: PUB;d62a8d88a57a4042884de952290288f0 -->
<!-- tradingviewscripts-format: 1 -->
# 3DLB Engine + ICT Midnight + Screener

Source: https://www.tradingview.com/script/r914lFH4/

## Description

asdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasd

---

## Source Code

````pine
//@version=6
indicator("3DLB Engine + ICT Midnight + Screener", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string TZ = "America/New_York"
groupLogic = "Logic"
fibThreshold = input.float(0.382, "Fib threshold", minval=0.0, maxval=1.0, step=0.001, group=groupLogic)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Screener - Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupScreener = "Multi-Pair Screener"
showScreener = input.bool(true, "Show 21-Pair Screener Table", group=groupScreener)
screenerPosStr = input.string("Top Right", "Screener Position", options=["Top Left", "Middle Left", "Bottom Left", "Top Right", "Middle Right", "Bottom Right"], group=groupScreener)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ICT Midnight Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TZI = input.string(defval="UTC -5", title="Timezone Selection", options=["UTC -10", "UTC -7", "UTC -6", "UTC -5", "UTC -4", "UTC -3", "UTC +0", "UTC +1", "UTC +2", "UTC +3", "UTC +3:30", "UTC +4", "UTC +5", "UTC +5:30", "UTC +6", "UTC +7", "UTC +8", "UTC +9", "UTC +9:30", "UTC +10", "UTC +10:30", "UTC +11", "UTC +13", "UTC +13:45"], tooltip="Select the Timezone for Midnight Lines", group="Global Settings (ICT)")
Timezone = TZI == "UTC -10" ? "GMT-10:00" : TZI == "UTC -7" ? "GMT-07:00" : TZI == "UTC -6" ? "GMT-06:00" : TZI == "UTC -5" ? "GMT-05:00" : TZI == "UTC -4" ? "GMT-04:00" : TZI == "UTC -3" ? "GMT-03:00" : TZI == "UTC +0" ? "GMT+00:00" : TZI == "UTC +1" ? "GMT+01:00" : TZI == "UTC +2" ? "GMT+02:00" : TZI == "UTC +3" ? "GMT+03:00" : TZI == "UTC +3:30" ? "GMT+03:30" : TZI == "UTC +4" ? "GMT+04:00" : TZI == "UTC +5" ? "GMT+05:00" : TZI == "UTC +5:30" ? "GMT+05:30" : TZI == "UTC +6" ? "GMT+06:00" : TZI == "UTC +7" ? "GMT+07:00" : TZI == "UTC +8" ? "GMT+08:00" : TZI == "UTC +9" ? "GMT+09:00" : TZI == "UTC +9:30" ? "GMT+09:30" : TZI == "UTC +10" ? "GMT+10:00" : TZI == "UTC +10:30" ? "GMT+10:30" : TZI == "UTC +11" ? "GMT+11:00" : TZI == "UTC +13" ? "GMT+13:00" : "GMT+13:45"
inputMaxInterval = input.int(240, title="Hide Lines Above Specified Minutes", group="Global Settings (ICT)")

group_ict_v = "VERTICAL LİNES"
ShowMOP = input.bool(title="", defval=true, inline="MOP", group=group_ict_v)
MOPColor = input.color(color.new(#000000, 0), "", inline="MOP", group=group_ict_v)
Midnight_Open_LS = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], inline="MOP", group=group_ict_v)
Midnight_Open_LW = input.string("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="MOP", group=group_ict_v)

group_ict_p = "OPENİNG PRİCE LİNES"
ShowMOPP = input.bool(title="", defval=true, inline="MOPP", group=group_ict_p)
MOPColP = input.color(color.new(#780000, 0), "", inline="MOPP", group=group_ict_p)
MOPLS = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], inline="MOPP", group=group_ict_p)
i_MOPLW = input.string("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="MOPP", group=group_ict_p)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3DLB Main Math Engine (Backtest Uyumlu Hafıza Sistemi)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_get_data() =>
    // NY gece yarısını tespit et
    bool isMidValid = (dayofweek(time, TZ) >= dayofweek.monday and dayofweek(time, TZ) <= dayofweek.friday)
    bool isMid = hour(time, TZ) == 0 and minute(time, TZ) == 0 and isMidValid

    // Gündelik High/Low Takibi
    float dH = na
    dH := isMid ? high : math.max(high, nz(dH[1], high))
    float dL = na
    dL := isMid ? low : math.min(low, nz(dL[1], low))

    // C1 (Önceki Gün) Verileri
    float c1O = ta.valuewhen(isMid, open, 1)
    float c1C = ta.valuewhen(isMid, close[1], 0)
    float c1H = ta.valuewhen(isMid, dH[1], 0)
    float c1L = ta.valuewhen(isMid, dL[1], 0)

    // C2 (2 Gün Önceki) Verileri
    float c2H = ta.valuewhen(isMid, dH[1], 1)
    float c2L = ta.valuewhen(isMid, dL[1], 1)

    // C3 (3 Gün Önceki) Verileri
    float c3H = ta.valuewhen(isMid, dH[1], 2)
    float c3L = ta.valuewhen(isMid, dL[1], 2)

    // YÖN KONTROLÜ (C3 ve C2 açıkları)
    bool highsOpen = c3H > c2H
    bool lowsOpen = c3L < c2L

    bool isC1Upclose = c1C > c1O
    bool isC1Downclose = c1C < c1O

    bool isBearBias = false
    bool isBullBias = false

    if highsOpen and lowsOpen
        if isC1Downclose
            isBearBias := true
        else
            isBullBias := true
    else if lowsOpen
        isBearBias := true
    else if highsOpen
        isBullBias := true

    // FİBONACCİ KONTROLÜ (C3 ve C1 arası çekilir)
    float bullFibVal = c1L + (c3H - c1L) * fibThreshold
    bool bullFibOk = c1C > bullFibVal and (c3H - c1L) > syminfo.mintick

    float bearFibVal = c1H - (c1H - c3L) * fibThreshold
    bool bearFibOk = c1C < bearFibVal and (c1H - c3L) > syminfo.mintick

    // TABLO DEĞERLERİ KODLAMASI
    int eDir = 0
    int eFib = 0
    int eNymo = 0
    int eDaily = 0
    int eStat = 0

    if isBearBias
        eDir := 2
        eFib := bearFibOk ? 1 : 2
        eNymo := isC1Downclose ? 1 : 2
        eDaily := isC1Downclose ? 1 : 2
    else if isBullBias
        eDir := 1
        eFib := bullFibOk ? 1 : 2
        eNymo := isC1Upclose ? 1 : 2
        eDaily := isC1Upclose ? 1 : 2

    // AKTİVASYON (C1 sadece C2'nin likiditesini temizlemek ZORUNDADIR - C3 şartı kaldırıldı)
    bool isBullishActive = isBullBias and bullFibOk and isC1Upclose and (c1L < c2L)
    bool isBearishActive = isBearBias and bearFibOk and isC1Downclose and (c1H > c2H)

    // Setup Çalışırken İptal Seviyesi Patladı mı? (C1L / C1H / T2)
    bool isTerminalHit = false
    if isBullishActive
        if dL <= c1L or dH >= c3H
            isTerminalHit := true
    if isBearishActive
        if dH >= c1H or dL <= c3L
            isTerminalHit := true

    if isBullishActive and not isTerminalHit
        eStat := 1
    else if isBearishActive and not isTerminalHit
        eStat := 2

    // Tüm verileri tek bir pakette ana sunucuya yolla
    eStat * 10000 + eDaily * 1000 + eNymo * 100 + eFib * 10 + eDir


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LEFT PANEL - 21 Pair Screener Logic 
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pos_map(s) =>
    s == "Top Left" ? position.top_left : s == "Middle Left" ? position.middle_left : s == "Bottom Left" ? position.bottom_left : s == "Top Right" ? position.top_right : s == "Middle Right" ? position.middle_right : position.bottom_right

v01 = request.security("EURNZD", timeframe.period, f_get_data())
v02 = request.security("EURAUD", timeframe.period, f_get_data())
v03 = request.security("EURCAD", timeframe.period, f_get_data())
v04 = request.security("EURCHF", timeframe.period, f_get_data())
v05 = request.security("EURJPY", timeframe.period, f_get_data())
v06 = request.security("EURGBP", timeframe.period, f_get_data())
v07 = request.security("GBPCAD", timeframe.period, f_get_data())
v08 = request.security("GBPNZD", timeframe.period, f_get_data())
v09 = request.security("GBPAUD", timeframe.period, f_get_data())
v10 = request.security("GBPCHF", timeframe.period, f_get_data())
v11 = request.security("GBPJPY", timeframe.period, f_get_data())
v12 = request.security("AUDCHF", timeframe.period, f_get_data())
v13 = request.security("AUDCAD", timeframe.period, f_get_data())
v14 = request.security("AUDJPY", timeframe.period, f_get_data())
v15 = request.security("AUDNZD", timeframe.period, f_get_data())
v16 = request.security("NZDCAD", timeframe.period, f_get_data())
v17 = request.security("NZDCHF", timeframe.period, f_get_data())
v18 = request.security("NZDJPY", timeframe.period, f_get_data())
v19 = request.security("CADCHF", timeframe.period, f_get_data())
v20 = request.security("CADJPY", timeframe.period, f_get_data())
v21 = request.security("CHFJPY", timeframe.period, f_get_data())

var table scTable = table.new(pos_map(screenerPosStr), 6, 22, border_width=1, border_color=color.gray)

f_fill_row(tbl, row, sym, packed_val) =>
    int stat_code = int(math.floor(packed_val / 10000))
    int rem1 = packed_val % 10000
    int daily_code = int(math.floor(rem1 / 1000))
    int rem2 = rem1 % 1000
    int nymo_code = int(math.floor(rem2 / 100))
    int rem3 = rem2 % 100
    int fib_code = int(math.floor(rem3 / 10))
    int dir_code = rem3 % 10

    string stat = stat_code == 1 ? "ACTIVE (BULL)" : stat_code == 2 ? "ACTIVE (BEAR)" : "INACTIVE"
    string dir = dir_code == 1 ? "Bullish" : dir_code == 2 ? "Bearish" : "-"
    string fib = fib_code == 1 ? "PASS" : fib_code == 2 ? "FAIL" : "Waiting"
    string nymo = nymo_code == 1 ? "PASS" : nymo_code == 2 ? "FAIL" : "Waiting"
    string daily = daily_code == 1 ? "PASS" : daily_code == 2 ? "FAIL" : "Waiting"

    color bgDir = dir == "Bullish" ? color.new(color.green, 85) : dir == "Bearish" ? color.new(color.red, 85) : color.white
    color bgFib = fib == "PASS" ? color.new(color.green, 85) : fib == "FAIL" ? color.new(color.red, 85) : color.white
    color bgNymo = nymo == "PASS" ? color.new(color.green, 85) : nymo == "FAIL" ? color.new(color.red, 85) : color.white
    color bgDaily = daily == "PASS" ? color.new(color.green, 85) : daily == "FAIL" ? color.new(color.red, 85) : color.white
    color bgStat = stat == "ACTIVE (BULL)" ? color.new(color.green, 60) : stat == "ACTIVE (BEAR)" ? color.new(color.red, 60) : color.new(color.gray, 85)
    
    table.cell(tbl, 0, row, sym, text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=size.small)
    table.cell(tbl, 1, row, dir, text_color=color.black, bgcolor=bgDir, text_size=size.small)
    table.cell(tbl, 2, row, fib, text_color=color.black, bgcolor=bgFib, text_size=size.small)
    table.cell(tbl, 3, row, nymo, text_color=color.black, bgcolor=bgNymo, text_size=size.small)
    table.cell(tbl, 4, row, daily, text_color=color.black, bgcolor=bgDaily, text_size=size.small)
    table.cell(tbl, 5, row, stat, text_color=color.black, bgcolor=bgStat, text_size=size.small)

if barstate.islast and showScreener
    table.cell(scTable, 0, 0, "Pair", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(scTable, 1, 0, "Bias", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(scTable, 2, 0, "Fib", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(scTable, 3, 0, "NYMO", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(scTable, 4, 0, "Daily", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(scTable, 5, 0, "Status", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)

    f_fill_row(scTable, 1, "EURNZD", v01)
    f_fill_row(scTable, 2, "EURAUD", v02)
    f_fill_row(scTable, 3, "EURCAD", v03)
    f_fill_row(scTable, 4, "EURCHF", v04)
    f_fill_row(scTable, 5, "EURJPY", v05)
    f_fill_row(scTable, 6, "EURGBP", v06)
    f_fill_row(scTable, 7, "GBPCAD", v07)
    f_fill_row(scTable, 8, "GBPNZD", v08)
    f_fill_row(scTable, 9, "GBPAUD", v09)
    f_fill_row(scTable, 10, "GBPCHF", v10)
    f_fill_row(scTable, 11, "GBPJPY", v11)
    f_fill_row(scTable, 12, "AUDCHF", v12)
    f_fill_row(scTable, 13, "AUDCAD", v13)
    f_fill_row(scTable, 14, "AUDJPY", v14)
    f_fill_row(scTable, 15, "AUDNZD", v15)
    f_fill_row(scTable, 16, "NZDCAD", v16)
    f_fill_row(scTable, 17, "NZDCHF", v17)
    f_fill_row(scTable, 18, "NZDJPY", v18)
    f_fill_row(scTable, 19, "CADCHF", v19)
    f_fill_row(scTable, 20, "CADJPY", v20)
    f_fill_row(scTable, 21, "CHFJPY", v21)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ICT Midnight Functions & Variables
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DOM = (timeframe.multiplier <= inputMaxInterval) and timeframe.isintraday

MNOPLS = Midnight_Open_LS=="Solid" ? line.style_solid : Midnight_Open_LS == "Dotted" ? line.style_dotted : line.style_dashed
MOPLSS = MOPLS=="Solid" ? line.style_solid : MOPLS == "Dotted" ? line.style_dotted : line.style_dashed
MOPLW = Midnight_Open_LW=="1px" ? 1 : Midnight_Open_LW == "2px" ? 2 : Midnight_Open_LW == "3px" ? 3 : Midnight_Open_LW == "4px" ? 4 : 5
MOPPLW = i_MOPLW=="1px" ? 1 : i_MOPLW == "2px" ? 2 : i_MOPLW == "3px" ? 3 : i_MOPLW == "4px" ? 4 : 5

bool isIctMidnight = hour(time, Timezone) == 0 and minute(time, Timezone) == 0

if isIctMidnight
    if (ShowMOP and DOM)
        line.new(x1=bar_index, y1=low, x2=bar_index, y2=high, xloc=xloc.bar_index, extend=extend.both, color=MOPColor, style=MNOPLS, width=MOPLW)
    
    if (ShowMOPP and DOM)
        int endTime = time + 86400000 
        if dayofweek(time, Timezone) == dayofweek.friday and syminfo.type != "crypto"
            endTime := time + 259200000 
        line.new(x1=time, y1=open, x2=endTime, y2=open, xloc=xloc.bar_time, extend=extend.none, color=MOPColP, style=MOPLSS, width=MOPPLW)
````
