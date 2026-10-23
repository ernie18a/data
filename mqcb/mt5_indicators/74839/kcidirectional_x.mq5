//+------------------------------------------------------------------+
//|                                            KCI-Directional_X.mq5 |
//|                             Copyright 2026, Ritz (KCI Developer) |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Ritz"
#property link        "https://www.mql5.com/en/users/ritzfalih"
#property description "Kinetic Compression Index - Directional Matrix (3-Line)"
#property version     "1.0"
#property indicator_separate_window

//--- Limit Oscillator 0 to 100 (Like ADX)
#property indicator_minimum 0.0
#property indicator_maximum 100.0

#property indicator_buffers 6
#property indicator_plots   3

//--- Plot 1: KCI Main (Trend Strength / Compression)
#property indicator_label1  "KCI Main"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- Plot 2: +KDI (Bullish Kinetic Direction)
#property indicator_label2  "+KCI Directional Index"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_DASHDOTDOT
#property indicator_width2  1

//--- Plot 3: -KDI (Bearish Kinetic Direction)
#property indicator_label3  "-KCI Directional Index"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_DASHDOTDOT
#property indicator_width3  1

//--- Reference Levels
#property indicator_level1  80.0
#property indicator_level2  20.0
#property indicator_levelcolor clrDimGray
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1

//--- Input Parameters
input group "=== KCI-DX Core Parameters ==="
input int    BasePeriod = 9;             // Kinetic Base Period
input int    ZScorePeriod = 30;          // Z-Score Normalization Window
input double Sensitivity = 1.5;          // Sigmoid Sharpness (1.0 to 3.0)

//--- Visual Buffers
double       KCI_Main[];    // Buffer 0
double       KDI_Plus[];    // Buffer 1
double       KDI_Minus[];   // Buffer 2

//--- Internal Metric Buffers
double       raw_trend[];   // Buffer 3
double       raw_plus[];    // Buffer 4
double       raw_minus[];   // Buffer 5

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorSetString(INDICATOR_LEVELTEXT, 0, "Extreme Trend (80)");  
    IndicatorSetString(INDICATOR_LEVELTEXT, 1, "Compression/Sideways (20)");     
    IndicatorSetString(INDICATOR_SHORTNAME, "KCI-DX ("+(string)BasePeriod+","+(string)ZScorePeriod+")");
    
    // Bind Visual Buffers
    SetIndexBuffer(0, KCI_Main, INDICATOR_DATA);
    SetIndexBuffer(1, KDI_Plus, INDICATOR_DATA);
    SetIndexBuffer(2, KDI_Minus, INDICATOR_DATA);
    
    // Bind Internal Buffers
    SetIndexBuffer(3, raw_trend, INDICATOR_CALCULATIONS);
    SetIndexBuffer(4, raw_plus, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, raw_minus, INDICATOR_CALCULATIONS);
    
    // Set as Series
    ArraySetAsSeries(KCI_Main, true);
    ArraySetAsSeries(KDI_Plus, true);
    ArraySetAsSeries(KDI_Minus, true);
    ArraySetAsSeries(raw_trend, true);
    ArraySetAsSeries(raw_plus, true);
    ArraySetAsSeries(raw_minus, true);
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Z-Score Normalization (Optimized Single-Pass)                    |
//+------------------------------------------------------------------+
double GetZScore(const double &data_array[], int start_index, int period)
{
    if(period < 2) return 0.0;
   
    double sum = 0.0;
    double sum_sq = 0.0;
   
    for(int i = 0; i < period; i++) 
    {
        double val = data_array[start_index + i];
        sum += val;
        sum_sq += val * val; 
    }
   
    double mean = sum / period;
    double variance = (sum_sq / period) - (mean * mean);
   
    if(variance <= 1e-10) return 0.0; 
   
    double std_dev = MathSqrt(variance);
    return (data_array[start_index] - mean) / std_dev;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    // Just use the absolute minimum limit so that the indicator doesn't block history
    int min_bars_required = BasePeriod + 3; 
    if(rates_total < min_bars_required) return 0;
    
    ArraySetAsSeries(close, true);
    
    if(prev_calculated == 0)
    {
        ArrayInitialize(KCI_Main, 0.0);
        ArrayInitialize(KDI_Plus, 0.0);
        ArrayInitialize(KDI_Minus, 0.0);
        ArrayInitialize(raw_trend, 0.0);
        ArrayInitialize(raw_plus, 0.0);
        ArrayInitialize(raw_minus, 0.0);
    }
    
    int limit;
    if(prev_calculated == 0 || prev_calculated > rates_total)
        limit = rates_total - BasePeriod - 1;
    else
        limit = rates_total - prev_calculated + 1;

    //=========================================================
    // PHASE 1: KINEMATIC DIRECTIONAL EXTRACTION
    //=========================================================
    for(int i = limit; i >= 0 && !IsStopped(); i--)
    {
        double path_len = 0.000001; 
        double net_up = 0.0;
        double net_dn = 0.0;
        double mean_p = 0.0;
        
        for(int j = 0; j < BasePeriod; j++)
        {
            double diff = close[i + j] - close[i + j + 1];
            path_len += MathAbs(diff);
            
            if(diff > 0) net_up += diff;
            else net_dn -= diff; 
            
            mean_p += close[i + j];
        }
        
        mean_p /= BasePeriod;
        double var_p = 0.0;
        
        for(int j = 0; j < BasePeriod; j++)
        {
            var_p += MathPow(close[i + j] - mean_p, 2);
        }
        double energy = MathSqrt(var_p / BasePeriod);
        
        raw_plus[i]  = (net_up / path_len) * energy;
        raw_minus[i] = (net_dn / path_len) * energy;
        raw_trend[i] = (MathAbs(net_up - net_dn) / path_len) * energy;
    }

    //=========================================================
    // PHASE 2: SIGMOID NORMALIZATION DYNAMIC SCALING
    //=========================================================
    int limit_z = limit;
    if(limit_z > rates_total - BasePeriod - 3) 
        limit_z = rates_total - BasePeriod - 3;

    for(int i = limit_z; i >= 0 && !IsStopped(); i--)
    {
        // Dynamic feature returns full range to end of history
        int available_bars = (rates_total - BasePeriod) - i;
        int dynamic_z_period = available_bars;
        
        if(dynamic_z_period > ZScorePeriod) dynamic_z_period = ZScorePeriod;
        if(dynamic_z_period < 3) continue; // Minimum security deviation period
        
        double z_plus  = GetZScore(raw_plus, i, dynamic_z_period);
        double z_minus = GetZScore(raw_minus, i, dynamic_z_period);
        double z_trend = GetZScore(raw_trend, i, dynamic_z_period);
        
        KDI_Plus[i]  = 100.0 / (1.0 + MathExp(-Sensitivity * z_plus));
        KDI_Minus[i]  = 100.0 / (1.0 + MathExp(-Sensitivity * z_minus));
        KCI_Main[i]  = 100.0 / (1.0 + MathExp(-Sensitivity * z_trend));
    }
    
    return(rates_total);
}


//+------------------------------------------------------------------+
