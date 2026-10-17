# DTC Lot Size Calculator

- url: https://www.tradingview.com/script/WVQ1Qwpj-DTC-Lot-Size-Calculator/
- type: indicator
- pine_id: PUB;9d24f03abb1f4b3d859e6259e5d98877
- version: 2.0

## Description

You set an Entry Price and Stop Price (click-to-place on the chart, or type them in). The script works backward from your risk percentage to tell you exactly how large a position you can take — lot size for forex/CFDs, or whole contracts for futures — so that a stop-out costs exactly what you intended to risk, not more.

It plots Entry, Stop, and R-multiple target lines (1R, 2R, 3R...) directly on the chart, and a compact table shows the full breakdown: risk amount, position size, commission, spread cost, required margin, and the resulting reward:risk ratio.

How the sizing works

Position size is solved from your planned Entry/Stop distance, not a live-recalculated one, so the lot size stays stable and doesn't silently drift every time price ticks. An optional "Reset entry to live price" toggle lets Entry track the current close while Stop stays fixed, so you can watch how a live-tracking price affects real risk without re-plotting manually every time.

True Risk (not just the target risk %) accounts for commission and spread cost, so the number you see is what you'd actually lose, not an idealized figure.

Futures contracts (ES, MES, NQ, MNQ, YM, MYM, RTY, M2K, CL, MCL, NG, GC, MGC, SI, HG, ZB, ZN, ZF, 6E, 6J, 6B, 6A, ZC, ZS, ZW, and CME BTC/ETH) use their real exchange tick size and tick value, and size in whole contracts only, no fractional micros. Spot metals (XAUUSD, XAGUSD, XPTUSD, XPDUSD) use standard 100oz/5000oz/50oz lot conventions matching their COMEX futures equivalents, since these are commonly mispriced by generic calculators.

Built-in safety checks

Risk % turns red with a caution mark above a threshold you set (default 3%). Stop distance turns red with a caution mark if it's unusually wide for a forex pair (default 15 pips). Margin % estimates how much of your account the position would tie up at your configured leverage, and warns if it exceeds 100%, catching cases where a risk-correct position size is still too large for the account to actually hold. A second, independently configurable account/risk table can be shown side by side for comparing two account sizes or risk profiles at once.

Why this is a distinct build, not a re-skin

The original by cryptonnnite was a single-instrument forex lot size calculator. This version adds: multi-asset contract specs (futures + metals), the planned-vs-live entry distinction and its safety fallback, commission+spread-inclusive true risk, the margin/leverage check, configurable warning thresholds, a second comparison account, and the auto dark/light theme system, all new logic layered on top of the original risk-sizing concept.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Enhanced Forex Lot Size Calculator
// Based on original by cryptonnnite

//@version=6
indicator('DTC Lot Size', max_bars_back = 100, overlay = true, linktoseries = true, scale = scale.none, precision = 5, format = format.price)

// =============================================================================
// === UTILITY FUNCTIONS ===
// =============================================================================

toString(x) =>
    str.tostring(x)
numberToLotSizeFormat(size) =>
    str.format('{0,number,#.##}', size)
roundPrice(price) =>
    math.round(price, 5)

// Known futures contracts: tick size and tick value (USD) per the CME/CBOT/COMEX/NYMEX
// specs. tick value = tick size × point value for all of these, so storing tick value
// directly lets us derive an equivalent "point value" for getContractSize() below
// without touching the rest of the cash-flow math.
f_futuresTickSize(string root) =>
    switch root
        'ES' => 0.25
        'MES' => 0.25
        'NQ' => 0.25
        'MNQ' => 0.25
        'YM' => 1.0
        'MYM' => 1.0
        'RTY' => 0.1
        'M2K' => 0.1
        'CL' => 0.01
        'MCL' => 0.01
        'NG' => 0.001
        'GC' => 0.1
        'MGC' => 0.1
        'SI' => 0.005
        'HG' => 0.0005
        'ZB' => 0.03125
        'ZN' => 0.015625
        'ZF' => 0.0078125
        '6E' => 0.00005
        '6J' => 0.0000005
        '6B' => 0.0001
        '6A' => 0.0001
        'ZC' => 0.25
        'ZS' => 0.25
        'ZW' => 0.25
        'BTC' => 5.0
        'MBT' => 5.0
        'ETH' => 0.25
        => na

f_futuresTickValue(string root) =>
    switch root
        'ES' => 12.5
        'MES' => 1.25
        'NQ' => 5.0
        'MNQ' => 0.5
        'YM' => 5.0
        'MYM' => 0.5
        'RTY' => 5.0
        'M2K' => 0.5
        'CL' => 10.0
        'MCL' => 1.0
        'NG' => 10.0
        'GC' => 10.0
        'MGC' => 1.0
        'SI' => 25.0
        'HG' => 12.5
        'ZB' => 31.25
        'ZN' => 15.625
        'ZF' => 7.8125
        '6E' => 6.25
        '6J' => 6.25
        '6B' => 6.25
        '6A' => 10.0
        'ZC' => 12.5
        'ZS' => 12.5
        'ZW' => 12.5
        'BTC' => 25.0
        'MBT' => 0.5
        'ETH' => 12.5
        => na

