# OCC Strategy Optimized (MA 5 + Delayed TSL)

- url: https://www.tradingview.com/script/oeDm4xHc-OCC-Strategy-Optimized-MA-5-Delayed-TSL/
- type: strategy
- pine_id: PUB;342e34ada62b45f89c4dc04cbbda0eba
- version: 2.0

## Description

# OCC Strategy Optimized (MA 5 + Delayed TSL) - User Guide

## Introduction
The **OCC Strategy Optimized** is an enhanced version of the classic **Open Close Cross (OCC)** strategy. This strategy is designed for high-precision trend following, utilizing the crossover logic of Open and Close moving averages to identify market shifts. This optimized version incorporates advanced risk management, multi-timeframe analysis, and a variety of moving average types to provide a robust trading solution for modern markets.

> [!IMPORTANT]
> **Special Thanks:** This strategy is based on the original work of **JustUncleL**, a renowned Pine Script developer. You can find their work and profile on TradingView here: [JustUncleL's Profile](https://in.tradingview.com/u/JustUncleL/).

---

## Key Features

### 1. Optimized Core Logic
- **MA Period (Default: 5):** The strategy is tuned with a shorter MA length to reduce lag and capture trends earlier.
- **Crossing Logic:** Signals are generated when the Moving Average of the **Close** crosses the Moving Average of the **Open**.

### 2. Multi-Timeframe (MTF) Analysis
- **Alternate Resolution:** Use a higher timeframe (Resolution Multiplier) to filter out noise. By default, it uses $3 \times$ your current chart timeframe to confirm the trend.
- **Non-Repainting:** Includes an optional delay offset to ensure signals are confirmed and do not disappear (repaint) after the bar closes.

### 3. Advanced Risk Management
This script features a hierarchical exit system to protect your capital and lock in profits:
- **Fixed Stop Loss (Initial):** Protects against sudden market reversals immediately after entry.
- **Delayed Trailing Stop Loss (TSL):** 
    - **Activation Delay:** The TSL only activates after the trade reaches a specific profit threshold (e.g., 1%). This prevents being stopped out too early in the trade's development.
    - **Ratchet Trail:** Once activated, the stop loss "ratchets" up/down, never moving backward, ensuring you lock in profits as the trend continues.
- **Take Profit (TP):** A fixed percentage target to exit the trade at a pre-defined profit level.

### 4. Versatility
- **12 MA Types:** Choose from SMA, EMA, DEMA, TEMA, WMA, VWMA, SMMA, HullMA, LSMA, ALMA, SSMA, and TMA.
- **Trade Direction:** Toggle between Long-only, Short-only, or Both.
- **Visuals:** Optional bar coloring to visualize the trend directly on the candlesticks.

---

## User Input Guide

### Core Settings
- **Use Alternate Resolution?:** Enable this to use the MTF logic.
- **Multiplier for Alternate Resolution:** How many charts higher the "filter" timeframe should be.
- **MA Type:** Select your preferred moving average smoothing method.
- **MA Period:** The length of the Open/Close averages.
- **Delay Open/Close MA:** Use `1` or higher to force non-repainting behavior.

### Risk Management Settings
- **Use Trailing Stop Loss?:** Enables the TSL system.
- **Trailing Stop %:** The distance the stop follows behind the price (Optimized Default: 1.5%).
- **TSL Activation % (Delay):** The profit % required before the TSL starts moving. (Optimized Default: 2.0% to ensure 0.5% profit is locked immediately).
- **Initial Fixed Stop Loss %:** Your hard stop if the trade immediately goes against you.
- **Take Profit %:** Your ultimate profit target for the trade.

---

## How to Trade with This Strategy
1. **Identify the Trend:** Look for the Moving Average lines (Close vs Open) to cross.
2. **Wait for Confirmation:** If using MTF, ensure the higher timeframe also shows a trend change.
3. **Manage the Trade:** Let the TSL work. With the default **2.0% Activation** and **1.5% Trail**, the strategy will automatically lock in **0.5% profit** the moment the threshold is hit, then follow the price higher.
4. **Position Sizing:** Adjust the `Properties` tab in the script settings to match your desired capital allocation (Default is 10% of equity).

---

## Recommended Settings

1. Trialing < Activation
2. Check ranging

## Credits
Original Strategy by: **JustUncleL**  
Optimized and Enhanced by: **Antigravity AI**

## Source Code

````pine
// @version=6
// OCC Strategy Optimized (MA 5 + Delayed TSL)
// 
// Special Thanks to the original author: JustUncleL (https://in.tradingview.com/u/JustUncleL/)
// This is an optimized and enhanced version of the original OCC Strategy.
// Features: Optimized defaults, MTF Support, Delayed Trailing Stop Loss, Fixed Stop Loss, and Take Profit.
// Detailed User Guide: Refer to OCC_Optimized_Guide.md
strategy(title = "OCC Strategy Optimized (MA 5 + Delayed TSL)", shorttitle = "OCC Opt", overlay = true, 
  pyramiding = 0, default_qty_type = strategy.percent_of_equity, default_qty_value = 10, initial_capital = 100000, margin_long = 0, margin_short = 0, calc_on_every_tick=false)

// === INPUTS ===
// Optimized Defaults: MA Length = 5
useRes      = input.bool(defval = true, title = "Use Alternate Resolution?")
intRes      = input.float(defval = 3.0, title = "Multiplier for Alernate Resolution", minval = 0.1, step = 0.1)
// V6: timeframe.period replaces interval, timeframe.is* functions
stratRes    = timeframe.ismonthly? str.tostring(timeframe.multiplier*intRes,"###M") : timeframe.isweekly? str.tostring(timeframe.multiplier*intRes,"###W") : timeframe.isdaily?  str.tostring(timeframe.multiplier*intRes,"###D") : timeframe.isintraday ? str.tostring(timeframe.multiplier*intRes,"####") : '60'
basisType   = input.string(defval = "SMMA", title = "MA Type: ", options=["SMA", "EMA", "DEMA", "TEMA", "WMA", "VWMA", "SMMA", "HullMA", "LSMA", "ALMA", "SSMA", "TMA"])
basisLen    = input.int(defval = 5, title = "MA Period", minval = 1) // OPTIMIZED DEFAULT: 5
offsetSigma = input.int(defval = 6, title = "Offset for LSMA / Sigma for ALMA", minval = 0)
offsetALMA  = input.float(defval = 0.85, title = "Offset for ALMA", minval = 0, step = 0.01)
scolor      = input.bool(defval = false, title="Show coloured Bars to indicate Trend?")
delayOffset = input.int(defval = 0, title = "Delay Open/Close MA (Forces Non-Repainting)", minval = 0, step = 1)
tradeType   = input.string(defval = "BOTH", title="What trades should be taken : ", options=["LONG", "SHORT", "BOTH", "NONE"])
// Positioning is managed via the 'Properties' tab in the script settings.

// TRAILING STOP & RISK MANAGEMENT INPUTS
useTSL           = input.bool(true, title="Use Trailing Stop Loss?")
tslPct           = input.float(1.5, title="Trailing Stop %", minval=0.1, step=0.1) / 100
tslActivationPct = input.float(2.0, title="TSL Activation % (Delay)", minval=0.1, step=0.1) / 100
slPct            = input.float(2.0, title="Initial Fixed Stop Loss %", minval=0.1, step=0.1) / 100
useTP            = input.bool(true, title="Use Take Profit?")
tpPct            = input.float(5.0, title="Take Profit %", minval=0.1, step=0.1) / 100

// RANGING MARKET FILTER (Optional)
useADXFilter     = input.bool(defval = false, title = "Use ADX Filter (Avoid Range)?", group = "Filters")
useAutoADX       = input.bool(defval = true, title = "Auto-Detect Threshold?", group = "Filters", tooltip = "When enabled, the strategy automatically determines the ranging threshold based on historical trend strength.")
adxThreshold     = input.int(defval = 20, title = "Manual ADX Threshold", minval = 1, group = "Filters", tooltip = "Only used if Auto-Detect is OFF. ADX above this level indicates a strong trend.")
adxLen           = input.int(defval = 14, title = "ADX Length", minval = 1, group = "Filters")
adxLookback      = input.int(defval = 200, title = "Auto-Detect Lookback", minval = 10, group = "Filters", tooltip = "Number of bars used to calculate the adaptive threshold.")

// === /INPUTS ===
// === /INPUTS ===
// ADX Logic
dirmov(len) =>
	up = ta.change(high)
	down = -ta.change(low)
	plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
	minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
	truerange = ta.rma(ta.tr, len)
	plus = fixnan(100 * ta.rma(plusDM, len) / truerange)
	minus = fixnan(100 * ta.rma(minusDM, len) / truerange)
	[plus, minus]

adx(dilen, adxlen) =>
	[plus, minus] = dirmov(dilen)
	sum = plus + minus
	adx_val = 100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), adxlen)
	adx_val

