# Market Strategies  Protected Structure CHOCH

- url: https://www.tradingview.com/script/XFJwPmQ3-Market-Strategies-Protected-Structure-CHOCH/
- type: indicator
- pine_id: PUB;8c15154a0d5442e98692323be65155fe
- version: 1.0

## Description

Market Strategies – Protected Structure CHOCH is a lightweight market structure and Change of Character (CHoCH) indicator designed to visualize protected bullish and bearish structure levels in real time.

This script focuses specifically on structural control shifts and protected auction levels rather than attempting to combine multiple Smart Money Concepts tools into a single indicator. The purpose of this script is to help traders clearly identify:

* bullish structure,
* bearish structure,
* CHoCH transitions,
* protected highs and lows,
* and directional auction control.

This indicator is designed to work alongside the larger “Market Strategies – Smart Money Concepts” framework and serves as a simplified structure engine that can be used independently or as confirmation for broader order flow and liquidity-based analysis.

━━━━━━━━━━━━━━━━━━
CORE CONCEPT
━━━━━━━━━━━━━━━━━━

The script continuously tracks confirmed swing highs and swing lows using pivot-based structure calculations.

From those pivots, the indicator builds:

* protected bullish structure levels,
* protected bearish structure levels,
* and directional trend state.

The green structure line represents protected bullish structure.
The red structure line represents protected bearish structure.

These lines act as dynamic structural control zones that evolve as the auction progresses.

As long as price continues accepting above protected bullish structure, bullish continuation probabilities remain stronger.

As long as price continues accepting below protected bearish structure, bearish continuation probabilities remain stronger.

━━━━━━━━━━━━━━━━━━
CHANGE OF CHARACTER (CHoCH)
━━━━━━━━━━━━━━━━━━

A Change of Character occurs when the current market structure loses directional control.

Bullish CHoCH:

* occurs when bearish structure fails and price closes above the most recent protected swing high.

Bearish CHoCH:

* occurs when bullish structure fails and price closes below the most recent protected swing low.

The script confirms CHoCH only on candle close in order to reduce false signals and intrabar repainting behavior.

This allows traders to identify:

* possible trend reversals,
* auction transitions,
* failed continuation conditions,
* and potential momentum shifts.

━━━━━━━━━━━━━━━━━━
PROTECTED STRUCTURE LEVELS
━━━━━━━━━━━━━━━━━━

The protected structure lines are one of the primary features of this script.

These levels represent areas where buyers or sellers are currently defending directional control.

Green protected structure:

* represents bullish control.

Red protected structure:

* represents bearish control.

The script updates these levels dynamically as new structure forms.

These levels can be used similarly to dynamic support and resistance zones, but they are derived from confirmed market structure rather than static price levels.

━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━

This indicator is intended to be used as a structural framework and directional confirmation tool.

Common uses include:

* identifying bullish vs bearish market control,
* detecting CHoCH transitions,
* confirming continuation after pullbacks,
* identifying failed breakouts,
* monitoring structural acceptance,
* and tracking trend progression.

A common bullish sequence:
Bear Struct → Bull CHoCH → Bull Structure Continuation.

A common bearish sequence:
Bull Struct → Bear CHoCH → Bear Structure Continuation.

━━━━━━━━━━━━━━━━━━
BEST USE CASES
━━━━━━━━━━━━━━━━━━

This script works particularly well when combined with:

* the Market Strategies – Smart Money Concepts indicator,
* VWAP,
* order flow,
* CVD,
* delta,
* liquidity analysis,
* Bookmap heatmaps,
* and volume confirmation.

The protected structure levels can be used as dynamic decision zones where traders monitor:

* acceptance,
* rejection,
* continuation,
* absorption,
* or structural failure.

━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━

The script includes:

* Bullish CHoCH alerts,
* Bearish CHoCH alerts,
* and Any CHoCH alerts.

Alerts trigger only after candle close confirmation.

━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━

This indicator is designed to simplify market structure interpretation and directional bias analysis.

It does not attempt to predict future price movement and should be used alongside broader market context, liquidity behavior, and proper risk management.

## Source Code

