//KurlFX 2009.01.31
//+------------------------------------------------------------------+
//|	*** MTFPI-sub3 ***		SL-line based on stochastic cross		|
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2009,Kurl FX"//*rev.2/2/09
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green 
#property indicator_color2 OrangeRed

extern int K_Period = 5;
extern int D_Period = 3;
extern int Slowing=3;

double BS[];//StopLoss;Buy
double SS[];//StopLoss;Sell
double BG[];//sign;Buy/No 
double SG[];//sign;Sell/No
double Bx[];//price;at stochas up cross
double Sx[];//price;at stochas dn cross
double Sto[];//stochastic;main
double Sig[];//stochastic;signal
//+------------------------------------------------------------------+
//|  Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(8);
   SetIndexBuffer(0,BS);
   SetIndexBuffer(1,SS);
   SetIndexBuffer(2,BG);
   SetIndexBuffer(3,SG);
   SetIndexBuffer(4,Bx);
   SetIndexBuffer(5,Sx);
   SetIndexBuffer(6,Sto);
   SetIndexBuffer(7,Sig);
   SetIndexLabel(0,"BuySL");
   SetIndexLabel(1,"SellSL");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   static int Pos;//*must be static
   int counted_bar=IndicatorCounted();
   int limit=Bars-counted_bar;
   if(counted_bar==0)limit-=K_Period+D_Period+Slowing;
   for(int i=limit-1;i>=0;i--)
     {
      Sto[i]=iStochastic(NULL,0,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,i);
      Sig[i]=iStochastic(NULL,0,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,i);
     }
   if(counted_bar==0){limit-=50;BS[limit]=EMPTY_VALUE;SS[limit]=EMPTY_VALUE;}
   for(i=limit-1;i>=0;i--)
     {
      BS[i]=BS[i+1];SS[i]=SS[i+1];
      if(Sto[i+1]<=Sig[i+1] && Sto[i]>Sig[i])Pos=1;
      if(Sto[i+1]>=Sig[i+1] && Sto[i]<Sig[i])Pos=-1;
      if(Pos>0)
        {
         for(int j=2;j<=50;j++)
           {
            if(Sto[i+j+1]<=Sig[i+j+1] && Sto[i+j]>Sig[i+j]){Bx[i]=MathMin(Low[i+j+1],Low[i+j]);break;}
           }
        }
      else Bx[i]=Bx[i+1];
      if(Pos<0)
        {
         for(j=2;j<=50;j++)
           {
            if(Sto[i+j+1]>=Sig[i+j+1] && Sto[i+j]<Sig[i+j]){Sx[i]=MathMax(High[i+j+1],High[i+j]);break;}
           }
        }
      else Sx[i]=Sx[i+1];

      int bx=0;
      if(Close[i+1]<=Bx[i+1] && Close[i]>Bx[i])bx=1;
      else{if(Close[i+1]>=Bx[i+1] && Close[i]<Bx[i])bx=-1;}
      int sx=0;
      if(Close[i+1]<=Sx[i+1] && Close[i]>Sx[i])sx=1;
      else{if(Close[i+1]>=Sx[i+1] && Close[i]<Sx[i])sx=-1;}

      BG[i]=EMPTY_VALUE;SG[i]=EMPTY_VALUE;
      double sxh=MathMax(Low[i+1],Sx[i]);double sxl=MathMin(High[i+1],Sx[i]);
      double bxh=MathMax(Low[i+1],Bx[i]);double bxl=MathMin(High[i+1],Bx[i]);
      if(bx==1)
        {
         BG[i]=Close[i];
         BS[i]=bxh;
        }
      if(sx==1)
        {
         BS[i]=sxh;
         if(BS[i+1]==EMPTY_VALUE)BG[i]=Close[i];
        }
      if(sx==-1)
        {
         SG[i]=Close[i];
         SS[i]=sxl;
        }
      if(bx==-1)
        {
         if(SS[i+1]==EMPTY_VALUE)SG[i]=Close[i];
         SS[i]=bxl;
        }
      if(BG[i+1]!=EMPTY_VALUE&&SG[i]==EMPTY_VALUE)SS[i]=EMPTY_VALUE;
      if(SG[i+1]!=EMPTY_VALUE&&BG[i]==EMPTY_VALUE)BS[i]=EMPTY_VALUE;

      if(BS[i]!=EMPTY_VALUE){double d=MathMin(Low[i+2],Low[i+1]);BS[i]=MathMax(d,BS[i]);}
      if(SS[i]!=EMPTY_VALUE){d=MathMax(High[i+2],High[i+1]);SS[i]=MathMin(d,SS[i]);}
     }
   return(0);
  }
//+------------------------------------------------------------------+
