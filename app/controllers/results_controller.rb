# -*- encoding : utf-8 -*-
class ResultsController < BaseController
  include ExercisesHelper
  before_filter :load_hierarchy, only: [:index, :edit]

  load_resource :exercise
  load_and_authorize_resource :result, except: :create

  def create
    authorize! :read, @exercise.lecture
    @result = @exercise.start_for(current_user)

    respond_to do |format|
      format.html do
        redirect_to exercise_question_path(@exercise, @exercise.questions.first(:conditions => { :position => 1 }))
      end
    end
  end

  def update
    @exercise.finalize_for(current_user)
    @subject = @exercise.lecture.subject
    @space = @subject.space

    respond_to do |format|
      format.html do
        redirect_to \
          space_subject_lecture_path(@space, @subject, @exercise.lecture)
      end
    end
  end

  def edit
    @first_question = @exercise.questions.
      first(conditions: { position: 1})
    @last_question = @first_question.last_item
    @result = @exercise.result_for(current_user, false)
    @choices_count = current_user.choices.by_exercise(@exercise).count
    @questions_count = @exercise.questions.count

    respond_to do |format|
      format.html { render 'results/admin/edit' }
    end
  end

  def index
    authorize! :manage, @lecture
    @results = Result.finalized.where(exercise_id: @exercise).
      includes(:user, :choices, exercise: :questions)

    respond_to do |format|
      format.html { render 'results/admin/index' }
    end
  end

  def download
    result = Result.find(params[:result_id])
    #
    t = result.choices.map do |item|
      [
        item.question.statement, 
        item.question.explanation, 
        item.question.correct_alternative.text, 
        item.alternative.text
      ]
    end

    report = result.to_report

    html = render(template: 'results/download', locals: {results: t, report: report, result: result} ,layout: 'pdf')[0]

    kit = PDFKit.new(html, page_size: 'A4')
    send_file kit.to_file("#{Rails.root}/public/result_#{result.id}.pdf"),
      filename: "result_#{result.id}.pdf",
      type: "application/pdf",
      disposition: "inline"
  end

  protected

  def load_hierarchy
    @exercise = Exercise.find(params[:exercise_id])
    @lecture = @exercise.lecture
    @subject = @lecture.subject
    @space = @subject.space
    @course = @space.course
    @environment = @course.environment
  end
end
