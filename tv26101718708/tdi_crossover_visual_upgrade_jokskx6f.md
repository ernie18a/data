# TDI - (Crossover Visual Upgrade)

- url: https://www.tradingview.com/script/JoKSkX6F-TDI-Crossover-Visual-Upgrade/
- type: indicator
- pine_id: PUB;caecb95b1cb1484bb54811667da1cd11
- version: 7.0

## Description

TDI - (Crossover Visual Upgrade) - Enhanced Momentum Tracking

This script is an optimized version of the classic Traders Dynamic Index (TDI). While keeping the original calculation logic, I have introduced visual enhancements and alert features to help traders react faster to market momentum changes.

Why this version is useful:
The original TDI can sometimes be difficult to read during fast-moving markets. This version features a dynamic RSI line that changes color based on its position relative to the Bollinger Band midline. This allows traders to instantly spot trend reversals and crossovers without needing to squint at the screen.

Key Features:
Dynamic Color-Coding: The Fast MA line automatically shifts color when crossing the Bollinger Band midline, providing an immediate visual cue for potential entry or exit points.

Smart Alert System: Integrated alerts for bullish and bearish crossovers, ensuring you never miss a critical setup.

On-Chart Labeling: Option to display crossover labels directly on the main chart for better price-action context (with customizable settings).

Configurable Limits: Adjustable label history to keep your chart clean.

How to use:
Add the indicator to your chart.

The RSI line will turn green when above the midline and red when below, signaling the immediate momentum bias.

Configure alerts via the standard TradingView "Alert" menu by selecting the crossover conditions.

Credits:
This script is based on the original Traders Dynamic Index logic by LazyBear.

Author's Note:
I developed this version of the TDI to improve visual clarity because I personally trade at a fast pace. I wanted to eliminate the need to spend extra time and mental energy double-checking whether the RSI has crossed the Bollinger Band midline.

Since I built this for my own workflow, I decided to share it with the community in case others are facing the same issue. Big thanks to Gemini for helping me craft this description. I hope you find this indicator useful for your trading!

## Source Code

````pine
//@version=6
// @author LazyBear / Modified by Bromley & Gemini
indicator("TDI - (Crossover Visual Upgrade)", shorttitle="TDI - (Crossover Visual Upgrade)", overlay=false)

// ==========================================
// --- Inputs: Multi-Timeframe Settings ---
// ==========================================
group_mtf = "============== Multi-Timeframe Settings =============="
useCustomTf = input.bool(true, "Enable Custom Timeframe", group=group_mtf, tooltip="Unchecked = Use current chart timeframe. Checked = Use custom target timeframe below.")
customTf = input.timeframe("", "Target Timeframe", group=group_mtf, tooltip="Select the timeframe for TDI calculations when custom timeframe is enabled (e.g., 5, 15, 60, D)")

// ==========================================
// --- Inputs: TDI Core Settings ---
// ==========================================
group_tdi = "================= TDI Core Settings ================="
rsiPeriod = input.int(11, minval=1, title="RSI Period", group=group_tdi, tooltip="Period for RSI calculation")
bandLength = input.int(31, minval=1, title="Band Length", group=group_tdi, tooltip="Period for volatility bands calculation")
lengthrsipl = input.int(1, minval=0, title="Fast MA on RSI", group=group_tdi, tooltip="Length of Fast MA line")
lengthtradesl = input.int(9, minval=1, title="Slow MA on RSI", group=group_tdi, tooltip="Length of Slow MA line")

