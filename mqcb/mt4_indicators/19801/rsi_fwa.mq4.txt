//+------------------------------------------------------------------+
//|                                                          RSI.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp. et 2018, Charly Oudy"
#property link        "http://www.mql4.com"
#property description "Relative Strength Index : version 1.01"
#property strict

#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_buffers    1
#property indicator_color1     DodgerBlue
#property indicator_level1     30.0
#property indicator_level2     50.0
#property indicator_level3     70.0
#property indicator_levelcolor clrBlack
#property indicator_levelstyle STYLE_DOT
//--- input parameters
input int InpRSIPeriod = 14; // RSI Period
input int tailleArrow  =  5; // Taille des icones (1 à 5)
input int surachat     = 72; // Niveau de surachat déclenchant l'affichage de l'icone
input int survente     = 28; // Niveau de survente déclenchant l'affichage de l'icone
//--- buffers
double ExtRSIBuffer[];
double ExtPosBuffer[];
double ExtNegBuffer[];

   datetime lastbar;
   bool     premierTour;



//+------------------------------------------------------------------+
//| On vérifie si c'est une nouvelle barre                           |
//+------------------------------------------------------------------+
bool isNewBar(){
   datetime curbar = Time[0];
   if(lastbar!=curbar){
      return (true);
   }
   else
   {
      return(false);
   }
}
  

//+------------------------------------------------------------------+
//| Creating Text object                                             |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,               // chart's ID
                const string            name="Text",              // object name
                const int               sub_window=0,             // subwindow index
                datetime                time=0,                   // anchor point time
                double                  price=0,                  // anchor point price
                const string            text="Text",              // the text itself
                const string            font="Arial",             // font
                const int               font_size=10,             // font size
                const color             clr=clrRed,               // color
                const double            angle=0.0,                // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,              // hidden in the object list
                const long              z_order=0)                // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeTextEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create Text object
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the object by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
//| Create Check sign                                                |
//+------------------------------------------------------------------+
bool ArrowCheckCreate(const long              chart_ID=0,           // chart's ID
                      const string            name="ArrowCheck",    // sign name
                      const int               sub_window=0,         // subwindow index
                      datetime                time=0,               // anchor point time
                      double                  price=0,              // anchor point price
                      const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor type
                      const color             clr=clrRed,           // sign color
                      const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style
                      const int               width=3,              // sign size
                      const bool              back=false,           // in the background
                      const bool              selection=true,       // highlight to move
                      const bool              hidden=true,          // hidden in the object list
                      const long              z_order=0)            // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create the sign
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_CHECK,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Check\" sign! Error code = ",GetLastError());
      return(false);
     }
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set a sign color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the sign size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the sign by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Create Thumbs UP sign                                                |
//+------------------------------------------------------------------+
bool ArrowThumbUpCreate(const long              chart_ID=0,           // chart's ID
                      const string            name="ArrowCheck",    // sign name
                      const int               sub_window=0,         // subwindow index
                      datetime                time=0,               // anchor point time
                      double                  price=0,              // anchor point price
                      const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor type
                      const color             clr=clrRed,           // sign color
                      const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style
                      const int               width=3,              // sign size
                      const bool              back=false,           // in the background
                      const bool              selection=true,       // highlight to move
                      const bool              hidden=true,          // hidden in the object list
                      const long              z_order=0)            // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create the sign
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_THUMB_UP,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Check\" sign! Error code = ",GetLastError());
      return(false);
     }
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set a sign color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the sign size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the sign by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeTextEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
  
  
//+------------------------------------------------------------------+
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }

//+------------------------------------------------------------------+
//| Delete Check sign                                                |
//+------------------------------------------------------------------+
bool ArrowCheckDelete(const long   chart_ID=0,        // chart's ID
                      const string name="ArrowCheck") // sign name
  {
//--- reset the error value
   ResetLastError();
//--- delete the sign
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete \"Check\" sign! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="TrendLine",  // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time1=0,           // first point time
                 double                price1=0,          // first point price
                 datetime              time2=0,           // second point time
                 double                price2=0,          // second point price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            ray_right=false,   // line's continuation to the right
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- set anchor points' coordinates if they are not set
   ChangeTrendEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a trend line by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Check the values of trend line's anchor points and set default   |
//| values for empty ones                                            |
//+------------------------------------------------------------------+
void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, it is equal to the first point's one
   if(!price2)
      price2=price1;
  }
  

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   lastbar     = NULL;
   premierTour = TRUE;
   string short_name;
   // Variables globales pour entrer dans le RSI FWA
//--- 2 additional buffers are used for counting.
   IndicatorBuffers(3);
   SetIndexBuffer(1,ExtPosBuffer);
   SetIndexBuffer(2,ExtNegBuffer);
