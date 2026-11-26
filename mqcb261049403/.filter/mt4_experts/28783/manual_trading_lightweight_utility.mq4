//+------------------------------------------------------------------+
//|                           Manual Trading Lightweight Utility.mq4 |
//|                                              by Fabrizio Ranieri |
//|                                         https://www.ipposnif.com |
//+------------------------------------------------------------------+

#include <stdlib.mqh>
#property strict
#property copyright     "Fabrizio Ranieri"
#property link          "https://www.ipposnif.com"
#property version       "1.00"
#property description   "The left button changes the order type: E=Market Execution  L-Pending Limit  S=Pending Stop."
#property description   "The Pending Limit order is placed at the market price plus LimitOrderPoints."
#property description   "The Pending Stop order is placed at the market price plus StopOrderPoints."
#property description   "TakeProfitPoints and StopLossPoints specify the Stop Loss and Take profit for every order. 0=Off."
#property description   "The header shows the symbol, the maximum eventual loss and the maximum eventual return for the current market."
#property description   "Press L to show the Lot Control."
//#property icon "C:\\Projects\\mql4\\dao04.png"

extern double        LotSize=1;
extern bool          LotControl = false;
extern double        LotVolumeStep=0.1;
extern int           TakeProfitPoints=400;
extern int           StopLossPoints=200;
extern int           LimitOrderPoints=50;
extern int           StopOrderPoints=50;
extern int           PriceStep=10;
extern color         SellColor=8421631;
extern color         BuyColor=16760992;
extern string        comment="Manual Trading";
extern int           magicNumber=0;

string orderType[2]={"Sell","Buy"};
double LimitOrderAmount, TakeProfitAmount, StopLossAmount, StopOrderAmount;
color back=(color)ChartGetInteger(0, CHART_COLOR_BACKGROUND, 0);
color fore=(color)ChartGetInteger(0, CHART_COLOR_FOREGROUND, 0);
int x, y, mm, xc, yc, isDragging;
int framePosition= CORNER_LEFT_UPPER; 
int framex=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)-350;
int framey=60;
string currentOrderType[2]={"E","E"};
string currenTrail[2]={"M","M"};
string currenPrice[2]={"0","0"};
double currentLot[2]={-1,-1};
double StoplevelAmount = (int)MarketInfo("0",MODE_STOPLEVEL)/pow(10, Digits);
double marketLotStep = MarketInfo("0",MODE_LOTSTEP);
double marketMinLot = MarketInfo("0",MODE_MINLOT);
double marketMaxLot = MarketInfo("0",MODE_MAXLOT);

