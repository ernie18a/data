Calculation: Estimated bar delta = volume * (high > low ? clamp(2 * (close - low) / (high - low) - 1, -1, 1) : 0)
Calculation: Relative volume = volume / max(volume floor, SMA(volume, volume-average lookback) if available, else volume)
Calculation: Session delta = sum of Estimated bar delta from the first bar of the current analysis session through the current bar, retained outside the session until the next session begins
Calculation: Flow score = clamp(session-delta weight * (session volume > 0 ? clamp(delta scale * Session delta / session volume, score lower bound, score upper bound) : 0) + momentum weight * clamp(momentum scale * (EMA(close, shorter lookback) - EMA(close, longer lookback)) / max(minimum price increment, ATR(ATR lookback)), score lower bound, score upper bound) + VWAP-distance weight * (session volume > 0 ? clamp(VWAP-distance scale * (close - VWAP(HLC3, analysis session)) / max(minimum price increment, ATR(ATR lookback)), score lower bound, score upper bound) : 0) + large-volume weight * clamp(large-volume count scale * (count of large-volume count lookback bars, including the current bar, where Relative volume >= large-volume multiple and Estimated bar delta > 0 - count of those bars where Estimated bar delta < 0), score lower bound, score upper bound), score lower bound, score upper bound), where session volume is the sum of volume from the current analysis session through the current bar
Long: EMA(close, shorter lookback) >= EMA(close, longer lookback)
Short: EMA(close, shorter lookback) < EMA(close, longer lookback)
Long: Session delta >= 0
Short: Session delta < 0
Long: in the analysis session AND Flow score >= strong-flow threshold
Short: in the analysis session AND Flow score <= negative strong-flow threshold
Long: in the analysis session AND Flow score crosses above strong-flow threshold
Short: in the analysis session AND Flow score crosses below negative strong-flow threshold