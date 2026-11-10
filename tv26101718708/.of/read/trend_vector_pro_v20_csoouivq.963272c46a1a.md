Calculation: Momentum = EMA(shorter-period SMA of (high + low) / 2 minus longer-period SMA of (high + low) / 2). If adaptive history is enabled, cap the longer SMA period at the number of available bars and leave momentum undefined until at least max(2 × shorter period, shorter period + 2) bars are available.
Calculation: Bull state = momentum and its preceding value are defined AND momentum > 0 AND absolute momentum >= a threshold times the rolling standard deviation of momentum.
Calculation: Bear state = momentum and its preceding value are defined AND momentum <= 0 AND absolute momentum >= a threshold times the rolling standard deviation of momentum.
Calculation: Strong bull state = bull state AND momentum > preceding momentum.
Calculation: Strong bear state = bear state AND momentum < preceding momentum.
Calculation: Extended bar = close > upper Bollinger Band OR close < lower Bollinger Band.
Calculation: Swing high = preceding high > current high AND preceding high > high two bars ago.
Calculation: Swing low = preceding low < current low AND preceding low < low two bars ago.
Calculation: Raw long signal = (reversal mode AND bull state AND preceding bar is not bull state) OR (strong-pulse mode AND strong bull state AND preceding bar is not strong bull state) OR (early-entry mode AND momentum < 0 AND momentum > preceding momentum AND preceding momentum <= momentum two bars ago) OR (bottom-reversal mode AND momentum and preceding momentum are defined AND current bar is not bull state AND preceding close < preceding lower Bollinger Band AND close > lower Bollinger Band AND close > open AND lowest RSI over its lookback < oversold threshold).
Calculation: Raw short signal = (reversal mode AND bear state AND preceding bar is not bear state) OR (strong-pulse mode AND strong bear state AND preceding bar is not strong bear state).
Long: Bull state AND extended bar is false AND swing high is false.
Short: Bear state AND extended bar is false AND swing low is false.
Long: Raw long signal AND (ADX filter disabled OR ADX > threshold).
Short: Raw short signal AND (ADX filter disabled OR ADX > threshold).
Exit: long, raw short signal AND (short entries disabled OR ADX filter disabled OR ADX > threshold).
Exit: short, raw long signal AND (long entries disabled OR ADX filter disabled OR ADX > threshold).
Exit: long, (early-entry mode OR bottom-reversal mode) AND momentum < 0 AND momentum < preceding momentum AND preceding momentum >= momentum two bars ago.
Exit: long, percentage stop enabled AND low <= entry-signal close × (1 - stop percentage).
Exit: short, percentage stop enabled AND high >= entry-signal close × (1 + stop percentage).
Exit: long, ATR stop enabled AND low <= entry-signal close - multiplier × ATR at entry signal.
Exit: short, ATR stop enabled AND high >= entry-signal close + multiplier × ATR at entry signal.