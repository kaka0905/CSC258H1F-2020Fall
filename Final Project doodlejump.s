#################################################################
#
# CSC258H5S Final 2020 Assembly Final Project
# University of Toronto, St.George
#
# Student: Zewen Ma, 1005968375
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Milestone reached in this submission: Milestone 4
# Features in Milestone4:
# i. Game Over and retry(retry is not printed on the screen,
#    there will be an instruction below).
# ii. Scoreboard will be displayed in the game over screen.
#
# Instruction:
# 1. Press 's' to start, the screen will generate plates and the doodle
# 2. Press 'j' to make doodle move to left
# 3. Press 'k' to make doodle move to right
# 4. When the doodle die, the score of the player will be displayed
#    under "GAME OVER", note that the initial board will not be counted
#    into the overall score. If the doodle fall from current board,
#    that board will not be counted as well.
# 5. Press 's' to get back to the start screen. 
#    Press 'e' to quit.
#    Press 's' again to re-start.
#################################################################


.data
displayAddress: .word 0x10008000

########################
# Keyboard Address Information
########################
keyboardAddress: .word 0xffff0000
fetchAddress: .word 0xffff0004

########################
# Screen Information
########################
screenWidth: .word 32
screenHeight: .word 32
screenColor: .word 0x97cff0 # blue

########################
# Color Information
########################
doodleColor: .word 0xef5f33 # orange
plateColor: .word 0x009553 # green
numberColor: .word 0xff9c80 # pink
charColor: .word 0x4f4e4c # dark grey

########################
# Plate Information
########################
plateStartX: .word 12 	# X value of the left most pixel
plateStartY: .word 30 	# Y value of the right most pixel
plateArrayX: .space 24	# An array that stores all the X values of the plates
plateArrayY: .space 24	# An array that sotres all the Y values of the plates

########################
# Doodle Information
########################
# Assume doodle takes a 3x3 board
doodleStartX: .word 14	# X value of the topleft pixel
doodleStartY: .word 27	# Y value of the topleft pixel
jumpHeight: .word 0
shiftHeight: .word 0
height: .word 0
score: .word 0

########################
# Input Information
########################
s: .word 0x73
j: .word 0x6a
k: .word 0x6b

########################
# Number Information
########################
onesPositionX: .word 20
tensPositionX: .word 16
hundredsPositionX: .word 12
numberPositionY: .word 19

.text
#####################################################
#####################################################
# Paint Board
Main:
	addi $t0, $zero, 14
	sw $t0, doodleStartX
	addi $t0, $zero, 27
	sw $t0, doodleStartY
	add $t0, $zero, $zero
	sw $t0, jumpHeight	
	sw $t0, shiftHeight
	
	lw $t0, displayAddress # Store top left pixel in t0
	lw $t1, screenWidth # Load screen width to t1
	lw $t2, screenHeight # Load hight to $t2
	mult $t1, $t2
	mflo $t2
	li $t1, 4
	mult $t2, $t1
	mflo $t2
	add $t2, $t2, $t0
	lw $t1, screenColor
fillLoop: 
	beq $t0, $t2, CheckStartKeyPress
	sw $t1, 0($t0) #store color
	addi $t0, $t0, 4
	j fillLoop
	
####################################################
# Paint Plate
CheckStartKeyPress:
	lw $t8, 0xffff0000
	beq $t8, 1, start_input
	j CheckStartKeyPress
start_input:
	lw $t2, 0xffff0004
	beq $t2, 0x73, respondToS
	j CheckStartKeyPress
respondToS:
	j RandomPlate
	
##################################################
RandomPlate:
	GenerateY:
		la $t8, plateArrayY
		lw $t2, plateStartY
		sw $t2, 0($t8)
		addi $t2, $t2, -5
		sw $t2, 4($t8)
		addi $t2, $t2, -5
		sw $t2, 8($t8)
		addi $t2, $t2, -5
		sw $t2, 12($t8)
		addi $t2, $t2, -5
		sw $t2, 16($t8)
		addi $t2, $t2, -5
		sw $t2, 20($t8)

	RandomX:
		la $t8, plateArrayX
		lw $t1, plateStartX
		sw $t1, 0($t8)
		li $v0, 42
		li $a0, 0
		li $a1, 24
		syscall
		sw $a0, 4($t8)
		syscall
		sw $a0, 8($t8)
		syscall
		sw $a0, 12($t8)
		syscall
		sw $a0, 16($t8)
		syscall
		sw $a0, 20($t8)
		
	la $t8, plateArrayX
	la $t9, plateArrayY
	add $t7, $zero, $zero