adx_value = adx(adxLen, adxLen)

// Adaptive Threshold Calculation (Median of recent ADX)
float currentThreshold = float(adxThreshold)
if useAutoADX
    currentThreshold := ta.percentile_linear_interpolation(adx_value, adxLookback, 50)

adx_pass  = not useADXFilter or adx_value > currentThreshold


// Constants colours that include fully non-transparent option.
green100 = #008000FF
lime100  = #00FF00FF
red100   = #FF0000FF
blue100  = #0000FFFF
aqua100  = #00FFFFFF
darkred100 = #8B0000FF
gray100 = #808080FF

// === BASE FUNCTIONS ===
variant(type, src, len, offSig, offALMA) =>
    v1 = ta.sma(src, len)                                                  // Simple
    v2 = ta.ema(src, len)                                                  // Exponential
    v3 = 2 * v2 - ta.ema(v2, len)                                          // Double Exponential
    v4 = 3 * (v2 - ta.ema(v2, len)) + ta.ema(ta.ema(v2, len), len)         // Triple Exponential
    v5 = ta.wma(src, len)                                                  // Weighted
    v6 = ta.vwma(src, len)                                                 // Volume Weighted
    v7 = 0.0
    v7 := na(v7[1]) ? ta.sma(src, len) : (v7[1] * (len - 1) + src) / len    // Smoothed (SMMA)
    v8 = ta.wma(2 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))   // Hull
    v9 = ta.linreg(src, len, offSig)                                       // Least Squares
    v10 = ta.alma(src, len, offALMA, offSig)                               // Arnaud Legoux
    v11 = ta.sma(v1,len)                                                   // Triangular (extreme smooth)
    // SuperSmoother filter
    a1 = math.exp(-1.414*3.14159 / len)
    b1 = 2*a1*math.cos(1.414*3.14159 / len)
    c2 = b1
    c3 = (-a1)*a1
    c1 = 1 - c2 - c3
    v12 = 0.0
    v12 := c1*(src + nz(src[1])) / 2 + c2*nz(v12[1]) + c3*nz(v12[2])
    type=="EMA"?v2 : type=="DEMA"?v3 : type=="TEMA"?v4 : type=="WMA"?v5 : type=="VWMA"?v6 : type=="SMMA"?v7 : type=="HullMA"?v8 : type=="LSMA"?v9 : type=="ALMA"?v10 : type=="TMA"?v11: type=="SSMA"?v12: v1

