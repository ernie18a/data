//+------------------------------------------------------------------+
//|                                                 NRTR Rosh v2.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "2010, MetaQuotes Software Corp."
//---- link to the website of the author
#property link      "https://forge.mql5.io"
//---- indicator version
#property version   "2.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----six buffers are used for calculation of drawing of the indicator
#property indicator_buffers 6
//---- four plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- red color is used as the color of the bearish indicator line
#property indicator_color1  Red
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bearish label of the indicator
#property indicator_label1  "Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- lime color is used as the color of the bullish line of the indicator
#property indicator_color2  Lime
//---- thickness of the indicator line 2 is equal to 1
#property indicator_width2  1
//---- displaying of the bullish label of the indicator
#property indicator_label2 "Buy"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3 DRAW_ARROW
//---- aqua color is used as the color of the bullish indicator line
#property indicator_color3 Aqua 
//---- thickness of the indicator line 3 is equal to 1
#property indicator_width3  1
//---- displaying of the bullish label of the indicator
#property indicator_label3  "Ceil"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4 DRAW_ARROW
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color4 Magenta
//---- thickness of the indicator line 4 is equal to 1
#property indicator_width4  1
//---- displaying of the bearish label of the indicator
#property indicator_label4 "Floor"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int    PerATR=40;
input double kATR=2.0;
input bool   useSendMail=false;
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
double Ceil[];
double Floor[];
double Trend[];
double ATR[];
//---- declaration of a variable for storing the indicator handle
int Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set SellBuffer dynamic array as indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,0);
//--- creating a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Sell");
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,251);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer,true);

//---- set BuyBuffer dynamic array as indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,0);
//--- creating a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Buy");
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,251);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer,true);

//---- set Ceil dynamic array as indicator buffer
   SetIndexBuffer(2,Ceil,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,0);
//--- creating a label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Ceil");
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(Ceil,true);

//---- set Floor dynamic array as indicator buffer
   SetIndexBuffer(3,Floor,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,0);
//--- creating a label to display in DataWindow
   PlotIndexSetString(3,PLOT_LABEL,"Floor");
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(Floor,true);

//---- set Trend dynamic array as indicator buffer
   SetIndexBuffer(4,Trend,INDICATOR_CALCULATIONS);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(Trend,true);

//---- set ATR dynamic array as indicator buffer
   SetIndexBuffer(5,ATR,INDICATOR_DATA);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(ATR,true);

//---- initializations of a variable for indicator short name
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"NRTR Rosh");
//--- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- Get indicator's handle
   Handle=iATR(NULL,0,PerATR);
   if(Handle==INVALID_HANDLE) Print(" Failed to get handle of the ATR indicator");
//----
  }
