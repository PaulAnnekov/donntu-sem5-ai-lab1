; Universal OUT. Works with registers that exists in registers area and memory-mapped registers.
.macro	uout
	.if	@0 < 0x40
		OUT	@0,@1         
	.else
		STS	@0,@1
	.endif
.endm

.equ 	Timer_Compare = 156 ; 8*10^6 Hz / 64 / 156 = 800 Hz.
.equ 	Max_Interrupts = 1600 ; 2 seconds (800 * 2 = 1600 = 0x0640).
.equ 	Toggled_Pin = PINB
.equ 	Toggled_Bit = PINB6
.equ	TCCR0B_State = 0b00000011 ; 011 Timer clock (Timer0) = system clock / 64.

; Data segment.
.dseg
Counter:	.byte	2

; Code segment.
.cseg

; Go to start label.
.org 0x0000		
rjmp Start								
 
; TimerCounter0 Compare Match A Interrupt. Interrupts when current timer value matches value from OCR0A register.
.org OC0Aaddr							
rjmp Timer
 
; Main program start.
.org 0x0032

Start:
; Stack initialization.
ldi R16,Low(RAMEND)						
uout SPL,R16								
ldi R16,High(RAMEND)
uout SPH,R16

; Set TCCR0B control register state.
ldi r16, TCCR0B_State			
uout TCCR0B, r16						

; Clear TOV0/ clear pending interrupts.
ldi r16, 1<<TOV0
uout TIFR0, r16							

; Enable TimerCounter0 Compare Match A Interrupt.
ldi r16, 1<<OCIE0A
uout TIMSK0, r16						

; Write value to compare timer to.
ldi r16, Timer_Compare							
out OCR0A, r16							

; Initialize tone duration counter.
ldi r16, low(Max_Interrupts)									
sts Counter, r16
ldi r16, high(Max_Interrupts)
sts Counter+1, r16

; Enable interrupts globally.
sei										

; Wait for interrupts.
Wait:										
nop
nop
nop
rjmp Wait

; Handle TimerCounter0 Compare Match A Interrupt.
Timer:
; Toggle PORTB 6 bit: "Writing a logic one to PINxn toggles the value of PORTxn, independent on the value of DDRxn".									
ldi r16, (1<<Toggled_Bit) 
uout Toggled_Pin, r16

; Decrement our Counter.
lds r16, Counter
lds r17, Counter+1
subi R16,1			; Substract 1.
sbci R17,0			; Substract 1 only if С flag raised.
brmi Disable_Timer		; Disable timer if previous operation results in negative value.
sts Counter, r16
sts Counter+1, r17

reti

; Disable all interrupts to disable timer :).
Disable_Timer:
cli
ret