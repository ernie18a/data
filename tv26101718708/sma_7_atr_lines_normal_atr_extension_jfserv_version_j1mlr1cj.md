# SMA +7 ATR Lines (Normal atr extension + jfserv version)

- url: https://www.tradingview.com/script/J1MLR1cj-SMA-7-ATR-Lines-Normal-atr-extension-jfserv-version/
- type: indicator
- pine_id: PUB;4e2eaf2fd32e47aeb807358fdf7005b4
- version: 1.0

## Description

This script is a comparison study between two different ATR extension calculation methods from a chosen SMA (10, 21, or 50).
Purpose:
To visually compare the classic “Normal / Matrix Style” ATR extension (used in the ATR Matrix indicator) with the jfserv percentage-normalized method.
The Two Methods Compared:

Normal / Matrix Style (Orange Line)
Line = SMA + Multiplier × ATR
→ Classic dollar-based extension. Same formula used in the “ATR Matrix” script (f_lvl_from_sma(n) => sma50 + n * atr).
jfserv % Method (Red Line)
Line = SMA + Multiplier × ATR × (SMA / close)
→ Percentage-normalized approach. Adjusts the extension level based on the current price relative to the SMA.

Features:

Switch between SMA10, SMA21, or SMA50
Show one or both lines (both visible by default)
Background color based on chosen method
Adjustable ATR multiplier (default 7x)
Thicker lines (default width 4)
Fill zone and visual labels

Created by: @denis__hamel

## Source Code

````pine
//@version=6
indicator("SMA +7 ATR Lines (Normal atr extension + jfserv version)", shorttitle="SMA 7x ATR Dual", overlay=true, max_lines_count=500)

// ─────────────────────────────────────────────────────────────
//  Script by @denis__hamel
//  Created with Grok (xAI)
//
//  This indicator is a comparison study between two ATR extension 
//  methods from a chosen SMA (10, 21, or 50):
//  
//  1. Normal / Matrix Style (Orange Line):
//     Line = SMA + multiplier * ATR
//     → Classic dollar-based extension (same as your ATR Matrix script)
//
//  2. jfserv % Method (Red Line):
//     Line = SMA + multiplier * ATR * (SMA / close)
//     → Percentage-normalized approach
//
//  Features:
//  - Switch between SMA10 / SMA21 / SMA50
//  - Show one or both lines (both visible by default)
//  - Background color based on chosen method
//  - Adjustable multiplier (default 7x) and line width (default 4)
// ─────────────────────────────────────────────────────────────

// === INPUTS ===
smaType = input.string("SMA50", "SMA Type", options=["SMA10", "SMA21", "SMA50"])
atrLength = input.int(14, "ATR Length", minval=1)
showBoth = input.bool(true, "Show Both Lines (Normal + jfserv)")
bgChoice = input.string("normal", "Background based on", options=["jfserv", "normal", "none"], tooltip="Which line triggers the red background when price is extended above it.")
showSMA = input.bool(true, "Show Chosen SMA")
multiplier = input.float(7.0, "ATR Multiplier", step=0.1)
lineWidth = input.int(4, "Line Width", minval=1, maxval=10)

// === CALCULATIONS ===
sma10 = ta.sma(close, 10)
sma21 = ta.sma(close, 21)
sma50 = ta.sma(close, 50)

sma = smaType == "SMA10" ? sma10 : smaType == "SMA21" ? sma21 : sma50

atr = ta.atr(atrLength)

// Normal / Matrix Style (same as your ATR Matrix script)
normalLine = sma + multiplier * atr

// jfserv percentage method
jfservLine = sma + multiplier * atr * (sma / close)

// === PLOTTING ===
plot(showSMA ? sma : na, title="Chosen SMA", color=color.blue, linewidth=lineWidth)

// Plot lines
plot(normalLine, title="Normal +7 ATR (Matrix Style)", color=color.orange, linewidth=lineWidth, style=plot.style_linebr, display=showBoth ? display.all : display.none)
plot(jfservLine, title="jfserv +7 ATR%", color=color.red, linewidth=lineWidth, style=plot.style_linebr)

// Fill zone (using normal/Matrix by default)
fill(plot(sma), plot(normalLine), color=color.new(color.orange, 90), title="Extension Zone")

// === BACKGROUND COLOR ===
isExtended = bgChoice == "jfserv" ? close > jfservLine :
             bgChoice == "normal" ? close > normalLine : false

bgcolor(isExtended ? color.new(color.red, 95) : na, title="Extended Background")

// Last bar labels
if barstate.islast
    label.new(bar_index, normalLine, text="+7x Normal", color=color.orange, style=label.style_label_left, textcolor=color.white, size=size.small)
    if showBoth
        label.new(bar_index, jfservLine, text="+7x jfserv", color=color.red, style=label.style_label_left, textcolor=color.white, size=size.small)
````
