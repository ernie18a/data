# Sniper Trader V6.5 Pro SMC, FVGs & Volume Sweep Engine

- url: https://www.tradingview.com/script/AD90vyED-Sniper-Trader-V6-5-Pro-SMC-FVGs-Volume-Sweep-Engine/
- type: indicator
- pine_id: PUB;6deb2fb5a18647e188d144633aafc642
- version: 25.0

## Description

[b]Sniper Trader Pro[/b] is an all-in-one Smart Money Concepts (SMC) indicator designed to filter out market noise and identify high-probability institutional setups. Built for precision, this algorithm detects liquidity sweeps, Fair Value Gaps (FVGs), and volume-backed rejections, giving you a clear visual map of where the "Smart Money" is trapping retail traders.

Optimized for volatile assets like indices (NASDAQ/NQ, S&P500) on the 5-minute timeframe, this tool acts as a complete trading system.

Core Features

Dynamic Liquidity Boxes (FVGs): Automatically plots Demand (Aqua) and Supply (Red) zones based on momentum. The algorithm features a smart "garbage collector" that instantly deletes boxes once they are fully mitigated by price, keeping your chart perfectly clean.

Institutional Trend Filters: Integrates key dynamic support/resistance levels, including the 14 EMA, 80 HMA, 200 EMA, and the daily VWAP, allowing you to gauge the macro and micro trends at a glance.

Volume-Backed Sweep Signals: The indicator doesn't just look for wicks; it analyzes the relationship between wick size, body size, and relative volume. It plots clear "LONG" and "SHORT" triangles only when a rejection wick touches a key dynamic level (EMA/VWAP) and is backed by above-average volume.

Ultimate Sensitivity Engine: Fully customizable settings. You can adjust the required wick size, maximum opposite wick size, and volume multiplier to adapt the trigger sensitivity to the current market volatility.

How to Trade with Gems Sniper Trader Pro
This indicator is built to trade pullbacks into liquidity zones in the direction of the macro trend.

For a LONG Setup:

Ensure the price is trading above the 200 EMA (Macro Trend).

Wait for the price to pull back and enter an Aqua Demand Box.

Look for a green LONG triangle signal. This confirms a liquidity sweep bouncing off the 14 EMA, 80 HMA, or VWAP with institutional volume.

Place your Stop Loss safely below the sweep wick.

For a SHORT Setup:

Ensure the price is trading below the 200 EMA.

Wait for a fake breakout into a Red Supply Box.

Look for a red SHORT triangle rejecting the zone with volume.

Place your Stop Loss above the rejection wick.

[b]Pro Tip[/b]:
Avoid taking signals that float in the middle of nowhere. The highest probability trades occur when the sweep signal perfectly aligns (confluence) with a Liquidity Box and a dynamic level like the VWAP.

## Source Code

