//+----------------------------------------------------------------------------+
//|                                                               ADX_real.mq4 |
//| This ADX version is used on many other popular trading platforms.          |
//| It is different to the standard one included with Metatrader.              |
//+----------------------------------------------------------------------------+
#property description "Code by Max Michael 2022"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_levelcolor DimGray
#property indicator_levelstyle 0
#property strict

//---- input parameters
extern int    Length = 10;
extern int    Smooth = 10;
extern double  Level = 20.0;
extern int   MaxBars = 500;

double PrePos, PreNeg, PreTR, PreADX;

double ADXbuffer[];
double PlusBuffer[];
double MinusBuffer[];

int init()
{
   SetIndexBuffer(0,ADXbuffer);  SetIndexStyle(0,DRAW_LINE); SetIndexLabel(0,"ADX");
   SetIndexBuffer(1,PlusBuffer); SetIndexStyle(1,DRAW_LINE); SetIndexLabel(1,"+DI");
   SetIndexBuffer(2,MinusBuffer);SetIndexStyle(2,DRAW_LINE); SetIndexLabel(2,"-DI");
   IndicatorShortName("ADX("+string(Length)+","+string(Smooth)+")");
   SetLevelValue(0,Level);
   IndicatorDigits(2);
   return(0);
}

int start()
{
   if(Bars <= Length) return(0);
   int CountedBars=IndicatorCounted();
   if (CountedBars<0) return(-1);
   int limit = Bars-CountedBars-1;
   if (limit > MaxBars) limit=MathMin(MaxBars,Bars-1);
   double diff=0; 
   
   for (int i=limit; i>=0; i--)
   {      
      if(High[i]>High[i+1] && (High[i]-High[i+1])>(Low[i+1]-Low[i])) { diff=High[i]-High[i+1]; }
      else { diff=0.0; }
      double Pos=(((Length-1.0)*PrePos)+diff)/(Length);
      
      if(Low[i]<Low[i+1] && (Low[i+1]-Low[i])>(High[i]-High[i+1]))  { diff=Low[i+1]-Low[i]; }
      else { diff=0.0; }
      double Neg=(((Length-1.0)*PreNeg)+diff)/(Length);
      
      double Buff=MathAbs(Pos-Neg), ADX; 
      if (Buff==0) { ADX=(((Smooth-1.0)*PreADX))/Smooth; }
      else         { ADX=(((Smooth-1.0)*PreADX)+(MathAbs(Pos-Neg)/(Pos+Neg)))/Smooth; }
      
      if(i>0) { PreNeg=Neg; PrePos=Pos; PreADX=ADX; }
      double tr=(((Length-1.0)*PreTR)+Close[i])/Length;
      PreTR=tr;
      PlusBuffer[i] =100000*(Pos/tr);
      MinusBuffer[i]=100000*(Neg/tr);
      ADXbuffer[i]  =100*ADX;
   }
   return(0);
}
