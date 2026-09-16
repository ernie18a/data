<!-- tradingview-pine-id: PUB;363b0cbb08d4487aacf6810fcc3df5b7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# NX Flow

Source: https://www.tradingview.com/script/0CSha3nK/

## Description

■Overview
"NX Flow" is a next-generation confluence indicator that seamlessly merges pure Price Action with Order Flow dynamics.
While many traders focus solely on the shape of price movements, it is "Volume" and "Liquidity" that truly drive the market. This script is designed to project the fundamental essence of the market—institutional intent, structural shifts, and true buying/selling pressure—directly onto your main chart intuitively, without cluttering your workspace with complex lower-pane oscillators.

■TradingView House Rules & Educational Intent
This script is built strictly for educational purposes and fully complies with TradingView's House Rules. It utilizes absolutely NO repainting functions and NO lookahead features that reference future data. To ensure signal authenticity and maintain chart performance, heavy internal calculations (such as Volume Profile processing) are highly optimized and executed only when the candle is finalized (barstate.isconfirmed).

■Core Calculation Logic & Mathematical Rationale
The script mathematically evaluates the following elements. A signal is output only when the combined score exceeds your defined sensitivity threshold.

1. SuperTrend Baseline (Trend & Volatility)

Calculation: Base = hl2. Upper/Lower Bands = Base ± (Multiplier * ATR).

Why? Simple moving averages lag and ignore volatility. By using the median price and ATR, this model dynamically adapts to market noise, tightening during consolidation and widening during high volatility to prevent premature stop-outs.

2. Fibonacci Retracements (0.5 / 0.618)

Calculation: Range = Pivot High - Pivot Low. Dynamically calculates the 50% and 61.8% retracement levels of the most recent swing.

Why? These ratios are statistically proven mean-reversion zones where institutional algorithms frequently place limit orders. Calculating these automatically removes subjective drawing errors.

3. CVD (Cumulative Volume Delta)

Calculation: Delta = +Volume (if Close > Open) or -Volume (if Close < Open). Cumulates the net difference.

Why? Total volume shows activity, but CVD reveals "Intent." By separating buying/selling volume, it exposes hidden Order Flow, allowing you to spot divergences where smart money is distributing into retail buying pressure.

4. Volume Profile POC (Point of Control)

Calculation: Scans the high/low range over the last 200 bars, divides it into equal bins, and aggregates volume into the specific bin where the typical price (hlc3) traded. Finds the bin with the max volume.

Why? POC is the exact mathematical price where the most trading occurred—the "fairest" value agreed upon by buyers and sellers. It acts as a massive gravitational wall. To keep the chart clean, this is computed strictly via background array logic.

5. FVG (Fair Value Gap) & CHoCH (Change of Character)

Calculation: Detects 3-candle liquidity voids (FVG) and structural breaks of recent pivot highs/lows (CHoCH).

Why? Identifies the exact moment a sequence of highs/lows is broken and visualizes areas of inefficient pricing that the market will naturally seek to rebalance.

6. Smart Bias (MTF & VSA - Volume Spread Analysis)

Calculation: Validates execution timeframe VSA (Spread > 20 SMA & Volume > 1.5x 20 SMA) against the Higher Timeframe (default Weekly) EMA trend.

Why? Eliminates counter-trend fake-outs. If macro trend is bullish, it mathematically filters out micro bearish traps by demanding institutional effort (high volume/spread) aligns with the macro direction.

■Visual Interface: Cyber Volume Envelope
The wavy bands rendered at the top and bottom of the SuperTrend scale the current volume's strength against its moving average using an ATR multiplier. When volume spikes, the waves expand dynamically. This provides an immediate, intuitive read of the market's injected energy right on the price action, eliminating the need to look away at a separate volume indicator.

■How to Use

Trend Identification: Assess the immediate market environment using the color of the central SuperTrend line and its surrounding Cyber Bands.

Confluence Signals: A "BUY / SELL" label is triggered only when your required number of conditions (default 5 out of 7) align, combined with strict filters requiring above-average volume and sufficient candle body size.

Customize the Confluence Sensitivity and Higher Timeframe baseline in the settings to perfectly match your trading style.

