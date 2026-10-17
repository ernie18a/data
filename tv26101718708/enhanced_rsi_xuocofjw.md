# Enhanced RSI

- url: https://www.tradingview.com/script/XUOcoFjw-Enhanced-RSI/
- type: indicator
- pine_id: PUB;c0c6502ef35a4db8b081c2abcf95e05d
- version: 2.0

## Description

[b]Why this Enhanced RSI is better than the classic RSI[/b]

The classic RSI is a powerful momentum oscillator, but it has some limitations in real trading. This Enhanced RSI improves on the standard version by adding several useful visual and analytical features.

[b]1. Momentum Fill (The Biggest Improvement)[/b]

The classic RSI only shows one line, so you have to mentally compare its slope and position. This Enhanced RSI plots both the RSI and its moving average (SMA or EMA), then fills the space between them with color. Green fill means the RSI is above its MA (bullish momentum is strong), while red fill means the RSI is below its MA (bearish momentum is strong). This gives you an instant visual read of momentum strength and direction.

[b]2. RSI + Signal Line (Like a Mini MACD for RSI)[/b]

The moving average of the RSI acts as a signal line. Crossovers between the RSI and its MA often give cleaner and earlier signals than just waiting for the RSI to cross 50 or the classic 30/70 levels. It also helps filter out some of the noise and whipsaws that the raw RSI produces.

[b]3. Better Overbought / Oversold Zones[/b]

The classic RSI uses thin horizontal lines at 70 and 30. This Enhanced version draws filled bands with adjustable width (default width = 10). This shows you how deeply price has moved into overbought or oversold territory, not just whether it crossed a line. It gives a better sense of exhaustion strength.

[b]4. Much Better Visual Clarity[/b]

The Enhanced RSI offers significantly better visual clarity compared to the classic version. The colored momentum fill between the RSI and its moving average makes it very easy to instantly see whether momentum is bullish or bearish. The filled OB/OS bands are more informative than simple thin lines. Overall, the combination of the RSI line, its MA, the dynamic fill, and the visible zones allows traders to read the indicator much faster and with less effort than the standard RSI.

[b]5. Practical Trading Advantages[/b]

Divergences are easier to spot because you have two lines instead of one. The colored fill helps you quickly see when momentum is accelerating or fading. It works well for both mean-reversion strategies (fading extremes) and trend-following (following strong momentum). Overall, it reduces noise compared to the raw RSI and provides more actionable information at a glance.

[b]Summary – When to use which[/b]

Use the Enhanced RSI when you want faster visual interpretation of momentum, cleaner signals with fewer whipsaws, and better visualization of overbought/oversold strength. The classic RSI can still be useful if you prefer a simpler and more minimal chart. For most discretionary traders and those who like clear visual feedback, the Enhanced version is generally superior.

[b]Bottom line[/b]

This Enhanced RSI doesn’t replace the classic RSI — it enhances it. By adding a signal line, a visual momentum fill, and better zone visualization, it allows traders to read momentum and potential reversals faster and with greater confidence.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xCresus

