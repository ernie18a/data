# G8 Single Currency Rate Yield Ampel Stable

- url: https://www.tradingview.com/script/eqx4ck1v/
- type: indicator
- pine_id: PUB;63a3e2f4496642fd82aad61d660e5101
- version: 1.0

## Description

G8 Single Currency Rate/Yield Traffic Light

G8 Single Currency Rate/Yield Traffic Light is a macro-driven FX bias indicator designed to visualize whether the current interest-rate and yield environment supports a bullish, neutral, or bearish bias for a selected G8 currency.

The indicator is built around a simple but powerful macro principle:

Rising yields usually support a currency, while falling yields usually weaken it.
Rising short-rate futures usually imply lower expected policy rates and are therefore interpreted as bearish for the currency. Falling short-rate futures imply higher expected policy rates and are interpreted as bullish.

This tool is not designed as a standalone buy or sell signal. It is intended to act as a macro bias filter for FX traders who want to align their trade ideas with the current direction of rates, yields, and currency momentum.

Supported Currencies

The indicator currently supports the following G8 currencies:

USD
EUR
GBP
CHF
JPY
AUD
NZD
CAD

The selected currency can be changed directly in the settings menu.

Core Logic

The indicator calculates a score based on four possible components:

1. 2-Year Government Yield

The 2-year yield is usually very sensitive to central bank expectations.

2Y yield rising = bullish for the currency
2Y yield falling = bearish for the currency
2. 10-Year Government Yield

The 10-year yield reflects longer-term macro conditions, inflation expectations, growth expectations, and term premium.

10Y yield rising = supportive for the currency
10Y yield falling = negative for the currency
3. Short-Rate Futures

Short-rate futures are interpreted inversely.

Future price rising = lower expected rates = bearish for the currency
Future price falling = higher expected rates = bullish for the currency

Examples:

USD: SOFR future
EUR: Euribor future
GBP: short-rate / sterling rate future proxy
CAD: CORRA future proxy
CHF: SARON future proxy
AUD/NZD/JPY: rate future proxies depending on TradingView data availability
4. FX Proxy

The indicator can also include a currency proxy, such as:

DXY for USD
EURUSD for EUR
GBPUSD for GBP
AUDUSD for AUD
NZDUSD for NZD
USDCHF for CHF
USDJPY for JPY
USDCAD for CAD

For inverted pairs such as USDCHF, USDJPY, and USDCAD, the logic is automatically inverted.

Example:

USDJPY rising = JPY weakness
USDJPY falling = JPY strength
Score Interpretation

Each active module contributes either:

+1 = bullish contribution
 0 = neutral / no contribution
-1 = bearish contribution

The total score is then plotted as a colored histogram.

Default interpretation:

Score >= +2 = bullish / green
Score between -1 and +1 = neutral / yellow
Score <= -2 = bearish / red

The thresholds can be adjusted in the settings.

Traffic Light Colors
Green

A green signal means that the selected currency currently has positive macro/rate momentum.

This may indicate that:

Yields are rising
Rate futures are falling
The FX proxy is confirming currency strength

In practical FX analysis, this means the selected currency may be preferred as the stronger side of a currency pair.

Yellow

A yellow signal means that the picture is mixed or neutral.

This may happen when:

Short-term yields and long-term yields disagree
Rate futures and yields send conflicting signals
The FX proxy is not confirming the rate/yield picture

In this state, traders may prefer to wait for clearer confirmation or rely more heavily on upcoming catalysts, price structure, or higher-timeframe analysis.

Red

A red signal means that the selected currency currently has negative macro/rate momentum.

This may indicate that:

Yields are falling
Rate futures are rising
The FX proxy confirms currency weakness

In practical FX analysis, this means the selected currency may be the weaker side of a currency pair.

Example Use Cases
EURUSD

If the EUR indicator is green and the USD indicator is red, this supports a EURUSD long bias.

If the EUR indicator is red and the USD indicator is green, this supports a EURUSD short bias.

If both currencies are green or both are red, the relative edge is less clear.

GBPJPY

If GBP is green and JPY is red, the macro/rate environment supports a GBPJPY long bias.

If GBP is red and JPY is green, the macro/rate environment supports a GBPJPY short bias.

AUDCAD

If AUD is green and CAD is red, the relative rate/yield picture supports AUDCAD long ideas.

If AUD is red and CAD is green, AUDCAD short ideas may be favored.

Recommended Timeframes

The indicator can be used on different timeframes depending on the trader’s style.

H1

The H1 timeframe is a good balance between responsiveness and stability. It is useful for intraday bias and short-term macro alignment.

Recommended setting:

Momentum Length: 8
H4

H4 can be used for a broader daily bias. It filters more noise and is better for traders who want fewer signal changes.

Daily

The daily timeframe can be used as a structural macro filter for swing trading and weekly FX planning.

