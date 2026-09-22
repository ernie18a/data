<!-- tradingview-pine-id: PUB;6709a6607d7444b5b3c65230ea1f1367 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Price Action S/R Master - B R-B E

Source: https://www.tradingview.com/script/MmCnFomg-Price-Action-Support-and-resistance/

## Description

Short description

A clean daily price-action indicator that identifies support/resistance-based Buy, Re-Buy, and Exit signals using repeated S/R reactions, candle confirmation, breakout/retests, and adaptive 10-day-low protection.

Full TradingView description

Price Action S/R – Buy, Re-Buy & Exit is a price-action indicator designed primarily for daily-chart swing and positional trading.

The goal is to keep the chart visually simple while allowing the underlying logic to evaluate repeated support/resistance interactions, candle confirmation, breakout/retest setups, exits, and re-entry opportunities.

Signals

B — Buy

A Buy can occur when a sufficiently established support/resistance setup produces one of the supported bullish confirmations, including:

• Support rejection
• Bullish engulfing at support
• Support reclaim
• Resistance breakout followed by a successful retest

By default, a support/resistance level requires at least 3 touches before it becomes eligible for a signal.

R-B — Re-Buy

After an Exit, the indicator remembers the original setup level for a limited period. If price makes a fresh reclaim of that level with bullish confirmation, an R-B signal can be generated.

This is intended to identify situations where an earlier position was protected by the exit logic but the original bullish setup subsequently recovers.

E — Exit

The indicator uses two stages of downside protection.

Before a qualifying resistance warning occurs, the protective level is based on the lowest low of the previous 10 completed candles at the time of entry. This level remains frozen.

A qualifying resistance warning does not automatically create an Exit. Instead, it activates rolling previous-10-day-low protection.

After that transition, a daily close below the rolling previous 10-day low can generate an E signal.

Clean chart design

Only three markers are displayed:

B = Buy
R-B = Re-Buy
E = Exit

Additional calculations remain hidden to avoid filling the chart with support/resistance labels and warning markers.

Hovering over a signal provides additional context such as the setup type, support/resistance touch count, candle type, daily volume, RVOL20, and signal price.

Support and resistance

Support and resistance are treated as zones rather than exact prices. ATR is used to provide tolerance around detected pivot levels.

Nearby pivot reactions can contribute to an existing level, while a minimum separation between reactions helps reduce repeated counting of nearby candles as independent touches.

Candle confirmation

The indicator recognizes price-action confirmations including:

• Bullish rejection
• Bearish rejection
• Bullish engulfing
• Bearish engulfing
• Support reclaim
• Failed breakout
• Breakout and retest

Volume information

Signal tooltips include the day's volume and RVOL20, which compares current volume with the 20-day average volume.

Volume is currently informational only. It is not a mandatory condition for generating a Buy signal.

Recommended use

The indicator was designed primarily around the 1-day timeframe for swing and positional analysis.

It should be used as one component of a broader analysis process rather than as a standalone prediction system. Market conditions, company fundamentals, liquidity, earnings, gaps, and risk tolerance can materially affect results.

Historical signals do not guarantee future performance.

This script is provided for educational and technical-analysis purposes only and is not financial advice.

Suggested TradingView tags

Use tags/categories around:

Support and Resistance, Price Action, Swing Trading, Breakout, Reversal, Volume, Relative Volume

Author's note

You can add this at the bottom:

Version 1.0

This is the first public release. The emphasis is intentionally on chart simplicity: B, R-B and E are displayed while the supporting calculations operate internally.

Future versions may refine support/resistance detection, confirmation quality, volume analysis and risk management based on testing and community feedback.

Code

Use the exact locked script we just finalized — the version titled:

Price Action S/R Master - B R-B E

I would only change its public-facing title:

//@version=6
indicator(
     "Price Action S/R - Buy, Re-Buy & Exit [V1.0]",
     overlay=true,
     max_labels_count=500)

Everything below that can remain exactly as in the locked version. Do not change the calculations before publishing V1.0.

What I would choose when publishing

For visibility, publish it as an open-source indicator if you're comfortable letting others inspect/copy the Pine code. If you want people to use it but don't want the source openly available, TradingView's available publication/access choices should be reviewed at publishing time.

For the chart screenshot, use a clean 1D chart showing at least one B → E → R-B sequence if you can find a good historical example. Keep the screenshot free of unrelated indicators so people immediately understand what your script does.

