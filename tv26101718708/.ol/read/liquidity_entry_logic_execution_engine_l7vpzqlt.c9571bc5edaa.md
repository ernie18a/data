Calculation: Asia session high/low = running maximum high/minimum low during the configured Asia session, reset at its start
Calculation: Confirmed high sweep = high > Asia session high AND upper wick > configured fraction of high − low AND close < open
Calculation: Confirmed low sweep = low < Asia session low AND lower wick > configured fraction of high − low AND close > open
Calculation: Bull impulse = close > open AND high − low > configured multiple of the 10-bar average high − low
Calculation: Bear impulse = close < open AND high − low > configured multiple of the 10-bar average high − low
Calculation: Trending = absolute difference between close and its 10-bar-prior value > 20-bar average high − low × configured factor
Calculation: Choppy = 10-bar average of high − low < 50-bar average of high − low
Calculation: Bullish score = 2 × confirmed low sweep + bull impulse + (close > mid EMA AND mid EMA > slow EMA) + (higher-timeframe mid EMA > higher-timeframe slow EMA) + configured NY session + trending + NOT choppy; each boolean contributes 1
Calculation: Bearish score = 2 × confirmed high sweep + bear impulse + (close < mid EMA AND mid EMA < slow EMA) + (higher-timeframe mid EMA < higher-timeframe slow EMA) + configured NY session + trending + NOT choppy; each boolean contributes 1
Calculation: Mid and slow EMAs = EMAs of close, with the mid EMA using a shorter lookback than the slow EMA; higher-timeframe EMAs use bars aggregated to a timeframe higher than the chart timeframe and the current, still-forming higher-timeframe bar
Long: (A+ only enabled AND bullish score >= configured A+ threshold OR A+ only disabled AND bullish score >= 4) AND position is flat or short
Short: (A+ only enabled AND bearish score >= configured A+ threshold OR A+ only disabled AND bearish score >= 4) AND position is flat or long
Exit: Long, low <= close − ATR × configured stop multiple OR high >= close + ATR × configured target multiple
Exit: Short, high >= close + ATR × configured stop multiple OR low <= close − ATR × configured target multiple