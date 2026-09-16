<!-- tradingview-pine-id: PUB;ba07bfdef09e470399c86c51cba5c4ff -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Buy Signal Ema Macd Cross

Source: https://www.tradingview.com/script/DiwTgX5I-Buy-Signal-Ema-Macd-Cross/

## Description

Buy Signal Ema Macd Cross — Xcelerate Trade

All-in-one indicator for TradingView: multi-factor BUY confluence on the price chart + classic MACD (12, 26, 9) in a separate pane below.

WHAT YOU GET
• Price chart: MA14 (purple) and MA200 (red) — MA25/50/99 optional
• BUY labels when all confluence rules align (not on a single isolated MACD cross)
• Live Confluence table — MACD, Signal, Histogram, condition checks, active window
• Movable table — 9 screen positions (corners & centers)
• MACD pane: official TradingView-style histogram (4-tone momentum colors), MACD line, Signal line (orange), zero line

BUY SIGNAL LOGIC
A BUY fires only when these align within the Confluence window (default: 8 bars):

1. MACD crosses above Signal (bullish cross)
2. Close above MA14 and MA200
3. Price recently crossed above MA200 (within window)
4. MA14 recently crossed above MA200 (within window)
5. Cooldown: minimum 12 bars between BUY labels (anti-spam)

Optional (default OFF): BUY only when MACD is below zero — cross and signal must occur under the zero line (classic recovery-from-oversold setup).

Analysis limited to the last 500 bars on chart load.

KEY SETTINGS
• Moving averages: show/hide MA14, MA25, MA50, MA99, MA200
• MACD: 12 / 26 / 9, EMA oscillator & signal
• Confluence window & cooldown — tune for your timeframe and volatility
• Display: BUY label color, confluence table on/off, table position

ALERTS
• BUY confluence (all conditions met)
• MACD crosses above / below Signal
• MACD histogram rising→falling / falling→rising

WHO IT'S FOR
Traders who want filtered BUY entries combining trend (MA200), short-term momentum (MA14), and MACD confirmation — intraday and swing on forex, gold, crypto, indices. Always validate on demo and adjust window/cooldown for your market.

DISCLAIMER
Technical analysis tool only — not financial advice. Past signals do not guarantee future results. Trade at your own risk.

---

## Source Code

````pine
//@version=6
// Buy Signal Ema Macd Cross — MA14/MA200 confluence BUY + official TV MACD pane below chart.
// overlay=false → MACD in its own pane; MAs/BUY use force_overlay on the price chart.
indicator("Buy Signal Ema Macd Cross", shorttitle = "Buy Signal", overlay = false, max_labels_count = 500)

grpMa = "Moving averages (SMA)"
ma14Len = input.int(14, "MA14", minval = 1, maxval = 500, group = grpMa)
ma25Len = input.int(25, "MA25", minval = 1, maxval = 500, group = grpMa)
ma50Len = input.int(50, "MA50", minval = 1, maxval = 500, group = grpMa)
ma99Len = input.int(99, "MA99", minval = 1, maxval = 500, group = grpMa)
ma200Len = input.int(200, "MA200", minval = 1, maxval = 500, group = grpMa)
showMa14 = input.bool(true, "Show MA14", group = grpMa)
showMa25 = input.bool(false, "Show MA25", group = grpMa)
showMa50 = input.bool(false, "Show MA50", group = grpMa)
showMa99 = input.bool(false, "Show MA99", group = grpMa)
showMa200 = input.bool(true, "Show MA200", group = grpMa)

grpMacd = "MACD"
sourceInput = input.source(close, "Source", group = grpMacd)
fastLenInput = input.int(12, "Fast length", minval = 1, group = grpMacd)
slowLenInput = input.int(26, "Slow length", minval = 1, group = grpMacd)
sigLenInput = input.int(9, "Signal length", minval = 1, group = grpMacd)
oscTypeInput = input.string("EMA", "Oscillator MA type", ["EMA", "SMA"], display = display.none, group = grpMacd)
sigTypeInput = input.string("EMA", "Signal MA type", ["EMA", "SMA"], display = display.none, group = grpMacd)
showMacdPane = input.bool(true, "Show MACD pane below chart", group = grpMacd)
requireMacdCross = input.bool(true, "BUY: require MACD cross above Signal", group = grpMacd)
requireMacdBelowZero = input.bool(false, "BUY: only when MACD below zero", group = grpMacd)
colorBarsMacd = input.bool(false, "Tint candles by MACD histogram", group = grpMacd)

signalColor = #ff6d00

ma(float source, int length, simple string maType) =>
    switch maType
        "EMA" => ta.ema(source, length)
        "SMA" => ta.sma(source, length)

