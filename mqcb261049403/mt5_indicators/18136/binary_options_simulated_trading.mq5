//+-------------------------------------------------------------------------+
//| Binary Options Simulated Trading                                        |
//+-------------------------------------------------------------------------+
#property copyright "Coded by Leon Lam (QQ: 82756)"
#property link "http://wpa.qq.com/msgrd?v=3&uin=82756&site=qq&menu=yes"
#property version "17.429"
#property description "Binary Options Simulated Trading"
#property indicator_chart_window

enum ENUM_LANGUAGE {English,Chinese};  //Define Language
input double BALANCE=10000;  //Account Balance
input double AMOUNT=10;      //Investment Amount (Lots)
input double MARGIN=0.75;    //Profit Margin
input int EXPIRED=3;         //Expiry Time (Minutes)
input ENUM_LANGUAGE LANGUAGE=Chinese; //Display Language

double OS_BALANCE=BALANCE,OS_LOTS=AMOUNT,OS_MARGIN=MARGIN;  //Variable for account balance / investment amount / profit margin
int OS_EXPIRED=EXPIRED; int OP_BUY=0,OP_SELL=1;       //Variable for expiry time / buy order / sell order
double OS_ORDER[]={0,0,-1};   //Variables for time & price & buy/sell
double OS_COUNT[]={0,0,0};    //Variable for total & win & flat
//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Remove All Object When Exit                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   int CHART_ID=0; string OBJ_NAME="ORDER LINE";
   if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);
   OBJ_NAME="PanelRectangle";
   if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);
   OBJ_NAME="PanelTitle";
   if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);
   OBJ_NAME="PanelBalance";
   if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);
   OBJ_NAME="PanelProfit";
   if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);
   OBJ_NAME="PanelExpired";
   if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);
   OBJ_NAME="PanelBtnExpMinus";
   if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);
   OBJ_NAME="PanelBtnExpPlus";
   if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);
   OBJ_NAME="PanelCount";
   if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);
   OBJ_NAME="PanelBtnCall";
   if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);
   OBJ_NAME="PanelBtnPut";
   if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);
  }
//+------------------------------------------------------------------+
//| Main                                                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[])
  {
   PanelCreate(); //Draw Main Panel
   ORDER_CLOSE(); //Close order
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Button Click Events                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(OS_ORDER[0]!=0||OS_ORDER[1]!=0) return;      //Exit when there is an order in processd
      if(sparam=="PanelBtnCall") ORDER_OPEN(OP_BUY);  //Call button click
      if(sparam=="PanelBtnPut") ORDER_OPEN(OP_SELL);  //Put button click
      if(sparam=="PanelBtnExpMinus")   //Minute add button click
        {
         if(OS_EXPIRED<=1) return;     //Minimum 1 minute
         OS_EXPIRED--;
        }
      if(sparam=="PanelBtnExpPlus")    //Minute subtract button click
        {
         if(OS_EXPIRED>=60) return;    //Maximum 60 minute
         OS_EXPIRED++;
        }
     }
  }
