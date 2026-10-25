#property copyright "Copyright © 2012, File45"
#property link      "http: //codebase.mql4.com/en/author/file45"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| START: DEFAULT OPTIONS
//+------------------------------------------------------------------+
extern bool   Popup_Alert       = false;
extern bool   Sound_Alert       = false;
extern bool   Email_Alert       = false;
extern bool   Push_Notification = false;
extern int    Sound_Bite        = 1;
extern string New_Bar_Label     = "NB Alert";
extern color  Font_Color        = DodgerBlue;
extern int    Font_Size         = 11;
extern bool   Font_Bold         = true;
extern bool   Show_Font         = true;
extern int    Left_Right        = 25;
extern int    Up_Down           = 100;
extern int    Corner            = 1;
//+------------------------------------------------------------------+
//| END: DEFAULT OPTIONS
//+------------------------------------------------------------------+
string NBL, AF, TM;
string The_Sound;
datetime LastAlertTime;
//+------------------------------------------------------------------+
//| Init
//+------------------------------------------------------------------+
int init()
{
   if(Show_Font == true)
   {   
      if (Popup_Alert == true && Sound_Alert == True)
      {
         Alert("Pop Up Alert will kill Sound_Alert Alert");
      }            
      if (Popup_Alert == true && Sound_Alert == True && Email_Alert == true && Push_Notification == true) //1: TTTT
      {
         NBL = New_Bar_Label + " : AMP";
      }  
      else if (Popup_Alert == true && Sound_Alert == True && Email_Alert == true && Push_Notification == false) //2: TTTF
      {
         NBL = New_Bar_Label + " : AM";
      }
      else if (Popup_Alert == true && Sound_Alert == True && Email_Alert == false && Push_Notification == true) //3: TTFT
      {
         NBL = New_Bar_Label + " : AP";
      }     
      else if (Popup_Alert == true && Sound_Alert == True && Email_Alert == false && Push_Notification == false) //4: TTFF
      {
         NBL = New_Bar_Label + " : A";
      }     
      else if (Popup_Alert == true && Sound_Alert == false && Email_Alert == true && Push_Notification == true) //5: TFTT
      {
         NBL = New_Bar_Label + " : AMP";
      } 
      else if (Popup_Alert == true && Sound_Alert == false && Email_Alert == true && Push_Notification == false) //6: TFTF
      {
         NBL = New_Bar_Label + " : AM";
      }
      else if (Popup_Alert == true && Sound_Alert == false && Email_Alert == false && Push_Notification == true) //7: TFFT
      {
         NBL = New_Bar_Label + " : AP";
      }   
      else if (Popup_Alert == true && Sound_Alert == false && Email_Alert == false && Push_Notification == false) //8: TFFF
      {
         NBL = New_Bar_Label + " : A";
      } 
      else if (Popup_Alert == false && Sound_Alert == true && Email_Alert == true && Push_Notification == true) //9: FTTT
      {
         NBL = New_Bar_Label + " : SMP";
      }   
      else if (Popup_Alert == false && Sound_Alert == true && Email_Alert == true && Push_Notification == false) //10: FTTF
      {
         NBL = New_Bar_Label + " : SM";
      }                             
      else if (Popup_Alert == false && Sound_Alert == true && Email_Alert == false && Push_Notification == true) //11: FTFT
      {
         NBL = New_Bar_Label + " : SP";
      } 
      else if (Popup_Alert == false && Sound_Alert == true && Email_Alert == false && Push_Notification == false) //12: FTFF
      {
         NBL = New_Bar_Label + " : S";
      }
      else if (Popup_Alert == false && Sound_Alert == false && Email_Alert == true && Push_Notification == true) //13: FFTT
      {
         NBL = New_Bar_Label + " : MP";
      }               
      else if (Popup_Alert == false && Sound_Alert == false && Email_Alert == true && Push_Notification == false) //14: FFTF
      {
         NBL = New_Bar_Label + " : M";
      }     
      else if (Popup_Alert == false && Sound_Alert == false && Email_Alert == false && Push_Notification == true) //15: FFFT
      {
        NBL = New_Bar_Label + " : P";
      }     
      else if (Popup_Alert == false && Sound_Alert == false && Email_Alert == false && Push_Notification == false) //14: FFFF
      {
         NBL = New_Bar_Label + " : x";
      }    
   }   
   
   switch(Period())
   {    
      case 1:     TM = "M1";  break;
      case 2:     TM = "M2";  break;
      case 3:     TM = "M3";  break;
      case 4:     TM = "M4";  break;
      case 5:     TM = "M5";  break;
      case 6:     TM = "M6";  break;
      case 7:     TM = "M7";  break;
      case 8:     TM = "M8";  break;
      case 9:     TM = "M9";  break;
      case 10:    TM = "M10"; break;
      case 11:    TM = "M11"; break;
      case 12:    TM = "M12"; break;
      case 13:    TM = "M13"; break;
      case 14:    TM = "M14"; break;
      case 15:    TM = "M15"; break;
      case 20:    TM = "M20"; break;
      case 25:    TM = "M25"; break;
      case 30:    TM = "M30"; break;
      case 40:    TM = "M40"; break;
      case 45:    TM = "M45"; break;
      case 50:    TM = "M50"; break;
      case 60:    TM = "H1";  break;
      case 120:   TM = "H2";  break;
      case 180:   TM = "H3";  break;
      case 240:   TM = "H4";  break;
      case 300:   TM = "H5";  break;
      case 360:   TM = "H6";  break;
      case 420:   TM = "H7";  break;
      case 480:   TM = "H8";  break;
      case 540:   TM = "H9";  break;
      case 600:   TM = "H10"; break;
      case 660:   TM = "H11"; break;
      case 720:   TM = "H12"; break;
      case 1440:  TM = "D1";  break;
      case 10080: TM = "W1";  break;
      case 43200: TM = "M4";  break;  
   }        
   
   switch(Sound_Bite)
   {
      case 0:  The_Sound = "alert.wav"; break;
      case 1:  The_Sound = "alert.wav"; break;
      case 2:  The_Sound = "SB2.wav";   break;
      case 3:  The_Sound = "SB3.wav";   break;
      case 4:  The_Sound = "SB4.wav";   break;
      case 5:  The_Sound = "SB5.wav";   break;
      case 6:  The_Sound = "SB6.wav";   break;
      case 7:  The_Sound = "SB7.wav";   break;
      case 8:  The_Sound = "SB8.wav";   break;
      default: The_Sound = "alert.wav";
   }
   
   LastAlertTime=TimeCurrent();
   
return(0);
}
//+------------------------------------------------------------------+
//| Deinit
//+------------------------------------------------------------------+
int deinit()
{
   ObjectDelete("NB");

return(0);
}
//+------------------------------------------------------------------+
//| Start
//+------------------------------------------------------------------+
int start()
{        
   switch(Font_Bold)
   {
      case 1: AF = "Arial Bold"; break;
      case 0: AF = "Arial";      break;
   } 
     
   ObjectCreate("NB", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("NB", NBL, Font_Size, AF, Font_Color);
   ObjectSet("NB", OBJPROP_CORNER, Corner);
   ObjectSet("NB", OBJPROP_XDISTANCE, Left_Right);
   ObjectSet("NB", OBJPROP_YDISTANCE, Up_Down);
    
// ALERTS
    
   static datetime tmp;
   // if (tmp != Time[0])
   if (tmp < Time [0])
   {
      tmp = Time [0];
       
      if (Popup_Alert == true && (LastAlertTime<Time[0]))
      { 
         Alert("New Bar  -  ", Symbol(), "  -  " + TM + "  -  " + AccountCompany()); 
         LastAlertTime=TimeCurrent();  
      }
  
      if (Sound_Alert == true)
      {
         PlaySound(The_Sound);
      }
      
      if (Email_Alert == true)
      {
         SendMail("New Bar - " + Symbol() + " - " + AccountCompany(),
                  //"New Bar :  " + "Alert  \n" +
                  "NEW BAR ALERT" + "\n" +
                  "--------------------" + "\n" +
                  "Symbol : " + " " + Symbol() + " \n" +
                  "Period : " + " " + TM + " \n" +
                  "Time and Date : " + TimeToStr(TimeCurrent(), TIME_SECONDS)+ "  " + TimeToStr(TimeCurrent(), TIME_DATE) + " \n" +         
                  "Broker : " + " " + AccountCompany() + "\n" +
                  "Account # : " + " " + AccountNumber());                     
      }

      if (Push_Notification == true)
      {
         SendNotification(Symbol() + " " + TM + "\n" +
         "New Bar: " + TimeToStr(TimeCurrent(), TIME_SECONDS)+ "  " + TimeToStr(TimeCurrent(), TIME_DATE) + "  " + AccountCompany()); 
      }
   }   
return(0);
}

/* bool NewBar_1()
 {
  static datetime tmp;
   // if (tmp != Time[0])
   if (tmp < Time [0])
   {
      tmp = Time [0]; 
      return(true);     
   }
  else
    {
      return(false);
   }  
}

/*bool NewBa_2()
{
   static int PrevTime=0;
   if (PrevTime==Time[0]) 
   {
      return(false);
   )
   else
   {
      return(true);
   }
}*/


