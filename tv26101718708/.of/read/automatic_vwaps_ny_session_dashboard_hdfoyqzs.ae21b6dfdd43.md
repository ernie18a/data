Calculation: Daily VWAP = volume-weighted average of OHLC4 from the current futures-day 18:00 New York reset bar through the current bar.
Calculation: NY VWAP = volume-weighted average of OHLC4 from the current New York session’s 09:30 reset bar through the current bar; only available from 09:30 to 16:00 New York time.
Calculation: Prior-session NY VWAP = volume-weighted average of OHLC4 from the previous New York session’s 09:30 reset bar through the current bar; only available from 09:30 to 16:00 New York time.
Calculation: High-anchored VWAP = volume-weighted average of OHLC4 from the latest bar that sets or ties the futures-day high through the current bar; the anchor resets at 18:00 New York time.
Calculation: Low-anchored VWAP = volume-weighted average of OHLC4 from the latest bar that sets or ties the futures-day low through the current bar; the anchor resets at 18:00 New York time.
Calculation: Opening-range high and low = highest high and lowest low from bars beginning 09:30 through 09:45 New York time.
Calculation: VWAP-above count = number of the five VWAPs above whose value is available and below the current close.
Long: Close > Daily VWAP OR Close > NY VWAP OR Close > Prior-session NY VWAP OR Close > High-anchored VWAP OR Close > Low-anchored VWAP OR Close > Opening-range high OR VWAP-above count >= 4.
Short: Close <= Daily VWAP OR Close <= NY VWAP OR Close <= Prior-session NY VWAP OR Close <= High-anchored VWAP OR Close <= Low-anchored VWAP OR Close < Opening-range low OR VWAP-above count <= 1.