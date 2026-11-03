Calculation: normalized body = absolute close-open divided by ATR
Calculation: normalized range = max(high-low, minimum tick) divided by ATR
Calculation: close location = (close-low) / max(high-low, minimum tick) × 100
Calculation: bullish shelf = [max(open, low + ATR × shelf thickness), min(close, high - ATR × shelf thickness)]
Calculation: bearish shelf = [max(close, low + ATR × shelf thickness), min(open, high - ATR × shelf thickness)]
Calculation: active ladder level = high for a bullish displacement; low for a bearish displacement; after a ladder step, replace it with that bar's close
Long: close > open AND normalized body ≥ minimum body threshold AND normalized range ≥ minimum range threshold AND close location ≥ minimum close-strength threshold OR active bullish displacement AND shelf has not failed AND close > active ladder level OR active bearish displacement AND within its shelf-failure window AND shelf has not failed AND close > bearish shelf top
Short: close < open AND normalized body ≥ minimum body threshold AND normalized range ≥ minimum range threshold AND 100 - close location ≥ minimum close-strength threshold OR active bearish displacement AND shelf has not failed AND close < active ladder level OR active bullish displacement AND within its shelf-failure window AND shelf has not failed AND close < bullish shelf bottom