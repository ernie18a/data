<!-- tradingview-pine-id: PUB;ee3a48b7624a448fb331113eb3cd46b1 -->
<!-- tradingviewscripts-format: 1 -->
# Global Liquidity Indicators VS Bitcoin | TR

Source: https://www.tradingview.com/script/PwpO2iCK-Global-Liquidity-Indicators-VS-Bitcoin-TR/

## Description

🎯 Overview
Global Liquidity Indicators VS Bitcoin | TR is a macro‑economic divergence and consensus oscillator that compares Bitcoin's momentum against a composite Global Liquidity index. Instead of relying on a single metric, it aggregates up to five technical analysis tools (ROC, CCI, RSI, MFI, CMO) into a weighted voting system. The indicator applies user‑defined lags to both series, allowing traders to test leading/lagging relationships between liquidity conditions and Bitcoin price action. The final output is a normalised consensus score (‑100 to +100), displayed via dynamic background colouring, raw TA line overlays, and a prominent trend table for immediate directional bias.

⚙️ Core Calculations

Data Sourcing
The indicator requests closing prices from two custom tickers:

Bitcoin (BTC): INDEX:BTCUSD

Global Liquidity (LIQ): A composite basket defined as
TVC:CN10Y/TVC:DXY/FRED:BAMLH0A0HYM2*(ECONOMICS:USCBBS+FRED:JPNASSETS/FX:USDJPY+ECONOMICS:CNCBBS/FX_IDC:USDCNY+FRED:ECBASSETSW/FX_IDC:USDEUR)
This combines yield curves, FX rates, central bank balance sheets, and credit spreads into a single synthetic price series.

Technical Analysis Engine
For both BTC and LIQ, the indicator computes up to five separate momentum/oscillator values over user‑defined lengths:

ROC (Rate of Change) – default 90 for BTC, 63 for LIQ

CCI (Commodity Channel Index)

RSI (Relative Strength Index)

MFI (Money Flow Index)

CMO (Chande Momentum Oscillator)

Each TA variant is calculated independently, giving a multi‑faceted view of each asset’s internal momentum.

Lag Application
Every computed TA value is shifted by a user‑defined lag:

BTC_Lag (default 0) – shifts Bitcoin’s data forward/backward.

LIQ_Lag (default 101) – shifts Liquidity’s data.
This is the core differentiator: by applying a lag to Liquidity, the indicator can test whether past liquidity changes predict current Bitcoin moves (positive lag) or vice‑versa.

Binary Scoring & Consensus
For each enabled TA tool (enableROC, enableCCI, etc.), the indicator compares the lagged BTC value against the lagged LIQ value:

BTC > LIQ → score = +1 (bullish for BTC)

BTC < LIQ → score = -1 (bearish for BTC)

The total score is summed across all enabled indicators, then divided by the number of active tools (active) to produce an average:

text
percentual_btc = (sum_of_scores / active) * 100
The result ranges from ‑100 (all indicators favour Liquidity) to +100 (all indicators favour Bitcoin).

Primary TA Line (for visual plotting)
The user can select one TA type (TA input) to plot as the raw line overlay for both assets. This line is also shifted by its respective lag, allowing visual comparison of the chosen metric directly on the chart.

📈 Signal System

Trend Bias (Consensus)

Bullish Regime (Bull_BTC): percentual_btc > 0 → more than 50% of enabled indicators favour Bitcoin over Liquidity.

Bearish Regime (Bear_BTC): percentual_btc < 0 → more than 50% of enabled indicators favour Liquidity over Bitcoin.

Neutral: exactly 0 (rare, but possible when active is even and scores cancel out).

Crossing Zero
While not explicitly plotted as a crossover line, a shift from positive to negative (or vice‑versa) signals a change in the macro consensus – i.e., Liquidity is gaining/losing relative strength against Bitcoin.

Background Zone
The entire chart background is tinted:

Green (bullish) when consensus favours Bitcoin.

Red (bearish) when consensus favours Liquidity.
Transparency is fixed at 95%, keeping price action fully readable.

🎨 Visual Features

Primary TA Overlays
Two plotted lines (BTC in orange, LIQ in blue) display the user‑selected technical indicator (ROC, CCI, RSI, MFI, or CMO). Both respect their respective lag offsets, letting you visually assess divergences and crossovers.

9 Colour Themes
Choose from Classic, Modern, Heat, Robust, Accented, Monochrome, Moderate, Aqua, or Cosmic. These define the specific shades used for the bullish (UpC) and bearish (DnC) background fills and the trend table text.

Trend Table
A persistent, large‑font table positioned at the middle‑right of the chart displays:

⬆️ ＢＵＬＬＩＳＨ (green)

⬇️ ＢＥＡＲＩＳＨ (red)

➖ ＮＥＵＴＲＡＬ (grey)
This gives an instantaneous, screen‑wide readout of the current macro bias.

Active Indicator Toggles
Each of the five TA tools can be individually enabled/disabled. Disabling a tool removes its vote from the consensus, allowing you to back‑test which combination of indicators produces the most reliable signals.

📖 Interpretation Guide

