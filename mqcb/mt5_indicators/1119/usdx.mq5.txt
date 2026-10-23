//+------------------------------------------------------------------+
//|                                                         USDx.mq5 |
//|                                   Copyright 2012, Bekmetov Denis |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Bekmetov Denis"
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property indicator_separate_window


#property indicator_buffers 7
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "USDx"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2



input int MaxBar=1000;//Number of bars for calculation

//--- indicator buffers
double         USDx[],mEURUSD[],mUSDJPY[],mGBPUSD[],mUSDCAD[],mUSDSEK[],mUSDCHF[],F[];
int handle1,handle2,handle3,handle4,handle5,handle6;

double sEURUSD;
double sUSDJPY;
double sGBPUSD;
double sUSDCAD;
double sUSDSEK;
double sUSDCHF;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,USDx,INDICATOR_DATA);
   SetIndexBuffer(1,mEURUSD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,mUSDJPY,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,mGBPUSD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,mUSDCAD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,mUSDSEK,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,mUSDCHF,INDICATOR_CALCULATIONS);

   ArraySetAsSeries(mEURUSD,true);
   ArraySetAsSeries(mUSDJPY,true);
   ArraySetAsSeries(mGBPUSD,true);
   ArraySetAsSeries(mUSDCAD,true);
   ArraySetAsSeries(mUSDSEK,true);
   ArraySetAsSeries(mUSDCHF,true);
   ArraySetAsSeries(USDx,true);



//---
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
   if(rates_total!=prev_calculated)
     {
      if(CopyClose("EURUSD",PERIOD_CURRENT,0,MaxBar,mEURUSD)<=0 || 
         CopyClose("USDJPY",PERIOD_CURRENT,0,MaxBar,mUSDJPY)<=0 ||
         CopyClose("GBPUSD",PERIOD_CURRENT,0,MaxBar,mGBPUSD)<=0 ||
         CopyClose("USDCAD",PERIOD_CURRENT,0,MaxBar,mUSDCAD)<=0 ||
         CopyClose("USDSEK",PERIOD_CURRENT,0,MaxBar,mUSDSEK)<=0 ||
         CopyClose("USDCHF",PERIOD_CURRENT,0,MaxBar,mUSDCHF)<=0 )
        {

         return(0);
        }

     }
   int i;
   for(i=prev_calculated;i<rates_total;i++)
     {
      sEURUSD =MathPow(mEURUSD[i],-0.576);
      sUSDJPY =MathPow(mUSDJPY[i],0.136);
      sGBPUSD =MathPow(mGBPUSD[i],-0.119);
      sUSDCAD =MathPow(mUSDCAD[i],0.091);
      sUSDSEK =MathPow(mUSDSEK[i],0.042);
      sUSDCHF =MathPow(mUSDCHF[i],0.036);

      USDx[i]=50.14348112 *sEURUSD*sUSDJPY*sGBPUSD *sUSDCAD*sUSDSEK*sUSDCHF;

     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
