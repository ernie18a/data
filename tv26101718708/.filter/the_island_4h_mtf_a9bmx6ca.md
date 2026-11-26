# The Island 4H MTF

- url: https://www.tradingview.com/script/a9BmX6CA-The-Island-4H-MTF/
- type: indicator
- pine_id: PUB;a1575c3f5cfa4bd3999842eb17487b18
- version: 2.0

## Description

The Indicator looks for a failed breakout on the 4H — what most people call a liquidity sweep or a stop run.The mechanic is deliberately simple. On each closed 4H candle it asks two questions:

Buy: Did this candle's low go below the previous candle's low, and did it then close back above that low? If yes, price probed below a level where stops were resting, failed to hold there, and buyers reclaimed the level before the candle closed. Green triangle below the bar.

Sell: Did this candle's high go above the previous candle's high, and did it close back below it? Sellers rejected the probe. Red triangle above the bar.

Everything is computed on the 4H series itself, so the signals are identical whether you're looking at a 5m, 15m, 1h or 4h chart. The lower timeframe just gives you a finer view of the same 4H events.

What actually matters when you take these entries

1. The signal tells you where, not whether. A sweep at a level nobody cares about is noise. A sweep of a prior day's low, a weekly open, a swing point that's been tested twice, a round number — that's a sweep with a reason. Before taking any triangle, ask what liquidity was actually taken. If you can't name the level, skip it. This is the single biggest filter and the indicator can't do it for you.

2. Direction bias. Buy sweeps taken against a strong 4H/daily downtrend get run over. The pattern works best when the sweep is against the immediate move but with the higher-timeframe direction — a fake breakdown inside an uptrend. Overlay a daily 50/200 EMA and be honest about which side you're on. I offered a built-in bias filter earlier; this is why it's worth adding.

3. Location within the range. Sweeps at the extremes of a multi-day range are meaningfully different from sweeps in the middle of one. Mid-range sweeps in chop will fire constantly and most will fail. If price has been going sideways for a week, expect a lot of triangles and a lot of losses.

4. The signal bar offset. With confirmed close on, the triangle prints at the open of the following 4H candle, not on the sweep candle. That's what makes it non-repainting — but it means the entry price you get is the next 4H open, which can gap away from the signal candle's close, especially on equities and at session boundaries. Decide in advance: are you entering at that open, or waiting for a pullback into the swept level?

5. Where your stop goes defines the trade. Natural invalidation is below the sweep wick's low (for a buy). If that wick is enormous, your stop is far and the position has to be small — the setup may be structurally valid but not worth taking on risk-to-reward alone. Check the wick size before you decide you like the signal.

6. Sweep depth and the reclaim quality. A deep wick with a strong close near the high is a violent rejection. A shallow poke with a close barely back inside is often just noise that happens to satisfy the rule. The close-location filter is the crude version of this judgement; your eyes are better.

7. Session boundaries. 4H candles align to the instrument's session. On equities and futures the 4H boundaries follow exchange hours, and the first bar after a session break behaves differently — overnight gaps can create "sweeps" that are just the gap, not participation.

8. News. A sweep driven by a scheduled release is a different animal from an organic one. CPI, FOMC, earnings — the wick is real but the follow-through is unpredictable. Know what's on the calendar.

9. Consecutive signals. In a strong trend you'll get repeated sweeps in the losing direction as price grinds. Three buy triangles in a row while price makes lower lows is not three opportunities, it's the market telling you the pattern isn't working right now.

Depending on what time frame you decide to use, careful with your risk management and not to make it too large or too close to your entries. You will experience downdraw on your entries. So please pay attention to volume and continuation confirmation on the momentum.

Happy Trading!!!!

## Source Code

````pine
//@version=6
// 
// DISCLAIMER: This code is for educational and testing purposes only.
// 
// Past performance in backtests does not guarantee future results.
// Always verify code logic and test on a demo account before use.

indicator(title = "The Island MTF ", overlay=true)

