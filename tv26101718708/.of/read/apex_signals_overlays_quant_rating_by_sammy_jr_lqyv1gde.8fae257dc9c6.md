Calculation: Supertrend = with basis=(high+low)/2 and ATR (Wilder) of the chart timeframe, upper=basis+factor*ATR, lower=basis-factor*ATR; final upper band only moves down unless previous close was above it, final lower band only moves up unless previous close was below it; trend is up when close is above the final upper band, down when close is below the final lower band, otherwise unchanged
Long: Supertrend trend is up on this bar AND was down on the previous bar
Long: RSI < oversold threshold AND low <= lowest low of the last N bars including current bar AND close > open
Short: Supertrend trend is down on this bar AND was up on the previous bar
Short: RSI > overbought threshold AND high >= highest high of the last N bars including current bar AND close < open
Exit: long, low <= entry price - stop multiple * ATR at entry bar (stop loss)
Exit: long, high >= entry price + TP1 multiple * stop multiple * ATR at entry bar (take profit 1)
Exit: long, high >= entry price + TP2 multiple * stop multiple * ATR at entry bar (take profit 2, TP2 multiple greater than TP1 multiple)
Exit: short, high >= entry price + stop multiple * ATR at entry bar (stop loss)
Exit: short, low <= entry price - TP1 multiple * stop multiple * ATR at entry bar (take profit 1)
Exit: short, low <= entry price - TP2 multiple * stop multiple * ATR at entry bar (take profit 2, TP2 multiple greater than TP1 multiple)