Long: Stochastic on the chart timeframe, using the last completed bar, < oversold threshold AND hour(datetime) >= 21 OR hour(datetime) < 6 AND no open position
Short: Stochastic on the chart timeframe, using the last completed bar, > overbought threshold AND hour(datetime) >= 21 OR hour(datetime) < 6 AND no open position
Exit: long, low <= entry price - configured stop-loss distance OR high >= entry price + configured take-profit distance
Exit: short, high >= entry price + configured stop-loss distance OR low <= entry price - configured take-profit distance