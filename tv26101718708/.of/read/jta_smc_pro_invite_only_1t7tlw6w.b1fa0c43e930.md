Calculation: Structure levels = latest confirmed pivot high and pivot low, each using the same number of bars on either side; update levels before evaluating the current bar's crossings.
Calculation: Structure bias = initially neutral; on a confirmed bar, change to bullish when close crosses above the structure high while bias is bearish or neutral, and change to bearish when close crosses below the structure low while bias is bullish or neutral. A cross compares the current close and current level with the previous close and previous bar's level.
Calculation: Bullish order block = on a bullish structure-bias change, the high-to-low range of the most recent bearish candle within a lookback three times the structure pivot lookback. Retain up to a configurable maximum number, discarding the oldest first; each starts unmitigated and becomes mitigated when a confirmed bar's low is within its range, including on its creation bar.
Calculation: Bearish order block = on a bearish structure-bias change, the high-to-low range of the bullish candle with the highest high within a lookback three times the structure pivot lookback; resolve equal highs in favor of the most recent candle. Retain up to a configurable maximum number, discarding the oldest first; each starts unmitigated and becomes mitigated when a confirmed bar's high is within its range, including on its creation bar.
Long: Structure bias = bullish.
Short: Structure bias = bearish.
Long: Confirmed close crosses above the structure high AND prior structure bias is bearish or neutral.
Short: Confirmed close crosses below the structure low AND prior structure bias is bullish or neutral.
Long: A bullish order block exists AND confirmed low is within its range AND the block was unmitigated before this bar's mitigation check.
Short: A bearish order block exists AND confirmed high is within its range AND the block was unmitigated before this bar's mitigation check.
Long: Confirmed low > high two bars ago AND low minus high two bars ago >= ATR multiplied by a configurable threshold.
Short: Confirmed high < low two bars ago AND low two bars ago minus high >= ATR multiplied by a configurable threshold.