Calculation: EarlyBuzz = cumulative chart-bar volume from 09:30 through the current chart bar divided by the mean cumulative volume through the same minute over the prior Lookback days, calculated on T1 bars using the latest T1 value (forming in realtime, completed historically)
Calculation: RegularBuzz = volume of the T2 bar divided by the mean volume at the same session slot over the prior Lookback days; use the current T2 value during 09:30–09:44, the previous T2 value on realtime bars afterward, and the current T2 value on historical bars
Calculation: Buzz = EarlyBuzz when time is 09:30–09:44; otherwise RegularBuzz
Long: Buzz >= High threshold AND close >= open
Short: (Buzz >= High threshold AND close < open) OR (Buzz < High threshold AND Buzz < Low threshold)