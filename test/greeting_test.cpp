#include "my_project/greeting.hpp"

#include <iostream>
#include <string_view>

int main() {
    if (my_project::greeting("") != "Hello, world!") {
        std::cerr << "Empty names should use the default greeting\n";
        return 1;
    }
    if (my_project::greeting("C++20") != "Hello, C++20!") {
        std::cerr << "Named greeting is incorrect\n";
        return 1;
    }
    // A string_view need not end at the backing string's null terminator.
    if (my_project::greeting(std::string_view("Alice extra", 5)) !=
        "Hello, Alice!") {
        std::cerr << "Greeting must respect string_view length\n";
        return 1;
    }
}
