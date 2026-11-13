Directional bias framework for US equity-index instruments. It combines six signals, each clipped to -1..+1, into a composite. Two signals use outside data: a volatility index chosen to match the traded instrument (Nasdaq-family uses the Nasdaq vol index, Russell-family uses the Russell vol index, otherwise the S&P vol index) and the US Dollar Index.

Signals:
1. Price momentum: the close's change over a short lookback, divided by ATR times a scale factor.
2. Volatility-index slope: the vol index's change over a short lookback, sign-flipped and scaled. Falling implied vol is bullish and rising vol is bearish.
3. Volume flow: a running sum of bar volume, positive if the bar closed above its open and negative if below. It resets at each new day and decays each bar. It is normalized by a multiple of average volume.
4. Trend agreement: the slopes of a fast and a slow EMA of close over a short lookback, each normalized by ATR and clipped, then averaged. Disagreeing slopes pull the value toward zero.
5. Dollar pressure: the Dollar Index's change over a short lookback, sign-flipped and scaled. A rising dollar is bearish and a falling dollar is bullish.
6. Candle conviction: (close - open) / (high - low), multiplied by relative volume (volume / average volume, capped at 2), then clipped.

Composite: take the weighted average of the six signals, with equal weights by default. Smooth it with a short EMA and multiply by 100 to get a Pressure value in -100..+100. Optionally track Pressure's own per-bar slope as a momentum-of-pressure confirmation.

Decisions:
- Long (bullish bias): Pressure crosses from below to above zero. The conviction is stronger when Pressure crosses above +50.
- Short (bearish bias): Pressure crosses from above to below zero. The conviction is stronger when Pressure crosses below -50.
- Beyond +80 or -80 is an extreme reading. It means continuation or exhaustion, so use it as a warning or optional exit/fade filter rather than a standalone entry.
- Exit or flatten: when Pressure crosses back through zero against the held position, or optionally when the strong-level threshold is lost.