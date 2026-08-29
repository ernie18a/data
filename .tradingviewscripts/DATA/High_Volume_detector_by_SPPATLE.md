<!-- tradingview-pine-id: PUB;523a0f68c8484b2b8c25cf9d2a50ba25 -->
<!-- tradingviewscripts-format: 1 -->
# High Volume detector by SPPATLE

Source: https://www.tradingview.com/script/iY7ts7vL-High-Volume-detector-by-SPPATLE/

## Description

this indicatoer detects high volume and highlights candles

---

## Source Code

````pine
//@spp2788
//
//@spp2788@gmail.com


//@version=6
indicator("High Volume detector by SPPATLE", overlay=true)

// ==========================================
// SETTINGS & INPUTS (GROUPED IN STYLE)
// ==========================================
volLen     = input.int(100, "Volume Average Length", minval=1, group="Style")
volMult    = input.float(1.5, "Volume Multiplier (RVOL)", step=0.1, group="Style")
lineWidth  = input.int(2, "Highlight Line Thickness", minval=1, maxval=5, group="Style")

// ==========================================
// VOLUME HIGHLIGHT LOGIC
// ==========================================
avgVol = ta.sma(volume, volLen)
isHighVol = avgVol > 0 and (volume >= avgVol * volMult)

var line highVolLine = na
if isHighVol
    highVolLine := line.new(x1=bar_index, y1=high, x2=bar_index, y2=low, extend=extend.both, color=color.new(color.gray, 50), width=lineWidth)

barcolor(isHighVol ? color.gray : na)
````
