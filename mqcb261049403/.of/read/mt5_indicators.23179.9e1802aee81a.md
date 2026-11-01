Calculation: Reference price = either the open of the forming higher-timeframe bar or the pivot point of the last completed higher-timeframe bar; the higher-timeframe boundaries may be shifted, and Sunday chart bars are included in the preceding period.
Calculation: Pivot point = (high + low + close) / 3 of the last completed higher-timeframe bar.
Calculation: Upper levels = reference price plus three increasing positive price offsets; lower levels = reference price minus three increasing positive price offsets.
Long: Close >= nearest upper level AND close < farthest upper level.
Short: Close <= nearest lower level AND close > farthest lower level.
Short: Close > any lower level minus a proximity offset AND close < that lower level plus the proximity offset AND (close <= pivot point minus a pivot proximity offset OR close >= pivot point plus that offset) AND (close <= forming higher-timeframe open minus an open proximity offset OR close >= that open plus that offset).