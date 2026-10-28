Calculation: Bullish volume fraction = total volume of 1-minute bars with close > open / total volume of all 1-minute bars (0.5 if total volume is zero)
Calculation: Daily average range = simple average of high − low over the most recent completed daily bars
Calculation: Bullish engulfing = close > open[1] AND open < close[1] AND close − open > 0.3 × true range
Calculation: Bearish engulfing = close < open[1] AND open > close[1] AND open − close > 0.3 × true range
Calculation: Hammer = min(open, close) − low > 0.5 × true range AND high − max(open, close) < 0.2 × true range
Calculation: Shooting star = high − max(open, close) > 0.5 × true range AND min(open, close) − low < 0.2 × true range
Long: MACD line crosses above its signal line (MACD uses a shorter and a longer close EMA) AND close > close EMA AND bullish volume fraction > bull threshold
Long: low < latest confirmed pivot low AND close > latest confirmed pivot low AND bullish volume fraction > shark bull threshold
Long: (low <= previous completed daily low + 0.5 × true range OR low <= current daily open − daily average range) AND (hammer OR bullish engulfing) AND volume > simple moving average of volume × volume multiplier AND more bars than the cooldown length have elapsed since the previous Box signal
Long: (close crosses above the prior bar's stored swing high OR close crosses above the latest bearish fair-value-gap top) AND a bearish order-block top is stored
Short: MACD line crosses below its signal line (MACD uses a shorter and a longer close EMA) AND close < close EMA AND bullish volume fraction < bear threshold
Short: high > latest confirmed pivot high AND close < latest confirmed pivot high AND bullish volume fraction < shark bear threshold
Short: (high >= previous completed daily high − 0.5 × true range OR high >= current daily open + daily average range) AND (shooting star OR bearish engulfing) AND volume > simple moving average of volume × volume multiplier AND more bars than the cooldown length have elapsed since the previous Box signal