Calculation: short-term oscillator = RSI(ALMA(selected source price, shorter short-term ALMA lookback, shared ALMA offset, shared ALMA sigma) - ALMA(selected source price, longer short-term ALMA lookback, shared ALMA offset, shared ALMA sigma), short-term RSI lookback) - shared RSI midpoint
Calculation: smoothed short-term oscillator = ALMA(short-term oscillator, signal ALMA lookback, shared ALMA offset, shared ALMA sigma)
Calculation: long-term oscillator = RSI(ALMA(selected source price, long-term ALMA lookback, shared ALMA offset, shared ALMA sigma), long-term RSI lookback) - shared RSI midpoint
Long: short-term oscillator is above its centerline
Short: short-term oscillator is at or below its centerline
Long: smoothed short-term oscillator is above its value on the immediately previous chart bar
Short: smoothed short-term oscillator is at or below its value on the immediately previous chart bar
Long: smoothed short-term oscillator is above its value on the immediately previous chart bar AND its value on the immediately previous chart bar is below its value on the next older chart bar
Short: smoothed short-term oscillator is below its value on the immediately previous chart bar AND its value on the immediately previous chart bar is above its value on the next older chart bar
Long: long-term oscillator is above its value on the immediately previous chart bar
Short: long-term oscillator is at or below its value on the immediately previous chart bar
Long: on chart bars, long-term oscillator from the still-forming T1 bar is above its centerline
Short: on chart bars, long-term oscillator from the still-forming T1 bar is at or below its centerline