grpConf = "BUY confluence"
requirePriceCrossMa200 = input.bool(true, "Require price cross above MA200", group = grpConf)
requireMa14CrossMa200 = input.bool(true, "Require MA14 cross above MA200", group = grpConf)
requirePriceAboveMa14 = input.bool(true, "Require close above MA14", group = grpConf)
confluenceWindow = input.int(8, "Confluence window (bars)", minval = 1, maxval = 50, group = grpConf)
cooldownBars = input.int(12, "Cooldown after BUY (bars)", minval = 0, maxval = 200, group = grpConf)
analysisLookback = input.int(500, "Max history (bars from right)", minval = 50, maxval = 5000, group = grpConf)

grpDisp = "Display"
showBuyLabel = input.bool(true, "Show BUY label", group = grpDisp)
showInfoTable = input.bool(true, "Show confluence table", group = grpDisp)
tablePositionInput = input.string("Top Right", "Confluence table position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpDisp)
buyLabelColor = input.color(color.new(color.teal, 10), "BUY label", group = grpDisp)

tablePos = switch tablePositionInput
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Top Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right" => position.bottom_right
    => position.top_right

ma14 = ta.sma(close, ma14Len)
ma25 = ta.sma(close, ma25Len)
ma50 = ta.sma(close, ma50Len)
ma99 = ta.sma(close, ma99Len)
ma200 = ta.sma(close, ma200Len)

maFast = ma(sourceInput, fastLenInput, oscTypeInput)
maSlow = ma(sourceInput, slowLenInput, oscTypeInput)
macd = maFast - maSlow
signal = ma(macd, sigLenInput, sigTypeInput)
hist = macd - signal
hColor = hist >= 0 ? hist > hist[1] ? #26a69a : #b2dfdb : hist > hist[1] ? #ffcdd2 : #ff5252

macdBullCross = ta.crossover(macd, signal)
macdBearCross = ta.crossunder(macd, signal)
macdBullCrossOk = macdBullCross and (not requireMacdBelowZero or (macd < 0 and signal < 0))
macdBullState = macd > signal
macdBelowZeroOk = not requireMacdBelowZero or macd < 0

priceCrossMa200 = ta.crossover(close, ma200)
priceAboveMa200 = close > ma200
ma14CrossMa200 = ta.crossover(ma14, ma200)
ma14AboveMa200 = ma14 > ma200
priceAboveBoth = close > ma14 and close > ma200

barsSinceMacdCross = ta.barssince(macdBullCrossOk)
barsSinceMa14x200 = ta.barssince(ma14CrossMa200)
barsSincePriceMa200 = ta.barssince(priceCrossMa200)

macdOk = requireMacdCross ? (not na(barsSinceMacdCross) and barsSinceMacdCross <= confluenceWindow) : macdBullState
ma14x200Ok = requireMa14CrossMa200 ? (not na(barsSinceMa14x200) and barsSinceMa14x200 <= confluenceWindow) : ma14AboveMa200
priceMa200Ok = requirePriceCrossMa200 ? (not na(barsSincePriceMa200) and barsSincePriceMa200 <= confluenceWindow) : priceAboveMa200
priceMa14Ok = not requirePriceAboveMa14 or close > ma14
inAnalysis = last_bar_index - bar_index < analysisLookback

buyConfluence = inAnalysis and macdOk and macdBelowZeroOk and ma14x200Ok and priceMa200Ok and priceMa14Ok and priceAboveBoth

var int lastBuyBar = na
canBuy = na(lastBuyBar) or bar_index - lastBuyBar > cooldownBars
buySignal = buyConfluence and canBuy
if buySignal
    lastBuyBar := bar_index

showSitePromo = true
promoIntervalMin = 7
promoHighlightSec = 30
promoMsg = "For more indicators & strategies\nvisit trading.xcelerate.trade"
promoIntervalMs = promoIntervalMin * 60 * 1000
promoVisibleMs = promoHighlightSec * 1000
var table sitePromoTbl = na
varip int promoHiddenAnchorMs = -1
varip int promoVisibleAnchorMs = -1
if showSitePromo and barstate.islast
    if na(sitePromoTbl)
        sitePromoTbl := table.new(position.middle_center, 1, 1, border_width = 0, frame_color = color.new(color.black, 100), bgcolor = color.new(color.black, 100), force_overlay = true)
    nowMs = na(timenow) ? time_close : timenow
    if promoHiddenAnchorMs < 0 and promoVisibleAnchorMs < 0
        promoHiddenAnchorMs := nowMs
    if promoVisibleAnchorMs >= 0
        if nowMs - promoVisibleAnchorMs >= promoVisibleMs
            promoHiddenAnchorMs := nowMs
            promoVisibleAnchorMs := -1
    else if promoHiddenAnchorMs >= 0 and nowMs - promoHiddenAnchorMs >= promoIntervalMs
        promoVisibleAnchorMs := nowMs
    showPromoNow = promoVisibleAnchorMs >= 0 and nowMs - promoVisibleAnchorMs < promoVisibleMs
    if showPromoNow
        table.cell(sitePromoTbl, 0, 0, promoMsg, text_color = color.white, text_size = size.large, bgcolor = color.new(color.black, 25), text_halign = text.align_center)
    else
        table.cell(sitePromoTbl, 0, 0, "", bgcolor = color.new(color.black, 100), text_color = color.new(color.white, 100), text_size = size.large)

hline(0, "Zero", #787b8680, display = showMacdPane ? display.all : display.none)
plot(showMacdPane ? hist : na, "Histogram", hColor, style = plot.style_columns)
plot(showMacdPane ? macd : na, "MACD")
plot(showMacdPane ? signal : na, "Signal line", signalColor)

plot(showMa14 ? ma14 : na, "MA14", color = color.new(#9B59B6, 0), linewidth = 1, force_overlay = true)
plot(showMa25 ? ma25 : na, "MA25", color = color.new(color.orange, 0), linewidth = 1, force_overlay = true)
plot(showMa50 ? ma50 : na, "MA50", color = color.new(color.lime, 0), linewidth = 1, force_overlay = true)
plot(showMa99 ? ma99 : na, "MA99", color = color.new(color.blue, 0), linewidth = 1, force_overlay = true)
plot(showMa200 ? ma200 : na, "MA200", color = color.new(color.red, 0), linewidth = 2, force_overlay = true)

barcolor(colorBarsMacd ? color.new(hColor, 78) : na, title = "MACD hist tint")

plotshape(showBuyLabel and buySignal, title = "BUY", style = shape.labelup, location = location.belowbar, text = "BUY", color = buyLabelColor, textcolor = color.white, size = size.normal, force_overlay = true)

var table info = table.new(position.top_right, 2, 9, border_width = 1, bgcolor = color.new(color.black, 85), force_overlay = true)

if barstate.islast
    table.set_position(info, tablePos)
    if showInfoTable
        table.cell(info, 0, 0, "Confluence", text_color = color.white, bgcolor = color.new(color.navy, 0))
        table.cell(info, 1, 0, buyConfluence ? "READY" : "—", text_color = buyConfluence ? color.lime : color.silver, bgcolor = color.new(color.navy, 0))
        table.cell(info, 0, 1, "MACD", text_color = color.white)
        table.cell(info, 1, 1, str.tostring(macd, "#.##"), text_color = color.blue)
        table.cell(info, 0, 2, "Signal", text_color = color.white)
        table.cell(info, 1, 2, str.tostring(signal, "#.##"), text_color = signalColor)
        table.cell(info, 0, 3, "Histogram", text_color = color.white)
        table.cell(info, 1, 3, str.tostring(hist, "#.##"), text_color = hist >= 0 ? color.lime : color.red)
        table.cell(info, 0, 4, "MACD > Signal", text_color = color.white)
        table.cell(info, 1, 4, macdOk ? "yes" : "no", text_color = macdOk ? color.lime : color.silver)
        table.cell(info, 0, 5, "MACD < 0", text_color = color.white)
        table.cell(info, 1, 5, macdBelowZeroOk ? "yes" : "no", text_color = macdBelowZeroOk ? color.lime : color.silver)
        table.cell(info, 0, 6, "MA14 > MA200", text_color = color.white)
        table.cell(info, 1, 6, ma14AboveMa200 ? "yes" : "no", text_color = ma14AboveMa200 ? color.lime : color.silver)
        table.cell(info, 0, 7, "Close > MA200", text_color = color.white)
        table.cell(info, 1, 7, priceAboveMa200 ? "yes" : "no", text_color = priceAboveMa200 ? color.lime : color.silver)
        table.cell(info, 0, 8, "Window", text_color = color.white)
        table.cell(info, 1, 8, str.tostring(confluenceWindow) + " bars", text_color = color.silver)
    else
        table.clear(info, 0, 0, 1, 8)

alertcondition(buySignal, title = "BUY confluence", message = "Buy Signal Ema Macd Cross: BUY on {{ticker}} {{interval}}")
alertcondition(macdBullCross, title = "MACD crosses above Signal", message = "Buy Signal Ema Macd Cross: MACD > Signal on {{ticker}} {{interval}}")
alertcondition(macdBearCross, title = "MACD crosses below Signal", message = "Buy Signal Ema Macd Cross: MACD < Signal on {{ticker}} {{interval}}")
alertcondition(hist[1] >= 0 and hist < 0, "Rising to falling", "MACD histogram switched from a rising to falling state")
alertcondition(hist[1] <= 0 and hist > 0, "Falling to rising", "MACD histogram switched from a falling to rising state")
````
