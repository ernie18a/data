//+------------------------------------------------------------------+
//|                                              Theil Sen Slope.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

#include <BreakPoint.mqh>//you can comment this out 
#property indicator_chart_window

//---- indicator parameters
int sub_window=0,width=2,int_MarketPhase=0,int_Tendency=0;
input string aCurrentSymbol="";
input int aChart=0;
input int RegLin_Period=20;
input string Applied_Price_Dataset="ema_close";//close,open,high,low,ema_close,sma_close
extern string Result_MarketPhase="";
extern string Result_Tendency="";
extern double Result_Slope=0;
extern string aTrendline_NickName="your_line_nickname_here";
input bool DisplayText=true;
input int Shift=1;//the bar where the last anchor point should drawn to.
string obj_name = "theil-sen_"+aTrendline_NickName,allresult;
int    chart_id = 0;


datetime time1=0,time2=0;
double price1=0,price2=0,slope=-1,y_intercept=2;
//----


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
 
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Median values                                                    |
//+------------------------------------------------------------------+

void TheilSen(double& m, double& b, double& v[], int n1, int iBeg=0){
   double slopes[];
   int nReq = n1 * (n1-1) / 2;
   int i=0,j=0;
   if(ArraySize(slopes) < nReq) if(ArrayResize(slopes, nReq) <= 0){
      Print("ArrayResize(TheilSen, " + IntegerToString(nReq) + ") Failed: "
                                                +IntegerToString(GetLastError()) );   return;  }                                           
   int   nSlopes = 0;
   for( i=iBeg + n1 - 1; i >  iBeg; i--)
      for ( j=i - 1;     j >= iBeg; j--){
         slopes[nSlopes] = (v[i] - v[j]) / (i-j);   nSlopes++;    
  }           
   m = Median(slopes, nSlopes);

 i=0;
   for(i=0; i < n1; i++)   slopes[i] = v[iBeg+i] - m * i;
   b = Median(slopes, n1);
   
}



double   Median(double& values[], int iLimit, int iBeg=0)
   {
   int      iLeft = iBeg,  nValues = iLimit-iBeg,  iMed = iBeg + nValues / 2;
   double   med   = NthElement(values, iLeft, iMed, iLimit);
   if (nValues % 2 == 1)   return(med);                  
   iLimit = iMed;    iMed--;                              
   if(iLeft == iMed){   med += values[iMed];              
                        return( med * 0.5 );                                  }
   if(iLeft > iMed)     iLeft = iBeg;                     
   med += NthElement(values, iLeft, iMed, iLimit);       
   return( med * 0.5 );
   }
   
   
#define ASCENDING    +1
#define DESCENDING   -1


double   NthElement(double&values[], int&iLB, int iNth, int&iRL, double asc=+1)
   {
   while(true)
      {    
      int      iRight = iRL - 1;                             
      if(iLB >= iNth && iRight <= iNth)   return( values[iNth] );
      int      iPivot   = (iLB+iRight) / 2;                        
      if((values[iLB]  - values[iRight])*asc > 0)
                                 SwapAD(values, iLB,  iRight);     
      if((values[iLB]  - values[iPivot])*asc > 0)
                                 SwapAD(values, iLB,  iPivot);     
      if((values[iPivot] - values[iRight])*asc > 0)
                                 SwapAD(values, iPivot, iRight);   
      double   vPivot   = values[iPivot];  
      values[iPivot]    = values[iRight];  


      int iStore = 0;
      double vStore = 0;
      for( iStore=iLB; iStore < iRight; iStore++)
         {
          vStore = values[iStore];  if((vStore-vPivot)*asc > 0.)  break; 
         }


      for(int iTest=iStore+1; iTest < iRight; iTest++)
         {
         double   vTest = values[iTest];  
         if((vTest - vPivot)*asc < 0.)
            {
            values[iStore] = vTest;                    
            values[iTest]  = vStore;                  
            iStore++;      vStore = values[iStore];    
            }  
         }
      values[iRight] = vStore;                         
      values[iStore] = vPivot;                         

      if(      iStore < iNth) iLB = iStore + 1;
      else  if(iStore > iNth) iRL = iStore;
      else                    return( values[iNth] );
      }   
      
    
   }   



void     SwapAD(double& arr[], int iA, int iB)
   {
   double   T = arr[iA];   arr[iA] = arr[iB];   arr[iB] = T;                  
   }


