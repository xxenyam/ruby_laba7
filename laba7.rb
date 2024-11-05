require 'json'
require 'date'

class Task
  attr_accessor :title, :deadline, :status

  def initialize(title, deadline, status = 'не зроблено')
    @title = title
    @deadline = set_deadline(deadline)
    @status = status
  end

  def to_hash
    { 'title' => @title, 'deadline' => @deadline&.strftime('%d.%m.%Y'), 'status' => @status }
  end

  def self.from_hash(hash)
    new(hash['title'], hash['deadline'], hash['status'])
  end

  def to_s
    deadline_str = @deadline ? @deadline.strftime('%d.%m.%Y') : "Не встановлено"
    "Назва: #{@title} - Дедлайн: #{deadline_str} - Статус: #{@status}"
  end

  private

  def set_deadline(deadline)
    return nil if deadline.nil? || deadline.empty?
    begin
      day, month, year = deadline.split('.').map(&:to_i)
      Date.new(year, month, day)
    rescue ArgumentError
      puts "Невірний формат дати або недійсна дата '#{deadline}'. Потрібно використовувати формат ДД.ММ.РРРР і переконатися, що дата коректна."
      nil
    end
  end
end

class TaskApp
  FILE_PATH = 'tasks.json'

  def initialize
    @tasks = load_tasks
  end

  def add_task(title, deadline)
    @tasks << Task.new(title, deadline)
    save_tasks
  end

  def delete_task(title)
    @tasks.reject! { |task| task.title == title }
    save_tasks
  end

  def edit_task(title, new_title: nil, new_deadline: nil, new_status: nil)
    task = @tasks.find { |t| t.title == title }
    if task
      task.title = new_title if new_title
      task.deadline = set_new_deadline(new_deadline) if new_deadline
      task.status = new_status if new_status
      save_tasks
    else
      puts "Завдання не знайдено."
    end
  end

  def filter_tasks(task_status: nil, deadline_date: nil)
    filtered_tasks = @tasks

    filtered_tasks = filtered_tasks.select { |task| task.status == task_status } if task_status

    if deadline_date
      deadline_parsed = Date.strptime(deadline_date, '%d.%m.%Y') rescue nil
      if deadline_parsed
        filtered_tasks = filtered_tasks.select { |task| task.deadline <= deadline_parsed }
      else
        puts "Невірний формат дати для дедлайну '#{deadline_date}'. Використовуйте формат ДД.ММ.РРРР."
      end
    end

    filtered_tasks
  end

  def list_tasks
    @tasks.each { |task| puts task }
  end

  private

  def save_tasks
    File.write(FILE_PATH, JSON.pretty_generate(@tasks.map(&:to_hash)))
  end

  def load_tasks
    if File.exist?(FILE_PATH)
      JSON.parse(File.read(FILE_PATH)).map { |task_hash| Task.from_hash(task_hash) }
    else
      []
    end
  end

  def set_new_deadline(new_deadline)
    begin
      Date.strptime(new_deadline, '%d.%m.%Y')
    rescue ArgumentError
      puts "Неправильний формат дати для нового дедлайну '#{new_deadline}'. Використовуйте формат ДД.ММ.РРРР."
      nil
    end
  end
end

def main
  app = TaskApp.new

  loop do
    puts "\n1. Додати задачу"
    puts "2. Видалити задачу"
    puts "3. Редагувати задачу"
    puts "4. Відфільтрувати задачі"
    puts "5. Показати всі задачі"
    puts "6. Вихід"
    print "\nВиберіть дію: "
    choice = gets.to_i

    case choice
    when 1
      print "Введіть назву задачі: "
      title = gets.chomp
      print "Введіть дедлайн (ДД.ММ.РРРР): "
      deadline = gets.chomp
      app.add_task(title, deadline)
    when 2
      print "Введіть назву задачі для видалення: "
      title = gets.chomp
      app.delete_task(title)
    when 3
      print "Введіть назву задачі для редагування: "
      title = gets.chomp
      print "Нова назва (Enter, щоб пропустити): "
      new_title = gets.chomp
      new_title = nil if new_title.empty?
      print "Новий дедлайн (ДД.ММ.РРРР, Enter, щоб пропустити): "
      new_deadline = gets.chomp
      new_deadline = nil if new_deadline.empty?
      print "Новий статус (зроблено/не зроблено, Enter, щоб пропустити): "
      new_status = gets.chomp
      new_status = nil if new_status.empty?
      app.edit_task(title, new_title: new_title, new_deadline: new_deadline, new_status: new_status)
    when 4
      print "Фільтр за статусом (зроблено/не зроблено,Enter, щоб пропустити): "
      task_status = gets.chomp
      task_status = nil if task_status.empty?
      print "Фільтр за дедлайном (ДД.ММ.РРРР, Enter, щоб пропустити): "
      deadline_date = gets.chomp
      deadline_date = nil if deadline_date.empty?
      tasks = app.filter_tasks(task_status: task_status, deadline_date: deadline_date)
      tasks.each { |task| puts task }
    when 5
      app.list_tasks
    when 6
      break
    else
      puts "Невірний вибір, спробуйте ще раз."
    end
  end
end

if __FILE__ == $0
  main
end