DrawBoardLoop:
	bge $t7, 24, LOOP
	lw $t1, plateArrayX($t7)
	lw $t2, plateArrayY($t7)
	jal CoorToAdd
	lw $t1, plateColor
	jal DrawPlate
	addi $t7, $t7, 4
	j DrawBoardLoop
	
#####################################################
# Game Loop
LOOP:
	lw $t1, doodleStartX
	lw $t2, doodleStartY
	bne $t2, 13, LOOP_CONTINUE
	lw $s3, shiftHeight
	bne $s3, 0, LOOP_CONTINUE
	addi $s3, $zero, 6
	sw $s3, shiftHeight
LOOP_CONTINUE:
	lw $s3, jumpHeight
	bge $t2, 32, Die
	j CheckNewKeyPress
CheckNewKeyPress:
	lw $t8, 0xffff0000
	beq $t8, 1, keyboard_input
	j CheckJump
DrawItem:
	lw $t2, doodleStartY
	jal CoorToAdd
	lw $t1, doodleColor
	jal DrawDoodle
	
	li $v0, 32
	li $a0, 100
	syscall
EraseItem:
	lw $t1, doodleStartX
	jal CoorToAdd
	lw $t1, screenColor
	jal DrawDoodle
	la $t8, plateArrayX
	la $t9, plateArrayY
	add $t7, $zero, $zero
PlateLoop:
	bge $t7, 24, LOOP
	lw $t1, plateArrayX($t7)
	lw $t2, plateArrayY($t7)
	jal CoorToAdd
	lw $t1, plateColor
	jal DrawPlate
	addi $t7, $t7, 4
	j PlateLoop
	j LOOP
CheckJump:
	blt $s3, 6, StartJump
	beq $s3, 6, StopJump
	beq $s3, 7, CheckPosition
	j CheckPosition
CheckPosition:
	la $t8, plateArrayY
	addi $t3, $t2, 3
	lw $t5, 0($t8)
	addi $t6, $zero, 0
	beq $t3, $t5, ContinueCheckXL
	lw $t5, 4($t8)
	addi $t6, $zero, 4
	beq $t3, $t5, ContinueCheckXL # if the position on the bottom of the doodle is equal to any of the second Y in the array, continue check
	lw $t5, 8($t8)
	addi $t6, $zero, 8
	beq $t3, $t5, ContinueCheckXL
	lw $t5, 12($t8)
	addi $t6, $zero, 12
	beq $t3, $t5, ContinueCheckXL
	lw $t5, 16($t8)
	addi $t6, $zero, 16
	beq $t3, $t5, ContinueCheckXL
	lw $t5, 20($t8)
	addi $t6, $zero, 20
	beq $t3, $t5, ContinueCheckXL
	# if not, should bact to Fall
	j StopJump
ContinueCheckXL:
	#la $t8, plateArrayX
	lw $t5, plateArrayX($t6)
	#lw $t5, 4($t8)
	subi $t5, $t5, 2
	bge $t1, $t5, ContinueCheckXR
	j StopJump
	
ContinueCheckXR:
	#la $t8, plateArrayX
	lw $t5, plateArrayX($t6)
	#lw $t5, 4($t8)
	addi $t5, $t5, 8
	blt $t1, $t5, Reset
	j StopJump
Reset:
	li $s3, 0
	jal CalculateScore
	sw $s3, jumpHeight
	j CheckJump
StartJump:
	lw $s0, shiftHeight
	beq $s0, 0, StartJumpNormal
	addi $s0, $s0, -1
	sw $s0, shiftHeight
	
	# cover the old plates
	add $t6, $zero, $zero
	StartShiftCoverLoop:
	bge $t6, 24, StartShiftCoverLoopEnd
	lw $t1, plateArrayX($t6)
	lw $t2, plateArrayY($t6)
	jal CoorToAdd
	lw $t1, screenColor
	jal DrawPlate
	addi $t6, $t6, 4
	j StartShiftCoverLoop
StartShiftCoverLoopEnd:
	add $t6, $zero, $zero
