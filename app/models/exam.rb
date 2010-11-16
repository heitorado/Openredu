class Exam < ActiveRecord::Base

  # ASSOCIATIONS
  has_many :statuses, :as => :statusable
  has_many :question_exam_associations, :dependent => :destroy
  has_many :questions, :through => :question_exam_associations, :include => :alternatives, :order => :position
  has_many :exam_users, :dependent => :destroy
  has_many :user_history, :through => :exam_users, :source => :user
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner_id"
  belongs_to :simple_category
  has_one :lecture_subject, :as => :lectureable, :dependent => :destroy
  has_one :space_asset, :as => :asset
  has_one :space, :through => :space_asset#, :as => :asset
  
  # NESTED
  accepts_nested_attributes_for :questions, 
    :reject_if => lambda { |q| q[:statement].blank? },
    :allow_destroy => true


  # NAMED SCOPES
  named_scope :published, :conditions => ['published = ?', true], :include => :owner
  named_scope :published_by, lambda { |my_id|
    { :conditions => ["published = ? AND owner_id = ?", true, my_id] }
  }
  named_scope :unpublished_by, lambda { |my_id|
    { :conditions => ["published = ? AND owner_id = ?", false, my_id] }
  }

  # ACCESSORS
  attr_writer :current_step

  # PLUGINS
  acts_as_taggable
  ajaxful_rateable :stars => 5

  # VALIDATIONS
  validates_presence_of :name
  validates_presence_of :description
  validation_group :step1, :fields=>[:name, :description]
  validation_group :step2, :fields=>[:questions]
  validation_group :step3, :fields=>[:price]

  def get_question(qid)
    if qid
      self.questions.each_with_index do |question, index| 
        return [question,index]  if question.id == qid
      end
    end
  end

  def to_param #friendly url
    "#{id}-#{name.parameterize}"
  end

  def permalink
    APP_URL + "/exams/"+ self.id.to_s+"-"+self.name.parameterize
  end

  def current_step
    @current_step || steps.first
  end

  def steps
    %w[general editor publication]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end
end
