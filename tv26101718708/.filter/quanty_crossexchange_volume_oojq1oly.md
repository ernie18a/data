# Quanty | Cross-Exchange Volume

- url: https://www.tradingview.com/script/OOjQ1OlY-Quanty-Cross-Exchange-Volume/
- type: indicator
- pine_id: PUB;f535d61f3a6f44c3bfebe594ce1f2aec
- version: 1.0

## Description

Most volume indicators read one exchange. For a crypto perpetual that is only part of the flow: the same candle can look ordinary on the venue you happen to be charting and extreme once every venue is counted. This script aggregates perpetual volume across Binance, OKX and Bybit and measures the current candle against its own recent baseline.

HOW IT IS CALCULATED

Each venue's volume is converted to quote currency and summed. That aggregate is divided by its own average over the previous N days of the chart timeframe.

The current candle is excluded from its own baseline, so a large candle cannot lift the average it is being compared against.

The baseline window follows the chart timeframe, so 14 days means 84 bars on a 4-hour chart and 14 bars on a daily chart. On very low timeframes the window is capped at 2000 bars. The panel reports the window actually used, so a reading is never quietly based on less history than the setting implies.

READING IT

The histogram is the ratio, not raw volume, so it is scale-free: a large-cap and a newly listed asset can be read on the same axis. Dotted lines mark the three intensity thresholds.

The panel shows each venue's raw volume and its own ratio, then a breadth line. Breadth is the part a single-exchange tool cannot give you. A spike confirmed on every venue is market-wide participation. A spike on one venue while the others sit near 1x is venue-specific, and deserves more scepticism: a listing, an incentive programme, or a single participant will all look identical to a volume reading taken from that one venue.

A WORD ON VOLUME UNITS

Venues do not agree on what the volume field contains. Binance and Bybit perpetual volume arrives in the base asset; OKX perpetual volume arrives already in quote currency. Multiplying an already-quoted figure by price counts the price twice and inflates that venue by roughly the asset price. On a BTC candle this produced 12,985B for OKX against 294M for Binance before it was corrected.

Each venue therefore has a quote switch, set correctly by default. The Volume column shows raw figures rather than percentages precisely so that a mismatch is visible: every venue should land in the same order of magnitude. A percentage would normalise the error and hide it.

NOTES AND LIMITATIONS

Volume is not direction. Unusual volume precedes falls as often as rises. This measures participation, not intent, and no threshold here is a signal to buy or sell.

Readings are taken on closed candles by default. The panel always reports the last closed bar, because on a forming candle the charted venue updates tick by tick while requested venues lag, which distorts every share.

The symbol suffix must match the instrument: USDT.P for perpetuals, USDT for spot. Venues where the asset is not listed are left out of the sum rather than counted as zero, and if no venue resolves the panel says so instead of showing a blank reading.

Venue prefixes are inputs. A wrong one fails quietly by contributing less volume, so check the Volume column before trusting the numbers.

## Source Code

````pine
//@version=6
indicator("Quanty | Cross-Exchange Volume", shorttitle="Quanty XVOL", overlay=false, precision=2, max_bars_back=5000)

// Aggregates perpetual volume across several venues and measures the current
// candle against its own recent baseline. A single venue shows only part of the
// flow; the same move can look ordinary on one exchange and extreme across all.
//
// Volume is converted to quote currency (volume * close) before summing, because
// venues report base-currency volume and raw base units are not additive across
// different prices.

const string GROUP_VENUES = "1. Venues"
const string GROUP_BASE = "2. Baseline"
const string GROUP_TIERS = "3. Intensity tiers"
const string GROUP_STYLE = "4. Appearance"

