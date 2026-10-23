Every rule below is a touch of a zone's price band, read as support or resistance. Zone edges come from pivots and range extremes; the entry is a touch of the zone's edge, whatever the pivot or range type. Every zone is rebuilt as each new bar arrives.

Pivots: a pivot high is a bar whose high is the highest of the N bars before it and the N bars after it. A pivot low is the mirror image with lows. A pivot is confirmed N bars after it forms. N is chosen by the user. Typical values are 2 to 5 for scalping, 5 to 10 for intraday and 10 to 20 for swing. H is the latest pivot high price and L is the latest pivot low price. Use a pivot pair only when both exist and H > L. Range = H - L.

Bull GP (pullback support, long): rebuilt on the bar a new pivot high is confirmed. Top = H - Range*0.65. Bottom = H - Range*0.707. It stays anchored to its pivot pair until the next pivot high.
Bear GP (rally resistance, short): rebuilt on the bar a new pivot low is confirmed. Bottom = L + Range*0.65. Top = L + Range*0.707. It stays anchored to its pivot pair until the next pivot low.

Quick GP (alternative with no pivots): over the last M bars (20 to 50), take HH = highest high and LL = lowest low, and Range = HH - LL. The bull GP is Top = HH - Range*0.65, Bottom = HH - Range*0.707. The bear GP is Bottom = LL + Range*0.65, Top = LL + Range*0.707. Both are rebuilt every bar.

GP touch (entry): the bar's low drops to or below the zone's top while the previous bar's low was above the zone's top, or the bar's high rises to or above the zone's bottom while the previous bar's high was below the zone's bottom. For a bull GP the touch means a long. For a bear GP the touch means a short.

GP extension (target zone): bull extension is Bottom = H + Range*0.65, Top = H + Range*0.707, above the high. Bear extension is Top = L - Range*0.65, Bottom = L - Range*0.707, below the low. Touching the bull extension means a short or taking profit on a long. Touching the bear extension means a long or taking profit on a short. Use the same touch test as above. The bull extension counts as reached when the bar's high >= its bottom. The bear extension counts as reached when the bar's low <= its top.

GP invalidation (exit): a bull GP is dropped when the open (or close) is below the zone's bottom for 3 consecutive bars. A bear GP is dropped when the open (or close) is above the zone's top for 3 consecutive bars. The counter resets to 0 on any bar that does not break the zone. A dropped bull GP means exit longs. A dropped bear GP means exit shorts. When a bull GP is dropped, also remove its extension.

Out-of-play filter: a bull GP with close < its bottom is out of play, so skip longs from it. A bear GP with close > its top is out of play, so skip shorts from it.

Demand and Supply zones:
- ATR = a 14-bar Wilder average of true range. True range = max(high-low, |high-prev close|, |low-prev close|). Body = |close-open|.
- Impulse up: body > ATR*1.0, close > open, and close > the highest high of the previous 10 bars (not counting the current bar; use 5 bars for scalping).
- Impulse down: body > ATR*1.0, close < open, and close < the lowest low of the previous 10 bars.
- Demand zone: on an impulse up, search back j = 1 to 10 for the nearest bar with close < open. The zone is that bar's high (top) to its low (bottom). Cap the height at ATR*1.5 to 2 by raising the bottom. Merge it with an existing demand zone when the overlap is at least 50% of the smaller height. Remove any supply zone that overlaps the new demand zone by more than 50% of the smaller height.
- Supply zone: on an impulse down, search back j = 1 to 10 for the nearest bar with close > open. The zone is that bar's high (top) to its low (bottom). Cap the height at ATR*1.5 to 2 by lowering the top. Merge and cross-remove in the same way, with demand zones as the ones removed.
- Demand touch means a long: low <= top and previous low > top. Supply touch means a short: high >= bottom and previous high < bottom.
- Zone removal: remove a demand zone when close < its bottom. Remove a supply zone when close > its top. This also serves as the exit for that side. Each zone is retested up to 3 times. A retest counts when the low (demand) or high (supply) enters the zone after price first moved fully outside it. Each retest shrinks the zone by 1/3 of its height from the tested edge. Remove the zone on the 3rd retest. Keep at most 3 to 5 zones per side and drop the oldest.

FVG (optional): a bullish FVG forms when low > the high from 2 bars ago and the gap >= 0.3*ATR. Its zone runs from high[2] (bottom) to low (top). A bearish FVG forms when high < the low from 2 bars ago and the gap >= 0.3*ATR. Its zone runs from high (bottom) to low[2] (top). Use the same touch test as the other zones. A bull FVG touch means a long and a bear FVG touch means a short. Remove a bull FVG when low <= its bottom, and a bear FVG when high >= its top.

MA filter (optional, off by default): fast = EMA(9) of close, slow = EMA(21) of close. Trend direction mode: with trend, allow bull GPs only when fast > fast[1] and bear GPs only when fast < fast[1]. In both-lines mode, bull needs fast > slow and bear needs fast < slow. The against-trend setting flips this. Price position mode: a bull GP is only built when both H and L are above the fast MA. In both-lines mode, also require fast > slow. A bear GP needs H and L below the fast MA. In both-lines mode, also require fast < slow.

Volume mark: a zone whose originating bar has volume above SMA(volume, 21) is marked as high-volume. In supply/demand cross-removal, a high-volume zone is not removed by a new opposing zone that is not high-volume.

Confluence: where two or more zones overlap in price (their tops and bottoms intersect), the overlap band is a higher-probability area. A touch of that band is read in the direction of the zones involved, long for bull GP or demand, short for bear GP or supply.