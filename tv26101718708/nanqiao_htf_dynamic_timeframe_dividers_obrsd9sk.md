# [Nanqiao] HTF Dynamic Timeframe Dividers

- url: https://www.tradingview.com/script/obRSd9sk/
- type: indicator
- pine_id: PUB;ef5b23eab12d4db788796d17e551b073
- version: 1.0

## Description

[Overview]
A minimalist yet powerful visual aid for professional intra-day traders. This indicator automatically plots vertical dividers representing Higher Timeframe (HTF) openings directly onto your current lower timeframe chart. Perfect for Price Action and ICT traders who need to stay aware of HTF boundaries.

[Dynamic Mapping]

1m Chart -> 15m Boundaries

5m Chart -> 1h Boundaries

15m Chart -> 4h Boundaries

1h/4h Chart -> Daily Boundaries

Daily Chart -> Weekly Boundaries

[Key Features]

Smart Scaling: Unlike other scripts that break your price scale (Auto-Scale), this script uses dynamic price anchoring to ensure your candlesticks remain perfectly visible.

Clutter-Free: Automatically manages and displays only the 10 most recent dividers to keep your focus on current price action.

Zero Lag: Optimized logic for high performance on Nasdaq (NQ) and S&P 500 (ES) futures trading.

## Source Code

````pine
//@version=5
indicator("高周期时间分割线 (南桥-修复版)", overlay=true)

// --- 1. 周期匹配逻辑 ---
string htf = ""
if timeframe.isminutes
    if timeframe.multiplier == 1
        htf := "15"
    else if timeframe.multiplier == 5
        htf := "60"
    else if timeframe.multiplier == 15
        htf := "240"
    else if timeframe.multiplier == 60
        htf := "1D"
    else if timeframe.multiplier == 240    
        htf := "1D"
else if timeframe.isdaily
    htf := "1W"        
else if timeframe.isweekly
    htf := "12M"

// --- 2. 变量持久化声明 ---
var line[] v_line_array = array.new_line() 
v_line_color = color.new(color.gray, 60) 

// --- 3. 核心绘图逻辑 ---
if timeframe.change(htf)
    // 【修复点】：y坐标直接引用当前K线的low和high，配合extend.both
    // 这样它会自动无限延伸，但不会干扰坐标轴的自动缩放
    new_v = line.new(bar_index, low, bar_index, high, 
         xloc=xloc.bar_index, 
         extend=extend.both, 
         color=v_line_color, 
         style=line.style_dashed, 
         width=1)
    
    // 管理数组
    array.push(v_line_array, new_v)
    
    // 保留最近 10 根分割线
    if array.size(v_line_array) > 10
        line.delete(array.shift(v_line_array))
````
