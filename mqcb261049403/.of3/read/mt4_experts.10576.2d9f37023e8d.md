Long: no orders AND (mode is forced long OR (mode follows trend AND current chart-bar close > LWMA(close on T1 bars, lookback A, last completed T1 bar)))
Short: no orders AND (mode is forced short OR (mode follows trend AND current chart-bar close < LWMA(close on T1 bars, lookback A, last completed T1 bar)))
Long: no orders AND mode follows trend AND current chart-bar close > EMA(close on chart bars, lookback B, last completed chart bar)
Short: no orders AND mode follows trend AND current chart-bar close < EMA(close on chart bars, lookback B, last completed chart bar)
Long: reversal enabled AND order count > 0 AND previous completed chart-bar close > EMA(close on chart bars, lookback B, last completed chart bar)
Short: reversal enabled AND order count > 0 AND previous completed chart-bar close < EMA(close on chart bars, lookback B, last completed chart bar)
Long: latest order is long AND (order count = add-stage count A1 OR order count = add-stage count A2) AND maximum-order setting A - 1 >= order count AND (latest entry price - current close) / point >= add/target distance A
Short: latest order is short AND (order count = add-stage count A1 OR order count = add-stage count A2) AND maximum-order setting A - 1 >= order count AND (current close - latest entry price) / point >= add/target distance A
Long: latest order is long AND (order count = add-stage count B1 OR order count = add-stage count B2 OR order count = add-stage count B3 OR order count = add-stage count B4) AND maximum-order setting B - 1 >= order count AND (latest entry price - current close) / point >= add/target distance B
Short: latest order is short AND (order count = add-stage count B1 OR order count = add-stage count B2 OR order count = add-stage count B3 OR order count = add-stage count B4) AND maximum-order setting B - 1 >= order count AND (current close - latest entry price) / point >= add/target distance B
Exit: long, (current close - entry price) / point >= add/target distance A
Exit: short, (entry price - current close) / point >= add/target distance A
Exit: long, (current close - entry price) / point >= add/target distance B
Exit: short, (entry price - current close) / point >= add/target distance B
Exit: long, latest order is long AND stop-loss enabled AND order count = maximum-order setting B - 1 AND (entry price - current close) / point >= stop-loss distance
Exit: short, latest order is short AND stop-loss enabled AND order count = maximum-order setting B - 1 AND (current close - entry price) / point >= stop-loss distance
Exit: long, trade profit + swap > profit-close threshold A
Exit: short, trade profit + swap > profit-close threshold A
Exit: long, trade profit + swap > profit-close threshold B
Exit: short, trade profit + swap > profit-close threshold B