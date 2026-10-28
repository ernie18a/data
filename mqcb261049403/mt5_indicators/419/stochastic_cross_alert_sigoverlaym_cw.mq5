//+------------------------------------------------------------------+
//|                                       Stochastic_Cross_Alert.mq5 |
//|                                    Copyright © 2006, Robert Hill |
//|                                                                  |
//| Written by Robert Hill for use with AIME for the stochastic cross|
//| to draw arrows and popup alert or send email                     |
//| Modified by Linuxser to display in a separate windows            |
//|                                       http://www.linuxser.com.ar |     
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Robert Hill"
#property link      "https://www.metaquotes.net/"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used as the color of the bearish label of the indicator
#property indicator_color1  Magenta
//---- thickness of the indicator line 1 is equal to 4
#property indicator_width1  4
//---- displaying of the bearish label of the indicator
#property indicator_label1  "Sell"
//+----------------------------------------------+
//|  Parameters of drawing the bullish indicator |
//+----------------------------------------------+
//---- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- lime color is used as the color of the bullish label of the indicator
#property indicator_color2  Lime
//---- thickness of the indicator line 2 is equal to 4
#property indicator_width2  4
//---- displaying the bullish label of the indicator
#property indicator_label2 "Buy"

//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input bool SoundON=false;
input bool EmailON=false;
//----
input int KPeriod=5;
input int DPeriod=3;
input int Slowing=3;
input ENUM_MA_METHOD MA_Method=MODE_SMA;
input ENUM_STO_PRICE Price_field=STO_LOWHIGH;
input int OverBoughtLevel=80;
input int OverSoldLevel=20;
input bool show_KD_cross=false;
input bool show_K_OBOScross = true;
input bool show_D_OBOScross = false;
//+----------------------------------------------+

//---- declaration of dynamic arrays that
// will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//----
int StartBars;
int STO_Handle;
bool flagval1_;
bool flagval2_;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   StartBars=KPeriod+DPeriod;
   if(StartBars<9)StartBars=9;
//---- getting handle of the ATR indicator
   STO_Handle=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MA_Method,Price_field);
   if(STO_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iStochastic1 indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- Create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Sell");
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- Create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Buy");
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer,true);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows
   string short_name="Stochastic_Cross_Alert";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(STO_Handle)<rates_total
      || rates_total<StartBars)
      return(0);

//---- declarations of local variables 
   int to_copy,limit,bar;
   double fastMAnow,slowMAnow,fastMAprevious,slowMAprevious;
   double Range,AvgRange,STOM[],STOS[],Bid,Ask;
   string sTimeCur,sAsk,sBid,sTimeHour,sTimeMinute,sPeriod;
   bool flagval1,flagval2;

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      to_copy=rates_total;           // calculated number of all bars
      limit=rates_total-StartBars-1; // starting index for calculation of all bars
      flagval1_=false;
      flagval2_=false;
     }
   else
     {
      to_copy=rates_total-prev_calculated+2; // calculated number of new bars only
      limit=rates_total-prev_calculated;     // starting index for calculation of new bars
     }

//---- copy newly appeared data in the arrays
   if(CopyBuffer(STO_Handle,0,0,to_copy,STOM)<=0) return(0);
   if(CopyBuffer(STO_Handle,1,0,to_copy,STOS)<=0) return(0);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(STOM,true);
   ArraySetAsSeries(STOS,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- restore values of the variables
   flagval1=flagval1_;
   flagval2=flagval2_;

//---- main indicator calculation loop
   for(bar=limit; bar>0; bar--)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==rates_total-1)
        {
         flagval1_ = flagval1;
         flagval2_ = flagval2;
        }

      AvgRange=0;

      for(int iii=bar; iii<bar+10; iii++) AvgRange+=MathAbs(high[iii]-low[iii]);

      Range=AvgRange/10;

      SellBuffer[bar]=0.0;
      BuyBuffer[bar]=0.0;

      fastMAnow=STOM[bar];
      fastMAprevious=STOM[bar+1];
      slowMAnow=STOS[bar];
      slowMAprevious=STOS[bar+1];

      if((show_KD_cross && fastMAnow>slowMAnow && fastMAprevious<slowMAprevious)
         || (show_K_OBOScross && fastMAnow>OverSoldLevel && fastMAprevious<OverSoldLevel)
         || (show_D_OBOScross && slowMAnow>OverSoldLevel && slowMAprevious<OverSoldLevel))
        {
         if(bar==1 && !flagval1)
           {
            flagval1=true;
            flagval2=false;

            if(SoundON || EmailON)
              {
               Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
               Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
               sTimeCur=TimeToString(TimeCurrent(),TIME_DATE);
               sAsk=DoubleToString(Ask,_Digits);
               sBid=DoubleToString(Bid,_Digits);

               MqlDateTime tm;
               TimeToStruct(TimeCurrent(),tm);
               sTimeHour=IntegerToString(tm.hour);
               sTimeMinute=IntegerToString(tm.min);
               sPeriod=EnumToString(Period());
              }

            if(SoundON) Alert("BUY signal at Ask=",sAsk,"\n Bid=",sBid,"\n Time=",sTimeCur," ",sTimeHour,":",sTimeMinute,"\n Symbol=",Symbol()," Period=",sPeriod);
            if(EmailON) SendMail("BUY signal alert","BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+sTimeCur+" "+sTimeHour+":"+sTimeMinute+" Symbol="+Symbol()+" Period="+sPeriod);
           }

         BuyBuffer[bar]=low[bar]-Range*0.5;
         SellBuffer[bar]=0.0;
        }
      else
         if((show_KD_cross && fastMAnow<slowMAnow && fastMAprevious>slowMAprevious)
            || (show_K_OBOScross && fastMAnow<OverBoughtLevel && fastMAprevious>OverBoughtLevel)
            || (show_D_OBOScross && slowMAnow<OverBoughtLevel && slowMAprevious>OverBoughtLevel))
           {
            if(bar==1 && !flagval2)
              {
               flagval2=true;
               flagval1=false;

               if(SoundON || EmailON)
                 {
                  Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
                  Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
                  sTimeCur=TimeToString(TimeCurrent(),TIME_DATE);
                  sAsk=DoubleToString(Ask,_Digits);
                  sBid=DoubleToString(Bid,_Digits);

                  MqlDateTime tm;
                  TimeToStruct(TimeCurrent(),tm);
                  sTimeHour=IntegerToString(tm.hour);
                  sTimeMinute=IntegerToString(tm.min);
                  sPeriod=EnumToString(Period());
                 }

               if(SoundON) Alert("SELL signal at Ask=",sAsk,"\n Bid=",sBid,"\n Date=",sTimeCur," ",sTimeHour,":",sTimeMinute,"\n Symbol=",Symbol()," Period=",sPeriod);
               if(EmailON) SendMail("SELL signal alert","SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+sTimeCur+" "+sTimeHour+":"+sTimeMinute+" Symbol="+Symbol()+" Period="+sPeriod);
              }
            SellBuffer[bar]=high[bar]+Range*0.5;
            BuyBuffer[bar]=0.0;
           }
     }

   SellBuffer[0]=0.0;
   BuyBuffer[0]=0.0;
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
