<!-- tradingview-pine-id: PUB;7fcb65294c864cc991a8b95011282424 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Sweep Hunter [JPT] 

Source: https://www.tradingview.com/script/lSNp9pMR-Liquidity-Sweep-Hunter-JPT/

## Description

🔷 OVERVIEW

Liquidity Sweep Hunter [JPT] is an original Pine Script® v6 indicator designed to automatically detect key liquidity levels and identify Buy-Side and Sell-Side Liquidity Sweeps. The indicator plots significant swing highs and lows as liquidity zones, helping traders spot potential institutional stop hunts and market reversals without manually marking levels.

Suitable for Forex, Gold (XAUUSD), Silver (XAGUSD), Cryptocurrency, Stocks, Indices, Futures, and Commodities, the indicator provides a simple and clean Smart Money Concepts (SMC) workflow.

🔷 HOW IT WORKS

The indicator continuously scans price using confirmed pivot highs and pivot lows.

Buy-Side Liquidity (BSL)

When a confirmed Swing High is detected, the indicator plots a horizontal liquidity level representing Buy-Side Liquidity.

These levels often become areas where resting buy-stop orders accumulate.

Sell-Side Liquidity (SSL)

When a confirmed Swing Low is detected, the indicator plots a horizontal liquidity level representing Sell-Side Liquidity.

These zones commonly contain sell-stop liquidity below recent lows.

Liquidity Sweep Detection

The indicator automatically monitors price interaction with the latest liquidity levels.

Bearish Liquidity Sweep

A bearish sweep occurs when:

• Price trades above the previous Buy-Side Liquidity (Swing High)

• The candle closes back below the liquidity level

This may indicate a liquidity grab before a potential bearish move.

Bullish Liquidity Sweep

A bullish sweep occurs when:

• Price trades below the previous Sell-Side Liquidity (Swing Low)

• The candle closes back above the liquidity level

This may indicate a stop hunt before a potential bullish reversal.

🔷 VISUAL FEATURES

• Automatic Swing High Detection

• Automatic Swing Low Detection

• Buy-Side Liquidity (BSL) Levels

• Sell-Side Liquidity (SSL) Levels

• Dashed Liquidity Lines

• BSL Labels

• SSL Labels

• Bullish Liquidity Sweep Detection

• Bearish Liquidity Sweep Detection

• Optional EMA Trend Filter

• Clean and Lightweight Chart Display

🔷 INPUTS

Available settings include:

• Pivot Length

• EMA Length

• Show EMA

• Show Liquidity Lines

These settings allow traders to adjust swing sensitivity and customize the chart appearance.

🔷 HOW TO USE

A common workflow is:

Wait for the indicator to identify Buy-Side or Sell-Side Liquidity.
Watch for price to sweep one of these liquidity levels.
Look for additional confirmation using price action or market structure.
Use the sweep as a potential indication of a continuation or reversal, depending on your trading plan.
🔷 MARKETS

Liquidity Sweep Hunter [JPT] can be used on:

• Forex

• Gold (XAUUSD)

• Silver (XAGUSD)

• Cryptocurrency

• Stocks

• Indices

• Futures

• Commodities

Compatible with all TradingView-supported timeframes.

🔷 BEST PRACTICES

Many traders combine liquidity sweeps with:

• Market Structure (HH, HL, LH, LL)

• Break of Structure (BOS)

• Change of Character (CHoCH)

• Order Blocks

• Fair Value Gaps (FVG)

• Support & Resistance

• EMA Trend Confirmation

• Higher Timeframe Analysis

Using multiple confirmations can provide additional context when evaluating liquidity events.

🔷 UPCOMING FEATURES

Future updates may include:

• Equal High / Equal Low Detection

• Liquidity Sweep Labels

• Multi-Timeframe Liquidity Levels

• Order Block Detection

• Fair Value Gap (FVG) Integration

• BOS & CHoCH Confirmation

• Trend Dashboard

• Smart Money Alerts

• ATR-Based Liquidity Filter

• Advanced Notification System

🔷 DISCLAIMER

This indicator is provided for educational and informational purposes only. It identifies confirmed liquidity levels and potential liquidity sweeps based on historical price action. It does not predict future market movements or guarantee trading results. Always perform your own analysis, apply sound risk management, and consider additional market factors before making trading decisions.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Liquidity Sweep Hunter [JPT] ", overlay=true, max_lines_count=200, max_labels_count=200)

//====================
// Inputs
//====================
pivotLen = input.int(5, "Pivot Length", minval=2)
emaLen   = input.int(200, "EMA Length")
showEMA  = input.bool(true, "Show EMA")
showLines= input.bool(true, "Show Liquidity Lines")

//====================
// Pivot High / Low
//====================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float lastLow = na

if not na(ph)
    lastHigh := ph
    if showLines
        line.new(bar_index-pivotLen, ph, bar_index+50, ph,
             color=color.red, style=line.style_dashed)

if not na(pl)
    lastLow := pl
    if showLines
        line.new(bar_index-pivotLen, pl, bar_index+50, pl,
             color=color.lime, style=line.style_dashed)

//====================
// Liquidity Sweeps
//====================

// Sweep above previous high then close below
bearSweep =
     not na(lastHigh) and
     high > lastHigh and
     close < lastHigh

// Sweep below previous low then close above
bullSweep =
     not na(lastLow) and
     low < lastLow and
     close > lastLow

    //====================
// Liquidity High / Low Detection
//====================

ph2 = ta.pivothigh(high, pivotLen, pivotLen)
pl2 = ta.pivotlow(low, pivotLen, pivotLen)

var float liquidityHigh = na
var float liquidityLow = na

if not na(ph)
    lastHigh := ph

    if showLines
        line.new(
             bar_index - pivotLen,
             ph,
             bar_index + 100,
             ph,
             extend=extend.none,
             color=color.red,
             width=1,
             style=line.style_dashed)

        label.new(
             bar_index - pivotLen,
             ph,
             "BSL",
             style=label.style_label_down,
             color=color.red,
             textcolor=color.white,
             size=size.tiny)

if not na(pl)
    lastLow := pl

    if showLines
        line.new(
             bar_index - pivotLen,
             pl,
             bar_index + 100,
             pl,
             extend=extend.none,
             color=color.lime,
             width=1,
             style=line.style_dashed)

        label.new(
             bar_index - pivotLen,
             pl,
             "SSL",
             style=label.style_label_up,
             color=color.lime,
             textcolor=color.white,
             size=size.tiny)
````
