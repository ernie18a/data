# Khajanchi Smart Swing Engine [Auto-Fibs]

- url: https://www.tradingview.com/script/rBzxL3d6-Khajanchi-Smart-Swing-Engine-Auto-Fibs/
- type: indicator
- pine_id: PUB;6a2c31f92f144d1ab711dad8e7b9e824
- version: 12.0

## Description

Overview
The Khajanchi Smart Swing Engine is a universal, trend-filtered trading suite engineered specifically for swing traders. Instead of cluttering your chart with isolated indicators, this engine combines institutional moving averages, volatility-adjusted swing pivots, automated Fibonacci zones, and RSI divergences into a single, clean workspace.

Optimized for the 4H and Daily timeframes, the script is designed to be asset-agnostic—working seamlessly across Indian equities (NSE/BSE), crypto, indices, and commodities by using ATR (Average True Range) to adapt to the asset's unique volatility.

Core Features

Institutional Regime Filter (50 EMA & 200 SMA): The 200 SMA acts as the master trend filter. The engine only looks for bullish setups when the price is above the 200 SMA, and bearish setups when below. The 50 EMA acts as your dynamic support/resistance for high-probability pullback entries.

ATR-Adaptive Auto-Fibs & The Golden Pocket: Stop drawing manual retracements. The script auto-detects structural swing highs and lows, dynamically tightening its lookback during high volatility and expanding during consolidation. It automatically projects Fibonacci retracement zones in the direction of the trend, highlighting the 0.382 (Ideal Retest) in green and coloring the 0.5 to 0.618 "Golden Pocket" in yellow.

Trend-Filtered RSI (7) Divergence: Uses a highly responsive 7-period RSI to spot exhaustion. To prevent false signals, it only plots Bullish Divergences during overall uptrends (buy the dip) and Bearish Divergences during downtrends (sell the rip).

Clean Telemetry HUD: A minimalist top-right dashboard provides instant situational awareness without obscuring price action. It tracks the current Regime Bias (Bullish/Bearish), real-time RSI State (Bull Power >60, Bear Power <40, or Neutral 40-60), the current ATR-adjusted swing lookback, and the 200 SMA baseline.

Built-in Custom Alerts: Features native alert conditions that notify you exactly when an asset pulls back and touches the 50 EMA within an established trend—perfect for setting up limit orders at the Golden Pocket.

How to Trade with this Engine

Identify the Regime: Look at the HUD. Is the Regime Bullish (Price > 200 SMA)? If yes, you are only looking for long positions.

Wait for the Pullback: Let the price retrace into the highlighted yellow "Golden Pocket" (0.500 - 0.618) or touch the 50 EMA.

Confirm the Trigger: Look for a printed Bullish Divergence arrow below the price, or check the HUD to see if the RSI is resetting from Neutral back into "Bull Power" (>60).

Execute: Enter the trade with your stop loss safely below the recent dynamic support line (auto-plotted in grey) or the 0.786 deep value zone.

Best Timeframes: 4H and 1D (Daily)
Asset Classes: Universal (Crypto, Equities, Forex, Commodities)

Script and logic engineered by Khajanchi Wealth.

## Source Code

````pine
//@version=6
indicator('Khajanchi Smart Swing Engine [Auto-Fibs]', shorttitle = 'KW Swing', overlay = true, max_lines_count = 100, max_labels_count = 50)

