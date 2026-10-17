# Macro Thesis Fleet: Direction & Cause Overlay

- url: https://www.tradingview.com/script/ha5blcIT-Macro-Thesis-Fleet-Direction-Cause-Overlay/
- type: indicator
- pine_id: PUB;e296283bc8b84b2ca65795c9686c2f77
- version: 1.0

## Description

Macro Thesis Fleet Overlay

A read-only macro context panel for your chart. Instead of a single trend arrow, it shows how a fleet of independent macro theses currently lean on a mapped symbol — plus the top causal claim behind that lean.

What it shows (top-right table)

 Asset name — human label for the matched symbol
 Direction — LONG, SHORT, or MIXED from fleet vote aggregation
 Room % — estimated unpriced move remaining (Tight / Moderate / Significant band)
 Strength label — e.g. Clear signal, Mixed fleet, Flagged (when thesis quality gates fail)
 Fleet lean — count of theses leaning up / down / neutral (when available)
 Cause one-liner — the dominant D1-level macro claim driving the read (not a price summary)
How direction is computed

Each mapped symbol carries a pre-computed direction code from upstream thesis aggregation:

 LONG — net tradable lean is bullish after quality filters
 SHORT — net tradable lean is bearish after quality filters
 MIXED — material disagreement across the thesis fleet (no forced one-sided arrow)
This is macro context, not an intraday entry signal. Use it as a filter before your own timeframe and risk rules.

How symbol matching works

On the last bar, the script builds candidate keys from syminfo.tickerid, exchange:ticker, and bare ticker, then looks up the first match in parallel embedded arrays (MACRO_TV_KEYS, MACRO_SYMBOLS). If no match, the panel states that the chart symbol is not in the current feed.

Data cadence (important)

Values are embedded at publish time as Pine string/int/float arrays — Pine cannot call external APIs on Community scripts. Republish this script when you need a refreshed snapshot. The embedded Generated: comment in source shows the bake timestamp.

Mapped symbols in this release (31)

BTC · XAUUSD · XAGUSD · NVDA · MSFT · META · GOOGL · AMZN · SPY · QQQ · IWM · GLD · GC · XLE · GDX · TLT · EURUSD · USDJPY · EURJPY · PA · KIE · FXY · AEM · RGLD · URA · UST · NUGT · VALE · TECK · XLRE · VNQ

Matching examples: BINANCE:BTCUSDT, OANDA:XAUUSD, NASDAQ:NVDA, AMEX:SPY.

How to use

Add to a chart for one of the mapped symbols above.
Read direction + room + cause in the panel.
If direction is MIXED or strength is Flagged, treat the read as low conviction until you verify contributing theses yourself.
Republish when the embedded snapshot is stale for your workflow.
Not financial advice. Macro snapshot only — not a trading system.

## Source Code

````pine
//@version=6
indicator("Macro Thesis Fleet: Direction & Cause Overlay", overlay=true, max_labels_count=500)

// Multi-thesis macro overlay: direction, room-to-run, fleet lean, and top cause one-liner.
// Feed is embedded at publish time (static snapshot) — republish to refresh mapped symbols.

// Generated: 2026-07-02T23:10:22.320Z
// Entries: 31

