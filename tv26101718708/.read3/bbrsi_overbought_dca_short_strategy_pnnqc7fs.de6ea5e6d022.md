Calculation: CumDev(k) = sum over i=1..k of first_averaging_deviation * averaging_deviation_multiplier^(i-1)
Short: BollingerPercentB(close, bollinger_period, bollinger_deviation, T1, last completed bar) crosses above bollinger_level AND RSI(close, rsi_period, T2, last completed bar) crosses above rsi_level AND position side is flat
Short: position side is short AND filled averaging orders < averaging_order_count AND close >= base entry price * (1 + CumDev(filled averaging orders + 1) / 100)
Exit: short, close <= average entry price * (1 - take_profit_percent / 100)