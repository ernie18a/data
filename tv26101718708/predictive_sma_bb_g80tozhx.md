# Predictive SMA & BB

- url: https://www.tradingview.com/script/G80TozhX/
- type: indicator
- pine_id: PUB;0e7431a1e9ff409d9837cf23fe1724c0
- version: 1.0

## Description

■ Overview
Most technical indicators are strictly lagging—they only tell you what has already happened. The "Predictive SMA & BB" flips this paradigm by projecting the Simple Moving Average (SMA) and Bollinger Bands (BB) into the future space of your chart.

This tool allows you to visualize where dynamic support and resistance (the statistical walls) will be in the future, giving you a massive edge in planning limit orders and understanding the element of "time" in your trades.

■ The Core Logic: Forward Fill & Sliding Window
How do we plot the future without a crystal ball?
This script uses a quantitative approach known as "Forward Fill". It simulates the passing of time by assuming the current price remains perfectly flat (sideways).
As it projects bars into the future, the algorithm drops the oldest historical data points from the calculation window (e.g., a 200-period window) and sequentially fills the new future slots with the current close price.

This reveals a powerful mathematical truth: Even if the price doesn't move, moving averages and standard deviations will shift based on the decay of historical data.

■ Key Features & How to Use

Future Baseline Projection: See exactly when a downward-sloping SMA will mathematically curl upwards as old, extreme price data is dropped from the calculation.

Time-Based Squeeze Anticipation: As future bars are populated with flat prices, the projected Bollinger Bands will naturally squeeze, visualizing the expected statistical boundaries if volatility dies down.

Custom UI: Fully customizable from the inputs panel. Toggle the future SMA, BB lines, and cloud fills, and adjust colors/opacity without touching the code.

■ ⚠️ Crucial Limitations & Disclaimers
To use this tool effectively, you must understand its mathematical limitations:

Not a Crystal Ball: This indicator projects a statistical baseline based on the assumption that current prices will maintain a zero-volatility trajectory.

Vulnerability to Volatility Expansion: The projected ±2σ bands do NOT account for sudden, explosive price movements (e.g., macroeconomic news, central bank interventions). If high-impact news hits and volatility expands, the actual bands will violently widen, overriding the projected squeeze.

Decreasing Confidence: The further you project into the future, the more the calculation relies on the "Forward Fill" assumption, naturally decreasing the statistical confidence of the extreme ends of the projection.

Use these projected lines as strategic zones for "waiting in ambush" during normal market conditions, not as absolute guarantees. Combine this with multi-timeframe analysis and your own price action strategies.

## Source Code

````pine
//@version=5
indicator("Predictive SMA & BB", overlay=true, max_lines_count=500)

// ==========================================
// 1. 基本パラメーター設定
// ==========================================
length      = input.int(200, title="SMA 期間", minval=10, group="基本設定")
mult        = input.float(2.0, title="標準偏差(σ)", minval=0.1, group="基本設定")
future_bars = input.int(100, title="未来予測の描画本数", minval=1, maxval=200, group="基本設定")

