Calculation: Scaled ATR = ATR(ATR lookback) * ATR multiplier
Calculation: Swing state(k) = 0 if high[k] > highest(high, k), 1 if low[k] < lowest(low, k), otherwise Swing state(k)[1]
Calculation: Last swing high(k) = high[k] on bars where Swing state(k) = 0 and Swing state(k)[1] != 0, otherwise Last swing high(k)[1]
Calculation: Last swing low(k) = low[k] on bars where Swing state(k) = 1 and Swing state(k)[1] != 1, otherwise Last swing low(k)[1]
Calculation: Bull CHoCH = close > Last swing high(longer swing lookback) AND close has not been above that same value on any earlier bar since it was formed
Calculation: Bear CHoCH = close < Last swing low(longer swing lookback) AND close has not been below that same value on any earlier bar since it was formed
Calculation: Bias = 1 on bars where Bull CHoCH, 0 on bars where Bear CHoCH, otherwise Bias[1]
Calculation: High since bias change = high on bars where Bias != Bias[1], otherwise max(high, High since bias change[1])
Calculation: Low since bias change = low on bars where Bias != Bias[1], otherwise min(low, Low since bias change[1])
Calculation: Bull minor sweep = low < Last swing low(shorter swing lookback) AND Bias = 1 AND Last swing low(shorter swing lookback) != Last swing low(longer swing lookback) AND no Bull minor sweep since the last bias change or last Bull BOS, before this bar
Calculation: Bear minor sweep = high > Last swing high(shorter swing lookback) AND Bias = 0 AND Last swing high(shorter swing lookback) != Last swing high(longer swing lookback) AND no Bear minor sweep since the last bias change or last Bear BOS, before this bar
Calculation: Bull BOS = Bias = 1 AND close > High since bias change[1] AND a Bull minor sweep has occurred since the last bias change or last Bull BOS, up to and including this bar
Calculation: Bear BOS = Bias = 0 AND close < Low since bias change[1] AND a Bear minor sweep has occurred since the last bias change or last Bear BOS, up to and including this bar
Calculation: Bull sweep = low < Low since bias change[1] AND close > Low since bias change[1] AND Bias = 0 AND the bar that set Low since bias change[1] is more than sweep delay bars before this bar
Calculation: Bear sweep = high > High since bias change[1] AND close < High since bias change[1] AND Bias = 1 AND the bar that set High since bias change[1] is more than sweep delay bars before this bar
Calculation: Volume exhaustion = volume > SMA(volume, volume MA lookback) * volume exhaustion multiplier AND close < open
Calculation: VWAP distance % = (close - VWAP(hlc3)) / VWAP(hlc3) * 100
Calculation: Bullish divergence = lowest(low, divergence lookback) < lowest(low, longer divergence lookback)[divergence lookback] AND lowest(RSI(close, RSI lookback), divergence lookback) > lowest(RSI(close, RSI lookback), longer divergence lookback)[divergence lookback]
Calculation: Bearish divergence = highest(high, divergence lookback) > highest(high, longer divergence lookback)[divergence lookback] AND highest(RSI(close, RSI lookback), divergence lookback) < highest(RSI(close, RSI lookback), longer divergence lookback)[divergence lookback]
Calculation: Candle body = abs(close - open)
Calculation: Upper wick = high - max(close, open)
Calculation: Lower wick = min(close, open) - low
Calculation: Shooting star = Upper wick > Candle body * shooting-star wick multiple AND Lower wick < Candle body * shooting-star opposite-wick fraction AND high - low > Scaled ATR * shooting-star range fraction
Calculation: Profit % = (close - entry price) / entry price * 100
Calculation: Exit signal count = number of true among: Bearish divergence; Shooting star; Volume exhaustion; MACD histogram crosses below 0; Bear CHoCH; close < VWAP(hlc3); HTF bullish is false; RSI(close, RSI lookback) >= RSI hard block; VWAP distance % > VWAP hard overextension limit
Calculation: Long filters pass = RSI(close, RSI lookback) > RSI min long AND RSI(close, RSI lookback) < RSI hard block AND (RSI(close, RSI lookback) < RSI hot level OR (RSI(close, RSI lookback) > RSI(close, RSI lookback)[1] AND RSI(close, RSI lookback)[1] > RSI(close, RSI lookback)[2] AND Bearish divergence is false)) AND volume > SMA(volume, volume MA lookback) * volume min multiplier AND EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback) AND close > EMA(close, long EMA lookback) AND ADX(ADX lookback) > ADX minimum AND (bar time (New York) is within session window 1 OR session window 2) AND close > VWAP(hlc3) AND VWAP distance % <= VWAP hard overextension limit AND HTF bullish AND MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) > 0
Calculation: Short filters pass = RSI(close, RSI lookback) < RSI max short AND RSI(close, RSI lookback) > RSI oversold level AND volume > SMA(volume, volume MA lookback) * volume min multiplier AND EMA(close, fast EMA lookback) < EMA(close, slow EMA lookback) AND close < EMA(close, long EMA lookback) AND ADX(ADX lookback) > ADX minimum AND (bar time (New York) is within session window 1 OR session window 2) AND close < VWAP(hlc3) AND EMA(close, HTF fast EMA lookback, T1 bars, last completed bar) < EMA(close, HTF slow EMA lookback, T1 bars, last completed bar) AND MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) < 0
Calculation: HTF bullish = EMA(close, HTF fast EMA lookback, T1 bars, last completed bar) > EMA(close, HTF slow EMA lookback, T1 bars, last completed bar)
Long: Long filters pass AND Bull BOS
Long: Long filters pass AND Bull sweep AND Candle body > 0 AND Lower wick / Candle body >= minimum wick-to-body ratio
Long: Bull BOS
Long: Bull sweep
Long: Bull CHoCH
Long: Bullish divergence
Long: Long filters pass AND NOT Bull BOS AND NOT (Bull sweep AND Candle body > 0 AND Lower wick / Candle body >= minimum wick-to-body ratio)
Short: Short filters pass AND Bear BOS
Short: Short filters pass AND Bear sweep AND Candle body > 0 AND Upper wick / Candle body >= minimum wick-to-body ratio
Short: Bear BOS
Short: Bear sweep
Short: Bear CHoCH
Short: Bearish divergence
Short: Shooting star
Exit: long, low <= entry price - stop multiplier * Scaled ATR on the entry bar
Exit: long, high >= entry price + target multiplier * Scaled ATR on the entry bar
Exit: long, high >= entry price + partial target multiplier * Scaled ATR on the entry bar
Exit: long, low <= entry price AND high >= entry price + partial target multiplier * Scaled ATR on the entry bar on some bar since entry
Exit: long, Bear CHoCH
Exit: long, VWAP distance % > VWAP hard overextension limit AND Profit % > 0
Exit: long, Exit signal count >= exit signal count threshold
Exit: long, RSI(close, RSI lookback) >= RSI hard block
Exit: long, Bearish divergence AND Shooting star
Exit: long, Bearish divergence AND Volume exhaustion
Exit: long, VWAP distance % > VWAP extended limit AND Bearish divergence
Exit: long, Bearish divergence AND RSI(close, RSI lookback) > RSI warning level
Exit: long, Volume exhaustion AND Profit % > volume-exhaustion profit threshold
Exit: long, Shooting star AND RSI(close, RSI lookback) > RSI candle level
Exit: long, close < VWAP(hlc3)
Exit: long, HTF bullish is false
Exit: long, MACD histogram crosses below 0 AND Profit % > MACD profit threshold
Exit: long, Bias = 0 AND Profit % <= 0 AND partial target not reached on any bar since entry
Exit: short, high >= entry price + stop multiplier * Scaled ATR on the entry bar
Exit: short, low <= entry price - target multiplier * Scaled ATR on the entry bar
Exit: short, low <= entry price - partial target multiplier * Scaled ATR on the entry bar
Exit: short, high >= entry price AND low <= entry price - partial target multiplier * Scaled ATR on the entry bar on some bar since entry
Exit: short, Bull CHoCH