//--- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtRSIBuffer);
//--- name for DataWindow and indicator subwindow label
   short_name="RSI("+string(InpRSIPeriod)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//--- check for input
   if(InpRSIPeriod<2)
     {
      Print("Incorrect value for input variable InpRSIPeriod = ",InpRSIPeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,InpRSIPeriod);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int    i,pos;
   double diff;
//---
   if(Bars<=InpRSIPeriod || InpRSIPeriod<2)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtRSIBuffer,false);
   ArraySetAsSeries(ExtPosBuffer,false);
   ArraySetAsSeries(ExtNegBuffer,false);
   ArraySetAsSeries(close,false);
//--- preliminary calculations
   pos=prev_calculated-1;
   if(pos<=InpRSIPeriod)
     {
      //--- first RSIPeriod values of the indicator are not calculated
      ExtRSIBuffer[0]=0.0;
      ExtPosBuffer[0]=0.0;
      ExtNegBuffer[0]=0.0;
      double sump=0.0;
      double sumn=0.0;
      for(i=1; i<=InpRSIPeriod; i++)
        {
         ExtRSIBuffer[i]=0.0;
         ExtPosBuffer[i]=0.0;
         ExtNegBuffer[i]=0.0;
         diff=close[i]-close[i-1];
         if(diff>0)
            sump+=diff;
         else
            sumn-=diff;
        }
      //--- calculate first visible value
      ExtPosBuffer[InpRSIPeriod]=sump/InpRSIPeriod;
      ExtNegBuffer[InpRSIPeriod]=sumn/InpRSIPeriod;
      if(ExtNegBuffer[InpRSIPeriod]!=0.0)
         ExtRSIBuffer[InpRSIPeriod]=100.0-(100.0/(1.0+ExtPosBuffer[InpRSIPeriod]/ExtNegBuffer[InpRSIPeriod]));
      else
        {
         if(ExtPosBuffer[InpRSIPeriod]!=0.0)
            ExtRSIBuffer[InpRSIPeriod]=100.0;
         else
            ExtRSIBuffer[InpRSIPeriod]=50.0;
        }
      //--- prepare the position value for main calculation
      pos=InpRSIPeriod+1;
     }
//--- the main loop of calculations
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      diff=close[i]-close[i-1];
      ExtPosBuffer[i]=(ExtPosBuffer[i-1]*(InpRSIPeriod-1)+(diff>0.0?diff:0.0))/InpRSIPeriod;
      ExtNegBuffer[i]=(ExtNegBuffer[i-1]*(InpRSIPeriod-1)+(diff<0.0?-diff:0.0))/InpRSIPeriod;
      if(ExtNegBuffer[i]!=0.0)
         ExtRSIBuffer[i]=100.0-100.0/(1+ExtPosBuffer[i]/ExtNegBuffer[i]);
      else
        {
         if(ExtPosBuffer[i]!=0.0)
            ExtRSIBuffer[i]=100.0;
         else
            ExtRSIBuffer[i]=50.0;
        }
     }

//+------------------------------------------------------------------+
//| PLUS HAUTS et PLUS BAS by Charly Oudy                            |
//+------------------------------------------------------------------+

if (premierTour || isNewBar()){
// on déclare les variables nécessaires
   int nbBars=WindowBarsPerChart();    // le nombre de chandeliers visibles de la fenêtre
      //if (nbBars > 200){ nbBars = 200;}// On limite le nombre de barres traité pour éviter un plantage
   int j=1,h=1,maxI,minI,beginTrendUpI=0,beginTrendDownI=0,endTrendDownI=0,endTrendUpI=0;
   long chartID = ChartID();           // le sous-jacent courant
   string short_namebis, short_nameter;// le nom de l'objet
   double valRSI,maxRSI,minRSI, beginTrendUp=0, endTrendUp=0,beginTrendDown=0, endTrendDown=0;
   int subwindow=ChartWindowFind();    // numéro de la fenetre ou se trouve l'indicateur
   datetime beginTrendTimeDown=0, endTrendTimeDown=0, beginTrendTimeUp=0, endTrendTimeUp=0;

// On efface tous les signes visibles
   for(i=0;i<=nbBars;i++)
     {
      short_namebis="Plus haut("+string(i)+")"; // Les plus hauts
      if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}
      short_namebis="Plus bas("+string(i)+")"; // Les plus bas
      if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}
      short_namebis="Plus haut prix("+string(i)+")"; // Les plus haut sur les prix
      if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}
      short_namebis="Plus bas prix("+string(i)+")"; // Les plus haut sur les prix
      if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}
     }

