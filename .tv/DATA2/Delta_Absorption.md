<!-- tradingview-pine-id: PUB;b31f68d3582249d6b4d2e1bb22a04cb6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Delta Absorption

Source: https://www.tradingview.com/script/SrtMeFGj-Delta-Absorption/

## Description

DELTA ABSORPTION

Delta Absorption is designed to find moments where aggressive buying or selling is strong, but price does not move much in the same direction.

That can suggest the aggressive side is being absorbed by passive buyers or sellers.

IMPORTANT:
This indicator uses estimated Delta based on candle price and volume.
It is NOT true exchange Bid/Ask order-flow Delta.

--------------------------------------------------
POSSIBLE BULL ABSORPTION
--------------------------------------------------

A possible Bull Absorption happens when:

1. Delta is strongly NEGATIVE
2. Sellers are aggressive
3. Price does NOT move down very much
4. Volume passes the filter if the volume filter is turned ON

This can suggest passive buyers are absorbing aggressive sellers.

GREEN SQUARE BELOW CANDLE
= Possible Bull Absorption

Simple example:

Strong selling
+
Very little downside price movement
=
Possible buyers absorbing sellers

--------------------------------------------------
POSSIBLE BEAR ABSORPTION
--------------------------------------------------

A possible Bear Absorption happens when:

1. Delta is strongly POSITIVE
2. Buyers are aggressive
3. Price does NOT move up very much
4. Volume passes the filter if the volume filter is turned ON

This can suggest passive sellers are absorbing aggressive buyers.

RED SQUARE ABOVE CANDLE
= Possible Bear Absorption

Simple example:

Strong buying
+
Very little upside price movement
=
Possible sellers absorbing buyers

--------------------------------------------------
CONFIRMED BULL ABSORPTION
--------------------------------------------------

A Confirmed Bull Absorption requires:

1. Possible Bull Absorption happens first
2. Strong selling fails to move price lower
3. Within the Confirmation Bars setting,
   Delta strongly flips from negative to positive
4. The Flip must pass the Flip Threshold

GREEN DIAMOND BELOW CANDLE
= Confirmed Bull Absorption

Simple example:

Strong selling appears
+
Price resists going lower
+
Aggression strongly flips bullish
=
Confirmed Bull Absorption

--------------------------------------------------
CONFIRMED BEAR ABSORPTION
--------------------------------------------------

A Confirmed Bear Absorption requires:

1. Possible Bear Absorption happens first
2. Strong buying fails to move price higher
3. Within the Confirmation Bars setting,
   Delta strongly flips from positive to negative
4. The Flip must pass the Flip Threshold

RED DIAMOND ABOVE CANDLE
= Confirmed Bear Absorption

Simple example:

Strong buying appears
+
Price resists going higher
+
Aggression strongly flips bearish
=
Confirmed Bear Absorption

--------------------------------------------------
DELTA LOOKBACK
--------------------------------------------------

Default: 10

Controls how many previous candles are used to calculate what normal Delta looks like.

Lower number:
More sensitive
Reacts faster

Higher number:
Smoother
Uses more history

--------------------------------------------------
ABSORPTION DELTA THRESHOLD
--------------------------------------------------

Default: 1.2

Controls how strong Delta must be before the candle can qualify as possible absorption.

1.2 means Delta must be about 1.2x normal.

Higher number:
Stronger Delta required
Fewer signals

Lower number:
Weaker Delta can qualify
More signals

--------------------------------------------------
ATR LENGTH
--------------------------------------------------

Default: 14

ATR is used to measure normal price movement.

This helps the indicator decide whether price moved too much or barely moved compared with what is normal.

--------------------------------------------------
MAXIMUM PRICE RESPONSE
--------------------------------------------------

Default: 0.50

Controls how much price is allowed to move in the same direction as the aggressive Delta.

Example:

If ATR = 10 points

Maximum Price Response = 0.50

Maximum allowed movement = 5 points