// Exchange prefixes are inputs because venue symbology differs and a wrong one
// fails quietly: the venue simply contributes less volume and skews every share.
// Verify each symbol in the panel before trusting the numbers.
string venueSuffix = input.string("USDT.P", "Symbol suffix", options = ["USDT.P", "USDT", "USD.P"], tooltip = "Perpetuals end in .P on TradingView. Use USDT for spot pairs.", group = GROUP_VENUES)
string quoteHint = "Tick this when the venue already reports volume in quote currency. Leave it off when volume is in the base asset. Check the Volume column: every venue should land in the same order of magnitude."
bool useBinance = input.bool(true, "Binance", inline = "b", group = GROUP_VENUES)
string prefixBinance = input.string("BINANCE", "", inline = "b", group = GROUP_VENUES)
bool binanceInQuote = input.bool(false, "quote", inline = "b", tooltip = quoteHint, group = GROUP_VENUES)
bool useOkx = input.bool(true, "OKX", inline = "o", group = GROUP_VENUES)
string prefixOkx = input.string("OKX", "", inline = "o", group = GROUP_VENUES)
bool okxInQuote = input.bool(true, "quote", inline = "o", tooltip = quoteHint, group = GROUP_VENUES)
bool useBybit = input.bool(true, "Bybit", inline = "y", group = GROUP_VENUES)
string prefixBybit = input.string("BYBIT", "", inline = "y", group = GROUP_VENUES)
bool bybitInQuote = input.bool(false, "quote", inline = "y", tooltip = quoteHint, group = GROUP_VENUES)

float baselineDays = input.float(14.0, "Baseline (days)", minval = 1.0, maxval = 60.0, step = 1.0, tooltip = "The average is taken over this many days of the chart timeframe, excluding the current candle.", group = GROUP_BASE)
bool confirmedOnly = input.bool(true, "Confirmed candles only", tooltip = "When off, the live candle is measured before it closes and its reading keeps changing.", group = GROUP_BASE)

float tierExtreme = input.float(10.0, "Extreme", minval = 1.0, step = 0.5, group = GROUP_TIERS)
float tierHigh = input.float(5.0, "High", minval = 1.0, step = 0.5, group = GROUP_TIERS)
float tierElevated = input.float(3.0, "Elevated", minval = 1.0, step = 0.5, group = GROUP_TIERS)

color colExtreme = input.color(color.rgb(224, 87, 107), "Extreme", group = GROUP_STYLE)
color colHigh = input.color(color.rgb(232, 118, 47), "High", group = GROUP_STYLE)
color colElevated = input.color(color.rgb(232, 163, 61), "Elevated", group = GROUP_STYLE)
color colNormal = input.color(color.rgb(53, 71, 94), "Normal", group = GROUP_STYLE)
bool showPanel = input.bool(true, "Show venue panel", group = GROUP_STYLE)

// Quote-currency volume for one venue. An unlisted symbol returns na and is
// simply left out of the sum instead of being counted as zero.
// Venues do not agree on volume units. TradingView reports Binance and Bybit
// perpetual volume in the BASE asset, but OKX perpetual volume already in QUOTE
// currency. Multiplying an already-quoted figure by close counts the price twice
// and inflates that venue by roughly the asset price, which is why OKX once read
// 12,985B against Binance's 294M on the same BTC candle.
venueQuoteVolume(simple string sym, simple bool alreadyQuote) =>
    [venueVolume, venueClose] = request.security(sym, timeframe.period, [volume, close], ignore_invalid_symbol = true)
    na(venueVolume) ? na : alreadyQuote ? venueVolume : na(venueClose) ? na : venueVolume * venueClose

string symBinance = prefixBinance + ":" + syminfo.basecurrency + venueSuffix
string symOkx = prefixOkx + ":" + syminfo.basecurrency + venueSuffix
string symBybit = prefixBybit + ":" + syminfo.basecurrency + venueSuffix
float binanceVolume = venueQuoteVolume(symBinance, binanceInQuote)
float okxVolume = venueQuoteVolume(symOkx, okxInQuote)
float bybitVolume = venueQuoteVolume(symBybit, bybitInQuote)

