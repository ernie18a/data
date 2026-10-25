//+------------------------------------------------------------------+
//|                                                 CHO Smoothed.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.001"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot CHO
#property indicator_label1  "CHO"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot CHO_Smoothed
#property indicator_label2  "CHO_Smoothed"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input group             "Chaikin Oscillator, CHO"
input int                  Inp_CHO_fast_ma_period        = 3;              // CHO: fast period
input int                  Inp_CHO_slow_ma_period        = 10;             // CHO: slow period
input ENUM_MA_METHOD       Inp_CHO_ma_method             = MODE_EMA;       // CHO: smoothing type
input ENUM_APPLIED_VOLUME  Inp_CHO_applied_volume        = VOLUME_TICK;    // CHO: type of volume
input group             "MA"
input int                  Inp_MA_ma_period              = 3;              // MA: averaging period
input ENUM_MA_METHOD       Inp_MA_ma_method              = MODE_SMA;       // MA: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_applied_price          = PRICE_CLOSE;    // MA: type of price
//--- indicator buffers
double   CHOBuffer[];
double   CHO_SmoothedBuffer[];
//---
int      handle_iChaikin;                       // variable for storing the handle of the iChaikin indicator
int      handle_iMA_iChaikin;                   // variable for storing the handle of the iChaikin indicator
int      bars_calculated=0;                     // we will keep the number of values in the Moving Average indicator
bool     m_init_error=false;                    // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,CHOBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CHO_SmoothedBuffer,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- create handle of the indicator iChaikin
   handle_iChaikin=iChaikin(Symbol(),Period(),Inp_CHO_fast_ma_period,
                            Inp_CHO_slow_ma_period,Inp_CHO_ma_method,Inp_CHO_applied_volume);
//--- if the handle is not created
   if(handle_iChaikin==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iChaikin indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMA_iChaikin=iMA(Symbol(),Period(),Inp_MA_ma_period,0,
                           Inp_MA_ma_method,handle_iChaikin);
//--- if the handle is not created
   if(handle_iMA_iChaikin==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA iChaikin indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- MA
   string mode;
   switch(Inp_MA_ma_method)
     {
      case MODE_EMA :
         mode="EMA";
         break;
      case MODE_LWMA :
         mode="LWMA";
         break;
      case MODE_SMA :
         mode="SMA";
         break;
      case MODE_SMMA :
         mode="SMMA";
         break;
      default :
         mode="unknown mode";
     }
   string price;
   switch(Inp_MA_applied_price)
     {
      case PRICE_CLOSE:
         price="Close";
         break;
      case PRICE_OPEN:
         price="Open";
         break;
      case PRICE_HIGH:
         price="High";
         break;
      case PRICE_LOW:
         price="Low";
         break;
      case PRICE_MEDIAN:
         price="Median";
         break;
      case PRICE_TYPICAL:
         price="Typical";
         break;
      case PRICE_WEIGHTED:
         price="Weighted";
         break;
      default:
         price="unknown ma price";
     }
//--- name for indicator subwindow label
   string short_name=StringFormat("CHO(slow %d,fast %d) Smoothed(%d,%s,%s)",
                                  Inp_CHO_slow_ma_period,Inp_CHO_fast_ma_period,Inp_MA_ma_period,mode,price);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
   if(m_init_error)
      return(0);
//--- number of values copied from the iChaikin indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_cho=BarsCalculated(handle_iChaikin);
   if(calculated_cho<=0)
     {
      PrintFormat("BarsCalculated(handle_iChaikin) returned %d, error code %d",calculated_cho,GetLastError());
      return(0);
     }
   int calculated_ma_cho=BarsCalculated(handle_iMA_iChaikin);
   if(calculated_ma_cho<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_iChaikin) returned %d, error code %d",calculated_ma_cho,GetLastError());
      return(0);
     }
   if(calculated_cho!=calculated_ma_cho)
     {
      PrintFormat("BarsCalculated(handle_iChaikin) returned %d, BarsCalculated(handle_iMA_iChaikin) returned %d",calculated_cho,calculated_ma_cho);
      return(0);
     }
   int calculated=calculated_cho;
//--- if it is the first start of calculation of the indicator or if the number of values in the iChaikin indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iChaikinBuffer array is greater than the number of values in the iChaikin indicator for symbol/period, then we don't copy everything
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
//--- fill the iChaikinBuffer array with values of the Chaikin Oscillator indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(CHOBuffer,handle_iChaikin,values_to_copy))
      return(0);
   if(!FillArrayFromBuffer(CHO_SmoothedBuffer,handle_iMA_iChaikin,values_to_copy))
      return(0);
//--- memorize the number of values in the Chaikin Oscillator indicator
   bars_calculated=calculated;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iChaikin indicator            |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],  // indicator buffer of  values
                         int ind_handle,    // handle of indicator
                         int amount         // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the indicator, error code %d",GetLastError());
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
   if(handle_iMA_iChaikin!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_iChaikin);
   if(handle_iChaikin!=INVALID_HANDLE)
      IndicatorRelease(handle_iChaikin);
  }
//+------------------------------------------------------------------+
