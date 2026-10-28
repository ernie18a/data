# Simplified Trilean Unanimity

- url: https://www.tradingview.com/script/skDKsF4j-Simplified-Trilean-Unanimity/
- type: indicator
- pine_id: PUB;1c0a056fde614de685db3beb2faa22d6
- version: 1.0

## Description

Simplified Trilean Unanimity
by chuckaschultz, inspired by a framework published by The_Peaceful_Lizard.

A confluence filter that only signals when RSI, Money Flow Index, and Supertrend all agree — eliminating the false positives that come from single-indicator trading.

How It Works
Each indicator is evaluated in three states: bullish, bearish, or neutral. The script requires all three to reach unanimous agreement before plotting a signal. No consensus = no signal. Simple.

Reading the Indicator
🟢 Green area — All three indicators confirm bullish conditions. Look for long entries.
🔴 Red area — All three indicators confirm bearish conditions. Look for short entries or exits.
⬜ Gray / flat — Mixed signals. Stay patient.

Settings
InputDefaultNotesRSI Length14StandardRSI Overbought / Oversold69 / 35Slightly tighter than default 70/30MFI Length14StandardMFI Overbought / Oversold69 / 35Matches RSI thresholdsSupertrend Factor3.0Lower = more sensitiveSupertrend ATR Period10Standard

Alerts
Three built-in alert conditions:

Bullish Unanimity — All three confirm bullish
Bearish Unanimity — All three confirm bearish
Any Unanimity — Either direction fires

Set alerts to Once Per Bar Close for best reliability.

Best Practices

Use as a confirmation layer, not a standalone entry trigger
Works on any timeframe — higher timeframes produce fewer but higher-quality signals
Unanimity is intentionally rare — that's the point


Trilean logic inspired by a framework published by The_Peaceful_Lizard. This adaptation and implementation by Chuck Schultz.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chuckaschultz
// Proprietary: Calculations for the Simplified Trilean Unanimity are inspired by a library published by The_Peaceful_Lizard this adaptation is provided by Chuck Schultz. Do not copy or redistribute without permission.

//@version=6
indicator("Simplified Trilean Unanimity", overlay=false)

// --- Grouping Labels ---
const string GRP1 = "INDICATOR SETTINGS"
const string GRP2 = "BACKTESTING SETTINGS"
const string GRP3 = "STYLE SETTINGS"

// --- Indicator Settings ---
int rsi_length = input.int(14, title="RSI Length", minval=1, group=GRP1)
int mfi_length = input.int(14, title="MFI Length", minval=1, group=GRP1)
float rsi_overbought = input.float(69, title="RSI Overbought Level", minval=0, maxval=100, group=GRP1)
float rsi_oversold = input.float(35, title="RSI Oversold Level", minval=0, maxval=100, group=GRP1)
float mfi_overbought = input.float(69, title="MFI Overbought Level", minval=0, maxval=100, group=GRP1)
float mfi_oversold = input.float(35, title="MFI Oversold Level", minval=0, maxval=100, group=GRP1)
float supertrend_factor = input.float(3, title="Supertrend Factor", minval=0.1, step=0.1, group=GRP1)
int supertrend_atr = input.int(10, title="Supertrend ATR Period", minval=1, group=GRP1)


// Calculate indicators
float rsi = ta.rsi(close, rsi_length)
float mfi = ta.mfi(close, mfi_length)
[_, st] = ta.supertrend(supertrend_factor, supertrend_atr)

// Convert to trilean states (-1: False, 0: Uncertain, 1: True)
int rsi_state = rsi > rsi_overbought ? 1 : rsi < rsi_oversold ? -1 : 0
int mfi_state = mfi > mfi_overbought ? 1 : mfi < mfi_oversold ? -1 : 0
int st_state = st > 0 ? -1 : 1  // Invert Supertrend direction

// Check unanimity
int unanimous_state = 0
if rsi_state == mfi_state and mfi_state == st_state
    unanimous_state := rsi_state

// Set color based on value
color plot_color = unanimous_state < 0 ? color.green : unanimous_state > 0 ? color.red : color.gray

// Plot result
plot(unanimous_state, title="Unanimous State", color=plot_color, style=plot.style_area)

//Alerts
alertcondition(unanimous_state == -1, title="Bullish Unanimity", message="STU: All 3 indicators BULLISH")
alertcondition(unanimous_state == 1, title="Bearish Unanimity", message="STU: All 3 indicators BEARISH")
alertcondition(unanimous_state != 0, title="Any Unanimity", message="STU: Unanimous signal fired")
````
