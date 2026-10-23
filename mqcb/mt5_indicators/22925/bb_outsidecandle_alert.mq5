//+------------------------------------------------------------------+
//|                                       BB_OutsideCandle_Alert.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Bollinger Bands Outside Candle Alert indicator"
#property description "Candle opening and closing outside the bands for buy/sell signals"
#property description "Optional Inside/Out Mode for open inside and close outside"
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   5
//--- plot SigB
#property indicator_label1  "Long Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SigS
#property indicator_label2  "Short Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot BandUP
#property indicator_label3  "Upper Band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrChocolate
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot BandDN
#property indicator_label4  "Lower Band"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrForestGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Signal Candles
#property indicator_label5  "Signal Candle"
#property indicator_type5   DRAW_COLOR_CANDLES
#property indicator_color5  clrMediumSeaGreen,clrDarkOrange,clrDarkGray
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//---
enum ENUM_MODE_OP_CL
  {
   MODE_CANDLE_INSIDE_OUT, // Opening inside, then closing outside 
   MODE_CANDLE_OUTSIDE     // Opening and closing outside
  };
//--- input parameters
input uint              InpPeriodBB    =  12;                  // BB period
input double            InpDeviation   =  2.2;                 // BB deviation
input ENUM_MODE_OP_CL   InpModeCandle  =  MODE_CANDLE_OUTSIDE; // BB line breakdown method
input ENUM_INPUT_YES_NO InpShowBands   =  INPUT_YES;           // Show bands
input ENUM_INPUT_YES_NO InpShowCandles =  INPUT_YES;           // Show signal candles
input ENUM_INPUT_YES_NO InpShowAlerts  =  INPUT_YES;           // Use alerts
//--- indicator buffers
double         BufferSigB[];
double         BufferSigS[];
double         BufferBandUP[];
double         BufferBandDN[];
double         BufferCandleO[];
double         BufferCandleH[];
double         BufferCandleL[];
double         BufferCandleC[];
double         BufferColors[];
double         BufferBB[];
//--- global variables
double         deviation;
int            period_bb;
int            handle_bb;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_bb=int(InpPeriodBB<1 ? 1 : InpPeriodBB);
   deviation=InpDeviation;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSigB,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSigS,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBandUP,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBandDN,INDICATOR_DATA);
   SetIndexBuffer(4,BufferCandleO,INDICATOR_DATA);
   SetIndexBuffer(5,BufferCandleH,INDICATOR_DATA);
   SetIndexBuffer(6,BufferCandleL,INDICATOR_DATA);
   SetIndexBuffer(7,BufferCandleC,INDICATOR_DATA);
   SetIndexBuffer(8,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(9,BufferBB,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"BB Outside Candle Alert+("+(string)period_bb+","+DoubleToString(deviation,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,InpShowBands);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,InpShowBands);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSigB,true);
   ArraySetAsSeries(BufferSigS,true);
   ArraySetAsSeries(BufferBandUP,true);
   ArraySetAsSeries(BufferBandDN,true);
   ArraySetAsSeries(BufferCandleO,true);
   ArraySetAsSeries(BufferCandleH,true);
   ArraySetAsSeries(BufferCandleL,true);
   ArraySetAsSeries(BufferCandleC,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferBB,true);
