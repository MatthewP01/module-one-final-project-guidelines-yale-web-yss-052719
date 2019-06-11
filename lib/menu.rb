PROMPT = TTY::Prompt.new

def clear_screen
  system "clear"
end

def start_game

  # Catpix::print_image "./media/planet_pic.jpg",
  #   :limit_x => 0.5,
  #   :limit_y => 0.5,
  #   :center_x => false,
  #   :center_y => false,
  #   :resolution => "auto"
  #
  # puts "\n\n\n"

  begin_this_game
end

def begin_this_game
  # prompt = TTY::Prompt.new

  name_input = PROMPT.ask("Hello GOD - What shall you name thyself?") do |q|
    q.required true
    q.convert :string
  end

  if User.all.find_by(name: name_input)
    active_user =  User.all.find_by(name: name_input)
    clear_screen
    puts "Welcome back Almighty #{active_user.name}"
  else
    new_user = User.create(name: name_input)
    user_id = new_user.id
    puts "Welcome, Almighy #{new_user.name}"
    ask_for_galaxy(user_id)
  end
end

def ask_for_galaxy(id_use)
  # prompt = TTY::Prompt.new

  galaxy_input = PROMPT.ask("My liege, what will you call your galaxy?") do |q|
    q.required true
    q.convert :string
  end

  new_galaxy = Galaxy.create(name: galaxy_input, user_id: id_use)
  clear_screen
  puts "Enjoy your new galaxy, #{new_galaxy.name}"
  User.find(id_use).galaxies << new_galaxy
  ask_for_planets(new_galaxy)
end

def planet_function(new_galaxy, counter, type, type_id)
  # prompt = TTY::Prompt.new
  # PlanetType.create(name: type)
  # clear_screen
  puts "You have #{counter} planets to make - you can use them to build your:\nstrength\ntechology\nresources"
  planet_input = PROMPT.ask("How many #{type} planets would you like to create?") do |q|
    q.required true
  end.to_i
    if planet_input >=1 && planet_input <= counter
      new_galaxy.create_planets(planet_input, type_id)
    else
      puts "Sorry, please input a number between 1 and #{counter}"
      planet_input = planet_function(new_galaxy, counter, type, type_id)
    end
  planet_input
end

def ask_for_planets(new_galaxy)
  counter = 10
  counter -= planet_function(new_galaxy, counter, "Resources", 1)
  if counter > 0
    counter -= planet_function(new_galaxy, counter, "Strength", 2)
  else
    exit 0
  end
  if counter > 0
    counter -= planet_function(new_galaxy, counter, "Technology", 3)
  else
    exit 0
  end
end
