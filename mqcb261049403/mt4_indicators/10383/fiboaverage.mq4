//+------------------------------------------------------------------+
//|                                                Fibo-Average.mq4  |
//|                                                Copyright © 2011  |
//|                                            basisforex@gmail.com  |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2011"
#property  link      "basisforex@gmail.com"
//----------------------------------
#property  indicator_chart_window
#property  indicator_buffers 2
#property  indicator_color1  Blue
#property  indicator_color2  Yellow
//+------------------------------------------------------------------+
extern int       nAppliedPrice=0;// PRICE_CLOSE=0; PRICE_OPEN=1; PRICE_HIGH=2; PRICE_LOW=3; PRICE_MEDIAN=4; PRICE_TYPICAL=5; PRICE_WEIGHTED=6;
extern int       maPeriod      =55;
extern int       maMethod=0;// MODE_SMA=0; MODE_EMA=1; MODE_SMMA=2; MODE_LWMA=3; 
//----
double           BBPBuffer[];
double           TempBuffer[];
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,BBPBuffer);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,TempBuffer);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   int    i;
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+55;
//----
   i=limit;
   while(i>=0)
     {
      BBPBuffer[i]=(AppliedPrice(nAppliedPrice,i+0)+AppliedPrice(nAppliedPrice,i+1)+AppliedPrice(nAppliedPrice,i+1)
                    +AppliedPrice(nAppliedPrice,i+2)+AppliedPrice(nAppliedPrice,i+3)+AppliedPrice(nAppliedPrice,i+5)
                    +AppliedPrice(nAppliedPrice,i+8)+AppliedPrice(nAppliedPrice,i+13)+AppliedPrice(nAppliedPrice,i+21)
                    +AppliedPrice(nAppliedPrice,i+34)+AppliedPrice(nAppliedPrice,i+55))/11;
      i--;
     }
   i=limit;
   while(i>=0)
     {
      TempBuffer[i]=iMAOnArray(BBPBuffer,0,maPeriod,0,maMethod,i);
      i--;
     }
//----
  return(0);
  }
//+------------------------------------------------------------------+
double AppliedPrice(int nAppliedPrice1,int nIndex)
  {
   double aPrice;
   switch(nAppliedPrice1)
     {
      case 0:  aPrice = Close[nIndex];                                        break;
      case 1:  aPrice = Open[nIndex];                                         break;
      case 2:  aPrice = High[nIndex];                                         break;
      case 3:  aPrice = Low[nIndex];                                          break;
      case 4:  aPrice = (High[nIndex]+Low[nIndex]) / 2.0;                     break;
      case 5:  aPrice = (High[nIndex]+Low[nIndex] + Close[nIndex]) / 3.0;     break;
      case 6:  aPrice = (High[nIndex]+Low[nIndex] + 2 * Close[nIndex]) / 4.0; break;
      default: aPrice = 0.0;
     }
   return(aPrice);
  }
//+------------------------------------------------------------------+
