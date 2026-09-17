<!-- tradingview-pine-id: PUB;4368bbcf87374f4db129a59f9e0f647f -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Global Macro Regime

Source: https://www.tradingview.com/script/tDChNs5m-Global-Macro-Regime/

## Description

The Global Macro Regime is a top-down macro nowcasting and portfolio allocation tool that provides a consolidated view of the market-implied macro regime. It independently evaluates 30 key global markets across equities, fixed income, commodities, and currencies to determine the prevailing macro regime, which informs the model’s portfolio preferences and regime-specific exposures. It also features built-in alerts and an integrated backtester that enable investors to monitor regime changes and evaluate asset performance across different macro environments.

At its core, the model aggregates 30 independent cross-asset market signals to identify shifts in the market’s growth and inflation outlook. Rather than relying on backward-looking economic data, the model derives these signals in real time from evolving trends across global markets. By focusing on growth and inflation, the model captures two of the primary macroeconomic forces driving asset prices. The four possible combinations of growth and inflation define four distinct macro regimes, each of which tends to favor different portfolio preferences and exposures:

[*]Goldilocks (Growth ↑, Inflation ↓): Improving growth with low/declining inflation.
[*]Reflation (Growth ↑, Inflation ↑): Improving growth with high/rising inflation.
[*]Inflation (Growth ↓, Inflation ↑): Deteriorating growth with high/rising inflation.
[*]Deflation (Growth ↓, Inflation ↓): Deteriorating growth with low/declining inflation.

Goldilocks and Reflation represent Risk-On regimes, while Inflation and Deflation represent Risk-Off regimes. Each of the 30 selected markets is evaluated independently as either a growth or inflation signal. Markets signaling improving growth contribute to both Goldilocks and Reflation, while markets signaling deteriorating growth contribute to both Inflation and Deflation. Markets signaling high/rising inflation contribute to both Reflation and Inflation, while markets signaling low/declining inflation contribute to both Goldilocks and Deflation. The selected markets are grouped into equities (10), fixed income (10), commodities (6), and currencies (4):

[*]Equities = S&P 500 Index (SPX), Russell 2000 Index (RUT), STOXX Europe 600 Index (SXXP), Nikkei 225 Index (NI225), Hang Seng Index (HSI), MSCI Emerging Markets Index Futures (MME), High Beta / Low Volatility Ratio (SPHB/SPLV), Cyclicals / Defensives Ratio (XLY/XLP), S&P 500 Volatility Index (VIX), and 3M Implied Correlation Index (COR3M).
[*]Fixed Income = US 2Y Treasury Yield, US 10Y Treasury Yield, German 10Y Bund Yield, UK 10Y Gilt Yield, Japan 10Y JGB Yield, US 10Y Breakeven Inflation Rate, US CCC Distressed Index Option-Adjusted Spread, US High Yield Index Option-Adjusted Spread, US Investment Grade Corporate Index Option-Adjusted Spread, and US Bond Volatility Index (MOVE).
[*]Commodities = Brent Crude Oil Futures (BRN), Agricultural Commodities (DBA), Industrial Metals (DBB), Copper Futures (HG), Silver / Gold Ratio (SI/GC), and CME Bitcoin Futures.
[*]Currencies = US Dollar Index (DXY), Australian Dollar / US Dollar (AUDUSD), British Pound / US Dollar (GBPUSD), and Euro / US Dollar (EURUSD).

Each market signal is derived independently using either a volatility-adjusted moving-average crossover, a volatility-based adaptive trailing stop, or a combination of both. The signals are then aggregated and normalized into percentage scores representing each regime’s share of total signals, with optional smoothing over the specified signal length to reduce noise. The regime receiving the greatest confirmation across global markets is identified as the dominant macro regime and translated into portfolio preferences displayed in the regime preference table:

[*]Goldilocks Preferences = Risk-On > Risk-Off, High Beta > Low Beta, Cyclicals > Defensives, International < US Equities, SMID Caps < Large Caps, Short Rates > Long Rates, Spreads > Treasuries, High Yield > Low Yield, Beta FX > US Dollar, Metals > Energy, and Bitcoin > Gold.
[*]Reflation Preferences = Risk-On > Risk-Off, High Beta > Low Beta, Cyclicals > Defensives, International > US Equities, SMID Caps > Large Caps, Short Rates > Long Rates, Spreads > Treasuries, High Yield > Low Yield, Beta FX > US Dollar, Metals > Energy, and Bitcoin > Gold.
[*]Inflation Preferences = Risk-On < Risk-Off, High Beta < Low Beta, Cyclicals < Defensives, International < US Equities, SMID Caps < Large Caps, Short Rates > Long Rates, Spreads < Treasuries, High Yield < Low Yield, Beta FX < US Dollar, Metals < Energy, and Bitcoin < Gold.
[*]Deflation Preferences = Risk-On < Risk-Off, High Beta < Low Beta, Cyclicals < Defensives, International < US Equities, SMID Caps < Large Caps, Short Rates < Long Rates, Spreads < Treasuries, High Yield < Low Yield, Beta FX < US Dollar, Metals > Energy, and Bitcoin < Gold.

The model further translates these portfolio preferences into specific exposures across equities, fixed income, commodities, and currencies. The selected exposures have been systematically backtested across the four macro regimes, dating back as far as January 1996, to identify those exhibiting the strongest risk-adjusted performance and most consistent directionally aligned trending behavior within each asset class. The resulting exposure lists provide a more granular view of the model’s broader portfolio preferences based on historically observed relationships:

[*]Goldilocks Exposures = Equity sectors include Communication Services (XLC), Technology (XLK), Financials (XLF), Industrials (XLI), Consumer Discretionary (XLY), Materials (XLB), and Real Estate (VNQ). Equity factors include S&P 500 (SPY), Nasdaq 100 (QQQ), High Beta (SPHB), Momentum (MTUM), Quality (QUAL), Growth (IWF), and Value (IWD). Fixed income includes High Yield Bonds (HYG), Investment Grade Bonds (LQD), and Convertible Bonds (CWB). Commodities include Bitcoin (BTC), Industrial Metals (DBB), Metal Producers (PICK), Gold (GLD), Gold Miners (GDX), Silver (SLV), Silver Miners (SIL), Copper (CPER), Copper Miners (COPX), Uranium (SRUUF), and Uranium Miners (URNM). Currencies include Australian Dollar (FXA), British Pound (FXB), and Euro (FXE).
[*]Reflation Exposures = Equity sectors include Energy (XLE), Communication Services (XLC), Technology (XLK), Financials (XLF), Industrials (XLI), Consumer Discretionary (XLY), Materials (XLB), and Real Estate (VNQ). Equity factors include Global Equities (ACWI), International Equities (ACWX), S&P 500 (SPY), Nasdaq 100 (QQQ), Emerging Markets (EEM), High Beta (SPHB), Mid Caps (IWR), Small Caps (IWM), Momentum (MTUM), Quality (QUAL), Growth (IWF), Value (IWD), Equal Weight (RSP), Global Infrastructure (IGF), and International Real Estate (IFGL). Fixed income includes High Yield Bonds (HYG), Convertible Bonds (CWB), Private Credit (BIZD), and Emerging Market Bonds (EMB). Commodities include Bitcoin (BTC), Commodities (DBC), Industrial Metals (DBB), Metal Producers (PICK), Crude Oil (USO), Agriculture (DBA), Agriculture Producers (VEGI), Gold (GLD), Gold Miners (GDX), Silver (SLV), Silver Miners (SIL), Copper (CPER), Copper Miners (COPX), Uranium (SRUUF), and Uranium Miners (URNM). Currencies include Australian Dollar (FXA), Canadian Dollar (FXC), British Pound (FXB), and Euro (FXE).
[*]Inflation Exposures = Equity sectors include Energy (XLE), Consumer Staples (XLP), Utilities (XLU), and Health Care (XLV). Equity factors include Low Volatility (SPLV). Fixed income includes 1-3 Month Treasury Bills (BIL). Commodities include Commodities (DBC), Crude Oil (USO), Agriculture (DBA), and Gold (GLD). Currencies include US Dollar (UUP).
[*]Deflation Exposures = Equity sectors include Consumer Staples (XLP), Utilities (XLU), and Health Care (XLV). Equity factors include Low Volatility (SPLV) and High Dividend (SPHD). Fixed income includes 1-3 Year Treasuries (SHY), 7-10 Year Treasuries (IEF), 20+ Year Treasuries (TLT), US Aggregate Bonds (AGG), Mortgage-Backed Securities (MBB), and International Aggregate Bonds (BNDX). Commodities include Gold (GLD). Currencies include US Dollar (UUP) and Japanese Yen (FXY).

