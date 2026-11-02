Calculation: Rolling VWAP = sum(close × volume over the lookback) / sum(volume over the same lookback).
Calculation: Stochastic RSI K = SMA of the stochastic oscillator applied to RSI, using the same lookback for RSI and the stochastic oscillator; D = SMA of K using a separate smoothing lookback.
Calculation: Squeeze = Bollinger Bands strictly inside Keltner bands, both centered on the same SMA of close and using the same lookback; Bollinger distance is a multiplier of the standard deviation of close, and Keltner distance is a separate multiplier of ATR. Release = squeeze is false and was true on the previous bar.
Calculation: Squeeze momentum = the current endpoint of a linear regression over the squeeze lookback of close minus the average of the midpoint of the lookback's highest high and lowest low and the SMA of close over that lookback.
Calculation: Bull score = count of true conditions: short EMA > medium EMA > long EMA; RSI > midpoint AND RSI < overbought; MACD crosses above its signal OR MACD > signal AND MACD > zero; stochastic RSI K crosses above D AND K < overbought; ADX >= strength threshold AND +DI > -DI; CCI crosses above oversold OR CCI > zero AND CCI < overbought; close > Bollinger middle band AND close <= upper band; Williams %R crosses above oversold; volume > SMA of volume; Supertrend is bullish; close > rolling VWAP; squeeze momentum > zero AND (squeeze momentum > previous squeeze momentum OR release); close > Parabolic SAR; MFI < oversold OR MFI crosses above oversold.
Calculation: Bear score = count of true conditions: short EMA < medium EMA < long EMA; RSI < midpoint AND RSI > oversold; MACD crosses below its signal OR MACD < signal AND MACD < zero; stochastic RSI K crosses below D AND K > oversold; ADX >= strength threshold AND -DI > +DI; CCI crosses below overbought OR CCI < zero AND CCI > oversold; close < Bollinger middle band AND close >= lower band; Williams %R crosses below overbought; volume > SMA of volume; Supertrend is bearish; close < rolling VWAP; squeeze momentum < zero AND (squeeze momentum < previous squeeze momentum OR release); close < Parabolic SAR; MFI > overbought OR MFI crosses below overbought.
Long: Choppiness filter disabled OR Choppiness Index <= threshold, AND bull score >= bullish score threshold AND bull score >= bear score AND (MACD crosses above its signal OR RSI crosses above oversold OR stochastic RSI K crosses above D AND K < overbought OR Williams %R crosses above oversold OR Supertrend turns bullish OR close > Parabolic SAR AND previous close <= previous Parabolic SAR) AND most recent entry signal is not long.
Short: Choppiness filter disabled OR Choppiness Index <= threshold, AND bear score >= bearish score threshold AND bear score >= bull score AND (MACD crosses below its signal OR RSI crosses below overbought OR stochastic RSI K crosses below D AND K > oversold OR Williams %R crosses below overbought OR Supertrend turns bearish OR close < Parabolic SAR AND previous close >= previous Parabolic SAR) AND most recent entry signal is not short.
Exit: long, bars since most recent entry signal >= minimum exit delay AND no long exit has fired since the most recent long entry AND (Supertrend turns bearish OR close < Parabolic SAR AND previous close >= previous Parabolic SAR OR at least the required number of these conditions are true: RSI crosses below overbought; MACD crosses below its signal; stochastic RSI K > overbought AND K crosses below D; close >= upper Bollinger band AND bear score >= exit score threshold; CCI crosses below overbought; Williams %R crosses below overbought; MFI crosses below overbought; close crosses below rolling VWAP).
Exit: short, bars since most recent entry signal >= minimum exit delay AND no short exit has fired since the most recent short entry AND (Supertrend turns bullish OR close > Parabolic SAR AND previous close <= previous Parabolic SAR OR at least the required number of these conditions are true: RSI crosses above oversold; MACD crosses above its signal; stochastic RSI K < oversold AND K crosses above D; close <= lower Bollinger band AND bull score >= exit score threshold; CCI crosses above oversold; Williams %R crosses above oversold; MFI crosses above oversold; close crosses above rolling VWAP).
Long: Short EMA > medium EMA AND medium EMA > long EMA.
Short: Short EMA < medium EMA AND medium EMA < long EMA.
Long: RSI > midpoint AND RSI < overbought.
Short: RSI < midpoint AND RSI > oversold.
Long: MACD crosses above its signal OR MACD > signal AND MACD > zero.
Short: MACD crosses below its signal OR (MACD does not cross above its signal AND MACD is not bullish).
Long: Stochastic RSI K < oversold.
Short: Stochastic RSI K > overbought.
Long: ADX >= strength threshold AND +DI > -DI.
Short: ADX >= strength threshold AND -DI > +DI.
Long: CCI crosses above oversold OR CCI > zero AND CCI < overbought.
Short: CCI crosses below overbought OR CCI < zero AND CCI > oversold.
Long: close <= lower Bollinger band OR close > middle Bollinger band AND close <= upper Bollinger band.
Short: close >= upper Bollinger band OR (close > lower Bollinger band AND close <= middle Bollinger band).
Long: Williams %R <= oversold.
Short: Williams %R >= overbought.
Long: Supertrend is bullish.
Short: Supertrend is bearish.
Long: close > rolling VWAP.
Short: close <= rolling VWAP.
Long: squeeze is false AND squeeze momentum > zero AND (squeeze momentum > previous squeeze momentum OR release).
Short: squeeze is false AND squeeze momentum < zero AND (squeeze momentum < previous squeeze momentum OR release).
Long: close > Parabolic SAR.
Short: close <= Parabolic SAR.
Long: MFI < oversold OR MFI crosses above oversold.
Short: MFI > overbought.
Long: Choppiness filter disabled OR Choppiness Index <= threshold, AND bull score >= bullish score threshold AND raw short entry condition is false AND bearish bar-bias condition is false.
Short: Choppiness filter disabled OR Choppiness Index <= threshold, AND bear score >= bearish score threshold AND raw long entry condition is false.