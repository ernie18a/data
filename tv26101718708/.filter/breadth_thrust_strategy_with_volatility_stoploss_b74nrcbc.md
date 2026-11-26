# Breadth Thrust Strategy with Volatility Stop-Loss

- url: https://www.tradingview.com/script/b74nRCBc/
- type: strategy
- pine_id: PUB;701762c2a8d04698865501d54a404b9a
- version: 1.0

## Description

The "Breadth Thrust Strategy with Volatility Stop-Loss" is a trading strategy designed to capitalize on market momentum while managing risk through volatility-based stop-losses. Here's a detailed breakdown of the strategy:
Strategy Overview:

Market Breadth Analysis: The strategy uses the "Breadth Thrust Indicator," which evaluates market momentum by calculating the ratio of advancing stocks to the total number of stocks on the New York Stock Exchange (NYSE). This indicator helps identify bullish market conditions. An optional feature allows for the inclusion of volume data in this calculation, enhancing the signal's robustness.

Signal Generation: A long position is triggered when the smoothed breadth ratio (or the combined breadth and volume ratio) crosses above a specified low threshold (e.g., 0.4). This crossover indicates a potential shift towards positive market momentum.

Key Parameters:

Smoothing Length (length): Defines the period over which the breadth or combined ratio is smoothed using a simple moving average (SMA) to reduce noise and highlight the underlying trend.
    
Low Threshold (threshold_low): The level below which the smoothed ratio must fall before crossing back above to trigger a long signal.
    
Hold Periods (hold_periods): The minimum number of periods for which the position will be held once entered, ensuring the strategy captures a meaningful move.
    
Volatility Multiplier (volatility_multiplier): A multiplier applied to the Average True Range (ATR) to determine the distance of the stop-loss from the entry price, which adjusts according to market volatility.

Trade Management:

Entry Signal: The strategy enters a long position when the smoothed combined ratio crosses above the low threshold, signaling a potential bullish reversal.

ATR-Based Stop-Loss: Upon entering a trade, the strategy calculates a stop-loss level based on the ATR, which measures market volatility. The stop-loss is set at a distance from the entry price, determined by multiplying the ATR by the specified volatility multiplier. This adaptive stop-loss mechanism helps protect the position from adverse market moves.

Stop-Loss Adjustment: While the position is open, the stop-loss level is dynamically updated, ensuring it never decreases (trailing stop-loss effect) but can be adjusted upwards to reflect the latest price action relative to volatility.

Position Closure: The position is closed if:
        
The market price falls to or below the stop-loss level.
        
The position has been held for the specified number of periods (hold_periods), after which it is automatically closed.

Additional Settings:

Initial Capital: The strategy starts with an initial capital of $10,000.
    
Commissions and Slippage: Each trade incurs a commission of $5 per order, and slippage is accounted for at $1 per trade.
    
Background Highlighting: The chart background turns green when a position is open, providing a clear visual indication of the active trade.

This strategy is designed to identify and capitalize on upward momentum in the market while employing a volatility-adjusted stop-loss to manage risk. By combining market breadth analysis with volatility-based stop-losses, the strategy aims to balance profit potential with protection against sudden market reversals.

## Source Code

````pine
//@version=5
strategy("Breadth Thrust Strategy with Volatility Stop-Loss", overlay=false, precision=2, calc_on_every_tick=true, initial_capital=10000, currency=currency.USD, slippage=1, commission_type=strategy.commission.cash_per_order, commission_value=5)

// Input Parameters
length = input.int(10, title="Smoothing Length", minval=1)
threshold_low = input.float(0.4, title="Low Threshold", minval=0, maxval=1, step=0.01)
use_volume = input.bool(true, title="Include Volume in Calculation") // Checkbox to include volume
hold_periods = input.int(9, title="Hold Periods", minval=1) // Number of periods to hold the position
volatility_multiplier = input.float(5, title="Volatility Multiplier", minval=0.1) // Multiplier for the volatility-based stop-loss

// Load NYSE data
advancing_stocks = request.security("INDEX:ADVN", "D", close)
declining_stocks = request.security("INDEX:DECN", "D", close)
advancing_volume = request.security("INDEX:NVLU", "D", close)
declining_volume = request.security("INDEX:NVLD", "D", close)

// Calculate total number of stocks and volume
total_stocks = advancing_stocks + declining_stocks
total_volume = advancing_volume + declining_volume

// Breadth Ratio Calculation (based on stocks)
breadth_ratio = advancing_stocks / total_stocks

// Volume Ratio Calculation
volume_ratio = advancing_volume / total_volume

// Combined Breadth and Volume Ratio
combined_ratio = use_volume ? (breadth_ratio + volume_ratio) / 2 : breadth_ratio

// Smooth the Breadth Ratio and Combined Ratio
smoothed_combined = ta.sma(combined_ratio, length)

// Generate signals
long_signal = ta.crossover(smoothed_combined, threshold_low)
var float entry_price = na
var int entry_bar_index = na

// Calculate volatility using ATR (Average True Range)
atr = ta.atr(14) // 14-period ATR for volatility measure
var float stop_loss_level = na

if (long_signal)
    entry_price := close
    entry_bar_index := bar_index
    stop_loss_level := close - (volatility_multiplier * atr)
    strategy.entry("Long", strategy.long)

if (strategy.opentrades > 0)
    // Update stop-loss based on ATR
    stop_loss_level := math.max(stop_loss_level, close - (volatility_multiplier * atr))

    // Close position if the stop-loss level is hit
    if (low <= stop_loss_level)
        strategy.close("Long")

    // Close the position after the hold period
    if (bar_index - entry_bar_index >= hold_periods)
        strategy.close("Long")
        entry_price := na
        entry_bar_index := na
        stop_loss_level := na

// Plot the Breadth Ratio and Combined Ratio
plot(breadth_ratio, title="Breadth Ratio", color=color.blue, linewidth=1, display=display.none)
plot(volume_ratio, title="Volume Ratio", color=color.purple, linewidth=1, display=display.none)
plot(smoothed_combined, title="Smoothed Combined Ratio", color=color.white, linewidth=1)

// Draw horizontal lines for thresholds
hline(threshold_low, title="Low Threshold", color=color.red, linestyle=hline.style_dotted)

// Background color when position is open
bgcolor(strategy.opentrades > 0 ? color.new(color.green, 50) : na) // Green background when position is open
````
