# EMA1 + KR + EMA4 + VWAP + S&D + S/R

- url: https://www.tradingview.com/script/roJhyoZQ-EMA1-KR-EMA4-VWAP-S-D-S-R/
- type: indicator
- pine_id: PUB;14bf72f678a44d2f8817a81130957773
- version: 5.0

## Description

nsensus with structural price action, this indicatchart clutter  full situational awareness of mrsal zones, and breakdown/breakout confirmations.

## Source Code

````pine
//@version=6
indicator(title = "EMA + KR + VWAP + S&D + S/R", shorttitle = "EMA_KR + VWAP + SD + SR", overlay = true, max_boxes_count = 500, max_bars_back = 2000)

// ==========================================
// --- 1. Trend Lines (EMA + KR + VWAP) ---
// ==========================================
t_grp = "Trend: EMA & Kernel Regression & VWAP"
ema1_len  = input.int(9,     "EMA 1 (快線)", minval=1, group=t_grp)
ema1_col  = input.color(color.blue,    "EMA 1 顏色", group=t_grp)
show_ema1 = input.bool(true, "顯示 EMA 1", group=t_grp)

// Kernel Regression replacing SMA 1
kr_len    = input.int(25,    "Kernel Regression 頻寬 (Lookback)", minval=1, maxval=100, group=t_grp)
kr_col    = input.color(color.yellow, "Kernel Regression 顏色", group=t_grp)
show_kr   = input.bool(true, "顯示 Kernel Regression", group=t_grp)

ema4_len  = input.int(200,   "EMA 4 (長線)", minval=1, group=t_grp)
ema4_col  = input.color(color.white,   "EMA 4 顏色", group=t_grp)
show_ema4 = input.bool(true, "顯示 EMA 4", group=t_grp)

show_vwap = input.bool(true, "顯示 VWAP", group=t_grp)
vwap_col  = input.color(color.purple, "VWAP 顏色", group=t_grp)

// Background Fill
fill_transp = input.int(63, "EMA1-KR 背景透明度", minval=0, maxval=100, group="Background Fill")

ema1 = ta.ema(close, ema1_len)
ema4 = ta.ema(close, ema4_len)
vwap_val = ta.vwap(hlc3)

// Kernel Regression Calculation Logic
var float two_bandwidth_sq = 2 * math.pow(kr_len / 2, 2)

compute_kernel_regression(int lookup_len, float divisor) =>
    float sumWeights = 0.0
    float sumWeightedPrices = 0.0
    if bar_index >= lookup_len
        for i = 0 to lookup_len
            float weight = math.exp(-(i * i) / divisor)
            float val = close[i]
            sumWeights += weight
            sumWeightedPrices += val * weight
    sumWeights > 0 ? sumWeightedPrices / sumWeights : close

kr_val = compute_kernel_regression(kr_len, two_bandwidth_sq)

// Volume Confirmation for Breakouts
shortEMA = ta.ema(volume, 5)
longEMA = ta.ema(volume, 10)
osc = 100 * (shortEMA - longEMA) / longEMA
sr_grp = "LuxAlgo S/R Levels"
volumeThresh = input.int(9, "成交量閾值 (%)", group=sr_grp)
volConfirmed = osc > volumeThresh

// ==========================================
// --- Plotting Trend Lines ---
// ==========================================
p_ema1 = plot(show_ema1 ? ema1 : na, "EMA 1", color=ema1_col, linewidth=2)
p_kr   = plot(show_kr ? kr_val : na, "Kernel Regression", color=kr_col, linewidth=2)
p_ema4 = plot(show_ema4 ? ema4 : na, "EMA 4", color=ema4_col, linewidth=2)
p_vwap = plot(show_vwap ? vwap_val : na, "VWAP", color=vwap_col, linewidth=2)

// ==========================================
// --- Background Fill EMA1 & KR ---
// ==========================================
bull_fill = color.new(color.green, fill_transp)
bear_fill = color.new(color.red,   fill_transp)
fill(p_ema1, p_kr, color = ema1 > kr_val ? bull_fill : bear_fill, title="EMA1 - KR Fill")