The model includes a built-in alert system that notifies investors in real time when the dominant macro regime changes and provides the corresponding exposures for the new regime. It also features an integrated backtesting engine that can be enabled in the menu to evaluate asset performance across the macro regimes. Users can assign an asset to each regime, with the backtest automatically rotating into the corresponding asset whenever that regime becomes dominant. If one or more assets are assigned, any unassigned regimes are treated as cash. If no assets are assigned, the chart ticker is assigned to Goldilocks and Reflation, while Inflation and Deflation are treated as cash. The backtest reports the following performance metrics:

[*]CAGR = Compounded Annual Growth Rate.
[*]Excess = CAGR in excess of buy-and-hold.
[*]Sharpe = CAGR per unit of standard deviation.
[*]Sortino = CAGR per unit of downside deviation.
[*]Calmar = CAGR relative to maximum drawdown.
[*]Max DD = Largest peak-to-trough decline in value.
[*]Alpha (α) = Excess annualized risk-adjusted returns.
[*]Win Rate = Ratio of profitable trades to total trades.
[*]Profit Factor = Total gross profit per unit of losses.
[*]Expectancy = Average expected return per trade.
[*]Turnover = Average annualized change in exposure.

The indicator is designed with flexibility in mind, allowing users to select the backtest period, signal methodology, preferred trend type, volatility type, and the individual markets included in the regime calculation. Supported moving-average types include the Exponential Moving Average (EMA), Simple Moving Average (SMA), Wilder’s Moving Average (RMA), and Weighted Moving Average (WMA). Supported volatility types include the Average True Range (ATR), Standard Deviation (SD), and Mean Absolute Deviation (MAD). The table follows an intuitive color-coded logic that allows for quick performance comparison against buy-and-hold (B&H):

[*]CAGR = Green indicates above 0%, while red indicates below 0%.
[*]Excess = Green indicates above 0%, while red indicates below 0%.
[*]Sharpe = Green indicates better than B&H, while red indicates worse.
[*]Sortino = Green indicates better than B&H, while red indicates worse.
[*]Calmar = Green indicates better than B&H, while red indicates worse.
[*]Max DD = Green indicates better than B&H, while red indicates worse.
[*]Alpha (α) = Green indicates above 0%, while red indicates below 0%.
[*]Win Rate = Green indicates above 50%, while red indicates below 50%.
[*]Profit Factor = Green indicates above 2, while red indicates below 1.
[*]Expectancy = Green indicates above 0%, while red indicates below 0%.

In summary, the Global Macro Regime is a comprehensive market-based macro framework designed to identify the prevailing macro regime. By combining 30 independent cross-asset market signals, the model translates the dominant macro regime into portfolio preferences and regime-specific exposures based on historical relationships that may not persist under future market conditions as market dynamics and asset-specific characteristics evolve over time. Historical coverage also varies across the 30 selected markets, with regime signals prior to 2006 based on progressively fewer markets and therefore requiring more cautious interpretation.

---

## Source Code

````pine
// © QuantitativeAlpha
//@version=6
indicator(title = 'Global Macro Regime', shorttitle = 'GMR', overlay = false)
signal_type = input.string('Trend', title = 'Signal Type', options = ['Trend', 'Volatility', 'Combined'])
cross_type = input.string('EMA', title = 'Trend Type', options = ['EMA', 'SMA', 'RMA', 'WMA'])
fast_input = input.int(30, title = 'Fast Length', minval = 1)
slow_input = input.int(60, title = 'Slow Length', minval = 2)
cross_margin = input.float(0.3, title = 'Trend Margin', minval = 0.0)
vol_type = input.string('ATR', title = 'Volatility Type', options = ['ATR', 'SD', 'MAD'])
vol_input = input.int(10, title = 'Stop Length', minval = 1)
vol_factor = input.float(3.0, title = 'Stop Factor', minval = 0.1)
smooth_input = input.int(1, title = 'Signal Length', minval = 0)
use_spx = input.bool(true, title = 'S&P 500 Index')
use_rut = input.bool(true, title = 'Russell 2000 Index')
use_sxxp = input.bool(true, title = 'STOXX 600 Index')
use_ni225 = input.bool(true, title = 'Nikkei 225 Index')
use_hsi = input.bool(true, title = 'Hang Seng Index')
use_mme1 = input.bool(true, title = 'Emerging Markets Index')
use_beta = input.bool(true, title = 'High Beta / Low Volatility')
use_cycl = input.bool(true, title = 'Cyclicals / Defensives')
use_vix = input.bool(true, title = 'S&P 500 Volatility Index')
use_move = input.bool(true, title = 'US Bond Volatility Index')
use_cor3m = input.bool(true, title = '3M Implied Correlation')
use_brn1 = input.bool(true, title = 'Brent Crude Oil Futures')
use_dba = input.bool(true, title = 'Agricultural Commodities')
use_dbb = input.bool(true, title = 'Industrial Metals')
use_si1gc1 = input.bool(true, title = 'Silver / Gold Ratio')
use_hg1 = input.bool(true, title = 'Copper Futures')
use_btc = input.bool(true, title = 'Bitcoin Futures')
use_dxy = input.bool(true, title = 'US Dollar Index')
use_audusd = input.bool(true, title = 'AUD/USD FX Rate')
use_eurusd = input.bool(true, title = 'EUR/USD FX Rate')
use_gbpusd = input.bool(true, title = 'GBP/USD FX Rate')
use_eu10y = input.bool(true, title = 'German 10Y Bund Yield')
use_gb10y = input.bool(true, title = 'UK 10Y Gilt Yield')
use_jp10y = input.bool(true, title = 'Japan 10Y JGB Yield')
use_us02y = input.bool(true, title = 'US 2Y Treasury Yield')
use_us10y = input.bool(true, title = 'US 10Y Treasury Yield')
use_t10yie = input.bool(true, title = 'US 10Y Breakeven Rate')
use_dyoas = input.bool(true, title = 'US Distressed Index OAS')
use_hyoas = input.bool(true, title = 'US High Yield Index OAS')
use_igoas = input.bool(true, title = 'US Corporate Index OAS')
goldilocks_asset_input = input.symbol('', title = 'Goldilocks Asset')
reflation_asset_input = input.symbol('', title = 'Reflation Asset')
inflation_asset_input = input.symbol('', title = 'Inflation Asset')
deflation_asset_input = input.symbol('', title = 'Deflation Asset')
neutral_active = input.bool(true, title = 'Enable Neutral Regimes')
backtest_active = input.bool(false, title = 'Show Backtest Statistics')
start_month_name = input.string('Jan', title = 'Start Month', options = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])
start_year = input.int(2008, title = 'Start Year')
fee_input = input.float(0.1, title = 'Fees (%)', minval = 0.0)
price_type = input.string('Open', title = 'Entry/Exit', options = ['Open', 'Close'])
width_input = input.int(10, title = 'Table Width', minval = 1)
table_input = input.string('Low', title = 'Table Position', options = ['High', 'Middle', 'Low'])
table_position = table_input == 'High' ? position.top_right : table_input == 'Middle' ? position.middle_right : position.bottom_right
smooth = smooth_input == 0 ? 1 : smooth_input
ma(src, length) =>
    cross_type == 'SMA' ? ta.sma(src, length) : cross_type == 'WMA' ? ta.wma(src, length) : cross_type == 'RMA' ? ta.rma(src, length) : ta.ema(src, length)
vol_stop(src, volatility, factor) =>
    var float max_val = na
    var float min_val = na
    var bool up_trend = true
    var float stop = na
    if not na(src) and not na(volatility)
        vol_m = factor * volatility
        max_val := na(max_val) ? src : math.max(max_val, src)
        min_val := na(min_val) ? src : math.min(min_val, src)
        stop := na(stop) ? src : up_trend ? math.max(stop, max_val - vol_m) : math.min(stop, min_val + vol_m)
        prev_up_trend = up_trend
        up_trend := src >= stop
        if up_trend != prev_up_trend
            max_val := src
            min_val := src
            stop := up_trend ? max_val - vol_m : min_val + vol_m
    [stop, up_trend]
