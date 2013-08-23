class Study::Checkpointmark < ActiveRecord::Base
  self.table_name = 'checkpoint_mark'

  MARK_LECTURE_NOT_ATTEND   = 1001
  MARK_LECTURE_ATTEND       = 1002

  MARK_PRACTICAL_BAD        = 2001
  MARK_PRACTICAL_FAIR       = 2004
  MARK_PRACTICAL_GOOD       = 2002
  MARK_PRACTICAL_PERFECT    = 2003

  alias_attribute :id,        :checkpoint_mark_id
  alias_attribute :mark,      :checkpoint_mark_mark
  alias_attribute :retake,    :checkpoint_mark_retake

  belongs_to :student, primary_key: :id, foreign_key: :checkpoint_mark_student
  belongs_to :checkpoint, class_name: Study::Checkpoint, primary_key: :checkpoint_id, foreign_key: :checkpoint_mark_checkpoint

  scope :by_checkpoint, -> checkpoint { where(checkpoint: checkpoint) }
  scope :by_discipline, -> discipline {
    joins(:checkpoint).where(checkpoint: { checkpoint_subject: discipline })
  }
  scope :by_date, -> date {
    joins(:checkpoint).where(checkpoint: { checkpoint_date: date })
  }
  scope :by_student, -> student { where(student: student) }

  def result
    case mark
      when MARK_LECTURE_NOT_ATTEND
        {mark: 'не посетил', color: 'danger', circle: 10, hue: '#ee5f5b'}
      when MARK_LECTURE_ATTEND
        {mark: 'посетил', color: 'success', circle: 10, hue: '#62c462'}
      when MARK_PRACTICAL_BAD
        {mark: 'неудовлетворительно', color: 'danger', circle: 20, hue: '#ee5f5b'}
      when MARK_PRACTICAL_FAIR
        {mark: 'удовлетворительно', color: 'warning', circle: 20, hue: '#fbb450'}
      when MARK_PRACTICAL_GOOD
        {mark: 'хорошо', color: 'info', circle: 20, hue: '#5bc0de'}
      when MARK_PRACTICAL_PERFECT
        {mark: 'отлично', color: 'success', circle: 20, hue: '#62c462'}
    end
  end



end