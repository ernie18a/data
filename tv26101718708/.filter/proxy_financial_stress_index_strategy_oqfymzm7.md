# Proxy Financial Stress Index Strategy

- url: https://www.tradingview.com/script/OQFyMZm7/
- type: strategy
- pine_id: PUB;4804818c0f054b6ca27a6f087ab330ea
- version: 1.0

## Description

This strategy is based on a Proxy Financial Stress Index constructed using several key financial indicators. The strategy goes long when the financial stress index crosses below a user-defined threshold, signaling a potential reduction in market stress. Once a position is opened, it is held for a predetermined number of bars (periods), after which it is automatically closed.

The financial stress index is composed of several normalized indicators, each representing different market aspects:

    VIX - Market volatility.
    US 10-Year Treasury Yield - Bond market.
    Dollar Index (DXY) - Currency market.
    S&P 500 Index - Stock market.
    EUR/USD - Currency exchange rate.
    High-Yield Corporate Bond ETF (HYG) - Corporate bond market.

Each component is normalized using a Z-score (based on the user-defined moving average and standard deviation lengths) and weighted according to user inputs. The aggregated index reflects overall market stress.

The strategy enters a long position when the stress index crosses below a specified threshold from above, indicating reduced financial stress. The position is held for a defined holding period before being closed automatically.
Scientific References:

The concept of a financial stress index is derived from research that combines multiple financial variables to measure systemic risks in the financial markets. Key research includes:

The Financial Stress Index developed by various Federal Reserve banks, including the Cleveland Financial Stress Index (CFSI)​


Bank of America Merrill Lynch Option Volatility Estimate (MOVE) Index as a measure of interest rate volatility, which correlates with financial stress​


These indices are widely used in economic research to gauge financial instability and help in policy decisions. They track real-time fluctuations in various markets and are often used to anticipate economic downturns or periods of high financial risk.

## Source Code

````pine
//@version=5
strategy("Proxy Financial Stress Index Strategy", overlay=false)

// User Inputs
sma_length = input.int(41, title="SMA Length", minval=1)
std_dev_length = input.int(20, title="Standard Deviation Length", minval=1)
threshold = input.float(-0.8, title="Threshold for Stress Index", step=0.1)
holding_period = input.int(28, title="Holding Period (in Bars)", minval=1)

// Weight Inputs for Components
vix_weight = input.float(0.4, title="Weight for VIX", step=0.01)
us10y_weight = input.float(0.2, title="Weight for US 10Y", step=0.01)
dxy_weight = input.float(0.12, title="Weight for DXY", step=0.01)
sp500_weight = input.float(0.06, title="Weight for S&P 500", step=0.01)
eurusd_weight = input.float(0.1, title="Weight for EUR/USD", step=0.01)
hyg_weight = input.float(0.18, title="Weight for HYG", step=0.01)

// Data Sources (Proxy for Stress Index)
vix = request.security("CBOE:VIX", "D", close)  // Volatility Index (VIX)
us10y = request.security("TVC:US10Y", "D", close)  // US 10-Year Treasury Yield
dxy = request.security("TVC:DXY", "D", close)  // Dollar Index (DXY)
sp500 = request.security("SP:SPX", "D", close)  // S&P 500 Index
eurusd = request.security("FX_IDC:EURUSD", "D", close)  // Euro-Dollar Exchange Rate
hyg = request.security("AMEX:HYG", "D", close)  // High-Yield Corporate Bond ETF

// Normalization of Data (Z-Score)
normalize(src, sma_len, stddev_len) =>
    sma = ta.sma(src, sma_len)  // Simple Moving Average
    std_dev = ta.stdev(src, stddev_len)  // Standard Deviation
    (src - sma) / std_dev

// Normalized Values
vix_normalized = normalize(vix, sma_length, std_dev_length)
us10y_normalized = normalize(us10y, sma_length, std_dev_length)
dxy_normalized = normalize(dxy, sma_length, std_dev_length)
sp500_normalized = normalize(sp500, sma_length, std_dev_length)
eurusd_normalized = normalize(eurusd, sma_length, std_dev_length)
hyg_normalized = normalize(hyg, sma_length, std_dev_length)

// Weighted and Aggregated Components
stress_index = (vix_normalized * vix_weight) + (us10y_normalized * us10y_weight) +
               (dxy_normalized * dxy_weight) + (sp500_normalized * sp500_weight) +
               (eurusd_normalized * eurusd_weight) + (hyg_normalized * hyg_weight)

// Plot the Stress Index
plot(stress_index, title="Proxy Financial Stress Index", color=color.white)
hline(threshold, "Threshold Line", color=color.gray)

// Variable to Track Position and Holding Period
var int bars_in_position = na
var bool position_open = false

// Strategy Logic: Enter Long when Stress Index crosses below the threshold
if ta.crossover(threshold, stress_index) and strategy.opentrades == 0
    strategy.entry("Long", strategy.long)
    bars_in_position := 0
    position_open := true

// Increment the bar counter when a position is open
if strategy.opentrades > 0
    bars_in_position += 1
    position_open := true
else
    position_open := false

// Close the position after the specified holding period
if bars_in_position >= holding_period
    strategy.close("Long")
    bars_in_position := na  // Reset bar counter
    position_open := false

// Set background color based on position status
bgcolor(position_open ? color.new(color.green, 50) : na)
````
