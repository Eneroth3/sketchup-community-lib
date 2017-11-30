# SketchUp Standard Library (Beta)

## WIP

This project is at a very early stage and not these project outlines should be seen as a draft.

## Intent/Scope

The purpose of this library is to:

* prevent developers from reinventing the wheel,
* being long-lived (no fancy front-end web frameworks that are obsolete next Tuesday, please) and
* encourage community members to share knowledge and have fun together!

This should be achieved by:
* simplicity,
* generality and
* consistency.

This library should be easy to grasp and use for new developers, while still being useful for advanced developers.

To prevent the library from being bloated with functionality, try to make your additions as generic as possible and save specific implementations for your own code base. For instance this library has a method for changing the axes of a ComponentDefinition but if you want to center the axes onto the geometry the code for defining the new axes placement will have to be in your own extension.

If you have found a way to mimic SketchUp's native [face shading](https://github.com/Eneroth3/FaceShader), created [your own solid operations](https://github.com/Eneroth3/Eneroth-Solid-Tools) or creates some other rather specific functionality that is probably better suited as a separate library, but could be dependent on this one.

### Supported SU versions

This is not yet decided. However ancient versions should NOT be supported at the cost of code readability. For instance the &:-idiom must be supported (Ruby 1.8.7+ / SU 2014+).

## Installation

The library is designed to be placed in the directory of each extension using it. For simplicity's sake it is not intended to be a standalone extension or in other ways shared between extensions.

For now installation is manual (but could be scripted).

1. Copy the library directory (SUStandardLib/) into your extension's directory (e.g. to "my_extension/lib/SUStandardLib/).
2. Wrap the content of each file with the namespace of your extension.
3. Load the library's loader file from your plugin, e.g. by adding `require(File.join(File.dirname(__FILE__)), "lib", "SUStandardLib", "loader.rb")` inside your main extension file (a file inside "my_extension/").

## Contribute

1. Read and understand Intent/Scope.
2. Maybe fork, edit and make a Pull Request, I dunno how this typically works.
3. ????
4. Profit!

Guidelines:
* Follow the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide), with the modifications defined by .rubocop.yml.
* If a method could have been a class instance method its first argument must be the object that would have been self. For instance `Point.between?(point, boundary_a, boundary_b)` should have the point being checked first, not between the other arguments. Code consistency is more important than non-generalizable reasoning.
* KISS (keep it simple, stupid).
* Comments should tell why the code does what it does, never what it does. That should be obvious from the code itself.
* Document with YARD.
* Consistency! Consistency! Consistency!
