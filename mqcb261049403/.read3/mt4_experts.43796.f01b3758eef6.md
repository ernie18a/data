Calculation: latest band-touch side = upper if the most recent completed chart bar with high above its upper Bollinger Band or low below its lower Bollinger Band had high above its upper Bollinger Band; otherwise lower; undefined if no such bar exists
Calculation: open trade profit = sum of profit on all open market orders
Calculation: invested amount = total open lots × open price of the open order at index zero × tick value ÷ tick size ÷ investment divisor
Long: no open orders AND latest band-touch side is lower AND current forming bar close > middle Bollinger Band(close, lookback, deviation multiplier) on the last completed chart bar AND last completed chart bar open < that bar's middle Bollinger Band(close, lookback, deviation multiplier)
Short: no open orders AND latest band-touch side is upper AND current forming bar close < middle Bollinger Band(close, lookback, deviation multiplier) on the last completed chart bar AND last completed chart bar open > that bar's middle Bollinger Band(close, lookback, deviation multiplier)
Long: close on the last completed chart bar > its upper Bollinger Band(close, lookback, deviation multiplier) AND close on the second most recent completed chart bar > its upper Bollinger Band(close, lookback, deviation multiplier)
Short: close on the last completed chart bar < its lower Bollinger Band(close, lookback, deviation multiplier) AND close on the second most recent completed chart bar < its lower Bollinger Band(close, lookback, deviation multiplier)
Exit: long, open trade profit > invested amount × take-profit parameter
Exit: short, open trade profit > invested amount × take-profit parameter
Exit: long, open trade profit < -invested amount × stop-loss multiplier × take-profit parameter
Exit: short, open trade profit < -invested amount × stop-loss multiplier × take-profit parameter