If aggressive buyers enter but price moves up less than 5 points,
the candle can still qualify as possible Bear Absorption.

If price moves strongly with the aggression,
the candle is less likely to be absorption.

Lower setting:
Price must resist aggression more strongly
Fewer signals

Higher setting:
Allows more price movement
More signals

--------------------------------------------------
SHOCK LOOKBACK
--------------------------------------------------

Default: 3

Controls how many previous candles are used to calculate what a normal change in Delta looks like.

This setting is used for the Flip confirmation.

Lower number:
Very sensitive
Reacts quickly

Higher number:
Smoother
Less sensitive

--------------------------------------------------
FLIP THRESHOLD
--------------------------------------------------

Default: 1.5

Controls how strong the Delta change must be before it counts as a strong Flip.

A Bull Flip means:

Negative Delta
to
Positive Delta

A Bear Flip means:

Positive Delta
to
Negative Delta

1.5 means the Delta change must be about 1.5x stronger than a normal Delta change.

Higher setting:
Stronger Flip required
Fewer confirmed signals

Lower setting:
Easier Flip requirement
More confirmed signals

--------------------------------------------------
CONFIRMATION BARS
--------------------------------------------------

Default: 5

Controls how many candles the indicator waits after possible absorption for a strong Flip to happen.

Example:

Confirmation Bars = 5

The Flip can happen within the next:

1 candle
2 candles
3 candles
4 candles
or
5 candles

If the Flip happens after that window,
it will not count as confirmed absorption.

--------------------------------------------------
USE VOLUME FILTER
--------------------------------------------------

When ON:

The candle must also have enough volume to qualify.

When OFF:

Volume does not affect whether the signal appears.

--------------------------------------------------
VOLUME AVERAGE LENGTH
--------------------------------------------------

Default: 20

Controls how many candles are used to calculate average volume.

--------------------------------------------------
MINIMUM VOLUME VS AVERAGE
--------------------------------------------------

Default: 0.60

Controls how much volume the candle needs when the Volume Filter is ON.

0.60
= at least 60% of average volume

1.00
= at least average volume

1.50
= at least 1.5x average volume

Higher setting:
Fewer signals
Stronger volume required

Lower setting:
More signals

--------------------------------------------------
SHOW POSSIBLE ABSORPTION
--------------------------------------------------

Turns the possible absorption squares ON or OFF.

GREEN SQUARE
= Possible Bull Absorption

RED SQUARE
= Possible Bear Absorption

--------------------------------------------------
SHOW CONFIRMED ABSORPTION
--------------------------------------------------

Turns the confirmed absorption diamonds ON or OFF.

GREEN DIAMOND
= Confirmed Bull Absorption

RED DIAMOND
= Confirmed Bear Absorption

--------------------------------------------------
SHOW STRONG DELTA DEBUG
--------------------------------------------------

This is mainly for testing the indicator.

When turned ON:

Green triangle
= Strong positive Delta

Red triangle
= Strong negative Delta

This helps show whether the Delta part of the indicator is working.

If triangles are appearing but no squares are appearing,
the Price Response filter is likely blocking the absorption signals.

If squares are appearing but very few diamonds are appearing,
the Flip confirmation is likely too strict.

--------------------------------------------------
QUICK MARKER GUIDE
--------------------------------------------------

GREEN SQUARE
= Possible Bull Absorption

Strong selling
+
Price does not move down much

RED SQUARE
= Possible Bear Absorption

Strong buying
+
Price does not move up much

GREEN DIAMOND
= Confirmed Bull Absorption

Possible Bull Absorption
+
Strong bullish aggression Flip

RED DIAMOND
= Confirmed Bear Absorption

Possible Bear Absorption
+
Strong bearish aggression Flip

--------------------------------------------------
SIMPLE SUMMARY
--------------------------------------------------

Possible Absorption
=
Strong aggression
+
Weak price response

Confirmed Absorption
=
Possible absorption
+
Strong Delta Flip afterward

