/* heading.h */
#ifndef _defs_h_
#define _defs_h_

#include <string>
#include <vector>

struct Node {
    std::string code;
    std::string name;
};
struct Args {
    int num;
    std::vector<std::string> args;
};
#endif
