# SketchUp Community Library (Beta)

## WIP

This project is at a very early stage and these project outlines should be seen as a draft.

## Intent/Scope

The purpose of this library is to:

* prevent developers from reinventing the wheel,
* being long-lived (no fancy front-end web frameworks that are obsolete next Tuesday, please) and
* encourage community members to share knowledge and have fun together!

This should be achieved through:

* simplicity,
* generality and
* consistency.

This library should be easy to grasp and use for new developers, while still being useful for advanced developers.

To prevent the library from being bloated with functionality, try to make your additions as generic as possible and save specific implementations for your own code base. For instance this library has a method for changing the axes of a ComponentDefinition, but if you want to, say, center the axes at the bottom of the BoundingBox, the code for defining the new axes placement will have to be in your own extension/library.

If you have found a way to mimic SketchUp's native [face shading](https://github.com/Eneroth3/FaceShader), created [your own solid operations](https://github.com/Eneroth3/Eneroth-Solid-Tools) or creates some other rather specific functionality that is probably better suited as a separate library, but could be dependent on this one.

If you however have a snippet that is too simple to be published as an individual library and almost generic enough to fit into the API itself, this is the place for it.

### Supported SU versions

No effort should be made to make the library support versions older than SketchUp 2014 (Ruby 2.0.0). Code readability, such as using the &:-idion, matters more than supporting ancient versions. SU 2014 is also the oldest version supporting [TestUp2](https://github.com/SketchUp/testup-2).

Individual methods doesn't have to support SU 2014, e.g. methods related to API features added in a later version, but their documentation must in that case state what the oldest supported version is.

## Installation

The library is designed to be placed in the directory of each extension using it. For simplicity's and usability's sake it is not intended to be a standalone extension or in other ways be shared between extensions.

For now installation is manual (but could be scripted).

1. Copy the content of the source directory (src/) into your extension's directory (e.g. to "my_extension/lib/).
2. Wrap the content of each file with the namespace of your extension.
3. Load the library's loader file from your plugin.

Example of loading script inside an extension's own directory:

    dir_path = __dir__
    dir_path.force_encoding("UTF-8") if dir_path.respond_to?(:force_encoding)
    require(File.join(dir_path, "lib", "su_community_lib.rb"))

## Contribute

1. Read and understand Intent/Scope.
2. Read and below guidelines.
3. [Fork, create a new branch](https://gist.github.com/Chaser324/ce0505fbed06b947d962), do your thing, and make a pull request.
4. ????
5. Profit!

### Guidelines

* Follow the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide), with the modifications defined by .rubocop.yml.
    * Use [Rubocop-SketchUp](https://github.com/SketchUp/rubocop-sketchup) and make sure your code passes with no offenses.
* If a method could have been an instance method its first argument must be the object that would have been self. For instance `LPoint.between?(point, boundary_a, boundary_b)` should have the point being checked first, not between the other arguments. Code consistency is more important than non-generalizable reasoning.
* Code comments should tell why the code does what it does, never what it does. That should be obvious from the code itself.
* Document with YARD.
* KISS (keep it simple, stupid).
* Consistency! Consistency! Consistency!
