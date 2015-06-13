require 'number_helper'

class Task
  include NumberHelper

  @@filepath = nil
  def self.filepath=(path=nil)
    @@filepath = File.join(APP_ROOT, path)
  end

  attr_accessor :name, :steps, :price

  def self.file_exists?
    if @@filepath && File.exists?(@@filepath)
      return true
    else
      return false
    end
  end

  def self.file_usable?
    return false unless @@filepath
    return false unless File.exists?(@@filepath)
    return false unless File.readable?(@@filepath)
    return false unless File.writable?(@@filepath)
    return true
  end

  def self.create_file
    File.open(@@filepath, 'w') unless file_exists?
    return file_usable?
  end

  def self.saved_tasks
    tasks = []

    if file_usable?
      file = File.new(@@filepath, 'r')
      file.each_line do |line|
        tasks << Task.new.import_line(line.chomp)
      end
      file.close
    end
    tasks
  end

  def self.build_using_questions
    args = {}

    print 'Task name: '
    args[:name] = gets.chomp.strip

    print 'Steps: '
    args[:steps] = gets.chomp.strip

    return self.new(args)
  end

  def initialize(args={})
    @name = args[:name] || ''
    @steps = args[:steps] || ''
    # @price = args[:price] || ''
  end

  def import_line(line)
    line_array = line.split("\t")
    @name , @steps= line_array
    return self
  end

  def save
    return false unless Task.file_usable?
    File.open(@@filepath, 'a') do |file|
      file.puts "#{[@name, @steps].join("\t")}\n"
    end
    return true
  end

  def formatted_price
    number_to_currency(@price)
  end

end
