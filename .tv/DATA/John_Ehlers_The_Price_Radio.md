<!-- tradingview-pine-id: PUB;MIpad8EDpyM5jl51q4BqEgN9USU2BlgP -->
<!-- tradingviewscripts-format: 1 -->
# John Ehlers - The Price Radio

Source: https://www.tradingview.com/script/W5lBL0MV-John-Ehlers-The-Price-Radio/

## Description

Price curves consist of much noise and little signal. For separating the latter from the former, John Ehlers proposed in the Stocks&Commodities May 2021 issue an unusual approach: Treat the price curve like a radio wave. Apply AM and FM demodulating technology for separating trade signals from the underlying noise.
reference: https://financial-hacker.com/petra-on-programming-the-price-wave-radio/

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RicardoSantos

//@version=4
study(title='John Ehlers - The Price Radio')

// reference: 
//      https://financial-hacker.com/petra-on-programming-the-price-wave-radio/
clamp(_value, _min, _max)=>
    _t = _value < _min ? _min : _value
    _t > _max ? _max : _t

am(_signal, _period)=>
    _envelope = highest(abs(_signal), 4)
    sma(_envelope, _period)

fm(_signal, _period)=>
    _h = highest(_signal, _period)
    _l = lowest(_signal, _period)
    _hl = clamp(10. * _signal, _l, _h)//-1., 1.)
    sma(_hl, _period)

deriv = change(close, input(1))
length = input(14)
plot(series=deriv, title='D', color=color.black)
plot(series=am(deriv, length), title='AM+', color=color.red)
plot(series=-am(deriv, length), title='AM-', color=color.lime)
plot(series=fm(deriv, length), title='FM', color=color.navy)
````
