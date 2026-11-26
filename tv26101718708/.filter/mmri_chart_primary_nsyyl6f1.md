# MMRI Chart (Primary)

- url: https://www.tradingview.com/script/NsYyl6f1-MMRI-Chart-Primary/
- type: indicator
- pine_id: PUB;8fe49489cfaa4a77b7bdcb01e50a64cb
- version: 1.0

## Description

The **Mannarino Market Risk Indicator (MMRI)** is a financial risk measurement tool created by financial strategist Gregory Mannarino. It’s designed to assess the risk level in the stock market and economy based on current bond market conditions and the strength of the U.S. dollar. The MMRI considers factors like the U.S. 10-Year Treasury Yield and the Dollar Index (DXY), which indicate investor confidence in government debt and the dollar's purchasing power, respectively.

The formula for MMRI uses the 10-Year Treasury Yield multiplied by the Dollar Index, divided by a constant (1.61) to normalize the risk measure. A higher MMRI score suggests increased market risk, while a lower score indicates more stability. Mannarino has set certain thresholds to interpret the MMRI score:

- **Below 100**: Low risk.
- **100–200**: Moderate risk.
- **200–300**: High risk.
- **Above 300**: Extreme risk, indicating market instability and potential downturns.

This tool aims to provide insight into economic conditions that may affect asset classes like stocks, bonds, and precious metals. Mannarino often updates MMRI scores and risk analyses in his public market updates.

## Source Code

````pine
//@version=5
indicator("MMRI Chart (Primary)", overlay=true)

// Fetch the data for 10-Year Treasury Yield and Dollar Index (DXY)
treasury_yield = request.security("US10Y", "D", close)
dollar_index = request.security("DXY", "D", close)

// Calculate MMRI using the provided formula
mmri = (dollar_index * treasury_yield) / 1.61

// Replicate price chart behavior
mmri_series = input(true, title="Display as Primary Chart")

// Plot MMRI with custom color and size for main chart appearance
plot(mmri, color=color.blue, linewidth=2, title="MMRI Chart")

// Optional: Plot horizontal lines to define risk levels
hline(100, "Low Risk", color=color.green, linestyle=hline.style_dotted)
hline(200, "Moderate Risk", color=color.orange, linestyle=hline.style_dotted)
hline(300, "High Risk", color=color.red, linestyle=hline.style_dotted)
````
