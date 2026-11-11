Calculation: Smoothed stochastic K = SMA of raw stochastic %K calculated from close, high and low; stochastic D = SMA of smoothed stochastic K.
Calculation: Long score = count of these true conditions: close > trend EMA; fast EMA > slow EMA; RSI > midpoint AND RSI < overbought threshold; MACD line > MACD signal line; close > Bollinger middle band; smoothed stochastic K > stochastic D AND smoothed stochastic K < upper stochastic threshold.
Calculation: Short score = count of these true conditions: close < trend EMA; fast EMA < slow EMA; RSI < midpoint AND RSI > oversold threshold; MACD line < MACD signal line; close < Bollinger middle band; smoothed stochastic K < stochastic D AND smoothed stochastic K > lower stochastic threshold.
Calculation: Trailing distance = ATR at the entry-signal bar multiplied by the trailing factor and the instrument's minimum price increment; the resulting trail activation and offset distances are equal.
Long: Close > trend EMA AND fast EMA > slow EMA.
Short: Close < trend EMA AND fast EMA < slow EMA.
Long: RSI < oversold threshold.
Short: RSI > overbought threshold.
Long: MACD line > MACD signal line.
Short: MACD line <= MACD signal line.
Long: Smoothed stochastic K < lower stochastic threshold.
Short: Smoothed stochastic K > upper stochastic threshold.
Long: Long score >= minimum score.
Short: Short score >= minimum score.
Long: (session filter disabled OR bar time is within either configured session) AND (volume filter disabled OR volume > SMA of volume multiplied by the volume factor) AND long score >= minimum score AND close > trend EMA AND (fast EMA crosses above slow EMA OR MACD line crosses above MACD signal line OR RSI crosses above oversold threshold plus an offset OR (smoothed stochastic K crosses above stochastic D AND smoothed stochastic K < upper entry threshold)).
Short: (session filter disabled OR bar time is within either configured session) AND (volume filter disabled OR volume > SMA of volume multiplied by the volume factor) AND short score >= minimum score AND close < trend EMA AND (fast EMA crosses below slow EMA OR MACD line crosses below MACD signal line OR RSI crosses below overbought threshold minus an offset OR (smoothed stochastic K crosses below stochastic D AND smoothed stochastic K > lower entry threshold)).
Exit: long, low <= entry-signal bar close minus ATR at the entry-signal bar multiplied by the stop factor OR high >= entry-signal bar close plus ATR at the entry-signal bar multiplied by the target factor OR (trailing enabled AND price has reached entry price plus trailing distance AND low <= highest price since trailing activation minus trailing distance).
Exit: short, high >= entry-signal bar close plus ATR at the entry-signal bar multiplied by the stop factor OR low <= entry-signal bar close minus ATR at the entry-signal bar multiplied by the target factor OR (trailing enabled AND price has reached entry price minus trailing distance AND high >= lowest price since trailing activation plus trailing distance).