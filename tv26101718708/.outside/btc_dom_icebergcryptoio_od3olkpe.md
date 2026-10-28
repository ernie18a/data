# BTC Dom IcebergCrypto.io

- url: https://www.tradingview.com/script/OD3OlKpE-BTC-Dom-IcebergCrypto-io/
- type: indicator
- pine_id: PUB;a4e10cb03f404e1a8135f6cfe53df794
- version: 1.0

## Description

📊 BTC Dominance ex-Stablecoins | Iceberg Crypto

This indicator calculates Bitcoin's true dominance by excluding stablecoins (USDT, USDC) from the total crypto market cap.

🔍 Why?
Stablecoins artificially inflate the total market cap without representing actual speculative flows. By removing them, you get a cleaner read on BTC's real share of the risk-on market — essential for analyzing capital rotations between BTC and altcoins.

📐 Formula:
BTC Market Cap / (Total Market Cap - USDT MCap - USDC MCap) × 100
⚙️ How to use:

Identify alt season vs BTC season phases with greater accuracy
Spot divergences between classic dominance (BTC.D) and true dominance
Combine with Volume Profile and Orderflow to time rotations

🧊 By Iceberg Crypto
Institutional-grade trading education.
Volume Profile | Orderflow | Auction Market Theory
🌐 icebergcrypto.io
🐦 @IcebergCryptoX

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IcebergCrypto

//@version=6
indicator("BTC Dom IcebergCrypto.io", overlay=false)

btc = request.security("CRYPTOCAP:BTC", timeframe.period, close)
total = request.security("CRYPTOCAP:TOTAL", timeframe.period, close)
usdt = request.security("CRYPTOCAP:USDT", timeframe.period, close)
usdc = request.security("CRYPTOCAP:USDC", timeframe.period, close)

dom = (btc / (total - usdt - usdc)) * 100
plot(dom, "BTC Dom ex-Stables", color=color.orange, linewidth=2)
````