//--- create handles
   ResetLastError();
   handle_bb=iBands(NULL,PERIOD_CURRENT,period_bb,0,deviation,PRICE_CLOSE);
   if(handle_bb==INVALID_HANDLE)
     {
      Print("The iBands (",(string)period_bb+","+(string)deviation,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferSigB,EMPTY_VALUE);
      ArrayInitialize(BufferSigS,EMPTY_VALUE);
      ArrayInitialize(BufferBandUP,EMPTY_VALUE);
      ArrayInitialize(BufferBandDN,EMPTY_VALUE);
      ArrayInitialize(BufferCandleO,EMPTY_VALUE);
      ArrayInitialize(BufferCandleH,EMPTY_VALUE);
      ArrayInitialize(BufferCandleL,EMPTY_VALUE);
      ArrayInitialize(BufferCandleC,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferBB,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_bb,UPPER_BAND,0,count,BufferBandUP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,LOWER_BAND,0,count,BufferBandDN);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   static datetime last_time=0;
   string alert="";
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCandleO[i]=BufferCandleH[i]=BufferCandleL[i]=BufferCandleC[i]=EMPTY_VALUE;
      if(InpModeCandle==MODE_CANDLE_INSIDE_OUT)
        {
         //--- Bearish. Candle opening inside the bands and closing above the upper bollinger band
         if(open[i+1]<BufferBandUP[i+1] && close[i+1]>BufferBandUP[i+1])
           {
            BufferSigS[i]=high[i];//fmax(open[i+1],fmax(open[i],BufferBandUP[i]));
            if(InpShowCandles)
              DrawColorCandle(i+1,open,high,low,close);
            //--- Alert after the last Close of a candle
            if(i==0 && InpShowAlerts && time[0]>last_time)
              {
               Alert(Symbol()+" "+TimeframeToString(Period())+": Bollinger Bands Outside Candle SHORT Signal");
               last_time=TimeCurrent();
              }
           }
         //--- Bullish. Candle opening inside the bands and closing below the lower bollinger band
         if(open[i+1]>BufferBandDN[i+1] && close[i+1]<BufferBandDN[i+1])
           {
            BufferSigB[i]=low[i];//fmin(open[i+1],fmin(open[i],BufferBandDN[i]));
            if(InpShowCandles)
              DrawColorCandle(i+1,open,high,low,close);
            //--- Alert after the last Close of a candle
            if(i==0 && InpShowAlerts && time[0]>last_time)
              {
               Alert(Symbol()+" "+TimeframeToString(Period())+": Bollinger Bands Outside Candle LONG Signal");
               last_time=TimeCurrent();
              }
           }
        }
      else
        {
         //--- Bearish. Candle opening and closing above the upper bollinger band
         if(open[i+1]>close[i+1] && close[i+1]>BufferBandUP[i+1])
           {
            BufferSigS[i]=high[i];//fmax(open[i+1],fmax(open[i],BufferBandUP[i]));
            if(InpShowCandles)
              DrawColorCandle(i+1,open,high,low,close);
            //--- Alert after the last Close of a candle
            if(i==0 && InpShowAlerts && time[0]>last_time)
              {
               Alert(Symbol()+" "+TimeframeToString(Period())+": Bollinger Bands Outside Candle SHORT Signal");
               last_time=TimeCurrent();
              }
           }
         //--- Bullish. Candle opening and closing below the lower bollinger band
         if(open[i+1]<close[i+1] && close[i+1]<BufferBandDN[i+1])
           {
            BufferSigB[i]=low[i];//fmin(open[i+1],fmin(open[i],BufferBandDN[i]));
            if(InpShowCandles)
              DrawColorCandle(i+1,open,high,low,close);
            //--- Alert after the last Close of a candle
            if(i==0 && InpShowAlerts && time[0]>last_time)
              {
               Alert(Symbol()+" "+TimeframeToString(Period())+": Bollinger Bands Outside Candle LONG Signal");
               last_time=TimeCurrent();
              }
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  { 
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
//| Draw Color Candle                                                |
//+------------------------------------------------------------------+
void DrawColorCandle(const int shift,const double &open[],const double &high[],const double &low[],const double &close[])
  {
   BufferCandleO[shift]=open[shift];
   BufferCandleH[shift]=high[shift];
   BufferCandleL[shift]=low[shift];
   BufferCandleC[shift]=close[shift];
   BufferColors[shift]=(open[shift]<close[shift] ? 0 : open[shift]>close[shift] ? 1 : 2);
  }
//+------------------------------------------------------------------+
