# EDVEFI (Standard MA version)

- url: https://www.tradingview.com/script/mTHF2ZbL/
- type: indicator
- pine_id: PUB;1674b6354c7940e79ad5eb4389a30a6b
- version: 1.0

## Description

EDVEFI (Enhanced Dynamic Volume EFI)

This indicator is designed to measure market strength and weakness by combining price movement with volume.

Unlike the traditional Elder Force Index (EFI), which uses only price change and volume, EDVEFI also incorporates candle structure, including price range and wick information, to better reflect market behavior.

The Dynamic EFI is displayed as a bar chart, allowing traders to visualize short-term changes in buying and selling pressure. The Smoothed EFI, calculated using a Simple Moving Average (SMA), serves as a baseline for identifying the overall market trend.

When the Dynamic EFI rises above the Smoothed EFI, it suggests strengthening market momentum. Conversely, when it falls below the Smoothed EFI, it may indicate weakening momentum.

By analyzing both price movement and volume, this indicator helps traders evaluate trend strength, shifts in market sentiment, and changes in buying or selling pressure.

EDVEFI is intended as a market analysis tool rather than a predictive indicator, providing insight into the underlying dynamics of market participation.

## Source Code

````pine
//@version=6
indicator("EDVEFI (Standard MA version)", overlay=false, precision=2)

// Inputs
length = input.int(28, title="Moving Average Length", minval=1)
efi_length = input.int(14, title="EFI Length", minval=1)
wick_weight = input.float(0.0, title="Wick Weight", minval=0, maxval=10)
normalize = input.string("Spread", title="Normalize by", options=["Disable", "Spread", "Previous Bar Price"])

// Calculations
eps = 0.00000001
trl = math.min(low, close[1])      // True Range Low
trh = math.max(high, close[1])     // True Range High
true_range = trh - trl

// Adjusted Directional Range (ADR)
adr = wick_weight * (2 * close - (trh + trl)) / 10 + (1 - wick_weight / 10) * ta.change(close)

adr := normalize == "Disable" ? adr : adr / (normalize == "Spread" ? math.max(true_range, eps) : math.max(close[1], eps))

// Adjusted Volume
volume_adj = volume * adr

// Enhanced Dynamic EFI
dynamic_efi = ta.ema(volume_adj, efi_length)

// Smoothed EFI (SMA)
smoothed_dynamic_efi = ta.sma(dynamic_efi, length)

// Plots
plot(
     dynamic_efi,
     title="Dynamic EFI",
     style=plot.style_columns,
     color=dynamic_efi > smoothed_dynamic_efi ? color.rgb(25, 217, 105) : color.rgb(35, 123, 3)
)

plot(
     smoothed_dynamic_efi,
     title="Smoothed EFI (SMA)",
     color=smoothed_dynamic_efi > 0 ? color.lime : color.red,
     linewidth=1
)

hline(0, color=color.new(#787B86, 50), title="Zero Line")
````
