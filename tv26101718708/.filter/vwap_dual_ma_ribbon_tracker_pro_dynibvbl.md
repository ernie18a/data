# VWAP & Dual MA Ribbon Tracker Pro

- url: https://www.tradingview.com/script/dYnibVbL-VWAP-Dual-MA-Ribbon-Tracker-Pro/
- type: indicator
- pine_id: PUB;f41d604d2cfb4142a96e6871e44d8e08
- version: 1.0

## Description

The Master Trigger Breakdown
* For Longs (Green): The 4 EMA must be above the VWAP. If the 4 EMA is below the VWAP, a long trade is completely blocked, no matter how bullish the rest of the chart looks.
* For Shorts (Red): The 4 EMA must be below the VWAP. If the 4 EMA is above the VWAP, a short trade is completely blocked.

The Complete Logic Chain (How it fits together)
Your indicator only gives a trading color when all three layers of your rules agree with that master trigger:
1. The Structural Trigger: Is the 4 EMA on the correct side of VWAP? (Above for Long / Below for Short)
2. The Momentum Confirmation: Is the 4 EMA accelerating away from the 9 EMA? (Above 9 EMA for Long / Below 9 EMA for Short)
3. The Institutional Force: Is the Elder Force Index (EFI) confirming the volume pressure? (Above 0 for Long / Below 0 for Short) 
If any single one of these three layers disagrees, the master trigger pulls the plug and forces the ribbon to stay Blue (No Trading).

How the ATR Cushion Protects Your NASDAQ Trades
In the script, the ATR calculation creates a dynamic "buffer zone" around the VWAP and the 9 EMA.
* For Longs (Green): The 4 EMA can’t just be a fraction above the VWAP and 9 EMA. It must clear both of them by a margin of 0.2 * ATR.
* For Shorts (Red): The 4 EMA must drop below the VWAP and 9 EMA by a margin of 0.2 * ATR. 

Why This Asset-Specific Math is Important
The NASDAQ's range changes drastically throughout the day.
* At 9:30 AM EST (NY Open): The market is highly volatile. The ATR expands because the bars are large. The indicator automatically widens the cushion so you don't get trapped by massive, wild price swings.
* At 1:00 PM EST (Lunch Hour): The market slows down. The ATR shrinks because the bars are small. The indicator automatically tightens the cushion so you can still catch a genuine, breakout move if it happens. 

How to Tune It in Your Settings
If you feel the indicator is reacting perfectly but missing the exact start of a move, you can adjust the ATR Multiplier Cushion input:
* Lower it to 0.1: Makes the indicator more aggressive, giving you faster entries but a slightly higher risk of a false signal.
* Raise it to 0.3: Makes the indicator more conservative, filtering out more noise but delaying your entry.
* Turn it off: Uncheck the "Use ATR Cushion Filter" box in your settings to see the pure EMA rules without any volatility buffer.

Volume
This upgraded system swaps out rigid, raw volume for the Elder Force Index (EFI). Instead of blindly measuring how many shares were traded, the indicator now calculates true institutional momentum by multiplying volume against net price direction. This ensures you get highly accurate signals on the NASDAQ without missing trades during steady, trending moves.


Visual Layout & Interface
* Upper Main Chart: Your candles, the VWAP line, the 4 EMA, and the 9 EMA remain active here to map structure.
* Lower Separate Panel: Houses your solid color-blocked ribbon, updating instantly as the trend and market force align.



The 3 Market States & Color Codes
* 🟩 SOLID GREEN (Premise to Go Long)
    * The Structural Rule: The 4 EMA is above the VWAP AND above the 9 EMA (plus your ATR cushion).
    * The EFI Filter: The 13 or 2-period smoothed Elder Force Index must be above 0.
    * Market Context: Buyers are in absolute control. The trend has broken out, and it is actively backed by positive institutional buying power.
* 🟥 SOLID RED (Premise to Go Short)
    * The Structural Rule: The 4 EMA is below the VWAP AND below the 9 EMA (minus your ATR cushion).
    * The EFI Filter: The 13 or 2 setting-period smoothed Elder Force Index must be below 0.
    * Market Context: Sellers are dominant. Price is aggressively pushing lower, backed by true institutional distribution force.
* 🟦 SOLID BLUE (No Trading / Neutral Zone)
    * The Rule: Triggered if the EMAs conflict OR if the EFI doesn't match the price direction (e.g., the 4 EMA pushes up, but EFI is below 0).
    * Market Context: Weak, diverging, or manipulative market action. This protects your capital by sidelining you when the NASDAQ is trying to trap retail breakout buyers.

## Source Code

````pine
//@version=6
// +------------------------------------------------------------------+
// | Indicator: VWAP & Dual MA Ribbon Tracker Pro (EFI Edition)       |
// | Developer: Simon20cent                                           |
// | Date: June 2026                                                  |
// | Platform: TradingView (Pine Script v6)                          |
// +------------------------------------------------------------------+
indicator('VWAP & Dual MA Ribbon Tracker Pro', overlay = false)

// Inputs - Core Settings
ma_type     = input.string('EMA', title = 'MA Type', options = ['EMA', 'SMA'])
ma1_length  = input.int(4, title = 'MA 1 Length')
ma2_length  = input.int(9, title = 'MA 2 Length')

// Inputs - Advanced Filters
use_efi_filter = input.bool(true, title = "Filter out weak Elder Force Index?")
efi_length     = input.int(2, title = "EFI EMA Smoothing Length (Elder Classic = 2)")
use_atr_filter = input.bool(true, title = "Use ATR Cushion Filter?")
atr_length     = input.int(14, title = "ATR Length")
atr_multiplier = input.float(0.2, title = "ATR Multiplier Cushion", step = 0.1)

// Core Calculations
vwap_val = ta.vwap
get_ma(type, src, len) => type == 'EMA' ? ta.ema(src, len) : ta.sma(src, len)
ma1 = get_ma(ma_type, close, ma1_length) // 4 EMA
ma2 = get_ma(ma_type, close, ma2_length) // 9 EMA

// Elder Force Index (EFI) Calculation
raw_efi = (close - close[1]) * volume
smoothed_efi = ta.ema(raw_efi, efi_length)

// EFI Validations (Checks if institutional force matches trade direction)
efi_long_valid  = not use_efi_filter or (smoothed_efi > 0)
efi_short_valid = not use_efi_filter or (smoothed_efi < 0)

// ATR Volatility Cushion
atr_val = ta.atr(atr_length)
cushion = use_atr_filter ? (atr_val * atr_multiplier) : 0.0

// State Conditions (Simon20cent Logic Setup with Elder Force Index)
is_green = (ma1 > vwap_val + cushion) and (ma1 > ma2 + cushion) and efi_long_valid
is_red   = (ma1 < vwap_val - cushion) and (ma1 < ma2 - cushion) and efi_short_valid

// Assign Colors
ribbon_color = is_green ? color.green : is_red ? color.red : color.blue

// Plot Ribbon
plot(1, title = "Trend Ribbon Pro", color = ribbon_color, style = plot.style_histogram, linewidth = 4)
````