var string[] MACRO_TV_KEYS = array.from("BINANCE:BTCUSDT", "OANDA:XAUUSD", "OANDA:XAGUSD", "NASDAQ:NVDA", "NASDAQ:MSFT", "NASDAQ:META", "NASDAQ:GOOGL", "NASDAQ:AMZN", "AMEX:SPY", "NASDAQ:QQQ", "AMEX:IWM", "AMEX:GLD", "COMEX:GC1!", "AMEX:XLE", "AMEX:GDX", "NASDAQ:TLT", "OANDA:EURUSD", "OANDA:USDJPY", "OANDA:EURJPY", "TVC:PA", "AMEX:KIE", "AMEX:FXY", "NYSE:AEM", "NASDAQ:RGLD", "AMEX:URA", "AMEX:UST", "AMEX:NUGT", "NYSE:VALE", "NYSE:TECK", "AMEX:XLRE", "AMEX:VNQ")
var string[] MACRO_SYMBOLS = array.from("BTC", "XAUUSD", "XAGUSD", "NVDA", "MSFT", "META", "GOOGL", "AMZN", "SPY", "QQQ", "IWM", "GLD", "GC", "XLE", "GDX", "TLT", "EURUSD", "USDJPY", "EURJPY", "PA", "KIE", "FXY", "AEM", "RGLD", "URA", "UST", "NUGT", "VALE", "TECK", "XLRE", "VNQ")
var int[] MACRO_DIR = array.from(0, 0, -1, -1, -1, -1, -1, -1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1, -1, -1, 1, -1, -1, -1, -1, -1, -1, 1, 1, -1, 1)
var float[] MACRO_ROOM = array.from(31.00, 23.00, 28.00, 22.00, 16.00, 27.00, 17.00, 13.00, 21.00, 21.00, 26.00, 23.00, 23.00, 23.00, 27.00, 26.00, 23.00, 22.00, 32.00, 31.00, 31.00, 31.00, 30.00, 25.00, 25.00, 67.00, 35.00, 28.00, 28.00, 30.00, 28.00)
var string[] MACRO_ROOM_BAND = array.from("Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Tight", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Moderate", "Significant", "Significant", "Moderate", "Moderate", "Moderate", "Moderate")
var string[] MACRO_STRENGTH = array.from("Mixed fleet — Mixed picture", "Mixed fleet — Mixed picture", "Building", "Flagged — Clear signal", "Building", "Clear signal", "Building", "Clear signal", "Mixed fleet — Mixed picture", "Mixed fleet — Mixed picture", "Flagged — Building", "Mixed fleet — Mixed picture", "Mixed fleet — Mixed picture", "Mixed fleet — Mixed picture", "Mixed fleet — Mixed picture", "Mixed fleet — Mixed picture", "Mixed fleet — Mixed picture", "Flagged — Clear signal", "Clear signal", "Clear signal", "Clear signal", "Clear signal", "Clear signal", "Clear signal", "Clear signal", "Clear signal", "Clear signal", "Clear signal", "Clear signal", "Clear signal", "Clear signal")
var string[] MACRO_CAUSE = array.from("If state PUCs keep fast-tracking datacenter interconnection over crypto load,…", "Tail risk is lower than the last two years,…", "HG.1 crashes as CTA funds mechanically dump copper length on ISM below 48.5;…", "long-term Treasuries, EURUSD — Defense tech rerates as AI safety politicizes.…", "Crude oil slides as demand forecasts are trimmed;…", "META, GOOGL, NVDA — Meta and Google earnings soft-capex language hits semis and hyperscalers first.", "META, GOOGL, NVDA — Meta and Google earnings soft-capex language hits semis and hyperscalers first.", "US stocks, NVDA — AI capex shock hits headlines: MSFT, AMZN,…", "IWM rises on the direct D1→D2 channel.", "Money is still expensive. Companies that throw off steady cash can fund AI and earn…", "IWM, copper, energy stocks — Small-cap industrials catch up; copper demand from rearmament electrification sp…", "Tail risk is lower than the last two years,…", "Tail risk is lower than the last two years,…", "IWM, copper, energy stocks — Small-cap industrials catch up; copper demand from rearmament electrification sp…", "NUGT, XME — Miners get crushed as CTA models flip short", "intermediate bonds, dollar, EURUSD — Trend funds cover Treasury shorts,…", "Long bonds breathe as gold pivots to inflation hedge. Euro reprices energy-tax drag. Defense rerates.", "Gold rotates from war hedge to Fed-hedge. Pension cash cuts from 18% to 12% favor…", "GBPJPY, BZ, oil — CTA trend funds running EURJPY longs on dollar-weakness momentum will hit…", "copper, NZDUSD, PA — If Middle East supply-chain fears keep Chinese manufacturers deferring large copper…", "KIE, BZ, XAUUSD — Iran's IRGC seized a cargo vessel near Oman and jammed GPS…", "If reshoring metrics keep improving, investors may treat CNH as a currency to short,…", "Rand stays weak past 19/$, which forces treasury flows win from real-rate drop,…", "Junior miners drop harder; copper producers feel the same cost squeeze;…", "Energy producers reprice lower on margin pressure; tanker stocks weaken as fewer cargoes move;…", "TLT falls — UST falls — JGB rises —…", "NUGT, XME — Miners get crushed as CTA models flip short", "XME, iron ore, long-term Treasuries — copper miners, SCCO, TECK —…", "XME, iron ore, long-term Treasuries — copper miners, SCCO, TECK —…", "NEM, silver, XLRE — CTA gold stops trigger, GDX futures forced selling hits miners", "Wheat, cocoa, cotton face retaliatory tariffs. LNG export competitiveness erodes.…")
var string[] MACRO_NAME = array.from("Bitcoin", "Gold Spot", "Silver Spot", "Nvidia", "Microsoft", "Meta Platforms", "Alphabet", "Amazon", "S&P 500", "Nasdaq 100", "Russell 2000", "Gold Spot", "Gold Spot", "Energy Select Sector", "Gold Miners ETF", "20+ Year Treasuries", "Euro / US Dollar", "US Dollar / Japanese Yen", "Euro / Japanese Yen", "Palladium", "Insurance ETF", "Invesco CurrencyShares Japanese Yen Trust", "Agnico Eagle Mines", "Royal Gold", "Uranium", "Ultra 7–10Y Treasury ETF", "Direxion Gold Miners Bull 2X", "Vale S.A.", "Teck Resources", "Real Estate sector", "REIT ETF")
var string[] MACRO_LEAN = array.from("23 thesises lean up · 29 lean down · 2 neutral", "107 thesises lean up · 105 lean down · 18 neutral", "", "", "", "", "", "", "48 thesises lean up · 61 lean down · 15 neutral", "27 thesises lean up · 33 lean down · 6 neutral", "", "107 thesises lean up · 105 lean down · 18 neutral", "107 thesises lean up · 105 lean down · 18 neutral", "87 thesises lean up · 95 lean down · 5 neutral", "89 thesises lean up · 84 lean down · 6 neutral", "122 thesises lean up · 108 lean down · 16 neutral", "51 thesises lean up · 53 lean down · 11 neutral", "", "", "", "", "", "", "", "", "", "", "", "", "", "")

f_macro_key_candidates() =>
    array.from(
      syminfo.tickerid,
      syminfo.prefix + ":" + syminfo.ticker,
      syminfo.ticker
    )

f_macro_find_index() =>
    keys = f_macro_key_candidates()
    found = -1
    for ki = 0 to array.size(keys) - 1
        key = str.upper(array.get(keys, ki))
        for i = 0 to array.size(MACRO_TV_KEYS) - 1
            if key == array.get(MACRO_TV_KEYS, i)
                found := i
                break
            if key == array.get(MACRO_SYMBOLS, i)
                found := i
                break
        if found >= 0
            break
    found

f_macro_dir_label(code) =>
    code > 0 ? "LONG" : code < 0 ? "SHORT" : "MIXED"

f_macro_dir_color(code) =>
    code > 0 ? color.new(#22c55e, 0) : code < 0 ? color.new(#ef4444, 0) : color.new(#f59e0b, 0)

var table macroPanel = table.new(position.top_right, 1, 6, bgcolor=color.new(#111110, 10), border_width=1, border_color=color.new(#888888, 40))

if barstate.islast
    idx = f_macro_find_index()
    table.cell(macroPanel, 0, 0, "Macro thesis fleet", text_color=color.white, text_size=size.small)
    if idx < 0
        table.cell(macroPanel, 0, 1, "No feed entry for this chart symbol.", text_color=color.new(#888888, 0), text_size=size.tiny)
        table.cell(macroPanel, 0, 2, str.tostring(array.size(MACRO_TV_KEYS)) + " symbols mapped in this release.", text_color=color.new(#888888, 0), text_size=size.tiny)
    else
        dirCode = array.get(MACRO_DIR, idx)
        room = array.get(MACRO_ROOM, idx)
        table.cell(macroPanel, 0, 1, array.get(MACRO_NAME, idx), text_color=color.white, text_size=size.small)
        table.cell(macroPanel, 0, 2, f_macro_dir_label(dirCode) + " · " + str.tostring(room, "#") + "% room · " + array.get(MACRO_ROOM_BAND, idx), text_color=f_macro_dir_color(dirCode), text_size=size.tiny)
        table.cell(macroPanel, 0, 3, array.get(MACRO_STRENGTH, idx), text_color=color.new(#888888, 0), text_size=size.tiny)
        leanText = array.get(MACRO_LEAN, idx)
        if str.length(leanText) > 0
            table.cell(macroPanel, 0, 4, leanText, text_color=color.new(#888888, 0), text_size=size.tiny)
            table.cell(macroPanel, 0, 5, array.get(MACRO_CAUSE, idx), text_color=color.new(#ffffff, 0), text_size=size.tiny)
        else
            table.cell(macroPanel, 0, 4, array.get(MACRO_CAUSE, idx), text_color=color.new(#ffffff, 0), text_size=size.tiny)
            table.cell(macroPanel, 0, 5, "", text_color=color.new(#111110, 0), text_size=size.tiny)
````
