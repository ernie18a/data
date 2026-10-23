//+------------------------------------------------------------------+
//|                                CCFp(barabashkakvn's edition).mq5 |
//|                                              SemSemFX@rambler.ru |
//|              http://onix-trade.net/forum/index.php?showtopic=107 |
//+------------------------------------------------------------------+
#property copyright "SemSemFX@rambler.ru"
#property link      "http://onix-trade.net/forum/index.php?showtopic=107"
#property version   "1.002"
#property description "The indicator can be started ONLY on these timeframes:"
#property description "                                           M1"
#property description "                                           M5"
#property description "                                           M15"
#property description "                                           M30"
#property description "                                           H1"
#property description "                                           H4"
#property description "                                           D1"
#property description "                                           W1"
#property description "                                           MN1"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   8
//---
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_label1  "USD"
//---
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkBlue
#property indicator_label2  "EUR"
//---
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_label3  "GBP"
//---
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrChocolate
#property indicator_label4  "CHF"
//---
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrMaroon
#property indicator_label5  "JPY"
//---
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrDarkOrange
#property indicator_label6  "AUD"
//---
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrPurple
#property indicator_label7  "CAD"
//---
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrTeal
#property indicator_label8  "NZD"
//--- input parameters
input int                  InpFast_ma_period    = 3;           // Fast MA: averaging period 
input int                  InpSlow_ma_period    = 5;           // Slow MA: averaging period 
input ENUM_MA_METHOD       Inp_ma_method        = MODE_SMA;    // Fast and Slow MA's: smoothing type 
input ENUM_APPLIED_PRICE   Inp_applied_price    = PRICE_CLOSE; // Fast and Slow MA's: type of price 
//---
double ExtUSDBuffer[];
double ExtEURBuffer[];
double ExtGBPBuffer[];
double ExtCHFBuffer[];
double ExtJPYBuffer[];
double ExtAUDBuffer[];
double ExtCADBuffer[];
double ExtNZDBuffer[];

string array_symbols[7] = {"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
int    array_coef[8]    = {1,5,3,2,2,4,6,4};
int    coefficient      = 1;
/*
   M1(1),      M5(M1*5),   M15(M5*3),  M30(M15*2), 
   H1(M30*2),  H4(H1*4),   D1(H4*6),   W1(H4*4),  
*/

int    handles_Fast_EURUSD[];
int    handles_Fast_GBPUSD[];
int    handles_Fast_AUDUSD[];
int    handles_Fast_NZDUSD[];
int    handles_Fast_USDCAD[];
int    handles_Fast_USDCHF[];
int    handles_Fast_USDJPY[];

int    handles_Slow_EURUSD[];
int    handles_Slow_GBPUSD[];
int    handles_Slow_AUDUSD[];
int    handles_Slow_NZDUSD[];
int    handles_Slow_USDCAD[];
int    handles_Slow_USDCHF[];
int    handles_Slow_USDJPY[];
//--- indicator buffers mapping
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Period()!=PERIOD_M1 &&
      Period()!=PERIOD_M5 &&
      Period()!=PERIOD_M15 &&
      Period()!=PERIOD_M30 &&
      Period()!=PERIOD_H1 &&
      Period()!=PERIOD_H4 &&
      Period()!=PERIOD_D1 &&
      Period()!=PERIOD_W1 &&
      Period()!=PERIOD_MN1)
     {
      Alert("The indicator can be started ONLY on these timeframes: M1, M5, M15, M30, H1, H4, D1, W1, MN1");
      return(INIT_FAILED);
     }
