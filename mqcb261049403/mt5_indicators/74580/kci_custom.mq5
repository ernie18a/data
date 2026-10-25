//+------------------------------------------------------------------+
//|                                                   KCI Custom.mq5 |
//|                           Copyright 2026, KCI Standard Developer |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, KCI Standard Developer"
#property link        "https://www.mql5.com/en/users/ritzfalih"
#property description "Kinetic Compression Index - Polarized Oscillator (Color Dynamic)"
#property indicator_separate_window

#property indicator_buffers 9
#property indicator_plots   1

//--- Main Plot (Polarized Oscillator) using DRAW_COLOR_LINE
#property indicator_label1  "KCI (Polarized)"
#property indicator_type1   DRAW_COLOR_LINE
// Default color definition: Index 0 = Blue (Up), Index 1 = Red (Down)
#property indicator_color1  clrDodgerBlue,clrRed 
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- OB/OS Levels & Descriptions
#property indicator_level1  80.0
#property indicator_level2  0.0
#property indicator_level3 -80.0
#property indicator_levelcolor clrDimGray
#property indicator_levelstyle STYLE_DOT

//--- Input Parameters
input group "=== KCI Computing Core ==="
input int    ZScorePeriod = 50;           // Z-Score Rolling Window
input double CompressionThreshold = 2.0;  // Raw KCI Extreme Threshold
input int    BasePeriod = 14;             // Kinetic Base Period

input group "=== Visual Settings ==="
input color  ColorAboveZero = clrDodgerBlue; // KCI color at the moment > 0.0 (Bullish)
input color  ColorBelowZero = clrRed;        // KCI color at the moment < 0.0 (Bearish)

//--- Exposed Indicator Buffers
double       KCI_Buffer[];       // Buffer Index 0 (Visual Data)
double       KCI_Color[];        // Buffer Index 1 (Visual Color Index)
double       Bullish_Buffer[];   // Buffer Index 2 (Buy Signal) 
double       Bearish_Buffer[];   // Buffer Index 3 (Sell Signal) 

//--- Internal Metric Buffers
double       buf_vq[];           // Buffer Index 4
double       buf_kd[];           // Buffer Index 5
double       buf_ed[];           // Buffer Index 6 (Energy Dispersion) 
double       buf_pv[];           // Buffer Index 7
double       Raw_KCI[];          // Buffer Index 8 (Raw KCI)