int OnInit() {
   
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);
   ChartSetInteger(0,CHART_EVENT_OBJECT_DELETE,1);
   ChartSetInteger(0,CHART_FOREGROUND,0);
   if (LotVolumeStep<marketLotStep){
      LotVolumeStep=marketLotStep;
   }
   if (LotSize<marketMinLot){
      LotSize=marketMinLot;
   }   
   if (LotSize>marketMaxLot){
      LotSize=marketMaxLot;
   }      
   LimitOrderAmount = LimitOrderPoints/pow(10, Digits);
   StopOrderAmount = StopOrderPoints/pow(10, Digits);
   TakeProfitAmount = TakeProfitPoints/pow(10, Digits);
   StopLossAmount = StopLossPoints/pow(10, Digits);
   if (StoplevelAmount > LimitOrderAmount){
      LimitOrderAmount = StoplevelAmount;
   }
   if (StoplevelAmount > StopOrderAmount){
      StopOrderAmount = StoplevelAmount;
   }   
   if ((StoplevelAmount) > TakeProfitAmount){
      TakeProfitAmount = (StoplevelAmount);
   }
   if ((StoplevelAmount) > StopLossAmount){
      StopLossAmount = (StoplevelAmount);
   }
   x=framex;
   y=framey; 
      
      
   ObjectCreate(0,"top",OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(0, "top", OBJPROP_CORNER, framePosition);
   ObjectSetInteger(0,"top",OBJPROP_BGCOLOR,back);
   ObjectSetInteger(0,"top",OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,"top",OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,"top",OBJPROP_XSIZE,198+((LotControl==true) ? 78 : 0));
   ObjectSetInteger(0,"top",OBJPROP_YSIZE,15);
   ObjectSetInteger(0,"top",OBJPROP_ZORDER,1);
   ObjectSetInteger(0,"top",OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,"top",OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,"top",OBJPROP_SELECTED,true);   
   
   ObjectCreate(0,"ordersLbl" ,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0, "ordersLbl", OBJPROP_CORNER, framePosition);
   ObjectSetText("ordersLbl", "",8,"Tahoma",fore);
   ObjectSetInteger(0,"ordersLbl",OBJPROP_XDISTANCE,x+4);
   ObjectSetInteger(0,"ordersLbl",OBJPROP_YDISTANCE,y+2);
   ObjectSetInteger(0,"ordersLbl",OBJPROP_XSIZE,50);
   ObjectSetInteger(0,"ordersLbl",OBJPROP_YSIZE,16);   
   ObjectSetInteger(0,"ordersLbl" ,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"ordersLbl" ,OBJPROP_HIDDEN,true);
   
   ObjectCreate(0,"closeLbl" ,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0, "closeLbl", OBJPROP_CORNER, framePosition);
   ObjectSetText("closeLbl", "x",10,"Tahoma",fore);
   ObjectSetInteger(0,"closeLbl",OBJPROP_XDISTANCE,x+187+((LotControl==true) ? 78 : 0));
   ObjectSetInteger(0,"closeLbl",OBJPROP_YDISTANCE,y-2);
   ObjectSetInteger(0,"closeLbl",OBJPROP_XSIZE,5);
   ObjectSetInteger(0,"closeLbl",OBJPROP_YSIZE,16);   
   ObjectSetInteger(0,"closeLbl" ,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"closeLbl" ,OBJPROP_HIDDEN,true);
   
    
   y=y+14;
   ObjectCreate(0,"frame",OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(0, "frame", OBJPROP_CORNER, framePosition);
   ObjectSetInteger(0,"frame",OBJPROP_BGCOLOR,back);
   ObjectSetInteger(0,"frame",OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,"frame",OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,"frame",OBJPROP_XSIZE,198+((LotControl==true) ? 78 : 0));
   ObjectSetInteger(0,"frame",OBJPROP_YSIZE,83);
   ObjectSetInteger(0,"frame",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"frame",OBJPROP_SELECTED,false);   
   ObjectSetInteger(0,"frame",OBJPROP_BORDER_TYPE,BORDER_FLAT);
  
   y=y+2;
   for(int i=0;i<2;i++)
     {
      y=y+39*i;
      if (currentLot[i]==-1){currentLot[i]=LotSize;}
               
      ObjectCreate(0,"btnOrderType" + orderType[i],OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0, "btnOrderType" + orderType[i], OBJPROP_CORNER, framePosition);
      ObjectSetText("btnOrderType" + orderType[i], currentOrderType[i] ,10,"Verdana",clrNONE);   
      ObjectSetInteger(0, "btnOrderType" + orderType[i], OBJPROP_COLOR, 0);
      ObjectSetInteger(0,"btnOrderType" + orderType[i],OBJPROP_XDISTANCE,x+4);
      ObjectSetInteger(0,"btnOrderType" + orderType[i],OBJPROP_YDISTANCE,y+17);
      ObjectSetInteger(0,"btnOrderType" + orderType[i],OBJPROP_XSIZE,20);
      ObjectSetInteger(0,"btnOrderType" + orderType[i],OBJPROP_YSIZE,20);
      ObjectSetInteger(0,"btnOrderType" + orderType[i],OBJPROP_SELECTABLE,false);
      
      ObjectCreate(0,"lblPrice" + orderType[i],OBJ_LABEL,0,0,0);
      ObjectSetInteger(0, "lblPrice" + orderType[i], OBJPROP_CORNER, framePosition);
      ObjectSetText("lblPrice" + orderType[i], orderType[i] + (currentOrderType[i]=="L" ? " Limit at Price" : (currentOrderType[i]=="E" ? " Market Execution" : " Stop at Price")) + ((LotControl==true) ? "" : " (" + DoubleToStr(currentLot[i], currentLot[i]>=100 ? 0 : currentLot[i]>=10 ? 1 : 2) + " Lot" + (currentLot[i]>1 ? "s" : "") + ")"),8,"Verdana",fore);
      ObjectSetInteger(0,"lblPrice" + orderType[i],OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,"lblPrice" + orderType[i],OBJPROP_XDISTANCE,x+5);
      ObjectSetInteger(0,"lblPrice" + orderType[i],OBJPROP_YDISTANCE,y+2);
      ObjectSetInteger(0,"lblPrice" + orderType[i],OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,"lblPrice" + orderType[i] ,OBJPROP_HIDDEN,true);
      
      ObjectCreate(0,"txtPrice" + orderType[i],OBJ_EDIT,0,0,0);
      ObjectSetInteger(0, "txtPrice" + orderType[i], OBJPROP_CORNER, framePosition);
      ObjectSetText("txtPrice" + orderType[i], currenTrail[i]=="A" ? DoubleToStr(StrToDouble(currenPrice[i]),Digits): "" ,10,"Arial",clrNONE);
      ObjectSetInteger(0, "txtPrice" + orderType[i], OBJPROP_COLOR, 0);
      ObjectSetInteger(0,"txtPrice" + orderType[i],OBJPROP_XDISTANCE,x+25);
      ObjectSetInteger(0,"txtPrice" + orderType[i],OBJPROP_YDISTANCE,y+17);
      ObjectSetInteger(0,"txtPrice" + orderType[i],OBJPROP_XSIZE,60);
      ObjectSetInteger(0,"txtPrice" + orderType[i],OBJPROP_YSIZE,20);
      ObjectSetInteger(0, "txtPrice" + orderType[i], OBJPROP_READONLY, currenTrail[i]=="A" ? false : true);
      ObjectSetInteger(0,"txtPrice" + orderType[i],OBJPROP_BGCOLOR, currenTrail[i]=="A" ? clrWhite : (color)i==0 ? SellColor : BuyColor);
      ObjectSetInteger(0,"txtPrice" + orderType[i],OBJPROP_SELECTABLE,false);
      
      ObjectCreate(0,"btnTrail" + orderType[i],OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0, "btnTrail" + orderType[i], OBJPROP_CORNER, framePosition);
      ObjectSetText("btnTrail" + orderType[i],currenTrail[i],10,"Verdana",clrNONE);   
      ObjectSetInteger(0, "btnTrail" + orderType[i], OBJPROP_COLOR, currentOrderType[i]=="E" ? clrGray : 0);
      ObjectSetInteger(0,"btnTrail" + orderType[i],OBJPROP_XDISTANCE,x+86);
      ObjectSetInteger(0,"btnTrail" + orderType[i],OBJPROP_YDISTANCE,y+17);
      ObjectSetInteger(0,"btnTrail" + orderType[i],OBJPROP_XSIZE,20);
      ObjectSetInteger(0,"btnTrail" + orderType[i],OBJPROP_YSIZE,20);   
      ObjectSetInteger(0,"btnTrail" + orderType[i],OBJPROP_SELECTABLE,false);
      
            
      ObjectCreate(0,"btnPriceL" + orderType[i],OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0, "btnPriceL" + orderType[i], OBJPROP_CORNER, framePosition);
      ObjectSetText("btnPriceL" + orderType[i],"-",10,"Verdana",clrNONE);   
      ObjectSetInteger(0, "btnPriceL" + orderType[i], OBJPROP_COLOR, currentOrderType[i]=="E" ? clrGray : 0);
      ObjectSetInteger(0,"btnPriceL" + orderType[i],OBJPROP_XDISTANCE,x+105);
      ObjectSetInteger(0,"btnPriceL" + orderType[i],OBJPROP_YDISTANCE,y+17);
      ObjectSetInteger(0,"btnPriceL" + orderType[i],OBJPROP_XSIZE,20);
      ObjectSetInteger(0,"btnPriceL" + orderType[i],OBJPROP_YSIZE,20);
      ObjectSetInteger(0,"btnPriceL" + orderType[i],OBJPROP_SELECTABLE,false);
      
      ObjectCreate(0,"btnPriceR" + orderType[i],OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0, "btnPriceR" + orderType[i], OBJPROP_CORNER, framePosition);
      ObjectSetText("btnPriceR" + orderType[i],"+",10,"Verdana",clrNONE);   
      ObjectSetInteger(0, "btnPriceR" + orderType[i], OBJPROP_COLOR, currentOrderType[i]=="E" ? clrGray : 0);
      ObjectSetInteger(0,"btnPriceR" + orderType[i],OBJPROP_XDISTANCE,x+124);
      ObjectSetInteger(0,"btnPriceR" + orderType[i],OBJPROP_YDISTANCE,y+17);
      ObjectSetInteger(0,"btnPriceR" + orderType[i],OBJPROP_XSIZE,20);
      ObjectSetInteger(0,"btnPriceR" + orderType[i],OBJPROP_YSIZE,20);   
      ObjectSetInteger(0,"btnPriceR" + orderType[i],OBJPROP_SELECTABLE,false);
   

      if (LotControl==true){
         ObjectCreate(0,"lotLbl"+ orderType[i] ,OBJ_LABEL,0,0,0);
         ObjectSetInteger(0, "lotLbl"+ orderType[i], OBJPROP_CORNER, framePosition);
         ObjectSetText("lotLbl"+ orderType[i], "Lots",8,"Verdana",fore);
         ObjectSetInteger(0,"lotLbl" + orderType[i],OBJPROP_FONTSIZE,8);
         ObjectSetInteger(0,"lotLbl"+ orderType[i],OBJPROP_XDISTANCE,x+148);
         ObjectSetInteger(0,"lotLbl"+ orderType[i],OBJPROP_YDISTANCE,y+2);
         ObjectSetInteger(0,"lotLbl"+ orderType[i] ,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,"lotLbl" + orderType[i],OBJPROP_BACK,0);
         ObjectSetInteger(0,"lotLbl" + orderType[i] ,OBJPROP_HIDDEN,true);
         ObjectCreate(0,"txtLot" + orderType[i],OBJ_EDIT,0,0,0);
         ObjectSetInteger(0, "txtLot" + orderType[i], OBJPROP_CORNER, framePosition);

         ObjectSetText("txtLot" + orderType[i],DoubleToStr(currentLot[i], currentLot[i]>=100 ? 0 : currentLot[i]>=10 ? 1 : 2),10,"Arial",clrNONE);
         ObjectSetInteger(0, "txtLot" + orderType[i], OBJPROP_COLOR, 0);
         ObjectSetInteger(0,"txtLot" + orderType[i],OBJPROP_XDISTANCE,x+148);
         ObjectSetInteger(0,"txtLot" + orderType[i],OBJPROP_YDISTANCE,y+17);
         ObjectSetInteger(0,"txtLot" + orderType[i],OBJPROP_XSIZE,35);
         ObjectSetInteger(0,"txtLot" + orderType[i],OBJPROP_YSIZE,20);
         ObjectSetInteger(0, "txtLot" + orderType[i], OBJPROP_READONLY, false);
         ObjectSetInteger(0,"txtLot" + orderType[i],OBJPROP_SELECTABLE,false);
         
         ObjectCreate(0,"btnLotL" + orderType[i],OBJ_BUTTON,0,0,0);
         ObjectSetInteger(0, "btnLotL" + orderType[i], OBJPROP_CORNER, framePosition);
         ObjectSetText("btnLotL" + orderType[i],"-",10,"Verdana",clrNONE);   
         ObjectSetInteger(0, "btnLotL" + orderType[i], OBJPROP_COLOR, 0);
         ObjectSetInteger(0,"btnLotL" + orderType[i],OBJPROP_XDISTANCE,x+183);
         ObjectSetInteger(0,"btnLotL" + orderType[i],OBJPROP_YDISTANCE,y+17);
         ObjectSetInteger(0,"btnLotL" + orderType[i],OBJPROP_XSIZE,20);
         ObjectSetInteger(0,"btnLotL" + orderType[i],OBJPROP_YSIZE,20);
         ObjectSetInteger(0,"btnLotL" + orderType[i],OBJPROP_SELECTABLE,false);
         
         ObjectCreate(0,"btnLotR" + orderType[i],OBJ_BUTTON,0,0,0);
         ObjectSetInteger(0, "btnLotR" + orderType[i], OBJPROP_CORNER, framePosition);
         ObjectSetText("btnLotR" + orderType[i],"+",10,"Verdana",clrNONE);   
         ObjectSetInteger(0, "btnLotR" + orderType[i], OBJPROP_COLOR, 0);
         ObjectSetInteger(0,"btnLotR" + orderType[i],OBJPROP_XDISTANCE,x+202);
         ObjectSetInteger(0,"btnLotR" + orderType[i],OBJPROP_YDISTANCE,y+17);
         ObjectSetInteger(0,"btnLotR" + orderType[i],OBJPROP_XSIZE,20);
         ObjectSetInteger(0,"btnLotR" + orderType[i],OBJPROP_YSIZE,20);   
         ObjectSetInteger(0,"btnLotR" + orderType[i],OBJPROP_SELECTABLE,false);         
      }
        
        
      ObjectCreate(0,"btnOrder" + orderType[i],OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0, "btnOrder" + orderType[i], OBJPROP_CORNER, framePosition);
      ObjectSetText("btnOrder" + orderType[i],orderType[i],10,"Verdana",clrNONE);   
      ObjectSetInteger(0, "btnOrder" + orderType[i], OBJPROP_COLOR, 0);
      ObjectSetInteger(0, "btnOrder" + orderType[i], OBJPROP_BGCOLOR, (color)i==0 ? SellColor : BuyColor);
      ObjectSetInteger(0,"btnOrder" + orderType[i],OBJPROP_XDISTANCE,x+148+((LotControl==true) ? 78 : 0));
      ObjectSetInteger(0,"btnOrder" + orderType[i],OBJPROP_YDISTANCE,y+17);
      ObjectSetInteger(0,"btnOrder" + orderType[i],OBJPROP_XSIZE,45);
      ObjectSetInteger(0,"btnOrder" + orderType[i],OBJPROP_YSIZE,20);   
      ObjectSetInteger(0,"btnOrder" + orderType[i],OBJPROP_SELECTABLE,false);
   }
      
   RefreshPrices(); 
   return(INIT_SUCCEEDED);
}


void OnDeinit(const int reason)  { 

   ObjectDelete (0,"top");
   ObjectDelete (0,"ordersLbl");
   ObjectDelete (0,"closeLbl");
   ObjectDelete (0,"frame");
   for(int i=0;i<2;i++)
     {
         ObjectDelete (0,"btnOrderType"+ orderType[i]);
         ObjectDelete (0,"lblPrice"+ orderType[i]);
         ObjectDelete (0,"txtPrice"+ orderType[i]);
         ObjectDelete (0,"btnPriceL"+ orderType[i]);
         ObjectDelete (0,"btnPriceR"+ orderType[i]);
         ObjectDelete (0,"btnTrail"+ orderType[i]);
         ObjectDelete (0,"lotLbl"+ orderType[i]);
         ObjectDelete (0,"txtLot"+ orderType[i]);
         ObjectDelete (0,"btnLotL"+ orderType[i]);
         ObjectDelete (0,"btnLotR"+ orderType[i]);
         ObjectDelete (0,"btnOrder"+ orderType[i]);
      }
}

void RefreshPrices(){
   
   double sl=0, tp = 0;
   int ct=0, ctt=0;
   string ss;
   
   for(int i=0;i<2;i++) {  
      string c=ObjectGetString(0,"btnOrderType" + orderType[i], OBJPROP_TEXT,0);
      double ShiftAmount=c=="E" ? 0 : ((c=="L") ? LimitOrderAmount : (c=="S" ? StopOrderAmount : 0));
      if (ObjectGetString(0,"btnTrail" + orderType[i], OBJPROP_TEXT,0)=="M") {
         ObjectSetText("txtPrice" + orderType[i], DoubleToStr( (i==0 ? Bid : Ask) + (c=="L" ? + 1 : -1) * (i==0 ? +1 : -1) * ShiftAmount,Digits) ,10,"Arial",clrNONE);
      }
   }   
   int n=OrdersTotal(); 
   for(int i = 0; i < n; i++)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      continue;
      if (Symbol()==OrderSymbol())
      {   
         ctt=ctt+1;
         double tickvalue = MarketInfo("0", MODE_TICKVALUE);
         if (OrderStopLoss()!=0)
         {
            sl=sl+(OrderType()==OP_SELL || OrderType()==OP_SELLLIMIT ||OrderType()==OP_SELLSTOP ? +1 : -1)*(OrderOpenPrice()-OrderStopLoss())*pow(10, Digits)*tickvalue*OrderLots();
         }
         else
         {
            ct=ct+1;
         }
                  
         if (OrderTakeProfit()!=0)
         {
            tp=tp+(OrderType()==OP_SELL || OrderType()==OP_SELLLIMIT ||OrderType()==OP_SELLSTOP ? +1 : -1)*(OrderOpenPrice()-OrderTakeProfit())*pow(10, Digits)*tickvalue*OrderLots();
         }
      }
   }
   if (ctt!=0)
   {
      ss=Symbol()  + "  " + (sl>0 ? "+" : "") + DoubleToStr(NormalizeDouble(sl,0),0) + "  " + (tp>0 ? "+" : "") + DoubleToStr(NormalizeDouble(tp ,0),0); //+ "  !" + (int)MarketInfo("EURUSD",MODE_SPREAD); //+ (ct>0 ? " [!]" : "");
   }
   else
   {
      ss=Symbol();
   }
   ObjectSetText("ordersLbl", ss,7,"Verdana",fore);
}

