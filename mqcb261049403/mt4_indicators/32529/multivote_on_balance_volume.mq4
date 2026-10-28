//+------------------------------------------------------------------+
//|                         Normal & MultiVote On_Balance_Volume.mq4 |
//+------------------------------------------------------------------+
#property description "Code by Max Michael 2020"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
#property strict
//---- input parameters
extern bool    MultiVoteON = True;
//---- buffers
double OBV[];

int init()
{
   SetIndexBuffer(0,OBV);
   SetIndexStyle(0,DRAW_LINE);
   IndicatorDigits(0);     
   IndicatorShortName("OBV");
   SetIndexLabel(0,"OBV");
   return(0);
}

int deinit() { return(0); }

int start()
{
   int CountedBars=IndicatorCounted();
    if(CountedBars<0) return(-1);
   int Limit=Bars-CountedBars-1;
   int sum;
   
   for(int i=Limit; i>=0; i--)
   {
      if(i==Bars-1) OBV[i]=Volume[i];
      else
      {  
        sum=0;
        if (MultiVoteON)
        {
          if( High[i] > High[i+1])  ++sum; else --sum;
          if( Close[i]> Close[i+1]) ++sum; else --sum;
          if( Low[i]  > Low[i+1])   ++sum; else --sum;
        }
        else if( Close[i]> Close[i+1]) ++sum; else --sum;
        OBV[i]=OBV[i+1] + sum * Volume[i];
     }
   }
   return(0);
}
