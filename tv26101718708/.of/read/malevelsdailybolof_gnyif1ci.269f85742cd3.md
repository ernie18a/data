Calculation: MA = any of five EMAs with increasing lookbacks or three SMAs whose lookbacks match the three longest EMA lookbacks, calculated from closes on the last completed higher-timeframe bar; if that timeframe equals the chart timeframe, use the previous chart bar.
Calculation: Tolerance = the previous chart-bar ATR multiplied by a tolerance parameter; if ATR is unavailable, use the current close multiplied by a fallback parameter in place of ATR.
Long: In strict mode, for any MA, (low <= MA AND close > MA AND close > open) OR (previous close <= current MA AND close > current MA).
Short: In strict mode, for any MA, (high >= MA AND close < MA AND close < open) OR (previous close >= current MA AND close < current MA).
Long: In band mode, for any MA, low <= MA + tolerance AND low >= MA - 2 * tolerance AND close > MA AND close > open.
Short: In band mode, for any MA, high >= MA - tolerance AND high <= MA + 2 * tolerance AND close < MA AND close < open.
Long: In strict mode, for any MA, MA > 0 AND low > MA AND (low - MA) / MA <= proximity parameter AND close > open AND previous close > current MA.
Short: In strict mode, for any MA, MA > 0 AND high < MA AND (MA - high) / MA <= proximity parameter AND close < open AND previous close < current MA.
Long: In band mode, for any MA, MA > 0 AND low > MA + tolerance AND (low - MA) / MA <= proximity parameter AND close > open.
Short: In band mode, for any MA, MA > 0 AND high < MA - tolerance AND (MA - high) / MA <= proximity parameter AND close < open.