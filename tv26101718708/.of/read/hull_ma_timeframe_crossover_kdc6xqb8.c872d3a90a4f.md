Calculation: Price = selected OHLC price source
Calculation: Long-term MA = selected moving-average type applied to Price over a longer lookback
Calculation: Short-term MA = same moving-average type applied to Price over a shorter lookback than the Long-term MA
Calculation: ATR trailing stop = recursive stop that trails Price by ATR multiplied by a sensitivity factor; when Price and its previous value are both above the previous stop, use the greater of the previous stop and Price minus the ATR distance; when both are below, use the lesser of the previous stop and Price plus the ATR distance; otherwise use Price minus the ATR distance if Price is above the previous stop, and Price plus the ATR distance if below
Calculation: Higher-timeframe Price = Price from the selected timeframe, which is higher than the chart timeframe; use the bar still forming
Long: Long-term MA > its previous-bar value AND Short-term MA > Higher-timeframe Price AND Short-term MA > Long-term MA AND Long-term MA crosses above ATR trailing stop
Short: Long-term MA < its previous-bar value AND Short-term MA < Higher-timeframe Price AND Short-term MA < Long-term MA AND ATR trailing stop crosses above Long-term MA
Exit: long, close price is above entry price by the configured take-profit percentage OR below entry price by the configured stop-loss percentage
Exit: short, close price is below entry price by the configured take-profit percentage OR above entry price by the configured stop-loss percentage
Exit: long, when ATR stop exit is enabled, (Price > ATR trailing stop AND Long-term MA crosses above ATR trailing stop) OR (Price < ATR trailing stop AND ATR trailing stop crosses above Long-term MA)
Exit: short, when ATR stop exit is enabled, (Price > ATR trailing stop AND Long-term MA crosses above ATR trailing stop) OR (Price < ATR trailing stop AND ATR trailing stop crosses above Long-term MA)