And don't market it with claims like “90% accurate,” “guaranteed profits,” “best buy/sell indicator,” etc. The strength of this script is that the rules can be explained transparently.

Before you click Publish

I would use this final package:

Title: Price Action S/R – Buy, Re-Buy & Exit [V1.0]

Visibility on chart: B / R-B / E

Timeframe: 1D primarily

Description: Use the full description above.

Screenshot: Clean daily chart demonstrating the signals.

Version: 1.0

Source: Open-source if you want this to be genuinely community-shared.

Disclaimer: Educational/technical-analysis purposes; not financial advice.

---

## Source Code

````pine
//@version=6
indicator(
     "Price Action S/R Master - B R-B E",
     overlay=true,
     max_labels_count=500)

//====================================================================
// PRICE ACTION S/R MASTER
//
// DISPLAY:
//   B   = Normal Buy
//   R-B = Re-Buy
//   E   = Exit
//
// BUY:
//   S3+ Rejection
//   S3+ Engulfing
//   S3+ Reclaim
//   R3+ Breakout & Retest
//
// EXIT:
//   Before R3:
//      Frozen previous 10-day low from entry.
//
//   After R3:
//      R3 warning itself DOES NOT exit.
//      It activates rolling previous 10-day-low protection.
//
// RE-BUY:
//   After exit, remember original setup.
//   Reclaim setup level + bullish confirmation = R-B.
//
// HOVER:
//   B/R-B/E labels contain detailed tooltips.
//
// NO MOVING AVERAGES.
// NO SHORTS.
//====================================================================


//====================================================================
// 1. INPUTS
//====================================================================

pivotLen = input.int(
     5,
     "Pivot Strength",
     minval=2)

zoneATR = input.float(
     0.35,
     "S/R Zone Width ATR",
     minval=0.05,
     step=0.05)

signalTouches = input.int(
     3,
     "Minimum Touches For Signal",
     minval=2)

rejectionRatio = input.float(
     1.5,
     "Rejection Wick / Body",
     minval=0.5,
     step=0.1)

retestBars = input.int(
     5,
     "Maximum B&R Retest Bars",
     minval=1,
     maxval=10)

touchSeparation = input.int(
     5,
     "Minimum Bars Between Touches",
     minval=2)

signalCooldown = input.int(
     3,
     "Signal Cooldown",
     minval=1)

exitLookback = input.int(
     10,
     "Exit Lookback",
     minval=2)

reentryBars = input.int(
     20,
     "Maximum Bars For Re-Buy",
     minval=3,
     maxval=60)

reentryBufferATR = input.float(
     0.10,
     "Re-Buy Buffer ATR",
     minval=0.0,
     step=0.05)

showExitLevel = input.bool(
     false,
     "Show Active Exit Level")

showReentryLevel = input.bool(
     false,
     "Show Re-Buy Level")


//====================================================================
// 2. ATR / S-R ZONE
//====================================================================

atr = ta.atr(14)

zone = atr * zoneATR


//====================================================================
// 3. VOLUME
//====================================================================

avgVolume20 = ta.sma(volume, 20)

rvol20 =
     not na(avgVolume20) and
     avgVolume20 > 0
     ? volume / avgVolume20
     : na


//====================================================================
// 4. CANDLE STRUCTURE
//====================================================================

body =
     math.abs(close - open)

safeBody =
     math.max(
         body,
         syminfo.mintick)

upperWick =
     high - math.max(open, close)

lowerWick =
     math.min(open, close) - low

bullish =
     close > open

bearish =
     close < open


//====================================================================
// 5. BULLISH REJECTION
//====================================================================

bullReject =
     bullish and
     lowerWick >= safeBody * rejectionRatio and
     lowerWick > upperWick


//====================================================================
// 6. BEARISH REJECTION
//====================================================================

bearReject =
     bearish and
     upperWick >= safeBody * rejectionRatio and
     upperWick > lowerWick


//====================================================================
// 7. BULLISH ENGULFING
//====================================================================

bullEngulf =
     bullish and
     close[1] < open[1] and
     open <= close[1] and
     close >= open[1]


//====================================================================
// 8. BEARISH ENGULFING
//====================================================================

bearEngulf =
     bearish and
     close[1] > open[1] and
     open >= close[1] and
     close <= open[1]


//====================================================================
// 9. PIVOTS
//====================================================================

pivotLow =
     ta.pivotlow(
         low,
         pivotLen,
         pivotLen)

