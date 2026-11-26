# Ultimate Divergence Pro [LuxAlgo]

- url: https://www.tradingview.com/script/Eyc1vCjk-Ultimate-Divergence-Pro-LuxAlgo/
- type: indicator
- pine_id: PUB;f026063572d142f6aa103979c2a62282
- version: 1.0

## Description

Title: Ultimate Divergence Pro with Trend & Volume Filter

Description:
The Ultimate Divergence Pro is a comprehensive momentum analysis tool designed to detect multi-layered discrepancies between price action and the Relative Strength Index (RSI). Unlike standard divergence scripts, this indicator combines trend, momentum, and volume validation to provide a "Solid" signal engine.

Originality and Usefulness:
This script is original because it integrates three distinct analytical layers to filter out low-probability signals:

Divergence Engine: Detects Regular (Reversal), Hidden (Continuation), and Exaggerated (Double Top/Bottom) divergences.
Trend Filter (EMA 200): Ensures that bullish signals only appear in uptrends and bearish signals in downtrends, preventing traders from "fighting the tape."
Volume Filter: Validates momentum shifts by ensuring that the signal occurs on volume that is higher than its 20-period average, confirming institutional interest.
FX Pro Logic: Implements Overbought/Oversold thresholds for regular divergences to filter out mid-range noise common in high-frequency markets.
How it works:
The indicator uses a high-speed pivot detection algorithm (configurable via the "Pivot Lookright" setting). When a pivot in the RSI is confirmed, the script checks the historical price relationship to determine the divergence type.

Features:

R (Regular): High-probability reversal signal.
H (Hidden): Trend continuation signal.
E (Exaggerated): ATR-adaptive double top/bottom momentum shifts.
Visuals: Uses short, ATR-adaptive vertical markers instead of full-background highlights for a cleaner trading interface.
Speed: Optimized for 1-bar confirmation (Speed = 1) for early entry opportunities.
Disclaimer:
Divergence trading carries inherent risks. Past performance does not guarantee future results. Always use proper risk management and stop-loss orders.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Ultimate Divergence Pro [LuxAlgo]", shorttitle="Divergence Pro", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// --- Groups ---
string G_OSC   = "Oscillator Settings"
string G_DIV   = "Divergence Detection"
string G_FILT  = "Confirmation & Filters"
string G_STYLE = "Style & Visuals"

// --- Inputs ---
int oscLength = input.int(14, "RSI Length", minval=1, group=G_OSC)
int lbL = input.int(5, "Pivot Lookleft", minval=1, group=G_DIV, tooltip="Stability: Bars to the left to confirm a peak/valley.")
int lbR = input.int(1, "Pivot Lookright (Speed)", minval=1, group=G_DIV, tooltip="Set to 1 for fastest possible detection (1-bar confirmation).")
int rangeUpper = input.int(40, "Max Lookback Range", minval=1, group=G_DIV)
int rangeLower = input.int(3, "Min Lookback Range", minval=1, group=G_DIV)

bool showRegular     = input.bool(true, "Show Regular Divergence", group=G_DIV)
bool showHidden      = input.bool(true, "Show Hidden Divergence", group=G_DIV)
bool showExaggerated = input.bool(true, "Show Exaggerated Divergence", group=G_DIV)

// --- Confirmation Filters ---
bool useTrendFilter  = input.bool(true, "Filter by Trend (EMA 200)", group=G_FILT, tooltip="Only shows signals aligned with the 200 EMA trend.")
int emaLen           = input.int(200, "EMA Length", minval=1, group=G_FILT)
bool useVolumeFilter = input.bool(true, "Filter by Volume", group=G_FILT, tooltip="Validates signals only if current volume is above its 20-period average.")
bool filterFXPro     = input.bool(true, "FX Pro Filter (OB/OS)", group=G_FILT, tooltip="Filters regular signals by RSI Overbought/Oversold levels.")
int rsiOB            = input.int(70, "RSI Overbought", group=G_FILT)
int rsiOS            = input.int(30, "RSI Oversold", group=G_FILT)

