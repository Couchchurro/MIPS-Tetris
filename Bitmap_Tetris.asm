.eqv	MAGENTA	0x00FF00FF	
.eqv	ORANGE	0xff9400
.eqv	WHITE	0x00FFFFFF
.eqv	YELLOW	0xffdb4d
.eqv	RED	0x00FF0000
.eqv	PURPLE	0x00800080 
.eqv	GREEN	0x0000FF00
.eqv	BLACK	0x00000000
.eqv	CYAN	0x0000FFFF

.eqv	WIDTH	16
.eqv	HEIGHT	32



.data

#a1 not used for anything
#a2 used for height
#a3 used for width
#s0 used for color
#s1 used for the input
#s2 used to hold the number which denotes the piece 
#s4 used as a counter
.text
bitmap_setup:
#settup up the bitmap
	addi 	$a3, $0, WIDTH    # a3 = X = WIDTH/2
	sra 	$a3, $a3, 1
	addi 	$a2, $0, HEIGHT   # a2 = Y = HEIGHT/2
	sra 	$a2, $a2, 1

make_white1:
#setting up size of the playing field so that it can be whited out
	addi	$t0,	$0,	16
	addi	$t1,	$0,	32
	
	addi	$a3,	$0,	0
	addi	$a2,	$0,	0
	addi	$s0,	$0,	WHITE	
	
make_white2:
#sets up escape clause for when the whiteout is done
	beqz	$t1,	make_white4
	beqz	$t0,	make_white3
	addi	$t0,	$t0,	-1
	jal	draw_pixel
	
	addi	$a3,	$a3,	1

	j	make_white2



make_white3:
##restting the width after it the counter reaches the end of a line and moving down one row
	addi	$a3,	$a3,	-16
	addi	$a2,	$a2,	1
	addi	$t0,	$t0,	16
	addi	$t1,	$t1,	-1
	j	make_white2

make_white4:
	j	big_box_setup	

	

big_box_setup:
#Setting up for the black playing field box
	addi 	$s0, $0, BLACK  
	la	$t0,	21	#height of the box
	addi	$a3,	$0,	2	#top left pixel
	addi	$a2,	$0,	3	#top left pixel
BigBox1:
#escape clause for when done with the first line
	beqz	$t0,	BigBox2

#drawing pixel, moving down one, and repeating the process
	jal	draw_pixel
	addi	$t0,	$t0,	-1
	addi	$a2,	$a2,	1
	j	BigBox1
	
BigBox2:
	addi	$t0,	$0,	11	#width of the box
	
BigBox3:
#escape clause for when done with the second line
	beqz	$t0,	BigBox4
#drawing pixel, moving right one, and repeating the process
	jal	draw_pixel
	addi	$t0,	$t0,	-1
	addi	$a3,	$a3,	1
	j	BigBox3

BigBox4:
	addi	$t0,	$0,	21	#height of the box again
	
BigBox5:
#escape clause for when done with the third line
	beqz	$t0,	BigBox6

#drawing pixel, moving right one, and repeating the process
	jal	draw_pixel
	addi	$t0,	$t0,	-1
	addi	$a2,	$a2,	-1
	j	BigBox5
	
BigBox6:
	addi	$t0,	$0,	11	#width of the box again
BigBox7:
#escape clause for when done with the fourth and final line
	beqz	$t0,	next_piece1
	
#drawing pixel, moving left one, and repeating the process
	jal	draw_pixel
	addi	$t0,	$t0,	-1
	addi	$a3,	$a3,	-1
	j	BigBox7
	
		
next_piece1:
	la	$t2,	1
next_piece2:
#spot where the pieces are spawned in
	addi	$a2,	$0	4
	addi	$a3,	$0	6
	
#making sure that there is room to spawn the piece, otherwise known as checking that the game is sitll going
	jal	check_color
	bne	$s0,	WHITE,	Game_over
	addi	$a2,	$a2,	1
	jal	check_color
	bne	$s0,	WHITE,	Game_over	
	addi	$a3,	$a3,	1
	jal	check_color
	bne	$s0,	WHITE,	Game_over
	addi	$a2,	$a2,	-1
	jal	check_color
	bne	$s0,	WHITE,	Game_over
	addi	$a3,	$a3,	-1

#getting random number from 0-6
	la	$a1,	7
	li	$v0,	42
	syscall
	move	$s2,	$a0
	
#moving to a piece depending on what the number is
	beq	$a0,	0	O_piece
	beq	$a0,	1	I_piece	
	beq	$a0,	2	S_piece	
	beq	$a0,	3	Z_piece	
	beq	$a0,	4	L_piece
	beq	$a0,	5	J_piece	
	beq	$a0,	6	T_piece	
	

Game_over:
	j	exit
	
O_piece:
#making the piece yellow and moving right one since the O piece starts at a slightly different position
	addi	$s0,	$0,	YELLOW
	addi	$a3,	$a3,	1
	la	$t2,	1

#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack
	jal	O_piece_j1
	O_piece_j1:
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
#checks to make sure that I'm only drawing the piece once, then skips this part
	beqz	$t2,	O_piece_j2
	addi	$t2,	$t2,	-1

#draws the actual piece, then goes to the input loop
	j	draw_O1
	O_piece_j2:
	j	input
	
