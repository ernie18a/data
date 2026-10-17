# Moroccan OPCVM FCP Gold NAV Tracker (XAUUSD Based)

- url: https://www.tradingview.com/script/f2JPo6HP/
- type: indicator
- pine_id: PUB;cd9b2c127a7d453fa78b967d0fbb8236
- version: 3.0

## Description

**Moroccan OPCVM FCP GOLD VL**

This indicator provides a real-time estimation of the theoretical Net Asset Value (NAV) of the Moroccan OPCVM FCP Gold fund based on the gold price (XAUUSD).

**Formula**

Theoretical NAV = XAUUSD × 0.5708

**Calibration**

The coefficient was calibrated using:

* Official fund Net Asset Value (NAV)
* Gold spot price (XAUUSD)

**Purpose**

* Track the fund's theoretical performance between official NAV publications.
* Compare FCP Gold performance against the underlying gold market.
* Estimate future NAV movements based on gold price fluctuations.

**Important**
The official NAV of the fund is calculated and published every Thursday.

This indicator provides an approximation based solely on the gold price and does not take into account:

* Management fees
* Tracking errors
* USD/MAD exchange rate fluctuations
* Other operational adjustments made by the fund manager

**Use Case**
A practical tool for monitoring and comparing the Moroccan FCP Gold fund with the international gold market, providing investors with an indicative real-time valuation between official NAV updates.

**Disclaimer**
This indicator is for informational and educational purposes only and should not be considered as an official NAV source or investment advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © abdou_echchrif

//@version=6
indicator("OPCVM FCP GOLD VL", shorttitle="MA OPCVM GOLD VL", overlay=true)

gold = request.security("OANDA:XAUUSD", timeframe.period, close)

// Calibration 31/05/2026
// VL Attijari Gold = 2583.04 DH
// XAUUSD = 4525.32 USD
// Coefficient = 0.5708

attijari_gold = gold * 0.5708

plot(attijari_gold, title="VL théorique OPCVM Gold", linewidth=2)
````
