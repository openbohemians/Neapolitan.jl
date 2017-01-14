module Neapolitan

import YAML
#import JSON
import Mustache
import Base.Markdown

export render

# Document it parsed into sections.
type Section
  tag::String
  text::Any
end

# Render neapolitan stream given in the form of String.
function render(content::String)
  sections = parse(content)
  text = render(sections)
  text
end

#
# TODO We need a way to specify that the section does not need mustache.
#
# TODO Can sections support layouts too?
#
# TODO Store front matter data for possible access?
#
function render(sections::Array{Section})
  data = Dict{String,Any}()
  text = String[]

  for section in sections
    if section.tag == "metadata"
      merge!(data, yaml(section.text))
    elseif section.tag == "markdown"
      push!(text, markdown(mustache(section.text, data)))
    elseif section.tag == "html"
      push!(text, mustache(section.text, data))
    end
  end

  # join the section texts and return it
  str = join(text, "\n")

  # return text and data
  return str #, data

  # TODO: the layout too might need a layout render!
  #mustache(layout, data)
end

#
function parse(content::String)
  parse(IOBuffer(content))
end

#
function parse(content::IO)
  sections = Array(Section, 0)

  text = ""
  tag  = ""

  for line in readlines(content)
    if startswith(line, "---")
      if text != ""
        tag, val = guess(tag, text)
        push!(sections, Section(tag, val))
      end
      text = ""
      tag  = replace(strip(line), r"---\s*[!]*", "")
    else
      text = text * line
    end
  end

  if strip(text) != ""
    tag, val = guess(tag, text)
    push!(sections, Section(tag, val))
  end

  sections
end

# If the section is undecorated, try to guess its type.
function guess(tag::String, text::String)
  if tag == ""
    text = strip(text)
    if startswith(text, "<")
      tag = "html"
    elseif startswith(text, "#")
      tag = "markdown"
    elseif ismatch(r"\A\w+\:", text)
      tag = "metadata"
    else
      tag = "markdown"
    end
  end

  #if tag == "metadata"
  #  return tag, yaml(text)
  #else
    return tag, text
  #end
end

# Load YAML.
function yaml(text::String)
  YAML.load(text) #.raw
end

# Apply mustache templating.
function mustache(template, data)
 	Mustache.render(template, data)
end

# Convert Markdown to HTML.
function markdown(text)
  Markdown.html(Markdown.parse(text))
end

end