//+------------------------------------------------------------------+
//| Open a New Order                                                 |
//+------------------------------------------------------------------+
bool ORDER_OPEN(int OP)
  {
   if(OS_ORDER[0]!=0||OS_ORDER[1]!=0) return false;   //Exit when there is an order in processd
   if(OS_BALANCE<OS_LOTS) return false;               //Exit when the balance is not enough
   if(OP==OP_BUY)
     {
      OS_ORDER[0]=(int)TimeCurrent();  //Set order time
      OS_ORDER[1]=Close();             //Set order current price
      OS_ORDER[2]=OP_BUY;              //Set order type: buy
      OS_BALANCE-=OS_LOTS;             //Minus the balance
      ORDER_LINE(OP);                  //Draw a line for buy
      return true;
     }
   if(OP==OP_SELL)
     {
      OS_ORDER[0]=(int)TimeCurrent();  //Set order time
      OS_ORDER[1]=Close();             //Set order current price
      OS_ORDER[2]=OP_SELL;             //Set order type: sell
      OS_BALANCE-=OS_LOTS;             //Minus the balance
      ORDER_LINE(OP);                  //Draw a line for sell
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Close Order and Remove Order Line                                |
//+------------------------------------------------------------------+
void ORDER_CLOSE()
  {
   if(OS_ORDER[0]!=0 && OS_ORDER[1]!=0)   //Execute when order in processd
     {
      if(TimeCurrent()>=OS_ORDER[0]+(OS_EXPIRED*60))  //Execute when order timeout
        {
         if(OS_ORDER[2]==OP_BUY)       //Close buy order
           {
            if(Close()==OS_ORDER[1])   //Order flat when current price equal order price
              {
               OS_BALANCE+=OS_LOTS;    //Recover account balance
               OS_COUNT[2]++;          //Total flat order
              }
            if(Close()>OS_ORDER[1])    //Order flat when current price more than order price
              {
               OS_BALANCE+=OS_LOTS+(OS_LOTS*OS_MARGIN);  //Add account balance
               OS_COUNT[1]++;          //Total win order
              }
           }
         if(OS_ORDER[2]==OP_SELL)      //Close sell order
           {
            if(Close()==OS_ORDER[1])   //Order flat when current price equal order price
              {
               OS_BALANCE+=OS_LOTS;    //Recover account balance
               OS_COUNT[2]++;          //Total flat order
              }
            if(Close()<OS_ORDER[1])    //Order flat when current price less than order price
              {
               OS_BALANCE+=OS_LOTS+(OS_LOTS*OS_MARGIN);  //Add account balance
               OS_COUNT[1]++;          //Total win order
              }
           }
         OS_COUNT[0]++; OS_ORDER[0]=0; OS_ORDER[1]=0; OS_ORDER[2]=-1;   //Total all order & reset time & reset price & reset order type
         int CHART_ID=0; string OBJ_NAME="ORDER LINE";
         if(ObjectFind(CHART_ID,OBJ_NAME)>=0) ObjectDelete(CHART_ID,OBJ_NAME);   //Remove order line
        }
     }
  }
//+------------------------------------------------------------------+
//| Draw Order Line                                                  |
//+------------------------------------------------------------------+
void ORDER_LINE(int OP)
  {
   int CHART_ID=0; string OBJ_NAME="ORDER LINE";
   if(ObjectFind(CHART_ID,OBJ_NAME)<0)    //Draw a new order line
     {
      ObjectCreate(CHART_ID,OBJ_NAME,OBJ_HLINE,0,0,Close());
      ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BACK,false);
      ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTED,false);
      ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_HIDDEN,true);
      ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_COLOR,(OP==OP_BUY?clrRed:clrLime));
      ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_STYLE,STYLE_DASHDOT);
      if(LANGUAGE==Chinese)   //Display language text(Chinese|English)
        {
         ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,(OP==OP_BUY?"买涨":"买跌")+(string)OS_EXPIRED+"分钟 ("+TimeToString(TimeCurrent(),TIME_DATE)+" "+TimeToString(TimeCurrent(),TIME_SECONDS)+")");
           }else{
         ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,(OP==OP_BUY?"Buy":"Sell")+" "+(string)OS_EXPIRED+" Minutes ("+TimeToString(TimeCurrent(),TIME_DATE)+" "+TimeToString(TimeCurrent(),TIME_SECONDS)+")");
        }
     }
  }
