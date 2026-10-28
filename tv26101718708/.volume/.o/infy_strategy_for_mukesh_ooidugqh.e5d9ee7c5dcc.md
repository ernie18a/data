Calculation: Linear-regression RSI = Wilder RSI of the linear regression of HLC3
Calculation: VWAP RSI = Wilder RSI of session VWAP of HLC3
Calculation: VWMA-regression RSI = Wilder RSI of the volume-weighted moving average of the linear regression of close
Long: VWAP RSI > its previous value AND Linear-regression RSI > its previous value AND VWAP RSI < its configured threshold AND bar time is within the configured session AND datetime >= the configured start date
Short: VWMA-regression RSI > its configured threshold AND VWMA-regression RSI < its previous value AND its previous value < its value two bars ago AND bar time is within the configured session AND datetime >= the configured start date
Exit: long, VWAP RSI crosses above its configured threshold OR bar high >= average entry price × (1 + configured long profit fraction), AND datetime >= the configured start date
Exit: short, VWMA-regression RSI > its previous value AND its value two bars ago > its previous value OR bar low <= average entry price × (1 − configured short profit fraction), AND datetime >= the configured start date