Calculation: UpBar = max(0, close / open - 1) * volume / SMA(volume, volume lookback), on completed bars
Calculation: DownBar = max(0, 1 - close / open) * volume / SMA(volume, volume lookback), on completed bars
Calculation: UpHour(h) = mean of UpBar over completed T1 bars in the comparison window up to the current bar whose hour-of-day equals h, or n/a if fewer than hour minimum samples such bars
Calculation: DownHour(h) = mean of DownBar over completed T1 bars in the comparison window up to the current bar whose hour-of-day equals h, or n/a if fewer than hour minimum samples such bars
Calculation: UpDay(d) = mean of UpBar over completed T2 bars in the comparison window up to the current bar whose day-of-week equals d, or n/a if fewer than day minimum samples such bars
Calculation: DownDay(d) = mean of DownBar over completed T2 bars in the comparison window up to the current bar whose day-of-week equals d, or n/a if fewer than day minimum samples such bars
Calculation: UpHourNorm = mean of UpHour(h) over the hours h whose value is not n/a
Calculation: DownHourNorm = mean of DownHour(h) over the hours h whose value is not n/a
Calculation: UpDayNorm = mean of UpDay(d) over the days d whose value is not n/a
Calculation: DownDayNorm = mean of DownDay(d) over the days d whose value is not n/a
Calculation: NextHour = (hour-of-day of the current bar + 1) mod 24
Calculation: NextDay = (day-of-week of the current bar + 1) mod 7
Long: chart timeframe = T1 AND UpHour(NextHour) > UpHourNorm * extreme threshold AND (NOT DownHour(NextHour) > DownHourNorm * extreme threshold OR UpHour(NextHour) >= DownHour(NextHour))
Short: chart timeframe = T1 AND DownHour(NextHour) > DownHourNorm * extreme threshold AND (NOT UpHour(NextHour) > UpHourNorm * extreme threshold OR DownHour(NextHour) > UpHour(NextHour))
Long: chart timeframe = T2 AND UpDay(NextDay) > UpDayNorm * extreme threshold AND (NOT DownDay(NextDay) > DownDayNorm * extreme threshold OR UpDay(NextDay) >= DownDay(NextDay))
Short: chart timeframe = T2 AND DownDay(NextDay) > DownDayNorm * extreme threshold AND (NOT UpDay(NextDay) > UpDayNorm * extreme threshold OR DownDay(NextDay) > UpDay(NextDay))