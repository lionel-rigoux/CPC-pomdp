#ifndef LP_SOLVE_DEBUG
#define LP_SOLVE_DEBUG 1

/* prototypes for debug printing by other files */

void debug_print(lprec *lp, char *format, ...);
void debug_print_solution(lprec *lp);
void debug_print_bounds(lprec *lp, REAL *upbo, REAL *lowbo);

#endif
