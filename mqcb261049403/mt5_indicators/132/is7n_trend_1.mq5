//+------------------------------------------------------------------+
//|                                                 iS7N_TREND_1.mq5 |
//|                                       Copyright 2010, SHOOTER777 |
//|                                                      s7n@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, SHOOTER777"
#property link      "s7n@mail.ru"
#property version   "1.00"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
//---- plot settings
#property indicator_label1  "iTREND_1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  DarkBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input int Per=14;
//--- 
int iMx=300; // max bars to calculate
//--- indicator buffers
double dPlot[];
//--- handles buffers
double dBuf_1[];
double dBuf_2[];
//--- calculations buffers
double dBuf_3[];
double dBuf_4[];
//--- handles
int ihMA_1;
int ihMA_2;
//--- global variables
int P0,P2,P4;
int iIndCnt,iBufCnt,iRT,iPC;
int limit;
string sShNm;
double eee;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   int iPer=StringConcatenate(sShNm,"iS7N_TREND_1( ",Per," )");
   int iBars=Bars(_Symbol,_Period);  // number of bars in the history
//---
   SetIndexBuffer(0,dPlot,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,"TREND_1");
//---
   SetIndexBuffer(1,dBuf_1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,dBuf_2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,dBuf_3,INDICATOR_CALCULATIONS);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits-1);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,sShNm);
//---  
   vInPr();
//---
   ihMA_1  = iMA(Symbol(), 0, P0 , 0, MODE_EMA, PRICE_CLOSE);
   ihMA_2  = iMA(Symbol(), 0, P2 , 0, MODE_EMA, PRICE_CLOSE);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   if(prev_calculated<=0)
     {
      for(int i=0;i<=rates_total-1;i++)
        {
         dPlot [i]=EMPTY_VALUE;
         dBuf_1[i]=EMPTY_VALUE;
         dBuf_2[i]=EMPTY_VALUE;
         dBuf_3[i]=EMPTY_VALUE;
        }
     }

//--- the available bars should be greater than specified below
   int iMn=10*P0;
   if(iMn>rates_total)return(0);
   if(iMn>iMx) iMx=iMn;
   if(iMx>rates_total)iMx=rates_total;
//---    
   int limP0;
//---
   int preMx=1;
   if(prev_calculated<=0)// check for the first call
     {
      limit=rates_total-iMx;
      limP0=limit+P0;
     }
   else
     {
      limit=prev_calculated-preMx;
      limP0= limit;
     }

//---
   iBufCnt=limit-1;
//---
   ArrayResize(dBuf_4,P0);
//---
   vInt();
//---
   for(int iii=limit;iii<=rates_total-1;iii++)
     {
      dBuf_3[iii]=2.0*dBuf_2[iii]-dBuf_1[iii];
     }

   for(int iii=limP0; iii<=rates_total-1;iii++)
     {
      ArrayCopy(dBuf_4,dBuf_3,0,iii,P0);

      dPlot[iii]=iMAOnArrayMQL4(dBuf_4,0,P2,0,3,0);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| vInPr                                                            |
//+------------------------------------------------------------------+
void vInPr()
  {
   P0=Per;
   P2=Per/2;
   P4= int (MathSqrt(Per));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void vInt()
  {
   int n1,n2;
   n1=CopyBuffer(ihMA_1,0,0,iBufCnt+1,dBuf_1);
   n2=CopyBuffer(ihMA_2,0,0,iBufCnt+1,dBuf_2);
  }
//+------------------------------------------------------------------+
//| iMAOnArrayMQL4                                                   |
//+------------------------------------------------------------------+
double iMAOnArrayMQL4(double &array[],
                      int total,
                      int period,
                      int ma_shift,
                      int ma_method,
                      int shift)
  {
   double buf[],arr[];
   if(total==0) total=ArraySize(array);
   if(total>0 && total<=period) return(0);

   if(shift>total-period-ma_shift) return(0);

   switch(ma_method)
     {
      case MODE_SMA :
        {
         total=ArrayCopy(arr,array,0,shift+ma_shift,period);
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0;
         int    i,pos=total-1;
         for(i=1;i<period;i++,pos--)
            sum+=arr[pos];
         while(pos>=0)
           {
            sum+=arr[pos];
            buf[pos]=sum/period;
            sum-=arr[pos+period-1];
            pos--;
           }
         return(buf[0]);
        }
      case MODE_EMA :
        {

         if(ArrayResize(buf,total)<0) return(0);
         double pr=2.0/(period+1);
         int    pos=total-2;
         while(pos>=0)
           {
            if(pos==total-2) buf[pos+1]=array[pos+1];
            buf[pos]=array[pos]*pr+buf[pos+1]*(1-pr);
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_SMMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0;
         int    i,k,pos;
         pos=total-period;
         while(pos>=0)
           {
            if(pos==total-period)
              {
               for(i=0,k=pos;i<period;i++,k++)
                 {
                  sum+=array[k];
                  buf[k]=0;
                 }
              }
            else sum=buf[pos+1]*(period-1)+array[pos];
            buf[pos]=sum/period;
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_LWMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0.0,lsum=0.0;
         double price;
         int    i,weight=0,pos=total-1;
         for(i=1;i<=period;i++,pos--)
           {
            price=array[pos];
            sum+=price*i;
            lsum+=price;
            weight+=i;
           }
         pos++;
         i=pos+period;
         while(pos>=0)
           {
            buf[pos]=sum/weight;
            if(pos==0) break;
            pos--;
            i--;
            price=array[pos];
            sum=sum-lsum+price*period;
            lsum-=array[i];
            lsum+=price;
           }//Print("total ",buf[shift+ma_shift]);
         return(buf[shift+ma_shift]);
        }
      default: return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
