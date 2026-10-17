# LRLR & HRLR Liquidity Runs V2

- url: https://www.tradingview.com/script/V8cllCIH-LRLR-HRLR-Liquidity-Runs-V2/
- type: indicator
- pine_id: PUB;224be9001a5e4df8a0e9568e706e41f7
- version: 1.0

## Description

Its primary purpose is to automatically identify, classify, and connect consecutive swing highs and swing lows to highlight potential Liquidity Runs based on ICT/Smart Money Concepts.

Here is a breakdown of how it works:

1. Pivot Identification
The script relies on identifying structural pivot points (swing highs and lows).

It uses ta.pivothigh and ta.pivotlow to find these points.
By default, a pivot is confirmed if the price is the highest/lowest point compared to the 5 bars on its left and 5 bars on its right (customizable via leftBars and rightBars inputs).

2. Core Logic (LRLR vs HRLR)
Once a new pivot is identified, the script compares it to the immediate previous pivot of the same type to classify the resistance of the liquidity run:

For Pivot Highs (Resistance/Tops):

LRLR (Low Resistance Liquidity Run): If the new Pivot High is Lower than or Equal to the previous Pivot High. (Price failed to break the previous high, leaving clean liquidity above).
HRLR (High Resistance Liquidity Run): If the new Pivot High is Higher than the previous Pivot High. (Price successfully broke the previous high, taking out the liquidity).
For Pivot Lows (Support/Bottoms):

LRLR (Low Resistance Liquidity Run): If the new Pivot Low is Higher than or Equal to the previous Pivot Low. (Price failed to break the previous low, leaving clean liquidity below).
HRLR (High Resistance Liquidity Run): If the new Pivot Low is Lower than the previous Pivot Low. (Price successfully broke the previous low, taking out the liquidity).

3. Visual Output
Whenever a new pivot is confirmed, the script draws a Line connecting the previous pivot to the new pivot.
The color of the line changes based on whether it's an LRLR (default Greenish) or an HRLR (default Reddish).
A Text Label ("LRLR" or "HRLR") is plotted precisely at the midpoint of the line for easy visual identification.

## Source Code

````pine
//@version=6
indicator("LRLR & HRLR Liquidity Runs", overlay=true, max_lines_count=500, max_labels_count=500)

// Inputs
int leftBars  = input.int(5, "Pivot Left Bars", minval=1)
int rightBars = input.int(5, "Pivot Right Bars", minval=1)

color colLRLR = input.color(#26a69a, "LRLR Line Color") // Greenish matching Tradingview standard
color colHRLR = input.color(#ef5350, "HRLR Line Color") // Reddish matching Tradingview standard
color colText = input.color(#2962ff, "Text Color")      // Blueish matching the screenshot
string textSize = input.string(size.small, "Text Size", options=[size.tiny, size.small, size.normal, size.large])

// State variables for tracking the last pivot points
var float lastPhPrice = na
var int   lastPhIndex = na
var float lastPlPrice = na
var int   lastPlIndex = na

// Calculate Pivot points
float ph = ta.pivothigh(high, leftBars, rightBars)
float pl = ta.pivotlow(low, leftBars, rightBars)

// Logic for Pivot Highs
if not na(ph)
    int currentIndex = bar_index - rightBars
    if not na(lastPhPrice)
        // Lower High or Equal High -> LRLR (Low Resistance Liquidity Run)
        // Higher High -> HRLR (High Resistance Liquidity Run)
        bool isLRLR = ph <= lastPhPrice
        color lineColor = isLRLR ? colLRLR : colHRLR
        string labelText = isLRLR ? "LRLR" : "HRLR"
        
        // Draw the line connecting previous pivot high to current pivot high
        line.new(lastPhIndex, lastPhPrice, currentIndex, ph, color=lineColor, width=1)
        
        // Draw a label at the midpoint
        int midIndex = int(math.round((lastPhIndex + currentIndex) / 2.0))
        float midPrice = (lastPhPrice + ph) / 2.0
        label.new(midIndex, midPrice, text=labelText, style=label.style_none, textcolor=colText, size=textSize)
        
    lastPhPrice := ph
    lastPhIndex := currentIndex

// Logic for Pivot Lows
if not na(pl)
    int currentIndex = bar_index - rightBars
    if not na(lastPlPrice)
        // Higher Low or Equal Low -> LRLR (Low Resistance Liquidity Run)
        // Lower Low -> HRLR (High Resistance Liquidity Run)
        bool isLRLR = pl >= lastPlPrice
        color lineColor = isLRLR ? colLRLR : colHRLR
        string labelText = isLRLR ? "LRLR" : "HRLR"
        
        // Draw the line connecting previous pivot low to current pivot low
        line.new(lastPlIndex, lastPlPrice, currentIndex, pl, color=lineColor, width=1)
        
        // Draw a label at the midpoint
        int midIndex = int(math.round((lastPlIndex + currentIndex) / 2.0))
        float midPrice = (lastPlPrice + pl) / 2.0
        label.new(midIndex, midPrice, text=labelText, style=label.style_none, textcolor=colText, size=textSize)
        
    lastPlPrice := pl
    lastPlIndex := currentIndex
````
