Calculation: HTF structure = bullish when the latest confirmed 3-left/3-right pivot low exists and the current value of the higher-timeframe low is above it; bearish when the latest confirmed 3-left/3-right pivot high exists and the current higher-timeframe high is below it. Use the last completed higher-timeframe bar.
Calculation: MTF structure = the same structure test on medium-timeframe bars. Use the last completed medium-timeframe bar.
Calculation: LTF structure = the same structure test on chart-timeframe bars.
Calculation: Alignment = all three structures are bullish, or all three are bearish.
Calculation: Consolidating = fewer than 3 of these 10 comparisons are true: high > prior high, prior high > high two bars ago, continuing the same adjacent-high comparison through five bars ago; low < prior low, prior low < low two bars ago, continuing the same adjacent-low comparison through five bars ago.
Calculation: Bullish rejection = candle range > 0 and (min(open, close) - low) / (high - low) >= 0.20.
Calculation: Bearish rejection = candle range > 0 and (high - max(open, close)) / (high - low) >= 0.20.
Calculation: Strong bullish candle = candle range > 0, close > open, and (close - open) / (high - low) >= 0.50.
Calculation: Strong bearish candle = candle range > 0, close < open, and (open - close) / (high - low) >= 0.50.
Calculation: Volume ratio = volume / 20-bar simple moving average of volume, or 0 when that average is not positive.
Calculation: Continuation = in a position, not consolidating, the current bar's pullback from the highest high (long) or lowest low (short) over the last 5 bars is at most 55% of that 5-bar high-low range, and close > prior high (long) or close < prior low (short); require a positive range.
Calculation: No-move exit condition = no continuation has occurred since entry, at least 8 bars have elapsed since entry, and (high - prior close) for a long or (prior close - low) for a short is less than 0.5 × 14-bar ATR.
Calculation: Failed-continuation exit condition = a continuation has occurred since entry and at least 8 bars have elapsed since the most recent continuation.
Calculation: Structure-break exit condition = a confirmed pivot low (pivot strength parameter bars on each side) exists and close is below it for a long, or a confirmed pivot high exists and close is above it for a short.
Long: flat, not consolidating, HTF structure bullish, Alignment bullish, prior bar has Bullish rejection, current bar has Strong bullish candle, and Volume ratio >= 0.6; OR in a long position and Continuation.
Short: flat, not consolidating, HTF structure bearish, Alignment bearish, prior bar has Bearish rejection, current bar has Strong bearish candle, and Volume ratio >= 0.6; OR in a short position and Continuation.
Exit: long, in a position, not consolidating, and (No-move exit condition OR Failed-continuation exit condition OR Structure-break exit condition).
Exit: short, in a position, not consolidating, and (No-move exit condition OR Failed-continuation exit condition OR Structure-break exit condition).