// ==========================================
// --- Inputs: TDI Line Color Settings ---
// ==========================================
group_line_color = "================= TDI Line Color Settings ================="
upperBandColor = input.color(color.white, "Upper Band Color", group=group_line_color, tooltip="Color of the Upper Band")
lowerBandColor = input.color(color.white, "Lower Band Color", group=group_line_color, tooltip="Color of the Lower Band")
middleBandColor = input.color(#2e2e2e, "Middle Band Color", group=group_line_color, tooltip="Color of the Middle Band")
slowMAColor = input.color(#673ab7, "Slow MA Color", group=group_line_color, tooltip="Color of the Slow MA")
fastBullColor = input.color(color.rgb(0, 255, 8), "Fast MA Bullish Color", group=group_line_color, tooltip="Fast MA color when Fast MA is above Middle Band")
fastBearColor = input.color(color.rgb(255, 0, 0), "Fast MA Bearish Color", group=group_line_color, tooltip="Fast MA color when Fast MA is below Middle Band")
upperShadingColor = input.color(color.new(#fff9c4, 35), "Upper Shading Color", group=group_line_color)
lowerShadingColor = input.color(color.new(#fff9c4, 35), "Lower Shading Color", group=group_line_color)

// ==========================================
// --- Inputs: Background Color Settings ---
// ==========================================
group_bg = "============= Background Color Settings ============="
bgSource = input.string("RSI Level 50", "Background Color Mode", options=["RSI Level 50", "Middle Band Cross", "Fast MA vs Slow MA", "RSI 50 & Middle Band", "RSI 50 & Fast/Slow MA", "Middle Band & Fast/Slow MA", "All Combined (AND)"], group=group_bg, tooltip="Select background color condition")
bgBullColor = input.color(color.new(color.green, 75), "Background Bullish", group=group_bg, tooltip="Bullish background color")
bgBearColor = input.color(color.new(color.red, 75), "Background Bearish", group=group_bg, tooltip="Bearish background color")
showTdiBg = input.bool(false, "Show Background on TDI Sub-chart", group=group_bg, tooltip="Toggle standard background color display on the TDI sub-chart")
showMainBg = input.bool(false, "Show Background on Main Chart", group=group_bg, tooltip="Toggle background color display on the main chart")

// ==========================================
// --- Inputs: Extreme Zone Settings ---
// ==========================================
group_ext = "=============== Extreme Zone Settings ==============="
useExtreme = input.bool(false, "Enable Extreme Zone Feature", group=group_ext, tooltip="Enable/Disable all Extreme features (backgrounds, level lines, and Exit label)")
extremeMode = input.string("Level 75/25 Only", "Extreme Calculation Mode", options=["Level 75/25 Only", "BB Bands Only", "Both (BB & Levels)"], group=group_ext, tooltip="Select condition mode for Extreme zone detection")
extremeHigh = input.int(75, minval=50, maxval=100, title="Extreme High Level", group=group_ext, tooltip="Upper RSI threshold level (Default: 75)")
extremeLow = input.int(25, minval=0, maxval=50, title="Extreme Low Level", group=group_ext, tooltip="Lower RSI threshold level (Default: 25)")
bgExtremeHigh = input.color(color.new(color.green, 50), "Extreme High Background (Dark Green)", group=group_ext, tooltip="Background color when price breaches upper extreme level")
bgExtremeLow = input.color(color.new(color.red, 50), "Extreme Low Background (Dark Red)", group=group_ext, tooltip="Background color when price breaches lower extreme level")
showExtremeBg = input.bool(true, "Show Extreme Background (TDI Sub-chart)", group=group_ext, tooltip="Toggle background color display specifically for Extreme zones on the TDI sub-chart")
showExtremeMainBg = input.bool(false, "Show Extreme Background on Main Chart", group=group_ext, tooltip="Toggle background color display specifically for Extreme zones on the main chart")
showOutLabel = input.bool(true, "Show Exit Labels", group=group_ext, tooltip="Show exit warning labels when leaving the extreme zone.")
textMaybe = input.string("Maybe I'm out", "Text for 'Maybe' Exit", group=group_ext, tooltip="Custom text for real-time unconfirmed exit label")
textOut = input.string("I'm out.", "Text for Confirmed Exit", group=group_ext, tooltip="Custom text for confirmed exit label")
outColor = input.color(color.new(color.purple, 65), "Exit Label Color", group=group_ext, tooltip="Background color of the exit label")
outTextColor = input.color(color.white, "Exit Text Color", group=group_ext, tooltip="Text color of the exit label")
outTextSize = input.string(size.normal, "Exit Label Size", options=[size.tiny, size.small, size.normal, size.large, size.huge], group=group_ext, tooltip="Select exit label size")
outLabelLimit = input.int(20, minval=1, title="Max Exit Label History", group=group_ext, tooltip="Specify the number of exit labels to keep on the chart")

// ==========================================
// --- Inputs: Custom Label & Text ---
// ==========================================
group_label = "=============== Label & Text Settings ==============="
showLabels = input.bool(false, "Show Cross Labels (Cross Up/Down)", group=group_label, tooltip="Toggle crossover signals display (Cross Up / Cross Down)")
textUp = input.string("Cross Up", "Text for Bullish Cross", group=group_label, tooltip="Custom text for bullish crossover")
textDn = input.string("Cross Down", "Text for Bearish Cross", group=group_label, tooltip="Custom text for bearish crossover")
textSize = input.string(size.normal, "Cross Label Size", options=[size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, tooltip="Select cross label size")
crossLabelLimit = input.int(10, minval=1, title="Max Cross Label History", group=group_label, tooltip="Specify the number of cross labels to keep on the chart")
upColor = input.color(color.new(color.green, 0), "Bullish Label Color", group=group_label, tooltip="Background color for bullish cross label")
downColor = input.color(color.new(color.red, 0), "Bearish Label Color", group=group_label, tooltip="Background color for bearish cross label")
upTextColor = input.color(color.white, "Bullish Text Color", group=group_label, tooltip="Text color for bullish cross label")
downTextColor = input.color(color.white, "Bearish Text Color", group=group_label, tooltip="Text color for bearish cross label")

// ==========================================
// --- Calculations ---
// ==========================================
f_calcTdi(r_per, b_len, l_rsi, l_trade) =>
    r = ta.rsi(close, r_per)
    ma = ta.sma(r, b_len)
    offs = 1.6185 * ta.stdev(r, b_len)
    up_b = ma + offs
    dn_b = ma - offs
    mid_b = (up_b + dn_b) / 2
    f_ma = ta.sma(r, l_rsi)
    s_ma = ta.sma(r, l_trade)
    [r, ma, up_b, dn_b, mid_b, f_ma, s_ma]

targetTf = useCustomTf ? customTf : timeframe.period
[r, ma, up, dn, mid, fastMA, slowMA] = request.security(syminfo.tickerid, targetTf, f_calcTdi(rsiPeriod, bandLength, lengthrsipl, lengthtradesl), barmerge.gaps_off, barmerge.lookahead_off)

// ==========================================
// --- Color / Background Logic ---
// ==========================================
fastColor = fastMA > mid ? fastBullColor : fastBearColor
bool condRsi50 = r > 50
bool condMid = fastMA > mid
bool condMa = fastMA > slowMA

bool isBullish = switch bgSource
    "Middle Band Cross" => condMid
    "Fast MA vs Slow MA" => condMa
    "RSI 50 & Middle Band" => condRsi50 and condMid
    "RSI 50 & Fast/Slow MA" => condRsi50 and condMa
    "Middle Band & Fast/Slow MA" => condMid and condMa
    "All Combined (AND)" => condRsi50 and condMid and condMa
    => condRsi50

// ==========================================
// --- Extreme Zone Logic ---
// ==========================================
bool isExtremeHigh = false
bool isExtremeLow = false

if useExtreme
    if extremeMode == "BB Bands Only"
        isExtremeHigh := r > up
        isExtremeLow := r < dn
    else if extremeMode == "Both (BB & Levels)"
        isExtremeHigh := r > extremeHigh and r > up
        isExtremeLow := r < extremeLow and r < dn
    else
        isExtremeHigh := r > extremeHigh
        isExtremeLow := r < extremeLow

bool isExtreme = isExtremeHigh or isExtremeLow

// ==========================================
// --- Backgrounds ---
// ==========================================
color tdiBgFinal = isExtreme and showExtremeBg ? (isExtremeHigh ? bgExtremeHigh : bgExtremeLow) : showTdiBg ? (isBullish ? bgBullColor : bgBearColor) : na
color mainBgFinal = isExtreme and showExtremeMainBg ? (isExtremeHigh ? bgExtremeHigh : bgExtremeLow) : showMainBg ? (isBullish ? bgBullColor : bgBearColor) : na

bgcolor(tdiBgFinal, title="RSI Trend Background (TDI)")
bgcolor(mainBgFinal, title="RSI Trend Background (Main Chart)", force_overlay=true)

// ==========================================
// --- Plotting ---
// ==========================================
hline(30, "Oversold (Standard)", linestyle=hline.style_dotted)
hline(50, "Midline", linestyle=hline.style_dashed)
hline(70, "Overbought (Standard)", linestyle=hline.style_dotted)
hline(useExtreme ? extremeLow : na, "Extreme Low", color.new(color.green, 30), linestyle=hline.style_dotted)
hline(useExtreme ? extremeHigh : na, "Extreme High", color.new(color.red, 30), linestyle=hline.style_dotted)

upl = plot(up, "Upper Band", color=upperBandColor, linewidth=2)
dnl = plot(dn, "Lower Band", color=lowerBandColor, linewidth=2)
midl = plot(mid, "Middle Band", color=middleBandColor, linewidth=2)
plot(slowMA, "Slow MA", color=slowMAColor, linewidth=3)
plot(fastMA, "Fast MA", color=fastColor, linewidth=3)

fill(upl, midl, color=upperShadingColor, title="Upper Shading")
fill(midl, dnl, color=lowerShadingColor, title="Lower Shading")

// ==========================================
// --- Label Management ---
// ==========================================
var label currentOutLabel = na
var cross_label_ids = array.new_label()
var bool wasExtreme = false
var bool wasExtremeHigh = false
var bool wasExtremeLow = false
bool isLeavingNow = useExtreme and wasExtreme and not isExtreme
var bool savedIsFromHigh = false

if isLeavingNow
    savedIsFromHigh := wasExtremeHigh

wasExtreme := useExtreme and isExtreme
wasExtremeHigh := useExtreme and isExtremeHigh
wasExtremeLow := useExtreme and isExtremeLow

// ==========================================
// --- Exit Label ---
// ==========================================
if useExtreme and showOutLabel and (isLeavingNow or (not barstate.isconfirmed and not na(currentOutLabel)))
    string currentText = barstate.isconfirmed ? textOut : textMaybe
    color currentColor = barstate.isconfirmed ? outColor : color.new(outColor, 40)
    labelStyle = savedIsFromHigh ? label.style_label_down : label.style_label_up
    labelYloc = savedIsFromHigh ? yloc.abovebar : yloc.belowbar

    if not na(currentOutLabel)
        label.delete(currentOutLabel)

    currentOutLabel := label.new(bar_index, savedIsFromHigh ? high : low, currentText, color=currentColor, textcolor=outTextColor, size=outTextSize, style=labelStyle, yloc=labelYloc, force_overlay=true)

    if barstate.isconfirmed
        currentOutLabel := na

// ==========================================
// --- Cross Labels ---
// ==========================================
if showLabels
    if ta.crossover(fastMA, mid)
        array.push(cross_label_ids, label.new(bar_index, low, textUp, color=upColor, textcolor=upTextColor, size=textSize, style=label.style_label_up, yloc=yloc.belowbar, force_overlay=true))
    if ta.crossunder(fastMA, mid)
        array.push(cross_label_ids, label.new(bar_index, high, textDn, color=downColor, textcolor=downTextColor, size=textSize, style=label.style_label_down, yloc=yloc.abovebar, force_overlay=true))

if array.size(cross_label_ids) > crossLabelLimit
    label.delete(array.shift(cross_label_ids))

// ==========================================
// --- Alerts ---
// ==========================================
bool exitExtreme = useExtreme and wasExtreme and not isExtreme
alertcondition(exitExtreme and barstate.isconfirmed, "Exit Extreme Zone (Confirmed)", "TDI: I'm out.")
alertcondition(isLeavingNow and not barstate.isconfirmed, "Maybe Exit Extreme Zone", "TDI: Maybe I'm out")
alertcondition(ta.crossover(fastMA, mid), "Bullish Cross", "TDI Signal Up")
alertcondition(ta.crossunder(fastMA, mid), "Bearish Cross", "TDI Signal Down")
````
