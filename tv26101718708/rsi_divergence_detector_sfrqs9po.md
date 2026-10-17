# RSI Divergence Detector

- url: https://www.tradingview.com/script/SfRqs9Po-RSI-Divergence-Detector/
- type: indicator
- pine_id: PUB;387bb80cd56a4e22a509f09c27d2a0c0
- version: 1.0

## Description

RSI Divergence Detector with automatic pivot based detection
 
Spots bullish and bearish RSI divergences automatically by connecting pivot highs and lows on the RSI panel.
 
🔍 What it does
 
This indicator detects when price and RSI momentum disagree. One of the most reliable early warning signals in technical analysis.
 
Regular Bullish Divergence: Price makes a lower low while RSI makes a higher low. Momentum is improving despite price weakness, potential reversal to the upside.
 
Regular Bearish Divergence: Price makes a higher high while RSI makes a lower high. Momentum is fading despite price strength, potential reversal to the downside.
 
Hidden Bullish Divergence (need to turn on in options): Price makes a higher low while RSI makes a lower low. Trend continuation signal the pullback is likely over.
 
Hidden Bearish Divergence (need to turn on in options): Price makes a lower high while RSI makes a higher high. Downtrend continuation signal, the bounce is likely over.
 
📊 Visual Design
 
- Clean RSI line that changes color: green in oversold (below 30), red in overbought (above 70), white in the middle
- Subtle gradient fills on overbought/oversold zones
- Solid lines connecting divergence pivots on the RSI panel  (green for bullish, red for bearish)
- Dashed lines for hidden divergences (when enabled)
- Small triangle markers when divergence is detected
 
⚙️ Settings
 
RSI Length: Default 14. Standard setting that works across most timeframes.
 
Pivot Lookback: Default 5. How many bars are needed to confirm a pivot point. Lower (3) = more signals. Higher (8-10) = fewer but stronger divergences.
 
Max Divergence Width: Default 60. Maximum bars allowed between two pivots forming a divergence. On daily charts, 60 bars is roughly 3 months.
 
Recommended settings by timeframe:
- Daily: Pivot 5, Width 60 (default)
- 4H: Pivot 5, Width 100
- Weekly: Pivot 3, Width 30
- 1H: Pivot 5, Width 120
 
Hidden divergence is OFF by default. Learn to read regular divergences first, then enable hidden for trend continuation signals.
 
🔔 Alerts
 
Built-in alert conditions for: Bullish Divergence, Bearish Divergence, Hidden Bullish, Hidden Bearish, Any Regular, and Any Divergence.
 
⚠️ Important Notes
 
Divergence signals appear with a delay equal to the Pivot Lookback setting (default 5 bars) because the indicator needs bars after a potential pivot to confirm it was a real turning point. This is by design accuracy over speed.
 
Divergence is a warning signal, not an entry trigger. Use it alongside other technical analysis, price action, and your own risk management. Not every divergence leads to a reversal.
 
This indicator is for educational and informational purposes only. Not financial advice.

## Source Code

````pine
//@version=5
indicator("RSI Divergence Detector", shorttitle="RSI Div", overlay=false, max_labels_count=500, max_lines_count=500)

// ============================================================
// INPUTS
// ============================================================
rsiLen      = input.int(14, "RSI Length", minval=2, maxval=50, group="RSI Settings")
rsiSource   = input.source(close, "RSI Source", group="RSI Settings")

pivotLook   = input.int(5, "Pivot Lookback", minval=2, maxval=20, group="Divergence Detection", tooltip="How many bars to confirm a pivot. 5 = default, 3 = more signals, 8+ = fewer but stronger.")
divLookback = input.int(60, "Max Divergence Width", minval=10, maxval=200, group="Divergence Detection", tooltip="Maximum bars between two pivots. 60 = ~3 months on daily.")

showBull    = input.bool(true, "Show Bullish Divergence", group="Display")
showBear    = input.bool(true, "Show Bearish Divergence", group="Display")
showHidden  = input.bool(false, "Show Hidden Divergence", group="Display", tooltip="Hidden divergences signal trend continuation rather than reversal.")
showLabels  = input.bool(true, "Show Labels", group="Display")

// Colors
bullCol     = input.color(color.rgb(0, 230, 118), "Bullish Color", group="Colors")
bearCol     = input.color(color.rgb(255, 82, 82), "Bearish Color", group="Colors")
hidBullCol  = input.color(color.rgb(0, 150, 80), "Hidden Bullish Color", group="Colors")
hidBearCol  = input.color(color.rgb(180, 50, 50), "Hidden Bearish Color", group="Colors")

// ============================================================
// RSI CALCULATION
// ============================================================
rsiVal = ta.rsi(rsiSource, rsiLen)

// ============================================================
// RSI PLOT
// ============================================================
rsiMid = hline(50, "Midline", color=color.new(color.gray, 70), linestyle=hline.style_dotted)
rsiOB  = hline(70, "Overbought", color=color.new(bearCol, 70), linestyle=hline.style_dotted)
rsiOS  = hline(30, "Oversold", color=color.new(bullCol, 70), linestyle=hline.style_dotted)

fill(rsiOB, rsiMid, color=color.new(bearCol, 92), title="Overbought Zone")
fill(rsiOS, rsiMid, color=color.new(bullCol, 92), title="Oversold Zone")

rsiColor = rsiVal >= 70 ? color.new(bearCol, 20) : rsiVal <= 30 ? color.new(bullCol, 20) : color.new(color.white, 30)
plot(rsiVal, "RSI", color=rsiColor, linewidth=2)

// ============================================================
// PIVOT DETECTION
// ============================================================
pivotHigh = ta.pivothigh(rsiVal, pivotLook, pivotLook)
pivotLow  = ta.pivotlow(rsiVal, pivotLook, pivotLook)

