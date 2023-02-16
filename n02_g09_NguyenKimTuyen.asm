.eqv SEVENSEG_LEFT    0xFFFF0011 				# Dia chi cua den led 7 doan trai	
								# Bit 0 = doan a         
								# Bit 1 = doan b	
								# Bit 7 = dau . 
.eqv SEVENSEG_RIGHT   0xFFFF0010 				# Dia chi cua den led 7 doan phai 
.eqv IN_ADRESS_HEXA_KEYBOARD       0xFFFF0012  		# Command row number of hexadecimal keyboard (bit 0 to 3)
.eqv OUT_ADRESS_HEXA_KEYBOARD      0xFFFF0014		# Receive row and column of the key pressed
.eqv KEY_CODE   0xFFFF0004         				# ASCII code from keyboard, 1 byte 
.eqv KEY_READY  0xFFFF0000        				# =1 if has a new keycode ?                                  
				        			# Auto clear after lw  
.eqv DISPLAY_CODE   0xFFFF000C   				# ASCII code to show, 1 byte 
.eqv DISPLAY_READY  0xFFFF0008   				# =1 if the display has already to do  
	                                			# Auto clear after sw  
.eqv MASK_CAUSE_KEYBOARD   0x0000034     			# Keyboard Cause    
  

# Message to user and declare for store string, value
.data 
	numDisplay:	.byte 63,6,91,79,102,109,125,7,127,111 	# Segment value
	array:		.space 1000				# Reserves space for input string
	originalString: .asciiz "ao that day" 			# Pattern original
	notify: 	.asciiz "\n So ky tu trong 1s :  "	# Message show typing speed
	info: 		.asciiz "\n Toc do trung binh trong 1s: "	# Message show typing speed
	message: 	.asciiz  "\n So ky tu nhap dung la: "  	# Message show accuracy
	notification: 	.asciiz "\n Quay lai chuong trinh? "	

#Program
.text
#MAIN Program
MAIN:
Begin:	li	$k0, KEY_CODE              
	li   	$k1, KEY_READY                    
	li   	$s0, DISPLAY_CODE              
	li   	$s1, DISPLAY_READY 
	
	li	$a2, 0						# Dem so thoi gian nhap
	li 	$s4, 0 						# Dem so ky tu nhap vao
	li 	$s7, 10						# Bien dung de tinh toan thoi gian hien thi
  	li 	$s5, 100					# Luu gia tri so vong lap = 100

	jal INPUT						# Procedure nhan string tu nguoi dung
	nop
	jal COMPARE						# Procedure so sanh string duoc nhap voi string goc
	nop
	jal DISPLAY						# Hien thi so ki tu nhap dung tren Digital Lab Sim
	nop
	jal ASK							# Hoi nguoi dung co muon chay tiep chuong trinh
	nop
	beq $a0, 0, Begin
	nop
Quit:	li $v0, 10						#Exit program
	syscall
endMain:
# PROCEDURE
#--------------------------------------------------------------
#Input string of from user
#Input: String in Keyboard Simulator
#Output: String from user	
INPUT:
  	li 	$s3,0						# Dem so vong lap 
	li 	$t6,0						# Dem so ky tu nhap duoc trong 1s
	addi	$sp, $sp, -4					# size stack
	sw	$ra, 0($sp)					# save $ra to stack
	nop
	
LOOP: 		
WAIT_FOR_KEY:	
	lb 	$t1, 0($k1) 			# $t1 = [$k1] = KEY_READY
 	nop
 	beq 	$t1, $zero, CONTINUE 		# if $t1 == 0 then Polling
 	nop
INCRE_CHAR:	
 	addi 	$t6,$t6,1    			# Tang bien dem ky tu nhap duoc trong 1s len 1
	teqi 	$t1, 1                       	# if $t1 = 1 tao ngoai le 
	nop
	beq	$v0, 1, INCOM			# $v1 = 1 -> ket thuc string boi '\n' -> out procedure (vi khi truoc do se in ra duoc roi, v0 =1 nen o day se nhay xuong INCOME luon) 
	nop
CONTINUE:					# Check 100 vong trong 1s
	addi    $s3, $s3, 1      		# Dem so vong lap
	div 	$s3, $s5			# Lay so vong lap chia cho 100 de xac dinh da duoc 1 chu ky hay chua
	mfhi 	$t7				# Luu phan du cua phep chia tren
	bne 	$t7,0, SLEEP			# Neu chua duoc 1s nhay den label sleep
	nop
