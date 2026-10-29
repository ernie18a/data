Calculation: Previous-window high = highest high of the preceding lookback bars, excluding the current bar
Calculation: Previous-window low = lowest low of the preceding lookback bars, excluding the current bar
Calculation: Bullish sweep = current low < previous-window low AND current close > previous-window low
Calculation: Bearish sweep = current high > previous-window high AND current close < previous-window high
Calculation: Bullish reclaim = bullish sweep AND current close > current open
Calculation: Bearish reclaim = bearish sweep AND current close < current open
Calculation: Bullish dealer flow = current close > VWAP AND current close > short-term EMA
Calculation: Bearish dealer flow = current close < VWAP AND current close < short-term EMA
Calculation: High volume = current volume > moving average of volume over a longer lookback × volume multiplier
Calculation: Active dealer zone = high volume AND current close is within VWAP ± ATR × zone-width multiplier
Calculation: Bullish displacement = current close > current open AND absolute(close − open) > ATR × displacement multiplier
Calculation: Bearish displacement = current close < current open AND absolute(close − open) > ATR × displacement multiplier
Calculation: Bull score = count of true conditions: bullish sweep, bullish reclaim, bullish dealer flow, high volume, short-term EMA > long-term EMA, bullish displacement, active dealer zone
Calculation: Bear score = count of true conditions: bearish sweep, bearish reclaim, bearish dealer flow, high volume, short-term EMA < long-term EMA, bearish displacement, active dealer zone
Long: bullish sweep
Long: bullish sweep AND bullish reclaim AND bull score ≥ minimum score AND (trend filter disabled OR short-term EMA > long-term EMA) AND no long signal within the cooldown lookback AND current bar is confirmed
Long: close crosses above the latest main dealer ceiling
Short: bearish sweep
Short: bearish sweep AND bearish reclaim AND bear score ≥ minimum score AND (trend filter disabled OR short-term EMA < long-term EMA) AND no short signal within the cooldown lookback AND current bar is confirmed
Short: close crosses below the latest main dealer floor