I_piece:
	addi	$s0,	$0,	CYAN
	la	$t2,	1

	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	I_piece_j1
	I_piece_j1:
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
#checks to make sure that I'm only drawing the piece once, then skips this part
	beqz	$t2,	I_piece_j2
	addi	$t2,	$t2,	-1

#draws the actual piece, then goes to the input loop
	j	draw_I1
	I_piece_j2:
	j	input
	
	
S_piece:
	addi	$s0,	$0,	RED
	la	$t2,	1
	

#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack		
	jal	S_piece_j1
	S_piece_j1:
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
#checks to make sure that I'm only drawing the piece once, then skips this part
	beqz	$t2,	S_piece_j2
	addi	$t2,	$t2,	-1

#draws the actual piece, then goes to the input loop
	j	draw_S1
	S_piece_j2:
	j	input

Z_piece:
	addi	$s0,	$0,	GREEN
	la	$t2,	1

#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	Z_piece_j1
	Z_piece_j1:
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
#checks to make sure that I'm only drawing the piece once, then skips this part
	beqz	$t2,	Z_piece_j2
	addi	$t2,	$t2,	-1


#draws the actual piece, then goes to the input loop
	j	draw_Z1
	Z_piece_j2:
	j	input
	
	
	
L_piece:
	addi	$s0,	$0,	ORANGE
	la	$t2,	1

#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack				
	jal	L_piece_j1
	L_piece_j1:
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
#checks to make sure that I'm only drawing the piece once, then skips this part
	beqz	$t2,	L_piece_j2
	addi	$t2,	$t2,	-1

#draws the actual piece, then goes to the input loop	
	j	draw_L1
	L_piece_j2:
	j	input
	
	
	
J_piece:
	addi	$s0,	$0,	MAGENTA
	la	$t2,	1

#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack
	jal	J_piece_j1
	J_piece_j1:
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)

#checks to make sure that I'm only drawing the piece once, then skips this part
	beqz	$t2,	J_piece_j2
	addi	$t2,	$t2,	-1

#draws the actual piece, then goes to the input loop	
	j	draw_J1
	J_piece_j2:
	j	input
	
T_piece:
	addi	$s0,	$0,	PURPLE
	la	$t2,	1

#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	T_piece_j1
	T_piece_j1:
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)

#checks to make sure that I'm only drawing the piece once, then skips this part
	beqz	$t2,	T_piece_j2
	addi	$t2,	$t2,	-1

#draws the actual piece, then goes to the input loop	
	j	draw_T1
	T_piece_j2:
	j	input
	
#Input loops through until you type A or D, or the counter hits 0
input:	
#counter that is used to track when the block should move down
la	$s3 50000
input2:
#Moves the counter down until it hits 0, then sees if it can move the block down
	addi	$s3,	$s3,	-1
	beqz	$s3,	choose_down
	


#check for input
	lw $t0, 0xffff0000  #t1 holds if input available
    	beq $t0, 0, input2   #If no input, keep displaying
	
	lw 	$s1, 0xffff0004
	beq	$s1, 100, right	# input d
	beq	$s1, 97, left  	# input a
	j	input2
	
right:	
#jumps to specific parts of the code depending on what number is in #s2, which determines which piece it goes to
	beq	$s2,	0,	check_Oright
	beq	$s2,	1,	check_Iright
	beq	$s2,	2,	check_Sright
	beq	$s2,	3,	check_Zright
	beq	$s2,	4,	check_Lright
	beq	$s2,	5,	check_Jright
	beq	$s2,	6,	check_Tright						
left:
#jumps to specific parts of the code depending on what number is in #s2, which determines which piece it goes to
	beq	$s2,	0,	check_Oleft	
	beq	$s2,	1,	check_Ileft		
	beq	$s2,	2,	check_Sleft		
	beq	$s2,	3,	check_Zleft	
	beq	$s2,	4,	check_Lleft	
	beq	$s2,	5,	check_Jleft	
	beq	$s2,	6,	check_Tleft			
				
choose_down:
#jumps to specific parts of the code depending on what number is in #s2, which determines which piece it goes to
	beq	$s2,	0,	check_Odown
	beq	$s2,	1,	check_Idown
	beq	$s2,	2,	check_Sdown
	beq	$s2,	3,	check_Zdown
	beq	$s2,	4,	check_Ldown
	beq	$s2,	5,	check_Jdown
	beq	$s2,	6,	check_Tdown		
	
	
	
bottom:
	j	check_for_tetris
	
	
check_for_tetris:
#going to the leftmost pixel in the game field, then storing it's location
	addi	$a3,	$0,	3

#Goes to the specific check for if a line has been filled dependent on S2, the piece tracker
	beq	$s2,	0,	checkO_for_tetris
	beq	$s2,	1,	checkI_for_tetris	
	beq	$s2,	2,	checkS_for_tetris
	beq	$s2,	3,	checkZ_for_tetris
	beq	$s2,	4,	checkL_for_tetris
	beq	$s2,	5,	checkJ_for_tetris
	beq	$s2,	6,	checkT_for_tetris					
	
	


checkO_for_tetris:
#counter to make sure I don't infinitely loop
	la	$t2,	2

#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	checkO1
	checkO1:
	
#Skips the following code once it's already been run through once
	beq	$t2,	1	check_rowO2
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
#checks if there is a cleared line
	j	check_row1_for_tetris

	check_rowO2:

#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	checkO2
	checkO2:
	
#moves up a row, then checks if there is a cleared line
	addi	$a2,	$a2,	-1	
	beqz	$t2,	done_checking
	
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	j	check_row1_for_tetris

