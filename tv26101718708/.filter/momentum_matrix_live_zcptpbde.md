# Momentum Matrix [LIVE]

- url: https://www.tradingview.com/script/ZCPtpbDE-Momentum-Matrix-LIVE/
- type: indicator
- pine_id: PUB;3fc16fc0a72b4c66b58ec53f3a8715ea
- version: 2.0

## Description

[b]### Introduction[/b]
Welcome to [b]Momentum Matrix [LIVE][/b], a multi-dimensional momentum and volatility confluence engine. This indicator combines Linear Geometry (Moving Average Slope) with Derivative Volatility Breakouts (Bollinger Bands applied to a custom MACD line) to create a rigorous, two-step verification system designed to identify high-probability trend expansions while filtering out low-volume market noise and chop.

[b]### How It Works[/b]

1. [i]**The Core Trend (MA Angle):**[/i] The script normalizes a moving average using an Average True Range (ATR) calculation to determine its precise geometric angle. It flags the trend as bullish or bearish only when the moving average breaks past a user-defined threshold (e.g., 6°), turning flat ranges grey (**No Trade Zone**).
2.[i] **The Volatility Trigger (MACD BB):** [/i]A custom MACD line is tracked natively against standard deviation Bollinger Bands. When momentum expands, the MACD line punches outside the bands.
3. **The Confluence Signal:** When [i]**both**[/i] systems simultaneously turn bright green or bright red, the script prints a distinct[i] **Confluence Dot** [/i]on the zero line, signaling an institutional momentum breakout.

---

[b]### Key Use Cases[/b]

[b]*🚀 **Squeeze Play & Volatility Breakout Entries***[/b]
Entering the trade on the first Confluence Dot catches the absolute beginning of a macro trend expansion.

[b]*📈 **High-Probability Trend Following***[/b]
As long as the lines and histograms stay locked in solid green or red, it proves that the velocity of the move is being actively sustained by volume.

[b]
*⚠️ **False Breakout Filter (Staying Out of Chop)***[/b]
Many traders lose money by buying a breakout on the price chart, only for it to immediately reverse. This indicator acts as a gatekeeper. If price makes a sudden spike upward, the MACD might briefly flash green. However, if the broader Moving Average Angle remains flat and stuck in the "No Trade Zone," the indicator refuses to print a buy dot, preventing FOMO entries.

[b]*⏱️ **Scalping with the Live Delta Dashboard***[/b]
 If an asset is moving up but the live angle change starts decaying (e.g., dropping from +2.5° down to +0.2°), it signals a hidden momentum loss—alerting you to take profits before the price action actually stalls out.

---

[b]### Key Features[/b]
* **Adaptive MA Selection:** Swap between EMA, SMA, HMA, LSMA, ALMA, and McGinley.
* **Built-in Volatility Filter:** Bollinger Bands track the MACD line directly to confirm momentum expansion.
* **Live Statistics Table:** View current trend angles and live changes on every tick.
* **Strict Non-Repainting Signals:** Confluence triggers confirm at the close of the bar to ensure historical data accuracy.

---

[b]### Credits & Acknowledgments[/b]
This script is a customized confluence engine built upon the excellent open-source work of two brilliant developers in the TradingView community. Special thanks to:
* **[b]@Mango2Juice[/b]** for the foundational logic behind the *Angle of Moving Averages* script.
* **[b]@Algokid[/b]** for the original concept and design of the *AK MACD BB indicator*.

This version modernizes the calculations into [b]Pine Script v5[/b], introduces a dynamic real-time tracking dashboard, and establishes a strict non-repainting mathematical handshake between both metrics.

## Source Code

````pine
//@version=5
indicator("Momentum Matrix [Live]", overlay=false)

var string G1 = "Angle MA Settings"
i_lookback   = input.int(2,       "Angle Period", group=G1, minval = 1)
i_atrPeriod  = input.int(10,      "ATR Period",   group=G1, minval = 1)
i_angleLevel = input.int(6,       "Angle Level",  group=G1, minval = 1)
i_maLength   = input.int(20,      "MA Length",    group=G1, minval = 1)
i_maType     = input.string("EMA", "MA Type",     options=["ALMA", "EMA", "DEMA", "TEMA", "WMA", "VWMA", "SMA", "SMMA", "HMA", "LSMA", "Kijun", "McGinley"], group=G1)
i_maSource   = input.source(close, "MA Source",    group=G1)
i_lsmaOffset = input.int(0,     "* LSMA Only - Offset Value", group=G1, minval=0)
i_almaOffset = input.float(0.85, "* ALMA Only - Offset Value",  group=G1, minval=0.0, step=0.01) 
i_almaSigma  = input.int(6,     "* ALMA Only - Sigma Value",   group=G1, minval=0)
i_noTZone    = input.bool(true,  "No Trade Zone", group=G1)

var string G2 = "MACD BB Settings"
bb_length    = input.int(10,      "BB Periods",   group=G2, minval=1)
bb_dev       = input.float(1.0,   "Deviations",   group=G2, minval=0.0001)
fastLength   = input.int(12,      "MACD Fast Length", group=G2, minval=1) 
slowLength   = input.int(26,      "MACD Slow Length", group=G2, minval=1)
signalLength = input.int(9,       "MACD Signal Length", group=G2, minval=1)

