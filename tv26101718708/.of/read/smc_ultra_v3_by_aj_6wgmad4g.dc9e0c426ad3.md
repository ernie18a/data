Calculation: Volume delta = 2 × buy volume − volume, where buy volume = volume if close > open; otherwise volume × (close − low) / max(high − low, minimum range constant).
Long: close >= open.
Short: close < open.
Long: close > open AND abs(close − open) >= SMA(abs(close − open)) × momentum multiplier.
Short: close < open AND abs(close − open) >= SMA(abs(close − open)) × momentum multiplier.
Long: close > open AND abs(close − open) >= SMA(abs(close − open)) × momentum multiplier AND volume >= SMA(volume) × volume multiplier AND volume delta > 0.
Short: close < open AND abs(close − open) >= SMA(abs(close − open)) × momentum multiplier AND volume >= SMA(volume) × volume multiplier AND volume delta < 0.
Long: close > open AND abs(close − open) >= SMA(abs(close − open)) × momentum multiplier AND volume >= SMA(volume) × volume multiplier AND volume delta > 0 AND (RSI filter disabled OR RSI < overbought threshold) AND (higher-timeframe filter disabled OR higher-timeframe close > higher-timeframe EMA of close).
Short: close < open AND abs(close − open) >= SMA(abs(close − open)) × momentum multiplier AND volume >= SMA(volume) × volume multiplier AND volume delta < 0 AND (RSI filter disabled OR RSI > oversold threshold) AND (higher-timeframe filter disabled OR higher-timeframe close < higher-timeframe EMA of close).
Long: low > high two bars ago.
Short: high < low two bars ago.
Long: min(open, close) − low > abs(close − open) × wick multiplier AND min(open, close) − low > high − max(open, close).
Short: high − max(open, close) > abs(close − open) × wick multiplier AND high − max(open, close) > min(open, close) − low.
Long: RSI < oversold threshold.
Short: RSI > overbought threshold.
Long: volume delta > 0.
Short: volume delta <= 0.
Long: higher-timeframe close > higher-timeframe EMA of close.
Short: higher-timeframe close <= higher-timeframe EMA of close.
Calculation: Higher-timeframe close and EMA use the last completed higher-timeframe bar on historical chart bars, and the still-forming higher-timeframe bar on realtime chart bars.