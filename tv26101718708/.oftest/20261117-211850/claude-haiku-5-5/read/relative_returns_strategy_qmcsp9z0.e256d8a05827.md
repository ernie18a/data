Calculation: index_close = close of index_instrument on index_timeframe, using the index_timeframe bar still forming
Calculation: stock_return = (close - close[loopback]) / close
Calculation: index_return = (index_close - index_close[loopback]) / index_close
Calculation: stock_return_ma = moving average of stock_return with type ma_type and length ma_length
Calculation: index_return_ma = moving average of index_return with type ma_type and length ma_length
Calculation: relative_returns = stock_return - index_return
Calculation: relative_returns_ma = moving average of relative_returns with type ma_type and length ma_length
Long: ((use_stop_and_index_returns AND use_stop_and_index_returns_ma AND stock_return_ma > index_return_ma) OR (use_stop_and_index_returns AND NOT use_stop_and_index_returns_ma AND stock_return > index_return) OR (NOT use_stop_and_index_returns AND relative_returns > relative_returns_ma)) AND datetime >= backtest_start_time AND datetime <= backtest_end_time
Exit: long, (use_stop_and_index_returns AND use_stop_and_index_returns_ma AND stock_return_ma < index_return_ma) OR (use_stop_and_index_returns AND NOT use_stop_and_index_returns_ma AND stock_return < index_return) OR (NOT use_stop_and_index_returns AND relative_returns < relative_returns_ma)