//+------------------------------------------------------------------+
//|                                        Custom Moving Average.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters

extern int Price_Mode=0;
extern int MA_Period=13;
extern int CountTick=100;
extern bool DrawAll=false;


//---- indicator buffers
double ExtMapBuffer[];

int ExtCountedBars=0;
double Price[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   string short_name;
   SetIndexStyle(0,DRAW_SECTION);
   short_name="SMA(";
   IndicatorShortName(short_name+MA_Period+")");
   SetIndexBuffer(0,ExtMapBuffer);
   ArrayResize(Price,MA_Period);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start() {
   int limit;
   int counted_bars=IndicatorCounted();
   int i, pos;
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=2;
   for (i = limit-MA_Period-1;i>=0;i--){
      PriceArray(Price,i);
      sma(i);  
   }
   return(0);
}

bool PriceArray(double &Price[], int pos){
   int i,shift;
   shift=0;
   for (i=0;i<MA_Period;i++){
      Price[i]=iCustom(NULL,0,"VininI ConstTickPrice",Price_Mode,CountTick,DrawAll,0,pos+shift);
      shift+=(iCustom(NULL,0,"VininI ConstTickPrice",Price_Mode,CountTick,DrawAll,1,pos+shift)+1);
   }
}

//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma(int pos) {
   int i,shift;
   double sum=0;
   if (!DrawAll) {
      shift=iCustom(NULL,0,"VininI ConstTickPrice",Price_Mode,CountTick,DrawAll,1,pos);
      for (i=1;i<=shift;i++) ExtMapBuffer[pos+i]=EMPTY_VALUE;
   }
   for(i=0;i<MA_Period;i++) sum+=Price[i];
   ExtMapBuffer[pos]=sum/MA_Period;
  }
/*
//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
void ema(int pos) {
   int i,shift;
   double pr=2.0/(MA_Period+1);
   if (!DrawAll) {
      shift=iCustom(NULL,0,"VininI ConstTickPrice",Price_Mode,CountTick,DrawAll,1,pos);
      for (i=1;i<=shift;i++) ExtMapBuffer[pos+i]=EMPTY_VALUE;
   }
   if(pos==Bars-2) ExtMapBuffer[pos+1]=Close[pos+1];
      ExtMapBuffer[pos]=Close[pos]*pr+ExtMapBuffer[pos+1]*(1-pr);
 	   pos--;
     }
  }


//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
void smma()
  {
   double sum=0;
   int    i,k,pos=Bars-ExtCountedBars+1;
//---- main calculation loop
   pos=Bars-MA_Period;
   if(pos>Bars-ExtCountedBars) pos=Bars-ExtCountedBars;
   while(pos>=0)
     {
      if(pos==Bars-MA_Period)
        {
         //---- initial accumulation
         for(i=0,k=pos;i<MA_Period;i++,k++)
           {
            sum+=Close[k];
            //---- zero initial bars
            ExtMapBuffer[k]=0;
           }
        }
      else sum=ExtMapBuffer[pos+1]*(MA_Period-1)+Close[pos];
      ExtMapBuffer[pos]=sum/MA_Period;
 	   pos--;
     }
  }
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma()
  {
   double sum=0.0,lsum=0.0;
   double price;
   int    i,weight=0,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<=MA_Period;i++,pos--)
     {
      price=Close[pos];
      sum+=price*i;
      lsum+=price;
      weight+=i;
     }
//---- main calculation loop
   pos++;
   i=pos+MA_Period;
   while(pos>=0)
     {
      ExtMapBuffer[pos]=sum/weight;
      if(pos==0) break;
      pos--;
      i--;
      price=Close[pos];
      sum=sum-lsum+price*MA_Period;
      lsum-=Close[i];
      lsum+=price;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer[Bars-i]=0;
  }
//+------------------------------------------------------------------+
*/