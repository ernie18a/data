Calculation: RangeHigh = highest high of lower-timeframe bars (than the chart timeframe) from the daily range start time to the daily range end time
Calculation: RangeLow = lowest low of lower-timeframe bars (than the chart timeframe) from the daily range start time to the daily range end time
Long: current time > range end time AND last completed chart-timeframe bar close > RangeHigh AND that bar's open time != range end time AND no entry has been taken yet today
Short: current time > range end time AND last completed chart-timeframe bar close < RangeLow AND that bar's open time != range end time AND no entry has been taken yet today
Exit: long, price <= RangeLow OR price >= RangeHigh + (RangeHigh - RangeLow) OR current time > daily trading end time
Exit: short, price >= RangeHigh OR price <= RangeLow - (RangeHigh - RangeLow) OR current time > daily trading end time