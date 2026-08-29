<!-- tradingview-pine-id: PUB;a1575c3f5cfa4bd3999842eb17487b18 -->
<!-- tradingviewscripts-format: 1 -->
# The Island 4H MTF

Source: https://www.tradingview.com/script/a9BmX6CA-The-Island-4H-MTF/

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

---

## Source Code

````pine
// =============================================================================
// 4H Reversal MTF
// Pattern: The HTF candle sweeps the prior bar's high or low (liquidity sweep),
// then closes back inside the prior range or beyond the prior close, signalling
// a potential reversal.
// Repainting behaviour:
//   Confirmed Close ON  -> signal fires on the OPEN of the bar after the HTF
//                          candle closes. Fully non-repainting.
//   Confirmed Close OFF -> signal may appear intrabar and repaint until the
//                          HTF candle closes. Use for awareness only.
// =============================================================================
//@version=6
indicator(title = "The Island 4H MTF", shorttitle = "Island 4H Reversal", overlay = true, max_labels_count = 500)

// ====== INPUTS ======

i_tf = input.timeframe("240", "Signal Timeframe", group = "Timeframe")
i_confirmedClose = input.bool(true, "Show only on confirmed HTF close", group = "Timeframe", tooltip = "ON (recommended): triangle prints at the open of the bar AFTER the HTF candle closes. Fully non-repainting. OFF: may print intrabar and repaint until the HTF candle closes.")

i_confirmMode = input.string("Back inside prior range", "Close Confirmation", options = ["Back inside prior range", "Beyond prior close", "Both"], group = "Signal Logic")
i_requireBody = input.bool(true, "Require bullish/bearish candle body", group = "Signal Logic")
i_requireCloseLoc = input.bool(false, "Require close in top/bottom % of range", group = "Signal Logic")
i_closeLocPct = input.float(50.0, "Close Location % of Range", minval = 0.0, maxval = 100.0, step = 1.0, group = "Signal Logic")
i_minSweepTicks = input.float(0.0, "Minimum sweep depth (ticks)", minval = 0.0, step = 1.0, group = "Signal Logic")

