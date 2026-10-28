Calculation: Bollinger Band width percentile = percentile rank of (upper band − lower band) / basis × 100, where basis is the simple moving average of close and the bands are basis ± (standard deviation of close × band multiplier)
Calculation: Entry stop = entry price − ATR at entry × initial stop multiple
Calculation: Chandelier stop = highest close since entry − current ATR × trail multiple
Calculation: Active stop = greater of entry stop and chandelier stop
Long: no open position AND datetime is within the configured backtest window AND at least one of the current or prior squeeze-age bars has a Bollinger Band width percentile below the squeeze threshold AND close > highest high of the prior breakout-lookback bars AND volume > its moving average over the volume lookback AND close > its trend simple moving average
Exit: long, datetime > configured backtest end date OR close < active stop