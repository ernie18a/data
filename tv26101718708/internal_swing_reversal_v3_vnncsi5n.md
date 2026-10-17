# Internal Swing Reversal V3 

- url: https://www.tradingview.com/script/VnNCsI5N-Internal-Swing-Reversal-V3/
- type: indicator
- pine_id: PUB;a81db997aaad407388a972b73307b54a
- version: 1.0

## Description

In this video, I’m pulling back the curtain on a collaboration between a trader and AI. I took my manual observations on Gold (XAUUSD)—specifically those frustrating internal swing "fakes"—and challenged Gemini to turn them into a definitive, code-backed signal.

The Mission:
Eliminate the noise. I wanted an indicator that doesn't just look for "overbought" or "oversold," but one that understands market memory and momentum gravity.

Watch the Evolution:

The Brainstorm: How I explained my "Purple Arrow" logic to Gemini using live chart screenshots.

The Problem Solving: Watch us troubleshoot Pine Script v6 compiler errors in real-time (no more help argument bugs!).

The Optimization: How Gemini suggested a 50-candle "RSI Memory" filter and MACD zero-line confirmation to kill false positives.

The Result: A clean, professional-grade visual tool that marks liquidity sweeps only when the probability is highest.

Why this matters:
Most traders use indicators out of the box. Today, I’m showing you how to be the architect of your own tools by using Gemini as your lead developer.

## Source Code

````pine
//@version=6
indicator("Internal Swing Reversal V3 [Gemini]", overlay=true, max_labels_count=500)

// --- Inputs ---
rsi_len     = input.int(14, "RSI Length")
rsi_ob      = input.int(70, "RSI Overbought Threshold")
rsi_os      = input.int(30, "RSI Oversold Threshold")
rsi_look    = input.int(50, "RSI Memory Lookback", tooltip="Checks if RSI touched extremes within this many bars")

macd_fast   = input.int(12, "MACD Fast")
macd_slow   = input.int(26, "MACD Slow")
macd_sig    = input.int(9, "MACD Signal")

lb_period   = input.int(10, "Pivot Lookback", tooltip="High/Low check for the immediate sweep")
conf_delay  = input.int(2, "Confirmation Bars")

// --- Calculations ---
rsi_val = ta.rsi(close, rsi_len)
[macd_line, signal_line, hist] = ta.macd(close, macd_fast, macd_slow, macd_sig)

// 1. RSI Memory Logic: Was it recently Overbought or Oversold?
// ta.highest and ta.lowest on the RSI series itself
was_ob = ta.highest(rsi_val, rsi_look) >= rsi_ob
was_os = ta.lowest(rsi_val, rsi_look) <= rsi_os

// 2. Immediate Structural Sweep
peak_high  = ta.highest(high, lb_period)
trough_low = ta.lowest(low, lb_period)

// --- The "Purple Arrow" Logic with Multi-Layer Filters ---

// Bearish Reversal: 
// 1. RSI was recently > 70
// 2. MACD Lines are > 0 (Upward bias exhaustion)
// 3. Price just peaked and is rolling over (confirmed by hist and close)
bear_confirm = was_ob and 
               macd_line < 0 and 
               signal_line < 0 and 
               high[conf_delay] == peak_high and 
               hist < hist[1] and 
               close < open

// Bullish Reversal:
// 1. RSI was recently < 30
// 2. MACD Lines are < 0 (Downward bias exhaustion)
// 3. Price just bottomed and is recovering
bull_confirm = was_os and 
               macd_line > 0 and 
               signal_line > 0 and 
               low[conf_delay] == trough_low and 
               hist > hist[1] and 
               close > open

// --- Visuals ---
//plotshape(bear_confirm, title="Confirmed Bear Reversal", style=shape.triangledown, location=location.abovebar - 10, color=color.purple, size=size.tiny)
//plotshape(bull_confirm, title="Confirmed Bull Reversal", style=shape.triangleup, location=location.belowbar + 10, color=color.purple, size=size.tiny)
// --- Inside your Bearish Logic ---
if bear_confirm
    // Calculate distance: high + 10% of the current ATR or a fixed tick amount
    float dist = ta.atr(14) * 1.25 
    label.new(bar_index, high + dist, text="▼", color=color.new(#9b27b0, 100), textcolor=color.purple, style=label.style_label_down, size=size.small)

// --- Inside your Bullish Logic ---
if bull_confirm
    float dist = ta.atr(14) * 1.25
    label.new(bar_index, low - dist, text="▲", color=color.new(#9b27b0, 100), textcolor=color.purple, style=label.style_label_up, size=size.small)


// Visualizing the RSI Memory status for debugging (Optional)
plot(was_ob ? 1 : 0, "OB Memory Active", color=color.new(color.red, 90), display=display.status_line)
plot(was_os ? 1 : 0, "OS Memory Active", color=color.new(color.green, 90), display=display.status_line)

// --- Alerts ---
alertcondition(bear_confirm or bull_confirm, "5min Reversal", "XAUUSD Reversal Confirmed")
//alertcondition(bull_confirm, "Bullish Purple Arrow", "XAUUSD Bullish Reversal Confirmed")
````
