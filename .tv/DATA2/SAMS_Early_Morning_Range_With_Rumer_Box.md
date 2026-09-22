<!-- tradingview-pine-id: PUB;608459d2f9a84e3b9fe85e63c4a75b75 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SAMS Early Morning Range - With Rumer Box

Source: https://www.tradingview.com/script/2qN8XCLG-SAMS-Early-Morning-Range-Lines/

## Description

This indicator maps the premarket / early-morning range (EMR) and uses that range as a reference for regular-session structure and breakout signals.
What it plots

EMR high / low (green / red): the high and low printed during the 04:00–09:30 America/New_York window. These levels persist into the regular session.
Previous-day RTH range (Rumer Box): prior regular-session high and low, with a light purple fill between them. The prior RTH range is only updated after a full RTH session has printed.
Premarket bands (RTH only): optional ±% envelopes around the EMR high and EMR low. Default is 0.03%. Use these as a buffer around the premarket extremes instead of treating the raw high/low as a single line.

Sessions are defined in Eastern time (America/New_York) so DST is handled by TradingView’s session engine.
Signals
Signals fire only after the EMR session ends and only if EMR high and low exist.

Buy: first valid break of EMR high
Sell: first valid break of EMR low
Re-Buy: after a sell, price recrosses back up through EMR low
Re-Sell: after a buy, price recrosses back down through EMR high

Only one primary buy and one primary sell are allowed per day unless a re-entry flips the state.
Signal modes

Crossover Candle — close crosses the EMR level.
First Fully Crossed — the bar’s low crosses above EMR high (buy) or the bar’s high crosses below EMR low (sell). Stricter than a close-only cross.
Open Confirmation — the cross is detected on the current bar, then confirmed on the next bar if open continues in the breakout direction relative to the prior close. Reduces same-bar fakeouts.

Default mode is Open Confirmation.
Alerts
On a confirmed signal the script fires a once-per-bar-close alert:
SAMS_EMR_BUY / SELL / RE_BUY / RE_SELL

plus ticker, interval, and close.
Create alerts from the indicator with “Any alert() function call”.
Suggested use
Use EMR high/low as the first overnight auction box. The previous-day RTH box is context for whether the open is inside, above, or below yesterday’s cash range. Bands are for traders who want a small buffer instead of a hard level. This is a level + confirmation tool, not a standalone strategy. Combine with your own risk rules, size, and higher-timeframe bias.
Notes
Works best on intraday charts that include premarket data (1–15 minute is typical). If the symbol or session settings omit 04:00–09:30 ET prints, EMR high/low will be incomplete. Past session levels and signals are not a guarantee of future results.

---

## Source Code

````pine
//@version=6
indicator("SAMS Early Morning Range - With Rumer Box", overlay = true)

// Signal mode input
signal_mode = input.string("Open Confirmation", title="Signal Mode", options=["Crossover Candle", "First Fully Crossed", "Open Confirmation"])

band_pct         = input.float(0.03, "Band width ± % around high/low", minval=0.0, step=0.005, group="Premarket High/Low Bands (RTH)")
show_bands       = input.bool(true, "Show bands during RTH", group="Premarket High/Low Bands (RTH)")
band_color_high  = input.color(color.new(color.green, 75), "High band fill color", group="Premarket High/Low Bands (RTH)")
band_color_low   = input.color(color.new(color.red, 75), "Low band fill color", group="Premarket High/Low Bands (RTH)")
line_color       = input.color(color.new(color.gray, 40), "Band border color", group="Premarket High/Low Bands (RTH)")

// Define session times in EST
tz = "America/New_York"
string emr_session = "0400-0930"   // Pre-market / early range (up to but not including the 9:30 bar)
string rth_session = "0930-1600"   // Regular trading hours

// Persistent variables for high and low
var float sessionHigh = na
var float sessionLow = na

// Persistent variables for previous day RTH
var float prevRTHHigh = na
var float prevRTHLow = na

// Current day RTH trackers (will be shifted to prev on new day)
var float currRTHHigh = na
var float currRTHLow = na

