//+------------------------------------------------------------------+
//|                                                     iMovment.mq5 |
//|                                              Copyright dmffx.com |
//|                                                 http://dmffx.com |
//+------------------------------------------------------------------+
#property copyright "dmffx.com"
#property link      "http://dmffx.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   1

#property indicator_label1  "Open;High;Low;Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  CLR_NONE

// Величина движения цены в пунктах считающееся сменой направления тренда
input int      Movment     =  70;         
// Цвет движения вверх
input color    UpColor     =  Blue;
// Цвет откатов на движении вверх       
input color    UpBackColor =  White;  
// Цвет движения вниз    
input color    DnColor     =  Red;  
// Цвет откатов на движении вниз      
input color    DnBackColor =  White; 
// Автоматически умножать параметр Movment на 10 при работе на 5-ти и 3-ех знаковых котировках
input bool     Auto5Digits =  true;       

double         BOpen[];
double         BHigh[];
double         BLow[];
double         BClose[];
double         BColor[];
double         BTrend[];
double         BMin[];
double         BMax[];

int Grad=10;
color Colors[];
double Movment2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){

   Movment2=Movment;

      if(Auto5Digits){
         if(_Digits==5 || _Digits==3){
            Movment2*=10;
         }
      }

   SetIndexBuffer(0,BOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BLow,INDICATOR_DATA);
   SetIndexBuffer(3,BClose,INDICATOR_DATA);
   SetIndexBuffer(4,BColor,INDICATOR_COLOR_INDEX);
   
   SetIndexBuffer(5,BTrend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BMin,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BMax,INDICATOR_CALCULATIONS);   
   
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
   
   ArrayResize(Colors,Grad*2);
   color Col1=color(PlotIndexGetInteger(0,PLOT_LINE_COLOR,0));
   color Col2=color(PlotIndexGetInteger(0,PLOT_LINE_COLOR,1));
   
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,Grad*2);
   
      for(int i=0;i<Grad;i++){
         Colors[i]=GetColor(1.0*i/(Grad-1),DnColor,DnBackColor);
         Colors[i+Grad]=GetColor(1.0*i/(Grad-1),UpColor,UpBackColor);         
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,i,Colors[i]);
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,i+Grad,Colors[i+Grad]);         
      }
      
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
  
   int limit;
      if(prev_calculated>0)
      {
         limit=prev_calculated-1;
      }
      else
      {
         limit=1;
      } 
      for(int i=limit;i<rates_total;i++)
      {
         BOpen[i]=open[i];
         BHigh[i]=high[i];         
         BLow[i]=low[i];
         BClose[i]=close[i];
         BTrend[i]=BTrend[i-1];
         BMax[i]=BMax[i-1];
         BMin[i]=BMin[i-1];         
         int ColInd=0;
            switch((int)BTrend[i])
            {
               case 1:
                     if(close[i]>BMax[i])
                     {
                        BMax[i]=close[i];
                     }
                  ColInd=(int)MathCeil(10.0*(BMax[i]-close[i])/(_Point*Movment2));
                     if(ColInd>=Grad)
                     {
                        BTrend[i]=-1;
                        BMin[i]=close[i];
                        ColInd=0;
                     } 
                     else
                     {
                        ColInd+=Grad;    
                     }
               break;
               case 0:
                  BOpen[i]=0;
                  BHigh[i]=0;
                  BLow[i]=0;
                  BClose[i]=0;
                     if(close[i]>BMax[i])
                     {
                        BMax[i]=close[i];
                     } 
                     if(close[i]<BMin[i])
                     {
                        BMin[i]=close[i];
                     }  
                     if(close[i]<=BMax[i]-_Point*Movment2)
                     {
                        BTrend[i]=-1;
                        BMin[i]=close[i];
                     }
                     if(close[i]>=BMin[i]+_Point*Movment2)
                     {
                        BTrend[i]=1;
                        BMax[i]=close[i];
                     } 
               break;
               case -1:
                     if(close[i]<BMin[i])
                     {
                        BMin[i]=close[i];
                     }
                  ColInd=(int)MathCeil(10.0*(close[i]-BMin[i])/(_Point*Movment2));
                     if(ColInd>=Grad)
                     {
                        BTrend[i]=1;
                        BMax[i]=close[i];
                        ColInd=Grad;
                     }  
               break;
            }
         BColor[i]=ColInd;
      }    
   return(rates_total);
  }
//+------------------------------------------------------------------+

color GetColor(double aK,int Col1,double Col2)
{
   int R1,G1,B1,R2,G2,B2;
   fGetRGB(R1,G1,B1,int(Col1));
   fGetRGB(R2,G2,B2,int(Col2));  
   return(fRGB(int(R1+aK*(R2-R1)),int(G1+aK*(G2-G1)),int(B1+aK*(B2-B1))));
}  
  
void fGetRGB(int & aR,int & aG,int & aB,int aCol)
{
   aB=aCol/65536;
   aCol-=aB*65536;
   aG=aCol/256;
   aCol-=aG*256;
   aR=aCol;
}  

color fRGB(int aR,int aG, int aB)
{
   return(color(aR+256*aG+65536*aB));
}