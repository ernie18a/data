# GoldAlgo DXY

- url: https://www.tradingview.com/script/WEqwb3YQ-GoldAlgo-DXY/
- type: indicator
- pine_id: PUB;c81b33f301554bc88602b83e1b14c9f0
- version: 1.0

## Description

GoldAlgo DXY puts the US Dollar Index in a panel under your Gold (XAUUSD) chart and translates it into one simple question: is the dollar a headwind or a tailwind for gold right now?

WHY THE DOLLAR

Gold is priced in dollars, so most of the time it trades inverse to the Dollar Index: a rising DXY pressures gold down, a falling DXY supports it. Watching the two side by side is one of the oldest edges in gold trading — this tool does it for you and reads the relationship out loud.

HOW IT WORKS

1. The dollar in a panel. DXY is plotted as candles (or a line) on your chart's own timeframe, with a trend EMA (default 50) over it.

2. The bias tint. The panel background shades softly red while the dollar trends above its EMA (headwind for gold) and softly green while it trends below (tailwind), so the bias is readable at a glance without studying the candles.

3. The correlation check. A rolling correlation between gold and DXY is tracked over a configurable lookback. On gold it normally sits deep negative; when it drifts toward zero the panel flags the relationship as broken — on those days, trust the dollar less.

ON-CHART DASHBOARD

A live panel shows the DXY price, today's percentage change, the dollar trend, the current gold/DXY correlation with a broken-relationship flag, and the resulting gold bias in plain words: headwind or tailwind.

ALERTS

Alert conditions for the dollar turning up (crossing above its EMA) and turning down (crossing below), so you catch the shifts in the gold backdrop from your phone.

SETTINGS

Dollar Index symbol, candles or line, trend EMA length, correlation lookback, bias tint on/off, and full color customization.

IMPORTANT

GoldAlgo DXY works only on Gold (XAUUSD). On any other symbol it displays a notice instead of drawings. This is an educational analysis tool: correlation is a tendency, not a rule — it does not predict the market and it is not financial advice. Always use proper risk management and never risk capital you cannot afford to lose.

## Source Code

````pine
//@version=6
indicator("GoldAlgo DXY", "GoldAlgo DXY", overlay = false, format = format.price, precision = 2)

string G_SRC = "Dollar Index"
string G_UI  = "Dashboard & Colors"

dxySym   = input.symbol("TVC:DXY", "Symbol", group = G_SRC, tooltip = "The US Dollar Index. Gold trades inverse to it most of the time — a rising DXY is the headwind, a falling DXY is the tailwind.")
plotAs   = input.string("Candles", "Plot as", options = ["Candles", "Line"], group = G_SRC)
emaLen   = input.int(50, "Trend EMA", minval = 5, group = G_SRC, tooltip = "DXY above the EMA = dollar uptrend = headwind for gold. Below = tailwind.")
corrLen  = input.int(100, "Correlation lookback (bars)", minval = 10, group = G_SRC, tooltip = "Rolling correlation between the chart symbol and DXY. On gold this normally sits deep negative; when it flips toward 0 the usual inverse relationship is broken — trust DXY less on those days.")
showBias = input.bool(true, "Tint panel with the gold bias", group = G_SRC)

showDash = input.bool(true, "Show dashboard", group = G_UI)
colUp    = input.color(#10A66E, "Bullish", group = G_UI, inline = "col")
colDn    = input.color(#D9414B, "Bearish", group = G_UI, inline = "col")
colGold  = input.color(#E8B33C, "Brand", group = G_UI, inline = "col")

bool isGold = str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")
var table warn = table.new(position.middle_center, 1, 1)
if not isGold and barstate.islast
    table.cell(warn, 0, 0, "  GoldAlgo DXY works only on Gold — open an XAUUSD chart  ", text_color = colGold, text_size = size.normal, bgcolor = #0E0C07)

[dO, dH, dL, dC] = request.security(dxySym, timeframe.period, [open, high, low, close])
float dEma     = request.security(dxySym, timeframe.period, ta.ema(close, emaLen))
float dPrevDay = request.security(dxySym, "D", close[1], lookahead = barmerge.lookahead_on)
float corr     = ta.correlation(close, dC, corrLen)

bool  dxyUp   = dC > dEma
float dayChg  = not na(dPrevDay) and dPrevDay != 0 ? (dC / dPrevDay - 1) * 100 : na
bool  candles = isGold and plotAs == "Candles"

color barCol = dC >= dO ? colUp : colDn
plotcandle(candles ? dO : na, candles ? dH : na, candles ? dL : na, candles ? dC : na, "DXY", color = color.new(barCol, 15), wickcolor = color.new(barCol, 40), bordercolor = color.new(barCol, 15))
plot(isGold and not candles ? dC : na, "DXY line", color = colGold, linewidth = 2)
plot(isGold ? dEma : na, "Trend EMA", color = color.new(colGold, 35), linewidth = 1)

// A rising dollar is a headwind for gold, a falling one a tailwind
bgcolor(isGold and showBias ? (dxyUp ? color.new(colDn, 96) : color.new(colUp, 96)) : na, title = "Gold bias tint")

alertcondition(isGold and ta.crossover(dC, dEma),  "GoldAlgo DXY — Dollar turned up",   "DXY crossed above its EMA — headwind for gold")
alertcondition(isGold and ta.crossunder(dC, dEma), "GoldAlgo DXY — Dollar turned down", "DXY crossed below its EMA — tailwind for gold")

bool corrBroken = not na(corr) and corr > -0.3
var table dash = table.new(position.bottom_right, 2, 7, bgcolor = #0E0C07, frame_width = 2, frame_color = color.new(#E8B33C, 25), border_width = 1, border_color = color.new(#E8B33C, 92))
if showDash and isGold and barstate.islast
    color lblCol = #CFC6B0
    table.cell(dash, 0, 0, "  GoldAlgo DXY  ", text_color = colGold, text_size = size.normal, bgcolor = #060502, text_halign = text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)
    table.cell(dash, 0, 1, "  DXY", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, str.tostring(dC, "0.00") + "  ", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 2, "  Today", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, (na(dayChg) ? "—" : (dayChg >= 0 ? "+" : "") + str.tostring(dayChg, "0.00") + "%") + "  ", text_color = na(dayChg) ? color.white : dayChg >= 0 ? colUp : colDn, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 3, "  Dollar trend (EMA " + str.tostring(emaLen) + ")", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, (dxyUp ? "▲ up" : "▼ down") + "  ", text_color = dxyUp ? colUp : colDn, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 4, "  Correlation (" + str.tostring(corrLen) + " bars)", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, (na(corr) ? "—" : str.tostring(corr, "0.00") + (corrBroken ? " — broken" : "")) + "  ", text_color = corrBroken ? colGold : color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 5, "  Gold bias", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, (dxyUp ? "Headwind — favor sells" : "Tailwind — favor buys") + "  ", text_color = dxyUp ? colDn : colUp, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 6, "  SGHK Softwares Limited  ", text_color = color.new(colGold, 20), text_size = size.tiny, text_halign = text.align_center)
    table.merge_cells(dash, 0, 6, 1, 6)
````
