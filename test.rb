require 'rspec'
require 'json'
require 'date'
require_relative 'laba7' 

RSpec.describe TaskApp do
  let(:app) { TaskApp.new }

  before do
    allow(STDOUT).to receive(:puts) # Убрати вивід в консолі
  end

  describe '#add_task' do
    it 'додає нову задачу' do
      app.add_task('Перевірка', '17.08.2025')
      expect(app.filter_tasks).to include(an_object_having_attributes(title: 'Перевірка', deadline: Date.strptime('17.08.2025', '%d.%m.%Y'), status: 'не зроблено'))
    end
  end

  describe '#delete_task' do
    it 'видаляє задачу за назвою' do
      app.add_task('Завдання для видалення', '18.08.2025')
      app.delete_task('Завдання для видалення')
      expect(app.filter_tasks).not_to include(an_object_having_attributes(title: 'Завдання для видалення'))
    end
  end

  describe '#edit_task' do
    it 'редагує назву задачі' do
      app.add_task('Стара назва', '17.08.2025')
      app.edit_task('Стара назва', new_title: 'Нова назва')
      expect(app.filter_tasks).to include(an_object_having_attributes(title: 'Нова назва'))
    end

    it 'редагує дедлайн задачі' do
      app.add_task('Редагування дедлайну', '17.08.2025')
      app.edit_task('Редагування дедлайну', new_deadline: '18.08.2025')
      expect(app.filter_tasks).to include(an_object_having_attributes(deadline: Date.strptime('18.08.2025', '%d.%m.%Y')))
    end

    it 'редагує статус задачі' do
      app.add_task('Перевірка статусу', '17.08.2025')
      app.edit_task('Перевірка статусу', new_status: 'зроблено')
      expect(app.filter_tasks).to include(an_object_having_attributes(status: 'зроблено'))
    end
  end

  describe '#filter_tasks' do
    it 'фільтрує задачі за статусом' do
      app.add_task('Завдання з статусом', '17.08.2025')
      app.edit_task('Завдання з статусом', new_status: 'зроблено')
      expect(app.filter_tasks(task_status: 'зроблено')).to include(an_object_having_attributes(title: 'Завдання з статусом'))
    end

    it 'фільтрує задачі за дедлайном' do
      app.add_task('Тест дедлайну', '17.08.2025')
      app.add_task('Інше завдання', '18.08.2025')
      expect(app.filter_tasks(deadline_date: '17.08.2025')).to include(an_object_having_attributes(title: 'Тест дедлайну'))
      expect(app.filter_tasks(deadline_date: '17.08.2025')).not_to include(an_object_having_attributes(title: 'Інше завдання'))
    end
  end

  describe '#list_tasks' do
    it 'виводить всі задачі' do
      app.add_task('Вивід задач', '17.08.2025')
      expect { app.list_tasks }.to output(/Вивід задач/).to_stdout
    end
  end
end