float venueSum = 0.0
int venueCount = 0
if useBinance and not na(binanceVolume)
    venueSum += binanceVolume
    venueCount += 1
if useOkx and not na(okxVolume)
    venueSum += okxVolume
    venueCount += 1
if useBybit and not na(bybitVolume)
    venueSum += bybitVolume
    venueCount += 1
float aggregate = venueCount > 0 ? venueSum : na

// Baseline length follows the chart timeframe so the window is always the same
// number of days. Capped so very low timeframes stay inside the history limit.
// On very low timeframes 14 days is more bars than the script may look back, so
// the window is capped. The panel reports the window ACTUALLY used, because a
// baseline silently shorter than the setting would misrepresent every reading.
simple int baselineBars = math.max(5, math.min(2000, int(math.round(baselineDays * 86400.0 / timeframe.in_seconds(timeframe.period)))))
simple float effectiveDays = baselineBars * timeframe.in_seconds(timeframe.period) / 86400.0
simple bool baselineCapped = effectiveDays < baselineDays - 0.01

// The current candle is excluded from its own baseline.
float baseline = ta.sma(aggregate[1], baselineBars)
bool timeReady = not confirmedOnly or barstate.isconfirmed
float ratio = timeReady and not na(baseline) and baseline > 0.0 and not na(aggregate) ? aggregate / baseline : na

// Pine only accepts function declarations at global scope, never inside a block.
venueShare(float venueVolume, bool enabled, float total) =>
    not enabled or na(venueVolume) or na(total) or total <= 0.0 ? "-" : str.tostring(100.0 * venueVolume / total, "#.#") + "%"

// Raw quote volume, so a unit mismatch between venues becomes visible instead of
// hiding inside a percentage. A venue reporting contracts instead of base units
// shows up here as a number orders of magnitude away from its neighbours.
venueRawText(float venueVolume, bool enabled) =>
    if not enabled or na(venueVolume)
        "-"
    else if venueVolume >= 1e9
        str.tostring(venueVolume / 1e9, "#.##") + "B"
    else if venueVolume >= 1e6
        str.tostring(venueVolume / 1e6, "#.##") + "M"
    else if venueVolume >= 1e3
        str.tostring(venueVolume / 1e3, "#.##") + "K"
    else
        str.tostring(venueVolume, "#.##")

venueRatio(float venueVolume, simple int bars) =>
    float venueBaseline = ta.sma(venueVolume[1], bars)
    na(venueBaseline) or venueBaseline <= 0.0 or na(venueVolume) ? na : venueVolume / venueBaseline

venueRatioText(float value, bool enabled) =>
    not enabled or na(value) ? "-" : str.tostring(value, "#.#") + "x"

color tierColor = na(ratio) ? colNormal : ratio >= tierExtreme ? colExtreme : ratio >= tierHigh ? colHigh : ratio >= tierElevated ? colElevated : colNormal

plot(ratio, title = "Volume ratio", style = plot.style_columns, color = tierColor)
hline(tierExtreme, "Extreme", color = color.new(color.gray, 55), linestyle = hline.style_dotted)
hline(tierHigh, "High", color = color.new(color.gray, 70), linestyle = hline.style_dotted)
hline(tierElevated, "Elevated", color = color.new(color.gray, 80), linestyle = hline.style_dotted)

// Each venue is also measured against its OWN baseline. A spike confirmed on
// every venue is market-wide interest; a spike on one venue while the others
// sit near 1x is venue-specific and far less trustworthy. This breadth read is
// the thing a single-exchange indicator cannot give you.
float binanceRatio = venueRatio(binanceVolume, baselineBars)
float okxRatio = venueRatio(okxVolume, baselineBars)
float bybitRatio = venueRatio(bybitVolume, baselineBars)

