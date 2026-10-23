//+------------------------------------------------------------------+
//|                                         VIDYA N Bars Borders.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot Upper
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_DASH
#property indicator_width1  1
//--- plot VIDYA
#property indicator_label2  "VIDYA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Lower
#property indicator_label3  "Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMediumSeaGreen
#property indicator_style3  STYLE_DASH
#property indicator_width3  1
//--- input parameters
input group             "VIDyA"
input int                  Inp_VIDyA_cmo_period          = 15;             // VIDyA: period for Chande Momentum
input int                  Inp_VIDyA_ema_period          = 12;             // VIDyA: EMA smoothing period
input int                  Inp_VIDyA_ma_shift            = 0;              // VIDyA: horizontal shift on the price chart
input ENUM_APPLIED_PRICE   Inp_VIDyA_applied_price       = PRICE_CLOSE;    // VIDyA: type of price
input int                  Inp_n_bars                    = 6;              // N Bars
//--- indicator buffers
double   UpperBuffer[];
double   VIDYABuffer[];
double   LowerBuffer[];
double   iATRBuffer[];
//---
int      handle_iVIDyA;                      // variable for storing the handle of the iVIDyA indicator
int      handle_iATR;                        // variable for storing the handle of the iATR indicator
int      bars_calculated   = 0;              // we will keep the number of values in the indicators
bool     m_init_error      = false;          // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,VIDYABuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,iATRBuffer,INDICATOR_DATA);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Inp_VIDyA_ema_period+Inp_VIDyA_cmo_period-1);
//--- sets indicator shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Inp_VIDyA_ma_shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Inp_VIDyA_ma_shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Inp_VIDyA_ma_shift);
//--- name for indicator label
   string str_input=IntegerToString(Inp_VIDyA_cmo_period)+","+IntegerToString(Inp_VIDyA_ema_period)+","+IntegerToString(Inp_VIDyA_ma_shift)+","+IntegerToString(Inp_n_bars);
   IndicatorSetString(INDICATOR_SHORTNAME,"VIDYA N Bars Borders("+str_input+")");
//--- name for index label
   PlotIndexSetString(0,PLOT_LABEL,"Upper("+str_input+")");
   PlotIndexSetString(1,PLOT_LABEL,"VIDYA("+str_input+")");
   PlotIndexSetString(2,PLOT_LABEL,"Lower("+str_input+")");
//--- create handle of the indicator
   handle_iVIDyA=iVIDyA(Symbol(),Period(),Inp_VIDyA_cmo_period,
                        Inp_VIDyA_ema_period,Inp_VIDyA_ma_shift,Inp_VIDyA_applied_price);
//--- if the handle is not created
   if(handle_iVIDyA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iVIDyA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iATR
   handle_iATR=iATR(Symbol(),Period(),Inp_n_bars);
//--- if the handle is not created
   if(handle_iATR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iATR indicator for the symbol %s/%s, error code %d",
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
   int calculated=BarsCalculated(handle_iVIDyA);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iVIDyA indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iVIDyABuffer array is greater than the number of values in the iVIDyA indicator for symbol/period, then we don't copy everything
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
//--- fill the array with values from the Variable Index Dynamic Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(VIDYABuffer,Inp_VIDyA_ma_shift,handle_iVIDyA,values_to_copy))
      return(0);
//--- fill the iATRBuffer array with values of the Average True Range indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(iATRBuffer,handle_iATR,values_to_copy))
      return(0);
//--- memorize the number of values in the Variable Index Dynamic Average indicator
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=limit; i<rates_total; i++)
     {
      UpperBuffer[i]=VIDYABuffer[i]+iATRBuffer[i];
      LowerBuffer[i]=VIDYABuffer[i]-iATRBuffer[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iVIDyA indicator              |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &vidya_buffer[],// indicator buffer of Variable Index Dynamic Average values
                         int v_shift,           // shift of the line
                         int ind_handle,        // handle of the iVIDyA indicator
                         int amount             // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iVIDyABuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,-v_shift,amount,vidya_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iVIDyA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
//--- everything is fine
   return(true);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iATR indicator                |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],  // indicator buffer for ATR values
                         int ind_handle,    // handle of the iATR indicator
                         int amount         // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iATRBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
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
   if(handle_iVIDyA!=INVALID_HANDLE)
      IndicatorRelease(handle_iVIDyA);
   if(handle_iATR!=INVALID_HANDLE)
      IndicatorRelease(handle_iATR);
  }
//+------------------------------------------------------------------+
