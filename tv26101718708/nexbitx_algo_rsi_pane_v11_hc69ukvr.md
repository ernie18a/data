# NexBitX Algo - RSI Pane v1.1

- url: https://www.tradingview.com/script/hc69uKVr-NexBitX-Algo-RSI-Pane-v1-1/
- type: indicator
- pine_id: PUB;d158421cf853439db928e808354a6df3
- version: 1.0

## Description

NexBitX Algo — RSI Pane v1.1

NexBitX Algo — RSI Pane is a clean momentum indicator designed to help traders identify overbought, oversold, and neutral RSI market conditions with professional NexBitX styling.

This indicator plots RSI in a separate pane with dynamic color changes, overbought/oversold levels, midline reference, zone fills, and RSI exit signals.

Key Features

✅ RSI Momentum Analysis
✅ Overbought & Oversold Zones
✅ Dynamic RSI Color Change
✅ RSI Buy Signal when exiting Oversold Zone
✅ RSI Sell Signal when exiting Overbought Zone
✅ Clean RSI Pane Layout
✅ NexBitX Branded Watermark

How It Works

• RSI above Overbought level indicates strong momentum but possible exhaustion.
• RSI below Oversold level indicates weak momentum but possible reversal.
• RSI crossing back above Oversold may suggest a potential buy setup.
• RSI crossing back below Overbought may suggest a potential sell setup.

Best Use

This indicator can be used for:

• Stocks
• Index
• Futures & Options
• Forex
• Commodities
• Crypto

It works best when combined with trend indicators, support/resistance, price action, and proper risk management.

Disclaimer

This indicator is intended for educational and analytical purposes only. It does not provide financial advice or guarantee trading results. Always perform your own analysis and use proper risk management when trading.

Developed by NexBitX Algo.

## Source Code

````pine
// ============================================================
//  NexBitX Algo — RSI Pane v1.1
//  © NexBitX Algo — All Rights Reserved
// ============================================================
//@version=6
indicator(
     title      = "NexBitX Algo — RSI",
     shorttitle = "NBX-RSI",
     overlay    = false
)

// ── Inputs ────────────────────────────────────────────────
rsi_len  = input.int(14, "RSI Length", minval=1)
rsi_ob   = input.int(70, "Overbought", minval=50)
rsi_os   = input.int(30, "Oversold",   maxval=50)

// ── Colors ────────────────────────────────────────────────
color NBX_BLUE     = color.new(#00BFFF, 0)
color NBX_GOLD     = color.new(#FFA500, 0)
color NBX_BEAR     = color.new(#FF4C4C, 0)
color NBX_BULL     = color.new(#00BFFF, 0)
color OB_FILL      = color.new(#FF4C4C, 88)
color OS_FILL      = color.new(#00BFFF, 88)
color MID_LINE     = color.new(#FFA500, 60)

// ── RSI Calculation ───────────────────────────────────────
rsiValue = ta.rsi(close, rsi_len)
rsiColor = rsiValue >= rsi_ob ? NBX_BEAR :
           rsiValue <= rsi_os ? NBX_BULL : NBX_GOLD

// ── Plots ─────────────────────────────────────────────────
rsiPlot = plot(rsiValue, "RSI", color=rsiColor, linewidth=2)
obPlot  = plot(rsi_ob,   "Overbought", color=color.new(#FF4C4C, 40), linewidth=1)
osPlot  = plot(rsi_os,   "Oversold",   color=color.new(#00BFFF, 40), linewidth=1)
midPlot = plot(50,       "Midline",    color=MID_LINE,                linewidth=1)

// ── OB / OS Zone Fills ────────────────────────────────────
fill(rsiPlot, obPlot,
     color = rsiValue >= rsi_ob ? OB_FILL : na,
     title = "Overbought Fill")
fill(rsiPlot, osPlot,
     color = rsiValue <= rsi_os ? OS_FILL : na,
     title = "Oversold Fill")

// ── OB/OS Cross Signals ───────────────────────────────────
rsiCrossOB = ta.crossunder(rsiValue, rsi_ob)
rsiCrossOS = ta.crossover(rsiValue,  rsi_os)

plotshape(rsiCrossOS, title="RSI Buy",
     style    = shape.triangleup,
     location = location.bottom,
     color    = NBX_BULL,
     size     = size.tiny)

plotshape(rsiCrossOB, title="RSI Sell",
     style    = shape.triangledown,
     location = location.top,
     color    = NBX_BEAR,
     size     = size.tiny)

// ── Watermark ─────────────────────────────────────────────
var table wm = table.new(position.bottom_right, 1, 1,
     bgcolor      = color.new(#0A1628, 40),
     border_color = color.new(#FFA500, 60),
     border_width = 1)
table.cell(wm, 0, 0, "NexBitX RSI",
     text_color  = color.new(#FFA500, 0),
     text_size   = size.tiny,
     text_halign = text.align_center)
````
