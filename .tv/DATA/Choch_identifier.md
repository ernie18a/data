<!-- tradingview-pine-id: PUB;cfff152e7d9149cda84fc4827aa107f9 -->
<!-- tradingviewscripts-format: 1 -->
# Choch identifier

Source: https://www.tradingview.com/script/jjDJ98zA-Choch-identifier/

## Description

Here is a professional and engaging description you can copy and paste directly into your TradingView script publication page:

ChoCh Identifier: All-in-One Structure, Order Blocks & VWAP

TradingView's free tier restricts users to just three indicators per chart, making it difficult to build a complete trading setup without upgrading. I created the ChoCh Identifier to solve this exact problem. By bundling essential price action, volume, and trend tools into a single, highly optimized script, this indicator makes high-quality trading tools accessible to everyone while saving your valuable indicator slots.

If this script helps you catch better setups or saves you subscription fees, consider supporting my work! You can buy me a coffee here: https://ko-fi.com/tradeguru/ ☕

Need a tool tailored specifically to your trading plan? You can also contact me directly for custom Pine Script development and custom indicators.

🛠️ What's Included in This Script
This indicator is a comprehensive powerhouse, combining customized open-source logic with brand-new structural elements to give you a complete view of the market.

Market Structure Trend Matrix (ChoCh): Identifies structural shifts (Change of Character) and provides a dynamic ATR trailing stop to help you ride the trend. (Credit: Built upon the original Trend Matrix logic by BigBeluga).

Volume-Trend Order Block Engine: Automatically detects and draws Bullish and Bearish Order Blocks driven by the active ChoCh direction. It includes real-time buy/sell volume ratios within the blocks and automatically deletes them upon a complete break. (Credit: Adapted from the Order Block Engine by BigBeluga).

Structure & Swing Point Levels (S/R Lines): My own custom addition to the script. This feature maps out critical support and resistance levels based on historical swing pivots, reinforcing the structural memory of the chart.

VWAP (Volume Weighted Average Price): Integrated directly into the script to help you further validate trend direction and ChoCh signals without needing to load a separate indicator.

⚙️ Key Features & Settings
Fully Customizable: Tweak lookback periods, ATR multipliers, and swing point strengths to fit your specific timeframe and asset.

Clean Visuals: Control exactly what you want to see. Toggle the VWAP, Order Blocks, historical targets, or S/R lines on and off to keep your chart as clean as you prefer.

Retest Signals: Built-in markers alert you when the price successfully retests a valid Order Block with sufficient volume.

License & Credits:
This derivative work is distributed under the same CC BY-NC-SA 4.0 license as the original scripts to honor the open-source community. Massive thanks to BigBeluga for the foundational logic on the Trend Matrix and Order Blocks!

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// -----------------------------------------------------------------------------------------
// ATTRIBUTION & CREDITS:
// © Original "Market Structure Trend Matrix" and "Volume-Trend Order Block Engine" by BigBeluga.
// Modified, expanded, and combined by jan80hansen.
//
// ABOUT THIS DERIVATIVE WORK:
// This indicator, "Choch identifier", is built upon BigBeluga's open-source Trend Matrix and 
// Order Block logic. It is distributed under the same CC BY-NC-SA 4.0 license to honor and 
// protect the original author's work.
//
// NEW ADDITIONS & MODIFICATIONS (by jan80hansen):
// 1. Structure and Swing Point Levels: A custom invention added to reinforce the trend matrix.
// 2. VWAP (Volume Weighted Average Price): Integrated to further validate trend direction 
//    and ChoCh (Change of Character) signals.
//
// PURPOSE & PHILOSOPHY:
// TradingView restricts free users to a maximum of 3 indicators per chart, and not everyone 
// has the financial means to subscribe to premium plans. The core purpose of this combined 
// script is to save valuable indicator slots for the community by packaging essential trend, 
// volume, and structure tools into one comprehensive, accessible indicator.
// -----------------------------------------------------------------------------------------

