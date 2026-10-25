//+------------------------------------------------------------------+
//|                                  Gaussian_Filter_Multi_Pole+.mq4 |
//+------------------------------------------------------------------+
#property description "Code by Max Michael 2023"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DeepSkyBlue
#property indicator_color2 OrangeRed
#property indicator_color3 OrangeRed
#property strict

enum PoleMode
{
  a=1, // one pole
  b=2, // two poles
  c=3, // three poles
  d=4, // four poles
};

//---- input parameters
extern int                  length = 14;
input  PoleMode              poles = 2; 
extern ENUM_APPLIED_PRICE    price = PRICE_CLOSE;
extern int              SMA_smooth = 1;
extern bool           Use_J_filter = false;
extern double             J_smooth = 0.55;
extern int                 maxbars = 500;

double alpha;

double buffer[];
double buffer1[];
double buffer2[];

int init()
{
   SetIndexBuffer(0,buffer);  SetIndexStyle(0,DRAW_LINE); SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexBuffer(1,buffer1); SetIndexStyle(1,DRAW_LINE); SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexBuffer(2,buffer2); SetIndexStyle(2,DRAW_LINE); SetIndexEmptyValue(2,EMPTY_VALUE);
   IndicatorDigits(Digits);
   if(SMA_smooth<1) SMA_smooth=1; // < 2 no smoothing 
   if(maxbars > Bars-1) maxbars=Bars-1;
   double alpha2;
   if(Use_J_filter) // JMA like filter
   {
      alpha = 0.45*(length-1.) / (0.45*(length-1)+2);
      alpha = alpha*alpha;
      alpha2= (1-alpha)*(1-alpha);
      alpha = (alpha2 + alpha)*J_smooth;
   }
   else // standard gaussian filter: updated with poles component
   {   
     double  beta = (1.0-MathCos(2.0* M_PI/length)) / (MathPow(MathSqrt(2.0),2.0/poles)-1.0);
            alpha = -beta + MathSqrt(beta*beta + 2.0*beta);
   }
   return(0);
}

int deinit() { return(0); }

int start()
{
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=fmin(Bars-counted_bars,maxbars);

   for (int i=limit; i>=0; i--)
   {
      if(i>maxbars-5) buffer[i]=Close[i]; //initialize data
      else
      {
         double price_= iMA(NULL,0,SMA_smooth,0,MODE_SMA,price,i); //SMA_smooth=1 no SMA smoothing
         switch(poles)
         {  //   1 to 4 pole smoothers
            case 1: buffer[i]= alpha * price_ + (1-alpha) * buffer[i+1]; break;
            case 2: buffer[i]= MathPow(alpha,2)*price_ + 2*(1-alpha)*buffer[i+1] - MathPow(1-alpha,2)*buffer[i+2]; break;
            case 3: buffer[i]= MathPow(alpha,3)*price_ + 3*(1-alpha)*buffer[i+1] - 3*MathPow(1-alpha,2)*buffer[i+2] + MathPow(1-alpha,3)*buffer[i+3]; break; 
            case 4: buffer[i]= MathPow(alpha,4)*price_ + 4*(1-alpha)*buffer[i+1] - 6*MathPow(1-alpha,2)*buffer[i+2] + 4*MathPow(1-alpha,3)*buffer[i+3] - MathPow(1-alpha,4)*buffer[i+4]; break; 
         }
      }
      if(buffer[i] < buffer[i+1]) ColorPlot(i,buffer1, buffer2, buffer);
      else  buffer1[i]=buffer2[i]=EMPTY_VALUE;   
   }
   return(0);
}

void ColorPlot(int i, double& first[], double& second[], double& source[])
{
   if (i>=Bars-3) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i] =source[i]; first[i+1] =source[i+1]; second[i]= EMPTY_VALUE; }
      else  { second[i]=source[i]; second[i+1]=source[i+1]; first[i] = EMPTY_VALUE; }
   else     { first[i] =source[i];                         second[i] = EMPTY_VALUE; }
}