void OnTick() {
   RefreshPrices(); 
}


void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   int i;
   string s, ss;
   double l;
      
   if (id==CHARTEVENT_OBJECT_DELETE) {
      if (sparam=="top"){ 
         ObjectDelete("ordersLbl");
         ObjectDelete("closeLbl");
         OnInit();
      }
   }
   
   if (id==CHARTEVENT_CHART_CHANGE) 
   {
      int sh;   
      sh=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);  
      if (sh<(framey+100)){
         framey=sh-100;
         if (framey<1) {
            framey=1;
         }         
         OnInit();
      }
   }

   if (id==CHARTEVENT_MOUSE_MOVE) {
      mm=(int)sparam;
      if (sparam=="1" && ((xc != lparam) || (yc != dparam)))
      {
         isDragging=1;
         
         if ((ObjectGetInteger(0,"top",OBJPROP_XDISTANCE)!=framex) || (ObjectGetInteger(0,"top",OBJPROP_YDISTANCE)!=framey)) {
            framex=(int)ObjectGetInteger(0,"top",OBJPROP_XDISTANCE);
            framey=(int)ObjectGetInteger(0,"top",OBJPROP_YDISTANCE);
            OnInit();
         }         
      }
      else
      {
         if (sparam!="1"){
            xc=(int)lparam;
            yc=(int)dparam;
            isDragging=0;
         }
      }
   }
        
   if(sparam =="top") {
      int shh;   
      shh=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);           
      int ll=(int)(lparam-framex);
      
      
      if ((ll>(187+((LotControl==true) ? 78 : 0)) )&&(ll<(200+((LotControl==true) ? 78 : 0)))){
         if (MessageBox("Do you want to close this utility?","Manual Trading Lightweight Utility",1)==1){
            ExpertRemove();
         }      
      }   
   } 
     
   if (id==CHARTEVENT_KEYDOWN) 
   {
      if (lparam==76){
         LotControl=!LotControl;
         OnDeinit(0);
         OnInit();
      }
   }
      
   if (id==CHARTEVENT_OBJECT_ENDEDIT) 
   {
      for(i=0;i<2;i++) {  
         if (sparam=="txtLot"+ orderType[i]){
            s=ObjectGetString(0,"txtLot" + orderType[i],OBJPROP_TEXT,0);
            l=StrToDouble(s);
            if(l==0) {
               l=currentLot[i];
            }
            ObjectSetText("txtLot" + orderType[i],DoubleToStr(l, l>=100 ? 0 : l>=10 ? 1 : 2),10,"Arial",clrNONE);
            currentLot[i]=l;   
         }
         if (sparam=="txtPrice"+ orderType[i]){
            s=ObjectGetString(0,"txtPrice" + orderType[i],OBJPROP_TEXT,0);
            l=StrToDouble(s);
            if(l==0) {
               l= (i==0 ? Bid : Ask);
            }
            ObjectSetText("txtPrice" + orderType[i], DoubleToStr(l,Digits),10,"Arial",clrNONE);
            currenPrice[i]=DoubleToStr(l);   
         }

      }
   } 
   
       
   if ((id==CHARTEVENT_OBJECT_CLICK) && (isDragging==0)) {

      for(i=0;i<2;i++) {  
         if(ObjectGetInteger(0,"btnOrderType" + orderType[i],OBJPROP_STATE)==true) {
            s=ObjectGetString(0,"btnOrderType" + orderType[i],OBJPROP_TEXT,0);
            if (s=="S") {
               s="E";
               ObjectSetInteger(0, "txtPrice" + orderType[i], OBJPROP_READONLY, true);
               ObjectSetInteger(0,"txtPrice" + orderType[i],OBJPROP_BGCOLOR,(color)i==0 ? SellColor : BuyColor);
               ObjectSetText("btnTrail" + orderType[i], "M", 10, "Arial", clrNONE);
               currenTrail[i]="M";
               ObjectSetInteger(0, "btnTrail" + orderType[i], OBJPROP_COLOR, clrGray);
               ObjectSetInteger(0, "btnPriceL" + orderType[i], OBJPROP_COLOR, clrGray);
               ObjectSetInteger(0, "btnPriceR" + orderType[i], OBJPROP_COLOR, clrGray);
               RefreshPrices(); 
            }
            else {
               ObjectSetInteger(0, "btnTrail" + orderType[i], OBJPROP_COLOR, 0);
               ObjectSetInteger(0, "btnPriceL" + orderType[i], OBJPROP_COLOR, 0);
               ObjectSetInteger(0, "btnPriceR" + orderType[i], OBJPROP_COLOR, 0);            
               if (s=="E") {
                  s="L";
                  
               }
               else {
                  s="S";
               }
            }
            ObjectSetText("btnOrderType"  + orderType[i], s ,10,"Arial",clrNONE);
            ObjectSetText("lblPrice" + orderType[i], orderType[i] + (s=="L" ? " Limit at Price" : (s=="E" ? " Market Execution" : " Stop at Price")) + ((LotControl==true) ? "" : " (" + DoubleToStr(currentLot[i], currentLot[i]>=100 ? 0 : currentLot[i]>=10 ? 1 : 2) + " Lot" + (currentLot[i]>1 ? "s" : "") + ")"),8,"Verdana",fore);
            RefreshPrices(); 
            currentOrderType[i]=s;
            Sleep(50);     
         }
         
         if(ObjectGetInteger(0,"btnTrail" + orderType[i],OBJPROP_STATE)==true) {
            s=ObjectGetString(0,"btnOrderType" + orderType[i],OBJPROP_TEXT,0);
            if (s!="E"){
               s=ObjectGetString(0,"btnTrail" + orderType[i],OBJPROP_TEXT,0);
               if (s=="M") {
                  s="A";
                  ObjectSetText("btnTrail" + orderType[i], s, 10, "Arial", clrNONE);
                  ObjectSetInteger(0,"txtPrice" + orderType[i],OBJPROP_BGCOLOR,clrWhite);
                  ObjectSetInteger(0, "txtPrice" + orderType[i], OBJPROP_READONLY, false);
                  ss=ObjectGetString(0,"txtPrice" + orderType[i],OBJPROP_TEXT,0);
                  l=StrToDouble(ss);               
                  currenPrice[i]=DoubleToStr(l);
               }
               else {
                  s="M";
                  ObjectSetText("btnTrail" + orderType[i], s, 10, "Arial", clrNONE);
                  RefreshPrices(); 
                  ObjectSetInteger(0,"txtPrice" + orderType[i],OBJPROP_BGCOLOR,(color)i==0 ? SellColor : BuyColor);
                  ObjectSetInteger(0, "txtPrice" + orderType[i], OBJPROP_READONLY, true);               
               }
            }
            currenTrail[i]=s;
            Sleep(50);     
         }
           
         if(ObjectGetInteger(0,"btnPriceL" + orderType[i],OBJPROP_STATE)==true) {
            s=ObjectGetString(0,"btnOrderType" + orderType[i],OBJPROP_TEXT,0);
            if (s!="E"){         
               ObjectSetText("btnTrail" + orderType[i],"A",10,"Arial",clrNONE);
               ObjectSetInteger(0,"txtPrice" + orderType[i],OBJPROP_BGCOLOR,clrWhite);
               s=ObjectGetString(0,"txtPrice" + orderType[i],OBJPROP_TEXT,0);
               l=StrToDouble(s);
               ObjectSetText("txtPrice" + orderType[i],DoubleToStr(l-=PriceStep*Point,Digits),10,"Arial",clrNONE);
               ObjectSetInteger(0, "txtPrice" + orderType[i], OBJPROP_READONLY, false);
               s=ObjectGetString(0,"txtPrice" + orderType[i],OBJPROP_TEXT,0);
               l=StrToDouble(s);               
               currenPrice[i]=DoubleToStr(l);
            }
            Sleep(50);        
         }
      
         if(ObjectGetInteger(0,"btnPriceR" + orderType[i],OBJPROP_STATE)==true) {
            s=ObjectGetString(0,"btnOrderType" + orderType[i],OBJPROP_TEXT,0);
            if (s!="E"){         
               ObjectSetText("btnTrail" + orderType[i],"A",10,"Arial",clrNONE);
               ObjectSetInteger(0,"txtPrice" + orderType[i],OBJPROP_BGCOLOR,clrWhite);
               s=ObjectGetString(0,"txtPrice" + orderType[i],OBJPROP_TEXT,0);
               l=StrToDouble(s);
               ObjectSetText("txtPrice" + orderType[i],DoubleToStr(l+=PriceStep*Point,Digits),10,"Arial",clrNONE);
               ObjectSetInteger(0, "txtPrice" + orderType[i], OBJPROP_READONLY, false);
               s=ObjectGetString(0,"txtPrice" + orderType[i],OBJPROP_TEXT,0);
               l=StrToDouble(s);               
               currenPrice[i]=DoubleToStr(l);
            }
            Sleep(50);            
         }   
               
         if(ObjectGetInteger(0,"btnLotL" + orderType[i],OBJPROP_STATE)==true) {
            s=ObjectGetString(0,"txtLot" + orderType[i],OBJPROP_TEXT,0);
            l=StrToDouble(s);
            if (l>LotVolumeStep){
               l=l-(LotVolumeStep<1 && l>100 ? 1 : (LotVolumeStep<0.1 && l>10 ? 0.1 : LotVolumeStep));
               ObjectSetText("txtLot" + orderType[i],DoubleToStr(l, l>=100 ? 0 : l>=10 ? 1 : 2),10,"Arial",clrNONE);
               s=ObjectGetString(0,"txtLot" + orderType[i],OBJPROP_TEXT,0);
               l=StrToDouble(s);
               currentLot[i]=l;
            }
            Sleep(50);        
         }
      
         if(ObjectGetInteger(0,"btnLotR" + orderType[i],OBJPROP_STATE)==true) {
            s=ObjectGetString(0,"txtLot" + orderType[i],OBJPROP_TEXT,0);
            l=StrToDouble(s);
            if ((l+LotVolumeStep)<=marketMaxLot){
               l=l+(LotVolumeStep<1 && l>=100 ? 1 : (LotVolumeStep<0.1 && l>=10 ? 0.1 : LotVolumeStep));
               ObjectSetText("txtLot" + orderType[i],DoubleToStr(l,l>=100 ? 0 : l>=10 ? 1 : 2),10,"Arial",clrNONE);
               s=ObjectGetString(0,"txtLot" + orderType[i],OBJPROP_TEXT,0);
               l=StrToDouble(s);
               currentLot[i]=l;       
            }
            Sleep(50);            
         }   
                        
         if(ObjectGetInteger(0,"btnOrder" + orderType[i],OBJPROP_STATE)==true) {
            string c=ObjectGetString(0,"btnOrderType" + orderType[i], OBJPROP_TEXT,0);
            double Price=StrToDouble(ObjectGetString(0,"txtPrice" + orderType[i],OBJPROP_TEXT,0));
            //double lots=ObjectGetString(0,"txtLot" + orderType[i],OBJPROP_TEXT,0);
            double StopLoss=Price + (i==0 ? +(StopLossAmount + Ask - Bid) : -(StopLossAmount + Ask - Bid));
            double TakeProfit=Price + (i==0 ? -(TakeProfitAmount ) : +(TakeProfitAmount));
            //if (Symbol()=="E" + "U" + "RU" + "SD"){
               
               int ticket=OrderSend(Symbol(),c=="E" ? (i==0 ? OP_SELL : OP_BUY) : (c=="L" ? (i==0 ? OP_SELLLIMIT : OP_BUYLIMIT) : (i==0 ? OP_SELLSTOP : OP_BUYSTOP)), currentLot[i], 
                     NormalizeDouble(Price,Digits), 50, NormalizeDouble(StopLossPoints==0 ? 0 : StopLoss,Digits), NormalizeDouble(TakeProfitPoints==0 ? 0 :TakeProfit,Digits),comment, magicNumber, 0, clrNONE);
               Sleep(50);     
               
               if(ticket>0){
                  if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
                     Print(orderType[i] +" order opened : ",OrderOpenPrice());
                     ObjectSetInteger(0,"lotLbl" + orderType[i],OBJPROP_BACK,0);
                     RefreshPrices(); 
                     ObjectSetText("lblPrice" + orderType[i], orderType[i] + (s=="L" ? " Limit at Price" : (s=="E" ? " Market Execution" : " Stop at Price")) + ((LotControl==true) ? "" : " (" + DoubleToStr(currentLot[i], currentLot[i]>=100 ? 0 : currentLot[i]>=10 ? 1 : 2) + " Lot" + (currentLot[i]>1 ? "s" : "") + ")"),8,"Verdana",fore);
                  }    
               }
               else {
                  string errore=ErrorDescription(GetLastError());
                  //bool u=StringToUpper(errore);
                  ObjectSetInteger(0,"lotLbl" + orderType[i],OBJPROP_BACK,1);
                  Print("Error opening " + orderType[i] +" order : ", errore);
                  ObjectSetText("lblPrice" + orderType[i], errore,8,"Verdana",clrRed);     
               }  
            /*
            }
            else
            {
               ObjectSetInteger(0,"lotLbl" + orderType[i],OBJPROP_BACK,1);
               ObjectSetText("lblPrice" + orderType[i], "This utility is FREE on EURUSD",8,"Verdana",clrRed);   
            }
           */
         }   
      }   
   }  
   
   if (id==CHARTEVENT_OBJECT_CLICK)  {
      for(i=0;i<2;i++) {    
         ObjectSetInteger(0,"btnOrderType" + orderType[i],OBJPROP_STATE,false);
         ObjectSetInteger(0,"btnTrail" + orderType[i],OBJPROP_STATE,false);
         ObjectSetInteger(0,"btnPriceL" + orderType[i],OBJPROP_STATE,false);      
         ObjectSetInteger(0,"btnPriceR" + orderType[i],OBJPROP_STATE,false);
         ObjectSetInteger(0,"btnOrder" + orderType[i],OBJPROP_STATE,false);       
         ObjectSetInteger(0,"btnLotL" + orderType[i],OBJPROP_STATE,false);       
         ObjectSetInteger(0,"btnLotR" + orderType[i],OBJPROP_STATE,false);       
         
         ObjectSetInteger(0,"top",OBJPROP_SELECTED,true);  

      }
   }
}
  
  
  
