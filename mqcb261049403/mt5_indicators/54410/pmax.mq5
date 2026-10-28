#property copyright "Mahmut Deniz"
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   4

#property indicator_label1  "SuperTrend"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrWhite,clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Direnc"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDimGray
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

#property indicator_label3  "Destek"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDimGray
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

#property indicator_label4  "Trend"
#property indicator_type4   DRAW_NONE

#property indicator_label6  "MA7"
#property indicator_color6  clrGreenYellow
#property indicator_type6   DRAW_LINE
#property indicator_width6  1

// Input parameters
input int           AtrPeriod = 26;                              // ATR Period
input double        multiplier = 3;                              // Multiplier
input int           MovingAveragePeriod = 5;                     // Moving Average Period
input ENUM_APPLIED_PRICE PriceType = PRICE_CLOSE;                // Applied Price
input bool          ShowMovingAverage = false;                   // Show Moving Average?
input ENUM_MA_METHOD MovingAverageMetod = MODE_SMA;              // Moving Average Method

// Buffers
double ST[], Direnc[], Destek[];
double TrendBuffer[], atrBuffer[], maBuffer[], Up[], Down[], Renk[];
int atr, ima;

// Trend enumeration
enum TREND_TYPE {
    NO_TREND = 0,
    BUY = 1,
    SELL = 2
};

//+------------------------------------------------------------------+
//| Custom indicator initialization function                           |
//+------------------------------------------------------------------+
int OnInit() {
    string info = StringFormat("PMAX \nAtr: %d\nMultiplier: %G\nMA: %d",AtrPeriod, multiplier, MovingAveragePeriod);
    info += StringFormat("\n%s", EnumToString(PriceType));
    IndicatorSetString(INDICATOR_SHORTNAME, info);

    atr = iATR(NULL, PERIOD_CURRENT, AtrPeriod);
    ima = iMA(NULL, PERIOD_CURRENT, MovingAveragePeriod, 0, MovingAverageMetod, PriceType);
    
    // Set Index Buffers
    SetIndexBuffer(0, ST, INDICATOR_DATA);
    SetIndexBuffer(1, Renk, INDICATOR_COLOR_INDEX);
    SetIndexBuffer(2, Direnc, INDICATOR_DATA);
    SetIndexBuffer(3, Destek, INDICATOR_DATA);
    SetIndexBuffer(4, TrendBuffer, INDICATOR_DATA);
    SetIndexBuffer(5, maBuffer, INDICATOR_DATA);  
    SetIndexBuffer(6, atrBuffer, INDICATOR_DATA);
    SetIndexBuffer(7, Up, INDICATOR_DATA);
    SetIndexBuffer(8, Down, INDICATOR_DATA);
    
    InitBuffers(indicator_buffers, AtrPeriod);
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
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
                const int &spread[]) {
    
    if(rates_total < 100) return 0; // Minimum required bars check
    
    int start;
    if(prev_calculated == 0) {
        start = 100; // Starting point for first calculation
        ArrayInitialize(ST, 0.0);
        ArrayInitialize(Renk, 0.0);
        ArrayInitialize(Direnc, 0.0);
        ArrayInitialize(Destek, 0.0);
        ArrayInitialize(TrendBuffer, 0.0);
        ArrayInitialize(Up, 0.0);
        ArrayInitialize(Down, 0.0);
    } else {
        start = prev_calculated - 1; // Recalculate last bar
    }

    // Update ATR and MA data
    if(!FillArrayFromBuffer(maBuffer, 0, ima, rates_total, 0)) return 0;
    if(!FillArrayFromBuffer(atrBuffer, 0, atr, rates_total, 0)) return 0;

    // Calculate SuperTrend
    for(int i = start; i < rates_total; i++) {
        double HL2 = maBuffer[i-1];
        double PHL2 = maBuffer[i-2];
        
        // Calculate Up and Down levels
        Up[i] = HL2 + (multiplier * atrBuffer[i]);
        Down[i] = HL2 - (multiplier * atrBuffer[i]);
        
        // Calculate Resistance
        Direnc[i] = (PHL2 > Up[i-1]) ? MathMax(Up[i], Up[i-1]) : Up[i];
        Direnc[i] = (Up[i] < Direnc[i-1] || PHL2 > Direnc[i-1]) ? Up[i] : Direnc[i-1];
        
        // Calculate Support
        Destek[i] = (PHL2 < Down[i-1]) ? MathMin(Down[i], Down[i-1]) : Down[i];
        Destek[i] = (Down[i] > Destek[i-1] || PHL2 < Destek[i-1]) ? Down[i] : Destek[i-1];
        
        // Determine trend
        TREND_TYPE x = NO_TREND;
        if (HL2 > Direnc[i-1]) x = BUY;
        if (HL2 < Destek[i-1]) x = SELL;
        
        TrendBuffer[i] = (x == NO_TREND) ? TrendBuffer[i-1] : x;
        
        // Set colors and values based on trend
        if (TrendBuffer[i] == BUY) {
            Renk[i] = 1;
            ST[i] = Destek[i];
        }
        if (TrendBuffer[i] == SELL) {
            Renk[i] = 2;
            ST[i] = Direnc[i];
        }
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    if(ima != INVALID_HANDLE) IndicatorRelease(ima);
    if(atr != INVALID_HANDLE) IndicatorRelease(atr);
    Comment("");
}

//+------------------------------------------------------------------+
//| Fill array from indicator buffer                                   |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],
                        int idx,
                        int ind_handle,
                        int amount,
                        int start_pos=0) {
    ResetLastError();
    if(amount == 0) {
        Print("Requested copy amount is 0!");
        return false;
    }
    
    if(CopyBuffer(ind_handle, idx, start_pos, amount, values) < 0) {
        PrintFormat("Failed to copy data, error code %d", GetLastError());
        PrintFormat("StartFrom: %d, CopyAmount: %d, ArraySize: %d",
                   start_pos, amount, ArraySize(values));
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Initialize indicator buffers                                       |
//+------------------------------------------------------------------+
void InitBuffers(int numberOfBuffer, int idx_start_bar) {
    for(int i = 0; i < numberOfBuffer; i++) {
        PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, idx_start_bar);
        PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);
    }
}