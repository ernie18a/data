//+------------------------------------------------------------------+
//|                                 Standard Deviation smoothing.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#include <MovingAverages.mqh>
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- the iStdDev plot
#property indicator_label1  "StdDev smoothing"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreenYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters 
input int                  Inp_StdDev_ma_period    = 20;          // period of averaging
input int                  Inp_StdDev_ma_shift     = 0;           // shift
input ENUM_MA_METHOD       Inp_StdDev_ma_method    = MODE_SMA;    // type of smoothing
input ENUM_APPLIED_PRICE   Inp_StdDev_applied_price= PRICE_CLOSE; // type of price
//--- indicator buffer 
double StdDevBuffer[];
double StdDevBufferTemp[];
int    handle_iStdDev;        // variable for storing the handle_iStdDev of the iStdDev indicator 
string short_name;            // name of the indicator on a chart 
int    bars_calculated=0;     // we will keep the number of values in the Standard Deviation indicator 
int    m_weightsum;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
   m_weightsum=0;
//--- assignment of array to indicator buffer 
   SetIndexBuffer(0,StdDevBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,StdDevBufferTemp,INDICATOR_CALCULATIONS);
//--- set shift 
   PlotIndexSetInteger(0,PLOT_SHIFT,Inp_StdDev_ma_shift);
//--- create handle_iStdDev of the indicator iStdDev   
   handle_iStdDev=iStdDev(Symbol(),Period(),Inp_StdDev_ma_period,
                          Inp_StdDev_ma_shift,Inp_StdDev_ma_method,Inp_StdDev_applied_price);
//--- if the handle_iStdDev is not created 
   if(handle_iStdDev==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle_iStdDev of the iStdDev indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- show the symbol/timeframe the Standard Deviation indicator is calculated for 
   short_name=StringFormat("StdDev smoothing(%d)",Inp_StdDev_ma_period);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- normal initialization of the indicator   
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
//--- number of values copied from the iStdDev indicator 
   int values_to_copy;
//--- determine the number of values calculated in the indicator 
   int calculated=BarsCalculated(handle_iStdDev);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iStdDev indicator changed 
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iStdDevBuffer array is greater than the number of values in the iStdDev indicator for symbol/period, then we don't copy everything  
      //--- otherwise, we copy less than the size of indicator buffers 
      if(calculated>rates_total)
         values_to_copy=rates_total;
      else
         values_to_copy=calculated;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the array with values of the Standard Deviation indicator 
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArrayFromBuffer(StdDevBufferTemp,Inp_StdDev_ma_shift,handle_iStdDev,values_to_copy))
      return(0);
   if(prev_calculated==0)
      for(int i=0;i<Inp_StdDev_ma_period-1;i++)
         StdDevBufferTemp[i]=0.0;
   switch(Inp_StdDev_ma_method)
     {
      case  MODE_SMA:
         SimpleMAOnBuffer(rates_total,prev_calculated,0,3,StdDevBufferTemp,StdDevBuffer);
         break;
      case  MODE_EMA:
         ExponentialMAOnBuffer(rates_total,prev_calculated,0,3,StdDevBufferTemp,StdDevBuffer);
         break;
      case  MODE_SMMA:
         SmoothedMAOnBuffer(rates_total,prev_calculated,0,3,StdDevBufferTemp,StdDevBuffer);
         break;
      default:
         LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,9,StdDevBufferTemp,StdDevBuffer,m_weightsum);
         break;
     }
//--- memorize the number of values in the Standard Deviation indicator 
   bars_calculated=calculated;
//--- return the prev_calculated value for the next call 
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the iStdDev indicator             | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &std_buffer[],  // indicator buffer of the Standard Deviation line 
                         int std_shift,         // shift of the Standard Deviation line 
                         int ind_handle,        // handle_iStdDev of the iStdDev indicator 
                         int amount             // number of copied values 
                         )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStdDevBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,-std_shift,amount,std_buffer)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStdDev indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//--- everything is fine 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Indicator deinitialization function                              | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason)
  {
//--- clear the chart after deleting the indicator 
   Comment("");
  }
//+------------------------------------------------------------------+