//+------------------------------------------------------------------+
//| downtrend top breakout                                           |
//+------------------------------------------------------------------+
bool BreakDown(int shift,const double &Close[])
  {
//----
   if(Close[shift]>SellBuffer[shift+1]) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| uptrend bottom breakout                                          |
//+------------------------------------------------------------------+
bool BreakUp(int shift,const double &Close[])
  {
//----
   if(Close[shift]<BuyBuffer[shift+1]) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| new downtrend minimum                                            |
//+------------------------------------------------------------------+
bool BreakFloor(int shift,const double &High[])
  {
//----
   if(High[shift]<Floor[shift+1]) return(true);
//----  
   return(false);
  }
//+------------------------------------------------------------------+
//| new uptrend maximum                                              |
//+------------------------------------------------------------------+
bool BreakCeil(int shift,const double &Low[])
  {
//----
   if(Low[shift]>Ceil[shift+1]) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| determining previous trend                                       |
//+------------------------------------------------------------------+
bool Uptrend(int shift)
  {
//----
//Print("Trend=",Trend[shift+1]);
   bool result=false;
   if(Trend[shift + 1] ==  1) result = true;
   if(Trend[shift + 1] == -1) result = false;
   if(Trend[shift+ 1] !=  1 && Trend[shift + 1] != -1)
      Print("Attention! Trend is not determined, abnormal situation. Bar from the end ",(Bars(NULL,0)-shift));
//----
   return(result);
  }
//+------------------------------------------------------------------+
//| setting a new ceil level                                         |
//+------------------------------------------------------------------+
void NewCeil(int shift,const double &Close[])
  {
//----
   Ceil[shift]=Close[shift];
   Floor[shift]=0.0;
//----
  }
//+------------------------------------------------------------------+
//| setting a new floor level                                        |
//+------------------------------------------------------------------+
void NewFloor(int shift,const double &Close[])
  {
//----
   Floor[shift]= Close[shift];
   Ceil[shift] = 0.0;
//----
  }
//+------------------------------------------------------------------+
//| setting an uptrend support level                                 |
//+------------------------------------------------------------------+
void SetBuyBuffer(int shift,const double &Close[])
  {
//----
   BuyBuffer[shift]=Close[shift]-kATR*ATR[shift];
   SellBuffer[shift]=0.0;
//----
  }
//+------------------------------------------------------------------+
//| setting a downtrend support level                                |
//+------------------------------------------------------------------+
void SetSellBuffer(int shift,const double &Close[])
  {
//----
   SellBuffer[shift]= Close[shift]+kATR * ATR[shift];
   BuyBuffer[shift] = 0.0;
//----
  }
//+------------------------------------------------------------------+
//| trend reverse and setting new levels                             |
//+------------------------------------------------------------------+
void NewTrend(int shift,const double &Close[])
  {
//----
   if(Trend[shift+1]==1)
     {
      Trend[shift]=-1;
      NewFloor(shift,Close);
      SetSellBuffer(shift,Close);
     }
   else
     {
      Trend[shift]=1;
      NewCeil(shift,Close);
      SetBuyBuffer(shift,Close);
     }

   if(Trend[shift+1]!=1 && Trend[shift+1]!=-1)
      Print("Attention! Trend is not determined, abnormal situation");
//----
  }
//+------------------------------------------------------------------+
//| trend progress                                                   |
//+------------------------------------------------------------------+
void CopyLastValues(int shift)
  {
//----
   SellBuffer[shift]= SellBuffer[shift+1];
   BuyBuffer[shift] = BuyBuffer[shift+1];
   Ceil[shift]=Ceil[shift+1];
   Floor[shift] = Floor[shift + 1];
   Trend[shift] = Trend[shift + 1];
//----
  }
//+------------------------------------------------------------------+
//| trend progress                                                   |
//+------------------------------------------------------------------+
void SendSMS(int shift)
  {
//----
   if(IsNewBar() && Trend[shift+1]*Trend[shift+2]==-1 && shift==0 && useSendMail) // the trend has changed
     {
      if(Trend[shift+1]==1)
         SendMail("NRTR ",Symbol()+" "+EnumToString(Period())+" turned upwards, Ask = "+DoubleToString(SymbolInfoDouble(NULL,SYMBOL_ASK),_Digits));
      else
         SendMail("NRTR ",Symbol()+" "+EnumToString(Period())+" turned downwards, Bid = "+DoubleToString(SymbolInfoDouble(NULL,SYMBOL_BID),_Digits));
     }

//----
  }
//+------------------------------------------------------------------+
//| IsNewBar() function                                              |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
//----
   static datetime Told;
   datetime Tnew[1];

   CopyTime(Symbol(),0,0,1,Tnew);
   if(Tnew[0]!=Told)
     {
      Told=Tnew[0];
      return(true);
     }
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the calculation of indicator
                const double& low[],      // price array of price minimums for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<PerATR-1) return(0);

//---- declarations of local variables 
   int limit,to_copy;

//---- indexing elements in arrays, as timeseries
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);

//---- calculation of the 'first' starting index for the cycle of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-PerATR-1;  // starting index for calculation of all bars
      to_copy=rates_total;

      //---- copy newly appeared data in the dynamic array
      if(CopyBuffer(Handle,0,0,to_copy,ATR)<=0) return(0);

      double closeX= close[limit+1];
      double openX = open[limit+1];
      //----
      if(closeX >  openX){Trend[limit + 1] = +1; Ceil [limit + 1] = closeX; BuyBuffer [limit + 1] = closeX - kATR * ATR[limit + 1];}
      if(closeX <  openX){Trend[limit + 1] = -1; Floor[limit + 1] = closeX; SellBuffer[limit + 1] = closeX + kATR * ATR[limit + 1];}
      if(closeX == openX){Trend[limit + 1] = +1; Ceil [limit + 1] = closeX; BuyBuffer [limit + 1] = closeX - kATR * ATR[limit + 1];}
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
      to_copy=limit+1;
      //--- copy newly appeared data in the dynamic array
      if(CopyBuffer(Handle,0,0,to_copy,ATR)<=0) return(0);
     }

//---- main loop of the indicator calculation
   for(int cnt=limit; cnt>=0; cnt--)
     {
      //SendSMS(cnt);
      Trend[cnt]=0;

      if(Uptrend(cnt))
        {
         //Print("UpTrend");
         if(BreakCeil(cnt,low))
           {
            NewCeil(cnt,close);
            SetBuyBuffer(cnt,close);
            Trend[cnt]=+1;
            continue;
           }

         if(BreakUp(cnt,close))
           {
            NewTrend(cnt,close);
            continue;
           }

         CopyLastValues(cnt);
        }
      else
        {
         //Print("DownTrend");
         if(BreakFloor(cnt,high))
           {
            NewFloor(cnt,close);
            SetSellBuffer(cnt,close);
            Trend[cnt]=-1;
            continue;
           }

         if(BreakDown(cnt,close))
           {
            NewTrend(cnt,close);
            continue;
           }

         CopyLastValues(cnt);
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
