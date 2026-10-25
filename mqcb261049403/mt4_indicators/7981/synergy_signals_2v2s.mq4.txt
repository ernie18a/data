//+------------------------------------------------------------------+
//|                                         Synergy Signals [v2].mq4 |
//|                                                         SwingMan |
//|                    Sources: Traders Dynamic Index, HeikenAshi_DM |
//+------------------------------------------------------------------+
#property copyright "SwingMan"
#property link      ""
//----
#property indicator_chart_window
#property indicator_buffers 7
//---- colors
#property indicator_color1 Green       // long/short Signals
#property indicator_color2 Red
#property indicator_color3 IndianRed   // StopLoss
#property indicator_color4 LimeGreen
#property indicator_color5 Yellow
#property indicator_color6 Yellow
#property indicator_color7 Green
//---- extern parameters 
extern int PriceChannel_Period=5;
extern int RSI_Period=13;               //8-25
extern int RSISmooth_Period=2;
extern int RSIVolatilityBand_Period=34; //20-40
extern int RSITradeSignal_Period=7;
extern int TrendIndicator_Period=55;
extern int RSI_Price=0;                 //0-6
extern int RSI_MavgMODE=0;              //0-3
extern int RSITradeSignal_MavgMODE=0;   //0-3
extern double Factor_ShortBars=0.50;
extern int SignalOffset=5;
//---- arrays Traders Dynamic Index
double RSIBuf[10000],UpZone[10000],BaseLine[10000],DnZone[10000];
double RSILine[10000],RedLine[10000];
//---- arrays HeikinAshi Candles
double haBuffer_Low[10000];
double haBuffer_High[10000];
double haBuffer_Open[10000];
double haBuffer_Close[10000];
//---- MovingAverages / PriceActionChannel / PAC
double mavHighs[];
double mavLows[];
double mavTrend[];
//---- signals
double LongSignal[];
double ShortSignal[];
double StopLong[];
double StopShort[];
//---- variables
string sName="Synergy Signals [v2]";
double dSignalOffset, Spread;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName(sName);
   Comment(sName);
   dSignalOffset=SignalOffset*Point;
   Spread=MarketInfo(Symbol(), MODE_SPREAD) * Point;
//---- Set Arrays ----------------------------------------------------
   ArraySetAsSeries(RSIBuf, true);        // Traders Dynamic Index
   ArraySetAsSeries(UpZone, true);
   ArraySetAsSeries(BaseLine, true);
   ArraySetAsSeries(DnZone, true);
   ArraySetAsSeries(RSILine, true);
   ArraySetAsSeries(RedLine, true);
   ArraySetAsSeries(haBuffer_Low, true); // HeikinAshi Candles
   ArraySetAsSeries(haBuffer_High, true);
   ArraySetAsSeries(haBuffer_Open, true);
   ArraySetAsSeries(haBuffer_Close, true);
//---- Long/Short Signals
   SetIndexBuffer(0,LongSignal);
   SetIndexBuffer(1,ShortSignal);
   SetIndexStyle(0,DRAW_ARROW,0,1);
   SetIndexStyle(1,DRAW_ARROW,0,1);
   SetIndexArrow(0,159);
   SetIndexArrow(1,159);
   SetIndexLabel(0,"LONG Signal");
   SetIndexLabel(1,"SHORT Signal");
//---- Stops Long/Short 
   SetIndexBuffer(2,StopLong);
   SetIndexBuffer(3,StopShort);
   SetIndexStyle(2,DRAW_ARROW,0,0);
   SetIndexStyle(3,DRAW_ARROW,0,0);
   SetIndexArrow(2,251);
   SetIndexArrow(3,251);
   SetIndexLabel(2,"Stop Long");
   SetIndexLabel(3,"Stop Short");
//---- MovingAverages / PriceActionChannel / PAC    
   SetIndexBuffer(4,mavHighs);
   SetIndexBuffer(5,mavLows);
   SetIndexBuffer(6,mavTrend);
   SetIndexStyle(4,DRAW_LINE,0,2);
   SetIndexStyle(5,DRAW_LINE,0,2);
   SetIndexStyle(6,DRAW_LINE,0,2);
   SetIndexLabel(4,"High mavg");
   SetIndexLabel(5,"Low mavg");
   SetIndexLabel(6,"Trend line");
//---- Draw begin
   SetIndexDrawBegin(0,TrendIndicator_Period);
   SetIndexDrawBegin(1,TrendIndicator_Period);
   SetIndexDrawBegin(2,TrendIndicator_Period);
   SetIndexDrawBegin(3,TrendIndicator_Period);
   SetIndexDrawBegin(4,TrendIndicator_Period);
   SetIndexDrawBegin(5,TrendIndicator_Period);
   SetIndexDrawBegin(6,TrendIndicator_Period);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() { return(0); }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   bool TradeLong =false;
   bool TradeShort=false;
