# EMA/VWAP/SD/SR

- url: https://www.tradingview.com/script/gcX4yARl-EMA-VWAP-SD-SR/
- type: indicator
- pine_id: PUB;713230456dbe45fd98fda923c72dc7d8
- version: 5.0

## Description

EMA / VWAP / Supply & Demand / LuxAlgo S/R
Multi-timeframe Trend + Institutional Order Block Detector
這是一個功能強大且乾淨的多合一指標，專為波段交易和日內交易而設計。

## Source Code

````pine
//@version=6
indicator(title = "EMA + KR + VWAP + S&D + S/R", shorttitle = "EMA_KR + VWAP + SD + SR", overlay = true, max_boxes_count = 500, max_bars_back = 2000)

// ==========================================
// --- 1. Trend Lines (EMA + KR + VWAP) ---
// ==========================================
t_grp = "Trend: EMA & Kernel & VWAP"

// 使用 inline="ema1" 將長度、顏色、開關排在同一行
ema1_len  = input.int(9,     "EMA 1 (快線)", minval=1, group=t_grp, inline="ema1")
ema1_col  = input.color(color.blue, "", group=t_grp, inline="ema1")
show_ema1 = input.bool(true, "顯示", group=t_grp, inline="ema1")

// 使用 inline="ema2"
ema2_len  = input.int(50,    "EMA 2 (中線)", minval=1, group=t_grp, inline="ema2")
ema2_col  = input.color(color.orange, "", group=t_grp, inline="ema2")
show_ema2 = input.bool(false, "顯示", group=t_grp, inline="ema2")

// 使用 inline="kr"
kr_len    = input.int(25,    "Kernel Regression (Lookback)", minval=1, maxval=100, group=t_grp, inline="kr")
kr_col    = input.color(color.yellow, "", group=t_grp, inline="kr")
show_kr   = input.bool(true, "顯示", group=t_grp, inline="kr")

// 使用 inline="ema4"
ema4_len  = input.int(200,   "EMA 4 (長線)", minval=1, group=t_grp, inline="ema4")
ema4_col  = input.color(color.white,  "", group=t_grp, inline="ema4")
show_ema4 = input.bool(true, "顯示", group=t_grp, inline="ema4")

// 使用 inline="vwap"
show_vwap = input.bool(true, "顯示 VWAP", group=t_grp, inline="vwap")
vwap_col  = input.color(color.purple, "", group=t_grp, inline="vwap")

// Background Fill
fill_transp = input.int(63, "EMA1-KR 背景透明度", minval=0, maxval=100, group="Background Fill")

ema1 = ta.ema(close, ema1_len)
ema2 = ta.ema(close, ema2_len) // 計算 EMA 2
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

// ==========================================
// --- Plotting Trend Lines ---
// ==========================================
p_ema1 = plot(show_ema1 ? ema1 : na, "EMA 1", color=ema1_col, linewidth=2)
p_ema2 = plot(show_ema2 ? ema2 : na, "EMA 2", color=ema2_col, linewidth=2) // 繪製 EMA 2
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

            
//###############################################


// ==========================================
// --- 2. SMC Order Block ---
// ==========================================
// ==========================================
// --- INPUTS (設定選單) ---
// ==========================================

// 1. 篩選與開關 (Filter Options)
var string G_FILTER = "SMC Order Block"
showBullish      = input.bool(true, "Show Bullish Order Blocks", group=G_FILTER)
showBearish      = input.bool(true, "Show Bearish Order Blocks", group=G_FILTER)

// 2. 結構與驗證 (Structure & Validation Settings)
var string G_VALID  = "Validation Settings"
requireFVG       = input.bool(false, "Require Imbalance/FVG for OB", group=G_VALID)
fvgCheckBars     = input.int(3, "FVG Lookback Bars", minval=0, maxval=5, group=G_VALID, tooltip="檢查近幾根 K 棒是否有 FVG")
mitigateMode     = input.string("Close", "Mitigation Type", options=["High/Low", "Close"], group=G_VALID)

var string G_STRUCT = "Structure Settings"
swingLength      = input.int(3, "Swing High/Low Length", minval=1, group=G_STRUCT)
obLookback       = input.int(10, "OB Candidate Search Range (Bars)", minval=5, maxval=50, group=G_STRUCT, tooltip="BOS 發生時，向向左搜尋最高/最低 K 棒的範圍")

