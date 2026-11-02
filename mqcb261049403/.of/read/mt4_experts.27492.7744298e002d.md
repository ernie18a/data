Calculation: Entry reference price = chart-bar open, used as an approximation of the opening bid; opening ask = opening bid + an assumed spread.
Long: At the start of a chart bar, absolute difference between opening bid and the close two bars ago > a distance threshold AND the low two bars ago < the previous bar's high AND the close two bars ago < its close-based simple moving average.
Short: At the start of a chart bar, absolute difference between opening ask and the close two bars ago > a distance threshold AND the previous bar's low < the high two bars ago AND the close two bars ago > its close-based simple moving average.
Exit: long, price <= entry price - stop-loss distance OR price >= entry price + take-profit distance.
Exit: short, price >= entry price + stop-loss distance OR price <= entry price - take-profit distance.
Exit: short, price has fallen more than an activation distance below entry price AND subsequently rises to or above entry price - a stop-offset distance.
Exit: long, MACD main line on the last completed higher-timeframe bar, or chart-timeframe bar if the chart is already at that timeframe, < its signal line AND MACD main line != 0.
Exit: short, MACD main line on the last completed higher-timeframe bar, or chart-timeframe bar if the chart is already at that timeframe, > its signal line AND MACD main line != 0.