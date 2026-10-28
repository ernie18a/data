Calculation: Up move = current close minus close at the move lookback bars ago > move threshold × ATR; down move = current close minus close at the move lookback bars ago < −move threshold × ATR
Calculation: Up watch = bars since the latest up move ≤ watch-window length; down watch = bars since the latest down move ≤ watch-window length (reset the count to zero on a qualifying move, otherwise increment it)
Calculation: Range position = (current close − lowest low over the range lookback) ÷ (highest high over the range lookback − lowest low over the range); use 0.5 when the denominator is zero
Calculation: Volume ratio = current volume ÷ its simple moving average over the volume lookback; use 1 when the average is zero
Calculation: Raw oscillator = (if up watch and range position ≥ top-zone threshold, max(volume ratio − 1, 0) × range position, otherwise 0) + (if down watch and range position ≤ bottom-zone threshold, −max(volume ratio − 1, 0) × (1 − range position), otherwise 0)
Calculation: Oscillator = EMA of raw oscillator over the smoothing length
Calculation: Signal level = positive threshold; negative threshold = −signal level
Short: oscillator crosses above the positive threshold (current oscillator > threshold AND previous oscillator ≤ threshold)
Long: oscillator crosses below the negative threshold (current oscillator < negative threshold AND previous oscillator ≥ negative threshold)