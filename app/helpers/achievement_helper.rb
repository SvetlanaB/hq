module AchievementHelper
  def achievements_credits(achievements)
    only_cost = true
    credits = achievements.inject(0) do |res, a|
      unless a.refused?
        if a.activity.need_cost? && a.cost.zero?
          only_cost = false
        elsif a.activity.need_cost?
          res += a.cost
        elsif a.activity.flexible_credits?
          only_cost = false
        else
          res += a.activity.credit
        end
      end

      res
    end

    res = "#{prettify(credits)} #{Russian::p(prettify(credits), 'балл', 'балла', 'баллов', 'балла')}"

    res += ' + ?' unless only_cost

    res
  end

  def sgn(number)
    return  1 if number > 0
    return -1 if number < 0

    return  0
  end

  def vvv(x, b)
    sgn(x) * (1 - Math::E**(-b * x.abs))
  end
end