<!-- tradingview-pine-id: PUB;48381915367a4580a84b72d32efe45c0 -->
<!-- tradingviewscripts-format: 1 -->
# Automated GEX Levels

Source: https://www.tradingview.com/script/m9YzShJl-Automated-GEX-Levels/

## Description

**Automated GEX Levels (NDX to NQ Basis Spread Adjuster)** 

### Overview

This utility indicator resolves a frequent problem faced by index derivatives traders: the tracking drift and basis premium mismatch between spot indices and futures contracts. Institutional options data dashboards (such as ZeroGEX) calculate critical price zones—like the Call Wall and Gamma Flip—using options chains from the underlying cash index (NASDAQ:NDX). Attempting to map these raw numbers directly onto futures contracts (CME:NQ) introduces a structural discrepancy, often resulting in missed executions or inaccurate level tests. 

### How It Works

The script automates the real-time calculation of the intraday basis spread by fetching the 5-minute closing price of the cash index and subtracting it from the live futures contract value: 

Live Basis Premium = NQ Close - NDX Close 

Traders enter the raw, institutional NDX levels directly into the script's user input fields. The indicator dynamically adds the live basis premium to those inputs, automatically projecting the corrected, inflation-adjusted execution levels directly onto the NQ candle layout. 

### Instructions for Use

1. Open your 5-minute NQ execution chart.
2. Open the indicator settings menu via the Gear Icon.
3. Reference your external options dashboard for the native NDX Call Wall and Gamma Flip levels.
4. Input those exact values into the user input fields.
5. The script handles the rest, painting real-time, precision-adjusted levels over your candles with zero manual math required.

---

## Source Code

````pine
//@version=6
indicator("Automated GEX Levels", overlay=true)

raw_call = input.float(0.0, title="ZeroGEX Raw NDX Call Wall")
raw_flip = input.float(0.0, title="ZeroGEX Raw NDX Gamma Flip")

live_basis = close - request.security("NASDAQ:NDX", "5", close)

plot(raw_call > 0 ? raw_call + live_basis : na, title="NQ Call Wall", color=color.green, linewidth=2)
plot(raw_flip > 0 ? raw_flip + live_basis : na, title="NQ Gamma Flip", color=color.orange, linewidth=2)
````