checkT_for_tetris:
#counter to make sure I don't infinitely loop
	la	$t2,	2
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	checkT1
	checkT1:
	
#Skips the following code once it's already been run through once
	beq	$t2,	1	check_rowT2
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
	j	check_row1_for_tetris

	check_rowT2:
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack		
	jal	checkT2
	checkT2:
	addi	$a2,	$a2,	-1
	
#Skips the following code once it's already been run through once
	beqz	$t2,	done_checking
	addi	$t2,	$t2,	-1
	
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
#checks if there is a cleared line
	j	check_row1_for_tetris
	
checkL_for_tetris:
	la	$t2,	2
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	checkL1
	checkL1:
	
#Skips the following code once it's already been run through once
	beq	$t2,	1	check_rowL2	
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
#checks if there is a cleared line
	j	check_row1_for_tetris

	check_rowL2:
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	checkL2
	checkL2:
	addi	$a2,	$a2,	-1
	
#Skips the following code once it's already been run through once
	beqz	$t2,	done_checking
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
#checks if there is a cleared line
	j	check_row1_for_tetris	
	
checkJ_for_tetris:
	la	$t2,	2
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	checkJ1
	checkJ1:
	
#Skips the following code once it's already been run through once
	beq	$t2,	1	check_rowL2
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
#checks if there is a cleared line
	j	check_row1_for_tetris

	check_rowJ2:
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	checkJ2
	checkJ2:
	addi	$a2,	$a2,	-1
	
#Skips the following code once it's already been run through once
	beqz	$t2,	done_checking
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
#checks if there is a cleared line
	j	check_row1_for_tetris	
	
checkZ_for_tetris:
	la	$t2,	2
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	checkZ1
	checkZ1:
	
#Skips the following code once it's already been run through once
	beq	$t2,	1	check_rowZ2
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
#checks if there is a cleared line
	j	check_row1_for_tetris

	check_rowZ2:
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	checkZ2
	checkZ2:
	addi	$a2,	$a2,	-1
	
#Skips the following code once it's already been run through once
	beqz	$t2,	done_checking
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)

#checks if there is a cleared line
	j	check_row1_for_tetris
	
checkI_for_tetris:
	la	$t2,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	checkI1
	checkI1:
	
#Skips the following code once it's already been run through once
	beqz	$t2,	done_checking
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
#checks if there is a cleared line
	j	check_row1_for_tetris

		
checkS_for_tetris:
	la	$t2,	2
	addi	$a2,	$a2,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	checkS1
	checkS1:
	
#Skips the following code once it's already been run through once
	beq	$t2,	1	check_rowS2
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)
	
#checks if there is a cleared line
	j	check_row1_for_tetris
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	check_rowS2:
	jal	checkS2
	checkS2:
	
#Skips the following code once it's already been run through once
	beqz	$t2,	done_checking
	addi	$t2,	$t2,	-1
	addi	$sp,	$sp,	-4
	sw	$ra	($sp)

#checks if there is a cleared line
	j	check_row1_for_tetris		
		
done_checking:
#If no cleared lines were found, it moves back up to the code to create a new piece
	j	next_piece1
	
check_row1_for_tetris:
#breaks once it reaches the end of a row
	beq	$a3,	13,	row1_tetris
	
#collecting whatever color is currently in the pixel, and comparing it to white, then moving right one pixel and jumping to the top of this loop
	jal	check_color
	beq	$s0,	WHITE,	row1_no_tetris
	addi	$a3,	$a3,	1
	
	j	check_row1_for_tetris
	
#If nothing is found, it just goes back to wherever in the code jumped to the check for tetris 
row1_no_tetris:
	j	jump_return
	
row1_tetris:
#this section of code is if there is a filled row, to get ready to clear it out and move everything else down one.

#moves to the leftmost pixel in the game field and sets the color being held in s2 to white, before storing the pixel's currnet height
	addi	$a3,	$0,	3
	addi	$s0,	$0,	WHITE
	addi	$t0,	$a2,	0
	
row1_tetris2:
#breaks once it hits the right of the playing field
	beq	$a3,	13,	row1_tetris3	
	
#makes the pixel white, the moves right once and jumps to the top of the loo[
	jal	draw_pixel
	addi	$a3,	$a3,	1
	j	row1_tetris2
row1_tetris3:
#moves to the leftmost pixel of the gaming field
	addi	$a3,	$0,	3

	
row1_tetris5:
#stops entirely once it hits a height of 6, otherwise known as near the top of the field
	beq	$a2,	6,	row1_tetris7
#stops once it gets to the right of the field
	beq	$a3,	13,	row1_tetris6
	
#moves up one row and grabs the color one above the whited out pixel
	addi	$a2,	$a2,	-1
	jal	check_color
#moves down one pixel and places the color in the whited out pixel
	addi	$a2,	$a2,	1
	jal	draw_pixel
	
#moves right one pixel
	addi	$a3,	$a3,	1
	j	row1_tetris5
	
row1_tetris6:
#moves up one pixel, then moves to the leftmost pixel
	addi	$a2,	$a2,	-1
	j	row1_tetris3
	
#restores the stores height
row1_tetris7:
	move	$a2,	$t0
#returns to whereever it was previously in the code
	j	jump_return
	

	
	
