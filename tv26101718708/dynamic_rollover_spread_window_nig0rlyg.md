# Dynamic Rollover & Spread Window

- url: https://www.tradingview.com/script/NIg0rlYG-Dynamic-Rollover-Spread-Window/
- type: indicator
- pine_id: PUB;7ca2b99ccbd94a118e4ff2ce0fa2742a
- version: 1.0

## Description

[b]Dynamic Rollover & High Spread Zones[/b]
If you trade across different asset classes, you know that daily rollovers, CFD maintenance breaks, and weekly opens carry massive spread widening and low liquidity. Getting caught in a trade during these windows often leads to unnecessary slippage or getting stopped out by the spread alone.
This indicator automatically highlights these high-risk liquidity gaps directly on your chart. Instead of manually drawing time boxes or switching indicator settings every time you change tickers, the script reads what you are trading and adapts instantly.
The Hidden Cost of High Spreads
The spread is the difference between the Bid (sell) price and the Ask (buy) price. During rollover windows and market opens, institutional liquidity dries up. To protect themselves, brokers widen this spread dramatically—sometimes inflating a standard 1-pip spread to 15 or 20 pips.

[b]This impacts your trading in two fatal ways:[/b]
[list]
[*]
[/list]Bad Entries: If you execute a market order during a high-spread window, you are forced to pay that inflated premium. You instantly start the trade in a much deeper drawdown, meaning the market has to move significantly further in your direction just for you to break even.
[list]
[*]
[/list]Phantom Stop-Outs: Stop-loss orders are triggered by the Bid or Ask price, not necessarily the mid-price you see on the chart. If the spread widens enough, it can tag your stop-loss even if the actual market price hasn't moved.

[b]A Simple Example:[/b] Imagine you are in a short position on EUR/USD. The current price on the chart is 1.1000, and your stop-loss is placed 10 pips above at 1.1010. Normally, the spread is 1 pip.

At 17:00 NY time (rollover), the broker widens the spread to 15 pips. Even though the chart price remains exactly at 1.1000, the Ask price instantly jumps to 1.1015. Your stop-loss is triggered, closing you out for a loss. Five minutes later, the spread returns to normal, and EUR/USD drops 50 pips in your favor—but you are already out of the trade.

[b]Key Features:[/b]
[list]
[*]
[/list][b]Dynamic Asset Detection:[/b] The script automatically detects if you are viewing a Forex pair, an Index (futures or CFD), or a Commodity. It then applies the correct low-liquidity window for that specific market.
[list]
[*]
[/list][b]Daily Rollovers vs. Weekly Opens:[/b] Daily maintenance windows (Monday–Friday) are highlighted in one color, while the notoriously thin Sunday Weekly Opens are isolated and highlighted in another.
[list]
[*]
[/list][b]Timezone Proof:[/b] All session times are anchored strictly to the "America/New_York" timezone (EST/EDT). This ensures the windows remain 100% accurate year-round, completely bypassing local Daylight Saving Time shifts.
[list]
[*]
[/list][b]Built for Edge Cases:[/b] The detection engine accurately categorizes generically labeled CFD tickers (like NAS100, US30, XAUUSD) and standard CME Futures (ES, NQ, CL).

[b]Default Time Windows (NY Time):[/b]
[list]
[*]
[/list][b]Forex:[/b] 17:00–18:00 (Daily) | 17:00–19:00 (Sunday Open)
[list]
[*]
[/list][b]Indices: [/b]16:00–18:00 (Daily) | 18:00–19:00 (Sunday Open)
[list]
[*]
[/list][b]Commodities:[/b] 17:00–18:00 (Daily) | 18:00–19:00 (Sunday Open)

[b]Customization:[/b]
All session times and highlight colors are fully customizable in the indicator inputs to match your specific broker's server times if they differ from the standard exchange breaks.

## Source Code

````pine
//@version=6
indicator("Dynamic Rollover & Spread Window", overlay = true)

// -----------------------------------------------------------------------------
// USER INPUTS
// -----------------------------------------------------------------------------
grpDaily = "Daily Rollover Settings (NY Time, Mon-Fri)"
// Using :23456 restricts these strictly to Monday through Friday
fxDaily   = input.session("1700-1800:23456", title="Forex Daily Rollover", group=grpDaily)
idxDaily  = input.session("1600-1800:23456", title="Indices Low Liquidity", group=grpDaily)
comDaily  = input.session("1700-1800:23456", title="Commodities Break", group=grpDaily)
defDaily  = input.session("1700-1800:23456", title="Default Daily Window", group=grpDaily)
colorDaily = input.color(color.new(color.red, 85), title="Daily Highlight Color", group=grpDaily)

grpWeekly = "Weekly Open Settings (NY Time, Sunday)"
// Using :1 restricts these strictly to Sunday's market open
fxWeek    = input.session("1700-1900:1", title="Forex Weekly Open", group=grpWeekly)
idxWeek   = input.session("1800-1900:1", title="Indices Weekly Open", group=grpWeekly)
comWeek   = input.session("1800-1900:1", title="Commodities Weekly Open", group=grpWeekly)
defWeek   = input.session("1700-1900:1", title="Default Weekly Window", group=grpWeekly)
colorWeekly = input.color(color.new(color.orange, 80), title="Weekly Open Highlight Color", group=grpWeekly)

// -----------------------------------------------------------------------------
// CATEGORY DETECTION LOGIC
// -----------------------------------------------------------------------------
get_instrument_category() =>
    string cat = "Default"
    
    // Direct type matching
    if syminfo.type == "forex"
        cat := "Forex"
    else if syminfo.type == "index"
        cat := "Index"
    else if syminfo.type == "crypto"
        cat := "Default" 
        
    // CFD edge cases
    else if syminfo.type == "cfd"
        if str.contains(syminfo.ticker, "NAS") or str.contains(syminfo.ticker, "US30") or str.contains(syminfo.ticker, "US500") or str.contains(syminfo.ticker, "SPX") or str.contains(syminfo.ticker, "UK100") or str.contains(syminfo.ticker, "GER") or str.contains(syminfo.ticker, "DAX") or str.contains(syminfo.ticker, "NDX")
            cat := "Index"
        else if str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "XAG") or str.contains(syminfo.ticker, "WTI") or str.contains(syminfo.ticker, "BRENT") or str.contains(syminfo.ticker, "OIL")
            cat := "Commodity"
            
    // Futures edge cases
    else if syminfo.type == "futures"
        if str.contains(syminfo.ticker, "ES") or str.contains(syminfo.ticker, "NQ") or str.contains(syminfo.ticker, "YM") or str.contains(syminfo.ticker, "RTY")
            cat := "Index"
        else
            cat := "Commodity"
            
    cat

// -----------------------------------------------------------------------------
// SESSION ASSIGNMENT & HIGHLIGHTING
// -----------------------------------------------------------------------------
category = get_instrument_category()

activeDaily = switch category
    "Forex"     => fxDaily
    "Index"     => idxDaily
    "Commodity" => comDaily
    => defDaily

activeWeekly = switch category
    "Forex"     => fxWeek
    "Index"     => idxWeek
    "Commodity" => comWeek
    => defWeek

// Check if the current bar falls inside the assigned session windows 
inDailyWindow  = not na(time(timeframe.period, activeDaily, "America/New_York"))
inWeeklyWindow = not na(time(timeframe.period, activeWeekly, "America/New_York"))

// Apply the background colors
bgcolor(inDailyWindow ? colorDaily : na, title="Daily High Spread Window")
bgcolor(inWeeklyWindow ? colorWeekly : na, title="Weekly Open High Spread Window")
````
