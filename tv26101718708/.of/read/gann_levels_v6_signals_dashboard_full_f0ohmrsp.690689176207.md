Calculation: Square-root base = close of the last completed higher-timeframe bar.
Calculation: Pivot base = (high + low + close) / 3 of the last completed higher-timeframe bar.
Long: (square-root mode active AND close > square-root base AND previous close <= previous square-root base) OR (pivot mode active AND close > pivot base AND previous close <= previous pivot base).
Short: (square-root mode active AND close < square-root base AND previous close >= previous square-root base) OR (pivot mode active AND close < pivot base AND previous close >= previous pivot base).