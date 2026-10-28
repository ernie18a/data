//+------------------------------------------------------------------+
//|                                                          PTB.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   9
//--- plot shortHigh
#property indicator_label1  "shortHigh"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot shortLow
#property indicator_label2  "shortLow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
//--- plot longHigh
#property indicator_label3  "longHigh"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  3
//--- plot longLow
#property indicator_label4  "longLow"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrange
#property indicator_style4  STYLE_SOLID
#property indicator_width4  3
//--- plot fibo786
#property indicator_label5  "fibo786"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrPurple
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot fibo236
#property indicator_label6  "fibo236"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrAqua
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot fibo382
#property indicator_label7  "fibo382"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrYellow
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot fibo618
#property indicator_label8  "fibo618"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBrown
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot fibo50
#property indicator_label9  "fibo50"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrWhite
#property indicator_style9  STYLE_SOLID
#property indicator_width9  3
//--- input parameters
input int      shortLength;
input int      longLength;
//--- indicator buffers
double         shortHighBuffer[];
double         shortLowBuffer[];
double         longHighBuffer[];
double         longLowBuffer[];
double         fibo786Buffer[];
double         fibo236Buffer[];
double         fibo382Buffer[];
double         fibo618Buffer[];
double         fibo50Buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0,shortHighBuffer,INDICATOR_DATA);
    SetIndexBuffer(1,shortLowBuffer,INDICATOR_DATA);
    SetIndexBuffer(2,longHighBuffer,INDICATOR_DATA);
    SetIndexBuffer(3,longLowBuffer,INDICATOR_DATA);
    SetIndexBuffer(4,fibo786Buffer,INDICATOR_DATA);
    SetIndexBuffer(5,fibo236Buffer,INDICATOR_DATA);
    SetIndexBuffer(6,fibo382Buffer,INDICATOR_DATA);
    SetIndexBuffer(7,fibo618Buffer,INDICATOR_DATA);
    SetIndexBuffer(8,fibo50Buffer,INDICATOR_DATA);
   
    //---
    return(INIT_SUCCEEDED);
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
    // Đảm bảo có đủ dữ liệu để tính toán
    if (rates_total < shortLength || rates_total < longLength)
        return (0);  // Không đủ dữ liệu để vẽ

    // Vòng lặp bắt đầu từ vị trí prev_calculated hoặc 0 nếu là lần đầu
    int start = prev_calculated > 0 ? prev_calculated - 1 : MathMax(shortLength, longLength);
    
    for (int i = start; i < rates_total; i++)
    {
        // Tính toán shortHigh và shortLow
        double highestHigh = high[i];
        double lowestLow = low[i];
        
        for (int j = 1; j < shortLength; j++)
        {
            if (high[i - j] > highestHigh)
                highestHigh = high[i - j];
            if (low[i - j] < lowestLow)
                lowestLow = low[i - j];
        }
        
        // Gán giá trị cao nhất và thấp nhất cho các buffer short
        shortHighBuffer[i] = highestHigh;
        shortLowBuffer[i] = lowestLow;
        
        // Tính toán longHigh và longLow
        double longHighestHigh = high[i];
        double longLowestLow = low[i];
        
        for (int j = 1; j < longLength; j++)
        {
            if (high[i - j] > longHighestHigh)
                longHighestHigh = high[i - j];
            if (low[i - j] < longLowestLow)
                longLowestLow = low[i - j];
        }
        
        // Gán giá trị cao nhất và thấp nhất cho các buffer long
        longHighBuffer[i] = longHighestHigh;
        longLowBuffer[i] = longLowestLow;

        // Tính toán các mức Fibonacci dựa trên longHigh và longLow
        double range = longHighestHigh - longLowestLow;
        fibo236Buffer[i] = longLowestLow + range * 0.236;
        fibo382Buffer[i] = longLowestLow + range * 0.382;
        fibo50Buffer[i]   = longLowestLow + range * 0.5;
        fibo618Buffer[i]  = longLowestLow + range * 0.618;
        fibo786Buffer[i]  = longLowestLow + range * 0.786;
    }
    
    // Trả về số lượng nến đã tính toán để lần sau tiếp tục
    return (rates_total);
}

//+------------------------------------------------------------------+
