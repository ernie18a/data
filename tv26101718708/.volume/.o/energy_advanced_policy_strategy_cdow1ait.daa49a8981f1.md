Calculation: Bullish and bearish policy-event counts = start at 0; on each qualifying event increment its count, capped at 5; every fifth bar decrement both counts by 1, floored at 0.
Calculation: Policy event = volume > 20-bar average volume × event-volume threshold AND absolute one-bar close change (%) > event-price threshold; bullish event requires positive change and RSI < 80, bearish event requires negative change and RSI > 20. Events are detected only when policy detection is enabled.
Calculation: Effective sentiment = manual sentiment, except when news filtering is enabled: positive if bullish count > bearish count and bullish count ≥ 2; negative if bearish count > bullish count and bearish count ≥ 2; neutral if the counts are equal; otherwise retain manual sentiment.
Calculation: Sentiment strength = absolute difference between bullish and bearish policy-event counts / 5.
Calculation: Bollinger squeeze = (upper band − lower band) / middle band < 0.1.
Long: policy detection enabled AND bullish policy event
Short: policy detection enabled AND bearish policy event
Long: position is flat AND (effective sentiment is positive OR bullish policy-event count ≥ 2) AND fast EMA > slower EMA AND close > long-term SMA AND RSI < overbought threshold AND MACD line > signal line AND close change over 5 bars > 0 AND NOT Bollinger squeeze
Long: position is flat AND the previous close ≤ its 2-period SMA AND close > its 2-period SMA
Exit: long, RSI > overbought threshold OR fast EMA < slower EMA OR close < long-term SMA OR MACD line < signal line OR effective sentiment is negative OR bearish policy-event count ≥ 2 OR close change over 5 bars < −2.0 OR low ≤ entry price × (1 − stop-loss percentage) OR high ≥ entry price × (1 + take-profit percentage)
Exit: long, low ≤ entry price × (1 − stop-loss percentage)