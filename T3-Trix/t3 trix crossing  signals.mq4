//+---------------------------------------------------------+
//| T3 Trix crossing  signals.mq4 
//|
//| Perky..
//+------------------------------------------------------------------+
#property  copyright "Author - Perky Aint no Porky"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LightBlue
#property indicator_width1 3
#property indicator_color2 Red
#property indicator_width2 3

//---- input parameters

extern int       A_t3_period=18; 
extern int       num_bars=350; 
extern int       is_A_open_price=0; 
extern int       B_t3_period_ac=10; 
extern int       diferential=0; 
extern double    hot=0.7; 
extern int CountBars=350;
extern bool UseAlert=True;

//---- buffers
double val1[];
double val2[];
double mtfstochs,mtfstochsb4;
double mtfstochs1,mtfstochs1b4;
int Timer;
string UD="";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,108);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,108);
   SetIndexBuffer(0,val1);
   SetIndexBuffer(1,val2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| AltrTrend_Signal_v2_2                                            |
//+------------------------------------------------------------------+
int start()
  {   
  // if (CountBars>=500) CountBars=500;
  // SetIndexDrawBegin(0,500-CountBars);
  // SetIndexDrawBegin(1,500-CountBars);
  int i,shift,counted_bars=IndicatorCounted();


   //---- check for possible errors
  // if(counted_bars<0) return(-1);

   //---- initial zero
  // if(counted_bars<1)
   //  {
    //  for(i=1;i<=CountBars;i++) val1[CountBars-i]=0.0;
    //  for(i=1;i<=CountBars;i++) val2[CountBars-i]=0.0;
    // } 

for ( shift = CountBars; shift>=0; shift--) 
{ 

   
     mtfstochs= 
     iCustom(Symbol(),Period(),"T3 -trix",A_t3_period,num_bars,is_A_open_price,B_t3_period_ac,diferential,hot,0,shift+0);
     mtfstochsb4=
     iCustom(Symbol(),Period(),"T3 -trix",A_t3_period,num_bars,is_A_open_price,B_t3_period_ac,diferential,hot,0,shift+1);

     mtfstochs1= 
          iCustom(Symbol(),Period(),"T3 -trix",A_t3_period,num_bars,is_A_open_price,B_t3_period_ac,diferential,hot,1,shift+0);

     mtfstochs1b4=
         iCustom(Symbol(),Period(),"T3 -trix",A_t3_period,num_bars,is_A_open_price,B_t3_period_ac,diferential,hot,1,shift+1);
     
//Comment ( "mtfstochs=",mtfstochs,"mtfstochsb4=",mtfstochsb4,"\nmtfstochs1=",mtfstochs1,"mtfstochs1b4=",mtfstochs1b4);
 	   val1[shift]=0;
		val2[shift]=0;

//if ( TTb4>TT1b4 && TT<TT1 ) 
 if ( mtfstochsb4<mtfstochs1b4 && mtfstochs>mtfstochs1)

{
	val2[shift]=High[shift]+6*Point;
	if (shift < 2 )
	
	{
	   UD="DOWN.";
		DoAlert(UD);
	}

}
// if ( TTb4<TT1b4 && TT>TT1) 
if  (mtfstochsb4>mtfstochs1b4 && mtfstochs<mtfstochs1)

{
		val1[shift]=Low[shift]-6*Point;
	
	 if (shift < 2 )
  { 
  UD=" UP.";	
  DoAlert(UD);
  }
}



}
   //return(0);
  }
 
void DoAlert(string UD)
{
   if (!NewBar() || !UseAlert)
      return;
     Alert (Symbol()," ",Period(),"MTF STOCHS cross ",UD);

}


  bool NewBar()
{
   static datetime dt  = 0;
   if (dt != Time[0])
   {
      dt = Time[0];
      return(true);
   }
  
}

//+------------------------------------------------------------------+