# Reversal & COG

- url: https://www.tradingview.com/script/e77tdOME-Reversal-COG/
- type: strategy
- pine_id: PUB;eb01d069bc9e4875a046af026b59e79d
- version: 1.0

## Description

This trading strategy is a multi-layered trend-reversal system that combines the **Reversal 123** methodology with a **Center of Gravity (COG)** channel filter. The core logic requires a dual-confirmation: the Reversal 123 component identifies short-term momentum shifts using specific price action patterns and Stochastic Oscillator levels, while the Center of Gravity indicator establishes a "fair value" corridor based on linear regression. A trade is only executed when both indicators align—entering long when price breaks above the lower COG band amid a bullish reversal pattern, and entering short when it breaks below the upper band during a bearish pattern. To enhance risk management, the script includes directional toggles and an optional percentage-based stop loss, ensuring that entries are only taken in the user's preferred direction while protecting capital against sudden volatility.

## Source Code

````pine
//@version=6
strategy(title="Reversal & COG", shorttitle="COG", overlay = false)

// --- Inputs ---
Length = input.int(5, minval=1)
KSmoothing = input.int(20, minval=1)
DLength = input.int(4, minval=1)
Level = input.int(4, minval=1)
LengthCoF = input.int(4, minval=1)
m = input.int(14, minval=0)
Percent = input.float(1.0, minval=0)
SignalLine = input.int(1, minval=1, maxval=2, title="Trade from line (1 or 2)")
reverse = input.bool(false, title="Trade reverse")

// --- NEW Toggles & SL ---
enableLong  = input.bool(true, title="Enable Long Trades")
enableShort = input.bool(true, title="Enable Short Trades")
useSL       = input.bool(false, title="Use Stop Loss (%)")
slPercent   = input.float(1.5, title="Stop Loss %", step=0.1)

// --- Functions ---
Reversal123(L, KS, DL, LL) =>
    vFast = ta.sma(ta.stoch(close, high, low, L), KS) 
    vSlow = ta.sma(vFast, DL)
    var float pos = 0.0
    // v4 logic used "pos[1]" for persistence. In v6 we use 'var' or explicit referencing.
    pos := (close[2] < close[1] and close > close[1] and vFast < vSlow and vFast > LL) ? 1.0 :
           (close[2] > close[1] and close < close[1] and vFast > vSlow and vFast < LL) ? -1.0 : nz(pos[1], 0.0)
    pos

CenterOfGravity(L, _m, P, SL) =>
    var float pos = 0.0
    xLG = ta.linreg(close, L, _m)
    xLG1r = xLG + ((close * P) / 100)
    xLG1s = xLG - ((close * P) / 100)
    xLG2r = xLG + ((close * P) / 100) * 2
    xLG2s = xLG - ((close * P) / 100) * 2
    xSignalR = (SL == 1) ? xLG1r : xLG2r
    xSignalS = (SL == 1) ? xLG1s : xLG2s
    pos := (close > xSignalR) ? 1.0 : (close < xSignalS) ? -1.0 : nz(pos[1], 0.0)
    pos

// --- Signals ---
posReversal123 = Reversal123(LengthCoF, KSmoothing, DLength, Level)
posCenterOfGravity = CenterOfGravity(Length, m, Percent, SignalLine)

// v4 Logic: iff(posReversal123 == 1 and posCenterOfGravity == 1 , 1, iff(posReversal123 == -1 and posCenterOfGravity == -1, -1, 0))
int pos = (posReversal123 == 1.0 and posCenterOfGravity == 1.0) ? 1 :
          (posReversal123 == -1.0 and posCenterOfGravity == -1.0) ? -1 : 0

int possig = reverse ? (pos == 1 ? -1 : pos == -1 ? 1 : 0) : pos

// --- Execution ---
if (possig == 1 and enableLong)
    strategy.entry("Long", strategy.long)

if (possig == -1 and enableShort)
    strategy.entry("Short", strategy.short)

// v4 close logic
if (possig == 0)
    strategy.close_all()

// --- Stop Loss ---
float longSL  = strategy.position_avg_price * (1 - slPercent / 100)
float shortSL = strategy.position_avg_price * (1 + slPercent / 100)

if (useSL)
    strategy.exit("SL Long", "Long", stop=longSL)
    strategy.exit("SL Short", "Short", stop=shortSL)

// --- Visuals ---
barcolor(possig == -1 ? #b50404 : possig == 1 ? #079605 : #0536b3)
````
