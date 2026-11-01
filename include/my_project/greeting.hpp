#pragma once

#include <string>
#include <string_view>

namespace my_project {
[[nodiscard]] std::string greeting(std::string_view name);
} // namespace my_project
