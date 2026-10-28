//+------------------------------------------------------------------+
//|                                            Identical candles.mq4 |
//|                                              Copyright 2017, Tor |
//|                                             http://einvestor.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Tor"
#property link      "http://einvestor.ru/"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

input bool Alerts=false;
input int Shift=1;
input bool OnlyChange=true; // Only signal change
input bool TF0 = true;//TF M1
input bool TF1 = true;//TF M5
input bool TF2 = true;//TF M15
input bool TF3= false;//TF M30
input bool TF4 = true;//TF H1
input bool TF5 = false;//TF H4
input bool TF6 = false;//TF D1
input bool TF7 = false;//TF W1
input bool TF8 = false;//TF MN
input bool Comments= true;
input color clrBUY = clrBlue;
input color clrSELL= clrRed;
double buy[],sell[],atr;
int TF[9],cnt=0; bool Vkl[9]; static datetime lastAlert=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorShortName("Identical candles");
   SetIndexBuffer(0,buy);
   SetIndexBuffer(1,sell);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,1,clrBUY);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1,clrSELL);
   SetIndexLabel(0,"Buy");
   SetIndexLabel(1,"Sell");
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   IndicatorDigits(_Digits+1);
   atr=iATR(_Symbol,_Period,200,1)/2;
   TF[0]=1; TF[1]=5; TF[2]=15; TF[3]=30; TF[4]=60; TF[5]=240; TF[6]=1440; TF[7]=10080; TF[8]=43200;
   Vkl[0]=TF0; Vkl[1]=TF1; Vkl[2]=TF2; Vkl[3]=TF3; Vkl[4]=TF4; Vkl[5]=TF5; Vkl[6]=TF6; Vkl[7]=TF7; Vkl[8]=TF8;
   for(int i=0;i<ArraySize(TF);i++){ if(Vkl[i]==true){ cnt=cnt+1; } }
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
   int limit; string txt="";  int sig=0; static int lastSig=0;
//---
   if(rates_total<=1)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit=limit+3;

   for(int x=limit-3; x>=0; x--)
     {
      sig=0;
      datetime time0=Time[x];
      for(int tf0=0; tf0<ArraySize(TF); tf0++)
        {

         if(Vkl[tf0]==true)
           {
            int br=iBarShift(_Symbol,TF[tf0],time0);
            string trend="";
            if(iOpen(_Symbol,TF[tf0],br+Shift)>iClose(_Symbol,TF[tf0],br+Shift))
              {
               sig=sig-1; trend="Down";
              }
            if(iOpen(_Symbol,TF[tf0],br+Shift)<iClose(_Symbol,TF[tf0],br+Shift))
              {
               sig=sig+1; trend="Up";
              }
            if(x<1){ txt=txt+""+(string)ReturnTF(TF[tf0])+"  "+trend+"\n"; }
           }

        }
      if(MathAbs(sig)==cnt)
        {
         if(sig>0 && ((OnlyChange && lastSig<1) || !OnlyChange))
           {
            buy[x]=Open[x]-atr;
            lastSig=1;
            if(lastAlert<Time[x] && x<=1 && Alerts)
              {
               Alert(_Symbol+" all candles : BUY");
               lastAlert=Time[x];
              }
           }
         if(sig<0 && ((OnlyChange && lastSig>-1) || !OnlyChange))
           {
            sell[x] = Open[x]+atr;
            lastSig = -1;
            if(lastAlert<Time[x] && x<=1 && Alerts)
              {
               Alert(_Symbol+" all candles : SELL");
               lastAlert=Time[x];
              }
           }
        }
     }
   if(Comments){ Comment(txt+""+(string)sig+" / "+(string)cnt); }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
string ReturnTF(int tfw=0)
  {
   switch(tfw)
     {
      case 1:
         return "M1";
         break;
      case 5:
         return "M5";
         break;
      case 15:
         return "M15";
         break;
      case 30:
         return "M30";
         break;
      case 60:
         return "H1";
         break;
      case 240:
         return "H4";
         break;
      case 1440:
         return "D1";
         break;
      case 10080:
         return "W1";
         break;
      case 43200:
         return "MN";
         break;
     }
   return "";
  }
//+------------------------------------------------------------------+
