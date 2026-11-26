# VPA + HA + BDTL STRATEGY

- url: https://www.tradingview.com/script/Qq9ZwIm5-VPA-HA-BDTL-STRATEGY/
- type: strategy
- pine_id: PUB;41aaf060ada844aa93eff23663059884
- version: 8.0

## Description

[b]VPA + HA + BDTL STRATEGY: Institutional Breakout with Volume[/b]

[b]The Philosophy[/b]
Most retail traders lose money because they trade the "noise." They buy random dips, get shaken out by tiny red wicks, and completely ignore the footprint of institutional money (Volume).

Designed for traders who want to treat the markets like a highly structured business, this script fuses three of the most powerful concepts in quantitative trading into one automated system: Anna Coulling's Volume Price Analysis (VPA), Heikin Ashi (HA) Trend Smoothing, and Automated Structural Down-Trend Line (DTL) Breakouts.

This is not a "get rich quick" indicator. It is a highly restrictive "Sniper" system that forces you to sit on your hands until the perfect storm of Price Action, Momentum, and Volume aligns.

[b]🏛️ The Three Pillars of the Engine
[/b]

[b]1. Heikin Ashi (HA) Momentum Filtering[/b]
Standard candlesticks lie to you with volatility. This script calculates Heikin Ashi values internally to find the "pure" trend.

It explicitly scans for "Flat Bottoms" (zero lower wicks on green candles) to confirm maximum bullish momentum.

It features a "Trend Life Counter" that tracks the exact age of a trend, keeping you out of exhausted, late-stage FOMO entries.

[b]2. Volume Price Analysis (VPA) Validation[/b]
A breakout without volume is a trap. The script uses a customizable Volume Threshold (default 1.2x the 20-day SMA).

Effort vs. Result: A buy signal will not fire unless the institutional effort (Volume Spike) matches the result (Price Breakout).

[b]3. Automated Structural DTL (Down-Trend Line)[/b]
Forget manually drawing subjective lines. The script's array scanner memorizes the last 5 major pivot highs, identifies the absolute peak (Anchor), finds the next prominent lower high (Trigger), and draws a structural, diagonal resistance line extending into the future.

[b]🧰 Key Features & Visual Toolkit[/b]
The Pro Dashboard: A fully customizable, 6-position heads-up display. It gives you live intelligence on the HA Trend Life, DTL Status, Volume Strength, RSI (14), and an AI-driven "Action Plan" (e.g., EXECUTE BUY, HOLD POSITION, STAY OUT).

Dynamic Institutional Volume Scaler: Overlays scaled volume bars and a Volume Moving Average directly onto the bottom 15% of your price chart, allowing you to read the tape without taking your eyes off the price action.

Smart Hybrid Mode: If a stock goes parabolic and no downward structure exists, the script automatically defaults to a 50 EMA baseline filter so you never miss a primary trend entry.

[b]🎯 The Sniper Playbook (How to Trade It)[/b]
The Long Entry (Buy):
Wait for the Green "BUY HA" label to appear below the candle. This guarantees:

Price has shattered the Red Dashed DTL (or the 50 EMA in hybrid mode).

The Volume Bar is spiking above its moving average.

The internal Heikin Ashi candle is Green with a perfect Flat Bottom.
(Pro Tip: Check the Dashboard. Only take entries if the "HA Trend Life" is young, ideally between 1 and 5 bars).

The Exit (Sell):
Wait for the Red "SELL HA" label. This triggers when:

The Heikin Ashi trend flips Red with a "Flat Top".

Volume validates the selling pressure.

Price breaks down below the structural EMA trend.

[b]⚙️ Customization[/b]
This script is built to adapt to your specific market (Crypto, US Tech, or Bursa Malaysia). Open the settings to adjust the Volume Spike Factor (lower it for illiquid stocks, raise it for volatile ones) or toggle the Wick Tolerance for markets prone to micro-wicks.

[b](Disclaimer: This script is an analytical tool, not financial advice. Always use strict risk management and backtest thoroughly on your specific tickers before deploying real capital.)[/b]