// security wrapper for repeat calls
// V6: request.security
reso(exp, use, res) => use ? request.security(syminfo.tickerid, res, exp, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on) : exp

// === /BASE FUNCTIONS ===

// === SERIES SETUP ===
closeSeries     = variant(basisType, close[delayOffset], basisLen, offsetSigma, offsetALMA)
openSeries      = variant(basisType, open[delayOffset], basisLen, offsetSigma, offsetALMA)
// === /SERIES ===

// === PLOTTING ===
closeSeriesAlt = reso(closeSeries, useRes, stratRes)
openSeriesAlt = reso(openSeries, useRes, stratRes)

trendColour = (closeSeriesAlt > openSeriesAlt) ? color.green : color.red
bcolour     = (closeSeries > openSeriesAlt) ? lime100 : red100
barcolor(scolor?bcolour:na, title = "Bar Colours")
// V6: transp deprecated in plot. Use color.new()
closeP=plot(nz(closeSeriesAlt), title = "Close Series", color = color.new(trendColour, 20), linewidth = 2, style = plot.style_line)
openP=plot(nz(openSeriesAlt), title = "Open Series", color = color.new(trendColour, 20), linewidth = 2, style = plot.style_line)
// Debug: Commenting out fill to ensure it doesn't crash the renderer
// fill(closeP, openP, color=color.new(color.gray, 80))
// === /PLOTTING ===

// === ALERT conditions
xlong       = ta.crossover(closeSeriesAlt, openSeriesAlt)
xshort      = ta.crossunder(closeSeriesAlt, openSeriesAlt)
longCond    = xlong
shortCond   = xshort

// Entry Logic
if (tradeType!="NONE")
    if (longCond==true and tradeType!="SHORT" and adx_pass)
        strategy.entry("long", strategy.long)

    if (shortCond==true and tradeType!="LONG" and adx_pass)
        strategy.entry("short", strategy.short)


    if (shortCond==true and tradeType=="LONG")
        strategy.close("long")
    if (longCond==true and tradeType=="SHORT")
        strategy.close("short")

