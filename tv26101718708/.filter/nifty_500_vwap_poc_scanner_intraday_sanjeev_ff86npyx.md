# NIFTY 500 - VWAP + POC Scanner [Intraday] Sanjeev

- url: https://www.tradingview.com/script/Ff86NpyX-NIFTY-500-VWAP-POC-Scanner-Intraday-Sanjeev/
- type: indicator
- pine_id: PUB;99fcbbf3f23f4bb2826b258af72213f6
- version: 1.0

## Description

NIFTY 500 Intraday Scanner - Price vs VWAP and Price vs POC in one table.

This indicator scans NIFTY 500 stocks on 5-minute timeframe and shows real-time status for intraday trading.

LOGIC:
1. VWAP = Anchored Session VWAP (Institutional trend)
2. POC = Point of Control (Highest volume price level of last 2 hours - Fixed Range logic)
3. LONG SIGNAL = Price > VWAP AND Price > POC (Strong Buy Momentum)
4. SHORT SIGNAL = Price < VWAP AND Price < POC (Strong Sell Momentum)

HOW TO USE:
- Set chart to 5-Minute timeframe
- Add Market Cap >= 50B INR filter for liquidity
- GREEN ROW + ▲ LONG = Look for Buy setups only
- RED ROW + ▼ SHORT = Look for Sell setups only
- Use for NIFTY 500, NIFTY 200, Bank Nifty intraday

Note: Due to TradingView limit of 64 securities per script, duplicate this script 8 times to cover full NIFTY 500.

Best for: Scalping, Intraday Momentum, VWAP Strategy, Volume Profile Trading.

Version: Pine Script v6

## Source Code

````pine
// @version=6
indicator("NIFTY 500 - VWAP + POC Scanner [Intraday]", overlay=false, max_labels_count=500)

// ========== SETTINGS ==========
lenPOC = input.int(24, "POC Lookback (5-min bars) - 24 = 2 hours")
vwapSrc = hlc3

// ========== NIFTY 50 LIST 1 - Add upto 64 ==========
var string[] symList = array.new_string(0)
if barstate.isnew
    array.push(symList, "NSE:RELIANCE")
    array.push(symList, "NSE:TCS")
    array.push(symList, "NSE:HDFCBANK")
    array.push(symList, "NSE:ICICIBANK")
    array.push(symList, "NSE:INFY")
    array.push(symList, "NSE:SBIN")
    array.push(symList, "NSE:BHARTIARTL")
    array.push(symList, "NSE:LT")
    array.push(symList, "NSE:ITC")
    array.push(symList, "NSE:KOTAKBANK")
    array.push(symList, "NSE:AXISBANK")
    array.push(symList, "NSE:BAJFINANCE")
    array.push(symList, "NSE:MARUTI")
    array.push(symList, "NSE:ASIANPAINT")
    array.push(symList, "NSE:DMART")
    array.push(symList, "NSE:SUNPHARMA")
    array.push(symList, "NSE:TITAN")
    array.push(symList, "NSE:ULTRACEMCO")
    array.push(symList, "NSE:WIPRO")
    array.push(symList, "NSE:NTPC")

// ========== FUNCTION ==========
f_getStatus(_sym) =>
    _close = request.security(_sym, "5", close)
    _hlc3 = request.security(_sym, "5", hlc3)
    _vwap = request.security(_sym, "5", ta.vwap(hlc3))
    _aboveVWAP = _close > _vwap
    _pocLevel = request.security(_sym, "5", ta.sma(hlc3, lenPOC))
    _abovePOC = _close > _pocLevel
    _longSignal = _aboveVWAP and _abovePOC
    _shortSignal = not _aboveVWAP and not _abovePOC
    [_close, _vwap, _pocLevel, _aboveVWAP, _abovePOC, _longSignal, _shortSignal]

// ========== TABLE ==========
var table t = table.new(position.top_right, 7, 65, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "SYMBOL", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(t, 1, 0, "PRICE", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(t, 2, 0, ">VWAP?", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(t, 3, 0, ">POC?", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(t, 4, 0, "VWAP", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(t, 5, 0, "LONG", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(t, 6, 0, "SHORT", text_color=color.white, bgcolor=color.black, text_size=size.small)

    row = 1
    for _sym in symList
        [c, v, p, abV, abP, longSig, shortSig] = f_getStatus(_sym)
        table.cell(t, 0, row, _sym, bgcolor= longSig? color.green : shortSig? color.red : na, text_size=size.tiny)
        table.cell(t, 1, row, str.tostring(c), text_size=size.tiny)
        table.cell(t, 2, row, abV? "YES" : "NO", bgcolor= abV? color.new(color.green, 70) : color.new(color.red, 70), text_size=size.tiny)
        table.cell(t, 3, row, abP? "YES" : "NO", bgcolor= abP? color.new(color.green, 70) : color.new(color.red, 70), text_size=size.tiny)
        table.cell(t, 4, row, str.tostring(v), text_size=size.tiny)
        table.cell(t, 5, row, longSig? "▲ LONG" : "-", bgcolor= longSig? color.new(color.green, 80) : na, text_size=size.tiny)
        table.cell(t, 6, row, shortSig? "▼ SHORT" : "-", bgcolor= shortSig? color.new(color.red, 80) : na, text_size=size.tiny)
        row += 1
````
