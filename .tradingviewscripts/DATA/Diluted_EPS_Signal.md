<!-- tradingview-pine-id: PUB;626d350a83824667950b73c5b9f0ad7e -->
<!-- tradingviewscripts-format: 1 -->
# Diluted EPS Signal

Source: https://www.tradingview.com/script/ToaTQAbG-Diluted-Earnings-Per-Share-Signal-AstrideUnicorn/

## Description

Earnings Per Share (EPS) is a financial metric closely monitored by investors. The so-called "positive earnings surprise" - a situation when EPS reading for a stock beats the value forecasted by analysts gives a bullish signal for this stock. The EPS reading lower than the analysts' estimate gives a bearish signal.

The Diluted Earnings Per Share (Diluted EPS) metric calculates a company's potential earnings per share value in the case if all convertible securities get converted to common shares. Convertible securities include preferred shares, stock options, warrants, convertible debt, etc. Diluted EPS is a more scientific way to estimate earnings per share, and it is usually lower than the ordinary EPS. 

The Diluted EPS Signal indicator (DEPSS) is a fundamental indicator that calculates trading signals by comparing the Diluted EPS to the EPS Estimate. In many cases, Diluted EPS gives better insight into how a reported EPS reading may impact the stock price.

HOW TO USE
For each earnings date, the indicator calculates the Diluted Earnings Surprise percentage value :
Diluted Earnings Surprise =  (Diluted EPS - EPS Estimate)/ EPS Estimate.

Diluted Earnings Surprise higher than the specified threshold value is a bullish signal. In this case, the indicator displays a green triangle pointing up.
Diluted Earnings Surprise lower than the specified threshold value is a bearish signal displayed as a red triangle pointing down.

As one can see on the chart, there are a lot of situations where EPS readings with green labels (the ones that beat analysts' estimates) lead to down moves. The DEPSS indicator can spot weak earnings and give opposite signals. 

SETTINGS

Earnings Surprise Threshold (%): the threshold value (in percentage units) for the Diluted Earnings Surprise. The calculated Diluted Earnings Surprise must be higher than Earnings Surprise Threshold to be considered a BUY signal or lower than minus Earnings Surprise Threshold to be considered a SELL signal. The default value for Earnings Surprise Threshold is 20%.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstrideUnicorn

//@version=5
indicator('Diluted EPS Signal', shorttitle='DEPSS' ,overlay=true)

// Input earnings surprise thershold
threshold1 = input.float(defval=20, title='Earnings Surprise Threshold (%)', step=0.01)

// Get Eanings Per Share Estimate and Earnings Per Share Diluted
EPS_estimate = request.earnings(syminfo.tickerid, earnings.estimate)
EPS_diluted = request.financial(syminfo.tickerid, 'EARNINGS_PER_SHARE_DILUTED', 'FQ')

// Convert percentafe value of the treshold to a decimal one
threshold = threshold1/100

// Calcuate the absolute value of eranings suprise
absolute_earnings_surprise = math.abs((EPS_diluted - EPS_estimate) / EPS_estimate)

// Condition that determines if the current earnings signal is significant
significant = absolute_earnings_surprise >= threshold

// Define BUY and SELL signals
buy_signal = EPS_diluted - EPS_estimate >= 0 and significant
sell_signal = EPS_diluted - EPS_estimate < 0 and significant

// Calculate eranings date
Earnings_date = ta.barssince(EPS_estimate - EPS_estimate[1] != 0) == 0

// plot signal arrows
plotshape(Earnings_date and buy_signal, style=shape.triangleup, color=color.new(color.green, 0), location=location.belowbar, size=size.normal)
plotshape(Earnings_date and sell_signal, style=shape.triangledown, color=color.new(color.red, 0), location=location.abovebar, size=size.normal)
````
