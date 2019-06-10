def clear_screen
  system "clear"
end

def start_game
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
  prompt = TTY::Prompt.new

  name_input = prompt.ask("Hello GOD - What shall you name thyself?") do |q|
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
  prompt = TTY::Prompt.new

  galaxy_input = prompt.ask("My liege, what will you call your galaxy?") do |q|
    q.required true
    q.convert :string
  end

  new_galaxy = Galaxy.create(name: galaxy_input, user_id: id_use)
  puts "Enjoy your new galaxy, #{new_galaxy.name}"
  User.find(id_use).galaxies << new_galaxy
end
