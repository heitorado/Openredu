class Exam < ActiveRecord::Base
  
  # PLUGINS
  acts_as_commentable
  acts_as_taggable
  ajaxful_rateable :stars => 5
  
  # ASSOCIATIONS
  has_many :question_exam_association, :dependent => :destroy
  has_many :questions, :through => :question_exam_association, :include => :alternatives, :order => :position
  has_many :exam_users, :dependent => :destroy
  has_many :user_history, :through => :exam_users, :source => :user
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :logs, :as => :logeable, :dependent => :destroy
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner_id"
  belongs_to :simple_category
  
  # NESTED
  accepts_nested_attributes_for :questions, 
    :reject_if => lambda { |q| q[:statement].blank? },
    :allow_destroy => true
  
  # VALIDATIONS
  validates_presence_of :name
  validates_presence_of :description
  #validates_length_of :name, :within => 6..40, :too_long => ": Por favor escolha um título menor que 20 caracteres.", :too_short => ": Por favor escolha um título maior que 6 caracteres."
  validates_associated :questions 
  validates_length_of :questions, :allow_nil => false, :within => 1..100, :too_long => "O exame contém {{count}} questões. O máximo de questões permitido é 100", :too_short => ": Um exame deve conter ao menos uma questão."
  
  validation_group :step1, :fields=>[:name, :description]
  validation_group :step2, :fields=>[:questions]
  validation_group :step3, :fields=>[:price]
  
  # NAMED SCOPES
  named_scope :published, :conditions => ['published = ?', true], :include => :owner
  
  named_scope :published_by, lambda { |my_id|
    { :conditions => ["published = ? AND owner_id = ?", true, my_id] }
  }
  
  named_scope :unpublished_by, lambda { |my_id|
    { :conditions => ["published = ? AND owner_id = ?", false, my_id] }
  }
  
  
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
  
  
end
