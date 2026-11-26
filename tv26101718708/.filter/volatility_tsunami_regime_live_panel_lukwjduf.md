# Volatility Tsunami Regime + Live Panel

- url: https://www.tradingview.com/script/lukwJDuf-Volatility-Tsunami-Regime-Live-Panel/
- type: indicator
- pine_id: PUB;661c627beb35483dbbe062e6627374d4
- version: 1.0

## Description

Taken from the individual below and updated with a live panel showing both conditions:
https://www.tradingview.com/script/lbSYjz9M-Volatility-Tsunami-Regime/

## Source Code

````pine
//@version=6
indicator("Volatility Tsunami Regime + Live Panel", overlay=true, max_labels_count=500, max_boxes_count=500)

// --- Inputs ---
len          = input.int(20,   title="StdDev Length",          minval=1)
vixThresh    = input.float(0.86, title="VIX SD Threshold",     step=0.01)
vvixThresh   = input.float(3.16, title="VVIX SD Threshold",    step=0.01)
showPanel    = input.bool(true,  title="Show Live Panel")
panelPos     = input.string("Top Right", "Panel Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"])

// --- Data Fetching & Calculations ---
vixClose   = request.security("CBOE:VIX",   timeframe.period, close)
vvixClose  = request.security("CBOE:VVIX",  timeframe.period, close)

vixStdDev  = ta.stdev(vixClose,  len)
vvixStdDev = ta.stdev(vvixClose, len)

// --- Conditions ---
isVixBelow  = vixStdDev  < vixThresh
isVvixBelow = vvixStdDev < vvixThresh
bothBelow   = isVixBelow and isVvixBelow
oneBelow    = isVixBelow or isVvixBelow

// --- Background Coloring ---
bgColor = bothBelow ? color.new(color.red,   80) :
          oneBelow  ? color.new(color.orange,80) : na
bgcolor(bgColor, title="Tsunami Regime Background")

// === LIVE INFO PANEL ===
if showPanel and barstate.islast
    // Determine position
    var pos = panelPos == "Top Left" ? position.top_left :
              panelPos == "Top Right" ? position.top_right :
              panelPos == "Bottom Left" ? position.bottom_left : position.bottom_right

    var table infoPanel = table.new(
        position     = pos,
        columns      = 3,
        rows         = 4,
        bgcolor      = color.new(color.black, 80),
        border_width = 1,
        frame_color  = color.gray
    )

    // Header
    table.cell(infoPanel, 0, 0, "Metric",  text_color = color.white, bgcolor = color.new(#1e222d, 0))
    table.cell(infoPanel, 1, 0, "Value",   text_color = color.white, bgcolor = color.new(#1e222d, 0))
    table.cell(infoPanel, 2, 0, "Status",  text_color = color.white, bgcolor = color.new(#1e222d, 0))

    // VIX SD Row
    vixColor = isVixBelow ? color.lime : color.red
    table.cell(infoPanel, 0, 1, "VIX 20d SD", text_color = color.white)
    table.cell(infoPanel, 1, 1, str.tostring(vixStdDev, "#.##"), text_color = vixColor)
    table.cell(infoPanel, 2, 1, isVixBelow ? "BELOW" : "ABOVE", text_color = vixColor)

    // VVIX SD Row
    vvixColor = isVvixBelow ? color.lime : color.red
    table.cell(infoPanel, 0, 2, "VVIX 20d SD", text_color = color.white)
    table.cell(infoPanel, 1, 2, str.tostring(vvixStdDev, "#.##"), text_color = vvixColor)
    table.cell(infoPanel, 2, 2, isVvixBelow ? "BELOW" : "ABOVE", text_color = vvixColor)

    // Overall Regime Row
    regimeText  = bothBelow ? "DOUBLE COMPRESSION (RED)" :
                  oneBelow  ? "SINGLE COMPRESSION (ORANGE)" : "NORMAL"
    regimeColor = bothBelow ? color.red : oneBelow ? color.orange : color.gray

    table.cell(infoPanel, 0, 3, "REGIME",      text_color = color.white, bgcolor = color.new(#1e222d, 0))
    table.cell(infoPanel, 1, 3, regimeText,    text_color = regimeColor, bgcolor = color.new(#1e222d, 0))

// Optional: SD plots
plot(vixStdDev,  "VIX 20d SD",  color=color.red,   linewidth=2)
plot(vvixStdDev, "VVIX 20d SD", color=color.blue,  linewidth=2)
````
