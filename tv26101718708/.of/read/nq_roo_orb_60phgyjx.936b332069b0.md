Calculation: OR High/OR Low = highest high / lowest low of bars from the session open until the opening-range window ends; the range is final only after that window has ended, and resets each session
Calculation: Prior-day High/Low/Close = high/low/close of the last completed daily bar (higher timeframe)
Calculation: Swing High/Low = confirmed pivot: a bar whose high (low) is the highest (lowest) among N bars on each side; only the most recent ~30 of each are kept
Calculation: Resistance Above = lowest level that is above the current close among {prior-day high, prior-day close, stored swing highs}; none if no such level
Calculation: Support Below = highest level that is below the current close among {prior-day low, prior-day close, stored swing lows}; none if no such level
Calculation: Body Ratio = abs(close - open) / (high - low), 0 if high == low
Calculation: Target Distance = fixed number of points; Stop Distance = fixed number of points or a multiple of ATR, smaller than Target Distance
Long: opening range is final AND bar is within an early-session signal window after the open AND close > OR High AND open > OR High AND Body Ratio >= minimum threshold AND volume > simple moving average of volume AND (Resistance Above is none OR Resistance Above - close >= Target Distance) AND no long signal has fired since close was last below OR High (re-arms when close < OR High and at each new session)
Short: opening range is final AND bar is within an early-session signal window after the open AND close < OR Low AND open < OR Low AND Body Ratio >= minimum threshold AND volume > simple moving average of volume AND (Support Below is none OR close - Support Below >= Target Distance) AND no short signal has fired since close was last above OR Low (re-arms when close > OR Low and at each new session)
Exit: long, high >= entry price + Target Distance OR low <= entry price - Stop Distance
Exit: short, low <= entry price - Target Distance OR high >= entry price + Stop Distance