// --- Style Inputs ---
color bullColor = input.color(#089981, "Bullish Line Color", group=G_STYLE, inline="bull")
color bearColor = input.color(#f23645, "Bearish Line Color", group=G_STYLE, inline="bear")
string lStyle   = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=G_STYLE)
int lWidth      = input.int(2, "Line Width", minval=1, maxval=5, group=G_STYLE)
color textColor = input.color(#ffffff, "Text Color", group=G_STYLE)
bool showBg     = input.bool(true, "Show Signal Markers", group=G_STYLE)
int bgTransp    = input.int(85, "Highlight Transparency", minval=0, maxval=100, group=G_STYLE)
float bgHeight  = input.float(2.0, "Highlight Height (ATR mult)", minval=0.1, step=0.1, group=G_STYLE)

// --- Calculations ---
float osc = ta.rsi(close, oscLength)
float atr = ta.atr(14)
float trendEma = ta.ema(close, emaLen)
float volMa = ta.sma(volume, 20)

// Pivot detection
float pl = ta.pivotlow(osc, lbL, lbR)
float ph = ta.pivothigh(osc, lbL, lbR)

// Tracking pivots
var float pLastPlPrice = na
var float pLastPlOsc   = na
var int   pLastPlBar   = na

var float pLastPhPrice = na
var float pLastPhOsc   = na
var int   pLastPhBar   = na

// Helper function for line style
f_getStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

// Main Logic
if not na(pl)
    float curLow = low[lbR]
    float curOsc = osc[lbR]
    int   curBar = bar_index[lbR]
    
    if not na(pLastPlBar)
        int diff = curBar - pLastPlBar
        if diff <= rangeUpper and diff >= rangeLower
            bool isReg = curLow < pLastPlPrice and curOsc > pLastPlOsc
            bool isHid = curLow > pLastPlPrice and curOsc < pLastPlOsc
            bool isExa = math.abs(curLow - pLastPlPrice) <= (atr[lbR] * 0.15) and curOsc > pLastPlOsc
            
            // Multi-Layer Confirmation
            bool trendPass  = not useTrendFilter or close[lbR] > trendEma[lbR]
            bool volumePass = not useVolumeFilter or volume[lbR] > volMa[lbR]
            bool fxPass     = not filterFXPro or (curOsc <= rsiOS or pLastPlOsc <= rsiOS)
            
            if trendPass and volumePass and ((showRegular and isReg and fxPass) or (showHidden and isHid) or (showExaggerated and isExa))
                string t = isReg ? "R" : isHid ? "H" : "E"
                line.new(pLastPlBar, pLastPlPrice, curBar, curLow, xloc.bar_index, extend.none, color.new(bullColor, 40), f_getStyle(lStyle), lWidth)
                label.new(curBar, curLow, t, xloc.bar_index, yloc.belowbar, #00000000, label.style_label_up, textColor, size.small)
                if showBg
                    box.new(bar_index, low, bar_index, low - (atr * bgHeight), border_color=na, bgcolor=color.new(bullColor, bgTransp))
                alert("Bullish Divergence Detected", alert.freq_once_per_bar)
    
    pLastPlPrice := curLow
    pLastPlOsc   := curOsc
    pLastPlBar   := curBar

if not na(ph)
    float curHigh = high[lbR]
    float curOsc  = osc[lbR]
    int   curBar  = bar_index[lbR]
    
    if not na(pLastPhBar)
        int diff = curBar - pLastPhBar
        if diff <= rangeUpper and diff >= rangeLower
            bool isReg = curHigh > pLastPhPrice and curOsc < pLastPhOsc
            bool isHid = curHigh < pLastPhPrice and curOsc > pLastPhOsc
            bool isExa = math.abs(curHigh - pLastPhPrice) <= (atr[lbR] * 0.15) and curOsc < pLastPhOsc
            
            // Multi-Layer Confirmation
            bool trendPass  = not useTrendFilter or close[lbR] < trendEma[lbR]
            bool volumePass = not useVolumeFilter or volume[lbR] > volMa[lbR]
            bool fxPass     = not filterFXPro or (curOsc >= rsiOB or pLastPhOsc >= rsiOB)
            
            if trendPass and volumePass and ((showRegular and isReg and fxPass) or (showHidden and isHid) or (showExaggerated and isExa))
                string t = isReg ? "R" : isHid ? "H" : "E"
                line.new(pLastPhBar, pLastPhPrice, curBar, curHigh, xloc.bar_index, extend.none, color.new(bearColor, 40), f_getStyle(lStyle), lWidth)
                label.new(curBar, curHigh, t, xloc.bar_index, yloc.abovebar, #00000000, label.style_label_down, textColor, size.small)
                if showBg
                    box.new(bar_index, high + (atr * bgHeight), bar_index, high, border_color=na, bgcolor=color.new(bearColor, bgTransp))
                alert("Bearish Divergence Detected", alert.freq_once_per_bar)

    pLastPhPrice := curHigh
    pLastPhOsc   := curOsc
    pLastPhBar   := curBar
````