draw_Z1:
#draws the z piece
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a2,	$a2,	1
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	
#returns to whereever it was previously in the code
	j	jump_return

clear_Z1:
#sets a counter to make sure it doesn't get stuck in an infinite loop, and sets the color to white
	la	$t2,	1
	addi	$s0,	$0,	WHITE
clear_Z2:
#breaks once it's ran through once
	beqz	$t2,	clear_Z3
	addi	$t2,	$t2,	-1

#draws the z piece in reverse so that everything is whited out
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
	addi	$a2,	$a2,	-1
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
clear_Z3:	
#returns to whereever it was previously in the code
	j	jump_return	

#checks to see if the piece has room to move to the right 
check_Zright:
#stores the x and y positions of the pixel
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3
	
#mvoes right once, and checks if the color of the pixel is white or not
	addi	$a3,	$a3,	1
	jal	check_color
	bne	$s0,	WHITE,	Zr_white1
	
#moves dowsn and to the left, checks if the color of the pixel is white or not
	addi	$a2,	$a2,	1	
	addi	$a3,	$a3,	-1
	jal	check_color
	bne	$s0,	WHITE,	Zr_white1	

#if both pixels are white, it means it has space to move 
	j	jZ_not_white
	
#resets the x and y of the pixel, then goes back up to the input loop
	Zr_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	input
	
#resets the x and y of the pixel, then moves the piece right once
	jZ_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Zright


Zright:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack		
	jal	jump_Zr1
	jump_Zr1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks the loop once it has been run through once
	beqz	$t2,	jump_Zr2
	addi	$t2,	$t2,	-1

#clears the piece out, then returns to the top of the loop
	j	clear_Z1
		
	jump_Zr2:
#moves right once
	addi	$a3,	$a3,	1

#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack		
	jal	jump_Zr3
	jump_Zr3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks out of the loop once it has been run through once
	beqz	$t3,	jump_Zr4
	addi	$t3,	$t3,	-1
	
#sets the color to green, then draws the piece
	addi	$s0,	$0,	GREEN
	j	draw_Z1
	
	jump_Zr4:
#jumps to the input loop
	j	input

check_Zleft:
#stores the x and y positions of the pixel
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3

#moves left ttwice
	addi	$a3,	$a3,	-2	

#checks if the color is white, breaks if it is not
	jal	check_color
	bne	$s0,	WHITE,	Zl_white1
	
#moves left once, and down once
	addi	$a3,	$a3,	-1
	addi	$a2,	$a2,	1	
	
#checks if the color is white, breaks if it is not
	jal	check_color
	bne	$s0,	WHITE,	Zl_white1	
	
#if both pixels are white, it means that the piece can move
	j	Zl_not_white
	
#if either pixel is not white, it jumps to the input loop
	Zl_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	input
	
#restores the x and y positions, and moves the piece to the left
	Zl_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Zleft


Zleft:
	la	$t2,	1
	la	$t3,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Zl1
	jump_Zl1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Zl2
	addi	$t2,	$t2,	-1
	
#whites out the piece
	j	clear_Z1
	
	jump_Zl2:
#moves left once
	addi	$a3,	$a3,	-1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Zl3
	jump_Zl3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Zl4
	addi	$t3,	$t3,	-1
	
#makes the color green and draws the piece
	addi	$s0,	$0,	GREEN
	j	draw_Z1
	
#jumps to the input loop
	jump_Zl4:
	j	input
	
check_Zdown:
#stores the x and y positions
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3

#moves down once
	addi	$a2,	$a2,	1	

#compares the color to white, breaks if it is
	jal	check_color
	bne	$s0,	WHITE,	Zd_white1
	
#left once
	addi	$a3,	$a3,	-1
	
#compares the color to white, breaks if it is
	jal	check_color
	bne	$s0,	WHITE,	Zd_white1	
	
#left once, up once
	addi	$a3,	$a3,	-1
	addi	$a2,	$a2,	-1
	
#compares the color to white, breaks if it is
	jal	check_color
	bne	$s0,	WHITE,	Zd_white1
	
#if both pixels are not white, jumps to move it down
	j	Zd_not_white

#restores x and y, moves to bottom loop
	Zd_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	bottom
	
#restores x and y, moves to down loop
	Zd_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Zdown

Zdown:
	la	$t2,	1
	la	$t3,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Zd1
	jump_Zd1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Zd2
	addi	$t2,	$t2,	-1
	
#whites out eh piece
	j	clear_Z1

	
	jump_Zd2:
#down once
	addi	$a2,	$a2,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Zd3
	jump_Zd3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once run through once
	beqz	$t3,	jump_Zd4
	addi	$t3,	$t3,	-1
	
#draws the piede in green
	addi	$s0,	$0,	GREEN
	j	draw_Z1
	
#jumps to input loop
	jump_Zd4:
	j	input	
	
	
	
	
	
draw_S1:
#draws the S piece
	addi	$a2,	$a2,	1
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a2,	$a2,	-1
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	
#returns to wherever in the code it jumped from
	j	jump_return

clear_S1:
	la	$t2,	1
	addi	$s0,	$0,	WHITE

clear_S2:
#breaks once the code has been run through once
	beqz	$t2,	clear_S3
	addi	$t2,	$t2,	-1

#builds the piece in reverse
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
	addi	$a2,	$a2,	1
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
	
clear_S3:	
#returns to wherever in the code it jumped from
		j	jump_return	


check_Sright:
#store sthe x and y
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3
	