pivotHigh =
     ta.pivothigh(
         high,
         pivotLen,
         pivotLen)


//====================================================================
// 10. SUPPORT / RESISTANCE STORAGE
//====================================================================

var float support = na
var float resistance = na

var int supportTouches = 0
var int resistanceTouches = 0

var int lastSupportTouchBar = na
var int lastResistanceTouchBar = na


//====================================================================
// 11. PROCESS SUPPORT PIVOTS
//====================================================================

if not na(pivotLow)

    float newSupport =
         pivotLow

    float historicalZone =
         zone[pivotLen]

    bool sameSupport =
         not na(support) and
         math.abs(newSupport - support) <= historicalZone

    if sameSupport

        support :=
             (
                 support * supportTouches +
                 newSupport
             ) /
             (
                 supportTouches + 1
             )

        supportTouches += 1

    else

        support :=
             newSupport

        supportTouches :=
             1

        lastSupportTouchBar :=
             bar_index - pivotLen


//====================================================================
// 12. PROCESS RESISTANCE PIVOTS
//====================================================================

if not na(pivotHigh)

    float newResistance =
         pivotHigh

    float historicalZone =
         zone[pivotLen]

    bool sameResistance =
         not na(resistance) and
         math.abs(newResistance - resistance) <= historicalZone

    if sameResistance

        resistance :=
             (
                 resistance * resistanceTouches +
                 newResistance
             ) /
             (
                 resistanceTouches + 1
             )

        resistanceTouches += 1

    else

        resistance :=
             newResistance

        resistanceTouches :=
             1

        lastResistanceTouchBar :=
             bar_index - pivotLen


//====================================================================
// 13. PRICE AT SUPPORT
//====================================================================

atSupport =
     not na(support) and
     low <= support + zone and
     high >= support - zone


//====================================================================
// 14. PRICE AT RESISTANCE
//====================================================================

atResistance =
     not na(resistance) and
     high >= resistance - zone and
     low <= resistance + zone


//====================================================================
// 15. DISTINCT SUPPORT TOUCH
//====================================================================

newSupportTouch =
     atSupport and
     (
         na(lastSupportTouchBar) or
         bar_index - lastSupportTouchBar >= touchSeparation
     )


//====================================================================
// 16. DISTINCT RESISTANCE TOUCH
//====================================================================

newResistanceTouch =
     atResistance and
     (
         na(lastResistanceTouchBar) or
         bar_index - lastResistanceTouchBar >= touchSeparation
     )


//====================================================================
// 17. UPDATE TOUCH COUNTS
//====================================================================

if newSupportTouch

    supportTouches += 1

    lastSupportTouchBar :=
         bar_index


if newResistanceTouch

    resistanceTouches += 1

    lastResistanceTouchBar :=
         bar_index


//====================================================================
// 18. VALID S/R
//====================================================================

validSupport =
     not na(support) and
     supportTouches >= signalTouches

validResistance =
     not na(resistance) and
     resistanceTouches >= signalTouches


//====================================================================
// 19. SUPPORT RECLAIM
//====================================================================

supportReclaim =
     validSupport and
     atSupport and
     low < support - zone * 0.20 and
     close > support


//====================================================================
// 20. SUPPORT REJECTION
//====================================================================

supportRejection =
     validSupport and
     atSupport and
     bullReject


//====================================================================
// 21. SUPPORT ENGULFING
//====================================================================

supportEngulfing =
     validSupport and
     atSupport and
     bullEngulf


//====================================================================
// 22. SUPPORT ENTRY
//====================================================================

supportEntry =
     supportReclaim or
     supportRejection or
     supportEngulfing


//====================================================================
// 23. RESISTANCE BREAKOUT
//====================================================================

resistanceBreakout =
     validResistance and
     close > resistance + zone * 0.20 and
     close[1] <= resistance + zone * 0.20


//====================================================================
// 24. BREAKOUT MEMORY
//====================================================================

var bool waitingForRetest = false

var float breakoutLevel = na

var int breakoutBar = na

var int breakoutTouchCount = na


//====================================================================
// 25. STORE BREAKOUT
//====================================================================

if resistanceBreakout

    waitingForRetest :=
         true

    breakoutLevel :=
         resistance

    breakoutBar :=
         bar_index

    breakoutTouchCount :=
         resistanceTouches


//====================================================================
// 26. EXPIRE BREAKOUT
//====================================================================