// 3. 視覺與延伸設定 (Style & Extension Settings)
var string G_STYLE_OB  = "OB Style & Extension"
bullColor        = input.color(color.new(color.teal, 70), "Bullish OB Color", group=G_STYLE_OB)
bearColor        = input.color(color.new(color.red, 70), "Bearish OB Color", group=G_STYLE_OB)
extendBarsRight  = input.int(20, "Extend Active OB Right (Bars)", minval=1, group=G_STYLE_OB, tooltip="未破位的 OB 向右延伸長度")
maxMemoryOBs     = input.int(300, "Max Stored OBs in Memory", minval=20, maxval=300, group=G_STYLE_OB, tooltip="記憶體保留的最大 OB 數量")


// ==========================================
// --- TYPES ---
// ==========================================
type OrderBlock
    box      obBox
    float    top
    float    bottom
    bool     isBull
    int      locIndex
    bool     mitigated

var OrderBlock[] allOBs = array.new<OrderBlock>()

// ==========================================
// --- SWING HIGH/LOW & BOS DETECTION ---
// ==========================================
swingHigh = ta.pivothigh(high, swingLength, swingLength)
swingLow  = ta.pivotlow(low, swingLength, swingLength)

var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(swingHigh)
    lastSwingHigh := swingHigh
if not na(swingLow)
    lastSwingLow := swingLow

// 【修正 Warnings 1 & 2】將 ta.crossover / crossunder 移出 if 条件外全局計算
bool isBullishCross = ta.crossover(close, lastSwingHigh)
bool isBearishCross = ta.crossunder(close, lastSwingLow)

bullishBOS = not na(lastSwingHigh) and isBullishCross
bearishBOS = not na(lastSwingLow) and isBearishCross

// ==========================================
// --- FAIR VALUE GAP (FVG) DETECTION ---
// ==========================================
bullishFVG = (low[0] > high[2])
bearishFVG = (high[0] < low[2])

fnCheckFVG(bool isBull, int lookback) =>
    bool hasFVG = false
    for k = 0 to lookback
        if isBull and bullishFVG[k]
            hasFVG := true
            break
        if not isBull and bearishFVG[k]
            hasFVG := true
            break
    hasFVG

// 【修正 Warnings 3 & 4】全局提前計算 FVG，確保每根 K 棒都能無縫執行歷史運算
bool globalBullFVG = fnCheckFVG(true, fvgCheckBars)
bool globalBearFVG = fnCheckFVG(false, fvgCheckBars)

// ==========================================
// --- ORDER BLOCK DETECTION LOGIC ---
// ==========================================

// 看漲 OB (Bullish Order Block)
if bullishBOS and showBullish
    lastSwingHigh := na
    
    int obOffset = 1
    float minLow = low[1]
    
    for i = 1 to obLookback
        if low[i] < minLow
            minLow := low[i]
            obOffset := i
            
    bool validFVG = requireFVG ? globalBullFVG : true
    
    if validFVG
        float obTop    = high[obOffset]
        float obBottom = low[obOffset]
        int obBarIdx   = bar_index - obOffset
        
        box b = box.new(left=obBarIdx, top=obTop, right=bar_index + extendBarsRight, bottom=obBottom, 
                        bgcolor=bullColor, border_color=color.new(color.white, 100), border_style=line.style_solid)
        
        allOBs.push(OrderBlock.new(b, obTop, obBottom, true, obBarIdx, false))

// 看跌 OB (Bearish Order Block)
if bearishBOS and showBearish
    lastSwingLow := na
    
    int obOffset = 1
    float maxHigh = high[1]
    
    for i = 1 to obLookback
        if high[i] > maxHigh
            maxHigh := high[i]
            obOffset := i
            
    bool validFVG = requireFVG ? globalBearFVG : true
    
    if validFVG
        float obTop    = high[obOffset]
        float obBottom = low[obOffset]
        int obBarIdx   = bar_index - obOffset
        
        box b = box.new(left=obBarIdx, top=obTop, right=bar_index + extendBarsRight, bottom=obBottom, 
                        bgcolor=bearColor, border_color=color.new(color.white, 100), border_style=line.style_solid)
        
        allOBs.push(OrderBlock.new(b, obTop, obBottom, false, obBarIdx, false))

