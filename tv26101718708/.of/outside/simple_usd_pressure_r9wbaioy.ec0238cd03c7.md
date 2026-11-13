Regime filter from outside USD-related instruments, mapped to a position on the traded instrument. The traded instrument is treated as USD-aligned, so invert the long/short mapping for instruments that move against the USD.

1. Direction vote per instrument: on completed bars only, on a chosen calculation timeframe, compare each instrument's latest close with its close a short number of bars earlier. Unchanged counts as 0.
- USD-bullish if the instrument rose: USDJPY, USDCHF, USDCAD, and optionally DXY and US10Y yield.
- USD-bullish if the instrument fell: EURUSD, GBPUSD, AUDUSD, NZDUSD, and optionally Gold and the SPX index (risk sentiment).
- The opposite move is a USD-bearish vote (-1).

2. Pair pressure: over the enabled major USD pairs, compute (bull votes - bear votes) / number of enabled pairs. The result is in [-1, 1].

3. Confirmation score: over the enabled confirming instruments (DXY and Gold by default; US10Y and SPX optional), compute (bull votes - bear votes) / number of enabled confirmers. If none are enabled, there is no confirmation score.

4. Composite: if any confirmers are enabled, take a weighted blend of the raw pair pressure and raw confirmation score, with pair pressure weighted clearly higher. Otherwise use the raw pair pressure alone. Smooth the blend with an exponential moving average.

5. Regime from the smoothed composite and a symmetric threshold between 0 and 1:
- composite >= +threshold: USD Strong, state +1.
- composite <= -threshold: USD Weak, state -1.
- otherwise: USD Mixed, state 0.

6. Trading decision, evaluated each completed bar:
- On a change into USD Strong, go long the USD-aligned instrument.
- On a change into USD Weak, go short it.
- On a change into USD Mixed, exit to flat.
- Hold the position while the regime is unchanged.