Calculation: normalized MACD signal gap = ATR(high, low, close, ATR lookback) > 0 ? (MACD(close, shorter lookback, longer lookback, signal lookback).line - MACD(close, shorter lookback, longer lookback, signal lookback).signal) / ATR(high, low, close, ATR lookback) : 0
Calculation: bullish MACD confirmation = (ATR filter enabled AND normalized MACD signal gap > gap threshold) OR (ATR filter disabled AND MACD(close, shorter lookback, longer lookback, signal lookback).line > MACD(close, shorter lookback, longer lookback, signal lookback).signal)
Calculation: bearish MACD confirmation = (ATR filter enabled AND normalized MACD signal gap < -gap threshold) OR (ATR filter disabled AND MACD(close, shorter lookback, longer lookback, signal lookback).line < MACD(close, shorter lookback, longer lookback, signal lookback).signal)
Calculation: bullish alignment = EFI(close, volume, EFI lookback) > 0 AND bullish MACD confirmation
Calculation: bearish alignment = EFI(close, volume, EFI lookback) < 0 AND bearish MACD confirmation
Long: EFI(close, volume, EFI lookback) >= 0
Short: EFI(close, volume, EFI lookback) < 0
Exit: Long, bullish alignment[1] AND NOT bullish alignment AND (EFI(close, volume, EFI lookback) < EFI(close, volume, EFI lookback)[1] OR NOT bullish MACD confirmation)
Exit: Short, bearish alignment[1] AND NOT bearish alignment AND (EFI(close, volume, EFI lookback) > EFI(close, volume, EFI lookback)[1] OR NOT bearish MACD confirmation)