// ==========================================
// --- OB MANAGEMENT & CLEANUP ---
// ==========================================
int arraySize = allOBs.size()
if arraySize > 0
    for i = arraySize - 1 to 0
        OrderBlock currentOB = allOBs.get(i)
        
        if not currentOB.mitigated
            currentOB.obBox.set_right(bar_index + extendBarsRight)
            
            bool isMitigated = false
            if currentOB.isBull
                float checkVal = mitigateMode == "Close" ? close : low
                if checkVal < currentOB.bottom
                    isMitigated := true
            else
                float checkVal = mitigateMode == "Close" ? close : high
                if checkVal > currentOB.top
                    isMitigated := true
            
            if isMitigated
                currentOB.obBox.delete()
                allOBs.remove(i)

// 記憶體清理（防止 Array 過大）
if allOBs.size() > maxMemoryOBs
    for i = allOBs.size() - 1 to 0
        OrderBlock checkOB = allOBs.get(i)
        if checkOB.mitigated
            allOBs.remove(i)
            
            
//###############################################


// ==========================================
// --- 3. LuxAlgo S/R ---
// ==========================================
leftBars     = input.int(7, "Pivot 左側 Bars", minval=1, group=sr_grp)
rightBars    = input.int(10, "Pivot 右側 Bars", minval=1, group=sr_grp)
lineLength   = input.int(10, "S/R 線條長度", minval=1, group=sr_grp)

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

highPivot  = ta.pivothigh(high, leftBars, rightBars)
lowPivot   = ta.pivotlow(low, leftBars, rightBars) 
target_vol = volume[rightBars]

// ==========================================
// --- 計算一個動態的微調間距 (Offset) ---
// ==========================================
sr_offset = ta.atr(14) * 0.06

// 處理 Pivot High (阻力位)
if not na(highPivot)
    int pivot_bar = bar_index - rightBars
    int end_bar = pivot_bar + lineLength
    
    line.new(x1=pivot_bar, y1=highPivot, x2=end_bar, y2=highPivot, color=color.red, width=2)
    
    label.new(x=end_bar, y=highPivot + sr_offset, 
              text=format_vol(target_vol), 
              color=color.new(color.white, 100), 
              textcolor=color.rgb(255, 255, 255), 
              style=label.style_none, 
              size=size.small)

// 處理 Pivot Low (支撐位)
if not na(lowPivot)
    int pivot_bar = bar_index - rightBars
    int end_bar = pivot_bar + lineLength
    
    line.new(x1=pivot_bar, y1=lowPivot, x2=end_bar, y2=lowPivot, color=color.blue, width=2)
    
    label.new(x=end_bar, y=lowPivot + sr_offset, 
              text=format_vol(target_vol), 
              color=color.new(color.white, 100), 
              textcolor=color.rgb(255, 255, 255), 
              style=label.style_none, 
              size=size.small)


// ==========================================
// --- Higher Low 偵測邏輯  ---
// ==========================================
var float last_pivot_low = na
var float prev_pivot_low = na
var bool is_higher_low = false
var bool trigger_hl_alert = false

if not na(lowPivot)
    prev_pivot_low := last_pivot_low
    last_pivot_low := lowPivot
    
    if not na(prev_pivot_low) and last_pivot_low > prev_pivot_low
        is_higher_low := true
        
        if close > last_pivot_low
            trigger_hl_alert := true
        else
            trigger_hl_alert := false
    else
        is_higher_low := false
        trigger_hl_alert := false
else
    trigger_hl_alert := false

alertcondition(trigger_hl_alert, title="Higher Low 偵測訊號", message="偵測到更高嘅底部 (Higher Low)！")

plot(last_pivot_low, title="Hidden Last PL", display=display.none)

//###############################################


//###############################################
// --- 4. Pure TD Sequential 9 ---
//###############################################
td_grp = "TD SEQUENTIAL (TD 9)"
show_td9 = input.bool(true, "啟用 TD 9 標籤", group=td_grp)

c_neon_green = color.rgb(255, 220, 0)
c_neon_red   = color.rgb(255, 220, 0)

