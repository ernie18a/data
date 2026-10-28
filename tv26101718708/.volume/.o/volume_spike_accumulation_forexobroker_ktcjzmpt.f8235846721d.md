Calculation: Close position = (close - low) / (high - low), or 0.5 when high = low
Calculation: Volume baseline = simple moving average of volume
Long: volume >= spike multiple × volume baseline AND close position >= close-position threshold OR (EMA-reclaim mode: the most recent classified spike was accumulation AND close crosses above the entry EMA)
Short: volume >= spike multiple × volume baseline AND close position <= 1 - close-position threshold OR (EMA-reclaim mode: the most recent classified spike was distribution AND close crosses below the entry EMA)
Long: long condition AND in session when the session filter is enabled AND position side is not long AND cooldown elapsed; confirm at bar close
Short: short condition AND in session when the session filter is enabled AND position side is not short AND cooldown elapsed; confirm at bar close