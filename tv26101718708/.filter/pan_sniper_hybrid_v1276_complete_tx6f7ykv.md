# Pan Sniper Hybrid V12.7.6 Complete

- url: https://www.tradingview.com/script/tX6f7YKv-Pan-Sniper-Hybrid-V12-7-6-Complete/
- type: indicator
- pine_id: PUB;523d1414e8424a00aa0f568c10503d00
- version: 4.0

## Description

Title: Pan Sniper Hybrid V12.8 - Multi-Strategy SMC & Volumetric Signals
Description:
Pan Sniper Hybrid V12.8 is a comprehensive trading tool designed for professional scalpers and day traders. It combines Market Structure Analysis (SMC), Volumetric Delta Analysis, and FX Market Sessions into a single, high-performance indicator.

This script is optimized for lower timeframes (1m, 5m, 15m) to identify high-probability reversal and trend-following setups.

Key Features:
Automatic Market Structure: Real-time labeling of HH, HL, LL, LH to help you identify trend shifts and institutional order flow.

Volumetric Delta Signals: Includes Bull (🐂) and Bear (🐻) signals based on real-time Volume Delta calculations from lower timeframe data.

Shark SFP (Swing Failure Pattern): The Shark (🦈) signal identifies liquidity sweeps at key structural highs and lows—perfect for catching sharp reversals.

AMD Session Boxes: Automatically plots Asia, London, and New York sessions with visual boxes (Accumulation, Manipulation, Distribution) to help you trade session highs and lows.

Dynamic Fibo Zones: Features upper and lower Fibonacci-based bands to identify overextended price levels (Overbought/Oversold).

Gaussian Trend Filter: A smooth trend-following baseline that changes color based on market momentum.

How to use:
For Scalping (1m/5m): Increase the Shark % and Pivot Lookback in settings to filter out minor price noise.

Trend Confirmation: Look for Bull/Bear signals that align with the Gaussian Filter color.

Session Trading: Use the Opening Range (Yellow/Pink lines) as a breakout or mean-reversion boundary during major market opens.

Settings Highlights:
Signal Sensitivity: Fully customizable thresholds for Bull, Bear, and Shark signals to match your risk appetite.

MACD Customization: Adjustable Fast/Slow lengths to fine-tune signal entry timing.

Disclaimer: This indicator is for educational and analytical purposes only. It does not constitute financial advice. Past performance does not guarantee future results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gemini_Syntrade_Collab | Pan Sniper Hybrid V12.7.6 (100% Fixed & Restored Dashboard)
//@version=6
indicator("Pan Sniper Hybrid V12.7.6 Complete", overlay=true, max_labels_count=500, max_boxes_count=500)

// ==========================================
// 1) [INPUTS] - ตั้งค่าฟังก์ชันระบบหลัก
// ==========================================
group_struct = "Market Structure (HH, HL, LL, LH)"
lbL = input.int(5, "Pivot Left (ความกว้างซ้าย)", minval=1, group=group_struct)
lbR = input.int(5, "Pivot Right (ความกว้างขวา)", minval=1, group=group_struct)

group_fibo = "Fibo Bands Settings (แถบสีเขียว-แดง)"
lb_p = input.int(30, "Fibo Lookback Period", minval=5, group=group_fibo)
f_mult = input.float(0.1, "Fibo Band Multiplier", step=0.01, group=group_fibo)

group_macd = "MACD Settings (ปรับค่า วัว-หมี)"
fast_len = input.int(12, "Fast EMA Length", group=group_macd)
slow_len = input.int(26, "Slow EMA Length", group=group_macd)
sig_len  = input.int(9,  "Signal Smoothing", group=group_macd)

group_sig = "Signal Sensitivity (ปรับค่า วัว หมี ฉลาม)"
bull_thresh = input.float(0.6, "Bull Signal % (วัว) >", minval=0.5, maxval=1.0, step=0.01, group=group_sig)
bear_thresh = input.float(0.4, "Bear Signal % (หมี) <", minval=0.0, maxval=0.5, step=0.01, group=group_sig)
shark_bull   = input.float(0.6, "Shark Bull % >", minval=0.5, maxval=1.0, step=0.01, group=group_sig)
shark_bear   = input.float(0.4, "Shark Bear % <", minval=0.0, maxval=0.5, step=0.01, group=group_sig)

