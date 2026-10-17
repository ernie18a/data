# Super trend Fractal by Santiago Rebello

- url: https://www.tradingview.com/script/WCS6RxgC-Super-trend-Fractal-by-Santiago-Rebello/
- type: indicator
- pine_id: PUB;7707cb9bf39f475cbd4e94b820932565
- version: 1.0

## Description

Mathematical Specifications & Signal Mechanics1. Volatility & Dynamic Trailing EngineThe volatility tracking engine is established using a modified True Range algorithm, filtered through a Wilder's Moving Average. The default values are tuned to ATRPeriod = 10 and ATRFactor = 14.True Range Modification:To account for extreme market gaps, the engine compares the standard high-to-low spread against an expanded average calculation, selecting the higher boundary to build a clean tracking cushion:$$\text{HiLo} = \min\left(\text{High} - \text{Low}, 1.5 \times \text{SMA}(\text{High} - \text{Low}, \text{Period})\right)$$Trailing Stop Line (trail):The calculated loss factor is projected as an offset band relative to the closing price ($14 \times \text{ATR}$). When the asset closes beyond the previous boundary, the system identifies a structural trend shift, flipping the thick trailing line (linewidth = 3) from Green (Bullish) to Red (Bearish).Dynamic Retracements:The script measures the vertical distance between the absolute trend extremum (ex) and the active trailing stop (trail). It marks three critical Fibonacci expansion nodes directly on the chart profile:Retracement 1: $61.8\%$Retracement 2: $78.6\%$Retracement 3: $88.6\%$2. Statistical Percentile ChannelThe breakout engine completely bypasses standard price-averaging formulas, relying instead on a historical ranking distribution across a 45-bar rolling lookback window.Envelope Thresholds:The channel uses nearest-rank percentiles to plot strict multi-period boundaries (Upper Line = 45.0%, Lower Line = 36.0%).Pattern Validation:The system identifies internal expansion setups based on strict multi-candle body definitions. Signals trigger only when candlestick body expansions meet or exceed a specific proportional weight ($0.66 \times \text{Total Candle Range}$).Signal Placement:Structural Buy Points (Olive/Green Shapes): Print when a valid bullish pattern establishes itself entirely below the statistical lower percentile line.Structural Sell Points (Maroon/Red Shapes): Print when a valid bearish pattern establishes itself entirely above the statistical upper percentile line.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Supertrend Retracement Indicator", overlay = true)

// ==========================================
// 1. VOLATILITY ENGINE INPUTS & SECURITY
// ==========================================
trailType        = input.string("modified", "Trailtype", options = ["modified", "unmodified"])
ATRPeriod        = input.int(10, "ATR Period")
ATRFactor        = input.int(14, "ATR Factor")

// Fetch security data safely
ticker_string = ticker.new(syminfo.prefix, syminfo.ticker)
norm_o = request.security(ticker_string, timeframe.period, open)
norm_h = request.security(ticker_string, timeframe.period, high)
norm_l = request.security(ticker_string, timeframe.period, low)
norm_c = request.security(ticker_string, timeframe.period, close)

// ==========================================
// 2. PERCENTILE ENVELOPE INPUTS & DATA
// ==========================================
n                   = input.int(title="Structural Periods", defval=2, minval=2)
length              = input.int(defval=45, minval=1, title="Lookback Period")
upperPercentilePlot = input.float(45.0, title="Upper Percentile Threshold")
lowerPercentilePlot = input.float(36.0, title="Lower Percentile Threshold")   
src                 = input.source(close, title="Source")

// ==========================================
// 3. CORE VOLATILITY TRACKING
// ==========================================
Wild_ma(_src, _malength) =>
    var float _wild = 0.0
    _wild := nz(_wild[1]) + (_src - nz(_wild[1])) / _malength
    _wild

f_fixnan(series_val) =>
    var float last_valid = na
    if not na(series_val)
        last_valid := series_val
    last_valid

HiLo = math.min(norm_h - norm_l, 1.5 * nz(ta.sma((norm_h - norm_l), ATRPeriod)))
HRef = norm_l <= norm_h[1] ? norm_h - norm_c[1] : (norm_h - norm_c[1]) - 0.5 * (norm_l - norm_h[1])
LRef = norm_h >= norm_l[1] ? norm_c[1] - norm_l : (norm_c[1] - norm_l) - 0.5 * (norm_l[1] - norm_h)

trueRange = trailType == "modified" ? math.max(HiLo, HRef, LRef) : math.max(norm_h - norm_l, math.abs(norm_h - norm_c[1]), math.abs(norm_l - norm_c[1]))

loss = ATRFactor * Wild_ma(trueRange, ATRPeriod)
Up = norm_c - loss
Dn = norm_c + loss

var float TrendUp = Up
var float TrendDown = Dn
var int Trend = 1

TrendUp   := norm_c[1] > TrendUp[1]   ? math.max(Up, TrendUp[1])   : Up
TrendDown := norm_c[1] < TrendDown[1] ? math.min(Dn, TrendDown[1]) : Dn