````pine
//@version=6
indicator('Sniper Trader V10.7 Pro SMC/CVD Edition', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ==========================================
// --- ENUMS & CUSTOM TYPES ---
// ==========================================
enum LineStyle
    Solid
    Dashed
    Dotted

enum TextSize
    Tiny
    Small
    Normal
    Large
    Huge

enum PanelPosition
    TopRight
    TopLeft
    BottomRight
    BottomLeft
    MiddleRight
    MiddleLeft

enum PanelLayout
    PC_Expanded
    Mobile_Compact

enum MAType
    SMA
    EMA
    HMA

enum TimeZoneEnum
    NY
    Chicago
    Denver
    LA
    London
    Madrid
    Tokyo
    Dubai
    Sydney
    UTC

type DivZone
    box id
    float top
    float bot
    bool bounced
    int start_bar
    float cum_delta // NUEVO CAMPO: Delta neto acumulado

type TPLevel
    line ln
    label lbl
    float price
    bool is_active

type TradeState
    TPLevel tp1
    TPLevel tp2
    TPLevel tp3
    bool is_long
    float sl_price
    int start_bar

// ==========================================
// --- HELPER METHODS ---
// ==========================================
get_line_style(LineStyle s) =>
    switch s
        LineStyle.Solid => line.style_solid
        LineStyle.Dashed => line.style_dashed
        LineStyle.Dotted => line.style_dotted

get_text_size(TextSize s) =>
    switch s
        TextSize.Tiny => size.tiny
        TextSize.Small => size.small
        TextSize.Normal => size.normal
        TextSize.Large => size.large
        TextSize.Huge => size.huge

get_ma(MAType t, float src, int len) =>
    val_ema = ta.ema(src, len)
    val_sma = ta.sma(src, len)
    val_hma = ta.hma(src, len)
    switch t
        MAType.EMA => val_ema
        MAType.SMA => val_sma
        MAType.HMA => val_hma

get_tz(TimeZoneEnum tz) =>
    switch tz
        TimeZoneEnum.NY => "America/New_York"
        TimeZoneEnum.Chicago => "America/Chicago"
        TimeZoneEnum.Denver => "America/Denver"
        TimeZoneEnum.LA => "America/Los_Angeles"
        TimeZoneEnum.London => "Europe/London"
        TimeZoneEnum.Madrid => "Europe/Madrid"
        TimeZoneEnum.Tokyo => "Asia/Tokyo"
        TimeZoneEnum.Dubai => "Asia/Dubai"
        TimeZoneEnum.Sydney => "Australia/Sydney"
        TimeZoneEnum.UTC => "UTC"

get_box_border_style(string s) =>
    switch s
        "Solid" => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dashed

// ==========================================
// --- SETTINGS ---
// ==========================================
g0 = '0. Global Time & Session Mode'
tz_selected_enum = input.enum(TimeZoneEnum.NY, 'Global Timezone', group = g0)
tz_selected = get_tz(tz_selected_enum)
use_crypto_mode = input.bool(false, 'Enable Crypto Mode (8 PM Reset)', group = g0)
crypto_sess = input.session("2000-1959", 'Crypto Daily Cycle', group = g0)

g1 = '1. Moving Averages'
s_ma = input.bool(true, 'Show Moving Averages', group = g1)
type_10 = input.enum(MAType.EMA, 'Fast MA Type', group = g1, inline = "ma1")
l10 = input.int(10, 'Period', group = g1, inline = "ma1")
c10 = input.color(color.white, 'Color', group = g1, inline = "ma1")
type_20 = input.enum(MAType.SMA, 'Trend MA Type', group = g1, inline = "ma2")
l20 = input.int(20, 'Period', group = g1, inline = "ma2")
c20 = input.color(#2962FF, 'Color', group = g1, inline = "ma2") 
type_210 = input.enum(MAType.EMA, 'Support MA Type', group = g1, inline = "ma3")
l210 = input.int(210, 'Period', group = g1, inline = "ma3")
c210 = input.color(#F44336, 'Color', group = g1, inline = "ma3") 

g2 = '2. Drifting VWAP & Bands'
s_vw = input.bool(true, 'Show Drifting VWAP', group = g2)
neutral_vwap_col = input.color(color.yellow, 'Neutral VWAP Color', group = g2)
vwapAnchor = input.string("NY Session (09:30)", title="VWAP Anchor (Regular Mode)", options=["NY Session (09:30)", "Daily", "Weekly", "Monthly"], group = g2)
showBands = input.bool(false, title="Show Standard Deviation Bands", group = g2)
mult1 = input.float(1.0, title="Deviation 1", group = g2)
mult2 = input.float(2.0, title="Deviation 2", group = g2)
mult3 = input.float(3.0, title="Deviation 3", group = g2)
colBand1 = input.color(color.rgb(109, 76, 65, 50), title="Band Color 1", group = g2) 
colBand2 = input.color(color.rgb(62, 39, 35, 60), title="Band Color 2", group = g2) 
colBand3 = input.color(color.rgb(33, 17, 17, 70), title="Band Color 3", group = g2) 

g3 = '3. Advanced FVG Filter'
s_f = input.bool(false, 'Show boxes', group = g3)
cb = input.color(color.aqua, 'Bullish', group = g3)
cr = input.color(color.red, 'Bearish', group = g3)
tbg = input.int(85, 'Transparency', group = g3)
tbr = input.int(75, 'Borders', group = g3)
pro = input.int(3, 'Projection', group = g3) 
use_atr = input.bool(true, 'Filter by ATR (Size)', group = g3)
atr_mult = input.float(0.3, 'ATR Multiplier', step = 0.1, group = g3)
use_vol = input.bool(true, 'Filter by Volume', group = g3)
vol_mult = input.float(1.0, 'Volume Multiplier', step = 0.1, group = g3)
show_vol_text = input.bool(false, 'Show Volume Strength Label', group = g3)
clean_overnight = input.bool(true, 'Auto-Delete Old Session FVGs', group = g3)
use_delta = input.bool(true, 'Filter by Favorable Delta', group = g3)

g4_1 = "4.1 CVD Divergence Settings"
leftBars = input.int(10, title="Left Bars", group = g4_1)
rightBars = input.int(1, title="Right Bars", group = g4_1)

g4_2 = "4.2 Absorption Zones Styling"
cvd_pro = input.int(3, title="Projection Margin (Bars)", group = g4_2)
c_bull_zone = input.color(color.new(#1E56E0, 85), title="Bullish Zone Background", group = g4_2)
c_bull_brdr = input.color(color.new(#2962FF, 0), title="Bullish Zone Border", group = g4_2)
c_bear_zone = input.color(color.new(#4E1107, 85), title="Bearish Zone Background", group = g4_2)
c_bear_brdr = input.color(color.new(#FF6D00, 0), title="Bearish Zone Border", group = g4_2)
zone_brdr_sty_str = input.string("Dotted", title="Zone Border Style", options=["Solid", "Dashed", "Dotted"], group = g4_2)
zone_brdr_width = input.int(1, title="Zone Border Width", minval=1, maxval=5, group = g4_2)
show_zone_delta = input.bool(true, title="Mostrar Magnitud de Delta", group = g4_2) // NUEVO INPUT

g4_3 = "4.3 Entry Validation Parameters"
min_bars_bounce = input.int(2, title="Min Bars Before Bounce", minval=0, tooltip="Minimum number of bars to validate a bounce.", group = g4_3)

g4_4 = "4.4 Breakout, Targets & Chart Cleaning"
use_breakouts = input.bool(true, title="Enable Breakout Strategy", group = g4_4)
cvd_sma_filter = input.int(210, title="Trend Filter (SMA)", group = g4_4)
cvd_atr_len = input.int(14, title="ATR Length", group = g4_4)
cvd_atr_mult_1 = input.float(1.0, title="ATR Multiplier TP1", step=0.5, group = g4_4)
cvd_atr_mult_2 = input.float(2.0, title="ATR Multiplier TP2", step=0.5, group = g4_4)
cvd_atr_mult_3 = input.float(3.0, title="ATR Multiplier TP3", step=0.5, group = g4_4)
max_trade_duration = input.int(30, title="Max Trade Duration (Bars)", tooltip="Kills unresolved TP lines to clean chart", group = g4_4)
c_tp_line = input.color(color.yellow, title="Take Profit Line Color", group = g4_4)

g4_5 = "4.5 Trading Session (Time Filter)"
use_session = input.bool(false, title="Enable Time Filter", group = g4_5)
trade_session = input.session("0400-1045", title="Trading Hours", group = g4_5)

g4_6 = "4.6 Divergence Signals"
show_shapes = input.bool(true, title="Show Divergence Shapes", group = g4_6)
c_long_txt = input.color(color.white, title="Long Entry Text Color", group = g4_6)
c_short_txt = input.color(color.white, title="Short Entry Text Color", group = g4_6)

g4_7 = "4.7 Divergence Candle Colors"
color_bars = input.bool(true, title="Color Candles on Divergence", group = g4_7)
c_bar_bull_up = input.color(#2962FF, title="Bullish Div (Green Candle)", group = g4_7)
c_bar_bull_dn = input.color(#2962FF, title="Bullish Div (Red Candle)", group = g4_7)
c_bar_bear_dn = input.color(#FF6D00, title="Bearish Div (Red Candle)", group = g4_7)
c_bar_bear_up = input.color(#FF6D00, title="Bearish Div (Green Candle)", group = g4_7)

g5 = '7. Hybrid ORB (Crypto, NY & Afternoon)'
s_orb = input.bool(true, 'Show ORB', group = g5)
orb_sess_crypto = input.session('2000-2015', 'Crypto ORB Timeframe', group = g5)
orb_sess_ny = input.session('0930-1000', 'NY ORB Timeframe', group = g5)
orb_sess_pm = input.session('1800-1815', 'Afternoon ORB Timeframe', group = g5)
c_orb = input.color(color.silver, 'Line color', group = g5)
orb_sty_enum = input.enum(LineStyle.Dashed, 'Style', group = g5)
orb_pro = input.int(3, 'Margin', group = g5)
show_orb_lbl = input.bool(true, 'Show Labels', group = g5)

g6 = '8. MTF Momentum Panel'
panel_pos_input = input.enum(PanelPosition.BottomRight, title="Panel Position", group = g6)
panel_layout_input = input.enum(PanelLayout.PC_Expanded, title="Display Mode", group = g6)
color_long = input.color(#26A69A, title="Bullish Color", group = g6)
color_short = input.color(#EF5350, title="Bearish Color", group = g6)

g7 = '9. Market Structure (CHoCH / BOS)'
s_ms = input.bool(false, 'Show Market Structure', group = g7)
ms_prd = input.int(3, 'Pivot Period', minval=1, group = g7)
c_ms_bull = input.color(color.aqua, 'Bullish MS Color', group = g7)
c_ms_bear = input.color(color.red, 'Bearish MS Color', group = g7)
ms_choch_sty_enum = input.enum(LineStyle.Dotted, 'CHoCH Line Style', group = g7)
ms_bos_sty_enum = input.enum(LineStyle.Dotted, 'BOS Line Style', group = g7)
ms_width = input.int(1, 'Line Width', minval=1, maxval=5, group = g7)
ms_text_size_enum = input.enum(TextSize.Small, 'Text Size', group = g7)

g8 = '10. Liquidity (EQH / EQL)'
s_eq = input.bool(false, 'Show EQH / EQL', group = g8)
eq_tol = input.float(0.15, 'Tolerance (ATR Mult)', step=0.05, group = g8)
c_eqh = input.color(color.aqua, 'EQH Color', group = g8)
c_eql = input.color(color.orange, 'EQL Color', group = g8)

// ==========================================
// --- GLOBAL STATES & SYNCHRONIZATION ---
// ==========================================
var bool in_day_session = false
var bool traditional_reset = false
var bool crypto_reset = false
var bool global_reset = false

in_day_session := bool(time(timeframe.period, "0930-1800", tz_selected) > 0)
traditional_reset := bool((in_day_session and not in_day_session[1]) or (not in_day_session and in_day_session[1]))
crypto_reset := bool(ta.change(time("D", crypto_sess, tz_selected)) != 0)
global_reset := bool(use_crypto_mode ? crypto_reset : traditional_reset)

var bool in_trade_window = false
in_trade_window := bool(not use_session or (time(timeframe.period, trade_session, tz_selected) > 0))

float v = volume > 0 ? volume : 1.0

ph = ta.pivothigh(high, ms_prd, ms_prd)
pl = ta.pivotlow(low, ms_prd, ms_prd)

// ==========================================
// --- DRIFTING VWAP & BANDS LOGIC ---
// ==========================================
bool in_ny_rth = bool(time(timeframe.period, "0930-1600", tz_selected) != 0)
bool is_RTH_start = bool(in_ny_rth and not in_ny_rth[1])

bool change_D = bool(ta.change(time("D")) != 0)
bool change_W = bool(ta.change(time("W")) != 0)
bool change_M = bool(ta.change(time("M")) != 0)

bool isNewAnchor = false
if use_crypto_mode
    isNewAnchor := crypto_reset
else if vwapAnchor == "NY Session (09:30)"
    isNewAnchor := timeframe.isdwm ? change_D : is_RTH_start
else if vwapAnchor == "Daily"
    isNewAnchor := change_D
else if vwapAnchor == "Weekly"
    isNewAnchor := change_W
else if vwapAnchor == "Monthly"
    isNewAnchor := change_M

var float sumSrcVol = 0.0
var float sumVol = 0.0
var float sumSrc2Vol = 0.0 

if isNewAnchor
    sumSrcVol := 0.0
    sumVol := 0.0
    sumSrc2Vol := 0.0

sumSrcVol += hlc3 * v
sumVol += v
sumSrc2Vol += math.pow(hlc3, 2) * v

float vwapValue = sumVol > 0 ? sumSrcVol / sumVol : na
float variance = sumVol > 0 ? (sumSrc2Vol / sumVol) - math.pow(vwapValue, 2) : 0.0
float stdDev = variance > 0 ? math.sqrt(variance) : 0.0

float dev1 = stdDev * mult1
float upper1 = vwapValue + dev1
float lower1 = vwapValue - dev1

var int barsSinceAnchor = 0
if isNewAnchor
    barsSinceAnchor := 0
else
    barsSinceAnchor += 1

float tfInMinutes = timeframe.isseconds ? timeframe.multiplier / 60.0 : (timeframe.isminutes ? timeframe.multiplier : 1440.0)

int bars15m = math.max(1, int(math.round(15.0 / tfInMinutes)))
int bars1h  = math.max(1, int(math.round(60.0 / tfInMinutes)))

int safeLookback15m = math.min(bars15m, barsSinceAnchor)
int safeLookback1h  = math.min(bars1h, barsSinceAnchor)

float vwap15mAgo = (safeLookback15m > 0 and timeframe.isintraday) ? vwapValue[safeLookback15m] : na
float price1hAgo = (safeLookback1h > 0 and timeframe.isintraday) ? close[safeLookback1h] : na

bool vwapRising = bool(vwap15mAgo > 0 and (vwapValue > vwap15mAgo))
bool priceUp1h  = bool(price1hAgo > 0 and (close >= (price1hAgo * 1.001)))
bool longTrend  = bool((close > vwapValue) and vwapRising and priceUp1h)

bool vwapFalling = bool(vwap15mAgo > 0 and (vwapValue < vwap15mAgo))
bool priceDown1h = bool(price1hAgo > 0 and (close <= (price1hAgo * 0.999)))
bool shortTrend  = bool((close < vwapValue) and vwapFalling and priceDown1h)

bool isNeutral = bool(not longTrend and not shortTrend)
color neutralColor = isNeutral ? neutral_vwap_col : color.new(neutral_vwap_col, 100)
var plotVisibility = display.pane + display.price_scale

plot(s_vw ? vwapValue : na, title="Neutral VWAP (Line)", color=neutralColor, linewidth=2, style=plot.style_line, display=plotVisibility)
plot(s_vw and longTrend ? vwapValue : na, title="Bullish Drift", color=color.white, linewidth=2, style=plot.style_cross, display=plotVisibility)
plot(s_vw and shortTrend ? vwapValue : na, title="Bearish Drift", color=color.rgb(239, 83, 80), linewidth=2, style=plot.style_cross, display=plotVisibility)

plot(s_vw and showBands ? upper1 : na, title="Upper Band 1", color=colBand1, style=plot.style_line, display=plotVisibility)
plot(s_vw and showBands ? lower1 : na, title="Lower Band 1", color=colBand1, style=plot.style_line, display=plotVisibility)
plot(s_vw and showBands ? vwapValue + (stdDev * mult2) : na, title="Upper Band 2", color=colBand2, style=plot.style_line, display=plotVisibility)
plot(s_vw and showBands ? vwapValue - (stdDev * mult2) : na, title="Lower Band 2", color=colBand2, style=plot.style_line, display=plotVisibility)
plot(s_vw and showBands ? vwapValue + (stdDev * mult3) : na, title="Upper Band 3", color=colBand3, style=plot.style_line, display=plotVisibility)
plot(s_vw and showBands ? vwapValue - (stdDev * mult3) : na, title="Lower Band 3", color=colBand3, style=plot.style_line, display=plotVisibility)

// ==========================================
// --- MAs ---
// ==========================================
ma1 = get_ma(type_10, close, l10)
ma2 = get_ma(type_20, close, l20)
ma3 = get_ma(type_210, close, l210)

plot(s_ma ? ma1 : na, color = c10, linewidth = 2, title="Fast MA")
plot(s_ma ? ma2 : na, color = c20, linewidth = 2, title="Trend MA")
plot(s_ma ? ma3 : na, color = c210, linewidth = 2, title="Support MA")

// ==========================================
// --- ADVANCED CVD PRO ZONES LOGIC V2.1 ---
// ==========================================
float cvd_global_sma = ta.sma(close, cvd_sma_filter)
float cvd_global_atr = ta.atr(cvd_atr_len)

isUp_cvd = bool(close > open)
isDown_cvd = bool(close < open)
isDoji_cvd = bool(close == open)

buyVol  = isUp_cvd ? v : (isDoji_cvd ? v / 2 : 0)
sellVol = isDown_cvd ? v : (isDoji_cvd ? v / 2 : 0)
delta   = buyVol - sellVol

var float cvd = 0.0
if global_reset
    cvd := delta
else
    cvd += delta

pricePh_cvd = ta.pivothigh(high, leftBars, rightBars)
pricePl_cvd = ta.pivotlow(low, leftBars, rightBars)

var float lastPriceHigh = na
var float lastCvdHigh = na
var float lastPriceLow = na
var float lastCvdLow = na

if bool(not na(pricePh_cvd))
    lastPriceHigh := pricePh_cvd
    lastCvdHigh := cvd[rightBars]

if bool(not na(pricePl_cvd))
    lastPriceLow := pricePl_cvd
    lastCvdLow := cvd[rightBars]

signalBearishDiv = bool(lastPriceHigh > 0 and high > lastPriceHigh and cvd < lastCvdHigh)
signalBullishDiv = bool(lastPriceLow > 0 and low < lastPriceLow and cvd > lastCvdLow)

triggerBear = bool(signalBearishDiv and not signalBearishDiv[1])
triggerBull = bool(signalBullishDiv and not signalBullishDiv[1])

var b_zones = array.new<DivZone>()
var r_zones = array.new<DivZone>()
var active_trades = array.new<TradeState>()

ip_cvd = bar_index + cvd_pro
brdr_style = get_box_border_style(zone_brdr_sty_str)

candle_range = high - low
bull_sweep = math.min(open, close) - low
bull_opp = high - math.max(open, close)
bear_sweep = high - math.max(open, close)
bear_opp = math.min(open, close) - low

valid_bull_bounce = bool(candle_range > 0 and (bull_sweep / candle_range) >= 0.3 and (bull_opp / candle_range) <= 0.6)
valid_bear_bounce = bool(candle_range > 0 and (bear_sweep / candle_range) >= 0.3 and (bear_opp / candle_range) <= 0.6)

bool enter_long_bounce = false
bool enter_short_bounce = false
bool enter_bo_long = false
bool enter_bo_short = false

if triggerBull
    top_body = math.min(open, close)
    bottom_wick = low
    bx = box.new(bar_index, top_body, ip_cvd, bottom_wick, border_color=c_bull_brdr, border_width=zone_brdr_width, border_style=brdr_style, bgcolor=c_bull_zone)
    array.push(b_zones, DivZone.new(bx, top_body, bottom_wick, false, bar_index, delta))

sz_b_z = array.size(b_zones)
if bool(sz_b_z > 0)
    for i = sz_b_z - 1 to 0
        zone = array.get(b_zones, i)
        box.set_right(zone.id, ip_cvd) 
        
        // Acumulación y visualización del Delta
        zone.cum_delta += delta
        if show_zone_delta
            box.set_text(zone.id, "Δ " + str.tostring(zone.cum_delta, format.volume))
            box.set_text_color(zone.id, color.new(c_long_txt, 30))
            box.set_text_size(zone.id, size.tiny)
            box.set_text_valign(zone.id, text.align_bottom)
        
        if bool(close < zone.bot)
            if bool(use_breakouts and not enter_bo_short and close < cvd_global_sma and in_trade_window)
                enter_bo_short := true
                
                sz_clean_short = array.size(active_trades)
                if sz_clean_short > 0
                    for j = sz_clean_short - 1 to 0
                        old_trade = array.get(active_trades, j)
                        if not old_trade.is_long
                            line.delete(old_trade.tp1.ln)
                            label.delete(old_trade.tp1.lbl)
                            line.delete(old_trade.tp2.ln)
                            label.delete(old_trade.tp2.lbl)
                            line.delete(old_trade.tp3.ln)
                            label.delete(old_trade.tp3.lbl)
                            array.remove(active_trades, j)
                
                float p1 = close - (cvd_global_atr * cvd_atr_mult_1)
                float p2 = close - (cvd_global_atr * cvd_atr_mult_2)
                float p3 = close - (cvd_global_atr * cvd_atr_mult_3)
                float sl = zone.top
                
                ln1 = line.new(bar_index, p1, bar_index + 1, p1, color=c_tp_line, style=line.style_dashed)
                lb1 = label.new(bar_index + 1, p1, "T1", color=color.new(color.black, 100), textcolor=c_tp_line, style=label.style_label_left, size=size.tiny)
                
                ln2 = line.new(bar_index, p2, bar_index + 1, p2, color=c_tp_line, style=line.style_dashed)
                lb2 = label.new(bar_index + 1, p2, "T2", color=color.new(color.black, 100), textcolor=c_tp_line, style=label.style_label_left, size=size.tiny)
                
                ln3 = line.new(bar_index, p3, bar_index + 1, p3, color=c_tp_line, style=line.style_dashed)
                lb3 = label.new(bar_index + 1, p3, "T3", color=color.new(color.black, 100), textcolor=c_tp_line, style=label.style_label_left, size=size.tiny)
                
                t1 = TPLevel.new(ln1, lb1, p1, true)
                t2 = TPLevel.new(ln2, lb2, p2, true)
                t3 = TPLevel.new(ln3, lb3, p3, true)
                array.push(active_trades, TradeState.new(t1, t2, t3, false, sl, bar_index))

            box.delete(zone.id)
            array.remove(b_zones, i)
            continue
            
        if bool(not zone.bounced and (bar_index - zone.start_bar >= min_bars_bounce) and low <= zone.top and close > zone.bot)
            if bool(isUp_cvd and valid_bull_bounce and in_trade_window)
                enter_long_bounce := true
                zone.bounced := true
                box.set_bgcolor(zone.id, color.new(c_bull_zone, 95))

if triggerBear
    top_wick = high
    bottom_body = math.max(open, close)
    bx = box.new(bar_index, top_wick, ip_cvd, bottom_body, border_color=c_bear_brdr, border_width=zone_brdr_width, border_style=brdr_style, bgcolor=c_bear_zone)
    array.push(r_zones, DivZone.new(bx, top_wick, bottom_body, false, bar_index, delta))

sz_r_z = array.size(r_zones)
if bool(sz_r_z > 0)
    for i = sz_r_z - 1 to 0
        zone = array.get(r_zones, i)
        box.set_right(zone.id, ip_cvd) 
        
        // Acumulación y visualización del Delta
        zone.cum_delta += delta
        if show_zone_delta
            box.set_text(zone.id, "Δ " + str.tostring(zone.cum_delta, format.volume))
            box.set_text_color(zone.id, color.new(c_short_txt, 30))
            box.set_text_size(zone.id, size.tiny)
            box.set_text_valign(zone.id, text.align_top)
        
        if bool(close > zone.top)
            if bool(use_breakouts and not enter_bo_long and close > cvd_global_sma and in_trade_window)
                enter_bo_long := true
                
                sz_clean_long = array.size(active_trades)
                if sz_clean_long > 0
                    for j = sz_clean_long - 1 to 0
                        old_trade = array.get(active_trades, j)
                        if old_trade.is_long
                            line.delete(old_trade.tp1.ln)
                            label.delete(old_trade.tp1.lbl)
                            line.delete(old_trade.tp2.ln)
                            label.delete(old_trade.tp2.lbl)
                            line.delete(old_trade.tp3.ln)
                            label.delete(old_trade.tp3.lbl)
                            array.remove(active_trades, j)
                
                float p1 = close + (cvd_global_atr * cvd_atr_mult_1)
                float p2 = close + (cvd_global_atr * cvd_atr_mult_2)
                float p3 = close + (cvd_global_atr * cvd_atr_mult_3)
                float sl = zone.bot
                
                ln1 = line.new(bar_index, p1, bar_index + 1, p1, color=c_tp_line, style=line.style_dashed)
                lb1 = label.new(bar_index + 1, p1, "T1", color=color.new(color.black, 100), textcolor=c_tp_line, style=label.style_label_left, size=size.tiny)
                
                ln2 = line.new(bar_index, p2, bar_index + 1, p2, color=c_tp_line, style=line.style_dashed)
                lb2 = label.new(bar_index + 1, p2, "T2", color=color.new(color.black, 100), textcolor=c_tp_line, style=label.style_label_left, size=size.tiny)
                
                ln3 = line.new(bar_index, p3, bar_index + 1, p3, color=c_tp_line, style=line.style_dashed)
                lb3 = label.new(bar_index + 1, p3, "T3", color=color.new(color.black, 100), textcolor=c_tp_line, style=label.style_label_left, size=size.tiny)
                
                t1 = TPLevel.new(ln1, lb1, p1, true)
                t2 = TPLevel.new(ln2, lb2, p2, true)
                t3 = TPLevel.new(ln3, lb3, p3, true)
                array.push(active_trades, TradeState.new(t1, t2, t3, true, sl, bar_index))

            box.delete(zone.id)
            array.remove(r_zones, i)
            continue
            
        if bool(not zone.bounced and (bar_index - zone.start_bar >= min_bars_bounce) and high >= zone.bot and close < zone.top)
            if bool(isDown_cvd and valid_bear_bounce and in_trade_window)
                enter_short_bounce := true
                zone.bounced := true
                box.set_bgcolor(zone.id, color.new(c_bear_zone, 95))

sz_t = array.size(active_trades)
if bool(sz_t > 0)
    for i = sz_t - 1 to 0
        trade = array.get(active_trades, i)
        
        bool sl_hit = false
        if bool(trade.is_long and close <= trade.sl_price)
            sl_hit := true
        if bool(not trade.is_long and close >= trade.sl_price)
            sl_hit := true
            
        bool time_expired = bool((bar_index - trade.start_bar) > max_trade_duration)
        
        if bool(sl_hit or time_expired)
            line.delete(trade.tp1.ln)
            label.delete(trade.tp1.lbl)
            line.delete(trade.tp2.ln)
            label.delete(trade.tp2.lbl)
            line.delete(trade.tp3.ln)
            label.delete(trade.tp3.lbl)
            array.remove(active_trades, i)
            continue
        
        if trade.tp1.is_active
            line.set_x2(trade.tp1.ln, bar_index + 1)
            label.set_x(trade.tp1.lbl, bar_index + 1)
            if bool((trade.is_long and high >= trade.tp1.price) or (not trade.is_long and low <= trade.tp1.price))
                trade.tp1.is_active := false
                line.set_color(trade.tp1.ln, color.new(color.gray, 60))
                label.set_textcolor(trade.tp1.lbl, color.new(color.gray, 60))
                
        if trade.tp2.is_active
            line.set_x2(trade.tp2.ln, bar_index + 1)
            label.set_x(trade.tp2.lbl, bar_index + 1)
            if bool((trade.is_long and high >= trade.tp2.price) or (not trade.is_long and low <= trade.tp2.price))
                trade.tp2.is_active := false
                line.set_color(trade.tp2.ln, color.new(color.gray, 60))
                label.set_textcolor(trade.tp2.lbl, color.new(color.gray, 60))
                
        if trade.tp3.is_active
            line.set_x2(trade.tp3.ln, bar_index + 1)
            label.set_x(trade.tp3.lbl, bar_index + 1)
            if bool((trade.is_long and high >= trade.tp3.price) or (not trade.is_long and low <= trade.tp3.price))
                trade.tp3.is_active := false
                line.set_color(trade.tp3.ln, color.new(color.gray, 60))
                label.set_textcolor(trade.tp3.lbl, color.new(color.gray, 60))

plotshape(enter_long_bounce, title="Long Bounce", style=shape.labelup, location=location.belowbar, color=color.new(#1E56E0, 0), size=size.tiny, text="B", textcolor=c_long_txt)
plotshape(enter_short_bounce, title="Short Bounce", style=shape.labeldown, location=location.abovebar, color=color.new(#E65100, 0), size=size.tiny, text="B", textcolor=c_short_txt)

plotshape(enter_bo_long, title="Long Breakout", style=shape.labelup, location=location.belowbar, color=color.new(color.teal, 0), size=size.tiny, text="BU", textcolor=color.white)
plotshape(enter_bo_short, title="Short Breakout", style=shape.labeldown, location=location.abovebar, color=color.new(color.maroon, 0), size=size.tiny, text="BD", textcolor=color.white)

isCandleUp = bool(close >= open)
isCandleDown = bool(close < open)

plotshape(bool(show_shapes and triggerBull and isCandleUp), title="Bullish Div (Green Candle)", style=shape.triangleup, location=location.belowbar, color=#2962FF, size=size.tiny)
plotshape(bool(show_shapes and triggerBull and isCandleDown), title="Bullish Div (Red Candle)", style=shape.xcross, location=location.belowbar, color=#2962FF, size=size.tiny)
plotshape(bool(show_shapes and triggerBear and isCandleDown), title="Bearish Div (Red Candle)", style=shape.triangledown, location=location.abovebar, color=#FF6D00, size=size.tiny)
plotshape(bool(show_shapes and triggerBear and isCandleUp), title="Bearish Div (Green Candle)", style=shape.cross, location=location.abovebar, color=#FF6D00, size=size.tiny)

color final_bar_color = na
if bool(triggerBull and isCandleUp)
    final_bar_color := c_bar_bull_up
if bool(triggerBull and isCandleDown)
    final_bar_color := c_bar_bull_dn
if bool(triggerBear and isCandleDown)
    final_bar_color := c_bar_bear_dn
if bool(triggerBear and isCandleUp)
    final_bar_color := c_bar_bear_up

barcolor(color_bars ? final_bar_color : na, title="Divergence Candle Colors")

// ==========================================
// --- FVG LOGIC WITH FILTERS ---
// ==========================================
_atr = ta.atr(14)
_vol_avg = ta.sma(v, 20)

bull_gap = low - high[2]
bear_gap = low[2] - high

vol_ratio = _vol_avg[1] > 0 ? (v[1] / _vol_avg[1]) : 0.0
fvg_text_base = show_vol_text ? ("Vol: " + str.tostring(vol_ratio, "#.#") + "x") : ""
fvg_text_final = use_delta ? fvg_text_base + " Delta" : fvg_text_base

var bool valid_vol = false
var bool valid_bull_size = false
var bool valid_bear_size = false
var bool valid_bull_delta = false
var bool valid_bear_delta = false

valid_vol := bool(not use_vol or (v[1] > (_vol_avg[1] * vol_mult)))
valid_bull_size := bool(not use_atr or (bull_gap > (_atr[1] * atr_mult)))
valid_bear_size := bool(not use_atr or (bear_gap > (_atr[1] * atr_mult)))
valid_bull_delta := bool(not use_delta or (delta[1] > 0))
valid_bear_delta := bool(not use_delta or (delta[1] < 0))

var bool is_bull = false
var bool is_bear = false
is_bull := bool(bull_gap > 0 and valid_vol and valid_bull_size and valid_bull_delta)
is_bear := bool(bear_gap > 0 and valid_vol and valid_bear_size and valid_bear_delta)

var b_bx = array.new<box>()
var r_bx = array.new<box>()
var b_ln = array.new<line>()
var r_ln = array.new<line>()
var b_ovn = array.new<bool>()
var r_ovn = array.new<bool>()

ip = bar_index + pro 

bg_b_strong = color.new(cb, tbg)
bg_r_strong = color.new(cr, tbg)
br_b = color.new(cb, tbr)
br_r = color.new(cr, tbr)
c_line_b = color.new(cb, 65)
c_line_r = color.new(cr, 65)

var bool is_out_of_session = false
is_out_of_session := bool(use_crypto_mode ? false : not in_day_session)

if bool(s_f and is_bull)
    if array.size(b_bx) > 450
        box.delete(array.shift(b_bx))
        line.delete(array.shift(b_ln))
        array.shift(b_ovn)

    array.push(b_bx, box.new(bar_index, low, ip, high[2], border_color = br_b, bgcolor = bg_b_strong, text = fvg_text_final, text_size = size.small, text_color = cb, text_halign = text.align_right, text_valign = text.align_bottom))
    mid_b = high[2] + ((low - high[2]) / 2.0)
    array.push(b_ln, line.new(bar_index, mid_b, ip, mid_b, color = c_line_b, style = line.style_dotted, width = 1))
    array.push(b_ovn, is_out_of_session) 

if bool(s_f and is_bear)
    if array.size(r_bx) > 450
        box.delete(array.shift(r_bx))
        line.delete(array.shift(r_ln))
        array.shift(r_ovn)

    array.push(r_bx, box.new(bar_index, low[2], ip, high, border_color = br_r, bgcolor = bg_r_strong, text = fvg_text_final, text_size = size.small, text_color = cr, text_halign = text.align_right, text_valign = text.align_top))
    mid_r = high + ((low[2] - high) / 2.0)
    array.push(r_ln, line.new(bar_index, mid_r, ip, mid_r, color = c_line_r, style = line.style_dotted, width = 1))
    array.push(r_ovn, is_out_of_session)

sz_b = array.size(b_bx)
if sz_b > 0
    for i = sz_b - 1 to 0
        bx = array.get(b_bx, i)
        ln = array.get(b_ln, i)
        box.set_right(bx, ip) 
        line.set_x2(ln, ip)
        curr_top = box.get_top(bx)
        curr_bot = box.get_bottom(bx)
        midpoint = curr_bot + ((curr_top - curr_bot) / 2.0)
        if bool(low < midpoint)
            box.delete(bx)
            line.delete(ln)
            array.remove(b_bx, i)
            array.remove(b_ln, i)
            array.remove(b_ovn, i)

sz_r = array.size(r_bx)
if sz_r > 0
    for i = sz_r - 1 to 0
        bx = array.get(r_bx, i)
        ln = array.get(r_ln, i)
        box.set_right(bx, ip) 
        line.set_x2(ln, ip)
        curr_top = box.get_top(bx)
        curr_bot = box.get_bottom(bx)
        midpoint = curr_bot + ((curr_top - curr_bot) / 2.0)
        if bool(high > midpoint)
            box.delete(bx)
            line.delete(ln)
            array.remove(r_bx, i)
            array.remove(r_ln, i)
            array.remove(r_ovn, i)

if bool(global_reset and clean_overnight)
    sz_b_clean = array.size(b_bx)
    if sz_b_clean > 0
        for i = sz_b_clean - 1 to 0
            if bool(array.get(b_ovn, i) == true)
                box.delete(array.get(b_bx, i))
                line.delete(array.get(b_ln, i))
                array.remove(b_bx, i)
                array.remove(b_ln, i)
                array.remove(b_ovn, i)
    sz_r_clean = array.size(r_bx)
    if sz_r_clean > 0
        for i = sz_r_clean - 1 to 0
            if bool(array.get(r_ovn, i) == true)
                box.delete(array.get(r_bx, i))
                line.delete(array.get(r_ln, i))
                array.remove(r_bx, i)
                array.remove(r_ln, i)
                array.remove(r_ovn, i)

// ==========================================
// --- CHOCH, BOS & LIQUIDITY LOGIC ---
// ==========================================
var float last_ph = na
var int last_ph_loc = na
var float last_pl = na
var int last_pl_loc = na
var int ms_trend = 1 

var float last_eq_ph = na
var int last_eq_ph_loc = na
var float last_eq_pl = na
var int last_eq_pl_loc = na

choch_sty = get_line_style(ms_choch_sty_enum)
bos_sty = get_line_style(ms_bos_sty_enum)
ms_size = get_text_size(ms_text_size_enum)

if bool(ph > 0)
    if bool(s_eq and last_eq_ph > 0)
        if bool(math.abs(ph - last_eq_ph) <= (_atr * eq_tol))
            line.new(last_eq_ph_loc, last_eq_ph, bar_index - ms_prd, ph, color=c_eqh, style=line.style_dotted, width=ms_width)
            label.new(int(math.avg(last_eq_ph_loc, bar_index - ms_prd)), math.max(last_eq_ph, ph), "EQH", color=color.new(color.white,100), textcolor=c_eqh, style=label.style_label_down, size=ms_size)
    last_eq_ph := ph
    last_eq_ph_loc := bar_index - ms_prd
    last_ph := ph
    last_ph_loc := bar_index - ms_prd

if bool(pl > 0)
    if bool(s_eq and last_eq_pl > 0)
        if bool(math.abs(pl - last_eq_pl) <= (_atr * eq_tol))
            line.new(last_eq_pl_loc, last_eq_pl, bar_index - ms_prd, pl, color=c_eql, style=line.style_dotted, width=ms_width)
            label.new(int(math.avg(last_eq_pl_loc, bar_index - ms_prd)), math.min(last_eq_pl, pl), "EQL", color=color.new(color.white,100), textcolor=c_eql, style=label.style_label_up, size=ms_size)
    last_eq_pl := pl
    last_eq_pl_loc := bar_index - ms_prd
    last_pl := pl
    last_pl_loc := bar_index - ms_prd

var bool bull_break = false
var bool bear_break = false
bull_break := bool(last_ph > 0 and close > last_ph and close[1] <= last_ph)
bear_break := bool(last_pl > 0 and close < last_pl and close[1] >= last_pl)

if bool(s_ms and bull_break)
    if ms_trend == -1
        ms_trend := 1
        line.new(last_ph_loc, last_ph, bar_index, last_ph, color=c_ms_bull, style=choch_sty, width=ms_width)
        label.new(int(math.avg(last_ph_loc, bar_index)), last_ph, "CHoCH", color=color.new(color.white,100), textcolor=c_ms_bull, style=label.style_label_down, size=ms_size)
    else if ms_trend == 1
        line.new(last_ph_loc, last_ph, bar_index, last_ph, color=c_ms_bull, style=bos_sty, width=ms_width)
        label.new(int(math.avg(last_ph_loc, bar_index)), last_ph, "BOS", color=color.new(color.white,100), textcolor=c_ms_bull, style=label.style_label_down, size=ms_size)
    last_ph := na 

if bool(s_ms and bear_break)
    if ms_trend == 1
        ms_trend := -1
        line.new(last_pl_loc, last_pl, bar_index, last_pl, color=c_ms_bear, style=choch_sty, width=ms_width)
        label.new(int(math.avg(last_pl_loc, bar_index)), last_pl, "CHoCH", color=color.new(color.white,100), textcolor=c_ms_bear, style=label.style_label_up, size=ms_size)
    else if ms_trend == -1
        line.new(last_pl_loc, last_pl, bar_index, last_pl, color=c_ms_bear, style=bos_sty, width=ms_width)
        label.new(int(math.avg(last_pl_loc, bar_index)), last_pl, "BOS", color=color.new(color.white,100), textcolor=c_ms_bear, style=label.style_label_up, size=ms_size)
    last_pl := na 

// ==========================================
// --- TRIPLE HYBRID ORB LOGIC (MTF FIXED) ---
// ==========================================
f_get_orb(sess, tz) =>
    is_in = time("1", sess, tz) > 0
    var float h = na
    var float l = na
    var int st = na
    if is_in and not is_in[1]
        h := high
        l := low
        st := time
    else if is_in
        h := math.max(h, high)
        l := math.min(l, low)
    [h, l, st]

[mtf_crypto_h, mtf_crypto_l, mtf_crypto_st] = request.security(syminfo.tickerid, "1", f_get_orb(orb_sess_crypto, tz_selected))
[mtf_ny_h, mtf_ny_l, mtf_ny_st] = request.security(syminfo.tickerid, "1", f_get_orb(orb_sess_ny, tz_selected))
[mtf_pm_h, mtf_pm_l, mtf_pm_st] = request.security(syminfo.tickerid, "1", f_get_orb(orb_sess_pm, tz_selected))

var float crypto_orb_h = na, var float crypto_orb_l = na, var int crypto_orb_start = na
var float ny_orb_h = na, var float ny_orb_l = na, var int ny_orb_start = na
var float pm_orb_h = na, var float pm_orb_l = na, var int pm_orb_start = na

if global_reset
    crypto_orb_h := na, crypto_orb_l := na
    ny_orb_h := na, ny_orb_l := na
    pm_orb_h := na, pm_orb_l := na

if bool(mtf_crypto_st > 0)
    if mtf_crypto_st != mtf_crypto_st[1]
        crypto_orb_start := bar_index
    crypto_orb_h := mtf_crypto_h
    crypto_orb_l := mtf_crypto_l

if bool(mtf_ny_st > 0)
    if mtf_ny_st != mtf_ny_st[1]
        ny_orb_start := bar_index
    ny_orb_h := mtf_ny_h
    ny_orb_l := mtf_ny_l

if bool(mtf_pm_st > 0)
    if mtf_pm_st != mtf_pm_st[1]
        pm_orb_start := bar_index
    pm_orb_h := mtf_pm_h
    pm_orb_l := mtf_pm_l

var bool is_ny_display = false
var bool is_pm_display = false
is_ny_display := bool(time(timeframe.period, "0930-1759", tz_selected) > 0)
is_pm_display := bool(time(timeframe.period, "1800-0929", tz_selected) > 0)

var bool show_crypto = false
var bool show_ny = false
var bool show_pm = false

show_crypto := bool(use_crypto_mode)
show_ny := bool(not use_crypto_mode and is_ny_display)
show_pm := bool(not use_crypto_mode and is_pm_display)

var line l_orb_h = line.new(na, na, na, na, color = c_orb, style = get_line_style(orb_sty_enum), width = 1)
var line l_orb_l = line.new(na, na, na, na, color = c_orb, style = get_line_style(orb_sty_enum), width = 1)
var label lb_orb_h = label.new(na, na, "", color = color.new(color.white, 100), textcolor = c_orb, style = label.style_label_down, size = size.small)
var label lb_orb_l = label.new(na, na, "", color = color.new(color.white, 100), textcolor = c_orb, style = label.style_label_up, size = size.small)

ip_orb = bar_index + orb_pro

if s_orb
    if bool(show_crypto and crypto_orb_h > 0)
        line.set_xy1(l_orb_h, crypto_orb_start, crypto_orb_h)
        line.set_xy2(l_orb_h, ip_orb, crypto_orb_h)
        line.set_xy1(l_orb_l, crypto_orb_start, crypto_orb_l)
        line.set_xy2(l_orb_l, ip_orb, crypto_orb_l)
        if show_orb_lbl
            label.set_xy(lb_orb_h, ip_orb, crypto_orb_h)
            label.set_text(lb_orb_h, 'CRYPTO ORB-H')
            label.set_xy(lb_orb_l, ip_orb, crypto_orb_l)
            label.set_text(lb_orb_l, 'CRYPTO ORB-L')
    else if bool(show_ny and ny_orb_h > 0)
        line.set_xy1(l_orb_h, ny_orb_start, ny_orb_h)
        line.set_xy2(l_orb_h, ip_orb, ny_orb_h)
        line.set_xy1(l_orb_l, ny_orb_start, ny_orb_l)
        line.set_xy2(l_orb_l, ip_orb, ny_orb_l)
        if show_orb_lbl
            label.set_xy(lb_orb_h, ip_orb, ny_orb_h)
            label.set_text(lb_orb_h, 'NY ORB-H')
            label.set_xy(lb_orb_l, ip_orb, ny_orb_l)
            label.set_text(lb_orb_l, 'NY ORB-L')
    else if bool(show_pm and pm_orb_h > 0)
        line.set_xy1(l_orb_h, pm_orb_start, pm_orb_h)
        line.set_xy2(l_orb_h, ip_orb, pm_orb_h)
        line.set_xy1(l_orb_l, pm_orb_start, pm_orb_l)
        line.set_xy2(l_orb_l, ip_orb, pm_orb_l)
        if show_orb_lbl
            label.set_xy(lb_orb_h, ip_orb, pm_orb_h)
            label.set_text(lb_orb_h, 'PM ORB-H')
            label.set_xy(lb_orb_l, ip_orb, pm_orb_l)
            label.set_text(lb_orb_l, 'PM ORB-L')
    else
        line.set_xy1(l_orb_h, na, na)
        line.set_xy1(l_orb_l, na, na)
        label.set_xy(lb_orb_h, na, na)
        label.set_xy(lb_orb_l, na, na)
else
    line.set_xy1(l_orb_h, na, na)
    line.set_xy1(l_orb_l, na, na)
    label.set_xy(lb_orb_h, na, na)
    label.set_xy(lb_orb_l, na, na)

// ==========================================
// --- MTF MOMENTUM PANEL LOGIC ---
// ==========================================
get_pos(PanelPosition p) =>
    switch p
        PanelPosition.TopRight => position.top_right
        PanelPosition.TopLeft => position.top_left
        PanelPosition.BottomRight => position.bottom_right
        PanelPosition.BottomLeft => position.bottom_left
        PanelPosition.MiddleRight => position.middle_right
        PanelPosition.MiddleLeft => position.middle_left

c_bg_modern = color.new(#131722, 20) 
c_border    = color.new(#363A45, 50) 
c_neutral   = color.new(#787B86, 0)

var int t_cols = 2
var int t_rows = 10
var table panel = table.new(get_pos(panel_pos_input), columns=t_cols, rows=t_rows, bgcolor=c_bg_modern, border_width=1, border_color=c_border, frame_color=c_border, frame_width=1)

f_mom() => close > open ? 1 : close < open ? -1 : 0

m_1D  = request.security(syminfo.tickerid, "1D",  f_mom())
m_4H  = request.security(syminfo.tickerid, "240", f_mom())
m_2H  = request.security(syminfo.tickerid, "120", f_mom())
m_1H  = request.security(syminfo.tickerid, "60",  f_mom())
m_30m = request.security(syminfo.tickerid, "30",  f_mom())
m_15m = request.security(syminfo.tickerid, "15",  f_mom())
m_10m = request.security(syminfo.tickerid, "10",  f_mom())
m_5m  = request.security(syminfo.tickerid, "5",   f_mom())
m_1m  = request.security(syminfo.tickerid, "1",   f_mom())

var tfs = array.from("1D", "4H", "2H", "1H", "30m", "15m", "10m", "5m", "1m")

if barstate.isfirst
    table.merge_cells(panel, 0, 0, 1, 0)

if barstate.islast
    momentums = array.from(m_1D, m_4H, m_2H, m_1H, m_30m, m_15m, m_10m, m_5m, m_1m)
    score_long = (m_1D == 1 ? 15 : 0) + (m_4H == 1 ? 15 : 0) + (m_2H == 1 ? 15 : 0) + (m_1H == 1 ? 15 : 0) + (m_30m == 1 ? 10 : 0) + (m_15m == 1 ? 10 : 0) + (m_10m == 1 ? 10 : 0) + (m_5m == 1 ? 5 : 0) + (m_1m == 1 ? 5 : 0)
    score_short = (m_1D == -1 ? 15 : 0) + (m_4H == -1 ? 15 : 0) + (m_2H == -1 ? 15 : 0) + (m_1H == -1 ? 15 : 0) + (m_30m == -1 ? 10 : 0) + (m_15m == -1 ? 10 : 0) + (m_10m == -1 ? 10 : 0) + (m_5m == -1 ? 5 : 0) + (m_1m == -1 ? 5 : 0)

    panel_is_bull = bool(score_long > score_short)
    panel_is_bear = bool(score_short > score_long)
    
    prob_color = panel_is_bull ? color.new(color_long, 20) : panel_is_bear ? color.new(color_short, 20) : color.new(c_neutral, 20)
    prob_text  = panel_is_bull ? "BULL " + str.tostring(score_long) + "%" : panel_is_bear ? "BEAR " + str.tostring(score_short) + "%" : "NEUTRAL"
    txt_size   = panel_layout_input == PanelLayout.PC_Expanded ? size.small : size.tiny

    table.cell(panel, 0, 0, prob_text, text_color=color.white, text_size=txt_size, text_font_family=font.family_monospace, bgcolor=prob_color)
    
    for i = 0 to 8
        m_val = array.get(momentums, i)
        
        sym_bull = panel_layout_input == PanelLayout.PC_Expanded ? "Bull ▲" : "▲"
        sym_bear = panel_layout_input == PanelLayout.PC_Expanded ? "Bear ▼" : "▼"
        sym_txt  = m_val == 1 ? sym_bull : m_val == -1 ? sym_bear : "▬"
        c_txt    = m_val == 1 ? color_long : m_val == -1 ? color_short : c_neutral
        
        table.cell(panel, 0, i + 1, array.get(tfs, i), text_color=color.new(color.white, 30), text_size=txt_size, text_halign=text.align_left)
        table.cell(panel, 1, i + 1, sym_txt, text_color=c_txt, text_size=txt_size, text_halign=text.align_right)
````
