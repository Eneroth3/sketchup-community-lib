# SketchUp Standard Library

## WIP

This project is at a very early stage and not even the project outlines have been fully defined yet. Read at your own risk :P ! Beware of internet jokes and smileys :O !

## Intent/Scope

The purpose of this library is to fill in gaps of missing features in the SketchUp Ruby API. This was intended as a running text, not a list, but since I'm not sure myself yet of the purpose of this projects here's a lits for ya:

- Not having each developer re-inventing the wheel.
- Long term (no new fancy front end frameworks that are obsolete next Tuesday).
- Generic utility stuff/Not too specific. If you code solid operators or mimic SketchUp's own face shading, please publish that as a separate library instead.

## Installation

1. Copy the library (SUStandardLib/) into your extension's directory, e.g. to "my_extension/lib/SUStandardLib".
2. Wrap in your extension's namespace by replacing "ExampleExtensionModule", e.g. with "MyExtension".
3. Load the library's loader file from your own extension, e.g. by adding `require(File.join(File.dirname(__FILE__)), "lib", "SUStandardLib", "loader.rb")` inside your main extension file (a file inside "my_extension/").

## Contribute

1. Read and understand Intent/Scope.
2. Do stuff
3. ????
4. Profit!
