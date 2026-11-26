Calculation: Protected candle range = max(high - low, minimum price increment)
Calculation: Synthetic volume delta = volume * unit-clamp(impulse body weight * (close - open) / protected candle range + impulse close-location weight * ((close - low) - (high - close)) / protected candle range) * (minimum body factor + body-ratio weight * clamp(abs(close - open) / protected candle range, 0, 1))
Calculation: Session VWAP = cumulative(volume * HLC3) / cumulative(volume), reset at the start of the configured session and held outside it
Calculation: Raw session sigma = sqrt(max(cumulative(volume * HLC3^2) / cumulative(volume) - session VWAP^2, 0)), with cumulative values reset at the start of the configured session and held outside it
Calculation: Safe session sigma = max(EMA(raw session sigma, sigma smoothing length), ATR fallback multiplier * safe ATR), floored at the minimum price increment
Calculation: Safe ATR = max(ATR(ATR lookback), minimum price increment)
Calculation: Sigma position = unit-clamp((close - session VWAP) / max(safe session sigma * sigma-position scale, minimum price increment))
Calculation: Wick skew = (lower wick - upper wick) / protected candle range
Calculation: Volume ratio = volume / max(SMA(volume, volume baseline length), minimum volume denominator), using current volume if the SMA is unavailable
Calculation: Session CVD = cumulative synthetic volume delta during the configured session, reset to the current synthetic volume delta at session start and held outside the session
Calculation: CVD signal = EMA(session CVD, max(delta smoothing length * CVD-signal period multiplier, minimum EMA length))
Calculation: CVD pulse = unit-clamp((session CVD - CVD signal) / max(EMA(abs(session CVD - CVD signal), volume baseline length), minimum CVD denominator))
Calculation: Delta bias = unit-clamp(((synthetic volume delta - EMA(synthetic volume delta, delta smoothing length)) / max(STDEV(synthetic volume delta, delta smoothing length), minimum delta deviation)) / delta normalization scale)
Calculation: VWAP bias = unit-clamp((close - session VWAP) / max(safe ATR * VWAP normalization multiplier, minimum price increment))
Calculation: Structure bias = positive sweep value for a bullish sweep, negative sweep value for a bearish sweep, or zero otherwise
Calculation: Absorption bias = positive absorption value for bullish absorption, negative absorption value for bearish absorption, or zero otherwise
Calculation: Volume bias = unit-clamp((volume ratio - volume baseline offset) / volume normalization scale)
Calculation: Session bias = configured in-session value during the configured session and configured out-of-session value otherwise
Calculation: Directional confidence = clamp(confidence baseline + VWAP-bias weight * VWAP bias + delta-bias weight * delta bias + CVD-bias weight * CVD pulse + structure-bias weight * structure bias + absorption-bias weight * absorption bias + volume-bias weight * volume bias + session-bias weight * session bias, 0, 100)
Calculation: Direction blend = VWAP-bias blend weight * VWAP bias + delta-bias blend weight * delta bias + CVD-bias blend weight * CVD pulse + structure-bias blend weight * structure bias + absorption-bias blend weight * absorption bias
Long: Current bar is confirmed AND low < most recent confirmed PivotLow(low, pivot length, pivot length) AND close > that pivot low AND close > open
Short: Current bar is confirmed AND high > most recent confirmed PivotHigh(high, pivot length, pivot length) AND close < that pivot high AND close < open
Long: Current bar is confirmed AND volume ratio >= volume-spike multiplier AND clamp(1 - protected candle range / max(safe ATR * absorption range ceiling, minimum price increment), 0, 1) > absorption compactness threshold AND (close - low) / protected candle range >= bullish absorption close-bias threshold AND synthetic volume delta > 0
Short: Current bar is confirmed AND volume ratio >= volume-spike multiplier AND clamp(1 - protected candle range / max(safe ATR * absorption range ceiling, minimum price increment), 0, 1) > absorption compactness threshold AND (close - low) / protected candle range <= bearish absorption close-bias threshold AND synthetic volume delta < 0
Long: Bullish sweep AND wick skew > wick-rejection threshold AND close > session VWAP
Short: Bearish sweep AND wick skew < -wick-rejection threshold AND close < session VWAP
Long: Direction blend >= 0
Short: Direction blend < 0
Long: Direction blend > direction-control threshold
Short: Direction blend < -direction-control threshold
Long: Session CVD > session CVD[1]
Short: Session CVD < session CVD[1]
Long: close > session VWAP
Short: close < session VWAP
Long: Directional confidence >= background-confidence threshold AND close > session VWAP
Short: Directional confidence >= background-confidence threshold AND close < session VWAP
Long: Current bar is confirmed AND more than the signal-cooldown bars have elapsed since either ledger signal (or no ledger signal has occurred) AND directional confidence >= entry-confidence threshold AND session VWAP is available AND close > session VWAP AND synthetic volume delta > EMA(synthetic volume delta, delta smoothing length) AND session CVD >= CVD signal AND sigma position > -sigma-context threshold AND no bearish sweep AND (bullish reclaim OR bullish absorption OR close < session VWAP + safe session sigma * one-sigma multiplier)
Short: Current bar is confirmed AND more than the signal-cooldown bars have elapsed since either ledger signal (or no ledger signal has occurred) AND directional confidence >= entry-confidence threshold AND session VWAP is available AND close < session VWAP AND synthetic volume delta < EMA(synthetic volume delta, delta smoothing length) AND session CVD <= CVD signal AND sigma position < sigma-context threshold AND no bullish sweep AND (bearish reclaim OR bearish absorption OR close > session VWAP - safe session sigma * one-sigma multiplier)
Calculation: Long stop level = min(entry-signal-bar low, session VWAP at entry - safe session sigma at entry * outer-sigma multiplier) - safe ATR at entry * stop-padding multiplier
Calculation: Short stop level = max(entry-signal-bar high, session VWAP at entry + safe session sigma at entry * outer-sigma multiplier) + safe ATR at entry * stop-padding multiplier
Calculation: Risk unit = max(abs(entry price - stop level for the position side), safe ATR at entry * minimum-risk ATR multiplier)
Calculation: Third target price = entry price + position side * risk unit * third-target risk multiple
Exit: long, Current bar is confirmed AND trade-map display is enabled AND a long planned trade is active AND (low <= long stop level OR high >= third target price)
Exit: short, Current bar is confirmed AND trade-map display is enabled AND a short planned trade is active AND (high >= short stop level OR low <= third target price)