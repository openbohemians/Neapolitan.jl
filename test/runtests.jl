push!(LOAD_PATH, joinpath(pwd(), "src"))

using Neapolitan
using Base.Test

#

source = """
---
# Example
"""

result = Neapolitan.render(source)

@test result == "<h1>Example</h1>\n"

#

source = """
---
title: Example Title
---
# {{title}}
"""

result = Neapolitan.render(source)

@test result == "<h1>Example Title</h1>\n"

