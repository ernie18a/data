Calculation: Mid(N) = (highest high over last N bars + lowest low over last N bars) / 2
Calculation: LeadA = (Mid(short N) + Mid(medium N)) / 2; LeadB = Mid(long N); short N < medium N < long N
Calculation: WeeklyLeadA/WeeklyLeadB = LeadA/LeadB computed on weekly aggregated bars (higher timeframe than the chart, and higher than the daily bars), using the still-forming weekly bar. DailyLeadA/DailyLeadB = LeadA/LeadB computed on daily aggregated bars (higher than or equal to the chart timeframe, lower than weekly), using the still-forming daily bar. Both use the same N values.
Long: WeeklyLeadA > WeeklyLeadB OR DailyLeadA > DailyLeadB
Short: WeeklyLeadA < WeeklyLeadB OR DailyLeadA < DailyLeadB