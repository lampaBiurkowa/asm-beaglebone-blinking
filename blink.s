.section .data
export_path: .asciz "/sys/class/gpio/export"
unexport_path: .asciz "/sys/class/gpio/unexport"
gpio_direction: .asciz "/sys/class/gpio/gpio73/direction"
gpio_value: .asciz "/sys/class/gpio/gpio73/value"
out_str: .asciz "out"
high_str: .asciz "1"
low_str: .asciz "0"

.section .text
.global _start

.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_CLOSE, 6
.equ SYS_NANOSLEEP, 162
.equ BLINKS_COUNT, 5

_start:
    ldr r0, =gpio_direction
    ldr r1, =out_str
    mov r2, #3
    bl write_sysfs

    mov r4, #BLINKS_COUNT
blink_loop:
    ldr r0, =gpio_value
    ldr r1, =high_str
    mov r2, #1
    bl write_sysfs

    bl delay

    ldr r0, =gpio_value
    ldr r1, =low_str
    mov r2, #1
    bl write_sysfs

    bl delay
    
    subs r4, r4, #1
    bne blink_loop

    mov r7, #1
    swi 0

write_sysfs:
    push {fp, lr}
    mov fp, sp
    sub sp, sp, #8
    str r1, [fp, #-4] //value
    mov r7, #SYS_OPEN
    mov r1, #1 //O_WRONLY
    swi 0
    str r0, [fp, #-8] //fd

    mov r7, #SYS_WRITE
    ldr r0, [fp, #-8]
    ldr r1, [fp, #-4]
    @r2 already has length
    swi 0

    mov r7, #SYS_CLOSE
    ldr r0, [fp, #-8]
    swi 0

    add sp, sp, #8
    pop {fp, pc}

delay:
    push {fp, lr}
    mov fp, sp
    sub sp, sp, #8
    mov r1, #1 //seconds
    mov r2, #0 //nanoseconds

    str r1, [fp, #-8]
    str r2, [sp, #-4]
    mov r0, sp
    mov r7, #SYS_NANOSLEEP
    swi 0

    add sp, sp, #8
    pop {fp, pc}
