Calculation: Selected moving average = selected moving-average type applied to close over a lookback
Long: a random trigger occurs AND the state machine accepts a transition AND close > selected moving average
Short: a random trigger occurs AND the state machine accepts a transition AND close < selected moving average
Exit: Long, low <= entry price − risk distance OR high >= entry price + risk distance × reward/risk ratio OR bars since entry >= holding duration OR previous close >= previous moving average AND close < selected moving average
Exit: Short, high >= entry price + risk distance OR low <= entry price − risk distance × reward/risk ratio OR bars since entry >= holding duration OR previous close <= previous moving average AND close > selected moving average