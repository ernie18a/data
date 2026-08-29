<!-- tradingview-pine-id: PUB;0b9bbafe17754534afddf1a65fcae84b -->
<!-- tradingviewscripts-format: 1 -->
# Custom Multi-Indicator Suite (Vindi Clone) V6

Source: https://www.tradingview.com/script/Rq6wZ96P-Custom-Multi-Indicator-Suite-Vindi-Clone-V6/

## Description

Overview

The Clone Multi-Indicator Suite is an all-in-one algorithmic charting package built natively in Pine Script v6. It consolidates trend direction, localized volatility signals, and key horizontal market structure levels into a single execution layer. By housing multiple tracking tools inside one script, it allows free TradingView accounts to circumvent multi-indicator layout restrictions.Core Structural Features1. Dynamic Trend Ribbon (The Cloud)This serves as the underlying momentum engine of your chart. It acts as a visual filter to prevent you from trading against the dominant market force.How it works: The ribbon calculates the interaction between a Fast Exponential Moving Average (EMA) and a Slow EMA.Bullish Regime: When the fast EMA is above the slow EMA, the ribbon fills with a green cloud, showing a healthy uptrend.Bearish Regime: When the fast EMA drops below the slow EMA, the ribbon fills with a red cloud, showing an active downtrend.2. "Early Buy" & "Early Sell" Volatility AlertsModeled closely after highly popular quantitative scripts like UT Bot Alerts, this module acts as your local execution trigger.How it works: It tracking price action relative to an Average True Range (ATR) trailing stop band. This stop band dynamically expands during heavy market volatility and contracts during tight consolidation.The Triggers:An EARLY BUY label prints right beneath a candle when momentum surges upwards out of its recent volatility band.An EARLY SELL label prints directly above a candle when momentum breaks down past the trailing support barrier.3. Algorithmic Support & Resistance (Liquidity Zones)Instead of manually drawing horizontal levels every session, this module identifies structural turning points using mathematical pivots.How it works: The script scans historical data for a user-defined window of candles (Pivot Strength). When it finds an isolated high or low that hasn't been broken, it maps a precise horizontal line forward across your screen.Red Dashed Line: Represents local institutional resistance (liquidity ceilings).Blue Dashed Line: Represents local institutional support (liquidity floors).

---

## Source Code

````pine
//@version=6
indicator("Custom Multi-Indicator Suite (Vindi Clone) V6", overlay=true, max_labels_count=500)

// ==========================================
// 1. DYNAMIC TREND RIBBON (THE CLOUD)
// ==========================================
var string grp_cloud = "Trend Ribbon Settings"
ma_fast_len = input.int(20, title="Fast Ribbon Length", group=grp_cloud)
ma_slow_len = input.int(50, title="Slow Ribbon Length", group=grp_cloud)

ma_fast = ta.ema(close, ma_fast_len)
ma_slow = ta.ema(close, ma_slow_len)

// Determine the trend direction for coloring the cloud background
trend_bullish = ma_fast > ma_slow
color_cloud   = trend_bullish ? color.new(color.green, 85) : color.new(color.red, 85)

// Plot the ribbon boundaries and fill the space between them
p1 = plot(ma_fast, title="Fast Ribbon Line", color=trend_bullish ? color.green : color.red, linewidth=2)
p2 = plot(ma_slow, title="Slow Ribbon Line", color=trend_bullish ? color.lime : color.maroon, linewidth=1)
fill(p1, p2, color=color_cloud, title="Trend Ribbon Cloud")


// ==========================================
// 2. AUTOMATED BUY/SELL ALERTS (UT BOT ALERTS STYLE)
// ==========================================
var string grp_alerts = "Signal Settings (UT Bot Style)"
src        = input.source(close, title="Signal Source", group=grp_alerts)
key_value  = input.float(2.0, title="Key Value (Sensitivity)", step=0.5, group=grp_alerts)
atr_period = input.int(10, title="ATR Period", group=grp_alerts)

x_atr  = ta.atr(atr_period)
n_loss = key_value * x_atr

// Trailing stop calculation for signal logic using updated V6 functions
var float x_atr_trailing_stop = 0.0
x_atr_trailing_stop := src > nz(x_atr_trailing_stop, 0.0) and src > nz(x_atr_trailing_stop, 0.0) ? math.max(nz(x_atr_trailing_stop), src - n_loss) :
                       src < nz(x_atr_trailing_stop, 0.0) and src < nz(x_atr_trailing_stop, 0.0) ? math.min(nz(x_atr_trailing_stop), src + n_loss) :
                       src > nz(x_atr_trailing_stop, 0.0) ? src - n_loss : src + n_loss

// Position sizing state tracking
var int pos = 0
pos := src > nz(x_atr_trailing_stop, 0.0) and src <= nz(x_atr_trailing_stop, 0.0) ? 1 :
       src < nz(x_atr_trailing_stop, 0.0) and src >= nz(x_atr_trailing_stop, 0.0) ? -1 : nz(pos, 0)

ema_fast_signal = ta.ema(src, 1)

buy_signal  = ta.crossover(ema_fast_signal, x_atr_trailing_stop) and pos == 1
sell_signal = ta.crossunder(ema_fast_signal, x_atr_trailing_stop) and pos == -1

// Plot clean shapes and text labels right above or below the candles
plotshape(buy_signal, title="Early Buy Alert", style=shape.labelup, location=location.belowbar, color=color.green, text="EARLY\nBUY", textcolor=color.white, size=size.small)
plotshape(sell_signal, title="Early Sell Alert", style=shape.labeldown, location=location.abovebar, color=color.red, text="EARLY\nSELL", textcolor=color.white, size=size.small)


// ==========================================
// 3. HORIZONTAL SUPPORT & RESISTANCE (LIQUIDITY LEVELS)
// ==========================================
var string grp_sr = "Support & Resistance Levels"
pivot_len = input.int(15, title="Pivot Window Left/Right Strength", group=grp_sr)

pivot_high = ta.pivothigh(high, pivot_len, pivot_len)
pivot_low  = ta.pivotlow(low, pivot_len, pivot_len)

// Track and update the dynamic support/resistance lines on chart using strict line types
var line res_line = na
var line sup_line = na

if not na(pivot_high)
    line.delete(res_line)
    res_line := line.new(x1=bar_index[pivot_len], y1=pivot_high, x2=bar_index, y2=pivot_high, color=color.red, width=1, style=line.style_dashed)

if not na(pivot_low)
    line.delete(sup_line)
    sup_line := line.new(x1=bar_index[pivot_len], y1=pivot_low, x2=bar_index, y2=pivot_low, color=color.blue, width=1, style=line.style_dashed)

// Extend existing active SR lines continuously forward into the live data session
if not na(res_line)
    line.set_x2(res_line, bar_index)
if not na(sup_line)
    line.set_x2(sup_line, bar_index)
````
