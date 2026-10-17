# R2D2 Buy-Sell Indicator v1.5

- url: https://www.tradingview.com/script/B0D1EsYX-R2D2-Buy-Sell-Indicator-v1-5/
- type: indicator
- pine_id: PUB;ce570a567b9c4e8a85d2f22228071a91
- version: 1.0

## Description

[b]BSI Premium - Advanced Trend, Zone & Momentum System[/b]

Summary: A highly customizable, all-in-one momentum and trend indicator. BSI Premium features 6 unique trend states, high-conviction "Early Buy" signals, dynamically shaded trade zones, and a powerful multi-condition alert engine for automated scanning.

[b]Description:[/b]
Overview
Welcome to the BSI Premium (Buy Sell Indicator). This script is designed to act as a complete, standalone trading system or a powerful confluence tool alongside your existing strategy. By combining smoothed momentum oscillators, dynamic Bollinger Band clouds, and strict zero-line threshold logic, BSI Premium cuts through market noise to give you clear, actionable insights into short-term trends.

Whether you are looking for lower-risk entries, managing active positions, or hunting for high-reward reversal setups, BSI Premium visually guides you through every stage of the market cycle.

[b]🔥 Key Features

1. The 6-State Trend Engine[/b]
Instead of simple red and green, BSI Premium analyzes momentum and signal crossovers to define 6 specific micro-trends, visually plotted directly on the oscillator line:

Bright Green Dots: Trend Bullish (Momentum is accelerating in the Buy Zone).

Dark Green Dots: Fading Bull (In the Buy Zone, but losing strength).

Yellow Dots: Early Buy Setup (Momentum is improving below the zero line).

Red Dots: Trend Bearish (Momentum is falling in the Warning Zone).

Dark Red Dots: Improving Bear (In the Warning Zone, but things are getting better).

Grey Dots: Neutral (No clear short-term trend).

[b]2. Precision Action Signals[/b]

Early Buy (Purple Bubble): Triggers the first day conditions are met below the zero line. This is designed for high-conviction stocks and offers a higher risk/reward entry.

Standard Buy (White Bubble): Triggers when conditions are met above the zero line, indicating a lower-risk entry point.

Sell (Orange Bubble): Shows possible times to take profits or tighten stop losses.

[b]3. Visual Trade Zones & Bollinger Clouds[/b]
The chart background automatically shades Green (Buy Zones) and Red (Warning Zones) only when momentum strictly agrees with the signal line. Transitional periods are left unshaded (black), keeping your chart clean during chop. Furthermore, dynamic Bollinger Band Clouds wrap the oscillator, helping you visualize overextended momentum or squeeze conditions.

[b]4. Ultimate Customization (14 Inputs)[/b]
Every asset breathes differently. BSI Premium allows you to fully customize the mathematical core of the indicator. You can individually change the Fast, Slow, and Signal moving average types (choose between SMA, EMA, WMA, HullMA, and Wilders RMA), adjust lengths, and tweak Bollinger Band multipliers to fit your exact trading style.

[b]🔔 The Multi-Condition Alert Engine (Scanner Ready)[/b]
A powerful, unique feature of BSI Premium is its built-in alert engine. You can easily create automated Trade Alerts for any symbol, on any timeframe, without writing code.

Using TradingView's alert menu, you can set up pop-ups, emails, or SMS notifications for 7 distinct conditions, complete with dynamic ticker and price data:

Early Buy Signals

Standard Buy Signals

Sell Signals

Entering the Green Buy Zone

Entering the Red Warning Zone

Momentum crossing Above the Cloud

Momentum crossing Below the Cloud

[b]📖 How to Trade with BSI Premium[/b]
"In The Red, You’re Dead": The general rule of thumb is to avoid buying or adding to positions while in the Red Warning Zone. Most standard buy signals happen outside of this zone (with exceptions for momentum squeezes and deep reversals).

Zone Management: Use the green shaded areas to actively look for long entries. Conversely, use the red zones to tighten stops or consider closing out positions.

The "Early" Advantage: Use the Early Buy signal to enter high-conviction stocks at the bottom of a cycle for maximum risk/reward, scaling into the rest of your position when the Standard Buy triggers.

Confluence: BSI Premium works beautifully by itself, but it can also be paired with volume oscillators or broader market indicators to confirm entries.