// TRAILING STOP LOGIC (DELAYED ACTIVATION)
// Variables initialized for plotting
var float long_tsl_price = na
var float short_tsl_price = 1000000.0
var bool active_trade_l = false
var bool active_trade_s = false

// Reset logic needs to handle 'var' persistence slightly differently or manually reset.
// In v6 'var' keeps values.
// We need to detect NEW entries to reset.
if (strategy.position_size == 0)
    long_tsl_price := na
    short_tsl_price := na
    active_trade_l := false
    active_trade_s := false

if (strategy.position_size > 0)
    entry_price = strategy.position_avg_price
    
    // Check Activation
    if (high > entry_price * (1 + tslActivationPct))
        active_trade_l := true
    
    // Calculate Stop Prices
    fixed_stop = entry_price * (1 - slPct)
    trail_stop = high * (1 - tslPct)
    
    // Logic: Use Fixed Stop until Activated, then Ratchet Trail
    if (active_trade_l)
        // If activated, we ratchet up (MAX)
        // Ensure we don't drop below the fixed stop initially or previous trail
        // Must handle 'na' for max calculation
        prev_stop_l = na(long_tsl_price[1]) ? fixed_stop : long_tsl_price[1]
        // If we switched from fixed to active this tick, long_tsl_price might be fixed_stop
        prev_valid = na(long_tsl_price) ? fixed_stop : long_tsl_price
        // Max of current Trail and Previous Valid Stop
        long_tsl_price := math.max(trail_stop, prev_valid)
    else
        // Not activated yet, hold fixed stop
        long_tsl_price := fixed_stop
        
    // Reset inverse logic just in case
    short_tsl_price := na

if (strategy.position_size < 0)
    entry_price = strategy.position_avg_price
    
    // Check Activation
    if (low < entry_price * (1 - tslActivationPct))
        active_trade_s := true
    
    // Calculate Stop Prices
    fixed_stop = entry_price * (1 + slPct)
    trail_stop = low * (1 + tslPct)
    
    // Logic: Use Fixed Stop until Activated, then Ratchet Trail
    if (active_trade_s)
        // If activated, we ratchet down (MIN)
        prev_stop_s = na(short_tsl_price[1]) ? fixed_stop : short_tsl_price[1]
        prev_valid_s = na(short_tsl_price) ? fixed_stop : short_tsl_price
        short_tsl_price := math.min(trail_stop, prev_valid_s)
    else
        // Not activated yet, hold fixed stop
        short_tsl_price := fixed_stop
        
    // Reset inverse logic
    long_tsl_price := na


// PLOT TSL
// Fix: Only plot when position exists to avoid scaling issues with 0 or 1000000
plot(useTSL and strategy.position_size > 0 ? long_tsl_price : na, color = color.blue, style = plot.style_circles, linewidth = 2, title = "Long TSL")
plot(useTSL and strategy.position_size < 0 ? short_tsl_price : na, color = color.fuchsia, style = plot.style_circles, linewidth = 2, title = "Short TSL")

// Plot TSL Activation Signals
tsl_activated_l = ta.change(active_trade_l) and active_trade_l
tsl_activated_s = ta.change(active_trade_s) and active_trade_s
plotshape(tsl_activated_l, "Long TSL Activation", shape.diamond, location.abovebar, color.blue, size = size.tiny, text = "TSL ON", textcolor = color.blue)
plotshape(tsl_activated_s, "Short TSL Activation", shape.diamond, location.belowbar, color.fuchsia, size = size.tiny, text = "TSL ON", textcolor = color.fuchsia)


// EXITS
if (strategy.position_size > 0)
    // 1. Stop Loss (Handles both Initial and Trailing)
    if (useTSL)
        strategy.exit("SL/TSL L", "long", stop = long_tsl_price)
    // 2. Take Profit
    if (useTP)
        strategy.exit("TP L", "long", limit = strategy.position_avg_price * (1 + tpPct))

if (strategy.position_size < 0)
    // 1. Stop Loss
    if (useTSL)
        strategy.exit("SL/TSL S", "short", stop = short_tsl_price)
    // 2. Take Profit
    if (useTP)
        strategy.exit("TP S", "short", limit = strategy.position_avg_price * (1 - tpPct))

// === /STRATEGY ===
````
