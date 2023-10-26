format ELF64 executable

SYS_read  equ 0
SYS_write equ 1
SYS_exit  equ 60

STDIN        equ 0
STDOUT       equ 1
STDERR       equ 2

STDIN_BUFFERSIZE equ 1024

EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1

macro syscall1 syscallId, a
{
    mov rax, syscallId ;; Write syscallId to rax register, telling the OS which syscall to perform
    mov rdi, a         ;; Write first parameter to the rdi register
    syscall            ;; Ask operating system to perform system call
}
macro syscall2 syscallId, a, b
{
    mov rax, syscallId ;; Write syscallId to rax register, telling the OS which syscall to perform
    mov rdi, a         ;; Write first parameter to the rdi register
    mov rsi, b         ;; Write second parameter to the rsi register
    syscall            ;; Ask operating system to perform system call
}
macro syscall3 syscallId, a, b, c
{
    mov rax, syscallId ;; Write syscallId to rax register, telling the OS which syscall to perform
    mov rdi, a         ;; Write first parameter to the rdi register
    mov rsi, b         ;; Write second parameter to the rsi register
    mov rdx, c         ;; Write third parameter to the rdx register
    syscall            ;; Ask operating system to perform system call
}
macro write fd, buf, count
{
    syscall3 SYS_write, fd, buf, count
}
macro read fd, buf, count
{
    syscall3 SYS_read, fd, buf, count
}
macro close fd
{
    syscall1 SYS_close, fd
}
macro exit code
{
    syscall1 SYS_exit, code
}

segment readable executable
entry main
main:
    read  STDIN, stdin_buff, STDIN_BUFFERSIZE ;; Reads values from stdin and places them in buffer
    cmp rax, 0 ;; Check for errors
    jl error
    mov qword [stdin_buff_len], rax ;; Writes the number of characters read from stdin to memory

    write STDOUT, stdin_buff, [stdin_buff_len]

    write STDOUT, msg, msg_len

    exit EXIT_SUCCESS

error:
    write STDERR, error_msg, error_msg_len
    exit EXIT_FAILURE

segment readable writable
stdin_buff rb STDIN_BUFFERSIZE
stdin_buff_len dq $ - stdin_buff

msg db "Let's Play Tic Tac Toe", 10      ;; Sequence of bytes in memory with the characters "Hello, World!" with a new line terminator
msg_len = $ - msg               ;; Length of message

error_msg db "Error!", 10                                  ;; Sequence of bytes in memory with the characters "Hello, World!" with a new line terminator
error_msg_len = $ - error_msg                              ;; Length of message
