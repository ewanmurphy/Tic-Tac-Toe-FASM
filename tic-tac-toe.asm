format ELF64 executable

SYS_read   equ 0
SYS_write  equ 1
SYS_open   equ 2
SYS_close  equ 3
SYS_exit   equ 60
SYS_chmod  equ 90
SYS_fchmod equ 91

STDIN        equ 0
STDOUT       equ 1
STDERR       equ 2

STDIN_BUFFERSIZE equ 1024
FILE_BUFFERSIZE equ 1024

EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1


O_RDONLY equ 0o
O_WRONLY equ 1o
O_RDWR   equ 2o
O_CREAT  equ 100o

S_IRUSR equ 0400o
S_IWUSR equ 0200o
S_IXUSR equ 0100o
S_IRGRP equ 0040o
S_IWGRP equ 0020o
S_IXGRP equ 0010o
S_IROTH equ 0004o
S_IWOTH equ 0002o
S_IXOTH equ 0001o

readfile = 0

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
    cmp rax, 0 ;; Check for errors
    jl error
}
macro read fd, buf, count, buff_len_pointer
{
    syscall3 SYS_read, fd, buf, count
    cmp rax, 0 ;; Check for errors
    jl error
    mov qword [buff_len_pointer], rax ;; Writes the number of characters read from file to memory
}
macro open filename, flags, mode, fd_pointer
{
    syscall3 SYS_open, filename, flags, mode
    cmp rax, 0 ;; Check for errors
    jl error
    mov qword [fd_pointer], rax ;; Place file descriptor of opened file in memory
}
macro fchmod fd, mode
{
    syscall2 SYS_fchmod, fd, mode
    cmp rax, 0 ;; Check for errors
    jl error
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
    ;; Conditionally compile different sections of code
if readfile = 1
    ;; Open file
    open text_file_path, (O_CREAT or O_RDWR), 0002, text_fd
    ;; Read contents of file into buffer
    read  [text_fd], file_buff, FILE_BUFFERSIZE, file_buff_len ;; Reads values from file and places them in buffer
    ;; Write contents of file buffer to stdout
    write STDOUT, file_buff, [file_buff_len]
else
    ;; Open file
    open text_file_path, (O_CREAT or O_RDWR), 0002, text_fd
    ;; Read contents of stdin into buffer
    read  STDIN, stdin_buff, STDIN_BUFFERSIZE, stdin_buff_len ;; Reads values from stdin and places them in buffer
    ;; Write contents of stdin buffer to file
    write [text_fd], stdin_buff, [stdin_buff_len]
    ;; Set permissions of file
    fchmod [text_fd], (S_IRUSR or S_IWUSR)
end if

    write STDOUT, msg, msg_len

    ;; Close file
    close [text_fd]
    exit EXIT_SUCCESS

error:
    write STDERR, error_msg, error_msg_len
    close [text_fd]
    exit EXIT_FAILURE

segment readable writable
stdin_buff rb STDIN_BUFFERSIZE
stdin_buff_len dq $ - stdin_buff

file_buff rb FILE_BUFFERSIZE
file_buff_len dq $ - file_buff

text_file_path db "/home/ewan/Documents/FASM/Tic-Tac-Toe/test.txt", 0
text_fd dq -1

msg db 10, "Let's Play Tic Tac Toe", 10      ;; Sequence of bytes in memory with the characters "Hello, World!" with a new line terminator
msg_len = $ - msg               ;; Length of message

error_msg db "Error!", 10                                  ;; Sequence of bytes in memory with the characters "Hello, World!" with a new line terminator
error_msg_len = $ - error_msg                              ;; Length of message
