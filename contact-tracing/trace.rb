#!/home/gitpod/.rvm/rubies/ruby-2.6.6/bin/ruby
require 'highline'
require_relative './helpers'
require_relative './objects'

#Time,Person,x,y
INPUT_LOCATIONS_FILE = "locations.csv"

#Time,Person
EXPOSURE_REPORTS_FILE = "exposure.csv"

#TraceId,Time,Person
OUTPUT_FILE = "output.csv"

# Our world is a 10x10 grid
SIZE_OF_WORLD = 10

# Draw an ASCII representation of the 10x10 world
# and the location of each person
def draw_person_map(locations_for_same_time)
    if locations_for_same_time.empty?
        return
    end

    # Create a 2D array and then draw from that array
    array = Array.new(SIZE_OF_WORLD) {Array.new(SIZE_OF_WORLD, " ")}
    locations_for_same_time.each do |location|
        array[location.x][location.y] = location.person
    end

    x = 0
    y = 0
    puts "#{cyan(' 0123456789')}     #{blue('t = ')}#{locations_for_same_time[0].time}"
    (0..9).each do |y|
        puts "#{cyan(y.to_s)}#{array[0][y]}#{array[1][y]}#{array[2][y]}#{array[3][y]}#{array[4][y]}#{array[5][y]}#{array[6][y]}#{array[7][y]}#{array[8][y]}#{array[9][y]}"
    end
    puts " "
end

$previous_neighbours = {}
$current_neighbours = {}
$exposures_final = []
$exposed = {}

def is_neighbour(location1, location2)
    if location1.x - location2.x > -2 && location1.x - location2.x < 2 && location1.y - location2.y > -2 && location1.y - location2.y < 2
        return true
    end
    return false
end

def tick (locations_for_same_time, time)
    $current_neighbours = {}

    if locations_for_same_time.empty?
        return
    end

    # Create a 2D array and then draw from that array
    array = Array.new(SIZE_OF_WORLD) {Array.new(SIZE_OF_WORLD, " ")}
    locations_for_same_time.each do |location|
        array[location.x][location.y] = location.person

        if !$previous_neighbours[location.person]
            $previous_neighbours[location.person] = []
        end
    end

    locations_for_same_time.each do |person_to_test|
        if $exposed[person_to_test.person] && $exposed[person_to_test.person] < time
            puts red "Skipping #{person_to_test.person} because they already get exposed at #{$exposed[person_to_test.person]}"
            next
        end

        locations_for_same_time.each do |possible_neighbour|
            if possible_neighbour.person == person_to_test.person
                next
            end
            puts cyan "Testing for #{person_to_test.person} if #{possible_neighbour.person} is a neighbour?"
            if is_neighbour(person_to_test, possible_neighbour)
                puts "Yes they are"
                if !$current_neighbours[person_to_test.person]
                    puts "Making the neighbours array for the first time this round"
                    $current_neighbours[person_to_test.person] = []
                end
                $current_neighbours[person_to_test.person] << possible_neighbour.person

                puts cyan "When does this neighbour get exposed? #{$exposed[possible_neighbour.person]} and it is now #{time}"
                if $exposed[possible_neighbour.person] && $exposed[possible_neighbour.person] < time
                    puts "Were they already neighbours?"
                    if $previous_neighbours[person_to_test.person].include? possible_neighbour.person
                        "Yes they were"
                        $exposures_final << [time-1, person_to_test.person, possible_neighbour.person]
                        $exposed[person_to_test.person] = time
                    else
                        puts "Nope"
                    end
                end
            else
                puts "Nope"
            end
        end
    end

    $previous_neighbours = $current_neighbours
end

puts " "

File.readlines(EXPOSURE_REPORTS_FILE).each do |line|
    data_elements = line.split ","
    time = data_elements[0].to_i
    person = data_elements[1].chomp

    puts red "Person #{person} exposed at t = #{time}"

    $exposed[person] = time
end

puts " "

current_time = 1
current_locations = []
previous_locations = []
File.readlines(INPUT_LOCATIONS_FILE).each do |line|
    data_elements = line.split ","
    time = data_elements[0].to_i
    person = data_elements[1]
    x = data_elements[2].to_i
    y = data_elements[3].to_i
    person_location = PersonLocation.new(time, person, x, y)

    if time == current_time
        current_locations << person_location
    else
        # The next two lines are for debugging and demo purposes
        draw_person_map(current_locations)

        tick(current_locations, current_time)
        
        previous_locations = current_locations
        current_time = time
        current_locations = []
        current_locations << person_location
    end
end

# Make sure to display the last time series
draw_person_map(current_locations)
tick(current_locations, current_time)

puts " "
puts cyan "Exposures were: (Time,Person)"
puts File.read(EXPOSURE_REPORTS_FILE)
puts cyan "The expected results were: (TraceId,Time,Person)"
puts File.read(OUTPUT_FILE)

puts "Exposures"

$i = 0
$exposures_final.each do |exposure|
    puts "#{$i},#{exposure[0]},#{exposure[1]}"
    $i = $i + 1
end
