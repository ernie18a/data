Long: close < open AND volume > previous completed chart bar volume AND VWAP > prior completed chart bar VWAP AND Choppiness Index < trend threshold AND datetime is within the configured market session
Short: close > open AND volume > previous completed chart bar volume AND VWAP < prior completed chart bar VWAP AND Choppiness Index < trend threshold AND datetime is within the configured market session
Exit: long, datetime is outside the configured market session
Exit: short, datetime is outside the configured market session