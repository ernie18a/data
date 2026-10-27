# LH | NQ Bond Yield Bias 10Y

- url: https://www.tradingview.com/script/GfGrwuaD-LH-NQ-Bond-Yield-Bias-10Y/
- type: indicator
- pine_id: PUB;f4c9ae33461a489aacf940d86f2b883a
- version: 1.0

## Description

**Liquidity Hunter | NQ Bond Yield Bias**

This indicator gives NQ traders a quick read on five markets: the 10-year Treasury yield, 2-year Treasury yield, VIX, DXY, and crude oil (CL). It turns their recent moves into a **LONG BIAS**, **SHORT BIAS**, or **NEUTRAL / WAIT** reading on your chart.

The 10-year yield anchors the signal and carries two points in the alignment score. By default, falling 10-year yields, VIX, and DXY favor a long NQ bias; rising readings favor a short bias. The script requires a score of at least +3 or −3, so the 10-year move needs confirmation from another enabled market. The 2-year yield can be required as a separate confirmation.

CL appears in the table but does not affect the bias unless you turn it on. Its relationship to NQ can vary, so the settings let you choose whether rising CL counts toward a long or short bias. You can also adjust each market’s minimum move, the comparison period, quote freshness, and an optional NQ EMA filter.

The table shows each reading, the alignment score, and the reason for a neutral result. Optional chart markers and alerts fire when the bias changes.

**How I use it:** The bias helps set my NQ narrative. I still wait for my liquidity sweep and price confirmation before considering an entry. **NO SWEEP. NO TRADE. 🏹**

This is a market context tool, not a standalone trade signal. Relationships between yields, volatility, the dollar, crude oil, and NQ can change.

## Source Code

````pine
//@version=6
indicator("LH | NQ Bond Yield Bias", shorttitle="LH Yield Bias", overlay=true)

// Yield quotes are in percent. A 0.01 percentage-point move is one basis point.
groupYield = "Treasury yields"
tenSymbol = input.symbol("TVC:US10Y", "10Y yield", group=groupYield)
twoSymbol = input.symbol("TVC:US02Y", "2Y yield", group=groupYield)
yieldTf = input.timeframe("60", "Yield timeframe", group=groupYield)
smoothBars = input.int(3, "Yield EMA bars", minval=1, group=groupYield)
changeBars = input.int(3, "Compare with bars ago", minval=1, group=groupYield)
minBp = input.float(1.0, "Minimum move (basis points)", minval=0.0, step=0.25, group=groupYield)
confirm2Y = input.bool(false, "Require 2Y agreement", group=groupYield)
maxAgeMins = input.int(180, "Maximum quote age (minutes)", minval=1, group=groupYield)

groupMacro = "VIX / DXY / crude"
vixSymbol = input.symbol("TVC:VIX", "VIX symbol", group=groupMacro)
dxySymbol = input.symbol("TVC:DXY", "DXY symbol", group=groupMacro)
clSymbol = input.symbol("NYMEX:CL1!", "CL symbol", group=groupMacro)
useVix = input.bool(true, "Count VIX in bias", group=groupMacro)
useDxy = input.bool(true, "Count DXY in bias", group=groupMacro)
useCl = input.bool(false, "Count CL in bias", group=groupMacro)
clRelation = input.string("Inverse", "CL to NQ relationship", options=["Inverse", "Direct"], group=groupMacro)
vixThreshold = input.float(0.5, "VIX minimum change (%)", minval=0, step=0.1, group=groupMacro)
dxyThreshold = input.float(0.1, "DXY minimum change (%)", minval=0, step=0.05, group=groupMacro)
clThreshold = input.float(0.5, "CL minimum change (%)", minval=0, step=0.1, group=groupMacro)
requiredScore = input.int(3, "Minimum alignment score (10Y = 2)", minval=1, maxval=5, group=groupMacro)

groupNQ = "NQ confirmation"
useNqFilter = input.bool(false, "Require NQ EMA agreement", group=groupNQ)
nqEmaLength = input.int(21, "NQ EMA length", minval=1, group=groupNQ)

groupDisplay = "Display"
showTable = input.bool(true, "Show status table", group=groupDisplay)
showSignals = input.bool(true, "Mark bias changes", group=groupDisplay)
shadeBars = input.bool(false, "Color chart bars", group=groupDisplay)
tablePlace = input.string("Top right", "Table location", options=["Top right", "Middle right", "Bottom right", "Top left"], group=groupDisplay)

