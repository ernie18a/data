# Tristan HTF Master - Multi Timeframe Overlay

- url: https://www.tradingview.com/script/dfKTkdP6-Tristan-HTF-Master-Multi-Timeframe-Overlay/
- type: indicator
- pine_id: PUB;a6a6a9a6f08147a684e8ed4a016bef07
- version: 1.0

## Description

Welcome to my indicator, a powerful multi-timeframe (MTF) visualization tool designed specifically for traders who rely on "Candle Behavior Strategies" and precise timing strategies. I use this indicator as an orientation 

If you base your trades on the internal mechanics of Higher Timeframe (HTF) candles—such as tracking the open, high, low, and close of a 1-hour candle while executing on the 1-minute or 5-minute chart—this indicator is built for you.
[b]The Core Concept:[/b] Time-Based Candle Behavior: Depending on your strategy in my opinion it is best suited for Time Based Strategies.

This indicator was developed with a specific structural trading strategy in mind (heavily inspired by concepts of "Tom Trades" Candle Behavior Reversal. So respects to him. The core philosophy revolves around observing how a Higher Timeframe candle (e.g., the 1H candle) behaves during its lifespan.

Often, in ranging or consolidating markets, a 1H candle will exhibit a distinct pattern:
First 30 Minutes (The Trap): The market creates a sudden Liquidity Sweep accompanied by an Overextension. This often traps breakout traders.
The Reversal (At ~30 Mins): Right around the midpoint of the candle's lifespan, the market loses momentum, reverses, and creates a Type 3 Market Shift / Break of Structure (BoS) on the lower timeframes.
Last 30 Minutes (The Retrace): The price retraces back into the HTF candle's range, often pulling back up to 50% of the initial overextension before the candle closes.

Because precise timing is everything in this strategy, the Tristan HTF Master visually draws the HTF candle directly onto your lower timeframe chart from the very first second it opens. You can visually track exactly when the 30-minute mark is reached without having to constantly switch timeframes or check the clock.

How to Trade the Strategy Using This Indicator

While this tool can be used for any MTF strategy, here is the optimal step-by-step setup it was designed for:
Market Condition: Identify a ranging market. Avoid massive, aggressive trending environments. Look for longs in the lower third of the range, and shorts in the upper third.
The Setup: Wait for a Liquidity Sweep and an Overextension during the first half of the HTF candle (e.g., the first 30 mins of the 1H box).
The Trigger: Look for a Type 3 Market Shift (Break of Structure) on the lower timeframe, confirming the exhaustion of the overextension.
The Entry: Pull your Fibonacci tool over the Type 3 shift. Place a limit order at the 50% retracement level of that shift (ideally backed by a factual shift confirmation).
Stop Loss (SL): Placed strictly above the local high (for shorts) or below the local low (for longs) of the sweep.
Take Profit (TP): Target the 50% retracement level of the entire initial overextension.

Indicator Features
Dynamic HTF Boxes: Overlays 15m, 30m, 1H, or 4H candles perfectly onto your current LTF chart. The boxes span the full width of the time period from the moment they open.
100% Transparent Bodies: The HTF box bodies are fully transparent. This allows you to clearly read the internal Lower Timeframe (LTF) price action without visual clutter.
Real-Time Wicks: The wicks of the HTF candle update dynamically in the center of the box as new highs and lows are formed.
Live Countdown Timer: Includes a clean, built-in countdown label attached to the active HTF candle, showing exactly how much time is left until the candle closes.

Disclaimer: This script and the described strategy are for educational purposes only and do not constitute financial advice. Past performance is not indicative of future results. Always backtest strategies thoroughly and manage your risk appropriately.

## Source Code

````pine
//@version=5
// TITLE MUST BE ENGLISH
indicator("Tristan HTF Master - Multi Timeframe Overlay", overlay=true, max_boxes_count=500, max_lines_count=500)

// =========================================================================
// 1. SETTINGS (Menu) - Main Variables
// =========================================================================
grpToggles = "Timeframes to Display"
show_15m = input.bool(false, "15 Minutes Box", group=grpToggles)
show_30m = input.bool(false, "30 Minutes Box", group=grpToggles)
show_1h  = input.bool(true,  "1 Hour Box", group=grpToggles)
show_4h  = input.bool(false, "4 Hours Box", group=grpToggles)

grpColors = "Color Settings"
// 100% transparent inside, because we want to see full Candle for Candle Behavior Strategy. Blue because I use Pepperstone which is blue too.
bullBody = input.color(color.new(color.blue, 100), "Bullish Inside (Transparent)", group=grpColors)
bullWick = input.color(color.blue, "Bullish Border & Wick", group=grpColors)

bearBody = input.color(color.new(color.red, 100), "Bearish Inside (Transparent)", group=grpColors)
bearWick = input.color(color.red, "Bearish Border & Wick", group=grpColors)

// =========================================================================
// 2. HELPER FUNCTION (Countdown Formatting)
// =========================================================================
f_format_countdown(ms) =>
    if ms < 0
        ""
    else
        int total_seconds = math.floor(ms / 1000)
        int minutes = math.floor(total_seconds / 60) % 60
        int hours = math.floor(total_seconds / 3600)
        int seconds = total_seconds % 60
        string hours_str = hours > 0 ? str.tostring(hours) + "h " : ""
        string mins_str = (minutes < 10 ? "0" : "") + str.tostring(minutes) + "m "
        string secs_str = (seconds < 10 ? "0" : "") + str.tostring(seconds) + "s"
        hours_str + mins_str + secs_str

// =========================================================================
// 3. BOX DRAWING LOGIC (Full width from the start, dynamic height)
// =========================================================================
f_draw_htf(tf_string, tf_name, show_toggle) =>
    if show_toggle
        is_new_htf = ta.change(time(tf_string)) != 0

        // Variables to track the HTF candle formation
        var float h_open = na
        var float h_high = na
        var float h_low  = na
        
        // Using time instead of bar_index to draw into the future
        var int t_start = na
        var int t_end = na

        // Box and Line objects using xloc.bar_time
        var box htf_box = na
        var line wick_top = na
        var line wick_bot = na
        var label htf_label = label.new(na, na, "", style=label.style_label_down, color=color.new(color.white, 100), size=size.small, xloc=xloc.bar_time)

        if is_new_htf
            // Initialize HTF data at the very first bar of the new period
            h_open := open
            h_high := high
            h_low  := low
            
            // Get the start time and the expected end time of this HTF candle
            t_start := time(tf_string)
            t_end := time_close(tf_string)

            col = close >= h_open ? bullBody : bearBody
            border_col = close >= h_open ? bullWick : bearWick

            // The wick will be placed in the exact horizontal center of the full width box
            mid_time = math.round(t_start + (t_end - t_start) / 2)

            // Create initial box spanning the FULL width of the timeframe
            htf_box := box.new(left=t_start, top=math.max(h_open, close), right=t_end, bottom=math.min(h_open, close), border_color=border_col, bgcolor=col, xloc=xloc.bar_time)
            wick_top := line.new(x1=mid_time, y1=h_high, x2=mid_time, y2=math.max(h_open, close), color=border_col, xloc=xloc.bar_time)
            wick_bot := line.new(x1=mid_time, y1=math.min(h_open, close), x2=mid_time, y2=h_low, color=border_col, xloc=xloc.bar_time)
            
        else if not na(h_open) 
            // Dynamically expand the High and Low as new LTF bars arrive
            h_high := math.max(h_high, high)
            h_low  := math.min(h_low, low)

            col = close >= h_open ? bullBody : bearBody
            border_col = close >= h_open ? bullWick : bearWick

            // We only update top and bottom! Left and right stay at full width. Important for Time-Based Candle Behavior.
            box.set_top(htf_box, math.max(h_open, close))
            box.set_bottom(htf_box, math.min(h_open, close))
            box.set_bgcolor(htf_box, col)
            box.set_border_color(htf_box, border_col)
            
            // Update wicks height
            line.set_y1(wick_top, h_high)
            line.set_y2(wick_top, math.max(h_open, close))
            line.set_color(wick_top, border_col)
            
            line.set_y1(wick_bot, math.min(h_open, close))
            line.set_y2(wick_bot, h_low)
            line.set_color(wick_bot, border_col)
        
        // Update countdown label only on the very last live bar
        if barstate.islast
            timeLeft = t_end - timenow
            countdownText = f_format_countdown(timeLeft)
            
            if not na(t_start)
                mid_time = math.round(t_start + (t_end - t_start) / 2)
                label.set_x(htf_label, mid_time)
                label.set_y(htf_label, h_high)
                label.set_text(htf_label, tf_name + " | " + countdownText)
                
                border_col = close >= h_open ? bullWick : bearWick
                label.set_textcolor(htf_label, border_col)

// =========================================================================
// 4. EXECUTION
// =========================================================================
f_draw_htf("15", "15M", show_15m)
f_draw_htf("30", "30M", show_30m)
f_draw_htf("60", "1H", show_1h)
f_draw_htf("240", "4H", show_4h)
````
