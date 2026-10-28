# TT Realized Price

- url: https://www.tradingview.com/script/ShLi1axr-TT-Realized-Price/
- type: indicator
- pine_id: PUB;4b9d3a6838c940fba70d056ee085d422
- version: 1.0

## Description

This indicator shows the Realized Price of Bitcoin

Realized price is the average price at which bitcoins were purchased/spent/transferred. It is a metric that takes into account the price at which each individual bitcoin last moved on the blockchain.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Chill00r

//@version=6
indicator("TT Realized Price", overlay = true)

float RC = request.security("COINMETRICS:BTC_MARKETCAPREAL", "D", close)
float SP = request.security("GLASSNODE:BTC_SUPPLY","D", close)
float RP = RC / SP

plot(RP, color = color.orange, title = "RealizedPrice", linewidth = 2)
````
