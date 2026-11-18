Long: close of T1 bar still forming, sampled on chart bars > close[1] of T1 last completed bar, sampled on chart bars
Short: close of T1 bar still forming, sampled on chart bars <= close[1] of T1 last completed bar, sampled on chart bars
Long: WMA(close, shorter lookback parameter) > WMA(close, longer lookback parameter)
Short: WMA(close, shorter lookback parameter) <= WMA(close, longer lookback parameter)
Long: HMA(close, lookback parameter) > HMA(close, lookback parameter)[2]
Short: HMA(close, lookback parameter) <= HMA(close, lookback parameter)[2]
Long: close of T1 bar still forming, sampled on chart bars > close[1] of T1 last completed bar, sampled on chart bars AND HMA(close, lookback parameter) > HMA(close, lookback parameter)[2]
Short: close of T1 bar still forming, sampled on chart bars < close[1] of T1 last completed bar, sampled on chart bars AND HMA(close, lookback parameter) < HMA(close, lookback parameter)[2]
Exit: long, close of T1 bar still forming, sampled on chart bars < close[1] of T1 last completed bar, sampled on chart bars AND HMA(close, lookback parameter) < HMA(close, lookback parameter)[2] AND unrealized profit > parameter
Exit: short, close of T1 bar still forming, sampled on chart bars > close[1] of T1 last completed bar, sampled on chart bars AND HMA(close, lookback parameter) > HMA(close, lookback parameter)[2] AND unrealized profit > parameter