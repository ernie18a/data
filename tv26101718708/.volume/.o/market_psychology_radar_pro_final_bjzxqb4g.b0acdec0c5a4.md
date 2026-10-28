Calculation: Previous-day high/low = high/low of the last completed daily bar; previous-day midpoint = their average
Calculation: Locked Asia high/low = highest high / lowest low during the configured Asia session, once that session has ended
Calculation: ATR = average true range on the chart timeframe
Calculation: Bullish displacement = close > open AND high − low > ATR × displacement threshold AND candle body / (high − low) > 0.60 AND (close − low) / (high − low) > 0.70
Calculation: Bearish displacement = close < open AND high − low > ATR × displacement threshold AND candle body / (high − low) > 0.60 AND (high − close) / (high − low) > 0.70
Calculation: Bullish absorption = lower wick / (high − low) > wick threshold AND candle body / (high − low) < 0.45 AND volume > average volume × strong-volume threshold AND high − low < average high−low range × 0.75 AND close > low + 0.35 × (high − low)
Calculation: Bearish absorption = upper wick / (high − low) > wick threshold AND candle body / (high − low) < 0.45 AND volume > average volume × strong-volume threshold AND high − low < average high−low range × 0.75 AND close < high − 0.35 × (high − low)
Calculation: Bullish market-structure shift = close > the latest confirmed pivot high, using the configured swing length on both sides of the pivot
Calculation: Bearish market-structure shift = close < the latest confirmed pivot low, using the configured swing length on both sides of the pivot
Long: A low sweep occurs (low < previous-day low − ATR × sweep-buffer threshold OR low < locked Asia low − ATR × sweep-buffer threshold), then within the configured confirmation bars close > previous-day low AND close > open, then on a later bar bullish displacement OR bullish absorption, with (close − low) / (high − low) > 0.55; apply the optional grade filter only when enabled (setup grade A or A+)
Short: A high sweep occurs (high > previous-day high + ATR × sweep-buffer threshold OR high > locked Asia high + ATR × sweep-buffer threshold), then within the configured confirmation bars close < previous-day high AND close < open, then on a later bar bearish displacement OR bearish absorption, with (high − close) / (high − low) > 0.55; apply the optional grade filter only when enabled (setup grade A or A+)
Long: Bullish market-structure shift
Short: Bearish market-structure shift