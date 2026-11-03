Calculation: Liquidity base = lowest low over the liquidity lookback
Calculation: Apex = highest high over the liquidity lookback
Calculation: Recent high = highest high over its lookback
Calculation: Recent low = lowest low over its lookback
Calculation: ATR = average true range over its lookback
Calculation: Volume average = simple moving average of volume over its lookback
Calculation: First-day high/low = high/low of the first chart bar when the calendar day changes, retained until the next day
Calculation: First-day range = first-day high - first-day low
Calculation: Long liquidity-entry target = entry close + ATR × take-profit multiplier
Calculation: Long liquidity-entry stop = liquidity base - ATR × stop-loss multiplier
Calculation: Short liquidity-entry target = entry close - ATR × take-profit multiplier
Calculation: Short liquidity-entry stop = Apex + ATR × stop-loss multiplier
Calculation: First-day long stop = first-day low - ATR × stop-loss buffer multiplier
Calculation: First-day long target = first-day high + first-day range × risk/reward ratio
Calculation: First-day short stop = first-day high + ATR × stop-loss buffer multiplier
Calculation: First-day short target = first-day low - first-day range × risk/reward ratio
Long: Close crosses above liquidity base AND close > liquidity base + ATR × breakout threshold
Long: (Close > liquidity base AND close < recent high AND position is flat) AND volume > volume average AND within configured trading session
Long: First-day high captured AND close crosses above first-day high AND low <= first-day high AND close > first-day high AND (trend filter disabled OR close > 50-period EMA) AND position is flat AND (RSI filter disabled OR RSI < oversold threshold)
Short: Close crosses below Apex AND close < Apex - ATR × breakout threshold
Short: (Close < Apex AND close > recent low AND position is flat) AND volume > volume average AND within configured trading session
Short: First-day high/low captured AND close crosses below first-day low AND high >= first-day low AND close < first-day low AND (trend filter disabled OR close < 50-period EMA) AND position is flat AND (RSI filter disabled OR RSI > overbought threshold)
Exit: long, close >= long liquidity-entry target OR close <= long liquidity-entry stop OR high >= first-day long target OR low <= first-day long stop
Exit: short, close <= short liquidity-entry target OR close >= short liquidity-entry stop OR low <= first-day short target OR high >= first-day short stop