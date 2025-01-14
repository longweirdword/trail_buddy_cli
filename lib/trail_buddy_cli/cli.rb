class CLI 
    attr_accessor :current_state, :current_trail 

    VALID_STATES = ["alabama", "alaska", "arizona", "arkansas", "california", 
        "colorado", "connecticut", "delaware", "florida", "georgia",
         "hawaii", "idaho", "illinois", "indiana", "iowa", "kansas", "kentucky", "louisiana",
         "maine", "maryland", "massachusetts", "michigan", "minnesota", 
         "mississippi", "missouri", "montana", "nebraska", "nevada", "new hampshire", "new jersey", 
         "new mexico", "new york", "north carolina", "north dakota",
         "ohio", "oklahoma", "oregon", "pennsylvania", "rhode island", 
         "south carolina", "south dakota", "tennessee", "texas", "utah", "vermont", 
         "virginia", "washington", "washington dc", "west virginia", "wisconsin", "wyoming"] 


    def start 
        system "clear"
        "Hello Adventurer!".colorize(:green).split("").each{|letter| print letter; sleep 0.05}
        sleep 1
        get_state 
    end 

    def get_state
        line_break
        puts "Welcome to Trail Buddy!"
        line_break
        puts "Please enter the name of the State you would like to explore today:"
        state = user_input
        validate_input(state)
    end 

    def validate_input(state)
        if VALID_STATES.include?(state)
            get_state_trails(state)
        else 
            puts "Invalid entry."
            puts "Please enter the name of the State you would like to explore today:"
            state = user_input
            validate_input(state)
        end 
    end 

    def get_state_trails(state)
        line_break
        puts "\nPlease wait while we scout up ahead...".colorize(:green)
        @current_state = state.split(" ").map{|word| word.capitalize}.join(" ")

        Scraper.get_data_by_state(state) if !duplicate?(state)
        print_state_trails
    end 

    def duplicate?(state)
        Trail.all.detect{|trail| trail.state == current_state} ? true : false 
    end 
        
    def print_state_trails 
        system "clear"
        line_break                                                
        puts "Here are the top rated hiking trails for #{current_state}:".colorize(:green)
        puts "--------------------------------------------------".colorize(:light_black)
        Trail.select_by_state(current_state).each_with_index do |trail, index|
        puts "#{index + 1}. #{trail.name}".colorize(:blue) + " - #{trail.location}"
        line_break
        puts "#{trail.overview}"
        puts "Total time".colorize(:red) + " #{trail.time_estimate.downcase}"
        line_break
        end 
        puts "--------------------------------------------------".colorize(:light_black)
        select_trail
    end 

    def select_trail
        puts "-For more information on a trail, please enter the number of the corresponding trail (1-10)".colorize(:green)
        puts "-To explore a new state, enter 'new'".colorize(:green)
        puts "-To exit, enter 'exit'".colorize(:green)
        input = user_input

        if input.to_i.between?(1,10)
            more_trail_info(input.to_i)
        elsif input == "new"
            system "clear"
            get_state
        elsif input == "exit"
            goodbye
        else 
            invalid 
            select_trail
        end 
    end 

    def more_trail_info(input)
        system "clear"
        @current_trail = Trail.select_by_state(current_state)[input -1]
        puts "#{current_trail.name}".colorize(:blue) + " - #{current_trail.location}, #{current_state}"
        puts "Length:".colorize(:red) + " #{current_trail.length} - #{current_trail.time_estimate}"
        puts "Difficulty:".colorize(:red) + " #{current_trail.difficulty}"
        puts "Elevation gain:".colorize(:red) + " #{current_trail.elevation_gain}"
        puts "route type:".colorize(:red) + " #{current_trail.route_type}"
        puts "---------------------------------------------------".colorize(:light_black)
        current_trail.description != nil ? (puts "#{current_trail.description}") : (puts "#{current_trail.overview}")
        puts "---------------------------------------------------".colorize(:light_black)
        puts "Facilities and contact information:".colorize(:red)
        line_break
        puts "#{current_trail.facilities}" 
        line_break
        puts "#{current_trail.contact}" 
        menu 
    end 

    def menu 
        line_break 
        puts "-To view the weather forecast for this area, enter 'weather'".colorize(:green)
        puts "-To return to #{current_state} trails, enter 'back'".colorize(:green)
        puts "-To explore a new state, enter 'new'".colorize(:green)
        puts "-To exit, enter 'exit'".colorize(:green)

        input = user_input
        if input == "weather"
            line_break
            get_weather
            print_weather 
        elsif input == "back"
            print_state_trails
        elsif input == "new"
            system "clear"
            get_state 
        elsif input == "exit"
            goodbye
        else 
            invalid
            menu 
        end 
    end 

    def get_weather
        API.get_weather_by_trail(current_trail) 
    end 

    def print_weather 
        if current_trail.weather == []
            line_break
            puts "Weather data unavailable at this time."
        else 
            line_break
            puts "----------------------------------------".colorize(:light_black)
            current_trail.weather.each_with_index do |day, index|
            puts "#{day.day}".colorize(:light_blue)
            line_break
            puts "#{day.description}"
            puts "High:".colorize(:red) + " #{day.max_temp}°"
            puts "Low:".colorize(:red) + " #{day.min_temp}°"
            puts "Humidity:".colorize(:red) + " #{day.humidity}%"
            puts '_____________________'.colorize(:light_black) if index != current_trail.weather.length - 1 
            end 
            puts "----------------------------------------".colorize(:light_black)
        end 
        weather_menu 
    end
    
    def weather_menu 
        line_break 
        puts "-To return to #{current_state} trails, enter 'back'".colorize(:green)
        puts "-To explore a new state, enter 'new'".colorize(:green)
        puts "-To exit, enter 'exit'".colorize(:green)

        input = user_input
        if input == "back"
            print_state_trails
        elsif input == "new"
            system "clear"
            get_state 
        elsif input == "exit"
            goodbye 
        else 
            invalid
            weather_menu 
        end 
    end 

    def user_input 
        gets.strip.downcase
    end 

    def line_break 
        puts ""
    end 

    def invalid 
        line_break
        puts "Invalid entry! Please try again."
    end 

    def goodbye 
        system "clear"
        "Happy Hiking!".colorize(:green).split("").each{|letter| print letter; sleep 0.05}
        sleep 2
        system "clear"
    end 

end 