# Commodity Selection Index Strategy

- url: https://www.tradingview.com/script/AVe3DusS-Commodity-Selection-Index-Strategy/
- type: indicator
- pine_id: PUB;fG8liywOZ9LK0lxnby482ac1qFdhatxM
- version: 1.0

## Description

The Commodity Selection Index ("CSI") is a momentum indicator. It was 
 developed by Welles Wilder and is presented in his book New Concepts in 
 Technical Trading Systems. The name of the index reflects its primary purpose. 
 That is, to help select commodities suitable for short-term trading.
 A high CSI rating indicates that the commodity has strong trending and volatility 
 characteristics. The trending characteristics are brought out by the Directional 
 Movement factor in the calculation--the volatility characteristic by the Average 
 True Range factor.
 Wilder's approach is to trade commodities with high CSI values (relative to other 
 commodities). Because these commodities are highly volatile, they have the potential 
 to make the "most money in the shortest period of time." High CSI values imply 
 trending characteristics which make it easier to trade the security.
 The Commodity Selection Index is designed for short-term traders who can handle 
 the risks associated with highly volatile markets.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 19/03/2019
// The Commodity Selection Index ("CSI") is a momentum indicator. It was 
// developed by Welles Wilder and is presented in his book New Concepts in 
// Technical Trading Systems. The name of the index reflects its primary purpose. 
// That is, to help select commodities suitable for short-term trading.
// A high CSI rating indicates that the commodity has strong trending and volatility 
// characteristics. The trending characteristics are brought out by the Directional 
// Movement factor in the calculation--the volatility characteristic by the Average 
// True Range factor.
// Wilder's approach is to trade commodities with high CSI values (relative to other 
// commodities). Because these commodities are highly volatile, they have the potential 
// to make the "most money in the shortest period of time." High CSI values imply 
// trending characteristics which make it easier to trade the security.
// The Commodity Selection Index is designed for short-term traders who can handle 
// the risks associated with highly volatile markets.
////////////////////////////////////////////////////////////
fADX(Len) =>
    up = change(high)
    down = -change(low)
    trur = rma(tr, Len)
    plus = fixnan(100 * rma(up > down and up > 0 ? up : 0, Len) / trur)
    minus = fixnan(100 * rma(down > up and down > 0 ? down : 0, Len) / trur)
    sum = plus + minus 
    100 * rma(abs(plus - minus) / (sum == 0 ? 1 : sum), Len)

study(title="Commodity Selection Index Strategy", shorttitle="CSI Strategy")
PointValue = input(50)
Margin = input(3000)
Commission = input(10)
Length = input(14)
K = 100 * ((PointValue / sqrt(Margin) / (150 + Commission)))
xATR = atr(Length)
xADX = fADX(Length)
nADXR = (xADX + xADX[Length]) * 0.5
xCSI = K * xATR * nADXR
xMACSI = sma(xCSI, Length)
pos = 0.0
pos := iff(xCSI < xMACSI, 1,
	   iff(xCSI > xMACSI, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue ) 
plot(xCSI, color=green, title="CSI")
plot(xMACSI, color=red, title="CSI SMA")
````