// 只有當 show_td9 為 true 時才變色
barcolor(show_td9 and is_buy_9 ? c_neon_green : (show_td9 and is_sell_9 ? c_neon_red : na), title="TD 9 Bar Color")

// 只有當 show_td9 為 true 且觸發 is_buy_9 時才顯示標籤
plotshape(show_td9 and is_buy_9,  
     title="TD Buy 9 (帶背景)", 
     text="9", 
     style=shape.labelup, 
     location=location.belowbar, 
     color=color.new(color.green, 20),     
     textcolor=color.white,                
     size=size.tiny)

plotshape(show_td9 and is_sell_9, 
     title="TD Sell 9 (帶背景)", 
     text="9", 
     style=shape.labeldown, 
     location=location.abovebar, 
     color=color.new(color.red, 20),        
     textcolor=color.white,                
     size=size.tiny)


//###############################################


// ==========================================
// --- 5. Cross EMA 9 Label Alert ---
// ==========================================

[h_o, h_h, h_l, h_c] = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, [open, high, low, close], lookahead=barmerge.lookahead_off)

ema9 = ta.ema(h_c, 9)

float higher_line = math.max(ema1, kr_val)

is_green = h_c > h_o

cross_up_higher = (h_c[1] <= higher_line[1]) and (h_c > higher_line)

enhanced_early_signal = cross_up_higher and is_green and barstate.isconfirmed

alert_trigger = enhanced_early_signal 

alertcondition(alert_trigger, title="EMA 9 + KR 複合突破買入訊號", message="Heikin-Ashi 綠K 成功向上突破 EMA1 與 Kernel Regression 的最高線（已收盤確認）！")


//###############################################


// ==========================================
// --- 7. Info Box ---
// ==========================================
info_pos     = input.string("Top Right", "Info Box Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Info Box")
var string f_size = size.small

show_header  = input.bool(true, "顯示 標頭 (Indicator/Status)", group="Info Box 內容顯示開關")
show_ema200  = input.bool(true, "顯示 > 200 EMA", group="Info Box 內容顯示開關")
show_ema9    = input.bool(true, "顯示 > 9 EMA", group="Info Box 內容顯示開關")
show_kernel  = input.bool(true, "顯示 9 EMA > Kernel", group="Info Box 內容顯示開關")
show_hl      = input.bool(true, "顯示 Higher Low", group="Info Box 內容顯示開關")
show_box_vwap = input.bool(true, "顯示 > VWAP", group="Info Box 內容顯示開關")
show_bs_vol  = input.bool(true, "顯示 買賣成交量 (B/S Vol)", group="Info Box 內容顯示開關")
show_rvol    = input.bool(true, "顯示 相對成交量 (RVol)", group="Info Box 內容顯示開關")


// --- 【數據計算】 ---
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
if show_box_vwap 
    total_rows := total_rows + 1
if show_bs_vol
    total_rows := total_rows + 1
if show_rvol
    total_rows := total_rows + 1


table infoBox = table.new(position = info_pos == "Top Right" ? position.top_right : info_pos == "Top Left" ? position.top_left : info_pos == "Bottom Right" ? position.bottom_right : position.bottom_left, columns = 2, rows = total_rows, bgcolor = color.new(color.black, 80), border_width = 1, frame_color = color.gray)

int current_row = 0

