
#property copyright   "Copyright 2025, Max Michael"
#property description "Fair Value Gaps indicator or 'imbalance areas' where markets often move back to."
#property indicator_chart_window
#property strict

extern  int        barsback = 300;
extern  double  minimumpips = 2.0;
extern  color    boxcolorUp = C'0x00,0x40,0x00';
extern  color  boxcolorDown = C'0x55,0x00,0x00';

double   pipvalue;
datetime prevtime;

int init() 
{
   pipvalue=Point;
   if (Digits==5 || Digits<=3) pipvalue=Point*10;
   barsback=MathMin(barsback,Bars-101);
   return(0);
}

int deinit() 
{
   DeleteObjects(barsback+100);
   return(0); 
}

int start() 
{        
   if(Time[1]!=prevtime)
   {
      prevtime=Time[1];
      DeleteObjects(4);
      for(int i=barsback; i>=0; i--)
      {
         bool Bull_fvg = Low[i] >High[i+2] && Close[i+1]>High[i+2];
         bool Bear_fvg = High[i]<Low[i+2]  && Close[i+1]<Low[i+2];
         if  (Bull_fvg) MakeBoxGreen(Low[i],High[i+2],i);
         if  (Bear_fvg) MakeBoxRed(Low[i+2],High[i],i);
      }
   }
   return(0);  
}

void MakeBoxRed(double priceHigh, double priceLow, int bar) 
{
   int length=0;
   for(int i=bar; i>0; i--) { if(High[i]>priceLow) break; length++; } // continue the box until breached
   datetime time1 = iTime(_Symbol,0,bar+2);               // start of box 
   datetime time2 = iTime(_Symbol,0,bar-length);          // -1 bars until a breach of priceLow or bar 0
   string objname = "FVG_"+string(Time[bar]);
   if(ObjectFind(objname)==0) ObjectDelete(objname);   // delete box and update
   if ( (Low[bar+2]-High[bar])/pipvalue > minimumpips) // filter out tiny boxes 
   {
      ObjectCreate(objname,OBJ_RECTANGLE,0,time1, priceHigh, time2, priceLow);
      ObjectSet(objname,OBJPROP_COLOR,boxcolorDown);
      ObjectSet(objname,OBJPROP_BACK,True); // True=fillbox
   }
}

void MakeBoxGreen(double priceHigh, double priceLow, int bar)
{
   int length=0;
   for(int i=bar; i>0; i--) { if(Low[i]<priceHigh) break; length++; } // continue the box until breached    
   datetime time1 = iTime(_Symbol,0,bar+2);            // start of box
   datetime time2 = iTime(_Symbol,0,bar-length);       // -1 bars until a breach of priceHigh or bar 0
   string objname = "FVG_"+string(Time[bar]);
   if(ObjectFind(objname)==0) ObjectDelete(objname);   // delete box and update
   if ( (Low[bar]-High[bar+2])/pipvalue > minimumpips) // filter out tiny boxes
   {
      ObjectCreate(objname,OBJ_RECTANGLE,0,time1, priceHigh, time2, priceLow);
      ObjectSet(objname,OBJPROP_COLOR,boxcolorUp);
      ObjectSet(objname,OBJPROP_BACK,True); // True=fillbox
   }
}

void DeleteObjects(int bars)
{
   for(int i=bars; i>=0; i--)
   {   
      datetime time1 = iTime(_Symbol,0,i+2);
      datetime time2 = iTime(_Symbol,0,i); 
      string objname = "FVG_"+string(Time[i]);
      if(ObjectFind(objname)==0) ObjectDelete(objname);
   }
}
