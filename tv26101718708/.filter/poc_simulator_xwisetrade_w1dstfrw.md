# POC Simulator [XWiseTrade]

- url: https://www.tradingview.com/script/w1DstFrw-POC-Simulator-XWiseTrade/
- type: indicator
- pine_id: PUB;64681ad44b1f434e9c6d2e0d19c563eb
- version: 1.0

## Description

Real-time Point of Control (POC) for the current candle using lower timeframe volume data.

This indicator calculates the price level with the highest traded volume within the current bar (based on 1s to 15min data) — a dynamic approximation of the developing POC.

Features:
• Selectable lower timeframe source (1s, 15s, 1, 3, 5, 15min)
• Clean POC line + price label
• Lightweight and responsive

Perfect for intraday traders identifying developing value areas and potential support/resistance.

## Source Code

````pine
//@version=6
indicator("POC Simulator [XWiseTrade]", overlay=true, max_lines_count=200)

// === Inputs ===
group_settings = "Settings"
lowTF    = input.string("1", "Lower Timeframe Source", options=["1S","15S","1","3","5","15"], group=group_settings)
showPOC  = input.bool(true, "Show POC Line", group=group_settings)
colorPOC = input.color(color.purple, "POC Color", group=group_settings)

// === Convert input to Pine timeframe ===
low_tf = lowTF == "1S" ? "1S" :
         lowTF == "15S" ? "15S" :
         lowTF

// === POC Calculation Function ===
getPOC() =>
    [lowCloses, lowVols] = request.security_lower_tf(syminfo.tickerid, low_tf, [close, volume])
    sz = array.size(lowCloses)
    if sz == 0
        na
    else
        float totalVol = 0.0
        for i = 0 to sz - 1
            totalVol += array.get(lowVols, i)
        
        float bestVal = na
        float bestRatio = 0.0
        if totalVol > 0
            for i = 0 to sz - 1
                float v = array.get(lowVols, i)
                float r = v / totalVol
                if r > bestRatio
                    bestRatio := r
                    bestVal := array.get(lowCloses, i)
        bestVal

// === Plot POC ===
pocValue = showPOC ? getPOC() : na
plot(pocValue, "POC", color=colorPOC, linewidth=2, style=plot.style_linebr)

// === Label ===
if showPOC and not na(pocValue) and barstate.islast
    label.new(bar_index, pocValue, 
         text="POC: " + str.tostring(pocValue, format.price), 
         style=label.style_label_left, 
         color=color.new(colorPOC, 30), 
         textcolor=color.white, 
         size=size.normal)
````