Trend := norm_c > TrendDown[1] ? 1 : norm_c < TrendUp[1] ? -1 : nz(Trend[1], 1)
trail = Trend == 1 ? TrendUp : TrendDown

var float ex = 0.0
ex := ta.crossover(Trend, 0) ? norm_h : ta.crossunder(Trend, 0) ? norm_l : Trend == 1 ? math.max(ex[1], norm_h) : Trend == -1 ? math.min(ex[1], norm_l) : ex[1]

plot(trail, "Trailing Stop", style = plot.style_line, color = Trend == 1 ? color.green : Trend == -1 ? color.red : na, linewidth = 3)
plot(ex, "Extremum Level", style = plot.style_circles, color = Trend == 1 ? color.lime : Trend == -1 ? color.fuchsia : na)

state = Trend == 1 ? "long" : "short"
fib1Level = 61.8
fib2Level = 78.6
fib3Level = 88.6

f1 = ex + (trail - ex) * fib1Level / 100
f2 = ex + (trail - ex) * fib2Level / 100
f3 = ex + (trail - ex) * fib3Level / 100
l100 = trail + 0

plot(f1,   "Retracement 1", style = plot.style_line, color = color.black)
plot(f2,   "Retracement 2", style = plot.style_line, color = color.black)
plot(f3,   "Retracement 3", style = plot.style_line, color = color.black)
plot(l100, "Base Level", style = plot.style_line, color = color.black)

// ==========================================
// 4. STATISTICAL BREAKOUT ENGINE
// ==========================================
cr = math.abs(close - open)
isUp = close > open 
isDown = close < open

median_high = ta.percentile_nearest_rank(src, length, upperPercentilePlot)
median_low = ta.percentile_nearest_rank(src, length, lowerPercentilePlot)

plot(median_high, "Envelope Upper Line", color = color.maroon, linewidth = 2)
plot(median_low, "Envelope Lower Line", color = color.lime, linewidth = 2)

downUPup = true
downDOWNup = true
for i = 1 to n
    downUPup := downUPup and isUp[n-1] and isUp[n] and isDown[n+1] and (close[n-i] > close[n]) and cr[n-1] >= cr[n+1] * 0.66
    downDOWNup := downDOWNup and isUp[n-1] and isDown[n] and isDown[n+1] and (close[n-i] > close[n]) and cr[n-1] >= cr[n+1] * 0.66

upFractal1 = (downUPup and close < median_low)
upFractal2 = (downDOWNup and close < median_low)

plotshape(upFractal1, "Structural Buy 1", style=shape.triangleup, location=location.belowbar, offset = -n, color=color.olive, size = size.small)
plotshape(upFractal2, "Structural Buy 2", style=shape.triangleup, location=location.belowbar, offset = -n, color=color.green, size = size.small)

upUPdown = true
upDOWNdown = true
for i = 1 to n
    upUPdown := upUPdown and isDown[n-1] and isUp[n] and isUp[n+1] and (close[n-i] < close[n]) and cr[n-1] >= cr[n+1] * 0.66
    upDOWNdown := upDOWNdown and isDown[n-1] and isDown[n] and isUp[n+1] and (close[n-i] < close[n]) and cr[n-1] >= cr[n+1] * 0.66
    
downFractal1 = (upUPdown and close > median_high)
downFractal2 = (upDOWNdown and close > median_high)

plotshape(downFractal1, "Structural Sell 1", style=shape.triangledown, location=location.abovebar, offset = -n, color=color.maroon, size = size.small)
plotshape(downFractal2, "Structural Sell 2", style=shape.triangledown, location=location.abovebar, offset = -n, color=color.red, size = size.small)

// ==========================================
// 5. AUTOMATED LLM PAYLOAD GENERATOR
// ==========================================
is_buy_signal  = upFractal1 or upFractal2
is_sell_signal = downFractal1 or downFractal2
is_trend_flip  = ta.change(Trend) != 0

alert_msg = '{"ticker": "' + syminfo.ticker + '", "price": ' + str.tostring(close) + ', "timeframe": "' + timeframe.period + '"'

if is_buy_signal
    alert_msg := alert_msg + ', "event": "BULLISH_BREAKOUT", "action": "ANALYSIS_REQUEST", "sentiment_bias": "LONG", "structural_support": ' + str.tostring(median_low) + '}'
else if is_sell_signal
    alert_msg := alert_msg + ', "event": "BEARISH_BREAKOUT", "action": "ANALYSIS_REQUEST", "sentiment_bias": "SHORT", "structural_resistance": ' + str.tostring(median_high) + '}'
else if is_trend_flip
    alert_msg := alert_msg + ', "event": "TREND_DIRECTION_CHANGE", "action": "RISK_UPDATE", "new_trend": "' + (Trend == 1 ? "BULLISH" : "BEARISH") + '", "trailing_stop": ' + str.tostring(trail) + '}'
else
    alert_msg := alert_msg + ', "event": "GENERIC_DATA_STREAM"}'

alert_condition = is_buy_signal or is_sell_signal or is_trend_flip
alert(alert_msg, alert.freq_once_per_bar_close)
````
