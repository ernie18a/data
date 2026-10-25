//+------------------------------------------------------------------+
//|                                                      iTC_iMA.mq5 |
//|                                        Programing 2013, Prozorov |
//|                                                  prozavf@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Gennadiy Stanilevych"
#property link      "moremoneysystem@gmail.com"
#property version   "1.00"

 
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- Constructing iMA
#property indicator_label1  "iMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrAqua
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2


input int                  ma_shift=0;                   // Shift
input ENUM_MA_METHOD       ma_method=MODE_SMA;           // Smoothing type
input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE;    // Price type

double         iMABuffer[];
int    handle;
string name;
string short_name;
int    bars_calculated=0;
int PeriodI;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,iMABuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_SHIFT,ma_shift);  
  // PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,IndColor);
   name=_Symbol;
  PeriodCalc();
  int ma_period=PeriodI;
  handle=iMA(name,0,ma_period,ma_shift,ma_method,applied_price);
   if(handle==INVALID_HANDLE)
     {
      Print("Failed to create the indicator handle of iTC_iMA  ");
      return(INIT_FAILED);
     }
   short_name="iTC_iMa";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   return(INIT_SUCCEEDED);
  }
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
   int values_to_copy;
   int calculated=BarsCalculated(handle);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      if(calculated>rates_total) values_to_copy=rates_total;
      else                       values_to_copy=calculated;
     }
   else
     {
      values_to_copy=(rates_total-prev_calculated)+1;
     }
   if(!FillArrayFromBuffer(iMABuffer,ma_shift,handle,values_to_copy)) return(0);
   string comm=StringFormat("%s ==>  Indicator period updated %s: %d",
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
                            short_name,
                            PeriodI);
   Comment(comm);
   bars_calculated=calculated;
   return(rates_total);
  }
bool FillArrayFromBuffer(double &values[],   // the indicator buffer of the Moving Average values
                         int shift,          // shift
                         int ind_handle,     // handle of the iMA indicator
                         int amount          // the number of copied values
                         )
  {
   ResetLastError();
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0)
     {
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      return(false);
     }
   return(true);
  }
void OnDeinit(const int reason)
  {
   Comment("");
  }     

int PeriodCalc()
{
 datetime from;
 datetime to;
 int k;
 long h;
 if (ChartPeriod(0)==PERIOD_MN1){ PeriodI=12; return(0);}
 if (ChartPeriod(0)==PERIOD_W1){ PeriodI=52; return(0);}
 if (ChartPeriod(0)==PERIOD_D1)
 {
   k=0;
   if ( SymbolInfoSessionTrade(Symbol(),SUNDAY,0,from,to)) k++;
   if ( SymbolInfoSessionTrade(Symbol(),MONDAY,0,from,to)) k++;
   if ( SymbolInfoSessionTrade(Symbol(),TUESDAY,0,from,to)) k++;
   if ( SymbolInfoSessionTrade(Symbol(),WEDNESDAY,0,from,to)) k++;
   if ( SymbolInfoSessionTrade(Symbol(),THURSDAY,0,from,to)) k++;
   if ( SymbolInfoSessionTrade(Symbol(),FRIDAY,0,from,to)) k++;
   if ( SymbolInfoSessionTrade(Symbol(),SATURDAY,0,from,to)) k++;
   
  
   PeriodI=22;
   if (k==6) PeriodI=26;
   return(0);
 }
 int pers=PeriodSeconds(0); 
 if (pers>=3600)
 {
   k=0;
   h=0;
   if ( SymbolInfoSessionTrade(Symbol(),SUNDAY,0,from,to)) 
   {
     if (from>0||to>0) h=h+(to-from); else h=h+86400; 
   }
   if ( SymbolInfoSessionTrade(Symbol(),MONDAY,0,from,to))
   {
      if (from>0||to>0) h=h+(to-from); else h=h+86400; 
   }
   if ( SymbolInfoSessionTrade(Symbol(),TUESDAY,0,from,to))
   {
      if (from>0||to>0) h=h+(to-from); else h=h+86400; 
   }
   if ( SymbolInfoSessionTrade(Symbol(),WEDNESDAY,0,from,to))
   {
      if (from>0||to>0) h=h+(to-from); else h=h+86400; 
   }
   if ( SymbolInfoSessionTrade(Symbol(),THURSDAY,0,from,to)) 
   {
      if (from>0||to>0) h=h+(to-from); else h=h+86400; 
   }
   if ( SymbolInfoSessionTrade(Symbol(),FRIDAY,0,from,to))
   {
      if (from>0||to>0)h=h+(to-from); else h=h+86400; 
   }
   if ( SymbolInfoSessionTrade(Symbol(),SATURDAY,0,from,to)) 
   {
      if (from>0||to>0) h=h+(to-from); else h=h+86400; 
   }
   Print ("  ------   h= "  ,h);
   PeriodI=h/pers;
   
 
 }
 else
 {
   h=0;
   if ( SymbolInfoSessionTrade(Symbol(),WEDNESDAY,0,from,to))
   {
      if (from>0||to>0) h=(to-from); else h=86400; 
   }
   PeriodI=h/pers;
 }
 
 return(0);
}
