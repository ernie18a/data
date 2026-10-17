# ATR Position Sizer

- url: https://www.tradingview.com/script/sGEH40hF-ATR-Position-Sizer/
- type: indicator
- pine_id: PUB;52401e5e450c46c1bff6ecd16a37c0e2
- version: 1.0

## Description

[b]ATR Position Sizer
[/b]
A simple position sizing tool for futures traders. Calculates how many contracts to trade based on your risk tolerance and the current ATR-based stop distance.

[b]How it works
[/b]
The indicator uses the standard formula:
Contracts = Risk $ ÷ (ATR × Stop Multiplier × Dollar per Point)
It pulls the contract's dollar-per-point value directly from the symbol info, so you don't need to enter it manually. At the close of each bar, the calculation updates and displays in the bottom right of your chart.

Inputs
[list]
[*]ATR Lookback (bars): How many bars to use for the ATR calculation. Default is 14.
[*]Risk Tolerance ($): Maximum dollar amount you're willing to lose on the trade. Default is $250.
[*]Stop Multiplier (xATR): How wide your stop is relative to ATR. Default is 1.5x.
[/list]

[b]How to use it
[/b]
[list=1]
[*]Add the indicator to your chart.
[*]Set your ATR lookback, risk tolerance, and stop multiplier in the settings.
[*]At the close of your entry candle, look at the contracts value in the bottom right.
[*]Size your trade accordingly.
[/list]

The output is a decimal so you can see exactly where you stand. Round down if you want to stay within your risk, round up if you're comfortable taking slightly more.

[b]Supported instruments
[/b]
This indicator was designed and tested on the following futures contracts:

S&P 500: ES, MES
Nasdaq 100: NQ, MNQ
Russell 2000: RTY, M2K
Dow: YM, MYM
Nikkei 225: NKD, NIY
Gold: GC, MGC
Crude Oil: CL, QM, MCL

It may work on other futures contracts that have a defined point value in TradingView, but results outside the listed instruments are not guaranteed.
Disclaimers
This indicator is for educational and informational purposes only. It is not financial advice, investment advice, or a trading recommendation.
The calculations assume your actual stop loss will be placed at the ATR-based distance. If you use a different stop placement method, your real risk will differ from what this indicator shows. Always verify your stop placement and position size before entering a trade.
ATR is a backward-looking measure of volatility. It does not predict future price movement, slippage, gaps, or news-driven volatility expansion. Your actual loss on a trade can exceed the calculated risk amount, especially on thinly traded instruments, around economic releases, or during overnight sessions.
This tool does not account for commissions, exchange fees, margin requirements, account size, or overall portfolio exposure. You are responsible for ensuring any position size is appropriate for your account and risk profile.
Futures trading involves substantial risk of loss and is not suitable for every investor. Past performance is not indicative of future results. Trade at your own risk.

## Source Code

````pine
//@version=5
indicator("ATR Position Sizer", overlay=true)

// === INPUTS ===
lookback     = input.int(14,    title="ATR Lookback (bars)",   minval=1,   tooltip="How many bars to use for ATR calculation")
risk_dollars = input.float(250, title="Risk Tolerance ($)",    minval=1,   step=50)
stop_mult    = input.float(1.5, title="Stop Multiplier (xATR)", minval=0.1, step=0.1)

// === CALCULATIONS ===
atr_val           = ta.atr(lookback)
pt_value          = syminfo.pointvalue
stop_points       = atr_val * stop_mult
risk_per_contract = stop_points * pt_value
contracts         = risk_per_contract > 0 ? risk_dollars / risk_per_contract : 0

// === TABLE ===
var table info = table.new(position.bottom_right, 2, 2, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast
    table.cell(info, 0, 0, "Risk",                                text_color=color.white, bgcolor=color.new(color.blue, 50), text_size=size.small)
    table.cell(info, 1, 0, "$" + str.tostring(risk_dollars, "#"), text_color=color.white,                                    text_size=size.small)

    table.cell(info, 0, 1, "CONTRACTS",                           text_color=color.white, bgcolor=color.new(color.green, 30), text_size=size.small)
    table.cell(info, 1, 1, str.tostring(contracts, "#.##"),       text_color=color.white, bgcolor=color.new(color.green, 30), text_size=size.small)
````
