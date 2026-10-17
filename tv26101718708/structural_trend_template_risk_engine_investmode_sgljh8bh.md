# Structural Trend Template & Risk Engine [InvestMode]

- url: https://www.tradingview.com/script/SGljH8bH-Structural-Trend-Template-Risk-Engine-InvestMode/
- type: indicator
- pine_id: PUB;69191e1fc3b2452ea3eb9e7cd85d03f2
- version: 1.0

## Description

### Overview
The "Structural Trend Template & Risk Engine v6" is a high-end technical overlay designed specifically for swing traders who prioritize mechanical risk management and capital preservation over emotional execution. 

Instead of reactive, low-frequency intra-day noise, this system relies on strict multi-day institutional trend alignments to isolate high-probability directional bias across equities and macro indices.

### Key Architectural Components

1. 🟢🔴 Structural Trend Filters (EMA Ribbon):
The engine tracks the mathematical space between a Fast (21) and Slow (50) Exponential Moving Average. It establishes a definitive baseline trend, systemizing the chart layout so users avoid late-entry chasing or trading against institutional momentum.

2. 📐 Dynamic Volatility Risk Ribbon (ATR Integration):
The script utilizes a 14-period Average True Range (ATR) algorithm to project precise structural target zones across your chart the exact bar close an entry signal triggers. 
- Dynamic OCO Floor (Red Ribbon): Automatically plots your structural protection net at 2.0x ATR.
- Dynamic OCO Ceiling (Blue Ribbon): Projects a dominant 4.0x ATR target ceiling, mechanically locking in an institutional 1:2 risk-to-reward ratio.

3. 🔔 Automated Bracket Alert String:
The system features a dynamically injected alert payload optimized for server-side processing. When the bar close confirms a trend shift, the system pushes an alert containing the exact textual coordinate values directly to your device—allowing for seamless coordination with your manual or automated broker execution dashboards.

### How to Use
1. Load the indicator on a macro swing timeframe (e.g., 4-Hour or 1-Day charts).
2. Wait for the engine to print a verified "InvestMode Entry" shape below the bar.
3. Configure a server-side alert tracking "Once Per Bar Close" to feed real-time coordinates instantly to your phone.
4. Utilize the projected Red (Stop-Loss) and Blue (Take-Profit) horizontal price ribbons to program your execution risk brackets.

--------------------------------------------------------------------------------
⚖️ LEGAL DISCLAIMER:
This script code is published open-source strictly for educational and technical illustrative purposes under the operations of Skalehub Inc. It does not constitute investment advice, financial analysis, or an endorsement/recommendation to buy or sell any security. Past performance of mathematical chart configurations does not guarantee future market results. Financial trading involves substantial risk of loss; users assume full personal responsibility for their individual technical setups and execution decisions.

## Source Code

````pine
//@version=6
indicator("InvestMode | Structural Trend & Risk Engine v6", overlay=true)

// =============================================================================
// ENGINE 1: TREND IDENTIFICATION (V6 METRICS)
// =============================================================================
int fastLength = input.int(21, title="Fast Trend Length", minval=1)
int slowLength = input.int(50, title="Slow Trend Length", minval=1)

float fastEMA = ta.ema(close, fastLength)
float slowEMA = ta.ema(close, slowLength)

plot(fastEMA, color=color.green, title="Fast Trend (21 EMA)", linewidth=2)
plot(slowEMA, color=color.red, title="Slow Trend (50 EMA)", linewidth=2)

// =============================================================================
// ENGINE 2: MATHEMATICAL RISK BOUNDARIES (V6 ATR CALCULATIONS)
// =============================================================================
int atrPeriod = input.int(14, title="ATR Period")
float atrMultiplier = input.float(2.0, title="Risk Multiplier (Stop Loss)")
float profitMultiplier = input.float(4.0, title="Target Multiplier (Take Profit)")

float atr = ta.atr(atrPeriod)

// =============================================================================
// ENGINE 3: SYSTEM SIGNALS & COMPILER FIXES
// =============================================================================
bool longEntrySignal = ta.crossover(fastEMA, slowEMA)

// Fixed V6 Shape Syntax Variables
plotshape(longEntrySignal, 
          title="InvestMode Entry", 
          style=shape.triangleup, 
          location=location.belowbar, 
          color=color.green, 
          size=size.small)

// =============================================================================
// PREMIUM FEATURES: HIGH-END DYNAMIC BRACKET RIBBONS
// =============================================================================
var float v6StopLoss = na
var float v6TakeProfit = na

if longEntrySignal
    v6StopLoss := close - (atr * atrMultiplier)
    v6TakeProfit := close + (atr * profitMultiplier)
else if close < v6StopLoss or close > v6TakeProfit
    v6StopLoss := na
    v6TakeProfit := na

// Plot structural target zones dynamically for the trader
plot(v6StopLoss, title="Dynamic OCO Floor (Stop Loss)", color=color.new(color.red, 30), style=plot.style_linebr, linewidth=2)
plot(v6TakeProfit, title="Dynamic OCO Ceiling (Take Profit)", color=color.new(color.blue, 30), style=plot.style_linebr, linewidth=2)

// =============================================================================
// AUTOMATED ALERT STRINGS
// =============================================================================
if longEntrySignal
    alert("InvestMode Alert: Trend shift confirmed. Entry: " + str.tostring(close) + " | Stop-Loss: " + str.tostring(v6StopLoss) + " | Take-Profit: " + str.tostring(v6TakeProfit), alert.freq_once_per_bar_close)
````
