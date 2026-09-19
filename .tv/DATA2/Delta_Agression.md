<!-- tradingview-pine-id: PUB;8526961672f54a6c80e1b754f085b1b0 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Delta Agression

Source: https://www.tradingview.com/script/n2jovM3Z-Delta-Agression/

## Description

DELTA AGRESSION

Delta Agression is designed to highlight moments when buying or selling pressure becomes unusually strong.

The indicator estimates Delta from each candle's volume and where the candle closes inside its range. It then compares current activity with recent activity to find spikes, rising aggression, sudden shocks, and flips in control.
==================
● AGGRESSION SPIKE

Delta is unusually large.

Think:
Big aggression.

◆ EXTREME AGGRESSION

Delta is extremely large.

Think:
Very big aggression.

▲ / ▼ RISING AGGRESSION

Aggression has increased for 3 candles in a row.

Think:
Aggression is building.

■ AGGRESSION SHOCK

Delta suddenly changed much harder than normal.

Think:
Aggression suddenly accelerated.

✕ AGGRESSION FLIP

Delta suddenly changed hard AND control switched sides.

Think:
One side aggressively took control from the other side.
===============================================

SIMPLE SUMMARY

Spike = big aggression.

Extreme = very big aggression.

Rising = aggression is building.

Shock = aggression suddenly accelerates.

Flip = one side aggressively takes control from the other side.

IMPORTANT:
The Delta used by this indicator is an estimate based on candle price and volume. It is not true exchange Bid/Ask order-flow Delta.

SETTINGS & SIGNALS

DELTA LOOKBACK
Default: 20

Determines how many recent candles are used to calculate what a normal Delta size looks like.

20 means the current Delta is compared with roughly the last 20 candles.

Higher setting = smoother and harder to trigger.
Lower setting = more sensitive.

AGGRESSION SPIKE
Default: 2.0

Controls the ● Aggression Spike signal.

It looks for Delta that is unusually large compared with normal Delta.

2.0 means the current Delta must be about 2x normal.

Green ● below candle = bullish aggression.
Red ● above candle = bearish aggression.

EXTREME AGGRESSION
Default: 3.5

Controls the ◆ Extreme Aggression signal.

This looks for extremely large Delta readings.

3.5 means Delta must be about 3.5x normal.

Green ◆ below candle = extreme buying aggression.
Red ◆ above candle = extreme selling aggression.

3-BAR RISING AGGRESSION
Marker: ▲ / ▼

Looks for aggression increasing for 3 candles in a row.

Bullish example:

+500
+1,000
+2,000

Buying aggression is getting stronger each candle.

Bearish example:

-500
-1,000
-2,000

Selling aggression is getting stronger each candle.

Green ▲ below candle = buying aggression is building.
Red ▼ above candle = selling aggression is building.

SHOCK LOOKBACK
Default: 20

Determines what a normal change in Delta looks like.

The indicator compares the change in Delta from one candle to the next over the recent lookback period.

20 means it uses roughly the last 20 candles to determine what a normal Delta change looks like.

SHOCK THRESHOLD
Default: 2.0

Controls the ■ Aggression Shock signal.

A Shock happens when Delta suddenly changes much more than normal.

Example:

Previous Delta: +300
Current Delta:  +3,500

That is a large sudden increase toward buyers.

2.0 means the Delta change must be about 2x larger than normal.

Green ■ below candle = bullish shock.
Red ■ above candle = bearish shock.

IMPORTANT:
A Shock does NOT have to cross from negative Delta to positive Delta.

Example:

+300 → +3,500

This can still be a Bull Shock because buying aggression suddenly became much stronger.

FLIP THRESHOLD
Default: 2.5

Controls the ✕ Aggression Flip signal.

A Flip happens when Delta changes sides AND the change is unusually powerful.

Bull Flip example:

Previous Delta: -2,000
Current Delta:  +1,500

Sellers were in control.
Then buyers aggressively took control.

Green ✕ below candle = bullish flip.

Bear Flip example:

Previous Delta: +2,000
Current Delta:  -1,500

Buyers were in control.
Then sellers aggressively took control.

Red ✕ above candle = bearish flip.