//---
   int total_symbols=ArraySize(array_symbols);
   int total_coef=ArraySize(array_coef);
   int start_coef=1;
   switch(Period())
     {
      case  PERIOD_M1:
         start_coef=0;
         break;
      case  PERIOD_M5:
         start_coef=1;
         break;
      case  PERIOD_M15:
         start_coef=2;
         break;
      case  PERIOD_M30:
         start_coef=3;
         break;
      case  PERIOD_H1:
         start_coef=4;
         break;
      case  PERIOD_H4:
         start_coef=5;
         break;
      case  PERIOD_D1:
         start_coef=6;
         break;
     }

   for(int i=0;i<total_symbols;i++)
      for(int j=start_coef;j<total_coef;j++)
        {
         coefficient=(j==start_coef)?1:coefficient*array_coef[j];
         int Fast_handle;
         if(!CreateMA(array_symbols[i],Period(),InpFast_ma_period*coefficient,0,Inp_ma_method,Inp_applied_price,Fast_handle))
            return(INIT_FAILED);
         int Slow_handle;
         if(!CreateMA(array_symbols[i],Period(),InpSlow_ma_period*coefficient,0,Inp_ma_method,Inp_applied_price,Slow_handle))
            return(INIT_FAILED);
         //---
         int size=-1;
         switch(i)
           {
            case  0:
               size=ArraySize(handles_Fast_EURUSD);
               ArrayResize(handles_Fast_EURUSD,size+1);
               handles_Fast_EURUSD[size]=Fast_handle;

               size=ArraySize(handles_Slow_EURUSD);
               ArrayResize(handles_Slow_EURUSD,size+1);
               handles_Slow_EURUSD[size]=Slow_handle;
               break;
            case  1:
               size=ArraySize(handles_Fast_GBPUSD);
               ArrayResize(handles_Fast_GBPUSD,size+1);
               handles_Fast_GBPUSD[size]=Fast_handle;

               size=ArraySize(handles_Slow_GBPUSD);
               ArrayResize(handles_Slow_GBPUSD,size+1);
               handles_Slow_GBPUSD[size]=Slow_handle;
               break;
            case  2:
               size=ArraySize(handles_Fast_AUDUSD);
               ArrayResize(handles_Fast_AUDUSD,size+1);
               handles_Fast_AUDUSD[size]=Fast_handle;

               size=ArraySize(handles_Slow_AUDUSD);
               ArrayResize(handles_Slow_AUDUSD,size+1);
               handles_Slow_AUDUSD[size]=Slow_handle;
               break;
            case  3:
               size=ArraySize(handles_Fast_NZDUSD);
               ArrayResize(handles_Fast_NZDUSD,size+1);
               handles_Fast_NZDUSD[size]=Fast_handle;

               size=ArraySize(handles_Slow_NZDUSD);
               ArrayResize(handles_Slow_NZDUSD,size+1);
               handles_Slow_NZDUSD[size]=Slow_handle;
               break;
            case  4:
               size=ArraySize(handles_Fast_USDCAD);
               ArrayResize(handles_Fast_USDCAD,size+1);
               handles_Fast_USDCAD[size]=Fast_handle;

               size=ArraySize(handles_Slow_USDCAD);
               ArrayResize(handles_Slow_USDCAD,size+1);
               handles_Slow_USDCAD[size]=Slow_handle;
               break;
            case  5:
               size=ArraySize(handles_Fast_USDCHF);
               ArrayResize(handles_Fast_USDCHF,size+1);
               handles_Fast_USDCHF[size]=Fast_handle;

               size=ArraySize(handles_Slow_USDCHF);
               ArrayResize(handles_Slow_USDCHF,size+1);
               handles_Slow_USDCHF[size]=Slow_handle;
               break;
            case  6:
               size=ArraySize(handles_Fast_USDJPY);
               ArrayResize(handles_Fast_USDJPY,size+1);
               handles_Fast_USDJPY[size]=Fast_handle;

               size=ArraySize(handles_Slow_USDJPY);
               ArrayResize(handles_Slow_USDJPY,size+1);
               handles_Slow_USDJPY[size]=Slow_handle;
               break;
           }
        }

   int size=ArraySize(handles_Fast_EURUSD);
   if(size!=ArraySize(handles_Slow_EURUSD) ||
      size!=ArraySize(handles_Fast_GBPUSD) || size!=ArraySize(handles_Slow_GBPUSD) ||
      size!=ArraySize(handles_Fast_AUDUSD) || size!=ArraySize(handles_Slow_AUDUSD) ||
      size!=ArraySize(handles_Fast_NZDUSD) || size!=ArraySize(handles_Slow_NZDUSD) ||
      size!=ArraySize(handles_Fast_USDCAD) || size!=ArraySize(handles_Slow_USDCAD) ||
      size!=ArraySize(handles_Fast_USDCHF) || size!=ArraySize(handles_Slow_USDCHF) ||
      size!=ArraySize(handles_Fast_USDJPY) || size!=ArraySize(handles_Slow_USDJPY) ||
      size!=ArraySize(handles_Fast_GBPUSD) || size!=ArraySize(handles_Slow_GBPUSD) ||
      size!=ArraySize(handles_Fast_GBPUSD) || size!=ArraySize(handles_Slow_GBPUSD))
     {
      Alert("ArraySize !=");
      return(INIT_FAILED);
     }
