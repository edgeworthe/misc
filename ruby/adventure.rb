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
    attr_accessor :description, :name, :container

    def initialize(name, description)
        @name = name
        @description = description
        @container = nil
    end

    def to_s
        @name
    end

    def action(verb)
        action = verb.downcase
        if self.methods.index(action) != nil
            self.send(action)
        else
            puts "I don't know how to #{verb} #{self}"
        end
    end

    def show_contents()
        # Yeah, inefficient
        ObjectSpace.each_object(Entity) do |e|
            puts e if e.container == self
        end
    end
end

class Item < Entity
    # TODO: Is there anything that distinguishes Items from 
    # Entities?
    def initialize(name, description)
        super
    end
end

class Room < Entity
    # TODO: consider using ObjectSpace._id2ref/object_id to connect Rooms?
    # Or maybe makes more sense to have a hash of Rooms and each
    # Room knows its exits refer to keys for other Rooms' values?
    # Or a hash of direction -> room object
    attr_accessor :exits
end

class DungeonMaster

    attr_accessor :current_location, :rooms

    def initialize()
        @rooms = { "home_base" => Room.new("HOMEBASE", 
                    "Sort-of pentagon shape in ground"),
                "first_base" => Room.new("FIRSTBASE",
                    "Soft square on ground."),
                "second_base" => Room.new("SECONDBASE",
                    "Soft square on ground. Deja vu."),
                "third_base" => Room.new("THIRDBASE",
                    "Soft square on ground. So much for original writing.") 
                 }
        @current_location = @rooms["home_base"]
    end

    # display current room description, a prompt character,
    # and accept+process user input
    def run_game()
        while 1 do
            puts @current_location
            print "> "
            begin
                command = gets.chomp
                do_thy_bidding(command)
            rescue
                # ctrl-D and chomp do not mix
                puts "\nDOES NOT COMPUTE\nType EXIT to exit!"
                command = ''
            end
        end
    end

    # Just test the various entities, make sure
    # stuff is working properly, no strange behaviors
    def test_entities
        start_room = Room.new("HOME PLATE", "This is where you start")
        inventory = Entity.new("INVENTORY", "The things you are carrying")
        bag = Item.new("BAG", "This is your bag")
        torch = Item.new("TORCH", 
            "It burns brightly with the flame of justice!")
        torch.container = inventory
        torch.action("LIGHT")
        #puts Item.inventory.inspect
        puts "Current inventory:"
        inventory.show_contents
        bag.container = inventory
        puts "Current inventory with bag:"
        inventory.show_contents
        puts start_room
    end

    def do_thy_bidding(command)
        # TODO: more command processing
        command.upcase!
        words = command.split()
        if words[0] == "EXIT"
            puts "Thanks for playing!"
            exit
        elsif words[0] == "TEST"
            test_entities()
        else
            puts "Sorry, I don't understand \"%s\"" % [command]
        end
    end

    def find_entity(name)
        # given the name of an entity, return its 
        # object if the entity is within reach,
        # or null otherwise.
    end

end

class Player < Entity
    # TODO: make fancy.
    # So far the only purpose I can think to have a Player
    # object is for inventory, which can be represented
    # as player_inventory in DungeonMaster, so maybe no 
    # need for this class?
end

if __FILE__ == $PROGRAM_NAME
    DungeonMaster.new().run_game()
end

