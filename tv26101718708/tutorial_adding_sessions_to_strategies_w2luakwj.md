# Tutorial - Adding sessions to strategies

- url: https://www.tradingview.com/script/W2LUAkwJ-Tutorial-Adding-sessions-to-strategies/
- type: strategy
- pine_id: PUB;3df7a3f0803041ceb81152045351892d
- version: 1.0

## Description

A simple script to illustrate how to add sessions to trading strategies.

In this interactive tutorial, you'll learn how to add trading sessions to your strategies using Pine Script. By the end of this session (pun intended!), you'll be able to create custom trading windows that adapt to changing market conditions.

What You'll Learn:
[list=1]
[*] Defining Trading Sessions: Understand how to set up specific time frames for buying and selling, tailored to your unique trading style.
[*] RSI-Based Entry Signals: Discover how to use the Relative Strength Index (RSI) as a trigger for buy and sell signals, helping you capitalize on market trends.
[*] Combining Session Logic with Trading Decisions: Learn how to integrate session-based logic into your strategy, ensuring that trades are executed only during designated times.
[/list]

By combining these elements, we create an interactive strategy that:
[list=1]
[*]1. Generates buy and sell signals based on RSI levels.
[*]2. Checks if the market is open during a specific trading session (e.g., 1300-1700).
[*]3. Executes trades only when both conditions are met.
[/list]

**Tips & Variations:**

* Experiment with different RSI periods, thresholds, and sessions to optimize your strategy for various markets and time frames.
* Consider adding more advanced logic, such as stop-losses or position sizing, to further refine your trading approach.

Get ready to take your Pine Script skills to the next level!

[i]~Description partially generated with Llama3_8B[/i]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RicardoSantos

//@version=6

string LTITLE = 'Tutorial - Adding sessions to strategies'
string STITLE = 'T'
strategy(LTITLE, STITLE, overlay=true)

// RSI trading logic

float rsi = ta.rsi(close, 14)
float u = 70.0
float l = 30.0

bool buy_signal = ta.crossover(rsi, l)
bool sel_signal = ta.crossunder(rsi, u)

// Session logic

// @variable String with session information.
string session = input.session('1300-1700', 'Session:', options=['0930-1600', '1300-1700', '1700-2100'])
// @variable check if current time is within session window.
bool in_session = not na(time(timeframe.period, session))

// Trading logic:

if in_session
    if buy_signal
        strategy.entry('buy', strategy.long)
    if sel_signal
        strategy.entry('sel', strategy.short)
else
    strategy.close_all('Out of Session')
````