#right once
	addi	$a3,	$a3,	1
	
#checks to see if the pixel is white, breaks if it ise
	jal	check_color
	bne	$s0,	WHITE,	Sr_white1
	
#down once, left one
	addi	$a2,	$a2,	1	
	addi	$a3,	$a3,	-1
	
	#checks to see if the pixel is white, breaks if it ise
	jal	check_color
	bne	$s0,	WHITE,	Sr_white1	

#if neither is white, it is able to mvoe right once
	j	jS_not_white
	
#if either is not white, resets the x and yand mvoes to input loop
	Sr_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	input
	
#since both are whtie, moves right once and resets x and y
	jS_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Sright


Sright:
	la	$t2,	1
	la	$t3,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Sr1
	jump_Sr1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Sr2
	addi	$t2,	$t2,	-1
	
#whites out the piece
	j	clear_S1
		
	jump_Sr2:
	
#right once, up once
	addi	$a3,	$a3,	1
	addi	$a2,	$a2,	-1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Sr3
	jump_Sr3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run once
	beqz	$t3,	jump_Sr4
	addi	$t3,	$t3,	-1
	
#draws the piece in red
	addi	$s0,	$0,	RED
	j	draw_S1
	
	jump_Sr4:
	j	input

check_Sleft:
#stores the x and y
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3

#left twice
	addi	$a3,	$a3,	-2	


#compares the pixel to white, breaks if it isnt'	
	jal	check_color
	bne	$s0,	WHITE,	Sl_white1
	
#left once, down once
	addi	$a3,	$a3,	-1
	addi	$a2,	$a2,	1	
	
#compares the pixel to white, breaks if it isnt'
	jal	check_color
	bne	$s0,	WHITE,	Sl_white1	
	
#neither is colored, means it can jump
	j	Sl_not_white
	
	Sl_white1:
#restores x and y, jumps to input loop
	move	$a2,	$t0
	move	$a3,	$t1
	j	input
	
#restores x and y, moves left
	Sl_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Sleft


Sleft:
	la	$t2,	1
	la	$t3,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Sl1
	jump_Sl1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once run once
	beqz	$t2,	jump_Sl2
	addi	$t2,	$t2,	-1
	
#whites out eh piece
	j	clear_S1

	
	jump_Sl2:
	
#left once, up once
	addi	$a3,	$a3,	-1
	addi	$a2,	$a2,	-1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Sl3
	jump_Sl3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once run once
	beqz	$t3,	jump_Sl4
	addi	$t3,	$t3,	-1
	
#draws the S piece
	addi	$s0,	$0,	RED
	j	draw_S1
	
#jumps to input loop
	jump_Sl4:
	j	input	
	
	
check_Sdown:
#store sthe x and y
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3
	
#down once
	addi	$a2,	$a2,	1
	
#compares the pixel to white, breask if it is
	jal	check_color
	bne	$s0,	WHITE,	Sd_white1
	
#down once, left once
	addi	$a2,	$a2,	1	
	addi	$a3,	$a3,	-1
	
#compares the pixel to white, breask if it is
	jal	check_color
	bne	$s0,	WHITE,	Sd_white1	

#left once
	addi	$a3,	$a3,	-1
	
#compares the pixel to white, breask if it is
	jal	check_color
	bne	$s0,	WHITE,	Sd_white1
	
#both are whtie, able to loop
	j	Sd_not_white
	
#restores x and y, moves to the bottom loop
	Sd_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	bottom
	
#restores x and y, moves to move the piece down once
	Sd_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Sdown


Sdown:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack		
	jal	jump_Sd1
	jump_Sd1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once run
	beqz	$t2,	jump_Sd2
	addi	$t2,	$t2,	-1
	
#whites out piece
	j	clear_S1
		
	jump_Sd2:

#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack		
	jal	jump_Sd3
	jump_Sd3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once run
	beqz	$t3,	jump_Sd4
	addi	$t3,	$t3,	-1
	
#draws the S piece
	addi	$s0,	$0,	RED
	j	draw_S1
	
#jumps to input loo
	jump_Sd4:
	j	input
	
	
draw_T1:
#draws the T piece
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	addi	$a2,	$a2,	1
	jal	draw_pixel
	
#jujmps to wherever previous it was in the coee
	j	jump_return

clear_T1:
#whtieis out the piece
	la	$t2,	1
	addi	$s0,	$0,	WHITE
	
clear_T2:
#breaks loop once run
	beqz	$t2,	clear_T3
	addi	$t2,	$t2,	-1

#draws T in reverse
	addi	$s0,	$s0,	0
	jal	draw_pixel
	addi	$a3,	$a3,	1
	addi	$a2,	$a2,	-1
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
	
clear_T3:
#jujmps to wherever previous it was in the coee	
	j	jump_return	


check_Tright:
#stores x and y
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3

#right once
	addi	$a3,	$a3,	1
	
#compares color to white, breaks if it isn't
	jal	check_color
	bne	$s0,	WHITE,	jT_white1

#down once, right once
	addi	$a2,	$a2,	1
	addi	$a3,	$a3,	1
	
#compares color to white, breaks if it isn't
	jal	check_color
	bne	$s0,	WHITE,	jT_white1	
	
	j	jT_not_white
	
	
	jT_white1:
#restores x and y, goes to inputl oop
	move	$a2,	$t0
	move	$a3,	$t1
	j	input
	
	jT_not_white:
