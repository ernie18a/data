//+------------------------------------------------------------------+
//|                                                    KeyFinder.mqh |
//|                                                   Trofimov Pavel |
//|                                               trofimovpp@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Trofimov Pavel"
#property link      "trofimovpp@mail.ru"
//+------------------------------------------------------------------+
//| Class for KeyFinder 2.0                                          |
//+------------------------------------------------------------------+
class CKeyFinder
  {
private:
   // Class variables
   int               MinDimension;  //Minimum dimension of points
   int               MaxBars;       //The number of bars to process
protected:
   // Class methods for internal use
   // Determining the upper points dimensions
   int               getHighDimension(MqlRates &tmpRates[],int tmp_i,int tmp_iCod);
   // Determining the lower points dimensions
   int               getLowDimension(MqlRates &tmpRates[],int tmp_i,int tmp_iCod);
public:
   // Class constructor
                     CKeyFinder();
   // Class destructor
                    ~CKeyFinder();
   // Property method for getting the dimension   
   int               GetMinDimension();
   // Property method for setting the dimension
   void              SetMinDimension(int temp_Val);
   // Property method for getting the number of bars to process
   int               GetMaxBars();
   // Property method for setting the number of bars to process
   void              SetMaxBars(int temp_Val);
   // Method for finding upper pivot points
   void              FindUpKeyPoints(int temp_iCod,MqlRates &temp_rates[]);
   // Method for finding lower pivot points
   void              FindLowKeyPoints(int temp_iCod,MqlRates &temp_rates[]);
   // Clearing the chart from the script objects.
   int               CleanChart();
  };
//+------------------------------------------------------------------+
//|                Determining the upper point dimension             |
//+------------------------------------------------------------------+
int CKeyFinder::getHighDimension(MqlRates &tmpRates[],int tmp_i,int tmp_iCod)// The method receives an array of MqlRates type data, a number of a processed bar in the array and a maximum index of the array
  {
   int k=1;
   while((tmpRates[tmp_i].high>tmpRates[tmp_i+k].high) && (tmpRates[tmp_i].high>tmpRates[tmp_i-k].high) && ((tmp_i+k)<(tmp_iCod)) && ((tmp_i-k)>0)) k++;
   if(((tmp_i+k)==tmp_iCod) || ((tmp_i-k)==0)) k=-1;
   return(k);
  };
//+------------------------------------------------------------------+
//|                Determining the lower point dimension              |
//+------------------------------------------------------------------+
int CKeyFinder::getLowDimension(MqlRates &tmpRates[],int tmp_i,int tmp_iCod)// The method receives an array of MqlRates type data, a number of a processed bar in the array and a maximum index of the array
  {
   int k=1;
   while((tmpRates[tmp_i].low<tmpRates[tmp_i+k].low) && (tmpRates[tmp_i].low<tmpRates[tmp_i-k].low) && ((tmp_i+k)<(tmp_iCod)) && ((tmp_i-k)>0)) k++;
   if(((tmp_i+k)==tmp_iCod) || ((tmp_i-k)==0)) k=-1;
   return(k);
  };
//+------------------------------------------------------------------+
//| Method GetMinDimension                                           |
//+------------------------------------------------------------------+
int CKeyFinder::GetMinDimension(){return(MinDimension);};
//+------------------------------------------------------------------+
//| Method SetMinDimension                                           |
//+------------------------------------------------------------------+
void CKeyFinder::SetMinDimension(int temp_Val)
  {
   if(temp_Val>1) MinDimension=temp_Val;
   else
     {
      MessageBox("The set dimension is too low."+"\n"+"The default dimension of 5 will be used","Warning!",MB_OK+MB_ICONWARNING);
      MinDimension=5;
     };
  };
//+------------------------------------------------------------------+
//| Method GetMaxBars                                                |
//+------------------------------------------------------------------+
int CKeyFinder::GetMaxBars() {return(MaxBars);};
//+------------------------------------------------------------------+
//| Method SetMaxBars                                                |
//+------------------------------------------------------------------+
void CKeyFinder::SetMaxBars(int temp_Val)
  {
// Checking the availability of history for the set number of bars
   int SMaxBars=Bars(Symbol(),0);
   if(SMaxBars<temp_Val)
     {
      temp_Val=SMaxBars;// Setting the maximum available number of bars
      MessageBox("The MaxBars parameter is too high."+"\n"+"Only "+IntegerToString(temp_Val)+" bars will be used for calculation.","Warning!",MB_OK+MB_ICONWARNING);
     };

// Checking if the number of bars is not too low
   if(temp_Val<(2*MinDimension))
     {
      MessageBox("The set number of bars is too low."+"\n"+"The default number of 300 will be used","Warning!",MB_OK+MB_ICONWARNING);
      temp_Val=300;
     };
   MaxBars=temp_Val;
  };
