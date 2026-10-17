# Volume with Bill Williams Market Facilitation Index Coloring

- url: https://www.tradingview.com/script/RmaBpxqH-Volume-with-Bill-Williams-Market-Facilitation-Index-Coloring/
- type: indicator
- pine_id: PUB;70b323f40cf24494a36e38e29d758c46
- version: 2.0

## Description

Volume indicator with Bill Williams Market Facilitation Index (BW MFI) coloring.

This indicator applies Bill Williams' BW MFI color logic to volume analysis by comparing price range changes (High-Low) and volume changes.

Market states:

🟢 Green — Range Up + Volume Up
Increasing range and increasing volume indicate strong market activity and participation.

🔵 Blue — Range Up + Volume Down
Price range expands while volume decreases, showing movement with weaker participation.

🩷 Pink — Range Down + Volume Up
Volume increases while price range decreases, indicating a possible battle between buyers and sellers.

🟤 Brown — Range Down + Volume Down
Both range and volume decrease, showing reduced market activity.

Features:
• BW MFI color-based volume analysis
• Optional Volume Moving Average
• Customizable colors

Based on Bill Williams' Market Facilitation Index methodology.

## Source Code

````pine
// © OlekBard

//@version=6
indicator(
     "Volume with Bill Williams Market Facilitation Index Coloring",
     shorttitle="Vol+BW MFI",
     overlay=false,
     format=format.volume
)

// Settings
enableMFI = input.bool(true, "Enable BW MFI Coloring")
showVolumeMA = input.bool(false, "Show Volume Moving Average")
maLength = input.int(20, "Volume MA Length", minval=1)

// BW MFI colors
enableGreen = input.bool(true, "Enable Market Facilitation (Green)")
enableBlue  = input.bool(true, "Enable Fake (Blue)")
enablePink  = input.bool(true, "Enable Squat (Pink)")
enableBrown = input.bool(true, "Enable Fade (Brown)")

greenColor = input.color(color.green, "Green Color — Market Facilitation")
blueColor  = input.color(color.blue, "Blue Color — Fake")
pinkColor  = input.color(color.rgb(255, 105, 180), "Pink Color — Squat")
brownColor = input.color(color.rgb(139, 69, 19), "Brown Color — Fade")

upVolColor = input.color(#009688, "Up Volume Color")
downVolColor = input.color(#F44336, "Down Volume Color")

// BW MFI
float mfi = na

if not na(volume) and volume > 0
    mfi := ((high - low) / volume) * 1000000000000.0

// MFI direction
int mfiDirection = na

if not na(mfi) and not na(mfi[1])
    if mfi > mfi[1]
        mfiDirection := 1
    else if mfi < mfi[1]
        mfiDirection := -1

// Volume direction
int volumeDirection = na

if not na(volume) and not na(volume[1])
    if volume > volume[1]
        volumeDirection := 1
    else if volume < volume[1]
        volumeDirection := -1

// BW MFI state
color mfiColor = na

if mfiDirection == 1 and volumeDirection == 1
    if enableGreen
        mfiColor := greenColor
else if mfiDirection == 1 and volumeDirection == -1
    if enableBlue
        mfiColor := blueColor
else if mfiDirection == -1 and volumeDirection == 1
    if enablePink
        mfiColor := pinkColor
else if mfiDirection == -1 and volumeDirection == -1
    if enableBrown
        mfiColor := brownColor

// Normal volume color
color normalColor = close >= open ? upVolColor : downVolColor

// Final color
color finalColor = enableMFI and not na(mfiColor) ? mfiColor : normalColor

// Volume
plot(
     volume,
     title="Volume",
     style=plot.style_histogram,
     color=finalColor,
     linewidth=2
)

// Volume MA
plot(
     showVolumeMA ? ta.sma(volume, maLength) : na,
     title="Volume MA",
     color=color.yellow,
     linewidth=1
)
````
