# BB HH LL ALERT By KEROL

- url: https://www.tradingview.com/script/XxwMLq6L-BB-HH-LL-ALERT-By-KEROL/
- type: indicator
- pine_id: PUB;79ad0fbb49894ab19756be50768a8c92
- version: 1.0

## Description

# BB HH LL ALERT

Smart Money market structure indicator with Bollinger Band confirmation for XAUUSD.

## Features

* Detect Higher High (HH)
* Detect Higher Low (HL)
* Detect Lower High (LH)
* Detect Lower Low (LL)
* Bollinger Band touch confirmation
* Alert only on M15 timeframe
* 3 bip alert notification
* Clean dark green & grey theme
* Reversal scalp setup for gold

## Signal Rules

### Upper Bollinger Band

* HH appears only when touching or above upper BB
* LH appears only when touching or above upper BB

### Lower Bollinger Band

* HL appears only when touching or below lower BB
* LL appears only when touching or below lower BB

## Colour Theme

* Dark Green = Bullish
* Grey = Bearish

## Best Usage

* XAUUSD
* M15 timeframe
* London Session
* New York Session

## Recommended Setup

* BB Length: 20
* BB Std Dev: 2
* Pivot Length: 5

## Alert

* Alert triggers only on M15
* 3 bip notification when signal appears

## Best Confirmation

Combine with:

* M15 Order Block
* M15 FVG
* Liquidity Sweep
* EMA 50 trend direction

## Trading Style

* Smart Money Concept (SMC)
* ICT Reversal
* Gold Scalping
* Intraday Trading

## Source Code

````pine
//@version=6
indicator("BB HH LL ALERT", overlay=true,
 max_labels_count=500)

//=====================================================
// SETTINGS
//=====================================================

groupBB = "BOLLINGER BAND"

bbLength = input.int(20, "BB Length", minval=1, group=groupBB)
bbStd = input.float(2.0, "BB Std Dev", step=0.1, group=groupBB)

groupStructure = "MARKET STRUCTURE"

pivotLength = input.int(5, "Pivot Length", minval=1, maxval=20, group=groupStructure)

//=====================================================
// BOLLINGER BAND
//=====================================================

basis = ta.sma(close, bbLength)

dev = ta.stdev(close, bbLength) * bbStd

upperBB = basis + dev
lowerBB = basis - dev

plot(upperBB,
 color=color.rgb(120,120,120),
 linewidth=1)

plot(lowerBB,
 color=color.rgb(0,100,60),
 linewidth=1)

//=====================================================
// PIVOT
//=====================================================

ph = ta.pivothigh(high, pivotLength, pivotLength)
pl = ta.pivotlow(low, pivotLength, pivotLength)

//=====================================================
// STORAGE
//=====================================================

var float prevHigh = na
var float prevLow = na

//=====================================================
// ALERT SOUND FUNCTION
//=====================================================

alertMessage = "BB Structure Touch"

//=====================================================
// HIGH STRUCTURE
//=====================================================

if not na(ph)

    bbHigh = upperBB[pivotLength]

    // TOUCH OR ABOVE UPPER BB
    if ph >= bbHigh

        // Higher High
        if not na(prevHigh) and ph > prevHigh

            label.new(
             x=bar_index - pivotLength,
             y=ph,
             text="⬆",
             style=label.style_circle,
             color=color.rgb(0,100,60),
             textcolor=color.white,
             size=size.small)

            // 3 ALERTS
            alert(alertMessage + " HH", alert.freq_once_per_bar)
            alert(alertMessage + " HH", alert.freq_once_per_bar)
            alert(alertMessage + " HH", alert.freq_once_per_bar)

        // Lower High
        if not na(prevHigh) and ph < prevHigh

            label.new(
             x=bar_index - pivotLength,
             y=ph,
             text="↘",
             style=label.style_circle,
             color=color.rgb(120,120,120),
             textcolor=color.white,
             size=size.small)

            // 3 ALERTS
            alert(alertMessage + " LH", alert.freq_once_per_bar)
            alert(alertMessage + " LH", alert.freq_once_per_bar)
            alert(alertMessage + " LH", alert.freq_once_per_bar)

    prevHigh := ph

//=====================================================
// LOW STRUCTURE
//=====================================================

if not na(pl)

    bbLow = lowerBB[pivotLength]

    // TOUCH OR BELOW LOWER BB
    if pl <= bbLow

        // Higher Low
        if not na(prevLow) and pl > prevLow

            label.new(
             x=bar_index - pivotLength,
             y=pl,
             text="↗",
             style=label.style_circle,
             color=color.rgb(0,120,70),
             textcolor=color.white,
             size=size.small)

            // 3 ALERTS
            alert(alertMessage + " HL", alert.freq_once_per_bar)
            alert(alertMessage + " HL", alert.freq_once_per_bar)
            alert(alertMessage + " HL", alert.freq_once_per_bar)

        // Lower Low
        if not na(prevLow) and pl < prevLow

            label.new(
             x=bar_index - pivotLength,
             y=pl,
             text="⬇",
             style=label.style_circle,
             color=color.rgb(150,150,150),
             textcolor=color.white,
             size=size.small)

            // 3 ALERTS
            alert(alertMessage + " LL", alert.freq_once_per_bar)
            alert(alertMessage + " LL", alert.freq_once_per_bar)
            alert(alertMessage + " LL", alert.freq_once_per_bar)

    prevLow := pl
````