````pine
//@version=5
indicator("Market Strategies – Protected Structure CHOCH", overlay=true, max_labels_count=500)

//────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────
swingLength  = input.int(5, "Swing Length", minval=1)
showLabels   = input.bool(true, "Show Structure Label")
showBubbles  = input.bool(true, "Show CHOCH Bubbles")
enableAlerts = input.bool(true, "Enable Alerts")

//────────────────────────────────────────────
// SWING HIGH / SWING LOW DETECTION
//────────────────────────────────────────────
swingHigh = high[swingLength] == ta.highest(high, swingLength * 2 + 1)
swingLow  = low[swingLength]  == ta.lowest(low, swingLength * 2 + 1)

confirmedSwingHigh = swingHigh ? high[swingLength] : na
confirmedSwingLow  = swingLow  ? low[swingLength]  : na

//────────────────────────────────────────────
// STORE MOST RECENT STRUCTURE LEVELS
//────────────────────────────────────────────
var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(confirmedSwingHigh)
    lastSwingHigh := confirmedSwingHigh

if not na(confirmedSwingLow)
    lastSwingLow := confirmedSwingLow

//────────────────────────────────────────────
// MARKET STRUCTURE TREND
// 1  = Bullish Structure
// -1 = Bearish Structure
// 0  = Neutral
//────────────────────────────────────────────
var int trend = 0

prevLastSwingHigh = lastSwingHigh[1]
prevLastSwingLow  = lastSwingLow[1]

if not na(prevLastSwingHigh) and close > prevLastSwingHigh
    trend := 1
else if not na(prevLastSwingLow) and close < prevLastSwingLow
    trend := -1
else
    trend := nz(trend[1], 0)

//────────────────────────────────────────────
// CHOCH LOGIC
//────────────────────────────────────────────
bullishCHOCH =
     trend[1] == -1 and
     not na(prevLastSwingHigh) and
     close > prevLastSwingHigh and
     barstate.isconfirmed

bearishCHOCH =
     trend[1] == 1 and
     not na(prevLastSwingLow) and
     close < prevLastSwingLow and
     barstate.isconfirmed

anyCHOCH = bullishCHOCH or bearishCHOCH

//────────────────────────────────────────────
// PLOT STRUCTURE LEVELS
//────────────────────────────────────────────
plot(lastSwingHigh, title="CHOCH High", color=color.green, linewidth=2, style=plot.style_linebr)
plot(lastSwingLow, title="CHOCH Low", color=color.red, linewidth=2, style=plot.style_linebr)

//────────────────────────────────────────────
// CHOCH BUBBLES
//────────────────────────────────────────────
if showBubbles and bullishCHOCH
    label.new(   bar_index,  low,   "Bull CHOCH",  style=label.style_label_up, textcolor=color.white,  color=color.green,   size=size.small)

if showBubbles and bearishCHOCH
    label.new(   bar_index,   high,   "Bear CHOCH",  style=label.style_label_down,  textcolor=color.white,  color=color.red,   size=size.small)

//────────────────────────────────────────────
// STRUCTURE LABEL
//────────────────────────────────────────────
var label structureLabel = na

if showLabels and barstate.islast
    label.delete(structureLabel)

    structureText =
         trend == 1 ? "Structure: Bullish" :
         trend == -1 ? "Structure: Bearish" :
         "Structure: Neutral"

    structureColor =
         trend == 1 ? color.green :
         trend == -1 ? color.red :
         color.gray

    structureLabel := label.new(  bar_index,  high,  structureText,   style=label.style_label_left,  textcolor=color.white,  color=structureColor,  size=size.normal)

//────────────────────────────────────────────
// ALERTS
//────────────────────────────────────────────
alertcondition( enableAlerts and bullishCHOCH, title="Bullish CHOCH",    message="Bullish CHOCH detected on {{ticker}} / {{interval}}")

alertcondition(  enableAlerts and bearishCHOCH,  title="Bearish CHOCH",   message="Bearish CHOCH detected on {{ticker}} / {{interval}}")

alertcondition(   enableAlerts and anyCHOCH,  title="Any CHOCH",  message="CHOCH detected on {{ticker}} / {{interval}}")
````
