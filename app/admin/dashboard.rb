# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { t 'active_admin.dashboard' }

  content title: proc { t 'active_admin.dashboard' } do
    columns do
      column do
        panel t('active_admin.dashboard_welcome.upcoming_activities') do
          ul do
            Activity
              .in_country(top_level_domain)
              .includes(:event)
              .where(date: Date.current..Date.current.end_of_week, published: false)
              .order('event.visible_order')
              .each do |activity|
                li link_to_if(can?(:read, activity), human_activity_name(activity), admin_activity_path(activity))
              end
          end
        end

        panel t('active_admin.dashboard_welcome.latest_activities') do
          ul do
            Activity
              .in_country(top_level_domain)
              .includes(:event)
              .order(created_at: :desc)
              .first(10)
              .each do |activity|
                li link_to_if(can?(:read, activity), human_activity_name(activity), admin_activity_path(activity))
              end
          end
        end
      end
      column do
        panel t('active_admin.dashboard_welcome.info') do
          para t 'active_admin.dashboard_welcome.call_to_action'
        end
        panel t('active_admin.dashboard_welcome.change_log') do
          ul do
            li 'Поиск по клубам в селекторе на форме редактирования участника'
            li 'Возможность добавлять комментарий к волонтёрской позиции и отображение его в ростере.'
            li 'Подсветка строк с некорректными результатами в редакторе протокола и при просмотре забега.'
            li 'Добавлено отдельное поле RunPark ID. Ссылка в протоколе ведёт на сайт RunPark`а.'
            li 'Добавлена система аудитов. Можно посмотреть изменения, произведённые с пользователями и забегами.'
            li 'Участнику можно назначить Домашний забег. В некоторых случаях это может помочь идентифицировать человека.'
            li 'В редактор протокола добавлено действие - Обнулить 🏃 - сбрасывающее текущего участника на неизвестного.'
            li 'На форму создания результата добавлено поле с автокомплитом для поиска участников.'
            li 'После публикации забега в Деталях появляется ссылка на протокол данного забега на сайте.'
            li 'Возможность создавать свой набор волонтёрских позиций под каждую локацию.'
            li 'Оптимизация запросов, тонкая настройка меню и системы.'
            li 'Действие Удалить в редакторе протокола корректно удаляет результат, пересчитывая позиции.'
            li 'В редактор волонтёров добавлена возможность выгрузить таблицу в CSV файл.'
            li 'Награды участникам присваиваются в фоновом режиме после публикации протокола, если заполнены волонтёры.'
            li 'В редакторе протокола теперь можно вставить новый результат (строку) в любом месте. Наконец-то )'
            li 'Можно устанавливать пол новым участникам сразу при просмотре протокола.'
            li 'В поле для описания забега встроен редактор текста. Можно форматировать текст, добавлять ссылки на альбомы'
            li 'Автоматическое удаление лишних пробелов в имени участника'
            li 'После добавления волонтёра в забег происходит редирект на список волонтёров, а не на новую запись'
            li 'На страницу забега добавлена ссылка на внешний ресурс (паркран или 5 вёрст), можно посмотреть имя участника'
            li 'Поиск дубликатов переехал в фильтры и теперь ищет в любом порядке'
            li 'В разделе Участники можно выбрать сколько строк выводить на странице'
            li 'Расширен функционал редактора протокола за счёт переноса функций со странички просмотра забега.'
            li 'Изменена форма редактирования результата. Можно вводить как parkrun, 5 вёрст id, так и id из базы сайта.'
            li <<~CHANGE
              Добавлен автокомлит на страницу "Расписание волонтёров". Чтобы воспользоваться инструментом,
              предварительно нужно создать пустой предстоящий забег (можно сразу на 4 недели вперёд).
            CHANGE
            li 'Увеличен размер шрифтов.'
            li 'Раздел "Волонтёры" перенесён в "Забеги" и доступен из каждого забега по кнопке "Редактор волонтёров".'
            li 'Изменён диалог добавления волонтёрства. Выбор участника может производиться из автокомплита по имени и шк.'
          end
        end
      end
    end
  end
end