//---- Traders Dynamic Index; Copyright © 2006, Dean Malone 
   double MA,RSI[];
   ArrayResize(RSI,RSIVolatilityBand_Period);
   int counted_bars=IndicatorCounted();
   int limit=Bars-counted_bars-1;
   for(int i=limit; i>=0; i--)
     {
      RSIBuf[i]=(iRSI(NULL,0,RSI_Period,RSI_Price,i));
      MA=0;
      for(int x=i; x<i+RSIVolatilityBand_Period; x++)
        {
         RSI[x-i]=RSIBuf[x];
         MA+=RSIBuf[x]/RSIVolatilityBand_Period;
        }
      UpZone[i]=(MA + (1.6185 * StDev(RSI,RSIVolatilityBand_Period)));         // upper Volatility Band; Blue
      DnZone[i]=(MA - (1.6185 * StDev(RSI,RSIVolatilityBand_Period)));         // lower Volatility Band; Blue
      BaseLine[i]=((UpZone[i] + DnZone[i])*0.5);                               // Market Base Line (MBL); Yellow
     }
   for(i=limit-1;i>=0;i--)
     {
      RSILine[i]=(iMAOnArray(RSIBuf,0,RSISmooth_Period,0,RSI_MavgMODE,i));           // RSI Price Line; Green
      RedLine[i]=(iMAOnArray(RSIBuf,0,RSITradeSignal_Period,0,RSITradeSignal_MavgMODE,i)); // Trade Signal Line (TSL); Red
     }
   // MovingAverages / PriceActionChannel / PAC 
   for(i=limit-1;i>=0;i--)
     {
      mavHighs[i]=iMA(NULL,0,PriceChannel_Period,  0,MODE_SMMA,PRICE_HIGH,i);  // PriceActionChannel (PAC) Highs; Yellow
      mavLows[i] =iMA(NULL,0,PriceChannel_Period,  0,MODE_SMMA,PRICE_LOW,i);   // PriceActionChannel (PAC) Lows; Yellow
      mavTrend[i]=iMA(NULL,0,TrendIndicator_Period,0,MODE_SMMA,PRICE_MEDIAN,i);// Trend Line; Green
     }
      //+----------------------------------------------------+
      //|  Signals                                           |
      //+----------------------------------------------------+
   for(i=limit-1;i>=0;i--)
     {
      //---- HeikinAshi CANDLES --------------------------------------
      double haOpen, haHigh, haLow, haClose;
      haOpen=(haBuffer_Open[i+1]+haBuffer_Close[i+1])*0.50;
      haClose=(Open[i]+High[i]+Low[i]+Close[i])*0.25;
      haHigh=MathMax(High[i], MathMax(haOpen, haClose));
      haLow=MathMin(Low[i], MathMin(haOpen, haClose));
        if (haOpen<haClose) 
        {
         haBuffer_Low[i] =haLow;
         haBuffer_High[i]=haHigh;
        }
      else
        {
         haBuffer_Low[i] =haHigh;
         haBuffer_High[i]=haLow;
        }
      haBuffer_Open[i] =haOpen;
      haBuffer_Close[i]=haClose;
      //---- local High/Low
      if (haBuffer_High[i] > haBuffer_Low[i])
        {
         double thisHigh=haBuffer_High[i];
         double thisLow =haBuffer_Low[i];
        }
      else
        {
         thisHigh=haBuffer_Low[i];
         thisLow =haBuffer_High[i];
        }
      //+------------------------------------------------------+
      //|     ENTRY                                            |
      //+------------------------------------------------------+
      //---- LONG SIGNALS --------------------------------------------      
      bool Long_RSI_PriceLine=(RSILine[i] > 50.0) && (RSILine[i] < 68.0);
      bool Long_RSI_AboveTradeSignal   =(RSILine[i] > RedLine[i]);    // GreenLine > RedLine
      bool Long_RSI_AboveMarketBaseLine=(RSILine[i] > BaseLine[i]);   // GreenLine > YellowLine
      bool Long_CloseHACandle          =(haClose  > mavHighs[i]); // Close HeikinAshi Candle
      bool Long_PriceActionChannelUp   =(mavHighs[i] > mavHighs[i+1]);
      //---- SHORT SIGNALS -------------------------------------------      
      bool Short_RSI_PriceLine=(RSILine[i] < 50.0) && (RSILine[i] > 32.0);
      bool Short_RSI_BelowTradeSignal   =(RSILine[i] < RedLine[i]);
      bool Short_RSI_BelowMarketBaseLine=(RSILine[i] < BaseLine[i]);
      bool Short_CloseHACandle          =(haClose  < mavLows[i]);
      bool Short_PriceActionChannelDown =(mavLows[i] < mavLows[i+1]);
      //---- CHECK ENTRY CONDITIONS ----------------------------------      
      if(Long_RSI_PriceLine && Long_RSI_AboveTradeSignal && Long_RSI_AboveMarketBaseLine &&
           Long_CloseHACandle && Long_PriceActionChannelUp )
        {
         LongSignal[i]=thisHigh + dSignalOffset;
         TradeLong =true;
         TradeShort=false;
        }
      if(Short_RSI_PriceLine && Short_RSI_BelowTradeSignal && Short_RSI_BelowMarketBaseLine &&
           Short_CloseHACandle && Short_PriceActionChannelDown )
        {
         ShortSignal[i]=thisLow - dSignalOffset;
         TradeLong =false;
         TradeShort=true;
        }
      //+------------------------------------------------------+
      //|     EXIT                                             |
      //+------------------------------------------------------+
      bool Exit_RSI_PriceLine=(RSILine[i] > 68.0) || (RSILine[i] < 32.0);
      bool Exit_BarRange     =MathAbs(haBuffer_High[i] - haBuffer_Low[i]) < // HeikinAshi Candles
      Factor_ShortBars*MathAbs(haBuffer_High[i+1] - haBuffer_Low[i+1]);
      //---- LONG EXITS ----------------------------------------------      
      // GreenLine crosses below the TSL; Trade Signal Line; RedLine
      bool XLong_RSI_BelowTradeSignal=(RSILine[i] < RedLine[i]) && (RSILine[i+1] > RedLine[i+1]);
      // GreenLine crosses below the upper Volatility Band; BlueLine
      bool XLong_RSI_BelowUpperVB=(RSILine[i] < UpZone[i]) && (RSILine[i+1] > UpZone[i+1]);
      // HeikinAshi Candles
      bool XLong_OpenCloseChange  =(haBuffer_Close[i] < haBuffer_Open[i]) && (haBuffer_Close[i+1] > haBuffer_Open[i+1]);
      bool XLong_ClosePriceChannel=(haClose < mavHighs[i]) || ((haClose < mavHighs[i]) && (haClose > mavLows[i]));
      //---- SHORT EXITS ---------------------------------------------      
      // GreenLine crosses above the TSL; Trade Signal Line; RedLine
      bool XShort_RSI_AboveTradeSignal=(RSILine[i] > RedLine[i]) && (RSILine[i+1] < RedLine[i+1]);
      // GreenLine crosses above the lower Volatility Band; BlueLine
      bool XShort_RSI_AboveLoverVB=(RSILine[i] > DnZone[i]) && (RSILine[i+1] < DnZone[i+1]);
      // HeikinAshi Candles  
      bool XShort_OpenCloseChange  =(haBuffer_Close[i] > haBuffer_Open[i]) && (haBuffer_Close[i+1] < haBuffer_Open[i+1]);
      bool XShort_ClosePriceChannel=(haClose > mavLows[i]) || ((haClose < mavHighs[i]) && (haClose > mavLows[i]));
/*if (i==14)
{
Print("==Close=",Close[i]);
Print("==haBuffer_High[i]=",haBuffer_High[i],"  haBuffer_Low[i]=",haBuffer_Low[i]);
Print("==haBuffer_High[i+1]=",haBuffer_High[i+1],"  haBuffer_Low[i+1]=",haBuffer_Low[i+1]);
Print("==Exit_RSI_PriceLine=",Exit_RSI_PriceLine,"  XShort_RSI_AboveTradeSignal=",XShort_RSI_AboveTradeSignal,"  XShort_RSI_AboveLoverVB=",XShort_RSI_AboveLoverVB);
Print("==Exit_BarRange=",Exit_BarRange,"  XShort_OpenCloseChange=",XShort_OpenCloseChange,"  XShort_ClosePriceChannel=",XShort_ClosePriceChannel); 
}*/
      //---- CHECK EXIT CONDITIONS -----------------------------------
      if(TradeLong && (Exit_RSI_PriceLine || XLong_RSI_BelowTradeSignal || XLong_RSI_BelowUpperVB ||
           Exit_BarRange || XLong_OpenCloseChange || XLong_ClosePriceChannel))
        {
         StopLong[i]=thisLow - dSignalOffset;
        }
      if(TradeShort && (Exit_RSI_PriceLine || XShort_RSI_AboveTradeSignal || XShort_RSI_AboveLoverVB ||
           Exit_BarRange || XShort_OpenCloseChange || XShort_ClosePriceChannel))
        {
         StopShort[i]=thisHigh + dSignalOffset;
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| StDev
//+------------------------------------------------------------------+  
double StDev(double& Data[], int Per)
  {
   return(MathSqrt(Variance(Data,Per)));
  }
//+------------------------------------------------------------------+
//| Variance
//+------------------------------------------------------------------+  
double Variance(double& Data[], int Per)
  {
   double sum, ssum;
   for(int i=0; i<Per; i++)
     {
      sum+=Data[i];
      ssum+=MathPow(Data[i],2);
     }
   return((ssum*Per - sum*sum)/(Per*(Per-1)));
  }
//+------------------------------------------------------------------+