if waitingForRetest and
     bar_index - breakoutBar > retestBars

    waitingForRetest :=
         false

    breakoutLevel :=
         na

    breakoutBar :=
         na

    breakoutTouchCount :=
         na


//====================================================================
// 27. RETEST OLD RESISTANCE
//====================================================================

retestingOldResistance =
     waitingForRetest and
     bar_index > breakoutBar and
     low <= breakoutLevel + zone and
     high >= breakoutLevel - zone


//====================================================================
// 28. RETEST HOLDS
//====================================================================

retestHeld =
     retestingOldResistance and
     close >= breakoutLevel


//====================================================================
// 29. BREAKOUT & RETEST ENTRY
//====================================================================

breakoutRetestEntry =
     retestHeld and
     (
         bullReject or
         bullEngulf
     )


//====================================================================
// 30. CLOSE B&R SETUP
//====================================================================

if breakoutRetestEntry

    waitingForRetest :=
         false


//====================================================================
// 31. RESISTANCE REJECTION
//====================================================================

resistanceRejection =
     validResistance and
     atResistance and
     bearReject


//====================================================================
// 32. RESISTANCE ENGULFING
//====================================================================

resistanceEngulfing =
     validResistance and
     atResistance and
     bearEngulf


//====================================================================
// 33. FAILED BREAKOUT
//====================================================================

failedBreakout =
     validResistance and
     high > resistance + zone * 0.20 and
     close < resistance


//====================================================================
// 34. INTERNAL RESISTANCE WARNING
//
// Hidden from chart.
//
// R3+ warning activates rolling 10D protection.
//====================================================================

resistanceWarning =
     resistanceRejection or
     resistanceEngulfing or
     failedBreakout


//====================================================================
// 35. PREVIOUS 10 COMPLETED CANDLES LOW
//====================================================================

previous10DayLow =
     ta.lowest(
         low[1],
         exitLookback)


//====================================================================
// 36. SIGNAL COOLDOWN
//====================================================================

var int lastGreenSignal = na

var int lastWarningSignal = na


greenAllowed =
     na(lastGreenSignal) or
     bar_index - lastGreenSignal >= signalCooldown


warningAllowed =
     na(lastWarningSignal) or
     bar_index - lastWarningSignal >= signalCooldown


//====================================================================
// 37. NORMAL BUY SETUPS
//====================================================================

supportBuySignal =
     supportEntry and
     greenAllowed


breakoutBuySignal =
     breakoutRetestEntry and
     greenAllowed


rawBuySignal =
     supportBuySignal or
     breakoutBuySignal


//====================================================================
// 38. INTERNAL TRADE STATE
//====================================================================

var bool inTrade = false

var float entryPrice = na

var float entryFrozenLow = na

var float originalSetupLevel = na

var int entryBar = na


//====================================================================
// 39. STORE ENTRY INFORMATION FOR HOVER
//====================================================================

var int storedEntryTouchCount = na

var string storedEntryReason = ""

var string storedEntryCandle = ""

var float storedEntryVolume = na

var float storedEntryRVOL = na


//====================================================================
// 40. R3 PROTECTION STATE
//====================================================================

var bool r3ProtectionActive = false

var int r3ActivatedBar = na


//====================================================================
// 41. RE-BUY STATE
//====================================================================

var bool reentryArmed = false

var float savedReentryLevel = na

var int reentryStartBar = na

var bool reentryUsed = false

var string savedOriginalReason = ""

var int savedOriginalTouchCount = na


//====================================================================
// 42. CANDLE DESCRIPTION
//====================================================================

string currentCandleType =
     bullEngulf
     ? "Bullish Engulfing"
     : bullReject
     ? "Bullish Rejection"
     : bullish
     ? "Bullish Candle"
     : bearish
     ? "Bearish Candle"
     : "Neutral Candle"


//====================================================================
// 43. NORMAL BUY
//====================================================================

buySignal =
     not inTrade and
     not reentryArmed and
     rawBuySignal


//====================================================================
// 44. DETERMINE NORMAL BUY REASON
//====================================================================

string currentBuyReason =
     breakoutBuySignal
     ? "Breakout & Retest"
     : supportReclaim
     ? "Support Reclaim"
     : supportEngulfing
     ? "Support Engulfing"
     : supportRejection
     ? "Support Rejection"
     : "Price Action"


int currentBuyTouchCount =
     breakoutBuySignal
     ? breakoutTouchCount
     : supportTouches


string currentBuySR =
     breakoutBuySignal
     ? "R" + str.tostring(currentBuyTouchCount)
     : "S" + str.tostring(currentBuyTouchCount)


