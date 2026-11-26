# VWAP Bands

- url: https://www.tradingview.com/script/1l5ShM54/
- type: indicator
- pine_id: PUB;422c3d3ffe534bba8487a66e5d18e1ea
- version: 3.0

## Description

Event Based VWAP Bands with EMA & TP Signals - Complete Guide
📊 Indicator Overview
This enhanced version of LuxAlgo's Event Based VWAP Bands combines the powerful Volume Weighted Average Price (VWAP) indicator with Exponential Moving Average (EMA) crossover signals and real-time Take Profit (TP) signals. The indicator provides a comprehensive trading system with multiple entry and exit signals based on price interactions with VWAP bands.

🔍 Core Components
1. VWAP (Volume Weighted Average Price)
Basis Line (Orange): Represents the volume-weighted average price

Upper Band (Blue): Basis + (Standard Deviation × Multiplier)

Lower Band (Red): Basis - (Standard Deviation × Multiplier)

Band Width: Determined by the Multiplier value (3.5 recommended)

2. EMA (Exponential Moving Average)
Blue Line: Smoothed price average with ultra-fast response (Length: 1 recommended)

Provides early entry signals through crossover detection

3. Take Profit (TP) System
BUY TP: Triggers IMMEDIATELY when price touches the Upper Band

SELL TP: Triggers IMMEDIATELY when price touches the Lower Band

Real-time detection: No waiting for bar close

🎯 Signal Logic & Timing
Signal Type	Trigger Condition	Timing	Visual
BUY	EMA crosses ABOVE VWAP Basis	Bar Close	Green "BUY" label
SELL	EMA crosses BELOW VWAP Basis	Bar Close	Red "SELL" label
BUY TP	Price touches Upper Band	IMMEDIATE	Lime "BUY TP" label
SELL TP	Price touches Lower Band	IMMEDIATE	Fuchsia "SELL TP" label
Signal Detection Logic:
text
BUY Signal  = ta.crossover(ema_value, pvwap)     // EMA crosses above
SELL Signal = ta.crossunder(ema_value, pvwap)    // EMA crosses below

BUY TP Signal  = high >= upper_band and low <= upper_band   // Price touches upper band
SELL TP Signal = high >= lower_band and low <= lower_band   // Price touches lower band
⚙️ Recommended Settings (Default)
📈 VWAP Settings
text
✅ Start At First Bar: CHECKED
   Length: 14 periods
   Multiplier: 3.5 ★ (Critical for TP sensitivity)
   Source: open
🎯 Event Settings
text
Event Type: Trend Change
External Cross/Event: open
📊 EMA Settings
text
EMA Length: 1 (Ultra-fast response)
Show EMA: CHECKED
🔔 Alert & Display Settings
text
Enable Alerts: CHECKED
Show TP Signals: CHECKED
Enable TP Alerts: CHECKED
💡 Why These Settings Work Best:
Setting	Value	Reason
Multiplier	3.5	Wider bands reduce false TP signals while capturing significant price movements
Source	open	More stable VWAP calculation using opening price
Event	Trend Change	Resets VWAP at trend reversals for better adaptability
EMA Length	1	Highly responsive to price changes for earlier signals
Start At First Bar	True	Ensures consistent VWAP calculation from chart beginning
🚨 Alert System
The indicator includes 4 separate alert conditions for comprehensive monitoring:

EMA Signals:
Buy Alert: "EMA crossed above VWAP Basis! Buy signal"

Sell Alert: "EMA crossed below VWAP Basis! Sell signal"

TP Signals:
Buy TP Alert: "Price touched VWAP Upper Band! BUY TP signal"

Sell TP Alert: "Price touched VWAP Lower Band! SELL TP signal"

Alert Status Indicators:
▲ (Green): Buy Alert Trigger

▼ (Red): Sell Alert Trigger

⬆ (Lime): Buy TP Trigger

⬇ (Fuchsia): Sell TP Trigger

📝 How to Use This Strategy
Entry Strategy (EMA Crossovers)
BUY Entry: When EMA crosses above VWAP Basis → Consider entering long position

SELL Entry: When EMA crosses below VWAP Basis → Consider entering short position

Exit/Take Profit Strategy
BUY TP: When price touches Upper Band → Take profit on long positions

SELL TP: When price touches Lower Band → Take profit on short positions

Risk Management Notes
Use Upper Band as realistic profit target for long positions

Use Lower Band as realistic profit target for short positions

Wider multiplier (3.5) provides more achievable profit targets

TP signals trigger in real-time, allowing immediate action

🎨 Visual Guide
Element	Color	Symbol	Meaning
Upper Band	Blue	Line	Resistance/Profit Target
Basis	Orange	Line	VWAP Center
Lower Band	Red	Line	Support/Profit Target
EMA	Blue	Line	Moving Average
BUY Signal	Green	"BUY" label	Entry signal
SELL Signal	Red	"SELL" label	Entry signal
BUY TP Signal	Lime	"BUY TP" label	Take profit signal
SELL TP Signal	Fuchsia	"SELL TP" label	Take profit signal
⚠️ Important Notes
TP signals are real-time: Trigger immediately when price touches bands, bar close not required