group_or = "Opening Range Settings (เส้นเหลือง-ชมพู)"
or_len   = input.int(3, "OR Candle Count", minval=1, group=group_or)

group_sess = "FX Market Sessions & AMD (กล่อง)"
s1_t = input.session("0600-1400", "Asia", group=group_sess)
s2_t = input.session("1400-1930", "London", group=group_sess)
s3_t = input.session("1930-0000", "NY", group=group_sess)
show_boxes = input.bool(true, "Show Session Boxes", group=group_sess)

group_gauss = "Trend Filter Settings"
g_len = input.int(200, "Gaussian Length", group=group_gauss)

group_obfvg = "OB & FVG Target Zone Settings"
obTarget_length      = input.int(5, title="Swing Length for MSB", group=group_obfvg)
obTarget_showVisuals = input.bool(true, title="Show OB/FVG Dynamic Boxes", group=group_obfvg)


// ==========================================
// 2) Core Logic: Structure & Fibo
// ==========================================
hi_lb = ta.highest(high, lb_p), lo_lb = ta.lowest(low, lb_p), r_lb = hi_lb - lo_lb
p_t1 = plot(hi_lb, "Fibo Top 1", color=color.new(color.red, 60))
p_t2 = plot(hi_lb + (r_lb * f_mult), "Fibo Top 2", color=color.new(color.red, 60))
fill(p_t1, p_t2, color.new(color.red, 90))
p_b1 = plot(lo_lb, "Fibo Bottom 1", color=color.new(color.green, 60))
p_b2 = plot(lo_lb - (r_lb * f_mult), "Fibo Bottom 2", color=color.new(color.green, 60))
fill(p_b1, p_b2, color.new(color.green, 90))

ph = ta.pivothigh(high, lbL, lbR)
pl = ta.pivotlow(low, lbL, lbR)
var float last_ph = na
var float last_pl = na

string current_struct_state = "CHOCH/HOLD"

if not na(ph)
    label_text = ph > nz(last_ph) ? "HH" : "LH"
    label_color = ph > nz(last_ph) ? color.green : color.red
    label.new(bar_index[lbR], ph, label_text, color=color.new(label_color, 100), textcolor=label_color, style=label.style_label_down, size=size.tiny)
    last_ph := ph
    if ph < nz(last_ph)
        current_struct_state := "BOS BEAR"

if not na(pl)
    label_text = pl < nz(last_pl) ? "LL" : "HL"
    label_color = pl < nz(last_pl) ? color.red : color.green
    label.new(bar_index[lbR], pl, label_text, color=color.new(label_color, 100), textcolor=label_color, style=label.style_label_up, size=size.tiny)
    last_pl := pl
    if pl > nz(last_pl)
        current_struct_state := "BOS BULL"

// ==========================================
// 3) Core Logic: Volume, Gaussian, Teeth
// ==========================================
f_vol_delta() =>
    arr_bull = request.security_lower_tf(syminfo.tickerid, "1", close > open ? volume : 0.0)
    total_v  = request.security_lower_tf(syminfo.tickerid, "1", volume)
    float b_sum = 0.0, float t_sum = 0.0
    if array.size(arr_bull) > 0
        for i = 0 to array.size(arr_bull) - 1
            b_sum += array.get(arr_bull, i), t_sum += array.get(total_v, i)
    [t_sum > 0 ? b_sum / t_sum : 0.5]
[bullPct] = f_vol_delta()

g_ma = ta.ema(close, g_len)
plot(g_ma, "Gaussian Filter", color=g_ma > g_ma[1] ? color.green : color.red, linewidth=3)

