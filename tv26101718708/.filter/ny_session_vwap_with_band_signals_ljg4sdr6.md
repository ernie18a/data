# NY Session VWAP with Band & Signals

- url: https://www.tradingview.com/script/LJG4SDR6-NY-Session-VWAP-with-Band-Signals/
- type: indicator
- pine_id: PUB;05616ee36f7d4aae92a7610b145b4b1c
- version: 1.0

## Description

Overview
This Pine Script indicator is a comprehensive trading tool designed for the New York trading session, combining Volume-Weighted Average Price (VWAP) with statistical bands and multi-condition signal generation. It's optimized for traders who want to identify high-probability entry points during the NY session with strict validation filters.

Key Features
🕐 Session Management
NY Session Focus: Automatically detects and highlights the main NY trading session (9:30 AM - 4:00 PM ET)

Delayed Start Option: Configurable delay after NY open (default 15 minutes) to avoid early session noise

Visual Session Tracking: Different background colors for active NY session and pre-trading window periods

📊 VWAP & Statistical Bands
Dynamic VWAP Calculation: Resets daily at NY session open

Standard Deviation Bands: User-adjustable band width (default 1.0 standard deviations)

Real-time Updates: Continuous calculation throughout the session

🎯 Signal Generation - Multi-Layer Validation
The script generates BUY signals only when ALL conditions are met simultaneously:

Proximity to VWAP (Proximity (pts)): Price must be within X points of VWAP

Band Break: Price must close outside the upper or lower VWAP band

Direction Match: Bullish close must correspond with upper band break; Bearish close with lower band break

Close Percentage Filter:

Bullish signals: Close must be in the upper X% of the candle's range (default 75%)

Bearish signals: Close must be in the lower X% of the candle's range

Opposite Band Validation:

Bullish signals are invalidated if the candle touches the lower band

Bearish signals are invalidated if the candle touches the upper band

📈 Visual Feedback
Candle Coloring: Highlighted candles when signals trigger

Signal Markers: Clear triangle markers above candles

Debug Indicators:

Yellow markers for "filter met but no direction match"

Red markers for invalid signals (opposite band touch)

VWAP & Bands: Visual plotting with fill between bands

📋 Information Table
Real-time dashboard showing:

Session status (Active/Inactive)

Trading window state (Active/Waiting)

Current delay setting

Close percentage filter value

Current candle's close percentage

Signal status (Triggered/None)

Opposite band validation status

🔔 Alert System
Built-in alerts for:

Price crossing upper/lower bands

Price crossing VWAP

Full signal generation (all conditions met)

Ideal Use Cases
Mean Reversion Trading: Identifying overextended moves with VWAP proximity

Breakout Confirmation: Ensuring directional moves have momentum (close percentage filter)

Noise Reduction: Multiple filters prevent false signals during choppy markets

Intraday Trend Following: Capturing NY session momentum with statistical validation

Best Practices
Use on 3-minute timeframe for best signal quality on MNQ or MES

Don't trade within the first 15M, possibly even 30M, of the NY open. 

Consider using the "Close Percentage Filter" at 70-80% for quality signals

The "Opposite Band" validation helps avoid false breakouts

Technical Requirements
TradingView account with Pine Script v6 support

Suitable for any instrument with NY session trading

Requires volume data for accurate VWAP calculation

## Source Code

````pine
//@version=6
indicator("NY Session VWAP with Band & Signals", overlay=true)

// === Inputs ===
deviation = input.float(1.0, "Band Deviation", step=0.1, tooltip="Number of standard deviations for the band")
proximity_pts = input.float(5.0, "VWAP Proximity (pts)", step=1.0, tooltip="Points within VWAP to trigger signal")
delay_minutes = input.int(15, "Delay After Open (minutes)", step=5, tooltip="No signals until X minutes after NY open")
close_percentage = input.float(75.0, "Close Percentage Filter (%)", step=5.0, minval=1, maxval=100, tooltip="Candle must close at or above X% of its range in the direction of the move")

show_band = input.bool(true, "Show Band")
show_vwap = input.bool(true, "Show VWAP")
bg_color = input.bool(true, "Highlight NY Session Background")
show_signals = input.bool(true, "Show Signal Highlights")

// === NY Session Times (Eastern Time) ===
ny_open_time = "0930"
ny_close_time = "1600"

// Check if in main NY session
in_ny_session = not na(time(timeframe.period, ny_open_time + "-" + ny_close_time + ":1234567", "America/New_York"))