EMA signals are bar-close: Traditional crossover signals confirmed at bar close

Multiplier affects all signals: Higher multiplier = wider bands = fewer but more significant signals

Multiple signals possible: EMA and TP signals can occur independently

Event-based reset: VWAP recalculates at Trend Change events for better accuracy

🔧 Customization Options
Users can adjust:

Multiplier: Control band width and TP sensitivity

EMA Length: Adjust signal speed (1 = fastest)

Source: Change VWAP calculation base

Event Type: Modify reset conditions

Colors: Customize visual appearance

Alerts: Enable/disable specific signals

📊 Example Scenario
text
Price Action:
1. EMA crosses above VWAP Basis → BUY signal (Green label)
2. Price rises and touches Upper Band → BUY TP signal (Lime label) 
3. Take profit at Upper Band
4. Price reverses, EMA crosses below VWAP Basis → SELL signal (Red label)
5. Price falls and touches Lower Band → SELL TP signal (Fuchsia label)
6. Take profit at Lower Band
🙏 Special Thanks & Credits
This indicator builds upon the exceptional work of LuxAlgo, the original creator of the Event Based VWAP Bands indicator.

Why LuxAlgo's Work Matters:
Innovative Approach: Revolutionized VWAP calculation with event-based resets

Versatile Framework: Allows for creative extensions like this enhanced version

Professional Quality: Industry-standard code structure and reliability

Open Source Contribution: Enables the trading community to build and improve

Thank you, LuxAlgo, for developing such a robust and versatile VWAP framework that serves as the foundation for this enhanced indicator. Your contribution to the trading community is invaluable.

📌 Quick Reference Card
text
┌─────────────────────────────────────────────────────────────┐
│                  SIGNAL REFERENCE CARD                      │
├─────────────────────────────────────────────────────────────┤
│  ENTRY SIGNALS:                                            │
│  BUY  : EMA crosses ABOVE VWAP Basis (Bar Close)          │
│  SELL : EMA crosses BELOW VWAP Basis (Bar Close)          │
│                                                             │
│  EXIT/TP SIGNALS:                                          │
│  BUY TP : Price touches UPPER Band (IMMEDIATE)            │
│  SELL TP: Price touches LOWER Band (IMMEDIATE)            │
├─────────────────────────────────────────────────────────────┤
│  RECOMMENDED SETTINGS:                                     │
│  Multiplier: 3.5  │  EMA Length: 1                        │
│  Source: open      │  Event: Trend Change                  │
│  Start At First Bar: ✓  │  All Alerts: ✓                  │
├─────────────────────────────────────────────────────────────┤
│  ALERT MESSAGES:                                           │
│  🟢 "EMA crossed above VWAP Basis! Buy signal"            │
│  🔴 "EMA crossed below VWAP Basis! Sell signal"           │
│  🟢 "Price touched VWAP Upper Band! BUY TP signal"        │
│  🔴 "Price touched VWAP Lower Band! SELL TP signal"       │
└─────────────────────────────────────────────────────────────┘
🎯 Final Notes
This enhanced indicator provides traders with:

Clear entry signals through EMA crossovers

Real-time profit targets through TP signals

Multiple alert options for automated monitoring

Customizable settings for different trading styles

Professional-grade code based on LuxAlgo's framework

Disclaimer: This indicator is for educational and informational purposes only. Always conduct your own research, practice proper risk management, and test thoroughly before using in live trading. Past performance does not guarantee future results.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=6
indicator("VWAP Bands","VWAP Alerts",overlay=true)

// Original settings
start     = input.time(0,confirm=true)
from_bar0 = input(false,'Start At First Bar')
length    = input(14,group='VWAP')
mult      = input(2.,group='VWAP')
source    = input.string('close',
  options=['open','high','low','close','hl2','hlc3','ohlc4'],group='VWAP')
event = input.string('Periodic',
  options=['Periodic','Higher High','Lower Low','Trend Change','Start','External Cross','External Event'],
  group='Event')
ext_src = input.source(open,'External Cross/Event')

// --- EMA SETTINGS (Additional) ---
ema_length = input(9, title="EMA Length", group="EMA Settings")
ema_color = input(color.new(color.blue, 0), title="EMA Color", group="EMA Settings")
show_ema = input(true, title="Show EMA", group="EMA Settings")

// --- Signal Settings ---
alert_on = input(true, title="Enable Alerts", group="Alert Settings")

// Original variables
var t = 0
var csum_num = 0.
var csum_den = 0.
var var_num = 0.
var var_den = 0.

src = switch source
    'open'  => open
    'high'  => high
    'low'   => low
    'close' => close
    'hl2'   => hl2
    'hlc3'  => hlc3
    'ohlc4' => ohlc4

upper = ta.highest(length)
lower = ta.lowest(length)
os = math.round(ta.stoch(src,src,src,length)/100)

start_time = from_bar0 ? true : time >= start

