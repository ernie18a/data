//+------------------------------------------------------------------+
//|                                                          KCI.mq5 |
//|                                  Copyright 2026, Syamsurizal D.  |
//|                                       Kinetic Compression Index  |
//+------------------------------------------------------------------+
#property copyright "Syamsurizal Dimjati"
#property link      "https://www.mql5.com/en/users/ritzfalih"
#property version   "1.0"
#property indicator_separate_window

//--- Indicator Plots Configuration
#property indicator_buffers 9
#property indicator_plots   3

//--- Plot 0: KCI_Main & KCI_Color (Color Line requires 2 buffers)
#property indicator_label1  "KCI_Main"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue, clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Plot 1: Signal_Buy (Data buffer, not visually plotted by default)
#property indicator_label2  "Signal_Buy"
#property indicator_type2   DRAW_NONE

//--- Plot 2: Signal_Sell (Data buffer, not visually plotted by default)
#property indicator_label3  "Signal_Sell"
#property indicator_type3   DRAW_NONE

//--- Levels
#property indicator_level1  80.0
#property indicator_level2  0.0
#property indicator_level3 -80.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT

//--- Inputs
input int    ZScorePeriod         = 50;   // Z-Score Normalization Period
input double CompressionThreshold = 2.0;  // Exhaustion Event Threshold
input int    BasePeriod           = 14;   // Kinematic Base Lookback Period

