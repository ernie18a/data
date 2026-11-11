Calculation: Session low and session high = lowest low and highest high, respectively, of preceding bars in the current calendar session, calculated separately for each timeframe.
Calculation: Close location = (close - low) / (high - low); use the midpoint if high equals low.
Calculation: Lower wick fraction = (min(open, close) - low) / (high - low); use zero if high equals low.
Calculation: Upper wick fraction = (high - max(open, close)) / (high - low); use zero if high equals low.
Calculation: New session low = current low < session low AND current bar is not the first bar of the session.
Calculation: New session high = current high > session high AND current bar is not the first bar of the session.
Calculation: Low reversal = (new session low AND close > open AND close location >= upper close-location threshold) OR (new session low AND lower wick fraction > wick threshold AND close location > lower close-location threshold) OR (current bar is not the first bar of the session AND previous bar was a new session low AND previous close < previous open AND close > open AND close > previous open). The lower close-location threshold is below the upper close-location threshold.
Calculation: High reversal = (new session high AND upper wick fraction > wick threshold AND close location < upper close-location threshold) OR (current bar is not the first bar of the session AND previous bar was a new session high AND previous close > previous open AND close < open).
Long: Low reversal on the chart timeframe.
Short: High reversal on the chart timeframe.
Long: Low reversal on the last completed higher-timeframe bar AND the current chart bar is the first bar of a new higher-timeframe period.
Short: High reversal on the last completed higher-timeframe bar AND the current chart bar is the first bar of a new higher-timeframe period.
Long: Low reversal on the still-forming higher-timeframe bar.
Short: High reversal on the still-forming higher-timeframe bar AND low reversal on that bar is false.