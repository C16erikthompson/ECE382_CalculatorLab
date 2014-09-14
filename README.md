ECE382_CalculatorLab
====================

Calculator in assembly

#Step 1: Pseudocode

To begin the process of creating the calculator, I created some psuedocode that described the way in which I would complete each objective for full functionality.  While this should have been done in a more modular, segmented sort of way, the psuedocode I created here was sufficient in providing me guidance as I worked through my coding.  I must be sure to create a more appropriate diagram next time I create pseudocode.  Flow chart appears below:

![](http://i47.photobucket.com/albums/f189/erik_thompson2/calculatorpseudocode_zps3f3ab06a.jpg?raw=true)

#Step 2: Addition, Subtraction, Clearing, Ending

Implementing these functions took little effort as addition and subtraction are instructions inherent to the language, clearing merely required moving #0x00 into the register containg the answer, and ending was a simple compare and jump.  The code for each appears below

##Addition
adder:										;performs addition  
mov.b	@r4+,		r6  
add		r6,			r5  
jmp		linker  

##Subtraction
subtractor:									;performs subtraction  
			mov.b	@r4+,		r6  
			sub		r6,			r5  
			jn		negative  
			jmp		linker  
			
##Clearing
clearer:									;clears number in register and moves to next spot in memory  
			mov.b	#0x00,		r5  
			mov.b	r5,			0(r8)  
			mov.b	@r4+,		r5  
			jmp		ifClear  
			
##Ending
cmp.b	end,		r7  
			jz		finish  
			
#Bounding the Answer
"B" functionality of the assignment required that answers be bounded between the decimal values 0 and 255.  To achieve this, loops were created that checked whether a value in a register existed outside these bounds or not.  If it did, it was changed to zero if it was negative, or 255 if it was greater than 255.  The code for these two functions is shown below:

##255 (0xFF) Bound
tooHigh:									;upper bound at 0x55 (255) for answers  
			mov.b	#0xFF,		r5  
			jmp	linkerCont  
			clrn  
			
##0 (0x00) Bound
negative:									;lower bound at zero for answers  
			mov.b	#0x00,		r5  
			jmp		linkerCont  
			clrn  
#Multiplying
The final requirment for total functionality was the addition of a multiplication function with a Big O value of log(n).  To accomplish this, a left rotation was used.  The code for this appears below.
  
multiplier:									;performs multiplication  
			mov.b	@r4+,		r6  
			cmp		#0x01,		r6			;checks if multiplying by 1  
			jz		linker  
			cmp		#0x00,		r6			;checks if multiplying by zero  
			jz		ifZero  
			cmp		#0x00,		r5			;checks if multiplying by zero (other number)  
			jz		ifZero  
			mov.b	r5,			r11  
  
contMultiplier:  
			rla	r5							;rotates number in r5 to the left, multiplying by two each time  
			rla	r10							;rotates r10 "checker number" to the left, multiplying by two  
			cmp		r6,			r10			;compares the value of r10 to r6  
			jz		linker					;if equal, done with multiplication  
			jge		finishMultiply			;if greater, moves to subtraction stage  
			jmp		contMultiplier			;if less, does multiplication again  
  
finishMultiply:  

			sub		r6,			r10			;determines number of subtractions necessary  
  
contFinishMultiply:  
			sub		r11,			r5		;subtracts the original number from the multiplied result the  
			dec		r10						;number of times specified in the previous step  
			cmp		#0x00,		r10  
			jz		linker  
			jmp		contFinishMultiply  
  
ifZero:  
			mov.b	#0x00,		r5			;makes answer zero if multiplied by zero  
			jmp		linker  
			
#Documentation
None
