# DOPEWEI DataX [Ultimate Matrix v6]

- url: https://www.tradingview.com/script/lSQqqN9k/
- type: indicator
- pine_id: PUB;5314eabbc13145aab6149dec588e3bc4
- version: 1.0

## Description

DataX 2026 by DopeWei
1. 👑 黃金首選：15分鐘線（15m）— 日內波段與趨勢追蹤
這是最完美的機構級操盤週期。

原因： 50 週期的 CHoCH 可以精準捕捉日內由造市商發動的主要訂單流轉換，且 FVG（失衡箱體）在 15m 具有極高的動態磁鐵效應（回踩測試的假突破最少）。

面板配合： 當您看 15m 圖表時，右上角的 DataX Matrix 面板會自動去撈 60m、240m、1D 的老大哥趨勢。只要大週期全綠，15m 出現 🟢 DataX Buy 就是閉眼進場的高勝率黃金點。

2. 🎯 當沖/波頭（Scalping）首選：5分鐘線（5m）— 獵取流動性
如果您喜歡快進快出，當天收盤不留倉，5m 是極佳的戰場。

原因： 在 5m 線上，LuxAlgo SMC 模組產生的 「x」標籤（Liquidity Sweep / 掃止損插針） 訊號非常敏銳。

技巧： 在 5m 週期，建議專注於抓取價格衝過 5m 高點後失敗、跳出 🔴 DataX Sell 標籤的「假突破逆勢單」，或者是回踩 5m FVG 箱體的「順勢單」，極速吃滿 TP1 ~ TP2 即可離場。

3. 💼 穩健波段/上班族首選：1小時線（1h）或 4小時線（4H）
如果您不想整天盯盤，只想抓大波段。

原因： 1小時與 4小時線產生的 CHoCH 和 BOS 是真正的 macro（宏觀）市場結構轉變。此時出現的 DataX 智慧風控面板（TP/SL），其目標空間會非常宏大。

優勢： 配合「非線性標準差止損」，在 1h 或 4h 線上，您的止損會非常具有抗震盪能力，能徹底過濾掉日內雜訊，咬滿整波大趨勢。

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DOPEWEI DataX - Advanced Trading Analytics System [2026 Space Non-Linear Edition Fixed]

