Calculation: UpBar = close > open OR (close = open AND (close > close[1] OR (close = close[1] AND UpBar[1])))
Calculation: DownBar = close < open OR (close = open AND (close < close[1] OR (close = close[1] AND DownBar[1])))
Long: UpBar
Long: close > close[1]
Long: volume > volume[1]
Long: UpBar AND close > close[1]
Long: UpBar AND volume > volume[1]
Long: close > close[1] AND volume > volume[1]
Long: UpBar AND close > close[1] AND volume > volume[1]
Short: DownBar
Short: close < close[1]
Short: volume > volume[1]
Short: DownBar AND close < close[1]
Short: DownBar AND volume > volume[1]
Short: close < close[1] AND volume > volume[1]
Short: DownBar AND close < close[1] AND volume > volume[1]