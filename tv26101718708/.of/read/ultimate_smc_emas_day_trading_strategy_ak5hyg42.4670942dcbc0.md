Calculation: Higher-timeframe high/low = high/low of the higher-timeframe bar still forming, sampled on the chart timeframe
Calculation: Confirmed pivot high/low = a chart bar whose high/low is a pivot high/low confirmed using equal left and right lookbacks
Calculation: Order-block top/bottom = the high/low sampled at the order-block pivot lookback on the latest bar confirming a pivot high/low
Calculation: Fibonacci 0.618 level = order-block bottom + (order-block top − order-block bottom) × 0.618, updated when either pivot is confirmed
Calculation: Bullish FVG = current low > high two chart bars ago AND prior close > high two chart bars ago
Calculation: Bearish FVG = current high < low two chart bars ago AND prior close < low two chart bars ago
Long: flat AND close > long-term SMA AND short-term EMA > longer-term EMA AND (close <= Fibonacci 0.618 level OR low <= order-block bottom) AND (bullish FVG OR close crosses above short-term EMA)
Short: flat AND close < long-term SMA AND short-term EMA < longer-term EMA AND (close >= Fibonacci 0.618 level OR high >= order-block top) AND (bearish FVG OR close crosses below short-term EMA)
Exit: long, low <= higher-timeframe low captured at entry OR high >= higher-timeframe high captured at entry
Exit: short, high >= higher-timeframe high captured at entry OR low <= higher-timeframe low captured at entry