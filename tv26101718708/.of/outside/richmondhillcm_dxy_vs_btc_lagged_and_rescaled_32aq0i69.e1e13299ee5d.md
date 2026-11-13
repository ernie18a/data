Trade the Bitcoin (BTC) price series, using the US Dollar Index (DXY) as an external leading input. Both series use closing prices on the chart's timeframe.

1. Lag selection. For every candidate lag in a configured range, compute the rolling correlation over a correlation window between DXY shifted back by that many bars and BTC. Choose the lag with the most negative correlation. On ties, keep the first (smallest) lag found. If no lag yields a valid correlation, use a manual default lag. A manual-override mode may use the default lag instead of the scan.

2. Normalization. Take the lagged DXY series (the DXY value lag bars ago). Over a rolling normalization window, compute its highest and lowest values. Scale BTC to 0-100 using BTC's own rolling lowest and highest over the same window. Scale lagged DXY to 0-100 using its own rolling extremes, then invert it (100 minus the value) so it should move with BTC.

3. Projection. Take the current, un-lagged DXY and scale it to 0-100 using the rolling min and max of the LAGGED DXY series from step 2. Invert it (100 minus the value). This is the projected BTC level implied by the dollar's current position. Gap = projected level minus normalized BTC.

4. Reliability filter. Compute the rolling correlation over the correlation window between lagged DXY and BTC, using the lag from step 1. Flip its sign, because DXY is shown inverted. The overlay is reliable only when this flipped correlation is at or above a modest positive threshold. When it is near zero or negative (the inverse relationship has broken down), treat the dollar signal as unreliable.

5. Decisions, evaluated on each bar:
- Reliable and gap > 0 (BTC sits below where the inverted dollar implies): go or stay LONG BTC.
- Reliable and gap <= 0 (BTC sits above the implied level): go or stay SHORT BTC.
- Not reliable: no directional signal. Stay flat, and exit any open position.
- Exit or reverse when the gap changes sign, or when reliability is lost.

No other conditions apply. The only inputs are the DXY and BTC closes.