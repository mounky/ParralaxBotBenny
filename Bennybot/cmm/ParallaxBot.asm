 GNU assembler version 2.21 (propeller-elf)
	 using BFD version (propellergcc_v1_0_0_2408) 2.21.
 options passed	: -lmm -cmm -ahdlnsg=cmm/ParallaxBot.asm 
 input file    	: C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s
 output file   	: cmm/ParallaxBot.o
 target        	: propeller-parallax-elf
 time stamp    	: 

   1              		.text
   2              	.Ltext0
   3              		.global	_Step
   4              	_Step
   5              	.LFB2
   6              		.file 1 "ParallaxBot.c"
   1:ParallaxBot.c **** /**
   2:ParallaxBot.c **** * This is the main twitchBot program file.
   3:ParallaxBot.c **** */
   4:ParallaxBot.c **** #include "simpletools.h"
   5:ParallaxBot.c **** #include "fdserial.h"
   6:ParallaxBot.c **** #include "abdrive.h"
   7:ParallaxBot.c **** #include "ping.h"
   8:ParallaxBot.c **** #include "servo.h"
   9:ParallaxBot.c **** #include "ws2812.h"
  10:ParallaxBot.c **** 
  11:ParallaxBot.c **** 
  12:ParallaxBot.c **** #define LED_PIN     8
  13:ParallaxBot.c **** #define LED_COUNT   18
  14:ParallaxBot.c **** 
  15:ParallaxBot.c **** void Step(int leftSpeed, int rightSpeed);
  16:ParallaxBot.c **** void Stop(void);
  17:ParallaxBot.c **** void led_blink();
  18:ParallaxBot.c **** void eyes_blink();
  19:ParallaxBot.c **** void motor_controller();
  20:ParallaxBot.c **** void neopixel_controller();
  21:ParallaxBot.c **** void set_motor_controller(int leftSpeed, int rightSpeed);
  22:ParallaxBot.c **** void set_neopixel_group(uint32_t color);
  23:ParallaxBot.c **** void set_neopixel(uint8_t pixel_num, uint32_t color);
  24:ParallaxBot.c **** void pause(int ms);
  25:ParallaxBot.c **** 
  26:ParallaxBot.c **** uint32_t ledColors[LED_COUNT];
  27:ParallaxBot.c **** ws2812_t driver;
  28:ParallaxBot.c **** int ticks_per_ms;
  29:ParallaxBot.c **** uint8_t brightness = 255;
  30:ParallaxBot.c **** uint32_t eye_color = 0x0F0F0F;
  31:ParallaxBot.c ****   
  32:ParallaxBot.c **** 
  33:ParallaxBot.c **** fdserial *term; //enables full-duplex serilization of the terminal (In otherwise, 2 way signals bet
  34:ParallaxBot.c **** int ticks = 12; //each tick makes the wheel move by 3.25mm, 64 ticks is a full wheel rotation (or 2
  35:ParallaxBot.c **** int turnTick = 6; //Turning is at half the normal rate
  36:ParallaxBot.c **** int maxSpeed = 128; //the maximum amount of ticks the robot can travel with the "drive_goto" functi
  37:ParallaxBot.c **** int minSpeed = 2; //the lowest amount of ticks the robot can travel with the "drive_goto" function
  38:ParallaxBot.c **** int maxTurnSpeed = 64;
  39:ParallaxBot.c **** int minTurnSpeed = 2;
  40:ParallaxBot.c **** int gripDegree = 0; //Angle of the servo that controls the gripper
  41:ParallaxBot.c **** int gripState = -1;
  42:ParallaxBot.c **** int commandget = 0;
  43:ParallaxBot.c **** volatile int current_leftspd = 0;
  44:ParallaxBot.c **** volatile int current_rightspd = 0;
  45:ParallaxBot.c **** volatile int motor_flag = 0;
  46:ParallaxBot.c **** 
  47:ParallaxBot.c **** 
  48:ParallaxBot.c **** 
  49:ParallaxBot.c **** 
  50:ParallaxBot.c **** int defaultStraightSpeed = 60;
  51:ParallaxBot.c **** int defaultTurnSpeed = 30;
  52:ParallaxBot.c **** 
  53:ParallaxBot.c **** int pingDistance;
  54:ParallaxBot.c **** 
  55:ParallaxBot.c **** //int verbose = 1;
  56:ParallaxBot.c **** 
  57:ParallaxBot.c **** 
  58:ParallaxBot.c **** int main()
  59:ParallaxBot.c **** {
  60:ParallaxBot.c **** 	//access the simpleIDE terminal
  61:ParallaxBot.c **** 	simpleterm_close();
  62:ParallaxBot.c **** 	//set full-duplex serialization for the terminal
  63:ParallaxBot.c **** 	term = fdserial_open(31, 30, 0, 9600);
  64:ParallaxBot.c ****  
  65:ParallaxBot.c ****    ticks_per_ms = CLKFREQ / 1000;
  66:ParallaxBot.c ****   
  67:ParallaxBot.c **** 	cog_run(motor_controller,128);
  68:ParallaxBot.c ****     // load the LED driver
  69:ParallaxBot.c ****     if (ws2812b_init(&driver) < 0)
  70:ParallaxBot.c ****        return 1;
  71:ParallaxBot.c ****        pause(500);
  72:ParallaxBot.c ****    eyes_blink();
  73:ParallaxBot.c ****        
  74:ParallaxBot.c **** 
  75:ParallaxBot.c **** 	char c;
  76:ParallaxBot.c **** 
  77:ParallaxBot.c **** 	//servo_angle(16, gripDegree); //Orient gripper to half open on start
  78:ParallaxBot.c **** 	
  79:ParallaxBot.c ****  //pause(3000);
  80:ParallaxBot.c ****   
  81:ParallaxBot.c ****   int inputStringLength = 20;
  82:ParallaxBot.c **** 	
  83:ParallaxBot.c **** //  int i = 0;
  84:ParallaxBot.c **** //  while(i<=inputStingLength)
  85:ParallaxBot.c **** //  {
  86:ParallaxBot.c ****   char inputString[inputStringLength];
  87:ParallaxBot.c **** //  i++;	
  88:ParallaxBot.c **** //  }
  89:ParallaxBot.c **** 	int sPos = 0;
  90:ParallaxBot.c **** 
  91:ParallaxBot.c **** 	while (1)
  92:ParallaxBot.c **** 	{
  93:ParallaxBot.c **** 
  94:ParallaxBot.c **** 
  95:ParallaxBot.c **** 		if (fdserial_rxReady(term)!=0)
  96:ParallaxBot.c **** 		{
  97:ParallaxBot.c **** 			c = fdserial_rxChar(term); //Get the character entered from the terminal
  98:ParallaxBot.c **** 
  99:ParallaxBot.c **** 			if (c != -1) {
 100:ParallaxBot.c **** 				dprint(term, "%d", (int)c);
 101:ParallaxBot.c **** 				if ((int)c == 13 || (int)c == 10) {
 102:ParallaxBot.c **** 					dprint(term, "received line:");
 103:ParallaxBot.c **** 					dprint(term, inputString);
 104:ParallaxBot.c **** 					dprint(term, "\n");
 105:ParallaxBot.c **** 					if (strcmp(inputString, "l") == 0) {
 106:ParallaxBot.c **** 						dprint(term, "left");
 107:ParallaxBot.c **** 						set_motor_controller(-defaultTurnSpeed,defaultTurnSpeed);
 108:ParallaxBot.c **** 					}          
 109:ParallaxBot.c **** 					if (strcmp(inputString, "r") == 0) {
 110:ParallaxBot.c **** 						dprint(term, "right");
 111:ParallaxBot.c **** 						set_motor_controller(defaultTurnSpeed, -defaultTurnSpeed);
 112:ParallaxBot.c **** 					}          
 113:ParallaxBot.c **** 					if (strcmp(inputString, "f") == 0) {
 114:ParallaxBot.c **** 						dprint(term, "forward");
 115:ParallaxBot.c **** 						set_motor_controller(defaultStraightSpeed, defaultStraightSpeed);
 116:ParallaxBot.c **** 					}          
 117:ParallaxBot.c **** 					if (strcmp(inputString, "b") == 0) {
 118:ParallaxBot.c **** 						dprint(term, "back");
 119:ParallaxBot.c **** 						set_motor_controller(-defaultStraightSpeed, -defaultStraightSpeed);
 120:ParallaxBot.c **** 					}
 121:ParallaxBot.c **** 					if (strcmp(inputString, "l_up") == 0) {
 122:ParallaxBot.c **** 						dprint(term, "left_stop");
 123:ParallaxBot.c **** 						Stop();
 124:ParallaxBot.c **** 					}          
 125:ParallaxBot.c **** 					if (strcmp(inputString, "r_up") == 0) {
 126:ParallaxBot.c **** 						dprint(term, "right_stop");
 127:ParallaxBot.c **** 						Stop();
 128:ParallaxBot.c **** 					}          
 129:ParallaxBot.c **** 					if (strcmp(inputString, "f_up") == 0) {
 130:ParallaxBot.c **** 						dprint(term, "forward_stop");
 131:ParallaxBot.c **** 						Stop();
 132:ParallaxBot.c **** 					}          
 133:ParallaxBot.c **** 					if (strcmp(inputString, "b_up") == 0) {
 134:ParallaxBot.c **** 						dprint(term, "back_stop");
 135:ParallaxBot.c **** 						Stop();
 136:ParallaxBot.c **** 					}
 137:ParallaxBot.c **** 
 138:ParallaxBot.c ****      
 139:ParallaxBot.c ****      				if (strcmp(inputString, "debug2") == 0) {
 140:ParallaxBot.c ****                int leftDist, rightDist;  
 141:ParallaxBot.c ****                drive_getTicksCalc	(&leftDist,&rightDist);
 142:ParallaxBot.c ****                dprint(term, "Left Want: ");
 143:ParallaxBot.c **** 						dprint(term, "%d\n",&leftDist );
 144:ParallaxBot.c ****                 dprint(term, "Right Want:");
 145:ParallaxBot.c ****       	        dprint(term, "%d\n",&rightDist );
 146:ParallaxBot.c ****                drive_getTicks	(&leftDist,&rightDist);
 147:ParallaxBot.c ****                dprint(term, "Left Have: ");
 148:ParallaxBot.c **** 						dprint(term, "%d\n",&leftDist );
 149:ParallaxBot.c ****                 dprint(term, "Right Have:");
 150:ParallaxBot.c ****       	        dprint(term, "%d\n",&rightDist );
 151:ParallaxBot.c **** 					}
 152:ParallaxBot.c ****      
 153:ParallaxBot.c ****           		if (strncmp(inputString, "led",3) == 0) 
 154:ParallaxBot.c ****               { 
 155:ParallaxBot.c ****                char * pBeg = &inputString;
 156:ParallaxBot.c ****                char * pEnd;
 157:ParallaxBot.c ****                uint8_t pixel = strtol(pBeg+4, &pEnd,10);
 158:ParallaxBot.c ****                uint32_t color = strtol(pEnd, &pEnd,16);
 159:ParallaxBot.c ****                dprint(term,"%d\n",color);
 160:ParallaxBot.c ****                if((pixel < LED_COUNT)&&(color<=0xFFFFFF))
 161:ParallaxBot.c ****                set_neopixel(pixel,color); 
 162:ParallaxBot.c ****               }			
 163:ParallaxBot.c ****               
 164:ParallaxBot.c ****               	if (strncmp(inputString, "leds",4) == 0) 
 165:ParallaxBot.c ****               { 
 166:ParallaxBot.c ****                char * pBeg = &inputString;
 167:ParallaxBot.c ****                char * pEnd;
 168:ParallaxBot.c ****                uint32_t color = strtol(pBeg+5, &pEnd,16);
 169:ParallaxBot.c ****                dprint(term,"%d\n",color);
 170:ParallaxBot.c ****                if((color<=0xFFFFFF))
 171:ParallaxBot.c ****                set_neopixel_group(color); 
 172:ParallaxBot.c ****               }					
 173:ParallaxBot.c **** 					sPos = 0;
 174:ParallaxBot.c **** 					inputString[0] = 0; // clear string
 175:ParallaxBot.c **** 				} else if (sPos < inputStringLength - 1) {
 176:ParallaxBot.c **** 					// record next character
 177:ParallaxBot.c **** 					inputString[sPos] = c;
 178:ParallaxBot.c **** 					sPos += 1;
 179:ParallaxBot.c **** 					inputString[sPos] = 0; // make sure last element of string is 0
 180:ParallaxBot.c **** 					dprint(term, inputString);
 181:ParallaxBot.c **** 					dprint(term, " ok \n");
 182:ParallaxBot.c **** 				}  
 183:ParallaxBot.c **** 			}            
 184:ParallaxBot.c **** 		}      
 185:ParallaxBot.c **** 	}   
 186:ParallaxBot.c **** }
 187:ParallaxBot.c **** void Step(int leftSpeed, int rightSpeed)
 188:ParallaxBot.c **** {
   7              		.loc 1 188 0
   8              	.LVL0
   9 0000 031F     		lpushm	#16+15
  10              	.LCFI0
 189:ParallaxBot.c **** 	drive_speed(leftSpeed, rightSpeed);
  11              		.loc 1 189 0
  12 0002 060000   		lcall	#_drive_speed
  13              	.LVL1
 190:ParallaxBot.c **** }  
  14              		.loc 1 190 0
  15 0005 051F     		lpopret	#16+15
  16              	.LFE2
  17              		.global	_set_motor_controller
  18              	_set_motor_controller
  19              	.LFB3
 191:ParallaxBot.c **** 
 192:ParallaxBot.c **** void set_motor_controller(int leftSpeed, int rightSpeed)
 193:ParallaxBot.c **** {
  20              		.loc 1 193 0
  21              	.LVL2
 194:ParallaxBot.c **** 	current_leftspd =leftSpeed;
  22              		.loc 1 194 0
  23 0007 670000   		mviw	r7,#_current_leftspd
 195:ParallaxBot.c **** 	current_rightspd = rightSpeed;
 196:ParallaxBot.c **** 	motor_flag = 1;
  24              		.loc 1 196 0
  25 000a A601     		mov	r6, #1
 194:ParallaxBot.c **** 	current_leftspd =leftSpeed;
  26              		.loc 1 194 0
  27 000c 107F     		wrlong	r0, r7
 195:ParallaxBot.c **** 	current_rightspd = rightSpeed;
  28              		.loc 1 195 0
  29 000e 670000   		mviw	r7,#_current_rightspd
  30 0011 117F     		wrlong	r1, r7
  31              		.loc 1 196 0
  32 0013 670000   		mviw	r7,#_motor_flag
  33 0016 167F     		wrlong	r6, r7
 197:ParallaxBot.c **** }  
  34              		.loc 1 197 0
  35 0018 02       		lret
  36              	.LFE3
  37              		.global	_Stop
  38              	_Stop
  39              	.LFB4
 198:ParallaxBot.c **** 
 199:ParallaxBot.c **** void Stop(void)
 200:ParallaxBot.c **** {
  40              		.loc 1 200 0
  41 0019 031F     		lpushm	#16+15
  42              	.LCFI1
 201:ParallaxBot.c **** 	//drive_feedback(0);
 202:ParallaxBot.c ****   //drive_close();
 203:ParallaxBot.c ****   drive_speed(0, 0);
  43              		.loc 1 203 0
  44 001b B0       		mov	r0, #0
  45 001c B1       		mov	r1, #0
  46 001d 060000   		lcall	#_drive_speed
 204:ParallaxBot.c **** 
 205:ParallaxBot.c **** }  
  47              		.loc 1 205 0
  48 0020 051F     		lpopret	#16+15
  49              	.LFE4
  50              		.global	_motor_controller
  51              	_motor_controller
  52              	.LFB6
 206:ParallaxBot.c **** 
 207:ParallaxBot.c **** void led_blink()                            // Blink function for other cog
 208:ParallaxBot.c **** {
 209:ParallaxBot.c **** 	while(1)                              // Endless loop for other cog
 210:ParallaxBot.c **** 	{
 211:ParallaxBot.c **** 		high(26);                           // P26 LED on
 212:ParallaxBot.c **** 		pause(1000);                         // ...for 0.1 seconds
 213:ParallaxBot.c **** 		low(26);                            // P26 LED off
 214:ParallaxBot.c **** 		pause(1000);                         // ...for 0.1 seconds
 215:ParallaxBot.c **** 	}
 216:ParallaxBot.c **** }
 217:ParallaxBot.c **** 
 218:ParallaxBot.c **** void motor_controller()
 219:ParallaxBot.c **** {
  53              		.loc 1 219 0
  54              	.LVL3
  55 0022 035B     		lpushm	#(5<<4)+11
  56              	.LCFI2
 220:ParallaxBot.c **** 	uint32_t last_ms = 0;
 221:ParallaxBot.c **** 	uint32_t current_ms = 0;
 222:ParallaxBot.c **** 	uint32_t wait_ms = 10;
 223:ParallaxBot.c **** 	uint32_t clk_wait = 80000*wait_ms;
 224:ParallaxBot.c **** 	uint32_t timeout_timer = 0;
  57              		.loc 1 224 0
  58 0024 BC       		mov	r12, #0
 220:ParallaxBot.c **** 	uint32_t last_ms = 0;
  59              		.loc 1 220 0
  60 0025 B7       		mov	r7, #0
 225:ParallaxBot.c **** 	uint32_t timeout_ms = 80000*500;
 226:ParallaxBot.c **** 	while(1)
 227:ParallaxBot.c **** 	{
 228:ParallaxBot.c **** 
 229:ParallaxBot.c **** 		current_ms = CNT;  
 230:ParallaxBot.c **** 		if(current_ms-last_ms >= clk_wait )
  61              		.loc 1 230 0
  62 0026 5BFF340C 		mvi	r11,#799999
  62      00
 231:ParallaxBot.c **** 		{            
 232:ParallaxBot.c **** 			last_ms = current_ms;
 233:ParallaxBot.c **** 			if(motor_flag == 1) 
  63              		.loc 1 233 0
  64 002b 6D0000   		mviw	r13,#_motor_flag
  65 002e 7F02     		brs	#.L11
  66              	.LVL4
  67              	.L8
 229:ParallaxBot.c **** 		current_ms = CNT;  
  68              		.loc 1 229 0
  69 0030 0A7E     		mov	r7, r14
  70              	.LVL5
  71              	.L11
  72 0032 F2001CA0 		mov	r14, CNT
  73              	.LVL6
 230:ParallaxBot.c **** 		if(current_ms-last_ms >= clk_wait )
  74              		.loc 1 230 0
  75 0036 D66E71   		xmov	r6,r14 sub r6,r7
  76 0039 16B3     		cmp	r6, r11 wz,wc
  77 003b 7EF5     		IF_BE	brs	#.L11
  78              	.LVL7
  79              		.loc 1 233 0
  80 003d 17DD     		rdlong	r7, r13
  81 003f 2712     		cmps	r7, #1 wz,wc
  82 0041 7512     		IF_NE	brs	#.L7
 234:ParallaxBot.c **** 			{
 235:ParallaxBot.c **** 				Step(current_leftspd,current_rightspd);
  83              		.loc 1 235 0
  84 0043 670000   		mviw	r7,#_current_leftspd
 229:ParallaxBot.c **** 		current_ms = CNT;  
  85              		.loc 1 229 0
  86 0046 0ACE     		mov	r12, r14
  87              	.LVL8
  88              		.loc 1 235 0
  89 0048 107D     		rdlong	r0, r7
  90 004a 670000   		mviw	r7,#_current_rightspd
  91 004d 117D     		rdlong	r1, r7
  92              	.LVL9
  93              	.LBB16
  94              	.LBB17
 189:ParallaxBot.c **** 	drive_speed(leftSpeed, rightSpeed);
  95              		.loc 1 189 0
  96 004f 060000   		lcall	#_drive_speed
  97              	.LVL10
  98              	.LBE17
  99              	.LBE16
 236:ParallaxBot.c **** 				motor_flag =0;
 100              		.loc 1 236 0
 101 0052 B7       		mov	r7, #0
 102 0053 17DF     		wrlong	r7, r13
 103              	.LVL11
 104              	.L7
 237:ParallaxBot.c **** 				timeout_timer = current_ms;
 238:ParallaxBot.c **** 			}
 239:ParallaxBot.c **** 			if(current_ms-timeout_timer >= timeout_ms)
 105              		.loc 1 239 0
 106 0055 D66EC1   		xmov	r6,r14 sub r6,r12
 107 0058 57FF5962 		mvi	r7,#39999999
 107      02
 108 005d 1673     		cmp	r6, r7 wz,wc
 109 005f 7ECF     		IF_BE	brs	#.L8
 240:ParallaxBot.c **** 			{
 241:ParallaxBot.c **** 				Stop();
 110              		.loc 1 241 0
 111 0061 060000   		lcall	#_Stop
 112 0064 7FCA     		brs	#.L8
 113              	.LFE6
 114              		.global	_pause
 115              	_pause
 116              	.LFB7
 242:ParallaxBot.c **** 			}          
 243:ParallaxBot.c **** 		}        
 244:ParallaxBot.c **** 	}  
 245:ParallaxBot.c **** }
 246:ParallaxBot.c **** 
 247:ParallaxBot.c **** 
 248:ParallaxBot.c **** void pause(int ms)
 249:ParallaxBot.c **** {
 117              		.loc 1 249 0
 118              	.LVL12
 250:ParallaxBot.c ****     waitcnt(CNT + ms * ticks_per_ms);
 119              		.loc 1 250 0
 120 0066 660000   		mviw	r6,#_ticks_per_ms
 121 0069 F2000EA0 		mov	r7, CNT
 122 006d 116D     		rdlong	r1, r6
 123 006f 07       		lmul
 124              	.LVL13
 125 0070 1070     		add	r0, r7
 126 0072 F30000F8 		waitcnt	r0,#0
 251:ParallaxBot.c **** }
 127              		.loc 1 251 0
 128 0076 02       		lret
 129              	.LFE7
 130              		.global	_led_blink
 131              	_led_blink
 132              	.LFB5
 208:ParallaxBot.c **** {
 133              		.loc 1 208 0
 134 0077 031F     		lpushm	#16+15
 135              	.LCFI3
 136              	.L14
 211:ParallaxBot.c **** 		high(26);                           // P26 LED on
 137              		.loc 1 211 0 discriminator 1
 138 0079 A01A     		mov	r0, #26
 139 007b 060000   		lcall	#_high
 212:ParallaxBot.c **** 		pause(1000);                         // ...for 0.1 seconds
 140              		.loc 1 212 0 discriminator 1
 141 007e 60E803   		mviw	r0,#1000
 142 0081 060000   		lcall	#_pause
 213:ParallaxBot.c **** 		low(26);                            // P26 LED off
 143              		.loc 1 213 0 discriminator 1
 144 0084 A01A     		mov	r0, #26
 145 0086 060000   		lcall	#_low
 214:ParallaxBot.c **** 		pause(1000);                         // ...for 0.1 seconds
 146              		.loc 1 214 0 discriminator 1
 147 0089 60E803   		mviw	r0,#1000
 148 008c 060000   		lcall	#_pause
 149 008f 7FE8     		brs	#.L14
 150              	.LFE5
 151              		.global	_set_neopixel_group
 152              	_set_neopixel_group
 153              	.LFB8
 252:ParallaxBot.c **** 
 253:ParallaxBot.c **** void set_neopixel_group(uint32_t color)
 254:ParallaxBot.c **** {
 154              		.loc 1 254 0
 155              	.LVL14
 156 0091 031F     		lpushm	#16+15
 157              	.LCFI4
 158 0093 0CB8     		sub	sp, #72
 159              	.LCFI5
 255:ParallaxBot.c ****         int i2;
 256:ParallaxBot.c ****         uint32_t dim_array[LED_COUNT];
 257:ParallaxBot.c ****         for (i2 = 0; i2 < LED_COUNT; ++i2)
 258:ParallaxBot.c ****         {
 259:ParallaxBot.c ****           ledColors[i2] = color;
 260:ParallaxBot.c ****           dim_array[i2] = brightness*ledColors[i2]/255;
 160              		.loc 1 260 0
 161 0095 670000   		mviw	r7,#_brightness
 162 0098 117C     		rdbyte	r1, r7
 254:ParallaxBot.c **** {
 163              		.loc 1 254 0
 164 009a 0A60     		mov	r6, r0
 165              		.loc 1 260 0
 166 009c B7       		mov	r7, #0
 167 009d 07       		lmul
 168              	.LVL15
 169 009e A1FF     		mov	r1, #255
 253:ParallaxBot.c **** void set_neopixel_group(uint32_t color)
 170              		.loc 1 253 0
 171 00a0 650000   		mviw	r5,#_ledColors
 172              		.loc 1 260 0
 173 00a3 08       		ludiv
 174              	.LVL16
 175              	.L16
 253:ParallaxBot.c **** void set_neopixel_group(uint32_t color)
 176              		.loc 1 253 0 discriminator 2
 177 00a4 D44750   		xmov	r4,r7 add r4,r5
 259:ParallaxBot.c ****           ledColors[i2] = color;
 178              		.loc 1 259 0 discriminator 2
 179 00a7 164F     		wrlong	r6, r4
 253:ParallaxBot.c **** void set_neopixel_group(uint32_t color)
 180              		.loc 1 253 0 discriminator 2
 181 00a9 C400     		leasp r4,#0
 182 00ab 1470     		add	r4, r7
 183              		.loc 1 260 0 discriminator 2
 184 00ad 2740     		add	r7, #4
 257:ParallaxBot.c ****         for (i2 = 0; i2 < LED_COUNT; ++i2)
 185              		.loc 1 257 0 discriminator 2
 186 00af 374820   		cmps	r7, #72 wz,wc
 187              		.loc 1 260 0 discriminator 2
 188 00b2 104F     		wrlong	r0, r4
 257:ParallaxBot.c ****         for (i2 = 0; i2 < LED_COUNT; ++i2)
 189              		.loc 1 257 0 discriminator 2
 190 00b4 75EE     		IF_NE	brs	#.L16
 261:ParallaxBot.c ****         }   
 262:ParallaxBot.c ****         ws2812_refresh(&driver, LED_PIN, dim_array, LED_COUNT);
 191              		.loc 1 262 0
 192 00b6 600000   		mviw	r0,#_driver
 193 00b9 A108     		mov	r1, #8
 194 00bb F21004A0 		mov	r2, sp
 195 00bf A312     		mov	r3, #18
 196 00c1 060000   		lcall	#_ws2812_refresh
 197              	.LVL17
 263:ParallaxBot.c ****       
 264:ParallaxBot.c **** }
 198              		.loc 1 264 0
 199 00c4 0C48     		add	sp, #72
 200 00c6 051F     		lpopret	#16+15
 201              	.LFE8
 202              		.global	_set_neopixel
 203              	_set_neopixel
 204              	.LFB9
 265:ParallaxBot.c **** 
 266:ParallaxBot.c **** void set_neopixel(uint8_t pixel_num, uint32_t color)
 267:ParallaxBot.c **** {
 205              		.loc 1 267 0
 206              	.LVL18
 207 00c8 031F     		lpushm	#16+15
 208              	.LCFI6
 209 00ca 0CB8     		sub	sp, #72
 210              	.LCFI7
 268:ParallaxBot.c ****         if(pixel_num <LED_COUNT)
 211              		.loc 1 268 0
 212 00cc 301130   		cmp	r0, #17 wz,wc
 267:ParallaxBot.c **** {
 213              		.loc 1 267 0
 214 00cf 0B6041   		xmov	r6,r0 mov r4,r1
 215              		.loc 1 268 0
 216 00d2 7135     		IF_A 	brs	#.L18
 217              	.LBB22
 218              	.LBB23
 269:ParallaxBot.c ****         {
 270:ParallaxBot.c ****         
 271:ParallaxBot.c ****         uint32_t dim_array[LED_COUNT];
 272:ParallaxBot.c ****         int i2;
 273:ParallaxBot.c ****         for (i2 = 0; i2 < LED_COUNT; ++i2)
 274:ParallaxBot.c ****         {
 275:ParallaxBot.c ****           ledColors[pixel_num] = color;
 276:ParallaxBot.c ****           dim_array[i2] = brightness*ledColors[i2]/255;
 219              		.loc 1 276 0
 220 00d4 670000   		mviw	r7,#_brightness
 275:ParallaxBot.c ****           ledColors[pixel_num] = color;
 221              		.loc 1 275 0
 222 00d7 650000   		mviw	r5,#_ledColors
 223 00da 2629     		shl	r6, #2
 224 00dc 1650     		add	r6, r5
 225              		.loc 1 276 0
 226 00de 137C     		rdbyte	r3, r7
 227 00e0 B7       		mov	r7, #0
 228              	.LVL19
 229              	.L20
 266:ParallaxBot.c **** void set_neopixel(uint8_t pixel_num, uint32_t color)
 230              		.loc 1 266 0
 231 00e1 D11750   		xmov	r1,r7 add r1,r5
 232              		.loc 1 276 0
 233 00e4 0A03     		mov	r0, r3
 266:ParallaxBot.c **** void set_neopixel(uint8_t pixel_num, uint32_t color)
 234              		.loc 1 266 0
 235 00e6 C200     		leasp r2,#0
 275:ParallaxBot.c ****           ledColors[pixel_num] = color;
 236              		.loc 1 275 0
 237 00e8 146F     		wrlong	r4, r6
 266:ParallaxBot.c **** void set_neopixel(uint8_t pixel_num, uint32_t color)
 238              		.loc 1 266 0
 239 00ea 1270     		add	r2, r7
 240              		.loc 1 276 0
 241 00ec 2740     		add	r7, #4
 242 00ee 111D     		rdlong	r1, r1
 243 00f0 07       		lmul
 244 00f1 A1FF     		mov	r1, #255
 245 00f3 08       		ludiv
 246 00f4 102F     		wrlong	r0, r2
 273:ParallaxBot.c ****         for (i2 = 0; i2 < LED_COUNT; ++i2)
 247              		.loc 1 273 0
 248 00f6 374820   		cmps	r7, #72 wz,wc
 249 00f9 75E6     		IF_NE	brs	#.L20
 277:ParallaxBot.c ****         }   
 278:ParallaxBot.c ****         ws2812_refresh(&driver, LED_PIN, dim_array, LED_COUNT);
 250              		.loc 1 278 0
 251 00fb 600000   		mviw	r0,#_driver
 252 00fe A108     		mov	r1, #8
 253 0100 F21004A0 		mov	r2, sp
 254 0104 A312     		mov	r3, #18
 255 0106 060000   		lcall	#_ws2812_refresh
 256              	.LVL20
 257              	.L18
 258              	.LBE23
 259              	.LBE22
 279:ParallaxBot.c ****         }        
 280:ParallaxBot.c **** }
 260              		.loc 1 280 0
 261 0109 0C48     		add	sp, #72
 262 010b 051F     		lpopret	#16+15
 263              	.LFE9
 264              		.global	_eyes_blink
 265              	_eyes_blink
 266              	.LFB10
 281:ParallaxBot.c **** 
 282:ParallaxBot.c **** 
 283:ParallaxBot.c **** void eyes_blink()
 284:ParallaxBot.c **** {
 267              		.loc 1 284 0
 268              	.LVL21
 269 010d 033D     		lpushm	#(3<<4)+13
 270              	.LCFI8
 285:ParallaxBot.c ****         int doot;
 286:ParallaxBot.c ****         doot=0;
 271              		.loc 1 286 0
 272 010f BE       		mov	r14, #0
 287:ParallaxBot.c ****         while(doot<LED_COUNT)
 288:ParallaxBot.c ****         {
 289:ParallaxBot.c ****         if(doot==4||doot==13)
 290:ParallaxBot.c ****         set_neopixel(doot,0x000000);  
 291:ParallaxBot.c ****         else
 292:ParallaxBot.c ****         set_neopixel(doot,eye_color);         
 273              		.loc 1 292 0
 274 0110 6D0000   		mviw	r13,#_eye_color
 275              	.LVL22
 276              	.L26
 277 0113 0A0E     		mov	r0, r14
 289:ParallaxBot.c ****         if(doot==4||doot==13)
 278              		.loc 1 289 0
 279 0115 2ED2     		cmps	r14, #13 wz,wc
 280              		.loc 1 292 0
 281 0117 30FF40   		and	r0,#255
 289:ParallaxBot.c ****         if(doot==4||doot==13)
 282              		.loc 1 289 0
 283 011a 7A04     		IF_E 	brs	#.L35
 284 011c 2E42     		cmps	r14, #4 wz,wc
 285 011e 7503     		IF_NE	brs	#.L23
 286              	.L35
 290:ParallaxBot.c ****         set_neopixel(doot,0x000000);  
 287              		.loc 1 290 0
 288 0120 B1       		mov	r1, #0
 289 0121 7F02     		brs	#.L41
 290              	.L23
 291              		.loc 1 292 0
 292 0123 11DD     		rdlong	r1, r13
 293              	.L41
 294 0125 060000   		lcall	#_set_neopixel
 293:ParallaxBot.c ****         doot+=1;
 294:ParallaxBot.c ****         pause(1);
 295              		.loc 1 294 0
 296 0128 A001     		mov	r0, #1
 293:ParallaxBot.c ****         doot+=1;
 297              		.loc 1 293 0
 298 012a 2E10     		add	r14, #1
 299              	.LVL23
 300              		.loc 1 294 0
 301 012c 060000   		lcall	#_pause
 287:ParallaxBot.c ****         while(doot<LED_COUNT)
 302              		.loc 1 287 0
 303 012f 3E1220   		cmps	r14, #18 wz,wc
 304 0132 75DF     		IF_NE	brs	#.L26
 305              	.LVL24
 295:ParallaxBot.c ****         }     
 296:ParallaxBot.c ****         doot =0;   
 297:ParallaxBot.c ****         pause(400);
 306              		.loc 1 297 0
 307 0134 609001   		mov	r0, #400
 296:ParallaxBot.c ****         doot =0;   
 308              		.loc 1 296 0
 309 0137 BE       		mov	r14, #0
 298:ParallaxBot.c ****         while(doot<LED_COUNT)
 299:ParallaxBot.c ****         {
 300:ParallaxBot.c ****         if((doot>=3 && doot<=5)|| (doot>=12 && doot<=14))
 301:ParallaxBot.c ****         set_neopixel(doot,eye_color);  
 310              		.loc 1 301 0
 311 0138 6D0000   		mviw	r13,#_eye_color
 297:ParallaxBot.c ****         pause(400);
 312              		.loc 1 297 0
 313 013b 060000   		lcall	#_pause
 314              	.LVL25
 315              	.L30
 300:ParallaxBot.c ****         if((doot>=3 && doot<=5)|| (doot>=12 && doot<=14))
 316              		.loc 1 300 0
 317 013e E77EC1   		xmov	r7,r14 sub r7,#12
 302:ParallaxBot.c ****         else
 303:ParallaxBot.c ****         set_neopixel(doot,0x000000);         
 318              		.loc 1 303 0
 319 0141 0A0E     		mov	r0, r14
 300:ParallaxBot.c ****         if((doot>=3 && doot<=5)|| (doot>=12 && doot<=14))
 320              		.loc 1 300 0
 321 0143 2733     		cmp	r7, #3 wz,wc
 322              		.loc 1 303 0
 323 0145 30FF40   		and	r0,#255
 300:ParallaxBot.c ****         if((doot>=3 && doot<=5)|| (doot>=12 && doot<=14))
 324              		.loc 1 300 0
 325 0148 7C09     		IF_B 	brs	#.L36
 326 014a 2790     		add	r7, #9
 327 014c 2733     		cmp	r7, #3 wz,wc
 328              		.loc 1 303 0
 329 014e 8CA100   		IF_AE mov	r1, #0
 300:ParallaxBot.c ****         if((doot>=3 && doot<=5)|| (doot>=12 && doot<=14))
 330              		.loc 1 300 0
 331 0151 7302     		IF_AE	brs	#.L42
 332              	.L36
 301:ParallaxBot.c ****         set_neopixel(doot,eye_color);  
 333              		.loc 1 301 0
 334 0153 11DD     		rdlong	r1, r13
 335              	.L42
 336              		.loc 1 303 0
 337 0155 060000   		lcall	#_set_neopixel
 304:ParallaxBot.c ****         doot+=1;
 305:ParallaxBot.c ****            pause(1);
 338              		.loc 1 305 0
 339 0158 A001     		mov	r0, #1
 304:ParallaxBot.c ****         doot+=1;
 340              		.loc 1 304 0
 341 015a 2E10     		add	r14, #1
 342              	.LVL26
 343              		.loc 1 305 0
 344 015c 060000   		lcall	#_pause
 298:ParallaxBot.c ****         while(doot<LED_COUNT)
 345              		.loc 1 298 0
 346 015f 3E1220   		cmps	r14, #18 wz,wc
 347 0162 75DA     		IF_NE	brs	#.L30
 348              	.LVL27
 306:ParallaxBot.c ****         }     
 307:ParallaxBot.c ****         doot =0; 
 308:ParallaxBot.c ****         pause(400);
 349              		.loc 1 308 0
 350 0164 609001   		mov	r0, #400
 307:ParallaxBot.c ****         doot =0; 
 351              		.loc 1 307 0
 352 0167 BE       		mov	r14, #0
 309:ParallaxBot.c ****                 while(doot<LED_COUNT)
 310:ParallaxBot.c ****         {
 311:ParallaxBot.c ****         if(doot==4||doot==13)
 312:ParallaxBot.c ****         set_neopixel(doot,0x000000);  
 313:ParallaxBot.c ****         else
 314:ParallaxBot.c ****         set_neopixel(doot,eye_color);         
 353              		.loc 1 314 0
 354 0168 6D0000   		mviw	r13,#_eye_color
 308:ParallaxBot.c ****         pause(400);
 355              		.loc 1 308 0
 356 016b 060000   		lcall	#_pause
 357              	.LVL28
 358              	.L34
 359              		.loc 1 314 0
 360 016e 0A0E     		mov	r0, r14
 311:ParallaxBot.c ****         if(doot==4||doot==13)
 361              		.loc 1 311 0
 362 0170 2ED2     		cmps	r14, #13 wz,wc
 363              		.loc 1 314 0
 364 0172 30FF40   		and	r0,#255
 311:ParallaxBot.c ****         if(doot==4||doot==13)
 365              		.loc 1 311 0
 366 0175 7A04     		IF_E 	brs	#.L37
 367 0177 2E42     		cmps	r14, #4 wz,wc
 368 0179 7503     		IF_NE	brs	#.L31
 369              	.L37
 312:ParallaxBot.c ****         set_neopixel(doot,0x000000);  
 370              		.loc 1 312 0
 371 017b B1       		mov	r1, #0
 372 017c 7F02     		brs	#.L43
 373              	.L31
 374              		.loc 1 314 0
 375 017e 11DD     		rdlong	r1, r13
 376              	.L43
 377 0180 060000   		lcall	#_set_neopixel
 315:ParallaxBot.c ****         doot+=1;
 316:ParallaxBot.c ****            pause(1);
 378              		.loc 1 316 0
 379 0183 A001     		mov	r0, #1
 315:ParallaxBot.c ****         doot+=1;
 380              		.loc 1 315 0
 381 0185 2E10     		add	r14, #1
 382              	.LVL29
 383              		.loc 1 316 0
 384 0187 060000   		lcall	#_pause
 309:ParallaxBot.c ****                 while(doot<LED_COUNT)
 385              		.loc 1 309 0
 386 018a 3E1220   		cmps	r14, #18 wz,wc
 387 018d 75DF     		IF_NE	brs	#.L34
 317:ParallaxBot.c ****                    }
 318:ParallaxBot.c **** }  ...
 388              		.loc 1 318 0
 389 018f 053F     		lpopret	#(3<<4)+15
 390              	.LFE10
 391              		.data
 392              		.balign	4
 393              	.LC0
 394 0000 256400   		.ascii "%d\0"
 395 0003 00       		.balign	4
 396              	.LC1
 397 0004 72656365 		.ascii "received line:\0"
 397      69766564 
 397      206C696E 
 397      653A00
 398 0013 00       		.balign	4
 399              	.LC2
 400 0014 0A00     		.ascii "\12\0"
 401 0016 0000     		.balign	4
 402              	.LC3
 403 0018 6C00     		.ascii "l\0"
 404 001a 0000     		.balign	4
 405              	.LC4
 406 001c 6C656674 		.ascii "left\0"
 406      00
 407 0021 000000   		.balign	4
 408              	.LC5
 409 0024 7200     		.ascii "r\0"
 410 0026 0000     		.balign	4
 411              	.LC6
 412 0028 72696768 		.ascii "right\0"
 412      7400
 413 002e 0000     		.balign	4
 414              	.LC7
 415 0030 6600     		.ascii "f\0"
 416 0032 0000     		.balign	4
 417              	.LC8
 418 0034 666F7277 		.ascii "forward\0"
 418      61726400 
 419              		.balign	4
 420              	.LC9
 421 003c 6200     		.ascii "b\0"
 422 003e 0000     		.balign	4
 423              	.LC10
 424 0040 6261636B 		.ascii "back\0"
 424      00
 425 0045 000000   		.balign	4
 426              	.LC11
 427 0048 6C5F7570 		.ascii "l_up\0"
 427      00
 428 004d 000000   		.balign	4
 429              	.LC12
 430 0050 6C656674 		.ascii "left_stop\0"
 430      5F73746F 
 430      7000
 431 005a 0000     		.balign	4
 432              	.LC13
 433 005c 725F7570 		.ascii "r_up\0"
 433      00
 434 0061 000000   		.balign	4
 435              	.LC14
 436 0064 72696768 		.ascii "right_stop\0"
 436      745F7374 
 436      6F7000
 437 006f 00       		.balign	4
 438              	.LC15
 439 0070 665F7570 		.ascii "f_up\0"
 439      00
 440 0075 000000   		.balign	4
 441              	.LC16
 442 0078 666F7277 		.ascii "forward_stop\0"
 442      6172645F 
 442      73746F70 
 442      00
 443 0085 000000   		.balign	4
 444              	.LC17
 445 0088 625F7570 		.ascii "b_up\0"
 445      00
 446 008d 000000   		.balign	4
 447              	.LC18
 448 0090 6261636B 		.ascii "back_stop\0"
 448      5F73746F 
 448      7000
 449 009a 0000     		.balign	4
 450              	.LC19
 451 009c 64656275 		.ascii "debug2\0"
 451      673200
 452 00a3 00       		.balign	4
 453              	.LC20
 454 00a4 4C656674 		.ascii "Left Want: \0"
 454      2057616E 
 454      743A2000 
 455              		.balign	4
 456              	.LC21
 457 00b0 25640A00 		.ascii "%d\12\0"
 458              		.balign	4
 459              	.LC22
 460 00b4 52696768 		.ascii "Right Want:\0"
 460      74205761 
 460      6E743A00 
 461              		.balign	4
 462              	.LC23
 463 00c0 4C656674 		.ascii "Left Have: \0"
 463      20486176 
 463      653A2000 
 464              		.balign	4
 465              	.LC24
 466 00cc 52696768 		.ascii "Right Have:\0"
 466      74204861 
 466      76653A00 
 467              		.balign	4
 468              	.LC25
 469 00d8 6C656400 		.ascii "led\0"
 470              		.balign	4
 471              	.LC26
 472 00dc 6C656473 		.ascii "leds\0"
 472      00
 473 00e1 000000   		.balign	4
 474              	.LC27
 475 00e4 206F6B20 		.ascii " ok \12\0"
 475      0A00
 476              		.text
 477              		.global	_main
 478              	_main
 479              	.LFB1
  59:ParallaxBot.c **** {
 480              		.loc 1 59 0
 481 0191 036A     		lpushm	#(6<<4)+10
 482              	.LCFI9
 483 0193 0CEC     		sub	sp, #20
 484              	.LCFI10
  63:ParallaxBot.c **** 	term = fdserial_open(31, 30, 0, 9600);
 485              		.loc 1 63 0
 486 0195 6E0000   		mviw	r14,#_term
  61:ParallaxBot.c **** 	simpleterm_close();
 487              		.loc 1 61 0
 488 0198 060000   		lcall	#_simpleterm_close
  63:ParallaxBot.c **** 	term = fdserial_open(31, 30, 0, 9600);
 489              		.loc 1 63 0
 490 019b B2       		mov	r2, #0
 491 019c 638025   		mviw	r3,#9600
 492 019f A11E     		mov	r1, #30
 493 01a1 A01F     		mov	r0, #31
 494 01a3 060000   		lcall	#_fdserial_open
  65:ParallaxBot.c ****    ticks_per_ms = CLKFREQ / 1000;
 495              		.loc 1 65 0
 496 01a6 670000   		mviw	r7,#__clkfreq
 497 01a9 61E803   		mviw	r1,#1000
  63:ParallaxBot.c **** 	term = fdserial_open(31, 30, 0, 9600);
 498              		.loc 1 63 0
 499 01ac 10EF     		wrlong	r0, r14
  65:ParallaxBot.c ****    ticks_per_ms = CLKFREQ / 1000;
 500              		.loc 1 65 0
 501 01ae 107D     		rdlong	r0, r7
 502 01b0 670000   		mviw	r7,#_ticks_per_ms
 503 01b3 08       		ludiv
 504 01b4 107F     		wrlong	r0, r7
  67:ParallaxBot.c **** 	cog_run(motor_controller,128);
 505              		.loc 1 67 0
 506 01b6 A180     		mov	r1, #128
 507 01b8 600000   		mviw	r0,#_motor_controller
 508 01bb 060000   		lcall	#_cog_run
  69:ParallaxBot.c ****     if (ws2812b_init(&driver) < 0)
 509              		.loc 1 69 0
 510 01be 600000   		mviw	r0,#_driver
 511 01c1 060000   		lcall	#_ws2812b_init
 512 01c4 2002     		cmps	r0, #0 wz,wc
 513 01c6 7306     		IF_AE	brs	#.L45
 186:ParallaxBot.c **** }
 514              		.loc 1 186 0
 515 01c8 A001     		mov	r0, #1
 516 01ca 0C14     		add	sp, #20
 517 01cc 056F     		lpopret	#(6<<4)+15
 518              	.L45
  71:ParallaxBot.c ****        pause(500);
 519              		.loc 1 71 0
 520 01ce 60F401   		mov	r0, #500
  89:ParallaxBot.c **** 	int sPos = 0;
 521              		.loc 1 89 0
 522 01d1 BB       		mov	r11, #0
  71:ParallaxBot.c ****        pause(500);
 523              		.loc 1 71 0
 524 01d2 060000   		lcall	#_pause
  72:ParallaxBot.c ****    eyes_blink();
 525              		.loc 1 72 0
 526 01d5 060000   		lcall	#_eyes_blink
 527              	.LVL30
  86:ParallaxBot.c ****   char inputString[inputStringLength];
 528              		.loc 1 86 0
 529 01d8 0CE8     		sub	sp, #24
 530 01da CD08     		leasp r13,#8
 531              	.LVL31
 100:ParallaxBot.c **** 				dprint(term, "%d", (int)c);
 532              		.loc 1 100 0
 533 01dc CC04     		leasp r12,#4
 534              	.LVL32
 535              	.L65
  95:ParallaxBot.c **** 		if (fdserial_rxReady(term)!=0)
 536              		.loc 1 95 0
 537 01de 10ED     		rdlong	r0, r14
 538 01e0 060000   		lcall	#_fdserial_rxReady
 539 01e3 2002     		cmps	r0, #0 wz,wc
 540 01e5 7AF7     		IF_E 	brs	#.L65
  97:ParallaxBot.c **** 			c = fdserial_rxChar(term); //Get the character entered from the terminal
 541              		.loc 1 97 0
 542 01e7 10ED     		rdlong	r0, r14
 543 01e9 060000   		lcall	#_fdserial_rxChar
 544 01ec 0AA0     		mov	r10, r0
 100:ParallaxBot.c **** 				dprint(term, "%d", (int)c);
 545              		.loc 1 100 0
 546 01ee 660000   		mviw	r6,#.LC0
  97:ParallaxBot.c **** 			c = fdserial_rxChar(term); //Get the character entered from the terminal
 547              		.loc 1 97 0
 548 01f1 3AFF40   		and	r10,#255
 549              	.LVL33
 100:ParallaxBot.c **** 				dprint(term, "%d", (int)c);
 550              		.loc 1 100 0
 551 01f4 10ED     		rdlong	r0, r14
 552 01f6 F0100C08 		wrlong	r6, sp
 553 01fa 1ACF     		wrlong	r10, r12
 554 01fc 060000   		lcall	#_dprint
 101:ParallaxBot.c **** 				if ((int)c == 13 || (int)c == 10) {
 555              		.loc 1 101 0
 556 01ff 2AA2     		cmps	r10, #10 wz,wc
 557 0201 7A05     		IF_E 	brs	#.L62
 558 0203 2AD2     		cmps	r10, #13 wz,wc
 559 0205 450000   		IF_NE	brw	#.L48
 560              	.L62
 102:ParallaxBot.c **** 					dprint(term, "received line:");
 561              		.loc 1 102 0
 562 0208 670000   		mviw	r7,#.LC1
 563 020b 10ED     		rdlong	r0, r14
 564 020d F0100E08 		wrlong	r7, sp
 565 0211 060000   		lcall	#_dprint
 103:ParallaxBot.c **** 					dprint(term, inputString);
 566              		.loc 1 103 0
 567 0214 10ED     		rdlong	r0, r14
 568 0216 F0101A08 		wrlong	r13, sp
 569 021a 060000   		lcall	#_dprint
 104:ParallaxBot.c **** 					dprint(term, "\n");
 570              		.loc 1 104 0
 571 021d 660000   		mviw	r6,#.LC2
 572 0220 10ED     		rdlong	r0, r14
 573 0222 F0100C08 		wrlong	r6, sp
 574 0226 060000   		lcall	#_dprint
 105:ParallaxBot.c **** 					if (strcmp(inputString, "l") == 0) {
 575              		.loc 1 105 0
 576 0229 0A0D     		mov	r0, r13
 577 022b 610000   		mviw	r1,#.LC3
 578 022e 060000   		lcall	#_strcmp
 579 0231 2002     		cmps	r0, #0 wz,wc
 580 0233 7524     		IF_NE	brs	#.L50
 106:ParallaxBot.c **** 						dprint(term, "left");
 581              		.loc 1 106 0
 582 0235 670000   		mviw	r7,#.LC4
 583 0238 10ED     		rdlong	r0, r14
 584 023a F0100E08 		wrlong	r7, sp
 585 023e 060000   		lcall	#_dprint
 107:ParallaxBot.c **** 						set_motor_controller(-defaultTurnSpeed,defaultTurnSpeed);
 586              		.loc 1 107 0
 587 0241 670000   		mviw	r7,#_defaultTurnSpeed
 588              	.LBB24
 589              	.LBB25
 194:ParallaxBot.c **** 	current_leftspd =leftSpeed;
 590              		.loc 1 194 0
 591 0244 660000   		mviw	r6,#_current_leftspd
 592              	.LBE25
 593              	.LBE24
 107:ParallaxBot.c **** 						set_motor_controller(-defaultTurnSpeed,defaultTurnSpeed);
 594              		.loc 1 107 0
 595 0247 177D     		rdlong	r7, r7
 596 0249 1576     		neg	r5, r7
 597              	.LVL34
 598              	.LBB27
 599              	.LBB26
 194:ParallaxBot.c **** 	current_leftspd =leftSpeed;
 600              		.loc 1 194 0
 601 024b 156F     		wrlong	r5, r6
 195:ParallaxBot.c **** 	current_rightspd = rightSpeed;
 602              		.loc 1 195 0
 603 024d 660000   		mviw	r6,#_current_rightspd
 604 0250 176F     		wrlong	r7, r6
 196:ParallaxBot.c **** 	motor_flag = 1;
 605              		.loc 1 196 0
 606 0252 670000   		mviw	r7,#_motor_flag
 607 0255 A601     		mov	r6, #1
 608 0257 167F     		wrlong	r6, r7
 609              	.LVL35
 610              	.L50
 611              	.LBE26
 612              	.LBE27
 109:ParallaxBot.c **** 					if (strcmp(inputString, "r") == 0) {
 613              		.loc 1 109 0
 614 0259 0A0D     		mov	r0, r13
 615 025b 610000   		mviw	r1,#.LC5
 616 025e 060000   		lcall	#_strcmp
 617 0261 2002     		cmps	r0, #0 wz,wc
 618 0263 7524     		IF_NE	brs	#.L51
 110:ParallaxBot.c **** 						dprint(term, "right");
 619              		.loc 1 110 0
 620 0265 670000   		mviw	r7,#.LC6
 621 0268 10ED     		rdlong	r0, r14
 622 026a F0100E08 		wrlong	r7, sp
 623 026e 060000   		lcall	#_dprint
 111:ParallaxBot.c **** 						set_motor_controller(defaultTurnSpeed, -defaultTurnSpeed);
 624              		.loc 1 111 0
 625 0271 670000   		mviw	r7,#_defaultTurnSpeed
 626              	.LBB28
 627              	.LBB29
 194:ParallaxBot.c **** 	current_leftspd =leftSpeed;
 628              		.loc 1 194 0
 629 0274 650000   		mviw	r5,#_current_leftspd
 630              	.LBE29
 631              	.LBE28
 111:ParallaxBot.c **** 						set_motor_controller(defaultTurnSpeed, -defaultTurnSpeed);
 632              		.loc 1 111 0
 633 0277 177D     		rdlong	r7, r7
 634 0279 1676     		neg	r6, r7
 635              	.LVL36
 636              	.LBB31
 637              	.LBB30
 194:ParallaxBot.c **** 	current_leftspd =leftSpeed;
 638              		.loc 1 194 0
 639 027b 175F     		wrlong	r7, r5
 195:ParallaxBot.c **** 	current_rightspd = rightSpeed;
 640              		.loc 1 195 0
 641 027d 670000   		mviw	r7,#_current_rightspd
 642 0280 167F     		wrlong	r6, r7
 196:ParallaxBot.c **** 	motor_flag = 1;
 643              		.loc 1 196 0
 644 0282 670000   		mviw	r7,#_motor_flag
 645 0285 A601     		mov	r6, #1
 646              	.LVL37
 647 0287 167F     		wrlong	r6, r7
 648              	.LVL38
 649              	.L51
 650              	.LBE30
 651              	.LBE31
 113:ParallaxBot.c **** 					if (strcmp(inputString, "f") == 0) {
 652              		.loc 1 113 0
 653 0289 0A0D     		mov	r0, r13
 654 028b 610000   		mviw	r1,#.LC7
 655 028e 060000   		lcall	#_strcmp
 656 0291 2002     		cmps	r0, #0 wz,wc
 657 0293 7522     		IF_NE	brs	#.L52
 114:ParallaxBot.c **** 						dprint(term, "forward");
 658              		.loc 1 114 0
 659 0295 670000   		mviw	r7,#.LC8
 660 0298 10ED     		rdlong	r0, r14
 661 029a F0100E08 		wrlong	r7, sp
 662 029e 060000   		lcall	#_dprint
 115:ParallaxBot.c **** 						set_motor_controller(defaultStraightSpeed, defaultStraightSpeed);
 663              		.loc 1 115 0
 664 02a1 670000   		mviw	r7,#_defaultStraightSpeed
 665              	.LBB32
 666              	.LBB33
 194:ParallaxBot.c **** 	current_leftspd =leftSpeed;
 667              		.loc 1 194 0
 668 02a4 660000   		mviw	r6,#_current_leftspd
 669              	.LBE33
 670              	.LBE32
 115:ParallaxBot.c **** 						set_motor_controller(defaultStraightSpeed, defaultStraightSpeed);
 671              		.loc 1 115 0
 672 02a7 177D     		rdlong	r7, r7
 673              	.LVL39
 674              	.LBB35
 675              	.LBB34
 194:ParallaxBot.c **** 	current_leftspd =leftSpeed;
 676              		.loc 1 194 0
 677 02a9 176F     		wrlong	r7, r6
 195:ParallaxBot.c **** 	current_rightspd = rightSpeed;
 678              		.loc 1 195 0
 679 02ab 660000   		mviw	r6,#_current_rightspd
 680 02ae 176F     		wrlong	r7, r6
 196:ParallaxBot.c **** 	motor_flag = 1;
 681              		.loc 1 196 0
 682 02b0 670000   		mviw	r7,#_motor_flag
 683 02b3 A601     		mov	r6, #1
 684 02b5 167F     		wrlong	r6, r7
 685              	.LVL40
 686              	.L52
 687              	.LBE34
 688              	.LBE35
 117:ParallaxBot.c **** 					if (strcmp(inputString, "b") == 0) {
 689              		.loc 1 117 0
 690 02b7 0A0D     		mov	r0, r13
 691 02b9 610000   		mviw	r1,#.LC9
 692 02bc 060000   		lcall	#_strcmp
 693 02bf 2002     		cmps	r0, #0 wz,wc
 694 02c1 7524     		IF_NE	brs	#.L53
 118:ParallaxBot.c **** 						dprint(term, "back");
 695              		.loc 1 118 0
 696 02c3 670000   		mviw	r7,#.LC10
 697 02c6 10ED     		rdlong	r0, r14
 698 02c8 F0100E08 		wrlong	r7, sp
 699 02cc 060000   		lcall	#_dprint
 119:ParallaxBot.c **** 						set_motor_controller(-defaultStraightSpeed, -defaultStraightSpeed);
 700              		.loc 1 119 0
 701 02cf 670000   		mviw	r7,#_defaultStraightSpeed
 702              	.LBB36
 703              	.LBB37
 194:ParallaxBot.c **** 	current_leftspd =leftSpeed;
 704              		.loc 1 194 0
 705 02d2 660000   		mviw	r6,#_current_leftspd
 706              	.LBE37
 707              	.LBE36
 119:ParallaxBot.c **** 						set_motor_controller(-defaultStraightSpeed, -defaultStraightSpeed);
 708              		.loc 1 119 0
 709 02d5 177D     		rdlong	r7, r7
 710 02d7 1776     		neg	r7, r7
 711              	.LVL41
 712              	.LBB39
 713              	.LBB38
 194:ParallaxBot.c **** 	current_leftspd =leftSpeed;
 714              		.loc 1 194 0
 715 02d9 176F     		wrlong	r7, r6
 195:ParallaxBot.c **** 	current_rightspd = rightSpeed;
 716              		.loc 1 195 0
 717 02db 660000   		mviw	r6,#_current_rightspd
 718 02de 176F     		wrlong	r7, r6
 196:ParallaxBot.c **** 	motor_flag = 1;
 719              		.loc 1 196 0
 720 02e0 670000   		mviw	r7,#_motor_flag
 721              	.LVL42
 722 02e3 A601     		mov	r6, #1
 723 02e5 167F     		wrlong	r6, r7
 724              	.LVL43
 725              	.L53
 726              	.LBE38
 727              	.LBE39
 121:ParallaxBot.c **** 					if (strcmp(inputString, "l_up") == 0) {
 728              		.loc 1 121 0
 729 02e7 0A0D     		mov	r0, r13
 730 02e9 610000   		mviw	r1,#.LC11
 731 02ec 060000   		lcall	#_strcmp
 732 02ef 2002     		cmps	r0, #0 wz,wc
 733 02f1 750F     		IF_NE	brs	#.L54
 122:ParallaxBot.c **** 						dprint(term, "left_stop");
 734              		.loc 1 122 0
 735 02f3 670000   		mviw	r7,#.LC12
 736 02f6 10ED     		rdlong	r0, r14
 737 02f8 F0100E08 		wrlong	r7, sp
 738 02fc 060000   		lcall	#_dprint
 123:ParallaxBot.c **** 						Stop();
 739              		.loc 1 123 0
 740 02ff 060000   		lcall	#_Stop
 741              	.L54
 125:ParallaxBot.c **** 					if (strcmp(inputString, "r_up") == 0) {
 742              		.loc 1 125 0
 743 0302 0A0D     		mov	r0, r13
 744 0304 610000   		mviw	r1,#.LC13
 745 0307 060000   		lcall	#_strcmp
 746 030a 2002     		cmps	r0, #0 wz,wc
 747 030c 750F     		IF_NE	brs	#.L55
 126:ParallaxBot.c **** 						dprint(term, "right_stop");
 748              		.loc 1 126 0
 749 030e 660000   		mviw	r6,#.LC14
 750 0311 10ED     		rdlong	r0, r14
 751 0313 F0100C08 		wrlong	r6, sp
 752 0317 060000   		lcall	#_dprint
 127:ParallaxBot.c **** 						Stop();
 753              		.loc 1 127 0
 754 031a 060000   		lcall	#_Stop
 755              	.L55
 129:ParallaxBot.c **** 					if (strcmp(inputString, "f_up") == 0) {
 756              		.loc 1 129 0
 757 031d 0A0D     		mov	r0, r13
 758 031f 610000   		mviw	r1,#.LC15
 759 0322 060000   		lcall	#_strcmp
 760 0325 2002     		cmps	r0, #0 wz,wc
 761 0327 750F     		IF_NE	brs	#.L56
 130:ParallaxBot.c **** 						dprint(term, "forward_stop");
 762              		.loc 1 130 0
 763 0329 670000   		mviw	r7,#.LC16
 764 032c 10ED     		rdlong	r0, r14
 765 032e F0100E08 		wrlong	r7, sp
 766 0332 060000   		lcall	#_dprint
 131:ParallaxBot.c **** 						Stop();
 767              		.loc 1 131 0
 768 0335 060000   		lcall	#_Stop
 769              	.L56
 133:ParallaxBot.c **** 					if (strcmp(inputString, "b_up") == 0) {
 770              		.loc 1 133 0
 771 0338 0A0D     		mov	r0, r13
 772 033a 610000   		mviw	r1,#.LC17
 773 033d 060000   		lcall	#_strcmp
 774 0340 2002     		cmps	r0, #0 wz,wc
 775 0342 750F     		IF_NE	brs	#.L57
 134:ParallaxBot.c **** 						dprint(term, "back_stop");
 776              		.loc 1 134 0
 777 0344 660000   		mviw	r6,#.LC18
 778 0347 10ED     		rdlong	r0, r14
 779 0349 F0100C08 		wrlong	r6, sp
 780 034d 060000   		lcall	#_dprint
 135:ParallaxBot.c **** 						Stop();
 781              		.loc 1 135 0
 782 0350 060000   		lcall	#_Stop
 783              	.L57
 139:ParallaxBot.c ****      				if (strcmp(inputString, "debug2") == 0) {
 784              		.loc 1 139 0
 785 0353 0A0D     		mov	r0, r13
 786 0355 610000   		mviw	r1,#.LC19
 787 0358 060000   		lcall	#_strcmp
 788 035b 2002     		cmps	r0, #0 wz,wc
 789 035d 450000   		IF_NE	brw	#.L58
 790              	.LBB40
 141:ParallaxBot.c ****                drive_getTicksCalc	(&leftDist,&rightDist);
 791              		.loc 1 141 0
 792 0360 C124     		leasp r1,#36
 793 0362 C028     		leasp r0,#40
 794 0364 060000   		lcall	#_drive_getTicksCalc
 142:ParallaxBot.c ****                dprint(term, "Left Want: ");
 795              		.loc 1 142 0
 796 0367 670000   		mviw	r7,#.LC20
 797 036a 10ED     		rdlong	r0, r14
 798 036c F0100E08 		wrlong	r7, sp
 799 0370 060000   		lcall	#_dprint
 143:ParallaxBot.c **** 						dprint(term, "%d\n",&leftDist );
 800              		.loc 1 143 0
 801 0373 660000   		mviw	r6,#.LC21
 802 0376 C728     		leasp r7,#40
 803 0378 10ED     		rdlong	r0, r14
 804 037a F0100C08 		wrlong	r6, sp
 805 037e 17CF     		wrlong	r7, r12
 806 0380 060000   		lcall	#_dprint
 144:ParallaxBot.c ****                 dprint(term, "Right Want:");
 807              		.loc 1 144 0
 808 0383 660000   		mviw	r6,#.LC22
 809 0386 10ED     		rdlong	r0, r14
 810 0388 F0100C08 		wrlong	r6, sp
 811 038c 060000   		lcall	#_dprint
 145:ParallaxBot.c ****       	        dprint(term, "%d\n",&rightDist );
 812              		.loc 1 145 0
 813 038f 670000   		mviw	r7,#.LC21
 814 0392 C624     		leasp r6,#36
 815 0394 10ED     		rdlong	r0, r14
 816 0396 F0100E08 		wrlong	r7, sp
 817 039a 16CF     		wrlong	r6, r12
 818 039c 060000   		lcall	#_dprint
 146:ParallaxBot.c ****                drive_getTicks	(&leftDist,&rightDist);
 819              		.loc 1 146 0
 820 039f C124     		leasp r1,#36
 821 03a1 C028     		leasp r0,#40
 822 03a3 060000   		lcall	#_drive_getTicks
 147:ParallaxBot.c ****                dprint(term, "Left Have: ");
 823              		.loc 1 147 0
 824 03a6 670000   		mviw	r7,#.LC23
 825 03a9 10ED     		rdlong	r0, r14
 826 03ab F0100E08 		wrlong	r7, sp
 827 03af 060000   		lcall	#_dprint
 148:ParallaxBot.c **** 						dprint(term, "%d\n",&leftDist );
 828              		.loc 1 148 0
 829 03b2 660000   		mviw	r6,#.LC21
 830 03b5 C728     		leasp r7,#40
 831 03b7 10ED     		rdlong	r0, r14
 832 03b9 F0100C08 		wrlong	r6, sp
 833 03bd 17CF     		wrlong	r7, r12
 834 03bf 060000   		lcall	#_dprint
 149:ParallaxBot.c ****                 dprint(term, "Right Have:");
 835              		.loc 1 149 0
 836 03c2 660000   		mviw	r6,#.LC24
 837 03c5 10ED     		rdlong	r0, r14
 838 03c7 F0100C08 		wrlong	r6, sp
 839 03cb 060000   		lcall	#_dprint
 150:ParallaxBot.c ****       	        dprint(term, "%d\n",&rightDist );
 840              		.loc 1 150 0
 841 03ce 670000   		mviw	r7,#.LC21
 842 03d1 10ED     		rdlong	r0, r14
 843 03d3 C624     		leasp r6,#36
 844 03d5 F0100E08 		wrlong	r7, sp
 845 03d9 16CF     		wrlong	r6, r12
 846 03db 060000   		lcall	#_dprint
 847              	.L58
 848              	.LBE40
 153:ParallaxBot.c ****           		if (strncmp(inputString, "led",3) == 0) 
 849              		.loc 1 153 0
 850 03de 0A0D     		mov	r0, r13
 851 03e0 610000   		mviw	r1,#.LC25
 852 03e3 A203     		mov	r2, #3
 853 03e5 060000   		lcall	#_strncmp
 854 03e8 2002     		cmps	r0, #0 wz,wc
 855 03ea 753E     		IF_NE	brs	#.L59
 856              	.LVL44
 857              	.LBB41
 157:ParallaxBot.c ****                uint8_t pixel = strtol(pBeg+4, &pEnd,10);
 858              		.loc 1 157 0
 859 03ec CB20     		leasp r11,#32
 860              	.LVL45
 861 03ee 0B0D1B   		xmov	r0,r13 mov r1,r11
 862 03f1 A20A     		mov	r2, #10
 863 03f3 2040     		add	r0, #4
 864 03f5 060000   		lcall	#_strtol
 158:ParallaxBot.c ****                uint32_t color = strtol(pEnd, &pEnd,16);
 865              		.loc 1 158 0
 866 03f8 0A1B     		mov	r1, r11
 157:ParallaxBot.c ****                uint8_t pixel = strtol(pBeg+4, &pEnd,10);
 867              		.loc 1 157 0
 868 03fa 0AA0     		mov	r10, r0
 869              	.LVL46
 158:ParallaxBot.c ****                uint32_t color = strtol(pEnd, &pEnd,16);
 870              		.loc 1 158 0
 871 03fc A210     		mov	r2, #16
 157:ParallaxBot.c ****                uint8_t pixel = strtol(pBeg+4, &pEnd,10);
 872              		.loc 1 157 0
 873 03fe 3AFF40   		and	r10,#255
 874              	.LVL47
 158:ParallaxBot.c ****                uint32_t color = strtol(pEnd, &pEnd,16);
 875              		.loc 1 158 0
 876 0401 10BD     		rdlong	r0, r11
 877 0403 060000   		lcall	#_strtol
 159:ParallaxBot.c ****                dprint(term,"%d\n",color);
 878              		.loc 1 159 0
 879 0406 670000   		mviw	r7,#.LC21
 158:ParallaxBot.c ****                uint32_t color = strtol(pEnd, &pEnd,16);
 880              		.loc 1 158 0
 881 0409 0AB0     		mov	r11, r0
 882              	.LVL48
 159:ParallaxBot.c ****                dprint(term,"%d\n",color);
 883              		.loc 1 159 0
 884 040b 10ED     		rdlong	r0, r14
 885              	.LVL49
 886 040d F0100E08 		wrlong	r7, sp
 887 0411 1BCF     		wrlong	r11, r12
 888 0413 060000   		lcall	#_dprint
 160:ParallaxBot.c ****                if((pixel < LED_COUNT)&&(color<=0xFFFFFF))
 889              		.loc 1 160 0
 890 0416 57FFFFFF 		mvi	r7,#16777215
 890      00
 891 041b 17B3     		cmp	r7, r11 wz,wc
 892 041d 7C0B     		IF_B 	brs	#.L59
 893 041f 3A1230   		cmp	r10, #18 wz,wc
 894 0422 7306     		IF_AE	brs	#.L59
 161:ParallaxBot.c ****                set_neopixel(pixel,color); 
 895              		.loc 1 161 0
 896 0424 0B0A1B   		xmov	r0,r10 mov r1,r11
 897 0427 060000   		lcall	#_set_neopixel
 898              	.LVL50
 899              	.L59
 900              	.LBE41
 164:ParallaxBot.c ****               	if (strncmp(inputString, "leds",4) == 0) 
 901              		.loc 1 164 0
 902 042a 0A0D     		mov	r0, r13
 903 042c 610000   		mviw	r1,#.LC26
 904 042f A204     		mov	r2, #4
 905 0431 060000   		lcall	#_strncmp
 906 0434 2002     		cmps	r0, #0 wz,wc
 907 0436 7529     		IF_NE	brs	#.L60
 908              	.LVL51
 909              	.LBB42
 168:ParallaxBot.c ****                uint32_t color = strtol(pBeg+5, &pEnd,16);
 910              		.loc 1 168 0
 911 0438 0A0D     		mov	r0, r13
 912 043a A210     		mov	r2, #16
 913 043c 2050     		add	r0, #5
 914 043e C120     		leasp r1,#32
 915 0440 060000   		lcall	#_strtol
 169:ParallaxBot.c ****                dprint(term,"%d\n",color);
 916              		.loc 1 169 0
 917 0443 660000   		mviw	r6,#.LC21
 168:ParallaxBot.c ****                uint32_t color = strtol(pBeg+5, &pEnd,16);
 918              		.loc 1 168 0
 919 0446 0AB0     		mov	r11, r0
 920              	.LVL52
 169:ParallaxBot.c ****                dprint(term,"%d\n",color);
 921              		.loc 1 169 0
 922 0448 10ED     		rdlong	r0, r14
 923              	.LVL53
 924 044a F0100C08 		wrlong	r6, sp
 925 044e 1BCF     		wrlong	r11, r12
 926 0450 060000   		lcall	#_dprint
 170:ParallaxBot.c ****                if((color<=0xFFFFFF))
 927              		.loc 1 170 0
 928 0453 57FFFFFF 		mvi	r7,#16777215
 928      00
 929 0458 1B73     		cmp	r11, r7 wz,wc
 930 045a 7105     		IF_A 	brs	#.L60
 171:ParallaxBot.c ****                set_neopixel_group(color); 
 931              		.loc 1 171 0
 932 045c 0A0B     		mov	r0, r11
 933 045e 060000   		lcall	#_set_neopixel_group
 934              	.LVL54
 935              	.L60
 936              	.LBE42
 174:ParallaxBot.c **** 					inputString[0] = 0; // clear string
 937              		.loc 1 174 0
 938 0461 B7       		mov	r7, #0
 173:ParallaxBot.c **** 					sPos = 0;
 939              		.loc 1 173 0
 940 0462 BB       		mov	r11, #0
 174:ParallaxBot.c **** 					inputString[0] = 0; // clear string
 941              		.loc 1 174 0
 942 0463 17DE     		wrbyte	r7, r13
 943 0465 4F0000   		brw	#.L65
 944              	.LVL55
 945              	.L48
 175:ParallaxBot.c **** 				} else if (sPos < inputStringLength - 1) {
 946              		.loc 1 175 0
 947 0468 3B1220   		cmps	r11, #18 wz,wc
 948 046b 410000   		IF_A 	brw	#.L65
 177:ParallaxBot.c **** 					inputString[sPos] = c;
 949              		.loc 1 177 0
 950 046e D77DB0   		xmov	r7,r13 add r7,r11
 178:ParallaxBot.c **** 					sPos += 1;
 951              		.loc 1 178 0
 952 0471 2B10     		add	r11, #1
 953              	.LVL56
 179:ParallaxBot.c **** 					inputString[sPos] = 0; // make sure last element of string is 0
 954              		.loc 1 179 0
 955 0473 B6       		mov	r6, #0
 177:ParallaxBot.c **** 					inputString[sPos] = c;
 956              		.loc 1 177 0
 957 0474 1A7E     		wrbyte	r10, r7
 179:ParallaxBot.c **** 					inputString[sPos] = 0; // make sure last element of string is 0
 958              		.loc 1 179 0
 959 0476 D77DB0   		xmov	r7,r13 add r7,r11
 960 0479 167E     		wrbyte	r6, r7
 180:ParallaxBot.c **** 					dprint(term, inputString);
 961              		.loc 1 180 0
 962 047b 10ED     		rdlong	r0, r14
 963 047d F0101A08 		wrlong	r13, sp
 964 0481 060000   		lcall	#_dprint
 181:ParallaxBot.c **** 					dprint(term, " ok \n");
 965              		.loc 1 181 0
 966 0484 10ED     		rdlong	r0, r14
 967 0486 670000   		mviw	r7,#.LC27
 968 0489 F0100E08 		wrlong	r7, sp
 969 048d 060000   		lcall	#_dprint
 970 0490 4F0000   		brw	#.L65
 971              	.LFE1
 972              		.comm	_pingDistance,4,4
 973              		.global	_defaultTurnSpeed
 974              		.data
 975 00ea 0000     		.balign	4
 976              	_defaultTurnSpeed
 977 00ec 1E000000 		long	30
 978              		.global	_defaultStraightSpeed
 979              		.balign	4
 980              	_defaultStraightSpeed
 981 00f0 3C000000 		long	60
 982              		.global	_motor_flag
 983              		.section	.bss
 984              		.balign	4
 985              	_motor_flag
 986 0000 00000000 		.zero	4
 987              		.global	_current_rightspd
 988              		.balign	4
 989              	_current_rightspd
 990 0004 00000000 		.zero	4
 991              		.global	_current_leftspd
 992              		.balign	4
 993              	_current_leftspd
 994 0008 00000000 		.zero	4
 995              		.global	_commandget
 996              		.balign	4
 997              	_commandget
 998 000c 00000000 		.zero	4
 999              		.global	_gripState
 1000              		.data
 1001              		.balign	4
 1002              	_gripState
 1003 00f4 FFFFFFFF 		long	-1
 1004              		.global	_gripDegree
 1005              		.section	.bss
 1006              		.balign	4
 1007              	_gripDegree
 1008 0010 00000000 		.zero	4
 1009              		.global	_minTurnSpeed
 1010              		.data
 1011              		.balign	4
 1012              	_minTurnSpeed
 1013 00f8 02000000 		long	2
 1014              		.global	_maxTurnSpeed
 1015              		.balign	4
 1016              	_maxTurnSpeed
 1017 00fc 40000000 		long	64
 1018              		.global	_minSpeed
 1019              		.balign	4
 1020              	_minSpeed
 1021 0100 02000000 		long	2
 1022              		.global	_maxSpeed
 1023              		.balign	4
 1024              	_maxSpeed
 1025 0104 80000000 		long	128
 1026              		.global	_turnTick
 1027              		.balign	4
 1028              	_turnTick
 1029 0108 06000000 		long	6
 1030              		.global	_ticks
 1031              		.balign	4
 1032              	_ticks
 1033 010c 0C000000 		long	12
 1034              		.comm	_term,4,4
 1035              		.global	_eye_color
 1036              		.balign	4
 1037              	_eye_color
 1038 0110 0F0F0F00 		long	986895
 1039              		.global	_brightness
 1040              	_brightness
 1041 0114 FF       		byte	-1
 1042              		.comm	_ticks_per_ms,4,4
 1043              		.comm	_driver,8,4
 1044              		.comm	_ledColors,72,4
 1196              	.Letext0
 1197              		.file 2 "c:\\program files (x86)\\simpleide\\propeller-gcc\\bin\\../lib/gcc/propeller-elf/4.6.1/..
 1198              		.file 3 "C:/Users/Benjamin Morris/Documents/SimpleIDE/Learn/Simple Libraries/TextDevices/libsimple
 1199              		.file 4 "c:\\program files (x86)\\simpleide\\propeller-gcc\\bin\\../lib/gcc/propeller-elf/4.6.1/..
 1200              		.file 5 "C:/Users/Benjamin Morris/Documents/SimpleIDE/Learn/Simple Libraries/TextDevices/libfdseri
 1201              		.file 6 "ws2812.h"
 1202              		.file 7 "c:\\program files (x86)\\simpleide\\propeller-gcc\\bin\\../lib/gcc/propeller-elf/4.6.1/..
DEFINED SYMBOLS
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:2      .text:00000000 .Ltext0
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:4      .text:00000000 _Step
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:5      .text:00000000 .LFB2
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:9      .text:00000000 L0
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:16     .text:00000007 .LFE2
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:18     .text:00000007 _set_motor_controller
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:19     .text:00000007 .LFB3
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:993    .bss:00000008 _current_leftspd
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:989    .bss:00000004 _current_rightspd
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:985    .bss:00000000 _motor_flag
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:36     .text:00000019 .LFE3
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:38     .text:00000019 _Stop
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:39     .text:00000019 .LFB4
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:49     .text:00000022 .LFE4
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:51     .text:00000022 _motor_controller
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:52     .text:00000022 .LFB6
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:93     .text:0000004f .LBB16
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:99     .text:00000052 .LBE16
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:113    .text:00000066 .LFE6
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:115    .text:00000066 _pause
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:116    .text:00000066 .LFB7
                            *COM*:00000004 _ticks_per_ms
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:129    .text:00000077 .LFE7
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:131    .text:00000077 _led_blink
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:132    .text:00000077 .LFB5
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:150    .text:00000091 .LFE5
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:152    .text:00000091 _set_neopixel_group
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:153    .text:00000091 .LFB8
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1040   .data:00000114 _brightness
                            *COM*:00000048 _ledColors
                            *COM*:00000008 _driver
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:201    .text:000000c8 .LFE8
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:203    .text:000000c8 _set_neopixel
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:204    .text:000000c8 .LFB9
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:217    .text:000000d4 .LBB22
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:218    .text:000000d4 .LBB23
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:258    .text:00000109 .LBE23
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:259    .text:00000109 .LBE22
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:263    .text:0000010d .LFE9
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:265    .text:0000010d _eyes_blink
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:266    .text:0000010d .LFB10
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1037   .data:00000110 _eye_color
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:390    .text:00000191 .LFE10
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:393    .data:00000000 .LC0
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:396    .data:00000004 .LC1
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:399    .data:00000014 .LC2
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:402    .data:00000018 .LC3
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:405    .data:0000001c .LC4
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:408    .data:00000024 .LC5
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:411    .data:00000028 .LC6
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:414    .data:00000030 .LC7
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:417    .data:00000034 .LC8
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:420    .data:0000003c .LC9
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:423    .data:00000040 .LC10
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:426    .data:00000048 .LC11
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:429    .data:00000050 .LC12
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:432    .data:0000005c .LC13
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:435    .data:00000064 .LC14
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:438    .data:00000070 .LC15
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:441    .data:00000078 .LC16
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:444    .data:00000088 .LC17
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:447    .data:00000090 .LC18
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:450    .data:0000009c .LC19
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:453    .data:000000a4 .LC20
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:456    .data:000000b0 .LC21
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:459    .data:000000b4 .LC22
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:462    .data:000000c0 .LC23
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:465    .data:000000cc .LC24
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:468    .data:000000d8 .LC25
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:471    .data:000000dc .LC26
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:474    .data:000000e4 .LC27
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:478    .text:00000191 _main
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:479    .text:00000191 .LFB1
                            *COM*:00000004 _term
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:535    .text:000001de .L65
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:976    .data:000000ec _defaultTurnSpeed
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:588    .text:00000244 .LBB24
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:626    .text:00000274 .LBB28
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:980    .data:000000f0 _defaultStraightSpeed
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:665    .text:000002a4 .LBB32
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:702    .text:000002d2 .LBB36
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:790    .text:00000360 .LBB40
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:847    .text:000003de .L58
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:848    .text:000003de .LBE40
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:857    .text:000003ec .LBB41
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:900    .text:0000042a .LBE41
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:909    .text:00000438 .LBB42
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:936    .text:00000461 .LBE42
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:945    .text:00000468 .L48
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:971    .text:00000493 .LFE1
                            *COM*:00000004 _pingDistance
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:997    .bss:0000000c _commandget
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1002   .data:000000f4 _gripState
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1007   .bss:00000010 _gripDegree
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1012   .data:000000f8 _minTurnSpeed
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1016   .data:000000fc _maxTurnSpeed
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1020   .data:00000100 _minSpeed
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1024   .data:00000104 _maxSpeed
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1028   .data:00000108 _turnTick
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1032   .data:0000010c _ticks
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1046   .debug_frame:00000000 .Lframe0
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1196   .text:00000493 .Letext0
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:1204   .debug_info:00000000 .Ldebug_info0
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:2182   .debug_abbrev:00000000 .Ldebug_abbrev0
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:2974   .debug_loc:00000000 .LLST0
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:2981   .debug_loc:00000013 .LLST1
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:2988   .debug_loc:00000026 .LLST2
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3001   .debug_loc:00000046 .LLST3
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3021   .debug_loc:0000007b .LLST4
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3037   .debug_loc:000000a5 .LLST5
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3053   .debug_loc:000000cf .LLST6
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3060   .debug_loc:000000e2 .LLST7
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3067   .debug_loc:000000f5 .LLST8
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3074   .debug_loc:00000108 .LLST9
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3087   .debug_loc:00000129 .LLST10
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3098   .debug_loc:00000147 .LLST11
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3106   .debug_loc:0000015b .LLST12
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3119   .debug_loc:0000017c .LLST13
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3126   .debug_loc:0000018f .LLST14
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3137   .debug_loc:000001ad .LLST15
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3150   .debug_loc:000001cd .LLST16
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3180   .debug_loc:0000021a .LLST17
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3198   .debug_loc:00000246 .LLST18
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3209   .debug_loc:00000264 .LLST19
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3230   .debug_loc:0000029a .LLST20
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3238   .debug_loc:000002b1 .LLST21
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3245   .debug_loc:000002c4 .LLST22
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3257   .debug_loc:000002e6 .LLST23
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3265   .debug_loc:000002fd .LLST24
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3273   .debug_loc:00000314 .LLST26
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3285   .debug_loc:00000336 .LLST28
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3292   .debug_loc:00000349 .LLST29
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3299   .debug_loc:0000035c .LLST30
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3310   .debug_loc:0000037a .LLST31
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3317   .debug_loc:0000038d .LLST32
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3341   .debug_ranges:00000000 .Ldebug_ranges0
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3367   .debug_line:00000000 .Ldebug_line0
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3369   .debug_str:00000000 .LASF9
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3371   .debug_str:00000010 .LASF3
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3373   .debug_str:0000001a .LASF12
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3375   .debug_str:0000002f .LASF7
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3377   .debug_str:0000003a .LASF2
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3379   .debug_str:00000040 .LASF5
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3381   .debug_str:0000004a .LASF10
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3383   .debug_str:0000005b .LASF8
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3385   .debug_str:00000065 .LASF13
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3387   .debug_str:00000076 .LASF11
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3389   .debug_str:00000081 .LASF4
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3391   .debug_str:0000008a .LASF6
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3393   .debug_str:00000097 .LASF0
C:\Users\BENJAM~1\AppData\Local\Temp\ccJp1iok.s:3395   .debug_str:000000a1 .LASF1

UNDEFINED SYMBOLS
_drive_speed
CNT
_high
_low
_ws2812_refresh
_simpleterm_close
_fdserial_open
__clkfreq
_cog_run
_ws2812b_init
_fdserial_rxReady
_fdserial_rxChar
_dprint
_strcmp
_drive_getTicksCalc
_drive_getTicks
_strncmp
_strtol
