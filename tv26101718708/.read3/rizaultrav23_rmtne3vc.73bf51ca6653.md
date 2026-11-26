Calculation: LongStop = MAX(entry price * (1 - initial stop pct), IF highest high since entry > entry price * (1 + activation pct) THEN high * (1 - trailing pct), LongStop[1]), no value when not in a long position
Calculation: ShortStop = MIN(entry price * (1 + initial stop pct), IF lowest low since entry < entry price * (1 - activation pct) THEN low * (1 + trailing pct), ShortStop[1]), no value when not in a short position
Long: ((SMA(close, shorter lookback 1, T1, forming bar) crosses above SMA(close, longer lookback 1, T1, forming bar) AND SMA(close, shorter lookback 2, T2, forming bar) > SMA(close, longer lookback 2, T2, forming bar)) OR (SMA(close, shorter lookback 1, T1, forming bar) > SMA(close, longer lookback 1, T1, forming bar) AND SMA(close, shorter lookback 2, T2, forming bar) crosses above SMA(close, longer lookback 2, T2, forming bar))) AND (MAC filter disabled OR WaveTrend1(hlc3, channel length, average length, T3, forming bar) > 0)
Short: ((SMA(close, shorter lookback 1, T1, forming bar) crosses below SMA(close, longer lookback 1, T1, forming bar) AND SMA(close, shorter lookback 2, T2, forming bar) < SMA(close, longer lookback 2, T2, forming bar)) OR (SMA(close, shorter lookback 1, T1, forming bar) < SMA(close, longer lookback 1, T1, forming bar) AND SMA(close, shorter lookback 2, T2, forming bar) crosses below SMA(close, longer lookback 2, T2, forming bar))) AND (MAC filter disabled OR WaveTrend1(hlc3, channel length, average length, T3, forming bar) < 0)
Long: SMA(close, shorter lookback 1, T1, forming bar) > SMA(close, longer lookback 1, T1, forming bar)
Short: SMA(close, shorter lookback 1, T1, forming bar) < SMA(close, longer lookback 1, T1, forming bar)
Long: SMA(close, shorter lookback 2, T2, forming bar) > SMA(close, longer lookback 2, T2, forming bar)
Short: SMA(close, shorter lookback 2, T2, forming bar) < SMA(close, longer lookback 2, T2, forming bar)
Long: MAC filter enabled AND WaveTrend1(hlc3, channel length, average length, T3, forming bar) > 0
Short: MAC filter enabled AND WaveTrend1(hlc3, channel length, average length, T3, forming bar) < 0
Exit: long, low < LongStop[1]
Exit: short, high > ShortStop[1]