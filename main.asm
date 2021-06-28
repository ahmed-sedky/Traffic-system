

$NOMOD51	 ;to suppress the pre-defined addresses by keil
$include (C8051F020.INC)		; to declare the device peripherals	with it's addresses
ORG 0H					   ; to start writing the code from the base 0


;diable the watch dog
MOV WDTCN,#11011110B ;0DEH
MOV WDTCN,#10101101B ;0ADH

; config of clock
MOV OSCICN , #14H ; 2MH clock
;config cross bar
MOV XBR0 , #00H
MOV XBR1 , #00H
MOV XBR2 , #040H  ; Cross bar enabled , weak Pull-up enabled 

;config,setup
MOV P0MDOUT, #00h
;MOV P2MDOUT, #0FFh
MOV P1MDOUT, #0FFh

MOV P2MDOUT, #0FFh

; MOV P1,#00H
; MOV P3,#00H


MOV R0,#2
MOV R2,#2
;MOV P2,#1
MOV P74OUT,#00001000B
MOV P5,#10h

;loop

START1:	
		MOV R4,#10
		MOV DPTR, #400h
		MOV A,#10
		CLR C
		SUBB A,R0
		MOVC A,@A+DPTR
		MOV P1,A
		AJMP COUNT1

; START2: MOV P3,#3FH
; 		MOV R0,#3
; 		MOV DPTR, #401h
; 		AJMP COUNT2

SWITCH_BIT EQU 3   ;0000 0010 to and it with the switch port

MAIN:
	; input
	; processing
	; output

	DJNZ R4, COUNT1
	; AJMP START2
	DJNZ R0, START1
	; MOV R0,#3
	; AJMP START1
	
	AJMP RESTART
	END_COUNT:
	AJMP SWITCH1
	END_SWITCH1:
	AJMP increase ; check switch for increasing max 
	END_INCREASE: ; return if not increasing
	; old place
	AJMP MAIN

COUNT1:	CLR A
		MOVC A,@A+DPTR
		MOV P2,A

		INC DPTR
		AJMP END_COUNT

RESTART:
	MOV A,P5
	CJNE A,#00010000B,SWITCH_LEADS
	;MOV P2,#1
	MOV P5,#020h
	CLR A
	AJMP w
	
SWITCH_LEADS:
	;MOV P2, #2
	MOV P5,#010h
	AJMP w
	AJMP w

increase:                   ; label to check if increament switch is pressed
	ACALL GET_BIT4			; get value of incr switch
	CJNE R1, #1, DECR		; check if switch pressed,if not pressed then check decr label
	CJNE R0, #10, incrm		; bound. condition to not exceed 9 digit in ssd, if it satisfy condition so go to incrm label to increse R0
	AJMP w					; if not satisfy the condition go to w label
DECR:						; label to check if decreament switch is pressed
	ACALL GET_BIT5			; get value of decr switch
	CJNE R1, #1, w 			;check if switch pressed,if not pressed then go to w
	CJNE R0, #1, dcrm		; bound. condition to not be less than 1 digit in ssd, if it satisfy condition so go to dcrm label to decr R0
	AJMP w					; if not satisfy the condition go to w label

dcrm:						;label to decreament R0
	DEC R0					
	MOV A,R0
	MOV R2,A				; save value of R0 TO R2
	AJMP START1				
incrm:						;label to increament R0
	INC R0
	MOV A,R0
	MOV R2,A				; save value of R0 TO R2
	AJMP START1
w:							; label to determine the path (restart code or return to main) 
	CJNE R0,#0,W2			; if R0=0 means that no action from switchs but it is normally finished its iteration,so if R0 !=0 so got to main
	MOV A,R2				
	MOV R0,A				; else save value of R2 TO R0 and repeat the code
	CLR A
	AJMP START1
W2:							; label to go to main 
	AJMP END_INCREASE		