//--- Buffer Arrays (Strictly matching the Unified Buffer Map)
double KCI_Main[];    // 0: INDICATOR_DATA
double KCI_Color[];   // 1: INDICATOR_COLOR_INDEX
double Signal_Buy[];  // 2: INDICATOR_DATA
double Signal_Sell[]; // 3: INDICATOR_DATA
double Internal_VQ[]; // 4: INDICATOR_CALCULATIONS
double Internal_KD[]; // 5: INDICATOR_CALCULATIONS
double Internal_ED[]; // 6: INDICATOR_CALCULATIONS
double Internal_PV[]; // 7: INDICATOR_CALCULATIONS
double Raw_KCI[];     // 8: INDICATOR_CALCULATIONS

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- 1. Set Indicator Buffers Mapping
    SetIndexBuffer(0, KCI_Main,    INDICATOR_DATA);
    SetIndexBuffer(1, KCI_Color,   INDICATOR_COLOR_INDEX);
    SetIndexBuffer(2, Signal_Buy,  INDICATOR_DATA);
    SetIndexBuffer(3, Signal_Sell, INDICATOR_DATA);
    
    SetIndexBuffer(4, Internal_VQ, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, Internal_KD, INDICATOR_CALCULATIONS);
    SetIndexBuffer(6, Internal_ED, INDICATOR_CALCULATIONS);
    SetIndexBuffer(7, Internal_PV, INDICATOR_CALCULATIONS);
    SetIndexBuffer(8, Raw_KCI,     INDICATOR_CALCULATIONS);

    //--- 2. Set Empty Values
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0); // 0.0 = Neutral

    //--- 3. Indicator Name
    string short_name = StringFormat("KCI (%d, %.1f, %d)", ZScorePeriod, CompressionThreshold, BasePeriod);
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    
    // Validate inputs
    if(ZScorePeriod <= 1 || BasePeriod <= 1)
    {
        Print("Error: Periods must be greater than 1.");
        return(INIT_PARAMETERS_INCORRECT);
    }

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Z-Score Calculation Helper                                       |
//+------------------------------------------------------------------+
double GetZScore(const double &arr[], int current_index, int period)
{
    double sum = 0.0;
    for(int j = 0; j < period; j++)
    {
        sum += arr[current_index - j];
    }
    double mean = sum / period;
    
    double sum_sq = 0.0;
    for(int j = 0; j < period; j++)
    {
        sum_sq += MathPow(arr[current_index - j] - mean, 2);
    }
    
    double stddev = MathSqrt(sum_sq / period);
    if(stddev == 0.0) return 0.0; // Prevent division by zero during flat markets
    
    return (arr[current_index] - mean) / stddev;
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
    //--- 1. Check for sufficient history
    int min_history = ZScorePeriod + BasePeriod + 3;
    if(rates_total < min_history) return 0;

    //--- 2. Define starting index (limit)
    int limit;
    if(prev_calculated == 0)
    {
        limit = min_history;
        // Initialize all buffers explicitly for empty history
        ArrayInitialize(KCI_Main, EMPTY_VALUE);
        ArrayInitialize(Signal_Buy, 0.0);
        ArrayInitialize(Signal_Sell, 0.0);
    }
    else
    {
        limit = prev_calculated - 1; 
    }

    //--- 3. Phase 1: Pure Kinematics Calculation
    for(int i = limit; i < rates_total; i++)
    {
        // Velocity Quotient (VQ)
        Internal_VQ[i] = (close[i] - close[i - BasePeriod]) / BasePeriod;
        
        // Calculate SMA for KD and ED
        double sum_close = 0.0;
        for(int j = 0; j < BasePeriod; j++)
        {
            sum_close += close[i - j];
        }
        double sma = sum_close / BasePeriod;
        
        // Kinetic Displacement (KD)
        Internal_KD[i] = close[i] - sma;
        
        // Energy Dispersion (ED) - Standard Deviation proxy
        double sum_sq_close = 0.0;
        for(int j = 0; j < BasePeriod; j++)
        {
            sum_sq_close += MathPow(close[i - j] - sma, 2);
        }
        Internal_ED[i] = MathSqrt(sum_sq_close / BasePeriod);
        
        // Phase Velocity (PV)
        Internal_PV[i] = Internal_VQ[i] - Internal_VQ[i - 1];
    }

    //--- 4. Phase 2: Z-Score Normalization & Polarization
    double decay_constant = 0.22314355 / CompressionThreshold; // -ln(0.8) / Threshold

    for(int i = limit; i < rates_total; i++)
    {
        double vq_z = GetZScore(Internal_VQ, i, ZScorePeriod);
        double kd_z = GetZScore(Internal_KD, i, ZScorePeriod);
        double ed_z = GetZScore(Internal_ED, i, ZScorePeriod);
        double pv_z = GetZScore(Internal_PV, i, ZScorePeriod);
        
        // Raw KCI is the sum of absolute mathematical anomalies
        Raw_KCI[i] = MathAbs(vq_z) + MathAbs(kd_z) + MathAbs(ed_z) + MathAbs(pv_z);
        
        // Polarization
        double direction = (Internal_KD[i] >= 0) ? 1.0 : -1.0;
        double kci_val = 100.0 * MathExp(-decay_constant * Raw_KCI[i]) * direction;
        
        // Clamp values safely between -100 and 100
        KCI_Main[i] = MathMax(-100.0, MathMin(100.0, kci_val));
        
        // Dynamic Color: 0 = clrDodgerBlue (Bullish), 1 = clrRed (Bearish)
        KCI_Color[i] = (KCI_Main[i] >= 0) ? 0 : 1;
    }

    //--- 5. Phase 3: Exhaustion Event Validation (Strictly Non-Repainting)
    // We only evaluate up to rates_total - 2. 
    // This ensures that i, i-1, and i+1 are all completely CLOSED bars.
    int signal_limit = MathMin(rates_total - 2, limit);
    if(prev_calculated == 0) signal_limit = min_history;

    for(int i = signal_limit; i < rates_total - 2; i++)
    {
        // Clear previous state
        Signal_Buy[i] = 0.0;
        Signal_Sell[i] = 0.0;
        
        // Check local minimum (V-shape) in Raw_KCI compression
        bool is_local_min = (Raw_KCI[i] < Raw_KCI[i - 1]) && (Raw_KCI[i] < Raw_KCI[i + 1]);
        bool is_extreme   = (Raw_KCI[i] <= CompressionThreshold);
        
        // Tick volume handling (Zero-volume fallback protection)
        double vol_current = (tick_volume[i] > 0) ? (double)tick_volume[i] : 1.0;
        double vol_prev    = (tick_volume[i - 1] > 0) ? (double)tick_volume[i - 1] : 1.0;
        
        // Energy drop validation
        double E_current = vol_current * MathPow(close[i] - close[i - 1], 2);
        double E_prev    = vol_prev * MathPow(close[i - 1] - close[i - 2], 2);
        
        // If exhaustive compression is detected
        if(is_extreme && is_local_min && (E_current < E_prev))
        {
            if(close[i] < close[i - 1]) 
            {
                Signal_Buy[i] = 1.0; 
            }
            else 
            {
                Signal_Sell[i] = 1.0;
            }
        }
    }

    //--- Return total bars calculated
    return(rates_total);
}
//+------------------------------------------------------------------+