// ==========================================
// --- Crossover Icons ---
// ==========================================
plotshape(ta.crossover(ema1, kr_val),  title="EMA1 Cross Above KR", location=location.belowbar, color=color.new(color.green, 30), style=shape.circle, size=size.small)
plotshape(ta.crossunder(ema1, kr_val), title="EMA1 Cross Below KR", location=location.abovebar, color=color.new(color.red, 30),   style=shape.circle, size=size.small)


//###############################################
// 【提前宣告修正】先將 TD 9 计数邏輯搬到呢度，等後面嘅 S&D 迴圈可以正常讀取
//###############################################
var int buy_setup_count  = 0
var int sell_setup_count = 0

buy_setup_count  := (close < close[4]) ? buy_setup_count + 1 : 0
sell_setup_count := (close > close[4]) ? sell_setup_count + 1 : 0

is_buy_9  = (buy_setup_count == 9)
is_sell_9 = (sell_setup_count == 9)


// ==========================================
// --- 2. Supply & Demand Zone ---
// ==========================================
sd_grp = 'Supply & Demand'
show_sd = input.bool(true, "顯示 Supply & Demand Zones", group = sd_grp)
maxDistStr = input.string('Normal', 'S&D 計算範圍', options = ['High', 'Normal', 'Low'], group = sd_grp)
momBodyMult = input.float(0.5, '動量實體倍數', step = 0.1, group = sd_grp)
momCount = input.int(4, '動量 K 棒數', group = sd_grp)
momSpan = input.int(4, '動量跨度', group = sd_grp)
bullSDCol = input.color(color.new(#3affde, 80), 'Demand 顏色', group = sd_grp)
bearSDCol = input.color(color.new(#ff3a4a, 80), 'Supply 顏色', group = sd_grp)
sdTextColor = input.color(color.white, '區域文字顏色', group = 'S&D: Style')
tf1E = input.bool(true, '啟用 TF 1', inline = 'tf1', group = sd_grp)
tf1  = input.timeframe('', '', inline = 'tf1', group = sd_grp)
tf2E = input.bool(false, '啟用 TF 2', inline = 'tf2', group = sd_grp)
tf2  = input.timeframe('15', '', inline = 'tf2', group = sd_grp)

const int maxSDZones = 15
const int minDistanceBetweenZones = 5
type sdZoneInfo
    float top
    float bottom
    string sdType
    int startTime
    int breakTime
maxD = maxDistStr == 'Low' ? 150 : maxDistStr == 'Normal' ? 500 : 1250
bool isRel = bar_index > last_bar_index - maxD
avgB = ta.sma(math.abs(close - open), 20)
bSize = math.abs(close - open)
int bullMom = 0
int bearMom = 0
if isRel
    for i = 0 to momSpan - 1
        if bSize[i] >= avgB * momBodyMult
            if close[i] > open[i]
                bullMom += 1
            else
                bearMom += 1
var dZones = array.new<sdZoneInfo>(0)
var sZones = array.new<sdZoneInfo>(0)
var int lastD = 0
var int lastS = 0
if isRel
    if bullMom >= momCount and bar_index - lastD > minDistanceBetweenZones
        lastD := bar_index
        // 以爆發前夕 (momSpan) 作為起點向左搜尋最後一支陰線
        int base_offset = momSpan
        for j = momSpan to momSpan + 10
            if close[j] < open[j]
                base_offset := j
                break
        dZones.unshift(sdZoneInfo.new(high[base_offset], low[base_offset], 'Demand', time[base_offset], na))
        if dZones.size() > maxSDZones
            dZones.pop()
            
    if bearMom >= momCount and bar_index - lastS > minDistanceBetweenZones
        lastS := bar_index
        // 以爆發前夕 (momSpan) 作為起點向左搜尋最後一支陽線
        int base_offset = momSpan
        for j = momSpan to momSpan + 10
            if close[j] > open[j] or (buy_setup_count[j] == 9)
                base_offset := j
                break
        sZones.unshift(sdZoneInfo.new(high[base_offset], low[base_offset], 'Supply', time[base_offset], na))
        if sZones.size() > maxSDZones
            sZones.pop()

    // Update break time
    if dZones.size() > 0
        for i = 0 to dZones.size() - 1
            z = dZones.get(i)
            if na(z.breakTime) and close < z.bottom
                z.breakTime := time
    if sZones.size() > 0
        for i = 0 to sZones.size() - 1
            z = sZones.get(i)
            if na(z.breakTime) and close > z.top
                z.breakTime := time

d1_mtf = tf1E ? request.security(syminfo.tickerid, tf1, dZones) : na
s1_mtf = tf1E ? request.security(syminfo.tickerid, tf1, sZones) : na
d2_mtf = tf2E ? request.security(syminfo.tickerid, tf2, dZones) : na
s2_mtf = tf2E ? request.security(syminfo.tickerid, tf2, sZones) : na
var allBoxes = array.new<box>(0)

renderZones(array<sdZoneInfo> list, string lbl, color col) =>
    if not na(list) and list.size() > 0
        int dLim = math.min(list.size(), 10)
        for i = 0 to dLim - 1
            zi = list.get(i)
            if na(zi.breakTime)
                allBoxes.push(box.new(left=zi.startTime, top=zi.top, right=time, bottom=zi.bottom,
                                    xloc=xloc.bar_time, bgcolor=col, border_color=col,
                                    text=lbl, text_size=size.tiny, text_color=sdTextColor,
                                    text_halign=text.align_right, text_valign=text.align_bottom))
if barstate.isconfirmed
    if allBoxes.size() > 0
        for bx in allBoxes
            box.delete(bx)
        allBoxes.clear()
    if show_sd
        if tf1E
            renderZones(d1_mtf, tf1 == '' ? timeframe.period : tf1, bullSDCol)
            renderZones(s1_mtf, tf1 == '' ? timeframe.period : tf1, bearSDCol)
        if tf2E
            renderZones(d2_mtf, tf2, bullSDCol)
            renderZones(s2_mtf, tf2, bearSDCol)
            
            
//###############################################


// ==========================================
// --- 3. LuxAlgo S/R  ---
// ==========================================
toggleBreaks = input.bool(true, "顯示 S/R 突破 (B)", group=sr_grp)
leftBars     = input.int(8, "Pivot 左側 Bars", minval=1, group=sr_grp)
rightBars    = input.int(8, "Pivot 右側 Bars", minval=1, group=sr_grp)
lineLength   = input.int(8, "S/R 線條長度", minval=1, group=sr_grp)

// ==========================================
// --- 數字格式化函數 ---
// ==========================================
format_vol(vol) =>
    if vol >= 1000000
        str.tostring(vol / 1000000, "#.#") + "M"
    else if vol >= 1000
        str.tostring(vol / 1000, "#.#") + "K"
    else
        str.tostring(vol, "#")

highPivot = ta.pivothigh(leftBars, rightBars)
lowPivot  = ta.pivotlow(leftBars, rightBars)

// ==========================================
// --- 計算一個動態的微調間距 (Offset) ---
// ==========================================
// 使用 14 週期 ATR 的 15% 作為上下浮動的間距，確保字體不黏線
sr_offset = ta.atr(14) * 0.06

// 處理 Pivot High (阻力位)
if not na(highPivot)
    int pivot_bar = bar_index - rightBars
    int end_bar = pivot_bar + lineLength  // 定義線條結束的 X 坐標
    
    // 畫阻力紅線
    line.new(x1=pivot_bar, y1=highPivot, x2=end_bar, y2=highPivot, color=color.red, width=2)
    
    // 【已修正】將 y 坐標加上 sr_offset，讓文字精準浮在紅線上方
    label.new(x=end_bar, y=highPivot + sr_offset, 
              text=format_vol(volume[rightBars]), 
              color=color.new(color.white, 100), 
              textcolor=color.rgb(255, 255, 255), 
              style=label.style_none, 
              size=size.small)

// 處理 Pivot Low (支撐位)
if not na(lowPivot)
    int pivot_bar = bar_index - rightBars
    int end_bar = pivot_bar + lineLength  // 定義線條結束的 X 坐標
    
    // 畫支撐藍線
    line.new(x1=pivot_bar, y1=lowPivot, x2=end_bar, y2=lowPivot, color=color.blue, width=2)
    
    // 【已修正】將 y 坐標加上 sr_offset，讓文字精準浮在藍線上方
    label.new(x=end_bar, y=lowPivot + sr_offset, 
              text=format_vol(volume[rightBars]), 
              color=color.new(color.white, 100), 
              textcolor=color.rgb(255, 255, 255), 
              style=label.style_none, 
              size=size.small)


//###############################################
// --- 4. Pure TD Sequential 9 ---
//###############################################
c_neon_green = color.rgb(255, 220, 0)
c_neon_red   = color.rgb(255, 220, 0)

// 保持原本的 K 棒變色邏輯
barcolor(is_buy_9 ? c_neon_green : (is_sell_9 ? c_neon_red : na), title="TD 9 Bar Color")

// 【已修改】使用 plotshape 替代 plotchar，加入背景標籤效果
plotshape(is_buy_9,  
     title="TD Buy 9 (帶背景)", 
     text="9", 
     style=shape.labelup, 
     location=location.belowbar, 
     color=color.new(color.green, 20),     // 背景標籤顏色 (帶點透明度比較好睇)
     textcolor=color.white,                // 文字顏色
     size=size.tiny)

plotshape(is_sell_9, 
     title="TD Sell 9 (帶背景)", 
     text="9", 
     style=shape.labeldown, 
     location=location.abovebar, 
     color=color.new(color.red, 20),       // 背景標籤顏色
     textcolor=color.white,                // 文字顏色
     size=size.tiny)


//###############################################


// ==========================================
// --- 5. Cross EMA 9 Label Alert (修正版) ---
// ==========================================

// 獲取 Heikin-Ashi 的 OHLV 數據
[h_o, h_h, h_l, h_c] = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, [open, high, low, close], lookahead=barmerge.lookahead_off)

// 計算 Heikin-Ashi 的 9 EMA
ema9 = ta.ema(h_c, 9)

// 找出 ema1 (快線) 與 kr_val (Kernel Regression) 之間的最高線
float higher_line = math.max(ema1, kr_val)

// 條件 1: Heikin-Ashi 必須是綠色陽線
is_green = h_c > h_o

// 條件 2: 突破條件 —— 收盤價必須突破「ema1 與 kr_val 的最高線」
cross_up_higher = (h_c[1] <= higher_line[1]) and (h_c > higher_line)

// 最終警報觸發點：必須是綠K，且收盤價成功突破最高線
enhanced_early_signal = cross_up_higher and is_green

// 【已修正】這裡改用「=」進行首次宣告，解決 Undeclared identifier 錯誤
alert_trigger = enhanced_early_signal 

// 更新警報通知內容
alertcondition(alert_trigger, title="EMA 9 + KR 複合突破買入訊號", message="Heikin-Ashi 綠K 成功向上突破 EMA1 與 Kernel Regression 的最高線！")


//###############################################


// ==========================================
// --- 6. Higher Low (不畫線/不顯字) ---
// ==========================================
hl_grp = "Higher Low 偵測設定"
hl_leftBars  = input.int(5, "HL Pivot 左側 Bars", minval=1, group=hl_grp)
hl_rightBars = input.int(5, "HL Pivot 右側 Bars", minval=1, group=hl_grp)

// 使用 var 紀錄連續兩次的 Pivot Low 價格
var float last_pivot_low = na
var float prev_pivot_low = na
var bool is_higher_low = false

// 1. 偵測有無新嘅 Pivot Low 形成
current_pl = ta.pivotlow(low, hl_leftBars, hl_rightBars)

// 宣告一個特定的布林值變數，用來觸發特定鬧鐘
var bool trigger_hl_alert = false

if not na(current_pl)
    // 把舊紀錄推前，更新最新紀錄
    prev_pivot_low := last_pivot_low
    last_pivot_low := current_pl
    
    // 【檢查 1】：新底高過舊底
    if not na(prev_pivot_low) and last_pivot_low > prev_pivot_low
        is_higher_low := true
        
        // 【檢查 2】：當前價格高過新底
        if close > last_pivot_low
            trigger_hl_alert := true
        else
            trigger_hl_alert := false
    else
        is_higher_low := false
        trigger_hl_alert := false
else
    // 如果呢一枝 Bar 冇新 Pivot 誕生，就關閉觸發狀態
    trigger_hl_alert := false

// 💡 解決方法：改用 alertcondition()，咁樣選單就會出現獨立選項！
alertcondition(trigger_hl_alert, title="Higher Low 偵測訊號", message="偵測到更高嘅底部 (Higher Low)！")

// 為咗等上面的 {{plot_0}} 可以喺 Message 動態顯示新底價錢，我哋 plot 出來（但設定不顯示喺圖表）
plot(last_pivot_low, title="Hidden Last PL", display=display.none)


//###############################################


// ==========================================
// --- 7. Info Box (修正變量命名衝突版) ---
// ==========================================
// --- 【1. UI 開關設定】 ---
info_pos     = input.string("Top Right", "Info Box Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Info Box")
var string f_size = size.small // 可改為 size.tiny 令字體更細

show_header  = input.bool(true, "顯示 標頭 (Indicator/Status)", group="Info Box 內容顯示開關")
show_ema200  = input.bool(true, "顯示 > 200 EMA", group="Info Box 內容顯示開關")
show_ema9    = input.bool(true, "顯示 > 9 EMA", group="Info Box 內容顯示開關")
show_kernel  = input.bool(true, "顯示 9 EMA > Kernel", group="Info Box 內容顯示開關")
show_hl      = input.bool(true, "顯示 Higher Low", group="Info Box 內容顯示開關")
// 【已修改】改名為 show_box_vwap，避開你原本控制繪圖線條的 show_vwap
show_box_vwap = input.bool(true, "顯示 > VWAP", group="Info Box 內容顯示開關")
show_bs_vol  = input.bool(true, "顯示 買賣成交量 (B/S Vol)", group="Info Box 內容顯示開關")
show_rvol    = input.bool(true, "顯示 相對成交量 (RVol)", group="Info Box 內容顯示開關")


// --- 【2. 數據計算】 ---
rvol_length = input.int(20, "RVol 平均週期", minval=1, group="Relative Volume")
float avg_volume = ta.sma(volume[1], rvol_length)
float rvol = (avg_volume == 0) ? 0.0 : volume / avg_volume

float candle_range = high - low
float buy_pct     = (candle_range == 0) ? 0.5 : (close - low) / candle_range
float sell_pct    = 1.0 - buy_pct
float buyVol  = volume * buy_pct
float sellVol = volume * sell_pct

string b_txt = (buyVol >= 1000000) ? (str.tostring(buyVol / 1000000, "#.#") + "M") : ((buyVol >= 1000) ? (str.tostring(buyVol / 1000, "#.#") + "K") : str.tostring(buyVol, "#"))
string s_txt = (sellVol >= 1000000) ? (str.tostring(sellVol / 1000000, "#.#") + "M") : ((sellVol >= 1000) ? (str.tostring(sellVol / 1000, "#.#") + "K") : str.tostring(sellVol, "#"))

string vol_text_combined = b_txt + " / " + s_txt
color vol_box_color     = (buyVol > sellVol) ? color.new(color.green, 20) : color.new(color.red, 20)

string display_rvol_text = "0x"
color  display_rvol_color = color.new(color.gray, 50)
if rvol > 1.5
    display_rvol_text  := str.tostring(rvol, "#.#") + "x"
    display_rvol_color := (rvol >= 2.0) ? color.new(color.green, 0) : color.new(color.green, 40)


// --- 【3. 動態計算總行數】 ---
int total_rows = 0
if show_header
    total_rows := total_rows + 1
if show_ema200
    total_rows := total_rows + 1
if show_ema9
    total_rows := total_rows + 1
if show_kernel
    total_rows := total_rows + 1
if show_hl
    total_rows := total_rows + 1
if show_box_vwap // 已同步修改
    total_rows := total_rows + 1
if show_bs_vol
    total_rows := total_rows + 1
if show_rvol
    total_rows := total_rows + 1


// --- 【4. 渲染與繪製表格】 ---
table infoBox = table.new(position = info_pos == "Top Right" ? position.top_right : info_pos == "Top Left" ? position.top_left : info_pos == "Bottom Right" ? position.bottom_right : position.bottom_left, columns = 2, rows = total_rows, bgcolor = color.new(color.black, 80), border_width = 1, frame_color = color.gray)

int current_row = 0

if total_rows > 0
    // 【行：標頭】
    if show_header
        table.cell(infoBox, 0, current_row, "Indicator", text_color = color.white, bgcolor = color.new(color.blue, 70), text_size = f_size)
        table.cell(infoBox, 1, current_row, "Status",    text_color = color.white, bgcolor = color.new(color.blue, 70), text_size = f_size)
        current_row := current_row + 1

    // 【行：> 200 EMA】
    if show_ema200
        table.cell(infoBox, 0, current_row, "> 200 EMA", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, close > ema4 ? "YES" : "NO", text_color = color.white, bgcolor = close > ema4 ? color.new(color.green,0) : color.new(color.red,0), text_size = f_size)
        current_row := current_row + 1

    // 【行：> 9 EMA】
    if show_ema9
        table.cell(infoBox, 0, current_row, "> 9 EMA", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, close > ema1 ? "YES" : "NO", text_color = color.white, bgcolor = close > ema1 ? color.new(color.green,0) : color.new(color.red,0), text_size = f_size)
        current_row := current_row + 1

    // 【行：9 EMA > Kernel】
    if show_kernel
        table.cell(infoBox, 0, current_row, "9 EMA > Kr", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, ema1 > kr_val ? "YES" : "NO", text_color = color.white, bgcolor = ema1 > kr_val ? color.new(color.green,0) : color.new(color.red,0), text_size = f_size)
        current_row := current_row + 1

    // 【行：Higher Low】
    if show_hl
        table.cell(infoBox, 0, current_row, "Higher Low", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, na(prev_pivot_low) ? "WAIT" : (is_higher_low ? "YES" : "NO"), text_color = color.white, bgcolor = na(prev_pivot_low) ? color.new(color.orange,0) : is_higher_low ? color.new(color.green,0) : color.new(color.red,0), text_size = f_size)
        current_row := current_row + 1

    // 【行：> VWAP】
    if show_box_vwap // 已同步修改
        table.cell(infoBox, 0, current_row, "> VWAP", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, close > vwap_val ? "YES" : "NO", text_color = color.white, bgcolor = close > vwap_val ? color.new(color.green,0) : color.new(color.red,0), text_size = f_size)
        current_row := current_row + 1

    // 【行：B/S Vol】
    if show_bs_vol
        table.cell(infoBox, 0, current_row, "B/S Vol", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, vol_text_combined, text_color = color.white, bgcolor = vol_box_color, text_size = f_size)
        current_row := current_row + 1

    // 【行：RVol (20)】
    if show_rvol
        table.cell(infoBox, 0, current_row, "RVol (20)", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, display_rvol_text, text_color = color.white, bgcolor = display_rvol_color, text_size = f_size)
        current_row := current_row + 1


//###############################################
````