#restores x and y, moves to move right
	move	$a2,	$t0
	move	$a3,	$t1
	j	Tright


Tright:
	la	$t2,	1
	la	$t3,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Tr1
	jump_Tr1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once run
	beqz	$t2,	jump_Tr2
	addi	$t2,	$t2,	-1
	
#whites out piece
	j	clear_T1
	
	jump_Tr2:
#right once
	addi	$a3,	$a3,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Tr3
	jump_Tr3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once run
	beqz	$t3,	jump_Tr4
	addi	$t3,	$t3,	-1
	
#draws piece
	addi	$s0,	$0,	PURPLE
	j	draw_T1
	
	jump_Tr4:
#jumps to inmput loop
	j	input

check_Tleft:
#sotres x and y
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3

#mvoes left once
	addi	$a3,	$a3,	-1	

#checks if color is white, breaks if it sint'
	jal	check_color
	bne	$s0,	WHITE,	Tl_white1
	
#left once, up once
	addi	$a3,	$a3,	-1	
	addi	$a2,	$a2,	-1

#checks if white, breaks if not
	jal	check_color
	bne	$s0,	WHITE,	Tl_white1	
	
	j	Tl_not_white
	
	
	Tl_white1:
#restores x and y, jumps to input loop
	move	$a2,	$t0
	move	$a3,	$t1
	j	input
	
	Tl_not_white:
#restores x adn y, moves to left code
	move	$a2,	$t0
	move	$a3,	$t1
	j	Tleft


Tleft:
	la	$t2,	1
	la	$t3,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Tl1
	jump_Tl1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once run
	beqz	$t2,	jump_Tl2
	addi	$t2,	$t2,	-1
	
#whites out piece
	j	clear_T1
	
	jump_Tl2:
#left once
	addi	$a3,	$a3,	-1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Tl3
	jump_Tl3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once run
	beqz	$t3,	jump_Tl4
	addi	$t3,	$t3,	-1
	
#draws piece
	addi	$s0,	$0,	PURPLE
	j	draw_T1
	
	jump_Tl4:
	j	input	
	
check_Tdown:
#stores x and y
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3
	
	addi	$a3,	$a3,	-1
#lef5t once
	
#breaks if not white
	jal	check_color
	bne	$s0,	WHITE,	Td_white1

#right once, down once
	addi	$a3,	$a3,	1
	addi	$a2,	$a2,	1
	
#breaks if not white
	jal	check_color
	bne	$s0,	WHITE,	Td_white1	
	
#left once, down once
	addi	$a2,	$a2,	-1
	addi	$a3,	$a3,	1
	
#breaks if nto white
	jal	check_color
	bne	$s0,	WHITE,	Td_white1
	
	j	Td_not_white
	
	Td_white1:
#restores x and y, moves to bottom loop
	move	$a2,	$t0
	move	$a3,	$t1
	j	bottom
	
	Td_not_white:
#restores x and y, moves to down
	move	$a2,	$t0
	move	$a3,	$t1
	j	Tdown


Tdown:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Td1
	jump_Td1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once run once
	beqz	$t2,	jump_Td2
	addi	$t2,	$t2,	-1
	
#whites out piece
	j	clear_T1
	
	jump_Td2:
	addi	$a2,	$a2,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack			
	jal	jump_Td3
	jump_Td3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

	beqz	$t3,	jump_Td4
	addi	$t3,	$t3,	-1
	
#draws piece
	addi	$s0,	$0,	PURPLE
	j	draw_T1
	
	jump_Td4:
	j	input	
	
	
	
	
draw_O1:
#draws O piece
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a2,	$a2,	1
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
	
	j	jump_return

clear_O1:
	la	$t2,	1
	addi	$s0,	$0,	WHITE
clear_O2:
#breaks once run once
	beqz	$t2,	clear_O3
	addi	$t2,	$t2,	-1

#draws O in reverse
	addi	$s0,	$s0,	0
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a2,	$a2,	-1
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
clear_O3:	
	j	jump_return	


check_Oright:
#sotres x and y
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3
	
	addi	$a3,	$a3,	2
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Or_white1
	addi	$a2,	$a2,	1	
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Or_white1	

	j	jO_not_white
	Or_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	input
	
	jO_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Oright


Oright:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Or1
	jump_Or1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Or2
	addi	$t2,	$t2,	-1
	j	clear_O1
	
	jump_Or2:
	addi	$a3,	$a3,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Or3
	jump_Or3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Or4
	addi	$t3,	$t3,	-1
	
	addi	$s0,	$0,	YELLOW
	j	draw_O1
	
	jump_Or4:
	j	input

check_Oleft:
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3


	addi	$a3,	$a3,	-1	
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Ol_white1
	addi	$a2,	$a2,	-1

#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Ol_white1	
	
	j	Ol_not_white
	Ol_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	input
	
	Ol_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Oleft


Oleft:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Ol1
	jump_Ol1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Ol2
	addi	$t2,	$t2,	-1
	j	clear_O1
	
	jump_Ol2:
	addi	$a3,	$a3,	-1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack		
	jal	jump_Ol3
	jump_Ol3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Ol4
	addi	$t3,	$t3,	-1
	
	addi	$s0,	$0,	YELLOW
	j	draw_O1
	
	jump_Ol4:
	j	input