StartShiftLoop:
	beq $t6, 24, StartShiftLoopEnd
	lw $t8, plateArrayY($t6)
	addi $t8, $t8, 1
	sw $t8, plateArrayY($t6)
	add $t6, $t6, 4
	j StartShiftLoop
StartShiftLoopEnd: 
	lw $t2, plateArrayY($zero)
	bne $t2, 32, StartShiftNoNewPlate
	addi $t6, $zero, 4
StartShiftLoop3:
	beq $t6, 24, StartShiftLoopEnd3
	lw $t8, plateArrayY($t6)
	lw $t9, plateArrayX($t6)
	addi $t7, $t6, -4
	sw $t8, plateArrayY($t7)
	sw $t9, plateArrayX($t7)
	add $t6, $t6, 4
	j StartShiftLoop3
StartShiftLoopEnd3: 
	la $t8, plateArrayX
	li $v0, 42
	li $a0, 0
	li $a1, 24
	syscall
	sw $a0, 20($t8)
	addi $t8, $zero, 20
	lw $t9, plateArrayY($t8)
	addi $t9, $t9, -5
	sw $t9, plateArrayY($t8)
StartShiftNoNewPlate:
	add $t6, $zero, $zero
StartShiftCoverLoop2:
	bge $t6, 24, StartShiftCoverLoopEnd2
	lw $t1, plateArrayX($t6)
	lw $t2, plateArrayY($t6)
	jal CoorToAdd
	lw $t1, plateColor
	jal DrawPlate
	addi $t6, $t6, 4
	j StartShiftCoverLoop2
StartShiftCoverLoopEnd2:
	li $t4, 1
	add $s3, $s3, $t4
	sw $s3, jumpHeight
	lw $s2, height
	addi $s2, $s2, 1
	sw $s2, height
	lw $t1, doodleStartX
	lw $t2, doodleStartY
	jal DrawItem
StartJumpNormal:
	sub $t2, $t2, 1
	lw $s2, height
	addi $s2, $s2, 1
	sw $s2, height
	sw $t2, doodleStartY
	li $t4, 1
	add $s3, $s3, $t4
	sw $s3, jumpHeight
	jal DrawItem
StopJump:
	add $t2, $t2, 1
	lw $s2, height
	addi $s2, $s2, -1
	sw $s2, height
	sw $t2, doodleStartY
	li $t4, 1
	add $s3, $s3, $t4
	sw $s3, jumpHeight
	j DrawItem
keyboard_input:
	lw $t7, 0xffff0004
	beq $t7, 0x6a, respondToJ
	beq $t7, 0x6b, respondToK
	j CheckNewKeyPress
respondToJ:
	subi $t1, $t1, 1
	sw $t1, doodleStartX
	j DrawItem
respondToK:
	addi $t1, $t1, 1
	sw $t1, doodleStartX
	j DrawItem
	
#####################################################
#Helper functions
CalculateScore:
	lw $s2, height
	blt $s2, 0, AddZero
	divu $s4, $s2, 5
	sw $s4, score
	lw $s2, height
	jr $ra
AddZero:
	sw $zero, score
	jr $ra
CoorToAdd:
	lw $t0, screenWidth
	mult $t0, $t2 # multiply by y position
	mflo $t0
	add $t0, $t0, $t1 # add the x position
	li $t1, 4
	mult $t0, $t1   # multiply by 4
	mflo $t0
	lw $t1, displayAddress
	add $t0, $t0, $t1 # add global pointerform bitmap display
	jr $ra
	
DrawPlate:
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	jr $ra
	
