Calculation: Long vote count = number of the following five conditions true on the current bar: RSI is below its lower threshold and previous RSI is at or below that threshold, with close above the long-term EMA if the trend filter is enabled; SuperTrend changes from bearish to bullish; MACD line crosses above its signal line; fast EMA is above medium EMA and medium EMA is above slow EMA, and fast EMA was at or below medium EMA on either of the previous two bars; close is below the lower Bollinger Band and previous close was at or below the previous lower band.
Calculation: Short vote count = number of the following five conditions true on the current bar: RSI is above its upper threshold and previous RSI is at or above that threshold, with close below the long-term EMA if the trend filter is enabled; SuperTrend changes from bullish to bearish; MACD line crosses below its signal line; fast EMA is below medium EMA and medium EMA is below slow EMA, and fast EMA was at or above medium EMA on either of the previous two bars; close is above the upper Bollinger Band and previous close was at or above the previous upper band.
Long: RSI < lower threshold.
Short: RSI > upper threshold.
Long: close > long-term EMA.
Short: close < long-term EMA.
Long: SuperTrend is bullish.
Short: SuperTrend is bearish.
Long: RSI < lower threshold AND previous RSI <= lower threshold AND (trend filter disabled OR close > long-term EMA).
Short: RSI > upper threshold AND previous RSI >= upper threshold AND (trend filter disabled OR close < long-term EMA).
Long: SuperTrend changes from bearish to bullish.
Short: SuperTrend changes from bullish to bearish.
Long: MACD line crosses above its signal line.
Short: MACD line crosses below its signal line.
Long: fast EMA > medium EMA AND medium EMA > slow EMA AND (previous fast EMA <= previous medium EMA OR fast EMA two bars ago <= medium EMA two bars ago).
Short: fast EMA < medium EMA AND medium EMA < slow EMA AND (previous fast EMA >= previous medium EMA OR fast EMA two bars ago >= medium EMA two bars ago).
Long: close < lower Bollinger Band AND previous close <= previous lower Bollinger Band.
Short: close > upper Bollinger Band AND previous close >= previous upper Bollinger Band.
Long: long vote count >= minimum confirmations.
Short: short vote count >= minimum confirmations.
Exit: long, take-profit/stop-loss enabled AND (high >= previous close × (1 + take-profit percentage) OR low <= previous close × (1 - stop-loss percentage)).
Exit: short, take-profit/stop-loss enabled AND (low <= previous close × (1 - take-profit percentage) OR high >= previous close × (1 + stop-loss percentage)).