// === Trading Window Logic ===
// Calculate delayed open time
var string delayed_open_time = ""
if delay_minutes > 0
    // Calculate delayed open time
    delay_hours = math.floor(delay_minutes / 60)
    delay_remainder_minutes = delay_minutes % 60
    open_hour = 9
    open_minute = 30
    
    delayed_hour = open_hour + delay_hours
    delayed_minute = open_minute + delay_remainder_minutes
    
    // Handle minute overflow
    if delayed_minute >= 60
        delayed_hour := delayed_hour + 1
        delayed_minute := delayed_minute - 60
    
    // Format as HHMM
    delayed_open_time := str.tostring(delayed_hour) + str.tostring(delayed_minute)
    if delayed_minute < 10
        delayed_open_time := str.tostring(delayed_hour) + "0" + str.tostring(delayed_minute)
    if delayed_hour < 10
        delayed_open_time := "0" + delayed_open_time
else
    delayed_open_time := ny_open_time

// Create trading window session string
trading_window = delayed_open_time + "-" + ny_close_time + ":1234567"

// Check if in trading window (after delay)
in_trading_window = not na(time(timeframe.period, trading_window, "America/New_York"))

// === VWAP Calculation ===
var float cumulative_typ_price_vol = 0.0
var float cumulative_volume = 0.0
var float cumulative_sq_diff_vol = 0.0
var float vwap = na
var float band_upper = na
var float band_lower = na

// Reset at start of NY session
if in_ny_session and not in_ny_session[1]
    cumulative_typ_price_vol := 0.0
    cumulative_volume := 0.0
    cumulative_sq_diff_vol := 0.0
    vwap := na
    band_upper := na
    band_lower := na

// Calculate during NY session (VWAP starts calculating from open, not delayed)
if in_ny_session
    typical_price = (high + low + close) / 3
    cumulative_typ_price_vol += typical_price * volume
    cumulative_volume += volume
    
    if cumulative_volume > 0
        vwap := cumulative_typ_price_vol / cumulative_volume
        
        // Calculate squared difference for standard deviation
        cumulative_sq_diff_vol += math.pow(typical_price - vwap, 2) * volume
        
        // Calculate standard deviation
        variance = cumulative_sq_diff_vol / cumulative_volume
        stdev = math.sqrt(variance)
        
        // Calculate bands
        band_upper := vwap + (deviation * stdev)
        band_lower := vwap - (deviation * stdev)
else
    vwap := na
    band_upper := na
    band_lower := na

// === Close Percentage Filter ===
// Calculate where the close is within the candle's range
float candle_range = high - low
float close_position_pct = 0.0

if candle_range > 0
    // Percentage from low to close (0% = low, 100% = high)
    close_position_pct := ((close - low) / candle_range) * 100
else
    close_position_pct := 50  // Doji or no range

// Determine candle direction and check filter
bool is_bullish = close > open
bool is_bearish = close < open

// For bullish: close must be at or above X% of range from low
// For bearish: close must be at or below (100 - X)% of range from low
float filter_threshold = close_percentage / 100

bool meets_close_filter = false
string candle_type = ""

if is_bullish
    // Bullish: close should be in upper portion of candle
    meets_close_filter := close_position_pct >= close_percentage
    candle_type := "Bullish"
else if is_bearish
    // Bearish: close should be in lower portion of candle (close near low)
    meets_close_filter := close_position_pct <= (100 - close_percentage)
    candle_type := "Bearish"
else
    // Doji or neutral - only count if percentage is low enough
    meets_close_filter := close_percentage <= 50

// === Signal Logic ===
// Check if candle is within proximity of VWAP
float tick_value = syminfo.mintick
float proximity_in_price = proximity_pts * tick_value

bool within_proximity = not na(vwap) and (math.abs(low - vwap) <= proximity_in_price or 
                                           math.abs(high - vwap) <= proximity_in_price or
                                           (low <= vwap and high >= vwap))

// Check if candle closes outside either band
bool closed_outside_band = not na(band_upper) and not na(band_lower) and 
                           (close > band_upper or close < band_lower)

// Determine which band was broken
bool broke_upper = close > band_upper
bool broke_lower = close < band_lower

// === ADDED: Check if candle touches the OPPOSITE band ===
// For longs (bullish): invalidate if candle touches the lower band
bool touches_lower_band = not na(band_lower) and (low <= band_lower)
// For shorts (bearish): invalidate if candle touches the upper band  
bool touches_upper_band = not na(band_upper) and (high >= band_upper)

// Check for opposite band touch
bool invalid_opposite_band = false
if is_bullish and touches_lower_band
    invalid_opposite_band := true  // Long signal invalid because it touched lower band
