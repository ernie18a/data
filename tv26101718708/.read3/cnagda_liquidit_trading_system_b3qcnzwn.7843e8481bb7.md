Calculation: Swing bias = on each newly confirmed PivotLow(low, swing-strength parameter, swing-strength parameter), compare its value with the preceding confirmed pivot low; set bullish if higher and bearish otherwise; then apply the same comparison to each newly confirmed PivotHigh(high, swing-strength parameter, swing-strength parameter), with the high update last if both confirm on one chart bar; leave unchanged when the preceding same-kind pivot is absent.
Calculation: Small candle body = abs(close - open) < (high - low) × small-body-to-range parameter.
Calculation: High-volume confirmation = volume > SMA(volume, shorter volume-average lookback) × high-volume multiplier.
Calculation: Advanced bullish liquidity grab = low < most recent confirmed pivot low AND close > that pivot low AND (that pivot low - low) > abs(open - close) × wick-to-body multiplier AND Small candle body AND High-volume confirmation.
Calculation: Advanced bearish liquidity grab = high > most recent confirmed pivot high AND close < that pivot high AND (high - that pivot high) > abs(open - close) × wick-to-body multiplier AND Small candle body AND High-volume confirmation.
Calculation: Effective bullish engulfing = close > open AND prior close < prior open AND close > prior open AND open < prior close AND (a confirmed PivotLow(low, swing-strength parameter, swing-strength parameter) occurs on this chart bar OR sufficient trend-lookback history exists AND close > prior close).
Calculation: Effective bearish engulfing = close < open AND prior close > prior open AND close < prior open AND open > prior close AND (a confirmed PivotHigh(high, swing-strength parameter, swing-strength parameter) occurs on this chart bar OR sufficient trend-lookback history exists AND close < prior close).
Calculation: Bullish iceberg proxy = volume > SMA(volume, longer volume-average lookback) × iceberg volume multiplier AND high > low AND abs(close - open) / (high - low) < iceberg body-to-range parameter AND close > open.
Calculation: Bearish iceberg proxy = volume > SMA(volume, longer volume-average lookback) × iceberg volume multiplier AND high > low AND abs(close - open) / (high - low) < iceberg body-to-range parameter AND close < open.
Calculation: Session-volume confirmation = volume > the sum of chart-bar volume since the current T1 interval began × participation fraction.
Calculation: Configured chart VWAP = VWAP(close) in the configured session or cumulative mode.
Calculation: Higher-timeframe VWAP = VWAP(close) calculated on T2 bars and sampled on chart bars with lookahead off; the current T2 bar may be forming in realtime, and historical values finalize at T2 close.
Calculation: Bullish price alignment = close > Configured chart VWAP AND close > SMA(close, TWAP lookback) AND close > Higher-timeframe VWAP.
Calculation: Bearish price alignment = close < Configured chart VWAP AND close < SMA(close, TWAP lookback) AND close < Higher-timeframe VWAP.
Calculation: Pool tolerance = ATR(longer pool-tolerance lookback) × pool ATR multiplier when ATR tolerance mode is enabled; otherwise the configured percentage of close.
Calculation: Active liquidity pools = when pool detection is enabled, each BSL is the midpoint of consecutive confirmed PivotHigh(high, swing-strength parameter, swing-strength parameter) values within pool tolerance and separated by at least the minimum pivot gap; each SSL is defined analogously from consecutive confirmed pivot lows; retain at most the pool-history limit per side; deactivate a BSL when close > its level + pool tolerance and an SSL when close < its level - pool tolerance.
Calculation: Nearest active BSL = active BSL level with the smallest absolute distance from close.
Calculation: Nearest active SSL = active SSL level with the smallest absolute distance from close.
Calculation: Bullish Smart Money Flow reversal candle = close > open AND open - low > abs(open - close) × Smart Money wick-to-body multiplier AND High-volume confirmation.
Calculation: Bearish Smart Money Flow reversal candle = close < open AND high - close > abs(open - close) × Smart Money wick-to-body multiplier AND High-volume confirmation.
Calculation: Bullish signal score = count of true conditions among bullish price alignment, Advanced bullish liquidity grab, Bullish iceberg proxy, and Effective bullish engulfing.
Calculation: Bearish signal score = count of true conditions among bearish price alignment, Advanced bearish liquidity grab, Bearish iceberg proxy, and Effective bearish engulfing.
Calculation: Accepted bullish lite signal = Bullish signal score > Bearish signal score now AND Bullish signal score ≤ Bearish signal score on the prior chart bar AND the Accumulation/Distribution Line rises on the current chart bar.
Calculation: Accepted bearish lite signal = Bearish signal score > Bullish signal score now AND Bearish signal score ≤ Bullish signal score on the prior chart bar AND the Accumulation/Distribution Line falls on the current chart bar.
Calculation: Global signal bias = direction occurring more often among the most recent signal-history-length accepted bullish and bearish lite signals; neutral when counts are equal or there are no signals.
Long: Swing bias is bullish.
Short: Swing bias is bearish.
Long: Advanced bullish liquidity grab.
Short: Advanced bearish liquidity grab.
Long: Effective bullish engulfing.
Short: Effective bearish engulfing.
Long: (high - low) > abs(open - close) × hammer range-to-body multiplier AND (close - low) / (high - low + range epsilon) > candle-position parameter AND (open - low) / (high - low + range epsilon) > candle-position parameter AND prior bar range > ATR(hammer lookback).
Short: (high - low) > abs(open - close) × star range-to-body multiplier AND (high - close) / (high - low + range epsilon) > candle-position parameter AND (high - open) / (high - low + range epsilon) > candle-position parameter AND (a confirmed PivotHigh(high, swing-strength parameter, swing-strength parameter) occurs on this chart bar OR sufficient trend-lookback history exists AND prior close > close).
Short: (high - low) > abs(open - close) × hanging-man range-to-body multiplier AND (close - low) / (high - low + range epsilon) > candle-position parameter AND (open - low) / (high - low + range epsilon) > candle-position parameter AND (a confirmed PivotHigh(high, swing-strength parameter, swing-strength parameter) occurs on this chart bar OR sufficient trend-lookback history exists AND prior close > close).
Long: Bullish iceberg proxy.
Short: Bearish iceberg proxy.
Long: Nearest active SSL exists AND abs(close - Nearest active SSL) < ATR(shorter reversal-distance lookback) × reversal-distance multiplier AND Bullish Smart Money Flow reversal candle.
Short: Nearest active BSL exists AND abs(close - Nearest active BSL) < ATR(shorter reversal-distance lookback) × reversal-distance multiplier AND Bearish Smart Money Flow reversal candle.
Long: Advanced bullish liquidity grab AND Effective bullish engulfing AND Session-volume confirmation AND Bullish iceberg proxy AND Bullish price alignment AND (bar-close confirmation is disabled OR the current chart bar is confirmed).
Short: Advanced bearish liquidity grab AND Effective bearish engulfing AND Session-volume confirmation AND Bearish iceberg proxy AND Bearish price alignment AND (bar-close confirmation is disabled OR the current chart bar is confirmed).
Long: Global signal bias changes to bullish.
Short: Global signal bias changes to bearish.
Exit: long, Global signal bias changes to neutral.
Exit: short, Global signal bias changes to neutral.