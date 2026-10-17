# Macro Fibo LookBack

- url: https://www.tradingview.com/script/PeNVz4NT/
- type: indicator
- pine_id: PUB;27235df747e0409ab1c34d2830feba03
- version: 1.0

## Description

Auto Macro Fibonacci (
Overview
Drawing Fibonacci retracements manually on higher timeframes can often be subjective and tedious. The Auto Macro Fibonacci indicator automates this process by scanning a user-defined historical period (lookback) to identify the absolute macro peak and trough, instantly plotting a flawless, rule-based Fibonacci retracement.

Whether you are looking for deep pullbacks, harmonic pattern completion zones, or major structural support/resistance, this tool filters out the intraday noise and focuses on the big picture.

Key Features

Smart Lookback Engine: Scans the last X bars (default is 300) to find the true macro high and low. You can easily expand this to 500 or 1000 bars to capture multi-year trends.

Auto Trend Detection: The algorithm mathematically calculates which pivot happened first, automatically determining if the macro trend is bullish or bearish, and aligns the 0.0 and 1.0 anchor levels correctly.

Custom Directional Control: Prefer your Fibo anchors drawn differently? Use the settings menu to override the auto-detection and force the draw from "Left to Right" or "Right to Left" to suit your personal trading style.

Includes the 0.886 Level: By default, this indicator includes the 0.886 retracement level, a critical zone for Harmonic pattern traders (specifically the Bat form) and deep liquidity grabs.

Performance Optimized: Built with a custom garbage-collection system (memory management). It dynamically deletes old historical lines on every tick, ensuring it runs lightning-fast on live markets without lagging your chart or hitting TradingView's drawing limits.

Minimalist UI: Designed to keep your charts clean. A single color setting applies to the entire Fibonacci web and the macro dashed trendline, with carefully balanced transparency levels so it doesn't distract from price action.

How to Use

Lookback Period (Bars): Adjust this number to widen or narrow the indicator's field of vision. Smaller numbers (e.g., 100) will catch intermediate swings, while larger numbers (e.g., 500+) will catch major cycle highs and lows.

Fibo Direction: Leave it on "Automatic" for algorithmic trend plotting, or manually flip the 0.0 and 1.0 levels.

Lines Color: Pick one color to seamlessly theme the entire indicator.

Disclaimer: This script is for educational and analytical purposes only. Always use proper risk management.

## Source Code

````pine
//@version=5
indicator("MacroFiboV7", overlay=true, max_lines_count=50, max_labels_count=50)

// --- INPUTS ---
grp_1 = "Scan Settings"
lookback = input.int(300, "Lookback Period (Bars)", minval=50, maxval=5000, group=grp_1)
fibo_dir = input.string("Automatic", "Fibo Direction", options=["Automatic", "Left to Right", "Right to Left"], group=grp_1)

grp_2 = "Visual Settings"
c_lines = input.color(color.orange, "Lines Color", group=grp_2)

// --- GARBAGE COLLECTION (BELLEK YÖNETİMİ) ---
// Eski çizgileri hafızada tutup silmek için değişkenler
var line active_trend = na
var line[] active_fibs = array.new_line()
var label[] active_lbls = array.new_label()

// --- CALCULATION ---
hh_offset = ta.highestbars(high, lookback)
ll_offset = ta.lowestbars(low, lookback)
hh = ta.highest(high, lookback)
ll = ta.lowest(low, lookback)

if barstate.islast
    // 1. Yeni çizim yapmadan önce ekrandaki eski çizgileri temizle
    line.delete(active_trend)
    while array.size(active_fibs) > 0
        line.delete(array.pop(active_fibs))
    while array.size(active_lbls) > 0
        label.delete(array.pop(active_lbls))

    // 2. Zaman ve Fiyat Hesaplamaları
    time_hh = time[math.abs(hh_offset)]
    time_ll = time[math.abs(ll_offset)]
    
    float start_p = na
    float end_p   = na
    int   start_t = na
    int   end_t   = na
    
    bool is_hh_older = time_hh < time_ll
    
    // Yön Mantığı
    if fibo_dir == "Left to Right"
        start_p := is_hh_older ? hh : ll
        start_t := is_hh_older ? time_hh : time_ll
        end_p   := is_hh_older ? ll : hh
        end_t   := is_hh_older ? time_ll : time_hh
        
    else if fibo_dir == "Right to Left"
        start_p := is_hh_older ? ll : hh
        start_t := is_hh_older ? time_ll : time_hh
        end_p   := is_hh_older ? hh : ll
        end_t   := is_hh_older ? time_hh : time_ll
        
    else
        // Otomatik Yön
        is_up = hh_offset > ll_offset 
        start_p := is_up ? ll : hh
        start_t := is_up ? time_ll : time_hh
        end_p   := is_up ? hh : ll
        end_t   := is_up ? time_hh : time_ll
    
    // --- DRAWING ---
    
    // ANA TREND ÇİZGİSİ: Şeffaflık sıfırlandı, birebir aynı renk, ince ve kesikli
    active_trend := line.new(start_t, start_p, end_t, end_p, xloc=xloc.bar_time, color=c_lines, style=line.style_dashed, width=1)
    
    // Fibo Oranları
    fibo_ratios = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 0.886, 1.0)
    
    time_step = time - time[1]
    x_end = time + (time_step * 30) 
    x_start_line = math.min(start_t, end_t)

    for r in fibo_ratios
        // Seviye hesaplama
        lvl = end_p + (start_p - end_p) * r
        
        // FİBO ÇİZGİLERİ: Trend çizgisiyle aynı renk, ince ve düz çizgi
        l = line.new(x_start_line, lvl, x_end, lvl, xloc=xloc.bar_time, color=c_lines, style=line.style_solid, width=1)
        array.push(active_fibs, l)
        
        // FİBO ETİKETLERİ
        txt = str.tostring(r) + " (" + str.tostring(lvl, "#.##") + ")"
        lb = label.new(x_end, lvl, txt, xloc=xloc.bar_time, style=label.style_none, textcolor=c_lines, size=size.normal)
        array.push(active_lbls, lb)
````
