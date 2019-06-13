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
  login_choice = PROMPT.select("Create a new GOD or Login as an existing GOD\n".bold) do |option|
    option.choice "Create new GOD"
    option.choice "Login as existing GOD"
    option.choice "Quit".red
  end

  if login_choice == "Create new GOD"
    ask = true

    while ask
      name_input = PROMPT.ask("Hello GOD - What shall you name thyself?") do |q|
        q.required true
        q.convert :string
      end
      if User.all.find_by(name: name_input)
        puts "\nSorry, that Godname is taken. Please choose another.\n".red.bold
      else
        user = User.create(name: name_input)
        user_id = user.id
        puts "\n 👑  Welcome, Almighty #{user.name} 👑\n".yellow.bold
        ask_for_galaxy(user_id)
        ask = false
      end
    end
    run_game(user)
    
  elsif login_choice == "Login as existing GOD"
    name_input = PROMPT.ask("Hello GOD - What are you called?") do |q|
      q.required true
      q.convert :string
    end
    user =  User.all.find_by(name: name_input)
    if user
     puts "\n 👑  Welcome back Almighty #{user.name} 👑\n".yellow.bold
     PROMPT.keypress("Press ENTER to continue", keys: [:return])
    else
     puts "\nThis GOD does not exist!\n".bold
     begin_this_game
    end
    run_game(user)

  elsif login_choice == "Quit".red
    puts "\nCome back soon!!\n\n"
  end
end

def run_game(user)
  continue = true
  galaxy = user.galaxies.first
  resource_planets = galaxy.count_planets(PlanetType.find_by(name: "Resources").id)
  if resource_planets == 0
    puts "Game Over - You ran out of resources while you were gone ☹️!".red.bold
    puts "Goodbye - thanks for playing"
    User.delete(user.id)
    continue = false
    PROMPT.keypress("Press ENTER to start again", keys: [:return])
    start_game

  end
  while continue
    galaxy = user.galaxies.first
    clear_screen
    options = ['Fight!','Manage your Galaxy', 'Create New God or Log In as Another God', 'Delete your God', 'Quit']
    user_choice = PROMPT.select("What would you like to do?", options)
    if user_choice == "Manage your Galaxy"
      manage_planets(galaxy)
    elsif user_choice == "Fight!"
      fight(user)
    elsif user_choice == "Quit"
      puts "Goodbye...\n"
      continue = false
    elsif user_choice == "Create New God or Log In as Another God"
      start_game
      continue = false
    elsif user_choice == "Delete your God"
      if PROMPT.yes?("Are you sure? Y/N")
        destroy_user(user)
        continue = false
        puts "Create a new God to play again!"
        sleep(3)
        clear_screen
        start_game
      end
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
end

def planet_function(new_galaxy, counter, type)
  type_id = PlanetType.find_by(name: type).id
  puts "\nEnjoy your new galaxy - #{new_galaxy.name}! You have #{counter} planets to create."
  puts "\nThere are three types of planets:\nResources\nStrength\nTechology\n\n"
  planet_input = PROMPT.ask("How many #{type} planets would you like to create?") do |q|
    q.required true
  end.to_i
    if planet_input >=1 && planet_input <= counter
      new_galaxy.create_planets(planet_input, type_id)
    else
      puts "\nSorry, please input a number between 1 and #{counter}".red.bold
      planet_input = planet_function(new_galaxy, counter, type)
    end
  planet_input
end

def ask_for_planets(new_galaxy)

  counter = 10
  counter -= planet_function(new_galaxy, counter, "Resources")
  if counter > 0
    counter -= planet_function(new_galaxy, counter, "Strength")
  else
    return 0
  end
  if counter > 0
    counter -= planet_function(new_galaxy, counter, "Technology")
  else
    return 0
  end
end

def view_planets(galaxy)
  puts "Resource Planets: #{galaxy.count_planets(PlanetType.find_by(name: "Resources").id)}"
  puts  "Strength Planets: #{galaxy.count_planets(PlanetType.find_by(name: "Strength").id)}"
  puts "Technology Planets: #{galaxy.count_planets(PlanetType.find_by(name: "Technology").id)}"