smaTeeth = ta.sma(hl2, 8)
var float smma = na
smma := na(smma[1]) ? smaTeeth : (smma[1] * 7 + hl2) / 8
plot(smma, "Teeth Line", color=#2196F3, linewidth=2, offset=5)

// ==========================================
// 4) Opening Range & Signals
// ==========================================
f_get_or(in_sess, length) =>
    var float h = na, var float l = na, var int count = 0
    if in_sess and not in_sess[1]
        h := high, l := low, count := 1
    else if in_sess and count < length
        h := math.max(h, high), l := math.min(l, low), count := count + 1
    [h, l]

f_sess(t) => not na(time(timeframe.period, t, "Asia/Bangkok"))
in1 = f_sess(s1_t), in2 = f_sess(s2_t), in3 = f_sess(s3_t)
[h1, l1] = f_get_or(in1, or_len), [h2, l2] = f_get_or(in2, or_len), [h3, l3] = f_get_or(in3, or_len)

plot(in1 ? h1 : na, "S1H", color=color.yellow, style=plot.style_linebr, linewidth=2)
plot(in1 ? l1 : na, "S1L", color=#FF00FF, style=plot.style_linebr, linewidth=2)
plot(in2 ? h2 : na, "S2H", color=color.yellow, style=plot.style_linebr, linewidth=2)
plot(in2 ? l2 : na, "S2L", color=#FF00FF, style=plot.style_linebr, linewidth=2)
plot(in3 ? h3 : na, "S3H", color=color.yellow, style=plot.style_linebr, linewidth=2)
plot(in3 ? l3 : na, "S3L", color=#FF00FF, style=plot.style_linebr, linewidth=2)

is_new_day = ta.change(time("D", "Asia/Bangkok")) != 0
var float or_p = na
if is_new_day
    or_p := open
plot(or_p, "Opening Price", color=color.new(color.white, 30), style=plot.style_linebr, linewidth=2)

[mLine, sLine, _] = ta.macd(close, fast_len, slow_len, sig_len)

bull_sig = ta.crossover(mLine, sLine) and close > g_ma and bullPct > bull_thresh
bear_sig = ta.crossunder(mLine, sLine) and close < g_ma and bullPct < bear_thresh
plotshape(bull_sig, "Bull", shape.labelup, location.belowbar, color.green, text="🐂", size=size.small)
plotshape(bear_sig, "Bear", shape.labeldown, location.abovebar, color.red, text="🐻", size=size.small)

sfp_bear = high > last_ph and close < last_ph and bullPct < shark_bear
sfp_bull = low < last_pl and close > last_pl and bullPct > shark_bull
plotshape(sfp_bear, "Shark Bear", shape.labeldown, location.abovebar, color.orange, text="🦈", size=size.small)
plotshape(sfp_bull, "Shark Bull", shape.labelup, location.belowbar, color.orange, text="🦈", size=size.small)

// ==========================================
// 5) AMD Boxes
// ==========================================
var box b1 = na, var box b2 = na, var box b3 = na
if show_boxes
    if in1
        if not in1[1]
            b1 := box.new(bar_index, high, bar_index, low, bgcolor=color.new(#FFEB3B, 92), border_color=color.new(#FFEB3B, 60), border_style=line.style_dotted)
        else
            box.set_right(b1, bar_index), box.set_top(b1, math.max(box.get_top(b1), high)), box.set_bottom(b1, math.min(box.get_bottom(b1), low))
    if in2
        if not in2[1]
            b2 := box.new(bar_index, high, bar_index, low, bgcolor=color.new(#9E9E9E, 92), border_color=color.new(#9E9E9E, 60), border_style=line.style_dotted)
        else
            box.set_right(b2, bar_index), box.set_top(b2, math.max(box.get_top(b2), high)), box.set_bottom(b2, math.min(box.get_bottom(b2), low))
    if in3
        if not in3[1]
            b3 := box.new(bar_index, high, bar_index, low, bgcolor=color.new(#F44336, 92), border_color=color.new(#F44336, 60), border_style=line.style_dotted)
        else
            box.set_right(b3, bar_index), box.set_top(b3, math.max(box.get_top(b3), high)), box.set_bottom(b3, math.min(box.get_bottom(b3), low))

barcolor(bullPct > bull_thresh ? color.lime : bullPct < bear_thresh ? color.red : color.gray)


// ==========================================
// 6) BOX THEORY + DRS REVERSAL SYSTEM
// ==========================================
var string G_COMBINED = "Box + DRS System Settings"
showVisuals  = input.bool(true, "Show Box & DRS Lines", group=G_COMBINED)
boxColor     = input.color(#9c27b0, "Daily Box Color", group=G_COMBINED)
drsColor     = input.color(#ff9800, "DRS Target Color", group=G_COMBINED)
visualOffset = input.int(20, "Visual Offset (Bars)", group=G_COMBINED)
displayWidth = input.int(30, "Display Width", group=G_COMBINED)
volLength    = input.int(20, "Volume Average Length", group=G_COMBINED)
volMult      = input.float(2.0, "Volume Multiplier", group=G_COMBINED)
cooldownBars = input.int(3, "Signal Cooldown (Bars)", group=G_COMBINED)

pdh   = request.security(syminfo.tickerid, "D", high[1])
pdl   = request.security(syminfo.tickerid, "D", low[1])
dOpen = request.security(syminfo.tickerid, "D", open)
mid   = (pdh + pdl) / 2
adrValue = request.security(syminfo.tickerid, "D", ta.sma(high - low, 5)[1])
projHigh = dOpen + adrValue
projLow  = dOpen - adrValue

var box  dailyBox = na
var line midLine  = na
var line drsHigh  = na
var line drsLow   = na

if showVisuals and barstate.islast
    box.delete(dailyBox), line.delete(midLine), line.delete(drsHigh), line.delete(drsLow)
    float todayHigh = request.security(syminfo.tickerid, "D", high)
    float todayLow  = request.security(syminfo.tickerid, "D", low)
    float todayMid  = (todayHigh + todayLow) / 2
    float validPdh  = na(pdh) ? todayHigh : pdh
    float validPdl  = na(pdl) ? todayLow : pdl
    float validMid  = na(mid) ? todayMid : mid

    int b1_left  = bar_index + visualOffset
    int b1_right = b1_left + displayWidth
    int b2_left  = b1_right
    int b2_right = b2_left + displayWidth

    dailyBox := box.new(left=b1_left, top=validPdh, right=b1_right, bottom=validPdl, border_color=boxColor, bgcolor=color.new(boxColor, 96), text="Yesterday", text_size=size.small, text_color=boxColor)
    var box todayBox = box.new(left=b2_left, top=todayHigh, right=b2_right, bottom=todayLow, border_color=boxColor, bgcolor=color.new(boxColor, 96), text="Today", text_size=size.small, text_color=boxColor)
    box.delete(todayBox[1])

    drsHigh := line.new(x1=b1_left, y1=projHigh, x2=b2_right, y2=projHigh, color=drsColor, width=2)
    drsLow  := line.new(x1=b1_left, y1=projLow,  x2=b2_right, y2=projLow,  color=drsColor, width=2)
    midLine := line.new(x1=b1_left, y1=validMid, x2=b1_right, y2=validMid, color=boxColor, style=line.style_dashed)
    var line todayMidLine = line.new(x1=b2_left, y1=todayMid, x2=b2_right, y2=todayMid, color=boxColor, style=line.style_dashed)
    line.delete(todayMidLine[1])

avgVol    = ta.sma(volume, volLength)
volFilter = volume > (avgVol * volMult)
isHammer        = (math.min(open, close) - low) > (ta.tr * 0.5) and (high - math.max(open, close)) < (ta.tr * 0.2)
isEngulfing     = close > open[1] and open < close[1] and (close - open) > (ta.tr * 0.3)
isShootingStar  = (high - math.max(open, close)) > (ta.tr * 0.5) and (math.min(open, close) - low) < (ta.tr * 0.2)
isBearEngulfing = close < open[1] and open > close[1] and (open - close) > (ta.tr * 0.3)

inBullZone  = (low <= pdl + (ta.tr * 0.5)) or (low <= projLow)
inBearZone  = (high >= pdh - (ta.tr * 0.5)) or (high >= projHigh)
comboBuy  = inBullZone and (isHammer or isEngulfing) and volFilter
comboSell = inBearZone and (isShootingStar or isBearEngulfing) and volFilter

var int lastSignalBar = 0
canTrigger = (bar_index - lastSignalBar) > cooldownBars
finalBuy  = comboBuy and canTrigger
finalSell = comboSell and canTrigger
if finalBuy or finalSell
    lastSignalBar := bar_index

plotshape(finalBuy,  title="Box Buy Tiny",  style=shape.diamond, location=location.belowbar, color=#00b0ff, size=size.tiny)
plotshape(finalSell, title="Box Sell Tiny", style=shape.diamond, location=location.abovebar, color=#ff1744, size=size.tiny)


// ==========================================
// 7) SMT DIVERGENCE SYSTEM
// ==========================================
smt_enable_draw   = true
smt_lb            = 3
smt_h   = request.security("BINANCE:BTCUSDT.P", timeframe.period, high)
smt_l   = request.security("BINANCE:BTCUSDT.P", timeframe.period, low)
p_high  = ta.pivothigh(high, smt_lb, smt_lb)
p_low   = ta.pivotlow(low, smt_lb, smt_lb)
smt_ph  = ta.pivothigh(smt_h, smt_lb, smt_lb)
smt_pl  = ta.pivotlow(smt_l, smt_lb, smt_lb)

var float last_main_high = na, var float last_main_low  = na
var float last_smt_high  = na, var float last_smt_low  = na
var line  smt_bull_line  = na, var label smt_bull_label = na
var line  smt_bear_line  = na, var label smt_bear_label = na
var int bars_since_low  = 0
var int bars_since_high = 0

bars_since_low  := bars_since_low + 1
bars_since_high := bars_since_high + 1

string current_sweep_state = "SWEEP LOW (SHARK)"

if not na(p_low) and not na(smt_pl)
    if not na(last_main_low) and not na(last_smt_low)
        if p_low < last_main_low and smt_pl > last_smt_low and smt_enable_draw
            if not na(smt_bull_line)
                line.delete(smt_bull_line)
            if not na(smt_bull_label)
                label.delete(smt_bull_label)
            smt_bull_line := line.new(x1=bar_index - smt_lb, y1=p_low, x2=bar_index, y2=p_low, style=line.style_dashed, color=color.green, width=2)
            smt_bull_label := label.new(x=bar_index, y=p_low, text="Bullish SMT", color=color.new(color.green, 100), textcolor=color.green, style=label.style_label_up, size=size.normal)
            bars_since_low := 0
            current_sweep_state := "SMT BULLISH"
    last_main_low := p_low
    last_smt_low  := smt_pl

if not na(p_high) and not na(smt_ph)
    if not na(last_main_high) and not na(last_smt_high)
        if p_high > last_main_high and smt_ph < last_smt_high and smt_enable_draw
            if not na(smt_bear_line)
                line.delete(smt_bear_line)
            if not na(smt_bear_label)
                label.delete(smt_bear_label)
            smt_bear_line := line.new(x1=bar_index - smt_lb, y1=p_high, x2=bar_index, y2=p_high, style=line.style_dashed, color=color.red, width=2)
            smt_bear_label := label.new(x=bar_index, y=p_high, text="Bearish SMT", color=color.new(color.red, 100), textcolor=color.red, style=label.style_label_down, size=size.normal)
            bars_since_high := 0
            current_sweep_state := "SMT BEARISH"
    last_main_high := p_high
    last_smt_high  := smt_ph

if not na(smt_bull_line) and bars_since_low < 50
    line.set_x2(smt_bull_line, bar_index)
    label.set_x(smt_bull_label, bar_index)
if not na(smt_bear_line) and bars_since_high < 50
    line.set_x2(smt_bear_line, bar_index)
    label.set_x(smt_bear_label, bar_index)


// ==========================================
// 8) OB & FVG TARGET ZONE STRATEGY MODULE
// ==========================================
var float obTarget_swingHigh = na
var float obTarget_swingLow  = na

if ta.crossover(high, ta.highest(high[1], obTarget_length))
    obTarget_swingHigh := high
if ta.crossunder(low, ta.lowest(low[1], obTarget_length))
    obTarget_swingLow := low

bool obTarget_msbBullish = ta.crossover(close, obTarget_swingHigh[1])
bool obTarget_msbBearish = ta.crossunder(close, obTarget_swingLow[1])

bool main_isBullishFVG = low > high[2] and close[1] > high[2]
bool main_isBearishFVG = high < low[2] and close[1] < low[2]

var box dynamic_fvgBox = na

if obTarget_showVisuals
    if main_isBullishFVG
        box.delete(dynamic_fvgBox)
        dynamic_fvgBox := box.new(left=bar_index[2], top=low, right=bar_index, bottom=high[2], bgcolor=color.new(color.green, 90), border_color=color.new(color.green, 50), text="Bullish FVG", text_size=size.small, text_color=color.green)
    else if main_isBearishFVG
        box.delete(dynamic_fvgBox)
        dynamic_fvgBox := box.new(left=bar_index[2], top=low[2], right=bar_index, bottom=high, bgcolor=color.new(color.red, 90), border_color=color.new(color.red, 50), text="Bearish FVG", text_size=size.small, text_color=color.red)

if not na(dynamic_fvgBox)
    box.set_right(dynamic_fvgBox, bar_index)

var float tracker_obTop = na
var float tracker_obBot = na
var box dynamic_obBox = na

if obTarget_msbBearish[1] or main_isBearishFVG[1]
    tracker_obTop := high[2]
    tracker_obBot := low[2]
    if obTarget_showVisuals
        box.delete(dynamic_obBox)
        dynamic_obBox := box.new(left=bar_index[2], top=tracker_obTop, right=bar_index, bottom=tracker_obBot, bgcolor=color.new(color.orange, 85), border_color=color.new(color.orange, 40), text="Bearish OB Target", text_size=size.small, text_color=color.orange)

if ta.crossover(high, tracker_obTop)
    tracker_obTop := na
    tracker_obBot := na
    box.delete(dynamic_obBox)

if not na(dynamic_obBox) and not na(tracker_obTop)
    box.set_right(dynamic_obBox, bar_index)

float ref_fvgTop = main_isBearishFVG ? low[2] : na
var float last_fvgTop = na
if main_isBearishFVG
    last_fvgTop := ref_fvgTop

bool confirm_ifvg = ta.crossover(close, last_fvgTop)
bool final_obBuySignal = (obTarget_msbBullish or confirm_ifvg) and not na(tracker_obTop)

plotshape(final_obBuySignal, title="OB Target: Buy Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)


// ==========================================
// 9) FIXED: DASHBOARD DATA DISPLAY TABLE (v6 COMPATIBLE)
// ==========================================
var table main_dash = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 20), border_color=color.gray, border_width=1)

if barstate.islast
    // บรรทัดหัวข้อ Dashboard
    table.cell(main_dash, 0, 0, "DASHBOARD INDICATORS", bgcolor=color.gray, text_color=color.white, text_size=size.small)
    table.cell(main_dash, 1, 0, "STATUS VALUE", bgcolor=color.gray, text_color=color.white, text_size=size.small)
    
    // 1. BIAS
    string bias_txt = close > g_ma ? "NEUTRAL / BULL" : "NEUTRAL"
    color bias_col = close > g_ma ? color.green : color.gray
    table.cell(main_dash, 0, 1, "1. BIAS", text_color=color.white, text_size=size.small)
    table.cell(main_dash, 1, 1, bias_txt, bgcolor=color.new(bias_col, 70), text_color=bias_col, text_size=size.small)
    
    // 2. OPEN DIST
    float op_dist_val = dOpen > 0 ? ((close - dOpen) / dOpen) * 100 : 0.0
    string op_dist_txt = str.tostring(op_dist_val, "#.##") + "%"
    color op_dist_col = op_dist_val >= 0 ? color.teal : color.maroon
    table.cell(main_dash, 0, 2, "2. OPEN DIST", text_color=color.white, text_size=size.small)
    table.cell(main_dash, 1, 2, op_dist_txt, bgcolor=color.new(op_dist_col, 70), text_color=op_dist_col, text_size=size.small)
    
    // 3. GAUSSIAN
    string gauss_txt = close > g_ma ? "BULL" : "BEAR"
    color gauss_col = close > g_ma ? color.green : color.red
    table.cell(main_dash, 0, 3, "3. GAUSSIAN", text_color=color.white, text_size=size.small)
    table.cell(main_dash, 1, 3, gauss_txt, bgcolor=color.new(gauss_col, 70), text_color=gauss_col, text_size=size.small)
    
    // 4. TEETH LINE
    string teeth_txt = close < smma ? "BELOW" : "ABOVE"
    color teeth_col = close < smma ? color.red : color.green
    table.cell(main_dash, 0, 4, "4. TEETH LINE", text_color=color.white, text_size=size.small)
    table.cell(main_dash, 1, 4, teeth_txt, bgcolor=color.new(teeth_col, 70), text_color=teeth_col, text_size=size.small)
    
    // 5. STRUCTURE
    table.cell(main_dash, 0, 5, "5. STRUCTURE", text_color=color.white, text_size=size.small)
    table.cell(main_dash, 1, 5, current_struct_state, bgcolor=color.new(color.orange, 70), text_color=color.orange, text_size=size.small)
    
    // 6. SWEEP STAT
    table.cell(main_dash, 0, 6, "6. SWEEP STAT", text_color=color.white, text_size=size.small)
    table.cell(main_dash, 1, 6, current_sweep_state, bgcolor=color.new(color.teal, 70), text_color=color.teal, text_size=size.small)
````
