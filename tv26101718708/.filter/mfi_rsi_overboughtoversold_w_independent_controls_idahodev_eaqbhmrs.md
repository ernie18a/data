# MFI + RSI Overbought/Oversold w/ Independent Controls [idahodev]

- url: https://www.tradingview.com/script/eaQbhmRS-MFI-RSI-Overbought-Oversold-w-Independent-Controls-idahodev/
- type: indicator
- pine_id: PUB;71ac93e2c4b44b0e903668b25e37c7c1
- version: 1.0

## Description

This indicator displays the Money Flow Index (MFI) and Relative Strength Index (RSI) together in a single oscillator pane, with fully independent settings for each.

Both MFI and RSI can be customized with separate source inputs, lengths, smoothing types, smoothing lengths, overbought thresholds, and oversold thresholds. This makes it easier to compare price momentum and volume-weighted momentum without forcing both oscillators to use the same settings.

The script also includes conditional threshold fills. When RSI or MFI moves above its configured overbought level, the area between the oscillator line and the overbought threshold is filled. When RSI or MFI moves below its configured oversold level, the area between the oscillator line and the oversold threshold is filled. Fill colors and opacity can be customized independently for each oscillator and condition.

Features:
- Combined RSI and MFI oscillator display
- Independent RSI and MFI lengths
- Independent RSI and MFI smoothing
- SMA, EMA, RMA, WMA, or no smoothing
- Independent overbought and oversold levels
- Conditional overbought and oversold fills
- Custom fill colors and opacity
- Useful for spotting momentum extremes, divergences, and confluence between RSI and MFI

This indicator does not generate buy or sell signals by itself. It is intended as a visual analysis tool for identifying momentum conditions and possible exhaustion zones.

## Source Code

````pine
//@version=6
indicator(title="MFI + RSI Independent Settings with Conditional Fills", shorttitle="MFI/RSI Fills", overlay=false, precision=2)

mfiSource = input.source(defval=hlc3, title="MFI Source", group="MFI")
mfiLength = input.int(defval=14, title="MFI Length", minval=1, group="MFI")
mfiSmoothingType = input.string(defval="None", title="MFI Smoothing Type", options=["None", "SMA", "EMA", "RMA", "WMA"], group="MFI")
mfiSmoothingLength = input.int(defval=3, title="MFI Smoothing Length", minval=1, group="MFI")
mfiOverbought = input.float(defval=80.0, title="MFI Overbought", minval=0.0, maxval=100.0, step=0.5, group="MFI")
mfiOversold = input.float(defval=20.0, title="MFI Oversold", minval=0.0, maxval=100.0, step=0.5, group="MFI")

rsiSource = input.source(defval=close, title="RSI Source", group="RSI")
rsiLength = input.int(defval=14, title="RSI Length", minval=1, group="RSI")
rsiSmoothingType = input.string(defval="None", title="RSI Smoothing Type", options=["None", "SMA", "EMA", "RMA", "WMA"], group="RSI")
rsiSmoothingLength = input.int(defval=3, title="RSI Smoothing Length", minval=1, group="RSI")
rsiOverbought = input.float(defval=70.0, title="RSI Overbought", minval=0.0, maxval=100.0, step=0.5, group="RSI")
rsiOversold = input.float(defval=30.0, title="RSI Oversold", minval=0.0, maxval=100.0, step=0.5, group="RSI")

showConditionalFills = input.bool(defval=true, title="Show Conditional Fills", group="Fills")

mfiOverboughtFillBaseColor = input.color(defval=color.red, title="MFI Overbought Fill Color", group="Fills")
mfiOversoldFillBaseColor = input.color(defval=color.green, title="MFI Oversold Fill Color", group="Fills")
rsiOverboughtFillBaseColor = input.color(defval=color.orange, title="RSI Overbought Fill Color", group="Fills")
rsiOversoldFillBaseColor = input.color(defval=color.blue, title="RSI Oversold Fill Color", group="Fills")

mfiOverboughtFillOpacity = input.int(defval=65, title="MFI Overbought Fill Opacity", minval=0, maxval=100, group="Fills")
mfiOversoldFillOpacity = input.int(defval=65, title="MFI Oversold Fill Opacity", minval=0, maxval=100, group="Fills")
rsiOverboughtFillOpacity = input.int(defval=55, title="RSI Overbought Fill Opacity", minval=0, maxval=100, group="Fills")
rsiOversoldFillOpacity = input.int(defval=55, title="RSI Oversold Fill Opacity", minval=0, maxval=100, group="Fills")

