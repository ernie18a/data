Calculation: MACD = shorter-lookback EMA(close) minus longer-lookback EMA(close)
Calculation: MACD Bollinger Bands = SMA(MACD) plus or minus its standard deviation multiplied by a configurable factor
Calculation: SSL baseline channel = EMA(close) plus or minus EMA(true range) multiplied by a configurable factor
Calculation: Buyer strength = 100 × sum(volume × (close − low) / (high − low)) / sum(volume), over prior bars since the current trading session began
Calculation: Seller strength = 100 − buyer strength
Long: MACD ≥ upper MACD Bollinger Band AND MACD > 0 AND at least one of the prior configurable lookback bars had MACD > 0 and MACD < its upper Bollinger Band AND close > SSL baseline AND close > upper SSL baseline channel AND at least one of the prior configurable lookback bars had close below the upper SSL baseline channel AND rounded buyer strength > 50
Short: MACD < upper MACD Bollinger Band AND MACD < 0 AND at least one of the prior configurable lookback bars had MACD < 0 and MACD ≥ its upper Bollinger Band AND close < SSL baseline AND close < lower SSL baseline channel AND at least one of the prior configurable lookback bars had close above the lower SSL baseline channel AND rounded seller strength > 50
Exit: long, close < entry price × (1 − stop percentage) OR high ≥ entry price × (1 + target percentage)
Exit: short, close > entry price × (1 + stop percentage) OR low ≤ entry price × (1 − target percentage)