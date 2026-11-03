Calculation: Session membership = whether the current lower-timeframe bar's opening time is within the configured trade session.
Calculation: Session open = open of the first bar when session membership begins.
Calculation: Breakout distance = a percentage of the ATR from the last completed higher-timeframe daily bar.
Long: Session membership AND flat position AND (high crosses above session open + breakout distance OR the session open changes and high > session open + breakout distance)
Short: Session membership AND flat position AND (low crosses below session open - breakout distance OR the session open changes and low < session open - breakout distance)
Exit: long, high >= entry price + take-profit distance in ticks OR low <= entry price - stop-loss distance in ticks OR (trailing stop enabled AND high has reached entry price + activation distance AND low <= highest high since entry - trailing offset)
Exit: short, low <= entry price - take-profit distance in ticks OR high >= entry price + stop-loss distance in ticks OR (trailing stop enabled AND low has reached entry price - activation distance AND high >= lowest low since entry + trailing offset)
Exit: long or short, end-of-session close enabled AND session membership is false