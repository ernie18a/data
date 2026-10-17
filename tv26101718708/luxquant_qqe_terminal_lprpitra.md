# LuxQuant - QQE Terminal

- url: https://www.tradingview.com/script/LpRPitRA-LuxQuant-QQE-Terminal/
- type: indicator
- pine_id: PUB;3b4eb718540242828936b5ea877232d1
- version: 1.0

## Description

The LuxQuant - QQE Terminal is a high-performance momentum engine designed for traders who prioritize trade management over simple entry signals. While most indicators focus on "where to buy," the QQE Terminal focuses on how to stay in winners longer and cut losers quickly.

Built on the foundation of the Qualitative Quantitative Estimation (QQE) algorithm, this version introduces a terminal interface and four specialized "Operator Modes" that adapt to your specific trading style.

[b]Trading Styles:[/b]

Swing Trader (The Balanced Standard): Uses an RSI-14 base with dual-factor trailing stops. It is the only mode that displays "Slow Trend" dots for structural confirmation.

Trend Trader (The Runner): Slower, smoother, and designed for maximum stability. This mode filters out market noise to keep you in major macro trends.

Intraday Trader (The Scalper): A highly reactive, tight-factor setting (RSI-7) designed for fast-paced scalping and short-term momentum bursts.

Reversal Trader (The Mean Reversion): Tuned specifically to identify overextended conditions (Overbought/Oversold) where a snap-back to the mean is likely.


[b]Additions:[/b]
Dynamic Heatmap RSI: The momentum line changes color dynamically from "Bearish Pink" to "Cyberpunk Mint" based on the momentum pulse.

Momentum Glow: An enhanced visual glow effect that increases in intensity as momentum accelerates.

Cushion Fills: Subtle background fills between the RSI and the Fast QQE line help you visualize the "cushion" of your trade.

Fully Customizable: All colors for the indicator pane (RSI, QQE lines, Zones, and Fills) are fully adjustable to match your chart theme.

This script was made with LuxAlgo's QuantAI! Please let me know what you think!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Pro-Grade QQE Terminal", shorttitle="LuxQuant - QQE Terminal", precision=2, overlay = false)

// --- Constants ---
MODE_SWING    = "Swing Trader"
MODE_TREND    = "Trend Trader"
MODE_INTRADAY = "Intraday Trader"
MODE_REVERSAL = "Reversal Trader"
MODE_CUSTOM   = "Custom"

// --- Fixed Dashboard Colors ---
BULL_DASH     = #00ffbb
BEAR_DASH     = #ff0055
NEUTRAL_DASH  = #5b9cf6
PANEL_BG      = #131722
ACCENT_DASH   = #e0e3eb

// --- Inputs: Logic ---
modeInput       = input.string(MODE_SWING, "Mode", options = [MODE_SWING, MODE_TREND, MODE_INTRADAY, MODE_REVERSAL, MODE_CUSTOM], group = "Presets", tooltip = "Select a preset mode based on your trading style.")
rsiLenInput     = input.int(14, "Custom RSI Length", minval = 1, group = "Custom Settings")
smoothInput     = input.int(5, "Custom Smoothing", minval = 1, group = "Custom Settings")
fastFactorInput = input.float(3.0, "Custom Fast Factor", minval = 0.1, step = 0.1, group = "Custom Settings")
slowFactorInput = input.float(5.0, "Custom Slow Factor", minval = 0.1, step = 0.1, group = "Custom Settings")