2.5 means the takeover must be about 2.5x stronger than a normal Delta change.

USE VOLUME FILTER

When ON, a signal must also have enough total candle volume to qualify.

This helps remove signals that happen during very low-volume candles.

ON = volume requirement is used.
OFF = volume does not affect whether the signal appears.

VOLUME AVERAGE LENGTH
Default: 20

Determines how many candles are used to calculate normal volume.

20 means the indicator uses roughly the last 20 candles to calculate average volume.

MINIMUM VOLUME VS AVERAGE
Default: 1.0

Determines how much volume the current candle needs before a signal is allowed.

1.0 = at least average volume.
1.5 = at least 1.5x average volume.
2.0 = at least 2x average volume.

Higher settings create fewer signals and require stronger volume.

---

## Source Code

````pine
//@version=6
indicator("Delta Agression", shorttitle="Delta Agression", overlay=true)

//====================================================================
// 1. SETTINGS
//====================================================================

groupAgg = "Aggression"

lookback = input.int(
     20,
     "Delta Lookback",
     minval=5,
     group=groupAgg,
     display=display.none
     )

spikeMult = input.float(
     2.0,
     "Aggression Spike",
     minval=1.0,
     step=0.1,
     group=groupAgg,
     display=display.none
     )

extremeMult = input.float(
     3.5,
     "Extreme Aggression",
     minval=1.0,
     step=0.1,
     group=groupAgg,
     display=display.none
     )

//====================================================================
// 2. AGGRESSION SHOCK SETTINGS
//====================================================================

groupShock = "Aggression Shock"

shockLookback = input.int(
     20,
     "Shock Lookback",
     minval=5,
     group=groupShock,
     display=display.none
     )

shockMult = input.float(
     2.0,
     "Shock Threshold",
     minval=1.0,
     step=0.1,
     group=groupShock,
     display=display.none
     )

flipMult = input.float(
     2.5,
     "Flip Threshold",
     minval=1.0,
     step=0.1,
     group=groupShock,
     display=display.none
     )

//====================================================================
// 3. VOLUME FILTER SETTINGS
//====================================================================

groupVolume = "Volume Filter"

useVolumeFilter = input.bool(
     true,
     "Use Volume Filter",
     group=groupVolume,
     display=display.none
     )

