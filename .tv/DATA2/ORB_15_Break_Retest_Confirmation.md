<!-- tradingview-pine-id: PUB;27c511b26a694f8aacab6ee5c6f2104f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ORB 15 Break + Retest Confirmation

Source: https://www.tradingview.com/script/gJlFeYpq-ORB-15-Break-Retest-Confirmation/

## Description

This indicator is designed for use on a 5-minute chart and identifies a specific Opening Range Breakout setup using the first 15 minutes of the regular trading session.

It automatically calculates the ORB 15 High (15H) and ORB 15 Low (15L) from the 9:30 AM to 9:45 AM New York session. Once those levels are established, the script waits for a valid breakout.

A bullish setup begins only when a completed 5-minute candle closes above ORB 15H. After the breakout, the indicator waits for price to return and retest the 15H level. If price touches or slightly penetrates the level and the 5-minute candle closes back above it, the script generates a LONG confirmation.

A bearish setup works the same way in reverse. A completed 5-minute candle must first close below ORB 15L. The script then waits for price to retest the 15L level from below. If price touches or slightly crosses the level and the candle closes back below it, the script generates a SHORT confirmation.

The script uses a sequential state-based approach, so a retest signal cannot occur unless a valid breakout happened first. Wick-only breakouts are ignored, and signals are evaluated only on completed 5-minute candles.

The indicator also includes a configurable retest tolerance and a maximum number of bars allowed for the retest to occur. If the breakout fails or the retest does not happen within the defined window, the setup is reset.

This tool is intended to help identify structured breakout → retest → confirmation setups around the 15-minute opening range.

Disclaimer: This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. Signals may be inaccurate, delayed, or fail under certain market conditions. Always perform your own analysis, use appropriate risk management, and trade at your own risk. The author is not responsible for any losses resulting from the use of this script.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © strangemail2000

//@version=6
indicator("ORB 15 Break + Retest Confirmation", overlay=true)

// =====================================================
// SETTINGS
// =====================================================

retestTolerance = input.float(0.10, "Retest tolerance", step=0.01)
maxRetestBars   = input.int(20, "Maximum bars for retest", minval=1)

// =====================================================
// SESSION
// First 15 minutes: 9:30 AM - 9:45 AM New York time
// =====================================================

newDay = timeframe.change("D")

inORB = not na(time(timeframe.period, "0930-0945", "America/New_York"))

var float orbHigh = na
var float orbLow  = na
var bool orbReady = false

if newDay
    orbHigh := na
    orbLow := na
    orbReady := false

// Build ORB during first 15 minutes
if inORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow) ? low : math.min(orbLow, low)

// Once 9:45 passes, lock the ORB
if not inORB and inORB[1]
    orbReady := true

// =====================================================
// STATE
// 0 = waiting
// 1 = bullish breakout happened
// -1 = bearish breakout happened
// =====================================================

var int state = 0
var int breakoutBar = na

if newDay
    state := 0
    breakoutBar := na

// =====================================================
// BREAKOUT
// Must be a completed 5m candle CLOSE beyond ORB
// =====================================================

bullBreak =
     orbReady and
     state == 0 and
     close > orbHigh and
     close[1] <= orbHigh

bearBreak =
     orbReady and
     state == 0 and
     close < orbLow and
     close[1] >= orbLow

if barstate.isconfirmed
    if bullBreak
        state := 1
        breakoutBar := bar_index

    else if bearBreak
        state := -1
        breakoutBar := bar_index

// =====================================================
// RETEST
// Retest must happen AFTER breakout candle
// =====================================================

bullTouch =
     state == 1 and
     bar_index > breakoutBar and
     low <= orbHigh + retestTolerance

bullConfirmation =
     barstate.isconfirmed and
     bullTouch and
     close > orbHigh

bearTouch =
     state == -1 and
     bar_index > breakoutBar and
     high >= orbLow - retestTolerance

bearConfirmation =
     barstate.isconfirmed and
     bearTouch and
     close < orbLow

// =====================================================
// INVALIDATION
// =====================================================

// Bull breakout failed if candle closes back below ORB
bullFailed =
     state == 1 and
     close < orbHigh

// Bear breakout failed if candle closes back above ORB
bearFailed =
     state == -1 and
     close > orbLow

expired =
     state != 0 and
     not na(breakoutBar) and
     bar_index - breakoutBar > maxRetestBars

// =====================================================
// RESET AFTER CONFIRMATION
// =====================================================

if bullConfirmation
    state := 0
    breakoutBar := na

if bearConfirmation
    state := 0
    breakoutBar := na

if bullFailed or bearFailed or expired
    state := 0
    breakoutBar := na

// =====================================================
// PLOTS
// =====================================================

plot(
     orbHigh,
     "ORB 15H",
     color=color.purple,
     linewidth=1,
     style=plot.style_linebr
)

plot(
     orbLow,
     "ORB 15L",
     color=color.purple,
     linewidth=1,
     style=plot.style_linebr
)

// =====================================================
// CONFIRMATION LABELS
// =====================================================

plotshape(
     bullConfirmation,
     title="Long Confirmation",
     style=shape.labelup,
     location=location.belowbar,
     text="LONG",
     color=color.green,
     textcolor=color.white,
     size=size.small
)

plotshape(
     bearConfirmation,
     title="Short Confirmation",
     style=shape.labeldown,
     location=location.abovebar,
     text="SHORT",
     color=color.red,
     textcolor=color.white,
     size=size.small
)

// =====================================================
// ALERTS
// =====================================================

alertcondition(
     bullConfirmation,
     title="ORB 15H Long Confirmed",
     message="ORB 15H breakout and retest confirmed"
)

alertcondition(
     bearConfirmation,
     title="ORB 15L Short Confirmed",
     message="ORB 15L breakout and retest confirmed"
)
````
