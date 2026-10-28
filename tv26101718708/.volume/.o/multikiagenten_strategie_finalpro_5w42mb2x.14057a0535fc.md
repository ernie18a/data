Calculation: Bullish EMA trend = shorter-period EMA > medium-period EMA > longer-period EMA AND close > shorter-period EMA; all EMAs use current-timeframe closes.
Calculation: Bearish EMA trend = shorter-period EMA < medium-period EMA < longer-period EMA AND close < shorter-period EMA; all EMAs use current-timeframe closes.
Calculation: RSI oversold = current-timeframe RSI is below its configured oversold threshold.
Calculation: RSI overbought = current-timeframe RSI is above its configured overbought threshold.
Calculation: Volume spike = current-timeframe volume > its 20-bar simple moving average × configured volume multiplier.
Calculation: Bullish institutional condition = (high two bars ago < low one bar ago AND current close > low one bar ago) OR current close <= the lowest low over the configured lookback, calculated through the prior completed bar.
Calculation: Bearish institutional condition = (low two bars ago > high one bar ago AND current close < high one bar ago) OR current close >= the highest high over the configured lookback, calculated through the prior completed bar.
Calculation: 0.618 retracement = highest high over the configured lookback through the current bar − (highest high − lowest low over that same lookback) × 0.618.
Calculation: 0.382 retracement = highest high over the configured lookback through the current bar − (highest high − lowest low over that same lookback) × 0.382.
Calculation: Upward 0.618 cross = current close > current 0.618 retracement AND prior close <= current 0.618 retracement.
Calculation: Downward 0.382 cross = current close < current 0.382 retracement AND prior close >= current 0.382 retracement.
Calculation: Long score = configured weighted sum of bullish EMA trend, RSI oversold, volume spike, bullish institutional condition, and upward 0.618 cross.
Calculation: Short score = configured weighted sum of bearish EMA trend, RSI overbought, volume spike, bearish institutional condition, and downward 0.382 cross.
Calculation: Long initial stop = signal-bar close − ATR × configured stop multiplier; while long, update each bar to the greater of the prior stop and current low − 1.5 × ATR.
Calculation: Short initial stop = signal-bar close + ATR × configured stop multiplier; while short, update each bar to the lesser of the prior stop and current high + 1.5 × ATR.
Calculation: Long target = signal-bar close + ATR × configured target multiplier.
Calculation: Short target = signal-bar close − ATR × configured target multiplier.
Long: long score >= configured threshold AND position is flat.
Short: short score >= configured threshold AND long score < configured threshold AND position is flat.
Exit: long, current low <= long stop OR current high >= long target.
Exit: short, current high >= short stop OR current low <= short target.