//---
   double array_EURUSD[];
   double array_GBPUSD[];
   double array_AUDUSD[];
   double array_NZDUSD[];
   double array_USDCAD[];
   double array_USDCHF[];
   double array_USDJPY[];
   CopyClose("EURUSD",Period(),0,1000,array_EURUSD);
   CopyClose("GBPUSD",Period(),0,1000,array_GBPUSD);
   CopyClose("AUDUSD",Period(),0,1000,array_AUDUSD);
   CopyClose("NZDUSD",Period(),0,1000,array_NZDUSD);
   CopyClose("USDCAD",Period(),0,1000,array_USDCAD);
   CopyClose("USDCHF",Period(),0,1000,array_USDCHF);
   CopyClose("USDJPY",Period(),0,1000,array_USDJPY);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtUSDBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtEURBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtGBPBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCHFBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtJPYBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtAUDBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtCADBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,ExtNZDBuffer,INDICATOR_DATA);
//--- set an empty value 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0.0);
//---
   ArraySetAsSeries(ExtUSDBuffer,true);
   ArraySetAsSeries(ExtEURBuffer,true);
   ArraySetAsSeries(ExtGBPBuffer,true);
   ArraySetAsSeries(ExtCHFBuffer,true);
   ArraySetAsSeries(ExtJPYBuffer,true);
   ArraySetAsSeries(ExtAUDBuffer,true);
   ArraySetAsSeries(ExtCADBuffer,true);
   ArraySetAsSeries(ExtNZDBuffer,true);
//---
   ArrayInitialize(ExtUSDBuffer,0.0);
   ArrayInitialize(ExtEURBuffer,0.0);
   ArrayInitialize(ExtGBPBuffer,0.0);
   ArrayInitialize(ExtCHFBuffer,0.0);
   ArrayInitialize(ExtJPYBuffer,0.0);
   ArrayInitialize(ExtAUDBuffer,0.0);
   ArrayInitialize(ExtCADBuffer,0.0);
   ArrayInitialize(ExtNZDBuffer,0.0);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
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
//---
   int bars_EURUSD=Bars("EURUSD",Period());
   int bars_GBPUSD=Bars("GBPUSD",Period());
   int bars_AUDUSD=Bars("AUDUSD",Period());
   int bars_NZDUSD=Bars("NZDUSD",Period());
   int bars_USDCAD=Bars("USDCAD",Period());
   int bars_USDCHF=Bars("USDCHF",Period());
   int bars_USDJPY=Bars("USDJPY",Period());
/*   
   Comment("EURUSD ",bars_EURUSD,"\n",
           "GBPUSD ",bars_GBPUSD,"\n",
           "AUDUSD ",bars_AUDUSD,"\n",
           "NZDUSD ",bars_NZDUSD,"\n",
           "USDCAD ",bars_USDCAD,"\n",
           "USDCHF ",bars_USDCHF,"\n",
           "USDJPY ",bars_USDJPY);
*/
   if(bars_EURUSD==0 || bars_GBPUSD==0 || bars_AUDUSD==0 ||
      bars_NZDUSD==0 || bars_USDCAD==0 || bars_USDCHF==0 ||
      bars_USDJPY==0)
      return(0);

   int size=ArraySize(handles_Fast_EURUSD);
   for(int i=0;i<size;i++)
     {
      if(BarsCalculated(handles_Fast_EURUSD[i])!=bars_EURUSD)
         return(0);
      if(BarsCalculated(handles_Fast_GBPUSD[i])!=bars_GBPUSD)
         return(0);
      if(BarsCalculated(handles_Fast_AUDUSD[i])!=bars_AUDUSD)
         return(0);
      if(BarsCalculated(handles_Fast_NZDUSD[i])!=bars_NZDUSD)
         return(0);;
      if(BarsCalculated(handles_Fast_USDCAD[i])!=bars_USDCAD)
         return(0);;
      if(BarsCalculated(handles_Fast_USDCHF[i])!=bars_USDCHF)
         return(0);
      if(BarsCalculated(handles_Fast_USDJPY[i])!=bars_USDJPY)
         return(0);

      if(BarsCalculated(handles_Slow_EURUSD[i])!=bars_EURUSD)
         return(0);
      if(BarsCalculated(handles_Slow_GBPUSD[i])!=bars_GBPUSD)
         return(0);
      if(BarsCalculated(handles_Slow_AUDUSD[i])!=bars_AUDUSD)
         return(0);
      if(BarsCalculated(handles_Slow_NZDUSD[i])!=bars_NZDUSD)
         return(0);
      if(BarsCalculated(handles_Slow_USDCAD[i])!=bars_USDCAD)
         return(0);
      if(BarsCalculated(handles_Slow_USDCHF[i])!=bars_USDCHF)
         return(0);
      if(BarsCalculated(handles_Slow_USDJPY[i])!=bars_USDJPY)
         return(0);
     }
