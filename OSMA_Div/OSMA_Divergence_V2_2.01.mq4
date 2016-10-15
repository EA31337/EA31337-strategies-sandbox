//+------------------------------------------------------------------+
//|                                          FX5_Divergence_V2.1.mq4 |
//|                                                              FX5 |
//|                                                    hazem@uk2.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, FX5"
#property link      "hazem@uk2.net"
//----
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 DimGray
#property indicator_color2 DarkSlateGray
#property indicator_color3 Green
#property indicator_color4 Red
//---- input parameters
extern string    separator1 = "*** OSMA Settings ***";
extern int       fastEMA = 12;
extern int       slowEMA = 26;
extern int       signal = 9;
extern string    separator2 = "*** Indicator Settings ***";
extern bool      drawDivergenceLines = true;
extern string ___                       = "Divergence Alerts";
extern bool   divergenceAlert           = true;
extern bool   divergenceAlertsMessage   = true;
extern bool   divergenceAlertsSound     = true;
extern bool   divergenceAlertsNotify    = false;
extern bool   divergenceAlertsEmail     = false;
extern string divergenceAlertsSoundName = "alert1.wav";
//---- buffers
double upOsMA[];
double downOsMA[];
double bullishDivergence[];
double bearishDivergence[];
double OsMA[];
//----
static datetime lastAlertTimePk; // last alert for a Peak
static datetime lastAlertTimeTr; // last alert for a Trough
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexStyle(4, DRAW_NONE);
//----   
   SetIndexBuffer(0, upOsMA);
   SetIndexBuffer(1, downOsMA);
   SetIndexBuffer(2, bullishDivergence);
   SetIndexBuffer(3, bearishDivergence);
   SetIndexBuffer(4, OsMA);
//----   
   SetIndexArrow(2, 233);
   SetIndexArrow(3, 234);
