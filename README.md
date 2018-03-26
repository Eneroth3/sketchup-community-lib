# SketchUp Community Library (Beta)

## WIP

This project is at an early stage and these project outlines should be seen as a draft.

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

## Usage

The library is designed to be placed in the directory of each extension using it. For simplicity's and usability's sake it is not intended to be a standalone extension or in other ways be shared between extensions.

There are three ways to use this library for your own extensions.

### Copy and Paste Code

Ugly but straightforward. When just one method or two are needed this is the simplest approach.

### Manual Installation

Simple but tedious in the long run.

1. Copy the modules you need from `modules/` into your own extension's directory, e.g. `my_extension/vendor/c-lib/`. Make sure all required dependencies are copied.
2. Edit the copied files to wrap their content in your extension's namespace.
3. Edit the require calls (if any) to point to your own extension, e.g. by prepending `my_extension/vendor/c-lib/` to them.
4. Require the files you need from your own code.

### ~~Automatic Installation with Skippy~~

~~Automation, yay!~~

~~1. Install [Skippy](https://github.com/thomthom/skippy).
2. Follow Skippy's instructions to set up a new project, install this library and use the module you need.
3. Require the files you need from your own code.~~

_As of 2018-03-26 in a pre-release state and not recommended._

## Contribute

1. Read and understand Intent/Scope.
2. Read and understand below guidelines.
3. Create your own fork of this project.
4. Create a new branch for your addition.
5. Do the thing!
6. If the master branch has been updated since you forked, merge master into your development branch. This simplifies testing and merging for the maintainer of this project.
7. Make a pull request.

To load all modules, e.g. for testing, load `tools/loader.rb`.

### Guidelines

* Follow the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide), with the modifications defined by .rubocop.yml.
    * Use [Rubocop-SketchUp](https://github.com/SketchUp/rubocop-sketchup) and make sure your code passes with no offenses.
* If a method could have been an instance method its first argument must be the object that would have been self. For instance `LPoint.between?(point, boundary_a, boundary_b)` should have the point being checked first, not between the other arguments. Code consistency is more important than non-generalizable logic.
* Code comments should tell why the code does what it does, never what it does. That should be obvious from the code itself.
* Document with YARD.
* KISS (keep it simple, stupid).
* Consistency! Consistency! Consistency!
