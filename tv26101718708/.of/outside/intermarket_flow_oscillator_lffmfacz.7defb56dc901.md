Decide long, short or exit on the traded instrument from a risk-on versus risk-off capital-flow oscillator built from two other instruments: a risk asset (equity index futures) and a safe-haven asset (government bond futures). Both are sampled on the chart's timeframe using close prices. If a close is missing or non-positive, substitute 1 so the ratio stays defined.

Oscillator construction, evaluated each bar:
1. Spread = natural log of (risk close / safe close).
2. Z-score = (spread minus its rolling simple mean over a lookback window) divided by its rolling standard deviation over the same window. If the standard deviation is zero, the z-score is 0.
3. Smooth the z-score with Ehlers' 2-pole SuperSmoother, with cutoff length = max(2, smoothing period). Let a = exp(-sqrt(2)*pi/L), b = 2*a*cos(sqrt(2)*pi/L), c2 = b, c3 = -a^2, c1 = 1 - c2 - c3. Then smoothed[t] = c1*(z[t] + z[t-1])/2 + c2*smoothed[t-1] + c3*smoothed[t-2]. Where history is unavailable, seed with the current z-score.
4. Velocity = smoothed[t] minus smoothed[t-1], with 0 on the first bar.

Signals:
- Bullish apex (long entry): the smoothed oscillator is below minus X standard deviations (X is an extreme threshold) on the bar where velocity crosses from non-positive to positive. This marks exhausted risk-off selling, so go long the traded instrument.
- Bearish apex (exit longs / short entry): the smoothed oscillator is above plus X on the bar where velocity crosses from non-negative to negative. This marks exhausted risk-on euphoria, so close longs and optionally go short.
- Regime filter or alternative trend signal: the smoothed oscillator crossing above zero means a risk-on regime, so favor or enter long. Crossing below zero means a risk-off regime, so favor short or flat, and exit longs. While the oscillator stays above zero, hold a long bias. While it stays below zero, hold a short or flat bias.

Signals are evaluated on bar close. Apex signals are mean-reversion counter-trend entries at extremes, and zero-line crosses are trend-following regime shifts.