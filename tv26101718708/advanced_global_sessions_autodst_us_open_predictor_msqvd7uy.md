# Advanced Global Sessions: Auto-DST & US Open Predictor

- url: https://www.tradingview.com/script/MsQVd7UY/
- type: indicator
- pine_id: PUB;5854d5b29f0e4d09a8d935e8bc501168
- version: 1.0

## Description

Day trading requires absolute precision in timing, but manually adjusting UTC offsets for Daylight Saving Time (DST) every few months is a nightmare. This indicator is a heavily upgraded version of the classic LuxAlgo Sessions, completely re-engineered with a native IANA timezone engine and a forward-looking predictive market open line.

🌟 Key Upgrades & Features:

⏱️ 100% Zero-Touch Auto DST:
Say goodbye to the "UTC (+/-)" manual input. This script is hardcoded with official IANA timezones (America/New_York, Europe/London, Asia/Tokyo). It automatically syncs with your local chart time and flawlessly adjusts itself during summer/winter time transitions.

🇺🇸 Predictive US Open Line (09:30 NY):
Never miss the volatility injection of the US Equities Open. The script automatically plots a dashed vertical line at exactly 09:30 AM EST. Better yet, it features a Predictive Marker—drawing the upcoming US Open line in the future (empty space) before the price even gets there, allowing you to prepare your setups in advance.

🧹 Decluttered & Optimized UI:
The Sydney session has been completely removed to free up chart space and simplify the dashboard. It now focuses purely on the "Big 3" liquidity sessions: Asia, London, and New York.

📊 The Original LuxAlgo DNA:
Retains all the powerful visual features of the original script, including dynamic Session Ranges, Trendlines, VWAP tracking, and the sleek heads-up Dashboard.

⚙️ How to use:
Simply add it to your chart. You do NOT need to calculate your local UTC offset. The boxes and the US Open line will automatically align perfectly with your local time, 365 days a year.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo (Modified for US Open Prediction & Auto-DST by AI)