getContractSize() =>
    ticker = str.upper(syminfo.ticker)
    root = str.upper(syminfo.root)
    futTickSize = f_futuresTickSize(root)
    futTickValue = f_futuresTickValue(root)
    isKnownFutures = not na(futTickSize) and not na(futTickValue)
    isSPX500 = str.contains(ticker, 'SPX500') or str.contains(ticker, 'US500') or str.contains(ticker, 'SP500')
    isNDX100 = str.contains(ticker, 'NDX100') or str.contains(ticker, 'NAS100') or str.contains(ticker, 'US100') or str.contains(ticker, 'USTEC')
    // Spot metal CFDs (e.g. OANDA:XAUUSD) often report neither type=='forex' nor a usable
    // syminfo.pointvalue, which was silently falling through to a contractSize of 1.0 —
    // treating a $1 gold move as a $1 lot move instead of the standard 100oz lot. These
    // standard lot sizes match the equivalent COMEX futures (GC=100oz, SI=5000oz).
    isXAUUSD = str.contains(ticker, 'XAUUSD') or ticker == 'GOLD'
    isXAGUSD = str.contains(ticker, 'XAGUSD') or ticker == 'SILVER'
    isXPTUSD = str.contains(ticker, 'XPTUSD')
    isXPDUSD = str.contains(ticker, 'XPDUSD')
    isKnownFutures ? futTickValue / futTickSize : isXAUUSD ? 100.0 : isXAGUSD ? 5000.0 : isXPTUSD ? 50.0 : isXPDUSD ? 100.0 : isSPX500 ? 50.0 : isNDX100 ? 20.0 : syminfo.type == 'forex' ? 100000.0 : syminfo.pointvalue > 0 ? syminfo.pointvalue : 1.0

getCashPerLotForMove(priceMove, contractSize) =>
    syminfo.type == 'forex' ? priceMove / syminfo.mintick : priceMove * contractSize

// R-level helper: pure R distance based only on stop size (no commission)
getTicksForNR(stopLossTickSize, rCount) =>
    stopLossTickSize * rCount

getPriceForNR(entryPrice, stopLossPrice, ticks, mintick) =>
    roundPrice(entryPrice > stopLossPrice ? entryPrice + ticks * mintick : entryPrice - ticks * mintick)

// =============================================================================
// === USER SETTINGS GROUPS ===
// =============================================================================

PRICE_LEVELS_GROUP = '📊 Entry & SL Price'
RISK_MANAGE_GROUP = '💰 Risk Manager'
CUSTOM_R_GROUP = '🎯 Custom R Level'
TABLE_APPEARANCE_GROUP = '🎨 Table Appearance'
ADVANCED_GROUP = '⚙️ Advanced Settings'

// =============================================================================
// === PRICE LEVELS ===
// =============================================================================

// Price inputs with enhanced validation
isUserTakeProfit = input.bool(defval = false, title = 'Manual Target Price', group = PRICE_LEVELS_GROUP)
isStaticTakeProfit = input.bool(defval = true, title = 'Static Target Prices', group = PRICE_LEVELS_GROUP)
isShowOnlyLastProfitTargetLine = input.bool(defval = false, title = 'Show only last profit target line', group = PRICE_LEVELS_GROUP)

rewardCount = input.int(defval = 3, title = 'Profit Target in R', step = 1, minval = 1, maxval = 10, group = PRICE_LEVELS_GROUP)

