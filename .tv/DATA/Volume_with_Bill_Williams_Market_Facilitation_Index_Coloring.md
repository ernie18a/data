<!-- tradingview-pine-id: PUB;70b323f40cf24494a36e38e29d758c46 -->
<!-- tradingviewscripts-format: 1 -->
# Volume with Bill Williams Market Facilitation Index Coloring

Source: https://www.tradingview.com/script/RmaBpxqH-Volume-with-Bill-Williams-Market-Facilitation-Index-Coloring/

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

---

## Source Code

````pine
// © OlekBard

//@version=6
indicator("Volume with Bill Williams Market Facilitation Index Coloring", shorttitle="Vol+BW MFI", overlay=false, format=format.volume)

// ───── GENERAL SETTINGS ─────

enableMFI = input.bool(true, "Enable BW MFI Coloring")
showVolumeMA = input.bool(false, "Show Volume Moving Average")
maLength = input.int(20, "Volume MA Length", minval=1)

// ───── BW MFI COLOR SETTINGS ─────

enableGreen = input.bool(true, "Enable Green (Range Up + Volume Up)")
enableBlue  = input.bool(true, "Enable Blue (Range Up + Volume Down)")
enablePink  = input.bool(true, "Enable Pink (Range Down + Volume Up)")
enableBrown = input.bool(true, "Enable Brown (Range Down + Volume Down)")

greenColor = input.color(color.green, "Green Color")
blueColor  = input.color(color.blue, "Blue Color")
pinkColor  = input.color(color.rgb(255,105,180), "Pink Color")
brownColor = input.color(color.rgb(139,69,19), "Brown Color")

// ───── NORMAL VOLUME COLORS ─────

upVolColor = input.color(#009688, "Up Volume Color")
downVolColor = input.color(#F44336, "Down Volume Color")

// ───── CALCULATIONS ─────

rangeNow = high - low
rangePrev = high[1] - low[1]

rangeUp = rangeNow > rangePrev
volumeUp = volume > volume[1]

volMA = ta.sma(volume, maLength)

// ───── BW MFI LOGIC ─────

color mfiColor = na

mfiColor :=
     rangeUp and volumeUp ? (enableGreen ? greenColor : na) :
     rangeUp and not volumeUp ? (enableBlue ? blueColor : na) :
     not rangeUp and volumeUp ? (enablePink ? pinkColor : na) :
     (enableBrown ? brownColor : na)

// ───── NORMAL VOLUME LOGIC ─────

color normalColor = close >= open ? upVolColor : downVolColor

// ───── FINAL COLOR ─────

color finalColor = enableMFI ? nz(mfiColor, normalColor) : normalColor

// ───── PLOTS ─────

plot(volume, title="Volume", style=plot.style_histogram, color=finalColor, linewidth=2, format=format.volume)

plot(showVolumeMA ? volMA : na, title="Volume MA", color=color.yellow, linewidth=1, format=format.volume)
````