// === Inputs ===
higherTF  = input.timeframe("240", "Higher Timeframe", group="Settings")
buyColor  = input.color(color.green, "Buy Triangle Color", group="Settings")
sellColor = input.color(color.red,   "Sell Triangle Color", group="Settings")
sizeInput = input.string("Normal", "Triangle Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Settings")

// === 4H OHLC via request.security ===
// "Current" 4H candle = the just-closed one (uses [1] inside the security context).
// These values are stable on every chart bar within the new 4H period.
[curr4HOpen, curr4HHigh, curr4HLow, curr4HClose] = request.security(syminfo.tickerid, higherTF, [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_off)
// "Previous" 4H candle = the candle before the just-closed one.
[prev4HOpen, prev4HHigh, prev4HLow, prev4HClose] = request.security(syminfo.tickerid, higherTF, [open[2], high[2], low[2], close[2]], lookahead=barmerge.lookahead_off)

// Detect the chart bar where the 4H period rolls over
// (the bar where the just-closed 4H candle has just finished).
new4H = ta.change(time(higherTF)) != 0

// === Outside bar patterns ===
// Bullish outside bar: current 4H low is below previous 4H low AND
// current 4H close is above previous 4H high.
bullishOutsideBar = curr4HLow < prev4HLow and curr4HClose > prev4HHigh
// Bearish outside bar: current 4H high is above previous 4H high AND
// current 4H close is below previous 4H low.
bearishOutsideBar = curr4HHigh > prev4HHigh and curr4HClose < prev4HLow

// Fire the signal only on the chart bar where the 4H period rolls over,
// so the values being compared are confirmed/closed 4H candles.
buySignal  = new4H and bullishOutsideBar
sellSignal = new4H and bearishOutsideBar

// === Plot triangles one bar back (at bar_index - 1, the previous 4H candle) ===
// plotshape()'s `size` parameter requires a const string, so we emit one call per
// size option and gate each by the user's selection. Only the matching call draws.
plotshape(buySignal  and sizeInput == "Tiny",  title="Buy Signal (Bullish OB, Tiny)",  style=shape.triangleup,   location=location.belowbar, color=buyColor,  size=size.tiny,  offset=-1)
plotshape(buySignal  and sizeInput == "Small", title="Buy Signal (Bullish OB, Small)", style=shape.triangleup,   location=location.belowbar, color=buyColor,  size=size.small, offset=-1)
plotshape(buySignal  and sizeInput == "Normal",title="Buy Signal (Bullish OB, Normal)",style=shape.triangleup,   location=location.belowbar, color=buyColor,  size=size.normal,offset=-1)
plotshape(buySignal  and sizeInput == "Large", title="Buy Signal (Bullish OB, Large)", style=shape.triangleup,   location=location.belowbar, color=buyColor,  size=size.large, offset=-1)
plotshape(buySignal  and sizeInput == "Huge",  title="Buy Signal (Bullish OB, Huge)",  style=shape.triangleup,   location=location.belowbar, color=buyColor,  size=size.huge,  offset=-1)
plotshape(sellSignal and sizeInput == "Tiny",  title="Sell Signal (Bearish OB, Tiny)",  style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.tiny,  offset=-1)
plotshape(sellSignal and sizeInput == "Small", title="Sell Signal (Bearish OB, Small)", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.small, offset=-1)
plotshape(sellSignal and sizeInput == "Normal",title="Sell Signal (Bearish OB, Normal)",style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.normal,offset=-1)
plotshape(sellSignal and sizeInput == "Large", title="Sell Signal (Bearish OB, Large)", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.large, offset=-1)
plotshape(sellSignal and sizeInput == "Huge",  title="Sell Signal (Bearish OB, Huge)",  style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.huge,  offset=-1)

// === Alert conditions ===
alertcondition(buySignal,  title="Buy Signal (Bullish Outside Bar)",  message="Bullish outside bar detected on {{ticker}} - potential buying opportunity.")
alertcondition(sellSignal, title="Sell Signal (Bearish Outside Bar)", message="Bearish outside bar detected on {{ticker}} - potential selling opportunity.")
````
