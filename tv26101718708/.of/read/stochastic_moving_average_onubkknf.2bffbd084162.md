Calculation: Stochastic K = 100 × (close − lowest low over the lookback) / (highest high over the lookback − lowest low over the lookback).
Calculation: Stochastic D = simple moving average of stochastic K.
Calculation: Stop distance = ATR multiplied by a multiplier, captured on the entry signal bar.
Calculation: Signal close = close of the entry signal bar.
Long: Position is flat AND short-term EMA of close > long-term EMA of close AND close < short-term EMA AND close >= long-term EMA AND stochastic K crosses above stochastic D AND (at least one K from the current bar through the lookback bar is < the oversold threshold, or, if the all-bars option is enabled, K on the oldest lookback bar is < the oversold threshold).
Short: Position is flat AND short-term EMA of close < long-term EMA of close AND close > short-term EMA AND close <= long-term EMA AND stochastic K crosses below stochastic D AND (at least one K from the current bar through the lookback bar is > the overbought threshold, or, if the all-bars option is enabled, K on the oldest lookback bar is > the overbought threshold).
Exit: Long, low <= signal close − stop distance OR high >= signal close + stop distance × reward-to-risk ratio.
Exit: Short, high >= signal close + stop distance OR low <= signal close − stop distance × reward-to-risk ratio.