volumeLookback = input.int(
     20,
     "Volume Average Length",
     minval=5,
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
// 4. SIGNAL SETTINGS
//====================================================================

groupSignals = "Signals"

showSpike = input.bool(
     true,
     "Show Aggression Spike",
     group=groupSignals,
     display=display.none
     )

showExtreme = input.bool(
     true,
     "Show Extreme Aggression",
     group=groupSignals,
     display=display.none
     )

showRising = input.bool(
     true,
     "Show 3-Bar Rising Aggression",
     group=groupSignals,
     display=display.none
     )

showShock = input.bool(
     true,
     "Show Aggression Shock",
     group=groupSignals,
     display=display.none
     )

showFlip = input.bool(
     true,
     "Show Aggression Flip",
     group=groupSignals,
     display=display.none
     )

//====================================================================
// 5. VISUAL SETTINGS
//====================================================================

groupVisual = "Visuals"

bullColor = input.color(
     color.lime,
     "Bull Color",
     group=groupVisual,
     display=display.none
     )

bearColor = input.color(
     color.red,
     "Bear Color",
     group=groupVisual,
     display=display.none
     )

//====================================================================
// 6. ESTIMATED BUY / SELL VOLUME
//====================================================================

// Candle range
barRange = high - low

// Estimate buying volume.
// Close near the candle high = more volume assigned to buyers.

buyVolume = barRange > 0 ? volume * (close - low) / barRange : volume * 0.5

// Estimate selling volume.
// Close near the candle low = more volume assigned to sellers.

sellVolume = barRange > 0 ? volume * (high - close) / barRange : volume * 0.5

//====================================================================
// 7. DELTA
//====================================================================

delta = buyVolume - sellVolume

absDelta = math.abs(delta)

//====================================================================
// 8. CVD
//====================================================================

cvd = ta.cum(delta)

//====================================================================
// 9. NORMAL DELTA SIZE
//====================================================================

avgAbsDelta = ta.sma(absDelta, lookback)

aggressionRatio = avgAbsDelta > 0 ? absDelta / avgAbsDelta : 0.0

//====================================================================
// 10. VOLUME FILTER
//====================================================================

avgVolume = ta.sma(volume, volumeLookback)

volumeOK = not useVolumeFilter or volume >= avgVolume * volumeMult

//====================================================================
// 11. DELTA DIRECTION
//====================================================================

bullDelta = delta > 0

bearDelta = delta < 0

//====================================================================
// 12. AGGRESSION SPIKE
//====================================================================

// Current Delta is unusually large compared with normal Delta.

bullSpike =
     barstate.isconfirmed and
     bullDelta and
     aggressionRatio >= spikeMult and
     volumeOK

bearSpike =
     barstate.isconfirmed and
     bearDelta and
     aggressionRatio >= spikeMult and
     volumeOK

//====================================================================
// 13. EXTREME AGGRESSION
//====================================================================

// Current Delta is EXTREMELY large compared with normal Delta.

bullExtreme =
     barstate.isconfirmed and
     bullDelta and
     aggressionRatio >= extremeMult and
     volumeOK

bearExtreme =
     barstate.isconfirmed and
     bearDelta and
     aggressionRatio >= extremeMult and
     volumeOK

//====================================================================
// 14. THREE-BAR RISING AGGRESSION
//====================================================================

// Positive Delta gets stronger for 3 consecutive candles.

bullRising =
     barstate.isconfirmed and
     delta > 0 and
     delta[1] > 0 and
     delta[2] > 0 and
     delta > delta[1] and
     delta[1] > delta[2] and
     volumeOK

// Negative Delta gets stronger for 3 consecutive candles.

bearRising =
     barstate.isconfirmed and
     delta < 0 and
     delta[1] < 0 and
     delta[2] < 0 and
     math.abs(delta) > math.abs(delta[1]) and
     math.abs(delta[1]) > math.abs(delta[2]) and
     volumeOK

//====================================================================
// 15. AGGRESSION SHOCK
//====================================================================

// Measure how much Delta changed from the previous candle.
//
// Example:
//
// Previous Delta = -2000
// Current Delta  = +1500
//
// Shock:
//
// +1500 - (-2000)
//
// = +3500

shock = delta - delta[1]

absShock = math.abs(shock)

// Calculate the normal Delta-to-Delta change.

avgAbsShock = ta.sma(absShock, shockLookback)

// Compare current shock with normal shock.

shockRatio = avgAbsShock > 0 ? absShock / avgAbsShock : 0.0

//====================================================================
// 16. BULL / BEAR SHOCK
//====================================================================

// Positive shock = aggression suddenly moved toward buyers.

bullShock =
     barstate.isconfirmed and
     shock > 0 and
     shockRatio >= shockMult and
     volumeOK

// Negative shock = aggression suddenly moved toward sellers.

bearShock =
     barstate.isconfirmed and
     shock < 0 and
     shockRatio >= shockMult and
     volumeOK

//====================================================================
// 17. AGGRESSION FLIP
//====================================================================

// BULL FLIP
//
// Previous candle = negative Delta
// Current candle  = positive Delta
// Shock must also be abnormally strong.

bullFlip =
     barstate.isconfirmed and
     delta[1] < 0 and
     delta > 0 and
     shock > 0 and
     shockRatio >= flipMult and
     volumeOK

// BEAR FLIP
//
// Previous candle = positive Delta
// Current candle  = negative Delta
// Shock must also be abnormally strong.

bearFlip =
     barstate.isconfirmed and
     delta[1] > 0 and
     delta < 0 and
     shock < 0 and
     shockRatio >= flipMult and
     volumeOK

//====================================================================
// 18. AGGRESSION SPIKE MARKERS
//====================================================================

// CIRCLE
//
// Bull = below candle
// Bear = above candle

plotshape(
     showSpike and bullSpike and not bullExtreme,
     title="Bull Aggression Spike",
     style=shape.circle,
     location=location.belowbar,
     color=bullColor,
     size=size.tiny
     )

plotshape(
     showSpike and bearSpike and not bearExtreme,
     title="Bear Aggression Spike",
     style=shape.circle,
     location=location.abovebar,
     color=bearColor,
     size=size.tiny
     )

//====================================================================
// 19. EXTREME AGGRESSION MARKERS
//====================================================================

// DIAMOND

plotshape(
     showExtreme and bullExtreme,
     title="Extreme Bull Aggression",
     style=shape.diamond,
     location=location.belowbar,
     color=bullColor,
     size=size.tiny
     )

plotshape(
     showExtreme and bearExtreme,
     title="Extreme Bear Aggression",
     style=shape.diamond,
     location=location.abovebar,
     color=bearColor,
     size=size.tiny
     )

//====================================================================
// 20. RISING AGGRESSION MARKERS
//====================================================================

// TRIANGLE

plotshape(
     showRising and bullRising,
     title="Rising Bull Aggression",
     style=shape.triangleup,
     location=location.belowbar,
     color=bullColor,
     size=size.tiny
     )

plotshape(
     showRising and bearRising,
     title="Rising Bear Aggression",
     style=shape.triangledown,
     location=location.abovebar,
     color=bearColor,
     size=size.tiny
     )

//====================================================================
// 21. AGGRESSION SHOCK MARKERS
//====================================================================

// SQUARE
//
// We don't show the Shock square if that same candle qualifies
// as a stronger Aggression Flip.

plotshape(
     showShock and bullShock and not bullFlip,
     title="Bull Aggression Shock",
     style=shape.square,
     location=location.belowbar,
     color=bullColor,
     size=size.tiny
     )

plotshape(
     showShock and bearShock and not bearFlip,
     title="Bear Aggression Shock",
     style=shape.square,
     location=location.abovebar,
     color=bearColor,
     size=size.tiny
     )

//====================================================================
// 22. AGGRESSION FLIP MARKERS
//====================================================================

// X CROSS
//
// Bull Flip = below candle
// Bear Flip = above candle

plotshape(
     showFlip and bullFlip,
     title="Bull Aggression Flip",
     style=shape.xcross,
     location=location.belowbar,
     color=bullColor,
     size=size.tiny
     )

plotshape(
     showFlip and bearFlip,
     title="Bear Aggression Flip",
     style=shape.xcross,
     location=location.abovebar,
     color=bearColor,
     size=size.tiny
     )

//====================================================================
// 23. HIDDEN DATA
//====================================================================

// These calculations remain available internally,
// but they are hidden so they do NOT clutter the
// indicator status line with numbers.

plot(
     delta,
     title="Estimated Delta",
     display=display.none
     )

plot(
     cvd,
     title="Estimated CVD",
     display=display.none
     )

plot(
     aggressionRatio,
     title="Aggression Ratio",
     display=display.none
     )

plot(
     shock,
     title="Aggression Shock",
     display=display.none
     )

plot(
     shockRatio,
     title="Shock Ratio",
     display=display.none
     )

plot(
     buyVolume,
     title="Estimated Buy Volume",
     display=display.none
     )

plot(
     sellVolume,
     title="Estimated Sell Volume",
     display=display.none
     )

//====================================================================
// 24. ALERTS
//====================================================================

alertcondition(
     bullSpike,
     title="Bull Aggression Spike",
     message="Bull aggression spike detected"
     )

alertcondition(
     bearSpike,
     title="Bear Aggression Spike",
     message="Bear aggression spike detected"
     )

alertcondition(
     bullExtreme,
     title="Extreme Bull Aggression",
     message="Extreme bull aggression detected"
     )

alertcondition(
     bearExtreme,
     title="Extreme Bear Aggression",
     message="Extreme bear aggression detected"
     )

alertcondition(
     bullShock,
     title="Bull Aggression Shock",
     message="Bull aggression shock detected"
     )

alertcondition(
     bearShock,
     title="Bear Aggression Shock",
     message="Bear aggression shock detected"
     )

alertcondition(
     bullFlip,
     title="Bull Aggression Flip",
     message="Aggression violently flipped from sellers to buyers"
     )

alertcondition(
     bearFlip,
     title="Bear Aggression Flip",
     message="Aggression violently flipped from buyers to sellers"
     )
````
