//+------------------------------------------------------------------+
//|                                 Crossover on the current bar.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot Crossover
#property indicator_label1  "Crossover"
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrBlue,clrRed,clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input group           "MA Fast"
input int                  Inp_MA_Fast_ma_period      = 12;          // MA Fast: averaging period
input int                  Inp_MA_Fast_ma_shift       = 0;           // MA Fast: horizontal shift
input ENUM_MA_METHOD       Inp_MA_Fast_ma_method      = MODE_SMA;    // MA Fast: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_Fast_applied_price  = PRICE_CLOSE; // MA Fast: type of price
input group           "MA Slow"
input int                  Inp_MA_Slow_ma_period      = 26;          // MA Slow: averaging period
input int                  Inp_MA_Slow_ma_shift       = 0;           // MA Slow: horizontal shift
input ENUM_MA_METHOD       Inp_MA_Slow_ma_method      = MODE_SMA;    // MA Slow: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_Slow_applied_price  = PRICE_CLOSE; // MA Slow: type of price
//--- indicator buffers
double   CrossoverBuffer[];
double   ColorBuffer[];
double   iMAFastBuffer[];
double   iMASlowBuffer[];
//---
int      handle_iMA_Fast;                       // variable for storing the handle of the iMA indicator
int      handle_iMA_Slow;                       // variable for storing the handle of the iMA indicator

int      m_start;
int      bars_calculated   = 0;                 // we will keep the number of values in the Moving Average indicator
bool     m_init_error      = false;             // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,CrossoverBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,iMAFastBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,iMASlowBuffer,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//--- an empty value for plotting, for which there is no drawing
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- create handle of the indicator iMA
   handle_iMA_Fast=iMA(Symbol(),Period(),Inp_MA_Fast_ma_period,Inp_MA_Fast_ma_shift,
                       Inp_MA_Fast_ma_method,Inp_MA_Fast_applied_price);
//--- if the handle is not created
   if(handle_iMA_Fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator (\"Fast\") for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);;
     }
//--- create handle of the indicator iMA
   handle_iMA_Slow=iMA(Symbol(),Period(),Inp_MA_Slow_ma_period,Inp_MA_Slow_ma_shift,
                       Inp_MA_Slow_ma_method,Inp_MA_Slow_applied_price);
//--- if the handle is not created
   if(handle_iMA_Slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator (\"Slow\") for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//---
   m_start=Inp_MA_Fast_ma_period+Inp_MA_Fast_ma_shift;
   if(m_start<Inp_MA_Slow_ma_period+Inp_MA_Slow_ma_shift)
      m_start=Inp_MA_Slow_ma_period+Inp_MA_Slow_ma_shift;
   m_start++;
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
   if(rates_total<m_start || m_init_error)
      return(0);
//--- number of values copied from the iMA indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_fast=BarsCalculated(handle_iMA_Fast);
   if(calculated_fast<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_Fast) returned %d, error code %d",calculated_fast,GetLastError());
      return(0);
     }
   int calculated_slow=BarsCalculated(handle_iMA_Slow);
   if(calculated_slow<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_Slow) returned %d, error code %d",calculated_slow,GetLastError());
      return(0);
     }
   if(calculated_fast!=calculated_slow)
      return(0);
   int calculated=calculated_fast;
//--- if it is the first start of calculation of the indicator or if the number of values in the iMA indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iMABuffer array is greater than the number of values in the iMA indicator for symbol/period, then we don't copy everything
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
//--- fill the iMABuffer array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(iMAFastBuffer,Inp_MA_Fast_ma_shift,handle_iMA_Fast,values_to_copy))
      return(0);
   if(!FillArrayFromBuffer(iMASlowBuffer,Inp_MA_Slow_ma_shift,handle_iMA_Slow,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=m_start;
   for(int i=limit; i<rates_total; i++)
     {
      CrossoverBuffer[i]=0.0;
      ColorBuffer[i]=2.0;
      if(iMAFastBuffer[i-1]<iMASlowBuffer[i-1] && iMAFastBuffer[i]>iMASlowBuffer[i])
        {
         CrossoverBuffer[i]=1.0;
         ColorBuffer[i]=0.0;
        }
      else
         if(iMAFastBuffer[i-1]>iMASlowBuffer[i-1] && iMAFastBuffer[i]<iMASlowBuffer[i])
           {
            CrossoverBuffer[i]=1.0;
            ColorBuffer[i]=1.0;
           }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the MA indicator                  |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],   // indicator buffer of Moving Average values
                         int shift,          // shift
                         int ind_handle,     // handle of the iMA indicator
                         int amount          // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
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
   if(handle_iMA_Fast!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_Fast);
   if(handle_iMA_Slow!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_Slow);
  }
//+------------------------------------------------------------------+