// Flag to track if RTH occurred on the previous calendar day
var bool hadRTH = false

// Persistent variables for signals
var bool buySignaled = false
var bool sellSignaled = false

// Persistent variables for pending signals
var string pending = ""
var float trigger_close = na

// Detect new day in EST (more accurate with timezone-aware detection)
newDay = ta.change(dayofmonth(time, tz)) != 0

// Reset on new day
if newDay
    sessionHigh := na
    sessionLow := na
    buySignaled := false
    sellSignaled := false
    pending := ""
    trigger_close := na
    // Shift current RTH to previous only if RTH occurred
    if hadRTH
        prevRTHHigh := currRTHHigh
        prevRTHLow := currRTHLow
    currRTHHigh := na
    currRTHLow := na
    hadRTH := false

// Check if bar is within the early morning session or RTH (session-based = cleaner & handles DST correctly)
inSession = not na(time(timeframe.period, emr_session, tz))
inRTH   = not na(time(timeframe.period, rth_session, tz))

// Update early morning high and low if in session
if inSession
    sessionHigh := na(sessionHigh) ? high : math.max(sessionHigh, high)
    sessionLow := na(sessionLow) ? low : math.min(sessionLow, low)

// Update current day RTH high/low
if inRTH
    hadRTH := true
    currRTHHigh := na(currRTHHigh) ? high : math.max(currRTHHigh, high)
    currRTHLow := na(currRTHLow) ? low : math.min(currRTHLow, low)

var float high_upper = na
var float high_lower = na
var float low_upper  = na
var float low_lower  = na

if inRTH and not na(sessionHigh) and not na(sessionLow)
    float offset_high = sessionHigh * (band_pct / 100)
    high_upper := sessionHigh + offset_high
    high_lower := sessionHigh - offset_high
    
    float offset_low  = sessionLow  * (band_pct / 100)
    low_upper  := sessionLow  + offset_low
    low_lower  := sessionLow  - offset_low

// persist values across bars (so bands don't disappear mid-session)
high_upper := nz(high_upper, high_upper[1])
high_lower := nz(high_lower, high_lower[1])
low_upper  := nz(low_upper,  low_upper[1])
low_lower  := nz(low_lower,  low_lower[1])

// === SIGNAL LOGIC (unchanged) ===
buy_condition = false
sell_condition = false
re_buy_condition = false
re_sell_condition = false

if not inSession and not na(sessionHigh) and not na(sessionLow)
    // Pending signal trigger for Open Confirmation mode
    if pending != "" and signal_mode == "Open Confirmation"
        bool is_buy_type = pending == "buy" or pending == "re_buy"
        bool is_sell_type = pending == "sell" or pending == "re_sell"
        bool condition_met = (is_buy_type and open > trigger_close) or (is_sell_type and open < trigger_close)
        if condition_met
            if pending == "buy"
                buy_condition := true
                buySignaled := true
            else if pending == "re_buy"
                re_buy_condition := true
                sellSignaled := false
            else if pending == "sell"
                sell_condition := true
                sellSignaled := true
            else if pending == "re_sell"
                re_sell_condition := true
                buySignaled := false
            pending := ""
            trigger_close := na
    
    // Detect new crossovers if no pending
    if pending == ""
        bool buy_detect = false
        bool sell_detect = false
        bool re_buy_detect = false
        bool re_sell_detect = false
        
        if signal_mode == "Crossover Candle"
            buy_detect := not buySignaled and ta.crossover(close, sessionHigh)
            sell_detect := not sellSignaled and ta.crossunder(close, sessionLow)
            re_buy_detect := sellSignaled and ta.crossover(close, sessionLow)
            re_sell_detect := buySignaled and ta.crossunder(close, sessionHigh)
        else // "First Fully Crossed" and "Open Confirmation"
            buy_detect := not buySignaled and ta.crossover(low, sessionHigh)
            sell_detect := not sellSignaled and ta.crossunder(high, sessionLow)
            re_buy_detect := sellSignaled and ta.crossover(low, sessionLow)
            re_sell_detect := buySignaled and ta.crossunder(high, sessionHigh)
        
        if buy_detect
            if signal_mode == "Open Confirmation"
                pending := "buy"
                trigger_close := close
            else
                buy_condition := true
                buySignaled := true
        else if sell_detect
            if signal_mode == "Open Confirmation"
                pending := "sell"
                trigger_close := close
            else
                sell_condition := true
                sellSignaled := true
        else if re_buy_detect
            if signal_mode == "Open Confirmation"
                pending := "re_buy"
                trigger_close := close
            else
                re_buy_condition := true
                sellSignaled := false
        else if re_sell_detect
            if signal_mode == "Open Confirmation"
                pending := "re_sell"
                trigger_close := close
            else
                re_sell_condition := true
                buySignaled := false