This indicator and description are provided for educational and informational purposes only and do not constitute financial advice or a recommendation to buy or sell any financial instrument. Trading in financial markets involves a high degree of risk and may result in the loss of your entire capital. The signals and analysis provided by this script are based on historical data and probabilistic modeling, and do not guarantee future profits. The author accepts no liability for any losses or damages incurred as a result of using this script. All trading decisions must be made strictly at your own discretion and at your own risk.

---

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@ALT_analyst
//@version=6
indicator("NX Flow", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500, max_bars_back=5000)

// ~~ Constants & Titles {
const string t_fvgShow        = "Show FVG Candles"
const string t_fvgBullCol     = "Bullish FVG Color"
const string t_fvgBearCol     = "Bearish FVG Color"

const string t_chochShow      = "Show CHoCH Candles"
const string t_chochPivL      = "Pivot Left Length"
const string t_chochPivR      = "Pivot Right Length"
const string t_chochBullCol   = "Bullish CHoCH Color"
const string t_chochBearCol   = "Bearish CHoCH Color"

const string t_biasHtf        = "Higher Timeframe (Structure)"
const string t_vsaPeriod      = "VSA Baseline Period"
const string t_rvolThresh     = "RVOL Threshold (x MA)"

const string t_fibShow        = "Show Fibonacci 0.5 / 0.618 Lines"
const string t_fibCol         = "Fibonacci Line Color"

const string t_cvdReset       = "CVD Reset Period"
const string opt_cvdSession   = "Session (Daily)"
const string opt_cvdNone      = "None (Cumulative All Time)"

const string t_vpLookback     = "Volume Profile Lookback Bars"
const string t_vpBins         = "Volume Profile Rows (Bins)"

const string t_stShow         = "Show SuperTrend Line"
const string t_stSrcInput     = "SuperTrend Source"
const string t_stAtrLen       = "SuperTrend ATR Length"
const string t_stMult         = "SuperTrend Multiplier"

const string t_bandMode       = "Bands Calculation Mode"
const string t_bandShow1      = "Show Band #1"
const string t_bandMult1      = "Bands Multiplier #1"
const string t_bandShow2      = "Show Band #2"
const string t_bandMult2      = "Bands Multiplier #2"
const string t_bandShow3      = "Show Band #3"
const string t_bandMult3      = "Bands Multiplier #3"

const string t_bandBullLow    = "Band Bull (Low Volume)"
const string t_bandBullHigh   = "Band Bull (High Volume)"
const string t_bandBearLow    = "Band Bear (Low Volume)"
const string t_bandBearHigh   = "Band Bear (High Volume)"

const string t_volShow        = "Show Volume on SuperTrend"
const string t_volStyle       = "Volume Visual Style"
const string t_volSmooth      = "Volume Smoothing (1 = Off)"
const string t_volLookback    = "Volume Reference Range (N Bars)"
const string t_volMult        = "Volume Height Multiplier"
const string t_volSimple      = "Show Simple Volume Label"

const string t_volPos         = "Volume Draw Position"
const string opt_volBoth      = "Both (Bull=Top, Bear=Bot)"
const string opt_volTop       = "Top Only"
const string opt_volBot       = "Bottom Only"
const string opt_volNone      = "None"

const string t_volHighMode    = "Highlight High Volume Only"
const string t_volHighThresh  = "Highlight Volume Threshold (x MA)"

const string t_volBullLow     = "Vol/Env Bull (Low Volume)"
const string t_volBullHigh    = "Vol/Env Bull (High Volume)"
const string t_volBearLow     = "Vol/Env Bear (Low Volume)"
const string t_volBearHigh    = "Vol/Env Bear (High Volume)"
const string t_volGlobalTxt   = "Global Text Size (Auto-Scale)"

const string t_confShow       = "Show Confluence Labels"
const string t_confSens       = "Confluence Sensitivity (1-7)"
const string t_confVolFil     = "Require High Volume (Filter)"
const string t_confAtrFil     = "Require High Volatility (Filter)"

const string opt_volArea      = "Area (Wavy/Spiky)"
const string opt_volStep      = "Step Area (Histogram-like)"
const string opt_bndStdev     = "Standard Deviation"
const string opt_bndPerc      = "Percentage"