i_buyColor = input.color(#26A69A, "Buy Triangle Color", group = "Appearance")
i_sellColor = input.color(#EF5350, "Sell Triangle Color", group = "Appearance")
i_triSize = input.string("small", "Triangle Size", options = ["tiny", "small", "normal", "large"], group = "Appearance")
i_showLabels = input.bool(false, "Show BUY / SELL text labels", group = "Appearance")
i_showLevels = input.bool(false, "Show prior HTF high / low levels", group = "Appearance")

// ====== HTF SIGNAL FUNCTIONS ======

f_buySignal() =>
    sweptLow = low < low[1]
    depthOk = (low[1] - low) >= i_minSweepTicks * syminfo.mintick
    bodyOk = not i_requireBody or close > open
    barRange = high - low
    locRatio = barRange > 0 ? (close - low) / barRange : 0.0
    locOk = not i_requireCloseLoc or locRatio >= (1.0 - i_closeLocPct / 100.0)
    backInside = close > low[1]
    beyondClose = close > close[1]
    confirmOk = switch i_confirmMode
        "Back inside prior range" => backInside
        "Beyond prior close"      => beyondClose
        =>                           backInside and beyondClose
    sweptLow and depthOk and bodyOk and locOk and confirmOk

f_sellSignal() =>
    sweptHigh = high > high[1]
    depthOk = (high - high[1]) >= i_minSweepTicks * syminfo.mintick
    bodyOk = not i_requireBody or close < open
    barRange = high - low
    locRatio = barRange > 0 ? (close - low) / barRange : 1.0
    locOk = not i_requireCloseLoc or locRatio <= (i_closeLocPct / 100.0)
    backInside = close < high[1]
    beyondClose = close < close[1]
    confirmOk = switch i_confirmMode
        "Back inside prior range" => backInside
        "Beyond prior close"      => beyondClose
        =>                           backInside and beyondClose
    sweptHigh and depthOk and bodyOk and locOk and confirmOk

// ====== HTF DATA ======

[htfTime, htfPrevHigh, htfPrevLow, htfRawBuy, htfRawSell] = request.security(syminfo.tickerid, i_tf, [time, high[1], low[1], f_buySignal() ? 1 : 0, f_sellSignal() ? 1 : 0], lookahead = barmerge.lookahead_off)

// ====== SIGNAL GATING ======

bool isNewHtfBar = na(htfTime[1]) ? false : htfTime != htfTime[1]
bool rawBuyNow   = nz(htfRawBuy) == 1
bool rawSellNow  = nz(htfRawSell) == 1
bool rawBuyPrev  = nz(htfRawBuy[1]) == 1
bool rawSellPrev = nz(htfRawSell[1]) == 1
bool buySignal   = i_confirmedClose ? (isNewHtfBar and rawBuyPrev)  : rawBuyNow
bool sellSignal  = i_confirmedClose ? (isNewHtfBar and rawSellPrev) : rawSellNow

// ====== TIMEFRAME WARNING ======

int chartTfSecs  = timeframe.in_seconds(timeframe.period)
int signalTfSecs = timeframe.in_seconds(i_tf)
bool tfWarning   = chartTfSecs > signalTfSecs

if tfWarning and barstate.islast
    label.new(bar_index, high, text = "⚠ Chart TF (" + timeframe.period + ") is higher than Signal TF (" + i_tf + "). Signals may be unreliable.", style = label.style_label_left, color = color.orange, textcolor = color.white, size = size.small)

// ====== PLOTTING ======

plotshape(buySignal and i_triSize == "tiny",   title = "Buy (tiny)",   style = shape.triangleup,   location = location.belowbar, color = i_buyColor,  size = size.tiny)
plotshape(buySignal and i_triSize == "small",  title = "Buy (small)",  style = shape.triangleup,   location = location.belowbar, color = i_buyColor,  size = size.small)
plotshape(buySignal and i_triSize == "normal", title = "Buy (normal)", style = shape.triangleup,   location = location.belowbar, color = i_buyColor,  size = size.normal)
plotshape(buySignal and i_triSize == "large",  title = "Buy (large)",  style = shape.triangleup,   location = location.belowbar, color = i_buyColor,  size = size.large)

plotshape(sellSignal and i_triSize == "tiny",   title = "Sell (tiny)",   style = shape.triangledown, location = location.abovebar, color = i_sellColor, size = size.tiny)
plotshape(sellSignal and i_triSize == "small",  title = "Sell (small)",  style = shape.triangledown, location = location.abovebar, color = i_sellColor, size = size.small)
plotshape(sellSignal and i_triSize == "normal", title = "Sell (normal)", style = shape.triangledown, location = location.abovebar, color = i_sellColor, size = size.normal)
plotshape(sellSignal and i_triSize == "large",  title = "Sell (large)",  style = shape.triangledown, location = location.abovebar, color = i_sellColor, size = size.large)


if i_showLabels and buySignal
    label.new(bar_index, low,  text = "BUY",  style = label.style_label_up,   color = i_buyColor,  textcolor = color.white, size = size.small, yloc = yloc.belowbar)

if i_showLabels and sellSignal
    label.new(bar_index, high, text = "SELL", style = label.style_label_down, color = i_sellColor, textcolor = color.white, size = size.small, yloc = yloc.abovebar)

plot(i_showLevels ? htfPrevHigh : na, title = "Prior HTF High", color = color.new(color.gray, 50), style = plot.style_stepline, linewidth = 1)
plot(i_showLevels ? htfPrevLow  : na, title = "Prior HTF Low",  color = color.new(color.gray, 50), style = plot.style_stepline, linewidth = 1)

// ====== ALERTS ======

alertcondition(buySignal,  title = "4H Sweep Buy",  message = "{{ticker}} @ {{close}} — HTF candle swept the prior low and closed higher (4H Sweep Reversal Buy).")
alertcondition(sellSignal, title = "4H Sweep Sell", message = "{{ticker}} @ {{close}} — HTF candle swept the prior high and closed lower (4H Sweep Reversal Sell).")

if buySignal
    alert("BUY — " + syminfo.ticker + " swept prior HTF low and closed higher. Close: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

if sellSignal
    alert("SELL — " + syminfo.ticker + " swept prior HTF high and closed lower. Close: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
````