signal_logic() =>
    fast_ma = ma(close, fast_input)
    slow_ma = ma(close, slow_input)
    diff = fast_ma - slow_ma
    atr_value = ta.atr(slow_input)
    bull_cross = diff > cross_margin * atr_value
    bear_cross = diff < -cross_margin * atr_value
    cross_score = bull_cross ? 1 : bear_cross ? -1 : 0
    volatility = vol_type == 'SD' ? ta.stdev(close, vol_input) : vol_type == 'MAD' ? ta.sma(math.abs(close - ta.sma(close, vol_input)), vol_input) : ta.atr(vol_input)
    [v_stop, up_trend] = vol_stop(close, volatility, vol_factor)
    vol_score = up_trend ? 1 : -1
    ready_cross = not na(diff) and not na(atr_value)
    ready_vol = not na(volatility) and not na(v_stop)
    ready = signal_type == 'Trend' ? ready_cross : signal_type == 'Volatility' ? ready_vol : ready_cross and ready_vol
    total_score = signal_type == 'Trend' ? cross_score : signal_type == 'Volatility' ? vol_score : ready ? cross_score + vol_score : na
    bull = ready and (neutral_active ? total_score > 0 : total_score >= 0)
    bear = ready and total_score < 0
    [ready, bull, bear]
regime_contribution(valid, bull, bear, goldilocks, reflation, inflation, deflation) =>
    bull_active = valid and bull
    bear_active = valid and bear
    goldilocks_score = bull_active ? goldilocks : bear_active ? 1 - goldilocks : 0
    reflation_score = bull_active ? reflation : bear_active ? 1 - reflation : 0
    inflation_score = bull_active ? inflation : bear_active ? 1 - inflation : 0
    deflation_score = bull_active ? deflation : bear_active ? 1 - deflation : 0
    [goldilocks_score, reflation_score, inflation_score, deflation_score]