const string tip_1 = "Select the visual style of the volume. 'Step Area' creates a blocky, histogram-like appearance."
const string tip_2 = "Increasing this value smooths out sudden volume spikes into a gentle wave."
const string tip_3 = "Outputs a label when the set number of logic conditions (max 7: ST, FVG, CHoCH, Bias, Fib, CVD, POC) are met."
const string tip_4 = "When checked, signals are output only when the current volume exceeds the 20-bar average."
const string tip_5 = "When checked, signals are output only when the candle body is greater than half the ATR."
const string tip_6 = "Determines the unit for calculating the distance of the bands."
const string tip_7 = "Specifies the higher timeframe (e.g., Weekly) used as a baseline for the MTF filter."
const string tip_8 = "Number of rows (bins) for Volume Profile. Higher values increase resolution but require more processing."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Groups {
const string gFvg       = " [ TECHNICAL ] FVG"
const string gCho       = " [ TECHNICAL ] CHoCH"
const string gSmartBias = " [ TECHNICAL ] SMART BIAS (MTF & VSA)"
const string gFibo      = " [ TECHNICAL ] FIBONACCI"
const string gCvd       = " [ TECHNICAL ] CVD & VOLUME PROFILE"
const string gStBase    = " [ TECHNICAL ] SUPERTREND BASE"
const string gVwapBands = " [ TECHNICAL ] BANDS"
const string gVol       = " [ DISPLAY ] CYBER VOLUME"
const string gConf      = " [ SYSTEM ] CONFLUENCE ENGINE"
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
show_fvg = input.bool(true, t_fvgShow, group = gFvg)
col_fvg_bull = input.color(color.new(#2962FF, 0), t_fvgBullCol, group = gFvg)
col_fvg_bear = input.color(color.new(#FF9800, 0), t_fvgBearCol, group = gFvg)

show_choch = input.bool(true, t_chochShow, group = gCho)
pivot_left = input.int(7, t_chochPivL, minval=1, group = gCho)
pivot_right = input.int(7, t_chochPivR, minval=1, group = gCho)
col_choch_bull = input.color(color.new(#00FF00, 0), t_chochBullCol, group = gCho)
col_choch_bear = input.color(color.new(#FF0000, 0), t_chochBearCol, group = gCho)

htf_res = input.timeframe("W", t_biasHtf, group = gSmartBias, tooltip = tip_7)
vsa_period = input.int(25, t_vsaPeriod, minval=5, group = gSmartBias)
rvol_thresh = input.float(2, t_rvolThresh, minval=1.0, step=0.1, group = gSmartBias)

show_fib = input.bool(false, t_fibShow, group = gFibo)
col_fib = input.color(color.new(color.gray, 50), t_fibCol, group = gFibo)

cvd_reset = input.string(opt_cvdSession, t_cvdReset, options=[opt_cvdSession, opt_cvdNone], group = gCvd)
vp_lookback = input.int(200, t_vpLookback, minval=50, maxval=500, group = gCvd)
vp_bins = input.int(100, t_vpBins, minval=10, maxval=100, group = gCvd, tooltip = tip_8)

show_st = input.bool(true, t_stShow, group = gStBase)
st_src_input = input.source(hl2, t_stSrcInput, group = gStBase)
st_atr_len = input.int(10, t_stAtrLen, group = gStBase)
st_mult = input.float(3.0, t_stMult, group = gStBase, step = 0.5)

calcModeInput = input.string(opt_bndStdev, t_bandMode, options = [opt_bndStdev, opt_bndPerc], group = gVwapBands, tooltip = tip_6)
showBand_1 = input.bool(true, t_bandShow1, group = gVwapBands)
bandMult_1 = input.float(1.0, t_bandMult1, group = gVwapBands, step = 0.5, minval=0)

showBand_2 = input.bool(true, t_bandShow2, group = gVwapBands)
bandMult_2 = input.float(2.0, t_bandMult2, group = gVwapBands, step = 0.5, minval=0)

showBand_3 = input.bool(true, t_bandShow3, group = gVwapBands)
bandMult_3 = input.float(3.0, t_bandMult3, group = gVwapBands, step = 0.5, minval=0)

col_band_bull_low = input.color(color.new(#006064, 85), t_bandBullLow, group = gVwapBands)
col_band_bull_high = input.color(color.new(#00BCD4, 60), t_bandBullHigh, group = gVwapBands)
col_band_bear_low = input.color(color.new(#4A148C, 85), t_bandBearLow, group = gVwapBands)
col_band_bear_high = input.color(color.new(#9C27B0, 60), t_bandBearHigh, group = gVwapBands)

show_vol = input.bool(true, t_volShow, group = gVol)
vol_pos = input.string(opt_volBoth, t_volPos, options=[opt_volBoth, opt_volTop, opt_volBot, opt_volNone], group = gVol)
vol_style = input.string(opt_volArea, t_volStyle, options=[opt_volArea, opt_volStep], group = gVol, tooltip = tip_1)
vol_smooth = input.int(1, t_volSmooth, minval=1, maxval=50, group = gVol, tooltip = tip_2)
lookback_bars = input.int(200, t_volLookback, minval=1, maxval=500, group = gVol)
vol_mult = input.float(10.0, t_volMult, minval=0.1, step=0.1, group = gVol)

vol_high_mode = input.bool(true, t_volHighMode, group = gVol)
vol_high_thresh = input.float(1.5, t_volHighThresh, minval=0.1, step=0.1, group = gVol)

col_vol_bull_low = input.color(color.new(#006400, 60), t_volBullLow, group = gVol)
col_vol_bull_high = input.color(color.new(#00FF00, 10), t_volBullHigh, group = gVol)
col_vol_bear_low = input.color(color.new(#8B0000, 60), t_volBearLow, group = gVol)
col_vol_bear_high = input.color(color.new(#FF0000, 10), t_volBearHigh, group = gVol)

show_simple_vol = input.bool(true, t_volSimple, group = gVol)
global_txt_size = input.string(size.auto, t_volGlobalTxt, options=[size.auto, size.tiny, size.small, size.normal, size.large, size.huge], group = gVol)

show_conf_lbl = input.bool(true, t_confShow, group = gConf)
conf_sens = input.int(5, t_confSens, minval=1, maxval=7, group = gConf, tooltip = tip_3)
use_vol_filter = input.bool(true, t_confVolFil, group = gConf, tooltip = tip_4)
use_atr_filter = input.bool(true, t_confAtrFil, group = gConf, tooltip = tip_5)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Internal Variables {
const int lblCap = 480
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Helpers {
isBullFvg(float l0, float h2) => l0 > h2
isBearFvg(float h0, float l2) => h0 < l2

addLabel(array<label> ids, int t, float y, string txt, string styleStr, color col, color txtCol, string sz) =>
    while ids.size() > lblCap - 2
        old = ids.shift()
        old.delete()
    
    lblStyle = styleStr == "none" ? label.style_none : styleStr == "up" ? label.style_label_up : label.style_label_down
    loc = styleStr == "none" ? yloc.price : styleStr == "up" ? yloc.belowbar : yloc.abovebar
    
    id = label.new(
         x = t,
         y = styleStr == "none" ? y : na,
         text = txt,
         xloc = xloc.bar_time,
         yloc = loc,
         color = col,
         style = lblStyle,
         textcolor = txtCol,
         size = sz,
         force_overlay = true)
    ids.push(id)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ FVG & CHoCH {
is_bullish_fvg = isBullFvg(low[0], high[2])
is_bearish_fvg = isBearFvg(high[0], low[2])
final_fvg_color = show_fvg ? (is_bullish_fvg ? col_fvg_bull : (is_bearish_fvg ? col_fvg_bear : na)) : na
barcolor(final_fvg_color, offset=-1, title="FVG Candle")

float ph = ta.pivothigh(high, pivot_left, pivot_right)
float pl = ta.pivotlow(low, pivot_left, pivot_right)

var float last_ph = na
var float last_pl = na

if not na(ph)
    last_ph := ph
if not na(pl)
    last_pl := pl

bull_choch = ta.crossover(close, last_ph)
bear_choch = ta.crossunder(close, last_pl)
final_choch_color = show_choch ? (bull_choch ? col_choch_bull : (bear_choch ? col_choch_bear : na)) : na

barcolor(final_choch_color, title="CHoCH Candle")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Smart Bias Engine (MTF & VSA) {
// 1. HTF Market Structure (Higher Timeframe Trend Detection)
float htf_ema = request.security(syminfo.tickerid, htf_res, ta.ema(close, 20), lookahead=barmerge.lookahead_off)
float htf_close = request.security(syminfo.tickerid, htf_res, close, lookahead=barmerge.lookahead_off)

int htf_trend = 0
if htf_close > htf_ema
    htf_trend := 1
else if htf_close < htf_ema
    htf_trend := -1

// 2. VSA Effort vs Result (Volume and Spread Correlation)
float spread = math.abs(high - low)
float avg_spread = ta.sma(spread, vsa_period)
float rvol = volume / ta.sma(volume, vsa_period)

int vsa_signal = 0
// Consider the direction with volume > N times average and spread > average as 'institutional inflow'
if rvol > rvol_thresh and spread > avg_spread
    vsa_signal := close > open ? 1 : -1

int smart_bias = 0
// Apply bias only when HTF trend aligns with execution timeframe volume/spread pressure
if htf_trend == 1 and vsa_signal != -1
    smart_bias := 1
else if htf_trend == -1 and vsa_signal != 1
    smart_bias := -1
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Fibonacci Calculations {
float fib_range = na(last_ph) or na(last_pl) ? 0.0 : (last_ph - last_pl)
bool is_up_swing = last_ph > last_pl 

// Adjust Fibonacci reference based on upward/downward swing
float fib_0500 = is_up_swing ? (last_ph - (fib_range * 0.500)) : (last_pl + (math.abs(fib_range) * 0.500))
float fib_0618 = is_up_swing ? (last_ph - (fib_range * 0.618)) : (last_pl + (math.abs(fib_range) * 0.618))

plot(show_fib ? fib_0500 : na, title="Fib 0.5", color=col_fib, style=plot.style_circles)
plot(show_fib ? fib_0618 : na, title="Fib 0.618", color=col_fib, style=plot.style_cross)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ CVD & Volume Profile (Calculations) {
float delta_vol = close > open ? volume : close < open ? -volume : 0.0
var float current_cvd = 0.0

bool is_new_session = timeframe.change("D")
if cvd_reset == opt_cvdSession and is_new_session
    current_cvd := delta_vol
else
    current_cvd += delta_vol

// Update POC every bar using pure array calculations without drawing heavy objects
float vp_highest = ta.highest(high, vp_lookback)
float vp_lowest = ta.lowest(low, vp_lookback)
float bin_size = (vp_highest - vp_lowest) / vp_bins

array<float> vol_bins = array.new_float(vp_bins, 0.0)

// Aggregate volume for past vp_lookback bars into array (loop for past reference due to Pine specs)
if barstate.isconfirmed
    for i = 0 to vp_lookback - 1
        float typ_price = hlc3[i]
        int bin_index = math.floor((typ_price - vp_lowest) / bin_size)
        
        if bin_index >= vp_bins
            bin_index := vp_bins - 1
        if bin_index < 0
            bin_index := 0
            
        float cv = array.get(vol_bins, bin_index)
        array.set(vol_bins, bin_index, cv + volume[i])

float max_bin_vol = 0.0
int poc_index = 0

if barstate.isconfirmed
    for i = 0 to vp_bins - 1
        float v = array.get(vol_bins, i)
        if v > max_bin_vol
            max_bin_vol := v
            poc_index := i

float poc_price = vp_lowest + (poc_index * bin_size) + (bin_size / 2.0)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ SuperTrend Logic {
float baseValue = st_src_input
float atr_st = ta.atr(st_atr_len)
float basic_ub = baseValue + st_mult * atr_st
float basic_lb = baseValue - st_mult * atr_st

var float final_ub = na
var float final_lb = na

final_ub := na(final_ub[1]) ? basic_ub : (basic_ub < final_ub[1] or close[1] > final_ub[1] ? basic_ub : final_ub[1])
final_lb := na(final_lb[1]) ? basic_lb : (basic_lb > final_lb[1] or close[1] < final_lb[1] ? basic_lb : final_lb[1])

int st_dir = 1
st_dir := na(st_dir[1]) ? 1 : (st_dir[1] == 1 and close < final_lb ? -1 : (st_dir[1] == -1 and close > final_ub ? 1 : st_dir[1]))
float st_line = st_dir == 1 ? final_lb : final_ub

float bandBasis = calcModeInput == opt_bndStdev ? ta.stdev(close, 20) : st_line * 0.01
float upperBandValue1 = st_line + bandBasis * bandMult_1
float lowerBandValue1 = st_line - bandBasis * bandMult_1
float upperBandValue2 = st_line + bandBasis * bandMult_2
float lowerBandValue2 = st_line - bandBasis * bandMult_2
float upperBandValue3 = st_line + bandBasis * bandMult_3
float lowerBandValue3 = st_line - bandBasis * bandMult_3
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Cyber Gradient Calculations {
float atr_val = ta.atr(14)
float raw_vol = volume
float smoothed_vol = ta.sma(raw_vol, vol_smooth)
float max_vol = ta.highest(smoothed_vol, lookback_bars)
float vol_ratio = max_vol > 0 ? (smoothed_vol / max_vol) : 0.0

color vol_cyber_bull_grad = color.from_gradient(vol_ratio, 0.0, 1.0, col_vol_bull_low, col_vol_bull_high)
color vol_cyber_bear_grad = color.from_gradient(vol_ratio, 0.0, 1.0, col_vol_bear_low, col_vol_bear_high)
color vol_cyber_color = st_dir == 1 ? vol_cyber_bull_grad : vol_cyber_bear_grad

color band_cyber_bull_grad = color.from_gradient(vol_ratio, 0.0, 1.0, col_band_bull_low, col_band_bull_high)
color band_cyber_bear_grad = color.from_gradient(vol_ratio, 0.0, 1.0, col_band_bear_low, col_band_bear_high)
color band_fill_color = show_st ? (st_dir == 1 ? band_cyber_bull_grad : band_cyber_bear_grad) : na
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Bands Drawing {
upperBand_1 = plot(showBand_1 ? upperBandValue1 : na, title="Upper Band #1", color = color.new(color.gray, 80))
lowerBand_1 = plot(showBand_1 ? lowerBandValue1 : na, title="Lower Band #1", color = color.new(color.gray, 80))
fill(upperBand_1, lowerBand_1, title="Bands Fill #1", color = band_fill_color)

upperBand_2 = plot(showBand_2 ? upperBandValue2 : na, title="Upper Band #2", color = color.new(color.gray, 80))
lowerBand_2 = plot(showBand_2 ? lowerBandValue2 : na, title="Lower Band #2", color = color.new(color.gray, 80))
fill(upperBand_2, lowerBand_2, title="Bands Fill #2", color = band_fill_color)

upperBand_3 = plot(showBand_3 ? upperBandValue3 : na, title="Upper Band #3", color = color.new(color.gray, 80))
lowerBand_3 = plot(showBand_3 ? lowerBandValue3 : na, title="Lower Band #3", color = color.new(color.gray, 80))
fill(upperBand_3, lowerBand_3, title="Bands Fill #3", color = band_fill_color)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Cyber Volume & Envelope Rendering {
plot(show_st ? st_line : na, title = "SuperTrend Line", color = vol_cyber_color, linewidth=2)

float scale_factor = max_vol > 0 ? (atr_val * vol_mult) / max_vol : 0
float vol_scaled = smoothed_vol * scale_factor

float vol_sma_20 = ta.sma(volume, 20)
bool show_this_vol = not vol_high_mode or (smoothed_vol >= (vol_sma_20 * vol_high_thresh))
float effective_vol = show_this_vol ? vol_scaled : 0.0

is_bull_candle = close >= open
float vol_env_dist = atr_val * vol_mult
float vol_base_top = st_line + vol_env_dist
float vol_base_bot = st_line - vol_env_dist

float vol_tip_top = vol_base_top
float vol_tip_bot = vol_base_bot

if vol_pos == opt_volBoth
    vol_tip_top := not is_bull_candle ? vol_base_top - effective_vol : vol_base_top
    vol_tip_bot := is_bull_candle ? vol_base_bot + effective_vol : vol_base_bot
else if vol_pos == opt_volTop
    vol_tip_top := vol_base_top - effective_vol
else if vol_pos == opt_volBot
    vol_tip_bot := vol_base_bot + effective_vol

bool is_area = vol_style == opt_volArea
bool is_step = vol_style == opt_volStep
bool do_draw_vol = vol_pos != opt_volNone and show_vol and show_st

color color_env_top_final = show_vol and show_st ? vol_cyber_color : na
color color_env_bot_final = show_vol and show_st ? vol_cyber_color : na
p_vol_env_top = plot(show_vol and show_st ? vol_base_top : na, title="Vol Envelope Top", color=color_env_top_final, style=plot.style_line)
p_vol_env_bot = plot(show_vol and show_st ? vol_base_bot : na, title="Vol Envelope Bot", color=color_env_bot_final, style=plot.style_line)

color top_area_col = do_draw_vol and is_area ? vol_cyber_bear_grad : na
color bot_area_col = do_draw_vol and is_area ? vol_cyber_bull_grad : na
color top_step_col = do_draw_vol and is_step ? vol_cyber_bear_grad : na
color bot_step_col = do_draw_vol and is_step ? vol_cyber_bull_grad : na

p_vol_tip_top_area = plot(do_draw_vol and is_area ? vol_tip_top : na, title="Top Vol Tip Area", color=vol_cyber_bear_grad, style=plot.style_line)
p_vol_tip_bot_area = plot(do_draw_vol and is_area ? vol_tip_bot : na, title="Bot Vol Tip Area", color=vol_cyber_bull_grad, style=plot.style_line)
fill(p_vol_env_top, p_vol_tip_top_area, color=top_area_col, title="Fill Top Area")
fill(p_vol_env_bot, p_vol_tip_bot_area, color=bot_area_col, title="Fill Bot Area")

p_vol_tip_top_step = plot(do_draw_vol and is_step ? vol_tip_top : na, title="Top Vol Tip Step", color=vol_cyber_bear_grad, style=plot.style_stepline)
p_vol_tip_bot_step = plot(do_draw_vol and is_step ? vol_tip_bot : na, title="Bot Vol Tip Step", color=vol_cyber_bull_grad, style=plot.style_stepline)
fill(p_vol_env_top, p_vol_tip_top_step, color=top_step_col, title="Fill Top Step")
fill(p_vol_env_bot, p_vol_tip_bot_step, color=bot_step_col, title="Fill Bot Step")

var volLbls = array.new<label>()
color vol_text_color = is_bull_candle ? vol_cyber_bull_grad : vol_cyber_bear_grad

if show_simple_vol and barstate.isconfirmed
    addLabel(volLbls, time, low - (atr_val * 0.5), str.tostring(volume, format.volume), "none", color.new(color.white, 100), vol_text_color, global_txt_size)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Confluence Engine {
bool vol_cond = volume > vol_sma_20
float current_body = math.abs(close - open)
bool atr_cond = current_body > (atr_val * 0.5)

// Score strength/weakness with 7 elements (ST, FVG, CHoCH, SmartBias, Fib, CVD, POC)
int bull_score = (is_bullish_fvg ? 1 : 0) + (bull_choch ? 1 : 0) + (smart_bias == 1 ? 1 : 0) + (st_dir == 1 ? 1 : 0) + (close > fib_0500 ? 1 : 0) + (current_cvd > 0 ? 1 : 0) + (close > poc_price ? 1 : 0)
int bear_score = (is_bearish_fvg ? 1 : 0) + (bear_choch ? 1 : 0) + (smart_bias == -1 ? 1 : 0) + (st_dir == -1 ? 1 : 0) + (close < fib_0500 ? 1 : 0) + (current_cvd < 0 ? 1 : 0) + (close < poc_price ? 1 : 0)

bool base_bull_conf = bull_score >= conf_sens
bool base_bear_conf = bear_score >= conf_sens

bool final_bull_conf = base_bull_conf and (use_vol_filter ? vol_cond : true) and (use_atr_filter ? atr_cond : true)
bool final_bear_conf = base_bear_conf and (use_vol_filter ? vol_cond : true) and (use_atr_filter ? atr_cond : true)

var confLbls = array.new<label>()
if show_conf_lbl and final_bull_conf
    addLabel(confLbls, time, na, "BUY", "up", color.new(#089981, 0), color.white, size.small)

if show_conf_lbl and final_bear_conf
    addLabel(confLbls, time, na, "SELL", "down", color.new(#F23645, 0), color.white, size.small)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