//====================================================================
// 45. NORMAL BUY TOOLTIP
//====================================================================

string buyTooltip =
     "BUY" +
     "\nSetup: " + currentBuySR + " " + currentBuyReason +
     "\nCandle: " + currentCandleType +
     "\nVolume: " + str.tostring(volume, format.volume) +
     "\nRVOL20: " + str.tostring(rvol20, "#.##") + "x" +
     "\nPrice: " + str.tostring(close, format.mintick)


//====================================================================
// 46. EXECUTE INTERNAL NORMAL BUY
//====================================================================

if buySignal

    float setupLevel =
         breakoutBuySignal and not na(breakoutLevel)
         ? breakoutLevel
         : not na(support)
         ? support
         : close

    inTrade :=
         true

    entryPrice :=
         close

    entryFrozenLow :=
         previous10DayLow

    originalSetupLevel :=
         setupLevel

    entryBar :=
         bar_index

    storedEntryTouchCount :=
         currentBuyTouchCount

    storedEntryReason :=
         currentBuyReason

    storedEntryCandle :=
         currentCandleType

    storedEntryVolume :=
         volume

    storedEntryRVOL :=
         rvol20

    r3ProtectionActive :=
         false

    r3ActivatedBar :=
         na

    reentryArmed :=
         false

    savedReentryLevel :=
         na

    reentryStartBar :=
         na

    reentryUsed :=
         false

    lastGreenSignal :=
         bar_index


//====================================================================
// 47. INTERNAL R3 WARNING
//====================================================================

r3WarningSignal =
     inTrade and
     resistanceWarning and
     warningAllowed


//====================================================================
// 48. ACTIVATE ROLLING 10D PROTECTION
//====================================================================

if r3WarningSignal

    lastWarningSignal :=
         bar_index

    if not r3ProtectionActive

        r3ProtectionActive :=
             true

        r3ActivatedBar :=
             bar_index


//====================================================================
// 49. PRE-R3 EXIT
//====================================================================

preR3Exit =
     inTrade and
     not r3ProtectionActive and
     not na(entryFrozenLow) and
     not na(entryBar) and
     bar_index > entryBar and
     close < entryFrozenLow


//====================================================================
// 50. POST-R3 EXIT
//====================================================================

postR3Exit =
     inTrade and
     r3ProtectionActive and
     not na(r3ActivatedBar) and
     bar_index > r3ActivatedBar and
     not na(previous10DayLow) and
     close < previous10DayLow


//====================================================================
// 51. FINAL EXIT
//====================================================================

exitSignal =
     preR3Exit or
     postR3Exit


//====================================================================
// 52. EXIT TOOLTIP
//====================================================================

string exitReason =
     postR3Exit
     ? "R3+ activated rolling 10D low"
     : "Frozen entry 10D low"


float exitLevel =
     postR3Exit
     ? previous10DayLow
     : entryFrozenLow


string exitTooltip =
     "EXIT" +
     "\nReason: " + exitReason +
     "\nExit Level: " + str.tostring(exitLevel, format.mintick) +
     "\nClose: " + str.tostring(close, format.mintick) +
     "\nCandle: " + currentCandleType +
     "\nVolume: " + str.tostring(volume, format.volume) +
     "\nRVOL20: " + str.tostring(rvol20, "#.##") + "x"


//====================================================================
// 53. HANDLE EXIT
//====================================================================

if exitSignal

    savedReentryLevel :=
         not na(originalSetupLevel)
         ? originalSetupLevel
         : entryPrice

    savedOriginalReason :=
         storedEntryReason

    savedOriginalTouchCount :=
         storedEntryTouchCount

    reentryArmed :=
         true

    reentryStartBar :=
         bar_index

    reentryUsed :=
         false

    inTrade :=
         false

    entryPrice :=
         na

    entryFrozenLow :=
         na

    entryBar :=
         na

    r3ProtectionActive :=
         false

    r3ActivatedBar :=
         na


//====================================================================
// 54. RE-BUY EXPIRATION
//====================================================================

reentryExpired =
     reentryArmed and
     not na(reentryStartBar) and
     bar_index - reentryStartBar > reentryBars


if reentryExpired

    reentryArmed :=
         false

    savedReentryLevel :=
         na

    reentryStartBar :=
         na

    reentryUsed :=
         false

    savedOriginalReason :=
         ""

    savedOriginalTouchCount :=
         na