spx_ticker = ticker.inherit(syminfo.tickerid, 'TVC:SPX')
rut_ticker = ticker.inherit(syminfo.tickerid, 'TVC:RUT')
sxxp_ticker = ticker.inherit(syminfo.tickerid, 'TVC:SXXP')
ni225_ticker = ticker.inherit(syminfo.tickerid, 'TVC:NI225')
hsi_ticker = ticker.inherit(syminfo.tickerid, 'TVC:HSI')
mme1_ticker = ticker.inherit(syminfo.tickerid, 'ICEUS:MME1!')
beta_ticker = ticker.inherit(syminfo.tickerid, 'AMEX:SPHB/AMEX:SPLV')
cycl_ticker = ticker.inherit(syminfo.tickerid, 'AMEX:XLY/AMEX:XLP')
vix_ticker = ticker.inherit(syminfo.tickerid, 'CBOE:VIX')
move_ticker = ticker.inherit(syminfo.tickerid, 'TVC:MOVE')
cor3m_ticker = ticker.inherit(syminfo.tickerid, 'CBOE:COR3M')
brn1_ticker = ticker.inherit(syminfo.tickerid, 'ICEEUR:BRN1!')
dba_ticker = ticker.inherit(syminfo.tickerid, 'AMEX:DBA')
dbb_ticker = ticker.inherit(syminfo.tickerid, 'AMEX:DBB')
si1gc1_ticker = ticker.inherit(syminfo.tickerid, 'COMEX:SI1!/COMEX:GC1!')
hg1_ticker = ticker.inherit(syminfo.tickerid, 'COMEX:HG1!')
btc_ticker = ticker.inherit(syminfo.tickerid, 'CME:BTC1!')
dxy_ticker = ticker.inherit(syminfo.tickerid, 'TVC:DXY')
audusd_ticker = ticker.inherit(syminfo.tickerid, 'FX_IDC:AUDUSD')
eurusd_ticker = ticker.inherit(syminfo.tickerid, 'FX_IDC:EURUSD')
gbpusd_ticker = ticker.inherit(syminfo.tickerid, 'FX_IDC:GBPUSD')
eu10y_ticker = ticker.inherit(syminfo.tickerid, 'TVC:EU10Y')
gb10y_ticker = ticker.inherit(syminfo.tickerid, 'TVC:GB10Y')
jp10y_ticker = ticker.inherit(syminfo.tickerid, 'TVC:JP10Y')
us02y_ticker = ticker.inherit(syminfo.tickerid, 'TVC:US02Y')
us10y_ticker = ticker.inherit(syminfo.tickerid, 'TVC:US10Y')
t10yie_ticker = ticker.inherit(syminfo.tickerid, 'FRED:T10YIE')
dyoas_ticker = ticker.inherit(syminfo.tickerid, 'FRED:BAMLH0A3HYC')
hyoas_ticker = ticker.inherit(syminfo.tickerid, 'FRED:BAMLH0A0HYM2')
igoas_ticker = ticker.inherit(syminfo.tickerid, 'FRED:BAMLC0A0CM')
[spx_valid_raw, spx_bull, spx_bear] = request.security(spx_ticker, 'D', signal_logic())
[rut_valid_raw, rut_bull, rut_bear] = request.security(rut_ticker, 'D', signal_logic())
[sxxp_valid_raw, sxxp_bull, sxxp_bear] = request.security(sxxp_ticker, 'D', signal_logic())
[ni225_valid_raw, ni225_bull, ni225_bear] = request.security(ni225_ticker, 'D', signal_logic())
[hsi_valid_raw, hsi_bull, hsi_bear] = request.security(hsi_ticker, 'D', signal_logic())
[mme1_valid_raw, mme1_bull, mme1_bear] = request.security(mme1_ticker, 'D', signal_logic())
[beta_valid_raw, beta_bull, beta_bear] = request.security(beta_ticker, 'D', signal_logic())
[cycl_valid_raw, cycl_bull, cycl_bear] = request.security(cycl_ticker, 'D', signal_logic())
[vix_valid_raw, vix_bull, vix_bear] = request.security(vix_ticker, 'D', signal_logic())
[move_valid_raw, move_bull, move_bear] = request.security(move_ticker, 'D', signal_logic())
[cor3m_valid_raw, cor3m_bull, cor3m_bear] = request.security(cor3m_ticker, 'D', signal_logic())
[brn1_valid_raw, brn1_bull, brn1_bear] = request.security(brn1_ticker, 'D', signal_logic())
[dba_valid_raw, dba_bull, dba_bear] = request.security(dba_ticker, 'D', signal_logic())
[dbb_valid_raw, dbb_bull, dbb_bear] = request.security(dbb_ticker, 'D', signal_logic())
[si1gc1_valid_raw, si1gc1_bull, si1gc1_bear] = request.security(si1gc1_ticker, 'D', signal_logic())
[hg1_valid_raw, hg1_bull, hg1_bear] = request.security(hg1_ticker, 'D', signal_logic())
[btc_valid_raw, btc_bull, btc_bear] = request.security(btc_ticker, 'D', signal_logic())
[dxy_valid_raw, dxy_bull, dxy_bear] = request.security(dxy_ticker, 'D', signal_logic())
[audusd_valid_raw, audusd_bull, audusd_bear] = request.security(audusd_ticker, 'D', signal_logic())
[eurusd_valid_raw, eurusd_bull, eurusd_bear] = request.security(eurusd_ticker, 'D', signal_logic())
[gbpusd_valid_raw, gbpusd_bull, gbpusd_bear] = request.security(gbpusd_ticker, 'D', signal_logic())
[eu10y_valid_raw, eu10y_bull, eu10y_bear] = request.security(eu10y_ticker, 'D', signal_logic())
[gb10y_valid_raw, gb10y_bull, gb10y_bear] = request.security(gb10y_ticker, 'D', signal_logic())
[jp10y_valid_raw, jp10y_bull, jp10y_bear] = request.security(jp10y_ticker, 'D', signal_logic())
[us02y_valid_raw, us02y_bull, us02y_bear] = request.security(us02y_ticker, 'D', signal_logic())
[us10y_valid_raw, us10y_bull, us10y_bear] = request.security(us10y_ticker, 'D', signal_logic())
[t10yie_valid_raw, t10yie_bull, t10yie_bear] = request.security(t10yie_ticker, 'D', signal_logic())
[dyoas_valid_raw, dyoas_bull, dyoas_bear] = request.security(dyoas_ticker, 'D', signal_logic())
[hyoas_valid_raw, hyoas_bull, hyoas_bear] = request.security(hyoas_ticker, 'D', signal_logic())
[igoas_valid_raw, igoas_bull, igoas_bear] = request.security(igoas_ticker, 'D', signal_logic())
custom_assets = goldilocks_asset_input != '' or reflation_asset_input != '' or inflation_asset_input != '' or deflation_asset_input != ''
goldilocks_asset_active = custom_assets ? goldilocks_asset_input != '' : true
reflation_asset_active = custom_assets ? reflation_asset_input != '' : true
inflation_asset_active = custom_assets ? inflation_asset_input != '' : false
deflation_asset_active = custom_assets ? deflation_asset_input != '' : false
goldilocks_asset = custom_assets ? goldilocks_asset_input : syminfo.tickerid
reflation_asset = custom_assets ? reflation_asset_input : syminfo.tickerid
inflation_asset = inflation_asset_input
deflation_asset = deflation_asset_input
goldilocks_request_symbol = goldilocks_asset_input != '' ? goldilocks_asset_input : syminfo.tickerid
reflation_request_symbol = reflation_asset_input != '' ? reflation_asset_input : syminfo.tickerid
inflation_request_symbol = inflation_asset_input != '' ? inflation_asset_input : syminfo.tickerid
deflation_request_symbol = deflation_asset_input != '' ? deflation_asset_input : syminfo.tickerid
[goldilocks_open_req, goldilocks_close_req] = request.security(goldilocks_request_symbol, 'D', [open, close])
[reflation_open_req, reflation_close_req] = request.security(reflation_request_symbol, 'D', [open, close])
[inflation_open, inflation_close] = request.security(inflation_request_symbol, 'D', [open, close])
[deflation_open, deflation_close] = request.security(deflation_request_symbol, 'D', [open, close])
goldilocks_open = custom_assets ? goldilocks_open_req : open
goldilocks_close = custom_assets ? goldilocks_close_req : close
reflation_open = custom_assets ? reflation_open_req : open
reflation_close = custom_assets ? reflation_close_req : close
goldilocks_price = price_type == 'Open' ? goldilocks_open : goldilocks_close
reflation_price = price_type == 'Open' ? reflation_open : reflation_close
inflation_price = price_type == 'Open' ? inflation_open : inflation_close
deflation_price = price_type == 'Open' ? deflation_open : deflation_close
benchmark_price = price_type == 'Open' ? open : close
goldilocks_asset_ready = goldilocks_asset_active and not na(goldilocks_price) and not na(goldilocks_price[1])
reflation_asset_ready = reflation_asset_active and not na(reflation_price) and not na(reflation_price[1])
inflation_asset_ready = inflation_asset_active and not na(inflation_price) and not na(inflation_price[1])
deflation_asset_ready = deflation_asset_active and not na(deflation_price) and not na(deflation_price[1])
valid_spx = use_spx and spx_valid_raw
valid_rut = use_rut and rut_valid_raw
valid_sxxp = use_sxxp and sxxp_valid_raw
valid_ni225 = use_ni225 and ni225_valid_raw
valid_hsi = use_hsi and hsi_valid_raw
valid_mme1 = use_mme1 and mme1_valid_raw
valid_beta = use_beta and beta_valid_raw
valid_cycl = use_cycl and cycl_valid_raw
valid_vix = use_vix and vix_valid_raw
valid_move = use_move and move_valid_raw
valid_cor3m = use_cor3m and cor3m_valid_raw
valid_brn1 = use_brn1 and brn1_valid_raw
valid_dba = use_dba and dba_valid_raw
valid_dbb = use_dbb and dbb_valid_raw
valid_si1gc1 = use_si1gc1 and si1gc1_valid_raw
valid_hg1 = use_hg1 and hg1_valid_raw
valid_btc = use_btc and btc_valid_raw
valid_dxy = use_dxy and dxy_valid_raw
valid_audusd = use_audusd and audusd_valid_raw
valid_eurusd = use_eurusd and eurusd_valid_raw
valid_gbpusd = use_gbpusd and gbpusd_valid_raw
valid_eu10y = use_eu10y and eu10y_valid_raw
valid_gb10y = use_gb10y and gb10y_valid_raw
valid_jp10y = use_jp10y and jp10y_valid_raw
valid_us02y = use_us02y and us02y_valid_raw
valid_us10y = use_us10y and us10y_valid_raw
valid_t10yie = use_t10yie and t10yie_valid_raw
valid_dyoas = use_dyoas and dyoas_valid_raw
valid_hyoas = use_hyoas and hyoas_valid_raw
valid_igoas = use_igoas and igoas_valid_raw
model_available = valid_spx or valid_rut or valid_sxxp or valid_ni225 or valid_hsi or valid_mme1 or valid_beta or valid_cycl or valid_vix or valid_move or valid_cor3m or valid_brn1 or valid_dba or valid_dbb or valid_si1gc1 or valid_hg1 or valid_btc or valid_dxy or valid_audusd or valid_eurusd or valid_gbpusd or valid_eu10y or valid_gb10y or valid_jp10y or valid_us02y or valid_us10y or valid_t10yie or valid_dyoas or valid_hyoas or valid_igoas
[spx_gold, spx_refl, spx_infl, spx_defl] = regime_contribution(valid_spx, spx_bull, spx_bear, 1, 1, 0, 0)
[rut_gold, rut_refl, rut_infl, rut_defl] = regime_contribution(valid_rut, rut_bull, rut_bear, 1, 1, 0, 0)
[sxxp_gold, sxxp_refl, sxxp_infl, sxxp_defl] = regime_contribution(valid_sxxp, sxxp_bull, sxxp_bear, 1, 1, 0, 0)
[ni225_gold, ni225_refl, ni225_infl, ni225_defl] = regime_contribution(valid_ni225, ni225_bull, ni225_bear, 1, 1, 0, 0)
[hsi_gold, hsi_refl, hsi_infl, hsi_defl] = regime_contribution(valid_hsi, hsi_bull, hsi_bear, 1, 1, 0, 0)
[mme1_gold, mme1_refl, mme1_infl, mme1_defl] = regime_contribution(valid_mme1, mme1_bull, mme1_bear, 1, 1, 0, 0)
[beta_gold, beta_refl, beta_infl, beta_defl] = regime_contribution(valid_beta, beta_bull, beta_bear, 1, 1, 0, 0)
[cycl_gold, cycl_refl, cycl_infl, cycl_defl] = regime_contribution(valid_cycl, cycl_bull, cycl_bear, 1, 1, 0, 0)
[vix_gold, vix_refl, vix_infl, vix_defl] = regime_contribution(valid_vix, vix_bull, vix_bear, 0, 0, 1, 1)
[move_gold, move_refl, move_infl, move_defl] = regime_contribution(valid_move, move_bull, move_bear, 0, 0, 1, 1)
[cor3m_gold, cor3m_refl, cor3m_infl, cor3m_defl] = regime_contribution(valid_cor3m, cor3m_bull, cor3m_bear, 0, 0, 1, 1)
[brn1_gold, brn1_refl, brn1_infl, brn1_defl] = regime_contribution(valid_brn1, brn1_bull, brn1_bear, 0, 1, 1, 0)
[dba_gold, dba_refl, dba_infl, dba_defl] = regime_contribution(valid_dba, dba_bull, dba_bear, 0, 1, 1, 0)
[dbb_gold, dbb_refl, dbb_infl, dbb_defl] = regime_contribution(valid_dbb, dbb_bull, dbb_bear, 1, 1, 0, 0)
[si1gc1_gold, si1gc1_refl, si1gc1_infl, si1gc1_defl] = regime_contribution(valid_si1gc1, si1gc1_bull, si1gc1_bear, 1, 1, 0, 0)
[hg1_gold, hg1_refl, hg1_infl, hg1_defl] = regime_contribution(valid_hg1, hg1_bull, hg1_bear, 1, 1, 0, 0)
[btc_gold, btc_refl, btc_infl, btc_defl] = regime_contribution(valid_btc, btc_bull, btc_bear, 1, 1, 0, 0)
[dxy_gold, dxy_refl, dxy_infl, dxy_defl] = regime_contribution(valid_dxy, dxy_bull, dxy_bear, 0, 0, 1, 1)
[audusd_gold, audusd_refl, audusd_infl, audusd_defl] = regime_contribution(valid_audusd, audusd_bull, audusd_bear, 1, 1, 0, 0)
[eurusd_gold, eurusd_refl, eurusd_infl, eurusd_defl] = regime_contribution(valid_eurusd, eurusd_bull, eurusd_bear, 1, 1, 0, 0)
[gbpusd_gold, gbpusd_refl, gbpusd_infl, gbpusd_defl] = regime_contribution(valid_gbpusd, gbpusd_bull, gbpusd_bear, 1, 1, 0, 0)
[eu10y_gold, eu10y_refl, eu10y_infl, eu10y_defl] = regime_contribution(valid_eu10y, eu10y_bull, eu10y_bear, 0, 1, 1, 0)
[gb10y_gold, gb10y_refl, gb10y_infl, gb10y_defl] = regime_contribution(valid_gb10y, gb10y_bull, gb10y_bear, 0, 1, 1, 0)
[jp10y_gold, jp10y_refl, jp10y_infl, jp10y_defl] = regime_contribution(valid_jp10y, jp10y_bull, jp10y_bear, 0, 1, 1, 0)
[us02y_gold, us02y_refl, us02y_infl, us02y_defl] = regime_contribution(valid_us02y, us02y_bull, us02y_bear, 0, 1, 1, 0)
[us10y_gold, us10y_refl, us10y_infl, us10y_defl] = regime_contribution(valid_us10y, us10y_bull, us10y_bear, 0, 1, 1, 0)
[t10yie_gold, t10yie_refl, t10yie_infl, t10yie_defl] = regime_contribution(valid_t10yie, t10yie_bull, t10yie_bear, 0, 1, 1, 0)
[dyoas_gold, dyoas_refl, dyoas_infl, dyoas_defl] = regime_contribution(valid_dyoas, dyoas_bull, dyoas_bear, 0, 0, 1, 1)
[hyoas_gold, hyoas_refl, hyoas_infl, hyoas_defl] = regime_contribution(valid_hyoas, hyoas_bull, hyoas_bear, 0, 0, 1, 1)
[igoas_gold, igoas_refl, igoas_infl, igoas_defl] = regime_contribution(valid_igoas, igoas_bull, igoas_bear, 0, 0, 1, 1)
goldilocks_sum = spx_gold + rut_gold + sxxp_gold + ni225_gold + hsi_gold + mme1_gold + beta_gold + cycl_gold + vix_gold + move_gold + cor3m_gold + brn1_gold + dba_gold + dbb_gold + si1gc1_gold + hg1_gold + btc_gold + dxy_gold + audusd_gold + eurusd_gold + gbpusd_gold + eu10y_gold + gb10y_gold + jp10y_gold + us02y_gold + us10y_gold + t10yie_gold + dyoas_gold + hyoas_gold + igoas_gold
reflation_sum = spx_refl + rut_refl + sxxp_refl + ni225_refl + hsi_refl + mme1_refl + beta_refl + cycl_refl + vix_refl + move_refl + cor3m_refl + brn1_refl + dba_refl + dbb_refl + si1gc1_refl + hg1_refl + btc_refl + dxy_refl + audusd_refl + eurusd_refl + gbpusd_refl + eu10y_refl + gb10y_refl + jp10y_refl + us02y_refl + us10y_refl + t10yie_refl + dyoas_refl + hyoas_refl + igoas_refl
inflation_sum = spx_infl + rut_infl + sxxp_infl + ni225_infl + hsi_infl + mme1_infl + beta_infl + cycl_infl + vix_infl + move_infl + cor3m_infl + brn1_infl + dba_infl + dbb_infl + si1gc1_infl + hg1_infl + btc_infl + dxy_infl + audusd_infl + eurusd_infl + gbpusd_infl + eu10y_infl + gb10y_infl + jp10y_infl + us02y_infl + us10y_infl + t10yie_infl + dyoas_infl + hyoas_infl + igoas_infl
deflation_sum = spx_defl + rut_defl + sxxp_defl + ni225_defl + hsi_defl + mme1_defl + beta_defl + cycl_defl + vix_defl + move_defl + cor3m_defl + brn1_defl + dba_defl + dbb_defl + si1gc1_defl + hg1_defl + btc_defl + dxy_defl + audusd_defl + eurusd_defl + gbpusd_defl + eu10y_defl + gb10y_defl + jp10y_defl + us02y_defl + us10y_defl + t10yie_defl + dyoas_defl + hyoas_defl + igoas_defl
total_sum = goldilocks_sum + reflation_sum + inflation_sum + deflation_sum
goldilocks_raw = total_sum > 0 ? goldilocks_sum / total_sum * 100 : na
reflation_raw = total_sum > 0 ? reflation_sum / total_sum * 100 : na
inflation_raw = total_sum > 0 ? inflation_sum / total_sum * 100 : na
deflation_raw = total_sum > 0 ? deflation_sum / total_sum * 100 : na
goldilocks = ta.sma(goldilocks_raw, smooth)
reflation = ta.sma(reflation_raw, smooth)
inflation = ta.sma(inflation_raw, smooth)
deflation = ta.sma(deflation_raw, smooth)
regime_ready = model_available and not na(goldilocks) and not na(reflation) and not na(inflation) and not na(deflation)
dominant_value = regime_ready ? math.max(goldilocks, math.max(reflation, math.max(inflation, deflation))) : na
goldilocks_top = regime_ready and goldilocks == dominant_value
reflation_top = regime_ready and reflation == dominant_value
inflation_top = regime_ready and inflation == dominant_value
deflation_top = regime_ready and deflation == dominant_value
var int regime_state = 0
if regime_ready
    previous_still_top = (regime_state == 1 and goldilocks_top) or (regime_state == 2 and reflation_top) or (regime_state == 3 and inflation_top) or (regime_state == 4 and deflation_top)
    if not previous_still_top
        regime_state := goldilocks_top ? 1 : reflation_top ? 2 : inflation_top ? 3 : deflation_top ? 4 : regime_state
