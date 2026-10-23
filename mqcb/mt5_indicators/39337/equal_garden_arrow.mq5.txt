//+------------------------------------------------------------------+
//|                                           Equal garden Arrow.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_minimum -3
#property indicator_maximum 3
#property indicator_buffers 4
#property indicator_plots   2
//--- plot MA
#property indicator_label1  "MA"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrYellowGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot STO
#property indicator_label2  "STO"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLightSeaGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input group             "MA"
input int                  Inp_MA_ma_period              = 26;             // MA: averaging period
input int                  Inp_MA_ma_shift               = 0;              // MA: horizontal shift
input ENUM_MA_METHOD       Inp_MA_ma_method              = MODE_SMA;       // MA: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_applied_price          = PRICE_CLOSE;    // MA: type of price
input group             "Stochastic"
input int                  Inp_STO_Kperiod               = 5;              // Stochastic: K-period (number of bars for calculations)
input int                  Inp_STO_Dperiod               = 3;              // Stochastic: D-period (period of first smoothing)
input int                  Inp_STO_slowing               = 3;              // Stochastic: final smoothing
input ENUM_MA_METHOD       Inp_STO_ma_method             = MODE_SMA;       // Stochastic: type of smoothing
input ENUM_STO_PRICE       Inp_STO_price_field           = STO_LOWHIGH;    // Stochastic: stochastic calculation method
input double               Inp_STO_Level1                = 25.0;           // Value Level #1 (25.0)
input double               Inp_STO_Level2                = 75.0;           // Value Level #2 (75.0)
//--- indicator buffers
double   MABuffer[];
double   STOBuffer[];
double   iMABuffer[];
double   iSTOBuffer[];
//---
int      handle_iMA;                            // variable for storing the handle of the iMA indicator
int      handle_iStochastic;                    // variable for storing the handle of the iStochastic indicator
//---
int      bars_calculated   = 0;                 // we will keep the number of values in indicators
bool     m_init_error      = false;             // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MABuffer,INDICATOR_DATA);
   SetIndexBuffer(1,STOBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,iMABuffer,INDICATOR_DATA);
   SetIndexBuffer(3,iSTOBuffer,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- name for DataWindow and indicator subwindow label
   string plot_name="-";
   switch(Inp_MA_ma_method)
     {
      case MODE_EMA :
         plot_name="EMA";
         break;
      case MODE_LWMA :
         plot_name="LWMA";
         break;
      case MODE_SMA :
         plot_name="SMA";
         break;
      case MODE_SMMA :
         plot_name="SMMA";
         break;
      default :
         plot_name="unknown ma";
     }
   PlotIndexSetString(0,PLOT_LABEL,plot_name+"("+IntegerToString(Inp_MA_ma_period)+")");
   plot_name=StringFormat("STO(%d,%d,%d)",Inp_STO_Kperiod,Inp_STO_Dperiod,Inp_STO_slowing);
   PlotIndexSetString(1,PLOT_LABEL,plot_name);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- an empty value for plotting, for which there is no drawing
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),Period(),Inp_MA_ma_period,Inp_MA_ma_shift,
                  Inp_MA_ma_method,Inp_MA_applied_price);
//--- if the handle is not created
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(Symbol(),Period(),
                                  Inp_STO_Kperiod,Inp_STO_Dperiod,Inp_STO_slowing,
                                  Inp_STO_ma_method,Inp_STO_price_field);
//--- if the handle is not created
   if(handle_iStochastic==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
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
//--- number of values copied from the iStochastic indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_sto=BarsCalculated(handle_iStochastic);
   if(calculated_sto<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated_sto,GetLastError());
      return(0);
     }
//--- determine the number of values calculated in the indicator
   int calculated_ma=BarsCalculated(handle_iMA);
   if(calculated_ma<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated_ma,GetLastError());
      return(0);
     }
//---
   if(calculated_sto!=calculated_ma)
     {
      PrintFormat("BarsCalculated(STO) returned %d, BarsCalculated(MA) returned %d",calculated_sto,calculated_ma);
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iStochastic indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated_sto!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the StochasticBuffer array is greater than the number of values in the iStochastic indicator for symbol/period, then we don't copy everything
      //--- otherwise, we copy less than the size of indicator buffers
      if(calculated_sto>rates_total)
         values_to_copy=rates_total;
      else
         values_to_copy=calculated_sto;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate()
      //--- for calculation not more than one bar is added
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(iMABuffer,Inp_MA_ma_shift,handle_iMA,values_to_copy))
      return(0);
//--- fill the arrays with values of the iStochastic indicator
//--- if FillArraysFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArraysFromBuffers(iSTOBuffer,handle_iStochastic,values_to_copy))
      return(0);
//--- memorize the number of values in the Stochastic Oscillator indicator
   bars_calculated=calculated_sto;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=limit; i<rates_total; i++)
     {
      MABuffer[i]=0.0;
      STOBuffer[i]=0.0;
      if(close[i]>iMABuffer[i])
         MABuffer[i]=2.0;
      else
         MABuffer[i]=-2.0;
      if(iSTOBuffer[i]<Inp_STO_Level1)
         STOBuffer[i]=1.0;
      else
         if(iSTOBuffer[i]>Inp_STO_Level2)
            STOBuffer[i]=-1.0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iStochastic indicator         |
//+------------------------------------------------------------------+
bool FillArraysFromBuffers(double &main_buffer[],    // indicator buffer of Stochastic Oscillator values
                           int ind_handle,           // handle of the iStochastic indicator
                           int amount                // number of copied values
                          )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the StochasticBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,MAIN_LINE,0,amount,main_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
//--- everything is fine
   return(true);
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
   if(handle_iStochastic!=INVALID_HANDLE)
      IndicatorRelease(handle_iStochastic);
   if(handle_iMA!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA);
  }
//+------------------------------------------------------------------+