RESETCOUNT:					# Neu da dat 1s
	li	$s3, 0				# Reset $t3 ve 0 de dem lai so ky tu cho 1s tiep theo
	li 	$v0, 4				# In ra console message so ky tu nhap duoc trong 1s
	la 	$a0, notify
	syscall	
	li    	$v0,1            		# In ra so ky tu trong 1s
	add   	$a0,$t6,$zero    		
	syscall
			
	addi	$a2, $a2, 1			# Tinh tong thoi gian da go
			
	move	$v1, $t6			# Hien thi so ky tu nhap duoc trong 1s ra Lab Sim
	jal	DISPLAY				# Goi thu tuc hien thi ra LED, $v1 la dau vao thu tuc
	nop					# $v1 luu so ky tu can duoc hien thi
			
	li    	$t6,0				# Reset so ky tu trong 1s
	nop
SLEEP:  
	addi    $v0,$zero,32                   	# Function sleep
	li      $a0,10              		# Sleep 10 ms         
	syscall         
	nop           	          		# Prevent bug from Mars          
	j       LOOP          	 		# Loop 
	nop
INCOM:
	lw	$ra, 0($sp)			#load $ra
	nop
	addi	$sp, $sp, 4			#reset $sp	
	jr	$ra				#return ra
	nop
		
#--------------------------------------------------------------
# So sanh chuoi nguoi dung nhap voi chuoi goc
# Input: $s4: so ki tu nhap vao tu nguoi dung, array user input string
# Output: $v1 chua so ky tu duoc nhap chinh xac		
COMPARE:
	li 	$v0, 11         				# Ham 11 de in ky tu
	li 	$a0, '\n'         				# In xuong dong
	syscall 
	nop
	li 	$t1, 0 						# Dem so ky tu da duoc xet
	li 	$t3, 0                         			# Dem so ky tu nhap dung
	li 	$t8, 23						# Do dai pattern goc
	slt 	$t7, $s4, $t8					# Duyet theo xau co do dai ngan hon giua string goc
								# va string nguoi dung nhap
	bne 	$t7, 1, CHECK_STRING				# If string goc nho hon -> branch
	nop
	add 	$t8, $0, $s4					# Else $t8 = $s4 = do dai user's string
	addi 	$t8, $t8, -1					# Khong xet ky tu '\n' o cuoi string
	
CHECK_STRING:			
	la 	$t2, array			# Lay string duoc nguoi dung nhap vao
	add 	$t2, $t2, $t1			# Lay vi tri ki tu thu $t1
	li 	$v0, 11				# Func print char. In lan luot cac string duoc nhap tu ban phim.
	lb 	$t5,0($t2)			# Lay ky tu thu $t1 trong array luu vao $t5 
	nop					# de so sanh voi ky tu thu $t1 o originalString
	move 	$a0, $t5			
	syscall 
	nop
	la 	$t4, originalString
	add 	$t4, $t4, $t1			# Lay vi tri ki tu thu $t1 
	lb 	$t6, 0($t4)			# Lay ky tu thu $t1 trong originalString luu vao $t6
	nop
	bne 	$t6, $t5, NEXT			#neu 2 ky tu thu $t1 giong nhau thi tang bien dem so ky tu dung len 1
	nop
	addi 	$t3,$t3,1			# Tang so ky tu nhap dung o $t3
		
NEXT: 
	addi 	$t1, $t1, 1			# Sau khi so sanh 1 ky tu, tang bien dem len 1
	beq 	$t1, $t8, PRINT			# Duyet het so ky tu can xet thi in ra man hinh so ky tu nhap dung
	nop
	j 	CHECK_STRING			# Con khong thi tiep tuc xet tiep cac ky tu 
	nop
			
PRINT:	
	li 	$v0, 4				# Func print string so ky tu nhap dung
	la 	$a0, info			# Thong bao toc do trung binh
	syscall
	
  	
	div	$s4, $a2
	mflo	$t7
	li 	$v0, 1				# Func print toc do trung binh
	add 	$a0, $0, $t7			# $t7 = toc do trung binh
	
	syscall
	nop
			
	li 	$v0, 4				# Func print string so ky tu nhap dung
	la 	$a0, message			# Message cho ham
	syscall
	li 	$v0, 1				# Func print so ky tu nhap dung (int)
	add 	$a0, $0, $t3			# $t3 = so ky tu nhap dung
	syscall
	nop

	li 	$v1, 0				# Sau khi ket thuc chuong trinh,
	add 	$v1, $0, $t3			# so ky tu nhap dung duoc luu vao $v1
			
	jr 	$ra						# tro lai chuong trinh chinh
	nop

