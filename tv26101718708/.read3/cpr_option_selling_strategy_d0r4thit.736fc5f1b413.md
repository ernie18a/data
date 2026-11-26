Calculation: CPR top = MAX(2 * (high + low + close) / 3 - (high + low) / 2, (high + low) / 2) with high, low, close of T1 last completed bar
Calculation: CPR bottom = MIN(2 * (high + low + close) / 3 - (high + low) / 2, (high + low) / 2) with high, low, close of T1 last completed bar
Calculation: T1 opening bar = period start(datetime, T1) > period start(datetime[1], T1)
Option: sell put, T1 opening bar[1] AND source[1] > CPR top AND day of week of datetime in trade days AND datetime in backtest range
Option: sell call, T1 opening bar[1] AND source[1] < CPR bottom AND day of week of datetime in trade days AND datetime in backtest range
Option: sell call, T1 opening bar[1] AND source[1] > CPR bottom AND source[1] < CPR top AND day of week of datetime in trade days AND datetime in backtest range
Option: sell put, T1 opening bar[1] AND source[1] > CPR bottom AND source[1] < CPR top AND day of week of datetime in trade days AND datetime in backtest range