Positive values (> 0) indicate that Bitcoin’s momentum (as measured by the selected TA tools) is stronger than Global Liquidity’s momentum. This implies that risk‑on appetite is prevailing, and Bitcoin is likely to outperform – a bullish signal for BTC.

Negative values (< 0) indicate that Global Liquidity is gaining momentum faster than Bitcoin. This often suggests tightening financial conditions or risk‑off sentiment, which tends to weigh on speculative assets – a bearish signal for BTC.

Magnitude matters: a score of +80 or ‑80 means nearly all indicators agree, signalling a strong consensus and potentially a sustained trend. Values near zero suggest indecision or mixed signals – caution is advised.

The Lag Effect:

If LIQ_Lag is set high (e.g., 101 bars), the indicator effectively asks: “Did liquidity conditions 101 bars ago predict where Bitcoin is today?”

A consistently positive consensus under this setup suggests liquidity leads Bitcoin, making the indicator a leading macro predictor.

Conversely, if BTC_Lag is positive, you are testing whether Bitcoin leads liquidity – a less common but insightful alternative.

Background colour provides a quick visual summary; green zones are favourable for long positions, red zones for shorts or hedges.

🚨 Alert Summary
Two straightforward alert conditions are built in for automation:

LONG – triggered when percentual_btc > 0 (consensus turns bullish).

SHORT – triggered when percentual_btc < 0 (consensus turns bearish).