var string G3 = "Global Visuals"
i_barColor   = input.bool(false, "Paint Chart Bars?", group=G3)
i_showTable  = input.bool(true,  "Show Live Angle Dashboard?", group=G3)

f_angle(_src, _lookback, _atrPeriod) =>
    _atr = ta.atr(_atrPeriod)
    ang = math.atan((_src - _src[_lookback]) / _atr / _lookback) * (180 / math.pi)
    ang


f_mcginley(_src, _len) =>
    mg = 0.0
    mg := na(mg[1]) ? ta.ema(_src, _len) : mg[1] + (_src - mg[1]) / (_len * math.pow(_src/mg[1], 4))
    mg

f_ma(type, _src, _len) =>
    float result = 0.0
    switch type
        "SMA"      => result := ta.sma(_src, _len)
        "EMA"      => result := ta.ema(_src, _len)
        "DEMA"     => 
            e = ta.ema(_src, _len)
            result := 2 * e - ta.ema(e, _len)
        "TEMA"     => 
            e = ta.ema(_src, _len)
            result := 3 * (e - ta.ema(e, _len)) + ta.ema(ta.ema(e, _len), _len)
        "WMA"      => result := ta.wma(_src, _len)
        "VWMA"     => result := ta.vwma(_src, _len) 
        "SMMA"     => result := ta.rma(_src, _len) 
        "HMA"      => result := ta.hma(_src, _len)
        "LSMA"     => result := ta.linreg(_src, _len, i_lsmaOffset)
        "ALMA"     => result := ta.alma(_src, _len, i_almaOffset, i_almaSigma)
        "Kijun"    => result := math.avg(ta.lowest(_len), ta.highest(_len))
        "McGinley" => result := f_mcginley(_src, _len) 
    result

_ma    = f_ma(i_maType, i_maSource, i_maLength)
_angle = f_angle(_ma, i_lookback, i_atrPeriod)

color color_H = _angle > 0 ? color.lime : _angle < 0 ? color.red : color.gray
color color_L = _angle > _angle[1] and _angle > i_angleLevel ? color.lime : _angle < _angle[1] and _angle < -i_angleLevel ? color.red : color.gray
color c_ntz   = i_noTZone ? color_L : color_H

fastMA = ta.ema(close, fastLength)
slowMA = ta.ema(close, slowLength)
macd   = fastMA - slowMA

Std    = ta.stdev(macd, bb_length)
Upper  = (Std * bb_dev + (ta.sma(macd, bb_length)))
Lower  = ((ta.sma(macd, bb_length)) - (Std * bb_dev))

color mc = macd >= Upper ? color.lime : color.red

bool isAngleGreen = (c_ntz == color.lime)
bool isAngleRed   = (c_ntz == color.red)
bool isMacdGreen  = (mc == color.lime)
bool isMacdRed    = (mc == color.red)

bool confluenceBuy  = isAngleGreen and isMacdGreen and not (isAngleGreen[1] and isMacdGreen[1])
bool confluenceSell = isAngleRed   and isMacdRed   and not (isAngleRed[1]   and isMacdRed[1])

plot(_angle, "Angle MA Line", color=c_ntz, linewidth=2, style=plot.style_line)
plot(_angle, "Angle MA Histogram", color=c_ntz, linewidth=3, style=plot.style_histogram)

Band1 = plot(Upper, color=color.new(color.gray, 30), style=plot.style_line, linewidth=1, title="Upper Band")
Band2 = plot(Lower, color=color.new(color.gray, 30), style=plot.style_line, linewidth=1, title="Lower Band")
fill(Band1, Band2, color=color.new(color.blue, 90), title="BB Fill")
plot(macd, "MACD Circles", color=mc, style=plot.style_circles, linewidth=3)

zeroline = 0 
plot(zeroline, color=color.orange, linewidth=2, title="Zeroline")

plotshape(confluenceBuy  ? 0 : na, title="Buy Trigger",  style=shape.circle, location=location.absolute, color=color.lime, size=size.small)
plotshape(confluenceSell ? 0 : na, title="Sell Trigger", style=shape.circle, location=location.absolute, color=color.red,  size=size.small)

color finalBarColor = macd > Upper ? color.yellow : macd < Lower ? color.aqua : na
barcolor(i_barColor ? finalBarColor : na)

var table liveTable = table.new(position = position.top_right, columns = 2, rows = 2, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.gray)

if i_showTable and barstate.islast
    float angle_change = _angle - _angle[1]
    color text_color   = _angle > i_angleLevel ? color.lime : _angle < -i_angleLevel ? color.red : color.white
    color change_color = angle_change >= 0 ? color.lime : color.red
    
    table.cell(liveTable, 0, 0, "Current Angle", text_color = color.white, text_size = size.small)
    table.cell(liveTable, 1, 0, "Live Change", text_color = color.white, text_size = size.small)
    
    table.cell(liveTable, 0, 1, str.tostring(_angle, "#.##") + "°", text_color = text_color, text_size = size.normal, bgcolor=color.new(text_color, 85))
    table.cell(liveTable, 1, 1, (angle_change >= 0 ? "+" : "") + str.tostring(angle_change, "#.##") + "°", text_color = change_color, text_size = size.normal, bgcolor=color.new(change_color, 85))
````
