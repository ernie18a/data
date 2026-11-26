# [STRATEGY][RS]MarxBabu 4 Oscillators V0

- url: https://www.tradingview.com/script/jG5QmbAr-STRATEGY-RS-MarxBabu-4-Oscillators-V0/
- type: strategy
- pine_id: PUB;2115
- version: -1.0

## Description

EXPERIMENTAL:
Request for MarxBabu.

## Source Code

````pine
strategy(title='[STRATEGY][RS]MarxBabu 4 Oscillators V0', shorttitle='O', default_qty_type=strategy.cash, default_qty_value=10000, initial_capital=100000, currency=currency.USD)
//  ||  Inputs:
take_profit_in_ticks = input(title='Take profit in ticks:', type=integer, defval=500)
stop_loss_in_ticks = input(title='Stop loss in ticks:', type=integer, defval=500)
src = input(title='Source:', type=source, defval=hlc3)
length = input(title='Length', type=integer, defval=14)
ob = input(title='Overbought Level:', type=float, defval=80.00)
os = input(title='Oversold Level:', type=float, defval=20.00)
//  ||  Functions:
f_mf(_src, _length)=>
    _upper = sum(volume * (change(_src) <= 0 ? 0 : _src), _length)
    _lower = sum(volume * (change(_src) >= 0 ? 0 : _src), _length)
    _return = rsi(_upper, _lower)

f_srsi(_src, _rsi_length, _stoch_length, _smooth)=>
    _rsi = rsi(_src, _rsi_length)
    _return = sma(stoch(_rsi, _rsi, _rsi, _stoch_length), _smooth)

f_wr(_src, _length)=>
    _upper = highest(_length)
    _lower = lowest(_length)
    _out = 100 + (100 * (_src - _upper) / (_upper - _lower))

//  ||  Indicator Variables:
rsi = rsi(src, length)
mfi = f_mf(src, length)
srsi = f_srsi(src, length, length, 1)
wr = f_wr(src, length)

plot(title='RSI', series=rsi, color=black)
plot(title='SRSI', series=srsi, color=black)
plot(title='MFI', series=mfi, color=black)
plot(title='%R', series=wr, color=black)

overbought=hline(80, title="Overbought", color=#c0c0c0)
oversold=hline(20, title="Oversold", color=#c0c0c0)
fill(overbought, oversold, color=#9915ff, transp=90)

buy_condition = rsi > ob and srsi > ob and mfi > ob and wr > ob
sel_condition = rsi < os and srsi < os and mfi < os and wr < os

strategy.entry('buy', long=true, comment='buy', when=buy_condition)
strategy.entry('sel', long=false, comment='sell', when=sel_condition)
strategy.exit('exit buy', from_entry='buy', profit=take_profit_in_ticks, stop=stop_loss_in_ticks)
strategy.exit('exit sel', from_entry='sel', profit=take_profit_in_ticks, stop=stop_loss_in_ticks)
````
