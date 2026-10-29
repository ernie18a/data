Calculation: Session VWAP = cumulative volume-weighted average of (high + low + close) / 3, reset at each new daily session
Calculation: Volatility expansion = Bollinger Bands are not both inside the Keltner Channel
Calculation: Relative volume = volume / its simple moving average over a longer lookback
Calculation: Long trailing stop = initialize at the lower of the entry bar low and prior bar low minus an ATR multiple; on each holding bar, raise to the greater of the prior stop and prior bar low minus an ATR multiple
Calculation: Short trailing stop = initialize at the higher of the entry bar high and prior bar high plus an ATR multiple; on each holding bar, lower to the lesser of the prior stop and prior bar high plus an ATR multiple
Long: position is flat or short AND close > Session VWAP AND shorter-lookback EMA > longer-lookback EMA AND Stochastic RSI %K crosses above %D AND %K is below the overbought threshold AND Volatility expansion AND (volume = 0 OR Relative volume >= threshold)
Short: position is flat or long AND close < Session VWAP AND shorter-lookback EMA < longer-lookback EMA AND Stochastic RSI %K crosses below %D AND %K is above the oversold threshold AND Volatility expansion AND (volume = 0 OR Relative volume >= threshold)
Exit: long, close < Long trailing stop
Exit: short, close > Short trailing stop