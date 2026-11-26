# Relative Volume (RVOL) Surge Dashboard

- url: https://www.tradingview.com/script/WaRrdQae-Relative-Volume-RVOL-Surge-Dashboard/
- type: indicator
- pine_id: PUB;58220290704a4f9f8c1ac4265cf201ed
- version: 1.0

## Description

Overview
The **Relative Volume (RVOL) Surge Dashboard** is a utility script designed to visually isolate institutional activity and anomalies in volume. In financial markets, sudden volume spikes that double the recent average often signal institutional presence, news-driven breakouts, or potential trend exhaustion points.

This indicator keeps your main chart clean while feeding you live volume metrics via an on-chart HUD (Heads-Up Display).

 Key Features
* **Live Relative Volume Multiplier: ** Instantly displays exactly how many times the current bar's volume is exceeding its standard historical moving average (e.g., 1.54x, 3.10x).
* **Smart UI Dashboard: ** A customizable, clean panel that switches colors (Green/Red) immediately depending on whether a 2x volume surge is active or normal.
* **On-Chart Signals: ** Draws a clean yellow cross at the bottom of the price bar whenever a volume anomaly occurs.
* **Built-in Alert Engine: ** Supports native Trading View alert conditions so you can receive push notifications, email, or webhook alerts the exact second a volume anomaly prints.

 How to Use It
1. **Trend Breakout Confirmation: ** Look for the dashboard to trigger a green "2x ALERT: ACTIVE" during a consolidation breakout. High volume confirms validity.
2. **Climactic Reversals: ** If a stock has been in an extended downtrend/uptrend and suddenly prints a massive 2x+ volume spike without making significant price progress, look for a potential reversal.
3. **Customization: ** Use the settings panel to change the lookback period (default is 20 bars) or move the dashboard to any corner of your screen to prevent overlapping other indicators.

DISCLAIMER: 
This script is created for educational, informational, and utility purposes only. It does not constitute financial, investment, or trading advice. Past performance of any volume metrics or technical signals is not indicative of future results. Financial markets involve substantial risk of loss, and individual traders are entirely responsible for their own capital allocation and risk management. Always perform your own due diligence before entering any trade.

## Source Code

````pine
//@version=6
indicator("Volume 2x Dashboard Alert", overlay=true, max_bars_back=500)

// ==========================================
// 1. INPUTS
// ==========================================
int volAvgLen   = input.int(20, "Lookback Period (Bars)", minval=1, tooltip="Calculates the moving average of volume over this period.")
string dbPos    = input.string("Top Right", "Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"])

// Logic to determine table position
var string pos = switch dbPos
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    => position.bottom_left

// ==========================================
// 2. CALCULATIONS
// ==========================================
float volAvg    = ta.sma(volume, volAvgLen)
float relVol    = volAvg > 0 ? volume / volAvg : 0.0
bool isVol2x    = volume >= (volAvg * 2)

// Determine Color and Text
color volColor  = isVol2x ? color.new(color.green, 20) : color.new(color.red, 20)
string statusTxt = isVol2x ? "2x ALERT: ACTIVE" : "VOLUME: NORMAL"
string multiplier = str.tostring(relVol, "#.##") + "x"

// ==========================================
// 3. DASHBOARD RENDERING
// ==========================================
// Explicitly declare table size and style
var table volDash = table.new(pos, 2, 2, bgcolor=color.new(color.black, 40), border_width=1, border_color=color.gray)

if barstate.islast
    // Header Row
    table.cell(volDash, 0, 0, "VOL MULTIPLIER", text_color=color.white, bgcolor=color.new(color.blue, 30))
    table.cell(volDash, 1, 0, multiplier, text_color=color.white, bgcolor=color.new(color.blue, 30))
    
    // Status Row (Merged)
    table.cell(volDash, 0, 1, statusTxt, text_color=color.white, bgcolor=volColor)
    table.merge_cells(volDash, 0, 1, 1, 1)

// ==========================================
// 4. ALERTS & PLOTS
// ==========================================
// Added a native alert condition so users can actually set real-time notifications
alertcondition(isVol2x, title="Volume 2x Spike Alert", message="Volume Spike Detected! Relative Volume: {{plot_0}}")

// Visual Plot on Chart
plotshape(isVol2x, title="Vol 2x Spike", style=shape.xcross, location=location.bottom, color=color.yellow, size=size.tiny)
// Hidden plot used to pass the exact multiplier value dynamically into the alert message if needed
plot(relVol, title="Relative Volume Value", display=display.none)
````