check_Odown:
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3

	
	addi	$a2,	$a2,	1
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Od_white1
	addi	$a3,	$a3,	1	
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Od_white1	

	j	Od_not_white
	Od_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	bottom
	
	Od_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Odown


Odown:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Od1
	jump_Od1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Od2
	addi	$t2,	$t2,	-1
	j	clear_O1
	
	jump_Od2:
	addi	$a2,	$a2,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Od3
	jump_Od3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Od4
	addi	$t3,	$t3,	-1
	
	addi	$s0,	$0,	YELLOW
	j	draw_O1
	
	jump_Od4:
	j	input




check_Jright:
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3	

	addi	$a2,	$a2,	-1
	addi	$a3,	$a3,	1	
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Jr_white1
	addi	$a2,	$a2,	1	
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Jr_white1	
	
	j	Jr_not_white
	Jr_white1:
	move	$a3,	$t1
	move	$a2,	$t0
	j	input
	
	
	Jr_not_white:
	move	$a3,	$t1
	move	$a2,	$t0

	j	Jright

Jright:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Jr1
	jump_Jr1:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Jr2
	addi	$t2,	$t2,	-1
	j	clear_J1
	
	jump_Jr2:
	addi	$a3,	$a3,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Jr3
	jump_Jr3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Jr4
	addi	$t3,	$t3,	-1
	
	addi	$s0,	$0,	MAGENTA
	j	draw_J1
	
	jump_Jr4:
	j	input

check_Jleft:
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3


	addi	$a3,	$a3,	-1	

#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Jl_white1
	addi	$a2,	$a2,	-1	
	addi	$a3,	$a3,	-2	
		
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Jl_white2	
	
	j	Jl_not_white
	Jl_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	input
	
	Jl_white2:
	move	$a2,	$t0
	move	$a3,	$t1
	j	input
	
	Jl_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Jleft

Jleft:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Jl1
	jump_Jl1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Jl2
	addi	$t2,	$t2,	-1
	j	clear_J1
	
	jump_Jl2:
	addi	$a3,	$a3,	-1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Jl3
	jump_Jl3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Jl4
	addi	$t3,	$t3,	-1
	
	addi	$s0,	$0,	MAGENTA
	j	draw_J1
	
	jump_Jl4:
	j	input


check_Jdown:
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3	
	
	addi	$a2,	$a2,	1
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Jd_white1
	addi	$a2,	$a2,	-1
	addi	$a3,	$a3,	-1	
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Jd_white1	
	
	addi	$a3,	$a3,	-1
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Jd_white1
	j	Jd_not_white
	
	Jd_white1:
	move	$a3,	$t1
	move	$a2,	$t0
	j	bottom
	
	
	Jd_not_white:
	move	$a3,	$t1
	move	$a2,	$t0

	j	Jdown

Jdown:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Jd1
	jump_Jd1:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Jd2
	addi	$t2,	$t2,	-1
	j	clear_J1
	
	jump_Jd2:
	#addi	$a3,	$a3,	1
	addi	$a2,	$a2,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Jd3
	jump_Jd3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Jd4
	addi	$t3,	$t3,	-1
	
	addi	$s0,	$0,	MAGENTA
	j	draw_J1
	
	jump_Jd4:
	j	input

draw_J1:
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a2,	$a2,	1
	jal	draw_pixel
	
	j	jump_return

clear_J1:
	la	$t2,	1
	addi	$s0,	$0,	WHITE
clear_J2:
#breaks once it has been run through once
	beqz	$t2,	clear_J3
	addi	$t2,	$t2,	-1

	addi	$s0,	$s0,	0
	jal	draw_pixel
	addi	$a2,	$a2,	-1
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
clear_J3:	
	j	jump_return		


draw_L1:
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a2,	$a2,	1
	addi	$a3,	$a3,	-2
	jal	draw_pixel
	

	j	jump_return

clear_L1:
	la	$t2,	1
	addi	$s0,	$0,	WHITE
clear_L2:
#breaks once it has been run through once
	beqz	$t2,	clear_L3
	addi	$t2,	$t2,	-1

	addi	$s0,	$s0,	0
	jal	draw_pixel
	addi	$a2,	$a2,	-1
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
clear_L3:	
	j	jump_return	


check_Lright:
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3
	
	addi	$a3,	$a3,	1
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	jL_white1
	
	
	addi	$a2,	$a2,	-1	
	addi	$a3,	$a3,	2
	jal	check_color
	bne	$s0,	WHITE,	jL_white1	
	
	j	jL_not_white
	jL_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	input

	
	jL_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Lright


Lright:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Lr1
	jump_Lr1:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Lr2
	addi	$t2,	$t2,	-1
	j	clear_L1
	
	jump_Lr2:
	addi	$a3,	$a3,	-1
	
	jal	jump_Lr3
	jump_Lr3:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Lr4
	addi	$t3,	$t3,	-1
	
	addi	$s0,	$0,	ORANGE
	j	draw_L1
	
	jump_Lr4:
	j	input

check_Lleft:
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3


	addi	$a3,	$a3,	-1	

#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Ll_white1
	addi	$a2,	$a2,	-1	
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white		
	jal	check_color
	bne	$s0,	WHITE,	Ll_white1	
	
	j	Ll_not_white
	Ll_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	input

	Ll_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Lleft


