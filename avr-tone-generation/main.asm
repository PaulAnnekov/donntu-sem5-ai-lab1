/* Universal OUT. Works with registers that exists in registers area and memory-mapped registers */
.macro	uout
	.if	@0 < 0x40
		OUT	@0,@1         
	.else
		STS	@0,@1
	.endif
.endm

/* Data segment */
.dseg
Counter:	.byte	2

/* Code segment */
.cseg

// Go to start label.
.org 0x0000		
RJMP Start								
 
// TimerCounter0 Compare Match A Interrupt. Interrupts when current timer value matches value from OCR0A register.
.org OC0Aaddr							
RJMP Timer
 
// Main program start.
.org 0x0032

Start:
// Stack initialization.
LDI R16,Low(RAMEND)						
OUT SPL,R16								
LDI R16,High(RAMEND)
OUT SPH,R16

// 011 Timer clock (Timer0) = system clock / 64.
ldi r16, (1<<CS00)|(1<<CS01)			
uout TCCR0B, r16						

// Clear TOV0/ clear pending interrupts.
ldi r16, 1<<TOV0
out TIFR0, r16							

// Enable TimerCounter0 Compare Match A Interrupt.
ldi r16, 1<<OCIE0A
uout TIMSK0, r16						

// Write value to compare timer to.
ldi r16, 156							
out OCR0A, r16							

// Initialize tone duration counter to 2 seconds (800 * 2 = 0x0640).
ldi r16, 0x40									
sts Counter, r16
ldi r16, 0x06
sts Counter+1, r16

// Enable interrupts globally.
SEI										

// Wait for interrupts.
Wait:										
nop
nop
nop
rjmp Wait

// Handle TimerCounter0 Compare Match A Interrupt.
Timer:
// Toggle PORTB 6 bit: "Writing a logic one to PINxn toggles the value of PORTxn, independent on the value of DDRxn".									
LDI r16, (1<<PINB6) 
OUT PINB, r16

// Decrement our Counter.
lds r16, Counter
lds r17, Counter+1
SUBI	R16,1			// Substract 1.
SBCI	R17,0			// Substract 1 only if С flag raised.
BRMI Disable_Timer		// Disable timer if previous operation results in negative value.
sts Counter, r16
sts Counter+1, r17

reti

// Disable all interrupts to disable timer :).
Disable_Timer:
CLI
ret