//@version=6
indicator("DOPEWEI DataX [Ultimate Matrix v6]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ====================================================================================================================
// USER INPUTS - DOPEWEI DATAX CONFIGURATION
// ====================================================================================================================
// Group: DOPEWEI DataX - SMC Engine
lenSMC      = input.int(50, 'CHoCH Detection Period', group="1. DataX - SMC Engine")
shortLenSMC = input.int(3, 'IDM Detection Period', group="1. DataX - SMC Engine")
bullCss     = input.color(#089981, 'Bullish Structure Color', group="1. DataX - SMC Engine")
bearCss     = input.color(#ff5252, 'Bearish Structure Color', group="1. DataX - SMC Engine")
showSMC     = input.bool(true, "Show CHoCH & BOS Lines", group="1. DataX - SMC Engine")
showSweeps  = input.bool(true, "Show Liquidity Sweeps (x)", group="1. DataX - SMC Engine")

// Group: DOPEWEI DataX - ZLag Trend Filter
lenZLEMA    = input.int(70, "ZLEMA Length", group="2. DataX - ZLag Filter")
multZLEMA   = input.float(1.2, "ZLEMA Band Multiplier", group="2. DataX - ZLag Filter")
t1          = input.timeframe("5", "MTF Matrix 1", group="2. DataX - ZLag Filter")
t2          = input.timeframe("15", "MTF Matrix 2", group="2. DataX - ZLag Filter")
t3          = input.timeframe("60", "MTF Matrix 3", group="2. DataX - ZLag Filter")
t4          = input.timeframe("240", "MTF Matrix 4", group="2. DataX - ZLag Filter")
t5          = input.timeframe("1D", "MTF Matrix 5", group="2. DataX - ZLag Filter")

// Group: DOPEWEI DataX - Cloud Execution
lenCP       = input.int(35, "High-Low Lookback Period", group="3. DataX - Cloud Execution")
mean_rev    = input.bool(true, "Show Mean Reversion Points (⬥)", group="3. DataX - Cloud Execution")

// Group: DOPEWEI DataX - 2026 Institutional Upgrades
showFVG     = input.bool(true, "Auto-Detect Fair Value Gaps (FVG Boxes)", group="4. DataX - Institutional Engine")
fvgLen      = input.int(15, "FVG Active Bar Display Extension", group="4. DataX - Institutional Engine")
showSignals = input.bool(true, "Show Buy & Sell Visual Labels", group="5. DataX - Execution Labels")
showRiskMgmt= input.bool(true, "Display Scientific Risk Matrix (TP/SL)", group="5. DataX - Execution Labels")

// ==========================================
// MODULE 1: DATAX - SMC ENGINE
// ==========================================
n = bar_index
swings(l)=>
    var os = 0
    var int topx = na
    var int btmx = na
    upper = ta.highest(l), lower = ta.lowest(l)
    os := high[l] > upper ? 0 : low[l] < lower ? 1 : os[1]
    top = os == 0 and os[1] != 0 ? high[l] : na
    topx := os == 0 and os[1] != 0 ? n[l] : topx
    btm = os == 1 and os[1] != 1 ? low[l] : na
    btmx := os == 1 and os[1] != 1 ? n[l] : btmx
    [top, topx, btm, btmx]

[top, topx, btm, btmx] = swings(lenSMC)
[stop, stopx, sbtm, sbtmx] = swings(shortLenSMC)

var osSMC = 0
var top_crossed = false, var btm_crossed = false
var float maxSMC = na, var float minSMC = na
var int max_x1 = na, var int min_x1 = na
var float topy = na, var float btmy = na
var stop_crossed = false, var sbtm_crossed = false    

var bool isBOS_Bull = false
var bool isBOS_Bear = false
var bool isSweep_Bull = false
var bool isSweep_Bear = false

isBOS_Bull := false
isBOS_Bear := false
isSweep_Bull := false
isSweep_Bear := false

if not na(top)
    topy := top
    top_crossed := false
if not na(btm)
    btmy := btm
    btm_crossed := false

if close > topy and not top_crossed
    osSMC := 1
    top_crossed := true
if close < btmy and not btm_crossed
    osSMC := 0
    btm_crossed := true

if osSMC != osSMC[1]
    maxSMC := high, minSMC := low
    max_x1 := n, min_x1 := n
    stop_crossed := false, sbtm_crossed := false
    if osSMC == 1 and showSMC
        line.new(topx, topy, n, topy, color = bullCss, style = line.style_dashed)
        label.new(int(math.avg(n, topx)), topy, 'DataX CHoCH', color = color(na), style = label.style_label_down, textcolor = bullCss, size = size.tiny)
    else if showSMC
        line.new(btmx, btmy, n, btmy, color = bearCss, style = line.style_dashed)
        label.new(int(math.avg(n, btmx)), btmy, 'DataX CHoCH', color = color(na), style = label.style_label_up, textcolor = bearCss, size = size.tiny)

stopy = fixnan(stop)
sbtmy = fixnan(sbtm)

if low < sbtmy and not sbtm_crossed and osSMC == 1 and sbtmy != btmy
    if showSMC
        line.new(sbtmx, sbtmy, n, sbtmy, color = color.gray, style = line.style_dotted)
        label.new(int(math.avg(n, sbtmx)), sbtmy, 'DataX IDM', color = color(na), style = label.style_label_up, textcolor = color.gray, size = size.tiny)
    sbtm_crossed := true

if close > maxSMC and sbtm_crossed and osSMC == 1
    if showSMC
        line.new(max_x1, maxSMC, n, maxSMC, color = bullCss)
        label.new(int(math.avg(n, max_x1)), maxSMC, 'DataX BOS', color = color(na), style = label.style_label_down, textcolor = bullCss, size = size.tiny)
    sbtm_crossed := false
    isBOS_Bull := true

if close < minSMC and stop_crossed and osSMC == 0
    if showSMC
        line.new(min_x1, minSMC, n, minSMC, color = bearCss)
        label.new(int(math.avg(n, min_x1)), minSMC, 'DataX BOS', color = color(na), style = label.style_label_up, textcolor = bearCss, size = size.tiny)
    stop_crossed := false
    isBOS_Bear := true

if high > maxSMC and close < maxSMC and osSMC == 1 and n - max_x1 > 1 and showSweeps
    line.new(max_x1, maxSMC, n, maxSMC, color = color.gray, style = line.style_dotted)
    label.new(int(math.avg(n, max_x1)), maxSMC, 'x', color = color(na), style = label.style_label_down, textcolor = color.gray)
    isSweep_Bull := true

if low < minSMC and close > minSMC and osSMC == 0 and n - min_x1 > 1 and showSweeps
    line.new(min_x1, minSMC, n, minSMC, color = color.gray, style = line.style_dotted)
    label.new(int(math.avg(n, min_x1)), minSMC, 'x', color = color(na), style = label.style_label_up, textcolor = color.gray)
    isSweep_Bear := true

maxSMC := math.max(high, maxSMC)
minSMC := math.min(low, minSMC)
if maxSMC > maxSMC[1]
    max_x1 := n
if minSMC < minSMC[1]
    min_x1 := n

// ==========================================
// MODULE 2: DATAX - ZLAG TREND FILTER
// ==========================================
lagZ = math.floor((lenZLEMA - 1) / 2)
zlema = ta.ema(close + (close - close[lagZ]), lenZLEMA)
volatility = ta.highest(ta.atr(lenZLEMA), lenZLEMA*3) * multZLEMA

var trendZ = 0
if ta.crossover(close, zlema+volatility)
    trendZ := 1
if ta.crossunder(close, zlema-volatility)
    trendZ := -1

zlemaColor = trendZ == 1 ? color.new(bullCss, 85) : color.new(bearCss, 85)
m_p = plot(zlema, title="DataX ZLEMA Baseline", linewidth=1, color=zlemaColor)

s1 = request.security(syminfo.tickerid, t1, trendZ)
s2 = request.security(syminfo.tickerid, t2, trendZ)
s3 = request.security(syminfo.tickerid, t3, trendZ)
s4 = request.security(syminfo.tickerid, t4, trendZ)
s5 = request.security(syminfo.tickerid, t5, trendZ)

s1a = s1 == 1 ? "Bullish" : "Bearish"
s2a = s2 == 1 ? "Bullish" : "Bearish"
s3a = s3 == 1 ? "Bullish" : "Bearish"
s4a = s4 == 1 ? "Bullish" : "Bearish"
s5a = s5 == 1 ? "Bullish" : "Bearish"

if barstate.islast
    var data_table = table.new(position=position.top_right, columns=2, rows=6, bgcolor=chart.bg_color, border_width=1, border_color=chart.fg_color, frame_color=chart.fg_color, frame_width=1)
    table.cell(data_table, column=0, row=0, text="DOPEWEI DataX", text_color=chart.fg_color, text_size=size.small, bgcolor=color.new(chart.fg_color, 15))
    table.cell(data_table, column=1, row=0, text="Matrix Signal", text_color=chart.fg_color, text_size=size.small, bgcolor=color.new(chart.fg_color, 15))
    table.cell(data_table, column=0, row=1, text=t1, text_color=chart.fg_color, text_size=size.small)
    table.cell(data_table, column=1, row=1, text=s1a, text_color=chart.fg_color, bgcolor=s1a == "Bullish" ? color.new(bullCss, 70) : color.new(bearCss, 70), text_size=size.small)
    table.cell(data_table, column=0, row=2, text=t2, text_color=chart.fg_color, text_size=size.small)
    table.cell(data_table, column=1, row=2, text=s2a, text_color=chart.fg_color, bgcolor=s2a == "Bullish" ? color.new(bullCss, 70) : color.new(bearCss, 70), text_size=size.small)
    table.cell(data_table, column=0, row=3, text=t3, text_color=chart.fg_color, text_size=size.small)
    table.cell(data_table, column=1, row=3, text=s3a, text_color=chart.fg_color, bgcolor=s3a == "Bullish" ? color.new(bullCss, 70) : color.new(bearCss, 70), text_size=size.small)
    table.cell(data_table, column=0, row=4, text=t4, text_color=chart.fg_color, text_size=size.small)
    table.cell(data_table, column=1, row=4, text=s4a, text_color=chart.fg_color, bgcolor=s4a == "Bullish" ? color.new(bullCss, 70) : color.new(bearCss, 70), text_size=size.small)
    table.cell(data_table, column=0, row=5, text=t5, text_color=chart.fg_color, text_size=size.small)
    table.cell(data_table, column=1, row=5, text=s5a, text_color=chart.fg_color, bgcolor=s5a == "Bullish" ? color.new(bullCss, 70) : color.new(bearCss, 70), text_size=size.small)

// ==========================================
// MODULE 3: DATAX - CLOUD EXECUTION
// ==========================================
highestCP  = ta.highest(lenCP)
lowestCP   = ta.lowest(lenCP)
highest1CP = ta.highest(int(lenCP / 4))
lowest1CP  = ta.lowest(int(lenCP / 4))

var float valueCP = na
switch
    low  == lowestCP  => valueCP := highestCP  
    high == highestCP => valueCP := lowestCP  
    => valueCP := nz(valueCP[1])           

bandCP  = close > valueCP ? lowestCP : highestCP  
band1CP = close > valueCP ? lowest1CP : highest1CP  
colorCP = close > valueCP ? bullCss : bearCss  

isCrossed = ta.cross(close, bandCP)
p1 = plot(isCrossed ? na : bandCP, title="DataX Outer Band", color=colorCP, linewidth=1, style=plot.style_linebr)  
p2 = plot(band1CP, title="DataX Inner Band", color=color.new(chart.fg_color, 85), linewidth=1, style=plot.style_linebr)  
fill(p1, p2, band1CP, bandCP, color.new(colorCP, 92), color.new(colorCP, 70), fillgaps = true)

mean_rev_dn = ta.crossunder(high, band1CP[1]) and band1CP[1] == high[1] and high != band1CP and not isCrossed and bandCP[1] == bandCP
mean_rev_up = ta.crossover(low, band1CP[1]) and band1CP[1] == low[1]  and low  != band1CP and not isCrossed and bandCP[1] == bandCP

plotchar(mean_rev_dn and mean_rev ? high[1] : na, "DataX Bearish Signal", "⬥", location.absolute, bearCss, size=size.tiny, offset=-1)
plotchar(mean_rev_up and mean_rev ? low[1] : na, "DataX Bullish Signal", "⬥", location.absolute, bullCss, size=size.tiny, offset=-1)

// ====================================================================================================================
// NEW UPGRADE MODULE 4: INSTITUTIONAL FAIR VALUE GAP (FVG) MATRIX ENGINE
// ====================================================================================================================
// 【已修復】改用 v6 標準參數 border_style 與命名空間 line.style_dashed 
if showFVG
    bullish_fvg = (low > high[2]) and (close[1] > high[2])
    bearish_fvg = (high < low[2]) and (close[1] < low[2])
    
    if bullish_fvg
        box.new(left=bar_index[2], top=low, right=bar_index + fvgLen, bottom=high[2], 
               bgcolor=color.new(bullCss, 92), border_color=color.new(bullCss, 75), border_style=line.style_dashed)
               
    if bearish_fvg
        box.new(left=bar_index[2], top=low[2], right=bar_index + fvgLen, bottom=high, 
               bgcolor=color.new(bearCss, 92), border_color=color.new(bearCss, 75), border_style=line.style_dashed)

// ====================================================================================================================
// MODULE 5: DOPEWEI DATAX - EXECUTION SIGNALS & NON-LINEAR RISK MATRIX (TP/SL)
// ====================================================================================================================
current_atr = ta.atr(14)
body_size   = math.abs(close - open)
std_dev     = ta.stdev(body_size, 20)
dynamic_buffer = nz(std_dev * 1.5, current_atr * 0.5)

datax_buy_signal  = (mean_rev_up and trendZ == 1) or isBOS_Bear or isSweep_Bear
datax_sell_signal = (mean_rev_dn and trendZ == -1) or isBOS_Bull or isSweep_Bull

var float last_swing_low = na
var float last_swing_high = na

if not na(btm)
    last_swing_low := btm
if not na(top)
    last_swing_high := top

if showSignals
    if datax_buy_signal
        label.new(bar_index, low, text="🟢 DataX Buy", color=bullCss, textcolor=color.white, style=label.style_label_up, size=size.small)
        
        if showRiskMgmt
            tp1_val = close + (current_atr * 1.0)
            tp2_val = close + (current_atr * 2.0)
            tp3_val = close + (current_atr * 3.0)
            tp4_val = close + (current_atr * 4.5)
            sl_base = not na(last_swing_low) ? last_swing_low : low
            sl_val  = sl_base - dynamic_buffer
            
            risk_text = "📊 DataX Alpha Risk Matrix:\n🛑 SL : " + str.tostring(sl_val, format.mintick) + "\n-------------------------\n🎯 TP1: " + str.tostring(tp1_val, format.mintick) + "\n🎯 TP2: " + str.tostring(tp2_val, format.mintick) + "\n🎯 TP3: " + str.tostring(tp3_val, format.mintick) + "\n🎯 TP4: " + str.tostring(tp4_val, format.mintick)
            
            label.new(bar_index, high + (current_atr * 0.5), text=risk_text, color=color.new(chart.bg_color, 10), textcolor=chart.fg_color, style=label.style_label_lower_left, size=size.small)

    if datax_sell_signal
        label.new(bar_index, high, text="🔴 DataX Sell", color=bearCss, textcolor=color.white, style=label.style_label_down, size=size.small)
        
        if showRiskMgmt
            tp1_val = close - (current_atr * 1.0)
            tp2_val = close - (current_atr * 2.0)
            tp3_val = close - (current_atr * 3.0)
            tp4_val = close - (current_atr * 4.5)
            sl_base = not na(last_swing_high) ? last_swing_high : high
            sl_val  = sl_base + dynamic_buffer
            
            risk_text = "📊 DataX Alpha Risk Matrix:\n🛑 SL : " + str.tostring(sl_val, format.mintick) + "\n-------------------------\n🎯 TP1: " + str.tostring(tp1_val, format.mintick) + "\n🎯 TP2: " + str.tostring(tp2_val, format.mintick) + "\n🎯 TP3: " + str.tostring(tp3_val, format.mintick) + "\n🎯 TP4: " + str.tostring(tp4_val, format.mintick)
            
            label.new(bar_index, low - (current_atr * 0.5), text=risk_text, color=color.new(chart.bg_color, 10), textcolor=chart.fg_color, style=label.style_label_upper_left, size=size.small)

// ==========================================
// MODULE 6: DOPEWEI DATAX - UNIFIED SYSTEM ALERTS
// ==========================================
alertcondition((mean_rev_up and trendZ == 1), "DataX: Strong Alpha Buy", "DOPEWEI DataX Matrix Alignment: Bullish Structure Confluence detected.")
alertcondition((mean_rev_dn and trendZ == -1), "DataX: Strong Alpha Sell", "DOPEWEI DataX Matrix Alignment: Bearish Structure Confluence detected.")
````
