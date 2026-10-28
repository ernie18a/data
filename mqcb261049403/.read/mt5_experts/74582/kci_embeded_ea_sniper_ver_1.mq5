//+------------------------------------------------------------------+
//|                                   KCI_WPR_Embedded_Sniper_V1.mq5 |
//|                           Copyright 2026, KCI Standard Developer |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "https://www.mql5.com/en/users/ritzfalih"
#property version     "1.0"
#property description "EA Standalone: Embedded KCI + WPR + Trend Filter + Trailing Stop"

#include <Trade\Trade.mqh>

//--- Input Groups
input group "=== Trade & Execution Filter ==="
input double InpLotSize = 0.01;            
input int    InpMaxSpread = 200;           // Maximum allowed spread in points
input ulong  InpMagicNumber = 77720262;    
input int    InpSlippage = 10;             // Slippage tolerance

input group "=== Risk Management ==="
input double InpEDMultiplierSL = 1.5;      
input double InpEDMultiplierTP = 3.0;      
input bool   InpUseTrailing = true;        // Enable Trailing Stop
input int    InpTrailingStart = 500;        // Points in profit to start trailing
input int    InpTrailingStep = 200;         // Step to move SL

input group "=== Trend Filter (MTF) ==="
input bool   InpUseTrendFilter = false;     // Enable Higher Timeframe Trend Filter
input ENUM_TIMEFRAMES InpTrendTF = PERIOD_H4;
input int    InpTrendPeriod = 200;         // Moving Average Period

input group "=== WPR & KCI Settings ==="
input int    InpWPRPeriod = 14;            
input double InpWPRBuyLevel = -80.0;       
input double InpWPRSellLevel = -20.0;      
input int    ZScorePeriod = 50;         
input double CompressionThreshold = 2.0; 
input int    BasePeriod = 14;           

//--- Global Objects & Buffers
CTrade         trade;
int            handle_wpr, handle_trend;
datetime       last_bar_time = 0;
double         buf_wpr[], buf_trend[];

// Global buffers for calculation efficiency
double         vq[], kd[], ed[], pv[], Raw_KCI[];

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    trade.SetExpertMagicNumber(InpMagicNumber);
    trade.SetDeviationInPoints(InpSlippage);
    
    // Initialize WPR and Trend Filter
    ArraySetAsSeries(buf_wpr, true);
    ArraySetAsSeries(buf_trend, true);
    
    handle_wpr = iWPR(_Symbol, _Period, InpWPRPeriod);
    handle_trend = iMA(_Symbol, InpTrendTF, InpTrendPeriod, 0, MODE_EMA, PRICE_CLOSE);
    
    if(handle_wpr == INVALID_HANDLE || handle_trend == INVALID_HANDLE) 
        return(INIT_FAILED);
    
    // Allocate global memory for KCI Engine
    int total_bars = ZScorePeriod + BasePeriod + 10;
    ArrayResize(vq, total_bars); ArraySetAsSeries(vq, true);
    ArrayResize(kd, total_bars); ArraySetAsSeries(kd, true);
    ArrayResize(ed, total_bars); ArraySetAsSeries(ed, true);
    ArrayResize(pv, total_bars); ArraySetAsSeries(pv, true);
    ArrayResize(Raw_KCI, 5);     ArraySetAsSeries(Raw_KCI, true);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| New Bar Detection                                                |
//+------------------------------------------------------------------+
bool IsNewBar()
{
    datetime current_time = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
    if(current_time != last_bar_time) { last_bar_time = current_time; return true; }
    return false;
}

//+------------------------------------------------------------------+
//| Z-Score Custom Calculation                                       |
//+------------------------------------------------------------------+
double GetZScoreCustom(const double &data_array[], int start_index, int period)
{
    if(period < 2) return 0.0;
    double sum = 0.0, mean = 0.0, variance = 0.0, std_dev = 0.0;
    for(int i = 0; i < period; i++) sum += data_array[start_index + i];
    mean = sum / period;
    for(int i = 0; i < period; i++) variance += MathPow(data_array[start_index + i] - mean, 2);
    variance = variance / period;
    std_dev = MathSqrt(variance);
    if(std_dev == 0) return 0.0;
    return (data_array[start_index] - mean) / std_dev;
}