Disclaimer: This script is for educational and informational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always practice proper risk management and backtest indicators before using them with real capital.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Assistant

//@version=5
indicator("R2D2 Buy-Sell Indicator v1.5", shorttitle="BSI Premium (R2D2)", overlay=false)

// ==============================================================================
// 1. EXACTLY 14 USER INPUTS 
// ==============================================================================
src       = input.source(close, "Source", group="Calculations")
fastLen   = input.int(12, "Fast MA Length", group="Calculations")
slowLen   = input.int(26, "Slow MA Length", group="Calculations")
sigLen    = input.int(5, "Signal Length", group="Calculations")
maTypeF   = input.string("EMA", "Fast MA Type", options=["SMA", "EMA", "WMA", "HullMA", "Wilders"], group="Calculations")
maTypeS   = input.string("EMA", "Slow MA Type", options=["SMA", "EMA", "WMA", "HullMA", "Wilders"], group="Calculations")
maTypeSig = input.string("SMA", "Signal MA Type", options=["SMA", "EMA", "WMA", "HullMA", "Wilders"], group="Calculations")
bbLen     = input.int(20, "Bollinger Band Length", group="Calculations")
bbMult    = input.float(1.5, "Bollinger Band Multiplier", step=0.1, group="Calculations")
neutZone  = input.float(0.02, "Neutral Zone Threshold", step=0.01, group="Calculations")

showBands = input.bool(true, "Show BB Clouds", group="Visuals")
showBg    = input.bool(true, "Show Buy/Warning Zones (Background)", group="Visuals")
showSigs  = input.bool(true, "Show Signal Bubbles", group="Visuals")
showTable = input.bool(true, "Show Trend/Zone Labels", group="Visuals")

// ==============================================================================
// 2. CORE CALCULATIONS
// ==============================================================================
getMA(type, src, len) =>
    switch type
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "WMA" => ta.wma(src, len)
        "HullMA" => ta.hma(src, len)
        "Wilders" => ta.rma(src, len)
        => ta.ema(src, len)

fastMA = getMA(maTypeF, src, fastLen)
slowMA = getMA(maTypeS, src, slowLen)
osc    = fastMA - slowMA
signal = getMA(maTypeSig, osc, sigLen)

[_, bbUpper, bbLower] = ta.bb(osc, bbLen, bbMult)

// ==============================================================================
// 3. TREND LOGIC & EXACT COLORS
// ==============================================================================
bool isNeutral   = math.abs(osc) <= neutZone
bool isGreen     = osc > 0 and osc > osc[1] and not isNeutral
bool isDarkGreen = osc > 0 and osc <= osc[1] and not isNeutral
bool isRed       = osc < 0 and osc < osc[1] and not isNeutral
bool isYellow    = osc < 0 and osc >= osc[1] and osc > signal and not isNeutral
bool isDarkRed   = osc < 0 and osc >= osc[1] and osc <= signal and not isNeutral

color dotColor = isNeutral ? color.gray : 
                 isGreen ? color.rgb(0, 255, 0) :      
                 isDarkGreen ? color.rgb(0, 128, 0) :  
                 isYellow ? color.rgb(255, 255, 0) :   
                 isRed ? color.rgb(255, 0, 0) :        
                 isDarkRed ? color.rgb(139, 0, 0) :    
                 color.gray

// ==============================================================================
// 4. SIGNALS & ZONE LOGIC
// ==============================================================================
bool earlyBuy = ta.crossover(osc, signal) and osc < 0
bool stdBuy   = (ta.crossover(osc, signal) and osc > 0) or (ta.crossover(osc, 0) and osc > signal)
bool sellSig  = ta.crossunder(osc, signal)

bool isBuyZone  = osc > 0 and osc > signal
bool isWarnZone = osc < 0 and osc < signal

// ==============================================================================
// 5. PLOTTING & VISUALS (OPACITY ADJUSTED HERE)
// ==============================================================================
// Changed transparency from 85 down to 40 so they are much more opaque and visible
bgcolor(showBg and isBuyZone ? color.new(color.green, 40) : na, title="Buy Zone Shading")
bgcolor(showBg and isWarnZone ? color.new(color.red, 40) : na, title="Warning Zone Shading")