//+------------------------------------------------------------------+
//| indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
{
    // Prevents lines from being drawn to zero if data is empty.
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    
    // Applying the color from user input to Plot Index 0
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, ColorAboveZero); // Color index 0
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, ColorBelowZero); // Color index 1
    
    // 1. Setup Visual Buffer (Data & Color MUST be in sequence)
    SetIndexBuffer(0, KCI_Buffer, INDICATOR_DATA);
    SetIndexBuffer(1, KCI_Color, INDICATOR_COLOR_INDEX);
    IndicatorSetInteger(INDICATOR_DIGITS, 2);
    
    // --- NEW ADD: Provide Level Description in Sub-Window ---
    IndicatorSetString(INDICATOR_LEVELTEXT, 0, "Premium");     // For Level 80.0
    IndicatorSetString(INDICATOR_LEVELTEXT, 1, "Equilibrium"); // For Level 0.0
    IndicatorSetString(INDICATOR_LEVELTEXT, 2, "Discount");    // For Level -80.0
    IndicatorSetString(INDICATOR_SHORTNAME, "KCI Custom");
    // 2. Internal Calculation Buffer Setup
    SetIndexBuffer(2, Bullish_Buffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(3, Bearish_Buffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(4, buf_vq, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, buf_kd, INDICATOR_CALCULATIONS);
    SetIndexBuffer(6, buf_ed, INDICATOR_CALCULATIONS);
    SetIndexBuffer(7, buf_pv, INDICATOR_CALCULATIONS);
    SetIndexBuffer(8, Raw_KCI, INDICATOR_CALCULATIONS);
    
    ArraySetAsSeries(KCI_Buffer, true);
    ArraySetAsSeries(KCI_Color, true);
    ArraySetAsSeries(Bullish_Buffer, true);
    ArraySetAsSeries(Bearish_Buffer, true);
    ArraySetAsSeries(buf_vq, true);
    ArraySetAsSeries(buf_kd, true);
    ArraySetAsSeries(buf_ed, true);
    ArraySetAsSeries(buf_pv, true);
    ArraySetAsSeries(Raw_KCI, true);
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Z-Score Normalization Function                                   |
//+------------------------------------------------------------------+
double GetZScore(const double &data_array[], int start_index, int period)
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
    int min_bars_required = BasePeriod + 3;
    
    if(rates_total < min_bars_required) return 0;
    
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(tick_volume, true);
    
    if(prev_calculated == 0 || prev_calculated > rates_total)
    {
        ArrayInitialize(KCI_Buffer, EMPTY_VALUE);
        ArrayInitialize(KCI_Color, 0.0);
        ArrayInitialize(Bullish_Buffer, 0.0);
        ArrayInitialize(Bearish_Buffer, 0.0);
        ArrayInitialize(buf_vq, 0.0);
        ArrayInitialize(buf_kd, 0.0);
        ArrayInitialize(buf_ed, 0.0);
        ArrayInitialize(buf_pv, 0.0);
        ArrayInitialize(Raw_KCI, 0.0);
    }
    
    int limit;
    if(prev_calculated == 0 || prev_calculated > rates_total)
        limit = rates_total - 1;
    else
        limit = rates_total - prev_calculated + 1; 

    // =========================================================
    // PHASE 1: PURE KINEMATICS ENGINE
    // =========================================================
    int limit_base = limit;
    if(limit_base > rates_total - BasePeriod - 1) 
        limit_base = rates_total - BasePeriod - 1;

    for(int i = limit_base; i >= 0 && !IsStopped(); i--)
    {
        double sum_price = 0;
        double path_length = 0.000001; 
        double net_distance = close[i] - close[i + BasePeriod];
        
        for(int j = 0; j < BasePeriod; j++)
        {
            sum_price += close[i + j];
            path_length += MathAbs(close[i + j] - close[i + j + 1]);
        }
        
        double mean_price = sum_price / BasePeriod;
        double variance_price = 0;
        
        for(int j = 0; j < BasePeriod; j++)
        {
            variance_price += MathPow(close[i + j] - mean_price, 2);
        }
        
        buf_vq[i] = net_distance / path_length;               
        buf_kd[i] = close[i] - mean_price;                    
        buf_ed[i] = MathSqrt(variance_price / BasePeriod);    
        buf_pv[i] = net_distance;                             
    }

    double decay_constant = 0.22314355 / CompressionThreshold;

    // =========================================================
    // PHASE 2: DYNAMIC KCI & COGNITIVE ENGINE
    // =========================================================
    int limit_kci = limit;
    if(limit_kci > rates_total - BasePeriod - 3) 
        limit_kci = rates_total - BasePeriod - 3;

    for(int i = limit_kci; i >= 0 && !IsStopped(); i--)
    {
        Bullish_Buffer[i] = 0.0;
        Bearish_Buffer[i] = 0.0;
        
        int available_bars = (rates_total - BasePeriod) - i;
        int dynamic_z_period = available_bars;
        if(dynamic_z_period > ZScorePeriod) dynamic_z_period = ZScorePeriod; 
        
        if(dynamic_z_period < 3) continue; 
        
        double z_vq = GetZScore(buf_vq, i, dynamic_z_period);
        double z_kd = GetZScore(buf_kd, i, dynamic_z_period);
        double z_ed = GetZScore(buf_ed, i, dynamic_z_period);
        double z_pv = GetZScore(buf_pv, i, dynamic_z_period);
        
        double dist1 = MathAbs(z_vq - z_kd);
        double dist2 = MathAbs(z_vq - z_ed);
        double dist3 = MathAbs(z_vq - z_pv);
        double dist4 = MathAbs(z_kd - z_ed);
        double dist5 = MathAbs(z_kd - z_pv);
        double dist6 = MathAbs(z_ed - z_pv);
        
        Raw_KCI[i] = dist1 + dist2 + dist3 + dist4 + dist5 + dist6;
        
        // VISUAL MAPPING: Polarized KCI Oscillator
        double direction = (buf_kd[i] >= 0) ? 1.0 : -1.0;
        KCI_Buffer[i] = 100.0 * MathExp(-decay_constant * Raw_KCI[i]) * direction;
        
        // DYNAMIC COLOR LOGIC
        if(KCI_Buffer[i] >= 0.0) KCI_Color[i] = 0; 
        else KCI_Color[i] = 1;                     
        
        // =========================================================
        // PHASE 3: COGNITIVE VALIDATION ENGINE
        // =========================================================
        if(i < rates_total - 2) 
        {
            double kci_current = Raw_KCI[i];
            double kci_prev1   = Raw_KCI[i+1]; 
            double kci_prev2   = Raw_KCI[i+2];
            
            double v_t1  = close[i+1] - close[i+2];
            double v_t   = close[i] - close[i+1];
            
            bool is_local_min = (kci_prev1 < kci_current) && (kci_prev1 < kci_prev2);
            bool is_extreme   = (kci_prev1 <= CompressionThreshold);
            
            double vol_t1 = (tick_volume[i+1] > 0) ? (double)tick_volume[i+1] : 1.0;
            double vol_t  = (tick_volume[i] > 0)   ? (double)tick_volume[i]   : 1.0;
            
            double E_t1       = vol_t1 * (v_t1 * v_t1);
            double E_t        = vol_t  * (v_t * v_t);
            bool is_energy_drop = (E_t1 < E_t); 
            
            if(is_local_min && is_extreme && is_energy_drop)
            {
                if(v_t1 < 0) Bullish_Buffer[i+1] = 1.0; 
                else Bearish_Buffer[i+1] = 1.0; 
            }
        }
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+