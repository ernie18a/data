//+------------------------------------------------------------------+
//|                                             TandemInstrument.mq5 |
//|                                 Copyright 2012, Evgeniy Trofimov |
//|                          https://www.mql5.com/ru/users/evgetrofi |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Evgeniy Trofimov"
#property link      "https://www.mql5.com/ru/users/evgetrofi"
#property version   "1.15"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrTeal,clrSandyBrown

#include <MyMQL_v2.1.mqh>
enum Corr{
   Direct, Indirect
};
input string S = "GBPUSD"; //Indirect instrument
input int    P   = 400;    //Field of training
input int Optimum = 50;    //Interval of retraining
input Corr Correlation = Direct;
double K=0;          //The density coefficient of indirect instrument
double High_Win = 0; //Maximum price of basic instrument
double Low_Win = 0;  //Minimum price of basic instrument
double L=0;          //Minimum price of indirect instrument
double    ExtOpenBuffer[];
double    ExtHighBuffer[];
double    ExtLowBuffer[];
double    ExtCloseBuffer[];
double    ExtColorBuffer[];
datetime  LastOptimization;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
   
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
   
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetString(0,PLOT_LABEL,S+" Open;"+S+" High;"+S+" Low;"+S+" Close");
   IndicatorSetString(INDICATOR_SHORTNAME, S);
   return(0);
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
   static datetime LastTime;
   ArraySetAsSeries(time,true);
   int beg = rates_total-prev_calculated-1;
   if(ExtOpenBuffer[1]==0.0) {
      beg = rates_total-2;
      LastTime=0;
      LastOptimization=0;
   }
   for(int i=beg;i>=0;i--) {
      if(LastTime<time[i]) {
         ExtOpenBuffer[i]=0;
         ExtHighBuffer[i]=0;
         ExtLowBuffer[i]=0;
         ExtCloseBuffer[i]=0;
         if(Optimum>0){
            if(LastOptimization + Optimum * (iTime(Symbol(), Period(), i)-iTime(Symbol(), Period(), i+1)) < iTime(Symbol(), Period(), i)){
               Optimization(i,P);
               LastOptimization = iTime(Symbol(), Period(), i);
            }      
         }
         IndicatorPrint(i, rates_total);
         LastTime=time[i];
      }
   }//Next i
   IndicatorPrint(0, rates_total);
   string txt="compressed";
   if(K>1) txt="extended";
   Comment("/The density coefficient of indirect instrument "+S+": "+DoubleToString(K,5)+" ("+txt+")");   
//--- return value of prev_calculated for next call
   return(rates_total);
}//OnCalculate()
//+------------------------------------------------------------------+
void Optimization(int fBegin=0, int fLen=200){
//The procedure for selection of the density coefficient of indirect instrument 
//and minimum of basic and indirect instruments.
   if(Symbol()==S) Print("choose the same currency pairs "+S+"!!!");
          High_Win = GetExtremumPrice(Symbol(),Period(),fBegin, fLen,0);
          Low_Win  = GetExtremumPrice(Symbol(),Period(),fBegin, fLen,1);
   double H        = GetExtremumPrice(S,Period(),fBegin, fLen,0);
          L        = GetExtremumPrice(S,Period(),fBegin, fLen,1);
          if(H - L == 0){
            K = 1; 
          }else{
            K = (High_Win - Low_Win) / (H - L);
          }
}//Optimization()
//+------------------------------------------------------------------+
double GetExtremumPrice(string fSymbol, ENUM_TIMEFRAMES fTF, int fBegin=0, int fLen=1, int fType=0){
   //If fType = 0, the function returns the maximum price of the instrument, otherwise - the minimum
   double Prices[];
   int i;
   ArraySetAsSeries(Prices,true);
   if(fType==0){
      CopyHigh(fSymbol, fTF, fBegin, fLen, Prices);
      i=ArrayMaximum(Prices);
   }else{
      CopyLow(fSymbol, fTF, fBegin, fLen, Prices);
      i=ArrayMinimum(Prices);
   }
   return(Prices[i]);
}//GetExtremumPrice()
//+------------------------------------------------------------------+
void IndicatorPrint(int Candle, int rates_total){
   int Candle2 = iBarShift(S, Period(), iTime(Symbol(), Period(), Candle));
   int Candle2Last = iBarShift(S, Period(), iTime(Symbol(), Period(), Candle+1));
   ExtOpenBuffer[Candle]=K * (iOpen( S, Period(), Candle2) - L) + Low_Win;
   ExtHighBuffer[Candle]=K * (iHigh( S, Period(), Candle2) - L) + Low_Win;
   ExtLowBuffer[Candle] =K * (iLow(  S, Period(), Candle2) - L) + Low_Win;
   ExtCloseBuffer[Candle]=K *(iClose(S, Period(), Candle2) - L) + Low_Win;
   if(Correlation == Indirect){
      ExtOpenBuffer[Candle] = High_Win - (ExtOpenBuffer[Candle] - Low_Win);
      ExtCloseBuffer[Candle]= High_Win - (ExtCloseBuffer[Candle] - Low_Win);
      ExtHighBuffer[Candle]=  High_Win - (ExtHighBuffer[Candle] - Low_Win);
      ExtLowBuffer[Candle]=  High_Win -  (ExtLowBuffer[Candle] - Low_Win);      
   }
   if(ExtOpenBuffer[Candle]>ExtCloseBuffer[Candle]){
      ExtColorBuffer[Candle]=0;
   }else{
      ExtColorBuffer[Candle]=1;
   }
   if(Candle+1>rates_total-1) return;
   if((ExtCloseBuffer[Candle+1]>iClose(S, Period(), Candle2Last) && ExtCloseBuffer[Candle]<iClose(S, Period(), Candle2)) ||
      (ExtCloseBuffer[Candle+1]<iClose(S, Period(), Candle2Last) && ExtCloseBuffer[Candle]>iClose(S, Period(), Candle2))){
      LastOptimization=0;
   }
}//IndicatorPrint()
//+------------------------------------------------------------------+