end

def manage_planets(galaxy)
  view_planets(galaxy)
  this_user_unallocated = galaxy.unallocated
  puts "\nYou have #{this_user_unallocated} unallocated planet(s)\n\n"

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
      puts "\nYour overall Strength is now #{galaxy.count_planets(PlanetType.find_by(name: "Strength").id)}\n".red.bold
    elsif manage_choice == "Technology"
      galaxy.create_planets(1, PlanetType.find_by(name: "Technology").id)
      this_user_unallocated -= 1
      galaxy.update(unallocated: this_user_unallocated)
      puts "\nYour overall Technology is now #{galaxy.count_planets(PlanetType.find_by(name: "Technology").id)}\n".blue.bold
    end
    if this_user_unallocated != 0
      puts "\nYou now have #{this_user_unallocated} unallocated planets left\n\n"
      user_continue = PROMPT.select("Continue Allocating? Y/N") do |menu|
        menu.choice "Yes"
        menu.choice "No"
      end
    elsif this_user_unallocated == 0
      puts  "\nOut of new planets - fight again to get more!"
      puts "\nCurrent Status:"
      view_planets(galaxy)
      continue = false
    end
    if user_continue == "No"
      puts "Current Status:"
      view_planets(galaxy)
      continue = false
    end
  end
  PROMPT.keypress("\nPress Enter to return to menu", key: [:return])
end

def find_enemy(this_user)
  checking = User.all.all? do |user|
    user.galaxies.first.count_planets(PlanetType.find_by(name: "Resources").id) == 0 || user == this_user
  end
  if checking
    puts "\n\n\nThere are no other living Gods - you are the Ultimate GOD!\n".yellow.bold.blink
    sleep(7)
    clear_screen
    start_game

  else
    enemy_user = User.all[(rand(User.all.size))]
    until enemy_user != this_user && enemy_user.galaxies.first.count_planets(PlanetType.find_by(name: "Resources").id) != 0
      enemy_user = User.all[(rand(User.all.size))]
    end
    return enemy_user
  end
end

def fight(this_user)
  enemy_user = find_enemy(this_user)
  puts "🚀 You are challenging #{enemy_user.name} to a galactic battle 🚀"
  arr_inst = [PlanetType.find_by(name: "Strength"), PlanetType.find_by(name: "Technology")]
  battle_attr = arr_inst[rand(0..1)]
  sleep(0.5)
  puts "They are fighting you with #{battle_attr.name}"

  enemy_attr = enemy_user.galaxies.first.count_planets(battle_attr.id)
  user_attr = this_user.galaxies.first.count_planets(battle_attr.id)
  puts "\n3...\n".red
  sleep(1)
  puts "\n2...\n".blue
  sleep(1)
  puts "\n1...\n".green
  sleep(1)
  if user_attr > enemy_attr
    puts "\nYOU WIN!!! 😎\n".blink
    win_or_lose(this_user, enemy_user, "win")
  elsif user_attr == enemy_attr
    puts "\nIt's a Draw 🙏\n".underline
    win_or_lose(this_user, enemy_user, "draw")
  else
    puts "\nYou Lose 😈 💀\n".bold
    win_or_lose(this_user, enemy_user, "lose")
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
    if user.galaxies.first.count_planets(PlanetType.find_by(name: "Resources").id) == 0
      puts "Game Over".red.bold
      puts "Game Over - You ran out of resources!".red.bold
      puts "Goodbye - thanks for playing"
      destroy_user(user)
      PROMPT.keypress("Press ENTER to start again", keys: [:return])
      clear_screen
      start_game
    end
  elsif outcome == "win"
    user.galaxies.first.create_planets(1, resource_id)
    this_var = enemy_user.planets.find_by(planet_type_id: resource_id)
    this_var.destroy
  end
end

def destroy_user(user)
  Planet.where(galaxy_id: Galaxy.find_by(user_id: user.id)).destroy_all
  Galaxy.where(user_id: user.id).destroy_all
  User.delete(user.id)
end