DrawDoodle:
	sw $t1, 4($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 256($t0)
	sw $t1, 264($t0)
	jr $ra
	
CheckPlatform:
	lw $t1, doodleStartX
	lw $t2, doodleStartY
	
Die:
	# Draw letter "G"
	lw $t0, displayAddress			
	li $t1, 3
	li $t2, 5
	jal CoorToAdd
	lw $t1, charColor
	sw $t1, ($t0)	
	sw $t1, 124($t0)
	sw $t1, 248($t0)
	sw $t1, 376($t0)
	sw $t1, 508($t0)
	sw $t1, 640($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 644($t0)
	sw $t1, 648($t0)
	sw $t1, 388($t0)
	sw $t1, 392($t0)
	sw $t1, 396($t0)
	sw $t1, 524($t0)
	# Draw letter "A"
	lw $t0, displayAddress			
	li $t1, 11
	li $t2, 5
	jal CoorToAdd
	lw $t1, charColor
	sw $t1, ($t0)
	sw $t1, 4($t0)
	sw $t1, 124($t0)
	sw $t1, 136($t0)
	sw $t1, 248($t0)
	sw $t1, 268($t0)
	sw $t1, 376($t0)
	sw $t1, 380($t0)
	sw $t1, 384($t0)
	sw $t1, 388($t0)
	sw $t1, 392($t0)
	sw $t1, 504($t0)
	sw $t1, 632($t0)
	sw $t1, 396($t0)
	sw $t1, 524($t0)
	sw $t1, 652($t0)
	# Draw letter "M"
	lw $t0, displayAddress			
	li $t1, 17
	li $t2, 5
	jal CoorToAdd
	lw $t1, charColor
	sw $t1, ($t0)
	sw $t1, 4($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 256($t0)
	sw $t1, 264($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	sw $t1, 640($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 144($t0)
	sw $t1, 148($t0)
	sw $t1, 268($t0)
	sw $t1, 276($t0)
	sw $t1, 404($t0)
	sw $t1, 532($t0)
	sw $t1, 660($t0)
	# Draw letter "E"
	lw $t0, displayAddress			
	li $t1, 25
	li $t2, 5
	jal CoorToAdd
	lw $t1, charColor
	sw $t1, ($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 388($t0)
	sw $t1, 392($t0)
	sw $t1, 396($t0)
	sw $t1, 400($t0)
	sw $t1, 512($t0)
	sw $t1, 640($t0)
	sw $t1, 644($t0)
	sw $t1, 648($t0)
	sw $t1, 652($t0)
	sw $t1, 656($t0)
	# Draw letter "O"
	lw $t0, displayAddress			
	li $t1, 3
	li $t2, 12
	jal CoorToAdd
	lw $t1, charColor
	sw $t1, ($t0)	
	sw $t1, 124($t0)
	sw $t1, 140($t0)
	sw $t1, 248($t0)
	sw $t1, 272($t0)
	sw $t1, 376($t0)
	sw $t1, 400($t0)
	sw $t1, 508($t0)
	sw $t1, 524($t0)
	sw $t1, 640($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 644($t0)
	sw $t1, 648($t0)
	# Draw letter "V"
	lw $t0, displayAddress			
	li $t1, 9
	li $t2, 12
	jal CoorToAdd
	lw $t1, charColor
	sw $t1, ($t0)
	sw $t1, 20($t0)	
	sw $t1, 128($t0)
	sw $t1, 148($t0)
	sw $t1, 260($t0)
	sw $t1, 272($t0)
	sw $t1, 388($t0)
	sw $t1, 400($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 648($t0)
	sw $t1, 652($t0)
	# Draw letter "E"
	lw $t0, displayAddress			
	li $t1, 17
	li $t2, 12
	jal CoorToAdd
	lw $t1, charColor
	sw $t1, ($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 388($t0)
	sw $t1, 392($t0)
	sw $t1, 396($t0)
	sw $t1, 400($t0)
	sw $t1, 512($t0)
	sw $t1, 640($t0)
	sw $t1, 644($t0)
	sw $t1, 648($t0)
	sw $t1, 652($t0)
	sw $t1, 656($t0)
	# Draw letter "R"
	lw $t0, displayAddress			
	li $t1, 25
	li $t2, 12
	jal CoorToAdd
	lw $t1, charColor
	sw $t1, ($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 128($t0)
	sw $t1, 144($t0)
	sw $t1, 272($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 388($t0)
	sw $t1, 392($t0)
	sw $t1, 524($t0)
	sw $t1, 656($t0)
	sw $t1, 396($t0)
	sw $t1, 400($t0)
	sw $t1, 512($t0)
	sw $t1, 640($t0)
	# Draw S
	lw $t0, displayAddress			
	li $t1, 10
	li $t2, 26
	jal CoorToAdd
	lw $t1, charColor
	sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 392($t0)
	sw $t1, 520($t0)
	sw $t1, 516($t0)
	# Draw /
	lw $t0, displayAddress			
	li $t1, 14
	li $t2, 26
	jal CoorToAdd
	lw $t1, charColor
	sw $t1, 512($t0)
	sw $t1, 388($t0)
	sw $t1, 264($t0)
	sw $t1, 140($t0)
	sw $t1, 16($t0)
	# Draw E
	lw $t0, displayAddress			
	li $t1, 20
	li $t2, 26
	jal CoorToAdd
	lw $t1, charColor
	sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	j LoadScore
	
LoadScore:
	lw $t8, score
	blt $t8, 10, DrawOneNum
	blt $t8, 100, DrawTwoNum
	j DrawThreeNum

DrawThreeNum:
	lw $t8, score
	li $t9, 100
	div $t8, $t9
	mflo $t7
	lw $t1, hundredsPositionX
	lw $t2, numberPositionY
	jal CoorToAdd
	bne $t7, 0, DrawOneGreater
	jal DrawZero
	j DrawTens
DrawOneGreater:
	bne $t7, 1, DrawTwoGreater
	jal DrawOne
	j DrawTens
DrawTwoGreater:
	bne $t7, 2, DrawThreeGreater
	jal DrawTwo
	j DrawTens
DrawThreeGreater:
	bne $t7, 3, DrawFourGreater
	jal DrawThree
	j DrawTens
DrawFourGreater:
	bne $t7, 4, DrawFiveGreater
	jal DrawFour
	j DrawTens
DrawFiveGreater:
	bne $t7, 5, DrawSixGreater
	jal DrawFive
	j DrawTens
DrawSixGreater:
	bne $t7, 6, DrawSevenGreater
	jal DrawSix
	j DrawTens
DrawSevenGreater:
	bne $t7, 7, DrawEightGreater
	jal DrawSeven
	j DrawTens
DrawEightGreater:
	bne $t7, 8, DrawNineGreater
	jal DrawEight
	j DrawTens
DrawNineGreater:
	jal DrawNine
	j DrawTens
DrawTens:
	mult $t7, $t9
	mflo $t7,
	sub $t8, $t8, $t7
	sw $t8, score
	j DrawTwoNum
	
DrawTwoNum:
	lw $t8, score
	li $t9, 10
	div $t8, $t9
	mflo $t7
	lw $t1, tensPositionX
	lw $t2, numberPositionY
	jal CoorToAdd
	bne $t7, 0, DrawOnePlus
	jal DrawZero
	j DrawOnes
DrawOnePlus:
	bne $t7, 1, DrawTwoPlus
	jal DrawOne
	j DrawOnes
DrawTwoPlus:
	bne $t7, 2, DrawThreePlus
	jal DrawTwo
	j DrawOnes
DrawThreePlus:
	bne $t7, 3, DrawFourPlus
	jal DrawThree
	j DrawOnes
DrawFourPlus:
	bne $t7, 4, DrawFivePlus
	jal DrawFour
	j DrawOnes
DrawFivePlus:
	bne $t7, 5, DrawSixPlus
	jal DrawFive
	j DrawOnes
DrawSixPlus:
	bne $t7, 6, DrawSevenPlus
	jal DrawSix
	j DrawOnes
DrawSevenPlus:
	bne $t7, 7, DrawEightPlus
	jal DrawSeven
	j DrawOnes
DrawEightPlus:
	bne $t7, 8, DrawNinePlus
	jal DrawEight
	j DrawOnes
DrawNinePlus:
	jal DrawNine
	j DrawOnes
DrawOnes:
	mult $t7, $t9
	mflo $t7,
	sub $t8, $t8, $t7
	sw $t8, score
	j DrawOneNum
DrawOneNum:
	lw $t8, score
	lw $t1, onesPositionX
	lw $t2, numberPositionY
	jal CoorToAdd
	bne $t8, 0, DrawOneFinal
	jal DrawZero
	j Exit
DrawOneFinal:
	bne $t8, 1, DrawTwoFinal
	jal DrawOne
	j Exit
DrawTwoFinal:
	bne $t8, 2, DrawThreeFinal
	jal DrawTwo
	j Exit
DrawThreeFinal:
	bne $t8, 3, DrawFourFinal
	jal DrawThree
	j Exit
DrawFourFinal:
	bne $t8, 4, DrawFiveFinal
	jal DrawFour
	j Exit
DrawFiveFinal:
	bne $t8, 5, DrawSixFinal
	jal DrawFive
	j Exit
DrawSixFinal:
	bne $t8, 6, DrawSevenFinal
	jal DrawSix
	j Exit
DrawSevenFinal:
	bne $t8, 7, DrawEightFinal
	jal DrawSeven
	j Exit
DrawEightFinal:
	bne $t8, 8, DrawNineFinal
	jal DrawEight
	j Exit
DrawNineFinal:
	jal DrawNine
	j Exit

DrawZero:
	lw $t1, numberColor
	sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	sw $t1, 640($t0)
	sw $t1, 8($t0)
	sw $t1, 136($t0)
	sw $t1, 264($t0)
	sw $t1, 392($t0)
	sw $t1, 520($t0)
	sw $t1, 648($t0)
	sw $t1, 4($t0)
	sw $t1, 644($t0)
	jr $ra
DrawOne:
	lw $t1, numberColor
	sw $t1, 4($t0)
	sw $t1, 132($t0)
	sw $t1, 260($t0)
	sw $t1, 388($t0)
	sw $t1, 516($t0)
	sw $t1, 644($t0)
	jr $ra
DrawTwo:
	lw $t1, numberColor
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	sw $t1, 640($t0)
	sw $t1, 8($t0)
	sw $t1, 136($t0)
	sw $t1, 264($t0)
	sw $t1, 392($t0)
	sw $t1, 388($t0)
	sw $t1, 644($t0)
	sw $t1, 648($t0)
	jr $ra
DrawThree:
	lw $t1, numberColor
	sw $t1, 0($t0)
	sw $t1, 384($t0)
	sw $t1, 640($t0)
	sw $t1, 8($t0)
	sw $t1, 136($t0)
	sw $t1, 264($t0)
	sw $t1, 392($t0)
	sw $t1, 520($t0)
	sw $t1, 648($t0)
	sw $t1, 4($t0)
	sw $t1, 644($t0)
	sw $t1, 388($t0)
	jr $ra
DrawFour:
	lw $t1, numberColor
	sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 8($t0)
	sw $t1, 136($t0)
	sw $t1, 264($t0)
	sw $t1, 392($t0)
	sw $t1, 520($t0)
	sw $t1, 648($t0)
	sw $t1, 388($t0)
	jr $ra
DrawFive:
	lw $t1, numberColor
	sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 640($t0)
	sw $t1, 8($t0)
	sw $t1, 392($t0)
	sw $t1, 520($t0)
	sw $t1, 648($t0)
	sw $t1, 4($t0)
	sw $t1, 644($t0)
	sw $t1, 388($t0)
	jr $ra
DrawSix:
	lw $t1, numberColor
	sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	sw $t1, 640($t0)
	sw $t1, 8($t0)
	sw $t1, 392($t0)
	sw $t1, 520($t0)
	sw $t1, 648($t0)
	sw $t1, 4($t0)
	sw $t1, 644($t0)
	sw $t1, 388($t0)
	jr $ra
DrawSeven:
	lw $t1, numberColor
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	sw $t1, 136($t0)
	sw $t1, 264($t0)
	sw $t1, 392($t0)
	sw $t1, 520($t0)
	sw $t1, 648($t0)
	sw $t1, 4($t0)
DrawEight:
	lw $t1, numberColor
	sw $t1, 388($t0)
	sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	sw $t1, 640($t0)
	sw $t1, 8($t0)
	sw $t1, 136($t0)
	sw $t1, 264($t0)
	sw $t1, 392($t0)
	sw $t1, 520($t0)
	sw $t1, 648($t0)
	sw $t1, 4($t0)
	sw $t1, 644($t0)
	jr $ra
DrawNine:
	lw $t1, numberColor
	sw $t1, 388($t0)
	sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 640($t0)
	sw $t1, 8($t0)
	sw $t1, 136($t0)
	sw $t1, 264($t0)
	sw $t1, 392($t0)
	sw $t1, 520($t0)
	sw $t1, 648($t0)
	sw $t1, 4($t0)
	sw $t1, 644($t0)
	jr $ra
Exit:
CheckStartKeyPress2:
	lw $t8, 0xffff0000
	beq $t8, 1, start_input2
	j CheckStartKeyPress2
start_input2:
	lw $t2, 0xffff0004
	beq $t2, 0x73, Main
	beq $t2, 0x65, Terminate
	j CheckStartKeyPress2

Terminate:
	li $v0, 10
	syscall