goldilocks_regime = regime_state == 1
reflation_regime = regime_state == 2
inflation_regime = regime_state == 3
deflation_regime = regime_state == 4
risk_on = goldilocks_regime or reflation_regime
global_outperform = reflation_regime
smid_outperform = reflation_regime
spreads_outperform = goldilocks_regime or reflation_regime
short_rates_outperform = goldilocks_regime or reflation_regime or inflation_regime
high_yield_outperform = goldilocks_regime or reflation_regime
metals_outperform = goldilocks_regime or reflation_regime or deflation_regime
bitcoin_outperform = goldilocks_regime or reflation_regime
fx_outperform = goldilocks_regime or reflation_regime
risk_arrow = risk_on ? '>' : '<'
beta_arrow = risk_on ? '>' : '<'
cyclical_arrow = risk_on ? '>' : '<'
equity_arrow = global_outperform ? '>' : '<'
size_arrow = smid_outperform ? '>' : '<'
spread_arrow = spreads_outperform ? '>' : '<'
rates_arrow = short_rates_outperform ? '>' : '<'
credit_arrow = high_yield_outperform ? '>' : '<'
commodity_arrow = metals_outperform ? '>' : '<'
bitcoin_arrow = bitcoin_outperform ? '>' : '<'
currency_arrow = fx_outperform ? '>' : '<'
start_month = start_month_name == 'Jan' ? 1 : start_month_name == 'Feb' ? 2 : start_month_name == 'Mar' ? 3 : start_month_name == 'Apr' ? 4 : start_month_name == 'May' ? 5 : start_month_name == 'Jun' ? 6 : start_month_name == 'Jul' ? 7 : start_month_name == 'Aug' ? 8 : start_month_name == 'Sep' ? 9 : start_month_name == 'Oct' ? 10 : start_month_name == 'Nov' ? 11 : 12
is_crypto = syminfo.type == 'crypto'
trading_days_per_year = is_crypto ? 365.0 : 252.0
user_start_ts = timestamp(start_year, start_month, 1)
var int ipo_ts = na
if na(ipo_ts)
    ipo_ts := time
start_ts = math.max(user_start_ts, ipo_ts)
raw_start_bar = time >= start_ts
in_sample_bar = raw_start_bar and regime_ready
in_sample_ret = in_sample_bar and in_sample_bar[1]
var int period_start_ts = na
if na(period_start_ts) and in_sample_bar
    period_start_ts := time
