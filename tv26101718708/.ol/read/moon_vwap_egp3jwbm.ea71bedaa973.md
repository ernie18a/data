Calculation: New Moon anchored VWAP = cumulative volume-weighted average of HLC3 since the latest New Moon timestamp
Calculation: GPS band for an event cycle = [cycle high − range × 0.65, cycle high − range × 0.618], where range is high minus low over the preceding completed cycle between consecutive events of the same type; use New Moon, Full Moon, total lunar eclipse, total solar eclipse, partial lunar eclipse, or partial solar eclipse cycles
Calculation: GPS-in-band = close is within any of the six GPS bands
Calculation: ATR = average true range over a shorter lookback
Calculation: Body-valid = absolute(close − open) ≥ ATR × a configurable fraction
Calculation: Date root = repeatedly sum the digits of the current UTC year, month, and day until one digit remains, preserving 11, 22, or 33
Calculation: Lunation number = floor((bar datetime − 2000-01-21 04:40 UTC) ÷ 29.5305882 days) + 1
Calculation: Lunation root = repeatedly sum the lunation-number digits until one digit remains, preserving 11, 22, or 33
Calculation: Price integer = round(abs(close) × 10^k), choosing the smallest k from 0 through 6 that makes the result at least 1000
Calculation: Price root = repeatedly sum the price-integer digits until one digit remains, preserving 11, 22, or 33
Calculation: Repeating price = the price integer ends in at least three identical nonzero digits
Calculation: Numerology match = price root equals date root or lunation root, or price root is 11, 22, or 33, or repeating price
Calculation: Numerology conflict = the one-digit reductions of price root and date root sum to 10, excluding master-number and repeating prices
Calculation: Moon event = a New Moon, First Quarter, Full Moon, or Last Quarter timestamp, or the first bar of lunation day 9, 18, or 27; quarter timestamps are halfway between adjacent New/Full timestamps
Calculation: Event window = the event bar through a configurable number of following bars, inclusive
Long: within event window AND no signal has fired in that window AND GPS-in-band AND Numerology match AND NOT Numerology conflict AND Body-valid AND close > open AND close > prior close AND (New Moon anchored VWAP is unavailable OR close > New Moon anchored VWAP)
Short: within event window AND no signal has fired in that window AND GPS-in-band AND Numerology match AND NOT Numerology conflict AND Body-valid AND close < open AND close < prior close AND (New Moon anchored VWAP is unavailable OR close < New Moon anchored VWAP) AND no long signal on this bar