Calculation: Bull score = 1 + (1 if Aroon Up > Aroon Down else 0) + (1 if CMF > 0 OR CMF > its prior-bar value else 0)
Calculation: Bear score = 1 + (1 if Aroon Down > Aroon Up else 0) + (1 if CMF < 0 OR CMF < its prior-bar value else 0)
Calculation: Lower wick = min(open, close) - low
Calculation: Upper wick = high - max(open, close)
Long: low < the lowest low of the preceding Donchian lookback bars AND Lower wick > ATR × wick factor AND (Bull score >= threshold - 1 AND Bull score < threshold OR Bull score >= threshold AND bars since the previous bull score signal > cooldown)
Short: high > the highest high of the preceding Donchian lookback bars AND Upper wick > ATR × wick factor AND (Bear score >= threshold - 1 AND Bear score < threshold OR Bear score >= threshold AND bars since the previous bear score signal > cooldown)