ms_per_year = 365.0 * 24.0 * 60.0 * 60.0 * 1000.0
elapsed_years = not na(period_start_ts) ? (time - period_start_ts) / ms_per_year : na
safe_years = not na(elapsed_years) ? math.max(elapsed_years, 1.0 / trading_days_per_year) : na
bh_ret = math.log(benchmark_price / benchmark_price[1])
var float bh_equity = na
var float bh_equity_start = na
var float bh_peak = na
var float bh_max_dd = na
var int bh_count = 0
var float bh_mean = 0.0
var float bh_sumsq = 0.0
var int bh_neg_count = 0
var float bh_down_sumsq = 0.0
if in_sample_bar
    bh_equity := nz(bh_equity[1], 1.0) * math.exp(in_sample_ret ? nz(bh_ret, 0.0) : 0.0)
if na(bh_equity_start) and in_sample_bar
    bh_equity_start := bh_equity
bh_cagr = not na(bh_equity_start) and bh_equity_start > 0 and not na(safe_years) ? math.pow(bh_equity / bh_equity_start, 1.0 / safe_years) - 1.0 : na
if in_sample_ret and not na(bh_ret)
    bh_prev_mean = bh_mean
    bh_count += 1
    bh_dx = bh_ret - bh_prev_mean
    bh_mean += bh_dx / bh_count
    bh_sumsq += bh_dx * (bh_ret - bh_mean)
    bh_down = math.min(bh_ret, 0.0)
    if bh_down < 0
        bh_neg_count += 1
        bh_down_sumsq += bh_down * bh_down
bars_per_year = not na(elapsed_years) and elapsed_years > 0 and bh_count > 0 ? bh_count / elapsed_years : na
bh_vol = bh_count > 1 ? math.sqrt(bh_sumsq / (bh_count - 1)) : na
bh_hvol = not na(bh_vol) and not na(bars_per_year) ? bh_vol * math.sqrt(bars_per_year) : na
bh_sharpe = not na(bh_cagr) and not na(bh_hvol) and bh_hvol != 0 ? bh_cagr / bh_hvol : na
bh_semi = bh_neg_count > 0 ? math.sqrt(bh_down_sumsq / bh_neg_count) : na
bh_ddev = not na(bh_semi) and not na(bars_per_year) ? bh_semi * math.sqrt(bars_per_year) : na
bh_sortino = not na(bh_cagr) and not na(bh_ddev) and bh_ddev != 0 ? bh_cagr / bh_ddev : na
if in_sample_bar and not na(bh_equity)
    bh_peak := na(bh_peak) ? bh_equity : math.max(bh_peak, bh_equity)
bh_dd = not na(bh_peak) and bh_peak > 0 ? (bh_equity / bh_peak - 1.0) : na
if in_sample_bar and not na(bh_dd)
    bh_max_dd := na(bh_max_dd) ? bh_dd : math.min(bh_max_dd, bh_dd)
bh_mdd = not na(bh_max_dd) and bh_max_dd < 0 ? bh_max_dd : na
bh_calmar = not na(bh_cagr) and not na(bh_mdd) and bh_mdd != 0 ? bh_cagr / math.abs(bh_mdd) : na
var bool in_trade = false
var float entry_eq = na
var int trade_count = 0
var int wins = 0
var int losses = 0
var float tot_win = 0.0
var float tot_loss = 0.0
var int count = 0
var float mean = 0.0
var float squared = 0.0
var int neg_count = 0
var float down_sumsq = 0.0
var float equity_start = na
var float equity = na
var float peak = na
var float max_dd = na
var float bench_mean = 0.0
var float bench_sumsq = 0.0
var float cov_sumsq = 0.0
var int period_start_bar = na
if na(period_start_bar) and in_sample_bar
    period_start_bar := bar_index
target_slot = goldilocks_regime and goldilocks_asset_ready ? 1 : reflation_regime and reflation_asset_ready ? 2 : inflation_regime and inflation_asset_ready ? 3 : deflation_regime and deflation_asset_ready ? 4 : 0
target_symbol = target_slot == 1 ? goldilocks_asset : target_slot == 2 ? reflation_asset : target_slot == 3 ? inflation_asset : target_slot == 4 ? deflation_asset : ''
allocation_slot = na(target_slot[1]) ? 0 : target_slot[1]
allocation_symbol = na(target_symbol[1]) ? '' : target_symbol[1]
is_long = allocation_symbol != ''
was_long = allocation_symbol[1] != ''
allocation_changed = allocation_symbol != allocation_symbol[1]
long_signal = is_long and not was_long
short_signal = not is_long and was_long
rotation_signal = is_long and was_long and allocation_changed
goldilocks_ret = not na(goldilocks_price) and not na(goldilocks_price[1]) ? math.log(goldilocks_price / goldilocks_price[1]) : 0.0
reflation_ret = not na(reflation_price) and not na(reflation_price[1]) ? math.log(reflation_price / reflation_price[1]) : 0.0
inflation_ret = not na(inflation_price) and not na(inflation_price[1]) ? math.log(inflation_price / inflation_price[1]) : 0.0
deflation_ret = not na(deflation_price) and not na(deflation_price[1]) ? math.log(deflation_price / deflation_price[1]) : 0.0
active_asset_ret = allocation_slot[1] == 1 ? goldilocks_ret : allocation_slot[1] == 2 ? reflation_ret : allocation_slot[1] == 3 ? inflation_ret : allocation_slot[1] == 4 ? deflation_ret : 0.0
raw_ret = allocation_slot[1] > 0 ? nz(active_asset_ret, 0.0) : 0.0
fee = fee_input / 100.0
exit_turnover = was_long and allocation_changed ? 1.0 : 0.0
entry_turnover = is_long and allocation_changed ? 1.0 : 0.0
turnover = exit_turnover + entry_turnover
cost = turnover * fee
strat_ret = raw_ret - cost
if in_sample_bar
    base = na(equity[1]) ? 1.0 : equity[1]
    equity := base * math.exp(in_sample_ret ? nz(strat_ret, 0.0) : 0.0)
transition_equity = not na(equity[1]) ? equity[1] * math.exp((in_sample_ret ? nz(raw_ret, 0.0) : 0.0) - exit_turnover * fee) : equity
var float cum_turnover = 0.0
if in_sample_ret and not na(turnover)
    cum_turnover += turnover
turnover_annualized = not na(safe_years) and safe_years > 0 ? cum_turnover / safe_years : na
if in_sample_bar and not in_trade and bar_index == period_start_bar and is_long
    entry_eq := equity
    in_trade := true
if in_sample_ret and in_trade and (short_signal or rotation_signal) and not na(entry_eq) and not na(transition_equity)
    r = transition_equity / entry_eq - 1.0
    trade_count += 1
    if r > 0
        wins += 1
        tot_win += r
    else
        losses += 1
        tot_loss += r
    entry_eq := na
    in_trade := false
if in_sample_ret and not in_trade and long_signal and not na(equity[1])
    entry_eq := equity[1]
    in_trade := true
if in_sample_ret and not in_trade and rotation_signal and not na(transition_equity)
    entry_eq := transition_equity
    in_trade := true
if barstate.islastconfirmedhistory and in_trade and not na(entry_eq) and not na(equity)
    r = equity / entry_eq - 1.0
    trade_count += 1
    if r > 0
        wins += 1
        tot_win += r
    else
        losses += 1
        tot_loss += r
    entry_eq := na
    in_trade := false
if in_sample_ret and not na(strat_ret) and not na(bh_ret)
    prev_mean = mean
    prev_bench_mean = bench_mean
    count += 1
    dx = strat_ret - prev_mean
    mean += dx / count
    squared += dx * (strat_ret - mean)
    dy = bh_ret - prev_bench_mean
    bench_mean += dy / count
    bench_sumsq += dy * (bh_ret - bench_mean)
    cov_sumsq += dx * (bh_ret - bench_mean)
    down = math.min(strat_ret, 0.0)
    if down < 0
        neg_count += 1
        down_sumsq += down * down
if na(equity_start) and in_sample_bar
    equity_start := equity
if in_sample_bar and not na(equity)
    peak := na(peak) ? equity : math.max(peak, equity)
dd = not na(peak) and peak > 0 ? (equity / peak - 1.0) : na
if in_sample_bar and not na(dd)
    max_dd := na(max_dd) ? dd : math.min(max_dd, dd)