smoothOscillator(src, smoothingType, smoothingLength) =>
    switch smoothingType
        "SMA" => ta.sma(src, smoothingLength)
        "EMA" => ta.ema(src, smoothingLength)
        "RMA" => ta.rma(src, smoothingLength)
        "WMA" => ta.wma(src, smoothingLength)
        => src

mfiRaw = ta.mfi(mfiSource, mfiLength)
rsiRaw = ta.rsi(rsiSource, rsiLength)

mfiValue = smoothOscillator(mfiRaw, mfiSmoothingType, mfiSmoothingLength)
rsiValue = smoothOscillator(rsiRaw, rsiSmoothingType, rsiSmoothingLength)

hline(100.0, title="Upper Bound", color=color.new(color.gray, 85), linestyle=hline.style_solid)
hline(50.0, title="Midline", color=color.new(color.gray, 60), linestyle=hline.style_dotted)
hline(0.0, title="Lower Bound", color=color.new(color.gray, 85), linestyle=hline.style_solid)

hline(mfiOverbought, title="MFI Overbought", color=color.new(color.green, 35), linestyle=hline.style_dashed)
hline(mfiOversold, title="MFI Oversold", color=color.new(color.green, 35), linestyle=hline.style_dashed)
hline(rsiOverbought, title="RSI Overbought", color=color.new(color.blue, 35), linestyle=hline.style_dotted)
hline(rsiOversold, title="RSI Oversold", color=color.new(color.blue, 35), linestyle=hline.style_dotted)

mfiPlot = plot(mfiValue, title="MFI", color=color.new(color.green, 0), linewidth=2)
rsiPlot = plot(rsiValue, title="RSI", color=color.new(color.blue, 0), linewidth=2)

mfiOverboughtFillBoundary = plot(mfiOverbought, title="MFI Overbought Fill Boundary", color=color.new(color.white, 100), editable=false, display=display.none)
mfiOversoldFillBoundary = plot(mfiOversold, title="MFI Oversold Fill Boundary", color=color.new(color.white, 100), editable=false, display=display.none)
rsiOverboughtFillBoundary = plot(rsiOverbought, title="RSI Overbought Fill Boundary", color=color.new(color.white, 100), editable=false, display=display.none)
rsiOversoldFillBoundary = plot(rsiOversold, title="RSI Oversold Fill Boundary", color=color.new(color.white, 100), editable=false, display=display.none)

mfiOverboughtFillTransparency = 100 - mfiOverboughtFillOpacity
mfiOversoldFillTransparency = 100 - mfiOversoldFillOpacity
rsiOverboughtFillTransparency = 100 - rsiOverboughtFillOpacity
rsiOversoldFillTransparency = 100 - rsiOversoldFillOpacity

mfiOverboughtFillColor = showConditionalFills and mfiValue >= mfiOverbought ? color.new(mfiOverboughtFillBaseColor, mfiOverboughtFillTransparency) : na
mfiOversoldFillColor = showConditionalFills and mfiValue <= mfiOversold ? color.new(mfiOversoldFillBaseColor, mfiOversoldFillTransparency) : na
rsiOverboughtFillColor = showConditionalFills and rsiValue >= rsiOverbought ? color.new(rsiOverboughtFillBaseColor, rsiOverboughtFillTransparency) : na
rsiOversoldFillColor = showConditionalFills and rsiValue <= rsiOversold ? color.new(rsiOversoldFillBaseColor, rsiOversoldFillTransparency) : na

fill(mfiPlot, mfiOverboughtFillBoundary, color=mfiOverboughtFillColor, title="MFI Overbought Fill", fillgaps=false)
fill(mfiPlot, mfiOversoldFillBoundary, color=mfiOversoldFillColor, title="MFI Oversold Fill", fillgaps=false)
fill(rsiPlot, rsiOverboughtFillBoundary, color=rsiOverboughtFillColor, title="RSI Overbought Fill", fillgaps=false)
fill(rsiPlot, rsiOversoldFillBoundary, color=rsiOversoldFillColor, title="RSI Oversold Fill", fillgaps=false)
````
