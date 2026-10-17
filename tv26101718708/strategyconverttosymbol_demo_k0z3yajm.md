# strategy.convert_to_symbol() demo

- url: https://www.tradingview.com/script/K0z3yajM-strategy-convert-to-symbol-demo/
- type: strategy
- pine_id: PUB;e494518ea2ce4f18b644c6668203b067
- version: 1.0

## Description

A strategy demonstrating the new strategy.convert_to_symbol() and strategy.convert_to_account() functions introduced in Pine v5.

Try selecting a custom "Base Currency" under Properties to see how the conversion works.

Note: The conversion functions seem to work as expected on BTCUSD, but not on BTCUSDT. This is likely because USDT is not recognized as a currency.

## Source Code

````pine
// @version=5

// A strategy demonstrating the new strategy.convert_to_symbol() and
// strategy.convert_to_account() functions.
//
// Try selecting a custom "Base Currency" under Properties to see how the
// conversion works.
//
// Note: The conversion functions seem to work as expected on BTCUSD,
// but not on BTCUSDT. This is likely because USDT is not recognized as a
// currency.

strategy("strategy.convert_to_symbol() demo", overlay=true, margin_long=100, margin_short=100)

f_print(string _text) => 
    var table _t = table.new(position.middle_right, 1, 1, border_width = 10)
    table.cell(_t, 0, 0, _text, text_color = color.white, bgcolor = color.new(#283b53, 70), text_halign = text.align_left)

var string accountCurrency = strategy.account_currency == "" ? "Default" : strategy.account_currency

f_print(
  str.format("strategy.initial_capital = {0,number}", strategy.initial_capital) + "\n\n" +
  
  str.format("strategy.account_currency = {0}", accountCurrency) + "\n\n" +
  
  str.format("{0,number} {1} (account) = {2,number} {3} (symbol)", 
      strategy.initial_capital, 
      accountCurrency,
      strategy.convert_to_symbol(strategy.initial_capital),
      syminfo.currency
  ) + "\n\n" +
  
  str.format("{0,number} {1} (symbol) = {2,number} {3} (account)", 
      strategy.convert_to_symbol(strategy.initial_capital), 
      syminfo.currency,
      strategy.convert_to_account(strategy.convert_to_symbol(strategy.initial_capital)),
      accountCurrency
  )
  
  )

plot(ta.ema(close, 14))
````
