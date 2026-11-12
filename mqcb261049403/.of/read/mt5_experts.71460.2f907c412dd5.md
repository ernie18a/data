Calculation: Range High = highest high of lower-timeframe bars (than chart timeframe) from the day's range start time to range end time
Calculation: Range Low = lowest low of lower-timeframe bars (than chart timeframe) from the day's range start time to range end time
Long: current time > range end time AND current time <= trading end time AND no entry yet today AND last completed chart-timeframe bar close > Range High AND that bar's open time != range end time
Short: current time > range end time AND current time <= trading end time AND no entry yet today AND last completed chart-timeframe bar close < Range Low AND that bar's open time != range end time
Exit: long, price >= Range High + (Range High - Range Low) OR price <= Range Low OR current time > trading end time
Exit: short, price <= Range Low - (Range High - Range Low) OR price >= Range High OR current time > trading end time