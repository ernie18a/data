# ATR Trailing SL From Entry Time

- url: https://www.tradingview.com/script/rpYRtutw-ATR-Trailing-SL-From-Entry-Time/
- type: indicator
- pine_id: PUB;fdd2306464804b6e98b42b42a1371d48
- version: 1.0

## Description

# ATR Trailing SL From Entry Time 

## Overview

ATR Trailing SL From Entry Time is a simple and practical trade management indicator that helps traders monitor a dynamic ATR-based stop-loss after entering a trade.

Instead of manually adjusting stop-loss levels as volatility changes, the indicator automatically recalculates the stop-loss on every candle using the Average True Range (ATR).

Simply select your trade direction, choose the entry candle using the Entry Time input, and the indicator will continuously update the ATR stop-loss level while monitoring the position.

When price reaches the ATR stop-loss level, the indicator generates a visual chart label and alert notification.

This tool is designed for trade management, stop-loss monitoring, and risk control.

---

## Key Features

### Dynamic ATR Stop Loss

The stop-loss is recalculated on every candle using current market volatility.

**Long Position**

ATR Stop = Close - (ATR × Multiplier)

**Short Position**

ATR Stop = Close + (ATR × Multiplier)

This allows the stop-loss to automatically adapt to changing market conditions.

---

### Entry Time Selection

Instead of manually entering a price, users simply select the candle where the trade was entered using the Entry Time input.

The indicator automatically captures the entry candle and begins monitoring the position from that point forward.

---

### Long & Short Support

Works with both:

• Long Positions
• Short Positions

Simply select the desired direction from the settings panel.

---

### Visual Entry Line

A horizontal entry line is plotted on the chart, making it easy to identify the original trade entry level.

---

### Dynamic ATR Stop Line

The ATR stop-loss line is plotted directly on the chart and updates automatically with every new candle.

This provides a clear visual representation of the current stop-loss level.

---

### One-Time Alert System

When price reaches the ATR stop-loss level:

• A visual chart label appears
• An alert condition becomes true
• The alert triggers only once for the active setup

This prevents repeated notifications after the stop-loss has already been hit.

---

## Inputs

### ATR Length

Determines the ATR calculation period.

Common values:

• 14 (Default)
• 21
• 50

Lower values react faster to volatility changes.

Higher values produce smoother stop-loss levels.

---

### ATR Multiplier

Controls the distance between price and stop-loss.

Examples:

• 1.0 ATR
• 1.5 ATR
• 2.0 ATR
• 3.0 ATR

Higher multipliers create wider stop-loss levels.

Lower multipliers create tighter stop-loss levels.

---

### Direction

Select trade direction:

• Long
• Short

---

### Entry Time

Choose the candle where the trade was entered.

The indicator will automatically begin monitoring the position from that candle onward.

---

### Show Entry Line

Enable or disable the entry price visualization.

---

### Show ATR SL Line

Enable or disable the ATR stop-loss visualization.

---

## How To Use

### Long Trade Example

Step 1

Add the indicator to your chart.

Step 2

Open indicator settings.

Step 3

Select:

Direction = Long

Step 4

Choose the Entry Time corresponding to your trade entry candle.

Step 5

Configure ATR settings.

Example:

ATR Length = 14

ATR Multiplier = 2

Step 6

The indicator will automatically:

• Detect the entry candle
• Plot the entry level
• Plot the ATR stop-loss level
• Update the stop-loss every candle

Step 7

Monitor the trade and wait for either:

• Trade management decisions
• Stop-loss trigger notification

---

### Short Trade Example

Step 1

Select:

Direction = Short

Step 2

Choose your Entry Time.

Step 3

Adjust ATR settings if desired.

The ATR stop-loss line will now be calculated above price and updated continuously.

---

## Alert Setup Guide

### Creating Alerts

1. Add the indicator to your chart.

2. Click the TradingView "Create Alert" button.

3. Under Condition select:

ATR Trailing SL From Entry Time

4. Choose one of the following alert conditions:

• Long ATR SL Hit

or

• Short ATR SL Hit

5. Select your preferred notification method:

• App Notification
• Popup Notification
• Email Notification
• Webhook Notification

6. Click Create.

The alert will trigger automatically when the ATR stop-loss level is reached.

---

## Logic Explanation

### Long Position Logic

ATR Stop = Close - (ATR × Multiplier)

