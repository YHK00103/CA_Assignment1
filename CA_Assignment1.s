.data
num1: .word 1, 1, 0, 1, 1, 1
numSize1: .word 6
num2: .word 1, 0, 1, 1, 0, 1
numSize2: .word 6
num3: .word 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
numSize3: .word 35
str1: .string "Maximum number of consecutive 1's :"
str2: .string "\n"

.text
# main function in RISC-V assembly
main:
    # num1 case
    la a0, num1                 
    lw a1, numSize1                
    jal ra, findMaxConsecutiveOnes

    mv t0, a0                       
    la a0, str1    
    li a7, 4          
    ecall

    mv a0, t0
    li a7, 1             
    ecall
                     
    la a0, str2    
    li a7, 4          
    ecall

    # num2 case
    la a0, num2                 
    lw a1, numSize2                
    jal ra, findMaxConsecutiveOnes

    mv t0, a0                       
    la a0, str1    
    li a7, 4          
    ecall

    mv a0, t0
    li a7, 1             
    ecall

    la a0, str2    
    li a7, 4          
    ecall

    # num3 case
    la a0, num3                 
    lw a1, numSize3               
    jal ra, findMaxConsecutiveOnes

    mv t6, a0                       
    la a0, str1    
    li a7, 4          
    ecall

    mv a0, t6
    li a7, 1             
    ecall

    la a0, str2    
    li a7, 4          
    ecall
    
    # Exit the program
    li a7, 10                  # System call code for exiting
    ecall

# my_clz function in RISC-V assembly
# Input: 32-bit unsigned integer x (passed via a0)
# Output: count of leading zeros (returned in a0)

my_clz:
    li t2, 1                   # t2 = 1U
    li t1, 31                  # t1 = i = 31
    li t0, 0                   # t0 = count

my_clz_loop:
    sll  t3, t2, t1            # t3 = 1U << i
    addi t1, t1, -1            # t1 = i--
    and t3, a0, t3             # t3 = x & (1U << i)
    bnez t3, my_clz_end        # if ((x & (1U << i)) == 1), goto my_clz_end
    addi t0, t0, 1             # t0 = count++
    bgez t1, my_clz_loop       # if (i >= 0), goto my_clz_loop
    
my_clz_end:
    mv a0, t0                 
    ret

# findMaxConsecutiveOnes function in RISC-V assembly
# Input: pointer to array *num, interger numSize (passed via a0 and a1)
# Output: max consecutive ones (returned in a0)

findMaxConsecutiveOnes:
    li s0, 0                   # s0 = maxCount = 0
    srli s3, a1, 5             # s3 = set = (numSize >> 5)
    beqz a1, for_loop_end      # if (numsSize == 0), goto for_loop_end 
    li s1, 0                   # s1 = currentCount = 0
    slli s3, s3, 5             # s3 = set = (numSize >> 5) << 5
    li s2, 32                  # s2 = wordSize = 32
    li s4, 0                   # s4 = packed = 0
    addi s5, s3, 0             # s5 = i = set
    li s6, 0                   # s6 = j = 0
    j for_loop

for_loop:
    bgez s5, pack_bits         # if (i >= 0), goto pack_bits
    sub t5, s1, s0             # t5 = currentcount - maxCount
    bgez t5, update_maxCount2 # if (currentCount >= maxCount), goto update_maxCount2
    j for_loop_end

    # if-else structure 2
    sub t6, s1, s0             # t6 = currentCount - maxCount
    bgez t6, update_maxCount2  # if (currentCount - maxCount >= 0), goto update_maxCount2
    j for_loop_end
    
for_loop_update:
    sub s5, s5, s2             # s1 = i -= wordSize
    j for_loop

pack_bits:
    add t0, s5, s6             # t0 = i + j
    slli, t4, t0, 2            # t4 = (i+j) * 4
    sub t1, s6, s2             # t1 = j - wordSize
    add t3, a0, t4             # t4 = nums[i+j] address
    sub t2, t0, a1             # t2 = (i+j) - numsSize
    bgez t1, check_packed      # if (j - wordSize >= 0), goto check_packed
    lw t3, 0(t3)               # t3 = num[i+j] value
    bgez t2, check_packed      # if (((i+j) - numsSize) >= 0), goto check_packed
    sll t3, t3, s6             # t3 = num[i+j] << j
    addi s6, s6, 1             # s6 = j++
    li s8, 0xFFFFFFFF          # s8 = 0xFFFFFFFF
    or s4, s4, t3              # s4 = packed |= (nums[i + j] << j);
    j pack_bits

check_packed:
    sub t4, s4, s8             # t4 = packed - 0xFFFFFFFF
    li s7, 32                  # s7 = counter = 32
    li s6, 0                   # s6 = j = 0
    beqz t4, update_currentCount # if (packed == 0xFFFFFFFF), goto update_currentCount
    bgez s7, while_loop        # if (counter >= 0), goto, while_loop

update_currentCount:
    add s1, s1, s2              # s1 = currentCount += wordSize
    sub s5, s5, s2              # s1 = i -= wordSize
    j for_loop_update

while_loop:
    # check while_loop condition
    beqz s7, for_loop_update    # if (counter == 0), goto for_loop_update
    
    # call my_clz
    addi sp, sp, -24            #store ra and a0 to stack before calling my_clz
    sw ra, 24(sp)
    sw a0, 20(sp)
    sw t0, 16(sp)
    sw t1, 12(sp)
    sw t2, 8(sp)
    sw t3, 4(sp)
    mv a0, s4                   # a0 = packed
    jal ra, my_clz              
    mv s9, a0                   # s9 = leadingZeros = my_clz(packed)
    lw ra, 24(sp)
    lw a0, 20(sp)                 
    lw t0, 16(sp)
    lw t1, 12(sp)
    lw t2, 8(sp)
    lw t3, 4(sp)
    addi sp, sp, 24

    sll s4, s4, s9              # s4 = packed <<= leadingZeros
    sub s7, s7, s9              # s7 = counter -= leadingZeros
    
    # if-else structure 1
    beqz s9, update_currentCount2  # if (leadingZeros == 0), goto update_currentCount2
    sub t5, s1, s0              # t5 = currentcount - maxCount
    bgez t5, update_maxCount1   # if (currentCount - maxCount >= 0), goto update_maxCount1

update_currentCount2:
    addi s7, s7, -1             # s7 = counter -= 1
    addi s1, s1, 1              # s1 = currentCount++
    slli s4, s4, 1              # s4 = packed <<= 1
    j while_loop

update_maxCount1:
    mv s0, s1                   # s0 = maxCount = currentCount
    li s1, 0                    # s1 = currentCount = 0
    j while_loop

update_maxCount2:
    mv s0, s1                   # s0 = maxCount = currentCount
    j for_loop_end

for_loop_end:
    mv a0, s0                   # return maxCount
    ret
