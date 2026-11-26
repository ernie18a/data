Calculation: Instrument gross open profit = sum of open-trade profit for this instrument
Calculation: Instrument net open profit = sum of open-trade profit, commission, and swap for this instrument
Calculation: Strategy open profit = sum of open-trade profit for this instrument and strategy identifier
Calculation: Account-equity reference = current equity with no strategy trades; otherwise previous observed equity if the stored reference is below previous observed equity, else current equity
Calculation: Money exit reference = 0 with no strategy trades; while instrument net open profit is positive and below the monetary target, retain the greater of its current value and instrument net open profit; during the risk-qualified loss condition, replace its absolute value with the current absolute instrument net open profit when that is smaller
Long: most recent closed trade was a losing short trade, with net profit including commission and swap
Short: most recent closed trade was a losing long trade, with net profit including commission and swap
Long: no most recent closed trade exists or its net profit including commission and swap is at least zero AND DeMarker(lookback, current chart bar) > threshold AND Low[2] < High[1] AND MACD(close, fast lookback, slow lookback, signal lookback).main[1] != 0 AND MACD(close, fast lookback, slow lookback, signal lookback).main[1] > MACD(close, fast lookback, slow lookback, signal lookback).signal[1]
Exit: long, close[1] equals the upper Bollinger Band(close, lookback, deviation parameter)[1]
Exit: short, close[1] equals the lower Bollinger Band(close, lookback, deviation parameter)[1]
Exit: long, Instrument gross open profit >= monetary target
Exit: short, Instrument gross open profit >= monetary target
Exit: long, Instrument net open profit > 0 AND Instrument net open profit < monetary target AND Instrument net open profit <= Money exit reference - monetary stop parameter
Exit: short, Instrument net open profit > 0 AND Instrument net open profit < monetary target AND Instrument net open profit <= Money exit reference - monetary stop parameter
Exit: long, Instrument net open profit < monetary target AND Instrument net open profit < 0 AND Strategy open profit < 0 AND abs(Strategy open profit) > equity-risk percentage / 100 * Account-equity reference * loss multiplier AND sum of absolute net profit for open trades of this instrument >= abs(Money exit reference - monetary stop parameter)
Exit: short, Instrument net open profit < monetary target AND Instrument net open profit < 0 AND Strategy open profit < 0 AND abs(Strategy open profit) > equity-risk percentage / 100 * Account-equity reference * loss multiplier AND sum of absolute net profit for open trades of this instrument >= abs(Money exit reference - monetary stop parameter)