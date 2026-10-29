Calculation: Smoothed stochastic of price = EMA of 100 × (close − lowest low) / (highest high − lowest low) over a lookback
Calculation: DSS = EMA of 100 × (smoothed stochastic of price − its lowest value) / (its highest value − its lowest value) over the same lookback
Long: On the chart timeframe’s last completed bars, smoothed stochastic of price was at least DSS two bars ago AND DSS is now greater than smoothed stochastic of price
Short: On the chart timeframe’s last completed bars, DSS was at least smoothed stochastic of price two bars ago AND smoothed stochastic of price is now greater than DSS
Exit: long, smoothed stochastic of price > DSS on the last completed bar
Exit: short, DSS > smoothed stochastic of price on the last completed bar