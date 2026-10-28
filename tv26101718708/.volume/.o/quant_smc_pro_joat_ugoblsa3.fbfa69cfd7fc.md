Calculation: ATR = Average True Range on the current chart bars
Calculation: Major swing pivots = ATR-retracement-confirmed ZigZag pivots; each new confirmed pivot of a kind replaces the pending level of that kind
Calculation: Minor swing pivots = confirmed pivot highs and lows using equal look-left and look-right windows, shorter than the major fixed-window setting
Calculation: Impulse candle = absolute(close − open) ≥ 55% of (high − low) AND (high − low) ≥ configurable ATR multiple
Calculation: Bullish fair value gap = current low − high two bars earlier, when current low > high two bars earlier AND prior close > high two bars earlier
Calculation: Bearish fair value gap = low two bars earlier − current high, when current high < low two bars earlier AND prior close < low two bars earlier
Calculation: Qualifying order-block candle = opposite-color candle within the backward scan window AND body/range ≥ configurable minimum AND range < configurable ATR multiple AND, when volume filtering is active, volume ≥ rolling average volume × configurable multiplier
Long: close > pending major swing high AND previous close ≤ pending major swing high
Short: close < pending major swing low AND previous close ≥ pending major swing low
Long: close > pending minor swing high AND previous close ≤ pending minor swing high
Short: close < pending minor swing low AND previous close ≥ pending minor swing low
Long: low < most recent eligible minor swing low AND close > that low AND lower wick ≥ configurable ATR multiple AND lower wick / (high − low) ≥ configurable fraction AND cooldown since prior bullish sweep has elapsed
Short: high > most recent eligible minor swing high AND close < that high AND upper wick ≥ configurable ATR multiple AND upper wick / (high − low) ≥ configurable fraction AND cooldown since prior bearish sweep has elapsed
Long: bullish fair value gap size ≥ configurable ATR multiple
Short: bearish fair value gap size ≥ configurable ATR multiple
Long: a previously mitigated bearish fair value gap is crossed upward by the close within the configured post-mitigation window
Short: a previously mitigated bullish fair value gap is crossed downward by the close within the configured post-mitigation window
Long: bullish major break AND a qualifying bearish candle is found in the backward scan window AND its order-block score ≥ configured minimum
Short: bearish major break AND a qualifying bullish candle is found in the backward scan window AND its order-block score ≥ configured minimum
Long: a previously mitigated bearish order block is retested with low ≤ its top AND low ≥ its bottom AND close > its bottom, within the configured tracking window
Short: a previously mitigated bullish order block is retested with high ≥ its bottom AND high ≤ its top AND close < its top, within the configured tracking window