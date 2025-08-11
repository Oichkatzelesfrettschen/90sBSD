/* Minimal static ELF smoke test. */
__attribute__((noreturn)) void _start(void) {
    for (;;) {
        __asm__ __volatile__("hlt");
    }
}