//---
   int array_bars[7];
   array_bars[0]=bars_EURUSD;
   array_bars[1]=bars_GBPUSD;
   array_bars[2]=bars_AUDUSD;
   array_bars[3]=bars_NZDUSD;
   array_bars[4]=bars_USDCAD;
   array_bars[5]=bars_USDCHF;
   array_bars[6]=bars_USDJPY;
   int limit=INT_MAX; // "0" -> the leftmost bar on the chart
   if(prev_calculated==0)
     {
      size=ArraySize(array_bars);
      for(int i=0;i<size;i++)
        {
         if(limit>array_bars[i])
            limit=array_bars[i];
        }
      int index=coefficient*(int)MathMax((double)InpFast_ma_period,(double)InpSlow_ma_period);
      limit=(int)MathMin(index,limit);
     }
   else
      limit=rates_total-prev_calculated+1;
//--- the main loop of calculations
   size=ArraySize(handles_Fast_EURUSD);
   double ma_Fast = 0.0;
   double ma_Slow = 0.0;
   double ma      = 0.0;
   for(int i=limit;i>=0 && !IsStopped();i--)
     {
      //---
      ma_Fast=0.0;
      ma_Slow=0.0;
      for(int j=0;j<size;j++)
        {
         ma=iMAGet(handles_Fast_EURUSD[j],i);
         if(ma==0.0)
            return(0);
         ma_Fast+=ma;

         ma=iMAGet(handles_Slow_EURUSD[j],i);
         if(ma==0.0)
            return(0);
         ma_Slow+=ma;
        }
      if(ma_Slow==0.0 || ma_Fast==0.0)
         return(0);
      double EURUSD=ma_Slow/ma_Fast;
      if(EURUSD==0.0)
         return(0);

      ma_Fast=0.0;
      ma_Slow=0.0;
      for(int j=0;j<size;j++)
        {
         ma=iMAGet(handles_Fast_GBPUSD[j],i);
         if(ma==0.0)
            return(0);
         ma_Fast+=ma;

         ma=iMAGet(handles_Slow_GBPUSD[j],i);
         if(ma==0.0)
            return(0);
         ma_Slow+=ma;
        }
      if(ma_Slow==0.0 || ma_Fast==0.0)
         return(0);
      double GBPUSD=ma_Slow/ma_Fast;
      if(GBPUSD==0.0)
         return(0);

      ma_Fast=0.0;
      ma_Slow=0.0;
      for(int j=0;j<size;j++)
        {
         ma=iMAGet(handles_Fast_AUDUSD[j],i);
         if(ma==0.0)
            return(0);
         ma_Fast+=ma;

         ma=iMAGet(handles_Slow_AUDUSD[j],i);
         if(ma==0.0)
            return(0);
         ma_Slow+=ma;
        }
      if(ma_Slow==0.0 || ma_Fast==0.0)
         return(0);
      double AUDUSD=ma_Slow/ma_Fast;
      if(AUDUSD==0.0)
         return(0);

      ma_Fast=0.0;
      ma_Slow=0.0;
      for(int j=0;j<size;j++)
        {
         ma=iMAGet(handles_Fast_NZDUSD[j],i);
         if(ma==0.0)
            return(0);
         ma_Fast+=ma;

         ma=iMAGet(handles_Slow_NZDUSD[j],i);
         if(ma==0.0)
            return(0);
         ma_Slow+=ma;
        }
      if(ma_Slow==0.0 || ma_Fast==0.0)
         return(0);
      double NZDUSD=ma_Slow/ma_Fast;
      if(NZDUSD==0.0)
         return(0);

      ma_Fast=0.0;
      ma_Slow=0.0;
      for(int j=0;j<size;j++)
        {
         ma=iMAGet(handles_Fast_USDCAD[j],i);
         if(ma==0.0)
            return(0);
         ma_Fast+=ma;

         ma=iMAGet(handles_Slow_USDCAD[j],i);
         if(ma==0.0)
            return(0);
         ma_Slow+=ma;
        }
      if(ma_Slow==0.0 || ma_Fast==0.0)
         return(0);
      double CADUSD=ma_Fast/ma_Slow;
      if(CADUSD==0.0)
         return(0);

      ma_Fast=0.0;
      ma_Slow=0.0;
      for(int j=0;j<size;j++)
        {
         ma=iMAGet(handles_Fast_USDCHF[j],i);
         if(ma==0.0)
            return(0);
         ma_Fast+=ma;

         ma=iMAGet(handles_Slow_USDCHF[j],i);
         if(ma==0.0)
            return(0);
         ma_Slow+=ma;
        }
      if(ma_Slow==0.0 || ma_Fast==0.0)
         return(0);
      double CHFUSD=ma_Fast/ma_Slow;
      if(CHFUSD==0.0)
         return(0);

      ma_Fast=0.0;
      ma_Slow=0.0;
      for(int j=0;j<size;j++)
        {
         ma=iMAGet(handles_Fast_USDJPY[j],i);
         if(ma==0.0)
            return(0);
         ma_Fast+=ma;

         ma=iMAGet(handles_Slow_USDJPY[j],i);
         if(ma==0.0)
            return(0);
         ma_Slow+=ma;
        }
      if(ma_Slow==0.0 || ma_Fast==0.0)
         return(0);
      double JPYUSD=ma_Fast/ma_Slow;
      if(JPYUSD==0.0)
         return(0);

      double sum=EURUSD+GBPUSD+AUDUSD+NZDUSD+CHFUSD+CADUSD+JPYUSD;
      //---
      ExtUSDBuffer[i] = sum-7.0;
      ExtEURBuffer[i] = (sum-EURUSD+1.0)/EURUSD-7.0;
      ExtGBPBuffer[i] = (sum-GBPUSD+1.0)/GBPUSD-7.0;
      ExtAUDBuffer[i] = (sum-AUDUSD+1.0)/AUDUSD-7.0;
      ExtNZDBuffer[i] = (sum-NZDUSD+1.0)/NZDUSD-7.0;
      ExtCADBuffer[i] = (sum-CADUSD+1.0)/CADUSD-7.0;
      ExtCHFBuffer[i] = (sum-CHFUSD+1.0)/CHFUSD-7.0;
      ExtJPYBuffer[i] = (sum-JPYUSD+1.0)/JPYUSD-7.0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Create Moving Average                                            |
//+------------------------------------------------------------------+
bool CreateMA(const string       symbol,// symbol name 
              ENUM_TIMEFRAMES    period,           // period 
              int                ma_period,        // averaging period 
              int                ma_shift,         // horizontal shift 
              ENUM_MA_METHOD     ma_method,        // smoothing type 
              ENUM_APPLIED_PRICE applied_price,    // type of price 
              int &handle_iMA                      // handle
              )
  {
   ResetLastError();
//--- create handle of the indicator iMA
   handle_iMA=iMA(symbol,period,ma_period,ma_shift,ma_method,applied_price);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s,%s, av. period %d, shift %d, smoothing %s, price %s,error code %d",
                  symbol,
                  EnumToString(period),
                  ma_period,
                  ma_shift,
                  EnumToString(ma_method),
                  EnumToString(applied_price),
                  GetLastError());
      //--- the indicator is stopped early 
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int handle_iMA,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