//@version=6
indicator("Choch identifier", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ＩＮＰＵＴＳ ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

gp_ms          = "Market Structure (Trend Matrix)"
msLen          = input.int(10, "Market Structure Length", tooltip = "Lookback/lookahead for pivots defining market structure and ChoCh.", group = gp_ms)
atrLength      = input.int(14, "ATR Length", tooltip = "ATR period for trailing stop and target distance.", group = gp_ms)
atrMult        = input.float(4.0, "ATR Multiplier", tooltip = "ATR × this = distance from price to trailing stop.", group = gp_ms)
targetStepMult = input.float(2.0, "Target Step (ATR Multiplier)", tooltip = "Vertical distance between infinite targets, in ATR.", group = gp_ms)
bullColor      = input.color(color.rgb(52, 230, 126), "Bullish Color", group = gp_ms)
bearColor      = input.color(color.rgb(255, 82, 241), "Bearish Color", group = gp_ms)
showHistory    = input.bool(true, "Show Target History", tooltip = "Hide historical target lines/labels when off.", group = gp_ms)
showStop       = input.bool(true, "Show Trailing Stop", tooltip = "Show/hide ATR trailing stop line and fill.", group = gp_ms)

gp_ob          = "Order Block Settings"
obAtrLen       = input.int(50, title = "OB Volatility SMA Length", tooltip = "Number of candles for average range (High - Low) determining OB box height.", group = gp_ob)
pivot_len      = input.int(7, title = "Pivot Strength", minval = 1, tooltip = "Number of bars to confirm a swing high/low pivot (left and right).", group = gp_ob)
bull_col       = input.color(#00ffcc, title = "Bullish OB Color", group = gp_ob)
bear_col       = input.color(#ff007f, title = "Bearish OB Color", group = gp_ob)
txt_col        = input.color(#e0e0e0, title = "OB Text Label Color", group = gp_ob)
delete_on_break = input.bool(true, title = "Delete OB on Complete Break", tooltip = "Automatically delete order block when price breaks completely through it.", group = gp_ob)

gp_filt        = "Retest Filter Settings"
show_bull_retest = input.bool(true, title = "Bullish Retest Signals", tooltip = "Signal when price crosses up through bull OB top.", group = gp_filt, inline = "bull_ret")
bull_vol_pct     = input.float(50.0, title = "Min Buy %", minval = 0.0, maxval = 100.0, step = 5.0, tooltip = "Minimum buy volume % in the initial pivot window.", group = gp_filt, inline = "bull_ret")
bull_sig_col     = input.color(#00ffcc, title = "Color", group = gp_filt, inline = "bull_ret")
show_bear_retest = input.bool(true, title = "Bearish Retest Signals", tooltip = "Signal when price crosses down through bear OB bottom.", group = gp_filt, inline = "bear_ret")
bear_vol_pct     = input.float(50.0, title = "Min Sell %", minval = 0.0, maxval = 100.0, step = 5.0, tooltip = "Minimum sell volume % in the initial pivot window.", group = gp_filt, inline = "bear_ret")
bear_sig_col     = input.color(#ff007f, title = "Color", group = gp_filt, inline = "bear_ret")

gp_sr     = "Structure and Swing Point Levels (S/R Lines)"
piv_len   = input.int(20, title = "Swing Point Lookback (Strength)", minval = 5, tooltip = "Number of bars right/left to form a top/bottom becoming support/resistance.", group = gp_sr)
srRes_col = input.color(color.new(color.red, 10), title = "Resistance Line", group = gp_sr)
srSup_col = input.color(color.new(color.green, 10), title = "Support Line", group = gp_sr)

gp_vwap   = "VWAP Settings"
show_vwap = input.bool(true, "Show VWAP", tooltip = "Show/hide the Volume Weighted Average Price.", group = gp_vwap)
vwap_col  = input.color(color.rgb(33, 150, 243), "VWAP Color", group = gp_vwap)

// }

// ＣＡＬＣ: MARKET STRUCTURE / ChoCh (Trend Matrix) ―――――――――――――――――――――――――――――――――――――――――――――――――――――{

ph = ta.pivothigh(msLen, msLen)
pl = ta.pivotlow(msLen, msLen)

var float phVal = na
var float plVal = na
var int phIndx = 0
var int plIndx = 0
var bool direction = false   // true = bull structure, false = bear structure (drives OB direction)

float atr = ta.atr(atrLength)
var float atrTS = na

var float entryPrice = na
var float currentTarget = na
var line targetLine = na
var int trendStart = 0

var line[]  targetLines  = array.new_line()
var label[] targetLabels = array.new_label()

clearCurrentTrendObjects() =>
    if array.size(targetLines) > 0
        for i = 0 to array.size(targetLines) - 1
            line.delete(array.get(targetLines, i))
        array.clear(targetLines)
    if array.size(targetLabels) > 0
        for i = 0 to array.size(targetLabels) - 1
            label.delete(array.get(targetLabels, i))
        array.clear(targetLabels)

if not na(ph)
    phVal := high[msLen]
    phIndx := bar_index[msLen]

if not na(pl)
    plVal := low[msLen]
    plIndx := bar_index[msLen]

if ta.crossover(close, phVal) and not direction
    direction := true
    atrTS := close - (atr * atrMult)
    entryPrice := phVal
    currentTarget := entryPrice + (atr * targetStepMult)
    trendStart := bar_index

    line.new(phIndx, phVal, bar_index, phVal, color = bullColor, width = 2)
    label.new(int(math.avg(phIndx, bar_index)), phVal, "ChoCh ↑", style = label.style_label_down, color = na, textcolor = bullColor)

    line.delete(targetLine)
    targetLine := line.new(bar_index, currentTarget, bar_index + 10, currentTarget, color = color.new(bullColor, 0), width = 1)

if ta.crossunder(close, plVal) and direction
    direction := false
    atrTS := close + (atr * atrMult)
    entryPrice := plVal
    currentTarget := entryPrice - (atr * targetStepMult)
    trendStart := bar_index

    line.new(plIndx, plVal, bar_index, plVal, color = bearColor, width = 2)
    label.new(int(math.avg(plIndx, bar_index)), plVal, "ChoCh ↓", style = label.style_label_up, color = na, textcolor = bearColor)

    line.delete(targetLine)
    targetLine := line.new(bar_index, currentTarget, bar_index + 10, currentTarget, color = color.new(bearColor, 0), width = 1)

directionChange = direction != direction[1]

if directionChange and not showHistory
    clearCurrentTrendObjects()

if direction
    atrTS := math.max(nz(atrTS, close - (atr * atrMult)), close - (atr * atrMult))

    if high >= currentTarget and not na(currentTarget)
        line.set_x2(targetLine, bar_index)
        line.set_style(targetLine, line.style_dashed)
        line.set_x1(targetLine, trendStart)

        array.push(targetLines, targetLine)
        perc = (currentTarget - entryPrice) / entryPrice * 100
        array.push(targetLabels, label.new(trendStart, currentTarget, str.format("+{0,number,#.##}%", perc), style = label.style_none, textcolor = bullColor, size = size.small))

        currentTarget := currentTarget + (atr * targetStepMult)
        targetLine := line.new(trendStart, currentTarget, bar_index + 10, currentTarget, color = color.new(bullColor, 40), width = 1)
    else
        line.set_x2(targetLine, bar_index + 10)
else
    atrTS := math.min(nz(atrTS, close + (atr * atrMult)), close + (atr * atrMult))

    if low <= currentTarget and not na(currentTarget)
        line.set_x2(targetLine, bar_index)
        line.set_style(targetLine, line.style_dashed)
        line.set_x1(targetLine, trendStart)

        array.push(targetLines, targetLine)
        perc = (currentTarget - entryPrice) / entryPrice * 100
        array.push(targetLabels, label.new(trendStart, currentTarget, str.format("{0,number,#.##}%", perc), style = label.style_none, textcolor = bearColor, size = size.small))

        currentTarget := currentTarget - (atr * targetStepMult)
        targetLine := line.new(trendStart, currentTarget, bar_index + 10, currentTarget, color = color.new(bearColor, 40), width = 1)
    else
        line.set_x2(targetLine, bar_index + 10)

// }

// ＣＡＬＣ: ORDER BLOCKS (Driven by ChoCh direction) ―――――――――――――――――――――――――――――――――――――――――――――――――――――{

custom_atr = ta.sma(high - low, obAtrLen)   // OB box height

pivot_low  = ta.pivotlow(low, pivot_len, pivot_len)
pivot_high = ta.pivothigh(high, pivot_len, pivot_len)

var box active_top_box = na
var box active_bot_box = na
var float active_top = na
var float active_bot = na
var float active_buy_ratio = na
var int active_ob_trend = 0

is_overlapping(float new_top, float new_bot) =>
    if na(active_top) or na(active_bot)
        false
    else
        not (new_bot > active_top or new_top < active_bot)

p_idx = bar_index - pivot_len

get_window_volume_ratio(int lookback_len) =>
    float buy_vol = 0.0
    float sell_vol = 0.0
    for i = 0 to lookback_len by 1
        if close[i] >= open[i]
            buy_vol := buy_vol + volume[i]
        else
            sell_vol := sell_vol + volume[i]
    total_vol = buy_vol + sell_vol
    float buy_pct = total_vol > 0 ? buy_vol / total_vol : 0.5
    buy_pct

var int ob_start_bar = na

// 1. Bull Order Blocks — only when market structure is bullish (after bull-ChoCh)
if direction and not na(pivot_low)
    ob_top = math.min(open[pivot_len], close[pivot_len])
    ob_bot = ob_top - custom_atr

    if not is_overlapping(ob_top, ob_bot)
        if not na(active_top_box)
            box.set_right(active_top_box, p_idx)
            box.set_right(active_bot_box, p_idx)

        ob_start_bar := p_idx
        active_top := ob_top
        active_bot := ob_bot
        active_ob_trend := 1

        float buy_ratio = get_window_volume_ratio(pivot_len)
        active_buy_ratio := buy_ratio
        float sell_ratio = 1.0 - buy_ratio
        float split_price = active_bot + (active_top - active_bot) * buy_ratio

        string top_text = "Sell: " + str.tostring(math.round(sell_ratio * 100)) + "%"
        string bot_text = "Buy: " + str.tostring(math.round(buy_ratio * 100)) + "%"

        active_top_box := box.new(left = ob_start_bar, top = active_top, right = bar_index, bottom = split_price, bgcolor = color.new(bull_col, 85), border_color = color.new(bull_col, 40), text = top_text, text_color = txt_col, text_size = size.small, text_valign = text.align_center, text_halign = text.align_right)
        active_bot_box := box.new(left = ob_start_bar, top = split_price, right = bar_index, bottom = active_bot, bgcolor = color.new(bull_col, 75), border_color = color.new(bull_col, 40), text = bot_text, text_color = txt_col, text_size = size.small, text_valign = text.align_center, text_halign = text.align_right)

// 2. Bear Order Blocks — only when market structure is bearish (after bear-ChoCh)
if not direction and not na(pivot_high)
    ob_bot = math.max(open[pivot_len], close[pivot_len])
    ob_top = ob_bot + custom_atr

    if not is_overlapping(ob_top, ob_bot)
        if not na(active_top_box)
            box.set_right(active_top_box, p_idx)
            box.set_right(active_bot_box, p_idx)

        ob_start_bar := p_idx
        active_top := ob_top
        active_bot := ob_bot
        active_ob_trend := -1

        float buy_ratio = get_window_volume_ratio(pivot_len)
        active_buy_ratio := buy_ratio
        float sell_ratio = 1.0 - buy_ratio
        float split_price = active_bot + (active_top - active_bot) * buy_ratio

        string top_text = "Sell: " + str.tostring(math.round(sell_ratio * 100)) + "%"
        string bot_text = "Buy: " + str.tostring(math.round(buy_ratio * 100)) + "%"

        active_top_box := box.new(left = ob_start_bar, top = active_top, right = bar_index, bottom = split_price, bgcolor = color.new(bear_col, 75), border_color = color.new(bear_col, 40), text = top_text, text_color = txt_col, text_size = size.small, text_valign = text.align_center, text_halign = text.align_right)
        active_bot_box := box.new(left = ob_start_bar, top = split_price, right = bar_index, bottom = active_bot, bgcolor = color.new(bear_col, 85), border_color = color.new(bear_col, 40), text = bot_text, text_color = txt_col, text_size = size.small, text_valign = text.align_center, text_halign = text.align_right)

// Complete invalidation / deletion
if delete_on_break and not na(active_top) and not na(active_bot)
    bool is_broken = (active_ob_trend == 1 and high < active_bot) or (active_ob_trend == -1 and low > active_top)
    if is_broken
        box.delete(active_top_box)
        box.delete(active_bot_box)
        active_top := na
        active_bot := na
        active_ob_trend := 0

// Real-time right extension
if not na(active_top_box) and not na(active_bot_box)
    box.set_right(active_top_box, bar_index)
    box.set_right(active_bot_box, bar_index)

// Retest signals (uses ChoCh-flip directionChange instead of supertrend-flip)
float active_sell_ratio = 1.0 - active_buy_ratio
float bull_threshold    = bull_vol_pct / 100.0
float bear_threshold    = bear_vol_pct / 100.0

bool buy_retest  = ta.crossover(low, active_top) and show_bull_retest and na(pivot_low) and not na(active_top) and (active_buy_ratio >= bull_threshold) and not directionChange and barstate.isconfirmed
bool sell_retest = ta.crossunder(high, active_bot) and na(pivot_high) and show_bear_retest and not na(active_bot) and (active_sell_ratio >= bear_threshold) and not directionChange and barstate.isconfirmed

// }

// ＣＡＬＣ: SUPPORT / RESISTANCE (S/R structure memory) ―――――――――――――――――――――――――――――――――――――――――――――――――――――{

p_high = ta.pivothigh(high, piv_len, piv_len)
p_low  = ta.pivotlow(low, piv_len, piv_len)

var float resistance_level = na
var float support_level    = na

if not na(p_high)
    resistance_level := high[piv_len]
if not na(p_low)
    support_level := low[piv_len]

// }

// ＰＬＯＴ ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// VWAP Plot
plot(show_vwap ? ta.vwap : na, title="VWAP", color=vwap_col, linewidth=2)

// Trend Matrix ATR trailing stop (replaces supertrend as direction indicator)
plot(showStop and not directionChange ? atrTS : na, "ATR Trailing Stop", color = direction ? bullColor : bearColor, style = plot.style_linebr, linewidth = 2)

plot_price = plot(close, display = display.none, editable = false)
plot_stop  = plot(showStop ? atrTS : na, display = display.none, editable = false)
fillCol    = direction ? color.new(bullColor, 70) : color.new(bearColor, 70)
fill(plot_price, plot_stop, close, atrTS, na, showStop ? fillCol : na)

// Order Block retest signals
plotshape(buy_retest, title = "Bullish OB Retest", style = shape.cross, location = location.belowbar, color = bull_sig_col, size = size.tiny)
plotshape(sell_retest, title = "Bearish OB Retest", style = shape.cross, location = location.abovebar, color = bear_sig_col, size = size.tiny)

// Support / Resistance lines (linebr = vertical break at new level, no diagonal lines)
plot(resistance_level, title = "Resistance Line", color = srRes_col, linewidth = 2, style = plot.style_linebr)
plot(support_level, title = "Support Line", color = srSup_col, linewidth = 2, style = plot.style_linebr)

// }
````
