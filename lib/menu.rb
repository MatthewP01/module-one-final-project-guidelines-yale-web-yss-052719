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
  # puts "\n\n\n\n\n"

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
    puts "Welcome back Almighty #{name_input}"
  end

end
