# EagleCAD

The EagleCAD gem provides tools for working with the files generated by the popular [EagleCAD](http://www.cadsoftusa.com/) PCB design software. 

## Installation

Add this line to your application's Gemfile:

    gem 'eaglecad'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eaglecad

## Usage

```ruby
require 'eaglecad'

drawing = EagleCAD.read('my_schematic.sch')

drawing.write('cloned_schematic.sch')
```
