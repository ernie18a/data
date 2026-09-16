<!-- tradingview-pine-id: PUB;f45cb21f2edc4f02980f3b47615ee2a0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Timeframe Hull Moving Average (HMA) Candle Projection

Source: https://www.tradingview.com/script/arIkKLKk-Multi-Timeframe-Hull-Moving-Average-HMA-Candle-Projection/

## Description

### Overview
The **Multi-Timeframe Hull Moving Average (HMA) Candle Projection** is a lightweight, clean chart overlay designed for traders utilizing multi-timeframe analysis. 

Instead of traditional higher timeframe candlestick data, this tool applies a **Hull Moving Average (HMA)** calculation directly to the Open, High, Low, and Close (OHLC) values of a higher session. This extracts the noise-filtering benefits of a Hull Moving Average while still structuring the resulting data into recognizable candle bodies and wicks.

### Key Features
* **Live Sidebar Projection:** Rather than plotting blocks directly on top of your current price chart, this script cleanly isolates the real-time higher timeframe Hull candle to the right margin of your layout. This keeps your execution window clutter-free.
* **Lag Minimization:** By processing structural candle boundaries through the Hull formula, it smooths out higher timeframe data without introducing the heavy lag associated with standard simple moving averages.
* **Pine Script v6 Compliant:** Rewritten using the strict syntax rules of version 6 to ensure rapid rendering and seamless compatibility with modern TradingView engine performance metrics.

### How to Read & Use
1. **Trend Identification:** When the projected candle body is green, the higher timeframe Hull trend is bullish (Close >= Open). When it is red, the higher timeframe Hull trend is bearish (Close < Open).
2. **Top-Down Coordination:** This is highly effective for filtering micro-execution charts against macro-trends. For example, look for long setups on a 5-minute chart only when the 15-minute or 1-hour projected Hull candle on the right is green. 
3. **Settings Controls:** Double-click the indicator to alter the higher timeframe source resolution (e.g., changing it from 15 to 60 or W for Weekly), modify the HMA lookback length (default is 9), or shift the candle further into your right margin screen space.

---

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Hull Moving Average (HMA) Candle Projection", overlay=true, max_boxes_count=100, max_lines_count=100)

// --- INPUTS ---
string htf_input   = input.timeframe("15", "Higher Timeframe (e.g., 15, 60, W)")
int hma_length     = input.int(9, "Hull MA Length")
int shift_bars     = input.int(5, "Bars to Shift Right")

// --- FETCH HTF OHLC DATA ---
float htf_o = request.security(syminfo.tickerid, htf_input, open, barmerge.gaps_off, barmerge.lookahead_off)
float htf_h = request.security(syminfo.tickerid, htf_input, high, barmerge.gaps_off, barmerge.lookahead_off)
float htf_l = request.security(syminfo.tickerid, htf_input, low, barmerge.gaps_off, barmerge.lookahead_off)
float htf_c = request.security(syminfo.tickerid, htf_input, close, barmerge.gaps_off, barmerge.lookahead_off)

// --- CALCULATE HULL MA FOR OHLC POINTS ---
float hull_o = ta.hma(htf_o, hma_length)
float hull_h = ta.hma(htf_h, hma_length)
float hull_l = ta.hma(htf_l, hma_length)
float hull_c = ta.hma(htf_c, hma_length)

// --- TREND & COLOR LOGIC ---
bool is_bullish    = hull_c >= hull_o
color candle_color = is_bullish ? color.green : color.red
color wick_color   = is_bullish ? color.green : color.red

// --- LIVE PROJECTION ENGINE ---
var box live_candle_body = na
var line live_candle_wick = na

if barstate.islast
    // Clear the previous real-time drawing to prevent screen clutter
    box.delete(live_candle_body)
    line.delete(live_candle_wick)
    
    // X-Coordinate Calculations for the right margin space
    int target_x1 = bar_index + shift_bars
    int target_x2 = bar_index + shift_bars + 2 
    int wick_x    = bar_index + shift_bars + 1 
    
    // Draw the Live Projected Hull Candle Body
    live_candle_body := box.new(
         left=target_x1, 
         top=math.max(hull_o, hull_c), 
         right=target_x2, 
         bottom=math.min(hull_o, hull_c), 
         bgcolor=color.new(candle_color, 30), 
         border_color=candle_color
         )
         
    // Draw the Live Projected Hull Candle Wick
    live_candle_wick := line.new(
         x1=wick_x, 
         y1=hull_h, 
         x2=wick_x, 
         y2=hull_l, 
         color=wick_color, 
         width=2
         )
````
