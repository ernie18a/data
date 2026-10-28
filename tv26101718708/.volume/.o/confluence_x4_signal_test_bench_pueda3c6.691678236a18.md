Calculation: MT-Stoch score = bullish votes minus bearish votes: three stochastic K/D comparisons using longest, middle, and shortest lookbacks; stochastic RSI above 20 / below 80; and the 100-bar percentile rank of its K/D ratio at or above / below 50.
Calculation: MCU score = bullish votes minus bearish votes across three groups: (1) price versus the Ichimoku cloud displaced 30 bars into the past, conversion line versus base line, and close versus close 30 bars ago; (2) ATR as a percentage of close versus its longer-term average, with close versus prior close and close versus EMA; (3) Bollinger/Keltner squeeze release and linear-regression momentum sign and direction.
Long: Within the date range AND the selected bullish trigger fires AND each enabled filter is bullish; bullish triggers are SMA short-lookback crossing above SMA long-lookback with ADX above its threshold and RSI below its ceiling; first bar RSI > 50, MACD line > 0, and Chaikin Money Flow > 0; first bar MT-Stoch score reaches its configured positive threshold; first bar MCU score reaches its configured positive threshold.
Short: Within the date range AND the selected bearish trigger fires AND each enabled filter is bearish; bearish triggers are SMA short-lookback crossing below SMA long-lookback with ADX above its threshold and RSI above its floor; first bar RSI < 50, MACD line < 0, and Chaikin Money Flow < 0; first bar MT-Stoch score reaches its configured negative threshold; first bar MCU score reaches its configured negative threshold.
Exit: long, elapsed bars since entry >= configured holding period
Exit: short, elapsed bars since entry >= configured holding period
Exit: long, selected bearish trigger fires
Exit: short, selected bullish trigger fires
Exit: long, low <= entry price - configured stop multiple × ATR
Exit: long, high >= entry price + configured target multiple × ATR
Exit: short, high >= entry price + configured stop multiple × ATR
Exit: short, low <= entry price - configured target multiple × ATR
Exit: long, RSI(14) crosses above 80
Exit: short, RSI(14) crosses below 20
Exit: long, outside the date range
Exit: short, outside the date range