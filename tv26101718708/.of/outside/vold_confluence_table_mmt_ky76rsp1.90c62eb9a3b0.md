Market-internals bias framework that decides long, short, or flat on an index or instrument from three external breadth series. (1) VOLD, net up-volume minus down-volume across the exchange, read on a separate higher confirmation timeframe. (2) ADD, advancing minus declining issues, read on the chart timeframe. (3) TICK, stocks ticking up minus down, read on the chart timeframe. Use the latest closed value of each.

Bull score (0-6), one point for each true condition: VOLD > 0; VOLD above a strong positive level; ADD > 0; ADD above a strong positive level; TICK > 0; TICK above a positive warning level. Bear score (0-6) mirrors this: VOLD < 0; VOLD below a strong negative level; ADD <= 0; ADD below a strong negative level; TICK <= 0; TICK below a negative warning level.

Freight-train filter: compute a simple moving average of the higher-timeframe VOLD. Freight-bull is true when VOLD is above its average, is higher than its previous value, and is above the strong positive level. Freight-bull forbids shorts. Freight-bear is true when VOLD is not above its average, is lower than its previous value, and is below the strong negative level. Freight-bear forbids longs.

Divergence: ADD positive while VOLD negative (up-divergence), or ADD non-positive while VOLD positive (down-divergence).

Decision priority, evaluated in order each bar:
1. Trend day: if bull score >= 5, go or stay long unless freight-bear is active. If bear score >= 5, go or stay short unless freight-bull is active.
2. High confidence: if bull score == 4, long (same freight-bear veto). If bear score == 4, short (same freight-bull veto).
3. Divergence, when neither case above applies: take no new entries. If already positioned, reduce, take partials, or exit.
4. Chop: if both bull score and bear score are below 3, stay flat with no new entries and exit existing positions.
5. Otherwise neutral: no new entries. The side of VOLD relative to its average gives only a weak lean (above = long lean, below = short lean) and is not an entry trigger.

Exit: close a long when the long condition no longer holds (bull score falls below 4, freight-bear becomes active, or divergence or chop appears). Close a short symmetrically (bear score falls below 4, freight-bull becomes active, or divergence or chop appears). A flip to the opposite side's qualifying condition reverses the position.