// The panel must read the last CLOSED bar. On the live bar the chart's own venue
// updates tick by tick while requested venues lag, which skews every share and
// makes all ratios look tiny because the candle is only part-formed.
var float shownBinanceVolume = na
var float shownOkxVolume = na
var float shownBybitVolume = na
var float shownAggregate = na
var float shownBinanceRatio = na
var float shownOkxRatio = na
var float shownBybitRatio = na
if barstate.isconfirmed
    shownBinanceVolume := binanceVolume
    shownOkxVolume := okxVolume
    shownBybitVolume := bybitVolume
    shownAggregate := aggregate
    shownBinanceRatio := binanceRatio
    shownOkxRatio := okxRatio
    shownBybitRatio := bybitRatio

int confirming = 0
int participating = 0
if useBinance and not na(shownBinanceRatio)
    participating += 1
    confirming += shownBinanceRatio >= tierElevated ? 1 : 0
if useOkx and not na(shownOkxRatio)
    participating += 1
    confirming += shownOkxRatio >= tierElevated ? 1 : 0
if useBybit and not na(shownBybitRatio)
    participating += 1
    confirming += shownBybitRatio >= tierElevated ? 1 : 0
bool broad = participating > 1 and confirming == participating
bool concentrated = confirming == 1 and participating > 1

var table venuePanel = table.new(position.top_right, 3, 7, border_width = 1)
if showPanel and barstate.islast
    table.cell(venuePanel, 0, 0, "Venue", text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 1, 0, "Volume", text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 2, 0, "Ratio", text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 0, 5, "Baseline", text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 1, 5, str.tostring(baselineBars) + " bars", text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 2, 5, str.tostring(effectiveDays, "#.#") + "d", text_size = size.tiny, text_color = baselineCapped ? colHigh : color.gray)
    table.cell(venuePanel, 0, 6, participating == 0 ? "no venue data" : "closed bar", text_size = size.tiny, text_color = participating == 0 ? colHigh : color.new(color.gray, 40))
    table.cell(venuePanel, 0, 1, "Binance", text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 1, 1, venueRawText(shownBinanceVolume, useBinance), text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 2, 1, venueRatioText(shownBinanceRatio, useBinance), text_size = size.tiny, text_color = useBinance and not na(shownBinanceRatio) and shownBinanceRatio >= tierElevated ? colElevated : color.gray)
    table.cell(venuePanel, 0, 2, "OKX", text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 1, 2, venueRawText(shownOkxVolume, useOkx), text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 2, 2, venueRatioText(shownOkxRatio, useOkx), text_size = size.tiny, text_color = useOkx and not na(shownOkxRatio) and shownOkxRatio >= tierElevated ? colElevated : color.gray)
    table.cell(venuePanel, 0, 3, "Bybit", text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 1, 3, venueRawText(shownBybitVolume, useBybit), text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 2, 3, venueRatioText(shownBybitRatio, useBybit), text_size = size.tiny, text_color = useBybit and not na(shownBybitRatio) and shownBybitRatio >= tierElevated ? colElevated : color.gray)
    table.cell(venuePanel, 0, 4, "Breadth", text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 1, 4, str.tostring(confirming) + "/" + str.tostring(participating), text_size = size.tiny, text_color = color.gray)
    table.cell(venuePanel, 2, 4, broad ? "broad" : concentrated ? "one venue" : "-", text_size = size.tiny, text_color = broad ? colElevated : concentrated ? colHigh : color.gray)

bool extremeHit = not na(ratio) and ratio >= tierExtreme
bool highHit = not na(ratio) and ratio >= tierHigh and ratio < tierExtreme
alertcondition(extremeHit, "Quanty XVOL extreme", "{{ticker}} {{interval}}: extreme cross-exchange volume. Close: {{close}}")
alertcondition(highHit, "Quanty XVOL high", "{{ticker}} {{interval}}: high cross-exchange volume. Close: {{close}}")
alertcondition(extremeHit and broad, "Quanty XVOL extreme and broad", "{{ticker}} {{interval}}: extreme volume confirmed on every venue. Close: {{close}}")
````
