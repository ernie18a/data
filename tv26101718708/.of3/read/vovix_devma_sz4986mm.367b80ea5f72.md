Calculation: VoVix score = (ATR(shorter lookback) − ATR(longer lookback)) / (StDev(ATR(shorter lookback), deviation lookback) + epsilon)
Calculation: volatility deviation = StDev(VoVix score, deviation lookback)
Calculation: fast deviation average = SMA(volatility deviation, shorter lookback)
Calculation: slow deviation average = SMA(volatility deviation, longer lookback)
Calculation: signal strength = abs(fast deviation average − slow deviation average) / volatility deviation × scaling factor
Calculation: session hours active = (session start < session end AND hour(datetime) >= session start AND hour(datetime) < session end) OR (session start >= session end AND (hour(datetime) >= session start OR hour(datetime) < session end))
Long: fast deviation average crosses above slow deviation average
Short: fast deviation average crosses below slow deviation average
Long: fast deviation average crosses above slow deviation average AND position is flat AND bar is confirmed AND (force session active OR (session hours active AND (weekend trading enabled OR datetime is a weekday)))
Short: fast deviation average crosses below slow deviation average AND position is flat AND bar is confirmed AND (force session active OR (session hours active AND (weekend trading enabled OR datetime is a weekday)))
Long: fast deviation average > slow deviation average AND signal strength > higher signal-strength threshold
Short: fast deviation average <= slow deviation average AND signal strength > lower signal-strength threshold
Exit: long, (smart stop enabled AND low <= entry-signal-bar close − ATR(lookback) on the entry signal bar × stop-loss multiplier) OR (high >= entry-signal-bar close + ATR(lookback) on the entry signal bar × take-profit multiplier) OR (trailing stop enabled AND high since entry >= entry price + ATR(lookback) on the entry signal bar × trail-activation multiplier AND low <= highest high since activation − ATR(lookback) on the entry signal bar × trail-offset multiplier) OR bars in trade >= maximum bars in trade
Exit: short, (smart stop enabled AND high >= entry-signal-bar close + ATR(lookback) on the entry signal bar × stop-loss multiplier) OR (low <= entry-signal-bar close − ATR(lookback) on the entry signal bar × take-profit multiplier) OR (trailing stop enabled AND low since entry <= entry price − ATR(lookback) on the entry signal bar × trail-activation multiplier AND high >= lowest low since activation + ATR(lookback) on the entry signal bar × trail-offset multiplier) OR bars in trade >= maximum bars in trade