#VPA #VolumePriceAnalysis #HeikinAshi #Trendline #BreakoutStrategy #SwingTrading #RSI #EMA #SmartMoney #SniperEntry #AlgorithmicTrading #TrendLife

## Source Code

````pine
//@version=6
strategy("VPA + BDTL + VOLUME v10.0", overlay=true, calc_on_every_tick=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.05)

// ==========================================
// 1. 🛠️ SETTINGS
// ==========================================
grp_vpa = "VPA Sniper Settings"
vol_multiplier  = input.float(1.2, "Volume Spike Factor", step=0.1, group=grp_vpa)
spread_mult     = input.float(1.1, "Wide Spread Factor", step=0.1, group=grp_vpa)

grp_dtl = "Structural DTL Settings"
pivot_lookback  = input.int(10, "DTL Pivot Strength", minval=3, group=grp_dtl)

grp_trade = "Trade Management"
tsl_mult        = input.float(2.0, "TSL Sensitivity (ATR Mult)", step=0.1, group=grp_trade)

grp_vis = "Dashboard & Visuals"
dash_pos_input  = input.string("Top Right", "Dashboard Position", options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"], group=grp_vis)

// ==========================================
// 2. 📊 GLOBAL MATH (CALCULATED EVERY BAR)
// ==========================================
vol_avg = ta.sma(volume, 20)
is_high_vol = volume > (vol_avg * vol_multiplier)
spread = high - low
avg_spread = ta.sma(spread, 20)
is_wide_spread = spread > (avg_spread * spread_mult)
is_narrow_spread = spread < (avg_spread * 0.7)

// Indicators
rsi_val = ta.rsi(close, 14)
ema_slow = ta.ema(close, 50)
atr = ta.atr(14)

// VPA Logic (Anna Coulling)
vpa_bull_valid = (close > open) and is_high_vol and is_wide_spread
vpa_bear_valid = (close < open) and is_high_vol and is_wide_spread
vpa_squat_anomaly = is_high_vol and is_narrow_spread

// Wick Pressure Logic
body_size = math.abs(close - open)
lower_wick = math.min(open, close) - low
upper_wick = high - math.max(open, close)
bool buying_pressure = lower_wick > (body_size * 2) and is_high_vol
bool selling_pressure = upper_wick > (body_size * 2) and is_high_vol

// Trend Strength Logic
ema_slope = (ema_slow - ema_slow[5]) / ema_slow[5] * 100
string trend_strength = ema_slope > 0.1 ? "STRONG BULL" : ema_slope > 0 ? "WEAK BULL" : ema_slope > -0.1 ? "WEAK BEAR" : "STRONG BEAR"
color trend_color = ema_slope > 0.1 ? color.green : ema_slope > 0 ? color.lime : ema_slope > -0.1 ? color.orange : color.red

// ==========================================
// 3. 📐 STRUCTURAL DTL MATH (GLOBAL)
// ==========================================
float ph = ta.pivothigh(high, pivot_lookback, pivot_lookback)
var float p1_y = na, var int p1_x = na
var float p2_y = na, var int p2_x = na

if not na(ph)
    p2_y := p1_y
    p2_x := p1_x
    p1_y := ph
    p1_x := bar_index[pivot_lookback]

bool dtl_exists = not na(p1_y) and not na(p2_y) and p1_y < p2_y
float slope = dtl_exists ? (p1_y - p2_y) / (p1_x - p2_x) : na
float dtl_current_price = dtl_exists ? p1_y + (slope * (bar_index - p1_x)) : na

// Global crossover calculation to avoid compiler warnings
bool is_crossing_dtl = ta.crossover(close, dtl_current_price)
bool dtl_breakout_confirmed = dtl_exists and is_crossing_dtl

// Trendline Drawing
var line trend_line = na
if dtl_exists
    line.delete(trend_line)
    trend_line := line.new(p2_x, p2_y, bar_index, dtl_current_price, color=color.new(color.red, 30), width=2, style=line.style_dashed, extend=extend.right)

// ==========================================
// 4. 🎯 STRATEGY EXECUTION & ALERTS
// ==========================================
buy_signal = vpa_bull_valid and dtl_breakout_confirmed and (ema_slope > -0.05)

float long_stop_calc = close - (atr * tsl_mult)
var float tsl_price = na

if strategy.position_size > 0
    tsl_price := math.max(na(tsl_price) ? 0 : tsl_price, long_stop_calc)
else
    tsl_price := na

// Strategy Execution with Dynamic Alerts
if buy_signal
    strategy.entry("Sniper Long", strategy.long, alert_message = "BUY ALERT: " + syminfo.ticker + " VPA+DTL Breakout confirmed at " + str.tostring(close))

if strategy.position_size > 0
    if (close < tsl_price) or vpa_bear_valid
        msg = vpa_bear_valid ? "VPA Bearish Exit" : "Trailing Stop Triggered"
        strategy.close("Sniper Long", comment=msg, alert_message = "EXIT ALERT: " + syminfo.ticker + " " + msg)

// ==========================================
// 5. 🎨 VISUALS & DASHBOARD
// ==========================================
plot(ema_slow, "Institutional Trend", color=trend_color, linewidth=2)
plot(not na(tsl_price) ? tsl_price : na, "TSL", color=color.red, style=plot.style_linebr, linewidth=2)

// Candle Painting
color bar_col = vpa_squat_anomaly ? color.orange : vpa_bull_valid ? #00ffbb : vpa_bear_valid ? #ff1155 : na
barcolor(bar_col)

// Labels
plotshape(dtl_breakout_confirmed, "DTL Break", shape.triangleup, location.belowbar, color=color.yellow, size=size.small, text="VPA+DTL")
plotshape(vpa_squat_anomaly, "Squat", shape.labeldown, location.abovebar, color=color.orange, text="SQUAT", textcolor=color.white, size=size.small)
plotshape(buying_pressure, "Buy Pressure", shape.triangleup, location.belowbar, color=color.green, size=size.tiny)
plotshape(selling_pressure, "Sell Pressure", shape.triangledown, location.abovebar, color=color.red, size=size.tiny)

// Comprehensive Dashboard
var table dash = table.new(dash_pos_input == "Top Right" ? position.top_right : position.bottom_right, 2, 8, bgcolor=color.new(color.black, 40), border_width=1)
if barstate.islast
    sz = size.small
    table.cell(dash, 0, 0, "MASTER VPA v10.0", text_color=color.white, bgcolor=color.blue, text_size=sz)
    table.cell(dash, 1, 0, str.tostring(timeframe.period) + "M", text_color=color.white, bgcolor=color.blue, text_size=sz)
    table.cell(dash, 0, 1, "RSI (14)", text_color=color.white, text_size=sz)
    table.cell(dash, 1, 1, str.tostring(rsi_val, "#.##"), bgcolor=rsi_val > 70 ? color.red : rsi_val < 30 ? color.green : color.gray, text_color=color.white, text_size=sz)
    table.cell(dash, 0, 2, "Trend Strength", text_color=color.white, text_size=sz)
    table.cell(dash, 1, 2, trend_strength, bgcolor=trend_color, text_color=color.white, text_size=sz)
    table.cell(dash, 0, 3, "VPA Status", text_color=color.white, text_size=sz)
    vpa_label = vpa_squat_anomaly ? "SQUAT TRAP" : vpa_bull_valid ? "VALID BULL" : vpa_bear_valid ? "VALID BEAR" : "NEUTRAL"
    table.cell(dash, 1, 3, vpa_label, bgcolor=vpa_squat_anomaly ? color.orange : vpa_bull_valid ? color.green : vpa_bear_valid ? color.red : color.gray, text_color=color.white, text_size=sz)
    table.cell(dash, 0, 4, "AI Suggestion", text_color=color.white, text_size=sz)
    table.cell(dash, 1, 4, buy_signal ? "BUY NOW" : vpa_squat_anomaly ? "CAUTION" : "WAIT", bgcolor=buy_signal ? color.green : vpa_squat_anomaly ? color.orange : color.black, text_color=color.white, text_size=sz)
````