// === PLOTS ===
emrHighPlot = plot(sessionHigh, "Upper Range (EMR)", color = color.green, linewidth = 1)
emrLowPlot = plot(sessionLow, "Lower Range (EMR)", color = color.red, linewidth = 1)

// Previous day RTH (both lines same color so the band looks clean)
prevHighPlot = plot(prevRTHHigh, "Prev Day RTH High", color = color.purple, linewidth = 1)
prevLowPlot = plot(prevRTHLow, "Prev Day RTH Low", color = color.purple, linewidth = 1)

// Shade the area between previous day RTH high and low
fill(prevHighPlot, prevLowPlot, color = color.new(color.purple, 90), title = "Prev Day RTH Range Fill")

// Signals
plotshape(buy_condition, title="Buy Signal", location=location.belowbar, style=shape.triangleup, color=color.aqua, size=size.small)
plotshape(sell_condition, title="Sell Signal", location=location.abovebar, style=shape.triangledown, color=color.aqua, size=size.small)
plotshape(re_buy_condition, title="Re Buy Signal", location=location.belowbar, style=shape.triangleup, color=color.aqua, size=size.small)
plotshape(re_sell_condition, title="Re Sell Signal", location=location.abovebar, style=shape.triangledown, color=color.aqua, size=size.small)

// ────────────────────────────────────────────────
// PLOTS - High band and Low band (visible only during/in RTH)
// ────────────────────────────────────────────────

// Condition to show anything at all
bool show_this_bar = show_bands and inRTH

// High band lines ────────────────────────────────────────
plot(show_this_bar ? high_upper : na, "High +%", color = line_color, linewidth = 1)
plot(show_this_bar ? high_lower : na, "High -%", color = line_color, linewidth = 1)

// Low band lines ─────────────────────────────────────────
plot(show_this_bar ? low_upper  : na, "Low +%",  color = line_color, linewidth = 1)
plot(show_this_bar ? low_lower  : na, "Low -%",  color = line_color, linewidth = 1)

// Fills ──────────────────────────────────────────────────
// We use dummy plots with display.none so fill() can reference them
// but only when we actually want to show the fill

p_high_upper = plot(show_this_bar ? high_upper : na, display = display.none)
p_high_lower = plot(show_this_bar ? high_lower : na, display = display.none)

p_low_upper  = plot(show_this_bar ? low_upper  : na, display = display.none)
p_low_lower  = plot(show_this_bar ? low_lower  : na, display = display.none)

fill(p_high_upper, p_high_lower, color = show_this_bar ? band_color_high : na, title = "Band around Premarket High")
fill(p_low_upper,  p_low_lower,  color = show_this_bar ? band_color_low  : na, title = "Band around Premarket Low")


// === ALERTS (unchanged) ===
string alert_message = na

if buy_condition
    alert_message := "BUY"

if sell_condition
    alert_message := "SELL"

if re_buy_condition
    alert_message := "RE_BUY"

if re_sell_condition
    alert_message := "RE_SELL"

if not na(alert_message)
    alert(message = "SAMS_EMR_" + alert_message + 
                   "\nSymbol: {{ticker}}" + 
                   "\nInterval: {{interval}}" + 
                   "\nPrice: " + str.tostring(close), 
                   freq = alert.freq_once_per_bar_close)
````