//+------------------------------------------------------------------+
//| Draw Trading Panel                                               |
//+------------------------------------------------------------------+
void PanelCreate()
  {
   //Draw panel background
   int CHART_ID=0; string OBJ_NAME="PanelRectangle",OBJ_CLOCK;
   if(ObjectFind(CHART_ID,OBJ_NAME)<0) ObjectCreate(CHART_ID,OBJ_NAME,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_FILL,true);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BGCOLOR,C'10,10,10');
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_WIDTH,1);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XDISTANCE,115);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YDISTANCE,5);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XSIZE,110);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YSIZE,120);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BACK,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTED,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_HIDDEN,true);
   //Draw panel title
   OBJ_NAME="PanelTitle";
   if(ObjectFind(CHART_ID,OBJ_NAME)<0) ObjectCreate(CHART_ID,OBJ_NAME,OBJ_LABEL,0,0,0);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XDISTANCE,110);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YDISTANCE,10);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BACK,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTED,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_HIDDEN,true);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_FONTSIZE,9);
   if(LANGUAGE==Chinese)   //Display language text(Chinese|English)
     {
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Microsoft Yahei");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"二元期权模拟交易");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"二元期权模拟交易");
        }else{
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Arial Black");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"Binary Options");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"Binary Options Simulated Trading");
     }
   //Draw account balance
   OBJ_NAME="PanelBalance";
   if(ObjectFind(CHART_ID,OBJ_NAME)<0) ObjectCreate(CHART_ID,OBJ_NAME,OBJ_LABEL,0,0,0);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XDISTANCE,110);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YDISTANCE,30);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BACK,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTED,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_HIDDEN,true);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_FONTSIZE,8);
   if(LANGUAGE==Chinese)   //Display language text(Chinese|English)
     {
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Microsoft Yahei");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"余额 "+(string)OS_BALANCE);
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"余额 "+(string)OS_BALANCE);
        }else{
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Arial");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"BAL: "+(string)OS_BALANCE);
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"Balance: "+(string)OS_BALANCE);
     }
   //Draw investment amount and prifit margin
   OBJ_NAME="PanelProfit";
   if(ObjectFind(CHART_ID,OBJ_NAME)<0) ObjectCreate(CHART_ID,OBJ_NAME,OBJ_LABEL,0,0,0);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XDISTANCE,110);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YDISTANCE,45);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BACK,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTED,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_HIDDEN,true);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_FONTSIZE,8);
   if(LANGUAGE==Chinese)   //Display language text(Chinese|English)
     {
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Microsoft Yahei");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"收益 "+(string)OS_LOTS+"*"+(string)OS_MARGIN+"="+(string)(OS_LOTS*OS_MARGIN));
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"收益 "+(string)OS_LOTS+"*"+(string)OS_MARGIN+"="+(string)(OS_LOTS*OS_MARGIN));
        }else{
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Arial");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"PRO: "+(string)OS_LOTS+"*"+(string)OS_MARGIN+"="+(string)(OS_LOTS*OS_MARGIN));
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"Profit: "+(string)OS_LOTS+"*"+(string)OS_MARGIN+"="+(string)(OS_LOTS*OS_MARGIN));
     }
   //Draw order expiry time
   OBJ_NAME="PanelExpired";
   if(ObjectFind(CHART_ID,OBJ_NAME)<0) ObjectCreate(CHART_ID,OBJ_NAME,OBJ_LABEL,0,0,0);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XDISTANCE,110);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YDISTANCE,60);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BACK,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTED,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_HIDDEN,true);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_FONTSIZE,8);
   if(LANGUAGE==Chinese)   //Display language text(Chinese|English)
     {
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Microsoft Yahei");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"到期 "+(string)OS_EXPIRED+" 分钟");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"到期 "+(string)OS_EXPIRED+" 分钟");
        }else{
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Arial");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"EXP: "+(string)OS_EXPIRED+" Minutes");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"Expired: "+(string)OS_EXPIRED+" Minutes");
     }
   //Draw expiry time subtract button
   OBJ_NAME="PanelBtnExpMinus";
   if(ObjectFind(CHART_ID,OBJ_NAME)<0) ObjectCreate(CHART_ID,OBJ_NAME,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XDISTANCE,36);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YDISTANCE,62);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BACK,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTED,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_HIDDEN,true);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XSIZE,12);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YSIZE,12);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_ALIGN,ALIGN_CENTER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BGCOLOR,clrLime);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BORDER_COLOR,clrLime);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_FONTSIZE,9);
   if(LANGUAGE==Chinese)   //Display language text(Chinese|English)
     {
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Microsoft Yahei");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"－");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"减小1分钟");
        }else{
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Arial Black");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"-");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"Subtract 1 minute");
     }
   //Draw expiry time add button
   OBJ_NAME="PanelBtnExpPlus";
   if(ObjectFind(CHART_ID,OBJ_NAME)<0) ObjectCreate(CHART_ID,OBJ_NAME,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XDISTANCE,22);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YDISTANCE,62);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BACK,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTED,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_HIDDEN,true);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XSIZE,12);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YSIZE,12);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_ALIGN,ALIGN_CENTER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BGCOLOR,clrRed);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BORDER_COLOR,clrRed);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_FONTSIZE,9);
   if(LANGUAGE==Chinese)   //Display language text(Chinese|English)
     {
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Microsoft Yahei");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"＋");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"增加1分钟");
        }else{
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Arial Black");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"+");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"Add 1 minute");
     }
   //Draw order win & flat & total
   OBJ_NAME="PanelCount";
   if(ObjectFind(CHART_ID,OBJ_NAME)<0) ObjectCreate(CHART_ID,OBJ_NAME,OBJ_LABEL,0,0,0);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XDISTANCE,110);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YDISTANCE,75);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BACK,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTED,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_HIDDEN,true);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_FONTSIZE,8);
   if(LANGUAGE==Chinese)   //Display language text(Chinese|English)
     {
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Microsoft Yahei");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"胜率 "+(OS_COUNT[0]==0?"0%":(DoubleToString(OS_COUNT[1]/OS_COUNT[0]*100,1)+"% ("+(string)OS_COUNT[1]+"/"+(string)OS_COUNT[0]+")")));
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"胜率 "+(OS_COUNT[0]==0?"0%":(DoubleToString(OS_COUNT[1]/OS_COUNT[0]*100,1)+"% (胜 "+(string)OS_COUNT[1]+", 平 "+(string)OS_COUNT[2]+", 共 "+(string)OS_COUNT[0]+")")));
        }else{
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Arial");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,"WIN: "+(OS_COUNT[0]==0?"0%":(DoubleToString(OS_COUNT[1]/OS_COUNT[0]*100,1)+"% ("+(string)OS_COUNT[1]+"/"+(string)OS_COUNT[0]+")")));
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"Win rate: "+(OS_COUNT[0]==0?"0%":(DoubleToString(OS_COUNT[1]/OS_COUNT[0]*100,1)+"% (Win "+(string)OS_COUNT[1]+", Flat "+(string)OS_COUNT[2]+", Total "+(string)OS_COUNT[0]+")")));
     }
   //Draw order button for buy
   OBJ_NAME="PanelBtnCall"; OBJ_CLOCK="";
   if(OS_ORDER[2]==OP_BUY && OS_ORDER[0]!=0) OBJ_CLOCK=DoubleToString((OS_ORDER[0]+(OS_EXPIRED*60))-(int)TimeCurrent(),0)+(OS_ORDER[1]<Close()?" :)":(OS_ORDER[1]>Close()?" :(":" :|"));
   if(ObjectFind(CHART_ID,OBJ_NAME)<0) ObjectCreate(CHART_ID,OBJ_NAME,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XDISTANCE,110);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YDISTANCE,99);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BACK,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTED,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_HIDDEN,true);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XSIZE,45);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YSIZE,20);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_ALIGN,ALIGN_CENTER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BGCOLOR,clrRed);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BORDER_COLOR,clrRed);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_FONTSIZE,9);
   if(LANGUAGE==Chinese)   //Display language text(Chinese|English)
     {
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Microsoft Yahei");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,(OBJ_CLOCK==""?"买涨▲":OBJ_CLOCK));
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"买涨"+(string)OS_EXPIRED+"分钟");
        }else{
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Arial");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,(OBJ_CLOCK==""?"Buy▲":OBJ_CLOCK));
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"Buy "+(string)OS_EXPIRED+" Minutes");
     }
   //Draw order button for sell
   OBJ_NAME="PanelBtnPut"; OBJ_CLOCK="";
   if(OS_ORDER[2]==OP_SELL && OS_ORDER[0]!=0) OBJ_CLOCK=DoubleToString((OS_ORDER[0]+(OS_EXPIRED*60))-(int)TimeCurrent(),0)+(OS_ORDER[1]>Close()?" :)":(OS_ORDER[1]<Close()?" :(":" :|"));
   if(ObjectFind(CHART_ID,OBJ_NAME)<0) ObjectCreate(CHART_ID,OBJ_NAME,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XDISTANCE,55);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YDISTANCE,99);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BACK,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_SELECTED,false);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_HIDDEN,true);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_XSIZE,45);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_YSIZE,20);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_ALIGN,ALIGN_CENTER);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BGCOLOR,clrLime);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_BORDER_COLOR,clrLime);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(CHART_ID,OBJ_NAME,OBJPROP_FONTSIZE,9);
   if(LANGUAGE==Chinese)   //Display language text(Chinese|English)
     {
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Microsoft Yahei");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,(OBJ_CLOCK==""?"买跌▼":OBJ_CLOCK));
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"买跌"+(string)OS_EXPIRED+"分钟");
        }else{
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_FONT,"Arial");
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TEXT,(OBJ_CLOCK==""?"Sell▼":OBJ_CLOCK));
      ObjectSetString(CHART_ID,OBJ_NAME,OBJPROP_TOOLTIP,"Sell "+(string)OS_EXPIRED+" Minutes");
     }
  }
//+------------------------------------------------------------------+
//| Close Price                                                      |
//+------------------------------------------------------------------+
double Close()
  {
   return SymbolInfoDouble(Symbol(),SYMBOL_BID);   //Get current price
  }
//+------------------------------------------------------------------+