//@version=6
indicator("Enhanced RSI", overlay=false, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// =============================================================================
// INPUTS
// =============================================================================

// --- RSI Settings ---
len              = input.int(14,  "RSI Length",               minval=1,  group="RSI Settings")
maLen            = input.int(9,   "MA Length",                minval=1,  group="RSI Settings")
useEMA           = input.bool(false, "Use EMA (off = SMA)",             group="RSI Settings")

// --- Visibility ---
showRsi          = input.bool(true,  "Show RSI",                         group="Visibility")
showMa           = input.bool(true,  "Show RSI MA",                      group="Visibility")
showMABand       = input.bool(true,  "Fill between RSI and MA",          group="Visibility")
showZones        = input.bool(true,  "Show OB/OS Zones",                 group="Visibility")

// --- Zones ---
obLevel          = input.int(70,  "Overbought Level",         minval=0, maxval=100, group="Zones")
osLevel          = input.int(30,  "Oversold Level",           minval=0, maxval=100, group="Zones")
wid              = input.int(10,  "Width of OB/OS Zones",     minval=0,               group="Zones")
bandAlpha        = input.int(80,  "Zone Transparency (0-100)", minval=0, maxval=100, group="Zones")

// --- Colors ---
thrustUp         = input.color(#64ffda, "Thrust Up Fill Color",           group="Colors")
thrustDn         = input.color(#f44336, "Thrust Down Fill Color",         group="Colors")
maBandAlpha      = input.int(70,  "MA Band Transparency (0-100)", minval=0, maxval=100, group="Colors")
rsiColor         = input.color(#ffffff, "RSI Color",                      group="Colors")
maColor          = input.color(#ffd400, "MA Color",                       group="Colors")
obColor          = input.color(#ff1744, "Overbought Zone Color",          group="Colors")
osColor          = input.color(#00e676, "Oversold Zone Color",            group="Colors")

// --- Divergence Settings ---
showDiv          = input.bool(true,  "Show Divergences",                  group="Divergence")
leftBars         = input.int(7,   "Pivot Left Bars",          minval=1,  group="Divergence")
rightBars        = input.int(7,   "Pivot Right Bars",         minval=1,  group="Divergence")
showRegular      = input.bool(true,  "Regular Divergences",               group="Divergence")
showHidden       = input.bool(false, "Hidden Divergences",                group="Divergence")
bullDivColor     = input.color(#00e676, "Bullish Divergence Color",       group="Divergence")
bearDivColor     = input.color(#ff1744, "Bearish Divergence Color",       group="Divergence")
divLineWidth     = input.int(2,   "Divergence Line Width",    minval=1,  group="Divergence")

// =============================================================================
// CALCULATIONS
// =============================================================================

rsiRaw = ta.rsi(close, len)
rsiMA  = useEMA ? ta.ema(rsiRaw, maLen) : ta.sma(rsiRaw, maLen)

obUpperLevel = obLevel + wid
obLowerLevel = obLevel
osUpperLevel = osLevel
osLowerLevel = osLevel - wid

// =============================================================================
// PLOTS (existing)
// =============================================================================

plotRsi = plot(showRsi ? rsiRaw : na, color=rsiColor, linewidth=2, title="RSI")
plotMa  = plot(showMa  ? rsiMA  : na, color=maColor,  linewidth=2, title="RSI MA")

hline(50, "Midline 50", color=color.new(#777777, 40), linestyle=hline.style_dotted, linewidth=1)

maFillColor = showMABand ? 
     (rsiRaw > rsiMA ? color.new(thrustUp, maBandAlpha) : color.new(thrustDn, maBandAlpha)) : 
     na
fill(plotRsi, plotMa, color=maFillColor, title="RSI-MA Momentum Fill")

// Overbought Zone
ob_col = color.new(obColor, bandAlpha)
p_ob_upper = plot(showZones ? obUpperLevel : na, color=ob_col, linewidth=1, title="OB Upper")
p_ob_lower = plot(showZones ? obLowerLevel : na, color=ob_col, linewidth=1, title="OB Lower")
fill(p_ob_upper, p_ob_lower, color=showZones ? ob_col : na, title="Overbought Zone")

// Oversold Zone
os_col = color.new(osColor, bandAlpha)
p_os_upper = plot(showZones ? osUpperLevel : na, color=os_col, linewidth=1, title="OS Upper")
p_os_lower = plot(showZones ? osLowerLevel : na, color=os_col, linewidth=1, title="OS Lower")
fill(p_os_upper, p_os_lower, color=showZones ? os_col : na, title="Oversold Zone")

// =============================================================================
// DIVERGENCE DETECTOR
// =============================================================================

if showDiv
    // Pivots on RSI
    phRsi = ta.pivothigh(rsiRaw, leftBars, rightBars)
    plRsi = ta.pivotlow(rsiRaw, leftBars, rightBars)

    // Pivots on Price (using high/low for better accuracy)
    phPrice = ta.pivothigh(high, leftBars, rightBars)
    plPrice = ta.pivotlow(low, leftBars, rightBars)

    // Store last confirmed pivots
    var float lastPhRsi   = na
    var float lastPlRsi   = na
    var float lastPhPrice = na
    var float lastPlPrice = na
    var int   lastPhBar   = na
    var int   lastPlBar   = na

    // ---- Bearish Divergence (Higher High on Price + Lower High on RSI) ----
    if not na(phRsi)
        // New pivot high confirmed
        if not na(lastPhRsi)
            // Regular Bearish
            if showRegular and high[rightBars] > lastPhPrice and rsiRaw[rightBars] < lastPhRsi
                line.new(lastPhBar, lastPhRsi, bar_index[rightBars], rsiRaw[rightBars], 
                     color=bearDivColor, width=divLineWidth, style=line.style_solid)
                label.new(bar_index[rightBars], rsiRaw[rightBars], "Bear", 
                     style=label.style_label_down, color=bearDivColor, textcolor=color.white, size=size.small)

            // Hidden Bearish
            if showHidden and high[rightBars] < lastPhPrice and rsiRaw[rightBars] > lastPhRsi
                line.new(lastPhBar, lastPhRsi, bar_index[rightBars], rsiRaw[rightBars], 
                     color=color.new(bearDivColor, 40), width=divLineWidth, style=line.style_dashed)
                label.new(bar_index[rightBars], rsiRaw[rightBars], "H.Bear", 
                     style=label.style_label_down, color=color.new(bearDivColor, 20), textcolor=color.white, size=size.small)

        // Update last pivot high
        lastPhRsi   := rsiRaw[rightBars]
        lastPhPrice := high[rightBars]
        lastPhBar   := bar_index[rightBars]

    // ---- Bullish Divergence (Lower Low on Price + Higher Low on RSI) ----
    if not na(plRsi)
        if not na(lastPlRsi)
            // Regular Bullish
            if showRegular and low[rightBars] < lastPlPrice and rsiRaw[rightBars] > lastPlRsi
                line.new(lastPlBar, lastPlRsi, bar_index[rightBars], rsiRaw[rightBars], 
                     color=bullDivColor, width=divLineWidth, style=line.style_solid)
                label.new(bar_index[rightBars], rsiRaw[rightBars], "Bull", 
                     style=label.style_label_up, color=bullDivColor, textcolor=color.white, size=size.small)

            // Hidden Bullish
            if showHidden and low[rightBars] > lastPlPrice and rsiRaw[rightBars] < lastPlRsi
                line.new(lastPlBar, lastPlRsi, bar_index[rightBars], rsiRaw[rightBars], 
                     color=color.new(bullDivColor, 40), width=divLineWidth, style=line.style_dashed)
                label.new(bar_index[rightBars], rsiRaw[rightBars], "H.Bull", 
                     style=label.style_label_up, color=color.new(bullDivColor, 20), textcolor=color.white, size=size.small)

        // Update last pivot low
        lastPlRsi   := rsiRaw[rightBars]
        lastPlPrice := low[rightBars]
        lastPlBar   := bar_index[rightBars]
````
