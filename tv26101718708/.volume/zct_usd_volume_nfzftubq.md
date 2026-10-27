# ZCT USD Volume

- url: https://www.tradingview.com/script/NfzFtUbq-ZCT-USD-Volume/
- type: indicator
- pine_id: PUB;c048c144556840d69b0a70d52f7c1eba
- version: 3.0

## Description

A clean USD-denominated volume indicator that converts raw volume into dollar terms (volume × price), giving you a true measure of capital flow rather than contract count.

Bullish and bearish bars are colour-coded for instant readability, with a 60-period moving average to smooth out noise and highlight volume trends. MA length is fully adjustable from the settings panel.

Built for traders who want to see where real money is moving. A core part of the ZCT indicator suite.

## Source Code

````pine
//@version=6
indicator("USD Volume", shorttitle="ZCT USDVol", format=format.volume, overlay=false)




// ── Inputs ────────────────────────────────────────────────
maLength = input.int(60, title="MA Length", minval=1)




// ── Calculations ──────────────────────────────────────────
usdVolume = volume * close
bullish   = close >= open


//checkpoint

// ── Colours ───────────────────────────────────────────────
bullColor = color.new(#888c98, 0)   // light grey
bearColor = color.new(#434651, 0)   // dark grey
maColor   = color.new(#62c1bf, 0)   // signature teal




barColor  = bullish ? bullColor : bearColor




// ── Plots ─────────────────────────────────────────────────
plot(usdVolume,
    style  = plot.style_columns,
    color  = barColor,
    title  = "USD Volume")




plot(ta.sma(usdVolume, maLength),
    color     = maColor,
    linewidth = 2,
    title     = "Volume MA")




// ── ZCT Branding ──────────────────────────────────────────
var table brandingTable = table.new(position.bottom_left, 1, 1)
table.cell(brandingTable, 0, 0, "ZCT",
    text_color = maColor,
    text_size  = size.small,
    bgcolor    = color.new(color.black, 100))
````