//+------------------------------------------------------------------+
//| Method FindKeyPoints - Finding upper key points                  |
//+------------------------------------------------------------------+
void CKeyFinder::FindUpKeyPoints(int temp_iCod,MqlRates &temp_rates[])// The method receives an index of the maximum array element and the MqlRates array
  {
   int HD=1;   //initializing points dimensions
   for(int i=temp_iCod-MinDimension; i>(MinDimension-1); i--)// A loop from the last bar - MinDimension to the zero bar + MinDimension
     {
      HD=getHighDimension(temp_rates,i,temp_iCod);//Getting points dimensions
      if((HD>=MinDimension) || (HD==-1))
        {//Creating a mark if MinDimension condition is met
         string Ob_Name="KF_Label"+IntegerToString(i);
         if(HD!=-1)
           {
            ObjectCreate(0,Ob_Name,OBJ_TEXT,0,temp_rates[i].time,temp_rates[i].high);
            ObjectSetInteger(0,Ob_Name,OBJPROP_ANCHOR,0,ANCHOR_LOWER);
            ObjectSetString(0,Ob_Name,OBJPROP_TEXT,0,IntegerToString(HD));
            ObjectSetInteger(0,Ob_Name,OBJPROP_COLOR,clrRed);
           }
         else
           { //If the dimension can't be determined, use a ball mark
            ObjectCreate(0,Ob_Name,OBJ_ARROW,0,temp_rates[i].time,temp_rates[i].high);
            ObjectSetInteger(0,Ob_Name,OBJPROP_ARROWCODE,0,159);
            ObjectSetInteger(0,Ob_Name,OBJPROP_ANCHOR,0,ANCHOR_BOTTOM);
            ObjectSetInteger(0,Ob_Name,OBJPROP_COLOR,clrRed);
           };
        };
     };
  };
//+------------------------------------------------------------------+
//| Method FindLowKeyPoints - Finding lower key points               |
//+------------------------------------------------------------------+   
void CKeyFinder::FindLowKeyPoints(int temp_iCod,MqlRates &temp_rates[])// The method receives an index of the maximum array element and the MqlRates array
  {
   int LD=1;//initializing points dimensions
   bool iCreate;
   for(int i=temp_iCod-MinDimension; i>(MinDimension-1); i--)// A loop from the last bar - MinDimension to the zero bar + MinDimension
     {
      LD=getLowDimension(temp_rates,i,temp_iCod);
      if((LD>=MinDimension) || (LD==-1))
        {
         string Ob_Name="KF_Label"+IntegerToString(i)+"_1";//Avoiding the bars there Low and High can be key points
         if(LD!=-1)
           {
            iCreate=ObjectCreate(0,Ob_Name,OBJ_TEXT,0,temp_rates[i].time,temp_rates[i].low);
            if(iCreate)
              {
               ObjectSetInteger(0,Ob_Name,OBJPROP_ANCHOR,0,ANCHOR_UPPER);
               ObjectSetString(0,Ob_Name,OBJPROP_TEXT,0,IntegerToString(LD));
               ObjectSetInteger(0,Ob_Name,OBJPROP_COLOR,clrGreen);
              }
            else Comment("Cannot create the object");
           }
         else
           {
            iCreate=ObjectCreate(0,Ob_Name,OBJ_ARROW,0,temp_rates[i].time,temp_rates[i].low);
            if(iCreate)
              {
               ObjectSetInteger(0,Ob_Name,OBJPROP_ARROWCODE,0,159);
               ObjectSetInteger(0,Ob_Name,OBJPROP_ANCHOR,0,ANCHOR_TOP);
               ObjectSetInteger(0,Ob_Name,OBJPROP_COLOR,clrGreen);
              }
            else Comment("Cannot create the object");
           };
        };
     };
  };
//+------------------------------------------------------------------+
//| Method CleanChart - Clearing the chart from objects              |
//+------------------------------------------------------------------+   
int CKeyFinder::CleanChart(void)
  {
   string Label="KF_Label";
   int obj_total=ObjectsTotal(0,0,-1),n=0;
   for(int obj=obj_total-1; obj>=0; obj--) //Clearing the objects created by the script by the name mask
     {
      string objname=ObjectName(0,obj,0,-1);
      if(StringFind(objname,Label)>=0) ObjectDelete(0,objname);
      n++;
     }
   return(n);
  }
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CKeyFinder::CKeyFinder(){};
//+------------------------------------------------------------------+
//| Class destructor                                                 |
//+------------------------------------------------------------------+
CKeyFinder::~CKeyFinder(){};
//+---------------------------------------------------------------------+
