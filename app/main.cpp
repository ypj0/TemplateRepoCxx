#include "my_project/greeting.hpp"

#include <iostream>

int main(int argc, char *argv[]) {
    std::cout << my_project::greeting(argc > 1 ? argv[1] : "") << '\n';
}
