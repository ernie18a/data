Calculation: Supertrend line = line of Supertrend(high, low, close, ATR lookback, Supertrend multiplier)
Calculation: Supertrend direction = direction of Supertrend(high, low, close, ATR lookback, Supertrend multiplier)
Calculation: Aligned long = close > VWMA(close, volume, VWMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND RSI(close, RSI lookback) > RSI bullish threshold AND Supertrend direction is bullish AND (ADX filter disabled OR ADX(high, low, close, ADX lookback) > ADX threshold)
Calculation: Aligned short = close < VWMA(close, volume, VWMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND RSI(close, RSI lookback) < RSI bearish threshold AND Supertrend direction is bearish AND (ADX filter disabled OR ADX(high, low, close, ADX lookback) > ADX threshold)
Calculation: Regime = 1 if Aligned long; else -1 if Aligned short; else 0 if (Regime[1] = 1 AND close < Supertrend line) OR (Regime[1] = -1 AND close > Supertrend line); else Regime[1]
Calculation: Signal = ((Aligned long AND Regime[1] != 1) OR (Aligned short AND Regime[1] != -1)) AND Bars since signal >= signal cooldown
Calculation: Bars since signal = 1 if Signal[1]; else Bars since signal[1] + 1
Calculation: Stop distance (set on the entry bar) = stop mode M1: |entry price - Supertrend line|; stop mode M2: min(|entry price - Supertrend line|, ATR(high, low, close, ATR lookback) * ATR cap multiplier); stop mode M3: entry price * fixed stop percent / 100
Calculation: TP1 reached = TP1 reached[1] OR (long: high >= entry price + Stop distance * TP1 risk-reward ratio; short: low <= entry price - Stop distance * TP1 risk-reward ratio)
Calculation: Stop level = long: if entry bar then entry price - Stop distance; else if TP1 reached[1] then max(Stop level[1], Supertrend line); else if stop mode M1 then Supertrend line; else Stop level[1]. short: if entry bar then entry price + Stop distance; else if TP1 reached[1] then min(Stop level[1], Supertrend line); else if stop mode M1 then Supertrend line; else Stop level[1]
Long: Aligned long AND Regime[1] != 1 AND Bars since signal >= signal cooldown
Long: Regime = 1
Short: Aligned short AND Regime[1] != -1 AND Bars since signal >= signal cooldown
Short: Regime = -1
Exit: long, low <= Stop level
Exit: long, Supertrend direction is bearish
Exit: long, Regime = 0
Exit: short, high >= Stop level
Exit: short, Supertrend direction is bullish
Exit: short, Regime = 0