//----
   IndicatorDigits(Digits + 2);
   IndicatorShortName("OSMA-Divergence_v2.2(" + fastEMA + "," + 
                      slowEMA + "," + signal + ")");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       if(StringSubstr(label, 0, 14) != "DivergenceLine")
           continue;
       ObjectDelete(label);   
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int countedBars = IndicatorCounted();
   if(countedBars < 0)
       countedBars = 0;
   CalculateIndicator(countedBars);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateIndicator(int countedBars)
  {
   for(int i = Bars - countedBars; i >= 0; i--)
     {
      CalculateOsMA(i);
      CatchBullishDivergence(i + 2);
      CatchBearishDivergence(i + 2);
     }              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateOsMA(int i)
  {
   OsMA[i] = iOsMA(NULL, 0, fastEMA, slowEMA, signal, PRICE_CLOSE, i);
//----
   if(OsMA[i] > 0)
     {
       upOsMA[i] = OsMA[i];
       downOsMA[i] = 0;
     }
   else 
       if(OsMA[i] < 0)
         {
           downOsMA[i] = OsMA[i];
           upOsMA[i] = 0;   
         }
       else
         {
           upOsMA[i] = 0;
           downOsMA[i] = 0;   
         }         
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBullishDivergence(int shift)
  {
   if(IsIndicatorTrough(shift) == false)
       return;
   int currentTrough = shift;
   int lastTrough = GetIndicatorLastTrough(shift);
   if(OsMA[currentTrough] > OsMA[lastTrough] && Low[currentTrough] < Low[lastTrough])
     {
      bullishDivergence[currentTrough] = OsMA[currentTrough];
      if(drawDivergenceLines == true)
        {
          DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], Low[currentTrough], 
                             Low[lastTrough], Green, STYLE_SOLID);
          DrawIndicatorTrendLine(Time[currentTrough], Time[lastTrough], OsMA[currentTrough],
                                 OsMA[lastTrough], Green, STYLE_SOLID);
        }
      if(divergenceAlert == true)
          DisplayAlert("Classical bullish divergence", currentTrough);  // peak = False
     }
   if(OsMA[currentTrough] < OsMA[lastTrough] && Low[currentTrough] > Low[lastTrough])
     {
      bullishDivergence[currentTrough] = OsMA[currentTrough];
      if(drawDivergenceLines == true)
        {
          DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], Low[currentTrough], 
                             Low[lastTrough], Green, STYLE_DOT);
          DrawIndicatorTrendLine(Time[currentTrough], Time[lastTrough], OsMA[currentTrough],
                                 OsMA[lastTrough], Green, STYLE_DOT);
        }
      if(divergenceAlert == true)
          DisplayAlert("Hidden bullish divergence", currentTrough);   // peak = False
     }      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBearishDivergence(int shift)
  {
   if(IsIndicatorPeak(shift) == false)
       return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift);
   
   if(OsMA[currentPeak] < OsMA[lastPeak] && High[currentPeak] > High[lastPeak])
     {
       bearishDivergence[currentPeak] = OsMA[currentPeak];
       if(drawDivergenceLines == true)
         {
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], High[currentPeak], 
                              High[lastPeak], Red, STYLE_SOLID);
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], OsMA[currentPeak],
                                  OsMA[lastPeak], Red, STYLE_SOLID);
         }
       if(divergenceAlert == true)
           DisplayAlert("Classical bearish divergence", currentPeak);  // peak = True
     }
   if(OsMA[currentPeak] > OsMA[lastPeak] && High[currentPeak] < High[lastPeak])
     {
       bearishDivergence[currentPeak] = OsMA[currentPeak];
       if(drawDivergenceLines == true)
         {
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], High[currentPeak], 
                              High[lastPeak], Red, STYLE_DOT);
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], OsMA[currentPeak],
                                  OsMA[lastPeak], Red, STYLE_DOT);
         }
       if(divergenceAlert == true)
           DisplayAlert("Hidden bearish divergence", currentPeak);   // peak = True
     }   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorPeak(int shift)
  {
   if(OsMA[shift] > 0 && OsMA[shift] > OsMA[shift+1] && OsMA[shift] > OsMA[shift-1])
     {
       for(int i = shift + 1; i < Bars; i++)
         {
           if(OsMA[i] < 0)
              return(true);
           if(OsMA[i] > OsMA[shift])
              break;            
         }
     }   
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorTrough(int shift)
  {
   if(OsMA[shift] < 0 && OsMA[shift] < OsMA[shift+1] && OsMA[shift] < OsMA[shift-1])
     {
       for(int i = shift + 1; i < Bars; i++)
         {
           if(OsMA[i] > 0)
               return(true);
           if(OsMA[i] < OsMA[shift])
               break;            
         }
     }   
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak(int shift)
  {
    for(int i = shift + 5; i < Bars; i++)
      {
        if(OsMA[i] >= OsMA[i+1] && OsMA[i] > OsMA[i+2] &&
           OsMA[i] >= OsMA[i-1] && OsMA[i] > OsMA[i-2])
            return(i);
      }
    return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastTrough(int shift)
  {  
    for(int i = shift + 5; i < Bars; i++)
      {
        if(OsMA[i] <= OsMA[i+1] && OsMA[i] < OsMA[i+2] &&
           OsMA[i] <= OsMA[i-1] && OsMA[i] < OsMA[i-2])
            return(i);
      }
    return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void DisplayAlert(string doWhat, int shift)
{
    string dmessage;
    static datetime lastAlertTime;
    if(shift <= 2 && Time[0] != lastAlertTime)
    {
      dmessage =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," OsMa ",doWhat);
          if (divergenceAlertsMessage) Alert(dmessage);
          if (divergenceAlertsNotify)  SendNotification(dmessage);
          if (divergenceAlertsEmail)   SendMail(StringConcatenate(Symbol()," OsMa "),dmessage);
          if (divergenceAlertsSound)   PlaySound(divergenceAlertsSoundName); 
          lastAlertTime = Time[0];
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, double style)
  {
   string label = "DivergenceLine2.1# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1, 
                            double y2, color lineColor, double style)
  {
   int indicatorWindow = WindowFind("OSMA-Divergence_v2.2(" + fastEMA + 
                                    "," + slowEMA + "," + signal + ")");
   if(indicatorWindow < 0)
       return;
   string label = "DivergenceLine2.1$# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+