cagr = not na(equity_start) and equity_start > 0 and not na(safe_years) ? math.pow(equity / equity_start, 1.0 / safe_years) - 1.0 : na
strat_vol = count > 1 ? math.sqrt(squared / (count - 1)) : na
hvol = not na(strat_vol) and not na(bars_per_year) ? strat_vol * math.sqrt(bars_per_year) : na
sharpe = not na(cagr) and not na(hvol) and hvol != 0 ? cagr / hvol : na
semi = neg_count > 0 ? math.sqrt(down_sumsq / neg_count) : na
ddev = not na(semi) and not na(bars_per_year) ? semi * math.sqrt(bars_per_year) : na
sortino = not na(cagr) and not na(ddev) and ddev != 0 ? cagr / ddev : na
mdd = not na(max_dd) and max_dd < 0 ? max_dd : na
calmar = not na(cagr) and not na(mdd) and mdd != 0 ? cagr / math.abs(mdd) : na
var_bh = count > 1 ? bench_sumsq / (count - 1) : na
cov_xy = count > 1 ? cov_sumsq / (count - 1) : na
beta = not na(cov_xy) and not na(var_bh) and var_bh != 0 ? cov_xy / var_bh : na
excess = not na(cagr) and not na(bh_cagr) ? cagr - bh_cagr : na
alpha_bar_log = not na(beta) and not na(mean) and not na(bench_mean) ? mean - beta * bench_mean : na
alpha_ann_log = not na(alpha_bar_log) and not na(bars_per_year) ? alpha_bar_log * bars_per_year : na
alpha = not na(alpha_ann_log) ? math.exp(alpha_ann_log) - 1.0 : na
profit_factor = trade_count == 0 ? na : (losses == 0 and wins > 0 ? 99 : (tot_loss != 0 ? (tot_win / math.abs(tot_loss)) : 0.0))
win_rate = trade_count > 0 ? wins / trade_count : na
loss_rate = trade_count > 0 ? losses / trade_count : na
avg_win = wins > 0 ? tot_win / wins : na
avg_loss = losses > 0 ? tot_loss / losses : na
expectancy = not na(win_rate) and not na(avg_win) and losses == 0 ? win_rate * avg_win : not na(loss_rate) and not na(avg_loss) and wins == 0 ? -loss_rate * math.abs(avg_loss) : not na(win_rate) and not na(loss_rate) and not na(avg_win) and not na(avg_loss) ? (win_rate * avg_win - loss_rate * math.abs(avg_loss)) : na
excess_final = na(excess) ? '-' : str.tostring(excess, '#%')
cagr_final = na(cagr) ? '-' : str.tostring(cagr, '#%')
sharpe_final = na(sharpe) ? '-' : str.tostring(sharpe, '#.#')
sortino_final = na(sortino) ? '-' : str.tostring(sortino, '#.#')
calmar_final = na(calmar) ? '-' : str.tostring(calmar, '#.#')
mdd_final = na(mdd) ? '-' : str.tostring(mdd, '#%')
alpha_final = na(alpha) ? '-' : str.tostring(alpha, '#%')
win_final = na(win_rate) ? '-' : str.tostring(win_rate, '#%')
profit_factor_final = na(profit_factor) ? '-' : str.tostring(profit_factor, '#.#') + 'x'
expectancy_final = na(expectancy) ? '-' : str.tostring(expectancy, '#%')
turnover_final = na(turnover_annualized) ? '-' : str.tostring(turnover_annualized, '#.#')
plot(goldilocks, title = 'Goldilocks', color = color.yellow, linewidth = 2, format = format.percent, precision = 0)
plot(reflation, title = 'Reflation', color = color.green, linewidth = 2, format = format.percent, precision = 0)
plot(inflation, title = 'Inflation', color = color.red, linewidth = 2, format = format.percent, precision = 0)
plot(deflation, title = 'Deflation', color = color.blue, linewidth = 2, format = format.percent, precision = 0)
var label goldilocks_label = label.new(na, na, '', style = label.style_label_left, textcolor = color.white, color = color.yellow)
var label reflation_label = label.new(na, na, '', style = label.style_label_left, textcolor = color.white, color = color.green)
var label inflation_label = label.new(na, na, '', style = label.style_label_left, textcolor = color.white, color = color.red)
var label deflation_label = label.new(na, na, '', style = label.style_label_left, textcolor = color.white, color = color.blue)
if barstate.islast
    label.set_xy(goldilocks_label, bar_index + 1, goldilocks)
    label.set_text(goldilocks_label, 'Goldilocks (' + str.tostring(goldilocks / 100, '#%') + ')')
    label.set_xy(reflation_label, bar_index + 1, reflation)
    label.set_text(reflation_label, 'Reflation (' + str.tostring(reflation / 100, '#%') + ')')
    label.set_xy(inflation_label, bar_index + 1, inflation)
    label.set_text(inflation_label, 'Inflation (' + str.tostring(inflation / 100, '#%') + ')')
    label.set_xy(deflation_label, bar_index + 1, deflation)
    label.set_text(deflation_label, 'Deflation (' + str.tostring(deflation / 100, '#%') + ')')
var table t = table.new(table_position, 3, 11, frame_color = color.white, frame_width = 1, border_color = color.white, border_width = 1)
if backtest_active
    table.cell(t, 0, 0, text = 'CAGR', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 1, text = 'Excess', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 2, text = 'Sharpe', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 3, text = 'Sortino', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 4, text = 'Calmar', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 5, text = 'Max DD', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 6, text = 'Alpha (α)', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 7, text = 'Win Rate', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 8, text = 'Profit Factor', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 9, text = 'Expectancy', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 10, text = 'Turnover', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 1, 0, text = cagr_final, width = width_input, text_color = color.white, bgcolor = cagr > 0 ? color.green : cagr < 0 ? color.red : color.gray)
    table.cell(t, 1, 1, text = excess_final, width = width_input, text_color = color.white, bgcolor = excess > 0 ? color.green : excess < 0 ? color.red : color.gray)
    table.cell(t, 1, 2, text = sharpe_final, width = width_input, text_color = color.white, bgcolor = sharpe > bh_sharpe ? color.green : sharpe < bh_sharpe ? color.red : color.gray)
    table.cell(t, 1, 3, text = sortino_final, width = width_input, text_color = color.white, bgcolor = sortino > bh_sortino ? color.green : sortino < bh_sortino ? color.red : color.gray)
    table.cell(t, 1, 4, text = calmar_final, width = width_input, text_color = color.white, bgcolor = calmar > bh_calmar ? color.green : calmar < bh_calmar ? color.red : color.gray)
    table.cell(t, 1, 5, text = mdd_final, width = width_input, text_color = color.white, bgcolor = mdd > bh_mdd ? color.green : mdd < bh_mdd ? color.red : color.gray)
    table.cell(t, 1, 6, text = alpha_final, width = width_input, text_color = color.white, bgcolor = alpha > 0 ? color.green : alpha < 0 ? color.red : color.gray)
    table.cell(t, 1, 7, text = win_final, width = width_input, text_color = color.white, bgcolor = win_rate > 0.5 ? color.green : win_rate < 0.5 ? color.red : color.gray)
    table.cell(t, 1, 8, text = profit_factor_final, width = width_input, text_color = color.white, bgcolor = profit_factor > 2 ? color.green : profit_factor < 1 ? color.red : color.gray)
    table.cell(t, 1, 9, text = expectancy_final, width = width_input, text_color = color.white, bgcolor = expectancy > 0 ? color.green : expectancy < 0 ? color.red : color.gray)
    table.cell(t, 1, 10, text = turnover_final, width = width_input, text_color = color.white, bgcolor = color.gray)
