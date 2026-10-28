Calculation: EMA fast and EMA slow = exponential moving averages of close, with fast lookback shorter than slow lookback
Calculation: Confirmed swing high/low = pivot high/low using equal left and right lookbacks; use the latest confirmed pivot, not a forming pivot
Calculation: Stochastic RSI = RSI of close, normalized between its rolling lowest and highest RSI, then smoothed into %K and %D with %K's smoothing lookback shorter than %D's
Calculation: Average volume = simple moving average of volume
Long: EMA fast > EMA slow AND (low <= EMA fast AND high >= EMA slow OR low is within 0.5% of the latest confirmed swing low) AND %K < 20 AND %D < 20 AND %K crosses above %D AND volume > average volume AND close > open
Short: EMA fast < EMA slow AND (low <= EMA fast AND high >= EMA slow OR high is within 0.5% of the latest confirmed swing high) AND %K > 80 AND %D > 80 AND %K crosses below %D AND volume > average volume AND close < open
Exit: long, close <= latest confirmed swing low OR close >= latest confirmed swing high
Exit: short, close >= latest confirmed swing high OR close <= latest confirmed swing low