//+------------------------------------------------------------------+
//| Start Function                                                   |
//+------------------------------------------------------------------+
int start()
{           
  double close[],applied_prices_arr[],data=0,dslope=0,max_ranging_value=0.0006,max_neutral_val=0.0001;
  int arrsz=iBars(aCurrentSymbol,aChart)-Shift; 
     if(IsTesting()==true)arrsz = Bars; 
  int c=0, lastpos=0,precision=4;
  ArrayResize(applied_prices_arr,arrsz);
  c=arrsz; 
   while(c>=Shift && arrsz>RegLin_Period && Shift>=0 )
   {   
       if(Applied_Price_Dataset == "close")data=iClose(aCurrentSymbol,aChart,c);//close
       if(Applied_Price_Dataset == "open")data=iOpen(aCurrentSymbol,aChart,c);//open
       if(Applied_Price_Dataset == "high")data=iHigh(aCurrentSymbol,aChart,c);//high
       if(Applied_Price_Dataset == "low")data=iLow(aCurrentSymbol,aChart,c);//low
       if(Applied_Price_Dataset == "sma_close")data=iMA(aCurrentSymbol,aChart,RegLin_Period,0,MODE_SMA,PRICE_CLOSE,c);//sma close
       if(Applied_Price_Dataset == "ema_close")data=iMA(aCurrentSymbol,aChart,RegLin_Period,0,MODE_EMA,PRICE_CLOSE,c);//ema close          
    c--;
       if(c>=0)applied_prices_arr[c]=data;      
   } 
   
   if( (Applied_Price_Dataset == "close" || Applied_Price_Dataset == "open" || Applied_Price_Dataset == "high" || Applied_Price_Dataset == "low" || Applied_Price_Dataset == "sma_close" || Applied_Price_Dataset == "ema_close") && arrsz>0)
   {
       if(arrsz>RegLin_Period)TheilSen(slope, y_intercept, applied_prices_arr, RegLin_Period, lastpos);
       else
       { 
        Print("Insufficient bars: only "+IntegerToString(arrsz)+" bars are available but "+IntegerToString(RegLin_Period)+" bars are required. Please waite...");
        return(0);
       } 
   }
   else
   {
    Print("You did not specify a valid data set. You can specify it by setting 'Applied_Price_Dataset' to 'close','open',...");
    return(0);
   }      
          
//--- create a trend line using 2 points 
   time1=iTime(aCurrentSymbol,aChart,RegLin_Period);time2=iTime(aCurrentSymbol,aChart,Shift);
      if(Applied_Price_Dataset == "close")price1=iClose(aCurrentSymbol,aChart,RegLin_Period);
      else if(Applied_Price_Dataset == "open")price1=iOpen(aCurrentSymbol,aChart,RegLin_Period);
      else if(Applied_Price_Dataset == "high")price1=iHigh(aCurrentSymbol,aChart,RegLin_Period);
      else if(Applied_Price_Dataset == "low")price1=iLow(aCurrentSymbol,aChart,RegLin_Period);
      else if(Applied_Price_Dataset == "sma_close")price1=iMA(aCurrentSymbol,aChart,RegLin_Period,0,MODE_SMA,PRICE_CLOSE,RegLin_Period);
      else if(Applied_Price_Dataset == "ema_close")price1=iMA(aCurrentSymbol,aChart,RegLin_Period,0,MODE_EMA,PRICE_CLOSE,RegLin_Period);
   price1 = NormalizeDouble(price1,precision);
   price2=0;  
      
  //calculate price2
  price2 = ( (slope * RegLin_Period) - price1 ) / -1; 
  price2 = NormalizeDouble(price2,precision);    
   
  //ObjectsDeleteAll ();// Delete all objects
  ObjectDelete(chart_id,obj_name);//Delete objects by name
     if(DisplayText==true)
     {
        if(!ObjectCreate(chart_id,obj_name,OBJ_TREND,sub_window,time1,price1,time2,price2))//display on the chart directly
         { 
         Print(__FUNCTION__,": failed to create a trend line! Error code = ",GetLastError()); 
         return(false); 
        }  
     } 
dslope=slope * -1;//we do this to orient it towards upcoming price
dslope = NormalizeDouble(dslope,precision);

   //now let's do the interpreation of slope
   if(dslope<max_ranging_value && dslope>-max_ranging_value){Result_MarketPhase = "ranging";int_MarketPhase = 2;}
   else if(dslope>max_ranging_value || dslope<-max_ranging_value){Result_MarketPhase = "trending";int_MarketPhase = 1;}
   
   if(dslope<0){Result_Tendency = "bearish";int_Tendency = 2;}
   else if(dslope >-max_neutral_val && dslope < max_neutral_val){Result_Tendency = "neutral"; int_Tendency = 3;}
   else if(dslope > 0){Result_Tendency = "bullish"; int_Tendency = 1;}
 Result_Slope = dslope; 
 
 if(int_Tendency == 2 && int_MarketPhase == 1)ObjectSetInteger(chart_id,obj_name,OBJPROP_COLOR,clrRed);
 else if(int_Tendency == 1 && int_MarketPhase == 1)ObjectSetInteger(chart_id,obj_name,OBJPROP_COLOR,clrAqua);
 else if(int_Tendency == 3)ObjectSetInteger(chart_id,obj_name,OBJPROP_COLOR,clrGold);
 else ObjectSetInteger(chart_id,obj_name,OBJPROP_COLOR,clrSaddleBrown);

 GlobalVariableSet("tGlobalMarketPhase",int_MarketPhase);
 GlobalVariableSet("tGlobalTendency",int_Tendency);
 GlobalVariableSet("tGlobalSlope",dslope);
 
    if(DisplayText==true)
    {
     Comment("Linear Regression Slope("+IntegerToString(RegLin_Period)+") = "+DoubleToStr(Result_Slope,4)+"\nMarketCondition = "+Result_MarketPhase+"\nTendency = "+Result_Tendency );      
     ObjectSetInteger(chart_id,obj_name,OBJPROP_WIDTH,width);//--- set line width       
     ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTABLE,true);//make line selectable 
     ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTED,true);  
     ObjectSetInteger(chart_id,obj_name,OBJPROP_RAY_RIGHT,false);//--- enable (true) or disable (false) the mode of continuation of the line's display to the right 
    } 
 return(0);     
}