If:

Low <= ATR Stop

The stop-loss event is triggered.

---

### Short Position Logic

ATR Stop = Close + (ATR × Multiplier)

If:

High >= ATR Stop

The stop-loss event is triggered.

---

## Best Use Cases

This indicator can be used for:

• Swing Trading
• Day Trading
• Scalping
• Trend Following Strategies
• Futures Trading
• Forex Trading
• Cryptocurrency Trading
• Stock Trading

---

## Important Notes

• This indicator is a trade management tool and not an entry signal generator.

• ATR values change with market volatility, therefore stop-loss levels will continuously update.

• Always combine ATR-based stop-loss management with proper position sizing and risk management.

• No indicator can guarantee profits or eliminate trading risk.

---

## Open-Source Notice

This script is published as Open Source for educational and research purposes.

Feel free to study, modify, improve, and adapt the code to fit your own trading style and risk management requirements.

If you find this indicator useful, consider leaving a like, sharing feedback, and supporting future development.

Happy Trading and Trade Safe!

## Source Code

````pine
//@version=6
indicator("ATR Trailing SL From Entry Time", overlay=true, max_labels_count=500)

//=========================
// INPUTS
//=========================
atrLen      = input.int(14, "ATR Length", minval=1)
atrMult     = input.float(2.0, "ATR Multiplier", step=0.1)

direction   = input.string("Long", "Direction", options=["Long", "Short"])

// Entry candle select karo
entryTime   = input.time(timestamp("01 Jan 2026 09:15 +0530"), "Entry Time")

showEntry   = input.bool(true, "Show Entry Line")
showSL      = input.bool(true, "Show ATR SL Line")

//=========================
// ATR
//=========================
atr = ta.atr(atrLen)

//=========================
// ENTRY DETECTION
//=========================
var float entryPrice = na
var bool entryFound = false

if not entryFound and time >= entryTime
    entryPrice := close
    entryFound := true

//=========================
// ATR SL
//=========================
float trailSL = na

if entryFound
    if direction == "Long"
        trailSL := close - atr * atrMult
    else
        trailSL := close + atr * atrMult

//=========================
// ONE-TIME ALERT
//=========================
var bool slTriggered = false

longHit =
     entryFound and
     not slTriggered and
     direction == "Long" and
     low <= trailSL

shortHit =
     entryFound and
     not slTriggered and
     direction == "Short" and
     high >= trailSL

if longHit or shortHit
    slTriggered := true

//=========================
// PLOTS
//=========================
plot(
     showEntry and entryFound ? entryPrice : na,
     "Entry",
     color=color.yellow,
     linewidth=2)

plot(
     showSL and entryFound ? trailSL : na,
     "ATR SL",
     color=direction == "Long" ? color.lime : color.red,
     linewidth=3,
     style=plot.style_linebr)

// Entry marker
plotshape(
     entryFound and time == entryTime,
     title="Entry",
     style=shape.circle,
     location=location.absolute,
     color=color.yellow,
     size=size.small)

//=========================
// HIT LABELS
//=========================
plotshape(
     longHit,
     title="Long SL Hit",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="LONG SL HIT",
     textcolor=color.white)

plotshape(
     shortHit,
     title="Short SL Hit",
     style=shape.labelup,
     location=location.belowbar,
     color=color.red,
     text="SHORT SL HIT",
     textcolor=color.white)

//=========================
// ALERTS
//=========================
alertcondition(
     longHit,
     title="Long ATR SL Hit",
     message="LONG ATR TRAILING SL HIT")

alertcondition(
     shortHit,
     title="Short ATR SL Hit",
     message="SHORT ATR TRAILING SL HIT")

//=========================
// INFO TABLE
//=========================
var table t = table.new(position.top_right, 2, 5, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "Direction")
    table.cell(t, 1, 0, direction)

    table.cell(t, 0, 1, "Entry")
    table.cell(t, 1, 1, str.tostring(entryPrice))

    table.cell(t, 0, 2, "ATR SL")
    table.cell(t, 1, 2, str.tostring(trailSL))

    table.cell(t, 0, 3, "ATR")
    table.cell(t, 1, 3, str.tostring(atr))

    table.cell(t, 0, 4, "Status")
    table.cell(t, 1, 4, slTriggered ? "SL HIT" : "ACTIVE")
````
