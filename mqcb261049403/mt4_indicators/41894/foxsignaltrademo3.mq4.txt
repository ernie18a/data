//+---------------------------------------------------------------------+
//|                                               FOXSignal-TradeMo3.mq4|
//| For more EXPERTS, INDICATORS, TRAILING EAs and SUPPORT Please visit:|
//|                                         http://www.foxzard.com      |
//|           Our forum is at:   http://forex-forum.landofcash.net      |
//+---------------------------------------------------------------------+
#property strict
#property copyright "Foxzard.com TradeMo3"
#property link      "http://www.foxzard.com "

#property indicator_chart_window
#property indicator_buffers 3
//Buy signal
#property indicator_color1 OrangeRed 
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID
//Sell signal
#property indicator_color2 OrangeRed
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID
//Lot size
#property indicator_color3 CLR_NONE
#property indicator_width3 0
//Conditions
//


string _name = "FOXSignal TradeMo3";
string _ver="v2.2";
bool _enableAlert=true;
//---------------------------------------------


//lot size is constant
double _lotSizeDefault=0;
//---------------------------------------------
double _buySignal[];
double _sellSignal[];
double _lotSize[];

//


double _pipsMultiplyer=1;


int init()
{
   Print(_name+" - " + _ver);
   IndicatorShortName(_name+" - " + _ver);
   Comment(_name+" " + _ver+" @ "+"http://www.foxzard.com");  
  _lotSizeDefault=MarketInfo(Symbol(),MODE_MINLOT);  
//init buffers
   IndicatorBuffers(3);    
   SetIndexBuffer(0,_buySignal);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexLabel(0,"Buy");
   SetIndexArrow(0,233);
      
   SetIndexBuffer(1,_sellSignal);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexLabel(1,"Sell");
   SetIndexArrow(1,234);

   SetIndexBuffer(2,_lotSize);   
   SetIndexStyle(2,DRAW_NONE);
   SetIndexLabel(2,"Lot");
   
   //conditions
   
   
   //get pip value
   if(Digits == 2 || Digits == 4) {
      _pipsMultiplyer = 1;
   } else {
      if(Digits == 3 || Digits == 5) {
         _pipsMultiplyer = 10;
      }
   }
   return(0);
}

int deinit()
{
   return(0);
}
//conditions
//cross
bool IsCrossUp(double lineX0, double lineX1, double lineY0, double lineY1){
   if(lineX1<lineY1 && lineX0>lineY0){
      return (true);
   }
   return (false);
}
bool IsCrossDown(double lineX0, double lineX1, double lineY0, double lineY1){
   if(lineX1>lineY1 && lineX0<lineY0){
      return (true);
   }
   return (false);
}
//Direction
bool IsPointingUp(double lineX0, double lineX1){
   if(lineX1<lineX0){
      return (true);
   }
   return (false);
}
bool IsPointingDown(double lineX0, double lineX1){
   if(lineX1>lineX0){
      return (true);
   }
   return (false);
}
//level
bool IsAbove(double lineX0, double lineY0){
   if(lineX0>lineY0){
      return (true);
   }
   return (false);
}
bool IsBelow(double lineX0, double lineY0){
   if(lineX0<lineY0){
      return (true);
   }
   return (false);
}
//extremum
bool IsMaximum(double lineX0, double lineX1, double lineX2){
   if(lineX0<lineX1 && lineX1>lineX2){
      return (true);
   }
   return (false);
}
bool IsMinimum(double lineX0, double lineX1, double lineX2){
   if(lineX0>lineX1 && lineX1<lineX2){
      return (true);
   }
   return (false);
}

bool IsBuySignal(int i){
   bool result=true;
   int met=0;
   double pipAdd=200*Point;
   //buy conditions
if(!Condition1(i)){
    result=false; //Condition1
}

   return (result);
}
bool IsSellSignal(int i){
   bool result=true;
   int met=0;
   double pipAdd=200*Point;
   //sell conditions
if(!Condition2(i)){
    result=false; //Condition2
}
 
   return (result);  
}

int start()
{
   double visualAddition= 3*_pipsMultiplyer*Point;
   int    counted_bars=IndicatorCounted();
   if(Bars<=100) {return(0);}
   int i=Bars-counted_bars-1;
   while(i>=0)
   {
      _buySignal[i]=EMPTY_VALUE;
      _sellSignal[i]=EMPTY_VALUE;
      _lotSize[i]=_lotSizeDefault;
      if(IsBuySignal(i)){
         _buySignal[i]=iLow(Symbol(),Period(),i)-visualAddition;
         if(_enableAlert){
            if(i==1){
               Alert("BUY "+Symbol()+" "+IntegerToString(Period(),2,' ')+_name);
            }
         }
      }
      if(IsSellSignal(i)){
         _sellSignal[i]=iHigh(Symbol(),Period(),i)+visualAddition;
         if(_enableAlert){
            if(i==1){
               Alert("SELL "+Symbol()+" "+IntegerToString(Period(),2,' ')+_name);
            }
         }
      }         
      i--;
   }
   return(0);
}


   //Conditions
bool Condition1(int i){
    bool result;
    double lineX0 = iMA(Symbol(),Period(),8,0,3,0,i+0);
    double lineX1 = iMA(Symbol(),Period(),8,0,3,0,i+1);
    double lineY0 = iMA(Symbol(),Period(),10,0,3,1,i+0);
    double lineY1 = iMA(Symbol(),Period(),10,0,3,1,i+1);
    result = IsCrossUp(lineX0,lineX1,lineY0,lineY1);
    return (result);

}
bool Condition2(int i){
    bool result;
    double lineX0 = iMA(Symbol(),Period(),8,0,3,0,i+0);
    double lineX1 = iMA(Symbol(),Period(),8,0,3,0,i+1);
    double lineY0 = iMA(Symbol(),Period(),10,0,3,1,i+0);
    double lineY1 = iMA(Symbol(),Period(),10,0,3,1,i+1);
    result = IsCrossDown(lineX0,lineX1,lineY0,lineY1);
    return (result);

}