if total_rows > 0
    if show_header
        table.cell(infoBox, 0, current_row, "Indicator", text_color = color.white, bgcolor = color.new(color.blue, 70), text_size = f_size)
        table.cell(infoBox, 1, current_row, "Status",    text_color = color.white, bgcolor = color.new(color.blue, 70), text_size = f_size)
        current_row := current_row + 1

    if show_ema200
        table.cell(infoBox, 0, current_row, "> 200 EMA", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, close > ema4 ? "YES" : "NO", text_color = color.white, bgcolor = close > ema4 ? color.new(color.green,0) : color.new(color.red,0), text_size = f_size)
        current_row := current_row + 1

    if show_ema9
        table.cell(infoBox, 0, current_row, "> 9 EMA", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, close > ema1 ? "YES" : "NO", text_color = color.white, bgcolor = close > ema1 ? color.new(color.green,0) : color.new(color.red,0), text_size = f_size)
        current_row := current_row + 1

    if show_kernel
        table.cell(infoBox, 0, current_row, "9 EMA > Kr", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, ema1 > kr_val ? "YES" : "NO", text_color = color.white, bgcolor = ema1 > kr_val ? color.new(color.green,0) : color.new(color.red,0), text_size = f_size)
        current_row := current_row + 1

    if show_hl
        table.cell(infoBox, 0, current_row, "Higher Low", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, na(prev_pivot_low) ? "WAIT" : (is_higher_low ? "YES" : "NO"), text_color = color.white, bgcolor = na(prev_pivot_low) ? color.new(color.orange,0) : is_higher_low ? color.new(color.green,0) : color.new(color.red,0), text_size = f_size)
        current_row := current_row + 1

    if show_box_vwap 
        table.cell(infoBox, 0, current_row, "> VWAP", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, close > vwap_val ? "YES" : "NO", text_color = color.white, bgcolor = close > vwap_val ? color.new(color.green,0) : color.new(color.red,0), text_size = f_size)
        current_row := current_row + 1

    if show_bs_vol
        table.cell(infoBox, 0, current_row, "B/S Vol", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, vol_text_combined, text_color = color.white, bgcolor = vol_box_color, text_size = f_size)
        current_row := current_row + 1

    if show_rvol
        table.cell(infoBox, 0, current_row, "RVol (20)", text_color = color.white, bgcolor = color.new(color.gray, 80), text_size = f_size)
        table.cell(infoBox, 1, current_row, display_rvol_text, text_color = color.white, bgcolor = display_rvol_color, text_size = f_size)
        current_row := current_row + 1


//###############################################


// ==========================================
// --- Up/Down Trendlines ---
// ==========================================

var string G_PIVOT = "Pivot Settings"
pivotLeft           = input.int(10, title="Pivot Left Bars", minval=1, group=G_PIVOT, tooltip="左側 K 棒數量")
pivotRight          = input.int(15, title="Pivot Right Bars", minval=1, group=G_PIVOT, tooltip="右側 K 棒數量")

var string G_SLOPE = "Slope & ATR Settings"
slopeInput          = input.float(1.2, title="Slope Multiplier", group=G_SLOPE)
slopeMethod         = input.string("Atr", title="Slope Calculation Method", options=["Atr"], group=G_SLOPE)
atrLength           = input.int(14, title="ATR Length", minval=1, group=G_SLOPE)

var string G_TOGGLE = "Trendline Toggle & Length"
showAscending       = input.bool(true, title="Show Ascending Trendline", group=G_TOGGLE)
showDescending      = input.bool(true, title="Show Descending Trendline", group=G_TOGGLE)
trendlineLength     = input.int(150, title="Trendline Length (Bars)", minval=1, group=G_TOGGLE)

var string G_CHANNEL = "Channel Settings"
channelWidthMult    = input.float(0.5, title="Channel Width Multiplier", group=G_CHANNEL)
channelWidthSource  = input.string("Atr", title="Channel Width Source", options=["Atr"], group=G_CHANNEL)

var string G_STYLE_TL = "Trendline Color & Style Settings"
upColor             = input.color(color.green, title="Ascending Line Color", group=G_STYLE_TL)
upFillColor         = input.color(color.new(color.green, 85), title="Ascending Fill Color", group=G_STYLE_TL)
dnColor             = input.color(color.red, title="Descending Line Color", group=G_STYLE_TL)
dnFillColor         = input.color(color.new(color.red, 85), title="Descending Fill Color", group=G_STYLE_TL)
lineWidth           = input.int(1, title="Line Width", minval=1, maxval=5, group=G_STYLE_TL)


// ==========================================
// --- 效能優化計算 (Optimized Calculations) ---
// ==========================================

atrValue = ta.atr(atrLength)

pLow  = showAscending ? ta.pivotlow(low, pivotLeft, pivotRight) : na
pHigh = showDescending ? ta.pivothigh(high, pivotLeft, pivotRight) : na

haClose = (open + high + low + close) * 0.25
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) * 0.5 : (haOpen[1] + haClose[1]) * 0.5

isHaGreen = haClose > haOpen
isHaRed   = haClose < haOpen


