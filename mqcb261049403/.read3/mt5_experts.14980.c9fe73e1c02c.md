Calculation: MACD(price, fast lookback, slow lookback) = moving average(price, fast lookback, price smoothing method, price smoothing phase) - moving average(price, slow lookback, price smoothing method, price smoothing phase), with fast lookback shorter than slow lookback
Calculation: MACD signal line(price) = moving average(MACD(price, fast lookback, slow lookback), signal lookback, separate signal smoothing method, separate signal smoothing phase)
Calculation: Selected entry direction = sign(MACD(close) - MACD(open)) for the selected MACD candle source, or sign(current MACD signal line - prior MACD signal line) for the selected signal-line source
Long: MACD(close) > MACD(open) on the current T1 bar, including the bar still forming
Short: MACD(close) < MACD(open) on the current T1 bar, including the bar still forming
Long: MACD signal line on the current T1 bar > MACD signal line on the immediately prior T1 bar
Short: MACD signal line on the current T1 bar < MACD signal line on the immediately prior T1 bar
Long: Selected entry direction at the selected T1 bar offset > 0 AND selected entry direction at the immediately older T1 bar offset <= 0; offset zero uses the forming T1 bar and evaluates on each chart tick, while positive offsets use completed T1 bars and evaluate on each new T1 bar
Short: Selected entry direction at the selected T1 bar offset < 0 AND selected entry direction at the immediately older T1 bar offset >= 0; offset zero uses the forming T1 bar and evaluates on each chart tick, while positive offsets use completed T1 bars and evaluate on each new T1 bar
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance