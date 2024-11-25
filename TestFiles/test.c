//
//  test.c
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//
/* test support for left and right shift operations where the right operand
 * (i.e. the shift count) is the result of another expression, not a constant.
 */

#ifdef SUPPRESS_WARNINGS
#ifdef __clang__
#pragma clang diagnostic ignored "-Wshift-op-parentheses"
#else
#pragma GCC diagnostic ignored "-Wparentheses"
#endif
#endif

int main(void) {
    return 40 << 4 + 12 >> 1;
}
