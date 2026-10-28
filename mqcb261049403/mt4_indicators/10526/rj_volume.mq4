//+------------------------------------------------------------------+
//|                                                    Rj_Volume.mq4 |
//|                           Copyright © 2011, RJ Rjabkov Aleksandr |
//|                                                     rj-a@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, RJ Rjabkov Aleksandr"
#property link      "rj-a@mail.ru"

#property indicator_chart_window
extern int DayRange=1;

double VolBuy[];
double VolSell[];
static datetime LastTime;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init() 
  {
   IndicatorBuffers(2);
   SetIndexBuffer(0,VolBuy);
   SetIndexBuffer(1,VolSell);
   return(0);
  }

int deinit() {return(0);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start() 
  {
   int i,j;
   double MaxPrice = iHigh(NULL, PERIOD_D1, 0);
   double MinPrice = iLow(NULL, PERIOD_D1, 0);
   
   if (ArraySize(VolBuy)<DayRange+1) return(0);

   for(j=DayRange; j>=0; j--) 
     {
      MaxPrice = MathMax(MaxPrice, iHigh(NULL, PERIOD_D1, j));
      MinPrice = MathMin(MinPrice, iLow(NULL, PERIOD_D1, j));
     }
   int Range=MathRound((MaxPrice-MinPrice)/Point);

   ArrayInitialize(VolBuy,0.0);
   ArrayInitialize(VolSell,0.0);

   int ind=iBarShift(NULL,PERIOD_M1,iTime(NULL,PERIOD_D1,DayRange));
   
   if (ind<0) return(-1);
   
   for(i=ind; i>=1; i--) 
     {
      double lw=Low[i], op=Open[i], cl=Close[i], hg=High[i], vl=Volume[i];
      double up=0.0, sl=0.0, dl=0.0;
      for(double k=High[i]; k>=Low[i]; k-=Point) 
        {
         j=MathRound((k-MinPrice)/Point);

         if(op<cl) 
           {
            up=((hg-lw)+(cl-op))/Point;
            sl=(hg-lw)/Point;
            if(up!=0 && sl!=0) 
              {
               dl=vl/(up+sl);
               if ((j>=0) && (j<ArraySize(VolBuy)))  {VolBuy[j]  += dl*up/sl;}
               if ((j>=0) && (j<ArraySize(VolSell))) {VolSell[j] += dl;}
              }
           }
         if(op>=cl) 
           {
            up=(hg-lw)/Point;
            sl=((hg-lw)+(op-cl))/Point;
            if(up!=0 && sl!=0) 
              {
               dl=vl/(up+sl);
               if ((j>=0) && (j<ArraySize(VolBuy)))  {VolBuy[j]  += dl;}
               if ((j>=0) && (j<ArraySize(VolSell))) {VolSell[j] += dl*sl/up;}
              }
           }
        }
     }
   LastTime=TimeCurrent();
   return(0);
  }
//+------------------------------------------------------------------+