//+------------------------------------------------------------------+
//| KCI Core Signal Logic                                            |
//+------------------------------------------------------------------+
int GetEmbeddedKCISignal(double &out_ed)
{
    int total_bars = ZScorePeriod + BasePeriod + 10;
    double close[]; long tick_vol[];
    ArraySetAsSeries(close, true); ArraySetAsSeries(tick_vol, true);
    
    if(CopyClose(_Symbol, _Period, 0, total_bars, close) < total_bars) return 0;
    if(CopyTickVolume(_Symbol, _Period, 0, total_bars, tick_vol) < total_bars) return 0;

    for(int i = total_bars - BasePeriod - 1; i >= 1; i--)
    {
        double sum_price = 0, path_length = 0.000001;
        double net_dist = close[i] - close[i + BasePeriod];
        for(int j = 0; j < BasePeriod; j++) {
            sum_price += close[i + j];
            path_length += MathAbs(close[i + j] - close[i + j + 1]);
        }
        double mean_price = sum_price / BasePeriod;
        double variance_price = 0;
        for(int j = 0; j < BasePeriod; j++) variance_price += MathPow(close[i + j] - mean_price, 2);

        vq[i] = net_dist / path_length;
        kd[i] = close[i] - mean_price;
        ed[i] = MathSqrt(variance_price / BasePeriod);
        pv[i] = net_dist;
    }

    for(int i = 3; i >= 1; i--)
    {
        double z_vq = GetZScoreCustom(vq, i, ZScorePeriod);
        double z_kd = GetZScoreCustom(kd, i, ZScorePeriod);
        double z_ed = GetZScoreCustom(ed, i, ZScorePeriod);
        double z_pv = GetZScoreCustom(pv, i, ZScorePeriod);
        Raw_KCI[i] = MathAbs(z_vq-z_kd) + MathAbs(z_vq-z_ed) + MathAbs(z_vq-z_pv) +
                     MathAbs(z_kd-z_ed) + MathAbs(z_kd-z_pv) + MathAbs(z_ed-z_pv);
    }

    bool is_local_min = (Raw_KCI[2] < Raw_KCI[1]) && (Raw_KCI[2] < Raw_KCI[3]);
    bool is_extreme   = (Raw_KCI[2] <= CompressionThreshold);
    bool is_energy_drop = ((double)tick_vol[2] * MathPow(close[2]-close[3], 2)) < 
                          ((double)tick_vol[1] * MathPow(close[1]-close[2], 2));

    out_ed = ed[1]; 
    if(is_local_min && is_extreme && is_energy_drop)
        return ((close[2]-close[3]) < 0) ? 1 : -1;
    return 0;
}

//+------------------------------------------------------------------+
//| Manage Trailing Stop                                             |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
    if(!InpUseTrailing) return;
    
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
        {
            double price = PositionGetDouble(POSITION_PRICE_CURRENT);
            double sl = PositionGetDouble(POSITION_SL);
            double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
            
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
                if(price - open_price > InpTrailingStart * _Point)
                {
                    if(sl < price - (InpTrailingStart + InpTrailingStep) * _Point)
                        trade.PositionModify(ticket, price - InpTrailingStart * _Point, PositionGetDouble(POSITION_TP));
                }
            }
            else // SELL
            {
                if(open_price - price > InpTrailingStart * _Point)
                {
                    if(sl > price + (InpTrailingStart + InpTrailingStep) * _Point || sl == 0)
                        trade.PositionModify(ticket, price + InpTrailingStart * _Point, PositionGetDouble(POSITION_TP));
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Main Tick Function                                               |
//+------------------------------------------------------------------+
void OnTick()
{
    // Trailing stop runs every tick
    ManageTrailingStop();
    
    // Entry logic runs only on new bar
    if(!IsNewBar()) return;
    if(PositionsTotal() > 0) return; 

    // Spread filter
    if((int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > InpMaxSpread) return;

    // Trend filter logic
    if(InpUseTrendFilter)
    {
        CopyBuffer(handle_trend, 0, 1, 1, buf_trend);
        double trend_ma = buf_trend[0];
        
        // Buy filter: Close must be above MA
        if(SymbolInfoDouble(_Symbol, SYMBOL_BID) < trend_ma) return;
        // Sell filter: Close must be below MA
        if(SymbolInfoDouble(_Symbol, SYMBOL_BID) > trend_ma) return;
    }

    if(CopyBuffer(handle_wpr, 0, 1, 1, buf_wpr) <= 0) return;
    
    double current_ed = 0.0;
    int kci_signal = GetEmbeddedKCISignal(current_ed);
    
    if(current_ed == 0) return;

    // Execution
    if(kci_signal == 1 && buf_wpr[0] <= InpWPRBuyLevel)
    {
        double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        trade.Buy(InpLotSize, _Symbol, ask, ask - (current_ed * InpEDMultiplierSL), ask + (current_ed * InpEDMultiplierTP), "KCI Sniper Buy");
    }
    else if(kci_signal == -1 && buf_wpr[0] >= InpWPRSellLevel)
    {
        double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        trade.Sell(InpLotSize, _Symbol, bid, bid + (current_ed * InpEDMultiplierSL), bid - (current_ed * InpEDMultiplierTP), "KCI Sniper Sell");
    }
}