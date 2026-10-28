//+------------------------------------------------------------------+
//|                                                  Correlation.mq5 |
//|                                                        AIS Forex |
//|                        https://www.mql5.com/ru/users/aleksej1966 |
//+------------------------------------------------------------------+
#property copyright "AIS Forex"
#property link      "https://www.mql5.com/ru/users/aleksej1966"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_minimum -100
#property indicator_maximum  100

#property indicator_type1  DRAW_LINE
#property indicator_label1 "Correlation"
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID

enum cor_type {Pearson,Kendall,Spearman,Fechner,Colligation,Difference,Distance};

input string SecSymbol="USDCHF";
input cor_type Type=Pearson;
input int iPeriod=24;
struct _matrix {double array[];};
_matrix mtrx1[],mtrx2[];
int period,price1[],price2[],arr1[][2],arr2[][2];
double buffer[],point,denom,row[],column[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,buffer,INDICATOR_DATA);
   ArraySetAsSeries(buffer,true);

   bool custom=false;
   if(SymbolExist(SecSymbol,custom)==false)
     {
      Alert("Symbol not found!");
      return(INIT_FAILED);
     }
   double sec[];
   CopyOpen(SecSymbol,PERIOD_CURRENT,0,100,sec);
   ArrayFree(sec);

   period=MathMax(3,iPeriod);
   ArrayResize(price1,period);
   ArrayResize(price2,period);
   for(int i=0;i<period;i++)
     {
      price1[i]=i;
      price2[i]=i;
     }

   point=SymbolInfoDouble(SecSymbol,SYMBOL_POINT);

   if(Type==Kendall)
      denom=period*(period-1)/2;

   if(Type==Difference || Type==Spearman)
     {
      ArrayResize(arr1,period);
      ArrayResize(arr2,period);
      denom=period*(period*period-1)/6;
     }

   if(Type==Distance)
     {
      ArrayResize(mtrx1,period);
      ArrayResize(mtrx2,period);
      for(int j=0;j<period;j++)
        {
         ArrayResize(mtrx1[j].array,period);
         ArrayResize(mtrx2[j].array,period);
        }
      ArrayResize(row,period);
      ArrayResize(column,period);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
//---
   if(NewBar()==true)
     {
      ArraySetAsSeries(open,true);
      int bars=rates_total-prev_calculated-1;

      if(prev_calculated<1)
        {
         double sec[];
         CopyOpen(SecSymbol,PERIOD_CURRENT,0,100,sec);
         ArrayFree(sec);
         bars=MathMin(bars,iBars(SecSymbol,PERIOD_CURRENT)-1);
        }

      for(int i=bars;i>-1;i--)
        {
         if(NewPrice(open[i],iOpen(SecSymbol,PERIOD_CURRENT,i))==false)
            return(0);

         double res=0;

         if(Type==Pearson)
           {
            double x=0,x2=0,y=0,y2=0,xy=0;
            for(int i=0;i<period;i++)
              {
               x=x+(double)price1[i];
               x2=x2+(double)price1[i]*price1[i];
               y=y+(double)price2[i];
               y2=y2+(double)price2[i]*price2[i];
               xy=xy+(double)price1[i]*price2[i];
              }
            denom=MathSqrt((period*x2-x*x)*(period*y2-y*y));
            if(denom>0)
               res=(period*xy-x*y)/denom;
           }

         if(Type==Kendall)
           {
            for(int j=period-2;j>=0;j--)
               for(int k=j+1;k<period;k++)
                  res=res+Sign(price1[j]-price1[k])*Sign(price2[j]-price2[k]);
            res=res/denom;
           }

         if(Type==Difference || Type==Spearman)
           {
            for(int j=0;j<period;j++)
              {
               int p=j+1;
               arr1[j][0]=price1[j];
               arr1[j][1]=p;
               arr2[j][0]=price2[j];
               arr2[j][1]=p;
              }
            ArraySort(arr1);
            ArraySort(arr2);

            if(Type==Difference)
               for(int j=0;j<period;j++)
                  res=res+MathPow(arr1[j][1]-arr2[j][1],2);
            else
               for(int j=0;j<period;j++)
                  for(int k=0;k<period;k++)
                     if(arr1[j][1]==arr2[k][1])
                        res=res+MathPow(j-k,2);

            res=1-res/denom;
           }

         if(Type==Fechner)
           {
            int c1=0,c2=0;
            double sum1=0,sum2=0;
            for(int j=0;j<period;j++)
              {
               sum1=sum1+price1[j];
               sum2=sum2+price2[j];
              }
            sum1=(double)sum1/period;
            sum2=(double)sum2/period;
            for(int j=0;j<period;j++)
              {
               if((price1[j]-sum1)*(price2[j]-sum2)>0)
                  c1++;
               else
                  c2++;
              }
            denom=(double)c1+c2;
            if(denom>0)
               res=(c1-c2)/denom;
           }

         if(Type==Colligation)
           {
            int a=0,b=0,c=0,d=0;
            double sum1=0,sum2=0;
            for(int j=0;j<period;j++)
              {
               sum1=sum1+price1[j];
               sum2=sum2+price2[j];
              }
            sum1=(double)sum1/period;
            sum2=(double)sum2/period;
            for(int j=0;j<period;j++)
              {
               if(price1[j]>sum1)
                 {
                  if(price2[j]>sum2)
                     a++;
                  else
                     b++;
                 }
               else
                 {
                  if(price2[j]>sum2)
                     c++;
                  else
                     d++;
                 }
              }
            sum1=MathSqrt(a*d);
            sum2=MathSqrt(b*c);
            denom=sum1+sum2;
            if(denom>0)
               res=(sum1-sum2)/denom;
           }

         if(Type==Distance)
           {
            for(int j=0;j<period;j++)
               for(int k=0;k<period;k++)
                 {
                  mtrx1[j].array[k]=price1[j]-price1[k];
                  mtrx2[j].array[k]=price2[j]-price2[k];
                 }
            CalcCov(mtrx1);
            CalcCov(mtrx2);
            double covariance=0,var1=0,var2=0;
            for(int j=0;j<period;j++)
               for(int k=0;k<period;k++)
                 {
                  covariance=covariance+mtrx1[j].array[k]*mtrx2[j].array[k];
                  var1=var1+mtrx1[j].array[k]*mtrx1[j].array[k];
                  var2=var2+mtrx2[j].array[k]*mtrx2[j].array[k];
                 }
            res=covariance/MathSqrt(var1*var2);
           }

         buffer[i]=100*res;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalcCov(_matrix &a[])
  {
//---
   double sum=0;

   for(int j=0;j<period;j++)
     {
      row[j]=0;
      column[j]=0;
     }

   for(int j=0;j<period;j++)
     {
      for(int k=0;k<period;k++)
        {
         sum=sum+a[j].array[k];
         row[j]=row[j]+a[j].array[k];
         if(j==k)
            column[j]=column[j]+a[j].array[k];
        }
      row[j]=row[j]/period;
      column[j]=column[j]/period;
     }
   sum=sum/(period*period);

   for(int j=0;j<period;j++)
      for(int k=0;k<period;k++)
         a[j].array[k]=a[j].array[k]-row[j]-column[k]+sum;
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
char Sign(int diff)
  {
//---
   if(diff>0)
      return(1);

   if(diff<0)
      return(-1);

   return(0);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewPrice(double open1,double open2)
  {
//---
   for(int i=period-1;i>0;i--)
     {
      int p=i-1;
      price1[i]=price1[p];
      price2[i]=price2[p];
     }

   price1[0]=(int)MathRound(open1/_Point);
   price2[0]=(int)MathRound(open2/point);

   if(price1[0]<1 || price2[0]<1)
      return(false);

   return(true);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
  {
//---
   static long last_bar1,last_bar2;
   long cur_bar1=SeriesInfoInteger(_Symbol,PERIOD_CURRENT,SERIES_LASTBAR_DATE),
        cur_bar2=SeriesInfoInteger(SecSymbol,PERIOD_CURRENT,SERIES_LASTBAR_DATE);
   if(last_bar1<cur_bar1 && last_bar2<cur_bar2)
     {
      last_bar1=cur_bar1;
      last_bar2=cur_bar2;
      return(true);
     }
   return(false);
//---
  }
//+------------------------------------------------------------------+
