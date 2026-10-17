# Volume-Confirmed Order Blocks - CFD Charts

- url: https://www.tradingview.com/script/7nnMPqAf/
- type: indicator
- pine_id: PUB;18d224da9edf473f9850f95ad36ea359
- version: 1.0

## Description

Order-block zones for CFD and cash-index charts — kept only when the impulse
that created them carried above-average REAL futures volume.

What makes it original: classic order-block tools mark every last opposite
candle before a fast move, which paints charts full of untested zones. This
one validates the impulse against the exchange volume of the auto-detected
futures contract (never the CFD's tick volume): a zone only exists where real
contracts changed hands. Price coordinates stay this chart's prices — only the
volume is borrowed, so the futures-vs-cash basis cannot shift a zone.

How it works:
- Impulse = candle range > k x ATR with a decisive body (both adjustable).
- The last opposite candle within a few bars before the impulse becomes the
  order block; its high/low span the zone.
- Volume confirmation: the impulse candle needs >= x times the average
  futures volume (set the multiplier to 0 for classic, unfiltered blocks).
- Zones extend right until price closes through the far side (mitigation),
  then they are removed; the number of kept zones is capped.
- Label-free chart output — zones read from color and geometry alone. Alerts
  fire on new bullish/bearish zones.

How to use it: treat the zones as inventory areas of real participation —
pullbacks into a fresh volume-confirmed zone are the classic retest context,
a close through the far side invalidates it (and removes it from the chart).
The volume filter is the quality dial: raise the multiplier to keep only the
zones where the futures market genuinely committed. Delayed futures feeds
confirm new zones a few minutes late; history is complete.

*This script is part of a consistent set of open-source session, range and
volume tools — the companions are on my profile.*

## Source Code

````pine
//@version=6
// VOLUME-CONFIRMED ORDER BLOCKS — order-block zones on a CFD chart, validated
// by REAL futures contract volume. The chart's broker tick volume is NEVER
// used: the confirmation volume comes from the auto-detected futures contract
// (request.security). Price coordinates are this chart's (CFD) prices — only
// the volume is borrowed, so the futures-vs-cash basis cannot distort zones.
// Logic: impulse candle (range > k x ATR, decisive body) -> the LAST opposite
// candle before it is the order block; the zone is kept only if the impulse
// traded ABOVE-AVERAGE futures volume (real participation, not tick noise).
// Zone extends right until price trades through its far side (mitigation).
// Label-free by design: zones read from color/geometry (family convention).
// Sibling tools: futures_volume_delta / future_volume_profile / vwap / twap.
indicator("Volume-Confirmed Order Blocks — CFD Charts", shorttitle = "Fut OB", overlay = true, max_boxes_count = 100)

volMode  = input.string("Futures symbol", "Volume source",
     options = ["Chart (native)", "Futures symbol"], group = "Volume",
     tooltip = "Futures = real exchange volume via request.security. Chart = this chart's own volume (only sensible on a native futures chart).")
autoFut  = input.bool(true, "Auto-detect futures symbol", group = "Volume")
futMan   = input.symbol("EUREX:FDAX1!", "…manual otherwise", group = "Volume")

kATR     = input.float(1.5, "Impulse: range > k x ATR", step = 0.1, minval = 0.5, group = "Order blocks")
bodyMin  = input.float(0.5, "Impulse: min body/range", step = 0.05, minval = 0.0, maxval = 1.0, group = "Order blocks")
atrLen   = input.int(50, "ATR length", minval = 5, group = "Order blocks")
obSearch = input.int(3, "Max bars back to the opposite candle", minval = 1, maxval = 10, group = "Order blocks")
volMult  = input.float(1.5, "Volume confirm: impulse vol >= x * MA", step = 0.1, minval = 0.0, group = "Order blocks",
     tooltip = "The impulse candle must carry at least x times the average futures volume. 0 = volume filter off (classic order blocks).")
volMALen = input.int(50, "Volume MA length", minval = 1, group = "Order blocks")
maxBoxes = input.int(20, "Max zones kept", minval = 1, maxval = 50, group = "Order blocks")

bullCol = input.color(color.new(color.teal, 82), "Bullish zone", group = "Style")
bearCol = input.color(color.new(color.red, 82), "Bearish zone", group = "Style")

f_detectFut() =>
    s = str.lower(syminfo.ticker) + " " + str.lower(syminfo.prefix) + " " + str.lower(syminfo.description)
    isNQ  = str.contains(s, "nas") or str.contains(s, "ndx") or str.contains(s, "us100") or str.contains(s, "ustec") or str.contains(s, "tech100") or str.contains(s, "nq1") or str.contains(s, "nq!")
    isYM  = str.contains(s, "dow") or str.contains(s, "us30") or str.contains(s, "dji") or str.contains(s, "ym1") or str.contains(s, "ym!") or str.contains(s, "wall street")
    isDAX = str.contains(s, "dax") or str.contains(s, "ger40") or str.contains(s, "de40") or str.contains(s, "german")
    isFTSE = str.contains(s, "ftse") or str.contains(s, "uk100") or str.contains(s, "ukx")
    isES  = str.contains(s, "us500") or str.contains(s, "sp500") or str.contains(s, "spx") or str.contains(s, "s&p") or str.contains(s, "es1") or str.contains(s, "es!")
    isDAX ? "EUREX:FDAX1!" : isFTSE ? "ICEEUR:Z1!" : isNQ ? "CME_MINI:NQ1!" :
     isYM ? "CBOT_MINI:YM1!" : isES ? "CME_MINI:ES1!" : syminfo.tickerid

futSym = autoFut ? f_detectFut() : futMan
useFut = volMode == "Futures symbol"

futVol = request.security(futSym, timeframe.period, volume, ignore_invalid_symbol = true)
vol    = useFut ? futVol : volume
volMA  = ta.sma(nz(vol), volMALen)

// --- impulse detection (on confirmed bars only) ---
atr   = ta.atr(atrLen)
rng   = high - low
body  = math.abs(close - open)
isImp = barstate.isconfirmed and rng > kATR * atr and rng > 0 and body / rng >= bodyMin
impUp = isImp and close > open
impDn = isImp and close < open
volOK = volMult <= 0.0 or (nz(vol) >= volMult * volMA and volMA > 0)

var array<box> bullBoxes = array.new<box>()
var array<box> bearBoxes = array.new<box>()

f_lastOpposite(_up) =>
    // last opposite candle within obSearch bars BEFORE the impulse candle
    int found = -1
    for i = 1 to obSearch
        if _up and close[i] < open[i]
            found := i
            break
        if not _up and close[i] > open[i]
            found := i
            break
    found

if impUp and volOK
    i = f_lastOpposite(true)
    if i > 0
        b = box.new(bar_index - i, high[i], bar_index, low[i],
             border_color = color.new(color.teal, 55), bgcolor = bullCol,
             extend = extend.right)
        bullBoxes.push(b)
        if bullBoxes.size() > maxBoxes
            box.delete(bullBoxes.shift())

if impDn and volOK
    i = f_lastOpposite(false)
    if i > 0
        b = box.new(bar_index - i, high[i], bar_index, low[i],
             border_color = color.new(color.red, 55), bgcolor = bearCol,
             extend = extend.right)
        bearBoxes.push(b)
        if bearBoxes.size() > maxBoxes
            box.delete(bearBoxes.shift())

// --- mitigation: price trades through the far side -> zone removed ---
if barstate.isconfirmed and bullBoxes.size() > 0
    for j = bullBoxes.size() - 1 to 0
        bx = bullBoxes.get(j)
        if close < box.get_bottom(bx)
            box.delete(bx)
            bullBoxes.remove(j)
if barstate.isconfirmed and bearBoxes.size() > 0
    for j = bearBoxes.size() - 1 to 0
        bx = bearBoxes.get(j)
        if close > box.get_top(bx)
            box.delete(bx)
            bearBoxes.remove(j)

newBull = impUp and volOK
newBear = impDn and volOK
alertcondition(newBull, "New bullish order block", "Volume-confirmed bullish order block formed")
alertcondition(newBear, "New bearish order block", "Volume-confirmed bearish order block formed")

// --- status label ---
if barstate.islast
    txt = (useFut ? "Futures volume: " + futSym + (na(futVol) ? " (NO DATA - volume filter passes nothing)" : " ✓")
                  : "Chart volume (native)")
         + "\nZones: " + str.tostring(bullBoxes.size() + bearBoxes.size())
         + " active | impulse > " + str.tostring(kATR, "#.#") + "x ATR, vol >= "
         + str.tostring(volMult, "#.#") + "x MA"
    label.new(bar_index, close, txt, style = label.style_label_left,
         color = color.new(color.black, 20), textcolor = color.white, size = size.small)
````