// ==========================================
// 2. カスタムUI（表示・スタイル設定）
// ==========================================
// --- 未来のSMA ---
show_sma_pred = input.bool(true, title="未来のSMAを表示", group="未来のSMA 設定")
sma_color     = input.color(color.new(#1A237E, 0), title="色 & 透明度", group="未来のSMA 設定")
sma_style_str = input.string("実線 (Solid)", title="線の種類", options=["実線 (Solid)", "点線 (Dotted)", "破線 (Dashed)"], group="未来のSMA 設定")
sma_width     = input.int(1, title="線の太さ", minval=1, maxval=5, group="未来のSMA 設定")

// --- 未来のBB（ボリンジャーバンド） ---
show_bb_pred = input.bool(true, title="未来のBBを表示", group="未来のBB 設定")
bb_color     = input.color(color.new(color.gray, 50), title="色 & 透明度", group="未来のBB 設定")
bb_style_str = input.string("実線 (Solid)", title="線の種類", options=["実線 (Solid)", "点線 (Dotted)", "破線 (Dashed)"], group="未来のBB 設定")
bb_width     = input.int(1, title="線の太さ", minval=1, maxval=5, group="未来のBB 設定")

// --- 未来の塗りつぶし（雲） ---
show_fill_pred = input.bool(false, title="未来のBB内を塗りつぶす", group="未来の塗りつぶし 設定")
fill_color     = input.color(color.new(color.gray, 90), title="塗りつぶしの色 & 透明度", group="未来の塗りつぶし 設定")

// ==========================================
// 3. 内部ロジック & 描画
// ==========================================
// 文字列からラインスタイルに変換する関数
get_line_style(style_str) =>
    style_str == "実線 (Solid)" ? line.style_solid :
     style_str == "点線 (Dotted)" ? line.style_dotted :
     line.style_dashed

sma_style = get_line_style(sma_style_str)
bb_style  = get_line_style(bb_style_str)

// 通常のSMA（現在まで）
sma_normal = ta.sma(close, length)
plot(sma_normal, title="現在 SMA", color=sma_color, linewidth=2)

// 未来予測の計算と描画
if barstate.islast
    var line[] sma_lines = array.new_line()
    var line[] upper_lines = array.new_line()
    var line[] lower_lines = array.new_line()
    var linefill[] bb_fills = array.new_linefill()

    if array.size(sma_lines) > 0
        for i = 0 to array.size(sma_lines) - 1
            line.delete(array.get(sma_lines, i))
            line.delete(array.get(upper_lines, i))
            line.delete(array.get(lower_lines, i))
        array.clear(sma_lines)
        array.clear(upper_lines)
        array.clear(lower_lines)
    
    if array.size(bb_fills) > 0
        for i = 0 to array.size(bb_fills) - 1
            linefill.delete(array.get(bb_fills, i))
        array.clear(bb_fills)

    current_close = close
    historical_closes = array.new_float(length)
    for i = 0 to length - 1
        array.set(historical_closes, i, close[i])

    std_normal = ta.stdev(close, length)
    prev_sma = sma_normal
    prev_upper = sma_normal + mult * std_normal
    prev_lower = sma_normal - mult * std_normal

    for f = 1 to future_bars
        hypo_array = array.new_float(length)
        
        hist_count = length - f
        if hist_count > 0
            for i = 0 to hist_count - 1
                array.set(hypo_array, f + i, array.get(historical_closes, i))
                
        for i = 0 to f - 1
            array.set(hypo_array, i, current_close)
            
        hypo_sma = array.avg(hypo_array)
        hypo_std = array.stdev(hypo_array)
        hypo_upper = hypo_sma + mult * hypo_std
        hypo_lower = hypo_sma - mult * hypo_std
        
        // 描画（カスタムスタイル適用）
        l_sma   = show_sma_pred ? line.new(bar_index + f - 1, prev_sma, bar_index + f, hypo_sma, color=sma_color, width=sma_width, style=sma_style) : na
        
        // 塗りつぶしONで線OFFの場合、枠線を見えなくする処理
        upper_c = show_bb_pred ? bb_color : color.new(color.gray, 100)
        lower_c = show_bb_pred ? bb_color : color.new(color.gray, 100)
        
        l_upper = show_bb_pred or show_fill_pred ? line.new(bar_index + f - 1, prev_upper, bar_index + f, hypo_upper, color=upper_c, width=bb_width, style=bb_style) : na
        l_lower = show_bb_pred or show_fill_pred ? line.new(bar_index + f - 1, prev_lower, bar_index + f, hypo_lower, color=lower_c, width=bb_width, style=bb_style) : na
        
        if show_fill_pred and not na(l_upper) and not na(l_lower)
            array.push(bb_fills, linefill.new(l_upper, l_lower, fill_color))
        
        if not na(l_sma)
            array.push(sma_lines, l_sma)
        if not na(l_upper)
            array.push(upper_lines, l_upper)
        if not na(l_lower)
            array.push(lower_lines, l_lower)
        
        prev_sma   := hypo_sma
        prev_upper := hypo_upper
        prev_lower := hypo_lower
````
