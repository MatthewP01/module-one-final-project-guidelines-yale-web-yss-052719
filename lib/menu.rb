PROMPT = TTY::Prompt.new

def clear_screen
  system "clear"
end

def start_game
   str = "  _____     __                 _      __
 / ___/__ _/ /__ ___ ____ __  | | /| / /__ ________
/ (_ / _ `/ / _ `/\\ \\ / // /  | |/ |/ / _ `/ __(_-<
\\___/\\_,_/_/\\_,_//_\\_\\\\_, /   |__/|__/\\_,_/_/ /___/
                     /___/                         "

  puts str


  Catpix::print_image "./media/planet_pic.jpg",
    :limit_x => 0.5,
    :limit_y => 0.5,
    :center_x => false,
    :center_y => false,
    :resolution => "auto"

  puts "\n\n\n"

  begin_this_game
end

def choice
  clear_screen
  user_choice = PROMPT.select("What would you like to do?") do |option|
    option.choice "Fight", 1
    option.choice "Manage your Galaxy", 2
    user_choice
  end
end

def begin_this_game
  # prompt = TTY::Prompt.new

  name_input = PROMPT.ask("Hello GOD - What shall you name thyself?") do |q|
    q.required true
    q.convert :string
  end

  if User.all.find_by(name: name_input)
    active_user =  User.all.find_by(name: name_input)
    # clear_screen
    puts "Welcome back Almighty #{active_user.name}"
    if choice == 2
      view_planets(active_user.galaxies.first)
    elsif choice == 1
      fight(active_user)
    end
  else
    new_user = User.create(name: name_input)
    user_id = new_user.id
    # clear_screen
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
  # clear_screen
  this_user = User.find(id_use)
  this_user.galaxies << new_galaxy
  ask_for_planets(new_galaxy)
  # user_choice = choice
  if choice == 2
    view_planets(new_galaxy)
  elsif choice == 1
    fight(this_user)
  end
end

def planet_function(new_galaxy, counter, type)
  # prompt = TTY::Prompt.new
  # PlanetType.create(name: type)
  # clear_screen
  type_id = PlanetType.find_by(name: type).id
  puts "Enjoy your new galaxy! You have #{counter} planets to make - you can use them to build your:\nStrength\nTechology\nResources"
  planet_input = PROMPT.ask("How many #{type} planets would you like to create?") do |q|
    q.required true
  end.to_i
    if planet_input >=1 && planet_input <= counter
      new_galaxy.create_planets(planet_input, type_id)
    else
      puts "Sorry, please input a number between 1 and #{counter}"
      planet_input = planet_function(new_galaxy, counter, type)
    end
  planet_input
end

def ask_for_planets(new_galaxy)
  # clear_screen

  counter = 10
  counter -= planet_function(new_galaxy, counter, "Resources")
  # clear_screen
  if counter > 0
    counter -= planet_function(new_galaxy, counter, "Strength")
    # clear_screen
  else
    return 0
  end
  if counter > 0
    counter -= planet_function(new_galaxy, counter, "Technology")
    # clear_screen
  else
    return 0
  end
end

def view_planets(galaxy)
  clear_screen
  puts "Resource Planets: #{galaxy.count_planets(PlanetType.find_by(name: "Resources").id)}"
  puts  "Strength Planets: #{galaxy.count_planets(PlanetType.find_by(name: "Strength").id)}"
  puts "Technology Planets: #{galaxy.count_planets(PlanetType.find_by(name: "Technology").id)}"
end

def fight(this_user)
  user_id_min = User.minimum("id")
  user_id_max = User.maximum("id")

  enemy_user = User.find(rand(user_id_min..user_id_max))
  puts "🚀 You are challenging #{enemy_user.name} to a galactic battle 🚀"
  arr_inst = [PlanetType.find_by(name: "Strength"), PlanetType.find_by(name: "Technology")]
  battle_attr = arr_inst[rand(0..1)]
  puts "They are fighting you with #{battle_attr.name}"

  enemy_attr = enemy_user.galaxies.first.count_planets(battle_attr.id)
  puts enemy_attr
  user_attr = this_user.galaxies.first.count_planets(battle_attr.id)
  puts user_attr
end