else if is_bearish and touches_upper_band
    invalid_opposite_band := true  // Short signal invalid because it touched upper band

// Additional filter: Direction should match band break
bool direction_matches = false
if broke_upper and is_bullish
    direction_matches := true
else if broke_lower and is_bearish
    direction_matches := true

// === UPDATED: Combined signal - ALL conditions must be met ===
// Added: NOT invalid_opposite_band condition
bool signal = in_trading_window and 
              within_proximity and 
              closed_outside_band and 
              meets_close_filter and
              direction_matches and
              not invalid_opposite_band  // NEW: Invalidate if touching opposite band

// === Visual Highlighting ===
// Highlight candle when signal occurs
barcolor(show_signals and signal ? color.new(color.blue, 0) : na)

// Plot signal markers
plotshape(show_signals and signal, title="Signal", location=location.abovebar, 
          style=shape.triangleup, size=size.small, color=color.new(color.blue, 0))

// Plot invalid signals (touching opposite band) - for debugging
plotshape(show_signals and in_trading_window and closed_outside_band and within_proximity and invalid_opposite_band, 
          title="Invalid Signal (Opposite Band)", location=location.abovebar, 
          style=shape.triangledown, size=size.tiny, color=color.new(color.red, 80))

// Optional: Plot close percentage as a visual indicator
plotshape(show_signals and meets_close_filter and in_trading_window and closed_outside_band and within_proximity and not signal and not invalid_opposite_band, 
          title="Filter Met But No Direction", location=location.abovebar, 
          style=shape.triangleup, size=size.tiny, color=color.new(color.yellow, 0))

// === Plotting ===
plot(show_vwap and not na(vwap) ? vwap : na, "NY VWAP", color=color.new(color.blue, 0), linewidth=2)

// Plot bands as lines
plot(show_band and not na(band_upper) ? band_upper : na, "Upper Band", color=color.new(color.red, 0), linewidth=1)
plot(show_band and not na(band_lower) ? band_lower : na, "Lower Band", color=color.new(color.green, 0), linewidth=1)

// Fill between bands
fill(plot(show_band and not na(band_upper) ? band_upper : na), 
     plot(show_band and not na(band_lower) ? band_lower : na), 
     color=color.new(color.gray, 90))

// Background highlighting
bgcolor(bg_color and in_ny_session ? color.new(color.blue, 95) : na)

// Show trading window background in different color
bgcolor(show_signals and in_ny_session and not in_trading_window ? color.new(color.red, 90) : na)

// === Alert Conditions ===
alertcondition(ta.cross(close, band_upper), title="Price Crossed Upper Band", message="Price crossed above NY VWAP upper band")
alertcondition(ta.cross(close, band_lower), title="Price Crossed Lower Band", message="Price crossed below NY VWAP lower band")
alertcondition(ta.cross(close, vwap), title="Price Crossed VWAP", message="Price crossed NY VWAP")
alertcondition(signal, title="Signal Alert", message="Signal: All conditions met (proximity, band break, close filter, direction match)")

// === Info Table ===
var table info_table = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 80))
if barstate.islast
    table.cell(info_table, 0, 0, "NY Session:", text_color=color.white)
    table.cell(info_table, 1, 0, in_ny_session ? "Active" : "Inactive", text_color=in_ny_session ? color.green : color.red)
    table.cell(info_table, 0, 1, "Trading Window:", text_color=color.white)
    table.cell(info_table, 1, 1, in_trading_window ? "Active" : "Waiting", text_color=in_trading_window ? color.green : color.orange)
    table.cell(info_table, 0, 2, "Delay:", text_color=color.white)
    table.cell(info_table, 1, 2, str.tostring(delay_minutes) + " min", text_color=color.yellow)
    table.cell(info_table, 0, 3, "Close Filter:", text_color=color.white)
    table.cell(info_table, 1, 3, str.tostring(close_percentage) + "%", text_color=color.orange)
    table.cell(info_table, 0, 4, "Current Close %:", text_color=color.white)
    table.cell(info_table, 1, 4, str.tostring(math.round(close_position_pct, 1)) + "%", text_color=meets_close_filter ? color.green : color.red)
    table.cell(info_table, 0, 5, "Signals:", text_color=color.white)
    table.cell(info_table, 1, 5, signal ? "TRIGGERED" : "None", text_color=signal ? color.blue : color.gray)
    table.cell(info_table, 0, 6, "Opposite Band:", text_color=color.white)
    table.cell(info_table, 1, 6, invalid_opposite_band ? "INVALID" : "OK", text_color=invalid_opposite_band ? color.red : color.green)
````