hline(0, "Zero Line", color=color.new(color.white, 50))

p_upper = plot(showBands ? bbUpper : na, "BB Upper", color=color.new(color.red, 70))
p_lower = plot(showBands ? bbLower : na, "BB Lower", color=color.new(color.red, 70))
fill(p_upper, p_lower, color=color.new(color.red, 85), title="Bollinger Cloud")

plot(signal, title="Signal Line", color=color.new(color.orange, 0), linewidth=1)
plot(osc, title="Trend Line", color=dotColor, style=plot.style_line, linewidth=2)
plot(osc, title="Trend Dots", color=dotColor, style=plot.style_circles, linewidth=3)

plotshape(showSigs and earlyBuy ? osc : na, title="Early Buy", style=shape.labelup, location=location.absolute, color=color.purple, text="Early", textcolor=color.white, size=size.tiny)
plotshape(showSigs and stdBuy ? osc : na, title="Buy", style=shape.labelup, location=location.absolute, color=color.white, text="Buy", textcolor=color.black, size=size.tiny)
plotshape(showSigs and sellSig ? osc : na, title="Sell", style=shape.labeldown, location=location.absolute, color=color.orange, text="Sell", textcolor=color.black, size=size.tiny)

// ==============================================================================
// 6. DUAL-LABEL TREND & ZONE TABLE
// ==============================================================================
var table labelsTable = table.new(position.bottom_right, 3, 1, bgcolor=color.new(color.black, 100), border_width=0)

if showTable and barstate.islast
    string trendText = isGreen ? "Trend Bullish" : isDarkGreen ? "Trend Fading Bull" : isRed ? "Trend Bearish" : isDarkRed ? "Trend Improving Bear" : isYellow ? "Trend Early Setup" : "Trend Neutral"
    color trendBgColor = isGreen ? color.rgb(0, 255, 0) : isDarkGreen ? color.rgb(0, 128, 0) : isRed ? color.rgb(255, 0, 0) : isDarkRed ? color.rgb(139, 0, 0) : isYellow ? color.rgb(255, 255, 0) : color.gray
    color trendTxtColor = (isGreen or isYellow) ? color.black : color.white 
    
    string zoneText = isBuyZone ? "Buy Zone" : isWarnZone ? "Warning Zone" : "Neutral Zone"
    color zoneBgColor = isBuyZone ? color.rgb(0, 128, 0) : isWarnZone ? color.rgb(200, 50, 50) : color.gray
    
    table.cell(labelsTable, 0, 0, trendText, text_color=trendTxtColor, bgcolor=trendBgColor)
    table.cell(labelsTable, 1, 0, "  ", text_color=color.black, bgcolor=color.black) 
    table.cell(labelsTable, 2, 0, zoneText, text_color=color.white, bgcolor=zoneBgColor)

// ==============================================================================
// 7. MULTI-CONDITION TRADE ALERTS
// ==============================================================================
alertcondition(earlyBuy, title="1. EARLY BUY ALERT", message="EARLY BUY triggered for {{ticker}} on the {{interval}} chart at ${{close}}.")
alertcondition(stdBuy, title="2. BUY ALERT", message="STANDARD BUY triggered for {{ticker}} on the {{interval}} chart at ${{close}}.")
alertcondition(sellSig, title="3. SELL ALERT", message="SELL SIGNAL triggered for {{ticker}} on the {{interval}} chart at ${{close}}.")
alertcondition(isBuyZone and not isBuyZone[1], title="4. Entered Buy Zone (Green)", message="{{ticker}} has entered the GREEN BUY ZONE on the {{interval}} chart.")
alertcondition(isWarnZone and not isWarnZone[1], title="5. Entered Warning Zone (Red)", message="{{ticker}} has entered the RED WARNING ZONE on the {{interval}} chart.")
alertcondition(ta.crossover(osc, bbUpper), title="6. Crossed Above Cloud", message="{{ticker}} momentum crossed ABOVE the Bollinger Cloud on the {{interval}} chart.")
alertcondition(ta.crossunder(osc, bbLower), title="7. Crossed Below Cloud", message="{{ticker}} momentum crossed BELOW the Bollinger Cloud on the {{interval}} chart.")

// May the trades be with you.
````
