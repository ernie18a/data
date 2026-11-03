Calculation: Filtered WVF washout = ((highest close over the WVF lookback − low) / highest close) × 100; fires when the prior value was at or above its upper volatility band or range threshold, the current value is below both, low > prior low, close > prior high and close > close over the strength lookback, and close < close over either the long-term or mid-term lookback.
Calculation: Bullish FVG = low − high from two bars earlier > 0 and the gap as a percentage of close meets the configured minimum.
Calculation: Signed volume = volume when close ≥ open, otherwise −volume.
Calculation: Bullish OBV slope = cumulative signed volume > its value at the longer lookback.
Calculation: Bullish DELTA = EMA of signed volume > 0.
Calculation: Bullish VIDYA posture = close > VIDYA; VIDYA uses the shorter length for its adaptive average and the longer length for its momentum-based adaptation factor.
Calculation: TQI = mean of (1) efficiency ratio, (2) ATR divided by its longer-term ATR average, scaled and clamped to [0,1], (3) close’s distance above a long-term SMA in ATR units, scaled and clamped to [0,1], and (4) percentage momentum scaled and clamped to [0,1].
Calculation: Confluence score = configured weights for bullish EMA alignment, bullish VIDYA posture, bullish OBV slope, armed bullish DELTA, armed bullish FVG when enabled, TQI at or above its threshold when enabled, and ATR percentile in the high band, minus the configured low-band ATR penalty.
Calculation: ATR percentile = percentile rank of ATR against its rolling lookback; high band begins at the higher configured cut and low band is below the lower configured cut.
Calculation: Entry tier = 0 if WVF gate fails or score is below the BASE floor; otherwise BASE if below the SCALE floor, SCALE if at or above that floor with ADX at or above the FULL threshold, or FULL if at or above that floor with ADX below the threshold. A recent BB lower-band close within the anti-signal window demotes a tier above BASE by one.
Calculation: Bollinger lower band = SMA(close, lookback) − multiplier × standard deviation(close, lookback).
Calculation: WVF Top = the prior upper-wick volatility value was at or below its lower volatility band or range threshold, and the current value is above both; upper-wick volatility value = ((lowest close over the WVF lookback − high) / lowest close) × 100.
Calculation: CVI = (close − lowest low over lookback) / (highest high over lookback − lowest low over lookback); if the range is zero, use 0.5.
Calculation: Chart-timeframe Char-Flip = prior TQI > its upper threshold AND current TQI < its lower threshold.
Calculation: MBI bull/bear fire = smoothed directional momentum bias rolls over while above its volatility bound and greater than the opposite bias; bull uses downside bias, bear uses upside bias. Directional bias is computed from close change normalized by EMA of high−low, with positive and negative momentum accumulated separately.
Calculation: BBAWE long/short = EMA(close, shortest length) crosses above/below the Bollinger basis, close is above/below that basis, and the Awesome Oscillator is nonnegative and rising / negative and falling.
Calculation: Trend-panel direction per requested timeframe = +1 when chart close is above both that timeframe’s EMA and VWAP, −1 when below both, otherwise 0; add +0.5 for positive three-bar momentum or −0.5 for negative momentum, and add +0.5 when ATR exceeds its average. Direction is up if the total > 0.5 and down if < −0.5.
Long: On an enabled entry timeframe, entry tier > 0 AND entry tier differs from its prior value AND the configured entry delay has elapsed AND the TQI dead-zone exclusion does not apply AND (tier is not FULL OR BTC bull requirement is disabled OR BTC close > BTC EMA). Use the last completed bar when that timeframe is higher than the chart timeframe; use the timeframe’s forming bar when it is lower. By default, only the primary entry timeframe creates entries.
Long: Filtered WVF washout.
Long: Bullish FVG.
Long: Bullish MBI fire.
Long: BBAWE long condition.
Long: Chart-timeframe close > EMA(9) AND EMA(9) > its value five bars earlier.
Long: Chart close > chart-timeframe EMA(20) AND chart-timeframe VWAP AND chart close > chart close three bars earlier.
Short: MBI bear fire.
Short: BBAWE short condition.
Short: Chart-timeframe close < EMA(9) AND EMA(9) ≤ EMA(21) AND EMA(9) < its value five bars earlier.
Short: Chart close < chart-timeframe EMA(20) AND chart-timeframe VWAP AND chart close < chart close three bars earlier.
Exit: Long, close ≤ Bollinger lower band on any enabled signal timeframe OR WVF Top on any enabled signal timeframe OR CVI crosses from at/above its threshold to below it on any enabled signal timeframe; a single new exit type signals a half exit, while two distinct new exit types within the configured exit window signal a full exit. Ignore these exit pulses during the post-entry cooldown. For signal timeframes higher than the chart timeframe use the last completed bar; for lower timeframes use the forming bar.
Exit: Long, Chart-timeframe Char-Flip AND a position is active.
Exit: Long, any new exit pulse AND nearest unswept sell-side liquidity is within the configured ATR distance AND a position is active.