// Calculate changes on the selected market timeframe, not the NQ chart timeframe.
yieldData(int emaBars, int barsBack) =>
    float smoothed = ta.ema(close, emaBars)
    [close, (smoothed - smoothed[barsBack]) * 100.0, time]

macroData(int emaBars, int barsBack) =>
    float smoothed = ta.ema(close, emaBars)
    [close, (smoothed / smoothed[barsBack] - 1.0) * 100.0, time]

[tenClose, tenBp, tenTime] = request.security(tenSymbol, yieldTf, yieldData(smoothBars, changeBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[twoClose, twoBp, twoTime] = request.security(twoSymbol, yieldTf, yieldData(smoothBars, changeBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[vixClose, vixPct, vixTime] = request.security(vixSymbol, yieldTf, macroData(smoothBars, changeBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[dxyClose, dxyPct, dxyTime] = request.security(dxySymbol, yieldTf, macroData(smoothBars, changeBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[clClose, clPct, clTime] = request.security(clSymbol, yieldTf, macroData(smoothBars, changeBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

// Use the current clock on live bars and chart time on historical bars.
int referenceTime = barstate.isrealtime ? timenow : time
bool tenFresh = not na(tenClose) and not na(tenBp) and not na(tenTime) and referenceTime >= tenTime and referenceTime - tenTime <= maxAgeMins * 60000
bool twoFresh = not na(twoClose) and not na(twoBp) and not na(twoTime) and referenceTime >= twoTime and referenceTime - twoTime <= maxAgeMins * 60000
bool vixFresh = not na(vixClose) and not na(vixPct) and not na(vixTime) and referenceTime >= vixTime and referenceTime - vixTime <= maxAgeMins * 60000
bool dxyFresh = not na(dxyClose) and not na(dxyPct) and not na(dxyTime) and referenceTime >= dxyTime and referenceTime - dxyTime <= maxAgeMins * 60000
bool clFresh = not na(clClose) and not na(clPct) and not na(clTime) and referenceTime >= clTime and referenceTime - clTime <= maxAgeMins * 60000

// A falling 10Y yield, VIX, or DXY contributes to an NQ long bias.
int tenDir = tenFresh ? (tenBp <= -minBp ? 1 : tenBp >= minBp ? -1 : 0) : 0
int twoDir = twoFresh ? (twoBp <= -minBp ? 1 : twoBp >= minBp ? -1 : 0) : 0
int vixDir = vixFresh ? (vixPct <= -vixThreshold ? 1 : vixPct >= vixThreshold ? -1 : 0) : 0
int dxyDir = dxyFresh ? (dxyPct <= -dxyThreshold ? 1 : dxyPct >= dxyThreshold ? -1 : 0) : 0
int clRawDir = clFresh ? (clPct <= -clThreshold ? 1 : clPct >= clThreshold ? -1 : 0) : 0
int clDir = clRelation == "Inverse" ? clRawDir : -clRawDir

int score = tenDir * 2 + (useVix ? vixDir : 0) + (useDxy ? dxyDir : 0) + (useCl ? clDir : 0)

float nqEma = ta.ema(close, nqEmaLength)
bool nqLongOk = not useNqFilter or close > nqEma
bool nqShortOk = not useNqFilter or close < nqEma

int bias = tenDir == 1 and score >= requiredScore and (not confirm2Y or twoDir == 1) and nqLongOk ? 1 : tenDir == -1 and score <= -requiredScore and (not confirm2Y or twoDir == -1) and nqShortOk ? -1 : 0

color gold = color.rgb(191, 153, 55)
color green = color.rgb(26, 145, 78)
color red = color.rgb(188, 49, 55)
color ink = color.rgb(18, 20, 25)
color neutral = color.rgb(100, 106, 115)
color biasColor = bias == 1 ? green : bias == -1 ? red : neutral

string biasText = not tenFresh ? "NO FRESH YIELD" : bias == 1 ? "LONG BIAS" : bias == -1 ? "SHORT BIAS" : "NEUTRAL / WAIT"
string tenText = na(tenClose) ? "NO DATA" : str.tostring(tenClose, "#.###") + "%  " + (na(tenBp) ? "—" : (tenBp > 0 ? "+" : "") + str.tostring(tenBp, "#.##") + " bp")
string twoText = na(twoClose) ? "NO DATA" : str.tostring(twoClose, "#.###") + "%  " + (na(twoBp) ? "—" : (twoBp > 0 ? "+" : "") + str.tostring(twoBp, "#.##") + " bp")

macroText(float value, float pct, bool fresh) =>
    na(value) ? "NO DATA" : not fresh ? "STALE  " + str.tostring(value, "#.##") : str.tostring(value, "#.##") + "  " + (pct > 0 ? "+" : "") + str.tostring(pct, "#.##") + "%"

string reason = not tenFresh ? "10Y feed closed / stale" : confirm2Y and not twoFresh ? "2Y feed closed / stale" : tenDir == 0 ? "10Y move below threshold" : confirm2Y and twoDir != tenDir ? "2Y does not confirm" : useNqFilter and bias == 0 and math.abs(score) >= requiredScore ? "NQ EMA disagrees" : bias == 0 ? "Macro score below minimum" : "Macro alignment confirmed"

tablePos = tablePlace == "Top right" ? position.top_right : tablePlace == "Middle right" ? position.middle_right : tablePlace == "Bottom right" ? position.bottom_right : position.top_left
var table panel = table.new(tablePos, 2, 9, border_width=1, border_color=gold)

if barstate.islast
    if showTable
        table.cell(panel, 0, 0, "LIQUIDITY HUNTER", text_color=color.white, bgcolor=ink, text_size=size.tiny)
        table.cell(panel, 1, 0, "NQ • YIELDS", text_color=gold, bgcolor=ink, text_size=size.tiny)
        table.cell(panel, 0, 1, "BIAS", text_color=color.white, bgcolor=biasColor, text_size=size.tiny)
        table.cell(panel, 1, 1, biasText, text_color=color.white, bgcolor=biasColor, text_size=size.tiny)
        table.cell(panel, 0, 2, "10Y", text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 1, 2, tenText, text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 0, 3, "2Y" + (confirm2Y ? " CONFIRM" : " INFO"), text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 1, 3, twoText, text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 0, 4, "STATUS", text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 1, 4, reason, text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 0, 5, "VIX" + (useVix ? " • ON" : " • INFO"), text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 1, 5, macroText(vixClose, vixPct, vixFresh), text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 0, 6, "DXY" + (useDxy ? " • ON" : " • INFO"), text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 1, 6, macroText(dxyClose, dxyPct, dxyFresh), text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 0, 7, "CL" + (useCl ? " • ON" : " • INFO"), text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 1, 7, macroText(clClose, clPct, clFresh), text_color=ink, bgcolor=color.white, text_size=size.tiny)
        table.cell(panel, 0, 8, "SCORE", text_color=gold, bgcolor=ink, text_size=size.tiny)
        table.cell(panel, 1, 8, str.tostring(score) + " / ±" + str.tostring(requiredScore), text_color=color.white, bgcolor=ink, text_size=size.tiny)
    else
        table.clear(panel, 0, 0, 1, 8)

bool newLong = barstate.isconfirmed and bias == 1 and nz(bias[1]) != 1
bool newShort = barstate.isconfirmed and bias == -1 and nz(bias[1]) != -1
bool newNeutral = barstate.isconfirmed and bias == 0 and nz(bias[1]) != 0

plotshape(showSignals and newLong, title="Yield long bias", style=shape.labelup, location=location.belowbar, text="YIELD\nLONG", color=green, textcolor=color.white, size=size.tiny)
plotshape(showSignals and newShort, title="Yield short bias", style=shape.labeldown, location=location.abovebar, text="YIELD\nSHORT", color=red, textcolor=color.white, size=size.tiny)
barcolor(shadeBars and bias != 0 ? color.new(biasColor, 45) : na)

alertcondition(newLong, title="LH Macro Long Bias", message="LH NQ yield/macro bias changed LONG. Confirm with your price/liquidity model.")
alertcondition(newShort, title="LH Macro Short Bias", message="LH NQ yield/macro bias changed SHORT. Confirm with your price/liquidity model.")
alertcondition(newNeutral, title="LH Macro Neutral", message="LH NQ yield/macro bias changed NEUTRAL or quote became stale.")
````
