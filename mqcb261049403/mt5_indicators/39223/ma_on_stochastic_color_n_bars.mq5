//+------------------------------------------------------------------+
//|                                MA On Stochastic Color N Bars.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 2
#property indicator_plots   1
//--- plot MA on Stoch Color
#property indicator_label1  "MA on Stoch Color"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrYellowGreen,clrBlue,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input group             "Stochastic"
input int                  Inp_STO_Kperiod      = 5;           // Stochastic: K-period (number of bars for calculations)
input int                  Inp_STO_Dperiod      = 3;           // Stochastic: D-period (period of first smoothing)
input int                  Inp_STO_slowing      = 3;           // Stochastic: final smoothing
input ENUM_MA_METHOD       Inp_STO_ma_method    = MODE_SMA;    // Stochastic: type of smoothing
input ENUM_STO_PRICE       Inp_STO_price_field  = STO_LOWHIGH; // Stochastic: stochastic calculation method
input group             "MA"
input int                  Inp_MA_ma_period     = 6;           // MA: averaging period
input int                  Inp_MA_ma_shift      = 0;           // MA: horizontal shift
input ENUM_MA_METHOD       Inp_MA_ma_method     = MODE_SMA;    // MA: smoothing type
input uchar                Inp_MA_trend_n_bars  = 3;           // MA: trend N Bars
//--- indicator buffers
double   MAColorBuffer[];
double   MAColorColors[];
//---
int      handle_iStochastic;                    // variable for storing the handle of the iStochastic indicator
int      handle_iMA;                            // variable for storing the handle of the iMA indicator
//---
int      bars_calculated   = 0;                 // we will keep the number of values in the Stochastic Oscillator indicator
bool     m_init_error      = false;             // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- forced initialization of variables
   m_init_error            = false;             // error on InInit
//--- indicator buffers mapping
   SetIndexBuffer(0,MAColorBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MAColorColors,INDICATOR_COLOR_INDEX);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- set levels
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,20);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,80);
//--- name for DataWindow and indicator subwindow label
   string plot_name=StringFormat("Stoch(%d,%d,%d)",Inp_STO_Kperiod,Inp_STO_Dperiod,Inp_STO_slowing);
   PlotIndexSetString(0,PLOT_LABEL,plot_name);
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
   PlotIndexSetString(2,PLOT_LABEL,plot_name+"("+IntegerToString(Inp_MA_ma_period)+")");
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Inp_STO_Kperiod+Inp_STO_slowing-2);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Inp_STO_Kperiod+Inp_STO_Dperiod);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,Inp_STO_Kperiod+Inp_STO_Dperiod+Inp_MA_ma_period);
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
//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),Period(),Inp_MA_ma_period,Inp_MA_ma_shift,
                  Inp_MA_ma_method,handle_iStochastic);
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
   if(!FillArrayFromBuffer(MAColorBuffer,Inp_MA_ma_shift,handle_iMA,values_to_copy))
      return(0);
//--- memorize the number of values in the Stochastic Oscillator indicator
   bars_calculated=calculated_sto;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      limit=Inp_MA_trend_n_bars;
      for(int i=0; i<limit; i++)
         MAColorColors[i]=0.0;
     }
   for(int i=limit; i<rates_total; i++)
     {
      int trend=0;
      for(int j=i-Inp_MA_trend_n_bars; j<i; j++)
        {
         if(MAColorBuffer[j]<MAColorBuffer[j+1])
            trend++;
         else
            trend--;
        }
      if(trend==Inp_MA_trend_n_bars)
         MAColorColors[i]=1;
      else
         if(-trend==Inp_MA_trend_n_bars)
            MAColorColors[i]=2;
         else
            MAColorColors[i]=0;
      int d=0;
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
   if(handle_iStochastic!=INVALID_HANDLE)
      IndicatorRelease(handle_iStochastic);
   if(handle_iMA!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA);
  }
//+------------------------------------------------------------------+