Bull Absorption
=
Aggressive sellers may be getting absorbed by buyers

Bear Absorption
=
Aggressive buyers may be getting absorbed by sellers

---

## Source Code

````pine
//@version=6
indicator("Delta Absorption", shorttitle="Delta Absorption", overlay=true)

//====================================================================
// 1. ABSORPTION SETTINGS
//====================================================================

groupAbsorption = "ABSORPTION"

deltaLookback = input.int(
     20,
     "Delta Lookback",
     minval=5,
     group=groupAbsorption,
     display=display.none
     )

absorptionMult = input.float(
     2.0,
     "Absorption Delta Threshold",
     minval=0.1,
     step=0.1,
     group=groupAbsorption,
     display=display.none
     )

atrLength = input.int(
     14,
     "ATR Length",
     minval=1,
     group=groupAbsorption,
     display=display.none
     )

maxPriceResponseATR = input.float(
     0.20,
     "Maximum Price Response",
     minval=0.01,
     step=0.05,
     group=groupAbsorption,
     display=display.none
     )

//====================================================================
// 2. CONFIRMATION SETTINGS
//====================================================================

groupConfirmation = "CONFIRMATION"

// CHANGED:
// Shock Lookback can now go as low as 2.

shockLookback = input.int(
     5,
     "Shock Lookback",
     minval=2,
     group=groupConfirmation,
     display=display.none
     )

flipThreshold = input.float(
     2.5,
     "Flip Threshold",
     minval=0.1,
     step=0.1,
     group=groupConfirmation,
     display=display.none
     )

confirmationBars = input.int(
     3,
     "Confirmation Bars",
     minval=1,
     maxval=20,
     group=groupConfirmation,
     display=display.none
     )

//====================================================================
// 3. VOLUME FILTER
//====================================================================

groupVolume = "VOLUME FILTER"

useVolumeFilter = input.bool(
     true,
     "Use Volume Filter",
     group=groupVolume,
     display=display.none
     )

volumeLookback = input.int(
     20,
     "Volume Average Length",
     minval=2,
     group=groupVolume,
     display=display.none
     )

volumeMult = input.float(
     1.0,
     "Minimum Volume vs Average",
     minval=0.1,
     step=0.1,
     group=groupVolume,
     display=display.none
     )

//====================================================================
// 4. DISPLAY SETTINGS
//====================================================================

groupDisplay = "DISPLAY"

showPotential = input.bool(
     true,
     "Show Possible Absorption",
     group=groupDisplay,
     display=display.none
     )

showConfirmed = input.bool(
     true,
     "Show Confirmed Absorption",
     group=groupDisplay,
     display=display.none
     )

bullColor = input.color(
     color.lime,
     "Bull Color",
     group=groupDisplay,
     display=display.none
     )

bearColor = input.color(
     color.red,
     "Bear Color",
     group=groupDisplay,
     display=display.none
     )

//====================================================================
// 5. ESTIMATED BUY / SELL VOLUME
//====================================================================

// IMPORTANT:
//
// This is estimated Delta based on candle price and volume.
//
// It is NOT true exchange Bid/Ask aggressor Delta.

barRange = high - low

buyVolume =
     barRange > 0
     ? volume * (close - low) / barRange
     : volume * 0.5

sellVolume =
     barRange > 0
     ? volume * (high - close) / barRange
     : volume * 0.5

//====================================================================
// 6. DELTA
//====================================================================

delta = buyVolume - sellVolume

absDelta = math.abs(delta)

//====================================================================
// 7. NORMAL DELTA
//====================================================================

// Use previous candles to determine what normal Delta looks like.

avgAbsDelta = ta.sma(absDelta[1], deltaLookback)

// Compare the current Delta against normal Delta.

aggressionRatio =
     avgAbsDelta > 0
     ? absDelta / avgAbsDelta
     : 0.0

//====================================================================
// 8. VOLUME FILTER
//====================================================================

// Determine normal volume.