Recommended Settings

For an H1 chart, a balanced default setup is:

Momentum Length: 8
2Y Yield: enabled
10Y Yield: enabled
Rate Future: enabled if data is available
FX Proxy: enabled
Long Threshold: +2
Short Threshold: -2

For a cleaner pure macro/rates model, the FX proxy can be disabled. In that case, the indicator focuses only on yields and short-rate futures.

Important Notes About Symbols

Some short-rate futures may not be available for every user depending on TradingView data access and exchange permissions.

If a futures symbol does not load, the indicator should still work because invalid symbols are ignored. In that case, the user can either:

disable the Rate Future module, or
manually replace the symbol in the settings with a valid TradingView symbol.

The most important components are usually the 2-year yield and short-rate future, because they are more directly linked to central bank expectations.

What This Indicator Is Designed For

This indicator is designed to help traders answer one specific question:

Does the current rate and yield environment support strength or weakness in this currency?

It can be used as part of a broader FX workflow:

1. Check macro calendar and news catalysts
2. Check the G8 currency traffic lights
3. Compare strong currencies against weak currencies
4. Build a directional bias for selected FX pairs
5. Use price action, volume profile, RSI, TSV, VWAP, or other tools for execution

The indicator is best used as a bias filter, not as a direct entry trigger.

Limitations

This indicator does not predict the future.

It does not include:

central bank speeches in real time
inflation surprises
geopolitical risk
liquidity shocks
positioning extremes
full yield curve analysis
options market structure
relative growth data

It should therefore be combined with macro context, event risk, technical structure, and proper risk management.

Disclaimer

This script is for educational and analytical purposes only. It does not provide financial advice, investment advice, or trading recommendations. All trading decisions are the responsibility of the user. Markets involve risk, and past behavior of rates, yields, or currencies does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("G8 Single Currency Rate Yield Ampel Stable", overlay=false)

// Main Settings
currency = input.string("USD", "Currency", options=["USD", "EUR", "GBP", "CHF", "JPY", "AUD", "NZD", "CAD"])
len = input.int(8, "Momentum Laenge", minval=1)

use2Y = input.bool(true, "2Y Yield einbeziehen")
use10Y = input.bool(true, "10Y Yield einbeziehen")
useFuture = input.bool(true, "Rate Future einbeziehen")
useProxy = input.bool(true, "FX Proxy einbeziehen")

bullThreshold = input.int(2, "Long Schwelle", minval=1)
bearThreshold = input.int(-2, "Short Schwelle", maxval=-1)

// USD Settings
symUSD2Y = input.string("TVC:US02Y", "USD 2Y Yield")
symUSD10Y = input.string("TVC:US10Y", "USD 10Y Yield")
symUSDFut = input.string("CME:SR31!", "USD SOFR Future Front")
symUSDProxy = input.string("TVC:DXY", "USD Proxy DXY")

// EUR Settings
symEUR2Y = input.string("TVC:DE02Y", "EUR 2Y Yield Proxy")
symEUR10Y = input.string("TVC:DE10Y", "EUR 10Y Yield Proxy")
symEURFut = input.string("EUREX:FEU31!", "EUR Euribor Future Front")
symEURProxy = input.string("FX:EURUSD", "EUR Proxy EURUSD")

// GBP Settings
symGBP2Y = input.string("TVC:GB02Y", "GBP 2Y Yield")
symGBP10Y = input.string("TVC:GB10Y", "GBP 10Y Yield")
symGBPFut = input.string("ICEEUR:SS31!", "GBP Rate Future Front")
symGBPProxy = input.string("FX:GBPUSD", "GBP Proxy GBPUSD")

// CHF Settings
symCHF2Y = input.string("TVC:CH02Y", "CHF 2Y Yield")
symCHF10Y = input.string("TVC:CH10Y", "CHF 10Y Yield")
symCHFFut = input.string("ICEEUR:SAR1!", "CHF SARON Future Front")
symCHFProxy = input.string("FX:USDCHF", "CHF Proxy USDCHF")

// JPY Settings
symJPY2Y = input.string("TVC:JP02Y", "JPY 2Y Yield")
symJPY10Y = input.string("TVC:JP10Y", "JPY 10Y Yield")
symJPYFut = input.string("OSE:3JB1!", "JPY Rate Future Front")
symJPYProxy = input.string("FX:USDJPY", "JPY Proxy USDJPY")

// AUD Settings
symAUD2Y = input.string("TVC:AU02Y", "AUD 2Y Yield")
symAUD10Y = input.string("TVC:AU10Y", "AUD 10Y Yield")
symAUDFut = input.string("ASX:IR1!", "AUD 90 Day Bank Bill Future Front")
symAUDProxy = input.string("FX:AUDUSD", "AUD Proxy AUDUSD")

