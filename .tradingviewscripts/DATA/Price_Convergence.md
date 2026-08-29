<!-- tradingview-pine-id: PUB;mRdXHnBaTsU5UYNt2fKriF7RSrTpod5e -->
<!-- tradingviewscripts-format: 1 -->
# Price Convergence

Source: https://www.tradingview.com/script/FK25igs7-Price-Convergence/

## Description

Compares the probability of price increase to the probability of price decrease to predict the likelihood of price discovery.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nickbarcomb

//@version=4
study("Price Convergence", precision=2)
_F = input(true, "Full History (ignore Range)")
_R = input(200, "Range", minval=1)
a = _F ? cum(ohlc4) : sum(ohlc4, _R)

E(d) =>
    if _F
        d ? cum(close >= open ? ohlc4 : 0) : cum(close <= open ? ohlc4 : 0)
    else
        d ? sum(close >= open ? ohlc4 : 0, _R) : sum(close <= open ? ohlc4 : 0, _R)
        
A(E) =>
    E / a * 100
    
// probability of price increase
plot(A(E(true)), "Prob. Up", color=#00ff88)
// probability of price decrease
plot(A(E(false)), "Prob. Dw", color=#ff0088)

// price discover is accomplished when the price sustains at 50
hline(50, color=#888888)
````