avgVolume = ta.sma(volume[1], volumeLookback)

// Candle passes volume filter if:
//
// Volume Filter OFF
//
// OR
//
// Current volume is large enough.

volumeOK =
     not useVolumeFilter or
     volume >= avgVolume * volumeMult

//====================================================================
// 9. ATR / PRICE RESPONSE
//====================================================================

// ATR gives us a measurement of normal price movement.

atrValue = ta.atr(atrLength)

// Measure candle body movement.

priceChange = close - open

// Maximum amount price is allowed to move in the aggression
// direction before we stop calling it possible absorption.

maxPriceResponse =
     atrValue * maxPriceResponseATR

//====================================================================
// 10. POSSIBLE BEARISH ABSORPTION
//====================================================================

// Buyers are aggressive.
//
// Delta is strongly positive.
//
// BUT price does not move upward enough.
//
// This MAY mean passive sellers are absorbing
// the aggressive buyers.

buyersAbsorbed =
     barstate.isconfirmed and
     delta > 0 and
     aggressionRatio >= absorptionMult and
     priceChange <= maxPriceResponse and
     volumeOK

//====================================================================
// 11. POSSIBLE BULLISH ABSORPTION
//====================================================================

// Sellers are aggressive.
//
// Delta is strongly negative.
//
// BUT price does not move downward enough.
//
// This MAY mean passive buyers are absorbing
// the aggressive sellers.

sellersAbsorbed =
     barstate.isconfirmed and
     delta < 0 and
     aggressionRatio >= absorptionMult and
     priceChange >= -maxPriceResponse and
     volumeOK

//====================================================================
// 12. DELTA SHOCK
//====================================================================

// Measure the change in Delta from the previous candle.
//
// Example:
//
// Previous Delta = -2000
// Current Delta  = +1500
//
// Shock = +3500

shock = delta - delta[1]

absShock = math.abs(shock)

//====================================================================
// 13. NORMAL SHOCK
//====================================================================

// Shock Lookback determines how many recent candles
// are used to determine what a normal Delta change is.
//
// NOW YOU CAN SET THIS AS LOW AS 2.

avgAbsShock =
     ta.sma(absShock[1], shockLookback)

//====================================================================
// 14. SHOCK RATIO
//====================================================================

// Compare current Shock with normal Shock.
//
// Example:
//
// Current Shock = 3000
// Normal Shock  = 1000
//
// Shock Ratio = 3.0x

shockRatio =
     avgAbsShock > 0
     ? absShock / avgAbsShock
     : 0.0

//====================================================================
// 15. BULLISH AGGRESSION FLIP
//====================================================================

// Previous candle:
// Negative Delta = sellers controlled aggression.
//
// Current candle:
// Positive Delta = buyers now control aggression.
//
// The change must also pass the Flip Threshold.

bullFlip =
     barstate.isconfirmed and
     delta[1] < 0 and
     delta > 0 and
     shock > 0 and
     shockRatio >= flipThreshold and
     volumeOK

//====================================================================
// 16. BEARISH AGGRESSION FLIP
//====================================================================

// Previous candle:
// Positive Delta = buyers controlled aggression.
//
// Current candle:
// Negative Delta = sellers now control aggression.
//
// The change must also pass the Flip Threshold.

bearFlip =
     barstate.isconfirmed and
     delta[1] > 0 and
     delta < 0 and
     shock < 0 and
     shockRatio >= flipThreshold and
     volumeOK

//====================================================================
// 17. FIND RECENT POSSIBLE ABSORPTION
//====================================================================

// Count how many candles have passed since
// possible seller absorption.

barsSinceSellerAbsorption =
     ta.barssince(sellersAbsorbed)

// Count how many candles have passed since
// possible buyer absorption.

barsSinceBuyerAbsorption =
     ta.barssince(buyersAbsorbed)

//====================================================================
// 18. CONFIRMED BULLISH ABSORPTION
//====================================================================