// ==========================================
// --- 1. 上升趨勢線邏輯 (Ascending Trendline) ---
// ==========================================
var line upCenterLine = na
var line upUpperLine  = na
var line upLowerLine  = na
var linefill upFill   = na

var int upPivotBarIndex = na
var float upPivotPrice  = na
var float upSlope       = na
var float upWidth       = na
var bool isUpActive     = false

if not na(pLow)
    upPivotBarIndex := bar_index - pivotRight
    upPivotPrice    := pLow
    
    float currentAtr = atrValue[pivotRight]
    upSlope         := (currentAtr / atrLength) * slopeInput
    upWidth         := currentAtr * channelWidthMult
    isUpActive      := true

    int endBar = upPivotBarIndex + trendlineLength
    float endCenterPrice = upPivotPrice + (trendlineLength * upSlope)

    line.delete(upCenterLine)
    line.delete(upUpperLine)
    line.delete(upLowerLine)
    linefill.delete(upFill)

    upCenterLine := line.new(upPivotBarIndex, upPivotPrice, endBar, endCenterPrice, color=upColor, style=line.style_dashed, width=lineWidth)
    upUpperLine  := line.new(upPivotBarIndex, upPivotPrice + upWidth, endBar, endCenterPrice + upWidth, color=color.new(upColor, 80), width=lineWidth)
    upLowerLine  := line.new(upPivotBarIndex, upPivotPrice - upWidth, endBar, endCenterPrice - upWidth, color=color.new(upColor, 80), width=lineWidth)
    upFill       := linefill.new(upUpperLine, upLowerLine, color=upFillColor)

if isUpActive
    int barsPassed = bar_index - upPivotBarIndex

    if barsPassed > 0 and barsPassed <= trendlineLength
        float currentUpLowerPrice = upPivotPrice + (barsPassed * upSlope) - upWidth

        if isHaRed and (haClose < currentUpLowerPrice)
            line.delete(upCenterLine)
            line.delete(upUpperLine)
            line.delete(upLowerLine)
            linefill.delete(upFill)
            isUpActive := false


// ==========================================
// --- 2. 下降趨勢線邏輯 (Descending Trendline) ---
// ==========================================
var line dnCenterLine = na
var line dnUpperLine  = na
var line dnLowerLine  = na
var linefill dnFill   = na

var int dnPivotBarIndex = na
var float dnPivotPrice  = na
var float dnSlope       = na
var float dnWidth       = na
var bool isDnActive     = false

if not na(pHigh)
    dnPivotBarIndex := bar_index - pivotRight
    dnPivotPrice    := pHigh
    
    float currentAtr = atrValue[pivotRight]
    dnSlope         := (currentAtr / atrLength) * slopeInput
    dnWidth         := currentAtr * channelWidthMult
    isDnActive      := true

    int endBar = dnPivotBarIndex + trendlineLength
    float endCenterPrice = dnPivotPrice - (trendlineLength * dnSlope)

    line.delete(dnCenterLine)
    line.delete(dnUpperLine)
    line.delete(dnLowerLine)
    linefill.delete(dnFill)

    dnCenterLine := line.new(dnPivotBarIndex, dnPivotPrice, endBar, endCenterPrice, color=dnColor, style=line.style_dashed, width=lineWidth)
    dnUpperLine  := line.new(dnPivotBarIndex, dnPivotPrice + dnWidth, endBar, endCenterPrice + dnWidth, color=color.new(dnColor, 80), width=lineWidth)
    dnLowerLine  := line.new(dnPivotBarIndex, dnPivotPrice - dnWidth, endBar, endCenterPrice - dnWidth, color=color.new(dnColor, 80), width=lineWidth)
    dnFill       := linefill.new(dnUpperLine, dnLowerLine, color=dnFillColor)

if isDnActive
    int barsPassed = bar_index - dnPivotBarIndex

    if barsPassed > 0 and barsPassed <= trendlineLength
        float currentDnUpperPrice = dnPivotPrice - (barsPassed * dnSlope) + dnWidth

        if isHaGreen and (haClose > currentDnUpperPrice)
            line.delete(dnCenterLine)
            line.delete(dnUpperLine)
            line.delete(dnLowerLine)
            linefill.delete(dnFill)
            isDnActive := false
````