Both alerts are available in the TradingView alerts panel. They are ideal for macro‑based entry signals, portfolio allocation shifts, or as a filter to confirm directional bias before taking a trade on BTC or related crypto assets.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tiagorocha1989
//                              ████████╗ ████████╗  ████████╗  ███████╗   ██████╗        ██████╗   ██████╗   ██████╗ ██╗   ██╗ ████████╗
//                              ╚══██╔══╝ ╚══██╔══╝  ██╔═══██║  ██╔════╝  ██╔═══██╗       ██╔══██╗ ██╔═══██╗ ██╔════╝ ██║   ██║ ██╔═══██║
//                                 ██║       ██║     ████████║  ██║ ███║  ██║   ██║       ██████╔╝ ██║   ██║ ██║      ████████║ ████████║
//                                 ██║       ██║     ██╔═══██║  ██║  ██║  ██║   ██║       ██╔══██╗ ██║   ██║ ██║      ██║   ██║ ██╔═══██║
//                                 ██║    ████████╗  ██║   ██║  ███████║  ╚██████╔╝       ██║  ██║ ╚██████╔╝ ╚██████╗ ██║   ██║ ██║   ██║
//@version=6
indicator('Global Liquidity Indicators VS Bitcoin | TR', 'GLI VS BTC | TR →', false)
//╔═════════════════╗
//║     DATA        ║
//╚═════════════════╝
Liquidity_Ticker = 'TVC:CN10Y/TVC:DXY/FRED:BAMLH0A0HYM2*(ECONOMICS:USCBBS+FRED:JPNASSETS/FX:USDJPY+ECONOMICS:CNCBBS/FX_IDC:USDCNY+FRED:ECBASSETSW/FX_IDC:USDEUR)'
BTC_Ticker = 'INDEX:BTCUSD'
//╔═════════════════╗
//║     Input's     ║
//╚═════════════════╝
Color_Mode =    input.string('Classic', '🎨 Color Choice', group = 'Color', options = ['Classic', 'Modern', 'Heat', 'Robust', 'Accented', 'Monochrome', 'Moderate', 'Aqua', 'Cosmic'])
TA =            input.string('ROC', 'Technical Analysis', group='📊 Technical Analysis ', inline='TA', options=['ROC', 'CCI', 'RSI', 'MFI', 'CMO'])
LIQ_Length =    input.int(63, 'LIQ Length', group='⚙️ LIQ Setting', inline='GLI')
LIQ_Lag    =    input.int(101, 'Lag', group='⚙️ LIQ Setting', inline='GLI')
BTC_Length =    input.int(90, 'BTC Length', group='⚙️ BTC Setting', inline='BTC')
BTC_Lag    =    input.int(0, 'Lag', group='⚙️ BTC Setting', inline='BTC')
enableROC =     input.bool(true, '🔹 Use ROC', group='📊 Consensus', inline='ROC')
enableCCI =     input.bool(false, '🔹 Use CCI', group='📊 Consensus', inline='CCI')
enableRSI =     input.bool(false, '🔹 Use RSI', group='📊 Consensus', inline='RSI')
enableMFI =     input.bool(false, '🔹 Use MFI', group='📊 Consensus', inline='MFI')
enableCMO =     input.bool(false, '🔹 Use CMO', group='📊 Consensus', inline='CMO')
//╔═════════════════╗
//║     Color       ║
//╚═════════════════╝
[UpC, DnC] = switch Color_Mode
    'Classic'       => [#008800, #ff0000]
    'Modern'        => [#ffffff, #b721ff]
    'Heat'          => [#ff0000, #87cefb]
    'Robust'        => [#ffbb00, #770737]
    'Accented'      => [#8c5cf7, #e83e8c]
    'Monochrome'    => [#e9ecef, #495057]
    'Moderate'      => [#43a047, #e53935]
    'Aqua'          => [#00a8e8, #f18f01]
    'Cosmic'        => [#e83e8c, #6f2da8]
//╔══════════════════════════════════╗
//║     MOVING AVERAGE ENGINE        ║
//╚══════════════════════════════════╝
ma(source, length, type) =>
     type == 'ROC' ? ta.roc(source, length) :
     type == 'CCI' ? ta.cci(source, length) :
     type == 'RSI' ? ta.rsi(source, length) :
     type == 'MFI' ? ta.mfi(source, length) :
     type == 'CMO' ? ta.cmo(source, length) :
     na
//╔═════════════════════╗
//║     Request's       ║
//╚═════════════════════╝
BTC       = request.security(BTC_Ticker, timeframe.period, close)
Liquidity = request.security(Liquidity_Ticker, timeframe.period, close)

btc_roc  = ma(BTC, BTC_Length, 'ROC')
btc_cci  = ma(BTC, BTC_Length, 'CCI')
btc_rsi  = ma(BTC, BTC_Length, 'RSI')
btc_mfi  = ma(BTC, BTC_Length, 'MFI')
btc_cmo  = ma(BTC, BTC_Length, 'CMO')

liq_roc  = ma(Liquidity, LIQ_Length, 'ROC')
liq_cci  = ma(Liquidity, LIQ_Length, 'CCI')
liq_rsi  = ma(Liquidity, LIQ_Length, 'RSI')
liq_mfi  = ma(Liquidity, LIQ_Length, 'MFI')
liq_cmo  = ma(Liquidity, LIQ_Length, 'CMO')

btc_roc_lag  = btc_roc[BTC_Lag]
btc_cci_lag  = btc_cci[BTC_Lag]
btc_rsi_lag  = btc_rsi[BTC_Lag]
btc_mfi_lag  = btc_mfi[BTC_Lag]
btc_cmo_lag  = btc_cmo[BTC_Lag]

liq_roc_lag  = liq_roc[LIQ_Lag]
liq_cci_lag  = liq_cci[LIQ_Lag]
liq_rsi_lag  = liq_rsi[LIQ_Lag]
liq_mfi_lag  = liq_mfi[LIQ_Lag]
liq_cmo_lag  = liq_cmo[LIQ_Lag]

score_roc = enableROC ? (btc_roc_lag > liq_roc_lag ? 1 : -1) : 0
score_cci = enableCCI ? (btc_cci_lag > liq_cci_lag ? 1 : -1) : 0
score_rsi = enableRSI ? (btc_rsi_lag > liq_rsi_lag ? 1 : -1) : 0
score_mfi = enableMFI ? (btc_mfi_lag > liq_mfi_lag ? 1 : -1) : 0
score_cmo = enableCMO ? (btc_cmo_lag > liq_cmo_lag ? 1 : -1) : 0

active = (enableROC ? 1 : 0) + (enableCCI ? 1 : 0) + (enableRSI ? 1 : 0) + (enableMFI ? 1 : 0) + (enableCMO ? 1 : 0)

var float percentual_btc = 0.0
if active > 0
    score_btc   = score_roc + score_cci + score_rsi + score_mfi + score_cmo
    percentual_btc := (score_btc / active) * 100
else
    percentual_btc := 0.0

Bull_BTC = percentual_btc > 0
Bear_BTC = percentual_btc < 0

BTC_TA = ma(BTC, BTC_Length, TA)
LIQ_TA = ma(Liquidity, LIQ_Length, TA)
BTC_TA_Lagged = BTC_TA[BTC_Lag]
LIQ_TA_Lagged = LIQ_TA[LIQ_Lag]

Value = BTC_TA_Lagged - LIQ_TA_Lagged
//╔═════════════════╗
//║     Plot        ║
//╚═════════════════╝
plot(BTC_TA, title='BTC', offset=BTC_Lag, color=color.orange, linewidth=2)
plot(LIQ_TA, title='LIQ', offset=LIQ_Lag, color=color.blue, linewidth=2)
bgcolor(Bull_BTC ? color.new(UpC, 95) : Bear_BTC ? color.new(DnC, 95) : na, title='Zone Background', force_overlay=true)
//╔═════════════════╗
//║     VIEW        ║
//╚═════════════════╝
var table Table_GLI = table.new(position.middle_right, 1, 1, border_width = 1)
if barstate.islast
    table.cell(Table_GLI, 0, 0, text = percentual_btc > 0 ? '⬆️ ＢＵＬＬＩＳＨ' : percentual_btc < 0 ? '⬇️ ＢＥＡＲＩＳＨ' : na, text_color = percentual_btc > 0 ? UpC : percentual_btc < 0 ? DnC : na, text_size = size.huge)
//╔════════════════════════╗
//║         Alerts         ║
//╚════════════════════════╝
alertcondition(percentual_btc > 0 , title= 'LONG', message= 'BTC LONG')
alertcondition(percentual_btc < 0 , title= 'SHORT', message= 'BTC SHORT')
````