GET_BIT4:
	MOV R3, #2 ; SELECT BIT #2 in switch port
	MOV A, P4    ;P0 is the Switch port
	ANL A, #00000010B
	START_ROTATE4:   ;like a for loop
	DJNZ R3, ROTATE4 
	AJMP END_ROTATE4
	ROTATE4:
		RR A        ;Right shift A
		AJMP START_ROTATE4
	END_ROTATE4:
	MOV R1, A 
	RET
GET_BIT5:
	MOV R3, #3 ; SELECT BIT #2 in switch port
	MOV A, P4    ;P0 is the Switch port
	ANL A, #00000100B
	START_ROTATE5:   ;like a for loop
	DJNZ R3, ROTATE5 
	AJMP END_ROTATE5
	ROTATE5:
		RR A        ;Right shift A
		AJMP START_ROTATE5
	END_ROTATE5:
	MOV R1, A 
	RET
SWITCH1:
	ACALL GET_BIT1
	CJNE R1, #1, SWITCH2
	AJMP DELAY1
	

GET_BIT1:
	MOV R3, #4 ; SELECT BIT #2 in switch port
	MOV A, P4    ;P0 is the Switch port
	ANL A, #00001000B
	START_ROTATE:   ;like a for loop
	DJNZ R3, ROTATE 
	AJMP END_ROTATE
	ROTATE:
		RR A        ;Right shift A
		AJMP START_ROTATE
	END_ROTATE:
	MOV R1, A 
	RET

SWITCH2:
	ACALL GET_BIT2
	CJNE R1, #1, SWITCH3
	AJMP DELAY2
	

GET_BIT2:
	MOV R3, #5 ; SELECT BIT #2 in switch port
	MOV A, P4    ;P0 is the Switch port
	ANL A, #00010000B
	START_ROTATE2:   ;like a for loop
	DJNZ R3, ROTATE2 
	AJMP END_ROTATE2
	ROTATE2:
		RR A        ;Right shift A
		AJMP START_ROTATE2
	END_ROTATE2:
	MOV R1, A 
	RET

SWITCH3:
	ACALL GET_BIT3
	CJNE R1, #1, DELAY
	AJMP DELAY3
	

GET_BIT3:
	MOV R3, #6 ; SELECT BIT #2 in switch port
	MOV A, P4    ;P0 is the Switch port
	ANL A, #00100000B
	START_ROTATE3:   ;like a for loop
	DJNZ R3, ROTATE3 
	AJMP END_ROTATE3
	ROTATE3:
		RR A        ;Right shift A
		AJMP START_ROTATE3
	END_ROTATE3:
	MOV R1, A 
	RET

DELAY:
	MOV R7, #5
	LOOP3:MOV R6,#200
	LOOP2:MOV R5,#198
	LOOP1:DJNZ R5,LOOP1
	DJNZ R6,LOOP2
	DJNZ R7,LOOP3
	AJMP END_SWITCH1

DELAY1:
	MOV R7, #10
	LOOP6:MOV R6,#200
	LOOP5:MOV R5,#198
	LOOP4:DJNZ R5,LOOP1
	DJNZ R6,LOOP2
	DJNZ R7,LOOP3
	AJMP END_SWITCH1

DELAY2:
	MOV R7, #20
	LOOP9:MOV R6,#200
	LOOP8:MOV R5,#198
	LOOP7:DJNZ R5,LOOP1
	DJNZ R6,LOOP2
	DJNZ R7,LOOP3
	AJMP END_SWITCH1

DELAY3:
	MOV R7, #40
	LOOP12:MOV R6,#200
	LOOP11:MOV R5,#198
	LOOP10:DJNZ R5,LOOP1
	DJNZ R6,LOOP2
	DJNZ R7,LOOP3
	AJMP END_SWITCH1


ORG 400H
DB 0CFH,0DFH,07H,0DDH,0CDH,0C6H,4FH,5BH,06H,9FH

END