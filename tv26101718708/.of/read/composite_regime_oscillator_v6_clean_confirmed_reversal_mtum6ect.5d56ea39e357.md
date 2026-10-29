Calculation: Normalized scale = clamp((x − lower bound) / (upper bound − lower bound), 0, 1) × 100; bounds are configurable.
Calculation: ATR ratio = shorter-lookback ATR / longer-lookback ATR.
Calculation: Drawdown = (highest high over its lookback − close) / highest high over that lookback.
Calculation: Rebound = (close − lowest low over its lookback) / lowest low over that lookback.
Calculation: Range position = (close − lowest low over its lookback) / (highest high − lowest low over that lookback).
Calculation: ATR distance = (close − EMA) / ATR; the EMA and ATR use configurable lookbacks.
Calculation: Relative volume = volume / its longer-lookback average volume.
Calculation: Regime stress = SMA of a weighted sum of normalized ATR ratio, drawdown, and rebound.
Calculation: Stretch score = SMA of a weighted sum of normalized absolute ATR distance and absolute distance of range position from 0.5.
Calculation: Location score = SMA of a weighted sum of normalized range position, normalized distance above the lookback low, and 100 minus normalized distance below the lookback high.
Calculation: Bullish overreaction score = SMA of a weighted sum of normalized (100 − RSI) and normalized negative ATR distance. Bearish overreaction score = SMA of a weighted sum of normalized RSI and normalized ATR distance.
Calculation: Pressure score = SMA of a weighted sum of normalized relative volume and normalized ATR ratio.
Calculation: Bullish exhaustion score = EMA of a weighted sum of (100 − location score), bullish overreaction score, regime stress, and pressure score.
Calculation: Bearish exhaustion score = EMA of a weighted sum of location score, bearish overreaction score, (100 − regime stress), and pressure score.
Calculation: Fast and slow trend EMAs = EMAs with shorter and longer lookbacks, respectively; fast EMA slope = fast EMA − its value at the slope lookback.
Calculation: Strong uptrend = close > fast trend EMA AND fast trend EMA > slow trend EMA AND fast EMA slope > 0. Strong downtrend = close < fast trend EMA AND fast trend EMA < slow trend EMA AND fast EMA slope < 0.
Calculation: ADX cooling = ADX falling on each bar over its lookback. ADX rising = ADX rising on each bar over that lookback. Strong trend = ADX > its threshold.
Calculation: Bullish setup = bullish exhaustion score ≥ its threshold. Bearish setup = bearish exhaustion score ≥ its threshold.
Calculation: Bullish trigger = close > prior high OR (close > open AND prior close < prior open) OR RSI crossing above its oversold threshold OR close rising on each bar over its momentum lookback. Bearish trigger = close < prior low OR (close < open AND prior close > prior open) OR RSI crossing below its overbought threshold OR close falling on each bar over its momentum lookback.
Calculation: Bullish EMA confirmation = close crosses above its EMA. Bearish EMA confirmation = close crosses below that EMA.
Calculation: Bullish confirmed trigger = bullish trigger AND (EMA confirmation is not required OR bullish EMA confirmation OR close > prior high). Bearish confirmed trigger = bearish trigger AND (EMA confirmation is not required OR bearish EMA confirmation OR close < prior low).
Calculation: Bullish signal is blocked = strong downtrend AND strong trend AND (ADX cooling is required AND ADX is not cooling, OR ADX cooling is not required AND ADX is rising). Bearish signal is blocked = strong uptrend AND strong trend AND (ADX cooling is required AND ADX is not cooling, OR ADX cooling is not required AND ADX is rising).
Long: bullish setup AND (trigger confirmation is disabled OR bullish confirmed trigger) AND NOT bullish signal is blocked AND prior bar did not meet these same base conditions AND no bullish signal occurred within the cooldown lookback OR bullish setup AND bullish signal is blocked.
Short: bearish setup AND (trigger confirmation is disabled OR bearish confirmed trigger) AND NOT bearish signal is blocked AND prior bar did not meet these same base conditions AND no bearish signal occurred within the cooldown lookback OR bearish setup AND bearish signal is blocked.