else
    table.cell(t, 0, 0, text = 'Risk-On', width = width_input, text_color = color.white, bgcolor = risk_on ? color.green : color.red)
    table.cell(t, 1, 0, text = risk_arrow, width = width_input / 4, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 2, 0, text = 'Risk-Off', width = width_input, text_color = color.white, bgcolor = risk_on ? color.red : color.green)
    table.cell(t, 0, 1, text = 'High Beta', width = width_input, text_color = color.white, bgcolor = risk_on ? color.green : color.red)
    table.cell(t, 1, 1, text = beta_arrow, width = width_input / 4, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 2, 1, text = 'Low Beta', width = width_input, text_color = color.white, bgcolor = risk_on ? color.red : color.green)
    table.cell(t, 0, 2, text = 'Cyclicals', width = width_input, text_color = color.white, bgcolor = risk_on ? color.green : color.red)
    table.cell(t, 1, 2, text = cyclical_arrow, width = width_input / 4, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 2, 2, text = 'Defensives', width = width_input, text_color = color.white, bgcolor = risk_on ? color.red : color.green)
    table.cell(t, 0, 3, text = 'International', width = width_input, text_color = color.white, bgcolor = global_outperform ? color.green : color.red)
    table.cell(t, 1, 3, text = equity_arrow, width = width_input / 4, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 2, 3, text = 'US Equities', width = width_input, text_color = color.white, bgcolor = global_outperform ? color.red : color.green)
    table.cell(t, 0, 4, text = 'SMID Caps', width = width_input, text_color = color.white, bgcolor = smid_outperform ? color.green : color.red)
    table.cell(t, 1, 4, text = size_arrow, width = width_input / 4, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 2, 4, text = 'Large Caps', width = width_input, text_color = color.white, bgcolor = smid_outperform ? color.red : color.green)
    table.cell(t, 0, 5, text = 'Short Rates', width = width_input, text_color = color.white, bgcolor = short_rates_outperform ? color.green : color.red)
    table.cell(t, 1, 5, text = rates_arrow, width = width_input / 4, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 2, 5, text = 'Long Rates', width = width_input, text_color = color.white, bgcolor = short_rates_outperform ? color.red : color.green)
    table.cell(t, 0, 6, text = 'Spreads', width = width_input, text_color = color.white, bgcolor = spreads_outperform ? color.green : color.red)
    table.cell(t, 1, 6, text = spread_arrow, width = width_input / 4, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 2, 6, text = 'Treasuries', width = width_input, text_color = color.white, bgcolor = spreads_outperform ? color.red : color.green)
    table.cell(t, 0, 7, text = 'High Yield', width = width_input, text_color = color.white, bgcolor = high_yield_outperform ? color.green : color.red)
    table.cell(t, 1, 7, text = credit_arrow, width = width_input / 4, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 2, 7, text = 'Low Yield', width = width_input, text_color = color.white, bgcolor = high_yield_outperform ? color.red : color.green)
    table.cell(t, 0, 8, text = 'Beta FX', width = width_input, text_color = color.white, bgcolor = fx_outperform ? color.green : color.red)
    table.cell(t, 1, 8, text = currency_arrow, width = width_input / 4, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 2, 8, text = 'US Dollar', width = width_input, text_color = color.white, bgcolor = fx_outperform ? color.red : color.green)
    table.cell(t, 0, 9, text = 'Metals', width = width_input, text_color = color.white, bgcolor = metals_outperform ? color.green : color.red)
    table.cell(t, 1, 9, text = commodity_arrow, width = width_input / 4, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 2, 9, text = 'Energy', width = width_input, text_color = color.white, bgcolor = metals_outperform ? color.red : color.green)
    table.cell(t, 0, 10, text = 'Bitcoin', width = width_input, text_color = color.white, bgcolor = bitcoin_outperform ? color.green : color.red)
    table.cell(t, 1, 10, text = bitcoin_arrow, width = width_input / 4, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 2, 10, text = 'Gold', width = width_input, text_color = color.white, bgcolor = bitcoin_outperform ? color.red : color.green)
goldilocks_condition = barstate.isconfirmed and goldilocks_regime and not goldilocks_regime[1]
reflation_condition = barstate.isconfirmed and reflation_regime and not reflation_regime[1]
inflation_condition = barstate.isconfirmed and inflation_regime and not inflation_regime[1]
deflation_condition = barstate.isconfirmed and deflation_regime and not deflation_regime[1]
const string goldilocks_alert = 'Global Macro Regime: GOLDILOCKS\n\n' +
 'Equity Sectors:\n' +
 'Communication Services (XLC), Technology (XLK), Financials (XLF), Industrials (XLI), Consumer Discretionary (XLY), Materials (XLB), Real Estate (VNQ)\n\n' +
 'Equity Factors:\n' +
 'S&P 500 (SPY), Nasdaq 100 (QQQ), High Beta (SPHB), Momentum (MTUM), Quality (QUAL), Growth (IWF), Value (IWD)\n\n' +
 'Fixed Income:\n' +
 'High Yield Bonds (HYG), Investment Grade Bonds (LQD), Convertible Bonds (CWB)\n\n' +
 'Commodities:\n' +
 'Bitcoin (BTC), Industrial Metals (DBB), Metal Producers (PICK), Gold (GLD), Gold Miners (GDX), Silver (SLV), Silver Miners (SIL), Copper (CPER), Copper Miners (COPX), Uranium (SRUUF), Uranium Miners (URNM)\n\n' +
 'Currencies:\n' +
 'Australian Dollar (FXA), British Pound (FXB), Euro (FXE)'
const string reflation_alert = 'Global Macro Regime: REFLATION\n\n' +
 'Equity Sectors:\n' +
 'Energy (XLE), Communication Services (XLC), Technology (XLK), Financials (XLF), Industrials (XLI), Consumer Discretionary (XLY), Materials (XLB), Real Estate (VNQ)\n\n' +
 'Equity Factors:\n' +
 'Global Equities (ACWI), International Equities (ACWX), S&P 500 (SPY), Nasdaq 100 (QQQ), Emerging Markets (EEM), High Beta (SPHB), Mid Caps (IWR), Small Caps (IWM), Momentum (MTUM), Quality (QUAL), Growth (IWF), Value (IWD), Equal Weight (RSP), Global Infrastructure (IGF), International Real Estate (IFGL)\n\n' +
 'Fixed Income:\n' +
 'High Yield Bonds (HYG), Convertible Bonds (CWB), Private Credit (BIZD), Emerging Market Bonds (EMB)\n\n' +
 'Commodities:\n' +
 'Bitcoin (BTC), Commodities (DBC), Industrial Metals (DBB), Metal Producers (PICK), Crude Oil (USO), Agriculture (DBA), Agriculture Producers (VEGI), Gold (GLD), Gold Miners (GDX), Silver (SLV), Silver Miners (SIL), Copper (CPER), Copper Miners (COPX), Uranium (SRUUF), Uranium Miners (URNM)\n\n' +
 'Currencies:\n' +
 'Australian Dollar (FXA), Canadian Dollar (FXC), British Pound (FXB), Euro (FXE)'
const string inflation_alert = 'Global Macro Regime: INFLATION\n\n' +
 'Equity Sectors:\n' +
 'Energy (XLE), Consumer Staples (XLP), Utilities (XLU), Health Care (XLV)\n\n' +
 'Equity Factors:\n' +
 'Low Volatility (SPLV)\n\n' +
 'Fixed Income:\n' +
 '1-3 Month Treasury Bills (BIL)\n\n' +
 'Commodities:\n' +
 'Commodities (DBC), Crude Oil (USO), Agriculture (DBA), Gold (GLD)\n\n' +
 'Currencies:\n' +
 'US Dollar (UUP)'
const string deflation_alert = 'Global Macro Regime: DEFLATION\n\n' +
 'Equity Sectors:\n' +
 'Consumer Staples (XLP), Utilities (XLU), Health Care (XLV)\n\n' +
 'Equity Factors:\n' +
 'Low Volatility (SPLV), High Dividend (SPHD)\n\n' +
 'Fixed Income:\n' +
 '1-3 Year Treasuries (SHY), 7-10 Year Treasuries (IEF), 20+ Year Treasuries (TLT), US Aggregate Bonds (AGG), Mortgage-Backed Securities (MBB), International Aggregate Bonds (BNDX)\n\n' +
 'Commodities:\n' +
 'Gold (GLD)\n\n' +
 'Currencies:\n' +
 'US Dollar (UUP), Japanese Yen (FXY)'
alertcondition(goldilocks_condition, title = 'Goldilocks', message = goldilocks_alert)
alertcondition(reflation_condition, title = 'Reflation', message = reflation_alert)
alertcondition(inflation_condition, title = 'Inflation', message = inflation_alert)
alertcondition(deflation_condition, title = 'Deflation', message = deflation_alert)
if goldilocks_condition
    alert(goldilocks_alert, alert.freq_once_per_bar_close)
if reflation_condition
    alert(reflation_alert, alert.freq_once_per_bar_close)
if inflation_condition
    alert(inflation_alert, alert.freq_once_per_bar_close)
if deflation_condition
    alert(deflation_alert, alert.freq_once_per_bar_close)
````