// On efface les lines de tendances du RSI si il y en a et la mention divergence et le thumbs up
      short_namebis="Trend Line RSI sup";
      if(ObjectFind(chartID,short_namebis)>0 && !ArrowCheckDelete(chartID,short_namebis)){}
      short_namebis="Trend Line RSI inf";
      if(ObjectFind(chartID,short_namebis)>0 && !ArrowCheckDelete(chartID,short_namebis)){}
      short_namebis="Confirmation niveau 50";
      if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}
      short_namebis="Divergence-Convergence";
      if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}

// ON MET LES CHECK SIGN SUR LES PLUS HAUTS ET LES PLUS BAS
    if (Period() < 10080){ // Si on est en dessous du weekly
         i=0;
         while(i<=nbBars && j<=4 && h<=4)
         {
            valRSI=iRSI(NULL,0,InpRSIPeriod,PRICE_CLOSE,i);
            if(valRSI>surachat)
              {                       //si on est au dessus de 70
               maxRSI = valRSI;                  //on enregistre la valeur du RSI
               maxI   = i;                       //on enregistre le i max (pour l'utilsier dans le TIME()
               i++;
               valRSI=iRSI(NULL,0,InpRSIPeriod,PRICE_CLOSE,i);
      
               while(valRSI>60)
                 {
                  if(valRSI>maxRSI)
                    {             //Si on est au dessus de 70 et que le RSI est supérieur au maxRSI
                     maxRSI = valRSI;
                     maxI   = i;
                    }
      
                  i++;
                  valRSI=iRSI(NULL,0,14,PRICE_CLOSE,i);
                 }
      
               datetime  d3=Time[maxI];                      // On récupère la date concernée
               short_namebis="Plus haut("+string(j)+")";     // On cré le nom de l'objet pour le RSI
               short_nameter="Plus haut prix("+string(j)+")";// On cré le nom de l'objet pour le prix
               
               if(ArrowCheckCreate(chartID,short_namebis,subwindow,d3,maxRSI,ANCHOR_BOTTOM,clrRed,STYLE_SOLID,tailleArrow,false,false,false,0) 
                  && ArrowCheckCreate(chartID,short_nameter,0,d3,Close[maxI],ANCHOR_BOTTOM,clrRed,STYLE_SOLID,tailleArrow,false,false,false,0))
                     {
                        if (j == 2){
                              beginTrendUp     = maxRSI;
                              beginTrendTimeUp = d3;
                              beginTrendUpI    = i;
                        }
                        if (j == 1){
                              endTrendUp       = maxRSI;
                              endTrendTimeUp   = d3;
                              endTrendUpI      = i;
                        }
                        j++; // Si on a bien créé les objets, on incrémente j pour le prochain   
                     }
              }
      
            else if(valRSI<survente)
              {                        //si on est en dessous de 30
               minRSI = valRSI;
               minI   = i;
               i++;
               valRSI=iRSI(NULL,0,14,PRICE_CLOSE,i);
      
               while(valRSI<40)
                 {
                  if(valRSI<minRSI)
                    {
                     minRSI = valRSI;
                     minI   = i;
                    }
      
                  i++;
                  valRSI=iRSI(NULL,0,InpRSIPeriod,PRICE_CLOSE,i);
                 }
      
               datetime  d3=Time[minI];
               short_namebis="Plus bas("+string(h)+")";
               short_nameter="Plus bas prix("+string(h)+")";// On cré le nom de l'objet pour le prix
               if(ArrowCheckCreate(chartID,short_namebis,subwindow,d3,minRSI,ANCHOR_TOP,clrRed,STYLE_SOLID,tailleArrow,false,false,false,0) 
                  && ArrowCheckCreate(chartID,short_nameter,0,d3,Close[minI],ANCHOR_TOP,clrRed,STYLE_SOLID,tailleArrow,false,false,false,0))
                     {  
                        if (h == 2){
                              beginTrendDown     = minRSI;
                              beginTrendTimeDown = d3;
                              beginTrendDownI    = i;
                        }
                        if (h == 1){
                              endTrendDown       = minRSI;
                              endTrendTimeDown   = d3;
                              endTrendDownI      = i;
                        }
                        h++; // Si on a bien créé les objets, on incrémente h pour le prochain   
                     }
              }
      
            else
              {
               i++;                // On incrémente i si 30<valRSI< 70
              }
           }
           
           // On affiche les barres de tendances du RSI
           if (beginTrendDown != 0 && endTrendTimeUp < endTrendTimeDown){  // Sur les points bas
              short_namebis="Trend Line RSI inf";
              if(TrendCreate(chartID,short_namebis,subwindow,beginTrendTimeDown,beginTrendDown,endTrendTimeDown,endTrendDown,clrRed,STYLE_SOLID,2,false,false,false,false,0)){}
              
              // On récupère la valeur max entre les deux premiers points bas
              minRSI = endTrendDown;
              for(i=endTrendDownI;i<=beginTrendDownI;i++){
                  valRSI = iRSI(NULL,0,14,PRICE_CLOSE,i);
                  if(minRSI < valRSI){
                     minRSI = valRSI;
                     j = i;
                  }
              }
              
              //Si sup. à 50, on affiche un thumbs up ET la divergence ou convergence
              if (minRSI > 50){
                  datetime d3 = Time[j];
                  short_namebis="Confirmation niveau 50";
                  if(ArrowThumbUpCreate(chartID,short_namebis,subwindow,d3,minRSI,ANCHOR_BOTTOM,clrGreen,STYLE_SOLID,tailleArrow,false,false,false,0)){}
                  
                  if((beginTrendDown-endTrendDown)<0 && (Close[endTrendDownI]-Close[beginTrendDownI])<0){
                     short_nameter="  + divergence!";               
                  }
                  else{
                     short_nameter="  mais convergence..."; 
                  }
                  short_namebis="Divergence-Convergence";
                  d3 = Time[endTrendDownI];
                  if(TextCreate(chartID,short_namebis,subwindow,d3,70,short_nameter,"Arial",12,clrGreen,0.0,ANCHOR_LEFT_LOWER,false,false,false,0)){}
              }
           }
           
           if (beginTrendUp != 0 && endTrendTimeUp > endTrendTimeDown){    // Sur les points hauts
              short_namebis="Trend Line RSI sup";
              if(TrendCreate(chartID,short_namebis,subwindow,beginTrendTimeUp,beginTrendUp,endTrendTimeUp,endTrendUp,clrRed,STYLE_SOLID,2,false,false,false,false,0)){}
           
              // On récupère la valeur min entre les deux premiers points bas
              maxRSI = endTrendUp;
              for(i=endTrendUpI;i<=beginTrendUpI;i++){
                  valRSI = iRSI(NULL,0,14,PRICE_CLOSE,i);
                  if(maxRSI > valRSI){
                     maxRSI = valRSI;
                     j = i;
                  }
              }
              
              //Si inf. à 50, on affiche un thumbs up
              if (maxRSI < 50){
                  datetime d3 = Time[j];
                  short_namebis="Confirmation niveau 50";
                  if(ArrowThumbUpCreate(chartID,short_namebis,subwindow,d3,maxRSI-4,ANCHOR_TOP,clrGreen,STYLE_SOLID,8,false,false,false,0)){}
                  
                  if((beginTrendUp-endTrendUp)>0 && (Close[endTrendUpI]-Close[beginTrendUpI])>0){
                     short_nameter="  + divergence!";               
                  }
                  else{
                     short_nameter="  mais convergence..."; 
                  }
                  short_namebis="Divergence-Convergence";
                  d3 = Time[endTrendUpI];
                  if(TextCreate(chartID,short_namebis,subwindow,d3,30,short_nameter,"Arial",12,clrGreen,0.0,ANCHOR_LEFT_UPPER,false,false,false,0)){}
              }
           }
       
       }
       
       if (isNewBar()){ lastbar = Time[0]; } // Si on est entré avec une nouvelle barre, on met a jour lastbar
       else {premierTour = FALSE; }             // sinon on met premierTour à FALSE car c'était le premier tour :)

    }
       

