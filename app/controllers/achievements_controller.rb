class AchievementsController < ApplicationController
  load_and_authorize_resource

  def periods
    @periods = AchievementPeriod.all
  end

  def index
    @period = AchievementPeriod.where(year: params[:year],
                                      semester: params[:semester])
                               .first

    unless @period.active?
      redirect_to periods_achievements_path, notice: 'Приём данных по указанному периоду завершён.'
    end

    @achievements = @period.achievements.by(current_user)

    a = Activity.all.includes(:activity_group, :activity_type, :activity_credit_type)
    @groups = a.group_by { |activ| activ.activity_group.name }
  end

  def show

  end

  def new

  end

  def create
    @achievement.user_id = current_user.id

    if @achievement.save
      p = @achievement.period

      respond_to do |format|
        format.html do
          redirect_to achievements_path(year: p.year, semester: p.semester),
                      notice: 'Результат работы сохранён.'
        end

        format.js do
          @achievements = @achievement.period.achievements.by(current_user)
        end
      end
    else
      render action: :new
    end
  end

  def edit

  end

  def update
    if @achievement.update(resource_params)
      redirect_to achievements_path, notice: 'Изменения сохранены.'
    else
      render action: :edit
    end
  end

  def destroy
    @achievement = Achievement.unscoped.find(params[:id])
    @achievement.destroy

    @period = AchievementPeriod.find(params[:period])
    redirect_to achievements_path(year: @period.year, semester: @period.semester)
  end

  def resource_params
    params.fetch(:achievement, {}).permit(:description, :achievement_period_id,
                                          :activity_id)
  end
end