// Enhanced price inputs with inline styling
entryPriceManual = roundPrice(input.price(defval = 1.00000, title = 'Entry Price', group = PRICE_LEVELS_GROUP, inline = '1', confirm = true, tooltip = 'Click-to-place only fires on first add. To move it: type a new price here, or use the reset toggle below.'))
entryColor = input.color(color.new(#047857, 0), title = '', inline = '1', group = PRICE_LEVELS_GROUP)

stopLossPriceManual = roundPrice(input.price(defval = 0.99950, title = 'Stop Price', inline = '2', group = PRICE_LEVELS_GROUP, confirm = true, tooltip = 'Click-to-place only fires on first add. To move it: type a new price here, or use the reset toggle below. Auto-resets to a default offset from Entry if left over from a different symbol\'s price scale.'))
stopLossColor = input.color(color.new(#991b1b, 0), title = '', inline = '2', group = PRICE_LEVELS_GROUP)

takeProfitPriceManual = roundPrice(input.price(defval = 1.00050, title = 'Target Price', inline = '3', group = PRICE_LEVELS_GROUP, tooltip = 'Auto-resets to a default offset from Entry if left over from a different symbol\'s price scale.'))
takeColor = input.color(color.new(#1e40af, 0), title = '', inline = '3', group = PRICE_LEVELS_GROUP)

// Reset: snap Entry Price to the live symbol price instead of the manually-placed value
// above. Stop Price is intentionally untouched by this — it lets you stop re-dragging
// the entry point every time price moves, while keeping your stop exactly where you
// planned it.
resetToLive = input.bool(defval = false, title = '🔄 Reset entry to live price', group = PRICE_LEVELS_GROUP, tooltip = 'When enabled, Entry Price always tracks the current close every bar — a genuinely live-following entry. When disabled (default), a stale manual price (see below) is corrected once and then holds still; it will not keep drifting with price after that.')

// Manual re-sync trigger: the stale-price fix below only re-latches once per script
// load (e.g. right after a symbol switch), so if a level goes stale for any other reason
// and you don't want to remove/re-add the indicator, check this box to force a fresh
// snap to the current price, then uncheck it — whatever it lands on stays fixed after
// you uncheck it, same as the automatic one-shot behavior.
forceResync = input.bool(defval = false, title = '🔁 Force resync levels now (check, then uncheck)', group = PRICE_LEVELS_GROUP, tooltip = 'Manual alternative to removing and re-adding the indicator. While checked, any stale Entry/Stop/Target keeps snapping to a fresh value near the current price. Uncheck it to freeze whatever it landed on. Note: this never overrides "Reset entry to live price" above — if that toggle is on, Entry will keep following live price regardless, by its own separate design. Turn that off first if you want Entry to freeze too.')

// Guard against a stale manual entry/stop/target price left over from a different
// symbol's price scale (e.g. placed on SPX500 ~7565, chart switched to Nasdaq ~25000) —
// without this, the manual lines still get drawn, just miles outside the visible range,
// so it looks like they "disappeared" instead of just being off-scale (and any distance
// computed against them, like SL pips, comes out as a nonsense huge number).
//
// isEntryStale itself is re-evaluated every bar, but entryPriceManual never changes on
// its own — so if resetToLive were the only thing standing between "stale" and "close",
// a stale value would recompute against the live close on every single bar, which is
// indistinguishable from permanent live-tracking even with resetToLive left off. Instead,
// the very first time this loads with a stale value (i.e. right after a symbol switch,
// which reloads the script fresh), latch a value ONCE and hold it — plan a trade at a
// fixed level instead of it silently chasing price forever.
isEntryStale      = entryPriceManual      <= 0 or math.abs(entryPriceManual      - close) / close > 0.5
isStopStale       = stopLossPriceManual   <= 0 or math.abs(stopLossPriceManual   - close) / close > 0.5
isTakeProfitStale = takeProfitPriceManual <= 0 or math.abs(takeProfitPriceManual - close) / close > 0.5

// Detect an actual symbol change (not just a settings dialog open/close) as an
// unambiguous, code-visible trigger for re-arming the one-shot latches below — instead
// of relying only on the side effect of "changing an input reloads the whole script,"
// which is harder to reason about precisely.
var string _prevTicker = ''
bool tickerChanged = _prevTicker != syminfo.tickerid
_prevTicker := syminfo.tickerid

var float latchedEntry = na
var bool  entryLatched = false
if tickerChanged
    entryLatched := false
// While the manual resync toggle is checked, keep clearing the "already latched" flag so
// a stale value keeps snapping fresh every bar — unchecking it simply stops clearing the
// flag, so the next latch (using whatever price was current at that moment) sticks.
if forceResync
    entryLatched := false
if not entryLatched and isEntryStale and barstate.islast
    latchedEntry := roundPrice(close)
    entryLatched := true

entryPrice = resetToLive ? roundPrice(close) : isEntryStale ? latchedEntry : entryPriceManual

// Stop/Target normally stay exactly at their manually-plotted values — resetToLive never
// touches them. If stale, they latch the same way as Entry above: a fixed small offset
// from the (already-resolved) entry price, captured once and held, not recomputed every
// bar. Based on entryPrice rather than latchedEntry directly, so this still works
// correctly even when Entry itself isn't stale but Stop/Target are (e.g. you fixed Entry
// after a symbol switch but forgot Stop). Same 0.05% offset as this script's own
// placeholder defaults (1.00000 entry / 0.99950 stop / 1.00050 target), so a
// freshly-latched reset looks the same as a first-time add.
var float latchedStop = na
var bool  stopLatched = false
if tickerChanged
    stopLatched := false
if forceResync
    stopLatched := false
if not stopLatched and isStopStale and barstate.islast
    latchedStop := roundPrice(entryPrice * 0.9995)
    stopLatched := true

var float latchedTakeProfit = na
var bool  takeProfitLatched = false
if tickerChanged
    takeProfitLatched := false
if forceResync
    takeProfitLatched := false
if not takeProfitLatched and isTakeProfitStale and barstate.islast
    latchedTakeProfit := roundPrice(entryPrice * 1.0005)
    takeProfitLatched := true

stopLossPrice   = isStopStale       ? latchedStop       : stopLossPriceManual
takeProfitPrice = isTakeProfitStale ? latchedTakeProfit : takeProfitPriceManual

// =============================================================================
// === CUSTOM R LEVEL ===
// =============================================================================

showCustomR = input.bool(true, 'Show Custom R Level', group = CUSTOM_R_GROUP)
customR = input.float(0.5, 'Custom R Level', minval = 0.1, maxval = 9.0, step = 0.1, group = CUSTOM_R_GROUP, tooltip = 'Draw an extra R line at this level (e.g. 0.5, 0.9)')
customRColor = input.color(color.new(#4274D9, 0), 'Custom R Color', group = CUSTOM_R_GROUP)

// =============================================================================
// === RISK MANAGEMENT ===
// =============================================================================

accountSize = input(5000, 'Account Size ($)', group = RISK_MANAGE_GROUP, tooltip = 'Total account balance in USD')
risk = input.float(1, title = 'Risk (%)', group = RISK_MANAGE_GROUP, minval = 0.1, maxval = 10, step = 0.1, tooltip = 'Risk percentage per trade')
commission = input.float(5, title = 'Commission ($/lot)', group = RISK_MANAGE_GROUP, minval = 0, tooltip = 'Commission per lot round-trip (e.g. $5 for prop firms)')
spread = input.float(2, title = 'Spread (pips)', group = RISK_MANAGE_GROUP, minval = 0, tooltip = 'Average spread in pips')
leverage = input.int(30, title = 'Leverage (1:X)', group = RISK_MANAGE_GROUP, minval = 1, maxval = 2000, tooltip = 'Used to estimate required margin from Position Value. E.g. 30 = 1:30.')
maxSafeRiskPct = input.float(3.0, title = 'Warn if Risk % above', group = RISK_MANAGE_GROUP, minval = 0.1, maxval = 100, step = 0.1, tooltip = 'Both risk % fields turn red with a ⚠ caution mark when set above this value.')
maxSlPips = input.float(15, title = 'Warn if SL distance above (pips)', group = RISK_MANAGE_GROUP, minval = 1, tooltip = 'Forex-only: shows a caution row when the Stop Price is more than this many pips from Entry.')

// =============================================================================
// === SECOND ACCOUNT TABLE SETTINGS ===
// =============================================================================

SECOND_ACCOUNT_GROUP = '📊 Second Account Table'
showSecondTable = input.bool(false, 'Show Second Account Table', group = SECOND_ACCOUNT_GROUP, tooltip = 'Enable second table for different account size')
accountSize2 = input(10000, 'Second Account Size ($)', group = SECOND_ACCOUNT_GROUP, tooltip = 'Second account balance in USD')
risk2 = input.float(1.5, title = 'Second Risk (%)', group = SECOND_ACCOUNT_GROUP, minval = 0.1, maxval = 10, step = 0.1, tooltip = 'Risk percentage for second account')
commission2 = input.float(5, title = 'Second Commission ($/lot)', group = SECOND_ACCOUNT_GROUP, minval = 0, tooltip = 'Commission per lot round-trip for second account')
spread2 = input.float(2, title = 'Second Spread (pips)', group = SECOND_ACCOUNT_GROUP, minval = 0, tooltip = 'Average spread for second account')
leverage2 = input.int(30, title = 'Second Leverage (1:X)', group = SECOND_ACCOUNT_GROUP, minval = 1, maxval = 2000, tooltip = 'Leverage used for the second account margin estimate.')

// =============================================================================
// === TABLE APPEARANCE ===
// =============================================================================

tabPosI = input.string('top_right', 'Table 1 Position', ['top_left', 'top_center', 'top_right', 'middle_left', 'middle_center', 'middle_right', 'bottom_left', 'bottom_center', 'bottom_right'], group = TABLE_APPEARANCE_GROUP)
tabPosI2 = input.string('top_left', 'Table 2 Position', ['top_left', 'top_center', 'top_right', 'middle_left', 'middle_center', 'middle_right', 'bottom_left', 'bottom_center', 'bottom_right'], group = TABLE_APPEARANCE_GROUP)
textSize = input.string('normal', 'Text Size', ['small', 'tiny', 'normal', 'large'], group = TABLE_APPEARANCE_GROUP)
useAutoTheme = input.bool(true, 'Auto theme (match chart bg)', group = TABLE_APPEARANCE_GROUP, tooltip = 'When enabled, table colors are derived from your chart background (light/dark) just like the DTC AIO theme system.')

// =============================================================================
// === ADVANCED SETTINGS ===
// =============================================================================


// =============================================================================
// === THEME SYSTEM (matched to DTC AIO) ===
// =============================================================================

f_chart_is_dark() =>
    bg = chart.bg_color
    color.r(bg) + color.g(bg) + color.b(bg) <= 400

bool isDark = f_chart_is_dark()

color cleanTableBg = isDark ? color.new(#0d0d0d, 100) : color.new(#ffffff, 100)
color cleanTableAltBg = isDark ? color.new(#141414, 100) : color.new(#f0f0f0, 100)
color cleanTableHeaderBg = isDark ? color.new(#242424, 100) : color.new(#e4e4e4, 100)
color cleanTableText = isDark ? color.new(#eaeaea, 0) : color.new(#1c1c1c, 0)
color cleanTableHeaderText = cleanTableText
color cleanTableBorder = isDark ? #333333 : #cccccc
color cleanTablePositive = color.new(#146b00, 0)
color cleanTableNegative = color.new(#960505, 0)

f_table_row_bg(int row) =>
    row % 2 == 0 ? cleanTableBg : cleanTableAltBg

// Resolve final colors: auto theme vs manual override
color tabCol = useAutoTheme ? cleanTableBg : input.color(color.new(#1e293b, 10), 'Background', group = TABLE_APPEARANCE_GROUP)
color textCol = useAutoTheme ? cleanTableText : input.color(color.white, 'Text Color', group = TABLE_APPEARANCE_GROUP)
color borderColor = useAutoTheme ? cleanTableBorder : input.color(color.new(#64748b, 0), 'Border', group = TABLE_APPEARANCE_GROUP)
color headerCol = useAutoTheme ? cleanTableHeaderBg : tabCol
color warnBg = useAutoTheme ? color.new(isDark ? #7f1d1d : #fee2e2, 20) : color.new(#7f1d1d, 20)
color warnText = useAutoTheme ? cleanTableNegative : color.new(#ef4444, 0)

// =============================================================================
// === CALCULATIONS ===
// =============================================================================

// Risk calculations
riskInUSD = int(risk * accountSize / 100)
riskCaution = risk > maxSafeRiskPct

// Futures trade in whole contracts only (no fractional micros) — everything else
// (forex lots, CFD/index units) keeps fractional sizing as before.
isFuturesInstrument = syminfo.type == 'futures'

// Stop loss calculations (live — uses the current, possibly live-tracking, entryPrice)
stopLossSize = math.abs(entryPrice - stopLossPrice)
stopLossTickSize = int(roundPrice(stopLossSize / syminfo.mintick))
contractSize = getContractSize()
stopLossCashPerLot = getCashPerLotForMove(stopLossSize, contractSize)

// Pip size (moved up from the SL-distance section below so spread cost can use it too)
// accounts for 5-decimal and 3-decimal forex pairs.
isForex = syminfo.type == 'forex'
pipSize = syminfo.mintick * (syminfo.mintick == 0.00001 or syminfo.mintick == 0.001 ? 10 : 1)

// Spread cost per lot — the "Spread (pips)" inputs were previously collected but never
// used anywhere, silently understating real trading cost. Modeled the same way as
// commission: a per-lot dollar cost baked into sizing and into True Risk.
spreadCostPerLot = getCashPerLotForMove(spread * pipSize, contractSize)
spreadCostPerLot2 = getCashPerLotForMove(spread2 * pipSize, contractSize)

// Normally position size is solved from the planned manual entry/stop. When Entry is
// set to follow live price, however, recalculate size from the live entry-to-stop
// distance so the lot size stays aligned with the moving entry. A stale manual Entry
// or Stop also falls back to the resolved live distance rather than using a garbage
// cross-symbol distance.
plannedStopLossSize = resetToLive or isEntryStale or isStopStale ? stopLossSize : math.abs(entryPriceManual - stopLossPriceManual)
plannedCashPerLotWithCommission = getCashPerLotForMove(plannedStopLossSize, contractSize) + commission + spreadCostPerLot
lotsWithCommission = plannedCashPerLotWithCommission > 0 ? riskInUSD / plannedCashPerLotWithCommission : 0
finalLots = lotsWithCommission > 0 ? isFuturesInstrument ? math.floor(lotsWithCommission) : lotsWithCommission : 0
// True when the risk budget can't afford even 1 whole contract at this stop distance
zeroContractsWarning = isFuturesInstrument and lotsWithCommission > 0 and finalLots < 1

// Take profit calculations
takeProfitSize = math.abs(entryPrice - takeProfitPrice)
takeProfitTickSize = int(roundPrice(takeProfitSize / syminfo.mintick))
takeProfitCashPerLot = getCashPerLotForMove(takeProfitSize, contractSize)
takeProfitInUSD = takeProfitCashPerLot * finalLots - commission * finalLots - spreadCostPerLot * finalLots

// Position value
positionValue = finalLots * contractSize * entryPrice

// Required margin at the configured leverage, and what % of the account that consumes.
// Position sizing solves purely for risk %, so it's possible to land on a lot size that
// is "correct" for risk but needs more margin than the account actually has — this is
// the check that catches that case.
requiredMargin = positionValue / leverage
marginPct = accountSize > 0 ? requiredMargin / accountSize * 100 : na
marginCaution = marginPct > 100

// Commission calculations
totalCommission = commission * finalLots
totalSpreadCost = spreadCostPerLot * finalLots
// The actual $ risk at the current stop distance and position size — not just the
// target risk amount echoed back. These normally match for fractional (forex) sizing
// since finalLots is solved to hit riskInUSD exactly, but they diverge whenever finalLots
// gets rounded (e.g. whole-contract flooring for futures), and this also means True Risk
// now moves live as Entry Price tracks the current close while Stop Price stays fixed.
trueRisk = finalLots * stopLossCashPerLot + totalCommission + totalSpreadCost

// Custom R-level calculations
isLong = entryPrice > stopLossPrice
customRTicks = int(stopLossTickSize * customR)
customRPrice = roundPrice(isLong ? entryPrice + customRTicks * syminfo.mintick : entryPrice - customRTicks * syminfo.mintick)
// R-multiples are quoted off trueRisk (the actual $ risk of the sized position,
// including commission + spread) rather than the idealized riskInUSD target, so the
// R-ladder and the True Risk row are always talking about the same number.
customRProfit = trueRisk * customR - totalCommission - totalSpreadCost

// SL distance in pips/ticks
stopLossPips = stopLossSize / pipSize
slWarning = isForex and stopLossPips > maxSlPips

// =============================================================================
// === SECOND ACCOUNT CALCULATIONS ===
// =============================================================================

// Risk calculations for second account
riskInUSD2 = int(risk2 * accountSize2 / 100)
riskCaution2 = risk2 > maxSafeRiskPct
plannedCashPerLotWithCommission2 = getCashPerLotForMove(plannedStopLossSize, contractSize) + commission2 + spreadCostPerLot2

// Position size calculations for second account (also solved from the planned distance)
lotsWithCommission2 = plannedCashPerLotWithCommission2 > 0 ? riskInUSD2 / plannedCashPerLotWithCommission2 : 0
finalLots2 = lotsWithCommission2 > 0 ? isFuturesInstrument ? math.floor(lotsWithCommission2) : lotsWithCommission2 : 0
zeroContractsWarning2 = isFuturesInstrument and lotsWithCommission2 > 0 and finalLots2 < 1

// Take profit calculations for second account
takeProfitInUSD2 = takeProfitCashPerLot * finalLots2 - commission2 * finalLots2 - spreadCostPerLot2 * finalLots2

// Position value for second account
positionValue2 = finalLots2 * contractSize * entryPrice
requiredMargin2 = positionValue2 / leverage2
marginPct2 = accountSize2 > 0 ? requiredMargin2 / accountSize2 * 100 : na
marginCaution2 = marginPct2 > 100

// Commission calculations for second account
totalCommission2 = commission2 * finalLots2
totalSpreadCost2 = spreadCostPerLot2 * finalLots2
trueRisk2 = finalLots2 * stopLossCashPerLot + totalCommission2 + totalSpreadCost2

// =============================================================================
// === TABLE SETUP ===
// =============================================================================

// Function to convert position string to position enum
getTablePosition(posStr) =>
    switch posStr
        'top_left' => position.top_left
        'top_center' => position.top_center
        'top_right' => position.top_right
        'middle_left' => position.middle_left
        'middle_center' => position.middle_center
        'middle_right' => position.middle_right
        'bottom_left' => position.bottom_left
        'bottom_center' => position.bottom_center
        'bottom_right' => position.bottom_right
        => position.top_right

tabPos = getTablePosition(tabPosI)
tabPos2 = getTablePosition(tabPosI2)

var smartTable = table.new(position = tabPos, columns = 2, rows = 19, bgcolor = cleanTableBg, frame_color = borderColor, frame_width = 2, border_color = borderColor, border_width = 1)
var smartTable2 = table.new(position = tabPos2, columns = 2, rows = 19, bgcolor = cleanTableBg, frame_color = borderColor, frame_width = 2, border_color = borderColor, border_width = 1)

// Reward-to-risk ratio (based on the manual Target Price, when shown). Divides by
// trueRisk (actual $ risk including commission + spread) to match the True Risk row.
rrRatio = trueRisk > 0 ? takeProfitInUSD / trueRisk : na

f_section(table _t, int row, string label) =>
    table.cell(_t, 0, row, label, text_color = textCol, text_size = textSize, bgcolor = headerCol, text_halign = text.align_left)
    table.cell(_t, 1, row, '', bgcolor = headerCol)
    table.merge_cells(_t, 0, row, 1, row)

f_row(table _t, int row, string label, string val, color valColor) =>
    table.cell(_t, 0, row, label, text_color = textCol, text_size = textSize, bgcolor = f_table_row_bg(row), text_halign = text.align_left)
    table.cell(_t, 1, row, val, text_color = valColor, text_size = textSize, bgcolor = f_table_row_bg(row), text_halign = text.align_right, text_font_family = font.family_monospace)

// Futures show whole contracts ("3", not "3.00"); everything else keeps fractional lot formatting
f_formatQty(float qty) =>
    isFuturesInstrument ? str.tostring(qty, '#') : numberToLotSizeFormat(qty)
string qtyLabel = isFuturesInstrument ? 'Contracts' : 'Lot Size'
string slUnitLabel = isFuturesInstrument ? ' ticks' : ' pips'

// =============================================================================
// === TABLE CONTENT ===
// =============================================================================

if barstate.islast
    // Title banner
    table.cell(smartTable, 0, 0, '⚡ DTC Lot Size', text_color = textCol, text_size = 'normal', bgcolor = headerCol, text_halign = text.align_center)
    table.cell(smartTable, 1, 0, '', bgcolor = headerCol)
    table.merge_cells(smartTable, 0, 0, 1, 0)
    int r1 = 1

    f_section(smartTable, r1, '💰 Account & Risk')
    r1 := r1 + 1
    f_row(smartTable, r1, 'Account Size', '$' + toString(accountSize), textCol)
    r1 := r1 + 1
    f_row(smartTable, r1, 'Risk Amount', '$' + toString(riskInUSD), textCol)
    r1 := r1 + 1
    f_row(smartTable, r1, 'Risk %', toString(risk) + '%' + (riskCaution ? ' ⚠' : ''), riskCaution ? warnText : textCol)
    r1 := r1 + 1
    f_row(smartTable, r1, 'SL Distance', toString(stopLossTickSize) + slUnitLabel, textCol)
    r1 := r1 + 1

    f_section(smartTable, r1, '📦 Position Size')
    r1 := r1 + 1
    f_row(smartTable, r1, qtyLabel, f_formatQty(finalLots), cleanTablePositive)
    r1 := r1 + 1
    f_row(smartTable, r1, 'Position Value', '$' + numberToLotSizeFormat(positionValue), textCol)
    r1 := r1 + 1
    f_row(smartTable, r1, 'Margin %', numberToLotSizeFormat(marginPct) + '%' + (marginCaution ? ' ⚠' : ''), marginCaution ? warnText : textCol)
    r1 := r1 + 1
    f_row(smartTable, r1, 'Total Commission', '$' + numberToLotSizeFormat(totalCommission), textCol)
    r1 := r1 + 1
    f_row(smartTable, r1, 'Spread Cost', '$' + numberToLotSizeFormat(totalSpreadCost), textCol)
    r1 := r1 + 1
    f_row(smartTable, r1, 'True Risk', '$' + numberToLotSizeFormat(trueRisk), cleanTableNegative)
    r1 := r1 + 1
    if zeroContractsWarning
        f_row(smartTable, r1, '⚠ Risk too small', 'for 1 contract', warnText)
        r1 := r1 + 1
        r1

    // Take profit information
    if isUserTakeProfit
        f_section(smartTable, r1, '🎯 Targets')
        r1 := r1 + 1
        f_row(smartTable, r1, 'Take Profit', toString(takeProfitPrice), takeColor)
        r1 := r1 + 1
        f_row(smartTable, r1, 'Profit in $', '$' + numberToLotSizeFormat(takeProfitInUSD), takeColor)
        r1 := r1 + 1
        f_row(smartTable, r1, 'Reward:Risk', na(rrRatio) ? '-' : numberToLotSizeFormat(rrRatio) + 'R', takeColor)
        r1 := r1 + 1
        r1

    // SL distance warning for forex
    if slWarning
        table.cell(smartTable, 0, r1, '⚠ Warning', text_color = warnText, text_size = textSize, bgcolor = warnBg)
        table.cell(smartTable, 1, r1, 'SL > ' + numberToLotSizeFormat(maxSlPips) + ' pips (' + numberToLotSizeFormat(stopLossPips) + 'p)', text_color = warnText, text_size = textSize, bgcolor = warnBg, text_halign = text.align_right)

// =============================================================================
// === SECOND TABLE CONTENT ===
// =============================================================================

rrRatio2 = trueRisk2 > 0 ? takeProfitInUSD2 / trueRisk2 : na

if barstate.islast and showSecondTable
    table.cell(smartTable2, 0, 0, '⚡ DTC Lot Size 2', text_color = textCol, text_size = 'normal', bgcolor = headerCol, text_halign = text.align_center)
    table.cell(smartTable2, 1, 0, '', bgcolor = headerCol)
    table.merge_cells(smartTable2, 0, 0, 1, 0)
    int r2 = 1

    f_section(smartTable2, r2, '💰 Account & Risk')
    r2 := r2 + 1
    f_row(smartTable2, r2, 'Account Size', '$' + toString(accountSize2), textCol)
    r2 := r2 + 1
    f_row(smartTable2, r2, 'Risk Amount', '$' + toString(riskInUSD2), textCol)
    r2 := r2 + 1
    f_row(smartTable2, r2, 'Risk %', toString(risk2) + '%' + (riskCaution2 ? ' ⚠' : ''), riskCaution2 ? warnText : textCol)
    r2 := r2 + 1
    f_row(smartTable2, r2, 'SL Distance', toString(stopLossTickSize) + slUnitLabel, textCol)
    r2 := r2 + 1

    f_section(smartTable2, r2, '📦 Position Size')
    r2 := r2 + 1
    f_row(smartTable2, r2, qtyLabel, f_formatQty(finalLots2), cleanTablePositive)
    r2 := r2 + 1
    f_row(smartTable2, r2, 'Position Value', '$' + numberToLotSizeFormat(positionValue2), textCol)
    r2 := r2 + 1
    f_row(smartTable2, r2, 'Margin %', numberToLotSizeFormat(marginPct2) + '%' + (marginCaution2 ? ' ⚠' : ''), marginCaution2 ? warnText : textCol)
    r2 := r2 + 1
    f_row(smartTable2, r2, 'Total Commission', '$' + numberToLotSizeFormat(totalCommission2), textCol)
    r2 := r2 + 1
    f_row(smartTable2, r2, 'Spread Cost', '$' + numberToLotSizeFormat(totalSpreadCost2), textCol)
    r2 := r2 + 1
    f_row(smartTable2, r2, 'True Risk', '$' + numberToLotSizeFormat(trueRisk2), cleanTableNegative)
    r2 := r2 + 1
    if zeroContractsWarning2
        f_row(smartTable2, r2, '⚠ Risk too small', 'for 1 contract', warnText)
        r2 := r2 + 1
        r2

    if isUserTakeProfit
        f_section(smartTable2, r2, '🎯 Targets')
        r2 := r2 + 1
        f_row(smartTable2, r2, 'Take Profit', toString(takeProfitPrice), takeColor)
        r2 := r2 + 1
        f_row(smartTable2, r2, 'Profit in $', '$' + numberToLotSizeFormat(takeProfitInUSD2), takeColor)
        r2 := r2 + 1
        f_row(smartTable2, r2, 'Reward:Risk', na(rrRatio2) ? '-' : numberToLotSizeFormat(rrRatio2) + 'R', takeColor)
        r2 := r2 + 1
        r2

    if slWarning
        table.cell(smartTable2, 0, r2, '⚠ Warning', text_color = warnText, text_size = textSize, bgcolor = warnBg)
        table.cell(smartTable2, 1, r2, 'SL > ' + numberToLotSizeFormat(maxSlPips) + ' pips (' + numberToLotSizeFormat(stopLossPips) + 'p)', text_color = warnText, text_size = textSize, bgcolor = warnBg, text_halign = text.align_right)


// =============================================================================
// === VISUAL ELEMENTS ===
// =============================================================================

// R-multiple target lines
var rewardLines = array.new_line()
var rewardLabels = array.new_label()

if array.size(rewardLines) < rewardCount
    for i = 1 to rewardCount by 1
        // Thin dashed lines, extended left across the chart (like before)
        rewardLine = line.new(bar_index, 0, bar_index + 10, 0, extend = extend.left, style = line.style_dashed, color = takeColor, width = 1)
        rewardLabel = label.new(bar_index + 10, 0, textcolor = takeColor, color = color.new(color.silver, 100), style = label.style_label_left)
        array.push(rewardLines, rewardLine)
        array.push(rewardLabels, rewardLabel)

// Entry, SL, TP lines (thin but extended left like before)
var entryLine = line.new(bar_index, 0, bar_index + 10, 0, extend = extend.left, style = line.style_dashed, color = entryColor, width = 1)
var stopLossLine = line.new(bar_index, 0, bar_index + 10, 0, extend = extend.left, style = line.style_dashed, color = stopLossColor, width = 1)
var entryLineLabel = label.new(bar_index + 10, 0, '', textcolor = entryColor, color = color.new(color.silver, 100), style = label.style_label_left)
var stopLossLineLabel = label.new(bar_index + 10, 0, '', textcolor = stopLossColor, color = color.new(color.silver, 100), style = label.style_label_left)
var takeProfitLine = line.new(bar_index, takeProfitPrice, bar_index + 10, takeProfitPrice, extend = extend.left, style = line.style_dashed, color = takeColor, width = 1)
var takeProfitLabel = label.new(bar_index + 10, takeProfitPrice, '', textcolor = takeColor, color = color.new(color.silver, 100), style = label.style_label_left)

// Custom R line
var customRLine = line.new(na, na, na, na, extend = extend.left, style = line.style_dashed, width = 1)
var customRLineLabel = label.new(na, na, '', color = color.new(color.silver, 100), style = label.style_label_left)

if barstate.islast
    // Entry line & label
    line.set_xy1(entryLine, bar_index, entryPrice)
    line.set_xy2(entryLine, bar_index + 10, entryPrice)
    label.set_xy(entryLineLabel, bar_index + 10, entryPrice)
    label.set_text(entryLineLabel, 'Entry: ' + toString(entryPrice))

    // Stop loss line & label
    line.set_xy1(stopLossLine, bar_index, stopLossPrice)
    line.set_xy2(stopLossLine, bar_index + 10, stopLossPrice)
    label.set_xy(stopLossLineLabel, bar_index + 10, stopLossPrice)
    label.set_text(stopLossLineLabel, 'Stop: ' + toString(stopLossPrice) + '  -$' + numberToLotSizeFormat(trueRisk))

    // Take profit line & label
    line.set_xy1(takeProfitLine, bar_index, takeProfitPrice)
    line.set_xy2(takeProfitLine, bar_index + 10, takeProfitPrice)
    label.set_xy(takeProfitLabel, bar_index + 10, takeProfitPrice)
    label.set_text(takeProfitLabel, 'Target: ' + toString(takeProfitPrice) + '  +$' + numberToLotSizeFormat(takeProfitInUSD))

    // Custom R line
    if showCustomR
        line.set_xy1(customRLine, bar_index, customRPrice)
        line.set_xy2(customRLine, bar_index + 10, customRPrice)
        line.set_color(customRLine, customRColor)
        label.set_xy(customRLineLabel, bar_index + 10, customRPrice)
        label.set_text(customRLineLabel, numberToLotSizeFormat(customR) + 'R: ' + toString(customRPrice) + '  +$' + numberToLotSizeFormat(customRProfit))
        label.set_textcolor(customRLineLabel, customRColor)
    else
        line.delete(customRLine)
        label.delete(customRLineLabel)

    // Static R target lines (1R, 2R, 3R, ...) positioned using pure stop distance
    for i = 1 to rewardCount by 1
        rewardLine = array.get(rewardLines, i - 1)
        rewardLabel = array.get(rewardLabels, i - 1)
        ticks = getTicksForNR(stopLossTickSize, i)
        price = getPriceForNR(entryPrice, stopLossPrice, ticks, syminfo.mintick)
        line.set_xy1(rewardLine, bar_index, price)
        line.set_xy2(rewardLine, bar_index + 10, price)
        label.set_xy(rewardLabel, bar_index + 10, price)
        // Profit shown as N * trueRisk minus costs once (matches the True Risk row's basis)
        nRProfit = trueRisk * i - totalCommission - totalSpreadCost
        label.set_text(rewardLabel, toString(i) + 'R: ' + toString(price) + '  +$' + numberToLotSizeFormat(nRProfit))
        rewardLine

    // Hide the whole 1R–NR ladder when Manual Target Price is on — a fixed target line
    // plus a full R-multiple ladder is redundant clutter once you've picked one exact target.
    if not isStaticTakeProfit or isUserTakeProfit
        for i = 1 to rewardCount by 1
            rewardLine = array.get(rewardLines, i - 1)
            rewardLabel = array.get(rewardLabels, i - 1)
            line.delete(rewardLine)
            label.delete(rewardLabel)

    if isShowOnlyLastProfitTargetLine and rewardCount > 1
        for i = 1 to rewardCount - 1 by 1
            rewardLine = array.get(rewardLines, i - 1)
            rewardLabel = array.get(rewardLabels, i - 1)
            line.delete(rewardLine)
            label.delete(rewardLabel)

    // Show/hide manual take profit line
    if not isUserTakeProfit
        line.delete(takeProfitLine)
        label.delete(takeProfitLabel)
````
