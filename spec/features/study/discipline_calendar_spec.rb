require 'spec_helper'

feature 'Вывод списка группы для ввода оценок' do
  background 'Преподаватель' do
    # понять, куда это перенести
    @fd = create(:department, name: 'First Department', abbreviation: 'FD', department_role: 'faculty')
    ffs = create(:speciality, name: 'Empty', suffix: 'fdf', faculty: @fd)
    @fss = create(:speciality, name: 'First department second speciality', faculty: @fd)
    @group = create(:group, speciality: @fss)

    @user = create(:user, :lecturer)
    as_user(@user)
    @discipline = create(:discipline, semester: 2, year: 2013, lead_teacher: @user, group: @group)
    create(:exam, :final, discipline: @discipline)
  end

  scenario 'если нет контрольных точек, должен перенаправлять на календарь' do
    visit study_disciplines_path
    click_link 'Внести данные'
    within 'h1' do
      page.should have_content 'Расписание занятий и контрольных точек'
    end
    page.should have_content @group.name
    page.should have_content @discipline.name
    page.should have_css '.semester-calendar'
  end

  scenario 'если осенний семестр, должен выводить календарь с сентября по декабрь' do
    autumn_discipline = create(:discipline, semester: 1, lead_teacher: @user, group: @group)
    visit study_discipline_checkpoints_path(autumn_discipline)
    page.should have_content 'сент.'
    page.should have_content 'дек.'
  end

  scenario 'если весенний семестр, должен выводить календарь с января по июнь' do
    spring_discipline = create(:discipline, semester: 2, lead_teacher: @user, group: @group)
    visit study_discipline_checkpoints_path(spring_discipline)
    page.should have_content 'янв.'
    page.should have_content 'июня'
  end

  scenario 'по клику на календарь должны появляться спрятанные формы (лекции)', js: true, driver: :webkit do
    visit study_discipline_checkpoints_path(@discipline)
    within '.lectures' do
      find('td[data-date="13.02.2014"]').click
    end
    page.should have_css '.lecture_fields'
    within '.lecture_fields' do
      page.should have_css('input[value="13.02.2014"]', visible: false)
      page.should have_css('input[value="false"]', visible: false)
    end
  end

  scenario 'по клику выделенной даты, занятие должно помечаться на удаление (лекции)', js: true, driver: :webkit do
    visit study_discipline_checkpoints_path(@discipline)
    within '.lectures' do
      find('td[data-date="13.02.2014"]').click
      find('td[data-date="13.02.2014"]').click
    end
    within('.lecture_fields', visible: false) do
      page.should have_css('input[value="13.02.2014"]', visible: false)
      page.should have_css('input[value="1"]', visible: false)
    end
  end

  #scenario 'занятия должны сохраняться (лекции)', js: true, driver: :webkit do
  #  visit study_discipline_checkpoints_path(@discipline)
  #  within '.lectures' do
  #    find('td[data-date="13.02.2014"]').click
  #  end
  #  click_button 'Сохранить информацию о контрольных точках'
  #  @discipline.classes.count.should eql(1)
  #end

  scenario 'по клику на календарь должны появляться формы (контрольные точки)', js: true, driver: :webkit do
    visit study_discipline_checkpoints_path(@discipline)
    within '.checkpoints' do
      find('td[data-date="13.02.2014"]').click
    end
    page.should have_css '.checkpoint_fields'
    within '.checkpoint_fields' do
      page.should have_css('input[data-date="13.02.2014"]')
      page.should have_content 'Дата'
      page.should have_content 'Название'
      page.should have_content 'Описание'
      page.should have_content 'Максимальный балл'
      page.should have_content 'Зачётный минимум'
    end
  end

  scenario 'при верном заполнении контрольных точек должен перенаправлять на страницу с занятиями', js: true, driver: :webkit do
    visit study_discipline_checkpoints_path(@discipline)
    within '.checkpoints' do
      find('td[data-date="13.02.2014"]').click
    end
    within '.checkpoint_fields' do
      fill_in 'Название', with: 'Example name'
      fill_in 'Описание', with: 'Example descripltion'
      fill_in 'Максимальный балл', with: '80'
      fill_in 'Зачётный минимум', with: '44'
    end
    click_button 'Сохранить информацию о контрольных точках'
    within 'h1' do
      page.should have_content @discipline.name
    end
    within 'table' do
      page.should have_content 'Example name'
      page.should have_content '13.02.2014'
      page.should have_content 'Внести результаты'
    end
  end

  scenario 'если не введено название, не должен сохранять', js: true, driver: :webkit do
    visit study_discipline_checkpoints_path(@discipline)
    within '.checkpoints' do
      find('td[data-date="13.02.2014"]').click
    end
    within '.checkpoint_fields' do
      fill_in 'Описание', with: 'Example descripltion'
      fill_in 'Максимальный балл', with: '80'
      fill_in 'Зачётный минимум', with: '44'
    end
    click_button 'Сохранить информацию о контрольных точках'
    within 'h1' do
      page.should have_content 'Расписание занятий и контрольных точек'
    end
    page.should have_css '.has-error'
  end

  scenario 'при неверном заполнении минимума и максимума не должен сохранять', js: true, driver: :webkit do
      visit study_discipline_checkpoints_path(@discipline)
      within '.checkpoints' do
        find('td[data-date="13.02.2014"]').click
      end
      within '.checkpoint_fields' do
        fill_in 'Название', with: 'Example name'
        fill_in 'Описание', with: 'Example descripltion'
        fill_in 'Максимальный балл', with: '90'
        fill_in 'Зачётный минимум', with: '94'
      end
      click_button 'Сохранить информацию о контрольных точках'
      within 'h1' do
        page.should have_content 'Расписание занятий и контрольных точек'
      end
      page.should have_content 'Сумма максимальных баллов должна равняться 80. У вас — 90.'
      page.should have_content 'Сумма минимальных зачётных баллов должна равняться 44. У вас — 94.'
      page.should have_content 'Минимальный зачётный балл должен быть меньше, чем максимальный балл.'
    end

end