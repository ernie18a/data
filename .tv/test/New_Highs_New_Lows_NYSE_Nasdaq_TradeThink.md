<!-- tradingview-pine-id: PUB;af10f74bd8794e149957f8d982147d0a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# New Highs - New Lows (NYSE & Nasdaq) [TradeThink]

Source: https://www.tradingview.com/script/1eELX40U-New-Highs-New-Lows-NYSE-Nasdaq-TradeThink/

## Description

WHAT IT DOES

The New Highs – New Lows (NH-NL) indicator is a market breadth tool based on the method described by Stan Weinstein in “Secrets for Profiting in Bull and Bear Markets”. Weinstein used NYSE data, while this indicator also provides Nasdaq and Combined NYSE & Nasdaq options.

It helps identify changes in the technical health of the market that may not be obvious from the major indexes and can provide early signs of weakening or strengthening market conditions.

HOW TO USE IT

It is recommended to use the Weekly chart to focus on longer-term market conditions and reduce short-term noise.

When NH-NL stays consistently above 0, it is generally a bullish sign for the market. 
When NH-NL stays consistently below 0, it indicates an unhealthy market.

An important divergence between NH-NL and the major index can be an early sign that the market trend is starting to change.

Around a market bottom, or sometimes slightly before it, NH-NL often drops sharply and deeply into negative territory, then rebounds quickly, forming a very sharp and deep V-shaped recovery.

The NH-NL is one part of market analysis and should not be judged alone. It should be considered together with the overall market trend and other market evidence.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeThink_Research

//@version=6
indicator("New Highs - New Lows (NYSE & Nasdaq) [TradeThink]", shorttitle = 'NH-NL[TradeThink]')

adlType = input.string('NYSE', 'NH-NL Type', options = ['NYSE', 'Nasdaq', 'NYSE & Nasdaq'])

NYHigh = request.security("HIGN", timeframe.period, close)
NYLow = request.security("LOWN", timeframe.period, close)
NQHigh = request.security("HIGQ", timeframe.period, close)
NQLow = request.security("LOWQ", timeframe.period, close)

NYDiff = NYHigh - NYLow
NQDiff = NQHigh - NQLow

diff = switch adlType
    'NYSE' => NYDiff
    'Nasdaq' => NQDiff
    'NYSE & Nasdaq'=> NYDiff + NQDiff

plot(diff)
hline(0, color=color.gray)
````
