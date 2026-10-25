//+------------------------------------------------------------------+
//|                                             SCT_PivotPointss.mq4 |
//|                                    Copyright 2020, Forex Jarvis. |
//|                                            forexjarvis@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Forex Jarvis. forexjarvis@gmail.com"
#property link      "https://forge.mql5.io"
#property strict
#property version   "1.00"

string sArrowBuy1 = "";
string sArrowBuy2 = "";
string sArrowSell1 = "";
string sArrowSell2 = "";

double dHighPrice=0.0;
double dLowPrice=0.0;


double dHighPrice1=0.0;
double dLowPrice1=0.0;

double dHighPrice2=0.0;
double dLowPrice2=0.0;

double dHighPrice3=0.0;
double dLowPrice3=0.0;

double dHighPrice4=0.0;
double dLowPrice4=0.0;

double dHighPrice6=0.0;
double dLowPrice6=0.0;

double dHighPrice7=0.0;
double dLowPrice7=0.0;

double dHighPrice8=0.0;
double dLowPrice8=0.0;

double dHighPrice9=0.0;
double dLowPrice9=0.0;

datetime dtBarTimeZ = 0;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---

   for(int z=4;z<=1000;z++) {
   
      sArrowBuy1 = "";
      sArrowBuy2 = "";
      sArrowSell1 = "";
      sArrowSell2 = "";

      // OHLC of the tested Candle 
      dHighPrice = iHigh(_Symbol,PERIOD_CURRENT,z);
      dLowPrice = iLow(_Symbol,PERIOD_CURRENT,z);
      
      dHighPrice1 = iHigh(_Symbol,PERIOD_CURRENT,z-1);
      dLowPrice1 = iLow(_Symbol,PERIOD_CURRENT,z-1);
      dHighPrice2 = iHigh(_Symbol,PERIOD_CURRENT,z-2);
      dLowPrice2 = iLow(_Symbol,PERIOD_CURRENT,z-2);
      dHighPrice3 = iHigh(_Symbol,PERIOD_CURRENT,z-3);
      dLowPrice3 = iLow(_Symbol,PERIOD_CURRENT,z-3);
      dHighPrice4 = iHigh(_Symbol,PERIOD_CURRENT,z-4);
      dLowPrice4 = iLow(_Symbol,PERIOD_CURRENT,z-4);
      
      dHighPrice6 = iHigh(_Symbol,PERIOD_CURRENT,z+1);
      dLowPrice6 = iLow(_Symbol,PERIOD_CURRENT,z+1);
      dHighPrice7 = iHigh(_Symbol,PERIOD_CURRENT,z+2);
      dLowPrice7 = iLow(_Symbol,PERIOD_CURRENT,z+2);
      dHighPrice8 = iHigh(_Symbol,PERIOD_CURRENT,z+1);
      dLowPrice8 = iLow(_Symbol,PERIOD_CURRENT,z+1);
      dHighPrice9 = iHigh(_Symbol,PERIOD_CURRENT,z+2);
      dLowPrice9 = iLow(_Symbol,PERIOD_CURRENT,z+2);

      dtBarTimeZ = iTime(NULL,PERIOD_CURRENT,z);  // it will return the datetime of the z bar of the current symbol on the H1 timeframe

   
      if (dHighPrice>dHighPrice1 && dHighPrice>dHighPrice2 && dHighPrice>dHighPrice3 && dHighPrice>dHighPrice4 &&
          dHighPrice>dHighPrice6 && dHighPrice>dHighPrice7 && dHighPrice>dHighPrice8 && dHighPrice>dHighPrice9) {
         sArrowSell1 = StringConcatenate("sArrowSell1",string(dtBarTimeZ));
         ObjectCreate(0,sArrowSell1,OBJ_ARROW_SELL,0,dtBarTimeZ,dHighPrice);
         ObjectSet(sArrowSell1,OBJPROP_COLOR,clrRed);
      } else if (dLowPrice<dLowPrice1 && dLowPrice<dLowPrice2 && dLowPrice<dLowPrice3 && dLowPrice<dLowPrice4 && 
                 dLowPrice<dLowPrice6 && dLowPrice<dLowPrice7 && dLowPrice<dLowPrice8 && dLowPrice<dLowPrice9) {
         sArrowBuy1 = StringConcatenate("sArrowBuy1",string(dtBarTimeZ));
         ObjectCreate(0,sArrowBuy1,OBJ_ARROW_BUY,0,dtBarTimeZ,dLowPrice);      
         ObjectSet(sArrowBuy1,OBJPROP_COLOR,clrGreen);
      }
   }
  }
//+------------------------------------------------------------------+
/*      if (dHighPrice>dHighPrice1 && dHighPrice>dHighPrice2 && dHighPrice>dHighPrice3 && dHighPrice>dHighPrice4 &&
          dHighPrice>dHighPrice6 && dHighPrice>dHighPrice7 && dHighPrice>dHighPrice8 && dHighPrice>dHighPrice9) {
         sArrowSell1 = StringConcatenate("sArrowSell1",string(dtBarTimeZ));
         ObjectCreate(0,sArrowSell1,OBJ_TEXT,0,dtBarTimeZ,dHighPrice);
         ObjectSetInteger(NULL,sArrowSell1,OBJPROP_FONTSIZE,15);
         ObjectSetInteger(NULL,sArrowSell1,OBJPROP_COLOR,clrGreen);
         ObjectSetString(NULL,sArrowSell1,OBJPROP_TEXT,"√");          
         
      } else if (dLowPrice<dLowPrice1 && dLowPrice<dLowPrice2 && dLowPrice<dLowPrice3 && dLowPrice<dLowPrice4 && 
                 dLowPrice<dLowPrice6 && dLowPrice<dLowPrice7 && dLowPrice<dLowPrice8 && dLowPrice<dLowPrice9) {
         sArrowBuy1 = StringConcatenate("sArrowBuy1",string(dtBarTimeZ));
         ObjectCreate(0,sArrowBuy1,OBJ_TEXT,0,dtBarTimeZ,dLowPrice);      
         ObjectSetInteger(NULL,sArrowBuy1,OBJPROP_FONTSIZE,15);
         ObjectSetInteger(NULL,sArrowBuy1,OBJPROP_COLOR,clrGreen);
         ObjectSetString(NULL,sArrowBuy1,OBJPROP_TEXT,"^");
      }*/