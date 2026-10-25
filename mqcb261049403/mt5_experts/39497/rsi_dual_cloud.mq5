//+------------------------------------------------------------------+
//|                                               RSI Dual Cloud.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 6
#property indicator_plots   4
//--- plot RSI Fast
#property indicator_label1  "RSI Fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot RSI Slow
#property indicator_label2  "RSI Slow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLime
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Cloud UP
#property indicator_label3  "Cloud UP"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  C'255,236,236',clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Cloud DOWN
#property indicator_label4  "Cloud DOWN"
#property indicator_type4   DRAW_FILLING
#property indicator_color4  clrRed,C'236,236,255'
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//+------------------------------------------------------------------+
//| Enum Line Mode                                                   |
//+------------------------------------------------------------------+
enum ENUM_LINE_MODE
  {
   fast=0,     // Fast
   slow=1,     // Slow
   h_l=2,      // Highest Lowest
  };
//--- input parameters
input group             "RSI Fast and Slow"
input double               Inp_RSI_LevelUP            = 75;          // RSI Fast and Slow: Level UP
input double               Inp_RSI_LevelDOWN          = 25;          // RSI Fast and Slow: Level DOWN
input ENUM_LINE_MODE       InpLineMode                = fast;        // Cloud mode:
input group             "RSI Fast"
input int                  Inp_RSI_Fast_ma_period     = 5;           // RSI Fast: averaging period
input ENUM_APPLIED_PRICE   Inp_RSI_Fast_applied_price = PRICE_CLOSE; // RSI Fast: type of price
input group             "RSI Slow"
input int                  Inp_RSI_Slow_ma_period     = 15;          // RSI Slow: averaging period
input ENUM_APPLIED_PRICE   Inp_RSI_Slow_applied_price = PRICE_CLOSE; // RSI Slow: type of price
//--- indicator buffers
double   RSIFastBuffer[];
double   RSISlowBuffer[];
double   Cloud_Up1_Buffer[];
double   Cloud_Up2_Buffer[];
double   Cloud_Down1_Buffer[];
double   Cloud_Down2_Buffer[];
//---
int      handle_iRSI_Fast;             // variable for storing the handle of the iRSI indicator
int      handle_iRSI_Slow;             // variable for storing the handle of the iRSI indicator
int      bars_calculated   = 0;        // we will keep the number of values in the Relative Strength Index indicators
bool     m_init_error      = false;    // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,RSIFastBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,RSISlowBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,Cloud_Up1_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,Cloud_Up2_Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,Cloud_Down1_Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,Cloud_Down2_Buffer,INDICATOR_DATA);
//--- set levels
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Inp_RSI_LevelUP);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Inp_RSI_LevelDOWN);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Inp_RSI_Fast_ma_period);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Inp_RSI_Slow_ma_period);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI Dual Cloud("+IntegerToString(Inp_RSI_Fast_ma_period)+","+IntegerToString(Inp_RSI_Slow_ma_period)+")");
//--- create handle of the indicator iRSI
   handle_iRSI_Fast=iRSI(Symbol(),Period(),Inp_RSI_Fast_ma_period,Inp_RSI_Fast_applied_price);
//--- if the handle is not created
   if(handle_iRSI_Fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iRSI indicator ('Fast') for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iRSI
   handle_iRSI_Slow=iRSI(Symbol(),Period(),Inp_RSI_Slow_ma_period,Inp_RSI_Slow_applied_price);
//--- if the handle is not created
   if(handle_iRSI_Slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iRSI indicator ('Slow') for the symbol %s/%s, error code %d",
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
//---
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_fast=BarsCalculated(handle_iRSI_Fast);
   if(calculated_fast<=0)
     {
      PrintFormat("BarsCalculated(handle_iRSI_Fast) returned %d, error code %d",calculated_fast,GetLastError());
      return(0);
     }
   int calculated_slow=BarsCalculated(handle_iRSI_Slow);
   if(calculated_slow<=0)
     {
      PrintFormat("BarsCalculated(handle_iRSI_Slow) returned %d, error code %d",calculated_slow,GetLastError());
      return(0);
     }
   if(calculated_fast!=calculated_slow)
     {
      PrintFormat("BarsCalculated(handle_iRSI_Fast) returned %d, BarsCalculated(handle_iRSI_Slow) returned %d",calculated_fast,calculated_slow);
      return(0);
     }
   int calculated=calculated_fast;
//--- if it is the first start of calculation of the indicator or if the number of values in the iRSI indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iRSIBuffer array is greater than the number of values in the iRSI indicator for symbol/period, then we don't copy everything
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
//--- fill the array with values of the iRSI indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(RSIFastBuffer,handle_iRSI_Fast,values_to_copy))
      return(0);
   if(!FillArrayFromBuffer(RSISlowBuffer,handle_iRSI_Slow,values_to_copy))
      return(0);
//--- memorize the number of values in the Relative Strength Index indicator
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=limit; i<rates_total; i++)
     {
      if(InpLineMode==fast)
        {
         Cloud_Up1_Buffer[i]=100.0;
         Cloud_Up2_Buffer[i]=RSIFastBuffer[i];
         Cloud_Down1_Buffer[i]=0.0;
         Cloud_Down2_Buffer[i]=RSIFastBuffer[i];
         continue;
        }
      if(InpLineMode==slow)
        {
         Cloud_Up1_Buffer[i]=100.0;
         Cloud_Up2_Buffer[i]=RSISlowBuffer[i];
         Cloud_Down1_Buffer[i]=0.0;
         Cloud_Down2_Buffer[i]=RSISlowBuffer[i];
         continue;
        }
      Cloud_Up1_Buffer[i]=100.0;
      Cloud_Up2_Buffer[i]=(RSIFastBuffer[i]>RSISlowBuffer[i])?RSIFastBuffer[i]:RSISlowBuffer[i];
      Cloud_Down1_Buffer[i]=0.0;
      Cloud_Down2_Buffer[i]=(RSIFastBuffer[i]<RSISlowBuffer[i])?RSIFastBuffer[i]:RSISlowBuffer[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iRSI indicator                |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &rsi_buffer[],  // indicator buffer of Relative Strength Index values
                         int ind_handle,        // handle of the iRSI indicator
                         int amount             // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iRSIBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,rsi_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
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
   if(handle_iRSI_Fast!=INVALID_HANDLE)
      IndicatorRelease(handle_iRSI_Fast);
   if(handle_iRSI_Slow!=INVALID_HANDLE)
      IndicatorRelease(handle_iRSI_Slow);
  }
//+------------------------------------------------------------------+