Lleft:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Ll1
	jump_Ll1:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Ll2
	addi	$t2,	$t2,	-1
	j	clear_L1
	
	jump_Ll2:
	addi	$a3,	$a3,	-3
	
	jal	jump_Ll3
	jump_Ll3:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Ll4
	addi	$t3,	$t3,	-1
	
	addi	$s0,	$0,	ORANGE
	j	draw_L1
	
	jump_Ll4:
	j	input


check_Ldown:
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3
	
	addi	$a2,	$a2,	1
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Ld_white1
	addi	$a3,	$a3,	1
	addi	$a2,	$a2,	-1

#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Ld_white1	
	addi	$a3,	$a3,	1
	
	jal	check_color
	bne	$s0,	WHITE,	Ld_white1
	addi	$a3,	$a3,	1
	
	j	Ld_not_white
	Ld_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	bottom

	
	Ld_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Ldown


Ldown:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Ld1
	jump_Ld1:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Ld2
	addi	$t2,	$t2,	-1
	j	clear_L1
	
	jump_Ld2:
	addi	$a3,	$a3,	-2
	addi	$a2,	$a2,	1
	jal	jump_Ld3
	jump_Ld3:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Ld4
	addi	$t3,	$t3,	-1
	
	addi	$s0,	$0,	ORANGE
	j	draw_L1
	
	jump_Ld4:
	j	input


draw_I1:
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	addi	$a3,	$a3,	1
	jal	draw_pixel
	

	j	jump_return

clear_I1:
	la	$t2,	1
	addi	$s0,	$0,	WHITE
clear_I2:
	beqz	$t2,	clear_I3
	addi	$t2,	$t2,	-1
	#addi	$s0,	$0,	0
	
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
	addi	$a3,	$a3,	-1
	jal	draw_pixel
clear_I3:	
	j	jump_return	

check_Iright:
	add	$t1,	$0,	$a3
	add	$t0,	$0,	$a2
	
	addi	$a3,	$a3,	1

#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white	
	jal	check_color
	bne	$s0,	WHITE,	jI_not_white

	j	jI_white1
	jI_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	input

	
	jI_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Iright


Iright:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Ir1
	jump_Ir1:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Ir2
	addi	$t2,	$t2,	-1
	j	clear_I1
	
	jump_Ir2:
	addi	$a3,	$a3,	1
	
	jal	jump_Ir3
	jump_Ir3:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Ir4
	addi	$t3,	$t3,	-1
	
	addi	$s0,	$0,	CYAN
	j	draw_I1
	
	jump_Ir4:
	j	input

check_Ileft:
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3


	addi	$a3,	$a3,	-4

#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Il_not_white

	j	Il_white1
	Il_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	input
	
	Il_white1:
	move	$a2,	$t0
	move	$a3,	$t1
	j	Ileft


Ileft:
	la	$t2,	1
	la	$t3,	1
		
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Il1
	jump_Il1:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Il2
	addi	$t2,	$t2,	-1
	j	clear_I1
	
	jump_Il2:
	addi	$a3,	$a3,	-1
	
	jal	jump_Il3
	jump_Il3:
	
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
#breaks once it has been run through once
	beqz	$t3,	jump_Il4
	addi	$t3,	$t3,	-1
	
	addi	$s0,	$0,	CYAN
	j	draw_I1
	
	jump_Il4:
	j	input

check_Idown:
#stores x and y
	add	$t0,	$0,	$a2
	add	$t1,	$0,	$a3


	la	$t2,	1
	la	$t3,	1
	
#moves down once
	addi	$a2,	$a2,	1
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Id_not_white

	addi	$a3,	$a3,	-1
	
#checks what color the pixel is, and breaks out of this part of the code if it is anything other than white
	jal	check_color
	bne	$s0,	WHITE,	Id_not_white	

	addi	$a3,	$a3,	-1
	jal	check_color
	bne	$s0,	WHITE,	Id_not_white

	addi	$a3,	$a3,	-1
	jal	check_color
	bne	$s0,	WHITE,	Id_not_white

	j	Id_white1
	Id_not_white:
	move	$a2,	$t0
	move	$a3,	$t1
	j	bottom

	
	Id_white1:
#restores the x and y, and moves down
	move	$a2,	$t0
	move	$a3,	$t1
	j	Idown


Idown:
	la	$t2,	1
	la	$t3,	1
			
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Id1
	jump_Id1:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
#breaks once it has been run through once
	beqz	$t2,	jump_Id2
	addi	$t2,	$t2,	-1
	
	#addi	$a2,	$a2,	-1
	j	clear_I1
	
	jump_Id2:
	addi	$a2,	$a2,	1
	
#the way that I found best to make sure I can return to a specific spot in the code, since I am adding this $ra onto the stack	
	jal	jump_Id3
	jump_Id3:
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)

#breaks once it has been run through once
	beqz	$t3,	jump_Id4
	addi	$t3,	$t3,	-1
	
#draws the piece
	addi	$s0,	$0,	CYAN
	j	draw_I1
	
	jump_Id4:
	j	input




















##############################################################
exit:
#exits to code
	li	$v0,	10
	syscall

jump_return:
	lw	$ra,	($sp)
	addi	$sp,	$sp,	4
	
	jr	$ra
	
draw_pixel:
	# s1 = address = $gp + 4*(x + y*width)
	mul	$t9, $a2, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$s0, ($t9)	  # store color at memory location
	jr 	$ra
	
check_color:
	mul	$t9, $a2, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	lw	$s0, ($t9)	  # leads color from memory location
	jr	$ra
