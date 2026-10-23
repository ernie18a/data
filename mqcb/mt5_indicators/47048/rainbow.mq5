//+------------------------------------------------------------------+
//|                                                      Rainbow.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Müller Péter"
#property link      "https://www.mql5.com/en/users/mullerp04/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 6
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_LINE
#property indicator_type5 DRAW_LINE
#property indicator_type6 DRAW_LINE
#property indicator_color1 clrRed
#property indicator_color2 clrOrange
#property indicator_color3 clrYellow
#property indicator_color4 clrYellowGreen
#property indicator_color5 clrAliceBlue
#property indicator_color6 clrBlue

int High;
int Low;
int Atr;
   
input double AtrMultiplier = 1;
input int period = 20;

double FirstBuffer[];
double SecondBuffer[];
double ThirdBuffer[];
double FourthBuffer[];
double FifthBuffer[];
double SixthBuffer[];


int OnInit()
  {
   SetIndexBuffer(0,FirstBuffer);
   SetIndexBuffer(1,SecondBuffer);
   SetIndexBuffer(2,ThirdBuffer);
   SetIndexBuffer(3,FourthBuffer);
   SetIndexBuffer(4,FifthBuffer);
   SetIndexBuffer(5,SixthBuffer);
   string short_name="Period( "+IntegerToString(period)+" )" + _Symbol;
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,100);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,100);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,100);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,100);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,100);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,100);
   High = iMA(_Symbol,PERIOD_CURRENT,period,0,MODE_SMA,PRICE_HIGH);
   Low = iMA(_Symbol,PERIOD_CURRENT,period,0,MODE_SMA,PRICE_LOW);
   Atr = iATR(_Symbol,PERIOD_CURRENT,period);
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
   if(rates_total < period) 
      return 0;

   ArraySetAsSeries(FirstBuffer,false);
   ArraySetAsSeries(SecondBuffer,false);
   ArraySetAsSeries(ThirdBuffer,false);
   ArraySetAsSeries(FourthBuffer,false);
   ArraySetAsSeries(FifthBuffer,false);
   ArraySetAsSeries(SixthBuffer,false);
   for(int i = prev_calculated; i < rates_total;i++)
   {
      double HighMa[1],LowMa[1],currAtr[1];
      CopyBuffer(High,0,rates_total-i,1,HighMa);
      CopyBuffer(Low,0,rates_total-i,1,LowMa);
      CopyBuffer(Atr,0,rates_total-i,1,currAtr);
      FirstBuffer[i] = HighMa[0] + 2*AtrMultiplier*currAtr[0];
      SecondBuffer[i] = HighMa[0] + AtrMultiplier*currAtr[0];
      ThirdBuffer[i] = HighMa[0];
      FourthBuffer[i] = LowMa[0];
      FifthBuffer[i] = LowMa[0]-AtrMultiplier*currAtr[0];
      SixthBuffer[i] = LowMa[0]-2*AtrMultiplier*currAtr[0];
   }
   return(rates_total);
  }
//+------------------------------------------------------------------+