// Requirements:
//
// 1. Strong selling happened.
//
// 2. Price resisted that selling.
//
// 3. Possible Bull Absorption was detected.
//
// 4. Within the Confirmation Bars window,
//    aggression strongly flips bullish.

confirmedBullAbsorption =
     bullFlip and
     not na(barsSinceSellerAbsorption) and
     barsSinceSellerAbsorption > 0 and
     barsSinceSellerAbsorption <= confirmationBars

//====================================================================
// 19. CONFIRMED BEARISH ABSORPTION
//====================================================================

// Requirements:
//
// 1. Strong buying happened.
//
// 2. Price resisted that buying.
//
// 3. Possible Bear Absorption was detected.
//
// 4. Within the Confirmation Bars window,
//    aggression strongly flips bearish.

confirmedBearAbsorption =
     bearFlip and
     not na(barsSinceBuyerAbsorption) and
     barsSinceBuyerAbsorption > 0 and
     barsSinceBuyerAbsorption <= confirmationBars

//====================================================================
// 20. POSSIBLE BULL ABSORPTION MARKER
//====================================================================

// GREEN SQUARE BELOW CANDLE
//
// Strong selling aggression,
// but price resisted going lower.

plotshape(
     showPotential and sellersAbsorbed,
     title="Possible Bull Absorption",
     style=shape.square,
     location=location.belowbar,
     color=bullColor,
     size=size.tiny
     )

//====================================================================
// 21. POSSIBLE BEAR ABSORPTION MARKER
//====================================================================

// RED SQUARE ABOVE CANDLE
//
// Strong buying aggression,
// but price resisted going higher.

plotshape(
     showPotential and buyersAbsorbed,
     title="Possible Bear Absorption",
     style=shape.square,
     location=location.abovebar,
     color=bearColor,
     size=size.tiny
     )

//====================================================================
// 22. CONFIRMED BULL ABSORPTION
//====================================================================

// GREEN DIAMOND BELOW CANDLE
//
// Seller absorption happened first,
// then aggression strongly flipped bullish.

plotshape(
     showConfirmed and confirmedBullAbsorption,
     title="Confirmed Bull Absorption",
     style=shape.diamond,
     location=location.belowbar,
     color=bullColor,
     size=size.tiny
     )

//====================================================================
// 23. CONFIRMED BEAR ABSORPTION
//====================================================================

// RED DIAMOND ABOVE CANDLE
//
// Buyer absorption happened first,
// then aggression strongly flipped bearish.

plotshape(
     showConfirmed and confirmedBearAbsorption,
     title="Confirmed Bear Absorption",
     style=shape.diamond,
     location=location.abovebar,
     color=bearColor,
     size=size.tiny
     )

//====================================================================
// 24. HIDDEN DATA
//====================================================================

// Hidden so TradingView does not clutter
// the top of the chart with values.

plot(
     delta,
     title="Estimated Delta",
     display=display.none
     )

plot(
     aggressionRatio,
     title="Aggression Ratio",
     display=display.none
     )

plot(
     shock,
     title="Delta Shock",
     display=display.none
     )

plot(
     shockRatio,
     title="Shock Ratio",
     display=display.none
     )

plot(
     priceChange,
     title="Price Response",
     display=display.none
     )

//====================================================================
// 25. ALERTS
//====================================================================

alertcondition(
     sellersAbsorbed,
     title="Possible Bull Absorption",
     message="Aggressive selling may be getting absorbed by buyers"
     )

alertcondition(
     buyersAbsorbed,
     title="Possible Bear Absorption",
     message="Aggressive buying may be getting absorbed by sellers"
     )

alertcondition(
     confirmedBullAbsorption,
     title="Confirmed Bull Absorption",
     message="Seller absorption followed by a strong bullish aggression flip"
     )

alertcondition(
     confirmedBearAbsorption,
     title="Confirmed Bear Absorption",
     message="Buyer absorption followed by a strong bearish aggression flip"
     )
````