//====================================================================
// 55. RE-BUY THRESHOLD
//====================================================================

reentryThreshold =
     not na(savedReentryLevel)
     ? savedReentryLevel + atr * reentryBufferATR
     : na


//====================================================================
// 56. BULLISH RECLAIM
//====================================================================

bullishReclaimCandle =
     bullish and
     close > close[1]


//====================================================================
// 57. FRESH RECLAIM
//====================================================================

freshReclaim =
     reentryArmed and
     not na(reentryThreshold) and
     close > reentryThreshold and
     close[1] <= reentryThreshold


//====================================================================
// 58. RE-BUY CONFIRMATION
//====================================================================

reentryConfirmation =
     bullReject or
     bullEngulf or
     bullishReclaimCandle


//====================================================================
// 59. FINAL RE-BUY
//====================================================================

reBuySignal =
     not inTrade and
     reentryArmed and
     not reentryUsed and
     not na(reentryStartBar) and
     bar_index > reentryStartBar and
     freshReclaim and
     reentryConfirmation


//====================================================================
// 60. RE-BUY TOOLTIP
//====================================================================

string reBuyOriginalSetup =
     not na(savedOriginalTouchCount)
     ? "S/R" + str.tostring(savedOriginalTouchCount)
     : "Previous Setup"


string reBuyTooltip =
     "RE-BUY" +
     "\nReason: Previous setup reclaimed" +
     "\nOriginal: " + reBuyOriginalSetup + " " + savedOriginalReason +
     "\nReclaim Level: " + str.tostring(savedReentryLevel, format.mintick) +
     "\nCandle: " + currentCandleType +
     "\nVolume: " + str.tostring(volume, format.volume) +
     "\nRVOL20: " + str.tostring(rvol20, "#.##") + "x" +
     "\nPrice: " + str.tostring(close, format.mintick)


//====================================================================
// 61. EXECUTE INTERNAL RE-BUY
//====================================================================

if reBuySignal

    inTrade :=
         true

    entryPrice :=
         close

    entryFrozenLow :=
         previous10DayLow

    originalSetupLevel :=
         savedReentryLevel

    entryBar :=
         bar_index

    storedEntryReason :=
         "Re-Buy Reclaim"

    storedEntryCandle :=
         currentCandleType

    storedEntryVolume :=
         volume

    storedEntryRVOL :=
         rvol20

    r3ProtectionActive :=
         false

    r3ActivatedBar :=
         na

    reentryUsed :=
         true

    reentryArmed :=
         false

    reentryStartBar :=
         na

    lastGreenSignal :=
         bar_index


//====================================================================
// 62. ACTIVE EXIT LEVEL
//====================================================================

activeExitLevel =
     inTrade
     ? (
         r3ProtectionActive
         ? previous10DayLow
         : entryFrozenLow
       )
     : na


//====================================================================
// 63. TINY B MARKER
//
// Hover over B for:
//   S3/R3
//   setup reason
//   candle
//   volume
//   RVOL
//   price
//====================================================================

if buySignal

    label.new(
         bar_index,
         low,
         "B",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.tiny,
         tooltip=buyTooltip)


//====================================================================
// 64. TINY R-B MARKER
//====================================================================

if reBuySignal

    label.new(
         bar_index,
         low,
         "R-B",
         style=label.style_label_up,
         color=color.aqua,
         textcolor=color.black,
         size=size.tiny,
         tooltip=reBuyTooltip)


//====================================================================
// 65. TINY E MARKER
//====================================================================

if exitSignal

    label.new(
         bar_index,
         high,
         "E",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.tiny,
         tooltip=exitTooltip)


//====================================================================
// 66. OPTIONAL EXIT LEVEL
//====================================================================

plot(
     showExitLevel
     ? activeExitLevel
     : na,
     title="Active Exit Level",
     color=color.orange,
     linewidth=1)


//====================================================================
// 67. OPTIONAL RE-BUY LEVEL
//====================================================================

plot(
     showReentryLevel and reentryArmed
     ? reentryThreshold
     : na,
     title="Re-Buy Level",
     color=color.aqua,
     linewidth=1)


//====================================================================
// 68. ALERTS
//====================================================================

alertcondition(
     buySignal,
     title="B",
     message="BUY signal")

alertcondition(
     reBuySignal,
     title="R-B",
     message="RE-BUY signal")

alertcondition(
     exitSignal,
     title="E",
     message="EXIT signal")
````
