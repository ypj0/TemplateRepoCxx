#include "my_project/greeting.hpp"

namespace my_project {
std::string greeting(std::string_view name) {
    if (name.empty()) {
        name = "world";
    }
    return "Hello, " + std::string(name) + "!";
}
} // namespace my_project