// --- Inputs: Styles (Indicator Only) ---
rsiBullColor    = input.color(#00ffbb, "RSI Bullish", group = "Styles")
rsiBearColor    = input.color(#ff0055, "RSI Bearish", group = "Styles")
fastQqeColor    = input.color(#5b9cf6, "Fast QQE Line", group = "Styles")
slowQqeColor    = input.color(#9598a1, "Slow QQE Dots", group = "Styles")
obZoneColor     = input.color(color.new(#00ffbb, 92), "Overbought Zone", group = "Styles")
osZoneColor     = input.color(color.new(#ff0055, 92), "Oversold Zone", group = "Styles")

// --- Inputs: Visual Overhaul ---
showDashInput   = input.bool(true, "Show AI Dashboard (Main Chart)", group = "Visual Overhaul")
dashPosInput    = input.string(position.top_right, "Dashboard Position", options = [position.top_left, position.top_right, position.bottom_left, position.bottom_right], group = "Visual Overhaul")
dashSizeInput   = input.string(size.small, "Dashboard Size", options = [size.tiny, size.small, size.normal, size.large, size.huge], group = "Visual Overhaul")
showGlowInput   = input.bool(true, "Enhanced Glow Effects", group = "Visual Overhaul")

// --- Mode Logic ---
int rsiLen    = modeInput == MODE_SWING ? 14  : modeInput == MODE_TREND ? 21  : modeInput == MODE_INTRADAY ? 7   : modeInput == MODE_REVERSAL ? 10  : rsiLenInput
int smoothing = modeInput == MODE_SWING ? 5   : modeInput == MODE_TREND ? 8   : modeInput == MODE_INTRADAY ? 3   : modeInput == MODE_REVERSAL ? 4   : smoothInput
float fFactor = modeInput == MODE_SWING ? 3.0 : modeInput == MODE_TREND ? 4.5 : modeInput == MODE_INTRADAY ? 2.0 : modeInput == MODE_REVERSAL ? 2.5 : fastFactorInput
float sFactor = modeInput == MODE_SWING ? 5.0 : modeInput == MODE_TREND ? 4.5 : modeInput == MODE_INTRADAY ? 3.5 : modeInput == MODE_REVERSAL ? 4.0 : slowFactorInput

// --- Core Calculations ---
rsiValue = ta.rsi(close, rsiLen)
rsiSmoothed = ta.ema(rsiValue, smoothing)

calcQQE(src, len, factor) =>
    qAtr = ta.rma(math.abs(src[1] - src), len * 2 - 1)
    qDar = qAtr * factor
    var float qLine = 0.0
    float newUpper = src + qDar
    float newLower = src - qDar
    qLine := src[1] > qLine and src > qLine ? math.max(qLine, newLower) : 
             src[1] < qLine and src < qLine ? math.min(qLine, newUpper) : 
             src > qLine ? newLower : newUpper
    qLine

qqeFast = calcQQE(rsiSmoothed, rsiLen, fFactor)
qqeSlow = calcQQE(rsiSmoothed, rsiLen, sFactor)

// Global metrics for dashboard
volatility = ta.atr(14) / close * 100

// --- Market Condition Logic (Dashboard Internal) ---
string marketCondition = "Neutral"
color conditionColor   = ACCENT_DASH

if rsiSmoothed > 50
    if rsiSmoothed > qqeSlow and rsiSmoothed > qqeFast
        marketCondition := rsiSmoothed > 70 ? "EXTREME BULLISH" : "STRONG BULLISH"
        conditionColor  := BULL_DASH
    else if rsiSmoothed < qqeFast
        marketCondition := "BULLISH PULLBACK"
        conditionColor  := NEUTRAL_DASH
else
    if rsiSmoothed < qqeSlow and rsiSmoothed < qqeFast
        marketCondition := rsiSmoothed < 30 ? "EXTREME BEARISH" : "STRONG BEARISH"
        conditionColor  := BEAR_DASH
    else if rsiSmoothed > qqeFast
        marketCondition := "BEARISH BOUNCE"
        conditionColor  := NEUTRAL_DASH

string actionAdvice = rsiSmoothed > 50 ? (rsiSmoothed > qqeFast ? "HOLD WINNERS" : "WATCH FAST") : (rsiSmoothed < qqeFast ? "CUT LOSERS" : "WATCH FAST")

// --- Visual Overhaul: Oscillator Pane ---
bgcolor(rsiSmoothed > 70 ? obZoneColor : na)
bgcolor(rsiSmoothed < 30 ? osZoneColor : na)

hMid = hline(50, "Midline", color.new(ACCENT_DASH, 80), linestyle = hline.style_dotted)
hOB  = hline(70, "OB", color.new(rsiBullColor, 60), linestyle = hline.style_dashed)
hOS  = hline(30, "OS", color.new(rsiBearColor, 60), linestyle = hline.style_dashed)

rsiDynamicColor = color.from_gradient(rsiSmoothed, 30, 70, rsiBearColor, rsiBullColor)
plot(rsiSmoothed, "RSI Glow", showGlowInput ? color.new(rsiDynamicColor, 80) : na, 6)
plotRsi = plot(rsiSmoothed, "Smoothed RSI", rsiDynamicColor, 2)

plotFast = plot(qqeFast, "Fast Trigger", fastQqeColor, 2, plot.style_linebr)
plotSlow = plot(qqeSlow, "Slow Trend", modeInput == MODE_SWING ? color.new(slowQqeColor, 30) : color(na), 1, plot.style_circles)

midPlot = plot(50, "Mid Reference", color.new(chart.fg_color, 100), display = display.none)
fill(plotRsi, midPlot, 
     top_value    = math.max(50, rsiSmoothed), 
     bottom_value = math.min(50, rsiSmoothed), 
     top_color    = rsiSmoothed > 50 ? color.new(rsiBullColor, 60) : color.new(rsiBearColor, 100), 
     bottom_color = rsiSmoothed > 50 ? color.new(rsiBullColor, 100) : color.new(rsiBearColor, 60),
     title        = "Main Gradient")

fill(plotRsi, plotFast, rsiSmoothed > qqeFast ? color.new(rsiBullColor, 85) : color.new(rsiBearColor, 85), "Cushion Fill")

// --- Visual Overhaul: Main Chart Dashboard ---
var table terminal = table.new(dashPosInput, 2, 6, bgcolor = color.new(PANEL_BG, 10), border_color = color.new(ACCENT_DASH, 70), border_width = 1, force_overlay = true)

if showDashInput and barstate.islast
    table.cell(terminal, 0, 0, "QQE TERMINAL", text_color = ACCENT_DASH, bgcolor = color.new(NEUTRAL_DASH, 20), text_size = dashSizeInput, text_halign = text.align_center)
    table.cell(terminal, 1, 0, "LIVE DATA", text_color = ACCENT_DASH, bgcolor = color.new(NEUTRAL_DASH, 20), text_size = dashSizeInput, text_halign = text.align_center)
    
    table.cell(terminal, 0, 1, "OPERATOR", text_color = ACCENT_DASH, text_halign = text.align_left, text_size = dashSizeInput)
    table.cell(terminal, 1, 1, modeInput, text_color = NEUTRAL_DASH, text_halign = text.align_right, text_size = dashSizeInput)
    
    table.cell(terminal, 0, 2, "PULSE", text_color = ACCENT_DASH, text_halign = text.align_left, text_size = dashSizeInput)
    table.cell(terminal, 1, 2, str.tostring(rsiSmoothed, "#.##"), text_color = rsiDynamicColor, text_halign = text.align_right, text_size = dashSizeInput)
    
    table.cell(terminal, 0, 3, "CONDITION", text_color = ACCENT_DASH, text_halign = text.align_left, text_size = dashSizeInput)
    table.cell(terminal, 1, 3, marketCondition, text_color = conditionColor, text_halign = text.align_right, text_size = dashSizeInput)

    table.cell(terminal, 0, 4, "ADVICE", text_color = ACCENT_DASH, text_halign = text.align_left, text_size = dashSizeInput)
    table.cell(terminal, 1, 4, actionAdvice, text_color = conditionColor, text_halign = text.align_right, text_size = dashSizeInput)

    table.cell(terminal, 0, 5, "VOLATILITY", text_color = ACCENT_DASH, text_halign = text.align_left, text_size = dashSizeInput)
    table.cell(terminal, 1, 5, str.format("{0,number,#.##}%", volatility), text_color = ACCENT_DASH, text_halign = text.align_right, text_size = dashSizeInput)

// Alerts
alertcondition(ta.cross(rsiSmoothed, qqeFast), "RSI Cross Fast QQE", "Smoothed RSI crossed the Fast QQE Trigger")
alertcondition(ta.cross(rsiSmoothed, qqeSlow), "RSI Cross Slow QQE", "Smoothed RSI crossed the Slow QQE Trend")
````
