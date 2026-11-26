Calculation: Bullish indicator count = count of true conditions: RSI(close, RSI lookback) < lower RSI threshold AND RSI(close, RSI lookback) > its previous-bar value; MACD histogram(close, shorter fast lookback, longer slow lookback, signal lookback) > 0 OR MACD line crosses above signal line; Williams %R(high, low, close, lookback) < lower Williams %R threshold AND Williams %R > its previous-bar value; close < lower Bollinger Band(close, lookback, deviation) OR previous-bar close < previous-bar lower Bollinger Band(close, lookback, deviation).
Calculation: Bearish indicator count = count of true conditions: RSI(close, RSI lookback) > higher RSI threshold AND RSI(close, RSI lookback) < its previous-bar value; MACD histogram(close, shorter fast lookback, longer slow lookback, signal lookback) < 0 OR MACD line crosses below signal line; Williams %R(high, low, close, lookback) > higher Williams %R threshold AND Williams %R < its previous-bar value; close > upper Bollinger Band(close, lookback, deviation) OR previous-bar close > previous-bar upper Bollinger Band(close, lookback, deviation).
Calculation: Volume spike = volume > SMA(volume, volume-average lookback) * volume-spike multiplier.
Calculation: Bullish reversal candle = close > open AND close - open > (high - close) * body-to-wick ratio AND open - low > (high - low) * wick-range fraction.
Calculation: Bearish reversal candle = close < open AND open - close > (close - low) * body-to-wick ratio AND high - open > (high - low) * wick-range fraction.
Calculation: NY session passes = NY session filter disabled OR current chart bar is inside the configured NY session.
Calculation: Standard long signal = bullish indicator count >= minimum-aligned-indicators parameter AND divergence confirmation is not required AND (volume confirmation is disabled OR volume spike) AND (reversal-candle confirmation is disabled OR bullish reversal candle) AND NY session passes.
Calculation: Standard short signal = bearish indicator count >= minimum-aligned-indicators parameter AND divergence confirmation is not required AND (volume confirmation is disabled OR volume spike) AND (reversal-candle confirmation is disabled OR bearish reversal candle) AND NY session passes.
Calculation: Long signal = (signal flip disabled AND standard long signal) OR (signal flip enabled AND standard short signal).
Calculation: Short signal = (signal flip disabled AND standard short signal) OR (signal flip enabled AND standard long signal).
Long: long signal AND ((pyramiding enabled AND same-side entry count is below the pyramid entry limit) OR (pyramiding disabled AND position is flat or short).
Short: short signal AND ((pyramiding enabled AND same-side entry count is below the pyramid entry limit) OR (pyramiding disabled AND position is flat or long).
Long: long signal AND current chart bar is confirmed.
Short: short signal AND current chart bar is confirmed.
Long: bullish indicator count >= setup-alignment threshold AND NOT long signal AND NY session passes.
Short: bearish indicator count >= setup-alignment threshold AND NOT short signal AND NY session passes.
Long: bullish indicator count >= minimum-aligned-indicators parameter.
Short: bearish indicator count >= minimum-aligned-indicators parameter AND bullish indicator count < minimum-aligned-indicators parameter.
Calculation: Long stop price = close on the most recent accepted long-entry signal bar * (1 - stop-loss percent / 100).
Calculation: Long target price = close on the most recent accepted long-entry signal bar * (1 + take-profit percent / 100).
Calculation: Short stop price = close on the most recent accepted short-entry signal bar * (1 + stop-loss percent / 100).
Calculation: Short target price = close on the most recent accepted short-entry signal bar * (1 - take-profit percent / 100).
Exit: Long, (stop loss enabled AND low <= long stop price) OR (take profit enabled AND high >= long target price).
Exit: Short, (stop loss enabled AND high >= short stop price) OR (take profit enabled AND low <= short target price).