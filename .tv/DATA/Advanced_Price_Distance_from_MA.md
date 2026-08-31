<!-- tradingview-pine-id: PUB;5f9a0a6b78384e4d852a9237748cb3c5 -->
<!-- tradingviewscripts-format: 1 -->
# Advanced Price Distance from MA

Source: https://www.tradingview.com/script/BZgDiTrn/

## Description

What does this indicator do for us? 🤔
It displays on a separate chart exactly how far the stock price is from the 150 MA in percentages.
The idea (just like Micha talks about a lot) is to easily spot when the stock is in a healthy uptrend and when it's overextended—"stretched too far" like a rubber band and due for a correction.

Key features included:
 👇📏 Percentage Distance Chart directly from the 150 MA.

🛣️ Smart Threshold Bands selectable in fixed percentages or dynamic ATR (which automatically adjusts to the stock’s volatility).

🎨 Automatic Color Changing: Green above zero, red below zero, and the moment it breaks the bands—it turns bright yellow to warn that we've reached a heavily overextended zone.

🚩 Distance Flags at Extremes: The oscillator automatically detects turning points and places a small flag with the exact percentage value.Of course, all settings, label sensitivity, and colors can be fully customized in the settings menu.

---

## Source Code

````pine
//@version=6
indicator("Advanced Price Distance from MA", overlay=false, precision=2)

// ==========================================
// 1. INPUTS
// ==========================================
// Moving Average Settings
maGroup        = "MA Settings"
maType         = input.string(title="MA Type", defval="Simple", options=["Simple", "Exponential", "Weighted", "Hull"], group=maGroup)
maLength       = input.int(title="MA Length", defval=150, minval=1, group=maGroup)
src            = input.source(title="Source", defval=close, group=maGroup)

// Band Type Settings (Percentage or ATR)
bandGroup      = "Band Settings"
bandMethod     = input.string(title="Band Calculation Method", defval="Percentage", options=["Percentage", "ATR Multiplier"], group=bandGroup)
atrLength      = input.int(title="ATR Length (If ATR Selected)", defval=14, minval=1, group=bandGroup)

// Band Threshold Values
upperPctVal    = input.float(title="Upper Band (%)", defval=20.0, step=0.1, group=bandGroup)
lowerPctVal    = input.float(title="Lower Band (%)", defval=-20.0, step=0.1, group=bandGroup)
upperAtrMult   = input.float(title="Upper ATR Multiplier", defval=3.0, step=0.1, group=bandGroup)
lowerAtrMult   = input.float(title="Lower ATR Multiplier", defval=3.0, step=0.1, group=bandGroup)

// Visual & Color Settings (Perfectly Separated)
colorGroup     = "Visual Settings"
aboveZeroColor = input.color(title="Above 0 Color", defval=color.green, group=colorGroup)
belowZeroColor = input.color(title="Below 0 Color", defval=color.red, group=colorGroup)
extremeColor   = input.color(title="Extreme Zone Line Color", defval=color.yellow, group=colorGroup)
labelBgColor   = input.color(title="Label Background Color", defval=color.gray, group=colorGroup)
labelTextColor = input.color(title="Label Text Color", defval=color.black, group=colorGroup)
showLabels     = input.bool(title="Show Extreme Value Labels?", defval=true, group=colorGroup)

// ==========================================
// 2. LOGIC & CALCULATIONS
// ==========================================
// MA Calculation
maValue = switch maType
    "Simple"      => ta.sma(src, maLength)
    "Exponential" => ta.ema(src, maLength)
    "Weighted"    => ta.wma(src, maLength)
    "Hull"        => ta.hma(src, maLength)
    => na

// Avoid division by zero
priceDistancePct = maValue != 0 and not na(maValue) ? ((src - maValue) / maValue) * 100 : na

// Calculate Bands dynamically based on user selection
currentAtr = ta.atr(atrLength)
atrInPct   = maValue != 0 and not na(maValue) ? (currentAtr / maValue) * 100 : na

upperBand = switch bandMethod
    "Percentage"     => upperPctVal
    "ATR Multiplier" => atrInPct * upperAtrMult
    => na

lowerBand = switch bandMethod
    "Percentage"     => lowerPctVal
    "ATR Multiplier" => -(atrInPct * lowerAtrMult)
    => na

// ==========================================
// 3. DYNAMIC COLORING
// ==========================================
plotColor = (priceDistancePct > upperBand or priceDistancePct < lowerBand) ? extremeColor : (priceDistancePct >= 0 ? aboveZeroColor : belowZeroColor)

// ==========================================
// 4. PLOTTING
// ==========================================
plot(0, title="Zero Line", color=color.gray, style=plot.style_line)
plot(upperBand, title="Upper Band Line", color=color.blue, linewidth=1)
plot(lowerBand, title="Lower Band Line", color=color.blue, linewidth=1)
plot(priceDistancePct, title="Distance (%)", color=plotColor, linewidth=2, style=plot.style_line)

// ==========================================
// 5. LABELS FOR EXTREME VALUES (PIVOTS)
// ==========================================
// Using 15 bars lookleft and lookright to capture major turning points
pivotRange = 15
pH = ta.pivothigh(priceDistancePct, pivotRange, pivotRange)
pL = ta.pivotlow(priceDistancePct, pivotRange, pivotRange)

// Plot labels using the independent color variables
if showLabels and not na(pH) and pH > upperBand
    label.new(x=bar_index - pivotRange, y=pH, text=str.tostring(pH, "#.##") + "%", color=labelBgColor, textcolor=labelTextColor, style=label.style_label_down, size=size.small)
                  
if showLabels and not na(pL) and pL < lowerBand
    label.new(x=bar_index - pivotRange, y=pL, text=str.tostring(pL, "#.##") + "%", color=labelBgColor, textcolor=labelTextColor, style=label.style_label_up, size=size.small)
````
