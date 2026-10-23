//+----------------------------------------------------------+
//|                                full formula RSI duel.mq4 |
//+----------------------------------------------------------+
#property description "Code by Max Michael 2020"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Blue
#property strict
// inputs
extern int        Length = 50;
extern bool   RSI_normal = true;    
extern bool   RSI_cutler = true;
extern int  NumberOfBars = 1000;
// buffers
double Rsi[];
double cRsi[];

int    Wlength;
double Alpha;

int init()
{
   IndicatorShortName("RSI duel ("+IntegerToString(Length) +") ");
   IndicatorDigits(Digits-1);
   SetIndexBuffer(0,Rsi);
   if (RSI_normal){ SetIndexStyle(0,DRAW_LINE); SetIndexLabel(0,"Normal RSI"); }
   else           { SetIndexStyle(0,DRAW_NONE); SetIndexLabel(0,""); }
   SetIndexBuffer(1,cRsi);
   if (RSI_cutler) { SetIndexStyle(1,DRAW_LINE); SetIndexLabel(1,"Cutler"); }
   else            { SetIndexStyle(1,DRAW_NONE); SetIndexLabel(1,""); }
   Wlength=Length*2-1;     // Wilders smoothing function
   Alpha= 2.0/(1+Wlength); // EMA factor
   NumberOfBars=MathMin(Bars,NumberOfBars);
   return(0);
}

int deinit() { return(0); }

int start()
{
   int CountedBars=IndicatorCounted();
   if (CountedBars<0) return(-1);
   int limit = Bars-CountedBars-1;
   if (limit > NumberOfBars) limit=NumberOfBars;
   double Su, Sd, Su2, Sd2, Sup, Sdn;

   int i=limit;
   while(i>=0)
   {
      if (i==limit && i>1) { Su2=0.0001; Sd2=0.0001; }      //initialize EMA's
      Su=(Close[i]-Close[i+1]>0) ? Close[i]-Close[i+1] : 0; //difference up
      Sd=(Close[i]-Close[i+1]<0) ? Close[i+1]-Close[i] : 0; //difference down
      // Standard RSI uses Exponential Moving Average
      Sup=(Su-Su2)* Alpha + Su2; Su2=Sup; 
      Sdn=(Sd-Sd2)* Alpha + Sd2; Sd2=Sdn;
      Rsi[i]=100-100/(1 + Sup/Sdn);
      
      // Cutler RSI uses Simple Moving Average
      Sup=0; Sdn=0; int x;
      for(x=0; x<Length; x++) { Su=(Close[x+i]-Close[x+i+1]>0) ? Close[x+i]-Close[x+i+1] : 0; Sup += Su; } Sup /=(Length);
      for(x=0; x<Length; x++) { Sd=(Close[x+i]-Close[x+i+1]<0) ? Close[x+i+1]-Close[x+i] : 0; Sdn += Sd; } Sdn /=(Length);
      cRsi[i]=100-100/(1 + Sup/Sdn);
      i--;
   }
   return(0);
}