#--------------------------------------------------------------
# Hien thi so ra Digital Lab Sim
#Input: $v1 chua so ky tu can hien thi
#Output: Hien thi ra Digital Lab Sim		
DISPLAY:
	addi	$sp, $sp, -4					# Khoi tao con tro stack
	sw	$ra, 0($sp)					# Save $ra to stack
	nop
	
	move	$t6, $v1					# Lay so ky tu can hien thi tu $v1
	div 	$t6, $s7					# Lay tong so ky tu chia cho 10
	mflo 	$t7						# Gia tri phan nguyen, duoc in ra o den LED ben trai
	la 	$s2, numDisplay					# Lay danh sach gia tri cua tung chu so tren den LED
	add 	$s2, $s2, $t7					# Xac dia chi cua gia tri 
	lb 	$a0, 0($s2)                 			# Lay noi dung cho vao $a0           
	jal   	SHOW_7SEG_LEFT       				# Show
	nop
	
#------------------------------------------------------------------------
	mfhi 	$t7						# Gia tri phan du cua phep chia, duoc in ra o den LED ben phai
	la 	$s2, numDisplay					# Lay danh sach gia tri cua tung chu so tren den LED
	add 	$s2, $s2, $t7					# Xac dia chi cua gia tri
	lb 	$a0, 0($s2)                			# Lay noi dung cho vao $a0           
	jal  	SHOW_7SEG_RIGHT      				# Show
	nop  
	
	lw	$ra, 0($sp)					# load $ra
	nop
	addi	$sp, $sp, 4					# reset $sp	
	jr	$ra						# return ra
	nop
	
SHOW_7SEG_LEFT:  
	li   	$t0, SEVENSEG_LEFT 				# assign port's address                   
	sb   	$a0, 0($t0)        				# assign new value                    
	jr    	$ra 
	nop
SHOW_7SEG_RIGHT: 
	li   	$t0, SEVENSEG_RIGHT 				# assign port's address                  
	sb   	$a0, 0($t0)         				# assign new value                   
	jr   	$ra 
	nop
	
	
#--------------------------------------------------------------
# Hoi nguoi dung co muon chay lai chuong trinh
# Output: $a0 = 0 neu nguoi dung muon tiep tuc
ASK:
	li $v0, 50						# Ham hoi nguoi dung co muon chay lai
	la $a0, notification					# Hien thong bao
	syscall
	nop
	
	bnez	$a0, end_ask					# Nguoi dung muon chay lai
	li	$t0, 0						# bien dem
	la	$t1, array					# Load string nguoi dung nhap
	reset:							# Reset loop
		beq	$t0, $s4, end_ask			# Neu bien dem = so ki tu trong array
		nop
		sw	$zero, 0($t1)				# Set gia tri tai moi vi tri = 0
		nop
		addi	$t0, $t0, 1				# Tang bien dem
		addi	$t1, $t1, 1				# Dich chuyen vi tri tren array
		j 	reset					# Lap lai
		nop
		
	end_ask:
	jr $ra
	nop
#---------------------------------------------------------------
# Interrupt subroutine
#---------------------------------------------------------------
.ktext	0x80000180
get_caus: 	mfc0 	$t1, $13 				# $t1 = Coproc0.cause
IsCount: 	li 	$t2, MASK_CAUSE_KEYBOARD		# if Cause value confirm Keyboard..
 		and 	$at, $t1,$t2
 		beq 	$at,$t2, Counter_Keyboard
 		nop
 		j 	end_process
		nop
Counter_Keyboard:	
ReadKey: 	lb 	$t0, 0($k0) 				# $t0 = [$k0] = KEY_CODE
		nop
		
WaitForDis: 	lb 	$t2, 0($s1) 				# $t2 = [$s1] = DISPLAY_READY
		nop
 		beq 	$t2, $zero, WaitForDis 			# if $t2 == 0 then Polling
 		nop
check:		
 		beq	$t0, 10, ShowKey			# Van nhan enter
 		blt	$t0, 32, end_process			# Kiem tra ki tu thuoc khoang 32 den 127
 		bgt	$t0, 127, end_process			# 	trong bang ascii

ShowKey:	
	 	sb 	$t0, 0($s0) 				# show key
		nop
		la  	$t7, array				# lay $t7 lam dia chi co so cua chuoi nhap vao
             	add 	$t7, $t7, $s4				# Lay vi tri de luu ky tu moi
             	sb 	$t0, 0($t7)				# Dua ky tu moi vao array
             	nop
             	addi 	$s4, $s4, 1				# Tang bien dem ky tu len 1
             	bne 	$t0, 10, end_process   			# If input character la '\n'
             	nop
             	li 	$v0, 1					# then $v0 = 1 -> end of String
             	
end_process:
next_pc: 	mfc0 $at, $14 					# $at <= Coproc0.$14 = Coproc0.epc
 		addi $at, $at, 4 				# $at = $at + 4 (next instruction)
 		mtc0 $at, $14 					# Coproc0.$14 = Coproc0.epc <= $at
return: 	eret 						# Return from exception
