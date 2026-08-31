<!-- tradingview-pine-id: PUB;35121ed548984a0a8eb37cbd95e9bc1c -->
<!-- tradingviewscripts-format: 1 -->
# HTF MACD Turn

Source: https://www.tradingview.com/script/zYKiXzvv/

## Description

This indicator uses the MACD histogram from a higher timeframe to identify confirmed momentum shifts and generate signals on the main chart

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("HTF MACD Turn", shorttitle = "HTF MACD Turn", overlay = true)

// --- Constants ---
const string GROUP_MACD = "MACD Settings"
const color BULL_COLOR = #089981
const color BEAR_COLOR = #F23645

// --- Inputs ---
string htfInput = input.timeframe("60", "Higher Timeframe", group = GROUP_MACD, tooltip = "The higher timeframe used to calculate MACD. Signals use confirmed higher-timeframe candle data.")
sourceInput = input.source(close, "Source", group = GROUP_MACD, tooltip = "The data source used for MACD.")
int fastLengthInput = input.int(12, "Fast Length", minval = 1, group = GROUP_MACD, tooltip = "The fast EMA length for MACD.")
int slowLengthInput = input.int(26, "Slow Length", minval = 2, group = GROUP_MACD, tooltip = "The slow EMA length for MACD.")
int signalLengthInput = input.int(9, "Signal Length", minval = 1, group = GROUP_MACD, tooltip = "The signal-line EMA length for MACD.")

// --- Functions ---
macdHistogram(series float source, int fastLength, int slowLength, int signalLength) =>
    [macdLine, signalLine, _] = ta.macd(source, fastLength, slowLength, signalLength)
    macdLine - signalLine

// --- Core logic ---
// Offsetting inside request.security() retrieves confirmed HTF values and avoids
// using the still-forming HTF candle.
float htfHistogram1 = request.security(
     syminfo.tickerid,
     htfInput,
     macdHistogram(sourceInput, fastLengthInput, slowLengthInput, signalLengthInput)[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on)
float htfHistogram2 = request.security(
     syminfo.tickerid,
     htfInput,
     macdHistogram(sourceInput, fastLengthInput, slowLengthInput, signalLengthInput)[2],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on)
float htfHistogram3 = request.security(
     syminfo.tickerid,
     htfInput,
     macdHistogram(sourceInput, fastLengthInput, slowLengthInput, signalLengthInput)[3],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on)

int slopeNow = htfHistogram1 > htfHistogram2 ? 1 : htfHistogram1 < htfHistogram2 ? -1 : 0
int slopePrevious = htfHistogram2 > htfHistogram3 ? 1 : htfHistogram2 < htfHistogram3 ? -1 : 0

bool shortSignal = slopeNow == -1 and slopePrevious == 1 and slopeNow[1] != -1
bool longSignal = slopeNow == 1 and slopePrevious == -1 and slopeNow[1] != 1

// --- Visual elements ---
plotshape(longSignal, title = "Long Signal", style = shape.labelup, location = location.belowbar, color = BULL_COLOR, text = "up", textcolor = color.white, size = size.tiny)
plotshape(shortSignal, title = "Short Signal", style = shape.labeldown, location = location.abovebar, color = BEAR_COLOR, text = "down", textcolor = color.white, size = size.tiny)

// --- Alerts ---
alertcondition(longSignal, title = "HTF MACD Long", message = "HTF MACD histogram changed from falling to rising: long signal")
alertcondition(shortSignal, title = "HTF MACD Short", message = "HTF MACD histogram changed from rising to falling: short signal")
````
