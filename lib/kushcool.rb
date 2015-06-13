require 'task'
require 'string_extend'

class Kushcool
  class Config
    @@actions = ['list', 'find', 'add', 'clear', 'quit']
    def self.actions; @@actions; end
  end


  def initialize(path=nil)
    Task.filepath = path

    if Task.file_usable?
      puts 'Found task file.'
    elsif Task.create_file
      puts 'Created task file.'
    else
      puts 'Exiting.\n\n'
      exit!
    end
  end

  def launch!
    introduction

    result = nil

    until result == :quit
      action, args = get_action
      result = do_action(action, args)
    end
    conclusion
  end

  def get_action
    action = nil
    until Kushcool::Config.actions.include?(action)
      puts 'Actions: ' + Kushcool::Config.actions.join(", ") if action
      print "> "
      user_response = gets.chomp
      args = user_response.downcase.strip.split(' ')
      action = args.shift
    end
    return action, args
  end

  def do_action(action, args=[])
    case action
      when 'list'
        list(args)
      when 'find'
        keyword = args.shift
        find(keyword)
      when 'add'
        add
      when 'clear'
        clear
      when 'quit'
        return :quit
      else
        puts "\nIdon't understand that command.\n"
    end
  end

  def list(args=[])
    sort_order = args.shift
    sort_order = args.shift if sort_order == 'by'
    sort_order = 'name' unless ['name', 'cuisine', 'price'].include?(sort_order)

    output_action_header 'Listing tasks'
    tasks = Task.saved_tasks

    tasks.sort! do |r1, r2|
      case sort_order
      when 'name'
        r1.name.downcase <=> r2.name.downcase
      when 'cuisine'
        r1.cuisine.downcase <=> r2.cuisine.downcase
      when 'price'
        r1.price.to_i <=> r2.price.to_i
      end
    end
    output_task_table tasks
    puts "Sort using: 'list cuisine' or list by cuisine\n\n"
  end

  def find(keyword='')
    output_action_header 'Find a task'
    if keyword
      tasks = Task.saved_tasks
      found = tasks.select do |t|
        t.name.downcase.include?(keyword.downcase) ||
        t.steps.downcase.include?(keyword.downcase)
        # rest.price.to_i <= keyword.to_i
      end

      output_task_table(found)
    else
      puts 'Find using a key phrase to search the task list.'
      puts "Examples: 'find tamale', 'find Mexican', 'find mex'\n\n"
    end
  end

  def add
    output_action_header 'Add a task'

    task = Task.build_using_questions
    if task.save
      puts "\nTask Added\n\n"
    else
      puts "\nSave Error: Task not added\n\n"
    end
  end

  def clear
    system 'clear'
  end

  def introduction
    puts "\n\n<<< Welcome to the Food Finder >>>\n\n"
    puts "This is an interactive guide to help you find the food you crave.\n\n"
  end

  def conclusion
    puts "\n<<< Goodbye and Bon Appetit! >>>\n\n\n"
  end

  private

  def output_action_header(text)
    puts "\n#{text.upcase.center(60)}\n\n"
  end

  def output_task_table(tasks=[])
    print ' ' + 'Name'.ljust(21)
    print ' ' + 'Steps'.ljust(30) + "\n"
    # print ' ' + 'Price'.rjust(6) + "\n"
    puts "-" * 60

    tasks.each do |t|
      line = ' ' << t.name.titleize.ljust(21)
      line << ' ' + t.steps.titleize.ljust(30)
      # line << ' ' + rest.formatted_price.rjust(6)
      puts line
    end

      puts 'No listing found' if tasks.empty?
      puts '-' * 60
  end

end