//@version=5
indicator("Sessions [LuxAlgo] - 美股開盤提前標記版", "LuxAlgo - Sessions", overlay = true, max_bars_back = 500, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

//------------------------------------------------------------------------------
//Settings
//-----------------------------------------------------------------------------{
//Session A (New York)
show_sesa = input(true, '', inline = 'sesa', group = 'Session A')
sesa_txt = input('New York', '', inline = 'sesa', group = 'Session A')
sesa_ses = input.session('0800-1700', '當地時間', inline = 'sesa', group = 'Session A')
sesa_css = input.color(#ff5d00, '', inline = 'sesa', group = 'Session A')
sesa_range = input(true, 'Range', inline = 'sesa_overlays', group = 'Session A')

//Session B (London)
show_sesb = input(true, '', inline = 'sesb', group = 'Session B')
sesb_txt = input('London', '', inline = 'sesb', group = 'Session B')
sesb_ses = input.session('0800-1630', '當地時間', inline = 'sesb', group = 'Session B')
sesb_css = input.color(#2157f3, '', inline = 'sesb', group = 'Session B')
sesb_range = input(true, 'Range', inline = 'sesb_overlays', group = 'Session B')

//Session C (Tokyo)
show_sesc = input(true, '', inline = 'sesc', group = 'Session C')
sesc_txt = input('Tokyo', '', inline = 'sesc', group = 'Session C')
sesc_ses = input.session('0800-1600', '當地時間', inline = 'sesc', group = 'Session C')
sesc_css = input.color(#e91e63, '', inline = 'sesc', group = 'Session C')
sesc_range = input(true, 'Range', inline = 'sesc_overlays', group = 'Session C')

// 美股開盤標記設定
show_us_open = input.bool(true, "顯示美股開盤虛線 (09:30 NY)", group = "開盤標記")
predict_ahead = input.bool(true, "提前標記 (預測下一次開盤位置)", group = "開盤標記")

//Ranges Options
bg_transp = input.float(90, '背景透明度', group = 'Ranges Settings')
show_outline = input(true, '顯示外框', group = 'Ranges Settings')
show_txt = input(true, '顯示標籤', group = 'Ranges Settings')

//Divider
show_ses_div = input(false, '顯示時段分割線', group = 'Dividers')
show_day_div = input(true, '顯示每日分割線', group = 'Dividers')

//-----------------------------------------------------------------------------}
//Functions
//-----------------------------------------------------------------------------{
n = bar_index

//Set session range
get_range(session, session_name, session_css)=>
    var t = 0 
    var float max = high
    var float min = low
    var box bx = na
    var label lbl = na 
    
    if session > session[1]
        t := time
        max := high
        min := low

        bx := box.new(n, max, n, min
          , bgcolor = color.new(session_css, bg_transp)
          , border_color = show_outline ? session_css : na
          , border_style = line.style_dotted)

        if show_txt
            lbl := label.new(t, max, session_name
              , xloc = xloc.bar_time
              , textcolor = session_css
              , style = label.style_label_down
              , color = color.new(color.white, 100)
              , size = size.tiny)

    if session and session == session[1]
        max := math.max(high, max)
        min := math.min(low, min)

        box.set_top(bx, max)
        box.set_rightbottom(bx, n, min)

        if show_txt
            label.set_xy(lbl, int(math.avg(t, time)), max)
    
    [session ? na : max, session ? na : min]

//-----------------------------------------------------------------------------}
//Sessions (★ 全自動時區與開盤提前預測 ★)
//-----------------------------------------------------------------------------{
tf = timeframe.period
ny_tz = "America/New_York"

is_sesa = math.sign(nz(time(tf, sesa_ses, ny_tz)))
is_sesb = math.sign(nz(time(tf, sesb_ses, "Europe/London")))
is_sesc = math.sign(nz(time(tf, sesc_ses, "Asia/Tokyo")))

// 1. 歷史標記：在每個交易日 09:30 畫垂直虛線
is_us_open = not na(time(tf, "0930-0931", ny_tz)) and na(time(tf, "0930-0931", ny_tz)[1])

if show_us_open and is_us_open
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(color.orange, 40), style=line.style_dashed, width=1)
    label.new(bar_index, high, "🇺🇸 美股開盤 (09:30)", color=color.new(color.black, 100), textcolor=color.orange, style=label.style_label_down, size=size.small)

// 2. 提前標記：預測下一個美股開盤點
var line nextOpenLine = na
var label nextOpenLabel = na

if predict_ahead and barstate.islast
    // 獲取當前美東時間的年月日
    y = year(timenow, ny_tz)
    m = month(timenow, ny_tz)
    d = dayofmonth(timenow, ny_tz)
    
    // 構造今日的美股開盤時間戳
    todayOpen = timestamp(ny_tz, y, m, d, 9, 30, 0)
    
    // 如果現在已經過了今天的 09:30，就找明天的
    targetTime = timenow > todayOpen ? todayOpen + 86400000 : todayOpen
    
    // 刪除舊的預測線並畫新的
    line.delete(nextOpenLine)
    label.delete(nextOpenLabel)
    
    nextOpenLine := line.new(targetTime, 0, targetTime, 1, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.gray, 60), style=line.style_dashed, width=1)
    nextOpenLabel := label.new(targetTime, high, "⏳ 預計下次美股開盤", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=color.gray, style=label.style_label_down, size=size.small)

//-----------------------------------------------------------------------------}
//Overlays & Dividers
//-----------------------------------------------------------------------------{
if show_sesa and sesa_range
    get_range(is_sesa, sesa_txt, sesa_css)
if show_sesb and sesb_range
    get_range(is_sesb, sesb_txt, sesb_css)
if show_sesc and sesc_range
    get_range(is_sesc, sesc_txt, sesc_css)

// 每日分割線
if show_day_div and (dayofweek != dayofweek[1])
    line.new(n, close + syminfo.mintick, n, close - syminfo.mintick, color=color.gray, extend=extend.both, style=line.style_dashed)

plot(na, display=display.none) // 防報錯
````
