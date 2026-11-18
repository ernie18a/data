Calculation: Long stop price = low[1] captured when a long position opens
Calculation: Short stop price = high[1] captured when a short position opens
Calculation: Long target price = entry price + (entry price - Long stop price) * risk-to-reward parameter
Calculation: Short target price = entry price - (Short stop price - entry price) * risk-to-reward parameter
Long: crosses above(selected moving average type A of source A over lookback A on T1's last completed bar, sampled on chart bars with gap setting A, selected moving average type B of source B over lookback B on T2's last completed bar, sampled on chart bars with gap setting B) AND chart bar is confirmed AND position is flat
Short: crosses below(selected moving average type A of source A over lookback A on T1's last completed bar, sampled on chart bars with gap setting A, selected moving average type B of source B over lookback B on T2's last completed bar, sampled on chart bars with gap setting B) AND chart bar is confirmed AND position is flat
Exit: long, low <= Long stop price OR high >= Long target price
Exit: short, high >= Short stop price OR low <= Short target price