//---
   return(rates_total);
  }
  
int deinit()                                    // Special funct. deinit()
   {
   // on déclare les variables nécessaires
   int nbBars=WindowBarsPerChart();    // le nombre de chandeliers visibles de la fenêtre
   long chartID = ChartID();           // le sous-jacent courant
   string short_namebis ;              // le nom de l'objet
   
   // On efface tous les signes visibles
   for(int i=0;i<=nbBars;i++)
        {
         short_namebis="Plus haut("+string(i)+")"; // Les plus hauts
         if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}
         short_namebis="Plus bas("+string(i)+")"; // Les plus bas
         if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}
         short_namebis="Plus haut prix("+string(i)+")"; // Les plus haut sur les prix
         if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}
         short_namebis="Plus bas prix("+string(i)+")"; // Les plus haut sur les prix
         if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}
        }

      // On efface les lines de tendances du RSI si il y en a et la mention divergence et le thumbs up
      short_namebis="Trend Line RSI sup";
      if(ObjectFind(chartID,short_namebis)>0 && !ArrowCheckDelete(chartID,short_namebis)){}
      short_namebis="Trend Line RSI inf";
      if(ObjectFind(chartID,short_namebis)>0 && !ArrowCheckDelete(chartID,short_namebis)){}
      short_namebis="Confirmation niveau 50";
      if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}
      short_namebis="Divergence-Convergence";
      if(ObjectFind(chartID,short_namebis)>=0 && !ArrowCheckDelete(chartID,short_namebis)){}

      return 1;                                      // Exit deinit()
}
//+------------------------------------------------------------------+