event_condition = switch event
    'Periodic'       => t%length == 0
    'Higher High'    => upper > upper[1]
    'Lower Low'      => lower < lower[1]
    'Trend Change'   => os != os[1]
    'Start'          => false
    'External Cross' => ta.cross(src,ext_src)
    'External Event' => ext_src != 0

if start_time
    csum_num += src*volume
    csum_den += volume
    var_num += src*src*volume
    t += 1
    
    if event_condition
        csum_num := src*volume
        csum_den := volume
        var_num := src*src*volume

pvwap = csum_num/csum_den
dev = math.sqrt(var_num/csum_den - pvwap*pvwap)*mult      

// --- EMA Calculation (Additional) ---
ema_value = ta.ema(close, ema_length)

// --- Plots (Original) ---
up = plot(event_condition ? na : pvwap + dev,'Upper',color=#2157f3,style=plot.style_linebr)
plot(event_condition ? na : pvwap,'Basis',color=#ff5d00,style=plot.style_linebr)
dn = plot(event_condition ? na : pvwap - dev,'Lower',color=#ff1100,style=plot.style_linebr)
fill(up,dn,color=color.new(#2157f3,80))

// --- EMA Plot (Additional) ---
plot(show_ema ? ema_value : na, color=ema_color, linewidth=2, title="EMA Line")

// --- Signal Logic (Additional) ---
buy_signal = ta.crossover(ema_value, pvwap)  // EMA crosses above
sell_signal = ta.crossunder(ema_value, pvwap) // EMA crosses below

// --- Signal Indicators (Additional) ---
plotshape(buy_signal, title="Buy Signal", location=location.belowbar,
          color=color.new(color.green, 0), style=shape.labelup, 
          text="BUY", textcolor=color.white, size=size.small)

plotshape(sell_signal, title="Sell Signal", location=location.abovebar,
          color=color.new(color.red, 0), style=shape.labeldown,
          text="SELL", textcolor=color.white, size=size.small)

// --- Alert Conditions (Additional) - CORRECTED ---
alertcondition(buy_signal and alert_on, title="Buy Alert (EMA Crosses Above)", message="EMA crossed above VWAP Basis! Buy signal")
alertcondition(sell_signal and alert_on, title="Sell Alert (EMA Crosses Below)", message="EMA crossed below VWAP Basis! Sell signal")

// --- Alert Status Indicator ---
plotchar(buy_signal, title="Buy Alert Trigger", location=location.bottom, color=color.green, char="▲")
plotchar(sell_signal, title="Sell Alert Trigger", location=location.top, color=color.red, char="▼")
//=====================================================
// PERCENT TRAILING TAKE PROFIT
//=====================================================

// SETTINGS
useTrailingTP      = input.bool(true, "Enable Trailing TP", group="Trailing TP")
trailStartPercent  = input.float(2.0, "Activation Profit %", step=0.1, group="Trailing TP")
trailPercent       = input.float(1.0, "Trailing Distance %", step=0.1, group="Trailing TP")
showTPLabels       = input.bool(true, "Show TP Labels", group="Trailing TP")

// VARIABLES
var bool longTrade = false
var bool shortTrade = false

var float longEntry = na
var float shortEntry = na

var float highestSinceEntry = na
var float lowestSinceEntry = na

longTP = false
shortTP = false

//==========================
// BUY ENTRY
//==========================
if buy_signal
    longTrade := true
    shortTrade := false

    longEntry := close
    highestSinceEntry := high
    lowestSinceEntry := na

//==========================
// SELL ENTRY
//==========================
if sell_signal
    shortTrade := true
    longTrade := false

    shortEntry := close
    lowestSinceEntry := low
    highestSinceEntry := na

//==========================
// LONG TRAILING TP
//==========================
if useTrailingTP and longTrade

    highestSinceEntry := math.max(highestSinceEntry, high)

    profitPercent =
         (highestSinceEntry - longEntry) / longEntry * 100

    trailPrice =
         highestSinceEntry * (1 - trailPercent / 100)

    longTP :=
         profitPercent >= trailStartPercent and close <= trailPrice

    if longTP
        longTrade := false

//==========================
// SHORT TRAILING TP
//==========================
if useTrailingTP and shortTrade

    lowestSinceEntry := math.min(lowestSinceEntry, low)

    profitPercent =
         (shortEntry - lowestSinceEntry) / shortEntry * 100

    trailPrice =
         lowestSinceEntry * (1 + trailPercent / 100)

    shortTP :=
         profitPercent >= trailStartPercent and close >= trailPrice

    if shortTP
        shortTrade := false

//==========================
// TP LABELS
//==========================
plotshape(showTPLabels and longTP,
     title="Long Trailing TP",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.lime,
     text="TP",
     textcolor=color.black,
     size=size.small)

plotshape(showTPLabels and shortTP,
     title="Short Trailing TP",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.orange,
     text="TP",
     textcolor=color.white,
     size=size.small)

//==========================
// ALERTS
//==========================
alertcondition(longTP,
     title="Long Trailing TP",
     message="LONG Trailing Take Profit")

alertcondition(shortTP,
     title="Short Trailing TP",
     message="SHORT Trailing Take Profit")
````