// Track previous pivot locations and values
var float prevPH_rsi   = na
var float prevPH_price = na
var int   prevPH_bar   = na

var float prevPL_rsi   = na
var float prevPL_price = na
var int   prevPL_bar   = na

// Current bar offset for pivot (pivots confirm pivotLook bars late)
currBar = bar_index - pivotLook

// ============================================================
// DIVERGENCE DETECTION & PLOTTING
// ============================================================
// Track divergence events for alerts and chart markers
var bool bearDivEvent = false
var bool bullDivEvent = false
var bool hidBearDivEvent = false
var bool hidBullDivEvent = false
bearDivEvent := false
bullDivEvent := false
hidBearDivEvent := false
hidBullDivEvent := false

// --- BEARISH DIVERGENCE: Price higher high, RSI lower high ---
if not na(pivotHigh)
    currPH_rsi   = pivotHigh
    currPH_price = high[pivotLook]
    
    if not na(prevPH_rsi) and not na(prevPH_bar)
        barDiff = currBar - prevPH_bar
        
        if barDiff > 0 and barDiff <= divLookback
            // Regular bearish: price HH, RSI LH
            if showBear and currPH_price > prevPH_price and currPH_rsi < prevPH_rsi
                // RSI panel line
                line.new(prevPH_bar, prevPH_rsi, currBar, currPH_rsi, color=bearCol, width=2, style=line.style_solid)
                if showLabels
                    label.new(currBar, currPH_rsi + 3, "▼ BEAR", style=label.style_none, textcolor=bearCol, size=size.small)
                bearDivEvent := true
            
            // Hidden bearish: price LH, RSI HH
            if showHidden and currPH_price < prevPH_price and currPH_rsi > prevPH_rsi
                line.new(prevPH_bar, prevPH_rsi, currBar, currPH_rsi, color=hidBearCol, width=2, style=line.style_dashed)
                if showLabels
                    label.new(currBar, currPH_rsi + 3, "▼ H.BEAR", style=label.style_none, textcolor=hidBearCol, size=size.tiny)
                hidBearDivEvent := true
    
    prevPH_rsi   := currPH_rsi
    prevPH_price := currPH_price
    prevPH_bar   := currBar

// --- BULLISH DIVERGENCE: Price lower low, RSI higher low ---
if not na(pivotLow)
    currPL_rsi   = pivotLow
    currPL_price = low[pivotLook]
    
    if not na(prevPL_rsi) and not na(prevPL_bar)
        barDiff = currBar - prevPL_bar
        
        if barDiff > 0 and barDiff <= divLookback
            // Regular bullish: price LL, RSI HL
            if showBull and currPL_price < prevPL_price and currPL_rsi > prevPL_rsi
                line.new(prevPL_bar, prevPL_rsi, currBar, currPL_rsi, color=bullCol, width=2, style=line.style_solid)
                if showLabels
                    label.new(currBar, currPL_rsi - 3, "▲ BULL", style=label.style_none, textcolor=bullCol, size=size.small)
                bullDivEvent := true
            
            // Hidden bullish: price HL, RSI LL
            if showHidden and currPL_price > prevPL_price and currPL_rsi < prevPL_rsi
                line.new(prevPL_bar, prevPL_rsi, currBar, currPL_rsi, color=hidBullCol, width=2, style=line.style_dashed)
                if showLabels
                    label.new(currBar, currPL_rsi - 3, "▲ H.BULL", style=label.style_none, textcolor=hidBullCol, size=size.tiny)
                hidBullDivEvent := true
    
    prevPL_rsi   := currPL_rsi
    prevPL_price := currPL_price
    prevPL_bar   := currBar

// ============================================================
// CHART OVERLAY SIGNALS (plotted on price chart via separate pane)
// These appear as colored markers on the RSI panel at the edges
// to draw attention without cluttering
// ============================================================
// Bearish divergence — red triangle at top of RSI panel
plotshape(bearDivEvent, title="Bearish Div Signal", style=shape.triangledown, location=location.top, offset=-pivotLook, color=bearCol, size=size.small)

// Bullish divergence — green triangle at bottom of RSI panel
plotshape(bullDivEvent, title="Bullish Div Signal", style=shape.triangleup, location=location.bottom, offset=-pivotLook, color=bullCol, size=size.small)

// Hidden divergences — smaller markers
plotshape(hidBearDivEvent, title="Hidden Bear Signal", style=shape.triangledown, location=location.top, offset=-pivotLook, color=hidBearCol, size=size.tiny)
plotshape(hidBullDivEvent, title="Hidden Bull Signal", style=shape.triangleup, location=location.bottom, offset=-pivotLook, color=hidBullCol, size=size.tiny)

// ============================================================
// ALERTS
// ============================================================
alertcondition(bearDivEvent, title="Bearish Divergence", message="RSI Bearish Divergence — price higher high, RSI lower high")
alertcondition(bullDivEvent, title="Bullish Divergence", message="RSI Bullish Divergence — price lower low, RSI higher low")
alertcondition(hidBearDivEvent, title="Hidden Bearish Divergence", message="RSI Hidden Bearish Divergence — price lower high, RSI higher high")
alertcondition(hidBullDivEvent, title="Hidden Bullish Divergence", message="RSI Hidden Bullish Divergence — price higher low, RSI lower low")
alertcondition(bearDivEvent or bullDivEvent, title="Any Regular Divergence", message="RSI Divergence detected")
alertcondition(bearDivEvent or bullDivEvent or hidBearDivEvent or hidBullDivEvent, title="Any Divergence", message="RSI Divergence detected (regular or hidden)")
````
