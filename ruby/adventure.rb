#!/usr/bin/ruby
# Working on http://ruby.learncodethehardway.org/book/ex36.html

# Instead of a complicated parsing of every command
# with hand-crafted responses for each case, try
# to craft some reusable functions, and possibly
# develop object system for things you can come
# across--so then there's a vocabulary of VERBs
# that can act upon OBJECTs.  help command would be
# nice as well.

# VERBs
# You can TAKE, OPEN, EXAMINE, GO (or is GO just a
# synonym for TAKE, except you can only have one GO
# object at a time?), TALK TO, DESTROY/KILL, USE,
# COMBINE(?), etc. -- we can make dynamic calls to
# objects using obj.send(string), check if it's there
# with obj.methods.index(string) != nil
#
# Looking at https://twitter.com/textadventurer notice
# that it's basically VERB OBJECT with rare prepositions
# and 2nd OBJECTs, and sometimes 3-word samples where 
# 3rd word is either part of the OBJECT (trap door) or 
# part of the VERB (turn off)

# So then Class system with methods that inherit from
# base Item Class and methods are directly associated with
# VERBs -- instead of OBJECTs let's call 'em ITEMs since
# we're using an object-based system already.

# learning classes, see
# http://juixe.com/techknow/index.php/2007/01/22/ruby-class-tutorial/
class Entity
    attr_accessor :description, :name

    def initialize(name, description)
        @name = name
        @description = description
    end

    def to_s
        @name
    end

    def action(verb)
        if self.methods.index(verb) != nil
            self.send(verb)
        else
            puts "I don't know how to #{verb} #{self}"
        end
    end
    # TODO: represent container aspect, e.g. room has Items,
    # Items contain other Items
end

class Item < Entity
    attr_accessor :in_inventory

    def initialize(name, description)
        @name = name
        @description = description
        # TODO: consider using location and make inventory
        # a special-case Entity/Item
        @in_inventory = false # should we take as argument?
    end

    # return all items currently in inventory
    def self.inventory()
        items = []
        ObjectSpace.each_object(Item) { |o|
            items.push(o) if o.in_inventory
        }
        items
    end
end

class Room < Entity
    # TODO: consider using ObjectSpace._id2ref/object_id to connect Rooms?
    # Or maybe makes more sense to have a hash of Rooms and each
    # Room knows its exits refer to keys for other Rooms' values?
end

def test_entities
    bag = Item.new("BAG", "This is your bag")
    torch = Item.new("TORCH", "It burns brightly with the flame of justice!")
    torch.in_inventory = true
    puts Item.inventory.inspect
end

test_entities()

