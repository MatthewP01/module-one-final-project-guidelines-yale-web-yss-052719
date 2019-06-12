require 'colorize'
PROMPT = TTY::Prompt.new

def clear_screen
  system "clear"
end

def start_game
   str = "  _____     __                 _      __
 / ___/__ _/ /__ ___ ____ __  | | /| / /__ ________
/ (_ / _ `/ / _ `/\\ \\ / // /  | |/ |/ / _ `/ __(_-<
\\___/\\_,_/_/\\_,_//_\\_\\\\_, /   |__/|__/\\_,_/_/ /___/
                     /___/                         ".yellow

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



def begin_this_game
  # prompt = TTY::Prompt.new

  name_input = PROMPT.ask("Hello GOD - What shall you name thyself?".blue) do |q|
    q.required true
    q.convert :string
  end

  if User.all.find_by(name: name_input)
    user =  User.all.find_by(name: name_input)
    # clear_screen
    puts "Welcome back Almighty #{user.name}"
  else
    user = User.create(name: name_input)
    user_id = user.id
    # clear_screen
    puts "Welcome, Almighty #{user.name}"
    ask_for_galaxy(user_id)
  end
  galaxy = user.galaxies.first
  run_game(user, galaxy)
end

def run_game(user, galaxy)

  continue = true
  resource_planets = galaxy.count_planets(PlanetType.find_by(name: "Resources").id)
  puts resource_planets
  if resource_planets == 0
    puts "Game Over"
    continue = false
  end
  while continue
    clear_screen
    options = ['Fight!', 'Manage your Galaxy', 'Quit']
    user_choice = PROMPT.select("What would you like to do?", options)
    if user_choice == "Manage your Galaxy"
      manage_planets(galaxy)
    elsif user_choice == "Fight!"
      fight(user)
    elsif user_choice == "Quit"
      puts "Goodbye...\n"
      continue = false
    end
    if resource_planets == 0
      puts "Game Over"
      continue = false
    end
  end
end

def ask_for_galaxy(id_use)

  galaxy_input = PROMPT.ask("My liege, what will you call your galaxy?") do |q|
    q.required true
    q.convert :string
  end

  new_galaxy = Galaxy.create(name: galaxy_input, user_id: id_use, unallocated: 0)
  this_user = User.find(id_use)
  this_user.galaxies << new_galaxy
  ask_for_planets(new_galaxy)
  # user_choice = choice
  # if choice == 2
  #   manage_planets(new_galaxy)
  # elsif choice == 1
  #   fight(this_user)
  # end

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
  # clear_screen
  puts "Resource Planets: #{galaxy.count_planets(PlanetType.find_by(name: "Resources").id)}"
  puts  "Strength Planets: #{galaxy.count_planets(PlanetType.find_by(name: "Strength").id)}"
  puts "Technology Planets: #{galaxy.count_planets(PlanetType.find_by(name: "Technology").id)}"
end

def manage_planets(galaxy)
  view_planets(galaxy)
  this_user_unallocated = galaxy.unallocated
  puts "You have #{this_user_unallocated} unallocated planet(s)"

  if this_user_unallocated == 0
    continue = false
    puts "No new planets - fight again to get more!"
  else
    continue = true
  end
  while continue
    manage_choice = PROMPT.select("Would you like to allocate token(s) to:") do |menu|
      menu.choice "Strength"
      menu.choice "Technology"
    end
    if manage_choice == "Strength"
      galaxy.create_planets(1, PlanetType.find_by(name: "Strength").id)
      this_user_unallocated -= 1
      galaxy.update(unallocated: this_user_unallocated)
    elsif manage_choice == "Technology"
      galaxy.create_planets(1, PlanetType.find_by(name: "Technology").id)
      this_user_unallocated -= 1
      galaxy.update(unallocated: this_user_unallocated)
    end
    if this_user_unallocated != 0
      puts "You now have #{this_user_unallocated} unallocated planets left"
      user_continue = PROMPT.select("Continue Allocating? Y/N") do |menu|
        menu.choice "Yes"
        menu.choice "No"
      end
    elsif this_user_unallocated == 0
      puts  "Out of new planets - fight again to get more!"
      puts "Current Status:"
      view_planets(galaxy)
      continue = false
    end
    if user_continue == "No"
      puts "Current Status:"
      view_planets(galaxy)
      continue = false
    end
  end
end

def fight(this_user)
  user_id_min = User.minimum("id")
  user_id_max = User.maximum("id")

  enemy_user = User.find(rand(user_id_min..user_id_max))
  puts "🚀 You are challenging #{enemy_user.name} to a galactic battle 🚀"
  arr_inst = [PlanetType.find_by(name: "Strength"), PlanetType.find_by(name: "Technology")]
  battle_attr = arr_inst[rand(0..1)]
  sleep(0.5)
  puts "They are fighting you with #{battle_attr.name}"

  enemy_attr = enemy_user.galaxies.first.count_planets(battle_attr.id)
  user_attr = this_user.galaxies.first.count_planets(battle_attr.id)
  puts "3...".red
  sleep(1)
  puts "2...".blue
  sleep(1)
  puts "1...".green
  sleep(1)
  if user_attr > enemy_attr
    puts "YOU WIN!!! 😎".blink
    win_or_lose(this_user, enemy_user, "win")
    #sleep(4)
  elsif user_attr == enemy_attr
    puts "It's a Draw 🙏".underline
    win_or_lose(this_user, enemy_user, "draw")
    #sleep(4)
  else
    puts "You Lose 😈 💀".bold
    win_or_lose(this_user, enemy_user, "lose")
    #sleep(4)
  end
  PROMPT.keypress("Press ENTER to return to menu", keys: [:return])
end

def win_or_lose(user, enemy_user, outcome)
  resource_id = PlanetType.find_by(name:"Resources").id

  user_unallocated = user.galaxies.first.unallocated
  user.galaxies.first.update(unallocated: user_unallocated + 1)
  enemy_unallocated = enemy_user.galaxies.first.unallocated
  enemy_user.galaxies.first.update(unallocated: enemy_unallocated + 1)

  if outcome == "lose"
    this_var = user.planets.find_by(planet_type_id: resource_id)
    this_var.destroy
    enemy_user.galaxies.first.create_planets(1, resource_id)
  elsif outcome == "win"
    user.galaxies.first.create_planets(1, resource_id)
    this_var = enemy_user.planets.find_by(planet_type_id: resource_id)
    this_var.destroy
  end
end