// NZD Settings
symNZD2Y = input.string("TVC:NZ02Y", "NZD 2Y Yield")
symNZD10Y = input.string("TVC:NZ10Y", "NZD 10Y Yield")
symNZDFut = input.string("ASX:BB1!", "NZD Bank Bill / Rate Future Front")
symNZDProxy = input.string("FX:NZDUSD", "NZD Proxy NZDUSD")

// CAD Settings
symCAD2Y = input.string("TVC:CA02Y", "CAD 2Y Yield")
symCAD10Y = input.string("TVC:CA10Y", "CAD 10Y Yield")
symCADFut = input.string("MX:CRA1!", "CAD CORRA Future Front")
symCADProxy = input.string("FX:USDCAD", "CAD Proxy USDCAD")

// Currency Selection
sym2Y = currency == "USD" ? symUSD2Y :
     currency == "EUR" ? symEUR2Y :
     currency == "GBP" ? symGBP2Y :
     currency == "CHF" ? symCHF2Y :
     currency == "JPY" ? symJPY2Y :
     currency == "AUD" ? symAUD2Y :
     currency == "NZD" ? symNZD2Y :
     symCAD2Y

sym10Y = currency == "USD" ? symUSD10Y :
     currency == "EUR" ? symEUR10Y :
     currency == "GBP" ? symGBP10Y :
     currency == "CHF" ? symCHF10Y :
     currency == "JPY" ? symJPY10Y :
     currency == "AUD" ? symAUD10Y :
     currency == "NZD" ? symNZD10Y :
     symCAD10Y

symFuture = currency == "USD" ? symUSDFut :
     currency == "EUR" ? symEURFut :
     currency == "GBP" ? symGBPFut :
     currency == "CHF" ? symCHFFut :
     currency == "JPY" ? symJPYFut :
     currency == "AUD" ? symAUDFut :
     currency == "NZD" ? symNZDFut :
     symCADFut

symProxy = currency == "USD" ? symUSDProxy :
     currency == "EUR" ? symEURProxy :
     currency == "GBP" ? symGBPProxy :
     currency == "CHF" ? symCHFProxy :
     currency == "JPY" ? symJPYProxy :
     currency == "AUD" ? symAUDProxy :
     currency == "NZD" ? symNZDProxy :
     symCADProxy

// Proxy-Invertierung automatisch
proxyInverted = currency == "CHF" or currency == "JPY" or currency == "CAD"

// Data
y2 = request.security(sym2Y, timeframe.period, close, ignore_invalid_symbol=true)
y10 = request.security(sym10Y, timeframe.period, close, ignore_invalid_symbol=true)
fut = request.security(symFuture, timeframe.period, close, ignore_invalid_symbol=true)
proxy = request.security(symProxy, timeframe.period, close, ignore_invalid_symbol=true)

// Momentum
y2Mom = y2 - y2[len]
y10Mom = y10 - y10[len]
futMom = fut - fut[len]
proxyMom = proxy - proxy[len]

// Scores
score2Y = use2Y and not na(y2Mom) ? (y2Mom > 0 ? 1 : y2Mom < 0 ? -1 : 0) : 0
score10Y = use10Y and not na(y10Mom) ? (y10Mom > 0 ? 1 : y10Mom < 0 ? -1 : 0) : 0

// Rate Future invers:
// Future steigt = dovisher = Waehrung bearish
// Future faellt = hawkisher = Waehrung bullish
scoreFuture = useFuture and not na(futMom) ? (futMom < 0 ? 1 : futMom > 0 ? -1 : 0) : 0

// FX Proxy
scoreProxyNormal = proxyMom > 0 ? 1 : proxyMom < 0 ? -1 : 0
scoreProxyInverse = proxyMom < 0 ? 1 : proxyMom > 0 ? -1 : 0
scoreProxy = useProxy and not na(proxyMom) ? (proxyInverted ? scoreProxyInverse : scoreProxyNormal) : 0

// Total Score
score = score2Y + score10Y + scoreFuture + scoreProxy

isBull = score >= bullThreshold
isBear = score <= bearThreshold

signalColor = isBull ? color.green : isBear ? color.red : color.yellow

// Plot
plot(score, title="Currency Score", style=plot.style_columns, color=signalColor, linewidth=3)

hline(bullThreshold, "Long Bias", color=color.green)
hline(0, "Neutral", color=color.gray)
hline(bearThreshold, "Short Bias", color=color.red)

bgcolor(isBull ? color.new(color.green, 85) : isBear ? color.new(color.red, 85) : color.new(color.yellow, 88))

// Data Window
plot(score2Y, title="Score 2Y Yield", display=display.data_window)
plot(score10Y, title="Score 10Y Yield", display=display.data_window)
plot(scoreFuture, title="Score Rate Future", display=display.data_window)
plot(scoreProxy, title="Score FX Proxy", display=display.data_window)
````
