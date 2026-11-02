Calculation: Daily VWAP = cumulative sum of ((open + high + low + close) / 4) × volume divided by cumulative volume, resetting at the start of each day in the specified timezone.
Calculation: Bar volume delta = sum of volume on completed lower-timeframe bars within the chart bar where close > open minus sum of volume on those where close < open; equal open and close contribute zero.
Calculation: Daily CVD = cumulative bar volume delta since the daily reset. Session CVD = cumulative bar volume delta during each specified session, reset at the daily reset and at that session's start; retain its last value outside the session. Active session CVD = the session CVD selected by the specified session priority, or unavailable outside all sessions.
Calculation: Swing levels = latest confirmed pivot high and low of the requested-timeframe Heikin Ashi high and low series, using equal numbers of chart bars on each side of the pivot. The requested timeframe may be higher or lower than the chart timeframe; on historical bars use the last completed higher-timeframe bar or the last lower-timeframe bar within the chart bar. Replace a level when a new pivot is confirmed and clear it after its corresponding break.
Calculation: Structure events = on each bar, set the high-sweep flag when high > swing high AND close < swing high, and set the low-sweep flag when low < swing low AND close > swing low. A bullish break occurs when close > swing high AND previous close <= that same swing high; a bearish break occurs when close < swing low AND previous close >= that same swing low. A bullish break with the low-sweep flag is bullish CHoCH, otherwise bullish BOS; a bearish break with the high-sweep flag is bearish CHoCH, otherwise bearish BOS. After bullish CHoCH clear the low-sweep flag and set the high-sweep flag; after bearish CHoCH clear the high-sweep flag and set the low-sweep flag. Evaluate the events before applying these CHoCH updates.
Calculation: Momentum score = average over a lookback of signed candle scores. Each candle score is direction × abs(close - open) / (high - low) × close conviction, where direction is positive when close >= open and negative otherwise, and close conviction is (close - low) / (high - low) for a nonnegative candle and (high - close) / (high - low) otherwise. A zero-range candle has score zero.
Calculation: VWAP rate of change = 100 × (daily VWAP - daily VWAP at the rate-of-change lookback) / daily VWAP at that lookback. It is valid only when at least that many chart bars have elapsed since the daily reset.
Calculation: EMA spread ratio = abs(shorter-period close EMA - longer-period close EMA) / ATR, or zero when ATR is not positive.
Calculation: Pullback setup = a bullish structure break with close > daily VWAP starts or restarts a bullish setup; a bearish break with close <= daily VWAP starts or restarts a bearish setup. Any opposite structure break cancels the setup regardless of VWAP. A setup expires after a longer maximum age, or after a shorter maximum age if no opposite-direction Heikin Ashi candle has yet appeared. A bullish setup records a Heikin Ashi close < open; a bearish setup records a Heikin Ashi close > open. A matching entry clears its setup. Heikin Ashi candles here use the chart timeframe.
Long: close > daily VWAP
Short: close <= daily VWAP
Long: daily CVD >= 0 OR any session CVD >= 0
Short: daily CVD < 0 OR any session CVD < 0
Long: close > daily VWAP AND any session CVD > 0
Short: close <= daily VWAP AND any session CVD < 0
Long: chart-timeframe Heikin Ashi close >= Heikin Ashi open
Short: chart-timeframe Heikin Ashi close < Heikin Ashi open
Long: momentum score >= positive momentum threshold
Short: momentum score <= negative momentum threshold
Long: bullish CHoCH OR bullish BOS
Short: bearish CHoCH OR bearish BOS
Long: low < swing low AND close > swing low AND close > daily VWAP
Short: high > swing high AND close < swing high AND close <= daily VWAP
Long: bullish structure break AND at least one prior chart candle within the order-block lookback has close < open
Short: bearish structure break AND at least one prior chart candle within the order-block lookback has close > open
Long: VWAP rate of change is valid AND crosses above either of two positive thresholds, one higher than the other
Short: VWAP rate of change is valid AND crosses below either of two negative thresholds, one with a larger absolute magnitude than the other
Long: shorter-period close EMA > longer-period close EMA AND no bearish VWAP rate-of-change cross of the lower-magnitude threshold on the current or either of the two preceding chart bars AND no bullish VWAP rate-of-change cross of that threshold on those bars
Short: shorter-period close EMA <= longer-period close EMA AND no bearish VWAP rate-of-change cross of the lower-magnitude threshold on the current or either of the two preceding chart bars AND no bullish VWAP rate-of-change cross of that threshold on those bars
Long: EMA spread ratio crosses above the momentum-start threshold AND shorter-period close EMA > longer-period close EMA
Short: EMA spread ratio crosses above the momentum-start threshold AND shorter-period close EMA < longer-period close EMA
Long: bullish pullback setup is active AND its opposite-direction Heikin Ashi candle has been recorded AND chart-timeframe Heikin Ashi close > open AND close > daily VWAP AND active session CVD > previous bar's active session CVD AND high > low AND abs(close - open) / (high - low) >= entry body threshold
Short: bearish pullback setup is active AND its opposite-direction Heikin Ashi candle has been recorded AND chart-timeframe Heikin Ashi close < open AND close <= daily VWAP AND active session CVD < previous bar's active session CVD AND high > low AND abs(close - open) / (high - low) >= entry body threshold
Exit: long, EMA spread ratio crosses below the momentum-end threshold AND the latest momentum-start event was bullish AND no momentum-end event has occurred since it
Exit: short, EMA spread ratio crosses below the momentum-end threshold AND the latest momentum-start event was bearish AND no momentum-end event has occurred since it