// =============================================================================
// SETTINGS TAB
// =============================================================================
GRP_MA        = "1. Institutional MAs & Regime Filter"
showMAs       = input.bool(true, "Show 50 EMA / 200 SMA", group = GRP_MA)
lenFast       = input.int(50, "Fast EMA Length", minval = 1, group = GRP_MA)
lenSlow       = input.int(200, "Slow SMA Length", minval = 1, group = GRP_MA)
adxThreshold  = input.int(20, "ADX Sideways/Ranging Threshold", minval = 10, maxval = 40, group = GRP_MA)
colFast       = input.color(color.new(#2962FF, 0), "50 EMA (Deep Blue)", group = GRP_MA)
colSlow       = input.color(color.new(#424242, 0), "200 SMA (Solid Slate)", group = GRP_MA)

GRP_SR        = "2. Dynamic Swing Structure"
showSR        = input.bool(true, "Show Pivots & Boundary Labels", group = GRP_SR)
baseLookback  = input.int(10, "Base Swing Lookback", minval = 3, group = GRP_SR)
colResist     = input.color(color.new(#EF5350, 0), "Swing High Boundary (Red)", group = GRP_SR)
colSupport    = input.color(color.new(#26A69A, 0), "Swing Low Boundary (Teal)", group = GRP_SR)

GRP_FIB       = "3. Fibonacci Zones"
showFib       = input.bool(true, "Enable Fibonacci Zones & Labels", group = GRP_FIB)
colFib382     = input.color(color.new(#455A64, 0), "0.382 Boundary Line", group = GRP_FIB)
colFibPocket  = input.color(color.new(#FFB300, 0), "0.500 - 0.618 Golden Pocket", group = GRP_FIB)
colFib786     = input.color(color.new(#1E88E5, 0), "0.786 Invalidation Line", group = GRP_FIB)

GRP_HUD       = "4. Telemetry Dashboard"
showHUD       = input.bool(true, "Show Signal HUD", group = GRP_HUD)
hudPosInput   = input.string("Top Right", "Signal HUD Position", options = ["Top Right", "Top Left"], group = GRP_HUD)

// =============================================================================
// 1. REGIME DETECTION
// =============================================================================
bool isClosed = barstate.isconfirmed
ema50  = ta.ema(close, lenFast)
sma200 = ta.sma(close, lenSlow)

plot(showMAs ? ema50 : na,  "Fast EMA", color = colFast, linewidth = 2, style = plot.style_line)
plot(showMAs ? sma200 : na, "Slow SMA", color = colSlow, linewidth = 2, style = plot.style_line)

[diPlus, diMinus, adxVal] = ta.dmi(14, 14)
bool isRanging = adxVal < adxThreshold

bool isMacroBullish = not na(sma200) ? close > sma200 : not na(ema50) ? close > ema50 : close > open[20]
bool isMacroBearish = not na(sma200) ? close < sma200 : not na(ema50) ? close < ema50 : close < open[20]

bool isUptrend   = not isRanging and isMacroBullish
bool isDowntrend = not isRanging and isMacroBearish

string regimeText  = isRanging ? "RANGING / CHOP" : isUptrend ? "BULLISH" : "BEARISH"
color  regimeColor = isRanging ? color.new(#FFB300, 0) : isUptrend ? color.new(#00E676, 0) : color.new(#EF5350, 0)

sma200_4h = request.security(syminfo.tickerid, "240", ta.sma(close, 200))
sma200_1d = request.security(syminfo.tickerid, "D", ta.sma(close, 200))
sma200_1w = request.security(syminfo.tickerid, "W", ta.sma(close, 200))
c_4h      = request.security(syminfo.tickerid, "240", close)
c_1d      = request.security(syminfo.tickerid, "D", close)
c_1w      = request.security(syminfo.tickerid, "W", close)

// =============================================================================
// 2. ATR DYNAMIC SWINGS & PULLBACK ISOLATION
// =============================================================================
atr = ta.atr(14)
atrAvg = ta.sma(atr, 50)
volatilityRatio = atrAvg == 0 ? 1 : atr / atrAvg
dynLookback = int(math.max(3, math.min(60, math.round(baseLookback / volatilityRatio))))

volState = atr < (atrAvg * 0.75) ? "SQUEEZE" : atr > (atrAvg * 1.25) ? "EXPANDING" : "NORMAL"

ph = ta.pivothigh(high, dynLookback, dynLookback)
pl = ta.pivotlow(low, dynLookback, dynLookback)

var float last_high = na
var float last_low = na
var int last_high_time = na
var int last_low_time = na

var float pending_low = na
var int pending_low_time = na
var float pending_high = na
var int pending_high_time = na

if not na(ph)
    if isDowntrend and not na(last_low) and time[dynLookback] > last_low_time
        if na(last_high) or ph > last_high
            last_high := ph
            last_high_time := time[dynLookback]
            pending_high := na
        else
            pending_high := ph
            pending_high_time := time[dynLookback]
    else
        if isUptrend and not na(pending_low)
            last_low := pending_low
            last_low_time := pending_low_time
            pending_low := na
            pending_low_time := na
        last_high := ph
        last_high_time := time[dynLookback]

if not na(pl)
    if isUptrend and not na(last_high) and time[dynLookback] > last_high_time
        if na(last_low) or pl < last_low
            last_low := pl
            last_low_time := time[dynLookback]
            pending_low := na
        else
            pending_low := pl
            pending_low_time := time[dynLookback]
    else
        if isDowntrend and not na(pending_high)
            last_high := pending_high
            last_high_time := pending_high_time
            pending_high := na
            pending_high_time := na
        last_low := pl
        last_low_time := time[dynLookback]

float prev_low = last_low
float prev_high = last_high

if isUptrend
    if not na(last_high) and high > last_high
        last_high := high
        last_high_time := time
else if isDowntrend
    if not na(last_low) and low < last_low
        last_low := low
        last_low_time := time
else 
    if not na(last_low) and low < last_low
        last_low := low
        last_low_time := time
    if not na(last_high) and high > last_high
        last_high := high
        last_high_time := time

if not na(last_high) and not na(last_low) and last_low >= last_high
    int offH = math.abs(nz(ta.highestbars(high, 100)))
    int offL = math.abs(nz(ta.lowestbars(low, 100)))
    last_high := high[offH]
    last_high_time := time[offH]
    last_low := low[offL]
    last_low_time := time[offL]
    pending_high := na
    pending_low := na

int lblOffset = time + (time - time[1]) * 2 

if showSR and barstate.islast and not na(last_high) and not na(last_low)
    var line resLine = na
    var line supLine = na
    if na(resLine)
        resLine := line.new(last_high_time, last_high, lblOffset, last_high, xloc=xloc.bar_time, color=colResist, width=2)
    else
        line.set_xy1(resLine, last_high_time, last_high)
        line.set_xy2(resLine, lblOffset, last_high)
        line.set_color(resLine, colResist)
    if na(supLine)
        supLine := line.new(last_low_time, last_low, lblOffset, last_low, xloc=xloc.bar_time, color=colSupport, width=2)
    else
        line.set_xy1(supLine, last_low_time, last_low)
        line.set_xy2(supLine, lblOffset, last_low)
        line.set_color(supLine, colSupport)

var label lbl_high = na
var label lbl_low = na
if showSR and barstate.islast and not na(last_high) and not na(last_low)
    if na(lbl_high)
        lbl_high := label.new(lblOffset, last_high, "High " + str.tostring(last_high, format.mintick), xloc=xloc.bar_time, color=colResist, textcolor=color.white, style=label.style_label_left, size=size.normal)
    else
        label.set_xy(lbl_high, lblOffset, last_high)
        label.set_text(lbl_high, "High " + str.tostring(last_high, format.mintick))
    if na(lbl_low)
        lbl_low := label.new(lblOffset, last_low, "Low " + str.tostring(last_low, format.mintick), xloc=xloc.bar_time, color=colSupport, textcolor=color.white, style=label.style_label_left, size=size.normal)
    else
        label.set_xy(lbl_low, lblOffset, last_low)
        label.set_text(lbl_low, "Low " + str.tostring(last_low, format.mintick))

// =============================================================================
// 3. FIBONACCI ENGINE
// =============================================================================
var line line_382 = na
var line line_500 = na
var line line_618 = na
var line line_786 = na
var linefill fill_pocket = na
var label lbl_382 = na
var label lbl_500 = na
var label lbl_618 = na
var label lbl_786 = na

f_draw_line(ln, x1, x2, y, col) =>
    if na(ln)
        line.new(x1, y, x2, y, xloc=xloc.bar_time, color=col, style=line.style_dotted)
    else
        line.set_xy1(ln, x1, y)
        line.set_xy2(ln, x2, y)
        line.set_color(ln, col)
        ln
f_draw_label(lbl, x, y, txt, txtCol, bgCol) =>
    if na(lbl)
        label.new(x, y, txt, xloc=xloc.bar_time, textcolor=txtCol, color=bgCol, style=label.style_label_left, size=size.normal)
    else
        label.set_xy(lbl, x, y)
        label.set_text(lbl, txt)
        label.set_color(lbl, bgCol)
        lbl

bool isSwingUp = isRanging ? (last_high_time > last_low_time) : isUptrend
float diff = math.abs(last_high - last_low)

float l382 = isSwingUp ? last_high - diff * 0.382 : last_low + diff * 0.382
float l500 = isSwingUp ? last_high - diff * 0.500 : last_low + diff * 0.500
float l618 = isSwingUp ? last_high - diff * 0.618 : last_low + diff * 0.618
float l786 = isSwingUp ? last_high - diff * 0.786 : last_low + diff * 0.786

if showFib and barstate.islast and not na(last_high) and not na(last_low)
    int startTime = math.min(last_high_time, last_low_time)
    line_382 := f_draw_line(line_382, startTime, lblOffset, l382, color.new(colFib382, 30))
    line_500 := f_draw_line(line_500, startTime, lblOffset, l500, colFibPocket)
    line_618 := f_draw_line(line_618, startTime, lblOffset, l618, colFibPocket)
    line_786 := f_draw_line(line_786, startTime, lblOffset, l786, colFib786)
    lbl_382 := f_draw_label(lbl_382, lblOffset, l382, "0.382 [Minimum Retest] " + str.tostring(l382, format.mintick), color.white, colFib382)
    lbl_500 := f_draw_label(lbl_500, lblOffset, l500, "0.500 [Equilibrium] " + str.tostring(l500, format.mintick), color.white, colFibPocket)
    lbl_618 := f_draw_label(lbl_618, lblOffset, l618, "0.618 [Golden Ratio] " + str.tostring(l618, format.mintick), color.white, colFibPocket)
    lbl_786 := f_draw_label(lbl_786, lblOffset, l786, "0.786 [Deep Value] " + str.tostring(l786, format.mintick), color.white, colFib786)
    if na(fill_pocket)
        fill_pocket := linefill.new(line_500, line_618, color.new(colFibPocket, 85))
    else
        linefill.set_color(fill_pocket, color.new(colFibPocket, 85))

// =============================================================================
// 4. MICRO-TO-MACRO TRIGGER SYSTEM
// =============================================================================
float gpTop = math.max(l500, l618)
float gpBot = math.min(l500, l618)
[c4_vol, c4_volMa, c4_low, c4_high, c4_close] = request.security(syminfo.tickerid, "240", [volume, ta.sma(volume, 20), low, high, close])
bool inPocket_4h   = (c4_low <= gpTop and c4_high >= gpBot)
bool stealthVol_4h = inPocket_4h and (c4_vol > (c4_volMa * 1.5))
bool longSweep_4h  = not na(prev_low) and c4_low < prev_low and c4_close > prev_low
bool shortSweep_4h = not na(prev_high) and c4_high > prev_high and c4_close < prev_high

bool inPocket = (low <= gpTop and high >= gpBot)
volMa = ta.sma(volume, 20)
bool stealthVol = inPocket and (volume > (volMa * 1.5))
barcolor(stealthVol and isClosed ? color.new(#FFEB3B, 0) : na)

bool longSweep = not na(prev_low) and low < prev_low and close > prev_low and isClosed
bool shortSweep = not na(prev_high) and high > prev_high and close < prev_high and isClosed
plotshape(longSweep and not isRanging and close > sma200, "Bullish Liquidity Sweep", style=shape.xcross, location=location.belowbar, color=color.new(#2962FF,0), size=size.tiny)
plotshape(shortSweep and not isRanging and close < sma200, "Bearish Liquidity Sweep", style=shape.xcross, location=location.abovebar, color=color.new(#2962FF,0), size=size.tiny)

// =============================================================================
// 5. TELEMETRY SIGNAL HUD (FREE VERSION)
// =============================================================================
hudPos = hudPosInput == "Top Left" ? position.top_left : position.top_right
var table hud = table.new(hudPos, 2, 13, bgcolor = color.new(#121826, 5), border_width = 1, border_color = color.new(#2A374A, 0))

float liveRisk = math.abs(close - l786)
float target1Val = isSwingUp ? last_high : last_low
float target2Val = isSwingUp ? last_high + (diff * 0.618) : last_low - (diff * 0.618)

float liveReward1 = math.abs(target1Val - close)
float liveReward2 = math.abs(target2Val - close)
float rr1 = liveRisk > 0 ? liveReward1 / liveRisk : 0
float rr2 = liveRisk > 0 ? liveReward2 / liveRisk : 0

color rrColor1 = rr1 >= 1.5 ? color.new(#00E676, 0) : color.new(#9E9E9E, 0)
color rrColor2 = rr2 >= 2.0 ? color.new(#00B0FF, 0) : color.new(#9E9E9E, 0)

bool chk_trend   = not isRanging and ((isSwingUp and c_1d > sma200_1d) or (not isSwingUp and c_1d < sma200_1d))
bool chk_zone    = inPocket_4h
bool trap_hit    = stealthVol_4h or longSweep_4h or shortSweep_4h
bool chk_conf    = ta.barssince(trap_hit) <= 1
bool chk_rr      = rr1 >= 1.5
bool chk_sl_safe = liveRisk >= atr
bool all_clear   = chk_trend and chk_zone and chk_conf and chk_rr 

bool alertTrigger = all_clear and not all_clear[1]
string directionText = isSwingUp ? "LONG" : "SHORT"
alertcondition(alertTrigger, title = "Khajanchi Trade Ready Alert", message = "KHAJANCHI SETUP: {{ticker}} is READY FOR EXECUTION!\nDirection: Check Chart\nCurrent Price: {{close}}")
if alertTrigger
    alert("KHAJANCHI SETUP: " + syminfo.ticker + " (" + directionText + ") is READY FOR EXECUTION at " + str.tostring(close, format.mintick) + " | SL: " + str.tostring(l786, format.mintick) + " | TP1: " + str.tostring(target1Val, format.mintick), alert.freq_once_per_bar_close)

if showHUD and barstate.islast
    string str1d = na(sma200_1d) ? "⚪" : c_1d > sma200_1d ? "🟢" : "🔴"
    string str1w = na(sma200_1w) ? "⚪" : c_1w > sma200_1w ? "🟢" : "🔴"
    string mtfRow = (na(sma200_4h) ? "⚪" : c_4h > sma200_4h ? "🟢" : "🔴") + " 4H | " + str1d + " 1D | " + str1w + " 1W"
    
    table.cell(hud, 0, 0, "MTF Trend Bias", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 0, mtfRow, text_color=color.white, text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 1, "Regime Bias", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 1, regimeText, text_color=regimeColor, text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 2, "Swing Lookback (Vol)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 2, str.tostring(dynLookback) + " Bars | " + volState, text_color=color.new(#9E9E9E,0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(hud, 0, 3, "Target 1 (Base Swing)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 3, str.tostring(target1Val, format.mintick), text_color=color.new(#FFD700, 0), text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 4, "Target 2 (1.618 Ext)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 4, str.tostring(target2Val, format.mintick), text_color=color.new(#FFD700, 0), text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 5, "Live R:R (TP1 | TP2)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 5, "1:" + str.tostring(rr1, "#.1") + " | 1:" + str.tostring(rr2, "#.1"), text_color=rrColor1, text_size=size.small, text_halign=text.align_right)
    
    table.cell(hud, 0, 6, "--- SYSTEM CHECKLIST ---", text_color=color.new(#9E9E9E,0), text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 6, "-----------", text_color=color.new(#9E9E9E,0), text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 7, "1. Macro Alignment", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 7, isRanging ? "🟡 Ranging" : chk_trend ? "🟢 Valid" : "⚪ Wait", text_color=isRanging ? color.new(#FFB300, 0) : chk_trend ? color.new(#00E676,0) : color.new(#9E9E9E,0), text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 8, "2. Price In Pocket", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 8, chk_zone ? "🟢 Active" : "⚪ Wait", text_color=chk_zone ? color.new(#00E676,0) : color.new(#9E9E9E,0), text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 9, "3. 4H Trap Confirmed", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 9, chk_conf ? "🟢 4H Sweep/Vol" : "⚪ Wait", text_color=chk_conf ? color.new(#00E676,0) : color.new(#9E9E9E,0), text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 10, "4. SL ATR Safety (Warning)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 10, chk_sl_safe ? "🟢 Safe (>1 ATR)" : "🔴 Too Tight", text_color=chk_sl_safe ? color.new(#00E676,0) : color.new(#EF5350,0), text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 11, "TRADE STATUS", text_color=color.white, text_size=size.small, text_halign=text.align_left, bgcolor=all_clear ? color.new(#00C853, 70) : na)
    table.cell(hud, 1, 11, isRanging ? "CHOP FILTERED" : all_clear ? "READY / EXECUTE" : "WAITING", text_color=all_clear ? color.white : color.new(#9E9E9E,0), text_size=size.small, text_halign=text.align_right, bgcolor=all_clear ? color.new(#00C853, 70) : na)
````
